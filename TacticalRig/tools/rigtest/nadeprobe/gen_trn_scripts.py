#!/usr/bin/env python3
# gen_trn_scripts.py -- TEST ONLY: writes the grenade-holster rig scripts.
#   trn_scriptD.txt  doom2 + RSQ Grenade (RSQGN_Ammo / RSQGN_Grenade)
#   trn_scriptLO.txt the full order (BD22's GrenadeAmmo / HandGrenades)
# Looking down at the buckle from the eyes (pitch -70), both hands held well away from it (no ring, Hand Nearby);
# 0, 1, 3 grenades; the grenade drawn at the spot (netevent rsqtr_nade) and put back; the switch off; then the
# rings always on (the spot's count light) at 3, 1, 0, looking 60 down.
def script(ammo, weap, setup):
    s = ['wait 40', 'vr_secondary_button_mappings 0', 'set rsqtr_messages 1',
         'qz_rhand "0.35 1.45 -0.35 30 0 0"', 'qz_lhand "-0.35 1.45 -0.35 30 0 0"'] + setup + [
         'take %s 999' % ammo, 'wait 5', 'qz_hmd "0 1.6 0 -70 0 0"', 'echo TRN_ZERO', 'wait 70',
         'give %s 1' % ammo, 'echo TRN_ONE', 'wait 70',
         'give %s 2' % ammo, 'echo TRN_THREE', 'wait 70',
         'give %s' % weap, 'netevent rsqtr_nade', 'echo TRN_INHAND', 'wait 70',
         'netevent rsqtr_nade', 'echo TRN_BACK', 'wait 70',
         'set rsqtr_nade_show 0', 'echo TRN_SWITCH_OFF', 'wait 50',
         'set rsqtr_nade_show 1', 'set rsqtr_markers 2', 'qz_hmd "0 1.6 0 -60 0 0"', 'echo TRN_RINGS', 'wait 70',
         'take %s 2' % ammo, 'echo TRN_RINGS_ONE', 'wait 60',
         'take %s 1' % ammo, 'echo TRN_RINGS_ZERO', 'wait 60', 'quit']
    return '; '.join(s) + '\n'
import os
d = os.path.dirname(os.path.abspath(__file__))
open(os.path.join(d, 'trn_scriptD.txt'), 'w').write(script('RSQGN_Ammo', 'RSQGN_Grenade', ['give shotgun', 'wait 5', 'use Shotgun']))
open(os.path.join(d, 'trn_scriptLO.txt'), 'w').write(script('GrenadeAmmo', 'HandGrenades', []))
