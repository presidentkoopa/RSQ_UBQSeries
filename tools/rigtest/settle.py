import re,sys,math
# per-swing table: turning points, amplitude in degrees from the anchor, period, settle tic
pts=[];anc=None
for l in open(sys.argv[1]):
    m=re.match(r'T_GR t(\d+) h0 (\w+) pos\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) vel\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) claw\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) L([\d.]+).*scale([\d.]+)',l)
    if m: pts.append([float(x) if i!=1 else x for i,x in enumerate(m.groups())])
sw=[p for p in pts if p[1]=='swing']
prev=None; turns=[]
for p in sw:
    if prev and (prev[5]>0)!=(p[5]>0): turns.append(p)
    prev=p
for i,p in enumerate(turns):
    ax=p[8]; L=p[11]; a=math.degrees(math.asin(max(-1,min(1,(p[2]-ax)/L))))
    print('turn %2d t%4d x %.1f amp %5.1f deg %s'%(i,int(p[0]),p[2],abs(a), ('half-period %d'%(int(p[0])-int(turns[i-1][0])) if i else '')))
still=lambda p: abs(p[5])<0.005 and abs(p[6])<0.005 and abs(p[7])<0.005
rest=None
for i in range(len(sw)):
    if all(still(q) for q in sw[i:]): rest=sw[i]; break
start=sw[0][0] if sw else 0
print(('rest at t%d (%d tics = %.1f s after the swing began at t%d), %.1f units from under the anchor'%(rest[0],rest[0]-start,(rest[0]-start)/35.0,start,math.hypot(rest[2]-rest[8],rest[3]-rest[9]))) if rest else 'not at rest', 'scale', sw[-1][12] if sw else '')
