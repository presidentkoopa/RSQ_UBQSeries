# BD22 VR Reloaded: every weapon, every input, and what Gun Cards shows on it

Written 2026-11-27 from a code read. **Nothing was run**: no build, no game, no rig, no headset. Every line below is
what the code says, not what was seen.

| Repo | Path | Commit read |
|---|---|---|
| A, the weapon set ("BD22 VR Reloaded") | `/home/claude/presidentkoopa/rsq_bd_vr_reloaded` (only `src/`) | `edfaf63` |
| B, the series (only `GunCards/`) | `/home/claude/rsq_ubqseries` | `0a3ffa48a` when the read began; `e49910d92` when it ended, plus uncommitted changes (see below) |

**Repo B moved during the read.** Other work committed to it and left `GunCards/zscript/rsqgc/card.zs`,
`gestcopy.zs`, `GunCards/CVARINFO.txt` and `GunCards/MENUDEF.txt` changed and not committed (the watch check and a new
pulse check, read by Gun Cards itself). The rules of Part 2 were read before that and then checked again, line by line,
against the working tree as it stood at the end (`e49910d92` plus those changes): the rules are the same, and every
`card.zs` line number below is the working tree's. `GunCards/README.md` says it was written from `e2b60912e` and is
older than both.

Paths in Part 1 are under Repo A `src/`. Paths that start `card.zs`, `modelcard.zs`, `items.zs`, `side.zs`, `spots.zs`
are under Repo B `GunCards/zscript/rsqgc/`.

## What could not be read

- **Base Brutal Doom (brutal22test6.pk3) is not in Repo A.** So these are not visible: the fists weapon
  `Melee_Attacks` (named, never defined, in src: `zscript/rsq/fists.zs:257`), `BFG10k` (named in `RSQGCOFF.rsq:41`,
  never defined in src), Brutal Doom's KEYCONF (its keys, aliases and binds), its ACS, its LANGUAGE lump (so a Tag
  written `$TAGBD_...` is given here as written, not as the words the player sees), and every ammo class that src
  names but does not define (`Clip1`, `Clip2`, `AmmoShell`, `AmmoRocket`, `AmmoCell`, `Gas`, `BDPistolAmmo`,
  `BDSMGAmmo`, `MP40Ammo`, `Mauser9mm`, `PlasmaAmmo`, `RailgunAmmo`, `SSGAmmo`, `GLAmmo`, `SniperAmmo`, `SoulAmmo`,
  `DevastatorAmmo`, `Nuke`, `MiniHellRocketAmmo`, `GrenadeAmmo`, `BDDualPistolAmmo`, `DoubleRifleAmmo`,
  `DoublePlasmaAmmo`).
- **The engine (QuestZDoom) is in neither repo.** Three things below rest on it and are marked: that a weapon's
  `Ammo1` pointer exists whenever the weapon declares an AmmoType1; what `A_WeaponReady` lets through; which weapons the
  engine's own "switch hand" can put in the off hand.
- **RSQ Miniboss's code was not read.** The "pulse monster / start fight" card is not in Gun Cards (see the end of Part 2).
- In Repo A, `zscript/rsld/*` (LegenDoom mode) was read only for names asked or answered; `MODELDEF.*` only for the
  class names in `MODELDEF.rsqgc`. The states of the 13 generated off-hand copies were read through their state labels
  and every line that reads a button or a token, not line by line.

---

# Part 1. The weapons and every input

## 1.0 Counts

| Group | Classes | Where |
|---|---|---|
| Main-hand weapons defined in src | 32 | `actors/Weapons/*.dec` |
| Off-hand copies (`RSQ_Off_<gun>`) | 13 | `DECORATE.rsqdual`, `DECORATE.rsqdualmg:21`, `actors/Weapons/Axe.dec:455`, `actors/Weapons/BrutalRevolver.dec:263` |
| The off hand's own weapon `RSQ_Hands` | 1 | `zscript/rsq/hands.zs:241` |
| `Purist<gun>` copies | 24 | one line each, listed in 1.6 |
| Named in src, defined in base Brutal Doom | `Melee_Attacks` (fists) | not visible |

46 weapon classes with states of their own, 70 with the Purist copies, 71 with `Melee_Attacks`.

Three more classes inherit from `Weapon` but only hold states for layers and are never given to the player by any code
read: `RSQ_HotdStates` (`zscript/rsq/flick.zs:495`, used at `:267`), `RSR_PartStates` (`zscript/rsr/vreload.zs:947`,
used at `:167`), `RSB_PartStates` (`zscript/rsr/rsr_break.zs:1192`).

## 1.1 Which hand a class can be in

- `RSQ_Hands` is the off hand's only: `+WEAPON.OFFHANDWEAPON`, `+WEAPON.NOHANDSWITCH` (`zscript/rsq/hands.zs:276-277`).
- `Melee_Attacks` is the main hand's only: src sets `bNoHandSwitch` on it every tic (`zscript/rsq/fists.zs:117-120`).
- The 13 guns of `RSQ_DualTable` (`zscript/rsq/dualtable.zs:8`: BrutalPistol, Revolver, BrutalSMG, MP40, Rifle,
  Plasma_Gun, Shot_Gun, SSG, AssaultShotgun, RailGun, BrutalRevolver, BrutalAxe, Minigun) are the main-hand version; in
  the off hand `RSQ_Dual.Hands` turns them into their `RSQ_Off_` copy, and a copy in the main hand into its gun
  (`zscript/rsq/dual.zs:231-296`). The main class can be in the off hand "for a moment before it is swapped in"
  (comment, `zscript/rsvr/melee.zs:780-781`).
- The other 19 main-hand classes have no flag in src that keeps them out of the off hand. src's comments name
  "QuestZDoom's switch hand" and other mods as ways a weapon gets there (`zscript/rsq/dual.zs:257`,
  `zscript/rsq/hands.zs:326-327`). Whether a given class really reaches the off hand is the engine's and those mods'
  doing and was not read.

## 1.2 Inputs that many weapons share

Each weapon section below names these by their letter.

**A. Brutal Doom's tokens (main hand).** Most ready loops do not wait for the engine: they test inventory tokens and
jump. The tokens are `FiredPrimary` (fire), `FiredSecondary` (alt fire), `Reloading` (reload), `Unloading` (unload),
`Kicking`, `Taunting`, `Salute1`, `Salute2`, `TossGrenade`, `IsRunning` (sprint), `ExecuteDownedEnemy`,
`StartDualWield`. The shared targets are in `BrutalWeapon`: `DoKick` (`actors/Weapons/DEFAULTWEAPON.dec:391`), `Taunt`
(`:601`), `Salute` (`:622`), `TossGrenade` (`:634`, throws `HandGrenade` at `:670`, needs `GrenadeAmmo` `:636`),
`DoExecution` (`:692`). **No file in src gives these tokens from a key.** src says Brutal Doom's ACS does it
(`zscript/rsr/vreload.zs:1235`: "BD22: its ACS turns reload into this token"; `zscript/rsq/dual.zs:447`: "BD22: +user3
gives StartDualWield"). The keys themselves are Brutal Doom's and not visible. src gives two of them itself:
`Reloading` from the off hand's reload button (H below) and `StartDualWield` once at the start of a game with Start
With Two (`zscript/rsq/roster.zs:113-121`).

**B. The off hand reads raw buttons.** The same states serve both hands and split on `OverlayID() == 1000000`: the
main hand takes the token, the off hand takes `GetPlayerInput(INPUT_BUTTONS) & 67108864` for fire and `& 134217728`
for alt fire (first seen at `actors/Weapons/DEFAULTWEAPON.dec:220`; e.g. `actors/Weapons/Rifle.dec:244` and `:246`).
67108864 is `BT_OFFHANDATTACK` (`CVARINFO.rsr:3`). 134217728 is bit 27; src's ZScript reads the same button as
`BT_OFFHANDALTATTACK` (`zscript/rsr/rsr_m203.zs:355`); the number itself is not named in either repo. `& 1` is the main
trigger and `& 32` is alt fire (`CVARINFO.rsvr:11` "32 = BT_ALTATTACK"). The off hand never reads `Reloading`,
`Kicking`, `Taunting` (comment `actors/Weapons/Axe.dec:453-454`; the reload test is written
`OverlayID() != 1000000 && CountInv("Reloading") > 0`, e.g. `actors/Weapons/DEFAULTWEAPON.dec:241`).

**C. The engine's own checks.** A state that calls `A_WeaponReady` with no `WRF_NOFIRE` lets the engine's fire and alt
fire start `Fire` / `AltFire`; with `WRF_ALLOWRELOAD` the engine's reload starts `Reload`; with `WRF_ALLOWZOOM` the
engine's zoom starts `Zoom`. `Zoom` exists once, in `BrutalWeapon`, and is the same label as `DoKick`
(`actors/Weapons/DEFAULTWEAPON.dec:390-391`): zoom is the kick. **No `A_WeaponReady` in src passes
`WRF_ALLOWUSER1` to `WRF_ALLOWUSER4`** (grep, 0 hits), so the labels `User1` (= `TossGrenade`,
`DEFAULTWEAPON.dec:633-634`), `User2` (= `Unload`) and `User3` (= `DualWield`) are not entered from the engine's user
buttons by any state in src; they are entered by the tokens of A. (What the engine does with these flags is the
engine's; not read.)

**D. Every gun fires at Brutal Doom's rate.** `RSQ_TriggerHeld` rewrites `player.attackdown` from `BT_ATTACK` held on
two tics running (`zscript/rsq/semiauto.zs:13-22`); it is given to every player (`zscript/rsq/alts.zs:36-38`).
`RSQ_SemiLock` is taken when the trigger is up and `FiredPrimary` is gone (`zscript/rsq/semiauto.zs:24-34`).

**E. The Reload button, a gun in each hand.** Any of `BT_RELOAD`, `BT_MAINHANDRELOAD`, `BT_OFFHANDRELOAD`
(`zscript/rsq/flick.zs:53`, `:320`) reloads the off hand's gun always and the main gun only while the off hand holds a
gun too (`zscript/rsq/flick.zs:367-382`); a busy gun takes it within 105 tics (`:52`). A rifle's launcher is loaded on
the same press (`:385`). "Gun" here is any weapon with a `Reload` state except `RSQ_Hands`, `Melee_Attacks`,
`BrutalAxe`, `Chain_saw`, `DSweap`, `HandGrenades` (`zscript/rsq/flick.zs:73-85`). Off for the Purist class (`:323`).

**F. The reload gesture.** Runs for each hand when both hands hold guns and `rsq_flick` is on, and for the main gun
alone when it is a lone SSG, or the off hand holds one of the series' off-hand items; a lone Rifle's gesture loads its
launcher only (`zscript/rsq/flick.zs:147-171`). `rsq_reload_gesture` 0 (default): point the gun
`rsq_offscreen_deg` (60, clamp 40 to 85) below where you look, or 120 degrees off it, and pull that hand's trigger: the
gun reloads and does not fire (`zscript/rsq/flick.zs:9-24`, `:49`, `:117-130`; trigger read `:255`). 1: flick the
barrel down 45 degrees within 4 tics, ending 40 below level (`:25-26`, `:41-44`). In VR only, not for Purist (`:147`).

**G. The hand reload (magazines).** With `rsr_reload` 1, in VR, not Purist, and `RSQ_Hands` in the off hand
(`zscript/rsr/vreload.zs:1086-1095`), the gun's `Reload` goes to `RSR_Start` and the script takes over: the magazine
drops, the off hand takes a new one at least 20 cm from the well (or 40 cm below the eyes with `rsr_pouch` 1), brings
it to the well, pushes it home, then pulls the handle; a locked-back slide lets go on a 1.5 cm tug
(`zscript/rsr/vreload.zs:3-9`, `:65-66`, `:76`). The off hand takes hold with: the off trigger
(`rsr_grab_buttons`, default `BT_OFFHANDATTACK`) anywhere; or the off grip, read as raw key codes `rsr_grip_keys`
("443 436") in `InputProcess`, only when the controllers are 50 cm or more apart or `vr_two_handed_weapons` is 0; or the
Use key while a reload has the hand; one of the three by `rsr_grab_with` (`zscript/rsr/vreload.zs:110-122`,
`:135-149`, `:1363-1415`, `CVARINFO.rsr:2-3`, `CVARINFO.rsq:13`). With RSQ Tactical Rig's pouch the round is taken only
there (`zscript/rsr/vreload.zs:92-108`). For 18 guns, by exact class name (`zscript/rsr/rsr_guns.bd.zs:20-44`): Rifle,
BrutalPistol, BrutalSMG, MP40, AssaultShotgun, RailGun, Plasma_Gun, Sniper, Rocket_Launcher, MG42, Flamethrower2,
IncendiaryLauncher, Unmaker, Devastator, NukeLauncher, HellishMissileLauncher, Minigun, Machinegun.

**H. The off hand's reload button starts the main gun's reload.** `rsr_magrelease` (default 268435456,
`BT_OFFHANDRELOAD`, `CVARINFO.rsr:4`): on the press, with G's conditions, the main gun gets its reload token or its
`Reload` state (`zscript/rsr/vreload.zs:1223-1245`; the same for break-open guns `zscript/rsr/rsr_break.zs:1465-1490`).

**I. The hand reload (break-open guns and revolvers).** SSG, GrenadeLauncher, Revolver, BrutalRevolver, by exact class
(`zscript/rsr/rsb_guns.zs:29-41`): `Reload` goes to `RSB_Start`, the action swings open, the off hand takes a round
(same grab rule as G), puts it in a chamber from behind and pushes it home; a quick turn of the gun hand the way the
action closes (`rsb_flick_speed` 450 deg/s over 3 tics, `CVARINFO.rsb:3`) or the off hand pushing it shut closes it
(`zscript/rsr/rsr_break.zs:6-13`). `rsb_revolver_feed` 0 speedloader, 1 a round at a time (`CVARINFO.rsb:26`,
`zscript/rsr/rsb_guns.zs:22-27`); `rsr_ssg_pair` 1: two shells at once into an empty double barrel (`CVARINFO.rsb:6`).

**J. The two-hand grip.** The engine's steadying (`WF_TWOHANDSTABILIZED`, read at `zscript/rsvr/vrhand.zs:107-109`;
src's comments say the engine starts it on the off grip pressed within 50 cm of the gun hand,
`zscript/rsr/vreload.zs:135-142`) multiplies every main-hand shot's spread by `sv_rsq_twohand_spread` (0.5); shotguns
only with `sv_rsq_twohand_shotguns` (`CVARINFO.rsx:28-35`).

**K. Pistol whip.** Swing the gun into something: `rsq_pistol_whip` (on), speed `rsq_whip_speed` (5.0). Main hand:
BrutalPistol, Revolver, BrutalRevolver (`zscript/rsvr/melee.zs:746-756`). Off hand: the same three and their copies
(`:782-788`). With RSQ Melee loaded it is RSQ Melee's (`zscript/rsvr/melee.zs:769-771`, `zscript/rsvr/yield.zs:23-24`).

**L. Butt strike.** `rsq_butt` (off by default, `CVARINFO.rsq:51`), speed `rsq_butt_speed` 2.4 m/s
(`zscript/rsvr/melee.zs:1107`): the butt leading, a shove counts (`:1163-1172`). Main hand only: Rifle, Shot_Gun, SSG,
AssaultShotgun, MP40, BrutalSMG, Machinegun, MG42 (`zscript/rsvr/melee.zs:727-745`).

**M. The Dual key.** `StartDualWield` is taken by `RSQ_Dual` before any gun sees it and toggles the off hand between
the copy of the main gun and the fist (`zscript/rsq/dual.zs:6-8`, `:447-452`, `:459`). Per gun it needs its
`rsq_dual_<gun>` setting (`CVARINFO.rsqdual:4-16`).

**N. Whip, butt and punch work switches.** A blow that lands on a usable line works it within 30 map units
(`rsq_punch_use`, `zscript/rsq/fists.zs:53-58`; `zscript/rsvr/melee.zs:1257-1261`).

## 1.3 Main-hand guns

"Header" gives the ammo lines exactly as written. `BrutalWeapon` sets `Weapon.AmmoUse1 0`, `Weapon.AmmoGive1 0`,
`Weapon.AmmoUse2 0`, `Weapon.AmmoGive2 0` for all of them unless the weapon says otherwise
(`actors/Weapons/DEFAULTWEAPON.dec:3-6`). No weapon in src declares `SisterWeapon`. "Twin" is the `RSQ_Off_` copy.
All paths in this section are `actors/Weapons/<file>` unless a folder is given.

### BrutalPistol — `Pistol.dec:2` — Tag `$TAGBD_PISTOL` (`:12`; "Pistol" in `zscript/rsq/dualtable.zs:33`)
- Header: `Weapon.AmmoType1 "Clip1"` (`:4`), `Weapon.AmmoType2 "BDPistolAmmo"` (`:5`). Magazine: the Ammo2 pile `BDPistolAmmo` (not defined in src; the fill loop stops at 15, `:71`).
- Twin: `RSQ_Off_BrutalPistol`.
- Fire (`Fire` `:316`): one round of `BDPistolAmmo`; A, B, C, D. With `rsa_pistol_semi` (off by default, `CVARINFO.rsr:30`) the gun waits for the trigger to come up, reading `& 1` / `& 67108864` (`RSA_SemiHold` `:371-374`).
- Alt fire (`AltFire` `:547`): switches burst and single (`PistolBurstFire`, prints `$BD_PISTOL_BURST_MODE` / `$BD_PISTOL_SINGLE_MODE`); nothing while `RSLD_AltDown` is held (`:548`).
- Reload (`Reload` `:454`): with a full magazine it goes to `Inspect` (`:416`), where alt fire held continues it (`:418`); else `RSR_Start` (`:17`): G, H; E, F with two guns.
- `Unloading` -> `Unload` (`:568`, label `User2` `:567`). `User3` / `DualWield` (`:606-607`) -> `GetDual` (`:614`, selects `DualPistols` at `:628`): the ready loop's jump to it is `A_JumpIf(0, "DualWield")` (`:234`), so it is not taken; M does the dual.
- Also: K, J, N.

### Revolver — `Revolver.dec:2` — Tag `$TAGBD_REVOLVER` (`:12`; "Shotvolver" in `zscript/rsq/dualtable.zs:33`)
- Header: `Weapon.AmmoType1 "AmmoShell"` (`:5`), `Weapon.AmmoType2 "RevolverAmmo"` (`:6`). Magazine: Ammo2 pile `RevolverAmmo`, max 6 (`:532-537`).
- Twin: `RSQ_Off_Revolver`.
- Fire (`:236`); the hammer step reads `& 32` / `& 134217728` (`Hammering` `:292`).
- Alt fire (`AltFire` `:316`): with `rsa_rev_slug` (on, `CVARINFO.rsr:31`; token `RSA_Opt_Rev`) the next shot is a slug (`RSA_Magnum` main, `RSA_MagnumOff` off, `:316-324`; `zscript/rsq/alts.zs:10-11`); without it, nothing (`:317`).
- Reload (`:390`): full -> `Inspect` (`:56`); else `RSB_Start` (`:20`): I, H. `Unloading` -> `Unload` (`:487`).
- Also: K, M, E, F, J.

### BrutalRevolver — `BrutalRevolver.dec:47` — Tag `"Silvergun"` (`:65`)
- Header: `Weapon.AmmoUse1 0`, `Weapon.AmmoUse2 0`, `Weapon.AmmoGive1 18`, `Weapon.AmmoGive2 0`, `Weapon.AmmoType1 "Clip1"`, `Weapon.AmmoType2 "BrutalRevolverCylinder"` (`:50-55`). Magazine: Ammo2 pile `BrutalRevolverCylinder`, max 6 (`:38-44`). A reload needs 3 `Clip1` (`:173-176`; one loaded round costs 3, `zscript/rsr/rsb_guns.zs:13-15`).
- Twin: `RSQ_Off_BrutalRevolver`.
- Ready (`:102`): `FiredPrimary` -> `Fire` (`:108`), `Reloading` -> `Reload` (`:105`), `A_WeaponReady(WRF_ALLOWRELOAD)` (`:109`), kick, grenade toss (`:103`, `:110`).
- Fire (`:121`): one shot per pull (`RSQ_SemiLock` `:123`; the trigger is read `& 1` at `:146`). No `AltFire` label of its own.
- Reload (`:173`) -> `RSB_Start` (`:209`): I, H.
- Slot 2 (`KEYCONF.rsqmoon:3`). Also: K, M, E, F, J. `rsq_moonlight_pistol` puts it in the Pistol's place (`CVARINFO.rsq:33`).

### BrutalSMG — `SubMachinegun.dec:2` — Tag `$TAGBD_SMG` (`:10`)
- Header: `Weapon.AmmoType1 "Clip1"` (`:4`), `Weapon.AmmoType2 "BDSMGAmmo"` (`:5`). Magazine: Ammo2 pile.
- Twin: `RSQ_Off_BrutalSMG`.
- Fire (`:342`). In burst, three rounds then it waits for the trigger to come up (`RSA_BurstStep` `:393`, `RSA_BurstWait` `:408-410`, reads `& 1` / `& 67108864`).
- Alt fire (`AltFire` `:211`): always `RSA_SMGToggle` (`:412`): switches 3-round burst and full auto, prints "SMG: 3-round burst" / "SMG: full auto"; then waits for the button to come up (`RSA_AltWait` `:420-422`).
- Reload (`:484`) -> `RSR_Start` (`:18`): G, H. `Unloading` -> `Unload` (`:572`). `DualWield` (`:622`).
- Also: L, M, E, F, J.

### MP40 — `Mp40.dec:2` — Tag `$TAGBD_MP40` (`:11`)
- Header: `Weapon.AmmoType2 "MP40Ammo"` (`:4`), `Weapon.AmmoType1 "Mauser9mm"` (`:5`). Magazine: Ammo2 pile.
- Twin: `RSQ_Off_MP40`.
- Fire (`:331`). Alt fire (`AltFire` `:239`): Brutal Doom's aim: `Zoomed`, `A_ZoomFactor(1.3)`, `ADSmode`; again to leave (`NoAim`); hold or toggle by Brutal Doom's `AimMode_Toggle` / `AimMode_Hold` tokens (`:239-259`).
- Reload (`:430`) -> `RSR_Start` (`:19`): G, H. `Unloading` -> `Unload` (`:589`). `DualWield` (`:631`).
- Also: L, M, E, F, J.

### Rifle — `Rifle.dec:2` — Tag `$TAGBD_RIFLE` (`:10`)
- Header: `Weapon.AmmoType1 "Clip2"` (`:4`), `Weapon.AmmoType2 "RifleAmmo"` (`:5`). Magazine: Ammo2 pile `RifleAmmo`, max 31 (`:980-985`). The launcher's round is a token: `RFGLoaded` (main, `:505-507`), `RSM_LoadedOff` (off, `:509-511`).
- Twin: `RSQ_Off_Rifle`.
- Fire (`:306`).
- Alt fire (`AltFire` `:606`): always `RSM_AltGrenade` (`:505`): launches the underbarrel when loaded (`FireGrenade`), else a dry click (`RSM_Dry` `:498`); in the off hand `RSM_FireOff` (`:509`). Brutal Doom's aim states after it are not reached (`A_Jump(256, ...)` first, `:606-608`).
- The launcher by hand (one rifle, main hand; `zscript/rsr/rsr_m203.zs:5-17`): steadied, the off trigger is the latch (`:339`), hold it and push the off hand forward to open the tube; let go, take a 40 mm round away from the gun (G's grab), tilt it into the breech and push it home; steady and pull back to shut. `rsm_ammo` 0 a rocket, 1 a hand grenade (`CVARINFO.rsr:27`). Two rifles: F or E loads it (`zscript/rsr/rsr_m203.zs:18-19`).
- Reload (`:788`): full -> `Inspect` (`:691`); else `RSR_Start` (`:18`): G, H. `Unloading` -> `Unload` (`:894`). `DualWield` (`:933`). While aiming, `TossGrenade` goes to `FireGrenade` (`:256`, `:648`).
- Also: L, M, E, F, J.

### Plasma_Gun — `Plasma.dec:2` — Tag `$TAGBD_Plasma` (`:11`)
- Header: `Weapon.AmmoType1 "AmmoCell"` (`:4`), `Weapon.AmmoType2 "PlasmaAmmo"` (`:5`). Magazine: Ammo2 pile.
- Twin: `RSQ_Off_Plasma_Gun`.
- Fire (`:380`). Alt fire (`AltFire` `:430`): needs 10 `PlasmaAmmo`, charges while held (`AltHold` `:477`, `A_ReFire`), fires on release (`LetFly`); `Reloading` during the hold cancels it (`:481-487`); nothing while `RSLD_AltDown` (`:431`).
- Reload (`:645`) -> `RSR_Start` (`:20`): G, H. `Unloading` -> `Unload` (`:693`). `DualWield` (`:722`).
- Also: M, E, F, J.

### Shot_Gun — `Shotgun.dec:3` — Tag `$TAGBD_SHOTGUN` (`:14`)
- Header: `Weapon.AmmoType1 "AmmoShell"` (`:7`), `Weapon.AmmoType2 "ShotgunAmmo"` (`:8`). Magazine: Ammo2 pile `ShotgunAmmo`, max 9 (`:1028-1033`). A spent shell in the chamber is the token `ShotgunWasEmpty` (`:41`, `:72`; `zscript/rsq/dual.zs:163-171`).
- Twin: `RSQ_Off_Shot_Gun`.
- Fire (`:443`). Alt fire (`AltFire` `:671`): with `rsa_sg_slug` (off, `CVARINFO.rsr:32`; token `RSA_Opt_Slug`) the next shot is a slug (`RSA_SlugGo` `:701`); without it Brutal Doom's aim (`A_ZoomFactor(1.2)`, `:671-691`).
- Reload (`:819`): shells by hand (`RSP_Load` `:23`): the off hand takes one shell away from the gun (G's grab) and pushes it in at the loading port, and at the ejection port too with `rsr_sideport` 1 (`CVARINFO.rsb:9`); one shell counts as `rsr_shell_credit` (1 to 4, `CVARINFO.rsr:23`). The reload button (`BT_RELOAD` or bit 20) puts a shell in any time up to the cap (`zscript/rsr/rsr_pump.zs:359-372`).
- The pump by hand: steadied (J) with the off controller at the pump, or the grab taken on the pump and held, the pump follows the hand back and forward; off the pump, Brutal Doom's own pump runs (`zscript/rsr/rsr_pump.zs:12-19`).
- `Kicking` while loading -> `RSP_Kick` (`:94`). `Unloading` -> `Unload` (`:933`). `Inspect` (`:271`).
- Also: L, M, E, F, J. `rsq_pump_spread` changes its pattern (`CVARINFO.rsx:17`).

### SSG — `SSG.dec:2` — Tag `$TAGBD_SSG` (`:14`)
- Header: `Weapon.AmmoType1 "AmmoShell"` (`:7`), `Weapon.AmmoType2 "SSGAmmo"` (`:8`). Magazine: Ammo2 pile (the copy's is max 2, `DECORATE.rsqdual:5272-5278`).
- Twin: `RSQ_Off_SSG`.
- Fire (`:217`): both barrels with 2 loaded, else it goes to `AltFire`. Alt fire (`AltFire` `:307`): one barrel.
- Reload (`:453`): full -> `Inspect` (`:87`); else `RSB_Start` (`:22`): I, H. A lone SSG also takes F and reloads itself (`RSQ_FlickReload` `:61`; `zscript/rsq/flick.zs:158-160`, `:417-420`).
- `Unloading` -> `Unload` (`:555`). Also: L, M, E, J.

### AssaultShotgun — `AssaultShotgun.dec:2` — Tag `$TAGBD_ASG` (`:10`)
- Header: `Weapon.AmmoType1 "AmmoShell"` (`:4`), `Weapon.AmmoType2 "AssaultShotgunAmmo"` (`:5`). Magazine: Ammo2 pile, max 20 (`:800-805`).
- Twin: `RSQ_Off_AssaultShotgun`.
- Fire (`:234`; main hand from `FiredPrimary`, off from `& 67108864`, `:170`). Alt fire (`AltFire` `:390`): with `rsa_asg_slug` (on, `CVARINFO.rsr:33`; token `RSA_Opt_ASlug`) the next shot is a slug (`RSA_ASlugGo` `:370`); without it Brutal Doom's aim (`A_ZoomFactor(1.3)`).
- Reload (`:471`): full -> `Inspect` (`:594`); else `RSR_Start`: G, H. `Unloading` -> `Unload` (`:683`).
- Also: L, M, E, F, J.

### RailGun — `Railgun.dec:2` — Tag `$TAGBD_RAILGUN` (`:11`)
- Header: `Weapon.AmmoType1 "AmmoCell"` (`:4`), `Weapon.AmmoType2 "RailgunAmmo"` (`:5`). Magazine: Ammo2 pile (the copy's is max 5, `zscript/rsq/dualtable.zs:23`). A reload needs 10 `AmmoCell` (`:609-615`).
- Twin: `RSQ_Off_RailGun`.
- Fire (`:246`). Alt fire: the state (`AltFire` `:442`) only takes `FiredSecondary` and `ZoomHold` and goes back to `Ready`. The live scope is switched off and on by the script on the press of `BT_ALTATTACK` (`zscript/rsq/scope_real.zs:310-318`; table row 1, `zscript/rsq/scope.zs:72`), main hand's gun only (it reads the ready weapon's table row). `rsq_scope2_railgun` 0 dot, 1 real (`CVARINFO.rsq:26`).
- Reload (`:609`) -> `RSR_Start` (`:20`): G, H. `Unloading` -> `Unload` (`:669`). Also: M, E, F, J.

### Sniper — `Sniper.dec:2` — Tag `$TAGBD_SNIPER` (`:15`; "Ruger" in Repo A's README)
- Header: `Weapon.AmmoType1 "SniperAmmo"` (`:4`), `Weapon.AmmoType2 "xm21Ammo"` (`:5`). Magazine: Ammo2 pile `xm21Ammo`, max 11 (`:727-732`).
- No twin.
- Fire (`:238`): one shot per pull (`RSQ_SemiLock` `:239`). Alt fire (`AltFire` `:448`): as the RailGun: the state does nothing, the script switches the live scope (`zscript/rsq/scope_real.zs:310-318`; `zscript/rsq/scope.zs:73`); `rsq_scope2_sniper` (`CVARINFO.rsq:25`).
- Reload (`:587`): full -> `Inspect` (`:526`); else `RSR_Start` (`:23`): G, H. `Unloading` -> `Unload` (`:689`). Also: J.

### Rocket_Launcher — `RocketLauncher.dec:2` — Tag `$TAGBD_RL` (`:13`)
- Header: `Weapon.AmmoType1 "AmmoRocket"` (`:6`), `Weapon.AmmoType2 "RocketRounds"` (`:7`). Magazine: Ammo2 pile `RocketRounds`, max 6 (`:785-790`).
- No twin.
- Fire (`:350`). Alt fire (`AltFire` `:683`): with `rsa_rl_lock` (on, `CVARINFO.rsr:34`; token `RSA_Opt_RLLock`) hold it (`RSA_RLLock` `:679-681`): every 4 tics the enemy nearest the barrel's line within `rsa_rl_lock_cone` (10 degrees) is locked, up to 3; let go and one homing rocket goes to each (`zscript/rsq/rlock.zs:4-16`, button read `:93`). Without it Brutal Doom's aim (`A_ZoomFactor(3.0)`, `PowerLightAmp`).
- Reload (`:577`) -> `RSR_Start` (`:22`): G, H. `Unloading` -> `Unload` (`:647`). Also: J.

### GrenadeLauncher — `GrenadeLaunch.dec:2` — Tag `$TAGBD_GL` (`:12`)
- Header: `Weapon.AmmoType1 "AmmoRocket"` (`:4`), `Weapon.AmmoType2 "GLAmmo"` (`:5`). Magazine: Ammo2 pile.
- No twin.
- Fire (`:218`): `ShortGrenade2` (`:238`). Alt fire (`AltFire` `:266`): gives `FiredSecondary` and goes to `Fire`, which then fires `GrenadeMissile` (`:240-243`; the off hand's test is `& 134217728`, `:228`).
- Reload (`:272`): loaded -> `Inspect` (`:56`); else `RSB_Start` (`:21`): I, H. `Unloading` -> `Unload` (`:322`). Also: J.

### MiniGun — `Minigun.dec:3` — Tag `$TAGBD_CHAINGUN` (`:17`; "Minigun" in `zscript/rsq/dualtable.zs:33`)
- Header: `Weapon.AmmoType "RSQ_MinigunAmmo"` (`:7`), `Weapon.AmmoUse 1` (`:8`), `Weapon.AmmoGive 200` (`:9`). `RSQ_MinigunAmmo`: max 400, backpack 800 (`:603-608`). Magazine: the inventory token `RSQ_Mag_Minigun`, max 200 (`zscript/rsq/counters.zs:428`), with up to 10 rounds lent into the pile (`RSQ_Lent_Minigun`, `zscript/rsq/counters.zs:20-22`, `:435`), while VR reloading is on (`zscript/rsq/counters.zs:1-6`).
- Twin: `RSQ_Off_Minigun`.
- Fire (`:280`, hold `:291`; main from `FiredPrimary`, off from `& 67108864`, `:175`). Alt fire (`AltFire` `:552`): spins the barrels up and keeps them spinning (`Spin`), again to stop (`StopAlt`).
- Reload (`:25`): to `RSR_Start` when the box is out or not full and the pouch has rounds (`:25-30`): G, H. Also: M, E, F, J.

### MG42 — `MG42.dec:2` — Tag `$TAGBD_MG42` (`:13`)
- Header: `Weapon.AmmoUse 1` (`:6`), `Weapon.AmmoType "Clip2"` (`:7`). Magazine: token `RSQ_Mag_MG42`, max 100 (`zscript/rsq/counters.zs:396`), as the MiniGun's.
- No twin. Fire (`:109`). No `AltFire` label. Reload (`:20`) -> `RSR_Start`: G, H. Also: L, J.

### Machinegun — `Machinegun.dec:5` — Tag `"MachineGun"` (`:23`)
- Header: `Weapon.AmmoType1 "Clip2"`, `Weapon.AmmoGive1 0`, `Weapon.AmmoUse1 1`, `Weapon.AmmoType2 "AmmoRocket"`, `Weapon.AmmoGive2 0`, `Weapon.AmmoUse2 1` (`:8-13`). Its Ammo2 is the launcher's rockets, not a magazine (`SBARINFO.rsq:214`). Magazine: token `RSQ_Mag_Machinegun`, max 100 (`zscript/rsq/counters.zs:408`). The launcher's round: token `RFGLoaded` (`:276`).
- No twin. Slot 4 (`KEYCONF.rsq:8`).
- Fire (`:209`). Alt fire (`AltFire` `:248`): with the token `RSM_VR` the launcher fires when loaded, else a dry click (`RSM_AltGrenade` `:276`, `RSM_Dry` `:278`); without it Brutal Doom's own launcher shot and its reload (`:249-266`). `RSM_VR` is set each tic from `RSM.VRReload` (`zscript/rsr/rsr_m203.zs:929-931`); that test was not read.
- Reload (`:268`): with `RSM_VR` the box by hand (`RSR_Box` `:31`): G, H; else `ReloadGrenade`. Also: L, J.

### Flamethrower2 — `Flamethrower.dec:2` — Tag `$TAGBD_FLAMETHROWER` (`:16`)
- Header: `Weapon.AmmoType "Gas"` (`:6`), `Weapon.AmmoUse 1` (`:7`). Magazine: token `RSQ_Mag_Flamethrower2`, max 100 (`zscript/rsq/counters.zs:400`).
- No twin. Fire (`:197`, hold `:203`, not under water). No `AltFire` label. Reload (`:25`) -> `RSR_Start`: G, H. Also: J.

### FlameCannon — `FlameCannon.dec:1` — Tag `$TAGBD_FLAMECANNON` (`:12`)
- Header: `Weapon.AmmoType "Gas"` (`:4`); no AmmoUse line. No magazine.
- No twin. Fire (`:145`): a fireball, needs and takes 30 `Gas`. Alt fire (`AltFire` `:165`): the flame stream, needs 44 `Gas`. The label `Reload` (`:65`) is part of the ready loop; there is no reload. `User3` / `DualWield` (`:201-202`) -> `GetDual` (`:210`); the ready loop's jump to it is `A_JumpIf(0, ...)` (`:65-75`).

### Unmaker — `Unmaker.dec:2` — Tag `$TAGBD_UNMAKER` (`:14`)
- Header: `Weapon.AmmoUse 2` (`:4`), `Weapon.AmmoType "SoulAmmo"` (`:5`). Magazine: token `RSQ_Mag_Unmaker`, max 200 (`zscript/rsq/counters.zs:412`).
- No twin. Fire (`:190`, hold `:199`). No `AltFire` label. Reload (`:23`) -> `RSR_Start`: G, H. Also: J.

### Devastator — `Devastator.dec:2` — Tag `$TAGBD_DEVASTATOR` (`:15`)
- Header: `Weapon.AmmoUse 1` (`:6`), `Weapon.AmmoType "DevastatorAmmo"` (`:7`). Magazine: token `RSQ_Mag_Devastator`, max 50 (`zscript/rsq/counters.zs:416`).
- No twin. Fire and alt fire are one label (`AltFire` `:169`, `Fire` `:170`). Reload (`:25`) -> `RSR_Start`: G, H. Also: J.

### NukeLauncher — `NukeLauncher.dec:2` — Tag `$TAGBD_NUKE` (`:16`)
- Header: `Weapon.AmmoUse 1` (`:7`), `Weapon.AmmoType "Nuke"` (`:8`). Magazine: token `RSQ_Mag_NukeLauncher`, max 1 (`zscript/rsq/counters.zs:420`).
- No twin. Fire (`:160`). No `AltFire` label. Reload (`:24`) -> `RSR_Start`: G, H. Also: J.

### HellishMissileLauncher — `HellishMissile.dec:2` — Tag `$TAGBD_REVMISSILE` (`:14`)
- Header: `Weapon.AmmoUse 1` (`:4`), `Weapon.AmmoType "MiniHellRocketAmmo"` (`:5`). Magazine: token `RSQ_Mag_HellishMissileLauncher`, max 6 (`zscript/rsq/counters.zs:424`).
- No twin. Fire and alt fire are one label (`Fire` `:166`, `AltFire` `:167`). Reload (`:22`) -> `RSR_Start`: G, H. Its own `Taunt` (`:211`) and `TossGrenade` (`:235`). Also: J.

### IncendiaryLauncher — `IncendiaryLauncher.dec:2` — Tag `$TAGBD_M202` (`:12`)
- Header: `Weapon.AmmoType "AmmoM202"` (`:4`), `Weapon.AmmoUse 1` (`:5`). `AmmoM202`: amount 1, max 4 (`:132-138`). Magazine: token `RSQ_Mag_IncendiaryLauncher`, max 6 (`zscript/rsq/counters.zs:404`).
- No twin. Fire (`:109`). No `AltFire` label. Reload (`:19`) -> `RSR_Start`: G, H. Also: J.

### BIG_FUCKING_GUN — `BFG.dec:1` — Tag `$TAGBD_BFG9000` (`:15`)
- Header: `Weapon.AmmoUse 50` (`:5`), `Weapon.AmmoType "AmmoCell"` (`:6`). No magazine.
- No twin. Fire (`:125`). No `AltFire` and no `Reload` label. Ready (`:52-58`): kick and grenade toss only. Also: J.

### DualPistols, DualRifles, DualPlasmaRifles (Brutal Doom's one-weapon dual guns)
- `DualPistols` — `DualPistol.dec:1` — Tag `$TAGBD_DUALPISTOLS` (`:13`); `Weapon.AmmoType1 "Clip1"` (`:3`), `Weapon.AmmoType2 "BDDualPistolAmmo"` (`:4`); `+WEAPON.CHEATNOTWEAPON` (`:6`). Fire (`:182`), alt fire (`:311`, burst / single as the Pistol), `Reloading` -> `Reload` (`:327`), `Unloading` -> `Unload` (`:432`), `StartDualWield` -> `DualWield` (`:110`, `:114`: back to `BrutalPistol`).
- `DualRifles` — `DUalRifle.dec:1` — Tag `$TAGBD_DUALRIFLES` (`:12`); `Weapon.AmmoType1 "Clip2"` (`:3`), `Weapon.AmmoType2 "dOUBLERifleAmmo"` (`:4`); `+WEAPON.CHEATNOTWEAPON` (`:6`). Fire (`:176`), `Reload` (`:264`), `Unload` (`:355`), `DualWield` (`:140`, `:145`).
- `DualPlasmaRifles` — `DualPlasma.dec:1` — Tag `$TAGBD_DUALPLASMA` (`:12`); `Weapon.AmmoType1 "AmmoCell"` (`:3`), `Weapon.AmmoType2 "DoublePlasmaAmmo"` (`:4`); `+WEAPON.CHEATNOTWEAPON` (`:6`). Fire (`:235`), `Reload` (`:318`), `Unload` (`:370`), `DualWield` (`:181`).
- No twin. The only code in src that selects them is the single guns' `GetDual` labels (e.g. `Pistol.dec:614-628`), which no ready loop in src jumps to (see BrutalPistol), and `RSQ_Dual` takes `StartDualWield` first (`zscript/rsq/dual.zs:447-452`). They are not in `RSQ_DualTable`, in `RSQGCOFF.rsq`, or in the hand reload's tables.

## 1.4 Melee weapons, fists, grenades

### BrutalAxe — `Axe.dec:2` — Tag `$TAGBD_AXE` (`:21`)
- Header: `Weapon.AmmoType1 "RSVR_Axes"` (`:10`), `Weapon.AmmoUse1 0` (`:11`), `Weapon.AmmoGive1 1` (`:12`), `+WEAPON.MELEEWEAPON` (`:16`). `RSVR_Axes` is an `Ammo`, max 10, Tag "Axes" (`zscript/rsvr/axegrab.zs:34-48`): the count of axes you have, the ones in your hands included (`:19`); each throw spends one (`:3-5`). No magazine.
- Twin: `RSQ_Off_BrutalAxe`.
- Swing the controller: the blade cuts what it passes through, on a down or side swing, speed scaled by `rsvr_melee_swing` (`zscript/rsvr/melee.zs:3-8`, `:1142`; `CVARINFO.rsvr:5`).
- Fire (`Fire` `:283`): in VR with `rsg_vr` on (token `RSVR_AxeVRThrow`, `zscript/rsvr/melee.zs:186-188`) hold the trigger, swing, let go: thrown with the hand's speed (`TrigGrip` `:43`; `zscript/rsvr/melee.zs:10-12`, trigger read `:1576`). Otherwise Brutal Doom's chop (`Hold` `:296`).
- Alt fire (`AltFire` `:26` -> `AltGrip` `:34`): in VR the same hold-and-release throw; out of VR Brutal Doom's side swing (`:36`). The hold can also come from `rsvr_axe_hold` (a button mask, default 32) or raw key codes `rsvr_axe_keys` (`zscript/rsvr/melee.zs:477-490`, `:74-97`; `CVARINFO.rsvr:17`, `:21`); the ready loop enters it on the token `RSVR_AxeHold` (`:196`).
- While held to throw, the axe marks the monster the hand points at within `rsvr_axe_pick_cone` (8 degrees) out to `rsvr_axe_lock_range` (1200), and flies there (`CVARINFO.rsvr:33-35`); the direction blends the arm's motion and the hand's aim by `rsvr_axe_throw_blend` (`:37`).
- `Reload` (`:277`) is an empty label. `DualWield` (`:118`) throws Brutal Doom's `ThrowedAxe`; the ready loop does not jump to it (no `StartDualWield` test in `Ready` `:177-197`).
- A thrown axe lies 5 s and can be grabbed back with RSQ Distance Grab (`zscript/rsvr/axegrab.zs:9-17`). Also: M (`rsq_dual_axe`).

### Chain_saw — `Saw.dec:2` — Tag `$TAGBD_SAW` (`:13`)
- Header: no AmmoType line (`:2-14`); `+WEAPON.MELEEWEAPON` (`:7`). No ammo, no magazine. No twin.
- Fire (`Fire` `:170`): in VR (token `RSVR_SawVR`, `zscript/rsvr/melee.zs:197-199`) the chain runs while the trigger is held, with no swing animation (`RSVR_SawRun` `:419`, `RSVR_SawRunLoop` `:424`), and the bar cuts what it touches (`zscript/rsvr/melee.zs:1075-1076`). Out of VR Brutal Doom's own.
- Alt fire (`AltFire` `:432`): Brutal Doom's own states, not changed. Reload (`Reload` `:58`): Brutal Doom's own (`DoInspect`). The ready loop allows the engine's reload and zoom (`:128`).

### DSweap — `Dragonslayer.dec:5` — Tag `"Dragonslayer"` (`:14`)
- Header: no AmmoType line (`:5-14`). No ammo. No twin. The file says it is only got by cheats (`:2`).
- Swing: cuts only on a deliberate swing (`zscript/rsvr/melee.zs:424-428`, `:1180`).
- Fire (`Fire` `:87`): in VR (token `RSVR_SwordVR`) the trigger runs no combo (`RSVR_SwordNoCombo` `:56`); out of VR Brutal Doom's combo (`Hold` `:94`, off hand `& 67108864` at `:122`).
- Two hands: while the engine steadies it (J) the token `RSVR_SwordTwo` moves it to the two-hand placement and the blow counts 2.0x (`Ready` `:43`, `TwoHand`; `zscript/rsvr/melee.zs:195-196`, `:1440-1442`); the off grip held within 50 cm also sets `RSVR_MeleeTwo` (`zscript/rsvr/melee.zs:192-194`).

### HandGrenades — `Grenades.dec:1` — Tag `$TAGBD_GRENADE` (`:15`)
- Header: `Weapon.AmmoUse 1` (`:4`), `Weapon.AmmoType "GrenadeAmmo"` (`:5`). No magazine. No twin.
- In VR with `rsg_vr` 1 (token `RSG_VR`; `Ready3` `:66` -> `RSG_Ready` `:157`; fire and alt fire are shut off in the states, `:160`), the script does it (`zscript/rsg/grenade.zs:1-23`):
  1. the off trigger takes the ring and pulls it away: the pin is out (`BT_OFFHANDATTACK` only, `:463-465`); back at the top and grabbed again: pin back in;
  2. the main trigger is the squeeze on the spoon (`BT_ATTACK`, `:470`): let go while swinging and it is thrown at the swing's speed and direction; let go while still and it cooks in the hand; squeeze and let go again to throw;
  3. cooked 48 tics it goes off in the hand;
  4. the teeth: squeeze the trigger or alt fire (`:473`) and hold the grenade within `rsg_mouth_r` (0.15 m) of your mouth for `rsg_face_hold` (12) tics: the pin is out; the hand must have been `rsg_face_far` (0.71 m) clear before another (`CVARINFO.rsb:14-17`).
- Out of VR or `rsg_vr` 0: `User1` / `TossGrenade` / `Fire` are one label (`:101-103`); hold and let go throws `HandGrenade` (`Hold` `:108`); alt fire throws `HandGrenadeAlt` (`AltFire` `:128`, `AltHold` `:135`).
- Out of grenades the hand becomes the fist (`zscript/rsg/grenade.zs:414`). A thrown grenade goes off when a player's shot passes within `rsg_shot_r` (`CVARINFO.rsb:19-20`). With `rsg_rsq_nade` and RSQ Grenade loaded it stands down (`CVARINFO.rsb:27-29`).

### Melee_Attacks (Brutal Doom's fists) — not defined in src
- Its header, Tag and ammo lines are in base Brutal Doom and were not seen. What follows is only what src does to it.
- Main hand only (`zscript/rsq/fists.zs:117-120`).
- Punch by swinging (`rsq_punch`, on; in VR): over 2.5 m/s in the body's frame, at least 0.7 of it forward, 0.15 m of forward travel, ending 0.25 m ahead of the body; the hand must come back 0.08 m or go still before the next (`zscript/rsq/fists.zs:130-135`, constants in `RSQ_FistHand` `:152-162`). With RSQ Melee loaded the punch is RSQ Melee's (`:129-131`).
- Trigger and alt fire: with `rsq_no_trigger_punch` (on) in VR the canned punch is put straight back to `Ready`; the comment there says Brutal Doom's Fire is the jab and AltFire the cross, read from its Melee.dec (`zscript/rsq/fists.zs:254-266`, class `RSQ_NoTrigPunch` `:266`).
- A free main hand takes doors (below).

### RSQ_Hands (the off hand's fist) — `zscript/rsq/hands.zs:241` — Tag `"Fist"` (`:290`)
- Header: no ammo lines (`:274-292`). `+WEAPON.OFFHANDWEAPON`, `+WEAPON.NOHANDSWITCH`, `+WEAPON.CHEATNOTWEAPON`, `Weapon.SlotNumber 1` (`:276-291`); slot 1 also in `KEYCONF.rsq:5`. Given to the player every tic while hands or VR reloading are on (`:308-318`).
- States: `Ready` is `A_WeaponReady(WRF_NOFIRE | WRF_NOBOB)` (`:1166-1171`); `Fire` does nothing (`:1179-1181`). The off trigger throws no canned jab (`:899-902`).
- What the hand does is read by scripts: the punch by swinging as the main fist's (`zscript/rsq/fists.zs:133`, `:136`); every grab of G, I, the pump, the launcher and the grenade ring; doors.
- Doors (`rsq_door`, either free hand; `zscript/rsvr/door.zs:20-25`, `:163-170`): put a hand on a door and take hold with the off grip (`rsq_door_grip`, off hand only), Use (`rsq_door_use`, `BT_USE`) or a palm turned out against it (`rsq_door_palm`), then lift; let go past `rsq_door_commit` (0.40) and it opens (`CVARINFO.rsvr:39-44`). A hand holding a gun never takes a door (`zscript/rsvr/door.zs:414-420`). With RSQ Distance Grab loaded this stands down (`:157-159`).

## 1.5 The off-hand copies

All 13: `+WEAPON.OFFHANDWEAPON`, `-WEAPON.NOHANDSWITCH`, `+WEAPON.CHEATNOTWEAPON`, `Weapon.AmmoGive1 0`. Reserve is
shared with the gun; the magazine is the copy's own Ammo2 pile (`zscript/rsq/dual.zs:9`). The 10 in `DECORATE.rsqdual`
and the Minigun's are generated copies of their gun's states (`DECORATE.rsqdual:1-2`, `DECORATE.rsqdualmg:1-4`), so
their inputs are their gun's with B: fire is `& 67108864`, alt fire `& 134217728`, and no `Reloading` token; reload is
E and F only (`zscript/rsq/flick.zs:365-366`). K for the pistol and both revolvers.

| Class | File:line | Tag | Ammo lines |
|---|---|---|---|
| `RSQ_Off_BrutalPistol` | `DECORATE.rsqdual:15` | "Off-hand Pistol" (`:17`) | `AmmoType1 "Clip1"` (`:25`), `AmmoType2 "BDPistolAmmoOff"` (`:26`, max 16 `:6-11`) |
| `RSQ_Off_Revolver` | `DECORATE.rsqdual:652` | "Off-hand Revolver" (`:654`) | `"AmmoShell"` (`:663`), `"RevolverAmmoOff"` (`:664`, max 6 `:643-648`) |
| `RSQ_Off_BrutalSMG` | `DECORATE.rsqdual:1196` | "Off-hand SMG" (`:1198`) | `"Clip1"` (`:1206`), `"BDSMGAmmoOff"` (`:1207`, max 41 `:1187-1192`) |
| `RSQ_Off_MP40` | `DECORATE.rsqdual:1843` | "Off-hand MP40" (`:1845`) | `AmmoType2 "MP40AmmoOff"` (`:1853`, max 32 `:1834-1839`), `AmmoType1 "Mauser9mm"` (`:1854`) |
| `RSQ_Off_Rifle` | `DECORATE.rsqdual:2518` | "Off-hand Rifle" (`:2520`) | `"Clip2"` (`:2528`), `"RifleAmmoOff"` (`:2529`, max 31 `:2509-2514`); launcher token `RSM_LoadedOff` (`:3027`) |
| `RSQ_Off_Plasma_Gun` | `DECORATE.rsqdual:3484` | "Off-hand Plasma rifle" (`:3486`) | `"AmmoCell"` (`:3494`), `"PlasmaAmmoOff"` (`:3495`, max 50 `:3475-3480`) |
| `RSQ_Off_Shot_Gun` | `DECORATE.rsqdual:4250` | "Off-hand Shotgun" (`:4252`) | `"AmmoShell"` (`:4262`), `"ShotgunAmmoOff"` (`:4263`, max 9 `:4241-4246`); chamber token `RSQ_ShotgunWasEmptyOff` |
| `RSQ_Off_SSG` | `DECORATE.rsqdual:5281` | "Off-hand Super shotgun" (`:5283`) | `"AmmoShell"` (`:5294`), `"SSGAmmoOff"` (`:5295`, max 2 `:5272-5277`) |
| `RSQ_Off_AssaultShotgun` | `DECORATE.rsqdual:5888` | "Off-hand Assault shotgun" (`:5890`) | `"AmmoShell"` (`:5898`), `"AssaultShotgunAmmoOff"` (`:5899`) |
| `RSQ_Off_RailGun` | `DECORATE.rsqdual:6698` | "Off-hand Railgun" (`:6700`) | `"AmmoCell"` (`:6708`), `"RailgunAmmoOff"` (`:6709`) |
| `RSQ_Off_Minigun` | `DECORATE.rsqdualmg:21` | "Off-hand Minigun" (`:23`) | `AmmoType1 "RSQ_MinigunAmmo"` (`:30`), `AmmoType2 "MinigunAmmoOff"` (`:31`, max 200 `:5-12`), `AmmoUse2 0` (`:32`); its own spin token `RSQ_SpinOff` (`:14`) |
| `RSQ_Off_BrutalRevolver` | `actors/Weapons/BrutalRevolver.dec:263` | "Off-hand Silvergun" (`:265`) | `AmmoGive1 0`, `AmmoGive2 0`, `"Clip1"` (`:273`), `"BrutalRevolverCylinderOff"` (`:274`, max 6 `:254-260`) |
| `RSQ_Off_BrutalAxe` | `actors/Weapons/Axe.dec:455` | none of its own; inherits `$TAGBD_AXE` (`:457-463`) | `AmmoGive1 0` (`:458`); inherits `AmmoType1 "RSVR_Axes"` |

Two are written by hand and differ from their gun:
- `RSQ_Off_BrutalRevolver`: `Ready` is a plain `A_WeaponReady` (`BrutalRevolver.dec:280-283`); fire is one shot per pull with its own lock `RSQ_SemiLockOff`, the trigger read `& 67108864` (`:294-314`); `Reload` goes to the stock reload `RSB_Stock`, never the hand reload (`:338-341`).
- `RSQ_Off_BrutalAxe`: `Ready` is a plain `A_WeaponReady` (`Axe.dec:475-477`); `Fire` (`:478`) with the token `RSVR_OffAxeVRThrow` holds and throws on the off trigger's release (`OffTrigGrip` `:487`; `zscript/rsvr/melee.zs:1587`), otherwise the gun's chop; `AltFire` and `Reload` do nothing (`:482-485`). It swings and cuts from the off controller (`zscript/rsvr/melee.zs:14-18`). Thrown with no axe left, the hand is the fist again (`:497-501`). Slot 1 (`KEYCONF.rsq:13`).

## 1.6 The Purist copies

One line each: `ACTOR Purist<gun> : <gun> { -WEAPON.NOAUTOAIM +WEAPON.CHEATNOTWEAPON }`. They inherit their gun's
ammo, Tag and states; the states branch on the token `IsPlayingAsPurist` (given by base Brutal Doom, not seen), e.g.
the Pistol's fire then takes `Clip1` and not the magazine (`actors/Weapons/Pistol.dec:318`, `:329-332`). The hand
reload, the reload button and the gesture are off for that class (`zscript/rsr/vreload.zs:1090-1093`,
`zscript/rsq/flick.zs:147`, `:323`). Only `PuristRifle` has a state of its own: `AltFire` takes `RFGrenade` and does
nothing else (`actors/Weapons/Rifle.dec:963-972`).

`PuristAssaultShotgun` `AssaultShotgun.dec:798`, `PuristBIG_FUCKING_GUN` `BFG.dec:164`, `PuristDevastator`
`Devastator.dec:205`, `PuristFlameCannon` `FlameCannon.dec:229`, `PuristFlamethrower2` `Flamethrower.dec:250`,
`PuristGrenadeLauncher` `GrenadeLaunch.dec:397`, `PuristHandGrenades` `Grenades.dec:239`,
`PuristHellishMissileLauncher` `HellishMissile.dec:277`, `PuristIncendiaryLauncher` `IncendiaryLauncher.dec:130`,
`PuristMG42` `MG42.dec:244`, `PuristMinigun` `Minigun.dec:597`, `PuristMP40` `Mp40.dec:663`, `PuristNukeLauncher`
`NukeLauncher.dec:179`, `PuristPistol` `Pistol.dec:633`, `PuristPlasma_Gun` `Plasma.dec:749`, `PuristRailGun`
`Railgun.dec:771`, `PuristRevolver` `Revolver.dec:530`, `PuristRifle` `Rifle.dec:963`, `PuristRocket_Launcher`
`RocketLauncher.dec:783`, `PuristSSG` `SSG.dec:597`, `PuristShot_Gun` `Shotgun.dec:1026`, `PuristSniper`
`Sniper.dec:725`, `PuristSMG` `SubMachinegun.dec:648`, `PuristUnmaker` `Unmaker.dec:243` (all under
`actors/Weapons/`).

## 1.7 Keys: every KEYCONF line in src

src has two KEYCONF lumps. **They hold no alias, no bind and no key section of their own**: only weapon slots, in
Brutal Doom's own section. Every key the player presses for these weapons is the engine's or base Brutal Doom's
(not visible). No MENUDEF in src adds a key row (grep for `Control`, `alias`, `bind`: 0 hits).

| File:line | Section | Line | Default bind | What it does |
|---|---|---|---|---|
| `KEYCONF.rsq:4-5` | `weaponsection "Brutal_Doom"` | `addslotdefault 1 RSQ_Hands` | none (slot 1) | the off-hand fist can be picked in slot 1, so a gun moved to the off hand can be swapped back (`KEYCONF.rsq:1-3`) |
| `KEYCONF.rsq:8` | same | `addslotdefault 4 Machinegun` | none (slot 4) | the Machinegun on slot 4 with the MG42 |
| `KEYCONF.rsq:12-13` | `weaponsection "Brutal_Doom"` | `addslotdefault 1 RSQ_Off_BrutalAxe` | none (slot 1) | the off-hand axe cycles in the off hand with the off fist |
| `KEYCONF.rsqmoon:2-3` | `weaponsection "Brutal_Doom"` | `addslotdefault 2 BrutalRevolver` | none (slot 2) | the Silvergun on slot 2 |

Raw keys and console events read by code (not KEYCONF):

| What | Where | What it does |
|---|---|---|
| key codes in `rsr_grip_keys` ("443 436") | `zscript/rsr/vreload.zs:1363-1415` | the off grip: sent as the event `rsr_grip`; grabs for reloads (G), takes doors, the sword's two hands |
| the Use key, while a reload has the hand and `rsr_grab_with` is 2 | `zscript/rsr/vreload.zs:1372-1410` | sent as `rsr_use`: the grab; a running reload eats the press |
| key codes in `rsvr_axe_keys` (empty) | `zscript/rsvr/melee.zs:74-97` | sent as `rsvr_axe_grip`: readies the axe throw |
| `netevent rsld_drop` (menu row "Drop Legendary") | `MENUDEF.rsld:12` | drops the legendary; a menu row, not a key |
| `pukename LDMenuToggle` (menu row "Legendary Info") | `MENUDEF.rsld:10` | LegenDoom's info screen |
| `netevent rsq_ontop`, `netevent rsq_moon_count` | `zscript/rsq/counters.zs:160-165`, `zscript/rsq/roster.zs:96-100` | test printouts |

## 1.8 Every CVARINFO setting that changes a control

| Setting (default) | File:line | What it changes |
|---|---|---|
| `rsr_reload` (1) | `CVARINFO.rsq:3` | 1: reloads are by hand (G, I, pump, launcher); 0: Brutal Doom's own |
| `rsq_reload_nonstd` (true) | `CVARINFO.rsq:4` | the nine guns Brutal Doom never reloads have magazines |
| `rsr_grab_with` (0) | `CVARINFO.rsq:13` | what the off hand grabs ammo with: 0 off trigger, 1 off grip, 2 Use |
| `rsr_grab_buttons` (67108864) | `CVARINFO.rsr:3` | the button mask that grabs anywhere |
| `rsr_grip_keys` ("443 436") | `CVARINFO.rsr:2` | which key codes are the off grip |
| `rsr_magrelease` (268435456) | `CVARINFO.rsr:4` | the button that starts the main gun's reload (H) |
| `rsr_pouch` (0), `rsr_rig_pouch` (1) | `CVARINFO.rsr:5-6` | where a new magazine is taken |
| `rsr_eat_grip` (true) | `CVARINFO.rsr:7` | while a reload has the off hand its grip key does nothing else |
| `rsr_assist` (1.0) | `CVARINFO.rsr:14` | scales every reload reach and tolerance |
| `rsr_shell_credit` (1), `rsr_sideport` (1), `rsr_ssg_pair` (1) | `CVARINFO.rsr:23`, `CVARINFO.rsb:9`, `:6` | shells per insert; the second port; two shells at once |
| `rsb_flick_speed` (450), `rsb_revolver_feed` (0) | `CVARINFO.rsb:3`, `:26` | the wrist turn that shuts a break-open gun; speedloader or single rounds |
| `rsm_ammo` (0) | `CVARINFO.rsr:27` | what the launcher's hand-loaded round costs |
| `rsq_flick` (true), `rsq_reload_gesture` (0), `rsq_offscreen_deg` (60) | `CVARINFO.rsq:14-16` | the reload gesture (F) |
| `rsa_pistol_semi` (false), `rsa_rev_slug` (true), `rsa_sg_slug` (false), `rsa_asg_slug` (true), `rsa_rl_lock` (true), `rsa_rl_lock_cone` (10) | `CVARINFO.rsr:30-35` | what the trigger and alt fire do on the Pistol, Revolver, Shot_Gun, AssaultShotgun, Rocket_Launcher |
| `rsq_scope2_sniper` (1), `rsq_scope2_railgun` (1) | `CVARINFO.rsq:25-26` | the scope alt fire switches: dot or real |
| `rsq_dual_start` (true), `rsq_dual_pistol` ... `rsq_dual_minigun` | `CVARINFO.rsqdual:3-16` | which guns the Dual key puts in the off hand (shotgun, ssg, asg, railgun default off) |
| `rsq_moonlight_two` (false) | `CVARINFO.rsq:34` | start with a Silvergun in each hand |
| `rsq_instant_switch` (true) | `CVARINFO.rsq:71` | switching weapons skips raise and lower, both hands (`zscript/rsq/switch.zs:1-16`) |
| `rsq_punch` (1), `rsq_punch_use` (true), `rsq_no_trigger_punch` (true) | `CVARINFO.rsq:7-11` | punching by swing; blows work switches; no canned punch on the trigger |
| `rsq_pistol_whip` (true), `rsq_whip_speed` (5.0) | `CVARINFO.rsq:42`, `CVARINFO.rsvr:45` | K |
| `rsq_butt` (0), `rsvr_butt_fwd` (0.5), `rsq_butt_speed` (2.4) | `CVARINFO.rsq:51-53` | L |
| `rsvr_melee_swing` (1.0), `rsvr_melee_down` (0.25) | `CVARINFO.rsvr:5`, `:8` | how hard a swing must be; how far down a whip must point |
| `rsvr_axe_hold` (32), `rsvr_axe_keys` (""), `rsvr_axe_edge` (0.5), `rsvr_axe_pick_cone` (8), `rsvr_axe_lock_range` (1200), `rsvr_axe_throw_blend` (0.7) | `CVARINFO.rsvr:17-37` | the axe throw |
| `rsq_door`, `rsq_door_grip`, `rsq_door_use`, `rsq_door_palm` (all true), `rsq_door_commit` (0.40), `rsq_door_gain` (2.5) | `CVARINFO.rsvr:39-44` | doors lifted by hand |
| `rsg_vr` (1), `rsg_face` (1), `rsg_mouth_r` (0.15), `rsg_face_far` (0.71), `rsg_face_hold` (12) | `CVARINFO.rsb:12-17` | the grenade by hand and the teeth; `rsg_vr` also the axe's trigger throw |
| `rsg_shoot` (1), `rsg_rsq_nade` (0) | `CVARINFO.rsb:19`, `:29` | shooting a thrown grenade; standing down for RSQ Grenade |
| `sv_rsq_twohand_spread` (0.5), `sv_rsq_twohand_shotguns` (false) | `CVARINFO.rsx:32`, `:35` | J |
| `rsq_hands` (true) | `CVARINFO.rsq:2` | hands drawn on the controllers; with it or `rsr_reload` the off-hand weapon `RSQ_Hands` is given |

---

# Part 2. Each weapon against Gun Cards

## 2.1 The rules, from the code

All at Gun Cards' defaults: Show Cards Always (`rsqgc_card` 1), Watch Card On Check (`rsqgc_watch` 1), Watch Shows
Weapon (`rsqgc_watch_shows` 0), Draw in World off (`rsqgc_world` 0), Both Guns One Card off (`rsqgc_hands` 0)
(`GunCards/CVARINFO.txt:5`, `:7`, `:8`, `:12`, `:31`).

1. **A hand's weapon** is `p.ReadyWeapon` (main) or `p.OffhandWeapon` (off) (`card.zs:943`).
2. **Empty hand**: no weapon, or the class name is `Melee_Attacks` or `RSQ_Hands`, or it is a `Fist`
   (`card.zs:268-274`). Checking the watch with an empty hand is the Status card (`card.zs:933`).
3. **Item**: not an empty hand and no `Ammo1` (`card.zs:944`, `items.zs:24`). Checking the watch is the item card
   (`card.zs:945`, built at `card.zs:1109`). The item table names four classes of other mods and gives every other
   item its own name (`items.zs:55-63`); no class of Repo A is in it.
4. **Gun**: `Loaded(w) >= 0`, and `Loaded` answers -1 only when there is no weapon or no `Ammo1`
   (`card.zs:329-337`, `card.zs:946-947`). **This test does not ask whether the hand is empty**: a fists class with an
   `Ammo1` would be a gun for the small card.
5. **The count**: for a class that has both `RSQ_Mag_<class>` and `RSQ_Lent_<class>` and with `rsr_reload` 1,
   `rsq_reload_nonstd` on, in VR: the `RSQ_Mag_` token and the pile less the lent rounds (`card.zs:304-317`); with that
   off, the pile alone (`card.zs:324`, `:337`). Any other class: the Ammo2 pile when there is one that is not Ammo1, with
   Ammo1 as the reserve; else Ammo1 alone (`card.zs:320-353`).
6. **Small card shown**: not checking the watch, a gun, and `Wanted` (always, at the default) (`card.zs:951`,
   `card.zs:707-711`); drawn at `card.zs:1054` by `Draw`, which first asks `McUse` (`card.zs:1176`).
7. **`McUse`**: main hand, the layers' owner is `RSQGC_CardItem`: yes for every gun. Off hand, the owner is the
   off-hand weapon itself and its class name must be in a loaded `RSQGCOFF` lump (`modelcard.zs:31-49`, `:52-60`;
   owner set at `card.zs:1003`). Repo A's lump is `src/RSQGCOFF.rsq` (66 names, lines 3-68) with the blocks in
   `src/MODELDEF.rsqgc` (the same 66 classes).
8. **Watch card shown**: checking the watch and (a gun, or an item, or an empty hand) (`card.zs:951`). A gun: the
   Weapon card (`card.zs:1048`, `Build` at `card.zs:1110`). The watch card's layers are set with the same owner
   (`side.zs:103-118`) but its pieces are voxels found by sprite name (`GunCards/VOXELDEF.txt:1-2`), so no per-class
   block is needed. With nothing in the off-hand slot the Status card is drawn in the world (`card.zs:1007-1012`).
9. **The off hand's check does not count** while the engine steadies the gun or the off hand lies on the gun's line
   (`card.zs:646-658`, `card.zs:924`). This is a pose rule, not a class rule.
10. **Names**: an `RSQ_Off_<gun>` goes by its gun's Tag (`card.zs:547-560`) and uses its gun's saved spot
    (`spots.zs:65-69`, `:73-81`). No other per-class table was found (`card.zs:845` is by weapon slot).

Resting on the engine (not in either repo): that `Ammo1` is set for a weapon that declares an AmmoType1, also at 0
rounds. Repo A relies on the same thing for the axe ("every display reads the count through the axe's Ammo1",
`zscript/rsvr/melee.zs:329`).

## 2.2 The table

"Sure?" is about the rule as written. Whether a class can reach the off hand at all is 1.1.

| Weapon | Hand | Small card | Watch card | Why not, file:line | Sure? |
|---|---|---|---|---|---|
| BrutalPistol, Revolver, BrutalRevolver, BrutalSMG, MP40, Rifle, Plasma_Gun, Shot_Gun, SSG, AssaultShotgun, RailGun (11) | main | yes: MAGAZINE, the Ammo2 pile big, Ammo1 as reserve | yes: Weapon | | certain |
| Sniper, Rocket_Launcher, GrenadeLauncher (3) | main | yes: MAGAZINE, Ammo2 big, Ammo1 reserve | yes: Weapon | | certain |
| MiniGun, MG42, Machinegun, Flamethrower2, Unmaker, Devastator, NukeLauncher, HellishMissileLauncher, IncendiaryLauncher (9) | main | yes: with VR reloading on, MAGAZINE from `RSQ_Mag_<gun>`; off, AMMO, the Ammo1 pile | yes: Weapon | | certain (`card.zs:304-317`; classes at `zscript/rsq/counters.zs:396-449` in Repo A) |
| BIG_FUCKING_GUN, FlameCannon (2) | main | yes: AMMO, the Ammo1 pile | yes: Weapon | | certain |
| HandGrenades | main | yes: AMMO, `GrenadeAmmo` | yes: Weapon | | certain |
| BrutalAxe | main | yes: AMMO, the `RSVR_Axes` count (it has an Ammo1, so it is a gun to Gun Cards, not an item) | yes: Weapon | | certain (`card.zs:329-337`; `actors/Weapons/Axe.dec:10`) |
| DualPistols, DualRifles, DualPlasmaRifles (3) | main | yes: MAGAZINE, Ammo2 big | yes: Weapon | | certain |
| Chain_saw | main | **no** | yes: item card, name from its Tag | no `Ammo1`, so `Loaded` answers -1 and the hand has no gun: `card.zs:331`, `card.zs:946`; no AmmoType in `actors/Weapons/Saw.dec:2-14` | certain |
| DSweap | main | **no** | yes: item card, "Dragonslayer" | the same; no AmmoType in `actors/Weapons/Dragonslayer.dec:5-14` | certain |
| Melee_Attacks | main | **no, if it has no AmmoType1; yes if it has one** | yes: Status (in place of a weapon card) | class name is an empty hand: `card.zs:273`. The small card's test never asks that: `card.zs:946-951` | watch card certain; small card depends on base Brutal Doom's `Melee_Attacks`, not seen |
| the 24 Purist copies | main | yes | yes: Weapon | for a Purist copy with an Ammo2 the big number is the Ammo2 pile, while the Purist branch read (Pistol) spends Ammo1: `actors/Weapons/Pistol.dec:318`, `:329-332`; `card.zs:335` | card certain; the count's worth depends on `IsPlayingAsPurist`, base Brutal Doom |
| the 13 `RSQ_Off_<gun>` copies | off | yes: all 13 are in `RSQGCOFF.rsq:3-15` | yes: Weapon, under the gun's name | | certain (the lump and blocks are generated: `RSQGCOFF.rsq:1-2`) |
| RSQ_Hands | off | **no** | yes: Status (in place of a weapon card) | class name is an empty hand: `card.zs:273`; no ammo lines (`zscript/rsq/hands.zs:274-292`) so `Loaded` is -1: `card.zs:331`; not in `RSQGCOFF.rsq` | certain |
| nothing in the off-hand slot | off | no | yes: Status, drawn in the world | `card.zs:1007-1012` | certain |
| BIG_FUCKING_GUN, Devastator, FlameCannon, Flamethrower2, GrenadeLauncher, HandGrenades, HellishMissileLauncher, IncendiaryLauncher, MG42, Machinegun, NukeLauncher, Rocket_Launcher, Sniper, Unmaker (14, no twin) | off | yes: in `RSQGCOFF.rsq:22-42` | yes: Weapon | | rule certain; reaching the off hand is the engine's or another mod's |
| the 13 table guns as their main class | off | yes: in `RSQGCOFF.rsq:16-30`, `:43` | yes: Weapon | held only until `RSQ_Dual.Hands` swaps the copy in (`zscript/rsq/dual.zs:231-296`) | certain |
| DualPistols, DualRifles, DualPlasmaRifles (3) | off | **no** | yes: Weapon | not in any `RSQGCOFF` lump, so `McUse` answers no: `modelcard.zs:52-60`; no block in `MODELDEF.rsqgc` | rule certain; reaching the off hand not seen |
| Chain_saw, DSweap (2) | off | **no** | yes: item card | no `Ammo1`: `card.zs:331`, `:946`; and not in `RSQGCOFF.rsq` | rule certain; reaching the off hand not seen |
| the 24 Purist copies | off | yes: all 24 in `RSQGCOFF.rsq:44-68` | yes: Weapon | | rule certain; reaching the off hand not seen |

## 2.3 What the table adds up to

- **No class has neither card.** Every weapon of Part 1 shows something on a watch check in each hand it can be in.
- **No small card, certain:** Chain_saw and DSweap (either hand), RSQ_Hands (off hand). **Depends on base Brutal
  Doom:** Melee_Attacks (main hand). **Only if they reach the off hand:** DualPistols, DualRifles, DualPlasmaRifles.
- **A watch card that is not the weapon's own:** Melee_Attacks and RSQ_Hands show the Status card.
- **Counts that may not be the rounds you can fire:** a Purist copy with an Ammo2 (above); the BrutalRevolver's
  reserve is `Clip1` items and one loaded round costs 3 (`zscript/rsr/rsb_guns.zs:13-15`); the Rifle's and the
  Machinegun's launcher round is a token and is on no card (`actors/Weapons/Rifle.dec:505-507`,
  `actors/Weapons/Machinegun.dec:276`).
- **The "pulse monster / start fight" card is not drawn by Gun Cards.** Gun Cards asks `RSQMB_Service` "fightcard.up"
  and hides the off hand's watch card while the answer is 1 (`card.zs:629-634`, `card.zs:975`). In the working tree
  (not committed) Gun Cards also reads a pulse check, the inside of the wrist, and answers it by name
  (`RSQGC_GCopyService` "pulse", `gestcopy.zs:391-395`, `:419`); that reader looks at the hand's pose only and names no
  weapon (no `ReadyWeapon`, `OffhandWeapon` or class name in `gestcopy.zs`). The card itself is RSQ Miniboss's and was
  not read, so nothing is said here about which weapons get it.

## 2.4 Does Repo A ask or answer Gun Cards or the series by name?

Asked of Gun Cards:
- `RSQGC_Service` GetDouble `"cnd.spread"` with the gun: a worn gun's spread, 1.0 without Gun Cards
  (`zscript/rsq/muzzle.zs:244-262`, used at `:125` and `:501`). This is the only call to Gun Cards in src.

Carried for Gun Cards (data, no call):
- `RSQGCOFF.rsq` (the off-hand class list), `MODELDEF.rsqgc` (the off-hand small card's blocks, 66 classes),
  `zscript/rsq/gcsprites.zs:1-3` (names the card's sprites), all three generated by Gun Cards' `gen_modelcard.py`
  (`RSQGCOFF.rsq:1-2`, `MODELDEF.rsqgc:1-6`; included at `ZSCRIPT.rsvr:42`).
- `rsq_hud_nohp`, `rsq_hud_noammo` (`CVARINFO.rsq:74-75`): read by `SBARINFO.rsq` (first at `:29` and `:76`; the
  header note is `:3`) and `zscript/rsq/bottomhud.zs:80`. Gun Cards' menu switches them; src only reads them.

Not found in src (grep): `RSQG_Service`, `"inspect"` as a service request, any `"cnd."` request other than
`"cnd.spread"`, any answer to `RSQGC_*`. "pulse" appears only in comments about other things
(`zscript/rsq/ballistics.zs:70`, `zscript/rsld/g3_fx.zs:459`, `:635-637`).

Asked of other series mods, by name:
- `RSQMB_Service` "bossfight", "tier", "wasboss", "bossfights" (`zscript/rsld/handler.zs:843-850`, `:885-886`).
- `RSQSM_Service` "scale" (`zscript/rsg/grenade.zs:61-63`), "down.target" (`zscript/rsld/handler.zs:852-862`).
- `RSQTR_RigService` "pouch.at" (`zscript/rsr/vreload.zs:103-106`), "nade.at" (`zscript/rsr/rsr_m203.zs:150-153`).
- `RSQGN_Service` "kind", "kind.next", "kind.word", "kind.share", "burst" (`zscript/rsr/rsr_m203.zs:122-143`, `:291`, `:694`, `:702`).
- `RSQML_Service` "owns" (`zscript/rsvr/yield.zs:23-24`).
- `RSQA_Service` "buzz" (`zscript/rsvr/melee.zs:1528-1533`).

Answered by Repo A (services it defines):
- `RSQ_BD22OffhandService`: "main.of", "off.of", "is.off", "equip" (`zscript/rsq/dual.zs:523-568`).
- `RSVR_AxeGrabEventService`: "grab.event" (`zscript/rsvr/axegrab.zs:533-537`).
- `RSVR_MeleeService`: "punch.record" (`zscript/rsvr/yield.zs:35-39`).
- `RSM_LauncherService` (`zscript/rsr/rsr_m203.zs:748`; its requests were not read).
- `RSLDP_Service`: "ld_prefix" (`zscript/rsld/handler.zs:1534-1553`).
- `RSLD_KioskService`: "ready", "give", "kiosk.take", "roll", "roll.kiosk", "yours", "stats", "yours.stats", "yours.desc", "raise" (`zscript/rsld/kiosk.zs:43`, `:198-200`, `:313-325`).

---

# What would have to change for every weapon to have both cards

Causes only, with the classes each one holds back.

1. **A weapon with no `Ammo1` is never a gun to the small card** (`card.zs:331`, `card.zs:946`): Chain_saw, DSweap. 2 classes, both hands.
2. **The two fists are named as empty hands** (`card.zs:273`), so their watch card is the Status card and (for `RSQ_Hands`, which also has no `Ammo1`) there is no small card: Melee_Attacks, RSQ_Hands. 2 classes. The owner said these may not need a small card.
3. **The small card's test does not ask whether the hand is empty** (`card.zs:946-951`), so whether Melee_Attacks has a small card today is decided by an ammo line in base Brutal Doom that was not seen. 1 class.
4. **The off hand's small card needs the class in an `RSQGCOFF` lump and its blocks in the gun's own pack** (`modelcard.zs:52-60`). Not listed in Repo A's lump: Chain_saw, DSweap, RSQ_Hands, DualPistols, DualRifles, DualPlasmaRifles. 6 classes (2 of them already held back by cause 1, 1 by cause 2). `Melee_Attacks` and `BFG10k` are base Brutal Doom's; `BFG10k` is listed (`RSQGCOFF.rsq:41`), `Melee_Attacks` is not.
5. **The count comes from the ammo piles alone** (`card.zs:320-353`): on the 13 Purist copies that have an Ammo2 the big number is a pile the Purist branch read does not spend; the launcher round of the Rifle, RSQ_Off_Rifle and Machinegun is a token no card reads. Up to 16 classes; no card is missing, the number is what is in doubt.
6. **The pulse / start fight card is drawn by another mod** (`card.zs:629-634`; the pulse check Gun Cards answers, `gestcopy.zs:391-395`, reads the pose and no weapon): which weapons have the card cannot be said from Gun Cards or Repo A. All classes; not read.
