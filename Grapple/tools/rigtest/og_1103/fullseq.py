s=['wait 2','map GRV','wait 30','notarget','god','rsqgr_debug 1','netevent bonsai-debug,p-up,RSQ_Upgrade_Grapple 1','netevent bonsai-debug,p-up,RSQ_Upgrade_GetOverHere 1','wait 40',
   'qz_rhand "0.25 1.3 -0.3 30 0 0"','netevent grv_tp 1800 512 0','wait 6','echo SHOT_wall600','event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 70',
   'qz_rhand "0.25 1.3 -0.3 90 0 0"','netevent grv_tp 1900 512 0','wait 6','echo SHOT_ceil60','event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 90',
   'qz_rhand "0.25 1.3 -0.3 30 0 0"','netevent grv_tp 600 512 0','wait 3','netevent grv_sum 0 400','wait 3','echo SHOT_imp400','event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 80','quit']
print('; '.join(s))
