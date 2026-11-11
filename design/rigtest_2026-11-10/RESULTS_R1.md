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
