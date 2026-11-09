#!/usr/bin/env python3
# TEST ONLY. The console script for run.sh (one rig session, 11-09): the pouch's reach, SlowMo's reload lengths and hands,
# Tactical Rig's Dual-to-main. Poses: qz_*hand "x(right) y(up from the floor) z(back) pitch yaw roll", room metres; eyes
# 1.55 m over the floor on the Brutal Doom order (dualprobe's measure). The pouch (rig.zs, 11-09): 0.22 forward, 0.18
# toward the off hand (left, right-handed), 0.64 under the eyes -> x -0.18, y 0.91, z -0.22.
import os
E = 1.55
RR = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'; RL = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
def lh(x, y, z, pitch=30): return 'qz_lhand "%.3f %.3f %.3f %d 0 0"' % (x, y, z, pitch)
def flick(hands):   # every hand in `hands`: level (arms), +70, level, -70, level: one of the two is a 70-degree drop
    out = ''
    for pitch in (0, 70, 0, -70, 0):
        for h in hands:
            out += 'qz_%shand "%s %d 0 0"; ' % (h, '0.25 1.3 -0.3' if h == 'r' else '-0.25 1.3 -0.3', pitch)
        out += 'wait 10; '
    return out + (RR + '; ' if 'r' in hands else '') + (RL + '; ' if 'l' in hands else '')
def reload_key(): return '+reload; wait 3; -reload; '
s = ('wait 40; vr_control_scheme 0; vr_secondary_button_mappings 0; set rsqtr_messages 1; set rsq_switch_log 1; '
     'set rsq_dual_rifle 1; set rsr_reload 0; set rsqsm_debug 1; set rsqsm_reload 1; set rsqsm_reload_when 0; '
     'set rsqsm_auto_cooldown 0; set rsqsm_trig_score 0; set rsqsm_auto_miniboss 0; set rsqsm_closecall 0; '
     'set rsqsm_trig_heavy 0; set rsqsm_trig_gbvr 0; set rsqsm_auto_other 0; god; notarget; ' + RR + '; ' + RL + '; '
     'give Rifle; give Clip2 200; wait 5; use Rifle; wait 120; ')
# 1. the pouch reaching: the off hand comes in from 30 cm in front of it, 2 cm every 3 tics, holds, and goes back
s += 'echo RLP_POUCH; '
x, y, z0 = -0.18, E - 0.64, -0.22
for k in range(16):
    s += lh(x, y, z0 - 0.30 + 0.02 * k) + '; wait 3; '
s += 'wait 30; '
for k in range(16):
    s += lh(x, y, z0 - 0.02 * k) + '; wait 3; '
s += RL + '; wait 40; '
# 2. reload lengths, main hand (the gun's own reload: rsr_reload 0), 10 rounds out of the magazine each time
def main_reload(tag, cmds, tail=230):
    return 'echo %s; %s give Clip2 30; take RifleAmmo 10; wait 5; ' % (tag, cmds) + reload_key() + 'wait %d; ' % tail
s += main_reload('RLP_FIXED_1200', 'set rsqsm_reload_len 0; set rsqsm_reload_ms 1200;')
s += main_reload('RLP_UNTIL', 'set rsqsm_reload_len 1;')
s += main_reload('RLP_BOTH_3000', 'set rsqsm_reload_len 2; set rsqsm_reload_ms 3000;')
s += main_reload('RLP_BOTH_600', 'set rsqsm_reload_len 2; set rsqsm_reload_ms 600;')
# 3. dual: BD's Dual key with the Rifle in the main hand (BD's own: the off hand gets its copy)
s += 'echo RLP_DUAL_SETUP; +user3; wait 8; -user3; wait 120; '
# 4. hands: the off hand's flick reload with Off Hand Only, then with Main Hand Only (no slow motion), then both at once
s += 'echo RLP_OFF_ONLY; set rsqsm_reload_len 1; set rsqsm_reload_hand 2; give Clip2 30; take RifleAmmoOff 10; wait 5; ' + flick('l') + 'wait 200; '
s += 'echo RLP_MAIN_ONLY_OFF_FLICK; set rsqsm_reload_hand 1; give Clip2 30; take RifleAmmoOff 10; wait 5; ' + flick('l') + 'wait 200; '
s += 'echo RLP_BOTH_HANDS; set rsqsm_reload_hand 3; give Clip2 60; take RifleAmmoOff 10; take RifleAmmo 10; wait 5; ' + flick('rl') + 'wait 250; '
s += 'set rsqsm_reload_hand 0; '
# 5. Tactical Rig: the main hand to its fists, the Rifle's copy stays in the off hand; Dual held 20 tics -> main gets the Rifle
s += 'echo RLP_MAIN_EMPTY; use Melee_Attacks; wait 120; echo RLP_DUAL_TO_MAIN; +user3; wait 20; -user3; wait 150; '
# 6. BD's own Dual again (a gun in each hand: the off hand goes back to its empty hand), untouched
s += 'echo RLP_DUAL_BD_OWN; +user3; wait 8; -user3; wait 150; '
# 7. the hard cap: Real VR Reload on, the hand reload left waiting for a magazine (RSR_Wait), Until the Reload Ends: 10 s
s += 'echo RLP_CAP; set rsr_reload 1; set rsqsm_reload_len 1; set rsqsm_reload_hand 0; give Clip2 30; take RifleAmmo 10; wait 5; ' + reload_key() + 'wait 420; echo RLP_END; quit'
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'script.txt'), 'w').write(s + '\n')
