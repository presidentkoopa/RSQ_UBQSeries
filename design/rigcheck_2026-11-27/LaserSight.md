# Rig check: RSQ LaserSight (LaserSight/README.md "How to play"), 2026-11-27, agent B

Rig only, not headset. Fixed rig (`/home/claude/rigdata/rig2`, `qz_aimroll 1`), arena `TestRig/maps/rig01.wad`,
`pk3/RSQ_LaserSight.pk3` (13:04 build), `rsqls_debug 1` (its `[RSQLS]` lines), plus the test-only probe
(`/home/claude/rigdata/probes/B/bprobe`). The probe's `BLS` lines ask the mod's own service every tic: `live` is
`laser.active` and `beam` is `laser.beam`, main hand then off hand. L1 and L2 run on the Brutal Doom stack (brutal22test6 + BD22
VoxelPack + BD22 VR-Reloaded 3.0rc), which gives the measured guns. The probe raises `RSQ_Off_Rifle` into the off hand
(`B_offraise`, the same calls Distance Grab uses). L2 adds `pk3/RSQ_GunCards.pk3` for the watch check. L3 and L4 are plain
Freedoom guns. Floor textures and the room's light were changed by the probe (`B_ftex`, `B_light`). Logs and scripts:
`design/rigcheck_2026-11-27/logs/B_L*.log` / `B_L*_script.txt`. Frames: `frames/LaserSight/`, looked at zoomed.

Rig note: the rig shows the guns as flat sprites at the bottom of the view. These hide whatever is drawn right beside the
gun, such as the "At Gun" range readout. The beams are 1-2 pixels wide at 360 pixels.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | L14 Measured gun: beam from the muzzle, fading over 3 m, stops at what it hits; a dot; main red, off green | WORKS | frames/LaserSight/l1_ab_zoom.png (t40 red beam and dot from the main Rifle; t84 green from the off-hand RSQ_Off_Rifle too); B_L1.log:120, 205 (both guns resolved, "beam row ... shot line found") | The 3 m fade was not measured |
| 2 | L15 Any other gun: no beam, only the dot | WORKS | B_L3.log:127 (plain Pistol: live 1, beam 0); l3_pistol_dot_perslot.png t40 (dot, no beam) | |
| 3 | L16 Melee weapon / not a gun: no beam and no dot on that hand | WORKS | B_L1.log:151 (BD off hand holding rsq_hands: live 0) | |
| 4 | L17 Nothing in a hand: nothing drawn on that hand | WORKS | B_L3.log:127 (plain Doom off hand empty: live 0) | |
| 5 | L18 Dot on a wall / floor / ceiling: painted flat, same size at any range, bloom 1.8x, a real light | WORKS | l2_glow_both_off_bloom_light.png t300 (dot with bloom on the wall); l4_surface_nukage_metal.png t40 (on the floor) | "Same size at any range" and the light not measured |
| 6 | L19 Sky / nothing within Trace Range: no dot, beam still drawn | WORKS | l2_range_enemyonly_dotrange.png t62 (Trace Range 100, wall 300 away: beams drawn, no dots) | The arena has no sky. Shown with the Trace Range set short |
| 7 | L20 Dot on a live hostile: on its body, 1.25x, pulsing 12% at 2.2 Hz; beam 1.35x brighter | WORKS | l1_c_imp_pulse.png (t95-t103: the dot on the imp grows and shrinks) | The 1.35x beam not measured |
| 8 | L21 Muzzle closer than 10 cm: the beam goes, the dot stays | WORKS | B_L1.log:908 (gun pushed toward the step face: beam 0, live 1) | Note: pushed on into the wall, the beam came back (B_L1.log:915, t369-388) and went again on the way out (:953) |
| 9 | L22 Pointed down more than 55 deg: that hand's laser off | WORKS | B_L1.log:350 then 365 (main off t110-117 at pitch -40, back after); l1_d_bright_dark.png t112 | |
| 10 | L23 Switch weapons: main laser off from the ask until done | WORKS | B_L3.log:279 then 347-348 (plain Doom: off t62-76, back when the Shotgun is up) | On Brutal Doom the switch is instant (B_L1.log:638, 653; l1_bd_switch.png: the shotgun is up the next frame), so there is nothing to hide |
| 11 | L24 Firing a measured gun: the beam keeps its last pose for 35 tics; then a frame with no measurement (reload) hides it; the dot stays | WORKS (log) | B_L1.log:523 (beam 1 all through 8 tics of Rifle fire) | The kept pose and the hide on reload (Only When Ready off) were not looked at |
| 12 | L25 Watch check: the laser goes off on a hand whose gun is not aimed within 40 deg of the view | WORKS (log) | B_L2.log:1412 then 1428 (off hand raised, yawed 70 deg, rolled 90: off hand's laser off t628-637; main stays on) | Only one of three tried poses read as a watch check (roll +90); roll -90 did not |
| 13 | L26 Off hand's gun steadied two-handed: its laser off | WORKS | B_L1.log:754 (off hand live 0 from t288), :776 (twohand 1), back at t308 | The README says only PC VR sets the mark; this rig sets it |
| 14 | L27 Bright room: beam at 35% of the dark | WORKS (visual) | l1_d_bright_dark.png (t131 light 255 vs t138 light 40: the beams are much stronger in the dark) | The 35% not measured |
| 15 | L28 Dot on nukage etc.: swims 18%, 75% brightness | WORKS | l4_surface_nukage_metal.png (t49-t61 on NUKAGE1: dimmer, size changes tic to tic) | |
| 16 | L29 Dot on metal: bloom and light 1.5x wider | WORKS | l4_surface_nukage_metal.png t72 (METAL: wider bloom than the plain floor at t40 / t84) | |
| 17 | L30 Grenade launcher fired once with fire held: learned; the beam bends along the path, 24 dots, the dot where it lands | WORKS | B_L2.log:1564 ("LEARNED GrenadeLauncher ... grav 0.80"); l2_arc_zoom.png (t755: the dot lower in the scorch mark than the straight line's dot with the arc off at t782) | The 24 path dots cannot be told apart at this size |
| 18 | L31 Die: every beam, dot, arc and readout hides | WORKS | B_L1.log:1093 (t421 after `kill`: live 0 0, beam 0 0) | |
| 19 | L32 Show on Melee: a dot only on a melee / not-a-gun hand | WORKS | B_L2.log:236 (off hand rsq_hands with Show on Melee on: live 1, beam 0) | |
| 20 | L33 Colour on Target: dot and beam yellow on a hostile | WORKS | l2_imp_colour_tighten_head.png t120 (yellow dot and beam) | |
| 21 | L34 Lock Tighten: the dot smaller on a hostile, still pulsing | WORKS | l2_imp_colour_tighten_head.png t135 (small dot) | The pulse at this setting not looked at |
| 22 | L35 Headshot Reaction, pulse: dot and beam pulse to white | WORKS | l2_imp_colour_tighten_head.png t150, t153, t156 (pink, white, red) | |
| 23 | L36 Headshot Reaction, no pulse: white and stays | WORKS | l2_imp_colour_tighten_head.png t170 (white dot and beam) | |
| 24 | L37 Dot Only on Enemies: no dot elsewhere | WORKS | l2_range_enemyonly_dotrange.png t190 (beams, no dots on the wall) | |
| 25 | L38 Dot Range Limit: no dot past it | WORKS | l2_range_enemyonly_dotrange.png t205 (limit 100, wall 300: no dots) | |
| 26 | L39 Show Range: digits by the gun or over the dot | WORKS (was PARTLY: At Gun not seen) | At Dot: l2_readout_zoom.png t235 (digits above the red dot) | At Gun: CAN'T TEST. Nothing changed in the frame between readout off and At Gun (pixel diff, t220 vs t250) because the rig's flat gun sprite covers that spot **Re-checked 2026-11-27 (fix2), no code change:** with the rig's flat gun sprites hidden (`r_drawplayersprites 0`, BD stack), At Gun draws "8.4 m" beside the main hand (frames/LaserSight/F2_l2bd_readout_at_gun.png and _zoom.png t78; off at t66); with the hand raised it follows the hand ("8.3 m", t98); readout off, gone (t110). F2_L2bd.log:223-344 |
| 27 | L40 Spread Ring after three shots | WORKS | l2_spread_ring.png (t520, t530: a red ring round the dot after the Rifle fired) | |
| 28 | L41 Only When Ready: off while reloading / switching | WORKS | B_L2.log:1228 then 1307 (`+reload`: main off t534-573) | |
| 29 | L42 Infrared Only: shows only with the goggles' power | WORKS | B_L2.log:986 (no goggles: live 0 0), :1020 (after `give Infrared`: 1 1) | |
| 30 | L43 Colour Mode Single: both hands one colour | WORKS | l2_colours_cycle_sparkle.png t250 (both beams red) | |
| 31 | L44 Colour Mode Beam Dot: each dot its own colour | WORKS | l2_beamdot_sparkle_zoom.png t265 (blue and yellow dots, red and green beams) | |
| 32 | L45 Colour per Slot: the laser takes the slot's colour | FIXED (was BROKEN) | B_L3.log P2 (plain Pistol, slot 2: dot pixels the same before and after turning it on: 255 161 86 / 220 116 87); l2_perslot_shotgun.png t600 (BD Shot_Gun, slot 3: still red, not yellow) | No change on either gun. Likely cause (code read): sight.zs:553 reads `w.SlotNumber`, which is -1 unless the weapon class sets `Weapon.SlotNumber` (engine default, weapons.zs:118). Doom's and Brutal Doom's guns get their slots from game info / KEYCONF `setslot`, so the per-slot colour never applies **FIXED 2026-11-27 (fix2):** the slot is now asked of the player's own weapon slots, `p.weapons.LocateWeapon` (sight.zs:550-561, used at :577); the class's SlotNumber is only the fallback. Plain Pistol (F2_L3.log:179, P2): the dot's brightest pixel 255 161 86 (red, per slot off, t44 / t62) -> 255 255 53 over orange (slot 2 ff 80 10, t50 / t56): frames/LaserSight/F2_l3_pistol_perslot_zoom.png. BD Shot_Gun (F2_L2bd.log:481-530): red beam and dot at t166, yellow (slot 3 ff e0 20) with per slot on at t178, red again at t190: frames/LaserSight/F2_l2bd_shotgun_perslot_zoom.png |
| 33 | L46 Cycle Colours: hues run round, hands half a turn apart | WORKS | l2_colours_cycle_sparkle.png t278, t285, t292 (colours change, the two hands differ) | Rate not measured |
| 34 | L47 Beam Sparkle: a small spark now and then | CAN'T TEST | Pixel diffs near the beams, tic to tic: sparkle on 0-1 changed pixels, sparkle off 0-2 (B_L2 t299-317 vs t244-257 and t320-333) | One-particle sparks cannot be told from noise at 360 px |
| 35 | L48 Arc With Beam Off: only the dots, no beam | WORKS | B_L2.log:1682 then 1714 (GrenadeLauncher: beam 0, live 1 t759-772) | |
| 36 | L49 Grenade Arc Off: the plain straight beam | WORKS | B_L2.log:1714 (beam back); l2_arc_zoom.png t782 (straight beam, dot above where the arc's was) | |
| 37 | L50 Aim Down Off 0: on at any angle | WORKS | B_L2.log:1055 then 1059 (pitch -40: off until Aim Down Off set 0, then on) | |
| 38 | L51 Dot Glow Off / Bloom / Light | WORKS | l2_glow_both_off_bloom_light.png (t325 off: bare dot; t340 bloom; t355 light: no bloom) | The light itself not distinguishable on the wall |
| 39 | L52 Dot Lead: the dot drawn ahead of the hand's movement | WORKS (measured) | B_L2 frames t487-497: with Lead 6 the dot's screen x ran past its resting place (266 vs 248 px) at the end of a 3 deg/tic sweep; the same sweep back with Lead 0 stopped at its rest (176 -> 172.8) with no overshoot | |
| 40 | L53 Show Beam Off: dot only | WORKS | B_L2.log:822 (beam 0 0, live 1 1); l2_beamoff_dotoff.png t370 | |
| 41 | L54 Show Dot Off: beam only | WORKS | l2_beamoff_dotoff.png t385 (beams, no dots) | |
| 42 | L55 Main Hand / Off Hand Off: nothing on that hand | WORKS | B_L2.log:884 (main off: 0 1), :917 (off off: 1 0) | |
| 43 | L56 Laser Sight Off: nothing drawn | WORKS | B_L2.log:953 (0 0, 0 0) | |

Counts at the check: WORKS 40, PARTLY 1, BROKEN 1, CAN'T TEST 1. After fix2 (2026-11-27): WORKS 41 (row 26 re-checked, drawn), FIXED 1 (row 32), CAN'T TEST 1.

## Fixes, 2026-11-27 (fix2, owner: "Fix all")

Rebuilt `pk3/RSQ_LaserSight.pk3`; load-checked alone (F2_load_LaserSight.log) and on the Brutal Doom stack (F2_load_full.log).
Rig only, not headset.
- Row 32 (Colour per Slot). Cause: sight.zs ColorOf read `w.SlotNumber`, which is -1 unless the class itself sets
  `Weapon.SlotNumber`; Doom's guns take their slots from the game info, Brutal Doom's from KEYCONF `setslot`. Fix: SlotOf asks the
  player's own weapon slots (`p.weapons.LocateWeapon`), the class's number only as a fallback (sight.zs:550-561, :577). The
  README was right.
- Row 26 (At Gun). Re-checked with the gun sprites hidden: it is drawn by the gun. No change.
