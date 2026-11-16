// ============================================================================
// RS_Diagnostics.zs -- what answers RSQ Monsters' Test and Debug page (Monster Diagnostics).
// (Monster Assembly, 2026-11-16; any family since the menu was built, owner 09:58 "Build it as proposed".)
//
// The family is Test and Debug > Family (rsq_mon_dbg_family, RS_TierLadder's family numbers: 0 Chaingunner ...
// 16 Zombieman). Each family is listed under the page's roster codes (docs/MONSTER_DIAGNOSTICS.md):
//   C0001          the Common form
//   T0001..T0010   the ten coloured forms: Green 1, Blue 2, Cyan 3, Purple 4, Yellow 5, Brown 6, Gray 7, Abyss 8,
//                  FireBlu 9, Red 10 (the page's own order, not the strength ladder's numbers)
//   B0001, B0002   the Black and White bosses
//   X0001          the EX boss (ten families have one; the others show the row greyed)
// Row N (0..13) is the row's place on the page.
//
//   netevent rs_diag_spawn N   one of them, 160 units in front of you, facing you
//   netevent rs_diag_line      the whole family in a line
//   netevent rs_diag_clear     removes every monster these rows spawned
//   netevent rs_diag_diag      the console: each one's LIVE class, name, health, ladder tier and code
//   netevent rs_diag_wake      wakes them and sets you as their target
// rs_mon_dbg_hostile 0 (the default): a spawned one stands dormant until WAKE; 1: it acts at once.
// Test tools: play code from network events, so every machine does the same.
// ============================================================================

class RS_DiagMark : Inventory
{
	int row;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}

class RS_DiagHandler : EventHandler
{
	const ROWS = 14;

	// the ladder tier each row is; 0 = the EX row
	static clearscope int RowTier(int row)
	{
		static const int T[] = { 1, 2, 3, 4, 7, 10, 5, 9, 6, 11, 8, 12, 13, 0 };
		return (row >= 0 && row < ROWS) ? T[row] : -1;
	}

	static clearscope String RowCode(int row)
	{
		static const String C[] = { "C0001", "T0001", "T0002", "T0004", "T0005", "T0010", "T0003", "T0007",
		                            "T0006", "T0008", "T0009", "B0001", "B0002", "X0001" };
		return (row >= 0 && row < ROWS) ? C[row] : "?";
	}

	static clearscope int Family()
	{
		let cv = CVar.FindCVar('rsq_mon_dbg_family');
		return cv ? clamp(cv.GetInt(), 0, RS_TierLadder.FamilyCount() - 1) : 0;
	}

	// the family's EX form: named after its gate, Black or (the Shotgunner, the Lost Soul) White, as "set.class.ex" finds it
	static clearscope Name EXClass(int fam)
	{
		for (int t = 12; t <= 13; t++)
		{
			String g = RS_TierLadder.GateFor(fam, t);
			String ex = g .. "EX";
			class<Actor> xc = ex;
			if (!xc)
			{
				int n = g.Length();
				while (n > 0 && g.ByteAt(n - 1) >= 48 && g.ByteAt(n - 1) <= 57) n--;
				ex = g.Left(n) .. "EX";
				xc = ex;
			}
			if (xc) return ex;
		}
		return 'None';
	}

	static clearscope Name RowClass(int fam, int row)
	{
		if (row < 0 || row >= ROWS) return 'None';
		int t = RowTier(row);
		return t > 0 ? RS_TierLadder.ClassFor(fam, t) : EXClass(fam);
	}

	static Actor SpawnRow(PlayerPawn pmo, int fam, int row, double side)
	{
		if (!pmo) return null;
		Name n = RowClass(fam, row);
		class<Actor> cls = n;
		if (!cls) { Console.Printf("RSDIAG %s: none in this family", RowCode(row)); return null; }
		Vector3 at = pmo.Vec3Angle(160, pmo.angle) + (Actor.RotateVector((0, side), pmo.angle), 0);
		let mo = Actor.Spawn(cls, at, ALLOW_REPLACE);
		if (!mo) return null;
		mo.angle = pmo.angle + 180;
		let mk = RS_DiagMark(mo.GiveInventoryType('RS_DiagMark'));
		if (mk) mk.row = row;
		let cv = CVar.FindCVar('rs_mon_dbg_hostile');
		if (!(cv && cv.GetBool())) mo.Deactivate(pmo);
		Console.Printf("RSDIAG spawned %s %s (%s)", RowCode(row), mo.GetClassName(), mo.GetTag());
		return mo;
	}

	// A setting saved by an older version with a value the menu no longer lists (the old MeatGrinder 2 and Mixed 3, which
	// the code already reads as ColorfulHell) is written as ColorfulHell once, so its row shows a name and not
	// "Unknown". Nothing plays differently. (Here because this handler is the pack's menu-side one; 11-16.)
	override void WorldLoaded(WorldEvent e)
	{
		Fix('rsq_monster_set', 2, 2, 3);
		Fix('rsq_mon_bf_boss', 2, 3, 1);
		Fix('rsq_mon_bf_thralls', 2, 3, 1);
	}

	static void Fix(Name n, int lo, int hi, int to)
	{
		let c = CVar.FindCVar(n);
		if (c && c.GetInt() >= lo && c.GetInt() <= hi) c.SetInt(to);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let pmo = players[e.Player].mo;
		if (!pmo) return;
		int fam = Family();
		if (e.Name ~== "rs_diag_spawn") SpawnRow(pmo, fam, e.Args[0], 0);
		else if (e.Name ~== "rs_diag_line")
		{
			for (int r = 0; r < ROWS; r++) SpawnRow(pmo, fam, r, (r - (ROWS - 1) * 0.5) * 72);
		}
		else if (e.Name ~== "rs_diag_clear" || e.Name ~== "rs_diag_diag" || e.Name ~== "rs_diag_wake")
		{
			int n = 0;
			Array<Actor> found;
			let it = ThinkerIterator.Create("Actor", Thinker.STAT_DEFAULT);
			Actor a;
			while (a = Actor(it.Next())) if (a.bIsMonster && a.FindInventory('RS_DiagMark')) found.Push(a);
			for (int i = 0; i < found.Size(); i++)
			{
				a = found[i];
				let mk = RS_DiagMark(a.FindInventory('RS_DiagMark'));
				String code = mk ? RowCode(mk.row) : "?";
				if (e.Name ~== "rs_diag_clear") { a.ClearCounters(); a.Destroy(); n++; continue; }
				if (e.Name ~== "rs_diag_wake")
				{
					if (a.health > 0) { a.Activate(pmo); a.target = pmo; if (a.SeeState) a.SetState(a.SeeState); n++; }
					continue;
				}
				Console.Printf("RSDIAG %s %s \"%s\" health %d of %d, ladder tier %d%s%s", code, a.GetClassName(), a.GetTag(),
					a.health, a.GetSpawnHealth(), RS_Retier.TierNowOf(a), a.bDORMANT ? ", dormant" : "",
					a.health <= 0 ? ", dead" : "");
				n++;
			}
			Console.Printf("RSDIAG %s: %d", e.Name, n);
		}
	}
}
