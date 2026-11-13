import sys; sys.path.insert(0,'/tmp/econ3/ladder/scripts')
import sim, time
sim.load('/tmp/econ3/ladder/scripts/rsq_classes.pkl')
for n in sys.argv[1:]:
    t0=time.time()
    for d in (256,512):
        r=sim.simulate(n,d,runs=20)
        T=r.t/35
        print(f"{n:18} d={d} dps={r.dmg/T:6.1f} att/s={r.attacks/T:5.2f} chase%={r.chase_t/r.t*100:4.0f} summ={ {k:round(v/T*20,2) for k,v in r.summ.items()} } heal_o/s={r.heal_others/T:.1f} invul%={r.invul_t/r.t*100:.0f} by={ {k:round(v/T,1) for k,v in sorted(r.dmg_by.items(),key=lambda x:-x[1])[:4]} } tags={sorted(r.tags)[:6]} {time.time()-t0:.1f}s")
