# TEST ONLY: P4 N2, Whip and Gun's cursor: red aim (out of reach) -> gold (ceiling) -> red -> gold -> red. Uses bindwhip's gen.py.
import sys; sys.path.insert(0,'/home/claude/scratch/bindwhip')
from gen import *
AIM=(0.20,1.40,-0.40,43,0)
s=S()
s.add('map SWINGTST','wait 40','god','notarget','qz_rhand '+P(REST),'qz_lhand "-0.200 1.300 -0.300 20.00 0.00 0"','wait 70','use RSQWP_WhipWeapon','wait 60','rsqwp_debug 5','whp_scen 11','whp_log 3','netevent whp_go','netevent whp_tp 378 512 0')
s.hold(REST,5)
s.add('echo N2_OFFGUN','netevent whp_offgun 0')
s.hold(REST,40)
for k in range(2):
    s.add('echo N2_TO_GOLD_%d'%k); s.path([(0,REST),(20,AIM)]); s.add('echo N2_GOLD_HOLD_%d'%k); s.hold(AIM,30)
    s.add('echo N2_TO_RED_%d'%k); s.path([(0,AIM),(20,REST)]); s.add('echo N2_RED_HOLD_%d'%k); s.hold(REST,40)
s.add('echo N2_SLOT1_ONLY','netevent whp_offgun 2'); s.hold(REST,30)
s.write('/home/claude/scratch/p4/N2',HEAD)
