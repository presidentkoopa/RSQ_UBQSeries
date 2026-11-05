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

**Dynamic lights** (need the engine's dynamic lights on)
- Off by default (Quest): no dynamic lights at all. On PC, Lights Over Pools and Lights on Items add a few real lights
  over the largest pools and on the most important items, in the Subdued style (double radius, half brightness).

**Honest limits.** The engine glows walls only: a floor or ceiling cannot glow on its own face. And the glow is per
room, not per pixel: one colour for a sector's floor glow and one for its ceiling glow.

## How To Play

1. Add RSQ_GlowInTheDark.pk3 to your load order. It works in VR and flat.
2. Open Options → Radiant Silvergun Options → RSQ Glow In The Dark. On a Quest, leave Dynamic Lights at 0; on PC, try
   Lights Over Pools 4 and Lights on Items 6.
3. Step through Profile with left and right.
4. Start a map. Try a few profiles in the same room to see them change.
5. Playing with DarkDoomZ? Pick a profile and press Use DarkDoomZ Pairing: it sets DarkDoomZ's mode and preset
   to the ones that profile was made for.

## Controls

| Action | How | Notes |
|---|---|---|
| Change the look | Options → RSQ Glow In The Dark → Profile | Left and right step through every profile |
| New colours now | Shuffle Profile Now | |
| Everything else | Plays on its own | No buttons, no gestures |

## Menu

Options → Radiant Silvergun Options → RSQ Glow In The Dark: one page, with Test and Debug and Reset All at its foot.

| Row | Default | What it does |
|---|---|---|
| Glow In The Dark | On | The whole mod |
| Profile | Classic (1.1) | Custom, Random Profile, or one of 35 named looks |
| Shuffle Profile Now | | New colours (and a new profile on Random) |
| Use DarkDoomZ Pairing | | Sets DarkDoomZ's mode and preset to the profile's (greyed without DarkDoomZ) |
| Re-roll Colours | Every Map | Never, Every Map, On Each Death, On Each Level-Up, Every N Minutes |
| Re-roll Every (min) | 5 | For Every N Minutes |
| Strength | 1.0 | Overall glow strength |
| Glow Height | 64 | How far the glow reaches up and down the walls |
| *Glow Types* | | |
| Floor and Ceiling Glow | On | The room glow |
| Liquids Glow | On | Liquids in their own light |
| Liquid Colour | Profile Decides | Room Colour, Profile Decides, Always Their Own |
| Living Liquids | On | Each liquid breathes |
| Splash Flares | On | A death in a liquid flares it |
| Guess Liquids by Name | On | Liquids in unknown map packs |
| Hurt Floors Throb Red | On | Damaging floors warn you |
| Secret Rooms Shimmer | Off | Gold until found |
| Stronger in the Dark | On | More glow in dark rooms |
| One Colour Per | Profile Decides | Profile Decides, Tag Group, Each Room |
| Blend Rooms | Off | Rooms made of several sectors read as one colour |
| *Things That Matter* | | |
| Switches, Exits, Locks | On | Their walls glow; locked doors in their key's colour, brighter once you hold it |
| Ordinary Doors Too | On | A faint edge on plain doors |
| Things Strength | 1.0 | How strong those glows are |
| Keys and Pickups | Keys and Powerups | Off, Keys and Powerups, + Health and Armour, + Ammo and Weapons |
| *Reactions* (each needs the mod named) | | |
| Miniboss Tint (Miniboss) | On | With RSQ Miniboss: the map takes a colour and throbs while a miniboss lives |
| Tint Colour | The Miniboss's Own | Blood Red, The Miniboss's Own (the colour of its own beaded lines and life orbs), Custom |
| Custom Tint | Red | For Custom |
| Darken the Map | On | The map darkens meanwhile |
| Darken By | 48 | How much light |
| Level-Up Wave (Gun Bonsai) | On | A wave rolls out when a gun is ready to level up |
| Wave Colour | Gold | |
| Combo Glow (RSQ Score) | On | The glow climbs with the kill chain |
| SlowMo Drain (RSQ SlowMo) | On | The glow drains toward grey in slow motion |
| *Custom Profile* (used when Profile is Custom) | | |
| Floor Glow / Ceiling Glow | Any Colour | Any Colour, Fixed (the sliders below), A Profile's Colours, Off |
| Colours From | (a profile) | The profile A Profile's Colours uses |
| Floor Red / Green / Blue | 135 | The fixed floor colour |
| Ceiling Red / Green / Blue | 135 | The fixed ceiling colour |
| Custom Strength | 1.0 | |
| Pulse | Steady | Steady, Breathe, Heartbeat, Candle, Hue Drift, Ripple |
| Custom Liquids | Own Colour | Own Colour, Lean to the Room's, The Room's Colour |
| *Dynamic Lights* (need the engine's dynamic lights on) | | |
| Light Style | Subdued | Normal, or Subdued (double radius, half brightness; wider lights touch more walls, so each costs more) |
| Lights Over Pools | 0 | Real lights over the largest pools (0 = none) |
| Lights on Items | 0 | Real lights on the most important items (0 = none) |
| Reset All | | Every setting on both pages back to its default |

**Test and Debug**: Rooms per Tic (128), Colour Seed (1337, used with Re-roll Never), Combo Per Kill (0.08, up to 10
kills), Custom Profile's Colour Wander (0), Floor Balance and Ceiling Balance (1.0), Pulse Speed (10 a minute) and Pulse
Depth (0.3), Debug Log (Off, One Line per Map, + Every Second).

## Works with

Runs alone, with any map set. It finds the others by name:
- **DarkDoomZ** (Caligari87): the two pair naturally; each profile names a DarkDoomZ setting to go with it. During a
  miniboss it lowers DarkDoomZ's own brightness setting and puts it back afterwards, even after a quit mid-fight.
  Without DarkDoomZ the map's own light is lowered and given back exactly.
- **RSQ Miniboss**: the miniboss tint, in the miniboss's own colour.
- **Gun Bonsai** (ToxicFrog's): the level-up wave, from Gun Bonsai alone; with RSQ Gun Bonsai VR, for each hand's gun.
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
