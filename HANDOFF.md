# ==== service (branch agent-svc): service.zs, 2026-10-27 ====

## RSQGR_Service -- what the hook did, for any mod (found by name, nothing links)
`ServiceIterator.Find("RSQGR_Service")`, then `GetInt(request, "", intArg, 0, objectArg)`; every unknown or
unanswerable request is -1 (a GetObject one null). Full comment block at the top of `zscript/rsqgr/service.zs`.

| request | objectArg | intArg | answer |
|---|---|---|---|
| `hook.phase` | pawn | hand | -1 none, 0 fly, 1 latch (wall or heavy anchor), 2 bite, 3 JP hold, 4 retract |
| `swinging` / `reeling` / `climbing` | pawn | | 1 / 0 (swinging = latched and off the ground) |
| `airborne` | pawn | | 1 in the air on a flight the rope took part in (floor to floor) |
| `released` | pawn | | tics since a rope let go of him in the air (tap or slip), -1 (10 s) |
| `landed` | pawn | | tics since he came down from a roped flight, -1 (10 s) |
| `flight.dist` / `flight.drop` | pawn | | 2D units floor to floor / depth of the lowest floor under it, -1 |
| `gaps` | pawn | | gap crossings counted on this map |
| `hooked` | monster | | tics since it was last on a line (0 on it; biting or as a heavy anchor), -1 (10 s) |
| `hooked.by` | monster | | player number, -1 |
| `hooked.heavy` | monster | | 1 anchor (too heavy to come), 0 came |
| `bites` | monster | | hooks in a chain (each within 5 s of the last release) |
| `volleys` | monster | | rehooks in that chain after it was sent flying AWAY (own vel away from the hooker >= 6 u/tic world time) |
| `yanked` | monster | | 1 on the yank path, 2 flying on its own after, 0 neither, -1 never hooked |
| `landing` | monster | | tics since its own throw hurt it (landing, wall or thing strike), -1 |
| `struck` / `struck.by` / `pin` | monster | | tics since a thrown body hit it / thrower's player number / 1st, 2nd... thing that body hit |
| `whipped` | monster | | tics since the whip crack hit it |
| GetObject `hook.victim` | pawn | hand | the monster on that line |
| GetObject `hooked.by` / `struck.ball` | monster | | the hooker's pawn / the thrown body |

Every blow is noted BEFORE it lands (Slam / Struck / Whipped are called before DamageMobj), so a scorer
hearing the death in WorldThingDied already reads 0. Pushes one award to RSQ_Score by name:
`RS_ScoreService GetInt("award", "Indiana Jones", points, 0, pawn)` for a gap crossed on the rope (left a
floor, passed over one >= 64 below both ends, landed >= 192 units 2D away in another sector; once per
sector pair per player per map; 150 + (dist-192)/2, max 500). `rsqgr_score` (menu "Score Stunts") turns the
push off.

Core edits (one line each): core.zs Fly (Bitten after the bite/anchor), monster.zs Impact (Struck, Slam)
and Land (Slam), whip.zs Crack (Whipped). MAPINFO: RSQGR_Events registered last.

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

# ==== monster side (branch agent-monster): monster.zs, whip.zs, looks.zs, 2026-10-27 ====

## Done (measured, rig C, QZD 17.3; evidence logs and frames in test/evidence/, harness test/harness.zs, never shipped)
| what | measured |
|---|---|
| Slide (default) | core's stub kept line for line (`RSQGR_Monster.Slide`); a monster over `rsqgr_yank_mass` or wider than 64 / taller than 110 slides even in Yank mode (Demon 400 with the limit at 300: 10 u/tic slide). |
| Yank | DG's WorldHands path (e = t^1.6, arc 0.15 x dist capped by MeasureArc, 15 m/s, 6..70 tics) x weight (mass/100)^0.25 on time, / on arc. Vanilla imp 168 u: 12 tics, peak 24.9, lands 52 u in front of you, facing you. |
| Slow motion | identical arc at any world speed: imp full 12 tics / quarter 47 tics, same landing spot (308,512), landing speed 27.2 both, damage 4 both. BD Imp, BullDemon, Baron, Caco, Mancubus, Arachnotron, RifleZombie, Arch-vile, Lost Soul on the full order: same peak and landing spot full vs 0.25, 4.0x the tics (table in the report). Rope cut mid-throw at the same path clock: same cut velocity (-14.12, 0, 4.02), same peak 61.5, same landing x 22.3, full vs 0.25. |
| Tumble | Spin (angle, ends facing you), Flip (roll on sprites with ROLLSPRITE/ROLLCENTER; pitch via SetModelFlag on voxels, whole turns so it lands upright), Both. Frames: test/evidence/frames_spin.png, frames_flip.png; BD_VoxelPack barrel detected as voxel and flipped by pitch: frames_voxel_barrel.png. |
| Landing | only TryMove/SetZ, a thing refused in Z too (comes down on a head: pushed off, falls); TestMobjLocation at landing: fits 1 in every run. Damage (speed-8) x 0.8, max 40: imp arrival 4, wall strike at 26.6 u/t 14. Death mid-flight: corpse finishes the path, flags restored, no landing damage. |
| Whip | `rsqgr_whip 1`: core's fresh claw is taken back on the same netevent; crack at tic 4: imp at 120 u, 12 damage, Pain entered. Snag: tip on the alcove lintel 91 u above the hand -> core's own Latch(); reel and swing are core's (log w_snag.txt). |
| Looks | JP / Combat FX / Ballistics: every Sound name resolves (H_SND), Ballistics claw = btracer mesh (RSGB), wall hit = 4 tracer streaks. |
| Save/load | BullDemon mid-throw under slow motion, full order: saved, loaded twice (age 28 -> 26 twice), landed at the same spot as without the save; map change mid-throw and back: no errors. Script errors: only BD_VoxelPack's 4 voxeldef lines. |
| Cost | full order, a Baron thrown: 0.036 ms mean, 0.075 max per tic (incl. logging). |

## Not done
- Carry/hold (monster dangling on the rope): core's 52-tic no-progress guard would drop it; would need a seam change.
- Whip as a flick gesture: it cracks on the bind press along the hand.
- Disarm: a Doom monster's attack is a state, not an item; the whip's forced Pain breaks off the attack, nothing more.

## Open / needs the headset
- Yank speed/arc feel (DG's numbers were tuned for objects to the hand, here monsters to your feet); 0.27 air after a cut makes a monster sail over you.
- Whip: whether a button-cracked lash along the controller reads as a whip at all.
- Combat FX set: the uploaded well has no impact sounds or art; hits stay JP's.

## Cheello's Voxel Doom II (not available here) -- check when the pk3 arrives
- `RSQGR_Voxels` must list its monster sprites (it reads VOXELDEF + voxels/ namespace); the launch log says voxel=1/0.
- Pivots: Flip assumes the KVX pivot at the feet (BD_VoxelPack's, measured). If Cheello's pivots are centred, the WorldOffset fix will move the voxel off its path by half its height while flipping: watch a flipped imp.
- Does it replace monster classes or only add VOXELDEF? Class-agnostic code either way; masses/radii come from whatever is loaded.
- If it uses MODELDEF models instead of KVX: models are not detected (no API); Flip then rolls the sprite flags only and the model will not turn. Spin works regardless.

## For core
- Reset All: KEYCONF's monster block redefines `rsqgr_reset` = core's list + this side's; if core's list changes, regenerate both.
- Whip takes back core's claw from its own NetworkProcess (registered after RSQGR_Input). A one-line seam in `RSQGR_Core.Press` (`if (RSQGR_Whip.Takes(...)) return;`) would be cleaner.

## RSQ_SlowMo findings (for its owner; not edited here)
See the report: (1) Consider() double-adds a thing spawned before the clock's WorldTick (summon, NetworkProcess) on a Gather tic -> tics x16 per tic, int overflow, monster frozen at tics 1; (2) Impulses() exempts a vertical push from the floor.

# ==== Gun Bonsai hook upgrades (branch agent-gbhook): perks.zs, 2026-10-27 ====

The Gun Bonsai VR / Offhand patch (rs_gunbonsai-offhand-vr, branch agent-gbhook, rsq/zscript/up_hook.zs) offers
nine PLAYER perks while this pk3 is loaded; `zscript/rsqgr/perks.zs` (RSQGR_Perks) reads their levels by name
(RSQ_MeleeUpgradeService "plevel", once a second) and does the effects. Without the patch every level is 0 and
the hook is unchanged (rig: grapple alone, yank as before, no errors). Calls added: one line each in core
(Fire range/speed, Fly mass + OnBite, LetGo, reel x3, drag), monster (slide speed + arrival + Bowl, Throwable
limits, path Bowl, Land arrival off the rope, Free() for Double Hook) and whip; every hook blow goes through
RSQGR_Perks.Hurt (a bracket RSQGR_Service answers as "hook.dealing", so Gun Bonsai pays it to the player pool).
RSQGR_Service (agent-svc, merged) also forwards "xp.bites/yanks/swing/kills/killhp/slams" to perks.zs.

## Done (measured, rig F, QZD 17.3; logs test/evidence/gb_*.txt)
| upgrade | measured |
|---|---|
| Long Line (cap 4) | claw turns back at 1024 (lv0); lv4 range 1843: latched the far wall 1717 away (gb_r0/r4) |
| Fast Reel (cap 4) | rope in 12.0 -> 19.2 u/tic (lv4); claw to the ceiling 21 -> 14 tics (gb_e0/e4); slide x1.15/lv |
| Heavy Haul (cap 3) | Cyberdemon bitten: 0 -> 40 pain tics (lv3), second bite inside 3 s not re-staggered (gb_b0/b3). Gold champion (Champions, woken by LegenDoom's transform token) mass 1200: lv0 an anchor, lv1 (limit 1500) it slides / is thrown (T 32 tics, arc 20) (gb_hc0/hc1/hg) |
| Get Over Here (cap 3) | imp slid in: 0 -> 65 pain tics on arrival (lv3); yanked: once per arrival (gb_s0/s3/y3) |
| Bowling (cap 3) | slide lv0: imp stuck behind a Demon, claw dropped after 52 tics of no progress; lv3: Demon 25 dmg, 47 pain tics, shoved 30 u aside, imp arrives (gb_bd0/bd3); zombieman pin killed (gb_bowl3); yank 28 dmg at 17.2 u/tic (gb_bowly3) |
| Barbed Claw (cap 4) | Baron: bite 20, tear 30 at lv4 (gb_ba4) |
| Slingshot (cap 3) | release 9.76 -> 12.69 u/tic (lv3); fell 331 -> 444 units from the release point (gb_sl0/sl3) |
| Steady Line (cap 3) | GRTEST pit from rest: 15.4 s to still (lv0), 9.5 s (lv1), 7.5 s (lv3) (gb_st*) |
| Double Hook (cap 3, player lv 5+) | two imps 177 apart: slammed in 4 tics, 65 each at lv3 (both died), 2 kills + slam paid (gb_dh3); lv0 both slide as usual |

XP ledger (paid by the patch to the player pool): bite 15, yank +15, 1 per 32 units swung airborne (1280 a latch),
half the spawn health of a kill the hook was in on (3 s), 40 a slam; hook damage pays the pool as damage and no
gun (gb_x1, gb_ba4: Pistol xp 0, pool +100 for 50 Baron damage). Save mid-throw/slide, loaded twice: same
outcome each time; changemap: perks and pool kept, the ledger restarts at 0 on both sides (gb_f1/f2/v1).
Full order incl. Champions (dormant boosted legendary) + LegenDoom Lite: no script errors from these pk3s.

## Not done / open
- Bronze champion (mass 2^31-1) and Titan (+BOSS) not forced on the rig (champion_debug_forced kept giving Gold);
  by the code they are anchors at any level and Heavy Haul staggers them.
- Cost of perks.zs not measured (2 hooks x players + 16 flight slots + 8 slams per tic, no iterators unless Bowling
  is learned).
- Headset: Bowling shove and Double Hook slam feel; whether Steady Line x(1+3lv) is too strong for swingers.
