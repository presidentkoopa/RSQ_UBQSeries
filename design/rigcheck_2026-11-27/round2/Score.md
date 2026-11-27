# Rig check round 2: RSQ Score (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

Rows that round 1 (`merge_main/design/rigcheck_2026-11-27/Score.md`) left CAN'T TEST, now run where the rig can drive them.
README line numbers are today's `merge_main/Score/README.md`.
Rig: `rig2`, `qz_hz 35`, Freedoom 2, map `R2MAP01` (test-only room). pk3: current main build (copied 14:45): `RSQ_Score` +
`RSQ_SlowMo` (R2_SC1-SC3), + `RSQ_Miniboss` for its built-in Champions (R2_SC4, `champion_OverrideChance 256`: every monster a
champion). `rs_score_debug 1` (its `RS_Score[killer]: ... | Row share` lines), `rs_score_hs_log 1` (`HS` head-shot verdicts).
Kills and blows by the test probe (never ships): `c_kill` / `c_dmg` (DamageMobj from the player with a damage type), `c_shoot`
(a real hitscan from the eye at a height of the monster), `c_mkill` (monster kills monster), `c_mz` (lift a monster), `c_pz`
(the player's jump), `r2_worldkill` (damage with no source), `r2_justice` (a real hitscan the tic a monster is in its Missile
state), `r2_kill` (forced death); real weapons where the row needs them (fists, chaingun, chainsaw, rocket launcher, trigger held).
Logs + scripts: `/home/claude/rigcheck_round2/logs/R2_SC1..SC4.log`. Frames: `/home/claude/rigcheck_round2/frames/Score/`.
Rig only, not headset; sounds not checked.

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 19 | Glossary: Enter does nothing (19) | WORKS | R2_SC1.log:98-114 (`Pad_A` = Enter twice: the Glossary stays open, closed only by `closemenu`) | |
| 21-22 | Mouse clicks on a tab / a row (21-22) | CAN'T TEST | | The rig sends no mouse or pointer events |
| 28 | The level kills a monster with no blow of yours: nothing (28) | WORKS | R2_SC1.log:129 (`r2_worldkill`: Zombieman killed with no source), 137 (score still 0, no `RS_Score` line) | |
| 32 | Die anyway while holding lives: one lost, the others kept (32) | WORKS | R2_SC1.log:1906 (lives 3), 1918-1919 (forced death: `died through the hold -- one life lost, 2 kept`), 1985 (lives 2) | |
| 33 | Finish a map: total and lives kept, bar starts empty (33) | WORKS | R2_SC2.log:110 (score 20, lives 2, progress 4), 132 (next map: score 20, lives 2, progress 0) | |
| 37 | Punch, saw or kick (a melee hitscan): no critical roll (37) | BROKEN (saw) | R2_SC1.log:135-505 (300 tics of Fist punches on a Baron, hits at 185, 200, 219...: no crit line); 577-703 (chaingun: 4 crits); 1112-1367 (plain Doom Chainsaw on a Hell Knight: `CRITICAL HIT (hitscan) on HellKnight by BulletPuff` at 1272, 1297, 1334) | The fists roll no crit, as claimed; the chainsaw's blows did roll crits (x2 and the stun) |
| 52 | Land a kill after you have died: Swan Song +3.0, big moment (52) | WORKS | R2_SC3.log:361-363 (forced death), 383-384 (the rocket fired before it lands: `Swan Song 2.813 | Direct Hit 0.188`, together the 3 x base cap) | |
| 56 | Juggle (56) | WORKS | R2_SC1.log:886-888 (monster lifted 30, punched, killed by a melee blow: `Juggle 0.300`) | |
| 57 | Ring Out: punched, then another monster kills it within 2 s: yours, +0.5 (57) | WORKS | R2_SC1.log:838 (punch), 851-856 (another imp kills it 10 tics later: `RS_Score[killer] ... Ring Out 0.500`) | |
| 58 | Counter: melee kill in its Missile/Melee state or within 18 tics of its shot (58) | WORKS (state) | R2_SC1.log:1367 (chainsaw kill of an attacking Hell Knight: `Counter 0.300`) | The "within 18 tics of its shot" path, tried with a probe-fired imp ball the same tic (803), paid no Counter; a monster's own shot was not timed |
| 59 | Knockdown: fist kill while in Pain (59) | WORKS | R2_SC1.log:770-772 (`Knockdown 0.200`, Brawler) | |
| 62-67 | Blind-fire, Off-hand, Two Guns, Combo Chain, Variety, Weapon Master (62-67) | CAN'T TEST | | Not run in round 2 either: they need firing by each hand's trigger with an off-hand gun (BD22 VR) and several mods' melee tools on one monster. (A `Combo Chain[Gun Kata 0.40]` was paid on its own in R2_SC1.log:718) |
| 69 | Death from Above: melee kill while falling, feet 34+ above its head (69) | WORKS | R2_SC1.log:955 (`Death from Above 0.400`, Air) | |
| 73 | Hand Cannon (73) | CAN'T TEST | | Not run: BD's BrutalRevolver kill from full health not driven |
| 76 | Direct Hit: a rocket's impact, not its splash (76) | WORKS | R2_SC2.log:195-198 (real RocketLauncher shot: `Direct Hit 0.200`) | A probe-spawned rocket (R2_SC1.log:1079-1080) killed by impact and paid none: the rig's spawned missile, not the mod |
| 77 | Rip and Tear: kill 400+ with a chainsaw (77) | BROKEN | R2_SC1.log:1162-1367 (Doom's Chainsaw on a 500-health Hell Knight until it died: paid `Brawler`, `Counter`, `Point-Blank`, `Giant Slayer`, no Rip and Tear) | The chainsaw's blow reads as a punch (its damage type is Melee); the row only knows Brutal Doom's saw puffs (tools.zs `SSawPuff`/`SawDamage`). The README names no Brutal Doom need |
| 78 | Justice Shot: shot dead in its attack before its shot left (78) | WORKS | R2_SC1.log:1530-1534 (imp shot in its Missile state: `Justice Shot 0.400`) | |
| 182 | Last Grain: kill while the world speeds back up (182) | WORKS | R2_SC1.log:1775-1790 (scale 0.61 and 0.89 heading for 1.00: `Last Grain 0.200` twice; at 1.00, 1803-1841: none) | |
| 189-220 | Champions rows not met in round 1 | PARTLY | R2_SC4.log (64 forced champions): Silver 0.500, Yellow, Red, Indigo, Grey, Cyan, Pink, Green champion rows, Hybrid, Ghost, Balloon, Pinata, Champion Streak, Rainbow 0.500 at 5 colours and 1.000 at 10 with its big moment (383, 562-566), Glass Cannon, Too Close for Comfort | **Pop! BROKEN**: a Balloon champion killed by a melee blow (R2_SC4.log:1029-1030: `Melee`, Brawler, `Balloon 0.250`) paid no Pop!: the Balloon row knows the balloon by its float flags, Pop! asks for a `champion_BalloonToken`. Dark Red, Bronze, Gold, Titan, Undying, Immovable Object, Fool's Gold, Heartbreaker, Champion Fatality: none came up in 64 champions (CAN'T TEST) |
| 248 | Wrist Score: the total in gold above the off hand (248) | WORKS | frame sc3_visual.png f190/f200 (gold "185" above the off hand, the total then) | |
| 249 | Reward: Ammo Only: 20 s of ammo back, 40% of each max (249) | WORKS | R2_SC2.log:365 (two rewards, lives stay 2), 338, 368, 508, 649 (Clip 50 -> 67 -> 84, rockets 21 -> 25 -> 29 over 300 tics) | |
| 250 | Reward: None: nothing, no bar (250) | WORKS | R2_SC1.log:2348-2366 (bar wrapped with no life and no ammo); frame sc3_scoreline_zoom.png (third: SCORE with no bar; fourth: bar back after) | |
| 251 | New Map Keeps: Nothing / Total / Everything (251) | PARTLY | R2_SC1.log:2692 -> 2716 (Nothing: score 10858 lives 3 -> 0 and 0); 2734 -> 2758 (Total: score 4000 kept, bar empty) | Everything was not read (the run ended before the next readout); Total's "lives not kept" not shown (0 lives before) |
| 252 | Revival Fire: Off: no ring of fire (252) | WORKS | R2_SC1.log:2378-2384 (revived: the blast carrier `RS_ScoreReviveFire` only, no `RS_ScoreReviveFlame` spawned) | |
| 253 | Reward Tint / Revival Tint (253) | WORKS | frame sc2_visual.png f576 (the whole view tinted at the reward), f588 (tinted at the revival) | |
| 254 | Head Shots: Off: no extra damage, the row still given (254) | WORKS | R2_SC2.log:267-271 (On: `verdict HEAD ... bonus 30`, 30 more damage, row pays); 301-318 (Off: `verdict HEAD ... bonus 0`, 5 damage only, `Headshot row PAYS`, Headshot 0.250) | |
| 255 | Critical Hits: Off (255) | WORKS | R2_SC1.log:2448-2618 (100 tics of chaingun on a Baron: no crit line; with them on, 4 in 100 tics: 577-703) | |
| 256 | Show Score: Off (256) | WORKS | frame sc3_visual.png f64 (no score line; f24 before it shows SCORE and the bar); R2_SC3.log:137 (the kill still paid) | |
| 257 | Bonus Time: 0: no rows drawn (257) | WORKS | frame sc3_scoreline_zoom.png (first: rows under the bar after a kill; second, Bonus Time 0: none) | |
| 258 | Roster rows switched off (258) | CAN'T TEST | | RSQ Monsters may not be loaded (job rule) |
| 259 | Family cap above 0 scales that family down (259) | WORKS | R2_SC1.log:2643 (Style Cap 10: Double Tap paid 0.100 against its 0.200) | |
| 82-180 | The other mods' move rows (BD22 VR axe, Melee, Saber, ShieldSaw, Whip, Grapple, Distance Grab, Tactical Rig, Grenade) and the 171 named combos | CAN'T TEST | | Not run in round 2 either: each needs that mod's own hand moves; left for a per-mod pass |
| 221-246 | LegenDoom rows, RSQ Monsters roster rows | CAN'T TEST | | LegenDoom not on this machine; RSQ Monsters may not be loaded |

Counts (this round, 33 rows): WORKS 23, PARTLY 2 (#189-220 champions, which holds the BROKEN Pop!; #251), BROKEN 2 (#37 the chainsaw rolls crits; #77 Rip and Tear never pays on Doom's chainsaw), CAN'T TEST 6 (#21-22 mouse, #62-67, #73, #258, #82-180, #221-246).
