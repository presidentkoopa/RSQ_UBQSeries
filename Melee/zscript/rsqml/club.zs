// THE GUN AS A CLUB, AND BD22 VR'S VR PUNCH (RSQ Melee, 2026-11-13; owner 01:32: "GET THE MELEE INTO RSQ MELEE ... IT IS
// CALLED RSQ MELEE NOT RSQ SOMEMELEE"). Moved here from BD22 VR Reloaded 2.0.4t, its code ported line for line, its
// numbers carried unchanged:
//   THE BUTT STRIKE   zscript/rsvr/melee.zs RSVR_Hand, kinds RIFLEBUTT..MG42BUTT (rsq_butt, rsq_butt_speed, rsvr_butt_fwd)
//   THE PISTOL WHIP   the same hand, kinds PISTOL and REVOLVER, either hand (rsq_pistol_whip, rsq_whip_speed, rsvr_melee_down)
//   THE VR PUNCH      zscript/rsq/fists.zs RSQ_FistHand on BD22's fists and the free off fist (rsq_punch, rsq_punch_use)
// Each is measured exactly as BD22 VR Reloaded measured it: the gun's own striking points on its drawn 3D model (the
// stock, the muzzle), carried from the controller through the model's placement (Place) and the r12 FBX-hand move
// (RSQML_ClubMove), differenced in the BODY's frame from a stamped pose history (RSQML_ClubPose: BD22 VR's RSQ_Pose spine)
// and a per-frame hand sync (RSQML_ClubSync: BD22 VR's RSVR_HandSync, with its yaw). Same speeds, same thresholds, same
// envelopes, same attack actors by name (KickAttack / SuperKickAttack, MeleeStrikeNormal / MeleeStrike1Berserked,
// AxeAttack into a wall), same swing sound and wait, same controller buzz (a player missile on the weapon hand, through
// RSQ Accessibility's Rumble Backup when it is on).
//
// WHEN IT RUNS. Only with BD22 VR Reloaded 2.0.4u or later loaded: those gun models, their sprites and their placement
// are that pack's. It is found by NAME at run time (RSVR_MeleeHandler, and RSVR_MeleeYield, the class that says that
// pack hands these moves over); nothing is linked, and RSQ Melee loads and plays alone. That pack asks RSQ Melee by
// name too (RSQML_Service "owns" "club" / "punch", service.zs) and its own butt strike, pistol whip and VR punch then
// stand down. Without RSQ Melee it keeps its own. An older BD22 VR Reloaded (no RSVR_MeleeYield) keeps its own as before
// and RSQ Melee leaves it alone (shove.zs: stand down and watch, as before 2026-11-13).
//
// WHAT RSQ MELEE ADDS ON TOP (not feel): the blow is named the shove for RSQ Score first ("shove", as the gun-butt shove
// is), a landed butt strike asks RSQ SlowMo for the shove's slow-mo pulse (rsqml_shove_slowmo, opening the F.E.A.R.
// window), and Gun Bonsai VR's Pistol Whip / Rifle Butt read the KickAttack's damage as they did (shove.zs).
//
// THE SETTINGS were BD22 VR Reloaded's user rows. On the first map with both packs loaded their values are copied into
// RSQ Melee's own (Migrate, once: rsqml_club_migrated), so what the owner tuned carries over.

// ---- the hand sync (BD22 VR Reloaded rsvr/vrhand.zs RSVR_HandSync, 2.0.3s/2.0.3w, ported under RSQ Melee's prefix) ----
// QuestZDoom writes AttackPos / OffhandPos only while it renders a frame; this carries the frame's hands to where the body
// is this tic, in the BODY's frame (turned back by the yaw the frame drew with, so a snap turn is no swing). The full
// story is in that file and in handsync.zs. Sends only while the club runs (RSQML_Club.On).
class RSQML_ClubSync : StaticEventHandler
{
	const FRESH = 10;
	const RESEND = 2;
	Vector3 off0[MAXPLAYERS], off1[MAXPLAYERS];
	int offAt[MAXPLAYERS];
	Vector3 raw0[MAXPLAYERS], raw1[MAXPLAYERS];
	Vector3 bod0[MAXPLAYERS], bod1[MAXPLAYERS];
	double vz0[MAXPLAYERS], vz1[MAXPLAYERS];
	double vzLast[MAXPLAYERS];
	double yw0[MAXPLAYERS], yw1[MAXPLAYERS];
	double ywLast[MAXPLAYERS];
	int seen[MAXPLAYERS];
	PlayerPawn who[MAXPLAYERS];
	bool on;										// RSQML_Club.On(), refreshed in play (ui reads it)
	ui int sent0, sent1, sentTic, sentYaw;
	ui bool sentAny;

	static RSQML_ClubSync Get() { return RSQML_ClubSync(StaticEventHandler.Find("RSQML_ClubSync")); }

	override void WorldLoaded(WorldEvent e) { for (int i = 0; i < MAXPLAYERS; i++) { seen[i] = 0; offAt[i] = 0; } on = RSQML_Club.On(); }

	override void WorldTick()
	{
		on = RSQML_Club.On();
		if (!on) return;
		for (int i = 0; i < MAXPLAYERS; i++)
			if (playeringame[i] && players[i].mo)
				Look(players[i].mo);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (!on) return;
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return;
		let mo = players[consoleplayer].mo;
		if (!mo || !mo.OverrideAttackPosDir || mo.AttackPos == mo.OffhandPos) return;
		Vector3 ref = OpenVR() ? e.ViewPos : (mo.pos.x, mo.pos.y, e.ViewPos.z);
		int a = Pack(Flat(mo.AttackPos - ref, -mo.angle));
		int b = Pack(Flat(mo.OffhandPos - ref, -mo.angle));
		if (a == 0 || b == 0) return;
		int yw = int(round(Actor.Normalize180(mo.angle) * 100));
		if (sentAny && a == sent0 && b == sent1 && yw == sentYaw && level.maptime - sentTic < RESEND && level.maptime >= sentTic) return;
		sent0 = a; sent1 = b; sentYaw = yw; sentAny = true; sentTic = level.maptime;
		EventHandler.SendNetworkEvent("RSQML_cs", a, b, yw);
	}

	static ui bool OpenVR() { let c = CVar.FindCVar('vr_mode'); return c && c.GetInt() == 10; }

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "RSQML_cs")) return;
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i]) return;
		off0[i] = Unpack(e.Args[0]);
		off1[i] = Unpack(e.Args[1]);
		offAt[i] = level.maptime + 1;
	}

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
		if (!mo || !mo.player) return;
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS) return;
		int now = mo.Level.maptime + 1;
		if (seen[i] == now && who[i] == mo) return;
		bool fresh = seen[i] == 0 || who[i] != mo;
		double vzFrame = fresh ? mo.player.viewz : vzLast[i];
		double ywFrame = fresh ? mo.angle : ywLast[i];
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
		if (!mo || !mo.player || raw != (ctrl == 0 ? mo.AttackPos : mo.OffhandPos)) return raw;
		let h = Get();
		if (!h) return raw;
		h.Look(mo);
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS) return raw;
		if (h.offAt[i] > 0 && mo.Level.maptime + 1 - h.offAt[i] <= FRESH)
			return Body(mo) + Flat(ctrl == 0 ? h.off0[i] : h.off1[i], mo.angle);
		Vector3 b = ctrl == 0 ? h.bod0[i] : h.bod1[i];
		double vz = ctrl == 0 ? h.vz0[i] : h.vz1[i];
		double yw = ctrl == 0 ? h.yw0[i] : h.yw1[i];
		Vector3 d = Flat((raw.x - b.x, raw.y - b.y, raw.z - vz), mo.angle - yw);
		return (mo.pos.x + d.x, mo.pos.y + d.y, mo.player.viewz + d.z);
	}

	static Vector3 Now(PlayerPawn mo, bool off) { return Fix(mo, off ? mo.OffhandPos : mo.AttackPos, off ? 1 : 0); }

	static clearscope Vector3 Flat(Vector3 v, double deg)
	{
		double c = cos(deg), s = sin(deg);
		return (v.x * c - v.y * s, v.x * s + v.y * c, v.z);
	}

	static clearscope Vector3 Body(Actor a)
	{
		if (!a) return (0, 0, 0);
		if (!a.player) return a.pos;
		return (a.pos.x, a.pos.y, a.player.viewz);
	}
}

// ---- the controllers (BD22 VR Reloaded rsvr/vrhand.zs RSVR_VRHand, the parts the club reads) ----
class RSQML_ClubVR play
{
	static bool InVR(PlayerPawn mo) { return mo && mo.player && mo.player.PlayInVR && mo.OverrideAttackPosDir; }
	static Vector3 HandPos(PlayerPawn mo) { return RSQML_ClubSync.Now(mo, false); }
	static Vector3 OffPos(PlayerPawn mo) { return RSQML_ClubSync.Now(mo, true); }

	// a direction in the controller's frame (yaw 0 pitch 0 forward, yaw 90 left), the vertical squash taken back out.
	// The engine sets the pointer behind AttackDir / OffhandDir only while it renders: never called before that.
	static Vector3 HandDir(PlayerPawn mo, double yaw, double pitch, double ps)
	{
		Vector3 ap = mo.OverrideAttackPosDir ? mo.AttackDir(mo, mo.angle + yaw, mo.pitch + pitch) : (mo.angle + yaw, mo.pitch + pitch, 0);
		double cp = cos(ap.y);
		Vector3 v = (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y) * ps);
		double l = v.Length();
		return l <= 0 ? (1, 0, 0) : v / l;
	}
	static Vector3 OffDir(PlayerPawn mo, double yaw, double pitch, double ps)
	{
		Vector3 ap = mo.OverrideAttackPosDir ? mo.OffhandDir(mo, mo.angle + yaw, mo.pitch + pitch) : (mo.angle + yaw, mo.pitch + pitch, 0);
		double cp = cos(ap.y);
		Vector3 v = (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y) * ps);
		double l = v.Length();
		return l <= 0 ? (1, 0, 0) : v / l;
	}
	// the engine steadying the gun with both hands (p_pspr.cpp sets the flag)
	static bool Steadied(PlayerPawn mo) { return (mo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0; }
}

// ---- the pose spine (BD22 VR Reloaded rsq/pose.zs RSQ_Pose / RSQ_PoseNet / RSQ_PoseHandler, ported) ----
// A per-player, per-hand history fed once a tic by a network event from the console player and read ONLY from the history,
// on every machine including the sender's: dt-correct velocities, each sample with the body pose it came with.
class RSQML_ClubPose play
{
	const N = 8;
	const MAIN = 0;
	const OFF = 1;
	Vector3 pos[8];
	Vector3 bod[8];
	double byaw[8];
	int stamp[8];
	Vector3 F, L, U;
	bool left;
	int buttons;
	int count;

	void Push(Vector3 p, Vector3 body, double bodyYaw, double yaw, double pitch, double roll, int btn, int now)
	{
		for (int k = N - 1; k > 0; k--) { pos[k] = pos[k - 1]; stamp[k] = stamp[k - 1]; bod[k] = bod[k - 1]; byaw[k] = byaw[k - 1]; }
		pos[0] = p; stamp[0] = now; bod[0] = body; byaw[0] = bodyYaw;
		// built in place: three Vector3 returns come back zeroed on this VM
		double cp = cos(pitch);
		F.x = cp * cos(yaw); F.y = cp * sin(yaw); F.z = sin(pitch);
		double l0x = cos(yaw + 90), l0y = sin(yaw + 90), l0z = 0;
		double u0x = F.y * l0z - F.z * l0y;
		double u0y = F.z * l0x - F.x * l0z;
		double u0z = F.x * l0y - F.y * l0x;
		double cr = cos(roll), sr = sin(roll);
		L.x = l0x * cr + u0x * sr; L.y = l0y * cr + u0y * sr; L.z = l0z * cr + u0z * sr;
		U.x = u0x * cr - l0x * sr; U.y = u0y * cr - l0y * sr; U.z = u0z * cr - l0z * sr;
		buttons = btn;
		if (count < N) count++;
	}

	clearscope bool Fresh(int now) const { return count > 0 && now - stamp[0] <= 3; }
}

class RSQML_ClubPoseNet abstract play
{
	static clearscope int ClampI(int v, int lo, int hi) { return v < lo ? lo : (v > hi ? hi : v); }
	static clearscope int PackPos(Vector3 rel)
	{
		int x = ClampI(int(round(rel.x * 4)), -1024, 1023) & 0x7FF;
		int y = ClampI(int(round(rel.y * 4)), -1024, 1023) & 0x7FF;
		int z = ClampI(int(round(rel.z * 4)), -512, 511) & 0x3FF;
		return x | (y << 11) | (z << 22);
	}
	static clearscope Vector3 UnpackPos(int a)
	{
		int x = a & 0x7FF; if (x >= 1024) x -= 2048;
		int y = (a >> 11) & 0x7FF; if (y >= 1024) y -= 2048;
		int z = (a >> 22) & 0x3FF; if (z >= 512) z -= 1024;
		return (x / 4.0, y / 4.0, z / 4.0);
	}
	static clearscope int PackAng(double yaw, double pitch, double roll, int btn)
	{
		int iy = ClampI(int(round((yaw % 360.0 + 360.0) % 360.0 / 360.0 * 1023.0)), 0, 1023);
		int ip = ClampI(int(round((pitch + 90.0) / 180.0 * 1023.0)), 0, 1023);
		int ir = ClampI(int(round(((roll + 180.0) % 360.0 + 360.0) % 360.0 / 360.0 * 1023.0)), 0, 1023);
		return iy | (ip << 10) | (ir << 20) | ((btn & 3) << 30);
	}
	static clearscope double, double, double, int UnpackAng(int a)
	{
		double yaw = (a & 0x3FF) / 1023.0 * 360.0;
		double pitch = ((a >> 10) & 0x3FF) / 1023.0 * 180.0 - 90.0;
		double roll = ((a >> 20) & 0x3FF) / 1023.0 * 360.0 - 180.0;
		int btn = (a >> 30) & 3;
		return yaw, pitch, roll, btn;
	}
	static clearscope double RollOf(Vector3 F, Vector3 Lreal)
	{
		double yaw = atan2(F.y, F.x);
		Vector3 L0 = (cos(yaw + 90), sin(yaw + 90), 0);
		Vector3 U0 = (F.y * L0.z - F.z * L0.y, F.z * L0.x - F.x * L0.z, F.x * L0.y - F.y * L0.x);
		return atan2(Lreal dot U0, Lreal dot L0);
	}
}

// ---- THE CLUB: the poses, the hands, the punch, the settings ----------------------------------------------------------
class RSQML_Club : StaticEventHandler
{
	RSQML_ClubPose poseMain[MAXPLAYERS];
	RSQML_ClubPose poseOff[MAXPLAYERS];
	RSQML_ClubHand hands[MAXPLAYERS];
	RSQML_ClubHand offHands[MAXPLAYERS];
	RSQML_BDPunch punchMain[MAXPLAYERS];
	RSQML_BDPunch punchOff[MAXPLAYERS];
	bool wasOn;

	static RSQML_Club Get() { return RSQML_Club(StaticEventHandler.Find("RSQML_Club")); }

	// BD22 VR Reloaded is loaded AND hands these moves over (2.0.4u and later: RSVR_MeleeYield). Class names through a
	// String, so nothing is linked.
	// Brutal Doom too (BrutalWeapon): the weapon sets carry BD22 VR's hands under its class names but not its guns, and
	// with them RSQ Melee's own shove is the one (shove.zs BD22QLoaded, owner 2026-11-13)
	static clearscope bool On()
	{
		return Object.FindClass("BrutalWeapon") != null && Object.FindClass("RSVR_MeleeHandler") != null
			&& Object.FindClass("RSVR_MeleeYield") != null;
	}

	static clearscope int UserI(PlayerPawn mo, Name n, int def)
	{
		let cv = mo && mo.player ? CVar.GetCVar(n, mo.player) : CVar.FindCVar(n);
		return cv ? cv.GetInt() : def;
	}
	static clearscope double UserF(PlayerPawn mo, Name n, double def)
	{
		let cv = mo && mo.player ? CVar.GetCVar(n, mo.player) : CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	override void OnRegister()
	{
		for (int i = 0; i < MAXPLAYERS; i++) { poseMain[i] = new('RSQML_ClubPose'); poseOff[i] = new('RSQML_ClubPose'); }
	}

	static RSQML_ClubPose PoseOf(PlayerPawn mo, int hand)
	{
		let h = Get();
		if (!h || !mo || !mo.player) return null;
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS) return null;
		return hand == RSQML_ClubPose.OFF ? h.poseOff[i] : h.poseMain[i];
	}

	override void WorldLoaded(WorldEvent e)
	{
		wasOn = On();
		if (wasOn) Migrate();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (hands[n]) { hands[n].Reset(); hands[n].kind = 0; }
			if (offHands[n]) { offHands[n].Reset(); offHands[n].kind = 0; }
			if (punchMain[n]) { punchMain[n].count = 0; punchMain[n].ready = false; }
			if (punchOff[n]) { punchOff[n].count = 0; punchOff[n].ready = false; }
		}
		if (wasOn && RSQML.Debug() >= 1)
			Console.Printf("\c[Gold]rsqml club: BD22 VR Reloaded hands over its butt strike, pistol whip and VR punch: RSQ Melee does them (t%d)", level.maptime);
	}

	// THE OWNER'S BD22 VR SETTINGS, carried over once (the first map with both packs loaded). User cvars: this machine's.
	static void Migrate()
	{
		let flag = CVar.FindCVar("rsqml_club_migrated");
		if (!flag || flag.GetInt() != 0) return;
		String said = "";
		said = said .. CopyI("rsq_butt", "rsqml_butt");
		said = said .. CopyF("rsq_butt_speed", "rsqml_butt_speed");
		said = said .. CopyF("rsvr_butt_fwd", "rsqml_butt_fwd");
		said = said .. CopyI("rsq_pistol_whip", "rsqml_pistol_whip");
		said = said .. CopyF("rsq_whip_speed", "rsqml_whip_speed");
		said = said .. CopyF("rsvr_melee_down", "rsqml_whip_down");
		said = said .. CopyF("rsvr_melee_swing", "rsqml_club_swing");
		said = said .. CopyI("rsq_punch", "rsqml_bd_punch");
		said = said .. CopyI("rsq_punch_use", "rsqml_punch_use");
		flag.SetInt(1);
		Console.Printf("\c[Gold]rsqml club: BD22 VR Reloaded's settings carried into RSQ Melee (once):%s", said);
	}
	static String CopyI(String from, String to)
	{
		let a = CVar.FindCVar(from), b = CVar.FindCVar(to);
		if (!a || !b) return "";
		b.SetInt(a.GetInt());
		return String.Format(" %s=%d", to, a.GetInt());
	}
	static String CopyF(String from, String to)
	{
		let a = CVar.FindCVar(from), b = CVar.FindCVar(to);
		if (!a || !b) return "";
		b.SetFloat(a.GetFloat());
		return String.Format(" %s=%.2f", to, a.GetFloat());
	}

	// THE POSE EVENTS: every peer, the sender too
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqml-cpose") return;
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i] || !players[i].mo) return;
		let mo = players[i].mo;
		double yaw, pitch, roll;
		int btn;
		[yaw, pitch, roll, btn] = RSQML_ClubPoseNet.UnpackAng(e.Args[1]);
		int hand = e.Args[2] & 1;
		let p = hand == RSQML_ClubPose.OFF ? poseOff[i] : poseMain[i];
		if (!p) return;
		Vector3 bodyNow = RSQML_ClubSync.Body(mo);
		p.Push(bodyNow + RSQML_ClubPoseNet.UnpackPos(e.Args[0]), bodyNow, mo.angle, yaw, pitch, roll, btn, level.maptime);
		p.left = (e.Args[2] & 2) != 0;
	}

	override void WorldTick()
	{
		bool on = On();
		if (on != wasOn)
		{
			wasOn = on;
			if (on) Migrate();
		}
		if (!on) return;
		SendPose();
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let mo = players[i].mo;
			if (!hands[i]) hands[i] = new('RSQML_ClubHand');
			if (!offHands[i]) { offHands[i] = new('RSQML_ClubHand'); offHands[i].off = true; }
			hands[i].Tick(mo);
			offHands[i].Tick(mo);
			Punches(mo, i);
		}
	}

	// the sender, this machine's console player only (play scope: HandDir / OffDir are play)
	void SendPose()
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p ? PlayerPawn(p.mo) : null;
		if (!mo || !RSQML_ClubVR.InVR(mo)) return;
		double ps = mo.Level.pixelstretch;
		if (ps <= 0) ps = 1.2;
		int btn = ((p.cmd.buttons & BT_ATTACK) != 0 ? 1 : 0) | ((p.cmd.buttons & BT_ALTATTACK) != 0 ? 2 : 0);
		let cv = CVar.FindCVar('vr_control_scheme');
		int lh = (cv && cv.GetInt() >= 10) ? 2 : 0;
		Send(mo, RSQML_ClubVR.HandPos(mo), RSQML_ClubVR.HandDir(mo, 0, 0, ps), RSQML_ClubVR.HandDir(mo, 90, 0, ps), btn, RSQML_ClubPose.MAIN | lh);
		Send(mo, RSQML_ClubVR.OffPos(mo), RSQML_ClubVR.OffDir(mo, 0, 0, ps), RSQML_ClubVR.OffDir(mo, 90, 0, ps), btn, RSQML_ClubPose.OFF | lh);
	}
	void Send(PlayerPawn mo, Vector3 hand, Vector3 F, Vector3 Lreal, int btn, int flags)
	{
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		double roll = RSQML_ClubPoseNet.RollOf(F, Lreal);
		EventHandler.SendNetworkEvent("rsqml-cpose", RSQML_ClubPoseNet.PackPos(hand - RSQML_ClubSync.Body(mo)),
			RSQML_ClubPoseNet.PackAng(yaw, pitch, roll, btn), flags);
	}

	// BD22 VR's VR PUNCH (fists.zs RSQ_Fists.WorldTick): BD22's fists in the main hand (the class Melee_Attacks itself) and
	// the free off fist (RSQ_Hands on its closed-hand layer), VR Punching on, alive and in VR
	void Punches(PlayerPawn mo, int n)
	{
		let p = mo.player;
		if (!punchMain[n]) { punchMain[n] = new('RSQML_BDPunch'); punchMain[n].handIdx = 0; }
		if (!punchOff[n]) { punchOff[n] = new('RSQML_BDPunch'); punchOff[n].handIdx = 1; }
		bool vr = RSQML_ClubVR.InVR(mo) && p.playerstate == PST_LIVE && mo.health > 0 && UserI(mo, 'rsqml_bd_punch', 0) != 0;
		class<Inventory> mc = (class<Inventory>)(RSQML_ClubHand.Cls('Melee_Attacks'));
		let fw = mc ? Weapon(mo.FindInventory(mc)) : null;
		bool mainFist = vr && p.ReadyWeapon && fw && p.ReadyWeapon == fw;
		bool offFist = vr && OffFist(mo);
		punchMain[n].Tick(mo, RSQML_ClubVR.HandPos(mo), mainFist);
		punchOff[n].Tick(mo, RSQML_ClubVR.OffPos(mo), offFist);
	}
	// BD22 VR's RSQ_Hands.OffFist: its off-hand weapon, in the off hand, on its free closed hand ("AmmoH" on the free-hand
	// layer 2200: the state its freeFist is set from), read off the psprite because the field cannot be read unlinked
	static bool OffFist(PlayerPawn mo)
	{
		let w = mo.player.OffhandWeapon;
		if (!w || w.GetClassName() != 'RSQ_Hands') return false;
		let psp = mo.player.FindPSprite(RSQML_Gloves.BD22_FREEHAND);
		State closed = w.FindState("AmmoH");
		return psp && psp.Caller == w && closed && psp.CurState == closed;
	}
}

// ---- THE GUN AS A CLUB: one hand (BD22 VR Reloaded rsvr/melee.zs RSVR_Hand, the butt strike and the pistol whip) ----
class RSQML_ClubHand play
{
	const HIST = 6;
	const PISTOL = 3;
	const REVOLVER = 4;
	const RIFLEBUTT = 5;
	const SGBUTT = 6;
	const SSGBUTT = 7;
	const ASGBUTT = 8;
	const MP40BUTT = 9;
	const SMGBUTT = 10;
	const MGBUTT = 11;
	const MG42BUTT = 12;
	// the butt's reach ahead of the stock and its pad (BD22 VR 2.0.3y: 90 and 16, BD22's kick envelope widened), the
	// muzzle's lead the butt may not exceed (it is leading, not the butt), and a whip's reach for a switch past the gun
	const BUTT_REACH = 90.0;
	const BUTT_PAD = 16.0;
	const BUTT_LEAD = 1.25;
	const WHIP_USE = 30.0;

	double tx[HIST], ty[HIST], tz[HIST];
	double px[HIST], py[HIST], pz[HIST];
	int count, head;
	int kind;
	bool off;
	bool havePrev;
	Vector3 prevIn, prevH, prevOut, prevPos, prevRel, prevRelIn;
	int prevStamp;
	int poseFrame, placeK, lastPoseFrame;
	int swingTics, calmTics, whooshWait, scrapeWait;
	bool usedLine;
	bool pulsed;			// RSQ Melee: this swing has asked RSQ SlowMo for its pulse already
	bool inWall;
	Array<Actor> struck;

	transient Vector3 fH, pBod, fF, fR, fU;
	transient double pByaw, vu, ws, ox, oy, oz, ps;
	transient int pStamp;
	transient bool spritesSet;
	transient SpriteID sRIFG, s2IFG, sRI2G, sSHTN, s2HTN, sSHTA, sVSSG, sSHT2, sVSHZ, sUSAS, s2SAS, sA12P;
	transient SpriteID sMP40, sMP42, sPP40, sSMGF, sSMGR, sVSMG, sMGN1, sHBUS, sPBUS, sPIST, s2IST, sREVO, s2EVO, sRVMA;

	static class<Actor> Cls(Name n) { class<Actor> c = n; return c; }

	// the gun's striking points, in the held model's own units (BD22 VR's posefix measurements, melee.zs BladeIn / BladeOut)
	static Vector3 BladeIn(int k)
	{
		if (k == RIFLEBUTT) return (25.1, 0.1, 6.3);	// Rifle.md3 frame 3, toward the muzzle
		if (k == SGBUTT) return (23.7, 0.0, -5.4);		// ShotGun.md3 frame 4
		if (k == SSGBUTT) return (27.9, 0.1, -2.8);		// SSG.md3 frame 1
		if (k == ASGBUTT) return (20.0, 0.0, -2.6);		// AssaultShotgun.md3 frame 4
		if (k == MP40BUTT) return (24.8, 0.2, -3.1);	// MP40.md3 frame 2
		if (k == SMGBUTT) return (18.6, -0.3, -1.2);	// BrutalSMG.md3 frame 3
		if (k == MGBUTT) return (20.1, 0.0, 4.3);		// Machinegun.md3 frame 4, surface M249_lowpoly
		if (k == MG42BUTT) return (21.6, -1.0, 1.2);	// HitlersBuzzsaw.md3 frame 0
		if (k == PISTOL) return (26.2, 0.0, -7.0);		// BrutalPistol.md3 frame 3, just forward of the hand
		if (k == REVOLVER) return (29.4, 0.1, -1.5);	// Revolver.md3 frame 0, just forward of the hand
		return (0, 0, 0);
	}
	static Vector3 BladeOut(int k)
	{
		if (k == RIFLEBUTT) return (2.5, 0.5, -1.0);	// the butt
		if (k == SGBUTT) return (0.9, 0.0, -10.7);
		if (k == SSGBUTT) return (15.3, 0.1, -7.0);
		if (k == ASGBUTT) return (-1.7, 0.0, -6.0);
		if (k == MP40BUTT) return (-1.2, 0.0, -3.5);
		if (k == SMGBUTT) return (0.6, 0.0, -10.4);
		if (k == MGBUTT) return (-1.4, 0.0, 2.0);
		if (k == MG42BUTT) return (-10.8, -0.1, 1.6);
		if (k == PISTOL) return (44.2, 0.0, -0.2);		// the muzzle
		if (k == REVOLVER) return (50.2, 0.0, 2.4);		// the muzzle
		return (0, 0, 0);
	}

	void InitSprites()
	{
		sRIFG = Actor.GetSpriteIndex('RIFG'); s2IFG = Actor.GetSpriteIndex('2IFG'); sRI2G = Actor.GetSpriteIndex('RI2G');
		sSHTN = Actor.GetSpriteIndex('SHTN'); s2HTN = Actor.GetSpriteIndex('2HTN'); sSHTA = Actor.GetSpriteIndex('SHTA');
		sVSSG = Actor.GetSpriteIndex('VSSG'); sSHT2 = Actor.GetSpriteIndex('SHT2'); sVSHZ = Actor.GetSpriteIndex('VSHZ');
		sUSAS = Actor.GetSpriteIndex('USAS'); s2SAS = Actor.GetSpriteIndex('2SAS'); sA12P = Actor.GetSpriteIndex('A12P');
		sMP40 = Actor.GetSpriteIndex('MP40'); sMP42 = Actor.GetSpriteIndex('MP42'); sPP40 = Actor.GetSpriteIndex('PP40');
		sSMGF = Actor.GetSpriteIndex('SMGF'); sSMGR = Actor.GetSpriteIndex('SMGR'); sVSMG = Actor.GetSpriteIndex('VSMG');
		sMGN1 = Actor.GetSpriteIndex('MGN1'); sHBUS = Actor.GetSpriteIndex('HBUS'); sPBUS = Actor.GetSpriteIndex('PBUS');
		sPIST = Actor.GetSpriteIndex('PIST'); s2IST = Actor.GetSpriteIndex('2IST');
		sREVO = Actor.GetSpriteIndex('REVO'); s2EVO = Actor.GetSpriteIndex('2EVO'); sRVMA = Actor.GetSpriteIndex('RVMA');
		spritesSet = true;
	}

	static bool IsButt(int k) { return k >= RIFLEBUTT && k <= MG42BUTT; }

	// WHAT THE MAIN HAND SWINGS (melee.zs KindOf, its gun kinds): the butt strike with Two-Handed Butt Strike on, the
	// pistol whip with Pistol Whip on
	static int KindOf(PlayerPawn mo)
	{
		let p = mo.player;
		if (!p || !p.ReadyWeapon || p.PendingWeapon != WP_NOCHANGE || mo.health <= 0) return 0;
		Name n = p.ReadyWeapon.GetClassName();
		if (RSQML_Club.UserI(mo, 'rsqml_butt', 0) != 0)
		{
			if (n == 'Rifle') return RIFLEBUTT;
			if (n == 'Shot_Gun') return SGBUTT;
			if (n == 'SSG') return SSGBUTT;
			if (n == 'AssaultShotgun') return ASGBUTT;
			if (n == 'MP40') return MP40BUTT;
			if (n == 'BrutalSMG') return SMGBUTT;
			if (n == 'Machinegun') return MGBUTT;
			if (n == 'MG42') return MG42BUTT;
		}
		if (RSQML_Club.UserI(mo, 'rsqml_pistol_whip', 1) == 0) return 0;
		if (n == 'BrutalPistol') return PISTOL;
		if (n == 'Revolver') return REVOLVER;
		if (n == 'BrutalRevolver') return REVOLVER;	// the Moonlight whips with the Revolver's points (BD22 VR 2.0.2)
		return 0;
	}
	// the OFF hand: a pistol or revolver whips there too (BD22 VR 2.0.3y; its off-hand versions and, for a moment before
	// the swap, the main ones)
	static int KindOfOff(PlayerPawn mo)
	{
		let p = mo.player;
		if (!p || !p.OffhandWeapon || mo.health <= 0) return 0;
		if (RSQML_Club.UserI(mo, 'rsqml_pistol_whip', 1) == 0) return 0;
		Name n = p.OffhandWeapon.GetClassName();
		if (n == 'RSQ_Off_BrutalPistol' || n == 'BrutalPistol') return PISTOL;
		if (n == 'RSQ_Off_Revolver' || n == 'Revolver' || n == 'RSQ_Off_BrutalRevolver' || n == 'BrutalRevolver') return REVOLVER;
		return 0;
	}
	int KindFor(PlayerPawn mo) { return off ? KindOfOff(mo) : KindOf(mo); }

	// the gun in its held pose: its striking points are where the model shows them (melee.zs ReadyPose)
	bool ReadyPose(PlayerPawn mo, int k)
	{
		if (!spritesSet) InitSprites();
		let psp = mo.player.FindPSprite(off ? PSP_OFFHANDWEAPON : PSP_WEAPON);
		if (!psp) return false;
		SpriteID s = psp.Sprite;
		poseFrame = 0;
		placeK = k;
		// BrutalPistol's Ready holds PIST E (loaded), PIST I (empty) or 2IST E; MODELDEF binds them to model frames 7 and 3,
		// which put the whip points within 0.1 unit of each other
		if (k == PISTOL)
			return (s == sPIST && (psp.Frame == 0 || psp.Frame == 4 || psp.Frame == 8)) || (s == s2IST && (psp.Frame == 0 || psp.Frame == 4));
		if (psp.Frame != 0) return false;
		if (k == RIFLEBUTT) return s == sRIFG || s == s2IFG || s == sRI2G;
		if (k == SGBUTT) return s == sSHTN || s == s2HTN || s == sSHTA;
		if (k == SSGBUTT) return s == sVSSG || s == sSHT2 || s == sVSHZ;
		if (k == ASGBUTT) return s == sUSAS || s == s2SAS || s == sA12P;
		if (k == MP40BUTT) return s == sMP40 || s == sMP42 || s == sPP40;
		if (k == SMGBUTT) return s == sSMGF || s == sSMGR || s == sVSMG;
		if (k == MGBUTT) return s == sMGN1;
		if (k == MG42BUTT) return s == sHBUS || s == sPBUS;
		if (k == REVOLVER) return s == sREVO || s == s2EVO || s == sRVMA;
		return false;
	}

	static double CVarF(Name n, double def) { let cv = CVar.FindCVar(n); return cv ? cv.GetFloat() : def; }

	// the hand out of the pose history, with the body pose recorded WITH that sample (melee.zs Frame)
	bool Frame(PlayerPawn mo)
	{
		let ph = RSQML_Club.PoseOf(mo, off ? RSQML_ClubPose.OFF : RSQML_ClubPose.MAIN);
		if (!ph || !ph.Fresh(mo.Level.maptime)) return false;
		ps = mo.Level.pixelstretch;
		if (ps <= 0) ps = 1.2;
		fH = ph.pos[0];
		fF = ph.F;
		fR = -ph.L;
		fU = off ? -ph.U : ph.U;	// the off frame arrives mirrored (BD22 VR 2.0.3q)
		pBod = ph.bod[0];
		pByaw = ph.byaw[0];
		pStamp = ph.stamp[0];
		vu = CVarF('vr_vunits_per_meter', 34);
		ws = CVarF('vr_weaponScale', 1.02);
		ox = CVarF('vr_3dweaponOffsetX', 0);
		oy = CVarF('vr_3dweaponOffsetY', 0);
		oz = CVarF('vr_3dweaponOffsetZ', 0);
		return true;
	}

	// a point of the held model -> world, the chain RenderHUDModel draws it with (melee.zs Place), then the gun's move to
	// the fitted FBX hand (RSQML_ClubMove)
	Vector3 Place(Vector3 m)
	{
		double f = 0.01 * (ws * m.x - 30 - oz);
		double r = 0.01 * (-ws * m.y + ox);
		double u = 0.01 * (ws * m.z + oy);
		Vector3 mv = RSQML_ClubMove.Apply(placeK, poseFrame, (100 * f, -100 * r, 100 * u));
		f = 0.01 * mv.x;
		r = -0.01 * mv.y;
		u = 0.01 * mv.z;
		Vector3 w = fF * f + fR * r + fU * u;
		w.z /= ps;
		return fH + w * vu;
	}

	void Push(Vector3 tip, Vector3 pos)
	{
		head = (head + 1) % HIST;
		tx[head] = tip.x; ty[head] = tip.y; tz[head] = tip.z;
		px[head] = pos.x; py[head] = pos.y; pz[head] = pos.z;
		if (count < HIST) count++;
	}

	void Reset()
	{
		count = 0;
		havePrev = false;
		prevStamp = 0;
		swingTics = 0;
		calmTics = 0;
		inWall = false;
		usedLine = false;
		pulsed = false;
		struck.Clear();
	}

	// a world point in the body's own frame (forward, left, up), against the body pose that came WITH the sample
	Vector3 BodyFrame(PlayerPawn mo, Vector3 p)
	{
		Vector3 d = p - pBod;
		double c = cos(pByaw), s = sin(pByaw);
		return (d.x * c + d.y * s, -d.x * s + d.y * c, d.z);
	}

	void Tick(PlayerPawn mo)
	{
		if (whooshWait > 0) whooshWait--;
		if (scrapeWait > 0) scrapeWait--;
		int k = KindFor(mo);
		if (k != kind)
		{
			Reset();
			kind = k;
			if (k != 0 && RSQML.Debug() >= 1)
				Console.Printf("\c[Gold]rsqml club: %s %s in the %s hand (t%d)", IsButt(k) ? "butt strike ready," : "pistol whip ready,",
					off ? mo.player.OffhandWeapon.GetClassName() : mo.player.ReadyWeapon.GetClassName(), off ? "off" : "main", level.maptime);
		}
		if (k == 0 || !ReadyPose(mo, k) || !Frame(mo))
		{
			Reset();
			return;
		}
		if (poseFrame != lastPoseFrame)
		{
			lastPoseFrame = poseFrame;
			Reset();
			return;
		}
		Vector3 bin = Place(BladeIn(k));
		Vector3 bout = Place(BladeOut(k));
		Push(bout, mo.pos);
		if (!havePrev)
		{
			prevIn = bin; prevH = fH;
			prevOut = bout;
			prevPos = mo.pos;
			prevRel = BodyFrame(mo, bout);
			prevRelIn = BodyFrame(mo, bin);
			prevStamp = pStamp;
			havePrev = true;
			return;
		}

		bool isButt = IsButt(k);
		// the speed a blow needs, at the striking end (m/s -> map units a tic): Butt Strike / Pistol Whip: Swing Needed,
		// times Gun Club Swing Strength (BD22 VR's Melee swing strength)
		double thr = (isButt ? clamp(RSQML_Club.UserF(mo, 'rsqml_butt_speed', 2.4), 1.0, 8.0)
			: clamp(RSQML_Club.UserF(mo, 'rsqml_whip_speed', 5.0), 1.0, 12.0)) * vu / 35.
			* max(0.2, RSQML_Club.UserF(mo, 'rsqml_club_swing', 1.0));
		int gap = max(1, pStamp - prevStamp);
		Vector3 rel = BodyFrame(mo, bout);
		Vector3 vel = (rel - prevRel) / gap;
		prevRel = rel;
		Vector3 relIn = BodyFrame(mo, bin);
		Vector3 velIn = (relIn - prevRelIn) / gap;
		prevRelIn = relIn;
		prevStamp = pStamp;
		double speed = vel.Length();
		double power = speed / thr;

		// the whip must point DOWN by Pistol Whip: Must Swing Down of its speed (BD22 VR's rsvr_melee_down, 0.25)
		double rise = speed > 0 ? vel.z / speed : 0;
		bool backswing = rise > -clamp(RSQML_Club.UserF(mo, 'rsqml_whip_down', 0.25), 0.0, 0.9);
		if (isButt)
		{
			// the butt strike: two hands on the gun (the engine's steadying), driving forward by Butt Strike: Forward Share
			// of its speed, and NOT muzzle-led (a pivot and a straight shove both strike; swinging the barrel round does not)
			double fwd = speed > 0 ? vel.x / speed : 0;
			backswing = !RSQML_ClubVR.Steadied(mo)
				|| fwd < clamp(RSQML_Club.UserF(mo, 'rsqml_butt_fwd', 0.5), 0.0, 1.0)
				|| velIn.Length() > speed * BUTT_LEAD;
		}

		bool fast = power >= 1 && !backswing;
		if (fast)
		{
			calmTics = 0;
			swingTics++;
			if (swingTics == 1 && whooshWait == 0)
			{
				mo.A_StartSound("Melee/SwingStrong", CHAN_WEAPON, CHANF_OVERLAP);
				whooshWait = 12;
			}
			if (swingTics == 1 && RSQML.Debug() >= 1)
				Console.Printf("\c[Gold]rsqml club: %s swing, %s hand, %.2f m/s at the %s (%.2f x the swing needed) (t%d)", isButt ? "butt strike" : "pistol whip",
					off ? "off" : "main", speed * 35. / vu, isButt ? "stock" : "muzzle", power, level.maptime);
			Sweep(mo, k, prevIn, prevOut, bin, bout, power);
			Vector3 sd = bout - prevOut;
			double sl = sd.Length();
			if (sl > 0) sd /= sl;
			if (isButt && sl > 0)
				Sweep(mo, k, prevOut, prevOut + sd * BUTT_REACH, bout, bout + sd * BUTT_REACH, power, BUTT_PAD);
			// a switch or a door the gun meets: worked once a swing, as a Use press on that line
			if (!usedLine && sl > 0)
				usedLine = LineUse(mo, fH, prevOut, bout, isButt ? BUTT_REACH : WHIP_USE, isButt ? "butt strike" : off ? "off-hand pistol whip" : "pistol whip");
		}
		else if (++calmTics > 2)
		{
			swingTics = 0;
			struck.Clear();
			usedLine = false;
			pulsed = false;
		}
		WallCheck(mo, bout, power);

		prevIn = bin; prevH = fH;
		prevOut = bout;
		prevPos = mo.pos;
	}

	// the gun's path this tic against every body near it; each body is hit once per swing, where the gun first meets it
	void Sweep(PlayerPawn mo, int k, Vector3 a0, Vector3 b0, Vector3 a1, Vector3 b1, double power, double padAt = 0)
	{
		double pad = padAt > 0 ? padAt : 5;
		Vector3 c = (a0 + b0 + a1 + b1) / 4;
		double r = max(max((a0 - c).Length(), (b0 - c).Length()), max((a1 - c).Length(), (b1 - c).Length())) + pad;
		double travel = max((b1 - b0).Length(), (a1 - a0).Length());
		int steps = clamp(int(travel / 4) + 1, 1, 16);
		int segs = 8;
		Array<Actor> victims;
		Array<double> hx, hy, hz, dx, dy, dz;
		let it = BlockThingsIterator.CreateFromPos(c.x, c.y, c.z - r, 2 * r, r, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || t == mo || t.player || !t.bSHOOTABLE || t.bFRIENDLY || t.bDORMANT || t.health <= 0) continue;
			if (struck.Find(t) != struck.Size() || victims.Find(t) != victims.Size()) continue;
			bool hit = false;
			Vector3 at = (0, 0, 0);
			Vector3 dir = (0, 0, 0);
			for (int i = 1; i <= steps && !hit; i++)
			{
				double f = double(i) / steps;
				for (int j = segs; j >= 0 && !hit; j--)
				{
					double s = double(j) / segs;
					Vector3 p0 = a0 + (b0 - a0) * s;
					Vector3 p1 = a1 + (b1 - a1) * s;
					Vector3 q = p0 + (p1 - p0) * f;
					if (Touches(t, q, pad)) { hit = true; at = q; dir = p1 - p0; }
				}
			}
			if (!hit || !Clear(mo, fH, at)) continue;
			victims.Push(t);
			hx.Push(at.x); hy.Push(at.y); hz.Push(at.z);
			dx.Push(dir.x); dy.Push(dir.y); dz.Push(dir.z);
		}
		for (int i = 0; i < victims.Size(); i++)
		{
			Actor t = victims[i];
			if (!t || t.health <= 0) continue;
			struck.Push(t);
			Strike(mo, k, t, (hx[i], hy[i], hz[i]), (dx[i], dy[i], dz[i]), power);
		}
	}

	static bool Touches(Actor t, Vector3 q, double pad)
	{
		if (q.z < t.pos.z - pad || q.z > t.pos.z + t.height + pad) return false;
		double ddx = q.x - t.pos.x, ddy = q.y - t.pos.y, rr = t.radius + pad;
		return ddx * ddx + ddy * ddy <= rr * rr;
	}

	static bool Clear(Actor mo, Vector3 from, Vector3 to)
	{
		Vector3 d = to - from;
		double len = d.Length();
		if (len < 1) return true;
		FLineTraceData tr;
		mo.LineTrace(VectorAngle(d.x, d.y), len, -asin(clamp(d.z / len, -1, 1)), TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, tr);
		return tr.HitType == TRACE_HitNone || tr.HitType == TRACE_HitActor;
	}

	void Strike(PlayerPawn mo, int k, Actor t, Vector3 at, Vector3 dir, double power)
	{
		// BD22's attack starts just inside the body, at the height the gun met it
		double rx = at.x - t.pos.x, ry = at.y - t.pos.y;
		double rl = sqrt(rx * rx + ry * ry);
		double lim = max(t.radius - 2, 1);
		if (rl > lim) { rx *= lim / rl; ry *= lim / rl; }
		Vector3 p = (t.pos.x + rx, t.pos.y + ry, clamp(at.z, t.pos.z + 1, t.pos.z + max(t.height - 1, 1)));
		double dl = dir.Length();
		if (dl > 0) dir = dir / dl;
		else dir = (cos(mo.angle), sin(mo.angle), 0);
		// RSQ Score: the gun-butt shove, BD22 VR's butt strike and the pistol whip are one tool, named before the blow so a
		// kill inside it is scored as it (shove.zs ButtShove does the same)
		RSQML.Touch("shove", mo, t);
		bool zerk = mo.CountInv('PowerStrength') > 0;
		String what;
		if (k == PISTOL || k == REVOLVER)
		{
			// the pistol whip: BD22's own punch (and a second at twice the swing needed)
			Launch(mo, zerk ? 'MeleeStrike1Berserked' : 'MeleeStrikeNormal', p, dir);
			what = zerk ? "MeleeStrike1Berserked" : "MeleeStrikeNormal";
			if (power >= 2.0) { Launch(mo, 'MeleeStrikeNormal', p, dir); what = what .. " + MeleeStrikeNormal"; }
		}
		else
		{
			// the butt strike: BD22's own kick
			Launch(mo, zerk ? 'SuperKickAttack' : 'KickAttack', p, dir);
			what = zerk ? "SuperKickAttack" : "KickAttack";
		}
		if (RSQML.Debug() >= 1)
			Console.Printf("\c[Gold]rsqml club: %s hit %s (%s hand, %s), %s, power %.2f (t%d)", IsButt(k) ? "butt strike" : "pistol whip", t.GetClassName(),
				off ? "off" : "main", off ? mo.player.OffhandWeapon.GetClassName() : mo.player.ReadyWeapon.GetClassName(), what, power, level.maptime);
		if (!off) Buzz(mo);	// the engine buzzes the WEAPON hand only (as BD22 VR's)
		// the butt strike's slow-mo, once a swing (it was RSQ Melee's watch on BD22 VR's KickAttack; now the strike is ours)
		if (IsButt(k) && !pulsed && mo.PlayerNumber() == consoleplayer)
		{
			pulsed = true;
			let sh = RSQML_Shove.Get();
			if (sh) sh.Pulse("the butt strike");
		}
	}

	// BD22's attack actor, fired by the player from that point
	static void Launch(PlayerPawn mo, Name cname, Vector3 p, Vector3 dir)
	{
		class<Actor> cls = cname;
		if (!cls) return;
		let a = Actor.Spawn(cls, p, ALLOW_REPLACE);
		if (!a) return;
		a.target = mo;
		a.angle = VectorAngle(dir.x, dir.y);
		a.pitch = -asin(clamp(dir.z, -1, 1));
		a.vel = dir * a.speed;
		a.CheckMissileSpawn(0);
	}

	// the controller's buzz: the engine buzzes the weapon hand when the player fires a projectile (P_SpawnPlayerMissile).
	// Through RSQ Accessibility's Rumble Backup first when it is on (it then sends the buzz and this one is not sent).
	static void Buzz(PlayerPawn mo, bool off = false)
	{
		if (RumbleBackup(mo, off)) return;
		mo.SpawnPlayerMissile('RSQML_ClubBuzz', mo.angle, noautoaim: true, aimflags: off ? ALF_ISOFFHAND : 0);
	}
	static bool RumbleBackup(PlayerPawn mo, bool off)
	{
		if (!mo || !mo.player) return false;
		let cv = CVar.FindCVar('rsqa_rumble_backup');
		if (!cv || cv.GetInt() == 0) return false;
		let s = ServiceIterator.Find("RSQA_Service").Next();
		if (!s) return false;
		let cs = CVar.FindCVar('vr_control_scheme');
		bool left = off != (cs && cs.GetInt() >= 10);
		return s.GetInt("buzz", "RSQML", mo.PlayerNumber(), left ? 1 : 0) == 1;
	}

	// the gun going into a wall, floor or ceiling at speed: BD22's axe impact (sparks and clang, or the floor's splash)
	void WallCheck(PlayerPawn mo, Vector3 bout, double power)
	{
		Vector3 d = bout - fH;
		double len = d.Length();
		bool blocked = false;
		Vector3 hitAt = (0, 0, 0);
		if (len > 1)
		{
			FLineTraceData tr;
			mo.LineTrace(VectorAngle(d.x, d.y), len, -asin(clamp(d.z / len, -1, 1)), TRF_ABSPOSITION | TRF_THRUACTORS, fH.z, fH.x, fH.y, tr);
			if (tr.HitType == TRACE_HitWall || tr.HitType == TRACE_HitFloor || tr.HitType == TRACE_HitCeiling) { blocked = true; hitAt = tr.HitLocation; }
		}
		if (blocked && !inWall && power >= 1 && scrapeWait == 0)
		{
			Vector3 dir = d / len;
			Launch(mo, 'AxeAttack', hitAt - dir * 6, dir);
			Buzz(mo);
			scrapeWait = 8;
		}
		inWall = blocked;
	}

	// A SWITCH OR A DOOR the gun meets (BD22 VR rsq/fists.zs LineUse): along the gun (hand -> its striking end), then the
	// striking end's own path this tic and on along the blow for `reach`. The LINE'S SPECIAL decides, never its texture.
	// Whip / Butt / VR Punch Open Switches (rsqml_punch_use, BD22 VR's Punch Switches Open) switches it off.
	static bool LineUse(PlayerPawn mo, Vector3 hand, Vector3 prevTip, Vector3 tip, double reach, String what)
	{
		if (!mo || RSQML_Club.UserI(mo, 'rsqml_punch_use', 1) == 0) return false;
		Vector3 g = tip - hand;
		double gl = g.Length();
		if (gl > 1 && UseAlong(mo, hand, g / gl, gl, what)) return true;
		Vector3 m = tip - prevTip;
		double ml = m.Length();
		if (ml <= 0) return false;
		return UseAlong(mo, prevTip, m / ml, ml + reach, what);
	}
	static bool UseAlong(PlayerPawn mo, Vector3 from, Vector3 dir, double reach, String what)
	{
		FLineTraceData d;
		if (!mo.LineTrace(VectorAngle(dir.x, dir.y), reach, -asin(clamp(dir.z, -1, 1)), TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, d)) return false;
		if (d.HitType != TRACE_HitWall || !d.HitLine || d.HitLine.special == 0) return false;
		bool done = d.HitLine.Activate(mo, d.LineSide, SPAC_Use) || d.HitLine.Activate(mo, d.LineSide, SPAC_Push);
		if (RSQML.Debug() >= 1)
			Console.Printf("\c[Gold]rsqml club: %s hit line %d (special %d) at %.0f units: %s (t%d)", what, d.HitLine.Index(), d.HitLine.special, d.Distance,
				done ? "worked" : "not usable from here", level.maptime);
		return done;
	}
}

// ---- BD22 VR'S VR PUNCH (BD22 VR Reloaded rsq/fists.zs RSQ_FistHand, ported) ----
// The hand measured in the BODY's own frame; a blow is fast (PUNCH m/s), forward (FORWARD of it along the body's forward
// axis), a real jab (JAB_LEN forward within the history) and out in front (FRONT ahead of the body). It lands BD22's own
// punch (MeleeStrikeNormal, MeleeStrike1Berserked with berserk) from the hand, flying REACH a tic. After a blow the hand
// must come back (RECOCK) or go still. RSQ Melee's own punch reader still reads which punch it was and adds the rest (no
// damage of its own: gloves.zs BD22Punches).
class RSQML_BDPunch play
{
	const PUNCH = 2.5;
	const CALM = 0.35;
	const FORWARD = 0.7;
	const JAB_LEN = 0.15;
	const FRONT = 0.25;
	const RECOCK = 0.08;
	const HIST = 6;
	const REACH = 16.0;
	const USE_REACH = 30.0;
	const JUMP = 0.5;

	double fx[HIST], fy[HIST], fz[HIST];
	int head, count;
	bool ready;
	double peak;
	int handIdx;

	void Tick(PlayerPawn mo, Vector3 hand, bool on)
	{
		if (!on) { count = 0; ready = false; return; }
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		if (vu <= 0) vu = 34;
		Vector3 d = hand - RSQML_ClubSync.Body(mo);
		double c = cos(mo.angle), s = sin(mo.angle);
		double lf = d.x * c + d.y * s;
		double ll = -d.x * s + d.y * c;
		double lu = d.z;
		// a step faster than any arm (the engine re-syncing its VR yaw on a map load) is the frame moving: start again
		if (count > 0 && (lf - fx[head], ll - fy[head], lu - fz[head]).Length() > JUMP * vu) { count = 0; ready = false; }
		int prev = head;
		head = (head + 1) % HIST;
		fx[head] = lf; fy[head] = ll; fz[head] = lu;
		if (count < HIST)
		{
			count++;
			if (count < 2) return;
		}
		Vector3 v = (lf - fx[prev], ll - fy[prev], lu - fz[prev]);
		double speed = v.Length();
		double thr = PUNCH * vu / 35.;
		if (!ready)
		{
			if (speed < thr * CALM || lf < peak - RECOCK * vu) ready = true;
			return;
		}
		if (speed < thr || v.x / speed < FORWARD || lf < FRONT * vu) return;
		double back = lf;
		for (int i = 0; i < count; i++) back = min(back, fx[(head - i + HIST) % HIST]);
		if (lf - back < JAB_LEN * vu) return;
		ready = false;
		peak = lf;
		Vector3 dir = (v.x * c - v.y * s, v.x * s + v.y * c, v.z) / speed;
		Name sn = mo.CountInv('PowerStrength') > 0 ? 'MeleeStrike1Berserked' : 'MeleeStrikeNormal';
		class<Actor> sc = RSQML_ClubHand.Cls(sn);
		if (!sc) return;
		let a = Actor.Spawn(sc, hand, ALLOW_REPLACE);
		if (!a) return;
		a.target = mo;
		a.angle = VectorAngle(dir.x, dir.y);
		a.pitch = -asin(clamp(dir.z, -1, 1));
		a.vel = dir * REACH;
		double mps = speed * 35. / vu;
		// BD22 VR's LegenDoom mode reads the punch's hand and speed off its record (rsq/fists.zs Record): asked by name
		let svc = ServiceIterator.Find("RSVR_MeleeService").Next();
		if (svc) svc.GetInt("punch.record", "", handIdx, mps, a);
		PunchUse(mo, hand, dir);
		mo.A_StartSound("Melee/Swing", CHAN_AUTO, CHANF_OVERLAP);
		if (RSQML.Debug() >= 1)
			Console.Printf("\c[Gold]rsqml club: VR punch (BD22 VR's), %s hand, %.2f m/s: %s (t%d)", handIdx == 1 ? "off" : "main", mps, sn, level.maptime);
	}

	// a blow that lands on a switch or any usable line works it, at the fist's own reach (fists.zs PunchUse)
	static void PunchUse(PlayerPawn mo, Vector3 from, Vector3 dir)
	{
		if (!mo || RSQML_Club.UserI(mo, 'rsqml_punch_use', 1) == 0) return;
		FLineTraceData d;
		double ang = VectorAngle(dir.x, dir.y);
		double pit = -asin(clamp(dir.z, -1, 1));
		if (!mo.LineTrace(ang, USE_REACH, pit, TRF_ABSPOSITION, from.z, from.x, from.y, d)) return;
		if (d.HitType != TRACE_HitWall || !d.HitLine || d.HitLine.special == 0) return;
		if (!d.HitLine.Activate(mo, d.LineSide, SPAC_Use)) d.HitLine.Activate(mo, d.LineSide, SPAC_Push);
	}
}

// a projectile the engine counts as a shot: spawning it buzzes the weapon hand (BD22 VR's RSVR_Buzz)
class RSQML_ClubBuzz : Actor
{
	Default
	{
		Projectile;
		+NOCLIP
		Radius 1;
		Height 1;
		Speed 1;
		DamageType "RSQMLHaptic";
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}

// THE GUNS DRAWN AT THE FBX HAND (BD22 VR Reloaded r12 port, rsvr/melee.zs RSVR_MeleeMove, its butt-strike / pistol-whip
// rows): a point Place() computed in the original placement (controller frame, F / L / U cm, vr_weaponScale 1.02) ->
// R p + t, the gun's own rigid move to where it is drawn.
class RSQML_ClubMove abstract
{
	static Vector3 Apply(int k, int pf, Vector3 p)
	{
		if (pf != 0) return p;
		Vector3 t;
		if (k == RSQML_ClubHand.RIFLEBUTT) t = (5.7921, 1.6646, 4.9479);	// Rifle
		else if (k == RSQML_ClubHand.SGBUTT) t = (4.1373, 5.5150, -2.2130);	// Shot_Gun
		else if (k == RSQML_ClubHand.SSGBUTT) t = (3.8398, 5.8258, -6.0133);	// SSG
		else if (k == RSQML_ClubHand.ASGBUTT) t = (4.6856, 6.7137, -5.2711);	// AssaultShotgun
		else if (k == RSQML_ClubHand.MP40BUTT) t = (4.3510, 2.9954, 4.5470);	// MP40
		else if (k == RSQML_ClubHand.SMGBUTT) t = (4.4405, 1.1050, 3.3465);	// BrutalSMG
		else if (k == RSQML_ClubHand.MGBUTT) t = (3.8472, 2.6254, 4.7226);	// Machinegun
		else if (k == RSQML_ClubHand.MG42BUTT) t = (2.7396, 2.7430, 6.3178);	// MG42
		else if (k == RSQML_ClubHand.PISTOL) t = (8.2136, 1.1930, 5.3519);	// BrutalPistol
		else if (k == RSQML_ClubHand.REVOLVER) t = (5.2965, 1.5468, 3.9587);	// Revolver
		else return p;
		return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + t.x,
			0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + t.y,
			0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + t.z);
	}
}
