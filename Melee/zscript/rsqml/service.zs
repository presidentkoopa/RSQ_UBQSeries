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
//   GetInt "punch.height"     where the glove met it, permille of the body's height from its feet (Headshot)
//   GetInt "punch.kinds"      this player's punches inside 1 s, oldest first, digits kind + 1 (jab, jab, hook = 112)
//   GetInt "punch.run"        Dempsey: alternating hooks in a row, this one included (0 not a hook)
//   GetDouble "punch.power"   0..1 between Punch Min Speed and Punch Full Speed; -1 not a glove
//   GetDouble "punch.speed"   the swing's average, m/s; -1 not a glove
//   GetInt "guard"            objectArg = the pawn: tics the Guard has been up (0 down)
//   GetInt "headlock.claim"   objectArg = the pawn: 1 while the off-hand grip press is the Headlock's (Distance Grab
//                             stands down for it); 0 not
//   GetInt "headlock.holding" objectArg = a monster: 1 while a Headlock holds it
//   GetInt "returned.by"      objectArg = a missile: which hand sent it back at its shooter: 0 a punch (Hadouken, a punched
//                             bullet, a catch), 1 Swat Back, 2 the Guard's reflect; -1 not one of ours (RSQ Score, 11-03)
//   GetInt "launch.age"       objectArg = a monster, intArg = a player number: tics since that player's uppercut launched
//                             it, while it is still off the floor; -1 not (RSQ Gun Bonsai VR's Juggle, launch.zs)
//   GetInt "autopunch"        objectArg = a monster, intArg = a player number, doubleArg = a damage share: that player's
//                             empty fist punches it now, full power, as a counter (1 done, 0 no empty fist; RSQ Grapple's
//                             Scorpion)
// RSQ Gun Bonsai VR's glove upgrades read "punch.*" in ModifyDamageDealt (the glove is the inflictor there).
class RSQML_Service : Service
{
	// THE MENU (MENU_PASS_BRIEF.md, owner 11-04): GetIntUI("menu.locked", <upgrade>) 1 while that Gun Bonsai VR upgrade is
	// not learned by the console player (the row then does nothing), 0 learned. Asked by the RSQMLGbOption rows only while
	// Gun Bonsai VR is loaded; read from RSQML_Sim's once-a-second cache (core.zs). Not in a game: 1.
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request ~== "menu.locked")) return 0;
		let sim = RSQML_Sim(StaticEventHandler.Find("RSQML_Sim"));
		if (!sim || !players[consoleplayer].mo) return 1;
		static const String F[] = { "Guard", "WallSplat", "GroundPound", "ClearOut", "HumanShield" };
		for (int i = 0; i < F.Size(); i++)
			if (stringArg ~== F[i]) return sim.menuLv[i] < 0 ? 0 : (sim.menuLv[i] >= 1 ? 0 : 1);
		return 0;
	}

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
			if (request == "punch.height") return g.lastHeight;
			if (request == "punch.run") return g.lastRun;
			return -1;
		}
		// "autopunch": objectArg = a monster, intArg = a player number, doubleArg = the damage share: that player's empty fist
		// punches it now at full power, as a counter (RSQML_Gloves.AutoPunch). 1 done, 0 no empty fist. RSQ Grapple's
		// Scorpion asks it.
		if (request == "autopunch")
		{
			let v = Actor(objectArg);
			let gl = RSQML_Gloves.Get();
			if (!gl || !v || intArg < 0 || intArg >= MAXPLAYERS || !playeringame[intArg]) return 0;
			return gl.AutoPunch(players[intArg].mo, v, doubleArg) ? 1 : 0;
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
		if (request == "returned.by")
		{
			let gl = RSQML_Gloves.Get();
			let m = Actor(objectArg);
			return (gl && m) ? gl.ReturnedHow(m) : -1;
		}
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
