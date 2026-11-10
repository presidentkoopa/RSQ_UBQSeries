#!/usr/bin/env python3
"""Regenerate KEYCONF.txt's `rsqgr_reset` alias (Reset All) from CVARINFO.txt's defaults."""
import os
R = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
cv = [l.split() for l in open(os.path.join(R, 'CVARINFO.txt')) if l.startswith('server') or l.startswith('user')]
# a string cvar ("443 436") is reset with resetcvar: its quotes would end the alias's own quoted text
cmds = [("resetcvar %s" % c[2]) if c[1] == 'string' else
        "%s %s" % (c[2], c[4].rstrip(';').replace('true', '1').replace('false', '0')) for c in cv]
p = os.path.join(R, 'KEYCONF.txt'); k = open(p).read()
i = k.index('alias rsqgr_reset')
j = k.index('\n', i)
k = k[:i] + 'alias rsqgr_reset "' + '; '.join(cmds) + '"' + k[j:]
open(p, 'w').write(k); print(len(cmds), 'cvars')
