#!/usr/bin/env python3
"""gen_gestcopy.py -- writes a series mod's OWN gesture reader (gestcopy_template.zs) into each mod that needs one
(owner 2026-11-04 19:45). The reader began as RSQ Gestures', folded into RSQ Accessibility 11-05; Accessibility was removed
2026-11-27 (owner: "remove the whole mod"), so these copies are the only readers, with that reader's default numbers as
constants. Every copy comes from the one template, so they stay identical; regenerate them all after changing it:

    python3 tools/gestcopy/gen_gestcopy.py            every mod in COPIES
    python3 tools/gestcopy/gen_gestcopy.py --check    exit 1 if a written copy differs from what the template makes

Template lines: @IF PART@ / @IF !PART@ ... @END@ keep or drop whole lines; @P@ the class prefix, @p@ the same in lower
case (network event names), @MOD@ the mod's name, @HS@ the mod's HandSync class (tools/handsync), @DBG@ the mod's debug
cvar."""
import os, re, sys

HUB = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TEMPLATE = os.path.join(HUB, 'tools', 'gestcopy', 'gestcopy_template.zs')

# out file, prefix, mod name, parts, HandSync class, debug cvar
# PARTS: INSPECT the old watch check (the box reader), PAIR the two-hand events, LOOK the wrist checks by the rule of
# 2026-11-27 (owner: "Look at it, it shows"): the watch check and the pulse check from the wrist's face and your gaze.
# Gun Cards is the wrist checks' home since 2026-11-27; RSQ Boss carries the same part as its fallback without Gun Cards.
# A copy takes INSPECT or LOOK, never both (they share names). Tactical Rig's copy is still INSPECT: its own pass moves it.
COPIES = [
    ('GunCards/zscript/rsqgc/gestcopy.zs', 'RSQGC', 'RSQ Gun Cards', {'LOOK'}, 'RSQGC_HandSync', 'rsqgc_debug_log'),
    ('TacticalRig/zscript/rsqtr/gestcopy.zs', 'RSQTR', 'RSQ Tactical Rig', {'INSPECT'}, 'RSQTR_HandSync', 'rsqtr_messages'),
    ('Melee/zscript/rsqml/gestcopy.zs', 'RSQML', 'RSQ Melee', {'PAIR'}, 'RSQML_HandSync', 'rsqml_debug'),
    ('Miniboss/zscript/rsqmb/gestcopy.zs', 'RSQMB', 'RSQ Miniboss', {'LOOK'}, 'RSQMB_HandSync', 'rsqmb_debug'),
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
            out.append(line.replace('@P@', prefix).replace('@p@', prefix.lower()).replace('@MOD@', mod).replace('@HS@', hs).replace('@DBG@', dbg))
    assert len(keep) == 1, 'unbalanced @IF/@END@'
    text = '\n'.join(out)
    assert '@' not in re.sub(r'//.*', '', text), 'unreplaced marker'
    return text


def main():
    check = '--check' in sys.argv
    ok = True
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
