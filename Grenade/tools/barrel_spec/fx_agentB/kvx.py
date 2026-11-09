import struct,numpy as np
from PIL import Image
def load(p):
    b=open(p,'rb').read()
    nb,xs,ys,zs=struct.unpack_from('<4i',b,0)
    o=4+12+12
    xoff=struct.unpack_from(f'<{xs+1}i',b,o); o+=4*(xs+1)
    xyoff=[struct.unpack_from(f'<{ys+1}H',b,o+i*2*(ys+1)) for i in range(xs)]
    o2=o+xs*2*(ys+1)
    pal=np.frombuffer(b[-768:],np.uint8).reshape(256,3).astype(int)*255//63
    vox={}
    base=28+4*(xs+1)+xs*2*(ys+1)
    for x in range(xs):
        for y in range(ys):
            s=base+xoff[x]-xoff[0]+xyoff[x][y]; e=base+xoff[x]-xoff[0]+xyoff[x][y+1]
            while s<e:
                zt,zl,cull=b[s],b[s+1],b[s+2]; cols=b[s+3:s+3+zl]
                for k,c in enumerate(cols): vox[(x,y,zt+k)]=c
                s+=3+zl
    return (xs,ys,zs),vox,pal
dims,vox,pal=load('/home/claude/rsq_ubqseries/Monsters/voxels/BAR1A.kvx')
xs,ys,zs=dims; print(dims,len(vox))
img=np.zeros((zs,xs,4),np.uint8); dep=np.full((zs,xs),999)
for (x,y,z),c in vox.items():
    if y<dep[z,x]:
        dep[z,x]=y; r,g,bb=pal[c]
        # simple shade by depth
        img[z,x]=[r,g,bb,255]
# shade: cylinder lighting by x
cx=xs/2
for x in range(xs):
    f=0.55+0.6*max(0,1-abs((x-cx*0.8)/(cx)))**0.7
    img[:,x,:3]=np.clip(img[:,x,:3]*f,0,255)
im=Image.fromarray(img); im.save('cut/barrel_side.png'); print(im.size)
im.resize((im.width*4,im.height*4),Image.NEAREST).save('prev/barrel4.png')
