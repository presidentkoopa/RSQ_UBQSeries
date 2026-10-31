#!/usr/bin/env python3
"""RSQ Wheel: import every palette, font and voxel picture in a folder, in one go.

    python3 import_all.py <folder> [--wheel <Wheel>] [--out <folder>] [--into <Wheel>] [--pk3 <file>]
                          [--avoid <pk3/wad> ...]

See README.md. Default: the Wheel folder these tools sit in (Wheel/tools/import/ -> Wheel/) is
COPIED to <folder>/../Wheel_imported and everything is written into the copy; the real Wheel folder
is only written with --into. --pk3 also zips the result, ready to load after the series.
"""
import argparse, os, re, shlex, sys, zipfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_common, wr_import_palette, wr_import_font, wr_make_voxels

PAL_EXT = ('.gpl', '.pal', '.hex', '.txt', '.ase', '.act', '.lmp', '.wad')
FONT_EXT = ('.ttf', '.otf', '.ttc', '.bdf', '.pcf', '.gz')


def sidecar(path):
    """<file>.args (or <folder>/args.txt): extra options for that one input, e.g. --size 12 --name Foo"""
    for p in (path + '.args', os.path.join(path, 'args.txt')):
        if os.path.isfile(p): return shlex.split(' '.join(l.split('#')[0] for l in open(p)))
    return []


def classify(folder):
    pals, fonts, voxels = [], [], []
    for entry in sorted(os.listdir(folder)):
        p = os.path.join(folder, entry)
        low = entry.lower()
        if entry.startswith('.') or low.endswith('.args') or low in ('readme.md', 'args.txt'): continue
        if os.path.isdir(p):
            sub = low.rstrip('/')
            if sub in ('palettes', 'palette'):
                pals += [os.path.join(p, f) for f in sorted(os.listdir(p)) if not f.endswith('.args') and not f.startswith('.')]
            elif sub in ('fonts', 'font'):
                fonts += [os.path.join(p, f) for f in sorted(os.listdir(p)) if not f.endswith('.args') and not f.startswith('.')]
            elif sub in ('voxels', 'voxel'):
                loose = [os.path.join(p, f) for f in sorted(os.listdir(p)) if f.lower().endswith('.png')]
                if loose: voxels.append(('Voxels', loose))
                for f in sorted(os.listdir(p)):
                    if os.path.isdir(os.path.join(p, f)): voxels.append((wr_common.clean_name(f), [os.path.join(p, f)]))
            else:
                fonts.append(p)        # a folder of one-glyph PNGs
        elif low.endswith(FONT_EXT):
            fonts.append(p)
        elif low.endswith('.png'):
            (fonts if re.search(r'\d+x\d+', low) else pals).append(p)
        elif low.endswith(PAL_EXT):
            pals.append(p)
        else:
            print('  skipped %s (not a palette, font or picture these tools read)' % entry)
    return pals, fonts, voxels


def sprite_names(files):
    """4-letter sprite names in pk3/wad files (lumps like PISGA0 / PLAYA2A8), so a voxel set never
    takes a name another mod's actor already draws with"""
    out = set()
    pat = re.compile(r'^([A-Z0-9]{4})[A-Z\[\]\\^][0-8]([A-Z\[\]\\^][0-8])?$')
    for f in files:
        try:
            if zipfile.is_zipfile(f):
                names = [os.path.splitext(os.path.basename(n))[0].upper() for n in zipfile.ZipFile(f).namelist()]
            else:
                import struct
                d = open(f, 'rb').read()
                n, off = struct.unpack('<ii', d[4:12])
                names = [d[off + 16 * i + 8:off + 16 * i + 16].rstrip(b'\0').decode('latin1').upper() for i in range(n)]
            out.update(m.group(1) for m in map(pat.match, names) if m)
        except Exception as e:
            print('  --avoid %s: could not read (%s)' % (f, e))
    return out


def free_sprite(target, name, avoid=()):
    used = set(avoid)
    vd = os.path.join(target, 'VOXELDEF.txt')
    prev = re.findall(r'^([A-Z0-9]{4})[A-Z]\s*=', wr_common.read_blocks(vd, 'voxels').get(name, ''), re.M)
    if prev: return prev[0]          # a second import of the same set keeps its sprite name
    if os.path.exists(vd):
        used = set(re.findall(r'^([A-Z0-9]{4})[A-Z]\s*=', open(vd).read(), re.M))
    letters = [c for c in name.upper() if c.isalpha()] + list('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    for i in range(len(letters)):
        for j in range(i + 1, len(letters)):
            s = 'WV' + letters[i] + letters[j]
            if s not in used: return s
    return 'WVZZ'


def pack(target, pk3):
    skip_dirs = {'tools', 'import_previews'}
    with zipfile.ZipFile(pk3, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(target):
            rel = os.path.relpath(root, target)
            if rel.split(os.sep)[0] in skip_dirs: continue
            for f in sorted(files):
                if f.lower().endswith(('.md', '.pk3')): continue
                full = os.path.join(root, f)
                z.write(full, os.path.relpath(full, target).replace(os.sep, '/'))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('folder')
    ap.add_argument('--wheel', help='the Wheel folder to copy (default: the one these tools are in)')
    ap.add_argument('--out', help='where the copy goes (default <folder>/../Wheel_imported)')
    ap.add_argument('--into', help='write into this Wheel folder itself instead of a copy')
    ap.add_argument('--pk3', help='also zip the result into this pk3')
    ap.add_argument('--avoid', nargs='*', default=[], help='pk3/wad files to keep clear of: new font prefixes and voxel sprite names will not clash with their lumps')
    a = ap.parse_args()
    folder = os.path.abspath(a.folder)
    out = a.out or os.path.join(os.path.dirname(folder), 'Wheel_imported')
    target = wr_common.prepare_target(a.wheel or wr_common.find_wheel(), out, a.into)
    print('writing into %s%s' % (target, '' if a.into else ' (a copy)'))
    pals, fonts, voxels = classify(folder)
    done, failed = [], []
    for p in pals:
        try:
            done.append(('palette', wr_import_palette.main([p, '--into', target] + sidecar(p))))
        except (ValueError, OSError, SystemExit) as e:
            failed.append((p, e))
    for f in fonts:
        try:
            done.append(('font set', wr_import_font.main([f, '--into', target, '--avoid'] + a.avoid + sidecar(f))))
        except (ValueError, OSError, SystemExit) as e:
            failed.append((f, e))
    avoid_spr = sprite_names(a.avoid) if voxels else set()
    for name, inputs in voxels:
        try:
            extra = sidecar(inputs[0]) if os.path.isdir(inputs[0]) else []
            args = inputs + ['--into', target, '--name', name, '--sprite', free_sprite(target, name, avoid_spr)] + extra
            done.append(('voxels', wr_make_voxels.main(args)))
        except (ValueError, OSError, SystemExit) as e:
            failed.append((name, e))
    print()
    for kind, n in done: print('  %-8s %s' % (kind, n))
    for p, e in failed: print('  FAILED   %s: %s' % (p, e))
    print('previews: %s' % os.path.join(target, 'import_previews'))
    print('pick them in game: Options -> Radiant Silvergun Options -> RSQ Wheel -> Palette / Font,')
    print('or in the console: wr_palette <Name> / wr_fontset <Name>')
    if a.pk3:
        pack(target, a.pk3)
        print('pk3: %s' % a.pk3)
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
