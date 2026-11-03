import sys
mode=sys.argv[1]
# a cacodemon floating 120 up at 350 (hand aimed up at its middle), a cyberdemon at 400 (too heavy: an anchor)
shots=[("caco_up120",4,350,120,49),("cyber400",3,400,0,30)]
s=['wait 2','map GRV','wait 10','notarget','god']+sys.argv[2:]
for name,c,d,z,p in shots:
    s+=['qz_rhand "0.25 1.3 -0.3 %d 0 0"'%p,'netevent grv_tp 600 512 0','wait 3','netevent grv_sum %d %d %d'%(c,d,z),'wait 3','echo SHOT_%s'%name]
    if mode=='og': s+=['netevent grv_og']
    else: s+=['event rsqgr_press 0','wait 2','event rsqgr_release 0']
    s+=['wait 80']
s+=['quit']
print('; '.join(s))
