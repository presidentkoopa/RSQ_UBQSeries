# RSQ Laser Sight

A laser on every gun in both hands. The beam comes out of the gun's own barrel, and the dot lands where the shot will.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New on 11-09 (not headset-confirmed): the beam no longer disappears between shots. It went out on every gun frame
that was never measured, and the pistol's and pump shotgun's fire and pump frames are such frames. Now the beam holds
the gun's last measured pose until the gun is back in one. On the rig the beam stayed up on every tic of a long rifle
burst; the pistol and shotgun themselves are not yet shown on the rig or in the headset.

New on 11-06 (rig only, not headset-confirmed): Dot Only on Enemies; the beam bent along the grenade arc (Arc With
Beam, on, now one continuous line); Laser (Quest / PC VR).

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

Throw a grenade from a launcher once and the laser learns its flight. From then on that gun shows its beam bent along a dotted arc to
the exact spot it will land.

## Features

**The beam**
- Starts at the real muzzle of each gun model and runs down its barrel. The muzzles were measured from the meshes.
- Stops where it hits, so it never shows through a wall.
- Brighter in the dark, softer in full light, as a real laser looks.
- Stays on while you fire: between shots it holds the gun's last measured pose (not headset-confirmed). It used to
  blink off during the fire and pump frames that were never measured.
- Laser (Quest / PC VR): PC VR draws a whiter core inside a soft halo of the beam colour, on every beam (the
  straight one and the one bent along a grenade arc), both hands the same. Rig only, not headset-confirmed. PC VR's halo
  rods make the pk3 about 16 MB bigger (about 26 MB) and are loaded at startup whichever type is picked, so they cost
  memory on the Quest even on Quest.

**The dot**
- Painted on the surface it hits: flat on walls and floors, on the body of a monster.
- Stays the same size on screen at any distance.
- Glow: a soft bloom, a real dynamic light, or both.
- Swims on water, slime, lava and blood; glints on metal.
- With BD22 VR Reloaded: traced down that mod's own bore line, so it matches where its guns really fire.
- Optional (off): Dot Only on Enemies, the dot shown only on a live hostile monster.

**Learned from each gun**
- Grenade arc: once a gun has thrown a gravity projectile, it shows the flight path and the landing spot, with the beam
  bent along it (Arc With Beam, on).
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

Options → Radiant Silvergun Options → RSQ Laser Sight. One page; the raw numbers and the debug log are on **Test and
Debug**; **Reset All** at the foot resets both. With RSQ Gun Bonsai VR and RSQ Tactical Rig loaded (the Rig is what
offers the laser nodes), Target Lock, Colour on Target and Headshot Reaction are unlocked by the upgrades: they stay
greyed until Target Lock 1, Target Lock 2 and Headshot Reaction 1 are learned, and the page's top line reads
"GunBonsaiOVR detected. Mod features unlocked via upgrades." Learning one switches its row on; the row can still turn it
off. Without the Rig nothing is gated: no top line, and the rows work as without Gun Bonsai VR.
A colour row is greyed while the switch it belongs to is off.

| Row | Default | What it does |
|---|---|---|
| Laser Sight | On | The whole mod. |
| Main Hand | On | The main hand's laser. |
| Off Hand | On | The off hand's laser. |
| **Beam and Dot** | | |
| Show Beam | On | The beam from the muzzle. |
| Laser | Quest | Quest: the voxel beam. PC VR: a whiter core inside a soft halo, on the straight beam and the arc beam alike. |
| Show Dot | On | The dot where it lands. |
| Dot Only on Enemies | Off | The dot shows only on a live hostile monster. |
| Dot Size | 1.00 | The dot's size. |
| Dot Glow | Bloom and Light | Off, Bloom, Light, or both. |
| Dot Reacts to Surface | On | The dot swims on liquids and glints on metal. |
| Infrared Only | Off | Only visible through light amplification goggles. |
| **When It Shows** | | |
| Show on Melee | No | A laser on fists, chainsaws, sabers, shields and empty hands too. |
| Only When Ready | No | Hide it while the gun is switching or reloading. |
| Off When Aimed Down | 55 | Degrees the gun may point down before the laser goes out (0 = never). |
| Follow Brutal Doom Shots | On | With BD22 VR Reloaded, trace the dot down its true shot line. |
| **Targets** | | |
| Target Lock | On | The dot swells and pulses on a live monster. |
| Colour on Target | Off | The dot turns the target colour on a monster. |
| Target Colour | Yellow | Picker. |
| Headshot Reaction | Off | The dot reacts when it sits on a monster's head. |
| Headshot Colour | White | Picker. |
| Headshot Pulse | On | The headshot colour pulses rather than holding. |
| **Extras** | | |
| Grenade Arc | On | Guns that throw a projectile show its arc once they have fired. |
| Arc With Beam | On | The beam as well as the arc's dots, bent along the arc (since 11-06; it was a straight line). |
| Spread Ring | Off | A ring at the dot showing this gun's learned spread. |
| Show Range | Off | Off, By the Gun, or At the Dot. |
| Range Units | Metres | Metres, Feet or Map Units. |
| **Colours** | | |
| Colour Mode | Per Hand | One Colour, Per Hand, or Beam and Dot coloured separately. |
| Main Hand Colour / Off Hand Colour | Red / Green | Pickers. |
| Main Hand Dot / Off Hand Dot | Red / Green | The dots' colours, in Beam and Dot mode. |
| Cycle Colours | Off | The laser runs through the rainbow. |
| Dot Cycles Too | On | The dot cycles with the beam. |
| Colour per Slot | Off | Each weapon slot its own colour. |
| Slot 1 to Slot 0 | Red, orange, yellow, green, cyan, blue, violet, pink, white, red | One picker per slot. |
| **Controls** | | |
| Toggle Main Hand / Off Hand | Unbound | Keys that switch each laser on and off. |
| Toggle Rumble | On | A rumble in the hand when a laser is switched. |
| Test and Debug | | The page below. |
| Reset All | | Every setting on both pages back to its default. |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| Beam Fade Length | 3.0 | Metres for the beam to fade out (0.5 to 6). |
| Beam Brightness | 0.80 | At the muzzle. |
| Beam in Daylight | 0.35 | The beam's strength in full light, as a share of its strength in the dark. |
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
| Debug Log | Off | Logs what the grenade-arc learner sees. |

## Works with

Runs on its own with any weapon mod.

- **BD22 VR Reloaded / Brutal Doom:** the full beam on every measured Brutal Doom gun and its off-hand copies, and the
  dot on that mod's true shot line.
- **RSQ Gun Bonsai VR (with Gun Bonsai and RSQ TacticalRig):** Target Lock and Headshot Reaction become upgrades you
  earn, after TacticalRig's Quick Draw. Level 1 of Target Lock is the lock, level 2 adds the target colour. Level 1 of
  Headshot Reaction is the colour change; level 2 makes a gun hit with your dot on a monster's head count as a
  headshot. While Gun Bonsai VR and TacticalRig are both loaded, each menu switch works once its upgrade is learned
  (learning turns it on, the switch can turn it off); with Gun Bonsai VR but no TacticalRig the upgrades can't exist,
  so the switches work as without it.
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
