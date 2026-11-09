import sys,os
from PIL import Image,ImageDraw
out=sys.argv[1]; sc=int(sys.argv[2]); rows=sys.argv[3:]
ims=[[Image.open(f'{r}/{f}').convert('RGBA') for f in sorted(os.listdir(r))] for r in rows]
W=max(sum(i.width*sc+6 for i in row) for row in ims); H=sum(max(i.height for i in row)*sc+14 for row in ims)
S=Image.new('RGBA',(W,H),(20,20,30,255)); d=ImageDraw.Draw(S); y=0
for row in ims:
    x=0; h=max(i.height for i in row)*sc
    for k,i in enumerate(row):
        i=i.resize((i.width*sc,i.height*sc),Image.NEAREST); S.alpha_composite(i,(x,y)); d.text((x,y+h),str(k),fill=(255,255,0)); x+=i.width+6
    y+=h+14
S.convert('RGB').save(out)
