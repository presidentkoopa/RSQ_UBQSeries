// ============================================================================
// RS_Diagnostics.zs -- what answers RSQ Monsters' Test and Debug page (Monster Diagnostics).
// (Monster Assembly, 2026-11-16. Before this the page's buttons sent netevents nothing in the pk3 answered.)
//
// The page lists the Chaingunner family, the first family ported from Colourful Hell, under the page's own roster
// codes (Monsters/docs/MONSTER_DIAGNOSTICS.md):
//   C0001          the Common form
//   T0001..T0010   the ten coloured forms: Green 1, Blue 2, Cyan 3, Purple 4, Yellow 5, Brown 6, Gray 7, Abyss 8,
//                  FireBlu 9, Red 10 (the page's own order, not the strength ladder's numbers)
//   B0001, B0002   the Black and White bosses
//   X0001          the EX boss
// Button N (netevent rs_cg_spawn N) is the row's place on the page, 0..13.
//
//   netevent rs_cg_spawn N   one of them, 160 units in front of you, facing you
//   netevent rs_cg_line      all fourteen in a line
//   netevent rs_cg_clear     removes every monster these buttons spawned
//   netevent rs_cg_diag      the console: each one's LIVE class, name, health, ladder tier and code
//   netevent rs_cg_wake      wakes them and sets you as their target
// rs_mon_dbg_hostile 0 (the default): a spawned one stands dormant until WAKE; 1: it acts at once.
// Single player test tools: play code from network events, so every machine does the same.
// ============================================================================

class RS_DiagMark : Inventory
{
	int row;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}

class RS_DiagHandler : EventHandler
{
	// the page's rows, in order: the ladder tier each row is (RS_TierLadder.ClassFor, family 0 = Chaingunner), 0 = EX
	const ROWS = 14;
	static int RowTier(int row)
	{
		static const int T[] = { 1, 2, 3, 4, 7, 10, 5, 9, 6, 11, 8, 12, 13, 0 };
		return (row >= 0 && row < ROWS) ? T[row] : -1;
	}
	static String RowCode(int row)
	{
		static const String C[] = { "C0001", "T0001", "T0002", "T0004", "T0005", "T0010", "T0003", "T0007",
		                            "T0006", "T0008", "T0009", "B0001", "B0002", "X0001" };
		return (row >= 0 && row < ROWS) ? C[row] : "?";
	}

	static Name RowClass(int row)
	{
		if (row < 0 || row >= ROWS) return 'None';
		int t = RowTier(row);
		return t > 0 ? RS_TierLadder.ClassFor(0, t) : 'RS_BlackCGuyEX';
	}

	static Actor SpawnRow(PlayerPawn pmo, int row, double side)
	{
		if (!pmo) return null;
		Name n = RowClass(row);
		class<Actor> cls = n;
		if (!cls) { Console.Printf("RSDIAG row %d: no class %s", row, n); return null; }
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

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let pmo = players[e.Player].mo;
		if (!pmo) return;
		if (e.Name ~== "rs_cg_spawn") SpawnRow(pmo, e.Args[0], 0);
		else if (e.Name ~== "rs_cg_line")
		{
			for (int r = 0; r < ROWS; r++) SpawnRow(pmo, r, (r - (ROWS - 1) * 0.5) * 72);
		}
		else if (e.Name ~== "rs_cg_clear" || e.Name ~== "rs_cg_diag" || e.Name ~== "rs_cg_wake")
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
				if (e.Name ~== "rs_cg_clear") { a.ClearCounters(); a.Destroy(); n++; continue; }
				if (e.Name ~== "rs_cg_wake")
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
