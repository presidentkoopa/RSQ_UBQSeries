#!/usr/bin/env python3
"""fxsounds.py -- pulls the Fists tree's sounds into RSQ Melee from the owner's two sound wells (tool only; never ships).

    python Melee/tools/fxsounds.py [RS_CombatFX dir] [RS_Ballistics dir]     (defaults: E:/DOOMWork/RS_CombatFX, RS_Ballistics)

The owner's rule (GBOVR_TREES.md 4): art and sounds come from RS Combat FX and RS Ballistics. RS_CombatFX is a well that
is never loaded; a package copies single assets out of it, and its README asks that every pull be recorded (it has no
pull tool yet). THIS TABLE IS THAT RECORD for RSQ Melee. Each file is converted to mono 44.1 kHz Ogg (the engine places
only mono sounds in the world, and the wells run 11 to 48 kHz) into Melee/sounds/rsqml/fx/, and the SNDINFO lines are
printed. Needs ffmpeg on the PATH."""
import os, subprocess, sys

FX = sys.argv[1] if len(sys.argv) > 1 else 'E:/DOOMWork/RS_CombatFX'
BA = sys.argv[2] if len(sys.argv) > 2 else 'E:/DOOMWork/RS_Ballistics'
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'sounds', 'rsqml', 'fx')

# (output name, source, where it came from in the well)
PULLS = [
    ('blast1', FX, 'sounds/launcher/explode/RKTEXP1.ogg'),
    ('blast2', FX, 'sounds/launcher/explode/RKTEXP2.ogg'),
    ('blast3', FX, 'sounds/launcher/explode/RKTEXP3.ogg'),
    ('thud1', FX, 'sounds/melee/hammer/HAMRWAL.ogg'),
    ('thud2', FX, 'sounds/melee/wallhit/FISTWAL.ogg'),
    ('heavy1', FX, 'sounds/melee/unsorted/FISTSTR1.ogg'),
    ('heavy2', FX, 'sounds/melee/unsorted/FISTSTR2.ogg'),
    ('heavy3', FX, 'sounds/melee/unsorted/FISTSTR3.ogg'),
    ('whoosh1', FX, 'sounds/melee/unsorted/SWING1.ogg'),
    ('whoosh2', FX, 'sounds/melee/unsorted/SWING3.ogg'),
    ('whoosh3', FX, 'sounds/melee/unsorted/SWING5.ogg'),
    ('release1', FX, 'sounds/bfg/explode/bfg_ballexplode1.ogg'),
    ('release2', FX, 'sounds/bfg/explode/bfg_ballexplode2.ogg'),
    ('clang1', BA, 'sounds/rsb/impact_metal/blt_imp_metal_thick_near_01.ogg'),
    ('clang2', BA, 'sounds/rsb/impact_metal/blt_imp_metal_thick_near_02.ogg'),
    ('clang3', BA, 'sounds/rsb/impact_metal/blt_imp_metal_thick_near_03.ogg'),
    ('zap1', BA, 'sounds/rsb/impact_electric/electro8.wav'),
    ('zap2', BA, 'sounds/rsb/impact_electric/pzaphit.ogg'),
    ('zap3', BA, 'sounds/rsb/impact_electric/electro7.ogg'),
    ('ignite', BA, 'sounds/rsb/flame/flamer_start.ogg'),
    ('flare', BA, 'sounds/rsb/flame/flamerhiss1.ogg'),
]


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, root, rel in PULLS:
        src = os.path.join(root, rel)
        dst = os.path.join(OUT, name + '.ogg')
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', src, '-ac', '1', '-ar', '44100', '-c:a', 'libvorbis', '-q:a', '5', dst], check=True)
        print(f'rsqml/fx/{name:<10} "sounds/rsqml/fx/{name}.ogg"   // {os.path.basename(root)}/{rel}')


if __name__ == '__main__':
    main()
