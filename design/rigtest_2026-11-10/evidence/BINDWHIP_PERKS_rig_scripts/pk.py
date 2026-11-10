from gen import *
import sys
grant = sys.argv[1]=='on'
AIM=(0.20,1.40,-0.40,43,0)
s=S()
s.add('map SWINGTST','wait 40','god','notarget','qz_rhand '+P(REST),'qz_lhand "-0.200 1.300 -0.300 20.00 0.00 0"','wait 70','use RSQWP_WhipWeapon','wait 60','rsqwp_debug 1','whp_scen 11','whp_log 1','netevent whp_go','netevent whp_tp 378 512 0')
if grant: s.add('echo PK_GRANT','netevent rsqgb_dbg_all')
s.hold(REST,5)
s.add('echo PK_OFFGUN','netevent whp_offgun 0'); s.hold(REST,40)
s.add('echo PK_POINT'); s.hold(AIM,25)
s.add('echo PK_CRACK'); s.crack(AIM)
s.add('echo PK_REEL','+attack'); s.hold(REST,16); s.add('-attack','echo PK_REEL_END'); s.hold(REST,4)
s.add('echo PK_JUMP','+jump'); s.hold(REST,2); s.add('-jump')
s.hold(REST,90)
s.add('echo PK_LETGO','+altattack'); s.hold(REST,2); s.add('-altattack')
s.hold(REST,20)
s.write('PK_'+sys.argv[1],HEAD)
