import numpy as np,os
from PIL import Image
D='/home/claude/rsq_ubqseries/design/assets/fx_sheets/reactorcore_minipack/'
for n,name in [(3,'rc_cres'),(4,'rc_ybrown')]:
    im=Image.open(D+f'explosion ({n}).png').convert('RGBA'); c=im.width//4
    d=f'cut/{name}'; os.makedirs(d,exist_ok=True)
    for i in range(16):
        f=im.crop(((i%4)*c,(i//4)*c,(i%4+1)*c,(i//4+1)*c)); f.save(f'{d}/{i:02d}.png')
    print(name,np.unique(np.array(im)[...,3]))
