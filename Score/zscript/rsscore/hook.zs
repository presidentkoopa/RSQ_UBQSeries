// ============================================================================
// THE ARCADE LAYER: the grappling hook, and the combos that cross mods.
//
// The owner, 10-27: the series' mods are tools for your hands (saber and Force, ShieldSaw, hook,
// Distance Grab, Tactical Rig, SlowMo); the scorer is the arcade room that ties them together --
// it rewards style and the combos BETWEEN them, and it must work on any monster set: nothing here
// names a monster class. Brutal Doom-specific scoring is later, not here.
//
// WHERE THE FACTS COME FROM, nothing linked:
//   RSQGR_Service     RSQ_Grapple's ledger (zscript/rsqgr/service.zs there): who is on a line, who
//                     was hooked by whom and how long ago, the ping-pong volleys, the yank's flight,
//                     the bodies it struck (bowling), the whip's crack, the player's swing, release
//                     and landing. Every blow it deals is noted BEFORE it lands, so at the death it
//                     already reads 0.
//   RS_Melee.Kind     melee.zs: what struck (saber, Force, disc, bash, grind, blade, fist, boot,
//                     and now the hook's own blows MK_HOOK and the whip MK_WHIP)
//   RS_Physical       physical.zs: a shot, a Distance Grab throw, the rig's draw, SlowMo's clock
//
// NOTHING SCORES TWICE: Pulled In is the saber's Force
// pull, Reeled In the hook's -- one replaces the other; Skeet and Juggle are a body in the air, Fly
// Ball one the hook threw -- it replaces them; Air is your jump, Swinging and Dismount the rope's
// height -- they replace it; a thrown body's blows were read as punches (Brawler 0.5, Knockdown,
// Counter) and are MK_HOOK now, paid only here; Bullet Time no longer pays for being slow, it
// multiplies the style of the kill (AfterOthers).
//
// THE COMBO SYSTEM (combo.zs) is the general form of these: every monster keeps the ordered chain of
// tools that touched it. Reeled In, Ping-Pong, Fly Ball and Bowling stay here with their measured pay
// and act as named combos backed by their own rows (the chain pays nothing more for the tools they
// cover); the hook's bite, yank (and a body it threw striking another) and the whip are tools in that
// chain; Variety stands down on a kill whose own chain mixed two tools or more.
// ============================================================================

class RS_HookSeed play
{
	static void Names(out Array<String> into)
	{
		into.Push("RS_Bonus_ReeledIn");
		into.Push("RS_Bonus_PingPong");
		into.Push("RS_Bonus_Bowling");
		into.Push("RS_Bonus_HardLanding");
		into.Push("RS_Bonus_FlyBall");
		into.Push("RS_Bonus_Swinging");
		into.Push("RS_Bonus_Dismount");
		into.Push("RS_Bonus_Lashed");
		into.Push("RS_Bonus_Variety");
	}
}

class RS_Grapple play
{
	// Ask RSQ_Grapple's service. -1: no answer, or the grapple is not loaded.
	static int Ask(String request, Actor about, int arg = 0)
	{
		if (!about) return -1;
		return RS_Svc.Int(RS_Svc.GRAPPLE, request, arg, about);
	}

	static Actor AskActor(String request, Actor about)
	{
		if (!about) return null;
		return RS_Svc.Act(RS_Svc.GRAPPLE, request, about);
	}

	// this killer hooked the victim, and it was on the line at most `within` tics ago
	static bool HookedByKiller(RS_ScoreEvent ev, int within)
	{
		if (!ev.victim || ev.killerNum < 0) return false;
		int t = Ask("hooked", ev.victim);
		return t >= 0 && t <= within && Ask("hooked.by", ev.victim) == ev.killerNum;
	}

	// RSQ_SlowMo has the world slowed, and not inside the pulse this scorer asked for itself
	static bool SlowNow(RS_ScoreEvent ev)
	{
		if (!ev.killer) return false;
		if (ev.tracker && level.maptime <= ev.tracker.slowmoUntil) return false;
		return RS_Physical.AskSlowMo("slowmo.active") == 1;
	}
}


// Reeled In: the hook brought it to you (it came, or you reeled yourself to it), and a melee blow
// finished it within two seconds of the line letting go -- a shield bash, the saw, a saber cut, the
// Force, a fist, a boot. Each Reeled In inside four seconds of the last pays more: a chain.
class RS_Bonus_ReeledIn : RS_ScoreBonus
{
	const MULT = 0.3;
	const PER = 0.15;
	const MAXMULT = 0.75;
	const WINDOW = 70;
	const CHAIN = 140;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Reeled In"; }

	private bool Fires(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k == RS_Melee.MK_NONE || k == RS_Melee.MK_HOOK) return false;
		return RS_Grapple.HookedByKiller(ev, WINDOW);
	}
	private int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		return (tr && tr.reelCount > 0 && level.maptime - tr.reelTic <= CHAIN) ? tr.reelCount : 0;
	}
	override double Evaluate(RS_ScoreEvent ev) { return Fires(ev) ? min(MAXMULT, MULT + PER * Earlier(ev)) : 0.0; }
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || !Fires(ev)) return;
		tr.reelCount = Earlier(ev) + 1;
		tr.reelTic = level.maptime;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_PulledIn"; }
	// the third of a chain and on
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= MULT + 2 * PER - 0.001; }
}

// Ping-Pong: hooked in, sent flying back out (a Force push, a kick, a bash, a blast), hooked again --
// and then killed by you. Each volley past the first adds more.
class RS_Bonus_PingPong : RS_ScoreBonus
{
	const MULT = 0.4;
	const PER = 0.2;
	const MAXMULT = 1.0;
	const WINDOW = 175;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Ping-Pong"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Grapple.HookedByKiller(ev, WINDOW)) return 0.0;
		int v = RS_Grapple.Ask("volleys", ev.victim);
		return v >= 1 ? min(MAXMULT, MULT + PER * (v - 1)) : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= MULT + PER - 0.001; }
}

// Bowling: a body your hook threw struck this one, and it died of it (or you finished it inside a
// second). The second thing one throw strikes pays more, and so on.
class RS_Bonus_Bowling : RS_ScoreBonus
{
	const MULT = 0.5;
	const PER = 0.25;
	const MAXMULT = 1.25;
	const WINDOW = 35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Bowling"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.victim || ev.killerNum < 0) return 0.0;
		// a body thrown by hand struck it (11-03, sheet X4): the Headlock toss (Distance Grab carrying it, or Melee's own),
		// a monster swung on the whip -- the body is the blow's inflictor and it is not the victim
		String t0 = RS_Melee.KillTool(ev);
		if ((t0 == "headlock.throw" || t0 == "whip.flail") && ev.inflictor && ev.inflictor != ev.victim && ev.inflictor.bIsMonster) return MULT;
		int t = RS_Grapple.Ask("struck", ev.victim);
		if (t < 0 || t > WINDOW || RS_Grapple.Ask("struck.by", ev.victim) != ev.killerNum) return 0.0;
		int pin = max(1, RS_Grapple.Ask("pin", ev.victim));
		return min(MAXMULT, MULT + PER * (pin - 1));
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Hard Landing: the throw itself killed the body you hooked -- its landing, or the wall or the thing
// it struck on the way.
class RS_Bonus_HardLanding : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Hard Landing"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_HOOK) return 0.0;
		return RS_Grapple.Ask("landing", ev.victim) == 0 ? MULT : 0.0;
	}
}

// Fly Ball: killed in the air while your hook was throwing it (on the yank's path, or flying on
// after it) -- by anything but the throw's own landing.
class RS_Bonus_FlyBall : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Fly Ball"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.victim || ev.killerNum < 0 || ev.ringOut) return 0.0;
		if (RS_Melee.Kind(ev) == RS_Melee.MK_HOOK) return 0.0;
		if (RS_Grapple.Ask("yanked", ev.victim) < 1) return 0.0;
		return RS_Grapple.Ask("hooked.by", ev.victim) == ev.killerNum ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Skeet" || other is "RS_Bonus_Juggle"; }
}

// THE ROPE UNDER YOU: RSQ_Grapple's line or RSQ Whip's (its own fork of the line, answering the same request names,
// 11-03: sheet S17, W11). The first that answers wins.
class RS_Rope play
{
	static int Ask(String request, Actor who)
	{
		int v = RS_Grapple.Ask(request, who);
		if (v >= 0) return v;
		return RS_Whip.Ask(request, who);
	}
}

// Swinging: a kill while a latched rope holds you off the ground AND carries you. Since 11-02 the Grapple's default
// is the pull, where you hang still on a latched rope; hanging and shooting is Hanging Shot, a smaller row (sheet
// B S6, G8). A rope that cannot say its speed (an older mod) counts as swinging, as before.
class RS_Bonus_Swinging : RS_ScoreBonus
{
	const MULT = 0.35;
	const HANG = 0.15;
	const MOVING = 20;   // rope.speed (map units a tic x 10): 2 a tic and up is a swing, under it a hang
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Swinging"; }
	override int RowCount() const { return 2; }
	override String RowName(int i) const { return i == 0 ? "Swinging" : "Hanging Shot"; }
	bool lastHang;
	override double RowShare(int i) const { return (i == 1) == lastHang ? 1.0 : 0.0; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		lastHang = false;
		if (!ev.killer || ev.ringOut) return 0.0;
		if (RS_Rope.Ask("swinging", ev.killer) != 1) return 0.0;
		int sp = RS_Rope.Ask("rope.speed", ev.killer);
		lastHang = sp >= 0 && sp < MOVING;
		return lastHang ? HANG : MULT;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Air"; }
	override String DebugName() const { return lastHang ? "Hanging Shot" : "Swinging"; }
}

// Dismount: you let go of a swing in the air WITH SPEED (sheet B S7: a plain drop off the pull is not a dismount; a
// rope that cannot say the speed counts), and killed before you came down (within 3 s of letting go) or within a
// second of landing.
class RS_Bonus_Dismount : RS_ScoreBonus
{
	const MULT = 0.4;
	const AIR = 105;
	const LAND = 35;
	const SPEED = 60;    // released.speed (x 10): 6 a tic, the "sent flying" line the hook's own volleys use
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Dismount"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || ev.ringOut) return 0.0;
		if (RS_Rope.Ask("swinging", k) == 1) return 0.0;
		int rel = RS_Rope.Ask("released", k);
		if (rel < 0) return 0.0;
		int sp = RS_Rope.Ask("released.speed", k);
		if (sp >= 0 && sp < SPEED) return 0.0;
		if (RS_Rope.Ask("airborne", k) == 1) return rel <= AIR ? MULT : 0.0;
		int land = RS_Rope.Ask("landed", k);
		return (land >= 0 && land <= LAND && rel >= land) ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Air"; }
}

// Lashed: a whip's crack killed it (RSQ Whip, or RSQ_Grapple's old whip). 11-03 (sheet W1, "Bullwhip"): a HEAVY crack
// -- the top half of the whip's speed range, RSQWP_Service "crack.k" 50 and up -- pays more; a whip that cannot say
// pays the old flat. The name is the owner's to change.
class RS_Bonus_Lashed : RS_ScoreBonus
{
	const MULT = 0.25;
	const LIGHT = 0.2;
	const HEAVY = 0.35;
	const HEAVY_K = 50;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Lashed"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_WHIP) return 0.0;
		int k = RS_Whip.Ask("crack.k", ev.victim);
		if (k < 0) return MULT;
		return k >= HEAVY_K ? HEAVY : LIGHT;
	}
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
	// are not blows -- a holster draw, a rope holding you up
	static int Tools(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0;
		RS_Combo.ChainOf(ev);
		int m = 0;
		for (int k = 0; k < ev.chain.Size(); k++) m |= Bit(RS_Tool.ModOf(ev.chain[k]));
		if (RS_Physical.ThrownBy(ev)) m |= T_GRAB;
		if (RS_Grapple.Ask("swinging", ev.killer) == 1 || RS_Grapple.Ask("airborne", ev.killer) == 1) m |= T_HOOK;
		if (RS_Whip.Ask("swinging", ev.killer) == 1 || RS_Whip.Ask("airborne", ev.killer) == 1) m |= T_WHIP;
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
