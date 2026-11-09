from cutlib import *
import os
a,bg=key_white(RUF)
def segs(y0,y1,g=4):
    c=(a[y0:y1,:,3]>0).any(0); S=[];x=0
    while x<len(c):
        if c[x]:
            s=x
            while x<len(c) and (c[x] or c[x:x+g].any()): x+=1
            S.append((s,x))
        else: x+=1
    return S
def save(name,y0,y1,S,keyin=()):
    d=f'cut/{name}'; os.makedirs(d,exist_ok=True)
    for f in os.listdir(d): os.remove(f'{d}/{f}')
    for i,(x0,x1) in enumerate(S):
        t=a[y0:y1,x0:x1].copy()
        if i in keyin: t[(t[...,:3]==255).all(2),3]=0
        m=t[...,3]>0; ys=np.where(m.any(1))[0]; xs=np.where(m.any(0))[0]
        t=t[ys[0]:ys[-1]+1, xs[0]:xs[-1]+1]
        Image.fromarray(t).save(f'{d}/{i:02d}.png')
save('ruf_bubble',124,220,segs(124,220)[:4])
save('ruf_star',124,220,segs(124,220)[4:])
save('ruf_dome',224,273,segs(224,273),keyin=(7,8,9))
S=segs(276,325)
save('ruf_cluster',276,325,S[:3]+[(160,209),(212,261)],keyin=(0,1))
save('ruf_pring',276,325,S[8:11])
save('ruf_yflash',328,369,segs(328,369)[3:])
save('ruf_ypuff',372,421,segs(372,421),keyin=(5,6,7))
S=segs(668,709)
save('ruf_dust',668,709,S[:6],keyin=(1,2,3,4))
save('ruf_cres',668,709,S[6:])
