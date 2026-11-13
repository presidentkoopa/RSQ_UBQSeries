# GNRC_Reloaded: prep (2026-11-13)

Survey only. Nothing is built yet. Source: Led's Generic Mod (`src/gnrc`) plus its voxel pack (`src/vox`).
Owner: no new meshes; BD22 VR meshes, hands and reload systems; maybe a ZScript rebuild.

## How GNRC is built (the "strange" part)
- 10 weapons in DECORATE (~4,200 lines) inherit one ZScript class, `ModWeapon` (zscript.txt 4.6.1).
  `ModWeapon` holds the quick punch states and the A_Fire* actions (pistol, burst, rifle, ADS rifle, shotgun, ADS shotgun, SSG left/right, minigun, RL, plasma, plasma alt).
- Every option is read through ACS: about 30 `ACS_NamedExecuteWithResult("led_*")` calls whose scripts only return `GetCVar(...)`.
  - MD_OPTN: smoke, casings, spent mags, pump, SSG alt, death animation, armor.
  - MD_RELD: one reload on/off cvar per gun (pistol, rifle, shotgun, SSG, minigun, RL, plasma, BFG).
- Recoil is `A_SetPitch` plus `A_ZoomFactor`; select and lower animations are 2D `A_WeaponOffset` sweeps. In VR these pull the view, so they go.
- Aim punch: ACS script 600 (from Real Guns Advanced).
- Quick punch: KEYCONF `pukename PunchToggle` gives a `Punching` item; a variant uses `wait 9; +use`.
- The assault rifle replaces nothing. It drops from the Clip and ClipBox spawners (`DropItem ARifle`).
- There are no event handlers.
- Player start: Beretta, Knuckle, 50 PistolAmmo, and every magazine pre-filled (PistolMag 10, ShotgunMag 8, DBSGMag 2, RifleMag 30, MinigunMag 150, RocketMag 5, PlasmaMag 60, BFGMag 160).

## Weapons → BD22 VR mesh and reload row
| GNRC | replaces | BD22 VR mesh | reload | GNRC extras |
|---|---|---|---|---|
| Knuckle | Fist | Melee_Attacks | none | berserk punch |
| ModChainsaw | Chainsaw | Chain_saw | none | led_ChainsawOn |
| Beretta | Pistol | BrutalPistol | RSR row 2 | alt fire: 3-round burst |
| ARifle | (drops from clips) | Rifle | RSR row 1 | ADS (led_RifleADS) |
| Riotgun | Shotgun | Shot_Gun | RSP pump | ADS, led_ShotPump, chamber load |
| DoubleSG | SuperShotgun | SSG | RSB break | alt fire: single barrel (led_SSGAltFire) |
| Minigun | Chaingun | Minigun | RSR row 17 + ammo box | spin-up (SpinnyMini/EmptyMini) |
| Rlauncher | RocketLauncher | Rocket_Launcher | RSR row 9 | alt fire: grenade |
| PlasRifle | PlasmaRifle | Plasma_Gun | RSR row 7 | alt fire: rail (costs 20), cooldown |
| BFG9K | BFG9000 | BFG | none (owner: the BFG does not reload) | |

- Every mesh and row exists in rsq_bd_vr_reloaded (src/models/bd/*, rsr_guns.bd.zs).
- Plasma_Gun (row 7) and BFG are the only ones WoS did not use; WoS used RailGun and NukeLauncher.

## Voxel pack
- 56 voxels, 180 VOXELDEF lines, nothing missing.
- BNO2A-D are present but unused.
- MNIGA is a `.dat`; its header reads as KVX and it loads by lump name.
- Weapon pickups: PISTA, RIFLA, RIOBA, DBBLA, MNIGA, EMNGA, LAWNA, PLASA, BFUGA, CSAWZ.

## Plan (same pipeline as WoS)
1. Copy the WoS_Reloaded tools and the shared BD ports.
2. Write the GNRC classes and the mesh, row and dual tables.
3. Port GNRC's extras one decision at a time (owner answers).
4. Run one rig suite at the end, then one report, then the pk3.
