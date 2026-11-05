#!/usr/bin/env python3
"""gen_gestcopy.py -- writes a series mod's OWN COPY of RSQ Gestures' readers (gestcopy_template.zs), used by that mod
only when RSQ Gestures is not loaded (owner 2026-11-04 19:45). Every copy comes from the one template, so they stay
identical; regenerate them all after changing it:

    python3 tools/gestcopy/gen_gestcopy.py            every mod in COPIES
    python3 tools/gestcopy/gen_gestcopy.py --check    exit 1 if a written copy differs from what the template makes

The template is itself a copy of Accessibility/zscript/rsqg/gestures.zs (RSQG_Handler) and pose.zs (RSQG_Pose). Every run
also checks every rsqg_* default the template reads against Accessibility/CVARINFO.txt (what Gestures really uses when it is
loaded; gestures.zs's own fallbacks can differ, e.g. rsqg_inspect_way 0 in code, 2 in CVARINFO), and that each cvar is
one Gestures reads, so the copies cannot drift from Gestures' numbers unnoticed.

Template lines: @IF PART@ / @IF !PART@ ... @END@ keep or drop whole lines; @P@ the class prefix, @MOD@ the mod's
name, @HS@ the mod's HandSync class (tools/handsync), @DBG@ the mod's debug cvar."""
import os, re, sys

HUB = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TEMPLATE = os.path.join(HUB, 'tools', 'gestcopy', 'gestcopy_template.zs')
# The gesture reader lives in RSQ Accessibility since 2026-11-05 (RSQ Gestures folded in, same class and cvar names).
GESTURES = os.path.join(HUB, 'Accessibility', 'zscript', 'rsqg', 'gestures.zs')
CVARINFO = os.path.join(HUB, 'Accessibility', 'CVARINFO.txt')

# out file, prefix, mod name, parts, HandSync class, debug cvar
COPIES = [
    ('GunCards/zscript/rsqgc/gestcopy.zs', 'RSQGC', 'RSQ Gun Cards', {'INSPECT'}, 'RSQGC_HandSync', 'rsqgc_debug_log'),
    ('TacticalRig/zscript/rsqtr/gestcopy.zs', 'RSQTR', 'RSQ Tactical Rig', {'INSPECT'}, 'RSQTR_HandSync', 'rsqtr_messages'),
    ('Melee/zscript/rsqml/gestcopy.zs', 'RSQML', 'RSQ Melee', {'PAIR'}, 'RSQML_HandSync', 'rsqml_debug'),
    ('Miniboss/zscript/rsqmb/gestcopy.zs', 'RSQMB', 'RSQ Miniboss', {'INSPECT'}, 'RSQMB_HandSync', 'rsqmb_debug'),
]


def render(prefix, mod, parts, hs, dbg):
    out, keep = [], [True]
    for line in open(TEMPLATE).read().split('\n'):
        m = re.fullmatch(r'\s*@IF (!?)(\w+)@\s*', line)
        if m:
            want = (m.group(2) in parts) != (m.group(1) == '!')
            keep.append(keep[-1] and want)
            continue
        if re.fullmatch(r'\s*@END@\s*', line):
            keep.pop()
            continue
        if keep[-1]:
            out.append(line.replace('@P@', prefix).replace('@MOD@', mod).replace('@HS@', hs).replace('@DBG@', dbg))
    assert len(keep) == 1, 'unbalanced @IF/@END@'
    text = '\n'.join(out)
    assert '@' not in re.sub(r'//.*', '', text), 'unreplaced marker'
    return text


def defaults(text):
    found = {}
    for name, val in re.findall(r'(?:Num|Opt)\("(rsqg_\w+)",\s*([-\d.]+)\)', text):
        found.setdefault(name, set()).add(float(val))
    return found


def cvarinfo():
    vals = {}
    for m in re.finditer(r'^\s*(?:user|server)\s+\w+\s+(rsqg_\w+)\s*=\s*([^;]+);', open(CVARINFO).read(), re.M):
        v = m.group(2).strip().lower()
        vals[m.group(1)] = 1.0 if v == 'true' else 0.0 if v == 'false' else float(v)
    return vals


def check_numbers():
    gtext = open(GESTURES).read()
    tpl, ci = defaults(open(TEMPLATE).read()), cvarinfo()
    bad = 0
    for name, vals in sorted(tpl.items()):
        if ('"%s"' % name) not in gtext:
            print('NOT READ BY GESTURES: %s' % name); bad += 1
        elif name not in ci:
            print('NOT IN GESTURES CVARINFO: %s' % name); bad += 1
        elif vals != {ci[name]}:
            print('DEFAULT DIFFERS: %s template %s, Gestures CVARINFO %s' % (name, sorted(vals), ci[name])); bad += 1
    print('%d rsqg_* defaults compared with Accessibility/CVARINFO.txt: %s' % (len(tpl), 'all equal' if not bad else '%d differ' % bad))
    return bad == 0


def main():
    check = '--check' in sys.argv
    ok = check_numbers()
    for rel, prefix, mod, parts, hs, dbg in COPIES:
        text = render(prefix, mod, parts, hs, dbg)
        path = os.path.join(HUB, rel)
        if check:
            same = os.path.exists(path) and open(path).read() == text
            print('%s %s' % ('same   ' if same else 'DIFFERS', rel))
            ok = ok and same
        else:
            open(path, 'w').write(text)
            print('wrote %s (%s_GCopy, %s)' % (rel, prefix, '+'.join(sorted(parts))))
    sys.exit(0 if ok else 1)


main()
