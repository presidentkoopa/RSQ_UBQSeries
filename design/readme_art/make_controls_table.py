# make_controls_table.py <repo> <out dir>: the front page's two RSQoopaControls pictures, drawn from
# design/controls/rsq_standard_controls.ini (the owner's layout, 2026-11-27). Nothing is typed by hand but the plain
# words for each command (WORD); a command missing from WORD stops the script.
#   keys_buttons.png:     a table: each button, press / double press / right grip + press. "-" = nothing there.
#   keys_controllers.png: both Quest 2 controllers with lines to each button.
import sys,os,re
REPO=sys.argv[1]; OUTDIR=sys.argv[2]; HERE=REPO+'/design/readme_art'
exec(open(os.path.join(HERE,'readme_art_lib.py')).read().split("if __name__")[0])
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
 'invnext':'NEXT ITEM','netevent rsqgd_randomize':'GITD RANDOMIZE LOOK','switchhand 0':'OFF GUN TO MAIN HAND','rsqtr_recenter':'RECENTER TORSO','':'-'}
w=lambda d,k: WORD[d.get(k,'')] if k else '-'
LEFT=[('TRIGGER','Shift',None,'Alt'),('GRIP','#GRABS GUN','RThumb',None),('STICK','#MOVE',None,None),
      ('STICK CLICK','Space','Space','Home'),('X','Pad_X','Pad_X','PgDn'),('Y','Pad_Y','Pad_Y','PgUp')]
RIGHT=[('TRIGGER','RTrigger',None,'LTrigger'),('GRIP','#MODIFIER',None,None),('STICK UP','MWheelUp','#DOUBLE JUMP','Axis8Plus'),
       ('STICK DOWN','MWheelDown',None,'Axis8Minus'),('STICK LEFT','#SNAP TURN',None,'Axis7Minus'),('STICK RIGHT','#SNAP TURN',None,'Axis7Plus'),
       ('STICK CLICK','Enter','Enter','Tab'),('A','Pad_A','Pad_A','LThumb'),('B','Pad_B','Pad_B','Backspace')]
def cell(k,d):
    if k is None: return '-'
    if k.startswith('#'): return k[1:]
    return WORD[d.get(k,'')]
def T(s,look,sc=2): m=mask(s,F2); return paint(m,*look).resize((m.width*sc,m.height*sc),Image.NEAREST)
def Big(s,look,sc=2): im=boxed(paint(mask(s,F1),*look),1); return im.resize((im.width*sc,im.height*sc),Image.NEAREST)
FREE=((70,150,220),(120,190,255)); TXT=((196,196,206),(255,255,255)); DIM=((90,90,100),(120,120,130)); HEAD=COL['gold']
BG=(14,11,20); PANEL=(26,22,34); EDGE=(150,110,40)
COLW=[230,300,300,330]; ROWH=34; PAD=24
def panel(title,rows):
    W=sum(COLW)+2*PAD; H=PAD+60+ROWH+len(rows)*ROWH+PAD
    im=Image.new('RGBA',(W,H),PANEL+(255,)); d=ImageDraw.Draw(im)
    d.rectangle([0,0,W-1,H-1],outline=EDGE,width=3)
    t=Big(title,COL['red']); im.alpha_composite(t,((W-t.width)//2,PAD))
    y=PAD+60; x=PAD
    for i,h in enumerate(['BUTTON','PRESS','DOUBLE PRESS','RIGHT GRIP + PRESS']):
        im.alpha_composite(T(h,HEAD),(x,y)); x+=COLW[i]
    y+=ROWH
    for n,(b,p,dd,m) in enumerate(rows):
        if n%2==0: d.rectangle([PAD-8,y-6,W-PAD+8,y+ROWH-10],fill=(34,29,44))
        vals=[b,cell(p,B),cell(dd,D),cell(m,B)]; x=PAD
        for i,v in enumerate(vals):
            look=COL['green'] if i==0 else (DIM if v=='-' else (FREE if v=='FREE' else TXT))
            im.alpha_composite(T(v,look),(x,y)); x+=COLW[i]
        y+=ROWH
    return im
L=panel('LEFT CONTROLLER',LEFT); R=panel('RIGHT CONTROLLER',RIGHT)
top=Big('RSQOOPACONTROLS',COL['gold'],3)
W=max(L.width,top.width)+80; H=40+top.height+30+L.height+30+R.height+40
out=Image.new('RGBA',(W,H),BG+(255,)); y=40
out.alpha_composite(top,((W-top.width)//2,y)); y+=top.height+30
out.alpha_composite(L,((W-L.width)//2,y)); y+=L.height+30
out.alpha_composite(R,((W-R.width)//2,y))
pass
out.convert('RGB').save(os.path.join(OUTDIR,'keys_buttons.png')); print(out.size)
