// TEST ONLY (never ships): darkens the map (netevent ffp_dark <light>), reports the flares (netevent ffp_rep),
// and logs the flares' flight each tic while ffp_trace is on (netevent ffp_trace <tics>).
class FFP_Probe : EventHandler
{
	int traceLeft;
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "ffp_dark") { for (int i = 0; i < level.sectors.Size(); i++) level.sectors[i].SetLightLevel(e.Args[0]); Console.Printf("FFP dark %d", e.Args[0]); }
		if (e.Name == "ffp_trace") traceLeft = e.Args[0];
		if (e.Name == "ffp_rep") Rep();
		if (e.Name == "ffp_give") { players[e.Player].mo.SetInventory("RSQFF_Ammo", e.Args[0]); }
	}
	void Rep()
	{
		let it = ThinkerIterator.Create("RSQFF_Burner");
		RSQFF_Burner b; int n = 0, on = 0;
		while (b = RSQFF_Burner(it.Next()))
		{
			n++; if (b.lightOn) on++;
			Console.Printf("FFP flare %s at (%.0f %.0f %.0f) pitch %.0f burnLeft %d dark %d light %d spent %d", b.GetClassName(), b.pos.x, b.pos.y, b.pos.z, b.pitch, b.burnLeft, b.dark, b.lightOn, b.spent);
		}
		let p = players[consoleplayer];
		for (let ps = p.psprites; ps; ps = ps.Next)
			Console.Printf("FFP psp %d caller %s frame %d alpha %.2f state %s", ps.ID, ps.Caller ? ps.Caller.GetClassName() : 'none', ps.Frame, ps.Alpha, ps.CurState ? "set" : "null");
		Console.Printf("FFP t%d: %d burners, %d lights on; stabilised %d; pocket %d; off hand %s", level.maptime, n, on, (p.WeaponState & WF_TWOHANDSTABILIZED) != 0, p.mo.CountInv("RSQFF_Ammo"), p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
	}
	override void WorldTick()
	{
		if (traceLeft <= 0) return;
		traceLeft--;
		let it = ThinkerIterator.Create("RSQFF_Flare");
		RSQFF_Flare f;
		while (f = RSQFF_Flare(it.Next())) Console.Printf("FFP fly t%d (%.1f %.1f %.1f) v (%.2f %.2f %.2f) pitch %.0f missile %d", level.maptime, f.pos.x, f.pos.y, f.pos.z, f.vel.x, f.vel.y, f.vel.z, f.pitch, f.bMissile);
	}
}
