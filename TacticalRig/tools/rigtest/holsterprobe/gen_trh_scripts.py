#!/usr/bin/env python3
# TEST ONLY. Scenarios for trh_run.sh (the whip and flare holsters, owner 11-03 20:14). Presses held 5-12 waits (the console
# counts frames). Hand poses are qz_*hand "x(right) y(up from the floor) z(back) pitch yaw roll", room metres.
#   F  the flare holster (doom2 + FnF + Whip): hover, take, back, take then an off-hand draw from another holster (the flare
#      goes back), take then an EMPTY gun holster (back), main-hand switches with a flare out (it stays), lit: refused, FnF
#      drops it burning.
#   W  the whip holster: hover, holster, draw, a gun drawn from the right hip with the whip out (whip home, not filed in the
#      hip), the whip at an empty gun holster (home), wheel/slot switches (home), the off hand at the whip holster (refused),
#      a gun in the hand at the whip holster (whip drawn).
#   WL / FL  the same, left-handed (vr_control_scheme 10): main hand = the left controller.
import os
HERE = os.path.dirname(os.path.abspath(__file__))
import sys
EYE = float(os.environ.get('TRH_EYE', '1.45'))     # 1.45 Doom 2's pawn; set for another order
REST_R = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'
REST_L = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
SETUP = ('wait 40; vr_control_scheme 0; vr_secondary_button_mappings 0; set rsqtr_messages 1; set rsqff_debug 1; %s; %s; '
         'give shotgun; give supershotgun; give chaingun; wait 5; ' % (REST_R, REST_L))
def grip(hand, pose, rest, hold=5):
    return 'qz_%shand "%s"; wait 12; qz_%sgrip 1; wait %d; qz_%sgrip 0; wait 6; %s; wait 25; ' % (hand, pose, hand, hold, hand, rest)
def body(lefty):
    # x of a spot on the body's right side (right-handed main-hand side) flips with handedness only for hand-owned spots
    m, o = ('l', 'r') if lefty else ('r', 'l')
    RM, RO = (REST_L, REST_R) if lefty else (REST_R, REST_L)
    s = -1 if lefty else 1
    def X(v): return '%.2f' % (v * s)
    # the rig's eyes are 1.45 m over the floor on Doom 2's pawn (probe: "eyes 1.45 m"); places from RSQTR_Region's defaults
    E = EYE
    P = dict(
        whip='%s %.2f 0.06 30 0 0' % (X(0.30), E - 0.84), flare='%s %.2f 0.06 30 0 0' % (X(-0.30), E - 0.84),
        hipM='%s %.2f 0.0 30 0 0' % (X(0.18), E - 0.70), hipO='%s %.2f 0.0 30 0 0' % (X(-0.18), E - 0.70),
        chestO='%s %.2f -0.10 30 0 0' % (X(-0.12), E - 0.46), chestM='%s %.2f -0.10 30 0 0' % (X(0.12), E - 0.46))
    return m, o, RM, RO, P
def F(lefty):
    m, o, RM, RO, P = body(lefty)
    b = SETUP + ('vr_control_scheme 10; ' if lefty else '')
    # the SSG into the off-hand-side hip with the main hand
    b += 'use SuperShotgun; wait 40; ' + grip(m, P['hipO'], RM) + 'use Shotgun; wait 40; '
    b += 'echo TRH_F_HOVER; qz_%shand "%s"; wait 15; %s; wait 10; ' % (o, P['flare'], RO)
    b += 'echo TRH_F_TAKE; ' + grip(o, P['flare'], RO)
    b += 'echo TRH_F_BACK; ' + grip(o, P['flare'], RO)
    b += 'echo TRH_F_TAKE2; ' + grip(o, P['flare'], RO)
    b += 'echo TRH_F_OFFDRAW_OTHER_HOLSTER; ' + grip(o, P['hipO'], RO) + 'wait 20; '
    b += 'echo TRH_F_OFF_GUN_BACK_TO_HIP; ' + grip(o, P['hipO'], RO)
    b += 'echo TRH_F_TAKE3; ' + grip(o, P['flare'], RO)
    b += 'echo TRH_F_EMPTY_GUN_HOLSTER; ' + grip(o, P['chestO'], RO)
    b += 'echo TRH_F_TAKE4; ' + grip(o, P['flare'], RO)
    b += 'echo TRH_F_MAIN_SLOT_SWITCH; slot 4; wait 40; echo TRH_F_MAIN_NEXT; weapnext; wait 40; '
    b += 'echo TRH_F_MAIN_HAND_AT_FLARE; ' + grip(m, P['flare'], RM)
    b += 'echo TRH_F_LIGHT; +oh_attack; wait 8; -oh_attack; wait 30; '
    b += 'echo TRH_F_LIT_AT_HOLSTER; ' + grip(o, P['flare'], RO) + 'wait 20; '
    b += 'echo TRH_F_OFF_GUN_TO_HIP; ' + grip(o, P['hipO'], RO)
    b += 'echo TRH_F_TAKE5; ' + grip(o, P['flare'], RO) + 'echo TRH_F_LIGHT2; +oh_attack; wait 8; -oh_attack; wait 30; '
    b += 'echo TRH_F_OFFDRAW_LIT; ' + grip(o, P['hipO'], RO) + 'wait 20; '
    return b
def W(lefty):
    m, o, RM, RO, P = body(lefty)
    b = SETUP + ('vr_control_scheme 10; ' if lefty else '') + 'give RSQWP_WhipWeapon; wait 5; '
    # the shotgun into the main-hand-side hip
    b += 'use Shotgun; wait 40; ' + grip(m, P['hipM'], RM)
    b += 'use RSQWP_WhipWeapon; wait 40; '
    b += 'echo TRH_W_HOVER; qz_%shand "%s"; wait 15; %s; wait 10; ' % (m, P['whip'], RM)
    b += 'echo TRH_W_HOLSTER; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_DRAW; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_GUN_FROM_HIP; ' + grip(m, P['hipM'], RM) + 'wait 20; '
    b += 'echo TRH_W_GUN_BACK_TO_HIP; ' + grip(m, P['hipM'], RM) + 'wait 20; '
    b += 'echo TRH_W_DRAW2; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_EMPTY_GUN_HOLSTER; ' + grip(m, P['chestM'], RM) + 'wait 20; '
    b += 'echo TRH_W_DRAW3; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_SLOT3; slot 3; wait 45; '
    b += 'echo TRH_W_DRAW4; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_WEAPNEXT; weapnext; wait 45; '
    b += 'echo TRH_W_DRAW5; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_USE_CHAINGUN; use Chaingun; wait 45; '
    b += 'echo TRH_W_OFF_AT_WHIP; ' + grip(o, P['whip'], RO)
    b += 'echo TRH_W_GUN_IN_HAND_AT_WHIP; ' + grip(m, P['whip'], RM) + 'wait 20; '
    b += 'echo TRH_W_GUN_FROM_HIP2; ' + grip(m, P['hipM'], RM) + 'wait 20; '
    return b
def write(name, b):
    with open(os.path.join(HERE, 'trh_script%s.txt' % name), 'w') as f: f.write(b + 'wait 20; quit\n')
# ALL / ALLL (owner 11-03 20:51, "the torso rig will need to always show cigarette, whip, grenade, sabers, shieldsaw"):
# everything owned and stowed, the mirror (front, then back) with the torso; then each in a hand in turn (its spot empty).
# Loads TacticalRig + FnF + Whip + Saber + ShieldSaw + Grenade. Frames: EVERY.
def ALL(lefty):
    b = ('wait 40; con_notifytime 0; vr_control_scheme %d; %s; %s; set rsqtr_cig 1; set rsqtr_vest 0; set rsqtr_markers 0; '
         'set rsqtr_mirror 2; set rsqtr_mirror_m 0.5; set rsqtr_mirror_view 0; qz_hmd "0 1.6 0 -30 0 0"; '
         'give shotgun; give RSQWP_WhipWeapon; give UBQS_Saber; give UBQS_SaberOff; give SSQ_ShieldSaw; give RSQGN_Ammo 3; wait 5; use Shotgun; '
         % (10 if lefty else 0, REST_R, REST_L))
    b += 'wait 60; echo TRH_ALL_FRONT; wait 40; set rsqtr_mirror_view 1; echo TRH_ALL_BACK; wait 40; set rsqtr_mirror_view 0; '
    b += 'use RSQWP_WhipWeapon; wait 40; echo TRH_ALL_WHIP_IN_HAND; wait 40; use UBQS_Saber; wait 40; echo TRH_ALL_SABER_IN_HAND; wait 40; '
    b += 'use Shotgun; wait 40; set rsqtr_cig 0; echo TRH_ALL_CIG_OFF; wait 40; '
    return b
# POUCH / POUCHL / POUCH_BDALONE (owner 11-03 20:46, the ammo pouch): on the Brutal Doom order (eyes 1.55 m: the BD pawn
# stands 0.10 higher), a Rifle emptied and its magazine dropped (+reload), then the off hand pressed (off trigger, Grab Ammo
# With: trigger) at the buckle, the off hip, the off chest holster, the flare holster and the pouch; then a Shot_Gun with a
# shell fired, a press at the buckle and at the pouch. rsr_debug logs every take or refusal. Frames: the pouch looked at.
def POUCH(lefty):
    E = 1.55
    s = -1 if lefty else 1
    def X(v): return '%.2f' % (v * s)
    lo = 'qz_lhand' if not lefty else 'qz_rhand'          # the OFF controller
    rest = REST_L if not lefty else REST_R
    spots = [('BUCKLE', '0.00 %.2f -0.12' % (E - 0.62)), ('OFF_HIP', '%s %.2f 0.00' % (X(-0.18), E - 0.70)),
             ('OFF_CHEST', '%s %.2f -0.10' % (X(-0.12), E - 0.46)), ('FLARE_HOLSTER', '%s %.2f 0.06' % (X(-0.30), E - 0.84)),
             ('POUCH', '%s %.2f -0.16' % (X(-0.13), E - 0.61))]
    b = ('wait 60; god; notarget; puristmode false; con_notifytime 0; vr_control_scheme %d; vr_secondary_button_mappings 0; rsr_reload 1; rsr_grab_with 0; '
         'rsr_debug 1; set rsqtr_messages 1; set rsqtr_markers 2; %s; %s; give Rifle; give Clip2 400; use Rifle; wait 80; '
         '+attack; wait 12; -attack; wait 25; +reload; wait 4; -reload; wait 40; ' % (10 if lefty else 0, REST_R, REST_L))
    trig = 'qz_ltrigger' if not lefty else 'qz_rtrigger'
    for nm, pos in spots:
        b += 'echo TRH_P_MAG_AT_%s; %s "%s 30 0 0"; wait 12; %s 1; wait 12; %s 0; wait 8; %s; wait 25; ' % (nm, lo, pos, trig, trig, rest)
    b += 'give Shot_Gun; give AmmoShell 20; use Shot_Gun; wait 80; +attack; wait 6; -attack; wait 40; '
    for nm, pos in [spots[0], spots[4]]:
        b += 'echo TRH_P_SHELL_AT_%s; %s "%s 30 0 0"; wait 12; %s 1; wait 12; %s 0; wait 8; %s; wait 25; ' % (nm, lo, pos, trig, trig, rest)
    b += 'use Rifle; wait 60; qz_hmd "0 1.6 0 -70 %d 0"; echo TRH_P_LOOK; wait 40; ' % (20 if lefty else -20)
    return b
write('POUCH', POUCH(False)); write('POUCHL', POUCH(True))
write('F', F(False)); write('FL', F(True)); write('W', W(False)); write('WL', W(True)); write('ALL', ALL(False)); write('ALLL', ALL(True))
