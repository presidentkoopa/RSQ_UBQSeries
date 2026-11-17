import math, random, numpy as np, os
os.chdir('/home/claude/bnmock')
src=open('boss_mock.py').read(); exec(src[:src.index('# settled')])
from PIL import Image, ImageDraw, ImageFilter, ImageOps
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
S=2.6
def spr(f): im=Image.open('/tmp/hsmi/HSMI%s1.png'%f).convert('RGBA'); return im.resize((int(im.width*S),int(im.height*S)),Image.NEAREST)
A=spr('A'); H=spr('H')
SW,SH=960,900; FLOOR=640; CX=SW//2
def ink_text(s,z,col=(30,30,28)):
    m=lum_mask_from([F1.get(ord(ch)) for ch in s],gap=1,thr=75); m=m.resize((m.width*z,m.height*z),Image.NEAREST)
    o=Image.new('RGBA',m.size,col+(0,)); o.putalpha(m.point(lambda v:255 if v>0 else 0)); return o
def small_text(s,z,col=(40,40,36)):
    m=lum_mask_from([F2.get(ord(ch)) for ch in s.upper()],gap=1,thr=75); m=m.resize((m.width*z,m.height*z),Image.NEAREST)
    o=Image.new('RGBA',m.size,col+(0,)); o.putalpha(m.point(lambda v:255 if v>0 else 0)); return o
# the blueprint card (House of the Dead look: grid paper, the monster sketched, its weak points circled)
CW,CHh=760,500
NAME='OBSIDIAN TYRANT'; TYPE='HELL SMITH  TYPE EX-12'; HP=216000
def card(prog):
    c=Image.new('RGBA',(CW,CHh),(214,212,198,255)); d=ImageDraw.Draw(c)
    for x in range(0,CW,24): d.line((x,0,x,CHh),fill=(170,172,160,255),width=1)
    for y in range(0,CHh,24): d.line((0,y,CW,y),fill=(170,172,160,255),width=1)
    src=Image.open('/tmp/hsmi/HSMIA1.png').convert('RGBA'); z=1.75
    g=src.convert('L').filter(ImageFilter.FIND_EDGES); a=np.array(g); al=np.array(src.split()[3])
    e=np.where((a>40)&(al>0),255,0).astype(np.uint8)
    sil=Image.fromarray((al>0).astype(np.uint8)*255).filter(ImageFilter.FIND_EDGES)
    e=np.maximum(e,np.array(sil))
    m=Image.fromarray(e).resize((int(src.width*z),int(src.height*z)),Image.NEAREST)
    k=min(1,prog/0.35); cut=int(m.height*k); m2=m.copy(); ImageDraw.Draw(m2).rectangle((0,cut,m.width,m.height),fill=0)
    ink=Image.new('RGBA',m.size,(40,40,38,0)); ink.putalpha(m2)
    sx,sy=60,16; c.alpha_composite(ink,(sx,sy))
    spots=[(62,40,30),(20,50,27),(120,88,29)]
    for i,(px,py,r) in enumerate(spots):
        u=(prog-0.4-i*0.08)/0.1
        if u<=0: continue
        u=min(1,u); X=sx+px*z; Y=sy+py*z
        d.arc((X-r,Y-r,X+r,Y+r),0,int(360*u),fill=(30,30,28,255),width=3)
        if u>=1: d.line((X+r*0.7,Y-r*0.7,372,128),fill=(30,30,28,255),width=2)
    if prog>0.62:
        w=ink_text('WEAK POINT',3); c.alpha_composite(w,(380,108))
    # the name plate: a black band across the bottom, the name big in gold, slammed in
    BY=322
    d.rectangle((0,BY,CW,CHh),fill=(16,12,12,255)); d.line((0,BY,CW,BY),fill=(200,30,24,255),width=4)
    if prog>0.7:
        u=prog-0.7
        nm=banded(F1,NAME,4,GOLDB)
        sc=[1.5,1.25,1.08,1.0][min(3,int(u/0.02))]
        nm=nm.resize((int(nm.width*sc),int(nm.height*sc)),Image.NEAREST)
        if nm.width>CW-24:
            f=(CW-24)/nm.width; nm=nm.resize((int(nm.width*f),int(nm.height*f)),Image.NEAREST)
        c.alpha_composite(nm,(CW//2-nm.width//2,BY+18-(nm.height-int(nm.height/sc))//2))
    if prog>0.8:
        t2=small_text(TYPE,2,(200,196,180)); c.alpha_composite(t2,(24,CHh-50))
    if prog>0.84:
        u=min(1,(prog-0.84)/0.14); v=int(round(HP*u/10))*10
        parts=format(v,',').split(',')
        RED=[(255,230,220),(255,110,90),(225,35,25),(120,10,10)]
        ims=[banded(F1,'HP',3,RED)]
        row=Image.new('RGBA',(1,1),(0,0,0,0))
        segs=[banded(F1,p,3,RED) for p in parts]
        hh=segs[0].height; W=ims[0].width+18+sum(g.width for g in segs)+14*(len(segs)-1)
        hp=Image.new('RGBA',(W,hh),(0,0,0,0)); x=0
        hp.alpha_composite(ims[0],(0,0)); x=ims[0].width+18
        dd=ImageDraw.Draw(hp)
        for j,g in enumerate(segs):
            hp.alpha_composite(g,(x,0)); x+=g.width
            if j<len(segs)-1:
                dd.polygon([(x-2,hh-16),(x+6,hh-16),(x+6,hh-8),(x+1,hh-2),(x-2,hh-2)],fill=(225,35,25,255)); x+=10
        c.alpha_composite(hp,(CW-hp.width-24,CHh-hp.height-28))
    d.rectangle((0,0,CW-1,CHh-1),outline=(90,90,84,255),width=3)
    return c
def scene_bg():
    c=Image.new('RGBA',(SW,SH),(26,18,18,255)); d=ImageDraw.Draw(c)
    d.rectangle((0,FLOOR-20,SW,SH),fill=(44,32,30,255))
    for i in range(6): d.rectangle((60+i*150,120,120+i*150,FLOOR-20),fill=(34,24,24,255))
    return c
def greyed(im,k):
    g=ImageOps.grayscale(im.convert('RGB')).convert('RGBA'); g=Image.blend(g,Image.new('RGBA',g.size,(0,0,0,255)),0.45)
    return Image.blend(im,g,k)
END=230; frames=[]
for t in range(END):
    c=scene_bg(); d=ImageDraw.Draw(c,'RGBA')
    shake=0
    if t>=150:   # it drops in
        u=t-150; fall=max(0,1-u/6)
        im=A if u>=12 or u<6 else H
        y=FLOOR-im.height+8-int(fall*900)
        if u>=6:
            v=u-6
            for k in range(5):   # five pentagram lines crack out from the impact
                a=-math.pi/2+k*2*math.pi/5; L=min(420,v*38)
                d.line((CX,FLOOR,CX+math.cos(a)*L,FLOOR+math.sin(a)*L*0.3),fill=(255,70,20,230),width=6)
            if v<10: shake=random.Random(t).randint(-12,12)
            if v<6:
                r=40+v*45; d.ellipse((CX-r,FLOOR-r*0.3,CX+r,FLOOR+r*0.3),outline=(255,200,120,255-v*40),width=6)
        c.alpha_composite(im,(CX-im.width//2+shake,y))
    frozen=20<=t<140
    if t>=10 and t<150:
        k=min(1,(t-10)/10) if t<140 else max(0,1-(t-140)/10)
        c=greyed(c,0.85*k); d=ImageDraw.Draw(c,'RGBA')
    if 12<=t<40:
        b=banded(F1,'BIG BOSS INCOMING!',3,[(255,200,190),(255,90,70),(220,30,20),(120,10,10)],shade=False)
        s=[0.2,1.35,1.12,1.0][min(3,t-12)]; b=b.resize((max(1,int(b.width*s)),max(1,int(b.height*s))),Image.NEAREST)
        c.alpha_composite(b,(CX-b.width//2,60))
    if 40<=t<140:
        prog=min(1,(t-46)/76) if t>=46 else 0
        cd=card(prog); slide=1 if t<132 else max(0,1-(t-132)/8)
        k=min(1,(t-40)/6)
        sc=0.6+0.4*ease(k) if 'ease' in dir() else 1
        cd=cd.resize((int(cd.width*(0.6+0.4*min(1,(t-40)/6))),int(cd.height*(0.6+0.4*min(1,(t-40)/6)))),Image.NEAREST)
        x=CX-cd.width//2; y=150 if t<132 else 150-int((1-slide)*800)
        c.alpha_composite(cd,(x,y))
    if t>=168:
        bar=gauge(min(1,(t-168)/20),((72,15,12),(240,50,40),(250,160,150)),400,30,t)
        name=banded(F1,'OBSIDIAN TYRANT',3,GOLDB)
        row=hstack([HD.resize((80,80),Image.NEAREST),vstack([name,hstack([bar,banded(F1,'X3',3,GOLDB)],10)],6)],14)
        c.alpha_composite(row,(30,SH-150))
    cap='the siren; the world freezes and dims' if t<40 else ('the WEAK POINT card' if t<140 else 'it drops in: the hammer slam, five pentagram lines, a quake')
    ImageDraw.Draw(c).text((12,12),cap,fill=(220,220,225))
    ImageDraw.Draw(c).text((12,SH-16),'Arrival card v2: the name big on a plate, HP = all three lives (example figure: 24,000 x3 legendary x3 lives). Mockup, not in engine.',fill=(140,140,150))
    frames.append(c.convert('RGB'))
for name,ms in (('tyrant_arrival_v2_real.gif',29),):
    q=[f.quantize(160,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/tyrant/'+name,save_all=True,append_images=q[1:]+[q[-1]]*25,duration=ms,loop=0)
for i in (25,100,128,215): frames[i].save('/home/claude/tyrant/arr2_%d.png'%i)
print('ok')
