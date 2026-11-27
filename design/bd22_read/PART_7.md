# BD22 VR Reloaded bug read, part 7: zscript/rsvr, rsg, nosniper (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

## Files read
All paths are under `src/`.

| file | lines | read to the end? |
|---|---|---|
| zscript/rsvr/melee.zs | 1-2054 | yes |
| zscript/rsvr/axegrab.zs | 1-548 | yes |
| zscript/rsvr/door.zs | 1-436 | yes |
| zscript/rsvr/vrhand.zs | 1-321 | yes |
| zscript/rsvr/yield.zs | 1-48 | yes |
| zscript/rsg/grenade.zs | 1-745 | yes |
| zscript/nosniper/nosniper.zs | 1-117 | yes |
| CVARINFO.rsvr | 1-45 | yes |
| MAPINFO.rsvr | 1-6 | yes |
| MAPINFO.nosniper | 1 | yes |
| CVARINFO.rsx | 1-35 | yes |
| MAPINFO.rsx | 1-2 | yes |
| MENUDEF.rsx | 1-29 | yes |
| DECORATE.rsm | 1-36 | yes |

Total 4,423 lines. Opened outside the part, to confirm or kill a suspicion (parts only): `zscript/rsq/pose.zs` (whole),
`zscript/rsq/fists.zs` 95-175, `zscript/rsq/handler.zs` 1-30, `zscript/rsq/dual.zs` 125-200 and 320-392,
`zscript/rsr/vreload.zs` 240-300 and 1320-1335, `actors/Weapons/Axe.dec` 1-72, 176-199, 283-300, 455-508,
`actors/Weapons/Grenades.dec` 120-200, the Ready states of `Pistol.dec`, `Revolver.dec`, `BrutalRevolver.dec`,
`DECORATE.rsqdual`, `zscript/rsq/recoil.zs` 1-75, `ZSCRIPT.rsvr / .nosniper / .rsx`, `MENUDEF.rsq` (by search),
`README.md`, `src/README.txt`, `CHANGELOG.md` (by search), the built `pk3/03_BD22_VR-Reloaded_3.0rc.pk3` (its MAPINFO
lumps only). In the RSQ series (not this repo), parts of `Melee/zscript/rsqml/service.zs`, `club.zs`, `shove.zs` and
`DistanceGrab/zscript/rsqdg/feel.zs`, `door.zs`, to see what the other side of each by-name call does.

## What the prompt asked to be stated exactly

**Which hand's pose is read**
- The swing (axe, sword, saw, pistol whip, butt strike): `RSVR_Hand.Frame` reads the pose history, `RSQ_Pose.MAIN` for
  `hands[]` and `RSQ_Pose.OFF` for `offHands[]` (zscript/rsvr/melee.zs:894-915). MAIN is the engine's weapon controller
  (AttackPos / AttackDir), OFF the other one (OffhandPos / OffhandDir), as sent by zscript/rsq/pose.zs:294-297.
- The psprite tested for "held pose" is `PSP_WEAPON` for the main hand and `PSP_OFFHANDWEAPON` for the off hand
  (melee.zs:823).
- The off hand swings only the off-hand axe, and (without RSQ Melee) a pistol or revolver (melee.zs:762-790). It never
  runs the saw, the sword or a butt strike.
- The axe throw: the same `RSVR_Hand` of the hand that threw (melee.zs:1580, 1589).
- The grenade: the weapon controller for the throw (grenade.zs:448), the off controller for the ring (grenade.zs:476,
  through `RSR_State.offLocal`), the off TRIGGER only for the ring (grenade.zs:465).
- Doors: hand 0 is the weapon controller and `AttackRoll`, hand 1 the off controller and `OffhandRoll`
  (door.zs:166, 251). The grip is the off grip only (door.zs:169).

**Left-handed play.** The engine swaps the controllers itself, so "main" is always the weapon hand. Only three places
in this part know about `vr_control_scheme`: the rumble backup (melee.zs:1531-1532), the pose sender, which sends a
`left` flag (pose.zs:293, 272), and nothing reads that flag. See B7.5.

**Speeds and their units**
- Swing thresholds are metres a second, turned into map units a tic by `* vu / 35` (melee.zs:1106-1110): axe 3.0 x 1.5,
  sword 3.5 x 1.5, butt `rsq_butt_speed` 2.4 (clamp 1-8), whip `rsq_whip_speed` 5.0 (clamp 1-12), all times
  `rsvr_melee_swing` (floor 0.2). The measured speed is map units a tic in the body's frame over the stamped gap
  (melee.zs:1119-1127). The vertical part is not corrected for pixelstretch (B7.12).
- Sword: `SWORD_ARC` 34 map units, `SWORD_COOL` 12 tics, `SWORD_CALM` 4 tics (melee.zs:431-433).
- Throw test (axe and grenade): metres a second from the hand, `THROW_MIN` 2.2, `MARK_MPS` 1.0 (melee.zs:453-454,
  970-985; grenade.zs:676). Thrown speed: 3 x the measured step, clamped 14 to 42 map units a tic (melee.zs:1776,
  grenade.zs:689).
- Lock-on: cone in degrees, range in map units (melee.zs:1676-1677). Seek: 12 degrees a tic, 105 tics (melee.zs:1945,
  1971).
- Grenade: ring distances in centimetres, mouth distances in metres, fuse 48 tics (grenade.zs:347-361).
- Doors: touch 7 map units, door speed in map units a tic (the special's eighths), lift cap 4 x (door.zs:39-40, 115-119).
- Thrown axe on the ground: 175 tics, red from 70 (axegrab.zs:76-77).
I found no place where tics and seconds, or metres and map units, are mixed up, apart from B7.12.

**RSQ Melee of the RSQ series also loaded**
- The only test is `RSVR_MeleeYield` (yield.zs:15-28): `ServiceIterator.Find("RSQML_Service")`, `GetInt("owns", "club")`
  and `GetInt("owns", "punch")`, each `== 1`. `RSVR_MeleeHandler.AskMelee` asks once a second and in `WorldLoaded`
  and keeps the answers in `mlClub` / `mlPunch` (melee.zs:29-43, 109-111, 133-134).
- What stands down on `mlClub`: the main hand's butt strike and pistol whip (melee.zs:719-720) and the off hand's
  pistol whip (melee.zs:770-771). What stands down on `mlPunch`: the VR punch of both fists (rsq/fists.zs:130-131).
- What never stands down: the axe (both hands, swing and throw), the Dragonslayer, the chainsaw (melee.zs:712-717,
  767-768), the Melee Hit Flash (melee.zs:220-232), No Trigger Punch, and Brutal Doom's own button attacks.
- RSQ Melee's answer (read in its source, `service.zs` `Owns`, `club.zs:286-290`): 1 for both whenever the classes
  `BrutalWeapon`, `RSVR_MeleeHandler` and `RSVR_MeleeYield` all exist. It does not depend on RSQ Melee's own rows. So
  with both loaded this pack's whip, butt strike and VR punch are always off, and RSQ Melee's own rows
  (`rsqml_butt`, `rsqml_pistol_whip`, `rsqml_bd_punch`) decide. With RSQ Melee's row off, nobody does that move.
- When both could act on one swing: only in the first second after loading a saved game that was saved with a
  different load order (B7.18). On a new map `WorldLoaded` asks before the first tic, so there is no overlap.
- The Melee Hit Flash draws on RSQ Melee's hits too (by design, yield.zs:11-13). If RSQ Melee draws its own effect on
  the same hit, the player sees two effects. I did not read RSQ Melee's effect code.

**State that survives a map change.** `RSVR_MeleeHandler`, `RSVR_AxePool`, `RSVR_Door`, `RSG_Handler`,
`RSQ_PoseHandler` are level event handlers: the engine makes new ones for every map, so their fields start empty. What
travels is the player's inventory: `RSVR_Axes`, both axes, and every `RSVR_Token` / `RSG_*` token. Two of those tokens
are left set by an exit and are not cleared on the new map (B7.1, B7.7). `RSVR_HandSync` is static and clears itself in
`WorldLoaded` (vrhand.zs:193).

## Findings, worst first

## B7.1: Leave a map with the grenade's pin out and on the next map the grenade is stuck in your hand: it shows pin out, will not throw, and you cannot switch weapons
- Kind: wrong behaviour
- Where: src/zscript/rsg/grenade.zs:238-246, 337-338, 393-399, 426-436; src/actors/Weapons/Grenades.dec:157-166
- What the code does: `RSG_PinOut` and `RSG_Spoon` are inventory tokens, so they go with the player to the next map.
  They are cleared only by `RSG_State.Reset`, which runs from `Spent`, from `Step` when `armed` is true, and from
  `WorldLoaded` for a state that already exists. On a new map `RSG_Handler` is a new object, `st[n]` is null, so
  `WorldLoaded` skips the player (`!st[n]`, line 242) and the new `RSG_State` starts with `armed = false`. `Step` then
  never calls `Reset` (line 430 needs `armed`). The weapon still sees `RSG_PinOut` and goes to `RSG_Armed`, which is
  `A_WeaponReady(WRF_NOFIRE|WRF_NOSECONDARY|WRF_NOSWITCH)` every tic (Grenades.dec:164-166).
- Why it is wrong: the drawn grenade says pin out (or cooking, with `RSG_Spoon`), the script says pin in. Letting go of
  the trigger does nothing, no fuse runs, and `WRF_NOSWITCH` blocks every weapon switch. The way out is to pull the
  pin again (ring or teeth) and throw it, which nothing tells the player.
- Checked: every writer of the two tokens (grep: only grenade.zs:397-398, 493, 521, 634); the readers
  (Grenades.dec:158-165). The comment at grenade.zs:233-237 and 530-533 describes this same symptom from 2026-10-23
  ("the live grenade sits in the hand for good") and blames the map clock; the re-base at 534-538 cannot help because
  the state it re-bases is new on the new map.
- Sure?: likely. Certain from the code if a level's event handlers are made new for each map (stock GZDoom). One exit
  with the pin out settles it.
- Fix A: where the state is made (grenade.zs:337-338), call `st[n].Reset(mo)` right after `new('RSG_State')`. 1 line, 1 file.
- Fix B: in `Step`, when `!armed`, set `RSG_PinOut` and `RSG_Spoon` to 0 every tic. 2 lines, 1 file. Also covers any other way the two get out of step.
- Or intended: no; the comment says a new map should start clean.
- Already known?: no

## B7.2: Closing a menu (or loading a save) with the axe or the Dragonslayer out can whoosh and cut a monster beside you, with no swing
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:1058-1072, 1119-1128, 1181-1195, 1226-1247; src/zscript/rsq/pose.zs:87-90
- What the code does: the swing speed is this tic's blade point minus last tic's, in the body's frame. The pose counts
  as fresh for 3 tics of `maptime` (pose.zs:87-90). While a menu is open in single player the game is paused, so
  `maptime` does not move and the last sample stays fresh. The player points at the menu with the controller. On the
  first tics after the menu closes the hand is somewhere else, the difference is taken over a gap of 1 tic, and it
  reads as a very fast swing. The teleport and snap-turn guard was removed in 1.97 (melee.zs:1050-1056) and nothing
  replaced it for a jump of the hand itself. The fists have such a guard (`JUMP`, rsq/fists.zs), and the throw test
  has one (melee.zs:981).
- Why it is wrong: one tic of bogus speed plays the swing sound and sweeps the blade along the whole jump
  (melee.zs:1243-1247). For the Dragonslayer a jump of 34 map units at the point (it is 1.8 m from the grip, so a small
  turn of the wrist) arms the swing in that one tic (melee.zs:1189-1194) and lands DSAttack + DSAttack2. Without RSQ
  Melee the pistol whip and butt strike do the same and also press a switch within reach (melee.zs:1262-1263).
- Checked: `Reset()` callers (melee.zs:1030-1048): kind change, pose not ready, pose stale, placement change. None
  fires on a menu close. On a loaded save the level handler gets no `WorldLoaded` (door.zs:66-68 cites the engine), so
  `hands[]` come back with `havePrev` true and the saved `prevRel`. The direction tests still apply (no upswing, the
  axe's edge leading), so not every close does it.
- Sure?: likely. Not run. Settle it: hold the Dragonslayer next to a monster, open the menu, point somewhere else,
  close it.
- Fix A: in `Tick`, after `Frame`, compare the hand (`fH` in the body frame, not the blade) with last tic's. More than
  half a metre in one tic (`0.5 * vu` map units, the fists' `JUMP`) means `Reset()` and return. About 6 lines, 1 file.
- Fix B: also give `RSVR_MeleeHandler` the `afterLoad` flag `RSVR_Door` uses (door.zs:69-75, 149) and reset both hands
  on the first tic after a load. About 8 lines, 1 file. Fix A alone covers both cases.
- Or intended: no.
- Already known?: no

## B7.3: The Recoil row does nothing: recoil never runs
- Kind: setting or menu
- Where: src/MAPINFO.rsvr:5; src/MAPINFO.rsx:2; src/MAPINFO.nosniper:1; src/zscript/rsq/recoil.zs:52; src/MENUDEF.rsq:133; src/CVARINFO.rsq:57
- What the code does: `RSQ_Recoil` is an `EventHandler`. No `AddEventHandlers` list names it, in `src/` or in the built
  pk3 (MAPINFO.rsvr, .rsx, .nosniper, .rsld all checked). The engine only creates handlers that are listed.
- Why it is wrong: the menu has a Recoil row (`rsq_recoil`, on), and the 2.0.5n work "each gun kicks in its own hand"
  and "recoil for the Silvergun, Ruger, Nuke Launcher..." (CHANGELOG.md:32-58) changed code that is never called.
  `zscript/rsld/ld_g2_proj.zs:56` looks the handler up and gets nothing.
- Checked: CHANGELOG.md:748-750, in the 1.99 section: "Recoil is gone. It turned the gun model, so the gun spun around
  the shoulder". So it was taken out of the list on purpose then, and the later rows and fixes were built on it as if
  it still ran. The repo has one commit, so I cannot see when it left the list.
- Sure?: certain that it is not registered. That recoil therefore does nothing follows from stock engine behaviour.
- Fix A: recoil stays off: remove the Recoil row (MENUDEF.rsq:132-133) and say so in the changelog. 2 lines.
- Fix B: recoil comes back: add `"RSQ_Recoil"` to MAPINFO.rsvr:5. 1 word. It brings back whatever made the owner
  remove it in 1.99 unless that was fixed since; headset check needed.
- Or intended: off is intended (1.99); the row is not.
- Already known?: partly. Q2, SH4, SH5, SH9 all treat recoil as running. Owner said for SH4 "Fix it", SH5 "Add them",
  Q2/SH9 "a Recoil row is added". None of them notes that the handler is not registered.

## B7.4: Let go of the trigger while stepping up a stair and the axe or the grenade is thrown at your feet instead of kept
- Kind: wrong behaviour (drifted copy)
- Where: src/zscript/rsvr/melee.zs:959-969 (line 964); src/zscript/rsg/grenade.zs:447-453 (line 448)
- What the code does: both throw samplers measure the hand against `mo.pos`, the pawn's feet. The hand position they
  read hangs off the view height (`RSVR_HandSync.Body`, vrhand.zs:313-320; pose.zs:269-271). On a step the pawn's feet
  go up 8 to 24 units in one tic and the view catches up over several tics, so the hand reads as dropping 8 to 24 units
  against the feet. Over the 2-tic window that is 4.9 m/s for an 8-unit step, above `THROW_MIN` 2.2.
- Why it is wrong: for the grenade, "let go while still: it cooks" (grenade.zs:515-524) becomes a throw, straight down
  (the measured motion is downward), at the 14 units a tic floor, with a live fuse. For the axe an unpainted release
  with no swing throws it and spends an axe (melee.zs:1771). The swing code already measures from the view for this
  reason (vrhand.zs:167-169).
- Checked: `Fix()` returns `Body(mo) + offset` (vrhand.zs:291-292); `Body` z is `player.viewz`. The 0.5 m-a-tic guard
  (melee.zs:981, grenade.zs:661) does not catch a step of 24 units or less.
- Sure?: likely. Not run. Settle it: pull the pin, walk up a staircase, let go of the trigger mid-step with the hand still.
- Fix A: measure from `RSVR_HandSync.Body(mo)` in both: melee.zs:964 `fH - RSVR_HandSync.Body(mo)`, grenade.zs:448
  `RSVR_VRHand.HandPos(mo) - RSVR_HandSync.Body(mo)`. 2 lines, 2 files.
- Or intended: no.
- Already known?: no

## B7.5: Left-handed: the axe (and every other swung weapon) may be worked out upside down, so real chops are refused
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:905; src/zscript/rsq/pose.zs:52, 272, 293
- What the code does: `fU = off ? -ph.U : ph.U`. The comment says the engine mirrors the LEFT weapon, and the code
  flips the OFF hand's up axis. The pose carries `left` (the sender plays left-handed) and nothing reads it.
- Why it is wrong: if the engine mirrors by which controller is the left one (as both comments say: melee.zs:905,
  vrhand.zs:81-83), then for a left-hander the main hand is the mirrored one and the off hand is not. The main axe's
  blade would be computed below the wrist and the off axe's too. That is the 2.0.3q fault ("the edge-first rule threw
  out every real chop", CHANGELOG.md:608-612), for both hands.
- Checked: grep for `vr_control_scheme`, `LeftHanded`, `.left` in all of `src/zscript`: only pose.zs, bottomhud.zs and
  the rumble line. The engine source is not in the repo, so I cannot see whether it mirrors by left controller or by
  off hand.
- Sure?: unsure. Settle it: play left-handed, chop down on a monster with the main-hand axe.
- Fix A: `fU = (off != ph.left) ? -ph.U : ph.U;` 1 line, 1 file (if the engine mirrors the left controller).
- Or intended: correct as it is if the engine mirrors the off-hand weapon whichever side it is on.
- Already known?: no

## B7.6: The off-hand axe buzzes the wrong hand, or no hand
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:1477-1478, 1505-1510, 1559, 1721, 1816; src/zscript/rsg/grenade.zs:401, 484, 495
- What the code does: `Buzz(mo, off)` can buzz the off controller (`ALF_ISOFFHAND`, melee.zs:1509). `Strike` skips the
  buzz for the off hand with the comment "the engine buzzes the WEAPON hand only". `WallCheck`, `LockTick` and `Throw`
  call `Buzz(mo)` with no hand, so the off axe hitting a wall, painting a monster or being thrown buzzes the MAIN hand.
  The grenade's ring, taken by the off hand, also buzzes the main hand.
- Why it is wrong: a hit with the off axe gives no feel; its wall hit, lock and throw are felt in the other hand.
- Checked: `RumbleBackup` takes `off` too (melee.zs:1521-1534). No other buzz path in these files.
- Sure?: certain from the code. Whether `ALF_ISOFFHAND` on `SpawnPlayerMissile` really buzzes the off controller is the
  engine's; the comment at 1502-1503 says it does.
- Fix A: pass `off` in the four calls (melee.zs:1478 drop the `if (!off)` and call `Buzz(mo, off)`; 1559, 1721, 1816
  `Buzz(mo, off)`). 4 lines, 1 file. The ring: `RSVR_Hand.Buzz(mo, true)` at grenade.zs:484 and 495.
- Or intended: only if the off buzz was tried and does not work on the Quest.
- Already known?: no

## B7.7: Leave a map with the trigger held on the axe and, on the next map, holding the grip or alt fire no longer readies a throw until you press the trigger once
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:1576; src/actors/Weapons/Axe.dec:43-56
- What the code does: `RSVR_AxeTrig` is given in `TrigGrip` and taken when the hold ends (Axe.dec:44, 48, 54). It is an
  inventory token, so an exit during the hold carries it over. `Grip` then reads the trigger instead of the hold input
  for every later hold: `CountInv('RSVR_AxeTrig') > 0 ? BT_ATTACK : HoldDown(mo)`.
- Why it is wrong: on the alt-fire or grip path the trigger is not down, so `held` is false on the first tic and the
  axe goes straight back to Ready. Any trigger hold clears it.
- Checked: writers of `RSVR_AxeTrig` (Axe.dec:44, 48, 54; axegrab.zs:187). Nothing clears it on a new map: the handler
  is new and `WorldLoaded` only resets hands that exist (melee.zs:112-128).
- Sure?: likely. Not run.
- Fix A: in `WorldTick`, where `hands[i]` is made new (melee.zs:140-141), take `RSVR_AxeTrig`, `RSVR_AxeHolding`,
  `RSVR_OffAxeHolding`, `RSVR_AxeThrown`, `RSVR_OffAxeThrown`. About 6 lines, 1 file.
- Or intended: no.
- Already known?: no

## B7.8: Butt Strike, Pistol Whip, Lift Doors by Hand and Punch Switches Open have no menu rows; the README tells the player to turn Butt Strike on
- Kind: setting or menu / misleading text
- Where: src/CVARINFO.rsvr:39-45; src/CVARINFO.rsq:42, 51-53, 10; src/MENUDEF.rsq (no row); README.md:163-165;
  src/README.txt:90-92; src/zscript/rsvr/melee.zs:746, 1107
- What the code does: `rsq_butt` (0), `rsq_butt_speed`, `rsvr_butt_fwd`, `rsq_pistol_whip`, `rsq_whip_speed`,
  `rsvr_melee_swing`, `rsq_punch_use`, `rsq_door`, `rsq_door_grip`, `rsq_door_use`, `rsq_door_palm`,
  `rsq_door_commit`, `rsq_door_gain` and all `rsvr_axe_*` are read by the code and appear in no MENUDEF lump.
- Why it is wrong: README.md lists Butt Strike under "Off until you turn them on"; README.txt says the rows "say
  'without RSQ Melee'"; code comments speak of "its own option row" and a "Swing Needed row". Without RSQ Melee the
  butt strike can only be switched on from the console, and Lift Doors cannot be switched off in the menu.
- Checked: grep of every MENUDEF.* for each name. CHANGELOG.md:476-478, 556 name rows that existed once.
- Sure?: certain that the rows are absent. I do not know whether the 2.0.5n menu rewrite dropped them on purpose.
- Fix A: add rows on Test and Debug: Butt Strike, Pistol Whip, Lift Doors by Hand, Punch Switches Open (4 rows), and
  the two speed sliders if wanted. About 12 lines, 1 file.
- Fix B: keep the menu short and correct the README lines (README.md:165, src/README.txt:90-92).
- Or intended: the short menu is intended; then the README is the bug.
- Already known?: no (Q3 and RL7 are about other rows)

## B7.9: A quick tap on the trigger just after the next axe comes to hand can throw it with no swing
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:954-985, 1000-1012
- What the code does: `tHist[]` / `tOk[]` hold the last 7 hand samples. `Reset()` does not clear them, and they are
  only written while the axe is in its held pose. After a throw the pose is away for about 17 tics; when the next axe
  is ready the ring still holds the fast samples of the throw just made. `ThrowMs()` pairs old samples with old ones
  for the first 4 tics.
- Why it is wrong: in those tics a release reads the last throw's speed and counts as a throw.
- Checked: `Throw` also needs a non-zero edge step (melee.zs:1771), which any hand tremor gives.
- Sure?: likely, and narrow (a release within 4 tics of the axe being ready).
- Fix A: in `Reset()`, set all `tOk[]` to false. 2 lines, 1 file.
- Or intended: no.
- Already known?: no

## B7.10: Two bare hands on a door: either hand letting go drops the door; on two door lines at once, the first door is left hanging part open
- Kind: wrong behaviour
- Where: src/zscript/rsvr/door.zs:164-201, 274-297, 315-317
- What the code does: both hands test `dLine[n] < 0` in the same tic, before the grab event comes back, so both can
  take hold. `Grab` overwrites `dLine[n]` without letting the earlier door go. A release from one hand releases the
  player's one door.
- Why it is wrong: with Use (which both hands share) and hands on two different door lines, the first door's ceiling
  stays where the hand left it with no mover; it is only put right by using it again. On one line, a palm that turns
  away releases the door while the other hand still holds.
- Checked: `ApplyAll` only moves `dLine[n]`; nothing tracks the abandoned door.
- Sure?: certain from the code; rare in play.
- Fix A: in the hand loop, skip a start when the other hand already has `held[1 - h] >= 0`. 1 line, 1 file.
- Or intended: no.
- Already known?: no

## B7.11: "A palm turned out" takes a door with the palm turned either way
- Kind: wrong behaviour
- Where: src/zscript/rsvr/door.zs:247-257
- What the code does: `abs(abs(roll) - 90) <= 30`: a roll near +90 or near -90 both count. The comment says the
  values come from `rsqdg_palm_roll / _tol` when Distance Grab is loaded; the code uses fixed 90 and 30 and an unused
  `p`.
- Why it is wrong: a free hand rolled the other way, resting within 7 units of a door, takes hold of it too.
- Checked: with Distance Grab loaded this handler stands aside anyway (door.zs:156-159).
- Sure?: unsure which roll sign is "out" for each hand; the headset settles it.
- Fix A: accept one sign per hand (mirrored for the left controller). 3 lines, 1 file.
- Or intended: either way counts, as ported from Distance Grab.
- Already known?: no

## B7.12: A straight-down chop needs about 20% more arm speed than a level one
- Kind: wrong behaviour (units)
- Where: src/zscript/rsvr/melee.zs:943-945, 1119-1128, 1135
- What the code does: `Place` divides the vertical by pixelstretch (1.2), as the engine does. The swing speed is the
  plain length of the body-frame difference. pose.zs:38-41 says a threshold should be compared against the speed with
  pixelstretch put back (`Speed()`); the throw test does that (melee.zs:980), the swing test does not.
- Why it is wrong: the same real swing reads slower the more vertical it is; `rise` is read slightly low too.
- Checked: `BodyFrame` (melee.zs:1646-1651) passes z through.
- Sure?: certain from the code; the size of the effect in the hand is the owner's to judge.
- Fix A: `double speed = (vel.x, vel.y, vel.z * ps).Length();` and the same for `velIn`. 2 lines, 1 file. It makes
  downward chops easier than today, so the thresholds may want a look.
- Or intended: possible; the thresholds were tuned by feel with this in.
- Already known?: no

## B7.13: Without RSQ Melee, a pistol whip or butt strike into a wall makes the axe's wall hit
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:1538-1563 (line 1558), called at 1271
- What the code does: `WallCheck` runs for every swung kind and launches `AxeAttack` at the wall.
- Why it is wrong: a gun striking a wall sparks and clangs as the axe, and `AxeAttack` can hurt a monster standing at
  that spot.
- Checked: the saw returns before it (melee.zs:1102); the unarmed sword passes power 0.
- Sure?: certain from the code. What `AxeAttack` shows on a wall is Brutal Doom's and in Axe.dec.
- Fix A: `if (k != AXE && k != SWORD) return;` at the top of the hit branch (line 1555). 1 line.
- Or intended: a generic "metal on wall" was wanted.
- Already known?: no

## B7.14: A thrown axe can be mistaken for another axe that appears near it in flight
- Kind: wrong behaviour
- Where: src/zscript/rsvr/axegrab.zs:211-249
- What the code does: any `BrutalAxe` / `BrutalAxeOnWall` that spawns within 64 units of a flying thrown axe is taken
  as what that throw left (`t.item = a; t.proj = null`).
- Why it is wrong: a second thrown axe landing, or an enemy dropping an axe, beside one still in the air ends the
  tracking of the flying one: the wrong axe blinks red and fades at 5 s, and the flying one's hit and its +2 on a
  catch are lost.
- Checked: the loop takes throws in order and returns at the first match.
- Sure?: unsure; needs two axes within 64 units in the same tics.
- Fix A: only bind while `t.proj` is null or destroyed (the flight has ended). 1 line.
- Or intended: no.
- Already known?: no

## B7.15: Distance Grab's axe pickup always goes to the console player
- Kind: netplay
- Where: src/zscript/rsvr/axegrab.zs:541; src/zscript/rsvr/melee.zs:39; src/zscript/rsvr/door.zs:152, 329
- What the code does: `RSVR_AxeGrabEventService` gives the axe to `players[consoleplayer].mo`; the request does not
  carry the player.
- Why it is wrong: with two players each machine would give the axe to a different player. QuestZDoom has no netplay
  (melee.zs:1520), and door.zs uses `consoleplayer` on purpose (local hand, net events).
- Sure?: certain from the code.
- Fix A: take the player from the grabbing actor if Distance Grab passes one; otherwise leave.
- Or intended: yes while QuestZDoom has no netplay.
- Already known?: no

## B7.16: Work done every tic that a Quest would rather not do
- Kind: performance
- Where: src/zscript/rsg/grenade.zs:68-74, 76-131 (lines 78, 85, 121, 128-130); src/zscript/rsvr/melee.zs:1699;
  src/zscript/nosniper/nosniper.zs:98-116
- What the code does:
  - Every missile that spawns is put in `missiles[]` and four parallel arrays, and two loops walk them every tic
    whether or not a grenade is in the air. Brutal Doom spawns many missile-flagged effects. Removal is `Delete` from
    the middle of four arrays.
  - With a grenade in the air, `ShotR()` (two cvar lookups) is called for every missile every tic (line 121).
  - `WorldScale()` and `CanShoot()` each make a `ServiceIterator` every tic (lines 78, 85).
  - While a throw is held with nothing painted, `LockTick` walks the blockmap 2,400 units wide every tic (melee.zs:1699).
  - `RSQ_NoSniper.WorldTick` does 13 class lookups by name and 13 cvar lookups a tic for each player.
- Why it is wrong: none is large alone; the missile list grows with a big fight.
- Sure?: certain that the work is done; not measured.
- Fix A: grenade.zs: read `ShotR()` once before the loop; skip the missile bookkeeping while `nades.Size() == 0`
  (clear the list). About 6 lines. nosniper.zs: resolve the classes once in `OnRegister`. About 10 lines.
- Or intended: acceptable as is if the rig shows no cost.
- Already known?: no

## B7.17: Comments, README lines and leftovers that say what the code does not do
- Kind: misleading text / dead code
- Where and what:
  - src/README.txt:86 "AXE / DRAGONSLAYER swing them; two hands and the edge leading bite harder." The axe is never
    two-handed (melee.zs:14-18, 1434) and the edge leading is required, not a bonus (melee.zs:1153-1160).
  - src/CVARINFO.rsvr:23-27 describes `rsvr_axe_edge` as the two-handed axe's bonus; it now gates every axe cut.
  - src/zscript/rsg/grenade.zs:236-237 "Fires for a loaded savegame too": a level handler gets no `WorldLoaded` on a
    load (door.zs:66-68 says so and is built on it). grenade.zs:649 says `THROW_MIN` is 1.5; it is 2.2 (melee.zs:453).
  - src/zscript/rsvr/melee.zs:298 says `WorldTick` runs before the weapons tick, 1578 says after.
  - melee.zs:100-106 and 107-129: on a new map there are no hands to reset (new handler); the block only matters on a
    return to a hub map.
  - Never used: `RSVR_GiveOffAxe` (melee.zs:1892), `RSVR_AxeTwo` (1898, still asked by rsq/hands.zs:1093), `sAXE2`
    (583, 691), the AXE `pf == 1` block (2042-2043), `RSVR_AxeHalf` (Axe.dec:687), `BUTT_SWING`, `WHIP_SWING`, `RISE`
    (434-435, 459), the unused `p` in door.zs:253, the one-pass loop at grenade.zs:187.
  - The `RSVR_OffAxeGone` block (melee.zs:155-177) is only reached when the off hand has no `RSQ_Hands`
    (melee.zs:1627-1633); with axes left, `AxePool` gives the off axe straight back.
- Sure?: certain.
- Fix A: correct the three player-facing lines (README.txt:86, CVARINFO.rsvr:23-27) and the two wrong comments; remove
  the unused tokens with the next change to that file.
- Already known?: partly. RL9 (`rsvr_melee_down` comment, fixed in 2.0.5n; "Clean it all"), SH11 (`rsvr_butt_lead`
  removed; it now only appears in a comment at melee.zs:1169).

## B7.18: After loading a save made with a different load order, the whip, butt strike and punch can land twice, or not at all, for up to a second
- Kind: wrong behaviour
- Where: src/zscript/rsvr/melee.zs:29-43, 107-111, 133-134; src/zscript/rsvr/yield.zs:18-19
- What the code does: `mlClub`, `mlPunch` and `mlAskAt` are saved with the handler. A load does not call
  `WorldLoaded`, so the saved answers stand until the once-a-second ask.
- Why it is wrong: a save made without RSQ Melee, loaded with it: both act for up to 35 tics. The reverse: neither.
- Sure?: likely; small.
- Fix A: have `Club()` / `Punch()` ask when `mlAskAt > level.maptime` or on the first tic after `OnRegister`
  (a transient flag). 3 lines.
- Or intended: tolerable.
- Already known?: no

## B7.19: Returning to a hub map, the first press of the axe's grip key can be ignored
- Kind: key
- Where: src/zscript/rsvr/melee.zs:48-51, 92-96, 114
- What the code does: `keyIsDown` (ui) is saved with the map's handler. Leaving a hub map with the key down saves it
  as down; on return `keyDown[]` is cleared but `keyIsDown` is not, so the next key-down is taken for a repeat.
- Sure?: unsure (hub maps only, `rsvr_axe_keys` set, key held through the exit).
- Fix A: mark `keyIsDown` transient. 1 word.
- Already known?: no

## B7.20: The caught-axe guaranteed critical may never arm
- Kind: wrong behaviour
- Where: src/zscript/rsvr/axegrab.zs:92-100
- What the code does: MK Crits is detected by casting `csh_critController` to an Inventory class.
- Sure?: unsure; MK Crits is not in the repo.
- Fix A: look the class up as `class<Object>`. 1 line.
- Already known?: yes, RL8, owner said: "Rig check list: confirm on the rig".

## B7.21: Turning Cheat Extra Weapons off may leave the off-hand MP40 behind
- Kind: wrong behaviour
- Where: src/zscript/nosniper/nosniper.zs:8-16, 98-116; src/zscript/rsq/dualtable.zs:13
- What the code does: `gone[]` lists `MP40`; its off-hand version `RSQ_Off_MP40` is a separate class and is not
  listed. `CountInv` is exact, so the swap takes the MP40 and leaves the copy.
- Sure?: unsure; I did not find code in rsq/dual.zs that takes a copy whose gun is gone, and did not read all of it.
- Fix A: add `'RSQ_Off_MP40'` with stand-in `'RSQ_Off_BrutalSMG'` to the two lists. 2 lines.
- Or intended: cheat-only path.
- Already known?: no

## Things that looked wrong and are not (so the next reader does not chase them)
- door.zs:158-159 casts `RSQDG_Door` to `class<StaticEventHandler>` and uses `EventHandler.Find`: in Distance Grab
  `RSQDG_Door` is a level `EventHandler`, so the lookup works and this pack's doors do stand aside.
- door.zs:80: `dLine[]` starts at 0 (line 0), but `WorldLoaded` sets -1 before the first tic, and a load restores it.
- melee.zs:302 `FindInventory(Inv('BrutalAxe'), false)`: exact class, so the off axe (a subclass, Axe.dec:455) is not
  taken for the main one. `KindOf` compares the class name, also exact.
- door.zs:419 `w is 'BrutalAxe'` does cover the off-hand axe (it inherits from BrutalAxe), so an axe hand never takes a door.
- melee.zs:837: the pistol's held frames (PIST E, PIST I, 2IST E) match Pistol.dec:220-222 and the off pistol
  (DECORATE.rsqdual:231-233). The revolvers hold frame A (Revolver.dec:216, BrutalRevolver.dec:103, 281).
- The axe's hold loops keep sprite AXEG frame A (Axe.dec:40-42, 50-52, 491-493), so the throw samples keep running
  while a throw is readied.
- melee.zs:1613 compares a class with a name literal (`thrown != 'RSVR_AxeThrown'`): fine.
- axegrab.zs:163-196 `ToEmpty` swaps the psprite from inside the axe's own state action; the same pattern as
  `RSQ_Dual.Become`. Not checked against the engine.
- axegrab.zs:490-528 `RSVR_AxeStun`: two stuns on one monster inside 50 tics would leave NOPAIN on, but a critical
  needs a throw, a hit, a catch and another throw; not reachable in 50 tics.
- nosniper.zs: `gone[]` and `instead[]` both have 13 entries and line up. The MG42 spawner honours
  `rsq_mg_replaces_mg42` (SH6, changed in 2.0.5n).
- CVARINFO.rsx and MENUDEF.rsx: every cvar has a row in MENUDEF.rsq with a matching range, and a reader. The two
  option lists (`RSQ_PumpSpread`, `RSQ_HandTone`) are used at MENUDEF.rsq:131 and 65.
- CVARINFO.rsvr: every cvar is read. `rsvr_melee_up` and `rsvr_butt_lead` exist only in comments.
- MAPINFO.rsvr / .rsx / .nosniper: every handler named exists exactly once. (`RSLD_MenuDelegate` in MAPINFO.rsld is a
  menu delegate, not a handler.)
- The grenade's ring and the reload geometry use the engine's own hand axes, which already include the mirror, so
  they need no left-hand case (vreload.zs:250-252, 264-278). B7.5 is about the pose history only.
- grenade.zs:412-414 selects the fists every tic while the empty grenade is out: it only sets PendingWeapon.
- yield.zs:23 `ServiceIterator.Find(...).Next()` with no service returns null; guarded.
- `rsg_rsq_nade` has no row: RL7, owner said "Remove this row", removed in 2.0.5n. The cvar still works from the console.
- RL2 (the off grip takes a door only with Grab Ammo With on the grip): the code now reads `doorGrip`
  (door.zs:169, vreload.zs:1326-1331). Fixed as recorded.
- Q1 / SH1 (bare fists cannot punch): `rsq_punch` is 1 by default now (CVARINFO.rsq:7). Fixed as recorded.

## Not read or not checkable
- Brutal Doom's base pk3 is not in the repo: `ShortGrenade` (the parent of `RSM_KindRound`, DECORATE.rsm:10) could have
  death labels not overridden there, which would still go to its own explosion; `FragGrenadeExplosion`, `HandGrenade`,
  `GrenadeTime`, `MeleeStrike*`, `KickAttack`, `SawDamageHorizontal`, `DSAttack*`, the ACS `FistSelect`, and the sounds
  `Axe/*`, `Melee/SwingStrong`, `Grenade/*`, `weapons/shell` are all Brutal Doom's and were not seen.
- The QuestZDoom engine source is not here: the left-weapon mirror (B7.5), `ALF_ISOFFHAND` rumble (B7.6), whether view
  bob moves `viewz` in VR, and the class `Door` with `dirUp` (door.zs:305-306) rest on the code's own comments.
- MK Crits is not here (B7.20).
- RSQ Melee, Distance Grab, RSQ Grenade and RSQ SlowMo were opened only at the lines these files call by name.
- `actors/Weapons/Axe.dec` and `Grenades.dec` belong to another part; I read only the states my files drive.
