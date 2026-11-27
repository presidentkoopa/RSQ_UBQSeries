// THE REST OF THE SERIES, FOUND BY NAME.
//
// Nothing here links against another mod: a class name looked up at run time is
// null when that mod is absent, and the hook simply never fires.
//
//   RS_ShieldSawQ  2026-11-27 (owner: "we can optionally mount it on the offhand shoulder. when
//                  doing so, it takes the left shoulder slot ... it does not live anywhere by
//                  default"): the saw can be ASSIGNED to the off shoulder gun holster from RSQ
//                  Wheel's holster assignment screen (rig.zs sawMount). Mounted, that holster is
//                  the saw's (ShieldHolster, "rig.claim"): no gun goes in it, and the off hand's
//                  grip there draws the saw or puts it back (rig.zs Press, its own "ssq-draw").
//                  Shoulder for Shield off (rsqtr_yield_shield): no mount.
//
// Other mods can ask the rig what it holds, through RSQTR_RigService:
//   GetInt("rig.region", "", hand)          region the hand is in, or -1
//   GetInt("pouch.at", "", hand, 0, pawn)   1 the hand is in the ammo pouch, 0 not, -1 no pouch (BD22 VR's reloads)
//   GetInt("nade.at", "", hand, 0, pawn)    1 the hand is at the grenade spot, 0 not, -1 no grenade spot (BD22 VR's
//                                           under-barrel launchers load a grenade of the player's kind from it)
//   GetInt("rig.busy", "", hand, 0, pawn)   1 while the hand is in a holster,
//                                           holds a Distance Grab door, the cigarette or the Zippo
// The hands are known on the console player's own machine only, so both answers are
// for that player (a pawn passed as objectArg that is someone else's gets 0 / -1).
//   GetInt("rig.drawtic", "", 0, 0, pawn)   level.maptime of that player's last draw from
//                                           a holster this map, or -1 (RSQ_Score's Quick Draw)
//   GetString("rig.drawn", "", 0, 0, pawn)  the weapon class that draw brought up, or ""
//   GetInt("rig.holster", "<weapon class>", 0, 0, pawn)  the region that gun is holstered in, or -1 (RSQ Whip's
//                                           whip: 11, its own holster, while that is on and it is not in a hand)
//   GetString("rig.regionname", "", region)              that region's name ("Left hip" ...)
// (RSQ Wheel badges a holstered gun's card with where it hangs.)
//   GetDouble("region.x" / ".y" / ".z", "", region, 0, pawn)  that place's centre, world coordinates (1e9: unknown)
// And the rig asks a pack's own grenade of a Service named RSQTR_NadeService (rig.zs NadeService): "nade.weapon",
// "nade.ammo".
// rig.drawtic, rig.drawn and rig.holster are synced play state (the draw is a network event), so they answer for any
// player, not only the console player. More requests are answered below (rig.locked, rig.regionname, ...): each is
// described where it is answered.
class RSQTR_Hooks play
{
	// (2026-11-27: nothing claims a place any more. It was the ShieldSaw's shoulder while its shield hung there, left to
	// the ShieldSaw's own Use; the grip there is handled by the Rig now, rig.zs Press.)
	static bool Claimed(PlayerPawn pmo, int r)
	{
		return false;
	}

	// THE HOLSTER THE SHIELDSAW MAY BE MOUNTED ON (owner 2026-11-27: "CAN BE ASSIGNED BUT ONLY TO OFFHAND SHOULDER"): the
	// off shoulder gun holster -- the left shoulder (4) for a right-handed player, the right (5) left-handed, as the
	// ShieldSaw follows handedness (the engine's vr_control_scheme) -- while RSQ
	// ShieldSaw is loaded, this player carries the saw, and Shoulder for Shield is on. -1: none. By name only.
	static int SawSlot(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return -1;
		// SHOULDER TO SHIELDSAW OFF GIVES THE SHOULDER BACK TO THE GUNS (2026-11-16, owner: "Fix it")
		if (!RSQTR_Rig.Flag("rsqtr_yield_shield", pmo.player, true)) return -1;
		String cn = "SSQ_ShieldSaw";      // a run-time lookup: null when the ShieldSaw is not loaded
		class<Inventory> c = cn;
		if (!c || !pmo.FindInventory(c)) return -1;
		return RSQTR_Body.LeftHanded() ? 5 : 4;
	}

	// THE SHIELDSAW'S HOLSTER (owner 2026-11-07 10:31; 2026-11-27: "we can optionally mount it on the offhand shoulder.
	// when doing so, it takes the left shoulder slot"): while the saw is MOUNTED (assigned from RSQ Wheel's holster
	// assignment screen, rig.zs sawMount), the off shoulder gun holster is the ShieldSaw's. No gun goes in it by hand or by
	// the Wheel, whether the saw hangs there, is in the hand or is thrown; a gun that had it loses it (rig.zs ShieldTick).
	// Clear on the assignment screen gives it back. -1: none. It followed the ShieldSaw's own "Take It From: Shoulder"
	// setting (ssq_mount_spot 0) until 2026-11-27; that setting is gone.
	static int ShieldHolster(PlayerPawn pmo)
	{
		int r = SawSlot(pmo);
		if (r < 0) return -1;
		let rig = RSQTR_Rig.Get();
		int n = pmo.PlayerNumber();
		return (rig && n >= 0 && n < MAXPLAYERS && rig.sawMount[n]) ? r : -1;
	}

	// Where the saw is, for the grip at its shoulder (rig.zs Press): 1 in the off hand, 2 thrown (its disc, RSQ
	// ShieldSaw's SSQ_Disc, is in the map with this player as its target), 0 neither (it hangs on the shoulder). By name.
	static int SawState(PlayerPawn pmo)
	{
		String cn = "SSQ_ShieldSaw";
		class<Inventory> c = cn;
		if (!c || !pmo || !pmo.player) return 0;
		let s = pmo.FindInventory(c);
		if (s && pmo.player.OffhandWeapon == s) return 1;
		String dn = "SSQ_Disc";
		class<Actor> dc = dn;
		if (dc)
		{
			let it = ThinkerIterator.Create(dc);
			Actor a;
			while (a = Actor(it.Next())) if (a.target == pmo) return 2;
		}
		return 0;
	}
}

class RSQTR_RigService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let rig = RSQTR_Rig.Get();
		if (!rig) return -1;
		int h = intArg & 1;
		let who = PlayerPawn(objectArg);
		bool local = !who || (who.player && who.player == players[consoleplayer]);
		if (request == "rig.region") return local ? rig.HoverRegion(h) : -1;
		// THE FLARES' ONE HOME (owner 11-11 15:19, rig.zs FlareHome): 1 this player's flares live in the flare holster and RSQ
		// FnF's chest pocket is off, 0 FnF's pocket is their home. objectArg: the pawn.
		if (request == "flare.home")
		{
			let pm = who ? who : players[consoleplayer].mo;
			return (pm && RSQTR_Rig.FlareHome(pm.player)) ? 1 : 0;
		}
		// THE AMMO POUCH (11-03): 1 that hand is in the pouch, 0 it is not, -1 no pouch (Ammo Pouch off, no BD22 VR, the rig
		// off or out of VR, or another player's pawn: the hands are known here only) -- Brutal Doom 22 VR's reloads ask it
		if (request == "pouch.at")
		{
			if (!local) return -1;
			let pm = who ? who : players[consoleplayer].mo;
			return rig.PouchAt(pm, h);
		}
		// THE GRENADE SPOT FOR AN UNDER-BARREL LAUNCHER (2026-11-17, owner: "we grab grenade, alt fire cycle to the one we want
		// ... and we load it into the launcher"): 1 that hand is at the grenade spot, 0 it is not, -1 no grenade spot (off, no
		// hand grenade, the rig off or out of VR, another player's pawn) -- BD22 VR Reloaded's launcher loading asks it (its
		// rsr/rsr_m203.zs), as its reloads ask "pouch.at"
		if (request == "nade.at")
		{
			if (!local) return -1;
			let pm = who ? who : players[consoleplayer].mo;
			return rig.NadeAt(pm, h);
		}
		// the last holster draw of that hand (intArg 0 main, 1 off), for a scorer's Quick Draw
		if (request == "rig.drawtic")
		{
			int n = who ? who.PlayerNumber() : -1;
			return (n >= 0 && n < MAXPLAYERS && rig.drawTic[n * 2 + h] > 0) ? rig.drawTic[n * 2 + h] - 1 : -1;
		}
		if (request == "rig.busy")
		{
			if (!local) return 0;
			if (rig.HandBusy(h)) return 1;
			// THE MAIN HAND AT THE CIGARETTE POCKET (owner 11-11 15:19: "i cant get to the cigarettes") is the pocket's, as a
			// hand in a holster is the rig's: no other mod's grab (RSQ Distance Grab) arms there
			let cpm = who ? who : players[consoleplayer].mo;
			if (h == 0 && cpm && RSQTR_Cig.AtPocket(cpm)) return 1;
			let cig = RSQTR_Cig.Get();
			// the cigarette in the main hand; the off hand the whole time the cigarette is out (the Zippo is there or on
			// its way: cig.zs rule B)
			if (cig && ((h == 0 && cig.phase[consoleplayer] == RSQTR_Cig.PH_HAND)
				|| (h == 1 && cig.phase[consoleplayer] != RSQTR_Cig.PH_NONE))) return 1;
			// a hand lifting a door (RSQ_DistanceGrab's doors, asked by name)
			let dit = RSQTR_Lookup.Find("RSQDG_DoorService");
			Service ds;
			while (ds = dit.Next()) if (ds.GetInt("door.holding", "", h, 0, null) >= 0) return 1;
			return 0;
		}
		// HOLSTER ASSIGNMENT (rig.zs lockCls): the holster this gun is assigned to, or -1; and whether gun holster intArg takes a lock
		// THE SHIELDSAW (owner 2026-11-27: "CAN BE ASSIGNED BUT ONLY TO OFFHAND SHOULDER"): asked for "SSQ_ShieldSaw",
		// "rig.locked" is the shoulder it is mounted on (-1 not mounted) and "rig.lockable" is 1 only for the off shoulder
		// (hooks.zs SawSlot). RSQ ShieldSaw and RSQ Wheel ask both by name.
		if (request == "rig.locked")
		{
			int n = who ? who.PlayerNumber() : consoleplayer;
			if (stringArg ~== "SSQ_ShieldSaw") return RSQTR_Hooks.ShieldHolster(who ? who : players[consoleplayer].mo);
			return rig.LockedTo(n, stringArg);
		}
		if (request == "rig.lockable")
		{
			int n = who ? who.PlayerNumber() : consoleplayer;
			if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return 0;
			if (stringArg ~== "SSQ_ShieldSaw") return (intArg >= 0 && intArg == RSQTR_Hooks.SawSlot(players[n].mo)) ? 1 : 0;
			return (RSQTR_Rig.LockOn(players[n]) && RSQTR_Rig.IsGunRegion(intArg)) ? 1 : 0;
		}
		// THE HOLSTER WEB (RSQ Wheel, 11-07): the active holster profile (1..4, its ring colour)
		if (request == "rig.profile")
		{
			int n = who ? who.PlayerNumber() : consoleplayer;
			if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return 1;
			return clamp(RSQTR_Rig.Opt("rsqtr_profile_active", players[n], 1), 1, 4);
		}
		if (request == "rig.holster")
		{
			int n = who ? who.PlayerNumber() : consoleplayer;
			if (n < 0 || n >= MAXPLAYERS || stringArg == "") return -1;
			// the whip lives in its own holster while that is on (rig.zs WhipApply)
			if (stringArg ~== RSQTR_Rig.WHIP_CLASS && playeringame[n] && players[n].mo && RSQTR_Rig.WhipHolsterOn(players[n]))
				return (!RSQTR_Rig.WhipOf(players[n].mo) || RSQTR_Rig.WhipInHand(players[n].mo)) ? -1 : RSQTR_Region.WHIP;
			// (bugfix 2026-11-27: what the body really holds, not the raw record -- the Wheel listed a holster whose gun was gone;
			// a card asking with BD22 VR's off-hand copy name is read as its gun)
			if (!playeringame[n] || !players[n].mo) return -1;
			String want = RSQTR_Rig.MainOf(stringArg);
			for (int r = 0; r < RSQTR_Region.N; r++)
				if (rig.Content(players[n].mo, r) ~== want) return r;
			return -1;
		}
		return -1;
	}

	// RSQ FnF'S FLASHLIGHT CLIP, BESIDE THE FLARE HOLSTER (owner 11-11 15:19, rig.zs RSQTR_Region.TORCH_F): "torch.x" / ".y" /
	// ".z", the clip's centre in map units for the pawn in objectArg, while the rig is on for that player; 1e9 otherwise (FnF
	// then hangs it at its own place). FnF keeps the grab and its radius.
	// "torch.y.last" / "torch.z.last" (performance, 2026-11-27): the y / z of the place the last "torch.x" worked out, for an
	// asker that wants the whole point and asks them straight after its "torch.x", with nothing run between (FnF's geo.zs
	// RigTorch). FnF asked "torch.y" and "torch.z", and each worked TorchAt out again: the same place three times, several
	// times a tic. TorchAt worked out twice in a row is the same place (its Settings cache is filled by the first and only
	// read by the second; the rest only reads the pawn, the body and cvars), so these are exactly what "torch.y" / ".z"
	// would answer then. Asked for another pawn or tic than the last "torch.x", after that "torch.x" answered 1e9, or after
	// "torch.z.last" has handed it out, they work the place out afresh, exactly as "torch.y" / ".z".
	private Vector3 torchLast;
	private int torchLastWho, torchLastTic;
	private bool torchLastOk;
	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		String req = request;
		if (req == "torch.y.last" || req == "torch.z.last")
		{
			bool zl = req == "torch.z.last";
			let lp = PlayerPawn(objectArg);
			if (torchLastOk && lp && lp.player && torchLastTic == level.maptime && lp.PlayerNumber() == torchLastWho && players[torchLastWho].mo == lp)
			{
				if (zl) torchLastOk = false;
				return zl ? torchLast.z : torchLast.y;
			}
			torchLastOk = false;
			req = zl ? "torch.z" : "torch.y";
		}
		// A PLACE'S CENTRE (2026-11-13, Selaco VR draws its own grenade at the grenade spot): "region.x" / ".y" / ".z" for
		// place intArg (RSQTR_Region), world coordinates, that player (objectArg); 1e9 when the rig cannot say
		if (req == "region.x" || req == "region.y" || req == "region.z")
		{
			torchLastOk = false;      // another ask between: "torch.y.last" / ".z.last" work the place out afresh
			let rg = RSQTR_Rig.Get();
			let pw = PlayerPawn(objectArg);
			if (!rg || !pw || !pw.player || intArg < 0 || intArg >= RSQTR_Region.N || !RSQTR_Rig.Flag("rsqtr_on", pw.player, true)) return 1e9;
			Vector3 at = rg.RegionAt(pw, intArg);
			return req == "region.x" ? at.x : req == "region.y" ? at.y : at.z;
		}
		if (req != "torch.x" && req != "torch.y" && req != "torch.z") return 1e9;
		bool keep = req == "torch.x";
		if (keep) torchLastOk = false;
		let rig = RSQTR_Rig.Get();
		let pm = PlayerPawn(objectArg);
		if (!rig || !pm || !pm.player || !RSQTR_Rig.Flag("rsqtr_on", pm.player, true)) return 1e9;
		Vector3 at = rig.TorchAt(pm);
		if (keep)
		{
			torchLast = at;
			torchLastWho = pm.PlayerNumber();
			torchLastTic = level.maptime;
			torchLastOk = players[torchLastWho].mo == pm;
		}
		return req == "torch.x" ? at.x : req == "torch.y" ? at.y : at.z;
	}

	// HOW TO PLAY (2026-11-27, design/HOWTOPLAY_BUILD.md), asked from the menu (ui) by the series' shared How To Play page:
	//   GetIntUI("ghost.demo", "<move>")     1 the ghost hand can show that move now (ghost.zs DEMO_NAMES: holster, draw,
	//                                        offdraw, nade, cig, mouth, recenter, saber, offsaber, whip, flare, keyring,
	//                                        watch, pulse, shield), else 0: the rig off, dead, out of VR, not in a game, the
	//                                        place not there (no saber, no whip holster ...), or no hand mesh for a move with
	//                                        no ring
	//   GetStringUI("ghost.demo", "<move>")  the network event that plays it once ("" when it cannot)
	//   GetIntUI / GetStringUI("mirror.show", "<place>")  the same for Show On My Body: the mirror stands up for 10 s with
	//                                        that place lit (MOUTH, LSH, RSH, CHEST, BELT, LHIP, RHIP, OFF, MAIN, BOTH)
	// Answered from what the rig cached on its last tic (ghost.zs Avail); ui code reads it and never calls play code.
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "ghost.demo") return RSQTR_Ghost.CanDemo(stringArg) ? 1 : 0;
		if (request == "mirror.show") return RSQTR_Ghost.CanLight(stringArg) ? 1 : 0;
		return 0;
	}

	override String GetStringUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "ghost.demo") return RSQTR_Ghost.CanDemo(stringArg) ? "rsqtr_ghostdemo:" .. stringArg.MakeLower() : "";
		if (request == "mirror.show") return RSQTR_Ghost.CanLight(stringArg) ? "rsqtr_mirrorshow:" .. stringArg.MakeUpper() : "";
		return "";
	}

	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "rig.regionname") return (intArg >= 0 && intArg < RSQTR_Region.N) ? RSQTR_Region.NAMES[intArg] : "";
		// THE HOLSTER WEB (11-07): the gun gun holster intArg is assigned to ("" none)
		if (request == "rig.owner")
		{
			let rg = RSQTR_Rig.Get();
			let pw = PlayerPawn(objectArg);
			int n = pw ? pw.PlayerNumber() : consoleplayer;
			if (!rg || n < 0 || n >= MAXPLAYERS || intArg < 0 || intArg >= RSQTR_Region.N) return "";
			return rg.lockCls[n * RSQTR_Region.N + intArg];
		}
		// THE HOLSTER WEB (11-07 10:31): the item another mod holds gun holster intArg with ("SSQ_ShieldSaw": the shoulder
		// RSQ ShieldSaw's saw is mounted on, ShieldHolster; 2026-11-27), "" none
		if (request == "rig.claim")
		{
			let pw = PlayerPawn(objectArg);
			if (!pw) pw = players[consoleplayer].mo;
			return (intArg >= 0 && intArg == RSQTR_Hooks.ShieldHolster(pw)) ? "SSQ_ShieldSaw" : "";
		}
		// THE HOLSTER WEB'S MIRROR VIEW (RSQ Wheel's "Web View: Mirror", 11-07 10:32): this mirror (mirror.zs) drawn small
		// on the web's panel. stringArg "cx cy cz yaw tilt top bottom" (the panel's middle, its turn, and where on it, up
		// from its middle, the highest and the lowest gun holster go); intArg 1 show (every tic it is wanted), 0 hide.
		// Answers "back x y z s x y z s ..." (how far behind the panel's middle the mirror reaches, then every place's spot in
		// the copy by place index, s 1 when the copy shows that place's item), or "" when the mirror cannot be shown.
		if (request == "mirror.web")
		{
			let mh = RSQTR_Mirror(EventHandler.Find("RSQTR_Mirror"));
			if (!mh) return "";
			return mh.WebShow(stringArg, intArg != 0);
		}
		let rig = RSQTR_Rig.Get();
		let who = PlayerPawn(objectArg);
		if (!rig || !who || request != "rig.drawn") return "";
		int n = who.PlayerNumber();
		return (n >= 0 && n < MAXPLAYERS) ? rig.drawClass[n * 2 + (intArg & 1)] : "";
	}
}

// RSQ SLOWMO'S DOWN (owner 11-06, design/NEAR_DEATH.md 4): getting up (REVIVE) puts one cigarette back in the pocket, up to
// its normal carry (Pack Size, rsqtr_cig_count, plus Gun Bonsai VR's Chain Smoker), while Cigarettes is on. SlowMo tells
// every service named "...RSQDownJoin" by name (its down.zs Tell); nothing links.
class RSQTR_RSQDownJoin : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "down.revive") return 0;
		let pmo = PlayerPawn(objectArg);
		if (!pmo || !pmo.player) return 0;
		let p = pmo.player;
		let dc = CVar.FindCVar("rsqsm_debug");     // RSQ SlowMo's debug log
		bool msg = dc && dc.GetBool();
		if (!RSQTR_Rig.Flag("rsqtr_cig", p, false))
		{
			if (msg) Console.Printf("RSQ Tactical Rig: REVIVE: Cigarettes is off, no cigarette");
			return 0;
		}
		int cap = RSQTR_Rig.Opt("rsqtr_cig_count", p, 3) + max(RSQTR_Rig.Gb(p, 'ChainSmoker'), 0);
		int had = RSQTR_Cig.Packs(pmo);
		if (had < cap) pmo.SetInventory("RSQTR_CigPack", had + 1);
		if (msg) Console.Printf("RSQ Tactical Rig: REVIVE: cigarettes %d -> %d (carry %d)", had, RSQTR_Cig.Packs(pmo), cap);
		return 1;
	}
}
