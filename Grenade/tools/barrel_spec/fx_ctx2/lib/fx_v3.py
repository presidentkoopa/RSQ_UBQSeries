"""v3 renderer for set A: fx.render (unchanged) plus `back` items drawn BEFORE the sprite layers, so debris that is
still inside a fireball is covered by it and only shows once it flies clear (no specks floating on top of the flash)."""
import numpy as np
from PIL import Image
import fx
from fx import CW,CH,FY,BX,blit
def render(layers,sparks=(),back=(),T=None,light=None,pause=14):
    T=T or max([l.end() for l in layers]+[s.end() for s in list(sparks)+list(back)])+pause
    out=[]
    for t in range(T):
        c=np.zeros((CH,CW,3),np.float32); c[:]=(0.035,0.03,0.04)
        c[FY:]=(0.07,0.065,0.07)
        L=light(t) if light else 0
        if L>0:
            yy,xx=np.mgrid[FY:CH,0:CW]; d=np.sqrt(((xx-BX)/(110*fx.BAND_R))**2+((yy-FY)/(26*fx.BAND_R))**2)
            band=np.select([d<0.35,d<0.7,d<1.0],[0.55,0.32,0.14],0)
            c[FY:]+=band[...,None]*np.array([1.0,0.55,0.2])*min(L,1.0)
        c[FY:FY+1]=np.maximum(c[FY:FY+1],(0.32,0.30,0.30))
        for b in back: b.draw(c,t)
        for l in sorted(layers,key=lambda l:l.z):
            if l.floor: continue
            r=l.at(t)
            if r: blit(c,*r,l.add,l.gain,occ=fx.OCC)
        for s in sparks: s.draw(c,t)
        for l in layers:
            if not l.floor: continue
            r=l.at(t)
            if r: blit(c,*r,l.add,l.gain)
        out.append(Image.fromarray((np.clip(c,0,1)*255).astype(np.uint8)))
    return out
