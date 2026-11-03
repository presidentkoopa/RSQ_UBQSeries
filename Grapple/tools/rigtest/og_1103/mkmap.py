import struct, sys
# GRV: one flat room 0..2400 x 0..1024, floor 0, ceiling 512; east wall at x=2400. Test only.
V=[(0,0),(0,1024),(2400,1024),(2400,0)]
out=['namespace = "zdoom";',
 'thing { x = 100.0; y = 512.0; type = 1; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }']
for x,y in V: out.append('vertex { x = %d.0; y = %d.0; }'%(x,y))
for i in range(4):
    out.append('linedef { v1 = %d; v2 = %d; sidefront = %d; blocking = true; }'%(i,(i+1)%4,i))
for i in range(4): out.append('sidedef { sector = 0; texturemiddle = "STARTAN2"; }')
out.append('sector { heightfloor = 0; heightceiling = 512; texturefloor = "FLOOR4_8"; textureceiling = "CEIL5_1"; lightlevel = 200; }')
tm='\n'.join(out).encode()
lumps=[('GRV',b''),('TEXTMAP',tm),('ENDMAP',b'')]
data=b''; dirs=[]; off=12
for n,d in lumps: dirs.append((off,len(d),n)); data+=d; off+=len(d)
w=b'PWAD'+struct.pack('<ii',len(lumps),off)+data+b''.join(struct.pack('<ii8s',o,s,n.encode()) for o,s,n in dirs)
open(sys.argv[1],'wb').write(w)
