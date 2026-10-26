# How far behind the hand the beam's hand end is drawn, with and without lead.
# Engine model: playsim at 35 Hz samples the hand pose the renderer last wrote
# (up to one frame old); renderer at 90 Hz draws Prev + (Pos - Prev) * f, where
# Pos is this tic's placement, Prev last tic's, f the fraction into the tic.
import numpy as np
TIC, FPS = 1/35, 90
def run(x, lead, T=6.0):
    tics = np.arange(0, T, TIC)
    frames = np.arange(0, T, 1/FPS)
    last_frame = lambda t: frames[frames <= t].max() if (frames <= t).any() else 0.0
    samp = np.array([x(last_frame(t)) for t in tics])          # what script sees
    pos = samp.copy()
    pos[1:] = samp[1:] + (samp[1:] - samp[:-1]) * lead          # the placement
    err = []
    for t in frames[frames > 2*TIC]:
        n = int(t // TIC); f = (t - n*TIC) / TIC
        drawn = pos[n-1] + (pos[n] - pos[n-1]) * f
        err.append(drawn - x(t))
    e = np.abs(np.array(err)) * 100   # metres -> cm
    return e.mean(), e.max()
cases = {
 'slow sweep  (1 Hz, 30 cm)':  lambda t: 0.30*np.sin(2*np.pi*1.0*t),
 'fast sweep  (3 Hz, 20 cm)':  lambda t: 0.20*np.sin(2*np.pi*3.0*t),
 'swing at 2 m/s, then STOP':  lambda t: 2.0*min(t, 1.5) if t < 3 else 3.0,
}
print('%-28s %18s %18s %18s' % ('case', 'no lead (avg/max)', 'lead 1.0', 'lead 0.7'))
for name, x in cases.items():
    r = [run(x, l) for l in (0.0, 1.0, 0.7)]
    print('%-28s %18s %18s %18s' % (name, *['%5.1f / %5.1f cm' % a for a in r]))
