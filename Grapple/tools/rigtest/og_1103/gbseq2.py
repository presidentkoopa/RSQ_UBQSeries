# GBOVR Bowling 2 (an imp OG-thrown from 400 through a zombieman at 200) and Double Hook 2 (two imps, one per hand, within 16 tics)
s=['wait 2','map GRV','wait 10','notarget','god','rsqgr_debug 1',
   'netevent bonsai-debug,p-up,RSQ_Upgrade_Grapple 1','netevent bonsai-debug,p-up,RSQ_Upgrade_Bowling 2','netevent bonsai-debug,p-up,RSQ_Upgrade_HeavyHaul 2','netevent bonsai-debug,p-up,RSQ_Upgrade_DoubleHook 2','wait 40',
   'qz_rhand "0.25 1.3 -0.3 30 0 0"','netevent grv_tp 600 512 0','wait 3','netevent grv_sum 0 400','netevent grv_sumk 1 200 30','wait 3','echo SHOT_bowling','event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 80',
   'netevent grv_tp 600 512 0','wait 3','netevent grv_sum 0 300 -112','netevent grv_sumk 0 300 112',
   'qz_rhand "0.25 1.3 -0.3 30 -19.6 0"','qz_lhand "-0.25 1.3 -0.3 30 19.6 0"','wait 3','echo SHOT_double','event rsqgr_press 0','event rsqgr_press 1','wait 2','event rsqgr_release 0','event rsqgr_release 1','wait 80','quit']
print('; '.join(s))
