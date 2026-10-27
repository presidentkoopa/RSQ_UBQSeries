# RSQ_Grapple -- road to Hook 1.0

Hook 1.0 = the core as built (HANDOFF.md, measured 10-27) + the items below. Status is measured on
rig H (QZD 17.3) unless it says headset. The monster side (monster.zs, whip.zs, looks.zs) is
agent-monster's and tracked there.

| # | item | status |
|---|---|---|
| 0 | Core: fire from either hand, rope swing/reel/release, JP yank, latch walls/ceilings/3D floors, monster slide seam, slow motion, save/load, menu | done, measured (HANDOFF.md) |
| 1 | Pendulum comes to rest | done, measured -- see below |
| 1b | JP-look rope (owner: "the og mod does not have this issue"): tenda0 chain links like jp_grapple's LoreShot2 trail; cable model kept as an option | done, measured -- see below |
| 2 | Hand-over-hand rope climbing (BD22Q free hands, universal fallback, netplay by streamed pose, 1:1 with caps) | done, measured -- see below (netplay not run: no second machine) |
| 3 | Same bar: vanilla + full order, save/load twice mid-climb and mid-swing, map change, death, frames | done, measured (no script errors beyond BD_VoxelPack's voxeldef lines) |
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

## 1b. The rope looks like jp_grapple's (measured)
jp_grapple's rope is its FastProjectile's MissileType, LoreShot2 (engine zscript loremaster.zs: TEND A,
normal style, scale 1, 20 tics, no gravity); FastProjectile.Effect drops one per sub-step (radius 10,
speed 40 -> 8 sub-steps). His own pk3 run in the rig (probe counting LoreShot2): a link every 5.0 units,
nearest 15.0 units from the hand, 152 at most, each 5 x 5 units (tenda0's 40 px hires at the 5 px size).
The first sprite chain here drew 8-unit links from 3 units off the controller -- 1.6x his size and five
times closer to the eye: the fat white balls. Now `rsqgr_rope_style 0` Chain (default): same sprite,
size (0.125 of 40 px = 5 u), spacing 5.0, nearest 15.0 (measured: same probe, our links), normal style,
up to 160 links then they spread; along the live rope rather than a 20-tic flight trail. Side-by-side
frames (rig, same pose): indistinguishable in flight. `rsqgr_rope_style 1` Cable: the tube model.

## 2. Hand over hand (measured)
- Binds: Grab Rope (Main) / Grab Rope (Off) (`+rsqgr_grip_main` / `+rsqgr_grip_off`), and RSQ_DistanceGrab's own
  grab binds (`rsqdg_press/release`, where the grips live; `rsqgr_grab_dg`). Hold it with a free hand within
  16 units of the rope (`rsqgr_grab_reach`); a new press with the other hand takes the rope over.
- Free hands, read from BD22_VR-Reloaded r7's own code: main = BD22's fists weapon `Melee_Attacks`; off =
  `RSQ_Hands` with its free-hand layer (psprite 2200) in state `AmmoH` (its `freeFist`). By name, no link.
  Fallback without BD22Q: an empty slot or the engine's `Fist`. Full order: free(main,off) = 0,1 with BD22's
  pistol out -- the main hand's strokes were refused, the off hand climbed. Vanilla with the Fist: 1,1.
- Not built: a fist weapon handed out by the hook. QZD's off-hand slot is shared by the series' off-hand mods
  (saber, shield); an invisible fist weapon parked there would take it from them. The fallback is the rule
  above instead. Say if a visible fist is wanted.
- 1:1: the body's radial speed is the hand's step along the rope, capped 8 u/tic (`rsqgr_climb_cap`, the excess
  slips); holding with a still hand pins it (no coasting). Vertical rope, 0.6 m strokes (= 17.0 map units):
  -17.1, -17.1, -17.1, -17.1 alternating hands (vanilla), -17.1 x2 off hand (full order, BD22Q fists and with
  RSQ_DistanceGrab's grip bind), push up 0.6 m: +16.9. Body z with a 2-tic 0.6 m pull: 36.0 -> 44.0 -> 52.0,
  then still at 52.0.
- The hand pose is streamed every frame (`rsqgr_pose`) from the machine holding the controller, height taken
  against the frame's own eye: AttackPos.z is written from the interpolated eye, and viewz trails a moving pawn
  by a tic -- each fed the climb back into itself (16-unit loop with a still hand) until measured and removed.
- Save/load: a hold does not survive a load (reset on the first tic after it; the bind's release may never
  come) -- mid-climb saved, loaded twice, re-grabbed and climbed; mid-swing saved, loaded twice; death; map
  change. Vanilla and full order.
- Chain look: no link drawn within 15 units of the eye (a climbing hand holds the rope above the head); links
  face pitch too (+FORCEXYBILLBOARD) so they stay round looking up the rope.
- Cost (full order, two ropes out, 145 links): rope draw 0.110 ms mean / 0.353 max per rope (chain), 0.019 /
  0.045 (cable); core tick 0.051 / 0.147 (one 4.2 ms tick seen once in the cable run, not repeated).

## Needs the headset
- Damping feel (21.9 s to rest from 31.7 deg on a 19 m rope), pump.
- Climb comfort: 1:1 with one tic of delay (the pose of the last frame before the tic), the cap, the reach.
- Whether the chain near the hand reads right in VR (rig projection is not a headset).

## Art and sound: slated for replacement
The default claw, chain and sounds are jpalomo's (see CREDITS.txt). The owner (10-27): the hook is our
rebuild, so it should look and sound like our mod -- replace them from RS_CombatFX (and other cleared
sources). Status: open.
