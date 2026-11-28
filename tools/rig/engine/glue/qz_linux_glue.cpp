// qzlinux17 glue: replaces QzDoom_OpenXR.cpp / TBXR_Common.cpp / OpenXrInput.cpp of
// emawind84/questzdoom (the Android JNI + OpenXR layer) for a headless Linux test build.
// The engine's real OpenXR device mode (gl_openxrdevice.cpp, vr_mode 15) runs unchanged;
// this file only supplies what the OpenXR runtime would: HMD/controller poses (OpenXR stage
// space: +X right, +Y up, -Z forward, metres), buttons, eye buffers and the projection.
//
// Poses / buttons can be driven at runtime with console cvars (or env vars at startup):
//   qz_hmd   "x y z pitch yaw roll"   default "0 1.6 0 0 0 0"           (env QZ_HMD)
//   qz_rhand "x y z pitch yaw roll"   default "0.25 1.3 -0.3 30 0 0"     (env QZ_RHAND)
//   qz_lhand "x y z pitch yaw roll"   default "-0.25 1.3 -0.3 30 0 0"    (env QZ_LHAND)
//   qz_rtrigger / qz_rgrip / qz_ltrigger / qz_lgrip   0..1 (>0.5 = pressed)
//   qz_rbuttons / qz_lbuttons   raw xrButton bitmask (A=1 B=2 X=0x100 Y=0x200 thumb=4/0x400 ...)
//   qz_rstick / qz_lstick "x y"   thumbstick axes
// Angles in degrees: pitch about +X (positive = up), yaw about +Y (positive = left), roll about -Z.
// Hand pitch defaults to +30 because the engine applies vr_weaponRotate (-30) to the raw controller
// pose; +30 makes the in-game weapon aim level/forward (AttackPitch 0, AttackDir angle 0 pitch 0).
//
// (2026-11-27, rig2) HAND ROLL. qz_aimroll 0 (default, as before): a hand's angles are the raw
// controller's, q = yaw * pitch * roll, and the engine then turns that by vr_weaponRotate about the
// controller's own X (TBXR_Common.cpp QuatToYawPitchRoll, rotation[PITCH] = vr_weaponRotate,
// VrInputDefault.cpp:158-160 / 193-195). The roll is applied BEFORE that -30, so it does not survive
// it: roll 45 at pitch 30 reads AttackRoll 38.12 and leaks 7.29 into AttackPitch, 20.88 into the yaw.
// qz_aimroll 1: the roll is put AFTER the engine's turn (q = yaw * pitch' * roll * pitch(-wr), with
// pitch' = pitch + wr, wr = vr_weaponRotate), so AttackRoll / OffhandRoll read the roll exactly and
// pitch / yaw read as with roll 0. With roll 0 both modes give the same quaternion.
// Env QZ_AIMROLL sets the startup value.
//
// (2026-11-27, rig2) TEST-ONLY COMMANDS (nothing in the engine changes):
//   rig_key <keyname> [down|up|tap]   posts EV_KeyDown / EV_KeyUp for any key of the engine's key
//       table (c_bind.cpp KeyNames: Pad_A, Pad_B, Axis4Plus, Escape, Enter, K, RTrigger, #<code> ...)
//       through D_PostEvent, the call a Quest controller button makes (m_joy.cpp
//       Joy_GenerateButtonEvents): console -> menu (M_Responder, DMenu::CallMenuEvent /
//       CallResponder raise DMenu::InMenu) -> game bindings. tap (default) = down then up.
//   qz_state   prints the VR input state the engine reads: frame count, gametic, menu / game state,
//       hmd angles, snapTurn, doomYaw, weapon / off-hand angles, vr_control_scheme, vr_snapTurn.
//   qz_hz <n> (cvar, env QZ_HZ)   0 = frames as fast as the rig renders (as before); n > 0 holds the
//       render loop to at most n frames a second (a Quest at 72 / 90 / 120 Hz). The engine's smooth
//       turn (vr_snapTurn <= 10) and other per-frame input are per FRAME, so this sets their speed.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <time.h>
#include <signal.h>
#include <execinfo.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include "VrInput.h"
#include "xr_linear.h"
#include "c_dispatch.h"
#include "d_eventbase.h"
#include "keydef.h"
#include "printf.h"

// ---- android log shim ---------------------------------------------------
extern "C" int __android_log_vprint(int prio, const char *tag, const char *fmt, va_list ap)
{
	static int on = -1;
	if (on < 0) on = getenv("QZ_LOGCAT") != nullptr;
	if (!on) return 0;
	fprintf(stderr, "[%s] ", tag ? tag : "");
	int r = vfprintf(stderr, fmt, ap);
	fputc('\n', stderr);
	return r;
}
extern "C" int __android_log_print(int prio, const char *tag, const char *fmt, ...)
{
	va_list ap; va_start(ap, fmt);
	int r = __android_log_vprint(prio, tag, fmt, ap);
	va_end(ap);
	return r;
}

// (added 2026-10-25, as the 2026-10-24 rig did) the engine also calls the non-varargs writer
extern "C" int __android_log_write(int prio, const char *tag, const char *text)
{
	return __android_log_print(prio, tag, "%s", text ? text : "");
}

// ---- globals normally defined in QzDoom_OpenXR.cpp / TBXR_Common.cpp ----
class FArgs;
FArgs *Args;	// defined by the wrapper on Android (d_main.cpp only declares it)
int NUM_MULTI_SAMPLES = 2;
int REFRESH = 0;
float SS_MULTIPLIER = 1.25f;
bool qzdoom_initialised;
long long global_time;
float playerYaw;
bool resetDoomYaw;
bool resetPreviousPitch;
float doomYaw;
float previousPitch;
vec3_t worldPosition;
vec3_t hmdPosition;
vec3_t hmdorientation;
vec3_t positionDeltaThisFrame;
vec3_t weaponangles;
vec3_t weaponoffset;
bool weaponStabilised;
vec3_t offhandangles;
vec3_t offhandoffset;
bool player_moving;
bool shutdown;
bool ready_teleport;
bool trigger_teleport;
bool cinemamode;
ovrApp gAppState;
ovrAppThread *gAppThread;
ovrJava java;
static bool useVirtualScreen = false;

static int g_width = 1024, g_height = 1024;
static GLuint g_fbo, g_color, g_depth;

// ---- pose / button cvars --------------------------------------------------
static const char *envor(const char *e, const char *d) { const char *v = getenv(e); return v ? v : d; }
CVAR(String, qz_hmd,   envor("QZ_HMD",   "0 1.6 0 0 0 0"), 0)
CVAR(String, qz_rhand, envor("QZ_RHAND", "0.25 1.3 -0.3 30 0 0"), 0)
CVAR(String, qz_lhand, envor("QZ_LHAND", "-0.25 1.3 -0.3 30 0 0"), 0)
CVAR(Float, qz_rtrigger, 0.f, 0)
CVAR(Float, qz_rgrip, 0.f, 0)
CVAR(Float, qz_ltrigger, 0.f, 0)
CVAR(Float, qz_lgrip, 0.f, 0)
CVAR(Int, qz_rbuttons, 0, 0)
CVAR(Int, qz_lbuttons, 0, 0)
CVAR(String, qz_rstick, "0 0", 0)
CVAR(String, qz_lstick, "0 0", 0)
CVAR(Int, qz_aimroll, atoi(envor("QZ_AIMROLL", "0")), 0)
CVAR(Int, qz_hz, atoi(envor("QZ_HZ", "0")), 0)
EXTERN_CVAR(Float, vr_weaponRotate)
EXTERN_CVAR(Float, vr_snapTurn)

// hand = true for a controller: with qz_aimroll the roll goes after the engine's vr_weaponRotate
static XrPosef ParsePose(const char *s, bool hand = false)
{
	float v[6] = {0, 0, 0, 0, 0, 0};
	sscanf(s, "%f %f %f %f %f %f", &v[0], &v[1], &v[2], &v[3], &v[4], &v[5]);
	XrPosef p;
	p.position.x = v[0]; p.position.y = v[1]; p.position.z = v[2];
	XrQuaternionf qy, qx, qz, t;
	XrVector3f ay = {0, 1, 0}, ax = {1, 0, 0}, az = {0, 0, -1};
	const float d2r = (float)M_PI / 180.f;
	XrQuaternionf_CreateFromAxisAngle(&qy, &ay, v[4] * d2r);
	XrQuaternionf_CreateFromAxisAngle(&qz, &az, v[5] * d2r);
	if (hand && qz_aimroll && v[5] != 0.f)
	{
		// q = yaw * pitch(p + wr) * roll * pitch(-wr): after the engine's * pitch(wr) the aim frame is
		// yaw * pitch(p + wr) * roll, so its roll is v[5] and its pitch / yaw are those of roll 0.
		const float wr = vr_weaponRotate;
		XrQuaternionf qxp, qxm, t1;
		XrQuaternionf_CreateFromAxisAngle(&qxp, &ax, (v[3] + wr) * d2r);
		XrQuaternionf_CreateFromAxisAngle(&qxm, &ax, -wr * d2r);
		XrQuaternionf_Multiply(&t1, &qxm, &qz);     // qz * qxm
		XrQuaternionf_Multiply(&t, &t1, &qxp);      // qxp * qz * qxm
		XrQuaternionf_Multiply(&p.orientation, &t, &qy);
		return p;
	}
	// q = yaw(Y) * pitch(X) * roll(Z)
	XrQuaternionf_CreateFromAxisAngle(&qx, &ax, v[3] * d2r);
	XrQuaternionf_Multiply(&t, &qz, &qx);   // xr_linear: Multiply(result,a,b) = b*a
	XrQuaternionf_Multiply(&p.orientation, &t, &qy);
	return p;
}

// ---- QzDoom_* ----------------------------------------------------------
void QzDoom_setUseScreenLayer(bool use) { useVirtualScreen = use; }
int QzDoom_SetRefreshRate(int refreshRate) { return 0; }
void QzDoom_GetScreenRes(uint32_t *width, uint32_t *height) { *width = g_width; *height = g_height; }
void QzDoom_Vibrate(float duration, int channel, float intensity) {}
void QzDoom_Restart() { fprintf(stderr, "qzlinux: QzDoom_Restart requested (Android would relaunch the app); exiting\n"); exit(3); }
bool VR_UseScreenLayer() { return useVirtualScreen || cinemamode; }
float VR_GetScreenLayerDistance() { return 4.0f; }

void VR_SetHMDOrientation(float pitch, float yaw, float roll)
{
	VectorSet(hmdorientation, pitch, yaw, roll);
	if (!VR_UseScreenLayer()) playerYaw = yaw;
}

void VR_SetHMDPosition(float x, float y, float z)
{
	VectorSet(hmdPosition, x, y, z);
	positionDeltaThisFrame[0] = (worldPosition[0] - x);
	positionDeltaThisFrame[1] = (worldPosition[1] - y);
	positionDeltaThisFrame[2] = (worldPosition[2] - z);
	worldPosition[0] = x; worldPosition[1] = y; worldPosition[2] = z;
}

void VR_GetMove(float *joy_forward, float *joy_side, float *hmd_forward, float *hmd_side, float *up,
				float *yaw, float *pitch, float *roll)
{
	*joy_forward = remote_movementForward;
	*hmd_forward = positional_movementForward;
	*up = remote_movementUp;
	*joy_side = remote_movementSideways;
	*hmd_side = positional_movementSideways;
	*yaw = cinemamode ? cinemamodeYaw : hmdorientation[YAW] + snapTurn;
	*pitch = cinemamode ? cinemamodePitch : hmdorientation[PITCH];
	*roll = cinemamode ? 0.0f : hmdorientation[ROLL];
}

void VR_FrameSetup() {}

// Per-eye FOV a Quest-like runtime would report (symmetric 90x90 here)
static XrFovf g_fov = { -0.785398f, 0.785398f, 0.785398f, -0.785398f };
static float fov_y = 90.0f;
float QzDoom_GetFOV() { return fov_y; }

bool VR_GetVRProjection(int eye, float zNear, float zFar, float *projection)
{
	XrMatrix4x4f m;
	XrMatrix4x4f_CreateProjectionFov(&m, GRAPHICS_OPENGL_ES, g_fov, zNear, zFar);
	memcpy(projection, m.m, 16 * sizeof(float));
	return true;
}

void VR_ExternalHapticEvent(const char *event, int position, int flags, int intensity, float angle, float yHeight) {}
void VR_HapticStopEvent(const char *event) {}
void VR_HapticEnable() {}
void VR_HapticDisable() {}
void VR_HapticEvent(const char *event, int position, int intensity, float angle, float yHeight) {}
void VR_HapticUpdateEvent(const char *event, int intensity, float angle) {}
void VR_HapticEndFrame() {}
extern "C" {
void jni_haptic_event(const char *event, int position, int intensity, float angle, float yHeight) {}
void jni_haptic_updateevent(const char *event, int intensity, float angle) {}
void jni_haptic_stopevent(const char *event) {}
void jni_haptic_endframe() {}
void jni_haptic_enable() {}
void jni_haptic_disable() {}
}
void jni_shutdown() { exit(0); }
void VR_Shutdown() { jni_shutdown(); }

// ---- pose math copied verbatim from TBXR_Common.cpp by build.sh ----
#include "tbxr_math.inc"

// ---- controllers (replaces OpenXrInput.cpp TBXR_UpdateControllers) ------
static void FillRemote(ovrInputStateTrackedRemote *r, float trig, float grip, int raw, const char *stick)
{
	memset(r, 0, sizeof(*r));
	r->Buttons = (uint32_t)raw;
	r->IndexTrigger = trig; r->GripTrigger = grip;
	if (trig > 0.5f) r->Buttons |= xrButton_Trigger;
	if (grip > 0.5f) r->Buttons |= xrButton_GripTrigger;
	sscanf(stick, "%f %f", &r->Joystick.x, &r->Joystick.y);
}

// TEST DRIVER HOOK (2026-10-25): ZScript may not change an engine cvar, so a test pack cannot move
// these controllers from a script. If a loaded pack defines its own (CVARINFO, so scripts may set
// them) qzt_lhand / qzt_rhand / qzt_lgrip / qzt_ltrigger / qzt_rgrip / qzt_rtrigger, a non-empty or
// non-negative value replaces the qz_ one. Nothing in the engine changes; without such a pack the
// controllers are driven exactly as before.
static const char *PoseOr(const char *name, const char *dflt)
{
	FBaseCVar *v = FindCVar(name, nullptr);
	if (v && v->GetRealType() == CVAR_String) { const char *s = v->GetGenericRep(CVAR_String).String; if (s && *s) return s; }
	return dflt;
}
static float AxisOr(const char *name, float dflt)
{
	FBaseCVar *v = FindCVar(name, nullptr);
	if (v) { float f = v->GetGenericRep(CVAR_Float).Float; if (f >= 0.f) return f; }
	return dflt;
}

void TBXR_UpdateControllers()
{
	for (int i = 0; i < 2; i++)
	{
		ovrTrackedController &c = gAppState.TrackedController[i];
		memset(&c, 0, sizeof(c));
		c.Active = GL_TRUE;
		c.Pose = ParsePose(i == 0 ? PoseOr("qzt_lhand", *qz_lhand) : PoseOr("qzt_rhand", *qz_rhand), true);
		c.Velocity.type = XR_TYPE_SPACE_VELOCITY;
	}
	leftRemoteTracking_new = gAppState.TrackedController[0];
	rightRemoteTracking_new = gAppState.TrackedController[1];
	FillRemote(&leftTrackedRemoteState_new, AxisOr("qzt_ltrigger", qz_ltrigger), AxisOr("qzt_lgrip", qz_lgrip), qz_lbuttons, *qz_lstick);
	FillRemote(&rightTrackedRemoteState_new, AxisOr("qzt_rtrigger", qz_rtrigger), AxisOr("qzt_rgrip", qz_rgrip), qz_rbuttons, *qz_rstick);
}

void VR_HandleControllerInput()
{
	TBXR_UpdateControllers();
	switch (vr_control_scheme)
	{
	case RIGHT_HANDED_DEFAULT:
		HandleInput_Default(vr_control_scheme,
			&rightTrackedRemoteState_new, &rightTrackedRemoteState_old, &rightRemoteTracking_new,
			&leftTrackedRemoteState_new, &leftTrackedRemoteState_old, &leftRemoteTracking_new,
			xrButton_A, xrButton_B, xrButton_X, xrButton_Y);
		break;
	case LEFT_HANDED_DEFAULT:
	case LEFT_HANDED_ALT:
		HandleInput_Default(vr_control_scheme,
			&leftTrackedRemoteState_new, &leftTrackedRemoteState_old, &leftRemoteTracking_new,
			&rightTrackedRemoteState_new, &rightTrackedRemoteState_old, &rightRemoteTracking_new,
			xrButton_X, xrButton_Y, xrButton_A, xrButton_B);
		break;
	}
}

// ---- TBXR_* -------------------------------------------------------------
double TBXR_GetTimeInMilliSeconds()
{
	struct timespec now; clock_gettime(CLOCK_MONOTONIC, &now);
	return (now.tv_sec * 1e9 + now.tv_nsec) * 1e-6;
}
int TBXR_GetRefresh() { return 72; }
void TBXR_Recenter() {}
void TBXR_GetScreenRes(int *width, int *height) { *width = g_width; *height = g_height; }
void TBXR_Vibrate(int duration, int channel, float intensity) {}
void TBXR_ProcessHaptics() {}
void TBXR_updateProjections() {}
XrInstance TBXR_GetXrInstance() { return XR_NULL_HANDLE; }

static void TBXR_GetHMDOrientation()
{
	XrPosef head = ParsePose(*qz_hmd);
	gAppState.xfStageFromHead = head;
	vec3_t rotation = {0, 0, 0};
	vec3_t hmdorient = {0, 0, 0};
	QuatToYawPitchRoll(head.orientation, rotation, hmdorient);
	VR_SetHMDPosition(head.position.x, head.position.y, head.position.z);
	VR_SetHMDOrientation(hmdorient[0], hmdorient[1], hmdorient[2]);
}

static long g_frames = 0;	// render frames that read the controllers (qz_state)

bool TBXR_FrameSetup()
{
	if (gAppState.FrameSetupRefCount > 0) return false;
	g_frames++;
	VR_FrameSetup();
	TBXR_GetHMDOrientation();
	VR_HandleControllerInput();
	TBXR_ProcessHaptics();
	gAppState.FrameSetupRefCount++;
	return true;
}

void TBXR_prepareEyeBuffer(int eye)
{
	glBindFramebuffer(GL_FRAMEBUFFER, g_fbo);
	glEnable(GL_SCISSOR_TEST);
	glViewport(0, 0, g_width, g_height);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glScissor(0, 0, g_width, g_height);
	glClear(GL_COLOR_BUFFER_BIT);
	glScissor(0, 0, 0, 0);
	glDisable(GL_SCISSOR_TEST);
}

// TEST ONLY: QZ_DUMP_EVERY=n writes the left eye every n-th frame to $QZ_DUMP_DIR/fNNNNN.ppm
static int g_dumpFrame = 0;
void TBXR_finishEyeBuffer(int eye)
{
	if (eye == 0)
	{
		static int every = getenv("QZ_DUMP_EVERY") ? atoi(getenv("QZ_DUMP_EVERY")) : 0;
		g_dumpFrame++;
		if (every > 0 && g_dumpFrame % every == 0)
		{
			static unsigned char *px = nullptr;
			if (!px) px = (unsigned char *)malloc(g_width * g_height * 4);
			glReadPixels(0, 0, g_width, g_height, GL_RGBA, GL_UNSIGNED_BYTE, px);
			char fn[512];
			snprintf(fn, sizeof fn, "%s/f%05d.ppm", getenv("QZ_DUMP_DIR") ? getenv("QZ_DUMP_DIR") : ".", g_dumpFrame);
			FILE *f = fopen(fn, "wb");
			if (f)
			{
				fprintf(f, "P6\n%d %d\n255\n", g_width, g_height);
				for (int y = g_height - 1; y >= 0; y--)
					for (int x = 0; x < g_width; x++)
						fwrite(px + (y * g_width + x) * 4, 1, 3, f);
				fclose(f);
			}
		}
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void TBXR_submitFrame()
{
	if (gAppState.FrameSetupRefCount == 0) return;
	fov_y = (fabs(g_fov.angleUp) + fabs(g_fov.angleDown)) * 180.0f / M_PI;
	gAppState.FrameSetupRefCount--;
	// TEST ONLY (qz_hz): hold the render loop to at most qz_hz frames a second, as a headset's
	// display rate does; per-frame input (smooth turn) then runs at a Quest's speed. 0 = unpaced.
	if (qz_hz > 0)
	{
		static double next = 0;
		double now = TBXR_GetTimeInMilliSeconds(), period = 1000.0 / qz_hz;
		if (next <= 0 || now - next > 250.0) next = now;	// first frame, or a long stall: re-anchor
		next += period;
		if (next > now) usleep((useconds_t)((next - now) * 1000.0));
	}
}

// ---- TEST-ONLY console commands (rig2, 2026-11-27) ----------------------------
extern int gametic;
extern const char *KeyNames[NUM_KEYS];
int getMenuState();
int getGameState();

static int RigKeyFromName(const char *name)
{
	if (name[0] == '#' && name[1] != 0) return atoi(name + 1);	// #<code>, as the bind command takes
	for (int i = 1; i < NUM_KEYS; i++)
		if (KeyNames[i] && !strcasecmp(KeyNames[i], name)) return i;
	return 0;
}

CCMD(rig_key)
{
	if (argv.argc() < 2)
	{
		Printf("usage: rig_key <keyname> [down|up|tap]  (key names as the bind command takes: Pad_A, Axis4Minus, Escape, K, #37 ...)\n");
		return;
	}
	int k = RigKeyFromName(argv[1]);
	if (k <= 0 || k >= NUM_KEYS)
	{
		Printf("rig_key: unknown key '%s'\n", argv[1]);
		return;
	}
	const char *how = argv.argc() > 2 ? argv[2] : "tap";
	bool down = !strcasecmp(how, "down") || !strcasecmp(how, "tap");
	bool up = !strcasecmp(how, "up") || !strcasecmp(how, "tap");
	if (!down && !up)
	{
		Printf("rig_key: '%s' is not down, up or tap\n", how);
		return;
	}
	event_t ev = {};
	ev.data1 = (int16_t)k;
	if (down) { ev.type = EV_KeyDown; D_PostEvent(&ev); }
	if (up) { ev.type = EV_KeyUp; D_PostEvent(&ev); }
	Printf("RIGKEY t%d %s %s (key %d) menu %d\n", gametic, KeyNames[k] ? KeyNames[k] : "?", down && up ? "tap" : down ? "down" : "up", k, getMenuState());
}

CCMD(qz_state)
{
	Printf("QZSTATE t%d frame %ld menu %d game %d | hmd p %.2f y %.2f r %.2f | snapTurn %.2f doomYaw %.2f | "
		"weapon p %.2f y %.2f r %.2f | offhand p %.2f y %.2f r %.2f | scheme %d snap %.1f aimroll %d hz %d\n",
		gametic, g_frames, getMenuState(), getGameState(), hmdorientation[PITCH], hmdorientation[YAW], hmdorientation[ROLL],
		snapTurn, doomYaw, weaponangles[PITCH], weaponangles[YAW], weaponangles[ROLL],
		offhandangles[PITCH], offhandangles[YAW], offhandangles[ROLL], (int)vr_control_scheme, (float)vr_snapTurn,
		(int)qz_aimroll, (int)qz_hz);
}

// ---- EGL context ----------------------------------------------------------
static void InitEGL()
{
	EGLDisplay dpy = EGL_NO_DISPLAY;
	PFNEGLGETPLATFORMDISPLAYEXTPROC getPlat =
		(PFNEGLGETPLATFORMDISPLAYEXTPROC)eglGetProcAddress("eglGetPlatformDisplayEXT");
	if (!getenv("QZ_EGL_X11") && getPlat) dpy = getPlat(EGL_PLATFORM_SURFACELESS_MESA, EGL_DEFAULT_DISPLAY, NULL);
	if (dpy == EGL_NO_DISPLAY) dpy = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	EGLint maj, min;
	if (dpy == EGL_NO_DISPLAY || !eglInitialize(dpy, &maj, &min)) { fprintf(stderr, "qzlinux: EGL init failed\n"); exit(1); }
	eglBindAPI(EGL_OPENGL_ES_API);
	EGLint cfgattr[] = { EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT, EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
		EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8, EGL_DEPTH_SIZE, 24, EGL_STENCIL_SIZE, 8, EGL_NONE };
	EGLConfig cfg; EGLint n = 0;
	if (!eglChooseConfig(dpy, cfgattr, &cfg, 1, &n) || n == 0)
	{
		EGLint cfg2[] = { EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT, EGL_NONE };
		if (!eglChooseConfig(dpy, cfg2, &cfg, 1, &n) || n == 0) { fprintf(stderr, "qzlinux: no EGL config\n"); exit(1); }
	}
	EGLint ctxattr[] = { EGL_CONTEXT_MAJOR_VERSION, 3, EGL_CONTEXT_MINOR_VERSION, 2, EGL_NONE };
	EGLContext ctx = eglCreateContext(dpy, cfg, EGL_NO_CONTEXT, ctxattr);
	if (ctx == EGL_NO_CONTEXT) { fprintf(stderr, "qzlinux: eglCreateContext failed\n"); exit(1); }
	EGLint pb[] = { EGL_WIDTH, 16, EGL_HEIGHT, 16, EGL_NONE };
	EGLSurface surf = eglCreatePbufferSurface(dpy, cfg, pb);
	if (!eglMakeCurrent(dpy, surf, surf, ctx)) { fprintf(stderr, "qzlinux: eglMakeCurrent failed\n"); exit(1); }

	glGenFramebuffers(1, &g_fbo);
	glGenRenderbuffers(1, &g_color);
	glGenRenderbuffers(1, &g_depth);
	glBindRenderbuffer(GL_RENDERBUFFER, g_color);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, g_width, g_height);
	glBindRenderbuffer(GL_RENDERBUFFER, g_depth);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, g_width, g_height);
	glBindFramebuffer(GL_FRAMEBUFFER, g_fbo);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, g_color);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, g_depth);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	fprintf(stderr, "qzlinux: EGL %d.%d, GL_RENDERER=%s, GL_VERSION=%s\n", maj, min,
		(const char *)glGetString(GL_RENDERER), (const char *)glGetString(GL_VERSION));
}

// ---- fatal error / crash reporting ------------------------------------------
// Linker --wrap of I_ShowFatalError (posix/nosdl/i_system.cpp): non-zero exit code on fatal errors.
static bool g_fatal = false;
extern void __real__Z16I_ShowFatalErrorPKc(const char *message) __asm__("__real__Z16I_ShowFatalErrorPKc");
extern "C" void __wrap__Z16I_ShowFatalErrorPKc(const char *message)
{
	g_fatal = true;
	fprintf(stderr, "qzlinux: FATAL: %s\n", message);
	__real__Z16I_ShowFatalErrorPKc(message);
}

extern FILE *Logfile;
static void qz_crash(int sig)
{
	void *bt[64]; int n = backtrace(bt, 64);
	const char *msg = "\nqzlinux: *** CRASH: signal %d (%s) - engine crashed (on Quest this would exit to home) ***\n";
	fprintf(stderr, msg, sig, strsignal(sig));
	backtrace_symbols_fd(bt, n, 2);
	if (Logfile) { fprintf(Logfile, msg, sig, strsignal(sig)); fflush(Logfile); backtrace_symbols_fd(bt, n, fileno(Logfile)); }
	signal(sig, SIG_DFL); raise(sig);
}

void VR_DoomMain(int argc, char **argv);

int main(int argc, char **argv)
{
	if (getenv("QZ_RES")) { int w = atoi(getenv("QZ_RES")); if (w > 64) g_width = g_height = w; }
	// VR_Init()
	playerYaw = 0.0f; resetDoomYaw = true; resetPreviousPitch = true;
	remote_movementSideways = remote_movementForward = remote_movementUp = 0.0f;
	positional_movementSideways = positional_movementForward = 0.0f;
	snapTurn = 0.0f; cinemamodeYaw = cinemamodePitch = 0.0f;
	srand(time(NULL));
	shutdown = false; ready_teleport = false; trigger_teleport = false; cinemamode = false;

	gAppState.Width = g_width; gAppState.Height = g_height;
	static char hmd[] = "meta";
	gAppState.OpenXRHMD = hmd;
	gAppState.SessionActive = GL_TRUE;

	signal(SIGSEGV, qz_crash); signal(SIGBUS, qz_crash); signal(SIGFPE, qz_crash); signal(SIGILL, qz_crash); signal(SIGABRT, qz_crash);
	InitEGL();
	qzdoom_initialised = true;
	VR_DoomMain(argc, argv);
	return g_fatal ? 2 : 0;
}

// Android OpenAL-soft (OpenSL backend) extension used by oalsound.cpp under __ANDROID__
struct ALCdevice;
extern "C" void OpenSL_android_set_pause(ALCdevice *Device, int pause) {}
