import sys,os
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'readme_art_lib.py')).read().split("if __name__")[0])
OUT=sys.argv[2]
for fn,t,c in [('gun_cards','GUN CARDS','blue'),('gun_bonsai_vr','GUN BONSAI VR','gold'),('saber','SABER','cyan'),('shieldsaw','SHIELDSAW','steel'),('whip','WHIP','orange'),
 ('flash_and_flare','FLASH AND FLARE','red'),('glow_in_the_dark','GLOW IN THE DARK','purple'),('boss','THE BOSS','red'),('monsters','MONSTERS','green'),('graveyard','GRAVEYARD','steel'),
 ('score','SCORE','gold'),('laser_sight','LASER SIGHT','red'),('accessibility','ACCESSIBILITY','cyan'),('connected',"IT'S ALL CONNECTED",'pink')]:
    header(t,c,f'{OUT}/h_{fn}.gif',sc=3)
