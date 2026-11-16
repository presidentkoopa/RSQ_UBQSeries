#!/usr/bin/env python3
"""RSQ Gun Cards: THE SMALL CARD, DRAWN BY MODELS (owner 2026-11-15, option B "Same card, drawn by models"; 07:32: "do all
that in this style").

    python3 -I GunCards/tools/gen_modelcard.py [--bd22vr <BD22 VR Reloaded's repo>]

Writes Gun Cards' own files, RSQ Grenade's (Grenade/, this repo) and, with --bd22vr, BD22 VR Reloaded's (its src/; see
WHO OWNS THE LAYERS below). Without --bd22vr BD22 VR's copy is left as it is and the script says so.

The small card beside the wrist: Ermac's panels, the JFO glyphs (or Ermac's own lettering, Small Card Font), the same
colours and the same spot as the voxel card it replaced, but every piece is a MODEL whose animation frames are its glyphs,
the way RemaSelaco draws its ammo digits (RS_Selaco_VRWeapons/HANDOFF_SELACO_AMMO_DIGITS_2026-11-13.md). The owner's one
change (05:57, "the middle portion, i'd like to have centered, relative to the rest"): on the card with the word, the big
count and RELOAD sit centred between the word and the reserve (middle(), per font).

NO SPRITE FRAMES. QuestZDoom 17.3 makes sprite frames only from sprite graphics and voxels (R_InitSpriteDefs). These sprite
names have neither (a HUD model is found by caller class + sprite + frame before any graphic is looked at), so the card
costs none. The voxel card it replaced cost 9,929 (engine read on the owner's full order, docs/modelcard/).

A PIECE AND ITS GLYPH. Each slot (panel, the word, RELOAD, five big and five small digit places) is an MD3 per font (JFO
Quest, JFO PCVR, Ermac). Its one surface holds every glyph as a quad on that font's atlas; a frame unfolds one glyph and
folds every other quad to a point (zero area, nothing drawn), as Selaco folds its unlit segments. MODELDEF maps sprite +
letter to the frame; the layer's state is that sprite + letter.

BOTH HANDS FROM ONE SET. The engine draws the physical left hand mirrored. Each glyph has its mirror twin in the same frame
(the picture flipped, its place within the card mirrored), wound the other way; ForceCullBackfaces shows the plain quad on
an unmirrored hand and the twin on a mirrored one (rig 2026-11-15). And each quad is drawn twice, at the voxel's front face
and one voxel behind it, so Glass blends as the voxel did (one face let the room show through the panel).

THE IN SLIDER WITHOUT 13 COPIES (it moves the card along the forearm, -12..+12 cm, 13 places 2 cm apart). Baking 13 places
per glyph would make each gun class's MODELDEF ~7,000 entries. Instead each glyph has three frames: at In 0, at +14 cm and at
-14 cm, and the layer's state blends between two of them: the engine interpolates a model between its state's frame and the
next state's by the tics left in the state (models.cpp RenderFrameModels: inter = (Tics - tics left) / Tics). The states
last MC_TICS tics and come in pairs (In 0, then +14 or -14); modelcard.zs sets the layer's tics left every tic, which sets
the blend, which sets the In. The slider keeps its 13 places (card.zs Depth). With the engine's model interpolation off
(gl_interpolate_model_frames 0) the card stays at In 0, today's default spot.

WHO OWNS THE LAYERS. MODELDEF is keyed by the class of the layer's caller. The main hand's card is owned by RSQGC_CardItem,
for every gun (MODELDEF.txt, MODEL CARD). The off hand's card must be owned by the off-hand gun itself (the engine picks the
hand by that), so its blocks are keyed by that gun's class, and QuestZDoom 17.3 stops with a fatal "Unknown actor type" on a
block for a class that is not loaded. So THE PACK THAT DEFINES THE GUNS CARRIES THEIR BLOCKS (PACKS below; owner 2026-11-16
08:10: no extra pk3s to load; until then they were bridge pk3s, RSQ_GunCards_<pack>.pk3). Each pack gets:
  - a MODELDEF lump with its guns' blocks,
  - its own copy of the models and skins, under its own path (not models/rsqgc/mc), so the blocks load without Gun Cards
    (a missing model is a console message per block; the copy is byte-for-byte Gun Cards' own, made in the same run),
  - a ZScript class whose states name the card's sprites: MODELDEF's FrameIndex stops with a fatal "Unknown sprite" on a
    sprite no state names (models.cpp), and without Gun Cards nothing else names them. No graphics: no sprite frames,
  - the list of its classes (lump RSQGCOFF, read by modelcard.zs; a gun not listed gets no small card in the off hand).
Without Gun Cards nothing ever sets those layers and the blocks draw nothing. Rerun this (with --bd22vr) whenever the card's
models, sprites or letters change, and rebuild both packs, or their off-hand card falls out of step with Gun Cards'.

Coordinates as gen_cards.py: model cm, X + the player's left (right hand), Y + toward the player, Z up. An MD3 vertex is
(x, y, z) = (-X, Y, Z): the engine maps a voxel and an MD3 to the same model space (models_voxel.cpp AddFace,
models_md3.cpp BuildVertexBuffer), and AngleOffset 90 cancels the HUD model's own quarter turn, as VOXELDEF's default does.
"""
import os, re, shutil, struct, sys, math
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import jfo
import gen_cards as gc

ART = os.path.join(HERE, 'card_art')
MDIR = os.path.join(ROOT, 'models', 'rsqgc', 'mc')
PATH = 'models/rsqgc/mc'

# THE OFF HAND'S GUNS, by the pack that defines them; each pack carries its guns' blocks (see the module comment). BD22 VR's:
# its off-hand copies (RSQ_DualTable) and every Brutal Doom 22 gun with ammo that can go in the off hand as itself, Purist
# versions too (rig class read 2026-11-15: brutal22test6 + BD22 VR 2.0.4x; the Dual* guns, vehicles, shields and HUD guns
# are main-hand only). The series' own: the grenade. (No small card on the cigarette or the road flare, owner 11-15 16:09.)
HUB = os.path.dirname(ROOT)
OFF = {
    'BD22VR': ['RSQ_Off_BrutalPistol', 'RSQ_Off_Revolver', 'RSQ_Off_BrutalSMG', 'RSQ_Off_MP40', 'RSQ_Off_Rifle',
               'RSQ_Off_Plasma_Gun', 'RSQ_Off_Shot_Gun', 'RSQ_Off_SSG', 'RSQ_Off_AssaultShotgun', 'RSQ_Off_RailGun',
               'RSQ_Off_BrutalRevolver', 'RSQ_Off_BrutalAxe',
               'BrutalPistol', 'REVOLVER', 'BrutalRevolver', 'BrutalSMG', 'MP40', 'Rifle', 'Sniper', 'Shot_Gun', 'SSG',
               'AssaultShotgun', 'Minigun', 'Machinegun', 'MG42', 'Plasma_Gun', 'Railgun', 'Rocket_Launcher', 'GrenadeLauncher',
               'IncendiaryLauncher', 'Flamethrower2', 'FlameCannon', 'Unmaker', 'Devastator', 'NukeLauncher',
               'HellishMissileLauncher', 'BIG_FUCKING_GUN', 'BFG10k', 'HandGrenades', 'BrutalAxe',
               'PuristPistol', 'PuristRevolver', 'PuristSMG', 'PuristMP40', 'PuristRifle', 'PuristSniper', 'PuristShot_Gun',
               'PuristSSG', 'PuristAssaultShotgun', 'PuristMinigun', 'PuristMG42', 'PuristPlasma_Gun', 'PuristRailGun',
               'PuristRocket_Launcher', 'PuristGrenadeLauncher', 'PuristIncendiaryLauncher', 'PuristFlamethrower2',
               'PuristFlameCannon', 'PuristUnmaker', 'PuristDevastator', 'PuristNukeLauncher', 'PuristHellishMissileLauncher',
               'PuristBIG_FUCKING_GUN', 'PuristBFG10k', 'PuristHandGrenades'],
    'Grenade': ['RSQGN_Grenade'],
}
# where each pack's copy goes: root (None: given on the command line), the model path inside the pk3, the MODELDEF and
# RSQGCOFF lumps' file names, the ZScript file naming the sprites (its pack's ZScript #includes it, by hand, once) and its
# class. Names in each pack's own prefix, so nothing clashes with Gun Cards' (models/rsqgc/mc, RSQGC_*).
PACKS = {
    'BD22VR': dict(name='BD22 VR Reloaded', root=None, path='models/rsq/gcmc', modeldef='MODELDEF.rsqgc',
                   offlist='RSQGCOFF.rsq', zs='zscript/rsq/gcsprites.zs', cls='RSQ_GCCardSprites',
                   inc='ZSCRIPT.rsvr'),
    'Grenade': dict(name='RSQ Grenade', root=os.path.join(HUB, 'Grenade'), path='models/rsqgn/gcmc',
                    modeldef='MODELDEF.guncards.txt', offlist='RSQGCOFF.txt', zs='zscript/rsqgn/gcsprites.zs',
                    cls='RSQGN_GCCardSprites', inc='zscript.txt'),
}

UP_JFO_Q, UP_JFO_P, UP_ERMAC, UP_PANEL = 4, 2, 8, 4   # skins upscaled (nearest): the blocky voxel look survives filtering
GUTTER = 4
MC_TICS = 2000            # each state's tics (modelcard.zs MC_TICS): the blend's resolution, 24 cm / 2000
ENDS = (0.0, 14.0, -14.0) # the In places each glyph is baked at (cm along the forearm, + toward the player); In = t * 14
ECH = '012'
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
CARD, FRONT, PANEL_S = gc.CARD, gc.FRONT, gc.PANEL_S
GLYPHS = gc.GLYPHS        # 0-9, plus
JFO_CUT, ERMAC_CUT = 100, 60   # the voxels' alpha cut-outs (jfo_piece, card_piece)
FONTS = ('q', 'p', 'e')   # JFO Quest, JFO PCVR, Ermac


# ---- the art -------------------------------------------------------------------------------------------------------------
def cut(im, c):
    im = im.convert('RGBA')
    r, g, b, a = im.split()
    return Image.merge('RGBA', (r, g, b, a.point(lambda v: 255 if v >= c else 0)))


def up(im, k):
    return im.resize((im.size[0] * k, im.size[1] * k), Image.NEAREST)


def ermac(name):
    """Ermac's piece at the size the voxel card used (card_piece: NEAREST at his own size)"""
    return Image.open(os.path.join(ART, name + '.png')).convert('RGBA')


def pieces(font):
    """{name: (image, cm per pixel)} for a font: 'g0'..'g9', 'gplus' (cm per px at the BIG size), 'wAMMO', 'wMAGAZINE',
    'wRELOAD'. The small digits use the same glyph at SMALL_S."""
    out = {}
    if font in ('q', 'p'):
        half = font == 'q'
        for g in GLYPHS:
            im = jfo.glyph('big', 43 if g == 'plus' else ord(g), half)[0]
            out['g' + g] = (im, gc.BIG_S * 12 / im.size[1])
        for w in ('AMMO', 'MAGAZINE'):
            im = jfo.word(w, half)
            out['w' + w] = (im, gc.fit(im, gc.LABEL_BOX))
        im = jfo.word('RELOAD', half)
        out['wRELOAD'] = (im, gc.fit(im, gc.RELOAD_BOX))
    else:
        for g in GLYPHS:
            out['g' + g] = (ermac('digit_' + g), gc.BIG_S)
        out['wAMMO'] = (ermac('ammo'), gc.LABEL_S)
        out['wMAGAZINE'] = (ermac('magazine'), gc.LABEL_S)
        out['wRELOAD'] = (ermac('reload'), gc.RELOAD_S)
    return out


def atlas(font, pcs):
    """the font's atlas (glyphs in a row, the words under them) and each piece's UV box"""
    c = ERMAC_CUT if font == 'e' else JFO_CUT
    names = ['g' + g for g in GLYPHS] + ['wAMMO', 'wMAGAZINE', 'wRELOAD']
    row = [pcs[n][0] for n in names[:11]]
    W = max(sum(i.size[0] + GUTTER for i in row), max(pcs[n][0].size[0] + GUTTER for n in names[11:])) + GUTTER
    H = max(i.size[1] for i in row) + GUTTER + sum(pcs[n][0].size[1] + GUTTER for n in names[11:]) + GUTTER
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    pos = {}
    x, y = GUTTER // 2, GUTTER // 2
    for n in names[:11]:
        p = pcs[n][0]; im.alpha_composite(cut(p, c), (x, y)); pos[n] = (x, y, p.size); x += p.size[0] + GUTTER
    y += max(i.size[1] for i in row) + GUTTER
    for n in names[11:]:
        p = pcs[n][0]; im.alpha_composite(cut(p, c), (GUTTER // 2, y)); pos[n] = (GUTTER // 2, y, p.size); y += p.size[1] + GUTTER
    k = {'q': UP_JFO_Q, 'p': UP_JFO_P, 'e': UP_ERMAC}[font]
    uv = {n: (x0 / W, y0 / H, (x0 + w) / W, (y0 + h) / H) for n, (x0, y0, (w, h)) in pos.items()}
    return up(im, k), uv


def drawn(im, cut_at):
    a = im.convert('RGBA').split()[3].point(lambda v: 255 if v >= cut_at else 0)
    b = a.getbbox()
    return (b[1], b[3] - 1) if b else (0, im.size[1] - 1)


def span_z(im, sc, zc, cut_at):
    t, b = drawn(im, cut_at)
    h = im.size[1]
    return zc + (h / 2.0 - t) * sc, zc + (h / 2.0 - (b + 1)) * sc


def middle(font, pcs):
    """THE OWNER'S CHANGE (05:57): on the card with the word the big count sits centred between the word's foot (the mean of
    AMMO's and MAGAZINE's) and the reserve's top (its tallest digit), measured on the drawn pixels. Returns the big slots'
    z and RELOAD's (its own drawn middle on the same line)."""
    c = ERMAC_CUT if font == 'e' else JFO_CUT
    foot = sum(span_z(pcs[w][0], pcs[w][1], gc.LABEL_AT[2], c)[1] for w in ('wAMMO', 'wMAGAZINE')) / 2.0
    tops, mids = [], []
    for g in '0123456789':
        im, sc = pcs['g' + g]
        tops.append(span_z(im, sc * gc.SMALL_S / gc.BIG_S, gc.SMALL_AT[0][2], c)[0])
        t, b = span_z(im, sc, 0.0, c)
        mids.append((t + b) / 2.0)
    top = max(tops)
    want = (foot + top) / 2.0
    big_z = want - sum(mids) / len(mids)
    t, b = span_z(pcs['wRELOAD'][0], pcs['wRELOAD'][1], 0.0, c)
    rel_z = want - (t + b) / 2.0
    tb, bb = span_z(pcs['g8'][0], pcs['g8'][1], gc.BIG_AT[0][2], c)
    print('middle (%s): word foot %.3f, reserve top %.3f: the count now %.3f / %.3f cm from them (the voxel card: %.3f / %.3f)'
          % (font, foot, top, foot - (tb - gc.BIG_AT[0][2] + big_z), (bb - gc.BIG_AT[0][2] + big_z) - top, foot - tb, bb - top))
    return big_z, rel_z


# ---- MD3 -------------------------------------------------------------------------------------------------------------------
def enc_normal(n):
    x, y, z = n
    lat = int(round(math.acos(max(-1.0, min(1.0, z))) * 255 / (2 * math.pi))) & 255
    lng = int(round(math.atan2(y, x) * 255 / (2 * math.pi))) & 255
    return (lat << 8) | lng


def pad(s, n):
    b = s.encode()[:n - 1]
    return b + b'\0' * (n - len(b))


def write_md3(path, name, frames, st, tris):
    nf, nv, nt = len(frames), len(frames[0]), len(tris)
    rad = max(math.sqrt(x * x + y * y + z * z) for fr in frames for (x, y, z) in fr)
    fblob = b''
    for i, fr in enumerate(frames):
        xs = [p[0] for p in fr]; ys = [p[1] for p in fr]; zs = [p[2] for p in fr]
        fblob += struct.pack('<3f3f3ff16s', min(xs), min(ys), min(zs), max(xs), max(ys), max(zs), 0, 0, 0, rad, pad('f%d' % i, 16))
    nrm = enc_normal((0.0, 1.0, 0.0))
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
    o_fr = 108; o_tag = o_fr + len(fblob); o_eof = o_tag + len(surf)
    hdr = struct.pack('<4si64s9i', b'IDP3', 15, pad(name, 64), 0, nf, 0, 1, 0, o_fr, o_tag, o_tag, o_eof)
    open(path, 'wb').write(hdr + fblob + surf)
    return o_eof


class Quads:
    """quads with their mirror twins and back faces (the module comment)"""
    def __init__(self):
        self.uv = []

    def add(self, uv):
        self.uv.append(uv)
        return len(self.uv) - 1

    def st_tris(self):
        st, tris = [], []
        for (u0, v0, u1, v1) in self.uv:
            for _ in range(4):
                n = len(st)
                st += [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]     # TL TR BR BL of the picture
                # wound so the plain quad faces the player on an unmirrored hand (rig 2026-11-15); the twin, laid out
                # mirrored, is wound the other way by the same indices
                tris += [(n, n + 2, n + 1), (n, n + 3, n + 2)]
        return st, tris

    def frame(self, shown, rest):
        """shown = {quad: (X, Y, Z, w, h, t)}: X, Y, Z the plain quad's front face (card cm), w x h cm, t the voxel's
        depth; every other quad folded to rest"""
        out = []
        for k in range(len(self.uv)):
            if k in shown:
                X, Y0, Z, w, h, t = shown[k]
                for Y, twin in ((Y0 - t, 0), (Y0 - t, 1), (Y0, 0), (Y0, 1)):   # the back face first: drawn under the front
                    if twin == 0:
                        cx = -X; xl, xr = cx - w / 2, cx + w / 2
                    else:
                        cx = -(2 * CARD[0] - X); xl, xr = cx + w / 2, cx - w / 2
                    zt, zb = Z + h / 2, Z - h / 2
                    out += [(xl, Y, zt), (xr, Y, zt), (xr, Y, zb), (xl, Y, zb)]
            else:
                out += [(-rest[0], rest[1], rest[2])] * 16
        return out


# ---- the build -------------------------------------------------------------------------------------------------------------
def main(argv):
    roots = {k: p['root'] for k, p in PACKS.items()}
    if argv[:1] == ['--bd22vr'] and len(argv) == 2:
        roots['BD22VR'] = os.path.join(os.path.abspath(argv[1]), 'src')
    elif argv:
        raise SystemExit('usage: gen_modelcard.py [--bd22vr <BD22 VR Reloaded repo>]')
    for k, r in roots.items():
        if r and not os.path.isfile(os.path.join(r, PACKS[k]['inc'])):
            raise SystemExit('%s: no %s in %s' % (PACKS[k]['name'], PACKS[k]['inc'], r))
    os.makedirs(MDIR, exist_ok=True)
    for f in os.listdir(MDIR):
        if f.endswith(('.md3', '.png', '.txt')): os.remove(os.path.join(MDIR, f))
    total = 0
    blocks = []          # (comment, model, skin, [(sprite, letter, frame)])

    def emit(qd, frames, mname):
        nonlocal total
        st, tris = qd.st_tris()
        total += write_md3(os.path.join(MDIR, mname), mname[:-4], frames, st, tris)

    # PANELS: Q P <T|S> <end>, letter = Ermac's panel (style); one atlas of the 18
    bgs = sorted(int(re.match(r'ammo_bg(\d+)\.png$', f).group(1)) for f in os.listdir(ART) if re.match(r'ammo_bg\d+\.png$', f))
    for short in (0, 1):
        h_px = gc.SHORT_H if short else gc.PANEL_H
        cells = []
        for bg in bgs:
            src = os.path.join(ART, 'ammo_bg%d.png' % bg)
            im = Image.open(gc.short_panel(src) if short else src).convert('RGBA')
            if not short: im = im.resize((gc.PANEL_W, gc.PANEL_H), Image.LANCZOS)
            cells.append(cut(im, ERMAC_CUT))
        cols = 6
        cw, ch = gc.PANEL_W + GUTTER, h_px + GUTTER
        at = Image.new('RGBA', (cols * cw, ((len(cells) + cols - 1) // cols) * ch), (0, 0, 0, 0))
        q = Quads()
        for i, c in enumerate(cells):
            x0, y0 = (i % cols) * cw + GUTTER // 2, (i // cols) * ch + GUTTER // 2
            at.alpha_composite(c, (x0, y0))
            q.add((x0 / at.size[0], y0 / at.size[1], (x0 + c.size[0]) / at.size[0], (y0 + c.size[1]) / at.size[1]))
        skin = 'panels_%s.png' % 'ts'[short]
        up(at, UP_PANEL).save(os.path.join(MDIR, skin))
        lz = (gc.SHORT_TOP - gc.PANEL_H * PANEL_S / 2.0) / 2.0 - gc.SHORT_DROP if short else 0.0
        frames, idx = [], []
        for e, dy in enumerate(ENDS):
            for s in range(len(bgs)):
                frames.append(q.frame({s: (CARD[0], CARD[1] + dy + PANEL_S / 2, CARD[2] + lz, gc.PANEL_W * PANEL_S, h_px * PANEL_S, PANEL_S)},
                                      (CARD[0], CARD[1] + dy, CARD[2])))
                idx.append(('QP' + 'TS'[short] + ECH[e], LETTERS[s], len(frames) - 1))
        mname = 'panel_%s.md3' % 'ts'[short]
        emit(q, frames, mname)
        blocks.append(('Ermac\'s panels, the card %s the word' % ('without' if short else 'with'), mname, skin, idx))

    for fi, font in enumerate(FONTS):
        pcs = pieces(font)
        im, uv = atlas(font, pcs)
        skin = 'font_%s.png' % font
        im.save(os.path.join(MDIR, skin))
        big_z, rel_z = middle(font, pcs)
        fname = {'q': 'JFO Quest', 'p': 'JFO PCVR', 'e': 'Ermac'}[font]

        # THE WORD: Q L W <end>, letters font * 2 + word (A AMMO, B MAGAZINE; C D PCVR; E F Ermac)
        q = Quads(); ids = [q.add(uv['w' + w]) for w in ('AMMO', 'MAGAZINE')]
        frames, idx = [], []
        for e, dy in enumerate(ENDS):
            for k, w in enumerate(('AMMO', 'MAGAZINE')):
                p, sc = pcs['w' + w]
                X, Y, Z = CARD[0] + gc.LABEL_AT[0], CARD[1] + gc.LABEL_AT[1] + FRONT + dy + sc / 2, CARD[2] + gc.LABEL_AT[2]
                frames.append(q.frame({ids[k]: (X, Y, Z, p.size[0] * sc, p.size[1] * sc, sc)}, (X, Y, Z)))
                idx.append(('QLW' + ECH[e], LETTERS[fi * 2 + k], len(frames) - 1))
        mname = 'label_%s.md3' % font
        emit(q, frames, mname)
        blocks.append(('the word, %s' % fname, mname, skin, idx))

        # RELOAD: Q R W <end>, letters font * 2 + (A the card with the word, centred: the owner's change; B the short card)
        q = Quads(); rid = q.add(uv['wRELOAD'])
        p, sc = pcs['wRELOAD']
        frames, idx = [], []
        for e, dy in enumerate(ENDS):
            for k, z in enumerate((rel_z, gc.RELOAD_SHORT_AT[2])):
                X, Y, Z = CARD[0], CARD[1] + FRONT + dy + sc / 2, CARD[2] + z
                frames.append(q.frame({rid: (X, Y, Z, p.size[0] * sc, p.size[1] * sc, sc)}, (X, Y, Z)))
                idx.append(('QRW' + ECH[e], LETTERS[fi * 2 + k], len(frames) - 1))
        mname = 'reload_%s.md3' % font
        emit(q, frames, mname)
        blocks.append(('RELOAD, %s' % fname, mname, skin, idx))

        # THE DIGITS. JFO: big Q K <slot> <end> (the card with the word, centred) / Q H (the short card, gen_cards' place),
        # small Q S; letter = quality * 11 + glyph. Ermac: Q N / Q O / Q J, letter = glyph. (Q K and not Q B: Q B 0 0.. are
        # another pack's sprites in the owner's order, rig sprite read 2026-11-15.)
        jfo_font = font != 'e'
        for kind, slots, size in (('B', gc.BIG_AT, gc.BIG_S), ('S', gc.SMALL_AT, gc.SMALL_S)):
            for si, sat in enumerate(slots):
                q = Quads(); ids = [q.add(uv['g' + g]) for g in GLYPHS]
                if kind == 'B': variants = (('K' if jfo_font else 'N', big_z), ('H' if jfo_font else 'O', sat[2]))
                else: variants = (('S' if jfo_font else 'J', sat[2]),)
                frames, idx = [], []
                for e, dy in enumerate(ENDS):
                    for vc, z in variants:
                        for gi, g in enumerate(GLYPHS):
                            p, scb = pcs['g' + g]
                            sc = scb * size / gc.BIG_S
                            X, Y, Z = CARD[0] + sat[0], CARD[1] + sat[1] + FRONT + dy + sc / 2, CARD[2] + z
                            frames.append(q.frame({ids[gi]: (X, Y, Z, p.size[0] * sc, p.size[1] * sc, sc)}, (X, Y, Z)))
                            le = LETTERS[(fi * len(GLYPHS) if jfo_font else 0) + gi]
                            idx.append(('Q%s%d%s' % (vc, si, ECH[e]), le, len(frames) - 1))
                mname = '%s%d_%s.md3' % ('big' if kind == 'B' else 'small', si, font)
                emit(q, frames, mname)
                blocks.append(('%s digit slot %d, %s' % ('big' if kind == 'B' else 'small', si, fname), mname, skin, idx))

    # ---- MODELDEF ----
    def modeldef(cls, path=PATH):
        out = []
        for c, m, s, idx in blocks:
            out += ['// %s' % c, 'Model %s' % cls, '{', '\tPath "%s"' % path, '\tModel 0 "%s"' % m, '\tSkin 0 "%s"' % s,
                    '\tScale 1.0 1.0 1.0', '\tAngleOffset 90', '\tForceCullBackfaces']
            out += ['\tFrameIndex %s %s 0 %d' % (sp, le, fr) for sp, le, fr in idx]
            out += ['}', '']
        return out

    entries = sum(len(i) for _, _, _, i in blocks)
    head = '// >>> MODEL CARD (tools/gen_modelcard.py) -- the small card, drawn by models. The main hand: RSQGC_CardItem owns its'
    mpath = os.path.join(ROOT, 'MODELDEF.txt')
    old = open(mpath).read()
    a0, a1 = '// >>> MODEL CARD', '// <<< MODEL CARD'
    pre = old.split(a0, 1)[0].rstrip('\n') if a0 in old else old.rstrip('\n')
    post = old.rsplit(a1, 1)[1] if a1 in old else '\n'
    body = [head, '// layers, for every gun. The off hand\'s blocks are keyed by the off-hand gun\'s class and ship in that gun\'s pack',
            '// (gen_modelcard.py PACKS: BD22 VR Reloaded\'s MODELDEF.rsqgc, RSQ Grenade\'s MODELDEF.guncards.txt).'] \
        + modeldef('RSQGC_CardItem')
    open(mpath, 'w').write(pre + '\n\n' + '\n'.join(body) + a1 + post)

    # ---- the states: per sprite pair (In 0, then +14 or -14) a chain, each letter's two states in turn ----
    sprites = []
    for c, m, s, idx in blocks:
        for sp, le, fr in idx:
            if sp[:-1] not in sprites: sprites.append(sp[:-1])
    def letters_of(base):
        return sorted({le for _, _, _, idx in blocks for sp, le, fr in idx if sp[:-1] == base})
    KIND = {'QPT': 0, 'QPS': 1, 'QLW': 2, 'QRW': 3}
    SK = {'QK': 4, 'QH': 5, 'QS': 6, 'QN': 7, 'QO': 8, 'QJ': 9}
    def zs(cls, bright):
        z = ['class %s : Weapon' % cls, '{',
             '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }', '\tStates', '\t{']
        for base in sprites:
            for sign, far in (('P', '1'), ('M', '2')):
                z.append('\tMC_%s_%s:' % (base, sign))
                for le in letters_of(base):
                    z.append('\t\t%s0 %s %d%s;' % (base, le, MC_TICS, ' Bright' if bright else ''))
                    z.append('\t\t%s%s %s %d%s;' % (base, far, le, MC_TICS, ' Bright' if bright else ''))
                z.append('\t\tStop;')
        z += ['\t}', '',
              '\t// the first state of a piece: code = (kind * 100 + slot) * 2 + (1: In below 0); kind 0 panel, 1 short panel, 2 the',
              '\t// word, 3 RELOAD, 4 big JFO digit (card with the word), 5 big JFO digit (short card), 6 small JFO digit, 7 / 8 / 9',
              '\t// the same in Ermac\'s lettering. A letter\'s states are the 2 n-th and the next. (FindState wants a constant label.)',
              '\tstatic State Piece(int code)', '\t{', '\t\tlet d = GetDefaultByType("%s");' % cls, '\t\tswitch (code)', '\t\t{']
        for base in sprites:
            if base in KIND: k, slot = KIND[base], 0
            else: k, slot = SK[base[:2]], int(base[2])
            for si, sign in enumerate('PM'):
                z.append('\t\tcase %d: return d.FindState("MC_%s_%s");' % ((k * 100 + slot) * 2 + si, base, sign))
        z += ['\t\t}', '\t\treturn null;', '\t}', '}', '']
        return z
    hdr = ['// GENERATED by tools/gen_modelcard.py -- do not edit. The small card\'s pieces, drawn by models (modelcard.zs).',
           '// On Weapon classes so a layer owned by the off-hand gun accepts them (p_pspr.cpp:544-551). RSQGC_MCStatesB: the same,',
           '// Bright (Card Glow). No sprite graphics: these sprites make no sprite frames.', '',
           'class RSQGC_MC', '{',
           '\tconst TICS = %d;      // every state\'s tics: the In blend (modelcard.zs)' % MC_TICS,
           '\tconst END = %g;       // cm: the In places baked besides 0 (+END, -END)' % ENDS[1],
           '\tconst STYLES = %d;    // Ermac\'s panels: ammo_bg %s' % (len(bgs), ' '.join(map(str, bgs))),
           '\tconst GLYPHS = %d;    // 0-9, + (GLYPH_PLUS)' % len(GLYPHS),
           '\tconst GLYPH_PLUS = %d;' % GLYPHS.index('plus'),
           '\tconst SLOTS = %d;' % len(gc.BIG_AT),
           '\tconst DEPTHS = %d;    // the In slider\'s places (rsqgc_in), DEPTH_STEP cm apart, the middle one at 0' % len(gc.DEPTHS),
           '\tconst DEPTH_STEP = %g;' % (gc.DEPTHS[1] - gc.DEPTHS[0]),
           '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqgc', 'mcard_states.zs'), 'w').write(
        '\n'.join(hdr + zs('RSQGC_MCStates', False) + zs('RSQGC_MCStatesB', True)))
    # ---- each pack's copy (the module comment): blocks, models, the sprites' names, the class list ----
    used = []
    for c, m, s, idx in blocks:
        for sp, le, fr in idx:
            if sp not in used: used.append(sp)
    done = []
    for key, pk in PACKS.items():
        r = roots[key]
        if not r:
            print('%s NOT written (pass --bd22vr <its repo>): its off-hand small card stays as last generated' % pk['name'])
            continue
        mdir = os.path.join(r, *pk['path'].split('/'))
        os.makedirs(mdir, exist_ok=True)
        for f in os.listdir(mdir):
            if f.endswith(('.md3', '.png')): os.remove(os.path.join(mdir, f))
        for f in sorted(os.listdir(MDIR)):
            if f.endswith(('.md3', '.png')): shutil.copyfile(os.path.join(MDIR, f), os.path.join(mdir, f))
        gen = '// GENERATED by the RSQ UBQ Series\' GunCards/tools/gen_modelcard.py -- do not edit; rerun it.'
        md = [gen + ' RSQ Gun Cards\' small card,',
              '// drawn by models, on %s\'s guns in the off hand. A layer drawn on the off hand must be owned by the off-hand' % pk['name'],
              '// gun, and MODELDEF finds a layer\'s model by its owner\'s class; QuestZDoom 17.3 refuses a block for a class that is',
              '// not loaded, so the pack that defines the guns carries the blocks. The models and skins are this pack\'s own copy',
              '// (%s, byte-for-byte Gun Cards\' models/rsqgc/mc) and the sprites are named by %s (%s), so this' % (pk['path'], pk['cls'], pk['zs']),
              '// loads without Gun Cards; without it nothing sets these layers and nothing is drawn.', '']
        for cls in OFF[key]: md += modeldef(cls, pk['path'])
        open(os.path.join(r, pk['modeldef']), 'w').write('\n'.join(md))
        open(os.path.join(r, pk['offlist']), 'w').write(
            '// GENERATED by the RSQ UBQ Series\' GunCards/tools/gen_modelcard.py -- do not edit. The off-hand guns whose small card\n'
            '// this pack carries (%s); read by RSQ Gun Cards (modelcard.zs).\n' % pk['modeldef'] + '\n'.join(OFF[key]) + '\n')
        z = [gen, '// RSQ Gun Cards\' small card: these states only NAME the card\'s sprites, so %s\'s MODELDEF blocks' % pk['modeldef'],
             '// for it parse without Gun Cards (FrameIndex stops with a fatal "Unknown sprite" on a sprite no state names). Never',
             '// spawned. The sprites have no graphics, so they make no sprite frames.', '',
             'class %s : Actor' % pk['cls'], '{', '\tStates', '\t{', '\tSpawn:']
        z += ['\t\t%s A -1;' % sp for sp in used]
        z += ['\t\tStop;', '\t}', '}', '']
        zp = os.path.join(r, *pk['zs'].split('/'))
        open(zp, 'w').write('\n'.join(z))
        inc = open(os.path.join(r, pk['inc'])).read()
        if pk['zs'] not in inc:
            print('%s: add #include "%s" to %s' % (pk['name'], pk['zs'], pk['inc']))
        done.append('%s %d classes' % (pk['name'], len(OFF[key])))
    print('model card: %d MD3s (%d bytes), %d skins, %d blocks, %d FrameIndex entries per class, %d sprites; packs written: %s'
          % (len([f for f in os.listdir(MDIR) if f.endswith('.md3')]), total, len([f for f in os.listdir(MDIR) if f.endswith('.png')]),
             len(blocks), entries, len(sprites) * 3, ', '.join(done) or 'none'))


if __name__ == '__main__':
    main(sys.argv[1:])
