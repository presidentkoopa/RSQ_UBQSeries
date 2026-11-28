import rig, re, sys, mags
g = mags.tables()[1]
pouch = rig.lpose(0, 40, -30)
ins = 'qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 12; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 25; qz_ltrigger 0; wait 40; ' % (
    pouch, mags.at(g, g['M'] + 3), mags.at(g, g['M'] * 0.5), mags.at(g, 0))
s = ('wait 120; god; notarget; rsq_ballistics 2; rsq_recoil 1; rsr_reload 1; give Rifle; give Clip2 200; use Rifle; wait 80; echo B22PH walk; '
     '+forward; wait 70; -forward; +back; wait 70; -back; wait 20; echo B22PH fire; +attack; wait 8; -attack; wait 30; '
     'echo B22PH reload; +reload; wait 4; -reload; wait 30; ' + ins + 'echo B22PH after; wait 60; quit')
rc, t = rig.run(sys.argv[1], s, 400)
ph = 'start'; rows = {}
for l in t.splitlines():
    m = re.match(r'B22PH (\w+)', l.strip())
    if m: ph = m.group(1); continue
    m = re.match(r'B22 PSP \d+ x (\S+) y (\S+) flashes (\d+)', l)
    if m: rows.setdefault(ph, []).append((float(m.group(1)), float(m.group(2)), int(m.group(3))))
for ph in ('walk', 'fire', 'reload', 'after'):
    r = rows.get(ph, [])
    if r: print('%-7s |x| max %7.1f  y range %6.1f..%6.1f  flashes seen max %d  last x %.1f' % (ph, max(abs(a) for a, b, c in r), min(b for a, b, c in r), max(b for a, b, c in r), max(c for a, b, c in r), r[-1][0]))
