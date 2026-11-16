"""make_chargehum.py: the Nova Ball's and the Hyper Nova's charge buzz (owner 2026-11-16 03:30, fix 6), made here, not
taken from anyone: a half-second loop of an 80 Hz saw with its octave and a 30 Hz throb, every part a whole number of
cycles in the loop so it loops without a click. The game raises its pitch and volume over the charge
(zscript/wos/charge.zs, A_SoundPitch / A_SoundVolume).

    python3 tools/make_chargehum.py   -> src/sounds/rsqws/chargehum.wav (the build copies src/ into the pack)"""
import math, os, struct, wave
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
RATE, SECS = 22050, 0.5
N = int(RATE * SECS)
out = []
for i in range(N):
    t = i / RATE
    saw = lambda f: 2.0 * ((t * f) % 1.0) - 1.0
    s = 0.55 * saw(80) + 0.25 * saw(160) + 0.12 * math.sin(2 * math.pi * 320 * t)
    s *= 0.75 + 0.25 * math.sin(2 * math.pi * 30 * t)
    out.append(int(max(-1.0, min(1.0, s * 0.8)) * 32000))
for d in (os.path.join(ROOT, 'src/sounds/rsqws'),):
    os.makedirs(d, exist_ok=True)
    w = wave.open(os.path.join(d, 'chargehum.wav'), 'wb')
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
    w.writeframes(b''.join(struct.pack('<h', v) for v in out)); w.close()
print('chargehum.wav', N, 'samples')
