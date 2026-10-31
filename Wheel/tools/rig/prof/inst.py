# TEST ONLY: times wr_Rig / wr_BB WorldTick sections (WRI line) in a COPY of the source: python3 inst.py <copy>/zscript/wheel,
# then add "wr_InstD" to the copy's MAPINFO AddEventHandlers. Used for the 2026-10-31 apply/07 8.1 measurement.
import sys
d=sys.argv[1]
s=open(d+'/zscript.zs').read()
def R(a,b):
    global s
    assert a in s, a[:60]
    s=s.replace(a,b,1)
R('''		repaintFaces(pmo);

		// Same reason''','''		double _t0 = MSTimeF();
		repaintFaces(pmo);
		double _t1 = MSTimeF(); wr_Inst.Add(0, _t1 - _t0);

		// Same reason''')
R('''		refreshSheet(pmo);
''','''		refreshSheet(pmo);
		double _t2 = MSTimeF(); wr_Inst.Add(1, _t2 - _t1);
''')
R('''		layout(pmo);

		// CURSOR GAIN.''','''		layout(pmo);
		double _t3 = MSTimeF(); wr_Inst.Add(2, _t3 - _t2); wr_Inst.Mark(_t3);

		// CURSOR GAIN.''')
R('''	override void WorldTick()
	{

		if (mWantAutoOpen)''','''	override void WorldTick()
	{
		double _ta = MSTimeF();
		WorldTick_();
		if (mOpen) { wr_Inst.Add(3, MSTimeF() - wr_Inst.MarkT()); wr_Inst.Add(4, MSTimeF() - _ta); wr_Inst.Tic(); }
	}
	void WorldTick_()
	{

		if (mWantAutoOpen)''')
s+='''
class wr_Inst play
{
	static wr_InstD D() { let d = wr_InstD(StaticEventHandler.Find("wr_InstD")); return d; }
	static void Add(int k, double v) { let d = D(); if (d) d.sum[k] += v; }
	static void Mark(double v) { let d = D(); if (d) d.mark = v; }
	static double MarkT() { let d = D(); return d ? d.mark : 0; }
	static void Tic() { let d = D(); if (!d) return; d.n++; if (d.n == 200) Console.Printf("WRI n200 repaint %.3f sheet %.3f layout %.3f pointing %.3f rigtotal %.3f bb %.3f", d.sum[0]/200, d.sum[1]/200, d.sum[2]/200, d.sum[3]/200, d.sum[4]/200, d.sum[5]/200); }
}
class wr_InstD : StaticEventHandler { double sum[6]; double mark; int n; }
'''
open(d+'/zscript.zs','w').write(s)
t=open(d+'/wr_q_shim.zs').read()
a='''		let pp = players[consoleplayer];
		if (!pp.mo) return;
		Vector3 eye = (pp.mo.pos.xy, pp.viewz);
'''
assert a in t
t=t.replace(a,'''		double _tb = MSTimeF();
		WorldTickBB();
		if (wr_Rig.Get() && wr_Rig.Get().IsOpen()) wr_Inst.Add(5, MSTimeF() - _tb);
	}
	void WorldTickBB()
	{
		let pp = players[consoleplayer];
		if (!pp.mo) return;
		Vector3 eye = (pp.mo.pos.xy, pp.viewz);
''',1)
open(d+'/wr_q_shim.zs','w').write(t)
