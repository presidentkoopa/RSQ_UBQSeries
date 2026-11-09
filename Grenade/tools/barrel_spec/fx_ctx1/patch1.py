s=open('/tmp/fx_ctx1/ctx_a.py').read()
rep=[
("brick[:] = (0.13, 0.12, 0.13)","brick[:] = (0.2, 0.185, 0.19)"),
("brick[(yy % 12) == 0] = (0.08, 0.075, 0.08)","brick[(yy % 12) == 0] = (0.12, 0.11, 0.115)"),
("brick[((xx - WX + (yy // 12 % 2) * 12) % 24 == 0)] = (0.08, 0.075, 0.08)","brick[((xx - WX + (yy // 12 % 2) * 12) % 24 == 0)] = (0.12, 0.11, 0.115)"),
("brick[:, WX:WX + 2] = (0.28, 0.26, 0.27)","brick[:, WX:WX + 2] = (0.34, 0.32, 0.33)"),
("c[:, W:W + 2], (0.28, 0.26, 0.27))","c[:, W:W + 2], (0.34, 0.32, 0.33))"),
("s.ld = np.sqrt(((xx - WX) / 60) ** 2 + ((yy - cy) / 95) ** 2)","s.ld = np.sqrt(((xx - WX) / 46) ** 2 + ((yy - cy) / 84) ** 2)"),
("def __init__(s, WX, cy, t_scorch, scorch=(42, 70, 30)):","def __init__(s, WX, cy, t_scorch, scorch=(26, 66, 30)):"),
("            if dt < 3: cols = {3: (1.0, .78, .35), 2: (.95, .45, .12), 1: (.5, .18, .06)}\n            elif dt < 7: cols = {3: (.6, .2, .06), 2: (.32, .12, .05), 1: (.16, .09, .07)}\n            else: cols = {3: (.035, .03, .03), 2: (.06, .05, .045), 1: (.09, .08, .075)}",
 "            if dt < 3: cols = {3: (1.0, .7, .3), 2: (.7, .28, .08)}\n            elif dt < 7: cols = {3: (.45, .14, .05), 2: (.2, .09, .06), 1: (.12, .09, .08)}\n            else: cols = {3: (.03, .027, .027), 2: (.06, .052, .05), 1: (.11, .1, .095)}"),
("k, sv = (.4, 1.35 + .7 * g) if not l.floor else (.5, 1.0)","k, sv = (.35, 1.6 + 1.0 * g) if not l.floor else (.5, 1.0)"),
("ctx = Wall(WX, int(CEN[1] - U(4)), T0 + 1)","ctx = Wall(WX, int(CEN[1] - U(4)), T0 + 2)"),
("slab[:] = (0.12, 0.11, 0.12)","slab[:] = (0.2, 0.185, 0.19)"),
("slab[(yy % 10) == 0] = (0.08, 0.075, 0.08)","slab[(yy % 10) == 0] = (0.12, 0.11, 0.115)"),
("slab[((xx + (yy // 10 % 2) * 16) % 32 == 0)] = (0.08, 0.075, 0.08)","slab[((xx + (yy // 10 % 2) * 16) % 32 == 0)] = (0.12, 0.11, 0.115)"),
("slab[CYL - 2:CYL] = (0.28, 0.26, 0.27)","slab[CYL - 2:CYL] = (0.34, 0.32, 0.33)"),
("s.soot = make_scorch(BX, CYL, 95, 22, 1, 9)","s.soot = make_scorch(BX, CYL, 90, 16, 1, 9)"),
("Layer(strip(SMOKE[6:], [4] * 9 + [30]), T0 + 24","Layer(strip(SMOKE[5:12], [4] * 6 + [30]), T0 + 24"),
("SKY = [(0.012, 0.015, 0.05), (0.018, 0.024, 0.07), (0.026, 0.034, 0.09), (0.036, 0.045, 0.11), (0.05, 0.056, 0.13),\n       (0.07, 0.066, 0.14)]",
 "SKY = [(0.01, 0.012, 0.045), (0.02, 0.027, 0.08), (0.035, 0.045, 0.115), (0.055, 0.06, 0.145), (0.085, 0.075, 0.16),\n       (0.13, 0.09, 0.15)]"),
("Layer(strip(SMOKE[6:], [3] * 9 + [60]), t0,","Layer(strip(SMOKE[6:], [3, 3, 3, 3, 56, 3, 3, 3, 3, 3]), t0,"),
("alpha=.78, vel=(.12, -.35), grow=.5, fadein=4, fade=.9,","alpha=.78, vel=(.12, -.3), grow=.5, fadein=4, fade=None,"),
("ring = A.tint(A.gmap(YRING[2:7], 'blue'), (0.7, 0.9, 1.0))","ring = A.tint([A.white(f) for f in YRING[2:7]], (0.55, 0.8, 0.95))"),
("BUBF = A.gmap(seqB_strip := [","BUBF = A.tint(seqB_strip := ["),
("'/tmp/fx_agentB/cut/ruf_bubble/*.png'))], 'blue')","'/tmp/fx_agentB/cut/ruf_bubble/*.png'))], (0.8, 0.95, 1.0))"),
("(BX, CEN[1] - 6), size=60, grow=.9,\n                     vel=(0, -4.4)","(BX, CEN[1] - 6), size=84, grow=.9,\n                     vel=(0, -7.6)"),
("Bubbles(T0 + 2, BX, CEN[1], WS, n=44, R=52,","Bubbles(T0 + 2, BX, CEN[1], WS, n=64, R=70,"),
("Splash(T0 + 13, BX, WS, R=120, seed=3)","Splash(T0 + 12, BX, WS, R=120, seed=3, hump=(56, 18))"),
]
for a,b in rep:
    assert a in s, a[:60]; s=s.replace(a,b)
open('/tmp/fx_ctx1/ctx_a.py','w').write(s)
