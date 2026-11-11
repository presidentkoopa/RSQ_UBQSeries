# crop.py out.jpg box(x0,y0,x1,y1) scale run frame... : crops of frames stacked vertically, labelled
import sys
from PIL import Image, ImageDraw
out=sys.argv[1]; box=tuple(int(v) for v in sys.argv[2].split(',')); sc=float(sys.argv[3]); run=sys.argv[4]; fs=sys.argv[5:]
ims=[]
for f in fs:
    lab=f
    if ':' in f: f,lab=f.split(':',1)
    im=Image.open('%s/frames/%s.jpg'%(run,f)).convert('RGB').crop(box)
    im=im.resize((int(im.width*sc),int(im.height*sc)),Image.LANCZOS)
    ImageDraw.Draw(im).text((4,4),lab,fill=(255,255,0)); ims.append(im)
W=max(i.width for i in ims); S=Image.new('RGB',(W,sum(i.height for i in ims)))
y=0
for i in ims: S.paste(i,(0,y)); y+=i.height
S.save(out,quality=90); print(out,S.size)
