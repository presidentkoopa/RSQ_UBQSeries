# Rig check round 2: RSQ VisualRewards (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

Rows that round 1 (`merge_main/design/rigcheck_2026-11-27/VisualRewards.md`) left CAN'T TEST, now run. README line numbers are
today's `merge_main/VisualRewards/README.md`.
Rig: `rig2`, `qz_hz 35`, Freedoom 2. R2_VR1: `RSQ_VisualRewards` + `RSQ_FnF` on plain Doom, map `R2MAP01` (test room).
R2_MB1 / R2_MB2: Brutal Doom stack (brutal22test6 + BD22 VoxelPack + BD22 VR-Reloaded 3.0rc) + `RSQ_Miniboss`, `RSQ_Score`,
`RSQ_SlowMo`, `RSQ_VisualRewards` (R2_MB2 on MAP01, where a Boss fight can find monster kinds). pk3s: current main (14:45).
Test-only probe `r2vr.pk3` (never ships) prints the damage-number handler's own list (`R2VR ... num kind`: 0 a hit, 1 the
running total with `hits` = the xN combo, 2 a gain; `st` 1 = the kill slam; `kill`, `head`, `words` 1 HEADSHOT / 2 OVERKILL;
the gain's kind and hand) and each health bar (`hp`, `inv`, `aimMade`, `chunkHp/chunkTic`). Hits are the probe's DamageMobj
from the player. `rsqgb_kr_debug 1` for the Kill Rewards lines. Logs: `/home/claude/rigcheck_round2/logs/`. Frames:
`/home/claude/rigcheck_round2/frames/VisualRewards/` (480 px: the numbers can be seen, not read).

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 15 | A hit: a small number of the health lost jets up and fades in ~0.6 s (15) | WORKS | R2_VR1.log:77-131 (each hit a `kind 0` number of its damage, 20, 30, 25 ...; each gone about 20 tics later); vr1_numbers.png / vr1_numbers_zoom.png (yellow digits by the bar, t30) | |
| 16 | Hit again within 3 s: running total over the bar and "xN", stepping white to red, shaking from x5 (16) | WORKS (colours not read) | R2_VR1.log:98 (`kind 1 value 50 hits 2`), 116 (75, x3), 143 (115, x4), 168 (150, x5), 192 (180, x6); vr1_numbers_zoom.png (total over the bar, red by t50, a red mark beside it) | The step colours and the shake were seen only as red text at 480 px |
| 17 | HEADSHOT over a bigger gold number on a Brutal Doom head hit (17) | WORKS | R2_MB1.log:472 (BD PistolZombie shot at 100% of its height: `head 1 words 1` = HEADSHOT) | Not framed |
| 18 | Kill: its total punches once, holds, fades (18) | WORKS | R2_VR1.log:219-260 (on the kill the total goes to `st 1` with `kill 1`, value 1000, x7, held about 20 tics, gone by t84); vr1_numbers.png t64 (red total over the dying Baron) | |
| 24 | Battery bit: 15% of the flashlight battery (24) | WORKS | R2_VR1.log:1322 (battery 885 permille), 1338 (`+15% (a battery bit): 88.6% -> 100.0%`) | |
| 25 | Boss fight: kill within 256 units or 2 s of the last kill: 2 more health and 2 more armour bits (25) | WORKS | R2_MB2.log:2540, 2980 (thralls 224 and 173 units away: `close ... -> +2 health, +2 armour bits`), 3408 (the Boss 492 away, 5.7 s after the last kill: `no extra bits`) | |
| 28 | Pick up health, armour or ammo: "+N" rises and flies to the wrist (health/armour off hand, ammo the gun's hand) (28) | WORKS | R2_VR1.log:523 (`kind 2` gain 0 = health, hand 1), 546 (armour, hand 1), 568 (ammo, hand 0); 545-600 (each goes `st 2` fly, `st 3` land) | The +11 armour and +20 ammo gains summed a picked-up item with Kill Rewards bits taken in the same moment |
| 29, 39-40 | LEVEL UP (29, 39-40) | CAN'T TEST | | Needs Gun Bonsai, not on this machine |
| 30 | Invulnerable: a magenta bar with the god face in the top stack, draining (30) | WORKS | vr1_invuln.png / vr1_invuln_zoom.png (t370: a magenta bar with a small face icon top centre during an InvulnerabilitySphere) | Draining not measured |
| 35, 41 | LegenDoom drop words, THREAT! (35, 41) | CAN'T TEST | | LegenDoom not on this machine |
| 36 | Only Where I Aim: the aimed monster's bar shows, no other bars (36) | WORKS | R2_VR1.log:414 (the Baron straight ahead at full health: a bar `aimMade 1`), 428-429 (the second, off the aim and hurt: its bar `inv 1 alpha 0.00`) | |
| 37 | Overkill Word: OVERKILL over the number (37) | WORKS | R2_VR1.log:294 (an imp killed by 500 damage: `kill 1 words 2` = OVERKILL) | Not framed |
| 38 | Damage Chunk: what the hit took stays lit white half a second, then drains (38) | WORKS | R2_VR1.log:337 (`chunkHp 1000 chunkTic 143` after a 300 hit), 369 (`chunkHp 0` 32 tics later); vr1_numbers.png t147 (a white piece at the bar's end) | |

Counts (this round, 12 rows): WORKS 10, CAN'T TEST 2 (LEVEL UP: Gun Bonsai; LegenDoom words), PARTLY 0, BROKEN 0.
