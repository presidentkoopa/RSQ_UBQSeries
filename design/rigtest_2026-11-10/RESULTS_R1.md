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
| ... with SlowMo on | **not shown in launch 1, shown in launch 2 (below).** `netevent rsm_toggle 2` was sent but nothing in the log proves slow motion was running (no rsm_state readout; the frames show no colour drain). The menu frame over it (00192) has no HUD of ours | R1_HUD11A_sheet.jpg (00180, 00192) |
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
| SlowMo + menu | **shown.** (Correction: my first read of the log missed the lines.) `RSQ_SlowMo: trigger key t94: held ON at 25%`, countdown bar on; `slow motion: ON, scale 0.25, 387 actors slowed` read while the menu was open (t109). Frame left: slow motion running, gauges and Score line drawn; right: the options menu over it, no gauge, no Score, no SlowMo bar, no Accessibility cue. One small red line shows over the menu's Gauge Animation row, ending "(rig scaled 55%)": a console/notify line from the rig's debug messages (`rsqtr_messages 1`, test-only), not a HUD | R1_B_log.txt, R1_B_slowmo_then_menu.jpg |
| Right-chest flare diamond gone while the flare holster is on | **shown (log + frame).** `flare.home 1`; FnF's `pocket.*` zone answers 1e9 (not published, so the rig draws no diamond); an off-hand grip there: `RSQFF grip: ... the pocket is off: the flares are in the Tactical Rig's flare holster`. Frames looking down at the chest: no diamond on the right chest, only the flare holster's magenta diamond at the off hip | R1_B_log.txt (R1 GEO, RSQFF grip), R1_B_chest_hip_diamonds_cig.jpg (middle) |
| Flashlight 0.21 m behind the flare holster | **position shown (log), grab not yet.** FnF's clip = the rig's torch spot exactly (0.000 m apart), **0.207 m** from the flare holster's centre (body frame f -0.27 vs -0.06, same l 0.30, u -0.84), 0.712 m from the cigarette pocket. The grip test missed: the off hand was 0.12 m from the clip (needs 0.08), my pose, not the code (`RSQFF torch grip: off hand 0.12 m from the clip (needs 0.08)`). Two earlier off-hand grip netevents left no line at all (see launch 3) | R1_B_log.txt |
| Cigarette pocket reachable by the main hand | **shown.** Main hand 0.058 m from the pocket (R 0.08), AtPocket 1; real main grip key (446): `T_CIG rsqtr_cigtake`, hands then `RSQTR_CigWeapon` / `RSQTR_ZippoWeapon`, packs 5 -> 4; grip again: `rsqtr_cigback`, back to BrutalPistol. Frame: the cigarette in the hand, the pocket's diamond green | R1_B_log.txt (tags 6-8), R1_B_chest_hip_diamonds_cig.jpg (right) |
| ... with nothing else winning it | **mostly shown, one note.** No holster, Distance Grab or FnF action fired. But the same grip key flipped BrutalPistol's fire mode (`Burst` / `Semi-auto` lines, 4 per hold) — this also happened in CIG3 on 11-10, so it is the rig's key 446 also being the pistol's burst toggle (BD22 VR, `rsld/g6_ammo.zs` PistolBurstFire), not the pocket. Owner to say whether the main grip should flip the fire mode at all | R1_B_log.txt |
| Hip diamonds frame | **shown**: looking down, the flare holster's magenta diamond with its flare at the off hip, the right-hip holster sphere (blue) round the whip; the cigarette pocket above | R1_B_chest_hip_diamonds_cig.jpg (middle) |
| Wheel 3D props | **spawned (log), frame too small**: `RSQ Wheel card UBQS_Saber: prop UBQS_HipSaber`, `SSQ_ShieldSaw: prop SSQ_Prop`, `RSQWP_WhipWeapon: prop RSQWP_Stowed`, the fist/glove cards `RSQ_Glove RMHF` (FBX fist). At 720 px the cards were hidden behind the hands and the floating status bar. Redone in launch 3 with the new one-fist-card Wheel (fc833ac7) | R1_B_log.txt (RSQ Wheel card, R1 WHEEL) |

## Launch 3: R1C (`/home/claude/scratch/rig1110/R1C`, + R1_probe.pk3 with `r1_ring` / `r1_pick` / `r1_hands`), RES 960, EVERY 2

Pulled first: includes fc833ac7 (the Wheel's ONE fist card). Start With Melee Hands on (`rsqml_gloves 1` before `map MAP01`),
Slappers Only and Boxing Gloves off. rc=0, 25 frames (the renderer gave one frame per ~5 tics, so only two ring frames).
Script errors: the 4 BD_VoxelPack ones only.

| Check | Result | Evidence |
|---|---|---|
| Flashlight grabbed from 0.21 m behind the flare holster | **shown.** Off hand 0.044 m from the clip (clip 0.207 m from the flare holster's centre, same height and side); off grip: `RSQFF torch take t108: the flashlight in the off hand (had RSQ_GloveOff)`, light on; grip again at the clip: `RSQFF torch back t126: on the clip again`. The same grips at the old right-chest flare pocket: `the pocket is off` | R1_C_log.txt (tags 10-12) |
| Off-hand grip on the rig (method note) | The off grip cannot be pressed; the probe sends the same netevents a press sends (`rsqtr_grip 1 1/0`, `rsqff_grip 1/0`), held 8 tics. In launch 2 two 3-tic grips left no line; held 8 tics, both registered | — |
| ONE fist card in slot 1 | **shown (log + frame).** The ring's cards: `[0] RSQ_Glove [1] UBQS_Saber [2] SSQ_ShieldSaw [3] RSQWP_WhipWeapon [4] BrutalPistol [5] Rifle [6] HandGrenades`: 1 fist/melee-hands card (no separate Fists or second Melee Hands). Frame: one skin-tone fist card | R1_C_log.txt (R1 RING), R1_C_wheel_ring_3d_cards.jpg |
| A pick from each hand gives that hand's glove | **shown (log), aim not tested.** The probe set the hovered card to the fist card and the picking hand, then sent the Wheel's own `wr_grab` (the normal commit path). Main: `RSQ Wheel: pick RSQ_Glove (card RSQ_Glove) -> hand 0`, ready BrutalPistol -> RSQ_Glove. Off: `pick RSQ_GloveOff (card RSQ_Glove) -> hand 1` (the off hand already held RSQ_GloveOff, so no visible change there) | R1_C_log.txt (R1 PICK, RSQ Wheel: pick, R1 HANDS) |
| Wheel 3D models: saber hilt, shield, coiled whip, FBX fist | **shown, rig only.** The fist card: the FBX fist in skin tone; the shield card: the green shield turning (edge-on in one frame, face-on in the next), centred; the whip card: the coiled whip; the saber card: a thin dark rod with a light edge, the hilt. At this size it reads as a stick: the owner should judge in the headset whether it reads as a hilt. Pistol, Rifle and grenades keep their voxels/icons | R1_C_wheel_ring_3d_cards.jpg, R1_C_wheel_shield_fist_two_frames.jpg, R1_C_wheel_saber_two_frames.jpg |
| Does the saber circle its card or turn in place? | **turns in place, as far as two frames show.** In both frames the rod crosses the card's middle at a different angle (diagonal, then near vertical); it does not move round the card. Log: the prop's origin moves on a 1.8-unit circle (28.92 x 0.061), which is the planned offset that keeps the hilt's middle still. Two frames are little evidence; a slow sweep would settle it | R1_C_wheel_saber_two_frames.jpg, R1_C_log.txt (R1 WHEEL) |
