import struct, sys
# GRTEST: west ledge A, pit P (floor -512), east ledge B, a 3D-floor slab over the pit, ceiling 512.
V=[]; vid={}
def v(x,y):
    if (x,y) not in vid: vid[(x,y)]=len(V); V.append((x,y))
    return vid[(x,y)]
S=[]  # sectors dicts
L=[]  # (v1,v2,frontsec,backsec,special,args)
def sector(**k): S.append(k); return len(S)-1
def rect_edges(x0,y0,x1,y1):  # clockwise in y-up => right side inside
    pts=[(x0,y0),(x0,y1),(x1,y1),(x1,y0)]
    return [(pts[i],pts[(i+1)%4]) for i in range(4)]
edges={}
def add_rect(sec,x0,y0,x1,y1,splits=()):
    # splits: extra vertices on edges so shared segments match
    for (a,b) in rect_edges(x0,y0,x1,y1):
        pts=[a]+sorted([p for p in splits if on_seg(p,a,b)], key=lambda p:(p[0]-a[0])**2+(p[1]-a[1])**2)+[b]
        for i in range(len(pts)-1):
            key=(pts[i],pts[i+1])
            edges[key]=sec
def on_seg(p,a,b):
    if p==a or p==b: return False
    if a[0]==b[0]==p[0]: return min(a[1],b[1])<p[1]<max(a[1],b[1])
    if a[1]==b[1]==p[1]: return min(a[0],b[0])<p[0]<max(a[0],b[0])
    return False
A=sector(f=0,c=512,ft="FLOOR4_8",ct="CEIL5_1")
P=sector(f=-512,c=512,ft="NUKAGE1",ct="CEIL5_1")
B=sector(f=0,c=512,ft="FLOOR4_8",ct="CEIL5_1")
I=sector(f=-512,c=512,ft="NUKAGE1",ct="CEIL5_1",tag=1)       # under the slab
C=sector(f=128,c=160,ft="FLAT1",ct="FLAT1")                  # control sector (slab z 128..160)
D=sector(f=0,c=200,ft="FLOOR4_8",ct="CEIL5_1",tag=2)         # low-ceiling alcove in A (ceiling anchor that moves: tag 2)
add_rect(A,0,0,512,1024,splits=[(256,1024),(384,1024)])
add_rect(P,512,0,1280,1024)
add_rect(B,1280,0,1792,1024)
add_rect(I,800,64,1000,256)
add_rect(C,-512,-512,-384,-384)
add_rect(D,256,1024,384,1280)
# merge into linedefs
done=set(); lines=[]
for (a,b),sec in edges.items():
    if (a,b) in done: continue
    back=edges.get((b,a))
    done.add((a,b)); 
    if back is not None: done.add((b,a))
    lines.append([v(*a),v(*b),sec,back,0,(0,0,0,0,0)])
# inner rect I lines: back = P
for ln in lines:
    if ln[2]==I and ln[3] is None: ln[3]=P
# 3D floor control line on C's first line
for ln in lines:
    if ln[2]==C: ln[4]=160; ln[5]=(1,1,0,255,0); break
# a SWITCH (QoL GR5, 2026-10-31): ledge B's east wall, use to lower the alcove's ceiling (tag 2) by 64,
# Ceiling_LowerByValue(2, 8, 64), repeatable; the hook hits it from grp_tp 1600 512 0 straight ahead
USE=set()
for ln in lines:
    if ln[2]==B and ln[3] is None and V[ln[0]][0]==1792 and V[ln[1]][0]==1792: ln[4]=40; ln[5]=(2,8,64,0,0); USE.add(id(ln))
out=['namespace = "zdoom";',
 'thing { x = 256.0; y = 512.0; type = 1; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }']
for (x,y) in V: out.append('vertex { x = %d.0; y = %d.0; }'%(x,y))
sides=[]
def side(sec, other):
    s='sidedef { sector = %d; '%sec
    if other is None: s+='texturemiddle = "STARTAN2"; '
    else: s+='texturetop = "STARTAN2"; texturebottom = "STARTAN2"; '
    s+='}'; sides.append(s); return len(sides)-1
for ln in lines:
    (v1,v2,f,b,sp,args)=ln
    fs=side(f,b); bs=side(b,f) if b is not None else None
    s='linedef { v1 = %d; v2 = %d; sidefront = %d; '%(v1,v2,fs)
    if id(ln) in USE: s+='playeruse = true; repeatspecial = true; '
    if bs is not None: s+='sideback = %d; twosided = true; '%bs
    else: s+='blocking = true; '
    if sp: s+='special = %d; arg0 = %d; arg1 = %d; arg2 = %d; arg3 = %d; '%((sp,)+args[:4])
    s+='}'; out.append(s)
out+=sides
for k in S:
    s='sector { heightfloor = %d; heightceiling = %d; texturefloor = "%s"; textureceiling = "%s"; lightlevel = 200; '%(k['f'],k['c'],k['ft'],k['ct'])
    if 'tag' in k: s+='id = %d; '%k['tag']
    s+='}'; out.append(s)
tm='\n'.join(out).encode()
lumps=[('GRTEST',b''),('TEXTMAP',tm),('ENDMAP',b'')]
data=b''; dirs=[]; off=12
for n,d in lumps: dirs.append((off,len(d),n)); data+=d; off+=len(d)
w=b'PWAD'+struct.pack('<ii',len(lumps),off)+data+b''.join(struct.pack('<ii8s',o,s,n.encode()) for o,s,n in dirs)
open(sys.argv[1],'wb').write(w); print(len(V),'verts',len(lines),'lines',len(S),'sectors')
