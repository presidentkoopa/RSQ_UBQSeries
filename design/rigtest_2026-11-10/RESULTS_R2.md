# RESULTS_R2 (rig batch R2, 2026-11-11, after the owner lifted the no-rig order at 15:35)

Everything marked shown is **rig only, not headset-confirmed**. Harness: `evidence/R2_r2run.sh` (run.sh with BD22 VR
**2.0.4h** and an optional LegenDoom slot), probe `evidence/R2_probe/` (test only: readouts and setters by name) plus
the shared r10.pk3. Launch R2A: doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4h > LOB > Champions > GunBonsai >
every RSQ pk3 in pk3/ > r10 > r2. RES 1080, every rendered frame dumped. Log: `evidence/R2_R2A_run.log`, script
`evidence/R2_R2A_script.txt`. Errors: the 4 BD_VoxelPack voxeldef lines only; one VM abort was the PROBE's own
(`R2_Probe.Hands`, a format bug, fixed), at the last section.

## 1. The ladder renumbered by strength: SHOWN

| Check | What the log / frame shows | Evidence |
|---|---|---|
| Monsters spawn with the right tier numbers | The zombie family spawned tier 1..13 by `RS_TierLadder.ClassFor`: every one reads its own number back through RSQMN_RosterService (13/13 `OK`). All map monsters (19, then 32 with the line): 0 whose class name is not their tier's colour | R2_R2A_run.log `R2 LINE`, `R2 LINETIER`, `R2 MONSUM` |
| Each gem shows its own colour | `rs_ch_colorblind 1`: every gem actor's frame = its monster's tier, all 13 colours (A Common .. M White) `MATCH`; 1 `MISMATCH` line is the probe's nearest-monster guess (a White gem from the White zombie, nearest to the Black one 40 units away) | `R2 GEM` lines; frame `R2_gems_line_f00025.jpg` / `R2_gems_line_crop.jpg` (looked at: purple gem over the purple zombie, blue over blue, cyan, brown, yellow, grey over grey) |
| Tier-ups climb in strength (Red up to Abyss) | Miniboss Green(2)+8 = **Red(10)** RS_RedImp; life 1 lost: tier +1 -> **RS_AbyssImp2 tier 11 Abyss** (not FireBlu); life 2: -> RS_BlackImp1 12 Black; a missed window (untouched, +3): miniboss -> **RS_WhiteImp2 13**, thralls Cyan(5) -> **RS_FireBluZombie2 (8)**, map Commons (1) -> Purple (4) | `R2_MB_RED*`, `R2 MBSCAN`, `RSQMB life lost`, `RSQMB window MISSED`, `tier swap followed` |
| An EX miniboss goes up a colour when it loses a life | `rs_ch_exboss 3`: lands RS_BlackImpEX tier 12 (colour 505058, no longer the pink fallback); life lost -> `tier +1 asked` -> RS_WhiteImp2 tier 13 | `R2_MB_EX*` |
| Score's tier rows read the new numbers | Each kill pays its own colour's row: Green, Blue, Cyan, Brown, FireBlu, Red; a Black kill pays "Black Boss". Purple, Yellow, Gray, Abyss, White not isolated (two kills fell in one tic at 1080, so their before/after was merged) | `R2 KILL` / `R2 ROWS` |

## 2. DOWN

| Check | Result | Evidence |
|---|---|---|
| (a) Tactical Rig's holsters come down with the hands while DOWN | **SHOWN.** Standing: main hand up 36.8, hips 24.4, shoulders 41.2, RoomFloor 0. DOWN (view 17.6 of 44): RoomFloor -26.4, hips -2.0, shoulders 14.8; main hand 14.3 at t249, 10.4 at t285 (the pose catches up a frame later): hand and holsters both 26.4 lower, the same gaps as standing | `R2 HOLSTER` tags 1, 3, 5 |
| (b) Shots "from far to my right" while DOWN | see below (in progress) | |

## 4. Watch-check rods: laser layers SHOWN going 1 -> 0 -> 1

Stand-in for the wrist roll: `rsqg_inspect_twist 0` (the real Accessibility watch check, with the twist test met by any
roll). Main hand BrutalPistol across the chest in front of the eyes, off hand its dual copy, Laser PC VR look
(`rsqls_beam_type 1`). Log: t125 all four laser layers (2140, 2141, 1000140, 1000141) = 1; t178 the check enters
(inspect 1/1) -> all four 0; t183 held (2) -> 0; t248 lowered -> all four 1. Frames: not yet looked at.

## 5. BD22 VR 2.0.4h: the buzz is not a shot

Fix (rs_brutal22weaponsq): `RSQ_Ballistics.IsBuzzTrace` (LAF_NOINTERACT and under 1 unit), skipped in `flash.zs` and
`recoil.zs` WorldHitscanPreFired. Built as `pk3/03_BD22_VR-Reloaded_2.0.4h.pk3` (not committed).
Log, `rsq_ballistics 1`, Rumble Backup on, Quake Haptics 0: buzzes at t202 (probe), t211/t236/t260/t283/t305 (SlowMo's
DOWN pulses, both hands), t183 (the watch-check tick, both hands): `R2 PREFIRED dist 0.1 ... RSQA_PulsePuff` with **no
`R2 FLASH` and no `R2 KICK`**; the rifle's real shots at t249/253/257 each give `R2 FLASH`. **SHOWN (log).** Recoil
readout note: the probe saw no `R2 KICK` for the real shots either, so the kick half is not proved by this log.
