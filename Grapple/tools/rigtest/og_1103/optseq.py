def w(name,pre):
    return pre+['qz_rhand "0.25 1.3 -0.3 50 0 0"','netevent grv_tp 1800 512 0','wait 6','echo SHOT_%s'%name,'event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 70']
def m(name,pre):
    return pre+['qz_rhand "0.25 1.3 -0.3 30 0 0"','netevent grv_tp 600 512 0','wait 3','netevent grv_sum 0 400','wait 3','echo SHOT_%s'%name,'event rsqgr_press 0','wait 2','event rsqgr_release 0','wait 70']
s=['wait 2','map GRV','wait 10','notarget','god','rsqgr_debug 1']
s+=w('rope_pull',['rsqgr_geo_mode 0'])+w('swing',['rsqgr_swing 1'])+w('swing_with_og_row',['rsqgr_geo_mode 1'])
s+=['rsqgr_swing 0']+m('slide',['rsqgr_monster_mode 0'])+m('yank',['rsqgr_monster_mode 1'])+m('lasso',['rsqgr_monster_mode 2'])+['rsqgr_reset','wait 2','rsqgr_debug 1']+w('reset_wall',[])+m('reset_monster',[])+['quit']
print('; '.join(s))
