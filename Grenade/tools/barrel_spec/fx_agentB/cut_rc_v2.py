# v2: cut two more Reactorcore 64px sheets (pixel art) into 16 frames each
import os
from PIL import Image
D='/home/claude/rsq_ubqseries/design/assets/fx_sheets/reactorcore_minipack/'
for n in (7,10):
    im=Image.open(D+f'explosion ({n}).png').convert('RGBA'); c=im.width//4
    d=f'cut/rc_x{n}'; os.makedirs(d,exist_ok=True)
    for i in range(16): im.crop(((i%4)*c,(i//4)*c,(i%4+1)*c,(i//4+1)*c)).save(f'{d}/{i:02d}.png')
