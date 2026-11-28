"""TEST ONLY: the Rifle's M203 in the rig -- steady, latch, slide the tube open, load a 40 mm round, slide shut, fire."""
import re, sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import rig, handrot as h
import os
MG = os.environ.get('GUN') == 'mg'
L, U = (-0.068, -1.517) if MG else (0.520, -5.000)
TR = 9.694 if MG else 11.0
REAR = 29.272 if MG else 28.44
PALM = (-1.5, 2.0, -4.5)
RND, RAX = (-1.930, 4.560, -4.500), (0, 0, 1)
def palm_at(x):          # mirrored palm on the tube's line at F = x
    return h.place(PALM, (1, 0, 0), (x, L, U - 2.0), (1, 0, 0))[0]
def round_at(x):         # the round's middle on the bore line at F = x, nose forward
    return h.place(RND, RAX, (x, L, U), (1, 0, 0))[0]
FAR = '-0.25 1.3 -0.3 30 0 0'
s = ('wait 120; god; rsr_reload 1; rsr_grab_with 0; rsr_debug 1; give %s; give Clip2 100; give AmmoRocket 10; use %s; wait 80; '
     '+altattack; wait 3; -altattack; wait 60; '
     'qz_lhand "%s"; wait 10; qz_lgrip 1; wait 10; qz_ltrigger 1; wait 6; '        # steady on the tube, latch (held while it slides)
     'qz_lhand "%s"; wait 8; qz_lhand "%s"; wait 8; qz_lhand "%s"; wait 10; qz_ltrigger 0; qz_lgrip 0; wait 6; '          # slide it forward 11 cm
     'qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 10; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 8; '   # a round in
     'qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 8; qz_lhand "%s"; wait 8; qz_lhand "%s"; wait 10; qz_ltrigger 0; wait 8; '           # slide shut
     'qz_lhand "%s"; wait 10; +altattack; wait 3; -altattack; wait 40; quit'
     % ((('Machinegun',)*2 if MG else ('Rifle',)*2) + (palm_at(40), palm_at(40+TR*0.4), palm_at(40+TR*0.75), palm_at(40+TR+0.5), FAR, round_at(REAR+3.5), round_at(REAR+TR+0.4+4.3),
        palm_at(40+TR), palm_at(40+TR/2), palm_at(39.5), FAR)))
rig.run('m203' + ('mg' if MG else ''), s, 260)
t = open(rig.OUT + '/m203' + ('mg' if MG else '') + '.log', errors='replace').read()
for l in t.splitlines():
    if re.match(r'rsm|rs[mk]', l) or 'm203' in l.lower(): print(l[:160])
