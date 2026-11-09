import sys,glob
from PIL import Image, ImageDraw
name=sys.argv[1]; a,b,step=int(sys.argv[2]),int(sys.argv[3]),int(sys.argv[4]) if len(sys.argv)>4 else 1
crop=(30,0,290,290)
fs=[f'/tmp/fx_agentA/look/{name}_{i:03d}.png' for i in range(a,b,step)]
fs=[f for f in fs if glob.glob(f)]
cols=8; w,h=crop[2]-crop[0],crop[3]-crop[1]
o=Image.new('RGB',(cols*w,((len(fs)+cols-1)//cols)*(h+12)),(60,60,60)); d=ImageDraw.Draw(o)
for i,f in enumerate(fs):
    x=(i%cols)*w; y=(i//cols)*(h+12); o.paste(Image.open(f).crop(crop),(x,y+12)); d.text((x+2,y),f[-7:-4],fill=(255,255,0))
o.save(f'/tmp/fx_agentA/look/rev_{name}.png'); print(o.size)
