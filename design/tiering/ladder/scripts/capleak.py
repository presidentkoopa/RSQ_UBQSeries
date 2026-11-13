import sys, json
sys.path.insert(0,'/tmp/econ3/ladder/scripts')
from spawnmix import final_dist, tier_of_class, FAMS, COLS
import sim
res={}
for cap in range(1,14):
    above=[]; boss=[]
    for f in range(17):
        P,leak=final_dist(f, dict(sim.CV_DEFAULTS), cap)
        a=0;b=0
        for k,p in P.items():
            t=tier_of_class(k); t=int(t[2:]) if isinstance(t,str) else t
            if t>cap: a+=p
            if t>=12: b+=p
        above.append(a); boss.append(b)
    res[cap]={'mean_share_above_cap':sum(above)/17,'max_share_above_cap':max(above),'max_family':FAMS[above.index(max(above))],'mean_boss_share':sum(boss)/17}
    print(cap, COLS[cap-1], f"above cap: mean {res[cap]['mean_share_above_cap']*100:.2f}% max {res[cap]['max_share_above_cap']*100:.2f}% ({res[cap]['max_family']}); Black/White/EX share {res[cap]['mean_boss_share']*100:.3f}%")
json.dump(res,open('/tmp/econ3/ladder/cap_leak.json','w'),indent=1)
