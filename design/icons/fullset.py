# Style B (owner 11-10): 24 px, shaded, 1 px black outline, a highlight. Full set for review.
from PIL import Image, ImageDraw, ImageFont
import math, os
exec(open(__file__.replace('fullset.py','sheet.py')).read().split("STYLES=")[0])   # helpers: shade, px, outline, gem, flame, glove, shield
N=24
def canvas(): 
    im=Image.new('RGBA',(N,N),(0,0,0,0)); return im, ImageDraw.Draw(im)
def crown(im,col=(250,200,40,255)):
    d=ImageDraw.Draw(im)
    d.polygon([(6,7),(6,2),(9,5),(12,1),(15,5),(18,2),(18,7)],fill=col)
    d.line([(6,7),(18,7)],fill=shade(col,0.7),width=1)
    return im
def crowned_gem(col):
    g=gem(N-4,col,'shade'); im=Image.new('RGBA',(N,N),(0,0,0,0)); im.alpha_composite(g,(2,4))
    im=crown(im); return outline(im)
LADDER=[('1 Common',(170,170,170)),('2 Green',(60,200,70)),('3 Blue',(50,110,230)),('4 Purple',(150,60,200)),
        ('5 Yellow',(240,200,40)),('6 Red',(220,40,40)),('7 FireBlu',(60,190,255)),('8 Gray',(120,120,128)),
        ('9 Abyss',(20,40,90)),('10 Black boss',(60,50,70)),('11 White boss',(240,240,250)),('12 Cyan',(40,220,220)),('13 Brown',(140,90,50))]
tiers=[]
for n,c in LADDER:
    tiers.append((n, crowned_gem(c) if 'boss' in n else gem(N,c,'shade')))

def sym(kind,col):
    im,d=canvas(); c=col+(255,) if len(col)==3 else col; dk=shade(c,0.65); hi=shade(c,1.35)
    if kind=='heart':
        d.ellipse([3,4,12,13],fill=c); d.ellipse([11,4,20,13],fill=c); d.polygon([(3,10),(20,10),(11.5,20)],fill=c)
        d.ellipse([6,6,9,9],fill=hi)
    elif kind=='dagger':
        d.polygon([(11,1),(14,1),(14,14),(12.5,17),(11,14)],fill=(210,215,225,255)); d.rectangle([7,14,18,16],fill=c); d.rectangle([11,16,14,22],fill=dk)
    elif kind=='burst':
        for k in range(8):
            a=k*math.pi/4; x=12+8*math.cos(a); y=12+8*math.sin(a); d.ellipse([x-2,y-2,x+2,y+2],fill=c)
        d.ellipse([8,8,16,16],fill=hi)
    elif kind=='wind':
        for yy,w in ((6,16),(11,12),(16,16)):
            d.line([(3,yy),(3+w,yy)],fill=c,width=2); d.arc([w-1,yy-5,w+7,yy+1],200,90,fill=c,width=2)
    elif kind=='drops':
        for x,y,r in ((7,8,3),(15,6,3),(12,15,4)):
            d.ellipse([x-r,y-r+2,x+r,y+r+2],fill=c); d.polygon([(x-r+1,y+1),(x+r-1,y+1),(x,y-r-2)],fill=c)
        d.ellipse([3,19,21,22],fill=dk)
    elif kind=='respawn':
        d.arc([3,3,21,21],30,330,fill=c,width=3); d.polygon([(17,1),(22,6),(15,8)],fill=c)
        d.ellipse([9,9,15,15],fill=(230,230,230,255))
    elif kind=='coin':
        d.ellipse([2,2,21,21],fill=c); d.ellipse([5,5,18,18],outline=dk,width=1); d.text((8,6),"x5",fill=dk)
    elif kind=='teleport':
        for k in range(12):
            a=k*math.pi/6; x=12+8*math.cos(a); y=12+8*math.sin(a)
            if k%2==0: d.rectangle([x-1,y-1,x+1,y+1],fill=c)
        d.polygon([(12,5),(14,11),(20,12),(14,13),(12,19),(10,13),(4,12),(10,11)],fill=hi)
    elif kind=='lunge':
        d.polygon([(2,9),(13,9),(13,4),(22,12),(13,20),(13,15),(2,15)],fill=c); d.line([(2,10),(12,10)],fill=hi)
    elif kind=='clones':
        for x in (5,13):
            d.ellipse([x,3,x+6,9],fill=c); d.rectangle([x-1,10,x+7,20],fill=c if x==13 else dk)
    elif kind=='boom':
        pts=[]
        for k in range(16):
            a=k*math.pi/8; r=10 if k%2==0 else 5; pts.append((12+r*math.cos(a),12+r*math.sin(a)))
        d.polygon(pts,fill=c); d.ellipse([8,8,16,16],fill=(255,230,120,255))
    elif kind=='ankh':
        d.ellipse([8,2,16,10],outline=c,width=3); d.rectangle([10,10,14,22],fill=c); d.rectangle([5,11,19,14],fill=c)
    elif kind=='magnet':
        d.arc([3,2,21,20],180,360,fill=c,width=5); d.rectangle([3,10,8,20],fill=c); d.rectangle([16,10,21,20],fill=c)
        d.rectangle([3,17,8,21],fill=(230,230,230,255)); d.rectangle([16,17,21,21],fill=(230,230,230,255))
    elif kind=='fireball':
        d.ellipse([9,8,20,19],fill=c); d.polygon([(2,6),(12,9),(10,13)],fill=dk); d.polygon([(2,18),(12,16),(11,12)],fill=dk); d.ellipse([12,10,16,14],fill=hi)
    elif kind=='snow':
        for k in range(3):
            a=k*math.pi/3; dx=9*math.cos(a); dy=9*math.sin(a); d.line([(12-dx,12-dy),(12+dx,12+dy)],fill=c,width=2)
        d.ellipse([10,10,14,14],fill=hi)
    elif kind=='bolt':
        d.polygon([(14,1),(5,13),(11,13),(8,23),(19,9),(13,9),(17,1)],fill=c); d.line([(13,3),(8,11)],fill=hi)
    elif kind=='titan':
        d.polygon([(2,21),(8,6),(12,12),(16,3),(22,21)],fill=c); d.polygon([(16,3),(18,8),(14,8)],fill=hi)
    elif kind=='skull':
        d.ellipse([4,2,20,17],fill=c); d.rectangle([7,14,17,21],fill=c); d.ellipse([7,8,11,12],fill=(20,20,20,255)); d.ellipse([13,8,17,12],fill=(20,20,20,255))
        for x in (8,11,14): d.line([(x,18),(x,21)],fill=(20,20,20,255))
    elif kind=='ghost':
        d.ellipse([4,2,20,16],fill=c); d.rectangle([4,9,20,19],fill=c)
        for x in (4,10,16): d.polygon([(x,19),(x+6,19),(x+3,22)],fill=c)
        d.ellipse([8,7,11,11],fill=(30,30,40,255)); d.ellipse([13,7,16,11],fill=(30,30,40,255))
    elif kind=='balloon':
        d.ellipse([5,1,19,16],fill=c); d.polygon([(10,16),(14,16),(12,18)],fill=dk); d.line([(12,18),(10,23)],fill=(220,220,220,255)); d.ellipse([8,4,11,7],fill=hi)
    elif kind=='slime':
        d.ellipse([2,13,22,21],fill=dk); d.ellipse([4,12,20,19],fill=c); d.ellipse([7,13,11,15],fill=hi)
        d.ellipse([15,6,19,11],fill=c); d.polygon([(15,9),(19,9),(17,3)],fill=c); d.ellipse([16,7,17,8],fill=hi)
    elif kind=='clones3':
        for x,y,s in ((2,9,6),(9,4,7),(16,9,6)):
            d.ellipse([x,y,x+s,y+s],fill=c); d.polygon([(x-1,y+s+9),(x+s+1,y+s+9),(x+s,y+s),(x,y+s)],fill=c if s==7 else dk)
            d.rectangle([x+1,y+2,x+2,y+3],fill=(255,255,255,255)); d.rectangle([x+s-2,y+2,x+s-1,y+3],fill=(255,255,255,255))
    elif kind=='titanhead':
        d.polygon([(3,3),(7,9),(5,10)],fill=(230,225,210,255)); d.polygon([(21,3),(17,9),(19,10)],fill=(230,225,210,255))
        d.ellipse([5,6,19,21],fill=c); d.rectangle([8,12,10,14],fill=(255,230,60,255)); d.rectangle([14,12,16,14],fill=(255,230,60,255))
        d.line([(9,18),(15,18)],fill=dk,width=2); d.polygon([(7,4),(7,0),(10,2),(12,0),(14,2),(17,0),(17,4)],fill=(250,200,40,255))
    elif kind=='dodge':
        d.polygon([(1,12),(7,6),(7,10),(11,10),(11,14),(7,14),(7,18)],fill=c); d.polygon([(23,12),(17,6),(17,10),(13,10),(13,14),(17,14),(17,18)],fill=c)
        d.line([(12,2),(12,22)],fill=hi,width=1)
    elif kind=='anvil':
        d.polygon([(2,6),(21,6),(18,11),(15,11),(15,15),(19,20),(5,20),(9,15),(9,11),(5,11)],fill=c); d.line([(3,7),(20,7)],fill=hi)
    elif kind=='aura':
        d.ellipse([1,1,22,22],outline=c,width=2); d.polygon([(7,6),(17,6),(17,12),(12,18),(7,12)],fill=c); d.polygon([(12,6),(17,6),(17,12),(12,18)],fill=dk)
    elif kind=='homing':
        d.arc([2,4,20,22],200,330,fill=dk,width=2); d.polygon([(17,4),(22,9),(15,11)],fill=dk); d.ellipse([12,2,21,11],fill=c); d.ellipse([15,4,18,7],fill=hi)
    elif kind=='skullheart':
        d.ellipse([3,1,17,14],fill=c); d.rectangle([6,11,14,17],fill=c); d.ellipse([6,6,9,9],fill=(20,20,20,255)); d.ellipse([11,6,14,9],fill=(20,20,20,255))
        r=(230,30,40,255); d.ellipse([13,13,18,18],fill=r); d.ellipse([17,13,22,18],fill=r); d.polygon([(13,16),(22,16),(17.5,22)],fill=r)
    elif kind=='hybrid':
        d.pieslice([2,2,21,21],90,270,fill=c); d.pieslice([2,2,21,21],270,90,fill=(60,200,220,255)); d.line([(12,2),(12,21)],fill=(20,20,20,255))
    elif kind=='mystery':
        d.ellipse([3,3,20,20],fill=c); d.text((9,6),"?",fill=(255,255,255,255))
    return outline(im)

CHAMPS=[('Red: 2x health','heart',(220,40,40)),('Dark Red: comes back','respawn',(150,20,30)),('Orange: explodes','boom',(240,120,30)),
 ('Yellow: 2x speed','bolt',(250,220,40)),('Green: teleports','teleport',(60,200,70)),('Dark Green: damaging creep','slime',(60,170,40)),
 ('Light Blue: wind','wind',(60,220,230)),('Blue: bursts into shots','burst',(60,120,240)),('Indigo: weak clones','clones3',(90,70,200)),
 ('Violet: homing shots','homing',(170,70,220)),('Pink: resurrects','ankh',(250,120,190)),('Black: 2x damage','dagger',(70,60,80)),
 ('Grey: dodges','dodge',(150,150,155)),('White: slowing creep','snow',(235,240,255)),('Bronze: tough, slow','anvil',(190,120,60)),
 ('Silver: magnet','magnet',(200,205,215)),('Gold: shields its friends','aura',(240,200,50)),
 ('Floating (balloon)','balloon',(240,70,90)),('Ethereal','ghost',(200,220,240)),('Hybrid','hybrid',(240,120,30)),
 ('Undying (guardian heart)','skullheart',(225,220,200)),('Titan (boss)','titanhead',(160,90,60))]
champs=[(n,sym(k,c)) for n,k,c in CHAMPS]
misc=[('Glove (Melee hands)',glove(N,'shade')),('Glove (boxing, off hand)',glove(N,'shade').transpose(Image.FLIP_LEFT_RIGHT)),('Miniboss shield',shield(N,'shade'))]

font=ImageFont.load_default(); Z=3; cw=150; ch=24*Z+28; cols=6
groups=[('Tier icons (RSQ Monsters ladder; bosses crowned)',tiers),('Champion powers',champs),('Gloves and shield',misc)]
H=20; 
for g,it in groups: H+=22+((len(it)+cols-1)//cols)*ch
sheet=Image.new('RGBA',(20+cw*cols,H+10),(28,28,34,255)); d=ImageDraw.Draw(sheet); y=12
for g,items in groups:
    d.text((12,y),g,fill=(255,210,90,255),font=font); y+=20
    for i,(name,ic) in enumerate(items):
        x=12+(i%cols)*cw; yy=y+(i//cols)*ch
        sheet.alpha_composite(ic.resize((N*Z,N*Z),Image.NEAREST),(x,yy))
        sheet.alpha_composite(ic,(x+N*Z+6,yy+N*Z-N))
        d.text((x,yy+N*Z+4),name,fill=(210,210,210,255),font=font)
    y+=((len(items)+cols-1)//cols)*ch+6
sheet.convert('RGB').save('icon_set_B.png'); print(sheet.size)
os.makedirs('B',exist_ok=True)
for n,ic in tiers+champs+misc: ic.save('B/'+n.split(':')[0].replace(' ','_').replace('(','').replace(')','')+'.png')
