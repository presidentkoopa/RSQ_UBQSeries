// RSR-BREAK: the real VR reload for break-open guns and revolvers (team/reload_break/MERGE.md).
// QuestZDoom 17.3, no engine changes. Built on the real VR reload (rsr/vreload.zs): the same
// inputs (the synchronised off-hand grip, the off-hand trigger), the same off-hand frames,
// the same way of showing pieces of the gun's own model.
//
// The gun's own reload (after all of its own checks) opens the action: the hinged part (the
// barrels, the barrel, the cylinder) swings open about the hinge fitted from the set's own
// open frame, with the set's own open sound, and the spent rounds come out the way the set
// does it (BD22: its own casing actors; Vanilla VR Plus: its own rounds thrown out). The off
// hand takes a round (the gun's own, in Ermac's hold), brings it to an empty chamber, puts it
// in from behind along the bore and pushes it home: the set's own load sound, and the set's
// own step of its own loop moves the ammo. A quick turn of the gun hand the way the action
// closes (or the off hand pushing it shut) closes it, with the set's own close sound.
// Desktop, non-VR, or Stock reloading: the set's own reload, unchanged.
//
// The weapon file has (tools/rsb_patch.py):
//   its Reload goes to RSB_Start after all its own checks (RSB_Start: decide; RSB_Stock: its own);
//   RSB_Wait holds the gun ("####" "#") and gives RSB_Tick every tic;
//   RSB_EjectT (given here) makes it run the set's own casing spawns, RSB_LoadT the set's own
//   step for one round (a speedloader: its whole loop), RSB_TopUpT the set's own loop to its cap,
//   RSB_Done its own end of a reload.
// Positions: cm in the weapon controller's frame, F forward, L left, U up (rsb_guns.zs).

class RSB abstract
{
	// layers: the gun's side (RSB_GunParts, main controller), the off hand (RSQ_Hands)
	const HINGED = 2105;		// the hinged part
	const CHAMBER0 = 2106;		// 2106..2111: the round in chamber k
	const LAYER_FIRST = 2105;
	const LAYER_LAST = 2111;
	const HANDROUND = 2202;		// the round (or speedloader) in the off hand
	const HANDROUND2 = 2203;	// 2026-10-16: the second shell of a pair (double barrels)
	const MAXCH = 6;

	// phases
	const IDLE = 0;
	const OPENING = 1;
	const OPEN = 2;
	const CLOSING = 3;
	const DONE = 4;

	// what the off hand has
	const FREE = 0;
	const CARRY = 1;			// a round in the hand
	const INSERT = 2;			// the round going into a chamber, as far as the hand puts it
	const EMPTYLOADER = 3;		// V+ revolver: the loader, empty, still in the hand

	// a chamber
	const EMPTY = 0;
	const LIVE = 1;
	const SPENT = 2;

	const OPEN_TICS = 6;		// the hinged part falls open
	const CLOSE_TICS = 2;		// it swings shut
	const ENTER_SIDE = 1.4;		// cm: a round's tip this close to a chamber's bore goes in
	const ENTER_ANGLE = 30.0;	// ...pointing within this of the bore
	const LEAVE_SIDE = 2.6;		// further off the bore: back in the hand
	const LEAVE_OUT = 1.5;		// pulled back past the mouth by this: back in the hand
	const SEAT = 0.5;			// home within this
	const POUCH_MIN = 20.0;		// a round is taken at least this far from the chambers
	const POUCH_LOW = 40.0;		// rsr_pouch 1: this far below the eyes
	const STEADY_CM = 50.0;		// the engine steadies the gun on an off-grip press within this of the gun hand
	const STEADY_MARGIN = 2.0;	// ...a grip press is a grab only clear of it by this
	const FLICK_TICS = 3;		// the flick: angular speed over this many tics
	const SNAP_TURN = 20.0;		// deg in one tic about the vertical: a snap turn, not the hand
	const PUSH_SHUT = 6.0;		// deg: pushed this close, it snaps shut
	const PUSH_HAND = 5.0;		// cm: the hand's thickness at the part

	const WEAPONTOP = 32;

	clearscope static int PlayerInt(PlayerInfo p, Name n, int def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetInt() : def;
	}

	clearscope static double PlayerFloat(PlayerInfo p, Name n, double def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetFloat() : def;
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

	static String PhaseName(int ph)
	{
		static const String n[] = { "IDLE", "OPENING", "OPEN", "CLOSING", "DONE" };
		return ph >= 0 && ph < n.Size() ? n[ph] : "?";
	}

	static String HandName(int h)
	{
		static const String n[] = { "FREE", "CARRY", "INSERT", "EMPTYLOADER" };
		return h >= 0 && h < n.Size() ? n[h] : "?";
	}

	clearscope static int Count(Actor mo, String n)
	{
		class<Inventory> c = n;
		return c && mo ? mo.CountInv(c) : 0;
	}

	// the set's own items by name (the other set's classes do not exist in its build)
	play static void Give(Actor mo, String n, int k = 1)
	{
		class<Inventory> c = n;
		if (c && mo)
			mo.GiveInventory(c, k);
	}

	play static void Take(Actor mo, String n, int k = 1)
	{
		class<Inventory> c = n;
		if (c && mo)
			mo.TakeInventory(c, k);
	}

	// v turned about the unit axis a by deg (right-handed)
	clearscope static Vector3 Turn(Vector3 v, Vector3 a, double deg)
	{
		double c = cos(deg), s = sin(deg);
		return v * c + (a cross v) * s + a * ((a dot v) * (1 - c));
	}

	// a point turned about the hinge
	clearscope static Vector3 HingeTurn(int i, Vector3 p, double deg)
	{
		Vector3 h = RSB_Guns.Hinge(i);
		return h + Turn(p - h, RSB_Guns.Axis(i), deg);
	}

	// ---- 3x3 matrices as three rows

	clearscope static Vector3 Col(Vector3 r0, Vector3 r1, Vector3 r2, int j)
	{
		if (j == 0) return (r0.x, r1.x, r2.x);
		if (j == 1) return (r0.y, r1.y, r2.y);
		return (r0.z, r1.z, r2.z);
	}

	clearscope static Vector3, Vector3, Vector3 Mul(Vector3 a0, Vector3 a1, Vector3 a2, Vector3 b0, Vector3 b1, Vector3 b2)
	{
		Vector3 c0 = Col(b0, b1, b2, 0), c1 = Col(b0, b1, b2, 1), c2 = Col(b0, b1, b2, 2);
		return (a0 dot c0, a0 dot c1, a0 dot c2), (a1 dot c0, a1 dot c1, a1 dot c2), (a2 dot c0, a2 dot c1, a2 dot c2);
	}

	clearscope static Vector3 Apply(Vector3 r0, Vector3 r1, Vector3 r2, Vector3 v)
	{
		return (r0 dot v, r1 dot v, r2 dot v);
	}

	// the rotation about unit a by deg, as rows
	clearscope static Vector3, Vector3, Vector3 RotRows(Vector3 a, double deg)
	{
		Vector3 c0 = Turn((1, 0, 0), a, deg), c1 = Turn((0, 1, 0), a, deg), c2 = Turn((0, 0, 1), a, deg);
		return (c0.x, c1.x, c2.x), (c0.y, c1.y, c2.y), (c0.z, c1.z, c2.z);
	}

	// models.cpp RenderHUDModel turns yaw about y, then pitch about x, then roll about z
	// (hands.zs RSQ_Turn)
	clearscope static Vector3, Vector3, Vector3 EulerRows(Vector3 a)
	{
		double cx = cos(a.x), sx = sin(a.x);
		double cy = cos(a.y), sy = sin(a.y);
		double cz = cos(a.z), sz = sin(a.z);
		return (cx * cz + sx * sy * sz, -cx * sz + sx * sy * cz, sx * cy),
			(cy * sz, cy * cz, -sy),
			(-sx * cz + cx * sy * sz, sx * sz + cx * sy * cz, cx * cy);
	}

	clearscope static Vector3 Euler(Vector3 r0, Vector3 r1, Vector3 r2)
	{
		return (atan2(r0.z, r2.z), asin(clamp(-r1.z, -1., 1.)), atan2(r1.x, r1.y));
	}

	// The ModifyBobLayer3D hook that moves a layer's mesh (drawn with MODELDEF Scale sc,
	// Offset off) by the rigid motion p -> R p + t of the controller frame (F L U cm), and
	// keeps the incoming bob (tb, rb) on top of it, as the gun's own layer gets it.
	// Chain (models.cpp): local = K + o + S v3 + S Rot(rot) (tr + q), K = (0, 5, 30), local
	// x right y up z back, S = (sc.x, sc.z, sc.y); checked by tools/rsb_hookcheck.py.
	clearscope static Vector3, Vector3 Hook(Vector3 r0, Vector3 r1, Vector3 r2, Vector3 t, Vector3 sc, Vector3 off,
		Vector3 tb, Vector3 rb)
	{
		// into local axes: Rl = P^T R P (flu = P local: F = -z, L = -x, U = y)
		Vector3 l0 = (r1.y, -r1.z, r1.x);
		Vector3 l1 = (-r2.y, r2.z, -r2.x);
		Vector3 l2 = (r0.y, -r0.z, r0.x);
		Vector3 sv = (sc.x, sc.z, sc.y);
		// pre-scale: Rh = S^-1 Rl S
		Vector3 h0 = (l0.x, l0.y * sv.y / sv.x, l0.z * sv.z / sv.x);
		Vector3 h1 = (l1.x * sv.x / sv.y, l1.y, l1.z * sv.z / sv.y);
		Vector3 h2 = (l2.x * sv.x / sv.z, l2.y * sv.y / sv.z, l2.z);
		// (vr_3dweaponOffset moves the gun's layer and this one alike, before the turn: it stays out)
		Vector3 B = (0, 5, 30) + (off.x, off.z, off.y);
		Vector3 tl = (-t.y, t.z, -t.x);
		Vector3 w = tl - B;
		Vector3 back = l0 * w.x + l1 * w.y + l2 * w.z;	// Rl^T w
		Vector3 hs = B + back;
		Vector3 h = (hs.x / sv.x, hs.y / sv.y, hs.z / sv.z);
		// the bob on top: Rot = Rot(rb) Rh, tr = Rh^T tb + h
		Vector3 b0, b1, b2, e0, e1, e2;
		[b0, b1, b2] = EulerRows(rb);
		[e0, e1, e2] = Mul(b0, b1, b2, h0, h1, h2);
		Vector3 tbr = h0 * tb.x + h1 * tb.y + h2 * tb.z;		// Rh^T tb
		return h + tbr, Euler(e0, e1, e2);
	}

	// a layer the break reload owns: shown with a sprite and frame of the gun's own model
	// (MODELDEF.rsb), or gone
	play static void SetPart(PlayerInfo p, int id, Actor caller, bool show, Name spr, int frame)
	{
		let psp = p.FindPSprite(id);
		if (!show || !caller)
		{
			if (psp)
				p.SetPsprite(id, null);
			return;
		}
		let st = GetDefaultByType('RSB_PartStates').FindState("Part");
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
}

// one player's break reload
class RSB_State play
{
	int phase;
	int gun;					// RSB_Guns index
	Weapon weap;
	int phaseTic;
	int lastTick;
	double theta, thetaPrev;	// how far open (deg)
	int ch[6];			// EMPTY / LIVE / SPENT
	int nch;
	int loadedNow;				// rounds this reload put in
	bool ejected;
	int liveAtOpen;				// live rounds when it opened (a speedloader's set ejects them all)

	// the off hand
	int hand;
	int insCh;					// INSERT: the chamber
	bool pair;					// 2026-10-16: two shells in the hand, both barrels at once
	double s, sPrev;			// INSERT: cm short of seated, along the bore
	double sAt[6];		// CARRY: last tic, how far each chamber's mouth is from the tip (entry from behind)
	int grabSrc;				// what holds it: 1 the trigger, 2 the grip
	bool trigPrev;
	int usedPresses;
	int gripPress;				// maptime of a grip press waiting for its check (0: none)
	bool hinted;
	bool relPrev;

	// the off hand pushing the action shut
	bool pushing;
	int seatTic;				// maptime of the last round home (the hand leaving the breech is not a push)

	// the gun hand's frames, for the flick (world unit vectors)
	Array<double> hist;		// the gun hand's frames, newest first: F, L, U (9 numbers a tic)
	int hN;
	double flickSeen;			// the fastest closing turn seen this reload (deg/s), for the log
	int flickBy;				// 1 when the flick closed it, 2 the push, 3 the trigger

	int open2At, close2At;		// maptime of a second sound (the set's lever)

	// frames this tic
	Vector3 F, L, U, oF, oL, oU;
	double ps, vu;
	Vector3 offLocal;
	Vector3 tR0, tR1, tR2;		// TEST ONLY: the scripted off hand's turn in the gun hand's axes (rtest), for the desktop view

	void SetPhase(PlayerPawn mo, int ph)
	{
		if (RSB.Debug(mo.player))
			Console.Printf("rsb t%d gun %d: %s -> %s", mo.Level.maptime, gun, RSB.PhaseName(phase), RSB.PhaseName(ph));
		phase = ph;
		phaseTic = mo.Level.maptime;
	}

	void SetHand(PlayerPawn mo, int h)
	{
		if (RSB.Debug(mo.player))
			Console.Printf("rsb t%d hand %s -> %s", mo.Level.maptime, RSB.HandName(hand), RSB.HandName(h));
		hand = h;
	}

	void Frames(PlayerPawn mo)
	{
		ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		vu = RSB.Float('vr_vunits_per_meter', 34);
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

	Vector3 ToGun(Vector3 w)
	{
		w.z *= ps;
		w *= 100.0 / vu;
		return (w dot F, w dot L, w dot U);
	}

	Vector3 FromGun(Vector3 c)
	{
		Vector3 w = F * c.x + L * c.y + U * c.z;
		w *= vu / 100.0;
		w.z /= ps;
		return w;
	}

	Vector3 OffDirInGun(Vector3 v)
	{
		Vector3 w = oF * v.x + oL * v.y + oU * v.z;
		return (w dot F, w dot L, w dot U);
	}

	Vector3 OffPoint(Vector3 p)
	{
		return offLocal + OffDirInGun(p);
	}

	// the gun's own sound on its own slot, when the hand does the thing
	void PlaySnd(PlayerPawn mo, String snd)
	{
		if (snd == "")
			return;
		mo.A_StartSound(snd, RSB_Guns.Channel(gun));
		if (RSB.Debug(mo.player))
			Console.Printf("rsb t%d sound %s (slot %d)", mo.Level.maptime, snd, RSB_Guns.Channel(gun));
	}

	void Buzz(PlayerPawn mo)
	{
		RSVR_Hand.Buzz(mo, true);	// 2.0.4t: through RSQ Accessibility's Rumble Backup when it is on (melee.zs)
	}

	// ---- input

	// The grab. The off-hand trigger (rsr_grab_buttons) grabs anywhere. The off grip grabs only
	// where its press cannot start the engine's two-hand steadying: with the off controller at
	// least 50 cm from the gun controller, or with steadying off. A steadied grip is never a grab.
	// Returns: pressed now (a new grab), held.
	bool, bool Grab(PlayerPawn mo)
	{
		let p = mo.player;
		let rs = RSR_ReloadHandler.StateOf(mo);
		int mask = RSR.GrabMask(p);
		bool trig = mask != 0 && (p.cmd.buttons & mask) != 0 || rs && rs.netUse;
		bool trigPress = trig && !trigPrev;
		trigPrev = trig;
		bool steady = (p.WeaponState & WF_TWOHANDSTABILIZED) != 0;
		bool grip = rs && rs.netGrip;
		int presses = rs ? rs.netPresses : 0;
		bool gripPressNow = presses != usedPresses;
		usedPresses = presses;
		if (gripPressNow)
		{
			let cv = CVar.FindCVar('vr_two_handed_weapons');
			bool steadyOn = !cv || cv.GetBool();
			Vector3 dw = RSVR_VRHand.OffPos(mo) - RSVR_VRHand.HandPos(mo);
			dw.z *= ps;
			double cm = dw.Length() * 100.0 / vu;
			// the press waits a tic: the engine's own check may still steady the gun
			if (!steadyOn || cm >= RSB.STEADY_CM + RSB.STEADY_MARGIN)
				gripPress = mo.Level.maptime;
			else
			{
				gripPress = 0;
				if (RSB.Debug(p))
					Console.Printf("rsb t%d grip press %.0f cm from the gun hand: the engine's steadying, not a grab", mo.Level.maptime, cm);
			}
		}
		bool newGrab = false;
		if (trigPress)
		{
			newGrab = true;
			grabSrc = 1;
		}
		else if (gripPress > 0 && mo.Level.maptime > gripPress)
		{
			if (grip && !steady)
			{
				newGrab = true;
				grabSrc = 2;
			}
			gripPress = 0;
		}
		bool held = grabSrc == 1 ? trig : grabSrc == 2 ? grip && !steady : false;
		if (!held && !newGrab)
			grabSrc = 0;
		return newGrab, held;
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

	// ---- geometry of the chambers at the current opening

	Vector3 TipAt(int k, double deg) { return RSB.HingeTurn(gun, RSB_Guns.Tip(gun, k), deg); }
	Vector3 BoreAt(int k, double deg) { return RSB.Turn(RSB_Guns.Bore(gun, k), RSB_Guns.Axis(gun), deg); }
	double Depth(int k)
	{
		return RSB_Guns.Loader(gun) ? RSB_Guns.LoaderDepth(gun) : (RSB_Guns.Tip(gun, k) - RSB_Guns.Base(gun, k)).Length();
	}

	// the round in the off hand, in the gun's frame
	Vector3, Vector3 RoundInHand()
	{
		return OffPoint(RSB_Guns.HandBase(gun)), OffPoint(RSB_Guns.HandTip(gun));
	}

	// where the round in the hand is against chamber k: cm short of seated along the bore,
	// off the bore at the tip, the angle to it
	double, double, double AtChamber(int k)
	{
		Vector3 b, t;
		[b, t] = RoundInHand();
		Vector3 tk = TipAt(k, theta);
		Vector3 bk = BoreAt(k, theta);
		Vector3 rel = t - tk;
		double along = rel dot bk;
		double side = (rel - bk * along).Length();
		Vector3 u = t - b;
		double ul = u.Length();
		double ang = ul > 0 ? acos(clamp((u / ul) dot bk, -1, 1)) : 180;
		return -along, side, ang;
	}

	bool AnyEmpty()
	{
		for (int k = 0; k < nch; k++)
		{
			if (ch[k] == RSB.EMPTY)
				return true;
		}
		return false;
	}

	int LiveCount()
	{
		int n = 0;
		for (int k = 0; k < nch; k++)
		{
			if (ch[k] == RSB.LIVE)
				n++;
		}
		return n;
	}

	bool CanTakeRound(PlayerPawn mo)
	{
		int i = gun;
		if (!AnyEmpty())
			return false;
		int res = RSB.Count(mo, RSB_Guns.Reserve(i));
		// V+ super shotgun: its shells stay in the reserve until fired (its reload takes none)
		int need = RSB_Guns.ReserveHoldsLoaded(i) ? LiveCount() + 1 : 1;
		if (res < need * RSB_Guns.ReservePer(i))		// 2026-10-28: the Moonlight's round costs 3 pistol rounds
			return false;
		int rp = RSR.RigPouch(mo);		// 2.0.3u: the rig's ammo pouch only (vreload.zs RSR.RigPouch)
		if (rp >= 0)
		{
			if (RSR.Debug(mo.player))
				Console.Printf("rsb t%d gun %d: the rig's pouch %s", mo.Level.maptime, i, rp == 1 ? "gives a round" : "only: the off hand is not in it");
			return rp == 1;
		}
		Vector3 palm = OffPoint(RSR.PalmGrab());
		Vector3 mid = RSB.HingeTurn(i, (RSB_Guns.Base(i, 0) + RSB_Guns.Tip(i, 0)) / 2, theta);
		if ((palm - mid).Length() < RSB.POUCH_MIN)
			return false;
		if (RSB.PlayerInt(mo.player, 'rsr_pouch', 0) == 1)
		{
			Vector3 op = RSVR_VRHand.OffPos(mo);
			double below = (mo.player.viewz - op.z) * ps * 100.0 / vu;
			if (below < RSB.POUCH_LOW)
				return false;
		}
		return true;
	}

	// ---- world pieces: the gun's own round let go of, the set's own round thrown out

	void DropRound(PlayerPawn mo, Vector3 at, int frame)
	{
		Vector3 pos = RSVR_VRHand.HandPos(mo) + FromGun(at);
		let m = Actor.Spawn('RSB_Round', pos);
		if (!m)
			return;
		m.sprite = Actor.GetSpriteIndex(RSB_Guns.SprWorld(gun));
		m.frame = frame;
		m.angle = atan2(F.y, F.x);
		m.pitch = -asin(clamp(F.z, -1, 1));
		m.vel = mo.vel + (0, 0, -1);
	}

	void ThrowCasing(PlayerPawn mo, Vector3 at, Vector3 dirGun, double spd)
	{
		Vector3 pos = RSVR_VRHand.HandPos(mo) + FromGun(at);
		let m = Actor.Spawn('RSB_Casing', pos);
		if (!m)
			return;
		m.sprite = Actor.GetSpriteIndex(RSB_Guns.SprWorld(gun));
		m.frame = 2;
		m.angle = atan2(F.y, F.x) + frandom(-30, 30);
		m.pitch = frandom(-60, 60);
		m.roll = frandom(0, 360);
		Vector3 v = FromGun(dirGun * spd);
		m.vel = mo.vel + v;
	}

	// ---- the reload

	// the weapon's Reload reached RSB_Start and the break reload takes it
	void Begin(PlayerPawn mo, Weapon w, int i)
	{
		gun = i;
		weap = w;
		theta = thetaPrev = 0;
		nch = RSB_Guns.Chambers(i);
		loadedNow = 0;
		ejected = false;
		hand = RSB.FREE;
		pushing = false;
		flickSeen = 0;
		flickBy = 0;
		hN = 0;
		grabSrc = 0;
		gripPress = 0;
		let rs = RSR_ReloadHandler.StateOf(mo);
		usedPresses = rs ? rs.netPresses : 0;
		int mask = RSR.GrabMask(mo.player);
		trigPrev = (mo.player.cmd.buttons & mask) != 0 || rs && rs.netUse;		// a trigger already held is not a new grab
		lastTick = mo.Level.maptime;
		SetChambers(mo);
		SetPhase(mo, RSB.OPENING);
		PlaySnd(mo, RSB_Guns.SndOpen(i));
		open2At = RSB_Guns.SndOpen2(i) != "" ? mo.Level.maptime + 2 : 0;
		close2At = 0;
	}

	// what is in the chambers when it opens: the set's own count of live rounds, the rest spent
	void SetChambers(PlayerPawn mo)
	{
		int i = gun;
		int live = RSB.Count(mo, RSB_Guns.Loaded(i));
		bool unloaded = RSB_Guns.Unloaded(i) != "" && RSB.Count(mo, RSB_Guns.Unloaded(i)) > 0;
		for (int k = 0; k < RSB.MAXCH; k++)
			ch[k] = RSB.EMPTY;
		liveAtOpen = live;
		if (RSB_Guns.Loader(i))
		{
			ch[0] = RSB.SPENT;		// the cylinder's six: the ejector throws all of them
			return;
		}
		// The gun is only here because the set said it could reload, so there is somewhere to
		// put a round even when the set's count says otherwise: the last chamber reads spent.
		live = min(live, nch);
		if (live >= nch)
			live = nch - 1;
		for (int k = 0; k < nch; k++)
			ch[k] = k < live ? RSB.LIVE : unloaded ? RSB.EMPTY : RSB.SPENT;
		liveAtOpen = live;		// after the clamp, for the casings the set spawns
	}

	// at full open: the spent rounds come out the way the set does it
	void Eject(PlayerPawn mo)
	{
		ejected = true;
		int i = gun;
		int spent = 0;
		for (int k = 0; k < nch; k++)
		{
			if (ch[k] == RSB.SPENT)
				spent++;
		}
		if (RSB_Guns.Loader(i))
		{
			// the set's ejector throws all six (its own frames f20-f29); the live ones are held
			// and come back when a loader is home (the set tops up)
			for (int r = 0; RSB_Guns.WorldEject(i) && r < 6; r++)
			{
				double a = r * 60;
				Vector3 at = RSB.HingeTurn(i, RSB_Guns.Casing(i) + (0, cos(a) * 1.2, sin(a) * 1.2), theta);
				Vector3 away = -BoreAt(0, theta) + (0, frandom(-0.3, 0.3), 0.4);
				ThrowCasing(mo, at, away.Unit(), frandom(3.0, 4.5));
			}
			ch[0] = RSB.EMPTY;
			// the set's own casings where it does not throw them itself (BD22: its SSGCaseSpawner)
			// 2.0.4i (owner 11-11: "bd22 revolver empties one at a time instead of all at once on reload"): one casing
			// per EMPTY in the cylinder, all on the tic it opens (the set's count of live rounds was used here, so an
			// emptied cylinder threw one casing). The capacity is the set's own loaded count's maximum.
			int empties = 1;
			if (!RSB_Guns.WorldEject(i))
			{
				class<Inventory> lc = RSB_Guns.Loaded(i);
				int cap = lc ? GetDefaultByType(lc).MaxAmount : 6;
				empties = max(1, cap - liveAtOpen);
			}
			mo.GiveInventory('RSB_EjectT', empties);
			if (RSB.Debug(mo.player))
				Console.Printf("rsb t%d speedloader gun %d open: %d empties out (live %d)", mo.Level.maptime, i, empties, liveAtOpen);
			return;
		}
		if (spent == 0)
			return;
		if (RSB_Guns.WorldEject(i))
		{
			for (int k = 0; k < nch; k++)
			{
				if (ch[k] != RSB.SPENT)
					continue;
				Vector3 at = RSB.HingeTurn(i, (RSB_Guns.Base(i, k) + RSB_Guns.Tip(i, k)) / 2, theta);
				Vector3 away = -BoreAt(k, theta) + (0, k == 0 ? -0.3 : 0.3, 0.8);
				ThrowCasing(mo, at, away.Unit(), frandom(3.0, 4.0));
			}
		}
		else
			mo.GiveInventory('RSB_EjectT', spent);		// the set's own casing actors, from the weapon
		for (int k = 0; k < nch; k++)
		{
			if (ch[k] == RSB.SPENT)
				ch[k] = RSB.EMPTY;
		}
		if (RSB.Debug(mo.player))
			Console.Printf("rsb t%d ejected %d", mo.Level.maptime, spent);
	}

	// RSB_Tick, every tic the weapon waits
	void Tick(PlayerPawn mo)
	{
		int now = mo.Level.maptime;
		lastTick = now;
		Frames(mo);
		thetaPrev = theta;
		sPrev = s;
		int i = gun;
		bool press, held;
		[press, held] = Grab(mo);
		if (open2At > 0 && now >= open2At)
		{
			PlaySnd(mo, RSB_Guns.SndOpen2(i));
			open2At = 0;
		}
		double flick = FlickSpeed(mo);
		switch (phase)
		{
		case RSB.OPENING:
		{
			int t = now - phaseTic;
			double f = clamp(t / double(RSB.OPEN_TICS), 0, 1);
			theta = RSB_Guns.OpenDeg(i) * f * f;		// it falls open
			if (t >= RSB.OPEN_TICS)
			{
				theta = RSB_Guns.OpenDeg(i);
				Eject(mo);
				Buzz(mo);
				SetPhase(mo, RSB.OPEN);
			}
			break;
		}

		case RSB.OPEN:
			HandTick(mo, press, held);
			if (phase != RSB.OPEN)
				break;
			// the flick: a quick turn of the gun hand the way the action closes
			if (hand != RSB.INSERT && flick >= RSB.PlayerFloat(mo.player, 'rsb_flick_speed', 450))
			{
				flickBy = 1;
				if (RSB.Debug(mo.player))
					Console.Printf("rsb t%d flick %.0f deg/s about the hinge, closing", now, flick);
				StartClose(mo);
				break;
			}
			if (hand == RSB.FREE)
				PushTick(mo);
			break;

		case RSB.CLOSING:
		{
			int t = now - phaseTic;
			double f = clamp(t / double(RSB.CLOSE_TICS), 0, 1);
			theta = closeFrom * (1 - f);
			if (t >= RSB.CLOSE_TICS)
			{
				theta = 0;
				Shut(mo);
			}
			break;
		}
		}
		if (close2At > 0 && now >= close2At)
		{
			PlaySnd(mo, RSB_Guns.SndClose2(i));
			close2At = 0;
		}
	}
	double closeFrom;

	// what the off hand does while the action is open
	void HandTick(PlayerPawn mo, bool press, bool held)
	{
		int i = gun;
		switch (hand)
		{
		case RSB.FREE:
			if (press && !pushing && CanTakeRound(mo))
			{
				// 2026-10-16 (owner): a double-barrel takes TWO shells when both barrels are empty
				// and the reserve has two; pushed home together, they fill both barrels at once.
				int need2 = RSB_Guns.ReserveHoldsLoaded(i) ? LiveCount() + 2 : 2;
				pair = nch == 2 && !RSB_Guns.Loader(i) && ch[0] == RSB.EMPTY && ch[1] == RSB.EMPTY
					&& RSB.Count(mo, RSB_Guns.Reserve(i)) >= need2 * RSB_Guns.ReservePer(i) && RSB.PlayerInt(mo.player, 'rsr_ssg_pair', 1) != 0;
				SetHand(mo, RSB.CARRY);
				for (int k = 0; k < nch; k++)
					sAt[k] = 999;
				Buzz(mo);
			}
			break;

		case RSB.CARRY:
		{
			if (!held)
			{
				// let go of it: it falls
				Vector3 b, t;
				[b, t] = RoundInHand();
				DropRound(mo, (b + t) / 2, RSB_Guns.Loader(i) ? 1 : 0);
				if (pair)
					DropRound(mo, (b + t) / 2, 0);
				pair = false;
				SetHand(mo, RSB.FREE);
				break;
			}
			// THE CAPTURE ZONE (rsr_assist.zs). A cylinder of cap cm about each empty chamber's
			// bore, from home out to cap beyond the mouth. The round's tip inside it, pointing
			// within tilt of the bore, is CAUGHT by the NEAREST such chamber, and from there it
			// is drawn on that bore at the depth the hand has reached: the hand only pushes
			// ALONG it. No crossing of any plane is needed, so a quick hand is no longer missed.
			double cap = RSR_Assist.BreakCapture(mo.player, i);
			double tilt = RSR_Assist.BreakTilt(mo.player, i);
			int best = -1;
			double bestSide = cap;
			for (int k = 0; k < nch; k++)
			{
				double ss, side, ang;
				[ss, side, ang] = AtChamber(k);
				double dep = Depth(k);
				sAt[k] = ss;
				if (ch[k] != RSB.EMPTY)
					continue;
				if (RSR_Assist.Dbg(mo.player))
					ZoneRing(mo, TipAt(k, theta) - BoreAt(k, theta) * dep, BoreAt(k, theta), cap, Color(255, 255, 255, 64));
				bool inZone = ss <= dep + cap && ss > -0.5 * cap;
				if (!inZone || ang > tilt || side >= bestSide)
					continue;
				best = k;
				bestSide = side;
			}
			if (best >= 0)
			{
				insCh = best;
				double ss, side, ang;
				[ss, side, ang] = AtChamber(best);
				s = sPrev = clamp(ss, 0, Depth(best));
				Buzz(mo);
				SetHand(mo, RSB.INSERT);
				if (RSB.Debug(mo.player))
					Console.Printf("rsb t%d round at chamber %d: %.1f cm out, %.1f cm off the bore, %.0f deg", mo.Level.maptime, best, ss, side, ang);
			}
			break;
		}

		case RSB.INSERT:
		{
			double ss, side, ang;
			[ss, side, ang] = AtChamber(insCh);
			double dep = Depth(insCh);
			if (!held)
			{
				// let go before it is home: it drops out
				Vector3 at = RSB.HingeTurn(i, (RSB_Guns.Base(i, insCh) + RSB_Guns.Tip(i, insCh)) / 2, theta) - BoreAt(insCh, theta) * s;
				DropRound(mo, at, RSB_Guns.Loader(i) ? 1 : 0);
				if (pair)
					DropRound(mo, at, 0);
				pair = false;
				SetHand(mo, RSB.FREE);
				break;
			}
			double cap = RSR_Assist.BreakCapture(mo.player, i);
			double leave = RSR_Assist.Leave(mo.player, cap);
			if (RSR_Assist.Dbg(mo.player))
				ZoneRing(mo, TipAt(insCh, theta) - BoreAt(insCh, theta) * dep, BoreAt(insCh, theta), cap, Color(255, 64, 255, 64));
			if (side > leave || ss > dep + leave)
			{
				for (int k = 0; k < nch; k++)
					sAt[k] = 999;
				SetHand(mo, RSB.CARRY);
				break;
			}
			s = clamp(ss, 0, dep);
			// home: BreakSeatFrac of the way in from the mouth, never looser than RSB.SEAT cm
			double seat = RSR_Assist.SeatAt(dep, RSR_Assist.BreakSeatFrac(mo.player, i), RSB.SEAT);
			if (s <= seat)
			{
				s = sPrev = 0;
				Seat(mo);
			}
			break;
		}

		case RSB.EMPTYLOADER:
			if (!held)
			{
				// the empty loader, let go of: it falls
				Vector3 b, t;
				[b, t] = RoundInHand();
				DropRound(mo, (b + t) / 2, 0);
				SetHand(mo, RSB.FREE);
			}
			break;
		}
	}

	// pushed home: the set's own sound, the set's own step
	void Seat(PlayerPawn mo)
	{
		int i = gun;
		ch[insCh] = RSB.LIVE;
		loadedNow++;
		if (pair && nch == 2 && ch[1 - insCh] == RSB.EMPTY)
		{
			ch[1 - insCh] = RSB.LIVE;		// the second shell went in beside it
			loadedNow++;
			mo.GiveInventory('RSB_LoadT', 1);
		}
		pair = false;
		seatTic = mo.Level.maptime;
		PlaySnd(mo, RSB_Guns.SndLoad(i));
		Buzz(mo);
		mo.GiveInventory('RSB_LoadT', 1);
		if (RSB.Debug(mo.player))
			Console.Printf("rsb t%d chamber %d loaded", mo.Level.maptime, insCh);
		SetHand(mo, RSB_Guns.Loader(i) && RSB_Guns.LoaderEmptyInHand(i) ? RSB.EMPTYLOADER : RSB.FREE);
	}

	// The gun hand's turn about the hinge, the way the action closes (deg/s), over FLICK_TICS.
	// From the controller's frames (AttackDir), in the gun's own axes; a snap turn (the view
	// yaw jumping) is not the hand and is left out.
	double FlickSpeed(PlayerPawn mo)
	{
		if (hist.Size() != 72)
		{
			hist.Clear();
			for (int k = 0; k < 72; k++)
				hist.Push(0);
		}
		for (int k = 71; k >= 9; k--)
			hist[k] = hist[k - 9];
		hist[0] = F.x; hist[1] = F.y; hist[2] = F.z;
		hist[3] = L.x; hist[4] = L.y; hist[5] = L.z;
		hist[6] = U.x; hist[7] = U.y; hist[8] = U.z;
		hN = min(hN + 1, 8);
		// a snap turn: the forward axis swung about the vertical by a lot in one tic
		if (hN >= 2)
		{
			Vector3 f0 = HistF(0), f1 = HistF(1);
			double y0 = atan2(f1.y, f1.x), y1 = atan2(f0.y, f0.x);
			double dy = abs(Actor.DeltaAngle(y0, y1));
			double horiz = sqrt(f0.x * f0.x + f0.y * f0.y);
			if (dy * horiz > RSB.SNAP_TURN && abs(f0.z - f1.z) < 0.15)
			{
				hN = 1;		// start over from this tic
				return 0;
			}
		}
		int n = RSB.FLICK_TICS;
		if (hN <= n)
			return 0;
		// the turn from then to now, in the gun's axes then: D = Rthen^T Rnow
		Vector3 a = RSB_Guns.Axis(gun);
		Vector3 c = -a;		// closing
		Vector3 pf = HistF(n), pl = HistL(n), pu = HistU(n);
		Vector3 d0 = (pf dot F, pf dot L, pf dot U);
		Vector3 d1 = (pl dot F, pl dot L, pl dot U);
		Vector3 d2 = (pu dot F, pu dot L, pu dot U);
		// rows of D: D[r][j] = then_r . now_j
		Vector3 w = (d2.y - d1.z, d0.z - d2.x, d1.x - d0.y) * 0.5;		// sin(angle) * axis
		double tr = d0.x + d1.y + d2.z;
		double ang = atan2(w.Length(), (tr - 1) * 0.5);
		if (ang < 0.01)
			return 0;
		Vector3 ax = w.Unit();
		double speed = ang * (ax dot c) * TICRATE / n;
		if (speed > flickSeen)
			flickSeen = speed;
		return speed;
	}

	Vector3 HistF(int k) { return (hist[k * 9], hist[k * 9 + 1], hist[k * 9 + 2]); }
	Vector3 HistL(int k) { return (hist[k * 9 + 3], hist[k * 9 + 4], hist[k * 9 + 5]); }
	Vector3 HistU(int k) { return (hist[k * 9 + 6], hist[k * 9 + 7], hist[k * 9 + 8]); }

	// The off hand pushing the hinged part shut: the hand meets it from the open side and
	// moves it through its arc (its angle follows the hand); near shut, it snaps shut.
	void PushTick(PlayerPawn mo)
	{
		int i = gun;
		Vector3 a = RSB_Guns.Axis(i);
		Vector3 h = RSB_Guns.Hinge(i);
		Vector3 palm = OffPoint(RSR.PalmGrab()) - h;
		double z = palm dot a;
		Vector3 v = palm - a * z;
		double rho = v.Length();
		bool inBand = z >= RSB_Guns.PushZ0(i) && z <= RSB_Guns.PushZ1(i) && rho >= RSB_Guns.PushR0(i) && rho <= RSB_Guns.PushR1(i);
		if (!inBand || rho < 0.5 || mo.Level.maptime - seatTic < 15)
		{
			pushing = false;
			return;
		}
		Vector3 r0 = RSB_Guns.PushRef(i);
		double phi = atan2((r0 cross v) dot a, r0 dot v);		// the hand's angle about the hinge
		double edge = RSB_Guns.PushEdge(i, rho);				// the part's open-side face, closed
		if (edge < -900)
		{
			pushing = false;
			return;
		}
		double rel = phi - (edge + theta);
		double hd = atan(RSB.PUSH_HAND / rho);
		if (!pushing)
		{
			// it meets the part's open-side face
			if (rel >= -1 && rel <= hd)
			{
				pushing = true;
				if (RSB.Debug(mo.player))
					Console.Printf("rsb t%d off hand on the hinged part (%.0f deg open)", mo.Level.maptime, theta);
			}
			return;
		}
		if (rel > 2 * hd)
		{
			pushing = false;
			return;
		}
		double want = phi - edge;
		if (want < theta)
			theta = max(0, want);
		if (theta <= RSB.PUSH_SHUT)
		{
			flickBy = 2;
			StartClose(mo);
		}
	}

	void StartClose(PlayerPawn mo)
	{
		closeFrom = theta;
		pushing = false;
		if (hand == RSB.CARRY)
		{
			// a round still in the hand falls (none of the reserve went into it)
			Vector3 b, t;
			[b, t] = RoundInHand();
			DropRound(mo, (b + t) / 2, RSB_Guns.Loader(gun) ? 1 : 0);
			SetHand(mo, RSB.FREE);
		}
		SetPhase(mo, RSB.CLOSING);
	}

	// shut: the set's own close sound; the set's flags; the set's own end
	void Shut(PlayerPawn mo)
	{
		int i = gun;
		PlaySnd(mo, RSB_Guns.SndClose(i));
		close2At = RSB_Guns.SndClose2(i) != "" ? mo.Level.maptime + 6 : 0;
		Buzz(mo);
		bool full = !AnyEmpty();
		if (full && nch > 0 && RSB_Guns.Cap(i) > nch * RSB_Guns.PerLoad(i) && !RSB_Guns.Loader(i))
			mo.GiveInventory('RSB_TopUpT', 1);		// BD22 revolver: its 5-chamber mesh, its own count of 6
		CloseFlags(mo, i, full);
		mo.GiveInventory('RSB_Done', 1);
		SetPhase(mo, RSB.DONE);
		if (RSB.Debug(mo.player))
			Console.Printf("rsb t%d shut (%s), loaded %d this reload, fastest closing turn %.0f deg/s", mo.Level.maptime,
				flickBy == 1 ? "flick" : flickBy == 2 ? "pushed" : "other", loadedNow, flickSeen);
	}

	// The set's own state flags at the end of its reload (the ammo itself moved at each round).
	static void CloseFlags(PlayerPawn mo, int i, bool full)
	{
		Name c = RSB_Guns.Cls(i);
		if (c == 'SSG')
		{
			// BD22: SSGLoaded when both barrels are loaded (its full reload gives it; with it
			// set, its Reload goes straight back to Ready); one barrel: the other counts as
			// fired (SSGAlt), so it fires as BD22's second barrel and reloads as one
			RSB.Take(mo, "SSGAlt");
			int n = RSB.Count(mo, "SSGAmmo");
			if (n >= 2)
				RSB.Give(mo, "SSGLoaded");
			else if (n == 1)
				RSB.Give(mo, "SSGAlt");
			RSB.Take(mo, "Reloading");
			RSB.Take(mo, "SSGReloadToken");
		}
		else if (c == 'GrenadeLauncher')
			RSB.Take(mo, "Reloading");
		else if (c == 'Revolver')
		{
			RSB.Take(mo, "Reloading");
			RSB.Take(mo, "HasUnloadedRevolver");
			RSB.Take(mo, "RevolverIsReloading");
		}
		else if (c == 'VR_SuperShotgun')
		{
			// Vanilla VR Plus: VR_SSGAlt counts the loaded barrels, VR_SSGLoaded = both (its reload gives both)
			if (RSB.Count(mo, "VR_SSGAlt") >= 2)
				RSB.Give(mo, "VR_SSGLoaded");
		}
	}

	// the weapon left the reload (switched away, died, ...): it is closed with what was loaded
	void Abort(PlayerPawn mo)
	{
		if (hand == RSB.CARRY || hand == RSB.INSERT || hand == RSB.EMPTYLOADER)
		{
			Vector3 b, t;
			[b, t] = RoundInHand();
			DropRound(mo, (b + t) / 2, hand == RSB.EMPTYLOADER ? 0 : RSB_Guns.Loader(gun) ? 1 : 0);
		}
		if (phase != RSB.DONE)
			CloseFlags(mo, gun, !AnyEmpty());
		mo.TakeInventory('RSB_EjectT', 999);
		mo.TakeInventory('RSB_LoadT', 999);
		mo.TakeInventory('RSB_TopUpT', 999);
		mo.TakeInventory('RSB_Done', 999);
		End(mo);
	}

	void End(PlayerPawn mo)
	{
		if (phase != RSB.IDLE)
			SetPhase(mo, RSB.IDLE);
		weap = null;
		hand = RSB.FREE;
		theta = thetaPrev = 0;
		s = sPrev = 0;
		pushing = false;
	}

	// after the psprites have ticked (RSB_Handler.WorldTick): what the gun and the layers show
	void Draw(PlayerPawn mo)
	{
		let p = mo.player;
		let w = p.ReadyWeapon;
		bool active = phase != RSB.IDLE && w && w == weap;
		let psp = p.FindPSprite(PSP_WEAPON);
		if (active && psp && psp.CurState == w.FindState("RSB_Wait"))
		{
			// the gun without its hinged part and rounds: they are on their own layers
			psp.Sprite = Actor.GetSpriteIndex(RSB_Guns.SprGun(gun));
			psp.Frame = 0;
		}
		let parts = RSB_GunParts(mo.FindInventory('RSB_GunParts'));
		if (!parts && active)
		{
			mo.GiveInventory('RSB_GunParts', 1);
			parts = RSB_GunParts(mo.FindInventory('RSB_GunParts'));
		}
		int i = active ? gun : 0;
		Name sp = i > 0 ? RSB_Guns.SprPart(i) : 'TNT1';
		bool shown = active && phase != RSB.DONE;
		RSB.SetPart(p, RSB.HINGED, parts, shown, sp, 0);
		for (int k = 0; k < RSB.MAXCH; k++)
		{
			bool show = shown && k < nch && (ch[k] != RSB.EMPTY || hand == RSB.INSERT && (insCh == k || pair && nch == 2 && k == 1 - insCh));
			// the speedloader: seated on the cylinder while the hand pushes it, its rounds after
			int fr = RSB_Guns.Loader(i) ? (hand == RSB.INSERT ? 8 : 1) : k + 1;
			RSB.SetPart(p, RSB.CHAMBER0 + k, parts, show, sp, fr);
		}
		Actor hands = p.OffhandWeapon;
		bool inHand = shown && (hand == RSB.CARRY || hand == RSB.EMPTYLOADER);
		RSB.SetPart(p, RSB.HANDROUND, hands is 'RSQ_Hands' ? hands : null, inHand, sp, hand == RSB.EMPTYLOADER ? 9 : 7);
		RSB.SetPart(p, RSB.HANDROUND2, hands is 'RSQ_Hands' ? hands : null, inHand && pair && hand == RSB.CARRY, sp, 7);
	}
}

// what the weapon gives itself to talk to the break reload; never kept
class RSB_Call : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		let mo = PlayerPawn(toucher);
		if (mo && mo.player)
			Called(mo, RSB_Handler.StateOf(mo));
		return false;
	}

	virtual void Called(PlayerPawn mo, RSB_State s) {}
}

class RSB_Start : RSB_Call
{
	override void Called(PlayerPawn mo, RSB_State s)
	{
		let w = mo.player.ReadyWeapon;
		int i = RSB_Guns.Index(w);
		if (!s || i <= 0 || !RSR_ReloadHandler.Wanted(mo))
			return;			// the set's own reload
		if (s.phase != RSB.IDLE)
			s.End(mo);
		s.Begin(mo, w, i);
		mo.GiveInventory('RSB_Go', 1);
	}
}

class RSB_Tick : RSB_Call
{
	override void Called(PlayerPawn mo, RSB_State s)
	{
		if (!s)
			return;
		if (s.phase == RSB.IDLE)
		{
			// the gun is in its wait states without a reload (a saved game, ...): end it
			mo.GiveInventory('RSB_Done', 1);
			return;
		}
		s.Tick(mo);
	}
}

// what the break reload tells the weapon (the weapon takes them)
class RSB_Go : RSVR_Token {}
class RSB_Done : RSVR_Token {}
class RSB_TopUpT : RSVR_Token {}
class RSB_EjectT : Inventory { Default { Inventory.MaxAmount 8; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; } }
class RSB_LoadT : Inventory { Default { Inventory.MaxAmount 8; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; } }

// owns the break reload's layers on the main controller
class RSB_GunParts : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
	}
}

// the state every break-reload layer shows (sprite and frame set per gun). A weapon's state,
// so a layer whose caller is the off-hand weapon may show it; never given.
class RSB_PartStates : Weapon
{
	Default
	{
		+WEAPON.CHEATNOTWEAPON
		+WEAPON.NO_AUTO_SWITCH
		+WEAPON.NOAUTOSWITCHTO
		+INVENTORY.UNDROPPABLE
		Weapon.SelectionOrder 32002;
	}

	States
	{
	Part:
		RBSP A -1;
		Stop;
	}
}

// a round (or the speedloader) let go of: the gun's own mesh at world scale (MODELDEF.rsb)
class RSB_Round : Actor
{
	Default
	{
		Radius 1;
		Height 1;
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

// a spent round thrown out (Vanilla VR Plus: the set's own round, as its own frames throw it)
class RSB_Casing : RSB_Round
{
	Default
	{
		Gravity 0.6;
		BounceFactor 0.4;
	}

	States
	{
	Spawn:
		"####" "#" 1 { roll += 25; pitch += 15; }
		Loop;
	}
}

class RSB_Handler : EventHandler
{
	RSB_State st[MAXPLAYERS];

	clearscope static RSB_Handler Get()
	{
		return RSB_Handler(EventHandler.Find('RSB_Handler'));
	}

	static RSB_State StateOf(PlayerPawn mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS)
			return null;
		if (!h.st[n])
			h.st[n] = new('RSB_State');
		return h.st[n];
	}

	clearscope static RSB_State StateOfUi(Actor mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		return n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
	}

	// RSR_ReloadHandler.InputProcess: a break reload has the off hand (its grip keys are eaten)
	clearscope static bool Busy(int n)
	{
		let h = Get();
		return h && n >= 0 && n < MAXPLAYERS && h.st[n] && h.st[n].phase != RSB.IDLE;
	}

	// rsq/hands.zs: the free hand's state while a break reload has it ("" = not busy)
	clearscope static String FreeHand(Actor mo)
	{
		let s = StateOfUi(mo);
		if (!s || s.phase == RSB.IDLE || s.phase == RSB.DONE)
			return "";
		if (s.hand == RSB.CARRY || s.hand == RSB.INSERT || s.hand == RSB.EMPTYLOADER)
			return RSB_Guns.HoldState(s.gun);
		return "FreeHand";
	}

	// rsq/hands.zs RSQ_Hands.ModifyBobLayer3D: the layers this places
	clearscope static bool Owns(Actor owner, int layer)
	{
		if (layer >= RSB.LAYER_FIRST && layer <= RSB.LAYER_LAST || layer == RSB.HANDROUND || layer == RSB.HANDROUND2)
			return true;
		let s = StateOfUi(owner);
		return layer == RSQ_Layers.FREEHAND && s && s.phase != RSB.IDLE && TestDraw();
	}

	clearscope static bool TestDraw()
	{
		let cv = CVar.FindCVar('rsr_test_offdraw');
		return cv && cv.GetBool();
	}

	// where the break reload's layers go (ui, per frame)
	clearscope static Vector3, Vector3 Place(Actor owner, Vector3 t, Vector3 r, int layer, double ticfrac)
	{
		let s = StateOfUi(owner);
		if (!s || s.gun <= 0)
			return t, r;
		int i = s.gun;
		Vector3 sc = RSB_Guns.Scale(i);
		Vector3 off = RSB_Guns.Offset(i);
		double th = s.thetaPrev + (s.theta - s.thetaPrev) * ticfrac;
		Vector3 a = RSB_Guns.Axis(i);
		Vector3 hp = RSB_Guns.Hinge(i);
		Vector3 q0, q1, q2;
		[q0, q1, q2] = RSB.RotRows(a, th);
		if (layer == RSB.HINGED)
		{
			// p -> H + Rot (p - H)
			Vector3 ht, hr;
			[ht, hr] = RSB.Hook(q0, q1, q2, hp - RSB.Apply(q0, q1, q2, hp), sc, off, t, r);
			return ht, hr;
		}
		if (layer >= RSB.CHAMBER0 && layer <= RSB.LAYER_LAST)
		{
			int k = layer - RSB.CHAMBER0;
			// p -> hinge turn of (rest p - bore * s)
			double sh = s.hand == RSB.INSERT && (s.insCh == k || s.pair && s.nch == 2 && k == 1 - s.insCh) ? s.sPrev + (s.s - s.sPrev) * ticfrac : 0;
			Vector3 k0 = RSB_Guns.Rest0(i, k), k1 = RSB_Guns.Rest1(i, k), k2 = RSB_Guns.Rest2(i, k);
			Vector3 kt = RSB_Guns.RestT(i, k) - RSB_Guns.Bore(i, k) * sh;
			Vector3 m0, m1, m2;
			[m0, m1, m2] = RSB.Mul(q0, q1, q2, k0, k1, k2);
			Vector3 mt = RSB.Apply(q0, q1, q2, kt - hp) + hp;
			Vector3 ht, hr;
			[ht, hr] = RSB.Hook(m0, m1, m2, mt, sc, off, t, r);
			return ht, hr;
		}
		if (layer == RSB.HANDROUND || layer == RSB.HANDROUND2)
		{
			// the round's mesh -> seated (rest, chamber 0) -> Ermac's hold in the off hand. The pair's
			// second shell is seated in chamber 1 instead, so it rides beside the first exactly as
			// the barrels sit side by side.
			int hk = layer == RSB.HANDROUND2 ? 1 : 0;
			Vector3 k0 = RSB_Guns.Rest0(i, hk), k1 = RSB_Guns.Rest1(i, hk), k2 = RSB_Guns.Rest2(i, hk);
			Vector3 g0 = RSB_Guns.Hand0(i), g1 = RSB_Guns.Hand1(i), g2 = RSB_Guns.Hand2(i);
			Vector3 m0, m1, m2;
			[m0, m1, m2] = RSB.Mul(g0, g1, g2, k0, k1, k2);
			Vector3 mt = RSB.Apply(g0, g1, g2, RSB_Guns.RestT(i, hk)) + RSB_Guns.HandT(i);
			if (TestDraw())
			{
				// TEST ONLY: on a desktop the off hand's layers are drawn at the view: put them
				// where the scripted off hand is, turned as it is
				Vector3 a0, a1, a2;
				[a0, a1, a2] = TestTurn(s);
				[m0, m1, m2] = RSB.Mul(a0, a1, a2, m0, m1, m2);
				mt = RSB.Apply(a0, a1, a2, mt) + s.offLocal;
			}
			else
			{
				// vr_3dweaponOffset moves each model by its own block's Scale: the round (the gun's
				// block) goes where Ermac's hand (Scale -1 1 1) goes
				Vector3 v3 = (-RSB.Float('vr_3dweaponOffsetX', 0), RSB.Float('vr_3dweaponOffsetY', 0), RSB.Float('vr_3dweaponOffsetZ', 0));
				Vector3 sl = (sc.x, sc.z, sc.y);
				t += ((-1 - sl.x) * v3.x / sl.x, (1 - sl.y) * v3.y / sl.y, (1 - sl.z) * v3.z / sl.z);
			}
			Vector3 ht, hr;
			[ht, hr] = RSB.Hook(m0, m1, m2, mt, sc, off, t, r);
			return ht, hr;
		}
		if (layer == RSQ_Layers.FREEHAND)
		{
			// TEST ONLY (Owns: only with rsr_test_offdraw): Ermac's hand block, at the scripted off hand
			Vector3 a0, a1, a2;
			[a0, a1, a2] = TestTurn(s);
			Vector3 ht, hr;
			[ht, hr] = RSB.Hook(a0, a1, a2, s.offLocal, (-1, 1, 1), (0, -24, -10), t, r);
			return ht, hr;
		}
		return t, r;
	}

	clearscope static Vector3, Vector3, Vector3 TestTurn(RSB_State s)
	{
		if (s.tR0 == (0, 0, 0))
			return (1, 0, 0), (0, 1, 0), (0, 0, 1);
		return s.tR0, s.tR1, s.tR2;
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
				st[n] = new('RSB_State');
			let s = st[n];
			if (s.phase != RSB.IDLE)
			{
				bool gone = mo.health <= 0 || mo.player.ReadyWeapon != s.weap || now - s.lastTick > 2;
				if (s.phase == RSB.DONE && now - s.lastTick > 0)
				{
					if (s.close2At > 0)
					{
						s.PlaySnd(mo, RSB_Guns.SndClose2(s.gun));
						s.close2At = 0;
					}
					s.End(mo);
				}
				else if (gone)
				{
					if (RSB.Debug(mo.player))
						Console.Printf("rsb t%d: the gun left the reload (%s)", now, RSB.PhaseName(s.phase));
					s.Abort(mo);
				}
			}
			Lever(mo, s);
			s.Draw(mo);
		}
	}

	// the off hand's reload button (rsr_magrelease) is the gun's own reload too: it starts the
	// set's own reload, which the break reload then takes
	void Lever(PlayerPawn mo, RSB_State s)
	{
		let p = mo.player;
		int mask = RSB.PlayerInt(p, 'rsr_magrelease', (1 << 28));
		bool down = (p.cmd.buttons & mask) != 0;
		bool edge = down && !s.relPrev;
		s.relPrev = down;
		if (!edge || s.phase != RSB.IDLE || !RSR_ReloadHandler.Wanted(mo))
			return;
		let w = p.ReadyWeapon;
		int i = RSB_Guns.Index(w);
		if (i <= 0)
			return;
		String tok = RSB_Guns.ReloadToken(i);
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
}
