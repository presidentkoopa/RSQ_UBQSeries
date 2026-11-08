# RS Monsters x RS Score x RS GBOVR: design study (2026-11-08)

For the owner. Read only; no code was changed. Nothing here was run in an engine: every fact is from reading code
(file:line given). Guesses are marked [inference].

## 1. What RS Monsters is

**Where:** `/home/claude/rs_monsters`, one commit (`ac222f98`). 213 MB on disk (sprites 107 MB, sounds 23 MB).
About 80,000 lines of ZScript in 46 files. 143 cvars, all `rs_*`. MAPINFO adds two handlers: `RS_RetierHandler`
and `RS_RosterHandler` (`MAPINFO.txt`).

**What it is:** a native ZScript rebuild of *Colourful Hell* (CH; every class cites its CH file:line). 17 Doom
families, each with 13 colour tiers, each tier its own class with its own health, speed, attacks and inline
`Translation`. Example: `RS_PurpleZombie : ZombieMan`, Health 95, its own translation
(`zscript/monsters/zombieman/RS_Zombieman.zs:1317-1350`). Health climbs steeply: Red Imp 200, Black Imp 3800,
White Zombie 2800, Black Cyberdemon 14500 (`imp/RS_Imp.zs:1438,1739`, `zombieman/RS_Zombieman.zs:2438`,
`cyberdemon/RS_Cyberdemon.zs:2058`).

**The ladder** (`RS_Retier.zs:26-27`): 1 Common, 2 Green, 3 Blue, 4 Purple, 5 Yellow, 6 Red, 7 FireBlu, 8 Gray,
9 Abyss, 10 Black, 11 White, 12 Cyan, 13 Brown.

**What it replaces:** the 17 vanilla monsters, by `RandomSpawner ... replaces` "dials", for example
`RS_ImpColourset : RandomSpawner replaces DoomImp` with weights (Common 630 ... Black 2, White 1)
(`imp/RS_Imp.zs:11-28`). It also replaces three vanilla projectiles globally: `Rocket`
(`cyberdemon/RS_CyberdemonFX.zs:1318`), `BaronBall` (`baron/RS_BaronFX.zs:1187`), `FatShot`
(`fatso/RS_FatsoFX.zs:525`).

**How a tier is chosen at spawn** (`zscript/monsters/RS_Roster.zs`):
- `RS_RosterHandler.CheckReplacement` (:265-347) catches each vanilla family spawn.
- `rs_roster_pack` (default `"RSMG"`, `CVARINFO.txt:1183`) picks a roster set. No RSMG monsters exist in this
  repo, so every family falls through to the CH dial (:316-318).
- Per-family cap cvars `rs_roster_<family>`, **default 1** (`CVARINFO.txt:1185-1201`): only Common spawns by
  default. Raise the cap and the dial rolls among tiers at or below it, by CH's weights (:321-346).
- Tier is read from the class name's colour word (:216-238).
- `VANILLA` sets `Replacement = null, IsFinal = true` (:285-290), which hands back the original vanilla class.

**How a tier is carried:** each colour class calls `RS_Zom.SetTier(self, N)` in `PostBeginPlay`, which gives
`RS_ZomTierToken` with Amount = tier (`zombieman/RS_ZombiemanFX.zs:33-65`). Read it with
`CountInv("RS_ZomTierToken")`.

**The runtime re-tier** (`zscript/monsters/RS_Retier.zs`):
- `RS_TierLadder` (:35-671): if-chain tables `ClassFor(family, tier)` and `GateFor`, plus `FamilyOf`/`TierOf`.
- `RS_Retier.Request(mo, tier, instant=false)` (:704). Not one of ours: ignored. Already queued: re-targeted,
  never stacked.
- Staggered by default: a `RS_RetierJob` thinker (:779) waits a random 45-105 tics (:722), flickering `bBRIGHT`
  faster and faster as the "tell". A room ripples rather than snapping.
- `Swap` (:728) **replaces the actor with a new one of the new class**. It keeps the wound fraction
  (old health / old class health, clamped 0.05-1.0, :745), copies angle, velocity, target, master, tracer,
  special, args, TID, ambush and friendly, and puts it straight into its See state. Then `mo.ClearCounters();
  mo.Destroy()` (:773): the old body does not die and is not a kill.
- Console tests: `netevent rs_tierof`, `rs_retier N`, `rs_retier_up`, `rs_retier_all N` (:816-819).
- Nothing in the pack calls `Request` by itself. The only caller is the console handler. So "runtime re-tier" is
  an **API waiting for a trigger**. That is exactly what the RSQ mods could be.

**Older systems, state unclear.** `RS_MonsterMaster` re-tiers in place (one class, a tier field, with
`rs_mon_retier_preserve_fraction` and `rs_mon_transform_tell`, `RS_MonsterMaster.zs:429,696`). `zscript.txt:16`
includes it, but `EXCLUDED.txt` says it does not compile, and `ELITE_SYSTEMS.txt` names `RS_Elite*.zs` files that
are not in the tree. I could not check which is true without a compile. The README says it "needs the UZDXREMA
engine fork". **Whether it compiles on stock QuestZDoom 17.3 is not known.** That is the first gate.

**Targets:** vanilla monsters only. Every tier class inherits a vanilla class. It knows nothing of BD22.

## 2. Where it fights BD22, Champions and LegenDoom

**BD22** replaces the same vanilla classes in DECORATE: `RifleZombie replaces ZombieMan`, `Imp replaces DoomImp`,
`BullDemon : Demon replaces Demon`, `BaronofHell2 replaces BaronofHell`, `Mancubus replaces Fatso`,
`BigFireBall replaces Fatshot`, `GreenPlasmaBall replaces BaronBall`, and more (`brutal22test6.pk3`,
`actors/Enemies/*.dec`).
- Loaded after BD22, RS Monsters' dials win the replacement [inference: GZDoom keeps the last `replaces`]. Its
  `CheckReplacement` with `IsFinal` then decides alone. **BD22's monsters would stop spawning**: every imp becomes a
  CH imp, with no BD gore, deaths or fatalities.
- No setting keeps BD22 monsters. `rs_roster_enable false` leaves the dials in place. `VANILLA` returns the
  vanilla class, not BD22's [inference from the `RS_Roster.zs:277-290` comment].
- **Sprite clash:** 539 sprite lumps in RS Monsters have the same names as BD22's (ACNB, ARAC, SPID, SKEL, FATT,
  CYBB, BOS2, CACB...). 534 of 535 compared differ in bytes. Loaded later, RS Monsters' frames would override
  BD22's [inference]. Whether they look different was not checked.
- Class names: none of the 1516 classes RS Monsters compiles clash with an RSQ series class (checked). Cvars: no
  clash with the series (checked).

**Champions** (`mk-champions20210309.pk3`, `zscript/champions/`):
- Picks at spawn: `WorldThingSpawned` on any `bISMONSTER && bCOUNTKILL` thing, chance by skill
  (`handler.txt:406-419`).
- Then a controller thinker changes the monster in place: `A_SetTranslation("champion_<Colour>")`
  (`champs/champ_*.txt`), Health, `StartHealth` (`baseclass.txt:325`), DamageMultiply, flags, scale (Titan,
  `baseclass.txt:179-195`).
- It has a CH bridge that looks for a class named `ColorTierIconCH` (`handler.txt:44-88`). RS Monsters renamed it
  `RS_ColorTierIconCH`, so the bridge does nothing.

**LegenDoom (3.0 read):** at map start a chooser hands out `LDLegendaryMonsterPickup*` by `A_RadiusGive`
(`decorate/MonsterGen.dec`, `source/LEGENDINF.acs:469`). ACS `LDMonsterInit` sets health to SpawnHealth x
`LD_legendaryhealth`, then refills it at half health and transforms (`source/LEGENDMON.acs:2-66`). Score's notes
say LegenDoom Lite does the same (`Score/zscript/rsscore/boost.zs:15-20`). I did not open the LDL pk3.

**Where they fight over one monster:**
1. **The swap kills status.** `RS_Retier.Swap` destroys the body. A champion's controller loses its monster. A
   legendary's token, ACS loop and promised weapon drop go with it. The new body spawns, so Champions rolls again
   (it may or may not be a champion) [inference from `handler.txt:406`]. The new body may or may not become
   legendary: I could not check how LDL treats late spawns.
2. **Colour: the last writer wins.** A champion's `A_SetTranslation` overwrites the CH tier colour. A Purple
   Zombie that is a Red Champion just looks red. The tier can no longer be read by eye [inference].
3. **Health stacks.** Tier, then Champions' factor, then LegenDoom's 300%. A Black Imp (3800) that is a Gold
   champion (x5, per `boost.zs:12`) and legendary would be about 57,000 HP [inference, arithmetic].
4. **Score treats the swapped body as a stranger** (next section).

## 3. What Score and GBOVR already expose

**RS Score** (`Score/zscript/rsscore/`):
- Base pay = `victim.GetSpawnHealth()` (`event.zs:83`). A higher tier already pays more (Black Imp 3800 vs 60). The
  bonus cap is 300% of base.
- The map's reward target = average monster health x count (`handler.zs:119-150`). A map spawned at higher tiers
  raises the target too, so lives do not come faster.
- **Ready-made hook for this pack:** `boost.zs:40-46` says: subclass `RS_ScoreTierRow` (`boost.zs:188-212`; Token,
  Mult, Group, Active), register it, and Score is unchanged. Rows are in the Daring family. One row per group per
  kill.
- **Anti-farm:** a monster not counted at map load pays `rs_score_farmpercent` (default 25%) (`handler.zs:343-365`).
- **Combo chains** are kept per Actor (`combo.zs:95-200`, `eV`).
- Service `RS_ScoreService` (`awards.zs:86-215`): `award`, `touch`, `givelife`, `revivefire`, `kill.serial`,
  `kill.style`, `kill.base`, `kill.big`, `kill.chain`, `kill.victim`, `monster.name`, `score`, `progress`, `lives`,
  `rewards`.
- `Rainbow` row: kill champions of 5/10/14 colours in one map (`rows.zs:1212`).

**RS GBOVR:**
- Damage XP already scales with the victim's spawn health: x(log10(SpawnHealth) - 1) above 100 HP
  (`ca.ancilla.bonsai/PerPlayerStats.zsc:1333-1350`). Higher tiers pay more XP with no new code.
- XP Source: Style turns Score's `kill.style` into XP along the combo chain (`rsq/zscript/stylexp.zs:1-60`).
- Service `RSQGB_Service` (`rsq/zscript/service.zs`): `level`, `xp`, `xp.permille`, `count`, `upgrades`, and
  `player.level` (`:121`; Miniboss already reads it for its tier).
- Gun Bonsai's LegenDoom tie-in: legendary weapon effects (`WeaponInfo.zsc:306`).

**Swap, as built, breaks Score in three places.** (a) The new body is not in the census, so it pays 25%. (b) Its
combo chain is gone. (c) A champion or legendary row is lost or re-rolled. This must be fixed before any live
re-tier idea is fun.

## 4. Ideas, ranked

Each: what the player sees and feels | why it is arcade | the join | cost/risk | Champions/LD conflict.

### RS Monsters x RS Score (the owner's hunch: yes, this pair is the better fit)

**S1. Tier Bounty rows.** The breakdown shows "+3040 Black Imp" in Daring orange. Rare colours feel like jackpots.
| Arcade: the rare enemy you chase for points. | A bridge file subclasses `RS_ScoreTierRow`, Token
`RS_ZomTierToken`, `Active(v)` checks the amount, `Group 'rsmon'`, Mult rising with tier. Registered from the
bridge's own `OnRegister`. Score unchanged (`boost.zs:40-46`). | Cheapest idea; low risk. | A champion on top pays
both rows (different groups). The 300% cap holds it.

**S2. Re-body fix (needed by S3-S6).** Nothing visible; it stops the swap costing the player. | — | A new Score
request, e.g. `GetInt("rebody", ...)`, called by `RS_Retier.Swap` before `Destroy`. Score moves the census entry
and the combo-ledger runs from the old body to the new one. Needs two actors through one call (a token on the new
body naming the old, or two calls) [design open]. | Small, but touches Score and RS Monsters. | Also lets Score
carry "was a champion" for the row.

**S3. Heat (rank).** The more you score, the hotter the map. When your reward bar fills, the awake monsters near
you flicker and step up one colour, in a ripple. Losing a life cools them back down. | Arcade: Battle-Garegga-style
rank. Playing well makes it harder and worth more. | A bridge handler reads Score `progress`/`lives` (or
`kill.big`) and calls `RS_Retier.Request(mo, tier+1)`. The tell is RS_Retier's own flicker. | Medium. Risk: a
runaway spiral. Needs a ceiling and a cooldown. | Skip champions and legendaries (`champion_PersistentInfo`,
`LDLegendaryMonsterToken`); never swap them.

**S4. Big moments scare them down.** A named combo or Fatality makes nearby monsters flicker and drop a tier.
Reward rows: "Broke Their Nerve". | Arcade: a smart bomb you earn by style. | Score `kill.big` →
`RS_Retier.Request(mo, tier-1)` in a radius. Pay through `award`. | Medium. | Same skip rule.

**S5. Raise the Stakes (wager).** Watch-check and Use: the whole room tiers up, and kills pay xN until the room is
clear. | Arcade: the "double or nothing" button. | Gestures watch check (as Miniboss calls a Bossfight) →
`rs_retier_all`-style loop → Score `award` with a multiplier. | Medium; it is a new mechanic, so it is the owner's
call. | Same skip rule.

**S6. Lives set the spawn cap.** Hold more Score lives, and the next map's `rs_roster_<family>` caps rise. | Arcade:
the second loop is harder. | At `WorldLoaded`, before monsters spawn, set the server cvars from Score `lives`. |
Low code; risk: the order of handlers at map start [unchecked]. | None beyond section 2.

### RS Monsters x GBOVR

**G1. Free XP scaling.** Already works: a higher tier gives more XP per hit (`PerPlayerStats.zsc:1342`). Zero code.

**G2. The world levels with you.** GBOVR `player.level` sets a tier floor or the spawn caps (as Miniboss's Tier
From does). | Answers "Gun Bonsai makes me a god by MAP20". | Read `RSQGB_Service player.level` → caps, or
`Request` at map start. | Low. | Stacking: tier x champion x legendary at high level is huge; cap it.

**G3. Tier Breaker upgrade.** A GBOVR node: hits have a chance to knock the target down a tier (flicker, then a
weaker colour). | It is a VR power fantasy you can see. | A GBOVR upgrade `OnDamageDealt` → `RS_Retier.Request(t,
tier-1)`. Needs S2. | Medium. WHO_OWNS_WHAT allows it: GBOVR owns upgrades. | Skip champions and legendaries.

**G4. Miniboss EX tier.** `Miniboss/docs/IDEAS.md:13` already parks "EX tier (RS Monsters)". It points to
`/home/claude/work/RSMONSTERS_INVESTIGATION.md`, **which does not exist**.

### Re-tiering BD22's own monsters (recolour + rebuff)

RS_Retier's class swap **cannot** be used on BD22: there is one BD class per monster, not 13. A BD tier would be in
place, the way Champions and the old `RS_MonsterMaster` work.

**B1. Use Champions as the BD tier system.** It already recolours and rebuffs BD22 monsters at runtime. Score
already pays it and names it. SlowMo's DOWN already swaps a monster for a Champions-made copy
(`design/NEAR_DEATH.md:230-241`, rig only). | No new colours; nothing clashes. | Reuse DOWN's copy method as the
re-tier. | Lowest risk. | It IS Champions, so no clash. But Champions picks the colour by its own roll; you cannot
choose "tier 5".

**B2. Our own in-place BD tier.** About 5 named TRNSLATE tints, `A_SetTranslation`, health x factor (StartHealth
too, so Score pays it), speed, DamageMultiply, plus a token for Score's S1 row. | A clear, readable ladder on BD's
gory monsters. | A small handler on `WorldThingSpawned` or a Score/GBOVR trigger. | Medium. | **Colour clash** with
Champions (last `A_SetTranslation` wins) and **health clash** with LegenDoom (its ACS reads SpawnHealth; if we
change it first, its 300% multiplies ours). Rule needed: skip champions, or tier only non-champions.

**B3. Fold in RS Monsters as-is.** This replaces BD22's roster (section 2). It is only right if the owner wants CH
monsters *instead of* BD's. Highest risk: the QZD compile is unknown, 213 MB of assets, and the sprite overrides.

## 5. Open questions for the owner

1. RS Monsters fold-in: CH monsters instead of BD22 monsters, or only its tier ideas applied to BD22's monsters?
2. Must RS Monsters compile on stock QZD 17.3 first? (Unknown; its README says UZDXREMA.)
3. Live re-tier: may it ever touch a champion or legendary, or always skip them?
4. Colour: is the tier shown by colour (clashes with Champions) or by icon/glow only?
5. Heat (S3): does it ever cool down, and what is the top tier allowed?
6. Wager (S5): build it, or not? (A new mechanic is your call.)
7. Should Score pay full base for a re-bodied monster (S2), or keep the 25% anti-farm rule?
8. Health stacking: cap tier x Champions x LegenDoom, or let it run?
9. GBOVR Tier Breaker (G3): wanted as an upgrade node?
10. Which Score/GBOVR pass owns this: the parked one in `design/NEXT_SCORE_GBOVR.md`, or a later one?
