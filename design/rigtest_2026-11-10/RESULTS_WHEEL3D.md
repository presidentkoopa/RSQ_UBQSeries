# RESULTS_WHEEL3D: 3D models on the saber, shield, whip and fist cards (2026-11-11)

Bug from the owner's headset (11-11 15:05): "the wheel shows no 3d models for saber, shield, whip, or fist. if we set it
to 3d model it should show our colored fbx fist".

**Not run.** Owner's order 11-11 15:07: "no rig test, code only until i say". No rig launch and no load check
(`/tmp/lc.sh` launches the game) were made. The Wheel pk3 was rebuilt (`python3 tools/build_all.py Wheel`). Everything
below is **code only, not shown**. There are no WHEEL3D_* evidence files.

## Why the cards showed no model

`Wheel/zscript/wheel/zscript.zs` `spawnCardModels`: a card whose class has one of the Wheel's own icons (`ownIconOf`:
the saber, ShieldSaw, whip, fist, gloves, flare, torch, Force hand) was skipped before any model was spawned, so it kept
its flat icon. Without that skip they would still have shown nothing: a card's model must be a pickup voxel that
`wr_VoxSize` can measure, and these packs draw their weapons as MD3 meshes on the hand layers (UBQS_Saber, SSQ_ShieldSaw,
RSQWP_WhipWeapon, RSQ_Glove; BD22's Melee_Attacks / BD22 VR's RSQ_Hands), with a TNT1 or model-only Spawn state.

## The fix (code only, not shown)

| Card | What it now shows | Source |
|---|---|---|
| Saber (UBQS_SaberBase: UBQS_Saber, UBQS_SaberOff) | the hilt, blades in | RSQ Saber's `UBQS_HipSaber`, UBSP N (MODELDEF.hip: UBQS_Saber's own pickup block) |
| Shield (SSQ_ShieldSaw) | the shield, closed | RSQ ShieldSaw's world prop `SSQ_Prop`, SSQP A |
| Whip (RSQWP_WhipWeapon) | the coiled whip | RSQ Whip's `RSQWP_Stowed`, RSWP A |
| Fist (Fist's replacement: Melee_Attacks; RSQ_Hands) and gloves (RSQ_Glove, RSQ_GloveOff) | RSQ Melee's FBX fist in BD22 VR's Hand Skin Tone (`rsq_hand_tone`, BD22 VR's `models/rsq/fbx/tones/fbx_hand_tNN.png`, the way Melee's `RSQML_HandLook.Tone` wears it); the boxing glove while Slappers Only or Boxing Gloves is on (Melee's `Gloved()`) | `RSQ_Glove`, RMHF A (FBX fist) / RMHG A (glove) |

- Each is spawned by its class name, so its own pack's MODELDEF draws it. A pack not loaded: the card keeps its icon.
  The flare, torch and Force hand keep their icons (not asked for).
- Sizes and centres are measured from the meshes, not guessed: `Wheel/tools/measure_card_props.py` reads each block's
  Scale, Offset and MD3 frame as the engine's world path places them (`models.cpp` RenderFrameModels), and
  `wr_CardProp` (`wr_q_vox.zs`) holds the numbers. Each prop is fitted inside its card as the voxels are, and turns about
  its own middle (a hand model's origin is 22 units from the hand; the saber's 29 from the hilt).
- The fist's tone is read from the local `rsq_hand_tone` (as the Wheel reads all cvars), not in multiplayer (as Melee).

## Open, for the first rig run (when the owner allows)

- Compile and load: not checked (no launch).
- The frames: Wheel open with Gun Models on Cards on, the saber, shield, whip and fist cards; and a second with Boxing
  Gloves on (glove). Look for: each inside its card, turning about its middle (not orbiting), the fist in the chosen tone.
- The saber's centre uses the engine source's Offset rule (Offset not scaled by the MODELDEF Scale); TacticalRig's
  `measure_pickups.py` divides the Offset by the Scale, which for the saber's 1.608 block differs by 11 units at scale 1.
  If the hilt orbits its card, that is the number to check.
- TacticalRig's Mirror view takes the first visible `SSQ_Prop` near the player as the shield on your back
  (`TacticalRig/zscript/rsqtr/mirror.zs:137`): with the ring open, the shield card's prop may be the one it finds.
