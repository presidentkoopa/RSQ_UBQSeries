# TEST ONLY: P2A launch (rig02, RES 120, no frames): X1 axe + grenade, H3, A2, A3, D2, D1.
import sys; sys.path.insert(0, '.')
from lib import S
s = S()
REST_R = (0.25, 1.30, -0.30); REST_L = (-0.25, 1.30, -0.30)
s.add('wait 20', 'vr_control_scheme 0', 'bd_tips 0', 'crosshair 0', 'screenblocks 10', 'god', 'set ssq_debug 1', 'set ubqs_diag 1',
      'set rsqsm_debug 1', 'set rsqdg_debug 1', 'set rsqdg_trace 1', 'set rsqdg_corpses 1', 'qz_hmd "0 1.6 0 0 0 0"')
s.r(*REST_R); s.l(*REST_L); s.w(20); s.add('netevent p2_clearmon', 'netevent p2_inv'); s.w(5)
# ---- X1 axe
s.add('echo X1_AXE', 'give BrutalAxe'); s.w(2); s.add('use BrutalAxe'); s.w(90); s.add('netevent p2_axe 0')
for tag, step in ((20, 0.057), (30, 0.086)):
    s.add('echo X1_AXE_%d' % tag); s.r(0.25, 1.35, -0.15); s.w(12); s.add('+attack'); s.w(10); s.swing('r', step); s.add('-attack'); s.w(4)
    s.add('netevent p2_axe %d' % tag); s.w(40); s.add('netevent p2_axe %d' % (tag + 1)); s.r(*REST_R); s.w(30)
# ---- X1 grenade
s.add('echo X1_NADE', 'give HandGrenades', 'give GrenadeAmmo 4'); s.w(2); s.add('use HandGrenades'); s.w(90); s.add('netevent p2_nade 0')
def pin(tag):
    s.r(0.25, 1.35, -0.15); s.l(0.25, 1.35, -0.15); s.w(6); s.add('qz_ltrigger 1'); s.w(4); s.l(0.0, 1.35, -0.15); s.w(4)
    s.add('qz_ltrigger 0'); s.l(*REST_L); s.w(6); s.add('netevent p2_nade %d' % tag)
s.add('echo X1_NADE_PIN1'); pin(1)
s.add('echo X1_NADE_20', '+attack'); s.w(10); s.swing('r', 0.057); s.add('-attack'); s.w(4); s.add('netevent p2_nade 20')
s.add('echo X1_NADE_COOKED_RELEASE', '+attack'); s.w(2); s.add('-attack'); s.w(3); s.add('netevent p2_nade 21'); s.w(80); s.add('netevent p2_nade 22')
s.add('echo X1_NADE_PIN2'); s.w(30); pin(2)
s.add('echo X1_NADE_30', '+attack'); s.w(10); s.swing('r', 0.086); s.add('-attack'); s.w(4); s.add('netevent p2_nade 30'); s.w(80); s.add('netevent p2_nade 31')
s.r(*REST_R); s.w(10)
# ---- H3 ShieldSaw: nothing in the map to lock
s.add('echo H3_SSQ', 'use UBQS_Saber', 'give SSQ_ShieldSaw'); s.w(5); s.add('ssq_draw'); s.w(60); s.add('netevent p2_ssq 0')
for tag, step in ((20, 0.057), (30, 0.086)):
    s.add('echo H3_SSQ_%d' % tag); s.l(-0.25, 1.35, -0.15); s.w(12); s.add('qz_ltrigger 1'); s.w(15); s.swing('l', step, x=-0.25); s.add('qz_ltrigger 0'); s.w(4)
    s.add('netevent p2_ssq %d' % tag); s.w(60); s.l(*REST_L); s.w(100 if tag == 30 else 30); s.add('netevent p2_ssq %d' % (tag + 1))
s.w(60); s.add('netevent p2_ssq 32', 'echo H3_PUTAWAY', 'ssq_draw'); s.w(40); s.add('netevent p2_ssq 33', 'netevent p2_lit 0')
# ---- A2 Force Pull refused, then shown working
s.add('echo A2', 'netevent p2_item:Medikit 200 0'); s.w(5); s.add('netevent p2_force 0')
def yank(tag):
    s.l(-0.25, 1.30, -0.55); s.w(10); s.add('qz_ltrigger 1', '+oh_altatk'); s.w(10)
    for z in (-0.55, -0.46, -0.37, -0.28, -0.19): s.l(-0.25, 1.30, z); s.w(1)
    s.w(2); s.add('netevent p2_force %d' % tag, 'qz_ltrigger 0', '-oh_altatk'); s.w(30); s.add('netevent p2_force %d' % (tag + 1)); s.l(*REST_L); s.w(10)
s.add('echo A2_NOT_FORCE_SENSITIVE'); yank(10)
s.add('echo A2_ADD_ALL', 'netevent rsqgb_dbg_all'); s.w(50); s.add('set ubqs_force 0'); s.w(40); s.add('netevent p2_force 19', 'netevent p2_lit 19')
s.add('echo A2_FORCE_OFF'); yank(20)
s.add('set ubqs_force 1', 'netevent p2_hp 50'); s.w(40); s.add('netevent p2_force 29', 'netevent p2_lit 29')
s.add('echo A2_CONTROL_FORCE_ON_LEARNED'); yank(30); s.w(30); s.add('netevent p2_force 32', 'netevent p2_items')
# ---- A3 training remote
s.add('echo A3', 'use UBQS_Saber'); s.w(20); s.add('netevent p2_hp 60', 'netevent ubqs_remote'); s.w(40)
for k in range(8): s.add('netevent p2_remote %d' % k); s.w(12)
for k in range(4): s.add('echo A3_HIT_%d' % (k + 1), 'netevent r10_remotehit'); s.w(30); s.add('netevent p2_remote %d' % (100 + k))
s.w(80); s.add('netevent p2_remote 110', 'netevent ubqs_remote'); s.w(20)
# ---- D2 Palm Gate off: counts only with Grab Keys on
s.add('echo D', 'give Shot_Gun'); s.w(2); s.add('use Shot_Gun'); s.w(90)
s.add('netevent p2_item:ExplosiveBarrel 160 0'); s.r(0.25, 1.30, -0.30, -11, -30, 0); s.w(10)
s.add('echo D2_PALMGATE_OFF_KEYS_OFF', 'set rsqdg_palm 0', 'set rsqdg_button 0'); s.w(40)
s.add('echo D2_PALMGATE_OFF_KEYS_ON', 'set rsqdg_button 1'); s.w(40)
s.add('echo D2_KEY_RELEASE', '+rsqdg_main'); s.w(3); s.add('-rsqdg_main'); s.w(20)
s.add('set rsqdg_button 0', 'set rsqdg_palm 1'); s.w(10)
s.add('echo D2_PALMGATE_ON_ROLL0'); s.w(30)
# ---- D1 heavy throw: a corpse, then the barrel
def dg_throw(tag):
    s.r(0.25, 1.30, -0.30, -11, -30, 90); s.w(30)
    s.r(0.25, 1.30, -0.30, 2, -30, 90); s.w(2); s.r(0.25, 1.30, -0.30, 15, -30, 90); s.w(2); s.r(0.25, 1.30, -0.30, 15, -30, 0); s.w(4)
    s.r(0.25, 1.30, -0.30, -11, -30, 90); s.w(50); s.add('qz_rgrip 1'); s.w(5); s.r(0.25, 1.30, -0.30, -11, -30, 0); s.w(5)
    for k in range(10): s.r(0.25, 1.25 + 0.01 * k, -0.30 + 0.025 * k, -11, -30, 0); s.w(1)
    for k in range(7):
        s.r(0.25, 1.35 + 0.03 * k, -0.05 - 0.30 * k, -11, -30, 0)
        if k == 4: s.add('qz_rgrip 0')
        s.w(1)
    s.r(0.25, 1.30, -0.40, -11, -30, 0); s.w(30); s.add('netevent p2_dgkg', 'netevent p2_items'); s.w(60); s.add('netevent p2_dgkg')
s.add('echo D1_CORPSE', 'netevent p2_move 1 -320 -380', 'netevent p2_item:ZombieMan 160 0'); s.w(10); s.add('netevent p2_kill 2'); s.w(70); s.add('netevent p2_items')
dg_throw(1)
s.add('echo D1_BARREL', 'netevent p2_move 1 -160 0'); s.w(20); s.add('netevent p2_items')
dg_throw(2)
s.add('echo P2A_END'); s.w(10); s.add('quit')
open(sys.argv[1], 'w').write(s.text())
print(len(s.c), 'commands')
