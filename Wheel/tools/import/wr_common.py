"""RSQ Wheel import tools: the shared parts (reading palettes, colour maths, writing into a Wheel folder).

python3 + Pillow only. Nothing here touches a Wheel folder except through upsert_block() and add_menu_choice(),
which write marked blocks that a second run replaces instead of duplicating:

    // >>> wr_import <kind> <Name>
    ...
    // <<< wr_import <kind> <Name>
"""
import io, os, re, shutil, struct, sys, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------------------------------------
# Names. The ring reads WRPALS / WRFONTS by splitting on spaces and braces and dropping // comments,
# and matches the name without caring about case. So a name is letters, digits, - and _ only.
# ---------------------------------------------------------------------------------------------
BUILTIN_PALETTES = ['Standard', 'Doom', 'Hell', 'Tech']
BUILTIN_FONTSETS = ['StatusBar', 'SmallGold', 'SmallGrey', 'DoomFont']


def clean_name(s):
    """'my cool-palette (v2).gpl' -> 'MyCool-paletteV2'"""
    s = os.path.basename(s)
    for ext in ('.gz',):
        if s.lower().endswith(ext): s = s[:-len(ext)]
    s = os.path.splitext(s)[0]
    parts = re.split(r'[^A-Za-z0-9_\-]+', s)
    out = ''.join(p[:1].upper() + p[1:] for p in parts if p)
    if not out: out = 'Imported'
    if not out[0].isalpha(): out = 'P' + out
    return out[:32]


# ---------------------------------------------------------------------------------------------
# Colour maths: OKLab, for "how light" and "which hue" that match what the eye sees.
# ---------------------------------------------------------------------------------------------
def _lin(c):
    c /= 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def oklab(rgb):
    r, g, b = (_lin(v) for v in rgb[:3])
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = (v ** (1 / 3) if v > 0 else 0 for v in (l, m, s))
    return (0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s)


def hexrgb(rgb):
    return '%02X%02X%02X' % tuple(rgb[:3])


# ---------------------------------------------------------------------------------------------
# Palettes in the forms people download. Each reader returns [(r, g, b, name or None), ...].
# ---------------------------------------------------------------------------------------------
def _from_gpl(text):
    out = []
    for ln in text.splitlines():
        ln = ln.strip()
        if not ln or ln.startswith('#') or ln.startswith('GIMP') or ':' in ln.split(' ')[0]:
            continue
        m = re.match(r'(\d+)\s+(\d+)\s+(\d+)\s*(.*)$', ln)
        if m:
            nm = m.group(4).strip() or None
            out.append((int(m.group(1)), int(m.group(2)), int(m.group(3)), nm))
    return out


def _from_jasc(text):
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    n = int(lines[2])
    out = []
    for ln in lines[3:3 + n]:
        r, g, b = (int(v) for v in ln.split()[:3])
        out.append((r, g, b, None))
    return out


def _from_hex_text(text):
    """lospec .hex / .txt (one RRGGBB a line, '#' optional; Paint.NET's AARRGGBB too)."""
    out = []
    for ln in text.splitlines():
        ln = ln.split(';')[0].strip()
        for m in re.finditer(r'(?<![0-9A-Fa-f])#?([0-9A-Fa-f]{8}|[0-9A-Fa-f]{6})(?![0-9A-Fa-f])', ln):
            h = m.group(1)
            if len(h) == 8: h = h[2:]          # Paint.NET writes alpha first
            out.append((int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), None))
    return out


def _from_ase(data):
    """Adobe Swatch Exchange: RGB, Gray and (roughly) CMYK swatches; groups ignored."""
    if data[:4] != b'ASEF': raise ValueError('not an ASE file')
    nblk = struct.unpack('>I', data[8:12])[0]
    p = 12
    out = []
    for _ in range(nblk):
        btype, blen = struct.unpack('>HI', data[p:p + 6]); p += 6
        body = data[p:p + blen]; p += blen
        if btype != 0x0001: continue
        nlen = struct.unpack('>H', body[:2])[0]
        name = body[2:2 + nlen * 2].decode('utf-16-be', 'ignore').rstrip('\0') or None
        q = 2 + nlen * 2
        model = body[q:q + 4]; q += 4
        if model == b'RGB ':
            r, g, b = struct.unpack('>3f', body[q:q + 12])
        elif model == b'Gray':
            r = g = b = struct.unpack('>f', body[q:q + 4])[0]
        elif model == b'CMYK':
            c, m, y, k = struct.unpack('>4f', body[q:q + 16])
            r, g, b = (1 - c) * (1 - k), (1 - m) * (1 - k), (1 - y) * (1 - k)
        else:
            continue   # LAB swatches: rare in downloads; skipped
        out.append((int(round(r * 255)), int(round(g * 255)), int(round(b * 255)), name))
    return out


def _from_riff_pal(data):
    """Microsoft RIFF PAL ('RIFF' .. 'PAL ' 'data')."""
    i = data.find(b'data')
    n = struct.unpack('<H', data[i + 10:i + 12])[0]
    return [(data[i + 12 + 4 * k], data[i + 13 + 4 * k], data[i + 14 + 4 * k], None) for k in range(n)]


def _from_raw(data):
    """768 bytes a palette (Doom PLAYPAL, Build PALETTE.DAT, Adobe .act). PLAYPAL holds 14: the first
    is the game's. Build's 6-bit palettes (every byte under 64) are widened to 8 bits."""
    pal = data[:768]
    if max(pal) < 64:
        pal = bytes(min(255, (v << 2) | (v >> 4)) for v in pal)
    out = [(pal[3 * k], pal[3 * k + 1], pal[3 * k + 2], None) for k in range(256)]
    if len(data) in (772,):    # .act with a colour count
        n = struct.unpack('>H', data[768:770])[0]
        if 0 < n <= 256: out = out[:n]
    return out


def _wad_lump(data, want):
    if data[:4] not in (b'IWAD', b'PWAD'): return None
    n, off = struct.unpack('<ii', data[4:12])
    for i in range(n):
        o, sz, nm = struct.unpack('<ii8s', data[off + 16 * i:off + 16 * i + 16])
        if nm.rstrip(b'\0').upper() == want: return data[o:o + sz]
    return None


def _zip_lump(path, want):
    with zipfile.ZipFile(path) as z:
        for n in z.namelist():
            base = os.path.splitext(os.path.basename(n))[0].upper()
            if base == want.decode():
                return z.read(n)
    return None


def _from_png(path):
    """A swatch strip or grid (lospec's PNG exports, a 1-pixel-per-colour strip, a screenshot of
    swatches): every distinct opaque colour in reading order. More than 64 distinct colours means
    it is a picture, not a swatch: it is boiled down to 16 with Pillow's median cut."""
    from PIL import Image
    im = Image.open(path).convert('RGBA')
    px = im.load()
    seen, out = set(), []
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            r, g, b, a = px[x, y]
            if a < 128 or (r, g, b) in seen: continue
            seen.add((r, g, b)); out.append((r, g, b, None))
    if len(out) > 64:
        q = im.convert('RGB').quantize(16, method=Image.Quantize.MEDIANCUT)
        p = q.getpalette()[:48]
        out = [(p[3 * k], p[3 * k + 1], p[3 * k + 2], None) for k in range(16)]
    return out


def read_palette(path):
    """Any of: .gpl .pal (JASC or RIFF or raw) .hex .txt .ase .act .lmp/PLAYPAL .wad .pk3 .png.
    Returns [(r, g, b, name)] in the file's own order, duplicates removed."""
    data = open(path, 'rb').read()
    ext = os.path.splitext(path)[1].lower()
    cols = None
    if ext == '.png':
        cols = _from_png(path)
    elif data[:4] == b'ASEF':
        cols = _from_ase(data)
    elif data[:4] == b'RIFF' and b'PAL ' in data[:12]:
        cols = _from_riff_pal(data)
    elif data[:4] in (b'IWAD', b'PWAD'):
        lump = _wad_lump(data, b'PLAYPAL')
        if lump is None: raise ValueError('%s: no PLAYPAL lump' % path)
        cols = _from_raw(lump)
    elif data[:2] == b'PK':
        lump = _zip_lump(path, b'PLAYPAL')
        if lump is None: raise ValueError('%s: no PLAYPAL in the pk3' % path)
        cols = _from_raw(lump)
    else:
        try:
            text = data.decode('utf-8-sig')
            if '\0' in text: raise UnicodeError
        except UnicodeError:
            text = None
        if text is not None and text.lstrip().startswith('GIMP Palette'):
            cols = _from_gpl(text)
        elif text is not None and text.lstrip().startswith('JASC-PAL'):
            cols = _from_jasc(text)
        elif text is not None:
            cols = _from_hex_text(text)
        elif len(data) >= 768 and len(data) % 768 in (0, 4):
            cols = _from_raw(data)
    if not cols:
        raise ValueError('%s: no colours found (not a palette format these tools read)' % path)
    seen, out = set(), []
    for c in cols:
        if c[:3] in seen: continue
        seen.add(c[:3]); out.append(c)
    return out


# ---------------------------------------------------------------------------------------------
# Writing into a Wheel folder.
# ---------------------------------------------------------------------------------------------
def marker(kind, name):
    return ('// >>> wr_import %s %s' % (kind, name), '// <<< wr_import %s %s' % (kind, name))


def upsert_block(path, kind, name, body):
    """Put body between the markers for (kind, name) at the end of the file, replacing an earlier
    copy. Creates the file when missing."""
    text = open(path, encoding='utf-8').read() if os.path.exists(path) else ''
    a, b = marker(kind, name)
    pat = re.compile(re.escape(a) + r'\n.*?' + re.escape(b) + r'\n?', re.S)
    text = pat.sub('', text)
    if text and not text.endswith('\n'): text += '\n'
    text += a + '\n' + body.rstrip('\n') + '\n' + b + '\n'
    open(path, 'w', encoding='utf-8').write(text)


def read_blocks(path, kind):
    """{name: body} of the marked blocks of that kind already in the file."""
    if not os.path.exists(path): return {}
    text = open(path, encoding='utf-8').read()
    out = {}
    for m in re.finditer(r'// >>> wr_import %s (\S+)\n(.*?)// <<< wr_import %s \1\n' % (kind, kind), text, re.S):
        out[m.group(1)] = m.group(2)
    return out


def names_in(path, keyword):
    """Every '<keyword> <Name> {' in a WRPALS / WRFONTS file, comments dropped."""
    if not os.path.exists(path): return []
    text = re.sub(r'//[^\n]*', '', open(path, encoding='utf-8').read())
    return re.findall(r'\b%s\s+([A-Za-z0-9_\-]+)\s*\{' % keyword, text, re.I)


def add_menu_choice(wheel, option_list, value, label):
    """Add a line to MENUDEF's OptionString <option_list> so the name shows in Options -> RSQ Wheel.
    The text field beside it takes any name anyway; this only saves typing."""
    path = os.path.join(wheel, 'MENUDEF.txt')
    if not os.path.exists(path): return False
    text = open(path, encoding='utf-8').read()
    m = re.search(r'OptionString\s+"%s"\s*\{(.*?)\}' % re.escape(option_list), text, re.S)
    if not m: return False
    body = m.group(1)
    line = '\t"%s", "%s"   // wr_import' % (value, label.replace('"', "'"))
    if re.search(r'^\s*"%s"\s*,' % re.escape(value), body, re.M | re.I):
        body = re.sub(r'^\s*"%s"\s*,[^\n]*\n?' % re.escape(value), '', body, flags=re.M | re.I)
    body = body.rstrip() + '\n' + line + '\n'
    text = text[:m.start(1)] + body + text[m.end(1):]
    open(path, 'w', encoding='utf-8').write(text)
    return True


def find_wheel(start=None):
    """The Wheel folder these tools sit in (Wheel/tools/import/), or None."""
    p = os.path.abspath(start or os.path.join(HERE, '..', '..'))
    return p if os.path.exists(os.path.join(p, 'WRPALS.txt')) else None


def prepare_target(wheel_src, out, into):
    """Where to write. --into writes straight into that Wheel folder; otherwise the source Wheel
    is copied to out (tools/ and old rig output left behind) and the copy is written."""
    if into:
        if not os.path.exists(os.path.join(into, 'WRPALS.txt')):
            sys.exit('--into %s: that is not a Wheel folder (no WRPALS.txt)' % into)
        return os.path.abspath(into)
    if not wheel_src or not os.path.exists(os.path.join(wheel_src, 'WRPALS.txt')):
        sys.exit('no Wheel folder to copy: give --wheel <path to Wheel>')
    out = os.path.abspath(out)
    if os.path.abspath(wheel_src) == out:
        sys.exit('--out is the Wheel folder itself; use --into for that')
    if os.path.exists(out): shutil.rmtree(out)
    shutil.copytree(wheel_src, out, ignore=shutil.ignore_patterns('tools', '.git*', '*.pk3'))
    return out
