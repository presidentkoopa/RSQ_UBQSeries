import sys
# monster shots: summon ahead (class idx, dist), fire level at it
mode=sys.argv[1]
shots=[("imp200",0,200),("imp400",0,400),("imp600",0,600),("zombie300",1,300),("demon300",2,300)]
s=['wait 2','map GRV','wait 10','notarget','god']+sys.argv[2:]
for name,c,d in shots:
    s+=['qz_rhand "0.25 1.3 -0.3 30 0 0"','netevent grv_tp 600 512 0','wait 3','netevent grv_sum %d %d'%(c,d),'wait 3','echo SHOT_%s'%name]
    if mode=='og': s+=['netevent grv_og']
    else: s+=['event rsqgr_press 0','wait 2','event rsqgr_release 0']
    s+=['wait 80']
s+=['quit']
print('; '.join(s))
