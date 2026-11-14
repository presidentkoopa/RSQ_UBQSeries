# RSQ Monster Recolour (PROTOTYPE, branch `wip/2026-11-13-recolour`, not in `pk3/`, not built by `build_all`)

Hand-made recoloured frames for Brutal Doom's and XMVE's monsters on the colour ladder, drawn **without new sprite
names**, so they cost **no sprite frames** under QuestZDoom 17.3's 65,535-frame cap. The prototype is BD22's Imp
family (its body, deaths, crawlers, gibs, fatality and frozen death) in all twelve colours.

**rig only, not headset-confirmed.** Nothing here has been seen in the owner's headset.

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

## How it works (`zscript/rsrecolour/driver.zs`)

- **picnum.** An actor whose `picnum` is set draws that texture instead of its sprite frame. A texture is not a sprite
  frame: the baked PNGs live in a plain folder of the pk3 (`rsrecolour/<colour>/<LUMP>.png`), are made into textures
  only when first asked for by full path (`TexMan.CheckForTexture("rsrecolour/green/TROOA1.png")`), and count against
  nothing.
- **Rotations and mirroring.** picnum has neither, so every tic, after every actor has moved (a Thinker at statnum
  120), the driver asks the engine which lump the actor's frame shows from the console player's view
  (`State.GetSpriteTexture`, the engine's own rotation and mirror tables) and points picnum at that lump's baked copy,
  setting X-flip when the engine would mirror it.
- **The colour.** RSQ Monsters' tier tint is the mark: an actor wearing an `rs_bdtier_*` translation is that colour
  (RS_BDTier puts it on the monster and carries it to corpses, crawlers and gore). A translation also applies to a
  picnum texture (rig `rc_t1`: a white baked imp under a red translation drew red), so the driver takes the tint off for
  the renderer and puts it back first thing next tic (its handler has the lowest Order and restores in NetworkProcess
  and WorldTick): Brutal Doom, Carry and the tier flash only ever see the tint.
- **Fallback.** A frame with no baked copy keeps the live tint, so families can be added one at a time.
- **Single player:** the art is picked for the console player's view in play code.

## Shown on the rig (the driver; these runs drew the FIRST, tint-baked art)

| What | Run | Result |
|---|---|---|
| Exactness | `rc_t3`, `rc_t4` (doom2 + brutal22test6 + BD_VoxelPack + rig01) | Copies of the Imp's own lumps drawn through the driver against the engine's own sprite, 8 rotations, frames TROS A, TROO A, TROO C (rotations 6-8 mirrored): **0 differing imp pixels** once the baked copies carry the lumps' brightmaps (`docs/rig_identity_engine_vs_picnum.png`; TROS's 243 are the wall's moving line) |
| Full-path lookup | `rc_t1` | `rsrecolour/green/TROOA1.png` found (case-blind), without the extension not found |
| 12 colours alive | `rc_demo2`, `rc_final` (the owner's full order) | All twelve drawn from the art, no script error from these packs; art against the live tint, lit and at sector light 48 with brightmaps (`docs/fullorder_art_vs_live_tint.jpg`, `docs/fullorder_dark_room_art_vs_tint.jpg`) |
| 12 colours dying | `rc_min0` to `rc_min7` (doom2 + brutal22test6 + BD_VoxelPack + RSQ_Monsters + rig01; Kill Rewards off) | Plain, gibbed, plasma, ice, leg and shotgun deaths (`docs/imp_12colours_alive_and_*_death.jpg`); the full order's plain death (`docs/fullorder_plain_death_strip.png`) |
| The tier flash | `rc_flash` | World Tier 1 to 3 mid-map: the flash kept the tint as the monster's own (origTrans = the tint id every tic), flashed, landed on the new colour, drawn from the art |
| Cost | `rc_stress` | 120 coloured imps: 0.23 to 0.60 ms per tic for the driver; 333 tracked after their deaths: 0.33 to 0.98 ms (rig CPU, not Quest) |

Seen in those frames, NOT this prototype's doing (RSQ Monsters on main): BD's blood mist (`SuperGore` and others) takes
the tint, and the colours whose recipe lifts black (FireBlu, Red, Gray) paint it as coloured squares; a thrown imp arm
(`XDeathImpArm`, no maker) stays as shipped; imps closer than 64 units can hand each other their colour through Carry.

## Not done / open

- The art is made by rule, per part (above). Nothing is painted by hand yet; a frame painted by hand goes in
  `hand/<colour>/<LUMP>.png` and wins over the bake (`hand/README.txt`). Claws share the spikes' palette (same gray
  ramp in the source); a `claw` part exists for masks that split them. The frozen imp keeps its ice in every colour.
- Generic gore, burnt (`PBR1`, `XBRN`) and Brutal Doom's shared pieces are not baked: they keep the live tint.
- Each tic re-picks every tracked actor; still corpses could skip until their frame or the view changes.
- All BD22 + XMVE: 11,261 source lumps, 135,132 PNGs, about 300 MB. A plain zip holds 65,535 entries, so it would be
  several pk3s (one per colour fits). A hand-painted frame must live in a folder the bake does not overwrite.

## Build and bake

    python3 -I Monsters/tools/recolour/bake.py Monsters/tools/recolour/families/imp.txt MonsterRecolour/rsrecolour \
        Monsters/TRNSLATE.txt $(cat Monsters/tools/recolour/out/bake_load_order.txt)
    cd MonsterRecolour && zip -qr ../RSQ_MonsterRecolour_proto.pk3 zscript.txt zscript MAPINFO.txt CVARINFO.txt GLDEFS.txt rsrecolour -x rsrecolour/manifest.txt

The bake reads `families/imp.txt` (parts, group rules, masks, tint-kept lumps) and `ramps.py` (the palettes), then
copies `hand/` over its output. Load it after RSQ_Monsters. `rsrc_on 0` turns the art off (the live tint only); `rsrc_debug 1` logs what it draws.
Rig probes: `Monsters/tools/recolour/rig/` (test only).

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
  an actor wearing a tier tint, so the player is never drawn from it.
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
