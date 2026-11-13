# Tiering BD22 and XMVE monsters on the colour ladder (2026-11-13)

**This is the rule for putting Brutal Doom 22's and XMVE's monsters on RSQ Monsters' colour ladder** (owner, 2026-11-13:
"document all of this, i will come back to it as the rule for tieing bd and xmve").

**Design only. Nothing here is built, and nothing was run on the rig or in the headset.** Every number was read from
code by script. Attack-damage figures are estimates (about ±50%). Lines marked **PROPOSAL** are suggestions waiting on
the owner. **OWNER** marks his open calls. No ability was cut or scaled down for performance; any later cut is the owner's
decision alone.

Where it comes from: the progression design talk of 2026-11-13. Every gun turn-in raises every monster in the game one
colour (the "world tier", S). The owner's assumption for that design: "by this point we will have tiered the BD
monsters and fixed RSQ Monsters". This document is that tiering and those fixes.

Data and the scripts that made it: [`tiering/`](tiering/README.md).

---

## 1. The ladder

The ladder is RSQ Monsters' 13 colours in strength order ([LADDER_RENUMBER.md](LADDER_RENUMBER.md)), plus the EX forms.
**The whole set is used**, the extra colours included:

| # | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Colour | Common | Green | Blue | Purple | Cyan | Brown | Yellow | FireBlu | Gray | Red | Abyss | Black | White |

How ColorfulHell's own HP grows, as a geometric mean across all 17 families (× Common):

| Com | Grn | Blu | Pur | Cya | Brn | Yel | FBl | Gry | Red | Aby | Blk | Wht |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1.00 | 1.25 | 1.50 | 1.79 | 1.66 | 2.22 | 2.28 | 2.32 | 2.42 | 3.08 | 4.29 | 17.7 | 27.8 |

HP alone is the wrong test of a colour's strength. The extra colours bring speed, attacks and abilities: Cyan is fast and
hits about twice as hard; FireBlu fires twin shots. So a colour's strength is its HP, attack, mobility and abilities taken
together.

---

## 2. The rule for a BD22 or XMVE monster

1. **Family.** Every BD22 and XMVE monster belongs to one of the 17 ColorfulHell families: the one it acts like. It is
   found by walking up its parent or replacement chain, with a name table for the orphans (Aracnorb, BloodDemon,
   ImpureElemental, TerminatorDemon and others).
2. **Entry colour.** A monster enters the ladder at the highest colour whose family HP multiplier is at or below
   (its HP ÷ its family's BD base). Monsters with unusual attacks count those too: the SuperImp's 50-damage plasma ball
   moves it up (√2.5). Most enter at Common; the strong ones enter higher (section 5).
3. **Its colour at world tier S** = entry colour + (S − 1), capped at 13 (White), then EX steps.
4. **HP at a colour** = base HP × M(colour) ÷ M(entry), where M is the family's HP multiplier (section 3).
5. **Damage, speed and pain chance** follow the curves in section 3, taken relative to the entry colour.
6. **Abilities:** the colour's kit for that kind of monster (section 4).
7. **Tint:** the colour's translation, plus the tier gem (section 4).
8. **Summons** take the higher of their own colour and their summoner's.

---

## 3. The multipliers (PROPOSAL, derived from ColorfulHell)

### HP multiplier per family
From Common to Abyss, each family's own ColorfulHell HP ratio, made to climb at every step: pooled where it dips, then
at least +5% a step. Black and White continue the curve (×1.25 and ×1.5 of Abyss) instead of ColorfulHell's boss jump; see
section 6.

| Family | Com | Grn | Blu | Pur | Cya | Brn | Yel | FBl | Gry | Red | Aby | Blk | Wht |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Zombieman | 1.00 | 2.00 | 3.00 | 3.15 | 3.31 | 5.00 | 5.25 | 5.51 | 5.79 | 9.30 | 10.00 | 12.50 | 15.00 |
| Shotgunner | 1.00 | 1.50 | 1.83 | 2.25 | 2.36 | 4.00 | 4.20 | 5.89 | 6.18 | 6.49 | 10.00 | 12.50 | 15.00 |
| Chaingunner | 1.00 | 1.21 | 1.50 | 1.71 | 1.80 | 3.21 | 3.38 | 4.88 | 5.12 | 5.38 | 7.14 | 8.93 | 10.71 |
| Imp | 1.00 | 1.17 | 1.38 | 1.75 | 2.08 | 2.69 | 2.83 | 2.97 | 3.88 | 4.07 | 5.00 | 6.25 | 7.50 |
| Demon | 1.00 | 1.13 | 1.37 | 1.73 | 1.82 | 2.11 | 2.22 | 2.33 | 3.67 | 3.85 | 4.04 | 5.05 | 6.06 |
| Spectre | 1.00 | 1.17 | 1.40 | 1.67 | 1.80 | 1.89 | 1.98 | 2.08 | 2.81 | 2.95 | 4.00 | 5.00 | 6.00 |
| Cacodemon | 1.00 | 1.12 | 1.20 | 1.27 | 1.34 | 1.40 | 1.80 | 1.89 | 1.98 | 2.08 | 2.75 | 3.44 | 4.12 |
| Lost Soul | 1.00 | 1.20 | 1.26 | 1.32 | 1.39 | 1.46 | 1.53 | 1.61 | 1.69 | 2.40 | 3.80 | 4.75 | 5.70 |
| Pain Elemental | 1.00 | 1.25 | 1.52 | 1.98 | 2.16 | 2.27 | 2.39 | 2.51 | 3.20 | 3.36 | 4.00 | 5.00 | 6.00 |
| Hell Knight | 1.00 | 1.20 | 1.33 | 1.42 | 1.49 | 1.57 | 1.80 | 1.89 | 1.98 | 2.60 | 3.70 | 4.62 | 5.55 |
| Baron | 1.00 | 1.17 | 1.31 | 1.50 | 1.67 | 2.07 | 2.17 | 2.28 | 2.40 | 2.51 | 3.33 | 4.17 | 5.00 |
| Revenant | 1.00 | 1.20 | 1.40 | 1.66 | 1.74 | 2.22 | 2.33 | 2.45 | 2.57 | 2.77 | 3.33 | 4.17 | 5.00 |
| Mancubus | 1.00 | 1.25 | 1.40 | 1.47 | 1.54 | 1.62 | 2.03 | 2.13 | 2.24 | 2.67 | 3.58 | 4.48 | 5.38 |
| Arachnotron | 1.00 | 1.20 | 1.40 | 1.47 | 1.54 | 1.62 | 1.70 | 1.79 | 1.88 | 2.00 | 3.70 | 4.62 | 5.55 |
| Arch-Vile | 1.00 | 1.07 | 1.23 | 1.43 | 1.71 | 1.80 | 1.89 | 1.98 | 2.08 | 4.07 | 4.28 | 5.34 | 6.41 |
| Cyberdemon | 1.00 | 1.25 | 1.45 | 1.60 | 1.95 | 2.05 | 2.15 | 2.26 | 2.37 | 2.50 | 3.00 | 3.75 | 4.50 |
| Spider Mastermind | 1.00 | 1.40 | 1.87 | 2.22 | 2.59 | 2.72 | 2.86 | 3.00 | 3.15 | 3.33 | 4.07 | 5.09 | 6.11 |

### Damage multiplier (one curve for all families)
The square root of ColorfulHell's median attack growth, made to climb at every step. The square root is deliberate: the rest of
the damage growth comes from each colour's kit (section 4), not from a flat multiplier.

| Com | Grn | Blu | Pur | Cya | Brn | Yel | FBl | Gry | Red | Aby | Blk | Wht |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1.00 | 1.11 | 1.32 | 1.36 | 1.47 | 1.51 | 1.56 | 1.61 | 1.65 | 1.83 | 2.35 | 2.70 | 3.06 |

### Speed and pain chance
- Each family's own ColorfulHell ratio, made monotone.
- Speed is never below ×1.00, at most ×1.5 up to Abyss, and ×1.6 at White.
- Pain chance only ever falls.
- The Gray kit overrides speed to ×0.8 ("stone").
- Every row is in `tiering/data/family_curves.csv`.

---

## 4. What each colour brings (PROPOSAL; themes checked against ColorfulHell's code)

Each colour is an add-on kit. Its theme comes from what that colour's ColorfulHell classes really do in code.
Note: FireBlu does **not** split on death; no FireBlu class does that.

| Colour | Kit | ColorfulHell evidence |
|---|---|---|
| Common | none: the monster as BD/XMVE ship it, no tint | – |
| Green | **Acid.** Hits leave a 3 s poison puddle; hitscanners get acid rounds | `RS_GreeniesBR`[Poison] `RS_Baron.zs:1272`; Green PE gas; Green Lost Soul spit |
| Blue | **Plasma.** Missiles +20% speed and a small zap splash; hitscan spread ×0.85 | `RS_Blufier1` `RS_Imp.zs:1123` |
| Purple | **Volley.** One extra shot per attack; an Arch-Vile raises 2 corpses | Purple zombie fires 3 orbs `RS_Zombieman.zs:1380-1382`; `RS_Bounc11` `RS_Imp.zs:1240`; GrowRaisin `RS_Archvile.zs:1449` |
| Cyan | **Ice.** Hop-dodge; ice shots slow the player; Ice ×0.2; Fire and Melee ×1.5 | ThrustThingZ `RS_Imp.zs:415`; every Cyan class has Ice 0.10-0.35 and Fire/Melee 1.5-2.0 |
| Brown | **Support.** Every 3 s heals allies within 512 by 5% of their max (never itself); gives one ally a 2 s ×0.5 shield | heal `RS_Cacodemon.zs:288`, `RS_Archvile.zs:381`; shield `RS_Imp.zs:305`; command `RS_Imp.zs:291` |
| Yellow | **Fire.** Shots ignite (2 s burn); Fire ×0.5, Ice ×1.2 | `RS_SpitFireImp` `RS_Imp.zs:1373`; Yellow fire factors 0.3-0.75 |
| FireBlu | **Twin fire.** Each missile gets a blue twin; Fire ×0.25; a death blast | `RS_RedBBall` + `RS_BluBBall` `RS_Imp.zs:697-700`; fire resistance in 8 of 17 families |
| Gray | **Stone.** All damage ×0.65 (explosive ×0.5); pain chance 0; speed ×0.8; rock shots | `DamageFactor 0.65` `RS_Fatso.zs:768`; slow Grays (zombie 4, PE 3) |
| Red | **Rage.** At first pain or 50% HP: no pain, +40% speed, attacks more often; red flecks; 3-5 blood bolts on death; Ice ×1.4 | `RS_RedImp` Pain `RS_Imp.zs:1516-1521`; death bolts 1529; RS_RedThingsLS; ice 1.35-1.45 in 7 of 17 |
| Abyss | **Phase.** 1 s at translucent 0.35 after hits; a blink portal to flank; rises once as an Abyss husk | `A_SetTranslucent` `RS_Demon.zs:793-794`; `RS_AbyssPortalVile` `RS_Archvile.zs:717`; AbyssMark `RS_Zombieman.zs:863,590` |
| Black | see section 6 | all 17 are +BOSS; 13 take less from all damage |
| White | see section 6 | |

**By kind of monster** (full grid: `tiering/data/colour_kits.csv`):
- Hitscanners get "rounds" versions.
- Melee rushers get bite or charge versions.
- Flyers and summoners pass their colour on to what they summon.
- An Arch-Vile's colour changes its flame and what it raises.

**How a kit attaches:** one RSQ inventory item (the tier kit: DoEffect, ModifyDamage, a missile hook), plus one item per
colour behaviour. Missile kits find the owner's missiles in WorldThingSpawned (`missile.target == owner`), so BD's own
projectiles are never edited.

**Two cautions from BD's code:**
- BD switches NOPAIN itself (76 `A_ChangeFlag("NOPAIN")` calls in `actors/Enemies`), so "no pain" kits set PainChance 0,
  not the flag.
- BD never sets Speed, Translation or RenderStyle on monsters while running (0 hits), so those are safe to set.

**Tint:**
- 13 TRNSLATE entries, `rs_bdtier_<colour>`, written in ColorfulHell's own gradient-range syntax.
- Common has no tint (BD's look). FireBlu is two-tone (upper ranges red, lower blue). Abyss is dark plus the phase alpha.
  Black is near-black, White is light.
- The tier gems (`rs_ch_colorblind`, `RS_ColorTierIconCH<n>`) are also given to BD monsters.
- Unknown: whether BD and XMVE sprites tint well. Fuzzy and translucent bodies (Spectro, the stealth monsters) won't show
  a tint and rely on the gem.

---

## 5. Where BD22 and XMVE monsters enter

The full table covers every BD22 and live XMVE monster. For each it gives the class, file:line, base HP, family, entry colour, how it
appears and its HP at all 13 colours: **[`tiering/data/bd_xmve_ladders.md`](tiering/data/bd_xmve_ladders.md)**
(CSV: `bd_xmve_ladders.csv`).

**Already above Common by nature:**

| Enters at | Monsters |
|---|---|
| White | Juggernaut (13.3× Mancubus), SuperOverlord (25× Caco) |
| Abyss | Volcabus, BaronBoss1/2, TerminatorBoss |
| Red | AracnorbQueen (2.5× Caco) |
| FireBlu | MrX |
| Yellow | HellTrooper, BFGZombie, BloodSpectre |
| Brown | Arachnotron2, BDMummy, Draugr, OverLord |
| Cyan | Belphegor2, BrutalNightmareDemon, HeadlessZombie, DIABloist, BloodDemon, PyroSergeant, RocketGuy, U_ArchangelusA |
| Purple | ZSpecOpsRail, QuadShotgunZombie, ThamuzBoss, Motherdemon, SuperSpiderMastermindX, AracnorbQueenBOSSBOSS, U_ArchangelusB |
| Blue | **SuperImp** (80 HP, but it fires BD's 50-damage GreenPlasmaBall, `x04/SuperImp.txt:17`, `Enemies/Knight.dec:654`), the dark imps, Imp3, VoidSpectre, CyberKnight, Daedabus, ASGGuy, SuperShotgunZombie, ZSpecOps, Major |
| Green | **Annihilator** (7000 HP, the Cyberdemon's 250-damage CyberBalls; Blue if its volley proves bigger on the rig) |

- **Exempt:** scripted map pieces such as the Icon of Sin, the BossBrain replacer, Keen, DopeFish and XMVE's MiniTitan.
- **ACS health-bar bosses (HP curve only, no kit):** CyberdemonBoss 20000 (enters Black), GreatCyberdemon 10000 (Cyan),
  SuperMastermind 10000 (Purple) (`actors/PlayerClasses/SpecialDoom1Bosses.dec:2,189,203`).
- **Variant classes** take their parent's row: the XVStealth* classes and the Vanilla_* classes.
- **Unknown:** Thamuz (+BOSS, speed 32) and DarkCardinal/BOSS. HP alone puts them at Common, but their attacks were not
  measured. **Check on the rig.**
- **OWNER:** DarkCardinal (800) and Tyrant (1000) are weaker than the Cyberdemon family's base. Should they borrow a
  smaller family's curve?

### Which XMVE files are live (verified in code and the rig's own load log)
- XMVE's DECORATE includes only some of its files. Its copies of BD's monster files (`Zombiemen.txt`, `Imps.txt`,
  `Sergeants.txt` …) are never included, so BD22's own classes and HP apply.
- The 07 pack's 9 included files replace 04's by lump name. Its `Comando.txt` is never included.
- Both spawner packs load, 06 then 05: the rig log `runs/n_load/run.log` shows "Tried to define class
  'ZombiemanSpawner' more than once" for all 15 spawners. The later one (05, TUD) should be the one that spawns; that is
  inferred, not shown.
- Exact spawner odds for both: `tiering/data/spawn_tud05.json` and `spawn_doom2_06.json`. For example, the Cyberdemon slot
  spawns Annihilator 28.1%, TheCyberdemon 25.3%, SuperDemon 25.0%, Thamuz 21.6%.

---

## 6. Black, White and EX

Under "+1 for every monster", enough turn-ins put every monster at Black, then White. **OWNER** chooses:

- **B (recommended): a boss-grade world tier.**
  - HP ×1.25 (Black) and ×1.5 (White) of Abyss; damage ×2.70 and ×3.06.
  - Black kit: all damage taken ×0.6, no pain, and once, at 50% HP, it calls 2 of its family at the current world tier.
    Death shower.
  - White kit: as Black, plus a blink teleport every 8-12 s and a second call at 25%.
  - A monster becoming White flashes black, as RSQ already does (`RS_Retier.zs:910`).
- **A: literal ColorfulHell boss HP** in every slot (a Zombieman is 125× at Black and 140× at White).
- **Natural boss roll on top:** ColorfulHell's own odds (e.g. 2 and 1 in 1,843 for imps) can still roll a true boss at
  ColorfulHell's boss HP.
- **EX: turn-ins past White.**
  - ColorfulHell families use their EX form where one exists: 8 Black EX, plus `RS_WhiteLSoulEX` and `RS_WhiteSGEX`.
  - The 7 families with no EX (Arch-Vile, Baron, PE, Cyberdemon, Mastermind, Demon, Spectre) get White plus the kit below.
  - BD and XMVE monsters: White plus their family's Red Rage and Abyss Phase kits.
  - Every further step adds +10% HP and +5% damage, so every turn-in still climbs.

---

## 7. How it hooks in (no engine change)

**Recommended: in place on the same BD actor**, not a swap to a new class.

| | Swap, like RS_Retier (a new class per colour) | **In place on the same actor** |
|---|---|---|
| Classes needed | 13 × ~170. ZScript cannot inherit DECORATE classes, so this would mean DECORATE hard-linked to BD, which breaks "loads alone" | none: one kit item plus colour items, by name |
| BD gore, executions, headshot targets, tokens (TypeZombieMan), ACS checks by class | at risk (new class names) | intact |
| Score census | needs a take and an add on every change | nothing moves |
| Champions, LegenDoom, Universal Entropy, mk-crits | new body: re-rolled or lost | untouched |
| mk-crits headshot rule | can flip, as ColorfulHell's does (fix 5) | can't flip: the class never changes |
| Tier change mid-map | destroy and respawn | the same flash, then re-apply the multipliers |
| Risks | all of the above | BD's NOPAIN switching (use PainChance); variant replacers (the kit must skip a replacer that clears COUNTKILL; BD's variants spawn about 3 tics later, `Zombiemen.dec:156-176`); tint on BD art unproven |

**The hook** is a Monsters event handler.
- **WorldThingSpawned:** for any `bISMONSTER` not on the ColorfulHell ladder, find the family (section 2) and give the kit.
  The kit's tier is entry + S − 1. It sets StartHealth, health, DamageMultiply, Speed, PainChance, the tint and the colour
  items.
- **The roster service answers kit monsters too:** "tier" and "retier" (in place, with the flash). Then Score's rows and
  Miniboss's tier-ups work on BD monsters; today `TierOfMon` returns -1 for them (`Miniboss/zscript/rsqmb/fight.zs:83-88`).
- **The tools exist in QuestZDoom 17.3's base scripts:** `Actor.StartHealth`, `SpawnHealth()`, `GetSpawnHealth()`,
  `DamageMultiply`, `EventHandler.SetOrder` (gzdoom.pk3 `zscript/actors/actor.zs:160,743,946`; `events.zs:214-215`).
- Setting StartHealth should raise health in a way Score and gib thresholds follow; Champions relies on this
  (`champions/baseclass.txt:325,341`). That is confirmed by its use, not by engine source.

### How the world tier S is applied
1. **At map load, in the spawn choices.**
   - ColorfulHell: CheckReplacement (`RS_Roster.zs:351-428`) uses ClassFor at min(13, natural roll + S − 1), plus ladder
     health (fix 4).
   - BD/XMVE: the kit at WorldThingSpawned.
   - Both land before Score's tic-1 census: the right classes, the right HP, no flash, no actor churn.
2. **A turn-in during a map:** every live monster goes +1 through the "retier" service with the flash
   (`RS_ScoreReadout.zs:73-78`). ColorfulHell swaps (with fixes 1 and 2); BD and XMVE re-apply in place.
3. **A hub level re-entered:** a raise-to-floor pass after Miniboss's reset (fix 8).
4. **Not recommended: a whole-map retier at load.** At WorldLoaded the ColorfulHell dials are still RandomSpawners. After
   the census it would mean every body swapped, a stale life threshold, and every Champions, LegenDoom and UE roll re-done.

**Where S lives is still open.** No turn-in or world-tier code exists yet. A StaticEventHandler isn't saved with the game,
and player inventory is reset when the player is reborn after death. S belongs with whatever records turn-ins.

---

## 8. RSQ Monsters fixes the world tier needs

All are verified in code. None are built.

1. **Swap loses the skill's MonsterHealth.**
   - The problem: `RS_Retier.zs:814-817` takes the wound share from `od.Health` (the class default). `:835-837` then
     overwrites the new body's skill-scaled health with `nd.Health`. Black Metal (0.8) bodies come out 25% too tough, and
     Realism (0.5) ones twice as tough.
   - Fix: share = `mo.health / mo.SpawnHealth()`; full = `a.SpawnHealth()` (after setting `a.StartHealth` when ladder health
     applies); `a.health = FullHealth ? full : max(1, int(full * frac))`.
2. **Swap carries no inventory.**
   - The problem: `RS_Retier.zs:819-853` copies pointers, flags and TID only. Map monsters re-roll Champions, lose
     LegenDoom legendaries and get a new random UE size and colour. Only Miniboss carries tokens over today: KeptTokens at
     `Miniboss/zscript/rsqmb/fight.zs:309-321`, FollowGot at 371-390, and the Champions carry at `carry.zs:1-60`.
   - Fix: move the carry into RSQ Monsters' Swap, by name:
     - the KEEP tokens
     - LegenDoom: if `LDLegendaryMonsterToken` was there, give `LDLegendaryMonsterPickupGuaranteed`
     - Champions: the PersistentInfo move, plus `champion_NullToken`
     - RSQ's own `RS_CHAbyssMark`, `RS_GrowRaisin` and the stamp
     - UE: copy Scale, Radius/Height and Translation

     Miniboss then only follows.
   - Also: the Cyan zombie gate spawns three bodies (`RS_Zombieman.zs:90-92`), and Swap makes one.
3. **Tier changes ignore the extra-colour gates.**
   - The problem: `ClassFor` never names a gate (`RS_Retier.zs:63-64`, 805), and Miniboss's set.class uses ClassFor too.
   - A second bug, a leak: `BuildCHFamily` (`RS_Roster.zs:244-266`) keeps gate names under the cap. A switched-off gate
     rerolls into the **uncapped** whole dial (`RS_Zombieman.zs:64-66`), so it can produce Abyss, Black or White under a
     cap of 5 or more. Fix: drop switched-off colours when building the cap list.
   - Under the world rule the ladder is all 13 colours. The gates only shape the random natural roll above the floor.
4. **43 single steps where HP falls** (exactly 43; list and verdicts in `tiering/data/hp_drops_verdicts.csv`).
   - Don't edit class defaults: natural ColorfulHell spawns keep ColorfulHell's numbers.
   - Add **ladder health** under the world rule: a ColorfulHell monster's StartHealth = its family's running maximum
     ×1.05 per step (numbers per family in `hp_drops.json`, "envelope").
   - **Lift 41.** Examples: Purple Zombie 95 → Cyan 30 becomes 100; Brown Imp 215 → Yellow 145 becomes 226; Red Arch-Vile
     3200 → Abyss 2500 becomes 3360. 15 of these steps look made up for by stronger attacks on paper, but the attack
     numbers are estimates, so lift them anyway.
   - **Keep 2:**
     - The Gray Lost Soul hive (50 HP): its strength is the 2 bees per attack (`RS_LostSoul.zs:666`).
     - The Purple → Cyan Zombie step: fix Swap to spawn the 3 bodies (3 × 30 is about 95).
   - Note: every Cyan class takes ×1.5-2 from Fire and Melee, which matters for VR melee.
5. **mk-crits headshot immunity flips along the ladder.**
   - The problem: mk-crits exempts Demon, Spectre, LostSoul, Cacodemon, Revenant, PainElemental, Arachnotron and
     SpiderMastermind by inheritance (`zscript.txt:24-35`, `is` at :137). Some colour classes inherit the id class and
     some are `: Actor`. Example: Purple Caco (`RS_Cacodemon.zs:1142`, `: Cacodemon`) is immune; Red Caco (1407,
     `: Actor`) takes ×4. Per-family patterns are in the data.
   - Fix (PROPOSAL): a by-name shim, not re-parenting (re-parenting would pull in id states and flags). An
     `RS_HeadRuleShim` item given before `csh_Brain` divides mk-crits' factor back out for `: Actor` members of those 8
     families when the hit lands in the head band. **Rig test needed.**
   - BD monsters tiered in place can't flip.
6. **Universal Entropy and Champions hide the tier colour.**
   - The problem: UE's `ue_recolour` defaults to 5, and `5 >= random(1,5)` is always true, so **every** monster gets a
     random translation (`randomise.zs:66-68`). Champions applies `champion_<colour>`, e.g. `champ_red.txt:33`. The flash
     restores whatever translation it saved (`RS_Retier.zs:770`), and UE recolours each new body again.
   - Fix: a Monsters handler ordered after UE re-asserts the ladder look (the class default translation, or the BD tint).
     Tier gems on by default when UE, Champions or the world rule is on. Champions keeps its particles and Score's
     champion icons.
   - **OWNER:** which wins, the champion tint or the tier tint?
7. **Miniboss's map-wide tier-ups stack on the world tier.**
   - The problem: TierUp hits the whole map (`fight.zs:243-259`, `rsqmb_tier_mapwide` on). It adds 1-3 per missed window
     and +1 per life lost, capped only at 13 (`fight.zs:281,554`). At S = 10, one missed window can turn every map monster
     into a ColorfulHell Black or White boss at full boss HP.
   - Fix (PROPOSAL): for monsters that aren't part of the fight, cap map-wide steps at min(13, S + 3), and at Abyss unless
     S ≥ 12. Thralls are already capped at Abyss (`fight.zs:555`).
8. **Other things that break "+1 for everything, kept across maps":**
   - **Hub reset.** `fight.zs:401-411` (and `handler.zs:103`) puts monsters back to their pre-miniboss tier and ignores an
     S that rose meanwhile. Fix: back to max(original, the floor S sets), then a raise-to-floor pass. Unknown: whether
     handler arrays survive a hub snapshot on 17.3.
   - **ColorfulHell's own conversions bypass Retier**, so they get no flash, no census and no floor.
     - The Abyss PE pulse: `Pain.AbyssPE` in every tier-1-to-10 class spawns the Abyss class and then `A_Die`.
     - **Grow** raises monsters **down** the ladder: FireBlu and Gray come back as Purple (`RS_Zombieman.zs:619,753`;
       `RS_Revenant.zs:751,869`; `RS_Demon.zs:700`; `RS_Cacodemon.zs:824`), and the Gray Arachnotron as Yellow
       (`RS_Spider.zs:1471`).
     - Fix: route both through Swap, with target = max(target, floor).
   - **Map-end boss triggers.** ColorfulHell classes have no `replaces`, and nothing answers CheckReplacee. A_BossDeath
     matches by replacee type, so the MAP07 and E1M8 specials likely never fire for ColorfulHell Fatsos, Arachnotrons and
     Barons. Fix: CheckReplacee in RS_RosterHandler returns the vanilla family class. **Not shown on the rig; engine source
     not on disk.**
   - **Score's colour rows go wrong once S is above Common** (`Score/zscript/rsscore/rows_roster.zs`).
     - Rarity (208-224) reads spawn odds without the floor, so every floor-colour kill pays rarity.
     - Full Spectrum (227+) can't be completed when S > 1.
     - Colour Chain (259-286) pays on nearly every kill.
     - Upset (328+) needs tiers 1-3, so it is dead from S ≥ 4.
     - The tier rows (160-189) pay on every kill as S grows (maybe intended).
     - Fix: make spawn odds, Low and Full Spectrum relative to S.
   - **Census timing.** Score takes the census at WorldLoaded and again at maptime 1 (`handler.zs:51,117-173`).
     - XMVE's spawners wait a tic and BD's replacers spawn their variants at about tic 3, so both likely miss the census.
       Read from code, not run.
     - A world tier applied after the census leaves the life threshold worked out from lower HP.

---

## 9. Open calls for the owner

1. Black and White under the world rule: boss-grade (B, recommended) or literal ColorfulHell boss HP (A).
2. Which tint wins: the champion's or the tier's.
3. DarkCardinal and Tyrant: keep the Cyberdemon curve, or borrow a smaller family's.
4. The miniboss map-wide tier-up cap: min(13, S + 3), or something else.
5. Where S lives (it belongs with whatever records turn-ins).

## 10. Unknowns
- Whether tinting works on BD and XMVE art.
- The A_BossDeath replacee rule on 17.3.
- Whether handler state survives a hub snapshot.
- Brutal_Difficulties' skill values (no copy on disk).
- Real attack damage for Thamuz, DarkCardinal, the Annihilator's volley, and every ColorfulHell attack estimate (±50%).
- Legion of Bones' risen skeletons (SkullZombie : ZombieMan and the like) and SpawnAdjuster copies: covered by the
  generic kit through inheritance, but not checked in play.
- Whether XMVE TUD's spawners (05) win over Doom 2's (06).
