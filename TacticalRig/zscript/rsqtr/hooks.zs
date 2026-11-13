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
//   GetDouble("region.x" / ".y" / ".z", "", region, 0, pawn)  that place's centre, world coordinates (1e9: unknown)
// And the rig asks a pack's own grenade of a Service named RSQTR_NadeService (rig.zs NadeService): "nade.weapon",
// "nade.ammo".
// rig.drawtic, rig.drawn and rig.holster are synced play state (the draw is a network event), so they answer for any
// player, not only the console player. More requests are answered below (rig.locked, rig.regionname, ...): each is
// described where it is answered.
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

	// THE SHIELDSAW'S HOLSTER (owner 2026-11-07 10:31): with RSQ ShieldSaw loaded and its "Take It From" set to Over the
	// (Off) Shoulder (ssq_mount_spot 0, that player's own setting), the off-shoulder gun holster is the ShieldSaw's -- the
	// left shoulder (4) for a right-handed player, the right (5) left-handed, as the ShieldSaw follows handedness (the
	// engine's vr_control_scheme, which RSQ Accessibility's Handedness sets). No gun goes in it by hand or by RSQ Wheel's
	// web, whether the shield is on the shoulder or in the hand; only the ShieldSaw's own option moves it. -1: none.
	// By name only: no ShieldSaw, no claim.
	static int ShieldHolster(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return -1;
		String cn = "SSQ_ShieldSaw";
		class<Inventory> c = cn;
		if (!c) return -1;
		let sp = CVar.GetCVar("ssq_mount_spot", pmo.player);
		if (!sp || sp.GetInt() != 0) return -1;
		return RSQTR_Body.LeftHanded() ? 5 : 4;
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
			let dit = ServiceIterator.Find("RSQDG_DoorService");
			Service ds;
			while (ds = dit.Next()) if (ds.GetInt("door.holding", "", h, 0, null) >= 0) return 1;
			return 0;
		}
		// HOLSTER ASSIGNMENT (rig.zs lockCls): the holster this gun is assigned to, or -1; and whether gun holster intArg takes a lock
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

	// RSQ FnF'S FLASHLIGHT CLIP, BESIDE THE FLARE HOLSTER (owner 11-11 15:19, rig.zs RSQTR_Region.TORCH_F): "torch.x" / ".y" /
	// ".z", the clip's centre in map units for the pawn in objectArg, while the rig is on for that player; 1e9 otherwise (FnF
	// then hangs it at its own place). FnF keeps the grab and its radius.
	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// A PLACE'S CENTRE (2026-11-13, Selaco VR draws its own grenade at the grenade spot): "region.x" / ".y" / ".z" for
		// place intArg (RSQTR_Region), world coordinates, that player (objectArg); 1e9 when the rig cannot say
		if (request == "region.x" || request == "region.y" || request == "region.z")
		{
			let rg = RSQTR_Rig.Get();
			let pw = PlayerPawn(objectArg);
			if (!rg || !pw || !pw.player || intArg < 0 || intArg >= RSQTR_Region.N || !RSQTR_Rig.Flag("rsqtr_on", pw.player, true)) return 1e9;
			Vector3 at = rg.RegionAt(pw, intArg);
			return request == "region.x" ? at.x : request == "region.y" ? at.y : at.z;
		}
		if (request != "torch.x" && request != "torch.y" && request != "torch.z") return 1e9;
		let rig = RSQTR_Rig.Get();
		let pm = PlayerPawn(objectArg);
		if (!rig || !pm || !pm.player || !RSQTR_Rig.Flag("rsqtr_on", pm.player, true)) return 1e9;
		Vector3 at = rig.TorchAt(pm);
		return request == "torch.x" ? at.x : request == "torch.y" ? at.y : at.z;
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
		// THE HOLSTER WEB (11-07 10:31): the item another mod holds gun holster intArg with ("SSQ_ShieldSaw": RSQ ShieldSaw's
		// shoulder, ShieldHolster), "" none
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
