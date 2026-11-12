"""Pack a pk3 tree and load it once on the QZD 17.3 rig: prints every script error with its message.
usage: compile_check.py <tree dir> [extra pk3 ...]   (a compile check, not a test: nothing here says anything works)"""
import sys, os, re, zipfile, tempfile
RIG = os.environ.get('RSQ_RIG', '/home/claude/presidentkoopa/rsq_meshturbator/rig')
sys.path.insert(0, RIG)
import rig
tree = sys.argv[1]
fd, pk = tempfile.mkstemp(suffix='.pk3'); os.close(fd)
with zipfile.ZipFile(pk, 'w', zipfile.ZIP_DEFLATED) as z:
    for r, d, fs in os.walk(tree):
        for f in fs:
            p = os.path.join(r, f); z.write(p, os.path.relpath(p, tree))
t = rig.run('compile_check', [pk] + sys.argv[2:], 'wait 5; quit', secs=180)
lines = t.splitlines(); n = 0; seen = set()
for i, l in enumerate(lines):
    if re.search(r'Script error|FATAL|unknown class|not found', l, re.I) and 'pw.conf' not in l:
        msg = l.strip() + ' | ' + (lines[i + 1].strip() if i + 1 < len(lines) else '')
        if msg in seen: continue
        seen.add(msg); print(msg[:220]); n += 1
        if n >= 60: break
print('RESULT: %s, %d distinct error lines' % ('reached MAP01' if 'MAP01' in t else 'did NOT reach MAP01', n))
os.remove(pk)
