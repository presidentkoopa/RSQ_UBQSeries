# HANDOFF -- RSQ_Grapple core (branch agent-core), 2026-10-27

Round 2 (Hook 1.0: pendulum comes to rest, JP-look chain rope, hand-over-hand climbing) is in ROADMAP.md, measured.
New settings: rsqgr_rope_style / chain_links / chain_scale, rsqgr_rope_friction (drag now 0.002), rsqgr_climb /
climb_free_only / grab_reach / climb_cap / grab_dg. New binds: Grab Rope (Main/Off). New file: zscript/rsqgr/climb.zs.
Test kit adds settle.py, strokes.py, perf.py, climbscript.py, clsave.py.

## Done (measured on rig H, QZD 17.3 9afc750; vanilla doom2 and the owner's full order)

| what | measured |
|---|---|
| Fire from either hand | `+rsqgr_main` / `+rsqgr_off` (KEYCONF aliases) -> local `event` -> pose packed into `netevent rsqgr_fire`. Direction = (cos p cos y, cos p sin y, sin p / 1.2) from AttackAngle+90 / AttackPitch: equal to the engine's AttackDir at 5 poses (e.g. room 15 deg up -> 12.587 both; 33.95 -> 29.3 both). AttackDir itself is never called (null after a load). |
| Pendulum | GRTEST pit, L 643.2 constant, half period 82 tics (theory 2 pi sqrt(L/g) = 159 full, +1.5% for 28 deg amplitude = 162; measured 164); turning heights -88.4 -> -91.7 over a full swing (drag 0.0005). |
| Indiana Jones | step off the west ledge, hold to reel at the bottom (L 643 -> 487), tap to let go at t87 with vel (20.2, -0.5, 6.5): flew 445 units, landed on the east ledge (x 1654) at vel.z -14.5; with ZDoom falling damage (dmflags 8) hp stayed 100. |
| Pump | stick back on the return swing raised the turning point from z -88 to -70.6. |
| Reel / zip | hold = 12 u/tic in; inward speed capped at 1.5x reel (was 29 u/tic to a Cyberdemon before the cap, 12 after). |
| Walls | velocity solved from the actual last-tic move: reeling into a wall no longer builds speed (14.7 -> 17.6 u/tic before, ~1.4 after). Player is only ever moved by velocity. |
| Ceiling follows | alcove ceiling lowered 64: claw z 199 -> 135 with it, player hanging below. |
| 3D floor | latched on the slab side (x 799, z 139; slab 128..160) and reeled to it. |
| Sky | claw stops at the sky (z 254 of 256) and returns; no latch. |
| Rope slips | rope through a 3D slab between hand and anchor -> let go after 3 failed checks (12 tics). |
| Yank (JP) | `rsqgr_geo_mode 1`: thrust (dist2D/12, dz/16) as parsed from hook.acs/function.acs, capped by rsqgr_max_speed 30: (0.46, 28.89, 8.07), flew 450 units. |
| Monster slide | imp, Baron (mass 1000) slide at 10 u/tic and stop at radius+radius+16; Cyberdemon (BOSS) is an anchor you swing from / reel to. Barrel 10.0 u/tic normal, 2.5 u/tic at RSQ_SlowMo 0.25 (exactly scaled), released with zero velocity. |
| Save/load | mid-swing save, load twice: same tic, same pos/vel both times; two hooks latched saved and loaded; bite saved and loaded twice in the full order; map change with hooks out; death -> drop next tic. No script errors from this pk3 (only BD_VoxelPack's voxeldef lines). |
| Cost | full order, two hooks: core WorldTick mean 0.041 ms max 0.098; rope draw mean 0.016 ms max 0.061 per rope (desktop CPU). |
| Frames | rope = tube model, thin cable from the hand; claw JP sprite; barrel pulled on a taut rope. |

## Not done
- Arm pull (rope anchored at the hand so pulling the arm lifts you): left out -- the hand pose is local
  (not MP-safe) and a hand-driven body is a nausea risk. Headset call.
- Rope wrap around corners: the rope slips (lets go) instead.

## Open / needs the headset
- Feel: reel speed 12, top speed 30, pump 0.25, the tap window (8 tics) on stick clicks.
- Claw sprite is JP's 15-unit claw at scale 1: large right at the hand at launch.
- A press in the first frame after a menu closes fires from the body (the engine collapses the pose to
  the body while a menu is open).
- Seen, not ours: under RSQ_SlowMo a BD imp's idle `tics` read 27 -> 36336 -> 148827888 (probe T_M).
- Not run: Cheello's Voxel Doom II, netplay.

## Seam (for agent-monster)
`zscript/rsqgr/monster.zs` and `zscript/rsqgr/looks.zs` are stubs; replace them whole. Core calls only
`RSQGR_Monster.OnHooked/Tick/OnRelease` (declared `static play`) and `RSQGR_Looks.Sound/Sprite/Spark`.
Names core asks Looks for: Sound fire loop swish hitwall hitflesh retract; Sprite open closed; Spark wall
flesh. Helpers: `RSQGR_Core.Scale()` (world speed under RSQ_SlowMo), `RSQGR_Core.HookOf(pmo, hand)`.
Core already guards: victim gone, > 1.5 x range, no closer for 52 tics, player dead, boss or
mass > rsqgr_mass_max (anchor instead; the seam is not called).

## Test kit (scratch, not shipped)
`tools/rigtest/`: `build_probe.sh` (probe handler + generated GRTEST map: ledges, 768-wide pit, ceiling 512, 3D slab, tagged alcove), `gr.sh <name> <secs> "<console script>" [1 = full load order]`, `swing.py <log>` (turning points). Probe events: grp_tp x y ang, grp_summon idx dist angofs, grp_dir, grp_ceil raise amount, grp_hurt; cvar grp_log 1/2.
