# RSQ Glow In The Dark: extension ideas

One line each: **what it does** | engine feature (stock QuestZDoom 17.3) | cost on Quest | needs from other mods.
Sources: [R] RS Radiance (the owner's later direction), [E] the owner's event-reaction notes (2026-11-03 18:23),
[C] this lane. Status after the owner's picks (2026-11-03 18:26): **PICKED** (being built),
**NOT WANTED**, or open.

## Reactions to the game

1. **Level-up wave** [E] PICKED: a gold wave ripples out from the player across every floor glow on a Gun Bonsai level-up | plane glow colour/height written per sector by distance ring (a precomputed distance per sector, a few hundred sectors per tic at most) | low: ~1 s, only sectors the ring is crossing are written | Gun Bonsai VR patch's `RSQGB_Service` "level" (read by name); a "player.level" request would let it answer player levels too.
2. **Score combo intensifies** [E] PICKED: the map's glow climbs brighter/taller with RSQ Score's kill chain, falls back when the chain lapses | glow height + colour gain on the glowing sectors | low: one re-write of the coloured sectors per step change | RSQ Score's `RS_ScoreService` "kill.serial" (read by name). A "spree" request (its RS_ScoreTracker.spreeCount) would let it read Score's own chain instead of counting kills itself.
3. **SlowMo shift** [E] PICKED: while RSQ SlowMo slows the world, the glow drains toward grey-blue | colour lerp on the coloured sectors | low: written on enter/leave and while easing | `RSQSM_Service` "active", "scale".
4. **Miniboss tint** [E] PICKED: while an RSQ Miniboss lives the whole map's glow turns blood red (or the miniboss's own colour) and throbs like a heartbeat; back to normal when it dies | colour + height animation on the coloured sectors | low-medium: the whole coloured set is re-written at ~6 Hz while it lives | `RSQMB_Service` "miniboss". A "colour" request (RSQMB_Boss.col) would give the miniboss's own colour; asked for, falls back to blood red.
5. **Low-health throb** [E] NOT WANTED.
6. **Berserk red** [E] NOT WANTED.
7. **Kills near liquids flare** [E]: a kill standing in a liquid flashes that liquid's glow | per-sector glow height pulse | trivial | none (WorldThingDied). (Folded into splash flares, 9.)
8. **Keys picked up -> matching doors brighter** [E] PICKED as part of 15: a key in hand lifts its doors' glow.

## Living liquids (owner pick a)

9. **Splash flares** [C] PICKED: a thing landing in or dying in a liquid flares that pool's glow for half a second | plane glow height/colour on one sector | trivial | none.
10. **Pulsing liquids** [C] PICKED: liquid glow breathes (each liquid type its own colour and rhythm) | explicit plane glow colour per liquid sector, animated | low: liquid sectors only, at 7 Hz | none.
11. **Dynamic lights over liquids** [C] PICKED (capped): a few real point lights over the largest pools, coloured by liquid | PointLight actors (no shadowmaps) | medium: capped at 2 (Quest) / 8 (PCVR) per map, off with the Quest preset's cap at 0 | none.
12. **Name heuristics for unknown packs** [C] PICKED: flats whose names say NUKAGE/SLIME/LAVA/BLOOD/WATER/MAGMA/ACID/OOZE/POIS glow too (Oblige, OTEX, megawads) | name test at map start | none per tic | none. Also the engine's TERRAIN IsLiquid.

## Colour control (owner pick b)

13. **Colour per glow type + sliders** [C] PICKED: floor, ceiling, liquid each with Random/Palette/Fixed, strength, height, pulse speed | plane glow | none per tic | none.
14. **Quest / PCVR presets** [C] PICKED: one row sets the light cap, pulse rate and wave detail | cvars | none | none.

## Things that matter glow (owner pick c)

15. **Doors, switches, exits, locked doors in key colours** [C] PICKED: sectors behind door specials glow, locked doors in their key's colour, exit lines' sectors green/white, switches' sectors amber | plane glow on the sector behind the line | none per tic | none.
16. **Keys and pickups glow by type** [C] PICKED: keys, powerups, health, armour, ammo get a soft coloured dynamic light (capped) | attached PointLights (A_AttachLight) | low-medium, capped per map | none.
17. **Monster eye / projectile glow** [C]: monsters' projectiles carry a light | A_AttachLight on spawn | medium-high with Brutal Doom's projectile counts; Brutal Doom already lights its projectiles | none. Not built: cost and double-lighting with BD.

## DarkDoomZ teamwork (owner pick d)

18. **Glow stronger where it is darkest** [C] PICKED: the glow height and brightness scale up as a sector's light falls (so DarkDoomZ's darkness makes the glow carry the room) | reads Sector.lightlevel at apply time | none per tic | none (DarkDoomZ found by name only for the menu's note).
19. **Big moments darken the map** [E][C] PICKED: during the miniboss tint the map's light falls by a set amount and comes back after; with DarkDoomZ loaded it is done through DarkDoomZ's own `ddz_postgain` (its menu's post-gain), read back and restored exactly, so DarkDoomZ re-lights the map itself and nothing fights over sector light | DarkDoomZ cvar write (server) / without it, a temporary sector light offset restored exactly | low: one write in, one out | DarkDoomZ (optional).
20. **Drive DarkDoomZ's flashlight** [E]: flicker the flashlight on a miniboss arrival | would need to toggle DarkDoomZ_Flashlight (its Use state) | trivial | Not built: it would turn the player's light off when he needs it; listed for the owner.

## Customisation (owner's words: "Random, random on death, random on map load. Other stuff.")

21. **Random everywhere** PICKED: every colour choice offers Random.
22. **Re-roll colours: Never / Every Map / Each Death / Each Level-Up / Every N Minutes** PICKED.
23. **Palettes** PICKED: Classic (1.1's full range), Neon, Hellfire, Toxic, Cool, Random palette.
24. **Shuffle now** PICKED: one menu command.
25. **Colour each sector separately** [R]: instead of 1.1's one colour per tag group | plane glow | none | none. PICKED as "Random By: Tag Group (1.1) / Sector".

## RS Radiance ideas (REMA engine) and what QuestZDoom 17.3 can do with them

26. **Four lanes: wall-floor seam, wall-ceiling seam, floor face, ceiling face** [R]: QZD has the two seam lanes (plane glow on walls). The faces (a floor glowing itself) need UZDXREMA's SetFlatGlow*; QZD's nearest is the plane's additive colour (Sector.SetAdditiveColor), a flat tint, not a glow. Open: a "Floor Face Tint" option using it.
27. **Colour policies: fixed / random / texture-keyed / light-keyed, in an HSV window with a seed** [R]: all pure ZScript. Palettes (23) cover the HSV window; texture-keyed and light-keyed are open (cheap).
28. **Far colour, falloff, inset, intensity per lane** [R]: REMA engine only (SetGlowColorFar / Falloff / Inset / Intensity do not exist on QZD).
29. **Seamless walls (blend colours across neighbouring sectors)** [R]: pure ZScript at map start (two passes over sectors) | none per tic. Open.
30. **Emergency lighting / fire lights the room** [R]: needs RS_Ballistics' fixture and fire services (not in this series). Open.
31. **Waves and surface detail (scanlines, cracks, grain)** [R]: REMA per-pixel shader only. The level-up wave (1) is the QZD version, per sector.
32. **Looks (Golden Hour, Vaporwave, Red Alert ...)** [R]: palettes (23) are the glow half; the fog/bloom/darkness halves are other mods' business.
33. **Shuffle preset each map / on death** [R]: PICKED as re-roll timing (22).

## Asks for other mods (hooks, not built here; the other mods were not edited)

- RSQ Miniboss: `GetInt("colour", "", 0, 0, boss)` -> RSQMB_Boss.col (0xRRGGBB), so the tint can wear the miniboss's colour.
- RSQ Score: `GetInt("spree", "", 0, 0, pawn)` -> RS_ScoreTracker.spreeCount (and "spree.expire"), so the combo glow follows Score's own chain.
- Gun Bonsai VR patch: `GetInt("player.level", "", 0, 0, pawn)` -> Gun Bonsai's player level, so player level-ups also send the wave.
