#!/usr/bin/env python3
"""VisualRewards -- the arrival beams' sounds RVQB1-4 (owner picked 2026-11-09 18:50-18:53), made from the owner's own
files only: pitch (resampling), layering and echo. Nothing synthesized.
  RVQB1 V1 green  ONPARE8 (RVQCHMP) + itself an octave down at half volume, small-room echo
  RVQB2 V2 brown  ONPARE2 (RVQTHR1), the same with the octave at 0.45
  RVQB3 V3 blue   ONPARE3 (this folder) the same, faded out over 0.7-1.0 s so it ends with the beam
  RVQB4 V4 boss   ONPARE2 at tic 0 (0.6), PL01_U (RVQTHR2) lowered to 0.85 speed at tic 18 (the merge), hall echo
Run: python3 VisualRewards/tools/beam_sounds/gen_beam_sounds.py"""
import os, wave
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
SND = os.path.join(HERE, '..', '..', 'pk3', 'sounds', 'rsqvr')
OUT = os.environ.get('RSQVR_SND_OUT', SND)
SR = 22050; T = SR / 35
def rd(p):
    w = wave.open(p); return np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(float) / 32768
def wr(n, x):
    x = x / max(1e-9, np.abs(x).max()) * 0.95
    w = wave.open(os.path.join(OUT, n), 'wb'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype(np.int16).tobytes()); w.close()
def pitch(x, f): idx = np.arange(0, len(x) - 1, f); return np.interp(idx, np.arange(len(x)), x)
def echo(x, taps, tail):
    y = np.zeros(len(x) + int(tail * SR)); y[:len(x)] += x
    for d, g in taps: o = int(d * SR); y[o:o + len(x)] += g * x[:len(y) - o]
    return y
def at(parts):
    L = max(int(t * T) + len(p) for t, p, g in parts); y = np.zeros(L)
    for t, p, g in parts: o = int(t * T); y[o:o + len(p)] += g * p
    return y
def cut(x, start, end):
    x = x[:int(end * SR)].copy(); a = int(start * SR); x[a:] *= np.linspace(1, 0, len(x) - a) ** 1.5; return x
def wr_round(x):
    x = x / max(1e-9, np.abs(x).max()) * 0.95
    return (x * 32767).astype(np.int16).astype(float) / 32768
ROOM = [(0.045, 0.45), (0.09, 0.3), (0.15, 0.18), (0.23, 0.1)]
HALL = [(0.07, 0.5), (0.14, 0.35), (0.23, 0.25), (0.34, 0.16), (0.48, 0.1), (0.65, 0.06)]
def octave(x, g=0.5): return echo(x + g * pitch(x, 0.5)[:len(x)], ROOM, 0.5)
CH, T1, T2 = rd(os.path.join(SND, 'RVQCHMP.wav')), rd(os.path.join(SND, 'RVQTHR1.wav')), rd(os.path.join(SND, 'RVQTHR2.wav'))
O3 = rd(os.path.join(HERE, 'ONPARE3_00002.wav'))
wr('RVQB1.wav', octave(CH))
wr('RVQB2.wav', octave(T1, 0.45))
wr('RVQB3.wav', cut(wr_round(octave(O3)), 0.70, 1.00))   # cut from the 16-bit render, as it was made
wr('RVQB4.wav', echo(at([(0, T1, 0.6), (18, pitch(T2, 0.85), 1.0)]), HALL, 0.9))
