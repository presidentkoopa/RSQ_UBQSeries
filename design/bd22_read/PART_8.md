# BD22 VR Reloaded bug read, part 8: the DECORATE lumps in src/ (off-hand twins and the rest) (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

Paths are relative to the repo root. "rsqdual" is short for `src/DECORATE.rsqdual`, "rsqdualmg" for
`src/DECORATE.rsqdualmg`. Base Brutal Doom (brutal22test6.pk3) is not in the repo: every token or class marked
"base BD" below could not be opened.

## Files read
| file | lines | read to the end? |
|---|---|---|
| src/DECORATE.rsqdual | 7,443 | yes, with Read, in ten consecutive chunks (1-699, 700-1499, 1500-2349, 2350-3199, 3200-4049, 4050-4749, 4750-5449, 5450-6169, 6170-6849, 6850-7443) |
| src/DECORATE.rsqdualmg | 567 | yes, with Read, in one piece |
| src/DECORATE.rsqbash | 2 | yes (two comment lines; shown with `cat -n`, not Read) |
| src/DECORATE.rsqmg | 2 | yes (one comment, one `#include "actors/Weapons/Machinegun.dec"`; `cat -n`) |
| src/DECORATE.rsqmoon | 2 | yes (one comment, one `#include "actors/Weapons/BrutalRevolver.dec"`; `cat -n`) |
| src/DECORATE.rsm (not in this part; read because rsqdual fires its class) | 36 | yes (`cat -n`) |

Read outside the part, to confirm or kill a suspicion (not whole files unless said):
`src/actors/Weapons/BrutalRevolver.dec` 36-365 (whole of both actors; the Silvergun's twin lives there),
`src/actors/Weapons/Axe.dec` 2-56, 278-290, 455-509 (the axe's twin lives there), `DEFAULTWEAPON.dec` 1-30, 209-229,
391-425, 601-612, 634-682, `Pistol.dec` 20-34, 456-462, `SubMachinegun.dec` 62-76, 396-404, `Shotgun.dec` 38-51,
105-124, `Rifle.dec` 436-460, 604-612, `Railgun.dec` 441-452, `Minigun.dec` 3-19, 597-621,
`src/zscript/rsq/dualtable.zs` (whole, 53), `dual.zs` 150-200, 318-400, 476-510, `flick.zs` 300-454,
`counters.zs` 212-232, 345-380, `muzzle.zs` 70-92, `src/zscript/rsr/vreload.zs` 826-925, 1080-1100,
`rsr_break.zs` 1140-1153, `rsr_pump.zs` (grep only), `BUGS_FROM_CODE_READ_2026-11-24.md` (whole, 74).

How the two sides were compared: after the line-by-line read, each twin's actor block was put beside its main-hand
actor block with the magazine name made the same, and every line that still differed was listed (a throwaway script
kept outside the repo; whitespace and case ignored). So "the same" below means the same text, state for state. A second
script checked every `Goto`, every state name in an `A_Jump*` / `A_ReFire` / `A_GunFlash`, every inventory name and
every class name in the twins against the twin, its main-hand actor, `BrutalWeapon`, and every `actor` / `class` in
`src/`.

## The twin table

### A. Every weapon class in src/actors/Weapons and its off-hand twin
The table the code uses is `src/zscript/rsq/dualtable.zs` 4-33: 13 rows (`COUNT = 13`). `dual.zs` 106-119 matches the
exact class name, so a `Purist...` subclass never has a twin, and nothing expects one. `grep -ri sisterweapon src`
finds nothing: no weapon names a sister.

| main-hand class (file:line) | twin (file:line) | twin's magazine (max) | Dual Options cvar (default) |
|---|---|---|---|
| BrutalPistol (Pistol.dec:2) | RSQ_Off_BrutalPistol (rsqdual:15) | BDPistolAmmoOff (16), rsqdual:6 | rsq_dual_pistol (on) |
| Revolver, the Shotvolver (Revolver.dec:2) | RSQ_Off_Revolver (rsqdual:652) | RevolverAmmoOff (6), rsqdual:643 | rsq_dual_revolver (on) |
| BrutalSMG (SubMachinegun.dec:2) | RSQ_Off_BrutalSMG (rsqdual:1196) | BDSMGAmmoOff (41), rsqdual:1187 | rsq_dual_smg (on) |
| MP40 (Mp40.dec:2) | RSQ_Off_MP40 (rsqdual:1843) | MP40AmmoOff (32), rsqdual:1834 | rsq_dual_mp40 (on) |
| Rifle (Rifle.dec:2) | RSQ_Off_Rifle (rsqdual:2518) | RifleAmmoOff (31), rsqdual:2509 | rsq_dual_rifle (on) |
| Plasma_Gun (Plasma.dec:2) | RSQ_Off_Plasma_Gun (rsqdual:3484) | PlasmaAmmoOff (50), rsqdual:3475 | rsq_dual_plasma (on) |
| Shot_Gun (Shotgun.dec:3) | RSQ_Off_Shot_Gun (rsqdual:4250) | ShotgunAmmoOff (9), rsqdual:4241; chamber token RSQ_ShotgunWasEmptyOff, rsqdual:4239 | rsq_dual_shotgun (off) |
| SSG (SSG.dec:2) | RSQ_Off_SSG (rsqdual:5281) | SSGAmmoOff (2), rsqdual:5272 | rsq_dual_ssg (off) |
| AssaultShotgun (AssaultShotgun.dec:2) | RSQ_Off_AssaultShotgun (rsqdual:5888) | AssaultShotgunAmmoOff (20), rsqdual:5879 | rsq_dual_asg (off) |
| RailGun (Railgun.dec:2) | RSQ_Off_RailGun (rsqdual:6698) | RailgunAmmoOff (5), rsqdual:6689 | rsq_dual_railgun (off) |
| BrutalRevolver, the Silvergun (BrutalRevolver.dec:47) | RSQ_Off_BrutalRevolver (BrutalRevolver.dec:263) | BrutalRevolverCylinderOff (6), BrutalRevolver.dec:254 | rsq_dual_moonlight (on) |
| BrutalAxe (Axe.dec:2) | RSQ_Off_BrutalAxe (Axe.dec:455) | none ('None', 0: the axes are one count, RSVR_Axes) | rsq_dual_axe (on) |
| MiniGun (Minigun.dec:3) | RSQ_Off_Minigun (rsqdualmg:21) | MinigunAmmoOff (200), rsqdualmg:5; spin token RSQ_SpinOff, rsqdualmg:14 | rsq_dual_minigun (on) |

The magazine sizes in `dualtable.zs` 23 (16, 6, 41, 32, 31, 50, 9, 2, 20, 5, 6, 0, 200) agree with the twins' `Ammo`
actors. The main-hand magazines that are in the repo agree too (RevolverAmmo 6 Revolver.dec:535, RifleAmmo 31
Rifle.dec:983, ShotgunAmmo 9 Shotgun.dec:1031, AssaultShotgunAmmo 20 AssaultShotgun.dec:803,
BrutalRevolverCylinder 6 BrutalRevolver.dec:41); BDPistolAmmo, BDSMGAmmo, MP40Ammo, PlasmaAmmo, SSGAmmo and
RailgunAmmo are base BD and could not be compared.

Weapon classes with NO twin, and whether anything expects one (no row in `dualtable.zs` for any of them):

| class (file:line) | twin | does the code expect one? |
|---|---|---|
| BrutalWeapon (DEFAULTWEAPON.dec:1) | none | no: the parent of all |
| DualPistols (DualPistol.dec:1), DualRifles (DUalRifle.dec:1), DualPlasmaRifles (DualPlasma.dec:1) | none | no: BD22's own two-gun weapons; the twins' Select states take them away (rsqdual:154, 2676, 3675) |
| Rocket_Launcher (RocketLauncher.dec:2) | none | no table row, but the file tests the off-hand layer 32 times (`OverlayID() == 1000000`): off-hand branches with no off-hand class to run them |
| Sniper (Sniper.dec:2) | none | as above: 48 off-hand tests, no twin |
| GrenadeLauncher (GrenadeLaunch.dec:2) | none | as above: 6 off-hand tests, no twin |
| BIG_FUCKING_GUN (BFG.dec:1), Chain_saw (Saw.dec:2), FlameCannon (FlameCannon.dec:1), DSweap (Dragonslayer.dec:5) | none | no (1 off-hand test each) |
| Devastator, Flamethrower2, HandGrenades, HellishMissileLauncher, IncendiaryLauncher, MG42, Machinegun, NukeLauncher, Unmaker | none | no (no off-hand test in the file) |
| every Purist... subclass (24 of them, e.g. PuristPistol Pistol.dec:633) | none | no: `dual.zs` 374 says "the gun itself (not BD22's Purist subclass)" |

Those files are parts 1 and 2; the counts are from `grep -c 1000000`, the files were not read here.

### B. What every twin in rsqdual has that its main-hand gun has not (all meant)
| difference | twin side | main side | meant? |
|---|---|---|---|
| `Tag "Off-hand ..."` in place of BD22's `$TAGBD_...` | e.g. rsqdual:17 | e.g. Pistol.dec:12 | meant |
| `Weapon.AmmoGive1 0`, `Weapon.AmmoGive2 0` | e.g. rsqdual:18-19 | not set (parent's 0) | meant |
| `Weapon.SelectionOrder 99999` | e.g. rsqdual:20 | e.g. Pistol.dec:6 (1900) | meant |
| `+WEAPON.OFFHANDWEAPON`, `-WEAPON.NOHANDSWITCH`, `+WEAPON.CHEATNOTWEAPON` | e.g. rsqdual:21-23 | not set | meant |
| `Weapon.AmmoType2` is the twin's own magazine; AmmoType1 (the reserve) is the same | e.g. rsqdual:25-26 | e.g. Pistol.dec:4-5 | meant |
| every muzzle glow is spawned with `SXF_SETTRACER` | e.g. rsqdual:353 | e.g. Pistol.dec:342 | meant (muzzle.zs 78-85) |
| the magazine name in every state | whole block | whole block | meant |

Inputs: the same on both sides, because both sides carry the same test, e.g. rsqdual:2766 = Rifle.dec:244:
main layer `FiredPrimary` / `FiredSecondary` / `Reloading`; off layer (`OverlayID() == 1000000`) button bits 67108864
(primary; BrutalRevolver.dec:314 calls it BT_OFFHANDATTACK) and 134217728 (secondary). The Reload key's token is read
only on the main layer, so the off hand reloads only when `flick.zs` 437-446 puts it in `Reload`.

### C. Twin by twin: every remaining difference
Damage, ammo use, spread and tics were read on the twin's lines; "same" means the main-hand lines are the same text.

| twin | damage | ammo type and use | fire rate (tics, counted) | spread | sounds | states present | differences left, file:line both sides | meant or drift |
|---|---|---|---|---|---|---|---|---|
| RSQ_Off_BrutalPistol | same: 1 x 14 (rsqdual:356 = Pistol.dec:345) | same: 1 from the magazine a shot, Clip1 to refill; also takes BDDualPistolAmmo (rsqdual:333-334 = Pistol.dec:322-323) | same: 11 to the refire (A1 B1 C1 D1 E1 E3 E3, rsqdual:356-377) | same (1, 1) | same | same labels | (1) the 2026-10-23 "empty magazine must be changed" lines are missing: Pistol.dec:25-32 vs rsqdual:42-45; (2) the held-rounds jump is missing: Pistol.dec:460 vs rsqdual:470-471; (3) `RSLD_AltDownOff` for `RSLD_AltDown`: rsqdual:558 vs Pistol.dec:548 | (1)(2) drift, harmless today (B8.14); (3) meant |
| RSQ_Off_Revolver | same: 7 x 22 + 2 x 22 (+ 5 x 22 Tactical); slug 1 x 200 (rsqdual:924-927, 971) | same: 1 RevolverAmmoOff, AmmoShell to refill | same: 24 (12 of shot, 12 of hammer, rsqdual:924-949) | same | same | same labels | only a comment (rsqdual:941-944 vs Revolver.dec:285-286) | meant. Shares NeedToHammer with the main gun: B8.1 |
| RSQ_Off_BrutalSMG | same: 1 x 12 | same | same: 3 a round (2 Tactical), rsqdual:1566-1572 | same (6, 3; aimed 3, 2) | same | same labels | (1) SubMachinegun.dec:23-30 missing at rsqdual:1222-1224; (2) `RSR_FillB` still gives `RSR_Charge`: rsqdual:1259 vs SubMachinegun.dec:66-73; (3) held-rounds jump missing: SubMachinegun.dec:491 vs rsqdual:1677-1678 | all drift, harmless today (B8.14) |
| RSQ_Off_MP40 | same: 1 x 18 | same (Mauser9mm) | same: 4 a round, rsqdual:2213-2219 | same (3, 1.5; aimed 1.5, 1.5) | same | same labels | held-rounds jump missing: Mp40.dec:437 vs rsqdual:2283-2284 | drift, harmless today (B8.14) |
| RSQ_Off_Rifle | same: 1 x 20 | same (Clip2); launcher: its own round RSM_LoadedOff, fired by RSM_FireOff on both sides | same: 4 a round (3 Tactical), rsqdual:2870-2886 | same (1.0; aimed 0.2) | same | same labels | (1) the main-layer launcher branch lacks RSM_KindLoaded / RSM_KindRound: Rifle.dec:455-458, 473-476 vs rsqdual:2977, 2992; (2) the Purist line is after the launcher jump: rsqdual:3124-3125 vs Rifle.dec:608-609; (3) held-rounds jump missing: Rifle.dec:795 vs rsqdual:3310-3311; (4) the purist notes Rifle.dec:960-962 are the main file's own | (1) drift, never reached in the off hand (rsqdual:2959 jumps away first); (2) drift, only for a Purist with a twin, which dual.zs does not give; (3) drift, harmless today |
| RSQ_Off_Plasma_Gun | same (Plasma_Ball; alt 10 x PlasmaBall75) | same (AmmoCell); `-WEAPON.NOAUTOFIRE` on both | same: 4 a ball, rsqdual:3893-3906 | same | same | same labels | (1) `RSLD_AltDownOff`: rsqdual:3919 vs Plasma.dec:431; (2) held-rounds jump missing: Plasma.dec:651 vs rsqdual:4138-4139 | (1) meant; (2) drift, harmless today |
| RSQ_Off_Shot_Gun | same pellets and damage (4 x 13 + 5 x 13, + 5 x 13 Tactical; slug 1 x 150) | same (AmmoShell) | same: 13 of shot + 21 of pump, rsqdual:4729-4772 | **differs with Pump Spread = Enhanced**: main 3.0 / 2.5 on every volley (Shotgun.dec:483-486, 532-535, 615-618, 655-658), twin always 5 / 1, 2.5 / 2.5, 6 / 3 (rsqdual:4729-4732, 4778-4781, 4861-4864, 4901-4904) | same | main has `RSP_NoCase` (Shotgun.dec:45-50), the twin has not | (1) the spread, above; (2) its own chamber token RSQ_ShotgunWasEmptyOff for ShotgunWasEmpty (36 lines, e.g. rsqdual:4721 vs Shotgun.dec:475); (3) the 2.0.3q / 2.0.3y "no spent shell when you pump a gun loaded from empty" lines are missing: Shotgun.dec:41-50, 109, 119 vs rsqdual:4293-4294, 4353, 4363-4365; (4) `Game Doom` / `SpawnID 27` copied: rsqdual:4260-4261 = Shotgun.dec:5-6 | (1) drift: B8.5; (2) meant (2.0.5u); (3) drift, harmless today; (4) drift: B8.11 |
| RSQ_Off_SSG | same (both barrels 1 x 40 + 9 x 13 + 9 x 13, + 10 x 13 Tactical; one barrel 9 x 13, + 5 x 13) | same | same: 11 after both barrels (Tactical 26), rsqdual:5541-5559 | same | same | the twin has its own `RSQ_FlickReload`, `RSQ_FlickLoadOne`, `RSQ_FlickShut` (rsqdual:5343-5368) in place of the main gun's (SSG.dec:61 on) | (1) the flick reload on SSGAmmoOff; (2) `Game Doom` / `SpawnID 33` copied: rsqdual:5291-5292 = SSG.dec:4-5 | (1) meant (2.0.5u); (2) drift: B8.11. Shares SSGLoaded / SSGAlt with the main gun: B8.9 |
| RSQ_Off_AssaultShotgun | same (9 x 11, + 5 x 13 Tactical; slug 1 x 150) | same | same: 6 a shell, rsqdual:6165-6179 | same (5, 5) | same | same labels | held-rounds jump missing: AssaultShotgun.dec:478 vs rsqdual:6369-6370 | drift, harmless today |
| RSQ_Off_RailGun | same (rail 400 + RailgunProjectile) | same (10 AmmoCell a round) | same: 43, rsqdual:6984-7007 | same | same | **the twin has no swallow `AltFire` and no `ZoomAltFire` label**: its `AltFire` is still the zoom (rsqdual:7122-7150); main: Railgun.dec:442-446 swallow, 448 `ZoomAltFire` | (1) AltFire, above; (2) held-rounds jump missing: Railgun.dec:616 vs rsqdual:7289-7290 | (1) drift: B8.3; (2) drift, harmless today |
| RSQ_Off_Minigun | same: 1 x 20 a round | **meant to differ**: each shot takes 1 MinigunAmmoOff by `A_TakeInventory` and the bullets no longer use ammo (`FBF_USEAMMO` dropped): rsqdualmg:290-291 vs Minigun.dec:308; `Weapon.AmmoType1 "RSQ_MinigunAmmo"`, `AmmoType2 "MinigunAmmoOff"`, `AmmoUse2 0` (rsqdualmg:31-33) vs `AmmoType "RSQ_MinigunAmmo"`, `AmmoUse 1`, `AmmoGive 200`, `+ALT_USES_BOTH`, `-AMMO_CHECKBOTH` (Minigun.dec:7-12) | same: 3 a round (1 or 2 Tactical), 2 a round spun up; rsqdualmg:291-298, 434-440 = Minigun.dec:308-315, 456-462 | same (3, 2) | same | the twin has `RSQ_OffFill` (rsqdualmg:44-50) and none of the main gun's hand-reload states `RSR_Start`, `RSQ_StockFill`, `RSR_Out`, `RSR_Wait`, `RSR_Fill`, `RSR_Done` (Minigun.dec:31-65: it still inherits them, unused) | (1) `Spin` -> `RSQ_SpinOff` (rsqdualmg:60 on vs Minigun.dec:76 on); (2) `A_JumpIfNoAmmo` -> `CountInv("MinigunAmmoOff") < 1` (rsqdualmg:57 on vs Minigun.dec:73 on); (3) no "magazine empty -> Reload" jump in the fire loop (Minigun.dec:297, 307 ... vs rsqdualmg:280 on): empty, it clicks; (4) the muzzle glows have NO `SXF_SETTRACER`: rsqdualmg:287, 307, 326, 389, 407, 430, 448, 465, 494, 510; (5) no `Game Doom` / `SpawnID 28` (Minigun.dec:5-6) | (1)(2)(3)(5) meant; (4) drift: B8.6 |
| RSQ_Off_BrutalRevolver | same: 1 x 100 (BrutalRevolver.dec:308 = 140) | same: 1 from the cylinder a shot, 3 Clip1 a shot to refill (355-356 = 194-195) | same: 7 at the fastest, 15 the whole cycle (301-329 = 133-161) | same (1, 1) | same | written by hand: its own Ready, RSQ_SemiWait, Fire, NoAmmo, Reload, RSB_Stock, Fill, Shut; inherits Select, Deselect and the RSB_* hand-reload states (never entered: 343 goes straight to RSB_Stock) | (1) reads the off trigger bit and `RSQ_SemiLockOff` (296, 314-328 vs 123, 146-160); (2) Ready reads no Reloading, FiredPrimary, Salute, TossGrenade (279-284 vs 101-111); (3) empty: no reload by itself (332-336 vs 164-171); (4) Reload gives no `Pumping` and takes no `Reloading` (338-343 vs 173-181); (5) `-INVENTORY.ALWAYSPICKUP` (272 vs 63); (6) the muzzle glow has NO `SXF_SETTRACER` (305 vs 137) | (1)-(5) meant (277-278 says so); (6) drift: B8.6 |
| RSQ_Off_BrutalAxe | the main axe's swing (`Goto Super::Fire`, Axe.dec:481) | none: one count, RSVR_Axes, AmmoGive1 0 (Axe.dec:458) | the main axe's | n/a | same draw sound | written by hand: Select, SelectLoop, Deselect, Ready, Fire, AltFire = Reload (one idle tic), OffTrigGrip, OffTrigGripHold, OffAxeThrown, OffAxeGone, OffAxeRearm (Axe.dec:466-507) | its own VR throw tokens RSVR_OffAxe... (479-506 vs 43-70); Ready reads nothing but the trigger (474-477 vs 176 on); no kick, sprint or taunt | meant |

## Findings, worst first

## B8.1: Two Shotvolvers: a trigger tap on one gun while the other is cocking gives a hammer click and no shot
- Kind: wrong behaviour
- Where: rsqdual:899, 937, 945-952, 884 (twin); the same lines in Revolver.dec (its Fire, Hammering and Ready; not in
  the difference list, so the same text); `src/zscript/rsq/dual.zs` 157-174
- What the code does: both guns use ONE token, `NeedToHammer`. A shot gives it 9 tics after the trigger (rsqdual:937)
  and the gun's own hammer frames take it 15 tics later (rsqdual:949). `Fire` on either gun, before it takes a round,
  jumps to `Hammering` if the token is there (rsqdual:899): 12 tics of hammer, then `A_Refire` (rsqdual:951).
- Why it is wrong: for about 15 tics after either gun fires, the other gun's trigger starts the hammer animation in
  place of a shot. If the trigger is still held 12 tics later it fires then; a tap fires nothing. That hammer also
  takes the token while the first gun is still cocking. `Ready` on the idle gun shows its uncocked frame K for those
  tics (rsqdual:884). This is the fault 2.0.5u fixed for the pump Shotgun by giving the twin its own token
  (rsqdual:4236-4239); the Shotvolver was left on the shared one. The comment at rsqdual:941-944 already describes one
  hang this token caused.
- Checked: `NeedToHammer` is not defined in `src/` (base BD; assumed to hold at most 1). `dual.zs` SwapMags moves only
  the magazine and the shotgun's chamber token. Nothing in `src/zscript` gives or takes `NeedToHammer` per hand.
- Sure?: likely. The shared token and the jump are certain; what is not seen is base BD's definition of the token. A
  rig trace of both triggers pulled 10 tics apart settles it.
- Fix A: give the twin its own token (`ACTOR RSQ_NeedToHammerOff : bd_Token {}`), replace `NeedToHammer` in
  RSQ_Off_Revolver (13 lines: rsqdual:710, 751, 760, 766, 773, 848, 858, 884, 899, 937, 949, 1103, 1173), and swap it
  in `dual.zs` SwapMags as the shotgun's is. About 20 lines, 2 files.
- Or intended: only if two Shotvolvers are meant to be fired strictly one after the other.
- Already known?: no

## B8.2: With a gun in each hand, one kick press lands two kicks
- Kind: wrong behaviour
- Where: every generated twin's Ready loop reads `Kicking` with no hand test and jumps to `DoKick`: rsqdual:235, 877,
  1361, 2068, 2753, 3653 and 3720, 4622, 5472, 6049, 6890; rsqdualmg:150; BrutalRevolver.dec:281. The kick itself:
  `src/actors/Weapons/DEFAULTWEAPON.dec` 391-424
- What the code does: `DoKick` fires `KickAttack` (DEFAULTWEAPON.dec:417) and takes `Kicking` only at its end, 16 tics
  later (DEFAULTWEAPON.dec:420). The main gun's Ready loop and the off twin's Ready loop both see the token on the same
  tic, so both run `DoKick`: two `KickAttack`s, two kick sounds, two leg flashes, `SetPlayerProperty` frozen and
  thawed twice.
- Why it is wrong: one press, double the kick's damage, only because the off hand holds a gun.
- Checked: `DoKick` has no hand test (the only two off-layer tests in DEFAULTWEAPON.dec are at 220 and 241, in
  `NoAmmo`). `Taunt` and `TossGrenade` take their token in their first state (DEFAULTWEAPON.dec:603, 635), so only the
  first layer to run does those. The off-hand Silvergun's Ready reads `Kicking` on purpose (BrutalRevolver.dec:281),
  so the off gun stepping aside for a kick looks wanted; the second attack does not. Who gives `Kicking` is base BD.
- Sure?: likely. Certain in the weapon states; unsure only whether base BD's key gives the token in a way that the off
  layer cannot see. A rig count of `KickAttack` actors on one press settles it.
- Fix A: in `DoKick`, skip the attack on the off layer: before DEFAULTWEAPON.dec:417 add
  `"####" A 0 A_JumpIf(OverlayID() == 1000000, 2)`, and the same before the `BerserkerKick` jump at 416 (2 lines,
  1 file; the air kick and slide branches need the same line).
- Fix B: make the twins wait instead of kicking: one shared state in `BrutalWeapon` that holds the gun while `Kicking`
  is set, and point the twins' 13 `DoKick` jumps at it.
- Or intended: if a kick with two guns out is meant to hit twice.
- Already known?: no

## B8.3: The off-hand Railgun's secondary button still zooms and switches the light-amp on; the main Railgun's does nothing
- Kind: drifted copy, wrong behaviour
- Where: rsqdual:6908, 7006 (the jumps), 7122-7150 (`AltFire`), 7140 and 7154 (`PowerLightAmp`), 7129
  (`A_ZoomFActor(5.0)`), 7131 (`RAIL_ZM`); main: `src/actors/Weapons/Railgun.dec` 420-446
- What the code does: on 2026-10-23 and 10-28 the main Railgun's `AltFire` became a one-tic swallow and the old zoom
  was kept under the name `ZoomAltFire` (Railgun.dec:442-448). The twin was not regenerated: its `AltFire` is the old
  zoom. The off secondary button (bit 134217728) gives `Zoomed`, sets the crosshair to 41, calls `A_ZoomFactor(5.0)`,
  plays `ads/in` and `RAIL_ZM`, and gives `PowerLightAmp`.
- Why it is wrong: the two hands answer the same button differently, and the owner's note at Railgun.dec:424-430 says
  secondary fire on this weapon is deliberately free. `Zoomed` is one token for both hands, so the main gun reads it
  too (B8.7).
- Checked: `src/zscript/rsq/scope_real.zs` and `scope.zs` have no off-hand branch (grep for offhand, RSQ_Off_RailGun,
  the button bit: nothing). Dual Railgun is off by default (`src/CVARINFO.rsqdual` 13), so only players who turn it on
  meet this. What a 5x `A_ZoomFactor` does in the headset on QuestZDoom was not checkable.
- Sure?: certain that the twin differs; unsure how much of it shows in VR.
- Fix A: in RSQ_Off_RailGun rename `AltFire:` (rsqdual:7122) to `ZoomAltFire:` and add the main gun's swallow in front
  of it (`AltFire:` / take `ZoomHold` / `RAIL A 1 A_WeaponReady(WRF_NOSECONDARY)` / `Goto Ready`): 5 lines, 1 file.
- Or intended: if the off-hand Railgun is meant to keep BD22's zoom.
- Already known?: no

## B8.4: Moving with a gun in each hand tires you twice as fast and plays every footstep twice
- Kind: wrong behaviour
- Where: every twin's `StartSprint` / `Sprinting`: rsqdual:248-288, 997-1031, 1473-1508, 1958-1993, 2628-2664,
  3787-3843, 5012-5047, 5691-5727, 6624-6659, 7378-7419; rsqdualmg:176-213; entered from Ready, e.g. rsqdual:244
- What the code does: while `IsRunning` is set, the main gun and the off twin each run their own `Sprinting` loop.
  Each loop gives `UsedStamina` twice a cycle (e.g. rsqdual:262 and 277: 2 + 3), spawns a `FootStep` (rsqdual:278),
  runs ACS 852 "Makes player faster" (rsqdual:260) and nods the view 3.5 degrees down and up (rsqdual:266-285).
- Why it is wrong: stamina fills at twice the rate, so `StopSprintTired` comes in half the time; footsteps double; the
  view nod is applied by both layers. The note at rsqdual:3718 says "moving in VR is BD22's sprint", so this is every
  walk, not only a sprint.
- Checked: nothing in `src/zscript` reads or refunds `UsedStamina` or `IsRunning` (grep: no hit). The off-hand
  Silvergun and axe do not sprint (BrutalRevolver.dec:279-284, Axe.dec:474-477), so they are free of it. What ACS 852
  does when run twice is base BD.
- Sure?: likely. Both loops giving the token is certain; whether base BD gives `IsRunning` while a twin is out could
  not be seen. Watching `UsedStamina` with one gun and with two settles it.
- Fix A: in each twin's `Sprinting`, guard the three shared effects with the layer: the two `UsedStamina` gives, the
  `FootStep` spawn and the ACS call (4 lines a twin, 11 twins, 2 files), e.g.
  `A_JumpIf(OverlayID() == 1000000, 2)` in front of each.
- Fix B: take the `IsRunning` jump out of the twins' Ready loops (the off gun then stays in Ready while you move, and
  can fire on every tic).
- Or intended: no.
- Already known?: no

## B8.5: "Pump Spread: Enhanced" changes the main-hand Shotgun only; the off-hand Shotgun keeps BD22's wide pattern
- Kind: drifted copy, setting or menu
- Where: main `src/actors/Weapons/Shotgun.dec` 483-486, 532-535, 615-618, 655-658; twin rsqdual:4729-4732, 4778-4781,
  4861-4864, 4901-4904; the option `src/MENUDEF.rsq` 131, `src/CVARINFO.rsx` 17
- What the code does: the main gun reads `GetCVar("rsq_pump_spread")` in each volley (3.0 / 2.5 when it is 1). The
  twin has the plain numbers 5 / 1, 2.5 / 2.5 and 6 / 3.
- Why it is wrong: with the option on, the two hands' shotguns throw different patterns.
- Checked: `rsq_pump_spread` is a `server int`, default 0, so stock play is equal. Damage and pellet counts are equal.
- Sure?: certain.
- Fix A: copy the 12 `A_FireBullets` lines from Shotgun.dec into the twin (12 lines, 1 file).
- Or intended: no.
- Already known?: no

## B8.6: The off-hand Minigun's and the off-hand Silvergun's muzzle glow appears on the MAIN gun
- Kind: drifted copy, wrong behaviour
- Where: rsqdualmg:287, 307, 326, 389, 407, 430, 448, 465, 494, 510; `src/actors/Weapons/BrutalRevolver.dec` 305;
  the reader `src/zscript/rsq/muzzle.zs` 78-87
- What the code does: `muzzle.zs` puts a `PlayerMuzzle...` glow on the off gun only when its tracer is the pawn
  (`offGlow = c.tracer == mo`), which the copies in rsqdual arrange with `SXF_SETTRACER` (rsqdual:4-5). These two
  twins, made later by other means, spawn the glow with the main gun's plain call.
- Why it is wrong: a dual pair of Miniguns or Silverguns flashes twice on the right and never on the left, the fault
  the owner reported on 2026-11-17 and 2.0.5c fixed for the other ten.
- Checked: all 19 glow spawns in rsqdual have the flag; none of the 10 in rsqdualmg and not the one in
  BrutalRevolver.dec:305.
- Sure?: certain from the code.
- Fix A: add `,0,0,0,0,SXF_SETTRACER` to those 11 spawns (and to `tools/dual_minigun/gen_off_minigun.py`, which is
  not in this part): 11 lines, 2 files.
- Or intended: no.
- Already known?: no

## B8.7: Aiming the off-hand MP40, Shotgun, Assault Shotgun or Railgun puts the MAIN gun into its aimed mode too
- Kind: wrong behaviour
- Where: givers in the twins: rsqdual:2077 -> 2086-2093 (MP40), 4641 -> 4917-4926 (Shotgun, when the slug option is
  off), 6064 -> 6282-6290 (Assault Shotgun, when its slug option is off), 6908 -> 7122-7127 (Railgun). Readers, the
  same lines in the main files: Ready `Zoomed -> Ready2` (rsqdual:2754 = Rifle.dec:232; 1358, 2066, 4630, 6056, 6888)
  and Fire `Zoomed` (rsqdual:2830, 1530, 2179, 4691, 6127, 6949)
- What the code does: `Zoomed`, `ZoomHold` and `ADSmode` are single tokens. The off twin's secondary button gives
  them. The main gun's Ready loop then goes to its aimed loop and its Fire takes the aimed branch: for the Rifle that
  is spread 0.2 in place of 1.0 and a 10-tic wait after the refire (rsqdual:2917, 2940 = the same lines in Rifle.dec).
  Either gun's `StartSprint`, `DoKick` or `Deselect` takes the tokens back for both.
- Why it is wrong: one hand's aim changes the other hand's gun: its frames, its spread and its rate.
- Checked: the main Rifle's own secondary is the launcher (Rifle.dec:609) and the SMG's is the burst toggle
  (rsqdual:1399), so in VR the Rifle's aimed mode is reachable only through the other hand. The tokens are base BD.
- Sure?: likely (certain that the tokens are shared; what the aimed frames look like on the VR model was not seen).
- Fix A: the off twins do not zoom: make their `AltFire` a one-tic swallow as the main Railgun's (MP40 rsqdual:2086,
  Shotgun 4919, Assault Shotgun 6284, Railgun 7122): about 4 lines a twin.
- Fix B: per-hand tokens (`ZoomedOff`, `ZoomHoldOff`) in the twins: about 250 lines changed, generator work.
- Or intended: no.
- Already known?: no

## B8.8: The Reload key meant for the main gun is read, and eaten, by the off-hand gun
- Kind: wrong behaviour
- Where: reads with no hand test: rsqdual:3969, 3971, 3973, 3975 (Plasma, charge held), 1089 (Shotvolver), 4337, 4820,
  5122, 5215 (Shotgun). Takes: the first line of every twin `Reload` (rsqdual:466, 1049, 1675, 2281, 3308, 4134, 5069,
  5736, 6367, 7287), and Fire on three twins (rsqdual:893, 4715, 5503). The button: `src/zscript/rsq/flick.zs` 389-404,
  446
- What the code does: the generator turned most `Reloading` tests into "main layer only" but left these. So
  (a) a charged off-hand plasma shot is cancelled when Reload is pressed (rsqdual:3969 -> `Cancel` 4079: the charge
  is given back), (b) an off-hand Shotgun or Shotvolver that is loading shell by shell stops loading on the press,
  (c) the off twin's `Reload`, which the button starts with `SetPsprite` on the same tic (flick.zs:446), takes the
  token in its first state, and firing the off Shotvolver, Shotgun or SSG takes it too.
- Why it is wrong: (a) and (b): the off gun reacts to a key the notes say it never reads (flick.zs:363-366). (c):
  `ButtonHand` treats the main hand as served when `Reloading` is there (flick.zs:395-396, "the gun takes it from its
  ready loop") and then starts the off hand, whose first state removes the token; if the main gun's Ready loop has not
  run yet, the main gun does not reload on that press.
- Checked: when base BD gives `Reloading` (once on the press, or on every tic the key is down) is not in the repo. If
  it is given every tic, (c) only delays the main gun by a tic.
- Sure?: (a) and (b) certain; (c) unsure. A rig log (`rsq_switch_log`) of one short Reload press with two pistols
  settles (c).
- Fix A: (a)(b) put the same main-layer test on those 9 reads. (c) drop the `A_TakeInventory("Reloading", 1)` lines
  from the twins' `Reload` and Fire states (13 lines). 1 file, plus the generator.
- Or intended: (a) may be wanted (Reload cancels a charge); the rest no.
- Already known?: no. RL9 in BUGS_FROM_CODE_READ_2026-11-24.md is about other reload code that cannot be reached.

## B8.9: Other gun-state tokens that the two hands of a same-gun pair share
- Kind: wrong behaviour
- Where and what, each certain as shared, each small:
  - `MP40ReloadToken`: the off MP40 gives it for 23 tics near the end of a reload from empty (rsqdual:2320 to 2331).
    In that window a Reload on the main MP40 goes to `Fidget` and reloads nothing (rsqdual:2295 = the same line in
    Mp40.dec), and a main MP40 drawn then racks its bolt (rsqdual:2059). `RifleReloadToken` (rsqdual:3318, 3344, 3358)
    and `ASGReloadToken` (rsqdual:6377, 6406, 6416) the same way.
  - `SSGLoaded` and `SSGAlt`: one flag for two guns. The off SSG's own `Reload` gives up when the main SSG is loaded
    (rsqdual:5740), its Fire reads the main gun's `SSGAlt` (rsqdual:5506, 5606), and its Select skips the opening
    reload when the main gun is loaded (rsqdual:5444). Softened because the button and the flick use
    `RSQ_FlickReload` (flick.zs:420), which reads neither.
  - `HasUnloadedPistol`, `...SMG`, `...MP40`, `...Rifle`, `...Plasma`, `...ASG`, `...Railgun`, `...Revolver`,
    `...SSG`, `...Shotgun`: "no magazine in the gun" is one flag for both guns (e.g. rsqdual:480, 6058, 6133: an off
    Assault Shotgun cannot fire while the main one is unloaded).
  - `Unloading`: the Pistol twin holds one tic before it takes the token (rsqdual:579-580), so BD22's Unload key
    unloads both pistols; the other twins take it at once.
  - `PlasmaCharging` (rsqdual:3925, 4137): a Reload on one plasma rifle cancels the other's charge.
  - `HeavyAutomaticWeapon`, `RandomHeadExploder`: putting the off Minigun away takes them while the main Minigun is
    still out (rsqdualmg:224-225). What they do is base BD.
  - `PSeq3`, `FireFrameCount`, the `...Selected` tokens, `A_SetCrosshair` in every Ready pass: shared; cosmetic.
- Why it is wrong: each is the 2.0.5u Shotgun fault in a smaller place: the copy has its own magazine but not its own
  state.
- Checked: none of these has an `...Off` class in `src/` (the script's list of undefined names; all base BD).
  `dual.zs` SwapMags moves none of them.
- Sure?: certain that they are shared; each effect is likely and narrow.
- Fix A: per-hand tokens for the three bolt tokens and the `HasUnloaded...` set (about 110 lines in rsqdual and the
  generator), moved in `dual.zs` SwapMags as the shotgun's token is.
- Or intended: `PistolBurstFire` (one fire-mode switch for both pistols, rsqdual:561-566) reads as meant.
- Already known?: no

## B8.10: Two pistols in burst mode fired together give bursts of the wrong length
- Kind: wrong behaviour
- Where: rsqdual:394, 399, 403 (twin `Fire2`); the same lines in Pistol.dec (383, 388, 392)
- What the code does: both pistols count their burst in the one token `BurstCounter`: give 1 a shot, stop at 3, take
  all.
- Why it is wrong: with both triggers down the two guns count each other's shots: one stops after 1 or 2 rounds, the
  other runs on. The SMG's burst got a counter for each hand for this reason (rsqdual:1578-1594, "Each hand counts
  its own").
- Checked: `BurstCounter` is base BD; no `...Off` twin of it in `src/`.
- Sure?: certain in the states.
- Fix A: `BurstCounterOff` in the twin's three lines, plus its class (4 lines, 1 file).
- Or intended: no.
- Already known?: no

## B8.11: A map that hands out a Shotgun or Super Shotgun by spawn number may hand out the off-hand copy
- Kind: wrong behaviour
- Where: rsqdual:4260-4261 (`Game Doom`, `SpawnID 27`), 5291-5292 (`SpawnID 33`); main Shotgun.dec:5-6, SSG.dec:4-5
- What the code does: the generator copied the main gun's `SpawnID` into the twin. Two classes now claim 27 and two
  claim 33.
- Why it is wrong: `Thing_Spawn` and its relatives pick the class by this number; when two classes hold one number the
  later class normally wins, and the twin is defined later. The thing on the floor would be "Off-hand Shotgun": taken,
  it gives the twin with `AmmoGive` 0 and not the gun.
- Checked: the Minigun twin, made by a later script, does not copy its `SpawnID 28` (Minigun.dec:6; none in
  rsqdualmg), so the later script already avoids this. Which class the engine keeps for a doubled number was not run.
- Sure?: likely; a map that calls `Thing_Spawn` with 27 settles it.
- Fix A: delete the four lines (and in the generator).
- Or intended: no.
- Already known?: no

## B8.12: Every second Rifle shot uses the deathmatch puff (both hands)
- Kind: wrong behaviour
- Where: rsqdual:2872 and 2892 (`SpriteVariant:` twice), 2919 and 2951 (`SpriteVariant2:` twice); the same in
  `src/actors/Weapons/Rifle.dec` 350 and 370, 397 and 429
- What the code does: the label is defined twice in one actor; the second is the DM copy (`HitPuffDM`). A jump by
  name goes to one of them only, normally the later.
- Why it is wrong: the alternate shot (the `PSeq3` branch, rsqdual:2867) would then hit with `HitPuffDM` in single
  player. It is not drift: the twin copies the main file.
- Checked: both actors; `HitPuff` and `HitPuffDM` are base BD, so what differs between them is not known. BD22's own
  Rifle may carry the same doubled label.
- Sure?: unsure: which of two equal labels the engine keeps was not run, and the two puffs could not be opened.
- Fix A: rename the DM pair `SpriteVariantDM` / `SpriteVariant2DM` in both files (4 lines, 2 files). Nothing jumps to
  the DM states, so they are dead either way.
- Or intended: if BD22 ships it so and the owner wants BD22's behaviour.
- Already known?: no

## B8.13: The off-hand Minigun plays its reload with nothing to load
- Kind: wrong behaviour (small)
- Where: rsqdualmg:42, 44-50; `src/zscript/rsq/counters.zs` 356-372
- What the code does: `Reload` starts the 16-tic belt sound when the reserve item `RSQ_MinigunAmmo` is 1 or more.
  `OffFill` then moves `reserve - RSQ_Lent_Minigun` rounds: the rounds lent to the main Minigun's magazine are not
  the pouch's.
- Why it is wrong: when everything left in the reserve is lent to the main gun's magazine, the off gun plays the
  reload and gains nothing.
- Checked: counters.zs:216-222 (what "lent" means). The main gun's own Reload tests `RSQ_Pouch_Minigun` instead
  (Minigun.dec:29).
- Sure?: likely.
- Fix A: test `RSQ_Pouch_Minigun` at rsqdualmg:42 (1 line; and the generator) if that token is kept up while the gun
  is in the off hand, else have `RSQ_OffFillMinigun` answer first as `RSR_Start` does.
- Or intended: no.
- Already known?: no

## B8.14: The twins did not get the hand-reload fixes the main guns got (no effect while the rule below holds)
- Kind: drifted copy, dead code
- Where: Pistol.dec:25-32 vs rsqdual:42-45; SubMachinegun.dec:23-30 vs rsqdual:1222-1224 and 66-73 vs rsqdual:1259;
  the `RSR_Held_...` jump at Pistol.dec:460, SubMachinegun.dec:491, Mp40.dec:437, Rifle.dec:795, Plasma.dec:651,
  AssaultShotgun.dec:478, Railgun.dec:616, missing in each twin's `Reload`; Shotgun.dec:41-50, 109, 119 vs
  rsqdual:4293-4294, 4353, 4363-4365; Rifle.dec:455-458, 473-476 vs rsqdual:2977, 2992
- What the code does: the twins still carry the hand-reload states as they were when the lump was generated (1.20).
- Why it is not felt: the hand reload starts only when the off hand holds `RSQ_Hands`
  (`src/zscript/rsr/vreload.zs` 1086-1095; `rsr_break.zs` 1146; `rsr_pump.zs` 664, 687), and `RSR_Start`,
  `RSB_Start`, `RSP_LoadStart` look at `player.ReadyWeapon`, never the off gun (vreload.zs:868). With a twin in the
  off hand none of them gives its `..._Go`, so every twin drops to BD22's own reload (`RSR_Stock`, `RSB_Stock`,
  `RSP_LoadStock`) and the old lines are never run. The Rifle's old launcher lines are never run because the off
  layer jumps to `RSM_FireOff` first (rsqdual:2959).
- Sure?: certain.
- Fix A: regenerate the lump from today's main files (the header at rsqdual:1 says it is generated; `gen_dual.py` is
  not in the repo, dualtable.zs:5) or delete the dead `RSR_*` / `RSB_*` / `RSP_*` hand-reload blocks from the twins
  so nobody mistakes them for live code.
- Or intended: yes for now: it is dead code. It turns into the two 2026-10-23 faults again the day the off hand gets
  a hand reload.
- Already known?: no

## Things that looked wrong and are not (so the next reader does not chase them)
- Every state jump in every twin resolves. Each `Goto`, `A_Jump*`, `A_ReFire("...")` and `A_GunFlash("...")` name in
  the 13 twins and in `RSM_KindRound` exists in the twin, its main-hand actor or `BrutalWeapon` (script, then spot
  checks). Numeric jumps count the same states as the main files wherever the text is the same.
- `SubMachinegun.dec` 402 reads `BDSMGAmmoOff` in the MAIN gun: it is inside `RSA_BurstStepOff`, the off-layer branch,
  and the twin has the same line (rsqdual:1589). Correct for the twin, never run for the main gun.
- `A_JumpIf(0, "DualWield")` (rsqdual:245, 440, 1369, 2075 ...): never true by design; BD22's own two-gun weapons are
  switched off. `DualWield` / `GetDual` / `SelectDual` below it are dead.
- The off Minigun with an empty pouch and rounds in its magazine still fires: `Weapon.AmmoUse 1` is inherited
  (Minigun.dec:8) but `BrutalWeapon` has `+WEAPON.AMMO_OPTIONAL` and `+ALT_AMMO_OPTIONAL` (DEFAULTWEAPON.dec:20-21),
  and the twin's bullets no longer use ammo.
- `RSM_DryHold` in the Rifle twin tests the main layer only (rsqdual:3019): the off layer never gets there; it uses
  `RSM_DryOff` (rsqdual:3040-3045).
- `RSM_KindRoundOff`, `RSM_KindLoadedOff`, `RSM_LoadedOff`, `RSQ_OffFillMinigun`, `RSQ_SemiLockOff`, `RSA_MagnumOff`,
  `RSA_SlugOff`, `RSA_ASlugOff`, `RSA_BurstCntOff`, `RSLD_JamOff`, `RSLD_G5BlockOff`, `RSLD_AltDownOff`, all the
  `RSR_*`, `RSB_*`, `RSP_*` tokens and the `RSVR_OffAxe*` tokens are defined in `src/`.
- The axe twin's `OffAxeGone` loop has no way out in the states (Axe.dec:499-501); `melee.zs` 155-175 puts the copy
  away from outside.
- The axe twin's `Fire` with the main axe's VR-throw token set goes to `Ready` with no tic (Axe.dec:480), but `Ready`
  holds a tic, so it does not spin.
- The off-hand Silvergun's `RSLD_Jammed` and the off Minigun's allow reload (`WRF_ALLOWRELOAD`) while the twins'
  Ready loops do not: copied from the main guns; what the engine does with that flag on the off layer was not
  checkable.
- `dual.zs` SwapMags does nothing for a Minigun pair (the main Minigun has no `AmmoType2`, dual.zs:159): that is
  part of the zscript reader's file, noted here only because the table above names both magazines.

## Not read or not checkable
- Base Brutal Doom: every inventory token the twins use that is not defined in `src/` (116 names, among them
  `NeedToHammer`, `BurstCounter`, `Kicking`, `IsRunning`, `UsedStamina`, `Reloading`, `Zoomed`, `SSGLoaded`,
  `MP40ReloadToken`, `HasUnloaded...`, `TokenCleaner`, `Pumping`) and every class (46 names, among them
  `PlayerMuzzle1/2/3`, `ShotgunPuff`, `HitPuffDM`, `DecorativeTracer`, `KickAttack`, `ShortGrenade`,
  `RailgunSpawner`, `50CaseSpawn2`, the reserve ammo `Clip1`, `Clip2`, `AmmoShell`, `AmmoCell`, `Mauser9mm`). They
  are assumed to be BD22's. `DualSMG` and `DualMP40` (rsqdual:1828-1829, 2499-2500) are named by string and are in
  neither `src/` nor, as far as can be seen from here, anywhere checkable; the states that name them are dead.
- BD22's ACS (scripts 852, 853, `GetCrosshair`, `VoiceTaunt`) and how its keys give `Reloading`, `Kicking`,
  `Unloading`, `IsRunning`.
- Sounds and sprites named in the twins were not checked against `src/sounds` and `src/sprites`: they are the main
  guns' own names, the same text on both sides.
- `gen_dual.py` is not in the repo (dualtable.zs:5); `tools/dual_minigun/gen_off_minigun.py` is outside the shipped
  mod and was not read.
- The main-hand files were opened only at the lines listed under "Files read"; parts 1 and 2 read them whole.
- Nothing was run: which of two equal state labels or spawn numbers the engine keeps, the order in which the main
  and off layers tick, and what `A_ZoomFactor` and `PowerLightAmp` do in the headset are stated as likely, not seen.
