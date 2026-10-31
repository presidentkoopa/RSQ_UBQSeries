#!/usr/bin/env python3
# TEST ONLY. Reads a QoL rig log (AT_Q lines from the probe, rsqat_qol 1) and prints what Steady Hands and Seated
# Play did:  qol_analyse.py <log>
import math, re, sys

UPM, PS = 34.0, 1.2


def load(path):
    rows, marks = {}, {}
    for ln in open(path, errors='replace'):
        if ln.startswith('AT_Q '):
            t = ln.split()
            tic = int(t[1])
            raw = [float(v) for v in t[3:8]]
            st = [float(v) for v in t[9:14]]
            kv = dict(x.split('=') for x in t[14:] if '=' in x)
            rows[tic] = (raw, st, kv)
        elif ln.startswith('AT_MARK '):
            t = ln.split()
            marks[int(t[2])] = int(t[1])
    return rows, marks


def metres(v):
    return (v[0] / UPM, v[1] / UPM, v[2] * PS / UPM)


def rms_about_mean(seq):
    n = len(seq)
    m = [sum(s[k] for s in seq) / n for k in range(len(seq[0]))]
    return math.sqrt(sum(sum((s[k] - m[k]) ** 2 for k in range(len(m))) for s in seq) / n)


def steady(rows, marks, on):
    a, sw, ho = marks[1 if on else 0], marks[11 if on else 10], marks[21 if on else 20]
    still = [rows[t] for t in range(a + 10, sw) if t in rows]
    pr = rms_about_mean([metres(r[0][:3]) for r in still]) * 1000
    ps = rms_about_mean([metres(r[1][:3]) for r in still]) * 1000
    ar = rms_about_mean([r[0][3:5] for r in still])
    as_ = rms_about_mean([r[1][3:5] for r in still])
    name = 'ON ' if on else 'OFF'
    print(f'Steady {name} still hand ({len(still)} tics): position tremor {pr:.2f} -> {ps:.2f} mm RMS ({ps/pr:.2f}),'
          f' direction {ar:.2f} -> {as_:.2f} deg RMS ({as_/ar:.2f})')
    # the swing: from the last still tic to the hold
    t0 = sw
    end_raw = rows[ho + 3][0]
    start_raw = rows[t0][0]
    total = math.dist(metres(end_raw[:3]), metres(start_raw[:3]))
    tot_a = abs(end_raw[3] - start_raw[3])
    line = []
    for t in range(t0, ho + 6):
        if t not in rows: continue
        raw, st, _ = rows[t]
        dp = math.dist(metres(raw[:3]), metres(st[:3])) * 100
        da = abs(((raw[3] - st[3]) + 180) % 360 - 180)
        line.append(f'{t - t0}:{dp:.1f}cm/{da:.1f}deg')
    print(f'  swing {total*100:.0f} cm and {tot_a:.0f} deg; smoothed minus raw per tic from the swing start: ' + ' '.join(line))
    # per-tic raw speed during the swing, to state lag in tics
    steps = []
    for t in range(t0 + 1, ho + 2):
        if t in rows and t - 1 in rows:
            steps.append(math.dist(metres(rows[t][0][:3]), metres(rows[t - 1][0][:3])) * 100)
    print('  raw step per tic (cm): ' + ' '.join(f'{s:.1f}' for s in steps))


def seated(rows, path):
    lab = {}
    for i, ln in enumerate(open(path, errors='replace')):
        pass
    last = None
    out = []
    for t in sorted(rows):
        kv = rows[t][2]
        key = (kv['seat'], kv['hmd'])
        if key != last:
            out.append(f"tic {t}: hmd {kv['hmd']} seated={kv['seat']} drop={kv['drop']} eye={kv['eye']} stand={kv['stand']}")
            last = key
    print('Seated Play changes:')
    for o in out: print('  ' + o)


def main():
    rows, marks = load(sys.argv[1])
    steady(rows, marks, True)
    steady(rows, marks, False)
    seated(rows, sys.argv[1])
    taps = sorted({rows[t][2]['taps'] for t in rows})
    print('taps answers seen:', taps)


if __name__ == '__main__':
    main()
