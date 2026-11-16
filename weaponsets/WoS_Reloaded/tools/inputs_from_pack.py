"""Rebuild the build's third-party inputs from the set's own committed pack files, for a machine without them
(GNRC_Reloaded/tools/inputs_from_pack.py's way).

tools/build.py reads Weapons of Saturn's assets (WOS), Voxels of Saturn (VOX), RS Combat FX's and RS Ballistics' sounds
(CFX, RSBS) and RS Ballistics' .45 casing from fixed paths. A machine that does not have those folders can take them back
out of the pack files the set folder already holds (PACK_FILES.txt: the last built tree). Only files that came from those
inputs are taken, back to the names the build reads them by, and the build's own edits to them are undone:

    SOUNDS/**, SPRITES/**                          -> <out>/saturn/...   (SPRITES/BERETTA/RQWPA0.png back to PISTA0.png)
    SNDINFO.wos DECALDEFS.wos LANGUAGE.wos CREDITS.txt -> <out>/saturn/SNDINFO, DECALDEFS, LANGUAGE, CREDITS.txt
    GLDEFS.wos                                     -> <out>/saturn/GLDEFS (object names without RSQWS_, the Titan's three
                                                      objects back on BFGBALL lights, the build's orange lights cut off;
                                                      WoS's SaturnG object, which the build drops, is not restored)
    voxels/* (not the three BD22 voxel-pack ones), voxeldef.txt (the build's additions cut off) -> <out>/vox/...
    rsfx/cfx/*, rsfx/rsb/*                         -> <out>/cfx/..., <out>/rsbs/...
    models/rsq/casings/casing_45.md3               -> <out>/rsb_models/casings/casing_45.md3

    python3 tools/inputs_from_pack.py <out dir> [git revision, default HEAD]
then  RSQWS_INPUTS=<out dir> python3 tools/build.py [--pk3]

The files are read from git at the given revision (never from the working tree), so a build cannot feed itself."""
import os, re, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
LUMPS = {'SNDINFO.wos': 'SNDINFO', 'DECALDEFS.wos': 'DECALDEFS', 'LANGUAGE.wos': 'LANGUAGE', 'CREDITS.txt': 'CREDITS.txt'}
BDVOX = ('voxels/MP40I0.kvx', 'voxels/SRCGA.kvx', 'voxels/CSAWA.kvx')	# taken from the BD22 voxel pack by the build itself

def main(out, rev='HEAD'):
    pre = subprocess.check_output(['git', 'rev-parse', '--show-prefix'], cwd=ROOT, text=True).strip()
    def blob(rel): return subprocess.check_output(['git', 'show', '%s:%s%s' % (rev, pre, rel)], cwd=ROOT)
    files = blob('PACK_FILES.txt').decode().split('\n')
    n = 0
    def put(dst, data):
        nonlocal n
        p = os.path.join(out, dst); os.makedirs(os.path.dirname(p), exist_ok=True); open(p, 'wb').write(data); n += 1
    for rel in files:
        if not rel:
            continue
        if rel == 'SPRITES/BERETTA/RQWPA0.png': put('saturn/SPRITES/BERETTA/PISTA0.png', blob(rel))
        elif rel.startswith(('SOUNDS/', 'SPRITES/')): put('saturn/' + rel, blob(rel))
        elif rel in LUMPS: put('saturn/' + LUMPS[rel], blob(rel))
        elif rel.startswith('voxels/') and rel not in BDVOX: put('vox/' + rel, blob(rel))
        elif rel.startswith('rsfx/cfx/'): put('cfx/' + rel[9:], blob(rel))
        elif rel.startswith('rsfx/rsb/'): put('rsbs/' + rel[9:], blob(rel))
        elif rel == 'models/rsq/casings/casing_45.md3': put('rsb_models/casings/casing_45.md3', blob(rel))
    # GLDEFS: the build's edits undone (tools/build.py step 2)
    gl = blob('GLDEFS.wos').decode('latin-1')
    cut = gl.find("\n// tools/build.py: the Titan's rounds in the Nuker's orange")
    if cut >= 0:
        gl = gl[:cut]
    def white(m):
        return m.group(1) + re.sub(r'\blight RSQWS_NOVA(_X\d)?\b', lambda k: 'light BFGBALL' + (k.group(1) or ''), m.group(2))
    gl = re.sub(r'(?s)(object\s+RSQWS_(?:Nova|HyperNova|Residue)\s*\{)(.*?\n\})', white, gl)
    gl = re.sub(r'(?im)^(\s*object\s+)RSQWS_(\w+)', r'\1\2', gl)
    put('saturn/GLDEFS', gl.encode('latin-1'))
    vd = blob('voxeldef.txt').decode('latin-1')
    cut = vd.find("\n// tools/build.py: the Beretta's pickup sprite")
    put('vox/voxeldef.txt', (vd[:cut] if cut >= 0 else vd).encode('latin-1'))
    print('%d input files under %s (from %s)' % (n, out, rev))

if __name__ == '__main__':
    if len(sys.argv) < 2: raise SystemExit(__doc__)
    main(os.path.abspath(sys.argv[1]), sys.argv[2] if len(sys.argv) > 2 else 'HEAD')
