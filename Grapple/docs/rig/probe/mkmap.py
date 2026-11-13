# makes g2probe/maps/MAP01.wad: Grapple 2.0's test arena (rig only)
import struct, sys
V=[(-1024,-1024),(-1024,-640),(-1024,768),(-1024,1024),(1024,1024),(1024,768),(1024,-640),(1024,-1024)]
A,B,C,D,E,F,G,H=range(8)
S=[(0,512,'FLOOR4_8','CEIL5_1'),(64,512,'FLOOR4_8','CEIL5_1'),(0,90,'FLAT5_4','CEIL5_1')]
sides=[];lines=[]
def side(sec,mid=None,top=None):
    sides.append((sec,mid,top));return len(sides)-1
def one(v1,v2,sec): lines.append((v1,v2,side(sec,'STARTAN2'),None))
def two(v1,v2,front,back): lines.append((v1,v2,side(front,None,'STARTAN2'),side(back,None,'STARTAN2')))
one(B,C,0); one(C,D,1); one(D,E,1); one(E,F,1); one(F,G,0); one(G,H,2); one(H,A,2); one(A,B,2)
two(C,F,0,1)   # y=768, going east: front (right) = south = main, back = the ledge
two(G,B,0,2)   # y=-640, going west: front = north = main, back = the low ceiling
out=['namespace = "zdoom";','thing { x = 0.0; y = 0.0; type = 1; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }',
 'thing { x = 900.0; y = -900.0; type = 3001; angle = 180; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; ambush = true; }',
 'thing { x = 900.0; y = 900.0; type = 3001; angle = 180; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; ambush = true; }',
 'thing { x = -900.0; y = 900.0; type = 3004; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; ambush = true; }']
for x,y in V: out.append('vertex { x = %.1f; y = %.1f; }'%(x,y))
for v1,v2,f,b in lines:
    s='linedef { v1 = %d; v2 = %d; sidefront = %d; '%(v1,v2,f)
    s+= ('sideback = %d; twosided = true; '%b) if b is not None else 'blocking = true; '
    out.append(s+'}')
for sec,mid,top in sides:
    s='sidedef { sector = %d; '%sec
    if mid: s+='texturemiddle = "%s"; '%mid
    if top: s+='texturetop = "%s"; texturebottom = "%s"; '%(top,top)
    out.append(s+'}')
for f,c,tf,tc in S: out.append('sector { heightfloor = %d; heightceiling = %d; texturefloor = "%s"; textureceiling = "%s"; lightlevel = 200; }'%(f,c,tf,tc))
tm='\n'.join(out).encode()
lumps=[('MAP01',b''),('TEXTMAP',tm),('ENDMAP',b'')]
data=b'';dirs=[];off=12
for n,d in lumps: dirs.append((off,len(d),n));data+=d;off+=len(d)
w=struct.pack('<4sii',b'PWAD',len(lumps),off)+data+b''.join(struct.pack('<ii8s',o,l,n.encode()) for o,l,n in dirs)
open(sys.argv[1],'wb').write(w); print('map', len(w))
