exec(open('fitan2.py').read().split("results={}")[0])
from scipy import ndimage
from scipy.optimize import minimize
def obsmask2(im):
    d=np.abs(im.astype(int)-bg).sum(-1)
    m=d>45
    m=ndimage.binary_opening(m,iterations=1)
    m=ndimage.binary_closing(m,iterations=2)
    m=ndimage.binary_fill_holes(m)
    lab,n=ndimage.label(m)
    if n>1:
        sizes=ndimage.sum(m,lab,range(1,n+1)); keep=np.argmax(sizes)+1; m=lab==keep
    return m
OM=[obsmask2(im) for im in ims]
def pred(k,P,M,rs,sq,scale,delta):
    Mm=M+delta
    Mm=Mm.copy()
    if sq=='model': Mm[:,2]/=1.2
    F,L,U_=basis(P['a'],P['p'],rs*P['r']); R=np.stack([F,L,U_],1)
    # the origin as placed (it already has the centring for the table's centre)
    Wp=(R@(P['s']*scale*Mm).T).T
    if sq=='world': Wp[:,2]/=1.2
    return render(P['org']+Wp)
def score(x,M,rs,sq,which):
    scale=x[0]; delta=np.array(x[1:4])
    v=[]
    for k in which:
        pm=pred(k,poses[k],M,rs,sq,scale,delta); om=OM[k]
        v.append((pm&om).sum()/max(1,(pm|om).sum()))
    return np.array(v)
import sys
def rv(P,a,p,r): return np.array([mp.rot(tuple(q),a,p,r) for q in P])
MODEL['G_sq']=off+sm*rv(V*np.array([1,1,1/1.2]),ao,-po,ro)
MODEL['G_no']=off+sm*rv(V,ao,-po,ro)
for k in ['G_sq','G_no']:
    M=MODEL[k]; bb=[(M[:,i].min(),M[:,i].max()) for i in range(3)]
    print(k,'centre',np.round([(a+b)/2 for a,b in bb],2),'IoU0',np.round(score([1,0,0,0],M,1,'none',range(8)),2),flush=True)
for mk in ['G_sq','G_no']:
  for rs in (1,):
    for sq in ('none',):
        x0=[1.0,0,0,0]
        r=minimize(lambda x:-score(x,MODEL[mk],rs,sq,range(8)).mean(),x0,method='Nelder-Mead',options=dict(initial_simplex=[x0,[1.1,0,0,0],[1,3,0,0],[1,0,3,0],[1,0,0,3]],maxiter=300,xatol=0.01,fatol=1e-4))
        s=score(r.x,MODEL[mk],rs,sq,range(8))
        print(mk,rs,sq,'x',np.round(r.x,2),'mean %.3f'%s.mean(),' '.join('%.2f'%v for v in s),flush=True)
