import sys,glob
from PIL import Image
pre=sys.argv[1]; idx=[int(x) for x in sys.argv[2].split(',')]; crop=tuple(int(v) for v in sys.argv[3].split(',')) if len(sys.argv)>3 else None
ims=[Image.open(f'/tmp/fx_ctx2/look/{pre}_{i:03d}.png') for i in idx]
if crop: ims=[i.crop(crop) for i in ims]
w,h=ims[0].size; per=int(sys.argv[4]) if len(sys.argv)>4 else len(ims)
rows=(len(ims)+per-1)//per
M=Image.new('RGB',(w*per,h*rows))
for k,i in enumerate(ims): M.paste(i,((k%per)*w,(k//per)*h))
M.save(f'/tmp/fx_ctx2/look/S_{pre}.png'); print(M.size)
