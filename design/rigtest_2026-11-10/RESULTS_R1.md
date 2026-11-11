# Rig batch R1 (2026-11-11, after the owner lifted the no-rig order at 15:35)

Load order: doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4g > LOB > Champions > Gun Bonsai 0.10.6 > the RSQ pk3s
(pk3/ rebuilt 15:34-15:36 from HEAD 2c002e4a). All results are **rig only, not headset-confirmed**.

## Launch 1: HUD11A (`/home/claude/scratch/rig1110/HUD11A`, + HUD11_probe.pk3), RES 480, EVERY 4

rc=0, 62 frames. Script errors: 4, all BD_VoxelPack's voxeldef.txt (as always); none from our packs.

| Check | Result | Evidence |
|---|---|---|
| Score's line centred under the gauges, no overlap | **shown.** Saved Across 85 migrated to 50 at t12 (cfgver 0 -> 1); line centre x 0.500; gauges.bottom 166 permille, line top 0.176 (1% gap), Dual HUD and single HUD alike. Frame: the line sits under the gauges' text, nothing overlaps (480 px eye: small but readable) | R1_HUD11A_log.txt (GBP BAND), R1_HUD11A_score_line_crop.jpg (top dual, bottom single) |
| No ShieldSaw bar or row | **shown.** The GBOVR options page dumped (34 rows): no ShieldSaw Gauge row. No shield band in the gauge frames | R1_HUD11A_log.txt (GBP OPT), R1_HUD11A_sheet.jpg |
| No HUD over an open menu | **shown** for Gun Bonsai VR's gauges, Score's line and Score's wrist digits (log: 2 of 2 visible -> 0 of 2 when the menu opens, back on close) and the Accessibility vignette (log: `vignette shown 1` -> 0 with the menu open -> 1 after). Frames 00092/00116/00144/00192/00232: no gauge, no Score line. Compare GB_2 (before): gauges and Score over the status screen. **Note:** the base game's full status bar (BD's STBAR) still shows under every menu, as it did before; that is the engine's/BD's 2D bar, not one of ours. BD's "TIP" line also shows (bd_tips 0 did not stop it) | R1_HUD11A_log.txt (GBP WRIST, RSSC WRIST), R1_HUD11A_sheet.jpg |
| ... with SlowMo on | **not shown.** `netevent rsm_toggle 2` was sent but nothing in the log proves slow motion was running (no rsm_state readout; the frames show no colour drain). The menu frame over it (00192) has no HUD of ours | R1_HUD11A_sheet.jpg (00180, 00192) |
| Whip picture on Gun Bonsai VR's status screen | **shown.** The coiled whip in the MAIN card | R1_HUD11A_sheet.jpg (00092, 00116) |
| Bare fist picture | **broken:** the OFFHAND card shows "?". The class is `rsq_hands` (lower case, see the log's `hand1=rsq_hands`), and `RSQUI_GunPic.Get` compares `cls == "RSQ_Hands"` with a case-sensitive `==` (GunBonsaiOffhandVR/rsq/ui/skin_a_menus.zs:88-92). Fix below | R1_HUD11A_sheet.jpg (00092, 00116) |
| Display Info opens on the main hand | **shown.** First press: `focus hand 0, menuHand 0` (Whip, main); second press: `focus hand 1` (Fist) | R1_HUD11A_log.txt (GBP STATUS) |

### Fix: the bare-fist picture (GunBonsaiOffhandVR/rsq/ui/skin_a_menus.zs, RSQUI_GunPic.Get)
The weapon names now compare with `~==` (case-blind). Rebuilt with `python3 tools/build_all.py GunBonsaiOffhandVR`.
**Shown** in launch 2: the OFFHAND card shows Brutal Doom's fist (FISTD0), main card the whip (R1_B_status_fist_picture.jpg).

## Launch 2: R1B (`/home/claude/scratch/rig1110/R1B`, + R1_probe.pk3 = the HUD11 probe plus `r1.zs`), RES 720, EVERY 3

rc=0, 39 frames (one dump per ~5 tics: frames are sparse). Script errors: the 4 BD_VoxelPack ones only.
The probe's `r1_geo` prints each tic-tagged line one step after its echo (netevent lag); the tag numbers in the log are right.

| Check | Result | Evidence |
|---|---|---|
| Fist picture (after the fix) | **shown** (above) | R1_B_status_fist_picture.jpg |
| SlowMo + menu | **not shown.** `netevent rsm_state` prints nothing in this build and no line says slow motion went on from `rsm_toggle 2` (the only SlowMo line in that part is none; the Wheel later logged `trigger wheel ... held ON at 25%`, so the clock works). The menu frame has no HUD of ours either way | R1_B_log.txt |
| Right-chest flare diamond gone while the flare holster is on | **shown (log + frame).** `flare.home 1`; FnF's `pocket.*` zone answers 1e9 (not published, so the rig draws no diamond); an off-hand grip there: `RSQFF grip: ... the pocket is off: the flares are in the Tactical Rig's flare holster`. Frames looking down at the chest: no diamond on the right chest, only the flare holster's magenta diamond at the off hip | R1_B_log.txt (R1 GEO, RSQFF grip), R1_B_chest_hip_diamonds_cig.jpg (middle) |
| Flashlight 0.21 m behind the flare holster | **position shown (log), grab not yet.** FnF's clip = the rig's torch spot exactly (0.000 m apart), **0.207 m** from the flare holster's centre (body frame f -0.27 vs -0.06, same l 0.30, u -0.84), 0.712 m from the cigarette pocket. The grip test missed: the off hand was 0.12 m from the clip (needs 0.08), my pose, not the code (`RSQFF torch grip: off hand 0.12 m from the clip (needs 0.08)`). Two earlier off-hand grip netevents left no line at all (see launch 3) | R1_B_log.txt |
| Cigarette pocket reachable by the main hand | **shown.** Main hand 0.058 m from the pocket (R 0.08), AtPocket 1; real main grip key (446): `T_CIG rsqtr_cigtake`, hands then `RSQTR_CigWeapon` / `RSQTR_ZippoWeapon`, packs 5 -> 4; grip again: `rsqtr_cigback`, back to BrutalPistol. Frame: the cigarette in the hand, the pocket's diamond green | R1_B_log.txt (tags 6-8), R1_B_chest_hip_diamonds_cig.jpg (right) |
| ... with nothing else winning it | **mostly shown, one note.** No holster, Distance Grab or FnF action fired. But the same grip key flipped BrutalPistol's fire mode (`Burst` / `Semi-auto` lines, 4 per hold) — this also happened in CIG3 on 11-10, so it is the rig's key 446 also being the pistol's burst toggle (BD22 VR, `rsld/g6_ammo.zs` PistolBurstFire), not the pocket. Owner to say whether the main grip should flip the fire mode at all | R1_B_log.txt |
| Hip diamonds frame | **shown**: looking down, the flare holster's magenta diamond with its flare at the off hip, the right-hip holster sphere (blue) round the whip; the cigarette pocket above | R1_B_chest_hip_diamonds_cig.jpg (middle) |
| Wheel 3D props | **spawned (log), frame too small**: `RSQ Wheel card UBQS_Saber: prop UBQS_HipSaber`, `SSQ_ShieldSaw: prop SSQ_Prop`, `RSQWP_WhipWeapon: prop RSQWP_Stowed`, the fist/glove cards `RSQ_Glove RMHF` (FBX fist). At 720 px the cards were hidden behind the hands and the floating status bar. Redone in launch 3 with the new one-fist-card Wheel (fc833ac7) | R1_B_log.txt (RSQ Wheel card, R1 WHEEL) |
