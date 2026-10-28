// THE GRAPPLING HOOK'S UPGRADE PATH (RSQ_Grapple). PLAYER perks, like the grab's: the hook fires
// from either hand and is no weapon, so what it earns goes to the player pool and what it learns
// sits in the player bag, offered when the PLAYER levels and only while RSQ_Grapple is loaded.
//
// Gun Bonsai is Rebecca "ToxicFrog" Kelly's (MIT); this path is presidentkoopa's (same terms).
//
// WHO DOES THE WORK. The grapple asks this patch for each level by name (RSQ_MeleeUpgradeService
// "plevel", RSQGR_Perks in its perks.zs) and does the effect itself; the stagger it asks back for
// is this patch's own (RSQ_MeleeUpgradeService "stagger": RSQ_Dazed, so Executioner sees it).
// This file only defines what Gun Bonsai offers, stores and shows -- and pays the hook's XP.
//
// No elemental damage, nothing that is rate of fire; every upgrade grows a number the hook already
// has or rewards something the player already does with it. Nothing names a monster class.

class RSQ_HookPerk : RSQ_Perk
{
	override bool ModLoaded() { return RSQM.Has("RSQGR_Service") && RSQM.Has("RSQGR_Perks"); }
}

// LONG LINE: the claw flies 20% further a level.
class RSQ_Upgrade_LongLine : RSQ_HookPerk
{
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("r", AsPercentIncrease(1.0 + 0.20 * level));
		fields.Insert("m", AsMeters(int(RSQM.SV("rsqgr_range", 1024) * (1.0 + 0.20 * level))));
	}
}

// FAST REEL: reeling in, the claw's flight and a hooked monster's slide, 15% faster a level.
class RSQ_Upgrade_FastReel : RSQ_HookPerk
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsPercentIncrease(1.0 + 0.15 * level)); }
}

// HEAVY HAUL: heavier and bigger things come to you; a boss on the line staggers.
class RSQ_Upgrade_HeavyHaul : RSQ_HookPerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("kg", AsPercentIncrease(1.0 + 0.50 * level));
		fields.Insert("size", AsPercentIncrease(1.0 + 0.15 * level));
		fields.Insert("time", AsSeconds(10 + 10 * level));
	}
}

// GET OVER HERE: what the hook brings to you arrives staggered.
class RSQ_Upgrade_GetOverHere : RSQ_HookPerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(20 + 15 * level)); }
}

// BOWLING: what the hook brings to you strikes what is in its way, knocks it aside and comes on.
class RSQ_Upgrade_Bowling : RSQ_HookPerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("dmg", string.format("%d+", 5 + 5 * level));
		fields.Insert("time", AsSeconds(15 + 10 * level));
	}
}

// BARBED CLAW: the bite hurts, and tearing it out of a living monster hurts more.
class RSQ_Upgrade_BarbedClaw : RSQ_HookPerk
{
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("bite", string.format("%d", 4 + 4 * level));
		fields.Insert("tear", string.format("%d", 6 + 6 * level));
	}
}

// SLINGSHOT: letting go of a swing in the air carries you further.
class RSQ_Upgrade_Slingshot : RSQ_HookPerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsPercentIncrease(1.0 + 0.10 * level)); }
}

// STEADY LINE: hanging with the stick centred, the swing settles fast (a pump still pumps).
class RSQ_Upgrade_SteadyLine : RSQ_HookPerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("x", string.format("x%d", 1 + 3 * level)); }
}

// DOUBLE HOOK: a monster on each hand's hook -- they are slammed into each other. Offered from
// player level 5.
class RSQ_Upgrade_DoubleHook : RSQ_HookPerk
{
	override int Cap() { return 3; }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		return Super.IsSuitableForPlayer(stats) && stats.level >= 5;
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("dmg", string.format("%d", 20 + 15 * level));
		fields.Insert("time", AsSeconds(35 + 15 * level));
	}
}

// ---- THE HOOK'S XP ------------------------------------------------------------------------
// The grapple keeps a running count per player of what its hook did (RSQGR_Service "xp.*", by
// name); each tic the rise since the last look is paid to the player pool (PerPlayerStats.poolXP,
// where a Distance Grab throw's XP goes). The damage the hook itself deals is paid there too, as
// damage (PerPlayerStats.IsSuiteHook: RSQGR_Service "hook.dealing"). So a hooked fight pays:
//   a bite                15      (the claw takes a monster or a heavy anchor)
//   a yank                15 more (the monster is thrown through the air)
//   swinging              1 per metre in the air on a latched rope, up to 40 a latch
//   a kill it was in on   half the monster's spawn health (hooked, thrown, bowled, slammed or
//                         hurt by the hook in the last 3 s; on top of whatever the killing gun earns)
//   a Double Hook slam    40
//   x rsq_hook_xp (1.0). Every bonsai_base_level_cost (1200) of the pool is one player XP.
// Gun Bonsai's bars are untouched: this is the pool the player bar already fills from.
class RSQ_HookHandler : EventHandler
{
	int seenBites[MAXPLAYERS], seenYanks[MAXPLAYERS], seenSwing[MAXPLAYERS], seenKills[MAXPLAYERS], seenKillHP[MAXPLAYERS], seenSlams[MAXPLAYERS];
	double paid[MAXPLAYERS];   // total paid this map, for the log

	static int Ask(Service s, String req, Actor about)
	{
		return s ? s.GetInt(req, "", 0, 0, about) : -1;
	}

	override void WorldTick()
	{
		let s = RSQM.Svc("RSQGR_Service");
		if (!s) return;
		double k = max(0.0, RSQM.SV("rsq_hook_xp", 1.0));
		bool dbg = RSQM.SVI("rsqgr_debug", 0) > 0;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let pmo = players[pn].mo;
			int b = Ask(s, "xp.bites", pmo);
			if (b < 0) continue;   // a grapple that keeps no ledger
			int y = Ask(s, "xp.yanks", pmo), w = Ask(s, "xp.swing", pmo), kk = Ask(s, "xp.kills", pmo);
			int hp = Ask(s, "xp.killhp", pmo), sl = Ask(s, "xp.slams", pmo);
			// a count below what was seen is a new ledger (a new map came up first on its side)
			if (b < seenBites[pn] || y < seenYanks[pn] || w < seenSwing[pn] || kk < seenKills[pn] || sl < seenSlams[pn])
			{
				seenBites[pn] = 0; seenYanks[pn] = 0; seenSwing[pn] = 0; seenKills[pn] = 0; seenKillHP[pn] = 0; seenSlams[pn] = 0;
			}
			// swing is paid in whole metres (32 units); the remainder waits for the next
			int metres = (w - seenSwing[pn]) / 32;
			int wPaid = seenSwing[pn] + metres * 32;
			double xp = 15.0 * (b - seenBites[pn]) + 15.0 * (y - seenYanks[pn]) + metres
				+ 0.5 * (hp - seenKillHP[pn]) + 40.0 * (sl - seenSlams[pn]);
			let stats = TFLV_PerPlayerStats.GetStatsFor(pmo);
			// XP Source Style (rsq/zscript/stylexp.zs): the hook's share of each kill's style is its XP;
			// what it did is still counted here, so turning Style off later pays nothing old
			if (xp <= 0 || !stats || TFLV_PerPlayerStats.RSQ_XPSource() == 1)
			{
				seenBites[pn] = b; seenYanks[pn] = y; seenSwing[pn] = wPaid; seenKills[pn] = kk; seenKillHP[pn] = hp; seenSlams[pn] = sl;
				continue;
			}
			stats.AddPoolXP(xp * k);
			paid[pn] += xp * k;
			if (dbg)
				Console.Printf("T_GBH t%d p%d hook xp +%.1f (bites +%d yanks +%d swing +%d kills +%d hp +%d slams +%d) paid %.1f pool %.1f/%d player xp %d lv %d",
					level.maptime, pn, xp * k, b - seenBites[pn], y - seenYanks[pn], wPaid - seenSwing[pn], kk - seenKills[pn], hp - seenKillHP[pn], sl - seenSlams[pn],
					paid[pn], stats.poolXP, bonsai_base_level_cost, stats.XP, stats.level);
			seenBites[pn] = b; seenYanks[pn] = y; seenSwing[pn] = wPaid; seenKills[pn] = kk; seenKillHP[pn] = hp; seenSlams[pn] = sl;
		}
	}
}
