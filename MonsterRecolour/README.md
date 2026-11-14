# RSQ Monster Recolour: the painted colour art (branch `wip/2026-11-13-recolour`, not on main)

Hand-made recoloured frames for Brutal Doom's and XMVE's monsters on the colour ladder, drawn **without new sprite
names**, so they cost **no sprite frames** under QuestZDoom 17.3's 65,535-frame cap. Approved by the owner for the BD
and XMVE series (2026-11-13 18:01). The first family is BD22's Imp (its body, deaths, crawlers, gibs, fatality and frozen
death) in all twelve colours; the other families are being painted on this branch.

**rig only, not headset-confirmed.** Nothing here has been seen in the owner's headset.

**Status (owner's words, relayed by the main session 2026-11-13):**
- **The art style is approved for every BD22 and XMVE monster** (11-13 18:01: "The new art you have is lovely lets use
  that, i approve for the bd and xmve series").
- **The Zombieman, Shotgunner and Chaingunner families are approved as baked** (commits 2ef01fbe2b and f7f1a74ca2;
  11-13 19:19: "i approve."), with the choices written in their family files: the black and gray uniforms keep their
  gray (only the skin takes the colour), bloodstains stay red.
- **Later** (11-13 19:20: "the grey guys could use some blood, it's fine, we'll come back to it in some later update i
  guess but the rest look amazing"): the gray-uniformed men, BD22 ShotgunGuy and SMGGuy, XMVE's QSG, Rocket, Riot and
  Pyro sergeants, and ZSpecOps. Their uniforms keep their gray today; to be revisited with per-frame masks or a human
  painter.

**Since 2026-11-13 (integration) this folder holds the ART and its tools only.** The code that draws it is RSQ Monsters'
(`Monsters/zscript/monsters/RS_BDArt.zs`; see "How it works" below and `Monsters/README.md`), and the art ships as one
pk3 per colour, `pk3/RSQ_MonsterArt_<Colour>.pk3`, built by `tools/build_monster_art.py` (also run by
`tools/build_all.py` and `build_all.sh`). The prototype's own pack files (its `zscript/`, `MAPINFO`, `CVARINFO`, `GLDEFS`)
are gone; `rsrc_on` / `rsrc_debug` are now RSQ Monsters' `rsq_mon_art` / `rsq_mon_art_debug`.

| Folder / file | What |
|---|---|
| `rsrecolour/<colour>/<LUMP>.png` | the art, written by the bake (`Monsters/tools/recolour/bake.py`), one PNG per source sprite lump per colour |
| `hand/<colour>/<LUMP>.png` | frames painted by hand: the bake copies them over its own output, so they always win |
| `brightmaps.txt` | every BD22 + XMVE sprite's GLDEFS brightmap, read once from the load order (`tools/build_monster_art.py --brightmaps`), so the art build needs nothing outside the repo |
| `rsrecolour/GLDEFS.rsrecolour`, `rsrecolour/manifest.txt` | the bake's own lists for the family it last baked; not shipped (the art build writes each colour's GLDEFS from `brightmaps.txt` and whatever PNGs exist) |
| `docs/` | the sheets |

## The art: recoloured per part, not tinted (2026-11-13, replaces the first bake)

The owner (11-13): "i thought we agreed to step away from a flat tinting?" The first bake ran the approved tint recipes
over each pixel, so every recoloured pixel went through one hue: a flat tint in a PNG. The art in `rsrecolour/` is now
painted by `Monsters/tools/recolour/paint.py` with each colour's own palettes (`ramps.py`):

- **Parts.** Each pixel's nearest Doom palette index says which part it is: skin (the brown ramp 64-79 and its darkest
  and lightest neighbours), horn (spikes, claws and teeth: the grays 80-111). Everything else keeps its own pixels: eyes,
  mouth, blood and guts (the reds; the owner's rule 11-13 09:49), fire and its light on the hand (TRO1), the near-black
  outlines, the marine in the fatality, the frozen imp's ice. Where the ranges overlap, the family file's group rules
  and hand-written masks decide (`families/imp.txt`, `families/imp_masks.txt`): grays touching red are teeth or bone and
  stay white; near-black pixels inside the body are its deepest skin shadow; the fatality's marine (tans 128-159, his
  gun and belt) and the frozen imp's ice highlights are kept.
- **A palette per part per colour, with hue shifts.** Five colours per part (deepest shadow, shadow, base, light,
  highlight) whose hues move the way sprite artists move them: Green goes blue-green in the shadows and yellow-green in
  the lights, Yellow burnt orange-red to cream, Red wine-purple to hot orange-pink, White blue-gray to cream.
- **Spikes contrast the skin**, as ColorfulHell's hand-made imps do (its Yellow has red spikes, its Black silver ones;
  learnt from, not copied): Green yellowed bone, Blue steel, Purple gold, Cyan frost, Brown ivory, Yellow blood red,
  FireBlu flame, Gray dark basalt, Red black-to-bone, Abyss spectral teal, Black bright silver, White charcoal.
- **The original shading is kept.** The pixel's own lightness (Oklab L) across the part's range in the whole family picks
  its place on the ramp, so every shade the artist drew stays a separate shade; Black and White get steeper mid tones so
  they keep their muscles. The source's own painted variation (a flush, a dirty patch: saturation and hue lean against the
  part's average at that shade) is carried over.
- **FireBlu, no speckle.** The recipe alternated red and blue by palette row, which speckled. FireBlu is now a burning
  top (flame red-orange) that cools down the body into a blue-flame lower half, blended smoothly down the sprite's own
  height (through magenta, not gray), with flame spikes and claws.
- **Kept on the flat tint, on purpose:** `BOSBA0`-`BOSBE0` (BD22's Hell Knight art, listed in the family by its sprite
  name; only `BOSBF0` is an imp gib) and `X728` (XMVE's Dark Imp grabbing a marine: its own black look). `manifest.txt`'s
  last column says `paint` or `tint` per lump.

Shown on the rig (runs `rc2_old`, `rc2_new`: the owner's full order with his saved ini, `-skill 6`, rig01, sector light
224; no script error from these packs; the frames were cut into the sheets and the runs deleted). Test-only settings for
the sheets, not his: Universal Entropy's random recolour off (`ue_recolour 0`, else the as-shipped imp is a random
colour), the weapon, laser sight and Kill Rewards hidden, Legion of Bones' skeletons taken away by the test handler
(`Monsters/tools/recolour/rig/rc2demo`), static RNG.

| Sheet | What |
|---|---|
| `docs/imp_01_green_old_vs_new.jpg` .. `docs/imp_12_white_old_vs_new.jpg` | one per colour: as shipped, old tint bake, new art; front, side, plain death (frozen mid-fall, then dead), legs shot off (crawler, then dead) |
| `docs/imp_12colours_new_art_closeup.jpg` | the twelve colours side by side, front and side, in good light |

BD picks each death at random, so a death pose can differ between the old and new runs, and a body thrown sideways can
leave its tile (Black's mid-fall tile, for one).

## Why not new sprites: the frame cap (measured 2026-11-13)

| | frames |
|---|---|
| The owner's full order (`rig/work/full.sh`'s list with this branch's pk3s), read from the engine (gdb, run `rc_count0`) | **64,295** of 65,535: **1,240** to spare |
| The same order with this prototype loaded (run `rc_count1`) | **64,295**: unchanged |
| Every BD22 + XMVE tierable monster's body art (158 classes; every actor their DECORATE reaches: deaths, crawlers, last stands, gore pieces, fatalities, frozen and burnt bodies; `Monsters/tools/recolour/measure_frames.py`) | 806 sprite names, **7,620** frames (5,997 letters actually used) |
| Twelve colours of that under new sprite names | **91,440** (over the cap by 90,200); packed to used letters only 71,964 (over by 70,724) |
| Only the living frames (spawn, walk, attack, pain of the 158 classes) x 12 | 10,320 (over by 9,080) |
| The Imp family alone x 12 | 368 x 12 = 4,416 (over by 3,176) |

One colour of the full set (7,620) is already six times the headroom. The static walk is approximate (it found 30 of the
36 sprite names in the Imp's own folders; ACS and runtime names escape it), so the true numbers are a little higher.

## How it works (RSQ Monsters, `Monsters/zscript/monsters/RS_BDArt.zs`, since 2026-11-13)

- **Who holds the colour.** A Brutal Doom / XMVE monster's colour is its kit's (`RS_BDKit`). A piece that came out of a
  coloured body (a corpse that is a new actor, a crawler, a last stand, a limb, a gib) holds it in an `RS_BDHue`, put on by
  RSQ Monsters' Carry (`RS_BDTier.zs`). The translation is now only what the renderer shows: the tier tint
  (`rs_bdtier_*`) where there is no painted frame, no translation where the painted frame is drawn. The prototype's
  trick (take the tint off for the renderer, put it back at the top of every tic, because the tint WAS the colour) is
  gone: nothing reads the colour back from the translation.
- **picnum.** An actor whose `picnum` is set draws that texture instead of its sprite frame. A texture is not a sprite
  frame: the PNGs live in a plain folder of a pk3 (`rsrecolour/<colour>/<LUMP>.png`), are made into textures only when
  first asked for by full path, and count against nothing.
- **Rotations and mirroring.** picnum has neither, so after every actor has moved (a Thinker at statnum 120) the driver
  asks the engine which lump the actor's frame shows from the console player's view (`State.GetSpriteTexture`, the
  engine's own rotation and mirror tables) and points picnum at that lump's copy, with X-flip when the engine mirrors it.
- **Only its own look.** The art is drawn while the actor shows its tier colour (the tint, or no translation). The tier
  flash, a Champions tint before the kit takes it off (fix 6), or a colour a monster's own states set are left on
  screen. The tier flash's own-colour phase puts the tier tint back (not "no translation"), and the art follows.
- **Fallback.** A frame with no copy for its colour (a family not painted yet, an art pk3 not loaded, RSQ Monsters >
  Painted Colour Art off) shows the live tint, so families arrive one at a time.
- **Cost.** A corpse or a monster whose frame, colour and rotation from the viewer are what they were last tic is
  skipped (one angle and a few compares). A sprite with no art in its colour at all (another family) costs one Map
  lookup: each art pk3 carries `rsrecolour/<colour>/sprites.txt`, the sprite names it holds, read once.
- **Single player:** the art is picked for the console player's view in play code.

## Packaging (2026-11-13)

`python3 tools/build_monster_art.py` (or `tools/build_all.py`, `build_all.sh`) writes `pk3/RSQ_MonsterArt_<Colour>.pk3`
for each colour that has art: its PNGs (stored, not deflated), its `GLDEFS.txt` (each painted frame gets its source
sprite's brightmap, from `brightmaps.txt`) and its `sprites.txt`. It works with whatever families are painted at the
time. It stops if a colour would pass a zip's 65,535 entries or GitHub's 100 MB a file. One zip of every colour no
longer fits (71,517 files with the Imp and the three men's families); one per colour does: with those four families each
is 5,958 frames of 510 sprites, about 16 MB, and all of BD22 + XMVE would be about 11,300 lumps (about 30 MB) a colour.
The art pk3s are not committed on this branch (they are rebuilt from `rsrecolour/` whenever a family lands); they go in
at the merge. Load them after `RSQ_Monsters.pk3` (the lookups are by full path, so the order among them does
not matter). To refresh the brightmap table: `python3 -I tools/build_monster_art.py --brightmaps <the load order's
archives>` (`Monsters/tools/recolour/out/bake_load_order.txt` lists them).

## Shown on the rig: the integration (2026-11-13, RSQ Monsters' driver and the per-colour art pk3s)

All on the owner's full order (`rig/work/full_monA.sh`'s list: his saved ini, every pack of his order, this branch's RSQ
pk3s with `RSQ_MonsterArt_<Colour>.pk3`), `-skill 6`, rig01 at sector light 224 for the frames, through
`Monsters/tools/recolour/rig/rcE_full.sh` and its test handler `rcEdemo/`. **No script error from our packs** in any run
(the only `Script error` lines are BD22 VoxelPack's own VOXELDEF, as on main; 2161 warnings, the same count as main's).
Test-only settings for the frames, not his: Kill Rewards off (`rsqgb_kr_enabled 0`), weapon and laser sight hidden;
in `rcE_final2` also every imp a champion, awake (`champion_OverrideChance 256`, `champion_dormant 0`). Runs deleted
after the sheets were cut (`Monsters/tools/recolour/rig/rcE_sheets.py`).

| Sheet | What it shows | Log |
|---|---|---|
| `docs/integ_01_twelve_colours_drawn_by_rsq_monsters.jpg` (run `rcE_final`) | the Imp's twelve colours drawn from the art pk3s by RSQ Monsters' driver, front and side | census: every coloured imp "hue <colour> wears none ART" |
| `docs/integ_02_blood_mist_red_pieces_coloured.jpg` (`rcE_final`) | Red, Gray, FireBlu imps gibbed: the mist red (no coloured squares), the pieces in their imps' colours | 93 coloured things, 0 blood or mist wearing a tier tint; `XDeathImpArm` per imp: its imp's colour, drawn from the art |
| `docs/integ_03_pairs_side_by_side.jpg` (`rcE_final`) | imps 36 units apart in pairs (Green\|Red, as shipped\|Red, FireBlu\|Gray, Red\|as shipped): alive, plain deaths, one explosive hit on all | 0 bodies or pieces on one imp's spot holding another's colour; the as-shipped imps' pieces hold none |
| `docs/integ_04_champions_flash_art_toggle.jpg` (`rcE_final2`) | World Tier 3 from the start under Champions (and Universal Entropy, his `ue_recolour 5`): the tier colour from the art; World Tier 4 mid-map: the flash, then the new colour from the art; Painted Colour Art off (the tint) and on again (the art) | 7 "tier tint back over a Champions tint"; `rs_carry_dump`: 7 wear their tier colour, 0 a Champions tint; Champions' icons hold no colour |

Cost (`rsq_mon_art_debug 1`: the driver's own time, `MSTimeF` around its tick; **rig CPU, two cores shared with other
runs, not Quest: Quest numbers need his headset**). God mode, 600 tics of the map, then `kill monsters` and 420 tics of
the bodies:

| Map, World Tier | Tracked | Drawn from art | Driver, ms per tic (avg of each 35-tic window; worst tic) |
|---|---|---|---|
| MAP01, 4 (Purple), first measurement (see below) | 27 alive, 46 to 53 after | 12, then 13 | 0.03 to 0.06 (0.87) |
| MAP10, 4 (Purple) | 283 alive; 351 after the kill, 468 at the end | 65, then 52 | 0.18 to 0.22 (0.50) alive; 0.32 the second after the kill (0.61), then 0.18 to 0.24 |
| MAP10, 4 (Purple), with the Imp, Zombieman, Shotgunner and Chaingunner art (run `rcE_cost3_m10_w4`) | 279 alive; 364 after the kill, 469 at the end | 174, then 128 | 0.17 to 0.24 (0.68; 1.67 in the first second, the art first loaded) alive; 0.41 the second after the kill (1.03), then 0.19 to 0.24 |
| MAP10, 1 (as shipped: nothing coloured) | 279 alive, 128 after | 0 | 0.05 to 0.07 (0.32) |

The MAP10 rows are the final code. Before the per-sprite list and the kit's colour read straight off the kit (the first measurement, which is also the MAP01 row): MAP10 World
Tier 4 was 0.27 to 0.33 alive and 1.49 (6.9 worst) the second after the kill. Texture memory: the art pk3s add no sprite
frames; the art in use on MAP10 was 35 textures, 0.23 MB as 32-bit with the Imp alone, 183 textures, 1.29 MB with the four
families (the frames loaded on demand, logged by the driver;
the engine's own texture memory could not be read on the rig). The Imp art is about 7 KB a frame as 32-bit, so even a
few hundred painted frames in view at once stay in single megabytes.

## Shown on the rig (the prototype driver, before it moved to RSQ Monsters; these runs drew the FIRST, tint-baked art)

| What | Run | Result |
|---|---|---|
| Exactness | `rc_t3`, `rc_t4` (doom2 + brutal22test6 + BD_VoxelPack + rig01) | Copies of the Imp's own lumps drawn through the driver against the engine's own sprite, 8 rotations, frames TROS A, TROO A, TROO C (rotations 6-8 mirrored): **0 differing imp pixels** once the baked copies carry the lumps' brightmaps (`docs/rig_identity_engine_vs_picnum.png`; TROS's 243 are the wall's moving line) |
| Full-path lookup | `rc_t1` | `rsrecolour/green/TROOA1.png` found (case-blind), without the extension not found |
| 12 colours alive | `rc_demo2`, `rc_final` (the owner's full order) | All twelve drawn from the art, no script error from these packs; art against the live tint, lit and at sector light 48 with brightmaps (`docs/fullorder_art_vs_live_tint.jpg`, `docs/fullorder_dark_room_art_vs_tint.jpg`) |
| 12 colours dying | `rc_min0` to `rc_min7` (doom2 + brutal22test6 + BD_VoxelPack + RSQ_Monsters + rig01; Kill Rewards off) | Plain, gibbed, plasma, ice, leg and shotgun deaths (`docs/imp_12colours_alive_and_*_death.jpg`); the full order's plain death (`docs/fullorder_plain_death_strip.png`) |
| The tier flash | `rc_flash` | World Tier 1 to 3 mid-map: the flash kept the tint as the monster's own (origTrans = the tint id every tic), flashed, landed on the new colour, drawn from the art |
| Cost | `rc_stress` | 120 coloured imps: 0.23 to 0.60 ms per tic for the driver; 333 tracked after their deaths: 0.33 to 0.98 ms (rig CPU, not Quest) |

Seen in those frames, NOT the prototype's doing (RSQ Monsters on main): BD's blood mist (`SuperGore` and others) took
the tint, and the colours whose recipe lifts black (FireBlu, Red, Gray) painted it as coloured squares; a thrown imp arm
(`XDeathImpArm`, no maker) stayed as shipped; imps closer than 64 units could hand each other their colour through Carry.
All three are fixed in RSQ Monsters on this branch (2026-11-13, see `Monsters/README.md` and the integration rows below).

## Not done / open

- The art is made by rule, per part (above). Nothing is painted by hand yet; a frame painted by hand goes in
  `hand/<colour>/<LUMP>.png` and wins over the bake (`hand/README.txt`). Claws share the spikes' palette (same gray
  ramp in the source); a `claw` part exists for masks that split them. The frozen imp keeps its ice in every colour.
- Generic gore (`Guts`, `XDeath1`-`4`, organs, brains, teeth), burnt (`PBR1`, `XBRN`) and Brutal Doom's shared pieces
  are not baked: they keep the live tint (on main too). FireBlu's tint turns their red to blue. For the owner: paint
  them (they would keep their reds, as the Imp art does), or leave them uncoloured.
- All BD22 + XMVE: about 11,300 source lumps, 135,000 PNGs, 300 MB. One pk3 per colour (above) holds it.

## Build and bake

    python3 -I Monsters/tools/recolour/bake.py Monsters/tools/recolour/families/imp.txt MonsterRecolour/rsrecolour \
        Monsters/TRNSLATE.txt $(cat Monsters/tools/recolour/out/bake_load_order.txt)
    python3 tools/build_monster_art.py

The bake reads `families/imp.txt` (parts, group rules, masks, tint-kept lumps) and `ramps.py` (the palettes), then
copies `hand/` over its output. The art build packs every colour. RSQ Monsters > Painted Colour Art (`rsq_mon_art`)
0 turns the art off (the live tint only); `rsq_mon_art_debug 1` logs what it draws and its time (RSART lines).
Rig probes: `Monsters/tools/recolour/rig/` (test only; `rcE_full.sh` + `rcEdemo/` are the integration's).

## The Zombieman, Shotgunner and Chaingunner families (2026-11-13, owner-approved method: "lets use that, i approve for the bd and xmve series")

Every BD22 and XMVE class of the three tier families, with their last stands, crawlers, rolls, deaths, gibs,
fatalities, frozen and burnt deaths: `families/zombieman.txt` (233 sprite names, 2,447 lumps), `shotgunner.txt`
(152, 1,505), `chaingunner.txt` (89, 1,530). 5,482 lumps x 12 colours, painted per part as the Imp (no lump on the flat
tint), 282 MB of PNGs. Which sprite names, and why, is written at the top of each family file. **rig only, not
headset-confirmed.**

What is the body, for men (the plainest reading; each choice is in its family file):
- **The uniform and the skin.** Zombiemen: the khaki, olive and gold uniform (128-159) and the skin (48-79). SS: the
  blue uniform. Scientists: the white lab coat. Chaingunner, Rifle Commando: the red armour (16-47); Former Commander
  and Major also the bright reds 168-191. ASG guy, SSG guy: the olive/khaki gear. Hell Trooper: the red robe (168-191).
  Evil Marines: the green armour.
- **Kept:** guns and metal (the grays 80-111), the reds Brutal Doom paints its wounds and blood with (16-47 and 168-191
  for the zombies and shotgunners; 168-191 for the chaingunners), eyes, the ammo belt, muzzle flashes, hair, ice.
- **For the owner: gray uniforms.** The shotgunner's black uniform (BD22 ShotgunGuy, SMGGuy; XMVE QSG, Rocket, Riot and
  Pyro sergeants) and the ZSpecOps' armour are drawn in the same grays as their guns, so they are kept with the guns and
  only these men's skin carries the colour (see the shotgunner sheet). Colouring those uniforms needs per-frame masks
  or a human painter. Likewise the Plasma Zombie's gray-and-blue camo trousers keep, LabguyP's pistol takes the lab
  coat's colour, and the blood in the Hell Trooper's, Former Commander's and Major's own death frames is in their
  armour's reds and takes the colour.
- **Fatalities and stealth kills** show the player's marine: his green armour and tan helmet, boots and belt keep; in
  the zombieman fatalities that also keeps the zombie's khaki uniform (same palette), only his skin takes the colour.
- **Evil Marines** draw the player's own sprites (PLAY, MARN, ...); they are baked too. The driver draws the art only on
  a kit monster or a coloured piece (RSQ Monsters' `RS_BDArt.zs`), so the player is never drawn from it.
- **Left on the live tint (not baked):** Brutal Doom's shared gore, blood and burnt bodies (BDT*, CARB, PBR1, XBRN, BRZ3,
  BLOD, XME*, ...), pieces another family owns by folder (the Imp's LEG4 HND4 XHE4 TROO TROG; the Revenant's SKEL SPIC
  BNP*; the Lost Soul's LGI*; ID11 ID50), the Labgal's first-person hostage frames (never on a monster).

Tool changes (generic; the Imp's bake is byte-identical, checked): `statgroup <name> <prefixes>` gives a look its own
shading statistics (a blue SS and a white coat are not a khaki uniform); the bake keeps the other families' lines in the
shared `manifest.txt` and `GLDEFS.rsrecolour`; `RSRC_JOBS=n` paints in n processes.

Shown on the rig (owner's full order, his ini, -skill 6, rig01, light 224, `ue_recolour 0`, weapon, laser and bars
hidden; runs `rcA_*` with `rig/rc3_run.sh` + `rig/rc3demo`, cut by `rig/rc3_sheets.py`, then deleted; no script error
from these packs). One row of each family's base class (BD22 RifleZombie, ShotgunGuy1, ChaingunGuy1), as shipped then
Green .. White through RSQ Monsters' own tier change:

| Sheet | What |
|---|---|
| `docs/zombieman_12colours_new_art.jpg`, `docs/shotgunner_12colours_new_art.jpg`, `docs/chaingunner_12colours_new_art.jpg` | as shipped and the twelve colours: front, side, attack, dying (frozen mid-fall), dead |
| `docs/zombieman_07_fireblu_old_vs_new.jpg`, `docs/shotgunner_01_green_old_vs_new.jpg`, `docs/chaingunner_03_purple_old_vs_new.jpg` | as shipped, old (the live tint), new art, for one colour |

The other classes of the families (SS, scientists, Evil Marines, XMVE's) are not shown on the rig yet: only in bake
previews. In the chaingunner's live-tint run (`rcA_cg_old`) the second row (FireBlu .. White) got no tier (RS_Retier
answered rung -1), so its old/new sheet is cut for Purple, from the first row. In the last frames of some runs as-shipped men rose from
the corpses (the full order's own, not this art); the sheets' frames are picked before that.
The art is more than one zip can hold (71,517 entries with the Imp): the rig loaded it as two pk3s split by colour.
