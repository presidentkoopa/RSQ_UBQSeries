# RSQ Glow In The Dark

Your Glow In The Dark 1.1 (October 2021), rewritten in ZScript for QuestZDoom 17.3 and taken as far as the engine
lets us. Load `RSQ_GlowInTheDark.pk3` instead of the old `GlowInTheDark.pk3` (both would paint the same walls).

Options -> Radiant Silvergun Options -> RSQ Glow In The Dark.

Out of the box it looks like 1.1 (profile **Classic (1.1)**), plus: liquids keep their own colour and breathe,
locked doors glow in their key's colour, and the reactions below wake up when their mods are loaded.

## The main page

- **Profile**: 35 named looks plus **Custom** and **Random Profile**. Each sets the floor and ceiling colours, how
  strong and tall the glow is, the floor/ceiling balance, a pulse (steady, breathe, heartbeat, candle, hue drift,
  ripple), how liquids are coloured, and a DarkDoomZ pairing. Classic (1.1), Classic Doom, Hellfire, Toxic Waste,
  Neon Arcade, Synthwave, Vaporwave, Blood Moon, Deep Ocean, Arctic, Radioactive, Gothic Candle, Lava Lamp,
  Ultraviolet, Matrix Green, Sunset, Monochrome, Inferno, Aurora, Cyberpunk, Witching Hour, Sepia, Ghost, Toxic
  Rainbow, Ember, Abyss, Overcast, Holy, Corruption, Biohazard, Martian, Glacier, Firefly, Disco (slow: colours turn
  once every 10 s, nothing flashes), Minimal. They are one table (`zscript/rsqgd/profiles.zs`): add a line, get a
  profile.
- Under it: the profile's one-line description and its **DarkDoomZ pairing**; **Use This DarkDoomZ Pairing** sets
  DarkDoomZ's Mode and Preset to it (only when DarkDoomZ is loaded).
- **Shuffle Profile Now**: a different profile and new colours, now.
- **Re-roll Colours**: Never / Every Map (1.1's way) / On Each Death / On Each Level-Up / Every N Minutes. With
  Random Profile, a re-roll also draws a new profile.
- **Strength**, **Glow Height**, **Quality** (Quest: no dynamic lights at all; PCVR: a few soft ones).

## Glow Types page
Floor and Ceiling Glow (1.1's wall glow) / Liquids Glow, with Liquid Colour (Like 1.1 / Profile Decides / Always
Their Own), **Living Liquids** (each liquid breathes in its own colour and rhythm), **Splash Flares** (something dying
in a pool flares it), Guess Liquids by Name (unknown map packs, Oblige) / **Floors That Hurt Throb Red** / Secret
Rooms Shimmer (off: it gives secrets away) / **Stronger in the Dark** (the darker a room, the more its glow carries it:
made for DarkDoomZ) / One Colour Per (tag group like 1.1, or each room) / Blend Neighbouring Rooms (off).

## Things That Matter page
Switches (amber), exits (green, breathing), **locked doors in their key's colour** (breathing; brighter and quicker
once someone holds the key), teleporter pads (cyan shimmer), ordinary doors (a faint cool edge). Done with the wall
part's own additive colour: no lights. **Keys and Pickups Glow**: drawn at full brightness (keys and powerups by
default; health/armour and ammo/weapons as you choose).

## Reactions page (each needs its mod; none needs any other)
- **Miniboss Tint** (RSQ Miniboss): while a miniboss lives, the whole map's glow turns blood red (or its own colour,
  once RSQ Miniboss can say it) and throbs with a heartbeat; the map darkens so the colour carries it (with
  DarkDoomZ, through DarkDoomZ's own post-gain, put back after). Back to normal when it dies.
- **Level-Up Wave** (Gun Bonsai): a gold wave rolls out from you across every floor and ceiling glow.
- **Combo Glow** (RSQ Score): the glow climbs brighter and taller with each kill in a chain, and settles after.
- **SlowMo Drain** (RSQ SlowMo): while time is slowed the glow drains toward a cold grey.

## Custom Look page
Used when Profile is Custom: floor and ceiling each Any Colour (1.1) / Fixed (1.1's sliders) / A Profile's Colours
/ Off, strength, colour wander, balance, pulse and its speed and depth, liquid colour.

## Tuning and Debug page
Sectors per tic while moving, lights over pools, lights on items, **Light Style: Normal / Subdued** (double radius,
half brightness, like the Subdued Lights mod: softer pools; a wider light touches more walls, so it costs more per
light), the colour seed, debug lines, Reset All.

## Cost
Everything is the plane glow 1.1 used (the engine's own sector glow: free to draw) plus wall additive colours.
One pass at map start; a still look writes nothing per tic; a moving one re-writes the rooms near you every 2 tics
and the rest of the map in eighths. Dynamic lights are the only real cost and are hard-capped:
**Quest preset: 0 lights. PCVR preset: at most 10 (4 over pools, 6 on items).** Measured numbers: see
docs/PROOF.md.

## Plays well with DarkDoomZ
DarkDoomZ (Caligari87, not bundled) darkens light levels and fog and adds a flashlight. This mod writes only glow
colours; the one time it touches light (a miniboss's darkness) it goes through DarkDoomZ's own Post-Gain setting
and puts it back, so DarkDoomZ re-lights the map itself. Found by name; nothing breaks without it.

## For other mods
`RSQGD_Service` by name: reads (`enabled`, `liquid`, `profile`, `darkdoomz`...) and events (`event.wave`,
`event.flare`, `event.tint`, `event.reroll`). See `zscript/rsqgd/service.zs`.

## What the engine can't do (QuestZDoom 17.3, no engine changes)
- A floor or ceiling cannot glow on its own face: the engine's sector glow lights only the walls next to it. (RS
  Radiance's floor/ceiling faces, far colours, falloff, inset and per-pixel waves/scanlines/cracks are UZDXREMA.)
- Glow is per sector, not per pixel: a wave steps room by room.
- A sprite's glow is fullbright or a dynamic light; there is no cheap halo.
- A key's lock colour from LOCKDEFS is not readable from ZScript; locks 1-6 and 129-134 use Doom's colours.

## Next (ideas not built yet, for you to pick)
See docs/EXTENSION_IDEAS.md (each with its engine feature and Quest cost), and the hooks other mods could add there.

## Tested
Rig only (the QuestZDoom 17.3 rig, simulated headset), not headset-confirmed. docs/PROOF.md lists what was shown.
