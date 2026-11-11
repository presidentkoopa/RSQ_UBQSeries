# WATCHVOX: "watch check causes phantom voxels along the sight" (owner's headset, 11-11 15:05)

**Status: code only, not shown.** The owner ordered "no rig test, code only until i say" (11-11 15:07) before any
launch, so nothing here was run: no rig frames, no load check (`/tmp/lc.sh` boots the game too). The cause below is
read from the code and the engine source (QuestZDoom 17.3 = gzdoom 9afc750, the rig's PINS), not seen.

## The cause (from the code)

| Step | Where | What it does |
|---|---|---|
| 1 | `Accessibility/zscript/rsqg/gestures.zs` InspectPose | The watch check is the back of the wrist turned to your face, hand 0.15-0.65 m in front of the eyes, wrist twisted 35 deg or more. With a gun in that hand the gun points forward or across the chest (the code's own note on `rsqg_inspect_way`). |
| 2 | `LaserSight/zscript/rsqls/sight.zs` HandLive (before the fix) | Nothing held the laser off in that pose: only Off When Aimed Down, a weapon switch, melee weapons and the engine's brace. |
| 3 | `LaserSight/zscript/rsqls/beam.zs`, `tools/gen_beams.py` write_kvx | The Quest beam is a rod of voxels 0.4 cm square and 0.4 cm long, each its own palette index (its distance from the muzzle), drawn as a HUD model, additive, over the world (the HUD model depth squeeze). PC VR adds the 8-arm halo rod. |
| 4 | together | With the gun across the chest the rod runs a hand's width in front of the eyes. At 15-30 cm a 4 mm voxel is about 1 deg across, and each one has its own brightness step, so the beam reads as a row of separate blocks laid over the watch card and the hand: voxels along the sight. Aimed normally the same rod runs away from the eye and the blocks are too small to see. |

"We had this issue before": the only earlier record is `design/PARKED.md` (owner 11-07 05:49): "the stray bright voxels
seen in the outer beam were never tracked down". It was never fixed: the answer was Beam Sparkle, which is off by
default, so nothing regressed. The git history before 11-05 is not in any of the three repos, so an older fix could not
be checked.

## Ruled out (read, not run)

| Suspect | Finding |
|---|---|
| Voxel sprite names shared between packs | VOXELDEF lumps of every pk3 in the owner's order compared: LaserSight's LZ/LH and Gun Cards' card sprites are defined by no other pack, and no other pack has sprites with those names. Only BD_VoxelPack and RSQ Monsters share pickup voxels (CLIP, SHEL...), which are not along the gun. |
| Psprite layer ids | LaserSight 2140/2141, 1000140/1000141; Gun Cards 1000299-1000359, 1001200-1001599; FlashFlare 7311-7313; Grapple/Whip 2200. No overlap. |
| The watch-check tick | `RSQA_Buzz` is a quake (no view shake in VR, `r_quakeintensity` 0). With Rumble Backup on and Quake Haptics 0 it is a 0.1-unit `LAF_NOINTERACT` hitscan: no WorldHitscanFired (p_map.cpp returns the puff first), so no BD22 VR tracer or round (rounds need 2048 units). See the side finding. |
| QuestZDoom's M8F laser | Held off whenever ours is on (decb7c22); the watch check does not touch `rsqls_on`. |
| Range readout glyphs | Off by default; billboards, not voxels. |

**Side finding (not the voxels, not fixed, BD22 VR's repo):** BD22 VR's `zscript/rsq/flash.zs` and `recoil.zs` treat every
player hitscan as a shot, so with Rumble Backup on and Quake Haptics 0, every backup pulse (the watch-check tick included)
lights a muzzle flash, plays the gun's sound tail and kicks the gun. Its missile route already skips its own buzz
(`ballistics.zs` IsShot); the hitscan route has no such test.

## The fix (LaserSight only)

`LaserSight/zscript/rsqls/sight.zs`: `WatchCheck` asks RSQ Accessibility's `RSQG_Service` "inspect" by name, else RSQ Gun
Cards' copy (`RSQGC_GCopyService`), the two readers the watch card is shown from. In `HandLive`, a hand whose watch check
is entering or held (answer 1 or 2) has no laser that tic: HideHand takes the beam, the halo, the dot, its light, the arc,
the ring and that hand's range for the readout. Lowering the wrist brings it straight back. With neither mod loaded, or
the watch check switched off (-1), nothing changes. No new row. README updated (How to Play, Controls, Status).

## Not shown, and what would show it

Nothing above was run. When the owner allows the rig: BD22 VR shotgun in the main hand, laser on, Quest look, the gun
turned across the chest in front of the eyes (yaw only: roll does not reach ZScript on the rig, so the watch check itself
cannot be met by pose there and a probe has to stand in for its "inspect" answer); frames before and after the fix at
1080, looked at, plus a log of `laser.beam` for that hand going 1 -> 0 -> 1. The blocks themselves are a headset
judgement: the owner's eye decides whether they are gone.

## Update, owner 15:26: "two instances, one green, one gray", parallel to the laser, going away from the gun

That rules out the first reading (the real beam seen close). Still read only, not run (no rig, no lc.sh). What the code says:

| Question | Finding |
|---|---|
| What in the load order is a rod of voxels? | Only RSQ Laser Sight's beam rods (LZ, 7,344 entries) and halo rods (LH, 7,344). Every VOXELDEF and voxels/ lump of every pk3 in the owner's order was read: Gun Cards' 16,442 pieces are glyphs, keys and plates; BD_VoxelPack, RSQ Monsters and FnF are pickups. A rod laid parallel to the gun's beam, starting at the muzzle, is a rod built for a gun placement (its VOXELDEF carries that gun's muzzle as pivot and its barrel's yaw). |
| Which colours fit? | Green is the off hand's default laser colour (`rsqls_col_off` 20 ff 30). In Laser: PC VR a beam is two rods: the halo in the hand's colour (green) and the core pushed 62.5% toward white and x1.5 (a pale grey-green that reads grey). Gun Cards' watch card has C_GREEN 80e040 and C_GREY c8c8c8, but none of its layers can show a rod sprite (only beam.zs writes a layer's sprite to a rod; Gun Cards sets its states from its own classes). |
| The Rumble Backup trace (coordinator's suspect) | Cannot draw a line. It is 0.1 units with LAF_NOINTERACT; p_map.cpp (17.3) returns the puff before WorldHitscanFired on both the miss and hit paths, so BD22 VR's shotfx tracer, ballistics, SlowMo's trail never run, and playerrounds makes rounds only past 2048 units. Its PreFired hooks do run: flash.zs lights a muzzle flash and plays the tail, recoil.zs kicks the gun (the side finding above). Not tagged or changed: a light and a kick are not two rods. |
| Tactical Rig, Accessibility | Neither draws anything along the aim for the watch check (Rig: the watch move, off by default, on Use; Accessibility: a quake or the backup trace, and a grey text line low on screen). |
| How the pair gets onto the gun hand during the check | **Not found.** |

**Fix, widened (LaserSight only):** while EITHER hand's watch check is met, both hands' lasers go out whole (HideHand
destroys the beam and halo layers 2140 / 2141 / 1000140 / 1000141 and hides dot, arc, ring, readout). Whatever puts those
rods on the gun hand, no Laser Sight rod is drawn during the check. If the owner still sees the two rods with this build,
they are not Laser Sight's, and the table above is wrong about what is a rod. Code only, not shown.

The quickest proof when the owner allows it, no rig needed: Laser Sight's Off Hand row off (or Laser: Quest), then a watch check.
