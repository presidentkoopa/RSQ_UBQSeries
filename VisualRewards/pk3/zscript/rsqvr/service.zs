// RSQVR_Service -- RSQ VisualRewards, for any mod that asks by name (nothing links):
//     let s = ServiceIterator.Find("RSQVR_Service").Next();   // null without VisualRewards
//
//   GetInt "loaded"      1 (the pk3 is here)
//   GetInt "kr.loaded"   1: Kill Rewards is part of this pk3 (Gun Bonsai VR offers its Kill Rewards path only then)
//   GetInt "kr.on"       1 while Kill Rewards is switched on (rsqgb_kr_enabled), 0 off
//   GetInt "kr.perk"     stringArg = BitScavenger / RichBits / Magnet / LuckyKill, objectArg = a player's pawn: the level Kill
//                        Rewards is using for that player (read from Gun Bonsai VR by name; 0 without it)
//   GetDouble "kr.magnet" objectArg = a player's pawn: metres bits drift to that player from (the Magnet node or the
//                        Bits Fly to Me row, whichever is further; 0 = off)
//   GetInt "helper"      objectArg = an actor: 1 when it is one of Brutal Doom's helpers (head hitbox, boot smearer ...) that
//                        never gets a bar, a number or bits (rsqvr/helpers.zs), 0 not
//   GetInt "kr.battery"  (play) intArg = how many, objectArg = the body: that many battery bits burst out of it (RSQ FnF's "Bones
//                        Drop Battery Bits", rsqvr/batterybit.zs; each refills 15% of the toucher's flashlight battery through
//                        FnF). Returns how many came out. Asked whether or not Kill Rewards is on (FnF's own row decides).
// The damage numbers' own hook stays where it was: RSQTHP_DnService "crit" (damnums/events.zs).
class RSQVR_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "loaded") return 1;
		if (request == "kr.loaded") return RSQ_KRHandler(EventHandler.Find("RSQ_KRHandler")) ? 1 : 0;
		if (request == "kr.on") return RSQ_KRHandler.SVB("rsqgb_kr_enabled", true) ? 1 : 0;
		if (request == "kr.perk") return RSQ_KRHandler.Perk(Actor(objectArg), stringArg);
		if (request == "helper") return RSQVR_Helpers.IsHelper(Actor(objectArg)) ? 1 : 0;
		if (request == "kr.battery") return RSQ_KRBatteryBit.Burst(Actor(objectArg), clamp(intArg, 0, 32));
		return 0;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "kr.magnet") { let a = Actor(objectArg); return (a && a.player) ? RSQ_KRHandler.MagnetM(a) : 0; }
		return 0;
	}
}
