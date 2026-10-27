# RSQ_Grapple -- road to Hook 1.0

Hook 1.0 = the core as built (HANDOFF.md, measured 10-27) + the items below. Status is measured on
rig H (QZD 17.3) unless it says headset. The monster side (monster.zs, whip.zs, looks.zs) is
agent-monster's and tracked there.

| # | item | status |
|---|---|---|
| 0 | Core: fire from either hand, rope swing/reel/release, JP yank, latch walls/ceilings/3D floors, monster slide seam, slow motion, save/load, menu | done, measured (HANDOFF.md) |
| 1 | Pendulum comes to rest | done, measured -- see below |
| 2 | Hand-over-hand rope climbing (BD22Q free hands, universal fallback, netplay by streamed pose, 1:1 with caps) | in progress |
| 3 | Same bar: vanilla + full order, save/load twice mid-climb and mid-swing, map change, death, frames | pending |
| - | Headset: feel of reel/top speed/pump/tap window, damping, climbing comfort | needs the owner |

## 1. Pendulum comes to rest (measured)
Tangential-only losses: air drag `rsqgr_drag` 0.002 of the speed per tic plus a constant friction
`rsqgr_rope_friction` 0.025 u/tic per tic; below that speed within 1.5 deg of hanging straight, the swing
stops. GRTEST, L 643, stepped off the ledge:

| half swing | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| amplitude, deg (normal) | 31.7 | 26.3 | 21.4 | 16.9 | 12.8 | 9.0 | 5.6 | 2.4 |
| amplitude, deg (RSQ_SlowMo 0.25, full order) | 27.1 | 22.1 | 17.5 | 13.4 | 9.6 | 6.1 | 2.8 | 0.1 |

Half period 80-82 tics both ways (the player runs in real time under RSQ_SlowMo, by design). At rest
21.9 s after stepping off (normal), 19.5 s (slow-mo; it started 4.6 deg smaller), hanging 6.3 / 1.6
units from straight under the anchor. Stick pumped in time with the swing: amplitude held at 28-30 deg
for 9 half swings (to the end of the run).
