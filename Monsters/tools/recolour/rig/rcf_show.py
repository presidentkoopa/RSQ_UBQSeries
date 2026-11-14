#!/usr/bin/env python3
"""TEST ONLY: the console script of an rcFshow run (frames for the dying-body census), and the sheet cutter.
    rcf_show.py script                        the scenes below, each held frozen with its code shown (rcs_phase)
    rcf_show.py fatality                      one red Arachnotron killed by a fatality (the player holds fists): frames over time
    rcf_show.py sheet BEFORE_FRAMES AFTER_FRAMES OUT.jpg   per scene: the last frame of its code, before | after"""
import sys, os, glob
SCENES = [  # (title, class index, first colour, how many, damage type index, freeze after tics)
    ('Chaingunner, fire: the burning man', 0, 8, 6, 2, 30),
    ('Chaingunner, blast: the blasted crawler', 0, 8, 6, 3, 45),
    ('Arch-vile, SSG: the armless crawler', 1, 8, 6, 10, 70),
    ('Revenant, gibbed: bone dust and pieces', 5, 8, 6, 1, 30),
    ('Cacodemon, fire: the burning Cacodemon', 6, 8, 6, 2, 20),
    ("Imp, a captured marine's Taunt: born again", 8, 8, 6, 6, 12),
    ('Blood Demon, plain death', 3, 8, 6, 0, 40),
    ('Void Spectre, plain death', 4, 8, 6, 0, 40),
]
if sys.argv[1] == 'script':
    out = ['god', 'notarget', 'wait 30']
    for i, (t, c, f, n, d, fr) in enumerate(SCENES):
        out += ['netevent rcs_phase 0', 'netevent rcs_row %d %d %d' % (c, f, n), 'wait 3', 'netevent rcs_tier', 'wait 6',
                'netevent rcs_kill %d %d' % (d, fr), 'wait %d' % (fr + 4), 'netevent rcs_census', 'netevent rcs_phase %d' % (i + 1), 'wait 40', 'netevent rcs_phase 0', 'netevent rcs_go', 'wait 2']
    out += ['wait 10', 'quit']
    print('; '.join(out))
elif sys.argv[1] == 'fatality':
    out = ['god', 'notarget', 'wait 30', 'netevent rcs_fists', 'netevent rcs_row 2 10 1', 'wait 3', 'netevent rcs_tier', 'wait 6',
           'netevent rcs_fists', 'netevent rcs_kill 5 0', 'wait 40', 'netevent rcs_census', 'wait 40', 'netevent rcs_census', 'wait 40', 'netevent rcs_census', 'wait 60', 'netevent rcs_census', 'wait 10', 'quit']
    print('; '.join(out))
elif sys.argv[1] == 'sheet':
    # per scene: the last frame that shows its code (rcf_sheets.code reads the marker), before | after, the row cropped
    import importlib.util
    from PIL import Image, ImageDraw
    spec = importlib.util.spec_from_file_location('rs', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'rcf_sheets.py'))
    rs = importlib.util.module_from_spec(spec); spec.loader.exec_module(rs)
    def last(frames):
        got = {}
        for f in sorted(glob.glob(os.path.join(frames, '*.ppm'))):
            c = rs.code(f)
            if 1 <= c <= len(SCENES): got[c] = f
        return got
    B, A = last(sys.argv[2]), last(sys.argv[3])
    CW, CH = 480, 230; Y0 = 150
    out = Image.new('RGB', (CW * 2 + 20, 40 + (CH + 26) * len(SCENES)), (18, 18, 18)); d = ImageDraw.Draw(out)
    d.text((8, 6), 'Dying bodies, before (left: the branch as it was) and after (right: the census fixes), frozen; rig only, not headset-confirmed', fill=(255, 255, 255))
    d.text((8, 20), 'rig01, sector light 224, 260 units; six monsters each: FireBlu, Gray, Red, Abyss, Black, White (left to right)', fill=(200, 200, 200))
    for i, sc in enumerate(SCENES):
        y = 40 + i * (CH + 26)
        d.text((8, y + 4), sc[0], fill=(255, 255, 0))
        for j, src in enumerate((B, A)):
            f = src.get(i + 1)
            if f: out.paste(Image.open(f).convert('RGB').crop((0, Y0, 480, Y0 + CH)), (j * (CW + 20), y + 20))
            else: d.text((j * (CW + 20) + 10, y + 60), '(no frame)', fill=(255, 80, 80))
    out.save(sys.argv[4], quality=88)
    print('wrote', sys.argv[4], 'scenes before', sorted(B), 'after', sorted(A))
