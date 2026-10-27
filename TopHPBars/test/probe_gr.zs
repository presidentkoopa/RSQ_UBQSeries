// TEST ONLY, with RSQ_Grapple loaded: throw a row monster with the grapple's own yank
// (RSQGR_Flight.Launch -- its real path, tumble and landing stun) at tic thpt_yank.
class RSQTHPT_Yank : EventHandler
{
	override void WorldTick()
	{
		let c = CVar.FindCVar('thpt_yank');
		if (!c || c.GetInt() != level.maptime) return;
		let p = RSQTHPT_Probe.Get();
		let fl = RSQGR_Flight.Get();
		let pmo = players[consoleplayer].mo;
		int i = CVar.FindCVar('thpt_yankidx').GetInt();
		if (!p || !fl || !pmo || i < 0 || i >= p.row.Size() || !p.row[i]) { Console.Printf("THPT_YANK none"); return; }
		let a = p.row[i];
		a.Activate(null);
		bool ok = fl.Launch(a, PlayerPawn(pmo), 0);
		Console.Printf("THPT_YANK %d %s launched %d", i, a.GetClassName(), ok);
	}
}
