#!/usr/bin/env python3
"""TEST ONLY: the console script of one rcD rig run (rcDdemo): rows of a class from as shipped to White, each posed front,
side, attack, killed and frozen while dying, then dead; each pose held twice, once with the art (marker red) and once
with rsq_mon_art 0 (the live tint, marker blue), for rcD_sheets.py.

    rcD_script.py CLASS X SPACING PER_ROW ATTACK_LETTER FREEZE_TICS [PLAYER_X ROW_Y]
"""
# marks: row*100 + phase*2 + (0 art, 1 tint); phases 0 front, 1 side, 2 attack, 3 dying (frozen), 4 dead
import sys
cls, X, SP, PER, ATK, DF = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5], int(sys.argv[6])
PX, PY = (int(sys.argv[7]), int(sys.argv[8])) if len(sys.argv) > 8 else (-500, 0)
rows = []
if len(sys.argv) > 9:
    for r in sys.argv[9].split(','):
        a, b = map(int, r.split('-')); rows.append((a, b - a + 1))
else:
    r = 1
    while r <= 13: rows.append((r, min(PER, 14 - r))); r += PER
s = ['wait 20', 'god', 'notarget', 'netevent rcd_rowy %d' % PY, 'netevent rcd_place %d %d 0' % (PX, PY), 'netevent rcd_light 224']
def snap(m):
    s.extend(['wait 4', 'netevent rcd_mark %d' % m, 'wait 30', 'netevent rcd_unmark', 'set rsq_mon_art 0', 'wait 4', 'netevent rcd_mark %d' % (m + 1), 'wait 30', 'netevent rcd_unmark', 'set rsq_mon_art 1'])
for i, (first, n) in enumerate(rows):
    s += ['netevent rcd_row:%s %d %d %d' % (cls, X, SP, first + 100 * n), 'wait 25', 'netevent rcd_tier', 'wait 5', 'netevent rcd_tier', 'wait 3', 'netevent rcd_calm', 'wait 8',
          'netevent rcd_place %d %d 0' % (PX, PY), 'netevent rcd_face 0 -1']
    snap(i * 100 + 0)
    s += ['netevent rcd_face 90 -1']; snap(i * 100 + 2)
    s += ['netevent rcd_face 0 %d' % (ord(ATK) - 65)]; snap(i * 100 + 4)
    s += ['netevent rcd_kill 0 %d' % DF, 'wait %d' % (DF + 2)]; snap(i * 100 + 6)
    s += ['netevent rcd_go', 'wait 260', 'netevent rcd_freeze']; snap(i * 100 + 8)
s += ['wait 40', 'quit']
print(';'.join(s))
