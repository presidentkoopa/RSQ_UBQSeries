# RESULTS_MBTIER (2026-11-11): the Miniboss colour bonus from Gun Bonsai VR, and Smoker across a level change

Everything below is **rig only, not headset-confirmed**. The owner's load order from `run.sh` (doom2 > brutal22test6 >
BD_VoxelPack > BD22 VR 2.0.4f > LOB > Champions > GunBonsai 0.10.6 > every RSQ pk3, rebuilt from this change) plus a
test-only probe (`evidence/MB_TIER_probe/`: sets the Gun Bonsai VR player level and each hand's weapon record level
directly, reads both hands through RSQGB_Service as Miniboss does, lists each Bossfight monster with RSQ Monsters' own
"tier", logs every change of the player's bINVULNERABLE). MAP01 of doom2, RES 120, no frames (logs prove each point).
`rsqmb_debug 1`, `rsqmb_bf_ignore 1`, `rsq_monster_set 2`, fights called with `rsqmb_fill 1000` + `rsqmb_callin`.
Main hand BrutalPistol, off hand its BD22 VR twin RSQ_Off_BrutalPistol (BD22 VR's Dual key, `give StartDualWield`).

## 1. The tier bonus (Miniboss/zscript/rsqmb/fight.zs ApplyFrom, the arrival tic)

| Case | Debug line (start -> final) | Colours on the actors after landing | Evidence |
|---|---|---|---|
| A: player 3, weapons 3 + 2 = 5 (1.25 rounds down) | miniboss 2 -> 5 (+3), thralls 1 -> 2 (+1) | RS_YellowZombie tier 5; 3 x RS_GreenZombie tier 2 | MB_TIER_MBT2_log.txt (MB_TIER_A_125) |
| B: player 1, weapons 4 + 2 = 6 (1.5 rounds UP) | miniboss 2 -> 4 (+1, still above 3), thralls 1 -> 3 (+2) | RS_PurpleImp tier 4; 3 x RS_BlueZombie tier 3 | MB_TIER_MBT2_log.txt (MB_TIER_B_150) |
| C: player 20, weapons 20 + 20 = 40 | miniboss 2 -> 13 (capped at the top), thralls 1 -> 11 | RS_BrownImp2 tier 13; 4 x RS_WhiteZombie1 tier 11 | MB_TIER_MBT2_log.txt (MB_TIER_C_CAP) |
| E: player 20, weapons 30 + 30 = 60 (+15) | miniboss 13, thralls capped at 12 | RS_BrownImp2 tier 13; 4 x RS_CyanZombie2 tier 12 | MB_TIER_MBT3b_log.txt |
| F: player 0, weapons 10 + 10 = 20 (+5) | thralls 1 -> 6; miniboss 2 +0 RAISED to 7 (one above) | RS_FireBluZombie2 tier 7; 3 x RS_RedZombie tier 6 | MB_TIER_MBT3_log.txt (MB_TIER_F_RAISED) |
| D: fists (Melee_Attacks main, BD22 VR free hand rsq_hands off), both records set to level 9; Miniboss From / Thralls From at their defaults (the map's own) | weapons 0 + 0 = 0, +0; miniboss 1, thralls 1 | RS_CommonZombie tier 1; 3 x RS_CommonZombie tier 1 | MB_TIER_MBT2_log.txt (MB_TIER_D_FISTS_MAPOWN) |
| G: without RSQ_GunBonsaiVR (run_nogbvr.sh) | `RSQMB tier bonus t125: none (Gun Bonsai VR not loaded)`; RS_GreenImp from the start rule only | (no probe: it needs the patch) | MB_TIER_MBT4_log.txt |

The probe's hand readout before each call shows the levels as Miniboss reads them (`MBT HANDS ... gb level`).

Not shown: without RSQ Monsters (the old 0-4 pick). Code: ApplyFrom returns before anything when RSQ Monsters'
service is absent, as before; not run. A retried landing plans again and recomputes from the start colours (no
stacking); not run on purpose here.

Bug found on the way and fixed before the shown runs: the first build did not count BD22 VR's free hand (rsq_hands) as
empty (MBT1, case A read "off 2" from it). RSQ_Hands is now in the fists list.

## 2. Smoker invulnerability across a level change (TacticalRig/zscript/rsqtr/cig.zs)

Fix: RSQTR_Cig gets a WorldUnloaded: bINVULNERABLE goes back to godWas at the level's end, and what is left of the spell
(and godWas) rides on the pocket's token RSQTR_CigPack (as SlowMo's smoke rides on RSQSM_AdrToken); the next level's
WorldLoaded turns it back on for the rest, and the usual end turns it off.

Run (MBT1, after the Miniboss cases; `rsqtr_cig_secs 5`, so 5 + 2 (Smoker 1) = 7 s; Smoker added to the player's
upgrades by the probe; `changemap MAP02`, the intermission moved on with `qz_rgrip 1/0`):

| Step | Log | 
|---|---|
| smoke | `T_CIG smoker: untouchable t229 until t474 (was 0)`; `MBT INV t229 MAP01 bINVULNERABLE 1`; SlowMo kept until t477 |
| level end | `level ends with 193 tics of player 0's untouchable spell left: flag back to 0, the rest carried`; SlowMo carries 196 |
| MAP02 | `untouchable again on the new level for 193 tics (until t193)`; `MBT LOADED MAP02 t0 bINVULNERABLE 1`; SlowMo resumed until t197 |
| end | `T_CIG smoker: untouchable spell over t193, bINVULNERABLE back to 0`; `MBT INV t193 MAP02 bINVULNERABLE 0`; SlowMo ran its time t197; still 0 at t374 |

Evidence: CIG_SMOKER_MBT1_log.txt, CIG_SMOKER_MBT1_script.txt. Not run: death mid-spell on the new level (the
existing per-tic end covers it: health <= 0 restores the flag).

## Load check
`bash /tmp/lc.sh Miniboss TacticalRig`: no script error or warning from our pk3s (the 4 errors are BD_VoxelPack's
voxeldef; the 256 warnings are RSQ_Monsters', as before this change). MB_TIER_loadcheck.txt. Every rig run: errors=4
(the same voxeldef lines).

## 3. The colour bonus reworked to climb the STRENGTH order (owner 11-11 14:51-14:55)

The strength order, weakest first (step 1..13): Common, Green, Blue, Purple, Cyan, Brown, Yellow, FireBlu, Gray, Red,
Abyss, Black (boss), White (boss). Re-measured: `evidence/MB_TIER2_strength.py` (each colour's Health from
Monsters/zscript/monsters/*/, ranked per family, mean rank over the 17 families, EX excluded; Purple 5.18 / Cyan 4.97
tie, Yellow 7.24 / FireBlu 7.21 / Gray 7.56 about even; the owner's order used as given). Table in Miniboss/README.md.

Code (Miniboss/zscript/rsqmb/fight.zs ApplyFrom): the start colours (unchanged rule) are converted to steps; miniboss
+1 step a Gun Bonsai VR player level up to White (13); each thrall +0.25 step a weapon level (main + off, half up) and
stops at Abyss (11); then the miniboss is raised to one step above its strongest thrall. A miniboss this mod puts on a
boss colour gets RSQ Monsters' EX roll (new request `set.class.ex` in Monsters/zscript/monsters/RS_ScoreReadout.zs:
the family's EX form at its EX colour, rolled as the gate's stub does from `rs_ch_exboss`: 24/256, half, always or
never). The debug line now reads `RSQMB colour bonus ... (strength steps)` with names and steps.

Two RSQ Monsters fixes found on the way (Monsters/zscript/monsters/RS_ScoreReadout.zs):
- `set.class` answered "" for a ColorfulHell body that is no Doom class's child (every Black body, e.g. RS_BlackImp1,
  RS_BlackZombie1, RS_BlackSP2): now its family is found by name (FamOfType). Shown by the request probe
  (`MB_TIER2_MBT5x_ex_request_log.txt`, MB_TIER2_exprobe): before, all '' except DoomImp; after, every one answered.
- An EX body read no colour ("tier" -1) on the tic it lands, before its PostBeginPlay gives it its token, so Miniboss lit
  an EX miniboss in the pink fallback (case C below, `colour FF3CC8, tier -1`). Now an EX name reads its gate's colour
  (TierOfName; also `class.tier` / `class.set`). **Code only, not shown** (the owner's "no rig test" order came while
  its rerun was going; that run was stopped after case A).

Run MBT5 (rig only, not headset-confirmed; MAP01, RES 120, no frames; probe `evidence/MB_TIER2_probe` = MB_TIER_probe
plus each scanned body's ladder number, strength step and EX flag; script `MB_TIER2_MBT5_script.txt`). The build had
everything above except TierOfName and the "EX roll only for a colour this mod gave" condition. Start colours in every
case: miniboss Green (step 2), thralls Common (1).

| Check | Debug line (start -> final, steps) | Colours on the actors (scan ~4 s after) | Shown |
|---|---|---|---|
| A: thrall bonus past Abyss stops there; miniboss raised one step above an Abyss thrall (player 0, weapons 30 + 30 = +15) | thralls Common(1) -> Abyss(11); miniboss Green(2) +0 -> Black(12) | RS_BlackImp1 ladder 10 Black, step 12; 3 x RS_AbyssZombie2 ladder 9 Abyss, step 11 | yes |
| B: miniboss climbs to Black (player 10, weapons 0) | miniboss Green(2) +10 -> Black(12) RS_BlackImp1; thralls Common(1) +0 | RS_BlackImp1 Black step 12; 4 x RS_CommonZombie | yes |
| C: Black's EX roll (as B, `rs_ch_exboss 3` = always) | final miniboss Black(12) EX (RS_BlackImpEX) | RS_BlackImpEX ladder 10 Black, step 12, EX; landed in the pink fallback colour (fixed after, code only) | yes (colour fix not shown) |
| D: miniboss climbs to White (player 20) | miniboss Green(2) +20 -> White(13) RS_WhiteImp2 | RS_WhiteImp2 ladder 11 White, step 13 | yes |
| E: .5 rounds up (player 3, weapons 4 + 2 = 6 = 1.5) | thralls +2 Common(1) -> Blue(3); miniboss Green(2) +3 -> Cyan(5) RS_CyanZombie2 | 4 x RS_BlueZombie Blue step 3; RS_CyanZombie2 ladder 12 Cyan, step 5 | yes |

Colours on the actors match the log in every case (the arrival lines' tier and colour, and the probe's scan). Evidence:
`MB_TIER2_MBT5_log.txt` (the run's log lines as printed in the session: its own run.log was overwritten by the stopped
rerun, `MB_TIER2_MBT5_interrupted_log.txt`, which ran case A again on the final Monsters build with the same result).

Not run: a thrall start colour already above Abyss (only with Thralls From = the Map's Own and a Black or White monster
on the map: kept, never lowered; code only); 1.25 rounding down and "no Gun Bonsai VR" were shown for the first version
(part 1, cases A and G) and go through the same lines.

Load: no `lc.sh` after the last two changes (owner's order: no game launches). The stopped rerun loaded the final
Monsters pk3 and the strength-order Miniboss pk3 in the owner's order: 4 script errors, all BD_VoxelPack's voxeldef; 256
warnings from RSQ_Monsters (the same pre-existing deprecated-flag lines as before this change), none from Miniboss or
RS_ScoreReadout. The final Miniboss change (the EX-roll condition, one line) is **code only, not compiled on the rig**.
