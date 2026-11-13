# Data behind design/BD_XMVE_TIERING.md (2026-11-13)

Every value here was read from the mods' code by the scripts in `tools/`. Nothing was run in the engine.

| File | What it holds |
|---|---|
| `data/ch_ladder.csv` / `.json` | All 17 ColorfulHell families × 13 colours plus the 11 EX forms: class, parent, file:line, HP, HP × Common, speed, pain chance, estimated attack, abilities scan |
| `data/family_curves.csv` | Per family: ColorfulHell's raw HP ratio, the proposed HP multiplier (climbs every step), speed and pain-chance multipliers |
| `data/bd_xmve_ladders.md` / `.csv` | Every BD22 and live XMVE monster: base HP, file:line, family, entry colour, how it appears, HP at all 13 colours |
| `data/hp_drops.json`, `hp_drops_verdicts.csv` | The 43 ColorfulHell steps where HP falls, the "envelope" (ladder health) values, and a verdict per step |
| `data/colour_kits.csv` | The colour kits (PROPOSAL) by kind of monster, with ColorfulHell evidence |
| `data/colour_features.txt` | Raw scan of every ColorfulHell colour class (projectiles, damage types, flags, damage factors) |
| `data/spawn_tud05.json`, `spawn_doom2_06.json` | Exact XMVE spawner odds (05 TUD, 06 Doom 2) |
| `data/xmve_reach.json`, `xmve_live_files.txt` | How each XMVE class can appear; which XMVE files actually load |
| `data/bd22.json`, `xmve.json`, `xmve_live.json`, `*_damage.json` | Raw parses of BD22 and XMVE monster code |
| `data/report_table.txt` | The per-monster table as plain text |

`tools/` holds the parsers and generators. They were written for one-off scratch work and still read and write
`/tmp/econ3/tiering/data`, `/tmp/bd22src` (BD22 unpacked) and `/tmp/xmve_0x` (XMVE unpacked). To re-run them, unpack the
pk3s to those paths, or change the path constants at the top of each script.
