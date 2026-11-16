import math, random, numpy as np, os
os.chdir('/home/claude/bnmock')
src=open('boss_mock.py').read(); exec(src[:src.index('# settled')])
from PIL import Image, ImageDraw
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
S=2.4
def spr(f): im=Image.open('/tmp/hsmi/HSMI%s1.png'%f).convert('RGBA'); return im.resize((int(im.width*S),int(im.height*S)),Image.NEAREST)
SSM=spr('F'); STAND=spr('A')
SW,SH=960,900; FLOOR=520; CX=SW//2+140
PX,PY=SW//2-200,FLOOR+90   # the pentagram on the floor, in front of the player
def pentagram(d,cx,cy,r,col,a,w=5):
    pts=[(cx+r*math.cos(-math.pi/2+i*4*math.pi/5), cy+r*0.32*math.sin(-math.pi/2+i*4*math.pi/5)) for i in range(5)]
    d.line(pts+[pts[0]],fill=col+(a,),width=w); d.ellipse((cx-r,cy-r*0.32,cx+r,cy+r*0.32),outline=col+(a,),width=w-1)
def pop(im,t,t0):
    s=[0.2,1.35,1.12,1.0][min(3,max(0,t-t0))]; return im.resize((max(1,int(im.width*s)),max(1,int(im.height*s))),Image.NEAREST)
RED4=[(255,200,190),(255,90,70),(220,30,20),(120,10,10)]
def cycle(t,miss):
    """one pentagram: planted at 10, countdown 105 tics; hit (or not)"""
    c=Image.new('RGBA',(SW,SH),(22,14,12,255)); d=ImageDraw.Draw(c,'RGBA')
    d.rectangle((0,FLOOR-20,SW,SH),fill=(40,28,24,255))
    T0=10; WIN=105; END=T0+WIN
    hpP=1.0; broken=False
    if not miss:
        s=T0+40
        if t>=s: hpP=max(0,1-(t-s)/40)
        broken=t>=s+40
    life=0.42
    healing=T0<=t and not (broken) and t<END
    if t>=T0: life=min(0.42+0.0012*(min(t,END if not broken else (T0+80))-T0),1)
    if broken: life=min(life,0.42+0.0012*80)
    plus = miss and t>=END
    im=SSM if (t//4)%2==0 or plus else STAND
    if plus: im=SSM
    c.alpha_composite(im,(CX-im.width//2+(random.Random(t).randint(-3,3) if plus else 0),FLOOR-im.height+8))
    if t>=T0 and not broken:
        a=int(170+80*math.sin(t*0.6)); pentagram(d,PX,PY,150,(255,60,20),a,6)
        # the heal line: a red thread from the pentagram to the Smith
        if t<END or miss and t<END: d.line((PX,PY,CX,FLOOR-200),fill=(255,80,60,120),width=3)
    if broken and t<T0+80+14:
        u=t-(T0+80)
        for k in range(10):
            a=k*0.63; r=30+u*20; d.line((PX+math.cos(a)*r*0.4,PY+math.sin(a)*r*0.12,PX+math.cos(a)*r,PY+math.sin(a)*r*0.3),fill=(255,190,120,max(0,240-u*16)),width=4)
        b=pop(banded(F1,'BROKEN!',3,GOLDB,shade=False),t,T0+80); c.alpha_composite(b,(PX-b.width//2,PY-150-u*2))
    if T0+2<=t<END and not broken:
        # CRITICAL TARGET!: the label, a line down to the pentagram, its HP bar, the 3-second countdown
        lx,ly=40,170
        word=pop(banded(F1,'CRITICAL TARGET!',3,RED4,shade=False),t,T0+2); c.alpha_composite(word,(lx,ly))
        d.line((lx+120,ly+word.height+44,PX,PY-30),fill=(255,80,60,255),width=3)
        ex,ey=PX,PY-30; d.line((ex-14,ey,ex+14,ey),fill=(255,80,60,255),width=3); d.line((ex,ey-14,ex,ey+14),fill=(255,80,60,255),width=3)
        c.alpha_composite(gauge(hpP,((80,14,10),(240,50,40),(255,170,160)),260,18,t),(lx,ly+word.height+14))
        left=max(0,END-t)/35; ss=sevenseg('%d:%02d'%(int(left),int((left%1)*100)),(255,42,26),34); c.alpha_composite(ss,(lx+280,ly+word.height+4))
        if s_hits(t,miss): 
            r=random.Random(t); hx=PX+r.randint(-60,60); hy=PY+r.randint(-14,14); d.ellipse((hx-6,hy-4,hx+6,hy+4),fill=(255,255,220,255))
    if plus and t<END+40:
        b=pop(banded(F1,'SUPERSMITH+',4,RED4,shade=False),t,END); c.alpha_composite(b,(SW//2-b.width//2,120))
        n=banded(F1,'FASTER - MORE SLAMS',2,GOLDB,shade=False); c.alpha_composite(n,(SW//2-n.width//2,130+b.height))
    # its Boss bar, last life, healing green while the pentagram stands
    bar=gauge(life,((72,15,12),(240,50,40),(250,160,150)),400,30,t)
    if healing: bar.alpha_composite(Image.new('RGBA',(6,26),(120,255,120,230)),(int(400*life)-6,2))
    name=banded(F1,'OBSIDIAN TYRANT',3,GOLDB)
    row=hstack([HD.resize((80,80),Image.NEAREST),vstack([name,hstack([bar,banded(F1,'X1',3,GOLDB)],10)],6)],14)
    c.alpha_composite(row,(30,SH-150))
    if healing and t%10<6:
        hb=banded(F1,'HEALING',2,[(200,255,200),(120,255,120),(40,180,40),(10,90,10)],shade=False); c.alpha_composite(hb,(700,SH-95))
    cap=('broken in time: the heal stops' if not miss else 'missed: SUPERSMITH+ until its next EXPOSED!')
    ImageDraw.Draw(c).text((12,12),'Supersmith (last life) plants a pentagram to heal. '+cap,fill=(220,220,225))
    ImageDraw.Draw(c).text((12,SH-16),'Obsidian Tyrant: CRITICAL TARGET! (owner 11-16). Mockup, not in engine.',fill=(140,140,150))
    return c.convert('RGB')
def s_hits(t,miss): return (not miss) and 50<=t<90 and t%3==0
frames=[cycle(t,False) for t in range(150)]+[cycle(t,True) for t in range(170)]
for name,ms in (('tyrant_critical_target_real.gif',29),('tyrant_critical_target_slow.gif',60)):
    q=[f.quantize(160,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/tyrant/'+name,save_all=True,append_images=q[1:],duration=ms,loop=0)
for i in (60,95,150+60,150+125): frames[i].save('/home/claude/tyrant/ct_%d.png'%i)
print('ok')
