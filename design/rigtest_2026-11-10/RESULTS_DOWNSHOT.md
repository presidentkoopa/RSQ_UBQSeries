# DOWN: "the shots I fire seem to come from far to my right" (owner, headset, 11-11 15:05)

**Code only, not shown. Nothing was run** (owner 15:07: "no rig test, code only until i say"; no rig launch, no load
check). No mod code changed. No DOWNSHOT_* evidence exists, because evidence needs a run.

## Result: cause not found in the code

I traced every step from the trigger to the drawn tracer and checked each one against DOWN's crouch. **No step moves the
shot sideways because of DOWN.** I did not make a fix: I found nothing to fix, and a guessed change would break
"measure, don't guess". The next step is one short rig run (below).

## What was checked, and why it cannot move the shot sideways

| Step | Code | DOWN's effect |
|---|---|---|
| Where the engine puts the hand | QZD 17.3 `hw_openxrdevice.cpp:589-610`: AttackPos X/Y = **pawn X/Y** minus the controller offset; Z = eye + controller height - `getDoomPlayerHeightWithoutCrouch` (a **static** number cached once, `:158-170`) | X/Y never read a height. Z follows the lowered eye. |
| Where the engine draws the gun | the same file, `GetHandTransform :432-446`: the same eye, the same static number, the same controller offset | Same transform as AttackPos, so the drawn gun and AttackPos move down together. |
| Shot direction / missile spawn | `p_map.cpp:4784-4800, 5649-5670`; `p_mobj.cpp:7476-7520` | AttackPos and AttackDir only. Side offsets are zeroed in VR (`use_action_spawn_yzoffset`). |
| BD22 VR's muzzle | `rs_brutal22weaponsq/src/zscript/rsq/muzzle.zs` `Where` (hand + muzzle FLU in AttackDir axes), the hitscan re-fire, the trail rail (offsets zeroed, `:470-471`), missiles turned onto the bore | No height, Height or ViewHeight read. |
| The hand "now" | `rsvr/vrhand.zs` RSVR_HandSync: offset from (pawn X/Y, the frame's eye Z), rebuilt on (pawn X/Y, viewz) | The eye moves with the hand, so the offset does not change when DOWN lowers it. |
| True Bullets (default on) | `rsq/playerrounds.zs`: the round starts at `Where`; the last-stretch hitscan is fired by the round (LAF_ABSPOSITION) | Real time while DOWN: the class name starts with "rsq" (SlowMo `clock.zs:1158-1180`). |
| SlowMo's own player trail | `SlowMo/zscript/rsqsm/round.zs:73-100`, drawn only while the clock runs (DOWN always runs it): from the engine's `tempos` (`p_map.cpp:4872-4915, :5106`) | `tempos` is the muzzle after BD22 VR's re-fire. Rounds' hitscans are not the player's, so they get no trail. |
| Laser Sight | the beam is a layer on the gun; `learn.zs` only watches | Moves with the gun. |
| Tactical Rig, ShieldSaw, Score, Melee gloves, Gun Bonsai VR | their `WorldHitscanPreFired` hooks | None of them moves a player's shot. |

## What DOWN does break (real, but none of it is the reported bug)

DOWN scales the pawn's own `ViewHeight` (`down.zs:450`, to 40%). Several scripts take `pmo.ViewHeight` to be the
engine's fixed eye height, the static number above. While DOWN, each of them puts its "eye" or "floor" about 26 map
units (about 0.9 m) too high:
- BD22 VR `rsq/scope.zs:230` (the scope's eye) and `rsg/grenade.zs:564` (the throw face);
- the gesture copy (`tools/gestcopy/gestcopy_template.zs:71`, in Melee, GunCards, Tactical Rig, Miniboss, and
  Accessibility `rsqg/pose.zs:82`);
- Tactical Rig `body.zs:288` (RoomFloor), ShieldSaw `state.zs:191, :343`, Grenade `hand.zs:103`, FlashFlare `geo.zs:48`.

None of these is the gun's shot. These are the owner's call; I have not touched them.

There is also a vertical risk: at 40% the eye is 17.6 units (about 0.62 m) above the floor. A hand held about 0.6 m
below the eyes is then at or under the floor, and its shot starts there. That is a vertical fault, not a sideways one.

## Next (when the owner allows a run)

One map load is enough: DOWN by `r10_hitme 500` (as in `SEAT_DOWN_REMOTE_BLOCK_script.txt`). Fire the rifle standing and
DOWN, once with True Bullets on and once off. Log `Where`, AttackPos, the round's spawn, the first DecorativeTracer and the
SlowMo trail's first point, all against the pawn. Take one frame each way.
