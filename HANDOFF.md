# RSQ_TopHPBars -- handoff (2026-10-27, branch agent-thp)

Rig: rig A (`/home/claude/scratch/run17A.sh`, the real QZD 17.3 binary, zscript 4.14.2), doom2.wad MAP01.
Every number below was measured there; the logs and frames are under `test/evidence/` (copies) and
the scratchpad (`frames/<run>/`, `logsA/<run>.log`). Test runner: `test/run.sh <name> <secs> "<console>" <order>`.

## Branch `agent-polish` (2026-10-27, independent review items) -- read first

Not yet run on the owner's headset. Rig B (QZD 17.3 Linux), probe in the session scratchpad
`pol/thpprobe` (a two-map hub cluster over doom2 MAP01/MAP02, a voodoo doll made by giving a second
DoomPlayer body `player = players[0]`).
- **No bar on voodoo dolls**: `Eligible()` takes a player-class actor only when it is its player's own
  `mo`. Measured: a doll damaged for 5 had 1 bar before, 0 now; the player it passes the hit to still
  gets its bar (1).
- **Hub maps come back tracked**: on `WorldLoaded` with `IsReopen` the level's live monsters (and the
  players) are walked once into the poll list (WorldUnloaded cleared it, and hub monsters come back from
  the snapshot without WorldThingSpawned). Measured: MAP01 -> MAP02 -> MAP01 in a hub, an imp then set to
  3 x spawn health without damage (a legendary's way): overheal bar after 40 tics 0 before, 1 now.
  A saved game was already fine (the list is saved with the handler).
- RSQ_Accessibility's shared menu now has the HP Bars section (its branch `agent-polish`): the open
  item below is done there.
- Full order (doom2 -> brutal22test6 -> BD_VoxelPack -> BD22Q r7 -> Champions -> LegenDoom Lite -> suite
  -> Gun Bonsai + patch), save, load twice, map change: see the polish lane's smoke run in
  RSQ_Accessibility's README / the report (no script error but BD_VoxelPack's voxeldef lines).

## Branch `agent-compat` (2026-10-27): Champions + LegenDoom Lite -- read first

Not yet run on the owner's headset. Rig C = QZD 17.3 Linux, doom2 MAP01, the owner's order (brutal22test6 ->
BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions -> LegenDoom Lite 4.2 -> suite -> Gun Bonsai 0.10.6 + VR patch)
and vanilla doom2 + Champions + LegenDoom Lite + suite; Champions' setting champion_Legendoom 1,
champion_Dormant 1, champion_Booster 1. Probe: the session scratchpad cp/probe (forces tiers through
champion_debug_forced / champion_OverrideChance 256, legendaries through LDLegendaryMonsterPickupGuaranteed).
Save, load twice, MAP02: no script error but BD_VoxelPack's voxeldef lines.

- WearsChampIcon: in Champions' dormant LegenDoom mode EVERY champion is dormant until transformed, not only
  the legendary ones (handler.txt passes ld_dormant to the plain roll too). Measured: two dormant Gold imps
  that LegenDoom never picked reported icon 1 (bar lifted over nothing); now 0; the transformed one 1.

## Done (measured)
- **Compiles and runs clean**: shipped pk3 alone (g0), vanilla + probe (g1), Champions + LegenDoom Lite
  (g3), the owner's full order doom2 -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions ->
  LegenDoom Lite 4.2 -> the 8 suite pk3s -> ours -> damnums (g2). Each: save, load, load again, map
  change. Only script errors in any log: BD_VoxelPack's own `voxeldef.txt` lines 66/72/77/892. (Warnings
  that are not ours: BD's ForceDamageEventScripts / Deh_Actor_153, LegenDoom Lite's guncaster/DRLA compat.)
  Bars survive both loads (g2: 7 bars before, 7 after each load), MAP02 starts clean and gets its own.
- **Default look = coldcite's**: Classic/Red are his PNGs byte for byte; same 112x11 art, 5 % steps, ghost
  half-steps, offset 56,11, scale 0.3, 10 % height offset (log: imp bar 62.70 above feet = 57 x 1.1).
- **Colour sets** (frames `test/evidence/schemes_v5.png`, art `art_sets.png`): worst CIE76 dE between bands
  under the set's own simulation (Machado 2009): ProDeutan 33.6, Tritan 48.1, High Contrast 21.8 (high vs
  overheal strip, which sits apart). Classic under deuteranopia: high-low dE 5.2 (why the sets exist).
  Non-colour cues: low band hatched + pulse (alpha 1.0/0.6, 25 tics each, 1.4 Hz), mid band centre line,
  HC white rim, dark backing, always bright. `cvd_check.txt`.
- **rsqa_colorblind** (stub pk3 with the real cvar's name/type, server int): 1->Protanopia, 2->Deuteranopia,
  3->Tritanopia, 4->High Contrast, 0 -> own setting (`rsqa_override_cb1.txt`).
- **Overheal, LegenDoom Lite**: LDL alone, forced legendaries = 180/60 (StartHealth 0) -> full bar + full
  strip + 1 pip (RS11T); drained by 30 hp hits: RS11J, RS10T, RS10J, strip gone at 60/60, yellow band at
  30/60, removed at death (`ldl_overheal_ld2.png`, `ld2_bars.txt`). Owner's combo (Champions legendoom +
  dormant + booster, LD_diemode for the census): 19/19 natural legendaries at 300 % got a bar with the strip
  without being touched (`own1_census.txt`).
- **Placement**: after every actor has ticked (a statnum-120 thinker), bar-to-thing offset in the plane and
  the Prev mismatch were 0.0000 on every tic, including RSQ_Grapple's real yank (RSQGR_Flight.Launch, flip
  tumble) at 21.9 units/tic and in the full order at 17.4 units/tic (`yank1_sync.txt`, `fullorder_g2.txt`,
  frames `tumble_yank2.png`). During roll/pitch the standing height is held.
- **Voxels**: a test VOXELDEF drawing the imp's frames as a 64-tall KVX (pivot 64): bar top 64.00 (sprite
  would be 57), 70.40 above the feet; held through a pitch tumble (`voxel_top_vox1.*`).
- **Champions icon**: bars over a champion wearing its icon are lifted above it (77.0 = 56 x 1.1 + 14.4 + 1);
  dormant legendary champions (no icon yet) are not lifted (`champions_ldl_own1.png`).
- **coldcite's pk3 loaded first**: 0 of his bars, 0 of his items at every log tic, ours drawn (`coldcite_takeover_cold1.txt`).
- **damnums** (built from github.com/XaserAcheron/damnums for the test only): loads with the full order, no
  errors; its numbers spawn at head height (Height-16), under the bar (`fullorder_damnums_g2.png`).
- **Cost** (rig desktop CPU, VM): 170 bars + 224 tracked monsters: 1.36 us per bar per tic steady, 1.98 us
  when the frame is rebuilt, handler 2.76 us per tic. coldcite's 1.04 on the same scene: 8.36 us per bar per
  tic + 0.115 us per monster per tic for his ticking item (224 items). About 235 us vs 1447 us a tic (`cost.txt`).
  (His bench calls Tick, ours Update: ours excludes one VM dispatch per bar.)

## Not done / needs the headset
- Readability in the headset: coldcite's size 0.3 is ~1 m x 0.1 m in VR; Far Size (x2 at 1024 units) is on
  by default. Thin 1 px rims alias at the rig's 400-600 px eye (HC rim breaks up); judge at Quest resolution.
- The low-band pulse (comfort / photosensitivity), marker icon legibility at 2x, billboard slant at the
  edges of the view.
- Cheello's Voxel Doom II itself is not on this machine: voxel tops were proven with a synthetic VOXELDEF.
  Models (ModelSwapper) are not measurable from ZScript: those use the sprite.

## Round 2 (2026-10-27): markers on real data
- Bar side (handler.zs MarkersOf): RSQGR_Service hooked = "hooked" 0..3 tics or "yanked" 1/2; stunned =
  "stunned" == 1; SSQ_ScoreService "locked" == 1; UBQS_SaberService "gripped" == 1 (README table).
- Added, additive, each on branch agent-thp in its own worktree (not pushed, not merged):
  - RSQ_Grapple (`/home/claude/work/RSQGR_thp`, e01ffb1 + 42de5f5): service.zs "stunned" -- the yank's
    landing hold (rsqgr_yank_stun tics from the tic its throw ended) or the whip's crack within 35 tics
    while in Pain. Existing answers unchanged.
  - UltraBadassShieldSaw (`/home/claude/work/rs_shieldsawq_thp`, bd04648): score.zs "locked".
  - UltraBadassQuestSaber (`/home/claude/work/rs_questsaber_thp`, 3e14b3c): UBQS_SaberService "gripped".
- Proven with the real mods driven by their real inputs on rig A (ssq_draw + ssq-lock, the grapple's
  own throw, `event rsqgr_press`, the dual saber's off-hand alt attack held still): see the round-2
  evidence (`test/evidence/markers_*`), vanilla and the owner's full order, save/load twice, map change.
- Stun is short by design (8 tics default) and the bar polls every 4 tics: the icon can trail by up to 4.
- Gun Bonsai patch's RSQ_Dazed (stagger / down) is not readable by name: RSQ_MeleeUpgradeService has no
  request for it. Adding e.g. "dazed" there would light the stunned icon for its staggers too.

## Open
- (done, RSQ_Accessibility `agent-polish`) the shared menu's HP Bars section, detected by `RSQTHP_Handler`.
- Lossvoise's retexture is still in this repo's own git history (e7e644e, `lossvoise_retexture/`): rewrite
  the history or never push this repo (independent review 10-27, item 7).
- Champions sets a champion's StartHealth to its boosted health, so set-up champions read 100 % there (not
  overheal). LegenDoom Lite's evolve-at-half did not fire in the hurt tests (theirs, not looked into).
- Lossvoise's retexture is not shipped (no permission).
