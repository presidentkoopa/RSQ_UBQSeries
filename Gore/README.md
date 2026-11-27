# RSQ Gore
### Doom Arcade VR · Brutal Doom 22's gore, just as brutal, at a fraction of the cost

<p align="right"><a href="../README.md">&larr; RSQ UBQ Series</a></p>

**Not playable yet.** This is phase 0: the scaffolding, the class generator and the lint. The pk3 loads and does
nothing, and its master switch is off.

**What it will be:** one pk3, loaded like any other (no autoload), that takes Brutal Doom 22's and XMVE's gore classes
over by name as they spawn. BD and XMVE are not edited. Every death variant still plays, with BD's own sprites, models,
decals and sounds. What moves is the cost:

- **Liquid** (hit sprays, flying blood and trails, mist, arterial jets) becomes engine particles and parked
  VisualThinkers: no actors, no per-tic script.
- **Wall blood** becomes decals.
- **Floor and ceiling blood** becomes one parked, non-thinking actor each, merged and pooled.
- **Meat and limbs** are actors only while they fly, then freeze under a hard cap, oldest recycled.
- **Head and leg shots stay RSQ Score's.** RSQ Gore touches none of Score's classes.

With the master switch off, BD's own gore runs exactly as today. The full design is
[design/GORE_SYSTEM_DESIGN.md](../design/GORE_SYSTEM_DESIGN.md).

## Phase status

| Phase | Content | Status |
|---|---|---|
| 0 | Generator, lint, scaffolding; rig measurements (BD's blood level, XMVE helpers, decal and corpse cvars; parking and flipbook experiments) | **generator, lint and scaffolding built**; rig measurements are the main lane's |
| 1 | Hit blood, trails, mist, jets, SuperGore, liquid checks, screen blood; menu | not started |
| 2 | Spots, pools, ceiling spots, drips, footprints, smears; merge grid, rings | not started |
| 3 | Chunks, limbs and casings from generated cards | not started |
| 4 | Wall and ceiling launchers become traces; death recipes (BD and XMVE) | not started |
| 5 | XMVE's head and leg helpers become declarations and sensors (in RSQ Score, owner's Q1) | not started |
| 6 | Quest tuning, frame-time guard, the owner's look pass | not started |

## Settings (phase 0: declared, not read yet)

`rsqgo_on` (off until the phases ship), Gore / Spray And Mist / Blood That Stays (All, Some, None; All is BD's intended
blood level 2), Ceiling Drips, Screen Blood, Platform (PC / Quest). Budgets per platform: on PC 512 floor spots, 128
ceiling spots, 160 landed chunks, 192 flying chunks; the Quest preset about a third; the frame-time guard off on PC and
on in the Quest preset. See [CVARINFO.txt](CVARINFO.txt).

## Tools

Run from the series folder, with the real pk3s (read-only, straight from the zips):

```
python -I Gore/tools/gen_gore.py  <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>
python -I Gore/tools/gore_lint.py <1.00_brutal22test6.pk3> <1.3-XMVE_MonsterExpansion1.3.1-BD22.pk3>
```

- **gen_gore.py** reads both packs' DECORATE (following `#include`) and writes `generated/takeover_table.txt` (every
  gore class from the design's section 4 and its descendants: category, phase, owner, parent, flags, the Spawn
  sequence's shape and what it spawns) and `generated/takeover_summary.txt` (counts per category, what could not be
  categorised, and the design's claims checked against the data). Never hand-edit either.
- **gore_lint.py** fails when a table class no longer exists, a class is claimed twice (or by RSQ Score too), a
  descendant falls through a category gap, the table is stale, or CVARINFO / MENUDEF / MAPINFO / build.sh disagree.

## Build

`sh Gore/build.sh` packs `RSQ_Gore.pk3` from an explicit list (`zscript.txt MAPINFO.txt CVARINFO.txt README.md
zscript`). Load it after Brutal Doom 22 and XMVE. Without BD it stays inert.
