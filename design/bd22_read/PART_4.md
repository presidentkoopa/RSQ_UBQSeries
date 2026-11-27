# BD22 VR Reloaded bug read, part 4: zscript/rsld, core (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

LegenDoom 3.0, Brutal Doom (brutal22test6), RSQ Miniboss, RSQ SlowMo and Champions are not in the repo. Where a
finding depends on one of them it says so.

## Files read
All paths are under `src/`. The `.zs` code files were read with the Read tool, start to end. The generated number
tables and the three lumps were printed whole with `cat -n` and read from that print (see the note on `numbers_*`).

| file | lines | read to the end? |
|---|---|---|
| zscript/rsld/core.zs | 1-374 | yes |
| zscript/rsld/data.zs | 1-126 | yes |
| zscript/rsld/handler.zs | 1-1570 (1-520, 520-1049, 1049-1570) | yes |
| zscript/rsld/pickup.zs | 1-394 | yes |
| zscript/rsld/kiosk.zs | 1-350 | yes |
| zscript/rsld/menu.zs | 1-110 | yes |
| zscript/rsld/ldsounds.zs | 1-130 | yes |
| zscript/rsld/tables.zs | 1-1105 (1-140, 140-1105) | yes |
| zscript/rsld/fx_g0.zs | 1-645 | yes |
| zscript/rsld/fx_g9.zs | 1-96 | yes |
| zscript/rsld/g3_core.zs | 1-524 | yes |
| zscript/rsld/g3_fx.zs | 1-828 (1-420, 420-828) | yes |
| zscript/rsld/g4_bfg.zs | 1-220 | yes |
| zscript/rsld/g6_ammo.zs | 1-458 | yes |
| zscript/rsld/numbers_g0.zs | 1-83 | yes |
| zscript/rsld/numbers_g1.zs | 1-24 | yes |
| zscript/rsld/numbers_g10.zs | 1-13 | yes |
| zscript/rsld/numbers_g11.zs | 1-48 | yes |
| zscript/rsld/numbers_g2.zs | 1-125 | yes |
| zscript/rsld/numbers_g3.zs | 1-263 | yes for effect, key, value and file:line of every row; the fifth field (LegenDoom's quoted source line, which no code reads) was cut at column 150 |
| zscript/rsld/numbers_g5.zs | 1-78 | yes |
| zscript/rsld/numbers_g7.zs | 1-57 | yes |
| zscript/rsld/numbers_g8.zs | 1-59 | yes |
| CVARINFO.rsld | 1-19 | yes |
| MENUDEF.rsld | 1-166 | yes |
| MAPINFO.rsld | 1-8 | yes |

Table checks done by script as well as by eye: all 647 number rows have five fields and a trailing comma; no key is
defined twice with different values; every key the code asks for by a literal name has a row; every dynamic key
family (`<gun>_<kind>`, `rk|pl|bfg_*`, `idle*_*`, `d0..d5`, `s0..s5`) has all its rows; the 180 effect names in
`Rolls` against the 179 `RSLD_Fx_*` classes (only Favoured has no class, by the owner's choice).

Read outside the part to confirm: `zscript/rsld/ld_g5_fx.zs` 205-240, `ld_g5_core.zs` 175-178, `zscript/rsq/fists.zs`
1-60, `zscript/rsvr/melee.zs` 199 and 1488-1498, `actors/Weapons/Saw.dec` 170-206, 419-431, 649-660,
`actors/Weapons/Pistol.dec` 313-317 and 547-556, `SNDINFO.rsld`, `MENUDEF.rsq` 57-64, `ZSCRIPT.rsz`.

## Findings, worst first

## B4.1: A legendary rocket or grenade launcher whose power is not a missile power leaves the blast untouched (Annoying = free rockets with the full blast)
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:685-695, 761, 818; zscript/rsld/g3_core.zs:110-130, 474-481; zscript/rsld/fx_g0.zs:9-57, 487-495
- What the code does: BD22's rocket and grenade blast is a separate actor (RocketExplosion / UGBLExplosion, g3_core.zs:10-15).
  It reaches the handler as a "helper" missile. Only a rider claims it and tags it to the pull (g3_core.zs:119-129,
  478-479). Riders are made only by the `RSLD_G3Fx` family (g3_core.zs:454-460). For every other effect the blast
  stays untagged, and untagged helper damage is passed through unchanged (handler.zs:761) and never counted as a hit
  or a kill (handler.zs:818).
- Why it is wrong: on a rocket or grenade launcher the damage multipliers (Pristine, Raging, Lucky, Berserker,
  Patient, the x3 group powers, DemonSlayer), the on-hit powers and every on-kill power (Artifact, Bloodthirsty,
  Murderous, Violent, WarmUp...) act on the direct hit only. A kill by splash gives nothing. Annoying sets the direct
  hit to 1 and refunds every rocket (fx_g0.zs:487-490) while the blast still does its own 100: an endless rocket
  launcher at close to full strength.
- Checked: that the blast is a missile with the player as target follows from the rider path working at all
  (handler.zs:665-667 comes before 685-687). No other place tags an unclaimed blast (searched `Tag(` in every rsld file).
  Not seen: RocketExplosion itself (Brutal Doom's), and Rocket2's direct-hit number.
- Sure?: likely. Settle on the rig: rsld_debug 2, an Annoying rocket launcher, read the "damage" lines for the blast.
- Fix A: in handler.zs WorldThingSpawned, when `RSLD_G3.IsBlast(a)` and no rider claimed it, tag it to the pull of the
  nearest tagged projectile of that player that has just died (10-15 lines, handler.zs).
- Fix B: give every missile of a legendary pull a plain rider (a shared do-nothing `RSLD_G3Fx`) when its effect is
  not a G3 one; its default `RiderBlast` already tags the blast (8 lines, handler.zs and g3_core.zs).
- Or intended: only if the owner means "non-missile powers work on the direct hit alone".
- Already known?: no

## B4.2: A legendary dropped as a Devastator, Railgun, Unmaker, Flamethrower or Flame Cannon often does nothing
- Kind: wrong behaviour
- Where: zscript/rsld/g3_core.zs:32-44, 452-460; zscript/rsld/data.zs:31-39, 57-68, 109-116; zscript/rsld/g4_bfg.zs:27
- What the code does: a drop is given a random gun of its slot's group (data.zs:109-116). Missile powers ride a
  projectile only when it descends from Rocket2, Plasma_Ball, SuperBFGBall / BFGBall, ShortGrenade or GrenadeMissile
  (g3_core.zs:32-44); anything else is "not a projectile this effect rides" (g3_core.zs:457).
- Why it is wrong: in the repo DEvastatorMissile descends from revenantseekermissiles (actors/Weapons/Devastator.dec),
  RailgunProjectile and FlamethrowerProjectileNew from nothing, UnmakerLaser from FastProjectile. So every missile
  power of LegenDoom's rocket, plasma and BFG slots (Kinetic, Penetrating, Tricky, Spreadfire, Cluster, Bouncy,
  Seeker, Vacuum, TORGUE, Overkill, Nova, Stasis, about fifty in g3_fx.zs, g4_bfg.zs, g6_ammo.zs) is silent on those
  guns. One rocket-slot drop in four is a Devastator, one plasma drop in two a Railgun.
- Checked: the parents of each projectile in src/actors; IncendiaryRocket and NuclearRocket do descend from Rocket2
  and are ridden. Not seen: ShortGrenade2, GrenadeMissileBreaksGlass, the Hellish Missile's and BFG10k's projectiles
  (Brutal Doom's or not in the repo).
- Sure?: certain for the five guns named.
- Fix A: add the missing ancestors to `RSLD_G3.Kind` (DEvastatorMissile as rocket, UnmakerLaser and RailgunProjectile
  as plasma) and check each effect on them (5 lines, g3_core.zs, plus rig time).
- Fix B: have `PickAt` / `Reroll` skip effects the dropped gun cannot carry, by a per-gun kind in data.zs (20 lines,
  data.zs and pickup.zs).
- Or intended: 2.0.5o says these guns "join the slot whose job they share"; if a dud power on them is accepted.
- Already known?: partly. Q6 (owner: "Give them a slot") made the pairing; that the powers then do nothing is new.

## B4.3: With a Machine legendary, the secondary button alone fires the gun, and a dead player keeps firing
- Kind: wrong behaviour
- Where: zscript/rsld/fx_g0.zs:426-443; zscript/rsld/handler.zs:952-956, 1023-1044 (line 1041)
- What the code does: `held.attacking` for the main hand is BT_ATTACK or BT_ALTATTACK (handler.zs:1041). Machine,
  once it has measured the gun's own gap, forces the gun's Fire state every 2 tics while `attacking` is true
  (fx_g0.zs:429-441). `TickPlayer` runs for every player with a pawn, alive or not (handler.zs:952-956).
- Why it is wrong: on the pistol the secondary is the burst toggle (actors/Weapons/Pistol.dec:547-556). A tap of it
  lasts several tics, so a Machine pistol fires shots when the player only changes the mode. The same forced Fire
  cuts into a weapon switch or a kick that runs on the weapon's states. A player who dies with the trigger held keeps
  shooting from the floor until he lets go or the magazine is empty.
- Checked: `gap[k]` is never cleared except on a weapon change (fx_g0.zs:418); the only guards are the Reloading
  token and an empty magazine (fx_g0.zs:435-438). Burst's stand-down (g6_ammo.zs:116) does not cover Machine.
- Sure?: likely. Settle on the rig: Machine pistol, fire twice, then tap the secondary.
- Fix A: in fx_g0.zs:429 require `c.mo.health > 0` and the hand's own trigger: main `BT_ATTACK` only (2 lines); or
  set `held.attacking` from BT_ATTACK alone and add a separate `held.alt` (4 lines, handler.zs and core.zs).
- Or intended: no.
- Already known?: no

## B4.4: The Boss kiosk names one gun and hands over another
- Kind: drifted copy
- Where: zscript/rsld/kiosk.zs:16, 20-25, 34-36, 146, 165-171, 176-194, 211-236; zscript/rsld/pickup.zs:123-129, 187-203
- What the code does: an offer is slot, rarity, effect. "gun" and "class" answer with the slot's own gun
  (kiosk.zs:146, 167). "give" calls `Setup(s, r, e, true)` with no gun (kiosk.zs:185), so the pickup picks a random
  gun of the group (pickup.zs:126) and binds the power to it.
- Why it is wrong: since 2.0.5p a player who buys "SHOTGUN, RARE, CQC" can receive an Assault Shotgun or a Revolver
  with the power bound to that gun. "yours" compares against whatever legendary last sat in that LegenDoom slot, not
  the gun on offer (kiosk.zs:216-223). "give" 2 is documented as "he already carries a legendary of that slot"
  (kiosk.zs:35) but now means "that random gun already has one" (pickup.zs:193).
- Checked: pickup.zs Setup and TryPickup, data.zs PickDropGun. Not seen: the kiosk card itself (RSQ Miniboss).
- Sure?: certain in this repo's code; what the card shows needs RSQ Miniboss.
- Fix A: roll the gun with the offer: `slot|rarity|effect|gun` from `Roll`, pass it to `Setup(..., g)` in `Give`, and
  answer "gun" / "class" / "yours" from it (about 25 lines, kiosk.zs).
- Fix B: keep offers per slot and pass `RSLD_Data.Give[s]` as the gun in `Give` (1 line, kiosk.zs:185).
- Or intended: no; the header comment still describes the pre-2.0.5p rule.
- Already known?: no

## B4.5: Loading a save prints one "two classes for effect ..." line per effect (179 lines)
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:88-136 (lines 93-98, 122-124)
- What the code does: `OnRegister` fills `famCls`, the numbers and `fx`. The engine calls `OnRegister` again on a
  handler it has just restored from a save, with its saved arrays in place. The duplicate test at 122-123 then
  finds every effect already there and prints "RSLD: two classes for effect X: RSLD_Fx_X ignored" without a debug
  check; `famCls` / `famSlot` get every row a second time (harmless, slower).
- Why it is wrong: a wall of false warnings in the console and on screen after every load and hub return.
- Checked: none of the arrays is `transient`; nothing clears them at the top of OnRegister. Not seen: QuestZDoom
  17.3's event code (GZDoom's registers restored handlers through the same path).
- Sure?: likely. Settle: load a save with LegenDoom on and look at the console.
- Fix A: at the top of the LD branch clear `famCls`, `famSlot`, `fx` and rebuild (3 lines), or return early when
  `fx.Size() > 0` after setting `pel`, `pelX`, `hit`, `held` (2 lines).
- Or intended: no.
- Already known?: no

## B4.6: Unfathomable on a projectile gun fired at something close empties the magazine for nothing, or leaves rockets hanging
- Kind: wrong behaviour
- Where: zscript/rsld/g6_ammo.zs:344-366; zscript/rsld/handler.zs:934-949; zscript/rsld/g3_core.zs:165-184
- What the code does: the extra volleys are made in `OnPullEnd`, which runs two tics after the pull
  (handler.zs:938). The magazine is emptied first (g6_ammo.zs:349-350). Then each rider of the pull spawns the
  volleys from its projectile with that projectile's present speed (g6_ammo.zs:359-362).
- Why it is wrong: if the first projectile has already hit (a target within about two tics of flight), either it is
  gone (`!r.m`: no volley at all, the ammo is spent) or it sits in its death state with zero velocity, and the
  volleys are spawned with speed 0: live projectiles that hang in the air and never go off.
- Checked: `Child` uses the speed it is given (g3_core.zs:177); nothing refunds on the `!r.m` path.
- Sure?: likely; which of the two happens depends on Rocket2's and Plasma_Ball's death states (Brutal Doom's).
- Fix A: remember each rider's launch angle, pitch and speed in `RiderSpawn` and spawn the volleys from the gun with
  those; if no rider is left, give the rounds back (10 lines, g6_ammo.zs).
- Or intended: no.
- Already known?: no

## B4.7: Violent's blast sets off more Violent blasts, and from the off hand it is run through the main hand's legendary
- Kind: wrong behaviour
- Where: zscript/rsld/fx_g0.zs:150-184; zscript/rsld/handler.zs:705-754 (738-753)
- What the code does: `RSLD_ViolentBlast` explodes with the player as its target, a tic after the kill. It is not a
  missile and is not tagged, so `FindShot` gives it the no-pull context of the main hand's effect
  (handler.zs:745-753).
- Why it is wrong: main hand holds the Violent gun: each monster the blast kills gets its own blast, a chain through
  a crowd (LegenDoom's blast comes from the puff's kill only, by the comment at fx_g0.zs:147). Violent gun in the off
  hand and another legendary in the main hand: the blast is treated as the main gun's hit (Annoying makes it 1,
  a x3 group power triples it, its kills pay the main gun's on-kill power).
- Checked: `RSLD_Bleed` guards itself with `inDamage` (fx_g0.zs:259-263); the blast does not. Not seen: LegenDoom's
  LDViolentEffectChecker.
- Sure?: likely.
- Fix A: tag the blast to the pull at spawn (`s` is at hand in fx_g0.zs:157) and make Violent's `OnKill` return when
  `hit.inflictor is "RSLD_ViolentBlast"` (3 lines).
- Or intended: the chain, if the owner likes it; the off-hand case no.
- Already known?: related to LD1 (owner: "Fix it", changed in 2.0.5n); this case is left over.

## B4.8: Focusing's accuracy is thrown away after the first pellet of a pull
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:493; zscript/rsld/core.zs:224-227; zscript/rsld/ld_g5_fx.zs:227, 234
- What the code does: Focusing keeps its spread multiplier in the pull's scratch field `s.d2` and applies it to each
  pellet. After every pellet the handler re-aims, it writes that pellet's angle offset into the same `s.d2`
  (handler.zs:493). Nothing reads the handler's value.
- Why it is wrong: on a pull with two or more pellets (twin guns fired from one hand, any multi-bullet shot of the
  chaingun or plasma group) pellets after the first use a random number of degrees as the multiplier: wider than
  normal if positive, no narrowing at all if negative.
- Checked: every use of `.d2` in the rsld files (only these two). One pellet per pull is unaffected.
- Sure?: certain in code; it shows only on multi-pellet pulls.
- Fix A: delete handler.zs:493 (1 line).
- Or intended: no.
- Already known?: no

## B4.9: Legendary powers keep working on a dead player
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:952-956, 999-1044; zscript/rsld/fx_g0.zs:60-68, 500-509, 573-600
- What the code does: `SyncLegends` checks `health > 0` (handler.zs:913), `TickPlayer` does not. Passives and
  `WhileHeld` run on a corpse.
- Why it is wrong: lying dead with a Sensing gun the player hears Plasma/BeepQuiet every second and the pulse still
  marks monsters; Patient beeps up to 50 times; Replicating adds ammo; Illuminating keeps its glow; Machine fires
  (B4.3).
- Checked: no health test in TickPlayer or in `RSLD_ReadyBeat`.
- Sure?: likely.
- Fix A: in handler.zs:954 skip the passives and the hands loop when `players[pn].mo.health <= 0` (keep the RSLD_Amp
  and LegenDoom-weapon housekeeping) (2 lines).
- Or intended: no.
- Already known?: no

## B4.10: A legendary pickup that arrives without an effect bars its gun from legendaries for good
- Kind: wrong behaviour
- Where: zscript/rsld/pickup.zs:32, 129-133, 188-193, 212; zscript/rsld/handler.zs:1193-1218, 1472-1476
- What the code does: if LegenDoom's rarity token has not arrived after 12 tics the converter goes on with rarity -1;
  `Reroll` then keeps an empty effect (pickup.zs:317). The pickup still stores a legendary for the gun
  (`bind.Add(gun, slot, -1, "")`).
- Why it is wrong: that gun now "has" a legendary: every later legendary of that gun is refused (pickup.zs:193), and
  Drop Legendary says "This gun has no legendary power" (handler.zs:1476), so it cannot be removed. While the gun is
  held `SyncLegends` clears and resets the slot every tic (the empty effect resets `gun[s]` to None, handler.zs:1218,
  so the test at 1208 never holds).
- Checked: the three ways into `Setup`. The same stored-empty case comes from the legacy path at pickup.zs:191 when a
  slot has EffectActive but no effect token.
- Sure?: unsure how often LegenDoom fails to roll in 12 tics (its code is not in the repo); the lock itself is certain.
- Fix A: in `TryPickup` and at pickup.zs:191 do not `bind.Add` when the effect is "" (2 lines); in `Setup` give a
  rarity of 0 when r < 0 so `Reroll` can pick (1 line).
- Or intended: no.
- Already known?: no

## B4.11: Proximity projectiles never go away
- Kind: performance
- Where: zscript/rsld/g3_fx.zs:408-455; zscript/rsld/g3_core.zs:380-410
- What the code does: a deployed Proximity projectile stops and then looks for an enemy every fourth tic for ever
  (A_SeekerMissile with SMF_LOOK). Nothing ends it but a hit.
- Why it is wrong: a Proximity plasma rifle leaves every missed ball in the level as a live projectile with a rider
  thinker and a blockmap search. A long fight on a Quest fills the map with them.
- Checked: no fuse or count in the class. Not seen: whether LegenDoom's own Proximity projectile has a lifetime.
- Sure?: unsure about LegenDoom's rule; the missing limit here is certain.
- Fix A: a fuse (go off after N tics deployed) and a cap per player, oldest first (6 lines).
- Or intended: if LegenDoom's also stay for ever and the owner wants the same.
- Already known?: no

## B4.12: Concentrating adds 1 to 11 points to the blast instead of multiplying it, and may set it too late
- Kind: wrong behaviour
- Where: zscript/rsld/g3_fx.zs:577-592; zscript/rsld/g3_core.zs:119-129, 488
- What the code does: the direct hit is multiplied by (tics + 100) / 100, up to 11. The blast gets `explAdd = int(f)`,
  that is +1 to +11 damage on BD22's 100. `explAdd` is set in `RiderDeath`, which runs on the rider's own tick; the
  blast actor is claimed when it spawns, which can be earlier in the same tic.
- Why it is wrong: a rocket that flew for ten seconds hits for x4.5 but its blast is 104. If the blast spawns before
  the rider's tick, even that is lost.
- Checked: every other effect sets its blast numbers in `RiderSpawn`. Not seen: LegenDoom's Concentrating blast rule,
  and when Rocket2's Death state spawns RocketExplosion.
- Sure?: unsure; LegenDoom's RareSpecialEffects.dec would settle it.
- Fix A: keep `explDmgMul = f` up to date in `RiderTick` (2 lines).
- Or intended: if LegenDoom really adds the factor as points.
- Already known?: no

## B4.13: Accelerator's instant shot can hit the shooter
- Kind: wrong behaviour
- Where: zscript/rsld/g3_fx.zs:503-526
- What the code does: the projectile is put back where it spawned and a LineTrace is run from it; only the projectile
  itself and its species (TRF_THRUSPECIES) are skipped. The first shootable actor on the line takes the full hit and
  the projectile explodes there.
- Why it is wrong: if the spawn point is inside the player's own body cylinder (a hand held close) and the projectile
  does not share the player's species, the player is the first actor on the line.
- Checked: no test for `m.target`. Not seen: Rocket2's and the player's Species (Brutal Doom's).
- Sure?: unsure. Settle: read the Species of Rocket2, Plasma_Ball, SuperBFGBall and Doomer.
- Fix A: skip the shooter: `if (v == m.target) v = null` is not enough (the trace stops on him); trace with the
  player as the tracer instead (`m.target.LineTrace(...)` from the muzzle with TRF_ABSPOSITION) (4 lines).
- Or intended: no.
- Already known?: no

## B4.14: Out of VR, a legendary chainsaw on the trigger does not change the saw's real damage
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:558-576, 685-695, 761, 818; actors/Weapons/Saw.dec:198-212, 649-660
- What the code does: the helper word list has "mag" (for magazines). "SawDamageHorizontal" contains it, so the saw's
  damage missiles are helpers: no pull, damage unchanged, no hit or kill counted. The A_Saw trace next to them does 1.
- Why it is wrong: the trigger saw's damage is in those missiles (Damage random(5,6)). In VR the saw runs
  RSVR_SawRun and its cuts are recorded as strikes (Saw.dec:172, melee.zs:1497), so VR is not affected.
- Checked: the 82 missile names the repo's weapons fire against the word list; this is the only real attack caught.
- Sure?: likely, flat play only.
- Fix A: in `IsStrike` accept an ancestor named SawDamageHorizontal (1 line), or change "mag" to "magspawn" / "emptymag"
  after checking Brutal Doom's casing names.
- Or intended: if flat play is not supported.
- Already known?: no

## B4.15: Any player can run the rig probes
- Kind: netplay
- Where: zscript/rsld/handler.zs:1255-1470
- What the code does: `netevent rsld_health:<n>`, `rsld_fx_<Effect>`, `rsld_testlegend`, `rsld_target:<class>`,
  `rsld_cleartargets` (destroys every monster in the level), `rsld_home` and the rest are open to whoever sends them.
  The comment says "TEST: never in a menu"; nothing checks sv_cheats or rsld_debug.
- Why it is wrong: in co-op one player can remove all monsters or hand himself any legendary.
- Checked: only `rsld_drop` is sent by a menu (MENUDEF.rsld:12). `rsldp_drop` is heard and sent by nothing in the repo.
- Sure?: certain.
- Fix A: after the `rsld_drop` line return unless `rsld_debug > 0` (or sv_cheats) (1 line, handler.zs:1264).
- Or intended: single-player rig use only.
- Already known?: no

## B4.16: Kiosk rarity odds do not climb the way the comment says
- Kind: wrong behaviour
- Where: zscript/rsld/kiosk.zs:59-70
- What the code does: `k = clamp((tier - 2) / 9.0, 0, 1)` with tier counted from 1.
- Why it is wrong: tiers 1 and 2 both get 60 / 30 / 10, and tier 10 gets k = 0.89 (about 11 / 26 / 63), not the
  5 / 25 / 70 "at Red (tier 10)". The top is reached only at tier 11.
- Checked: handler.zs:846-849 (tier = RSQ Miniboss's + 1). Not seen: how many colours RSQ Miniboss has.
- Sure?: unsure which tier Red is.
- Fix A: `(tier - 1) / 9.0` if Red is this file's tier 10 (1 line).
- Or intended: if Red is RSQ Miniboss's own tier 10 (this file's 11); then only the two equal first steps remain.
- Already known?: no

## B4.17: Per-tic and per-shot costs a Quest will feel in long fights
- Kind: performance
- Where: zscript/rsld/data.zs:83-107; zscript/rsld/pickup.zs:368-393; zscript/rsld/handler.zs:175-183, 392-411, 1193-1214; zscript/rsld/core.zs:49-56; zscript/rsld/g3_fx.zs:594-602, 716-729; zscript/rsld/g6_ammo.zs:344-366, 408-414
- What the code does:
  1. `SlotOf` -> `Carries` -> `SameGun` and `SyncLegends` -> `Find` -> `BaseGun` split up to 24 strings on every call.
     They run several times a tic per player (SyncLegends, the hands loop, StandDown, every `RSLD.Count`), and every
     frame for the name on screen (`SlotOfUI`).
  2. `RSLD.Num` / `RSLD_G3.N` look the handler up by name and build a key string on every call; Hyper, Sluggish,
     Vacuum, Waveform, Irradiated and Proximity call it 1-4 times a tic for each projectile in flight.
  3. Every pellet makes two new objects (handler.zs:394-396) and every pull one; an SSG shot is 41 objects.
  4. Vacuum runs A_RadiusThrust over 1024 units every tic for every projectile (g3_fx.zs:599).
  5. Unfathomable fires the whole pool in one tic: a minigun's reserve is hundreds of traces with puffs at once
     (g6_ammo.zs:349-352).
  6. Overkill spawns 410 LegenDoom actors at the blast (g3_fx.zs:726-727); Overflowing walks the whole inventory four
     times on every pull (g6_ammo.zs:410).
  7. Many `s.Log(String.Format(...))` lines build the text even with the debug log off (for example fx_g0.zs:113, 454).
- Why it is wrong: none breaks the game; together they are frame time on a Quest in the heaviest moments.
- Checked: the per-tic call sites listed. Nothing was measured.
- Sure?: certain they run; unsure how much they cost.
- Fix A: cache per weapon class its base gun and slot in a Map at OnRegister (15 lines, data.zs and handler.zs); use
  the handler each effect already holds in `h` in the G3 code instead of looking it up by name; cap Unfathomable's volleys
  per tic and spread the rest over the next tics; test `RSLD.Debug()` before formatting.
- Or intended: Vacuum, Overkill and Unfathomable copy LegenDoom's rules.
- Already known?: no

## B4.18: With two players, one player's BFG powers touch the other's rays
- Kind: netplay
- Where: zscript/rsld/g3_core.zs:200-209, 259-264, 303-312; zscript/rsld/g4_bfg.zs:20, 41-43
- What the code does: `flashMuteUntil` and the ray catch (`catchS`, `catchDmg`...) are one set for the level, not one
  per player.
- Why it is wrong: while one player's muted BFG ball dies, another player's ray flashes in the same two tics are
  removed; while Annihilating or Raycaster catches flashes, another player's rays get the blasts too.
- Checked: `rayUntil` / `rayMul` are per player; these are not.
- Sure?: certain in code; co-op only.
- Fix A: index both by player number and test the flash's target (10 lines).
- Or intended: single-player only.
- Already known?: no

## B4.19: Menu and settings that do not say what they do
- Kind: setting or menu
- Where: MENUDEF.rsld:33-34, 36-37, 22-29; CVARINFO.rsld:6-7, 16; zscript/rsld/handler.zs:691, 879-887; zscript/rsld/pickup.zs:35
- What the code does and why it is wrong:
  1. "Test and Debug" is described as "Drop rules, tuning and the debug log"; the page holds the Debug Log row only.
  2. Debug Log is On / Off on a 0-2 setting, and the code also has a level 3 (handler.zs:691) the comment in
     CVARINFO.rsld:16 does not list.
  3. With Legendary Economy off, or without Champions and RSQ Miniboss, Boss Fights Only, Champions Drop and Rarity By
     Tier do nothing (`BossfightOnly` returns false first) and nothing on the page says so.
  4. `rsld_reroll` is defined and read by nothing.
- Checked: every cvar in CVARINFO.rsld against its readers; every menu row's cvar exists; `rsq_ld_economy`'s row is in
  MENUDEF.rsq:61. The "// tip:" lines are comments in this repo; whether another mod shows them was not seen.
- Sure?: certain.
- Fix A: reword the tip; make the Debug row a 0-3 slider or an Option with its own values; grey the three Drops rows
  (or add one static line) when the economy is off (5-10 lines, MENUDEF.rsld).
- Or intended: items 2 and 4 are.
- Already known?: partly. LD10 (Debug Log On/Off: "Left as is: invisible"), LD3 (rsld_reroll row removed on purpose),
  LD4 and Q5 (the rows need RSQ Miniboss: "Logged"). The Economy-off case and the tip are new.

## B4.20: Table rows and code nothing reads
- Kind: dead code
- Where: zscript/rsld/numbers_g0.zs:37-38; numbers_g1.zs:13-17, 20; numbers_g11.zs:21; numbers_g2.zs:14, 25-30, 32-38, 40-78, 82, 96, 102, 107, 110; numbers_g3.zs:173; numbers_g5.zs:14, 37, 74; numbers_g8.zs:10-13; zscript/rsld/tables.zs:119, 243, 354, 445, 543, 569, 663, 791, 922, 1035 (the nine `|Epic|Favoured` rows and `Pistol|Rare|DualWield`, effects the owner dropped: they never roll); zscript/rsld/handler.zs:921; zscript/rsld/pickup.zs:67; zscript/rsld/handler.zs:1263
- What the code does: no code asks for Machine.normaltics / normalend, Decaying.rocket_hi, the four Favoured rows,
  Convincing.tokens, Beam.fwd, Base.ss_dmg, Base.cg_cyc, 52 of the 54 Choked offsets (only sg_h3 and ss_h0 are read),
  Cursed.hitguard, Perfect.hitguard, Renegade.scream, Slug.sg_k / ss_k, Spamtastic.bfg_div, Burst.pi_gap,
  Accelerator.rl_pre, Scrounger's shell and rocket rows. handler.zs:921 `snapW[k] == s.weapon || s.weapon` is always
  true. pickup.zs:67's "no legendary death matched" can no longer print since 2.0.6b. "rsldp_drop" is heard, never sent.
- Why it is wrong: a player sees nothing. For part 5: Scrounger's shell and rocket numbers unread may mean Scrounger
  only tops up clips; Slug's 7 and 10 multipliers unread may mean Slug's damage is built another way. Not followed.
- Checked: a search of every rsld file for each key, literal and built.
- Sure?: certain that nothing reads them.
- Fix A: leave the generated rows; delete the three dead bits of code (3 lines).
- Or intended: yes for the generated tables.
- Already known?: no

## B4.21: With a main-hand legendary gun and a plain off-hand gun fired in the same tic, the off gun's close hits take the legendary
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:738-744
- What the code does: damage with no tagged inflictor in a tic where the main hand pulled goes to the main pull
  (line 740) before the off hand's "no legendary" rule (line 743) is looked at.
- Why it is wrong: only for hitscan hits (True Bullets off, or a target nearer than a round is made for).
- Checked: rounds, missiles and strikes are tagged or marked NoFx and are not affected.
- Sure?: likely; small.
- Fix A: use `pendRec[pn]`'s shot when a trace is running, before the tic rule (3 lines).
- Or intended: no.
- Already known?: yes, LD1, owner said: "Fix it. Changed in 2.0.5n (code only, not run)". This is what is left of it.

## B4.22: Brutal Doom's Dual Pistols weapon is taken away whenever LegenDoom is loaded
- Kind: wrong behaviour
- Where: zscript/rsld/handler.zs:1067-1095; zscript/rsld/pickup.zs:257-263
- What the code does: Dual Pistols is kept only while the pistol slot's legendary is DualWield, and DualWield never rolls.
- Sure?: certain.
- Fix A: none.
- Or intended: yes.
- Already known?: yes, LD11, owner said: "dualweild seems like a pointless legendary in a vr game". DualWield never
  rolls from 2.0.5n; the Dual Pistols weapon stays put away.

## B4.23: LegenDoom's screen shake option is switched off on every map
- Kind: setting or menu
- Where: zscript/rsld/handler.zs:142-151; zscript/rsld/menu.zs:94-96
- Sure?: certain. It also changes the player's saved LegenDoom setting.
- Fix A: none.
- Or intended: yes.
- Already known?: yes, LD12, owner said: "Fine as is".

## Things that looked wrong and are not (so the next reader does not chase them)
- `dropX` / `dropY` (handler.zs:896) are declared in kiosk.zs:334 by `extend class RSLD_Handler`.
- `Rolls` spells some names two ways (GyroJet / Gyrojet, QuarterMaster / Quartermaster): every reader compares
  without case, and class names are looked up without case.
- The top champion row's weights 65 / 35 / 6 / 4 sum to 110 (pickup.zs:287): they are weights, the owner's numbers;
  already LD10.
- `infoWas` is one flag for all players (handler.zs:1053) but only the console player ever changes it
  (ldsounds.zs:22); the two `consoleplayer` reads in ldsounds.zs only choose a local sound.
- Number keys the code asks for all exist. `% int(Num(...))` in g3_fx.zs:642 and `/ int(use)` in fx_g0.zs:565 would
  abort on a missing row, but both rows are there (Irradiated.period 35, Efficient.use 2).
- A plain off-hand rocket's or grenade's blast does not take the main gun's legendary: handler.zs:761 passes
  untagged helper damage through (the same rule that causes B4.1).
- Family, Variants and DropGuns names not in the repo (BFG10k, PuristBFG10k, DualSMG, DualMP40, DualFlameCannon,
  Melee_Attacks) are guarded by `if (c)` everywhere they are used.
- GroupTherapy's chain cannot chain again: its direct damage runs inside `inDamage` and its blasts have no rider
  (g3_fx.zs:375-378).
- Scattering's rays leave the player's body along the ball's horizontal angle, not the barrel
  (g4_bfg.zs:167-171): that is how A_BFGSpray works for every BFG here; only the comment promises more.
- `RSLD_Boom.Tick` has no `Super.Tick()` on purpose; it has no states to run.
- menu.zs:3 says LegenDoom's MENUDEF loads after BD22 VR, SNDINFO.rsld:1 says LegenDoom loads before it. The menu
  code works in either order; the sound order is the owner's open rig check LD8.
- `RSLD_GunBind` keeps a gun's legendary when the gun itself is lost; picking the gun up again brings it back.

## Not read or not checkable
- The `ld_*` files (part 5) beyond the lines listed above.
- LegenDoom 3.0: every `LD*` class, token, ACS script (LDMenuToggle, LDWeaponPickupEffectActivation) and LANGUAGE
  key named by string. All are looked up at run time and most are null-checked; whether the names are right was not
  checkable.
- Brutal Doom: Rocket2, Plasma_Ball's parents' behaviour, RocketExplosion, UGBLExplosion, SuperBFGExtra, Marine_Rifle,
  HeavyArmor, Clip2 / AmmoShell / AmmoRocket / AmmoCell, PowerStrength use, and these sound names, none of which is
  defined in the repo: BERSPKUP, Explode1, Explode6, Plasma/Beep, Plasma/BeepBeep, Plasma/BeepQuiet, Plasma/AltFire,
  Grenade/Bounce, Barrel/explode, Devastator/explode, Explosion, BFG/Charge, BFG/Fire, SLOWON, MEGAPKUP,
  Pickup/HeavyArmor, Pickup/Invis, BACKPACK, misc/w_pkup. Thieving's "is this ammo full" test (fx_g0.zs:349-351) looks
  for the pickup class Clip2 in the inventory; if Clip2 is not the ammo class itself it never finds it.
- QuestZDoom 17.3's engine: that it re-runs OnRegister on load (B4.5), its menu descriptor fields (menu.zs:34-46),
  WorldHitscanPreFired / OffhandWeapon / AttackPos.
- RSQ Miniboss, RSQ SlowMo, Champions: the services asked by name (handler.zs:843-862, 885-886) and the kiosk's card.
- The `Repl` table (tables.zs:8-63) was measured on the owner's rig; its class names could not be checked here.
