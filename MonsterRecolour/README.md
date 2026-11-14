# RSQ Monster Recolour: the painted colour art (on main since 2026-11-14; built as `pk3/RSQ_BDXMTiers_<Colour>.pk3`)

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
- Generic gore: painted since 2026-11-13 (the owner picked "Paint it"; see "The shared gore" below).
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

## The shared gore (2026-11-13, owner: "Paint it")

The owner (11-13): Brutal Doom's shared gore took the tier tint (on FireBlu the red guts turned blue); asked what it should
do, he picked **"Paint it"**: art per colour that keeps its reds and colours only the flesh bits. `families/gore.txt`,
40 sprite names, 330 lumps x 12 colours (3,960 PNGs, about 0.4 MB a colour). **rig only, not headset-confirmed.**

- **Which pieces.** The shared gore that RSQ Monsters' Carry colours today: found on the rig (run `rcG_census`: nine
  families, 13 each in FireBlu Red Gray Black White Green, each killed by another Brutal Doom damage type, every coloured
  piece counted by its sprite: `rig/rcGdemo` `rcg_sample`/`rcg_dump`, `rig/rcg_script.py census`) and by a static walk of
  every tierable class's DECORATE (`rig/rcg_gore_scan.py`): guts, organs, stomach (GUTS XME4 XME5 XME8 XSTO), brains and
  head pieces (BRIB BRIN BR7B BR7N XDB5), arms and flesh chunks (XARM XDT3 XDT5 XSKI GORX CRS3), teeth (XTET), the blood
  gibs and pools that are pieces, not blood actors (BLHT BLOD BLUD BPDL XDT1 XMT1 XMT2 XME2 XDB6 CRS1 CRS2 CRSB GIBS), the
  disintegrating man (ID50), the zombie and marine gibs (TGIB XDMG), and the burnt remains a corpse can show (CARB XBRN
  PBR1 BRZ3 GIBD ASHY ASHZ). The list and why is at the top of the family file. The blood actors and mist (SuperGore,
  BloodMist, Brutal_Blood ...) and the burning runners (BDT1-3, CRB7, SBRG, TRBR: Burning* classes) keep their own look by
  class name already and are not baked.
- **What takes the colour** (the plainest reading of "keeps its reds and colours only the flesh bits"): only the skin's
  tans and browns (palette 48-79, 236-239: the ramp the Imp's and the zombies' skin are drawn in), so an arm, a scalp, a
  jaw's skin, a flesh chunk take the piece's colour. Kept: every red and pink (blood, muscle, guts, brains), bone and
  teeth (grays, pale yellows, whites), hair (BR7B's green), a marine's armour, other monsters' blue and green blood.
- **Whole pieces kept as shipped**: guts and organs (their intestines are drawn in browns as well as reds: they are guts,
  not skin), teeth, the blood gibs, the burnt remains (charred, ash and fire keep their own). Their art is the shipped
  frame (checked pixel-identical), so the driver draws them with no tint.
- **The driver reaches them unchanged**: a coloured piece gets an RS_BDHue from Carry and `RS_BDHue.Put` hands it to
  `RS_BDArt`; no code change was needed. Census with the art (`rcG_census2`): every gore sprite on a coloured piece drawn
  from the art (e.g. GUTS 2,238 piece-tics ART, XMT2 3,830, XDB5 2,772), the rest is the one tic a new piece wears the
  tint before the driver's first look at it (about 3%, as for the families' pieces).

Shown on the rig (owner's full order, his ini, `-skill 6`, rig01, light 224, `ue_recolour 0`, weapon, laser and bars
hidden, Legion of Bones' risers removed by the test handler; RSQ_BDXMTiers_<Colour> pk3s built with the gore art, and the
same without it for "old"; no script error from our packs; runs deleted after the sheets were cut by `rig/rcg_sheets.py`):

| Sheet | What |
|---|---|
| `docs/gore_01_pieces_six_colours_old_vs_new.jpg` (runs `rcG_pc_old`, `rcG_pc_new`) | eleven Brutal Doom gore pieces (Guts, two arms, Gib_Arm, organ, stomach, XDeathGuts, brains, a scalp piece, teeth, a skin piece), one per colour Green, White, Black, Gray, Red, FireBlu: in the air and landed, old (the tint) against new (the art) |
| `docs/gore_02_gibbed_monsters_old_vs_new.jpg` (runs `rcG_gib_old`, `rcG_gib_new`) | RifleZombie, Imp, ShotgunGuy1, BullDemon rows in the six colours, gibbed: bursting and landed, old against new |

Seen on the rig, not this family's (for the owner / other families):
- On the tint in these runs because their families' art landed after the runs' pk3s were built: the Demon's pieces (DEMH
  HND8 LEG8 PDG1 S2RG SRRD, now in `demon.txt`), the Imp's ID17 (now in `imp_xmve.txt`). Also some TRO3 frames on a
  coloured BD22 imp were drawn with the tint (22 tics in `rcG_census2`; TRO3 is in `imp.txt`: a rotation or frame
  with no painted copy, not looked into).
- Not gore but coloured by Carry today (its class names miss them): BD's floor crater (`DetectFloorCraterSmall`, XXX1)
  and metal shards (`MetalShard1-3`, JNK1-3); Legion of Bones' risers (`SkullZombieSpawn`, `SkeletonImpSpawn`,
  `SkeletonDemonSpawn`, `SkullShotgunnerSpawn`, `CacoLichSpawn`). Left as they are (an RSQ Monsters Carry question, not
  art).


## Every dying body (2026-11-13/14, the dying-body census; rig only, not headset-confirmed)

The question: does every BD22 and XMVE body a tier-coloured monster turns into or spawns carry its colour? The census
(`Monsters/tools/recolour/rig/rcf_census.py`, handler template `rcf_census_zs.tpl` -> `rcFcensus/`, class table
`rcf_classes.txt` from `rcf_classes.py`, arena `rcf_arena.py`): on his full order (`rcE_full.sh`, `-skill 6`), every
tierable class of the ladder is killed by EVERY death its DECORATE has (`Death.<type>`, its parents' included; plus two
plain deaths and a gib), one monster a cell, each cell its own colour (the twelve cycle), all in the same tic (`DMG_FORCED`
with that damage type), and every actor on the arena is looked at 4, 14, 35, 70 and 140 tics after: drawn from the art,
on the tint, or holding NO colour (blood, mist, fire, smoke, effects and pickups by RSQ Monsters' own name rule are not
counted: they keep their own). Counts are actor-snapshots. Legion of Bones' undead are taken away by the handler.
"before" = the branch at ea87f7fd16 (its art), "after" = this commit with the art at d732bbe908 (the gore pass in: most of
the art/tint shift is the new art, the NONE column is this work). "summon" = Lost Souls, Phantasms, Impure Souls and
Aracnorbs that other monsters spit, alive or as pieces: separate monsters at the world tier, not the killed body (design
2.8 gives a summon its summoner's colour only for the Pain Elemental's Lost Souls; not changed here).

```
family                cls             art b|a            tint b|a            none b|a          summon b|a     none %b|a
Arachnotron             4          665 | 1910          5713 | 913              93 | 0               0 | 0       1.4|0.0
Arch-Vile               2           167 | 629             516 | 1              22 | 0               0 | 0       3.1|0.0
Baron                  13         1170 | 4183          5039 | 123              59 | 9               0 | 0       0.9|0.2
Cacodemon               9         4317 | 5726          4424 | 717           1427 | 22         1576 | 1595      12.2|0.3
Chaingunner            23        3425 | 15399         13628 | 470           551 | 139               0 | 0       3.1|0.9
Cyberdemon             12           204 | 863          1584 | 154            120 | 14               0 | 0       6.3|1.4
Demon                   5         1243 | 5271          4462 | 243            170 | 59               0 | 0       2.9|1.1
Hell Knight             5         1093 | 7314          5705 | 488           119 | 213               0 | 0       1.7|2.7
Imp                     7         1922 | 9670           7943 | 99           179 | 197               0 | 0       1.8|2.0
Lost Soul               6           691 | 750             69 | 94              20 | 0               0 | 0       2.6|0.0
Mancubus                6          997 | 6049           5598 | 65             56 | 13               0 | 0       0.8|0.2
Pain Elemental          4           132 | 612          1950 | 127             10 | 42           343 | 676       0.4|2.9
Revenant                4         1986 | 3356           4140 | 49          1268 | 202          115 | 1518      16.9|3.9
Shotgunner             18        4111 | 15250         15125 | 276          1664 | 191              15 | 0       8.0|1.2
Spectre                 3          513 | 1906           1404 | 66             85 | 40               0 | 0       4.2|2.0
Spider Mastermind       8          605 | 2263          3140 | 471              21 | 0           225 | 225       0.5|0.0
Zombieman              26        4609 | 22018         17911 | 223         2066 | 1147               0 | 0       8.4|4.9
ALL                   155      27850 | 103169        98351 | 4579         7930 | 2288         2274 | 4014       5.8|2.0
```

Holding no colour, by death type (actor-snapshots, summons left out), before | after:

```
  plain             647 | 406
  gib/explosion    1914 | 380
  fire              810 | 392
  ice               145 | 94
  head              634 | 155
  legs               73 | 44
  fatality/grab     690 | 174
  other            3019 | 643
```

What was missing, and the fix (all in `RS_BDTier.zs` / `RS_BDArt.zs`):
- **Bodies that never go away.** Brutal Doom's men end many deaths on `TNT1 A -1` after spawning their crawler or
  corpse, so the maker is never removed and Carry found no body (the Chaingunner's blasted, burning and headless
  crawlers `BrutalizedCommandoBlasted`, `BurningChaingunguy`, `BrutalizedCommandoLostHead*` and their corpses). Fix: a body that died within 64 units in the last 4 s and still
  lies there counts as the maker (nearest wins, with the removed bodies; a body at its entry colour still gives none).
- **Death stages that are family monsters** got a fresh kit at the world tier (as shipped): the Arch-vile's armless
  crawler `DyingArchvileNoArm`, the Demon's `PoorPinkyLostHisArm` / `ArmlessDemon`, `DyingHellKnight1`. Fix: a family
  monster spawned mid-map that counts no kill takes the body's rung (and never calls for help).
- **Born again.** `Death.Taunt` / `Death.KillMe` (a captured marine's hit) removes the monster and spawns a fresh copy of
  the replaced class (his random spawners can make it another kind of the same family): it came back as shipped, at the
  world tier's numbers. Fix: one of the same family spawned on the spot (16 units, 3 tics) takes the body's rung.
- **Friendly death stages** (`BurningCacodemon`, `BurningZombieMan`, `DyingZombieman` ... are `+FRIENDLY -COUNTKILL`)
  were skipped entirely. Fix: they follow the body (anything named "marine" stays out: the helper marines).
- **Bodies thrown as missiles that hurt** (`ExtremePunchedChaingunguy`) were taken for attacks. Fix: a damaging missile
  whose maker is gone or dead and whose states draw painted art follows the body (fireballs draw none).
- **Fatalities.** The monster dies and gives the player `GoFatality`; the PLAYER plays the kill (`ARF1` and kin, painted
  with the families) and throws the gore and the corpse (`RapedArachnotron`). None of it held a colour. Fix: while the
  player holds `GoFatality` (and 2 tics after) what it throws takes the colour of that player's last kill, and the
  player's own fatality frames are drawn from the art (`RS_BDFatalHue`: art only, never the tint; the player's own
  translation is put back). `docs/deathcarry_fatality_arachnotron_red_before_after.jpg`.
- **Named like an effect, painted like a body**: `RevenantDust` (the Revenant's bone dust, `SPIC`, painted with its
  family), `BurningCacodemon` (its own `HEAD` frames), `XDeathBurnedBlueMeat` (`CACB`). Fix: a thing the name rule calls an
  effect follows the body when its states draw a sprite that has painted art, never when its name says blood, mist, gore,
  fire, smoke or another effect (Brutal Doom's blood mist draws the painted gore sprites `XDT1`: it stays blood).
- **Kept their own look now** (the gore pass's note and this census): craters (`DetectFloorCrater*`), metal shards
  (`MetalShard1-3`), scrap (`XJunk1-5`), the ice chunks of a shattered frozen body (`XIceChunk1-3`: ice keeps its own, as
  in the family files), the Arachnotron's blue spark (`ShoqueAzul`), and every Legion of Bones class by name (its risers
  `SkullZombieSpawn` and kin: when a riser becomes a monster with a family, that monster gets its own kit).
- **The driver** put every painted body back on the tint for a tic when the camera went away (Brutal Doom's fatality
  camera ending: every dying body at once, 35 tics into a fatality). Fix: no camera, no change that tic.

**The tint where art exists (the Demon's, Cacodemon's and others' death sets): a sprite clash, not the driver.**
RSQ Monsters' ColorfulHell port ships 51 sprites under BD22 / XMVE names (`BOSB BOSC BOS2 BOS3 VILP DIAB TRO3 TRO4 CACB
CACF CACX FAT2 FAT3 FAT4 FATF ARAC BSPI CSPI DEMO SKEL ZKEL TERM SRG2 ASGZ MPOS CYBB ...`, 584 frame letters; about 17 are
byte-identical copies, the rest ColorfulHell's own pictures) and loads after BD22 and XMVE, so the engine draws ColorfulHell's
frame for every letter both define: BD22's Hell Knight's burnt death shows a blue CH Baron, the Arch-vile's head gib a
magenta CH Arch-vile, `TRO3` (the coordinator's 22 tics of TRO3 on the tint) CH's imp, and so on; their lump names
carry rotations (`BOSBE1`) where the art has `BOSBE0`, so no art was found. The owner's call (11-14 01:05): **"Bd22 look
is right"**: RSQ Monsters' versions are not painted. The driver now falls back to the frame's single-rotation art
(`BOSBE1` -> `BOSBE0`, unmirrored), so a coloured body draws BD22's look. Still open (not colour, so not done here): the
same clash makes those frames show ColorfulHell's picture on monsters at their entry colour (as shipped), and on frames
where both sides have rotations under different letters. `docs/deathcarry_sprite_clash_bd_vs_rsqmonsters.jpg`.

Frames (rig01, sector light 224, 260 units; test-only: weapon, laser, bars, Kill Rewards off, `ue_recolour 0`):
`docs/deathcarry_scenes_before_after.jpg` (FireBlu to White, frozen: the burning man, the blasted crawler, the
Arch-vile's armless crawler (BD22's look now, not ColorfulHell's magenta), the Revenant gibbed, the burning Cacodemon,
the Taunt rebirth, the Blood Demon's and Void Spectre's plain deaths), `docs/deathcarry_fatality_arachnotron_red_before_after.jpg`.
No script error and no VM abort from our packs in any census or frame run (BD22 VoxelPack's own VOXELDEF lines as on main).

Left (after):
- **Not censused: they stop the rig, before and after alike** (killed by all their deaths at once the engine hangs or the
  level ends): `SuperOverlord`, `AracnorbQueenBOSSBOSS`, `SuperSpiderMastermindX` (a boss death ends the map), and some
  batches of `Labguy` (its fire deaths: BD22's `BurningZombie` has `Spawn: BDT1 B 0 ... Loop`, a 0-tic loop: "Infinite
  state loop", then the rig stalls), `RifleCommando` and its two XMVE kinds, `HellTrooper`, `BFGZombie`,
  `Vanilla_HellTrooper`, `Annihilator`, `Vanilla_Demolisher`, `LabguyB` (one batch each). For the owner: a fire kill of a
  BD22 scientist may stall the game on his order too (seen on the rig only).
- A few pieces still hold no colour (2,288 actor-snapshots of 110,036): the Void Spectre's `VoidSpectreHeadPiece`
  thrown far from the body by Draugr / Incarnate deaths, some `BurningZombieMan` (Red, Black, White cells), generic gore
  whose maker is a summon at the world tier, some zombie falling / splattered stages (`ZombiemanFallingSplattered`,
  `DeadZombieMan_Blasted`), `Ricochet` (an effect, correctly none).
- On the tint (no art, by the families' choices): Brutal Doom's generic flesh parts `ID22` (`SpiderPart*`, `PEPart*`,
  `Aracnorb_Brain`), frozen bodies that are all ice (`FZD5` ...), ashes (`ASHZ`, `ASHY`), the marine half `HPLA`.
- Summons (Lost Souls, Phantasms, Impure Souls, Aracnorbs spat by other monsters) come at the world tier: design 2.8 only
  covers the Pain Elemental's Lost Souls. Not a body question; the owner's call.
