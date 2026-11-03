# Score ideas, lane C: Champions, LegenDoom, Miniboss, SlowMo, Tactical Rig

Proposals only. Nothing here is built or approved; every name is for the owner to veto. Written 2026-11-03.

## Summary

| Area | New ideas | Reworks of existing rows |
|---|---|---|
| 1. Champions and LegenDoom (colour powers, mutations, legendaries, packs, LegenDoom 3.0 weapons) | 37 | 2 |
| 2. Miniboss | 10 | 3 |
| 3. SlowMo (and the rename of "Bullet Time") | 8 | 3 |
| 4. Tactical Rig (kill-tied only) | 7 | 2 |
| 5. Named 2-tool and 3-tool combos (where these areas meet the fighting tools) | 30 chains + 3 cross-area rows | - |
| 6. Stale or wrong rows found | 17 | - |

Total: 95 new ideas (62 rows, 30 chains, 3 cross-area rows), 10 reworks, 17 stale or wrong items.

**Sources read, not remembered.** The three attachments, unpacked and read:
`mk-champions20210309.pk3` (every `champs/champ_*.txt`, `baseclass.txt`, `handler.txt`, `extrafx.txt`, `tokens.txt`,
`cvarinfo.txt`), `LegenDoomLite_4.2.pk3` (`DECORATE`, `source/LEGNDLIB.acs`, `CVARINFO`) and `LegenDoom_3.0.pk3`
(weapon `decorate/*`, `LANGUAGE.effectname/effectdesc`). In the repo: `Score/README.md`, `Score/zscript/rsscore/`
(boost, bonus, combo, event, handler, physical, melee, hook, awards), `Miniboss/` (README, `zscript/rsqmb/`
handler, boss, items, service), `SlowMo/` (README, `zscript/rsqsm/clock.zs`, `body.zs`), `Melee/zscript/rsqml/`
(shove, headlock, service), `TacticalRig/` (README, `zscript/rsqtr/rig.zs`, `hooks.zs`).

**Scale used.** Champion colour rows pay 0.25, rare tiers 0.5 to 0.75, Legendary 1.5; most rows 0.2 to 0.5; named
2-tool combos 0.4 to 0.5, 3-tool 0.9; the per-kill cap is 3x base (`rs_score_cap_kill` 300). A champion's base is
already its boosted StartHealth, so power rows stay small. Pays below are multipliers of the kill's base unless
marked "award" (flat points through `RS_ScoreHandler.AwardExternal`, or an internal award of a fraction of a base).

**Facts that change the design (from the code, not memory):**
- **There is no reflecting champion in this Champions build.** `champion_SilverReflection` (a reflective
  PowerInvulnerable) and `champion_SilverShield` are defined in `champ_silver.txt` but nothing ever gives them. There
  is also no regenerating colour and no shielded colour. The armoured ones are Bronze (damage taken x0.5, PainChance
  0, infinite Mass), Gold (health x5, Mass x12, PainChance x0.1) and Titan (damage taken drops 10 % per nearby monster
  it buffs, to 10 %). The ideas below use the powers that really exist.
- **Magenta** has a token (`champion_MagentaToken`) and a LegenDoom pentagram colour but no controller: it never
  spawns. No row needed.
- **LegenDoom Lite 4.2 (the owner's order) has no legendary weapons.** Only LegenDoom 3.0 does, and LegenDoom 3.0
  replaces the weapon set (`LDPistol : LDWeapon` ...), so it cannot sit on the BD22 order. LD3 rows are marked as such.
- **A risen legendary is DONTGIB, NOINFIGHTING, NOTARGET, ALWAYSFAST, MISSILEMORE/EVENMORE** (`LDLegendaryMonsterStatBoost`);
  a boss legendary also NOPAIN and DONTTHRUST. So a gib, a push or an infight on a legendary only happen before it rises.

---

## 1. Champions and LegenDoom: going beyond

All rows Daring unless said. All read only by NAME (inventory class, actor class, cvar, lump), like `boost.zs`.
"Active" means `RS_Boost.ChampActive(v)` (dormant mode respected). Every row pays only a player's kill.

### 1a. One idea per colour power

| # | Name | Family | Trigger (plain words) | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| 1 | **Blink and Miss** | Daring | Kill a Green champion within 1 s of it teleporting. | Green: `champ_green.txt` TickEffect spawns `TeleportFog` at both ends of the jump (every 35 tics, 1 in 5 with a target; Legendary 1 in 3, 1.5x the steps). Score's spawn hook (handler WorldThingSpawned already compares classes) notes a `TeleportFog` born within 64 units of a living active `champion_GreenToken` carrier: `Mark(v,'blink')` with the tic. Evaluate: victim marked within 35 tics. | 0.35 | new |
| 2 | **Matador** | Daring | Kill a Grey champion during its lunge or sidestep. | Grey's lunge (48 forward) and sidestep (16 aside) both give `champion_GreyShadowSpawner` for 20 tics (`champ_grey.txt`). Victim carries it at the kill. 0.5 with a melee kill (`ev.meleeKind` not MK_NONE) or Point-Blank, else 0.3. | 0.3 / 0.5 | new |
| 3 | **Into the Wind** | Daring | Kill a Cyan champion with a melee blow or from inside 64 units: you fought through its wind to get there. | `champion_CyanToken`; its TickEffect is `A_RadiusThrust(192, 384)` every tic (384 Legendary), and its hits on you thrust you 24 away (`handler.txt` WorldThingDamaged). Melee kind or `ev.edgeDistance <= 64`. | 0.35 | new |
| 4 | **Caught in the Field** | Daring | Melee-kill a Silver champion while its magnet drags you in. | `champion_SilverToken`; TickEffect `A_RadiusThrust(-224, 384)` (-384 Legendary) pulls you. Melee kind and `ev.edgeDistance <= 384`. | 0.35 | new |
| 5 | **Too Close for Comfort** | Daring | Kill an Orange champion with a melee blow or at Point-Blank, and still be alive 1 s later (its death blast is on you). | `champion_OrangeToken`; its DeathEffect spawns `champion_Explosion` (Legendary: `champion_ClusterExplosion` + 8 `champion_MiniCluster`). Score holds the kill's pay open 35 tics (an internal award like Indiana Jones) and pays if `killer.health > 0`. | award 0.5 x base | new |
| 6 | **Demolition** | Style | Another monster dies in an Orange champion's death blast. | Inflictor class `champion_Explosion`, `champion_ClusterExplosion` or `champion_MiniCluster`. The blast's `target` is the champion's target (`champ_orange.txt`), usually you, so it is already your kill; today it pays nothing special. Second and later kills of one blast +0.15 each (Powder Keg's shape). | 0.3, +0.15 per extra (to 0.9) | new |
| 7 | **Fireworks** | Style | Another monster dies to a Blue champion's death burst of fireballs, after you killed the Blue. | Inflictor `champion_Fireball1` whose `target` is a Blue champion (`champ_blue.txt` DeathEffect: rings of fireballs; they pass through the Blue's own class only). Today the fireball's owner is a dead monster, so the kill pays everyone Infighter. Score credits it to the player Score paid for that Blue (handler `kVictim` / `kPn`) within 3 s. | 0.35 per kill (paid to the Blue's killer) | new (also fixes credit) |
| 8 | **No Sequels** | Daring | The Indigo champion and all of its clones dead within 2 s of the Indigo's death. | Indigo DeathEffect spawns 2 clones (4 Legendary) of its class with `champion_CloneToken` at its position (`champ_indigo.txt`). Score already sees clone deaths (`RS_Boost.NotAKill`) but pays none. Note the Indigo's death tic and place; count clones born there that tic; when the last dies in time, award. | award 0.5 x the Indigo's base | new |
| 9 | **Last Rites** | Daring | Kill a Pink champion within 3 s of it raising a corpse. | Pink TickEffect (every 70 tics) `RaiseActor`s dead monsters within radius x4 (x8 Legendary) and pays 20 % of its own health per raise; stops at 20 % health (`champ_pink.txt`). Score's `WorldThingRevived` notes the revived body; the nearest active `champion_PinkToken` within radius x8 is marked `'raised'` with the tic. | 0.4 | new |
| 10 | **Stay Down** | Daring | Destroy a Dark Red champion's corpse so it can never get up. | Dark Red is BUDDHA; at 1 HP it hides at (16384,16384) and drops a `champion_ShootableCorpse` (30 HP, ISMONSTER, not counted). Shoot the corpse and the champion is `A_Die()`d at the corpse with no source (`champ_darkred.txt`). Score notes the corpse's killer (its WorldThingDied has the blow) and pays this row, and the champion's real kill, to that player. A kick or stomp on the corpse: +0.2 (**Curb Stomp**). | 0.5 (+0.2) | new (also fixes credit, see stale #10) |
| 11 | **Encore** | Daring | Kill a Dark Red champion that already got back up once. | If nobody destroys the corpse in 105 tics it rises at 33 % health (66 % Legendary) and the corpse is destroyed without dying. Score's `WorldThingDestroyed` sees a `champion_ShootableCorpse` go with health above 0 and marks the nearest Dark Red `'encore'`. | 0.25 | new |
| 12 | **Glass Cannon** | Daring | Kill a Black champion in one blow from full health. | Black deals x2 AND takes x2 (`champ_black.txt`: DamageMultiply and DamageFactor both x2). Score keeps the victim's health before the killing blow (RS_ScoreShots already hears WorldThingDamaged); full means it equalled StartHealth. | 0.35 | new |
| 13 | **Faster Than Fast** | Daring | Kill a Yellow champion while it is attacking. | Yellow cuts every state's tics by 1.5 (2.0 Legendary) and speeds its missiles the same (`champ_yellow.txt`, `handler.txt`). Same state test Counter uses (Missile/Melee sequence, or fired within half a second), on a `champion_YellowToken` victim, any weapon. | 0.35 | new |
| 14 | **Through the Storm** | Daring | Kill a Violet champion while 3 or more of its seeking fireballs are in the air near you. | Violet fires `champion_Fireball2` (SEEKERMISSILE) in fans of 1 to 8 every 30 tics (20 Legendary). At the kill, a BlockThingsIterator round the killer (512) counts `champion_Fireball2` whose `target` is the victim. | 0.4 | new |
| 15 | **Toxic Avenger** | Daring | Kill a Dark Green champion while its poison or creep is eating you. | Its hits give you `champion_Poison` (powerup `champion_PoisonBase`, 2 a second); its creep (`champion_DarkGreenCreep`) deals `'champion_Toxic'` (5 a second). Killer carries `champion_PoisonBase`, or took `'champion_Toxic'` damage in the last 35 tics (Score's player WorldThingDamaged notes it). | 0.3 | new |
| 16 | **Molasses** | Daring | Kill a White champion while its creep has you slowed. | White gives you `champion_Slowness1/2` -> powerup `champion_SlownessEffect` (PowerSpeed 0.33) by creep, aura and hits. Killer carries `champion_SlownessEffect`. | 0.3 | new |
| 17 | **Immovable Object** | Melee | Melee-kill a Bronze champion. | Bronze: damage taken x0.5, PainChance 0, Mass 0x7FFFFFFF (no knockback, no Ring Out, no Headlock), states x1.75 slower (`champ_bronze.txt`). `champion_BronzeToken` + melee kind. | 0.4 | new |
| 18 | **Midas Undone** | Daring | Kill a Gold champion while a monster it gilded still lives near it. | Gold gives `champion_MidasTouch1/2` to monsters within radius x3 (x5 Legendary): they get `champion_GoldToken`, Mass x12, damage taken x0.66 (x0.33 Legendary), with no `champion_PersistentInfo`. At the kill, any living monster within radius x5 carrying `champion_GoldToken` and not `champion_PersistentInfo`. | 0.4 | new |
| 19 | **Fool's Gold** | Daring | Kill a monster a Gold champion gilded. | `champion_GoldToken` without `champion_PersistentInfo`. Its health was never raised, so the base does not hold its toughness. | 0.2 | new (see stale #11) |
| 20 | **Pop!** | Style | Kill a Balloon champion with anything but a gun: a throw, the hook, the whip, a thrown gun, the disc, the saber. | Balloon detection as today (`RS_Bonus_MutBalloon`); the chain's last tool is not `gun`. (Skeet and Juggle skip NoGravity bodies, so balloons pay nothing for being in the air today.) | 0.3 | new |
| 21 | **Ghostbuster** | Daring | Kill a Ghost champion in the moment it is solid. | Ghost: VISIBILITYPULSE; the controller sets SPECTRAL while alpha < 0.5 and clears it at 0.5 or more (`baseclass.txt`). At the kill `v.alpha < 0.65`: caught just as it came back. (What SPECTRAL lets through on QZD 17.3 is to measure.) | 0.3 | new |
| 22 | **Heartbreaker** | Daring | Kill an Undying champion within 2 s of killing its heart. | The heart (`champion_Heart`, 50 HP, 200 on a boss, only players can hurt it: `extrafx.txt`) clears the master's BUDDHA on death. Score already marks `'undying'` on the heart's death (`RS_Boost.NoteDeath`); keep its tic. Stacks with Undying. | 0.35 | new |
| 23 | **Divide and Conquer** | Daring | Kill a Titan with no other monster within 384 units. | Titan: DamageFactor = 1 - 0.1 x the monsters it gave `champion_AggroEffect` in 384, floor 0.1, recomputed every tic (`baseclass.txt`). Count monsters (not `champion_Heart`) within 384 of the victim at the kill. 0 = this row. | 0.3 | new |
| 24 | **Pack Leader** | Daring | Kill a Titan with 5 or more monsters around it (it was taking half damage or less). | Same count, 5 or more. Replaces Divide and Conquer. Big moment. | 0.6 | new |
| 25 | **Pinata** | Style | Gib a champion. | Champions doubles its loot when `Health <= GetGibHealth()` at death (`baseclass.txt` champion_SpawnBundles); Score reads the same test at the kill. Not on a risen legendary (DONTGIB). | 0.25 | new |

### 1b. Packs, order and streaks

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| 26 | **Decapitation** | Daring | Kill the rarest champion of a group first, while 2 or more other champions live within 768 units of it. | Rarity from Champions' own weights (`cvarinfo.txt` `champion_weight_*`: the 14 colours 10, Bronze 3, Silver 2, Gold 1; any mutation counts as rarer than none, Titan 2 of 24). At the kill, BlockThingsIterator 768 for active champions; victim rarer than all of them. | 0.4 | new |
| 27 | **Pecking Order** | Style | Kill 3 or more champions of one group, each within 5 s of the last, from the commonest up to the rarest last. | A per-player run kept in Score (victims within 768 of the first, rarity never falling). Paid on the last kill. | 0.2 per champion in the run (to 0.8) | new |
| 28 | **Champion Streak** | Efficiency | Champion kills back to back, each within 5 s of the last. | Per-player note in the tracker. | 0.1 per earlier (to 0.5) | new |
| 29 | **Rainbow** | Style | Kill champions of 5, 10 and all 14 different colours in one map. | Per-player set of colour tokens killed this map (a hybrid's two count). Paid on the kill that completes the set. | award 0.5 / 1.0 / 2.0 x that kill's base | new |
| 30 | **Colour Clash** | Style | A champion dies to another champion's power that your kill set off (an Orange blast, a Blue burst). | Rows 6 and 7 with an active champion as the victim: paid on top of them. | 0.25 | new |

### 1c. LegenDoom (Lite 4.2 on the owner's order; 3.0 marked)

LegenDoom Lite's ACS (`LEGNDLIB.acs` LDMonsterInit) checks once a tic: at half of 300 % it refills and gives
`LDLegendaryMonsterTransformed`.

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| 31 | **Strike While It Rises** | Daring | Kill a legendary within 2 s of it rising. Its refilled 300 % went in one burst. | Score's combo ledger already polls touched monsters each tic: note the first tic it sees `LDLegendaryMonsterTransformed`. Replaces nothing; Legendary pays as well. | 0.5 | new |
| 32 | **Rude Awakening** | Daring | The same, on a dormant champion that woke at the rise (powers just switched on). | Row 31 with `RS_Boost.DormantMode()` and `ChampActive(v)`. Replaces row 31. | 0.75 | new |
| 33 | **Sleeper Denied** | Daring | Kill a dormant legendary champion before it rises: you denied its rise AND its powers. | `Champion(v) && DormantMode() && Legendary(v) && !Transformed(v)`. Today such a kill pays Legend Denied only (boost.zs header: "a champion that never transformed in that mode ... pays nothing here"). | 0.25 (on top of Legend Denied) | new |
| 34 | **One-Tap Legend** | Daring | Kill a legendary from full 300 % in a single blow. | Victim's health before the killing blow (kept as in row 12) equals spawn health x `LD_legendaryhealth`/100 (cvar by name). Replaces Legend Denied. Big moment. | 1.0 | new |
| 35 | **Legend Slayer** | Daring | Two legendaries killed within 10 s. | Per-player note. Paid on the second. | 0.5 | new |
| 36 | **Demon Slayer** (LD3 only) | Style | Kill a legendary with LegenDoom 3.0's Demon Slayer's effect. | `ev.damageType == 'DemonSlayer'` and `RS_Boost.Legendary(v)`; LDL's `LDLegendaryMonsterResistances` gives DemonSlayer x4. | 0.3 | new |
| - | **Legendary Arms** (LD3 only) | Style | Kill with a legendary weapon. | The killer holds `<ReadyWeapon class>Legendary<Common/Uncommon/Rare/Epic>` (LD3's naming, e.g. `LDPistolLegendaryRare`; Gun Bonsai's `LegendoomUtil.GetWeaponRarity` reads the same). Only when LD3 is loaded (it replaces the weapon set: not on BD22). | 0.1 / 0.15 / 0.2 / 0.3 by rarity | new (counted with 36) |

**Reworks in this area:** Legendary Champion (0.5): fine as is, but should also pay Strike While It Rises' successor
(row 32). Legend Denied (0.75): becomes the floor under One-Tap Legend (row 34 replaces it).

---

## 2. Miniboss

Facts by name: thralls carry `RSQMB_Thrall`, the miniboss `RSQMB_Ward`, enraged monsters `RSQMB_Rage`
(`Miniboss/zscript/rsqmb/items.zs`); `RSQMB_Service` answers `window` (tics left), `enraged`, `greed`, `living`,
`lives`, `invulnerable`, `shield`, `legendary` and GetString `powers`, GetObject `boss` (`service.zs`). Watch out:
`thrall`, `lives` and `invulnerable` answer 0 for a body at 0 health, so Score must read tokens at the kill or ask in
WorldThingDamaged before the death.

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| M1 | **Chain Gang** | Daring | Thralls killed one after another inside one slow window; each one pays more. | `RSQMB_Thrall` on the victim; window open before the kill (`window` > 0, asked in WorldThingDamaged, since the kill itself extends it by 3 s). Score counts thrall kills per window. | 2nd 0.4, 3rd 0.8, more 1.0 | new |
| M2 | **Severed** | Daring | Kill the miniboss within 1 s of its last thrall dying (its shield just dropped to nothing). | `RSQMB_Ward` on the victim; Score notes the tic `living` reached 0. | 0.5 | new |
| M3 | **Life Taker** | Daring | Take one of the miniboss's lives (a "kill" that does not end it). 0.5 if taken inside a slow window. | Miniboss sends `award "Life Taker"` from `RSQMB_Boss.LoseLife` (boss.zs:104) with points = 0.25 x the miniboss's spawn health; or Score polls `lives` on the Ward carrier. | award 0.25 / 0.5 x base | new |
| M4 | **Wake-Up Call** | Daring | Kill a revived thrall within 2 s of it rising. | `WorldThingRevived` on a body carrying `RSQMB_Thrall`; mark tic. | 0.3 | new |
| M5 | **Stay Dead** | Daring | Gib a thrall: a gibbed thrall never rises (README "A gibbed thrall stays dead"). Only possible before a legendary thrall rises (DONTGIB after). | `RSQMB_Thrall` and `Health <= GetGibHealth()` at the kill. | 0.3 | new |
| M6 | **Pulled It Off** | Daring | Greed was armed (you hit the miniboss early), and you cleared the last thrall before it came due. | At a thrall kill: boss (`GetObject "boss"`) answers `greed` 1 and `living` hits 0. | 0.5 | new |
| M7 | **Rage Quit** | Daring | Kill the miniboss while its rage runs (every monster twice as fast). | `RSQMB_Ward` victim; `enraged` (no object) 1. Big moment. | 0.75 | new |
| M8 | **Riot Control** | Daring | Kill an enraged monster. | Victim carries `RSQMB_Rage`. | 0.15 | new |
| M9 | **Inheritance Tax** | Daring | The miniboss pays for each power it inherited (its toughness and damage live in a ModifyDamage token, not in its base). | GetString `powers` on the Ward carrier at death (before Finish: ask in WorldThingDamaged), count the commas. | 0.15 per power (to 0.6) | new |
| M10 | **Power Cut** | Daring | Kill first the thrall whose colour the miniboss inherited and still wears. | Thrall's `champion_*Token` also on the boss, and no thrall had died yet. | 0.3 | new |

**Reworks:** Thrall Slow Kill (flat 100), Miniboss (flat 500) and Greedy (flat 1000) should become multipliers of the
body's base, so a miniboss imp and a miniboss Cyberdemon do not pay the same. Proposed: Thrall Slow Kill 0.3 (becomes
the first step of Chain Gang), Miniboss 1.0, Greedy 1.5 (rare, big moment). See stale #6.

---

## 3. SlowMo

### The rename of "Bullet Time"

Taken in the series already, so not proposed: Time Dilation, Matrix, Showdown, Adrenaline, Deeper (Gun Bonsai VR),
Slow Burn (RSQ Grenade), Akimbo (Gun Bonsai VR). Proposals, best first:

1. **Stretched Second** (says what happened, no film name)
2. **Frame by Frame**
3. **Time Thief**
4. **Deadeye**
5. **Slow Hand**

### Ideas

Facts: `RSQSM_Service` answers `slowmo.active`, `running` (held or pulsing, not easing out), `scale` (permille).
The clock keeps `pulseSrc` (the trigger's name: `key`, `wristcross`, `wheel`, `a11y.button`, `melee.shove`, `smoke`,
`saber.parry`, `shieldsaw.block`, `miniboss`, `score`, `gunbonsai`, `othermod`) and whether it was automatic, but does
not answer them. **Needed (proposed, one line each in clock.zs's RSQSM_Service):** GetString `trigger.src`, GetInt
`trigger.auto` and `trigger.tic` (the tic the current slow motion started). Without them rows S3, S4, S9 cannot tell a
deliberate slow-mo from an automatic one.

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| S1 | **Stretched Second** (Bullet Time renamed) | Style | A kill in slow motion that YOU started pays a share of its style, daring and melee rows. An automatic slow-mo (Score's own, Miniboss's, Gun Bonsai's, a reload) pays half that share. | Today's `RS_Bonus_BulletTime.AfterOthers`, with `trigger.auto`. | 50 % (25 % automatic) | rework |
| S2 | **Near-Freeze** | Style | The same, with the world at 10 % speed or slower: the share rises. | `scale <= 100`. Replaces S1's share. (Score's own hit-stop excluded: see stale #3.) | 75 % | new |
| S3 | **Opening Shot** | Style | The first kill within 1 s of starting slow motion yourself. | `trigger.auto` 0 and `level.maptime - trigger.tic <= 35`; once per slow-mo. | 0.25 | new |
| S4 | **Time Well Spent** | Efficiency | Three or more kills inside one slow motion you started. | Per-player count keyed on `trigger.tic`. | 0.15 per kill past 2 (to 0.6) | new |
| S5 | **Last Grain** | Style | A kill in the ease-out, as the world speeds back up. | `slowmo.active` 1 and `running` 0. | 0.2 | new |
| S6 | **Slip and Return** | Daring | Kill the monster within 2 s of leaning out of its slowed round or claw. | The claw dodge already sends `touch "lean"` on the monster (clock.zs RSQSM_ClawDodge). Proposed: the round's gate (`body.zs` the lean test) sends the same touch on `round.target`. Score: the victim's chain holds `lean` within 70 tics. | 0.4 | new |
| S7 | **Whiz Kid** | Daring | Kill the monster whose slowed round just cracked past your head. | `round.zs` already measures each round's closest pass and plays the crack; proposed: it sends `touch "whiz"` on the round's shooter. Score: chain holds `whiz` within 70 tics. | 0.35 | new |
| S8 | **Last Drag** | Style | A kill inside the slow-mo the cigarette started (smoking itself pays nothing). | `trigger.src == "smoke"`. Stacks with S1. | 0.3 | new |
| S9 | **Pick and Fire** | Style | Kill within 1 s of closing the Wheel with the weapon you picked on it. | `trigger.src == "wheel"` was the last slow-mo and the kill weapon changed during it (RS_PhysicalNotes keeps the last kill weapon; Wheel's own pick would be better: proposed `RSQWheel` answer `wheel.picktic`). | 0.3 | new |

**Reworks:** F.E.A.R. Effect (Melee's flat 200-point award) becomes a multiplier row, Style 0.5, and **F.E.A.R. Spree**
+0.15 per further shotgun kill in the same window (to 0.95); it then sits under the cap and S1 like any style row.
Thrall Slow Kill vs S1: see stale #4.

---

## 4. Tactical Rig: kill-tied only

Facts: `RSQTR_RigService` answers `rig.drawtic` and GetString `rig.drawn` per PLAYER (`hooks.zs`); `rig.region` only
for the local hand; `rig.holster`. The rig sets `drawTic`/`drawClass` on a main-hand draw, a swap and the grenade
spot (`rig.zs` 597, 1056, 1099). **Needed (proposed):** `rig.drawregion` (the holster index of the last draw) and a
hand argument on `rig.drawtic` / `rig.drawn`, so off-hand draws count.

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| T1 | **Quick Draw by region**: Hip Shot / **Cross Draw** / **Over the Shoulder** | Daring | Quick Draw's kill (inside 42 tics of the draw) pays by where the gun came from: a hip, the chest, a shoulder (the reach behind your head is the hardest). | `rig.drawregion` (0-1 hips, 6-7 chest, 4-5 shoulders, `RSQTR_Region.NAMES`). | 0.35 / 0.4 / 0.45 | rework of Quick Draw |
| T2 | **Off-Hand Draw** | Daring | Quick Draw for a gun the off hand drew. | `rig.drawtic` with hand 1, matched against `OffhandWeapon`. | 0.35 | rework (see stale #8) |
| T3 | **Twin Draw** | Style | Both hands draw within half a second and both guns kill within 2 s. | Two draw tics (hand 0 and 1) close together; Two Guns' hand reading on the kills. Paid on the second kill. | 0.5 | new |
| T4 | **Iaido** | Melee | Draw the saber from its spot and kill with it inside 42 tics. | A saber draw from a saber spot (regions 9-10) sets the draw tic today, so Quick Draw already pays it as a gun row; give it its own Melee row instead (replaces Quick Draw for a saber). | 0.45 | new |
| T5 | **Armory** | Daring | Three different guns, each drawn from a holster and each killing, inside 6 s. | Extends Hot Swap's notes (`lastKillWeapon`) to a list of 3. Replaces Hot Swap on the third. | 0.5 | new |
| T6 | **Throwaway** | Style | A gun you threw from the rig kills. +0.2 if it was empty when thrown (out of ammo, throw the gun). | Inflictor `is "Weapon"` with no Owner, damage type `'Melee'`, source you (rig.zs gun flight: `DamageMobj(g, thrower, dmg, 'Melee')`). Proposed: the rig always sends `touch "gun.throw"` (today only `gun.toss` with the Gun Bonsai Gun Toss node). Empty: rig answer `rig.thrownammo`. | 0.3 (+0.2) | new (also fixes stale #7) |
| T7 | **Homecoming** | Style | Kill with the gun inside 1 s of it flying back into your hand (Boomerang Gun level 2). | The rig sends `touch "boomerang.gun"` on the pawn when it arrives (`rig.zs` Arrive); Score notes the tic on the player; the kill's ReadyWeapon is that class. | 0.4 | new |
| T8 | **Pin Pulled** | Daring | The grenade drawn from the belt buckle kills within 3 s of the draw. | `rig.drawn` is the grenade class (`HandGrenades` or RSQ Grenade's), the kill's inflictor is a grenade. Today Quick Draw pays it only if it lands inside 42 tics, as a gun. | 0.3 (replaces Quick Draw) | new |
| T9 | **No Time to Reload** | Daring | Kill with a freshly drawn gun right after the gun you holstered ran dry. | Proposed rig answer `rig.putammo` (rounds left in the gun put away at the swap); 0 and the drawn gun kills inside 42 tics. | 0.3 | new |

Fast Hands (melee > rig.draw, 0.5) and Hot Swap stay as they are.

---

## 5. Named 2-tool and 3-tool combos (owner, 11-03: "of course we need to expand 2-tool combo and 3-tool combos")

Pattern steps are tool ids in order, the last the finishing blow (`combo.zs` THE TOOLS). Existing ids used: `gun`,
`rig.draw`, `saber.cut`, `saber.throw`, `force.push`, `force.pull`, `force.grip`, `shield.bash`, `shield.disc`,
`hook.bite`, `hook.yank`, `whip`, `grab.throw`, `grab.hold`, `kick`, `punch`, `glove`, `blade`, groups `hands`,
`melee`, `any`. Touches already sent but used by no combo today: `lean` (SlowMo claw dodge), `gun.toss` and
`boomerang.gun` (Tactical Rig), `zip.kick` (Grapple).

**Proposed new tool ids** (each needs one touch call in the named mod, or a classification in `combo.zs` Classify):
- `slow`: a virtual first step Score adds when the chain's first blow landed in a slow motion the player started
  (needs SlowMo's `trigger.auto`). It is not a pay for triggering: it only counts inside a kill's chain.
- `shove`: RSQ Melee's gun-butt shove (today it lands as plain damage `'Kick'`, so it is read as `kick`).
- `headlock.throw`: a monster thrown out of the Headlock (`headlock.zs` ThrowSwing; with Distance Grab loaded it is
  handed to `RSQDG_ThrowService "headlock.throw"` and may read as `grab.throw` today).
- `gun.throw`: a gun thrown from the rig (any throw, not only with Gun Toss).
- `rig.draw.hip`, `rig.draw.chest`, `rig.draw.shoulder`, `rig.draw.saber`: in the `rig.draw` group (needs `rig.drawregion`).
- A **victim filter** after a pattern: `| Bronze` = the victim carries that champion token (or `Legendary`,
  `Thrall`, `Miniboss`). A filtered combo replaces its unfiltered twin.

Pay rule kept from `combo.zs`: a named combo replaces the generic 2-Tool 0.2 / 3-Tool 0.4 for the tools it names.

| # | Name | Pattern | Pay | Meets |
|---|---|---|---|---|
| C1 | **Time Out** | `slow > grab.hold > headlock.throw` | 0.9 | SlowMo + Melee (the owner's example) |
| C2 | **Suplex** | `grab.hold > headlock.throw` | 0.5 | Melee |
| C3 | **Saloon Brawl** | `rig.draw > hands` | 0.5 | Rig + hands (quick draw, then a melee finish) |
| C4 | **High Noon** | `slow > rig.draw > gun` | 0.9 | SlowMo + Rig |
| C5 | **Iaido Cut** | `rig.draw.saber > saber.cut` | 0.5 | Rig + Saber |
| C6 | **Tuco** | `gun.throw > rig.draw` | 0.5 | Rig (throw the empty gun at it, draw another, finish) |
| C7 | **Homing Pigeon** | `gun.throw > boomerang.gun > gun` | 0.9 | Rig + Gun Bonsai VR's Boomerang Gun |
| C8 | **Swap Meet** | `rig.draw > rig.draw` (two different guns drawn, both hit it) | 0.5 | Rig |
| C9 | **Slip and Shoot** | `lean > gun` | 0.4 | SlowMo lean + gun |
| C10 | **Rope-a-Dope** | `lean > glove` (or `lean > punch`) | 0.5 | SlowMo lean + boxing gloves |
| C11 | **Bullet Ballet** | `slow > whip > gun` | 0.9 | SlowMo + Whip |
| C12 | **Shove and Cleave** | `shove > blade` | 0.5 | Melee shove + axe/chainsaw |
| C13 | **Riot Shield** | `shove > shield.bash` | 0.5 | Melee + ShieldSaw |
| C14 | **Drive-By** | `zip.kick > gun` | 0.5 | Grapple zip kick + gun |
| C15 | **Express Delivery** | `hook.bite > zip.kick` | 0.5 | Grapple |
| C16 | **Crack the Shell** | `shield.bash > blade \| Bronze` (also Gold, Titan) | 0.6 | ShieldSaw + blade on an armoured champion (the "bash then saw" example: Bronze takes half damage and never flinches) |
| C17 | **Title Belt** | `grab.hold > hands \| champion` | 0.6 | Melee Headlock on a champion (replaces Headlock 0.5; Bronze cannot be held: infinite Mass) |
| C18 | **Hot Potato** | `grab.hold > headlock.throw \| Orange` | 0.7 | Melee: throw an Orange champion into the crowd and let it blow |
| C19 | **Short Leash** | `hook.bite > any \| Green` | 0.6 | Grapple on a teleporting champion |
| C20 | **Against the Wind** | `hook.yank > melee \| Cyan` | 0.6 | Grapple drags a Cyan through its own wind to your fist |
| C21 | **Opposites Attract** | `force.pull > saber.cut \| Silver` | 0.6 | Saber: pull the magnet, cut it on arrival |
| C22 | **Kite String** | `hook.bite > any \| Balloon` | 0.6 | Grapple reels in a balloon |
| C23 | **Matador's Cape** | `whip > saber.cut \| Grey` | 0.6 | Whip + Saber on a lunging Grey |
| C24 | **Crack of Doom** | `whip > any \| Legendary` (killed before it rose: Legend Denied) | 0.6 | Whip denies a legend (the owner's example) |
| C25 | **Rising Uppercut** | `force.push > glove \| Legendary` (killed within 2 s of its rise) | 0.7 | Saber Force + gloves on a fresh legendary |
| C26 | **Throne Toss** | `grab.hold > headlock.throw \| Thrall` | 0.6 | Melee: a thrall thrown to its death |
| C27 | **Kingslayer** | `slow > any > any \| Miniboss` | 0.9 | SlowMo + any two tools finish the miniboss |
| C28 | **Exorcism** | `force.grip > saber.cut \| Ghost` | 0.6 | Saber: hold a Ghost while it is solid and cut it |
| C29 | **Curb Stomp** (chain form of row 10) | `gun > kick` with the kick landing on a Dark Red's corpse | 0.5 | Gun + Brutal Doom boots |
| C30 | **Draw, Shove, Fire** | `rig.draw > shove > gun` | 0.9 | Rig + Melee shove + gun |

**Cross-area combo rows** (not chains, but the same meeting point):
- **Champion Fatality**: Brutal Doom's Fatality (MK_FINISH) on an active champion: +0.25 on top of Fatality.
- **Slow Riposte**: a Perfect Riposte inside the slow-mo its own parry started (`trigger.src` `saber.parry` /
  `shieldsaw.block`): +0.2.
- **Thrown Thrall**: a thrall killed by a Distance Grab throw or a Headlock throw inside the slow window: Thrown /
  Hurled pays, plus Chain Gang counts it.

---

## 6. Stale or wrong rows found

| # | Row / text | What is wrong now | Where |
|---|---|---|---|
| 1 | **Bullet Time** (name) | To be renamed (owner); proposals in section 3. `Score/BONUS_IDEAS.md` still lists Bullet Time under "Considered and rejected", though it is built. | `physical.zs` RS_Bonus_BulletTime; `BONUS_IDEAS.md` |
| 2 | **Bullet Time pays automatic slow motion the same as the player's** | Since `bae904e9f` SlowMo tells deliberate from automatic triggers, but Score cannot ask which one is running. A Miniboss window, a Gun Bonsai pulse, Reload Slowdown and Close-Call all pay the full 50 %. | `hook.zs` RS_Grapple.SlowNow; SlowMo `clock.zs` RSQSM_Service |
| 3 | **Hit-stop slow motion pays Bullet Time** | Score's own hit-stop pulse (115 ms + ramp, 5 %) never sets `tr.slowmoUntil`, so a kill inside it is "in slow motion" and pays Bullet Time on a slow-mo Score made itself. | `handler.zs` BigMomentPulse (only the big-moment branch sets `slowmoUntil`) |
| 4 | **Bullet Time blanked when SlowMo refused Score's pulse** | `slowmoUntil` is set when Score SENDS its pulse, even when SlowMo refuses it (its 25 s automatic cooldown, the Score row off, or "not needed: slow motion is held on"). With the player's own slow-mo held on, every big moment blanks Bullet Time for about 41 tics. | `handler.zs` BigMomentPulse; `clock.zs` Trigger |
| 5 | **Score's Slow Motion Cooldown (6 s) is now mostly dead** | SlowMo's own Auto Slow-Mo Cooldown (25 s after an automatic pulse ENDS) refuses Score's pulses long before Score's 6 s matters. The README test "Another one inside 6 s does not" is still true but misleading. Also README: "Bullet Time needs SlowMo's slowmo.active answer (RSQ_SlowMo branch agent-suite)" names a branch that is long merged. | `Score/README.md` Features, Test it 14, The suite |
| 6 | **Miniboss awards are flat points** | Thrall Slow Kill 100, Miniboss 500, Greedy 1000 are the same on an imp and a Cyberdemon, sit outside the per-kill cap and outside Bullet Time; the champion rows on the same bodies scale. README calls them "Daring rows". | `Miniboss/zscript/rsqmb/handler.zs` Death / BossDied; `awards.zs` |
| 7 | **A gun thrown from the rig reads as a punch** | The rig's gun hits with `DamageMobj(gun, thrower, dmg, 'Melee')` (`rig.zs` flight). `RS_Melee.KindOf` excludes only Distance Grab throws, the hook and the whip, so a rig gun throw is MK_FIST: Brawler 0.5, and Knockdown / Counter can fire, and the chain sees `punch`. (By code reading; measure.) | `melee.zs` KindOf |
| 8 | **Quick Draw and Hot Swap miss off-hand draws** | Since 11-02 each hand draws its own gun, but `rig.drawtic` / `rig.drawn` are per player and only main-hand draws set them; Quick Draw compares with `ReadyWeapon`. An off-hand draw-and-kill never pays. | `physical.zs`; `TacticalRig/zscript/rsqtr/hooks.zs` |
| 9 | **Quick Draw pays a saber and a grenade as a gun draw** | The saber spot and the belt buckle set the same draw tic, so a saber cut or a grenade kill inside 42 tics pays Quick Draw (Daring) and the chain names it `rig.draw` (a "shot"). Proposed own rows: Iaido (T4), Pin Pulled (T8). | `rig.zs` 597, 1099; `combo.zs` Classify |
| 10 | **Dark Red Champion's kill loses its killing blow** | Its real death is `A_Die()` from the controller after the `champion_ShootableCorpse` is shot: no source, no inflictor. Score falls back to `victim.target` (often the player, so base and the colour row may still pay), but every row that reads the blow (melee, No-Look, the chain...) sees nothing, and an infight or a stray shot on the corpse can be paid to the wrong player. (By code reading; measure.) | `boost.zs`; `handler.zs` WorldThingDied |
| 11 | **A champion near a Gold champion is paid as Gold and as Hybrid** | Midas Touch gives `champion_GoldToken` to any nearby monster that lacks one, including other champions. A Red champion so gilded holds two colour tokens: the champion group pays Gold 0.75 instead of Red 0.25, and Hybrid (two colour tokens) pays 0.25 though it never rolled a Hybrid. (By code reading; measure.) | `boost.zs` ColourTokens, RS_Bonus_MutHybrid |
| 12 | **The "reflecting champion" does not exist** | `champion_SilverReflection` is never given in mk-champions 20210309; any design note or row name that assumes a reflector is wrong for this build. | Champions `champ_silver.txt` |
| 13 | **Undying and Ghost tokens are never given** | `champion_UndyingToken` and `champion_GhostToken` exist in Champions' `tokens.txt` but `baseclass.txt` never gives them. Score correctly reads the heart's death and VISIBILITYPULSE instead; a later edit must not "simplify" to the tokens. | `boost.zs` (correct; keep) |
| 14 | **F.E.A.R. Effect is a flat 200 award, not a Style row** | README calls it a Style row; it is a flat award (`shove.zs` FEAR_POINTS 200): outside the cap, outside Bullet Time, the same on any monster. | `Melee/zscript/rsqml/shove.zs`; `Score/README.md` Works with |
| 15 | **The gun-butt shove reads as a boot** | RSQ Melee's shove lands as plain `'Kick'` damage (BD22's KickAttack numbers), so a shove kill pays Boot 0.2 and enters the chain as `kick` (so shove > gun is Gun Kata). Fine as a fallback, but it cannot be named in a combo. Proposed `shove` tool. | `melee.zs` KindOf; `shove.zs` |
| 16 | **Touches nobody reads** | SlowMo's claw dodge sends `touch "lean"`, the rig `gun.toss` and `boomerang.gun`, Grapple `zip.kick`. They count toward generic N-Tool combos only; no named combo or row uses them. A lean is a dodge, not a blow: today `lean > gun` pays the 2-Tool Combo 0.2. Combos C9, C10, C7, C14, C15 give them meaning. | `combo.zs` |
| 17 | **Thrall Slow Kill and Bullet Time double up** | A thrall killed in Miniboss's window gets the flat 100 for the slow window AND Bullet Time's share for the same slow motion (an automatic one). With S1's automatic half share and M1 replacing the flat award, the window pays once, by the base. | `awards.zs`; `physical.zs` |

## The ten strongest

1. **Stay Down** (Dark Red corpse) + its credit fix.
2. **Matador** (kill a Grey mid-lunge; Champions marks the lunge with a token for 20 tics).
3. **Time Out** (slow > headlock > throw).
4. **Chain Gang** (thralls in one window, rising pay, as base multipliers).
5. **Strike While It Rises / Rude Awakening** (kill a legendary in the 2 s after it rises; more if a dormant champion just woke).
6. **Pack Leader / Divide and Conquer** (Titan's toughness is literally the crowd around it).
7. **Stretched Second** with the deliberate/automatic split and Near-Freeze (fixes three slow-mo bugs at once).
8. **Fireworks / Demolition** (kills by a Blue's or Orange's death power, credited to the player who set it off).
9. **Crack the Shell** (bash then blade an armoured champion) and the victim-filter extension for combos.
10. **Throwaway** (thrown rig gun kills, +0.2 if empty) + the punch misread fix.
