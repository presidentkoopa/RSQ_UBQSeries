import math, random, numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
W2=Wad('/home/claude/rig/packs/doom2.wad'); imp=W2.patch('TROOA1').convert('RGBA')
def shade(im,k):
    a=np.array(im).astype(float); a[:,:,:3]*=k; return Image.fromarray(np.clip(a,0,255).astype(np.uint8),'RGBA')
IMP=shade(imp,0.6).resize((imp.width*3,imp.height*3),Image.NEAREST)
def parts_of(path,z=2):
    im=Image.open(path).convert('RGBA'); im=im.resize((im.width*z,im.height*z),Image.NEAREST)
    a=np.array(im); lab,n=ndimage.label(a[:,:,3]>40)
    out=[]
    for i in range(1,n+1):
        m=(lab==i); ys,xs=np.where(m)
        x0,x1,y0,y1=xs.min(),xs.max()+1,ys.min(),ys.max()+1
        p=a[y0:y1,x0:x1].copy(); p[~m[y0:y1,x0:x1]]=0
        cx=(x0+x1)/2-im.width/2; cy=(y0+y1)/2-im.height/2
        out.append((Image.fromarray(p,'RGBA'),cx,cy))
    return out,im.size
def colourise(p,rgb):
    a=np.array(p).astype(float); a[:,:,:3]=a[:,:,:3]/255.0*np.array(rgb); return Image.fromarray(np.clip(a,0,255).astype(np.uint8),'RGBA')
def ease(t): return 1-(1-t)**3
PW,PH=330,380
def bg():
    p=Image.new('RGBA',(PW,PH),(26,20,18,255)); d=ImageDraw.Draw(p); d.rectangle((0,PH-60,PW,PH),fill=(44,36,30,255))
    p.alpha_composite(IMP,(PW//2-IMP.width//2,PH-60-IMP.height+6)); return p
CX,CY=PW//2,PH-60-IMP.height//2-10
random.seed(7)
def flyin_panel(parts,t,rgb,start=3,dur=7,stag=1):
    p=bg(); done=True
    order=list(range(len(parts))); 
    for k,i in enumerate(order):
        pimg,px,py=parts[i]; t0=start+k*stag; u=(t-t0)/dur
        if u<0: done=False; continue
        if u>=1: u=1
        else: done=False
        ang=math.atan2(py,px) if (px or py) else (k*2.4)
        ang+=random.Random(i*13).uniform(-0.6,0.6)
        dist=(1-ease(u))*220; sc=1+(1-ease(u))*1.6; al=min(1,u*2.2)
        im=colourise(pimg,rgb)
        im=im.resize((max(1,int(im.width*sc)),max(1,int(im.height*sc))),Image.NEAREST)
        if al<1: im.putalpha(im.split()[3].point(lambda v:int(v*al)))
        x=CX+px+math.cos(ang)*dist-im.width/2; y=CY+py+math.sin(ang)*dist-im.height/2
        p.alpha_composite(im,(int(x),int(y)))
    tlock=start+(len(parts)-1)*stag+dur
    if t>=tlock and t<tlock+3:   # snap flash: white over the assembled mark
        fl=Image.new('RGBA',(PW,PH),(0,0,0,0))
        for pimg,px,py in parts:
            im=colourise(pimg,(255,255,255)); fl.alpha_composite(im,(int(CX+px-im.width/2),int(CY+py-im.height/2)))
        p.alpha_composite(fl)
    return p,tlock
def predator_panel(t):
    p=bg(); d=ImageDraw.Draw(p,'RGBA')
    tri=[(CX,CY-34),(CX+30,CY+18),(CX-30,CY+18)]
    for k in range(3):
        a=tri[k]; b=tri[(k+1)%3]; u=(t-3-k)/8
        if u<0: continue
        u=min(1,u); e=ease(u); grow=(1-e)*9+1
        mx,my=(a[0]+b[0])/2,(a[1]+b[1])/2
        dx,dy=mx-CX,my-CY; L=math.hypot(dx,dy); off=(1-e)*260
        ox,oy=dx/L*off,dy/L*off
        A=(mx+(a[0]-mx)*grow+ox, my+(a[1]-my)*grow+oy); B=(mx+(b[0]-mx)*grow+ox, my+(b[1]-my)*grow+oy)
        w=int(3+(1-e)*30)
        d.line([A,B],fill=(230,20,20,int(120+135*e)),width=w)
    if 14<=t<17: d.polygon(tri,outline=(255,230,230,255),width=3)
    return p,14
def vcop_panel(t):
    p=bg(); d=ImageDraw.Draw(p,'RGBA')
    u=(t-3)/14
    if u<0: return p,17
    u=min(1,u); r=int(150-(150-34)*ease(u))
    cols=[(80,255,60),(255,230,40),(255,150,20),(240,30,30)]
    c=cols[min(3,int(u*4))] if u<1 else cols[3]
    for rr in (r,r-6):
        d.ellipse((CX-rr,CY-rr,CX+rr,CY+rr),outline=c+(255,),width=3)
    for k in range(8):
        a=k*math.pi/4+(1-u)*1.2; d.line((CX+math.cos(a)*(r-10),CY+math.sin(a)*(r-10),CX+math.cos(a)*(r+10),CY+math.sin(a)*(r+10)),fill=c+(255,),width=3)
    if u>=1 and t<20: d.ellipse((CX-r,CY-r,CX+r,CY+r),outline=(255,255,255,255),width=4)
    return p,17
P1,_=parts_of('/tmp/xh/RSQMBX01.png'); P5,_=parts_of('/tmp/xh/RSQMBX05.png'); P10,_=parts_of('/tmp/xh/RSQMBX10.png'); P7,_=parts_of('/tmp/xh/RSQMBX07.png')
RED=(255,60,40)
panels=[('A  OUR RSQMBX01, parts fly in',lambda t:flyin_panel(P1,t,RED)),
        ('B  RSQMBX07, many parts, staggered',lambda t:flyin_panel(P7,t,(255,214,60),stag=1,dur=6)),
        ('C  PREDATOR: three bars converge',predator_panel),
        ('D  VIRTUAL COP: ring closes, green to red',vcop_panel)]
T=34; frames=[]
for t in range(T):
    sh=Image.new('RGBA',(PW*4+50,PH+60),(18,17,22,255)); d=ImageDraw.Draw(sh)
    for i,(lab,fn) in enumerate(panels):
        im,_=fn(t); sh.alpha_composite(im,(10+i*(PW+10),40)); d.text((14+i*(PW+10),14),lab,fill=(255,226,120))
    d.text((10,sh.height-16),'Lock-on crosshairs on an imp, about 0.3-0.5 s each. Mockup, not in engine.',fill=(120,120,135))
    frames.append(sh.convert('RGB'))
for name,ms in (('crosshair_flyin_real.gif',29),('crosshair_flyin_slow.gif',100)):
    q=[f.quantize(128,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/xflyin/'+name,save_all=True,append_images=q[1:]+[q[-1]]*25,duration=ms,loop=0)
frames[7].save('/home/claude/xflyin/still.png'); print('ok')
