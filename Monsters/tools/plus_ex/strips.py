import glob,sys,os
from PIL import Image
OUT='/home/claude/wt_plusex/Monsters/docs/plus_ex/frames/'
def strip(d,name,picks=None,n=4):
    fs=sorted(glob.glob(d+'/*.jpg'))
    fs=fs[2:] if len(fs)>6 else fs
    if picks is None:
        step=max(1,len(fs)//n); picks=[min(len(fs)-1,i*step+step//2) for i in range(n)]
    im=[Image.open(fs[i]).resize((300,300)) for i in picks]
    s=Image.new('RGB',(300*len(im),300))
    for i,x in enumerate(im): s.paste(x,(i*300,0))
    s.save(OUT+'fight_'+name+'.jpg',quality=72); return [os.path.basename(fs[i]) for i in picks]
if __name__=='__main__':
    for a in sys.argv[1:]:
        d,name=a.split(':'); print(name,strip(d,name))
