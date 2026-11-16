BOSSNAME='THING FROM THE BOG'
exec(open('/home/claude/bog/common.py').read())
ZX,ZY=2.6*1.45*1.0,2.6*1.45
def spr2(n): im=Image.open('/tmp/bdem/%s.png'%n).convert('RGBA'); return im.resize((int(im.width*3.6),int(im.height*4.2)),Image.NEAREST)
B={k:spr2('BDEM%s1'%k) for k in 'AHI'}
H=B['H']; hx,hy=CX-H.width//2, FLOOR-H.height+8
# H frame 67x89: belly glow ~ (33,52); head ~ (33,14); right shoulder ~ (55,30)
WP=[dict(sx=33,sy=52,xh='RSQMBX04',col=(140,255,60),lab=(30,330),brk=100,orb=True,name='BELLY!'),
    dict(sx=33,sy=14,xh='RSQMBX01',col=(255,200,50),lab=(30,140),brk=122,orb=False,name='WEAK POINT!'),
    dict(sx=56,sy=30,xh='RSQMBX08',col=(120,200,255),lab=(SW-370,170),brk=144,orb=False,name='WEAK POINT!')]
for w in WP: w['x']=hx+int(w['sx']*3.6); w['y']=hy+int(w['sy']*4.2); w['parts']=parts_of('/tmp/xh/%s.png'%w['xh'])
GULP=8; EXP=30; WIN=105; WEND=EXP+WIN; ASM0=EXP+2; END=250
ACID=[(170,FLOOR+30),(SW-170,FLOOR+40),(CX-260,FLOOR+70),(CX+250,FLOOR+75)]
GREEN4=[(220,255,200),(150,255,90),(60,190,40),(20,90,10)]
frames=[]
for t in range(END):
    c=Image.new('RGBA',(SW,SH),(14,20,16,255)); d=ImageDraw.Draw(c,'RGBA')
    d.rectangle((0,FLOOR-20,SW,SH),fill=(26,34,26,255))
    broke=[t>=w['brk'] for w in WP]
    if t<GULP: im=B['A']
    elif t<EXP: im=B['H'] if (t//4)%2 else B['I']
    elif t<WEND+4: im=B['H']
    else: im=B['A']
    x,y=CX-im.width//2, FLOOR-im.height+8; c.alpha_composite(im,(x,y))
    if GULP<=t<EXP+20:
        g=pop(banded(F1,'GULP... GULP...',3,GREEN4,shade=False),t,GULP); c.alpha_composite(g,(CX-g.width//2,FLOOR-640))
    # the challenge: his burp blobs crawl at you and leave acid
    if t>=EXP+10 and t<WEND+40:
        lay=Image.new('RGBA',(SW,SH),(0,0,0,0)); ld=ImageDraw.Draw(lay)
        for i,(px,py) in enumerate(ACID):
            v=t-EXP-10-i*8
            if v<0: continue
            r=min(90,v*4); ld.ellipse((px-r,py-r*0.25,px+r,py+r*0.25),fill=(120,255,60,90))
            bx=px+(CX-px)*0.0; by=py-10+min(60,v)*1.2
            ld.ellipse((px-16,by-12,px+16,by+12),fill=(150,255,80,230))
        c.alpha_composite(lay)
        if t<EXP+40:
            b=pop(banded(F1,'BURP BLOBS!',3,GREEN4,shade=False),t,EXP+10); c.alpha_composite(b,(40,FLOOR-470))
    frac=1.0-0.1*sum(broke); perfect=all(broke)
    if perfect: frac=max(0.5,0.7-0.2*min(1,(t-WP[2]['brk'])/5))
    if EXP<=t<WEND:
        ex=pop(banded(F1,'EXPOSED!',4,[(255,240,200),(255,200,60),(235,130,20),(140,60,10)],shade=False),t,EXP); c.alpha_composite(ex,(CX-ex.width//2,24))
        left=max(0,WIN-(t-EXP))/35; ss=sevenseg('%d:%02d'%(int(left),int((left%1)*100)),(255,42,26),40); c.alpha_composite(ss,(CX-ss.width//2,24+ex.height+8))
        for w in WP:
            if t>=w['brk']:
                u=t-w['brk']
                if u<10:
                    r=14+u*10; d=ImageDraw.Draw(c,'RGBA'); d.ellipse((w['x']-r,w['y']-r,w['x']+r,w['y']+r),outline=(255,255,255,max(0,255-u*25)),width=4)
                    b=banded(F1,'-10%',3,GOLDB,shade=False); c.alpha_composite(b,(w['x']-b.width//2,w['y']-60-u*4))
                continue
            xh(c,w,t,ASM0+WP.index(w)*3); label(c,w,t,hp(w,t))
            if w['brk']-22<=t<w['brk'] and t%3==0:
                d=ImageDraw.Draw(c,'RGBA'); r=random.Random(t*7+w['sx']); hx_=w['x']+r.randint(-12,12); hy_=w['y']+r.randint(-12,12); d.ellipse((hx_-6,hy_-6,hx_+6,hy_+6),fill=(255,255,220,255))
    if WP[0]['brk']<=t<WP[0]['brk']+30:
        bf=pop(banded(F1,'BACKFIRE!',3,GREEN4,shade=False),t,WP[0]['brk']); c.alpha_composite(bf,(CX-bf.width//2,FLOOR-420))
        lay=Image.new('RGBA',(SW,SH),(0,0,0,0)); ImageDraw.Draw(lay).ellipse((CX-150,FLOOR-330,CX+150,FLOOR-60),fill=(140,255,60,110)); c.alpha_composite(lay)
    if WP[2]['brk']<=t<WP[2]['brk']+40:
        pf=pop(banded(F1,'PERFECT!',5,GOLDB,shade=False),t,WP[2]['brk']); c.alpha_composite(pf,(CX-pf.width//2,300))
        b=banded(F1,'-20%',4,GOLDB,shade=False); c.alpha_composite(b,(CX-b.width//2,300+pf.height+6))
    guard=t>=WEND+4
    if guard:
        u=t-WEND-4; d=ImageDraw.Draw(c,'RGBA'); r=B['A'].width//2+30; gy=FLOOR-B['A'].height
        d.ellipse((CX-r,gy-20,CX+r,FLOOR+20),outline=(200,205,220,160+int(60*math.sin(t*.4))),width=5)
        if u<30: g=pop(banded(F1,'GUARD!',3,SILVER,shade=False),t,WEND+4); c.alpha_composite(g,(CX-g.width//2,gy-70))
        for i,(px,py) in enumerate(GANG):
            v=u-6-i*6
            if v<0: continue
            k=min(1,v/10); m=W2.patch('FATTA1').convert('RGBA'); m=m.resize((m.width*2,m.height*2),Image.NEAREST)
            _a=np.array(m).astype(float); _a[:,:,1]*=1.15; _a[:,:,0]*=0.6; m=Image.fromarray(np.clip(_a,0,255).astype(np.uint8),'RGBA')
            m.putalpha(m.split()[3].point(lambda a,k=k:int(a*k))); c.alpha_composite(m,(px-m.width//2,py-m.height+10))
    stake=0.5 if (EXP<=t<WEND and not perfect) else 0
    c.alpha_composite(boss_row(t,frac,stake,(t in (WP[2]['brk'],WP[2]['brk']+1)),guard),(30,SH-150))
    caps=[(0,'the Burp wind-up: he gulps, his belly glows'),(EXP,'EXPOSED!: break the BELLY! and the burp BACKFIREs on him; the blobs crawl at you'),(WEND+4,'GUARD: his swamp spawn are the wave')]
    ImageDraw.Draw(c).text((12,8),[s for tt,s in caps if t>=tt][-1],fill=(220,220,225))
    ImageDraw.Draw(c).text((12,SH-16),'The thing from the bog (Black Mancubus EX), one EXPOSED! cycle. Mockup, not in engine.',fill=(140,140,150))
    frames.append(c.convert('RGB'))
for name,ms in (('bog_exposed_real.gif',29),('bog_exposed_slow.gif',70)):
    q=[f.quantize(160,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/bog/'+name,save_all=True,append_images=q[1:]+[q[-1]]*20,duration=ms,loop=0)
for i in (20,105,215): frames[i].save('/home/claude/bog/s_%d.png'%i)
print('ok')
