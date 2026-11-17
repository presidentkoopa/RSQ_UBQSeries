# World words mockup (owner 2026-11-17, "Mock it up"): RSQ VisualRewards' REVENGE! and REVIVE! and Gun Bonsai VR's LEVEL UP!
# as floating signs in the 3D world instead of on the HUD. MOCKUP ONLY, no mod code.
#   REVENGE!  floats over the monster that downed you (who to go after)
#   REVIVE!   rises from the floor where you get back up (an arcade continue)
#   LEVEL UP! on the gun in your hand, at the muzzle
# Each word is a flat sign that always faces the player and keeps the same apparent size at any distance: its place follows
# the 3D anchor in perspective, its size on screen does not change. The motion is the SOTN entrance of
# VisualRewards/pk3/zscript/rsqvr/words.zs (design/mockups/word_motion/): tics 0-3 the smear (width x (1 + 0.3k), slant 0.45k,
# k = 1 - tic/4, drawn as the four slices of tools/gen_word_slices.py), the snap at tic 4, the flash between the two looks
# every 4 tics up to tic 28 (the light look first), the drift up 1.4 letter heights (1 - exp(-tic/10)), a 35-tic life, a
# 10-tic fade. Letters: the Word Font's default, Score Small (VisualRewards/pk3/graphics/rsqvrwf/QWSWnnn.png), painted in
# the SOTN two-tone look as words.zs TransSotn does. REVENGE magenta and REVIVE cyan are the families the game already uses
# for them (damnums/events.zs REVENGE_COL 8, REVIVE_COL 13); LEVEL UP is the series' arcade gold.
# Backgrounds: real in-engine frames of MAP01 on the rig (QuestZDoom 17.3, the owner's full load order, boss_full.sh with
# P=/home/claude/rig/work/gate_rel5, BD22_VR-Reloaded_2.0.5a, RES=720, sv_cheats 1, rsqtr_eye_m 1.6), run ww_b: a test-only
# probe (rig/work/world_words/probe.pk3, not shipped) put an imp 320 and then 640 units in front of the player, frozen.
import os, math, numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
if not os.path.isdir(os.path.join(REPO, 'VisualRewards')): REPO = '/home/claude/rsq_ubqseries'
GLYPHS = os.path.join(REPO, 'VisualRewards/pk3/graphics/rsqvrwf')
RUN = os.environ.get('WW_RUN', '/home/claude/rig/work/runs/ww_b/frames')
OUT = os.environ.get('WW_OUT', '/mnt/user-data/outputs/world_words')
def frame(i): return Image.open(os.path.join(RUN, 'f%05d.ppm' % ((i + 1) * 3))).convert('RGB')   # dump every 3 frames
BG_EMPTY, BG_NEAR, BG_FAR = frame(18), frame(22), frame(27)

# ---- the letters (Score Small: 28-pixel cells, 4 texture pixels a font pixel, outline grey 49) ----
K = 4; CELL = 28; SPACE = 4 * K
SLICE = [0, 8, 12, 20, 28]                  # words.zs SliceB for a 7-row font: slices 1-2 the top half, 3-4 the bottom
def glyph(c): return np.array(Image.open(os.path.join(GLYPHS, 'QWSW%03d.png' % ord(c))).convert('RGBA'))
def lighter(c): return tuple((v + 255) // 2 for v in c)
def paint(g, top, bot):
    # words.zs TransSotn: grey <= 75 -> the dark box (8, 8, 10); else colour x (0.55 + 0.45 l/255) x 1.15; top half / bottom half
    l = g[..., 0].astype(float); o = np.zeros(g.shape, np.uint8)
    for y in range(g.shape[0]):
        col = np.array(top if y < SLICE[2] else bot, float)
        k = (0.55 + 0.45 * l[y] / 255.0) * 1.15
        rgb = np.clip(col[None, :] * k[:, None], 0, 255)
        dark = l[y] <= 75
        rgb[dark] = (8, 8, 10)
        o[y, :, :3] = rgb; o[y, :, 3] = np.where(g[y, :, 3] > 0, 255, 0)
    return o
def word_image(text, top, bot, et):
    """the word at entrance tic et, in texture pixels (smear: four slices per letter, stretched and slanted)"""
    k = max(0.0, 1 - et / 4.0)
    light = 4 <= et < 28 and ((et - 4) // 4) % 2 == 0
    if light: top, bot = lighter(top), lighter(bot)
    sxk, shear = 1 + 0.3 * k, 0.45 * k
    gl = [None if c == ' ' else paint(glyph(c), top, bot) for c in text]
    width = sum(SPACE if g is None else g.shape[1] for g in gl)
    W = int(width * sxk + shear * CELL + 8); out = Image.new('RGBA', (W, CELL), (0, 0, 0, 0))
    cx = -width / 2.0
    for g in gl:
        if g is None: cx += SPACE; continue
        gw = g.shape[1]; ox = (cx + gw / 2.0) * sxk
        for j in range(4):
            y0, y1 = SLICE[j], SLICE[j + 1]
            s = Image.fromarray(g[y0:y1])
            if k > 0: s = s.resize((max(1, round(gw * sxk)), y1 - y0), Image.NEAREST)
            mid = (y0 + y1) / 2.0
            x = W / 2.0 + ox + shear * (CELL / 2.0 - mid) - s.width / 2.0
            out.alpha_composite(s, (int(round(x)), y0))
        cx += gw
    return out
S = 1.25                                    # texture pixel -> screen pixel: capitals 30 px, about 3.7 degrees in this view
CAP = 24 * S
def sign(text, top, bot, t):
    im = word_image(text, top, bot, t)
    im = im.resize((round(im.width * S), round(im.height * S)), Image.NEAREST)
    a = 1.0 if t <= 35 else max(0.0, 1 - (t - 35) / 10.0)
    if a < 1: im.putalpha(im.split()[3].point(lambda v: int(v * a)))
    return im
MAGENTA = ((230, 40, 220), (255, 170, 245))   # REVENGE_COL family 8
CYAN = ((20, 200, 230), (150, 250, 255))      # REVIVE_COL family 13
GOLD = ((240, 150, 20), (255, 236, 120))      # arcade gold (LEVEL UP)

# ---- the view (from the frames: the imp's feet at 320 and 640 units, eye 44 over the floor, pitch 0) ----
F, CX, CY = 456.0, 362.0, 350.0
def project(fwd, side, dz): return CX + F * side / fwd, CY - F * dz / fwd      # dz: height over the eye
# the rifle and the hands: anything behind the muzzle is hidden by them (REVIVE stands 72 units out)
a = np.array(BG_EMPTY).astype(int); mx, mn = a.max(2), a.min(2)
gm = ((mx - mn < 22) & (mx > 14)) | ((a[..., 2] > a[..., 0] * 0.9) & (a[..., 2] > a[..., 1] + 30) & (mx > 60))
gm[:405] = False; gm = ndimage.binary_closing(gm, iterations=2); lab, _ = ndimage.label(gm)
GUN = ndimage.binary_fill_holes(np.isin(lab, [lab[y, x] for x, y in ((600, 600), (470, 470), (650, 690)) if lab[y, x]]))
GUNM = Image.fromarray((GUN * 255).astype(np.uint8))
MUZZLE = (435, 423)                          # the rifle's muzzle tip in this frame (the laser starts there)

def put(canvas, im, cx, cy, behind_gun=False):
    x, y = int(round(cx - im.width / 2)), int(round(cy - im.height / 2))
    if not behind_gun: canvas.alpha_composite(im, (x, y)); return
    layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0)); layer.alpha_composite(im, (x, y))
    al = np.array(layer.split()[3]); al[GUN] = 0; layer.putalpha(Image.fromarray(al)); canvas.alpha_composite(layer)

PRE, LIFE, POST = 10, 45, 14
def rise(t): return 1.4 * CAP * (1 - math.exp(-t / 10.0))
SCENES = [
    ('REVENGE!', MAGENTA, BG_NEAR, 'REVENGE!  over the monster that got you', 'who to go after   (imp 320 units away)',
     lambda t: (363, 394 - 10 * F / 320 - CAP / 2 - rise(t), False)),          # 10 units over its head (words.zs)
    ('REVENGE!', MAGENTA, BG_FAR, 'REVENGE!  the same, further off', 'same size on screen at any distance   (imp 640 units away)',
     lambda t: (364.5, 334 - 10 * F / 640 - CAP / 2 - rise(t), False)),
    ('REVIVE!', CYAN, BG_EMPTY, 'REVIVE!  rises from where you get back up', 'like an arcade continue   (from the floor, 72 units ahead)',
     lambda t: (*project(72, -12, -44 + 38 * (1 - math.exp(-t / 9.0)))[:1], project(72, -12, -44 + 38 * (1 - math.exp(-t / 9.0)))[1] - CAP / 2, True)),
    ('LEVEL UP!', GOLD, BG_EMPTY, 'LEVEL UP!  on the gun in your hand', 'Gun Bonsai VR: at the muzzle of the gun that levelled',
     lambda t: (MUZZLE[0], MUZZLE[1] - 6 - CAP / 2 - rise(t), False)),
]
try:
    FB = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 19)
    FS = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 14)
except OSError: FB = FS = ImageFont.load_default()
TOPB, BOTB = 62, 30
def compose(si, t):
    text, (top, bot), bg, cap1, cap2, where = SCENES[si]
    W, H = bg.size
    c = Image.new('RGBA', (W, H + TOPB + BOTB), (16, 15, 20, 255)); c.paste(bg, (0, TOPB))
    v = Image.new('RGBA', bg.size, (0, 0, 0, 0)); v.paste(bg, (0, 0))
    wt = t - PRE
    if 0 <= wt < LIFE:
        x, y, behind = where(wt)
        put(v, sign(text, top, bot, wt), x, y, behind)
    c.paste(v, (0, TOPB))
    d = ImageDraw.Draw(c)
    d.text((12, 8), cap1, font=FB, fill=(255, 255, 255)); d.text((12, 36), cap2, font=FS, fill=(190, 190, 205))
    d.text((W - 12, 10), '%d / %d' % (si + 1, len(SCENES)), font=FS, fill=(150, 150, 165), anchor='ra')
    d.text((W - 12, 33), 'Mockup, not in engine', font=FB, fill=(255, 210, 90), anchor='ra')
    d.text((12, H + TOPB + 7), 'Background: real in-engine frame, MAP01 on the rig. The word is drawn on top: not in engine.', font=FS, fill=(140, 140, 155))
    return c.convert('RGB')

os.makedirs(OUT, exist_ok=True)
frames = [compose(si, t) for si in range(len(SCENES)) for t in range(PRE + LIFE + POST)]
# one palette for every frame (the backgrounds and every look of the three words), so only the word changes frame to frame
probe = Image.new('RGB', (frames[0].width * 2, frames[0].height * 2))
for i, si_t in enumerate([(0, PRE + 2), (1, PRE + 6), (2, PRE + 8), (3, PRE + 20)]):
    probe.paste(compose(*si_t), ((i % 2) * frames[0].width, (i // 2) * frames[0].height))
PAL = probe.quantize(255, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
q = [f.quantize(palette=PAL, dither=Image.Dither.NONE) for f in frames]
for name, ms in (('world_words_mockup.gif', 30), ('world_words_mockup_half_speed.gif', 60)):
    q[0].save(os.path.join(OUT, name), save_all=True, append_images=q[1:], duration=ms, loop=0, optimize=False)
# a still sheet: each scene at the snap, in the flash and settled
st = Image.new('RGB', (4 * 360, 4 * 401), (16, 15, 20))
for si in range(4):
    for j, wt in enumerate((1, 6, 12, 30)):
        st.paste(compose(si, PRE + wt).resize((360, 401), Image.LANCZOS), (j * 360, si * 401))
st.save(os.path.join(OUT, 'world_words_stills.png'))
for f in sorted(os.listdir(OUT)): print(f, os.path.getsize(os.path.join(OUT, f)))
