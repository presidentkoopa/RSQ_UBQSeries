import sys
from PIL import Image, ImageDraw
fs=[int(x) for x in sys.argv[2].split(',')]; sc=int(sys.argv[3]) if len(sys.argv)>3 else 1
ims=[Image.open(f'/tmp/fx_mega2/look/f{i:03d}.png') for i in fs]
W=440*sc; S=Image.new('RGB',(W*len(ims),440*sc+12),(30,30,30)); d=ImageDraw.Draw(S)
for k,(i,im) in enumerate(zip(fs,ims)):
    S.paste(im.resize((W,440*sc),Image.NEAREST),(k*W,12)); d.text((k*W+3,0),f'f{i} tic{i-20:+d}',fill=(255,255,0))
S.save(sys.argv[1])
