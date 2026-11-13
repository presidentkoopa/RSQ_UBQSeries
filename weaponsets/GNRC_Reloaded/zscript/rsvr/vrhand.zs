// RS VR melee -- where the weapon hand is (QuestZDoom 17.3 fields, read only).
//
// QZD sets these on the player every frame (hw_openxrdevice.cpp / gl_openvr.cpp):
//   AttackPos            the weapon controller, world position
//   AttackDir(mo, a, p)  a direction in the controller's own frame, returned as
//                        (angle, pitch, 0); relative yaw 0 / pitch 0 = forward,
//                        yaw +90 = left, pitch +90 = up (MapWeaponDir)
//   OffhandPos           the other controller, world position
//   OverrideAttackPosDir true while playing in VR
// The held model hangs off the same transform (models.cpp RenderHUDModel), so a
// point of the model can be placed in the world exactly where it is drawn.
// This is the only file that touches QZD's own fields (OffDir, Buttons, Steadied and
// SteadyGap added for rsr/vreload.zs; the headless test stands in for this file).

class RSVR_VRHand play
{
	// playing in VR with the weapon following the controller
	static bool InVR(PlayerPawn mo)
	{
		return mo && mo.player && mo.player.PlayInVR && mo.OverrideAttackPosDir;
	}

	// THE ENGINE'S FIXED EYE HEIGHT (2.0.4g, owner 2026-11-11). With vr_crouch_use_button on, QuestZDoom places the eyes and
	// the hands at viewz + the headset's height - a height it caches ONCE (hw_openxrdevice.cpp:158-170,
	// getDoomPlayerHeightWithoutCrouch: player->DefaultViewHeight(), the pawn's ViewHeight at its first frame). RSQ SlowMo's
	// DOWN scales the pawn's ViewHeight to 40% while you are down, so mo.ViewHeight is not that number then; the class's
	// default is, crouched or not. A crouch still reaches the eye through viewz. Code only, not shown.
	static clearscope double StandEyeHeight(PlayerPawn mo)
	{
		return mo ? mo.Default.ViewHeight : 41.0;
	}

	// the weapon controller, world position -- 2.0.3s: where it is NOW (RSVR_HandSync below), not where
	// the last rendered frame left it
	static Vector3 HandPos(PlayerPawn mo)
	{
		return RSVR_HandSync.Now(mo, false);
	}

	// the other controller, world position (rsq/reload.zs, rsq/hands.zs)
	static Vector3 OffPos(PlayerPawn mo)
	{
		return RSVR_HandSync.Now(mo, true);
	}

	// unit vector of a direction in the controller's frame (yaw 0 pitch 0 =
	// forward, yaw 90 = left, pitch 90 = up), with the hand transform's vertical
	// squash (1 / pixelstretch) taken back out
	static Vector3 HandDir(PlayerPawn mo, double yaw, double pitch, double ps)
	{
		// 2026-10-27: the engine sets the pointer behind AttackDir only while it renders a frame
		// (hw_vrmodes.cpp). A pawn restored from a save thinks before its first frame, and an
		// unguarded call there segfaulted (save/load crash). Only call it when it is live.
		Vector3 ap = mo.OverrideAttackPosDir ? mo.AttackDir(mo, mo.angle + yaw, mo.pitch + pitch)
			: (mo.angle + yaw, mo.pitch + pitch, 0);
		double cp = cos(ap.y);
		Vector3 v = (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y) * ps);
		double l = v.Length();
		if (l <= 0)
			return (1, 0, 0);
		return v / l;
	}

	// the same for the off controller (rsr/vreload.zs). The engine mirrors the left
	// controller's frame (hw_vrmodes GetWeaponTransform); OffhandDir and AttackDir
	// include that, so these are the axes the layers on each hand are drawn in.
	static Vector3 OffDir(PlayerPawn mo, double yaw, double pitch, double ps)
	{
		// 2026-10-27: the engine sets the pointer behind OffhandDir only while it renders a frame
		// (hw_vrmodes.cpp). A pawn restored from a save thinks before its first frame, and an
		// unguarded call there segfaulted (save/load crash). Only call it when it is live.
		Vector3 ap = mo.OverrideAttackPosDir ? mo.OffhandDir(mo, mo.angle + yaw, mo.pitch + pitch)
			: (mo.angle + yaw, mo.pitch + pitch, 0);
		double cp = cos(ap.y);
		Vector3 v = (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y) * ps);
		double l = v.Length();
		if (l <= 0)
			return (1, 0, 0);
		return v / l;
	}

	// this tic's usercmd buttons (BT_OFFHANDATTACK: the off-hand trigger)
	static int Buttons(PlayerPawn mo)
	{
		return mo.player.cmd.buttons;
	}

	// the engine is steadying the gun with both hands (an off grip pressed within 50 cm
	// of the gun controller while vr_two_handed_weapons is on; p_pspr.cpp sets the flag)
	static bool Steadied(PlayerPawn mo)
	{
		return (mo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0;
	}

	// F11: two hands on the weapon as the player SEES it. Guns: the engine's steadying. The axe
	// and the sword: RSVR_MeleeTwo (melee.zs), the off grip held near them -- the engine's
	// steadying is switched off while they are in hand, so one controller still drives them.
	static bool TwoHands(PlayerPawn mo)
	{
		return mo && mo.player && (Steadied(mo) || mo.CountInv('RSVR_MeleeTwo') > 0);
	}

	// the distance between the two controllers, real cm: the engine's own steadying
	// distance (OffhandPos - AttackPos; heights are divided by pixelstretch,
	// hw_openxrdevice.cpp, so they are multiplied back)
	static double SteadyGap(PlayerPawn mo)
	{
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		if (vu <= 0)
			vu = 34;
		Vector3 w = mo.OffhandPos - mo.AttackPos;
		w.z *= ps;
		return w.Length() * 100.0 / vu;
	}
}

// 2.0.3s RSVR_HandSync -- the hands where the last FRAME put them, carried to where the BODY is now. The same class
// as RSQ_UBQSeries tools/handsync/handsync_template.zs (one copy per mod there), here under BD22 VR's prefix, with
// Now() for RSVR_VRHand.HandPos / OffPos above. Rig 2026-11-03, the owner's full load order: walking with the off-hand
// axe out whooshed (Axe/Swing) and cut (Axe/Hit, Melee/Flesh) with the hand still; the off hand's offset from the body
// read 4.75 units back and forth every other tic, a stale frame then a fresh one.
//
// THE FLAW IT FIXES (owner 2026-11-03 18:50: "strafing left and right causes the melee 'whoosh' sound to play";
// 18:58: "axe in my offhand, start moving forward and I'm hearing this swoosh sound constantly").
// QuestZDoom writes AttackPos / OffhandPos only while it RENDERS a frame (hw_openxrdevice.cpp:593-608): X/Y are the
// pawn's X/Y at that frame minus the controller's offset, Z is the frame's interpolated eye
// (r_viewpoint.CenterEyePos.Z) plus the controller's height. When two tics run with no frame between them -- any
// frame slower than a tic: a heavy load order, a hitch, the desktop test -- the second tic still holds the first
// frame's numbers while the pawn has walked on, so a hand read against the body jumps back by a whole step and
// forward again on the next frame (walking: 4.75 map units a tic each way). And the eye the frame drew from is
// interpolated, so on a stair, a landing or a lift the hand's height against the body wobbles by up to a tic of
// the view's motion. Both measured on the rig 2026-11-03 (BD22 VR's axe whooshed and cut while walking, the saber
// whooshed). Rig only, not headset-confirmed.
//
// THE FIX, two layers:
//  1. EXACT, per frame (RSQ Whip's climb and lash already do this, input.zs / whip.zs): the machine with the hands
//     measures each FRAME the controller against that same frame's pawn (flat; on PCVR the frame's eye, 2.0.3w) and
//     that frame's eye (RenderEvent.ViewPos, height) -- the controller's own offset, with nothing of the body's motion in it -- and
//     sends it when it changes. The last one before a tic is the one the tic uses. Body() + that offset is the hand.
//  2. Without a fresh one (menus, the first tics, a renderer that never calls RenderOverlay): the play-side estimate.
//     The world ticks (p_tick.cpp:168-173) run the players' input, then WorldTick, then the movers, and an item's
//     DoEffect runs inside its owner's Tick before the owner moves (p_mobj.cpp:4011 before :4344), so at the first
//     look in a tic the pawn still stands where the last frame drew it. If the hand field changed since the last
//     look a frame came in between and the pawn's position now is that frame's body; if not, the old body stands.
//
// Body(): THE BODY A SWING IS MEASURED FROM -- the pawn's X/Y and the VIEW's height. The hands hang off the view,
// and the engine moves the view against the pawn by itself (a step up lifts the pawn 8 units at once and the view
// follows over several tics; landing squats it), so a still hand read against the feet drops 8 units on a stair.
//
// USE: Fix(pmo, raw, ctrl) on a hand position read from the field ctrl (0 AttackPos, 1 OffhandPos) in PLAY code
// (a DoEffect, a WorldTick, a weapon state); anything else (a fallback, a probe's hand) comes back as it went in.
// Never in ui code: in a RenderOverlay the field is the frame's own and already right.
class RSVR_HandSync : StaticEventHandler
{
	const FRESH = 10;								// tics a per-frame offset stands without a newer one (no frames: a hitch)
	const RESEND = 2;								// an unchanged offset is sent again this often, so it stays fresh
	Vector3 off0[MAXPLAYERS], off1[MAXPLAYERS];		// layer 1: the controllers' offsets from the body, per frame
	int offAt[MAXPLAYERS];							// maptime + 1 they last arrived, 0 = never
	Vector3 raw0[MAXPLAYERS], raw1[MAXPLAYERS];		// layer 2: the fields as last seen
	Vector3 bod0[MAXPLAYERS], bod1[MAXPLAYERS];		// the pawn's position when the frame that wrote them was drawn
	double vz0[MAXPLAYERS], vz1[MAXPLAYERS];		// and the view height (viewz) it drew them from
	double vzLast[MAXPLAYERS];						// viewz at the last look
	double yw0[MAXPLAYERS], yw1[MAXPLAYERS];		// BD22 VR: the body's yaw that frame turned the offsets by
	double ywLast[MAXPLAYERS];						// the body's yaw at the last look
	int seen[MAXPLAYERS];							// maptime + 1 of the last look, 0 = never
	PlayerPawn who[MAXPLAYERS];
	ui int sent0, sent1, sentTic, sentYaw;			// the last offsets this machine sent (packed), the body's yaw then, and when
	ui bool sentAny;

	static RSVR_HandSync Get() { return RSVR_HandSync(StaticEventHandler.Find("RSVR_HandSync")); }

	override void WorldLoaded(WorldEvent e) { for (int i = 0; i < MAXPLAYERS; i++) { seen[i] = 0; offAt[i] = 0; } }

	// a look every tic, here, before anything moves the pawn
	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
			if (playeringame[i] && players[i].mo)
				Look(players[i].mo);
	}

	// LAYER 1, the sender: this frame's controllers against this frame's pawn and eye
	override void RenderOverlay(RenderEvent e)
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return;
		let mo = players[consoleplayer].mo;
		if (!mo || !mo.OverrideAttackPosDir || mo.AttackPos == mo.OffhandPos) return;
		// BD22 VR: in the BODY's frame (forward, left, up), turned back by the body's yaw this frame drew with, so a
		// snap turn is no swing: the pawn takes the turn a tic before the next frame turns the hands (rig, 2026-11-03:
		// the off hand read 13 units round the body for the one tic of a 45-degree snap, and the axe whooshed)
		// 2.0.3w: measured from what THIS renderer hung the hands on. PCVR (vr_mode 10, OpenVR) hangs them off the
		// frame's interpolated eye in X/Y as well (gl_openvr.cpp:1282 GetHandTransform: r_viewpoint.CenterEyePos, which
		// is RenderEvent.ViewPos), so against the pawn they wobbled by up to a tic of walking every frame: rig 2026-11-04,
		// the OpenVR placement emulated on 2.0.3v, his MAP01 stairs with the axe out: 21 false Axe/Swing in 8 walks, 0
		// with this. OpenXR (Quest, the rig: hw_openxrdevice.cpp:593-608) uses the pawn's X/Y, as before.
		Vector3 ref = OpenVR() ? e.ViewPos : (mo.pos.x, mo.pos.y, e.ViewPos.z);
		int a = Pack(Flat(mo.AttackPos - ref, -mo.angle));
		int b = Pack(Flat(mo.OffhandPos - ref, -mo.angle));
		if (a == 0 || b == 0) return;			// out of range: not a hand
		int yw = int(round(Actor.Normalize180(mo.angle) * 100));
		if (sentAny && a == sent0 && b == sent1 && yw == sentYaw && level.maptime - sentTic < RESEND && level.maptime >= sentTic) return;
		sent0 = a; sent1 = b; sentYaw = yw; sentAny = true; sentTic = level.maptime;
		EventHandler.SendNetworkEvent("RSVR_hs", a, b, yw);
	}

	// QuestZDoom 17.3's VR_OPENVR (hw_vrmodes.h): PCVR through SteamVR
	static ui bool OpenVR() { let c = CVar.FindCVar('vr_mode'); return c && c.GetInt() == 10; }

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "RSVR_hs")) return;	// (the engine may hand the name back in another case)
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i]) return;
		off0[i] = Unpack(e.Args[0]);
		off1[i] = Unpack(e.Args[1]);
		offAt[i] = level.maptime + 1;
	}

	// quarter units, 10 bits each plus a set bit (0 = none): +-128 every way, past any arm's reach
	static clearscope int Pack(Vector3 v)
	{
		int x = int(round(v.x * 4)), y = int(round(v.y * 4)), z = int(round(v.z * 4));
		if (abs(x) > 511 || abs(y) > 511 || abs(z) > 511) return 0;
		return (x & 0x3FF) | ((y & 0x3FF) << 10) | ((z & 0x3FF) << 20) | (1 << 30);
	}
	static clearscope Vector3 Unpack(int a)
	{
		int x = a & 0x3FF, y = (a >> 10) & 0x3FF, z = (a >> 20) & 0x3FF;
		if (x >= 512) x -= 1024;
		if (y >= 512) y -= 1024;
		if (z >= 512) z -= 1024;
		return (x / 4.0, y / 4.0, z / 4.0);
	}

	void Look(PlayerPawn mo)
	{
		if (!mo || !mo.player)
			return;
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS)
			return;
		int now = mo.Level.maptime + 1;
		if (seen[i] == now && who[i] == mo)
			return;
		bool fresh = seen[i] == 0 || who[i] != mo;
		double vzFrame = fresh ? mo.player.viewz : vzLast[i];
		double ywFrame = fresh ? mo.angle : ywLast[i];	// the players' think has already turned the pawn this tic
		if (fresh || mo.AttackPos != raw0[i]) { bod0[i] = mo.pos; vz0[i] = vzFrame; yw0[i] = ywFrame; }
		if (fresh || mo.OffhandPos != raw1[i]) { bod1[i] = mo.pos; vz1[i] = vzFrame; yw1[i] = ywFrame; }
		raw0[i] = mo.AttackPos;
		raw1[i] = mo.OffhandPos;
		vzLast[i] = mo.player.viewz;
		ywLast[i] = mo.angle;
		seen[i] = now;
		who[i] = mo;
	}

	static Vector3 Fix(Actor a, Vector3 raw, int ctrl)
	{
		let mo = PlayerPawn(a);
		if (!mo || !mo.player || raw != (ctrl == 0 ? mo.AttackPos : mo.OffhandPos))
			return raw;
		let h = Get();
		if (!h)
			return raw;
		h.Look(mo);
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS)
			return raw;
		if (h.offAt[i] > 0 && mo.Level.maptime + 1 - h.offAt[i] <= FRESH)
			return Body(mo) + Flat(ctrl == 0 ? h.off0[i] : h.off1[i], mo.angle);
		Vector3 b = ctrl == 0 ? h.bod0[i] : h.bod1[i];
		double vz = ctrl == 0 ? h.vz0[i] : h.vz1[i];
		double yw = ctrl == 0 ? h.yw0[i] : h.yw1[i];
		Vector3 d = Flat((raw.x - b.x, raw.y - b.y, raw.z - vz), mo.angle - yw);
		return (mo.pos.x + d.x, mo.pos.y + d.y, mo.player.viewz + d.z);
	}

	// RSVR_VRHand.HandPos / OffPos: the controller's field, carried to the body now
	static Vector3 Now(PlayerPawn mo, bool off)
	{
		return Fix(mo, off ? mo.OffhandPos : mo.AttackPos, off ? 1 : 0);
	}

	// turned about the vertical by deg
	static clearscope Vector3 Flat(Vector3 v, double deg)
	{
		double c = cos(deg), s = sin(deg);
		return (v.x * c - v.y * s, v.x * s + v.y * c, v.z);
	}

	static clearscope Vector3 Body(Actor a)
	{
		if (!a)
			return (0, 0, 0);
		if (!a.player)
			return a.pos;
		return (a.pos.x, a.pos.y, a.player.viewz);
	}
}
