import numpy as np, sys
from PIL import Image
from scipy import ndimage as ndi
def comps(path,y0,y1,x0=0,x1=None,grow=3,minpx=6):
    im=Image.open(path).convert('RGBA'); a=np.array(im)
    x1=x1 or a.shape[1]
    sub=a[y0:y1,x0:x1]; m=sub[...,3]>0
    # treat pure background color as empty too
    lab,n=ndi.label(ndi.binary_dilation(m,iterations=grow))
    out=[]
    for i,sl in enumerate(ndi.find_objects(lab)):
        mm=(lab[sl]==i+1)&m[sl]
        if mm.sum()<minpx: continue
        out.append((sl[1].start+x0,sl[0].start+y0,sl[1].stop+x0,sl[0].stop+y0,int(mm.sum())))
    out.sort(); return out
if __name__=='__main__':
    p=sys.argv[1]; y0,y1=int(sys.argv[2]),int(sys.argv[3])
    a=np.array(Image.open(p).convert('RGBA')); print('corner',a[0,0],a[5,5])
    for c in comps(p,y0,y1,grow=int(sys.argv[4]) if len(sys.argv)>4 else 3): print(c)
