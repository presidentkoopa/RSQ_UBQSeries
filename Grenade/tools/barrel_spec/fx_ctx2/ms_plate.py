"""Run the other designer's Metal Slug mega blast (/tmp/fx_mslug/mega.py, imported read-only) as a plate:
same layers/schedule, rendered over black and over white with no floor, light or barrel -> C (colour) and O (cover).
Separate process because mega.py's lib/fx.py shares the module name with set A's fx.py."""
import sys; sys.path.insert(0,'/tmp/fx_mslug')
import numpy as np, mega
from mega import *
def rend(bgv):
    L, LB, FL, S, B, BF, light, lcol = build()
    L=[l for l in L if l.name!='barrel']
    T = max([T0 + MS_END] + [l.end() for l in L + LB + FL] + [s.end() for s in S + B + BF]) + 2
    out=[]
    for t in range(T):
        c = np.zeros((CH, CW, 3), np.float32); c[:] = bgv
        for b in B: b.draw(c, t)
        for l in LB:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain, clip_floor=True)
        ms = ms_at(t - T0)
        if ms:
            img, ox, oy = ms; blit(c, img, ox, oy, 1.0, False)
        for l in L:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain, clip_floor=True)
        for s in S: s.draw(c, t)
        for b in BF: b.draw(c, t)
        for l in FL:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain)
        out.append(c)
    lt=np.array([light(t) for t in range(T)]); lc=np.array([lcol(t) for t in range(T)])
    return np.array(out),lt,lc
c0,lt,lc=rend(0.0); c1,_,_=rend(1.0)
O=np.clip(1-(c1-c0),0,1).mean(-1)
np.savez_compressed('/tmp/fx_ctx2/cache/ms_plate.npz',C=c0.astype(np.float16),O=O.astype(np.float16),light=lt,lcol=lc,T0=T0,BX=BX,FY=FY)
print(c0.shape,T0,BX,FY)
