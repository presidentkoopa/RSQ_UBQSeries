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

# R3 (2026-11-11, after the owner's "get on the still open items" at 16:14)

Rig only, not headset-confirmed. Order: doom2 > LegenDoom_3.0 > brutal22test6 > BD_VoxelPack > **BD22 VR 2.0.4i** > LOB >
Champions > GunBonsai > every RSQ pk3 (Melee ee0f71c8 and SlowMo 54912e16 rebuilt; Accessibility and GunCards rebuilt from
5a08eeca before R3G) > r10 > r2 probe. RES 480. Launches R3A-R3G: logs `evidence/R2_R3?_run.log`, scripts `R2_R3?_script.txt`.
Every launch: only the 4 BD_VoxelPack voxeldef errors. (R3A's first try ran the script through `exec` and the commands
interleaved; it was thrown away and run again.)

| # | Check | Result | Evidence |
|---|---|---|---|
| 2 | Shotgun hand pump, gloves 0 | **shown**: fire, the off trigger grabs the pump, `pump at the back` (Pump1), `pump forward: stroke done` (Pump2), `ready` | R2_R3A_run.log `R3_PUMP_G0` |
| 2 | Shotgun hand pump, gloves 1 (Melee's new start: inventory only) | **shown**: the level starts with Rifle main and RSQ_Hands off; Shot_Gun keeps RSQ_Hands; the same stroke | `R3_G1`, `R3_PUMP_G1` |
| 2 | The owner's lead: gloves from the Wheel, then back to a gun | Stand-in for the Wheel's off-hand pick (`r2_offglove`, as Melee's EquipTick does it): with the shotgun held the off hand takes RSQ_GloveOff and keeps it (t237, as asked); `use RSQ_Glove` (fists, t287); `use Shot_Gun`: **RSQ_Hands back in the off hand at t346**, the pump stroke works again (t375-396). This is BD22 VR **2.0.4i**'s fix (`RSQ_Hands.Upkeep`: when the main hand SWITCHES to a gun of the hand table and the off hand holds RSQ_GloveOff, the hands return). Before the fix nothing took the glove back (Upkeep only fills an empty off hand). The before case was not run | `R3_WHEEL_LEAD`, `R3_WHEEL_BACK_TO_GUN`, `R3_PUMP_G1_AFTER_WHEEL`; frame `R2_R3A_shotgun_hands_after_wheel_f00258.jpg` (looked at: support hand on the shotgun's fore-end), sheet `R2_R3A_pump_rifle_sheet.jpg` |
| 2 | Rifle grenade (M203) load | **Not shown.** Shown: secondary fire's dry click, the latch, `took the tube`, `open` (11 cm), and `took a round` in three runs (gloves 0 at any spot with `rsr_rig_pouch 0`; gloves 0 and 1 at Tactical Rig's ammo pouch with the default `rsr_rig_pouch 1`). Then the scripted round never entered the breech (`let the round go`). The Depot's m203.py round poses (pitch 120, yaw 180) and my recomputed ones (pitch -60) both failed, so the rig's poses are what is wrong; the code was not the test. Note for the owner: with Tactical Rig loaded, the 40 mm round is taken ONLY at the rig's ammo pouch (BD22 VR 2.0.3u, `RSR.RigPouch`) | R2_R3A_run.log, R2_R3C_run.log, R2_R3D_run.log `rsm t...` |
| 1 | DOWN shots "from the right" | **Cause found and fixed (2.0.4i), shown by log.** Standing vs DOWN, same gun and aim (R3C): the hand, the muzzle (`Where`), the round's spawn, the first tracer and SlowMo's trail start all go down with the gun (DOWN: muzzle up 3.1 instead of 29.5), with the same left/right (-6.4) and the same heading. One thing does not move: **BD22's muzzle glow PlayerMuzzle1** (a bright sprite with a dynamic light, `A_SpawnItemEx("PlayerMuzzle1",30,5,30)`) stays at (forward 30, right 5, **up 30**) from the pawn: standing chest height, ahead and to the right, about 0.8 m above a gun held while DOWN (and fixed to the body whichever way the gun points). Fix: `RSQ_Muzzle.WorldThingSpawned` puts PlayerMuzzle* on the drawn muzzle (the hand when the wall guard says no). R3E: standing, glow at (30, -6.4, 22.8) = Where; DOWN, glow at (12.0, -8.5, 10.3) = Where (the hand: the muzzle was under the floor with this pose). Frames `R2_R3E_stand_glow_f00041.jpg` and `R2_R3E_down_glow_f00057.jpg` were looked at: at 480 the DOWN frame is red, and the glow cannot be picked out in either frame, so the frames do not show the fix. The headset must judge whether this was what the owner saw | R2_R3C_run.log, R2_R3E_run.log `R2 SPAWN PlayerMuzzle1` |
| 3 | Watch-check rods in the R2A frames (the old build) | Looked at `R2_watch_before_during.jpg`: before the check the red main beam and green off beam; during it no beam and no rod of any colour (the watch card shows). No green or grey rod in these frames | R2A frames f00168, f00173 |
| 3/B | 5a08eeca "forearm across the body" | **shown (log).** `rsqg_inspect_twist 0` stands in for the cant (roll does not reach scripts). (1) One-handed rifle aimed forward: HandYawOff 0, **no watch check**. (2) The same with the off hand on the fore-end: **none**. (3) Main hand across (yaw 70): HandYawOff 70, inspect 0->1->2, both lasers off; off hand across: HandYawOff 70, inspect 0->1->2. The +90 convention reads 0 aimed forward and 70 across on this build. The "other way" (yaw -70) gave no new line because the state stayed held | R2_R3G_run.log |
| A | BD22 Revolver casings | **Cause found and fixed (2.0.4i), shown by log.** `rsr_break.zs`: a speedloader gun's open spawned `max(1, live rounds)` casings, so an emptied cylinder threw one. Now one per empty (capacity - live), all on the open tic: `rsb t250 speedloader gun 3 open: 4 empties out (live 2)`, 4 x SSGCaseSpawner at t250. BrutalRevolver (10/11) throws its own rounds per spent chamber in one loop (code read, not run). The per-round feed (index 7) was not run | R2_R3F_run.log |
| 4 | SlowMo green bar: revive and cigarette | **shown.** Revive: `trigger down.up t215: countdown bar: slow motion`, 3000 ms. Cigarette: `trigger smoke t641/t172: countdown bar: slow motion`. Frames: a small green bar under Score's line in both | R2_R3C/R3E_run.log; `R2_R3E_green_bar_cig_revive.jpg` (looked at) |
| 4 | Stacking: cigarette during an automatic slow | **shown**: auto 5000 ms, pulse until t314; smoke at t173 `added on`, pulse until **t489** (= 314 + 175); the bar refilled to 9.3 s | R2_R3C_run.log `R3_STACK_AUTO_THEN_CIG` |
| 4 | Stacking: automatic slow during a smoke | **shown** (`rsqsm_auto_cooldown 0`; in R3C the 25 s auto cooldown refused it): smoke until t347; auto at t202 `added on`, pulse until **t452** (= 347 + 105); the smoke's own end moved to t452 | R2_R3E_run.log |
| 5 | Score: Purple, Yellow, Gray, Abyss, White rows | **shown**: Purple Tier, Abyss Tier, Gray Tier (R3C, alone), White pays "White Boss"; Yellow Tier paid, but in the same 2 tics as a chain of other kills (the Yellow kill set off others) | R2_R3B_run.log, R2_R3C_run.log `R2 ROWS` |

BD22 VR 2.0.4i (rs_brutal22weaponsq, `pk3/03_BD22_VR-Reloaded_2.0.4i.pk3`, not committed): the off glove returns the
hands on a gun switch (hands.zs), the muzzle glow on the muzzle (muzzle.zs), and the revolver's empties (rsr_break.zs).
The shared run.sh points at 2.0.4h; R3 used `evidence/R2_r2run.sh` (2.0.4i).
