#!/usr/bin/env python3
# md3info.py -- TOOL (never ships): frames, surfaces and per-surface centre / extents of an MD3, per frame.
#   python3 -I Grenade/tools/md3info.py Grenade/models/rsqgn/nade.md3 0 2 16
import struct,sys
d=open(sys.argv[1],'rb').read()
ident,ver,name,flags,nf,nt,ns,nsk,ofr,otag,osurf,oend=struct.unpack('<4si64siiiiiiiii',d[:108])
print('frames',nf,'surfaces',ns)
o=osurf
surfs=[]
for s in range(ns):
    h=struct.unpack('<4s64siiiiiiiiii',d[o:o+108])
    _,sn,_,snf,nsh,nv,ntr,otri,osh,ost,oxyz,send=h
    sn=sn.split(b'\0')[0].decode()
    shn=struct.unpack('<64si',d[o+osh:o+osh+68])[0].split(b'\0')[0].decode()
    surfs.append((sn,shn,nv,o+oxyz))
    o+=send
fr=[int(a) for a in sys.argv[2:]] or [0,2]
for f in fr:
    print('frame',f)
    allp=[]
    for i,(sn,shn,nv,ox) in enumerate(surfs):
        pts=[]
        for v in range(nv):
            x,y,z,n=struct.unpack('<hhhH',d[ox+(f*nv+v)*8:ox+(f*nv+v)*8+8])
            pts.append((x/64,y/64,z/64))
        allp+=pts
        mn=[min(p[k] for p in pts) for k in range(3)];mx=[max(p[k] for p in pts) for k in range(3)]
        c=[sum(p[k] for p in pts)/len(pts) for k in range(3)]
        print(' surf',i,sn,shn,nv,'c=(%.2f %.2f %.2f)'%tuple(c),'min',['%.2f'%a for a in mn],'max',['%.2f'%a for a in mx])
    mn=[min(p[k] for p in allp) for k in range(3)];mx=[max(p[k] for p in allp) for k in range(3)]
    print(' all min',['%.2f'%a for a in mn],'max',['%.2f'%a for a in mx])
