# Three icon styles, one sample row each: tier gems (5 ladder colours), a Champion power, the glove, the shield.
from PIL import Image, ImageDraw, ImageFont
import math
OUT=(0,0,0,255)
def shade(c,f): return tuple(max(0,min(255,int(v*f))) for v in c[:3])+(255,)
TIERS=[('Common',(170,170,170)),('Green',(60,200,70)),('Red',(220,40,40)),('Black',(60,50,70)),('White',(240,240,250))]

def px(im,x,y,c):
    if 0<=x<im.width and 0<=y<im.height: im.putpixel((x,y),c)

def outline(im,col=OUT):
    w,h=im.size; src=im.copy()
    for y in range(h):
        for x in range(w):
            if src.getpixel((x,y))[3]==0:
                for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
                    xx,yy=x+dx,y+dy
                    if 0<=xx<w and 0<=yy<h and src.getpixel((xx,yy))[3]>0 and src.getpixel((xx,yy))!=col:
                        im.putpixel((x,y),col); break
    return im

# ---------- shape masks at size n (inner area n-2 for the outline) ----------
def gem(n,col,style):
    im=Image.new('RGBA',(n,n),(0,0,0,0)); c=(n-1)/2; r=(n-3)/2
    for y in range(n):
        for x in range(n):
            if abs(x-c)+abs(y-c)<=r:
                top = (y<c and x<=c+0.5)
                f=1.25 if (x-c)+(y-c)<-r*0.35 else (0.7 if (x-c)+(y-c)>r*0.35 else 1.0)
                if style=='flat': f=1.0 if y<c else 0.75
                px(im,x,y,shade(col,f))
    if style!='flat':
        px(im,int(c-r*0.4),int(c-r*0.4),(255,255,255,255))
    return outline(im)

def flame(n,style):
    im=Image.new('RGBA',(n,n),(0,0,0,0)); d=ImageDraw.Draw(im)
    s=n/16
    pts=[(8*s,1*s),(12.5*s,7*s),(13*s,11*s),(10.5*s,14.5*s),(5.5*s,14.5*s),(3*s,11*s),(4*s,7*s),(6*s,9*s)]
    d.polygon(pts,fill=(230,70,20,255))
    d.polygon([(8*s,6*s),(10.5*s,10*s),(10*s,13.5*s),(6*s,13.5*s),(5.5*s,10.5*s)],fill=(255,190,40,255))
    if style!='flat': d.polygon([(8*s,10*s),(9*s,12*s),(8*s,13.5*s),(7*s,12*s)],fill=(255,250,200,255))
    return outline(im)

def glove(n,style):
    im=Image.new('RGBA',(n,n),(0,0,0,0)); d=ImageDraw.Draw(im); s=n/16
    red=(225,35,35,255); dk=(150,15,20,255); hi=(250,140,140,255); cuff=(250,175,30,255)
    d.rounded_rectangle([2.5*s,2*s,13.5*s,10.5*s],radius=int(3.2*s),fill=red)
    d.rectangle([4*s,10*s,12*s,14*s],fill=cuff)
    d.rectangle([4*s,13*s,12*s,14*s],fill=(180,110,10,255))
    if style!='flat':
        d.line([(4*s,3.5*s),(9*s,3.5*s)],fill=hi,width=max(1,int(s)))
        d.rounded_rectangle([9*s,5*s,13.5*s,9*s],radius=int(1.5*s),outline=dk,width=max(1,int(s*0.8)))
        d.line([(3*s,9.5*s),(13*s,9.5*s)],fill=dk,width=max(1,int(s*0.8)))
    else:
        d.rectangle([9*s,5*s,13*s,8.5*s],fill=dk)
    return outline(im)

def shield(n,style):
    im=Image.new('RGBA',(n,n),(0,0,0,0)); d=ImageDraw.Draw(im); s=n/16
    body=(190,195,210,255); dk=(120,125,140,255)
    d.polygon([(2*s,2*s),(14*s,2*s),(14*s,8*s),(8*s,14.5*s),(2*s,8*s)],fill=body)
    d.polygon([(8*s,2*s),(14*s,2*s),(14*s,8*s),(8*s,14.5*s)],fill=dk if style!='flat' else body)
    d.rectangle([7*s,4*s,9*s,11*s],fill=(200,40,40,255))
    d.rectangle([5*s,6*s,11*s,8*s],fill=(200,40,40,255))
    return outline(im)

def badge(icon,n,ring):
    # style C: icon on a round coin with a coloured rim
    im=Image.new('RGBA',(n,n),(0,0,0,0)); d=ImageDraw.Draw(im)
    d.ellipse([0,0,n-1,n-1],fill=OUT); d.ellipse([1,1,n-2,n-2],fill=ring); d.ellipse([3,3,n-4,n-4],fill=(25,25,32,255))
    k=n-8; ic=icon.resize((k,k),Image.NEAREST); im.alpha_composite(ic,(4,4)); return im

STYLES=[('A  16 px, flat two-tone (like the crowned skull)',16,'flat',False),
        ('B  24 px, shaded with a highlight (chunky, like your glove refs)',24,'shade',False),
        ('C  24 px on a round coin (icon inside a coloured rim)',24,'shade',True)]
Z=4; pad=18
font=ImageFont.load_default()
rows=[]
for label,n,st,coin in STYLES:
    icons=[gem(n,c,st) for _,c in TIERS]+[flame(n,st),glove(n,st),shield(n,st)]
    if coin:
        rims=[c+(255,) for _,c in TIERS]+[(230,90,20,255),(225,35,35,255),(190,195,210,255)]
        icons=[badge(gem(n-6,c,st) if i<5 else [flame,glove,shield][i-5](n-6,st),n,rims[i]) for i,(c) in enumerate([t[1] for t in TIERS]+[None]*3)]
    rows.append((label,icons))
cell=24*Z+pad
W=pad+cell*8; H=40+len(rows)*(cell+40)+30
sheet=Image.new('RGBA',(W,H),(28,28,34,255)); d=ImageDraw.Draw(sheet)
names=[t[0] for t in TIERS]+['Champion','Glove','Shield']
y=20
for label,icons in rows:
    d.text((pad,y),label,fill=(255,210,90,255),font=font); y+=18
    for i,ic in enumerate(icons):
        big=ic.resize((ic.width*Z,ic.height*Z),Image.NEAREST)
        x=pad+i*cell+(cell-pad-big.width)//2
        sheet.alpha_composite(big,(x,y+(24*Z-big.height)//2))
        # actual size beside
        sheet.alpha_composite(ic,(pad+i*cell,y+24*Z+4))
        d.text((pad+i*cell+ic.width+4,y+24*Z+4),names[i],fill=(200,200,200,255),font=font)
    y+=cell+22
d.text((pad,H-22),"Tier gems: Common, Green, Red, Black, White (5 of 13). Champion: a sample power. Shown 4x, real size under each.",fill=(150,150,160,255),font=font)
sheet.convert('RGB').save('icon_styles.png')
print(sheet.size)
