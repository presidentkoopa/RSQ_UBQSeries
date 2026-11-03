#!/usr/bin/env python3
# TEST ONLY. Writes the 11-03 rule A/B scenario scripts (trc_scriptX1..X3, R, S, L) for trc_run.sh.
# X<state>: for the cigarette in the hand (1), in the mouth unlit (2), lit (3): each of seven switches / holsters, with a
# trc_rep line before (odd number) and after (even number). The switch keys are the owner's layout (B weapnext, Y
# "weapnext 1"), pressed as the controller's buttons. R: the whole ritual. S: the stray-cigarette repro.
import os
HERE = os.path.dirname(os.path.abspath(__file__))
REST_R = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'
REST_L = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
SETUP = ('wait 40; bind pad_a +use; bind pad_b weapnext; bind pad_y "weapnext 1"; vr_secondary_button_mappings 0; set rsqtr_cig 1; set rsqtr_messages 1; '
         'set rsqtr_cig_count 20; set rsqtr_cig_smoke 5; %s; %s; give shotgun; give chaingun; give RSQTR_CigPack 30; wait 5; use Shotgun; wait 30; '
         'switchhand 1; wait 40; echo TRC_SETUP_DONE; set trc_rep 99; wait 2; ' % (REST_R, REST_L))
TAKE = 'qz_rhand "-0.16 1.20 -0.12 30 0 0"; wait 12; +use; wait 3; -use; wait 12; %s; wait 30; ' % REST_R
MOUTH = 'qz_rhand "0.02 1.44 -0.10 70 40 30"; wait 8; +use; wait 3; -use; wait 15; %s; wait 30; ' % REST_R
LIGHT = ('+oh_attack; wait 3; -oh_attack; wait 20; qz_lhand "-0.05 1.45 -0.15 40 -30 10"; wait 20; +use; wait 3; -use; '
         'wait 10; %s; wait 10; ' % REST_L)
ACTIONS = [
    ('MAIN_SWITCH_KEY_B', 'qz_rbuttons 2; wait 2; qz_rbuttons 0; '),
    ('OFF_SWITCH_KEY_Y', 'qz_lbuttons 512; wait 2; qz_lbuttons 0; '),
    ('SWITCHHAND_1', 'switchhand 1; '),
    ('SWITCHHAND_0', 'switchhand 0; '),
    ('MAIN_HOLSTER', 'qz_rhand "0.18 0.86 0.0 30 0 0"; wait 10; qz_rgrip 1; wait 5; qz_rgrip 0; wait 5; %s; ' % REST_R),
    ('OFF_HOLSTER', 'qz_lhand "-0.18 0.86 0.0 30 0 0"; wait 10; qz_lgrip 1; wait 5; qz_lgrip 0; wait 5; %s; ' % REST_L),
    ('OTHER_MOD_TAKES_OFF', 'set trc_steal 1; '),
]
STATES = [('HAND', TAKE), ('MOUTH', TAKE + MOUTH), ('LIT', TAKE + MOUTH + LIGHT)]

def write(name, body):
    with open(os.path.join(HERE, 'trc_script%s.txt' % name), 'w') as f: f.write(body + 'wait 20; quit\n')

for si, (sn, get) in enumerate(STATES, 1):
    b = SETUP
    for ai, (an, act) in enumerate(ACTIONS):
        k = si * 100 + ai * 2 + 1
        b += 'echo TRC_%s_%s; %sset trc_rep %d; wait 2; %swait 45; set trc_rep %d; wait 20; ' % (sn, an, get, k, act, k + 1)
    write('X%d' % si, b)

# R: the whole ritual, smoke 2 s, ends with the flick from the mouth (and SlowMo's pulse when AFTER loads it)
write('R', SETUP.replace('set rsqtr_cig_smoke 5', 'set rsqtr_cig_smoke 2') + 'echo TRC_R_TAKE; ' + TAKE + 'set trc_rep 1; wait 2; echo TRC_R_MOUTH; ' + MOUTH
      + 'set trc_rep 2; wait 2; echo TRC_R_LIGHT; ' + LIGHT + 'set trc_rep 3; wait 2; wait 80; echo TRC_R_AFTER_FLICK; set trc_rep 4; wait 2; netevent rsm_state; '
      + 'echo TRC_R_FLICK_FROM_HAND; ' + TAKE + 'qz_rhand "0.30 1.1 -0.45 30 0 0"; wait 8; +use; wait 3; -use; wait 40; set trc_rep 5; wait 2; '
      + 'echo TRC_R_POCKET; ' + TAKE + 'qz_rhand "-0.16 1.20 -0.12 30 0 0"; wait 12; qz_rgrip 1; wait 4; qz_rgrip 0; wait 10; %s; wait 40; set trc_rep 6; wait 2; ' % REST_R
      + 'echo TRC_R_UNMOUTH; ' + TAKE + MOUTH + 'qz_rhand "0.02 1.44 -0.10 70 40 30"; wait 12; qz_rgrip 1; wait 4; qz_rgrip 0; wait 10; %s; wait 30; set trc_rep 7; wait 2; ' % REST_R
      + 'qz_rhand "0.30 1.1 -0.45 30 0 0"; wait 8; +use; wait 3; -use; wait 40; set trc_rep 8; wait 2; '
      + 'echo TRC_R_CIGS_OFF_LIT; ' + TAKE + MOUTH + LIGHT + 'set rsqtr_cig 0; wait 30; set trc_rep 9; wait 2; set rsqtr_cig 1; wait 10; '
      + 'echo TRC_R_LEVEL_CHANGE_MOUTH; ' + TAKE + MOUTH + 'set trc_rep 10; wait 2; set trc_next 1; wait 80; set trc_rep 11; wait 2; '
      + 'echo TRC_R_DEATH_HAND; ' + TAKE + 'kill; wait 40; set trc_rep 12; wait 2; ')

# S: the stray cigarette. S1 a fast swing with a grip, the cigarette in the hand (the rig's gun throw); S2 switchhand 1
# with it in the hand; S3 switchhand 0 (the Zippo); S4 the main grip at the right hip with it in the hand, then a new
# cigarette and the same holster again; S5 weapnext in the mouth (before: the Zippo stays).
FAST = 'qz_rhand "0.25 1.3 -0.3 30 0 0"; wait 10; qz_rhand "0.30 1.3 -0.75 30 0 0"; qz_rgrip 1; wait 1; qz_rhand "0.32 1.3 -0.80 30 0 0"; wait 3; qz_rgrip 0; wait 10; %s; ' % REST_R
POCKET = 'qz_rhand "-0.16 1.20 -0.12 30 0 0"; wait 12; qz_rgrip 1; wait 4; qz_rgrip 0; wait 10; %s; wait 30; ' % REST_R
HIP = 'qz_rhand "0.18 0.86 0.0 30 0 0"; wait 10; qz_rgrip 1; wait 5; qz_rgrip 0; wait 5; %s; ' % REST_R
write('S', SETUP + 'set rsqtr_debug_throw 0; echo TRC_S1_FAST_GRIP_SWING_IN_HAND; ' + TAKE + 'set trc_rep 1; wait 2; ' + FAST + 'wait 60; set trc_rep 2; wait 2; ' + POCKET
      + 'echo TRC_S2_SWITCHHAND1_IN_HAND; ' + TAKE + 'switchhand 1; wait 4; set trc_rep 3; wait 60; set trc_rep 4; wait 2; '
      + 'echo TRC_S3_SWITCHHAND0_ZIPPO; ' + TAKE + 'switchhand 0; wait 4; set trc_rep 5; wait 60; set trc_rep 6; wait 2; '
      + 'echo TRC_S4_HIP_GRIP_IN_HAND; ' + TAKE + HIP + 'wait 40; set trc_rep 7; wait 2; ' + TAKE + HIP + 'wait 40; set trc_rep 8; wait 2; '
      + 'echo TRC_S5_WEAPNEXT_IN_MOUTH; ' + TAKE + MOUTH + 'weapnext; wait 80; set trc_rep 9; wait 2; ')
print('written')

# THE FULL LOAD ORDER (Brutal Doom's pawn): its eyes sit higher on the rig, so the pocket and the hips are 0.10 m higher
# (as trc_scriptH did): the same scripts with those poses, as trc_scriptLO_*.txt. Gun Bonsai VR loaded: Smoker must be
# granted first (the fistsprobe's fp_rg; GunBonsaiOffhandVR/tools/fistsprobe), so each starts with that grant.
GRANT = 'wait 20; god; notarget; netevent fp_rg 2 7 1; netevent fp_rg 2 8 2; wait 5; '
for name in ['X1', 'X2', 'X3', 'R', 'S']:
    with open(os.path.join(HERE, 'trc_script%s.txt' % name)) as f: b = f.read()
    b = b.replace('"-0.16 1.20 -0.12', '"-0.16 1.30 -0.12').replace(' 0.86 0.0 30 0 0"', ' 0.96 0.0 30 0 0"')
    with open(os.path.join(HERE, 'trc_scriptLO_%s.txt' % name), 'w') as f: f.write(GRANT + b)
# Gun Bonsai VR + all RSQ pk3s on doom2: the grant, doom2 poses
for name in ['X1', 'X2', 'X3', 'R', 'S']:
    with open(os.path.join(HERE, 'trc_script%s.txt' % name)) as f: b = f.read()
    with open(os.path.join(HERE, 'trc_scriptGB_%s.txt' % name), 'w') as f: f.write(GRANT + b)
