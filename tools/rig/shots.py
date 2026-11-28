"""TEST ONLY: render the held gun in front of the eye and save frames: shots.py <tag> <pk3> <script-part>"""
import rig, os, sys, glob, shutil, subprocess
from PIL import Image
SP = __import__('rig').B + '/shots'
def shoot(tag, pk3, body, every=20, secs=500, probe=False):
    d = os.path.join(SP, tag); shutil.rmtree(d, ignore_errors=True); os.makedirs(d)
    env = dict(QZ_RES='480', QZ_DUMP_EVERY=str(every), QZ_DUMP_DIR=d, B22_PK3=pk3)
    if not probe: env['B22_NOPROBE'] = '1'
    old = dict(os.environ); os.environ.update(env)
    try:
        import importlib; importlib.reload(rig)
        rig.run('shot_' + tag, 'wait 100; god; notarget; screenblocks 12; crosshair 0; ' + body + '; quit', secs)
    finally:
        os.environ.clear(); os.environ.update(old)
    return sorted(glob.glob(d + '/*.ppm'))
if __name__ == '__main__':
    print(len(shoot(sys.argv[1], sys.argv[2], sys.argv[3])))
