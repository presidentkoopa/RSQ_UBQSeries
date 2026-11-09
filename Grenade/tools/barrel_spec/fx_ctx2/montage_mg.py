import glob,os
from PIL import Image, ImageDraw
fs=sorted(f for f in glob.glob('/home/claude/rsq_ubqseries/Monsters/sprites/meatgrinder/*') if not f.endswith('.dat'))
ims=[]
for f in fs:
    try: ims.append((os.path.basename(f)[:6],Image.open(f).convert('RGBA')))
    except Exception as e: pass
cols=24; cw=64; ch=74
rows=(len(ims)+cols-1)//cols
M=Image.new('RGB',(cols*cw,rows*ch),(40,40,48)); d=ImageDraw.Draw(M)
for i,(n,im) in enumerate(ims):
    im.thumbnail((60,60),Image.NEAREST); x=(i%cols)*cw; y=(i//cols)*ch
    M.paste(im,(x+2,y+2),im); d.text((x+2,y+62),n,fill=(220,220,120))
M.save('/tmp/fx_ctx2/look/mg_montage.png'); print(len(ims),M.size)
