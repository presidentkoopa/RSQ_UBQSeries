# mid-climb and mid-swing save/load twice, then death, then map change
L=lambda y: 'qz_lhand "-0.05 %.2f -0.15 30 0 0"'%y
s=['wait 2','map GRTEST','wait 10','netevent grp_tp 300 512 0','use Fist','rsqgr_debug 1','qz_rhand "0.25 1.3 -0.1 120 0 0"','wait 8',
   'event rsqgr_press 0','wait 14','event rsqgr_release 0','wait 30',
   L(1.75),'wait 3','event rsqgr_grip 1','wait 2',L(1.6),'wait 1',L(1.45),'wait 1','echo SAVE1','save grcl1','wait 1',L(1.3),'wait 1',L(1.15),'wait 6',
   'echo LOAD1','load grcl1','wait 6','echo AFTER1',L(1.75),'wait 3','event rsqgr_grip 1','wait 2',L(1.45),'wait 1',L(1.15),'wait 6',
   'echo LOAD2','load grcl1','wait 6','echo AFTER2','event rsqgr_ungrip 1','wait 4','qz_lstick "1 0"','wait 20','qz_lstick "0 0"','echo SAVE2','save grcl2','wait 10','echo LOAD3','load grcl2','wait 10','echo LOAD4','load grcl2','wait 10',
   'echo DIE','netevent grp_hurt','wait 10','echo MAP','map MAP01','wait 20','quit']
print('; '.join(s))
