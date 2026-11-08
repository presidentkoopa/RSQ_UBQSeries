#!/usr/bin/env python3
# TEST ONLY (never ships). The one rig test of the five merged 11-08 features (ghost hand, struggle hint, seated layout,
# shoulder grace, ammo arc) plus the regression (holster + draw, rule flash). Writes script_hol4_*.txt for run.sh.
# Poses as gen_scripts.py (right-handed, eyes 1.55 m, rsqtr_eye_m 1.62).
import os
HERE = os.path.dirname(os.path.abspath(__file__))
E = 1.55
RR = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'; RL = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
def at(f, l, u):
    return '%.3f %.3f %.3f 30 0 0' % (-l, E + u, -f)
HIP_R = at(0, -0.18, -0.70)
SH_R = at(-0.08, -0.18, -0.10)
CH_R = at(0.10, -0.12, -0.46)
NEAR_HIP_R = at(0.0, -0.40, -0.70)     # 0.22 m outboard of the right hip centre: outside its 0.14 ring, inside 2.5 radii, in no other ring
def grip(pose, rest, hold=30, hand='r'):
    return 'qz_%shand "%s"; wait 15; qz_%sgrip 1; wait %d; qz_%sgrip 0; wait 6; %s; wait 60; ' % (hand, pose, hand, hold, hand, rest)
BASE = ('wait 40; vr_control_scheme 0; vr_secondary_button_mappings 0; set rsqtr_messages 1; set rsq_switch_log 1; vr_hud_scale 1; god; '
        + RR + '; ' + RL + '; ')
PRE = 'set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; '
LOOK_HIP = 'qz_hmd "0 1.6 0 -50 -18 0"; '
def write(name, s):
    open(os.path.join(HERE, name), 'w').write(s + '\n')

# G: ghost hand (full order) + regression (first fit with the rule flash, holster, draw)
g = PRE + 'set rsqtr_tip_holster 0; set rsqtr_markers 1; ' + BASE + LOOK_HIP + 'give Rifle; give SSG; wait 5; use Rifle; echo HOL4_G_HOLD; wait 300; '
g += 'echo HOL4_G_EMPTY; use Melee_Attacks; wait 100; echo HOL4_G_RAISE; use Rifle; wait 250; '
g += 'qz_hmd "0 1.6 0 -62 -22 0"; echo HOL4_G_HOLSTER; ' + grip(HIP_R, RR) + 'wait 40; '
g += 'echo HOL4_G_DRAW; ' + grip(HIP_R, RR) + 'wait 60; '
g += 'echo HOL4_G_SSG; use SSG; wait 250; echo HOL4_END; quit'
write('script_hol4_g.txt', g)

# GA: ghost without BD22 VR (doom2 + the Rig): the doom2 shotgun
ga = PRE + 'set rsqtr_tip_holster 0; set rsqtr_markers 1; ' + BASE + LOOK_HIP + 'give Shotgun; wait 5; use Shotgun; echo HOL4_GA_HOLD; wait 300; echo HOL4_END; quit'
write('script_hol4_ga.txt', ga)

# S: struggle hint (empty hand, rings Near)
def inout(n, pose=HIP_R):
    return ''.join('qz_rhand "%s"; wait 20; %s; wait 20; ' % (pose, RR) for _ in range(n))
s = PRE + 'set rsqtr_tip_holster 1; set rsqtr_markers 1; ' + BASE + 'use Melee_Attacks; qz_hmd "0 1.6 0 -62 -22 0"; wait 60; '
s += 'echo HOL4_S_THREE; ' + inout(3) + 'wait 40; '
s += 'echo HOL4_S_AGAIN; ' + inout(3) + 'wait 60; '
# a grip inside between misses: one miss, then in + grip + out
s += 'echo HOL4_S_RESET; ' + inout(1) + 'qz_rhand "%s"; wait 15; qz_rgrip 1; wait 20; qz_rgrip 0; wait 5; %s; wait 30; ' % (HIP_R, RR)
s += 'echo HOL4_S_EDIT; set rsqtr_edit 1; wait 10; ' + inout(3) + 'set rsqtr_edit 0; wait 20; echo HOL4_END; quit'
write('script_hol4_s.txt', s)

# SE: seated layout. Seated eyes at 1.20 m in the room.
se = ('set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; set rsqtr_tip_holster 1; set rsqtr_tip_seated 0; set rsqtr_seated 1; '
      'set rsqtr_markers 2; set rsqtr_mirror 2; set rsqtr_profile_active 1; ' + BASE.replace(RR, 'qz_rhand "0.25 0.95 -0.3 30 0 0"').replace(RL, 'qz_lhand "-0.25 0.95 -0.3 30 0 0"')
      + 'qz_hmd "0 1.2 0 -60 0 0"; wait 40; echo HOL4_SE_P3; set rsqtr_profile_active 3; wait 120; '
      + 'echo HOL4_SE_MIRROR; qz_hmd "0 1.2 0 0 0 0"; wait 60; qz_hmd "0 1.2 0 -60 0 0"; '
      + 'echo HOL4_SE_P1; set rsqtr_profile_active 1; wait 60; echo HOL4_SE_P3B; set rsqtr_profile_active 3; wait 200; echo HOL4_END; quit')
write('script_hol4_se.txt', se)

# SH: shoulder grace. Rifle in hand.
def sh_press(k, pose=SH_R, then=RR):
    return 'qz_rhand "%s"; wait 10; %s; wait %d; qz_rgrip 1; wait 30; qz_rgrip 0; wait 6; %s; wait 60; ' % (pose, then, k, RR)
sh = PRE + 'set rsqtr_tip_holster 1; set rsqtr_markers 1; ' + BASE + 'qz_hmd "0 1.6 0 -20 -40 0"; give Rifle; give SSG; wait 5; use Rifle; wait 150; '
sh += 'echo HOL4_SH_A5_HOLSTER; ' + sh_press(5)
sh += 'echo HOL4_SH_LATE14; ' + sh_press(14)
sh += 'echo HOL4_SH_A5_DRAW; ' + sh_press(5) + 'wait 60; '
sh += 'echo HOL4_SH_CHEST; ' + sh_press(5, then='qz_rhand "%s"' % CH_R) + 'wait 30; echo HOL4_END; quit'
write('script_hol4_sh.txt', sh)

# AA: ammo arc. Rifle into the right hip, rings Near; the hand near / away; magazine part, low, full, empty.
NH = 'qz_rhand "%s"; ' % NEAR_HIP_R
aa = PRE + 'set rsqtr_tip_holster 1; set rsqtr_markers 1; ' + BASE + 'give Rifle; give SSG; wait 40; use Rifle; wait 150; '
aa += 'qz_hmd "0 1.6 0 -62 -22 0"; ' + grip(HIP_R, RR) + 'wait 60; use SSG; wait 150; '
aa += 'take RifleAmmo 10; echo HOL4_AA_PART; ' + NH + 'wait 70; ' + RR + '; wait 30; '
aa += 'take RifleAmmo 11; echo HOL4_AA_LOW; ' + NH + 'wait 70; ' + RR + '; wait 30; '
aa += 'give RifleAmmo 31; echo HOL4_AA_FULL; ' + NH + 'wait 70; ' + RR + '; wait 30; '
aa += 'take RifleAmmo 999; echo HOL4_AA_EMPTY; ' + NH + 'wait 70; echo HOL4_AA_AWAY; ' + RR + '; wait 40; echo HOL4_END; quit'
write('script_hol4_aa.txt', aa)
print('ok')
