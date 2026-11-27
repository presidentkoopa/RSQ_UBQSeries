# Rig check round 2: RSQ SlowMo (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

Rows that round 1 (`merge_main/design/rigcheck_2026-11-27/SlowMo.md`) left CAN'T TEST, now run. README line numbers are today's
`merge_main/SlowMo/README.md`.
Rig: `rig2`, `qz_hz 35`, Freedoom 2, map `R2MAP01` (test room). pk3: current main `RSQ_SlowMo` (+ `RSQ_Grenade` in R2_SM1), copied
14:45. `rsqsm_debug 1`, `developer 1` (its near-miss line). Slow motion started with the mod's own door `netevent rsqsm_start:r2
<ms> 0` (World Speed slider, 25%). Test-only probe: `c_svc` reads the meter (`adr`), `r2_zshoot` makes a monster fire one
hitscan bullet at a chosen point beside the head (the mod turns it into its slowed round), `c_ball` a monster's fireball.
Logs: `/home/claude/rigcheck_round2/logs/R2_SM1.log`, `R2_SM2.log`, `R2_trail.log`, `R2_lean.log`. Frames:
`/home/claude/rigcheck_round2/frames/SlowMo/`. Rig only, not headset.

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 14b | Under 25 adrenaline: a low buzz and the "oof" (14) | CAN'T TEST | | Buzz and sound cannot be checked (-nosound, no haptic log); the refusal itself worked in round 1 |
| 16, 28 | A round passing within 64 units of the head: whiz/crack, rumble, +4 adrenaline (16, 28) | WORKS (meter) | R2_SM2.log:82 (adr 0, slowed), 83 (a zombie's bullet aimed 40 units beside the head), 115 (`round passed player 0 at 40 units`), 193 (adr 4) | Sound and rumble not checkable |
| 17 | The meter carries over from level to level (17) | WORKS | R2_SM1.log:91 (adr 36 after three kills), 120 (next map: adr 36) | |
| 22 | Aim, fire and reload at full speed while slowed (22) | WORKS (fire) | R2_SM1.log:250 -> 375 (Pistol 50 -> 42: 8 shots in 105 tics, normal), 423 (slowed to 0.25), 426 -> 549 (42 -> 34: the same 8 shots in 105 tics, slowed) | Reload speed not measured |
| 23 | Sounds drop in pitch (23) | CAN'T TEST | | -nosound |
| 25 | A hitscan shot while slowed: a fading trail from muzzle to hit (25) | WORKS | sm_trail_zoom.png (left: a dotted trail from the gun to the far wall during slow motion, R2_trail.log:131; right: the same shot at full speed, no trail); rig_particle_test.png (the rig draws particles) | Round 1's frame had no shot |
| 27 | Lean the head 6 cm or more, stick centred, as a slowed round reaches you: a round passing on the side you leaned away from misses you (27) | BROKEN | R2_SM2.log:202 (a zombie's bullet aimed at the middle of the head, slowed), head leaned 12 cm to the side 10 tics later and held (the pawn moves with it: R2_lean.log, 0.12 m lean = 4.1 units), 226 (`DoomPlayer took 5 (Hitscan) ... via RSQSM_Round`: hit) | A 12 cm lean (twice the 6 cm asked) did not dodge a round on its line through the head's old place. By the code (body.zs LeanDodges) a round misses only if it passes more than (player radius 16 - lean) units off centre, i.e. a 6 cm lean (2 units) dodges only a round already 14+ units off centre; the README promises a miss for any round on the side leaned away from |
| 42 | Reload by hand: the world slows 1.2 s (42) | CAN'T TEST | | Needs BD22 VR's hand reload driven on the rig; not run |
| 44 | Grenade (RSQ Grenade's) goes off: the world slows 3 s (44) | WORKS (RSQ Grenade) | R2_SM1.log:1481 (`RSQGN boom thrown t1214`), 1486-1487 (`trigger grenade t1215 ... started 3000 ms at 25% (automatic) ... GRENADE BLAST`), 1503 | Brutal Doom's grenade and BD22 VR's over-under 40 mm not run |
| 46 | Colour Drain: colours fade as the world slows, up to 35% at full depth (46) | WORKS | sm1_trail_drain.png (third frame: Drain on, slowed, grey; fourth: Drain off, slowed, full colour); mean saturation 49.7 against 71.3 (-30%) | |

Counts (this round, 10 rows): WORKS 6, BROKEN 1 (#27 lean), CAN'T TEST 3 (#14b buzz/sound, #23 sound pitch, #42 BD22 VR hand reload), PARTLY 0.
