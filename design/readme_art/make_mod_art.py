# make_mod_art.py <repo> <out dir>: each mod README's animated title and its still divider (design/readme_art/mods/).
# The monster and colour per mod are the mod web's (make_mod_web.py); decoration only.
import sys,os
HERE=os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(HERE,'readme_art_lib.py')).read().split("if __name__")[0])
OUT=sys.argv[2]; os.makedirs(OUT,exist_ok=True)
RC=ROOT+'/MonsterRecolour/rsrecolour/'
LADDER=['green','blue','purple','cyan','brown','yellow','fireblu','gray','red','abyss','black','white']
TXT={'yellow':COL['gold'],'cyan':COL['cyan'],'green':COL['green'],'purple':COL['purple'],'black':COL['steel'],'fireblu':COL['orange'],
     'blue':COL['blue'],'red':COL['red'],'gray':COL['steel'],'brown':((150,84,30),(236,170,100)),'white':((200,204,214),(255,255,255)),'abyss':((90,50,190),(190,150,255))}
M={ # folder: (title, sprite prefix, colour)
'GunBonsaiOffhandVR':('RSQ GUN BONSAI VR','BOSS','yellow'),'Accessibility':('RSQ ACCESSIBILITY','HEAD','cyan'),'Score':('RSQ SCORE','FATT','green'),'SlowMo':('RSQ SLOWMO','PAIN','purple'),
'Miniboss':('RSQ MINIBOSS','CYBR','black'),'VisualRewards':('RSQ VISUAL REWARDS','HEAD','fireblu'),'TacticalRig':('RSQ TACTICAL RIG','CPOS','green'),'GunCards':('RSQ GUN CARDS','SPOS','blue'),
'FlashFlare':('RSQ FNF','TROO','yellow'),'Grenade':('RSQ GRENADE','FATT','red'),'DistanceGrab':('RSQ DISTANCE GRAB','SARG','cyan'),'LaserSight':('RSQ LASER SIGHT','BSPI','red'),
'QuestSaber':('RSQ SABER','BOSS','blue'),'GlowInTheDark':('RSQ GLOW IN THE DARK','PAIN','fireblu'),'Graveyard':('RSQ GRAVEYARD','SKEL','gray'),'Monsters':('RSQ MONSTERS','TROO','purple'),
'Melee':('RSQ MELEE','SARG','red'),'ShieldSaw':('RSQ SHIELDSAW','BSPI','brown'),'Wheel':('RSQ WHEEL','SPID','white'),'Whip':('RSQ WHIP','SKEL','brown'),'Grapple':('RSQ GRAPPLE','TROO','abyss'),
# the other READMEs (key: title, sprite, colour)
'MonsterRecolour':('RSQ MONSTER RECOLOUR','CYBR','red'),'GNRC_Reloaded':('GNRC RELOADED VR','CPOS','yellow'),'WoS_Reloaded':('WOS RELOADED','SPOS','purple'),
'WADs':('WADS','SARG','green'),'Renders':('RENDERS','HEAD','red'),'TestRig':('TESTRIG','BSPI','cyan'),'front':('RSQ UBQ SERIES','TROO','yellow')}
def walk(col,pre,hmax):
    names=[pre+x for x in ('A1','B1','C1','D1')]
    if not os.path.exists(RC+col+'/'+names[0]+'.png'): names=[pre+x for x in ('A1D1','B1E1','C1F1','B1E1')]
    ims=[Image.open(RC+col+'/'+n+'.png').convert('RGBA') for n in names]
    k=min(2.0,hmax/max(i.height for i in ims))
    return [i.resize((max(1,int(i.width*k)),max(1,int(i.height*k))),Image.NEAREST) for i in ims]
for folder,(title,pre,col) in M.items():
    key=folder.lower()
    look=TXT[col]; base=word(title,look,4); hot=word(title,WHITE,4)
    w=walk(col,pre,72); mw=max(i.width for i in w); Hh=max(base.height,max(i.height for i in w))+8
    W=mw*2+base.width+int(base.height*0.5)+60; tx=mw+30
    frames=[]
    for f in range(36):
        c=Image.new('RGBA',(W,Hh),(0,0,0,0))
        if f<4: t=smear(hot if f<2 else base,1.0-f*0.25)
        else: t=hot if (f<10 and f%2==0) else base
        c.alpha_composite(t.crop((0,0,min(t.width,W-tx),t.height)),(tx,(Hh-base.height)//2))
        s=w[(f//3)%4]; c.alpha_composite(s,((mw-s.width)//2,Hh-s.height-2))
        s2=w[(f//3+2)%4].transpose(Image.FLIP_LEFT_RIGHT); c.alpha_composite(s2,(W-mw+(mw-s2.width)//2,Hh-s2.height-2))
        frames.append(c)
    save_gif(frames,[110]*36,f'{OUT}/{key}_title.gif')
    # the still divider: this mod's monster in the twelve ladder colours
    ws=[walk(c2,pre,44)[i%4] for i,c2 in enumerate(LADDER)]
    cw=max(i.width for i in ws)+14; d=Image.new('RGBA',(cw*12,48),(0,0,0,0))
    for i,s in enumerate(ws): d.alpha_composite(s,(i*cw+(cw-s.width)//2,48-s.height-2))
    d.save(f'{OUT}/{key}_divider.png',optimize=True)
print(len(M),'mods')
