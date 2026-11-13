# RSQ Monster Recolour (PROTOTYPE, branch `wip/2026-11-13-recolour`, not in `pk3/`, not built by `build_all`)

Hand-made recoloured frames for Brutal Doom's and XMVE's monsters on the colour ladder, drawn **without new sprite
names**, so they cost **no sprite frames** under QuestZDoom 17.3's 65,535-frame cap. The prototype is BD22's Imp
family (its body, deaths, crawlers, gibs, fatality and frozen death) in all twelve colours.

**rig only, not headset-confirmed.** Nothing here has been seen in the owner's headset.

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

## Shown on the rig

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

- The art is the owner's approved recipes baked per pixel (from the pixel's own shade, not the palette entry's), plus
  one Imp rule (`Monsters/tools/recolour/families/imp.txt`: its blood and guts, palette 16-47 and 176-191, keep their
  red). It is a starting point for painting, frame by frame; nothing is painted by hand yet. FireBlu's recipe
  alternates red and blue by palette row, which speckles the Imp's death frames.
- Generic gore, burnt (`PBR1`, `XBRN`) and Brutal Doom's shared pieces are not baked: they keep the live tint.
- Each tic re-picks every tracked actor; still corpses could skip until their frame or the view changes.
- All BD22 + XMVE: 11,261 source lumps, 135,132 PNGs, about 300 MB. A plain zip holds 65,535 entries, so it would be
  several pk3s (one per colour fits). A hand-painted frame must live in a folder the bake does not overwrite.

## Build and bake

    python3 -I Monsters/tools/recolour/bake.py Monsters/tools/recolour/families/imp.txt MonsterRecolour/rsrecolour \
        Monsters/TRNSLATE.txt $(cat Monsters/tools/recolour/out/bake_load_order.txt)
    cd MonsterRecolour && zip -qr ../RSQ_MonsterRecolour_proto.pk3 zscript.txt zscript MAPINFO.txt CVARINFO.txt GLDEFS.txt rsrecolour -x rsrecolour/manifest.txt

Load it after RSQ_Monsters. `rsrc_on 0` turns the art off (the live tint only); `rsrc_debug 1` logs what it draws.
Rig probes: `Monsters/tools/recolour/rig/` (test only).
