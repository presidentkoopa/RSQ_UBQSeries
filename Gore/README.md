# RSQ Gore
### Doom Arcade VR · Brutal Doom 22's gore, just as brutal, at a fraction of the cost

<p align="right"><a href="../README.md">&larr; RSQ UBQ Series</a></p>

**Phase 1 built, not yet rig-tested.** Hit blood, flying blood and trails, mist and arterial jets, SuperGore, liquid
checks and screen blood are taken over and drawn as VisualThinkers playing BD's actors tic by tic. The master switch (`rsqgo_on`) is **off by default**
until the owner's look pass: with it off the pk3 changes nothing at all.

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
| 1 | Hit blood, trails, mist, jets, SuperGore, liquid checks, screen blood; menu | **built** (151 classes, generated cards; not yet rig-tested; master switch off) |
| 2 | Spots, pools, ceiling spots, drips, footprints, smears; merge grid, rings | not started |
| 3 | Chunks, limbs and casings from generated cards | not started |
| 4 | Wall and ceiling launchers become traces; death recipes (BD and XMVE) | not started |
| 5 | XMVE's head and leg helpers become declarations and sensors (in RSQ Score, owner's Q1) | not started |
| 6 | Quest tuning, frame-time guard, the owner's look pass | not started |

## What phase 1 does

- **Takeover by name.** `RSQGO_Manager.CheckReplacement` swaps each phase 1 class for a generated card class
  (`RSQGO_K_<BD class>`, one map read per spawn) while `rsqgo_on` is on. RSQ Score's head bloods and hitboxes, BD's
  Dead.dec and everything of phases 2-6 are untouched. 13 phase 1 classes stay BD's (metal and bone "bloods", the
  player's bloods, the md3 water spots); `generated/cards_summary.txt` says why for each.
- **Hit blood** (`RSQGO_HitBlood`) works in PostBeginPlay and is gone on its first tic: BD's sound, the water branch,
  SlaughterCounter low blood, the saw branch (its items, quake and sound), the low-damage state skip, screen blood by
  A_RadiusGive's rule, the mirrored BSPR puff, and BD's blood level paths (Blood Level 1-5; 1 Low is today's look: BD's own option never reaches the blood, see CVARINFO.txt). Its
  five children never become actors.
- **Flying blood, trails, mist, jets, SuperGore** become TRACKS: BD's actor simulated tic by tic from its own states
  (frame, x/y scale with A_SetScale growth, alpha with fades, Bright), played by a VisualThinker through the engine's
  sprite path, so size, offsets and lighting are BD's; BD's odds, velocity from the spawn, BD's gravity, the path cut
  by one trace where it meets a wall or the floor. A drop that left a floor spot queues BD's spot class there, on the tic it
  would have landed; a wall hit paints BD's decal.
- **Liquid checkers** land, test the floor against BD's own liquid list (SPLASH.acs) and leave BD's WaterBloodSpot.
- **Two tiers.** Whatever decides an actor (spots, BD actors, screen blood) is the same on every machine
  (`random[RSQGO_Play]`, server cvars, geometry traces); VisualThinkers are per machine (a xorshift, camera distance, user cvars).

## Settings

Front page: RSQ Gore (`rsqgo_on`, off until the look pass), Gore (phases 3-4, no effect yet), Spray And Mist (All /
Some / None: particle density on this screen), Blood That Stays (phase 1: the floor spots our drops leave), Ceiling
Drips (phase 2, no effect yet), Screen Blood, Platform (PC / Quest). Test and Debug: Blood Level, particle shares of
`r_maxparticles` (All 50%, Quest 25%), the frame-time guard (off on PC, on for Quest), the residue budgets of later
phases, and the debug log (`rsqgo_debug`: a line every 350 tics). See [CVARINFO.txt](CVARINFO.txt).

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
- It also writes phase 1's pk3 content through **cards.py**: `zscript/rsqgo/cards.zs` (one class and one data card per
  taken-over class, simulated from BD's own states, with every track's keyframes) and `graphics/rsqgo/RSQGOnnn.png`
  (every frame a track shows: BD's UNTRANSLATED frame cut to its opaque box with its offsets kept; the only art RSQ
  Gore ships, all derived from BD's and XMVE's), plus `generated/cards_summary.txt`. Colour is never baked: the
  VisualThinker draws the frame through BD's own class translation at run time (or the bleeder's, which the engine
  writes into our hit-blood actor exactly as into BD's), so the engine squashes it to the palette the game actually
  loads, as it does BD's sprites (2026-11-27: the rotation's PLAYPAL is not doom2.wad's; a baked blue came out wrong).
  No TEXTURES, ANIMDEFS or GLDEFS for phase 1: a TEXTURES Translation or Colormap draws wrong in this engine.
- **track_report.py** writes `generated/track_report.txt`: per card, BD's actor as it shows (simulated afresh) beside
  the tracks the VisualThinkers will play; every difference is marked.
- **gore_lint.py** fails when a table class no longer exists, a class is claimed twice (or by RSQ Score too), a
  descendant falls through a category gap, the table or the phase 1 outputs are stale, a track names a missing baked frame, a card is not a phase 1 Gore class, a ZScript class declares one name twice in different case, or
  CVARINFO / MENUDEF / MAPINFO / build.sh disagree.

## Build

`sh Gore/build.sh` packs `RSQ_Gore.pk3` from an explicit list (`zscript.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt
README.md zscript graphics`). Load it after Brutal Doom 22 and XMVE. Without BD it stays inert.
