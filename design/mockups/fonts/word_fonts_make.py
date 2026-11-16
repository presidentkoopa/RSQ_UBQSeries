import sys, os, numpy as np
from PIL import Image, ImageDraw, ImageFilter
os.chdir('/tmp/sotn')
exec(open('/tmp/sotn/sotnfont.py').read())                       # SOTN glyphs from the owner's word sheet
B='/home/claude/bnmock/'; S=B+'src/'
exec(open(B+'make_font_sheets.py').read().split('class Wad')[0].split('HERE =')[0])
_s=open(B+'make_font_sheets.py').read(); exec(_s[_s.index('def fon2'):_s.index('class Wad')])
src=open('/home/claude/bnmock/make_font_sheets.py').read(); exec(src[src.index('class Wad'):src.index('def png(path)')])
def png(p): return Image.open(p).convert('RGBA')
B='/home/claude/bnmock/'; S=B+'src/'
F1,_=fon2(open(S+'RSSCFON.fon2','rb').read()); F2,_=fon2(open(S+'RSSCFN2.fon2','rb').read())
JS={int(f[5:8]):png(S+'jfo/small/'+f) for f in os.listdir(S+'jfo/small')}
def crop(im):
    b=im.getbbox(); return im.crop((b[0],0,b[2],im.height)) if b else im
JS={k:crop(v) for k,v in JS.items()}
W=Wad('/home/claude/rig/packs/doom2.wad'); STCFN={}
for c in range(33,96):
    p=W.patch('STCFN%03d'%c)
    if p: STCFN[c]=p
H=40
def lum_mask_from(gl, gap=1, space=None, thr=60):
    """glyph images -> one luminance mask (L), letters' own shading kept"""
    hs=[g.height for g in gl if g]; h=max(hs)
    sp=space if space is not None else max(3,h//3)
    w=sum((g.width+gap) if g else sp for g in gl); m=Image.new('L',(max(1,w),h),0); x=0
    for g in gl:
        if g:
            a=np.array(g.convert('RGBA')).astype(float); L=a[:,:,:3].max(2)*(a[:,:,3]/255.0)
            L=np.where(L>thr,L,0).astype(np.uint8)
            cols=np.where(L.max(0)>0)[0]
            if len(cols): L=L[:,cols[0]:cols[-1]+1]
            m.paste(Image.fromarray(L),(x,h-g.height),Image.fromarray(L)); x+=L.shape[1]+gap
        else: x+=sp
    return m
def mask_font(name, s):
    if name=='SOTN': gl=[SOTN['white'].get(c) for c in s]
    elif name=='RSSCFON': gl=[F1.get(ord(c)) for c in s]
    elif name=='RSSCFN2': gl=[F2.get(ord(c)) for c in s]
    elif name=='JFO': gl=[JS.get(ord(c)) for c in s]
    elif name=='DOOM': gl=[STCFN.get(ord(c)) for c in s]
    m=lum_mask_from(gl, gap=2 if name=='SOTN' else 1, thr=75)
    k=H/m.height; return m.resize((max(1,int(m.width*k)),H),Image.NEAREST)
def paint(m, top, bot):
    a=np.array(m).astype(float); h,w=a.shape; o=np.zeros((h,w,4),np.uint8)
    for y in range(h):
        c=top if y<h/2 else bot
        k=0.55+0.45*a[y]/255.0
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
GOLD=((240,150,20),(255,236,120)); GOLDW=((255,220,120),(255,255,230))
WORDS=[('THREAT!',GOLD,GOLDW),('UNCOMMON',((40,170,60),(170,255,110)),((150,255,150),(235,255,190))),
       ('TARGET!',GOLD,GOLDW),('GUARD!',((96,100,112),(240,242,248)),((150,190,255),(235,245,255))),('KICK!',((255,130,20),(255,220,90)),GOLDW)]
FONTS=[('TODAY: RSSCFON (Score)','RSSCFON'),('SOTN LETTERS (your sheet)','SOTN'),('JFO (damage numbers)','JFO'),('RSSCFN2 (Score small)','RSSCFN2'),('DOOM SMALL FONT','DOOM')]
CW,RH=300,96; LW=230; N=56
frames=[]
for f in range(N):
    sh=Image.new('RGBA',(LW+CW*len(WORDS),RH*len(FONTS)),(20,19,26,255)); d=ImageDraw.Draw(sh)
    for ri,(lab,fn) in enumerate(FONTS):
        d.text((12,ri*RH+RH//2-6),lab,fill=(200,200,210))
        d.line((0,ri*RH,sh.width,ri*RH),fill=(40,40,50))
        for wi,(word,a,b) in enumerate(WORDS):
            age=f-4-wi*2
            if age<0: continue
            k=max(0.0,1-age/4)
            look=b if (age>=4 and age<28 and (age//4)%2==1) else a
            im=boxed(paint(mask_font(fn,word),*look),3)
            if k>0: im=smear(im,k)
            rise=min(age,44)*0.35; fade=1.0 if age<40 else max(0.0,1-(age-40)/10)
            if fade<1: im.putalpha(im.split()[3].point(lambda v:int(v*fade)))
            if im.width>CW-12: im=im.resize((CW-12,int(im.height*(CW-12)/im.width)),Image.NEAREST)
            sh.alpha_composite(im,(LW+wi*CW+(CW-im.width)//2, ri*RH+(RH-im.height)//2+10-int(rise)))
    frames.append(sh.convert('RGB'))
out='/home/claude/wordfont/word_fonts_animated.gif'
q=[fr.quantize(128,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for fr in frames]
q[0].save(out,save_all=True,append_images=q[1:],duration=55,loop=0,optimize=True)
frames[24].save('/home/claude/wordfont/word_fonts_still.png')
print('ok', os.path.getsize(out))
