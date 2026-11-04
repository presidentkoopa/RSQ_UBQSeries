# RSQ Glow In The Dark

Every room in the map lit by its own colour: walls washed up from the floor and down from the ceiling, pools of lava
and nukage breathing in their own light, and the doors, switches and keys you need standing out in the dark.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): the whole rewrite: everything on this page.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. It is the
owner's Glow In The Dark 1.1 (2021), rebuilt from scratch in ZScript and taken as far as the stock engine goes.

## Standout feature: 35 looks for any map, alive

Pick one of 35 named profiles (or Random, or your own Custom look) and every map you play wears it. Classic (1.1) gives each group of rooms its own random colour, the
way the original did. Hellfire flickers orange. Toxic Waste breathes sick green. Blood Moon beats a slow red
heartbeat. Aurora drifts northern lights along the ceilings. Lava Lamp rolls warm swells out from the middle of the
map. Each profile has its own palette, glow height, floor-to-ceiling balance and a slow pulse, and every one is
built to be gentle: nothing flashes.

The map answers what you do. A miniboss turns the whole map its colour and darkens it while it lives. A level-up
rolls a gold wave out from where you stand. A kill chain makes the glow climb. Slow motion drains it toward cold
grey. Something dying in a pool of nukage makes the pool flare.

All of it is written into the map's own sector glow, not painted on with lights, so it costs almost nothing: a still
look writes nothing at all after the map starts.

## Features

**Room glow**
- Floor and ceiling glow on every room's walls: a band of colour up from the floor and down from the ceiling.
- One colour per tag group (as 1.1 did) or per room, or whatever the profile decides; neighbouring rooms can blend.
- Colours re-roll every map (as 1.1), on each death, on each level-up, every few minutes, or never.
- Stronger in dark rooms, which pairs well with DarkDoomZ.
- Glow height and overall strength are yours to set.

**Liquids**
- Every liquid in Doom, the HD liquid packs and Brutal Doom's splashes glow in their own colour (the owner's own list
  of 591 flats).
- Living liquids: each kind breathes in its own rhythm, lava slow and heavy, water quick and light.
- Splash flares: something dying in a liquid flares the pool in that liquid's colour.
- Liquids in unknown map packs are found by name (nukage, lava, slime and the like) or by the map's own terrain.
- Liquid colour: their own, the profile's, or painted over by the room's colour exactly like 1.1.

**Things that matter**
- Switches, exits and teleporter pads glow. Locked doors glow in their key's colour, brighter and quicker once you
  hold the key. Ordinary doors get a faint cool edge.
- Keys and powerups are drawn at full brightness (optionally health and armour, or everything).
- Floors that hurt (and are not a known liquid) throb a slow red warning.
- Optional: secret rooms shimmer gold until you find them (off by default).

**Quality**
- Quest preset: no dynamic lights at all, a modest write budget. PCVR preset: a few real lights over the largest
  pools and on the most important items, in the Subdued style (double radius, half brightness).

**Honest limits.** The engine glows walls only: a floor or ceiling cannot glow on its own face. And the glow is per
room, not per pixel: one colour for a sector's floor glow and one for its ceiling glow.

## How To Play

1. Add RSQ_GlowInTheDark.pk3 to your load order. It works in VR and flat.
2. Open Options → Radiant Silvergun Options → RSQ Glow In The Dark. On a Quest, set Quality to Quest; on PC, PCVR.
3. Step through Profile with left and right. The line under it tells you what the look is.
4. Start a map. Try a few profiles in the same room to see them change.
5. Playing with DarkDoomZ? Pick a profile and press Use This DarkDoomZ Pairing: it sets DarkDoomZ's mode and preset
   to the ones that profile was made for.

## Controls

| Action | How | Notes |
|---|---|---|
| Change the look | Options → RSQ Glow In The Dark → Profile | Left and right step through every profile |
| New colours now | Shuffle Profile Now | |
| Everything else | Plays on its own | No buttons, no gestures |

## Menu

Options → Radiant Silvergun Options → RSQ Glow In The Dark

| Row | Default | What it does |
|---|---|---|
| Glow In The Dark | On | The whole mod |
| Profile | Classic (1.1) | Custom, Random Profile, or one of 35 named looks |
| Use This DarkDoomZ Pairing | | Sets DarkDoomZ's mode and preset to the profile's (with DarkDoomZ loaded) |
| Shuffle Profile Now | | New colours (and a new profile on Random) |
| Re-roll Colours | Every Map | Never, Every Map, On Each Death, On Each Level-Up, Every N Minutes |
| Every N Minutes | 5 | For Every N Minutes |
| Strength | 1.0 | Overall glow strength |
| Glow Height | 64 | How far the glow reaches up and down the walls |
| Quality | Quest | Quest or PCVR |

**Glow Types**

| Row | Default | What it does |
|---|---|---|
| Floor and Ceiling Glow | On | The room glow |
| Liquids Glow | On | Liquids in their own light |
| Liquid Colour | Profile Decides | Like 1.1 (Room Colour), Profile Decides, Always Their Own |
| Living Liquids | On | Each liquid breathes |
| Splash Flares | On | A death in a liquid flares it |
| Guess Liquids by Name | On | Liquids in unknown map packs |
| Floors That Hurt Throb Red | On | Damaging floors warn you |
| Secret Rooms Shimmer | Off | Gold until found |
| Stronger in the Dark | On | More glow in dark rooms |
| One Colour Per | Profile Decides | Profile Decides, Tag Group (1.1), Each Room |
| Blend Neighbouring Rooms | Off | Rooms made of several sectors read as one colour |

**Things That Matter**

| Row | Default | What it does |
|---|---|---|
| Switches, Exits, Locked Doors | On | Their walls glow; locked doors in their key's colour |
| Ordinary Doors Too | On | A faint edge on plain doors |
| Strength | 1.0 | How strong those glows are |
| Keys and Pickups Glow | Keys and Powerups | Off, Keys and Powerups, + Health and Armour, + Ammo and Weapons |

**Reactions** (each needs its mod loaded)

| Row | Default | What it does |
|---|---|---|
| Miniboss Tint (RSQ Miniboss) | On | The map takes a colour and throbs while a miniboss lives |
| Colour | The Miniboss's Own | Blood Red, The Miniboss's Own (red for now), Custom |
| Custom Colour | Red | For Custom |
| Darken the Map | On | The map darkens meanwhile |
| By | 48 | How much light |
| Level-Up Wave (Gun Bonsai) | On | A wave rolls out when a gun is ready to level up |
| Wave Colour | Gold | |
| Combo Glow (RSQ Score) | On | The glow climbs with the kill chain |
| Per Kill | 0.08 | Per kill, up to 10 |
| SlowMo Drain (RSQ SlowMo) | On | The glow drains toward grey in slow motion |

**Custom Look** (used when Profile is Custom): Floor Glow and Ceiling Glow (Any Colour, Fixed, A Profile's Colours,
Off), Colours From (a profile), fixed red, green and blue for each (135 grey), Strength (1.0), Colour Wander (0),
Floor Balance and Ceiling Balance (1.0), Pulse (Steady, Breathe, Heartbeat, Candle, Hue Drift, Ripple), its Speed (10
a minute) and Depth (0.3), and Liquids (Own Colour, Lean to the Room's, The Room's Colour).

**Tuning and Debug**: Rooms per Tic While Moving (128), Lights Over Pools (0), Lights on Items (0), Light Style
(Subdued), Colour Seed (1337, used with Re-roll Never), Debug Lines in the Console (Off), Reset All.

## Works with

Runs alone, with any map set. It finds the others by name:
- **DarkDoomZ** (Caligari87): the two pair naturally; each profile names a DarkDoomZ setting to go with it. During a
  miniboss it lowers DarkDoomZ's own brightness setting and puts it back afterwards, even after a quit mid-fight.
  Without DarkDoomZ the map's own light is lowered and given back exactly.
- **RSQ Miniboss**: the miniboss tint.
- **RSQ Gun Bonsai VR** (with Gun Bonsai): the level-up wave.
- **RSQ Score**: the combo glow.
- **RSQ SlowMo**: the slow-motion drain.
- **Brutal Doom**: its splash flats are in the liquid list.

## Credits and licence

- **presidentkoopa** (project owner): Glow In The Dark 1.1, "assembled and mostly written by PresidentKoopa": the
  idea, the menu, the floor and ceiling glow as he modified it, and the Glow list of every liquid in Doom, the HD
  liquids and Brutal Doom's splashes, shipped unchanged here. RS Radiance, his later direction for the idea (colour
  policies, seamless rooms, waves, reactive lighting), whose ideas are carried over where the engine allows.
- **ColorfulMaps** by Solid_Head, and NightFright's "Lite" offshoot of it, which 1.1's wall glow was built from. No
  ACS ships here; the ZScript is new.
- **GlowingLiquids** by Finder153, which 1.1's liquid glow was built on.
- The Subdued light style is the idea of the Subdued Lights mod (double radius, half brightness); nothing of that mod
  is used.
- **DarkDoomZ** by Caligari87 (Dark Doom concept by Josh771): played with, not bundled or changed.
- All ZScript written for this pack.
