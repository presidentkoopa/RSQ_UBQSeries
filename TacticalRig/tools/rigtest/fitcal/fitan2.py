exec(open('fitan.py').read().split("for k,(X,px) in enumerate(obs)")[0].replace("best=least_squares","best=least_squares"))
import itertools
U='/mnt/user-data/uploads/__CurrentRotationDONOTDELETE'
pk=mp.Pak('/home/claude/wt_bd/BD22_VR-Reloaded_2.0.5t.pk3')
data=pk.get('models/bd/BrutalPistol/BrutalPistol.md3')
def md3_mesh(data, frame):
    ident, ver, name, flags, nfr, ntags, nsurf, nskins, ofr, otag, osurf, oend = struct.unpack_from('<4si64s9i', data, 0)
    V=[];T=[];o=osurf
    for _ in range(nsurf):
        sid, sname, sflags, snfr, nshad, nverts, ntris, otris, oshad, ost, oxyz, oend2 = struct.unpack_from('<4s64s10i', data, o)
        base=len(V)
        for t in range(ntris):
            T.append([base+i for i in struct.unpack_from('<3i', data, o+otris+t*12)])
        b=o+oxyz+frame*nverts*8
        for v in range(nverts):
            x,y,z,_n=struct.unpack_from('<hhhh',data,b+v*8); V.append((x/64.,y/64.,z/64.))
        o+=oend2
    return np.array(V),np.array(T)
V,T=md3_mesh(data,7)
sm=np.array([-1.0,1,1]); off=np.array([0.82,-8.333,-1.408]); ao,po,ro=3.854,3.363,10.974
def rotoff(P): return np.array([mp.rot(tuple(p),ao,po,ro) for p in P])
MODEL={'tool':rotoff(V*sm)+off/sm, 'eng':sm*(rotoff(V)+off/sm), 'hyb':rotoff(V*sm)+off, 'eng2':sm*rotoff(V)+off}
bg=np.asarray(Image.open(FR%24).convert('RGB')).astype(int)
def obsmask(im):
    d=np.abs(im.astype(int)-bg).sum(-1)
    m=d>60
    r,g,b=im[...,0].astype(int),im[...,1].astype(int),im[...,2].astype(int)
    dots=((r>150)&(b>150)&(g<120))|((r>200)&(g>200))|((b>200)&(r<150))
    return m&~dots
def render(Pw):
    uv=project(Pw,cam)
    img=Image.new('L',(W,H),0); dr=ImageDraw.Draw(img)
    for t in T: dr.polygon([tuple(uv[i]) for i in t],fill=1)
    return np.asarray(img)>0
def R_of(a,p,r,kind):
    if kind=='ypr':
        F,L,U_=basis(a,p,r); return np.stack([F,L,U_],1)
results={}
masks=[obsmask(im) for im in ims]
for k,(P,m) in enumerate(zip(poses,masks)):
    for mk,M in MODEL.items():
        for rs in (1,-1):
            for sq in ('none','world','model'):
                Mm=M.copy()
                if sq=='model': Mm[:,2]/=1.2
                R=R_of(P['a'],P['p'],rs*P['r'],'ypr')
                Wp=(R@(P['s']*Mm).T).T
                if sq=='world': Wp[:,2]/=1.2
                pm=render(P['org']+Wp)
                # compare in a box around both
                inter=(pm&m).sum(); uni=(pm|m).sum()
                results.setdefault((mk,rs,sq),[]).append(inter/uni)
for key,v in sorted(results.items(),key=lambda kv:-np.mean(kv[1])):
    print(key,'mean %.3f'%np.mean(v),' '.join('%.2f'%x for x in v))
