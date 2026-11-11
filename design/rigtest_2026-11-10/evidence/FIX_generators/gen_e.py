# TEST ONLY (scratch, rig1110 FIX group): FXE (doom2 MAP01, RES 900): what slot 1 holds; the Wheel's glove cards
import sys; sys.path.insert(0, '/home/claude/rsq_ubqseries/design/rigtest_2026-11-10/evidence/P2_rig_scripts')
from lib import S
s = S()
s.add('set rsqml_gloves 1', 'wait 5', 'map MAP01', 'wait 30', 'vr_control_scheme 0', 'bd_tips 0', 'crosshair 0', 'screenblocks 10', 'notarget', 'buddha',
      'set ubqs_diag 4', 'set wr_debug 1', 'netevent p2_clearmon', 'qz_hmd "0 1.6 0 0 0 0"')
s.r(0.25, 1.30, -0.30, 30); s.l(-0.25, 1.30, -0.30, 30); s.w(20)
s.add('give Shot_Gun', 'use Shot_Gun'); s.w(50); s.add('netevent fx_inv 1', 'netevent fx_slots 1')
s.add('echo W_ADDSLOT', 'addslot 1 RSQ_Glove', 'addslot 1 RSQ_GloveOff'); s.w(5); s.add('netevent fx_slots 2')
s.add('echo W_MAIN_RING'); s.r(0.0, 1.50, -0.30, 0); s.w(5); s.add('netevent wr_toggle_main'); s.w(12); s.r(0.40, 1.00, -0.05, 0); s.w(35)
s.add('echo W_MAIN_CLOSE', 'netevent wr_toggle_main'); s.w(25); s.r(0.25, 1.30, -0.30, 30)
s.add('use UBQS_Saber'); s.w(70); s.add('netevent fx_inv 2')
s.add('echo W_OFF_RING'); s.l(0.0, 1.50, -0.30, 0); s.w(5); s.add('netevent wr_toggle_off'); s.w(12); s.l(-0.40, 1.00, -0.05, 0); s.w(35)
s.add('echo W_OFF_CLOSE', 'netevent wr_toggle_off'); s.w(20)
s.add('echo FXE_END', 'quit')
open(sys.argv[1], 'w').write(s.text())
