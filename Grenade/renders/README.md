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
