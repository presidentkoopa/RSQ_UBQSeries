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

## Handoff (2026-10-27) -- read first

Not yet run on the owner's headset. Rig B = QZD 17.3 Linux, doom2 MAP01, the owner's order
(brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions -> LegenDoom Lite 4.2 -> the suite ->
GunBonsai-0.10.6 -> this patch). Probe `pol/kdprobe` in the session scratchpad (real BD imps, LegenDoom
Lite's guaranteed legendary pickup, the upgrade objects called with level 1).

**Done, measured**
- *Knockdown and Executioner size against the health the monster STARTED with* (`RSQM.StartHealth`,
  branch `agent-polish`): Champions' StartHealth as before, and for a LegenDoom Lite legendary
  (transformed or not) the class's spawn health x `LD_legendaryhealth` / 100 (the ACS's own integer
  arithmetic, the ShieldSaw's TierHealth rule), the larger winning. Knockdown level 1 (share 0.44),
  damage in 5s until down: plain imp 40 -> 40; untransformed legendary imp (240 hp) 40 -> **110**;
  transformed legendary (refilled to 240) 40 -> **110**. A legendary champion (StartHealth already 240)
  stays 240, not 720. Executioner level 1 on a transformed legendary at 30 hp: no execution before
  (threshold 12), executed now (threshold 36).
- *Executioner after the victim's damage factors* (1f32468, `agent-compat`) still holds with the change:
  an imp taking half (DamageFactor 0.5) at 10 hp, staggered: blow 5 -> 22, 11 dealt, dead.
- *Brutal Doom's HUD type* (8b4b24f): the skins hide BD's HUD with `bd_sbartype` 5, a type BD knows;
  full order + save/load twice + map change: no `Unknown item type sbartype0` line (0 in the log).

**Done earlier today, recorded in commits** (their own numbers, not re-measured here): melee upgrade
paths, gloves, Slappers Only and the claim bracket (0f2f48d); Adrenaline charges SlowMo's meter
(b9f142e, rig: two charges of 10 read 20); suite upgrade paths for the ShieldSaw, saber, grab, rig,
SlowMo, hands and body (a460f51); punch and swing sounds renamed so they no longer replace BD's own
(a1ae4fb); COPYING.md (f357289); the screens and their fonts (e9b7eb8, d64248c, 90e80f2); left-handed
dual HUD reflected (6973ddb); Grapple player perks (fcf0a7a); colour-blind HUD (4bdd8c7); accessibility
round two (1b986bb); XP Source (49fd7c0, section below).

**Not done / headset**: how often Knockdown and Executioner fire on legendaries in real play.

**Open**
- `rsq_ui_skin` defaults to 1 (the screens on). The independent review (10-27, item 1) asks for 0 unless
  the owner chose 1; 90e80f2 turned it back on after cee9be2 had shelved it. The owner's call.

## Suite upgrades (`rsq/`)

New files only, compiled by a second ZSCRIPT lump (`zscript.txt` at the root): weapon upgrade paths
for the boxing gloves, the sabers and the Force, the ShieldSaw and any melee weapon; player upgrade
paths for Distance Grab, the Tactical Rig, SlowMo, the two hands and the body (each offered only
while its mod is loaded); **Slappers Only**. See `readme.txt` for the list, who earns which XP, and
the score-as-XP settings. The saber, the ShieldSaw and the grab ask `RSQ_MeleeUpgradeService` for
their levels by name; nothing links to anything.

The changes to shadowed files: `PerPlayerStats.zsc` (the claim bracket `claimStack`, the player
pool for throws, score XP shared per kill, `HandOfShot`, the XP Source gate `RSQ_XPSource` and the
per-monster credit `NoteStyleHit`, `GetShieldStats`), `HUD.zsc` (`DrawShield`), `EventHandler.zsc`
(the shield gauge's one call) and `debug.zsc` (the pool in the hands dump).

## XP Source: Damage, Style, Both (`rsq/zscript/stylexp.zs`)

Options -> the suite upgrades' page -> **XP Source** (`rsq_xp_source`, server): **Damage** (Gun Bonsai's
own, the default: nothing changes -- measured: the same 17 scripted kills left every weapon record, the
pool and the player XP identical to master), **Style**, **Both**. Style needs RSQ Score (asked by name);
without it Style reads as Damage.

With **Style** a kill's style points -- RSQ Score's bonus rows for that kill, the total less the base,
Champions' and LegenDoom Lite's rows included -- become XP (x `rsq_xp_style_scale`, 1.0), split along
its combo chain (RSQ Score's `kill.chain`, the finishing blow last): the **finisher's tool 50 %**, the
**setup tools share 50 %** equally (a chain of one tool: the finisher takes it all), and on top
`rsq_xp_style_player` (10 %) to the player pool. Damage pays no XP; the stock score-to-XP and the
hook's action XP stand down (they would pay the same kill again). **Both** keeps damage XP and adds the
style. Each share goes down the patch's existing paths: a gun to the gun(s) Gun Bonsai credited with
hitting that monster (`PerPlayerStats.NoteStyleHit`), the saber and the Force to the saber (up_saber),
the shield's tools to the ShieldSaw (up_shield), the gloves to the gloves (up_gloves), a punch, kick,
blade or finisher to the melee weapon that hit it (up_melee), the hook, the whip and a grab throw to the
player pool (up_hook's and the grab's perks are player upgrades). Measured (imp, base 60):
whip > ShieldSaw bash, style 66 -> ShieldSaw 33, pool 33 + 6.6; gun > saber cut > kick, style 69 -> kick
34.5 (pool), gun 17.25 (Shotgun), saber 17.25; four tools, style 66 -> finisher 33, three setups 11 each.
The XP bars look exactly as before.

## The ShieldSaw gauge (`rsq_hud_shield`, off by default)

Options -> the suite upgrades' page -> **ShieldSaw Gauge** (user). A third Gun Bonsai gauge -- the stock
art, colours, bars and text, through the same `DrawHUD` the hand gauges use -- for the ShieldSaw while it
rides on the shoulder (stowed or thrown; in a hand, that hand's gauge shows it), centred at the top
between the two hand gauges, just under their bars (22 % of a hand gauge's height down), scaled to fit
the gap (90 % of it, between half and full size of a hand gauge; `TFLV_HUD.ShieldScale`). RSQ Score
moves its display down by as far as the gauge reaches (`RSQ_HudService "shield.gauge.drop"`). Off,
nothing is drawn and nothing moves. It shows once the ShieldSaw has a Gun Bonsai record (it has been
held, or has earned XP).

## The screens (`rsq/ui/`)

The owner's Gun Bonsai mockups, drawn instead of Gun Bonsai's own HUD, status screen and level-up
menus. Options: **Gun Bonsai Screens** (skin, HUD inset, HUD size, ammo and health row).

```
rsq_ui_skin       0 Gun Bonsai's own, 1 Mockup (the recreation), 2 Hex Rail, 3 Terminal
rsq_ui_inset      fraction of each screen edge kept clear (the headset's edge of view)
rsq_ui_hud_scale  HUD size
rsq_ui_bottom     per-hand ammo, health, face and armour along the bottom
```

How it hooks Gun Bonsai: `RSQUI_Handler` draws the skin's HUD round Gun Bonsai's own XP gauges, which
draw themselves (no Gun Bonsai HUD code is skipped any more: d64248c). Gun Bonsai opens its menus by name, and this
patch's MENUDEF points those three names at routers (`rsq/ui/router.zs`) that are Gun Bonsai's own
menus with skin 0 and open the skin's screen otherwise. No other Gun Bonsai file is shadowed.

RS Score's display and Gun Bonsai's XP gauges draw themselves, untouched. With the bottom row on, a
skin sets Brutal Doom's `bd_sbartype` to 5 (a type Brutal Doom knows but draws nothing for; its
fullscreen HUD would sit under the row). It is put back when the skin is set to 0. Remove the patch
with a skin on and it stays as set: pick your HUD again in Brutal Doom's options (or `bd_sbartype 1`).

The screens write in Doom's own fonts from the IWAD (SmallFont, BigFont, NewSmallFont; owner, 10-27:
"just use the doom fonts"); the baked OFL fonts were removed in d64248c. `tools/rsqui_bake.py` makes
the remaining art; gun pictures come from `tools/rsqui_gunshots.py` (the gun's own model on the test
rig, keyed and cropped into `graphics/rsqui/guns/<Class>.png`; a gun without one shows its icon or
pickup sprite). The gauge frame is Gun Bonsai's own HUD art. Screens designed by presidentkoopa.

## Known collisions

Other Gun Bonsai patches that shadow the same files will silently clobber, or be
clobbered by, this one. GunBonsai has a number of addons and patches which alter its main behavior. I would not recommend using any of those with this patch. Maybe load this last if you do, but expect problems.

## Licence

Gun Bonsai is by Rebecca "ToxicFrog" Kelly, MIT licensed. This is a derivative
work under the same terms.

Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); glove mesh and fit by Ermac
(iAmErmac); sounds from Punch Out Doom (DerrickDavison) via Virtual Punch Out.

vr patch conceptualized by PresidentKoopa, authored with agentic ai
