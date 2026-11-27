# Rig check round 2: RSQ FnF (Flash and Flare) (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

**Rig note (added later, round 2):** rig2's ini has `gl_lights=false`, and these runs did not turn it on, so no dynamic light (flare, torch, glow lights) was drawn in this file's frames. The light verdicts here come from the probes' reads of the lights (radius, count, colour), not from lit frames. The beam/cone models are not dynamic lights and do show.

Rows that round 1 (`/home/claude/rigcheck_ab/rigcheck_2026-11-27/FlashFlare.md`) left CAN'T TEST, now run. README line numbers are
today's `merge_main/FlashFlare/README.md` (they moved by about 2 since round 1).
Rig: `rig2`, `qz_hz 35`, Freedoom 2, map `R2MAP01` (test-only room from the R2 probe; next map itself, no intermission) or `MAP01`
for the scatter row. pk3: current main `merge_main/pk3/RSQ_FnF.pk3` (copied 14:45) alone; R2_F5 on the Brutal Doom stack
(brutal22test6 + BD22 VoxelPack + BD22 VR-Reloaded 3.0rc) + FnF. `rsqff_debug 1`. Test-only probes: `r2probe.pk3` (hands, inventory,
spawns, damage, monster states) and `r2ff.pk3` (`R2FF` lines: every flare burner with position, velocity, gravity, burn left, spent,
dark, lit; the flashlight's spot light radius and colour; the battery in permille from the mod's own `RSQFF_Battery.Permille`).
Off grip = `qz_lgrip` (key 443), off trigger = `qz_ltrigger`. Pocket at `L 0.15 1.32 -0.12`, clip at `L -0.17 1.38 -0.10`
(headset at 1.6 m; both answer, as round 1 found). Logs + scripts: `/home/claude/rigcheck_round2/logs/R2_F1..F7.log`. Frames:
`/home/claude/rigcheck_round2/frames/FlashFlare/`. Rig only, not headset; sounds and buzzes not checked.

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 1b | Come back after dying: topped up to 2 (14) | WORKS | R2_F3.log:818 (after death and respawn: `RSQFF_Ammo=2`) | Round 1 left the dying half untried |
| 2 | Box of flares: 6, carry 24; about 1 in 21 items, up to 2 boxes a map (15) | WORKS | R2_F1.log:71 (`scatter MAP01: 53 items rolled, 2 boxes`), 112-114; 156-193 (0 -> 6 walking over a box; give 40 -> 24) | |
| 3 | Look down at your chest: a flare at the pocket; the flashlight on its clip (16) | PARTLY | f4_chest_on_off.png t22 (red flare hanging at the pocket), t62 (Flares Off: no flare); f1_chest_light_throw.png t120/t140 | The flare is seen. The flashlight on its clip was not found in any frame looking down (straight, 25 and 30 degrees toward the off side), so that half is not shown |
| 5 | Grip while the engine steadies the main gun: waits, after 6 s dropped (18) | WORKS | R2_F1.log:266-464 (grip held 250 tics at the pocket, the main hand 21 cm away: `take t349: let go (the grip held the gun steady for 6 s)`), 523 (no flare taken) | |
| 6 | Grip at the pocket with none left: "No flares left" (19) | WORKS | R2_F2.log:70-82 (ammo 0, empty hand: `No flares left`, `the pocket is empty`) | |
| 10 | Lit flare: light radius 140, flicker every 4 tics, 60 s, fades over the last 2 (23) | PARTLY | R2_F1.log:672 (`radius 140`), 699 (`burnLeft 2067/2100` = 60 s); frame f1_chest_light_throw.png t560/t616 (flame and sparks at the burning end) | Radius and burn time shown; the flicker and the 2 s fade were not measured |
| 14 | Thrown flare: half gravity, tumbles, bounces off floors, slides, lies burning, light 12 above (27) | WORKS | R2_F1.log:798-949 (`grav 0.50`, vel z falls 0.5 a tic, bounce at t648 and t662, slides 5.7 -> 0, rests with `lightOn 1`); frame t640 (in flight, burning) | Tumble and the light's height not checked |
| 15 | Lit or spent flare into a monster: 4 damage, once a monster a flight, while faster than 2 u/tic (28) | WORKS | R2_F1.log:1080-1081 (`DoomImp took 4 ... via RSQFF_Flare`, one hit in that flight) | |
| 16 | Burn out: in the hand the spent flare falls, the hand gets back what it held; spent lies dark 10 s, then gone (29) | WORKS | R2_F4.log:378 (`burnt out in the hand t323`), 402 (spent on the floor, dark), 710 (still there t665), 744 (gone at t700: 10.6 s) | |
| 17 | More than 3 burning: only 3 give light, the oldest lying goes dark, the one in the hand last (30) | WORKS | R2_F1.log:1294 (`budget: cap 3, the oldest (lit t518) goes dark`), 1339 (4 burning, 3 giving light), 1342-1345 (the oldest `dark 1`, the held one lit) | "Lights again when one burns out" not shown |
| 18 | Take another weapon into the off hand, or die, with a flare out: unlit back to count, lit falls burning (31) | PARTLY | R2_F2.log:1034-1035 (died with an unlit flare: `back ... (10)`); R2_F3.log:749-758 (died with a lit one: `let fall`, lies burning, `lightOn 1`) | Dying: both halves work. Taking another weapon into the off hand was not driven (no off-hand weapon pickup on plain Doom) |
| 19 | Leave the level with a flare in the hand: unlit back in the count, lit used up (32) | WORKS | R2_F2.log:790-800 (unlit: 10 -> 11 on the next map), 921-932 (lit: `the lit flare carried over a level change is used up`, count stays 10) | |
| 24 | Grip at the clip with the flashlight in the hand: back on the clip (36) | WORKS | R2_F1.log:3086 (`torch back t1112: on the clip again`) | Round 1's pose was at the wrong height |
| 25 | Take a flare while holding the flashlight: flashlight put away, comes back as it was (37) | WORKS | R2_F1.log:2085-2086 (`take ... (had RSQFF_Torch)`, `torch put away`), 2110, 2144 (flare back: the off hand holds `RSQFF_Torch` again, still off: the next pull turns it on, 2160) | |
| 27 | Flashlight on: drains 3 min from full; meter of 10 steps; dims at half, narrows and flickers lower, empty clicks off (39) | WORKS (meter not framed) | R2_F1.log:2175-2732 (998 -> 950 -> 903 permille in 300-tic steps: full in 6250 tics = 3.0 min); R2_F6.log (1-min battery): meter steps 9..1 (395-2099), `light x0.90` at step 5 (1264), `inner x0.59 outer x0.89` and varying values at step 2 (1883-2085), 2338-2340 (`EMPTY: the flashlight switches itself off`) | The meter drawn on the body and its blink were not framed |
| 28 | Off: recharges as fast; under 1 s of light it will not switch on (40) | PARTLY | R2_F1.log:2732-3030 (off 300 tics: 903 -> 951, the same rate) | The refusal under 1 s was not reached (it had 3 s when pressed, R2_F6.log:2456-2461) |
| 29 | Kill a monster in the lit beam: +5% (41) | WORKS | R2_F1.log:3053 (`+5% (a kill in the beam: DoomImp): 94.9% -> 99.9%`) | |
| 30 | Next level with the flashlight: charge kept, in hand stays in hand switched off (42) | WORKS | R2_F7.log:1107 (511 permille), 1119-1125 (next map: 510, off hand still `RSQFF_Torch`, off) | |
| 32 | Brutal Doom: lit flare into a small monster: Fire hit, burns 5 s, 3 Fire every 6 tics (43) | WORKS | R2_F5.log:374-375 (`RifleZombie took 4 (Fire)`, `set on fire`), 378-472 (3 Fire every 6 tics from `RSQFF_OnFire`), 473 (it died of it) | |
| 33 | Light It By: Strike: the trigger does nothing (44) | WORKS | R2_F3.log:144-213 (trigger pulled after the take: no light; the flick: `struck by a flick`, 217) | |
| 34 | Light It By: Trigger: the flick does nothing (45) | WORKS | R2_F2.log:1559-1654 (flick: no light; the trigger: `struck by the trigger` t505) | |
| 35 | Shoot Out Flares: On (46) | WORKS | R2_F2.log:1824 (`shot out t654: DoomPlayer (10 Hitscan damage)`), 1833 (that flare `spent 1`) | |
| 36 | Refill Each Level: topped to 4 (47) | WORKS | R2_F2.log:1837-1888 (1 flare, next map: `RSQFF_Ammo=4`) | |
| 37 | Battery Never Drains On, or Battery 0: no drain, no meter (48) | WORKS | R2_F2.log:1941, 2140 (Never Drains: `batt -1`, the mod's "no battery in use"), 2235 (Battery 0: still -1) | |
| 38 | Beam Colour Random: one of six, never the last (49) | WORKS | R2_F2.log:2267-2433 (colours 21, 24, 22, 20 at four switch-ons, each different from the one before) | |
| 39 | Beam Quality PCVR / High: 640 / 896, two layers, dust (50) | WORKS (range) | R2_F2.log:2490 (`range 640`), 2548 (`range 896`); frame f3_beam_hot_high.png t170/t185 (High: a denser cone than Quest's at t100) | Two layers and dust not told apart at 400 px |
| 40 | Beam Hotspot: On (51) | WORKS | R2_F3.log:908-909 (`RSQFF_TorchHot` where the beam lands); f3_beam_hot_high.png t140 (a brighter patch at the end of the beam) | With the hand level (round-2 first try, R2_F2.log:2643) the beam reached nothing within 2.5 x its range, so no spot: as designed |
| 41 | Beam Look DarkDoomZ, Spill Light (52) | WORKS | R2_F2.log:2759 (Halogen: spot r512 rgb 255 241 224 plus `RSQFF_TorchSpill r384`), 2813 (spill off: the spot alone) | |
| 42 | Bones Drop Battery Bits (53) | CAN'T TEST | | Legion of Bones is not on this machine |
| 43 | Flares Off: grip at the pocket nothing; none at the pocket; an unlit flare in hand goes back (54) | WORKS | R2_F2.log:2916-2925 (unlit flare back to the count 3 -> 4, then the grip at the pocket takes nothing); f4_chest_on_off.png t62 (no flare at the pocket) | |
| 44 | Flashlight Off (55) | WORKS | R2_F2.log:2815 (`torch put away (dead or switched off)`), 2825 (grip at the clip: off hand stays empty) | |
| 45 | Off Grip Keys (56) | WORKS | R2_F2.log:2970 (keys "37": the real off grip takes nothing), 3008 (key 37 = K pressed with `rig_key K down/up`: `take`) | |
| 46 | Pocket / clip sliders (57) | WORKS | R2_F2.log:3106 (Pocket Forward 0.30: the old spot does nothing), 3117 (the new spot 0.30 ahead: `back`), 3159 (`take`) | Clip sliders not tried |

Counts (this round, 32 rows): WORKS 26, PARTLY 5 (#3, #10, #18, #28 parts not shown; none seen failing), BROKEN 0, CAN'T TEST 1 (#42, Legion of Bones missing).
Note: no PARTLY here is a failure seen; each is a part of the row the rig did not reach.
