# RSQ Laser Sight

A laser on every gun in both hands. The beam comes out of the gun's own barrel, and the dot lands where the shot will.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. Everything here is ZScript and data. No engine
changes.

## Standout feature: a laser that tells the truth

Raise a gun and a beam leaves its muzzle. Not your fist, not the controller: the end of the barrel on the 3D model
in your hand. It runs straight down that barrel, bright at the muzzle, fading out over a few metres. Tilt the gun, cant
it on its side, swap it to your off hand: the beam stays on the barrel, because it is drawn as part of the gun.

Where it hits, a dot is painted onto the surface. It lies flat on walls, floors and ceilings, sits on a monster's
body, and casts real coloured light on the room around it. With BD22 VR Reloaded loaded, the dot follows that mod's
true shot line, from its muzzle and down its bore. Put the dot on a target, pull the trigger, and that is where the
round goes.

Throw a grenade from a launcher once and the laser learns its flight. From then on that gun shows a dotted arc to
the exact spot it will land.

## Features

**The beam**
- Starts at the real muzzle of each gun model and runs down its barrel. The muzzles were measured from the meshes.
- Stops where it hits, so it never shows through a wall.
- Brighter in the dark, softer in full light, as a real laser looks.
- Shown while the gun is in its ready pose; a reload or a kick in the animation hides it for that moment.

**The dot**
- Painted on the surface it hits: flat on walls and floors, on the body of a monster.
- Stays the same size on screen at any distance.
- Glow: a soft bloom, a real dynamic light, or both.
- Swims on water, slime, lava and blood; glints on metal.
- With BD22 VR Reloaded: traced down that mod's own bore line, so it matches where its guns really fire.

**Learned from each gun**
- Grenade arc: once a gun has thrown a gravity projectile, it shows the flight path and the landing spot.
- Spread ring (optional, off by default): an ellipse at the dot showing where this gun's shots land, learned from
  its own shots.
- Range readout (optional, off by default): the distance to what you are aiming at, by the gun or at the dot, in
  metres, feet or map units.

**Reacting to targets**
- Target lock: on a live monster the dot swells and pulses.
- Target colour (optional): the dot turns a colour of your choice on a monster.
- Headshot reaction (optional): the dot changes colour and pulses when it sits on the top fifth of a monster.

**Colour**
- Any colour, from a picker. Per hand, beam and dot separately, or one for everything.
- A colour per weapon slot (optional).
- Colour cycling (optional).
- Infrared mode (optional): the laser is invisible unless you wear light amplification goggles.

**Behaviour**
- Off while the gun points at the floor (past 55 degrees down) and while you switch guns.
- No laser on fists, chainsaws, sabers, shields or empty hands unless you ask for one.
- A short rumble in the hand when you switch a laser on or off.

## How To Play

1. Load the pk3 after your weapon mod. Nothing else is needed.
2. Start a level and raise a gun. Both hands get a laser: red on the main hand, green on the off hand.
3. Put the dot on a target and fire. With BD22 VR Reloaded, the dot is that mod's real shot line.
4. Lower the gun toward the floor and the laser switches off. Raise it and it comes back.
5. Fire a grenade launcher once. Aim again and you will see the arc and where the grenade will land.
6. Open Options → Radiant Silvergun Options → RSQ Laser Sight to change colours, the beam's look, or to bind keys
   that switch each hand's laser on and off.

Guns with a measured model (Brutal Doom's arsenal as drawn by BD22 VR Reloaded, including the off-hand copies) get the
full beam. Any other gun, from any mod, still gets the dot, traced from your hand along the shot's line. A weapon mod
can also tell the laser where its muzzles are.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Aim | Point the gun | Both hands, independently. |
| Laser off for a moment | Point the gun down past 55 degrees | The angle is a slider; 0 keeps it always on. |
| Main hand laser on/off | Bind a key | Options → Customize Controls → "RSQ Laser Sight", or the mod's Controls page. No default bind. |
| Off hand laser on/off | Bind a key | As above. No default bind. |
| See an infrared laser | Pick up light amplification goggles | Only with Infrared Only switched on. |

Left-handed play: main hand and off hand follow QuestZDoom's own handedness setting, and the beam follows the gun to
whichever hand holds it.

On SteamVR builds, bracing a gun with both hands hides the off hand's laser, because the engine stops drawing the
off-hand gun. Let go of the grip and it comes straight back.

## Menu

Options → Radiant Silvergun Options → RSQ Laser Sight

**Front page**

| Row | Default | What it does |
|---|---|---|
| Laser Sight | On | The whole mod. |
| Main Hand | On | The main hand's laser. |
| Off Hand | On | The off hand's laser. |
| Show Beam | On | The beam from the muzzle. |
| Beam Look | Standard | Subtle, Standard or Bold: fade length, brightness and daylight strength together. |
| Show Dot | On | The dot where it lands. |
| Dot Size | Standard | Small, Standard or Large. |
| Dot Glow | Bloom and Light | Off, Bloom, Light, or both. |
| Colour Mode | Per Hand | One Colour, Per Hand, or Beam and Dot coloured separately. |
| Main Hand Colour | Red | Picker. |
| Off Hand Colour | Green | Picker. |
| Show on Melee | No | A laser on fists, chainsaws, sabers, shields and empty hands too. |
| Only When Ready | No | Hide it while the gun is switching or reloading. |
| Dot Reacts to Surface (water, metal) | On | The dot swims on liquids and glints on metal. |
| Follow Brutal Doom VR Shots | On | With BD22 VR Reloaded, trace the dot down its true shot line. |
| Off When Pointed Down Past (deg, 0 = never) | 55 | How far down the gun may point before the laser goes out. |
| Infrared Only | Off | Only visible through light amplification goggles. |

**More Colours**

| Row | Default | What it does |
|---|---|---|
| Main Hand Dot | Red | The main dot's colour, in Beam and Dot mode. |
| Off Hand Dot | Green | The off dot's colour, in Beam and Dot mode. |
| Colour per Slot | Off | Each weapon slot its own colour. |
| Slot 1 to Slot 0 | Red, orange, yellow, green, cyan, blue, violet, pink, white, red | One picker per slot. |
| Cycle Colours | Off | The laser runs through the rainbow. |
| Dot Cycles Too | On | The dot cycles with the beam. |

**Targets and Extras**

| Row | Default | What it does |
|---|---|---|
| Target Lock | On | The dot swells and pulses on a live monster. |
| Target Colour Change | Off | The dot turns the target colour on a monster. |
| Target Colour | Yellow | Picker. |
| Headshot Reaction | Off | The dot reacts when it sits on a monster's head. |
| Headshot Colour | White | Picker. |
| Headshot Pulse | On | The headshot colour pulses rather than holding. |
| Grenade Arc | On | Guns that throw a projectile show its arc once they have fired. |
| Arc With Beam | Off | Keep the straight beam as well as the arc. |
| Spread Ring | Off | A ring at the dot showing this gun's learned spread. |
| Show Range | Off | Off, By the Gun, or At the Dot. |
| Units | Metres | Metres, Feet or Map Units. |

**Controls**

| Row | Default | What it does |
|---|---|---|
| Toggle Main Hand | Unbound | Key to switch the main laser on and off. |
| Toggle Off Hand | Unbound | Key to switch the off laser on and off. |
| Toggle Haptics | On | A rumble in the hand when a laser is switched. |

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Beam Fade Length | 3.0 | Metres for the beam to fade out (0.5 to 6). |
| Beam Brightness | 0.80 | At the muzzle. |
| Beam in Daylight | 0.35 | The beam's strength in full light, as a share of its strength in the dark. |
| Dot Size | 1.00 | Fine size control. |
| Dot Brightness | 1.00 | |
| Glow Size | 1.80 | Bloom size and light reach. |
| Glow Intensity | 1.00 | |
| Trace Range | 2048 | How far the laser looks, in map units (about 60 m). |
| Dot Range Limit | 0 | No dot beyond this distance; 0 = as far as the trace. |
| Dot Lead (Tics) | 0.0 | Draws the dot slightly ahead of a moving hand. |
| Cycle Speed | 60 | Degrees of hue a second. |
| Lock Tighten | 0.00 | How much the dot shrinks onto a target. |
| Lock Pulse Rate | 2.20 | Pulses a second. |
| Headshot Pulse Rate | 4.0 | Pulses a second. |
| Arc Dot Size | 1.00 | |
| Arc Brightness | 0.80 | |
| Ring Minimum Spread | 0.75 | Degrees; a tighter gun draws no ring. |
| Ring Brightness | 0.60 | |
| Readout Size | 1.00 | |
| Reset All | | Every setting back to its default. |

## Works with

Runs on its own with any weapon mod.

- **BD22 VR Reloaded / Brutal Doom:** the full beam on every measured Brutal Doom gun and its off-hand copies, and the
  dot on that mod's true shot line.
- **RSQ Gun Bonsai VR (with Gun Bonsai and RSQ TacticalRig):** Target Lock and Headshot Reaction become upgrades you
  earn, after TacticalRig's Quick Draw. Level 1 of Target Lock is the lock, level 2 adds the target colour. Level 1 of
  Headshot Reaction is the colour change; level 2 makes a gun hit with your dot on a monster's head count as a
  headshot. While Gun Bonsai VR is loaded, those menu switches stand aside.
- **RSQ Accessibility:** Steady Hands smooths the dot's aim (the beam stays on the gun). Colour-blind mode gives the
  hands the series' colour pair and shows the target lock by shape and pulse. Photosensitive mode caps pulse rates.
  Cue Size scales the dot, glow and arc. Text Size scales the range readout. Rumble Strength 0 silences the toggle
  rumble.
- **RSQ DistanceGrab:** its grab beam stands down on a hand that already has a laser.
- **RSQ Wheel:** the ring's pointing beam stands down on the idle hand when the laser is already lighting it.
- **Other weapon mods:** can set a laser colour per gun, or tell the laser where their muzzles are.

It is a replacement for the laser sight bundled with QuestZDoom.

## Credits and licence

- Made by presidentkoopa for the Radiant Silvergun Quest series.
- Inspired by Laser Sight by m8f (Alexander Kromm, github.com/mmaulwurff/laser-sight, GPLv3), the laser sight bundled
  with QuestZDoom. No code or sprites from it are used here.
- Generated for this pack: the beam voxels and the muzzle table, measured from Brutal Doom's gun models as drawn by
  brutal22test6, BD_VoxelPack and BD22 VR Reloaded.
- QuestZDoom by Emawind and Team Beef: the engine and the hand-pose script API.
