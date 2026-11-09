# v3: bouncing debris that lands and settles on the floor (generalised from #9's dark hard-pixel bits).
# Self-contained (no fx import) so both canvases can use it: pass the barrel x, floor y, px-per-map-unit and colour scale.
# Pieces are tiny hard-pixel masks (drawn opaque, normal blend), tumble 90 deg while airborne, bounce, skid, settle,
# step down a palette as they cool, then blink out one by one. Launched in mirrored pairs so the spray stays centred.
import math, random
import numpy as np
SHAPES={
 'dot':[[1]], 'bar':[[1,1]], 'vbar':[[1],[1]], 'sq':[[1,1],[1,1]], 'L':[[1,0],[1,1]],
 'shard':[[1,1,1],[0,1,0]], 'chunk':[[0,1,1],[1,1,1],[1,1,0]], 'slab':[[1,1,1],[1,1,1]], 'tri':[[1,0,0],[1,1,0],[1,1,1]],
}
class Debris:
    def __init__(s,start,bx,floor,unit,n=16,seed=1,z0=(14,30),speed=(4,8),spread=(20,75),grav=0.9,bounce=(0.3,0.45),
                 friction=0.55,palettes=None,cool=(2,3),shapes=('dot','bar','sq','L'),shape_w=None,px=2,hold=(14,24),
                 depth=(0,10),jit=0.08,mirror_x=0.0,spawn=1,trail=0,twinkle=0,tumble=2,cscale=1.0,shade=0.62,
                 hot_steps=0,glow=None,mirror_depth=True,x0=(0,3),mirror_shape=False,exact=False,until=None):
        """start: tic of first launch (canvas tic of the caller's render loop); n pieces in mirrored pairs, `spawn` tics apart
        per pair-group; z0 spawn height (map units); speed (units/tic); spread: launch angle range from vertical (deg);
        palettes: list of (weight, [rgb...]) stepped by age every cool tics; hold: tics a settled piece stays before blinking out;
        depth: px below the floor line where it lands (perspective scatter on the floor plane)."""
        r=random.Random(seed); s.exact=exact; s.start=start; s.bx=bx; s.floor=floor; s.u=unit; s.px=px; s.cs=cscale
        s.trail=trail; s.twinkle=twinkle; s.shade=shade; s.glow=glow
        palettes=palettes or [(1,[(255,240,200),(255,170,40),(200,70,10),(110,36,14),(50,30,26)])]
        W=[w for w,_ in palettes]
        s.pieces=[]
        for i in range(n//2):
            t0=start+int(i*spawn)
            ang=math.radians(r.uniform(*spread)); v=r.uniform(*speed)*unit
            z=r.uniform(*z0)*unit; xo=r.uniform(*x0)*unit
            pal=r.choices(palettes,weights=W)[0][1]
            d=r.uniform(*depth); bb=r.uniform(*bounce)
            pshp=np.array(SHAPES[r.choices(shapes,weights=shape_w)[0] if shape_w else r.choice(shapes)],bool)
            ph=r.randrange(4); hl=r.randint(*hold); cl=r.randint(*cool); tw0=r.randrange(max(1,twinkle))
            for sgn in (-1,1):
                j=1+r.uniform(-jit,jit)
                vx=sgn*math.sin(ang)*v*j; vz=math.cos(ang)*v*(1+r.uniform(-jit,jit))
                if exact: vx=sgn*math.sin(ang)*v; vz=math.cos(ang)*v
                shp=np.array(SHAPES[r.choices(shapes,weights=shape_w)[0] if shape_w else r.choice(shapes)],bool)
                if sgn>0 and r.random()<.5: shp=shp[:,::-1]
                if mirror_shape: shp=pshp
                dd=d if mirror_depth else r.uniform(*depth)
                path=s._sim(bx+sgn*xo,z,vx,vz,grav*unit,bb,friction,dd,shp.shape[0]*px)
                hold_=hl if exact else r.randint(*hold)
                s.pieces.append(dict(t0=t0,path=path,shp=shp,pal=pal,cool=cl if exact else r.randint(*cool),ph=ph if exact else r.randrange(4),sg=sgn,mir=mirror_shape,
                                     end=len(path)+hold_,tw=(tw0 if exact else r.randrange(max(1,twinkle))) if twinkle else 0,hs=hot_steps))
        if until:   # everything gone by `until` tics after start (staggered over the last 6, pairs together)
            for k in range(0,len(s.pieces),2):
                cap=until-6+(k//2)%7-(s.pieces[k]['t0']-start)
                for p in s.pieces[k:k+2]: p['end']=max(1,min(p['end'],cap))
        s.len=max(p['t0']+p['end'] for p in s.pieces)-start
    def _sim(s,x,z,vx,vz,g,b,fr,depth,h):
        path=[]; rest=0; land=None; nb=0
        for t in range(200):
            if land is None and t>0 and z<=0: land=t
            path.append((x,z,rest>0))
            if rest:
                rest+=1
                if rest>3: break
                continue
            if z<=0 and vz==0:            # sliding on the floor
                x+=vx; vx*=0.45
                if abs(vx)<0.5: rest=1
                continue
            x+=vx; z+=vz; vz-=g; vx*=0.985
            if z<=0:
                z=0
                if abs(vz)*b>1.3*g and nb<4: vz=-vz*b; vx*=fr; nb+=1
                else: vz=0; vx*=fr
        land=land or len(path)
        # depth (px below the floor line) eases in over the first flight, so pieces leave the blast and land in front of it
        return [(px,pz,st,depth*min(1,i/land)) for i,(px,pz,st) in enumerate(path)]
    def draw(s,c,t):
        for p in s.pieces:
            dt=t-p['t0']
            if dt<0 or dt>=p['end']: continue
            path=p['path']; x,z,st,d=path[min(dt,len(path)-1)]
            settled=dt>=len(path)-1
            shp=p['shp']
            if not settled and p['ph']%2==0 and (dt//2)%2: shp=np.rot90(shp)   # tumble
            elif not settled and (dt//2+p['ph'])%4>=2: shp=shp[::-1]
            if p['sg']>0 and p['mir']: shp=shp[:,::-1]
            pal=p['pal']; ci=min(len(pal)-1,dt//p['cool'])
            col=np.array(pal[ci],float)
            if s.twinkle and settled and (dt+p['tw'])%s.twinkle==0: col=np.array(pal[max(0,ci-3)],float)
            # blink out: last 4 tics of hold flash off/on
            rem=p['end']-dt
            if rem<=4 and rem%2==0: continue
            # trail: one or two darker pixels behind while flying fast
            if s.trail and not settled and dt>0:
                for k in range(1,s.trail+1):
                    px0,pz0,_,_=path[max(0,dt-k)]
                    tx=(px0+x)/2 if k==1 else px0; tz=(pz0+z)/2 if k==1 else pz0
                    if abs(px0-x)+abs(pz0-z)<3: break
                    tc=np.array(pal[min(len(pal)-1,ci+k)],float)
                    s._put(c,np.ones((1,1),bool),tx,tz,d,tc)
            s._put(c,shp,x,z,d,col)
    def _put(s,c,shp,x,z,d,col):
        h,w=shp.shape; P=s.px
        y_floor=s.floor+int(round(d))
        oy=int(round(y_floor-z))-h*P+1; ox=int(round(x-w*P/2))
        dark=col*s.shade
        for yy in range(h):
            for xx in range(w):
                if not shp[yy,xx]: continue
                cc=dark if (h>1 and yy==h-1 and w>1) else col
                y0,x0=oy+yy*P,ox+xx*P
                if 0<=x0 and x0+P<=c.shape[1] and 0<=y0 and y0+P<=c.shape[0]:
                    c[y0:y0+P,x0:x0+P]=cc*s.cs
