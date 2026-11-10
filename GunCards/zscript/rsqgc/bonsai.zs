// bonsai.zs -- RSQ Gun Cards (a copy of RSQ Wheel's wr_q_bonsai.zs): what Gun Bonsai knows about a gun (its level and its upgrades).
//
// Asked BY NAME, never linked: RSQ Gun Bonsai VR (the off-hand support addon for ToxicFrog's Gun
// Bonsai) answers as the service "RSQGB_Service" (its rsq/zscript/service.zs documents every
// request). With Gun Bonsai or the addon absent there is no service and every call below answers
// "nothing": Level -1, no upgrades. Nothing here names a Gun Bonsai class, so Gun Cards compiles
// and runs the same with or without it.
//
// One question per weapon per tic: the answers are cached for the tic they were asked in, so the
// watch card drawn with the hand, the world watch card and their signatures can all ask without
// asking Gun Bonsai twice.
//
// The API (play scope; only what the cards use, 2026-11-10):
//   RSQGC_Bonsai.Entry(pmo, w)    this tic's record: lvl (-1 = no record / not loaded), permille (toward
//                                 the next level, 0..1000), names / levels / on / colours of its upgrades
//   RSQGC_Bonsai.Numeral(n)       1 -> "I", 2 -> "II" ... 10 -> "X", past that "LV n"
// pmo may be null; w is the weapon (either hand, or one in the backpack). With w null, pmo's main
// hand is used.
//
// An older addon build without RSQGB_Service still answers the level through
// RSQ_MeleeUpgradeService ("weapon.level" / "weapon.xp"); it has no upgrade list.

class RSQGC_Bonsai play
{
	const STATNUM = Thinker.STAT_USER + 38;

	static Service Svc(String name)
	{
		let it = ServiceIterator.Find(name);
		return it.Next();
	}

	// The cached record for w this tic (asked of the service on the first call in a tic).
	static RSQGC_BonsaiEntry Entry(PlayerPawn pmo, Weapon w)
	{
		if (!w && pmo && pmo.player) w = pmo.player.ReadyWeapon;
		if (!w) return null;
		let c = RSQGC_BonsaiCache.Get();
		if (c.tic != level.maptime) { c.entries.Clear(); c.tic = level.maptime; }
		for (int i = 0; i < c.entries.Size(); ++i)
			if (c.entries[i].w == w) return c.entries[i];

		let e = new("RSQGC_BonsaiEntry");
		e.w = w;
		e.lvl = -1;
		let svc = Svc("RSQGB_Service");
		if (svc)
		{
			e.lvl = svc.GetInt("level", "", 0, 0, w);
			if (e.lvl >= 0)
			{
				e.permille = svc.GetInt("xp.permille", "", 0, 0, w);
				e.Parse(svc.GetString("upgrades", "", 0, 0, w));
			}
		}
		else if ((svc = Svc("RSQ_MeleeUpgradeService")) != null)
		{
			e.lvl = svc.GetInt("weapon.level", "", 0, 0, w);
			if (e.lvl >= 0) e.permille = clamp(svc.GetInt("weapon.xp", "", 0, 0, w), 0, 1000);
		}
		c.entries.Push(e);
		return e;
	}

	static String Numeral(int n)
	{
		static const String R[] = { "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" };
		if (n >= 1 && n <= 10) return R[n];
		return String.Format("LV %d", n);
	}
}

class RSQGC_BonsaiEntry play
{
	Weapon w;
	int lvl, permille;
	Array<String> names, colours;   // colours: Gun Bonsai's colour code for the name (ORANGE ...), or ""
	Array<int> levels;
	Array<bool> on;

	// "Name:level:max:Class:on:colour|..." (RSQGB_Service "upgrades"; max and Class are not shown, so not kept)
	void Parse(String s)
	{
		if (s.Length() == 0) return;
		Array<String> items;
		s.Split(items, "|", TOK_SKIPEMPTY);
		for (int i = 0; i < items.Size(); ++i)
		{
			Array<String> f;
			items[i].Split(f, ":");
			if (f.Size() < 2) continue;
			names.Push(f[0]);
			levels.Push(f[1].ToInt());
			on.Push(f.Size() > 4 ? f[4] != "0" : true);
			colours.Push(f.Size() > 5 ? f[5] : "");
		}
	}
}

// Holds this tic's answers. One per level, found by its own stat list.
class RSQGC_BonsaiCache : Thinker
{
	int tic;
	Array<RSQGC_BonsaiEntry> entries;

	static RSQGC_BonsaiCache Get()
	{
		let it = ThinkerIterator.Create("RSQGC_BonsaiCache", RSQGC_Bonsai.STATNUM);
		let c = RSQGC_BonsaiCache(it.Next());
		if (!c)
		{
			c = new("RSQGC_BonsaiCache");
			c.ChangeStatNum(RSQGC_Bonsai.STATNUM);
			c.tic = -1;
		}
		return c;
	}
}
