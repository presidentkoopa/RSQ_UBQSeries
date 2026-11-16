# Sprite names shared with other packs, and the Colourful Hell 1.04 sprites (2026-11-16)

Monster Assembly items 6 and the owner's 09:03 addition. Measured with scripts against the owner's full load order (the
list in `rig/work/boss/boss_full.sh`: doom2, TUD, LegenDoom 3.0, brutal22test6, BD22 VoxelPack, BD22 VR Reloaded 2.0.5a,
the four XMVE pk3s, Legion of Bones 1.05, Champions, No More Hitscans, Universal Entropy, Spawn Adjuster, the nine
environmental pk3s, MK Crits, RegenShield, ShotgunSpawner, Gun Bonsai 0.10.6, every RSQ pk3 of the 11-16 release gate).

## Why a shared name matters

RSQ_Monsters loads after Brutal Doom 22, XMVE, Legion of Bones and Champions. Under one sprite name the engine takes, for
each frame letter, the lumps of the last archive that has that letter: **every frame RSQ_Monsters ships under a shared
name replaces the other pack's**, even under a different lump name (our `BOSBE1` rotation lumps replaced Brutal Doom's
`BOSBE0`). The other pack's monsters then wear Colourful Hell's art (Brutal Doom's Arch-vile drew as a red Colourful
Hell Arch-vile at Common; RS_BDArt's 11-14 fallback only covered painted colours).

## What was found, and done

| Shared sprite | Over | Our frames that drew a different picture | Our code uses it? | Done |
|---|---|---|---|---|
| ARA2, ARAC, BOS3, CACF, CSPI, FAT3, FAT4, GRND, MPOS, ZSP2, RSP6, LEF1, LEF2 | Brutal Doom 22 / XMVE / Champions | 1-55 each (ARAC 49, MPOS 16, ZSP2 40 ...) | no | **our lumps removed** (312) |
| BOSB, BOSC, CYBB, FATF, REVP, TRO3, VILP | Brutal Doom 22 | rotation lumps over its frames (83, 83, 65, 40, 101, 53, 121) | no | **our lumps removed** (546) |
| ARNQ, ASGZ, BLUD, BOS2, BRUR, BSPI, CACX, CALI, CARD, CBAL, CPS2, DEMO, DIAB, FRFX, IMPB, QSZM, SKEL, SMK2, SRG2, TERM, ZKEL, ZSP1, CACB, FAT2, SUPR, TRO4, FATT (frame T only) | Brutal Doom 22, XMVE, Legion of Bones, Champions | 1-119 each (DIAB 119, TERM 94, SKEL 77, DEMO 62 ...) | yes | **ours renamed** (table below); the state lines that draw them follow (1,987 lines) |
| 46 more (ACNB, BRUS, INCA, OVER, RSH0, RSU1 ...) | XMVE, BD22 VR Reloaded, Champions, doom2 | none: the same pictures (or, for BOSS and MISL, letters only we have) | | left as they are |

**Renamed** (old -> new; every new name checked against every sprite name in the order):
ARNQ->RRNQ, ASGZ->RSGZ, BLUD->RLUD, BOS2->ROS2, BRUR->RRUR, BSPI->RSPI, CACX->RACX, CALI->RALI, CARD->RARD, CBAL->QBAL,
CPS2->RPS2, DEMO->REMO, DIAB->RIAB, FATT T->RATT A, FRFX->RRFX, IMPB->RMPB (its letters packed: A, I-U -> A-N), QSZM->RSZM,
SKEL->RKEL, SMK2->RMK2, SRG2->RRG2, TERM->RERM, ZKEL->QKEL, ZSP1->QSP1, CACB->RACB, FAT2->RAT2, SUPR->RUPR, TRO4->RRO4.
After: 0 shared names draw a different picture (re-measured).

Already fixed before: WICK -> RVWK (11-12).

## The Colourful Hell 1.04 sprites (owner 09:03)

The read-only comparison with Colourful Hell 1.04 (`/tmp/chcmp/absent_sprites.txt`) listed 50 sprite names our code
draws that the pack never carried, so those things drew nothing. Each was checked against our zscript's state lines
(frames used) and copied from `Enemies_ColourfulHell_1_04.pk3` into `sprites/monsters/ch104/` (its own folder names):
**49 sprite sets, 670 lumps**, every frame letter our states use present. **SMT1** (`RS_SmithGhost1`) is not in
Colourful Hell 1.04 either and stays without art. Nothing Colourful Hell has that our code does not draw was brought in.

Among them: ROAC (the Abyss Imp `RS_AbyssImp2`), VCCM (the Abyss Cacodemon `RS_AbyssCaco2`), SKLT (Mr Bones), UNHE
(Moloch Wraith, soul seekers), EWRM / DEAE / TWIA (Wakawaka), SPI1 (Mini Phantom), T4TE / T5TE / T6TE (the Abyss
Arch-vile's portal and tentacles), VIOB (ArchSpawnerOrb), AYPB (the Abyss conversion every family's Pain.AbyssPE plays),
DKAT / SWRD / RHLD (the Black Knight's darts and fire, sword, shield), HGRN (grenades), A8Y5 (the Abyss shot marker),
TARM / THAD / TSHO (the Terminator's thrown parts), BRHM / MAUL (hammers), CGUP / ZOMP / IMPP (the Purple Chaingunner's,
Purple Zombie's, Purple and FireBlu Imp's gib frames), CACT / GTEE / PTSU (their drop-items).

Shared names among them: FDFX, LFX2, TARM, THAD, TSHO are in XMVE with the same pictures (harmless); SHLD (over Brutal
Doom 22) and SG2A (over XMVE) differ, and were imported as RHLD and RG2A. Five imported sets that started high in the
alphabet had their letters packed from A (the engine reserves every letter up to a sprite's last one): A8Y5, BISH,
CGUP, ZOMP, SWRD, IMPP.

## The sprite-frame budget (the engine's 65,535)

Read from the engine on the rig (gdb, `SpriteFrames.Count`, the boss_full order with the 12 RSQ_BDXMTiers pk3s; runs
`asm_sfc_base`, `asm_sfc_new`): **55,114 before, 55,746 after: +632**, 9,789 to spare. (The renames give our frames
their own names, which costs letters the shared names used to share; the removals and the packed letters pay some of
it back; the HA/HB/HM/HFRM health-bar sprites of the deleted TEXTURES.txt are gone too.)

## Loading the colour art before RSQ_Monsters

The owner's PK3TEST folder sorts `RSQ_BDXMTiers_*` before `RSQ_Monsters`. They hold no sprite names and no code (art by
full path, drawn through `picnum`, and a GLDEFS of brightmaps), so the order does not matter: the same run with the 12
art pk3s before RSQ_Monsters (run `asm_order3`) drew every tracked monster from its art (RSART: tracked 27, drawn 27),
as with them after (run `asm_gate2`). Rig only, not headset-confirmed.

Rig only, not headset-confirmed: the Abyss Imp, Abyss Cacodemon, Mr Bones and the AYPB conversion drawn (frame
`rig_2026-11-16_assembly/ch104_sprites_drawn.png`, log `rig_logs.txt`).
