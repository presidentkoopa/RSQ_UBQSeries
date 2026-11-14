#!/usr/bin/env python3
"""TEST ONLY: the dying-body census (rcFcensus/).
    rcf_census.py gen rcf_classes.txt           write rcFcensus/zscript.txt (family|class|deathtype,...; 26 cells a row at most)
    rcf_census.py script FIRST LAST PASS         the console script of one run (rc2_full.sh)
    rcf_census.py sum RUN.log [RUN.log ...]      the counts: per status, per family, per snapshot; the misses listed
    rcf_census.py compare "BEFORE*.log" "AFTER*.log"   per family, before | after: the bodies that hold their colour (drawn
                                                 from the art, on the tint) and those that hold none"""
import sys, os, re, collections
HERE = os.path.dirname(os.path.abspath(__file__))
D = os.environ.get("RCF_OUT") or os.path.join(HERE, "rcFcensus")
BLEN = 148
if sys.argv[1] == 'gen':
    rows = []
    for l in open(sys.argv[2]):
        if not l.strip(): continue
        f, c, d = l.strip().split('|'); d = d.split(',')
        # at most 26 cells a batch (a class with 70 deaths at once could hang the rig: Labguy, HellTrooper)
        for i in range(0, len(d), 26): rows.append('%s|%s|%s' % (f, c, ','.join(d[i:i + 26])))
    tab = ',\n'.join('\t\t"%s"' % r for r in rows)
    src = open(os.path.join(HERE, 'rcf_census_zs.tpl')).read().replace('$TABLE$', tab)
    open(os.path.join(D, 'zscript.txt'), 'w').write(src)
    print('wrote zscript.txt, %d classes' % len(rows))
elif sys.argv[1] == 'script':
    a, b, p = map(int, sys.argv[2:5])
    print('; '.join(['god', 'notarget', 'wait 20', 'netevent rcc_run %d %d %d' % (a, b, p), 'wait %d' % ((b - a + 1) * BLEN + 30), 'wait 10', 'quit']))
elif sys.argv[1] == 'sum':
    fam = {}; tot = collections.Counter(); byfam = collections.defaultdict(collections.Counter); det = collections.Counter()
    cls_of = {}
    for f in sys.argv[2:]:
        for L in open(f, errors='replace'):
            m = re.match(r'RCC b(\d+) (\S+)\|(\S+) cells', L)
            if m: cls_of[(f, m.group(1))] = (m.group(2), m.group(3)); continue
            m = re.match(r'RCCS b(\d+) s(\d) x(\d+) (\S+) (.*)', L.strip())
            if not m: continue
            fm, cl = cls_of.get((f, m.group(1)), ('?', '?'))
            n = int(m.group(3)); st = m.group(4)
            tot[st] += n; byfam[fm][st] += n
            if not st.startswith(('ART', 'hidden', 'ownlook', 'LIVE-col')) or 'WRONG' in st:
                det[(st, cl, m.group(5))] += n
    keys = ['ART', 'TINT-L', 'TINT-S', 'OTHER', 'MISS', 'OWNART', 'LIVE-none', 'LIVE-entry']
    print('status totals (actor-snapshots, 5 snapshots a kill):')
    for k, v in sorted(tot.items(), key=lambda x: -x[1]): print('  %-18s %d' % (k, v))
    print('\nper family:  ' + '  '.join('%8s' % k for k in keys) + '   WRONG')
    for fm in sorted(byfam):
        c = byfam[fm]
        print('%-18s' % fm + '  '.join('%8d' % sum(v for s, v in c.items() if s.split('+')[0] == k) for k in keys) + '   %d' % sum(v for s, v in c.items() if 'WRONG' in s))
    print('\ndetails (status, root class, what):')
    for (st, cl, w), n in sorted(det.items(), key=lambda x: (x[0][0], x[0][1])): print('  %-12s %-24s %-60s x%d' % (st, cl, w, n))
elif sys.argv[1] == 'compare':
    import glob
    FX = ('blood', 'mist', 'gore', 'smearer', 'smoke', 'flame', 'flare', 'spark', 'puff', 'splash', 'steam', 'fog', 'particle',
          'explosion', 'fire', 'ember', 'crater', 'shard', 'junk', 'metal', 'plasma', 'shock', 'icechunk')
    def load(pat):
        byfam = collections.defaultdict(collections.Counter); left = collections.Counter(); cls_of = {}; classes = set()
        for f in sorted(glob.glob(pat)):
            for L in open(f, errors='replace'):
                m = re.match(r'RCC b(\d+) (.+?)\|(\S+) cells', L)
                if m: cls_of[(f, m.group(1))] = (m.group(2), m.group(3)); classes.add(m.group(3)); continue
                m = re.match(r'RCCS b(\d+) s(\d) x(\d+) (\S+) (\S+)(.*)', L.strip())
                if not m: continue
                fm, cl = cls_of.get((f, m.group(1)), ('?', '?'))
                n = int(m.group(3)); st = re.split(r'[+~]', m.group(4))[0]; nm = m.group(5)
                if '+WRONG' in m.group(4): byfam[fm]['wrong cell'] += n
                if st == 'OWNART' and any(x in nm.lower() for x in FX): st = 'own (blood/fx)'
                k = {'ART': 'art', 'TINT-L': 'tint', 'TINT-S': 'tint', 'OTHER': 'other', 'MISS': 'NONE', 'LIVE-none': 'NONE',
                     'LIVE-entry': 'NONE (stage)', 'OWNART': 'NONE (named fx)'}.get(st)
                if not k: continue
                byfam[fm][k] += n
                if k.startswith('NONE') or k == 'tint':
                    left[(k, cl, nm, m.group(6).split()[0][:4] if m.group(6).split() else '')] += n
        return byfam, left, classes
    b, bl, bc = load(sys.argv[2]); a, al, ac = load(sys.argv[3])
    K = ['art', 'tint', 'other', 'NONE', 'NONE (stage)', 'NONE (named fx)', 'wrong cell']
    print('classes: before %d, after %d' % (len(bc), len(ac)))
    print('%-18s' % 'family' + ''.join('%22s' % k for k in K))
    tb = collections.Counter(); ta = collections.Counter()
    for fm in sorted(set(b) | set(a)):
        print('%-18s' % fm + ''.join('%22s' % ('%d | %d' % (b[fm][k], a[fm][k])) for k in K))
        tb.update(b[fm]); ta.update(a[fm])
    print('%-18s' % 'ALL' + ''.join('%22s' % ('%d | %d' % (tb[k], ta[k])) for k in K))
    print('\nleft after (no colour, or the tint), by class and sprite:')
    agg = collections.Counter()
    for (k, cl, nm, spr), n in al.items(): agg[(k, nm, spr)] += n
    for (k, nm, spr), n in sorted(agg.items(), key=lambda x: (x[0][0], -x[1])): print('  %-16s %-40s %-5s %d' % (k, nm, spr, n))
