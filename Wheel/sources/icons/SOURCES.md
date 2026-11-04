# RSQ Wheel: sources of the card icons

The owner's order of 2026-11-03: the fist, the lightsaber and the whip get their own icons on the Wheel's cards.
These files are the sources. They do not ship: the build only packs `graphics/`. `make_icons.py` and
`gen_whip_icon.py` turn them into the three textures that do ship.

| shipped texture | source here | origin | licence / credit |
|---|---|---|---|
| `graphics/WRIFIST.png` (28x17) | `ldl_SFISZ0.png` | **LegenDoom 3.0** (`LegenDoom_3.0.pk3`, `sprites/Fist/SFISZ0`): the brass knuckles, the `Inventory.Icon` of its standard fists (`LDFists`, `decorate/Fist/Fist.dec`). In the pk3 the lump is already a PNG (RGBA), so this is a byte-for-byte copy and no palette conversion is involved. | LegenDoom is by Yholl and its contributors (its own `CREDITS` file; Sgt_Shivers drew most of its weapon and icon art, Perkristian the smooth standard fist). It ships no licence text. Used on the owner's order and credited in `CREDITS.txt`. |
| `graphics/WRISABER.png` (98x98) | `dinopixel_jedi_lightsaber_danger_doughnut52.png` (800x800, as the owner supplied it) | **"Jedi Lightsaber (Star Wars)"** pixel art by **danger_doughnut52** on dinopixel.com, 24 Aug 2020: https://dinopixel.com/jedi-lightsaber-star-wars-pixel-art-2388 | Supplied by the owner. The artist and URL are credited in `CREDITS.txt`. The site gives no licence text with it. The design is Star Wars fan art. |
| `graphics/WRIWHIP.png` (86x79) | `gen_whip_icon.py` and its output `whip_icon.png` | **Original**, drawn for the Wheel by a script, pixel by pixel. It copies and traces no existing sprite. The Dragon Quest sprite the owner showed as a mood reference (Square Enix art) was not used. | The series' own work. |

How the shipped textures are made:
- **Fist:** taken as is (Doom pickup-icon scale, like the guns' own pickup sprites on the other cards).
- **Lightsaber:** the 800x800 file is drawn on an exact 8-pixel grid, so it is taken down to its own 100x100 art
  pixels by nearest-neighbour at exactly 1:8 (nothing is resampled or blended), then cropped to the art: 98x98.
  It was tried at 64 and 49 pixels by nearest-neighbour as well. Both drop rows of the hilt and the outline, so the
  card keeps the art's own pixels and the card's billboard sets the size it is drawn at, as it does for every other
  icon.
- **Whip:** drawn on a 96 grid in the lightsaber's style: flat leather shades lit from the top left, and a
  one-pixel dark outline round the shape and wherever one strand crosses over another. It has a wrapped handle with
  a knob, three loops of coil and a tapering tail with a pale cracker.

Rebuild: `python3 Wheel/sources/icons/make_icons.py` and `python3 Wheel/sources/icons/gen_whip_icon.py`. To
re-extract the fist from the pk3, use `make_icons.py --extract <LegenDoom_3.0.pk3>`.
