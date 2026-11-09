# Grenade renders (mockups, never shipped)

Python-composited mockup GIFs of the barrel and grenade explosions, 2026-11-09. Pixel art throughout. `*_full.gif` is
game speed (35 tics/s), `*_half.gif` half speed, `*_contact.png` key frames. Nothing here goes into the pk3 (build_all.sh
packs Grenade from an explicit list that does not include `renders/`).

## Barrels: the owner's numbering

| # | Name | Files |
|---|---|---|
| 1 | Flash pop | `barrels/early/1_flash_pop_half.gif` |
| 2 | Hollow-out | `barrels/early/2_hollow_out_half.gif` |
| 3 | Shockwave (first) | `barrels/early/3_shockwave_half.gif` |
| 4 | Dirty finish | `barrels/early/4_dirty_finish_half.gif` |
| 5 | Snap | `A1_snap_*` (v1), `A1_5_snap_v2_*`, `A1_5_snap_v3_*` |
| 6 | Heavy | `A1_heavy_*` (v1), `A1_6_heavy_v2_*`, `A1_6_heavy_v3_*` |
| 7 | Pillar | `A1_pillar_*` (v1), `A1_7_pillar_v2_*`, `A1_7_pillar_v3_*` |
| 8 | Groundbreaker | `B1_shockwave_*` (v1), `B1_shockwave_v2_*`, `B1_shockwave_v3_*` |
| 9 | Slag column | `B2_slagcolumn_*` (v1), `B2_slagcolumn_v2_*` (final: unchanged in v3) |
| 10 | Neon crescent | `B3_neoncrescent_*` (v1), `B3_neoncrescent_v2_*`, `B3_neoncrescent_v3_*` |

`barrels/early/5_random_reel_fullspeed.gif` is 1-4 mixed at random, not a sequence of its own.

- `v1/`: the first six. Owner's notes: #7's flame sprites and #6's fire at tics 6-9 not pixelated enough; #8 and #9 not
  centred; #5 liked as it was; the barrel flashing before it blows liked.
- `v2/`: pixel art only, End of Starchild's barrel-death structure (reference only, none of its art), #8-#9 re-centred.
  Owner: "all of them are great", #7 the favourite ("that's the kind of life i want to see here").
- `v3/`, the build target: #8 dead centre on every layer, #9's bouncing debris on all the others, #10 with smoke and
  more life. #9's final is `v2/B2_slagcolumn_v2_*`.

## Grenade

`grenade/`: the frag blast on the floor (`G_frag_floor_*`) and shot out of the air (`G_frag_air_*`, the skill-shot reward
beat), `G_contact.png`, and `G_kinds_contact.png` (the blast tinted for each grenade kind; a proposal). Owner: "very
pleased with all four grenade tosses".

## Sources

RS Combat FX (the owner's), Reactorcore explosion minipack (CC0 by page comment only), Rufaswan magma sheet ("credits
not necessary", credited anyway), and fx_sheet_2 (domes and fire ring in #6, source unknown) — see
`design/assets/fx_sheets/README.md`. The barrel in the renders is the project's BAR1A voxel; the grenade shown is a
stand-in (the UAC Survival Pack's thrown sprite).

## Contexts (the blast changes with where it goes off)

`contexts/`: modifiers on the approved blasts, never new blasts. Owner: "i want them all"; these four greenlit 2026-11-09.
- `C_wall_barrel_*` (#5 base), `C_wall_grenade_*`: the blast folds flat against the wall and fans along it; sparks and
  shrapnel bounce back; a scorch stays. Detected by short side traces (a hit within ~40 units).
- `C_ceiling_barrel_*` (#6 base): fire spreads flat along a low ceiling, smoke pools under it, a soot band stays.
  Detected when floor-to-ceiling is under ~96 units and not sky.
- `C_sky_barrel_*` (#7 base): the column climbs out of sight and leaves a tall smoke column. Detected when the ceiling
  above is sky.
- `C_water_barrel_*` (#6 base), `C_water_grenade_*`: a white flash, no fire, a bubble dome rising to a surface splash,
  silt. Detected when the blast point is under the sector's water.
- `C1_contact.png`: key frames, one row per shot.
- `C_liquid_{nukage,lava,blood}_*` (#6 base): a crown of liquid spikes, ripple rings, drops falling back, a stain that
  stays, the light tinted to the liquid. Detected from the floor texture.
- `C_chain_*`: five barrels, each set off by the last, each bigger (#5, #5 x1.25, #6, #6 x1.2, then a mega finale; this
  render's finale is the Metal Slug example, which cannot ship — the own-material mega in `mega/` is its replacement).
  Detected when a barrel's killer is another barrel's blast.
- `C_crowd_*` (#6 base): imps killed by the blast gib, with a beat of held frames (slow motion) and a flat tint.
  Detected from the kills of one blast in the same tic (3+ suggested).
- `C_colour_room_*`: the blast in the complement of the room's GlowInTheDark colour. `C_colour_kill_*`: the blast takes
  the tier colour of what it killed (the tier colours here are the designer's picks; the ladder has no colour values).
- `C2_contact.png`: key frames for these seven.

Owner, 2026-11-09 10:24: "i approve all barrel designs" (the six, the eight contexts, the mega blast).

## Mega blast (our own material)

`mega/`: the big-barrel / chain-finale blast rebuilt from our material only (owner's choice after the Metal Slug example
in `Renders/fx_mockups/`): a pillar stem and a domed mushroom cap of Reactorcore fireballs and fire puffs, a dome slam with
a second floor ring, the cloud darkening with fire veins, lifting, then dust falling and settling. No Metal Slug pixels
(it was used for timing and silhouette only); `MEGA_vs_MS.png` puts the two side by side. 108 tics (20 barrel + 88 blast).
Sources: Reactorcore (CC0 by page comment), Rufaswan (credit anyway), RS Combat FX embers, the rest drawn in code.

## Mega blast, non-mushroom (the owner's preferred look)

`mega2/`: the mega blast rebuilt as a wide boiling block (no stem, no cap), from our material only, after the owner
preferred the Metal Slug example's non-mushroom look. Swell, climb, boil with re-igniting fireballs, brown with red veins,
lift, break up, dust. 108 tics. `MEGA2_vs_MS.png` compares it with the Metal Slug example. No Metal Slug pixels.
