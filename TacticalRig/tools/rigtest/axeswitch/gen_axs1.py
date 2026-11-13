# TEST ONLY: run axs1 (2026-11-12), the one combined run of the batch: BD22 VR Reloaded 2.0.4s's axe count (never 0 with
# an axe in a hand; every display reads the count), Distance Grab always switching the grabbing hand to the axe
# (neverswitchonpickup 1, as the owner's ini), walking over an axe following Doom's own pickup rule (neverswitch 1 / 0).
import sys; sys.path.insert(0, '.'); from lib import *
s = S()
s.add('wait 40', 'vr_control_scheme 0', 'vr_secondary_button_mappings 0', 'set rsqtr_messages 1', 'set rsqdg_trace 1', 'set rsqdg_debug 1',
      'set rsq_switch_log 1', 'qz_hmd "0 1.6 0 0 0 0"', REST_R, REST_L, 'netevent as_tp -320 0 0', 'netevent as_clear',
      'god', 'notarget', 'set wr_debug 1', 'set neverswitchonpickup 1', 'set rsqgc_debug_log 1', 'set rsqgc_watch 2')
TP = 'netevent as_tp -320 0 0'
def mark(t, tag): s.add('echo %s' % t, 'netevent as_sum %d' % tag)
def walk_over():
    s.add(TP); s.w(3); s.add('netevent as_spawn:BrutalAxe 64 0'); s.w(3); s.add('netevent as_push 12'); s.w(45); s.add('netevent as_floor')
def throw_both(step=0.086):
    s.add('qz_rhand "0.25 1.35 -0.15 30 0 0"', 'qz_lhand "-0.25 1.35 -0.15 30 0 0"'); s.w(12); s.add('+attack', '+oh_attack'); s.w(10)
    for k in range(7):
        s.add('qz_rhand "0.25 1.35 %.3f 30 0 0"' % (-0.15 - step * k), 'qz_lhand "-0.25 1.35 %.3f 30 0 0"' % (-0.15 - step * k)); s.w(1)
    s.add('-attack', '-oh_attack'); s.w(4); s.add(REST_R, REST_L); s.w(60)
# ---- W: walking over an axe, neverswitchonpickup 1: no switch, the count +1
s.add('give Shot_Gun', 'give MP40'); s.w(5); s.add('use Shot_Gun'); s.w(60)
mark('W1_WALK_OVER_NEVERSWITCH1_COUNT0', 1); walk_over()
mark('W2_WALK_OVER_NEVERSWITCH1_COUNT1', 2); walk_over()
s.add('netevent as_delfloor')
# ---- D: Distance Grab always switches the grabbing hand to the axe (neverswitchonpickup 1)
mark('D1_DG_MAIN_HOLDS_SHOTGUN_PULLS_AN_AXE', 3); s.add(TP); s.w(3); s.add('netevent as_spawn:BrutalAxe 160 0'); s.w(5); s.pull('r'); s.w(20)
s.add('netevent wr_test_pick:MP40 1'); s.w(45)
mark('D2_DG_OFF_HOLDS_MP40_PULLS_AN_AXE', 4); s.add(TP); s.w(3); s.add('netevent as_spawn:BrutalAxe 160 0'); s.w(5); s.pull('l'); s.w(20)
s.add('use Shot_Gun'); s.w(45)
mark('D3_WALKUP_GRIP_MAIN_HOLDS_SHOTGUN', 5); s.add(TP, 'qz_rhand "0.25 0.25 -0.45 30 0 0"'); s.w(12); s.add('netevent as_atpalm 0'); s.w(3)
s.add('qz_rgrip 1'); s.w(6); s.add('qz_rgrip 0'); s.w(6); s.add(REST_R); s.w(40); s.add('netevent as_floor', 'netevent as_delfloor')
# ---- T: the count through throws to empty, grab-backs, both hands
s.add('netevent as_axes 2', 'use BrutalAxe'); s.w(40); s.add('netevent wr_test_pick:BrutalAxe 1'); s.w(45)
mark('T1_COUNT2_BOTH_HOLD_MAIN_THROWS_MAIN_EMPTY_OFF_KEEPS', 10); s.throw_main(); s.add('netevent as_delfloor')
mark('T2_WHEEL_AXE_INTO_MAIN_WHILE_OFF_HOLDS_THE_LAST_ONE_IT_MOVES', 11); s.add('netevent wr_test_pick:BrutalAxe 0'); s.w(45)
mark('T3_MAIN_THROWS_THE_LAST_AXE', 12); s.throw_main(); s.w(10); s.add('netevent as_floor')
mark('T3B_GRAB_IT_BACK_INTO_THE_EMPTY_MAIN', 13); s.add('netevent as_put 160 0'); s.w(3); s.pull('r'); s.w(20)
s.add('netevent as_delfloor', 'netevent as_axes 3'); s.w(3); s.add('netevent wr_test_pick:BrutalAxe 1'); s.w(45)
mark('T4_COUNT3_OFF_THROWS_REARMS', 14); s.throw_off(); s.add('netevent as_delfloor')
mark('T4B_COUNT2_MAIN_THROWS_EMPTY', 15); s.throw_main(); s.add('netevent as_delfloor')
mark('T4C_COUNT1_OFF_THROWS_THE_LAST', 16); s.throw_off(); s.add('netevent as_delfloor')
s.add('netevent as_axes 3', 'use BrutalAxe'); s.w(40); s.add('netevent wr_test_pick:BrutalAxe 1'); s.w(45)
mark('T5_COUNT3_BOTH_THROW_THE_SAME_TIC', 17); throw_both(); s.add('netevent as_delfloor')
s.add('netevent as_axes 2'); s.w(3); s.add('use BrutalAxe'); s.w(40); s.add('netevent wr_test_pick:BrutalAxe 1'); s.w(45)
mark('T6_COUNT2_BOTH_THROW_THE_SAME_TIC', 18); throw_both(); s.w(10); s.add('netevent as_floor')
mark('T6B_GRAB_BOTH_BACK_OFF_THEN_MAIN', 19); s.add('netevent as_put 160 0'); s.w(3); s.pull('l'); s.w(20); s.add('netevent as_put 160 0'); s.w(3); s.pull('r'); s.w(20)
s.add('netevent as_delfloor')
mark('T7_A_SAVED_AXE_WITH_NO_AMMO1', 20); s.add('use BrutalAxe'); s.w(40); s.add('netevent as_nullammo'); s.w(10)
mark('T8_MAIN_FIST_OFF_AXE_BD_HUD', 21); s.add('use Melee_Attacks'); s.w(40); s.add('netevent wr_test_pick:BrutalAxe 1'); s.w(45)
mark('T9_COUNT_SET_TO_1_BOTH_HOLD', 22); s.add('use BrutalAxe'); s.w(40); s.add('netevent as_axes 1'); s.w(20)
mark('T10_COUNT_SET_TO_0', 23); s.add('netevent as_axes 0'); s.w(30)
# ---- C: walking over with neverswitchonpickup 0: Doom's own rule (a new weapon is switched to; an owned one is ammo)
s.add('use Shot_Gun'); s.w(45); s.add('set neverswitchonpickup 0'); s.w(5)
mark('C1_WALK_OVER_NEVERSWITCH0_COUNT0', 30); walk_over()
s.add('use Shot_Gun'); s.w(45)
mark('C2_WALK_OVER_NEVERSWITCH0_COUNT1_OWNED', 31); walk_over()
s.add('set neverswitchonpickup 1')
mark('END', 40)
print(s.text())
