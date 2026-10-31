#!/usr/bin/env python3
"""Regenerate KEYCONF's `wr_reset` alias (Reset All) from CVARINFO.txt: every Wheel setting back to
its CVARINFO default (resetcvar). wr_cfgver is left alone: it is the settings-update stamp, not a
setting, and resetting it would re-run every past update on the next map."""
import os
R = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SKIP = {'wr_cfgver', 'wr_slot_order'}   # wr_slot_order: the player's own gun order (dragged), not a setting
names = [l.split()[2] for l in open(os.path.join(R, 'CVARINFO.txt'))
         if l.startswith(('user', 'server')) and l.split()[2] not in SKIP]
p = os.path.join(R, 'KEYCONF'); k = open(p).read()
line = 'alias wr_reset "resetcvar ' + ' '.join(names) + '"'
if 'alias wr_reset ' in k:
    i = k.index('alias wr_reset '); j = k.index('\n', i); k = k[:i] + line + k[j:]
else:
    k = k.rstrip('\n') + '\n\n// Reset All (generated from CVARINFO by tools/gen_reset.py; wr_cfgver is not a setting)\n' + line + '\n'
open(p, 'w').write(k); print(len(names), 'cvars')
