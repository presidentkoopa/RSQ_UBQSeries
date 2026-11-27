# Rig check: RSQ Grenade (2026-11-27, agent A)

Rig: `rig2`, `qz_hz 35`, Freedoom 2 + `TestRig/maps/rig01.wad`, `RSQ_Grenade` alone (N1-N3) from `rsq_ubqseries/pk3/`.
`rsqgn_debug 1` (`RSQGN` lines: pin, ring, teeth, squeeze, release speed, throw speed, fuse, flashes, booms). Quick Grenade was bound
to K and pressed with `rig_key K` (a real key event). The pin by teeth used the mouth point measured for the Tactical Rig's cigarette
(the hand at 0.06 m ahead of and 0.13 m under the headset). Logs and scripts: `design/rigcheck_2026-11-27/logs/A_N1..N3.log`,
`A_N*_script.txt`. Rig only, not headset. Haptic buzzes are not visible on the rig.
**Several of my scripted moves spoiled later checks** (the hand jumped between poses in one tic, which the mod rightly read as a
fast swing; a grenade dropped at my feet threw the player up); those rows are CAN'T TEST, not failures of the mod.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | New game: grenade (slot 9) and 3 grenades, not in the hand (12) | WORKS | A_N1.log:95-96 (`RSQGN_Ammo=3 RSQGN_Grenade=1`, ready Pistol) | Respawn not tried |
| 2 | Pick slot 9: in the hand; its trigger fires nothing (13) | WORKS | A_N1.log:257 (ready RSQGN_Grenade); no throw / pin line after its trigger press | |
| 3 | Grenade pickups in levels, 8 / 16 carried (14) | CAN'T TEST | | rig01 has no items to scatter beside; not run on a real map |
| 4 | Quick Grenade / +user1: pin 7, toss 15, out 17 tics at 45 u/tic; next press after 22 (15) | WORKS | A_N1.log:101, 123 (pressed t10, out t27 at 45.3 u/tic); the second press 3 tics later was not taken; 146 (next accepted at t43) | +user1 not pressed; pin/toss sounds at 7/15 not checked |
| 5 | Quick Grenade with none left: "No grenades" (16) | CAN'T TEST | | Not run |
| 6 | Quick Grenade with the pin out: nothing (17) | CAN'T TEST | | Not run |
| 7 | Other hand within 12 cm of the ring + its fire: ring taken (18) | WORKS | A_N1.log:392 (`ring taken ... other hand 4.2 cm from it`) | |
| 8 | Keep fire held, pull > 20 cm: pin out (19) | WORKS | A_N1.log:397-400 (`ring pulled (28.5 cm)`, `pin out ... by ring`) | |
| 9 | Fire held at the mouth 12 tics: pin out by teeth (20) | WORKS | A_N1.log:463-466 (`teeth ... for 12 tics`, `pin out ... by teeth`) | |
| 10 | Pin out, swing >= 2.2 m/s and let go: thrown at twice the hand's speed (21) | WORKS | A_N1.log:512-516 (release at 3.50 m/s, leaves at 7.00 m/s, full fuse) | Arc cap at 40 degrees not checked |
| 11 | Let go slower: spoon off, cooking, 3 s fuse (22) | WORKS | A_N2.log:189 (`spoon off ... cooking`) | |
| 12 | While cooking, press and let go: thrown however slowly, keeps the fuse left (23) | WORKS | A_N2.log:221-224 (`release (cooking) ... thrown`, `fuse 81 of 105 (cooked)`) | |
| 13 | Cook to the end: goes off at your body (24) | CAN'T TEST | | Spoiled: the previous grenade went off at my feet and threw the player, which the mod read as a 17 m/s swing (A_N2.log:369) |
| 14 | Flashes red with a tick every 16 tics down to every 2 (25) | WORKS | A_N1.log `flash thrown ... period 16` down to `period 2` (45 lines) | Flash colour not framed |
| 15 | Pin back in with the other hand near the ring (26) | WORKS | A_N1.log:427 (`pin back in`) | |
| 16 | Switch weapons while cooking: drops at the feet, goes off at fuse end (27) | WORKS | A_N2.log:656, 785 (`dropped at the feet ... (switched away with it lit)`, boom at the same spot t520) | Death case not tried |
| 17 | Switch with the pin out, spoon on: pin back in, none used (28) | CAN'T TEST | | Spoiled by my pose jump (thrown at 6.76 m/s, A_N2.log:879-883) |
| 18 | Alt fire with the pin in: next type, colour (29) | WORKS | A_N1.log:313, 352 (Frag -> Impact -> Incendiary); A_N3.log:141-193 (-> Freeze) | Colour not framed |
| 19 | Frag: 85 over 200 units, then 75 a tic later (30) | WORKS | A_N2.log:1040-1045 (two imps hit at t700, again at t701, both killed) | |
| 20-27 | Impact, Incendiary, Freeze, Stun, Smoke, Flash, Charm, Infight effects (31-38) | CAN'T TEST | A_N3.log:220-453 (a Freeze quick throw went off far from the imps, which kept moving) | Not shown in this pass |
| 28 | Shoot a thrown grenade: it goes off, skeet burst (39) | CAN'T TEST | A_N1.log (`shot ...: nothing set off` lines: my pistol shots missed) | Not shown |
| 29 | Throw the last grenade: main hand picks another weapon (40) | WORKS | A_N1.log:589 (0 grenades) then the trigger fires the Pistol (`shot ...` lines from t346) | |
| 30-32 | Barrels: blink and random explosion; chains grow; mega blasts (41-43) | CAN'T TEST | A_N2.log:1363, 1382 (my pistol hit a barrel for 10 and 5; it did not go off before the run ended) | Not shown |
| 33-45 | Option rows (Arc, Only in Slow Motion, Faster in Slow Motion, Your Fire Burns You, Alt Fire Changes Type Off, Frag Only, Teeth Off, Quick Grenade Off, Shoot Grenades Off, Grenades Off, Barrels Off) (44-54) | CAN'T TEST | | Not run in this pass |
