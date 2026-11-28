"""TEST ONLY: R1 -- empty Rifle reload with Grab ammo with = Grip (rsr_grab_with 1), rack by a steadied grip."""
import re, sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import rig, mags
g = mags.tables()[1]
FAR = '-0.40 1.3 -0.3 30 0 0'     # 65 cm from the gun hand: a grip press here is a grab, not steadying
tr = g['travel']
s = ('wait 120; god; rsr_reload 1; rsr_grab_with 1; rsr_debug 1; give Rifle; give Clip2 200; use Rifle; wait 80; '
     'take RifleAmmo 999; wait 10; +reload; wait 4; -reload; wait 30; qz_lhand "%s"; wait 10; qz_lgrip 1; wait 12; '
     'qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 20; qz_lgrip 0; wait 15; '
     'qz_lhand "%s"; wait 15; qz_ltrigger 1; wait 12; qz_lhand "%s"; wait 10; qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 40; quit'
     % (FAR, mags.at(g, g['M'] + 3), mags.at(g, g['M'] * 0.5), mags.at(g, 0),
        mags.handle_at(g, 0), mags.handle_at(g, tr * 0.5), mags.handle_at(g, tr * 1.05)))
rig.run('grip', s, 240)
t = open(rig.OUT + '/grip.log', errors='replace').read()
for l in t.splitlines():
    if re.match(r'rsr t\d+ (gun|grip)', l): print(l[:150])
