// RS real VR reload (RSR) on QuestZDoom 17.3, no engine changes (team/reload/DESIGN.md).
//
// The gun's own magazine (drum, cell) drops out of the well and falls to the floor as the
// gun's own mesh. The off hand takes a new one, brings it to the well and pushes it home.
// Then, when the set's own rule says so, the hand takes the charging handle / slide / bolt
// and pulls it back. Every sound is the set's own, played when the hand does the thing;
// firing is the set's own. Out of VR, or with rsr_reload 0, the gun's own reload runs
// unchanged. The hand takes hold by the input rule (RSR.GripCanGrab): the off trigger
// anywhere, the off grip only where its press cannot start the engine's steadying.
//
// This file is the shared plumbing and names no gun. Per gun: rsr_guns.zs and MODELDEF.rsr
// (team/reload/tools/gen_rsr.py), and a few states in its weapon file (tools/rsr_patch.py):
//   its Reload goes to RSR_Start after all of its own checks (RSR_Start: decide);
//   RSR_Out gives RSR_MagOut when there is a magazine in the gun, then the set's own
//   counts take its rounds back to the reserve (a chambered round stays);
//   RSR_Wait holds the gun ("####" "#") and gives RSR_Tick every tic;
//   RSR_Seated (given here) makes it run the set's own fill loop, then give RSR_Filled;
//   RSR_Done (given here) ends at the set's own end of a reload.
// Positions: cm in the weapon controller's frame, F forward, L left, U up (rsr_guns.zs).

class RSR abstract
{
	// layers (rsq/hands.zs owns 2100, 2101, 2200)
	const WELLMAG = 2102;	// RSR_GunParts, main controller: the magazine at / in the well
	const HANDLE = 2103;	// RSR_GunParts: the charging handle (when it is its own surface)
	const BOLT = 2104;		// RSR_GunParts: the bolt carrier that moves with it
	const FREEHAND = 2200;	// RSQ_Hands: the free hand
	const HANDMAG = 2201;	// RSQ_Hands (the off-hand weapon), off controller: the magazine in the hand
	const LAYER_FIRST = 2102;
	const LAYER_LAST = 2104;

	// phases
	const IDLE = 0;
	const DROP = 1;			// the magazine slides out of the well
	const EMPTY = 2;		// no magazine; the hand goes for one
	const CARRY = 3;		// a magazine in the hand
	const INSERT = 4;		// the magazine in the well, as far as the hand puts it
	const SEATED = 5;		// home; the weapon fills it
	const CHARGE = 6;		// the hand goes for the handle
	const PULL = 7;			// the handle in the hand
	const RELEASED = 8;		// the handle springs forward
	const DONE = 9;

	const WEAPONTOP = 32;	// a layer drawn at y = 0 is tilted (hw_weapon.cpp: (my - WEAPONTOP) / -4)

	// 2026-10-27 (owner 19:40: the Unmaker skull "clearly visible while carried, like RS VR Reload"). Only
	// row 13 turns its part in the hand. RS VR Reload's Unmaker hand set (CVARINFO wm_ha_bfg_off_mag_yaw -75,
	// _pitch 15, _roll 0; GZDoom angles, about the skull's centre) as the HANDMAG layer's hook rotation, and
	// the skull re-seated -4 F +4 L +6 U cm on Ermac's pod hold so it touches the fingers and is seen from four
	// head positions 100/100/100/93% (was 83/96/100/32%): tools/handfit/unmaker/skull_turn.py, which also gives
	// rsr_guns row 13 HandHook / TopInHand. Round 3 (owner 20:15): the CARRIED skull is drawn 1.4x (MODELDEF.rsr
	// RSQ_Hands Scale; re-seated -6 F +6 L +6 U so it still touches), the insert check stays the normal skull's
	// (TopInHand = its top about the same centre). HandAxis: the skull's insertion axis in the off hand's frame
	// (the turn applied to Axis(13)), so MagAtWell judges the skull as it is drawn. Every other row: unturned.
	clearscope static Vector3 HandRot(int i)
	{
		return i == 13 ? (75.0, -15.0, 0.0) : (0, 0, 0);
	}
	clearscope static Vector3 HandAxis(int i)
	{
		return i == 13 ? (-0.0670, 0.2500, -0.9659) : RSR_Guns.Axis(i);
	}

	// cm, degrees
	const POUCH_MIN = 20.0;		// a magazine is taken at least this far from the well
	const POUCH_LOW = 40.0;		// rsr_pouch 1: this far below the eyes
	const ENTER_SIDE = 3.5;		// the magazine's top within this of the well's axis goes in
	const ENTER_ABOVE = 1.5;	// ...through the mouth: from no higher than this above it
	const ENTER_BELOW = 6.0;	// ...and no further than this below it
	const ENTER_ANGLE = 35.0;	// ...pointing within this of the axis
	const LEAVE_SIDE = 5.5;		// further off the axis than this: back in the hand
	const LEAVE_BELOW = 9.0;	// pulled further out than this below the mouth: back in the hand
	const SEAT = 0.6;			// home within this
	const GRAB_HANDLE = 7.0;	// the hand within this of the handle takes it
	const LEAVE_HANDLE = 12.0;	// the hand further than this from the handle's track lets go
	const LOCK_TUG = 1.5;		// 1.23: cm the hand pulls a locked-back slide/bolt to release it
	const RACKED = 0.85;		// of the handle's travel: far enough back to chamber a round
	const SPRING = 4.0;			// cm a released handle goes forward per tic
	const DROP_TICS = 4;
	const DROP_CM = 24.0;		// how far the old magazine slides in DROP_TICS before it falls free
	const STEADY_RANGE = 50.0;	// the engine steadies on an off-grip press with the controllers closer than this

	// the off hand's frame (the free hand's MODELDEF placement): the middle of the closed hand
	clearscope static Vector3 PalmGrab() { return (-1.5, 2.0, -4.5); }

	clearscope static int PlayerInt(PlayerInfo p, Name n, int def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetInt() : def;
	}

	// 2.0.3u THE RIG'S AMMO POUCH (owner 2026-11-03 20:46): with RSQ Tactical Rig loaded and its Ammo Pouch on, every reload
	// that fetches from the belt -- magazines, drums and boxes (vreload), shotgun shells (rsr_pump), break-open and cylinder
	// rounds (rsr_break), the rifle's underbarrel grenade (rsr_m203) -- takes ONLY from the pouch, left of the rig's belt
	// buckle: a press anywhere else, other rig places included, gives nothing. Asked by name (RSQTR_RigService "pouch.at",
	// the OFF hand: 1 in the pouch, 0 not, -1 no pouch), so this mod needs nothing loaded; with no answer (no rig, its pouch
	// off, out of VR) and with "Ammo From the Rig's Pouch Only" off (rsr_rig_pouch), each reload keeps its own rule exactly.
	// Returns 1 take it, 0 refuse, -1 the reload's own rule decides.
	play static int RigPouch(PlayerPawn mo)
	{
		if (!mo || !mo.player || PlayerInt(mo.player, 'rsr_pouch', 0) != 2	/* this pack: New magazine from = Tactical Rig's pouch */)
			return -1;
		let it = ServiceIterator.Find("RSQTR_RigService");
		Service s;
		while (s = it.Next())
			return s.GetInt("pouch.at", "", 1, 0, mo);
		return -1;
	}

	// 1.17 (owner): "Grab ammo with" (rsr_grab_with): 0 the off trigger, 1 the off grip (away
	// from the engine's steadying range, as 1.14), 2 the Use key (intercepted only while a reload
	// has the hand). One of the three, never a mix. The grenade ring keeps the off trigger.
	clearscope static int GrabWith(PlayerInfo p)
	{
		return PlayerInt(p, 'rsr_grab_with', 0);
	}

	// the usercmd buttons that grab: the off trigger, only when it is the chosen way
	clearscope static int GrabMask(PlayerInfo p)
	{
		return GrabWith(p) == 0 ? PlayerInt(p, 'rsr_grab_buttons', BT_OFFHANDATTACK) : 0;
	}

	clearscope static double Float(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	clearscope static bool Debug(PlayerInfo p)
	{
		return PlayerInt(p, 'rsr_debug', 0) != 0;
	}

	// INPUT RULE (DESIGN.md "Inputs"). Stock two-hand steadying stays as it is: the engine
	// steadies when the off grip is PRESSED with the controllers within STEADY_RANGE
	// (vr_two_handed_weapons on), and lets go when the grip is released. So:
	//   the off trigger (rsr_grab_buttons, BT_OFFHANDATTACK) grabs anywhere;
	//   the off grip grabs only when its press cannot start steadying: the controllers at
	//   least STEADY_RANGE apart (the engine's own distance), or vr_two_handed_weapons 0
	//   (read, never written). That grip then holds until it is released;
	//   a steadied grip (WF_TWOHANDSTABILIZED) is never a grab.
	play static bool GripCanGrab(PlayerPawn mo)
	{
		let cv = CVar.FindCVar('vr_two_handed_weapons');
		if (!cv || !cv.GetBool())
			return true;
		return RSVR_VRHand.SteadyGap(mo) >= STEADY_RANGE;
	}

	static String PhaseName(int ph)
	{
		static const String n[] = { "IDLE", "DROP", "EMPTY", "CARRY", "INSERT", "SEATED", "CHARGE", "PULL", "RELEASED", "DONE" };
		return ph >= 0 && ph < n.Size() ? n[ph] : "?";
	}

	// a layer the reload owns: shown with a sprite and frame of the gun's own model
	// (MODELDEF.rsr), or gone (st null)
	play static void SetPart(PlayerInfo p, int id, Actor caller, bool show, Name spr, int frame)
	{
		let psp = p.FindPSprite(id);
		if (!show || !caller)
		{
			if (psp)
				p.SetPsprite(id, null);
			return;
		}
		let st = GetDefaultByType('RSR_PartStates').FindState("Part");
		if (!psp || psp.Caller != caller || psp.CurState != st)
		{
			p.SetPsprite(id, st, false, caller);
			psp = p.FindPSprite(id);
			if (!psp)
				return;
			psp.bAddWeapon = false;
			psp.bAddBob = true;
			psp.x = 0;
			psp.oldx = 0;
			psp.y = WEAPONTOP;
			psp.oldy = WEAPONTOP;
		}
		psp.Sprite = Actor.GetSpriteIndex(spr);
		psp.Frame = frame;
	}

	// "RIFG A" -> sprite, frame
	play static bool SpriteOf(String s, out SpriteID spr, out int fr)
	{
		Array<String> w;
		s.Split(w, " ", TOK_SKIPEMPTY);
		if (w.Size() < 2)
			return false;
		spr = Actor.GetSpriteIndex(w[0]);
		fr = w[1].ByteAt(0) - 65;
		return true;
	}

	play static bool IsReadyFrame(PSprite psp, int gun)
	{
		Array<String> list;
		RSR_Guns.ReadySprites(gun).Split(list, " ", TOK_SKIPEMPTY);
		for (int k = 0; k + 1 < list.Size(); k += 2)
		{
			if (psp.Sprite == Actor.GetSpriteIndex(list[k]) && psp.Frame == list[k + 1].ByteAt(0) - 65)
				return true;
		}
		return false;
	}
}

// one player's reload
class RSR_State play
{
	int phase;
	int gun;				// RSR_Guns index
	Weapon weap;			// the gun being reloaded
	int phaseTic;
	int lastTick;			// maptime of the weapon's last RSR_Tick
	bool racked;
	bool backSounded;
	double grabS;			// where along the handle's track the hand took it

	// the grab (RSR.GripCanGrab; synchronised: rsr_grip network events from
	// RSR_ReloadHandler.InputProcess, and usercmd buttons)
	bool netGrip;			// the off grip's key is down
	bool netUse;			// 1.17 (rsr_use_grab): the Use key, taken over while a reload has the hand, grabs
	bool gripFree;			// ...and its press could not start steadying (latched at the press)
	int netPresses;			// grip presses that grab
	int usedPresses;
	bool gripPrev;
	bool relPrev;			// mag-release buttons last tic
	Weapon resumeWeap;		// 2.0.2: the ready weapon the resume check last looked at (RSR_ReloadHandler.Resume)
	bool resumeDone;		// ...and whether it has been checked since it was selected
	int resumeTries, resumeTic;	// ...tries so far (a select animation can eat the token: Rifle SelectAnimation), last try

	// what is drawn (ui interpolates prev -> cur with ticfrac)
	double d, dPrev;		// the magazine at the well: cm out of home along the axis
	double pull, pullPrev;	// the handle: cm back
	bool slideLock;			// 1.13: the pistol ran dry, its slide is locked back until racked
	bool lockedGrab;		// 1.23: the handle was taken with the slide/bolt locked back
	int lockGun;			// the gun the locked slide belongs to (the reload may be idle)
	bool wellShown, handShown;
	Vector3 offLocal;		// the off hand, gun frame cm (the desktop test draws with it)

	// 2.0.2 (owner 2026-10-28 19:05): the 1.93 FREE CHARGE press check (rsr_freecharge) is removed.

	// this tic's controller frames (world unit vectors; the engine mirrors the left hand,
	// AttackDir / OffhandDir include it, so these are the frames the layers are drawn in)
	Vector3 F, L, U, oF, oL, oU;
	double ps, vu;

	void SetPhase(PlayerPawn mo, int ph)
	{
		if (RSR.Debug(mo.player))
			Console.Printf("rsr t%d gun %d: %s -> %s", mo.Level.maptime, gun, RSR.PhaseName(phase), RSR.PhaseName(ph));
		phase = ph;
		phaseTic = mo.Level.maptime;
	}

	void Frames(PlayerPawn mo)
	{
		ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		vu = RSR.Float('vr_vunits_per_meter', 34);
		if (vu <= 0)
			vu = 34;
		F = RSVR_VRHand.HandDir(mo, 0, 0, ps);
		L = RSVR_VRHand.HandDir(mo, 90, 0, ps);
		U = RSVR_VRHand.HandDir(mo, 0, 90, ps);
		oF = RSVR_VRHand.OffDir(mo, 0, 0, ps);
		oL = RSVR_VRHand.OffDir(mo, 90, 0, ps);
		oU = RSVR_VRHand.OffDir(mo, 0, 90, ps);
		offLocal = ToGun(RSVR_VRHand.OffPos(mo) - RSVR_VRHand.HandPos(mo));
	}

	// a world offset -> gun frame cm
	Vector3 ToGun(Vector3 w)
	{
		w.z *= ps;
		w *= 100.0 / vu;
		return (w dot F, w dot L, w dot U);
	}

	// gun frame cm -> world offset from the gun hand
	Vector3 FromGun(Vector3 c)
	{
		Vector3 w = F * c.x + L * c.y + U * c.z;
		w *= vu / 100.0;
		w.z /= ps;
		return w;
	}

	// rsr_assist_debug ONLY: a ring round a capture zone, drawn in the gun hand's frame.
	// Nothing is spawned with the cvar off, and particles are not actors: no markers.
	void ZoneRing(PlayerPawn mo, Vector3 centre, Vector3 axis, double r, Color col)
	{
		Vector3 u = abs(axis.z) < 0.9 ? (axis cross (0, 0, 1)).Unit() : (axis cross (1, 0, 0)).Unit();
		Vector3 v = (axis cross u).Unit();
		Vector3 off = RSVR_VRHand.HandPos(mo) + FromGun(centre) - mo.Pos;
		RSR_Assist.Ring(mo, off, FromGun(u * r), FromGun(v * r), col);
	}

	// a direction of the off hand's frame -> gun frame
	Vector3 OffDirInGun(Vector3 v)
	{
		Vector3 w = oF * v.x + oL * v.y + oU * v.z;
		return (w dot F, w dot L, w dot U);
	}

	// a point of the off hand's frame (cm) -> gun frame (cm)
	Vector3 OffPoint(Vector3 p)
	{
		return offLocal + OffDirInGun(p);
	}

	// the off hand is holding on: its trigger anywhere, or a grip that grabbed (RSR.GripCanGrab)
	bool Grip(PlayerPawn mo)
	{
		int mask = RSR.GrabMask(mo.player);
		bool trig = (RSVR_VRHand.Buttons(mo) & mask) != 0;
		bool grip = netGrip && gripFree && !RSVR_VRHand.Steadied(mo);
		// F11 (R1): a steadied gun is re-aimed at the off hand, so a grip can never be on a handle
		// beside the gun hand. In grip mode the off trigger takes the handle (as on the M203 tube).
		bool atHandle = (phase == RSR.CHARGE || phase == RSR.PULL) && RSR.GrabWith(mo.player) == 1
			&& (RSVR_VRHand.Buttons(mo) & BT_OFFHANDATTACK) != 0;
		return trig || grip || netUse || atHandle;
	}

	// where the magazine in the hand is against the well: depth (cm out of home along the
	// axis), distance off the axis, angle to it
	double, double, double MagAtWell()
	{
		int i = gun;
		Vector3 top = OffPoint(RSR_Guns.TopInHand(i));
		Vector3 axis = RSR_Guns.Axis(i);
		Vector3 rel = top - RSR_Guns.Well(i);
		double along = rel dot axis;
		double side = (rel - axis * along).Length();
		double c = clamp(OffDirInGun(RSR.HandAxis(i)) dot axis, -1, 1);	// 2026-10-27: the part as turned in the hand (RSR.HandAxis)
		return -along, side, acos(c);
	}

	// F11 R3: the rounds held aside when the magazine came out (RSR_Held_<gun>, given by the gun's
	// RSR_Unload) -- they go back in when a magazine is home, so they are a magazine to take.
	int HeldRounds(PlayerPawn mo)
	{
		if (!mo.player || !mo.player.ReadyWeapon)
			return 0;
		String hn = "RSR_Held_" .. mo.player.ReadyWeapon.GetClassName();
		class<Inventory> hc = hn;
		return hc ? mo.CountInv(hc) : 0;
	}

	bool CanTakeMag(PlayerPawn mo)
	{
		int i = gun;
		String res = RSR_Guns.Reserve(i);
		class<Inventory> rc = res;
		if (rc && mo.CountInv(rc) <= 0 && HeldRounds(mo) <= 0)
		{
			if (RSR.Debug(mo.player))
				Console.Printf("rsr t%d gun %d: no magazine to take, reserve %s is empty",
					mo.Level.maptime, i, res);
			return false;
		}
		int rp = RSR.RigPouch(mo);
		if (rp >= 0)
		{
			if (RSR.Debug(mo.player))
				Console.Printf("rsr t%d gun %d: the rig's pouch %s", mo.Level.maptime, i, rp == 1 ? "gives a magazine" : "only: the off hand is not in it");
			return rp == 1;
		}
		Vector3 hand = OffPoint(RSR.PalmGrab());
		if ((hand - RSR_Guns.MagCentre(i)).Length() < RSR.POUCH_MIN)
			return false;
		if (RSR.PlayerInt(mo.player, 'rsr_pouch', 0) == 1)
		{
			Vector3 op = RSVR_VRHand.OffPos(mo);
			double below = (mo.player.viewz - op.z) * ps * 100.0 / vu;
			if (below < RSR.POUCH_LOW)
				return false;
		}
		return true;
	}

	void PlaySnd(PlayerPawn mo, String snd)
	{
		if (snd == "")
			return;
		mo.A_StartSound(snd, RSR_Guns.Channel(gun));
		if (RSR.Debug(mo.player))
			Console.Printf("rsr t%d sound %s (slot %d)", mo.Level.maptime, snd, RSR_Guns.Channel(gun));
	}

	// a magazine falls: the gun's own magazine as a world actor, where it is now
	void Fall(PlayerPawn mo, Vector3 at)
	{
		Vector3 pos = RSVR_VRHand.HandPos(mo) + FromGun(at);
		let m = RSR_DroppedMag(Actor.Spawn('RSR_DroppedMag', pos));
		if (!m)
			return;
		m.sprite = Actor.GetSpriteIndex(RSR_Guns.SprWorld(gun));
		m.frame = 0;
		m.angle = atan2(F.y, F.x);
		m.pitch = -asin(clamp(F.z, -1, 1));
		m.vel = mo.vel + (0, 0, -1.5);
		m.BounceSound = RSR_Guns.SndLand(gun);
		m.target = mo;
	}

	void Buzz(PlayerPawn mo)
	{
		mo.SpawnPlayerMissile('RSVR_Buzz', mo.angle, noautoaim: true, aimflags: ALF_ISOFFHAND);
	}

	// the weapon's Reload reached RSR_Start and the real reload takes it
	void Begin(PlayerPawn mo, Weapon w, int i)
	{
		// F11: a token left by a reload that was switched away from must not end this one.
		mo.TakeInventory('RSR_Done', 999);
		mo.TakeInventory('RSR_Seated', 999);
		gun = i;
		weap = w;
		racked = false;
		backSounded = false;
		d = dPrev = 0;
		pull = pullPrev = 0;
		lockedGrab = false;
		wellShown = handShown = false;
		usedPresses = netPresses;
		gripPrev = Grip(mo);		// a grip already held is not a new grab
		lastTick = mo.Level.maptime;
		SetPhase(mo, RSR.EMPTY);
	}

	// RSR_MagOut: the gun lets its magazine go
	void MagOut(PlayerPawn mo)
	{
		PlaySnd(mo, RSR_Guns.SndOut(gun));
		d = dPrev = 0;
		wellShown = true;
		SetPhase(mo, RSR.DROP);
	}

	// RSR_Filled: the set's own loop has filled the gun. The handle next when the set's own
	// rule says so (RSR_Guns.ChargeRule: the token its weapon file gave, or always)
	void Filled(PlayerPawn mo)
	{
		class<Inventory> tc = RSR_Guns.ChargeToken(gun);
		int rule = RSR_Guns.ChargeRule(gun);
		bool charge = rule == 2 || rule == 1 && tc && mo.CountInv(tc) > 0;
		if (charge)
		{
			SetPhase(mo, RSR.CHARGE);
			return;
		}
		mo.GiveInventory('RSR_Done', 1);
		SetPhase(mo, RSR.DONE);
	}

	// RSR_Tick, every tic the weapon waits
	void Tick(PlayerPawn mo)
	{
		int now = mo.Level.maptime;
		lastTick = now;
		Frames(mo);
		dPrev = d;
		pullPrev = pull;
		bool g = Grip(mo);
		// a new hold: the grab went on, or a grip press that grabs came and went between tics
		bool press = (g && !gripPrev) || netPresses != usedPresses && !RSVR_VRHand.Steadied(mo);
		usedPresses = netPresses;
		int i = gun;
		switch (phase)
		{
		case RSR.DROP:
		{
			int t = now - phaseTic;
			double f = t / double(RSR.DROP_TICS);
			d = RSR.DROP_CM * f * f;
			if (t >= RSR.DROP_TICS)
			{
				Fall(mo, RSR_Guns.MagCentre(i) - RSR_Guns.Axis(i) * d);
				wellShown = false;
				d = dPrev = 0;
				SetPhase(mo, RSR.EMPTY);
			}
			break;
		}

		case RSR.EMPTY:
			if (press && CanTakeMag(mo))
			{
				handShown = true;
				Buzz(mo);
				SetPhase(mo, RSR.CARRY);
			}
			break;

		case RSR.CARRY:
		{
			if (!g)
			{
				// let go of it: it falls
				Fall(mo, OffPoint(RSR_Guns.TopInHand(i)) - RSR_Guns.Well(i) + RSR_Guns.MagCentre(i));
				handShown = false;
				SetPhase(mo, RSR.EMPTY);
				break;
			}
			double dd, side, ang;
			[dd, side, ang] = MagAtWell();
			// THE CAPTURE ZONE (rsr_assist.zs). A cylinder of cap cm about the well's axis,
			// from home out to cap beyond the mouth. The magazine's top inside it, pointing
			// within tilt of the axis, is CAUGHT: from here the magazine is drawn on the axis
			// at the depth the hand has reached, so the hand only pushes ALONG it.
			double cap = RSR_Assist.MagCapture(mo.player, i);
			double tilt = RSR_Assist.MagTilt(mo.player, i);
			if (RSR_Assist.Dbg(mo.player))
				ZoneRing(mo, RSR_Guns.Well(i) + RSR_Guns.Axis(i) * RSR_Guns.Mouth(i), RSR_Guns.Axis(i), cap, Color(255, 255, 255, 64));
			if (side < cap && dd < RSR_Guns.Mouth(i) + cap && dd > -0.5 * cap && ang < tilt)
			{
				handShown = false;
				wellShown = true;
				d = dPrev = dd;
				Buzz(mo);
				SetPhase(mo, RSR.INSERT);
			}
			break;
		}

		case RSR.INSERT:
		{
			double dd, side, ang;
			[dd, side, ang] = MagAtWell();
			if (!g)
			{
				// let go before it is home: it falls out
				Fall(mo, RSR_Guns.MagCentre(i) - RSR_Guns.Axis(i) * d);
				wellShown = false;
				d = dPrev = 0;
				SetPhase(mo, RSR.EMPTY);
				break;
			}
			double cap = RSR_Assist.MagCapture(mo.player, i);
			double leave = RSR_Assist.Leave(mo.player, cap);
			if (RSR_Assist.Dbg(mo.player))
				ZoneRing(mo, RSR_Guns.Well(i) + RSR_Guns.Axis(i) * RSR_Guns.Mouth(i), RSR_Guns.Axis(i), cap, Color(255, 64, 255, 64));
			if (side > leave || dd > RSR_Guns.Mouth(i) + leave)
			{
				wellShown = false;
				handShown = true;
				d = dPrev = 0;
				SetPhase(mo, RSR.CARRY);
				break;
			}
			d = max(dd, 0);
			// home: SeatFrac of the way in from the mouth, but never looser than RSR.SEAT cm
			double seat = RSR_Assist.SeatAt(RSR_Guns.Mouth(i), RSR_Assist.MagSeatFrac(mo.player, i), RSR.SEAT);
			if (d <= seat)
			{
				d = dPrev = 0;
				wellShown = false;
				PlaySnd(mo, RSR_Guns.SndIn(i));
				Buzz(mo);
				mo.GiveInventory('RSR_Seated', 1);
				SetPhase(mo, RSR.SEATED);
			}
			break;
		}

		case RSR.CHARGE:
			if (press)
			{
				Vector3 rel = OffPoint(RSR.PalmGrab()) - RSR_Guns.Grab(i);
				if (rel.Length() < RSR_Assist.MagGrab(mo.player, i))
				{
					grabS = rel dot RSR_Guns.Pull(i);
					racked = false;
					backSounded = false;
					pull = pullPrev = 0;
					// 1.23 (owner): taking a slide that is locked back must not close it. It stays
					// open in the hand; a short tug back racks it (the sound), letting go then
					// sends it home. A slide (no separate bolt) is drawn all the way back meanwhile.
					lockedGrab = slideLock;
					if (lockedGrab && RSR_Guns.BoltRatio(i) <= 0)
						pull = pullPrev = RSR_Guns.Travel(i);
					Buzz(mo);
					SetPhase(mo, RSR.PULL);
				}
			}
			break;

		case RSR.PULL:
		{
			Vector3 pd = RSR_Guns.Pull(i);
			Vector3 rel = OffPoint(RSR.PalmGrab()) - RSR_Guns.Grab(i);
			double s = rel dot pd;
			double side = (rel - pd * s).Length();
			double travel = RSR_Guns.Travel(i);
			if (lockedGrab)
			{
				// the slide (or bolt) is held open by the lock; the hand's tug back releases it
				pull = RSR_Guns.BoltRatio(i) <= 0 ? travel : clamp(s - grabS, 0, travel);
				if (!racked && s - grabS >= RSR.LOCK_TUG)
				{
					racked = true;
					backSounded = true;
					PlaySnd(mo, RSR_Guns.SndBack(i));
					Buzz(mo);
				}
				if (!g || side > RSR_Assist.Leave(mo.player, RSR_Assist.MagGrab(mo.player, i)) * 1.2)
					SetPhase(mo, RSR.RELEASED);
				break;
			}
			pull = clamp(s - grabS, 0, travel);
			if (!backSounded && pull >= RSR_Guns.BackAt(i) * travel)
			{
				backSounded = true;
				PlaySnd(mo, RSR_Guns.SndBack(i));
			}
			if (pull >= RSR_Assist.MagPullFrac(mo.player, i) * travel && !racked)
			{
				racked = true;
				Buzz(mo);
			}
			if (!g || side > RSR_Assist.Leave(mo.player, RSR_Assist.MagGrab(mo.player, i)) * 1.2)
				SetPhase(mo, RSR.RELEASED);
			break;
		}

		case RSR.RELEASED:
			if (lockedGrab && !racked)
			{
				// let go without the tug: it is still locked open, waiting for the hand
				pull = pullPrev = 0;
				lockedGrab = false;
				slideLock = true;
				SetPhase(mo, RSR.CHARGE);
				break;
			}
			pull = max(0, pull - RSR.SPRING);
			if (pull <= 0)
			{
				if (racked)
				{
					PlaySnd(mo, RSR_Guns.SndFwd(i));
					mo.GiveInventory('RSR_Done', 1);
					SetPhase(mo, RSR.DONE);
				}
				else
					SetPhase(mo, RSR.CHARGE);
			}
			break;
		}
		gripPrev = g;
	}

	// the weapon left the reload (switched away, died, ...): put everything away
	void Abort(PlayerPawn mo)
	{
		mo.TakeInventory('RSR_Done', 999);	// F11: see Begin
		mo.TakeInventory('RSR_Seated', 999);
		if (phase == RSR.DROP || phase == RSR.INSERT)
			Fall(mo, RSR_Guns.MagCentre(gun) - RSR_Guns.Axis(gun) * d);
		else if (phase == RSR.CARRY)
			Fall(mo, OffPoint(RSR_Guns.TopInHand(gun)) - RSR_Guns.Well(gun) + RSR_Guns.MagCentre(gun));
		End(mo);
	}

	void End(PlayerPawn mo)
	{
		if (phase != RSR.IDLE)
			SetPhase(mo, RSR.IDLE);
		weap = null;
		wellShown = handShown = false;
		d = dPrev = pull = pullPrev = 0;
		lockedGrab = false;
		netGrip = false;
		netUse = false;		// F11: a release lost in a menu must not latch the grab
	}

	// after the psprites have ticked (RSR_ReloadHandler.WorldTick): what the gun and the layers show
	void Draw(PlayerPawn mo)
	{
		let p = mo.player;
		let w = p.ReadyWeapon;
		int i = RSR_Guns.Index(w);
		let psp = p.FindPSprite(PSP_WEAPON);
		bool active = phase != RSR.IDLE && w && w == weap;

		// 1.13 (owner): SLIDE / BOLT LOCK, on the guns that have one for real: the pistol (slide),
		// the rifle (bolt; its charging handle stays forward), the SMG and (1.14, owner) the assault
		// shotgun. MP40 is open-bolt and hidden. A gun fired dry locks back, and it stays back
		// through the magazine change until the hand racks it (taking the slide frees it; the
		// rack then springs it home as before). Out of VR reloading, a refilled gun frees it.
		if ((i == 1 || i == 2 || i == 3 || i == 5) && psp)
		{
			class<Inventory> ma = RSR_Guns.MagAmmo(i);
			int loaded = ma ? mo.CountInv(ma) : 1;
			if (!active && loaded <= 0 && RSR.IsReadyFrame(psp, i))
				slideLock = true;
			// 1.23: a locked slide taken in the hand stays locked until the tug racks it
			if (active && (phase == RSR.PULL || phase == RSR.RELEASED) && (!lockedGrab || racked) || !active && loaded > 0)
				slideLock = false;
		}
		else if (!active)
			slideLock = false;
		lockGun = slideLock ? i : 0;

		if (psp && i > 0)
		{
			Name gs = RSR_Guns.SprGun(i);
			if (active && psp.CurState == w.FindState("RSR_Wait"))
			{
				if (phase >= RSR.DROP && phase <= RSR.INSERT)
				{
					psp.Sprite = Actor.GetSpriteIndex(gs);		// the gun without its magazine
					psp.Frame = slideLock ? 2 : 0;				// (and without its slide: locked back)
				}
				else if (phase == RSR.PULL || phase == RSR.RELEASED)
				{
					if (RSR_Guns.HandleLayers(i))
					{
						psp.Sprite = Actor.GetSpriteIndex(gs);	// without the handle: it is on its own layers
						psp.Frame = 1;
					}
					else
					{
						int f = RSR_Guns.HandleFrame(i, pull);	// the gun's own frames with the bolt back
						if (f > 0)
						{
							psp.Sprite = Actor.GetSpriteIndex(gs);
							psp.Frame = f;
						}
						else
							ShowReady(psp, i);
					}
				}
				else if (slideLock)
				{
					psp.Sprite = Actor.GetSpriteIndex(gs);		// slide locked back: on its own layer
					psp.Frame = 1;
				}
				else
					ShowReady(psp, i);
			}
			else if (!active && slideLock && RSR.IsReadyFrame(psp, i))
			{
				class<Inventory> nm = RSR_Guns.NoMag(i);
				psp.Sprite = Actor.GetSpriteIndex(gs);
				psp.Frame = nm && mo.CountInv(nm) > 0 ? 2 : 1;	// no slide (and no magazine if it is out)
			}
			else if (!active && RSR_Guns.NoMag(i) != "")
			{
				// no magazine in the gun (left mid-reload, or the set's own unload): its
				// ready frame shows the well empty
				class<Inventory> nm = RSR_Guns.NoMag(i);
				if (nm && mo.CountInv(nm) > 0 && RSR.IsReadyFrame(psp, i))
				{
					psp.Sprite = Actor.GetSpriteIndex(gs);
					psp.Frame = 0;
				}
			}
		}

		let parts = RSR_GunParts(mo.FindInventory('RSR_GunParts'));
		if (!parts && (active || slideLock))
		{
			mo.GiveInventory('RSR_GunParts', 1);
			parts = RSR_GunParts(mo.FindInventory('RSR_GunParts'));
		}
		int gi = active ? gun : slideLock ? lockGun : 0;
		Name sp = gi > 0 ? RSR_Guns.SprPart(gi) : 'TNT1';
		bool handle = (active && (phase == RSR.PULL || phase == RSR.RELEASED) || slideLock) && RSR_Guns.HandleLayers(gi);
		RSR.SetPart(p, RSR.WELLMAG, parts, active && wellShown, sp, 0);
		RSR.SetPart(p, RSR.HANDLE, parts, handle, sp, 1);
		RSR.SetPart(p, RSR.BOLT, parts, handle && RSR_Guns.BoltRatio(gi) > 0, sp, 2);
		Actor hands = p.OffhandWeapon;
		RSR.SetPart(p, RSR.HANDMAG, hands is 'RSQ_Hands' ? hands : null, active && handShown, sp, 0);
	}

	void ShowReady(PSprite psp, int i)
	{
		SpriteID spr;
		int fr;
		Array<String> list;
		RSR_Guns.ReadySprites(i).Split(list, " ", TOK_SKIPEMPTY);
		if (list.Size() < 2)
			return;
		psp.Sprite = Actor.GetSpriteIndex(list[0]);
		psp.Frame = list[1].ByteAt(0) - 65;
	}
}

// what the weapon gives itself to talk to the reload; never kept
class RSR_Call : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		let mo = PlayerPawn(toucher);
		if (mo && mo.player)
			Called(mo, RSR_ReloadHandler.StateOf(mo));
		return false;
	}

	virtual void Called(PlayerPawn mo, RSR_State s) {}
}

class RSR_Start : RSR_Call
{
	override void Called(PlayerPawn mo, RSR_State s)
	{
		let w = mo.player.ReadyWeapon;
		int i = RSR_Guns.Index(w);
		if (!s || i <= 0 || !RSR_ReloadHandler.Wanted(mo)
			|| RSQ_Counters.IsNonStd(w) && !RSQ_Counters.NonStdOn(mo))	// 1.99x: "Reload Non-Standard Guns" off
		{
			// say why: this used to fail silently, and a stale off-hand weapon killed
			// reloading for the rest of the life with nothing on screen to show it
			if (RSR.Debug(mo.player))
			{
				let oh = mo.player.OffhandWeapon;
				Console.Printf("rsr t%d: reload refused (gun %d, off hand %s)",
					mo.Level.maptime, i, oh ? oh.GetClassName() : 'none');
			}
			return;			// the set's own reload
		}
		s.Begin(mo, w, i);
		mo.GiveInventory('RSR_Go', 1);
	}
}

class RSR_MagOut : RSR_Call
{
	override void Called(PlayerPawn mo, RSR_State s)
	{
		if (s && s.phase != RSR.IDLE)
			s.MagOut(mo);
	}
}

class RSR_Tick : RSR_Call
{
	override void Called(PlayerPawn mo, RSR_State s)
	{
		if (!s)
			return;
		if (s.phase == RSR.IDLE)
		{
			// the gun is in its wait states without a reload (a saved game, ...): end it
			mo.GiveInventory('RSR_Done', 1);
			return;
		}
		s.Tick(mo);
	}
}

class RSR_Filled : RSR_Call
{
	override void Called(PlayerPawn mo, RSR_State s)
	{
		if (s && s.phase != RSR.IDLE)
			s.Filled(mo);
	}
}

// what the reload tells the weapon (the weapon takes them)
class RSR_Go : RSVR_Token {}
class RSR_Seated : RSVR_Token {}
class RSR_Done : RSVR_Token {}
// the weapon file's "the handle is still to be pulled" for a set that has no item of its
// own for it (BD22 pistol, SMG); kept when the gun is put away, so the next reload goes
// straight to the handle
class RSR_Charge : RSVR_Token {}

// owns the reload's layers on the main controller (the way RSQ_GunSide owns the hands)
class RSR_GunParts : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
	}

}

// the state every reload layer shows (its sprite and frame set per gun). A weapon's state,
// so a layer whose caller is the off-hand weapon may show it (p_pspr.cpp SetState refuses
// non-weapon states there); never given.
class RSR_PartStates : Weapon
{
	Default
	{
		+WEAPON.CHEATNOTWEAPON
		+WEAPON.NO_AUTO_SWITCH
		+WEAPON.NOAUTOSWITCHTO
		+INVENTORY.UNDROPPABLE
		Weapon.SelectionOrder 32001;
	}

	States
	{
	Part:
		TNT1 A -1;		// sprite and frame set per gun (rsr_guns.zs RSR_GunSprites has every name)
		Stop;
	}
}

// the gun's own magazine, dropped: the same mesh and surface, at world scale (MODELDEF.rsr)
class RSR_DroppedMag : Actor
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		Mass 1;
		Projectile;
		-NOGRAVITY
		Gravity 0.8;
		BounceType "Doom";
		BounceFactor 0.3;
		WallBounceFactor 0.3;
		-CANBOUNCEWATER
		+MOVEWITHSECTOR
		+THRUACTORS
		+NOTELEPORT
		+NOBLOCKMONST
		+DONTSPLASH
		DeathSound "";
	}

	States
	{
	Spawn:
		"####" "#" 1;
		Loop;
	Death:
		"####" "#" 0 { pitch = 0; roll = 90; }
		"####" "#" 350;
		"####" "#" 1 A_FadeOut(0.05);
		Wait;
	}
}

class RSR_ReloadHandler : EventHandler
{
	RSR_State st[MAXPLAYERS];
	ui Array<int> gripKeys;
	ui String gripKeysFrom;
	ui bool eaten[512];
	ui bool useEaten[512];	// the Use press was SWALLOWED (the door must not get it)
	ui bool useSent[512];	// ...and, separately, whether rsr_use was sent, so the release always is

	clearscope static RSR_ReloadHandler Get()
	{
		return RSR_ReloadHandler(EventHandler.Find('RSR_ReloadHandler'));
	}

	static RSR_State StateOf(PlayerPawn mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS)
			return null;
		if (!h.st[n])
			h.st[n] = new('RSR_State');
		return h.st[n];
	}

	// Real reload is on, in VR, with the hands' off-hand weapon there to hold a magazine
	static bool Wanted(PlayerPawn mo)
	{
		if (!mo || !mo.player || RSR.PlayerInt(mo.player, 'rsr_reload', 0) != 1 || !RSVR_VRHand.InVR(mo))
			return false;
		// 1.10 (owner): BD22's purist mode has no reloading by design; ours stays out of it too.
		// One gate for all three (magazine, pump, break-open: they all ask here).
		if (mo.CountInv('IsPlayingAsPurist') > 0)
			return false;
		return mo.player.OffhandWeapon is 'RSQ_Hands';
	}

	// rsq/hands.zs Upkeep: the off-hand weapon is wanted for Real reload even with the hands off
	static bool WantsHands(PlayerPawn mo)
	{
		return mo && mo.player && RSR.PlayerInt(mo.player, 'rsr_reload', 0) == 1 && RSVR_VRHand.InVR(mo);
	}

	// 1.99x item 10 (history; the holds are FBX since 2026-10-28): which of Ermac's ammo_hand holds took the part. Frame 3 (his chaingun magazine,
	// "RsrHold") for every gun but the two whose part is a big block: the Nuker's warhead block and the
	// Hellish launcher's drum take frame 6, his BFG pod hold ("RsrHoldPod"). Each part was fitted to its
	// frame's own contact patch (translation only), so TopInHand / HandHook belong to that frame.
	clearscope static String HoldState(int i)
	{
		// off-hand FBX lane (owner 2026-10-28: the reload holds become FBX): each gun's own FBX frame round its own part
		// (MODELDEF.rsq RQHF <letter> = OhHold<letter>, tools/handfit/offhand). Was Ermac's ammo_hand 3 (RsrHold) / 6 (RsrHoldPod: 13, 15, 16).
		static const String h[] = { "RsrHold", "OhHoldA", "OhHoldB", "OhHoldC", "OhHoldD", "OhHoldE", "OhHoldF", "OhHoldG", "OhHoldH", "OhHoldI", "OhHoldJ", "OhHoldK", "OhHoldL", "OhHoldM", "OhHoldN", "OhHoldO", "OhHoldP", "OhHoldQ", "OhHoldR" };
		if (i == 19) i = 2;	// this pack: row 19 is held as the pistol is
		return i >= 1 && i < h.Size() ? h[i] : "RsrHold";
	}

	// rsq/hands.zs: the free hand's state while a reload has it ("" = not busy)
	clearscope static String FreeHand(Actor mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return "";
		int n = mo.PlayerNumber();
		let s = n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
		if (!s || s.phase == RSR.IDLE)
			return "";
		switch (s.phase)
		{
		case RSR.CARRY:
		case RSR.INSERT:
			return RSR_ReloadHandler.HoldState(s.gun);	// Ermac's hold, round the magazine (layer 2201 is the magazine)
		case RSR.PULL:
		case RSR.RELEASED:
			return "AmmoH";			// a closed hand round the handle
		}
		return "FreeHand";
	}

	// rsq/hands.zs RSQ_Hands.ModifyBobLayer3D: where the reload's layers go (ui, per frame)
	clearscope static Vector3, Vector3 Place(Actor owner, Vector3 t, Vector3 r, int layer, double ticfrac)
	{
		let h = Get();
		if (!h || !owner || !owner.player)
			return t, r;
		int n = owner.PlayerNumber();
		let s = n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
		if (!s)
			return t, r;
		int i = s.gun;
		switch (layer)
		{
		case RSR.WELLMAG:
			return t + RSR_Guns.WellHook(i) * (s.dPrev + (s.d - s.dPrev) * ticfrac), r;
		case RSR.HANDLE:
			if (s.slideLock && s.lockGun > 0)	// 1.13: locked back, all the way (a rifle's handle stays home)
				return t + RSR_Guns.HandleHook(s.lockGun) * (RSR_Guns.BoltRatio(s.lockGun) > 0 ? 0 : RSR_Guns.Travel(s.lockGun)), r;
			return t + RSR_Guns.HandleHook(i) * (s.pullPrev + (s.pull - s.pullPrev) * ticfrac), r;
		case RSR.BOLT:
			if (s.slideLock && s.lockGun > 0)	// 1.13: the bolt locked back
				return t + RSR_Guns.HandleHook(s.lockGun) * (RSR_Guns.BoltRatio(s.lockGun) * RSR_Guns.Travel(s.lockGun)), r;
			return t + RSR_Guns.HandleHook(i) * (RSR_Guns.BoltRatio(i) * (s.pullPrev + (s.pull - s.pullPrev) * ticfrac)), r;
		case RSR.HANDMAG:
			return t + RSR_Guns.HandHook(i) + DeskShift(owner, s, RSR_Guns.Scale(i)), r + RSR.HandRot(i);	// 2026-10-27: row 13 turned (RSR.HandRot)
		case RSR.FREEHAND:
			return t + DeskShift(owner, s, (-1, 1, 1)), r;
		}
		return t, r;
	}

	// TEST ONLY (rsr_test_offdraw): on a desktop both hands are drawn at the view, so move
	// the off hand's layers by where the (scripted) off hand is relative to the gun hand
	clearscope static Vector3 DeskShift(Actor owner, RSR_State s, Vector3 scale)
	{
		let cv = CVar.FindCVar('rsr_test_offdraw');
		if (!cv || !cv.GetBool())
			return (0, 0, 0);
		Vector3 c = s.offLocal;		// F L U cm
		return (-c.y / scale.x, c.z / scale.z, -c.x / scale.y);
	}

	// 2026-10-23 (owner): a new map starts clean. Level.maptime restarts at 0, so anything
	// still half-done across an exit is timed against a clock that no longer exists, and some
	// of it could never finish. This is the quiet put-away -- NOT Abort(), which drops the
	// magazine or shell into the world and would litter the new map. Fires for a loaded
	// savegame too, which is wanted.
	override void WorldLoaded(WorldEvent e)
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || !st[n])
				continue;
			st[n].End(players[n].mo);
		}
	}

	override void WorldTick()
	{
		int now = Level.maptime;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			if (!st[n])
				st[n] = new('RSR_State');
			let s = st[n];
			if (s.phase != RSR.IDLE)
			{
				bool gone = mo.health <= 0 || mo.player.ReadyWeapon != s.weap || now - s.lastTick > 2;
				if (s.phase == RSR.DONE && now - s.lastTick > 0)
					s.End(mo);
				else if (gone)
				{
					if (RSR.Debug(mo.player))
						Console.Printf("rsr t%d: the gun left the reload (%s)", now, RSR.PhaseName(s.phase));
					s.Abort(mo);
				}
			}
			MagRelease(mo, s);
			Resume(mo, s);			// 2.0.2: a gun put away without its magazine takes the hand reload back up
			s.Draw(mo);
		}
	}

	// the mag-release buttons (rsr_magrelease) start the set's own reload, which the real
	// reload then takes
	void MagRelease(PlayerPawn mo, RSR_State s)
	{
		let p = mo.player;
		int mask = RSR.PlayerInt(p, 'rsr_magrelease', (1 << 28));
		bool down = (RSVR_VRHand.Buttons(mo) & mask) != 0;
		bool edge = down && !s.relPrev;
		s.relPrev = down;
		if (!edge || s.phase != RSR.IDLE || !Wanted(mo))
			return;
		let w = p.ReadyWeapon;
		int i = RSR_Guns.Index(w);
		if (i <= 0)
			return;
		String tok = RSR_Guns.ReloadToken(i);
		class<Inventory> tc = tok;
		if (tc)
			mo.GiveInventory(tc, 1);		// BD22: its ACS turns reload into this token
		else if (p.WeaponState & WF_WEAPONRELOADOK)
		{
			let rs = w.FindState("Reload");
			if (rs)
				p.SetPsprite(PSP_WEAPON, rs);
		}
	}

	// 2.0.2 (owner item 33): "empty the mag, switch weapons without inserting a new one, switch back: you can no longer
	// grab ammo to insert". Switching away aborts the reload (WorldTick, "the gun left the reload") but the gun keeps
	// its no-magazine token (RSR_Guns.NoMag: HasUnloaded* / RSQ_NoMag_*), so it came back up empty with no reload to
	// grab into; only a trigger pull (BD22's NoAmmo -> Reload) started one again. Now, once per selection, as soon as a
	// magazine gun with no magazine is ready, its reload is started the way the mag-release button starts it: the
	// weapon's Reload -> RSR_Start -> RSR_Out sees the token and waits at EMPTY for the hand (no second magazine drops).
	// Every magazine gun (rsr 1-18) the same way; nothing changes off VR / with Real reload off (Wanted).
	void Resume(PlayerPawn mo, RSR_State s)
	{
		let p = mo.player;
		let w = p.ReadyWeapon;
		int now = mo.Level.maptime;
		if (w != s.resumeWeap)
		{
			s.resumeWeap = w;
			s.resumeDone = false;
			s.resumeTries = 0;
		}
		if (s.resumeDone || !w)
			return;
		if (s.phase != RSR.IDLE)
		{
			s.resumeDone = true;	// a reload has the gun (resumed, or the player's own)
			return;
		}
		int i = RSR_Guns.Index(w);
		if (i <= 0 || !Wanted(mo))
		{
			s.resumeDone = true;
			return;
		}
		class<Inventory> nm = RSR_Guns.NoMag(i);
		if (!nm || mo.CountInv(nm) <= 0 || RSQ_Counters.IsNonStd(w) && !RSQ_Counters.NonStdOn(mo))
		{
			s.resumeDone = true;	// it came up with its magazine: nothing to resume
			return;
		}
		// in its Ready loop (the gun's ready frame, A_WeaponReady): earlier, the select animation takes the token away
		let psp = p.FindPSprite(PSP_WEAPON);
		if (!(p.WeaponState & WF_WEAPONREADY) || !psp || !RSR.IsReadyFrame(psp, i))
			return;
		if (s.resumeTries > 0 && now - s.resumeTic < 8)
			return;
		if (++s.resumeTries >= 4)
			s.resumeDone = true;	// refused (e.g. no reserve: BD22's Reload goes back to Ready): stop asking
		s.resumeTic = now;
		if (RSR.Debug(p))
			Console.Printf("rsr t%d gun %d: selected with no magazine, the reload takes the hand again (try %d)", now, i, s.resumeTries);
		String tok = RSR_Guns.ReloadToken(i);
		class<Inventory> tc = tok;
		if (tc)
			mo.GiveInventory(tc, 1);
		else
		{
			let rs = w.FindState("Reload");
			if (rs)
				p.SetPsprite(PSP_WEAPON, rs);
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "rsr_use")
		{
			int un = e.Player;
			if (un < 0 || un >= MAXPLAYERS || !playeringame[un])
				return;
			if (!st[un])
				st[un] = new('RSR_State');
			st[un].netUse = e.Args[0] != 0;
			return;
		}
		if (e.Name != "rsr_grip")
			return;
		// 1.15 (owner): the grip kept starting the engine's two-hand steadying when reaching for a
		// shell near the gun, so it grabs only when "Grab ammo with" is set to the grip (1.17).
		if (e.Player < 0 || e.Player >= MAXPLAYERS || RSR.GrabWith(players[e.Player]) != 1)
			return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n])
			return;
		if (!st[n])
			st[n] = new('RSR_State');
		bool down = e.Args[0] != 0;
		let s = st[n];
		let mo = players[n].mo;
		if (down && !s.netGrip)
		{
			// the press grabs only where it cannot start the engine's steadying
			s.gripFree = mo && RSR.GripCanGrab(mo) && !RSVR_VRHand.Steadied(mo);
			if (s.gripFree)
				s.netPresses++;
		}
		if (!down)
			s.gripFree = false;
		s.netGrip = down;
		if (mo && RSR.Debug(players[n]))
			Console.Printf("rsr t%d grip %s (key %d)%s", Level.maptime, down ? "down" : "up", e.Args[1],
				!down ? "" : s.gripFree ? String.Format(", grabs (%.0f cm apart)", RSVR_VRHand.SteadyGap(mo))
				: RSVR_VRHand.Steadied(mo) ? ", the gun is steadied: not a grab"
				: String.Format(", within %.0f cm: the engine's steadying, not a grab", RSR.STEADY_RANGE));
	}

	// raw key events: the off-hand grip's key codes (rsr_grip_keys) become a synchronised
	// rsr_grip event. rsr_debug prints every key code, so the headset's codes can be read.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp)
			return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		int k = e.KeyScan;
		let me = players[consoleplayer];
		if (RSR.Debug(me))
			Console.Printf("rsr key %s %d (%s)", down ? "down" : "up", k, e.KeyString);
		// 1.17 (owner): "Intercept Use key". While a reload has the off hand, the Use key is the
		// grab (held = holding, like the off trigger) and does not reach doors or switches.
		// Any other time Use is untouched.
		if (k >= 0 && k < 512 && RSR.GrabWith(me) == 2 && IsUseKey(k))
		{
			if (down)
			{
				let us = consoleplayer < MAXPLAYERS ? st[consoleplayer] : null;
				// 2026-10-23 (owner: "cannot open door or use switches when the weapon isn't
				// loaded"): a reload that is RUNNING owns the Use key -- it must not open the door
				// behind the gun. But Feedable means only that a shell COULD be taken, which on a
				// part-empty gun is nearly always true, so Use was being swallowed the whole time
				// and doors stopped working. Split the two: a running reload still eats the press;
				// the merely-available ones are TOLD about it and let it through, so the same press
				// loads a shell when the hand is at the gun and opens the door when it is not.
				bool running = us && us.phase != RSR.IDLE || RSP_Handler.Busy(consoleplayer)
					|| RSB_Handler.Busy(consoleplayer) || RSK_M203Handler.Busy(consoleplayer);	// 1.34: the M203 open
				bool offers = RSP_Handler.Feedable(consoleplayer)	// 1.43: a shell to take, as the trigger would
					|| RSQB_GrenadeLink.WantsGrab(consoleplayer);		// 2026-10-23: the grenade's ring wants it too
				if (!running && !offers)
					return false;
				EventHandler.SendNetworkEvent("rsr_use", 1, k);
				useSent[k] = true;
				if (!running)
					return false;		// sent, not swallowed: the door still gets this press
				useEaten[k] = true;
				return true;
			}
			// the release always goes out if the press did, or netUse would latch on for good
			if (useSent[k])
			{
				useSent[k] = false;
				EventHandler.SendNetworkEvent("rsr_use", 0, k);
			}
			if (useEaten[k])
			{
				useEaten[k] = false;
				return true;
			}
			return false;
		}
		if (!IsGripKey(me, k))
			return false;
		EventHandler.SendNetworkEvent("rsr_grip", down ? 1 : 0, k);
		if (k < 0 || k >= 512)
			return false;
		if (down)
		{
			let s = consoleplayer < MAXPLAYERS ? st[consoleplayer] : null;
			bool busy = s && s.phase != RSR.IDLE || RSP_Handler.Busy(consoleplayer) || RSB_Handler.Busy(consoleplayer) || RSK_M203Handler.Busy(consoleplayer);	// RSR-PUMP, RSR-BREAK: their reloads have the hand too
			eaten[k] = busy && RSR.GrabWith(me) == 1 && RSR.PlayerInt(me, 'rsr_eat_grip', 1) != 0;
			return eaten[k];
		}
		bool was = eaten[k];
		eaten[k] = false;
		return was;		// only an up whose down was eaten
	}

	ui bool IsUseKey(int k)
	{
		Array<int> keys;
		Bindings.GetAllKeysForCommand(keys, "+use");
		return keys.Find(k) != keys.Size();
	}

	ui bool IsGripKey(PlayerInfo me, int k)
	{
		let cv = CVar.GetCVar('rsr_grip_keys', me);
		String keys = cv ? cv.GetString() : "443 436";
		if (keys != gripKeysFrom)
		{
			gripKeysFrom = keys;
			gripKeys.Clear();
			Array<String> w;
			keys.Split(w, " ", TOK_SKIPEMPTY);
			for (int j = 0; j < w.Size(); j++)
				gripKeys.Push(w[j].ToInt());
		}
		return gripKeys.Find(k) != gripKeys.Size();
	}
}

// RS options menu: the Reloading item (MENUDEF "RSRReload"). A plain option: it never
// touches vr_two_handed_weapons (stock steadying stays as the player set it).
class OptionMenuItemRSRReload : OptionMenuItemOption
{
}
