# Training remote HUD mockup (owner 11-10): the series' own fonts -- VisualRewards' word glyphs (QVW), JFO digits.
import os
from PIL import Image, ImageDraw, ImageFilter
R='/home/claude/rsq_ubqseries/VisualRewards/'
def qvw(ch):
    p=R+'pk3/graphics/rsqvrw/QVW%03d.png'%ord(ch)
    return Image.open(p).convert('RGBA') if os.path.exists(p) else None
def jfo(ch):
    p=R+'tools/dn_art/jfo_big/fontb%03d.png'%ord(ch)
    return Image.open(p).convert('RGBA') if os.path.exists(p) else None
def word(txt,src,h,tint=None,gap=2):
    gl=[src(c) for c in txt]; sc=[]
    for g in gl:
        if g is None: sc.append(None); continue
        s=h/g.height; sc.append(g.resize((max(1,int(g.width*s)),h),Image.NEAREST))
    w=sum((g.width if g else h//2)+gap for g in sc); im=Image.new('RGBA',(max(1,w),h),(0,0,0,0)); x=0
    for g in sc:
        if g:
            if tint:
                r,gg,b,a=g.split(); l=Image.merge('RGB',(r,gg,b)).convert('L')
                g=Image.merge('RGBA',[l.point(lambda v:int(v*tint[0]/255)),l.point(lambda v:int(v*tint[1]/255)),l.point(lambda v:int(v*tint[2]/255)),a])
            im.alpha_composite(g,(x,0)); x+=g.width+gap
        else: x+=h//2+gap
    return im
W,H=900,520
bg=Image.new('RGBA',(W,H),(18,16,24,255)); d=ImageDraw.Draw(bg)
for y in range(H): d.line([(0,y),(W,y)],fill=(18+y//20,16+y//30,26+y//14,255))
d.rectangle([0,380,W,H],fill=(40,34,30,255))
# the droid, out in front
d.ellipse([590,170,640,220],fill=(70,70,80,255),outline=(200,200,210,255),width=2); d.ellipse([608,188,622,202],fill=(255,60,40,255))
# panel
px,py=40,40
panel=Image.new('RGBA',(480,270),(0,0,0,0)); pd=ImageDraw.Draw(panel)
pd.rounded_rectangle([0,0,479,269],radius=10,fill=(10,10,16,200),outline=(255,210,90,255),width=2)
panel.alpha_composite(word('TRAINING',qvw,26),(16,12))
panel.alpha_composite(word('REMOTE',qvw,26,tint=(255,120,60)),(16,44))
panel.alpha_composite(word('ROUND',qvw,16,tint=(180,180,200)),(330,18)); panel.alpha_composite(word('3',jfo,30),(430,10))
# score
panel.alpha_composite(word('4250',jfo,56),(16,86))
panel.alpha_composite(word('PTS',qvw,16,tint=(180,180,200)),(250,124))
# hits pips
panel.alpha_composite(word('HITS',qvw,14,tint=(180,180,200)),(16,160))
for k in range(4):
    c=(255,200,40,255) if k<3 else (60,60,70,255)
    pd.rectangle([100+k*30,158,122+k*30,178],fill=c,outline=(0,0,0,255))
# streak bar
panel.alpha_composite(word('STREAK',qvw,14,tint=(180,180,200)),(16,196))
pd.rectangle([140,198,400,214],fill=(30,30,40,255)); pd.rectangle([140,198,140+int(260*0.6),214],fill=(80,200,255,255))
panel.alpha_composite(word('X1.6',qvw,14,tint=(80,200,255)),(410,198))
pd.text((16,240),"deflected 12   stung 2   best 9",fill=(150,150,165,255))
bg.alpha_composite(panel,(px,py))
# the pop when it goes down
pop=word('REMOTE DOWN!',qvw,30,tint=(255,220,90))
glow=pop.filter(ImageFilter.GaussianBlur(4)); bg.alpha_composite(glow,(520,240)); bg.alpha_composite(pop,(520,240))
bg.alpha_composite(word('+25',jfo,34),(600,285)); d=ImageDraw.Draw(bg); d.text((680,297),"HEALTH",fill=(120,255,120,255))
d.text((40,H-28),"Mockup: the panel floats at your off wrist (or top left of view); 'REMOTE DOWN!' pops over the droid with SlowMo's short slow.",fill=(170,170,180,255))
bg.convert('RGB').save('remote_hud_mock.png'); print('ok')
