import re,sys
# per shot: the player's track from the launch tic for N tics, OG vs ours, and the largest difference
def tracks(fn):
    L=open(fn,errors='replace').read().splitlines(); shot=None; out={}
    P=re.compile(r'V t(\d+) pos\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) vel\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) dv\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) \|vxy\| ([-\d.]+) km(\d) gnd(\d)')
    for ln in L:
        m=re.match(r'SHOT_(\S+)',ln)
        if m: shot=m.group(1); out[shot]=[]; continue
        g=P.match(ln)
        if shot and g: out[shot].append(g.groups())
    res={}
    for s,v in out.items():
        i=next((k for k,g in enumerate(v) if abs(float(g[7]))+abs(float(g[8]))>1.5 or float(g[9])>0.2),None)
        res[s]=v[i:i+80] if i is not None else []
    return res
a=tracks(sys.argv[1]); b=tracks(sys.argv[2])
for s in a:
    A,B=a[s],b.get(s,[])
    n=min(len(A),len(B))
    for k in range(1,n):
        if abs(float(A[k][1])-float(A[k-1][1]))>100 or abs(float(B[k][1])-float(B[k-1][1]))>100: n=k; break
    if not n: print(s,'-'); continue
    dmax=max(max(abs(float(A[k][j])-float(B[k][j])) for j in (1,2,3,4,5,6)) for k in range(n))
    land=next((k for k in range(1,n) if B[k][12]=='1'),None)
    km=[B[k][11] for k in range(n)]
    print(f"{s:9s} {n} tics compared, max |OG-ours| over pos/vel {dmax:.3f}; ours: lands +{land} tics, |vxy| then {B[land][10] if land else '-'}, at +40 x {float(B[min(40,n-1)][1]):.1f} |vxy| {B[min(40,n-1)][10]}, keepmomentum 1 for {km.count('1')} tics")
