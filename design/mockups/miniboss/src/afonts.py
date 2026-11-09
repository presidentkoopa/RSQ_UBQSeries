"""Fonts for the arcade-language mockups, decoded from the real files via design/mockups/fonts/make_font_sheets.py."""
import io, os, sys, zipfile
from PIL import Image, ImageDraw, ImageFilter, ImageChops
REPO = '/home/claude/rsq_ubqseries'
sys.path.insert(0, os.path.join(REPO, 'design', 'mockups', 'fonts'))
import make_font_sheets as M

W = M.Wad('/home/claude/gamedata/doom2.wad')
PAL = W.pal
def pal(i): return PAL[i]
def near(rgb):
    """nearest PLAYPAL colour"""
    return min(PAL, key=lambda p: sum((p[k] - rgb[k]) ** 2 for k in range(3)))

def _crop(im):
    b = im.getbbox(); return im.crop((b[0], 0, b[2], im.height)) if b else im

FON, _ = M.fon2(open(os.path.join(REPO, 'Score', 'RSSCFON.fon2'), 'rb').read())
FN2, _ = M.fon2(open(os.path.join(REPO, 'Score', 'RSSCFN2.fon2'), 'rb').read())
_js = os.path.join(REPO, 'GunCards', 'tools', 'card_art', 'jfo', 'small')
_jb = os.path.join(REPO, 'GunCards', 'tools', 'card_art', 'jfo', 'big')
JFO = {int(f[5:8]): _crop(M.png(os.path.join(_js, f))) for f in os.listdir(_js)}
JFOB = {int(f[5:8]): _crop(M.png(os.path.join(_jb, f))) for f in os.listdir(_jb)}
# JFO gaps filled with IWAD DoomFont letters, as the Wheel does (gen_jfo.py)
STC = {int(n[5:]): W.patch(n) for n in W.dir if n.startswith('STCFN') and n[5:].isdigit()}
for c, g in STC.items():
    if c not in JFO:
        JFO[c] = g.resize((g.width * 4, g.height * 4), Image.NEAREST)  # DoomFont scaled to JFO's 32 px cell (approx.)
DBIG = M.fon2(W.lump('DBIGFONT'))[0] if W.lump('DBIGFONT') else {}   # (this IWAD has no DBIGFONT: not used here)
STTNUM = {48 + i: W.patch('STTNUM%d' % i) for i in range(10)}; STTNUM[45] = W.patch('STTMINUS'); STTNUM[37] = W.patch('STTPRCNT')
WINUM = {48 + i: W.patch('WINUM%d' % i) for i in range(10)}; WINUM[45] = W.patch('WIMINUS'); WINUM[37] = W.patch('WIPCNT'); WINUM[58] = W.patch('WICOLON')
_ca = os.path.join(REPO, 'GunCards', 'tools', 'card_art')
ERMAC = {48 + i: M.png(os.path.join(_ca, 'digit_%d.png' % i)) for i in range(10)}; ERMAC[43] = M.png(os.path.join(_ca, 'digit_plus.png'))
_cl = os.path.join(REPO, 'VisualRewards', 'tools', 'dn_art', 'classic')
DAMNUM = {48 + i: M.png(os.path.join(_cl, 'QC11%s0.png' % 'ABCDEFGHIJ'[i])) for i in range(10)}
_z = zipfile.ZipFile('/home/claude/gamedata/brutal22test6.pk3')
def _bd(n): return Image.open(io.BytesIO(_z.read('graphics/HUDS/Font/%s.png' % n))).convert('RGBA')
DIGNUM = {48 + i: _bd('DIGNUM%dS' % i) for i in range(10)}; DIGNUM[45] = _bd('DIGMINUS')
DIGL = {48 + i: _bd('DIGLNUM%d' % i) for i in range(10)}

def text(font, s, scale=1, gap=1, space=None):
    """string -> RGBA at native size then nearest-scaled (chunky)"""
    sp = space if space is not None else max(3, (font.get(48) or next(iter(font.values()))).width // 2)
    gl = []
    for ch in s:
        g = font.get(ord(ch)) or font.get(ord(ch.upper()))
        gl.append(g if g is not None else Image.new('RGBA', (sp, 1), (0, 0, 0, 0)))
    return M.row(gl, scale, gap * scale if scale >= 1 else gap)

def tint(im, lo, hi): return M.tint(im, lo, hi)

def flat(im, rgb):
    """keep alpha, paint one colour"""
    out = Image.new('RGBA', im.size, rgb + (0,)); out.putalpha(im.getchannel('A')); return out

def glow(im, rgb, radius=6, strength=1.6, outline=2):
    """dark pixel outline + soft coloured glow behind a glyph run, returned on a padded canvas"""
    pad = radius * 3 + outline + 2
    W_, H_ = im.width + 2 * pad, im.height + 2 * pad
    base = Image.new('RGBA', (W_, H_), (0, 0, 0, 0)); base.alpha_composite(im, (pad, pad))
    a = base.getchannel('A')
    ol = a
    for _ in range(outline): ol = ol.filter(ImageFilter.MaxFilter(3))
    g = a.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(radius))
    g = g.point(lambda v: min(255, int(v * strength)))
    out = Image.new('RGBA', (W_, H_), (0, 0, 0, 0))
    out.alpha_composite(Image.merge('RGBA', (*Image.new('RGB', (W_, H_), rgb).split(), g)))
    out.alpha_composite(Image.merge('RGBA', (*Image.new('RGB', (W_, H_), (0, 0, 0)).split(), ol.point(lambda v: int(v * 0.85)))))
    out.alpha_composite(base)
    return out, pad

def seven(s, h, on=(0xFF, 0x2A, 0x1A), off=(0x3a, 0x14, 0x16), off_alpha=110):
    """DOWN's seven-segment digits (downhud.zs segment table), s like '09:00' or '12'"""
    MASK = {'0': 0x3F, '1': 0x06, '2': 0x5B, '3': 0x4F, '4': 0x66, '5': 0x6D, '6': 0x7D, '7': 0x07, '8': 0x7F, '9': 0x6F}
    dw = h * 0.53; th = max(2, int(h * 0.11)); gap = int(h * 0.2)
    W_ = 0
    for ch in s: W_ += (int(dw) + gap) if ch != ':' else (th * 2 + gap)
    im = Image.new('RGBA', (W_ + 2, h + 2), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    x = 0
    for ch in s:
        if ch == ':':
            for yy in (h * 0.3, h * 0.7): d.rectangle([x, yy - th / 2, x + th, yy + th / 2], fill=on + (255,))
            x += th * 2 + gap; continue
        m = MASK.get(ch, 0); w = int(dw); hh = h / 2
        seg = [(x + th, 0, x + w - th, th), (x + w - th, th, x + w, hh - 1), (x + w - th, hh + 1, x + w, h - th),
               (x + th, h - th, x + w - th, h), (x, hh + 1, x + th, h - th), (x, th, x + th, hh - 1), (x + th, hh - th / 2, x + w - th, hh + th / 2)]
        for k, r in enumerate(seg):
            lit = m & (1 << k)
            d.rectangle(r, fill=(on + (255,)) if lit else (off + (off_alpha,)))
        x += w + gap
    return im
