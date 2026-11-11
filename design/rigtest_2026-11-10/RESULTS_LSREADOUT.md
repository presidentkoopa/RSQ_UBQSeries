# Rig 11-10: RSQ Laser Sight's range readout, rebuilt as glyphs

Owner's decision (11-10) on P4's L5 finding (the readout's value was right, 341 u, but nothing was drawn): **"Redo it as
glyphs"**. The canvas readout (RSLRANGE) is gone; each character is now a billboard glyph actor (picnum, AddShaded in
the dot's colour, two layers deep), the way RSQ Score's wrist digits and the Saber's training-remote panel do it.

**Rig only, not headset-confirmed.** One map load (launch E: MAP01, the owner's order from `run.sh` + a readout probe,
1440 px an eye), BD22's pistol, the beam pitched 29 degrees up into the ceiling as in P4's L5 (`qz_rhand "0.20 1.40
-0.35 60 -25 0"`), then level onto a wall. No script error from our packs (the four errors in every launch are
BD_VoxelPack's VOXELDEF).

| Check | What was shown | Evidence |
|---|---|---|
| By the Gun, Map Units | "341 u" beside the pistol, on the hand's outer side, clear of the gun, in the dot's red | LS_READOUT_by_the_gun_u_m_ft.jpg (left), LS_READOUT_log.txt (LSR_GUN_U) |
| By the Gun, Metres | "11 m" (10.5 m; whole metres from 10 m) | the same, middle (LSR_GUN_M) |
| By the Gun, Feet | "34 ft" | the same, right (LSR_GUN_FT) |
| At the Dot, Map Units, steep shot | "341 u" UNDER the dot on the ceiling (over it was inside the ceiling) | LS_READOUT_at_the_dot_u_m_ceiling.jpg (left), log (LSR_DOT_U) |
| At the Dot, Metres | "11 m" under the dot | the same, middle (LSR_DOT_M) |
| Readout Size row | Readout Size 3: the same "11 m" three times the size | the same, right (LSR_DOT_M_SIZE3; log scale 0.070 -> 0.209) |
| At the Dot on a wall | "12 m" over the dot, as the old design placed it | LS_READOUT_at_the_dot_wall.jpg (LSR_DOT_WALL_M) |
| Show Range Off | every glyph hidden ("shown 0") | log (LSR_OFF) |
| Spawned once, never per tic | glyph actors alive: 0 before the first show, 8 from then to the end (4 characters x 2 layers), whatever the text | log, every line |

## What changed (LaserSight)
- `zscript/rsqls/sight.zs`: `RSQLS_ReadoutGlyph` (the glyph actor); `UpdateReadout` builds the text ("341 u", "11 m",
  "34 ft"), lays the glyphs out across the line from the eye and moves them; `UiTick` and the canvas are gone.
  `readM` / `readU` / `readRgb` stay (probes read them) and `readTxt` is new.
- `graphics/rsqls/RSLN*.png`: 0-9 . m f t u, white, one 48 px cell each, grAb at the centre, rendered by
  `tools/gen_readout_glyphs.py` from DejaVu Sans Bold (`tools/fonts/`, Bitstream Vera licence; CREDITS.txt). The
  series' own glyph sets (STCFN, RSSCFON / the Saber's QVW, JFO) have no lowercase, so "m", "ft" and "u" could not come
  from them.
- Removed: `ANIMDEFS.txt` (only RSLRANGE), `models/rsqls/rslsread.md3`, `sprites/rsqls/RSLQA0.png`, the readout model
  in `MODELDEF.txt` and `tools/gen_assets.py`. Nothing else used them.
- Size: as the old screen meant it: a digit 0.875 map units tall at scale 1 (SmallFont x2 on the old 2-unit quad), x
  Readout Size, x Accessibility's Text Size, At the Dot x clamp(metres / 4, 1, 8). Glyphs keep the font's shape (the
  world's 1.2 vertical stretch undone, as the old model's CORRECTPIXELSTRETCH did).
- Two placement fixes the frames asked for: By the Gun, the old spot (centred 8 cm up the barrel, 9 cm over the grip)
  put the first digit behind the gun held up, so the row now starts 3 cm past the drawn muzzle as seen from the eye, on
  the hand's outer side. At the Dot on a steep shot, "over the dot" was inside the ceiling, so it goes under the dot
  when over would cross the ceiling, and is pulled 2 units + 2% of the distance toward the eye so a wall never cuts it.

## For the owner
- **At the Dot is small at its old size**: past 4 m it stays about 0.37 degrees tall (a 2.6 cm digit read at 4 m), a
  tenth of By the Gun's. At 1440 px an eye it is a few pixels (the crops are enlarged 2.5x). Readout Size 3 reads well.
  Whether the default should be bigger is your call; nothing was changed there.
- The By the Gun row sits off to the side of your view when you look ahead (it needs a glance down and right, as in
  the frames); in the headset that is a matter of where you look.

| At the Dot, constant apparent size (owner 11-10: "Constant size with distance") | At 10.5 m the digit's glyph scale is 0.207 (By the Gun 0.027): "341 u" and "11 m" read clearly by the ceiling dot at Readout Size 1; Readout Size 3 three times that. READ_DOT_DEG 1.1 deg, never below the old size up close | LS_READOUT_at_the_dot_constant_size.jpg (t525 u, t595 m, t662 size 3, t700), _log.txt |
