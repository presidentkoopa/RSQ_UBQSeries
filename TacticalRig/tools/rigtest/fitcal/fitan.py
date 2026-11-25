import sys, struct, re, numpy as np
from PIL import Image, ImageDraw
from scipy.optimize import least_squares
sys.path.insert(0,'/home/claude/wt_boss/TacticalRig/tools')
import measure_pickups as mp
FR='/home/claude/rig/frames/c7/f%05d.ppm'
FRAMES=[45,72,108,148,186,222,258,295]
d2r=np.radians
def basis(a,p,r):
    ca,sa,cp,sp,cr,sr=np.cos(d2r(a)),np.sin(d2r(a)),np.cos(d2r(p)),np.sin(d2r(p)),np.cos(d2r(r)),np.sin(d2r(r))
    F=np.array([ca*cp,sa*cp,-sp]); L0=np.array([-sa,ca,0]); U0=np.array([ca*sp,sa*sp,cp])
    L=L0*cr+U0*sr; U=U0*cr-L0*sr
    return F,L,U
poses=[]
for line in open('/home/claude/rig/logs/c7.log',encoding='latin-1'):
    m=re.match(r'cal: t(\d+) pose (\d) eye (\S+) (\S+) (\S+) ang (\S+) \| org (\S+) (\S+) (\S+) \| a (\S+) p (\S+) r (\S+) s (\S+) \| tgt (\S+) (\S+) (\S+) ps (\S+)',line)
    if m and len(poses)<8:
        v=[float(x) for x in m.groups()]
        poses.append(dict(eye=np.array(v[2:5]),ang=v[5],org=np.array(v[6:9]),a=v[9],p=v[10],r=v[11],s=v[12],tgt=np.array(v[13:16]),ps=v[16]))
# ---- dots: 3D and pixels
half=0.5*27.06*2.5
def dots3d(P):
    F,L,U=basis(P['a'],P['p'],P['r'])
    out=[]
    for i in range(-6,7):
        e=F*(-half*i/6.0); out.append(P['tgt']+np.array([e[0],e[1],e[2]/P['ps']]))
    return np.array(out)
def detect(im):
    r,g,b=im[...,0].astype(int),im[...,1].astype(int),im[...,2].astype(int)
    m=((r>150)&(b>150)&(g<120))
    ys,xs=np.nonzero(m)
    cl=[]
    for x,y in zip(xs,ys):
        for c in cl:
            if abs(c[0]/c[2]-x)<3 and abs(c[1]/c[2]-y)<3: c[0]+=x;c[1]+=y;c[2]+=1;break
        else: cl.append([x,y,1])
    return np.array([(c[0]/c[2],c[1]/c[2]) for c in cl])
ims=[np.asarray(Image.open(FR%f).convert('RGB')) for f in FRAMES]
H,W=ims[0].shape[:2]
def project(X,cam):
    ex,ey,ez,f,cx,cy=cam
    eye=poses[0]['eye']+np.array([ex,ey,ez])
    d=X-eye
    # facing +y (angle 90): depth = y, right = x, up = z*ps
    depth=d[...,1]; right=d[...,0]; up=d[...,2]*1.2
    return np.stack([cx+f*right/depth, cy-f*up/depth],-1)
obs=[]
for P,im in zip(poses,ims):
    X=dots3d(P); px=detect(im)
    obs.append((X,px))
def resid(cam):
    r=[]
    for X,px in obs:
        pr=project(X,cam)
        if len(px)==0: continue
        # each detected dot to the nearest predicted dot
        for q in px:
            dd=np.linalg.norm(pr-q,axis=1); r.append(dd.min())
    return np.array(r)
cam0=[0,0,0,W/2,W/2,H/2]
best=least_squares(resid,cam0,loss='soft_l1')
cam=best.x
print('cam',np.round(cam,2),'rms',np.sqrt(np.mean(resid(cam)**2)).round(2),'n',len(resid(cam)))
np.save('cam.npy',cam)
for k,(X,px) in enumerate(obs):
    pr=project(X,cam)
    print(k,'det',np.round(px).astype(int).tolist()[:14])
    print(k,'pre',np.round(pr).astype(int).tolist())
