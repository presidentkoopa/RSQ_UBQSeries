// wr_q_bonsai.zs -- RSQ Wheel: what Gun Bonsai knows about a gun (its level and its upgrades).
//
// Asked BY NAME, never linked: RSQ Gun Bonsai VR (the off-hand support addon for ToxicFrog's Gun
// Bonsai) answers as the service "RSQGB_Service" (its rsq/zscript/service.zs documents every
// request). With Gun Bonsai or the addon absent there is no service and every call below answers
// "nothing": Level -1, no upgrades. Nothing here names a Gun Bonsai class, so the Wheel compiles
// and runs the same with or without it.
//
// One question per weapon per tic: the answers are cached for the tic they were asked in, so the
// ring's sheet, the inspect card and the gun card can all ask without asking Gun Bonsai twice.
//
// The API (play scope):
//   WR_Bonsai.Present()                        true when the service is loaded
//   WR_Bonsai.Level(pmo, w)                    the gun's Gun Bonsai level, -1 = no record / not loaded
//   WR_Bonsai.Progress(pmo, w)                 toward the next level, 0..1000 (thousandths)
//   WR_Bonsai.Upgrades(pmo, w, names, levels)  its upgrades in Gun Bonsai's order; returns how many
//   WR_Bonsai.UpgradesFull(pmo, w, names, levels, maxes, classes, on)   the same, every field
//   WR_Bonsai.Numeral(n)                       1 -> "I", 2 -> "II" ... 10 -> "X", past that "LV n"
// pmo may be null; w is the weapon (either hand, or one in the backpack). With w null, pmo's main
// hand is used.
//
// An older addon build without RSQGB_Service still answers the level through
// RSQ_MeleeUpgradeService ("weapon.level" / "weapon.xp"); it has no upgrade list.

class WR_Bonsai play
{
	const STATNUM = Thinker.STAT_USER + 37;

	static Service Svc(String name)
	{
		let it = ServiceIterator.Find(name);
		return it.Next();
	}

	static bool Present() { return Svc("RSQGB_Service") != null || Svc("RSQ_MeleeUpgradeService") != null; }

	// The cached record for w this tic (asked of the service on the first call in a tic).
	static WR_BonsaiEntry Entry(PlayerPawn pmo, Weapon w)
	{
		if (!w && pmo && pmo.player) w = pmo.player.ReadyWeapon;
		if (!w) return null;
		let c = WR_BonsaiCache.Get();
		if (c.tic != level.maptime) { c.entries.Clear(); c.tic = level.maptime; }
		for (int i = 0; i < c.entries.Size(); ++i)
			if (c.entries[i].w == w) return c.entries[i];

		let e = new("WR_BonsaiEntry");
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

	static int Level(PlayerPawn pmo, Weapon w)
	{
		let e = Entry(pmo, w);
		return e ? e.lvl : -1;
	}

	static int Progress(PlayerPawn pmo, Weapon w)
	{
		let e = Entry(pmo, w);
		return (e && e.lvl >= 0) ? e.permille : 0;
	}

	static int Upgrades(PlayerPawn pmo, Weapon w, out Array<String> names, out Array<int> levels)
	{
		names.Clear(); levels.Clear();
		let e = Entry(pmo, w);
		if (!e) return 0;
		names.Copy(e.names);
		levels.Copy(e.levels);
		return names.Size();
	}

	static int UpgradesFull(PlayerPawn pmo, Weapon w, out Array<String> names, out Array<int> levels,
	                        out Array<int> maxes, out Array<String> classes, out Array<bool> on)
	{
		names.Clear(); levels.Clear(); maxes.Clear(); classes.Clear(); on.Clear();
		let e = Entry(pmo, w);
		if (!e) return 0;
		names.Copy(e.names); levels.Copy(e.levels); maxes.Copy(e.maxes);
		classes.Copy(e.classes); on.Copy(e.on);
		return names.Size();
	}

	static String Numeral(int n)
	{
		static const String R[] = { "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" };
		if (n >= 1 && n <= 10) return R[n];
		return String.Format("LV %d", n);
	}
}

class WR_BonsaiEntry play
{
	Weapon w;
	int lvl, permille;
	Array<String> names, classes;
	Array<int> levels, maxes;
	Array<bool> on;

	// "Name:level:max:Class:on|..." (RSQGB_Service "upgrades")
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
			maxes.Push(f.Size() > 2 ? f[2].ToInt() : 0);
			classes.Push(f.Size() > 3 ? f[3] : "");
			on.Push(f.Size() > 4 ? f[4] != "0" : true);
		}
	}
}

// Holds this tic's answers. One per level, found by its own stat list.
class WR_BonsaiCache : Thinker
{
	int tic;
	Array<WR_BonsaiEntry> entries;

	static WR_BonsaiCache Get()
	{
		let it = ThinkerIterator.Create("WR_BonsaiCache", WR_Bonsai.STATNUM);
		let c = WR_BonsaiCache(it.Next());
		if (!c)
		{
			c = new("WR_BonsaiCache");
			c.ChangeStatNum(WR_Bonsai.STATNUM);
			c.tic = -1;
		}
		return c;
	}
}
