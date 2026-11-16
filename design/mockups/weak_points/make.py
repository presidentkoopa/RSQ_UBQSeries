import math, random, numpy as np, os
os.chdir('/home/claude/bnmock')
src=open('boss_mock.py').read(); exec(src[:src.index('# settled')])
from scipy import ndimage
from PIL import Image, ImageDraw
W2=Wad('/home/claude/rig/packs/doom2.wad') if 'Wad' in dir() else None
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
W2=Wad('/home/claude/rig/packs/doom2.wad'); imp=W2.patch('TROOA1').convert('RGBA')
Z=5; IMP=imp.resize((imp.width*Z,imp.height*Z),Image.NEAREST)
def shade(im,k):
    a=np.array(im).astype(float); a[:,:,:3]*=k; return Image.fromarray(np.clip(a,0,255).astype(np.uint8),'RGBA')
def tintflat(im,rgb):
    a=np.array(im).astype(float); a[:,:,:3]=np.array(rgb); return Image.fromarray(a.astype(np.uint8),'RGBA')
def parts_of(path,z=2):
    im=Image.open(path).convert('RGBA'); im=im.resize((im.width*z,im.height*z),Image.NEAREST)
    a=np.array(im); lab,n=ndimage.label(a[:,:,3]>40); out=[]
    for i in range(1,n+1):
        m=(lab==i); ys,xs=np.where(m); x0,x1,y0,y1=xs.min(),xs.max()+1,ys.min(),ys.max()+1
        p=a[y0:y1,x0:x1].copy(); p[~m[y0:y1,x0:x1]]=0
        out.append((Image.fromarray(p,'RGBA'),(x0+x1)/2-im.width/2,(y0+y1)/2-im.height/2))
    out.sort(key=lambda q:q[0].width*q[0].height); return out
def ease(t): return 1-(1-t)**3
SW,SH=900,820
IX,IY=SW//2-IMP.width//2, 140
_a=np.array(IMP).astype(float); _L=_a[:,:,:3].mean(2,keepdims=True); _red=(_a[:,:,0]>150)&(_a[:,:,1]<80)
_a[:,:,:3]=np.clip(_L*np.array([0.42,0.42,0.5]),0,255); _a[_red,0]=230; _a[_red,1]=30; _a[_red,2]=30
BLK=Image.fromarray(_a.astype(np.uint8),'RGBA')
# three weak points (sprite pixel coords on TROOA1 x Z): right shoulder, left thigh, the mouth
WP=[dict(x=IX+int(39*Z),y=IY+int(17*Z),xh='RSQMBX03',col=(60,170,255),lab=(SW-250,170),hp0=1.0,break_at=95),
    dict(x=IX+int(21*Z),y=IY+int(50*Z),xh='RSQMBX05',col=(200,90,255),lab=(40,470),hp0=1.0,break_at=125),
    dict(x=IX+int(28*Z),y=IY+int(10*Z),xh='RSQMBX01',col=(255,200,50),lab=(40,150),hp0=1.0,break_at=150)]
for w in WP: w['parts']=parts_of('/tmp/xh/%s.png'%w['xh'],1)
OPEN=8; ASM=(14,20,26); BIG=165; END=215
def xh_draw(c,w,t,t0):
    if t<t0: return
    n=len(w['parts']); dur=7; span=5; stag=span/max(1,n-1)
    for k,(p,px,py) in enumerate(w['parts']):
        u=(t-t0-k*stag)/dur
        if u<=0: continue
        u=min(1,u); e=ease(u); r=random.Random(k*31+w['x'])
        ang=(math.atan2(py,px) if abs(px)+abs(py)>2 else r.uniform(0,6.3))+r.uniform(-.5,.5)
        dist=(1-e)*r.uniform(140,200); sc=1+(1-e)*0.9; al=e**1.6
        im=tintflat(p,w['col']); im=im.resize((max(1,int(im.width*sc*1.4)),max(1,int(im.height*sc*1.4))),Image.NEAREST)
        im.putalpha(im.split()[3].point(lambda v,al=al:int(v*al)))
        c.alpha_composite(im,(int(w['x']+px*1.4+math.cos(ang)*dist-im.width/2),int(w['y']+py*1.4+math.sin(ang)*dist-im.height/2)))
    tl=t0+12
    if tl<=t<tl+2:
        for p,px,py in w['parts']:
            im=p.resize((int(p.width*1.5),int(p.height*1.5)),Image.NEAREST); c.alpha_composite(im,(int(w['x']+px*1.5-im.width/2),int(w['y']+py*1.5-im.height/2)))
def wp_hp(w,t):
    s=w['break_at']-40
    if t<s: return 1.0
    return max(0.0,1-(t-s)/40)
def label(c,w,t,t0,hp):
    if t<t0+10: return
    d=ImageDraw.Draw(c); lx,ly=w['lab']; ex,ey=w['x'],w['y']
    k=min(1,(t-t0-10)/4)
    ax=lx+200 if lx<SW//2 else lx; ay=ly+22
    d.line((ex,ey,ex+(ax-ex)*k,ey+(ay-ey)*k),fill=w['col']+(255,),width=3)
    if k<1: return
    d.line((lx,ay,lx+200,ay),fill=w['col']+(255,),width=3)
    word=banded(F1,'WEAK POINT!',2,[mix(w['col'],(255,255,255),.6),w['col'],tuple(int(v*.7) for v in w['col']),tuple(int(v*.45) for v in w['col'])],shade=False)
    c.alpha_composite(word,(lx,ay-word.height-6))
    cols=(tuple(int(v*0.3) for v in w['col']),w['col'],mix(w['col'],(255,255,255),0.55))
    c.alpha_composite(gauge(hp,cols,200,18,t),(lx,ay+8))
def crack(c,w,t):
    tb=w['break_at']
    if t<tb: return False
    d=ImageDraw.Draw(c); u=t-tb
    if u<8:
        r=10+u*9; d.ellipse((w['x']-r,w['y']-r,w['x']+r,w['y']+r),outline=(255,255,255,max(0,255-u*30)),width=4)
        word=banded(F1,'BREAK!',3,GOLDB,shade=False); c.alpha_composite(word,(w['x']-word.width//2,w['y']-70-u*3))
    return True
def boss_row(t,frac,chunk,flash):
    h=30; w=460; col=(240,50,40)
    cols=(tuple(int(c*0.3) for c in col), col, mix(col,(255,255,255),0.55))
    bar=gauge(frac,cols,w,h,t)
    if chunk>0:   # the yellow: what breaking all three in the window takes off
        a=int(w*(frac-chunk)); b=int(w*frac); o=Image.new('RGBA',(max(1,b-a),h-6),(255,205,40,int(225+30*math.sin(t*.5))))
        bar.alpha_composite(o,(a,3))
    if flash: bar.alpha_composite(Image.new('RGBA',(w,h),(255,255,255,140)))
    name=banded(F1,'IMP WARLORD',3,GOLDB)
    right=vstack([name,hstack([bar,banded(F1,'X3',3,GOLDB)],10)],6)
    return hstack([HD.resize((80,80),Image.NEAREST),right],14)
frames=[]
for t in range(END):
    c=Image.new('RGBA',(SW,SH),(24,19,17,255)); d=ImageDraw.Draw(c)
    d.rectangle((0,SH-190,SW,SH),fill=(40,33,28,255))
    c.alpha_composite(BLK,(IX,IY))
    inwin = OPEN<=t<BIG+20
    if t>=OPEN:
        k=min(1.0,(t-OPEN)/4); s=[0.2,1.35,1.12,1.0][min(3,t-OPEN)]
        ttl=banded(F1,'CRITICAL WINDOW!!',3,[(255,200,190),(255,90,70),(220,30,20),(120,10,10)],shade=False)
        ttl=ttl.resize((max(1,int(ttl.width*s)),max(1,int(ttl.height*s))),Image.NEAREST)
        if inwin or (t//3)%2==0: c.alpha_composite(ttl,(40,40))
        secs=max(0.0,6.0-(t-OPEN)/35); ss=sevenseg('%02d:%02d'%(int(secs),int((secs%1)*100)),(255,42,26),34)
        c.alpha_composite(ss,(44,40+ttl.height+8))
    broken=0
    for i,w in enumerate(WP):
        if crack(c,w,t): broken+=1; continue
        if t>=OPEN+ASM[i]-6: xh_draw(c,w,t,OPEN+ASM[i]-6)
        label(c,w,t,OPEN+ASM[i]-6,wp_hp(w,t))
        if w['break_at']-40<=t<w['break_at'] and t%3==0:   # hits landing
            r=random.Random(t); hx=w['x']+r.randint(-14,14); hy=w['y']+r.randint(-14,14)
            d.ellipse((hx-6,hy-6,hx+6,hy+6),fill=(255,255,220,255))
    frac=0.78-0.05*broken
    chunk=0.30 if (OPEN+20<=t<BIG) else 0
    if t>=BIG: frac=max(0.18,frac-0.30*min(1,(t-BIG)/6))
    flash=BIG<=t<BIG+3
    c.alpha_composite(boss_row(t,frac,chunk,flash),(80,SH-160))
    if BIG<=t<BIG+30:
        s=[0.2,1.35,1.12,1.0][min(3,t-BIG)]
        word=banded(F1,'CRITICAL HIT!',4,GOLDB,shade=False); word=word.resize((max(1,int(word.width*s)),max(1,int(word.height*s))),Image.NEAREST)
        c.alpha_composite(word,(SW//2-word.width//2,330))
    d.text((10,SH-16),'Big Boss weak points on a Black EX (Imp Warlord), the owner\'s sketch in our style. The Boss bar\'s yellow = what the window takes off if all three break. Mockup, not in engine.',fill=(150,150,160))
    frames.append(c.convert('RGB'))
for name,ms in (('weak_points_real.gif',29),('weak_points_slow.gif',70)):
    q=[f.quantize(128,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/weakpt/'+name,save_all=True,append_images=q[1:]+[q[-1]]*20,duration=ms,loop=0)
for i in (40,110,170): frames[i].save('/home/claude/weakpt/still_%d.png'%i)
print('ok')
