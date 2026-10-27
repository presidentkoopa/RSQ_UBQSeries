# RSQ_TopHPBars (UBQ / RSQ suite)

The series' version of **Top HP Bars 1.04 by coldcite** (based on SpriteShadow by Nash Muhandes). coldcite's header: "Feel free to use this in your mods. You don't have to ask my permission!" Credit coldcite and Nash in CREDITS.txt; check SpriteShadow's own terms before shipping.

- `original_1.04/`: coldcite's pk3, unpacked, unmodified. The default look and layout (owner: "the default tophpbars ui is amazing, I love the layout").
- Lossvoise's flat retexture (of Mere_Duke's version; zdoom forum thread t=56910) is NOT in this repo or the pk3 until Lossvoise and Mere_Duke give permission; credit chain coldcite -> Mere_Duke -> Lossvoise.

Owner's brief (10-27):
- Keep coldcite's layout. Add colour schemes, including colourblind schemes (read `rsqa_colorblind` from RSQ_Accessibility when loaded).
- Fix: overhealed monsters (health above 100%) -- the bar pops up undamaged and can't show over 100% (coldcite's own known issue).
- Works on vanilla, Brutal Doom and other monster sets; voxel monsters (Cheello's Voxel Doom II) and our tumbling/yanked monsters place the bar correctly.
- Plays well with damnums (Xaser, loaded alongside, never bundled).
- Optional arcade info on the bar from the series' services: hooked (RSQ_Grapple), stunned, locked on (ShieldSaw), Force-gripped (QuestSaber).

## The pk3

`sh build.sh` regenerates the art (`tools/gen_art.py`, from `original_1.04/graphics` only) and packs
`RSQ_TopHPBars.pk3` from `pk3/`. Load it anywhere after the monster mods. Options -> **RSQ HP Bars**.

| Path | What |
| --- | --- |
| `pk3/zscript/rsqthp/handler.zs` | settings once a tic, who gets a bar, coldcite take-over, series markers, Champions icon lift |
| `pk3/zscript/rsqthp/bar.zs` | the bar, the overheal strip, the marker icons |
| `pk3/zscript/rsqthp/voxels.zs` | a voxel frame's real top (VOXELDEF + KVX header) |
| `pk3/TEXTURES.rsqthp`, `pk3/graphics/rsqthp/` | generated -- do not hand-edit |
| `tools/gen_art.py`, `tools/cvd_check.py` | the art, and the colour-vision measurement of every set |
| `test/` | probe (never shipped), runner for rig A, frame tools |

### Colours
`rsqthp_scheme`: Classic (coldcite's A, his files byte for byte), Red (his B), Protanopia, Deuteranopia,
Tritanopia, High Contrast. When RSQ_Accessibility is loaded and `rsqa_colorblind` is not Off it decides
(1 protan, 2 deutan, 3 tritan, 4 high contrast). The colour-blind and high-contrast sets carry cues that
are not colour: the low band (under 40 %) is hatched and pulses gently, the mid band has a dark centre
line, high contrast has a white rim, a dark backing and is always full bright.

### Overheal
A thinner strip one pixel above the bar, in the same 10-block grid, holds the health above spawn health,
one spawn-health's worth per lap; laps past the strip are diamond pips at its right end (up to 4).
150 % = full bar + half strip; 300 % (a LegenDoom Lite legendary) = full bar + full strip + 1 pip.

### Series markers
Icons left of the bar, drawn at twice its scale, fixed slots (nearest first): hooked, stunned, locked,
gripped. Asked by name every 4th tic per bar (play scope), each mod in its own words:

| Icon | Mod / Service | Request (objectArg = monster) | Shown when |
| --- | --- | --- | --- |
| hooked | RSQ_Grapple `RSQGR_Service` | `"hooked"` (tics since on a line, 0 on it), `"yanked"` | hooked 0..3, or yanked 1/2 |
| stunned | RSQ_Grapple `RSQGR_Service` | `"stunned"` (added on agent-thp) | == 1 |
| locked | UltraBadassShieldSaw `SSQ_ScoreService` | `"locked"` (added on agent-thp) | == 1 |
| gripped | UltraBadassQuestSaber `UBQS_SaberService` | `"gripped"` (added on agent-thp) | == 1 |

Any other mod can drive all four with 1/0 answers from a Service whose class name contains `RSQTHP_Marker`.

### Loaded with coldcite's own pk3
Every name differs, so both load. While RSQ HP Bars is on, it takes his bar item off every monster the
tic after it appears and his bars remove themselves: one bar per monster. His HUD Options entry opens our
menu when his pk3 loads first. Switch ours off (HP Bars: Off) and his bars show for monsters that appear
from then on (the next level); items already taken stay taken.

### Other monster mods (looked at, nothing bundled)
- **LegenDoom Lite 4.2**: its legendaries get 300 % health by ACS (APROP_Health, no StartHealth), the
  overheal case: they get a bar at once with a full strip and one pip.
- **Champions**: its tier icon floats at the champion's Height x 1.1, where the bar is, so a bar over a
  champion that wears its icon is lifted above it (`champion_PersistentInfo`, `champion_Icons`,
  `champion_IconScale`, `champion_Dormant` read by name). Champions rewrites StartHealth to the boosted
  health when it sets a champion up, so a set-up champion reads 100 % at its boosted health (its design).
