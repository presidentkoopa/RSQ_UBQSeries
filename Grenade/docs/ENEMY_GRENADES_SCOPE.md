# Shoot enemy grenades (BD22 / XMVE): feasibility scope

Owner request (11-03 20:39): "Scope the feasibility of being able to shoot incoming grenades from BD enemies and
XMVE enemies. The feature can stand down when those mods are not detected."

This is scoping only. Nothing was built and no repo file was edited. Every number here was parsed from the parent
mods' DECORATE (extracted to `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/enemynades/`)
or from the engine source at `/home/claude/qzdeng` (GZDoom 4.14.3, which is what qzd17.3 is, per BD22 VR's
`rsq/recoil.zs` header). Nothing here has been shown working on the rig or in the headset.

## 0. Headline

* **BD22 test6: no monster throws or fires a grenade.** `MarineGrenade`, `ZombiemanGrenade`, `CyberDemonGrenade`,
  `BouncingGrenade` and `GrenadeMissile` are defined in `actors/Weapons/Explosives.dec`, but no monster fires
  any of them. `CommandoGrenade` appears only in commented-out lines (Comando.dec:178, Ubersoldat.dec:201) and is
  never defined. `HandGrenade` and `HandGrenadeAlt` are thrown by the player only. Monster explosives in BD are all
  **rockets**.
* **XMVE: one live enemy grenade, `AGLMissileMonster`**, fired by TerminatorDemon, TerminatorBoss and CyberBaron.
  All three are reachable through the 05/06 spawners. Two more are dead code on this load order: `ZombiemanGrenade`
  (its jump is commented out in ZombiemanHelmets.dec:284, and HelmetRifleZombie is shadowed by the spawner) and
  `pain_gernade` (DarkCardinal / DarkCardinalBOSS; it is not an explosive anyway, see the table).
* So **"grenades only" amounts to one class**. To give BD enemies anything to shoot, rockets have to be in scope. That
  is the owner's call, and section 4 lists them.
* It can be done in stock QZD 17.3 ZScript. Nothing needs an engine change.

## 1. How "Shoot Thrown Grenades" detects today (read from code)

| Path | RSQ Grenade (`Grenade/zscript/rsqgn/hand.zs`, `thrown.zs`) | BD22 VR (`src/zscript/rsg/grenade.zs`) |
|---|---|---|
| Hitscan | `WorldHitscanPreFired` (hand.zs:385). Console player only. Melee (reach 128 or less) is skipped. Both VR hands' rays are tested (`AttackPos` / `OffhandPos`). Point-to-ray miss of at most `ShotR()`, then `SendNetworkEvent("rsqgn_skeet", pos*8)`. `NetworkProcess` picks the grenade nearest that point within 32 units and calls `Shot()`. | Same at grenade.zs:135. The rays come from `RSVR_VRHand`. The event is `rsg_shoot`, nearest within 32 units. |
| Projectiles | `WorldThingSpawned` pushes every `bMissile` actor into `missiles` (pruned each tic). Each thrown grenade's own `Tick` runs `ShotByMissile()`: a missile whose `target.player` is set and whose `GetMissileDamage>0`, centre distance at most `ShotR()+t.radius`. | `WorldThingSpawned` splits actors into `nades` (HandGrenade/HandGrenadeAlt) and `missiles`. `ShotTick()` from `WorldTick` runs the same test. |
| Detonate | `Shot()` then `Detonate()`, then `SetStateLabel("Boom")` (its own actor) | Spawns `FragGrenadeExplosion` with `target` = thrower (plus `RSG_Skeet` if in the air), then `Destroy()`s the grenade |
| Gates | `rsqgn_shoot`, `rsqgn_shot_r` (0.10 to 0.35 m, at most 12 u), `rsqgn_shoot_slowmo`; `SHOT_GRACE` 6 tics | `rsg_shoot`, `rsg_shot_r`, `rsg_shoot_slowmo`; same grace |

Two weaknesses in the current code matter more once the targets move fast (section 2):
* **The projectile test is point-sampled.** It compares positions at tic end only. A 12-unit window misses most
  passes between a fast player projectile and a fast enemy one. The fix is a swept closest approach between
  `Prev` and `pos` for both actors (`native vector3 Prev`, actor.zs:99).
* **The network match uses "nearest within 32 units", one tic later.** The event is processed on a later tic.
  `AGLMissileMonster` moves 50 units a tic, `ZombieRocket` 45 and `EnemyHelicopterRocket` 75, so they are already
  outside the 32 units. The event should send the tracked array index plus a class check. The array is built in the
  playsim, so it is identical on every machine.

## 2. Class table: every monster-fired explosive projectile reachable on this load order

Flags and numbers are parsed from DECORATE. "Shootable now" means `+SHOOTABLE` is on the class.

### Grenades (lobbed, gravity, fuse)

| Class | Mod / file | Fired by | Radius x Height | Speed | Gravity / bounce | Fuse | How it explodes | Shootable now |
|---|---|---|---|---|---|---|---|---|
| **AGLMissileMonster** | XMVE Terminator.txt:390 | TerminatorDemon (RTshot), TerminatorBoss (inherits), CyberBaron (AGLfire, 96/256 branch) | 4 x 4 | 50 | 0.7, **no bounce** (`+DOOMBOUNCE` commented out). It bursts on first contact. `+SKYEXPLODE +EXPLODEONWATER` | `GrenadeTime` token on itself, 6 loops x 8 tics = **48-tic** airburst | Death: `A_NoBlocking`, then `A_SpawnItem("AGLMissileExplosionMonster")`, which runs `A_Explode(50,200)` after 1 tic and then 5 damage-less `AGLMissileClusterMonster` visuals (+NOBLOCKMAP +THRUACTORS, Damage 0) | No |
| pain_gernade | XMVE DarkCardinal(BOSS).txt:136 | DarkCardinal / DarkCardinalBOSS | 11 x 8 | 20 | -NoGravity, `+DoomBounce` | none | **Not explosive.** On death it spawns `Fire`, which spawns the monster `paingasm`. It is a summon, not a grenade. | No. Not reachable while the 05/06 CyberdemonSpawner wins the Cyberdemon replacement. |
| ZombiemanGrenade | BD Explosives.dec:935 | (XMVE HelmetRifleZombie; its jump is commented out) | 4 x 4 | 10 | grav 1.0, bounces floor/wall/ceiling 0.7 | none | Death: `A_Explode(200,300)` | No. Dead code. |
| MarineGrenade, CyberDemonGrenade, BouncingGrenade | BD Explosives.dec | nobody | 4 x 4 | 20 / 28 / 55 | bouncing | n/a | `A_Explode(200,300)` / `(200,200)` | Dead code |

### Rockets (straight or homing, explode on impact)

| Class | Mod | Fired by | R x H | Speed | Notes | Blast | Shootable now |
|---|---|---|---|---|---|---|---|
| VanillaCyberRocket (`replaces Rocket`) | BD Explosives.dec:247 | EvilMarineRocket (`"Rocket"`), any vanilla Rocket user | 4 x 2 | 20 | Rocket2 child: spawns 3 `RocketBackblast` FastProjectiles (damage 12, +RIPPER) behind it | Death spawns `RocketExplosion` = `A_Explode(160,200)` after 3 tics | No |
| CyberBalls / CyberBalls_Slaughter | BD :791 | TheCyberdemon (4-shot volleys), Annihilator, TerminatorBoss | 10 x 8 | 20 | ACS `BDCheckJanitor` on spawn (cosmetic) | Rocket2 Death, then `RocketExplosion` | No |
| JuggernautRocket | BD :256 | Juggernaut (ST, ednum 2545), 2 per volley | 4 x 2 | 20 | | RocketExplosion | No |
| EnemyHelicopterRocket | BD | ZombieHelicopter (map-remap vehicles) | 4 x 2 | 75 | | RocketExplosion | No |
| EnemYTankShell / MechMortar | BD | ZombieMainBattleTank / ZombieMech | 6x6 / 11x8 | 50 / 40 | vehicles | TankShotExplosionImpact / `A_Explode(300,300)` | No |
| revenantseekermissiles, RevenantMissile, _slaughterfest, LessBullshittyRevenantMissile | BD Revenant.dec:864 | Revenant1 (2 per volley), AncientFlyingCunt | 10 x 4 | 10 / 20 | homing; `-NOBLOCKMAP`, `Health 10`, `//+SHOOTABLE` commented out | `A_Explode(7,120,1)` in Death | No |
| ZombieRocket | XMVE(07) RocketGuy.txt:1053 | RocketGuy | 10 x 8 | 45 | `: Rocket` (stock parent) | spawns `ZombieRocketExplosion` = `A_Explode(25,100)` | No |
| **ZombieRocket2** | XMVE(07) :1124 | RocketGuy (homing shot) | 10 x 8 | 25 | **`+SHOOTABLE`, `Health 10`, `-NOBLOCKMAP`** | same | **Yes. A bullet already kills it**, but the blast is credited to the RocketGuy (see 3) |
| CyberKnightMissile | XMVE CyberKnight.txt:1031 | CyberKnight, CyberBaron | 4 x 4 | 32 | | `A_Explode(40,130,1)` in Death | No |

Not counted (fireballs or plasma, not ordnance): imp/baron/caco balls, `PyroBlast`, `FallingComet`,
`DraugrDemonMeteor*`, Thamuz `DCBMiss*`, Overlord `StormShot*`, plasma balls, and the monster bullet tracers
(`MonsterTracer` and the rest, which are projectiles in BD). `DMissile` (Diabloist) is never defined, so it spawns nothing.

## 3. Answers

### (1) Detection, by class name, standing down when BD/XMVE are absent
Yes, with the same three hooks that exist today:
* **List:** `WorldThingSpawned` keeps actors whose class is in a table resolved once in `OnRegister`/`WorldLoaded`
  (`String n = "AGLMissileMonster"; class<Actor> c = n;`). A null entry means that mod is absent. An empty table
  means the feature does nothing. Match the exact class or a listed parent (for example `revenantseekermissiles`
  covers its children).
  Also require `target && target.bIsMonster && !target.bFriendly && !target.player`, so BD's Brutal Friends rockets
  (`MarinesRocket`, `FriendBullet`) and player rockets that share `Rocket2` are never caught.
* **Hitscan:** reuse `WorldHitscanPreFired` and the two hand rays. Reach is `ShotR() + t.radius`, the same rule the
  projectile path uses now. Send the tracked index, not a position (section 1).
* **Rails:** `WorldRailgunPreFired` exists on 4.14.3 (events.zs:169). BD's railgun uses `A_RailAttack` (10 call
  sites), which does not raise `WorldHitscanPreFired` (that hook is only in `P_LineAttack`, p_map.cpp:4718). Without
  this hook the railgun would not trigger detonations.
* **Projectiles:** a swept player-projectile vs enemy-projectile test in `WorldTick`. The player's guns are mostly
  hitscan (BD's weapons have 106 `A_FireBullets` calls), so this path matters mainly for plasma and rockets.
* **Already shootable (ZombieRocket2):** `WorldThingDamaged` fires before `CallDie` (p_interaction.cpp:1612/1615).
  If a tracked missile reaches health 0 or less from a player source, set `target = source` there, so the blast is
  credited to the player.

### (2) Cost on Quest
* Typical alive counts, from fire rates in the code:
  * AGL: 0 most of the time, at most about 2 per Terminator or CyberBaron (one per 24-tic cycle, 48-tic life).
  * Rockets: 1 to 4 per volley (Cyberdemon 4, Revenant 2, Juggernaut 2).
  * Revenant seekers are slow (speed 10) and long-lived, so a room of five revenants means about 10 alive. A
    slaughter map can mean dozens.
* Per hitscan: N tracked x 2 rays, each a handful of vector operations. 20 tracked means 40 tests per shot.
* Per tic: E enemy x P player-damaging projectiles in the swept test, for example 20 x 10 = 200 segment tests.
  That is small. It has not been profiled on the headset.
* The dominant cost is already paid: `WorldThingSpawned` runs for every BD particle. The table check sits behind
  `bMissile`, as the existing code does it.

### (3) Detonating a projectile we do not own
* **Use `ExplodeMissile()`, not `SetStateLabel("Death")`.** `P_ExplodeMissile` (p_mobj.cpp:1586) does four things
  that `SetStateLabel` does not:
  * zeroes velocity
  * clears SHOOTABLE
  * plays DeathSound
  * runs the Death chain while `MF_MISSILE` is still set, and clears it only afterwards
  With `SetStateLabel`, a rocket keeps flying and is still a missile, so it can impact again and explode twice. A
  missile killed through `Die()` also goes through `P_ExplodeMissile` (p_interaction.cpp:407).
* **Credit:** set `missile.target = player` before `ExplodeMissile`.
  * Blasts in the Death state (`A_Explode` on CyberKnightMissile, the revenant missiles, ZombiemanGrenade) use
    `target` as the source.
  * Spawned explosions (`RocketExplosion`, `ZombieRocketExplosion`, `AGLMissileExplosionMonster`) inherit it.
    `A_SpawnItemEx` walks `originator` through `bMissile || default.bMissile` to `.target` (attacks.zs:220) and
    sets `mo.target = originator` (:271). `A_SpawnItem` goes through the same `InitSpawnedItem`.
  * Result: the player is the damage source, so kills count and Gun Bonsai or Score see a player kill. Side
    effect: monsters hit by the blast now target the player.
* **Score's Trap Shot does not pay as written.**
  * Its Evaluate is `MK_GRENADE && Tagged("skeet")`.
  * `MK_GRENADE` comes from `RS_Tool.Classify`, which recognises inflictors by name only: RSQGN_Thrown,
    RSQGN_HandBlast, HandGrenade, FragGrenadeExplosion (tools.zs:282). `RocketExplosion` and the others classify
    as something else.
  * The row's own wording is "your grenade, shot by you".
  * Making it pay needs two things:
    1. Tag the blast. Give a token to the missile, and to anything spawned synchronously during the
       `ExplodeMissile` call: all the spawns above happen in 0-tic Death frames, so a handler flag set around the
       call catches them.
    2. A Score change: Classify plus a row.
  * Whether that is Trap Shot or a new row is the owner's call. This scope invents no names.
* **In flight vs bouncing:** every reachable target bursts on contact or flies straight, so it is in-flight only in
  practice. For a bouncing or resting grenade, if one ever appears, `ExplodeMissile` still works. It is just the
  state change, and it is safe even after bounce auto-off clears `MF_MISSILE`.

### (4) Risks
* **Rockets vs grenades:** see the two tables. Grenades only means `AGLMissileMonster` and nothing from BD.
* **Self-damage:** the blast hurts whoever is near it. `A_Explode`'s default `XF_HURTSOURCE` applies, and with the
  player as source it still hurts the player. Shooting a CyberBall 2 m away costs `RocketExplosion` 160 over 200
  units. On skill 6, BD's `Damage_Control` multiplies monster and player damage alike by 7, so nothing changes
  there. The existing feature has no minimum distance either. Adding one is the owner's call.
* **Friendly fire:** the `target` filter above excludes friendlies. In co-op, any player's shot counts and the
  credit goes to the shooter.
* **BD tricks:**
  * `Rocket2` spawns damaging `RocketBackblast` FastProjectiles (+RIPPER, damage 12, `target` = monster). These are
    excluded by the class table, but the generic `missiles` list in the existing feature does include player-rocket
    backblasts.
  * ACS on spawn (`BDCheckJanitor`, `CheckIfDM`) is cosmetic.
  * No fake or proxy actors stand in for these projectiles. The explosion actors are spawned inside Death, which
    the retarget covers.
  * BD's only ZScript handler (`Script_DamageMult`) touches monsters and players, not missiles.
* **Revenant seekers are slow and numerous.** With rockets on, a room of revenants becomes a skeet range. That is a
  balance change that touches BD22's identity rule: "same role, same feel, same balance".

### (5) Recommendation
* **Host: BD22 VR Reloaded** (`rsg/grenade.zs`, next to `RSG_Handler`'s shoot code).
  * Both enemy sets exist only on BD22. The "-BD22" XMVE requires it.
  * RSQ Grenade stands itself down whenever BD22 VR is loaded (`RSQGN_Handler.BDVR()`), so on the owner's load
    order it is not running.
  * A copy in RSQ Grenade (for BD without BD22 VR) can come later, under the same stand-down rule.
  * RSQ SlowMo is not a fit: it only scales time. The "Only in Slow Motion" gate reads it by service, as now.
* **Menu rows:** match how the series writes toggles (the existing rows are `Option ... "OnOff"`). Proposed rows,
  for the owner to confirm:
  * "Shoot Enemy Grenades" (on)
  * "Shoot Enemy Rockets" (off; the balance question above)
  * Reuse the existing "Shot Grenade Reach" and "Only in Slow Motion" rows rather than adding new ones.
  * The rows show only when a class from the table resolved, or say "(BD/XMVE not detected)".
* **Effort:** about 150 to 200 lines of ZScript, plus CVARINFO, MENUDEF and LANGUAGE. That covers the class table,
  tracking, hitscan, rail and swept-projectile tests, retarget-and-ExplodeMissile, the `WorldThingDamaged` retarget,
  the token tag and the debug log. Roughly half a day to a day including the rig proof:
  * summon TerminatorDemon, CyberBaron and RocketGuy
  * log "AGLMissileMonster shot down by hitscan hand 0, blast source = player, kill counted"
  * capture frames
  * Score's Trap Shot change is separate, in RSQ Score.
* **What needs an engine change: nothing.**
* **Limits:**
  * A one-tic latency from the network event (already true for the current feature).
  * Point-sampled projectile tests would miss fast passes, so the swept test is needed.
