import struct,numpy as np
from PIL import Image
def load(p):
    b=open(p,'rb').read()
    n,xs,ys,zs,xp,yp,zp=struct.unpack('<7i',b[:28])
    o=28; xoff=struct.unpack(f'<{xs+1}i',b[o:o+4*(xs+1)]); o+=4*(xs+1)
    xyoff=[struct.unpack(f'<{ys+1}H',b[o+i*2*(ys+1):o+(i+1)*2*(ys+1)]) for i in range(xs)]
    o+=xs*2*(ys+1); base=28
    pal=np.frombuffer(b[-768:],np.uint8).reshape(256,3).astype(int)*4
    V=np.full((xs,ys,zs),-1,int)
    for x in range(xs):
        for y in range(ys):
            p=base+xoff[x]+xyoff[x][y]; e=base+xoff[x]+xyoff[x][y+1]
            while p<e:
                zt,zl,_=b[p],b[p+1],b[p+2]; p+=3
                for k in range(zl): V[x,y,zt+k]=b[p+k]
                p+=zl
    return V,pal
def side(p):
    V,pal=load(p); xs,ys,zs=V.shape
    img=np.zeros((zs,xs,4),np.uint8)
    for x in range(xs):
        for z in range(zs):
            col=V[x,:,z]; idx=np.where(col>=0)[0]
            if len(idx):
                c=pal[col[idx[0]]]
                # simple shading by x (cylinder)
                f=0.55+0.6*np.sin(np.pi*(x+0.5)/xs)**0.7
                img[z,x,:3]=np.clip(c*f,0,255); img[z,x,3]=255
    return Image.fromarray(img)
if __name__=='__main__':
    im=side('/home/claude/rsq_ubqseries/Monsters/voxels/BAR1A.kvx'); print(im.size)
    im.save('/tmp/fx_ctx1/look/look/barrel_side.png'); im.resize((im.width*6,im.height*6),Image.NEAREST).save('/tmp/fx_ctx1/look/look/barrel_big.png')
