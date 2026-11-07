// THE REST OF THE SERIES, FOUND BY NAME.
//
// Nothing here links against another mod: a class name looked up at run time is
// null when that mod is absent, and the hook simply never fires.
//
//   RS_ShieldSawQ  its stowed shield hangs over the off shoulder and Use there draws
//                  it. While the shield is on the shoulder, the rig leaves that
//                  shoulder region alone (rsqtr_yield_shield), so the two never act
//                  on the same press. With its Draw key route chosen (Use at the
//                  shoulder off), the shoulder is the rig's again.
//
// Other mods can ask the rig what it holds, through RSQTR_RigService:
//   GetInt("rig.region", "", hand)          region the hand is in, or -1
//   GetInt("pouch.at", "", hand, 0, pawn)   1 the hand is in the ammo pouch, 0 not, -1 no pouch (BD22 VR's reloads)
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
// These two are synced play state (the draw is a network event), so they answer for any
// player, not only the console player.
class RSQTR_Hooks play
{
	static bool Claimed(PlayerPawn pmo, int r)
	{
		if (!pmo || !pmo.player) return false;
		// The off shoulder: left for a right-handed player.
		int offShoulder = RSQTR_Body.LeftHanded() ? 5 : 4;
		if (r == offShoulder && RSQTR_Rig.Flag("rsqtr_yield_shield", pmo.player, true) && ShieldOnShoulder(pmo))
			return true;
		return false;
	}

	static bool ShieldOnShoulder(PlayerPawn pmo)
	{
		String cn = "SSQ_ShieldSaw";      // a run-time lookup: null when the ShieldSaw is not loaded
		class<Inventory> c = cn;
		if (!c) return false;
		let s = pmo.FindInventory(c);
		if (!s) return false;
		// The ShieldSaw's key route (ssq_shoulder_use off): the shield is drawn by its key
		// only, so its shoulder is no grab and the rig keeps that shoulder for weapons.
		let cv = CVar.GetCVar("ssq_shoulder_use", pmo.player);
		if (cv && !cv.GetBool()) return false;
		// on the shield's back mount (ssq_mount_spot 1-3, 2026-10-31) the off shoulder is the rig's
		let sp = CVar.GetCVar("ssq_mount_spot", pmo.player);
		if (sp && sp.GetInt() != 0) return false;
		return pmo.player.OffhandWeapon != s;
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
		// THE AMMO POUCH (11-03): 1 that hand is in the pouch, 0 it is not, -1 no pouch (Ammo Pouch off, no BD22 VR, the rig
		// off or out of VR, or another player's pawn: the hands are known here only) -- Brutal Doom 22 VR's reloads ask it
		if (request == "pouch.at")
		{
			if (!local) return -1;
			let pm = who ? who : players[consoleplayer].mo;
			return rig.PouchAt(pm, h);
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
			let cig = RSQTR_Cig.Get();
			// the cigarette in the main hand; the off hand the whole time the cigarette is out (the Zippo is there or on
			// its way: cig.zs rule B)
			if (cig && ((h == 0 && cig.phase[consoleplayer] == RSQTR_Cig.PH_HAND)
				|| (h == 1 && cig.phase[consoleplayer] != RSQTR_Cig.PH_NONE))) return 1;
			// a hand lifting a door (RSQ_DistanceGrab's doors, asked by name)
			let dit = ServiceIterator.Find("RSQDG_DoorService");
			Service ds;
			while (ds = dit.Next()) if (ds.GetInt("door.holding", "", h, 0, null) >= 0) return 1;
			return 0;
		}
		// HOLSTER LOCK (rig.zs lockCls): the holster this gun is locked to, or -1; and whether gun holster intArg takes a lock
		if (request == "rig.locked")
		{
			int n = who ? who.PlayerNumber() : consoleplayer;
			return rig.LockedTo(n, stringArg);
		}
		if (request == "rig.lockable")
		{
			int n = who ? who.PlayerNumber() : consoleplayer;
			if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return 0;
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
			for (int r = 0; r < RSQTR_Region.N; r++)
				if (rig.lastPut[n * RSQTR_Region.N + r] ~== stringArg) return r;
			return -1;
		}
		return -1;
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
