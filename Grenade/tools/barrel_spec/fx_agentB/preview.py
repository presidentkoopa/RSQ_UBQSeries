import sys,glob,os
from PIL import Image,ImageDraw
# usage: preview.py out.png cell files...
out=sys.argv[1]; cell=int(sys.argv[2]); fs=sys.argv[3:]
cols=min(12,len(fs)); rows=(len(fs)+cols-1)//cols
S=Image.new('RGB',(cols*cell,rows*(cell+10)),(40,40,60)); d=ImageDraw.Draw(S)
for i,f in enumerate(fs):
    im=Image.open(f).convert('RGBA'); s=min(cell/im.width,cell/im.height,3)
    im=im.resize((max(1,int(im.width*s)),max(1,int(im.height*s))),Image.NEAREST)
    x=(i%cols)*cell; y=(i//cols)*(cell+10)
    S.paste(im,(x,y),im); d.text((x+1,y+cell),os.path.basename(f)[:9],fill=(255,255,0))
S.save(out)
