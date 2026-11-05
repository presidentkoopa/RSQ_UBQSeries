#!/usr/bin/env python3
"""gen_gauges.py -- the series' HUD bars, all four from coldcite's Top HP Bars art (tool only; never ships).

The owner, 2026-11-02: "we could repurpose and recolor the TopHPBar as a hud element for SlowMo, arrange it vertically,
change the colors or style." The owner, 2026-11-05: "the slowmo countdown bar should be visually similar to the left and
right hud bars you made earlier, all four of these bars should be visually consistent". So every bar is coldcite's
style-A bar (112 x 11, his block texture, "Feel free to use this in your mods") with ONE rim (his) and ONE well (a dark,
half-clear inside, so a fill reads on a bright wall and an empty bar still reads as a bar), stood on end or left lying.

VERTICAL GAUGES (the left and right ones; the fill grows from the bottom):
    <NAME>E.png   the empty gauge: his empty bar (HP_A_00), its rim and the shared well, rotated
    <NAME>F.png   the full gauge: his full bar (HP_A_99), the fill recoloured pixel by pixel (each pixel keeps its
                  brightness against the fill's mean, so his blocks stay; only the hue changes), rotated
    <NAME>W.png   the full gauge in white (the same blocks, brightness kept): the HUD tints it by the level, so the colour
                  moves as it fills, and draws its light (the moving band, the glint) with it

    RSQSMG*  ->  SlowMo/graphics/             SlowMo's adrenaline meter: electric cyan
    RSQGBG*  ->  GunBonsaiOffhandVR/graphics/ Gun Bonsai VR's Berserk Meter: blood red

HORIZONTAL BARS (left lying as he drew it; the fill grows from the left), the HUD tints the white one:
    <NAME>E.png   the empty bar: his rim and the shared well
    <NAME>W.png   the full bar in white

    RSQSMH*  ->  SlowMo/graphics/             SlowMo's Real-Time Countdown bar (Green or its colour row)
    RSQMBH*  ->  Miniboss/graphics/           Miniboss's Bossfight meter (red while filling, gold when full)

THE BOSSFIGHT METER'S CROWNED SKULL (original pixel art, 16 x 16, drawn for the series 11-05; the owner kept it from the
mock-up): RSQMBSK0 dim (bone greyed, the meter not full), RSQMBSK1 lit (the bone shows, red eyes). The HUD draws the dim
one, then the lit one cropped from the bottom up to the meter's fill, so the skull fills with the bar.

THE COUNTDOWN BAR'S HOURGLASS (original pixel art, 16 x 16, drawn for the series 11-05; owner 11-05: "hourglass icon by the
slowdown bar"): RSQSMHG, gold plates, pale glass, sand running down. Same grid and outline as the skull, so SlowMo draws it
at the skull's size and the two rows (meter, countdown) line up.

Run from anywhere: python VisualRewards/tools/gen_gauges.py"""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
TOP = os.path.dirname(HERE)
SERIES = os.path.dirname(TOP)
SRC = os.path.join(TOP, 'original_1.04', 'graphics')
RIM = (50, 50, 50)
WELL = (8, 10, 12, 120)     # the one well inside every bar's rim (11-05: all four bars alike)

GAUGES = [
    ('RSQSMG', os.path.join(SERIES, 'SlowMo', 'graphics'), (60, 220, 255)),
    ('RSQGBG', os.path.join(SERIES, 'GunBonsaiOffhandVR', 'graphics'), (230, 40, 40)),
]
HBARS = [
    ('RSQSMH', os.path.join(SERIES, 'SlowMo', 'graphics')),
    ('RSQMBH', os.path.join(SERIES, 'Miniboss', 'graphics')),
]
SKULL_OUT = os.path.join(SERIES, 'Miniboss', 'graphics')
HOURGLASS_OUT = os.path.join(SERIES, 'SlowMo', 'graphics')

# '#' outline, 'o' crown gold, 'w' bone, 'r' eye
SK = ['#..#...##...#..#',
      '#o#.#.#oo#.#.#o#',
      '#oo#o#oooo#o#oo#',
      '.#oooooooooooo#.',
      '.#oooooooooooo#.',
      '..############..',
      '.#wwwwwwwwwwww#.',
      '#wwwwwwwwwwwwww#',
      '#ww###wwww###ww#',
      '#ww#r#wwww#r#ww#',
      '#ww###w##w###ww#',
      '.#wwwww##wwwww#.',
      '..#wwwwwwwwww#..',
      '..#w#w#w#w#w#..',
      '...#w#w#w#w#...',
      '....########....']

# '#' outline, 'o' plate gold, 'g' glass, 's' sand
HG = ['.##############.',
      '.#oooooooooooo#.',
      '.##############.',
      '..#gggggggggg#..',
      '..#gggggggggg#..',
      '...#ssssssss#...',
      '....#ssssss#....',
      '.....#ssss#.....',
      '......#ss#......',
      '.....#gssg#.....',
      '....#ggssgg#....',
      '...#ggssssgg#...',
      '..#ssssssssss#..',
      '.##############.',
      '.#oooooooooooo#.',
      '.##############.']


def luma(p): return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]


def fill_pixels(im):
    p = im.load()
    return [(x, y) for y in range(im.size[1]) for x in range(im.size[0]) if p[x, y][3] > 0 and p[x, y][:3] != RIM]


def recolour_fill(im, colour):
    im = im.convert('RGBA').copy()
    p = im.load()
    fill = fill_pixels(im)
    mean = sum(luma(p[x, y]) for x, y in fill) / max(1, len(fill))
    for x, y in fill:
        k = luma(p[x, y]) / mean
        p[x, y] = tuple(min(255, int(c * k)) for c in colour) + (p[x, y][3],)
    return im


def with_well(empty, full):
    """his empty bar with the shared well wherever his full bar has fill and the empty one is clear"""
    e = empty.copy()
    pe = e.load()
    for x, y in fill_pixels(full):
        if pe[x, y][3] == 0:
            pe[x, y] = WELL
    return e


def skull(lit):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    for y, r in enumerate(SK):
        for x, ch in enumerate(r[:16]):
            if ch == '#': p[x, y] = (15, 15, 15, 255)
            elif ch == 'o': p[x, y] = (255, 200, 40, 255) if lit else (170, 130, 30, 255)
            elif ch == 'w': p[x, y] = (235, 225, 205, 255) if lit else (90, 85, 80, 255)
            elif ch == 'r': p[x, y] = (255, 40, 30, 255) if lit else (110, 30, 25, 255)
    return im


def hourglass():
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    for y, r in enumerate(HG):
        assert len(r) == 16, (y, r)
        for x, ch in enumerate(r):
            if ch == '#': p[x, y] = (15, 15, 15, 255)
            elif ch == 'o': p[x, y] = (255, 200, 40, 255)
            elif ch == 'g': p[x, y] = (150, 185, 205, 120)
            elif ch == 's': p[x, y] = (245, 220, 150, 255)
    return im


def main():
    empty = Image.open(os.path.join(SRC, 'HP_A_00.png')).convert('RGBA')
    full = Image.open(os.path.join(SRC, 'HP_A_99.png')).convert('RGBA')
    well = with_well(empty, full)
    white = recolour_fill(full, (255, 255, 255))
    for name, out, colour in GAUGES:
        os.makedirs(out, exist_ok=True)
        # rotate 90 degrees counter-clockwise: the bar's left end (where it fills from) goes to the bottom
        well.rotate(90, expand=True).save(os.path.join(out, name + 'E.png'), optimize=True)
        recolour_fill(full, colour).rotate(90, expand=True).save(os.path.join(out, name + 'F.png'), optimize=True)
        white.rotate(90, expand=True).save(os.path.join(out, name + 'W.png'), optimize=True)
        print(f'{name}E / {name}F / {name}W -> {out}  (11 x 112, fill {colour})')
    for name, out in HBARS:
        os.makedirs(out, exist_ok=True)
        well.save(os.path.join(out, name + 'E.png'), optimize=True)
        white.save(os.path.join(out, name + 'W.png'), optimize=True)
        print(f'{name}E / {name}W -> {out}  (112 x 11, tinted by the HUD)')
    os.makedirs(SKULL_OUT, exist_ok=True)
    skull(False).save(os.path.join(SKULL_OUT, 'RSQMBSK0.png'), optimize=True)
    skull(True).save(os.path.join(SKULL_OUT, 'RSQMBSK1.png'), optimize=True)
    print(f'RSQMBSK0 / RSQMBSK1 -> {SKULL_OUT}  (16 x 16, the crowned skull)')
    os.makedirs(HOURGLASS_OUT, exist_ok=True)
    hourglass().save(os.path.join(HOURGLASS_OUT, 'RSQSMHG.png'), optimize=True)
    print(f'RSQSMHG -> {HOURGLASS_OUT}  (16 x 16, the hourglass)')


if __name__ == '__main__':
    main()
