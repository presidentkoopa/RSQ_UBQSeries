# TEST ONLY (scratch, rig1110 FIX group): FXB (rig02, RES 120, no frames): the Force with Melee's gloves (item 4), Slappers
# Only vs the saber (item 1), the ShieldSaw's slanted shot (item 6). Logs only.
import sys; sys.path.insert(0, '/home/claude/rsq_ubqseries/design/rigtest_2026-11-10/evidence/P2_rig_scripts')
from lib import S
s = S()
REST_R = (0.25, 1.30, -0.30); REST_L = (-0.25, 1.30, -0.30)
def yank(tag):
    s.l(-0.25, 1.30, -0.55, -10); s.w(10); s.add('qz_ltrigger 1', '+oh_altatk'); s.w(10)
    for z in (-0.55, -0.46, -0.37, -0.28, -0.19): s.l(-0.25, 1.30, z, -10); s.w(1)
    s.w(2); s.add('netevent p2_force %d' % tag, 'qz_ltrigger 0', '-oh_altatk'); s.w(30); s.add('netevent p2_force %d' % (tag + 1)); s.l(*REST_L); s.w(10)
s.add('set rsqml_gloves 1', 'wait 5', 'map MAP01', 'wait 30', 'vr_control_scheme 0', 'bd_tips 0', 'crosshair 0', 'screenblocks 10', 'buddha',
      'set ubqs_diag 4', 'set ssq_debug 1', 'set rsqml_debug 1', 'set rsqml_slappers 0', 'qz_hmd "0 1.6 0 0 0 0"')
s.r(*REST_R); s.l(*REST_L); s.w(20)
s.add('netevent p2_clearmon', 'rsqml_gloves', 'netevent fx_inv 0', 'echo F4_ADD_ALL', 'netevent rsqgb_dbg_all'); s.w(60)
s.add('set ubqs_dual_mode 0', 'set ubqs_force 1'); s.w(10); s.add('netevent fx_inv 1')
# ---- item 4: the saber drawn with Melee's off glove in the off hand
s.add('echo F4_SABER_IN', 'use UBQS_Saber'); s.w(70); s.add('netevent fx_inv 2', 'netevent p2_item:Medikit 200 0'); s.w(5); s.add('netevent p2_force 0')
s.add('echo F4_YANK_FORCEHAND'); yank(1)
s.add('echo F4_GUN', 'give Shot_Gun', 'use Shot_Gun'); s.w(60); s.add('netevent fx_inv 3')
s.add('echo F4_SABER_AGAIN', 'use UBQS_Saber'); s.w(70); s.add('netevent fx_inv 4', 'echo F4_GLOVE_BESIDE_SABER', 'use RSQ_GloveOff'); s.w(40); s.add('netevent fx_inv 5')
s.add('netevent p2_item:Medikit 200 0'); s.w(5); s.add('netevent p2_force 10', 'echo F4_YANK_GLOVE'); yank(11)
# ---- item 1: Slappers Only on and off, the saber in the inventory counted every tic
s.add('echo F1_GUNS', 'give BrutalPistol', 'give Shot_Gun', 'give SSQ_ShieldSaw', 'use Shot_Gun'); s.w(60); s.add('netevent fx_inv 10')
s.add('echo F1_ON', 'set rsqml_slappers 1'); s.w(20); s.add('netevent fx_inv 11', 'netevent fx_watch 48 1'); s.w(50); s.add('netevent fx_inv 12')
s.add('echo F1_GIVE_LATER', 'give Shot_Gun'); s.w(14); s.add('netevent fx_inv 13')
s.add('echo F1_OFF', 'set rsqml_slappers 0'); s.w(70); s.add('netevent fx_inv 14', 'netevent fx_watch 30 2'); s.w(32)
# ---- item 6: the ShieldSaw's plate, a slanted hitscan through it
s.add('echo F6', 'netevent p2_tp -320 0 0', 'netevent p2_ssqset 1'); s.w(40); s.add('set ssq_hitscan_guard 0'); s.l(-0.05, 1.15, -0.30, 0, -90); s.w(20)
s.add('netevent p2_ssq 0', 'netevent p2_zm 50 0'); s.w(10); s.add('echo F6_NEAR_SLANT', 'netevent p2_hp 100', 'netevent p2_zshoot 0'); s.w(10); s.add('netevent p2_zclear')
s.add('netevent p2_zm 400 0'); s.w(10); s.add('echo F6_FAR_FROM_THE_STEP', 'netevent p2_hp 100', 'netevent p2_zshoot 0'); s.w(10); s.add('netevent p2_zclear')
s.add('echo F6_PLATE_ASIDE'); s.l(*REST_L); s.w(10); s.add('netevent p2_zm 50 0'); s.w(10); s.add('netevent p2_hp 100', 'netevent p2_zshoot 0'); s.w(10); s.add('netevent p2_zclear', 'set ssq_hitscan_guard 1')
s.add('echo FXB_END', 'wait 5', 'quit')
open(sys.argv[1], 'w').write(s.text())
