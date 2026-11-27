#!/usr/bin/env python3
"""stamp.py -- THE SERIES' SHARED CORE (2026-11-24). One master copy of each piece many mods need, stamped into every mod
under that mod's class prefix, so the copies cannot drift (the saber threw on a flick while the axe wanted a hard
swing: the same idea, copied, then changed in some copies only). No new pk3 and no dependency: every mod still loads
alone.

    python3 tools/core/stamp.py           write every copy from its master
    python3 tools/core/stamp.py --check   exit 1 if any copy differs from what its master makes (build_all.py runs this)

Masters:
  tools/handsync/handsync_template.zs  the frame-to-tic hand correction, a whole file per mod
  tools/core/fling_template.zs         ONE THROW (the hand's speed to throw, the launch multiplier), the class block
                                       <P>_Fling inside a mod's own file (the file's other code is the mod's)
  tools/gestcopy                       the gesture readers, checked by their own generator (gen_gestcopy.py --check)
Plus the values that live in other code and must agree with ONE THROW's MIN_MPS: the saber's throw-speed default
(QuestSaber CVARINFO) and BD22 VR's RSVR_Hand.THROW_MIN (its own repo, when it sits beside this one).
"""
import os, re, sys, subprocess

HUB = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

HANDSYNC = os.path.join(HUB, 'tools', 'handsync', 'handsync_template.zs')
HANDSYNC_COPIES = [
    ('DistanceGrab/zscript/rsqdg/handsync.zs', 'RSQDG'),
    ('FlashFlare/zscript/rsqff/handsync.zs', 'RSQFF'),
    ('Grapple/zscript/rsqgr/handsync.zs', 'RSQGR'),
    ('GunCards/zscript/rsqgc/handsync.zs', 'RSQGC'),
    ('Melee/zscript/rsqml/handsync.zs', 'RSQML'),
    ('Miniboss/zscript/rsqmb/handsync.zs', 'RSQMB'),
    ('QuestSaber/zscript/ubqs_handsync.zs', 'UBQS'),
    ('ShieldSaw/zscript/ssq/handsync.zs', 'SSQ'),
    ('TacticalRig/zscript/rsqtr/handsync.zs', 'RSQTR'),
    ('PlayLog/zscript/rsqpl/handsync.zs', 'RSQPL'),
]

FLING = os.path.join(HUB, 'tools', 'core', 'fling_template.zs')
FLING_COPIES = [
    ('FlashFlare/zscript/rsqff/handler.zs', 'RSQFF'),
    ('Grenade/zscript/rsqgn/hand.zs', 'RSQGN'),
    ('ShieldSaw/zscript/ssq/pose.zs', 'SSQ'),
    ('QuestSaber/zscript/ubqs_fling.zs', 'UBQS'),
]

SABER_CVARINFO = 'QuestSaber/CVARINFO'
SABER_CVAR = 'ubqs_throw_min'
BD22_HAND = os.path.join(os.path.dirname(HUB), 'wt_bd', 'src', 'zscript', 'rsvr', 'melee.zs')


def read(p):
    with open(p, encoding='utf-8', newline='') as f:
        return f.read()


def write(p, s):
    with open(p, 'w', encoding='utf-8', newline='') as f:
        f.write(s)


def fling_block(prefix):
    t = read(FLING)
    t = t[t.index('class @P@_Fling'):]
    return t.replace('@P@', prefix).rstrip('\n')


def class_span(text, cls):
    m = re.search(r'^class ' + re.escape(cls) + r'\b.*?^}', text, re.S | re.M)
    return (m.start(), m.end()) if m else None


def min_mps():
    m = re.search(r'const MIN_MPS = ([0-9.]+);', read(FLING))
    return float(m.group(1))


def main():
    check = '--check' in sys.argv
    bad = []
    for rel, p in HANDSYNC_COPIES:
        path = os.path.join(HUB, rel)
        if not os.path.isdir(os.path.join(HUB, rel.split('/')[0])):
            continue   # a sparse checkout: that mod is not here
        want = read(HANDSYNC).replace('@P@', p)
        if not os.path.exists(path) or read(path) != want:
            if check: bad.append(rel + ' (hand sync)')
            else: write(path, want); print('wrote', rel)
    for rel, p in FLING_COPIES:
        path = os.path.join(HUB, rel)
        if not os.path.exists(path):
            continue
        text = read(path)
        span = class_span(text, p + '_Fling')
        if not span:
            bad.append(rel + ' (no %s_Fling)' % p); continue
        want = text[:span[0]] + fling_block(p) + text[span[1]:]
        if text != want:
            if check: bad.append(rel + ' (one throw)')
            else: write(path, want); print('wrote', rel)
    mps = min_mps()
    saber = os.path.join(HUB, SABER_CVARINFO)
    if os.path.exists(saber):
        m = re.search(re.escape(SABER_CVAR) + r'\s*=\s*([0-9.]+)', read(saber))
        if not m or abs(float(m.group(1)) - mps) > 1e-6:
            bad.append('%s: %s is %s, ONE THROW is %s' % (SABER_CVARINFO, SABER_CVAR, m.group(1) if m else 'missing', mps))
    if os.path.exists(BD22_HAND):
        m = re.search(r'const THROW_MIN = ([0-9.]+);', read(BD22_HAND))
        if not m or abs(float(m.group(1)) - mps) > 1e-6:
            bad.append('BD22 VR melee.zs: THROW_MIN is %s, ONE THROW is %s' % (m.group(1) if m else 'missing', mps))
    gest = os.path.join(HUB, 'tools', 'gestcopy', 'gen_gestcopy.py')
    if check and os.path.exists(gest):
        r = subprocess.run([sys.executable, gest, '--check'], capture_output=True, text=True)
        if r.returncode != 0:
            bad.append('gesture readers: ' + (r.stdout + r.stderr).strip().splitlines()[-1])
    if bad:
        print('SHARED CORE: these differ from their master:\n  ' + '\n  '.join(bad))
        print('run python3 tools/core/stamp.py (or fix the value) and build again')
        sys.exit(1)
    if check:
        print('shared core: every copy matches its master')


if __name__ == '__main__':
    main()
