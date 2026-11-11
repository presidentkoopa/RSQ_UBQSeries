# TEST ONLY: P4 run B (MAP01, full order + M8F laser-sight + p4 probe): L2 again (gun level), L4 on a wall, L5 readout, T1 clean
def H(y,p=0,yaw=0): return 'qz_hmd "0 %.2f 0 %d %d 0"'%(y,p,yaw)
c=[H(1.60),'qz_rhand "0.25 1.3 -0.3 30 0 0"','qz_lhand "-0.25 1.3 -0.3 30 0 0"','wait 20','vr_control_scheme 0','vr_secondary_button_mappings 0','bd_tips 0','crosshair 0','screenblocks 10','god','notarget','give ammo',
   'set rsqtr_tip_holster 1','set rsqtr_tip_recentre 1','set rsqtr_eye_m 1.62',
   'give BrutalPistol','use BrutalPistol','wait 150','netevent p4_log 1',
   'qz_rhand "0.20 1.35 -0.35 28 -10 0"','wait 20',
   'echo P4_L2_WHICH_RSQ','set rsqls_which 0','wait 40',
   'echo P4_L2_WHICH_M8F','set rsqls_which 1','wait 40',
   'echo P4_L2_WHICH_RSQ_AGAIN','set rsqls_which 0','wait 40',
   'echo P4_L4_WALL','qz_rhand "0.20 1.35 -0.35 24 -60 0"','wait 30',
   'echo P4_L4_GLOW1','set rsqls_glow_int 1','wait 40','echo P4_L4_GLOW3','set rsqls_glow_int 3','wait 40','echo P4_L4_GLOW1_AGAIN','set rsqls_glow_int 1','wait 30',
   'echo P4_L5_GUN','set rsqls_readout 1','set rsqls_readout_units 2','qz_rhand "0.20 1.40 -0.35 60 -25 0"','wait 50',
   'echo P4_L5_DOT','set rsqls_readout 2','wait 50','set rsqls_readout 0','netevent p4_log 0',
   # T1
   'set rsqtr_messages 1','netevent p4_log 4',H(1.60,-62),
   'echo P4_T1_GUN_HIP','qz_rhand "0.18 0.92 0.00 30 0 0"','qz_lhand "-0.18 0.92 0.00 30 0 0"','wait 45',
   'echo P4_T1_GUN_CHEST','qz_rhand "0.13 1.12 -0.09 30 0 0"','wait 45',
   'echo P4_T1_HOLSTER','qz_rhand "0.18 0.92 0.00 30 0 0"','wait 15','qz_rgrip 1','wait 30','qz_rgrip 0','wait 10',
   'echo P4_T1_EMPTY_RIGHT_HIP','wait 45',
   'echo P4_T1_EMPTY_CHEST','qz_rhand "0.13 1.12 -0.09 30 0 0"','wait 45',
   'echo P4_T1_EMPTY_AWAY','qz_rhand "0.25 1.3 -0.3 30 0 0"','qz_lhand "-0.25 1.3 -0.3 30 0 0"','wait 30','netevent p4_log 0',
   'echo P4_END','wait 5','quit']
open('B/script.txt','w').write('; '.join(c))
