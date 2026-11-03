#!/usr/bin/env python3
"""fxpull.py -- pulls the ShieldSaw tree's effects into RSQ ShieldSaw from the owner's two wells (tool only; never ships).

    python ShieldSaw/tools/fxpull.py [RS_CombatFX dir] [RS_Ballistics dir]   (defaults: E:/DOOMWork/RS_CombatFX, RS_Ballistics)

The owner's rule (GBOVR_TREES.md 4; "combatfx and ballistics are your friend", 11-02): art and sounds come from RS
Combat FX and RS Ballistics. RS_CombatFX is a well that is never loaded and asks that every pull be recorded: THIS TABLE
IS THAT RECORD for RSQ ShieldSaw. Sprites are copied frame by frame under this mod's own sprite name (so no other mod's
lumps are replaced); sounds are converted to mono 44.1 kHz Ogg (needs ffmpeg on the PATH) and the SNDINFO lines are
printed."""
import glob, os, shutil, subprocess, sys

FX = sys.argv[1] if len(sys.argv) > 1 else 'E:/DOOMWork/RS_CombatFX'
BA = sys.argv[2] if len(sys.argv) > 2 else 'E:/DOOMWork/RS_Ballistics'
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (our sprite, the well, its folder, its sprite, what for)
SPRITES = [
    ('SSQV', FX, 'explosions', 'RSEC', 'Charge: the burst that opens into a ring, at the wedge'),
    ('SSQK', FX, 'sparks', 'RSS4', 'Shield Dash: the speed streak (frame A) along the dash'),
]
# (our lump, the well, its file, the SNDINFO alias, what for)
SOUNDS = [
    ('SSQDASH', FX, 'sounds/melee/unsorted/SWING3.ogg', 'ssq/dash', 'Shield Dash: the whoosh as it starts'),
    ('SSQCHRG', BA, 'sounds/rsb/blast/roll1.ogg', 'ssq/charge', 'Charge: the rolling blast'),
]

for ours, well, folder, theirs, why in SPRITES:
    n = 0
    for f in sorted(glob.glob(os.path.join(well, folder, theirs + '*'))):
        name = os.path.basename(f)
        dst = os.path.join(ROOT, 'sprites', ours + name[4:])
        shutil.copyfile(f, dst)
        n += 1
    print('sprite %s <- %s/%s (%d frames): %s' % (ours, folder, theirs, n, why))
for ours, well, src, alias, why in SOUNDS:
    dst = os.path.join(ROOT, 'sounds', 'shieldsaw', ours + '.ogg')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', os.path.join(well, src), '-ac', '1', '-ar', '44100', dst], check=True)
    print('%-16s %-8s  // %s: %s' % (alias, ours, src, why))
