#!/usr/bin/env python3
"""track_report.py -- what BD's actor shows, tic by tic, beside what RSQ Gore will play, per phase 1 card.

    python -I Gore/tools/track_report.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>

BD's side is simulated afresh from BD's DECORATE (cards.explore / cards.timeline: every random branch of the Spawn
state, with its odds; a drop whose Spawn tests waterlevel also under water; for a hit blood its puff along every
blood-level route: its own path, or what it showed before BD's intensity script acted and then the level's state to
LowBlood's Stop, and the SlaughterCounter jump). Our side is read back from the GENERATED zscript/rsqgo/cards.zs
(AddVar / AddPuff + AddKf), i.e. exactly what the emitter's VisualThinkers will play. For each track: start tic, life,
frames shown, the scale (|x*y| square root) at the first and last visible keyframe, the alpha at the first and last,
mirrored, Bright. Every difference is marked "<<" and counted at the end. Writes Gore/generated/track_report.txt;
read-only on everything else.
"""
import math
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cards  # noqa: E402
import gen_gore  # noqa: E402


def geo(f):
    return math.sqrt(abs(f['sx'] * f['sy'])) if f['sx'] and f['sy'] else abs(f['sx'] or f['sy'])


def summarise(w, fr, end, loop, sprites):
    """One BD branch as it shows, or None: the life runs to `end` (BD's removal), or to the end of its last visible
    frame if it shows nothing after, or to the first frame whose sprite exists in neither pack (BD draws nothing)."""
    if not fr:
        return None
    start = fr[0]['t']
    if end is None:
        end = start + cards.LIFE_CAP
    shown = []
    for f in fr:
        if cards.frame_lump(sprites, f['spr'], f['fr'])[0] is None:
            end = min(end, f['t'])
            break
        shown.append(f)
    if not shown:
        return None
    if not loop:
        end = min(end, shown[-1]['t'] + shown[-1]['tics'])
    return (w, start, end - start, len(shown), geo(shown[0]), geo(shown[-1]), shown[0]['alpha'], shown[-1]['alpha'],
            shown[0]['sx'] < 0, any(f['bright'] for f in shown))


def bd_tracks(world, key, label, sprites, ctx=None):
    """BD's branches for a label, as they SHOW: [(w, start, life, nframes, s0, s1, a0, a1, mirror, bright)]."""
    out = []
    for p in cards.explore(world, key, label, ctx or cards.Ctx()):
        tl = cards.timeline(world, key, p)
        r = summarise(p['w'], tl['frames'], tl['end_t'], tl['end'][0] == 'loop', sprites)
        if r:
            out.append(r)
    return out


def bd_route(world, key, sprites, own, at, label, ctx):
    """BD's puff along one blood-level route: what each own branch showed before the script acted at `at` (cut there),
    then the label's states from the scale and alpha that branch had then, to LowBlood's Stop."""
    out = []
    for po in own:
        tl_o = cards.timeline(world, key, po)
        pre = [dict(f, tics=min(f['tics'], at - f['t'])) for f in tl_o['frames'] if f['t'] < at]
        sd = cards.timeline(world, key, {'w': 1.0, 'steps': [x for x in po['steps'] if x[2] <= at],
                                         'end': ('stop', at)})['seed_end']
        for pr in cards.explore(world, key, label, ctx):
            tl_r = cards.timeline(world, key, pr, sd)
            fr = pre + [dict(f, t=f['t'] + at) for f in tl_r['frames']]
            end = at + tl_r['end_t'] if tl_r['end_t'] is not None else None
            r = summarise(po['w'] * pr['w'], fr, end, False, sprites)
            if r:
                out.append(r)
    return out


def our_tracks(zs, name):
    """Our tracks for a card, from the generated cards.zs: [(kind, w, start, life, nkf, s0, s1, a0, a1, mirror, bright,
    extra)]; extra: a puff's (route, raw), a drop track's wet flag."""
    m = re.search(r'// %s\n(.*?)(?=\n\t\t// |\n\t\}\n)' % re.escape(name), zs, re.S)
    if not m:
        return []
    out = []
    for kind, head, kfs in re.findall(r'Add(Var|Puff|Splash|WSplash)\(([^)]*)\);((?:\s*AddKf\([^)]*\);)*)', m.group(1)):
        hp = [x.strip() for x in head.split(',')]
        w, start, life = [float(x) for x in hp[:3]]
        extra = (int(hp[5]), False) if kind == 'Puff' else (len(hp) > 5 and hp[5] == 'true')
        rows = [[x.strip() for x in k.split(',')] for k in re.findall(r'AddKf\(([^)]*)\)', kfs)]
        vis = [r for r in rows if int(r[1]) >= 0]
        if not vis:
            continue
        g = lambda r: math.sqrt(abs(float(r[2]) * float(r[3]))) if float(r[2]) and float(r[3]) else abs(float(r[2]) or float(r[3]))
        out.append((kind, w, int(start), int(life), len(rows), g(vis[0]), g(vis[-1]), float(vis[0][4]), float(vis[-1][4]),
                    float(vis[0][2]) < 0, any(r[5] == 'true' for r in vis), extra))
    return out


def card_groups(world, key, name, zs, sprites, hit):
    """[(label, BD tracks, our tracks)] for one card."""
    groups = []
    if hit:
        # each blood-level route; BD's script acts two tics after a call made in the blood's first tick, one tic
        # after a later call (cards.py hit_card)
        own = cards.explore(world, key, 'Spawn', cards.Ctx())
        ev = cards.timeline(world, key, own[0])['events']
        acs = next(e for e in ev if e[0] == 'acs')[1]
        at = acs + (2 if acs == 0 else 1)
        routes = [(cards.R_LEVEL2, None, None), (cards.R_LOW, 'LowBlood', cards.Ctx()),
                  (cards.R_LOTS, 'LotsOfBlood', cards.Ctx()), (cards.R_ABSURD, 'AbsurdBlood', cards.Ctx()),
                  (cards.R_ANIMU, 'AbsurdBlood', cards.Ctx(take=('AnimuGore',)))]
        ours_all = [o for o in our_tracks(zs, name) if o[0] == 'Puff']
        slaughter = any(e[0] == 'tinv' and e[2].lower() == 'slaughtercounter' for e in ev)
        for raw in sorted({o[11][1] for o in ours_all}) or [False]:
            sfx = ' raw' if raw else ''
            for rid, lab, ctx in routes:
                mine = [o for o in ours_all if o[11] == (rid, raw)]
                if lab is None:
                    bdt = bd_tracks(world, key, 'Spawn', sprites)
                elif world.find_label(key, lab) is None:
                    continue
                else:
                    bdt = bd_route(world, key, sprites, own, at, lab, ctx)
                if rid == cards.R_ANIMU and not mine and not any(
                        e for e in cards.explore(world, key, 'AbsurdBlood', cards.Ctx())
                        if any('animugore' in world.cls[s[0]].states.S[s[1]]['action'].lower() for s in e['steps'])):
                    continue
                groups.append(('puff %s%s' % (cards.ROUTE_NAMES[rid], sfx), bdt, mine))
            if slaughter:
                mine = [o for o in ours_all if o[11] == (cards.R_SLAUGHTER, raw)]
                bdt = bd_tracks(world, key, 'Spawn', sprites, cards.Ctx(take=('SlaughterCounter',)))
                groups.append(('puff slaughter%s' % sfx, bdt, mine))
    else:
        ours_all = [o for o in our_tracks(zs, name) if o[0] == 'Var']
        groups.append(('spawn', bd_tracks(world, key, 'Spawn', sprites), [o for o in ours_all if not o[11]]))
        wet = [o for o in ours_all if o[11]]
        if wet:
            groups.append(('spawn under water', bd_tracks(world, key, 'Spawn', sprites, cards.Ctx(water=True)), wet))
    return groups


def main(argv):
    if len(argv) != 3:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    bd, xm = argv[1], argv[2]
    world, cat, rows = gen_gore.build(bd, xm)
    sprites = cards.load_sprites([(bd, 'BD'), (xm, 'XMVE')])
    zs = open(os.path.join(gen_gore.GORE, gen_gore.PHASE1_OUT['zscript']), encoding='utf-8').read()
    names = re.findall(r'^class RSQGO_K_(\w+) : (RSQGO_\w+)', zs, re.M)
    L, diffs = [], 0
    w = L.append
    w('RSQ Gore track report -- GENERATED by Gore/tools/track_report.py. BD = simulated from BD\'s DECORATE; OURS = the')
    w('generated cards.zs the VisualThinkers play. Columns: odds, start tic, life (tics), frames/keyframes, scale first>last,')
    w('alpha first>last, M = mirrored at the start, B = a Bright frame. "<<" marks a difference.')
    w('')
    for name, base in names:
        key = name.lower()
        groups = card_groups(world, key, name, zs, sprites, base == 'RSQGO_HitBlood')
        if not any(g[1] or g[2] for g in groups):
            w('%s (spawn)' % name)
            w('   (shows nothing: a spawner or a checker)')
            continue
        for label, bdt, ours in groups:
            w('%s (%s)' % (name, label))
            # BD's branches merge where they show the same; compare by (start, life, scale, alpha, mirror) sets
            bset = {}
            for b in bdt:
                k = (b[1], b[2], round(b[4], 3), round(b[5], 3), round(b[6], 3), round(b[7], 3), b[8], b[9])
                bset[k] = bset.get(k, 0) + b[0]
            oset = {}
            for o in ours:
                k = (o[2], o[3], round(o[5], 3), round(o[6], 3), round(o[7], 3), round(o[8], 3), o[9], o[10])
                oset[k] = oset.get(k, 0) + o[1]
            for k in sorted(set(bset) | set(oset), key=str):
                mark = '' if (k in bset and k in oset and abs(bset[k] - oset[k]) < 0.01) else '  <<'
                if mark:
                    diffs += 1
                row = 'start %3d life %3d scale %.3f>%.3f alpha %.3f>%.3f %s%s' % (
                    k[0], k[1], k[2], k[3], k[4], k[5], 'M' if k[6] else '-', 'B' if k[7] else '-')
                w('   BD %-5s OURS %-5s %s%s' % ('%.2f' % bset[k] if k in bset else '--',
                                                 '%.2f' % oset[k] if k in oset else '--', row, mark))
            if not bdt and not ours:
                w('   (shows nothing here)')
    w('')
    w('== %d difference(s)' % diffs)
    out = os.path.join(gen_gore.GORE, 'generated', 'track_report.txt')
    with open(out, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(L) + '\n')
    print('wrote %s (%d cards, %d differences)' % (out, len(names), diffs))
    for ln in L:
        if ln.endswith('<<'):
            print(ln)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
