# RSQ Wheel import tools

Palettes, fonts and voxel pictures you collect go into the Wheel as selectable styles without any hand work.
Python 3 with Pillow, nothing else.

## The one command

Put what you collected in a folder:

```
my_styles/
  palettes/   PICO-8.gpl  sweetie-16.hex  neon.ase  playpal.lmp  strip.png ...
  fonts/      DejaVuSans-Bold.ttf  Arcade_8x8.png  terminus.bdf  ErmacDigits/ (a folder of one-glyph PNGs)
  voxels/     ErmacDigits/ (a folder of PNGs: one voxel each)
```

then, from `Wheel/tools/import/`:

```
python3 import_all.py my_styles --pk3 my_styles/RSQ_Wheel.pk3
```

This copies the Wheel folder to `my_styles/../Wheel_imported`, writes everything into the copy, makes a picture
of each import in `Wheel_imported/import_previews/`, and (with `--pk3`) zips the copy into a pk3 to load in place
of RSQ_Wheel.pk3. Your Wheel folder is not touched unless you say `--into <Wheel folder>`. Running it again
replaces what it wrote before; it never adds a second copy.

In the game: Options -> Radiant Silvergun Options -> RSQ Wheel -> Palette / Font (the new names are in the
lists), or the console: `wr_palette PICO-8`, `wr_fontset DejaVuBold`.

Options: `--wheel <Wheel>` (which Wheel to copy, default the one these tools sit in), `--out <folder>`,
`--into <Wheel>`, `--pk3 <file>`, `--avoid <pk3/wad ...>` (mods you load: new font names and voxel sprite
names are picked so they clash with none of their lumps; give it your IWAD and Brutal Doom files).

To change how one file is read, put the options in a file beside it named `<file>.args` (for a folder,
`args.txt` inside it), e.g. `DejaVuSans-Bold.ttf.args` holding `--size 14 --name DejaVuBold`.

## What each tool takes and writes

**wr_import_palette.py** - GIMP .gpl, JASC/RIFF/raw .pal, .hex/.txt hex lists (lospec), Adobe .ase, .act,
a Doom PLAYPAL (.lmp, or found inside a .wad/.pk3), a PNG swatch strip or grid. Writes a `palette <Name> { ... }`
block in WRPALS.txt and adds the name to the Palette menu. How colours go to the ring's roles: card faces and
backgrounds take the palette's dark colours, numbers and dim text its middle ones, words, the hover glow, the
laser and the slot colours its bright ones; within that, each role takes the colour nearest the ring's own
colour for it (so the warmest bright goes to hover, the reddest to the laser and empty-ammo, the bluest to slot 4).
Roles the ring draws in one colour always get the same one (hover = sheet_hot; slot4 = alt_bar = sheet_cool).
Override any role with `--roles map.txt` (lines like `hover 5`, `laser FF2010`, `idle name:Navy`,
`sheet_bg keep`). The preview shows the palette numbered, every role, and the slot colours on the stone as the
ring tints it.

**wr_import_font.py** - .ttf/.otf/.ttc (drawn at `--size` pixels, sharp edges; `--aa` for soft), .bdf/.pcf
bitmap fonts, a PNG glyph sheet (cell size in the name, `Arcade_8x8.png`, or `_8x8_first33` when it does not
start at the space; or `--cell 8x8 --first 32`), or a folder of one-glyph PNGs named by the character (`A.png`,
`065.png`, `digit_7.png`, `percent.png`). Pixel fonts are copied pixel for pixel. Writes one PNG cell per
character at `graphics/wrimport/<PFX>/<PFX><code>.png`, a TEXTURES block naming them, a `fontset` line in
WRFONTS.txt and the name in the Font menu. A font with letters draws the words, one with all ten digits the
numbers; a digits-only font keeps DoomFont for words (`--words` / `--numbers` choose: `font`, or one of the
ring's own `WRG` `WRD` `WRY` `WRN`). `--colour white` (outline and bitmap fonts) makes glyphs white so the
palette colours them fully; `keep` (PNG sources) keeps their shading.

**wr_make_voxels.py** - PNG files or folders (an imported font's cell folder works too). One KVX voxel per
picture: each opaque pixel a column `--depth` voxels deep (default 2), the picture's own colours (`--tint
RRGGBB` to colour white glyphs, `--pal <palette>` to snap to e.g. PLAYPAL). Writes `voxels/<frame>.kvx`, a
VOXELDEF block (`--scale`, default 1), and a small ZScript class `wr_vox_<Name>` that makes the sprite frames
exist (VOXELDEF binds a voxel only to a sprite some actor uses) and shows each voxel for a second when spawned.
The frame list (which picture is which frame) is at the top of that class. The picture faces the way the
actor faces, upright and not mirrored.

## Limits (the ring's, from wr_q_look.zs and wr_q_shim.zs)

- The ring draws text upper case, one fixed-width cell per character, characters 33..95 only (digits, A-Z,
  punctuation); anything else is a blank cell. So proportional fonts get even spacing, sized by the widest glyph.
  Lower-case-only fonts lend their letters to the upper-case cells.
- A character the font lacks gets an empty cell, never a missing texture.
- Names: letters, digits, `-` and `_` (the ring splits on spaces and braces). The ring's own names
  (Standard, Doom, Hell, Tech; StatusBar, SmallGold, SmallGrey, DoomFont) get `Imp` added.
- No limit on how many palettes or font sets: the ring looks the chosen name up when it opens.
- Cell names are a 3-letter prefix (always W.., never WR.., which is the ring's) plus the 3-digit code: 6
  characters, inside the 8 a lump name can have.
- Voxels: up to 26 a sprite name (frames A..Z); a picture at most 255 pixels tall.
- The shipping build (build_all.sh) needs `graphics voxels VOXELDEF.txt` in the Wheel's file list to carry
  imports made with `--into` (the patch in the helper's delivery adds them); `--pk3` packs everything already.
