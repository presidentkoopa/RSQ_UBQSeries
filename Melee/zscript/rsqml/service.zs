// RSQML_Service -- what RSQ Melee answers any mod that asks by name (no compile dependency):
//     let it = ServiceIterator.Find("RSQML_Service"); Service s = it.Next();
// With RSQ Melee absent there is no such service and nothing to read.
//
//   GetInt "loaded"           1
//   GetInt "punch.glove"      objectArg = a damage inflictor: 1 when it is one of the boxing gloves (a punch), else 0
//   GetInt "punch.kind"       the glove's last punch: 0 jab, 1 hook, 2 uppercut; -1 not a glove
//   GetInt "punch.body"       1 landed below the chest            GetInt "punch.counter"  1 into an attack wind-up
//   GetInt "punch.star"       1 a Star Punch                       GetInt "punch.chain"    One-Two: alternating hits in a row
//   GetInt "punch.hand"       0 main, 1 off
//   GetInt "punch.kinds"      this player's punches inside 1 s, oldest first, digits kind + 1 (jab, jab, hook = 112)
//   GetInt "punch.run"        Dempsey: alternating hooks in a row, this one included (0 not a hook)
//   GetDouble "punch.power"   0..1 between Punch Min Speed and Punch Full Speed; -1 not a glove
//   GetDouble "punch.speed"   the swing's average, m/s; -1 not a glove
//   GetInt "guard"            objectArg = the pawn: tics the Guard has been up (0 down)
//   GetInt "headlock.claim"   objectArg = the pawn: 1 while the off-hand grip press is the Headlock's (Distance Grab
//                             stands down for it); 0 not
//   GetInt "headlock.holding" objectArg = a monster: 1 while a Headlock holds it
//   GetInt "launch.age"       objectArg = a monster, intArg = a player number: tics since that player's uppercut launched
//                             it, while it is still off the floor; -1 not (RSQ Gun Bonsai VR's Juggle, launch.zs)
// RSQ Gun Bonsai VR's glove upgrades read "punch.*" in ModifyDamageDealt (the glove is the inflictor there).
class RSQML_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "loaded") return 1;
		if (request.Left(6) == "punch.")
		{
			let g = RSQ_Glove(objectArg);
			if (request == "punch.glove") return g ? 1 : 0;
			if (!g) return -1;
			if (request == "punch.kind") return g.lastKind;
			if (request == "punch.body") return g.lastBody ? 1 : 0;
			if (request == "punch.counter") return g.lastCounter ? 1 : 0;
			if (request == "punch.star") return g.lastStar ? 1 : 0;
			if (request == "punch.chain") return g.lastChain;
			if (request == "punch.hand") return g.lastHand;
			if (request == "punch.kinds") return g.lastKinds;
			if (request == "punch.run") return g.lastRun;
			return -1;
		}
		if (request == "guard")
		{
			let a = Actor(objectArg);
			let gd = RSQML_Guard.Get();
			if (!a || !a.player || !gd) return 0;
			int pn = a.PlayerNumber();
			return (pn >= 0 && pn < MAXPLAYERS) ? gd.guardTics[pn] : 0;
		}
		if (request == "headlock.claim")
		{
			let hl = RSQML_Headlock.Get();
			return (hl && hl.ClaimNow(PlayerPawn(objectArg))) ? 1 : 0;
		}
		if (request == "launch.age") return RSQML_Launched.AgeFor(Actor(objectArg), intArg);
		if (request == "headlock.holding")
		{
			let hl = RSQML_Headlock.Get();
			return (hl && hl.IsHolding(Actor(objectArg))) ? 1 : 0;
		}
		return 0;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let g = RSQ_Glove(objectArg);
		if (request == "punch.power") return g ? g.lastPower : -1;
		if (request == "punch.speed") return g ? g.lastSpeed : -1;
		return 0;
	}
}
