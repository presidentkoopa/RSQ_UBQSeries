"""Seat the BrutalWolf 1911 in BD22 VR's FBX pistol hand (owner 2026-11-12: re-measure it where it sits, put the FBX
hand on it). BD22 VR's method: the hand is pinned to the controller and the GUN moves to the hand. The FBX pistol hand
was solved on BrutalPistol; the 1911 is moved rigidly so its grip, backstrap notch (the web's seat) and trigger face land
where BrutalPistol's are, then its MODELDEF numbers are solved (ModelSwapper gunplace.fit). Writes seat_1911.json.
Landmarks are measured here, on both meshes, by the same rules (gunlm.pistol's, in md3 file units).
That landmark seat is the START. Then ONE direct solve on the FBX hand mesh itself (owner: magwell in hand, finger on trigger;
no rounds, no re-bake, no new pose): see the hand section below. "modeldef" = the solved seat (row_1911.py reads it)."""
import sys, json, os
import numpy as np
HT = '/home/claude/presidentkoopa/rs_modelswapper/tools/handfit/core/hands_tool'
sys.path.insert(0, HT)
import scene, gunplace, gunview, gunfield
BW = '/home/claude/presidentkoopa/rs_modelswapper/cards/brutalwolf/1911/bw_1911.md3'
BP = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src/models/bd/BrutalPistol/BrutalPistol.md3'
# BD22 VR's BrutalPistol placement (MODELDEF.bd.txt, BD 2.0 b1: gun to the FBX hand)
BP_IT = dict(path=BP, frame=3, scale=[-1.0, 1.0, 1.0], off=[0.820, -8.333, -1.408], ao=(3.854, 3.363, 10.974))
BW_IT = dict(path=BW, frame=0, scale=[-1.0, 1.0, 1.0], off=[0.0, 0.0, -5.0])
# which surfaces are what (md3 surface index): grip = body + mag, trigger, slide
SURF = {'BW': dict(grip=(0, 4), trigger=1, slide=3), 'BP': dict(grip=(3, 4), trigger=5, slide=1)}

def pca(Q):
    c = Q.mean(0); _, S, Vt = np.linalg.svd(Q - c, full_matrices=False); return c, Vt[0]

def landmarks(path, frame, sf):
    S = scene.md3_full(path)
    # the surfaces as dense samples (0.1 md3 units), not the low-poly vertices: the grip's edges lie between vertices
    V = [gunfield.sample_surface(s['xyz'][frame], s['tris'], 0.1)[0] for s in S]
    allv = np.concatenate(V)
    G = np.concatenate([V[i] for i in sf['grip']])
    T = V[sf['trigger']]
    tmin = T[:, 0].min()
    # side-view silhouettes of the grip behind the trigger guard, |L| < 1
    def sil(lo, hi, fn):
        out = []
        for u in np.arange(lo, hi, 0.25):
            q = G[(np.abs(G[:, 2] - u) < 0.13) & (np.abs(G[:, 1]) < 1.0) & (G[:, 0] < tmin - 0.3)]
            if len(q): out.append(q[fn(q[:, 0])])
        return np.array(out)
    zlo = G[:, 2].min()
    rear = sil(zlo + 0.4, -2.6, np.argmin); front = sil(zlo + 0.4, -6.6, np.argmax)
    def line(P):
        m = (P[:, 2] > zlo + 1.0) & (P[:, 2] < zlo + 8.0); c, a = pca(P[m]); return c, (a if a[2] > 0 else -a)
    cr, ar = line(rear); cf, af = line(front)
    a = ar + af; a /= np.linalg.norm(a); c = 0.5 * (cr + cf)
    # the spur / beavertail: the rearmost point of the TOP of the grip (above its middle); the bottom of a 1911's
    # grip is further back than its beavertail, so the whole silhouette cannot be used
    top = rear[rear[:, 2] > c[2] + 2.0]
    spur_u = top[np.argmin(top[:, 0]), 2]
    band = rear[(rear[:, 2] < spur_u - 0.2) & (rear[:, 2] > spur_u - 2.5)]
    web = band[np.argmax(band[:, 0])]
    u0, u1 = T[:, 2].min(), T[:, 2].max()
    tb = T[np.abs(T[:, 2] - (u0 + 0.35 * (u1 - u0))) < 0.3]
    trig = tb[np.argmax(tb[:, 0])]
    sl = V[sf['slide']]; _, ba = pca(sl); ba = ba if ba[0] > 0 else -ba
    muz = allv[allv[:, 0] > allv[:, 0].max() - 0.4].mean(0)
    return dict(grip_axis=a, grip_c=c, web=web, trigger_face=trig, bore_axis=ba, muzzle=muz, grip_len=float(np.ptp(rear[:, 2])))

def kabsch(A, B, w):
    w = np.asarray(w, float)[:, None]
    ca = (A * w).sum(0) / w.sum(); cb = (B * w).sum(0) / w.sum()
    H = ((A - ca) * w).T @ (B - cb)
    U, _, Vt = np.linalg.svd(H); d = np.sign(np.linalg.det(Vt.T @ U.T))
    R = Vt.T @ np.diag([1, 1, d]) @ U.T
    return R, cb - ca @ R.T

def pts(L):
    a, c = L['grip_axis'], L['grip_c']
    return np.array([L['web'], L['trigger_face'], c - 3 * a, c, c + 3 * a, L['web'] + 8 * L['bore_axis']])

lw, lp = landmarks(BW, 0, SURF['BW']), landmarks(BP, 3, SURF['BP'])
W8 = [3, 3, 1, 1, 1, 2]			# web and trigger carry the hold; the bore line keeps the aim
R, t = kabsch(pts(lw), pts(lp), W8)
res0 = np.linalg.norm(pts(lw) @ R.T + t - pts(lp), axis=1)
ang = lambda u, v: float(np.degrees(np.arccos(np.clip(np.dot(u, v) / np.linalg.norm(u) / np.linalg.norm(v), -1, 1))))
# every 1911 vertex where it must be drawn: through BrutalPistol's own placement after the rigid move (the start)
V = np.concatenate([s['xyz'][0] for s in scene.md3_full(BW)])
target = gunview.to_fl(gunplace.to_local_ao(V @ R.T + t, BP_IT))
md0 = gunplace.fit(BW_IT, target)

# ---- the owner's two constraints, measured on the FBX pistol hand itself (2026-11-12: "just getting the magwell in hand and
# finger on trigger"; one direct solve, no rounds, the hand pose untouched). The hand = BD22 VR's BrutalPistol hand block
# (MODELDEF.rsqdual: fbx_b1_R.md3, RQFG A = frame 0 finger on the trigger, B = frame 2 squeezed; Scale -1 1 1, Offset 0 -24 -10).
# Everything in the drawn controller frame (cm). Sets are found from the md3 alone: the trigger finger = the vertices that move
# between frames 0 and 2; its pad = those within 0.6 cm of the closest one to BrutalPistol's trigger; the wrap = the other hand
# vertices within 1.5 cm of BrutalPistol's grip (palm, fingers, thumb base), the hold BD22 VR fitted.
import exactpen
from scipy.spatial import cKDTree
from scipy.optimize import least_squares
from scipy.spatial.transform import Rotation
HAND = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src/models/rsq/fbx/fbx_b1_R.md3'
def drawn(path, frame, pl, surf=None):
    T, Vs, n = [], [], 0
    for k, s in enumerate(scene.md3_full(path)):
        if surf is None or k in surf:
            Vs.append(gunview.to_fl(gunplace.to_local_ao(s['xyz'][frame], pl))); T.append(s['tris'] + n); n += len(Vs[-1])
    return np.concatenate(Vs), np.concatenate(T)
HPL = dict(scale=[-1.0, 1.0, 1.0], off=[0.0, -24.0, -10.0])
H0, HF = drawn(HAND, 0, HPL); H2, _ = drawn(HAND, 2, HPL)
def pl_of(m): return dict(scale=[-1.0, 1.0, 1.0], off=[m['Offset'][0], m['Offset'][1], m['ZOffset']], ao=(m['AngleOffset'], m['PitchOffset'], m['RollOffset']))
BPPL = dict(scale=BP_IT['scale'], off=BP_IT['off'], ao=BP_IT['ao'])
def meshes(path, frame, pl, sf):
    return dict(all=drawn(path, frame, pl), grip=drawn(path, frame, pl, sf['grip']), trig=drawn(path, frame, pl, (sf['trigger'],)))
bp = meshes(BP, 3, BPPL, SURF['BP'])
mv = np.linalg.norm(H2 - H0, axis=1); idx = np.where(mv > 0.3)[0]
d = exactpen.Exact(*bp['trig']).unsigned(H0[idx]); FINGER = idx[d < d.min() + 0.6]
rest = np.where(mv <= 0.3)[0]; WRAP = rest[exactpen.Exact(*bp['grip']).unsigned(H0[rest]) < 1.5]
exH = exactpen.Exact(H0, HF)
def measure(g):
    """hand_in_gun: hand vertices inside the gun; grip_in_hand: grip surface inside the hand (poking through);
    wrap_gap: wrap vertices to the grip (median, share within 1 cm); pad: trigger-finger pad to the trigger surface"""
    dep = exactpen.Exact(*g['all']).depth(H0); eg = exactpen.Exact(*g['grip']); dg = eg.unsigned(H0[WRAP])
    gin = exH.depth(gunfield.sample_surface(*g['grip'], 0.2)[0]); et = exactpen.Exact(*g['trig']); dt = et.unsigned(H0[FINGER])
    r = lambda x: round(float(x), 3)
    return dict(hand_in_gun_max=r(dep.max()), hand_in_gun_n=int((dep > 0.05).sum()), grip_in_hand_max=r(gin.max()), grip_in_hand_n=int((gin > 0.05).sum()),
                wrap_gap_median=r(np.median(dg)), wrap_within_1cm=r((dg < 1.0).mean()), pad_to_trigger_min=r(dt.min()),
                pad_to_trigger_median=r(np.median(dt)), pad_in_trigger_max=r(et.depth(H0[FINGER]).max()))
def tf(p, pl): return gunview.to_fl(gunplace.to_local_ao(np.atleast_2d(np.asarray(p, float)), pl))[0]
def dirv(L, pl, k): c = tf(L['grip_c'], pl); u = tf(L['grip_c'] + L[k], pl) - c; return u / np.linalg.norm(u)
def with_normals(V, F, ex, step=0.1):
    A, B, C = V[F[:, 0]], V[F[:, 1]], V[F[:, 2]]; n = np.maximum(1, (0.5 * np.linalg.norm(np.cross(B - A, C - A), axis=1) / step ** 2).astype(int))
    tri = np.repeat(np.arange(len(F)), n); g = np.random.default_rng(0); r1, r2 = g.random(len(tri)), g.random(len(tri)); q = np.sqrt(r1)
    P = A[tri] * (1 - q)[:, None] + B[tri] * (q * (1 - r2))[:, None] + C[tri] * (q * r2)[:, None]
    N = np.cross(B - A, C - A); N = (N / (np.linalg.norm(N, axis=1, keepdims=True) + 1e-12))[tri]
    k = np.random.default_rng(2).choice(len(P), 400, replace=False)
    return P, (-N if (ex.depth(P[k] + 0.05 * N[k]) > 0).mean() > 0.5 else N)		# outward
pl0 = pl_of(md0); bw0 = meshes(BW, 0, pl0, SURF['BW']); exw = exactpen.Exact(*bw0['all'])
GP, GN = with_normals(*bw0['grip'], exw); TP, TN = with_normals(*bw0['trig'], exw); AP, AN = with_normals(*bw0['all'], exw)
boreB = dirv(lp, BPPL, 'bore_axis'); bore0 = dirv(lw, pl0, 'bore_axis'); piv = tf(lw['trigger_face'], pl0)
cb = tf(lp['grip_c'], BPPL); aB = dirv(lp, BPPL, 'grip_axis')
Wv = H0[WRAP]; Wv = Wv[np.abs((Wv - cb) @ aB) < 4]; Fp = H0[FINGER]
Hall = np.delete(H0, FINGER, axis=0); Hall = Hall[cKDTree(AP).query(Hall)[0] < 3]
trees = {k: cKDTree(P) for k, P in (('g', GP), ('t', TP), ('a', AP))}
def sd(Q, k, P, N): _, i = trees[k].query(Q); return np.einsum('ij,ij->i', Q - P[i], N[i])	# + outside the gun
def res(x):
    """x: the gun's move about its trigger face (rotation vector deg, translation cm); the hand is moved by the inverse"""
    Rm = Rotation.from_rotvec(np.radians(x[:3])).as_matrix(); inv = lambda Q: (Q - piv - x[3:]) @ Rm + piv
    pa = np.minimum(sd(inv(Hall), 'a', AP, AN), 0)					# no skin inside the gun anywhere
    s = sd(inv(Wv), 'g', GP, GN); g = np.where(s > 0, s, 10 * s)			# the grip into the hand's grip
    st = sd(inv(Fp), 't', TP, TN)							# the pad on the trigger face, not through it
    return np.r_[30 * pa / np.sqrt(len(pa)), 3 * g / np.sqrt(len(g)), 5 * np.abs(st).min(), 30 * np.minimum(st, 0) / np.sqrt(len(st)), 20 * (Rm @ bore0 - boreB)]
sol = least_squares(res, np.zeros(6), diff_step=1e-3)
Rm = Rotation.from_rotvec(np.radians(sol.x[:3])).as_matrix()
cur = gunview.to_fl(gunplace.to_local_ao(V, pl0)); md = gunplace.fit(BW_IT, (cur - piv) @ Rm.T + piv + sol.x[3:])
ang = lambda u, v: float(np.degrees(np.arccos(np.clip(np.dot(u, v) / np.linalg.norm(u) / np.linalg.norm(v), -1, 1))))
hand = dict(note='FBX pistol hand fbx_b1_R.md3 frame 0 (RQFG A), drawn frame, cm; BrutalPistol = the BD22 VR standard',
            pad_verts=len(FINGER), wrap_verts=len(WRAP), BrutalPistol=measure(bp), landmark_seat=measure(bw0),
            solved=measure(meshes(BW, 0, pl_of(md), SURF['BW'])),
            solve_move=dict(rotvec_deg=np.round(sol.x[:3], 3).tolist(), t_cm=np.round(sol.x[3:], 3).tolist()),
            bore_deg_vs_BrutalPistol=dict(landmark_seat=round(ang(bore0, boreB), 2), solved=round(ang(Rm @ bore0, boreB), 2)),
            muzzle_to_BrutalPistol_cm=dict(landmark_seat=round(float(np.linalg.norm(tf(lw['muzzle'], pl0) - tf(lp['muzzle'], BPPL))), 3),
                                           solved=round(float(np.linalg.norm(tf(lw['muzzle'], pl_of(md)) - tf(lp['muzzle'], BPPL))), 3)))
out = dict(modeldef=md, landmark_seat=dict(rigid_R=R.round(6).tolist(), rigid_t=t.round(4).tolist(), modeldef=md0), hand_fit=hand,
           residual_cm_md3={k: round(float(r), 3) for k, r in zip(['web', 'trigger_face', 'grip_lo', 'grip_c', 'grip_hi', 'bore_line'], res0)},
           grip_axis_deg=round(ang(lw['grip_axis'] @ R.T, lp['grip_axis']), 2), bore_deg=round(ang(lw['bore_axis'] @ R.T, lp['bore_axis']), 2),
           grip_len=dict(bw=round(lw['grip_len'], 2), bp=round(lp['grip_len'], 2)),
           landmarks={'bw_1911': {k: np.round(v, 3).tolist() if isinstance(v, np.ndarray) else v for k, v in lw.items()},
                      'BrutalPistol': {k: np.round(v, 3).tolist() if isinstance(v, np.ndarray) else v for k, v in lp.items()}})
json.dump(out, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'seat_1911.json'), 'w'), indent=1)
print(json.dumps({k: out[k] for k in ('modeldef', 'hand_fit')}, indent=1))
