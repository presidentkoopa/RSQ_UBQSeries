import struct, sys
# TEST ONLY. WHIPTEST = GRTEST plus a BEAM hanging over the pit near the west ledge (its underside at z 96,
# 80 units out: an edge a whip can wrap round) and a SWITCH pillar on the ledge (Light_ChangeToValue, use).
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
BM=sector(f=-512,c=72,ft="NUKAGE1",ct="FLAT1")               # the beam over the pit: underside z 72
SW=sector(f=0,c=0,ft="FLAT1",ct="FLAT1",tag=4)               # the switch pillar (closed), on ledge A
LG=sector(f=96,c=512,ft="FLAT1",ct="CEIL5_1")                # a 96-unit block on ledge A to mantle onto
add_rect(A,0,0,512,1024,splits=[(256,1024),(384,1024)])
add_rect(P,512,0,1280,1024)
add_rect(B,1280,0,1792,1024)
add_rect(I,800,64,1000,256)
add_rect(C,-512,-512,-384,-384)
add_rect(D,256,1024,384,1280)
add_rect(BM,536,384,576,640)
add_rect(SW,96,736,128,768)
add_rect(LG,320,96,448,288)
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
    if ln[2] in (I, BM) and ln[3] is None: ln[3]=P
    if ln[2] in (SW, LG) and ln[3] is None: ln[3]=A
# the switch: the pillar's west face (x 96), used from the ledge
SWL=None
for ln in lines:
    (x1,y1),(x2,y2)=V[ln[0]],V[ln[1]]
    if ln[2]==SW and x1==96 and x2==96: ln[4]=112; ln[5]=(4,255,0,0,0); SWL=ln
# 3D floor control line on C's first line
for ln in lines:
    if ln[2]==C: ln[4]=160; ln[5]=(1,1,0,255,0); break
out=['namespace = "zdoom";',
 'thing { x = 256.0; y = 512.0; type = 1; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }']
for (x,y) in V: out.append('vertex { x = %d.0; y = %d.0; }'%(x,y))
sides=[]
def side(sec, other):
    s='sidedef { sector = %d; '%sec
    if other is None: s+='texturemiddle = "STARTAN2"; '
    else: s+='texturetop = "STARTAN2"; texturebottom = "STARTAN2"; '
    s+='}'; sides.append(s); return len(sides)-1
for (v1,v2,f,b,sp,args) in lines:
    fs=side(f,b); bs=side(b,f) if b is not None else None
    s='linedef { v1 = %d; v2 = %d; sidefront = %d; '%(v1,v2,fs)
    if bs is not None: s+='sideback = %d; twosided = true; '%bs
    else: s+='blocking = true; '
    if sp: s+='special = %d; arg0 = %d; arg1 = %d; arg2 = %d; arg3 = %d; '%((sp,)+args[:4])
    if sp == 112: s+='playeruse = true; repeatspecial = true; '
    s+='}'; out.append(s)
out+=sides
for k in S:
    s='sector { heightfloor = %d; heightceiling = %d; texturefloor = "%s"; textureceiling = "%s"; lightlevel = 200; '%(k['f'],k['c'],k['ft'],k['ct'])
    if 'tag' in k: s+='id = %d; '%k['tag']
    s+='}'; out.append(s)
tm='\n'.join(out).encode()
lumps=[('WHIPTEST',b''),('TEXTMAP',tm),('ENDMAP',b'')]
data=b''; dirs=[]; off=12
for n,d in lumps: dirs.append((off,len(d),n)); data+=d; off+=len(d)
w=b'PWAD'+struct.pack('<ii',len(lumps),off)+data+b''.join(struct.pack('<ii8s',o,s,n.encode()) for o,s,n in dirs)
open(sys.argv[1],'wb').write(w); print(len(V),'verts',len(lines),'lines',len(S),'sectors')
