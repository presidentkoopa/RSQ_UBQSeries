#!/usr/bin/env python3
"""build_all.py -- build_all.sh for any machine with Python 3 (Windows included; no zip tool needed).

    python tools/build_all.py              every mod
    python tools/build_all.py Whip Wheel   just those folders

Packs each mod folder into pk3/ with EXACTLY the include lists build_all.sh uses (keep the two in step).
Paths inside the pk3 always use forward slashes (PowerShell's Compress-Archive writes backslashes on older
versions, which the engine does not read)."""
import os, sys, zipfile, fnmatch

HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HUB, 'pk3')

PACK_LIST_FILES = ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'TRNSLATE.txt', 'KEYCONF.txt', 'MENUDEF.txt',
                   'MODELDEF.txt', 'SNDINFO.txt', 'MASSDEF.txt', 'ANIMDEFS.txt', 'TEXTURES.txt', 'GLDEFS.txt',
                   'RSQTRFIT.txt', 'RSQTRLAY.txt', 'CREDITS.txt']

# folder -> (pk3 name, mode, spec)
#   'list': the named files and folders (missing ones skipped)
#   'all' : everything in the folder except the exclude patterns
#   'sub' : everything inside a subfolder; spec (subfolder, [files from the mod folder's root, e.g. README.md])
MODS = {
    'DistanceGrab': ('RSQ_DistanceGrab.pk3', 'list', PACK_LIST_FILES + ['README.md', 'zscript', 'graphics', 'sprites', 'sounds', 'models/rsqdg']),
    'TacticalRig':  ('RSQ_TacticalRig.pk3', 'list', PACK_LIST_FILES + ['README.md', 'zscript', 'graphics', 'sprites', 'sounds', 'models/rsqtr']),
    'SlowMo':       ('RSQ_SlowMo.pk3', 'list', PACK_LIST_FILES + ['README.md', 'zscript', 'graphics', 'sprites', 'sounds', 'models/rsqsm']),
    'ShieldSaw':    ('RSQ_ShieldSaw.pk3', 'all', ['docs/*', 'tools/*', '*.sh', '.gitignore', 'HANDOFF.md', 'README_draft.md']),
    'QuestSaber':   ('RSQ_Saber.pk3', 'all', ['docs/*', '.gitignore', 'README_draft.md']),
    'LaserSight':   ('RSQ_LaserSight.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'KEYCONF.txt', 'MENUDEF.txt',
                     'MODELDEF.txt', 'CREDITS.txt', 'README.md', 'VOXELDEF.txt', 'VOXELDEF.halo', 'ANIMDEFS.txt', 'zscript', 'sprites', 'models/rsqls']),
    'Grapple':      ('RSQ_Grapple.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'KEYCONF.txt', 'MENUDEF.txt',
                     'SNDINFO.txt', 'CREDITS.txt', 'README.md', 'MODELDEF.txt', 'zscript', 'sprites', 'sounds', 'models']),
    'VisualRewards': ('RSQ_VisualRewards.pk3', 'sub', ('pk3', ['README.md'])),   # HP bars + damage numbers + Kill Rewards (was TopHPBars / RSQ_HPBars.pk3)
    'Accessibility': ('RSQ_Accessibility.pk3', 'list', ['zscript.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'KEYCONF.txt',
                     'MAPINFO.txt', 'GLDEFS.txt', 'CREDITS.txt', 'README.md', 'zscript', 'shaders']),
    'Score':        ('RSQ_Score.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'SNDINFO.txt', 'TEXTCOLO.txt', 'TRNSLATE.txt',
                     'MENUDEF.txt', 'RSSCFON.fon2', 'RSSCFN2.fon2', 'CREDITS.md', 'README.md', 'zscript', 'sounds', 'graphics']),
    'Miniboss':     ('RSQ_Miniboss.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'CREDITS.txt', 'README.md', 'zscript', 'graphics']),
    'Whip':         ('RSQ_Whip.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'KEYCONF.txt', 'MENUDEF.txt',
                     'SNDINFO.txt', 'MODELDEF.txt', 'CREDITS.txt', 'README.md', 'zscript', 'sounds', 'models', 'sprites']),
    'Wheel':        ('RSQ_Wheel.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'KEYCONF', 'MENUDEF.txt',
                     'SNDINFO.txt', 'MODELDEF.txt', 'TEXTURES.txt', 'WRPALS.txt', 'WRFONTS.txt', 'CREDITS.txt', 'README.md',
                     'zscript', 'sounds', 'models', 'sprites', 'graphics']),
    'GunCards':     ('RSQ_GunCards.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'KEYCONF.txt', 'MENUDEF.txt',
                     'MODELDEF.txt', 'TEXTURES.txt', 'VOXELDEF.txt', 'CREDITS.txt', 'README.md', 'zscript', 'models',
                     'sprites', 'graphics', 'voxels']),
    'Grenade':      ('RSQ_Grenade.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'KEYCONF.txt', 'MODELDEF.txt', 'MODELDEF.kinds.txt',
                     'SNDINFO.txt', 'TRNSLATE.txt', 'DECALDEF.txt', 'CREDITS.txt', 'README.md', 'zscript', 'models', 'sounds',
                     'sprites', 'graphics']),   # DECALDEF + graphics/: the explosions' wall scorch (11-09)
    'Melee':        ('RSQ_Melee.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'MODELDEF.txt',
                     'SNDINFO.txt', 'LANGUAGE.txt', 'CREDITS.txt', 'README.md', 'zscript', 'models', 'sounds', 'sprites', 'credits']),
    'GlowInTheDark': ('RSQ_GlowInTheDark.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'KEYCONF.txt', 'GLDEFS.txt',
                     'CREDITS.txt', 'README.md', 'zscript',
                     'CVARINFO.ddz', 'MENUDEF.ddz', 'DarkDoomZ']),   # DarkDoomZ (Caligari87, zlib) built in
    'FlashFlare':   ('RSQ_FnF.pk3', 'list', ['zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'MODELDEF.txt',
                     'SNDINFO.txt', 'CREDITS.txt', 'README.md', 'zscript', 'models', 'sprites', 'graphics',
                     'VOXELDEF.txt', 'voxels', 'sounds', 'MODELDEF.torch']),
    'Graveyard':    ('RSQ_Graveyard.pk3', 'all', ['.gitignore', 'tools/*']),   # m8f's Graveyard (GPLv3), RSQ Edition: the whole folder ships (copying.txt, credits.txt, Readme.md included)
    'Monsters':     ('RSQ_Monsters.pk3', 'all', ['*.md', '.gitignore', 'EXCLUDED.txt', 'ELITE_SYSTEMS.txt']),   # RS Monsters (owner's), Quest edition
    'GunBonsaiOffhandVR': ('RSQ_GunBonsaiVR.pk3', 'all', ['.git*', 'build.ps1', 'NOTES.md', 'readme.txt', 'tools/*', 'docs/*', '*.pk3']),  # readme.txt: the old pre-README notes (0.99a item 30), not shipped
}


def walk(root):
    for d, _, files in os.walk(root):
        for f in files:
            full = os.path.join(d, f)
            yield full, os.path.relpath(full, root).replace(os.sep, '/')


def excluded(rel, pats):
    return any(fnmatch.fnmatch(rel, p) or fnmatch.fnmatch(rel.split('/')[0], p) for p in pats)


def build(folder):
    name, mode, spec = MODS[folder]
    src = os.path.join(HUB, folder)
    out = os.path.join(OUT, name)
    entries = []
    if mode == 'list':
        for item in spec:
            p = os.path.join(src, item)
            if os.path.isfile(p):
                entries.append((p, item))
            elif os.path.isdir(p):
                entries += [(f, item + '/' + r) for f, r in walk(p)]
    elif mode == 'all':
        entries = [(f, r) for f, r in walk(src) if not excluded(r, spec)]
    else:
        sub, extra = spec if isinstance(spec, tuple) else (spec, [])
        entries = list(walk(os.path.join(src, sub)))
        entries += [(os.path.join(src, f), f) for f in extra if os.path.isfile(os.path.join(src, f))]
    entries.sort(key=lambda e: e[1])
    if os.path.exists(out):
        os.remove(out)
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for f, r in entries:
            z.write(f, r)
    print('built pk3/%s (%d files)' % (name, len(entries)))


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    want = sys.argv[1:] or list(MODS)
    for m in want:
        if m not in MODS:
            sys.exit('unknown mod folder: %s (one of: %s)' % (m, ', '.join(MODS)))
        build(m)
