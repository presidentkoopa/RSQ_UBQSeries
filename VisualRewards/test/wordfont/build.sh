#!/bin/bash
# build the word-font lane's RSQ_VisualRewards.pk3 from /home/claude/wt_wordfont (tools/build_all.py's 'sub' mode: pk3/ + README.md)
W=/home/claude/wt_wordfont/VisualRewards; O=${1:-/tmp/wfbuild}; mkdir -p $O
python3 -I - "$W" "$O/RSQ_VisualRewards.pk3" <<'PY'
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
