import numpy as np
from PIL import Image
from kvx import load
dims,vox,pal=load('/home/claude/rsq_ubqseries/Monsters/voxels/BAR1A.kvx')
xs,ys,zs=dims; cx,cy=(xs-1)/2,(ys-1)/2
T=0.38  # tilt: how much of the top shows
H=int(zs+ys*T)+2
img=np.zeros((H,xs,4),np.uint8)
for (x,y,z),c in sorted(vox.items(),key=lambda kv:(-kv[0][1],kv[0][2])):
    sy=int(round(z+(ys-1-y)*T)); 
    r,g,b=pal[c]
    nx=(x-cx)/max(cx,1); ny=(y-cy)/max(cy,1)
    top = (z,x,y) and (x,y,z-1) not in vox
    l=0.75-0.45*nx-0.25*ny
    if top: l=1.1
    img[sy,x]=[min(255,r*l),min(255,g*l),min(255,b*l),255]
im=Image.fromarray(img); im.save('cut/barrel.png'); print(im.size)
im.resize((im.width*6,im.height*6),Image.NEAREST).save('prev/barrel6.png')
