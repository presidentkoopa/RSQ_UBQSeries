import numpy as np
from PIL import Image, ImageDraw
exec(open('/home/claude/wordfont/make.py').read().split('GOLD=((240')[0])
W2=Wad('/home/claude/rig/packs/doom2.wad'); imp=W2.patch('TROOA1').convert('RGBA'); Z=3
def tint(im,rgb,k=1.6):
    a=np.array(im).astype(float); L=a[:,:,:3].mean(2,keepdims=True)/255.0
    o=a.copy(); o[:,:,:3]=np.clip(L*np.array(rgb)*k,0,255); return Image.fromarray(o.astype(np.uint8),'RGBA')
def flat(im,rgb):
    a=np.array(im).astype(float); L=a[:,:,:3].mean(2,keepdims=True)/255.0
    o=a.copy(); o[:,:,:3]=np.clip(np.array(rgb)*(0.55+0.45*L*2.2),0,255); return Image.fromarray(o.astype(np.uint8),'RGBA')
def shade(im,k):
    a=np.array(im).astype(float); a[:,:,:3]*=k; return Image.fromarray(np.clip(a,0,255).astype(np.uint8),'RGBA')
DARK=0.45
COL={'Yellow':(255,214,60),'Red':(255,60,40),'White':(235,235,245)}
def body(c): return shade(tint(imp,COL[c],1.6 if c!='White' else 1.25),DARK)
WHITEF=flat(imp,(255,255,255)); BLACKF=flat(imp,(16,16,20))
# Hackfraud timing as built: wait (charging), then 3 tics flash / 3 tics own look ... until the wait ends; show a 4-flash case
SEQ=['F']*3+['O']*3+['F']*3+['O']*3+['F']*3+['O']*3+['F']*3
CASES=[('Yellow','Red'),('Red','White')]
def look(frm,to,t,mode):
    if t<5: return body(frm),'its colour (%s)'%frm
    i=t-5
    if i>=len(SEQ): return body(to),'now %s'%to
    if SEQ[i]=='O': return body(frm),'between flashes: its own colour'
    if mode=='now':
        return (BLACKF,'flash: black (becoming White)') if to=='White' else (WHITEF,'flash: white')
    return flat(imp,COL[to]),'flash: %s, the colour that is coming'%to.lower()
T=5+len(SEQ)+12
frames=[]
for t in range(T):
    sh=Image.new('RGB',(640,2*290+60),(18,17,22)); d=ImageDraw.Draw(sh)
    d.text((14,8),'NOW',fill=(255,226,120)); d.text((334,8),'PROPOSED: FLASH IN THE NEW COLOUR',fill=(255,226,120))
    for r,(frm,to) in enumerate(CASES):
        for c,m in enumerate(('now','new')):
            x0=10+c*320; y0=28+r*290; d.rectangle((x0,y0,x0+300,y0+270),fill=(22,18,16))
            im,cap=look(frm,to,t,m); im=im.resize((im.width*Z,im.height*Z),Image.NEAREST)
            sh.paste(im,(x0+150-im.width//2,y0+262-im.height),im)
            d.text((x0+6,y0+6),'%s -> %s'%(frm,to),fill=(255,255,255)); d.text((x0+6,y0+20),cap,fill=(200,200,210))
    d.text((10,sh.height-22),'Hackfraud timing (a 4-flash case), dark room, full-bright flash. Slowed: each frame is 1 tic. Mockup, not in engine.',fill=(120,120,135))
    frames.append(sh)
for name,ms in (('tier_flash_new_colour_slow.gif',110),('tier_flash_new_colour_real.gif',29)):
    q=[f.quantize(96,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in frames]
    q[0].save('/home/claude/flashmock/'+name,save_all=True,append_images=q[1:]+[q[-1]]*20,duration=ms,loop=0)
frames[6].save('/home/claude/flashmock/still2.png'); print('ok')
