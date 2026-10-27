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

## The screens (`rsq/ui/`)

The owner's Gun Bonsai mockups, drawn instead of Gun Bonsai's own HUD, status screen and level-up
menus. Options: **Gun Bonsai Screens** (skin, HUD inset, HUD size, ammo and health row).

```
rsq_ui_skin       0 Gun Bonsai's own, 1 Mockup (the recreation), 2 Hex Rail, 3 Terminal
rsq_ui_inset      fraction of each screen edge kept clear (the headset's edge of view)
rsq_ui_hud_scale  HUD size
rsq_ui_bottom     per-hand ammo, health, face and armour along the bottom
```

How it hooks Gun Bonsai: `RSQUI_Handler` draws the HUD; the shadowed `EventHandler.zsc` skips Gun
Bonsai's own HUD while a skin is on (one cvar check). Gun Bonsai opens its menus by name, and this
patch's MENUDEF points those three names at routers (`rsq/ui/router.zs`) that are Gun Bonsai's own
menus with skin 0 and open the skin's screen otherwise. No other Gun Bonsai file is shadowed.

While a skin is on it sets RS Score's `rs_score_hide` (the skin draws the score) and, with the
bottom row on, Brutal Doom's `bd_sbartype` to 0 (its fullscreen HUD would sit under the row). Both
are put back when the skin is set to 0. Remove the patch with a skin on and they stay as set:
`rs_score_hide 0`, `bd_sbartype 1`.

Fonts and art are made by `tools/rsqui_bake.py`; gun pictures by `tools/rsqui_gunshots.py` (the
gun's own model on the test rig, keyed and cropped into `graphics/rsqui/guns/<Class>.png`; a gun
without one shows its icon or pickup sprite).

Fonts (SIL Open Font License 1.1, licence beside each in `fonts/*/OFL.txt`), converted to bitmap
glyphs under other names: Press Start 2P (The Press Start 2P Project Authors, CodeMan38),
VT323 (The VT323 Project Authors, Peter Hull), Orbitron (The Orbitron Project Authors, Matt
McInerney / The League of Moveable Type). The gauge frame is Gun Bonsai's own HUD art. Screens
designed by presidentkoopa.

## Known collisions

Other Gun Bonsai patches that shadow the same files will silently clobber, or be
clobbered by, this one. GunBonsai has a number of addons and patches which alter its main behavior. I would not recommend using any of those with this patch. Maybe load this last if you do, but expect problems.

## Licence

Gun Bonsai is by Rebecca "ToxicFrog" Kelly, MIT licensed. This is a derivative
work under the same terms.

Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); glove mesh and fit by Ermac
(iAmErmac); sounds from Punch Out Doom (DerrickDavison) via Virtual Punch Out.

vr patch conceptualized by PresidentKoopa, authored with agentic ai
