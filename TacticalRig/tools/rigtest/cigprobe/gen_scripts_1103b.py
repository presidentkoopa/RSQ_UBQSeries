#!/usr/bin/env python3
# (Presses are held 10 waits: the console counts frames, and at a high frame rate a shorter hold can fall between two tics.)
# TEST ONLY. The 11-03 (afternoon) cigarette scenarios for trc_run.sh (owner's final rules):
#   E<state>[_LO]: every exit with the cigarette in the hand (1), in the mouth (2), lit (3): the main hand's next key,
#     a slot key, the off hand's next key, switchhand 1 / 0, the main hand at a full holster, the off hand at a holster,
#     another mod emptying the off hand, another mod switching the main hand. A trc_rep line just before the press, 3
#     tics after and 50 after; the cigarette's own T_CIG exit lines give both hands the tic of the end and the tic after.
#   R2[_LO]: the ritual (lit with the Zippo's trigger at the tip) and the other ends (flick, pocket, smoked, Use while
#     smoking, Cigarettes off, death, level change).
#   L: lighting (off-hand fire away from the tip: open / shut; at the tip: lit; Use in the mouth: nothing).
#   M: the mouth cigarette placed ten ways (hand poses, headset moved / lower / leaning) and followed through head turns.
#   FV: frames from the eye (the rig's camera is the head) with the lit cigarette in the mouth: level, up, down.
# _LO: Brutal Doom's full order (the pocket and the hips 0.10 m higher on its pawn), with a gun that has an off-hand copy
# (Shot_Gun + RSQ_Off_Shot_Gun) and one that has none (Rocket_Launcher). Doom 2 has no off-hand copies at all.
import os
HERE = os.path.dirname(os.path.abspath(__file__))
REST_R = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'
REST_L = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
TIP_L = 'qz_lhand "0.00 1.50 -0.18 0 0 0"'          # the Zippo's flame 2 cm from the mouth cigarette's tip (rig, 11-03)
BINDS = ('bind pad_a +use; bind pad_b weapnext; bind pad_y "weapnext 1"; bind pad_x "slot 3"; vr_secondary_button_mappings 0; '
         'set rsqtr_cig 1; set rsqtr_messages 1; set rsqtr_cig_count 20; set rsqtr_cig_smoke 5; %s; %s; ' % (REST_R, REST_L))
HIP_R = 'qz_rhand "0.18 0.86 0.0 30 0 0"; wait 10; qz_rgrip 1; wait 5; qz_rgrip 0; wait 5; %s; wait 30; ' % REST_R
HIP_L_MAIN = 'qz_rhand "-0.18 0.86 0.0 30 0 0"; wait 10; qz_rgrip 1; wait 5; qz_rgrip 0; wait 5; %s; wait 30; ' % REST_R
HIP_L_OFF = 'qz_lhand "-0.18 0.86 0.0 30 0 0"; wait 10; qz_lgrip 1; wait 5; qz_lgrip 0; wait 5; %s; ' % REST_L
TAKE = 'qz_rhand "-0.16 1.20 -0.12 30 0 0"; wait 12; +use; wait 10; -use; wait 12; %s; wait 30; ' % REST_R
MOUTH = 'qz_rhand "0.02 1.44 -0.10 70 40 30"; wait 8; +use; wait 10; -use; wait 15; %s; wait 30; ' % REST_R
LIGHT = '%s; wait 15; +oh_attack; wait 10; -oh_attack; wait 20; %s; wait 10; ' % (TIP_L, REST_L)
GUNS = {
    'D2': dict(give='give shotgun; give chaingun; give supershotgun; ', main='Chaingun', hipr='Shotgun', hipl='SuperShotgun', sw='Shotgun'),
    'LO': dict(give='give Shot_Gun; give RSQ_Off_Shot_Gun; give Rocket_Launcher; give SSG; ', main='Rocket_Launcher', hipr='Shot_Gun', hipl='SSG', sw='Shot_Gun'),
}
GRANT = 'wait 20; god; notarget; netevent fp_rg 2 7 1; netevent fp_rg 2 8 2; wait 5; '

def setup(g):
    return ('wait 40; ' + BINDS + g['give'] + 'give RSQTR_CigPack 30; wait 5; '
            'use %s; wait 40; %s' 'use %s; wait 40; %s' 'use %s; wait 40; echo TRC_SETUP_DONE; set trc_weap 1; set trc_rep 99; wait 2; '
            % (g['hipr'], HIP_R, g['hipl'], HIP_L_MAIN, g['main']))

def actions(g):
    return [
        ('MAIN_NEXT_KEY', 'qz_rbuttons 2; wait 12; qz_rbuttons 0; '),
        ('MAIN_SLOT3_KEY', 'qz_lbuttons 256; wait 12; qz_lbuttons 0; '),
        ('OFF_NEXT_KEY', 'qz_lbuttons 512; wait 12; qz_lbuttons 0; '),
        ('SWITCHHAND_1', 'switchhand 1; '),
        ('SWITCHHAND_0', 'switchhand 0; '),
        ('MAIN_HOLSTER_RIGHT_HIP', 'qz_rhand "0.18 0.86 0.0 30 0 0"; wait 10; qz_rgrip 1; wait 5; qz_rgrip 0; wait 5; %s; ' % REST_R),
        ('OFF_HOLSTER_LEFT_HIP', HIP_L_OFF),
        ('OTHER_MOD_EMPTIES_OFF', 'set trc_steal 1; '),
        ('OTHER_MOD_SWITCHES_MAIN', 'set trc_switch %s; ' % g['sw']),
    ]

# On the full order the rig runs a few tics behind the console under load (a Use seen 17 tics late, rig 11-03), so the
# ritual's own steps (take, to the mouth, light) are sent as their network events there; the presses themselves are
# proven on Doom 2 and Gun Bonsai + all RSQ (E, R2, L). The exits stay real presses (keys, grips, switchhand).
TAKE_N = 'netevent rsqtr_cigtake; wait 40; '
MOUTH_N = 'netevent rsqtr_ciglock; wait 30; '
LIGHT_N = 'netevent rsqtr_ciglight; wait 20; '
def lo(b):
    b = b.replace(TAKE + MOUTH + LIGHT, TAKE_N + MOUTH_N + LIGHT_N).replace(TAKE + MOUTH, TAKE_N + MOUTH_N).replace(TAKE, TAKE_N)
    b = b.replace('wait 10; qz_rgrip 1; wait 5; qz_rgrip 0', 'wait 25; qz_rgrip 1; wait 12; qz_rgrip 0').replace('wait 10; qz_lgrip 1; wait 5; qz_lgrip 0', 'wait 25; qz_lgrip 1; wait 12; qz_lgrip 0')
    return b.replace('"-0.16 1.20 -0.12', '"-0.16 1.30 -0.12').replace(' 0.86 0.0 30 0 0"', ' 0.96 0.0 30 0 0"')

def write(name, body):
    with open(os.path.join(HERE, 'trc_script%s.txt' % name), 'w') as f: f.write(body + 'wait 20; quit\n')

STATES = [('HAND', TAKE), ('MOUTH', TAKE + MOUTH), ('LIT', TAKE + MOUTH + LIGHT)]
for kind in ['D2', 'LO']:
    g = GUNS[kind]
    for si, (sn, get) in enumerate(STATES, 1):
        b = setup(g)
        for ai, (an, act) in enumerate(actions(g)):
            k = si * 100 + ai * 3 + 1
            b += ('echo TRC_%s_%s; use %s; wait 40; %sset trc_rep %d; wait 2; %swait 3; set trc_rep %d; wait 50; set trc_rep %d; wait 10; '
                  % (sn, an, g['main'], get, k, act, k + 1, k + 2))
        write('E%d%s' % (si, '' if kind == 'D2' else '_LO'), (GRANT + lo(b)) if kind == 'LO' else b)

    # R2: the ritual and the other ends
    R = setup(g).replace('set rsqtr_cig_smoke 5', 'set rsqtr_cig_smoke 2')
    R += ('echo TRC_R_TAKE; ' + TAKE + 'set trc_rep 1; wait 2; echo TRC_R_MOUTH; ' + MOUTH + 'set trc_rep 2; wait 2; echo TRC_R_LIGHT_SMOKED; ' + LIGHT
          + 'wait 80; set trc_rep 3; wait 2; netevent rsm_state; '
          + 'echo TRC_R_FLICK_FROM_HAND; use %s; wait 40; ' % g['main'] + TAKE + 'qz_rhand "0.30 1.1 -0.45 30 0 0"; wait 8; +use; wait 10; -use; wait 40; set trc_rep 4; wait 2; '
          + 'echo TRC_R_POCKET; ' + TAKE + 'qz_rhand "-0.16 1.20 -0.12 30 0 0"; wait 12; qz_rgrip 1; wait 4; qz_rgrip 0; wait 10; %s; wait 40; set trc_rep 5; wait 2; ' % REST_R
          + 'echo TRC_R_USE_WHILE_SMOKING; set rsqtr_cig_smoke 5; ' + TAKE + MOUTH + LIGHT + '+use; wait 10; -use; wait 40; set trc_rep 6; wait 2; '
          + 'echo TRC_R_CIGS_OFF_LIT; ' + TAKE + MOUTH + LIGHT + 'set rsqtr_cig 0; wait 30; set trc_rep 7; wait 2; set rsqtr_cig 1; wait 10; '
          + 'echo TRC_R_CIGS_OFF_HAND; ' + TAKE + 'set rsqtr_cig 0; wait 30; set trc_rep 8; wait 2; set rsqtr_cig 1; wait 10; '
          + 'echo TRC_R_LEVEL_CHANGE_MOUTH; ' + TAKE + MOUTH + 'set trc_rep 9; wait 2; set trc_next 1; wait 80; set trc_rep 10; wait 2; '
          + 'echo TRC_R_DEATH_HAND; ' + TAKE + 'kill; wait 40; set trc_rep 11; wait 2; ')
    write('R2%s' % ('' if kind == 'D2' else '_LO'), (GRANT + lo(R)) if kind == 'LO' else R)

# L: lighting (doom 2). The off trigger once as the controller's own trigger (qz_ltrigger: the key path) and the rest as
# +oh_attack (the command path).
g = GUNS['D2']
L = (setup(g) + TAKE + MOUTH
     + 'echo TRC_L_FIRE_AWAY_1; qz_ltrigger 1; wait 5; qz_ltrigger 0; wait 25; set trc_rep 1; wait 2; '
     + 'echo TRC_L_FIRE_AWAY_2; +oh_attack; wait 10; -oh_attack; wait 25; set trc_rep 2; wait 2; '
     + 'echo TRC_L_USE_IN_MOUTH; ' + TIP_L + '; wait 15; +use; wait 10; -use; wait 20; set trc_rep 3; wait 2; '
     + 'echo TRC_L_FIRE_AT_TIP; +oh_attack; wait 10; -oh_attack; wait 30; set trc_rep 4; wait 2; ' + REST_L + '; wait 200; ')
write('L', L)

# M: ten placements. 1-3 three hand poses at the lips; 4 the headset 0.2 m to the right; 5 the headset 0.25 m lower;
# 6 leaning 0.12 m forward; 7-10 placed level, then the head turned (qz_hmd pitch positive is UP): 20 up, 15 down, 40 to
# the side, 65 up.
def hmd(x, y, z, p=0, yw=0): return 'qz_hmd "%.2f %.2f %.2f %d %d 0"; ' % (x, y, z, p, yw)
PLACE = []
for (hx, hy, hz, hand) in [(0, 1.6, 0, '0.02 1.44 -0.10 70 40 30'), (0, 1.6, 0, '0.00 1.42 -0.08 60 30 20'), (0, 1.6, 0, '0.04 1.47 -0.11 80 50 40'),
                           (0.2, 1.6, 0, '0.22 1.44 -0.10 70 40 30'), (0, 1.35, 0, '0.02 1.19 -0.10 70 40 30'), (0, 1.6, -0.12, '0.02 1.44 -0.22 70 40 30')]:
    PLACE.append((hmd(hx, hy, hz), hand, ''))
for (p, yw) in [(20, 0), (-15, 0), (0, 40), (65, 0)]:
    PLACE.append((hmd(0, 1.6, 0), '0.02 1.44 -0.10 70 40 30', hmd(0, 1.6, 0, p, yw)))
M = setup(g)
for i, (h, hand, turn) in enumerate(PLACE, 1):
    M += ('echo TRC_M_%d; %suse %s; wait 30; netevent rsqtr_cigtake; wait 40; ' % (i, h, g['main'])
          + 'qz_rhand "%s"; wait 8; +use; wait 10; -use; wait 15; %s; wait 10; %swait 20; set trc_mpos %d; wait 3; '
            'qz_rhand "-0.16 1.20 -0.12 30 0 0"; wait 5; ' % (hand, REST_R, turn, i)
          + 'set rsqtr_cig 0; wait 10; set rsqtr_cig 1; wait 5; ' + hmd(0, 1.6, 0))
write('M', M)

# F: frames. Lit, smoking 5 s: look level, 12 up, 15 down (the rig's qz_hmd pitch is positive UP: pawn pitch = -it) (the rig's camera is the head; EVERY dumps frames).
# (the ritual's steps sent as their own network events: with frames dumped the rig runs a few frames a second and a
# console +use can fall between two tics; the presses themselves are proven in E / R2 / L)
F = (setup(g) + 'netevent rsqtr_cigtake; wait 40; netevent rsqtr_ciglock; wait 20; ' + TIP_L + '; wait 10; netevent rsqtr_ciglight; wait 8; ' + REST_L + '; '
     + 'echo TRC_F_LEVEL; wait 25; ' + hmd(0, 1.6, 0, 12) + 'echo TRC_F_UP_12; wait 25; ' + hmd(0, 1.6, 0, -15) + 'echo TRC_F_DOWN_15; wait 25; ' + hmd(0, 1.6, 0))
write('FV', F)
print('written')
