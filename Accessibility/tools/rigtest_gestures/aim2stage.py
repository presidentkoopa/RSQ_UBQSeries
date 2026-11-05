"""TEST ONLY: the rig's stage controller angles (pitch, yaw, roll) for a wanted AIM: the gun pointing
aimPitch up / aimYaw left and twisted `twist` degrees about its own pointing axis (a wrist twist).
Rig conventions (tools/rig/handrot.py, measured): stage orient = Ry(yaw) Rx(pitch) R(-Z, roll), and the
engine's aim frame = orient @ Rx(vr_weaponRotate = -30)."""
import sys
import numpy as np
from scipy.spatial.transform import Rotation as Rot

def R(axis, deg):
    return Rot.from_rotvec(np.radians(deg) * np.array(axis, float)).as_matrix()

def stage(aimPitch, aimYaw, twist):
    A = R((0, 1, 0), aimYaw) @ R((1, 0, 0), aimPitch) @ R((0, 0, -1), twist)
    O = A @ R((1, 0, 0), 30.0)
    y, p, c = Rot.from_matrix(O).as_euler('YXZ', degrees=True)
    return p, y, -c

if __name__ == '__main__':
    a = [float(v) for v in sys.argv[1:4]]
    print('%.2f %.2f %.2f' % stage(*a))
