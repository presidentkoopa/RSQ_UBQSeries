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
pk3 per colour, `pk3/RSQ_BDXMTiers_<Colour>.pk3`, built by `tools/build_monster_art.py` (also run by
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
- **Kept on the flat tint:** nothing now (`X728`, XMVE's Dark Imp, was; it is painted with the Dark Imps in
  `families/imp_xmve.txt` since 2026-11-13). `manifest.txt`'s last column says `paint` or `tint` per lump. `BOSBA0`-`BOSBE0` (BD22's Hell Knight burnt, listed in the Imp family by
  its sprite name; only `BOSBF0` is an imp gib) are the Hell Knight family's since 11-13 (`imp.txt` skips them).

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

## The Imp's XMVE kinds, Demon, Spectre, Lost Soul, Cacodemon, Pain Elemental (2026-11-13)

Same method, palettes (`ramps.py`) and driver as the Imp. Each family file says what is body and what keeps its own.
**rig only, not headset-confirmed.**

| Family file | Classes (BD22 + XMVE) | Lumps |
|---|---|---|
| `families/imp_xmve.txt` | DarkImp, NamiDarkImp, NetherDarkImp, VoidDarkImp, SuperImp, Imp3 (BD22's Imp: `imp.txt`) | 556 |
| `families/demon.txt` | BullDemon, FatPinky, Spectro (draws the Demon's lumps), BrutalNightmareDemon, BloodDemon, BloodSpectre (draws its lumps), VoidSpectre | 669 |
| `families/spectre.txt` | InvisibleAlien (the Spectre family's only art of its own; see below) | 173 |
| `families/lostsoul.txt` | TehLostSoul, AlphaLostSoul, AncientFlyingCunt, ImpureSoul, Phantasm, Vanilla_Phantasm | 246 |
| `families/caco.txt` | Cacodemon_, CacoAsshole, Aracnorb, XVStealthAracnorb, ImpureElemental, StealthImpureElemental, OverLord, SuperOverlord, Vanilla_Overlord (AracnorbQueen's ARNQ: `spidermastermind.txt`) | 455 |
| `families/painelemental.txt` | PainElemental1, SufferingElemental, Vanilla_SufferingElemental (paingasm draws the Cacodemon's HEAD) | 101 |

Tools: these families use `statgroup` (a monster's own shading statistics inside a family that holds several) and one
new group rule, `keepsat <chroma>` (a pixel whose own colour is at least that saturated keeps it: the Invisible Alien's
purple goo is drawn in true colour and its nearest palette entries are grays). The Imp's bake is unchanged, byte for
byte. `imp.txt` lost only `X728` (XMVE's Dark Imp art): it is painted in `imp_xmve.txt` now, not kept on the tint.

Choices made (the plainest; written in the family files):
- **The Spectre is not drawn as fuzz.** BD22's Spectre (`Spectro`) is the Demon drawn additive (RenderStyle Add, alpha
  0.45) with the Demon's own lumps, so it gets the Demon's art; its lurking frames `SPEC` are only red eyes (eyes keep
  their own: nothing to paint). XMVE's BloodSpectre is the Blood Demon's lumps drawn additive. The Spectre family's own
  art is BD22's Invisible Alien.
- **Each monster keeps its own range of shading** (`statgroup`). The black monsters (the Dark Imps, the Void Spectre,
  the Invisible Alien) read as darker shades of each colour; Gray and Black stay close to their shipped black. The brown
  XMVE imps match the Imp. A black hide's few dark browns (the Void Spectre's belly) keep their own: painted, they turned
  into saturated blotches (rig, first run).
- **Metal and armour keep their own:** the Blood Demon's legs, dorsal blade and jaw plates; the Overlord's black spiked
  shell (its flesh and horns are painted).
- **Fire, blood, goo and ice keep their own:** the Lost Souls' flames, the Nether Dark Imp's and Void Spectre's green
  goo, the Invisible Alien's purple goo, the Cacodemon's blue blood and mouth, the Overlord's death burst of blood
  (masked: `caco_masks.txt`), the Suffering Elemental's green eye and blast.
- **Teeth:** grays touching a red mouth stay white (as on the Imp); the Demon's horns and claws (its dark grays) are
  painted and its teeth (light grays) stay white; the Cacodemon's teeth touching its blue mouth stay white.
- **Shared lumps painted by another family:** `XHE5` (the Demon's head torn off; BD throws it from Barons and Hell
  Knights too) is `baron.txt`'s; `ARNQ` (the Aracnorb Queen, a Cacodemon-family monster whose BOSS kinds are the Spider
  Mastermind family's) is `spidermastermind.txt`'s. The Aracnorb Queen sheet below was cut before that (my ARNQ art);
  in the branch its frames are the Spider Mastermind family's.

Left on the live tint (not baked), and why:
- frozen deaths that are all ice (Demon FZD5 PFZD FZM1 FZM2 F6D4, Cacodemon FZDC CFZD, Pain Elemental EFZD FZDP, Lost
  Soul KFZD): nothing of the body shows under the ice;
- burnt deaths (TRBR, SBRG, CRB7, S6RN, PBR2 and the generic Carbonized and BurningMan): glowing embers, which is fire;
- fatalities where the marine and the monster share palette ramps (Pain Elemental PA1F, Suffering Elemental TA1F,
  Aracnorb FTAC): **frames for a human painter** (`hand/<colour>/`) or masks;
- not body art: projectiles, trails and lights (DKB1 DKB2 DKBT IBAL ITRL NLIT PLDB PLDC BLST CBTS EBLT AFX1 DLIT HADE
  HEFX LFX1 LFX2), the first-person grab view (DSHF DSHG GRZ8), the Invisible Alien's cloak shimmer (A6AG);
- other families' pieces BD throws from these monsters (Hell Knight and Baron gibs GHK* HKHE GG71, generic gore).

Shown on the rig (his full order with his saved ini, `-skill 6`, rig01 at sector light 224, 260 units, 480x480 frames;
test handler `Monsters/tools/recolour/rig/rcfam/`, `rcf_script.py`, cut by `rcf_sheets.py`; the runs deleted after).
Every pose is frozen and shown twice in the same run, with the art on and off (the live tint), so "old" and "new" are
the same pose. **No script error from our packs** in any run (only BD22 VoxelPack's own VOXELDEF lines, as on main).
The Overlord, Aracnorb Queen, Impure Elemental and both Pain Elementals were run on the integrated pipeline (RSQ Monsters'
`RS_BDArt.zs` drawing from the per-colour art pk3s built by `tools/build_monster_art.py`); the others on the prototype
driver just before the integration landed (the same PNGs). Test-only settings: `ue_recolour 0`, weapon, laser sight,
health bars and Kill Rewards off; the kit's entry colour lowered to 1 so every colour shows; Legion of Bones' skeletons
and a Pain Elemental's spat Lost Souls removed. BD picks each death at random; a body thrown out of its tile leaves it
empty, and a few dying tiles are blank where the frame finder missed the pose.

| Sheet (`docs/`) | What |
|---|---|
| `impxmve_darkimp_12colours.jpg`, `_netherdarkimp_`, `_voiddarkimp_`, `_superimp_`, `_imp3_` | as shipped and the twelve colours: front, side, attack, dying |
| `impxmve_darkimp_blue_shipped_tint_art.jpg` | Blue: as shipped, the live tint, the art |
| `demon_bulldemon_12colours.jpg`, `_nightmaredemon_`, `_blooddemon_`, `_voidspectre_` | the twelve colours |
| `demon_bulldemon_blue_shipped_tint_art.jpg` | Blue: shipped, tint, art |
| `spectre_spectro_12colours.jpg`, `_bloodspectre_`, `_invisiblealien_` | the twelve colours (the Spectres additive; the Invisible Alien is cloaked until it attacks) |
| `spectre_spectro_blue_shipped_tint_art.jpg` | Blue: shipped, tint, art (its eyes have no art: they keep the tint) |
| `lostsoul_lostsoul_12colours.jpg`, `_alphalostsoul_`, `_ancientflying_`, `_impuresoul_`, `_phantasm_` | the twelve colours |
| `lostsoul_lostsoul_blue_shipped_tint_art.jpg` | Blue: shipped, tint, art |
| `caco_cacodemon_12colours.jpg`, `_cacoasshole_`, `_aracnorb_`, `_impureelemental_`, `_overlord_`, `_aracnorbqueen_` | the twelve colours |
| `caco_cacodemon_blue_shipped_tint_art.jpg` | Blue: shipped, tint, art |
| `painelemental_painelemental_12colours.jpg`, `_sufferingelemental_` | the twelve colours |
| `painelemental_painelemental_blue_shipped_tint_art.jpg` | Blue: shipped, tint, art |

Seen in those frames, not this art's doing: some dying bodies show the live tint (a death frame from a sprite outside
these families, e.g. part of the Demon's and the Cacodemon's death sets), and a few show no colour at all (a dying
body that is a new actor holding no colour: some Blood Demon and Void Spectre deaths at Gray, Red, Abyss, White). The
Lost Soul's skull top and one side are lit by its own flame in the source (oranges): they keep the flame's colour.

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

`python3 tools/build_monster_art.py` (or `tools/build_all.py`, `build_all.sh`) writes `pk3/RSQ_BDXMTiers_<Colour>.pk3`
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
pk3s with `RSQ_BDXMTiers_<Colour>.pk3`), `-skill 6`, rig01 at sector light 224 for the frames, through
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

## Hell Knight, Baron, Revenant, Arch-vile families (2026-11-13, same method as the Imp)

**rig only, not headset-confirmed.** Thirteen family files (`Monsters/tools/recolour/families/`), each one art set with
its own shading statistics, baked with the Imp's palettes (`ramps.py`, unchanged):

| File | Classes (tier family) | Lumps |
|---|---|---|
| `hellknight.txt` (+ `_masks`) | BD22 HellKnight2 (Hell Knight): body, deaths, crawlers, gibs, burnt (BOSB A-E, BOSC), fatality KTFP, frozen FZD6 | 310 |
| `hellknight_cyber.txt` | XMVE CyberKnight, Cybruiser, PhasicKnightX, XVStealthCyberKnight (Hell Knight) | 181 |
| `baron.txt` (+ `_masks`) | BD22 BaronofHell2, BaronBoss1/2; XMVE Cyberbaron, XVStealthCyberBaron (Baron); doom2's BOSS (its corpse) | 435 |
| `baron_belphegor.txt` (+ `_masks`) | BD22 Belphegor2 | 102 |
| `baron_afrit.txt` | BD22 Afrit | 77 |
| `baron_bruiser.txt` | XMVE BruiserDemon, XVStealthBruiser | 114 |
| `baron_pyro.txt` | XMVE PyroDemon | 86 |
| `baron_terminator.txt` | XMVE TerminatorDemon, TerminatorBoss, XVStealthTerminator | 135 |
| `revenant.txt` (+ `_masks`) | BD22 Revenant1: body, crawler, legs, gibs, fatalities REFP and SKF1-3, frozen | 313 |
| `revenant_draugr.txt` (+ `_masks`) | XMVE Draugr, Vanilla_Draugr | 170 |
| `revenant_incarnate.txt` | XMVE Incarnate | 96 |
| `archvile.txt` | BD22 TehArchvile: body, burnt death (XVIP, DIBR), gibs, frozen | 252 |
| `archvile_diabloist.txt` | XMVE DIABloist | 145 |

**Choices made (plainest reading; each is written in its family file, for the owner to confirm or change):**
- **Revenant: its bones are its body** (painted); its white armour and launchers are metal (kept); its red flesh and tunic
  are drawn in the blood's own reds, so they stay red as blood does. Draugr the same (its black armour is metal).
- **Hell Knight, Baron, Belphegor:** hide and furred legs are one body; their horns are drawn in the hide's own colours
  (no gray), so they take the skin's palette. The Baron's green blood and the green fire in his hands stay green; his
  skin IS the reds 16-47, so a wound's red on him is painted with the skin.
- **Burnt Hell Knight (BOSB A-E, BOSC):** the char is his body: painted from the deepest steps of his ramp (charred in his
  colour). BOSB A-E moved here from the Imp family (`imp.txt` now `skip`s them; the Imp's other files bake identically).
- **Fire keeps its colours (the owner's rule), also where it lights the body:** the Arch-vile's and Diabloist's casting
  frames, where the whole body is lit gold/orange by their own fire, keep that gold (the live tint left it gold too);
  the Afrit's and Bruiser's flames stay fire. The Bruiser's hide is drawn in the fire's own oranges: its hide is painted,
  the bright flames and the oranges within 3 pixels of them are kept.
- **Mostly-metal monsters:** the Terminator's gray plates, limbs and guns are metal (kept), the red flesh between them is
  its body (painted). The CyberKnight's hide and its metal limbs are one gray ramp: the gray is painted as its hide, the
  gray within 3 pixels of a red light is taken as metal and kept (a heuristic; a human painter could do better).
- **Black-hided monsters** (PyroDemon, Death Incarnate): the black is their body and is painted, so their colour shows
  through their own black shading; their glowing cracks/core keep their fire.
- **Fatalities:** the victim keeps his own colours (rectangle masks per frame, `idx=` limits a mask to palette indices
  where the victim and the monster share browns). Left to the paint, a few pixels: the marine in REFP A-D (in front of
  the Revenant's legs, same browns), the marine inside the Baron's grip in 3HF2 A-C.
- **Not baked, on purpose:** projectiles, flames and effects in these monsters' folders; generic gore and burnt bodies
  other families share (CARB, XBRN, XDT1, XMT1-2, BR7B ...: live tint, as for the Imp); the player's first-person
  fatalities (sprites/Fatality/*: drawn on the weapon, never an actor).

**Tool changes (generic, backward compatible; the Imp's bake is byte-identical except BOSBA0-E0, checked):** `skip <prefixes>`
in a family file; masks take `idx=<ranges>`; a part with only a few pixels no longer breaks the statistics or divides by
zero.

**Shown on the rig, through the PROTOTYPE driver** (`MonsterRecolour/zscript`, before the integration moved it into RSQ
Monsters; the owner's full order, `-skill 6`, rig01, sector light 224, no script error from these packs: only
BD_VoxelPack's own four voxeldef lines; test-only settings as for the Imp, plus `rig/rcCdemo`, a row of any class; sheets
cut by `rig/rcC_sheets.py`, `rig/rcC_strip_sheet.py`). Runs
`rc3_hk2`, `rc3_bar2`, `rc3_rev2`, `rc3_av` (art switched off and on in one run for the old/new sheets), `rc3_strip` (XMVE
and the other Barons, rows of thirteen), `rc3_dbg1`/`rc3_dbg2` (the prototype's `rsrc_debug 1`, all 15 classes alive, attacking, killed and
gibbed: the log names every frame left to the tint). Frames cut into the sheets, runs deleted.

| Sheet | What |
|---|---|
| `docs/hellknight_12colours_new_art.jpg`, `docs/hellknight_07_fireblu_old_vs_new.jpg` | BD22 Hell Knight: front, side, attack, dead; FireBlu as shipped / live tint / art |
| `docs/baron_12colours_new_art.jpg`, `docs/baron_07_fireblu_old_vs_new.jpg` | BD22 Baron of Hell, the same |
| `docs/revenant_12colours_new_art.jpg`, `docs/revenant_07_fireblu_old_vs_new.jpg` | BD22 Revenant (dying, not dead: BD's Revenant falls to bones that the test handler clears) |
| `docs/archvile_12colours_new_art.jpg`, `docs/archvile_07_fireblu_old_vs_new.jpg` | BD22 Arch-vile |
| `docs/baron_others_12colours_strip.jpg` | Belphegor2, Afrit, Cyberbaron, BruiserDemon, PyroDemon, TerminatorDemon: front and dead, rows of 13 |
| `docs/knight_revenant_archvile_xmve_12colours_strip.jpg` | CyberKnight, PhasicKnightX, Draugr, Incarnate, DIABloist: the same |

**Shown again through the integration** (run `rcC_integ`, after rebasing on it: RSQ Monsters' `RS_BDArt.zs` and the twelve
`pk3/RSQ_BDXMTiers_<Colour>.pk3` built by `tools/build_monster_art.py` with every family painted so far, 8,369 frames of
647 sprites a colour; the owner's full order, `-skill 6`, `rig/rcE_full.sh` + `rig/rcCdemo`, `rsq_mon_art_debug 1`): rows of
thirteen HellKnight2, BaronofHell2, Revenant1, TehArchvile, CyberKnight, Draugr, art on then `rsq_mon_art 0`, and four
deaths: `docs/integ_hk_baron_rev_av_xmve_art_vs_tint.jpg`. All twelve colours drawn from the art (debug: 12 of 13 drawn
per row, the 13th as shipped); no script error from our packs (BD_VoxelPack's own four voxeldef lines only).

**Seen in the prototype runs, not the art's doing:**
- **Ladder entry rungs (stale).** With RSQ Monsters as it was before main's "every BD / XMVE monster enters at Common",
  some classes got no tint below their entry rung; the strips mark those tiles "no tint (ladder)". In the integration
  run every class took all twelve colours.
- **RSQ_Monsters ships its own sprites under the same names** (BOS2, BOS3, BOSB, BOSC, BOSS, BRUD, BRUS, BRUR, DIAB, INCA,
  INCX, SKEL, TERM, VILP among 74 names shared with BD22/XMVE), so in the full order its lump wins over BD22's. 583 such
  lumps have a baked copy of BD22's/XMVE's lump of that name (the art draws BD22's look there, as before RSQ_Monsters
  replaced it); 472 have none (e.g. `BOS3*C*`/`*D*` rotation pairs, `VILP*`, `BOSB`/`BOSC` rotations, `BRUR`) and keep the
  live tint. The rig showed two: `BOS3B1D1` (Belphegor walking) and `DIABZ0` (Arch-vile corpse), both RSQ_Monsters lumps.
  Whether RSQ_Monsters' own sprites should be baked instead is a choice for the owner (see the final report).
- `PLYCU0` on a BaronofHell2 (the player's crouch sprite, BD's fatality pose) and generic gore (`XDT1`, `XMT1-2`, `BAL1`,
  `JNK1-3`, `BPDL`, `GUTS`) keep the live tint.
- Legion of Bones' SlayerKnight (and others) rise among the rows; the Belphegor's purple aura covers his head in the strip.
