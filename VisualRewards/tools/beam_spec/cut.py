from PIL import Image; import numpy as np
SPEC = __import__('os').path.dirname(__import__('os').path.abspath(__file__))   # was /tmp/fx_beam
SHEET='/mnt/user-data/uploads/9cbabdfd-image.png'
im=np.asarray(Image.open(SHEET).convert('RGB')).astype(np.uint8)
def split_cols(x0,y0,x1,y1,gap=3,minw=8):
    m=im[y0:y1,x0:x1].max(-1)>12; col=m.any(0); out=[]; s=None; run=0
    for i,c in enumerate(list(col)+[False]*gap):
        if c:
            if s is None: s=i
            run=0; e=i
        elif s is not None:
            run+=1
            if run>=gap:
                if e-s+1>=minw: out.append((x0+s,x0+e+1)); 
                s=None
    return out
def cut(x0,y0,x1,y1):
    a=im[y0:y1,x0:x1]; m=a.max(-1)>12
    ys,xs=np.nonzero(m); a=a[ys.min():ys.max()+1,xs.min():xs.max()+1]; m=m[ys.min():ys.max()+1,xs.min():xs.max()+1]
    rgba=np.dstack([a,(m*255).astype(np.uint8)]); return Image.fromarray(rgba)
if __name__=='__main__':
    import os
    os.makedirs(SPEC + '/cut/blue',exist_ok=True); os.makedirs(SPEC + '/cut/skull',exist_ok=True)
    boxes={'b_dome':(833,2913,966,2985),'b_spike':(761,2987,926,3105),'b_burst':(768,3112,929,3260)}
    for i,(a,b) in enumerate(split_cols(756,3269,1000,3515)): boxes[f'b_col{i}']=(a,3269,b,3515)
    boxes['b_col2']=(790,3527,954,3772)
    for k,v in boxes.items(): c=cut(*v); c.save(f'{SPEC}/cut/blue/{k}.png'); print(k,v,c.size)
    rows=[(445,656),(663,862),(865,1063)]
    n=0
    for r,(y0,y1) in enumerate(rows):
        xr=(0,1000) if r<2 else (0,420)
        for a,b in split_cols(xr[0],y0,xr[1],y1,gap=4,minw=20):
            c=cut(a,y0,b,y1); c.save(f'{SPEC}/cut/skull/s{r}_{n:02d}.png'); print(r,n,(a,y0,b,y1),c.size); n+=1

from scipy import ndimage as nd
def cut_clean(x0,y0,x1,y1,thr=12):
    a=im[y0:y1,x0:x1]; m=a.max(-1)>thr
    l,n=nd.label(nd.binary_dilation(m,iterations=2))
    # keep components whose bbox centre is inside middle 70% horizontally
    keep=np.zeros_like(m); W=x1-x0
    for i,s in enumerate(nd.find_objects(l)):
        cx=(s[1].start+s[1].stop)/2
        if 0.15*W<cx<0.85*W or (s[1].stop-s[1].start)>0.5*W: keep|=(l==i+1)
    m&=keep
    ys,xs=np.nonzero(m); sl=(slice(ys.min(),ys.max()+1),slice(xs.min(),xs.max()+1))
    return Image.fromarray(np.dstack([a[sl],(m[sl]*255).astype(np.uint8)]))
def run2():
    import os,glob
    for f in glob.glob(SPEC + '/cut/*/*.png'): os.remove(f)
    B={'b_dome':(833,2913,966,2985),'b_spike':(761,2987,926,3105),'b_burst':(768,3112,929,3260),
       'b_col0':(756,3269,857,3515),'b_col1':(857,3269,1000,3515),'b_col2':(790,3527,954,3772)}
    for k,v in B.items(): c=cut_clean(*v); c.save(f'{SPEC}/cut/blue/{k}.png'); print(k,c.size)
    r0=[8,172,350,520,642,757,879,998]; r1=[0,113,216,325,440,555,671,780,890,1000]
    S=[]
    for i in range(len(r0)-1): S.append((r0[i],500 if i<2 else 445,r0[i+1],656))
    for i in range(len(r1)-1): S.append((r1[i],663,r1[i+1],862))
    for a,b in [(0,122),(122,245),(245,300),(300,350),(350,410)]: S.append((a,865,b,1063))
    for i,v in enumerate(S): c=cut_clean(*v); c.save(f'{SPEC}/cut/skull/s{i:02d}.png'); print(i,v,c.size)
if __name__=='__main__': run2()
