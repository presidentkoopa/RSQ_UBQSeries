import os, math, numpy as np
from PIL import Image, ImageDraw
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])   # fonts + helpers (F2 = RSSCFN2, Score Small)
def mask(s, z):
    gl=[F2.get(ord(c)) for c in s]; m=lum_mask_from(gl,gap=1,thr=75)
    return m.resize((m.width*z,m.height*z),Image.NEAREST)          # whole-number scale, sharp pixels
def paint(m, top, bot):
    a=np.array(m).astype(float); h,w=a.shape; o=np.zeros((h,w,4),np.uint8)
    for y in range(h):
        c=top if y<h/2 else bot; k=0.55+0.45*a[y]/255.0
        for i in range(3): o[y,:,i]=np.clip(c[i]*k*1.15,0,255)
        o[y,:,3]=np.where(a[y]>0,255,0)
    return Image.fromarray(o,'RGBA')
def boxed(im,pad=3,col=(8,8,10)):
    w,h=im.size; out=Image.new('RGBA',(w+pad*2,h+pad*2),(0,0,0,0)); a=im.split()[3]
    for dx in range(-pad,pad+1):
        for dy in range(-pad,pad+1): out.paste(Image.new('RGBA',im.size,col+(255,)),(pad+dx,pad+dy),a)
    out.alpha_composite(im,(pad,pad)); return out
def smear(im,k):
    w,h=im.size; im2=im.resize((int(w*(1+0.3*k)),h),Image.NEAREST); sh=0.45*k
    return im2.transform((int(im2.width+h*sh),h),Image.AFFINE,(1,sh,-h*sh,0,1,0),Image.NEAREST)
def scaled(im,s):
    return im.resize((max(1,int(im.width*s)),max(1,int(im.height*s))),Image.NEAREST)
GOLD=((240,150,20),(255,236,120)); GOLD2=((255,220,120),(255,255,230))
GRN=((40,170,60),(170,255,110)); GRN2=((150,255,150),(235,255,190)); WHITE=((255,255,255),(255,255,255))
WORDS=[('THREAT!',GOLD,GOLD2),('UNCOMMON',GRN,GRN2)]
Z=4; LIFE=35; END=LIFE+10
def today(word,a,b,t):
    # words.zs as it is: pop 0.45 -> 1.35 -> 1.15 -> 1.0, flicker to white every 2 tics for 14 tics, drift up, hold ~1 s, fade 10 tics
    popK=0.45 if t==0 else 1.35 if t==1 else 1.15 if t==2 else 1.0
    white=t<14 and (t//2)%2==1
    im=boxed(paint(mask(word,Z),*(WHITE if white else a)),3)
    return scaled(im,popK), 60*(1-math.exp(-t/10.0)), (1.0 if t<=LIFE else 1-(t-LIFE)/10)
def sotn(word,a,b,t):
    # the banners' SOTN entrance: smear in over 4 tics, snap upright, then flash between its two two-tone looks; same drift and fade
    k=max(0.0,1-t/4)
    look=b if (t>=4 and t<28 and ((t-4)//4)%2==0) else a
    im=boxed(paint(mask(word,Z),*look),3)
    if k>0: im=smear(im,k)
    return im, 60*(1-math.exp(-t/10.0)), (1.0 if t<=LIFE else 1-(t-LIFE)/10)
CW,RH,TOP=560,190,58
def frame(t):
    sh=Image.new('RGBA',(CW*2,TOP+RH*len(WORDS)),(20,19,26,255)); d=ImageDraw.Draw(sh)
    d.text((14,10),'NOW, IN THE GAME',fill=(255,255,255)); d.text((14,28),'pop, flicker to white, drift up, fade',fill=(190,190,200))
    d.text((CW+14,10),'THE OPTION: SOTN, like your banners',fill=(255,226,120)); d.text((CW+14,28),'smear in, snap upright, flash two looks, drift up, fade',fill=(190,190,200))
    d.line((CW,0,CW,sh.height),fill=(60,60,72))
    for ri,(w,a,b) in enumerate(WORDS):
        for ci,fn in enumerate((today,sotn)):
            tt=t-ri*3
            if tt<0 or tt>=END: continue
            im,rise,al=fn(w,a,b,tt)
            if al<1: im.putalpha(im.split()[3].point(lambda v:int(v*max(0,al))))
            cx=ci*CW+CW//2; cy=TOP+ri*RH+RH-50-int(rise)
            sh.alpha_composite(im,(cx-im.width//2, cy-im.height//2))
    d.text((14,sh.height-16),'Score Small font (the new default). Not in engine.',fill=(120,120,135))
    return sh.convert('RGB')
T=END+3+14
for name,ms in (('word_motion_real_speed.gif',30),('word_motion_quarter_speed.gif',110)):
    fr=[frame(t).quantize(96,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for t in range(T)]
    fr[0].save('/home/claude/wordmotion/'+name,save_all=True,append_images=fr[1:],duration=ms,loop=0,optimize=True)
# a strip of the first tics, side by side
st=Image.new('RGB',(CW*2,1),(0,0,0))
ticks=[0,1,2,3,4,6,8,10]
strip=Image.new('RGB',(170*len(ticks)+150,2*110+40),(20,19,26)); d=ImageDraw.Draw(strip)
for i,tk in enumerate(ticks): d.text((150+i*170+60,8),'tic %d'%tk,fill=(200,200,210))
for ri,(lab,fn) in enumerate((('NOW',today),('SOTN option',sotn))):
    d.text((10,40+ri*110+45),lab,fill=(255,255,255) if ri==0 else (255,226,120))
    for i,tk in enumerate(ticks):
        im,_,_=fn('THREAT!',GOLD,GOLD2,tk); im=scaled(im,0.5)
        strip.paste(im,(150+i*170+(170-im.width)//2,40+ri*110+(110-im.height)//2),im)
strip.save('/home/claude/wordmotion/word_motion_tic_by_tic.png')
for f in os.listdir('/home/claude/wordmotion'): print(f, os.path.getsize('/home/claude/wordmotion/'+f))
