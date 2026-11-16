#!/bin/bash
# build.sh [out]: the word-motion lane's RSQ_VisualRewards.pk3 from this worktree, the way tools/build_all.py builds it
# ('sub' mode: everything in pk3/ + README.md, sorted, deflated), and the probe pk3 (test only, never ships)
H=$(cd "$(dirname "$0")/../.." && pwd); O=${1:-/home/claude/rig/work/wm}; mkdir -p $O
python3 -I - "$H" "$O/RSQ_VisualRewards.pk3" <<'PY'
import os, sys, zipfile
src, out = sys.argv[1], sys.argv[2]
ent = []
for d, _, fs in os.walk(os.path.join(src, 'pk3')):
    for f in fs:
        full = os.path.join(d, f); ent.append((full, os.path.relpath(full, os.path.join(src, 'pk3')).replace(os.sep, '/')))
ent.append((os.path.join(src, 'README.md'), 'README.md'))
ent.sort(key=lambda e: e[1])
if os.path.exists(out): os.remove(out)
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for f, r in ent: z.write(f, r)
print(out, len(ent))
PY
P=$H/test/wordmotion; rm -f $O/wmprobe.pk3
(cd $P && zip -q -X $O/wmprobe.pk3 zscript.txt MAPINFO.txt CVARINFO.txt) && echo $O/wmprobe.pk3
