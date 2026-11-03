# TEST ONLY: seq.py <mesh 0|1> <lefty 0|1> -> the console script for one Force-hand sequence
import sys
m, lefty = int(sys.argv[1]), int(sys.argv[2])
sx = 0.12 if lefty else -0.12
mx = -0.30 if lefty else 0.30
off = 'qz_rhand' if lefty else 'qz_lhand'
main = 'qz_lhand' if lefty else 'qz_rhand'
def H(z, p=30, y=0): return '%s "%.2f 1.42 %.2f %d %d 0"' % (off, sx, z, p, y)
s = ['god', 'notarget', 'ubqs_dual_mode 0', 'ubqs_fhand_mesh %d' % m, 'vr_control_scheme %d' % (10 if lefty else 0),
     '%s "%.2f 1.2 -0.25 30 0 0"' % (main, mx), H(-0.38), 'wait 30', 'netevent fhp_arm', 'wait 30'] + (['netevent bonsai-debug,w-up,RSQ_Upgrade_ForceSensitive 1', 'netevent bonsai-debug,w-up,RSQ_Upgrade_ForcePush 1', 'netevent bonsai-debug,w-up,RSQ_Upgrade_ForcePull 1', 'netevent bonsai-debug,w-up,RSQ_Upgrade_ForceChoke 1', 'wait 2'] if len(sys.argv) > 3 else []) + [ 'netevent fhp_imps',
     'wait 30', 'echo MARK_IDLE', 'wait 15',
     '+oh_altatk', 'wait 4', 'echo MARK_ARMED', 'wait 4', H(-0.62), 'wait 1', 'echo MARK_PUSH', 'wait 12', '-oh_altatk', 'wait 10', H(-0.38), 'wait 45',
     H(-0.62), 'wait 10', '+oh_altatk', 'wait 6', H(-0.36), 'wait 1', 'echo MARK_PULL', 'wait 12', '-oh_altatk', 'wait 45',
     '+oh_altatk', 'echo MARK_GRIPSTART', 'wait 40', 'echo MARK_GRIP', 'wait 20', '-oh_altatk', 'wait 10',
     H(-0.38, 30, -45), 'wait 15', 'echo MARK_SIDE', 'wait 10', 'quit']
print('; '.join(s))
