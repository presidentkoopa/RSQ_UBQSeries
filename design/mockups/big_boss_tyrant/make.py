import math, random, numpy as np, os
os.chdir('/home/claude/bnmock')
src=open('boss_mock.py').read(); exec(src[:src.index('# settled')])
from scipy import ndimage
from PIL import Image, ImageDraw
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
W2=Wad('/home/claude/rig/packs/doom2.wad'); impS=W2.patch('TROOA1').convert('RGBA')
S=2.6
def spr(f): im=Image.open('/tmp/hsmi/HSMI%s1.png'%f).convert('RGBA'); return im.resize((int(im.width*S),int(im.height*S)),Image.NEAREST)
FR={f:spr(f) for f in 'ALHN'}
def parts_of(path,z=1):
    im=Image.open(path).convert('RGBA'); im=im.resize((im.width*z,im.height*z),Image.NEAREST)
    a=np.array(im); lab,n=ndimage.label(a[:,:,3]>40); out=[]
    for i in range(1,n+1):
        m=(lab==i); ys,xs=np.where(m); x0,x1,y0,y1=xs.min(),xs.max()+1,ys.min(),ys.max()+1
        p=a[y0:y1,x0:x1].copy(); p[~m[y0:y1,x0:x1]]=0
        out.append((Image.fromarray(p,'RGBA'),(x0+x1)/2-im.width/2,(y0+y1)/2-im.height/2))
    out.sort(key=lambda q:q[0].width*q[0].height); return out
def ease(t): return 1-(1-t)**3
def tintflat(im,rgb):
    a=np.array(im).astype(float); a[:,:,:3]=np.array(rgb); return Image.fromarray(a.astype(np.uint8),'RGBA')
SW,SH=960,900; FLOOR=640; CX=SW//2
def place(im): return (CX-im.width//2, FLOOR-im.height+8)
nN=FR['N']; nx,ny=place(nN)
WP=[dict(sx=64,sy=72,xh='RSQMBX01',col=(255,200,50),lab=(40,250),brk=100),
    dict(sx=28,sy=44,xh='RSQMBX03',col=(60,170,255),lab=(40,120),brk=124),
    dict(sx=112,sy=58,xh='RSQMBX05',col=(200,90,255),lab=(SW-330,150),brk=146)]
for w in WP: w['x']=nx+int(w['sx']*S); w['y']=ny+int(w['sy']*S); w['parts']=parts_of('/tmp/xh/%s.png'%w['xh'])
SLAM_END=56; EXP=58; WIN=105; WEND=EXP+WIN; ASM0=EXP+2; END=250
def xh(c,w,t,t0,sc0=1.25):
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
    if t0+10<=t<t0+12:
        for p,px,py in w['parts']:
            im=p.resize((int(p.width*sc0*1.15),int(p.height*sc0*1.15)),Image.NEAREST); c.alpha_composite(im,(int(w['x']+px*sc0*1.15-im.width/2),int(w['y']+py*sc0*1.15-im.height/2)))
def hp(w,t):
    s=w['brk']-24
    return 1.0 if t<s else max(0.0,1-(t-s)/24)
def label(c,w,t,h):
    if t<ASM0+8: return
    d=ImageDraw.Draw(c); lx,ly=w['lab']; ax=lx+210 if lx<SW//2 else lx; ay=ly+22
    k=min(1,(t-ASM0-8)/3); d.line((w['x'],w['y'],w['x']+(ax-w['x'])*k,w['y']+(ay-w['y'])*k),fill=w['col']+(255,),width=3)
    if k<1: return
    d.line((lx,ay,lx+210,ay),fill=w['col']+(255,),width=3)
    word=banded(F1,'WEAK POINT!',2,[mix(w['col'],(255,255,255),.6),w['col'],tuple(int(v*.7) for v in w['col']),tuple(int(v*.45) for v in w['col'])],shade=False)
    c.alpha_composite(word,(lx,ay-word.height-6))
    cols=(tuple(int(v*0.3) for v in w['col']),w['col'],mix(w['col'],(255,255,255),0.55))
    c.alpha_composite(gauge(h,cols,210,18,t),(lx,ay+8))
def pop(word_im,t,t0):
    s=[0.2,1.35,1.12,1.0][min(3,max(0,t-t0))]; return word_im.resize((max(1,int(word_im.width*s)),max(1,int(word_im.height*s))),Image.NEAREST)
def pentagram(d,cx,cy,r,col,a):
    pts=[(cx+r*math.cos(-math.pi/2+i*4*math.pi/5), cy+r*0.32*math.sin(-math.pi/2+i*4*math.pi/5)) for i in range(5)]
    d.line(pts+[pts[0]],fill=col+(a,),width=4); d.ellipse((cx-r,cy-r*0.32,cx+r,cy+r*0.32),outline=col+(a,),width=3)
def boss_row(t,frac,stake,flash,guard):
    h=30; w=400; col=(240,50,40)
    cols=((90,95,110),(180,185,200),(235,240,250)) if guard else (tuple(int(c*0.3) for c in col), col, mix(col,(255,255,255),0.55))
    bar=gauge(frac,cols,w,h,t)
    if stake>0:
        a=int(w*max(0,frac-stake)); b=int(w*frac); bar.alpha_composite(Image.new('RGBA',(max(1,b-a),h-6),(255,205,40,int(225+30*math.sin(t*.5)))),(a,3))
    if flash: bar.alpha_composite(Image.new('RGBA',(w,h),(255,255,255,150)))
    name=banded(F1,'OBSIDIAN TYRANT',3,GOLDB)
    row=[bar]
    if guard: row.append(pill(banded(F1,'GUARD',2,SILVER,shade=False),(12,12,16,215),None,8,10,6))
    row.append(banded(F1,'X3',3,GOLDB))
    return hstack([HD.resize((80,80),Image.NEAREST),vstack([name,hstack(row,10)],6)],14)
red_imp=impS.copy(); _a=np.array(red_imp).astype(float); _L=_a[:,:,:3].mean(2,keepdims=True)/255; _a[:,:,:3]=np.clip(_L*np.array([255,50,40])*1.7,0,255); red_imp=Image.fromarray(_a.astype(np.uint8),'RGBA').resize((impS.width*2,impS.height*2),Image.NEAREST)
PORT=[(140,FLOOR-40),(SW-140,FLOOR-40),(CX-300,FLOOR-10)]
frames=[]
for t in range(END):
    c=Image.new('RGBA',(SW,SH),(20,14,14,255)); d=ImageDraw.Draw(c,'RGBA')
    d.rectangle((0,FLOOR-20,SW,SH),fill=(38,28,26,255))
    shake=(random.Random(t).randint(-6,6) if t<SLAM_END and t%7<2 else 0)
    # the hellfire pentagram under it during BigHell
    if t<SLAM_END+6: pentagram(d,CX,FLOOR,250,(255,60,20),int(200 if t<SLAM_END else 200-(t-SLAM_END)*30))
    if t<SLAM_END:
        f='H' if t%7>=4 else 'L'; im=FR[f]
        for k in range(8):   # shockwave rings from the slams
            t0=k*7+4; u=t-t0
            if 0<=u<14: r=60+u*30; d.ellipse((CX-r,FLOOR-r*0.3,CX+r,FLOOR+r*0.3),outline=(255,150,40,max(0,230-u*16)),width=5)
    elif t<WEND+4: im=FR['N']
    else: im=FR['A']
    x,y=place(im); c.alpha_composite(im,(x+shake,y))
    broke=sum(1 for w in WP if ASM0<=t and t>=w['brk'])
    frac=1.0-0.1*broke; perfect=broke==3
    if perfect and t>=WP[2]['brk']: frac=max(0.5,0.7-0.2*min(1,(t-WP[2]['brk'])/5))
    if EXP<=t<WEND:
        ex=pop(banded(F1,'EXPOSED!',4,[(255,240,200),(255,200,60),(235,130,20),(140,60,10)],shade=False),t,EXP)
        c.alpha_composite(ex,(CX-ex.width//2,30))
        left=max(0,WIN-(t-EXP))/35; ss=sevenseg('%d:%02d'%(int(left),int((left%1)*100)),(255,42,26),40); c.alpha_composite(ss,(CX-ss.width//2,30+ex.height+8))
        for w in WP:
            if t>=w['brk']:
                u=t-w['brk']
                if u<10:
                    r=14+u*10; d.ellipse((w['x']-r,w['y']-r,w['x']+r,w['y']+r),outline=(255,255,255,max(0,255-u*25)),width=4)
                    b=banded(F1,'-10%',3,GOLDB,shade=False); c.alpha_composite(b,(w['x']-b.width//2,w['y']-60-u*4))
                continue
            xh(c,w,t,ASM0+WP.index(w)*3); label(c,w,t,hp(w,t))
            if w['brk']-24<=t<w['brk'] and t%3==0:
                r=random.Random(t*7+w['sx']); hx=w['x']+r.randint(-12,12); hy=w['y']+r.randint(-12,12)
                d.ellipse((hx-6,hy-6,hx+6,hy+6),fill=(255,255,220,255))
    if WP[2]['brk']<=t<WP[2]['brk']+40:
        pf=pop(banded(F1,'PERFECT!',5,GOLDB,shade=False),t,WP[2]['brk']); c.alpha_composite(pf,(CX-pf.width//2,300))
        b=banded(F1,'-20%',4,GOLDB,shade=False); c.alpha_composite(b,(CX-b.width//2,300+pf.height+6))
    guard=t>=WEND+4
    if guard:
        u=t-WEND-4
        gx,gy=place(FR['A']); r=FR['A'].width//2+30
        d.ellipse((CX-r,gy-20,CX+r,FLOOR+20),outline=(200,205,220,160+int(60*math.sin(t*.4))),width=5)
        if u<30:
            g=pop(banded(F1,'GUARD!',3,SILVER,shade=False),t,WEND+4); c.alpha_composite(g,(CX-g.width//2,gy-70))
        for i,(px,py) in enumerate(PORT):   # its portal summons: the wave
            v=u-8-i*6
            if v<0: continue
            rr=min(60,v*6); d.ellipse((px-rr,py-rr*1.4,px+rr,py+rr*0.2),outline=(255,40,30,230),width=5)
            if v>10:
                k=min(1,(v-10)/10); im2=red_imp.copy(); im2.putalpha(im2.split()[3].point(lambda a,k=k:int(a*k)))
                c.alpha_composite(im2,(px-im2.width//2,py-im2.height+10))
    stake=0.5 if (EXP<=t<WEND and not perfect) else 0
    c.alpha_composite(boss_row(t,frac,stake if not perfect else 0,(t==WP[2]['brk'] or t==WP[2]['brk']+1),guard),(30,SH-150))
    if guard and t-WEND-4>40:
        thr=hstack([pill(hstack([gauge(1.0,((90,20,16),(240,50,40),(255,170,160)),110,16,t)],8),(12,10,8,200),None,10,10,6) for _ in range(3)],10)
        c.alpha_composite(thr,(200,SH-50))
    labels=[(0,'BIG HELL: survive 12 slams'),(EXP,'EXPOSED! 3 seconds'),(WEND+4,'GUARD: its summons are the wave')]
    cap=[s for tt,s in labels if t>=tt][-1]
    ImageDraw.Draw(c).text((12,12),cap,fill=(200,200,210))
    ImageDraw.Draw(c).text((12,SH-16),'Obsidian Tyrant, one EXPOSED! cycle (owner 11-16). Mockup, not in engine; slams shortened to 8 here.',fill=(140,140,150))
    frames.append(c.convert('RGB'))
for name,ms in (('tyrant_exposed_cycle_real.gif',29),('tyrant_exposed_cycle_slow.gif',70)):
    q=[f.quantize(160,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/tyrant/'+name,save_all=True,append_images=q[1:]+[q[-1]]*20,duration=ms,loop=0)
for i in (30,90,150,235): frames[i].save('/home/claude/tyrant/still_%d.png'%i)
print('ok')
