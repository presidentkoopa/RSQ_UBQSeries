import re,sys,math
# per shot: launch tic (first big dv after the fire), player pos before, claw pos, launch dv, then the arc: peak z, landing tic, |vxy| on landing, final x
L=open(sys.argv[1],errors='replace').read().splitlines()
shot=None; rows={}
for ln in L:
    m=re.match(r'SHOT_(\S+)',ln)
    if m: shot=m.group(1); rows[shot]=[]; continue
    if shot and ln.startswith('V t'): rows[shot].append(ln)
P=re.compile(r'V t(\d+) pos\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) vel\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) dv\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) \|vxy\| ([-\d.]+) km(\d) gnd(\d)(.*)')
for s,rs in rows.items():
    v=[P.match(r).groups() for r in rs if P.match(r)]
    fired=None;launch=None;prev=None
    for i,g in enumerate(v):
        t=int(g[0]); dvx,dvy,dvz=map(float,g[7:10])
        if 'Hook' in g[13] and fired is None: fired=t
        if fired is not None and launch is None and (abs(dvx)+abs(dvy)>1.5 or dvz>0.2 or dvz<-1.2) : launch=i; break
    if launch is None: print(s,'NO LAUNCH',fired); continue
    g=v[launch]; pb=v[launch-1]
    claw=re.findall(r'\(([-\d.]+) ([-\d.]+) ([-\d.]+) st',g[13])
    cx,cy,cz=map(float,claw[-1]) if claw else (0,0,0)
    px,py,pz=map(float,pb[1:4])
    # the OG ACS on these two positions
    d=math.hypot(cx-px,cy-py); fd=int(d); ang=math.degrees(math.atan2(cy-py,cx-px))%360; b=int(ang*256/360)
    zh=math.floor(pz-cz+0.5); arg=int(zh/4); pvz=-(arg/4.0); f=fd//12; th=math.radians(b*360/256)
    peak=max(float(x[3]) for x in v[launch:]); land=None
    for x in v[launch+1:]:
        if x[12]=='1': land=x; break
    fin=v[-1]
    print(f"{s:9s} fire t{fired} launch t{g[0]} (+{int(g[0])-fired}) player({px:.1f},{py:.1f},{pz:.1f}) claw({cx:.1f},{cy:.1f},{cz:.1f}) 2D {d:.1f}"
          f" | dv({float(g[7]):.3f},{float(g[8]):.3f},{float(g[9]):.3f}) |dvxy| {math.hypot(float(g[7]),float(g[8])):.2f}"
          f" | ACS on these: ({f*math.cos(th):.3f},{f*math.sin(th):.3f},{pvz:.3f})"
          f" | km{g[11]} peak z {peak:.1f} land {('t'+land[0]+' |vxy| '+land[10]) if land else '-'} end x {float(fin[1]):.1f} |vxy| {fin[10]}")
