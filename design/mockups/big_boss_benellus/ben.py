BOSSNAME='BENELLUS'
exec(open('/home/claude/bog/common.py').read())
Z=3.4
def sb(n): im=Image.open('/tmp/bene/BENE%s0.png'%n).convert('RGBA'); return im.resize((int(im.width*Z),int(im.height*Z)),Image.NEAREST)
BB={k:sb(k) for k in 'ADEFGH'}
gun=Image.open('/tmp/bene/BENEM0.png').convert('RGBA').crop((18,17,84,27)); GUN=gun.resize((gun.width*6,gun.height*6),Image.NEAREST)
GUNR=GUN.transpose(Image.FLIP_LEFT_RIGHT)
bob=lambda t:int(10*math.sin(t*0.12))
A=BB['A']; ax,ay=CX-A.width//2, FLOOR-A.height-60
# ghost shotguns appear either side of YOU (the near edges of the view), his face the third
WP=[dict(x=130,y=560,xh='RSQMBX10',col=(150,230,255),lab=(20,300),brk=94,name='GHOST GUN!'),
    dict(x=SW-130,y=560,xh='RSQMBX10',col=(150,230,255),lab=(SW-350,300),brk=114,name='GHOST GUN!'),
    dict(x=ax+int(38*Z),y=ay+int(20*Z),xh='RSQMBX01',col=(255,200,50),lab=(20,130),brk=138,name='WEAK POINT!')]
for w in WP: w['sx']=w['x']; w['parts']=parts_of('/tmp/xh/%s.png'%w['xh'])
CH=6; EXP=26; WIN=105; WEND=EXP+WIN; ASM0=EXP+2; END=250
SHR=[(110,FLOOR-40),(SW-110,FLOOR-40)]
frames=[]
for t in range(END):
    c=Image.new('RGBA',(SW,SH),(20,18,26,255)); d=ImageDraw.Draw(c,'RGBA')
    d.rectangle((0,FLOOR-20,SW,SH),fill=(34,30,40,255))
    broke=[t>=w['brk'] for w in WP]
    im=BB['A'] if t<CH or t>=WEND+4 else BB['EFGH'[(t//3)%4]] if t<EXP else BB['D']
    c.alpha_composite(im,(CX-im.width//2, ay+bob(t)))
    if CH<=t<EXP+20:
        g=pop(banded(F1,'BEHOLD!',3,GOLDB,shade=False),t,CH); c.alpha_composite(g,(CX-g.width//2,ay-70))
    # the ghost shotguns, beside you, aimed in
    if EXP-6<=t<WEND:
        for i,w in enumerate(WP[:2]):
            if t>=w['brk']: continue
            gimg=(GUN if i==0 else GUNR).copy(); k=min(1,(t-EXP+6)/8); gimg.putalpha(gimg.split()[3].point(lambda a,k=k:int(a*0.75*k)))
            c.alpha_composite(gimg,(w['x']-gimg.width//2,w['y']-gimg.height//2))
    # the challenge: his two Shotgun Shrines spray sparks
    if EXP+8<=t<WEND+60:
        lay=Image.new('RGBA',(SW,SH),(0,0,0,0)); ld=ImageDraw.Draw(lay)
        for i,(px,py) in enumerate(SHR):
            v=t-EXP-8-i*6
            if v<0: continue
            sh=Image.open('/tmp/bene/BENEN0.png').convert('RGBA'); sh=sh.resize((int(sh.width*1.6),int(sh.height*1.6)),Image.NEAREST)
            c.alpha_composite(sh,(px-sh.width//2,py-sh.height+10))
            for k in range(6):
                u=(v*3+k*7)%30; sx=px+(CX-px)*u/40; sy=py-120+k*8+u*3
                ld.ellipse((sx-4,sy-4,sx+4,sy+4),fill=(255,220,120,230))
        c.alpha_composite(lay)
        if t<EXP+40: b=pop(banded(F1,'SHRINES!',3,GOLDB,shade=False),t,EXP+8); c.alpha_composite(b,(CX-b.width//2,FLOOR-80))
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
    if WP[1]['brk']<=t<WP[1]['brk']+30:
        cn=pop(banded(F1,'UNLOADED!',3,GOLDB,shade=False),t,WP[1]['brk']); c.alpha_composite(cn,(CX-cn.width//2,FLOOR-140))
    if WP[2]['brk']<=t<WP[2]['brk']+40:
        pf=pop(banded(F1,'PERFECT!',5,GOLDB,shade=False),t,WP[2]['brk']); c.alpha_composite(pf,(CX-pf.width//2,300))
        b=banded(F1,'-20%',4,GOLDB,shade=False); c.alpha_composite(b,(CX-b.width//2,300+pf.height+6))
    guard=t>=WEND+4
    if guard:
        u=t-WEND-4; d=ImageDraw.Draw(c,'RGBA'); r=A.width//2+30
        d.ellipse((CX-r,ay-20+bob(t),CX+r,ay+A.height+20+bob(t)),outline=(200,205,220,160+int(60*math.sin(t*.4))),width=5)
        if u<30: g=pop(banded(F1,'GUARD!',3,SILVER,shade=False),t,WEND+4); c.alpha_composite(g,(CX-g.width//2,ay-70))
        if 6<=u<40: g=pop(banded(F1,'SHOOT THE SHRINES!',2,GOLDB,shade=False),t,WEND+10); c.alpha_composite(g,(CX-g.width//2,FLOOR-40))
    stake=0.5 if (EXP<=t<WEND and not perfect) else 0
    c.alpha_composite(boss_row(t,frac,stake,(t in (WP[2]['brk'],WP[2]['brk']+1)),guard),(30,SH-150))
    caps=[(0,'he charges his sparks: BEHOLD!'),(EXP,'EXPOSED!: two GHOST GUNs appear beside YOU, turn and break them before they fire; his Shrines spray sparks'),(WEND+4,'GUARD: his Shotgun Shrines are the wave')]
    ImageDraw.Draw(c).text((12,8),[s for tt,s in caps if t>=tt][-1],fill=(220,220,225))
    ImageDraw.Draw(c).text((12,SH-16),'BENELLUS, GOD OF SHOTGUNS, ANGRIER (White Shotgunner EX), one EXPOSED! cycle. Mockup, not in engine.',fill=(140,140,150))
    frames.append(c.convert('RGB'))
for name,ms in (('benellus_exposed_real.gif',29),('benellus_exposed_slow.gif',70)):
    q=[f.quantize(160,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/benellus/'+name,save_all=True,append_images=q[1:]+[q[-1]]*20,duration=ms,loop=0)
for i in (20,80,215): frames[i].save('/home/claude/benellus/s_%d.png'%i)
print('ok')
