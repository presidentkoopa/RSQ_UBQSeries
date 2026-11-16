#!/usr/bin/env python3
"""meleesounds.py -- bakes the owner's approved melee sounds and the BOSS INCOMING! siren (design/MELEE_SOUNDS.md, owner
2026-11-16 04:25-05:27) into the files the Series plays (tool only; never ships). One file per hit: every trim, pitch, layer, gain
and fade is baked in, so the game plays one sound. The jab's +/-5% pitch is NOT baked: it is drawn at play time.

    python3 Melee/tools/meleesounds.py <dir with punch1..punch11.wav> <the siren mp3> [repo root]

The source files are the owner's uploads (punch1-punch11, "source to be found") and his siren (Pixabay "Siren Alarm" by
freesound_community, freesound_community-siren-alarm-96503.mp3, Pixabay Content License); they are not in the repo. Two layers come from the repo: Melee/sounds/rsqml/fx/thud2.ogg and RSQ Monsters'
Monsters/sounds/combatfx/casings/DSRIFLC2.ogg (read from git when Monsters/ is not checked out).

THE PROCESSING IS THE APPROVED PREVIEW'S (its build.py, 2026-11-16 05:09: pitch(), the whoosh cut, the punch3 trim, the
clank cut, the thud gains, its overall gain x1.0584): each layer is lined up as the preview lined it up, by its onset (the
first sample at half its peak) on the moment of the hit, and the file starts where the earliest layer starts. Two changes
the spec asked for after the preview: the uppercut takes the kick's sound (owner 05:20), and the kick's punch7 has its soft
start cut so its thump (the peak of its low end, ~70 ms into the original) lands within 10 ms of the file's start; the
kick's thud then lands with that thump (both on contact, its own lead cut to match).
THE SIREN (owner 05:27, replacing the klaxon, which is dropped): the file as it is -- no cutting, re-timing or
re-levelling -- made mono 44.1 kHz, from its own start, stopped after its second whoop at 4.2 s (a 50 ms fade at the stop).

Outputs (mono 44.1 kHz; Ogg Vorbis q6 for RSQ Melee and RSQ Grapple, 16-bit WAV for RSQ VisualRewards, as its sounds are):
  Melee/sounds/rsqml/hit/  jab1 jab2 jab3 hookr hookl uppercut whip buttshove swing   (.ogg)
  Grapple/sounds/rsqgr/    kick whoosh                                                (.ogg)
  VisualRewards/pk3/sounds/rsqvr/RVQSIREN.wav
Needs ffmpeg, numpy, scipy."""
import os, subprocess, sys, tempfile
import numpy as np, scipy.io.wavfile as wv, scipy.signal as sg

SR = 44100
GAIN = 1.0583979328165245      # the preview's overall gain (0.89 / its loudest mix), so the levels are what he heard


def ms(v): return int(round(SR * v / 1000.0))


def decode(path, tmp):
    """any file -> mono 44.1 kHz 16-bit, read as floats (the preview's copies were made the same way)"""
    out = os.path.join(tmp, os.path.basename(path) + '.wav')
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', path, '-ac', '1', '-ar', str(SR), '-c:a', 'pcm_s16le', out], check=True)
    sr, x = wv.read(out)
    assert sr == SR
    return x.astype(np.float64) / 32768.0


def pitch(x, r):
    """resample-style pitch shift (as the engine plays a pitched sound): r > 1 higher and shorter (the preview's)"""
    n = int(len(x) / r)
    return np.interp(np.arange(n) * r, np.arange(len(x)), x)


def fade(x, fin_ms=0.0, fout_ms=0.0):
    x = x.copy()
    a, b = int(SR * fin_ms / 1000), int(SR * fout_ms / 1000)
    if a: x[:a] *= np.linspace(0, 1, a)
    if b: x[-b:] *= np.linspace(1, 0, b)
    return x


def onset(x, frac=0.5):
    a = np.abs(x)
    return int(np.argmax(a > frac * a.max()))


def thump(x):
    """the centre of the loudest 5 ms of the low end (< 200 Hz): punch7's thump, not its scrape"""
    b, a = sg.butter(4, 200 / (SR / 2))
    lo = sg.filtfilt(b, a, x)
    w = ms(5)
    n = len(lo) // w
    e = np.sqrt((lo[:n * w].reshape(n, w) ** 2).mean(1))
    return int(e.argmax() * w + w // 2)


def mix(layers):
    """layers: (samples, gain, align) -- align is the sample that lands on the hit. The file starts at the earliest layer."""
    lead = max(al for _, _, al in layers)
    n = max(lead - al + len(x) for x, _, al in layers)
    out = np.zeros(n)
    for x, g, al in layers:
        s = lead - al
        out[s:s + len(x)] += g * x
    return out, lead


def L(x, g, align=None): return (x, g, onset(x) if align is None else align)


def write(x, path, wav=False, gain=GAIN):
    x = x * gain
    pk = np.abs(x).max()
    assert pk < 0.99, (path, pk)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pcm = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    if wav:
        wv.write(path, SR, pcm)
    else:
        with tempfile.TemporaryDirectory() as t:
            tw = os.path.join(t, 'x.wav')
            wv.write(tw, SR, pcm)
            subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', tw, '-map_metadata', '-1', '-c:a', 'libvorbis', '-q:a', '6', path], check=True)
    return pk


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else '/home/claude/melee_snd'
    siren = sys.argv[2] if len(sys.argv) > 2 else '/mnt/user-data/uploads/05764f73-freesound_community-siren-alarm-96503.mp3'
    root = sys.argv[3] if len(sys.argv) > 3 else os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    with tempfile.TemporaryDirectory() as tmp:
        P = {k: decode(os.path.join(src, f'punch{k}.wav'), tmp) for k in (1, 3, 5, 6, 7, 9, 10, 11)}
        THUD = decode(os.path.join(root, 'Melee/sounds/rsqml/fx/thud2.ogg'), tmp)
        cas = os.path.join(root, 'Monsters/sounds/combatfx/casings/DSRIFLC2.ogg')
        if not os.path.exists(cas):
            cas = os.path.join(tmp, 'DSRIFLC2.ogg')
            with open(cas, 'wb') as f:
                f.write(subprocess.run(['git', '-C', root, 'show', 'HEAD:Monsters/sounds/combatfx/casings/DSRIFLC2.ogg'],
                                       check=True, capture_output=True).stdout)
        CASING = decode(cas, tmp)
        SIREN = decode(siren, tmp)

    # ---- the layers, as the preview built them -------------------------------------------------------------------------
    WHOOSH = fade(P[10][:ms(108)], 0, 8)          # punch10's lead-in, before its own impact at ~111 ms
    CLANK = fade(CASING[:ms(55)], 0, 15)          # the casing's first tick, nothing after
    BUTT = fade(pitch(P[3][ms(14):], 0.85), 1, 0) # punch3, its first 14 ms cut, then -15 % pitch
    KICKP = pitch(P[7], 0.80)                     # punch7 -20 % pitch
    KTHUD = pitch(THUD, 0.85)                     # thud2 -15 % pitch
    # THE KICK'S TRIM (spec 2026-11-16): cut its soft start so the thump lands 9 ms into the file (2 ms fade in)
    th = thump(KICKP)
    cut = th - ms(9)
    KICKT = fade(KICKP[cut:], 2, 0)
    tcut = max(0, onset(KTHUD) - ms(9))           # the thud's onset lands with the thump (on contact): its lead cut to 9 ms
    KTHUDT = fade(KTHUD[tcut:], 1, 0)

    out = {}
    M = os.path.join(root, 'Melee/sounds/rsqml/hit')
    G = os.path.join(root, 'Grapple/sounds/rsqgr')
    V = os.path.join(root, 'VisualRewards/pk3/sounds/rsqvr')
    rec = []

    def put(name, layers, path, wav=False, note='', gain=GAIN):
        x, lead = mix(layers)
        pk = write(x, path, wav, gain)
        rec.append((name, os.path.relpath(path, root), len(x) / SR * 1000, lead / SR * 1000, pk, note))
        out[name] = x * gain

    put('jab1', [L(P[9], 1.0)], f'{M}/jab1.ogg', note='punch9')
    put('jab2', [L(P[6], 1.0)], f'{M}/jab2.ogg', note='punch6')
    put('jab3', [L(P[1], 1.0)], f'{M}/jab3.ogg', note='punch1')
    put('hookr', [L(P[11], 1.0)], f'{M}/hookr.ogg', note='punch11 (right hook)')
    put('hookl', [L(P[5], 1.0)], f'{M}/hookl.ogg', note='punch5 (left hook)')
    kick = [(KICKT, 1.0, ms(9)), (KTHUDT, 0.55, onset(KTHUDT))]
    put('uppercut', kick, f'{M}/uppercut.ogg', note='the kick: punch7 -20%% (cut %.1f ms, thump at 9 ms) + thud2 -15%% x0.55' % (cut / SR * 1000))
    put('whip', [L(P[11], 1.0), L(CLANK, 0.30)], f'{M}/whip.ogg', note='punch11 + DSRIFLC2 first 55 ms x0.3')
    put('buttshove', [L(BUTT, 1.0), L(THUD, 0.40)], f'{M}/buttshove.ogg', note='punch3 (14 ms cut, -15%) + thud2 x0.4')
    put('swing', [(WHOOSH, 0.8, 0)], f'{M}/swing.ogg', note='punch10 first 108 ms x0.8 (played on the swing, not the hit)')
    put('kick', kick, f'{G}/kick.ogg', note='as uppercut')
    put('whoosh', [(WHOOSH, 0.8, 0)], f'{G}/whoosh.ogg', note='as swing')
    put('siren', [(fade(SIREN[:ms(4200)], 0, 50), 1.0, 0)], f'{V}/RVQSIREN.wav', wav=True, gain=1.0,
        note='the siren as it is, 0-4.2 s (two whoops), 50 ms fade at the stop')

    # the kick's thump, measured on what was written
    print('kick: punch7 thump %.1f ms into the original, %.1f ms into the -20%% copy, cut there - 9 ms -> %.1f ms into the file; thud lead cut %.1f ms'
          % (thump(P[7]) / SR * 1000, th / SR * 1000, (th - cut) / SR * 1000 + mix(kick)[1] / SR * 1000 - 9, tcut / SR * 1000))
    for name, path, ln, lead, pk, note in rec:
        print(f'{name:10} {path:48} {ln:6.0f} ms  hit at {lead:5.1f} ms  peak {pk:.3f}  {note}')


main()
