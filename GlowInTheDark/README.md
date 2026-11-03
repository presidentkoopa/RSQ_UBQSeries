# RSQ Glow In The Dark

Your Glow In The Dark 1.1 (October 2021), rewritten in ZScript for QuestZDoom 17.3. Load `RSQ_GlowInTheDark.pk3`
instead of the old `GlowInTheDark.pk3` (they would both paint the same walls).

Options -> Radiant Silvergun Options -> RSQ Glow In The Dark.

## What it does, in plain words

- **Floor and Ceiling Glow** (on): every room's walls glow a band of colour up from the floor and down from the
  ceiling, a random colour per map, like 1.1. Rooms that share a tag share a colour, untagged rooms share one, as
  1.1 did. Every room is coloured the moment the map starts (1.1 reached tagged rooms one tag per tic).
- **Liquids and Lit Flats Glow** (on): your Glow list (every Doom liquid, the HD liquids, Brutal Doom's, screens,
  exit signs) glows in each flat's own colour. The list is your `gldefs.bm`, shipped unchanged as `GLDEFS.txt`.
- **Liquids Keep Their Own Colour** (on): new. In 1.1 the floor/ceiling colour painted over the liquids (the engine
  only uses a liquid's own glow when the room has no glow colour, and 1.1 gave every room one), so nukage glowed
  whatever random colour the room got. On, nukage glows green, lava orange, water blue. Off is 1.1 exactly.
- **Glow Height**: how far up and down the walls the glow reaches (1.1 always used 64).
- **Fixed Colours**: the colour sliders instead of random (1.1's "Override randomization").
- Settings now take effect within a second, no map restart, and are remembered between sessions (1.1 forgot them).

## Plays well with DarkDoomZ

DarkDoomZ (Caligari87, not bundled) darkens the map's light levels, fog and adds a flashlight. This mod never
touches any of those: it only sets each room's glow colour. The glow is added on top of the light, so the darker
DarkDoomZ makes the map, the more the glow carries the room. The mod finds DarkDoomZ by name (the debug line says
"DarkDoomZ found").

## For other mods

`RSQGD_Service`, found by name: `enabled`, `planes`, `liquids`, `liquid` (a sector index), `darkdoomz`. See
`zscript/rsqgd/service.zs`.

## Tested

Rig only (the QuestZDoom 17.3 rig, simulated headset), not headset-confirmed.
