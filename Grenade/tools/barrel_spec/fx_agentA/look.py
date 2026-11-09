import sys,glob,os
from PIL import Image,ImageDraw
# preview a list of PNGs on dark bg
d=sys.argv[1]; pat=sys.argv[2]; out=sys.argv[3]; cell=int(sys.argv[4]) if len(sys.argv)>4 else 64
fs=sorted(glob.glob(os.path.join(d,pat)))
cols=12; rows=(len(fs)+cols-1)//cols
sh=Image.new('RGB',(cols*cell,rows*(cell+10)),(30,0,40))
dr=ImageDraw.Draw(sh)
for i,f in enumerate(fs):
    try: im=Image.open(f).convert('RGBA')
    except Exception as e: continue
    s=min(cell/im.width,cell/im.height,4)
    im=im.resize((max(1,int(im.width*s)),max(1,int(im.height*s))),Image.NEAREST)
    x=(i%cols)*cell; y=(i//cols)*(cell+10)
    sh.paste(im,(x,y),im); dr.text((x+1,y+cell),os.path.basename(f)[:9]+f'{Image.open(f).size}'[:0],fill=(200,200,200))
sh.save(out); print(len(fs))
