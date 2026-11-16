// RSQ Miniboss's Big Boss pool (Miniboss/zscript/rsqmb/bigboss.zs ExPoolBuild), asked to print itself
class RSPG_BB play
{
	static void Pool()
	{
		let h = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!h) { Console.Printf("RSPG no RSQMB_Handler"); return; }
		h.debug = true; h.exPoolMap = 0; h.ExPoolBuild();
	}
}
