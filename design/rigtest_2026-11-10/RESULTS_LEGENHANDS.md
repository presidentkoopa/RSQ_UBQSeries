# LegenDoom: no hands on the gun (owner, headset, 11-11 15:05)

"playing with legendoom i don't see any of my hands on gun, why?"

**Code only, not shown.** The owner ordered at 15:07: "no rig test, code only until i say". Nothing was launched: no
rig run, no load check. Everything below comes from reading the pk3s and the code. The cause is NOT found yet.

## Facts (read from the files)

| What | Found | Where |
|---|---|---|
| Where the patch lives | BD22 VR 2.0.4f already HAS the LegenDoom patch built in (its "LD mode"). `RSLDP_Service` is defined in BD22 VR, not in LegenDoom 3.0: the LegenDoom_3.0 upload has no RSLDP or ZScript at all. So "RSLDP_Service already exists" is the old LegenDoom_BD22VR_Patch.pk3 clashing with BD22 VR 2.0.4f. RESULTS_P3's note ("the LegenDoom 3.0 upload already holds the patch") is wrong about which file has it | `rs_brutal22weaponsq/src/zscript/rsld/handler.zs:1424`, `ldl_patch/README.md:1-3` |
| The patch source is ours | Yes: `rs_brutal22weaponsq/src/zscript/rsld/` (current) and `rs_brutal22weaponsq/ldl_patch/` (old, retired; "do not load both") | |
| Where LegenDoom goes | BD22 VR's README: right after doom2. With the owner's order: doom2 -> **LegenDoom_3.0** -> brutal22test6 -> BD_VoxelPack -> BD22 VR 2.0.4f -> LOB -> Champions -> Gun Bonsai -> RSQ pk3s. Do NOT load LegenDoom_BD22VR_Patch.pk3 | `rs_brutal22weaponsq/README.md:31-33` |
| How the hands are drawn | Not by the gun's own MODELDEF entry. Both hands (the gun hand and the support hand) are layers of `RSQ_Hands`, an off-hand weapon, with models on `RSQ_GunSide` / `RSQ_Hands` sprites (RQGS, RQGT, RQSP...). They show only while (a) `RSQ_Hands` is the player's OFF-hand weapon, (b) `rsq_hands` is on and the player is in VR, (c) the gun in hand is in `RSQ_HandTable` (by class, `is`) | `src/zscript/rsq/hands.zs:298-336` (Shown, Upkeep), `:338-` (A_RSQ_Layers), `handtable.zs:10` |
| LegenDoom's weapon classes | LegenDoom has its own nine sprite weapons (LDFists, LDPistol...) and replaces 56 classes (weapons, ammo, items, monsters, `LDPlayer replaces DoomPlayer`). The LD mode hands every replacement back to the class it had before (CheckReplacement), and removes LegenDoom's own weapons from the player each tic (`RSLD: took LegenDoom's LDFists / LDPistol` in old LD rig logs) | `rsld/handler.zs:290-299`, `:907-926`; LD `decorate/StartingItems.dec:20,73` |
| MODELDEF lookup | The guns you hold under the LD mode are BD22 VR's own classes (BrutalPistol, Shot_Gun...), so the class-keyed lookups (MODELDEF, RSQ_HandTable) match. LegenDoom's MODELDEF only adds three beam puffs. No sprite-name, cvar or class-name collision between LegenDoom and BD22 VR (checked: 0 shared sprite prefixes, 0 shared cvars) | LD `MODELDEF` |
| Player class | LegenDoom's MAPINFO sets `playerclasses = "LDPlayer"`, but brutal22test6's KEYCONF `clearplayerclasses` / `addplayerclass` runs after it, so the player stays BD's class | LD `MAPINFO`, brutal22test6 `KEYCONF.txt` |

## Ruled out by reading (not by a run)
Class names and the MODELDEF lookup (the held gun is BD22 VR's class); LegenDoom replacing the held gun (handed back);
the player class; cvar and sprite name clashes; TwoHanded weapons (none in LegenDoom or BD22 VR); LegenDoom's ACS
(ENTER scripts give items and draw HUD boxes; none selects a weapon or touches the off hand).

## Not found: what the cause can still be
1. **The off hand never gets `RSQ_Hands`.** Upkeep gives it only when the off hand is empty AND no weapon is pending.
   LegenDoom's ENTER script gives LDFists and LDPistol at map start, which makes LDPistol the pending weapon; the LD mode
   removes it and calls PickNewWeapon. If something keeps a weapon pending, or a weapon other than RSQ_Hands lands in the
   off hand (the off-hand slot is also managed by ShieldSaw, DistanceGrab, Dual, holsters), no hand is drawn on any gun.
   Suspect lines: `rsld/handler.zs:915-926` against `rsq/hands.zs:330-336`.
2. **The owner loaded LegenDoom somewhere else** (e.g. at the end). Then LegenDoom's SBARINFO, MENUDEF, sprites and
   DECORATE replacements come after BD22 VR; the LD mode still hands the replacements back, so this alone does not
   explain it, but his real order is not known.
3. Old LD-mode frames from 11-06 (`rs_brutal22weaponsq/ldl_patch/evidence/key/pA_brutalpistol_in_hand_hud_line_f00420.png`,
   `ldmode/frames_2.0.4b/f00318.png`) show a BrutalPistol and a chainsaw with NO hand on them. Those runs set no
   controller poses, so they do not prove the bug, but nothing ever showed hands on a gun with LegenDoom loaded.
   The README's "our BD22 VR gun, with its hands" was never shown.

## What settles it (needs the owner's go for a rig run)
One short run, LegenDoom right after doom2 in the owner's order, plus the same run without LegenDoom: log every 35 tics
`ReadyWeapon`, `OffhandWeapon`, `PendingWeapon`, `RSQ_Hands.Shown`, `RSQ_HandTable.Index`, and save one frame of a
pistol in hand from each. That says which of the three conditions fails, and the fix follows from it.

## For the owner
- Which spot did you load LegenDoom in, and did you also load LegenDoom_BD22VR_Patch.pk3 (it would refuse to start)?
- May the rig run above go ahead?
