# RSQ Glow In The Dark: extension ideas

One line each: **what it does** | engine feature (stock QuestZDoom 17.3) | cost on Quest | needs from other mods.
Sources: [R] RS Radiance (the owner's later direction), [E] the owner's event notes (2026-11-03 18:23), [C] this lane.
Status after the owner's picks (18:26, 18:37, 18:43): **BUILT** (a row in the menu), **NOT WANTED**, or **OPEN**.

## Reactions to the game
1. **Level-up wave** [E] BUILT: a gold wave rolls out from the player across every floor/ceiling glow | plane glow per sector, sectors bucketed by distance when the wave starts, only the band's buckets written per tic | low | Gun Bonsai VR patch `RSQGB_Service` "level"/"name" per hand; without it, plain Gun Bonsai's own `bonsai-level-up` netevent.
2. **Combo glow** [E] BUILT: the glow climbs with RSQ Score's kill chain and settles after 4 s | colour gain + height | low | `RS_ScoreService` "kill.serial".
3. **SlowMo drain** [E] BUILT: the glow drains toward a cold grey while time is slowed | colour mix | low | `RSQSM_Service` "active", "scale".
4. **Miniboss tint** [E] BUILT: while an RSQ Miniboss lives, the map turns blood red (or its colour) with a heartbeat and darkens; back when it dies | colour + height on all sectors (near ones every 2 tics) | low | `RSQMB_Service` "miniboss" + "colour" (its set piece's colour).
5. **Low-health throb** [E] NOT WANTED.
6. **Berserk red** [E] NOT WANTED.
7. **Kills near liquids flare** [E] BUILT as splash flares (9).
8. **Keys -> matching doors brighter** [E] BUILT inside 15.

## Living liquids
9. **Splash flares** BUILT: a death in a pool flares it | one sector's glow | trivial | none.
10. **Breathing liquids** BUILT: each liquid kind its own colour and rhythm | explicit plane glow on the liquid list | low | none.
11. **Lights over pools** BUILT, capped: Quest 0, PCVR 4 | PointLight actors, spawned once per map, no shadows | the one real cost | none.
12. **Liquids by name and TERRAIN** BUILT: unknown packs' NUKAGE/LAVA/SLIME/BLOOD/WATER... flats glow too | name test at map start | none per tic | none.

## Colour control and profiles
13. **Profiles** BUILT: 35 named looks + Custom + Random Profile, one table (profiles.zs) | data | none | none.
14. **Custom look** BUILT: floor/ceiling Any (1.1) / Fixed (1.1's sliders) / a profile's colours / off; strength, wander, balance, pulse shape/speed/depth, liquids | none | none.
15. **Re-roll colours** BUILT: Never / Every Map / Each Death / Each Level-Up / Every N Minutes; Shuffle Profile Now | a seed, colours hashed from it (no reshuffle when a slider moves) | none | none.
16. **Quality preset** BUILT: Quest (0 lights) / PCVR (10 lights max, Subdued) | cvars | none | none.
17. **Light Style Normal / Subdued** BUILT: our lights at double radius, half brightness | none extra per light count; wider radius touches more surfaces | none.
18. **Per-liquid colour pickers** OPEN: pick nukage/lava/water/blood colours | cvars read at map start | none | none.

## Things that matter
19. **Switches, exits, locked doors in key colours, teleporter pads, doors** BUILT | sidedef tier additive colour (Side.SetAdditiveColor), pads by plane glow | none per tic but a few pulsing lines | none.
20. **Keys and pickups glow** BUILT: fullbright sprites (bBRIGHT), optional capped lights | none / capped | none.
21. **Floors that hurt throb red** [C] BUILT | plane glow | trivial | none.
22. **Secret rooms shimmer until found** [C] BUILT (off by default) | plane glow | trivial | none.
23. **Monster projectile glow** OPEN, not built: Brutal Doom already lights its projectiles; double cost.

## DarkDoomZ teamwork
24. **Stronger in the dark** BUILT: glow gain and height rise as a room's light falls | reads lightlevel when writing | none | none.
25. **Big moments darken the map** BUILT: through DarkDoomZ's ddz_postgain when loaded (saved, restored, also after a crash), else exact per-sector offsets | one write in, one out | DarkDoomZ optional.
26. **Profile -> DarkDoomZ pairing** BUILT: each profile names a DarkDoomZ Mode/Preset; one row applies it | menu writes ddz_mode/ddz_preset | none | DarkDoomZ.
27. **Flicker DarkDoomZ's flashlight on a miniboss** OPEN, not built: it would take the player's light away when he needs it.

## RS Radiance ideas, on QuestZDoom 17.3
28. **Seamless rooms (blend neighbours)** [R] BUILT (off by default) | map start only.
29. **Colour policies: texture-keyed, light-keyed** [R] OPEN | pure ZScript, cheap.
30. **Floor/ceiling FACE glow, far colour, falloff, inset, per-pixel waves/scanlines/cracks** [R] CAN'T: UZDXREMA engine only. Nearest QZD trick: the plane's additive colour (Sector.SetAdditiveColor) tints a floor without glowing it; OPEN as "Floor Face Tint".
31. **Emergency lighting / fire lights the room** [R] OPEN: needs RS_Ballistics' fixture and fire services (not in this series).
32. **Looks** [R] BUILT as profiles; fog/bloom/darkness halves belong to other mods (DarkDoomZ pairing covers darkness).

## Asks for other mods (hooks; the other mods were not edited)
- RSQ Miniboss: `GetInt("colour", "", 0, 0, boss)` -> RSQMB_Boss.col (0xRRGGBB). Asked already; until it answers the tint is blood red.
- RSQ Score: `GetInt("spree", "", 0, 0, pawn)` (RS_ScoreTracker.spreeCount) so the combo follows Score's own chain instead of counting scored kills 4 s apart.
- Gun Bonsai VR patch: `GetInt("player.level", "", 0, 0, pawn)` so player level-ups also send the wave.
- Any mod: `RSQGD_Service` events `event.wave`, `event.flare`, `event.tint`, `event.reroll` are open for big moments (a Saber parry, a Grapple landing, a Whip crack...).
