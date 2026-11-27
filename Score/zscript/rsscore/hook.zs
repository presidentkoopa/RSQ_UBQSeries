// ============================================================================
// THE ARCADE LAYER: the grappling hook, the whip, and the mix of tools across a fight.
//
// The owner, 10-27: the series' mods are tools for your hands (saber and Force, ShieldSaw, hook,
// Distance Grab, Tactical Rig, SlowMo); the scorer is the arcade room that ties them together --
// it rewards style and the combos BETWEEN them, and it must work on any monster set: nothing here
// names a monster class. Brutal Doom-specific scoring is later, not here.
//
// REBUILT 2026-11-27 for today's Grapple and Whip (owner, asked what Score does about the rebuilt Grapple and Whip:
// "New rows for new moves"). The rows that could no longer happen are gone: Reeled In, Ping-Pong, Hard Landing, Fly
// Ball, the hook half of Bowling, Swinging, Hanging Shot, Dismount (RSQ Grapple answers only names that start "g2.";
// RSQ Whip has no rope). New: Kick and Air Spike (the Grapple's two blows), Wide Swing and Ground Crack (the Whip's
// two moves).
//
// WHERE THE FACTS COME FROM, nothing linked:
//   RSQGR_Service     RSQ Grapple's ledger (Grapple/zscript/rsqgr/service.zs): for a monster, "g2.kicked" and
//                     "g2.spiked" (the tic of its last kick and air spike, -1 never) and "g2.by" (the player number).
//                     The kick is noted BEFORE its blow lands, so at the death it already reads this tic.
//   RSQGN_NeonSpike   RSQ Grenade's explosion where an air spike lands (the spike itself deals no damage), by class name
//   RSQ Whip          its Wide Swing is the one blow of damage type Whip; its Ground Crack deals none and tells Score
//                     with a touch, "ground.crack" (Whip/zscript/rsqwp/lash.zs GroundImpact; tools.zs: whip.ground)
//   RS_Melee.Kind     melee.zs: what struck (MK_HOOK the Grapple's kick, MK_WHIP the Wide Swing)
//
// THE COMBO SYSTEM (combo.zs) is the general form of these: every monster keeps the ordered chain of
// tools that touched it. The Grapple's kick (hook.kick) and air spike (hook.spike) and the Whip's two moves
// (whip.crack, whip.ground) are tools in that chain; Variety stands down on a kill whose own chain mixed two tools or
// more.
// ============================================================================

class RS_HookSeed play
{
	static void Names(out Array<String> into)
	{
		// 2026-11-27: nine names became seven (six out, four in; the lists are in this file's header)
		into.Push("RS_Bonus_Bowling");
		into.Push("RS_Bonus_HookKick");
		into.Push("RS_Bonus_AirSpike");
		into.Push("RS_Bonus_Lashed");
		into.Push("RS_Bonus_WideSwing");
		into.Push("RS_Bonus_GroundCrack");
		into.Push("RS_Bonus_Variety");
	}
}

class RS_Grapple play
{
	// Ask RSQ Grapple's service (its names all start "g2."). -1: no answer, or the grapple is not loaded.
	static int Ask(String request, Actor about, int arg = 0)
	{
		if (!about) return -1;
		return RS_Svc.Int(RS_Svc.GRAPPLE, request, arg, about);
	}

	// THE KICK, as its blow lands (2026-11-27): RSQ Grapple writes the tic and the player on the monster's record
	// before it deals the blow (its core.zs Kick: recKick, recBy, then DamageMobj), so the blow and a death inside it
	// both read "g2.kicked" as this tic. (tools.zs Classify asks this for a 'Melee' blow from the pawn.)
	static bool KickNow(Actor v, int pn)
	{
		return v && Ask("g2.kicked", v) == level.maptime && Ask("g2.by", v) == pn;
	}

	// tics since this player's air spike took the monster (RSQ Grapple's "g2.spiked" is the tic it began), or -1
	static int SpikedBy(Actor v, int pn)
	{
		int t = Ask("g2.spiked", v);
		if (t < 0 || t > level.maptime || Ask("g2.by", v) != pn) return -1;
		return level.maptime - t;
	}

	// RSQ_SlowMo has the world slowed, and not inside the pulse this scorer asked for itself
	static bool SlowNow(RS_ScoreEvent ev)
	{
		if (!ev.killer) return false;
		if (ev.tracker && level.maptime <= ev.tracker.slowmoUntil) return false;
		return RS_Physical.AskSlowMo("slowmo.active") == 1;
	}
}


// Bowling: a live monster you threw by hand (out of the Headlock: RSQ Melee's own toss, or Distance Grab carrying it)
// struck this one, and it died of it. 2026-11-27 (owner: "New rows for new moves"): the half that asked RSQ Grapple
// for a body its hook threw ("struck", "struck.by", "pin") is gone with the Grapple's throw, and so is a monster swung
// on the whip; the Headlock toss is what is left, at the flat pay it always had.
class RS_Bonus_Bowling : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Bowling"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.victim || ev.killerNum < 0) return 0.0;
		// the body is the blow's inflictor and it is not the victim (11-03, sheet X4)
		return (RS_Melee.KillTool(ev) == "headlock.throw" && ev.inflictor && ev.inflictor != ev.victim && ev.inflictor.bIsMonster) ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// ---- RSQ GRAPPLE'S TWO BLOWS (2026-11-27; owner: "New rows for new moves"). Each row is named as the Grapple's own
// README and code name the move. Family and pay are copies of the nearest row that was already here, for the owner to
// change: Kick is Butt Stroke's (a light blow that itself kills: Melee, 0.3), Air Spike is Slammed's (a body driven
// into the floor: Melee, 0.5, a big moment).

// Kick: the Grapple's kick killed it (you hooked it, flew to it, and arriving is the kick: 30 damage). The ledger
// reads that blow as hook.kick (tools.zs Classify, RS_Grapple.KickNow), so Brawler and the punch rows leave it alone.
class RS_Bonus_HookKick : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Kick"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.KillTool(ev) == "hook.kick" ? MULT : 0.0; }
}

// Air Spike: the monster you spiked died of the explosion where it landed. The spike deals no damage of its own
// (Grapple/README.md, Limits): the blow is RSQ Grenade's Neon Crescent (class RSQGN_NeonSpike, read as hook.spike),
// so without RSQ Grenade there is no such kill. Only the spiked monster itself: another monster the same explosion
// kills gets no row (the blow still counts as the hook's tool for Variety and the N-Tool rows). WINDOW: the spike
// began at most 4 s ago (RSQ Grapple lets it fall for 3 s at most, its TickSpike).
class RS_Bonus_AirSpike : RS_ScoreBonus
{
	const MULT = 0.5;
	const WINDOW = 140;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Air Spike"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.victim || ev.killerNum < 0 || RS_Melee.KillTool(ev) != "hook.spike") return 0.0;
		int t = RS_Grapple.SpikedBy(ev.victim, ev.killerNum);
		return (t >= 0 && t <= WINDOW) ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// ---- RSQ WHIP'S TWO MOVES (2026-11-27; owner: "New rows for new moves"; the Whip's own words for them: "a big wide
// swing" and "if i crack down to the ground the impact sends out a shockwave and sends enemies airborne").

// Lashed: the whip killed it: a blow of damage type Whip from you, which since 2026-11-27 is the Wide Swing and
// nothing else (Whip/zscript/rsqwp/lash.zs Sweep). The flat pay it always had; the light and heavy crack rates asked
// RSQ Whip's "crack.k", which answers "not happened" now that the pointed crack is gone, and went with it.
class RS_Bonus_Lashed : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Lashed"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Kind(ev) == RS_Melee.MK_WHIP ? MULT : 0.0; }
}

// Wide Swing: one Wide Swing killed two or more. A single Wide Swing kill is Lashed's already (every Whip blow is a
// Wide Swing now), so this row is what the move adds: everything in its 120 degrees at once. A copy of Seismic (one
// Ground Pound killing several: 0.3 for each kill before this one, up to 0.9, in place of Multi-Kill), for the owner
// to change. One swing hits all it reaches on one tic, and the Whip allows a move only every 8 tics, so "the same
// tool on the same tic" (Multi-Kill's own count) is one swing.
class RS_Bonus_WideSwing : RS_ScoreBonus
{
	const PER = 0.3;
	const MAXMULT = 0.9;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Wide Swing"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || RS_Melee.KillTool(ev) != "whip.crack") return 0.0;
		int n = RS_Row_MultiKill.Earlier(ev);
		return n > 0 ? min(MAXMULT, PER * n) : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Row_MultiKill"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 2 * PER - 0.001; }
}

// Ground Crack: you killed a monster while it was in the air, within 2 s of your Ground Crack's shockwave catching
// it. The shockwave deals no damage, so the Whip tells Score with a touch as it catches each monster ("ground.crack",
// kept on the ledger as the tool whip.ground); "in the air" is Juggle's own test (2 units off the floor, not a flyer,
// not standing on another), so a boss or a heavy monster the wave only staggers gives nothing. Any blow of yours may
// make the kill. A copy of Air Combo's pay (0.3, in place of Juggle and Skeet) in Skeet's family, for the owner to change.
class RS_Bonus_GroundCrack : RS_ScoreBonus
{
	const MULT = 0.3;
	const WINDOW = 70;   // RS_Melee.LAUNCH_TICS: the 2 s Juggle gives a launch
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Ground Crack"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || !ev.victim || ev.killerNum < 0 || !RS_Melee.Airborne(ev.victim)) return 0.0;
		let led = RS_ComboLedger.Get();
		int t = led ? led.SinceTool(ev.victim, ev.killerNum, "whip.ground") : -1;
		return (t >= 0 && t <= WINDOW) ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Juggle" || other is "RS_Bonus_Skeet"; }
}

// Variety: several of the series' tools in one fight. A fight is kills each within 10 s of the last.
// Each kill tags the tools it used (a shot, the saber, the shield, the hook, a Distance Grab throw, a
// holster draw, bare hands and blades; slow motion is not a tool here, it multiplies style through
// Bullet Time); a kill that brings a NEW tool into the fight,
// once three or more are in, pays 0.15 per tool past two (up to 0.6). Using the same tools again pays
// nothing more: it is the mix that pays, not the spam.
class RS_Bonus_Variety : RS_ScoreBonus
{
	// one bit per mod a tool can come from (tools.zs ModOf); 11-03 (sheet S4, B S15): the whip, Melee's fists and
	// the grenade are their own, not lumped with the hook, Brutal Doom's hands or nothing
	enum ETool { T_GUN = 1, T_SABER = 2, T_SHIELD = 4, T_HOOK = 8, T_GRAB = 16, T_RIG = 32, T_HANDS = 64, T_WHIP = 128, T_FISTS = 256, T_GRENADE = 512 }
	const NBITS = 10;
	const PER = 0.15;
	const MAXMULT = 0.6;
	const FIGHTTICS = 350;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Variety"; }

	static int Bit(String mod)
	{
		if (mod == "gun") return T_GUN;
		if (mod == "saber") return T_SABER;
		if (mod == "shield") return T_SHIELD;
		if (mod == "hook") return T_HOOK;
		if (mod == "grab") return T_GRAB;
		if (mod == "rig") return T_RIG;
		if (mod == "bd") return T_HANDS;
		if (mod == "whip") return T_WHIP;
		if (mod == "melee") return T_FISTS;
		if (mod == "grenade") return T_GRENADE;
		return 0;
	}

	// the tools this kill used: every tool in its chain (the ledger's reading of the blows), plus the facts that
	// are not blows -- a holster draw (a rope holding you up went 2026-11-27: neither mod has a rope now)
	static int Tools(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0;
		RS_Combo.ChainOf(ev);
		int m = 0;
		for (int k = 0; k < ev.chain.Size(); k++) m |= Bit(RS_Tool.ModOf(ev.chain[k]));
		if (RS_Physical.ThrownBy(ev)) m |= T_GRAB;
		int t = RS_Physical.AskRig("rig.drawtic", ev.killer);
		if (t >= 0 && level.maptime - t <= RS_Bonus_QuickDraw.WINDOW) m |= T_RIG;
		return m;
	}

	static int Count(int m)
	{
		int n = 0;
		for (int b = 0; b < NBITS; b++) if (m & (1 << b)) n++;
		return n;
	}

	private int Fight(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		return (tr && level.maptime - tr.varTic <= FIGHTTICS) ? tr.varMask : 0;
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (ev.killerNum < 0) return 0.0;
		if (RS_Combo.Mixed(ev)) return 0.0;   // this kill's own chain mixed its tools (combo.zs)
		int had = Fight(ev);
		int now = Tools(ev);
		if (!(now & ~had)) return 0.0;
		int n = Count(had | now);
		return n >= 3 ? min(MAXMULT, PER * (n - 2)) : 0.0;
	}

	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || ev.killerNum < 0) return;
		tr.varMask = Fight(ev) | Tools(ev);
		tr.varTic = level.maptime;
	}

	// five tools in one fight
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= PER * 3 - 0.001; }
}
