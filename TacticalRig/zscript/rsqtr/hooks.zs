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
//   GetInt("rig.busy", "", hand, 0, pawn)   1 while the hand is in a holster,
//                                           holds a Distance Grab door, the cigarette or the Zippo
// The hands are known on the console player's own machine only, so both answers are
// for that player (a pawn passed as objectArg that is someone else's gets 0 / -1).
//   GetInt("rig.drawtic", "", 0, 0, pawn)   level.maptime of that player's last draw from
//                                           a holster this map, or -1 (RSQ_Score's Quick Draw)
//   GetString("rig.drawn", "", 0, 0, pawn)  the weapon class that draw brought up, or ""
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
		if (request == "rig.drawtic")
		{
			int n = who ? who.PlayerNumber() : -1;
			return (n >= 0 && n < MAXPLAYERS && rig.drawTic[n] > 0) ? rig.drawTic[n] - 1 : -1;
		}
		if (request == "rig.busy")
		{
			if (!local) return 0;
			if (rig.HandBusy(h)) return 1;
			let cig = RSQTR_Cig.Get();
			if (cig && (cig.cigHand[consoleplayer] == h || cig.zipHand[consoleplayer] == h)) return 1;
			// a hand lifting a door (RSQ_DistanceGrab's doors, asked by name)
			let dit = ServiceIterator.Find("RSQDG_DoorService");
			Service ds;
			while (ds = dit.Next()) if (ds.GetInt("door.holding", "", h, 0, null) >= 0) return 1;
			return 0;
		}
		return -1;
	}

	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let rig = RSQTR_Rig.Get();
		let who = PlayerPawn(objectArg);
		if (!rig || !who || request != "rig.drawn") return "";
		int n = who.PlayerNumber();
		return (n >= 0 && n < MAXPLAYERS) ? rig.drawClass[n] : "";
	}
}
