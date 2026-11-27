# Rig check round 2: RSQ Miniboss (RSQ Boss) (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

Rows that round 1 (`merge_main/design/rigcheck_2026-11-27/Miniboss.md`) left CAN'T TEST, now run. README line numbers are
today's `merge_main/Miniboss/README.md`.
Rig: `rig2`, `qz_aimroll 1`, `qz_hz 35`, Freedoom 2, Brutal Doom stack (brutal22test6 + BD22 VoxelPack + BD22 VR-Reloaded 3.0rc)
+ `RSQ_Miniboss`, `RSQ_Score`, `RSQ_SlowMo`, `RSQ_VisualRewards` (current main, copied 14:45). R2_MB1 on the empty test room
(no fight could land there: `No Boss: No Monsters`, R2_MB1.log:731); R2_MB2 / R2_MB3 on MAP01. `rsqmb_debug 1`; the mod's own
test doors `rsqmb_fill 1000`, `rsqmb_callin`, `rsqmb_exfill 1000`, `rsqmb_comeback` (sv_cheats); R2_MB3 with `rsqmb_bf_cooldown 0`
and `rsqmb_bf_cap1 20` so several fights fit one map. Fight monsters are hit by the test probe's `c_mbkill` (DamageMobj from the
player). Note: those probe blows are huge, so "Boss Life by Time" turned them into huge life pools (R2_MB3.log `damage per
second 91286.8 x 20 s`): a rig artefact, not a player's case. Logs: `/home/claude/rigcheck_round2/logs/R2_MB1..MB3.log`.
Rig only, not headset; no frames this round (the rows below are log rows).

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 23-24 | WEAK! points while the Boss winds up; miss, and the attack fires (23-24) | WORKS | R2_MB2.log:1860-1862 (`"WEAK!" held over weak point 0/1`, `winds up (act 1, 2 weak points of 40 hp, 105 tics; attack travelling beam; next N 20.0 s)`), 2015 (`MISSED: travelling beam fires (act 1, 15 a hit)`) | Breaking both points (CRITICAL!, stagger) not driven |
| 25 | Finisher: melee on a staggered thrall (25) | CAN'T TEST | R2_MB3.log:784 (`a thrall RifleZombie staggers 70 tics (health 6)`), then a 1-damage Melee-type blow by the probe: no finisher line | The stagger works; the probe's typed blow is not a weapon's melee strike and no real melee swing was driven |
| 28 | CHARGER!: two stamps, a line, the rush; hits the wall: stunned 2 s, x1.5 (28) | WORKS | R2_MB2.log:401, 580 (trait rolled), 1292-1483 (winds up 42 tics, stamp 1, stamp 2, the line locks, rushes at 26 a tic, `hits the wall: stunned 70 tics, takes x1.50`, over), again 2043-2253 | Being caught (20 damage, knock back) not tried; SUMMONER / SHIELDED / SPLITTER did not roll in 4 fights |
| 27, 29-30 | SUMMONER!, SHIELDED!, SPLITTER! (27, 29-30) | CAN'T TEST | | Every Boss in these runs rolled CHARGER! (R2_MB2.log:401, R2_MB3.log `rolls CHARGER!`) |
| 32 | Walk over the life crate: +1 Score life (32) | WORKS | R2_MB2.log:3734 (`RSQ_ScoreLifeCrate` where the Boss died), 3732 -> 3815 (lives 1 -> 2 after walking onto it) | |
| 33 | Spend a Score life during the fight: lost, they leave on beams, BOSS WINS!, Big Boss bar still +25% (33) | WORKS | R2_MB3.log:4378-4400 (killing hit, Score life spent: `FIGHT LOST ... 2 monster(s) leave on beams, no legendary`, `Big Boss bar: a Boss lost: 25% -> 50%`, the Boss `on a beam, removed`) | The BOSS WINS! banner text was not read |
| 34-39 | Kiosk (34-39) | CAN'T TEST | R2_MB2.log:3394 (`kiosk: none (BD22 VR Reloaded's LD mode is off (no LegenDoom))`) | Needs full LegenDoom, not on this machine |
| 40 | Big Boss bar full: called like a Boss (BIG BOSS! card) (40) | WORKS | R2_MB3.log:5108 (bar 50% -> 100% `a Big Boss is due`), 5127 (`BIG BOSS CALLED IN`), 5134 (`BIG BOSS CARD: IMP WARLORD (BIG BOSS, EX-3, HP ...)`) | |
| 41 | Fight a Big Boss: card, lands alone, weak points throw bits (41) | PARTLY | R2_MB3.log:5135 (`Imp + 0 thralls`), 5289-5294 (lands alone, quake, pentagram lines), 5845-6085 (lives lost, win) | Lands alone as claimed; its 3 weak points and their bits were not seen (fight ended by probe blows) |
| 42 | Big Boss Guard while its summons live (42) | CAN'T TEST | | No GUARD window came up before the probe ended the fight |
| 43 | Beat a Big Boss: as a win, its kiosk five Epic (43) | PARTLY | R2_MB3.log:6085 (`win counted`) | The kiosk half needs LegenDoom |
| 44 | REVENGE / REVIVE: damage x1.5 for 10 s (44) | WORKS | R2_MB1.log:615-616 (20 damage before), 624 (`power: damage x1.50 for 10 s`, the mod's `rsqmb_comeback` test door "as a REVIVE would give it"), 667 (the same 20 now 30) | Reached through the mod's test door, not a real DOWN revive |
| 45 | Your damage per world colour (45) | CAN'T TEST | | Needs RSQ Monsters (may not be loaded) |
| 51 | Arrival: Classic: all land in front, held, cannot be hurt until a 5 s count (51) | PARTLY | R2_MB3.log:6331-6381 (no "Around You" ring stage; banner `BOSSINCOMING|...|clock:5`) | The 5 s clock is there; "held and cannot be hurt" was not measured |
| 52 | Call It In: Off: Use on the card does nothing, the card stays grey (52) | WORKS | R2_MB3.log:8051+ (`MINIBOSS FIGHT READY`, card `SHOWN GREY, meter READY`, `Use pressed, card grey`, no fight called) | |

Also seen (round 1 rows, more evidence): fight kill rewards and the ammo burst on a lost life (VisualRewards.md #25), the
Boss leaves on its last life with `win counted` and Big Boss bar +25% (R2_MB3.log:1676-1681).

Counts (this round, 15 rows): WORKS 7, PARTLY 3 (#41, #43, #51: parts not reached), BROKEN 0, CAN'T TEST 5 (#25 finisher, #27/29-30 traits not rolled, #34-39 kiosk, #42 guard, #45 RSQ Monsters).
