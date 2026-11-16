import math, numpy as np
from PIL import Image, ImageDraw, ImageFilter
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])   # fonts (F2 = Score Small) + Wad + helpers
W2=Wad('/home/claude/rig/packs/doom2.wad')
imp=W2.patch('TROOA1').convert('RGBA')
Z=4
def tint(im, rgb):
    a=np.array(im).astype(float); L=a[:,:,:3].mean(2,keepdims=True)/255.0
    o=a.copy(); o[:,:,:3]=np.clip(L*np.array(rgb)*1.6,0,255); return Image.fromarray(o.astype(np.uint8),'RGBA')
YEL=(255,214,60); CYA=(90,230,255)
body=tint(imp,YEL); body=body.resize((body.width*Z,body.height*Z),Image.NEAREST)
icY=Image.open('/tmp/icB/7_Yellow.png').convert('RGBA'); icC=Image.open('/tmp/icB/5_Cyan.png').convert('RGBA')
icY=icY.resize((48,48),Image.NEAREST); icC=icC.resize((48,48),Image.NEAREST)
def word(s, rgb, z=4):
    m=lum_mask_from([F2.get(ord(c)) for c in s],gap=1,thr=75); m=m.resize((m.width*z,m.height*z),Image.NEAREST)
    a=np.array(m).astype(float); h,w=a.shape; o=np.zeros((h,w,4),np.uint8)
    top=rgb; bot=tuple(min(255,int(c*0.6+255*0.4)) for c in rgb)
    for y in range(h):
        c=top if y<h/2 else bot; k=0.55+0.45*a[y]/255
        for i in range(3): o[y,:,i]=np.clip(c[i]*k*1.1,0,255)
        o[y,:,3]=np.where(a[y]>0,255,0)
    im=Image.fromarray(o,'RGBA'); pad=3; out=Image.new('RGBA',(w+6,h+6),(0,0,0,0)); al=im.split()[3]
    for dx in range(-pad,pad+1):
        for dy in range(-pad,pad+1): out.paste(Image.new('RGBA',im.size,(8,8,10,255)),(pad+dx,pad+dy),al)
    out.alpha_composite(im,(pad,pad)); return out
def outline(im, rgb, rad):
    al=im.split()[3]; g=al.filter(ImageFilter.MaxFilter(rad*2+1)).filter(ImageFilter.GaussianBlur(rad))
    o=Image.new('RGBA',im.size,rgb+(0,)); o.putalpha(g); return o
PW,PH=360,420
def bg():
    p=Image.new('RGBA',(PW,PH),(34,26,22,255)); d=ImageDraw.Draw(p)
    for y in range(PH): d.line((0,y,PW,y),fill=(int(30+20*y/PH),int(24+12*y/PH),int(20+8*y/PH),255))
    d.rectangle((0,PH-70,PW,PH),fill=(52,44,38,255)); return p
def panel(kind,t):
    p=bg(); bx=(PW-body.width)//2; by=PH-70-body.height+8
    pulse=0.5+0.5*math.sin(t*2*math.pi/24)
    if kind=='aura':
        pad=24; big=Image.new('RGBA',(body.width+pad*2,body.height+pad*2),(0,0,0,0)); big.alpha_composite(body,(pad,pad))
        o=outline(big,CYA,int(5+4*pulse)); o.putalpha(o.split()[3].point(lambda v:int(v*(0.55+0.45*pulse))))
        p.alpha_composite(o,(bx-pad,by-pad))
        for i in range(10):   # rising motes
            ph=(t*3+i*37)%120; x=bx+20+(i*53)%(body.width-40); y=by+body.height-ph*2
            if y>by-20: ImageDraw.Draw(p).rectangle((x,y,x+3,y+3),fill=CYA+(int(200*(1-ph/120)),))
    p.alpha_composite(body,(bx,by))
    iy=by-60
    if kind=='icon':
        bob=int(2*math.sin(t*2*math.pi/24))
        p.alpha_composite(icY,(PW//2-52,iy+bob)); p.alpha_composite(icC,(PW//2+4,iy+bob))
    else:
        p.alpha_composite(icY,(PW//2-24,iy))
    if kind=='word':
        w=word('CYAN',CYA if (t//6)%2==0 else tuple(min(255,int(c*0.5+127)) for c in CYA))
        p.alpha_composite(w,(PW//2-w.width//2,iy-w.height-8+int(2*math.sin(t*2*math.pi/24))))
    return p
LABELS=[('icon','A  ICON','its tier icon + a second icon'),('aura','B  GLOW','a pulsing outline + motes'),('word','C  WORD','the colour named over it')]
frames=[]
for t in range(24):
    sh=Image.new('RGBA',(PW*3+40,PH+64),(18,17,22,255)); d=ImageDraw.Draw(sh)
    for i,(k,a,b) in enumerate(LABELS):
        sh.alpha_composite(panel(k,t),(10+i*(PW+10),54)); d.text((14+i*(PW+10),10),a,fill=(255,226,120)); d.text((14+i*(PW+10),28),b,fill=(190,190,200))
    d.text((14,sh.height-14),'A Yellow Imp (yellow tier icon) with a Cyan second colour. Mockup, not in engine.',fill=(120,120,135))
    frames.append(sh.convert('RGB'))
q=[f.quantize(128,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
q[0].save('/home/claude/secondcol/second_colour_marks.gif',save_all=True,append_images=q[1:],duration=60,loop=0,optimize=True)
frames[6].save('/home/claude/secondcol/second_colour_marks.png'); print('ok')
