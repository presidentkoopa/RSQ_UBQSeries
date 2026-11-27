# Rig check: RSQ FnF (Flash and Flare) (2026-11-27, agent A)

Rig: `rig2`, `qz_hz 35`, Freedoom 2 + `TestRig/maps/rig01.wad`, `RSQ_FnF` alone (F1, F2) from `rsq_ubqseries/pk3/` (no Tactical Rig,
so FnF's own pocket and clip). `rsqff_debug 1` (`RSQFF` lines). The off grip is the real fake button (key 443); the off trigger is
the fake left trigger (Shift, `+oh_attack`). **The pocket and the clip are measured from the headset's eyes** (1.6 m on the rig):
the pocket answered at 0.12 ahead / 0.15 toward the main hand / 0.28 under the headset, and did not at the same offsets from the
pawn's eye height (1.45 m) (A_F1.log:111 vs 411: `off hand 0.15 m from the pocket (needs 0.11)`). Logs and scripts: `design/rigcheck_2026-11-27/logs/A_F1.log`, `A_F2.log`,
`A_F*_script.txt`. Rig only, not headset. Buzzes are not visible on the rig; lights and flames were not framed in this pass.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | New game: 2 flares (12) | WORKS | A_F1.log:91 (`RSQFF_Ammo=2`) | Topping up after death not tried |
| 2 | Box of flares in a map: 6, max 24 (13) | CAN'T TEST | | No items in rig01 to scatter beside |
| 3 | A flare hangs at the pocket, the flashlight on its clip (14) | CAN'T TEST | | Not framed |
| 4 | Off grip within 11 cm of the pocket: unlit flare, one fewer (15) | WORKS | A_F1.log:111; A_F2.log:109 (`take: a flare in the off hand ..., 1 left in the pocket`) | |
| 5 | Grip while the engine steadies the main gun: waits, 6 s drop (16) | CAN'T TEST | | Not run |
| 6 | Grip at the pocket with none left: "No flares left" (17) | CAN'T TEST | A_F2.log:317 (0 flares, but a lit flare still in hand) | Not reached cleanly |
| 7 | Unlit flare, grip at the pocket again: back, count +1 (18) | WORKS | A_F2.log:134 (`back: in the pocket again (2)`) | |
| 8 | Unlit flare + trigger: lights, 24 tics of sputter (19) | WORKS | A_F1.log:256 (`light: struck by the trigger, burns 60 s`) | Sputter / sparks not framed |
| 9 | Flick down at 1.4 m/s (down share 0.6) more than 8 tics after taking: lights (20) | WORKS | A_F2.log:231-235 (`strike: 2.63 m/s down ... needs 1.40`, `struck by a flick`) | |
| 10 | Lit flare: light 140, flicker, 60 s, fade (21) | CAN'T TEST | | Not framed / not timed |
| 11 | Hold trigger, swing, let go at 2.2+: thrown at 4x the hand's speed, 0.35 arc (22) | WORKS | A_F1.log:333-336 (release at 3.60 m/s; flight `vel (14.0 0.0 4.9)` a tic = 4 x 3.6 m/s ahead, 0.35 of it up) | |
| 12 | Let go slower than 2.2: stays in the hand (23) | WORKS | A_F1.log:261 (release at 0.00 m/s, no throw line) | |
| 13 | Grip with a lit flare: nothing (24) | WORKS | A_F2.log:309 (grip at the pocket with the lit flare: still `RSQFF_Held`) | |
| 14 | Thrown flare: half gravity, tumbles, bounces, slides, lies burning (25) | PARTLY | A_F1.log (`rsqff/bounce` sounds at t236, t240 after the throw) | Bounces heard in the sound log; the rest not framed |
| 15-20 | Monster hit 4 damage; burn-out; 3 lit at most; switch/die with a flare; level change (26-31) | CAN'T TEST | | Not run |
| 21 | Off grip within 8 cm of the clip: flashlight in the off hand, on (32) | WORKS | A_F1.log:515-517 (`torch take: the flashlight in the off hand`, `on (... range 448 ...)`) | |
| 22 | Trigger with the flashlight: off / on (33) | WORKS | A_F1.log:597, 626 | |
| 23 | Lit flashlight: spot light 448 units, Warm White, cone (34) | PARTLY | A_F1.log:517 (`range 448`, size 10/22 degrees, colour 20) | Settings logged; beam and cone not framed |
| 24 | Grip at the clip with the flashlight: back on the clip (35) | CAN'T TEST | | My grip was not at the clip (`torch grip ... 0.38 m`): not shown |
| 25 | Take a flare while holding the flashlight: flashlight put away, comes back (36) | CAN'T TEST | | Not run in that order |
| 26 | Grip at the clip while holding a flare: nothing (37) | WORKS | A_F2.log:334, 452 (`torch: the off hand holds a flare`) | |
| 27-31 | Battery drain / recharge / kill refill / level carry (38-41) | CAN'T TEST | | Not run |
| 32 | Brutal Doom: a thrown lit flare sets small monsters burning (42) | CAN'T TEST | | Not run |
| 33-48 | Option rows (Light It By, Shoot Out Flares, Refill, Never Drains, Random colour, Quality, Hotspot, DarkDoomZ look, LoB bits, Flares Off, Flashlight Off, Off Grip Keys, pocket/clip sliders) (43-58) | CAN'T TEST | | Not run in this pass |
