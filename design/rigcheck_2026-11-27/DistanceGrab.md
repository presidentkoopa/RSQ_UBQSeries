# Rig check: RSQ Distance Grab (DistanceGrab/README.md "How to play"), 2026-11-27, agent B

Rig only, not headset. Fixed rig (`/home/claude/rigdata/rig2`, `qz_aimroll 1` so a hand's roll reaches AttackRoll /
OffhandRoll: "palm out" is roll 90), Freedoom 2, `pk3/RSQ_DistanceGrab.pk3` (13:04 build), `rsqdg_debug 1` and
`rsqdg_trace 1` (its `[RSQDG]` lines), plus the test-only probe (`/home/claude/rigdata/probes/B/bprobe`). Arena
`TestRig/maps/rig01.wad` for D1-D10 and D14; Freedoom MAP01 (D11 doors, D12 switch) and MAP03 (D13 locked door) for doors,
since the arena has none. D10 adds `pk3/RSQ_Melee.pk3`. Logs and scripts: `design/rigcheck_2026-11-27/logs/B_D*.log` /
`B_D*_script.txt`, `B_K6.log`. Frames: `frames/DistanceGrab/`. Sounds, ticks, buzz and rumble cannot be checked (-nosound, no
haptics) and are left out of every verdict.

Rig notes:
- **The main (gun) hand's grip sends no key on this rig.** `qz_rgrip 1` gives no key event in ZScript's InputProcess;
  `qz_lgrip 1` gives key 443 (B_K6.log). Distance Grab reads the main grip by key code 446, so every main-hand grip action
  did nothing here (B_D7.log W2, B_D8.log W5). The rows below were shown with the off hand. Whether a Quest sends 446 for
  that grip is not known from here.
- A rig hand that stops dead reads as "no new pose" (aim.zs:188). A palm throw then waited its full 9 tics and dropped the
  barrel at 0 m/s (B_D2.log:6104-6160). With the arm slowing over 3 tics, as an arm does, it let go at the peak
  (B_D3.log:2173-2194). The palm-throw verdicts use the slowing stroke.
- Things the probe spawns are removed by its own `B_clear`, picked-up guns included; runs are set up so this does not
  touch a result.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | L14 Palm out: a blue beam, a dot where it lands, a faint cone | WORKS | frames/DistanceGrab/v1_idle_v2_lock.png (t35: blue beam, dot, faint octagon cone) | The cone's 12 deg and 512 units were not measured |
| 2 | L15 Palm at a pickup / gun / barrel in the cone, clear line: locked at once, green glow, green beam | WORKS | B_D1.log:241-243 (LOCKED Clip in the palm-out tic); v1_idle_v2_lock.png t45 (barrel glows green, beam and cone green) | Ties between kinds not tried |
| 3 | L16 Lock stays when pointing elsewhere; ends when the palm turns back, the thing is taken, or past 640 | WORKS | B_D1.log:297-380 (hand yawed 40 deg for 12 tics: no unlock); :1071-1078 (moved 894 away: "unlocked Clip -- out of range"); :757 (palm back) | |
| 4 | L17 Flick (wrist up 5 deg/tic, palm back in 1/5 s): flies on an arc at 22 m/s, 6-40 tics, end over end, faint green trail | WORKS | B_D1.log:391-393 (LAUNCHED, 192 units in an 8-tic path, about 24.7 m/s); frames/DistanceGrab/v3_flight_catch.png (barrel turning over, faint green motes) | |
| 5 | L18 Palm back without the flick: let go, nothing moves | WORKS | B_D1.log:756-757 ("let go of Clip (0.0 deg/tic, needed 5.0)"); :825 (clip still at -120 0) | |
| 6 | L19 Palm out again before it arrives: caught within 24 units, green bloom | WORKS | B_D1.log:436 ("caught and USED Clip"); B_D2.log:2378 (CAUGHT ExplosiveBarrel) | The bloom was not clearly seen (v3_flight_catch.png t60: one small green spot at the barrel) |
| 7 | L20 Palm away as it arrives: waits on the palm 4 tics, then drops | WORKS | B_D1.log:1477 ("arrived and was not caught -- dropped"); :1668 (clip on the floor under the palm, -309.8 8.5) | |
| 8 | L21 Catch a pickup: picked up at once | WORKS | B_D1.log:436 (Clip used) | Only ammo tried (health, armour, keys, powerups not) |
| 9 | L22 Catch a gun: into the hand that caught it | WORKS | B_D1.log:1810, 1905 (main hand: Shotgun, main switches); :2182-2194 (off hand: Chaingun raised) | The exceptions (melee, off-hand-only, two-handed) not tried |
| 10 | L23 Owned gun with full ammo / full ammo / unusable health: not taken, word, at your feet; off hand raises the owned gun | WORKS | B_D2.log:346-351 (AMMO FULL, at the feet); :840-854 (off hand: "yours is in your off hand", raised); :1368-1372 (ShellBox AMMO FULL); B_D1.log:3671-3675, 3987 (Stimpack HEALTH FULL, at the feet) | The floating word was not looked at |
| 11 | L24 Catch a barrel: carried about 30 cm ahead, spring, hangs lower when heavy, tips with the wrist | FIXED (was PARTLY) | Works: B_D2.log:2378, 2813-2861 (60 kg barrel 20 units ahead of the hand, base 25 below it; wrist 20 deg up lifts it 4.8). Fails: B_D9.log:757-761 then 1334, 1430 | After a walk-up grip refuses something (HEALTH FULL / AMMO FULL), the next barrel pulled in is not carried: it is dropped at your feet with a stale "HEALTH FULL" (default settings). Cause (code read): the walk-up refusal sets `refusedFull` (flight.zs:46) and nothing clears it until the next catch reads it (flight.zs:409-418); a barrel's catch reaches that check without going through TakeInto, which is where it is cleared (flight.zs:600) **FIXED 2026-11-27 (fix2):** the refusal is now cleared at the start of every catch (flight.zs:349-355). F2_D9.log:225-229 (walk-up Stimpack: HEALTH FULL, left), then :453 ("CAUGHT ExplosiveBarrel (60.0 kg)", carried, no word) and :496 (set down from the hand at 0.0 m/s) |
| 12 | L25 Carry something heavy: a 60 kg barrel leaves you at two thirds speed | WORKS | B_D3.log:222/319 (95.0 units in 20 tics empty) vs :1038/1198 (63.3 carrying): 0.67 | |
| 13 | L26 Palm back with the hand still: set down | WORKS | B_D2.log:3184, 3343 (released at 0.0 m/s, on the floor where it was) | |
| 14 | L27 Swing and roll the palm back: holds to the stroke's peak (at most 9 tics), leaves at stroke speed x arm/(arm+kg) x 2.5 | WORKS | B_D3.log:2173-2194 (palm back at 5.9 m/s, let go at the peak after 3 tics, 6.1 m/s); B_D2.log:4692 (grip throw: hand 5.9 -> barrel 4.9 m/s, the README's 0.8x) | Note: the two palm throws (both with the aim assist on a monster) left at about 1.0x the hand (6.1 from 5.9, 10.0 from 10.4), not 0.8x |
| 15 | L28 Throw within 12 deg of a monster: bends onto it, lobbed to come down on its middle | WORKS | B_D4.log:755-756, 938-939 (assist 4.9 deg, 253 units; 10 m/s throw hit the imp) | Note: a 6.1 m/s throw bent the same way but landed 90 units short (B_D3.log:2193, 2543) |
| 16 | L29 Thrown hit: half kg x v^2, 1 point per 15 J, none under 3 m/s; 20+ pains and shoves | WORKS | B_D4.log:938-939 (60 kg at 7.8 m/s: 1825 J / 15 = 122, BDMG 122, imp shoved vel 15.2) | |
| 17 | L30 Barrel thrown at 4 m/s or more: goes off where it first hits or lands | FIXED (was PARTLY) | Hits: B_D4.log:940 (on the imp), :2006 (on a wall). Lands: B_D3.log:2194 then 2543; :3487 then 3900 | Thrown at 6.1 m/s (36 deg up) and at 5.0 m/s (28 deg up), the barrels landed on the floor and stayed whole (hp 20). The blow is only in Impact, which needs the speed to halve in one tic (throw.zs:763); a lob that lands and slides does not do that **FIXED 2026-11-27 (fix2):** a thing that would go off (Barrel Blast reached at the throw, `impact explode`) now goes off on touchdown, the floor included (throw.zs:775-787, WouldGoOff throw.zs:654). The same two throws: F2_D3.log:1454 (6.1 m/s, 36 deg up) then :1623 ("went off (thrown 5.9, hit 6.3 m/s)"), :1691 (hp 0, dead, on the floor at -121 22, 90 units short of the imp); :2344 (5.0 m/s, 28 deg up) then :2467 (went off), :2687 (count 0). F2_D3h.log:285, 331-332 (the 5.0 m/s lob alone) and frames/DistanceGrab/F2_d3h_lob_goes_off_on_floor.png (t124 lands on the floor, t132 the barrel's death, t140 the blast on the floor). Hits unchanged: F2_D4.log:588-589 (imp), :1437 (wall); a barrel set down at 0 m/s does not go off (F2_D3.log:769) |
| 18 | L31 With RSQ Melee: the throw is Melee's, to the painted monster or the way it was thrown | WORKS | B_D10.log:1092-1093, 1192 (nothing painted: "the way it was hit", off on a wall); :2780, 2882-2936 (painted DoomImp: launched to it, off on it) | |
| 19 | L32 Walk-up: palm within 30 cm + grip: pickup used (gun into that hand), barrel carried; unusable left with the word | WORKS (off hand) | B_D7.log:805 (Clip taken); B_D8.log:2589-2591 (Shotgun into the off hand); B_D2.log:3909 (barrel carried); B_D7.log:2486-2490 (Stimpack: HEALTH FULL, left) | Main hand: nothing (B_D7.log W2, B_D8.log W5), because the rig's main grip sends no key (B_K6.log): CAN'T TEST on this rig |
| 20 | L33 Let go of the grip: a still hand sets down, a moving one throws | WORKS | B_D2.log:4041 (0.0 m/s, dropped); :4692 (4.9 m/s, thrown) | |
| 21 | L34 Grip pressed on a palm carry, or held as a pull arrives: the grip owns the carry | WORKS | B_D4.log:3109 ("the grip takes over the carry"); B_D6.log:1097 (grip held through the pull, palm out at arrival) then B_D6.log ROW O2 (palm back, still carried) | Grip held with the palm turned away does not catch (B_D4.log:4378), as L20 says |
| 22 | L35 Other palm on the carried thing: both hands carry it | WORKS | B_D4.log:3321 ("BOTH HANDS"), :3547 ("one hand" when it left) | "Half as heavy" not measured |
| 23 | L36 Swing a carried thing into a monster at 3 m/s or more: it hits by the throw rule | WORKS | B_D6.log:1331-1332 ("swung ExplosiveBarrel hit DoomImp at 3.4 m/s for 23") | |
| 24 | L37 Carried barrel between you and a fireball: it stops there | WORKS | B_D4.log:3794-3795 ("ExplosiveBarrel stopped DoomImpBall", the barrel took 3) | The barrel did not go off (3 of its 20) |
| 25 | L38 Walk away from a thing stuck behind a wall: let go after half a second, set down | WORKS | B_D4.log:5920-6079 (moved past the pillar: "lost ExplosiveBarrel -- held back 4.81 m" 18 tics later; set down) | |
| 26 | L39 Barrel in one hand, free palm at a monster: locked; holds within 24 deg and 3 s after | WORKS | B_D6.log:1622 ("LOCKED DoomImp (1.2 deg), the other hand holds a barrel"); :2178 ("no palm on DoomImp -- holds 3 s") | The green glow on the monster was not looked at |
| 27 | L40 Throw a barrel while a monster is locked: it flies to it, steered all the way | WORKS | B_D6.log:1848-2084 (thrown to the DoomImp 217 units off, steered 36 tics, hit at 7.7 m/s, went off) | Melee paint plus lock together not tried |
| 28 | L41 Hand within 7 units of a door, grip, raise the hand: the door follows, eased | WORKS | B_D11.log:284-363 (door 167: ceiling -64 -> -14.5 over the lift, 3 units a tic) | Use and palm variants not tried |
| 29 | L42 Let go at 40% open or more: it finishes opening by itself | WORKS | B_D11.log:363-374 (let go at 54%: opened to 28.0) | The close after its wait was not watched |
| 30 | L43 Let go below 40%: drops shut | WORKS | B_D11.log:878-909 (door 332: 28.9 -> 16.0, shut) | |
| 31 | L44 Throw the hand up as you let go: finishes from 15% | WORKS | B_D11.log:1789-1869 (door 721 let go at 22% with the hand thrown up: opened to 4.0) | |
| 32 | L45 Locked door without its key: nothing lifts, the game's locked message | WORKS | B_D13.log:209 ("Blue key needed for this door."), :124 and 481 (sector 247 stays 24.0) | |
| 33 | L46 Palm on a switch: used once, as Use | WORKS | B_D12.log:250 ("palm on switch line 839 (special 11): flipped") | The switch was one-shot, so "must leave before it can be used again" could not be shown |
| 34 | L47 Gun held two-handed: Distance Grab stands down until half a second after | WORKS | B_D5.log:1932 (standing down, hands 0.14 m apart), :1995 (palm refused), :2267-2285 (back; locks again) | |
| 35 | L48 Punch or move a hand at 2 m/s: that hand does not reach for 0.75 s | WORKS | B_D5.log:2505, 2525 (3.5 m/s: refused), :2808 (locks after) | |
| 36 | L49 Melee weapon in the hand: no reach, console line; bare fists reach | WORKS | B_D6.log:2812, 2944 (Chainsaw: refused; "Distance Grab: the main hand does not reach -- holding a melee weapon (Chainsaw)"); B_D5.log:3707 (Fist: LOCKED Clip) | |
| 37 | L50 A pull that meets a wall: it ends and the thing drops | FIXED (was BROKEN) | B_D6.log:426-504 (BTRK) | A clip pulled from behind the full-height pillar (Line of Sight off) flew through it: at t61-62 it was at (-138.5 255.8) and (-169.7 257.1), inside the pillar (x -176..-96, y 220..284), and was caught at t64. No "blocked" line. "Cannot arrive in time" not tried **FIXED 2026-11-27 (fix2):** the Arc path now moves in steps no longer than the body (flight.zs:1159-1195; TryMove tests only where a move ends, and the flight radius is 2). F2_D6.log:415 (LAUNCHED Clip behind the pillar), :439 ("lost Clip -- blocked on tic 3/9 at (-93 254 51)": the pillar's face is x -96), :441-552 (it stays at x -93.4 and falls to the floor, t60-t71; never caught). F2_D6u2.log:206 (the same alone, with frames): frames/DistanceGrab/F2_d6_pillar_pull_stops.png (t58-t72: nothing comes out of the pillar) |
| 38 | L51 Die or turn Distance Grab off: carried things are put down | WORKS | B_D5.log:4836/4908 (off: z 12 -> 0); :5205-5288 (die: z 12 -> 0) | "Pulls stop where they are" not tried |
| 39 | L52 Corpses On: corpses lock, pull, carry, throw like barrels | WORKS | B_D7.log:7410-7545 (dead imp locked, pulled, caught 100 kg); :8039 (set down) | Throw and "stops bullets" not tried |
| 40 | L53 Use On Catch Off: carried, not used | FIXED (was PARTLY) | Works alone: B_D8.log:428, 899-902 (CAUGHT Clip, carried, set down). Fails: B_D7.log:3827; B_D8.log:4362, 4684 | After a walk-up HEALTH FULL refusal, the next caught clip is dropped at your feet with a stale "HEALTH FULL" (same cause as row 11) **FIXED 2026-11-27 (fix2), same fix as row 11:** F2_D8.log:1854-1858 (walk-up HEALTH FULL), :2330 ("CAUGHT Clip (0.3 kg)"), :2646 (carried at z 27.3 in the hand, was on the floor at the feet), :2648 (set down); F2_D7.log:1538-1542 then :2580 (CAUGHT Clip) |
| 41 | L54 Lock Delay: amber while waiting, then green | WORKS | B_D7.log:4308 (locked 10 tics after the palm with delay 10); frames/DistanceGrab/v4_dwell_amber_green.png (amber t88, green t102, delay 20) | |
| 42 | L55 Flight Path Steer / Lob | WORKS | B_D7.log X3 BTRK (Steer: straight, 11.5 units a tic = 11.8 m/s); X4 BTRK (Lob: a parabola, top 47.6 units up) | |
| 43 | L56 Hit Stop: the monster freezes 3/4/6 tics | WORKS | B_D7.log:6413 ("hit-stop: DoomImp frozen 4 tics") | |
| 44 | L57 Line of Sight Off: a thing behind a wall can be locked and pulled; the pull still stops at the wall | FIXED (was PARTLY) | Locked and pulled: B_D6.log:386, 442. Sight On: not locked (B_D6.log:732-796). Not stopped: B_D6.log:426-504 | The pull went through the pillar (row 37) **FIXED 2026-11-27 (fix2), row 37's fix:** locked and pulled with Line of Sight off (F2_D6.log:356, 415), stopped at the pillar (:439); with Line of Sight on still not locked ("Clip is behind a wall (Line of Sight)") |
| 45 | L58 Walk Up Grab Off: the grip does nothing on a pickup | WORKS | B_D7.log:3416 (the clip still on the floor after the grip) | |

Counts at the check: WORKS 40, PARTLY 4, BROKEN 1. After fix2 (2026-11-27): WORKS 40, FIXED 5 (rows 11, 17, 37, 40, 44).

## Fixes, 2026-11-27 (fix2, owner: "Fix all")

Rebuilt `pk3/RSQ_DistanceGrab.pk3`; load-checked alone (F2_load_DistanceGrab.log) and on the Brutal Doom stack (F2_load_full.log:
only Brutal Doom's own two lines, as in B_L1.log). Runs: the B scripts unchanged (logs/F2_scripts/), same rig, same pk3 list.
Rig only, not headset.
- Rows 37 and 44 (pull through a wall). Cause: flight.zs StepPath moved the pulled thing with one `TryMove` a tic. TryMove tests
  only where the move ends, and a pulled thing flies 2 units wide at 20-30 units a tic, so from one side of the pillar's wall it
  landed in the pillar's empty middle, touching no line, then out the far side. Fix: the move is split into steps of the radius
  less one (as the engine's P_XYMovement does), each by TryMove; the first that fails ends the pull, "pull.blocked", and the thing
  drops there (flight.zs:1159-1195). The README was right.
- Rows 11 and 40 (stale HEALTH FULL). Cause: `refusedFull` ("TakeInto refused it this time") was set by the walk-up grip's
  TakeInto (near.zs:314) and only cleared by the next TakeInto; a caught barrel (not an Inventory) or a pickup caught with Use On
  Catch off never goes through TakeInto, so Catch read the stale refusal (flight.zs:417) and dropped it at your feet. Fix: cleared
  at the start of every Catch (flight.zs:349-355). The README was right.
- Row 17 (barrel lobbed onto the floor). Cause: Impact runs only when the speed halves in one tic (throw.zs:789-791); a lob
  coming down at a shallow angle keeps most of its speed as it slides. Fix: a thrown thing that would go off (thrown at Barrel
  Blast or more, MASSDEF `impact explode`, still standing) is impacted on the tic it touches down (throw.zs:775-787, WouldGoOff
  :654). Other thrown things keep the stop test only. The README was right.
