// RSR-M203 (1.31): the M203 under BD22's rifle, worked by hand (QuestZDoom 17.3 / UZDXREMA, no
// engine changes). The launcher is the machine gun's own M203, kitbashed onto the rifle
// (kitbash/fit.py, gen_m203.py); numbers in rsr_m203_geo.zs.
//
// The owner's rules (1.33, 2026-10-17). One rifle, in the main hand:
//   the rifle's SECONDARY FIRE launches the underbarrel (BD22's own FireGrenade); empty, a dry
//     click. BD22's own launcher key does nothing (Rifle.dec swallows its RFGrenade);
//   stabilized (the off grip: the engine's two-hand hold), the OFF TRIGGER is the latch: hold it
//     and push the off hand forward, the tube follows the hand and opens at the front (BD22's
//     open sound; a spent case falls out);
//   let go, take a 40 mm round away from the gun (the "Grab ammo with" button), tilt its nose
//     into the breech and push it home (BD22's load sound, one round of the chosen ammo taken);
//   stabilize and pull back: the tube follows the hand and locks shut (BD22's close sound).
// While the tube is open the rifle is drawn without it in every frame it shows (the tube is its
// own layer), so firing or anything else never snaps it shut. Nothing loads the launcher by
// itself (BD22's own reload animation only runs out of VR or with Real reload off).
// Two rifles (or a rifle in the off hand): a flick (rsq/flick.zs) loads the empty launcher with
// the magazine, and each hand's secondary fire is its launcher (Rifle.dec RSM_ states).
//
// Netplay: everything that decides runs in the playsim from the synced hand poses and usercmd
// buttons; the layers and the hand's pose are drawn from that state.

class RSM abstract play
{
	const TUBE = 2130;			// RSR_GunParts (main controller): the tube, off its rest
	const ROUND = 2131;			// RSR_GunParts: the round going in / in the open tube
	const LAYER_FIRST = 2130;
	const LAYER_LAST = 2131;

	// what the hand has
	const EMPTY = 0;
	const CARRY = 1;			// a round in the hand
	const INSERT = 2;			// the round in the breech, as far as the hand pushes it

	// cm, degrees
	const NEAR = 9.0;			// the palm this close to the tube's track: on the tube
	const LEAVE = 13.0;			// ...further than this: off it
	const OPEN_FRAC = 0.92;		// of the travel: open (the click, the case out)
	const SHUT_FRAC = 0.06;		// of the travel: shut again
	const RELOCK = 0.6;			// let go this close to shut and the latch takes it again
	const POUCH_MIN = 20.0;		// a round is taken at least this far from the breech
	const ENTER_SIDE = 5.0;		// the round's middle this close to the bore's line goes in
	const LEAVE_SIDE = 7.5;		// ...further off than this: back in the hand
	const ENTER_ANGLE = 40.0;	// ...nose within this of the bore
	const SEAT = 0.6;			// home within this

	clearscope static bool IsRifle(Weapon w)
	{
		return false;	// this pack: the Assault Rifle has no underbarrel
	}

	// 1.97: the guns with a launcher the module works: 1 the rifle, 2 the BD21 Machinegun (c2q/bd22_mg.py)
	clearscope static int GunOf(Weapon w)
	{
		if (!w) return 0;
		Name n = RSQ_Alias.Exact(w);
		// this pack: the Assault Rifle has no underbarrel (BD22 VR: if (n == 'Rifle') return 1;)
		if (n == 'Machinegun') return 2;
		return 0;
	}

	clearscope static bool IsAnyRifle(Weapon w)
	{
		return false;	// this pack: the Assault Rifle has no underbarrel
	}

	// the option (Underbarrel ammo): 0 rockets (as BD22), 1 hand grenades. A server setting: it
	// decides what is taken.
	static class<Inventory> AmmoClass()
	{
		let cv = CVar.FindCVar('rsm_ammo');
		Name n = cv && cv.GetInt() == 1 ? 'GrenadeAmmo' : 'AmmoRocket';
		class<Inventory> c = n;
		return c;
	}

	// real reload in VR (as RSR_ReloadHandler.Wanted, but the off hand may hold a gun: dual)
	static bool VRReload(PlayerPawn mo)
	{
		return mo && mo.player && RSR.PlayerInt(mo.player, 'rsr_reload', 0) == 1 && RSVR_VRHand.InVR(mo)
			&& mo.CountInv('IsPlayingAsPurist') <= 0;
	}

	// rsq/flick.zs: a flick reloads this hand's empty launcher too (dual)
	static void FlickLoad(PlayerPawn mo, bool offHand)
	{
		if (!VRReload(mo))
			return;
		Name loaded = offHand ? 'RSM_LoadedOff' : 'RFGLoaded';
		if (mo.CountInv(loaded) > 0)
			return;
		let ac = AmmoClass();
		if (!ac || mo.CountInv(ac) <= 0)
			return;
		mo.TakeInventory(ac, 1);
		mo.TakeInventory(offHand ? 'RSM_FiredOff' : 'FiredMGGrenade', 0x7FFFFFFF);
		mo.GiveInventory(loaded, 1);
		mo.A_StartSound("GrenadeLauncher/Load", CHAN_AUTO, CHANF_OVERLAP);
	}
}

class RSM_State play
{
	int gun;					// 1.97: RSM.GunOf (1 rifle, 2 machinegun)
	double pull, pullPrev;		// cm the tube is forward
	bool unlatched;
	bool held;					// the hand has the tube
	double grabS;
	bool isOpen;				// it reached the front (clicked open) this cycle
	int hand;
	double rr, rrPrev;			// INSERT: the round's rear, F
	bool roundIn;				// a round home in the open tube
	bool trigPrev, grabPrev;
	bool active;				// the rifle is up and the hand works it (drawn)
	bool steadied;
	RSR_State geo;
	Vector3 palm;
	Array<int> noTubeFrom, noTubeTo;	// rifle sprite -> its no-tube twin (1.33)

	void Log(PlayerPawn mo, String what)
	{
		if (RSR.Debug(mo.player))
			Console.Printf("rsm t%d pull %.1f hand %d: %s", mo.Level.maptime, pull, hand, what);
	}

	void Snd(PlayerPawn mo, Sound s)
	{
		mo.A_StartSound(s, CHAN_AUTO, CHANF_OVERLAP);
	}

	// the palm's distance from the tube (where it is now)
	double TubeDist(Vector3 p)
	{
		double f0 = RSM_Geo.TubeRear(gun) + pull;
		double f1 = RSM_Geo.TubeFront(gun) + pull;
		double f = clamp(p.x, f0, f1);
		return (p - (f, RSM_Geo.AxisL(gun), RSM_Geo.AxisU(gun))).Length();
	}

	double Side(Vector3 p)
	{
		return ((0, p.y, p.z) - (0, RSM_Geo.AxisL(gun), RSM_Geo.AxisU(gun))).Length();
	}

	void Reset()
	{
		pull = pullPrev = 0;
		unlatched = held = isOpen = roundIn = false;
		hand = RSM.EMPTY;
		rr = rrPrev = 0;
	}

	void Tick(PlayerPawn mo)
	{
		let p = mo.player;
		pullPrev = pull;
		rrPrev = rr;
		if (!geo)
			geo = new('RSR_State');
		geo.Frames(mo);
		palm = RSM_Geo.ToGun(gun, geo.OffPoint(RSR.PalmGrab()));	// batch 4: in the rifle's original frame
		steadied = RSVR_VRHand.Steadied(mo);
		bool trig = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;
		bool trigPress = trig && !trigPrev;
		trigPrev = trig;
		let rs = RSR_ReloadHandler.StateOf(mo);
		bool grab = rs && rs.Grip(mo);
		bool grabPress = grab && !grabPrev;
		grabPrev = grab;
		// a magazine reload has the hand
		if (rs && rs.phase != RSR.IDLE && rs.weap == p.ReadyWeapon)
		{
			held = false;
			if (hand != RSM.EMPTY)
				hand = RSM.EMPTY;
			return;
		}

		bool loaded = mo.CountInv('RFGLoaded') > 0;
		// 1.33 (owner): stabilized, the OFF TRIGGER is the latch (the launcher fires from the
		// rifle's secondary fire: Rifle.dec AltFire)
		if (steadied && trigPress && pull <= 0 && !unlatched && hand == RSM.EMPTY)
		{
			unlatched = true;
			Snd(mo, "Weapon/Empty");
			geo.Buzz(mo);
			Log(mo, "latch");
		}

		// the tube. Opening: stabilized with the latch, the hand pushes it out. Open: 1.35 (owner:
		// "gripping empty space is disorienting") the hand takes the tube itself, where it is now:
		// at it, the off trigger or the grip (stabilized) holds it, and the hand pulls it shut.
		bool onTube = TubeDist(palm) < (held ? RSM.LEAVE : RSM.NEAR);
		bool wants;
		if (isOpen)
			wants = hand == RSM.EMPTY && onTube && (trig || steadied);
		else
			wants = steadied && hand == RSM.EMPTY && (unlatched || pull > 0);
		if (held && !wants)
		{
			held = false;
			Log(mo, "let go of the tube");
		}
		else if (!held && wants)
		{
			held = true;
			grabS = palm.x - pull;
			Log(mo, "took the tube");
		}
		if (held)
		{
			double np = palm.x - grabS;
			if (np < 0)
			{
				grabS = palm.x;
				np = 0;
			}
			else if (np > RSM_Geo.TravelOf(gun))
			{
				grabS = palm.x - RSM_Geo.TravelOf(gun);
				np = RSM_Geo.TravelOf(gun);
			}
			pull = np;
		}
		if (!isOpen && pull >= RSM.OPEN_FRAC * RSM_Geo.TravelOf(gun))
		{
			isOpen = true;
			Snd(mo, "GrenadeLauncher/Open");
			geo.Buzz(mo);
			if (mo.CountInv('FiredMGGrenade') > 0)
			{
				mo.TakeInventory('FiredMGGrenade', 0x7FFFFFFF);
				CaseOut(mo);
			}
			Log(mo, "open");
		}
		if (isOpen && pull <= RSM.SHUT_FRAC * RSM_Geo.TravelOf(gun))
		{
			pull = 0;
			isOpen = held = unlatched = false;
			Snd(mo, "GrenadeLauncher/Close");
			geo.Buzz(mo);
			if (roundIn)
			{
				roundIn = false;
				mo.GiveInventory('RFGLoaded', 1);
				Log(mo, "shut: loaded");
			}
			else
				Log(mo, "shut: empty");
		}
		if (!isOpen && pull < RSM.RELOCK && !trig)
		{
			// back at rest without opening, the latch let go: it locks again
			pull = 0;
			unlatched = false;
		}

		// the round
		Vector3 mid = RSM_Geo.ToGun(gun, geo.OffPoint(RSM_Geo.RoundInHand()));	// batch 4: in the rifle's original frame
		Vector3 nose = RSM_Geo.DirToGun(gun, geo.OffDirInGun(RSM_Geo.RoundAxisInHand()));
		double rear = mid.x - nose.x * RSM_Geo.RoundLen(gun) / 2;
		double seatF = RSM_Geo.TubeRear(gun) + pull + RSM_Geo.RoundSeat(gun);
		switch (hand)
		{
		case RSM.EMPTY:
		{
			if (!grabPress || !isOpen || roundIn || loaded)
				break;
			let ac = RSM.AmmoClass();
			if (!ac || mo.CountInv(ac) <= 0)
				break;
			Vector3 breech = ((RSM_Geo.FrameFront(gun) + seatF) / 2, RSM_Geo.AxisL(gun), RSM_Geo.AxisU(gun));
			int rp = RSR.RigPouch(mo);		// 2.0.3u: the rig's ammo pouch only (vreload.zs RSR.RigPouch)
			if (rp == 0)
				break;
			if (rp < 0 && (palm - breech).Length() < RSM.POUCH_MIN)
				break;
			hand = RSM.CARRY;
			geo.Buzz(mo);
			Log(mo, "took a round");
			break;
		}
		case RSM.CARRY:
		{
			if (!grab || !isOpen)
			{
				hand = RSM.EMPTY;		// back in the pouch (nothing was taken)
				Log(mo, "let the round go");
				break;
			}
			double ang = acos(clamp(nose.x, -1, 1));
			if (Side(mid) < RSM.ENTER_SIDE && ang < RSM.ENTER_ANGLE
				&& mid.x > RSM_Geo.FrameFront(gun) - 4 && mid.x < seatF + RSM_Geo.RoundLen(gun) / 2 + 2)
			{
				hand = RSM.INSERT;
				rr = rrPrev = clamp(rear, RSM_Geo.FrameFront(gun) - RSM_Geo.RoundLen(gun), seatF);
				geo.Buzz(mo);
				Log(mo, "round in the breech");
			}
			break;
		}
		case RSM.INSERT:
		{
			rr = clamp(rear, RSM_Geo.FrameFront(gun) - RSM_Geo.RoundLen(gun), seatF);
			bool home = rr >= seatF - RSM.SEAT;
			if (!grab && rr >= seatF - RSM_Geo.RoundLen(gun) / 2)
				home = true;			// let go half in: it slides home
			if (home)
			{
				let ac = RSM.AmmoClass();
				if (ac)
					mo.TakeInventory(ac, 1);
				roundIn = true;
				hand = RSM.EMPTY;
				Snd(mo, "GrenadeLauncher/Load");
				geo.Buzz(mo);
				Log(mo, "round home");
				break;
			}
			if (!grab || !isOpen)
			{
				hand = RSM.EMPTY;
				Log(mo, "let the round go");
				break;
			}
			if (Side(mid) > RSM.LEAVE_SIDE || mid.x < RSM_Geo.FrameFront(gun) - 10)
			{
				hand = RSM.CARRY;
				Log(mo, "round out of the breech");
			}
			break;
		}
		}
	}

	// 1.36 (owner): the fired round's spent case, the round cut down and darker, drops out of the
	// breech to the ground when the tube opens
	void CaseOut(PlayerPawn mo)
	{
		Vector3 at = (RSM_Geo.FrameFront(gun) + 3, RSM_Geo.AxisL(gun), RSM_Geo.AxisU(gun) - 1);
		Vector3 pos = RSVR_VRHand.HandPos(mo) + geo.FromGun(RSM_Geo.FromGun(gun, at));	// batch 4: the moved breech
		let a = Actor.Spawn('RSM_SpentCase', pos);
		if (!a)
			return;
		a.angle = atan2(geo.F.y, geo.F.x);
		a.pitch = -asin(clamp(geo.F.z, -1, 1));
		a.vel = mo.vel + geo.FromGun((0, -25, -40)) * 0.06;
		a.target = mo;
	}

	// after the psprites tick: the gun without its tube while the tube is off its rest
	void Draw(PlayerPawn mo)
	{
		let p = mo.player;
		let psp = p.FindPSprite(PSP_WEAPON);
		bool shown = active && pull > 0.01;
		bool swapped = false;
		if (shown && psp)
		{
			// 1.33: whatever rifle frame is showing, its twin without the tube (MODELDEF.rsm)
			if (noTubeFrom.Size() == 0)
			{
				Array<Name> f, t;
				if (gun == 2) RSM_NoTube.NamesMG(f, t); else RSM_NoTube.Names(f, t);
				for (int k = 0; k < f.Size(); k++)
				{
					noTubeFrom.Push(Actor.GetSpriteIndex(f[k]));
					noTubeTo.Push(Actor.GetSpriteIndex(t[k]));
				}
			}
			int s = psp.Sprite;
			int k = noTubeFrom.Find(s);
			if (k < noTubeFrom.Size())
			{
				psp.Sprite = noTubeTo[k];
				swapped = true;
			}
			else if (noTubeTo.Find(s) < noTubeTo.Size())
				swapped = true;
		}
		bool round = active && (hand == RSM.INSERT || roundIn && pull > 0.5);
		let parts = RSR_GunParts(mo.FindInventory('RSR_GunParts'));
		if (!parts && (swapped || round))
		{
			mo.GiveInventory('RSR_GunParts', 1);
			parts = RSR_GunParts(mo.FindInventory('RSR_GunParts'));
		}
		RSR.SetPart(p, RSM.TUBE, parts, swapped, gun == 2 ? 'RQ3P' : 'RQ2P', 0);
		RSR.SetPart(p, RSM.ROUND, parts, round, gun == 2 ? 'RQ3P' : 'RQ2P', 1);
	}
}

// 1.36: the spent 40 mm case on the ground (MODELDEF.rsm)
class RSM_SpentCase : RSR_DroppedMag
{
	Default
	{
		Radius 1;
		Height 1;
		BounceFactor 0.35;
		WallBounceFactor 0.35;
		BounceSound "GrenadeLauncher/Casing";
	}

	States
	{
	Spawn:
		RQ2C A 1;
		Loop;
	Death:
		RQ2C A 0 { pitch = 0; roll = 90; }
		RQ2C A 350;
		RQ2C A 1 A_FadeOut(0.05);
		Wait;
	}
}

// the tokens (the weapon reads them)
class RSM_VR : RSVR_Token {}			// the launcher is loaded by hand (VR, Real reload)
class RSM_Dual : RSVR_Token {}
class RSM_Steady : RSVR_Token {}		// one rifle, the off hand on it: main secondary fire is the launcher			// the off hand holds a gun: alt fire is each rifle's launcher
class RSM_LoadedOff : RSVR_Token {}		// the off-hand rifle's launcher has a round
class RSM_FiredOff : RSVR_Token {}		// ...and a spent case
class RFGrenadeOff : RSVR_Token {}		// fire the off-hand rifle's launcher

// every sprite name MODELDEF.rsm keys, so the engine knows them; never spawned
class RSM_Sprites : Actor
{
	States
	{
	Spawn:
		RQ2T A 0;
		RQ2P AB 0;
		RQ3P AB 0;	// 1.97: the Machinegun's tube and round
		QU00 A 0;
		QU01 A 0;
		QU02 A 0;
		RQ2H AB 0;
		RQ2S AB 0;
		RQ2C A 0;
		Stop;
	}
}

class RSK_M203Handler : EventHandler
{
	RSM_State st[MAXPLAYERS];

	clearscope static RSK_M203Handler Get()
	{
		return RSK_M203Handler(EventHandler.Find('RSK_M203Handler'));
	}

	clearscope static RSM_State Peek(Actor mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		return n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
	}

	// rsr/vreload.zs InputProcess: while the tube is open (or a round is in the hand) the off hand
	// is loading, so "Grab ammo with" Use / grip is taken over for the grab, as in a reload (1.34)
	clearscope static bool Busy(int n)
	{
		let h = Get();
		let s = h && n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
		return s && s.active && (s.isOpen || s.hand != RSM.EMPTY);
	}

	// rsq/hands.zs: the free hand while it works the launcher ("" = the hands' own)
	clearscope static String FreeHand(Actor mo)
	{
		let s = Peek(mo);
		if (!s || !s.active)
			return "";
		if (s.hand == RSM.CARRY)
			return "RsmRound";			// Ermac's open grip round a 40 mm round
		if (s.hand == RSM.INSERT)
			return "RsmGrip";			// the same grip; the round is on the gun (layer RSM.ROUND)
		if (s.held && !s.steadied)
			return "AmmoH";				// 1.35: a closed hand on the open tube
		return "";						// stabilized: the support hand (on the launcher, rsq/hands.zs)
	}

	// rsq/hands.zs: stabilized with the launcher shut, the support hand holds it with its finger on
	// the launcher's trigger (MODELDEF.rsm RQ2S, baked in place: no hook); working the tube, it
	// holds the tube (the hand table's grip) and rides it
	clearscope static bool TriggerGrip(Actor owner)
	{
		return false;	// 1.32 (owner, option 2): the off hand stays on the tube; the off trigger fires the launcher
	}

	// rsq/hands.zs: the support hand rides the tube (hand-model hook units)
	clearscope static Vector3 SupportShift(Actor owner, double ticfrac)
	{
		let s = Peek(owner);
		if (!s || !s.active)
			return (0, 0, 0);
		return RSM_Geo.FwdHook(s.gun) * (s.pullPrev + (s.pull - s.pullPrev) * ticfrac);
	}

	clearscope static bool Places(Actor owner, int layer)
	{
		return layer >= RSM.LAYER_FIRST && layer <= RSM.LAYER_LAST;
	}

	clearscope static Vector3, Vector3 Place(Actor owner, Vector3 t, Vector3 r, int layer, double ticfrac)
	{
		let s = Peek(owner);
		if (!s)
			return t, r;
		double pl = s.pullPrev + (s.pull - s.pullPrev) * ticfrac;
		if (layer == RSM.TUBE)
			return t + RSM_Geo.FwdHook(s.gun) * pl, r;
		if (s.hand == RSM.INSERT)
		{
			double rv = s.rrPrev + (s.rr - s.rrPrev) * ticfrac;
			return t + RSM_Geo.FwdHook(s.gun) * (rv - RSM_Geo.TubeRear(s.gun) - RSM_Geo.RoundSeat(s.gun)), r;
		}
		return t + RSM_Geo.FwdHook(s.gun) * pl, r;
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
			st[n].Reset();
		}
	}

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			let p = mo.player;
			if (!st[n])
				st[n] = new('RSM_State');
			let s = st[n];
			bool vr = RSM.VRReload(mo);
			bool dual = p.OffhandWeapon && !(p.OffhandWeapon is 'RSQ_Hands');
			Sync(mo, 'RSM_VR', vr);
			Sync(mo, 'RSM_Dual', dual);
			if (mo.health <= 0)
				s.Reset();
			int gn = RSM.GunOf(p.ReadyWeapon);	// 1.97
			if (gn != s.gun)
			{
				s.Reset();
				s.gun = gn;
				s.noTubeFrom.Clear(); s.noTubeTo.Clear();
			}
			s.active = vr && !dual && gn > 0 && RSR_ReloadHandler.Wanted(mo);
			if (s.active)
				s.Tick(mo);
			else
			{
				s.held = false;
				s.pullPrev = s.pull;
				if (s.hand != RSM.EMPTY)
					s.hand = RSM.EMPTY;
			}
			Sync(mo, 'RSM_Steady', s.active && s.steadied);
			s.Draw(mo);
		}
	}

	static void Sync(PlayerPawn mo, Name tok, bool on)
	{
		if (on && mo.CountInv(tok) <= 0)
			mo.GiveInventory(tok, 1);
		else if (!on && mo.CountInv(tok) > 0)
			mo.TakeInventory(tok, 1);
	}
}
