import numpy as np
from PIL import Image
from scipy import ndimage as nd
RUF='/home/claude/rsq_ubqseries/design/assets/fx_sheets/fx_sheet_rufaswan_magma.png'
def key_white(path):
    a=np.array(Image.open(path).convert('RGBA')).astype(np.int16)
    w=(a[...,:3]==255).all(2)
    lab,n=nd.label(w)
    border=set(np.unique(np.concatenate([lab[0],lab[-1],lab[:,0],lab[:,-1]])))-{0}
    bg=np.isin(lab,list(border))
    # also large white components (>2000px) are bg islands
    sizes=nd.sum(w,lab,range(1,n+1))
    big=[i+1 for i,s in enumerate(sizes) if s>3000]
    bg|=np.isin(lab,big)
    out=a.copy().astype(np.uint8); out[bg,3]=0
    return out,bg
def bands(mask):
    r=mask.any(1); res=[];y=0
    while y<len(r):
        if r[y]:
            s=y
            while y<len(r) and r[y]: y+=1
            res.append((s,y))
        else: y+=1
    return res
def blobs(rgba,y0,y1,x0=0,x1=None,gap=3,minpx=6):
    """cut sprites in band by column projection; returns list of (x0,y0,x1,y1)"""
    sub=rgba[y0:y1,x0:x1]
    m=sub[...,3]>0
    lab,n=nd.label(nd.binary_dilation(m,iterations=gap))
    objs=nd.find_objects(lab)
    res=[]
    for i,o in enumerate(objs):
        mm=(lab[o]==i+1)&m[o]
        if mm.sum()<minpx: continue
        ys,xs=o
        res.append((xs.start+x0,ys.start+y0,xs.stop+x0,ys.stop+y0))
    res.sort(key=lambda b:b[0])
    return res
