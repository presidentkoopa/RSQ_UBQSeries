"""row_1911.py -> tools/row_1911.json: the 1911's real-VR-reload row (RSR_Guns row 19) in the seated placement.

BD22 VR's one method (tools/handfit/port/reseat_gun.py): the wrist stays pinned, the GUN moves to the hand, and every reload
point moves with it by x -> R x + t, R, t from the MODELDEF chain at the old placement (RS ModelSwapper row 94: Scale -1 1 1,
Offset 0 0 -5) to the seat (seat_1911.json). Checked on BD22 VR's own pistol row 2 before it is used (asserted below).
TopInHand / HandHook are hand-relative and are BD22 VR row 2's (the card's put the magazine 12 cm above the hand, the fault BD22 VR
fixed on row 2 on 2026-10-16); the reload sounds are the card's, which are aliases of BD22's pistol sounds = row 2's names."""
import os, sys, json, numpy as np
sys.argv = sys.argv[:1]
sys.path.insert(0, '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/tools/handfit/port')
import port_gun as pg
HERE = os.path.dirname(os.path.abspath(__file__))
G = dict(scale=(-1, 1, 1), off=(0, 0, -5))
def move(p):
    return pg.rigid_move(G, np.array(p, float))
# the method, on BD22 VR's pistol (row 2: old Well (-3, 0, -2.2) -> shipped (5.324, 1.418, 3.020))
R, t = move([0.820, -8.333, -1.408, 3.854, 3.363, 10.974])
assert np.abs(R @ np.array([-3, 0, -2.2]) + t - [5.324, 1.418, 3.020]).max() < 2e-3
S = json.load(open(os.path.join(HERE, 'seat_1911.json')))['modeldef']
p = [S['Offset'][0], S['Offset'][1], S['ZOffset'], S['AngleOffset'], S['PitchOffset'], S['RollOffset']]
R, t = move(p)
# The card's Axis (0.243, 0.192, 0.951) leans 11 degrees sideways. Re-measured (owner 2026-11-12: "remeasure it to get it to
# standards"): the magazine's own travel in the mesh's authored reload frames 7-9 (body put back on frame 0), straight down the
# grip at 18.7 degrees, no side lean -- the real 1911's grip angle.
C = pg.chain((-1, 1, 1), (0, 0, -5), (0, 0, 0)); MD = '/home/claude/presidentkoopa/rs_modelswapper/cards/brutalwolf/1911/bw_1911.md3'
b0 = C(pg.raw(MD, 0, [0])); m0 = C(pg.raw(MD, 0, [4])); Rb, tb = pg.kabsch(C(pg.raw(MD, 9, [0])), b0)
travel = -(C(pg.raw(MD, 9, [4])) @ Rb.T + tb - m0).mean(0); travel /= np.linalg.norm(travel)
assert abs(travel[1]) < 0.01 and 0.30 < travel[0] < 0.34, travel
card = dict(Well=(-2.664, 0.051, -1.714), Axis=tuple(travel), MagCentre=(-3.182, 0.043, -4.754), Grab=(3.374, 0.010, -0.163),
            Pull=(-1.0, 0.0, 0.0), WellHook=(-0.192, -0.951, 0.243), HandleHook=(0.0, 0.0, 1.0))
v = lambda a: [round(float(x), 3) for x in a]
ax = R @ np.array(card['Axis']); pu = R @ np.array(card['Pull'])
row = dict(
    Well=v(R @ np.array(card['Well']) + t), MagCentre=v(R @ np.array(card['MagCentre']) + t), Grab=v(R @ np.array(card['Grab']) + t),
    Axis=v(ax), Pull=v(pu),
    WellHook=v(np.linalg.norm(card['WellHook']) * np.array([-ax[1], -ax[2], ax[0]])),
    HandleHook=v(np.linalg.norm(card['HandleHook']) * np.array([pu[1], pu[2], -pu[0]])),
    Offset=v(p[:3]), Scale=[-1.0, 1.0, 1.0],
    Mouth=12.49, MagLen=11.88, Travel=4.08, BackAt=0.85, Channel=5, ChargeRule=1, BoltRatio=0.0, HasHandle=True, HandleLayers=True,
    TopInHand=[0.690, 3.937, 2.560], HandHook=[3.937, 4.760, -3.690],
    SprGun='RQ1M', SprPart='RQ1P', SprWorld='RQ1W', ReadySprites='PIST E',
    SndOut='Pistol/Reload1', SndIn='Pistol/Reload2', SndBack='rsr/slideback', SndFwd='pistol/slide2', SndLand='weapons/smallmagdrop',
    place=v(p), axis_old_frame=v(travel), card_axis_old_frame=[0.243, 0.192, 0.951])
json.dump(row, open(os.path.join(HERE, 'row_1911.json'), 'w'), indent=1)
print(json.dumps(row))
