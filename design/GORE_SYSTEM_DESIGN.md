# RSQ Gore: a fast replacement for Brutal Doom 22's gore (design only)

Written 2026-11-27 for the owner's review. **Nothing is built.** Every claim below is code-read from BD22's and XMVE's
extracted source and the QuestZDoom 17.3 source (E:\DOOMWork\QZD17-engine), or was measured on the rig today. None of it
is rig-shown or headset-confirmed yet.

Series guiding statement: **Doom Arcade VR.** Owner: BD22's "death and dismemberment is its best feature and its highest
cost"; the replacement must be "just as brutal".

## Summary

- **RSQ_Gore** is one pk3, loaded like any other (no autoload). An event handler takes over BD's and XMVE's gore classes
  by name at spawn (`CheckReplacement`). BD22 and XMVE are not edited. With the master switch off, BD's own gore runs
  exactly as today.
- **The look stays.** Monsters and their death states are untouched, so every death variant plays. Only what the
  death states spawn is redirected, and it uses BD's own sprites, models, decals and sounds by name. RSQ_Gore ships no
  art.
- **The cost moves.**
  - Liquid becomes engine particles and parked VisualThinkers: no actors, no per-tic script.
  - Wall blood becomes decals.
  - Floor and ceiling blood become one parked, non-thinking actor each, merged and pooled.
  - Meat and limbs are actors only while they fly; then they freeze under a hard cap, oldest recycled.
- **Head and leg shots stay RSQ Score's.** Score built the verdict on 11-09. The one new piece is taking over XMVE's
  per-frame helper actors (section 3); the recommendation is that it goes into Score.
- **Netplay.** Anything that is an actor is decided identically on every machine. Only particles, VisualThinkers and
  decals may vary per machine, and they never call a shared RNG.

## 1. Goals and the bar

**"Just as brutal" means:**

- Every BD and XMVE death variant, chosen by the same rules (damage type, overkill, tokens, attacker inventory, A_Jump).
- The same sprites and colours (red, Green_, Blue_, Alien_): BSPR, GTXZ, BL8A, BLOR, the BPDL md3 flats, XMT1, XARM,
  GUTS, and the rest.
- The same ingredients:
  - per hit: the hit puff, sprays, mist and arterial jets;
  - on walls and ceilings: splats, with drips from the ceiling;
  - on the floor: spots, growing pools, footprints and boot smears;
  - from the body: meat, guts, organs, limbs, heads and halves;
  - and the sounds.
- Residue that stays on the map within an owner-picked budget, never wiped by a timer.
- The same gameplay side effects (section 5).

**Today (measured, 100-monster wave, ~25 s):**

- **Spawns.** ~1,500 actor spawns/s, ~400/s of them gore. Top gore spawners: Brutal_FlyingBloodTrail 103/s,
  BloodDripingFromCeiling 25.5, Brutal_LiquidBloodTrail 18.7, SuperGoreMistTiny 17.1, Brutal_BloodSpot 16.3,
  BloodSplasher_Red 13.5, Brutal_Blood 12.0, HeadshotTarget4 11.2, LegTarget4 8.3.
- **Peak.** 2,900 actors, 1,605 of them thinking. Live gore at peak: FlyingBloodTrail 611, LiquidBloodTrail 94,
  DripingBloodLeavesSmallPool 56, FlyingBloodFaster 55, SuperGoreMistTiny 51, SuperGore 45, CeilBloodTinyBloodSpawner 35,
  Guts 28. That is about 1,050 thinking gore actors.
- **One ZombieXDeath** makes 54 direct spawns and about 150-250 actors in its first second.
- **Script time** is 4-7 ms/tic, but the gore cost is mostly engine-side (ticks, movement, blockmap, sprites), which the
  script timer does not see.

DistanceCheckerCeiling (15.7/s) is LiveReverb's, not gore, so it is out of scope.

**Targets (to confirm on the rig):**

| Measure | Today | Target |
|---|---|---|
| Live thinking gore actors at peak | ~1,050 | ≤ 150 (flying chunks only) |
| Gore spawns/s | ~400 | ≤ 150 after phase 2, ≤ 80 after phase 4 |
| Actors per ZombieXDeath, first second | 150-250 | ≤ 30, all of them visible chunks |
| Residue that ticks | some, forever | none |
| Manager script time at peak | n/a | ≤ 0.3 ms/tic |

**Two facts found while reading:**

- **QZD's defaults are Quest-tuned.** `cl_maxdecals` is 20 (g_cvars.cpp:102) and `sv_corpsequeuesize` (BD's "Max gibs")
  is 10 (g_cvars.cpp:85). On those defaults BD already culls its queued residue to 10 pieces and its wall blood to 20
  decals.
- **BD's per-hit blood probably runs at "Low".** With `isrunningzandronum = 1` (the default), `BD_CheckBloodIntensity`
  reads `BDCVarInfo[PlayerNumber()]` with the blood as activator, which is player -1 (Options.acs:430-445).
  ArterialBlood22Small (from the Spawn2 extras) is missing from the top spawners, which fits.

Phase 0 confirms both, reading live values from the console, never the ini.

## 2. Architecture

### 2.1 Two tiers

| Tier | What | Rules |
|---|---|---|
| **Playsim** | anything that is an actor (hit blood, chunks, limbs, spots, pools, casings), tokens, screen-blood scripts, boot smears | identical on every machine: server cvars, distance to the **nearest player** (never the console player), `random[RSQGO_Play]`, global caps |
| **Cosmetic** | particles, VisualThinkers, decals | may vary per machine (local camera LOD, user cvars, optional frame-time guard); uses a handler-held xorshift, never a shared RNG; never spawns an actor |

Why: spawning a MONSTER-flagged actor consumes `pr_spawnmobj` (p_mobj.cpp:4823-4832), and random state tics consume
RNG. An actor that exists on one machine only can therefore desync a network game.

### 2.2 The manager (`RSQGO_Manager : EventHandler`)

- **Takeover.** `CheckReplacement` maps classes through a class-keyed cache (section 4). It runs on every spawn in the
  game, so after a class's first sighting the lookup is one map read.
- **Budgets and rings.** Live counts per category, spawn budgets per tic from the preset, and one ring buffer per residue
  kind (floor spots and pools, ceiling spots, meat, limbs, footprints, casings). When a ring is full, its oldest entry is
  destroyed or reused.
- **Merge grid.** A 64-unit cell hash of floor spots. A new spot inside an existing spot's radius on the same floor
  (±2 units) grows that spot, up to a maximum, instead of adding an actor.
- **Schedules.** Small arrays walked once a tic; no ThinkerIterator or BlockThingsIterator.
  - drips;
  - pools growing on BD's 70-tic scale ramp;
  - screen-blood calls (a 3-tic delay);
  - smear zones (checked every 8 tics);
  - VisualThinker frame flips.
- **VisualThinker parking.** The series' pattern (Miniboss fx.zs, VisualRewards): parked in a non-ticking statnum, one
  driver. RSQ_Gore takes statnum 27 for VisualThinkers and 26 for parked actors; 28-30 are already taken.
- **Cosmetic emitter.**
  - Spray density scales with distance to the local camera: full under 512 units, half to 1,536, a quarter beyond,
    no mist past 3,072.
  - Live particles stay under half of `r_maxparticles` (a user cvar, default 4,000).
- **Optional frame-time guard (Q5).** It thins sprays and mist when frames run long, on the cosmetic tier only.

### 2.3 Each category and what replaces it

| Category | BD today | RSQ_Gore | Actors left |
|---|---|---|---|
| **Hit blood** (Brutal_Blood, colour bloods, SawBlood, BloodSPlatterReplacer) | 1 actor, 1-5 children, one ACS script, an item per nearby player | `RSQGO_HitBlood`: works in PostBeginPlay (sound, liquid test, spray, screen-blood queue); the BSPR puff becomes a parked VisualThinker; the actor is gone on tic 1 | 1 (was 3-7) |
| **Flying blood and trails** (Brutal_FlyingBlood*, *Trail*, *Fake*, LiquidBlood*) | missiles living 15-100 tics; each landing spawns a spot | particles with gravity as acceleration, lifetime clipped to the floor below; drops that left a spot schedule one merged floor spot | 0 |
| **Mist and jets** (Bloodmist*, ArterialBlood22*, SuperGore*) | missiles with 25-60 one-tic frames | parked VisualThinkers (multi-frame) or particles (single frame) | 0 |
| **Wall blood** (WallRedBlood family, wall painters) | invisible projectile whose Decal paints the wall | `A_SprayDecal`, same decal name, along the throw direction at BD's range | 0 |
| **Ceiling blood** (CeilBloodLauncher*, CeilBloodSpot*) | 3-12 tic projectile; the spot thrusts every 5 tics forever | one upward LineTrace; on a hit, one parked `RSQGO_CeilSpot` in the ceiling ring | ≤ 1 |
| **Drips** (ceiling drip spawners and drips) | spawner ~800 tics; 56 drip spawns, ~90% die at once | the drip schedule drops particles to the floor; the first one adds a small floor spot; sound from the ceiling spot | 0 |
| **Floor spots and pools** (Brutal_BloodSpot family, Splattered*, GrowingBloodPool, footprints) | a permanent blockmap actor each, in the corpse queue | merge grid; one pool per body grows on BD's ramp, then parks; rings | ~1 per death |
| **Boot smears** (BootSmearerRed) | a MONSTER thinker, 880 tics | a smear-zone record in the manager | 0 |
| **Liquid checks** (WaterBloodCHecker, ACS BD_CheckIfOverLiquid) | projectile, ACS script, inventory token | a native floor-texture test on BD's own list (SPLASH.acs:252), TextureIDs cached | 0 |
| **Meat and guts** (XDeath1-6, Organs, Guts, Smearing*, CeilXDeath*, brain bits, eyeball, teeth, XJunk) | missile, a trail actor every 2 tics, permanent once landed | phases 1-2: BD's class, children replaced. Phase 3: `RSQGO_Chunk` from a generated card (same frames, bounce, sounds, ceiling stick); the trail is a particle call; on landing it parks itself | 1 per chunk |
| **Limbs, heads, halves** (XDeath*Arm/Leg/Head*, Gib_*, LimbBase, BigGibBase, TinyGib) | flying actor that spawns a shootable Gib_ on landing; the base spawns a spot every 1,900 tics | phase 3: `RSQGO_Limb` card: one actor flies, then becomes the shootable landed limb (LimbBase's damage factors); unparks on damage | 1 per limb |
| **Death groups** (GoreGroups.dec launchers, XMVE's *XDeath launchers) | 54-62 spawns in one tic | phase 4: a generated recipe runs BD's exact list in one call, routing each entry by category | 0 |
| **Casings** (EmptyBrass family) | 210 tics | fly, then park; ring; `bd_infinitecasings` honoured | 1 |
| **Corpses** | BD's | untouched (Q6) | n/a |

### 2.4 Engine facts it rests on (QZD 17.3)

- **Particles and VisualThinkers exist.**
  - `Level.SpawnParticle` / `A_SpawnParticleEx` (doombase.zs:382, actor.zs:1240) take a texture, velocity,
    acceleration, fade, size and roll. They cannot collide (hence the lifetime clip) and take no translation.
  - So colour variants become **generated TEXTURES entries**: BD's sprite patches with BD's translation strings.
  - Flipbooks with `SPF_LOCAL_ANIM` plus our own ANIMDEFS (p_effect.cpp:1115) are a phase-0 experiment; parked
    VisualThinkers are the proven fallback.
- **Decals are wall-only.** `A_SprayDecal` paints only on a wall hit and shares the `cl_maxdecals` oldest-first cap
  (a_decals.cpp:668-681, 822-860), as BD's projectile decals do today. Floor and ceiling blood therefore stays BD's md3
  flats.
- **MODELDEF matches the exact class** (models.cpp FindModelFrameRaw). RSQ_Gore ships generated MODELDEF entries for
  its own classes, pointing at BD's model files.
- **A blood can skip states.** Under 9 damage, `P_SpawnBlood` starts a blood 2 states in (p_mobj.cpp:6448-6492).
  PostBeginPlay is immune to that. HitBlood keeps BD's Decal property, so the engine's bleed decal behind the victim
  is unchanged.
- **Parking.** A thinker in a statnum below 32 is never ticked. It is still saved (dthinker.cpp:283) and still moved
  by lifts.
  - A parked limb overrides `DamageMobj` to return itself to STAT_DEFAULT first, so its Death and Kick states play.
  - Fallback if parking misbehaves: `-1` tics with `+NOINTERACTION`.

## 3. Head shots and leg shots without helper actors

**Score owns the verdict.** RSQ Score decides head and leg at the blow, in `WorldThingDamaged`
(Score/zscript/rsscore/head.zs, design/HEADSHOT_SOLUTION.md). It already replaces BD's head bloods (Blood_Imp,
Blood_Zombies, Blood_Comando, SitZ_Blood, Blood_BWSS, Blood_Noble/Fatso/Archie/Cybie) and BD's head hitboxes by name.

- **RSQ_Gore touches none of these classes.**
- Score's blood copies spawn `Brutal_Blood` by name, and that still reaches `RSQGO_HitBlood`: after a handler answers,
  the engine follows the replacement chain again (info.cpp:618-640).
- The two handlers' class sets are disjoint, and the lint checks it.

**BD's rules, which must hold:**

| Rule | BD source | Kept by |
|---|---|---|
| Head if blood z − floorz > 46 (Commando 50, BWSS 43, slumped 21, Noble/Fatso 54, Arch-vile 56, Cyber 96); gives HitHead, takes HitLeg | BloodTypesMonsters.dec:17-36, 240 | Score (as family fractions) |
| ACS Head_Shot: `Thing_Damage2(0, 30, "Head")`, scaled by DamageFactor "Head" | Inputs.acs:1111-1119 | Score: +30 Head, dealt from the player |
| Leg if < 25; gives HitLeg (two of them give DoubleLegRemove) | BloodTypesMonsters.dec:18; Zombiemen.dec:958-971 | Score |
| IsDown / IsCrouching: the +30 is refused, but **the token is still given** | Inputs.acs:1114 | the sensors below follow BD. Score's blood path currently calls it "body" (no token): see Q1 |
| Tokens present by the 2-4 tic death check | Zombiemen.dec:680-685, 790 | Score stamps at the blow, before `CallDie` (p_interaction.cpp:1611-1615), which is earlier than BD |

**XMVE's helpers.** On about 2,800 animation frames, XMVE spawns `HeadshotTarget4/6/10/20` (r7 h18, alive 5-12 tics)
and `LegTargetBase/LegTarget4/12` (r24 h12). Their z follows the pose, from 28 when crouched to 83 on tall monsters.

- **HeadshotTarget:** any pain ends in `A_Explode(20, 15, 0, 0, 15)` of type head (Head_Sys.dec:2-65). Its health
  ladder is dead code.
- **LegTarget:** its ladder maps damage taken to 2-200 "leg" (Leg.dec:1-160).
- **They may never hurt their own monster.** Both pass flags 0 (no XF_HURTSOURCE), and their `target` is the spawning
  monster (attacks.zs:268-271). Phase 0 measures what they really do.
- **Their value is the pose information**, including the part that pokes above the collision box. Score's fixed
  top-of-box fraction lacks both.

**Options:**

- **A. A replacement that tests the height once and destroys itself.** At spawn there is no hit to test, so the hit
  area is simply lost.
- **B. Record the zone and judge it in WorldThingDamaged.** This keeps the pose, but shots above the box now miss.
- **C. One head sensor and one leg sensor per monster, moved by declarations (recommended).**

**Option C, exactly:**

1. Every `HeadshotTargetBase` and `LegTargetBase` class (subclasses matched with `is`) is replaced by a **declaration**
   with `+NOBLOCKMAP +NOSECTOR +NOINTERACTION`.
2. On its first tick, the declaration reads its position, its class's box and lifetime (copied per class:
   HeadshotTarget4 = 6 tics, HeadshotTarget10 = 13, ...) and its `target`. It then destroys itself.
3. It moves that monster's single persistent sensor with `SetOrigin` and `A_SetSize`, and sets the sensor's expiry. The
   sensor is created on the first declaration. It moves only when XMVE would have spawned a helper, and drops
   `bShootable` once expired.
4. The sensor keeps the helper's damage factors exactly (SSG 1.5, SHOTGUN 1.4, Head 0, ...; leg: Bullet 1.5, SSG 0).
   When hurt, it applies **Score's outcome** to its monster from the player, in the same tic:
   - head: HitHead and Score's family bonus;
   - leg: HitLeg and the leg ladder's damage, band for band;
   - the Head damage is refused on IsDown or IsCrouching, but the token is still given, as BD does.
5. Without Score, or with `rs_score_hs` off, helpers are not replaced, and XMVE behaves as today.

Cost: ZScript cannot cancel an `A_SpawnItem`, so each declaration is still a spawn, but a one-tic one off the blockmap.
The 11-20 shootable blockmap actors per second, and the checks they add to every hitscan and missile, are gone.

## 4. Class takeover

- **By name, at run time.** ZScript compiles before DECORATE, so it can neither name nor inherit BD's classes. The table
  is strings, resolved once per class. If BD is absent, the handler is inert.
- **No unknown-class errors are possible.** BD's death states keep naming BD's classes, which still exist; only the
  spawn is redirected. RSQ_Gore removes nothing.
- **Lookup order** at a class's first sighting:
  1. the generated exact-name table;
  2. `is` against family roots, colour roots first (`Green_Blood` before `Brutal_Blood`);
  3. otherwise the class is left to BD.

  The answer is cached; `IsFinal` is never set.
- **Colour.** Each role has a red, green, blue and alien class, each carrying BD's translation, decal and colour
  textures.
  - BD's colour families have no common root (GreenBloodMist : BloodMist, but GreenBloodMistBig : BloodMistBig), so
    the name table decides the colour.
  - `is` only catches unknown subclasses, such as XMVE's LegTarget4b.
  - A hit blood carrying a monster's custom `BloodTranslation` (p_mobj.cpp:6446) draws through VisualThinkers, which
    take a translation.

| BD/XMVE family (the per-class table is generated from BD's 867 and XMVE's 122 gore classes) | Our class | Phase |
|---|---|---|
| Brutal_Blood, Green_/Blue_/Alien_Blood, SawBlood, BloodSPlatterReplacer, BrainBlood, BloodDying | RSQGO_HitBlood_{colour} | 1 |
| *FlyingBlood*, *FlyingBloodTrail/Faster/Fake*, BloodTrails, *LiquidBlood*, Underblood* | RSQGO_Spray_{colour} (emits, gone on tic 1) | 1 |
| Bloodmist*, *BloodMist*, ArterialBlood22*, ArterialBloodSpray, SuperGore*, UltraGore*, their spawners | RSQGO_Mist_{colour} | 1 |
| WaterBloodCHecker variants, WaterBloodSpot | RSQGO_Liquid | 1 |
| Brutal_BloodSpot family, Splattered*, GrowingBloodPool, *FootPrint* | RSQGO_FloorSpot / RSQGO_Pool | 2 |
| CeilBloodLauncher*, CeilBloodSpot*, ceiling drip spawners and drips | RSQGO_CeilLauncher, RSQGO_CeilSpot, drip schedule | 2 |
| BootSmearer* | smear zone | 2 |
| XDeath1-6 and variants, Organs, Guts*, Smearing*, CeilXDeath*, SmallBrainPiece*, GibEyeball, Teeth*, XJunk* | RSQGO_Chunk (card) | 3 |
| XDeath limbs, heads, torsos and halves, Gib_*, *GibBase, *LimbBase, TinyGib children, XMVE's HFQSZ, DarkImp and CyberKnight parts | RSQGO_Limb (card) | 3 |
| EmptyBrass family | RSQGO_Casing | 3 |
| WallRedBlood family, RedBloodCircularWallPainter*, BloodSplinter | RSQGO_WallPaint (decal) | 4 |
| GoreGroups.dec launchers; XMVE's DarkImpXDeath, ChainMajorXDeath, ZSpecOpsXDeath, ... | RSQGO_Recipe | 4 |
| HeadshotTargetBase*, LegTargetBase* | declaration and sensor (in Score if Q1 agrees) | 5 |
| Executions, Burn, Frozen, MeatShields | left to BD | n/a |

Cards, recipes, TEXTURES and MODELDEF are generated by a tool that reads BD's and XMVE's DECORATE and modeldefs. They
are never hand-edited.

## 5. Behaviour that must be preserved

| Behaviour | BD source | How |
|---|---|---|
| BloodSplasher_Red to players within 96 when the blood is ≥ 48 above the floor | Blood.dec:76-77 | the manager tests each player with A_RadiusGive's rule (radius, sight); 3 tics later it runs ACS `BloodSplashRed` with **that player** as activator. No item is spawned. Colour variants likewise |
| Saw hits: ChainsawHitRed, PowerBloodOnVisor, quake, Chainsaw/Flesh | Blood.dec:120-133 | kept as BD does them |
| misc/xdeath5 per hit, blooddrop2 per landing, bloood and xdeath2/3 on chunks | Blood.dec, Meat.dec | kept; landing sounds rate-limited per 128-unit cell; drip sounds come from the ceiling spot |
| SlaughterCounter ≥ 30 gives low blood | Blood.dec:25 | kept |
| Shootable and kickable landed limbs | Limbs.dec:1-170 | LimbBase's damage factors; Death.Kick/Melee/SuperPunch relaunch it as a flying limb; Pain hop; ExplosiveImpact flies and relands; GibRemoving and TeleportRemover remove it; burn deaths |
| Trample gives BootsSmearedWithRedBlood 6; pools give 8 within 60 (3D) for 880 tics | Limbs.dec:97; Blood.dec:1863-1903 | kept; smear zones check **every** player (Q4) |
| waterlevel > 1 gives Underblood; over a liquid texture, a fading WaterBloodSpot instead of a spot; Guts underwater | Blood.dec:39, 866-930 | the same branches: particles, and a VisualThinker on BD's fade timings |
| Ceiling-sticking meat | Meat.dec:146-152 | the chunk card |
| Corpse queue | 199 A_QueueCorpse calls | our classes use our rings; whatever stays BD's still queues |

## 6. Options

Per design/MENU_STANDARD.md: short rows, master switch first, budgets in Test and Debug.

| Row | cvar (scope) | Values | Default |
|---|---|---|---|
| RSQ Gore | `rsqgo_on` (server) | On / Off (Off = BD's own gore) | On |
| Gore | `rsqgo_amount` (server) | All / Some / None | **All** |
| Spray And Mist | `rsqgo_fx` (user) | All / Some / None | **All** |
| Blood That Stays | `rsqgo_residue` (server) | All / Some / None | **All** |
| Ceiling Drips | `rsqgo_drips` (user) | On / Off | On |
| Screen Blood | `rsqgo_screen` (user) | On / Off | On |
| Platform | `rsqgo_platform` (server) | PC / Quest | PC |

| Budget (starting numbers) | All (PC, default) | Some | None | All (Quest) |
|---|---|---|---|---|
| Death recipe entries | BD's full list | every second chunk | puffs only | full |
| Live flying chunks | 192 | 96 | 0 | 96 |
| Floor spots and pools kept | 512 | 192 | 0 (10 s fade) | 160 |
| Ceiling spots kept | 128 | 48 | 0 | 48 |
| Landed meat and limbs kept | 160 | 64 | 0 | 64 |
| Particles live (share of r_maxparticles) | ≤ 50% | 25% | 5% | 25% |
| Spray per hit | BD level 2 (Q2) | half | puff + 1 | level 2 |

When a chunk budget is exceeded, entries are dropped farthest from every player first, in recipe order, never by RNG.

## 7. Risks, tests, phases

| Risk | Mitigation / test |
|---|---|
| The look drifts (particles do not collide; density) | same textures, lifetimes clipped to the floor, BD's counts; fixed-camera A/B screenshots via the master switch; the owner's headset A/B |
| Head or leg logic changes | phases 1-4 touch none of it; T1 |
| Netplay desync | the tier rule; T5 |
| Parked actors misbehave (saves, lifts) | phase-0 experiment, `-1`-tic fallback; T7 |
| Unmapped XMVE subclasses | `is` fallback; an unmapped class stays BD's; T6 |
| CheckReplacement cost; particle pool exhausted | class cache; ≤ 50% of r_maxparticles; both timed in T4 |
| RNG streams differ from BD's | compare distributions, not single fights (T2) |

**Rig tests** (the main lane runs them; delegated work never launches the engine):

- **T1 Hit grid.** Frozen monsters of every class are hit at heights 0-90 in steps of 2. Tokens, health lost and damage
  type are logged per blow, with RSQ_Gore off and on. The logs must be byte-identical.
- **T2 Death variants.** About 200 kills per class and damage type. A test-only probe logs the death state label; the
  label distributions must match.
- **T3 Actors per death.** Spawns within 70 tics and 256 units of each death, BD's against ours, per variant.
- **T4 The 100-monster wave.** Spawns/s, live thinking actors, frame time and script ms against today's numbers.
- **T5 Demo test.** Record with every cosmetic option on, play back with cosmetics None and r_maxparticles 100. It must
  stay in sync.
- **T6 Lint.** Every class spawned by gore paths maps or is deliberately left; every mapped class exists; MODELDEF is
  complete; Score's set does not overlap ours. Then a `-norun` boot and an in-level check before any install.
- **T7 Edge cases.** Save and load mid-fight, lifts, liquids, kicked and shot limbs, two-player smears.

**Phases** (each one ships on its own, behind the master switch):

| Phase | Content | Main win |
|---|---|---|
| 0 | Measure BD's blood level, the XMVE helper outcome and the live decal and corpse cvars; parking and flipbook experiments; generator and lint | facts; nothing installed |
| 1 | Hit blood, trails, mist, jets, SuperGore, liquid checks, screen blood; menu | ~900 live liquid thinkers, ~200 spawns/s. **Phase 1: built 2026-11-27** (Gore/README.md; not yet rig-tested, master switch off) |
| 2 | Spots, pools, ceiling spots, drips, footprints, smears; merge grid, rings | residue stops ticking and growing |
| 3 | Chunks, limbs and casings from cards | landing spawns and chunk trails |
| 4 | Wall and ceiling launchers become traces; death recipes (BD and XMVE) | ≤ 30 actors per death |
| 5 | XMVE helpers become declarations and sensors | 11-20 blockmap actors/s |
| 6 | Quest tuning, frame-time guard (Q5), the owner's look pass | Quest |

## 8. Open questions for the owner

**Owner's answers (2026-11-27):** Q1 the XMVE helper takeover lives in **RSQ Score** (one hit-height sensor per
monster, Score's head bonus applied, HitHead given to downed/crouching monsters as BD does, refusing only the +30).
Q2 "All" = **BD's intended level 2** plus every death ingredient. Q3 residue **512 floor + 128 ceiling + 160 chunks on PC**,
about a third on Quest, oldest recycled, never timed out. Q5 frame-time guard **off on PC, on in the Quest preset**.
Q4 (boot smears in co-op), Q6 (corpses) and Q7 (wall decal cap) still open; their recommendations stand until answered.

1. **Where does the XMVE helper takeover live, and what does an XMVE head shot do?** Recommended: **in RSQ Score**, beside
   the verdict ("it needs to be part of RS Score", 11-09), applying Score's family bonus even if XMVE's helpers turn out
   to hurt nothing today. Also: Score's blood path should give HitHead to a downed or crouching monster as BD does,
   refusing only the +30.
2. **Which look is "All"?** BD probably shows per-hit blood at "Low" on your setup. Recommended: **BD's intended level 2**
   plus every death ingredient. It is cheap now and truer to "just as brutal".
3. **How much blood stays?** BD on QZD defaults keeps 10 queued pieces. Recommended: **512 floor + 128 ceiling + 160
   chunks on PC**, about a third of that on Quest, oldest recycled, never timed out.
4. **Boot smears in co-op.** Recommended: **every player** who walks through gets smeared boots. BD gives them only to
   the one player its smearer locked onto.
5. **Frame-time guard.** Recommended: **off on PC, on in the Quest preset**. It thins sprays and mist only.
6. **Corpses.** Recommended: **leave BD's alone**. They are gameplay: shootable, executions, slaughtermap checks.
7. **Wall decal cap.** QZD's `cl_maxdecals` default of 20 caps BD's wall blood today and will cap ours. Recommended: a
   Test and Debug row that sets it, default untouched.

### Owner answers, 2026-11-27 (after phases 1-3 were built and compared)
- Install: in the rotation with Gore ON (`rsqgo_on` default true) once the residue/chunk comparison and the in-level
  check pass.
- Blood Level default: Normal (2). Told first that BD itself plays Low on this setup (its option never reaches the blood),
  so Normal is more blood per hit than today, by choice. Q2's "All = level 2" stands.
- Chunks in flight: capped at 192 (`rsqgo_fly_all`); BD has no cap. Landed pieces stay capped at 160.
- Landed limbs: one blood spot each, at tic 1900, not BD's new spot every 1900 tics forever.
- Home: RSQ_Gore stays its own pk3 while it is tested in the headset; it folds into BD22 VR Reloaded later, after testing
  (owner, 2026-11-27). Phase 5 (the XMVE hit sensors) stays in RSQ Score either way.

## 9. Phase 0 results (2026-11-27, measured on the Windows rig with the owner's full rotation)

| Question | Result | What it changes |
|---|---|---|
| BD's blood level on the owner's setup (`isrunningzandronum 1`, `bd_bloodamount 2`, `zdoombrutalblood 2`) | **Level 2, BD's standard path.** 20 injected Brutal_Blood (monsters ignoring the player): exactly 1 each of SuperGoreMistTiny, WaterBloodCHecker, Brutal_FlyingBlood, ArterialBlood22Small, BloodMist22Small per hit (+0.55 floor spots from landing drops), with the Zandronum path on or off. Setting `bd_bloodamount 3` on the Zandronum path changed nothing. | The suspected "forced to Low" is wrong. The real bug: with `isrunningzandronum 1` BD's blood-amount option is **ignored** (`BDCVarInfo[PlayerNumber()]` read with a non-player activator) and always plays level 2. Q2's "All = BD's intended level 2" therefore **equals today's look**; our option will actually work. |
| Do XMVE's head/leg helpers hurt their own monster? | **Yes.** A HeadshotTarget10 hit for 10 by the player: its SniperZombie took **26 "head" damage**, source the player, inflictor the helper (health 60 -> 34). | Section 3's sensor (in RSQ Score, Q1) must reproduce that damage, not only the tokens. |
| Live decal / corpse / particle settings | Owner's `[Doom]` config: **`sv_corpsequeuesize 8192`**, **`cl_maxdecals 256`**, `r_maxparticles 4000`, `gl_particles_style 2`, `bd_infinitecasings 0`. The rig's defaults were 10 / 20. | BD's gore residue is effectively **never cleaned** on the owner's setup (8,192 queued pieces): every rig measurement before this used 10 and understated a long level's cost. All later tests use the owner's values. Phase 2's rings (512/128/160, Q3) are a large cut on this setup, not a growth. |
| Parking (statnum 26) | **Works.** A parked actor did not tick for 35 tics; its DamageMobj override un-parked it and it ticked every tic after. **`statnum` is not readable from ZScript in 17.3**: the actor must keep its own `parked` flag. | Section 2.4's parking stands, with a `parked` field. |
| Particle flipbooks (`SPF_LOCAL_ANIM` + our ANIMDEFS on BD's sprite textures) | **Works.** BSPRB0 animated through D/F/H/J by an ANIMDEFS `texture` block in our pk3; screenshots show the animated particles playing the larger splat frames beside static frame-B ones. Each particle starts its own animation at spawn (p_effect.cpp:370, InitStandaloneAnimation). | Mist and sprays can be particles that play BD's frames; parked VisualThinkers stay the fallback for anything particles cannot do (translation, collision). |
| Not gore | `DistanceCheckerCeiling` (~16/s) is LiveReverb's; `LensFlareAlt` (~65/s) is BD's muzzle/flare light; `LDLegendaryMonsterVisualEffect*` are LegenDoom 3.0's (decision #71). | Out of RSQ_Gore's scope. |

**Generator corrections (Gore/tools/gen_gore.py over the real pk3s, 897 classes in 15 categories; Gore/generated/):**
- Option C in section 3 cannot match helpers with `is HeadshotTargetBase`: that also takes 8 non-helpers (MeatShield,
  TankEngineWeakSpot, FuelTankPhysics, RiotShieldPhysics, CybersHitBox, MasterMindHitBox, SuperMastermindHitbox,
  HellNobleCrotchHitbox). The takeover uses the generated exact list (48 hitbox helpers, owned by Score).
- Four head-check bloods are outside Score's set: Blood_Imp_Saw, Blood_Zombies_Saw, Blood_Comando_Saw, Blood_Bones.
  Section 4's `is SawBlood` fallback would take them as plain hit blood and lose HitHead/HitLeg; the table gives them to Score.
- There is no class "Organs"; only XDeathOrgan*.
- BD's gore files hold 875 classes (not 867); XMVE's 122 match.
- EmptyBrass ends at 76 tics (not 210); BootSmearerRed at 851 (not 880), measured along the path with no jumps taken.
- BD's Dead.dec is excluded whole: its Gibs2 / SmallBloodPool2 replace map decorations, which a residue ring must never recycle.
