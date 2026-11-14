#!/usr/bin/env python3
"""The owner's approved tier colours (Monsters/TRNSLATE.txt rs_bdtier_*, 2026-11-13 09:49), read from the file, and
the engine's own arithmetic for a GZDoom '%[r1,g1,b1]:[r2,g2,b2]' (desaturated) range, so a baked frame starts exactly
where the live tint is. One difference, on purpose: the engine takes the shade from the PALETTE entry the pixel is
nearest to; the bake takes it from the pixel itself, so a true-colour sprite keeps its own shading."""
import re

COLOURS = ['green', 'blue', 'purple', 'cyan', 'brown', 'yellow', 'fireblu', 'gray', 'red', 'abyss', 'black', 'white']

def load(trnslate_path):
    rec = {}
    for line in open(trnslate_path, encoding='latin-1'):
        m = re.match(r'\s*rs_bdtier_(\w+)\s*=\s*(.*)$', line)
        if not m: continue
        ranges = []
        for a, b, r1, g1, b1, r2, g2, b2 in re.findall(
                r'"(\d+):(\d+)=%\[([\d.]+),([\d.]+),([\d.]+)\]:\[([\d.]+),([\d.]+),([\d.]+)\]"', m.group(2)):
            ranges.append((int(a), int(b), tuple(map(float, (r1, g1, b1))), tuple(map(float, (r2, g2, b2)))))
        rec[m.group(1)] = ranges
    return rec

def table(ranges):
    """palette index -> (c1, c2) for the indices this colour remaps; the rest keep their own."""
    t = {}
    for a, b, c1, c2 in ranges:
        for i in range(a, b + 1): t[i] = (c1, c2)
    return t

def shade(c1, c2, intensity):
    """GZDoom FRemapTable::AddDesaturation: start*255 + intensity*(end-start), intensity = (77r+143g+37b)/256 (0..255)."""
    out = []
    for s, e in zip(c1, c2):
        s = min(max(s, 0.0), 2.0); e = min(max(e, 0.0), 2.0)
        out.append(min(255, int(s * 255 + intensity * (e - s))))
    return out
