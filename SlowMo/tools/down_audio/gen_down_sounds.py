#!/usr/bin/env python3
"""gen_down_sounds.py -- DOWN's own sounds for RSQ SlowMo (owner 2026-11-09 17:45: "we will need some kind of audio cues").

    python3 SlowMo/tools/down_audio/gen_down_sounds.py

Synthesized here from sine waves and seeded noise (no samples, nothing ripped), so the pack owns them outright. Writes
16-bit mono WAVs at 22050 Hz into SlowMo/sounds/rsqsm/ (SNDINFO names in brackets):
  smdnhit.wav   [rsqsm/dnhit]    the drop: a heavy body hit -- a low thump falling 95 -> 32 Hz, a short noise crack on top
  smdnring.wav  [rsqsm/dnring]   the ringing in the ears after it: two close high tones (3.6 kHz, beating slowly), 3.5 s fade
  smdnbeat.wav  [rsqsm/dnbeat]   one heartbeat, lub-dub (down.zs plays it faster, higher and louder as DEATH IN runs down)
  smdnrlf.wav   [rsqsm/dnrelief] getting up: a soft rising major chord with a breath of noise swelling under it
Same output every run (fixed seed)."""
import math, os, random, struct, wave

RATE = 22050
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'sounds', 'rsqsm')


def write(name, samples, peak=0.9):
    m = max(1e-9, max(abs(x) for x in samples))
    k = peak / m
    path = os.path.join(OUT, name)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1.0, min(1.0, x * k)) * 32767)) for x in samples))
    print('wrote', path, '%.2f s' % (len(samples) / RATE))


def lowpass(xs, cut):
    a = 1.0 - math.exp(-2.0 * math.pi * cut / RATE)
    y, out = 0.0, []
    for x in xs:
        y += a * (x - y)
        out.append(y)
    return out


def soft(x):
    return math.tanh(x)


def hit():
    rnd = random.Random(2611)
    n = int(1.3 * RATE)
    noise = lowpass([rnd.uniform(-1, 1) for _ in range(n)], 1800)
    out, ph = [], 0.0
    for i in range(n):
        t = i / RATE
        f = 32 + 63 * math.exp(-t * 7.0)                 # the thump's pitch falls
        ph += 2 * math.pi * f / RATE
        body = math.sin(ph) * math.exp(-t * 3.2)
        sub = math.sin(ph * 0.5) * 0.6 * math.exp(-t * 2.0)
        crack = noise[i] * 2.2 * math.exp(-t * 38.0)     # the first ~60 ms
        att = min(1.0, t / 0.004)
        out.append(soft(1.6 * att * (body + sub + crack)))
    return out


def ring():
    n = int(3.5 * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / 0.25) * math.exp(-t * 0.9)
        x = math.sin(2 * math.pi * 3600 * t) + 0.8 * math.sin(2 * math.pi * 3607 * t) + 0.15 * math.sin(2 * math.pi * 7200 * t)
        out.append(x * env)
    return out


def thump(t, f, decay):
    if t < 0:
        return 0.0
    return math.sin(2 * math.pi * f * t + 2.0 * (1 - math.exp(-t * 30))) * math.exp(-t * decay) * min(1.0, t / 0.003)


def beat():
    n = int(0.5 * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        lub = thump(t, 58, 18) + 0.35 * thump(t, 116, 30)
        dub = 0.7 * (thump(t - 0.17, 72, 22) + 0.3 * thump(t - 0.17, 144, 34))
        out.append(soft(1.4 * (lub + dub)))
    return out


def relief():
    rnd = random.Random(1109)
    n = int(1.8 * RATE)
    noise = lowpass([rnd.uniform(-1, 1) for _ in range(n)], 900)
    out = []
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / 0.45) * math.exp(-max(0.0, t - 0.45) * 2.2)
        rise = 1.0 + 0.06 * min(1.0, t / 0.6)            # the chord lifts a little as it swells
        chord = sum(a * math.sin(2 * math.pi * f * rise * t) for f, a in ((220, 1.0), (277.2, 0.7), (329.6, 0.6), (440, 0.3)))
        breath = noise[i] * 1.5 * min(1.0, t / 0.5) * math.exp(-max(0.0, t - 0.5) * 3.0)
        out.append(env * chord * 0.5 + breath)
    return out


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    write('smdnhit.wav', hit(), 0.95)
    write('smdnring.wav', ring(), 0.5)
    write('smdnbeat.wav', beat(), 0.9)
    write('smdnrlf.wav', relief(), 0.7)
