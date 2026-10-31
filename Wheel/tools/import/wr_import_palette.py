#!/usr/bin/env python3
"""RSQ Wheel: turn a downloaded palette into a WRPALS palette block, with a preview picture.

    python3 wr_import_palette.py <palette file> [--name Name] [--roles rolemap.txt]
                                 [--into <Wheel folder>] [--preview out.png] [--print]

Reads: .gpl (GIMP), .pal (JASC text, Microsoft RIFF, or raw 768 bytes), .hex / .txt (one RRGGBB a
line, lospec's export), .ase (Adobe swatches: RGB, Gray, CMYK), .act, a Doom PLAYPAL lump (.lmp)
or the PLAYPAL inside a .wad / .pk3, and a PNG swatch strip or grid.

HOW COLOURS GO TO ROLES (all automatic; a role map file overrides any of it):
  Each of the ring's roles (wr_q_look.zs ROLES) has its own colour in the ring (ROLE_COLS) and a
  place on the light-dark scale: card faces and sheet backgrounds are DARK, numbers and dim text are
  MID, words, the hover glow and the laser are BRIGHT. The palette's colours are put on the same
  scale (its darkest is 0, its lightest 1). Each role then takes the palette colour, from its own
  part of the scale, that is closest to the ring's own colour for that role (OKLab, lightness and
  hue both counted). So: dark -> idle / dry / sheet_bg, a bright warm accent -> hover, the reddest
  bright -> laser and ammo_dry, the greenest -> delta_up, the bluest -> slot4 / alt_bar, and so on.
  The nine slot colours try not to repeat while the palette has enough colours.
  Roles the ring draws in ONE colour move together (hover = sheet_hot; slot4 = alt_bar =
  sheet_cool): the importer always gives them the same colour, since the ring would otherwise keep
  only the last one written.

ROLE MAP FILE (optional, one role a line, # comments):
    hover   5           the palette's colour number 5 (numbers as in the preview, from 0)
    laser   FF2010      a colour of your own
    idle    name:Navy   a named swatch (.gpl / .ase names)
    sheet_bg keep       leave it out: the ring keeps its own colour for that role
"""
import argparse, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wr_common import read_palette, oklab, hexrgb, clean_name, upsert_block, add_menu_choice, names_in, BUILTIN_PALETTES

# The ring's roles and their own colours, as wr_q_look.zs has them (ROLES / ROLE_COLS).
ROLES = ["idle", "hover", "label", "sub", "beam_idle", "dry", "ammo", "ammo_dry", "alt_bar",
         "mark_mine", "mark_other", "slotnum", "stack",
         "slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8", "slot9",
         "sheet_bg", "sheet_bg2", "sheet_accent", "sheet_text", "sheet_dim", "sheet_hot", "sheet_cool",
         "sheet_meas", "sheet_lock", "delta_up", "delta_down", "laser"]
ROLE_COLS = [0x2E3440, 0xEF9F27, 0xD8DEE9, 0x4A3A20, 0x5A6C7A, 0x3A2226, 0x8C97A8, 0xC65C5C, 0x4FA3D1,
             0x6E7684, 0xEFC94C, 0x5F6874, 0xC98A3A,
             0x8A8F98, 0xE8C547, 0xE07A3E, 0x4FA3D1, 0xD1503F, 0x7B5FD1, 0x3FBF6F, 0xD14F9B, 0x46C6C0,
             0x0E1016, 0x1B2030, 0x7F77DD, 0xE8EAF0, 0x8D93A3, 0xEF9F27, 0x4FA3D1,
             0x5DCAA5, 0xBE3E4E, 0x66DD66, 0xDD5555, 0xFF3030]
# Where each role sits on the palette's own light-dark scale.
DARK = {"idle", "sub", "dry", "sheet_bg", "sheet_bg2", "beam_idle"}
MID = {"ammo", "mark_mine", "slotnum", "sheet_dim", "slot1"}
# everything else is BRIGHT (words, accents, slot colours, the laser)
SLOTS = ["slot%d" % i for i in range(1, 10)]


def rgb_of(v):
    return ((v >> 16) & 255, (v >> 8) & 255, v & 255)


def assign(cols):
    """{role: index into cols} by the rule in the header."""
    labs = [oklab(c) for c in cols]
    Ls = [l[0] for l in labs]
    lo, hi = min(Ls), max(Ls)
    span = hi - lo if hi - lo > 0.05 else 1.0
    Ln = [(L - lo) / span for L in Ls]
    dlabs = [oklab(rgb_of(v)) for v in ROLE_COLS]
    dlo, dhi = min(l[0] for l in dlabs), max(l[0] for l in dlabs)
    n = len(cols)

    def tier_members(role):
        if role in DARK: want = [i for i in range(n) if Ln[i] <= 0.45]
        elif role in MID: want = [i for i in range(n) if 0.2 <= Ln[i] <= 0.85]
        else: want = [i for i in range(n) if Ln[i] >= 0.5]
        return want or list(range(n))

    out, used = {}, {}
    by_colour = {}
    # slots last, so the fixed roles take their best colours first; slot4 is in a shared group
    order = [r for r in ROLES if r not in SLOTS] + SLOTS
    for role in order:
        k = ROLES.index(role)
        dc = ROLE_COLS[k]
        if dc in by_colour:
            out[role] = by_colour[dc]; continue
        dl = dlabs[k]
        tL = (dl[0] - dlo) / (dhi - dlo)
        best, bi = None, 0
        for i in tier_members(role):
            L, a, b = labs[i]
            wc = 3.0 if role in DARK else 8.0     # hue counts for more where the colour is meant to be seen
            # a palette colour MORE vivid than the ring's own counts as that vivid (so a bright
            # red is still the best red for a muted-red role); only its hue and lightness then count
            C, Cd = (a * a + b * b) ** 0.5, (dl[1] ** 2 + dl[2] ** 2) ** 0.5
            if Cd > 0.08 and C > Cd: a, b = a * Cd / C, b * Cd / C   # (greys keep the plain rule)
            d = 1.0 * (Ln[i] - tL) ** 2 + wc * ((a - dl[1]) ** 2 + (b - dl[2]) ** 2)
            if role in SLOTS: d += 0.04 * used.get(i, 0)
            if best is None or d < best: best, bi = d, i
        out[role] = bi
        by_colour[dc] = bi
        if role in SLOTS: used[bi] = used.get(bi, 0) + 1
    return out


def read_rolemap(path, cols):
    """{role: (r,g,b) or None for keep}"""
    res = {}
    for ln in open(path, encoding='utf-8'):
        ln = ln.split('#')[0].strip()
        if not ln: continue
        role, val = (ln.split(None, 1) + [''])[:2]
        role, val = role.lower(), val.strip()
        if role not in ROLES:
            print('  role map: no role "%s" in the ring; skipped' % role); continue
        if val.lower() == 'keep': res[role] = None
        elif val.lower() == 'auto': continue
        elif val.lower().startswith('name:'):
            nm = val[5:].strip().lower()
            hit = [c for c in cols if c[3] and c[3].lower() == nm]
            if hit: res[role] = hit[0][:3]
            else: print('  role map: no swatch named "%s"; %s stays automatic' % (val[5:], role))
        elif len(val.lstrip('#')) == 6:
            h = val.lstrip('#'); res[role] = (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
        elif val.isdigit() and int(val) < len(cols):
            res[role] = cols[int(val)][:3]
        else:
            print('  role map: cannot read "%s" for %s; it stays automatic' % (val, role))
    return res


def build(path, name=None, rolemap=None):
    cols = read_palette(path)
    pick = assign(cols)
    final = {r: cols[pick[r]][:3] for r in ROLES}
    src = {r: '#%d' % pick[r] for r in ROLES}
    if rolemap:
        over = read_rolemap(rolemap, cols)
        # a shared-colour group follows its overridden member
        for role, v in over.items():
            dc = ROLE_COLS[ROLES.index(role)]
            for r2 in ROLES:
                if ROLE_COLS[ROLES.index(r2)] == dc:
                    final[r2] = v; src[r2] = 'role map'
    name = name or clean_name(path)
    lines = ['// from %s (%d colours) by wr_import_palette.py' % (os.path.basename(path), len(cols)),
             'palette %s' % name, '{']
    for r in ROLES:
        if final[r] is None: continue
        lines.append('\t%-12s %s   // %s' % (r, hexrgb(final[r]), src[r]))
    lines.append('}')
    return name, cols, final, src, '\n'.join(lines) + '\n'


def tint(rgb, lum):
    """the ring's own recolouring of a WAD graphic (wr_q_shim.zs TransFor), for the preview"""
    v = min(1.0, lum * 2.2); g = min(255.0, lum * 255 * 0.45)
    return tuple(int(min(255, c * v + g)) for c in rgb)


def preview(name, cols, final, src, out):
    from PIL import Image, ImageDraw, ImageFont
    import random
    font = ImageFont.load_default()
    W = 720
    rows = (len(cols) + 31) // 32
    H = 40 + rows * 22 + 20 + ((len(ROLES) + 2) // 3) * 22 + 20 + 120
    im = Image.new('RGB', (W, H), (24, 24, 28))
    d = ImageDraw.Draw(im)
    d.text((8, 6), 'palette %s  (%d colours in the file; numbers as the role map uses them)' % (name, len(cols)), fill=(230, 230, 230), font=font)
    for i, c in enumerate(cols):
        x, y = 8 + (i % 32) * 22, 24 + (i // 32) * 22
        d.rectangle([x, y, x + 19, y + 19], fill=c[:3])
        l = oklab(c)[0]
        d.text((x + 2, y + 5), str(i), fill=(0, 0, 0) if l > 0.6 else (255, 255, 255), font=font)
    y0 = 24 + rows * 22 + 16
    for k, r in enumerate(ROLES):
        x, y = 8 + (k % 3) * 238, y0 + (k // 3) * 22
        c = final[r]
        if c is None:
            d.text((x, y + 4), '%-12s (ring keeps its own)' % r, fill=(150, 150, 150), font=font); continue
        d.rectangle([x, y, x + 36, y + 18], fill=c)
        d.text((x + 42, y + 4), '%-12s %s %s' % (r, hexrgb(c), src[r]), fill=(220, 220, 220), font=font)
    # a mock of cards as the ring tints them: stone grain (luminance 0.2-0.35) in each slot colour,
    # with the label colour across it
    y1 = y0 + ((len(ROLES) + 2) // 3) * 22 + 12
    d.text((8, y1), 'the slot colours on status-bar stone, tinted the way the ring tints it; words in "label":', fill=(220, 220, 220), font=font)
    rnd = random.Random(1)
    for s in range(9):
        c = final['slot%d' % (s + 1)] or rgb_of(ROLE_COLS[ROLES.index('slot%d' % (s + 1))])
        bx, by = 8 + s * 78, y1 + 18
        for yy in range(64):
            for xx in range(70):
                lum = 0.22 + 0.1 * rnd.random()
                im.putpixel((bx + xx, by + yy), tint(c, lum))
        d.text((bx + 6, by + 26), 'SLOT %d' % (s + 1), fill=final['label'] or (216, 222, 233), font=font)
    d.rectangle([8, y1 + 90, 8 + 700, y1 + 92], fill=final['laser'] or (255, 48, 48))
    d.text((8, y1 + 96), 'laser', fill=final['laser'] or (255, 48, 48), font=font)
    im.save(out)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('palette')
    ap.add_argument('--name', help='the palette name the ring shows (default: from the file name)')
    ap.add_argument('--roles', help='a role map file (see above)')
    ap.add_argument('--into', help='a Wheel folder: the block goes into its WRPALS.txt, the name into its menu')
    ap.add_argument('--preview', help='preview PNG path (default: <name>_palette.png beside --into/import_previews or here)')
    ap.add_argument('--print', action='store_true', help='print the block')
    a = ap.parse_args(argv)
    want = a.name or clean_name(a.palette)
    if want.lower() in [b.lower() for b in BUILTIN_PALETTES]:
        print('  "%s" is one of the ring\'s own palettes; this one is called %sImp' % (want, want))
        want += 'Imp'
    name, cols, final, src, block = build(a.palette, want, a.roles)
    if a.into:
        p = os.path.join(a.into, 'WRPALS.txt')
        upsert_block(p, 'palette', name, block)
        add_menu_choice(a.into, 'wr_Palettes', name, name)
        pv = a.preview or os.path.join(a.into, 'import_previews', '%s_palette.png' % name)
    else:
        pv = a.preview or '%s_palette.png' % name
    os.makedirs(os.path.dirname(os.path.abspath(pv)), exist_ok=True)
    preview(name, cols, final, src, pv)
    if a.print or not a.into: print(block)
    print('palette %s: %d colours read from %s; preview %s%s' % (
        name, len(cols), os.path.basename(a.palette), pv, (' ; written to ' + a.into) if a.into else ''))
    return name


if __name__ == '__main__':
    main()
