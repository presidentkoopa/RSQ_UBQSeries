// ============================================================================
// RSQMB_Service -- for other mods, found by name (nothing links):
//   RSQMB_Lookup.Find("RSQMB_Service").Next().GetInt("miniboss", "", 0, 0, monster)
// objectArg = the monster asked about; requests without one answer for the level. -1: unknown.
//
//   miniboss      1 a living miniboss of this set piece, else 0      (none: how many are alive)
//   thrall        1 a thrall bound to a living miniboss, else 0
//   lives         lives left, the current one included (miniboss), else 0
//   invulnerable  1 while it cannot be hurt (the arrival's charge, a lost life's invulnerability)
//   shield        damage it takes now, permille: 0 while invulnerable, else 1000 x its thralls' cut (1 - 0.8 x living /
//                 the thralls it came with, owner 2026-11-17) / inherited toughness
//   living        its living thralls (miniboss or thrall: the set piece it belongs to)
//   GONE 2026-11-17 (owner), still answered so a reader never breaks: enraged 0 (the greed rule), greed 0, segments 0,
//                 window 0 (the shield segments and their windows), shielded 0 (no immunity while thralls live: its damage
//                 is cut instead, "shield")
//   legendary     1 if it inherited legendary status
//   wasboss       1 when the object is (or was) this set piece's miniboss, dead or alive
//   colour        its set piece's colour, 0xRRGGBB (miniboss or thrall, dead or alive): the Boss bar's (its ladder colour
//                 first, else handler.zs PALETTE, one per miniboss in order); else -1. (Its effects wear the original's
//                 random colour instead, boss.zs fxCol.)
//   bossfor       COUNTS AS A BOSS (owner 2026-11-03: never the engine's BOSS flag). stringArg names the system; 1 when
//                 the monster is a miniboss AND that system's switch in the RSQ Miniboss menu is on, else 0:
//                   "rewards"   Boss Kill Rewards (rsqmb_boss_rewards, on): a living miniboss, or one that died this
//                               tic or the last (so a WorldThingDied handler gets it whichever runs first)
//                   "yank"      Can't Be Yanked (rsqmb_boss_noyank, on): a living miniboss
//                   "headlock"  Can't Be Headlocked (rsqmb_boss_noheadlock, on): a living miniboss
//                   "ldhealth"  LegenDoom: Best Health (rsqmb_boss_ldhealth, on, read when it was made legendary):
//                               Miniboss made it legendary with spawn x max(LD_legendaryhealthboss, LD_legendaryhealth)
//                               / 100 (the HIGHER of the two); stays 1 for that monster (dead or alive). A reader then
//                               uses that max where it would use LD_legendaryhealth
//                 Cheap first test for callers: the monster carries "RSQMB_Ward" (by name); only then ask.
//   bossfight     BOSSFIGHT (bossfight.zs): 1 when the monster came with a Bossfight (miniboss or thrall, dead or alive,
//                 for good: it carries RSQMB_Called); no object: 1 while a Bossfight is arriving or its miniboss lives
//   tier          the Bossfight's tier 0..4 (bossfight.zs Tier) for a Bossfight's miniboss or thrall (dead or alive);
//                 -1 for anything else (no set piece). RSQ VisualRewards draws it as up to 4 pips by the crown
//   bossfights    1 when Bossfights are on (rsqmb_enabled)
//   fightcard.up  (intArg the hand) 1 while the Start Fight card is shown on the inside of the off wrist with its face to
//                 your eyes (RSQ Gun Cards hides its off-hand watch card then; the two sit on opposite sides of the wrist)
//   meter         the Bossfight meter, permille (objectArg the player; none: the console player's), -1 none yet
//   meter.ready   1 while it is full and waiting
//   callin        1 while the watch check + Use would call this player's Bossfight in (objectArg the player; none: the
//                 console player's): Bossfights on, Call It In on, the meter full and not yet called. THE PRESS IS THE
//                 CALL-IN'S then (owner 11-05: "Calling a Bossfight must never also move the gun"): RSQ Tactical Rig's
//                 watch-check gun move asks this and leaves that Use press alone while it is 1
//   meter.bottom  (ui) the screen pixel row just under the meter's slot while it is shown (RSQ SlowMo's countdown bar
//                 and RSQ Score's combo rows go below it), -1 when it is off. While a Bossfight runs: -1 (the miniboss bar
//                 stands where Be Quick or Be Dead is, bossbar.zs, not under Score)
//   meter.x / meter.w / meter.h   (ui, GetDoubleUI; GetIntUI rounds) the meter's BAR in screen pixels while it is shown:
//                 its left edge, width and thickness (the skull is 1.6 x the thickness, 0.3 x it left of the bar); -1 off.
//                 RSQ SlowMo's countdown row under it takes these (owner 11-05: the meter and the countdown always line
//                 up, whatever Meter Size and Bar Size are set to: same icon size, same bar left edge and width)
// GetObject("boss", "", 0, 0, thrall) -> the thrall's miniboss; ("boss", "", n) -> the n-th miniboss.
// GetObject("thrall", "", n, 0, miniboss) -> its n-th thrall (dead or alive), null past the end.
// GetObject("fight.target", "", 0, 0, player) -> RSQ SlowMo DOWN's target in a miniboss fight (design/
//   DOWN_LIVES_MINIBOSS_TIERS.md 2, 2026-11-16): the nearest living thrall of a fight that is on (a bound miniboss alive),
//   else that miniboss; null when no fight is on.
// GetString("powers", "", 0, 0, miniboss) -> what it inherited, comma-separated.
// Play, ui and data scope all answer the same.
// ============================================================================

class RSQMB_Service : Service
{
	static clearscope RSQMB_Boss BossOf(Object o)
	{
		let a = Actor(o);
		if (!a) return null;
		let w = RSQMB_Ward(a.FindInventory("RSQMB_Ward"));
		if (w && w.boss) return w.boss;
		let t = RSQMB_Thrall(a.FindInventory("RSQMB_Thrall"));
		if (t && t.boss) return t.boss;
		return null;
	}

	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!h) return -1;
		let a = Actor(objectArg);
		let b = BossOf(a);
		bool isBoss = b && a && b.mb == a && !b.done && a.health > 0;
		bool isThrall = b && a && b.mb != a && !b.done && a.health > 0;
		if (request ~== "miniboss")
		{
			if (a) return isBoss ? 1 : 0;
			int n = 0;
			for (int i = 0; i < h.bosses.Size(); i++) if (h.bosses[i] && !h.bosses[i].done) n++;
			return n;
		}
		if (request ~== "thrall") return isThrall ? 1 : 0;
		// was this the miniboss itself, alive or dead (RSQ Tactical Rig gives a cigarette on the kill; owner 11-05, +1 since 11-12)
		if (request ~== "wasboss") return (b && a && b.mb == a) ? 1 : 0;
		// gone 2026-11-17 (greed, the segments and their windows, the immunity): answered 0 so readers keep working
		if (request ~== "enraged" || request ~== "greed" || request ~== "window" || request ~== "segments" || request ~== "shielded") return 0;
		if (request ~== "lives") return isBoss ? b.lives : 0;
		if (request ~== "invulnerable") return (isBoss && b.Invulnerable()) ? 1 : 0;
		if (request ~== "shield") return isBoss ? (b.Invulnerable() ? 0 : int(b.TakeFactorData() * 1000)) : 1000;
		if (request ~== "living") return (b && !b.done) ? b.Living() : 0;
		if (request ~== "legendary") return (isBoss && b.legendary) ? 1 : 0;
		if (request ~== "colour" || request ~== "color") return b ? (int(b.col) & 0xFFFFFF) : -1;
		if (request ~== "bossfight")
		{
			if (a) return a.FindInventory("RSQMB_Called") ? 1 : 0;
			return (h.arrPhase || (h.bfBoss && !h.bfBoss.done)) ? 1 : 0;
		}
		if (request ~== "tier") return (b && b.called) ? b.tier : -1;
		// THE BIG BOSS (bigboss.zs): "bigboss" with a monster: 1 the Big Boss or one of its thralls; without: 1 while a Big Boss
		// fight is on (or landing); "ex" the player's Big Boss bar 0..1000 (objectArg the pawn, else the console player's),
		// "ex.ready" 1 when it is full (a Big Boss due)
		if (request ~== "bigboss")
		{
			if (a) return (b && b.big) ? 1 : 0;
			return ((h.arrPhase && h.arrBig) || (h.bfBoss && !h.bfBoss.done && h.bfBoss.big)) ? 1 : 0;
		}
		if (request ~== "ex" || request ~== "ex.ready")
		{
			Actor p = a;
			if (!p) p = players[consoleplayer].mo;
			let m = p ? RSQMB_Meter(p.FindInventory("RSQMB_Meter")) : null;
			if (request ~== "ex.ready") return (m && m.exReady) ? 1 : 0;
			return m ? int(m.exFill) : -1;
		}
		// rank.zs: the Rank 0-100 (-1 not started or Rank off), the director's intensity x1000, 1 while it relaxes
		if (request ~== "rank") return RSQMB_Handler.RankOn() ? int(RSQMB_Handler.RankNow()) : -1;
		if (request ~== "director") { let dh = RSQMB_Handler(EventHandler.Find("RSQMB_Handler")); return dh ? int(dh.drInt * 1000) : 0; }
		if (request ~== "director.relax") { let dh = RSQMB_Handler(EventHandler.Find("RSQMB_Handler")); return (dh && dh.DirRelaxing()) ? 1 : 0; }
		if (request ~== "bossfights") return RSQMB_Handler.BfOn() ? 1 : 0;
		// fightcard.up (intArg the hand): 1 while the Start Fight card is shown on the inside of that hand's wrist with its face
		// to your eyes (the off hand only; this machine's console player; bossfight.zs WristCard). RSQ Gun Cards fades its
		// watch card out for it (owner 11-13); since 2026-11-17 the two are on opposite sides of the wrist, so that is never
		// while Gun Cards' card faces you.
		if (request ~== "fightcard.up") return (intArg == 1 && h.wcUp) ? 1 : 0;
		if (request ~== "meter" || request ~== "meter.ready" || request ~== "callin")
		{
			Actor p = a;
			if (!p) p = players[consoleplayer].mo;
			let m = p ? RSQMB_Meter(p.FindInventory("RSQMB_Meter")) : null;
			if (request ~== "meter.ready") return (m && m.ready) ? 1 : 0;
			if (request ~== "callin") return (m && m.ready && !m.called && RSQMB_Handler.BfOn() && RSQMB_Handler.CI('rsqmb_bf_callin', 1)) ? 1 : 0;
			return m ? int(m.fill) : -1;
		}
		if (request ~== "bossfor")
		{
			if (!b || !a || b.mb != a) return 0;
			if (stringArg ~== "rewards") return (RSQMB_Handler.CI('rsqmb_boss_rewards', 1) && (!b.done || level.maptime - b.diedAt <= 1)) ? 1 : 0;
			if (stringArg ~== "yank") return (RSQMB_Handler.CI('rsqmb_boss_noyank', 1) && isBoss) ? 1 : 0;
			if (stringArg ~== "headlock") return (RSQMB_Handler.CI('rsqmb_boss_noheadlock', 1) && isBoss) ? 1 : 0;
			if (stringArg ~== "ldhealth") return b.ldBoss ? 1 : 0;     // a fact about how its health was set: the switch decided it then
			return 0;
		}
		return -1;
	}
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// LIVES FEED RANK (owner 2026-11-23 09:32): RSQ Score sends "rank.life", intArg 1 a Score life earned, 0 one lost (play)
		if (request ~== "rank.life") { let rh = RSQMB_Handler(EventHandler.Find("RSQMB_Handler")); if (rh) rh.RankLife(intArg != 0); return RSQMB_Handler.RankOn() ? int(RSQMB_Handler.RankNow()) : -1; }
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "meter.bottom") return RSQMB_Handler.MeterBottom();
		if (request ~== "meter.x" || request ~== "meter.w" || request ~== "meter.h") return int(round(MeterBar(request)));
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}
	override double GetDoubleUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "meter.x" || request ~== "meter.w" || request ~== "meter.h") return MeterBar(request);
		return GetIntUI(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}
	// the bar's rect (hud.zs MeterRect) while the meter is shown; -1 while a Bossfight runs (the miniboss bar is not under
	// Score, bossbar.zs) or the meter is off
	static ui double MeterBar(String request)
	{
		if (gamestate != GS_LEVEL) return -1;
		double x, y, w, h, bot;
		if (RSQMB_Handler.StackShown()) return -1;   // the miniboss bar is not under Score (bossbar.zs)
		else if (!RSQMB_Handler.MeterShown()) return -1;
		else { [x, y, w, h] = RSQMB_Handler.MeterRect(); }
		if (request ~== "meter.x") return x;
		if (request ~== "meter.w") return w;
		return h;
	}

	override Object GetObjectData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!h) return null;
		if (request ~== "boss")
		{
			if (objectArg) { let b = BossOf(objectArg); return b ? b.mb : null; }
			return (intArg >= 0 && intArg < h.bosses.Size() && h.bosses[intArg]) ? h.bosses[intArg].mb : null;
		}
		if (request ~== "thrall")
		{
			let b = BossOf(objectArg);
			return (b && intArg >= 0 && intArg < b.thr.Size()) ? b.thr[intArg] : null;
		}
		if (request ~== "fight.target") return h.FightTarget(Actor(objectArg));
		return null;
	}
	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetObjectData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override Object GetObjectUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetObjectData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }

	override String GetStringData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// "bigname", stringArg its class: a Big Boss's own name (bigkit.zs), "" if it has none (RSQ VisualRewards' banner)
		if (request ~== "bigname") { let k = RSQMB_BigKit.Lookup(stringArg); return k ? k.Card() : ""; }
		if (!(request ~== "powers")) return "";
		let b = BossOf(objectArg);
		if (!b) return "";
		String s = "";
		for (int i = 0; i < b.powers.Size(); i++) s = s .. (i ? "," : "") .. b.powers[i];
		return s;
	}
	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetStringData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override String GetStringUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetStringData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
}
