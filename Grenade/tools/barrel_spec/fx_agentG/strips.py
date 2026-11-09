import glob,sys
from PIL import Image,ImageDraw
keys=sys.argv[2:]; out=sys.argv[1]
rows=[]
for k in keys:
    fs=sorted(glob.glob(f'/tmp/eosfr/{k}/*.png'))+sorted(glob.glob(f'/tmp/fx_agentB/cut/{k}/*.png'))
    if not fs: fs=sorted(glob.glob(k))
    ims=[Image.open(f).convert('RGBA') for f in fs]
    S=3; h=max(i.height for i in ims)*S+14; w=sum(i.width*S+4 for i in ims)+80
    r=Image.new('RGB',(w,h),(20,20,30)); d=ImageDraw.Draw(r); d.text((2,2),k.split('/')[-1][:12],fill=(255,255,0)); x=80
    for j,i in enumerate(ims):
        bg=Image.new('RGBA',i.size,(20,20,30,255)); bg.alpha_composite(i)
        r.paste(bg.convert('RGB').resize((i.width*S,i.height*S),Image.NEAREST),(x,12)); d.text((x,0),str(j),fill=(150,150,150)); x+=i.width*S+4
    rows.append(r)
W=max(r.width for r in rows); H=sum(r.height for r in rows)
o=Image.new('RGB',(W,H)); y=0
for r in rows: o.paste(r,(0,y)); y+=r.height
o.save(out)
