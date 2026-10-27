// THE REST OF THE SERIES, FOUND BY NAME.
//
// Nothing here links against another mod: a class name looked up at run time is
// null when that mod is absent, and the hook simply never fires.
//
//   RS_ShieldSawQ  its stowed shield hangs over the off shoulder and Use there draws
//                  it. While the shield is on the shoulder, the rig leaves that
//                  shoulder region alone (rsqtr_yield_shield), so the two never act
//                  on the same press.
//
// Other mods can ask the rig what it holds, through RSQTR_RigService:
//   GetInt("rig.region", "", hand)          region the hand is in, or -1
//   GetInt("rig.busy", "", hand, 0, pawn)   1 while the hand is in a region or a radial,
//                                           holds a door, the cigarette or the Zippo
// The hands are known on the console player's own machine only, so both answers are
// for that player (a pawn passed as objectArg that is someone else's gets 0 / -1).
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
		if (request == "rig.busy")
		{
			if (!local) return 0;
			if (rig.HandBusy(h)) return 1;
			let cig = RSQTR_Cig.Get();
			if (cig && (cig.cigHand[consoleplayer] == h || cig.zipHand[consoleplayer] == h)) return 1;
			let door = RSQTR_Door.Get();
			if (door && door.Holding(h)) return 1;
			return 0;
		}
		return -1;
	}
}
