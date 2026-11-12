# Architecture (working notes; SPEC.md is the owner's)

## Layout
- `src/` the pk3 tree, hand-written ZScript + data. `tools/build.py` assembles `src/` + the BD22 VR systems + meshes,
  runs the lint and the rig suite, and writes the pk3 ONLY when the suite passes.
- `tools/seat_1911.py` + `seat_1911.json`: the 1911 seated in the FBX pistol hand (done 2026-11-12: landmarks within
  0.39 md3 units, grip axis 3.2 deg, bore 3.3 deg; MODELDEF Offset 1.709 -8.477, ZOffset -2.334, Angle 4.713,
  Pitch 5.17, Roll 13.413).

## Weapons: ZScript, one base
- `RSQWS_Gun : Weapon` (src/zscript/wos/gun.zs): the ONLY place the VR protocols live: magazine (RSR), pump (RSP),
  break-open (RSB), underbarrel (RSM), flick, stock reload, semi auto, dual copies, quick kick hook. Ammo convention
  kept from WoS: Ammo1 = reserve, Ammo2 = the gun's loaded rounds.
- Each WoS gun = a short subclass: stats (damage, spread, rate, magazine) from WoS's DECORATE, its sounds, its
  projectiles (WoS's, ported to ZScript), its frames (the BD22 sprite frames its MODELDEF keys), its alt fire (SPEC).
- No ACS. WoS's options are gone (SPEC Q2); new VR options only.
- Classes, cvars, sounds: RSQWS_ prefix. Each gun `replaces` what WoS's replaced, and carries WoS's Tag / slot.

## The BD22 VR systems
- Copied from rsq_bd_vr_reloaded (hands, handtone, gunmoves, muzzle, vreload, rsr_break, rsr_pump, rsr_m203, flick,
  ballistics, rounds, casings, dual, scope) with RSQ_Alias mapping each RSQWS_ class to the BD22 gun whose tables it
  uses (the earlier port's tools/port/zs_port.py approach). The 1911 gets its own rows (BW 1911 card, moved by the seat).

## Not yet decided by the owner (ASK)
- (none open)
