#!/usr/bin/env python3
"""check_fit.py -- tool only: draws the baked hand (models/ubqs/ubqs_hilthand.md3) and the hilt in the card frame, three
views per blade size, to docs/hilthand/fit.png (the hilt grey, the hand coloured by distance to the hilt's axis)."""
import os, sys, numpy as np, matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
from gen_hilthand import read_md3, surface_samples, to_card, HAND_S, HAND_O, SABER_O, SIZES
hand, _ = read_md3(open(os.path.join(ROOT, 'models/ubqs/ubqs_hilthand.md3'), 'rb').read())
sab, _ = read_md3(open(os.path.join(ROOT, 'models/ubqs/ubqs_saber.md3'), 'rb').read())
sizes = [0, 2, 4]
fig, ax = plt.subplots(len(sizes), 3, figsize=(15, 5 * len(sizes)))
for row, si in enumerate(sizes):
    sc = SIZES[si]; S = (-sc, sc, sc)
    Hc = np.array([to_card(p, S, SABER_O) for s in sab[:5] for p, _ in s['frames'][0]])
    Pc = np.array([to_card(p, HAND_S, HAND_O) for p in surface_samples(hand, si)[::3]])
    for k, (i, j, nm) in enumerate([(1, 2, 'side (Y fwd-, Z up)'), (0, 2, 'from behind (X, Z)'), (0, 1, 'top (X, Y)')]):
        a = ax[row, k]
        a.scatter(Pc[:, i], Pc[:, j], s=0.4, c='tan')
        a.scatter(Hc[:, i], Hc[:, j], s=0.4, c='k')
        a.plot([0], [0], alpha=0)
        a.scatter([[0, -30, -5][i]], [[0, -30, -5][j]], marker='x', c='r', s=60)
        a.set_aspect('equal'); a.set_title('size %d: %s  (x = controller)' % (si + 1, nm)); a.grid(alpha=.3)
plt.tight_layout(); plt.savefig(os.path.join(HERE, 'fit.png'), dpi=60)
print('wrote docs/hilthand/fit.png')
