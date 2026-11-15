#!/usr/bin/env python3
"""RSQ Gun Cards: THE SMALL CARD DRAWN BY MODELS (owner 2026-11-15 05:22-05:57, option B: "Same card, drawn by models").

    python3 -I GunCards/tools/gen_modelcard.py

The same small card as tools/gen_cards.py bakes in voxels (same spot beside the wrist, the same JFO glyphs, Ermac's
panels, the same colours), but every piece is a MODEL whose animation frames are its glyphs, the way RemaSelaco draws
its ammo digits (RS_Selaco_VRWeapons/HANDOFF_SELACO_AMMO_DIGITS_2026-11-13.md). One change, the owner's: "the middle
portion, i'd like to have centered, relative to the rest": on the card with the word, the big count (and RELOAD) sits
centred between the word line and the reserve (measured from the glyphs' drawn rows, MIDDLE below).

WHY IT COSTS NO SPRITE FRAMES. QuestZDoom 17.3 makes sprite frames only from sprite graphics and voxels
(R_InitSpriteDefs); a sprite name that only a MODELDEF uses has no graphics, so it makes none, and a HUD model is found
by (caller class, sprite, frame) before any graphic is looked at. The voxel card spends one sprite frame per piece per
glyph per depth per mirror (9,906); this card spends none (measured on the rig: GunCards/docs/modelcard/).

HOW A PIECE PICKS ITS GLYPH. Each slot (the panel, the word, RELOAD, five big and five small digit places) is one MD3.
Its surface holds every glyph as its own quad, UV-mapped onto one atlas of the JFO glyphs; a frame unfolds one glyph's
quads and folds every other quad to a point (zero area, nothing drawn), as Selaco folds its unlit segments. The frames
run depth by depth (the 13 baked In places, as the voxel card's DEPTHS) and, for the big digits, tall card / short card.
MODELDEF maps sprite + letter to the frame; the layer's state is that sprite + letter.

THE MIRRORED HAND WITHOUT MORE FRAMES. The engine draws the physical left hand mirrored. Every glyph has two quads in
the same frame: the plain one and its mirror twin (picture flipped, place within the card mirrored), the twin wound the
other way round. The blocks set ForceCullBackfaces, so on an unmirrored hand only the plain quad faces front and on a
mirrored hand only the twin does: one set of frames serves both hands (the voxel card bakes every piece twice).

COLOURS. The skins are the glyphs in their own colours, as the voxels are; the count's green / yellow / red, the gold
reserve, the grey word and the red RELOAD come from the layer's translation exactly as on the voxel card (card.zs
TransFor). The panel colour is the skin: one MODELDEF block per Ermac panel (18), as the voxel card has one frame each.

WHO OWNS THE LAYERS. MODELDEF is keyed by the class of the layer's caller. The main hand's card is owned by
RSQGC_CardItem (blocks in MODELDEF.txt, here). The off hand's must be owned by the off-hand gun itself (the engine picks
the hand by that), so its blocks are keyed by the gun's class, and QuestZDoom 17.3 refuses a MODELDEF block for a class
that is not loaded (a fatal "Unknown actor type", rig 2026-11-15). So the off-hand blocks for BD22 VR's guns ship in a
pk3 of their own that only loads with BD22 VR: GunCards/bridge_bd22vr/ (tools/build_modelcard_bridge.sh).

THE PROOF (2026-11-15): one gun switches, BD22 VR's rifle: Rifle in the main hand, RSQ_Off_Rifle in the off hand
(MAIN_GUNS, OFF_GUNS). Every other gun keeps the voxel card.

Coordinates as gen_cards.py: model cm, X + the player's left (right hand), Y + toward the player, Z up. An MD3 vertex
is (x, y, z) = (-X, Y, Z): the engine maps a voxel and an MD3 to the same model space (models_voxel.cpp AddFace,
models_md3.cpp BuildVertexBuffer), and AngleOffset 90 cancels the HUD model's own quarter turn, as VOXELDEF's default does.
"""
import os, struct, sys, math
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import jfo
import gen_cards as gc

MDIR = os.path.join(ROOT, 'models', 'rsqgc', 'mc')
BRIDGE = os.path.join(ROOT, 'bridge_bd22vr')
PATH = 'models/rsqgc/mc'
MAIN_GUNS = ['Rifle']                 # main-hand guns that use the model card (the proof)
OFF_GUNS = ['RSQ_Off_Rifle']          # off-hand guns: their blocks go in the BD22 VR bridge
UPX = 4                               # skins upscaled by nearest neighbour (Quest glyphs x4, PCVR x2): the blocky voxel
                                      # look survives the renderer's texture filtering
GUTTER = 4                            # px between atlas cells (at the glyph's own resolution)
DEPTHS = gc.DEPTHS
DCH = '0123456789ABC'                 # depth index -> sprite character
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# ---- the layout (gen_cards.py's, the big count and RELOAD re-centred) ----------------------------------------------
CARD = gc.CARD
FRONT = gc.FRONT
PANEL_S = gc.PANEL_S
GLYPHS = gc.GLYPHS                    # 0-9, plus
CUT = 100                             # jfo_piece's alpha cut-out
PANEL_CUT = 60                        # card_piece's


def drawn_rows(im, cut=CUT):
    """the first and last drawn row of an image (alpha >= cut)"""
    a = im.split()[3].point(lambda v: 255 if v >= cut else 0)
    b = a.getbbox()
    return (b[1], b[3] - 1) if b else (0, im.size[1] - 1)


def span_z(im, sc, zc):
    """the drawn top and bottom (cm) of an image centred at zc, sc cm a pixel"""
    t, b = drawn_rows(im)
    h = im.size[1]
    return zc + (h / 2.0 - t) * sc, zc + (h / 2.0 - (b + 1)) * sc


def middle():
    """THE OWNER'S CHANGE (2026-11-15 05:57): the big count centred between the word line and the reserve. Measured on
    the PCVR glyphs (the Quest ones are the same size): the word's foot (the mean of AMMO's and MAGAZINE's), the
    reserve's top (the tallest digit), and the big count's drawn middle against its slot centre. Returns the big slots'
    new z and RELOAD's (its own drawn middle on the same line)."""
    feet = []
    for w in ('AMMO', 'MAGAZINE'):
        im = jfo.word(w, False)
        feet.append(span_z(im, gc.fit(im, gc.LABEL_BOX), gc.LABEL_AT[2])[1])
    foot = sum(feet) / len(feet)
    tops, mids = [], []
    for g in '0123456789':
        im = jfo.glyph('big', ord(g), False)[0]
        tops.append(span_z(im, gc.SMALL_S * 12 / im.size[1], gc.SMALL_AT[0][2])[0])
        t, b = span_z(im, gc.BIG_S * 12 / im.size[1], 0.0)
        mids.append((t + b) / 2.0)
    top = max(tops)
    want = (foot + top) / 2.0
    big_z = want - sum(mids) / len(mids)
    im = jfo.word('RELOAD', False)
    t, b = span_z(im, gc.fit(im, gc.RELOAD_BOX), 0.0)
    rel_z = want - (t + b) / 2.0
    old_t, old_b = span_z(jfo.glyph('big', ord('8'), False)[0], gc.BIG_S * 12 / 64.0, gc.BIG_AT[0][2])
    print('middle: word foot %.3f, reserve top %.3f -> count middle %.3f cm (was %.3f: gaps %.3f above / %.3f below, now %.3f / %.3f)'
          % (foot, top, want, (old_t + old_b) / 2, foot - old_t, old_b - top, foot - (want + 0.78), (want - 0.78) - top))
    return big_z, rel_z


# ---- MD3 ---------------------------------------------------------------------------------------------------------------
def enc_normal(n):
    x, y, z = n
    lat = int(round(math.acos(max(-1.0, min(1.0, z))) * 255 / (2 * math.pi))) & 255
    lng = int(round(math.atan2(y, x) * 255 / (2 * math.pi))) & 255
    return (lat << 8) | lng


def pad(s, n):
    b = s.encode()[:n - 1]
    return b + b'\0' * (n - len(b))


def write_md3(path, name, frames, st, tris):
    """one surface; frames = [[(x, y, z), ...] per frame], st = [(s, t)], tris = [(a, b, c)]"""
    nf, nv, nt = len(frames), len(frames[0]), len(tris)
    rad = max(math.sqrt(x * x + y * y + z * z) for fr in frames for (x, y, z) in fr)
    fblob = b''
    for i, fr in enumerate(frames):
        xs = [p[0] for p in fr]; ys = [p[1] for p in fr]; zs = [p[2] for p in fr]
        fblob += struct.pack('<3f3f3ff16s', min(xs), min(ys), min(zs), max(xs), max(ys), max(zs), 0, 0, 0, rad, pad('f%d' % i, 16))
    nrm = enc_normal((0.0, 1.0, 0.0))     # toward the player
    shader = struct.pack('<64si', pad('', 64), 0)
    tblob = b''.join(struct.pack('<3i', *t) for t in tris)
    sblob = b''.join(struct.pack('<2f', *uv) for uv in st)
    xyz = bytearray()
    for fr in frames:
        for (x, y, z) in fr:
            q = [int(round(c * 64.0)) for c in (x, y, z)]
            if max(abs(c) for c in q) > 32767: raise SystemExit('%s: out of the MD3 range' % path)
            xyz += struct.pack('<3hH', q[0], q[1], q[2], nrm)
    o_sh = 108; o_tri = o_sh + len(shader); o_st = o_tri + len(tblob); o_xyz = o_st + len(sblob); o_end = o_xyz + len(xyz)
    surf = struct.pack('<4s64s10i', b'IDP3', pad('card', 64), 0, nf, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end) \
        + shader + tblob + sblob + bytes(xyz)
    o_fr = 108; o_tag = o_fr + len(fblob); o_surf = o_tag; o_eof = o_surf + len(surf)
    hdr = struct.pack('<4si64s9i', b'IDP3', 15, pad(name, 64), 0, nf, 0, 1, 0, o_fr, o_tag, o_surf, o_eof)
    open(path, 'wb').write(hdr + fblob + surf)
    return len(hdr) + len(fblob) + len(surf)


class Quads:
    """a set of quads, each with a plain and a mirror twin (see the module comment)"""
    def __init__(self):
        self.uv = []          # per quad: (u0, v0, u1, v1)

    def add(self, uv):
        self.uv.append(uv)
        return len(self.uv) - 1

    def st_tris(self):
        st, tris = [], []
        for k, (u0, v0, u1, v1) in enumerate(self.uv):
            for twin in (0, 1, 0, 1):
                n = len(st)
                st += [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]     # TL TR BR BL of the picture
                # wound so the plain quad faces the player on an unmirrored hand (rig 2026-11-15: the other way round
                # showed the twin there); the twin, laid out mirrored, is wound the other way by the same indices
                tris += [(n, n + 2, n + 1), (n, n + 3, n + 2)]
        return st, tris

    def frame(self, shown, rest):
        """shown = {quad: (X, Y, Z, w, h, t)} the quads drawn (X, Y, Z the plain quad's front face, card cm, gen_cards
        coordinates; w, h cm; t the voxel's depth); every other quad folded to rest (X, Y, Z).
        THE VOXEL'S TWO FACES: a voxel piece is one voxel deep, and under Glass its front and back faces both blend, so it
        reads nearly solid. Each quad is drawn twice, at the voxel's front face and t behind it, so the model card blends
        the same way (rig 2026-11-15: one face showed the room through the panel)."""
        out = []
        for k in range(len(self.uv)):
            if k in shown:
                X, Y0, Z, w, h, t = shown[k]
                for Y, twin in ((Y0 - t, 0), (Y0 - t, 1), (Y0, 0), (Y0, 1)):   # the back face first: drawn under the front
                    if twin == 0:
                        cx = -X                                       # md3 x: the player's right
                        xl, xr = cx - w / 2, cx + w / 2               # the picture's left edge on the left
                    else:
                        cx = -(2 * CARD[0] - X)                       # the place within the card mirrored
                        xl, xr = cx + w / 2, cx - w / 2               # the picture flipped: its left edge on the right
                    zt, zb = Z + h / 2, Z - h / 2
                    out += [(xl, Y, zt), (xr, Y, zt), (xr, Y, zb), (xl, Y, zb)]
            else:
                p = (-rest[0], rest[1], rest[2])
                out += [p] * 16
        return out


# ---- the art ------------------------------------------------------------------------------------------------------
def cut(im, c):
    """the voxels' cut-out: alpha >= c drawn, else nothing"""
    im = im.convert('RGBA')
    r, g, b, a = im.split()
    a = a.point(lambda v: 255 if v >= c else 0)
    return Image.merge('RGBA', (r, g, b, a))


def up(im, k):
    return im.resize((im.size[0] * k, im.size[1] * k), Image.NEAREST)


def atlas(half):
    """one atlas per Text Quality: the 11 big-font glyphs and the words AMMO, MAGAZINE, RELOAD. Returns the image (upscaled
    so both qualities have the same pixel size) and per piece (u0, v0, u1, v1, w_px, h_px)."""
    cells = [('g' + g, jfo.glyph('big', 43 if g == 'plus' else ord(g), half)[0]) for g in GLYPHS]
    cells += [('w' + w, jfo.word(w, half)) for w in ('AMMO', 'MAGAZINE', 'RELOAD')]
    W = max(sum(c.size[0] + GUTTER for _, c in cells[:11]), max(c.size[0] + GUTTER for _, c in cells[11:]))
    H = cells[0][1].size[1] + GUTTER + sum(c.size[1] + GUTTER for _, c in cells[11:]) + GUTTER
    im = Image.new('RGBA', (W + GUTTER, H), (0, 0, 0, 0))
    pos = {}
    x, y = GUTTER // 2, GUTTER // 2
    for n, c in cells[:11]:
        im.alpha_composite(cut(c, CUT), (x, y)); pos[n] = (x, y, c.size); x += c.size[0] + GUTTER
    y += cells[0][1].size[1] + GUTTER
    for n, c in cells[11:]:
        im.alpha_composite(cut(c, CUT), (GUTTER // 2, y)); pos[n] = (GUTTER // 2, y, c.size); y += c.size[1] + GUTTER
    k = UPX if half else UPX // 2
    big = up(im, k)
    out = {}
    for n, (x0, y0, (w, h)) in pos.items():
        out[n] = (x0 / im.size[0], y0 / im.size[1], (x0 + w) / im.size[0], (y0 + h) / im.size[1], w, h)
    return big, out


def main():
    os.makedirs(MDIR, exist_ok=True)
    for f in os.listdir(MDIR):
        if f.endswith(('.md3', '.png')): os.remove(os.path.join(MDIR, f))
    big_z, rel_z = middle()
    total = 0
    blocks = []          # (comment, model, skin, [(sprite, letter, frame)])

    # ---- panels: Q P <T|S> <depth>, letter = Ermac's panel (style); the skin is the panel ----
    import re
    art = os.path.join(HERE, 'card_art')
    bgs = sorted(int(re.match(r'ammo_bg(\d+)\.png$', f).group(1)) for f in os.listdir(art) if re.match(r'ammo_bg\d+\.png$', f))
    for short in (0, 1):
        q = Quads(); q.add((0.0, 0.0, 1.0, 1.0))
        h_px = gc.SHORT_H if short else gc.PANEL_H
        lz = (gc.SHORT_TOP - gc.PANEL_H * PANEL_S / 2.0) / 2.0 - gc.SHORT_DROP if short else 0.0
        frames = []
        for dy in DEPTHS:
            # the voxel panel is one voxel (0.1 cm) deep: its face toward the player
            frames.append(q.frame({0: (CARD[0], CARD[1] + dy + PANEL_S / 2, CARD[2] + lz, gc.PANEL_W * PANEL_S, h_px * PANEL_S, PANEL_S)},
                                  (CARD[0], CARD[1] + dy, CARD[2])))
        st, tris = q.st_tris()
        mname = 'panel_%s.md3' % 'st'[short]
        total += write_md3(os.path.join(MDIR, mname), mname[:-4], frames, st, tris)
        for s, bg in enumerate(bgs):
            src = os.path.join(art, 'ammo_bg%d.png' % bg)
            im = Image.open(gc.short_panel(src) if short else src).convert('RGBA')
            if not short: im = im.resize((gc.PANEL_W, gc.PANEL_H), Image.LANCZOS)
            skin = 'p%s%02d.png' % ('ts'[short], bg)
            up(cut(im, PANEL_CUT), UPX).save(os.path.join(MDIR, skin))
            spr = 'QP' + 'TS'[short]
            blocks.append(('panel %d %s' % (bg, 'short' if short else 'tall'), mname, skin,
                           [(spr + DCH[d], LETTERS[s], d) for d in range(len(DEPTHS))]))

    for qi, half in enumerate(gc.QUALITIES):
        qc = 'qp'[qi]
        im, at = atlas(half)
        skin = 'jfo_%s.png' % qc
        im.save(os.path.join(MDIR, skin))

        # ---- the word: Q L W <depth>, letters A AMMO, B MAGAZINE (the skin is the quality) ----
        q = Quads(); ids = [q.add(at['w' + w][:4]) for w in ('AMMO', 'MAGAZINE')]
        frames, idx = [], []
        for d, dy in enumerate(DEPTHS):
            for k, w in enumerate(('AMMO', 'MAGAZINE')):
                u = at['w' + w]
                pw = jfo.word(w, half)
                sc = gc.fit(pw, gc.LABEL_BOX)
                X, Y, Z = CARD[0] + gc.LABEL_AT[0], CARD[1] + gc.LABEL_AT[1] + FRONT + dy + sc / 2, CARD[2] + gc.LABEL_AT[2]
                frames.append(q.frame({ids[k]: (X, Y, Z, u[4] * sc, u[5] * sc, sc)}, (X, Y, Z)))
                idx.append(('QLW' + DCH[d], LETTERS[k], len(frames) - 1))
        st, tris = q.st_tris()
        mname = 'label_%s.md3' % qc
        total += write_md3(os.path.join(MDIR, mname), mname[:-4], frames, st, tris)
        blocks.append(('the word, %s' % ('Quest' if half else 'PCVR'), mname, skin, idx))

        # ---- RELOAD: Q R W <depth>, letters A tall card (centred, the owner's change), B short card (RELOAD_SHORT_AT) ----
        q = Quads(); rid = q.add(at['wRELOAD'][:4])
        pw = jfo.word('RELOAD', half); sc = gc.fit(pw, gc.RELOAD_BOX); u = at['wRELOAD']
        frames, idx = [], []
        for d, dy in enumerate(DEPTHS):
            for k, z in enumerate((rel_z, gc.RELOAD_SHORT_AT[2])):
                X, Y, Z = CARD[0], CARD[1] + FRONT + dy + sc / 2, CARD[2] + z
                frames.append(q.frame({rid: (X, Y, Z, u[4] * sc, u[5] * sc, sc)}, (X, Y, Z)))
                idx.append(('QRW' + DCH[d], LETTERS[k], len(frames) - 1))
        st, tris = q.st_tris()
        mname = 'reload_%s.md3' % qc
        total += write_md3(os.path.join(MDIR, mname), mname[:-4], frames, st, tris)
        blocks.append(('RELOAD, %s' % ('Quest' if half else 'PCVR'), mname, skin, idx))

        # ---- the digits: big Q K <slot> <depth> (tall card) / Q H <slot> <depth> (short card: gen_cards' place),
        #      small Q S <slot> <depth>; letter = glyph (0-9, +). (Q K, not Q B: Q B 0 0.. are another pack's sprites in
        #      the owner's order, rig sprite read 2026-11-15) ----
        for kind, slots, hcm in (('B', gc.BIG_AT, gc.BIG_S * 12), ('S', gc.SMALL_AT, gc.SMALL_S * 12)):
            for si, sat in enumerate(slots):
                q = Quads(); ids = [q.add(at['g' + g][:4]) for g in GLYPHS]
                frames, idx = [], []
                variants = ((('K', big_z), ('H', sat[2])) if kind == 'B' else (('S', sat[2]),))
                for d, dy in enumerate(DEPTHS):
                    for vc, z in variants:
                        for gi, g in enumerate(GLYPHS):
                            u = at['g' + g]
                            sc = hcm / u[5]
                            X, Y, Z = CARD[0] + sat[0], CARD[1] + sat[1] + FRONT + dy + sc / 2, CARD[2] + z
                            frames.append(q.frame({ids[gi]: (X, Y, Z, u[4] * sc, u[5] * sc, sc)}, (X, Y, Z)))
                            idx.append(('Q%s%d%s' % (vc, si, DCH[d]), LETTERS[gi], len(frames) - 1))
                st, tris = q.st_tris()
                mname = '%s%d_%s.md3' % ('big' if kind == 'B' else 'small', si, qc)
                total += write_md3(os.path.join(MDIR, mname), mname[:-4], frames, st, tris)
                blocks.append(('%s digit slot %d, %s' % ('big' if kind == 'B' else 'small', si, 'Quest' if half else 'PCVR'),
                               mname, skin, idx))

    # the states take each sprite's letters in order: the quality is a second letter range for the word, RELOAD and the
    # digits (Quest A.., PCVR after), so one state chain per sprite serves both skins
    def letters_of(spr):
        out = {}
        for c, m, s, idx in blocks:
            for sp, le, fr in idx:
                if sp == spr: out[le] = 1
        return sorted(out)

    # Quest and PCVR share sprites: PCVR's letters are shifted past Quest's (word: C D, RELOAD: C D, digits: L..V)
    fixed = []
    for c, m, s, idx in blocks:
        if m.endswith('_p.md3'):
            if m.startswith(('label', 'reload')): sh = 2
            else: sh = len(GLYPHS)
            idx = [(sp, LETTERS[LETTERS.index(le) + sh], fr) for sp, le, fr in idx]
        fixed.append((c, m, s, idx))
    blocks = fixed

    # ---- MODELDEF ----
    def modeldef(cls):
        out = []
        for c, m, s, idx in blocks:
            out += ['// %s' % c, 'Model %s' % cls, '{', '\tPath "%s"' % PATH, '\tModel 0 "%s"' % m, '\tSkin 0 "%s"' % s,
                    '\tScale 1.0 1.0 1.0', '\tAngleOffset 90', '\tNoInterpolation', '\tForceCullBackfaces']
            out += ['\tFrameIndex %s %s 0 %d' % (sp, le, fr) for sp, le, fr in idx]
            out += ['}', '']
        return out

    head = ['// >>> MODEL CARD (tools/gen_modelcard.py) -- the small card drawn by models, the main hand (RSQGC_CardItem owns its',
            '// layers). The off hand\'s blocks are keyed by the off-hand gun\'s class: bridge_bd22vr/MODELDEF.txt.']
    mpath = os.path.join(ROOT, 'MODELDEF.txt')
    old = open(mpath).read()
    a0, a1 = head[0], '// <<< MODEL CARD'
    pre = old.split(a0, 1)[0].rstrip('\n') if a0 in old else old.rstrip('\n')
    post = old.split(a1, 1)[1] if a1 in old else '\n'
    body = head + modeldef('RSQGC_CardItem')
    entries = sum(len(i) for _, _, _, i in blocks)
    open(mpath, 'w').write(pre + '\n\n' + '\n'.join(body) + a1 + post)
    os.makedirs(BRIDGE, exist_ok=True)
    br = ['// GENERATED by GunCards/tools/gen_modelcard.py -- do not edit. RSQ Gun Cards\' small card drawn by models, on',
          '// BD22 VR Reloaded\'s off-hand guns. A layer drawn on the off hand must be owned by the off-hand gun, and MODELDEF',
          '// finds a layer\'s model by its owner\'s class; QuestZDoom 17.3 refuses a block for a class that is not loaded,',
          '// so these blocks ship here, in a pk3 that only loads with BD22 VR (tools/build_modelcard_bridge.sh).', '']
    for cls in OFF_GUNS: br += modeldef(cls)
    open(os.path.join(BRIDGE, 'MODELDEF.txt'), 'w').write('\n'.join(br))
    # the guns that switch: read by modelcard.zs (the bridge's list is found only when the bridge is loaded)
    open(os.path.join(MDIR, 'guns.txt'), 'w').write('\n'.join(MAIN_GUNS) + '\n')
    bdir = os.path.join(BRIDGE, PATH); os.makedirs(bdir, exist_ok=True)
    open(os.path.join(bdir, 'offguns.txt'), 'w').write('\n'.join(OFF_GUNS) + '\n')

    # ---- the states ----
    sprites = []
    for c, m, s, idx in blocks:
        for sp, le, fr in idx:
            if sp not in sprites: sprites.append(sp)
    def zs(cls, bright):
        z = ['class %s : Weapon' % cls, '{',
             '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }', '\tStates', '\t{']
        for sp in sprites:
            z.append('\t%s:' % sp)
            for le in letters_of(sp): z.append('\t\t%s %s -1%s;' % (sp, le, ' Bright' if bright else ''))
            z.append('\t\tStop;')
        z += ['\t}', '',
              '\t// the first state of a piece: code = kind * 1000 + slot * 100 + depth; kind 0 panel, 1 short panel, 2 the word,',
              '\t// 3 RELOAD, 4 big digit (card with the word), 5 big digit (short card), 6 small digit. (FindState wants a',
              '\t// constant label, hence the table.)',
              '\tstatic State Piece(int code)', '\t{', '\t\tlet d = GetDefaultByType("%s");' % cls, '\t\tswitch (code)', '\t\t{']
        for sp in sprites:
            k = {'QPT': 0, 'QPS': 1, 'QLW': 2, 'QRW': 3}.get(sp[:3])
            if k is None: k, slot = {'QK': 4, 'QH': 5, 'QS': 6}[sp[:2]], int(sp[2])
            else: slot = 0
            z.append('\t\tcase %d: return d.FindState("%s");' % (k * 1000 + slot * 100 + DCH.index(sp[3]), sp))
        z += ['\t\t}', '\t\treturn null;', '\t}', '}', '']
        return z
    hdr = ['// GENERATED by tools/gen_modelcard.py -- do not edit. The small card drawn by models: one state chain per sprite,',
           '// its letters in order (modelcard.zs walks NextState). On Weapon classes so a layer owned by the off-hand gun',
           '// accepts them (p_pspr.cpp:544-551). RSQGC_MCStatesB: the same, Bright (Card Glow). No sprite graphics: these',
           '// sprites make no sprite frames.', '']
    open(os.path.join(ROOT, 'zscript', 'rsqgc', 'mcard_states.zs'), 'w').write(
        '\n'.join(hdr + zs('RSQGC_MCStates', False) + zs('RSQGC_MCStatesB', True)))
    print('model card: %d MD3s (%d bytes), %d skins, %d blocks, %d FrameIndex entries per class, %d sprites'
          % (len([f for f in os.listdir(MDIR) if f.endswith('.md3')]), total, len([f for f in os.listdir(MDIR) if f.endswith('.png')]),
             len(blocks), entries, len(sprites)))


if __name__ == '__main__':
    main()
