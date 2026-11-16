import sys,os,json,math,random,numpy as np
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'readme_art_lib.py')).read().split("if __name__")[0])
from PIL import ImageDraw
OUT=sys.argv[2]
E=[tuple(e) for e in json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'mod_web_edges.json')))]
RC=ROOT+'/MonsterRecolour/rsrecolour/'
M={ # mod: (label, sprite, colour)
'GunBonsaiOffhandVR':('GUN BONSAI VR','BOSSA1','yellow'),'Accessibility':('ACCESSIBILITY','HEADA1','cyan'),'Score':('SCORE','FATTA1','green'),'SlowMo':('SLOWMO','PAINA1','purple'),
'Miniboss':('BOSS','CYBRA1','black'),'VisualRewards':('VISUAL REWARDS','HEADA1','fireblu'),'TacticalRig':('TACTICAL RIG','CPOSA1','green'),'GunCards':('GUN CARDS','SPOSA1','blue'),
'FlashFlare':('FLASH + FLARE','TROOA1','yellow'),'Grenade':('GRENADE','FATTA1','red'),'DistanceGrab':('DISTANCE GRAB','SARGA1','cyan'),'LaserSight':('LASER SIGHT','BSPIA1D1','red'),
'QuestSaber':('SABER','BOSSA1','blue'),'GlowInTheDark':('GLOW IN THE DARK','PAINA1','fireblu'),'Graveyard':('GRAVEYARD','SKELA1D1','gray'),'Monsters':('MONSTERS','TROOA1','purple'),
'Melee':('MELEE','SARGA1','red'),'ShieldSaw':('SHIELDSAW','BSPIA1D1','brown'),'Wheel':('WHEEL','SPIDA1D1','white'),'Whip':('WHIP','SKELA1D1','brown'),'Grapple':('GRAPPLE','TROOA1','abyss')}
W,H=1400,1300; CW,CH=176,138
HUB=['GunBonsaiOffhandVR','Accessibility','Score','SlowMo']
RING=['Miniboss','Melee','QuestSaber','ShieldSaw','Whip','Grapple','Grenade','DistanceGrab','TacticalRig','Wheel','GunCards','LaserSight','FlashFlare','GlowInTheDark','Graveyard','Monsters','VisualRewards']
cx,cy=W/2,630; pos={}
for m,(dx,dy) in zip(HUB,[(-150,-95),(150,-95),(-150,95),(150,95)]): pos[m]=(cx+dx,cy+dy)
for i,m in enumerate(RING):
    a=-math.pi/2+2*math.pi*i/len(RING); pos[m]=(cx+585*math.cos(a),cy+455*math.sin(a))
random.seed(7)
def txt(s,col,sc=2,F=F2,outline=None):
    im=paint(mask(s,F),col,col)
    if outline is not None: im=boxed(im,1,outline)
    return im.resize((im.width*sc,im.height*sc),Image.NEAREST)
def card(m):
    lab,sp,col=M[m]; c=Image.new('RGBA',(CW,CH),(238,234,220,255)); d=ImageDraw.Draw(c)
    d.rectangle((8,8,CW-9,CH-34),fill=(24,20,30,255))
    im=Image.open(RC+col+'/'+sp+'.png').convert('RGBA'); k=min((CW-24)/im.width,(CH-48)/im.height,1.6)
    im=im.resize((max(1,int(im.width*k)),max(1,int(im.height*k))),Image.NEAREST)
    c.alpha_composite(im,((CW-im.width)//2,CH-36-im.height))
    t=txt(lab,(30,26,30),2)
    if t.width>CW-10: t=txt(lab,(30,26,30),1).resize((CW-12,14),Image.NEAREST)
    c.alpha_composite(t,((CW-t.width)//2,CH-27))
    d.rectangle((0,0,CW-1,CH-1),outline=(120,110,90,255))
    return c.rotate(random.uniform(-5,5),resample=Image.NEAREST,expand=True)
CARDS={m:card(m) for m in M}
def cork():
    rs=np.random.RandomState(3); a=np.zeros((H,W,3),np.uint8); a[:]=(150,104,62)
    n=rs.rand(H//6+1,W//6+1); n=np.kron(n,np.ones((6,6)))[:H,:W]
    a[n>0.86]=(132,90,52); a[n<0.12]=(166,118,72)
    im=Image.fromarray(a,'RGB').convert('RGBA'); d=ImageDraw.Draw(im)
    for i in range(14): d.rectangle((i,i,W-1-i,H-1-i),outline=(70,44,24,255))
    return im
CORK=cork()
def yarn(d,a,b,col,w):
    (x0,y0),(x1,y1)=pos[a],pos[b]; y0-=CH/2-6; y1-=CH/2-6
    L=math.hypot(x1-x0,y1-y0); mx,my=(x0+x1)/2,(y0+y1)/2+L*0.10
    pts=[((1-t)**2*x0+2*(1-t)*t*mx+t*t*x1,(1-t)**2*y0+2*(1-t)*t*my+t*t*y1) for t in [i/24 for i in range(25)]]
    d.line(pts,fill=col,width=w,joint='curve')
TITLE=boxed(paint(mask("IT'S ALL CONNECTED"),*COL['gold']),1); TITLE=TITLE.resize((TITLE.width*4,TITLE.height*4),Image.NEAREST)
def frame(sel,col,note,glow=()):
    im=CORK.copy(); d=ImageDraw.Draw(im)
    for e in E:
        if e not in sel: yarn(d,e[0],e[1],(120,28,24,255) if sel else (176,30,26,255),2)
    for e in E:
        if e in sel: yarn(d,e[0],e[1],(20,14,10,255),7); yarn(d,e[0],e[1],col+(255,),4)
    for m,c in CARDS.items():
        x,y=pos[m]; px,py=int(x-c.width/2),int(y-c.height/2)
        if m in glow: d.rectangle((px-6,py-6,px+c.width+5,py+c.height+5),fill=col+(255,))
        sh=Image.new('RGBA',c.size,(0,0,0,0)); sh.paste((30,18,8,120),(0,0),c.split()[3]); im.alpha_composite(sh,(px+5,py+6)); im.alpha_composite(c,(px,py))
        d=ImageDraw.Draw(im); d.ellipse((x-7,y-CH/2-1,x+7,y-CH/2+13),fill=(210,30,30,255),outline=(60,10,10,255))
    im.alpha_composite(TITLE,((W-TITLE.width)//2,22))
    t=txt(note,(40,30,10),3); nw,nh=t.width+56,t.height+36; nx,ny=(W-nw)//2,H-nh-34
    d.rectangle((nx+6,ny+7,nx+nw+6,ny+nh+7),fill=(40,24,10,150)); d.rectangle((nx,ny,nx+nw,ny+nh),fill=(250,224,96,255),outline=(150,120,30,255))
    im.alpha_composite(t,(nx+28,ny+18)); return im
inn=lambda m:[e for e in E if e[1]==m]; out=lambda m:[e for e in E if e[0]==m]
n=lambda m:len(inn(m))
FR=[([], (0,0,0), f"{len(E)} STRINGS. EVERY ONE IS A REAL CALL IN THE CODE.",()),
 (inn('GunBonsaiOffhandVR'),(255,200,40),f"ALL {n('GunBonsaiOffhandVR')} OTHER MODS ASK GUN BONSAI VR FOR UPGRADES.",('GunBonsaiOffhandVR',)),
 (inn('Accessibility'),(60,220,240),f"{n('Accessibility')} MODS ASK ACCESSIBILITY HOW YOU PLAY.",('Accessibility',)),
 (inn('Score'),(110,230,80),f"{n('Score')} MODS WANT THEIR POINTS.",('Score',)),
 (inn('SlowMo'),(200,120,255),f"{n('SlowMo')} MODS WANT YOUR TIME.",('SlowMo',)),
 (inn('Miniboss'),(255,90,70),f"{n('Miniboss')} MODS KEEP CHECKING IF THE BOSS IS HOME.",('Miniboss',)),
 (out('TacticalRig'),(255,150,40),f"THE TACTICAL RIG ASKS {len(out('TacticalRig'))} OTHER MODS. NOSY.",('TacticalRig',)),
 (out('Whip')+out('Grapple'),(240,240,240),"NOBODY EVER ASKS THE WHIP OR THE GRAPPLE ANYTHING.",('Whip','Grapple')),
 (list(E),(255,60,50),"NO MOD NEEDS ANOTHER. THEY JUST TALK. A LOT.",())]
for s,c,t,g in FR: print(len(s),t)
frames=[frame(set(s),c,t,g).convert('RGB') for s,c,t,g in FR]
pal=frames[-1].quantize(96,method=Image.MEDIANCUT,dither=Image.Dither.NONE)
q=[f.quantize(96,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
q[0].save(OUT+'/mod_web.gif',save_all=True,append_images=q[1:],duration=[2600]+[2400]*(len(q)-2)+[3600],loop=0,optimize=True)
frames[-1].save(OUT+'/mod_web_still.png'); print(os.path.getsize(OUT+'/mod_web.gif'))
