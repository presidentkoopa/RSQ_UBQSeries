#!/usr/bin/env python3
"""Regenerate KEYCONF.txt's `rsqwp_reset` alias (Reset All) from CVARINFO.txt's defaults."""
import os
R = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
import re
# <scope> [flags] <type> <name> = <value>;  -- noarchive (test-only) cvars are left out; a string keeps its quotes
cmds = []
for l in open(os.path.join(R, 'CVARINFO.txt')):
    m = re.match(r'^(server|user)\s+((?:\w+\s+)*?)(bool|int|float|string|color)\s+(\w+)\s*=\s*("[^"]*"|[^;\s]+)\s*;', l)
    if not m or 'noarchive' in m.group(2): continue
    v = m.group(5).replace('true', '1').replace('false', '0')
    cmds.append("%s %s" % (m.group(4), v.replace('"', '\\"')))
p = os.path.join(R, 'KEYCONF.txt'); k = open(p).read()
i = k.index('alias rsqwp_reset')
j = k.index('\n', i)
k = k[:i] + 'alias rsqwp_reset "' + '; '.join(cmds) + '"' + k[j:]
open(p, 'w').write(k); print(len(cmds), 'cvars')
