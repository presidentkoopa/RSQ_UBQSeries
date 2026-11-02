// RS_ShieldSawQ -- the three states, the shoulder mount, the loadout swap, and the input.
//
//   STOWED   on the mount: the small of your back, behind your neck or over your off shoulder
//            (ssq_mount_spot), hung on your body, not your head (a world prop, guarding your back)
//   DRAWN    in your off hand: SSQ_ShieldSaw is the off-hand weapon
//   FLYING   thrown. Your previous off-hand weapon is already back, so you are never
//            empty-handed. The disc comes home along the way it went; a hand near it on the
//            way back catches it (DRAWN), otherwise it lands on the mount (STOWED).
//
// THE INPUT (owner, 2026-10-22 04:08), all synced usercmd bits, nothing to bind:
//   off hand AT THE MOUNT by the off shoulder + USE  -> the shield is in the hand (whatever was
//                                                        there steps aside and comes back after)
//   off PRIMARY held                                  -> the saw revs
//   off SECONDARY held                                -> lock-on: rings over what you aim at
//   off SECONDARY released, arm moving               -> throw, at the ringed targets in order
//   off SECONDARY released, arm still                -> nothing; it stays in the hand
//   off SECONDARY pressed while it flies              -> recall
//   USE at the mount again                            -> back on the shoulder
//   hand near the returning disc (Back in Hand on Return) -> caught
// The decision runs here, in WorldTick, from the SYNCED pose (pose.zs). No wait on the grab.

class SSQ_Handler : EventHandler
{
	enum EState { SS_STOWED = 0, SS_DRAWN, SS_FLYING }

	int   mState[MAXPLAYERS];
	SSQ_Pose mPose[MAXPLAYERS];
	Actor mProp[MAXPLAYERS];		// the shield as a world actor: on the back, or in the hand for others
	Actor mMarker[MAXPLAYERS];
	Actor mDisc[MAXPLAYERS];
	class<Weapon> mPrevOff[MAXPLAYERS];	// what the draw displaced (null: nothing, or the pack's hands)
	transient bool mFistNext[MAXPLAYERS];
	transient int a11yFlash;	// the last block star / bloom's tic (Photosensitive Mode, SSQ_FX.FlashOk)	// the next store hands the off hand its fist (ssq_store_to 0)
	class<Weapon> mPrevMain[MAXPLAYERS];	// the main-hand weapon a two-handed conflict lowered
	bool  mGripWas[MAXPLAYERS];		// off secondary last tic
	bool  mUseWas[MAXPLAYERS];
	bool  mStowLatch[MAXPLAYERS];	// holstered with Use: no re-draw until Use is let go
	int   mCatchGrace[MAXPLAYERS];	// tics after a catch before the grip is read again
	int   mDrawGrace[MAXPLAYERS];	// tics after a draw before an empty off hand counts as eviction
	int   mStartDrawn[MAXPLAYERS];	// countdown to the draw at spawn (ssq_start_drawn)
	bool  mInZone[MAXPLAYERS];		// kept for the debug line; the zone-hides-the-gun pass was retired
	// THE LOCK-ON YOU SEE. While the shield is held, a cone from where the off hand points picks
	// the targets every tic; a ring hangs over each, biggest over the first the disc will visit.
	// Let go and this list is what flies, in this order.
	Array<Actor> mLocks[MAXPLAYERS];
	Array<Actor> mLockMarks[MAXPLAYERS];
	Array<int>   mLockMiss[MAXPLAYERS];	// tics each lock has been out of the keep cone or out of sight
	int   mLastPaint[MAXPLAYERS];	// the tic the last target was painted: they go on one at a time
	int   mKeepMarks[MAXPLAYERS];	// let go for less than this long and your marks are still there
	bool  mLockKey[MAXPLAYERS];	// the ShieldSaw Lock key is down (netevent ssq-lock, ssq_lock_input 1)
	bool  mLockWas[MAXPLAYERS];	// the lock input last tic
	bool  mMigrated;
	SSQ_ScoreMemory score;		// what a scorer may ask about blocks and turned shots (score.zs)
	int   mLockSig[MAXPLAYERS];
	// SABER OVER SHIELD (pick 15): the stance, as the player's own machine last said (netevent ssq-brace)
	bool  mBraced[MAXPLAYERS];
	transient int mBraceSent;	// this machine's last sent value + 1 (0 = nothing sent yet)
	// THE BODY THE MOUNT HANGS ON (owner's headset, 11-02: "attached to helmet and not body"): the body's yaw,
	// synced from each player's own machine (netevent ssq-body, BodyKeep). Until one arrives (or off VR): the
	// pawn's angle, as before.
	double mBodyYaw[MAXPLAYERS];
	bool   mBodyHave[MAXPLAYERS];
	// ...and its height: the player's standing eyes (metres above the room floor, vr_height_adjust included), while
	// the sender has vr_crouch_use_button on (the default; off, viewz already follows the eyes)
	double mBodyEye[MAXPLAYERS];
	bool   mBodyEyeOk[MAXPLAYERS];
	// ...and the keeper on this machine, for its own console player only (re-primed from mBodyYaw on load)
	transient double kYaw, kLastA, kLastH0, kLastH1, kLastC0, kLastC1, kPend, kSentYaw, kEye, kSentEye;
	transient int kOffFor, kEyeLow, kSentEyeOk;
	transient bool kSwinging, kPrimed, kSent;
	transient Actor kMo;
	// WALL SLAM (pick 12): bodies a bash threw, watched for the wall that stops them
	Array<Actor>  mSlamWho;
	Array<int>    mSlamBy, mSlamUntil;
	Array<double> mSlamVX, mSlamVY;


	// ---- lookups -------------------------------------------------------------------
	static clearscope SSQ_Handler Get() { return SSQ_Handler(EventHandler.Find('SSQ_Handler')); }

	static clearscope double SV(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}
	static clearscope int SVI(Name n, int def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetInt() : def;
	}
	static clearscope double UV(PlayerInfo p, Name n, double def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetFloat() : def;
	}
	static clearscope int UVI(PlayerInfo p, Name n, int def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetInt() : def;
	}
	// cm -> map units
	static clearscope double CM(double cm) { return cm * SSQ_Hand.VU() / 100.0; }

	clearscope int StateOf(int pnum) { return mState[pnum]; }
	clearscope SSQ_Pose PoseOf(int pnum) { return mPose[pnum]; }

	// LEFT-HANDED IS THE ENGINE'S SETTING, not ours: vr_control_scheme >= 10 (gl_openxrdevice.cpp:639).
	// It is a local cvar, so it travels in the pose event (arg3 bit 0) and every machine reads it
	// from the sender's pose; before any pose has arrived the local cvar stands in.
	static clearscope bool LocalLeftHanded()
	{
		let cv = CVar.FindCVar('vr_control_scheme');
		return cv && cv.GetInt() >= 10;
	}
	static clearscope bool LeftHanded(PlayerInfo p)
	{
		let h = Get();
		if (h && p && p.mo)
		{
			int n = p.mo.PlayerNumber();
			if (n >= 0 && n < MAXPLAYERS && h.mPose[n].count > 0) return h.mPose[n].left;
		}
		return LocalLeftHanded();
	}

	// ---- the mount, hung on the BODY, not the head -----------------------------------------
	// THE HEAD IS NOT THE BODY (owner's headset, 2026-11-02: "the saw seems to be attached to helmet and not body ...
	// when I turn my head, the shield moves when stored"). The mount was placed off mo.angle, which in VR is the
	// headset's yaw, from mo.pos, which QuestZDoom moves with the headset: so every look sideways swung a point
	// 0.25-0.30 m behind you through an arc, out of the hand that was reaching for it, and the eyes orbiting the neck
	// slid it a few cm more. Now:
	//   YAW   the body's (BodyKeep below: the RSQ TacticalRig body.zs rule, copied so this mod works alone): a snap
	//         or smooth turn shows as both controllers' yaws moving with the pawn's angle in the same tic and turns
	//         the body; a head turn moves the angle alone and leaves it; a head held more than 35 degrees round for
	//         1 s is taken as the body turning in the room and the body eases round (at most 3 degrees a tic).
	//   PLACE the neck, not the eyes: the eyes sit ssq_neck_pivot (9 cm, an anatomical estimate, not measured) in
	//         front of the neck the head turns on, so the point under the eyes is taken back along the HEAD's yaw to
	//         the neck and out again along the BODY's: a head turn about the neck leaves it where it was.
	//   UP    your standing eyes (EyeZ below), not the pawn's fixed 1.45 m eye (viewz) the hands are not measured from.
	// Every offset below is from that point: your eyes as they are when you look straight ahead.
	// Off VR the body is the pawn and nothing changed.
	const BODY_TOL = 1.5;     // degrees: both controllers moved with the pawn = a turn of the tracking space (rig: TOL)
	const BODY_SWING = 3.0;   // most degrees a tic the body eases round while it catches up (rig: SWING)
	const BODY_STEEP = 78.0;  // head pitch past which the head's yaw is not trusted (rig: STEEP)
	const BODY_TURN = 35.0;   // degrees the head must be held round ... (rig: rsqtr_body_turn default)
	const BODY_TICS = 35;     // ... for this long before it counts as the body turning (rig: rsqtr_body_secs 1 s)

	static clearscope double BodyYaw(PlayerPawn mo)
	{
		let h = Get();
		int n = mo.PlayerNumber();
		if (h && n >= 0 && n < MAXPLAYERS && h.mBodyHave[n]) return h.mBodyYaw[n];
		return mo.angle;
	}
	// the point the body frame hangs from: your eyes, as they are when you look straight ahead
	static clearscope Vector3 BodyEyes(PlayerPawn mo)
	{
		let p = mo.player;
		double piv = CM(UV(p, 'ssq_neck_pivot', 9.0));
		double ha = mo.angle, by = BodyYaw(mo);
		return (mo.pos.x + (cos(by) - cos(ha)) * piv, mo.pos.y + (sin(by) - sin(ha)) * piv, EyeZ(mo));
	}
	// THE HEIGHT OF YOUR EYES, where the hands are measured from. The engine puts the hands at
	//   viewz - DefaultViewHeight + (controller height + vr_height_adjust) * vr_vunits_per_meter / pixelstretch
	// (hw_openxrdevice.cpp:595, stock QZD 17.3), but with vr_crouch_use_button on (the default) viewz itself is the
	// pawn's fixed 41-unit eye, 1.45 m, whatever your height: so a mount hung from viewz sat (your eye height - 1.45 m)
	// too LOW against your hands, about 0.15-0.25 m for a standing adult. Now it hangs from your standing eyes, kept as
	// RSQ TacticalRig keeps your seated eyes (body.zs UpdateSeat): the highest the headset has been lately, easing down
	// 2 cm a second, rising at once, and taken straight to the headset once it has stayed 0.20 m lower for a second
	// (you sat or crouched down). So bending to reach behind you does not pull the mount down with your head, and
	// sitting (RSQ_Accessibility's Seated Play or not) brings it down with you. Before the first body event, or with
	// the crouch button off (viewz then follows your eyes already): viewz, less the seat drop, as before.
	static clearscope double EyeZ(PlayerPawn mo)
	{
		let p = mo.player;
		let h = Get();
		int n = mo.PlayerNumber();
		if (h && n >= 0 && n < MAXPLAYERS && h.mBodyEyeOk[n])
			return p.viewz - mo.ViewHeight + h.mBodyEye[n] * SSQ_Hand.VU() / SSQ_Hand.PS(mo);
		return p.viewz - SeatUnits(mo);
	}
	// a point f forward, l to the LEFT, u up from BodyEyes, all in MAP UNITS, in the body's frame
	static clearscope Vector3 BodyAt(PlayerPawn mo, double f, double l, double u)
	{
		double by = BodyYaw(mo);
		return BodyEyes(mo) + (cos(by) * f - sin(by) * l, sin(by) * f + cos(by) * l, u);
	}
	// a world point in the body's frame, in ROOM METRES: x forward, y toward the OFF side, z up
	static clearscope Vector3 BodyLocal(PlayerPawn mo, Vector3 at)
	{
		Vector3 d = at - BodyEyes(mo);
		double by = BodyYaw(mo), vu = SSQ_Hand.VU();
		double f = (d.x * cos(by) + d.y * sin(by)) / vu;
		double l = (-d.x * sin(by) + d.y * cos(by)) / vu;
		return (f, LeftHanded(mo.player) ? -l : l, d.z * SSQ_Hand.PS(mo) / vu);
	}

	// THE BODY KEEPER: this machine's console player only (the controller yaws are written for the camera player
	// alone), sent to every machine as netevent ssq-body so every sim hangs the mount in the same place.
	void BodyKeep()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || !SSQ_Hand.InVR(mo)) return;
		double a = mo.angle, h0 = mo.AttackAngle, h1 = mo.OffhandAngle;
		// the standing eyes (EyeZ): the headset's height plus vr_height_adjust, metres above the room floor
		let cb = CVar.FindCVar('vr_crouch_use_button');
		let ha = CVar.FindCVar('vr_height_adjust');
		double hy = mo.HmdPosition.y;
		bool eyeOk = (!cb || cb.GetBool()) && hy > 0.3;	// no headset height read: viewz, as before
		double eh = hy + (ha ? ha.GetFloat() : 0.0);
		if (!eyeOk) { kEye = 0; kEyeLow = 0; }
		else
		{
			kEyeLow = eh < kEye - 0.20 ? kEyeLow + 1 : 0;
			if (kEye <= 0 || eh > kEye || kEyeLow > TICRATE) { kEye = eh; kEyeLow = 0; }
			else kEye = max(eh, kEye - 0.02 / TICRATE);
		}
		if (!kPrimed || kMo != mo)
		{
			// a loaded save keeps the body it had; a new pawn (respawn) starts facing where it faces
			kYaw = (!kPrimed && mBodyHave[consoleplayer]) ? mBodyYaw[consoleplayer] : a;
			kLastA = a; kLastH0 = h0; kLastH1 = h1; kLastC0 = h0; kLastC1 = h1;
			kPrimed = true; kMo = mo; kOffFor = 0; kSwinging = false; kPend = 0;
			kSent = false;
		}
		else
		{
			double dA = Actor.DeltaAngle(kLastA, a);
			double d0 = Actor.DeltaAngle(kLastH0, h0), d1 = Actor.DeltaAngle(kLastH1, h1);
			// THE CONTROLLER YAWS ARE A TIC LATE. The engine writes them from doomYaw - playerYaw
			// (hw_openxrdevice.cpp:589/603), and doomYaw is resampled from the camera a tic after the pawn's angle
			// moves: measured on the rig, a 45-degree snap moved the angle at t45 and both controllers at t46, and
			// a head turn of 4 degrees a tic read as the controllers turning -4 a tic while it lasted. So each
			// controller's yaw plus the angle's own change this tic is its true yaw (c0, c1): a snap then shows in
			// the same tic as the angle, and a head turn not at all. (The plain same-tic reading was tried beside
			// it and read the end of every fast head turn as a turn: the late controllers catch up by exactly the
			// head's last step.)
			double c0 = h0 + dA, c1 = h1 + dA;
			double e0 = Actor.DeltaAngle(kLastC0, c0), e1 = Actor.DeltaAngle(kLastC1, c1);
			kLastA = a; kLastC0 = c0; kLastC1 = c1;
			kLastH0 = h0; kLastH1 = h1;
			// the tracking space turned (snap, smooth, a teleport's facing): both controllers moved WITH the head,
			// by much the same (not the rig's plain |d - dA| < 1.5, which took any head turn slower than 1.5
			// degrees a tic, controllers still, for a turn of the body) ...
			// ... AND CONFIRMED A TIC LATER: the late raw yaws must then show that same step. In a tic the renderer
			// skipped (no new frame: measured on the rig rendering under 35 fps) the controller yaws are stale and
			// the correction above reads the previous head step as a turn; the next tic's raw yaws do not repeat it,
			// so it is dropped. A turn is applied one tic late.
			if (kPend != 0)
			{
				double pt = min(BODY_TOL, abs(kPend) * 0.5);
				bool ok = abs(d0 - kPend) < pt && abs(d1 - kPend) < pt;
				if (ok) kYaw += kPend;
				if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: body %s %.1f with the tracking space (controllers then %.1f %.1f)", ok ? "turns" : "holds, not", kPend, d0, d1);
				kPend = 0;
			}
			double tol = min(BODY_TOL, abs(dA) * 0.5);
			if (abs(dA) > 0.3 && abs(e0 - dA) < tol && abs(e1 - dA) < tol) kPend = dA;
			// looking steeply down at yourself is not turning: the headset's yaw swings wildly there. And A HAND
			// REACHING FOR THE MOUNT HOLDS THE BODY STILL (ShieldSaw's own addition to the rig's rule): you often
			// look round toward the side you reach behind, for longer than a second, and the catch-up must not
			// swing the mount out from under the hand
			if (abs(mo.pitch) > BODY_STEEP || (mState[consoleplayer] != SS_FLYING && ZoneFrac(mo, mo.OffhandPos) <= ZoneK()))
			{
				kOffFor = 0; kSwinging = false;
			}
			else
			{
				double off = Actor.DeltaAngle(kYaw, a);
				if (abs(off) > BODY_TURN) kOffFor++;
				else if (!kSwinging) kOffFor = 0;
				if (kOffFor > BODY_TICS) kSwinging = true;
				if (kSwinging)
				{
					kYaw += clamp(off * 0.08, -BODY_SWING, BODY_SWING);
					if (abs(off) < 4) { kSwinging = false; kOffFor = 0; }
				}
			}
			kYaw = Actor.Normalize180(kYaw);
		}
		int eyeState = eyeOk ? 1 : 0;
		if (kSent && abs(Actor.DeltaAngle(kSentYaw, kYaw)) < 0.25 && eyeState == kSentEyeOk && abs(kEye - kSentEye) < 0.01) return;
		kSent = true;
		kSentYaw = kYaw; kSentEye = kEye; kSentEyeOk = eyeState;
		// args: the body's yaw in hundredths of a degree; the standing eyes in mm (0 = none: viewz)
		EventHandler.SendNetworkEvent("ssq-body", int(round((kYaw % 360.0 + 360.0) % 360.0 * 100.0)), eyeOk ? clamp(int(round(kEye * 1000.0)), 1, 4000) : 0);
	}

	// ---- where you take it from (ssq_mount_spot, the "Take It From" row) -------------------------------------
	//   0 OVER THE OFF SHOULDER: the old mount (the default until 2026-10-31), as it was, only turned with the body: 27 cm
	//     behind and 12 cm to the off side of your eyes, 30 cm below the pawn's eye (viewz), a 30 cm sphere (cm as map
	//     units, as it always was: 0.27 / 0.12 / 0.36 / 0.30 room metres).
	//     RSQ TacticalRig leaves its off-shoulder holster to it (its hooks.zs ShieldOnShoulder: ssq_mount_spot 0).
	//   1 THE SMALL OF YOUR BACK (default): a sphere centred 0.30 m behind your eyes, 0.10 m to the off side, 0.62 m
	//     below them (belt height), radius 0.30 m, and only BEHIND THE HIP LINE: a hand less than 0.14 m behind your
	//     eyes never takes it (the rig's hip holsters reach 0.14 m back at most).
	//   2 BEHIND YOUR NECK: centred 0.22 m behind, 0.08 m to the off side, 0.18 m below your eyes, radius 0.26 m, and
	//     only 0.06 m or more behind your eyes, so a reach over the off shoulder from the front lands in it.
	//   3 either of 1 and 2.
	// Room metres, body frame (BodyLocal). With RSQ TacticalRig loaded and its Use draw on, a hand inside one of the
	// rig's holsters (its own places and sizes, read by name) is the rig's press, never the shield's.
	const BACK_LINE = -0.14;   // m: in front of this, no back grab
	const NECK_LINE = -0.06;   // m: in front of this, no neck grab
	static clearscope int Spot(PlayerInfo p) { return clamp(UVI(p, 'ssq_mount_spot', 1), 0, 3); }
	static clearscope bool OnBack(PlayerInfo p) { int s = Spot(p); return s == 1 || s == 3; }   // the handle low

	// the centre of a back spot in the body frame (metres; y toward the off side)
	static clearscope Vector3 SpotCentre(PlayerInfo p, bool neck)
	{
		if (neck) return (UV(p, 'ssq_neck_fwd', -22.0), UV(p, 'ssq_neck_side', 8.0), UV(p, 'ssq_neck_up', -18.0)) / 100.0;
		return (UV(p, 'ssq_back_fwd', -30.0), UV(p, 'ssq_back_side', 10.0), UV(p, 'ssq_back_up', -62.0)) / 100.0;
	}
	static clearscope double SpotRadius(PlayerInfo p, bool neck)
	{
		return max(0.02, (neck ? UV(p, 'ssq_neck_reach', 26.0) : UV(p, 'ssq_back_reach', 30.0)) / 100.0);
	}
	// a back spot as a world point (the marker, and the shield when it is drawn on your back)
	static clearscope Vector3 SpotPos(PlayerPawn mo, bool neck)
	{
		let p = mo.player;
		Vector3 c = SpotCentre(p, neck);
		double vu = SSQ_Hand.VU();
		return BodyAt(mo, c.x * vu, c.y * vu * (LeftHanded(p) ? -1 : 1), c.z * vu / SSQ_Hand.PS(mo));
	}
	static clearscope Vector3 NeckPos(PlayerPawn mo) { return SpotPos(mo, true); }

	// HOW FAR INTO THE GRAB the hand is: <= 1 takes a Use press; up to ZoneK() the marker brightens and the pose is
	// sent. With both back spots, the nearer.
	static clearscope double ZoneFrac(PlayerPawn mo, Vector3 hand)
	{
		let p = mo.player;
		int s = Spot(p);
		if (s == 0) return (hand - MountPos(mo)).Length() / max(0.01, CM(UV(p, 'ssq_mount_reach', 30.0)));
		Vector3 b = BodyLocal(mo, hand);
		double best = 1e9;
		if (s != 2) best = min(best, SpotFrac(mo, b, hand, false));
		if (s != 1) best = min(best, SpotFrac(mo, b, hand, true));
		return best;
	}
	static clearscope double SpotFrac(PlayerPawn mo, Vector3 b, Vector3 hand, bool neck)
	{
		let p = mo.player;
		double r = SpotRadius(p, neck);
		double d = (b - SpotCentre(p, neck)).Length() / r;
		double line = neck ? NECK_LINE : BACK_LINE;
		if (b.x > line) d = max(d, 1.0 + (b.x - line) / r);	// in front of the line: never a grab
		if (d <= 1.0 && InRigHolster(mo, hand)) d = 1.01;	// inside a rig holster: its press, not ours
		return d;
	}
	static clearscope bool InMount(PlayerPawn mo, Vector3 hand) { return ZoneFrac(mo, hand) <= 1.0; }
	// the near zone, as a multiple of the grab; RSQ_Accessibility's Gesture Ease widens it x1..x2
	static clearscope double ZoneK() { return SSQ_A11y.Wide(SV('ssq_zone_scale', 1.6)); }

	// RSQ TACTICAL RIG'S HOLSTERS, by name only (no rig: none). Its places 0 1 3 4 5 6 7 9 10 (hips, grenades,
	// shoulders, chest, saber spots; 2 is retired and the keyring is no Use holster), from its own cvars with its own
	// defaults (TacticalRig CVARINFO), scaled by its eye-height scale and reach as its rig.zs Settings() does, in ITS
	// frame: standing it hangs from the pawn's place at viewz (body.zs Head), seated from your seated eyes (taken here
	// as viewz less the seat drop), turned by its own body yaw (the same rule as ours, so taken as ours).
	static clearscope bool InRigHolster(PlayerPawn mo, Vector3 hand)
	{
		Name rn = 'RSQTR_Rig'; class<Object> rc = rn;
		if (!rc) return false;
		let p = mo.player;
		let use = CVar.GetCVar('rsqtr_use', p);
		if (!use || !use.GetBool()) return false;
		static const int RS[] = { 0, 1, 3, 4, 5, 6, 7, 9, 10 };
		static const double DF[] = { 0.00, 0.00, 0.12, -0.08, -0.08, 0.10, 0.10, 0.02, 0.02 };
		static const double DL[] = { 0.18, -0.18, 0.00, 0.18, -0.18, 0.12, -0.12, 0.21, -0.21 };
		static const double DU[] = { -0.70, -0.70, -0.62, -0.10, -0.10, -0.46, -0.46, -0.84, -0.84 };
		static const double DR[] = { 0.14, 0.14, 0.08, 0.14, 0.14, 0.11, 0.11, 0.10, 0.10 };
		let ec = CVar.GetCVar('rsqtr_eye_m', p);
		double eye = ec ? ec.GetFloat() : 0;
		double k = eye > 0.8 ? clamp(eye / 1.62, 0.7, 1.3) : 1.0;
		let rr = CVar.GetCVar('rsqtr_reach', p);
		double reach = (rr ? rr.GetFloat() : 1.0) * k;
		double by = BodyYaw(mo), vu = SSQ_Hand.VU();
		Vector3 d0 = hand - (mo.pos.x, mo.pos.y, p.viewz - SeatUnits(mo));
		Vector3 b = ((d0.x * cos(by) + d0.y * sin(by)) / vu, (-d0.x * sin(by) + d0.y * cos(by)) / vu, d0.z * SSQ_Hand.PS(mo) / vu);
		double left = b.y;	// the rig's places are left / right, not off / main
		for (int j = 0; j < 9; j++)
		{
			int r = RS[j];
			let cf = CVar.GetCVar(String.Format("rsqtr_r%d_f", r), p);
			let cl = CVar.GetCVar(String.Format("rsqtr_r%d_l", r), p);
			let cu = CVar.GetCVar(String.Format("rsqtr_r%d_u", r), p);
			let cr = CVar.GetCVar(String.Format("rsqtr_r%d_rad", r), p);
			Vector3 c = (cf ? cf.GetFloat() : DF[j], cl ? cl.GetFloat() : DL[j], cu ? cu.GetFloat() : DU[j]) * k;
			double rad = (cr ? cr.GetFloat() : DR[j]) * reach;
			if ((b.x - c.x, left - c.y, b.z - c.z).Length() <= rad) return true;
		}
		return false;
	}

	static clearscope Vector3 MountPos(PlayerPawn mo)
	{
		let p = mo.player;
		int s = Spot(p);
		if (s == 2) return SpotPos(mo, true);
		if (s != 0) return SpotPos(mo, false);
		// over the off shoulder: the old numbers in the old units (cm as map units) and at the old height (from viewz,
		// where the owner used it until 10-31), now turned with the body, not the head
		Vector3 at = BodyAt(mo, CM(UV(p, 'ssq_mount_fwd', -27.0)), CM(UV(p, 'ssq_mount_side', 12.0)) * (LeftHanded(p) ? -1 : 1), 0);
		return (at.x, at.y, p.viewz - SeatUnits(mo) + CM(UV(p, 'ssq_mount_up', -30.0)));
	}

	// SEATED PLAY (RSQ_Accessibility AC3, a11y.zs; the way RSQ TacticalRig's body.zs hangs its holsters from your seated
	// eyes). The mount hangs from the pawn's eye (viewz), which stays at standing height while you sit (vr_crouch_use_button
	// on, the default) though your shoulders and back drop with your eyes. So seated, it comes down by how far your eyes
	// are below standing. The drop travels in the synced pose (SendPose, "ssq-pose" Args[2]) so every machine agrees; the
	// sender sends 0 standing, with the crouch button off (viewz then follows your head already) or without Accessibility.
	static clearscope double SeatUnits(PlayerPawn mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player) return 0;
		int n = mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS || !h.mPose[n] || h.mPose[n].seatCm <= 0) return 0;
		return h.mPose[n].seatCm / 100.0 * SSQ_Hand.VU() / SSQ_Hand.PS(mo);
	}
	// this machine's own drop, for the pose it sends (centimetres, 0..255)
	static int LocalSeatCm(PlayerPawn mo)
	{
		let cb = CVar.FindCVar('vr_crouch_use_button');
		if (cb && !cb.GetBool()) return 0;
		return clamp(int(SSQ_A11y.SeatDrop(mo) * 100.0 + 0.5), 0, 255);
	}

	// THE HOLSTERED POSE, DERIVED FROM THE MESH, not from hand-set offsets.
	//
	// MountPos is the grab point: where the hand is when it reaches over the shoulder.
	// Holstered, the shield hangs there in the one orientation that is both grabbable and
	// guards the back: its forearm axis F points UP (the handle is at the top, where your
	// hand closes on it) and its +L side -- the side your arm is on -- faces FORWARD into
	// your back, so the face normal -L looks behind you. U = F x L is then the player's
	// left. The disc falls ssq_plate_f (15.4 cm, measured) below the grab point on its own,
	// which is what ssq_mount_drop used to guess at.
	//
	// The world prop (SSQ_Prop) is one MODELDEF block with no mirror, so this frame uses
	// the unmirrored lateral sign for both handednesses: 5 cm of ssq_plate_u is all that
	// differs between them, on a 58 cm disc.
	static clearscope Vector3 MountPlateCentre(PlayerPawn mo)
	{
		double a = BodyYaw(mo);	// the body's facing, not the head's
		// on the back the handle is LOW and the disc hangs above it: the forearm axis points down
		Vector3 Fh = OnBack(mo.player) ? (0, 0, -1) : (0, 0, 1);
		Vector3 Lh = (cos(a), sin(a), 0);			// forward
		Vector3 Uh = Fh cross Lh;					// the player's left (shoulder) or right (back)
		double k = SSQ_Guard.Scale();
		return MountPos(mo)
			+ Fh * (CM(SV('ssq_plate_f', -15.4)) * k)
			+ Lh * (CM(SV('ssq_plate_l', -7.5)) * k)
			+ Uh * (CM(SV('ssq_plate_u', -5.0)) * k);
	}

	static clearscope Vector3 MountPlateNormal(PlayerPawn mo)
	{
		double a = BodyYaw(mo);
		return (-cos(a), -sin(a), 0);	// -Lh: behind you
	}

	// the prop's own angles for that frame. models.cpp RenderModel composes
	// rotate(-angle,Y) . rotate(-pitch,Z) . rotate(-roll,X) on a vertex swizzled to
	// (mx, mz, my), so model +x is the actor's forward and model +y its left: pitch -90
	// stands the handle up, and roll 180 turns the mesh's +y (its +L side) forward.
	static clearscope double MountPropPitch() { return -90.0; }
	static clearscope double MountPropRoll() { return 180.0; }

	// THE LOCK/THROW TRIGGER, and why it is not just the alt button any more.
	//
	// Lock-on and the throw both hung on BT_OFFHANDALTATTACK alone. On a Quest that action is
	// `alt +oh_altatk` in the stock bind set (engine/vr/defbind3.txt) -- a GRIP-SHIFTED trigger:
	// you must hold the off grip to reach it, and holding that same grip is what arms QZD's
	// two-hand grab. So the one button the shield needed most was the one button the player
	// could not press cleanly, and from the outside the shield simply never locked and never
	// threw. The owner's own lightsaber reads BT_OFFHANDATTACK -- the plain off-hand trigger --
	// and that is why its lock-on and throw work.
	//
	// So: either button, by default. Holding the off trigger revs the saw AND paints locks;
	// letting go with the arm moving throws, which is also how the saber does it and makes a
	// revved throw the natural one. ssq_lock_button 0 keeps the old alt-only behaviour, 2 is
	// the trigger alone.
	// ---- LIVING WITH OTHER OFF-HAND MODS ------------------------------------------------
	//
	// Two mods we load beside are built to never leave the off hand empty: the weapon pack's
	// RSQ_Hands re-gives itself whenever the slot is null, and RSQ_Saber's bridge
	// gives UBQS_SaberOff to an empty off hand every tic when dual is on. Both are right to
	// do it and neither knows about us. The consequence is that an off-hand slot we leave
	// null for even one tic gets filled by somebody, and whatever we do next fights them.
	//
	// So: a weapon that appears in the off hand BY ITSELF is not the player taking the hand
	// away from us. This names those -- by class name, at run time, so neither mod has to be
	// present and nothing links against them.
	static clearscope bool IsFiller(Weapon w)
	{
		if (!w) return false;
		String n = w.GetClassName();
		return n.IndexOf('Hands') >= 0 || n.IndexOf('UBQS_') == 0;
	}

	// the off-hand weapon another mod would hand back when we let go, if there is one
	// The off hand's fist: the pack's empty hands (Brutal Doom Quest's RSQ_Hands), found by name.
	static clearscope Weapon FistBack(PlayerPawn mo)
	{
		Name hn = 'RSQ_Hands';
		return Weapon(mo.FindInventory(hn));
	}

	static clearscope Weapon HandBack(PlayerPawn mo)
	{
		static const Name fillers[] = { 'UBQS_SaberOff', 'RSQ_Hands' };
		for (int k = 0; k < 2; k++)
		{
			let w = Weapon(mo.FindInventory(fillers[k]));
			if (w) return w;
		}
		return null;
	}

	static clearscope bool SecHeld(PlayerInfo p)
	{
		int b = p.cmd.buttons;
		int mode = SVI('ssq_lock_button', 2);
		if (mode == 0) return (b & BT_OFFHANDALTATTACK) != 0;
		if (mode == 2) return (b & BT_OFFHANDATTACK) != 0;
		return (b & (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK)) != 0;
	}

	// Server settings still at the OLD defaults move to the new ones (a saved cvar outlives a
	// changed default): locks dropped 0.4 s out of view (14 tics) and the rings 1 s after letting
	// go (35); either off button threw. Now 3 s, 5 s, and the trigger.
	void MigrateLocks()
	{
		let g = CVar.FindCVar('ssq_lock_grace');
		if (g && g.GetInt() == 14) g.SetInt(105);
		let k = CVar.FindCVar('ssq_keep_marks');
		if (k && k.GetInt() == 35) k.SetInt(175);
		let b = CVar.FindCVar('ssq_lock_button');
		if (b && b.GetInt() == 1) b.SetInt(2);
	}

	// THE LOCK INPUT, ITS OWN BUTTON (the owner, 10-27: "hold trigger to rev AND lock on? ... the
	// lock on fades off after a few tics so I still can't hit shit"). Holding the trigger used to
	// rev, paint and throw at once. Now the trigger revs (and throws on release), and locking is
	// a separate hold, picked per player in ssq_lock_input:
	//   0  Use, held away from the shoulder mount (no binding needed)        <- default
	//   1  the "ShieldSaw: lock on (hold)" key -- bind the off grip or any key to it
	//   2  the old way: the throw button paints too
	bool LockHeld(int i)
	{
		let p = players[i];
		int mode = UVI(p, 'ssq_lock_input', 0);
		if (mode == 1) return mLockKey[i];
		if (mode == 2) return SecHeld(p);
		if ((p.cmd.buttons & BT_USE) == 0) return false;
		// Use at the mount is the draw / holster, not a lock
		let pose = mPose[i];
		if (!pose.Fresh(Level.maptime)) return true;
		return !InMount(p.mo, pose.pos[0]);
	}

	// ---- lifecycle ----------------------------------------------------------------
	override void OnRegister()
	{
		for (int i = 0; i < MAXPLAYERS; i++) mPose[i] = new('SSQ_Pose');
		Migrate();
	}

	// SETTINGS GENERATIONS, each once (ssq_cfgver; FindCVar, the values the config saves).
	// 1 (2026-10-31, owner: "tighten up the block to plate size"): the guard margin, the slab's depth and the early
	// turn come down to the plate itself, from whatever an older config saved.
	static void Migrate()
	{
		let ver = CVar.FindCVar('ssq_cfgver');
		if (!ver || ver.GetInt() >= 3) return;
		int from = ver.GetInt();
		if (from < 2)
		{
			// 2 (2026-10-31, owner: "it sends the projectile directly back to the attacker"): turned shots glance off the
			// plate and follow your swing, unless an older config chose something other than the old default
			let am = CVar.FindCVar('ssq_deflect_aim'); if (am && am.GetInt() == 1) am.SetInt(3);
			if (from < 1)
			{
				let pad = CVar.FindCVar('ssq_sweep_pad'); if (pad) pad.SetFloat(0.0);
				let th = CVar.FindCVar('ssq_plate_thick'); if (th) th.SetFloat(4.0);
				let ld = CVar.FindCVar('ssq_sweep_lead'); if (ld) ld.SetFloat(1.0);
			}
		}
		// 3 (2026-11-02, owner: "cannot reach small of back or neck"): the back spots are room centimetres on the body
		// now, with far larger grabs; whatever an older config saved under the old meaning goes back to the new defaults
		static const Name spots[] = { 'ssq_back_fwd', 'ssq_back_up', 'ssq_back_reach', 'ssq_neck_fwd', 'ssq_neck_up', 'ssq_neck_reach' };
		for (int k = 0; k < 6; k++) { let cv = CVar.FindCVar(spots[k]); if (cv) cv.ResetToDefault(); }
		ver.SetInt(3);
	}

	override void PlayerEntered(PlayerEvent e) { Give(e.PlayerNumber); }
	override void PlayerRespawned(PlayerEvent e) { Give(e.PlayerNumber); }

	void Give(int pnum)
	{
		if (pnum < 0 || pnum >= MAXPLAYERS || !playeringame[pnum]) return;
		let p = players[pnum];
		let mo = p.mo;
		if (!mo) return;
		mState[pnum] = SS_STOWED;
		mPrevOff[pnum] = null; mPrevMain[pnum] = null;
		if (!mo.FindInventory('SSQ_Guard')) mo.GiveInventory('SSQ_Guard', 1);
		if (SVI('ssq_start', 1) == 0) return;
		if (!mo.FindInventory('SSQ_ShieldSaw'))
		{
			mo.GiveInventory('SSQ_ShieldSaw', 1);
			// the give sets PendingWeapon unless the weapon carries NO_AUTO_SWITCH; make sure
			let saw = Weapon(mo.FindInventory('SSQ_ShieldSaw'));
			if (saw && p.PendingWeapon == saw) p.PendingWeapon = WP_NOCHANGE;
			WeaponSlots.SetupWeaponSlots(mo);
		}
		mStartDrawn[pnum] = UVI(p, 'ssq_start_drawn', 0) != 0 ? 3 : 0;
	}

	// THE MISSILES IN FLIGHT, for the sweep. A projectile is +NOBLOCKMAP (the PROJECTILE combo), so a
	// BlockThingsIterator never returns one -- measured on QZD 17.3: an imp ball crossing the plate
	// was absent from the iterator around it, and the sweep (SSQ_Guard.DoEffect) had never turned a
	// single shot; only the block on contact ever did. So every missile is noted as it spawns and the
	// sweep walks this list instead (pruned each tic; a few dozen entries in a firefight).
	Array<Actor> mMissiles;
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (a && a.bMissile && !(a is 'SSQ_Disc')) mMissiles.Push(a);
	}
	void PruneMissiles()
	{
		for (int k = mMissiles.Size() - 1; k >= 0; k--)
		{
			let a = mMissiles[k];
			if (!a || !a.bMissile) mMissiles.Delete(k);
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		mMissiles.Clear();
		for (int i = 0; i < MAXPLAYERS; i++) { mProp[i] = null; mMarker[i] = null; mDisc[i] = null; }
	}

	// ---- the sim, once a tic, every machine ------------------------------------------
	override void WorldTick()
	{
		if (!mMigrated) { mMigrated = true; MigrateLocks(); }
		if (!score) score = new('SSQ_ScoreMemory');
		PruneMissiles();
		BodyKeep();
		SendPose();
		SendBrace();
		SlamTick();
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let p = players[i];
			let mo = p.mo;
			if (p.playerstate != PST_LIVE || mo.health <= 0)
			{
				if (mState[i] == SS_DRAWN) Stow(i, false);
				continue;
			}
			let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
			if (!saw) { HideProps(i); continue; }
			if (mState[i] != SS_DRAWN) mBraced[i] = false;

			// nothing but Draw() puts the shield in the hand: undo the engine filling an empty
			// off hand with it, or a level change re-raising it
			if (mState[i] != SS_DRAWN && p.OffhandWeapon == saw) Unstow(i);
			if (mState[i] == SS_DRAWN) { if (SVI('ssq_yield_offhand', 0) != 0) HoldOrYield(i, saw); else PinHands(i, saw); }
			if (mState[i] == SS_FLYING && !mDisc[i]) { mState[i] = SS_STOWED; }
			if (mStartDrawn[i] > 0 && mState[i] == SS_STOWED && --mStartDrawn[i] == 0) Draw(i);

			// USE: grab in the zone / holster in the zone. Level, not edge, for the grab: a use
			// already held when the hand reaches the zone grabs too.
			bool use = (p.cmd.buttons & BT_USE) != 0;
			bool usePress = use && !mUseWas[i];
			mUseWas[i] = use;
			if (mCatchGrace[i] > 0) { mCatchGrace[i]--; usePress = false; use = false; }
			// A HOLSTER ON THE PRESS MUST NOT BE A DRAW ON THE NEXT TIC. Stow fires on
			// the press; the stowed grab reads the level -- so with Use still down and
			// the hand still at the mount, the very next tic drew it again. The latch
			// holds until Use is let go.
			if (!use) mStowLatch[i] = false;
			if (mState[i] == SS_STOWED && use && !mStowLatch[i]) OnPress(i);
			else if (mState[i] == SS_DRAWN && usePress) OnPress(i);
			// THE TRIGGER: held revs; let go with a forward flick throws (to the locks, or where
			// you point); press again in flight to recall. Locking is its own input (LockHeld).
			bool sec = SecHeld(p);
			bool secPress = sec && !mGripWas[i];
			bool secRelease = !sec && mGripWas[i];
			mGripWas[i] = sec;
			if (secRelease) OnRelease(i);
			else if (secPress && mState[i] == SS_FLYING && mDisc[i]) SSQ_Disc(mDisc[i]).Recall();

			if (mState[i] == SS_DRAWN && UVI(p, 'ssq_debug', 0) != 0 && (Level.maptime % 35) == 0)
			{
				let ps = mPose[i];
				Vector3 C = SSQ_Guard.PlateCentre(mo, ps, false);
				Vector3 n = SSQ_Guard.PlateNormal(mo, ps, false);
				Console.Printf("ssq: pose F(%.2f %.2f %.2f) L(%.2f %.2f %.2f) U(%.2f %.2f %.2f) hand(%.0f %.0f %.0f) C(%.0f %.0f %.0f) n(%.2f %.2f %.2f) R %.1f fresh %d",
					ps.F.x, ps.F.y, ps.F.z, ps.L.x, ps.L.y, ps.L.z, ps.U.x, ps.U.y, ps.U.z,
					ps.pos[0].x, ps.pos[0].y, ps.pos[0].z, C.x, C.y, C.z, n.x, n.y, n.z, SSQ_Guard.PlateRadius(false, SSQ_Guard.GrowFor(mo)), ps.Fresh(Level.maptime));
			}
			LocksTick(i);
			Props(i);
		}
	}

	// USE in the zone: holstered -> draw; drawn -> holster
	void OnPress(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool fresh = pose.Fresh(Level.maptime);
		double dist = fresh ? ZoneFrac(mo, pose.pos[0]) : 1e9;
		bool atMount = dist <= 1.0;
		if (UVI(p, 'ssq_debug', 0))
		{
			// the hand in the body frame, in cm (room): forward, to the off side, up from your eyes looking ahead
			Vector3 b = fresh ? BodyLocal(mo, pose.pos[0]) * 100.0 : (0, 0, 0);
			Console.Printf("ssq: press p%d state %d fresh %d spot %d zone %.2f (<=1 takes it)  hand on the body: fwd %.0f off-side %.0f up %.0f cm  body yaw %.0f head %.0f",
				i, mState[i], fresh, Spot(p), dist, b.x, b.y, b.z, BodyYaw(mo), mo.angle);
		}
		if (!atMount) return;
		// the key route (ssq_shoulder_use off): the shoulder is not a grab, only the Draw key
		if (UVI(p, 'ssq_shoulder_use', 1) == 0) return;
		if (mState[i] == SS_STOWED) Draw(i);
		else if (mState[i] == SS_DRAWN) { Stow(i, true); mStowLatch[i] = true; }
	}

	// secondary released: moving fast throws; still, it stays in the hand
	void OnRelease(int i)
	{
		if (mState[i] != SS_DRAWN) return;
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		Vector3 hv = pose.Fresh(Level.maptime) ? pose.ThrowVel(SSQ_Hand.PS(mo)) : (0, 0, 0);
		double speed = hv.Length() * TICRATE;
		// A THROW IS A FORWARD SNAP, NOT ANY FAST HAND. Letting go at the end of a block, a
		// backhand or a chop used to launch the shield because only raw speed was tested. The
		// hand has to be going out the way you are looking -- ssq_throw_forward is the cosine
		// of how far off that it may be (0.35 is about 70 degrees). 0 takes any direction back.
		double fwdmin = SSQ_A11y.Low(SV('ssq_throw_forward', 0.35));   // Gesture Ease: x1..x0.5
		bool forward = true;
		if (fwdmin > 0 && speed > 0)
		{
			Vector3 look = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
			forward = (hv.Unit() dot look) >= fwdmin;
		}
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: release p%d speed %.0f/s, %d locked, forward %d", i, speed, mLocks[i].Size(), forward);
		if (speed >= SSQ_A11y.Low(SV('ssq_throw_min', 60.0)) && forward) Throw(i);
		else mKeepMarks[i] = max(mKeepMarks[i], Level.maptime + SVI('ssq_keep_marks', 175));	// not a throw: hold the marks
	}

	clearscope bool Holding(int i) { return true; }	// the catch needs only the hand near the disc

	// WHILE FIRE IS HELD BOTH HANDS ARE PINNED: the shield in the off hand, the gun you had in
	// the main hand. QZD's `switchhand` (an off-hand button on the Quest) nulls BOTH hands and
	// moves the gun across (player.zs SwitchWeaponHand); a weapon-cycle or a pickup switch
	// changes one. Whatever happened, it is undone this tic. Only the release moves the shield.
	// WE STOPPED FIGHTING THE ENGINE FOR THE OFF HAND.
	//
	// v0.6 pinned both hands every single tic: if anything moved a weapon it was put back the
	// same tic, forever. That was aimed at QZD's `switchhand`, which an off-hand button is
	// bound to by default (engine/vr/defbind1.txt:6-7, defbind3.txt:12,21). Reading the stock
	// source settles what it actually does (g_game.cpp:347-361 -> player.zs:2488-2502): the
	// argument is the DESTINATION hand, so it moves the weapon in the OTHER one.
	//
	//   switchhand 0  moves the OFF-hand weapon -- the shield -- into the main hand.
	//                 +WEAPON.NOHANDSWITCH on the shield blocks this outright. Already set.
	//   switchhand 1  moves the MAIN-hand gun into the off hand. It tests NoHandSwitch on the
	//                 GUN, not on us, then nulls BOTH slots -- so the shield can always be
	//                 evicted and no flag we carry can prevent it.
	//
	// So eviction is not an error to undo, it is the player putting the shield down. We take
	// it as exactly that: the shield goes back to the shoulder, the loadout is restored once,
	// and the hand is theirs. Nothing is forced, nothing is re-raised behind their back, and
	// the engine's own command keeps working the way its own menu says it does.
	//
	// The two-hand grab needs no handling here at all. It never nulls OffhandWeapon and never
	// touches the hand pose; it only disables the off-hand weapon's ready/fire/button
	// machinery (weapons.zs:415-418, player.zs:393-396, p_pspr.cpp:847-850) -- and the shield
	// does not use any of it. Every input it has is read straight off p.cmd.buttons, which is
	// in the replicated ticcmd and which the grab cannot gate. The one thing the grab does
	// take is the drawn psprite, and the world prop covers that (see the prop block).
	// THE PIN. This is what v0.6 did and what the shield is known to work with: if anything
	// moves a weapon out of the off hand, put the shield straight back the same tic. It is a
	// fight with the engine, but it is a fight the shield wins, and the weapon pack re-giving
	// its hands weapon to an 'empty' off hand is a real thing that happens every tic.
	// ssq_yield_offhand 1 picks HoldOrYield below instead.
	void PinHands(int i, SSQ_ShieldSaw saw)
	{
		let p = players[i];
		let mo = p.mo;
		bool fix = false;
		// What took the off hand this tic, if anything -- switchhand's fingerprint (below).
		Weapon took = p.OffhandWeapon;
		// Only a hand that actually LOST the shield is put back. A raise merely ASKED FOR while
		// the shield is still in the hand is cancelled below, not answered with a re-raise:
		// with BD22Q loaded the off trigger asks for its hands weapon every tic, and re-raising
		// the shield ran its Select every tic, which zeroed the rev -- it never wound up, so the
		// blades never deployed (the owner's headset, 10-27: "the animations are gone").
		if (p.OffhandWeapon != saw) fix = true;
		if (fix)
		{
			saw.bOffhandWeapon = true;
			// IT MUST NOT MATTER WHO RAN FIRST THIS TIC. Event handlers tick in registration
			// order, which is LOAD order, so whether the saber's bridge or this handler sees the
			// off hand first depends on which pk3 the launcher listed first. Setting only
			// PendingWeapon makes us one voice among several and the last writer in the tic wins.
			// Writing the slot itself does not: whoever ran before us is overridden, and whoever
			// runs after us finds a hand that is not empty and leaves it alone -- which is all
			// either of those mods was ever waiting for. Load order stops mattering.
			p.OffhandWeapon = saw;
			p.PendingWeapon = saw;
			mo.BringUpWeapon();
			if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: pin off -> shield");
		}
		// and cancel a raise somebody else asked for while the shield is the one in the hand
		if (p.PendingWeapon && p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon != saw && p.PendingWeapon.bOffhandWeapon)
			p.PendingWeapon = WP_NOCHANGE;
		// THE MAIN HAND IS UNDONE ONLY WHEN switchhand DID IT. switchhand moves the main gun
		// INTO the off hand (sets its bOffhandWeapon, player.zs:2488-2502) -- so that gun is
		// either what took the off hand this tic or still carries the off-hand flag. Any other
		// change to the main hand is the player's own (a slot key, weapnext, running dry, a
		// pickup's auto-switch), and the shield follows it: the remembered gun becomes the one
		// now in hand. Before this, EVERY main-hand switch was put back ~12 tics later, and a
		// gun that ran dry looped forever (rig, 2026-10-26, with BD22).
		if (mPrevMain[i])
		{
			let back = Weapon(mo.FindInventory(mPrevMain[i]));
			bool switchhand = back && back != saw && (took == back || back.bOffhandWeapon);
			if (!switchhand && p.PendingWeapon == WP_NOCHANGE && p.ReadyWeapon && p.ReadyWeapon != saw && !p.ReadyWeapon.bOffhandWeapon)
				mPrevMain[i] = p.ReadyWeapon.GetClass();
			if (switchhand && p.ReadyWeapon != back && !back.bTwoHanded)
			{
				back.bOffhandWeapon = false;
				p.PendingWeapon = back;
				mo.BringUpWeapon();
				if (UVI(p, 'ssq_debug', 0)) { String rw = "-"; if (p.ReadyWeapon) rw = p.ReadyWeapon.GetClassName(); Console.Printf("ssq: pin main -> %s (now %s)", mPrevMain[i].GetClassName(), rw); }
			}
		}
	}

	// THE YIELD, off by default (ssq_yield_offhand 1). Reads an off hand taken by switchhand or
	// by a pickup as the player putting the shield down, instead of undoing it. Correct in
	// principle -- and it took the shield out of the hand entirely on a pack that re-gives its
	// hands weapon, which is why it is not the default until it has been seen to work.
	void HoldOrYield(int i, SSQ_ShieldSaw saw)
	{
		let p = players[i];
		if (mDrawGrace[i] > 0) { mDrawGrace[i]--; return; }
		if (p.OffhandWeapon == saw) return;
		if (p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon == saw) return;	// mid-raise
		// A WEAPON THAT PUT ITSELF THERE IS NOT THE PLAYER TAKING THE HAND. The pack's hands and
		// the saber's off-hand blade both appear in an empty off hand on their own; yielding to
		// those would have the shield stow itself a tic after every draw. Only a real weapon
		// arriving -- a switchhand, a pickup -- counts, and anything else gets pinned back.
		if (IsFiller(p.OffhandWeapon) || !p.OffhandWeapon) { PinHands(i, saw); return; }
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d off hand taken -- shield to the shoulder", i);
		// the player has just arranged their own hands: forget what the draw displaced, so
		// Unstow does not hand it straight back and start the fight over.
		mPrevOff[i] = null; mPrevMain[i] = null;
		Stow(i, true);
	}
	void ShownLocks(int i, out Array<Actor> found)
	{
		found.Clear();
		if (i < 0 || i >= MAXPLAYERS) return;
		for (int k = 0; k < mLocks[i].Size(); k++) if (mLocks[i][k] && mLocks[i][k].health > 0) found.Push(mLocks[i][k]);
	}

	void ClearLocks(int i)
	{
		mLocks[i].Clear();
		mLockMiss[i].Clear();
		mKeepMarks[i] = 0;
		mLastPaint[i] = 0;
		for (int k = 0; k < mLockMarks[i].Size(); k++) if (mLockMarks[i][k]) mLockMarks[i][k].Destroy();
		mLockMarks[i].Clear();
		mLockSig[i] = 0;
	}

	// IS THIS ONE STILL MINE? The keep test, deliberately looser than the acquire test:
	// alive, inside ssq_lock_keep of where the hand points, in range, in sight.
	static bool LockHolds(PlayerPawn mo, Vector3 from, Vector3 aim, Actor t)
	{
		if (!t || t.health <= 0 || !t.bShootable) return false;
		Vector3 d = t.pos + (0, 0, t.height * 0.5) - from;
		double dist = d.Length();
		if (dist < 1 || dist > SV('ssq_lock_range', 1200.0)) return false;
		if (acos(clamp((d / dist) dot aim, -1, 1)) > SV('ssq_lock_keep', 60.0)) return false;
		return mo.CheckSight(t);
	}

	// once a tic while held: keep what is locked, add what is newly aimed at, and show it.
	//
	// STICKY. v0.6 rebuilt this list from the acquire cone every single tic and re-sorted it
	// by angle, so a target fell out the moment the hand drifted 25 degrees and the disc's
	// visit order churned under the player's eyes -- "lock-on does not stay locked on".
	// Now a lock is acquired inside ssq_lock_cone and KEPT until it dies, leaves the much
	// wider ssq_lock_keep cone, goes out of sight or out of range for ssq_lock_grace tics in
	// a row, or the button comes up. Order is the order you ringed them in, which is the
	// order the disc will visit them -- it never re-sorts behind you.
	void LocksTick(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool aiming = LockHeld(i);
		// let go of the lock: the rings stay ssq_keep_marks tics (5 s), long enough to rev and throw
		if (!aiming && mLockWas[i]) mKeepMarks[i] = Level.maptime + SVI('ssq_keep_marks', 175);
		mLockWas[i] = aiming;
		// A BRIEF RELEASE DOES NOT COST YOU YOUR MARKS. Let go for under ssq_keep_marks tics --
		// to re-grip, to steady yourself -- and the list is still there when you take hold again.
		// Longer than that, or the shield leaving your hand, and it starts fresh.
		if (mState[i] != SS_DRAWN || !pose.Fresh(Level.maptime))
		{
			if (mLocks[i].Size() > 0) ClearLocks(i);
			return;
		}
		if (!aiming)
		{
			if (mLocks[i].Size() > 0 && Level.maptime > mKeepMarks[i]) ClearLocks(i);
			return;
		}

		// LOCKSTEP (Gun Bonsai VR patch, asked by name): one more lock a level
		int want = SVI('ssq_locks', 5) + SSQ_Upg.Lv(mo.FindInventory('SSQ_ShieldSaw'), "Lockstep");
		int grace = SVI('ssq_lock_grace', 105);
		while (mLockMiss[i].Size() < mLocks[i].Size()) mLockMiss[i].Push(0);

		// hold what is already locked
		for (int k = mLocks[i].Size() - 1; k >= 0; k--)
		{
			if (LockHolds(mo, pose.pos[0], pose.A, mLocks[i][k])) { mLockMiss[i][k] = 0; continue; }   // A: Steady Hands' aim, or F
			bool dead = !mLocks[i][k] || mLocks[i][k].health <= 0;
			mLockMiss[i][k] = mLockMiss[i][k] + 1;
			if (dead || mLockMiss[i][k] > grace) { mLocks[i].Delete(k); mLockMiss[i].Delete(k); }
		}

		// ONE AT A TIME, AS YOU SWEEP. Taking every target in the cone at once turns lock-on into
		// a scan: you point roughly at a crowd and five rings appear. Painting the best one every
		// ssq_paint_every tics makes it aiming -- you drag the hand across them and feel each one
		// go on, which is how the owner's lightsaber does it.
		int added = 0;
		if (mLocks[i].Size() < want && Level.maptime - mLastPaint[i] >= SVI('ssq_paint_every', 3))
		{
			Array<Actor> fresh;
			SSQ_Disc.FindTargets(mo, pose.pos[0], pose.A, fresh);   // A: Steady Hands' aim, or F
			for (int k = 0; k < fresh.Size(); k++)
			{
				let t = fresh[k];
				if (!t) continue;
				bool have = false;
				for (int j = 0; j < mLocks[i].Size(); j++) if (mLocks[i][j] == t) { have = true; break; }
				if (have) continue;
				mLocks[i].Push(t); mLockMiss[i].Push(0); added++;
				mLastPaint[i] = Level.maptime;
				break;		// the nearest to the hand's line, and only that one, this time
			}
		}
		if (added > 0)
		{
			mo.A_StartSound("ssq/lock", CHAN_6, 0, 0.8);
			SSQ_FX.Buzz(mo, 0.35, 3);	// you feel each one land, the way the saber does
		}

		// one ring per target, sized by rank: biggest over the one the disc visits first
		while (mLockMarks[i].Size() < mLocks[i].Size())
		{
			let m = Actor.Spawn('SSQ_LockMark', mo.pos);
			mLockMarks[i].Push(m);
		}
		for (int k = 0; k < mLockMarks[i].Size(); k++)
		{
			let m = mLockMarks[i][k];
			if (!m) continue;
			if (k >= mLocks[i].Size()) { m.bInvisible = true; continue; }
			let t = mLocks[i][k];
			if (!t) { m.bInvisible = true; continue; }
			// BIG ENOUGH TO SEE. These were 1.6 / 1.1 / 0.8 at 60% alpha over a monster's head,
			// which in a headset at ten metres is nothing. The one the disc visits first is twice
			// the size of the rest and fully lit, and it breathes so it reads as alive.
			// High contrast (rsqa_colorblind 4): every mark fully lit and a fifth larger, the first
			// breathing twice as deep -- rank is size, never colour.
			bool hc = SSQ_CB.Mode() == 4;
			double pulse = 1.0 + (hc && k == 0 ? 0.24 : 0.12) * sin(Level.maptime * 9.0 + k * 40);
			if (hc) pulse *= 1.2;
			m.bInvisible = false;
			m.SetOrigin(t.pos + (0, 0, t.height + 12), true);
			// around the actor's own 0.35, not around 1: the one the disc visits first is a
			// little under twice the others, which is plenty to read at range without
			// magnifying a 48-pixel picture into a dinner plate.
			m.A_SetScale(0.35 * (k == 0 ? 1.8 : (k == 1 ? 1.3 : 1.0)) * pulse * SV('ssq_lock_mark_scale', 1.0) * SSQ_A11y.Cue());   // Cue Size
			m.A_SetRenderStyle((k == 0 || hc) ? 1.0 : 0.85, STYLE_AddShaded);	// the ring; its centre copies the alpha
			m.angle += (k == 0 ? 14 : 8);
		}
	}

	// ---- the loadout swap -------------------------------------------------------------
	void Draw(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = Weapon(mo.FindInventory('SSQ_ShieldSaw'));
		if (!saw) return;
		let cur = p.OffhandWeapon;
		// the pack's hands weapon comes back on its own (RSQ_Handler re-gives it whenever the
		// off hand is empty), so it is not remembered; anything else is
		mPrevOff[i] = (cur && cur != saw && cur.GetClassName() != 'RSQ_Hands') ? cur.GetClass() : null;
		let rw = p.ReadyWeapon;
		mPrevMain[i] = (rw && rw != saw) ? rw.GetClass() : null;	// pinned while held (switchhand undone)
		saw.bOffhandWeapon = true;
		p.OffhandWeapon = saw;	// the slot is ours THIS tic: no window for anyone to fill
		p.PendingWeapon = saw;
		// BRING IT UP OURSELVES. A switch normally happens inside the old weapon's ready state
		// (it sees PendingWeapon, lowers, raises the next) -- and the zone took that layer away.
		mo.BringUpWeapon();
		mInZone[i] = false;
		mDrawGrace[i] = 8;	// the raise takes a few tics; do not read an empty slot as eviction
		mState[i] = SS_DRAWN;
		mo.A_StartSound("ssq/draw", CHAN_6);
		SSQ_FX.Buzz(mo, 0.5, 6);
		if (UVI(p, 'ssq_debug', 0))
		{
			String po = "-", pm = "-";
			if (mPrevOff[i]) po = mPrevOff[i].GetClassName();
			if (mPrevMain[i]) pm = mPrevMain[i].GetClassName();
			Console.Printf("ssq: p%d DRAW (prev off %s, prev main %s)", i, po, pm);
		}
	}

	// put the previous weapons back; the shield is out of the hand either way
	void Unstow(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		if (p.OffhandWeapon == saw)
		{
			p.SetPsprite(PSP_OFFHANDWEAPON, null);
			p.OffhandWeapon = null;
		}
		if (p.PendingWeapon == saw) p.PendingWeapon = WP_NOCHANGE;
		if (saw) saw.StopRev();
		// THE MAIN HAND FIRST, if raising the shield emptied it (BringUpWeapon nulls a two-handed
		// main gun). This used to sit in an `else` that tested the opposite of its own `if`, so it
		// never ran and the main hand stayed empty. BringUpWeapon raises it at once and leaves
		// PendingWeapon free for the off-hand handover below.
		if (mPrevMain[i] && !p.ReadyWeapon && p.PendingWeapon == WP_NOCHANGE)
		{
			let mainBack = Weapon(mo.FindInventory(mPrevMain[i]));
			if (mainBack && mainBack != saw) { mainBack.bOffhandWeapon = false; p.PendingWeapon = mainBack; mo.BringUpWeapon(); }
		}
		// HAND THE SLOT OVER, DO NOT DROP IT. Leaving OffhandWeapon null even for one tic is an
		// invitation: the pack and the saber both fill an empty off hand on their own schedule,
		// and then two mods are writing PendingWeapon in the same tic and the last one wins.
		// Whatever we displaced goes back here and now; if we displaced nothing, we give the
		// slot to whoever would have claimed it anyway, deliberately, instead of racing them.
		// NOT INTO A TWO-HANDED MAIN: BringUpWeapon nulls a two-handed ReadyWeapon whenever an
		// off-hand weapon comes up (player.zs), which would empty the hand just restored above.
		if (p.PendingWeapon == WP_NOCHANGE && !(p.ReadyWeapon && p.ReadyWeapon.bTwoHanded))
		{
			Weapon back = mPrevOff[i] ? Weapon(mo.FindInventory(mPrevOff[i])) : null;
			if (!back) back = mFistNext[i] ? FistBack(mo) : HandBack(mo);
			if (back && back != p.ReadyWeapon && back != saw)
			{
				back.bOffhandWeapon = true;
				p.OffhandWeapon = back;	// the slot is filled THIS tic, not after a raise
				p.PendingWeapon = back;
				mo.BringUpWeapon();
			}
		}
		mPrevOff[i] = null; mPrevMain[i] = null;
	}

	void Stow(int i, bool sound)
	{
		// ON MANUAL STORE (ssq_store_to, the owner, 10-27): 0 the off hand goes back to its fist
		// (the pack's empty hand, so reloading works at once), 1 to the weapon it held before the
		// shield came out.
		let st = CVar.FindCVar('ssq_store_to');
		if (!st || st.GetInt() == 0) { mPrevOff[i] = null; mFistNext[i] = true; }
		Unstow(i);
		mFistNext[i] = false;
		ClearLocks(i);
		mState[i] = SS_STOWED;
		if (sound) players[i].mo.A_StartSound("ssq/stow", CHAN_6);
		if (UVI(players[i], 'ssq_debug', 0)) Console.Printf("ssq: p%d STOW", i);
	}

	void Throw(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		let pose = mPose[i];
		int rev = saw ? saw.rev : 0;
		Unstow(i);
		let d = SSQ_Disc(Actor.Spawn('SSQ_Disc', pose.pos[0]));
		if (!d) { mState[i] = SS_STOWED; ClearLocks(i); return; }
		d.Claim(saw);
		d.Launch(mo, pose, rev);
		ClearLocks(i);
		mDisc[i] = d;
		mState[i] = SS_FLYING;
		mo.A_StartSound("ssq/throw", CHAN_6);
		SSQ_FX.Buzz(mo, 0.8, 8);
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d THROW speed %.1f/tic rev %d locks %d", i, d.vel.Length(), rev, d.locks.Size());
	}

	// the disc is home: caught (into the hand) or landed (onto the mount)
	void DiscHome(int i, bool caught)
	{
		mDisc[i] = null;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i]) return;
		mState[i] = SS_STOWED;
		if (UVI(players[i], 'ssq_debug', 0)) Console.Printf("ssq: p%d disc home, %s", i, caught ? "CAUGHT" : "landed on the mount");
		let mo = players[i].mo;
		if (!mo || mo.health <= 0) return;
		if (caught)
		{
			Draw(i);
			mCatchGrace[i] = 8;
			mo.A_StartSound("ssq/catch", CHAN_6);
			SSQ_FX.Buzz(mo, 1.0, 10);
		}
	}

	// ---- the world props -------------------------------------------------------------
	void HideProps(int i)
	{
		if (mProp[i]) mProp[i].bInvisible = true;
		if (mMarker[i]) mMarker[i].bInvisible = true;
	}

	void Props(int i)
	{
		let p = players[i];
		let mo = p.mo;
		if (!mProp[i]) mProp[i] = Actor.Spawn('SSQ_Prop', mo.pos);
		if (!mMarker[i]) mMarker[i] = Actor.Spawn('SSQ_MountMarker', mo.pos);
		let prop = mProp[i];
		let mk = mMarker[i];
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		let pose = mPose[i];
		Vector3 mount = MountPos(mo);

		// the marker: 0 never, 1 while it matters, 2 always; brighter when the hand is in reach
		int mode = UVI(p, 'ssq_marker', 1);
		bool show = mode == 2 || (mode == 1 && mState[i] != SS_FLYING);
		if (UVI(p, 'ssq_shoulder_use', 1) == 0) show = false;   // nothing to reach for on the key route
		mk.bInvisible = !show;
		if (show)
		{
			mk.SetOrigin(mount, true);
			// sized as before for the shoulder (its 30 cm reach); the back spots, whose zones are far larger, keep the
			// shoulder's size so the marker does not become a plate
			mk.A_SetScale(CM(UV(p, 'ssq_mount_reach', 30.0)) * 0.4);
			double d = pose.Fresh(Level.maptime) ? ZoneFrac(mo, pose.pos[0]) : 1e9;
			mk.A_SetRenderStyle(d <= 1.0 ? 0.9 : (d <= ZoneK() ? 0.5 : 0.2), STYLE_Add);
			mk.angle += 3;
		}

		// THE SHIELD YOU CAN SEE.
		//
		// Stowed, the prop IS the shield: it hangs at the grab point in the pose the guard
		// plate is computed for (MountPlateCentre/Normal), so what blocks and what is drawn
		// are the same object. The mesh origin is the grip, which is why the actor sits at
		// the grab point itself and the disc falls below it on its own -- no drop fudge.
		// Model +x is the actor's forward and +y its left (models.cpp RenderModel over the
		// (mx, mz, my) swizzle), so pitch -90 stands the forearm axis up and roll 180 turns
		// the plate's +L side -- the side your arm is on -- forward into your back.
		if (mState[i] == SS_STOWED)
		{
			prop.bInvisible = UVI(p, 'ssq_stow_world', 0) == 0;	// owner's default: not drawn when stored
			prop.SetOrigin(mount, true);
			prop.angle = BodyYaw(mo) + UV(p, 'ssq_mount_yaw', 0);
			prop.pitch = (OnBack(p) ? -MountPropPitch() : MountPropPitch()) + UV(p, 'ssq_mount_pitch', 0);
			prop.roll  = MountPropRoll()  + UV(p, 'ssq_mount_roll', 0);
			prop.A_SetScale(UV(p, 'ssq_mount_scale', 1.0) * SSQ_Guard.Scale());
			prop.frame = 0;
		}
		else if (mState[i] == SS_DRAWN)
		{
			// 0 never, 1 always, 2 only for other players' eyes. PLUS: while QZD's two-hand
			// grab is held the engine stops drawing every off-hand psprite in C++
			// (hw_weapon.cpp:833,919) -- script cannot prevent it -- so the shield would
			// vanish out of your own hand. The world prop stands in for exactly that long.
			int hw = UVI(p, 'ssq_held_world', 2);
			bool grabbed = (p.WeaponState & WF_TWOHANDSTABILIZED) != 0;
			// AND THE GRAB IS NOT A PREFERENCE. hw == 0 is "never draw the world copy", which is
			// a choice about what you and others see while the shield is in a normal grip -- but
			// the grab is not a matter of taste: the engine draws NO off-hand psprite at all
			// while it is held (hw_weapon.cpp:832-835 and :916-919, both keyed on the global
			// weaponStabilised that also raises WF_TWOHANDSTABILIZED at p_pspr.cpp:512-515), and
			// script cannot prevent it. So `hw != 0 && grabbed` meant a player who had turned the
			// world copy off in the options menu lost the shield out of his own hand the instant
			// the grip latched -- the exact failure this clause exists to prevent, with the
			// setting that reopens it one menu line away. The stand-in is unconditional now;
			// hw still decides the ordinary, ungrabbed case.
			bool want = hw == 1 || (hw == 2 && multiplayer) || grabbed;
			prop.bInvisible = !want || !pose.Fresh(Level.maptime);
			if (!prop.bInvisible)
			{
				// THE PROP'S ORIGIN IS THE GRIP, not the disc. shield.md3's origin sits in the
				// hand (hand_ssq straddles it, the handle bar is 1.3 cm off it) and the world
				// block carries no Offset, so the actor goes AT THE CONTROLLER and the mesh
				// puts the disc 15.4 cm back along the forearm by itself. Placing it at the
				// plate centre, as this did, pushed the drawn shield a whole radius off the
				// hand -- the guard was right and the picture was not.
				// AND IT CARRIES THE HELD OFFSETS. ModifyBobLayer3D adds ssq_held_x/y/z and
				// ssq_held_yaw/pitch/roll to the held layer every frame (shield.zs:176-177) --
				// the placement the owner dials in with the headset on -- and this prop, which
				// stands in for that layer whenever it is not drawn, was posed from the raw hand
				// with none of them. So on anyone who had touched those sliders the shield JUMPED
				// by the dialled-in offset the moment the two-hand grab started, and jumped back
				// on release. Same pose basis, same numbers.
				//
				// THE LAYER'S AXES, followed through stock QZD 17.3. The translation and the
				// three rotations are applied INSIDE the MODELDEF mesh scale (models.cpp
				// RenderHUDModel: the S(xscale,zscale,yscale) node, then T(pivot) . R(rotation.X
				// about Y) . R(rotation.Y about X) . R(rotation.Z about Z) . T(-pivot) .
				// T(translation)), and hw_vrmodes.cpp MapWeaponDir makes the layer frame
				// X = -L, Y = U, Z = -F -- which is why shield.zs packs the sliders as
				// (x, z, -y): x is the hand's right, y its forward, z its up.
				//
				// The held blocks of MODELDEF MIRROR the mesh for the other hand (SSQH is
				// Scale -1 1 1, SSQJ is Scale 1 1 1), and the nodes above sit inside that scale,
				// so the mirror conjugates them: the lateral slide and the rotations about Y and
				// Z change sign with the hand, the rotation about X does not. SSQ_Guard.Side() is
				// already exactly that sign (+1 when the off hand is the left controller, which
				// is the mirrored SSQH block), which is why the plate measurement uses it too.
				// SSQ_Prop's own mesh is NOT mirrored (Scale 0.34 0.34 0.34), so what is applied
				// here is the effective, post-mirror motion. ssq_shield_scale does not scale it:
				// it swaps the held model for a larger one rather than scaling one (MODELDEF:143)
				// and the layer translation is in mesh units either way. The one term not
				// reproduced is the rotation pivot, which this mod never sets
				// (ModifyBobPivotLayer3D is not overridden).
				double hs = SSQ_Guard.Side(p);
				double ry1 = -UV(p, 'ssq_held_yaw', 0) * hs;	// about the hand's up
				double rp1 = UV(p, 'ssq_held_pitch', 0);		// about its lateral axis
				double rr1 = -UV(p, 'ssq_held_roll', 0) * hs;	// about its forward
				double c1 = cos(ry1), s1 = sin(ry1);
				double c2 = cos(rp1), s2 = sin(rp1);
				double c3 = cos(rr1), s3 = sin(rr1);
				// the hand's axes turned by those three, written out in the hand's own basis so
				// that no function has to hand a Vector3 back: pose.zs:29-31 and guard.zs:136
				// both record that this VM drops those.
				Vector3 hF = pose.F * (c1 * c2) + pose.L * (s1 * c2) + pose.U * s2;
				Vector3 hL = pose.F * (-s1 * c3 + c1 * s2 * s3) + pose.L * (c1 * c3 + s1 * s2 * s3) + pose.U * (-c2 * s3);
				Vector3 hU = pose.F * (-s1 * s3 - c1 * s2 * c3) + pose.L * (c1 * s3 - s1 * s2 * c3) + pose.U * (c2 * c3);
				// and the slide, along the TURNED axes, because the layer's translation node sits
				// inside its rotation node (so the layer's own offset is rotated with it)
				Vector3 hoff = hF * CM(UV(p, 'ssq_held_y', 0))
					+ hL * (CM(UV(p, 'ssq_held_x', 0)) * hs)
					+ hU * CM(UV(p, 'ssq_held_z', 0));
				prop.SetOrigin(pose.pos[0] + hoff, true);
				prop.angle = atan2(hF.y, hF.x);
				prop.pitch = -asin(clamp(hF.z, -1, 1));
				prop.roll = SSQ_Hand.RollOf(hF, hL);
				prop.A_SetScale(SSQ_Guard.Scale());	// the world copy grows with the plate
				prop.frame = saw ? saw.Frame() : 0;
			}
		}
		else prop.bInvisible = true;
	}

	// ---- the muzzle: every hitscan in the level passes through here first ----------------
	//
	// Stock QZD calls this before P_LineAttack traces anything (p_map.cpp:4718) and true
	// cancels the shot outright. It is the only place a bullet can be stopped, because by the
	// time AbsorbDamage sees one it has already hit. Cheap by construction: it returns on the
	// first line for every shot in the game unless a player actually has a shield up.
	//
	// A PLAYER'S OWN SHOTS ARE NEVER TESTED. Not the gun in their hand, not the shield's own
	// return trace, not another mod's -- a shield stops what is fired AT you.
	override bool WorldHitscanPreFired(WorldEvent e)
	{
		if (SVI('ssq_guard', 1) == 0 || SVI('ssq_hitscan_guard', 1) == 0) return false;
		Actor shooter = e.Thing;
		if (!shooter || shooter.player) return false;
		// our own return shot comes off the plate from a helper (guard.zs): never eat it
		if (shooter is 'SSQ_Ricochet') return false;
		double ca = cos(e.AttackPitch);
		Vector3 dir = (cos(e.AttackAngle) * ca, sin(e.AttackAngle) * ca, -sin(e.AttackPitch));
		if (dir.Length() <= 0) return false;
		// WHERE THE SHOT REALLY STARTS, by P_LineAttack's own formula (p_map.cpp on stock QZD
		// 17.3): shootz = Center() - Floorclip + AttackOffset() + sz, and AttackOffset() is a flat
		// 8 for anything that is not a player. sz is the attack's own z offset, which the event
		// hands us as AttackZ and this never read. height * 0.75 was a guess sitting 6 units high
		// on an imp and 14 on a Cyberdemon -- against a 29 cm plate at twenty metres that is most
		// of the guard, which is why bullets that looked blockable were not.
		// LAF_OVERRIDEZ measures from the actor's feet instead.
		double mz = ((e.AttackLineFlags & LAF_OVERRIDEZ) ? 0.0 : (shooter.height * 0.5 - shooter.Floorclip + 8.0)) + e.AttackZ;
		Vector3 A = shooter.pos + (0, 0, mz);
		double dist = e.AttackDistance > 0 ? e.AttackDistance : 2048.0;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i]) continue;
			let p = players[i];
			if (!p.mo || p.mo == shooter) continue;
			if (mState[i] == SS_FLYING) continue;	// it is not in your hand to block with
			let g = SSQ_Guard(p.mo.FindInventory('SSQ_Guard'));
			if (!g) continue;
			if (g.StopsHitscan(shooter, A, dir, dist, e.Damage))
			{
				if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d ATE a hitscan from %s", i, shooter.GetClassName());
				return true;
			}
		}
		return false;
	}

	// ---- events ------------------------------------------------------------------
	// the live state in the corner, for a screenshot (Debug -> Print decisions)
	override void RenderOverlay(RenderEvent e)
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		if (!p.mo || UVI(p, 'ssq_debug', 0) == 0) return;
		int i = consoleplayer;
		String off = "-", main = "-";
		if (p.OffhandWeapon) off = p.OffhandWeapon.GetClassName();
		if (p.ReadyWeapon) main = p.ReadyWeapon.GetClassName();
		String pend = (p.PendingWeapon == WP_NOCHANGE) ? "-" : (p.PendingWeapon ? String.Format("%s", p.PendingWeapon.GetClassName()) : "null");
		let saw = SSQ_ShieldSaw(p.mo.FindInventory('SSQ_ShieldSaw'));
		int b = p.cmd.buttons;
		String line1 = String.Format("SSQ state %d  off %s  main %s  pending %s", mState[i], off, main, pend);
		String line2 = String.Format("buttons: atk %d alt %d ohatk %d ohalt %d   stabilised %d   rev %d  locks %d",
			(b & BT_ATTACK) != 0, (b & BT_ALTATTACK) != 0, (b & BT_OFFHANDATTACK) != 0, (b & BT_OFFHANDALTATTACK) != 0,
			(p.WeaponState & WF_TWOHANDSTABILIZED) != 0, saw ? saw.rev : -1, mLocks[i].Size());
		let pose = mPose[i];
		String line3 = String.Format("pose fresh %d  zone %.2f  body yaw %.0f head %.0f", pose.Fresh(Level.maptime), pose.Fresh(Level.maptime) ? ZoneFrac(p.mo, pose.pos[0]) : -1.0, BodyYaw(p.mo), p.mo.angle);
		Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 40, line1, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
		Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 50, line2, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
		Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 60, line3, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i] || !players[i].mo) return;
		let mo = players[i].mo;
		if (e.Name == "ssq-pose")
		{
			double yaw, pitch, roll; int grip;
			[yaw, pitch, roll, grip] = SSQ_Hand.UnpackAng(e.Args[1]);
			mPose[i].Push(mo.pos + SSQ_Hand.UnpackPos(e.Args[0]), mo.pos, mo.angle, yaw, pitch, roll, grip != 0, Level.maptime);
			mPose[i].left = (e.Args[2] & 1) != 0;
			// Args[2]: bit 0 left-handed; bits 1-20 the smoothed aim's yaw / pitch (10 bits each) with bit 21 saying it
			// is there (Steady Hands on at the sender); bits 22-29 the sender's seat drop in cm (Seated Play)
			if ((e.Args[2] >> 21) & 1)
			{
				double ay = ((e.Args[2] >> 1) & 0x3FF) / 1023.0 * 360.0, ap = ((e.Args[2] >> 11) & 0x3FF) / 1023.0 * 180.0 - 90.0;
				mPose[i].A = (cos(ap) * cos(ay), cos(ap) * sin(ay), sin(ap));
			}
			mPose[i].seatCm = (e.Args[2] >> 22) & 0xFF;
		}
		else if (e.Name == "ssq-body")
		{
			// the body's yaw from the player's own machine (BodyKeep), in hundredths of a degree
			mBodyYaw[i] = Actor.Normalize180(e.Args[0] / 100.0);
			mBodyHave[i] = true;
			mBodyEyeOk[i] = e.Args[1] > 0;
			mBodyEye[i] = e.Args[1] / 1000.0;
		}
		else if (e.Name == "ssq-draw")
		{
			// the desktop route: no reach needed
			if (mState[i] == SS_STOWED) Draw(i);
			else if (mState[i] == SS_DRAWN) Stow(i, true);
			else if (mDisc[i]) SSQ_Disc(mDisc[i]).Recall();
		}
		else if (e.Name == "ssq-lock")
		{
			// RSQ_Accessibility's Hold to Toggle: a press latches the lock key, the next lets it go
			if (SSQ_A11y.HoldToggle()) { if (e.Args[0]) mLockKey[i] = !mLockKey[i]; }
			else mLockKey[i] = e.Args[0] != 0;
		}
		else if (e.Name == "ssq-brace")
		{
			bool b = e.Args[0] != 0 && mState[i] == SS_DRAWN;
			if (b != mBraced[i] && UVI(players[i], 'ssq_debug', 0))
				Console.Printf("ssq: p%d saber over shield %s (block x%.2f)", i, b ? "ON" : "off", b ? clamp(SV('ssq_brace_widen', 1.3), 1.0, 2.0) : 1.0);
			mBraced[i] = b;
		}
		else if (e.Name == "ssq-throw")
		{
			// throw along the aim, for a player with no hand motion to read
			if (mState[i] == SS_DRAWN) ThrowAlongAim(i);
		}
		else if (e.Name == "rsqa_alt" && e.Args[0] == 6 && e.Args[1] && SSQ_A11y.OneHand())
		{
			// RSQ_Accessibility's Shield Throw gesture button (One-Handed): the forward flick's throw --
			// to the ringed targets when there are any, else along the aim
			if (mState[i] == SS_DRAWN) { if (mLocks[i].Size() > 0) Throw(i); else ThrowAlongAim(i); }
		}
	}

	void ThrowAlongAim(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		int rev = saw ? saw.rev : 0;
		Vector3 from = mo.pos + (0, 0, p.viewz - mo.pos.z - 8);
		Vector3 dir = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
		Unstow(i);
		let d = SSQ_Disc(Actor.Spawn('SSQ_Disc', from + dir * 16));
		if (!d) { mState[i] = SS_STOWED; return; }
		d.Claim(saw);
		d.LaunchAlong(mo, dir, SV('ssq_speed_floor', 12.0) * 3.0, 90, rev);	// flat, like a frisbee
		mDisc[i] = d;
		mState[i] = SS_FLYING;
		mo.A_StartSound("ssq/throw", CHAN_6);
		if (UVI(p, 'ssq_debug', 0))
		{
			String mw = "-"; if (p.ReadyWeapon) mw = p.ReadyWeapon.GetClassName();
			String ow = "-"; if (p.OffhandWeapon) ow = p.OffhandWeapon.GetClassName();
			Console.Printf("ssq: p%d THROW along aim, speed %.1f/tic rev %d locks %d  (main now %s, off now %s)", i, d.vel.Length(), rev, d.locks.Size(), mw, ow);
		}
	}

	// ---- the console player's side: the pose, and the raw grip ----------------------------
	// SendPose runs in WorldTick on every machine, for that machine's own console player only:
	// it reads the renderer-written fields (console pawn only) and sends them. The sim never
	// reads those fields anywhere else. OffhandDir is play-scope, so this cannot live in UiTick.
	// ---- WALL SLAM (owner's pick 12; Quest teardown surveys/01_MELEE.md 4.7) -----------------------
	// A bashed body is watched for 12 tics (longer while a hit-stop holds it). The engine stops a monster
	// that walks into a wall dead: P_XYMovement zeroes its XY velocity and leaves the line in
	// MovementBlockingLine (p_mobj.cpp:2231, :2400-2402), and clears that field at the start of each move
	// (:4338). WorldTick runs before the thinkers (p_tick.cpp:171-173), so here we see the result of last
	// tic's move against the velocity we saw before it: struck a line, and was going INTO it at
	// ssq_slam_min or more, is a slam. Once per bash.
	void ArmSlam(Actor t, int pnum)
	{
		if (!t || SVI('ssq_slam', 1) == 0) return;
		t.MovementBlockingLine = null;	// a stale line from its own walking is not this shove's wall
		int k = mSlamWho.Find(t);
		if (k >= mSlamWho.Size())
		{
			if (mSlamWho.Size() >= 32) { mSlamWho.Delete(0); mSlamBy.Delete(0); mSlamUntil.Delete(0); mSlamVX.Delete(0); mSlamVY.Delete(0); }
			mSlamWho.Push(t); mSlamBy.Push(pnum); mSlamUntil.Push(0); mSlamVX.Push(0); mSlamVY.Push(0);
			k = mSlamWho.Size() - 1;
		}
		mSlamBy[k] = pnum;
		mSlamUntil[k] = Level.maptime + 12 + max(t.freezetics, 0);
		mSlamVX[k] = t.vel.x; mSlamVY[k] = t.vel.y;
	}

	void SlamTick()
	{
		for (int k = mSlamWho.Size() - 1; k >= 0; k--)
		{
			Actor v = mSlamWho[k];
			if (!v || v.health <= 0 || v.bMissile || Level.maptime > mSlamUntil[k] || SVI('ssq_slam', 1) == 0)
			{
				mSlamWho.Delete(k); mSlamBy.Delete(k); mSlamUntil.Delete(k); mSlamVX.Delete(k); mSlamVY.Delete(k);
				continue;
			}
			if (v.freezetics > 0) { mSlamUntil[k] = max(mSlamUntil[k], Level.maptime + v.freezetics + 2); continue; }
			Line ln = v.MovementBlockingLine;
			if (ln)
			{
				// the wall's normal, toward the side the body is on
				Vector2 d = ln.delta;
				Vector2 nrm = (d.y, -d.x);
				double nl = nrm.Length();
				if (nl > 0)
				{
					nrm /= nl;
					if ((v.pos.xy - ln.v1.p) dot nrm < 0) nrm = -nrm;
					double impact = -((mSlamVX[k], mSlamVY[k]) dot nrm);
					if (impact >= SV('ssq_slam_min', 3.0))
					{
						Slam(v, mSlamBy[k], nrm, impact);
						mSlamWho.Delete(k); mSlamBy.Delete(k); mSlamUntil.Delete(k); mSlamVX.Delete(k); mSlamVY.Delete(k);
						continue;
					}
				}
			}
			mSlamVX[k] = v.vel.x; mSlamVY[k] = v.vel.y;
		}
	}

	void Slam(Actor v, int pnum, Vector2 nrm, double impact)
	{
		PlayerPawn mo = (pnum >= 0 && pnum < MAXPLAYERS && playeringame[pnum]) ? players[pnum].mo : null;
		int dmg = int(clamp(impact * 2.0, 5, 40) * SV('ssq_slam_damage', 1.0));
		Vector3 at = v.pos + (-nrm.x * v.radius, -nrm.y * v.radius, v.height * 0.5);
		int hp = v.health;
		if (dmg > 0)
		{
			let saw = mo ? mo.FindInventory('SSQ_ShieldSaw') : null;
			let upg = SSQ_Upg.Svc();
			if (upg && saw) upg.GetInt("credit.push", "", 2, 0, saw);
			SSQ_FX.Hit(v, mo, mo, dmg, 'Melee');
			if (upg && saw) upg.GetInt("credit.pop", "", 0, 0, saw);
		}
		if (mo && mo.player && UVI(mo.player, 'ssq_debug', 0))
			Console.Printf("ssq: WALL SLAM %s at %.1f u/tic into the wall, dmg %d (hp %d -> %d), stun %d", v ? v.GetClassName() : 'gone', impact, dmg, hp, v ? v.health : 0, SVI('ssq_slam_stun', 8));
		if (mo) SSQ_FX.At(mo, at, "ssq/bash", CHAN_5, 0.9, 0.8);
		if (mo && mo.player && UVI(mo.player, 'ssq_feedback', 1) != 0) SSQ_FX.Sparks(mo, at, (nrm.x, nrm.y, 0.2), 10);
		if (!v || v.health <= 0) return;
		// stunned: the pain state, held, and a small rebound off the wall once it thaws (01_MELEE 4.7: 0.45)
		// The PLAIN pain state, not Pain.Melee: Brutal Doom's Pain.Melee sends an unaware monster into its
		// stealth-kill cutscene (brutal22test6 actors/Enemies/Imps.dec Pain.Melee -> GotoStealthKill; on the rig
		// a bash on an idle BD imp already does this, old pk3 and new, and the camera leaves the player). A wall
		// must not add a second way in. Plain Pain also takes the stealth flag away.
		v.TriggerPainChance('None', true);
		v.freezetics = max(v.freezetics, clamp(SVI('ssq_slam_stun', 8), 0, 35));
		if (!v.bDontThrust && v.Mass < 0x7FFFFFFF) v.vel.xy = nrm * impact * 0.45;
	}

	// ---- SABER OVER SHIELD: decided here, on the player's own machine (pick 15) --------------------
	// Read only through what is public: the main-hand weapon's class name (RSQ Saber's are UBQS_*, the Force
	// hand excepted), its blade lit (UBQS_SaberService "saber.lit", hand 0, when it answers), and the raw hand
	// fields. The blade's line is the saber's resting frame worked through from its own code: the blade leaves
	// the hand's forward 50 degrees toward the hand's up (QuestSaber zscript.txt UBQS_Data.Up(0) = 50, Yaw(0) = 0)
	// and runs from BeamAlong(5.111, 6.091) to BeamAlong(37.940, 45.216) along it (3.3 to 31.3 units at
	// ubqs_size 1, vr_weaponScale 1). The plate is the synced one. Braced = two or more of nine points along
	// the blade lie over the plate's face (within its rim) and within ssq_brace_gap of the front.
	static double SaberAlong(double sz, double mx, double mz)
	{
		let wsc = CVar.FindCVar('vr_weaponScale');
		double k = 1.6080 * sz * (wsc ? wsc.GetFloat() : 1.0);
		return SSQ_Hand.VU() * 0.01 * ((5.0 - 8.0 + k * mz) * sin(50.0) - (30.0 - 29.0 - k * mx) * cos(50.0));
	}

	bool BraceNow()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return false;
		if (SVI('ssq_brace', 1) == 0) return false;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || mo.health <= 0 || !SSQ_Hand.InVR(mo) || mState[consoleplayer] != SS_DRAWN) return false;
		let pose = mPose[consoleplayer];
		if (!pose || !pose.Fresh(Level.maptime)) return false;
		let w = p.ReadyWeapon;
		if (!w) return false;
		String cn = w.GetClassName();
		if (!(cn.Left(5) ~== "UBQS_") || cn ~== "UBQS_ForceHand") return false;
		let svc = ServiceIterator.Find("UBQS_SaberService").Next();
		if (svc && svc.GetInt("saber.lit", "", 0, 0, mo) != 1) return false;
		let szc = CVar.GetCVar('ubqs_size', p);
		double sz = szc ? clamp(szc.GetFloat(), 0.7, 1.3) : 1.0;
		Vector3 hand = mo.AttackPos;
		Vector3 F = SSQ_Hand.MainDir(mo, 0, 0);
		Vector3 U = SSQ_Hand.MainDir(mo, 0, 90);
		Vector3 bd = F * cos(50.0) + U * sin(50.0);
		double a0 = SaberAlong(sz, 5.111, 6.091), a1 = SaberAlong(sz, 37.940, 45.216);
		Vector3 C = SSQ_Guard.PlateCentre(mo, pose, false);
		Vector3 n = SSQ_Guard.PlateNormal(mo, pose, false);
		double R = SSQ_Guard.PlateRadius(false, 1.0);
		double gap = CM(SV('ssq_brace_gap', 15.0));
		int over = 0;
		for (int s = 0; s <= 8; s++)
		{
			Vector3 q = hand + bd * (a0 + (a1 - a0) * s / 8.0) - C;
			double al = q dot n;
			if (al < -CM(2.0) || al > gap) continue;
			if ((q - n * al).Length() <= R) over++;
		}
		if (UVI(p, 'ssq_debug', 0) && (Level.maptime % 35) == 0)
		{
			Vector3 b0 = hand + bd * a0, b1 = hand + bd * a1;
			Console.Printf("ssq: brace test %s over %d/9 blade (%.0f %.0f %.0f)->(%.0f %.0f %.0f) dir(%.2f %.2f %.2f) plate C(%.0f %.0f %.0f) n(%.2f %.2f %.2f)", cn, over,
				b0.x, b0.y, b0.z, b1.x, b1.y, b1.z, bd.x, bd.y, bd.z, C.x, C.y, C.z, n.x, n.y, n.z);
		}
		return over >= 2;
	}

	void SendBrace()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		int now = BraceNow() ? 2 : 1;
		if (now == mBraceSent) return;
		if (mBraceSent == 0 && now == 1) { mBraceSent = 1; return; }
		mBraceSent = now;
		EventHandler.SendNetworkEvent("ssq-brace", now - 1);
	}

	void SendPose()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || !SSQ_Hand.InVR(mo)) return;
		int st = mState[consoleplayer];
		bool grip = (p.cmd.buttons & (BT_USE | BT_OFFHANDALTATTACK)) != 0;
		Vector3 hand = mo.OffhandPos;
		// RSQ_Accessibility's Off-Hand Modifier (One-Handed): while it is held and the shield is on the
		// shoulder, the MAIN hand is the one that reaches for it (Use at the off shoulder draws, as ever).
		// Drawn, the plate is where the engine draws the off weapon: on the off controller.
		bool swapped = st == SS_STOWED && SSQ_A11y.Swapped(mo);
		if (swapped) hand = mo.AttackPos;
		bool nearMount = ZoneFrac(mo, hand) <= ZoneK() * 1.5;
		// a changed seat drop is sent too, so the mount follows you sitting down even while nothing else needs the pose
		int seatCm = LocalSeatCm(mo);
		let mine = mPose[consoleplayer];
		bool seatStale = mine && abs(seatCm - mine.seatCm) > 2;
		bool want = st != SS_STOWED || grip || nearMount || seatStale;
		if (!want) return;
		Vector3 F = swapped ? SSQ_Hand.MainDir(mo, 0, 0) : SSQ_Hand.OffDir(mo, 0, 0);
		Vector3 L = swapped ? SSQ_Hand.MainDir(mo, 90, 0) : SSQ_Hand.OffDir(mo, 90, 0);
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		double roll = SSQ_Hand.RollOf(F, L);
		int extra = (LocalLeftHanded() ? 1 : 0) | (seatCm << 22);
		// STEADY HANDS (RSQ_Accessibility AC6, a11y.zs): the aim the locks and the throw's aim share is turned by how far
		// the smoothed hand differs from the raw one (yaw and pitch), and sent beside the raw pose. Off / absent: not sent.
		int ctl = swapped ? 0 : 1;
		if (SSQ_A11y.SteadyOn(mo))
		{
			double ry = (ctl == 0 ? mo.AttackAngle : mo.OffhandAngle), rp = (ctl == 0 ? mo.AttackPitch : mo.OffhandPitch);
			double ay = yaw + Actor.DeltaAngle(ry, SSQ_A11y.SteadyAngle(mo, ctl, "angle"));
			double ap = clamp(pitch + (SSQ_A11y.SteadyAngle(mo, ctl, "pitch") - rp), -90.0, 90.0);
			int iy = SSQ_Hand.ClampI(int(round((ay % 360.0 + 360.0) % 360.0 / 360.0 * 1023.0)), 0, 1023);
			int ip = SSQ_Hand.ClampI(int(round((ap + 90.0) / 180.0 * 1023.0)), 0, 1023);
			extra |= (iy << 1) | (ip << 11) | (1 << 21);
		}
		EventHandler.SendNetworkEvent("ssq-pose", SSQ_Hand.PackPos(hand - mo.pos), SSQ_Hand.PackAng(yaw, pitch, roll, grip), extra);
	}

}
