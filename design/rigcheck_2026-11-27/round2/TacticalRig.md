# RSQ Tactical Rig: rig check round 2 (2026-11-27)

**IWAD:** every run in this file is **Doom II** (`/home/claude/rigdata/doom2.wad`).

Rig: rig2 (copied per run), rig only (not headset).
- Map: R2TR01, a TEST-ONLY room (`/home/claude/rigdata/probes/R2/src/mktr.py`):
  - three Door_LockedRaise doors (lock 129, any red key) at x -300 / 0 / 300, y 300
  - a Line_Mirror on the north wall (x -128..128, y 1024)
- Plain Doom runs (`RSQ_TacticalRig` (+ `RSQ_Grenade`)): R2_TR1, R2_TR1b, R2_TR8, R2_TR9.
- BD stack runs (brutal22test6 + VoxelPack + VR-Reloaded 3.0rc + the series pk3s named per run): R2_TR2..R2_TR7, R2_TR10.
- Probes (TEST ONLY): `r2tr.pk3` lists the rig's drawn actors (class, frame, shown/hidden, alpha, place), door sector heights
  (`r2tr_sec`), and the pawn's mirror flag (`r2tr_pm`); `a.zs` hands/rig readouts.
- Logs: `/home/claude/rigcheck_round2/logs/R2_TR*.log`. Frames: `frames/TacticalRig/`.
- `vr_secondary_button_mappings 0` where the main grip is used (round 1 row G: with the engine default the gun-hand grip
  never reaches the rig).
- The off hand's alt fire has no controller route with that setting (the shift layer is off), so `rig_key Alt` (the key
  bound to `+oh_altatk`) was pressed for row 70.

Only the rows round 1 left CAN'T TEST or PARTLY for want of a run are here. Every other row stands as round 1 has it
(`/home/claude/rigcheck_ab/rigcheck_2026-11-27/TacticalRig.md`). That includes row G (BROKEN) and row 57 (PARTLY), whose
failing half was a real result, not a missing run.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 30 | Grenade spot: grip/Use gives the grenade; none: refused; a grenade hangs at the buckle while you have one, **with a light: green two or more, yellow one, red none** (30) | **PARTLY** | Grenade, refusal: R2_TR1b.log:507 (`T_REFUSE` grip at the buckle with 0), round 1 for the hand-out. Hanging grenade: frame tr1b_row30_grenade_spot_light.png (f116 / f176: the grenade at the buckle with 3 and 1; f196: gone at 0). Light: R2_TR1b.log:297 (hand away, 3 grenades: no `RSQTR_AmmoPip` at all), :343 (hand near, 3: pip frame 0 = green, shown), :388 (near, 1: frame 1 = yellow, shown), :433 (hand away, 1: hidden), :480-483 (near, 0: pip and grenade both **hidden**) | The light exists only while a hand is near (the ring showing), not "while you have one". **There is never a red light at none**: at 0 the pip is hidden with the grenade. On the rig the green/yellow pip could not be told apart in frames: it sits inside the grenade model under the spot's green marker (f136 vs f156 differ only in the tic label) |
| 53 | Stand at a map mirror: the torso, a helmet, copies of what your hands hold; the sprite marine hidden (53) | **PARTLY** | Plain Doom: frame tr1b_row53_map_mirror_zoom.png (green torso, grey helmet in the mirror). BD stack: R2_TR10.log:161, 176 (`invisible-in-mirrors 1`; `RSQTR_HelmetPart` + 3 `RSQTR_HeldShow` shown); frame tr10_row53_map_mirror_bd.png (f50/f58: torso and helmet, no sprite marine; f71 with Torso off: the sprite marine is back, :183 `invisible-in-mirrors 0`) | Torso, helmet and the hidden marine are seen. The three hand/gun copies exist (probe) but could not be made out in the reflection at 500 px (hands up or down looked the same) |
| 59 | Die: every ring, stored gun and light hidden until you live again; a cigarette out is gone (59) | WORKS (read) | R2_TR1.log:626 (alive, hand at a full holster: 13 of 19 rig actors shown, incl. stored-gun icon, pip, digits), 635 (death), 673 and 725 (dead: 1 of 19 "shown", and that one is the `RSQTR_CigPack` inventory item, not drawn), 877 (after the reload: shown again); cigarette half: round 1 | No frame: the dead view cannot look down at the body; the verdict is from the actors' own flags |
| 60 | Save or Load a holster profile; rings take its colour (60) | WORKS | Menu: R2_TR1.log:1257 (`R2SEL Save Standing B (Orange) -> item 83 in RSQTR_Test`), Pad_A, then "Tactical Rig: holsters saved to Standing B (orange)"; again R2_TR8.log:294. Colour: frame tr9_row60_ring_blue_then_orange_row80_chest.png (f215 the ring blue under profile A, f225 orange after Standing B is saved, R2_TR9.log:292) | |
| 64 | Whip spot: drawn / away; a whip put at an empty gun holster goes to its own holster (64) | WORKS | R2_TR2.log:1059-1063 (whip drawn at its spot), 1117 (`T_PRESS` at the empty Right hip with the whip), 1118 (`T_RIG whip holster: the whip goes home from the main hand`) | The not-run half of round 1, now run |
| 65 | Off grip at the flare spot: unlit flare / back; **with no flares: refused** (65) | WORKS | R2_TR2.log (T65 section): `T_PRESS t890 off hand at Flare`, `T_REFUSE t890 hand 1: double pulse and *usefail`, "No flares left" (`RSQFF_Ammo` taken, empty off hand) | |
| 68 | Main grip at the keyring, hold, touch the keys to a locked door: used through the lock check (68) | WORKS | R2_TR1.log:1668-1669 (`T_KEYS in hand 0`), 1699 (`T_KEYDOOR line 14: Line.Activate returned 1`), 1825 (door sector 3 ceiling 0 -> 118). Without a key (1444-1525): the keyring is empty, nothing to take, the door stays at 0 | |
| 69 | Off grip at the keyring, within 25 cm of a locked door, off fire: used; the off weapon does not fire (69) | WORKS | R2_TR1.log:1849 (`T_KEYS in hand 1`), 1901 (`off-hand trigger: locked door line 10`), 1904 (`Activate returned 1`), 1999 (ceiling 0 -> 90) | Off weapon fire not checked (empty off hand) |
| 70 | Keys in the off hand at a locked door: hold off alt fire, raise 12 cm: used (70) | WORKS | R2_TR1b.log:868 (`keys in hand 1`), 915-917 (`off-hand alt-fire on locked door line 6: raise to open`), 945 (`raised 0.13 m: door line 6 opened`), 948 (`Activate returned 1`), 1058 (ceiling 0 -> 104) | R2_TR1's attempt with grip+left trigger fired the trigger route instead (1899-1904): with `vr_secondary_button_mappings 0` the controller has no off-alt route; the bound key was used |
| 73 | Thrown gun hits a monster: hurt 1-60, flinches, freezes 3 tics, shoved; the gun drops off it (73) | WORKS | R2_TR1b.log:739-742 (Shotgun thrown at 5.4 a tic), 771 (`T_HIT ... at 8.9 a tic: dmg 15 (hp 60 -> 45)`), 774-783 (imp `st pain`, `freeze 3 / 2 / 1 / 0`), 786-805 (shoved along the throw: y 70 -> 76 -> 82 ... 104 once the freeze ends) | |
| 75 | Watch pose + Use: that hand's gun to the other hand, and back (75) | WORKS | R2_TR4.log:1102 (`watch move hand 0: Melee_Attacks -> main, Rifle -> off`), 1133 (off `RSQ_Off_Rifle`); 1179 (`watch move hand 1: RSQ_Off_Rifle -> main, RSQ_Hands -> off`), 1212 (main Rifle again) | The way back works with the off hand's wrist rolled 90 (`L -0.10 1.40 -0.25 30 -60 90`). Round 1's roll 180 is read as the wrong twist for the left hand (gestcopy.zs InspectPose flips the sign for the left), so it never entered the check |
| 80 | Ammo Count on: the gun's rounds as a small number over the ring (80) | **PARTLY** | R2_TR1.log:554-555 / 603-604, R2_TR8.log:236-237 / 264-265 (`RSQTR_AmmoDigit` frames 5,0 with 50 shells, 1,2 with 12: shown, green / per state); frames tr8_row80_ammo_count_digits.png (right hip at 600 px: no digit seen), tr9_row80_chest_digits_zoom.png (right chest: two pale-green flat marks beside the ring) | The digits are there and correct, but no number could be read in any frame. At the hip (looked at from straight above) they do not show at all. At the chest they show as two smeared green marks. They look like flat sprites seen nearly edge-on from above |
| 83 | Off grip at the off shoulder with ShieldSaw's saw mounted: on the shoulder -> off hand; in hand -> back; disc out: refused; Use does nothing for the saw (83) | WORKS | R2_TR6.log (ring closed, world running, :288): 241 (mounted on Left shoulder); 333 (Use at the shoulder: hands unchanged); 358-363 (grip: `ssq: p0 DRAW`, off `SSQ_ShieldSaw`); 387-392 (grip again: `STOW`; :420 the shield back on the shoulder at z+41); 478 (thrown), 511-513 (grip with the disc out: `T_REFUSE`); frame tr7_shieldsaw_mounted_left_shoulder.png (looking left: the shield hangs on the left shoulder) | See ShieldSaw.md rows 28-30 |

## Counts (rows re-checked here)
13 rows: WORKS 10 (one read from the actors, #59), PARTLY 3 (#30, #53, #80), BROKEN 0, CAN'T TEST 0.

Carried from round 1, not re-run:
- BROKEN: row G (main grip under the engine's default mappings).
- PARTLY: row 57 (a new map: the torso faces the start angle, not the head).
- CAN'T TEST: none left.

## Rig notes for anyone re-running these
- The frame-dump file number follows the rendered frame, not the tic. A Wheel menu or a load stalls rendering, so map a
  frame by the tic number AProbe draws in it.
- Teleporting a hand that holds the ShieldSaw (resetting a pose in one tic) reads as an 11+ m/s swing and throws the disc.
  Move it with `MOVE` over 25 tics.
- `Open Wheel` with a slot open goes back to the slots and does not close the ring: two presses close it. While the ring
  is up the world is frozen.
