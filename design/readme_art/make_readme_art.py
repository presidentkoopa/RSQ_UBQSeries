import sys,os,numpy as np
sys.argv=[sys.argv[0]]+sys.argv[1:]
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'readme_art_lib.py')).read().split("if __name__")[0])
from PIL import ImageDraw
OUT=sys.argv[2]; os.makedirs(OUT,exist_ok=True)
RC=ROOT+'/MonsterRecolour/rsrecolour/'
def spr(col,names):
    return [Image.open(RC+col+'/'+n+'.png').convert('RGBA') for n in names]
W4=lambda p:[p+'A1',p+'B1',p+'C1',p+'D1']
W3=lambda p:[p+'A1D1',p+'B1E1',p+'C1F1',p+'B1E1']
# headers
HEADS=[('in_short','IN SHORT','gold'),('melee','MELEE','red'),('hands','HANDS ON THE WORLD','cyan'),('throwing','THROWING','orange'),
 ('tactical_rig','TACTICAL RIG','green'),('weapon_wheel','WEAPON WHEEL','blue'),('slowmo','SLOWMO','purple'),('visual_rewards','VISUAL REWARDS','pink'),
 ('the_mods','THE MODS','lime'),('install','INSTALL','steel'),('status','WHERE IT STANDS','gold'),('credits','CREDITS','steel')]
stills=[]
for fn,t,c in HEADS:
    stills.append(header(t,c,f'{OUT}/h_{fn}.gif',sc=3))
# parade divider: imps in the twelve colours
LADDER=['green','blue','purple','cyan','brown','yellow','fireblu','gray','red','abyss','black','white']
def parade(path,cast,W,H,sc=1,bg=None,step=6,extra=None,nfr=None):
    seqs=[[im.resize((im.width*s,im.height*s),Image.NEAREST) for im in spr(col,names)] for col,names,s in cast]
    n=nfr or 4*3; frames=[]
    gap=W/len(cast)
    for f in range(n):
        c=Image.new('RGBA',(W,H),bg or (0,0,0,0))
        if extra: extra(c,f)
        for i,s in enumerate(seqs):
            im=s[(f//3+i)%len(s)]
            x=int(i*gap+gap/2-im.width/2); c.alpha_composite(im,(x,H-im.height-2))
        frames.append(c)
    return frames
fr=parade(None,[(c,W4('TROO'),1) for c in LADDER],840,74)
save_gif(fr,[90]*len(fr),f'{OUT}/divider_imps.gif')
# title banner (opaque dark panel)
BW,BH=960,300
def bgpanel():
    a=np.zeros((BH,BW,4),np.uint8); y=np.linspace(0,1,BH)[:,None]
    a[:,:,0]=(14+50*y**3); a[:,:,1]=(10+8*y); a[:,:,2]=(22+10*(1-y)); a[:,:,3]=255
    im=Image.fromarray(a,'RGBA'); d=ImageDraw.Draw(im)
    for x in range(0,BW,48): d.line((x,BH-46,x-140,BH),fill=(70,24,30,255))
    d.line((0,BH-46,BW,BH-46),fill=(120,40,40,255))
    return im
BG=bgpanel()
t1b=word('RADIANT SILVERGUN',COL['gold'],4); t1h=word('RADIANT SILVERGUN',WHITE,4)
t2=word('QUEST',COL['cyan'],4)
t3=word('DOOM ARCADE VR',COL['steel'],2,F2) if False else word('DOOM ARCADE VR',COL['red'],2)
cast=[('green',W4('TROO'),1),('blue',W4('SARG'),1),('purple',W4('HEAD'),1),('cyan',W4('SPOS'),1),('brown',W3('SKEL'),1),('yellow',W4('FATT'),1),
      ('fireblu',W4('BOSS'),1),('gray',W3('BSPI'),1),('red',W4('PAIN'),1),('black',W4('CYBR'),1)]
def extra(c,f):
    c.alpha_composite(BG)
    t=t1h if f in (0,1,4,5) else t1b
    c.alpha_composite(t,((BW-t.width)//2,22))
    c.alpha_composite(t2,((BW-t2.width)//2,22+t1b.height+6))
    if (f//6)%2==0 or True: c.alpha_composite(t3,((BW-t3.width)//2,22+t1b.height+t2.height+16))
fr=parade(None,cast,BW,BH,extra=extra,nfr=24)
q=[f.convert('RGB').quantize(200,method=Image.MEDIANCUT,dither=Image.Dither.NONE) for f in fr]
q[0].save(f'{OUT}/title_banner.gif',save_all=True,append_images=q[1:],duration=90,loop=0,optimize=True)
fr[8].convert('RGB').save(f'{OUT}/title_banner_still.png')
for f in sorted(os.listdir(OUT)): print(f,os.path.getsize(OUT+'/'+f))
