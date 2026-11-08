#!/usr/bin/env python3
# TEST ONLY. Console scripts for run.sh (the 11-08 new-player changes). Right-handed, BD22 order (eyes 1.55 m over the floor,
# as dualprobe measured; rsqtr_eye_m 1.62 so the rig is at scale 1.0 and Auto Height stays out of the way, except in H).
# Poses: qz_*hand "x(right) y(up from the floor) z(back) pitch yaw roll", room metres. qz_hmd pitch negative = looking down.
#   A: first fit (Rifle -> right hip), refuse (SSG at the Rifle's right hip), first fit (SSG -> left hip), draw Rifle,
#      home (Rifle at the SSG's full left hip: Rifle home to the right hip, SSG out), free (off hand held at the SSG's empty
#      left hip 50 tics).
#   O: overlap. The left chest holster (6) moved onto the left hip (0), 0.10 m higher; the hand between them, nearer the
#      chest. O1 empty hand, Rifle in the left hip: the hip (full) wins. O2 Rifle in hand, the grenade spot (3) moved
#      onto the right hip (1), the hand nearer the grenade spot: the hip wins.
#   H: auto height (rsqtr_eye_m 0, standing, head still) and the recentre tip (rsqtr_tip_recentre 0).
#   P: the empty ammo light's pulse (Rifle with no ammo at all in the right hip, rings Always).
import os
HERE = os.path.dirname(os.path.abspath(__file__))
E = 1.55
RR = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'; RL = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
def at(f, l, u, hand='r'):
    return '%.3f %.3f %.3f 30 0 0' % (-l, E + u, -f)
HIP_R = at(0, -0.18, -0.70); HIP_L = at(0, 0.18, -0.70)
def grip(hand, pose, rest, hold=30):
    return 'qz_%shand "%s"; wait 15; qz_%sgrip 1; wait %d; qz_%sgrip 0; wait 6; %s; wait 60; ' % (hand, pose, hand, hold, hand, rest)
BASE = ('wait 40; vr_control_scheme 0; vr_secondary_button_mappings 0; set rsqtr_messages 1; set rsq_switch_log 1; god; '
        + RR + '; ' + RL + '; ')
def write(name, s):
    open(os.path.join(HERE, name), 'w').write(s + '\n')

a = 'set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; ' + BASE + 'give Rifle; give SSG; wait 5; use Rifle; wait 150; '
a += 'qz_hmd "0 1.6 0 -62 -22 0"; echo UX_ASSIGN_RIFLE; ' + grip('r', HIP_R, RR)
a += 'use SSG; wait 150; echo UX_REFUSE_SSG; ' + grip('r', HIP_R, RR)
a += 'qz_hmd "0 1.6 0 -62 22 0"; echo UX_ASSIGN_SSG; ' + grip('r', HIP_L, RR)
a += 'qz_hmd "0 1.6 0 -62 -22 0"; echo UX_DRAW_RIFLE; ' + grip('r', HIP_R, RR) + 'wait 90; '
a += 'qz_hmd "0 1.6 0 -66 0 0"; echo UX_HOME; ' + grip('r', HIP_L, RR) + 'wait 90; '
a += 'qz_hmd "0 1.6 0 -62 22 0"; echo UX_FREE; ' + grip('l', HIP_L, RL, 50) + 'wait 60; echo UX_END; quit'
write('script_a.txt', a)

# O: overlap
CH_L = at(0, 0.18, -0.60)     # left chest moved to 0.10 m over the left hip
o = 'set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; ' + BASE + 'give Rifle; give SSG; wait 5; use Rifle; wait 150; '
o += 'echo UX_PUT_RIFLE_LEFT_HIP; ' + grip('r', HIP_L, RR)
o += 'set rsqtr_r6_f 0; set rsqtr_r6_l 0.18; set rsqtr_r6_u -0.60; set rsqtr_r6_rad 0.11; wait 5; '
o += 'echo UX_O1_EMPTY_HAND; qz_rhand "%s"; wait 20; ' % at(0, 0.18, -0.64) + RR + '; wait 20; '
o += 'use SSG; wait 150; '
o += 'set rsqtr_r3_f 0; set rsqtr_r3_l -0.18; set rsqtr_r3_u -0.60; wait 5; '
o += 'echo UX_O2_GUN_HAND; qz_rhand "%s"; wait 20; ' % at(0, -0.18, -0.64) + RR + '; wait 20; '
o += 'echo UX_O3_GUN_HAND_TWO_GUN_HOLSTERS; qz_rhand "%s"; wait 20; ' % at(0, 0.18, -0.64) + RR + '; wait 20; '
o += 'echo UX_END; quit'
write('script_o.txt', o)

# H: auto height + tip (the head still from the start; then 12 s for the tip)
h = 'set rsqtr_eye_m 0; set rsqtr_tip_recentre 0; set rsqtr_profile_active 1; ' + BASE + 'wait 500; echo UX_END; quit'
write('script_h.txt', h)
# H2: a set value is never overwritten; a seated profile never measures
h2 = 'set rsqtr_eye_m 1.70; set rsqtr_tip_recentre 1; ' + BASE + 'wait 200; echo UX_END; quit'
write('script_h2.txt', h2)
h3 = 'set rsqtr_eye_m 0; set rsqtr_tip_recentre 1; set rsqtr_profile_active 3; ' + BASE + 'wait 200; echo UX_END; quit'
write('script_h3.txt', h3)

# P: the empty light (Rifle emptied: take its ammo and magazine), rings Always, looking at the right hip
p = ('set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; set rsqtr_markers 2; ' + BASE + 'give Rifle; wait 5; use Rifle; wait 150; '
     + 'qz_hmd "0 1.6 0 -62 -22 0"; ' + grip('r', HIP_R, RR) + 'take Clip2 999; take RifleAmmo 999; echo UX_PULSE; wait 120; echo UX_END; quit')
write('script_p.txt', p)

# D: the item spots drawn as wire diamonds (11-08): FnF's flare pocket and flashlight clip and the cigarette pocket, rings
#    Always, looking down at the front of the body
d = ('set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; set rsqtr_markers 2; set rsqtr_cig 1; set trx_marks 1; ' + BASE
     + 'wait 60; qz_hmd "0 1.6 0 -70 0 0"; wait 80; echo UX_D_FRONT; qz_hmd "0 1.6 0 -60 30 0"; wait 80; echo UX_D_LEFT; '
     + 'qz_hmd "0 1.6 0 -60 -30 0"; wait 80; echo UX_END; quit')
write('script_d.txt', d)
# D2: only the three item spots near the hands (rings Near): the off hand by the cigarette pocket and FnF's clip, the main
#     hand by FnF's flare pocket, looking down at the chest
d2 = ('set rsqtr_eye_m 1.62; set rsqtr_tip_recentre 1; set rsqtr_markers 1; set rsqtr_cig 1; set trx_marks 1; ' + BASE
      + 'wait 60; qz_lhand "%s"; qz_rhand "%s"; qz_hmd "0 1.6 0 -40 0 0"; wait 80; echo UX_D2; wait 70; echo UX_END; quit'
      % (at(0.22, 0.20, -0.18), at(0.22, -0.15, -0.20)))
write('script_d2.txt', d2)
