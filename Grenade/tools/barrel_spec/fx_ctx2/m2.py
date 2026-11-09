import glob,os,sys
from PIL import Image, ImageDraw
pre=sys.argv[1].split(',')
ims=[]
for p in pre:
    for f in sorted(glob.glob(f'/home/claude/rsq_ubqseries/Monsters/sprites/meatgrinder/{p}*')):
        if f.endswith('.dat'): continue
        try: ims.append((os.path.basename(f)[:6],Image.open(f).convert("RGBA")))
        except Exception: pass
cols=10; cw=130; ch=140
rows=(len(ims)+cols-1)//cols
M=Image.new('RGB',(cols*cw,rows*ch),(40,40,48)); d=ImageDraw.Draw(M)
for i,(n,im) in enumerate(ims):
    s=min(3,120//max(im.size)) or 1
    im=im.resize((im.width*s,im.height*s),Image.NEAREST); x=(i%cols)*cw; y=(i//cols)*ch
    M.paste(im,(x+2,y+2),im); d.text((x+2,y+126),f'{n} {im.width//s}x{im.height//s}',fill=(220,220,120))
M.save(sys.argv[2])
