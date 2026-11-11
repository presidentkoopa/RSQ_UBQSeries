# TEST ONLY: P2F launch (rig02, RES 480, frames): N1 views, H1 (ShieldSaw Ricochet fix), D3 (Distance Grab fix).
import sys; sys.path.insert(0, '.')
from lib import S
s = S()
REST_R = (0.25, 1.30, -0.30); REST_L = (-0.25, 1.30, -0.30)
s.add('wait 20', 'vr_control_scheme 0', 'bd_tips 0', 'crosshair 0', 'screenblocks 10', 'buddha', 'set ssq_debug 1',
      'set rsqdg_debug 1', 'set rsqdg_trace 1', 'set rsqgc_debug_log 1', 'set rsqgc_watch 1', 'qz_hmd "0 1.6 0 0 0 0"')
s.r(*REST_R); s.l(*REST_L); s.w(20); s.add('netevent p2_clearmon', 'give SSQ_ShieldSaw'); s.w(5); s.add('netevent rsqgb_dbg_all'); s.w(40)
s.add('use UBQS_Saber'); s.w(60); s.add('netevent p2_off 0', 'qz_hmd "0 1.6 0 -30 0 0"')
RV = [(0.0, 1.45, -0.30, 0, 0, -60), (-0.05, 1.40, -0.35, -20, -20, -60), (0.05, 1.45, -0.40, 0, 30, -80)]
LV = [(0.0, 1.45, -0.30, 0, 0, 60), (0.05, 1.40, -0.35, -20, 20, 60), (-0.05, 1.45, -0.40, 0, -30, 80)]
for st in ('LIT', 'OFF'):
    if st == 'OFF': s.add('netevent ubqs_ignite'); s.w(10)
    for i, v in enumerate(RV): s.add('echo N1_SABER_%s_V%d' % (st, i)); s.r(*v); s.w(30); s.add('netevent p2_lit %d' % i)
s.add('netevent ubqs_ignite'); s.r(*REST_R); s.w(10)
s.add('give RSQFF_Ammo 4', 'netevent rsqff_take'); s.w(40); s.add('netevent p2_ff 1')
for i, v in enumerate(LV): s.add('echo N1_FLARE_V%d' % i); s.l(*v); s.w(30); s.add('netevent p2_ff %d' % (10 + i))
s.l(*REST_L); s.w(5); s.add('netevent rsqff_back'); s.w(30); s.add('netevent rsqff_fl_take'); s.w(40)
for i, v in enumerate(LV): s.add('echo N1_TORCH_V%d' % i); s.l(*v); s.w(30); s.add('netevent p2_ff %d' % (20 + i))
s.l(*REST_L); s.w(5); s.add('netevent rsqff_fl_back'); s.w(30); s.add('qz_hmd "0 1.6 0 0 0 0"', 'echo N1_END')
# ---- H1 (as P2D, with the Ricochet fix)
s.add('echo H1', 'netevent p2_tp -320 0 0', 'netevent p2_ssqset 1'); s.w(60); s.add('netevent p2_off 20', 'netevent p2_ssq 0')
s.add('netevent p2_xyit:DoomImp -60 150 1', 'netevent p2_xyit:DoomImp -40 -150 1'); s.w(30); s.add('netevent p2_items')
s.l(-0.25, 1.20, -0.35, 28, 29, 0); s.w(4); s.add('echo H1_PAINT', 'qz_ltrigger 1'); s.w(12); s.add('netevent p2_ssq 1')
s.l(-0.25, 1.20, -0.35, 28, -30, 0); s.w(12); s.add('netevent p2_ssq 2'); s.l(-0.25, 1.20, -0.35, 28, 0, 0); s.w(4); s.add('netevent p2_ssq 3', 'set rsqa_onehand 1'); s.w(2)
s.add('echo H1_THROW', 'netevent p2_move 0 -60 330', 'netevent p2_xyit:DoomImp -200 100 1', 'netevent rsqa_alt 6 1'); s.w(1); s.add('netevent rsqa_alt 6 0', 'qz_ltrigger 0', 'set rsqa_onehand 0')
s.w(60); s.add('echo H1_A_BACK_IN_VIEW', 'netevent p2_move 0 -60 150'); s.w(90); s.add('netevent p2_ssq 4', 'netevent p2_items', 'echo H1_END'); s.w(150)
s.add('netevent p2_ssqset 0'); s.w(60); s.add('netevent p2_ssqset 0'); s.w(30)
# ---- D3 (Distance Grab fix), two tries at the flick
s.add('echo D3', 'netevent p2_clearmon', 'netevent p2_clearfloor', 'netevent p2_tp -320 0 0', 'give Shot_Gun'); s.w(2); s.add('use Shot_Gun', 'give ammo'); s.w(90)
s.add('netevent p2_off 30', 'netevent p2_vani:Shot_Gun 160 0'); s.w(5); s.add('netevent p2_items')
for k in range(2):
    s.add('echo D3_TRY_%d' % k); s.r(0.25, 1.30, -0.30, -11, -30, 90); s.w(30)
    s.r(0.25, 1.30, -0.30, 2, -30, 90); s.w(2); s.r(0.25, 1.30, -0.30, 15, -30, 90); s.w(2); s.r(0.25, 1.30, -0.30, 15, -30, 0); s.w(4)
    s.add('qz_hmd "0 1.6 0 -40 0 0"'); s.r(0.25, 1.30, -0.30, -11, -30, 90); s.w(60); s.add('netevent p2_items', 'qz_hmd "0 1.6 0 0 0 0"'); s.r(0.25, 1.30, -0.30, -11, -30, 0); s.w(30)
s.add('netevent p2_inv', 'echo P2F_END'); s.w(5); s.add('quit')
open(sys.argv[1], 'w').write(s.text()); print(len(s.c), 'commands')
