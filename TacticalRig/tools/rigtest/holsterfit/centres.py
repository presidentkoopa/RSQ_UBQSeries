import sys, re, numpy as np
sys.path.insert(0,'/home/claude/wt_boss/TacticalRig/tools')
import measure_pickups as mp
U='/mnt/user-data/uploads/__CurrentRotationDONOTDELETE'
paks=[mp.Pak(p) for p in [U+'/1.00_brutal22test6.pk3',U+'/1.1-BD22_VoxelPack.pk3','/home/claude/wt_bd/BD22_VR-Reloaded_2.0.5t.pk3']]
def find(path):
    for pk in reversed(paks):
        d=pk.get(path)
        if d is not None: return d
table={}
for pk in paks:
    for low,real in sorted(pk.names.items()):
        base=low.rsplit('/',1)[-1]
        if '/' in low or not base.startswith('modeldef'): continue
        for cls,body in mp.parse_modeldef(pk.z.read(real).decode('latin-1')):
            s=mp.block_settings(body)
            for spr,fr,mi,mf in s['frames']:
                table.setdefault((cls.lower(),spr,fr),{})[int(mi)]=(s,mf)
FR={'rifle':('RIFG','A'),'brutalpistol':('2IST','E'),'shot_gun':('SHTN','A')}
MESH={}
for c,(spr,fr) in FR.items():
    pts=[]
    for mi,(s,mf) in table[(c,spr,fr)].items():
        path=s['path'].rstrip('/')+'/'+s['models'][mi]
        pts+=mp.place(mp.md3_points(find(path),int(mf)),s,1.2)
    MESH[c]=np.array(pts)
def basis(a,p,r):
    a,p,r=np.radians([a,p,r]); ca,sa,cp,sp,cr,sr=np.cos(a),np.sin(a),np.cos(p),np.sin(p),np.cos(r),np.sin(r)
    F=np.array([ca*cp,sa*cp,-sp]); L0=np.array([-sa,ca,0]); U0=np.array([ca*sp,sa*sp,cp])
    return np.stack([F,L0*cr+U0*sr,U0*cr-L0*sr],1)
upm=34.0
for run in sys.argv[1:]:
    seen={}
    for line in open('/home/claude/rig/logs/%s.log'%run,encoding='latin-1'):
        m=re.match(r'thd: t(\d+) r(\d) (\S+) at (\S+) (\S+) (\S+) org (\S+) (\S+) (\S+) ang (\S+) (\S+) (\S+) s (\S+) body (\S+)',line)
        if m: seen[m.group(2)]=m.groups()
    for r,g in sorted(seen.items()):
        cls=g[2]; at=np.array(g[3:6],float); org=np.array(g[6:9],float); a,p,rl=map(float,g[9:12]); s=float(g[12]); by=float(g[13])
        M=MESH[cls.lower()]; c=(M.min(0)+M.max(0))/2
        mid=org+basis(a,p,rl)@(s*c)
        d=mid-at
        # body frame: forward, left, up (metres; up uses the pixel stretch)
        cb,sb=np.cos(np.radians(by)),np.sin(np.radians(by))
        f=(d[0]*cb+d[1]*sb)/upm; l=(-d[0]*sb+d[1]*cb)/upm; u=d[2]*1.2/upm
        print('%s r%s %-13s drawn middle from holster centre: fwd %+.3f left %+.3f up %+.3f m  (|d| %.3f m)'%(run,r,cls,f,l,u,np.sqrt(f*f+l*l+u*u)))
