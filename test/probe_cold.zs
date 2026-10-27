// TEST ONLY: coldcite's 1.04 cost, measured the same way as ours (THPT_BENCH). Loaded with his
// unmodified pk3 (test/build_cold.sh) -- never shipped.
class RSQTHPT_ColdBench : EventHandler
{
	override void WorldTick()
	{
		let c = CVar.FindCVar('thpt_bench');
		if (!c || c.GetInt() != level.maptime) return;
		Array<Z_TopHP> bars;
		Array<Z_MyTopHP> items;
		let it = ThinkerIterator.Create("Z_TopHP");
		Z_TopHP b;
		while (b = Z_TopHP(it.Next())) bars.Push(b);
		let it2 = ThinkerIterator.Create("Z_MyTopHP", Thinker.STAT_INVENTORY);
		Z_MyTopHP m;
		while (m = Z_MyTopHP(it2.Next())) items.Push(m);
		int N = 2000;
		double t0 = MSTimeF();
		for (int r = 0; r < N; r++) for (int i = 0; i < bars.Size(); i++) if (bars[i]) bars[i].Tick();
		double t1 = MSTimeF();
		for (int r = 0; r < N; r++) for (int i = 0; i < items.Size(); i++) if (items[i]) items[i].Tick();
		double t2 = MSTimeF();
		Console.Printf("THPT_COLDBENCH bars %d items %d | bar %.3f us/bar-tic | item %.3f us/monster-tic",
			bars.Size(), items.Size(), (t1 - t0) * 1000.0 / (N * max(1, bars.Size())), (t2 - t1) * 1000.0 / (N * max(1, items.Size())));
	}
}
