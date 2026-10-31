// RSQGB_Service -- what Gun Bonsai knows about one gun, for any mod that asks by name.
//
// No mod needs Gun Bonsai to compile against this: find it with
//     let it = ServiceIterator.Find("RSQGB_Service"); let svc = it.Next();
// and with Gun Bonsai or this patch absent there is no such service and nothing to read.
// Everything here only READS Gun Bonsai's own records (TFLV_PerPlayerStats, TFLV_WeaponInfo, its
// upgrade bags); Gun Bonsai itself is not changed.
//
// WHICH GUN. objectArg is either
//   - the Weapon itself (either hand, a gun in the backpack, or one dropped on the floor that a
//     player's Gun Bonsai record still names): its own record, or
//   - the PlayerPawn, with intArg = 0 for the main hand, 1 for the off hand: that hand's live record.
// A gun with no record (never held yet, or held for less than a tic) answers as "none".
//
// REQUESTS (GetInt / GetString, play scope; the same names through GetIntData / GetStringData)
//   GetInt "loaded"       1. (The service exists only while this patch is loaded.)
//   GetInt "level"        the gun's Gun Bonsai level (0 before its first level-up); -1 = no record
//   GetInt "xp"           XP earned toward the next level (whole points); -1 = no record
//   GetInt "xp.next"      XP the next level costs (Gun Bonsai's maxXP); -1 = no record
//   GetInt "xp.permille"  xp / xp.next in thousandths, 0..1000; -1 = no record
//   GetInt "count"        how many upgrades the gun has; -1 = no record
//   GetInt "hand"         0 main hand, 1 off hand, -1 neither (objectArg = the Weapon)
//   GetString "upgrades"  the gun's upgrades in Gun Bonsai's own order (the order it shows them):
//                           "Name:level:max:Class:on:Colour|Name:level:max:Class:on:Colour|..."
//                         Name   the display name Gun Bonsai shows (its LANGUAGE "<Class>_Name",
//                                localised), without its colour code; any ':' or '|' in it becomes '/'
//                         Colour the colour code Gun Bonsai's name carries, "" for none: an
//                                elemental upgrade's "\c[ORANGE]" gives ORANGE, "\cD" gives D
//                         level  its current level;  max  the most it can reach
//                         Class  the upgrade's class name (TFLV_Upgrade_Explosive, RSQ_Upgrade_...)
//                         on     1, or 0 when the player switched it off in Gun Bonsai's status menu
//                         "" when the gun has no upgrades or no record.
//   GetString "name"      Gun Bonsai's name for the gun (its tag); "" = no record
//
// Example: a Shotgun at level 2 with Explosive Shots II and Fire I:
//   level 2, xp 140, xp.next 900, count 2,
//   upgrades "HE Shots:2:5:TFLV_Upgrade_ExplosiveShots:1:|Searing Inscription:1:5:TFLV_Upgrade_IncendiaryShots:1:ORANGE"
// (names come from Gun Bonsai's LANGUAGE; max levels from each upgrade's own max_level).
class RSQGB_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return RSQGB_Read.IntOf(request, intArg, objectArg); }

	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return RSQGB_Read.StrOf(request, intArg, objectArg); }

	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return RSQGB_Read.IntOf(request, intArg, objectArg); }

	override String GetStringData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return RSQGB_Read.StrOf(request, intArg, objectArg); }
}

// Read-only, field reads only (no Gun Bonsai method is called), so it is safe from any scope.
class RSQGB_Read
{
	static clearscope TFLV_PerPlayerStats StatsOf(Actor pawn)
	{
		if (!pawn || !pawn.player) return null;
		let h = TFLV_EventHandler(StaticEventHandler.Find("TFLV_EventHandler"));
		if (!h) return null;
		for (int p = 0; p < MAXPLAYERS; ++p)
		{
			if (playeringame[p] && players[p].mo == pawn) return h.playerstats[p];
		}
		return null;
	}

	static clearscope TFLV_WeaponInfo FindIn(TFLV_PerPlayerStats stats, Weapon w)
	{
		if (!stats) return null;
		for (int i = 0; i < stats.weapons.Size(); ++i)
		{
			let info = stats.weapons[i];
			if (info && info.wpn == w) return info;
		}
		return null;
	}

	// The record for objectArg (see the header). Hand records are checked against what the hand
	// really holds, as Gun Bonsai's own GetInfoForHand does.
	static clearscope TFLV_WeaponInfo InfoOf(Object o, int hand)
	{
		let w = Weapon(o);
		if (w)
		{
			// Owned: the owner's records. On the floor (dropped): whichever player's record still
			// names this very weapon -- Gun Bonsai keeps it bound until the gun is picked up again.
			if (w.owner) return FindIn(StatsOf(w.owner), w);
			let h = TFLV_EventHandler(StaticEventHandler.Find("TFLV_EventHandler"));
			if (!h) return null;
			for (int p = 0; p < MAXPLAYERS; ++p)
			{
				let info = FindIn(h.playerstats[p], w);
				if (info) return info;
			}
			return null;
		}
		let pawn = Actor(o);
		if (!pawn || !pawn.player) return null;
		let stats = StatsOf(pawn);
		if (!stats) return null;
		Weapon held = (hand == 1) ? pawn.player.OffhandWeapon : pawn.player.ReadyWeapon;
		let info = (hand == 1) ? stats.infoForOffhandWeapon : stats.infoForCurrentWeapon;
		if (held && info && info.wpn == held) return info;
		return null;
	}

	static clearscope int IntOf(String request, int hand, Object o)
	{
		if (request == "loaded") return 1;
		if (request == "hand")
		{
			let w = Weapon(o);
			if (!w || !w.owner || !w.owner.player) return -1;
			if (w.owner.player.ReadyWeapon == w) return 0;
			if (w.owner.player.OffhandWeapon == w) return 1;
			return -1;
		}
		let info = InfoOf(o, hand);
		if (!info) return -1;
		if (request == "level") return int(info.level);
		if (request == "xp") return int(info.XP);
		if (request == "xp.next") return int(info.maxXP);
		if (request == "xp.permille") return info.maxXP > 0 ? clamp(int(1000.0 * info.XP / info.maxXP), 0, 1000) : 0;
		if (request == "count") return info.upgrades ? info.upgrades.upgrades.Size() : 0;
		return 0;
	}

	// The name without Gun Bonsai's colour codes (TEXTCOLOR_ESCAPE, then one letter or [Name]),
	// and the first code's colour.
	static clearscope String, String Clean(String s)
	{
		String res = "", col = "";
		int n = s.Length();
		for (int i = 0; i < n; ++i)
		{
			int c = s.ByteAt(i);
			if (c == 0x1C && i + 1 < n)
			{
				String code;
				if (s.ByteAt(i + 1) == 0x5B)   // '['
				{
					int close = s.IndexOf("]", i + 2);
					if (close < 0) close = n - 1;
					code = s.Mid(i + 2, close - i - 2);
					i = close;
				}
				else { code = s.Mid(i + 1, 1); ++i; }
				if (col.Length() == 0) col = code;
				continue;
			}
			res = res .. s.Mid(i, 1);
		}
		res.Replace(":", "/"); res.Replace("|", "/");
		col.Replace(":", "/"); col.Replace("|", "/");
		return res, col;
	}

	static clearscope String StrOf(String request, int hand, Object o)
	{
		let info = InfoOf(o, hand);
		if (!info) return "";
		if (request == "name") return info.wpn ? info.wpn.GetTag() : "";
		if (request != "upgrades" || !info.upgrades) return "";
		String res = "";
		for (int i = 0; i < info.upgrades.upgrades.Size(); ++i)
		{
			let u = info.upgrades.upgrades[i];
			if (!u) continue;
			String cls = u.GetClassName();
			String nm, col;
			[nm, col] = Clean(StringTable.Localize("$" .. cls .. "_Name"));
			if (res.Length()) res = res .. "|";
			res = res .. String.Format("%s:%d:%d:%s:%d:%s", nm, u.level, u.max_level, cls, u.enabled ? 1 : 0, col);
		}
		return res;
	}
}
