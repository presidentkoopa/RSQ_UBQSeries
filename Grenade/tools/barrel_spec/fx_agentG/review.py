import sys,glob
from PIL import Image,ImageDraw
name=sys.argv[1]; tics=[int(x) for x in sys.argv[2].split(',')]; out=sys.argv[3]
crop=tuple(int(x) for x in sys.argv[4].split(',')) if len(sys.argv)>4 else (0,0,640,420)
cols=4; w=crop[2]-crop[0]; h=crop[3]-crop[1]
S=Image.new('RGB',(cols*w,((len(tics)+cols-1)//cols)*h)); d=ImageDraw.Draw(S)
for i,t in enumerate(tics):
    f=Image.open(f'look/{name}_{t:+04d}.png').crop(crop); S.paste(f,((i%cols)*w,(i//cols)*h)); d.text(((i%cols)*w+4,(i//cols)*h+4),f'tic {t}',fill=(255,255,0))
S.save(out)
