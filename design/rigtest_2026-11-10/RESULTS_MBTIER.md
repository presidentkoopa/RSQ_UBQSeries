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
