from PIL import Image, ImageDraw
import glob, os
S=Image.open('/mnt/user-data/uploads/16c02e30-image.png').convert('RGBA')
bg=S.getpixel((1,1))
def key(im):
    im=im.copy(); px=im.load()
    for y in range(im.height):
        for x in range(im.width):
            p=px[x,y]
            if abs(p[0]-bg[0])+abs(p[1]-bg[1])+abs(p[2]-bg[2])<40: px[x,y]=(0,0,0,0)
    bb=im.getbbox(); return im.crop(bb) if bb else im

import itertools
def ink(p): return abs(p[0]-bg[0])+abs(p[1]-bg[1])+abs(p[2]-bg[2])>=40
SP=S.load()
def bands(x0,x1,y0,y1,axis):
    out=[];on=False
    rng=range(y0,y1) if axis=='y' else range(x0,x1)
    for v in rng:
        hit=any(ink(SP[x,v]) for x in range(x0,x1)) if axis=='y' else any(ink(SP[v,y]) for y in range(y0,y1))
        if hit and not on: s0=v; on=True
        if not hit and on: out.append((s0,v)); on=False
    if on: out.append((s0,rng[-1]+1))
    return out
CR={}; DG={}
cols=[(0,106),(106,212),(212,318)]
names=[['white','cyan','green'],['gold','violet','red'],['silver','orange','lime']]
for ci,(x0,x1) in enumerate(cols):
    yb=bands(x0,x1,0,S.height,'y')
    for ri in range(3):
        dy=yb[ri*7]; cy=yb[ri*7+1]
        segs=bands(x0,x1,cy[0],cy[1],'x')
        CR[names[ri][ci]]=key(S.crop((segs[0][0],cy[0],segs[0][1],cy[1])))
        dsegs=bands(x0,x1,dy[0],dy[1],'x')
        DG[names[ri][ci]]=[key(S.crop((a0,dy[0],a1,dy[1]))) for a0,a1 in dsegs]
print({k:v.size for k,v in CR.items()}, {k:len(v) for k,v in DG.items()})
OUT='/mnt/user-data/outputs/crit_mockups/'
W,H,Z=160,90,5; BG=(14,12,20,255)
def cv(): return Image.new('RGBA',(W,H),BG)
def put(c,im,cx,cy,s=1.0,a=1.0):
    if s!=1: im=im.resize((max(1,round(im.width*s)),max(1,round(im.height*s))),Image.NEAREST)
    if a<1: im=im.copy(); im.putalpha(im.split()[3].point(lambda v:int(v*a)))
    c.alpha_composite(im,(int(cx-im.width/2),int(cy-im.height/2)))
def whiteout(im):
    o=im.copy(); px=o.load()
    for y in range(o.height):
        for x in range(o.width):
            if px[x,y][3]: px[x,y]=(255,255,255,px[x,y][3])
    return o
def save(n,fs,d):
    fs=[f.resize((W*Z,H*Z),Image.NEAREST).convert('P',palette=Image.ADAPTIVE,colors=255) for f in fs]
    fs[0].save(OUT+n+'.gif',save_all=True,append_images=fs[1:],duration=d,loop=0,disposal=2)
# A pop & shimmer gold<->red
A=[]
g,r=CR['gold'],CR['red']
for s in (3.0,2.2,1.6): c=cv(); put(c,whiteout(g),W/2,H/2,s*1.0); A.append(c)
for i in range(14):
    c=cv(); put(c,(g if (i//2)%2==0 else r),W/2,H/2-i*0.6,1.6 if i<1 else 1.4); A.append(c)
for i in range(6):
    c=cv(); put(c,g,W/2,H/2-9-i*1.5,1.4,1-i/6); A.append(c)
save('A_pop_shimmer_gold_red',A,55)
# B damage stack: red CRITICAL!! + gold digits bouncing in
B=[]; dmg='256'; dig={str(i):DG['gold'][i-1] for i in range(1,10)}; dig['0']=DG['gold'][9]
for f in range(26):
    c=cv(); put(c,(whiteout(r) if f<2 else r),W/2,H/2-12,1.6 if f<2 else 1.4)
    x0=W/2-len(dmg)*7
    for k,ch in enumerate(dmg):
        t=f-3-k*2
        if t<0: continue
        bounce=[-10,-4,0,-3,0,-1,0][t] if t<7 else 0
        put(c,dig[ch],x0+k*14+7,H/2+10+bounce,1.8)
    B.append(c)
save('B_damage_stack',B,50)
# C wipe-in: revealed left to right with a white leading edge, then gold, slight wobble
C=[]; gw=CR['white']; w=g.width
for f in range(26):
    c=cv(); k=min(1.0,f/8)
    cut=int(w*k)
    if cut>0:
        part=g.crop((0,0,cut,g.height)); full=Image.new('RGBA',g.size,(0,0,0,0)); full.alpha_composite(part,(0,0))
        if k<1: edge=gw.crop((max(0,cut-3),0,cut,g.height)); full.alpha_composite(whiteout(edge),(max(0,cut-3),0))
        wob=[0,-1,0,1][f%4] if f>8 and f<16 else 0
        put(c,full,W/2,H/2+wob,1.6)
    C.append(c)
save('C_wipe_in',C,45)
print('done')
# D in the world: the axe crit -- the yellow cross burst on the monster, CRITICAL!! popping above, damage below
import glob as _g
fr=sorted(_g.glob('/home/claude/rig/work/runs/flash1/frames/*.ppm'))
base=Image.open(fr[80]).convert('RGBA').crop((125,160,285,250))   # 160x90 around the imp
SRC='/home/claude/rsq_ubqseries/Melee/sprites/rsqml/'
def tint(im,rgb):
    o=im.copy();px=o.load()
    for y in range(o.height):
        for x in range(o.width):
            r_,g_,b_,a_=px[x,y]
            if not a_: continue
            l=(0.3*r_+0.59*g_+0.11*b_)/255
            if l>0.86: continue
            px[x,y]=(int(rgb[0]*min(1,l*1.4)),int(rgb[1]*min(1,l*1.4)),int(rgb[2]*min(1,l*1.4)),a_)
    return o
burst=[tint(Image.open(f).convert('RGBA'),(255,240,80)) for f in sorted(_g.glob(SRC+'MLK4?0.png'))]
D=[]; dg={str(i):DG['red'][i-1] for i in range(1,10)}; dg['0']=DG['red'][9]
for f in range(26):
    c=base.copy()
    if f<len(burst): put(c,burst[f],80,52,0.8)
    if f>=1:
        t=f-1; s=[2.4,1.8,1.4][t] if t<3 else 1.3
        im=whiteout(g) if t<1 else (g if (t//3)%2==0 else CR['orange'])
        put(c,im,80,22-min(t,10)*0.5,s,1.0 if t<20 else 1-(t-20)/6)
    if f>=4:
        x0=80-15
        for k,ch in enumerate('384'):
            t=f-4-k*2
            if t<0: continue
            bounce=[-8,-3,0,-2,0][t] if t<5 else 0
            put(c,dg[ch],x0+k*10+5,74+bounce,1.6)
    D.append(c)
save('D_axe_crit_in_world',D,55)
sheet=Image.new('RGBA',(W*4,H),BG)
for j,im in enumerate([A[6],B[16],C[14],D[4]]): sheet.alpha_composite(im,(j*W,0))
sheet.resize((W*4*2,H*2),Image.NEAREST).save(OUT+'sheet.png')
print('D done')
# E: the pick (owner 20:5x): A without the white flash, light blue, alive between frames of similar blues
def shade(im,k):  # k>0 toward white, k<0 toward deeper blue
    o=im.copy();px=o.load()
    for y in range(o.height):
        for x in range(o.width):
            r_,g_,b_,a_=px[x,y]
            if not a_ or (r_+g_+b_)<120: continue   # keep the dark outline
            if k>=0: px[x,y]=(int(r_+(255-r_)*k),int(g_+(255-g_)*k),int(b_+(255-b_)*k),a_)
            else: px[x,y]=(int(r_*(1+k)),int(g_*(1+k*0.4)),int(min(255,b_*(1-k*0.2))),a_)
    return o
cy=CR['cyan']; ladder=[cy,shade(cy,0.25),shade(cy,0.45),shade(cy,0.25),cy,shade(cy,-0.25),shade(cy,-0.4),shade(cy,-0.25)]
E_=[]
for s in (2.6,2.0,1.6): c=cv(); put(c,cy,W/2,H/2,s); E_.append(c)
for i in range(16):
    c=cv(); put(c,ladder[i%len(ladder)],W/2,H/2-i*0.6,1.4); E_.append(c)
for i in range(6):
    c=cv(); put(c,ladder[(16+i)%len(ladder)],W/2,H/2-9.6-i*1.5,1.4,1-i/6); E_.append(c)
save('E_pick_lightblue_pop_alive',E_,55)
print('E done')
