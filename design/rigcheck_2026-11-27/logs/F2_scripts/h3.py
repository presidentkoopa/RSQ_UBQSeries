import sys; sys.path.insert(0, '/home/claude/rigdata/probes/B/gen')
from dglib import D, swing
s = D(); s.start()
# H only: grip throw upward into open floor (no monster), as B_D3's H
s.add('netevent B_spawn:ExplosiveBarrel 40 0 0'); s.w(3)
s.mark('H_GRIP_THROW_UP'); s.move('l', z=-0.75, y=1.0, x=-0.1); s.add('qz_lgrip 1'); s.w(10); s.move('l', z=-0.2, y=1.1, x=-0.25); s.w(3)
swing(s, 'l', dz=(-0.15, -0.15, -0.15, -0.07, -0.03, -0.01), dy=(0.08, 0.08, 0.08, 0.04, 0.01, 0), at=3, act=('qz_lgrip 0',), settle=50)
s.add('netevent B_count:ExplosiveBarrel')
s.mark('END'); s.w(3); s.add('quit')
s.save(sys.argv[1])
