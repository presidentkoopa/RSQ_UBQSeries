# gen_sounds.py -- the cigarette's and the Zippo's sounds, synthesised from a fixed seed (owned outright).
#   rtzpopen  the lid flicked open: a bright metal clink
#   rtzplite  the wheel and the catch: a gritty scrape and a soft whump
#   rtzpclos  the lid snapped shut: a duller clack
#   rtcglite  the tip catching on a draw: a crackling sizzle
import numpy as np, wave, sys, os
SR = 22050
rng = np.random.default_rng(4242)
out = sys.argv[1] if len(sys.argv) > 1 else "sounds/rsqtr"

def save(name, x):
    x = x / max(1e-9, np.abs(x).max()) * 0.8
    w = wave.open(os.path.join(out, name + ".wav"), "wb")
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype(np.int16).tobytes()); w.close()

def t_(sec): return np.arange(int(SR * sec)) / SR

def clink(f0, dec, sec=0.25):
    t = t_(sec)
    return sum(np.sin(2 * np.pi * f0 * k * t) * np.exp(-t / (dec / k)) / k for k in (1, 2.76, 5.4))

t = t_(0.25); save("rtzpopen", clink(2400, 0.06) + 0.4 * rng.standard_normal(len(t)) * np.exp(-t / 0.004))
t = t_(0.6)
scrape = rng.standard_normal(len(t)) * (np.abs(np.sin(2 * np.pi * 38 * t)) ** 3) * np.exp(-t / 0.08)
whump = np.convolve(rng.standard_normal(len(t)), np.ones(60) / 60, mode="same") * np.exp(-np.maximum(t - 0.07, 0) / 0.18) * (t > 0.07)
save("rtzplite", scrape + 3.0 * whump)
t = t_(0.2); save("rtzpclos", clink(900, 0.03, 0.2) + 0.6 * rng.standard_normal(len(t)) * np.exp(-t / 0.006))
t = t_(0.9)
crack = np.zeros(len(t))
for _ in range(60):
    i = rng.integers(0, len(t) - 200); crack[i:i + 40] += rng.standard_normal(40) * np.exp(-np.arange(40) / 8) * rng.uniform(0.3, 1)
hiss = rng.standard_normal(len(t)) * 0.15
save("rtcglite", (crack + hiss) * np.minimum(1, t / 0.1) * np.minimum(1, (0.9 - t) / 0.3))
