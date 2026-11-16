import math, random, numpy as np, os
os.chdir('/home/claude/bnmock')
src=open('boss_mock.py').read(); exec(src[:src.index('# settled')])
from scipy import ndimage
from PIL import Image, ImageDraw
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
W2=Wad('/home/claude/rig/packs/doom2.wad'); impS=W2.patch('TROOA1').convert('RGBA')
ZX,ZY=6,6*1.4
def spr(n): im=Image.open('/tmp/agur/%s.png'%n).convert('RGBA'); return im.resize((int(im.width*ZX),int(im.height*ZY)),Image.NEAREST)
FR={'A':spr('AGURA1C1'),'F':spr('AGURF1'),'G':spr('AGURG1'),'E':spr('AGURE1')}
def parts_of(path):
    im=Image.open(path).convert('RGBA'); a=np.array(im); lab,n=ndimage.label(a[:,:,3]>40); out=[]
    for i in range(1,n+1):
        m=(lab==i); ys,xs=np.where(m); x0,x1,y0,y1=xs.min(),xs.max()+1,ys.min(),ys.max()+1
        p=a[y0:y1,x0:x1].copy(); p[~m[y0:y1,x0:x1]]=0
        out.append((Image.fromarray(p,'RGBA'),(x0+x1)/2-im.width/2,(y0+y1)/2-im.height/2))
    out.sort(key=lambda q:q[0].width*q[0].height); return out
def ease(t): return 1-(1-t)**3
def tintflat(im,rgb):
    a=np.array(im).astype(float); a[:,:,:3]=np.array(rgb); return Image.fromarray(a.astype(np.uint8),'RGBA')
def pop(im,t,t0):
    s=[0.2,1.35,1.12,1.0][min(3,max(0,t-t0))]; return im.resize((max(1,int(im.width*s)),max(1,int(im.height*s))),Image.NEAREST)
SW,SH=960,900; FLOOR=640; CX=SW//2
def place(im): return (CX-im.width//2, FLOOR-im.height+8)
F=FR['F']; fx,fy=place(F)
WP=[dict(sx=4,sy=13,xh='RSQMBX06',col=(255,70,60),lab=(30,140),brk=96,orb=True),
    dict(sx=52,sy=13,xh='RSQMBX06',col=(255,70,60),lab=(SW-370,140),brk=118,orb=True),
    dict(sx=25,sy=8,xh='RSQMBX01',col=(255,200,50),lab=(30,300),brk=140,orb=False)]
for w in WP: w['x']=fx+int(w['sx']*ZX); w['y']=fy+int(w['sy']*ZY); w['parts']=parts_of('/tmp/xh/%s.png'%w['xh'])
CRY=8; EXP=26; WIN=105; WEND=EXP+WIN; ASM0=EXP+2; END=250
def xh(c,w,t,t0,sc0=1.2):
    n=len(w['parts']); dur=6; span=4; stag=span/max(1,n-1)
    for k,(p,px,py) in enumerate(w['parts']):
        u=(t-t0-k*stag)/dur
        if u<=0: continue
        u=min(1,u); e=ease(u); r=random.Random(k*31+w['sx'])
        ang=(math.atan2(py,px) if abs(px)+abs(py)>2 else r.uniform(0,6.3))+r.uniform(-.5,.5)
        dist=(1-e)*r.uniform(160,230); sc=sc0*(1+(1-e)*0.9); al=e**1.6
        im=tintflat(p,w['col']); im=im.resize((max(1,int(im.width*sc)),max(1,int(im.height*sc))),Image.NEAREST)
        im.putalpha(im.split()[3].point(lambda v,al=al:int(v*al)))
        c.alpha_composite(im,(int(w['x']+px*sc0+math.cos(ang)*dist-im.width/2),int(w['y']+py*sc0+math.sin(ang)*dist-im.height/2)))
def hp(w,t):
    s=w['brk']-22; return 1.0 if t<s else max(0.0,1-(t-s)/22)
def label(c,w,t,h):
    if t<ASM0+8: return
    d=ImageDraw.Draw(c); lx,ly=w['lab']; ax=lx+210 if lx<SW//2 else lx; ay=ly+22
    k=min(1,(t-ASM0-8)/3); d.line((w['x'],w['y'],w['x']+(ax-w['x'])*k,w['y']+(ay-w['y'])*k),fill=w['col']+(255,),width=3)
    if k<1: return
    d.line((lx,ay,lx+210,ay),fill=w['col']+(255,),width=3)
    txt=w.get('name','WEAK POINT!')
    word=banded(F1,txt,2,[mix(w['col'],(255,255,255),.6),w['col'],tuple(int(v*.7) for v in w['col']),tuple(int(v*.45) for v in w['col'])],shade=False)
    c.alpha_composite(word,(lx,ay-word.height-6))
    cols=(tuple(int(v*0.3) for v in w['col']),w['col'],mix(w['col'],(255,255,255),0.55))
    c.alpha_composite(gauge(h,cols,210,18,t),(lx,ay+8))
def boss_row(t,frac,stake,flash,guard):
    h=30; w=400; col=(240,50,40)
    cols=((90,95,110),(180,185,200),(235,240,250)) if guard else (tuple(int(c*0.3) for c in col), col, mix(col,(255,255,255),0.55))
    bar=gauge(frac,cols,w,h,t)
    if stake>0:
        a=int(w*max(0,frac-stake)); b=int(w*frac); bar.alpha_composite(Image.new('RGBA',(max(1,b-a),h-6),(255,205,40,int(225+30*math.sin(t*.5)))),(a,3))
    if flash: bar.alpha_composite(Image.new('RGBA',(w,h),(255,255,255,150)))
    name=banded(F1,BOSSNAME,3,GOLDB); row=[bar]
    if guard: row.append(pill(banded(F1,'GUARD',2,SILVER,shade=False),(12,12,16,215),None,8,10,6))
    row.append(banded(F1,'X3',3,GOLDB))
    return hstack([HD.resize((80,80),Image.NEAREST),vstack([name,hstack(row,10)],6)],14)
dark_imp=impS.copy(); _a=np.array(dark_imp).astype(float); _a[:,:,:3]*=0.45; dark_imp=Image.fromarray(_a.astype(np.uint8),'RGBA').resize((impS.width*2,impS.height*2),Image.NEAREST)
GANG=[(150,FLOOR-30),(SW-150,FLOOR-30),(CX+320,FLOOR+20)]
BACKUP=[(120,FLOOR-10),(SW-120,FLOOR-10),(CX-330,FLOOR+30)]
RED4=[(255,200,190),(255,90,70),(220,30,20),(120,10,10)]
