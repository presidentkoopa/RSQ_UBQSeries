# Gun Bonsai — Offhand / VR Support

Dual-wield support for [Gun Bonsai](https://github.com/ToxicFrog/doom-mods) 0.10.6
on VR builds of GZDoom where the player holds a weapon in each hand.

Load **after** `GunBonsai-0.10.6.pk3`.

The patch ships replacement copies of nine Gun Bonsai source files at their
original paths. GZDoom's later-lump-wins rule substitutes them; there is no
patching step. Everything else in Gun Bonsai is untouched.

```
ca.ancilla.bonsai/PerPlayerStats.zsc        two live infos, provenance registry, Claim API
ca.ancilla.bonsai/EventHandler.zsc          dual HUD render, hitscan bracket, offhand ShowInfo
ca.ancilla.bonsai/WeaponInfo.zsc            cross-hand rebind guard
ca.ancilla.bonsai/WeaponTypeInference.zsc   type hints from claimed shots
ca.ancilla.bonsai/HUD.zsc                   per-hand anchoring
ca.ancilla.bonsai/debug.zsc                 bonsai-debug,hands
ca.ancilla.bonsai/upgrades/Dot.zsc          proportional burn credit
ca.ancilla.bonsai/upgrades/Juggler.zsc      both hands
ca.ancilla.bonsai/upgrades/RapidFire.zsc    per-hand psprite, null guard
```

Any file shipped here that is *not* actually modified should be deleted — an
unchanged shadowed file is collision surface with other patches for no benefit.

## Suite upgrades (`rsq/`)

New files only, compiled by a second ZSCRIPT lump (`zscript.txt` at the root): weapon upgrade paths
for the boxing gloves, the sabers and the Force, the ShieldSaw and any melee weapon; player upgrade
paths for Distance Grab, the Tactical Rig, SlowMo, the two hands and the body (each offered only
while its mod is loaded); **Slappers Only**. See `readme.txt` for the list, who earns which XP, and
the score-as-XP settings. The saber, the ShieldSaw and the grab ask `RSQ_MeleeUpgradeService` for
their levels by name; nothing links to anything.

The changes to shadowed files: `PerPlayerStats.zsc` (the claim bracket `claimStack`, the player
pool for throws, score XP shared per kill, `HandOfShot`) and `debug.zsc` (the pool in the hands dump).

## Known collisions

Other Gun Bonsai patches that shadow the same files will silently clobber, or be
clobbered by, this one. GunBonsai has a number of addons and patches which alter its main behavior. I would not recommend using any of those with this patch. Maybe load this last if you do, but expect problems.

## Licence

Gun Bonsai is by Rebecca "ToxicFrog" Kelly, MIT licensed. This is a derivative
work under the same terms.

Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); glove mesh and fit by Ermac
(iAmErmac); sounds from Punch Out Doom (DerrickDavison) via Virtual Punch Out.

vr patch conceptualized by PresidentKoopa, authored with agentic ai
