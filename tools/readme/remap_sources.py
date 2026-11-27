#!/usr/bin/env python3
"""Move a mod's docs/README_SOURCES.md line numbers after its code changed.

    python3 tools/readme/remap_sources.py <ModFolder> <git ref the numbers were right at> [ALIAS=path ...]

Every `name:123` or `name:123-130` cite whose file changed between the ref and the working tree is moved to the same
line's new number. A cited line that was deleted or rewritten is marked `(!)`: re-read it and fix the row by hand.
ALIAS=path gives the short names a sources file uses (e.g. Z=zscript/wheel/zscript.zs), relative to the mod folder.
"""
import difflib, os, re, subprocess, sys
mod, ref = sys.argv[1].rstrip('/'), sys.argv[2]
alias = dict(a.split('=', 1) for a in sys.argv[3:])
src = os.path.join(mod, 'docs', 'README_SOURCES.md')
text = open(src, encoding='utf-8').read()
maps, moved, gone = {}, 0, []
def mapping(name):
    if name in maps: return maps[name]
    path = os.path.join(mod, alias.get(name, name))
    m = None
    if os.path.isfile(path):
        old = subprocess.run(['git', 'show', '%s:%s' % (ref, path)], capture_output=True, text=True)
        if old.returncode == 0:
            a, b = old.stdout.splitlines(), open(path, encoding='utf-8', errors='replace').read().splitlines()
            m = {}
            for op, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
                for k in range(i2 - i1):
                    m[i1 + k + 1] = (j1 + k + 1) if op == 'equal' else None
    maps[name] = m
    return m
def rep(mo):
    global moved
    name, a, b = mo.group(1), int(mo.group(2)), mo.group(3)
    m = mapping(name)
    if m is None: return mo.group(0)
    na = m.get(a); nb = m.get(int(b[1:])) if b else None
    if na is None or (b and nb is None):
        gone.append(mo.group(0)); return mo.group(0) + '(!)'
    if na != a: moved += 1
    return '%s:%d%s' % (name, na, ('-%d' % nb) if b else '')
out = re.sub(r'(?<![\w/.])([\w./]+):(\d+)(-\d+)?(?!\(!\))', rep, text)
open(src, 'w', encoding='utf-8').write(out)
print('%s: %d cites moved, %d need a look: %s' % (src, moved, len(gone), ', '.join(gone)))
