import sys
# console script: shots in the GRV room. mode og = give HookShooter, ours = event rsqgr_press 0 (tap release after 2 tics)
mode=sys.argv[1]
shots=[("wall200",2200,30),("wall400",2000,30),("wall600",1800,30),("wall780",1620,30),
       ("up20_600",1800,50),("ceil60",1900,90),("floor25",1700,5),("miss1000",1400,30)]
s=['wait 2','map GRV','wait 10']+(sys.argv[2:] )
for name,x,p in shots:
    s+=['qz_rhand "0.25 1.3 -0.3 %d 0 0"'%p,'netevent grv_tp %d 512 0'%x,'wait 6','echo SHOT_%s'%name]
    if mode=='og': s+=['netevent grv_og']
    else: s+=['event rsqgr_press 0','wait 2','event rsqgr_release 0']
    s+=['wait 90']
s+=['quit']
print('; '.join(s))
