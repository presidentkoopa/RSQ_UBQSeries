#!/usr/bin/env python3
"""gen_wristcard.py -- RSQ Miniboss: the Start Fight card ON THE INSIDE OF THE OFF-HAND WRIST, drawn with the hand the way
RSQ Gun Cards draws its watch card (owner 2026-11-17: "on the inside of the god damn wrist. it's the exact same fucking
logic as the fucking guncards").

    python3 -I Miniboss/tools/gen_wristcard.py

THE SAME ANCHOR AS GUN CARDS' WATCH CARD. Gun Cards lays its watch card as VOXELDEF voxels on weapon layers owned by the
off-hand weapon, so the engine draws them with that hand's own transform every frame (GunCards/tools/gen_cards.py "WHY
VOXELS": MODELDEF is keyed by the owner's class, only a voxel draws on any off-hand gun). The card is a flat slab one
voxel deep in the plane of the wrist's side, in the hand's model centimetres, measured by Gun Cards from Brutal Doom VR's
hand mesh. This bake imports that tool's numbers and code (GunCards/tools/gen_side.py: SIDE_X, ROT_ZC, ROT_YC,
WEAPON_SCALE, piece(), block_palette(); gen_cards.py write_kvx()), so the two cards stand on the same measured wrist:
  Gun Cards' watch card   plane X = SIDE_X (-4.5): the back of the wrist (model X - is the back of the right hand)
  the Start Fight card    plane X = 2 * WRIST_X - SIDE_X (+5.3): the same distance off the wrist's centre on the other
                          side, the INSIDE of the wrist (the palm side), facing out of it
The two never overlap: a wrist lies between them (about 10 cm), and each is only drawn while its own face is turned to
your eyes.

WHICH WAY UP. As Gun Cards' card: baked with the text's up along model -Z (the gun's top) and turned half round when the
gun's top points up the screen (bossfight.zs WcRot, Gun Cards' SideRot). Gun Cards bakes the turned card twice over;
here the turn is the layer's y (hw_weapon.cpp: (y - 32) / -4 degrees about the model's X, the card's own normal), about
the card's centre, which the VOXELDEF offsets name. So only the mirrored twin (the physical left hand is drawn mirrored,
hw_vrmodes.cpp) is baked: 3 cards x 2 x 2 tiles = 12 sprite frames (the load order's sprite-frame cap: GunCards README).

THE CARD'S OWN LOOK. RSQMBWC0 (FIGHT (skull) NOT READY, grey), RSQMBWC1 (START (skull) FIGHT?, gold), RSQMBWC2 (BIG (skull)
BOSS!, black and red): the same pictures, at the same width as before (bossfight.zs WC_WIDE, 6 map units, 17.6 cm), at a
third of their pixels (one voxel 0.6 mm), each half its own piece of at most 16 colours (Gun Cards' block palette, so
texture filtering keeps every colour its own).

Writes voxels/mbwc*.kvx, VOXELDEF.txt, sprites/wristcard/QMWC*0.png (1 x 1 placeholders: the sprite names must exist)
and zscript/rsqmb/wristcard_states.zs (class RSQMB_WCStates)."""
import os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)   # the Miniboss folder
GC_TOOLS = os.path.join(os.path.dirname(ROOT), 'GunCards', 'tools')
sys.path.insert(0, GC_TOOLS)
import gen_side as gs          # Gun Cards' watch card: the measured wrist and the voxel piece writer

WRIST_X = 0.4                  # the wrist's centre (gen_cards.py: WRIST = (0.4, -16.9, -11.3), BD22 VR's hand mesh)
INNER_X = 2 * WRIST_X - gs.SIDE_X   # the inside of the wrist: as far off its centre as Gun Cards' card, the other side
WRIST_Y = gs.ROT_YC            # -16.9: the wrist along the forearm (Gun Cards' card is centred on it)
WRIST_Z = gs.ROT_ZC            # -11.3: the wrist's height
UNITS_PER_M = 34.0             # vr_vunits_per_meter's default
WIDE_UNITS = 6.0               # bossfight.zs WC_WIDE: the card's width, map units, as it was
CARD_W = WIDE_UNITS / UNITS_PER_M * 100.0   # cm
OVER_HAND = 1.0                # cm the card reaches past the wrist toward the hand; the rest runs up the forearm
SHRINK = 3                     # a third of the pictures' pixels
TILES = 2                      # pieces per card, each at most 16 colours
CARDS = ['RSQMBWC0', 'RSQMBWC1', 'RSQMBWC2']
SPRITE = 'QMWC'                # frames A..L: card * 4 + mirrored * 2 + tile (checked free in the full load order)


def main():
    vdir = os.path.join(ROOT, 'voxels'); sdir = os.path.join(ROOT, 'sprites', 'wristcard')
    os.makedirs(vdir, exist_ok=True); os.makedirs(sdir, exist_ok=True)
    for f in os.listdir(vdir):
        if f.startswith('mbwc') and f.endswith('.kvx'): os.remove(os.path.join(vdir, f))
    for f in os.listdir(sdir): os.remove(os.path.join(sdir, f))
    ws = gs.WEAPON_SCALE
    vdef, frames, sizes = [], [], []
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for ci, name in enumerate(CARDS):
        src = Image.open(os.path.join(ROOT, 'graphics', name + '.png')).convert('RGBA')
        im = src.resize((round(src.size[0] / SHRINK), round(src.size[1] / SHRINK)), Image.LANCZOS)
        w, h = im.size
        s = CARD_W / w                                   # cm per voxel
        ch = h * s
        # the card's rectangle on the inside of the wrist (model Y along the forearm, + toward the elbow; Z up)
        y_lo = WRIST_Y - OVER_HAND
        yc = y_lo + CARD_W / 2.0
        zc = WRIST_Z
        sizes.append((name, w, h, round(CARD_W, 2), round(ch, 2)))
        for mir in (0, 1):
            for t in range(TILES):
                x0 = w * t // TILES; x1 = w * (t + 1) // TILES
                tile = im.crop((x0, 0, x1, h))
                # Seen from outside the inside face (model X +), with the text's up along -Z, the text runs toward -Y
                # (toward the hand); piece() lays picture columns along +Y, so the hand's own (unmirrored) card is the
                # picture flipped, and its mirrored twin is the picture as drawn (Gun Cards' card faces -X: the reverse).
                flip = not mir
                # picture column x lands at Y = yc + CARD_W / 2 - x * s on the unmirrored card (text toward -Y)
                if flip: ty0 = yc + CARD_W / 2.0 - x1 * s
                else: ty0 = yc - CARD_W / 2.0 + x0 * s
                tz0 = zc - ch / 2.0
                lump = 'mbwc%d%d%d' % (ci, mir, t)
                # piece() lays the piece about the turning point (the VOXELDEF offsets: the card's centre, so the half
                # turn of the layer's y turns the card in place) and the engine's weapon scale (vr_weaponScale 1.02,
                # models.cpp:277) scales it about that point afterwards: every length is given over the scale, so the
                # card lands exactly at its measured place and size
                gs.piece(tile, os.path.join(vdir, lump + '.kvx'), s / ws, ty0 / ws, tz0 / ws, flip,
                         gs.SIDE_X - INNER_X / ws, 0, (yc, zc), cut=60)
                L = letters[ci * 4 + mir * 2 + t]
                vdef.append('%s%s = "%s" { Scale = %g YOffset = %g ZOffset = %g }' % (SPRITE, L, lump, round(s / ws, 6), round(yc, 4), round(zc, 4)))
                Image.new('RGBA', (1, 1)).save(os.path.join(sdir, '%s%s0.png' % (SPRITE, L)))
                frames.append(L)
    open(os.path.join(ROOT, 'VOXELDEF.txt'), 'w').write(
        '// GENERATED by tools/gen_wristcard.py -- do not edit. The Start Fight card on the inside of the off-hand wrist,\n'
        '// drawn with the hand as RSQ Gun Cards draws its watch card (bossfight.zs WristCard).\n' + '\n'.join(vdef) + '\n')
    z = ['// GENERATED by tools/gen_wristcard.py -- do not edit. The Start Fight card\'s pieces: Piece(card, mirrored, tile),',
         '// card 0 RSQMBWC0 (grey), 1 RSQMBWC1 (gold), 2 RSQMBWC2 (Big Boss); each a voxel (VOXELDEF.txt) on a layer owned by',
         '// the off-hand weapon (bossfight.zs WristCard).',
         'class RSQMB_WCStates : Weapon',
         '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst TILES = %d;' % TILES,
         '\tstatic State Piece(int card, bool mir, int tile)',
         '\t{',
         '\t\tif (card < 0 || card > 2 || tile < 0 || tile >= TILES) return null;',
         '\t\tState s = GetDefaultByType("RSQMB_WCStates").FindState("Pieces");',
         '\t\tfor (int i = 0; i < card * 4 + (mir ? 2 : 0) + tile && s; i++) s = s.NextState;   // as Gun Cards\' side_states Walk',
         '\t\treturn s;',
         '\t}',
         '\tStates',
         '\t{',
         '\tPieces:']
    for L in frames: z.append('\t\t%s %s -1 Bright;' % (SPRITE, L))
    z += ['\t}', '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqmb', 'wristcard_states.zs'), 'w').write('\n'.join(z))
    for n, w, h, cw, chh in sizes: print('%s: %d x %d voxels, %.2f x %.2f cm' % (n, w, h, cw, chh))
    print('inside of the wrist at model X %.2f (Gun Cards\' watch card at %.2f), %d frames' % (INNER_X, gs.SIDE_X, len(frames)))


if __name__ == '__main__':
    main()
