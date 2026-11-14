#!/usr/bin/env python3
"""TEST ONLY: cut the integration's rig runs (rcE_full.sh + rcEdemo; runs rcE_final and rcE_final2, 640x640 frames)
into the sheets in MonsterRecolour/docs/. Frame numbers were picked from the runs' contact strips (2026-11-13).

    rcE_sheets.py FINAL_FRAMES FINAL2_FRAMES OUTDIR"""
import sys, os
from PIL import Image, ImageDraw

NOTE = "rig only, not headset-confirmed. Owner's full order and saved settings, -skill 6, rig01, sector light 224."

def frame(d, n, box, scale):
    im = Image.open(os.path.join(d, 'f%05d.ppm' % n)).convert('RGB').crop(box)
    return im.resize((int(im.width * scale), int(im.height * scale)), Image.NEAREST)

def sheet(out, title, rows, note2=''):
    """rows: list of (label, image)"""
    W = max(im.width for _, im in rows) + 20
    H = 44 + sum(im.height + 22 for _, im in rows) + (16 if note2 else 0)
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((8, 6), title, fill=(235, 235, 235)); dr.text((8, 22), NOTE, fill=(170, 170, 170))
    y = 44
    for lab, im in rows:
        dr.text((10, y), lab, fill=(230, 210, 90)); y += 14
        S.paste(im, (10, y)); y += im.height + 8
    if note2: dr.text((8, H - 16), note2, fill=(150, 150, 150))
    S.save(out, quality=90)
    print('wrote', out)

def main():
    f1, f2, out = sys.argv[1:4]
    os.makedirs(out, exist_ok=True)
    band = (0, 250, 640, 450)
    sheet(os.path.join(out, 'integ_01_twelve_colours_drawn_by_rsq_monsters.jpg'),
          "The Imp's painted art drawn by RSQ Monsters' own driver (RS_BDArt.zs) from pk3/RSQ_BDXMTiers_<Colour>.pk3",
          [('as shipped (Universal Entropy colours it, his ue_recolour 5), Green .. Yellow, front (run rcE_final f65)', frame(f1, 65, band, 1.5)),
           ('the same, side (f75)', frame(f1, 75, band, 1.5)),
           ('FireBlu .. White, front (f100)', frame(f1, 100, band, 1.5)),
           ('the same, side (f115)', frame(f1, 115, band, 1.5))],
          'Right to left: rung 1 (as shipped) to 7; then rung 8 (FireBlu) to 13 (White). The census logged every one: "hue <colour> wears none ART".')
    sheet(os.path.join(out, 'integ_02_blood_mist_red_pieces_coloured.jpg'),
          'Gibbed Red, Gray, FireBlu imps: the blood mist (SuperGore, BloodMistExtraBig) stays red; the pieces keep their imp\'s colour',
          [('alive, drawn from the art (run rcE_final f140; left to right Red, Gray, FireBlu)', frame(f1, 140, (0, 160, 640, 520), 1.0)),
           ('gibbed, frozen 5 tics later: the mist red, no coloured squares (f148, f150)', Image.fromarray(__import__('numpy').hstack([__import__('numpy').asarray(frame(f1, 148, (0, 120, 640, 520), 0.6)), __import__('numpy').asarray(frame(f1, 150, (0, 120, 640, 520), 0.6))]))),
           ('landing: the pieces in their imps\' colours, red, gray, and the FireBlu legs blue (f151, f152)', Image.fromarray(__import__('numpy').hstack([__import__('numpy').asarray(frame(f1, 151, (0, 220, 640, 460), 0.8)), __import__('numpy').asarray(frame(f1, 152, (0, 220, 640, 460), 0.8))])))],
          'Census at the freeze: 93 coloured things, 0 blood or mist wearing a tier tint; XDeathImpArm x1 per imp "hue fireblu / gray / red, ART".')
    sheet(os.path.join(out, 'integ_03_pairs_side_by_side.jpg'),
          'Imps 36 units apart in pairs (Green|Red, as shipped|Red, FireBlu|Gray, Red|as shipped), killed together',
          [('alive (run rcE_final f195)', frame(f1, 195, band, 1.5)),
           ('plain deaths, the corpses side by side (f240)', frame(f1, 240, band, 1.5)),
           ('second set, all four pairs killed by one explosive hit, after the blast (f277)', frame(f1, 277, band, 1.5))],
          'Census after each: 0 bodies or pieces lying on one imp\'s spot holding another\'s colour; the as-shipped imps\' pieces hold none.')
    sheet(os.path.join(out, 'integ_04_champions_flash_art_toggle.jpg'),
          "Champions (test only: every imp a champion, awake) and Universal Entropy (his ue_recolour 5) under the tier colour; the tier flash; the art option",
          [('World Tier 3 from the start: Blue, drawn from the art, under Champions\' flames (run rcE_final2 f60)', frame(f2, 60, band, 1.5)),
           ('World Tier raised to 4 mid-map: the tier flash (f84)', frame(f2, 84, band, 1.5)),
           ('after the flash: Purple, from the art (f100)', frame(f2, 100, band, 1.5)),
           ('RSQ Monsters > Painted Colour Art off: the live tint (f110)', frame(f2, 110, band, 1.5)),
           ('on again: the art (f120)', frame(f2, 120, band, 1.5))],
          'Log: 7 "tier tint back over a Champions tint"; rs_carry_dump: 7 wear their tier colour, 0 a Champions tint; Champions\' icons hold no colour.')

if __name__ == '__main__':
    main()
