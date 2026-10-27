# gen_sounds.py -- the clock's own cues, synthesised from a fixed seed (owned outright).
#   smin   time bending down: a low swell with a falling, filtered rush
#   smout  time coming back: the reverse
#   smredy the adrenaline meter full: two heartbeat thumps
#   smempt not enough adrenaline: a dull click
import numpy as np, wave, sys, os
SR = 22050
rng = np.random.default_rng(1977)
out = sys.argv[1] if len(sys.argv) > 1 else "sounds/rsqsm"

def save(name, x):
    x = x / max(1e-9, np.abs(x).max()) * 0.85
    w = wave.open(os.path.join(out, name + ".wav"), "wb")
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype(np.int16).tobytes()); w.close()

def lowpass(x, a):
    y = np.zeros_like(x); s = 0.0
    for i, v in enumerate(x):
        s += a[i] * (v - s); y[i] = s
    return y

def bend(down):
    n = int(SR * 0.9); t = np.arange(n) / SR
    f = 90 * (0.55 ** (t / 0.9)) if down else 50 * (1.8 ** (t / 0.9))
    tone = np.sin(2 * np.pi * np.cumsum(f) / SR)
    a = np.linspace(0.25, 0.02, n) if down else np.linspace(0.02, 0.25, n)
    rush = lowpass(rng.standard_normal(n), a)
    env = np.minimum(1, t / 0.08) * np.minimum(1, (0.9 - t) / 0.35)
    return (0.8 * tone + 2.5 * rush) * env

def thump(t0, n):
    t = np.arange(n) / SR - t0
    return np.where(t >= 0, np.sin(2 * np.pi * 55 * t) * np.exp(-np.maximum(t, 0) / 0.07), 0)

save("smin", bend(True))
save("smout", bend(False))
n = int(SR * 0.7); save("smredy", thump(0.0, n) + 0.8 * thump(0.28, n))
n = int(SR * 0.12); t = np.arange(n) / SR
save("smempt", np.sin(2 * np.pi * 180 * t) * np.exp(-t / 0.015) + 0.3 * rng.standard_normal(n) * np.exp(-t / 0.004))
