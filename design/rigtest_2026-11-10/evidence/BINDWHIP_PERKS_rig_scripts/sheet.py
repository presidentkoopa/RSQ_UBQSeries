import re,sys,os
from PIL import Image, ImageDraw
run,out=sys.argv[1],sys.argv[2]; ts=[int(x) for x in sys.argv[3:]]
log=open(run+'/run.log','rb').read().decode('latin1')
F=[(int(a),int(c)) for a,b,c in re.findall(r'whp_F (\d+) g(\d+) m(\d+)',log)]
files=sorted(f for f in os.listdir(run+'/frames') if f.endswith('.jpg'))
off=int(files[-1][1:6])-F[-1][0]
ims=[]
for t in ts:
    c=[(abs(m-t),n) for n,m in F if os.path.exists('%s/frames/f%05d.jpg'%(run,n+off))]
    d,n=min(c); m=dict(F)[n]
    im=Image.open('%s/frames/f%05d.jpg'%(run,n+off)).convert('RGB'); ImageDraw.Draw(im).text((4,4),'t%d'%m,fill=(255,255,0)); ims.append(im)
w,h=ims[0].size; c=min(3,len(ims)); S=Image.new('RGB',(w*c,h*((len(ims)+c-1)//c)))
for i,im in enumerate(ims): S.paste(im,((i%c)*w,(i//c)*h))
S.save(out,quality=88); print(out, S.size, 'offset', off)
