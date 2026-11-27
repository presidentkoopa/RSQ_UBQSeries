# BD22 VR Reloaded bug read, part 6: zscript/rsr (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

All paths are relative to the repo root (`/home/claude/presidentkoopa/rsq_bd_vr_reloaded`).

## Files read
| file | lines | read to the end? |
|---|---|---|
| src/zscript/rsr/vreload.zs | 1458 | yes (1-1208, 1208-1459) |
| src/zscript/rsr/rsr_guns.bd.zs | 1032 | yes (1-1033) |
| src/zscript/rsr/rsr_assist.zs | 253 | yes |
| src/zscript/rsr/rsr_break.zs | 1491 | yes (1-800, 800-1492) |
| src/zscript/rsr/rsb_guns.zs | 1173 | yes |
| src/zscript/rsr/rsr_pump.zs | 1282 | yes |
| src/zscript/rsr/rsr_pump_guns.zs | 361 | yes |
| src/zscript/rsr/rsr_m203.zs | 974 | yes |
| src/zscript/rsr/rsr_m203_geo.zs | 113 | yes |
| src/CVARINFO.rsr | 35 | yes |
| src/CVARINFO.rsb | 29 | yes |
| src/MODELDEF.rsr | 2091 | yes (1-700, 700-1399, 1399-2092) |

Read outside the part, to confirm or kill a suspicion (targeted, not whole files):
`src/actors/Weapons/Rifle.dec` 1-84, 786-895 and its label outline; the `RSR_*` blocks of Pistol, SubMachinegun, Mp40,
AssaultShotgun, Railgun, Plasma, Sniper, RocketLauncher; the reload blocks of MG42, Minigun, Machinegun, Unmaker,
Flamethrower (Ready loop), the `RSB_*` blocks of SSG, GrenadeLaunch, Revolver, BrutalRevolver; `Shotgun.dec` 1-290;
`src/zscript/rsq/counters.zs` 205-389; `src/zscript/rsq/flick.zs` 70-112, 300-499; `src/zscript/rsvr/vrhand.zs` 18-21,
100-131; the ammo actors in `src/DECORATE.rsqdual` / `DECORATE.rsqdualmg`; `src/MENUDEF.rsq` rows 73-201;
`src/SNDINFO.rsr`; `src/MAPINFO.rsvr` line 5.
A script (kept outside the repo) checked every `Model` block of MODELDEF.rsr: 92 blocks, every md3 and skin file is in
`src/models`, every FrameIndex and SurfaceSkin index is inside its md3's frame and surface count.

## Findings, worst first

## B6.1: With a gun (or an RSQ item) in the off hand, eight guns can never be reloaded: the magazine runs dry and the trigger does nothing
- Kind: wrong behaviour
- Where: src/zscript/rsq/counters.zs:231 and :283-284; src/zscript/rsr/vreload.zs:870 and :1086-1095; the refusal's
  way out in src/actors/Weapons/MG42.dec:26-30, Flamethrower.dec:35, IncendiaryLauncher.dec:29, Machinegun.dec:37-41,
  Unmaker.dec:31-36, Devastator.dec:35, NukeLauncher.dec:34, HellishMissile.dec:32; the one gun that was fixed:
  Minigun.dec:35-44.
- What the code does: the "real magazine" of MG42, Flamethrower2, IncendiaryLauncher, Machinegun, Unmaker, Devastator,
  NukeLauncher, HellishMissileLauncher and Minigun is live whenever the gun is held, VR Reloading is on and the player
  is in VR (`on = held && RSR_ReloadHandler.WantsHands(mo) && NonStdOn(mo)`, counters.zs:231). The hand reload that
  refills it is only allowed when the off hand holds `RSQ_Hands` (`Wanted`, vreload.zs:1094; `RSR_Start.Called`
  refuses at vreload.zs:870). Refused, each of these guns goes `Goto Ready` ("BD22 has no reload for this gun"). Only
  the Minigun got a fallback (2.0.5e, `RSQ_StockFill`, whose own comment says "a refused hand reload left the magazine
  empty").
- Why it is wrong: with a second gun, a saber, a Zippo, a whip (anything that is not `RSQ_Hands`) in the off hand, the
  other eight guns fire their magazine dry (100 rounds for the MG42, 1 for the Nuke launcher), then every trigger pull
  goes Fire -> `RSQ_Empty_<gun>` -> Reload -> RSR_Start -> refused -> Ready. Nothing ever gives `RSQ_Fill_<gun>` (the
  only givers are each gun's own `RSR_Fill` and the Minigun's `RSQ_StockFill`). The reload button and the reload
  gesture (flick.zs:403-454) only set the same `Reload` state. If the magazine was already out (`RSQ_NoMag_<gun>`), it
  cannot be put back either, and the gun cannot fire (counters.zs:284 lends nothing). The player gets one free fill per
  map only (counters.zs:270: `inited` starts false in each map's new handler). A side effect on the Unmaker and the
  Flamethrower: with the skull or canister out and no reload running, `RSR_State.Draw` (vreload.zs:808-818) swaps the
  sprite to `RQWM`/`RQYM` on ready frame A only; their Ready loops then step `"####" B C D` (Unmaker.dec:85-93,
  Flamethrower.dec:100-115) on the swapped sprite, which has no B/C/D model, so the gun blinks out.
- Checked: counters.zs RealTick whole; every giver of `RSQ_Fill_*` in src (grep); flick.zs Reload / ButtonHand;
  dual.zs has no rule that keeps these guns out of a two-gun hold (grep for their names: none).
- Sure?: certain on the code path; not run. A headset test with an MG42 and a pistol in the off hand settles it.
- Fix A: give the other eight the Minigun's fallback: at each `RSR_Start`, replace `Goto Ready` with a short
  `RSQ_StockFill` (take `RSQ_NoMag_<gun>`, give `RSQ_Fill_<gun>`, the gun's own sound, a few `A_WeaponReady(WRF_NOFIRE)`
  tics, `Goto Ready`). About 7 lines in each of 8 files.
- Fix B: in counters.zs:231 use `RSR_ReloadHandler.Wanted(mo)` in place of `WantsHands(mo)`, so the magazine is only
  live when the hand reload can refill it (1 line; the guns are Brutal Doom's own while the off hand is busy).
- Or intended: only if these guns are meant to be one-magazine guns while dual wielding.
- Already known?: no (the Minigun's half was fixed in 2.0.5e; the file does not list the other eight).

## B6.2: BD22's Revolver set to "Revolver Reload: one round at a time" fills the whole cylinder with the first round
- Kind: wrong behaviour
- Where: src/actors/Weapons/Revolver.dec:39-51; src/zscript/rsr/rsb_guns.zs:36 (row 7), :116; src/zscript/rsr/rsr_break.zs:862-881
- What the code does: with `rsb_revolver_feed` 1 the Revolver uses row 7 (five chambers, one round each). Each round
  pushed home gives one `RSB_LoadT` (rsr_break.zs:877). Revolver.dec's `RSB_Load` was patched for the speedloader
  ("fills the whole cylinder", 2026-10-13) and always goes to `RSB_TopUp1`, which loops to 6 and takes a shell for each.
- Why it is wrong: the first round seated loads 6 and takes up to 6 shells; the cylinder model shows one round in and
  four empty chambers, and the next four rounds the player pushes in do nothing. BrutalRevolver.dec:226-242 has the
  split (`A_JumpIf(GetCVar("rsb_revolver_feed") != 0, "RSB_LoadOne")`); Revolver.dec does not.
- Checked: grep for `rsb_revolver_feed` in src: only BrutalRevolver.dec:228 and rsb_guns.zs:25 read it.
- Sure?: certain from the code.
- Fix A: copy BrutalRevolver's `RSB_LoadOne` into Revolver.dec (jump on the cvar after the `A_TakeInventory("RSB_LoadT")`;
  one `RevolverAmmo` and one `AmmoShell` when there is room and a shell). About 8 lines, 1 file.
- Or intended: no; the menu row promises one round at a time for both revolvers (MENUDEF.rsq:86-87).
- Already known?: no.

## B6.3: Leaving a map loses the round sitting in the open under-barrel tube, and a loaded RSQ Grenade round turns into a plain one
- Kind: wrong behaviour
- Where: src/zscript/rsr/rsr_m203.zs:229-230 (comment "kept over a gun switch and a new map"), :263-273, :866-875,
  :921-924, :961; src/MAPINFO.rsvr:5
- What the code does: `RSK_M203Handler` is a plain `EventHandler` (added with `AddEventHandlers`), so a new one is made
  for every map and its `st[]` starts empty. `WorldLoaded` refunds from `st[n]`, which is null on a new map
  (rsr_m203.zs:870). `loadedNade` (the kind of the round in the shut launcher) lives in the same object; on the new
  map it is 0 and `Sync(mo, 'RSM_KindLoaded', false)` takes the token (:961).
- Why it is wrong: (a) a round pushed home in the open tube was paid for (:553-555) and is neither given back nor
  loaded when the map ends; (b) a charm, freeze, smoke... grenade loaded in the launcher (`RFGLoaded` is inventory and
  does travel) fires as Brutal Doom's plain 40 mm after a map change, though it cost one RSQ Grenade grenade. The same
  holds for the off-hand rifle (`loadedNadeOff`). The refund in `WorldLoaded` only ever fires for a loaded savegame or
  a hub map visited again.
- Checked: no `WorldUnloaded` in the file; MAPINFO.rsvr:5 registers it as a per-map handler; nothing else stores the kind.
- Sure?: certain that per-map handlers start fresh; not run.
- Fix A: keep both in the inventory, which travels: carry the kind as the amount of `RSM_KindLoaded` /
  `RSM_KindLoadedOff` (MaxAmount 16, amount 1 + kind; the weapons only test `>= 1`), and do the refund in
  `WorldUnloaded` (or give `RFGLoaded` there when the round is home). About 20 lines, 1 file.
- Or intended: no; the owner's answer to RL1 was "Give it back", map change included.
- Already known?: partly. RL1, owner said: "Give it back. Changed in 2.0.5n (code only, not run)". The 2.0.5n change
  does not cover a map change; the lost grenade kind is new.

## B6.4: BD22's Revolver in "one round at a time" cannot be pushed shut with the off hand, only flicked
- Kind: wrong behaviour
- Where: src/zscript/rsr/rsb_guns.zs:1117-1133; src/zscript/rsr/rsr_break.zs:959-964
- What the code does: `PushEdge` holds six rows and returns -999 for any index outside 1..6, except 10 and 11 which it
  maps to row 5. The per-round Revolver is row 7. `PushTick` gives up when the edge is below -900.
- Why it is wrong: the speedloader Revolver (row 3) has its edge row; the same cylinder on row 7 has none, so the hand
  on the open cylinder never closes it. Every other number of row 7 is a copy of row 3.
- Checked: rows 7 in `PushRef`, `PushZ0/1`, `PushR0/1` exist (rsb_guns.zs:1031, 1050, 1069, 1088, 1107).
- Sure?: certain from the code.
- Fix A: in `PushEdge`, add `if (i == 7) i = 3;` beside the 10/11 line (1 line).
- Or intended: no.
- Already known?: no.

## B6.5: The pump shotgun sometimes pumps itself and sometimes waits for the hand, depending on how long the trigger stayed down
- Kind: wrong behaviour
- Where: src/zscript/rsr/rsr_pump.zs:872 (and the comment at :698-705); src/actors/Weapons/Shotgun.dec:127-143
- What the code does: after a shot with the hand not on the pump, the gun waits for the hand (`waitHand`), and "fire"
  ends the wait with Brutal Doom's own pump. The test is `mo.player.cmd.buttons & BT_ATTACK`: the trigger being DOWN,
  not a new press.
- Why it is wrong: if the trigger from the shot itself is still held when the gun reaches `RSP_P1` (a few tics after
  the shot), the first `RSP_PTick` sees it and runs the automatic pump at once; if the player let go a moment sooner,
  the gun waits. The same pull gives two behaviours.
- Checked: `trigPrev` in the same class tracks the OFF trigger only; nothing remembers the main trigger.
- Sure?: likely (the code is plain; how often the trigger is still down at `RSP_P1` needs a headset).
- Fix A: keep `atkPrev` in `RSP_State`, set it in `BeginPump` to the trigger's state, and require `down && !atkPrev`
  at :872 (about 5 lines).
- Or intended: yes if "hold the trigger = pump for me" is the wanted rule; then the comment at :874 should say so.
- Already known?: no.

## B6.6: The off-hand reload button does not start the shotgun's hand insert; the mask reads the scoreboard button instead
- Kind: key
- Where: src/zscript/rsr/rsr_pump.zs:361; compare src/zscript/rsr/vreload.zs:1228, src/zscript/rsr/rsr_break.zs:1470,
  src/zscript/rsq/flick.zs:53
- What the code does: `InsertWanted` reads `BT_RELOAD | (1 << 20)`. The magazine guns and the break-open guns read the
  `rsr_magrelease` cvar (default 268435456 = bit 28, BT_OFFHANDRELOAD); flick.zs uses
  `BT_RELOAD | BT_MAINHANDRELOAD | BT_OFFHANDRELOAD`.
- Why it is wrong: bit 20 is BT_SHOWSCORES in GZDoom's button list, not a reload button, and `rsr_magrelease` is not
  read here, so the off hand's reload button opens a magazine gun or a break-open gun but does nothing on the pump
  shotgun. The shotgun is in neither `RSR_Guns` nor `RSB_Guns`, so `MagRelease` and `Lever` skip it too.
- Checked: grep for `1 << 20` and `1048576` in src/zscript: this is the only use; no comment explains it.
- Sure?: likely. QuestZDoom's own button constants are not in the repo; its `BT_` list settles what bit 20 is.
- Fix A: read `RSR.PlayerInt(mo.player, 'rsr_magrelease', 1 << 28) | BT_RELOAD` (1 line).
- Or intended: only if bit 20 is a QuestZDoom reload button I could not see.
- Already known?: no.

## B6.7: Holding the pump shotgun runs a search through every class in the game each tic
- Kind: performance
- Where: src/zscript/rsr/rsr_pump.zs:1259-1261 -> :568-593 -> src/zscript/rsr/vreload.zs:99-108
- What the code does: `RSP_Handler.WorldTick` works out `feedOK` every tic for a player holding `Shot_Gun` with room in
  the tube, shells in reserve and an empty hand. That calls `CanTakeShell(mo, true)`, which calls `RSR.RigPouch`, which
  calls `ServiceIterator.Find("RSQTR_RigService")` (with `rsr_rig_pouch` at its default 1).
- Why it is wrong: on the GZDoom 4.x base, `ServiceIterator.Find` makes a new object and walks `AllClasses` comparing
  lower-cased names in the VM; Brutal Doom plus this pack is several thousand classes. Without the rig loaded nothing
  is found, so the whole list is walked, 35 times a second, on a Quest. With the rig loaded each call also makes a new
  Service object.
- Checked: the other `RigPouch` callers run on a grab press only (vreload.zs:371, rsr_break.zs:496, rsr_m203.zs:486).
  The engine's `service.zs` is not in the repo.
- Sure?: likely; the 17.3 engine's `service.zs` settles the cost.
- Fix A: find the service once and keep it (a `Service` field on `RSR_ReloadHandler`, looked up in `OnRegister` /
  `WorldLoaded`), and have `RigPouch` use it (about 10 lines, 1 file).
- Fix B: in `WorldTick`, do the cheap tests of `feedOK` first and only ask the pouch when the Use key is the grab
  (`RSR.GrabWith == 2`), since `feedOK` is only read for the Use key (vreload.zs:1389).
- Or intended: no.
- Already known?: no.

## B6.8: A drum or canister that still holds rounds cannot be put back once the shared reserve is at zero
- Kind: wrong behaviour
- Where: src/zscript/rsr/vreload.zs:350-370; src/zscript/rsq/counters.zs:283-284, :307
- What the code does: `CanTakeMag` refuses when the reserve item is at 0 and `RSR_Held_<gun>` is 0. For the nine
  real-magazine guns the rounds of a magazine that is out stay in `RSQ_Mag_<gun>`, not in `RSR_Held_<gun>`, and while
  it is out nothing is lent, so the reserve item's count is the pouch alone.
- Why it is wrong: take the drum off an MG42 with 60 rounds in it, switch to the Rifle (same `Clip2`), spend the
  `Clip2`, come back: the reload starts (MG42.dec:22), the gun waits in `RSR_Wait`, and every grab is refused ("no
  magazine to take, reserve Clip2 is empty"), though the drum on the floor had 60 rounds. The gun cannot fire until
  `Clip2` is found. The same for the Machinegun (Clip2) and, with less chance, the others.
- Checked: `HeldRounds` only counts `RSR_Held_<ReadyWeapon>`; `RSR_Guns.MagAmmo` rows 10-18 are the `RSQ_Mag_*` items.
- Sure?: likely (the path is plain; it needs the reserve to reach 0 while the magazine is out).
- Fix A: in `CanTakeMag`, also let it through when `RSR_Guns.NoMag(i)` is held and `CountInv(RSR_Guns.MagAmmo(i)) > 0`
  for rows 10-18 (about 4 lines).
- Or intended: no.
- Already known?: no.

## B6.9: Pulling the empty open launcher tube shut by its front end with the off trigger takes a round out of the air instead
- Kind: wrong behaviour
- Where: src/zscript/rsr/rsr_m203.zs:386-402 and :461-503
- What the code does: with the tube open, a hand within 9 cm of it holding the off trigger takes the tube (:389). In
  the same tic the round code runs: any new grab press while the tube is open, no round in it and ammo in reserve
  puts a round in the hand if the palm is 20 cm or more from the breech (:489). With "Grab Ammo With: Trigger" (the
  default) the trigger press is that grab. A round in the hand makes `wants` false on the next tic (:389 needs
  `hand == EMPTY`), so the tube is let go.
- Why it is wrong: the open tube runs from about 39 to 60 cm forward and the breech point is at about 34 cm, so a
  hand on the front 6 cm of the tube (or just ahead of it) is 20 cm from the breech: the trigger there produces a round
  in the hand and drops the tube. Nearer the breech it works.
- Checked: numbers from rsr_m203_geo.zs:8-11 (FRAME_FRONT 28.68, TUBE_REAR 28.44, TUBE_FRONT 49.2, TRAVEL 11). Not an
  issue with the rig's pouch (`rp == 0` breaks first) or with "Magazine From: Low".
- Sure?: likely; a headset settles how often the hand lands there.
- Fix A: at :463 add `|| onTube` to the early `break` (a press on the tube is the tube's), 1 line.
- Or intended: no.
- Already known?: no.

## B6.10: Putting a gun in the off hand while the launcher tube is open hides the open tube; a reload gesture then pays for a second round
- Kind: wrong behaviour
- Where: src/zscript/rsr/rsr_m203.zs:946-959, :171-199, :596-600
- What the code does: when `active` goes false (a gun in the off hand, VR Reloading off) only `held` and `hand` are
  cleared; `pull`, `isOpen` and `roundIn` stay. `Draw` shows the tube only while `active`. `FlickLoad` for the main
  hand takes the open-tube path only when `s.active` (:176); otherwise it takes a round from the reserve and gives
  `RFGLoaded`.
- Why it is wrong: the rifle looks shut but is still "open" with a paid round in it. A gesture or the reload button
  then pays for another round. When the off hand is empty again the tube shows open; shutting it gives `RFGLoaded`
  again (already held, MaxAmount 1) and the first round is gone.
- Checked: `Refund` runs on death, gun change and (for a savegame) map load only.
- Sure?: likely.
- Fix A: when `active` goes false with `isOpen`, call `FlickShut`-like code without sound: if `roundIn`, give
  `RFGLoaded` and set `loadedNade`; then `Reset()` (about 8 lines).
- Or intended: no.
- Already known?: no (near RL1).

## B6.11: After loading a save made in the middle of a magazine change, the gun sits without its magazine and nothing takes the hand reload up again
- Kind: wrong behaviour
- Where: src/zscript/rsr/vreload.zs:1184-1192, :903-907, :1262-1274
- What the code does: `WorldLoaded` ends the saved reload quietly; the weapon, still in `RSR_Wait`, gets `RSR_Done`
  from `RSR_Tick` and goes to Ready with its `HasUnloaded*` / `RSQ_NoMag_*` token. `Resume` would restart it, but
  `resumeWeap` and `resumeDone` were saved with the game, and `resumeDone` was set true the moment the reload ran (:1272).
- Why it is wrong: the 2.0.2 rule ("a gun put away without its magazine takes the hand reload back up") does not fire
  after a load: the gun shows its empty well and the player must press reload, or pull the trigger on a gun that still
  has a chambered round first. For the real-magazine guns the trigger does nothing until reload is pressed.
- Checked: `End()` does not touch `resumeDone`.
- Sure?: likely; a save and load in `RSR_Wait` settles it.
- Fix A: in `End()` (or in `WorldLoaded`) set `resumeDone = false; resumeTries = 0;` (2 lines).
- Or intended: no.
- Already known?: no.

## B6.12: A pistol or SMG reloaded from empty can skip its rack: switch away at the slide and switch back
- Kind: wrong behaviour
- Where: src/actors/Weapons/Pistol.dec:31-33, :64-66, :91-93; SubMachinegun.dec:29-31, :62-64; src/zscript/rsr/vreload.zs:926-929
- What the code does: the magazine is filled when it is seated (`RSR_FillA`), then `RSR_Charge` asks for the slide.
  If the player switches weapons there, the rounds are already in the gun and nothing in Brutal Doom's own states
  reads `RSR_Charge`.
- Why it is wrong: the gun comes back up loaded and fires without ever being racked. The token stays, so the next
  reload press goes straight to the slide (a rack with no magazine change, Pistol.dec:33) and only the press after
  that changes the magazine.
- Checked: the Rifle, MP40, ASG and Sniper use Brutal Doom's own tokens, which its select states handle
  (Rifle.dec:177 `SelectRechamber`).
- Sure?: certain from the code; a small thing.
- Fix A: in the Pistol's and SMG's `Fire`, send a gun holding `RSR_Charge` (and `RSM_VR`/in VR) to `Reload` instead of
  firing, or leave the slide locked (`slideLock`) while `RSR_Charge` is held. A few lines per gun.
- Or intended: possibly: the comment says the token is "kept when the gun is put away, so the next reload goes
  straight to the handle".
- Already known?: no.

## B6.13: A one-tic race leaves the shotgun's "ready" token behind; the next shot then needs no pump at all
- Kind: wrong behaviour
- Where: src/zscript/rsr/rsr_pump.zs:887-892, :905-916; src/actors/Weapons/Shotgun.dec:137-143 (and 190-196, 237-243)
- What the code does: `PumpTick` gives `RSP_Ready` and ends the stroke in one call. The weapon's wait state tests
  `RSP_ShellIn` and `RSP_Insert` before `RSP_Auto` and `RSP_Ready`. `End()` / `Abort()` take no tokens (the break-open
  code does: rsr_break.zs:1071-1074).
- Why it is wrong: if a shell credit or a reload press arrives on the very tic the stroke is declared ready, the
  weapon leaves through `RSP_P1Feed` or `RSP_VRIns` and `RSP_Ready` stays in the inventory. The next time the gun
  waits for a pump, it finds `RSP_Ready` at once and goes on as if pumped.
- Checked: order of the tests in all three wait states.
- Sure?: unsure how often (a one-tic window); certain the token is never cleaned.
- Fix A: in `RSP_State.End()` take `RSP_Ready`, `RSP_Auto`, `RSP_Back`, `RSP_Fwd` when the weapon is no longer in a
  wait state, or take `RSP_Ready`/`RSP_Auto` in `BeginPump` (2 lines).
- Or intended: no.
- Already known?: no.

## B6.14: Closing a break-open gun with shells in the hand drops one shell of a pair, and an empty speedloader just vanishes
- Kind: wrong behaviour (cosmetic)
- Where: src/zscript/rsr/rsr_break.zs:993-1006, :1061-1068, :1078-1087
- What the code does: `StartClose` drops one round for `CARRY` and does not clear `pair`; it does nothing for
  `EMPTYLOADER` (the flick is allowed there, :703). `Abort` drops one round for a pair. `End` does not clear `pair`.
- Why it is wrong: two shells held, one falls; the Silvergun's empty cage disappears from the hand on a flick shut
  instead of falling as it does when let go (:848-857).
- Sure?: certain from the code; cosmetic.
- Fix A: in `StartClose`, drop the second shell when `pair`, clear `pair`, and drop frame 0 for `EMPTYLOADER`
  (about 8 lines).
- Or intended: no.
- Already known?: no.

## B6.15: After a menu is opened with the grip or Use held as the grab, the next grab press is lost
- Kind: key
- Where: src/zscript/rsr/vreload.zs:1344-1353, :1393-1405, :690-691
- What the code does: the key-up is not seen while a menu has the keys, so `netGrip` (or `netUse`) stays true. On the
  next key-down `down && !s.netGrip` is false, so `netPresses` does not go up and no new grab is made; the release then
  clears it and the press after that works. `End()` clears both, but only when a reload ends.
- Why it is wrong: with "Grab Ammo With: Grip" or "Use Key", one press does nothing after a menu, and a magazine or
  round in the hand stays held until then.
- Sure?: likely; mends itself on the next press and release.
- Fix A: in `InputProcess`... not reachable from a menu; instead clear `netGrip`, `gripFree`, `netUse` in play code
  when `menuactive` was seen (a `UiTick` that sends `rsr_grip 0` / `rsr_use 0` once when a menu opens). About 10 lines.
- Or intended: no.
- Already known?: no (the comment at :691 covers the reload's end only).

## B6.16: Local settings are read in play code (two players would disagree)
- Kind: netplay
- Where: src/zscript/rsr/rsr_pump.zs:82-86 with :502 (`rsr_sideport`, a `user` cvar read with `CVar.FindCVar`);
  src/zscript/rsr/vreload.zs:145, :269; src/zscript/rsr/rsr_break.zs:313, :387; src/zscript/rsr/rsr_pump.zs:101-105
  (`vr_two_handed_weapons`, `vr_vunits_per_meter`)
- What the code does: these read the local machine's value for whichever player is being ticked.
- Why it is wrong: in a net game each machine would use its own value for every player (a desync); `rsr_sideport` of
  another player is never used.
- Sure?: certain from the code; only matters in multiplayer.
- Fix A: `rsr_sideport` through `RSR.PlayerInt(who, 'rsr_sideport', 1)` (2 lines). The two `vr_` cvars are the
  engine's and have no per-player copy: intended unless the pack ever syncs them.
- Or intended: yes for single player.
- Already known?: no.

## B6.17: Options with no menu row (console only in a headset)
- Kind: setting or menu
- Where: src/CVARINFO.rsb:3 (`rsb_flick_speed`); src/CVARINFO.rsr:2-4, :7 (`rsr_grip_keys`, `rsr_grab_buttons`,
  `rsr_magrelease`, `rsr_eat_grip`), :35 (`rsa_rl_lock_cone`); src/CVARINFO.rsb:29 (`rsg_rsq_nade`)
- What the code does: all are defined once and read by code; none has a row in src/MENUDEF.rsq.
- Why it is wrong: the pack's own comment (CVARINFO.rsr:15-17) says a console command is no use with a headset on.
  Every other cvar of the two files is defined once, is read, and its menu range matches the code's clamp
  (`rsr_assist` 0.5-3.0, `rsr_shell_credit` 1-4); defaults match the fallbacks in code.
- Sure?: certain.
- Fix A: rows for the ones a player may want (`rsb_flick_speed` slider, `rsr_eat_grip`), or leave as is.
- Or intended: `rsb_flick_speed`: intended, see below. The key and button masks: intended as expert settings.
- Already known?: yes for two. Q3, owner said: "recoil, ssg, and shotgun side load, not the flick": the flick-shut
  speed stays console only. RL7, owner said: "Remove this row" (`rsg_rsq_nade`). The others: no.

## B6.18: Code and table rows that nothing reaches
- Kind: dead code
- Where: src/zscript/rsr/vreload.zs:695-735 with :481 (`AutoStep`, `autoDone`); :969-982 and :1018-1056 with :414
  (`RSR_DroppedMag.Label`, `noAmmo`, `RSR_MagLabel`: `Label()` is never called, and MODELDEF.rsr:1990-1992 says "No
  floating label"); src/zscript/rsr/rsr_guns.bd.zs:943-946 (`HandleFrame` always 0); src/zscript/rsr/rsb_guns.zs rows
  4, 5, 6 (`VR_SuperShotgun`, `VR_Revolver`, `VR_Revolver2`), rows 8, 9 (retired), :1138-1139 (`RSB_Held_VR_*`);
  src/zscript/rsr/rsr_pump_guns.zs row 2 (`VR_Shotgun`); src/zscript/rsr/rsr_assist.zs:27-36 (the index list still says
  the magazine table is BD22 1..9; it is 1..18)
- What the code does: `autoDone` is only set by flick.zs:350-352 for a main gun while the off hand holds a gun, and
  then `Wanted` refuses the hand reload, so no reload is ever running to finish. The `VR_*` classes are the other
  weapon set's and are not in this repo; `Index()` can never return their rows.
- Why it is wrong: nothing a player sees; it misleads the next reader.
- Sure?: certain.
- Fix A: delete `Label`, `noAmmo`, `RSR_MagLabel`; leave the generated rows (the tables say "do not edit by hand").
- Or intended: the rows: yes (shared generator).
- Already known?: partly. RL9, owner said: "Clean it all. ... the unreachable reload code ... left in place (no compile
  check)". The label code and the table rows: no.

## Things that looked wrong and are not (so the next reader does not chase them)
- "The weapon stops ticking while it fills, so the handler aborts after 2 tics": no. Every `RSR_Fill`, `RSB_Eject`,
  `RSB_Load`, `RSB_TopUp` and `RSP_Shell` chain is 0-tic and ends back in the wait state in the same tic.
- Every wait state has a way out: `RSR_Wait` and `RSB_Wait` use `A_WeaponReady(WRF_NOBOB|WRF_NOFIRE)` (switching
  allowed); `RSP_LoadWait` allows fire, reload again, the pump and switching; the three pump waits allow switching and
  end on fire. Death, a switch and a weapon that stopped ticking are all caught by `gone` in each handler's `WorldTick`.
  A wait state with no reload behind it (savegame) is ended by `RSR_Tick` / `RSB_Tick` giving `*_Done`, `RSP_PTick`
  giving `RSP_Auto`, `RSP_LTick` starting a load.
- An off-hand twin (`RSQ_Off_*`) reaching `RSR_Start` / `RSB_Start` / `RSP_LoadStart` would read the MAIN hand's gun
  (`mo.player.ReadyWeapon`), but `Wanted` is false whenever the off hand is not `RSQ_Hands`, so all three refuse and
  the twin runs its stock reload.
- `ACTOR MiniGun` against `'Minigun'` in the tables: class names are not case sensitive.
- The inserted `RSR_Held_*` jump lines (Rifle.dec:795, Railgun.dec:616, Plasma.dec:651, RocketLauncher.dec:585): each
  offset was counted, they land where the next line's jump lands.
- Table rows against DECORATE: the 18 magazine rows, the 5 live break-open rows and the pump row name classes that
  exist, with the weapon's own `AmmoType1` as Reserve and `AmmoType2` (or `RSQ_Mag_*`) as the magazine; fill counts
  match (Rifle 30+1 of 31, Sniper 10+1 of 11, shotgun cap 9 = `ShotgunAmmo` 9). The off-hand twins' magazines
  (`*AmmoOff`: 16, 41, 32, 31, 50, 9, 2, 20, 5, 6, 200) agree with these where the main one is in the repo.
- `RSB_PartStates` shows sprite `RBSP`, which has no model: `SetPart` overwrites the sprite before it is drawn.
- Division by a `Scale(0)` of zero in `DeskShift`: only with the test cvar `rsr_test_offdraw`, which is not defined.
- `rsr_test_offdraw`, `rsp_test_steady`, `rsp_test_trigger` are not in any CVARINFO: test pack only, `FindCVar` null = off.
- Railgun with 1-9 cells: the magazine cannot be taken for nothing, the gun's own gate (Railgun.dec:617) needs 10.

## Not read or not checkable
- Base Brutal Doom (brutal22test6.pk3) is not in the repo: `BrutalWeapon`, its ACS (the `Reloading`, `Kicking`,
  `Pumping`, `FiredSecondary` tokens), most main-hand magazine ammo actors (`BDPistolAmmo`, `BDSMGAmmo`, `MP40Ammo`,
  `PlasmaAmmo`, `RailgunAmmo`, `SSGAmmo`, `GLAmmo`) and most sounds named in the tables (`Rifle/Reload1`,
  `Sniper/MagOut`, `weapons/largemagdrop`...) could not be checked. The `rsr/*` sounds are in src/SNDINFO.rsr.
  Whether a kick, grenade or taunt key pressed during `RSR_Wait` / `RSB_Wait` (which do not test those tokens) fires
  late when the reload ends depends on that ACS.
- The QuestZDoom 17.3 engine is not in the repo: the `BT_` bit list (B6.6), `ServiceIterator` (B6.7), whether a
  layer whose caller is a plain Inventory may show a Weapon's state.
- Geometry numbers (wells, hooks, hand holds) cannot be judged by reading. One thing to look at in a headset: the
  off-hand push band of rows 3/7 and 10/11 (`PushRef`, `PushZ*`, `PushEdge`, rsb_guns.zs:1027-1035, 1130-1131) was not
  re-expressed when "batch 4" moved those guns' hinge and axis, while rows 1 and 2 were; the push may be about 10
  degrees off on both revolvers.
- Left-handed play: these files never read `vr_control_scheme`; they rely on `RSVR_VRHand` giving mirrored frames
  (vreload.zs:251-252). Not checked here (vrhand.zs is another part).
- The weapon files and DECORATE.rsqdual were read only around their reload states, not whole.
