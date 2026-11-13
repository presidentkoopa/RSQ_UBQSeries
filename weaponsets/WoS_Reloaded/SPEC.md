# Weapons of Saturn VR: ground-up ZScript rebuild (spec, owner-agreed 2026-11-12 17:30-17:45)

Target: QuestZDoom 17.3 (ZScript 4.14), no engine changes. Generic Weapons is OUT of scope until the owner says.

## Scope (Q1)
- Rebuild in ZScript: every WoS weapon, its ammo, items (helmet, backpack) and the player class. No ACS anywhere.
- No monsters (WoS's zombieman is not carried over).

## Options (Q2)
- All of WoS's own options are dropped (per-gun reload switches, Classic Pump, Aim Toggle, Shell Casings, Smoke, Helmet
  Bonus). Anything that makes no sense in VR (ADS, iron sights, aim toggles, synth fire) is tossed and replaced by systems we design.
- The menu holds VR-only options, in the BD22 VR style (a list of options, no help text).

## Meshes (Q7), hands
| Weapon | Mesh | Notes |
|---|---|---|
| Knuckles | FBX fists | physical melee from the RSQ series (Q5) |
| Motorsaw | Chain_saw | animations uncoupled as in BD: the player drives the saw (Q5) |
| Beretta | BrutalPistol | |
| 1911 | BrutalWolf 1911 (RS ModelSwapper card) | RE-MEASURED where it sits to the BD22 VR standard, then the FBX pistol hand fitted to it (Q3). Report anything below standard. |
| Riotgun | ShotGun | |
| Coachgun | SSG | |
| MP40 | MP40 | |
| MachineRifle | Rifle + underbarrel | |
| Minigun | Minigun | magazine = scaled BD voxel ammo box over the off hand |
| SaturnV | RPG | it is the rocket launcher |
| NovaRifle | RailGun | live scope, always on, 3x |
| TITAN | Nuker | |

## Fire / alt fire (Q5, Q6, earlier spec)
- All kicks removed. BD's quick kick, usable any time.
- Fists: physical melee (RSQ series); their trigger and alt fire are left free.
- Beretta, 1911: no kick alt.
- MP40: open bolt, full auto only, about 525 rounds/min (one round every 4 tics), so a tap is a single shot. No alt fire.
  WoS's dual-MP40 mode is gone; dual wield is the BD22 VR system.
- Riotgun: alt fire = slugshot (iron sights gone).
- Coachgun: fire = one barrel, alt fire = both barrels.
- MachineRifle: alt fire = the underbarrel launcher (BD22 VR style hand load); ammo RSQ Grenade's, else rockets.
- Minigun: as WoS has it.
- SaturnV: alt fire = BD's 3x lock-on.
- NovaRifle: charge ball as WoS. TITAN: Hyper Nova as WoS.

## Sounds (Q4)
- 1911 hand reload: the BrutalWolf card's own five sounds.
- Other BD22 VR reload names with no file: RS Combat FX / RS Ballistics (earlier answer).

## Effects and sounds (owner 17:51)
- Weapon effects and sounds (ballistics): an option, WoS's original (OG) or our Enhanced set from RS Ballistics and
  RS Combat FX.

## Pickups (Q8)
- Every weapon and ammo pickup uses its Voxels of Saturn voxel; the dead BELT entry is dropped.
- They appear in the RSQ Wheel when it is loaded. RSQ compatibility for now: the Wheel and Melee; the rest should come mostly automatically.

## Carried over from the earlier spec (14:33 and after)
TrueBullet, Dual, Enhanced Ballistics, enhanced shotgun spread, HUD ammo (both hands, GBOVR style), VR hands, skin tone,
Reloading (Stock / VR / Flick), Grab ammo with, New magazine from (incl. Tactical Rig), shells per insert, reload assist,
pistol semi auto, Start With Two Pistols (BD22 VR's way), Start With Pistol and Shotgun, real casing models, BFG-class no
reload rules as decided, forced pump after loading from empty, flick never reloads a full gun.

## Process (owner, 17:29)
1. Survey (done 17:35). 2. Build. 3. One full rig suite at the end, unattended: every weapon given, raised, fired,
alt-fired, hand-reloaded to done with rounds counted, Stock and Flick reload, dual where enabled, HUD drawn. 4. One report
with logs, then the pk3. The build refuses to write a pk3 without a passing suite. No piecemeal rig chatter.
Any question: ASK the owner. Any mesh below standard: TELL the owner.
