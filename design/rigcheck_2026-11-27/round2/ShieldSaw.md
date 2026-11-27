# RSQ ShieldSaw: rig check round 2 (2026-11-27), rows #27-#30 and #35

**IWAD:** every run in this file is **Doom II** (`doom2.wad`).

Rig: rig2 (copied per run), rig only.
- Stack: brutal22test6 + BD22 VoxelPack + BD22 VR-Reloaded 3.0rc + `RSQ_TacticalRig`, `RSQ_Wheel`, `RSQ_ShieldSaw`,
  `RSQ_Whip`, `RSQ_FnF`, on R2TR01.
- Settings: `ssq_debug 1`, `wr_debug 1`, `rsqtr_messages 1`, `vr_secondary_button_mappings 0` (the main grip at the
  holsters).
- How the Wheel was driven:
  - Cards were aimed at from the Wheel's own readout (`wr_test_cards`).
  - The main hand's alt fire was the key bound to `+altattack` (`rig_key LTrigger`).
  - The holster web's rings (Left shoulder = node 0, Right shoulder = node 1, Clear = node 6) were pressed with the
    Wheel's own netevent `wr_webpick <node> 0`, the event its trigger-on-a-ring sends. Only the hover on the ring was not
    driven.
- Runs: R2_TR3, R2_TR4 (ring left up by mistake: the world was frozen for the shoulder rows there, so those rows were
  re-run), R2_TR6 (clean: the ring closed with two presses, R2_TR6.log:288), R2_TR7 (frame), R2_TR11 (a gun at the
  mounted shoulder).
- Logs: `/home/claude/rigcheck_round2/logs/`. Frames: `frames/ShieldSaw/`.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 27 | In RSQ Wheel, take the ShieldSaw's card with either hand: the shield comes into the off hand (40) | WORKS | Main hand: R2_TR3.log:266-273 (slot 1 opened, beam on card 2 `SSQ_ShieldSaw`, "ShieldSaw picked by hand 0: ssq-draw sent ... -> hand 1"), 278 (`ssq: p0 DRAW`), 301 (off `SSQ_ShieldSaw`). Off hand: R2_TR4.log:244-248 (off beam on card 2, off trigger, "picked by hand 1"), 253, 275 (off `SSQ_ShieldSaw`) | The card is inside slot 1's group (Always Group). With the main beam resting on the data sheet the off trigger pages the sheet instead (R2_TR3.log:419-443, nothing taken), so the main hand was pointed away for the off-hand take |
| 28 | Main alt fire on the ShieldSaw's card, then primary fire on the off shoulder's ring: mounted, hangs on that shoulder, no gun can use that holster; any other ring: a dull tick and nothing (41) | WORKS | R2_TR3.log:542 (`web: opened for SSQ_ShieldSaw`), 557 (right shoulder: `refused: the ShieldSaw goes only on the off shoulder (a dull tick)`), 566-569 (`-> holster 1 (place 4)`, `T_ASSIGN ... mounted on Left shoulder`); R2_TR6.log:241, 306 (`SSQ_Prop` on the body at z+41, ring closed); frame tr7_shieldsaw_mounted_left_shoulder.png (looking left: the shield hangs on the left shoulder); R2_TR11.log:429-433 (Rifle into the Left shoulder: `T_REFUSE`, `refuse (red) ... picture SSQ_ShieldSaw`) | The refusal's debug line reads "assigned to , holding )" with the names empty (cosmetic, a log line) |
| 29 | Main alt fire on the card, then Clear: no longer mounted (42) | WORKS | R2_TR6.log:853 (web opened), 860 (`SSQ_ShieldSaw cleared (no holster)`), 863 (`T_ASSIGN ... no longer mounted`), 927-928 (`SSQ_Prop` on the body hidden), 963-965 (off grip at that shoulder afterwards, t919: `T_REFUSE`, nothing there) | |
| 30 | Off grip at the mounted shoulder: shield on the shoulder -> off hand; in the off hand -> back to the shoulder; disc out: refused (43) | WORKS | R2_TR6.log (world running): 358-363 (`DRAW`, off `SSQ_ShieldSaw` :385); 387-392 (`STOW`), 420 (back on the shoulder, z+41); 478 (thrown), 511-513 (grip with the disc out: `T_REFUSE`); 590-592 (disc caught), 649-654 (grip with it in hand: `STOW` again); 333 (Use at the shoulder: nothing for the saw, Tactical Rig row 83) | |
| 35 | Block While Holstered: the mounted shield blocks an attack from behind and turns shots (49) | WORKS | R2_TR6.log:702-709 (setting off: an imp's fireball from behind hits, 20 damage, hp 80); 737-743 (setting on, `ssq_guard_stowed 1`: `ssq: guard kind 0 BLOCKED dmg 20 from Imp (held 0 ...)`), 753 (`Imp took 20 ... from BDoomer via FireBall_`: the shot went back into the imp), 773 (hp 100, no player damage) | |

## Counts
5 rows: WORKS 5, PARTLY 0, BROKEN 0, CAN'T TEST 0.

Round 1's other verdicts stand: BROKEN #12; PARTLY #13, #15, #20, #31.

One observation for #15 (catch): in R2_TR4 the thrown disc hung 29 units out for about 170 tics (R2_TR4.log:633-723).
That happened with the Wheel's ring left up by mistake, so the world was frozen. It is not a ShieldSaw result.
