#!/usr/bin/env python3
"""Generate the whip's skin and sounds. Procedural, deterministic, no samples from anywhere.

    python3 tools/gen_whip.py

Writes
  models/rsqgr/rsqwhip.png   the thong's skin: plaited brown leather (an 8-strand diamond
                             plait), on the rope's tube (rsqrope.md3, gen_rope.py)
  models/rsqgr/rsqwhiph.png  the handle's skin: dark wrapped leather with a knot band
  sounds/RSGWCRK1..3         three cracks: a supersonic tip makes an N-wave (a pressure jump
                             up, a ramp down, a jump back) about a millisecond long; what
                             you hear is that click and the room answering it
  sounds/RSGWSWS1..2         two swishes: band-passed noise whose band rises with the tip
  sounds/RSGWUNF             the thong unfurling / rolling up: a soft leather rustle
"""
import os, struct, wave
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
SR = 44100
rng = np.random.default_rng(1977)


def skin():
    W, H = 64, 256                       # u around the tube, v along it
    img = np.zeros((H, W, 3), np.float32)
    base = np.array([96, 58, 32], np.float32)
    dark = np.array([46, 26, 14], np.float32)
    for y in range(H):
        for x in range(W):
            # two families of diagonal strands crossing: an 8-strand plait reads as diamonds
            a = (x / W * 4 + y / 16.0) % 1.0
            b = (x / W * 4 - y / 16.0) % 1.0
            over = ((int(x / W * 4 + y / 16.0) + int(x / W * 4 - y / 16.0)) % 2) == 0
            s = a if over else b
            shade = 0.55 + 0.45 * np.sin(np.pi * s)     # each strand rounded
            groove = min(a, 1 - a, b, 1 - b)
            g = 1.0 if groove > 0.06 else 0.45
            c = dark + (base - dark) * shade * g
            img[y, x] = c * (0.92 + 0.08 * rng.random())
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(os.path.join(ROOT, 'models/rsqgr/rsqwhip.png'))
    W, H = 64, 128
    img = np.zeros((H, W, 3), np.float32)
    for y in range(H):
        for x in range(W):
            wrap = 0.6 + 0.4 * abs(np.sin(np.pi * (y / 6.0 + x / W)))
            c = np.array([58, 36, 22], np.float32) * wrap
            if 100 <= y <= 116: c = np.array([120, 84, 48], np.float32) * (0.7 + 0.3 * np.sin(np.pi * (y - 100) / 16))
            img[y, x] = c * (0.9 + 0.1 * rng.random())
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(os.path.join(ROOT, 'models/rsqgr/rsqwhiph.png'))


def band(x, lo, hi):
    f = np.fft.rfft(x)
    fr = np.fft.rfftfreq(len(x), 1 / SR)
    f[(fr < lo) | (fr > hi)] = 0
    return np.fft.irfft(f, len(x))


def write(name, x):
    x = x / (np.max(np.abs(x)) + 1e-9) * 0.92
    pcm = (x * 32767).astype('<i2').tobytes()
    with wave.open(os.path.join(ROOT, 'sounds', name), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm)


def crack(seed, nlen_ms, room):
    r = np.random.default_rng(seed)
    n = int(SR * 0.45)
    x = np.zeros(n)
    # the N-wave: jump to +1, ramp to -1, jump back to 0
    m = int(SR * nlen_ms / 1000)
    x[:m] = np.linspace(1.0, -1.0, m)
    # the air tearing behind it: a few ms of bright noise, falling fast
    t = np.arange(n) / SR
    burst = r.standard_normal(n) * np.exp(-t / 0.006) * 0.55
    x += band(burst, 1800, 12000)
    # a dull thump under it (the loop turning over), very short
    x += band(r.standard_normal(n) * np.exp(-t / 0.012), 120, 700) * 0.35
    # the room: early reflections, then a decaying tail
    out = x.copy()
    for d_ms, g in ((7, 0.45), (13, 0.32), (23, 0.22), (37, 0.15)):
        d = int(SR * d_ms / 1000)
        out[d:] += x[:n - d] * g
    tail = band(r.standard_normal(n), 400, 7000) * np.exp(-t / room) * 0.10
    tail[:int(SR * 0.004)] = 0
    out += tail
    return out


def swish(seed, dur, f0, f1):
    r = np.random.default_rng(seed)
    n = int(SR * dur)
    t = np.arange(n) / SR
    out = np.zeros(n)
    noise = r.standard_normal(n)
    # sweep a band from f0 to f1 in short overlapping blocks
    blk = 1024
    win = np.hanning(blk)
    for s in range(0, n - blk, blk // 2):
        c = f0 + (f1 - f0) * (s / n) ** 1.5
        out[s:s + blk] += band(noise[s:s + blk] * win, c * 0.6, c * 1.6)
    env = np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 2 * (0.3 + 0.7 * t / dur)
    return out * env


def unfurl():
    r = np.random.default_rng(5)
    n = int(SR * 0.35)
    t = np.arange(n) / SR
    out = band(r.standard_normal(n), 300, 3500) * (0.4 + 0.6 * np.abs(np.sin(2 * np.pi * 9 * t)))
    return out * np.sin(np.pi * t / 0.35) ** 1.5


if __name__ == '__main__':
    os.makedirs(os.path.join(ROOT, 'sounds'), exist_ok=True)
    skin()
    write('RSGWCRK1', crack(11, 1.1, 0.09))
    write('RSGWCRK2', crack(23, 0.9, 0.12))
    write('RSGWCRK3', crack(37, 1.3, 0.07))
    write('RSGWSWS1', swish(3, 0.30, 500, 2600))
    write('RSGWSWS2', swish(8, 0.24, 700, 3400))
    write('RSGWUNF', unfurl())
    print('wrote rsqwhip.png rsqwhiph.png RSGWCRK1-3 RSGWSWS1-2 RSGWUNF')
