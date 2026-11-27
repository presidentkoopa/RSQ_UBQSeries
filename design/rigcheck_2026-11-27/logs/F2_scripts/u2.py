import sys; sys.path.insert(0, '/home/claude/rigdata/probes/B/gen')
from dglib import D
s = D(); s.start(extra=('netevent B_hp 900',))
s.tp(-260, 252, 0); s.add('set rsqdg_sight 0', 'netevent B_spawn:Clip 210 0 0'); s.w(3)
s.mark('U2_SIGHT_OFF_BEHIND_WALL'); s.palm('l', wait=8); s.add('netevent B_track:Clip 1 30'); s.flick('l', hold=30); s.back('l'); s.w(3)
s.mark('END'); s.w(3); s.add('quit')
s.save(sys.argv[1])
