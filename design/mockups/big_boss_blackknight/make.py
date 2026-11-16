import math, random, numpy as np, os
os.chdir('/home/claude/bnmock')
src=open('boss_mock.py').read(); exec(src[:src.index('# settled')])
from scipy import ndimage
from PIL import Image, ImageDraw
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
W2=Wad('/home/claude/rig/packs/doom2.wad'); impS=W2.patch('TROOA1').convert('RGBA')
ZX,ZY=5.2,5.2*1.2
def spr(n): im=Image.open('/tmp/dknt/%s.png'%n).convert('RGBA'); return im.resize((int(im.width*ZX),int(im.height*ZY)),Image.NEAREST)
FR={'A':spr('DKNTA1'),'F':spr('DKNTH1'),'P':spr('DKNTP1'),'Q':spr('DKNTQ1'),'U':spr('DKNTU1')}
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
WP=[dict(sx=5,sy=21,xh='RSQMBX02',col=(255,70,60),lab=(30,140),brk=96,orb=True,name='SWORD ARM!'),
    dict(sx=44,sy=18,xh='RSQMBX09',col=(120,200,255),lab=(SW-370,140),brk=118,orb=True,name='SHIELD ARM!'),
    dict(sx=28,sy=12,xh='RSQMBX01',col=(255,200,50),lab=(30,300),brk=140,orb=False,name='WEAK POINT!')]
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
    txt=w['name']
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
    name=banded(F1,'THE BLACK KNIGHT',3,GOLDB); row=[bar]
    if guard: row.append(pill(banded(F1,'GUARD',2,SILVER,shade=False),(12,12,16,215),None,8,10,6))
    row.append(banded(F1,'X3',3,GOLDB))
    return hstack([HD.resize((80,80),Image.NEAREST),vstack([name,hstack(row,10)],6)],14)
_hk=W2.patch('BOSSA1').convert('RGBA'); _a=np.array(_hk).astype(float); _L=_a[:,:,:3].mean(2,keepdims=True)/255; _a[:,:,:3]=np.clip(_L*np.array([150,60,50])*1.6,0,255); dark_imp=Image.fromarray(_a.astype(np.uint8),'RGBA').resize((_hk.width*2,_hk.height*2),Image.NEAREST)
GANG=[(150,FLOOR-30),(SW-150,FLOOR-30),(CX+320,FLOOR+20)]
BACKUP=[(120,FLOOR-10),(SW-120,FLOOR-10),(CX-330,FLOOR+30)]
RED4=[(255,200,190),(255,90,70),(220,30,20),(120,10,10)]
frames=[]
for t in range(END):
    c=Image.new('RGBA',(SW,SH),(20,18,22,255)); d=ImageDraw.Draw(c,'RGBA')
    d.rectangle((0,FLOOR-20,SW,SH),fill=(36,32,34,255))
    sm=Image.new('RGBA',(SW,SH),(0,0,0,0)); sd=ImageDraw.Draw(sm)
    for k in range(5):   # his poison smoke drifting
        sx=(k*230+t*2)%SW; pass
    c.alpha_composite(sm)
    broke=[t>=w['brk'] for w in WP]; orbs_out=broke[0] and broke[1]
    if t<EXP: im=FR['P'] if (t//3)%2==0 else FR['Q']
    elif t<WEND+4: im=FR['F']
    else: im=FR['U']
    gx=0
    if True:
        x,y=place(im); c.alpha_composite(im,(x+gx,y))
    if t<EXP:   # the shield is up: your shots bounce back
        cr=pop(banded(F1,'NONE SHALL PASS!',3,RED4,shade=False),t,0); c.alpha_composite(cr,(CX-cr.width//2,FLOOR-600))
        for k in range(4):
            u=(t*3+k*9)%26; bx=CX+40-u*14+k*20; by=FLOOR-260+k*30-u*4
            d.ellipse((bx-5,by-5,bx+5,by+5),fill=(255,240,160,255))
    if EXP<=t<EXP+25:
        cr=pop(banded(F1,'SHIELD DOWN!',3,GOLDB,shade=False),t,EXP); c.alpha_composite(cr,(CX-cr.width//2+160,FLOOR-560))
    # the charge orbs in his hands grow while EXPOSED! runs
    if False:
        g=min(1,(t-CRY)/WIN)
        for w in WP[:2]:
            if t>=w['brk']: continue
            r=int(14+30*g+4*math.sin(t*.8)); ob=Image.new('RGBA',(SW,SH),(0,0,0,0)); ImageDraw.Draw(ob).ellipse((w['x']-r,w['y']-r,w['x']+r,w['y']+r),fill=(255,60,40,150)); c.alpha_composite(ob); d=ImageDraw.Draw(c,'RGBA'); d.ellipse((w['x']-r//2,w['y']-r//2,w['x']+r//2,w['y']+r//2),fill=(255,220,200,230))
    frac=1.0-0.1*sum(broke); perfect=all(broke)
    if perfect: frac=max(0.5,0.7-0.2*min(1,(t-WP[2]['brk'])/5))
    if EXP<=t<WEND:
        ex=pop(banded(F1,'EXPOSED!',4,[(255,240,200),(255,200,60),(235,130,20),(140,60,10)],shade=False),t,EXP)
        c.alpha_composite(ex,(CX-ex.width//2,24))
        left=max(0,WIN-(t-EXP))/35; ss=sevenseg('%d:%02d'%(int(left),int((left%1)*100)),(255,42,26),40); c.alpha_composite(ss,(CX-ss.width//2,24+ex.height+8))
        # the challenge: his nail mines bouncing at you
        for k in range(0):
            v=(t-EXP-10-k*30)
            if 0<=v<30:
                mx=200+k*260; my=SH-230
                if v<20: d.ellipse((mx-40,my-12,mx+40,my+12),outline=(255,60,40,255 if (v//3)%2==0 else 90),width=4)
                else: fl=Image.new('RGBA',(60,200),(255,120,40,170)); c.alpha_composite(fl,(mx-30,my-200))
        for w in WP:
            if t>=w['brk']:
                u=t-w['brk']
                if u<10:
                    r=14+u*10; d.ellipse((w['x']-r,w['y']-r,w['x']+r,w['y']+r),outline=(255,255,255,max(0,255-u*25)),width=4)
                    b=banded(F1,'-10%',3,GOLDB,shade=False); c.alpha_composite(b,(w['x']-b.width//2,w['y']-60-u*4))
                continue
            xh(c,w,t,ASM0+WP.index(w)*3); label(c,w,t,hp(w,t))
            if w['brk']-22<=t<w['brk'] and t%3==0:
                r=random.Random(t*7+w['sx']); hx=w['x']+r.randint(-12,12); hy=w['y']+r.randint(-12,12); d.ellipse((hx-6,hy-6,hx+6,hy+6),fill=(255,255,220,255))

    if WP[2]['brk']<=t<WP[2]['brk']+40:
        pf=pop(banded(F1,'PERFECT!',5,GOLDB,shade=False),t,WP[2]['brk']); c.alpha_composite(pf,(CX-pf.width//2,300))
        b=banded(F1,'-20%',4,GOLDB,shade=False); c.alpha_composite(b,(CX-b.width//2,300+pf.height+6))
    guard=t>=WEND+4
    if guard and t>=WEND+4:
        u=t-WEND-4; gxx=CX+gx; r=FR['A'].width//2+30; gy=place(FR['A'])[1]
        d.ellipse((gxx-r,gy-20,gxx+r,FLOOR+20),outline=(200,205,220,160+int(60*math.sin(t*.4))),width=5)
        if u<30: g=pop(banded(F1,'GUARD!',3,SILVER,shade=False),t,WEND+4); c.alpha_composite(g,(gxx-g.width//2,gy-70))
        for i,(px,py) in enumerate(GANG):   # his gang comes out of the smoke
            v=u-6-i*6
            if v<0: continue
            pf_=Image.new('RGBA',(SW,SH),(0,0,0,0)); ImageDraw.Draw(pf_).ellipse((px-70,py-150,px+70,py),fill=(120,130,110,max(0,140-v*6))); c.alpha_composite(pf_)
            k=min(1,v/10); im2=dark_imp.copy(); im2.putalpha(im2.split()[3].point(lambda a,k=k:int(a*k)))
            c.alpha_composite(im2,(px-im2.width//2,py-im2.height+10))
    if EXP<=t<WEND+4:   # his squires come while his guard is down, so he has time to charge
        for i,(px,py) in enumerate(BACKUP):
            v=t-EXP-i*5
            if v<0: continue
            pf_=Image.new('RGBA',(SW,SH),(0,0,0,0)); ImageDraw.Draw(pf_).ellipse((px-70,py-150,px+70,py),fill=(120,130,110,max(0,140-v*6))); c.alpha_composite(pf_)
            k=min(1,v/10); im2=dark_imp.copy(); im2.putalpha(im2.split()[3].point(lambda a,k=k:int(a*k)))
            step=min(70,max(0,v-12))*1.4
            c.alpha_composite(im2,(int(px-im2.width//2+(CX-px)*step/500),int(py-im2.height+10+step)))
        if t<EXP+30:
            bk=pop(banded(F1,'SQUIRES!',3,RED4,shade=False),t,EXP); c.alpha_composite(bk,(40,FLOOR-430))
    stake=0.5 if (EXP<=t<WEND and not perfect) else 0
    c.alpha_composite(boss_row(t,frac,stake,(t in (WP[2]['brk'],WP[2]['brk']+1)),guard),(30,SH-150))
    caps=[(0,'his shield is up: your shots bounce back'),(EXP,'SHIELD DOWN: EXPOSED!; his squires charge in'),(WEND+4,'GUARD: the shield and his reflecting shield; the squires are the wave')]
    ImageDraw.Draw(c).text((12,8),[s for tt,s in caps if t>=tt][-1],fill=(220,220,225))
    ImageDraw.Draw(c).text((12,SH-16),'The Black Knight unleashed, life 1, one EXPOSED! cycle. Mockup, not in engine.',fill=(140,140,150))
    frames.append(c.convert('RGB'))
for name,ms in (('blackknight_exposed_real.gif',29),('blackknight_exposed_slow.gif',70)):
    q=[f.quantize(160,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/bknight/'+name,save_all=True,append_images=q[1:]+[q[-1]]*20,duration=ms,loop=0)
for i in (60,100,125,215): frames[i].save('/home/claude/bknight/s_%d.png'%i)
print('ok')
