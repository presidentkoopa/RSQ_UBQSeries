# TEST ONLY: P2B launch (rig02, RES 480, frames): A1, N1, H1, H2, D3.
import sys; sys.path.insert(0, '.')
from lib import S
s = S()
REST_R = (0.25, 1.30, -0.30); REST_L = (-0.25, 1.30, -0.30)
s.add('wait 20', 'vr_control_scheme 0', 'bd_tips 0', 'crosshair 0', 'screenblocks 10', 'buddha', 'set ssq_debug 1', 'set ubqs_diag 1',
      'set rsqdg_debug 1', 'set rsqdg_trace 1', 'set rsqgc_debug_log 1', 'qz_hmd "0 1.6 0 0 0 0"')
s.r(*REST_R); s.l(*REST_L); s.w(20); s.add('netevent p2_clearmon', 'give SSQ_ShieldSaw'); s.w(5); s.add('netevent rsqgb_dbg_all'); s.w(60); s.add('netevent p2_inv')
# ---- A1 the second saber, drawn from its holster for the first time
s.add('echo A1', 'netevent p2_lit 1'); s.r(0.20, 1.30, -0.40); s.l(-0.20, 1.30, -0.40); s.w(10)
s.add('echo A1_DRAW', 'netevent ubqs_dual_out'); s.w(6); s.add('netevent p2_lit 2'); s.w(50); s.add('netevent p2_lit 3', 'echo A1_END')
s.add('netevent ubqs_dual_in'); s.w(30); s.add('netevent p2_lit 4')
# ---- N1 Gun Cards item cards on the watch
s.add('set rsqgc_watch 1', 'qz_hmd "0 1.6 0 -25 0 0"')
s.add('echo N1_SABER_LIT'); s.r(0.0, 1.45, -0.30, 0, 90, 0); s.w(60); s.add('netevent p2_lit 10')
s.add('echo N1_SABER_OFF', 'netevent ubqs_ignite'); s.w(50); s.add('netevent p2_lit 11')
s.add('netevent ubqs_ignite'); s.r(*REST_R); s.w(20); s.add('netevent p2_lit 12')
s.add('echo N1_FLARE', 'give RSQFF_Ammo 4', 'give RSQFF_Held'); s.w(2); s.add('use RSQFF_Held'); s.w(80); s.add('netevent p2_ff 1')
s.r(0.0, 1.45, -0.30, 0, 90, 0); s.w(60); s.add('netevent p2_ff 2', 'echo N1_FLARE_END'); s.r(*REST_R)
s.add('echo N1_TORCH', 'netevent rsqff_fl_take'); s.w(40); s.add('netevent p2_ff 3')
s.l(0.0, 1.45, -0.30, 0, -90, 0); s.w(60); s.add('netevent p2_ff 4', 'echo N1_TORCH_END'); s.l(*REST_L); s.add('netevent rsqff_fl_back'); s.w(30); s.add('netevent p2_ff 5')
s.add('qz_hmd "0 1.6 0 0 0 0"', 'use UBQS_Saber'); s.w(40)
# ---- H1 ricochet: A on the raised floor (the disc's line to it meets the step face), B on the low floor, C spawned at the throw
s.add('echo H1', 'netevent p2_ssqset 1'); s.w(60); s.add('netevent p2_ssq 0', 'netevent p2_off 0'); s.add('netevent p2_xyit:DoomImp 200 40 1', 'netevent p2_xyit:DoomImp -40 -150 1'); s.w(30); s.add('netevent p2_items')
s.l(-0.25, 1.20, -0.35, 12, 4, 0); s.w(10); s.add('echo H1_PAINT', 'qz_ltrigger 1'); s.w(12); s.add('netevent p2_ssq 1')
s.l(-0.25, 1.20, -0.35, -2, -28, 0); s.w(12); s.add('netevent p2_ssq 2'); s.l(-0.25, 1.20, -0.35, 0, 30, 0); s.w(9); s.l(-0.25, 1.20, -0.35, 12, 4, 0); s.w(3); s.add('netevent p2_ssq 3')
s.add('set rsqa_onehand 1'); s.w(2)
s.add('echo H1_THROW', 'netevent p2_xyit:DoomImp -150 120 1', 'netevent rsqa_alt 6 1'); s.w(1); s.add('netevent rsqa_alt 6 0', 'qz_ltrigger 0', 'set rsqa_onehand 0')
s.w(240); s.add('netevent p2_ssq 4', 'netevent p2_items', 'echo H1_END', 'netevent p2_ssqset 1'); s.w(120); s.add('netevent p2_ssqset 1'); s.w(60); s.add('netevent p2_ssq 5')
# ---- H2 a far zombieman's bullet on the plate (muzzle block off, then on), and a near one
s.add('echo H2', 'netevent p2_clearmon', 'set ssq_hitscan_guard 0', 'netevent p2_zm:400 0'); s.w(20)
for i, pose in enumerate([(-0.05, 1.15, -0.30, 0, -90, 0), (-0.05, 1.15, -0.30, 0, 90, 0), (-0.05, 1.20, -0.30, 90, 0, 0), (-0.10, 1.10, -0.35, 0, 0, 0)]):
    s.add('echo H2_FAR_POSE_%d' % i); s.l(*pose); s.w(15); s.add('netevent p2_hp 100', 'netevent p2_zshoot'); s.w(10)
s.add('echo H2_FAR_MUZZLE_ON', 'set ssq_hitscan_guard 1'); s.w(5); s.add('netevent p2_zshoot'); s.w(10); s.add('set ssq_hitscan_guard 0', 'netevent p2_zclear', 'netevent p2_zm:60 0'); s.w(20)
for i, pose in enumerate([(-0.05, 1.15, -0.30, 0, -90, 0), (-0.05, 1.20, -0.30, 90, 0, 0)]):
    s.add('echo H2_NEAR_POSE_%d' % i); s.l(*pose); s.w(15); s.add('netevent p2_hp 100', 'netevent p2_zshoot'); s.w(10)
s.add('netevent p2_zclear', 'set ssq_hitscan_guard 1'); s.l(*REST_L); s.w(5); s.add('netevent p2_ssqset 0'); s.w(40)
# ---- D3 a full gun you carry, pulled
s.add('echo D3', 'netevent p2_clearfloor', 'give Shot_Gun'); s.w(2); s.add('use Shot_Gun', 'give ammo'); s.w(90); s.add('netevent p2_inv', 'netevent p2_vani:Shot_Gun 160 0'); s.w(5); s.add('netevent p2_items')
s.r(0.25, 1.30, -0.30, -11, -30, 90); s.w(30)
s.r(0.25, 1.30, -0.30, 2, -30, 90); s.w(2); s.r(0.25, 1.30, -0.30, 15, -30, 90); s.w(2); s.r(0.25, 1.30, -0.30, 15, -30, 0); s.w(4)
s.add('echo D3_CATCH'); s.r(0.25, 1.30, -0.30, -11, -30, 90); s.w(25); s.add('qz_hmd "0 1.6 0 -40 0 0"'); s.w(40); s.add('netevent p2_items', 'echo D3_END'); s.w(20)
s.add('echo P2B_END'); s.w(5); s.add('quit')
open(sys.argv[1], 'w').write(s.text())
print(len(s.c), 'commands')
