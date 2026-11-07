#!/usr/bin/env python3
# TEST ONLY. The console script for run.sh: A and B of design/PARKED.md "BD22 VR dual wield and assigned holsters".
# Right-handed. Rifle (G: BD22 VR's Dual Rifle is on by default, rsq_dual_rifle; Dual Shotgun is off) is put in the right
# hip by hand (assigned there), SSG (X) in the left hip (assigned there).
#   TRD_A: G drawn, Dual (+user3) puts RSQ_Off_Rifle in the off hand; the off hand grips G's own holster (right hip).
#   TRD_B: G drawn and dual again; the off hand grips X's holster (left hip, SSG in it).
#   TRD_C (script_c.txt): see the end.
# Presses held 30 tics. Poses: qz_*hand "x(right) y(up from the floor) z(back) pitch yaw roll", room metres; the hips from
# RSQTR_Region's defaults on the eye the probe measures.
E = 1.55   # BD22 order: "TRD region ... eyes 1.55 m over the floor" (this probe, t30)
RR = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'; RL = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
HIP_R = '0.18 %.2f 0.0 30 0 0' % (E - 0.70); HIP_L = '-0.18 %.2f 0.0 30 0 0' % (E - 0.70)
def grip(hand, pose, rest):
    return 'qz_%shand "%s"; wait 15; qz_%sgrip 1; wait 30; qz_%sgrip 0; wait 6; %s; wait 90; ' % (hand, pose, hand, hand, rest)
def dual(): return 'echo TRD_DUAL; +user3; wait 8; -user3; wait 150; '
b = ('wait 40; vr_control_scheme 0; vr_secondary_button_mappings 0; set rsqtr_messages 1; set rsq_switch_log 1; set rsq_dual_rifle 1; god; '
     + RR + '; ' + RL + '; give Rifle; give SSG; wait 5; use Rifle; wait 150; ')
b += 'echo TRD_PUT_G_RIGHT_HIP; ' + grip('r', HIP_R, RR)
b += 'use SSG; wait 150; echo TRD_PUT_X_LEFT_HIP; ' + grip('r', HIP_L, RR)
b += 'echo TRD_DRAW_G; ' + grip('r', HIP_R, RR) + 'wait 60; ' + dual()
b += 'echo TRD_A; ' + grip('l', HIP_R, RL) + 'wait 120; '
b += 'echo TRD_DRAW_G2; ' + grip('r', HIP_R, RR) + 'wait 60; ' + dual()
b += 'echo TRD_B; ' + grip('l', HIP_L, RL) + 'wait 150; echo TRD_END; quit'
open(__import__('os').path.join(__import__('os').path.dirname(__import__('os').path.abspath(__file__)), 'script.txt'), 'w').write(b + '\n')
# TRD_C (design/PARKED.md "Dual edge cases", owner 11:3x): Rifle never holstered (unassigned), dual; the off hand grips the
# free, unassigned right hip: that holster becomes the Rifle's, the Rifle goes in, both hands go to fists. -> script_c.txt
c = ('wait 40; vr_control_scheme 0; vr_secondary_button_mappings 0; set rsqtr_messages 1; set rsq_switch_log 1; set rsq_dual_rifle 1; god; '
     + RR + '; ' + RL + '; give Rifle; wait 5; use Rifle; wait 150; ' + dual())
c += 'echo TRD_C; ' + grip('l', HIP_R, RL) + 'wait 150; echo TRD_END; quit'
open(__import__('os').path.join(__import__('os').path.dirname(__import__('os').path.abspath(__file__)), 'script_c.txt'), 'w').write(c + '\n')
