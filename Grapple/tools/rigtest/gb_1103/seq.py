import sys
# TEST ONLY (2026-11-03). Console scripts for the GRV room (../og_1103/grv.pk3) with Gun Bonsai + RSQ_GunBonsaiVR (+ gbp.pk3).
#   fastreel: Fast Reel 0, then 4 -- a wall shot from 600 (OG fling) and an imp at 400 (OG yank)
#   twin:     offers before/after Momentum; Momentum only (second rope lets the first go), then Twin Lines 2 (both hold,
#             a tap on one flings along the other)
#   extreme:  Long Line 4 + Fast Reel 4, a wall 1380 away (the hardest fling the tree gives)
#   scorpion: RSQ Melee's glove in hand, Grapple + Scorpion 1: an imp OG-yanked from 400 arrives and is punched
def up(c,n): return 'netevent bonsai-debug,p-up,RSQ_Upgrade_%s %d'%(c,n)
def shot(name, x, pitch, extra=[], hand=0):
    return ['qz_rhand "0.25 1.3 -0.3 %d 0 0"'%pitch,'netevent grv_tp %d 512 0'%x,'wait 3']+extra+['wait 3','echo SHOT_%s'%name,
            'event rsqgr_press %d'%hand,'wait 2','event rsqgr_release %d'%hand,'wait 80']
mode=sys.argv[1]
s=['wait 2','map GRV','wait 10','notarget','god','rsqgr_debug 1',up('Grapple',1),'wait 40']
if mode=='fastreel':
    for lv in (0,4):
        if lv: s+=[up('FastReel',lv),'wait 40']
        s+=shot('fr%d_wall600'%lv,1800,30)
        s+=shot('fr%d_imp400'%lv,600,30,['netevent grv_sum 0 400'])
elif mode=='extreme':
    # the fastest fling the tree allows: Long Line 4 (range x1.8) + Fast Reel 4 (x1.4), a wall 1380 away
    s+=[up('LongLine',4),up('FastReel',4),'wait 40']
    s+=shot('ll4fr4_wall1380',1020,30)
elif mode.startswith('twin'):
    # twin0 = Momentum only; twin1 / twin2 = Twin Lines 1 / 2. Both claws on the ceiling 35 degrees either side, both
    # reels held 50 tics (up off the floor), released: the hang. twin1 then holds the right reel alone 20 tics; twin2
    # taps the right press (lets that rope go: flung along the left one). Then a tap lets go of what is left.
    lv=int(mode[4:] or 0)
    s+=['netevent gbp_offers',up('LongLine',2),'wait 40','echo OFFERS_longline2','netevent gbp_offers']
    s+=[up('SwingMomentum',1),'wait 40','echo OFFERS_momentum','netevent gbp_offers']
    if lv: s+=[up('TwinLines',lv),'wait 40','echo OFFERS_twin%d'%lv,'netevent gbp_offers']
    s+=['netevent grv_tp 1200 512 0','qz_rhand "0.25 1.3 -0.3 90 -35 0"','qz_lhand "-0.25 1.3 -0.3 90 35 0"','wait 6','echo SHOT_twin%d'%lv,
        'event rsqgr_press 0','wait 4','event rsqgr_press 1','wait 50','event rsqgr_release 0','event rsqgr_release 1','wait 40','echo HANG']
    left=[1] if lv==0 else [0,1]
    if lv==1: s+=['echo REEL_RIGHT','event rsqgr_press 0','wait 20','event rsqgr_release 0','wait 30','echo REEL_DONE']
    if lv==2: s+=['echo TAP_RIGHT','event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 40']; left=[1]
    s+=['echo DROP']+['event rsqgr_press %d'%h for h in left]+['wait 2']+['event rsqgr_release %d'%h for h in left]+['wait 60']
elif mode=='scorpion':
    s+=['give RSQ_Glove','wait 5','use RSQ_Glove','wait 40','echo WEAPON','netevent gbp_weapon']
    s+=shot('noscorp_imp400',600,30,['netevent grv_sum 0 400'])
    s+=[up('Scorpion',1),'wait 40']
    s+=shot('scorp_imp400',600,30,['netevent grv_sum 0 400'])
    s+=[up('FastReel',4),'wait 40']
    s+=shot('scorp_fr4_imp400',600,30,['netevent grv_sum 0 400'])
    s+=shot('scorp_fr4_imp600',600,30,['netevent grv_sum 0 600'])
s+=['quit']
print('; '.join(s))
