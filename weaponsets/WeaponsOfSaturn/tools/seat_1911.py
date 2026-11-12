"""Seat the BrutalWolf 1911 in BD22 VR's FBX pistol hand (owner 2026-11-12: re-measure it where it sits, put the FBX
hand on it). BD22 VR's method: the hand is pinned to the controller and the GUN moves to the hand. The FBX pistol hand
was solved on BrutalPistol; the 1911 is moved rigidly so its grip, backstrap notch (the web's seat) and trigger face land
where BrutalPistol's are, then its MODELDEF numbers are solved (ModelSwapper gunplace.fit). Writes seat_1911.json.
Landmarks are measured here, on both meshes, by the same rules (gunlm.pistol's, in md3 file units)."""
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
res = np.linalg.norm(pts(lw) @ R.T + t - pts(lp), axis=1)
ang = lambda u, v: float(np.degrees(np.arccos(np.clip(np.dot(u, v) / np.linalg.norm(u) / np.linalg.norm(v), -1, 1))))
# every 1911 vertex where it must be drawn: through BrutalPistol's own placement after the rigid move
V = np.concatenate([s['xyz'][0] for s in scene.md3_full(BW)])
target = gunview.to_fl(gunplace.to_local_ao(V @ R.T + t, BP_IT))
md = gunplace.fit(BW_IT, target)
out = dict(rigid_R=R.round(6).tolist(), rigid_t=t.round(4).tolist(), modeldef=md,
           residual_cm_md3={k: round(float(r), 3) for k, r in zip(['web', 'trigger_face', 'grip_lo', 'grip_c', 'grip_hi', 'bore_line'], res)},
           grip_axis_deg=round(ang(lw['grip_axis'] @ R.T, lp['grip_axis']), 2), bore_deg=round(ang(lw['bore_axis'] @ R.T, lp['bore_axis']), 2),
           grip_len=dict(bw=round(lw['grip_len'], 2), bp=round(lp['grip_len'], 2)),
           landmarks={'bw_1911': {k: np.round(v, 3).tolist() if isinstance(v, np.ndarray) else v for k, v in lw.items()},
                      'BrutalPistol': {k: np.round(v, 3).tolist() if isinstance(v, np.ndarray) else v for k, v in lp.items()}})
json.dump(out, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'seat_1911.json'), 'w'), indent=1)
print(json.dumps({k: out[k] for k in ('modeldef', 'residual_cm_md3', 'grip_axis_deg', 'bore_deg', 'grip_len')}, indent=1))
