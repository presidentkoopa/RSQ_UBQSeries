import re,sys,os
from PIL import Image, ImageDraw
def tics(run):
    log=open(run+'/run.log','rb').read().decode('latin1')
    R=[(int(a),int(b)) for a,b in re.findall(r'R10 R (\d+) maptime (\d+)',log)]
    files=sorted(f for f in os.listdir(run+'/frames') if f.endswith('.jpg'))
    nmax=int(files[-1][1:6]); off=nmax-R[-1][0]
    return R,off,files
def frame_at(run,tic,seg=-1):
    R,off,files=tics(run)
    segs=[[]]
    for n,m in R:
        if segs[-1] and m<segs[-1][-1][1]: segs.append([])
        segs[-1].append((n,m))
    s=segs[seg]
    cands=[(abs(m-tic),n) for n,m in s if os.path.exists('%s/frames/f%05d.jpg'%(run,n+off))]
    d,n=min(cands); return '%s/frames/f%05d.jpg'%(run,n+off)
if __name__=='__main__':
    run,out=sys.argv[1],sys.argv[2]; ts=[int(x) for x in sys.argv[3:]]
    ims=[]
    for t in ts:
        p=frame_at(run,t); im=Image.open(p).convert('RGB'); ImageDraw.Draw(im).text((4,4),'t%d %s'%(t,os.path.basename(p)),fill=(255,255,0)); ims.append(im)
    w,h=ims[0].size; c=3; S=Image.new('RGB',(w*c,h*((len(ims)+c-1)//c)))
    for i,im in enumerate(ims): S.paste(im,((i%c)*w,(i//c)*h))
    S.save(out,quality=85); print(out)
