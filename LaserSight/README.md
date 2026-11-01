# RSQ Laser Sight

A laser from each gun's own barrel, in either hand, with a dot where the shot will land. The beam is
drawn on the gun's model, so it stays on the barrel at headset frame rate. The dot follows Brutal Doom VR
2.0's real shot line, shows a grenade launcher's arc, and reacts to monsters and surfaces. Part of the
Radiant Silvergun Quest series, for stock QuestZDoom 17.3 (script only, no engine changes). It replaces
the laser sight bundled with QuestZDoom; none of that one's code is used.

## Load order

```
doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3
          -> BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> RSQ_LaserSight.pk3   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** loads (Brutal Doom classes are looked up by name). You get the dot
  only, from the grip along your aim. The beam needs a measured gun model, and the beams were measured
  from Brutal Doom Quest's guns, so sprite guns (stock Doom's) have no beam. *Follow Brutal Doom VR Shots*
  does nothing without Brutal Doom VR 2.0.
- **Other RSQ pk3s needed:** none. It works alone.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Laser Sight.
- **Buttons to bind:** none needed; both lasers are on by default.
- **Optional toggles:** Customize Controls -> section "RSQ Laser Sight" -> "Laser on/off (main hand)" and
  "Laser on/off (off hand)". The same two are on the mod's *Controls* page as "Toggle Main Hand" /
  "Toggle Off Hand". No default binds (on purpose).

## What to do in VR

- **Aim:** hold a gun. The beam comes from its muzzle; the dot sits where the shots go.
- **Lower the gun:** point it down past 55 deg. The laser goes off. Raise it, it comes back.
- **Switch weapons:** the laser is off while the gun is switched or holstered.
- **Melee:** fists, chainsaw, saber, shield and empty hands show no laser.
- **Two-hand a rifle (SteamVR):** the off-hand laser stands down while the engine steadies the gun.

## Features

Rows are on the front page unless a page is named. "On" = on by default (CVARINFO); "Option" = off by
default.

| Menu row | Default | What it does |
|---|---|---|
| Laser Sight | On | The whole mod. |
| Main Hand / Off Hand | On | Each hand's laser. |
| Show Beam | On | The beam from the muzzle. |
| Beam Look | Standard | Subtle / Standard / Bold (fade length, brightness, daylight). |
| Show Dot | On | The dot where it lands. |
| Dot Size | Standard | Small / Standard / Large. |
| Dot Glow | Bloom and Light | Off / Bloom / Light / Bloom and Light. |
| Colour Mode | Per Hand | One Colour / Per Hand (main red, off green) / Beam and Dot. |
| Main Hand Colour / Off Hand Colour | red / green | Colour pickers. |
| Show on Melee | No | Show the laser on melee weapons and empty hands. |
| Only When Ready | No | Hide while switching or reloading. |
| Dot Reacts to Surface (water, metal) | On | The dot swims on water, slime, lava and blood; it glints on metal. |
| Follow Brutal Doom VR Shots | On | With Brutal Doom VR 2.0, the dot follows its muzzle and bore (its guns fire 3.85 deg left and 3.36 deg up of the controller, parsed from its code). |
| Off When Pointed Down Past (deg, 0 = never) | 55 | Laser off when the gun points down past this, or while switching. |
| Infrared Only | Option | Only visible through light amplification goggles. |
| More Colours: Main Hand Dot / Off Hand Dot | red / green | Dot colours for *Beam and Dot* mode. |
| More Colours: Colour per Slot | Option | A colour per weapon slot (Slot 1 to Slot 0 pickers). |
| More Colours: Cycle Colours | Option | The colour cycles through hues. *Dot Cycles Too* is on. |
| Targets and Extras: Target Lock | On | On a live monster the dot grows and pulses. |
| Targets and Extras: Target Colour Change | Option | The dot turns the target colour on a monster. |
| Targets and Extras: Headshot Reaction | Option | The top fifth of a monster turns the dot the headshot colour (pulse on). |
| Targets and Extras: Grenade Arc | On | A grenade launcher shows its arc and landing spot, once it has fired once. |
| Targets and Extras: Arc With Beam | Option | Keep the straight beam as well as the arc. |
| Targets and Extras: Spread Ring | Option | A ring at the dot showing this gun's spread (off since 10-29, owner's call). |
| Targets and Extras: Show Range | Off | Range readout: Off / By the Gun / At the Dot. *Units*: Metres / Feet / Map Units. |
| Controls: Toggle Haptics | On | A tick in the hand when you toggle a laser. |
| Tuning and Debug: Reset All | - | Resets every Laser Sight setting. |

Every other row under *Tuning and Debug* is a number for the features above. The arc-learner log
(`rsqls_debug`) is not on the menu.

## Test it

Items marked **(not yet headset-confirmed)** were built on 2026-10-30 or later and only ran on the
simulated rig.

1. Load the pack. Options -> Radiant Silvergun Options shows *RSQ Laser Sight*. No script error.
2. Hold the pistol. A red beam leaves the muzzle and fades over about 3 m; a red dot with a glow sits on
   the wall. Move the gun fast: the beam stays on the barrel.
3. Dual-wield (Brutal Doom's Dual). The off gun has a green beam and dot.
4. Fire at a wall mark with the dot on it. The bullet holes land on the dot.
   **(not yet headset-confirmed)**
5. Shotgun: fire a few blasts. The dot stays on the wall and does not jump short after the first.
   **(not yet headset-confirmed)**
6. Grenade launcher: fire once. Then the laser shows an arc, and the dot is where the grenade lands.
   **(not yet headset-confirmed)**
7. Point the gun at the floor past 55 deg. The laser goes off. Switch weapons: it is off during the
   switch. **(not yet headset-confirmed)**
8. Put the dot on water or nukage: it wobbles. On a metal wall or door: it glints.
   **(not yet headset-confirmed)**
9. Aim at an imp standing at an angle to you. The dot sits on its body, not floating beside it. The dot
   grows and pulses on it (Target Lock). **(not yet headset-confirmed)**
10. SteamVR: bring the off hand to the rifle and grip. The off-hand dot and glow disappear; let go and
    they come back within a few tics. **(not yet headset-confirmed)**
11. Bind "Laser on/off (main hand)" and press it. The main laser goes off with a tick in the hand.
12. Fists or chainsaw: no laser.
13. Turn on *Headshot Reaction* and put the dot on a monster's head. It turns white and pulses.
14. Set *Show Range* to At the Dot. A number should show the distance. **(the text was never seen on the
    rig; check that it reads at all)**
15. Turn on *Infrared Only*. The laser disappears until you pick up light amplification goggles.
16. Load RSQ Accessibility (Steady Hands on). Hold the dot on a far wall: it shakes visibly less than with
    Steady Hands off. A fast swing still puts the dot where you swung. **(not yet headset-confirmed; on the rig a
    3-degree hand shake moved the dot 1.5 units on and 7.7 units off)**
17. Loads on plain Doom 2 without Brutal Doom VR (a load error there was fixed on 2026-11-01).

## Works with

- **RSQ Distance Grab:** this mod tells it which hands have a live laser; the grab hides its own beam on
  those hands (its *Yield to Laser Sight* row).
- **RSQ Accessibility:** colour-blind colours per hand (a lock is then told by shape, not colour),
  Photosensitive Mode caps the pulses at 2.5 Hz, Cue Size on the dot, glow and arc, Text Size on the
  readout. Steady Hands (on in Accessibility): the dot (and a grenade's arc) is traced from the smoothed hand,
  so it sits steadier on a far wall; the beam stays glued to the gun. Steady Hands off: as before. Rumble
  Strength 0: no toggle tick (it is the engine's one fixed buzz). Shared settings only act with it loaded.
- Other weapon packs can give their own muzzle points and colours through two services
  (`LaserMuzzleService`, `LaserColorService`). No RSQ mod provides them today.

## Known limits / open issues

- No beam on guns without a measured model: sprite or voxel guns, BrutalRevolver, Revolver2, the Dual*
  sprite weapons. The dot still shows on those.
- Frames that move the gun more than 6 cm / 6 deg (reloads, inspections) hide the beam.
- MP40, MG42, Devastator, FlameCannon and HellishMissileLauncher are measured but were never seen in the
  rig.
- The light at the dot was never confirmed visually (software rendering on the rig).
- How the fade and the glow read at Quest brightness is not checked.
- The off-hand stand-down when two-handing is SteamVR only; on Quest it does nothing today.
- The range readout's text was never seen. A canvas readout drew a black rectangle in VR in the Tactical
  Rig's test, so it may not work.
- The beam table (about 7600 voxel rods) makes the pk3 large and adds load work.

## Credits

RSQ_LaserSight -- credits (from CREDITS.txt, unchanged):

A laser from each gun's own barrel, part of the Radiant Silvergun Quest series. For stock QuestZDoom 17.3:
ZScript and lumps only, no engine changes. Made by the project owner (presidentkoopa) and this pack.

INSPIRED BY (no code or assets taken)
- Laser Sight by m8f (Alexander Kromm, github.com/mmaulwurff/laser-sight), GPLv3 -- the laser sight
  bundled with QuestZDoom (laser-sight-0.5.5-vr.pk3). This pack replaces it; nothing of its code or
  sprites is used here.

GENERATED FOR THIS PACK
- The beam voxels (models/rsqls/beam/*.kvx, VOXELDEF.txt) and the muzzle table (zscript/rsqls/muzzles.zs):
  tools/gen_beams.py, measured from Brutal Doom Quest's own gun models.

QuestZDoom (Emawind and Team Beef): the engine and the hand-pose script API.
