// THE GLOVES AND THE PUNCH -- SuperPunchOut's boxing gloves, as weapons for any Doom map (RSQ Melee; moved from
// RSQ Gun Bonsai VR's rsq/zscript/gloves.zs on 2026-11-01).
//
// From SuperPunchOut (presidentkoopa): the glove weapons (spo_present.zs SPO_Glove /
// SPO_GloveOff), their model and skins (models/spo, the mesh of Ermac's PunchOutVR glove and
// Ermac's fit, Scale -1.2 1.2 1.2, Offset 0 -10 -10) and the punch reader (spo_corner.zs, the
// Arcade reader: a punch arms only after the glove has travelled ARM_M toward its target on
// consecutive tics, must average spo_min_speed over that travel, and its power is the average).
// The boxer, the ring and the bout are not here.
//
// RENAMED RSQ_Glove / RSQ_GloveOff, so this mod and SuperPunchOut can both be loaded without two classes of one
// name. Moved here from RSQ Gun Bonsai VR on 2026-11-01 WITH THEIR NAMES: Gun Bonsai keeps a glove's XP and
// upgrades by its class name, and a save holds the gloves by it. Gun Bonsai VR's glove upgrades read the last
// punch through RSQML_Service ("punch.*", service.zs), never by linking to these classes.
//
// A glove draws nothing (TNT1) and fires nothing: a punch is the hand. Stock QuestZDoom draws
// the READY weapon's model on the main controller and the OFFHAND weapon's on the other, so the
// MODELDEF on these two classes is the whole of what you see.

class RSQ_Glove : Weapon
{
	// THE LAST PUNCH, as the reader saw it -- Gun Bonsai VR's upgrades read these (RSQML_Service "punch.*") in
	// ModifyDamageDealt, where the only thing they are handed is this weapon as the inflictor.
	double lastPower;     // 0..1 between spo_min_speed and spo_full_speed (SuperPunchOut's own scale)
	double lastSpeed;     // m/s, the swing's average
	int    lastKind;      // RSQ_GloveHandler.PK_JAB / PK_HOOK / PK_UPPER
	bool   lastBody;      // landed below the chest
	bool   lastCounter;   // the target was in its attack wind-up
	bool   lastStar;      // a star punch
	int    lastChain;     // One-Two: how many alternating hits in a row, this one included
	int    lastHand;
	int    lastHeight;    // where the glove met it, permille of its height from its feet (Headshot)
	int    lastKinds;     // Combos: this player's punches inside COMBO_TICS, oldest first, digits kind + 1 (jab, jab, hook = 112)
	int    lastRun;       // Dempsey: alternating hooks in a row, this one included (0 not a hook)
	// Star Punch's bank (SuperPunchOut's), kept on the main-hand glove so it is saved and kept across levels
	int    bankStars, bankLanded;
	int    wornTone;      // the BD22 VR skin tone this hand wears (RSQML_HandLook), 0 = as drawn

	Default
	{
		Weapon.SelectionOrder 5500;
		Weapon.Kickback 100;
		Weapon.SlotNumber 1;
		Tag "$RSQ_GLOVE_TAG";
		Inventory.PickupMessage "$RSQ_GLOVE_PICKUP";
		Obituary "$RSQ_GLOVE_OB";
		+WEAPON.WIMPY_WEAPON
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
		+WEAPON.NOHANDSWITCH
		+WEAPON.NOAUTOSWITCHTO
		+WEAPON.NO_AUTO_SWITCH
		+WEAPON.AMMO_OPTIONAL
		+INVENTORY.UNDROPPABLE
	}

	States
	{
	// THE LOOK IS THE READY STATE: one per look, each naming its own MODELDEF sprite and frame (RSQML_HandLook picks;
	// setting a psprite's sprite or frame from script drew the wrong model on the rig, 2026-11-02: the HUD model blends
	// toward the state's own next frame). Each looks again every tic and moves to the right one.
	Ready:
		RMHE A 0;
		Goto ReadyErmacFist;
	ReadyErmacFist:
		RMHE A 1 { A_WeaponReady(WRF_NOFIRE); return RSQML_HandLook.Next(self, invoker, RSQML_HandLook.LK_ERMAC_FIST); }
		Loop;
	ReadyErmacOpen:
		RMHE B 1 { A_WeaponReady(WRF_NOFIRE); return RSQML_HandLook.Next(self, invoker, RSQML_HandLook.LK_ERMAC_OPEN); }
		Loop;
	ReadyFbxFist:
		RMHF A 1 { A_WeaponReady(WRF_NOFIRE); return RSQML_HandLook.Next(self, invoker, RSQML_HandLook.LK_FBX_FIST); }
		Loop;
	ReadyFbxOpen:
		RMHF B 1 { A_WeaponReady(WRF_NOFIRE); return RSQML_HandLook.Next(self, invoker, RSQML_HandLook.LK_FBX_OPEN); }
		Loop;
	ReadyGlove:
		RMHG A 1 { A_WeaponReady(WRF_NOFIRE); return RSQML_HandLook.Next(self, invoker, RSQML_HandLook.LK_GLOVE); }
		Loop;
	Deselect:
		RMHE A 1 A_Lower(120);
		Wait;
	Select:
		RMHE A 1 A_Raise(120);
		Wait;
	Fire:
		RMHE A 1;
		Goto Ready;
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

// ---- THE LOOK: MELEE'S HANDS (2026-11-02) ---------------------------------------------------------------------
// One weapon class per hand (RSQ_Glove / RSQ_GloveOff: their names are kept for saves and Gun Bonsai), five looks,
// one Ready state each (MODELDEF.txt):
//   RMHE A  Ermac's hand, frame 1: the fist        RMHE B  Ermac's hand, frame 0: the relaxed open hand
//   RMHF A  BD22 VR's FBX hand, frame 1: the fist   RMHF B  the FBX hand, frame 0: the relaxed open hand
//   RMHG A  SuperPunchOut's boxing glove (Boxing Gloves on, or Slappers Only): always a fist
// Melee Hands (rsqml_hands_model): Auto = the FBX hand when RSQ's BD22 VR weapons mod is loaded (found by the name of
// its RSQ_HandTone class), else Ermac's; or either one. One right-hand mesh draws both hands: QuestZDoom mirrors the
// off controller's model itself, as BD22 VR's own free hand relies on (MODELDEF.rsq RSQ_Hands).
// The FBX hand's skin tone: BD22 VR's Hand Skin Tone (its user cvar rsq_hand_tone, 0-17), worn the way BD22 VR wears
// it (zscript/rsq/handtone.zs: A_ChangeModel's skin override on the hand's model slot, which RenderHUDModel reads off
// the psprite's caller) from BD22 VR's own pre-tinted textures, models/rsq/fbx/tones/fbx_hand_tNN.png, read by path
// (nothing of them shipped here; without BD22 VR the hand wears its own texture as drawn).
class RSQML_HandLook play
{
	enum ELook { LK_ERMAC_FIST, LK_ERMAC_OPEN, LK_FBX_FIST, LK_FBX_OPEN, LK_GLOVE }
	const FBX_SLOT = 0;   // MODELDEF: the FBX hand's model slot (each look is its own block, all slot 0; the tone is worn
	                      // only while the FBX look is up and taken off when another look comes up)

	static bool BD22VR() { return RSQML.Has("RSQ_HandTone"); }
	static bool Gloved() { return RSQML.SVI("rsqml_slappers", 0) != 0 || RSQML.SVI("rsqml_boxing", 0) != 0; }

	static bool UseFbx(PlayerInfo p)
	{
		let c = CVar.GetCVar("rsqml_hands_model", p);
		int m = c ? c.GetInt() : 0;
		if (m == 1) return false;
		if (m == 2) return true;
		return BD22VR();
	}

	// the frame for this hand now
	static int Look(PlayerPawn pmo, int h)
	{
		if (Gloved()) return LK_GLOVE;
		bool open = RSQML_Gloves.PalmOpen(pmo, h);
		if (UseFbx(pmo.player)) return open ? LK_FBX_OPEN : LK_FBX_FIST;
		return open ? LK_ERMAC_OPEN : LK_ERMAC_FIST;
	}

	// the Ready state for the look this hand should have now; null to stay (the current one is right)
	static State Next(Actor owner, Weapon w, int cur)
	{
		let pmo = PlayerPawn(owner);
		if (!pmo || !pmo.player || !w) return null;
		int h = w.bOffhandWeapon ? 1 : 0;
		int lk = Look(pmo, h);
		Tone(pmo, RSQ_Glove(w), lk == LK_FBX_FIST || lk == LK_FBX_OPEN);
		if (lk == cur) return null;
		if (lk == LK_ERMAC_OPEN) return w.FindState("ReadyErmacOpen");
		if (lk == LK_FBX_FIST) return w.FindState("ReadyFbxFist");
		if (lk == LK_FBX_OPEN) return w.FindState("ReadyFbxOpen");
		if (lk == LK_GLOVE) return w.FindState("ReadyGlove");
		return w.FindState("ReadyErmacFist");
	}

	static void Tone(PlayerPawn pmo, RSQ_Glove g, bool fbx)
	{
		if (!g) return;
		int tone = 0;
		if (fbx && !multiplayer)
		{
			let c = CVar.GetCVar("rsq_hand_tone", pmo.player);
			tone = c ? clamp(c.GetInt(), 0, 17) : 0;
			if (tone > 0 && Wads.CheckNumForFullName(String.Format("models/rsq/fbx/tones/fbx_hand_t%02d.png", tone)) < 0) tone = 0;
		}
		if (tone == g.wornTone) return;
		g.wornTone = tone;
		if (tone > 0) g.A_ChangeModel('None', FBX_SLOT, "", 'None', FBX_SLOT, "models/rsq/fbx/tones/", Name(String.Format("fbx_hand_t%02d.png", tone)));
		else g.A_ChangeModel('None', FBX_SLOT, "", 'None', FBX_SLOT, "", 'None');
	}
}

class RSQ_GloveOff : RSQ_Glove
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
	}
}

// ---- THE READER ------------------------------------------------------------------------------
// Per player, per hand. Pure arithmetic over the hand's positions, so the same code reads a
// real controller and a probe's synthetic swing (Feed).
class RSQ_PunchHand play
{
	bool armed, swinging;
	double approach;
	int approachTics;
	int lastHit;
	// the hand, relative to the pawn at the top of the tic, and its velocity (map units / s)
	Vector3 loc, prevLoc, vel, hand, prevHand;
	bool prevValid;
	int prevTic;
	double prevYaw;
	Vector3 path;         // this swing's travel so far, real metres (the vertical x pixelstretch): which punch it is
}

class RSQML_Gloves : StaticEventHandler
{
	enum EKind { PK_JAB, PK_HOOK, PK_UPPER }

	// SuperPunchOut's Arcade reader constants (spo_corner.zs), unchanged
	const ARM_M = 0.15;       // metres toward the target before a swing is a punch
	const IN_MPS = 0.25;      // m/s that still counts as coming in
	const MAX_TICS = 14;      // longer than this is two motions, not one
	// SuperPunchOut's QZD velocity rules (spo_qzd.zs LocalHandVel), unchanged
	const JUMP_UNITS = 48.0;
	const MAX_GAP = 3;
	const SNAP_DEG = 15.0;

	RSQ_PunchHand hands[MAXPLAYERS * 2];
	// THE HAND SHAPE (2026-11-02): a tap of a hand's own fire input (main hand: fire; off hand: the off-hand fire) turns
	// that hand between the fist (as it starts) and the open palm. A tap is a press let go within TAP_TICS that landed
	// no punch meanwhile (Star Punch squeezes the trigger through an uppercut). Boxing gloves stay fists.
	bool openPalm[MAXPLAYERS * 2];
	int pressTic[MAXPLAYERS * 2];
	bool wasDown[MAXPLAYERS * 2];
	const TAP_TICS = 10;
	// One-Two
	int chainLastHand[MAXPLAYERS], chainLastTic[MAXPLAYERS], chainCount[MAXPLAYERS];
	// COMBOS (GBOVR_TREES.md 4.1 C): the last three landed punches a player threw (kind, tic), oldest first, and the Dempsey
	// run (alternating hooks, each inside DEMPSEY_TICS of the last)
	int histKind[MAXPLAYERS * 3], histTic[MAXPLAYERS * 3];
	int runCount[MAXPLAYERS], runHand[MAXPLAYERS], runTic[MAXPLAYERS];
	const COMBO_TICS = 35;     // Three-Hit's "inside 1 s"
	const DEMPSEY_TICS = 21;   // Dempsey's "each inside 0.6 s"

	// push this punch, and return the punches inside COMBO_TICS as digits (kind + 1), oldest first
	int NoteKind(int pn, int kind, int now)
	{
		int b = pn * 3;
		histKind[b] = histKind[b + 1]; histTic[b] = histTic[b + 1];
		histKind[b + 1] = histKind[b + 2]; histTic[b + 1] = histTic[b + 2];
		histKind[b + 2] = kind; histTic[b + 2] = now;
		int code = 0;
		for (int i = 0; i < 3; i++)
			if (histTic[b + i] > 0 && now - histTic[b + i] <= COMBO_TICS) code = code * 10 + histKind[b + i] + 1;
		return code;
	}

	static RSQML_Gloves Get() { return RSQML_Gloves(StaticEventHandler.Find("RSQML_Gloves")); }

	static bool PalmOpen(PlayerPawn pmo, int h)
	{
		let gl = Get();
		if (!gl || !pmo || RSQML_HandLook.Gloved()) return false;
		int i = pmo.PlayerNumber() * 2 + h;
		return i >= 0 && i < MAXPLAYERS * 2 && gl.openPalm[i];
	}

	private void TapShape(PlayerPawn pmo, int h)
	{
		int i = pmo.PlayerNumber() * 2 + h;
		bool down = (pmo.player.cmd.buttons & (h == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		int now = level.maptime;
		if (down && !wasDown[i]) pressTic[i] = now;
		if (!down && wasDown[i] && now - pressTic[i] <= TAP_TICS && HandOf(pmo.PlayerNumber(), h).lastHit < pressTic[i] && !RSQML_HandLook.Gloved())
		{
			openPalm[i] = !openPalm[i];
			pmo.A_StartSound("misc/w_pkup", CHAN_AUTO, CHANF_LOCAL, 0.15);   // a soft click: you changed the hand
			if (RSQML.Debug() > 0) Console.Printf("RSQML hand %s: %s", h ? "L" : "R", openPalm[i] ? "open palm" : "fist");
		}
		wasDown[i] = down;
	}

	RSQ_PunchHand HandOf(int pn, int h)
	{
		int i = pn * 2 + h;
		if (!hands[i]) hands[i] = new("RSQ_PunchHand");
		return hands[i];
	}

	static RSQ_Glove GloveIn(PlayerPawn pmo, int h)
	{
		if (!pmo || !pmo.player) return null;
		return RSQ_Glove(h == 0 ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon);
	}

	// The controller, or nothing (RSQML_Hands.Pos: out of VR the engine writes both hands to the pawn's chest).
	Vector3, bool HandPos(PlayerPawn pmo, int h) { Vector3 p; bool ok; [p, ok] = RSQML_Hands.Pos(pmo, h); return p, ok; }

	// SuperPunchOut's ClassifyPunch (PunchOutVR core.zs), unchanged: from how the glove travelled
	// against the line to the target -- not from where you look or how the controller is held.
	static int Classify(Vector3 dir, Vector2 toFoe, double rise)
	{
		double fwd = dir.xy dot toFoe;
		double lat = abs(dir.x * toFoe.y - dir.y * toFoe.x);
		if (dir.z > rise) return PK_UPPER;
		if (lat > 0.6 && lat > fwd) return PK_HOOK;
		return PK_JAB;
	}

	// WHICH PUNCH, in REAL space (2026-11-02; the owner: "the uppercut works but it is spotty"). Classify alone read the
	// last tic's velocity in MAP units, where a rise is squashed by the pixelstretch (1.2): a real 30-degree rise read as
	// 26 and missed the 0.5 line, and an uppercut that curls forward into the chin at contact read as a jab. Now the
	// swing's whole travel (path, real metres) decides, with the last tic's real direction as a second chance: either
	// rising past rsqml_punch_uppercut_rise (0.5 = 30 degrees) is an uppercut. Hook and jab as before.
	static int ClassifySwing(Vector3 last, Vector3 path, Vector2 toFoe, double rise)
	{
		double ps = level.pixelstretch > 0.1 ? level.pixelstretch : 1.2;
		Vector3 lr = (last.x, last.y, last.z * ps);
		if (lr.Length() > 0.0001) lr = lr.Unit();
		Vector3 pr = path.Length() > 0.03 ? path.Unit() : lr;
		if (pr.z > rise || lr.z > rise) return PK_UPPER;
		return Classify(pr.Length() > 0.0001 ? pr : last, toFoe, 2.0);
	}

	override void WorldTick()
	{
		// the missile list: what has burst or been destroyed goes (a few a tic at most)
		if ((level.maptime & 7) == 0)
		{
			for (int i = missiles.Size() - 1; i >= 0; i--) if (!missiles[i] || !missiles[i].bMissile) missiles.Delete(i);
			for (int i = returned.Size() - 1; i >= 0; i--) if (!returned[i] || !returned[i].bMissile) { returned.Delete(i); returnedMult.Delete(i); }
		}
		let hl = RSQML_Headlock.Get();
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.health <= 0) continue;
			RSQML_Body.Ensure(pmo);
			for (int h = 0; h < 2; h++)
			{
				let g = GloveIn(pmo, h);
				// the off hand holding a monster in the Headlock grips it: no punches from that hand meanwhile
				if (h == 1 && hl && hl.HoldsAny(pn)) g = null;
				if (!g) { HandOf(pn, h).prevValid = false; continue; }
				TapShape(pmo, h);
				Read(pmo, g, h);
			}
		}
	}

	private void Read(PlayerPawn pmo, RSQ_Glove g, int h)
	{
		let st = HandOf(pmo.PlayerNumber(), h);
		Vector3 hp; bool ok;
		[hp, ok] = HandPos(pmo, h);
		int now = level.maptime;
		if (!ok) { st.prevValid = false; return; }
		// THE VELOCITY, SuperPunchOut's way: the hand against the pawn at the top of the tic
		// (Prev), one tic, no averaging; a snap turn or a one-tic jump no arm makes is dropped.
		Vector3 loc = hp - pmo.Prev;
		int dt = now - st.prevTic;
		bool had = st.prevValid;
		Vector3 prev = st.loc;
		double yawStep = abs(Actor.DeltaAngle(st.prevYaw, pmo.angle));
		st.prevHand = st.hand;
		st.hand = hp;
		st.loc = loc;
		st.prevYaw = pmo.angle;
		st.prevTic = now;
		st.prevValid = true;
		st.vel = (0, 0, 0);
		if (!had || dt < 1 || dt > MAX_GAP) return;
		if (yawStep > SNAP_DEG * dt) return;
		Vector3 d = loc - prev;
		if (d.Length() > JUMP_UNITS * dt) return;
		st.vel = d * (double(TICRATE) / dt);
		Swing(pmo, g, h, st);
	}

	private void Swing(PlayerPawn pmo, RSQ_Glove g, int h, RSQ_PunchHand st)
	{
		double upm = RSQML.UnitsPerMetre();
		double ps = level.pixelstretch > 0.1 ? level.pixelstretch : 1.2;
		double minSpeed = RSQML.SV("rsqml_punch_min_speed", 2.0);   // spo_min_speed's default
		double fullSpeed = RSQML.SV("rsqml_punch_full_speed", 7.0); // spo_full_speed's default
		int rehit = RSQML.SVI("rsqml_punch_rehit", 6);               // spo_rehit_tics' default
		// DEMPSEY (GBOVR_TREES.md 4.1 C): in a run of alternating hooks, a glove that has it re-arms faster
		int dpn = pmo.PlayerNumber();
		if (runCount[dpn] > 0 && level.maptime - runTic[dpn] <= DEMPSEY_TICS)
		{
			int dpLv = RSQML.GBLevel(g, "Dempsey");
			if (dpLv > 0) rehit = min(rehit, int(RSQML.Num("Dempsey.rehit", dpLv, 0, 4)));
		}
		Vector3 v = st.vel;
		v.z *= ps;
		double mps = v.Length() / upm;
		int now = level.maptime;
		bool dbg = RSQML.Debug() > 0;
		if (dbg) Console.Printf("RSQML punch %s t%d %.2f m/s armed %d approach %.2f m in %d", h ? "L" : "R", now, mps, st.armed, st.approach, st.approachTics);

		// HADOUKEN (pick 53, was Return Fire; Gun Bonsai VR's upgrade class RSQ_Upgrade_ReturnFire): a glove moving at
		// punch speed knocks back an enemy missile it meets. With Gun Bonsai VR: once that glove has learned it. Without:
		// the Hadouken row (rsqml_hadouken, off), at level 1. Read on EVERY tic the glove moves that fast, armed or not
		// (until 2026-11-02 only inside an armed punch's approach: a fist snapped at a fireball rarely starts from rest).
		bool open = PalmOpen(pmo, h);
		if (open)
		{
			// THE OPEN PALM: no punches, no Hadouken -- a swat (SWAT_MPS or more, any direction) knocks a missile aside
			if (mps >= SWAT_MPS && missiles.Size() > 0 && RSQML.SVI("rsqml_swat", 1) != 0) Swat(pmo, g, h, st);
			st.armed = false;
			st.approach = 0;
			st.approachTics = 0;
			st.path = (0, 0, 0);
			return;
		}
		if (mps >= minSpeed && missiles.Size() > 0)
		{
			int rfLv = RSQML.MoveLevel(pmo, g, "ReturnFire", "rsqml_hadouken");
			if (rfLv > 0) ReturnFire(pmo, g, h, st, rfLv);
		}

		if (!st.armed)
		{
			if (now - st.lastHit >= rehit && mps < minSpeed * 0.6) st.armed = true;
			return;
		}
		if (mps >= IN_MPS && st.approachTics < MAX_TICS)
		{
			st.approach += mps / TICRATE;
			st.approachTics++;
			st.path += v / (upm * TICRATE);
		}
		else
		{
			if (st.swinging) Whiff(pmo, h);
			st.swinging = false;
			st.approach = 0;
			st.approachTics = 0;
			st.path = (0, 0, 0);
			return;
		}
		if (st.approach < ARM_M) return;
		double avg = st.approach * TICRATE / st.approachTics;
		if (avg < minSpeed) return;
		st.swinging = true;

		// WHAT THE GLOVE WENT INTO between last tic and this one: a body's cylinder, the glove a
		// sphere of SuperPunchOut's gloveradius (0.09 m) with a little reach.
		double gr = 0.09 * upm + RSQML.SV("rsqml_punch_pad", 4.0);
		Actor victim = Contact(pmo, st.prevHand, st.hand, gr);
		if (dbg) { String vn = "nothing"; if (victim) vn = victim.GetClassName(); Console.Printf("RSQML punch %s swing %.2f m/s avg -> %s", h ? "L" : "R", avg, vn); }
		if (!victim) return;
		Vector3 dir = st.vel;
		if (dir.Length() < 0.001) dir = level.Vec3Diff(st.hand, victim.pos);
		dir = dir.Unit();
		// a hand pulled back out of a body is not a punch (2026-11-02): the blow must drive toward it
		Vector2 toBody = victim.pos.xy - st.prevHand.xy;
		if (toBody.Length() > 1.0 && (dir.xy dot toBody.Unit()) < -0.2) return;
		Deliver(pmo, g, h, victim, avg, dir, st.hand, st.path);
		st.armed = false;
		st.swinging = false;
		st.approach = 0;
		st.approachTics = 0;
		st.path = (0, 0, 0);
		st.lastHit = now;
	}

	static Actor Contact(PlayerPawn pmo, Vector3 a, Vector3 b, double gr)
	{
		Actor best = null;
		double bestD = 1e9;
		let it = BlockThingsIterator.CreateFromPos(b.x, b.y, b.z - 96, 192, gr + 64, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!RSQML.IsFoe(pmo, mo)) continue;
			// nearest approach of the glove's path this tic to the body's axis, in the plane
			Vector2 c = mo.pos.xy;
			Vector2 ab = b.xy - a.xy;
			double l2 = ab dot ab;
			double t = l2 > 0.0001 ? clamp(((c - a.xy) dot ab) / l2, 0.0, 1.0) : 1.0;
			Vector3 p = a + (b - a) * t;
			double dxy = (p.xy - c).Length();
			if (dxy > mo.radius + gr) continue;
			if (p.z < mo.pos.z - gr || p.z > mo.pos.z + mo.height + gr) continue;
			if (dxy < bestD && ClearPath(pmo, p, mo)) { bestD = dxy; best = mo; }
		}
		return best;
	}

	// WALL OCCLUSION, the narrow phase. BlockThingsIterator is a blockmap query and nothing
	// more -- it walks the thing lists of the blocks it covers and never looks at a linedef -- so
	// the broad phase above happily returns a body on the far side of a thin wall, and until this
	// was added that punch landed. One confirming trace, for a candidate the nearest-approach
	// test would otherwise accept, from the glove's own contact point to the body.
	//
	// WHY LineTrace AND NOT CheckSight. CheckSight is actor-to-actor and starts at the first
	// actor's eyes -- "look from eyes of t1 to any part of t2", src/playsim/p_sight.cpp:834 --
	// and there is no way to tell it where to start. The glove is up to an arm from the chest, so
	// a fist around a corner, or a pillar standing between the fist and the body but not between
	// the chest and it, is exactly the geometry that produces this bug: the two calls disagree
	// precisely where it matters. CheckSight also answers a monster's question rather than a
	// geometric one -- it rejects on sector reject tables and the heightsec water boundary
	// (p_sight.cpp:862, :888) and rolls pr_checksight() when the target is invisible or
	// translucent (p_sight.cpp:879), and that RNG is the playsim's, drawn here on a machine-local
	// pose path, which is the one thing a hand reader must never do. LineTrace takes the start
	// point literally under TRF_ABSPOSITION -- startpos = (offsetforward, offsetside, offsetz),
	// src/playsim/p_map.cpp:5207-5209 -- so it is the only call in the script surface that can be
	// asked the question the glove actually has.
	//
	// NEITHER THE PLAYER NOR THE VICTIM IS AN OBSTRUCTION. TRF_THRUACTORS makes the trace's own
	// callback skip every actor it meets (CheckLineTrace returns TRACE_Skip, p_map.cpp:5160), so
	// the player's body under the fist, the victim at the far end, and any third monster between
	// them are all transparent and only geometry can stop it; the pawn is the trace's ignore actor
	// as well (P_LineTrace hands Trace its own t1, p_map.cpp:5269, tested at p_trace.cpp:866).
	// Nothing in the map is disturbed either: a crossed line's special fires only under
	// TRACE_Impact / TRACE_PCross (p_trace.cpp:485, :582) and P_LineTrace sets neither
	// (p_map.cpp:5265).
	//
	// Z NEEDS NO CONVERSION, and that is worth saying because the velocity above does. A hand pose
	// is an absolute MAP position, not an offset: the weapon transform is built from CenterEyePos,
	// scaled by vr_vunits_per_meter, and the up axis is divided by pixelstretch INSIDE it
	// (gl_openvr.cpp:1282-1292) before AttackPos.Z is read straight out of the matrix
	// (gl_openvr.cpp:2529, OffhandPos.Z at :2544). So a glove position is already in mo.pos's
	// space, which is why the contact test above compares p.z with mo.pos.z directly and is right
	// to. The vertical pixelstretch term converts a map-unit DELTA to metres; that is what Swing
	// applies it to (the velocity, v.z *= ps) and it has no business here.
	static bool ClearPath(PlayerPawn pmo, Vector3 from, Actor mo)
	{
		// the body's axis at the height the glove met it, so a punch over a chest-high wall is
		// still a punch and one into that wall is not
		Vector3 to = (mo.pos.x, mo.pos.y, clamp(from.z, mo.pos.z, mo.pos.z + mo.height));
		Vector3 d = mo.level.Vec3Diff(from, to);
		double dist = d.Length();
		if (dist < 1.0) return true;              // the fist is on the axis; nothing fits between
		// P_LineTrace builds its direction as (cos(pitch)cos(angle), cos(pitch)sin(angle),
		// -sin(pitch)) (p_map.cpp:5180), so the pitch of a delta is VectorAngle(dxy, -dz) -- the
		// engine's own idiom for it, zscript/actors/shared/movingcamera.zs:389.
		FLineTraceData t;
		bool stopped = pmo.LineTrace(VectorAngle(d.x, d.y), dist, VectorAngle(d.xy.Length(), -d.z),
			TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, t);
		if (!stopped && t.HitType == TRACE_HitNone) return true;
		if (RSQML.Debug() > 0) { String vn = mo.GetClassName(); Console.Printf("RSQML punch blocked: type %d at %.1f of %.1f to %s", t.HitType, t.Distance, dist, vn); }
		return false;
	}

	// ---- HADOUKEN (pick 53, was Return Fire) ----------------------------------------------------------------
	// Missiles are not in the blockmap (a projectile is +NOBLOCKMAP), so a blockmap query never finds them: the
	// enemy missiles in the level are listed as they spawn (the ShieldSaw keeps the same list for the same reason).
	Array<Actor> missiles;
	Array<Actor> returned;      // missiles sent back at their shooters (Hadouken, Swat Back, Reflect Guard), and what each hits for
	Array<double> returnedMult;

	// a new map, or a save loaded: the lists were the old level's (a static handler is never saved)
	override void WorldLoaded(WorldEvent e) { missiles.Clear(); returned.Clear(); returnedMult.Clear(); }
	override void WorldUnloaded(WorldEvent e) { missiles.Clear(); returned.Clear(); returnedMult.Clear(); }

	// Only a missile that can hurt: Brutal Doom's fireballs spawn three trail puffs a tic (ImpFireBallTrail1-3, missiles
	// with the imp as their shooter and no damage), and its gore flies as missiles too. Listing those cost a scan each
	// and, punched, each played a punch sound of its own.
	override void WorldThingSpawned(WorldEvent e)
	{
		let m = e.Thing;
		if (m && m.bMissile && !(m.target && m.target.player) && m.GetMissileDamage(0, 1) > 0) missiles.Push(m);
	}

	// what a missile sent back hits for (RSQML_Body), 0 when it was not sent back
	double MultOfReturned(Actor shot)
	{
		if (!shot) return 0;
		int k = returned.Find(shot);
		return k < returned.Size() ? returnedMult[k] : 0;
	}

	// SEND A MISSILE BACK AT WHOEVER FIRED IT (Hadouken, Swat Back, Reflect Guard; GBOVR_TREES.md 4.1 D). It leaves from
	// `at` (so it never starts inside you), toward its shooter's middle (or `fallback` if the shooter is gone), at its
	// speed x speedMult. It is the player's now (it hurts monsters, not you), a homing missile homes on its shooter, it hits
	// for dmgMult (RSQML_Body), and it is paid to `glove` when there is one (Gun Bonsai VR's claim).
	void SendBack(PlayerPawn pmo, Actor m, Actor from, Vector3 at, double speedMult, double dmgMult, Weapon glove, Vector3 fallback)
	{
		double sp = max(m.Speed, m.vel.Length()) * speedMult;
		Vector3 dir;
		if (from && from.health > 0) dir = level.Vec3Diff(at, from.pos + (0, 0, from.height * 0.5));
		else dir = fallback;
		if (dir.Length() < 0.001) dir = -m.vel;
		dir = dir.Unit();
		Vector3 p = at + dir * (m.radius + 2);
		m.SetOrigin((p.x, p.y, max(p.z, m.floorz)), true);
		m.target = pmo;
		m.tracer = from;
		m.vel = dir * sp;
		m.angle = VectorAngle(dir.x, dir.y);
		m.pitch = -asin(clamp(dir.z, -1.0, 1.0));
		if (glove) RSQML.Claim(m, glove);
		returned.Push(m);
		returnedMult.Push(dmgMult);
		int k = missiles.Find(m);
		if (k < missiles.Size()) missiles.Delete(k);
	}

	// Closest distance between segments p1-q1 and p2-q2 (Ericson, Real-Time Collision Detection 5.1.9).
	static double SegSegDist(Vector3 p1, Vector3 q1, Vector3 p2, Vector3 q2)
	{
		Vector3 d1 = q1 - p1, d2 = q2 - p2, r = p1 - p2;
		double a = d1 dot d1, e = d2 dot d2, f = d2 dot r;
		double s = 0, t = 0;
		if (a <= 1e-6 && e <= 1e-6) return r.Length();
		if (a <= 1e-6) t = clamp(f / e, 0.0, 1.0);
		else
		{
			double c = d1 dot r;
			if (e <= 1e-6) s = clamp(-c / a, 0.0, 1.0);
			else
			{
				double b = d1 dot d2, den = a * e - b * b;
				s = den > 1e-9 ? clamp((b * f - c * e) / den, 0.0, 1.0) : 0.0;
				t = (b * s + f) / e;
				if (t < 0) { t = 0; s = clamp(-c / a, 0.0, 1.0); }
				else if (t > 1) { t = 1; s = clamp((b - c) / a, 0.0, 1.0); }
			}
		}
		return ((p1 + d1 * s) - (p2 + d2 * t)).Length();
	}

	// WHERE A MISSILE CAN BE MET. Until 2026-11-02 the glove's path this tic had to come within (glove + missile radius +
	// 4) of the missile's path from one tic back to one tic ahead. That worked on vanilla Doom (DoomImpBall: drawn where
	// it is, 10 map units a tic, radius 6) and failed on Brutal Doom (the owner, in his headset; measured on the rig
	// 2026-11-02): Brutal Doom's imp fires FireBall_ (actors/Enemies/Imps.dec), speed 16, radius 4, whose own sprite is
	// TNT1 -- what you see is its trail, three puffs a tic (ImpFireBallTrail1-3, actors/MISC/Particles.dec) that are
	// invisible for their first tic and drawn for their second. So the fireball you see is one to two tics BEHIND the
	// real one: 16-32 map units (0.5-0.9 m). A fist thrown at the picture met the air where the real one had been, and
	// the real one, 1.6 x faster and a third thinner, was already at your chest (your body is 16 + 4 units from its
	// axis; a full punch reaches about 20). Now: the path is taken from LAG tics behind the missile (where you see a
	// lagging picture) to LEAD tics ahead (a fist that is early), and the reach is the glove plus at least 6 for the
	// missile plus 6.
	const HADO_LAG = 2.5;
	const HADO_LEAD = 2.0;

	// public so a probe can test it without hands (as Deliver)
	void ReturnFire(PlayerPawn pmo, RSQ_Glove g, int h, RSQ_PunchHand st, int lv)
	{
		double gr = 0.09 * RSQML.UnitsPerMetre() + RSQML.SV("rsqml_punch_pad", 4.0);
		for (int i = missiles.Size() - 1; i >= 0; i--)
		{
			let m = missiles[i];
			if (!m || !m.bMissile || m.bDestroyed) { missiles.Delete(i); continue; }
			let from = m.target;
			// only a monster's own missile (not yours, not another player's, not a flying gib nobody fired)
			if (!from || from.player || !from.bIsMonster || from.bFriendly) { if (!from || from.player) missiles.Delete(i); continue; }
			if (m.Distance3D(pmo) > 256) continue;
			// the missile's path, from where you see it to where it is about to be (event handlers tick before the
			// thinkers move it), against the glove's path this tic
			double reach = gr + max(m.radius, 6.0) + 6.0;
			double miss = SegSegDist(st.prevHand, st.hand, m.pos - m.vel * HADO_LAG, m.pos + m.vel * HADO_LEAD);
			if (RSQML.Debug() > 1) Console.Printf("RSQML hadouken test: %s %.1f from the glove's path (reach %.1f)", m.GetClassName(), miss, reach);
			if (miss > reach) continue;
			// its speed x the upgrade's (Gun Bonsai VR's RSQ_Upgrade_ReturnFire.Speed / .Mult; level 1's +15% and 150%
			// without it); it leaves from the glove, paid to that glove
			double sp = RSQML.Num("Hadouken.speed", lv, 0, 1.15);
			SendBack(pmo, m, from, st.hand, sp, RSQML.Num("Hadouken.mult", lv, 0, 1.5), g, st.vel);
			RSQML.Touch("hadouken", pmo, from);
			pmo.A_StartSound("rsqml/punch", CHAN_AUTO, 0, 1.0);
			RSQ_Buzz.Start(pmo, h, 0.8, 6);
			RSQML_Spark.Hadouken(st.hand);
			if (RSQML.Debug() > 0) { String fn = "(gone)"; if (from) fn = from.GetClassName(); Console.Printf("RSQML hadouken: %s back at %s, speed x%.2f (met %.1f from the glove's path)", m.GetClassName(), fn, sp, miss); }
		}
		for (int i = returned.Size() - 1; i >= 0; i--) if (!returned[i]) { returned.Delete(i); returnedMult.Delete(i); }
	}

	// THE SWAT (2026-11-02): the open palm moving at SWAT_MPS or more meets a monster's missile (the same window as the
	// Hadouken: from where you see it to where it is about to be) and knocks it aside: it leaves the palm sideways, the
	// way the palm was moving across its flight (or away from your middle if the palm moved along it), a quarter of its
	// old way kept so it flies on past you, at its own speed. It is yours now (it hurts what it hits, never you). The
	// Special spark, stock Doom's revenant slap (DSSKEPCH) and a knock in that hand. Not a Gun Bonsai upgrade: a base
	// move, with its own row (Open-Palm Swat, on).
	// SWAT BACK (GBOVR_TREES.md 4.1 D, a Gun Bonsai VR glove node after Guard): a glove that has it sends the swatted
	// missile at its shooter instead of aside, at RSQ_Upgrade_SwatBack.Mult, paid to that glove. Public so a probe can test
	// it without hands (as Deliver).
	const SWAT_MPS = 1.5;
	void Swat(PlayerPawn pmo, RSQ_Glove g, int h, RSQ_PunchHand st)
	{
		int sbLv = RSQML.GBLevel(g, "SwatBack");
		double gr = 0.09 * RSQML.UnitsPerMetre() + RSQML.SV("rsqml_punch_pad", 4.0);
		for (int i = missiles.Size() - 1; i >= 0; i--)
		{
			let m = missiles[i];
			if (!m || !m.bMissile || m.bDestroyed) { missiles.Delete(i); continue; }
			let from = m.target;
			if (!from || from.player || !from.bIsMonster || from.bFriendly) { if (!from || from.player) missiles.Delete(i); continue; }
			if (m.Distance3D(pmo) > 256) continue;
			double reach = gr + max(m.radius, 6.0) + 6.0;
			double miss = SegSegDist(st.prevHand, st.hand, m.pos - m.vel * HADO_LAG, m.pos + m.vel * HADO_LEAD);
			if (miss > reach) continue;
			if (sbLv > 0 && from.health > 0)
			{
				SendBack(pmo, m, from, st.hand, 1.0, RSQML.Num("SwatBack.mult", sbLv, 0, 1.15), g, st.vel);
				pmo.A_StartSound("rsqml/swat", CHAN_AUTO, CHANF_OVERLAP, 1.0);
				RSQ_Buzz.Start(pmo, h, 0.6, 5);
				RSQML_Spark.Swat(st.hand);
				RSQML.Touch("swat.back", pmo, from);
				if (RSQML.Debug() > 0) { String fn = from.GetClassName(); Console.Printf("RSQML swat back: %s at %s (level %d)", m.GetClassName(), fn, sbLv); }
				continue;
			}
			double sp = max(m.vel.Length(), 1.0);
			Vector3 inDir = m.vel / sp;
			Vector3 lat = st.vel - inDir * (st.vel dot inDir);
			lat.z *= 0.3;
			if (lat.Length() < 1.0)
			{
				Vector2 side = st.hand.xy - pmo.pos.xy;
				lat = (side.x, side.y, 0);
			}
			if (lat.Length() < 0.001) lat = (-inDir.y, inDir.x, 0);
			Vector3 dir = (lat.Unit() + inDir * 0.25).Unit();
			Vector3 at = st.hand + dir * (m.radius + 2);
			m.SetOrigin((at.x, at.y, max(at.z, m.floorz)), true);
			m.target = pmo;
			m.vel = dir * sp;
			m.angle = VectorAngle(dir.x, dir.y);
			m.pitch = -asin(clamp(dir.z, -1.0, 1.0));
			missiles.Delete(i);
			pmo.A_StartSound("rsqml/swat", CHAN_AUTO, CHANF_OVERLAP, 1.0);
			RSQ_Buzz.Start(pmo, h, 0.6, 5);
			RSQML_Spark.Swat(st.hand);
			if (RSQML.Debug() > 0) Console.Printf("RSQML swat: %s knocked aside (%.0f degrees off its way), palm %.1f m/s", m.GetClassName(), acos(clamp(dir dot inDir, -1.0, 1.0)), st.vel.Length() / RSQML.UnitsPerMetre());
		}
	}

	// A swing that ended without touching anything breaks a One-Two.
	void Whiff(PlayerPawn pmo, int h)
	{
		int pn = pmo.PlayerNumber();
		chainCount[pn] = 0;
	}

	// ---- A PUNCH LANDS ------------------------------------------------------------------------
	// Everything a landed punch is, decided here and written onto the glove, then one DamageMobj with the glove as
	// the inflictor: with Gun Bonsai VR loaded, Gun Bonsai credits that glove (a weapon naming itself is its own
	// claim) and its glove upgrades shape the number from what is written here (asked through RSQML_Service).
	// Public so a probe can land one without a controller.
	void Deliver(PlayerPawn pmo, RSQ_Glove g, int h, Actor victim, double avgMps, Vector3 dir, Vector3 at, Vector3 path = (0, 0, 0))
	{
		if (!pmo || !g || !victim || victim.health <= 0) return;
		int pn = pmo.PlayerNumber();
		int now = level.maptime;
		double minSpeed = RSQML.SV("rsqml_punch_min_speed", 2.0);
		double fullSpeed = RSQML.SV("rsqml_punch_full_speed", 7.0);
		double rise = RSQML.SV("rsqml_punch_uppercut_rise", 0.5);   // spo_uppercut_rise's default

		Vector2 toFoe = victim.pos.xy - pmo.pos.xy;
		double tl = toFoe.Length();
		toFoe = tl > 0.5 ? toFoe / tl : (cos(pmo.angle), sin(pmo.angle));

		g.lastHand = h;
		g.lastSpeed = avgMps;
		g.lastPower = clamp((avgMps - minSpeed) / max(fullSpeed - minSpeed, 0.1), 0.0, 1.0);
		g.lastKind = ClassifySwing(dir, path, toFoe, rise);
		// UPPERCUT, AN UNLOCK under Gun Bonsai VR (GBOVR_TREES.md 4.1 A, owner 11-02): until that glove learns it a rising
		// punch lands as a jab (the jab's spark, no lift). Without Gun Bonsai VR every glove uppercuts, as before.
		if (g.lastKind == PK_UPPER && RSQML.UnlockLevel(g, "Uppercut") <= 0) g.lastKind = PK_JAB;
		// COMBOS (4.1 C): the kinds inside a second (Three-Hit, Finisher), and the Dempsey run (alternating hooks)
		g.lastKinds = NoteKind(pn, g.lastKind, now);
		if (g.lastKind == PK_HOOK && runCount[pn] > 0 && runHand[pn] != h && now - runTic[pn] <= DEMPSEY_TICS) runCount[pn]++;
		else runCount[pn] = g.lastKind == PK_HOOK ? 1 : 0;
		runHand[pn] = h;
		runTic[pn] = now;
		g.lastRun = runCount[pn];
		double upFrac = clamp((at.z - victim.pos.z) / max(victim.height, 1.0), 0.0, 1.0);
		g.lastBody = g.lastKind != PK_UPPER && upFrac < 0.6;
		g.lastHeight = int(upFrac * 1000);
		g.lastCounter = RSQML.InAttack(victim);

		// ONE-TWO: the other hand, inside half a second, keeps the chain; the same hand or a gap
		// starts a new one
		if (chainCount[pn] > 0 && chainLastHand[pn] != h && now - chainLastTic[pn] <= 17) chainCount[pn]++;
		else chainCount[pn] = 1;
		chainLastHand[pn] = h;
		chainLastTic[pn] = now;
		g.lastChain = chainCount[pn];

		// STAR PUNCH (a Gun Bonsai VR glove upgrade; nothing without it): an uppercut thrown with that hand's trigger
		// squeezed, while a star is banked (SuperPunchOut's StarArmed, with the trigger standing in for the grip as its
		// QZD seam does). The bank lives on the main-hand glove (saved, and kept across levels).
		let gb = RSQML.GB();
		int starLv = gb ? gb.GetInt("level", "StarPunch", 0, 0, g) : 0;
		let bank = RSQ_Glove(pmo.FindInventory("RSQ_Glove"));
		if (!bank) bank = g;
		int btn = pmo.player.cmd.buttons;
		bool squeeze = (btn & (h == 0 ? (BT_ATTACK | BT_ALTATTACK) : (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK))) != 0;
		g.lastStar = starLv > 0 && bank.bankStars > 0 && g.lastKind == PK_UPPER && squeeze;
		if (g.lastStar) bank.bankStars--;

		// THE PUNCH: Brutal Doom's own fist is MeleeStrikeNormal (10) and its strong punch
		// MeleeStrike2 (20) -- parsed from brutal22test6 Melee.dec -- so a glove runs 10 at the
		// slowest punch that counts to 20 at a full-speed one.
		// JUGGLE (4.1 A): a glove that has it re-lifts a monster this player launched, while it is still in the air inside
		// RSQ_Upgrade_Juggle's window (Gun Bonsai VR does the harder hit, asking "launch.age"; read before the blow lands)
		int jAge = RSQML.GBLevel(g, "Juggle") > 0 ? RSQML_Launched.AgeFor(victim, pn) : -1;
		bool juggle = jAge >= 0 && jAge <= JUGGLE_TICS;
		int dmg = int(RSQML.SV("rsqml_punch_damage", 10.0) * (1.0 + g.lastPower));
		// HEADLOCK UPPERCUT (Gun Bonsai VR, the off glove's node; 4.1 E): an uppercut on the monster your off hand holds
		// hits harder, lets go and launches it higher
		let hlk = RSQML_Headlock.Get();
		int huLv = 0;
		if (g.lastKind == PK_UPPER && hlk && hlk.collar[pn] == victim) huLv = RSQML.GrappleLevel(pmo, "HeadlockUppercut");
		if (huLv > 0) dmg = int(dmg * RSQML.Num("HeadlockUppercut.mult", huLv, 0, 1.75));
		// THE BERSERK PACK (owner, 2026-11-02, GBOVR_TREES.md 4.1 F): x5 while you hold it (Doom's own fist is x10; the
		// shove already reads it, shove.zs BUTT_DMG_ZERK). Before this a Berserk punch did the same 10 to 20.
		// (any PowerStrength: Gun Bonsai VR's Berserk Meter gives a timed one, a subclass)
		bool zerk = pmo.FindInventory("PowerStrength", true) != null;
		if (zerk) dmg *= 5;
		// TAUNT (Gun Bonsai VR's player node, twohand.zs): the next punch inside its window does double
		let th = RSQML_TwoHand.Get();
		if (th && th.tauntUntil[pn] >= now)
		{
			dmg *= 2;
			th.tauntUntil[pn] = 0;
			if (RSQML.Debug() > 0) Console.Printf("RSQML taunt: the punch doubled");
		}
		// RAGE (Gun Bonsai VR, 4.1 F) under the Berserk: 2 the hit-stop doubles, 3 the knock x1.5
		int rgLv = zerk ? RSQML.GBLevel(g, "Rage") : 0;
		if (RSQML.Debug() > 0) { static const String kn[] = { "jab", "hook", "uppercut" }; Console.Printf("RSQML punch lands: %s, %.2f m/s, path %.2f %.2f %.2f m", kn[g.lastKind], avgMps, path.x, path.y, path.z); }
		victim.SpawnBlood(at, VectorAngle(dir.x, dir.y), dmg);
		RSQML_Spark.Punch(g.lastKind, RSQML_Spark.OnSkin(victim, at), dir, pmo, h);   // a spark per kind of blow, along the fist (sparks.zs)
		if (juggle) RSQML_Burst.At("RSQML_Burst4", at, 0.75, RSQML_Burst.ByLevel(RSQML.GBLevel(g, "Juggle"), 3));
		victim.DamageMobj(g, pmo, dmg, 'Melee', DMG_THRUSTLESS);
		pmo.A_StartSound(g.lastStar ? "rsqml/star" : "rsqml/punch", CHAN_AUTO, 0, 1.0);
		RSQ_Buzz.Start(pmo, h, 0.5 + 0.5 * g.lastPower + (g.lastStar ? 0.5 : 0.0), g.lastStar ? 10 : 5);
		// HEAVY HANDS (pick 52): the punch stops it for a beat and throws it further. With Gun Bonsai VR: once that glove
		// has learned it, at its numbers (RSQ_Upgrade_HeavyHands.Knock / Freeze). Without: the Heavy Hands row
		// (rsqml_heavyhands, off) at level 1's (knock +25%; 2 tics, 4 for a punch at half speed or more).
		int hhLv = RSQML.MoveLevel(pmo, g, "HeavyHands", "rsqml_heavyhands");
		if (huLv > 0 && victim && victim.health > 0)
		{
			hlk.LetGo(pn);
			RSQML.Touch("headlock.launch", pmo, victim);
			if (RSQML.Debug() > 0) Console.Printf("RSQML headlock uppercut: %s let go and launched (level %d)", victim.GetClassName(), huLv);
		}
		if (victim && victim.health > 0 && !victim.bDontThrust)
		{
			double kk = (2.0 + 6.0 * g.lastPower) * clamp(100.0 / max(victim.mass, 1.0), 0.08, 2.0);
			if (hhLv > 0) kk *= RSQML.Num("HeavyHands.knock", hhLv, 0, 1.25);
			if (rgLv >= 3) kk *= 1.5;
			if (g.lastKind == PK_UPPER || juggle) Launch(victim, toFoe, g.lastPower, hhLv, pmo, g, huLv > 0 ? RSQML.Num("HeadlockUppercut.lift", huLv, 0, 1.5) : 1.0);
			else victim.vel += dir * kk;
		}
		if (hhLv > 0 && victim && victim.health > 0 && !victim.player)
		{
			int ft = int(RSQML.Num("HeavyHands.freeze", hhLv, g.lastPower, g.lastPower >= 0.5 ? 4 : 2));
			if (rgLv >= 2) ft *= 2;
			victim.freezetics = max(victim.freezetics, ft);
			if (RSQML.Debug() > 0) Console.Printf("RSQML heavy hands: %s frozen %d tics, vel %.1f", victim.GetClassName(), ft, victim.vel.xy.Length());
		}
		// WALL SPLAT (pick 54): watched while it flies; a wall that stops it hurts it (splat.zs RSQ_Splat). With Gun
		// Bonsai VR: once that glove has learned it. Without: the Wall Splat row (rsqml_wallsplat, off), at level 1.
		int wsLv = RSQML.MoveLevel(pmo, g, "WallSplat", "rsqml_wallsplat");
		if (wsLv > 0 && victim && victim.health > 0) RSQ_Splat.Arm(victim, pmo, g, wsLv);
		// RSQ SCORE's hooks for the Power branch (GBOVR_TREES.md 4.1 A; nothing without RSQ Score)
		if (victim)
		{
			if (hhLv > 0) RSQML.Touch("hit.heavy", pmo, victim);
			if (g.lastBody) RSQML.Touch("hit.body", pmo, victim);
			if (g.lastKind == PK_UPPER) RSQML.Touch("punch.uppercut", pmo, victim);
			if (juggle) RSQML.Touch("juggle", pmo, victim);
		}
		if (juggle && RSQML.Debug() > 0) { String jn = "(dead)"; if (victim) jn = victim.GetClassName(); Console.Printf("RSQML juggle: %s hit %d tics after its launch", jn, jAge); }

		// THE BANK, SuperPunchOut's rule (spo_boxer.zs TakeHit): a punch landed into an open
		// window earns a star, and so does the starFirst-th landed punch and every starEvery-th
		// after. The defaults are Soda Popinski's line, `stars 1 2` (sodapopinski.txt), capped at
		// rules.txt's `maxstars 3`. Only a glove with Star Punch banks; a star spent does not.
		// The two numbers are Gun Bonsai VR's settings (rsq_star_first / rsq_star_every, read by name).
		if (starLv > 0 && !g.lastStar)
		{
			int first = RSQML.SVI("rsq_star_first", 1), every = RSQML.SVI("rsq_star_every", 2);
			bank.bankLanded++;
			bool earn = g.lastCounter;
			if (first > 0 && bank.bankLanded == first) earn = true;
			if (every > 0 && bank.bankLanded > first && ((bank.bankLanded - first) % every) == 0) earn = true;
			if (earn && bank.bankStars < 3)
			{
				bank.bankStars++;
				pmo.A_StartSound("rsqml/star", CHAN_AUTO, 0, 0.5, ATTN_NORM, 1.5);
			}
		}
	}

	const JUGGLE_TICS = 70;   // RSQ_Upgrade_Juggle.WINDOW

	// THE UPPERCUT'S KNOCK (2026-11-02; the owner: "does it knockback? it should"): it lifts. Up 5 map units a tic at
	// the weakest uppercut to 9 at full power (gravity 1 a tic: about 0.5 to 1.4 m of air for an imp), and back 2 to 5
	// away from you, both x 100 / its mass (imp, zombieman 1; demon 0.25; baron 0.1), a BOSS x 0.3 more. Held in its
	// pain for the flight (no attacking from the air). Heavy Hands adds its 25 % as it does to any punch.
	// THE FISTS TREE (GBOVR_TREES.md 4.1 A): Uppercut's levels 2-3 and Launcher add lift (map units a tic, before the
	// weight); a glove's launch marks the monster for Launcher's landing stagger, Juggle and Meteor (launch.zs).
	static void Launch(Actor victim, Vector2 toFoe, double power, int hhLv, PlayerPawn by = null, Weapon glove = null, double liftMult = 1.0)
	{
		double heavy = clamp(100.0 / max(victim.mass, 1.0), 0.1, 1.5);
		if (victim.bBoss) heavy *= 0.3;
		if (hhLv > 0) heavy *= RSQML.Num("HeavyHands.knock", hhLv, 0, 1.25);
		int upLv = RSQML.GBLevel(glove, "Uppercut"), lnLv = RSQML.GBLevel(glove, "Launcher"), mtLv = RSQML.GBLevel(glove, "Meteor");
		double extra = RSQML.Num("Uppercut.lift", upLv, 0, 0) + RSQML.Num("Launcher.lift", lnLv, 0, 0);
		double up = (5.0 + 4.0 * power + extra) * heavy * liftMult;
		// THE CAP (owner, 2026-11-02: "cap it"): at full levels the lifts stack (Uppercut 3 + Launcher 3 with Heavy Hands'
		// knock threw an imp up at 30 map units a tic, about 16 m of air). No launch goes higher than Uppercut Lift Cap
		// (rsqml_punch_lift_cap, 3 m of air): the speed whose rise, at gravity 1 a tic, is that height (v^2 / 2 map units,
		// the vertical x pixelstretch).
		double capM = RSQML.SV("rsqml_punch_lift_cap", 3.0);
		if (capM > 0) up = min(up, sqrt(2.0 * capM * RSQML.UnitsPerMetre() / RSQML.Stretch()));
		victim.vel.z = max(victim.vel.z, up);
		victim.vel.xy += toFoe * (2.0 + 3.0 * power) * heavy;
		int air = int(2.0 * up);   // up and down again at gravity 1
		if (air >= 4) RSQML.Stagger(victim, air);
		if (by)
		{
			// the lift's burst: the uppercut's level plays its frames (Launcher's adds to it)
			if (upLv > 0)
			{
				RSQML_Burst.At("RSQML_Burst3", victim.pos + (0, 0, victim.height * 0.5), 0.75, RSQML_Burst.ByLevel(upLv + lnLv, 6));
				victim.A_StartSound("rsqml/fx/whoosh", CHAN_AUTO, CHANF_OVERLAP, 0.8);
			}
			RSQML_Launched.Mark(victim, by, glove, lnLv, mtLv);
			if (lnLv > 0) RSQML.Touch("launch", by, victim);
		}
		if (RSQML.Debug() > 0) Console.Printf("RSQML uppercut: %s launched up %.1f, back %.1f (mass %d%s; uppercut %d launcher %d meteor %d)", victim.GetClassName(), up, (2.0 + 3.0 * power) * heavy, victim.mass, victim.bBoss ? ", boss" : "", upLv, lnLv, mtLv);
	}

	override void PlayerEntered(PlayerEvent e)
	{
		// a new map: the chain and the pose history are this map's (the bank is on the glove, kept)
		if (e.PlayerNumber < 0 || e.PlayerNumber >= MAXPLAYERS) return;
		chainCount[e.PlayerNumber] = 0;
		runCount[e.PlayerNumber] = 0;
		for (int i = 0; i < 3; i++) { histKind[e.PlayerNumber * 3 + i] = 0; histTic[e.PlayerNumber * 3 + i] = 0; }
		for (int h = 0; h < 2; h++) HandOf(e.PlayerNumber, h).prevValid = false;
	}
}
