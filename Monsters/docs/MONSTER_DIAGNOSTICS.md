# Monster Diagnostics, written up (2026-11-16)

Monster Diagnostics is a section of RSQ Monsters' test page: *Radiant Silvergun Options > RSQ Monsters > Test and Debug*
(`RSQMN_Test` in `MENUDEF.txt`; it was `RS_MonsterDebugMenu`, the row was named "Monster Diagnostics" until 11-16).
It came from the owner's RS Monsters (11-09: "Monster Diagnostics could be interesting: fold that into RSQ Monsters").

## What it does now

Since the menu was built (11-16, `MENU_PROPOSAL.md`) it covers **any of the 17 families**:

| Row | What happens | Answered by |
|---|---|---|
| Family | `rsq_mon_dbg_family`, RS_TierLadder's numbers (0 Chaingunner, the default ... 16 Zombieman) | the rows below |
| Spawn Hostile | `rs_mon_dbg_hostile`, off by default: a spawned one stands dormant until WAKE; on, it acts at once | `RS_Diagnostics.zs` |
| the 14 spawn rows | each labelled with its code and that family's monster's name as it is drawn; `netevent rs_diag_spawn N`: that monster, 160 units in front of you, facing you. A family with no EX shows X0001 greyed | `RSQ_MonsterMenu.zs` RSQMNDiagRow, `RS_Diagnostics.zs` |
| Spawn All | `netevent rs_diag_line`: the family in a line across your view, 72 units apart | `RS_Diagnostics.zs` |
| Remove Them All | `netevent rs_diag_clear`: every monster these rows spawned, removed (no kill counted) | `RS_Diagnostics.zs` |
| DIAG | `netevent rs_diag_diag`: one console line each, read from the LIVE actor: code, class, name, health of spawn health, ladder tier, dormant / dead | `RS_Diagnostics.zs` |
| WAKE | `netevent rs_diag_wake`: each one woken, its target you, sent to its See state | `RS_Diagnostics.zs` |

(God Mode, World Tier and the Aimed Monster rows sit on the same page; `MENU_PROPOSAL.md`.)

Before 11-16 only God Mode worked: the other rows sent netevents nothing in the pack answered, and the hostile setting
was read by nothing. Rig only, not headset-confirmed: the Chaingunner's fourteen (run `asm_gate2`) and the Imp's
(run `asm2_gate`, Family Imp) spawned, listed live by DIAG and removed; the rows' labels for Chaingunner, Demon (X0001
greyed) and Imp in `rig_2026-11-16_menu/`.

## The numbering: the key to the expanded coloured roster

Every row carries a code. It comes from the owner's RS Monsters, where every colour of every family was its own class
file named by it (`rs_chaingunner_c0001_common.zs`, `rs_chaingunner_t0001_green.zs` ... `rs_chaingunner_x0001_blackex.zs`;
those files were never in this repo: RSQ Monsters carries the Colourful Hell classes instead).

| Letter | Means | Count in a family |
|---|---|---|
| **C** | Common: the id monster's own form | C0001 |
| **T** | a coloured tier | T0001 ... T0010 |
| **B** | a boss colour | B0001 Black, B0002 White |
| **X** | an EX boss | X0001 (only families that have one) |

The Chaingunner family on the page, row by row (the row's place `N` is what `rs_cg_spawn N` takes):

| N | Code | Colour | Ladder tier (strength) | Class (live, rig) | Colourful Hell's name | CH health |
|---|---|---|---|---|---|---|
| 0 | C0001 | Common | 1 | RS_CommonCGuy | Former Captain | 70 |
| 1 | T0001 | Green | 2 | RS_GreenCGuy | Green Chaingunner | 85 |
| 2 | T0002 | Blue | 3 | RS_BlueCGuy | Blue Chaingunner | 105 |
| 3 | T0004 | Purple | 4 | RS_PurpleCGuy | Purple Chaingunner | 120 |
| 4 | T0005 | Yellow | 7 | RS_YellowCGuy | Orange Former Captain | 200 |
| 5 | T0010 | Red | 10 | RS_RedCGuy | Red Chaingunner | 300 |
| 6 | T0003 | Cyan | 5 | RS_CyanCGuy2 | Jetpack Larry | 125 |
| 7 | T0007 | Gray | 9 | RS_GrayCGuy2 | That is bad camo | 275 |
| 8 | T0006 | Brown | 6 | RS_BrownCGuy2 | Brown Noise Maker | 250 |
| 9 | T0008 | Abyss | 11 | RS_AbyssCGuy2 | Abyss Captain | 500 |
| 10 | T0009 | FireBlu | 8 | RS_FireBluCGuy2 | Bad makeup day | 450 |
| 11 | B0001 | Black | 12 | RS_BlackCGuy2 | ITS MR GENERAL TO YOU,MAGGOT | 4,500 |
| 12 | B0002 | White | 13 | RS_WhiteCguy2 | The crazy lady scientist | 7,777 |
| 13 | X0001 | Black EX | 12 | RS_BlackCGuyEX | LET ME SEE YOUR WARFACE | 8,999 |

(Health: Colourful Hell's, before the skill's monster health and before ladder health at a world tier above 1; the rig
run was at World Tier 10 on Black Metal, so its DIAG numbers differ.)

**The T numbers are the page's own order, not the strength ladder:** T1 Green, T2 Blue, T3 Cyan, T4 Purple, T5 Yellow,
T6 Brown, T7 Gray, T8 Abyss, T9 FireBlu, T10 Red. It is close to Colourful Hell's spawn rarity (most common first: the
Chaingunner dial weighs Green 460, Blue 200, Cyan 130, Purple 100, Yellow 60, Gray / Brown / Red 35, Abyss 30, FireBlu
20) with Red kept last, and not the same as Hackfraud's dial order (Green, Blue, Cyan, Purple, Yellow, Abyss, FireBlu,
Brown, Gray, Red). The ladder (since 11-11) is: 1 Common, 2 Green, 3 Blue, 4 Purple, 5 Cyan, 6 Brown, 7 Yellow,
8 FireBlu, 9 Gray, 10 Red, 11 Abyss, 12 Black, 13 White.

**Why it is the key to the expanded roster:** a code names one monster of one family independently of its colour's
place on the ladder, so the roster can grow without renumbering: a second form of a colour is the next T, a second
boss the next B, a new EX the next X (X0002 ...), and Colourful Hell Plus's subtiers (design/, "the second colour",
11-16) can take codes of their own. Written for all 17 families, a monster's full name is family + code
(`chaingunner T0010` = the Red Chaingunner). How the roster is to be numbered is the owner's call (Questions below);
this write-up records what the page holds.

## Questions for the owner

1. The expanded roster's T numbers: keep the page's order (above) for every family, or number T by the strength
   ladder (T1 Green ... T10 Abyss, so a code's number is its strength)?
2. (Answered 11-16 09:58 with the menu: the page covers all 17 families through its Family row.)
