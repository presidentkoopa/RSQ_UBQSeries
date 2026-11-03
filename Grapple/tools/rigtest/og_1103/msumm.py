import re,sys,math
L=open(sys.argv[1],errors='replace').read().splitlines()
shot=None; rows={}; pl={}
for ln in L:
    m=re.match(r'SHOT_(\S+)',ln)
    if m: shot=m.group(1); rows[shot]=[]; continue
    if shot and (ln.startswith('M t') or ln.startswith('V t')): rows[shot].append(ln)
M=re.compile(r'M t(\d+) (\S+) pos\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) vel\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) dv\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) \|vxy\| ([-\d.]+) d2 ([-\d.]+) hp (-?\d+) tics (-?\d+)')
V=re.compile(r'V t(\d+) pos\(([-\d.]+) ([-\d.]+) ([-\d.]+)\)')
for s,rs in rows.items():
    pp={}; ms=[]
    for r in rs:
        v=V.match(r)
        if v: pp[int(v.group(1))]=tuple(map(float,v.groups()[1:])); continue
        m=M.match(r)
        if m: ms.append(m.groups())
    li=None
    for i,g in enumerate(ms):
        if abs(float(g[8]))+abs(float(g[9]))>1.5: li=i; break
    if li is None: print(s,'NO THROW'); continue
    g=ms[li]; pb=ms[li-1]; t=int(g[0])
    mx,my,mz=map(float,pb[2:5]); px,py,pz=pp.get(t,pp.get(t-1))
    d=math.hypot(px-mx,py-my); f=math.floor(d+0.5); ang=math.degrees(math.atan2(py-my,px-mx))%360; b=int(ang*65536/360)>>8
    zh=math.floor(pz-mz+0.5); th=math.radians(b*360/256)
    # where it stopped
    stop=None
    for x in ms[li+1:]:
        if float(x[11])<0.1: stop=x; break
    print(f"{s:10s} throw t{t} mon({mx:.1f},{my:.1f},{mz:.1f}) player({px:.1f},{py:.1f},{pz:.1f}) 2D {d:.1f} | dv({float(g[8]):.3f},{float(g[9]):.3f}) vz {float(g[7]):.3f} | ACS: ({(f//12)*math.cos(th):.3f},{(f//12)*math.sin(th):.3f}) vz {int(zh/2)/4:.3f}"
          f" | stopped {('t'+stop[0]+' at '+stop[12]+' from you') if stop else '-'}")
