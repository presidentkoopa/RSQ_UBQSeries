#!/usr/bin/env python3
# TEST ONLY. Steady Hands (rsqa_steady): the 1-euro filter (Casiez, Roussel, Vogel, CHI 2012) at 35 tics a second,
# run offline on a still hand with tremor and a fast swing, to pick the numbers RSQA_Steady uses.
#   python3 tools/steady_sim.py            -> a table: tremor left (RMS) and lag on the swing, per setting
# Tremor: 6 Hz (pathological rest/postural tremor is 4-6 Hz, physiological 8-12 Hz) plus white noise.
import math, random, sys

TE = 1 / 35


def alpha(fc):
    return 1 / (1 + 1 / (2 * math.pi * fc * TE))


def euro(sig, mc, beta, dc):
    xh = xp = None
    dh = 0.0
    out = []
    for s in sig:
        if xh is None:
            xh = xp = s
            out.append(s)
            continue
        d = (s - xp) / TE
        xp = s
        dh += alpha(dc) * (d - dh)
        xh += alpha(mc + beta * abs(dh)) * (s - xh)
        out.append(xh)
    return out


def case(amp, noise, swing, swing_tics, mc, beta, dc, seed=1, n=140):
    random.seed(seed)
    sig, clean = [], []
    for t in range(n):
        base = min(1, max(0, (t - 70) / swing_tics)) * swing
        clean.append(base)
        sig.append(base + amp * math.sin(2 * math.pi * 6 * t * TE + 0.3) + random.gauss(0, noise))
    o = euro(sig, mc, beta, dc)
    rr = math.sqrt(sum((sig[t] - clean[t]) ** 2 for t in range(20, 70)) / 50)
    ro = math.sqrt(sum((o[t] - clean[t]) ** 2 for t in range(20, 70)) / 50)
    v = swing / swing_tics
    lag = max((clean[t] - o[t]) / v for t in range(71, 70 + swing_tics + 1))
    end = 70 + swing_tics
    settle = next((t - end for t in range(end, n) if abs(o[t] - swing) < 0.1 * swing), 99)
    return rr, ro, lag, settle


def main():
    print("POSITION (metres): tremor 3 mm at 6 Hz + 1.5 mm noise; swing 0.6 m in 5 tics (4.2 m/s)")
    for mc, beta, dc in [(1, 5, 3), (1, 10, 3), (1, 10, 5), (1, 20, 5), (0.7, 20, 5), (1.5, 20, 5)]:
        rr, ro, lag, st = case(0.003, 0.0015, 0.6, 5, mc, beta, dc)
        print(f"  mincut {mc:4} beta {beta:3} dcut {dc}: tremor {rr*1000:.2f} -> {ro*1000:.2f} mm ({ro/rr:.2f})"
              f"  worst lag on the swing {lag:.2f} tics, within 10% of the end {st} tics after")
    print("DIRECTION (degrees): tremor 0.8 deg at 6 Hz + 0.3 deg noise; flick 60 deg in 4 tics (525 deg/s)")
    for mc, beta, dc in [(1, 0.02, 5), (1, 0.05, 5), (1, 0.1, 5), (0.7, 0.1, 5), (1, 0.2, 5)]:
        rr, ro, lag, st = case(0.8, 0.3, 60, 4, mc, beta, dc)
        print(f"  mincut {mc:4} beta {beta:4} dcut {dc}: tremor {rr:.2f} -> {ro:.2f} deg ({ro/rr:.2f})"
              f"  worst lag on the flick {lag:.2f} tics, within 10% of the end {st} tics after")


if __name__ == "__main__":
    main()
