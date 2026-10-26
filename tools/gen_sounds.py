#!/usr/bin/env python3
"""Generate RSQ_DistanceGrab's feedback sounds. Procedural, original, no samples.

    python3 tools/gen_sounds.py            -> sounds/RSQDG*.wav

Re-runnable and deterministic (fixed seed), so the WAVs in sounds/ can always be
rebuilt from this file and tuned here rather than in an editor. 22050 Hz, 16-bit
mono: small on a Quest, and nothing here has content above 8 kHz.

  RSQDGLOK  lock      a short glassy tick-chime. Played AT THE PALM.
  RSQDGLNC  launch    an upward whoosh: band noise sweeping up + a rising tone.
  RSQDGHUM  hum       a seamless 1 s loop: a soft drone with a slow shimmer.
                      Looped on the flying object; the engine raises its pitch
                      as it closes (feel.zs). Built from whole cycles so the
                      loop point is inaudible.
  RSQDGCAT  catch     a soft thump with a bright edge. Played at the palm.
  RSQDGDRP  drop      a falling 'bloop': it got away.

Every sound is pitch-shifted by the object's mass at play time (light = high,
heavy = low), so one set covers a clip and a barrel.
"""
import os
import wave
import numpy as np

SR = 22050
RNG = np.random.default_rng(0x5153)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'sounds')


def env_ad(n, attack, decay_tau):
    t = np.arange(n) / SR
    a = np.clip(t / max(attack, 1e-4), 0, 1)
    return a * np.exp(-np.maximum(t - attack, 0) / decay_tau)


def onepole_lp(x, fc):
    a = np.exp(-2 * np.pi * fc / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def norm(x, peak=0.85):
    m = np.max(np.abs(x))
    return x * (peak / m) if m > 0 else x


def fade_edges(x, ms=4):
    n = int(SR * ms / 1000)
    if n * 2 < len(x):
        r = np.linspace(0, 1, n)
        x[:n] *= r
        x[-n:] *= r[::-1]
    return x


def write(name, x):
    os.makedirs(OUT, exist_ok=True)
    pcm = (np.clip(x, -1, 1) * 32767).astype('<i2')
    with wave.open(os.path.join(OUT, name + '.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print('%s.wav  %.2fs  %d bytes' % (name, len(x) / SR, len(pcm) * 2 + 44))


def lock():
    n = int(SR * 0.16)
    t = np.arange(n) / SR
    # two inharmonic partials = glassy; a tiny noise click on the front
    x = 0.6 * np.sin(2 * np.pi * 1760 * t) * env_ad(n, 0.002, 0.045)
    x += 0.35 * np.sin(2 * np.pi * 2793 * t) * env_ad(n, 0.002, 0.025)
    x += 0.25 * np.sin(2 * np.pi * 880 * t) * env_ad(n, 0.003, 0.06)
    click = RNG.standard_normal(n) * env_ad(n, 0.0005, 0.003)
    x += 0.3 * click
    return fade_edges(norm(x, 0.8))


def launch():
    n = int(SR * 0.38)
    t = np.arange(n) / SR
    p = t / t[-1]
    # rising tone
    f = 220 + 700 * p ** 1.5
    phase = 2 * np.pi * np.cumsum(f) / SR
    tone = np.sin(phase) * 0.35
    # band noise whose cutoff sweeps up
    noise = RNG.standard_normal(n)
    lo = onepole_lp(noise, 600)
    hi = onepole_lp(noise, 3500)
    band = (hi - lo)
    mix = (1 - p) * lo * 0.5 + p * band
    e = np.sin(np.pi * np.clip(p, 0, 1)) ** 0.8
    x = (tone + mix * 0.9) * e
    return fade_edges(norm(x, 0.75))


def hum():
    # exactly 1.0 s; every partial an integer number of cycles -> seamless loop
    n = SR
    t = np.arange(n) / SR
    x = (0.55 * np.sin(2 * np.pi * 110 * t)
         + 0.25 * np.sin(2 * np.pi * 220 * t + 0.4)
         + 0.12 * np.sin(2 * np.pi * 331 * t + 1.1)
         + 0.08 * np.sin(2 * np.pi * 662 * t + 2.0))
    # slow shimmer: 3 Hz amplitude wobble and a 2 Hz detuned pair (integer Hz)
    x *= 0.8 + 0.2 * np.sin(2 * np.pi * 3 * t)
    x += 0.10 * np.sin(2 * np.pi * 112 * t) * (0.5 + 0.5 * np.sin(2 * np.pi * 2 * t))
    return norm(x, 0.7)   # no edge fades: it loops


def catch():
    n = int(SR * 0.22)
    t = np.arange(n) / SR
    f = 140 * np.exp(-t / 0.05) + 70       # pitch drop = weight landing
    body = np.sin(2 * np.pi * np.cumsum(f) / SR) * env_ad(n, 0.002, 0.07)
    edge = onepole_lp(RNG.standard_normal(n), 2500) * env_ad(n, 0.001, 0.012)
    ring = 0.2 * np.sin(2 * np.pi * 1320 * t) * env_ad(n, 0.002, 0.03)
    x = body * 0.9 + edge * 0.6 + ring
    return fade_edges(norm(x, 0.85))


def drop():
    n = int(SR * 0.28)
    t = np.arange(n) / SR
    f = 520 * np.exp(-t / 0.09) + 120      # falling: it got away
    x = np.sin(2 * np.pi * np.cumsum(f) / SR) * env_ad(n, 0.004, 0.09)
    x += 0.15 * onepole_lp(RNG.standard_normal(n), 900) * env_ad(n, 0.002, 0.04)
    return fade_edges(norm(x, 0.7))


if __name__ == '__main__':
    write('RSQDGLOK', lock())
    write('RSQDGLNC', launch())
    write('RSQDGHUM', hum())
    write('RSQDGCAT', catch())
    write('RSQDGDRP', drop())
