# RSQ Miniboss (RSQ Boss): rig check 2026-11-27 (agent C)

Rig: **rig2** (the fixed scratch rig: `qz_aimroll 1` makes a hand's roll reach ZScript, the right A button is Use),
Freedoom 2, rig only. Runs: **C_mb2 / C_mb4** (full stack: brutal22test6, BD22 VoxelPack, BD22 VR Reloaded 3.0rc, the
series pk3s but Controls / Monsters / BDXM / GunBonsaiVR; MAP01; `rsqmb_debug 1`), **C_gy1** (plain Doom, Miniboss +
Graveyard + a Legion of Bones stand-in, 10 fights), C_sc2 (BD). Logs `logs/C_<run>.log`, scripts `logs/C_s_<run>.txt`.
The fight's monsters are killed by a test probe (`c_mbkill`: DamageMobj from the player, not forced, in C_mb4).

## Today's changes
- **Graves Rise Chance 30%:** 10 fights in C_gy1: 3 woke the stone, 7 "the graves stay shut this fight (Graves Rise
  Chance 30%)" (C_gy1.log:1009 ... 1715; Graveyard.md). Default 30 (C_gy1.log:241). **WORKS** (small sample).
- **Ammo burst when the Boss loses a life:** 6 ammo bits at its feet each life (C_mb4.log:461+465-470, 506+510-518);
  share of light green in VisualRewards.md. **WORKS.**

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN/PARTLY) |
|---|---|---|---|
| Kills fill the meter; with Score a kill counts 4 + style x0.25 (14-15) | WORKS | C_mb2.log:311 "RSQMB meter +2.0 (Score style 8) -> 6" (4 + 8 x 0.25) | chains and movement not isolated |
| Full meter: gold, GITD beats red, stones beat (16) | WORKS | C_mb2.log:339 "MINIBOSS FIGHT READY", 340 card "SHOWN GOLD"; C_gy1.log:947-955 "miniboss heartbeat ... stone pulse" | the glow's beat not framed |
| Comes by itself 60 s after; the wait reasons under the meter (17) | PARTLY | reasons logged: C_mb1.log:370 "No Boss: Near Exit", C_gy1.log:1786 "No Boss: Map Limit" | the 60 s self-arrival not run (Arrives By Itself set to 0) |
| Pulse check shows the Start Fight card, grey / gold (18) | WORKS (rig2) | C_mb2.log:314 "off-hand inside check HELD, SHOWN GREY, meter 0%"; 340 "SHOWN GOLD (Use calls it in)"; roll 90 / 180 "no" (347, 359) | the check also reads HELD for the rig's default resting off hand (roll 0, C_mb2.log:314), not only a turned wrist |
| Use on the gold card calls the fight past every wait (19) | WORKS (rig2) | C_mb2.log:351-354 A button: "Use pressed, card gold" -> "CALLED IN (the Start Fight card)", "the fight card overrides "No Boss: Near Exit""; again C_mb4.log:311-313 | in C_mb3 one A press of 4 tics was not read (no "Use pressed"); 8-tic presses always were |
| Arrival: 3 s slow and dark; thrall spots marked 0.75 s before; 400-700 out; Boss lands last, 1.25x, invulnerable 1.5 s (20) | PARTLY | C_mb2.log:357-363 "stage turn 3.0 s, thralls land at tics [31 61 78] (each marked 26 tics before), the Boss at 100, its landing invulnerable 52 tics"; SlowMo "BOSS INCOMING" 3000 ms at 5%; banner BOSS INCOMING; 406 "scale x1.25" | MAP01: "0 in the ring (400-700 ...), 1 nearer, 2 at any angle": the first thrall landed 206 units away (368) |
| Thralls: the Boss takes 20% (all up) to 100% (none); each death takes its Champion power (21) | WORKS | C_mb2.log:406 "takes x0.20", 480-498 "loses Pink ... x0.47", "x0.73", "x1.00" | |
| 3 lives; a life lost refills, 5 s invulnerable, 6 ammo bits, a colour up, faster, a fresh thrall (22) | WORKS | C_mb4.log:456-464 "life lost: boss 0 lives 2 hp 40 invuln 175 tics", "steps up: colour tier -1 -> 2, speed 5.8, 1 fresh thrall"; 504-509 the second; bits above | GUARD on the bar not framed |
| WEAK! points, telegraphed attacks, traits SUMMONER/CHARGER/SHIELDED/SPLITTER (23-24, 27-30) | CAN'T TEST | the fights were ended before a wind-up (C_mb4) | |
| Finisher on a staggered thrall (25) | CAN'T TEST | stagger seen (C_mb2.log:430 "a thrall ... staggers 70 tics"); no melee strike sent | |
| Camping Pressure (26) | WORKS | C_mb2.log:445 "a player stayed within 128 for 8 s: RifleZombie sent straight at him" | |
| Kill the Boss: BOSS DEFEATED, Score's Miniboss Called, life crate, Big Boss bar +25%, kiosk (31) | PARTLY | C_mb2.log:552-558 award "Miniboss Called" -> Score, 565 "award Boss paid 240" (3 x base 80), life crate dropped, "Big Boss bar ... 0% -> 25%", banner BOSSWIN; world tier: "no RSQ Monsters" | kiosk: "none (BD22 VR Reloaded's LD mode is off (no LegenDoom))" (C_mb2.log:555): see the kiosk rows |
| Walk over the life crate: +1 life (32) | CAN'T TEST | the probe could not find the crate by a class name with "Crate" (C_mb4.log:438) | |
| Lost fight (33) | CAN'T TEST | not run | |
| Kiosk: opens, offers, buy with trigger, LUCKY, REPAIR, folds away (34-39) | CAN'T TEST | needs BD22 VR's kiosk service, which needs LegenDoom; LegenDoom is not on this machine (C_mb2.log:555). rig2's trigger and A button work (Use above) | |
| Big Boss (40-43) | CAN'T TEST | not run in this batch | |
| REVENGE / REVIVE: x1.5 damage 10 s (44) | CAN'T TEST | not measured | |
| Your damage per world colour (45) | CAN'T TEST | needs RSQ Monsters (not to be loaded) | |
| Rank moves: up on a clean win, down 8 on a lost Score life (46) | WORKS | C_mb2.log:557 "rank 0.43 -> 2.43 (a clean Boss win)"; C_gy1.log:946 "rank 65.08 -> 57.08 (a Score life lost)" | |
| VR Finisher / BD22 fatality: no scene, the finisher paid (47-48) | PARTLY | C_sc2.log:544-555 a Fatality-type kill, then Score "award Finisher paid 100" | no frame of the gib; which of 47/48 paid is not in the log |
| LegenDoom Lite (49) | PARTLY | the Boss carries "Legendary" among its powers (C_mb2.log:403) and Score paid "Legendary Champion" / "Legend Slayer" (C_mb2.log:561) | the transform at half health not run |
| Champions built in (50) | WORKS | thralls dressed in Champion colours (C_mb4 / C_mb2.log:374, 386, 390); Score's champion rows paid (Score.md) | |
| Arrival Classic, Call It In off (51-52) | CAN'T TEST | not run | |
| Ignore Spawn Restrictions (53) | WORKS | C_gy1: 10 fights called with it on, landed (1010 ... 1716) | |
| Graves Rise (54) | WORKS | today's change above | |
| Limits: any Use with the gold card shown calls the fight, even one meant for something else (399) | WORKS | C_gy1.log:959-961 the Use that read a gravestone also called the fight ("Use pressed, card gold") | |
| Limits: Per Map Cap (401) | WORKS | C_gy1.log:1786 "No Boss: Map Limit" after the cap (set to 10 for the test) | |

## Counts
Table rows WORKS 13, PARTLY 5, CAN'T TEST 9, BROKEN 0; plus the two today's-change items (both WORKS). NEEDS ROLL / MENU rows (the card, Use)
were re-run on rig2 and given real verdicts above; the kiosk stays CAN'T TEST for LegenDoom, not for the rig.
