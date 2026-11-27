# make_controls_quest2.py <repo> <out dir>: the front page's two RSQoopaControls pictures, drawn from
# design/controls/rsq_standard_controls.ini (the owner's layout, 2026-11-27). Nothing is typed by hand but the plain
# words for each command (WORD); a command missing from WORD stops the script.
#   keys_buttons.png:     a table: each button, press / double press / right grip + press. FREE = a spot that can take
#                         a bind; "-" = not a slot (not a button, or a button you press fast: triggers, kick).
#   keys_controllers.png: both Quest 2 controllers with lines to each button.
import sys,os
REPO=sys.argv[1]; OUTDIR=sys.argv[2]
exec(open(REPO+'/design/readme_art/readme_art_lib.py').read().split("if __name__")[0])
from PIL import ImageDraw
ini=open(REPO+'/design/controls/rsq_standard_controls.ini').read()
B={};D={};cur=None
for L in ini.splitlines():
    L=L.strip()
    if L=='[Doom.Bindings]': cur=B; continue
    if L=='[Doom.DoubleBindings]': cur=D; continue
    if L.startswith('['): cur=None; continue
    if not L or L.startswith('#') or cur is None: continue
    k,v=L.split('=',1); cur[k]=v
WORD={'+oh_attack':'OFF-HAND FIRE','+oh_altatk':'OFF-HAND ALT FIRE','+attack':'MAIN-HAND FIRE','+altattack':'MAIN-HAND ALT FIRE',
 'rsqsm_toggle':'SLOWMO','rsqsm_dodge':'CRISIS DIVE','ssq_draw':'SHIELDSAW','invuse':'USE ITEM','togglemap':'MAP',
 'netevent bonsai-show-info':'GUN BONSAI MENU','+jump':'JUMP','+user1':'QUICK GRENADE','+crouch':'DUCK (HOLD)','+zoom':'KICK','brutaltaunt':'TAUNT (FLIP OFF)',
 '+reload':'RELOAD / DROP MAG','weapprev':'MAIN PREV WEAPON','weapnext':'MAIN NEXT WEAPON','+use':'USE','+user3':'BD DUAL',
 'menu_main':'MAIN MENU','+rsqgr_hook':'GRAPPLE','+wr_wheel':'WHEEL','slot 3':'SLOT 3','switchhand 1':'MAIN GUN TO OFF HAND',
 'invnext':'NEXT ITEM','netevent rsqgd_randomize':'GITD RANDOMIZE LOOK','switchhand 0':'OFF GUN TO MAIN HAND','rsqtr_recenter':'RECENTER TORSO','':None}
b=lambda k: WORD[B.get(k,'')]; d=lambda k: WORD[D.get(k,'')]
RG='RIGHT GRIP +'
def rows(press=None,dbl=None,mod=None):
    out=[]
    if press: out.append(('PRESS',press))
    if dbl: out.append(('2X',dbl))
    if mod: out.append((RG,mod))
    return out
# ---------------------------------------------------------------- look
S=3; H=860; YO=110
BG=(14,11,20); BODY=(46,46,54); BODY2=(60,60,70); EDGE=(178,178,192); BTN=(88,88,100); LINE=(214,162,48); DASH=(110,205,110)
WH=((205,205,215),(255,255,255)); TAG=((140,140,155),(175,175,190))
def T(s,look,sc=2): m=mask(s,F2); return paint(m,*look).resize((m.width*sc,m.height*sc),Image.NEAREST)
def Big(s,look,sc=2): im=boxed(paint(mask(s,F1),*look),1); return im.resize((im.width*sc,im.height*sc),Image.NEAREST)
def block(name,rs):
    head=Big(name,COL['green'])
    tagw=max([T(t,TAG).width for t,_ in rs]+[0])
    lines=[]
    for t,v in rs:
        a=T(t,TAG); c=T(v,WH); r=Image.new('RGBA',(tagw+16+c.width,max(a.height,c.height)))
        r.alpha_composite(a,(0,0)); r.alpha_composite(c,(tagw+16,0)); lines.append(r)
    Wb=max([head.width]+[l.width+16 for l in lines]); Hb=head.height+8+sum(l.height+6 for l in lines)
    im=Image.new('RGBA',(Wb,Hb)); im.alpha_composite(head,(0,0)); y=head.height+8
    for l in lines: im.alpha_composite(l,(16,y)); y+=l.height+6
    return im,head.height

BL=dict(lt=block('TRIGGER',rows(b('Shift'),None,b('Alt'))),
        ls=block('STICK',[('PUSH','MOVE'),('CLICK',b('Space')),('CLICK 2X',d('Space')),(RG+' CLICK',b('Home'))]),
        ly=block('Y',rows(b('Pad_Y'),d('Pad_Y'),b('PgUp'))),
        lx=block('X',rows(b('Pad_X'),d('Pad_X'),b('PgDn'))),
        lg=block('GRIP',[('PRESS','GRABS GUN WITH BOTH HANDS')]+rows(None,d('RThumb'),None)),
        rt=block('TRIGGER',rows(b('RTrigger'),None,b('LTrigger'))),
        rs=block('STICK',[('UP',b('MWheelUp')),('UP 2X','DOUBLE JUMP'),(RG+' UP',b('Axis8Plus')),('DOWN',b('MWheelDown')),(RG+' DOWN',b('Axis8Minus')),
                  ('LEFT / RIGHT','SNAP TURN'),(RG+' LEFT',b('Axis7Minus')),(RG+' RIGHT',b('Axis7Plus')),
                  ('CLICK',b('Enter')),('CLICK 2X',d('Enter')),(RG+' CLICK',b('Tab'))]),
        rb=block('B',rows(b('Pad_B'),d('Pad_B'),b('Backspace'))),
        ra=block('A',rows(b('Pad_A'),d('Pad_A'),b('LThumb'))),
        rg=block('GRIP',[('HOLD','MODIFIER')]))
wd=lambda *k: max(BL[x][0].width for x in k)
cxL=40+wd('lt','ls')+70+160
ix=cxL+190
cxR=ix+wd('ly','lx','lg')+90+wd('rb','ra','rg')+190
W=cxR+230+wd('rt','rs')+40
big=Image.new('RGB',(W*S,H*S),BG); g=ImageDraw.Draw(big)
P=lambda x,y:(x*S,(y+YO)*S)
def ell(cx,cy,rx,ry,fill=None,outline=None,w=0):
    g.ellipse([(cx-rx)*S,(cy-ry+YO)*S,(cx+rx)*S,(cy+ry+YO)*S],fill=fill,outline=outline,width=int(w*S))
def dashbox(x0,y0,x1,y1):
    x0,x1=min(x0,x1),max(x0,x1)
    for a,c in [((x0,y0),(x1,y0)),((x1,y0),(x1,y1)),((x1,y1),(x0,y1)),((x0,y1),(x0,y0))]:
        Ln=((c[0]-a[0])**2+(c[1]-a[1])**2)**.5; k=max(2,int(Ln//12))
        for i in range(0,k,2):
            t0,t1=i/k,min(1,(i+1)/k)
            g.line([P(a[0]+(c[0]-a[0])*t0,a[1]+(c[1]-a[1])*t0),P(a[0]+(c[0]-a[0])*t1,a[1]+(c[1]-a[1])*t1)],fill=DASH,width=4*S)
def controller(cx,s):   # s=+1 left controller (inner side +x), s=-1 right
    X=lambda dx: cx+s*dx
    # tracking ring (forward, over the thumb)
    ell(X(-8),150,150,96,outline=EDGE,w=26); ell(X(-8),150,150,96,outline=BODY2,w=20)
    # handle
    hp=[(X(-88),330),(X(80),330),(X(66),500),(X(48),585),(X(-28),600),(X(-62),560),(X(-98),420)]
    g.polygon([P(*p) for p in hp],fill=BODY,outline=EDGE,width=3*S)
    ell(X(10),588,40,22,fill=BODY,outline=None)
    # face
    ell(cx,300,142,100,fill=BODY2,outline=EDGE,w=3)
    # trigger (front, under the index finger) and grip (inner side, under the middle finger)
    dashbox(X(-38),196,X(58),230); dashbox(X(74),420,X(108),535)
    # stick, buttons, menu
    st=(X(-52),288); ell(*st,46,46,fill=(36,36,42),outline=EDGE,w=3); ell(*st,29,29,fill=BTN,outline=EDGE,w=2)
    up=(X(62),258); lo=(X(44),322)
    ell(*up,23,23,fill=BTN,outline=EDGE,w=2); ell(*lo,23,23,fill=BTN,outline=EDGE,w=2)
    ell(X(2),372,9,9,fill=BTN,outline=EDGE,w=2)
    return dict(TRIG_OUT=(X(-38),213),STICK_OUT=(X(-98),288),UP_IN=(X(85),258),LO_IN=(X(67),322),GRIP_IN=(X(108),478),
                up=up,lo=lo)
L=controller(cxL,1); R=controller(cxR,-1)
img=big.resize((W,H),Image.LANCZOS).convert('RGBA'); dr=ImageDraw.Draw(img)
for anc,lt in ((L['up'],'Y'),(L['lo'],'X'),(R['up'],'B'),(R['lo'],'A')):
    t=T(lt,WH); img.alpha_composite(t,(int(anc[0]-t.width/2),int(anc[1]+YO-t.height/2)))
def place(bk,x,y,anchor,line_from_right):
    im,hh=bk; img.alpha_composite(im,(int(x),int(y)))
    ey=int(y+hh/2); ex=int(x+im.width+16) if line_from_right else int(x-16)
    ax,ay=anchor[0],anchor[1]+YO
    elbow=ax-40 if line_from_right else ax+40
    dr.line([(ex,ey),(elbow,ey),(ax,ay)],fill=LINE,width=3,joint='curve')
    dr.ellipse([ax-6,ay-6,ax+6,ay+6],fill=LINE)
    return im
place(BL['lt'],40,YO+70,L['TRIG_OUT'],True); place(BL['ls'],40,YO+300,L['STICK_OUT'],True)
place(BL['ly'],ix,YO+150,L['UP_IN'],False); place(BL['lx'],ix,YO+330,L['LO_IN'],False); place(BL['lg'],ix,YO+500,L['GRIP_IN'],False)
place(BL['rt'],W-40-BL['rt'][0].width,YO+70,R['TRIG_OUT'],False); place(BL['rs'],W-40-BL['rs'][0].width,YO+260,R['STICK_OUT'],False)
def rplace(bk,y,anc): place(bk,cxR-190-bk[0].width,y,anc,True)
rplace(BL['rb'],YO+150,R['UP_IN']); rplace(BL['ra'],YO+330,R['LO_IN']); rplace(BL['rg'],YO+500,R['GRIP_IN'])
top=Big('RSQOOPACONTROLS',COL['gold'],3); img.alpha_composite(top,((W-top.width)//2,26))
for cx,t in ((cxL,'LEFT'),(cxR,'RIGHT')):
    tt=Big(t,COL['red']); img.alpha_composite(tt,(cx-tt.width//2+10,YO+640))
note=T('DASHED = UNDER YOUR FINGERS     HOLD RIGHT GRIP FOR EVERY  RIGHT GRIP +  LINE',TAG)
img.alpha_composite(note,((W-note.width)//2,H-50))
img.convert('RGB').save(os.path.join(OUTDIR,'keys_controllers.png')); print(img.size)
