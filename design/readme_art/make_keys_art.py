# make_keys_art.py <repo> <out dir>: the front page's two keys pictures, in RSQ Score's fonts.
#   keys_buttons.png: what each hand's buttons do with default settings, by mod, and the keys you bind yourself.
#   keys_body.png:    the places on your body the mods use, and the moves made with the hands.
# Every line is taken from a mod's README (How to play and Keys, written from the code on 2026-11-27). The front
# page's Keys table carries the same lines as text. Change a line here and there together.
import sys,os
HERE=os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(HERE,'readme_art_lib.py')).read().split("if __name__")[0])
from PIL import ImageDraw
OUT=sys.argv[2]; os.makedirs(OUT,exist_ok=True)
BG=(14,11,20); PANEL=(26,22,34); EDGE=(150,110,40)
TXT=((196,196,206),(255,255,255)); DIM=((130,130,145),(175,175,190))
BTN={'TRIGGER':COL['red'],'ALT FIRE':COL['blue'],'GRIP':COL['green'],'STICK CLICK':COL['gold'],'USE':COL['purple'],
     'JUMP':COL['cyan'],'NEXT / PREV WEAPON':COL['steel'],'HELP KEY':COL['steel'],'TOSS GRENADE (+USER1)':COL['red'],
     'DUAL (+USER3)':COL['steel'],"GUN BONSAI'S INFO KEY":COL['gold']}
def t(s,look=TXT,sc=2,F=F2): return paint(mask(s,F),*look).resize((mask(s,F).width*sc,mask(s,F).height*sc),Image.NEAREST)
def big(s,look,sc=2): im=boxed(paint(mask(s,F1),*look),1); return im.resize((im.width*sc,im.height*sc),Image.NEAREST)
def wrap(s,maxw,sc=2):
    words=s.split(' '); lines=[]; cur=''
    for w in words:
        c=(cur+' '+w).strip()
        if mask(c,F2).width*sc>maxw and cur: lines.append(cur); cur=w
        else: cur=c
    lines.append(cur); return lines
def block(rows,width):
    """rows: (button, [lines]) -> an RGBA image of the column"""
    parts=[]
    for b,lines in rows:
        h=big(b,BTN[b],2); parts.append(('h',h))
        for L in lines:
            for i,w in enumerate(wrap(L,width-60)): parts.append(('t' if i==0 else 't2',t(w)))
        parts.append(('gap',None))
    H=sum((p.height+4) if k!='gap' else 10 for k,p in parts)
    c=Image.new('RGBA',(width,H),(0,0,0,0)); y=0
    for k,p in parts:
        if k=='gap': y+=10; continue
        if k=='h':
            c.alpha_composite(p,(0,y))
        else: c.alpha_composite(p,(22 if k=='t' else 46,y))
        y+=p.height+4
    return c
def controller(left,col_t,col_a,col_g,col_s):
    """a plain drawing of a VR controller: tracking ring, handle, trigger (red), grip (green), face button (blue),
    stick (gold). left=True draws the left hand's."""
    W,H=230,210; im=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    body=(70,70,82,255); line=(20,18,26,255)
    d.ellipse((30,8,200,108),outline=(90,90,104,255),width=14)              # ring
    d.polygon([(85,70),(150,70),(140,200),(98,200)],fill=body,outline=line)  # handle
    d.rounded_rectangle((70,52,165,96),radius=18,fill=(84,84,98,255),outline=line,width=2)  # face
    d.ellipse((93+(0 if left else 18),58,117+(0 if left else 18),82),fill=col_s+(255,),outline=line,width=2)  # stick
    d.ellipse((128-(36 if not left else 0),74,142-(36 if not left else 0),88),fill=col_a+(255,),outline=line)  # face button
    gx=78 if not left else 140
    d.rounded_rectangle((gx,104,gx+16,160),radius=6,fill=col_g+(255,),outline=line,width=2)  # grip on the inside
    d.polygon([(100,96),(136,96),(128,128),(106,124)],fill=col_t+(255,),outline=line)        # trigger, under the face
    return im
# ---------- keys_buttons.png ----------
OFF=[('TRIGGER',['WHEEL: CHOOSE AND CLOSE','SABER: HOLD TO LOCK ON; SWING AND LET GO TO THROW','SHIELDSAW: REV THE SAW; WITH RINGS ON, CLEAR THEM',
                 'GRENADE: AT THE RING, TAKE IT AND PULL THE PIN','FNF: LIGHT THE FLARE, HOLD AND SWING TO THROW IT',
                 'FNF: FLASHLIGHT ON / OFF','MINIBOSS KIOSK: BUY THE OFFER YOU POINT AT']),
     ('ALT FIRE',['WHEEL: CHOOSE, KEEP THE WHEEL OPEN','SABER: HOLD FOR THE FORCE: THRUST TO PUSH, YANK TO PULL, HOLD STILL TO GRIP']),
     ('GRIP',['TACTICAL RIG: HOLSTER AND DRAW AT A HOLSTER','MELEE: HEADLOCK, AT A MONSTER',
              'FNF: TAKE THE FLARE OR THE FLASHLIGHT AT YOUR CHEST','DISTANCE GRAB: WALK-UP GRAB WITHIN 30 CM']),
     ('STICK CLICK',['WHEEL: OPEN WHEEL (LEFT STICK, THE ONE KEY BOUND BY DEFAULT)'])]
MAIN=[('TRIGGER',['WHEEL: CHOOSE AND CLOSE','SABER: HOLD TO LOCK ON; SWING AND LET GO TO THROW',
                  'SHIELDSAW: HOLD AND POINT TO RING TARGETS','MELEE: HOLD AND POINT TO PAINT A BARREL\'S TARGET',
                  'GRENADE: PIN OUT, HOLD, SWING, LET GO: THROWN','MINIBOSS KIOSK: BUY THE OFFER YOU POINT AT']),
      ('ALT FIRE',['WHEEL: ON A CARD, ASSIGN A HOLSTER (WITH THE RIG)','SABER: FORCE PUSH','GRENADE: NEXT GRENADE TYPE (PIN IN)',
                   'MINIBOSS KIOSK: LUCKY']),
      ('GRIP',['TACTICAL RIG: HOLSTER AND DRAW AT A HOLSTER','TACTICAL RIG: A CIGARETTE AT THE POCKET',
               'DISTANCE GRAB: WALK-UP GRAB WITHIN 30 CM'])]
ANY=[('USE',['TACTICAL RIG: HOLSTER AND DRAW, LIKE THE GRIP','MINIBOSS: ON THE GOLD START FIGHT CARD, CALL THE FIGHT',
             'GRAVEYARDS: READ A GRAVESTONE']),
     ('JUMP',['GRAPPLE: DOUBLE JUMP IN THE AIR','SABER: HOLD FOR A FORCE JUMP']),
     ('NEXT / PREV WEAPON',['WHEEL: THAT HAND STEPS TO ITS NEXT GUN']),
     ('TOSS GRENADE (+USER1)',['GRENADE: QUICK GRENADE'])]
ANY2=[('DUAL (+USER3)',["SABER: SECOND SABER AWAY / OUT (BRUTAL DOOM'S BUTTON)"]),
      ('HELP KEY',['SCORE: THE GLOSSARY']),
      ("GUN BONSAI'S INFO KEY",['GUN BONSAI VR: STATUS AND LEVEL-UP SCREENS'])]
UNBOUND=['GRAPPLE: FIRE HOOK','SHIELDSAW: DRAW / PUT BACK / RECALL','GRENADE: QUICK GRENADE',
         'SLOWMO: SLOW MOTION ON/OFF, CRISIS DIVE','TACTICAL RIG: RECENTER TORSO',
         'DISTANCE GRAB: GRAB / PULL, EACH HAND (NEEDS GRAB KEYS ON)']
W=1240; CW=590
title=big('THE BUTTONS',COL['gold'],3)
sub=t('DEFAULT SETTINGS. RIGHT-HANDED: THE OFF HAND IS THE LEFT.',DIM)
ctlL=controller(True,COL['red'][1],COL['blue'][1],COL['green'][1],COL['gold'][1])
ctlR=controller(False,COL['red'][1],COL['blue'][1],COL['green'][1],COL['gold'][1])
bL=block(OFF,CW); bR=block(MAIN,CW); bA=block(ANY,CW); bA2=block(ANY2,CW)
ub=[[t(w) for w in wrap(s,CW-40)] for s in UNBOUND]
H=40+title.height+sub.height+ctlL.height+60+max(bL.height,bR.height)+70+max(bA.height,bA2.height)+60+sum(sum(x.height+6 for x in u) for u in ub)+30
im=Image.new('RGBA',(W,H),BG+(255,)); d=ImageDraw.Draw(im)
d.rectangle((0,0,W-1,H-1),outline=EDGE+(255,),width=3)
y=20; im.alpha_composite(title,((W-title.width)//2,y)); y+=title.height+6
im.alpha_composite(sub,((W-sub.width)//2,y)); y+=sub.height+14
for i,(ctl,lab) in enumerate(((ctlL,'OFF HAND'),(ctlR,'MAIN HAND'))):
    x0=20+i*(CW+40); im.alpha_composite(ctl,(x0+(CW-ctl.width)//2,y))
    L=big(lab,COL['steel'],2); im.alpha_composite(L,(x0+(CW-L.width)//2,y+ctl.height+4))
y+=ctlL.height+L.height+24
im.alpha_composite(bL,(20,y)); im.alpha_composite(bR,(60+CW,y)); y+=max(bL.height,bR.height)+10
d.line((20,y,W-20,y),fill=EDGE+(255,),width=2); y+=14
L=big('EITHER HAND, OR A KEY',COL['steel'],2); im.alpha_composite(L,((W-L.width)//2,y)); y+=L.height+14
im.alpha_composite(bA,(20,y)); im.alpha_composite(bA2,(60+CW,y)); y+=max(bA.height,bA2.height)+10
d.line((20,y,W-20,y),fill=EDGE+(255,),width=2); y+=14
L=big('NOT BOUND: BIND THEM IN CUSTOMIZE CONTROLS',COL['orange'],2); im.alpha_composite(L,((W-L.width)//2,y)); y+=L.height+12
for i in range(0,len(ub),2):
    hh=0
    for j,u in enumerate(ub[i:i+2]):
        x=20 if j==0 else 60+CW; yy=y
        for k,line in enumerate(u): im.alpha_composite(line,(x+(22 if k==0 else 46),yy)); yy+=line.height+4
        hh=max(hh,yy-y)
    y+=hh+6
im=im.crop((0,0,W,y+24)); d=ImageDraw.Draw(im); d.rectangle((0,0,W-1,im.height-1),outline=EDGE+(255,),width=3)
im.convert('RGB').save(f'{OUT}/keys_buttons.png',optimize=True); print('keys_buttons',im.size)
# ---------- keys_body.png ----------
PLACES=[ # (number, the markers on the marine (x,y in the 8x sprite, offset below), place, lines)
 (1,[(126,74)],'MOUTH',['GRENADE: PULL THE PIN WITH YOUR TEETH','TACTICAL RIG: CIGARETTE TO YOUR LIPS, USE']),
 (2,[(196,30)],'IN FRONT OF YOUR FACE',['SLOWMO: CROSS YOUR WRISTS: SLOW MOTION ON / OFF']),
 (3,[(34,104),(214,96)],'SHOULDERS',['TACTICAL RIG: A HOLSTER OVER EACH','SHIELDSAW: THE OFF SHOULDER, WHEN MOUNTED']),
 (4,[(132,140)],'CHEST',['TACTICAL RIG: A HOLSTER EACH SIDE; CIGARETTES',
                       'TACTICAL RIG: BOTH HANDS ON YOUR CHEST: RECENTER','FNF: THE FLARE POCKET, THE FLASHLIGHT CLIP']),
 (5,[(26,176),(246,128)],'BACK OF EITHER WRIST',['GUN CARDS: TURN IT TO YOUR EYES, LOOK: WATCH CARD']),
 (6,[(272,160)],'INSIDE OF THE OFF WRIST',['MINIBOSS: TURN IT TO YOUR EYES, LOOK: START FIGHT CARD']),
 (7,[(128,222)],'BELT',['TACTICAL RIG: GRENADE SPOT, KEYRING, AMMO POUCH']),
 (8,[(66,248),(196,250)],'HIPS',['TACTICAL RIG: A HOLSTER ON EACH HIP','TACTICAL RIG: SABERS BELOW, WHIP AND FLARES BEHIND']),
]
MOVES=['MELEE: SWING A FIST: JAB, HOOK, UPPERCUT','MELEE: DRIVE THE GUN HAND FORWARD: GUN BUTT SHOVE',
       'DISTANCE GRAB: PALM OUT AT A THING, FLICK THE WRIST','SABER: SWING THE BLADE THROUGH IT',
       'SHIELDSAW: SWING THE OFF ARM FORWARD: THROW','WHIP: A WIDE LEVEL SWING; A HARD FLICK DOWN',
       'GRAPPLE: IN THE AIR, BOTH HANDS DOWN HARD: AIR SPIKE','GRENADE AND FNF: SWING AND LET GO: THROW']
# THE FIGURE: the Doom marine sprite PLAYA1 (Brutal Doom's, the one RSQ Wheel's holster screen draws), 8x, no drawn body
# (owner 2026-11-27: "what is this ugly AI art when we have a Doom marine sprite in the rig or wheel")
FW,FH=400,520; OX,OY=36,34
fig=Image.new('RGBA',(FW,FH),(0,0,0,0)); d=ImageDraw.Draw(fig)
mar=Image.open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'marine_PLAYA1.png')).convert('RGBA')
mar=mar.resize((mar.width*8,mar.height*8),Image.NEAREST); fig.alpha_composite(mar,(OX,OY))
lab=t('MAIN HAND',DIM); fig.alpha_composite(lab,(OX+4,OY+mar.height+10)); lab=t('OFF HAND',DIM); fig.alpha_composite(lab,(OX+mar.width-lab.width-4,OY+mar.height+10))
for n,pts,_,_ in PLACES:
    for (px,py) in pts:
        x,y=OX+px,OY+py
        d.ellipse((x-15,y-15,x+15,y+15),fill=(240,150,20,255),outline=(20,14,10,255),width=2)
        num=t(str(n),((20,14,10),(20,14,10))); fig.alpha_composite(num,(x-num.width//2+1,y-num.height//2))
rows=[]
for n,_,place,lines in PLACES:
    rows.append(big(f'{n} {place}',COL['gold'],2))
    for L in lines:
        for w in wrap(L,770): rows.append(t(w))
    rows.append(None)
rows.append(big('WITH YOUR HANDS',COL['gold'],2))
for L in MOVES: rows.append(t(L))
RH=sum((r.height+4) if r is not None else 8 for r in rows)
W2=1240; title=big('WHERE ON YOUR BODY',COL['gold'],3)
H2=max(FH,RH)+title.height+60
im=Image.new('RGBA',(W2,H2),BG+(255,)); d=ImageDraw.Draw(im); d.rectangle((0,0,W2-1,H2-1),outline=EDGE+(255,),width=3)
im.alpha_composite(title,((W2-title.width)//2,18)); y0=title.height+38
im.alpha_composite(fig,(24,y0)); y=y0
for r in rows:
    if r is None: y+=8; continue
    im.alpha_composite(r,(440,y)); y+=r.height+4
im.convert('RGB').save(f'{OUT}/keys_body.png',optimize=True); print('keys_body',im.size)
