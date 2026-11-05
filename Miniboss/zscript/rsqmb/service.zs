// ============================================================================
// RSQMB_Service -- for other mods, found by name (nothing links):
//   ServiceIterator.Find("RSQMB_Service").Next().GetInt("miniboss", "", 0, 0, monster)
// objectArg = the monster asked about; requests without one answer for the level. -1: unknown.
//
//   miniboss      1 a living miniboss of this set piece, else 0      (none: how many are alive)
//   thrall        1 a thrall bound to a living miniboss, else 0
//   enraged       1 enraged by the greed rule now, else 0            (none: 1 while any rage runs)
//   lives         lives left, the current one included (miniboss), else 0
//   invulnerable  1 while its lost-life invulnerability lasts
//   shield        damage it takes now, permille (living thralls x inherited toughness; 0 invulnerable)
//   greed         1 while its greed is armed (struck while thralls live; comes due with the window)
//   window        tics left in the slow window (no object needed)
//   living        its living thralls (miniboss or thrall: the set piece it belongs to)
//   legendary     1 if it inherited legendary status
//   colour        its set piece's colour, 0xRRGGBB (miniboss or thrall, dead or alive): the colour its own tethers,
//                 life orbs and bursts are drawn in (handler.zs PALETTE, one per miniboss in order); else -1
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
//                   "rewards.x" Bossfight bits (rsqmb_bf_bits, 3): how many times MORE Boss Kill Rewards bits this miniboss
//                               is worth (a Bossfight's miniboss, under the same rule as "rewards"); 1 for any other
//                 Cheap first test for callers: the monster carries "RSQMB_Ward" (by name); only then ask.
//   bossfight     BOSSFIGHT (bossfight.zs): 1 when the monster came with a Bossfight (miniboss or thrall, dead or alive,
//                 for good: it carries RSQMB_Called); no object: 1 while a Bossfight is arriving or its miniboss lives
//   tier          the Bossfight's tier 0..4 (bossfight.zs Tier) for a Bossfight's miniboss or thrall (dead or alive);
//                 -1 for anything else (a classic pick, no set piece). RSQ VisualRewards draws it as 1-3 pips by the crown
//   bossfights    1 when Bossfights are on (rsqmb_enabled)
//   meter         the Bossfight meter, permille (objectArg the player; none: the console player's), -1 none yet
//   meter.ready   1 while it is full and waiting
//   callin        1 while the watch check + Use would call this player's Bossfight in (objectArg the player; none: the
//                 console player's): Bossfights on, Call It In on, the meter full and not yet called. THE PRESS IS THE
//                 CALL-IN'S then (owner 11-05: "Calling a Bossfight must never also move the gun"): RSQ Tactical Rig's
//                 watch-check gun move asks this and leaves that Use press alone while it is 1
//   meter.bottom  (ui) the screen pixel row just under the meter's slot while it is shown (RSQ SlowMo's countdown bar
//                 and RSQ Score's combo rows go below it), -1 when it is off
//   meter.x / meter.w / meter.h   (ui, GetDoubleUI; GetIntUI rounds) the meter's BAR in screen pixels while it is shown:
//                 its left edge, width and thickness (the skull is 1.6 x the thickness, 0.3 x it left of the bar); -1 off.
//                 RSQ SlowMo's countdown row under it takes these (owner 11-05: the meter and the countdown always line
//                 up, whatever Meter Size and Bar Size are set to: same icon size, same bar left edge and width)
// GetObject("boss", "", 0, 0, thrall) -> the thrall's miniboss; ("boss", "", n) -> the n-th miniboss.
// GetObject("thrall", "", n, 0, miniboss) -> its n-th thrall (dead or alive), null past the end.
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
		if (request ~== "enraged")
		{
			if (a) return (a.FindInventory("RSQMB_Rage") && a.health > 0) ? 1 : 0;
			return h.rageCount > 0 ? 1 : 0;
		}
		if (request ~== "window") return max(0, h.windowEnd - level.maptime);
		if (request ~== "lives") return isBoss ? b.lives : 0;
		if (request ~== "invulnerable") return (isBoss && b.Invulnerable()) ? 1 : 0;
		if (request ~== "shield") return isBoss ? (b.Invulnerable() ? 0 : int(b.TakeFactorData() * 1000)) : 1000;
		if (request ~== "greed") return (isBoss && b.greedArmed) ? 1 : 0;
		if (request ~== "living") return (b && !b.done) ? b.Living() : 0;
		if (request ~== "legendary") return (isBoss && b.legendary) ? 1 : 0;
		if (request ~== "colour" || request ~== "color") return b ? (int(b.col) & 0xFFFFFF) : -1;
		if (request ~== "bossfight")
		{
			if (a) return a.FindInventory("RSQMB_Called") ? 1 : 0;
			return (h.arrPhase || (h.bfBoss && !h.bfBoss.done)) ? 1 : 0;
		}
		if (request ~== "tier") return (b && b.called) ? b.tier : -1;
		if (request ~== "bossfights") return RSQMB_Handler.BfOn() ? 1 : 0;
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
			if (stringArg ~== "rewards.x")
				return (b.called && RSQMB_Handler.CI('rsqmb_boss_rewards', 1) && (!b.done || level.maptime - b.diedAt <= 1)) ? max(1, RSQMB_Handler.CI('rsqmb_bf_bits', 3)) : 1;
			if (stringArg ~== "rewards") return (RSQMB_Handler.CI('rsqmb_boss_rewards', 1) && (!b.done || level.maptime - b.diedAt <= 1)) ? 1 : 0;
			if (stringArg ~== "yank") return (RSQMB_Handler.CI('rsqmb_boss_noyank', 1) && isBoss) ? 1 : 0;
			if (stringArg ~== "headlock") return (RSQMB_Handler.CI('rsqmb_boss_noheadlock', 1) && isBoss) ? 1 : 0;
			if (stringArg ~== "ldhealth") return b.ldBoss ? 1 : 0;     // a fact about how its health was set: the switch decided it then
			return 0;
		}
		return -1;
	}
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
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
	// the bar's rect (hud.zs MeterRect) while the meter is shown, else -1
	static ui double MeterBar(String request)
	{
		if (gamestate != GS_LEVEL || !RSQMB_Handler.MeterShown()) return -1;
		double x, y, w, h;
		[x, y, w, h] = RSQMB_Handler.MeterRect();
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
		return null;
	}
	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetObjectData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override Object GetObjectUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetObjectData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }

	override String GetStringData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
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
