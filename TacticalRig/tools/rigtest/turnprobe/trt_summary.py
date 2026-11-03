#!/usr/bin/env python3
# TEST ONLY. trt_summary.py <battery output>: one line a segment from trt_battery.sh output (evidence/*.txt).
import re,sys
lines=open(sys.argv[1]).read().splitlines()
for l in lines:
    if l.startswith('=='):
        print(l); continue
    m=re.match(r'(\S+)\s+tracking\s+(\S+)\s+rig\s+(\S+) \(rig-tracking\s+(\S+)\)\s+shield\s+(\S+) \(shield-tracking\s+(\S+), shield-rig\s+(\S+)\)(.*)',l)
    if not m: continue
    seg,tk,rg,rt,sh,st,sr,ex=m.groups()
    if seg=='TRT_START': continue
    if 'SNAP' in seg:
        e=re.search(r'pawn step (\S+) at \+\d+, rig over it\s+(\S+), shield over it\s+(\S+)',ex)
        es = ('pawn step %s, rig %s, shield %s' % e.groups()) if e else 'no snap reached pawn'
        print('  %-20s trk %8s rig %8s shield %8s | %s' % (seg,tk,rg,sh,es))
    elif 'ROOM' in seg:
        print('  %-20s rig %8s shield %8s %s' % (seg,rg,sh,ex.replace('  | room:','|')))
    else:
        print('  %-20s trk %8s rig %8s (r-t %s) shield %8s (s-t %s)' % (seg,tk,rg,rt,sh,st))
