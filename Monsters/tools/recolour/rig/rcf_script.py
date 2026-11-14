#!/usr/bin/env python3
"""TEST ONLY: the console script of one rcfam rig run (rcfam/zscript.txt), for rc2_full.sh.
    rcf_script.py CLASS_INDEX[:SPACING[:PER_ROW]] ...
Per class: rows of the as-shipped monster then Green .. White (PER_ROW to a row, default 7), at x -60 (260 units from
the player, rig01), sector light 224. Each pose is held with the art on, then again with rsq_mon_art 0 (the live tint), so
one run gives the new art and the old tint in the same frozen pose: front, side, attack (frozen 10 tics into its
missile or melee state), dying (frozen 16 tics after a plain death)."""
import sys
HOLD = 24
ROW = [0]
def row_script(cls, sp, first, n):
    base = ROW[0] * 8; ROW[0] += 1           # phase code = row * 8 + pose (1-8), shown by rcfam's marker (<= 15 rows)
    s = ['netevent rcf_row -60 %d %d' % (sp, first + 100 * n + 10000 * cls), 'wait 12', 'netevent rcf_tier', 'wait 12',
         'netevent rcf_tier', 'netevent rcf_calm', 'netevent rcf_light 224', 'netevent rcf_face 0 0', 'wait 10']
    for k, pose in enumerate(['netevent rcf_face 0 0', 'netevent rcf_face 90 0', 'netevent rcf_attack 10', 'netevent rcf_kill 0 16']):
        settle = 16 if k >= 2 else 4
        s += ['netevent rcf_phase 0', pose, 'wait %d' % settle, 'netevent rcf_phase %d' % (base + 2 * k + 1), 'wait %d' % HOLD,
              'netevent rcf_phase 0', 'rsq_mon_art 0', 'wait 4', 'netevent rcf_phase %d' % (base + 2 * k + 2), 'wait %d' % HOLD, 'rsq_mon_art 1']
    s += ['netevent rcf_phase 0']
    return s
out = ['god', 'notarget', 'wait 30', 'netevent rcf_clean 1', 'netevent rcf_light 224', 'wait 10', 'netevent rcf_phase 124', 'wait 10',
       'netevent rcf_phase 0']   # 124: the empty room (the cutter's background)
for arg in sys.argv[1:]:
    p = [int(x) for x in arg.split(':')]
    cls, sp, per = p[0], (p[1] if len(p) > 1 else 76), (p[2] if len(p) > 2 else 7)
    r = 1
    while r <= 13:
        n = min(per, 14 - r); out += row_script(cls, sp, r, n); r += n
out += ['wait 10', 'quit']
print('; '.join(out))
