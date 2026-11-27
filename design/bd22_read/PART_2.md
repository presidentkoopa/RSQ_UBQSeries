# BD22 VR Reloaded bug read, part 2: weapons B (2026-11-27)
Commit read: edfaf63 (VERSION 2.0.6b). Nothing was run. Nothing was changed.

Paths are relative to the repo root. "Base" means Brutal Doom's brutal22test6.pk3, which is not in the repo: `BrutalWeapon`
and its shared states (`NoAmmo`, `DoKick`, `Taunt`, `Salute`, `TossGrenade`, `StopSprintTired`, `DeselectInstant`, the
`Purist*` states), its ACS (`GetCrosshair`, scripts 852 / 853) and the tokens it hands out (`FiredPrimary`,
`FiredSecondary`, `Reloading`, `IsRunning`, `NoReloading`, `NoAutoReload`, `AimMode_*`) could not be seen. Where a finding
leans on one of them it says so. The engine (QuestZDoom 17.3) is not in the repo either; where a finding leans on how it
treats the off-hand weapon it says so.

## Files read
| file (src/actors/Weapons/) | lines | read to the end? |
|---|---|---|
| Mp40.dec | 1-663 | yes |
| SubMachinegun.dec | 1-648 | yes |
| Pistol.dec | 1-633 | yes |
| Minigun.dec | 1-621 | yes |
| SSG.dec | 1-597 | yes |
| Revolver.dec | 1-539 | yes |
| BFG.dec | 1-521 | yes |
| DualPistol.dec | 1-490 | yes |
| NukeLauncher.dec | 1-478 | yes |
| GrenadeLaunch.dec | 1-456 | yes |
| DualPlasma.dec | 1-406 | yes |
| DUalRifle.dec | 1-401 | yes |
| Flamethrower.dec | 1-371 | yes |
| BrutalRevolver.dec (with its off-hand twin, 253-364) | 1-364 | yes |
| Grenades.dec | 1-353 | yes |
| IncendiaryLauncher.dec | 1-335 | yes |
| HellishMissile.dec | 1-335 | yes |
| Unmaker.dec | 1-330 | yes |
| Machinegun.dec | 1-325 | yes |
| Dragonslayer.dec | 1-322 | yes |
| FlameCannon.dec | 1-287 | yes |
| MG42.dec | 1-244 | yes |
| Devastator.dec | 1-226 | yes |

23 files, 9,945 lines, each read whole with the Read tool. `git ls-files src/actors/Weapons` lists 33 files; the ten that are
not mine are the ten named in my prompt.

Read outside the part, to confirm or kill a suspicion:
- `src/zscript/rsq/counters.zs` 1-465 (whole): the magazines of the nine guns Brutal Doom never reloads.
- `src/zscript/rsr/vreload.zs` 60-211, 415-470, 845-931, 1058-1180, 1244-1300 (`RSR_Start`, `Wanted`, `WantsHands`, `Resume`).
- `src/zscript/rsq/semiauto.zs`, `alts.zs`, `dualtable.zs` (whole); `dual.zs` 420-470; `hands.zs` 308-351; `roster.zs` 22-48;
  `rsr_break.zs` 485-500, 855-880, 1030-1056, 1140-1170; `rsr_m203.zs` 905-937; `flick.zs` and `grenade.zs` by search.
- The off-hand twins. `src/DECORATE.rsqdual`: RSQ_Off_BrutalPistol (15-642), RSQ_Off_Revolver (652-1186),
  RSQ_Off_BrutalSMG (1196-1833), RSQ_Off_MP40 (1843-2508), RSQ_Off_SSG (5281-5878). `src/DECORATE.rsqdualmg`:
  RSQ_Off_Minigun (whole, 567 lines). Each was compared with its gun by a line diff after putting the magazine names back
  (`diff -b`, done in /tmp, the repo untouched); every difference the diff showed is accounted for below. Only seven of my
  guns have a twin (`src/zscript/rsq/dualtable.zs:8`): Pistol, Revolver, SMG, MP40, SSG, Minigun, BrutalRevolver. The other
  sixteen files have none.
- `tools/dual_minigun/gen_off_minigun.py` 1-30, 85-100 (not shipped; read only to see why the off Minigun is as it is).
- `CHANGELOG.md` by search; `BUGS_FROM_CODE_READ_2026-11-24.md` whole, after my own read.

## Findings, worst first

## B2.1: The game locks up for good when the Flamethrower's canister runs dry while the other hand holds a gun or an item
- Kind: crash or abort
- Where: `src/actors/Weapons/Flamethrower.dec:93-97` (Ready), `:25-30` (Reload), `:31-35` (RSR_Start), `:199-201`, `:204-206`
  (Fire, Hold); `src/zscript/rsr/vreload.zs:864-886` (RSR_Start), `:1086-1101` (Wanted, WantsHands);
  `src/zscript/rsq/counters.zs:231`, `:308-310`
- What the code does: Ready is five states of 0 tics; the fifth (`:97`) jumps to Reload when `RSQ_Empty_Flamethrower2` is
  held. Reload (`:26-30`, all 0 tics) goes to RSR_Start when there are rounds in the pouch or the canister is out.
  RSR_Start (`:32-35`, all 0 tics) gives `RSR_Start`; if the script does not answer with `RSR_Go` it does `Goto Ready`.
  The script refuses whenever `Wanted()` is false, and `Wanted()` needs the off hand to be `RSQ_Hands`
  (`vreload.zs:1094`). The counter that sets `RSQ_Empty_Flamethrower2` does not ask `Wanted()`; it asks `WantsHands()`
  (`counters.zs:231`), which ignores the off hand. So with VR reloading on, a gun copy, the off-hand axe or an RSQ item
  in the off hand, and the canister at 0 with Gas left in the pouch: Ready -> Reload -> RSR_Start -> Ready, round and
  round, with no state that lasts a tic.
- Why it is wrong: a weapon layer that never reaches a state with a duration never returns; the engine stays inside it.
  The player sees the picture freeze the moment the canister empties (or the moment they pick up Gas with an empty canister).
  The Minigun had the same `Goto Ready` and got `RSQ_StockFill` in 2.0.5e (`Minigun.dec:35-44`); the Flamethrower did not,
  and it is the only one of the nine guns whose Ready reads the empty token before any tic passes.
- Checked: `counters.zs:283-310` (Empty is given when the magazine is 0 and the pouch is above 0, or the canister is out;
  the Gas item then holds only the pouch, so `A_JumpIfNoAmmo` at `:96` does not catch it); `hands.zs:325-350` (since 2.0.3y
  an off-hand gun copy is never "stale" and stays until the player moves it); `flick.zs:437-446` (the gesture and the
  Reload button also send the main gun to this same Reload, so they do not break the loop, they start it).
  Not seen: QuestZDoom's own layer code. Stock GZDoom's `DPSprite::SetState` loops `while (!Tics)` with no counter.
- Sure?: likely. The loop in the files is certain. What would settle it: headset or rig, `rsr_reload 1`, an off-hand pistol,
  hold the Flamethrower's trigger until its 100 are gone.
- Fix A: in `Flamethrower.dec` replace the `Goto Ready` at `:35` with the Minigun's `RSQ_StockFill` block
  (`Minigun.dec:36-44`, with `RSQ_NoMag_Flamethrower2` / `RSQ_Fill_Flamethrower2` and the Flamethrower's own sounds). It has
  two 8-tic states, so the loop cannot form, and the canister tops up. About 9 lines, 1 file.
- Fix B: also move `:97` to just after the 1-tic state at `:100`, so Ready can never reach Reload without a tic passing.
  1 line moved, same file. Fix A alone is enough; B is a second lock on the door.
- Or intended: no.
- Already known?: no

## B2.2: With a gun or an RSQ item in the off hand, seven guns can never be reloaded once their magazine is empty
- Kind: wrong behaviour
- Where: `MG42.dec:30`, `Machinegun.dec:41`, `Unmaker.dec:36`, `Devastator.dec:35`, `HellishMissile.dec:32`,
  `IncendiaryLauncher.dec:29`, `NukeLauncher.dec:34` (each: `Goto Ready` after a refused `RSR_Start`);
  `src/zscript/rsq/counters.zs:231` (the magazine is live on `WantsHands`), `src/zscript/rsr/vreload.zs:869-882` (refused
  on `Wanted`)
- What the code does: the same mismatch as B2.1. The magazine is live whenever VR reloading is on; the hand reload runs
  only with `RSQ_Hands` in the off hand. When it is refused these seven go back to Ready with the magazine still empty.
  Every trigger pull then goes Fire -> `RSQ_Empty_*` -> Reload -> refused -> Ready.
- Why it is wrong: the trigger, the Reload button, the flick and the off-screen gesture all end in that same refused Reload
  (`flick.zs:437-446`), so the gun is dead while the HUD still shows rounds in reserve. The player has to empty the off
  hand to get the gun back, and nothing tells them. The Minigun was given a fallback for exactly this in 2.0.5e
  (`Minigun.dec:35`: "a refused hand reload left the magazine empty").
- Checked: each file's Reload and RSR_Start; `counters.zs:222-314`; the Machinegun reaches RSR_Start through its own Reload
  (`Machinegun.dec:268-273`, `RSR_Box` at `:31-36`). Purist play with VR reloading on is refused the same way
  (`vreload.zs:1092`) if the purist holds the plain classes; I could not see which class a purist is given (base).
- Sure?: certain for the files. That these guns are used with something in the off hand is the owner's to say.
- Fix A: the Minigun's `RSQ_StockFill` block in each of the seven files, in place of `Goto Ready` (8 lines a file, 7 files;
  with B2.1 that is all eight).
- Fix B: make the magazine follow the hand reload: `counters.zs:231` (and `:49`) use `RSR_ReloadHandler.Wanted(mo)`. 2 lines,
  1 file; the guns are then Brutal Doom's own (no magazine) while the off hand is busy. The rounds move between magazine
  and reserve each time the off hand changes (`counters.zs:240-253`), which is why A is the cleaner one.
- Or intended: only if these seven are meant to need a free off hand; then the Reload button should say so.
- Already known?: no

## B2.3: The off-hand Minigun stops firing with rounds still in its magazine when the shared reserve reads 0
- Kind: wrong behaviour
- Where: `src/DECORATE.rsqdualmg:21-33` (RSQ_Off_Minigun: `Weapon.AmmoType1 "RSQ_MinigunAmmo"`, `Weapon.AmmoUse2 0`, and no
  `Weapon.AmmoUse1`), `src/actors/Weapons/Minigun.dec:7-8`, `:12` (`Weapon.AmmoUse 1`, `-WEAPON.AMMO_CHECKBOTH`, inherited)
- What the code does: the copy fires from its own magazine (`MinigunAmmoOff`, taken by hand before each shot,
  `DECORATE.rsqdualmg:290`), but it still inherits "primary fire needs 1 of ammo type 1", and its type 1 is the shared
  reserve item.
- Why it is wrong: the engine's own ammo check before Fire and inside `A_ReFire` reads the reserve item, not the copy's
  magazine. That item is the pouch plus at most 10 rounds lent by the main Minigun (`counters.zs:22`, `:284`). With the
  pouch empty and the main Minigun empty or not in hand it is 0, and the off Minigun will not start or keep firing however
  full its own 200 is. Every other copy inherits `AmmoUse` 0 from its gun, so none of them has this.
- Checked: all of `DECORATE.rsqdualmg`; no `AmmoUse` anywhere in `DECORATE.rsqdual`; the generator's header
  (`tools/dual_minigun/gen_off_minigun.py:8-11`) explains taking the round by hand and does not mention `AmmoUse1`.
  Not seen: how QuestZDoom checks ammo for the off-hand weapon. In stock GZDoom `FireWeapon` calls `CheckAmmo`, and a
  failed check also asks for a weapon switch.
- Sure?: likely. Settle it on the rig: main hand a pistol, off hand the Minigun copy with its magazine full,
  `RSQ_MinigunAmmo` at 0, pull the off trigger.
- Fix A: add `Weapon.AmmoUse1 0` to the copy's header in `gen_off_minigun.py` and regenerate (1 line, then the generated
  file). Its own states already read `MinigunAmmoOff` for every empty check (`DECORATE.rsqdualmg:238`, `:250`, `:280`...).
- Or intended: no.
- Already known?: no

## B2.4: Two Shotvolvers get in each other's way: one reloading or cocking stops the other's shot
- Kind: wrong behaviour
- Where: `src/actors/Weapons/Revolver.dec:238`, `:243`, `:281`, `:291`, `:410`, `:441`; the same lines in the copy,
  `src/DECORATE.rsqdual` RSQ_Off_Revolver (652-1186; the diff shows them unchanged)
- What the code does: `RevolverIsReloading`, `NeedToHammer` and `HasUnloadedRevolver` are one item each on the player, read
  and written by both guns.
  1. The off gun's gesture or button reload runs Brutal Doom's own reload (`:403-436`; the hand reload is refused with a
     gun in the off hand), which holds `RevolverIsReloading` for the whole of it (`:410` to `:441`). The main gun's Fire
     reads it first (`:238`) and jumps to `FinishedInsertingShells`: 18 tics of the cylinder closing on a gun that never
     opened, no shot, and it takes the token away from the gun that is really reloading.
  2. Each shot gives `NeedToHammer` (`:281`) and takes it about 13 tics later (`:291`). In that time the other gun's Fire
     (`:243`) goes to Hammering instead of firing: 12 tics of cocking, then it fires only if its trigger is still down.
- Why it is wrong: firing left-right-left, the natural way to use two revolvers, keeps landing in each other's 13 tics, so
  the pair fires slower than one gun would suggest; and the main trigger is swallowed while the off gun reloads. The copy's
  own note at `DECORATE.rsqdual:940-943` records an earlier lock-up from this same shared token.
- Checked: the SMG's burst was given a counter per hand for this reason (`SubMachinegun.dec:391-407`, `RSA_BurstCnt` /
  `RSA_BurstCntOff`), and the slug has `RSA_Magnum` / `RSA_MagnumOff` (`Revolver.dec:216-219`); these three tokens have no
  off-hand form anywhere in `src`.
- Sure?: likely (read from the states; the tic counts are mine). Settle it on the rig with two Shotvolvers, alternating.
- Fix A: in RSQ_Off_Revolver use `NeedToHammerOff`, `RevolverIsReloadingOff`, `HasUnloadedRevolverOff` and define the three
  tokens. About 25 lines changed in `DECORATE.rsqdual`, by hand: `dualtable.zs:5` says gen_dual.py is not in this repo.
- Or intended: no.
- Already known?: no

## B2.5: The Nuke Launcher and the Machinegun play their shot when the magazine is empty and nothing leaves the barrel
- Kind: wrong behaviour
- Where: `src/actors/Weapons/NukeLauncher.dec:164-171`; `src/actors/Weapons/Machinegun.dec:211-217` and `:230-235`
- What the code does: both check `RSQ_Empty_*` after the sound. Nuke: `A_AlertMonsters`, the flash frame, "Rocket/Fire" and
  "brain/spit" at `:164-170`, the empty check at `:171`. Machinegun: "FARHMG" and "HMGFIRE" at `:211-212` (and `:230-231`
  for the second round of the pair), the check at `:217` (`:235`).
- Why it is wrong: in VR the player hears a nuke launch, or one more machine-gun round, sees the monsters wake, and then
  the gun asks for a reload. On the Machinegun it happens every time the box runs dry with the trigger held. The other
  seven check before they make a sound (for example `Minigun.dec:297`, `IncendiaryLauncher.dec:111`, `MG42.dec:114`,
  `Devastator.dec:172`, `HellishMissile.dec:169`, `Unmaker.dec:194`, `Flamethrower.dec:201`).
- Checked: `counters.zs:308-309` sets the token at the end of the tic of the last shot, so the next pull does see it.
- Sure?: certain.
- Fix A: move `NukeLauncher.dec:171` up to just after `:163`; move `Machinegun.dec:217` up to just after `:210` and `:235`
  to just after `:229`. 3 lines moved, 2 files.
- Or intended: no.
- Already known?: no

## B2.6: Two pistols on burst fire share one burst counter, so the bursts come out uneven
- Kind: wrong behaviour
- Where: `src/actors/Weapons/Pistol.dec:383`, `:388`, `:392`; the same lines in RSQ_Off_BrutalPistol
  (`src/DECORATE.rsqdual` 15-642)
- What the code does: each burst shot gives `BurstCounter`; at 3 the burst ends and the counter is emptied. Both hands add
  to the same item.
- Why it is wrong: fired together, the two guns reach 3 between them: one fires two rounds and the other one, then the
  first to finish empties the counter under the other. The pack's own SMG burst says "each hand counts its own"
  (`SubMachinegun.dec:391-392`).
- Checked: no `BurstCounterOff` in `src`. The burst switch itself (`PistolBurstFire`, `Pistol.dec:551-555`) is also shared, so
  either hand's secondary flips both guns; that may well be wanted.
- Sure?: likely.
- Fix A: `BurstCounterOff` in the copy (3 lines in `DECORATE.rsqdual`, 1 new token).
- Or intended: only the shared switch.
- Already known?: no

## B2.7: Two MP40s, and two Super Shotguns, share Brutal Doom's per-gun tokens
- Kind: wrong behaviour
- Where: MP40: `src/actors/Weapons/Mp40.dec:219`, `:244-246`, `:268`, `:286-292`, `:332`, `:449` and the same lines in
  RSQ_Off_MP40 (`src/DECORATE.rsqdual` 1843-2508). SSG: `SSG.dec:224`, `:324`, `:335`, `:378`, `:390-393`, `:458` and
  RSQ_Off_SSG (5281-5878)
- What the code does:
  - MP40: `Zoomed`, `ZoomHold`, `ADSmode` and `MP40ReloadToken` are single items. The off gun's secondary (aim) gives
    `Zoomed`; the main gun's Ready sees it (`:219`), walks into its own aim states, finds its own secondary up and leaves
    through NoAim (`:286-292`), which takes `Zoomed` and plays "ads/out". The off gun is still held in aim but its Fire
    (`:332`) no longer finds `Zoomed`, so it fires the hip shot (spread 3, `:366`) instead of the aimed one (1.5, `:397`).
    And a main reload asked for while the off gun is between `:474` and `:485` of its own reload goes to Fidget (`:449`).
  - SSG: `SSGAlt` (which barrel went) and `SSGLoaded` are single items. After the off gun fires one barrel, the main gun's
    first single-barrel shot takes the "second barrel" path (`:324` -> AltFire2) and ends in `NoAmmo` with a shell still
    in it (`:390-393`; dual wield forces `NoAutoReload`, `dual.zs:434-439`). After either gun reloads, the Reload key on
    the other, empty one does nothing (`:458`).
- Why it is wrong: one hand changes what the other gun does.
- Checked: the diffs show the copies differ from their guns only in the magazine name, the header, the muzzle-glow flag, one
  LegenDoom token and (SSG) its own flick reload. `rsr_break.zs:1032-1040` keeps `SSGAlt` / `SSGLoaded` right for one gun.
  Not seen: base `NoAmmo`, and who gives `AimMode_Toggle` / `AimMode_Hold`.
- Sure?: MP40 likely; SSG unsure (it ends in a base state). A rig trace of each would settle both.
- Fix A: off-hand names for these tokens in the two copies (MP40 about 30 lines, SSG about 20, by hand in `DECORATE.rsqdual`).
- Or intended: aiming with two MP40s may not be something anyone does; then leave the MP40 and fix only the SSG.
- Already known?: no

## B2.8: The off-hand Minigun's reload plays its belt sounds and loads nothing when the pouch is empty
- Kind: wrong behaviour
- Where: `src/DECORATE.rsqdualmg:40-50`; `src/zscript/rsq/counters.zs:369-372`
- What the code does: Reload starts when the reserve item is 1 or more (`:42`). The fill takes from the pouch, which is that
  item less the rounds lent to the main Minigun (`counters.zs:369`), and returns having done nothing when that is 0.
- Why it is wrong: with up to 10 lent rounds in the item and an empty pouch, each press or gesture gives two belt sounds and
  16 tics of a gun that will not fire, for no rounds.
- Checked: `RSQ_Lent_Minigun` is a real class (`counters.zs:435`), so the state can test it.
- Sure?: certain.
- Fix A: at `:42` jump on the pouch instead:
  `A_JumpIf(CountInv("RSQ_MinigunAmmo") - CountInv("RSQ_Lent_Minigun") > 0, "RSQ_OffFill")`, in the generator
  (`tools/dual_minigun/gen_off_minigun.py:51-54`). 1 line.
- Or intended: no.
- Already known?: no

## B2.9: The Unmaker answers the reload key up to three quarters of a second late
- Kind: wrong behaviour
- Where: `src/actors/Weapons/Unmaker.dec:85-107`
- What the code does: Ready is 13 states of 2 tics (26 tics a pass). The reload key's token is read once a pass, after the
  first five (`:86`).
- Why it is wrong: a press just after that line waits a whole pass. The other guns read it every 1 to 3 tics
  (`MG42.dec:91-92`, `Devastator.dec:96-97`, `Flamethrower.dec:100-101`).
- Checked: the token is taken only by Reload (`:26`), so the press is late, not lost. Not seen: the base script that gives it.
- Sure?: certain for the file; likely as something a player notices.
- Fix A: repeat line `:86` after `:93` and after `:100`. 2 lines.
- Or intended: no.
- Already known?: no

## B2.10: No sprint with the Silvergun in hand, or with a hand grenade held the VR way
- Kind: wrong behaviour
- Where: `src/actors/Weapons/BrutalRevolver.dec:101-111` (Ready), `:279-284` (the copy's Ready);
  `src/actors/Weapons/Grenades.dec:157-173` (RSG_Ready, RSG_Armed, RSG_Cooking, RSG_Check)
- What the code does: every Brutal Doom gun's Ready sends `IsRunning` to `StartSprint`, where ACS script 852 "makes player
  faster", and `StopSprint` runs 853. These Ready loops never read `IsRunning`.
- Why it is wrong: the comment at `DualPlasma.dec:105` says moving in VR is Brutal Doom's sprint. With the Silvergun (which
  can be the start gun, "Moonlight Replaces Pistol") the player would keep whatever speed the last gun left, and never gets
  the sprint.
- Checked: `Grenades.dec:76` does read it, but `:66` leaves for RSG_Ready first whenever `RSG_VR` is held.
  `IncendiaryLauncher.dec:75-81` and `Dragonslayer.dec:35-45`, both Brutal Doom's own, also have no sprint, so Brutal Doom
  lives with it on two guns. Not seen: scripts 852 / 853.
- Sure?: unsure. It rests on what 852 / 853 do. Settle it by walking with the Silvergun out and then with the pistol.
- Fix A: `RVMA A 0 A_JumpIfInventory("IsRunning",1,"StartSprint")` in BrutalRevolver's Ready, plus StartSprint / Sprinting /
  StopSprint states on RVMA frames (about 35 lines copied from `Pistol.dec:237-290`).
- Or intended: the Silvergun was written without a sprint on purpose; then nothing to do.
- Already known?: no

## B2.11: The Machinegun asks every tic for a script that this repo does not have
- Kind: missing asset or class
- Where: `src/actors/Weapons/Machinegun.dec:72`, `:102`, `:133`, `:214`, `:255`, `:286` (`ACS_NamedExecuteAlways("MGGrenadeCheck")`);
  `:198` (jump to state "Steady"); `:211-212`, `:230-231` (sounds "FARHMG", "HMGFIRE"); `:191` ("CHGNPKUP")
- What the code does: the gun is Brutal Doom 21's, carried into 22 (header, `:2-4`). The header lists the sounds that were
  renamed; it says nothing of the named script, the "Steady" state or these three sounds. None is defined in `src`
  (no ACS in the repo; no SNDINFO entry; no "Steady" in this actor).
- Why it is wrong: if brutal22test6 does not carry "MGGrenadeCheck", the engine prints "P_StartScript: Unknown script" once
  a tic for as long as the Machinegun is in hand (line `:72` is in Ready), which fills the console and costs time on a
  Quest. If the sounds are missing the gun fires silent.
- Checked: searched all of `src`, `tools` and `reference` for each name. Not seen: brutal22test6 (it may have all of them;
  the Minigun also plays "CHGNPKUP", `Minigun.dec:153`, which is Brutal Doom's own line).
- Sure?: unsure. Settle it with one look at the console with the Machinegun out, or a search of brutal22test6 for the names.
- Fix A: if the script is missing, delete the six lines (the launcher's state is tracked by `rsr_m203.zs` and the
  `FiredMGGrenade` / `RFGLoaded` tokens already). 6 lines.
- Or intended: fine as is if brutal22test6 has them.
- Already known?: no

## B2.12: The Minigun ammo box may be picked up without a sound
- Kind: missing asset or class
- Where: `src/actors/Weapons/Minigun.dec:610` (`Inventory.PickupSound "CBOXPICK"`, noted "BD22's bullet box sound")
- What the code does: the box uses "CBOXPICK". The Minigun itself, the off-hand Minigun and the Machinegun use "CBOXPKUP"
  (`Minigun.dec:14`, `DECORATE.rsqdualmg:35`, `Machinegun.dec:18`). "CBOXPICK" appears nowhere else in `src`.
- Why it is wrong: one of the two spellings may not exist; if it is this one, the box is silent.
- Checked: all of `src`. Not seen: brutal22test6's SNDINFO and its ClipBox2.
- Sure?: unsure. Settle it by looking up ClipBox2's pickup sound in brutal22test6.
- Fix A: use the name ClipBox2 uses. 1 line.
- Or intended: both names may exist in Brutal Doom.
- Already known?: no

## B2.13: The off-hand pistol and SMG copies have drifted from their guns' reload fixes
- Kind: drifted copy
- Where: `src/actors/Weapons/Pistol.dec:25-32`, `:460`; `SubMachinegun.dec:23-30`, `:66-73`, `:491`; `Mp40.dec:437`; against
  `src/DECORATE.rsqdual` RSQ_Off_BrutalPistol, RSQ_Off_BrutalSMG, RSQ_Off_MP40
- What the code does: the copies lack the 2026-10-23 fixes (an empty magazine is changed, not racked; no rack owed on a
  top-up: the off SMG's `RSR_FillB` still gives `RSR_Charge`) and the `RSR_Held_*` line in Reload.
- Why it is wrong: today nothing, because the copies never reach those states: with a copy in the off hand `RSR_Start` is
  refused (`vreload.zs:1094`) and they run Brutal Doom's reload. It turns into the old "no magazine is ever offered again"
  bug the day a copy is allowed a hand reload, or is held in the main hand. The file says "generated, do not edit by hand"
  (`DECORATE.rsqdual:1`) while `dualtable.zs:5` says the generator is not in this repo, so the copies cannot be made again
  from the guns.
- Checked: the full diff of each pair; `dual.zs` (a copy that reaches the main hand is swapped for its gun).
- Sure?: certain that they differ; harmless today.
- Fix A: delete the unreachable `RSR_*` states from the three copies (as the Minigun's generator does,
  `gen_off_minigun.py:13`), so there is nothing left to drift. About 80 lines a copy.
- Fix B: bring gen_dual.py into `tools/` and regenerate.
- Or intended: no.
- Already known?: no

## B2.14: On burst, the SMG fires one round a pull when Brutal Doom's "no reloading" play is on
- Kind: wrong behaviour
- Where: `src/actors/Weapons/SubMachinegun.dec:346-347`, `:361-364`, `:397`
- What the code does: with `IsPlayingAsPurist` or `NoReloading`, Fire spends the reserve (`Clip1`) and never touches the
  magazine. The burst only goes on while the magazine (`BDSMGAmmo`) has a round (`:397`).
- Why it is wrong: in that play the magazine is 0, so every burst is one round. Also, the burst count (`RSA_BurstCnt`) is
  reset only at the end of a burst (`:405`); a death in mid-burst leaves it at 1 or 2 and the next burst is short.
- Checked: `alts.zs` (the tokens are plain items; nothing else resets them). Not seen: what gives `NoReloading` (base).
- Sure?: likely.
- Fix A: at `:397` (and `:402` in the copy's branch) also go on when `NoReloading` or `IsPlayingAsPurist` is held and `Clip1`
  has a round; take both counters in Select. About 6 lines.
- Or intended: no.
- Already known?: no

## B2.15: Brutal Doom's own dual guns are shipped, patched for LegenDoom, and cannot be reached
- Kind: dead code
- Where: `src/actors/Weapons/DualPistol.dec`, `DUalRifle.dec`, `DualPlasma.dec` (whole files); the guns' jumps to them are
  switched off (`Pistol.dec:234`, `Mp40.dec:228`, `SubMachinegun.dec:182`, `FlameCannon.dec:75`: `A_JumpIf(0, "DualWield")`)
  and `dual.zs:447-451` takes the Dual key for the pack's own dual wield
- What the code does: no Ready loop allows the User3 state and none jumps to `DualWield` / `GetDual`, so `DualPistols`,
  `DualRifles`, `DualPlasmaRifles` can only arrive by a cheat or another mod. They carry LegenDoom jam lines
  (`DualPistol.dec:179-183`, `DUalRifle.dec:173-177`, `DualPlasma.dec:232-236`) and one 2.0.5g fix (`DualPlasma.dec:105`).
- Why it is wrong: three files kept up for guns nobody can hold. They also hold two of Brutal Doom's own slips that would
  show if the guns came back: `DualPlasma.dec:292` jumps to "ReloadDM", which does not exist (the state is `NoReloadDM`,
  `:297`); `DUalRifle.dec:206` and `:231` both define `SpriteVariant`, and if the later one wins, every second rifle shot
  uses the deathmatch puff.
- Checked: no `WRF_ALLOWUSER` anywhere in `src/actors/Weapons` or `src/DECORATE.*`. LD11 in the known-bugs file is about the
  same weapon from LegenDoom's side.
- Sure?: certain that the guns' own paths are closed; unsure which duplicate label the engine keeps.
- Fix A: leave the files alone and note in the README that these three are Brutal Doom's, unused. 1 line.
- Or intended: kept so LegenDoom's tables (`zscript/rsld/data.zs:20-25`) still find the class names.
- Already known?: partly. LD11, owner said: "dualweild seems like a pointless legendary in a vr game"; the Dual Pistols
  weapon stays put away. The two slips are not there.

## Things that looked wrong and are not (so the next reader does not chase them)
- `Pistol.dec:554` and `DualPistol.dec:318`, `Goto AltFire+8`, with a LegenDoom line added above: counted, both land on the
  ammo check as meant; the `+3` jumps at `Pistol.dec:551` and `DualPistol.dec:315` also land right.
- `Mp40.dec:387` and `SubMachinegun.dec:443`, `Goto Reload+6`: the added `RSR_Held_*` line is now state +6. It falls through
  to the reserve check that used to be +6, so nothing changed.
- `Mp40.dec:437`, `SubMachinegun.dec:491`, `Pistol.dec:460` ("jump 4, lands where the next line does"): counted, true in all three.
- `Flamethrower.dec:246` `Goto Ready+7`, `NukeLauncher.dec:146` / `:175`, `HellishMissile.dec:187` / `:199`,
  `Devastator.dec:187` / `:201` `Goto Ready+6`: counted against the added lines; all land where Brutal Doom's did.
- `SubMachinegun.dec:402` reads `BDSMGAmmoOff` in the main gun's file: that branch runs only on the off-hand layer, where the
  copy has the same line (`DECORATE.rsqdual:1589`). Right.
- SSG hand reload: `RSB_Load` (`SSG.dec:45-52`) does not give `SSGLoaded` or clear `SSGAlt`. The script does it at the shut
  (`rsr_break.zs:1032-1040`).
- `SSG.dec:48`, `GrenadeLaunch.dec:47`: the round is given without a reserve check. The script checks the reserve when the
  round is taken into the hand (`rsr_break.zs:485-494`).
- `Minigun.dec:254` / `:296`: HoldEmpty and Hold jump to each other with no tic between, but on opposite tests of the same
  item, so they cannot loop. The same in the copy (`DECORATE.rsqdualmg:238`, `:280`), which reads its own magazine in both.
- Minigun, MG42, Machinegun, Unmaker, Nuke, Incendiary, Hellish, Devastator: empty -> Reload -> Ready cannot lock up as the
  Flamethrower does; each has a state of at least 1 tic on the way round.
- `Revolver.dec:283` `+2` into Hammering: the 1.92 note at `:285-286` is right, and the copy has it (`DECORATE.rsqdual:940`).
- `Revolver.dec:292`: 32 is BT_ALTATTACK; 67108864 and 134217728 are the off-hand attack and alt attack bits used all
  through the pack.
- `MG42.dec:105-107`: Deselect ends in a 0-tic `A_Lower` and `Wait`. Brutal Doom's own; the 19 calls before it always
  finish the lowering.
- `IncendiaryLauncher.dec:96` `A_Lower` inside Select: Brutal Doom's own.
- `IncendiaryLauncher.dec:136` says 4 rockets: the carry is raised to 48 every tic and the cylinder is 6
  (`counters.zs:342-349`, `:13`).
- BrutalRevolver's frames RVMA B-Z and RVMB A-O have no sprite lumps (only `RVMAA0.png`): all 41 are model frames in
  `MODELDEF.rsqmoon` and `MODELDEF.rsqmoondual`.
- Every token name starting RS (88 of them) that my 23 files give, take or test is a class defined in `src` (checked by script).
- `rsb_revolver_feed` (`BrutalRevolver.dec:228`), `rsq_reload_nonstd`, `rsa_rev_slug`, `rsa_pistol_semi` are all in CVARINFO and
  each has a menu row.
- Comments only, no player sees them: the headers of MG42, Nuke, Incendiary, Hellish and Devastator still call the magazine
  "a COUNTER ... firing and the reserve are BD22's, untouched" (all nine are real magazines now, `counters.zs:19`);
  `BrutalRevolver.dec:1` says shown as "Revolver" (its Tag is "Silvergun", `:65`).

## Not read or not checkable
- brutal22test6.pk3 is not in the repo: nothing about `BrutalWeapon` or its shared states, ACS and tokens was checked.
  Findings B2.10, B2.11, B2.12 and half of B2.7 wait on it.
- QuestZDoom 17.3's source is not in the repo: how it fires, refires and ammo-checks the off-hand weapon (B2.3), and whether
  its weapon-layer loop has a guard against endless 0-tic states (B2.1), are read from stock GZDoom as I know it.
- `Flamethrower.dec:133-142` (ReadyDry) reads neither the reload key nor the empty token. With the canister left out and no
  Gas in the pouch the gun sits there; `vreload.zs:1257-1300` (Resume) may pick it up, depending on whether frame Q counts
  as a ready frame. I did not follow that table.
- `GrenadeLaunch.dec:228`, `:243`, `:269` give and take `FiredSecondary`, which the other guns treat as "the secondary is
  held". Whether a leftover one turns the next primary shot into the alt grenade depends on the base script that owns it.
- The six twin diffs compare states and properties. I did not compare each copy's MODELDEF blocks with its gun's.
