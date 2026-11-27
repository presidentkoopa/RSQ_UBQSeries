# RSQ SlowMo: rig check 2026-11-27 (agent C)

Rig: the scratch Linux headless QuestZDoom 17.3 rig (faked OpenXR headset and hands), Freedoom 2, rig only, not headset.
Map: CRIG01 (a flat 3072 x 3072 test room, test-only probe pk3 `/home/claude/rigdata/probes/C/cprobe.pk3`, not shipped).
Loads: C_sm1/C_sm2/C_smarm: RSQ_SlowMo alone; C_sm3/C_sm4/C_dumptest: RSQ_GlowInTheDark, RSQ_SlowMo, RSQ_Score,
RSQ_VisualRewards (repo `pk3/`, built 12:24). Brutal Doom not loaded for SlowMo (its BD rows marked).
Logs: `design/rigcheck_2026-11-27/logs/C_<run>.log` (scripts `C_s_<run>.txt`). Frames: `frames/SlowMo/`.
Probe doors used in place of a fight: spawn, a monster's hit on the player (`c_hurt`), a kill by the player (`c_kill`,
DamageMobj with the player as source), place the player, trace the player each tic (`CTR` lines).

**Rig note for every HUD claim (all mods):** the rig's ini has `screenblocks=12`, which hides every HUD; with
`screenblocks 10` (set in the script) the HUD is drawn in the eye frames (C_hudtest4 vs C_hudtest3). Menus are drawn too.

## Today's change: Crisis Dive Air Time (line 18, options line 70, limits 298-299)

From C_sm1.log (CTR every tic; `rsqsm_debug 1`; flat floor; stick centred = forward east; defaults otherwise):

| Air Time | leap (log line) | landed (log line) | in the air | distance | apex | meter |
|---|---|---|---|---|---|---|
| 1.0 | t85 (75) | t151 (76) | 65 tics, 1.86 s | 337.6 u | 62.8 | 100 -> 81 (lines 73, 78): 19 |
| 1.5 (default) | t415 (83) | t515 (84) | 99 tics, 2.83 s | 342.8 u | 61.9 | 81 -> 53 (81, 86): 28 |
| 3.0 | t757 (103) | t961 (104) | 203 tics, 5.80 s | 347.2 u | 61.1 | 100 -> 42 (101, 106): 58 |

Air at 1.5 / air at 1.0 = 1.52; the distance changes by +1.5% (1.5) and +2.8% (3.0); the arc's height is the same.
The expected ~103 vs 69 tics came out 99-100 vs 65-66 (the log's own landed tic minus the leap tic: 100 vs 66), and
the distance 338-347, not "about 355" (4-5% short). **WORKS** (the README's 355 is a little high; 3 s vs 2 s reads 2.9 vs 1.9). **README FIXED 2026-11-27:** line 18 now says
"about 340 map units" (measured 338-347 above).

## Claims

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN/PARTLY) |
|---|---|---|---|
| Wrist cross: crossed hands, held 12 tics, toggles on; again off (12) | WORKS | C_sm2.log:73-78 (hands crossed ~t47, "wristcross t59: held ON at 25%"), 83 ("t108: held off") | |
| Slow motion key toggles (13) | WORKS | C_sm2.log:93-94 (`netevent rsm_toggle 2` "key t163: held ON"); 104 off | |
| Start with < 25 adrenaline: nothing starts (14) | WORKS | C_sm2.log:111 "refused: not enough adrenaline" (meter 0). Buzz/sound: CAN'T TEST (-nosound, no haptics log) | |
| Held: meter drains, full lasts 10 s, at zero it ends (15) | WORKS | C_sm2.log:95-105: 100 -> 90 -> ... -> 10 every 35 tics, "held off" at t512 = 349 tics after t163 | |
| Kill +12 (16) | WORKS | C_sm1.log:59-70: 9 kills, 0 -> 100 (capped); C_sm3.log:72: a 20-damage hit 0 -> 10 (half the damage) | |
| Near miss +4 (16, 28) | CAN'T TEST | not isolated: the round test's gains (C_sm3.log:236, 302) are the damage taken | |
| New game starts empty (17) | WORKS | C_sm1.log:59 "adrenaline 0" at map start | |
| Carries level to level (17) | CAN'T TEST | not run in this batch | |
| Crisis Dive (18) | WORKS | table above; stick right: C_sm1.log:114-116 + CTR, 437 u to the south (the right of a player facing east) | |
| Dive in the air: nothing (19) | WORKS | C_sm1.log:120-121 "refused: not standing on the ground". Ducked / deep water / no-jump map: not run | |
| Key while another slow motion runs: takes over, the other's time dropped (20) | WORKS | C_sm2.log:124-132: othermod pulse until t815; key t660 "held ON at 25%"; off t700; full speed by t740 | |
| Slow Me Too: your walking slows as the world (21) | WORKS | C_sm3.log:78-117 walk 4.75 u/tic at full speed; 122-161 1.19 u/tic at world 25% (x0.25) | |
| Aim, fire, reload at full speed (22) | CAN'T TEST | not measured in this batch | |
| Within 3000 units things slow, farther run at full speed (23) | WORKS | C_sm3.log:172-296 (CMT): far zombie (~3900 u) 56 u per 29 tics before and during the slow; near zombie 48 u before, 14.6 u during (x0.3) | |
| Sounds drop in pitch (23) | CAN'T TEST | -nosound | |
| Your flying shots fly at world speed and leave a pale wake (24) | PARTLY | frames/SlowMo/sm4_pistol_f50_rocket_wake_f65_f80.png: a rocket fired during held slow motion leaves a pale grey wake (f65, f80) | the wake is shown; the rocket's speed was not measured |
| Hitscan leaves a fading trail (25) | CAN'T TEST | the pistol shot (C_sm4 script C_V_TRAIL) has no log line proving it fired; no trail in frame f50 | |
| Monster hitscan becomes a visible round at 14 u/tic; hits do the shot's damage (26) | PARTLY | C_sm3.log:299-301: `RSQSM_Round` spawned t612 at -1288 -1429, hit the player t619 (~115 u in 7 tics: ~14-16 u/tic), "via RSQSM_Round ... 9" damage | flight and damage shown in the log; the round was not seen in frames sm4 f190-f215 (at this resolution) |
| Lean out of a round (27) | CAN'T TEST | not run in this batch | |
| Heavy hit: 75% in one tic, special attacker or from behind (29) | WORKS | C_sm3.log:311-315 zombie from behind, 80: "HIT FROM BEHIND" 3000 ms; 322-324 zombie in front, 80: "not fired: heavy, but nothing it needs"; 330-334 Baron in front: "HEAVY HIT: PAIN LORD" 3000 ms; 407 not while DOWN | |
| Barrel within 2 m, multi-kill, chain: 3 s (30) | WORKS | C_sm3.log:341-344 "barrel.near ... 3000 ms"; 356-358 "barrel.multikill ... 2 monsters ... 3000 ms"; 365-367 "barrel.chain ... 3000 ms" | |
| Auto cooldown 25 s after an automatic slow (31) | WORKS | C_sm2.log:176 "othermod t805: refused: automatic cooldown, 25.3 s left"; 224 same 15.8 s left; heavy hit fired with its own cooldown (C_sm3.log:315 "own cooldown") | |
| Blue adrenaline bar with a white tick; green countdown bar with the cause word (32) | WORKS | frames/SlowMo/sm4_bars_held_f45_autobar_barrel_f125_f140.png: blue bar + white tick left of Score's bar; green bar + "BARREL BLAST" | |
| DOWN: 1 HP, world 1/20, DEATH IN 9 / 6 / 3 s, target 15% larger with x1.5 health (33) | WORKS | C_sm3.log:402-421 ("world to 5%", "DEATH IN 9.0 s", target "x1.15 size ... health 90 of 60", CMON scale 1.15 hp 90); C_sm4.log:108, 140, 170 (9.0, 6.0, 3.0 s) | |
| Fall / crusher / own shot: no DOWN (34) | WORKS (own shot) | C_sm3.log:507 "NO DOWN (his own doing)". Fall and crusher: not run | |
| Move at a third, hits cannot kill (35) | WORKS | C_sm3.log:478 "crawl x0.33"; 429-430 a 100 hit while DOWN: health 1 -> 1 | |
| Crosshair on the target in sight; chevrons within 75 deg; an arrow at the edge farther round; grey world with red (36) | PARTLY | frames/SlowMo/dumptest_DOWN_target_crosshair_f70.png (crosshair + TARGET on the imp, red world); sm4_DOWN_panel_f360_side_chevrons_f495_behind_f645.png: target at 55 deg: chevrons leading left (f495) | target behind (150 deg, f645): a downward chevron stack with the target icon under the view centre, not an arrow at the edge of the view — **2026-11-27: NOT A CODE BUG, README wording (not changed, for the owner).** The code does what the owner designed: design/NEAR_DEATH.md "v3 off-view turn markers" (owner 2026-11-07 05:53-05:58): the target's icon "on a ring around your gaze at the edge of comfortable view (world space, no flat screen edge) ... Directly behind: at the bottom of the ring, pointing down/back"; the 07:50 LAYERS answer put those arrows on the HUD round the gaze. downhud.zs EdgeArrow draws them round the middle of the view at the mockup's distances (icon 110 px, arrow 150-218 px of the mockup's 1312 px view), and plate.zs Edge sets the direction to -90 (down) when the target is more than 150 degrees round. The code never drew an arrow at the edge of the view; the frame (target behind: the chevrons under the view centre, pointing down) is the designed look. README line 36's "an arrow at the edge of the view" is what is wrong; suggested wording: "Farther round, a turn marker on a ring round your gaze points the way to turn (straight behind: at the bottom, pointing down)" |
| Hurting the target buys time (37) | WORKS | C_sm3.log:425-426 "30 of 60 health -> +0.13 s" and VisualRewards' "+0.1s"; 435 | |
| Kill the target: get up 100/66/33%, invulnerable 5/3/1, slow 3/1.5/5, armour 100/66/33 (38) | WORKS | C_sm4.log:123, 155, 185 (100% inv 5 slow 3; 66% inv 3 slow 1.5; 33% inv 1 slow 5); armour 0 -> 100 with VisualRewards not loaded: C_smarm.log:72; with it loaded the bits bank pays instead (0 banked: C_sm3.log:441), as line 224 says | magazines: "no magazine" on plain Doom guns (not BD) |
| DEATH IN reaches zero: the killing blow (39) | WORKS | C_sm3.log:483-490: clock out -> the killing blow, caught by Score's starting life ("a Score life holds him", lives 1 -> 0) | |
| Wrist Cross Bursts: 4 s, 40% of the meter (40) | WORKS | C_sm2.log:270-275 "wristcross.burst ... 4000 ms at 25%", meter 100 -> 60 | |
| Adrenaline off: free, lets go after 6 s (41) | WORKS | C_sm2.log:278-283 key t2351, "trigger length t2561: held off" (210 tics = 6 s), meter unchanged 60 | |
| Reload by hand: 1.2 s (42) | CAN'T TEST | needs BD22 VR's hand reload; not run | |
| Close Call: 0.7 s (43) | WORKS | C_sm3.log:373-375 imp fireball at 500 u: "closecall t1550: started 700 ms" | |
| Grenade / over-under blast (44) | CAN'T TEST | Brutal Doom not loaded in the SlowMo runs | |
| Lower View: view to 40% (45) | WORKS | C_sm3.log:473-481 "down to 40% ... view 16.4 of 41.0" | |
| Colour Drain (46) | CAN'T TEST | frames sm4 f230-f270 (drain on) show no difference I can judge at this resolution | |
| `netevent rsm_state` prints the clock (47) | WORKS | every "slow motion: ..." line, e.g. C_sm1.log:59 | |
| Limits: dive 6 s max; Air Time 3 lands inside it at 5.9 s (298) | WORKS | Air Time 3: 203 tics = 5.8 s, landed (C_sm1.log:104) | |
| Limits: meter cost of a dive ~20 / 30 / 60 (299) | WORKS | 19 / 28 / 58 (table above) | |

## Counts
WORKS 28, PARTLY 3, CAN'T TEST 9, BROKEN 0 (NEEDS ROLL / TURN / MENU: none needed for the rows run).
