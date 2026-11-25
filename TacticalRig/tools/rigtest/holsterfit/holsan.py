import sys, re, struct, numpy as np
from PIL import Image, ImageDraw
from scipy.optimize import least_squares
from scipy import ndimage
exec(open('centres.py').read().split('upm=34.0')[0])
def md3_mesh(data, frame):
    ident, ver, name, flags, nfr, ntags, nsurf, nskins, ofr, otag, osurf, oend = struct.unpack_from('<4si64s9i', data, 0)
    V=[];T=[];o=osurf
    for _ in range(nsurf):
        sid, sname, sflags, snfr, nshad, nverts, ntris, otris, oshad, ost, oxyz, oend2 = struct.unpack_from('<4s64s10i', data, o)
        base=len(V)
        for t in range(ntris): T.append([base+i for i in struct.unpack_from('<3i', data, o+otris+t*12)])
        b=o+oxyz+frame*nverts*8
        for v in range(nverts):
            x,y,z,_n=struct.unpack_from('<hhhh',data,b+v*8); V.append((x/64.,y/64.,z/64.))
        o+=oend2
    return V,T
TRI={}
for c,(spr,fr) in FR.items():
    V=[];T=[]
    for mi,(s,mf) in table[(c,spr,fr)].items():
        path=s['path'].rstrip('/')+'/'+s['models'][mi]
        v,t=md3_mesh(find(path),int(mf)); b=len(V)
        V+=mp.place(v,s,1.2); T+=[[b+i for i in tt] for tt in t]
    TRI[c]=(np.array(V),np.array(T))
LEN={'F':{'rifle':92.32,'brutalpistol':26.05,'shot_gun':94.13},'A':{'rifle':92.32,'brutalpistol':26.05,'shot_gun':94.13},'B':{'rifle':92.48,'brutalpistol':27.06,'shot_gun':94.51}}
HANG={0:(80,-10),1:(80,10),6:(70,35),7:(70,-35)}
def rot_cam(yaw,pitch,roll):
    # camera axes: forward, right, up for a view turned yaw (left +), pitch (down -), roll
    y,p,r=np.radians([yaw,pitch,roll])
    F=np.array([np.cos(y)*np.cos(p),np.sin(y)*np.cos(p),np.sin(p)])
    Rt=np.array([np.sin(y),-np.cos(y),0.0])
    Up=np.cross(Rt,F)
    Rt2=Rt*np.cos(r)+Up*np.sin(r); Up2=Up*np.cos(r)-Rt*np.sin(r)
    return F,Rt2,Up2
def project(X,cam,eye0):
    ex,ey,ez,yaw,pitch,roll,f,cx,cy=cam
    d=X-(eye0+np.array([ex,ey,ez])); d=d*np.array([1,1,1.2])
    F,R,Up=rot_cam(yaw,pitch,roll)
    z=d@F; return np.stack([cx+f*(d@R)/z, cy-f*(d@Up)/z],-1)
def detect(im):
    r,g,b=[im[...,i].astype(int) for i in range(3)]
    m=((r>140)&(b>140)&(g<110))|((r>200)&(g>200)&(b>200))|((b>180)&(r<120)&(g<150))
    lab,n=ndimage.label(m)
    return np.array(ndimage.center_of_mass(m,lab,range(1,n+1)))[:,::-1] if n else np.zeros((0,2))
def analyse(run,frame,bgframe=30):
    seen={}
    for line in open('/home/claude/rig/logs/%s.log'%run,encoding='latin-1'):
        m=re.match(r'thd: t(\d+) r(\d) (\S+) at (\S+) (\S+) (\S+) org (\S+) (\S+) (\S+) ang (\S+) (\S+) (\S+) s (\S+) body (\S+) eye (\S+) (\S+) (\S+) (\S+)',line)
        if m: seen[int(m.group(2))]=m.groups()
    eye0=np.array(list(seen.values())[0][14:17],float)
    X=[]; items=[]
    for r,g in seen.items():
        cls=g[2].lower(); at=np.array(g[3:6],float); s=float(g[12]); by=float(g[13])
        pt,rl=HANG[r]; F=basis(by,pt,rl)[:,0]; half=0.5*s*LEN[run[0]][cls]
        for k in range(-4,5):
            e=F*(half*k/4); X.append(at+np.array([e[0],e[1],e[2]/1.2]))
        items.append((r,cls,at,np.array(g[6:9],float),tuple(map(float,g[9:12])),s))
    by0=float(list(seen.values())[0][13]); cb,sb=np.cos(np.radians(by0)),np.sin(np.radians(by0))
    X=[]
    for gi in range(4):
        for gj in range(5):
            for gk in range(2):
                f=0.10+0.10*gi; l=-0.30+0.15*gj; dn=0.25 if gk==0 else 0.55
                X.append(eye0+np.array([(cb*f-sb*l)*34,(sb*f+cb*l)*34,-dn*34/1.2]))
    X=np.array(X)
    im=np.asarray(Image.open('/home/claude/rig/frames/%s/f%05d.ppm'%(run,frame)).convert('RGB'))
    H,W=im.shape[:2]
    r_,g_,b_=[im[...,i].astype(int) for i in range(3)]
    cm=(g_>150)&(b_>150)&(r_<90)
    lab,n=ndimage.label(cm); px=np.array(ndimage.center_of_mass(cm,lab,range(1,n+1)))[:,::-1]
    def res(cam):
        pr=project(X,cam,eye0)
        return np.array([np.min(np.linalg.norm(pr-q,axis=1)) for q in px])
    best=None
    for pit in (-75,-80,-85,-88):
        c0=[0,0,0,by0,pit,0,238.2*W/500,W/2,H/2]
        so=least_squares(res,c0,loss='soft_l1',f_scale=2)
        if best is None or so.cost<best.cost: best=so
    sol=best
    cam=sol.x
    rr=res(cam)
    bg=np.asarray(Image.open('/home/claude/rig/frames/%s/f%05d.ppm'%(run,bgframe)).convert('RGB')).astype(int)
    obs=np.abs(im.astype(int)-bg).sum(-1)>45
    dots=ndimage.binary_dilation(((im[...,0]>140)&(im[...,2]>140)&(im[...,1]<110))|((im[...,0]>200)&(im[...,1]>200)&(im[...,2]>200)),iterations=2)
    obs=ndimage.binary_fill_holes(ndimage.binary_closing(obs&~dots,iterations=2))
    out=[]
    for r,cls,at,org,ang,s in items:
        V,T=TRI[cls]
        Wp=org+(basis(*ang)@(s*V).T).T
        uv=project(Wp,cam,eye0)
        img=Image.new('L',(W,H),0); dr=ImageDraw.Draw(img)
        for t in T: dr.polygon([tuple(uv[i]) for i in t],fill=1)
        pm=np.asarray(img)>0
        # observed near this gun: within its predicted box grown by 15 px
        ys,xs=np.nonzero(pm); box=np.zeros_like(pm); box[max(0,ys.min()-15):ys.max()+15,max(0,xs.min()-15):xs.max()+15]=True
        om=obs&box
        out.append((r,cls,(pm&om).sum()/max(1,(pm|om).sum()),pm))
    return cam,rr,out,im
if __name__=='__main__':
    for run,frame in [(a.split(':')[0],int(a.split(':')[1])) for a in sys.argv[1:]]:
        cam,rr,out,im=analyse(run,frame)
        print(run,frame,'camera: dots %d, rms %.2f px'%(len(rr),np.sqrt(np.mean(np.minimum(rr,10)**2))),'pitch %.1f f %.0f'%(cam[4],cam[6]))
        vis=im.astype(float).copy()
        for r,cls,iou,pm in out:
            print('   r%d %-13s outline overlap (predicted vs drawn) %.2f'%(r,cls,iou))
            edge=pm&~ndimage.binary_erosion(pm)
            vis[edge]=[0,255,0]
        Image.fromarray(vis.astype(np.uint8)).save('hv_%s.png'%run)
