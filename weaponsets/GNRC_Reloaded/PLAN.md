# GNRC_Reloaded: plan (owner-agreed 2026-11-13 00:33-00:37)

Led's Generic Weapon Mod rebuilt in ZScript on the WoS_Reloaded base: BD22 VR meshes, hands and reloading, GNRC's
voxel pickups, GNRC's own sounds and damage numbers. No new meshes. QuestZDoom 17.3, no ACS, no engine changes.

## Scope (owner)
- Primary fire, secondary fire, reloading, options menu ("primary fire, secondary fire, reloading ... options menu").
- The options menu is the VR menu WoS_Reloaded has. None of Led's options or menu come over.
- No punching on the fists' triggers: "we use melee so we don't need punching triggers" (RSQ Melee does melee).
- A quick kick key: "if we need a quick kick then make one" (WoS_Reloaded's quick kick, no kick frames in VR).
- Pistol: "ROF is 5 or 6 per second" (6 tics a shot = 5.8 a second). Alt: GNRC's 3-round burst.
- Rifle: alt "toggle 3 rnd burst" (full auto <-> 3-round burst).
- Rocket launcher: "no rocket altfire".
- Shotgun alt: BD22 VR's slug (rsa_sg_slug), as WoS_Reloaded; GNRC's was iron sights.
- BFG: does not reload; it fires from the cells carried (40 a shot).
- GNRC's screen effects (A_SetPitch, zoom, weapon offsets, quakes, blends, A_Recoil) are not carried: in VR they move the view.

## Weapons → BD22 VR mesh and reload row
| GNRC | replaces | BD22 VR mesh | reload | GNRC extras |
|---|---|---|---|---|
| Knuckle | Fist | Melee_Attacks | none | trigger free (RSQ Melee) |
| ModChainsaw | Chainsaw | Chain_saw | none | led_ChainsawOn |
| Beretta | Pistol | BrutalPistol | RSR row 2 | 6 tics a shot; alt 3-round burst; dual |
| ARifle | (drops from clips) | Rifle | RSR row 1 | alt: full auto / 3-round burst; dual |
| Riotgun | Shotgun | Shot_Gun | RSP pump | alt: BD22 VR slug |
| DoubleSG | SuperShotgun | SSG | RSB break | fire one barrel, alt both |
| Minigun | Chaingun | Minigun | RSR row 17 + ammo box | spin-up, no alt |
| Rlauncher | RocketLauncher | Rocket_Launcher | RSR row 9 | no alt (owner) |
| PlasRifle | PlasmaRifle | Plasma_Gun | RSR row 7 | alt: rail (20 cells), cooldown |
| BFG9K | BFG9000 | BFG | none (owner: the BFG does not reload) | no alt |

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
3. Compile check on the QZD 17.3 rig (tools/compile_check.py).
4. Run one rig suite at the end, then one report, then the pk3.
