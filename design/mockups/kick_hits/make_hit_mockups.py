from PIL import Image, ImageChops, ImageFilter, ImageDraw
import glob, colorsys, math
SRC='/home/claude/rsq_ubqseries/Melee/sprites/rsqml/'
OUT='/mnt/user-data/outputs/hit_mockups/'
BG=(18,16,26,255); C=160; Z=4
def frames(n): return [Image.open(f).convert('RGBA') for f in sorted(glob.glob(SRC+n+'?0.png'))]
def tint(im, rgb, keep_hi=True):
    px=im.load(); out=im.copy(); po=out.load()
    for y in range(im.height):
        for x in range(im.width):
            r,g,b,a=px[x,y]
            if a==0: continue
            l=(0.3*r+0.59*g+0.11*b)/255
            if keep_hi and l>0.86: continue
            po[x,y]=(int(rgb[0]*min(1,l*1.4)),int(rgb[1]*min(1,l*1.4)),int(rgb[2]*min(1,l*1.4)),a)
    return out
def outline(im, col=(10,6,14,255)):
    a=im.split()[3].point(lambda v:255 if v>40 else 0)
    big=a.filter(ImageFilter.MaxFilter(3))
    o=Image.new('RGBA',im.size,col); o.putalpha(ImageChops.subtract(big,a))
    r=o.copy(); r.alpha_composite(im); return r
def crunch(im, n=12):
    a=im.split()[3]; q=im.convert('RGB').quantize(n, method=Image.Quantize.MEDIANCUT).convert('RGB'); q.putalpha(a.point(lambda v:255 if v>90 else 0)); return q
def canvas(): return Image.new('RGBA',(C,C),BG)
def place(cv, im, sx=1.0, sy=1.0, dx=0, dy=0, rot=0, alpha=1.0):
    if rot: im=im.rotate(rot, expand=True, resample=Image.NEAREST)
    if sx!=1 or sy!=1: im=im.resize((max(1,int(im.width*sx)),max(1,int(im.height*sy))),Image.NEAREST)
    if alpha<1: a=im.split()[3].point(lambda v:int(v*alpha)); im=im.copy(); im.putalpha(a)
    cv.alpha_composite(im,((C-im.width)//2+dx,(C-im.height)//2+dy))
def save(name, fs, dur):
    fs=[f.resize((C*Z,C*Z),Image.NEAREST).convert('P', palette=Image.ADAPTIVE, colors=255) for f in fs]
    fs[0].save(OUT+name+'.gif',save_all=True,append_images=fs[1:],duration=dur,loop=0,disposal=2)
    return fs
GOLD=(255,200,60); RED=(255,70,40); CYAN=(80,230,255); FIRE=(255,120,30); ICE=(110,200,255); SHOCK=(255,240,80)
F1,F2,F3,F4,F5=frames('MLK1'),frames('MLK2'),frames('MLK3'),frames('MLK4'),frames('MLK5')
out={}
# A BOOT STRIKE: sideways slash (impact 1) stretched, star lines (impact 4) over it, white pop, 3-frame hit-stop
A=[]
pop=canvas(); d=ImageDraw.Draw(pop); d.ellipse((C//2-26,C//2-14,C//2+26,C//2+14),fill=(255,255,255,255)); A+= [pop]
for i,f in enumerate(F1):
    cv=canvas(); place(cv, crunch(outline(tint(f,GOLD))), sx=1.7, sy=1.0, rot=-35+35)
    if i < len(F4): place(cv, tint(F4[min(i+1,len(F4)-1)],(255,255,255)), sx=1.3, sy=0.8, alpha=0.9)
    A.append(cv)
    if i==1: A+= [cv, cv, cv]   # hit-stop
out['A_boot_strike']=save('A_boot_strike',A,55)
# B WRECKING BALL: impact 5 body + impact 2 ring, red-orange, shake + expanding ring
B=[]
for i in range(len(F5)):
    cv=canvas(); sh=[(0,0),(6,-3),(-5,4),(4,2),(-2,-2),(1,1),(0,0),(0,0)][i]
    place(cv, crunch(outline(tint(F5[i],RED))), sx=1.6, sy=1.6, dx=sh[0], dy=sh[1])
    if i < len(F2): place(cv, tint(F2[i],GOLD), sx=1.1, sy=1.1, dx=sh[0], dy=sh[1], alpha=0.95)
    d=ImageDraw.Draw(cv); r=14+i*10; w=max(1,5-i//2)
    if i<6: d.ellipse((C//2-r+sh[0],C//2-r*0.55+sh[1],C//2+r+sh[0],C//2+r*0.55+sh[1]),outline=(255,230,180,255-i*35),width=w)
    B.append(cv)
    if i==0: B+=[cv,cv]
out['B_wrecking_ball']=save('B_wrecking_ball',B,60)
# C SLOW-MO SMEAR: impact 3 with afterimages, cyan (the Stretched Second colour), long frames
Cs=[]; trail=[]
for i,f in enumerate(F3):
    cv=canvas(); t=crunch(outline(tint(f,CYAN)))
    for k,(prev,age) in enumerate(trail[-3:]): place(cv, prev, sx=1.5, sy=1.5, dx=-(3-k)*6, alpha=0.18*(k+1))
    place(cv, t, sx=1.5, sy=1.5); trail.append((t,i)); Cs.append(cv)
out['C_slowmo_smear']=save('C_slowmo_smear',Cs,120)
# D ELEMENT KICKS: impact 1 / 4 in fire, ice, shock, side by side
Ds=[]
for i in range(len(F1)):
    row=Image.new('RGBA',(C*3,C),BG)
    for j,(col,src) in enumerate([(FIRE,F1),(ICE,F2),(SHOCK,F4)]):
        cv=canvas(); place(cv, crunch(outline(tint(src[min(i,len(src)-1)],col))), sx=1.4, sy=1.4); row.alpha_composite(cv,(j*C,0))
    Ds.append(row)
fs=[f.resize((C*3*3,C*3),Image.NEAREST) for f in Ds]
fs=[f.convert('P',palette=Image.ADAPTIVE,colors=255) for f in fs]
fs[0].save(OUT+'D_element_kicks.gif',save_all=True,append_images=fs[1:],duration=70,loop=0,disposal=2)
# contact sheet: peak frames
sheet=Image.new('RGBA',(C*6,C),BG)
for j,im in enumerate([A[3],A[5],B[2],B[4],Cs[3],Cs[5]]): sheet.alpha_composite(im,(j*C,0))
sheet.resize((C*6*2,C*2),Image.NEAREST).save(OUT+'sheet.png')
print('ok')
