# GBOVR: fire unlearned, learn Grapple + Get Over Here 3 (+ Bowling 2, Double Hook check later), OG-throw an imp from 400 (a zombieman in its path for Bowling), then Momentum: a wall shot swings
def shot(name, extra=[]):
    return ['qz_rhand "0.25 1.3 -0.3 30 0 0"','netevent grv_tp 600 512 0','wait 3']+extra+['wait 3','echo SHOT_%s'%name,'event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 80']
s=['wait 2','map GRV','wait 10','notarget','god','rsqgr_debug 1']
s+=shot('locked',['netevent grv_sum 0 400'])
s+=['netevent bonsai-debug,p-up,RSQ_Upgrade_Grapple 1','netevent bonsai-debug,p-up,RSQ_Upgrade_GetOverHere 3','wait 40']
s+=shot('goh_imp400',['netevent grv_sum 0 400'])
s+=['netevent bonsai-debug,p-up,RSQ_Upgrade_SwingMomentum 1','wait 40']
s+=['qz_rhand "0.25 1.3 -0.3 50 0 0"','netevent grv_tp 1800 512 0','wait 6','echo SHOT_momentum_wall','event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 60','quit']
print('; '.join(s))
