"""TEST ONLY: the rig's off-hand pose (pitch, yaw, roll in degrees) -> OffDirInGun matrix (gun frame F L U),
fitted to measurements from the probe. Gun hand at its default pose (pitch 30 = level)."""
import numpy as np
def R(axis, deg):
    a = np.radians(deg); c, s = np.cos(a), np.sin(a); x, y, z = axis
    return np.array([[c+x*x*(1-c), x*y*(1-c)-z*s, x*z*(1-c)+y*s],
                     [y*x*(1-c)+z*s, c+y*y*(1-c), y*z*(1-c)-x*s],
                     [z*x*(1-c)-y*s, z*y*(1-c)+x*s, c+z*z*(1-c)]])
# stage: x right, y up, z back.  gun frame F = -z, L = -x, U = y
S2G = np.array([[0, 0, -1], [-1, 0, 0], [0, 1, 0]], float)
MIRROR = np.diag([1, -1, 1.0])
def orient(p, y, r):          # ParsePose: q = qy * qx * qz, qz about -Z
    return R((0, 1, 0), y) @ R((1, 0, 0), p) @ R((0, 0, -1), r)
def offdir(p, y, r):
    Ro = orient(p, y, r) @ R((1, 0, 0), -30.0)      # vr_weaponRotate
    Rg = orient(30, 0, 0) @ R((1, 0, 0), -30.0)
    return S2G @ Rg.T @ Ro @ S2G.T @ MIRROR          # columns: images of off-hand F, L, U
if __name__ == '__main__':
    meas = {(30, 0, 0): [[1, 0, 0], [0, -1, 0], [0, 0, 1]], (30, 90, 0): [[0, 1, 0], [1, 0, 0], [0, 0, 1]],
            (60, 0, 0): [[.866, 0, .5], [0, -1, 0], [-.5, 0, .866]], (30, 0, 90): [[.75, .5, .433], [.5, 0, -.866], [.433, -.866, .25]]}
    for k, m in meas.items():
        M = offdir(*k); print(k, 'max err %.3f' % abs(M.T - np.array(m)).max())

from scipy.optimize import minimize
import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))

def solve_dir(a_hand, t_gun, start=(30, 0, 0)):
    """off-hand pitch, yaw, roll that turn the hand-frame direction a_hand onto the gun-frame t_gun."""
    a = np.array(a_hand, float); a /= np.linalg.norm(a)
    t = np.array(t_gun, float); t /= np.linalg.norm(t)
    best = None
    for y0 in (0, 90, 180, -90):
        for p0 in (30, -30, 90):
            r = minimize(lambda v: -float(offdir(*v) @ a @ t), (p0, y0, 0), method='Nelder-Mead')
            if best is None or r.fun < best.fun:
                best = r
    return tuple(best.x)

def place(pt_hand, a_hand, target_pt, t_gun):
    """rig qz_lhand pose: the hand-frame point pt_hand at target_pt, a_hand along t_gun."""
    import rig
    p, y, r = solve_dir(a_hand, t_gun)
    M = offdir(p, y, r)
    off = np.array(target_pt, float) - M @ np.array(pt_hand, float)
    return rig.lpose(off[0], off[1], off[2], pitch=p, yaw=y, roll=r), float(M @ (np.array(a_hand) / np.linalg.norm(a_hand)) @ (np.array(t_gun) / np.linalg.norm(t_gun)))
