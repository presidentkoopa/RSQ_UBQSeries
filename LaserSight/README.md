# RSQ LaserSight

A laser on the gun in each hand: a beam from the muzzle along the barrel, and a dot where it lands. It only draws: it changes no shot, no damage and no aim. It has no keys, no gestures and no button of its own. You hold a gun and point it; the rows below are what you then see.

<a name="how-to-play"></a>
## How to play

"Main hand" is the hand with your ready weapon; "off hand" is the other. A "measured gun" is a gun whose class is in this mod's beam table: Brutal Doom's guns as BD22 VR Reloaded draws them, their Purist and off hand (RSQ_Off_) copies, and the guns of the two weapon sets (WoS Reloaded, GNRC Reloaded). Map units are Doom's: 34 to a metre by default. A tic is 1/35 of a second.

| Do this | What happens | Needs |
|---|---|---|
| Hold a measured gun in either hand and point it | A beam from that gun's muzzle along its barrel, brightest at the muzzle, fading to nothing over 3 m and stopping at what it hits; and a dot where it lands. Main hand red, off hand green | Laser Sight, Main Hand, Off Hand, Show Beam, Show Dot: On (default); Colour Mode: Per Hand (default); Beam Fade Length (default 3) |
| Hold any other gun (plain Doom's own, or a pack's this mod has no measurement for) | No beam. Only the dot, traced from the controller along where the hand points | Show Dot: On (default) |
| Hold a melee weapon or a thing that is not a gun: a saber, the whip, a glove, the ShieldSaw, the Force hand, the hand grenade, a weapon set's bare hand | No beam and no dot on that hand. The test: the weapon is flagged MELEEWEAPON, or it is flagged CHEATNOTWEAPON and is not a measured gun | Show on Melee: Off (default) |
| Hold nothing in a hand | Nothing is drawn on that hand, whatever the settings | |
| Point the dot at a wall, a floor or a ceiling | The dot is painted flat on that surface. It grows with distance so it looks the same size at any range. A soft bloom 1.8 times the dot lies over it and a real light of its colour lights the spot | Dot Glow: Both (default); Dot Size (default 1); Glow Size (default 1.8) |
| Point at the sky, or at nothing within 2048 map units | No dot. The beam is still drawn, out to its fade length | Trace Range (default 2048) |
| Put the dot on a live monster that is not friendly | The dot is drawn on its body, 1.25 times its size, swelling and shrinking by 12% at 2.2 times a second. The beam is 1.35 times brighter | Target Lock: On (default); Lock Pulse Rate (default 2.2) |
| Hold the muzzle of a measured gun closer than 10 cm to what it points at | The beam goes (the shortest beam is 10 cm). The dot stays | |
| Point a gun down more than 55 degrees below level | That hand's beam and dot go off until it comes back up | Aim Down Off (default 55) |
| Switch weapons | The main hand's beam and dot are off from the moment the switch is asked for until it is done | |
| Press primary fire or secondary fire on a hand holding a measured gun | The beam keeps its last measured pose through the frames that follow, for 35 tics after that hand's fire was last seen held. Past that, on a frame with no measurement (a reload), the beam hides until the gun is back on a measured frame. The dot stays | |
| Raise either wrist for the watch check | The laser goes off on each hand whose gun is not aimed within 40 degrees of where you look, until the wrist comes down. A gun aimed that way keeps its laser | RSQ Accessibility or RSQ Gun Cards |
| Steady the off hand's gun with both hands (the engine's two handed weapons) | The off hand's beam and dot go off while the engine marks the gun as steadied. The code's own note says only PC VR sets that mark, not the Quest | |
| Walk from a dark room into a bright one | The beam dims with the room's light at the muzzle: in full light it is 35% of what it is in the dark | Beam in Daylight (default 0.35); Beam Brightness (default 0.8) |
| Put the dot on water, nukage, slime, lava, blood or a fall (by the texture's name) | The dot swims: its size goes up and down by 18% and it is drawn at 75% brightness | Dot Reacts to Surface: On (default) |
| Put the dot on metal (a texture named METAL, SUPPORT, DOOR, STEEL, SHAWN, PLAT or PIPE) | The dot's bloom and light are 1.5 times wider | Dot Reacts to Surface: On (default) |
| Fire a gun whose shot falls under gravity (a grenade launcher) once, with that hand's fire held | The shot is learned for the rest of the session. From then on that gun's beam bends along the path the shot will fly, 24 dots mark the path, and the dot is where it lands | Grenade Arc: On (default); Arc With Beam: On (default) |
| Die | Every beam, dot, arc and readout hides | |
| Hold a melee weapon or a thing that is not a gun | A dot only, traced from the controller along where the hand points. Never a beam | Show on Melee: On (default Off) |
| Put the dot on a live monster that is not friendly | The dot and the beam turn the Target Colour (yellow) | Colour on Target: On (default Off); Target Lock: On (default) |
| Put the dot on a live monster that is not friendly | The dot is smaller by that share, and still pulses | Lock Tighten above 0 (default 0) |
| Put the dot on a monster's head | The dot and the beam pulse between their own colour and the Headshot Colour (white), 4 times a second | Headshot Reaction: On (default Off); Headshot Pulse: On (default); Headshot Pulse Rate (default 4) |
| Put the dot on a monster's head | The dot and the beam turn the Headshot Colour and stay it | Headshot Reaction: On (default Off); Headshot Pulse: Off (default On) |
| Point at anything that is not a live unfriendly monster | No dot | Dot Only on Enemies: On (default Off) |
| Point at something further than the limit | No dot | Dot Range Limit above 0 (default 0: as far as Trace Range) |
| Point at something | The range to it is drawn as digits in the dot's colour, beside the gun or over the dot: the main hand's, or the off hand's when the main hand has none. Metres show one decimal under 10 m | Show Range: At Gun or At Dot (default Off); Range Units: Metres (default), Feet or Map Units |
| Fire a bullet gun three times with that hand's fire held | A ring at the dot shows where that gun's shots can land: the angle 95% of its seen shots fell inside | Spread Ring: On (default Off); Ring Minimum Spread (default 0.75) |
| Reload, raise or lower a weapon | That hand's beam and dot are off while its weapon is not ready | Only When Ready: On (default Off) |
| Pick up the light amplification goggles | The laser shows only while you carry the goggles' power; without it nothing is drawn | Infrared Only: On (default Off) |
| Hold a gun in each hand | Both hands use the one Laser Colour | Colour Mode: Single (default Per Hand) |
| Hold a gun in each hand | Each dot takes its own colour (Main Hand Dot, Off Hand Dot), apart from its beam's | Colour Mode: Beam Dot (default Per Hand) |
| Switch to a gun in another weapon slot | The laser takes that slot's colour (Slot 1 to Slot 0) | Colour per Slot: On (default Off) |
| Hold a gun | The beam's colour runs round the hues at 60 degrees a second, the two hands half a turn apart; the dot too | Cycle Colours: On (default Off); Dot Cycles Too: On (default); Cycle Speed (default 60) |
| Hold a measured gun | Now and then a small spark shows beside the beam, in the beam's colour whitened | Beam Sparkle: On (default Off) |
| Hold a gun whose falling shot has been learned | Only the 24 dots mark the path. No beam is drawn on that gun at all | Arc With Beam: Off (default On) |
| Hold a gun whose falling shot has been learned | The plain straight beam and dot, as on any gun | Grenade Arc: Off (default On) |
| Point a gun at the floor | The laser stays on at any angle | Aim Down Off: 0 (default 55) |
| Point the dot at a surface | No bloom and no light (Off), the bloom only (Bloom), or the light only (Light) | Dot Glow: Off, Bloom or Light (default Both) |
| Move a hand | The dot is drawn that many tics ahead of where the hand's movement carries it | Dot Lead above 0 (default 0) |
| Hold a gun | No beam; the dot only | Show Beam: Off (default On) |
| Hold a gun | No dot; the beam only | Show Dot: Off (default On) |
| Hold a gun in the main hand, or in the off hand | Nothing on that hand | Main Hand: Off, or Off Hand: Off (default On) |
| Hold a gun | Nothing is drawn | Laser Sight: Off (default On) |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Laser Sight

| Option | Default | What it does |
|---|---|---|
| Laser Sight | On | Turns the whole laser sight on or off. |
| Main Hand | On | The laser on the gun in your main hand. |
| Off Hand | On | The laser on the gun in your off hand. |
| **Look** | | |
| Show Beam | On | Draws the beam from the muzzle. |
| Show Dot | On | Draws the dot where the laser lands. |
| Dot Size | 1 (0.25 to 4) | How big the dot is. |
| Laser Colour | ff 20 10 | The laser's colour (the main hand's, or the only one when Colour Mode is Single). |
| **Targets** | | |
| Target Lock | On | The dot reacts when it is on a live hostile monster. |
| Headshot Reaction | Off | The dot changes when it is on a monster's head. |
| **Extras** | | |
| Grenade Arc | On | A thrown weapon such as a grenade shows its arc once it has been thrown once. |
| Show Range | Off | Shows the range to what the laser hits, by the gun or at the dot. |
| Test and Debug | (page) | Every other setting: colours, when it shows, tuning numbers and the debug log. |
| Reset All | (button) | Puts every RSQ Laser Sight setting back to its default. |

<details><summary>RSQ Laser Sight: Test And Debug (52 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Beam and Dot** | | |
| Beam Sparkle | Off | The Quest beam's outer shell sparkles gently. |
| Dot Only on Enemies | Off | The dot shows only on a live hostile monster. |
| Dot Glow | Both | The dot's glow: bloom, a real light, or both. |
| Dot Reacts to Surface | On | The dot swims on water, slime and lava and glints on metal. |
| Infrared Only | Off | The laser is visible only through light amplification goggles. |
| Beam Fade Length | 3 (0.5 to 6) | How many metres the beam takes to fade to nothing. |
| Beam Brightness | 0.8 (0.1 to 1) | The beam's brightness at the muzzle. |
| Beam in Daylight | 0.35 (0 to 1) | The beam's brightness in full light, as a share of its brightness in the dark. |
| Dot Brightness | 1 (0 to 1) | How bright the dot is. |
| Glow Size | 1.8 (1.1 to 4) | The bloom's size, times the dot, and the light's reach. |
| Glow Intensity | 1 (0.1 to 4) | How strong the dot's glow is. |
| Trace Range | 2048 (256 to 8192) | How far the laser looks, in map units. |
| Dot Range Limit | 0 (0 to 8192) | No dot beyond this distance; 0 is as far as the trace range. |
| Dot Lead (tics) | 0 (0 to 2) | How many tics ahead of the hand the dot is drawn. |
| **When It Shows** | | |
| Show on Melee | Off | Shows the laser on a fist, chainsaw, saber, shield or empty hand too. |
| Only When Ready | Off | Hides the laser while switching or reloading. |
| Aim Down Off (deg) | 55 (0 to 90) | Turns the laser off while the gun points down past this many degrees; 0 never. |
| Follow BD Shots | On | The dot follows Brutal Doom's shots, down the gun's bore. |
| **Targets** | | |
| Colour on Target | Off | The dot turns the target colour on a hostile. |
| Target Colour | ff e0 20 | The colour the dot turns on a target. |
| Headshot Colour | ff ff ff | The colour the dot turns on a head. |
| Headshot Pulse | On | The dot pulses on a head. |
| Lock Tighten | 0 (0 to 0.9) | The share the dot shrinks by onto a target. |
| Lock Pulse Rate | 2.2 (0.25 to 8) | How fast the dot pulses on a target, in Hz. |
| Headshot Pulse Rate | 4 (0.5 to 20) | How fast the dot pulses on a head, in Hz. |
| **Colours** | | |
| Colour Mode | Per Hand | One colour for both hands, one per hand, or separate beam and dot colours. |
| Off Hand Colour | 20 ff 30 | The off hand's laser colour. |
| Main Hand Dot | ff 20 10 | The main hand's dot colour, when Colour Mode is Beam Dot. |
| Off Hand Dot | 20 ff 30 | The off hand's dot colour, when Colour Mode is Beam Dot. |
| Cycle Colours | Off | The laser cycles through the colours. |
| Dot Cycles Too | On | The dot cycles its colour with the beam. |
| Cycle Speed | 60 (6 to 360) | How fast the colours cycle, in degrees of hue a second. |
| Colour per Slot | Off | Each weapon slot gets its own laser colour. |
| Slot 1 | ff 20 10 | The laser colour for slot 1. |
| Slot 2 | ff 80 10 | The laser colour for slot 2. |
| Slot 3 | ff e0 20 | The laser colour for slot 3. |
| Slot 4 | 20 ff 30 | The laser colour for slot 4. |
| Slot 5 | 20 e0 ff | The laser colour for slot 5. |
| Slot 6 | 30 50 ff | The laser colour for slot 6. |
| Slot 7 | c0 30 ff | The laser colour for slot 7. |
| Slot 8 | ff 20 e0 | The laser colour for slot 8. |
| Slot 9 | ff ff ff | The laser colour for slot 9. |
| Slot 0 | ff 20 10 | The laser colour for slot 0. |
| **Extras** | | |
| Arc With Beam | On | The beam bends along the grenade arc as well as its dots. |
| Spread Ring | Off | A ring at the dot shows where this gun's shots can land. |
| Range Units | Metres | The range readout in metres, feet or map units. |
| Arc Dot Size | 1 (0.25 to 4) | The size of the arc's dots. |
| Arc Brightness | 0.8 (0.1 to 1) | The brightness of the arc's dots. |
| Ring Minimum Spread | 0.75 (0 to 5) | A spread tighter than this many degrees draws no ring. |
| Ring Brightness | 0.6 (0.1 to 1) | How bright the spread ring is. |
| Readout Size | 1 (0.5 to 3) | How big the range readout is. |
| **Debug** | | |
| Debug Log | Off | Logs the arc learner, each hand's gun and what the dot is on, every second. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| Any mod that asks: service `RSQLS_SightService` | GetInt `"laser.active"` (intArg the hand, 0 main, 1 off): 1 when a beam, a bent beam or a dot drew on that hand last tic. GetInt `"laser.beam"`: the same for a beam or a bent beam alone. GetDouble `"laser.line"` with stringArg `"x"`, `"y"`, `"z"`, `"dx"`, `"dy"` or `"dz"`: the muzzle (map units) and the unit direction that hand's beam was drawn on last tic; for a bent beam, the line it leaves the muzzle on; 0 when no beam drew there. GetDouble `"laser.dot"`, the same six: the line that hand's dot was traced on (Brutal Doom's shot line when it is followed); 0 with a grenade arc or no laser on that hand. GetInt `"head.on"` (objectArg a monster): see RSQ Gun Bonsai VR below. GetIntUI `"menu.locked"` (stringArg `"TargetLock"`, `"TargetColour"` or `"Headshot"`) and `"menu.gated"`: for this mod's own menu rows. Any other GetInt request answers -1. Only the player at this machine is answered for |
| Any mod that asks: service `RSQLS_MuzzleService` | GetString `"muzzle.at"` (intArg the hand, objectArg the player's pawn): `"x y z"`, that hand's muzzle in map units. With BD22 VR Reloaded's muzzle handler running, its own muzzle for that gun; else the muzzle the beam was drawn from last tic; `""` when neither is known or the hand is empty |
| RSQ Wheel | The Wheel asks `"laser.beam"` and `"laser.line"` (the Wheel's own code): a hand whose beam this mod drew points at the cards along that beam and the Wheel draws no beam of its own there. A hand with no beam from this mod (any melee weapon, an empty hand, a gun that is not measured and has no learned arc) answers 0 |
| RSQ Distance Grab | It asks `"laser.beam"` and, with its own setting on (`rsqdg_ls_yield`, default Off), hides its grab beam on a hand this mod's beam is on (Distance Grab's own code) |
| RSQ VisualRewards | It asks `"muzzle.at"` of any service named ...MuzzleService (its own code) |
| RSQ Accessibility | The watch check (`RSQG_Service` `"inspect"`) turns the lasers off, as the row above. Steady Hands (`RSQA_Service` `"steady"`): the dot, and a grenade arc, are traced from the smoothed hand; the beam stays on the gun. Colour-blind play (`rsqa_colorblind`): the hands' own colours become its pair (azure and amber, cyan and red, or magenta and yellow), Colour on Target stands down and the Target Lock pulse is 25% deep in place of 12%. Photosensitive Mode (`rsqa_photosafe`): the pulses run at most 2.5 times a second and Beam Sparkle is dimmed to 40% and half as often. Cue Size (`rsqa_cue_scale`) scales the dot, its glow, the arc's dots and the bent beam. Text Size (`rsqa_text_scale`) scales the range digits |
| RSQ Gun Cards | Its copy of the watch check (`RSQGC_GCopyService` `"inspect"`) is asked when RSQ Accessibility does not answer |
| RSQ Score | Headshot Reaction asks Score first what a head is (`RS_ScoreService` `"head.at"`), so the colour follows what Score pays. Score's own head sensor (`RS_ScoreHeadSensor`) counts as its monster's head |
| RSQ Gun Bonsai VR, with RSQ Tactical Rig | This mod asks Gun Bonsai VR's service (`RSQ_MeleeUpgradeService`: `"loaded"`, and `"plevel"` for `"TargetLock"` and `"HeadshotReaction"`) and looks for the Rig's service (`RSQTR_RigService`), to lock Target Lock, Colour on Target and Headshot Reaction behind those upgrades and to answer `"head.on"`. Gun Bonsai VR as it stands answers `"loaded"` 0, so nothing is locked: the rows decide, and `"head.on"` always answers 0 |
| BD22 VR Reloaded 2.0 and later | While its muzzle handler (`RSQ_Muzzle`) runs, the dot is traced from that pack's own muzzle for the gun, 3.85 degrees left and 3.36 degrees up of the controller: the line its shots fly (Follow BD Shots, default On). Its off hand copies (RSQ_Off_ classes) are measured guns, so they have a beam |
| Brutal Doom and XMVE monsters | Headshot Reaction uses Brutal Doom's own head rules: its head boxes (`HeadHitbox`, `HeadshotTargetBase`) and the head heights of its bloods |
| WoS Reloaded, GNRC Reloaded (the weapon sets) | Each set's guns are named in this mod and draw the beam of the Brutal Doom gun they stand for; the WoS 1911 has a beam and muzzle of its own. Their knuckles and saws have none |
| Critical Hits and Headshots (mk-crits) | For monsters that are not Brutal Doom's, with its headshots on (`csh_headshot_enabled`): a head is the top fifth of the monster, and never on Demon, Spectre, LostSoul, Cacodemon, Revenant, PainElemental, Arachnotron or SpiderMastermind |
| QuestZDoom's own laser (M8F's Laser Sight) | While Laser Sight is On and you are playing, its switch (`m8f_wm_ShowLaserSight`) is held at 0 so only one laser shows. Your own value is kept (`rsqls_m8f_was`) and put back when Laser Sight is turned Off, when a menu is open, when the game is not in a level, and when a map unloads |
| Any weapon pack: a service named ...LaserColorService | Asked GetInt `"laser.color"` (stringArg the weapon's class, intArg the hand, doubleArg 1 for the dot and 0 for the beam, objectArg the weapon, nameArg `RSQ_LaserSight`): an answer of 0 or more is the colour 0xRRGGBB for that weapon's laser, over the hand's and the slot's colour |
| Any weapon pack: a service named ...LaserMuzzleService | Asked GetString `"laser.muzzle"` (stringArg the weapon's class, intArg the hand): `"forward up side"` in metres from the grip moves the start of the dot's trace on a gun that is not measured. It gives no beam |

## Limits

- No keys and no KEYCONF. The only buttons the code reads are each hand's primary and secondary fire, and only to time the beam after a shot and to learn what a gun fires. No grip, Use button, stick or body move is read.
- A beam is drawn only on a measured gun. Any other gun has a dot only; the one exception is a gun whose falling shot has been learned, which gets the bent beam.
- A hand holding a melee weapon gets nothing. With Show on Melee on it gets a dot, never a beam. No setting gives such a hand a beam.
- The series' hand grenade is a thing that is not a gun: the hand holding it gets no laser and no arc.
- An empty hand gets nothing, with Show on Melee on too.
- Only a gun's primary fire is drawn as an arc or a spread ring. A falling shot from secondary fire is learned under its own name and never drawn.
- A gun that has fired any bullet is never drawn as an arc. What was learned lasts until the game is closed and is not saved: after loading a save each gun is learned again on its next shot.
- A shot is learned only when it leaves within 96 map units of the hand, within 30 degrees of where the hand points, at 6 map units a tic or faster, with that hand's fire held in the last 8 tics.
- The arc is followed for at most 140 tics (4 seconds) of flight and stops at the first wall, floor or body.
- The beam's width has no setting. Its length is the longest of 72 fixed lengths, 10 cm to 6 m, that does not pass what it hits.
- The beam is drawn on the gun every frame; the dot is a thing in the world moved once a tic.
- The range digits show one hand at a time. Under At Dot, with the dot hidden, they are drawn beside the gun.
- While Laser Sight is On, QuestZDoom's own laser is held off even when Main Hand and Off Hand, or Show Beam and Show Dot, are all Off here.
- Everything is drawn for the player at this machine only.
- The brighter beam with a halo ("Laser: PC VR") is no longer drawn: its code is still in the files but is switched off.

## Credits

The full list is in **CREDITS.txt**.

- **presidentkoopa:** the project, and the options carried over from his UZDXREMA laser (pointer and beam apart,
  glow, colour pickers per hand, per slot, cycling, target and headshot reactions, infrared).
- **Laser Sight** by m8f (Alexander Kromm, github.com/mmaulwurff/laser-sight, GPLv3), the laser sight bundled with
  QuestZDoom: the inspiration. None of its code or sprites is used; with both loaded, this pack's laser wins and M8F's is held off.
- **Brutal Doom** and **BD22 VR Reloaded:** the gun models the muzzles were measured from, and BD22 VR's shot line.
  None of their files ship in this pack.
- **Generated for this pack:** the beam and halo voxels, the muzzle table, the sprites and meshes (the tools above).
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.

---
Written from the code at commit 692b3e53c, 2026-11-27.
