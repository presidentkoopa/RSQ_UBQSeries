# slowfx probe arena: one 2048x2048 room, ceiling 512, player at 0,0 facing east (rig only)
import struct, sys
V=[(-1024,-1024),(-1024,1024),(1024,1024),(1024,-1024)]
out=['namespace = "zdoom";','thing { x = 0.0; y = 0.0; type = 1; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }']
for x,y in V: out.append('vertex { x = %.1f; y = %.1f; }'%(x,y))
for i in range(4): out.append('linedef { v1 = %d; v2 = %d; sidefront = %d; blocking = true; }'%(i,(i+1)%4,i))
for i in range(4): out.append('sidedef { sector = 0; texturemiddle = "STARTAN2"; }')
out.append('sector { heightfloor = 0; heightceiling = 512; texturefloor = "FLOOR4_8"; textureceiling = "CEIL5_1"; lightlevel = 176; }')
tm='\n'.join(out).encode()
lumps=[('MAP01',b''),('TEXTMAP',tm),('ENDMAP',b'')]
data=b'';dirs=[];off=12
for n,d in lumps: dirs.append((off,len(d),n));data+=d;off+=len(d)
w=struct.pack('<4sii',b'PWAD',len(lumps),off)+data+b''.join(struct.pack('<ii8s',o,l,n.encode()) for o,l,n in dirs)
open(sys.argv[1],'wb').write(w); print('map', len(w))
