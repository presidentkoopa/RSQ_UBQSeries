import re,sys
pts=[]
for l in open(sys.argv[1]):
    m=re.match(r'T_GR t(\d+) h(\d) (\w+) pos\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) vel\(([-\d.]+) ([-\d.]+) ([-\d.]+)\).*L([\d.]+) d([\d.]+)',l)
    if m: pts.append(dict(t=int(m[1]),ph=m[3],x=float(m[4]),y=float(m[5]),z=float(m[6]),vx=float(m[7]),vy=float(m[8]),vz=float(m[9]),L=float(m[10]),d=float(m[11])))
ax=sys.argv[2] if len(sys.argv)>2 else 'x'
prev=None
for p in pts:
    if p['ph']!='swing': prev=None; continue
    if prev and (prev['v'+ax]>0)!=(p['v'+ax]>0): print('turn t%d %s=%.1f z=%.1f L%.1f d%.1f'%(p['t'],ax,p[ax],p['z'],p['L'],p['d']))
    prev=p
sw=[p for p in pts if p['ph']=='swing']
if sw: print('swing tics',len(sw)*2,'zmin %.1f'%min(p['z'] for p in sw), 'max|v| %.2f'%max((p['vx']**2+p['vy']**2+p['vz']**2)**.5 for p in sw))
