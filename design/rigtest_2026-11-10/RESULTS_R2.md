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
| (b) Shots "from far to my right" while DOWN | **Not settled.** Standing shots did not fire at RES 1080 (+attack and -attack fell in one rendered frame), so there is no standing comparison. DOWN, rifle, True Bullets on (t249): hand (f 11.9, l -8.5, u 14.3), muzzle Where (f 34.8, l -6.4, u 7.0), RSQ_PlayerRound spawn (f 34.9, l -6.4, u 3.1), BD22's **PlayerMuzzle1 at (f 30, l -5, u 30)**: about 23 units ABOVE the hand while DOWN (a pawn-based offset, not the hand); DecorativeTracer from (f 51, l -5.2, u -3.7) heading about 23 deg DOWN and slightly LEFT. Nothing starts far to the right in this log. Suspects for the owner's view: the muzzle flash sprite left at standing height and the tracer's steep start. Needs the standing run at low RES | R2_R2A_run.log `R2_DS_DOWN` |

## 3. Hands on the guns (LegenDoom / Start With Melee Hands), run first on the coordinator's priority change

Order used: doom2 > **LegenDoom_3.0** > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4h > LOB > Champions > GunBonsai >
RSQ pk3s (the owner's launcher order, LegenDoom at 0.99). Not on the rig: Brutal_Difficulties was not loaded; No More
Hitscans, Universal Entropy, Spawn Adjuster, Shotgun Spawner and RegenShield are not on the rig; the XMVE packs and the
environmental packs were not loaded. Probe `R2 HANDS` (ready / off / pending weapons, RSQ_Hands.Shown, HandTable.Index,
every psprite layer) and `R2 GLOVEINV`.

| Case | Result | Evidence |
|---|---|---|
| (a) `rsqml_gloves 1` from level start, NO LegenDoom | **Reproduced.** t1 Rifle main, RSQ_Hands off; t3 RSQ_Glove given and in the MAIN hand; t5 **RSQ_GloveOff in the OFF hand** (RSQ_Hands gone from the off hand); still so at t70 and after a `map` | R2_R2G3_run.log |
| (a) `rsqml_gloves 1` from level start, WITH LegenDoom after doom2 | Gloves given (inventory 1/1 by t35) but NOT equipped: Rifle main, rsq_hands off throughout; Shot_Gun, then Rifle: off hand rsq_hands, RSQ_GunSide hand layers 2100/2101/2112 on. Frame: hands on the shotgun's grip and fore-end, and on the rifle | R2_R2G4_run.log; R2_G4_LD_gloves1_shotgun_hands_f00038.jpg, R2_G4_LD_hands_shotgun_rifle_sheet.jpg (looked at) |
| (b) `rsqml_gloves 0`, with LegenDoom | Rifle / Shot_Gun main, rsq_hands off, hand layers on | R2_R2G4_run.log (R2G4_GLOVES0), R2_R2G_run.log |
| Pump and rifle grenade load | **Not shown** (needs a scripted off-hand pump / load motion; not run in this batch). Only the precondition is shown: RSQ_Hands is the off-hand weapon with LegenDoom loaded | |

So on the rig LegenDoom does not take the hands; Start With Melee Hands does, at level start, without LegenDoom (with
LegenDoom loaded the gloves stayed in the inventory and were not raised; why is not traced). Cause in code (coordinator,
confirmed by R2G3): Melee/zscript/rsqml/slappers.zs WorldTick `else if (gloves && !had) StartEquip(pn)` -> EquipTick puts
RSQ_Glove in the main hand and RSQ_GloveOff in the off hand; BD22 VR's RSQ_Hands.Upkeep only refills an EMPTY off hand,
so it never comes back while the off glove sits there. **Not fixed** (coordinator: the owner decides Melee's start
behaviour first).

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
