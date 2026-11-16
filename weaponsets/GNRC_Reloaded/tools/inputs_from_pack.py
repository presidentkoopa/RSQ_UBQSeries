"""Rebuild the build's third-party inputs from the set's own committed pack files, for a machine without them.

tools/build.py reads GNRC's assets (GNRC_SRC), the GNRC voxel pack (VOX), RS Combat FX's and RS Ballistics' sounds
(CFX, RSBS) from fixed paths. A machine that does not have those folders can take them back out of the pack files the
set folder already holds (PACK_FILES.txt: the last suite-passed tree). Only files that came from those inputs are
taken, back to the names the build reads them by:

    sounds/{weapons,items,player}, sprites/{weapons,items}, brightmaps/, graphics/  -> <out>/gnrc/...
    SNDINFO.gnrc DECALDEF.gnrc LANGUAGE.gnrc TEXTURES.gnrc CREDITS_GNRC.txt        -> <out>/gnrc/sndinfo.txt ...
    voxels/*, voxeldef.txt (the build's own additions taken back out)               -> <out>/vox/...
    rsfx/cfx/*, rsfx/rsb/*                                                          -> <out>/cfx/..., <out>/rsbs/...

    python3 tools/inputs_from_pack.py <out dir> [git revision, default HEAD]
then  RSQGW_INPUTS=<out dir> python3 tools/build.py

The files are read from git at the given revision (never from the working tree), so a build cannot feed itself."""
import os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
GNRC_DIRS = ('sounds/weapons/', 'sounds/items/', 'sounds/player/', 'sprites/weapons/', 'sprites/items/', 'brightmaps/', 'graphics/')
LUMPS = {'SNDINFO.gnrc': 'sndinfo.txt', 'DECALDEF.gnrc': 'decaldef.txt', 'LANGUAGE.gnrc': 'language.txt', 'TEXTURES.gnrc': 'TEXTURES.txt',
         'CREDITS_GNRC.txt': 'credits.txt'}

def main(out, rev='HEAD'):
    pre = subprocess.check_output(['git', 'rev-parse', '--show-prefix'], cwd=ROOT, text=True).strip()
    def blob(rel): return subprocess.check_output(['git', 'show', '%s:%s%s' % (rev, pre, rel)], cwd=ROOT)
    files = blob('PACK_FILES.txt').decode().split()
    n = 0
    def put(dst, data):
        nonlocal n
        p = os.path.join(out, dst); os.makedirs(os.path.dirname(p), exist_ok=True); open(p, 'wb').write(data); n += 1
    for rel in files:
        if rel.startswith(GNRC_DIRS): put('gnrc/' + rel, blob(rel))
        elif rel in LUMPS: put('gnrc/' + LUMPS[rel], blob(rel))
        elif rel.startswith('voxels/'): put('vox/' + rel, blob(rel))
        elif rel.startswith('rsfx/cfx/'): put('cfx/' + rel[9:], blob(rel))
        elif rel.startswith('rsfx/rsb/'): put('rsbs/' + rel[9:], blob(rel))
    vd = blob('voxeldef.txt').decode('latin-1')
    cut = vd.find("\n// tools/build.py: the Beretta's pickup sprite")
    put('vox/voxeldef.txt', (vd[:cut] if cut >= 0 else vd).encode('latin-1'))
    print('%d input files under %s (from %s)' % (n, out, rev))

if __name__ == '__main__':
    if len(sys.argv) < 2: raise SystemExit(__doc__)
    main(os.path.abspath(sys.argv[1]), sys.argv[2] if len(sys.argv) > 2 else 'HEAD')
