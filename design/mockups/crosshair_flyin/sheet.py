import math, random, numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
def parts_of(path,z=2):
    im=Image.open(path).convert('RGBA'); im=im.resize((im.width*z,im.height*z),Image.NEAREST)
    a=np.array(im); lab,n=ndimage.label(a[:,:,3]>40); out=[]
    for i in range(1,n+1):
        m=(lab==i); ys,xs=np.where(m); x0,x1,y0,y1=xs.min(),xs.max()+1,ys.min(),ys.max()+1
        p=a[y0:y1,x0:x1].copy(); p[~m[y0:y1,x0:x1]]=0
        out.append((Image.fromarray(p,'RGBA'),(x0+x1)/2-im.width/2,(y0+y1)/2-im.height/2))
    # biggest piece (usually the ring) last, so the outer bits gather around it
    out.sort(key=lambda q:q[0].width*q[0].height)
    return out
def ease(t): return 1-(1-t)**3
CW,CH=240,240; COLS,ROWS=5,2
P=[parts_of('/tmp/xh/RSQMBX%02d.png'%i) for i in range(1,11)]
def cell(parts,t,seed):
    c=Image.new('RGBA',(CW,CH),(36,37,46,255)); cx,cy=CW//2,CH//2-8
    n=len(parts); dur=7; span=6   # all pieces arrive within ~13 tics (0.37 s)
    stag=span/max(1,n-1); tl=dur+span
    for k,(pimg,px,py) in enumerate(parts):
        u=(t-k*stag)/dur
        if u<=0: continue
        u=min(1,u); e=ease(u)
        r=random.Random(seed*97+k); ang=(math.atan2(py,px) if (abs(px)+abs(py))>2 else r.uniform(0,6.28))+r.uniform(-0.5,0.5)
        dist=(1-e)*r.uniform(110,170); sc=1+(1-e)*0.9; al=e**1.6    # invisible at the start, fading in as it travels
        im=pimg.resize((max(1,int(pimg.width*sc)),max(1,int(pimg.height*sc))),Image.NEAREST)
        im.putalpha(im.split()[3].point(lambda v,al=al:int(v*al)))
        c.alpha_composite(im,(int(cx+px+math.cos(ang)*dist-im.width/2),int(cy+py+math.sin(ang)*dist-im.height/2)))
    if tl<=t<tl+2:   # the snap: a white flash and a 1-frame pop
        g=Image.new('RGBA',(CW,CH),(0,0,0,0))
        for pimg,px,py in parts:
            im=pimg.resize((int(pimg.width*1.12),int(pimg.height*1.12)),Image.NEAREST)
            g.alpha_composite(im,(int(cx+px*1.12-im.width/2),int(cy+py*1.12-im.height/2)))
        c.alpha_composite(g)
    return c
T=40; frames=[]
for t in range(T):
    sh=Image.new('RGBA',(10+COLS*(CW+10),46+ROWS*(CH+10)+18),(18,17,22,255)); d=ImageDraw.Draw(sh)
    d.text((12,14),'RSQ Boss crosshairs RSQMBX01-10, assembling: pieces start invisible far out and fade in as they fly together, then snap. Mockup, not in engine.',fill=(255,226,120))
    for i in range(10):
        st=(i%COLS)*2+(i//COLS)*3      # a ripple across the sheet
        im=cell(P[i],t-st,i); x=10+(i%COLS)*(CW+10); y=40+(i//COLS)*(CH+10)
        sh.alpha_composite(im,(x,y)); d.text((x+6,y+CH-18),'RSQMBX%02d'%(i+1),fill=(170,170,185))
    frames.append(sh.convert('RGB'))
for name,ms in (('crosshair_sheet_assemble_real.gif',29),('crosshair_sheet_assemble_slow.gif',90)):
    q=[f.quantize(64,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/xflyin/'+name,save_all=True,append_images=q[1:]+[q[-1]]*30,duration=ms,loop=0)
frames[9].save('/home/claude/xflyin/sheet_still.png'); print('ok')
