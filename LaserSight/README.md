# Laser Sight (RSQ LaserSight)

**The one thing:** the laser comes out of the gun's real barrel in either hand, and the dot is where the shot truly
lands (Brutal Doom VR's own shot line), with the grenade launcher's arc.

A laser from each gun's own barrel, in either hand, with a dot where the shot will land. The beam is drawn on the
gun's model, so it stays on the barrel at headset frame rate. The dot follows Brutal Doom VR 2.0's real shot line,
shows a grenade launcher's arc, and reacts to monsters and surfaces. For stock QuestZDoom 17.3, VR; script only, no
engine changes. It replaces the laser sight bundled with QuestZDoom. Needs no other mod; best with Brutal Doom VR
2.0, whose guns it was measured from.

## Features

**The beam.**
- A beam from the muzzle of the gun in each hand, along its barrel, brightest at the muzzle and fading over the Beam
  Look's length. It rides the gun model, so it never trails the gun.
- The beam stops where the trace hits, so it never shows through a wall.
- A gun without a measured model gets no beam, only the dot. Brutal Doom VR 2.0's guns are measured; stock Doom's
  sprite guns are not.
- Beam in Daylight: real beams show in the dark; in full light the beam is dimmer.

**The dot.**
- A dot where the shot lands, painted on the surface: flat on a wall, floor or ceiling, a billboard on a monster.
  Constant apparent size.
- Dot Glow: a bloom round it, a real light of its colour, or both.
- **Follow Brutal Doom VR Shots:** with Brutal Doom VR 2.0 the dot follows its muzzle and bore, so it sits where the
  bullet holes land.
- **Dot Reacts to Surface:** the dot swims on water, slime, lava and blood; it glints on metal.
- **Target Lock:** on a live monster the dot grows and pulses. **Target Colour Change:** it turns the target colour.
- **Headshot Reaction:** the top fifth of a monster turns the dot the headshot colour, with its own pulse.
- **Grenade Arc:** a grenade launcher shows its arc and landing spot, once it has fired once. Arc With Beam keeps the
  straight beam too.
- **Spread Ring:** a ring at the dot showing this gun's spread, learned from its shots.
- **Show Range:** a range readout by the gun or at the dot, in metres, feet or map units.
- **Infrared Only:** the laser is visible only through light amplification goggles.

**Colours.**
- One colour, a colour per hand (main red, off green), or beam and dot coloured separately, from colour pickers.
- Colour per Slot: a colour per weapon slot. Cycle Colours: the colour runs through the hues, the dot too if you like.

**When it goes off.**
- Point the gun down past 55 degrees and the laser goes off; raise it and it comes back.
- Off while a gun is switched or holstered. Only When Ready also hides it while reloading.
- No laser on fists, the chainsaw, the saber, the shield or an empty hand (unless Show on Melee).
- Two-hand a rifle on SteamVR and the off-hand laser stands down while the engine steadies the gun.

## How to play

Both lasers are on by default. Nothing to bind.

- **Aim:** hold a gun. The beam leaves its muzzle; the dot sits where the shots go.
- **Lower the gun:** point it down past 55 degrees and the laser goes off. Raise it and it is back.
- **Switch weapons:** the laser is off while the gun is switched or holstered.
- **Grenade launcher:** fire once. From then on the laser shows the arc and the dot is where the grenade lands.
- **Melee:** fists, chainsaw, saber, shield and empty hands show no laser.
- **Turn a laser off by hand:** Customize Controls -> **RSQ Laser Sight** -> "Laser on/off (main hand)" and "Laser
  on/off (off hand)". The same two are on the mod's Controls page as Toggle Main Hand and Toggle Off Hand. No default
  binds. A tick in the hand tells you it toggled (Toggle Haptics).

## Settings

Options -> Radiant Silvergun Options -> **RSQ Laser Sight**.

| Menu row | Default | What it does |
|---|---|---|
| Laser Sight | On | The whole mod. |
| Main Hand | On | The main hand's laser. |
| Off Hand | On | The off hand's laser. |
| Show Beam | On | The beam from the muzzle. |
| Beam Look | Standard | Subtle / Standard / Bold: the fade length, brightness and daylight together. |
| Show Dot | On | The dot where it lands. |
| Dot Size | Standard | Small / Standard / Large. |
| Dot Glow | Bloom and Light | Off / Bloom / Light / Bloom and Light. |
| Colour Mode | Per Hand | One Colour / Per Hand / Beam and Dot. |
| Main Hand Colour | red | The main hand's colour. |
| Off Hand Colour | green | The off hand's colour. |
| Show on Melee | No | Show the laser on melee weapons and empty hands. |
| Only When Ready | No | Hide while switching or reloading. |
| Dot Reacts to Surface (water, metal) | On | The dot swims on liquids and glints on metal. |
| Follow Brutal Doom VR Shots | On | With Brutal Doom VR 2.0, the dot follows its muzzle and bore. |
| Off When Pointed Down Past (deg, 0 = never) | 55 | Laser off when the gun points down past this. |
| Infrared Only | Off | Only visible through light amplification goggles. |

**More Colours**

| Menu row | Default | What it does |
|---|---|---|
| Main Hand Dot | red | The main hand's dot colour, for Beam and Dot mode. |
| Off Hand Dot | green | The off hand's dot colour, for Beam and Dot mode. |
| Colour per Slot | Off | A colour per weapon slot. |
| Slot 1 to Slot 0 | red, orange, yellow, green, cyan, blue, purple, magenta, white, red | The colour of each slot. |
| Cycle Colours | Off | The colour cycles through the hues. |
| Dot Cycles Too | On | The dot cycles with the beam. |

**Targets and Extras**

| Menu row | Default | What it does |
|---|---|---|
| Target Lock | On | On a live monster the dot grows and pulses. |
| Target Colour Change | Off | The dot turns the target colour on a monster. |
| Target Colour | yellow | That colour. |
| Headshot Reaction | Off | The top fifth of a monster turns the dot the headshot colour. |
| Headshot Colour | white | That colour. |
| Headshot Pulse | On | The dot pulses on a head. |
| Grenade Arc | On | A grenade launcher shows its arc and landing spot, once it has fired once. |
| Arc With Beam | Off | Keep the straight beam as well as the arc. |
| Spread Ring | Off | A ring at the dot showing this gun's spread. |
| Show Range | Off | Off / By the Gun / At the Dot. |
| Units | Metres | Metres / Feet / Map Units. |

**Controls**

| Menu row | Default | What it does |
|---|---|---|
| Toggle Main Hand | unbound | The main hand's laser on or off. |
| Toggle Off Hand | unbound | The off hand's laser on or off. |
| Toggle Haptics | On | A tick in the hand when you toggle a laser. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Beam Fade Length | 3.0 | Metres the beam takes to fade to nothing. |
| Beam Brightness | 0.8 | Brightness at the muzzle. |
| Beam in Daylight | 0.35 | Beam brightness in full light, as a share of the dark. |
| Dot Size | 1.0 | The dot's size. |
| Dot Brightness | 1.0 | The dot's brightness. |
| Glow Size | 1.8 | The bloom's size (times the dot) and the light's reach. |
| Glow Intensity | 1.0 | The glow's strength. |
| Trace Range | 2048 | How far the trace looks, map units. |
| Dot Range Limit | 0 | No dot beyond this; 0 = as far as the range. |
| Dot Lead (Tics) | 0.0 | Tics the dot is drawn ahead of the hand. |
| Cycle Speed | 60 | Degrees of hue a second. |
| Lock Tighten | 0.0 | The dot shrinks onto a locked monster by this share. |
| Lock Pulse Rate | 2.2 | The lock's pulse, Hz. |
| Headshot Pulse Rate | 4.0 | The headshot pulse, Hz. |
| Arc Dot Size | 1.0 | The arc's dots. |
| Arc Brightness | 0.8 | The arc's brightness. |
| Ring Minimum Spread | 0.75 | Degrees: a spread tighter than this draws no ring. |
| Ring Brightness | 0.6 | The ring's brightness. |
| Readout Size | 1.0 | The range readout's size. |
| Reset All | - | Every RSQ Laser Sight setting back to its default. |

## Works with

- **RSQ Gun Bonsai VR** (with Gun Bonsai and RSQ Tactical Rig): Target Lock and Headshot Reaction become unlocks in
  its Gunslinger tree, after Quick Draw. Target Lock 1 is the lock, 2 the Target Colour Change; Headshot Reaction 1
  is the reaction, and at 2 a gun hit with your dot on a monster's head counts for Critical Hits' Headshot. While it is
  loaded the three menu rows are not read; without it they work as before.
- **RSQ Distance Grab:** Laser Sight tells it which hands have a live laser, and the grab hides its own beam on those
  hands (its Yield to Laser Sight row).
- **RSQ Accessibility:** colour-blind colours per hand (a lock is then told by shape, not colour), Photosensitive Mode
  caps the pulses at 2.5 Hz, Cue Size scales the dot, glow and arc, Text Size the readout. Steady Hands: the dot and a
  grenade's arc are traced from the smoothed hand, so they sit steadier on a far wall; the beam stays on the gun.
  Rumble Strength 0: no toggle tick.
- **Brutal Doom VR 2.0:** the beams are measured from its guns, and the dot follows its shot line.

## Load order

After Brutal Doom, the voxel pack, BD22 VR Reloaded, the monster packs and Gun Bonsai, among the RSQ pk3s. Works
alone on plain Doom 2, dot only.

## Known limits

- No beam on guns without a measured model (sprite guns, and guns from packs other than Brutal Doom VR 2.0). The dot
  still shows on those, from the grip along your aim.
- The off-hand stand-down when two-handing is SteamVR only; on Quest it does nothing.
- Follow Brutal Doom VR Shots does nothing without Brutal Doom VR 2.0.

## For other mods

- `RSQLS_SightService`: `GetInt("laser.active", "", hand)` is 1 if a laser (beam or dot) drew on that hand (0 main,
  1 off) last tic; `GetInt("laser.beam", "", hand)` the same for the beam alone; `GetInt("head.on", "", 0, 0,
  monster)` is 1 when the console player's dot sat on that monster's head this tic or the last and they have Headshot
  Reaction 2.
- A weapon pack can give its own muzzle points and colours through two services it defines, found by name:
  `LaserMuzzleService` (`GetString("laser.muzzle", class, hand, 0, weapon)`) and `LaserColorService`
  (`GetInt("laser.color", class, hand, isDot, weapon)`). No RSQ mod provides them today.

## Credits

RSQ_LaserSight -- credits (from CREDITS.txt, unchanged):

A laser from each gun's own barrel, part of the Radiant Silvergun Quest series. For stock QuestZDoom 17.3: ZScript
and lumps only, no engine changes. Made by the project owner (presidentkoopa) and this pack.

INSPIRED BY (no code or assets taken)
- Laser Sight by m8f (Alexander Kromm, github.com/mmaulwurff/laser-sight), GPLv3 -- the laser sight bundled with
  QuestZDoom (laser-sight-0.5.5-vr.pk3). This pack replaces it; nothing of its code or sprites is used here.

GENERATED FOR THIS PACK
- The beam voxels (models/rsqls/beam/*.kvx, VOXELDEF.txt) and the muzzle table (zscript/rsqls/muzzles.zs):
  tools/gen_beams.py, measured from Brutal Doom Quest's own gun models.

QuestZDoom (Emawind and Team Beef): the engine and the hand-pose script API.
