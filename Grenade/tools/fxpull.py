#!/usr/bin/env python3
"""fxpull.py -- pulls the Grenade tree's effects into RSQ Grenade from the owner's two wells (tool only; never ships).

    python Grenade/tools/fxpull.py [RS_CombatFX dir] [RS_Ballistics dir]   (defaults: E:/DOOMWork/RS_CombatFX, RS_Ballistics)

The owner's rule (GBOVR_TREES.md 4; "combatfx and ballistics are your friend", 11-02): art and sounds come from RS
Combat FX and RS Ballistics. RS_CombatFX is a well that is never loaded and asks that every pull be recorded: THIS TABLE
IS THAT RECORD for RSQ Grenade. Sprites are copied frame by frame under this mod's own QG* sprite names (so no other
mod's lumps are replaced); sounds are converted to mono 44.1 kHz Ogg (needs ffmpeg on the PATH) and the SNDINFO lines
are printed."""
import glob, os, shutil, subprocess, sys

FX = sys.argv[1] if len(sys.argv) > 1 else 'E:/DOOMWork/RS_CombatFX'
BA = sys.argv[2] if len(sys.argv) > 2 else 'E:/DOOMWork/RS_Ballistics'
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (our sprite, the well, its folder, its sprite, what for)
SPRITES = [
    ('QGB1', FX, 'explosions', 'RSE1', 'Cluster: each bomblet\'s small blast'),
    ('QGBB', FX, 'fire', 'RSI9', 'Big Bang: the bigger fireball laid over the frag\'s'),
    ('QGIC', FX, 'ice', 'ICEY', 'Freeze: the frost burst'),
    ('QGFI', FX, 'fire', 'RSI3', 'Incendiary: the flames of the burning ground'),
    ('QGCL', FX, 'smoke', 'RSK3', 'Smoke: the cloud\'s puffs; Charm and Infight: their hazes (tinted)'),
    ('QGHF', FX, 'hitflash', 'RSH0', 'Flash: the bloom, drawn white'),
]
# (our lump, the well, its file, the SNDINFO alias, what for)
SOUNDS = [
    ('QGBOMB1', BA, 'sounds/rsb/blast/small1.ogg', 'rsqgn/fx/bomblet1', 'a bomblet goes off'),
    ('QGBOMB2', BA, 'sounds/rsb/blast/small2.ogg', 'rsqgn/fx/bomblet2', 'a bomblet goes off'),
    ('QGBOMB3', BA, 'sounds/rsb/blast/small3.ogg', 'rsqgn/fx/bomblet3', 'a bomblet goes off'),
    ('QGBIGB', BA, 'sounds/rsb/blast/big1.ogg', 'rsqgn/fx/bigbang', 'Big Bang: the blast\'s low end'),
    ('QGFREEZ', BA, 'sounds/rsb/glass/winbrea.ogg', 'rsqgn/fx/freeze', 'Freeze: the ice cracking out'),
    ('QGFIRE', BA, 'sounds/rsb/flame/flamer_blast.ogg', 'rsqgn/fx/fire', 'Incendiary: the ground catching'),
    ('QGSMOKE', BA, 'sounds/rsb/flame/ft_lighthiss.ogg', 'rsqgn/fx/smoke', 'Smoke: the hiss of the cloud'),
    ('QGFLASH', BA, 'sounds/rsb/blast/med1.ogg', 'rsqgn/fx/flash', 'Flash: the bang (played high)'),
    ('QGSTUN', FX, 'sounds/melee/hammer/HAMRWAL.ogg', 'rsqgn/fx/stun', 'Stun: the dull thud'),
    ('QGCHARM', BA, 'sounds/rsb/impact_electric/dsdevzap.ogg', 'rsqgn/fx/turn', 'Charm and Infight: the zap that turns them'),
]

for ours, well, folder, theirs, why in SPRITES:
    n = 0
    for f in sorted(glob.glob(os.path.join(well, folder, theirs + '*'))):
        name = os.path.basename(f)
        dst = os.path.join(ROOT, 'sprites', 'rsqgn', ours + name[4:6].upper() + name[6:])
        shutil.copyfile(f, dst)
        n += 1
    print('sprite %s <- %s/%s (%d frames): %s' % (ours, folder, theirs, n, why))
for ours, well, src, alias, why in SOUNDS:
    dst = os.path.join(ROOT, 'sounds', 'rsqgn', ours + '.ogg')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', os.path.join(well, src), '-ac', '1', '-ar', '44100', dst], check=True)
    print('%-20s %-8s  // %s: %s' % (alias, ours, src, why))
