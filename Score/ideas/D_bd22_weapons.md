# Score ideas, lane D: BD22 VR Reloaded weapons (secondary list)

Proposals only. Nothing here is built or approved; every name is for the owner to veto. Written 2026-11-03
from a read of `Score/zscript/rsscore/`, the BD22 VR repo (`rs_brutal22weaponsq/src`, 2.0.3o) and
`brutal22test6.pk3` (`actors/`, parsed with a script; class names and damage types below are from that parse,
not from memory). No pay here was measured: every number is a starting proposal on Score's scale (0.1 to 0.5
for something you can do often, about 1.0 for something rare; the 3x per-kill cap still holds).

## Summary

- **33 weapon ideas** for the 22 guns in scope, **6 cross-weapon rows** (last round, reload under fire,
  crossfire, headshot, sights up, hold streak), **a split of the ledger's `gun` tool** into 6 gun classes plus
  2 blade tools, **20 named 2- and 3-tool chains** (the owner's 11-03 ask), and **9 stale items**.
- The rule kept: Score pays for how you fight and kill. A hand reload, a pump or a scope pays nothing by itself.
  It counts only inside a kill (Hot Reload, Rack and Roll, Glass).
- **Two real bugs found** (stale list, 1 and 2): the Grenade Launcher's bouncing grenade lands as a boot kick,
  and Brawler never pays BD22's chainsaw or axe.
- **How Score can tell the guns apart.** BD22 shares damage types across guns (the revolvers fire the shotgun's
  `ShotgunPuff`; the Unmaker and the BFG are both `Desintegrate`). So a kill is matched by the inflictor's
  class first, then by the gun in the hand that fired (`player.ReadyWeapon`, or `player.OffhandWeapon` when
  `RS_Physical.ShotHand` says the off hand; the off-hand guns are `RSQ_Off_<Gun>`, subclasses of the gun, so
  `is` works). The damage type comes last.

### Names checked (the owner's list against the code)

| Owner's name | Class | Kill blow (inflictor : damage type) |
|---|---|---|
| Pistol | `BrutalPistol` | `WeakPuff` : `Minor` |
| Revolver | `BrutalRevolver` (the Moonlight; this pack's `BrutalRevolver.dec`) | `ShotgunPuff2` : `Shotgun`, 1 pellet, 100 damage |
| Slug Revolver | `Revolver` (BD22's Shotvolver) with its slug alt fire (token `RSA_Magnum`, `RSA_MagnumShot` in `Revolver.dec`) | `ShotgunPuff` : `Shotgun`, 1 pellet, 200 damage. BD21's separate slug revolver (`Revolver2`) was removed on 2026-10-27 (`roster.zs`). |
| Shotgun | `Shot_Gun` | `ShotgunPuff`/`ShotgunPuff2` : `Shotgun`; slug (`RSA_Slug`) 1 pellet, 150 damage |
| Super Shotgun | `SSG` | `ShotgunPuff*` : `Shotgun`, plus the point-blank blast `shotpuff` : `SSG` (300-unit range) |
| Assault Shotgun | `AssaultShotgun` | `MachineGunBulletPuff` : `Minigun` and `ShotgunPuff2`; slug (`RSA_ASlug`) 150 |
| Rifle | `Rifle` | `HitPuff` : `Bullet`; its 40 mm `ShortGrenade` : `Explosive` |
| Machinegun | `Machinegun` (BD21 M249) | `HitPuff` : `Bullet`; its 40 mm `ShortGrenade` |
| BrutalSMG | `BrutalSMG` | `WeakPuff` : `Minor` (burst token `RSA_BurstSMG`) |
| Minigun | `MiniGun` | `MachineGunBulletPuff` : `Minigun` |
| Sniper | `Sniper` (the Ruger) | `SniperPuff` : `SniperDamage`; with True Bullets the pierce is `RSQ_PiercingRound` (`playerrounds.zs`) |
| Rocket Launcher | `Rocket_Launcher` | `Rocket2`/`Rocket2Fast`/`RocketDM` : `Explosive` |
| Grenade Launcher | `GrenadeLauncher` | fire `ShortGrenade2` : `Explosive`; alt fire `GrenadeMissile` : **`Kick`** (bounces, timed) |
| Nuke Launcher | `NukeLauncher` | `NuclearRocket`, `NuclearExplosion`, `SpawnedExplosionNuke` : `Nuke`; `NuclearFlames` : `fire` |
| Plasma Gun | `Plasma_Gun` | `Plasma_Ball` : `Plasma`; alt fire a fan of 10 `PlasmaBall75` |
| Railgun | `RailGun` | rail puff `RailgunPuff2` : `Railgun`, `RailgunProjectile` : `Railgun`, `RailgunPenetrator` : `Extreme` |
| BFG9000 | `BIG_FUCKING_GUN` | `SuperBFGBall` : `Desintegrate`; the tracers `SuperBFGExtra` : `Desintegrate` |
| BFG10k | `BFG10k` | `BFG10K_Ball` : `Extreme` |
| Unmaker | `Unmaker` | `UnmakerLaser`/`UnmakerLaser2` : `desintegrate` |
| Flamethrower | `Flamethrower2` | `FlamethrowerProjectileNew`(2/3) : `fire` |
| Axe | `BrutalAxe` (and `RSQ_Off_BrutalAxe`) | swing `AxeAttack` : `Saw`, `AltAxeAttack` : `Cut`, `AxePuffs` : `Saw`; thrown `ThrowedAxe`/`ThrowedAxeStrong` : `Saw` |
| Chainsaw | `Chain_saw` | `SSawPuff2`/`SSawPuff3` : `Cut`, `SawDamageHorizontal*` : `Cut` |

Note: `RSQ_DualTable.Nice(10)` calls the Moonlight "Silvergun" while the README calls it the Moonlight. Worth one name.

## Per-weapon ideas

Families: Eff = Efficiency, Sty = Style, Dar = Daring, Mel = Melee. "Hold" means one continuous press of the
trigger that fired (Score keeps the buttons of the last 16 tics in `RS_PhysicalNotes`; a hold streak needs one
more field there: the tic the trigger went down).

| Weapon | Name | Fam | Trigger | Detection (by name at run time) | Pay | Status |
|---|---|---|---|---|---|---|
| Pistol | Double Tap | Sty | two pistol hits on one monster within 10 tics, the second kills | blows with inflictor `WeakPuff` while `BrutalPistol` (or `RSQ_Off_BrutalPistol`) fired; per-victim last-blow tic kept in the ledger | 0.2 | new |
| Revolver (Moonlight) | Hand Cannon | Eff | one Moonlight round takes a monster from full health to dead | blow `ShotgunPuff2`, damage 100, gun `BrutalRevolver`/`RSQ_Off_BrutalRevolver`; victim's health equalled `GetSpawnHealth()` before the blow (WorldThingDamaged) | 0.25 | new |
| Revolver (Moonlight) | Clean Cylinder | Eff | the cylinder's six shots all hit, the sixth kills | WorldHitscanFired count from the gun vs hits since the last seat; `BrutalRevolverCylinder` (or `...Off`) at 0 | 0.4 | new |
| Slug Revolver | Magnum Slug | Dar | a Shotvolver slug kill, from full health in one shot | single `ShotgunPuff` blow of 200 damage from `Revolver`/`RSQ_Off_Revolver` (the slug is the only 200 shot, `Revolver.dec` RSA_MagnumShot); +0.2 at 768 units or more | 0.3 (0.5 far) | new |
| Shotgun | Pump Double | Sty | one trigger pull of the pump kills two or more | kills on the same tic by `ShotgunPuff`/`ShotgunPuff2` with `Shot_Gun` firing; paid on the 2nd and later | 0.3 each extra | new |
| Shotgun | Rack and Roll | Sty | two pump shots in a row each kill, the second at the gun's own refire (a fast hand pump between) | two `Shot_Gun` kills whose shots are no more than BD22's refire + 10 tics apart; the hand pump is BD22 VR's `RSP_PumpStart` (`rsr_pump.zs`). Pays only the kill. | 0.25 | new |
| Shotgun | Deer Slug | Dar | a pump slug kill at 512 units or more | single `ShotgunPuff` blow of 150 damage from `Shot_Gun` (slug, `RSA_Slug`), edge distance >= 512 | 0.3 | new |
| Super Shotgun | Coach Gun | Dar | BD22's point-blank barrel blast made the kill | killing damage type `SSG` (inflictor `shotpuff`, `SSG.dec` A_FireBullets with range 300) | 0.25 | stale rework of Scrapping |
| Super Shotgun | Two Barrels, Two Bodies | Sty | one SSG blast kills two or more | same-tic kills, `SSG` firing, inflictor `ShotgunPuff*`/`shotpuff` | 0.35 each extra | new |
| Assault Shotgun | Street Sweeper | Sty | three or more kills in one hold | kills by `MachineGunBulletPuff`/`ShotgunPuff2` with `AssaultShotgun` firing, one trigger hold | 0.15 per kill past 2, to 0.6 | new |
| Rifle | Under-Barrel | Sty | the Rifle's own 40 mm hurt it, its bullets finished it (or the reverse) within 3 s | ledger: `gun.explosive` (inflictor `ShortGrenade` from `Rifle`) then `gun.rifle` (`HitPuff`), both from one `Rifle` | 0.4 | new (named chain "Over-Under", below) |
| Machinegun | Beltfed | Sty | four or more kills in one hold | `HitPuff` kills with `Machinegun` firing, one hold; `RSQ_Mag_Machinegun` (`counters.zs`) not emptied | 0.15 per kill past 3, to 0.6 | new |
| BrutalSMG | Three-Round Burst | Eff | on burst, all three rounds hit the victim and the third kills | `WeakPuff` blows from `BrutalSMG` with `RSA_BurstSMG` held, burst count `RSA_BurstCnt` (`alts.zs`) | 0.2 | new |
| Minigun | Bullet Hose | Sty | five or more kills in one hold | `MachineGunBulletPuff` kills with `MiniGun` firing, one hold | 0.1 per kill past 4, to 0.6 | new |
| Minigun | Wide Sweep | Sty | the kills of one hold span 90 degrees or more of arc | angle from the player to each victim at its kill, inside one hold | 0.4 | new |
| Sniper (Ruger) | Glass | Dar | a scoped long shot: a Ruger kill at 1024 units or more with the shot's line within 2 degrees of the head's facing (the eye at the scope) | inflictor `SniperPuff` (damage type `SniperDamage`) or `RSQ_PiercingRound`; head facing from `RS_PhysicalNotes` (No-Look's own math, reversed). The live scope's on/off is local only (`scope_real.zs`, off in multiplayer), so it is not read. | 0.4 (0.6 at 2048) | new |
| Sniper (Ruger) | Collateral | Sty | one Ruger shot kills two or more (it pierces) | same-tic `SniperDamage` kills from one shot | 0.5 each extra | new |
| Rocket Launcher | Triple Lock | Dar | the lock-on salvo kills its locked enemies | rockets with an `RSQ_RocketSeek` thinker (`rlock.zs`: its `r` the rocket, `tgt` the lock); paid per locked kill, more when all three die | 0.3 each, 1.0 for all three | new |
| Rocket Launcher | Direct Hit | Sty | a rocket's impact killed it, not the splash | inflictor `Rocket2*`, the blow without the explosion flag (the last-blow flags `RS_PhysicalNotes` already keeps for Blind-fire) | 0.2 | new |
| Grenade Launcher | Carom | Sty | the bouncing alt-fire grenade bounced at least once before its blast killed | track `GrenadeMissile` from WorldThingSpawned; a bounce is its velocity reversing (BD22 `BounceType "doom"`) | 0.3, +0.15 per bounce, to 0.6 | new |
| Nuke Launcher | Mushroom Cloud | Sty | one nuke kills four or more | kills inside 3 s by damage type `Nuke` (inflictors `NuclearRocket`, `NuclearExplosion`, `SpawnedExplosionNuke`) or its `NuclearFlames` (`fire`), one launch | 0.1 per kill past 3, to 1.0; big moment at 10 | new |
| Nuke Launcher | Danger Close | Dar | a nuke kill while you stood within 768 units of the blast and lived | the `NuclearRocket`'s death point vs the player's position at the kill | 0.5 | new |
| Plasma Gun | Fan Fire | Sty | one alt-fire fan kills three or more | kills by `PlasmaBall75` spawned on the same tic (BD22's own alt fire, untouched) | 0.2 per kill past 2, to 0.6 | new |
| Railgun | Skewer | Sty | one rail kills two or more | same-tic kills by damage type `Railgun` (puff `RailgunPuff2`, `RailgunProjectile`) or `RailgunPenetrator`, one shot | 0.4 each extra, to 1.2; big moment at 3 | new |
| Railgun | Glass | Dar | the Ruger's Glass row, for the Railgun (it has the same live scope) | `RailGun` firing, as above | 0.4 (0.6 at 2048) | new |
| BFG9000 | Tracer Count | Sty | the spray of one ball kills two or more | kills by `SuperBFGExtra` (is `BFGExtra`) within 1 s of one `SuperBFGBall`'s death; the ball's own direct kill counts as the first | 0.1 per tracer kill past 1, to 0.8 | new |
| BFG10k | Green Rain | Sty | five or more kills in one hold | inflictor `BFG10K_Ball` (its `Extreme` type is shared with the rail penetrator, so the class decides) | 0.1 per kill past 4, to 0.6 | new |
| Unmaker | Unmade | Dar | an Unmaker kill of a monster of 1000 spawn health or more | inflictor `UnmakerLaser*` (damage type `desintegrate`; the BFG's is the same word, so the class decides) | 0.3 | new |
| Flamethrower | Wildfire | Sty | the burn-out kill: a monster killed by the fire of a burning body you lit | BD22's fire death (`Death.Fire`) spawns a burning runner (e.g. `BurningImpRunning`, `actors/Gore/Burn.dec`) that throws `BurnParticles` (A_Explode, DamageType `Fire`). Kill by `BurnParticles`/`BurnDamageSmall`/`BurnDamageLarge` whose source is a `Burning*` actor spawned at the spot of your `fire` kill within 1 tic: credit you. Today that kill is probably credited to nobody: measure first. | 0.5 | new |
| Flamethrower | Firestarter | Sty | three or more fire kills in one hold | inflictor `FlamethrowerProjectileNew*` with `Flamethrower2` firing | 0.15 per kill past 2, to 0.6 | new |
| Axe | Tomahawk | Mel | a thrown axe kills, more from far | inflictor `ThrowedAxe`/`ThrowedAxeStrong` (damage type `Saw`); +0.15 when it reached the target its lock ring marked (`rsvr/axegrab.zs`, `RSVR_AxeLock`) | 0.3 (0.45 locked) | new |
| Axe | Twin Axes | Mel | both hands' axes struck one monster within 1 s, either killed | blows by `AxeAttack*`/`AxePuffs` from `BrutalAxe` and from `RSQ_Off_BrutalAxe` | 0.3 | new |
| Chainsaw | Rip and Tear | Mel | a chainsaw kill of a monster of 400 spawn health or more | inflictor `SSawPuff2`/`SSawPuff3`/`SawDamageHorizontal*` (damage type `Cut`) with `Chain_saw` in hand | 0.5; big moment at 1000 | new |

## Cross-weapon rows (any gun in scope)

| Name | Fam | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|
| Last Round | Eff | the killing shot was the magazine's last round | the firing gun's magazine at 0: BD22's `Weapon.AmmoType2` (e.g. `RifleAmmo`, `ShotgunAmmo`, `RailgunAmmo`, `BrutalRevolverCylinder`), the off-hand copy's `RSQ_DualTable.Mag` (`...Off`), or `RSQ_Mag_<Gun>` for the nine counter guns (`counters.zs`: Minigun, Machinegun, Flamethrower2, Unmaker, NukeLauncher...). A missile carries the count from its fire tic (noted at WorldThingSpawned). | 0.25 | stale rework (BONUS_IDEAS "Dry") |
| Hot Reload | Dar | a kill with the reloaded gun within 3 s of a hand reload that you finished while taking damage | needs one fact from BD22 VR: when each hand's reload started and seated. The phases live in `RSR_State.SetPhase` (`rsr/vreload.zs`), `RSP_State` (pump, `rsr_pump.zs`) and `RSB_State` (break-open, `rsr_break.zs`); their tokens (`RSR_Go`, `RSR_Seated`, `RSR_Done`) last one tic. Proposed: a small `RSQ_WeaponService` answering `reload.start` / `reload.seat` as "tics ago", per hand. The reload pays nothing alone. | 0.35 | stale rework (BONUS_IDEAS "Tactical") |
| Crossfire | Sty | one monster hit by BOTH hands' guns within 1 s, either hand killed it | per-blow hand in WorldThingDamaged (`RS_Physical.ShotHand` / `ButtonsAt`: `BT_ATTACK` vs `BT_OFFHANDATTACK`), kept per victim. Two Guns pays two kills; this pays one body. | 0.3 | new |
| Headshot | Sty | BD22 counted it a headshot | killing damage type `Head` or `MinorHead` (`actors/MISC/Head_Sys.dec` `HeadshotTargetBase`, monsters' `Death.Head`). The blow comes from the hitbox's A_Explode, so check who the source is; if not you, credit the player whose shot struck that `HeadshotTarget*` on that tic. | 0.25 (0.4 from the Ruger or the Moonlight) | new |
| Sights Up | Sty | a gun kill at 768 units or more with the shot's line within 2 degrees of the head's facing (aimed down the gun, not from the hip) | the shot line vs `RS_PhysicalNotes` head facing; Rifle, BrutalSMG, Machinegun, AssaultShotgun, pistols. Glass replaces it on the Ruger and Railgun. | 0.2 | new |
| Hold streak (one mechanism) | Sty | Street Sweeper, Beltfed, Bullet Hose, Green Rain and Firestarter are one counter with a name and threshold per gun | the trigger-down tic in `RS_PhysicalNotes`; kills by that gun since then | per gun, above | new |

## The combo ledger: split `gun` into gun classes

**Proposal: yes.** Today every gun is the one tool `gun` (`combo.zs` `RS_Tool.Classify` ends `return "gun"`).
Split it into ids under the `gun.` prefix, and the axe and chainsaw under `blade.`:

| Tool id | Guns (class names) |
|---|---|
| `gun.pistol` | `BrutalPistol`, `BrutalRevolver`, `Revolver` (slug included) |
| `gun.shotgun` | `Shot_Gun`, `SSG`, `AssaultShotgun` |
| `gun.rifle` | `Rifle`, `Machinegun`, `BrutalSMG`, `MiniGun`, `Sniper` (bullets) |
| `gun.explosive` | `Rocket_Launcher`, `GrenadeLauncher`, `NukeLauncher`, the Rifle's and Machinegun's 40 mm (`ShortGrenade`) |
| `gun.energy` | `Plasma_Gun`, `RailGun`, `BIG_FUCKING_GUN`, `BFG10k`, `Unmaker` |
| `gun.fire` | `Flamethrower2` (and its `Burning*` spread, Wildfire) |
| `blade.saw` / `blade.axe` | `Chain_saw` / `BrutalAxe` (thrown axe included) |

Why this does not break anything:
- `RS_Tool.InGroup` already matches a step by the prefix before the dot, so every existing pattern that says
  `gun` ("force.push > gun", Gun Kata "hands > gun") or `blade` still matches every class.
- Swapping guns must stay Switcharoo's business. So `RS_Tool.ActionOf` maps every `gun.*` to one action
  `gun` (and every `blade.*` to `blade`) when the generic 2-, 3- and 4-tool combos count tools. Only a NAMED
  combo can name a class.
- Classify: inflictor class first (missiles: the table above), then for a puff the gun in the hand that
  fired (`ReadyWeapon` / `OffhandWeapon` by `ShotHand`), mapped by a class table. A gun not in the table
  (another weapon set) stays plain `gun`, so non-BD22 play is unchanged.
- The melee tools named below that Score does not have yet (`punch.upper`, `shove`, `pistolwhip`, `grenade`)
  should use whatever ids the melee and grenade lanes settle on. The handoff's rule holds: the BD22 butt strike
  and RSQ Melee's gun-butt shove are ONE tool (`shove` here), whichever mod delivered it.

### Named 2- and 3-tool chains (owner, 11-03: "of course we need to expand 2-tool combo and 3-tool combos")

Patterns read as today: steps in order, the last is the finishing blow, 3 s breaks the chain. Some need a
condition on the finishing blow. Proposed: an optional condition word in `RegisterCombo`, taken from facts
other rows already work out: `air` (the victim airborne, as Juggle/Skeet), `pb` (Point-Blank, 64 units), `head`
(Headshot, above). The condition rows still pay their own pay; the chain pays only its own. Pays follow the
table's scale today: 2-tool 0.4 to 0.6, 3-tool 0.9 to 1.0.

New tool ids used here: `punch.upper` (RSQ Melee's uppercut; it already answers `RSQML_Service "punch.kind"`,
which no row reads yet), `shove` (butt strike / gun-butt shove), `pistolwhip` (BD22 VR's pistol whip, which
lands as BD's punch today, so it is `punch` until split), `grenade` (RSQ Grenade's blasts, `RSQGN_Blast*`).

| Name | Pattern | When | Pay |
|---|---|---|---|
| Launch Pad | `punch.upper > gun.shotgun` | air | 0.6 |
| Get Over Here | `hook.yank > gun.shotgun` | pb | 0.6 |
| Executioner | `pistolwhip > gun` | head | 0.6 |
| Hostage | `grab.hold > gun.pistol` | | 0.5 |
| Door Kick | `kick > gun.shotgun` | pb | 0.5 (replaces Gun Kata) |
| Fastball | `grab.throw > gun` | | 0.4 |
| Cowboy | `whip > gun.pistol` | | 0.5 |
| Flush Out | `grenade > gun.rifle` | | 0.4 |
| Rip and Pump | `blade.saw > gun.shotgun` | | 0.4 |
| Mop-Up | `gun.explosive > blade.saw` | | 0.5 |
| Laser Sword | `saber.cut > gun.energy` | | 0.5 |
| Over-Under | `gun.explosive > gun.rifle` (one gun's 40 mm and bullets) | | 0.4 |
| Pistol Kata | `shove > gun.pistol` | | 0.5 |
| F.E.A.R. Effect | `shove > gun.shotgun`, in the slow-motion window | | keeps its award pay; becomes this chain's backing row, so the chain adds nothing |
| Bouncer | `grab.hold > punch > gun.shotgun` | | 0.9 |
| Gunslinger | `hook.yank > pistolwhip > gun.pistol` | | 0.9 |
| Air Show | `punch.upper > gun.pistol > gun.shotgun` | air | 1.0 |
| Demolition | `grenade > shove > gun.shotgun` | | 0.9 |
| Jedi Gunner | `saber.cut > force.push > gun.energy` | | 0.9 |
| Scorched Earth | `gun.explosive > gun.fire > blade.saw` | | 0.9 |

Also propose: a three-step named chain stays a big moment (as today), and Air Show at 1.0 is one too.

## Stale Score rows about weapons

1. **Boot fires on a grenade (bug).** BD22's `GrenadeMissile` (the Grenade Launcher's bouncing alt fire,
   `actors/Weapons/Explosives.dec`) has `DamageType Kick`. A direct-impact kill reads as a boot in
   `RS_Melee.KindOf` (MK_BOOT): Boot 0.2, Juggle/Counter-style melee rows, and the combo tool `kick`, so
   "kick > gun" can fire Gun Kata with no kick. Fix: a missile inflictor is never a boot.
2. **Brawler never pays the BD22 chainsaw or axe.** Its table names `Chainsaw`; BD22's saw is `Chain_saw`,
   which replaces nothing (only the pickup `ChainsawSpawnerReplacer` replaces `Chainsaw`), and `BrutalAxe` has
   no entry. The fists pay 0.5, the saw 0. Decide: add both, or leave the blades to Cleaved, Heavy Swing and
   the rows above.
3. **Switcharoo is inert under BD22.** It waits for a weapon to call `RS_ScoreHandler.Switcharoo`; nothing in
   BD22 VR calls it (grep of `rs_brutal22weaponsq/src`). Rework: record the fire from WorldHitscanFired and
   from a player's missile spawning (slot from the ready weapon, mode from `BT_ALTATTACK`).
4. **Scrapping is dead.** It pays damage type `Scrap`, which no BD22 attack has, and its slot fallback runs
   only with no damage type, which BD22 always gives. Rework: Coach Gun (above), or drop it.
5. **The combo ledger's single `gun` tool**: the split above.
6. **Hot Swap and Quick Draw read only the main hand** (`ReadyWeapon`): an off-hand `RSQ_Off_*` kill is judged
   by the main gun. Read the firing hand's weapon.
7. **Headshots are not seen at all** (`Head` / `MinorHead`), and who gets the credit is unmeasured.
8. **Score README load order** names BD22 VR 2.0.3h plus the hotfix; the pack is 2.0.3o now.
9. **BONUS_IDEAS.md** "Reload: Dry, Tactical", "One Shot" and "Chain" are superseded by Last Round, Hot Reload,
   Hand Cannon / Magnum Slug and the same-tic multi-kill rows here.

## To measure before building

- Who gets the kill for a rocket's or grenade's blast spawned as a separate actor (`GrenadeExplosion`,
  `NuclearExplosion`), for a headshot hitbox, and for a burning runner's fire.
- Whether a rail's damage reaches Score with the puff as the inflictor or the player (Skewer reads the type, so
  either works).
- None of the windows and thresholds here (10 tics, 3 s, 768 / 1024 units, 2 degrees) were tried; all are
  first guesses for the rig, then the headset.
