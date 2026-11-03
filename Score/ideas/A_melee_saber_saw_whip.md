# Score ideas, lane A: Melee, Saber, ShieldSaw, Whip

Proposals only. Nothing here is built or approved. The owner names things, so every name is a proposal. Read from
the code on `main` (2026-11-03): `Score/zscript/rsscore/*`, `Melee/zscript/rsqml/*`, `QuestSaber/zscript.txt`,
`ShieldSaw/zscript/ssq/*`, `Whip/zscript/rsqwp/*`, `GunBonsaiOffhandVR/rsq/zscript/up_*.zs` and `GBOVR_TREES.md`.

## Summary

| Section | Count |
|---|---|
| Melee ideas (fists, guard, shove, headlock, Fists tree) | 34 |
| Saber ideas (cuts, stab, throw, deflect, Force) | 20 |
| ShieldSaw ideas (bash, slam, grind, disc, block, dash) | 17 |
| Whip ideas (crack, wrap, flail, yank, lasso, rope) | 17 |
| Shared across the four (one move in several mods = one idea) | 16 |
| **Ideas in all** | **104** |
| **Named chains (section 6, the major section)** | **204** |
| - two tools inside lane A | 99 |
| - three tools inside lane A | 29 |
| - four tools (one rule) | 1 |
| - with other lanes' tools (guns by class, grenade, hook, grab, rig, slow motion): two tools 58, three tools 17 | 75 |
| Proposal for the generic 2-/3-/4-tool pay (by actions, breadth, tempo) | section 6.5 |
| New tool ids the ledger needs | 40, plus an `@slow` step suffix; 4 new groups, 3 widened |
| Existing Score items that are stale or wrong now | 22 |

**The one thing to fix before adding any of this (stale item S1):** every upgrade hook the mods send through
`RS_ScoreService "touch"` (`hit.heavy`, `punch.uppercut`, `crit`, `stab.lunge`, `cleave.saw`, `crack`...) is entered
in the combo ledger as a *new tool* on the same blow. One body uppercut with Heavy Hands learned is recorded as
`glove > hit.heavy > hit.body > punch.uppercut`: a **4-Tool Combo (0.6) and a slow-motion big moment from a single
punch**. These hooks need to be *tags on the blow*, not tools (proposal in S1). Most ideas below read those tags.

**How to read the tables.**
- *Family*: Efficiency, Style, Daring or Melee (Score's four). No new family is needed. One option for the owner:
  a fifth family, **Counterplay**, for defence turned into a kill (Riposte, Perfect Riposte, Return to Sender,
  Poetic Justice, Rally, and the parry/return ideas here). It would give defensive play its own colour and cap.
- *Pay*: a multiplier of the kill's base (the monster's spawn health), the same scale as today: 0.1 to 0.5 for
  something you can do often, 0.5 to 1.0 for something rare, more only for the very rare. The per-kill cap
  (3x base) still holds over everything.
- *Detection*: **Exists** = the fact can be read today. **Needs** = one small answer or tag the owning mod must add
  (the name of the request is proposed).
- *Status*: **new**, or **rework** of an existing row (named).
- Every idea pays only on a **kill**. Utility (holstering, drawing, reloading, picking up, climbing) pays nothing by
  itself.

---

## 1. Melee (RSQ Melee + the Fists tree of Gun Bonsai VR)

What exists today for these moves: Brawler (0.5, Daring), Counter, Knockdown, Flurry, Juggle, Boot, Heavy Swing,
Combo, the `Headlock` combo (`grab.hold > hands`, 0.5) and the F.E.A.R. Effect award. A punch is dealt by
`RSQ_Glove` itself (`gloves.zs` Deliver, `victim.DamageMobj(g, pmo, dmg, 'Melee')`, line 949), so `ev.inflictor` is
the glove and `RSQML_Service "punch.*"` can be asked about it at the kill.

| # | Name (proposal) | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| M1 | **Shoryuken** | Melee | An uppercut kills it. | Exists: `RSQML_Service "punch.kind"` = 2, objectArg `ev.inflictor` (service.zs). Score's README lists this as "not built, no row reads it yet". | 0.3 | new |
| M2 | **Knockout** | Melee | A full-power punch kills it. | Exists: `"punch.power"` (GetDouble) >= 0.9 on the glove. | 0.2; 0.3 at 1.0 | new |
| M3 | **Liver Shot** | Melee | A punch landed below the chest kills it. | Exists: `"punch.body"` = 1. | 0.2 | new |
| M4 | **Glass Jaw** | Melee | A punch to the head (top fifth of the body) kills it. | Exists: `"punch.height"` >= 800 permille (Melee measures it for every glove hit, upgrade or not). | 0.25 | new |
| M5 | **Textbook** | Melee | The kill is the hook of a jab, jab, hook landed inside one second. | Exists: `"punch.kinds"` ends in `112`. | 0.35 | new |
| M6 | **Triple Threat** | Melee | The kill is the uppercut of jab, hook, uppercut inside one second. Replaces M1 and M5. | Exists: `"punch.kinds"` = `123`. | 0.5, big moment | new |
| M7 | **Dempsey Roll** | Melee | The kill ends a run of alternating hooks (each within 0.6 s). | Exists: `"punch.run"` (this hook included). | 0.15 per hook past 2, to 0.6 | new |
| M8 | **Air Combo** | Melee | A punch kills a monster your uppercut launched, while it is still in the air. +0.15 per earlier punch that landed on it in the air. Replaces Juggle. | Exists: `"launch.age"` (objectArg victim, intArg player) >= 0; count of `juggle` tags on the victim's chain since the launch. | 0.3 + 0.15 each, to 0.9; big moment at 0.75 | new (supersedes Juggle for punches) |
| M9 | **Aerial Raid** | Daring | Both of you are in the air: you (jumping, Force jump, dismount) punch to death a monster you launched. | Exists: `"launch.age"` >= 0 and the killer off its floor (`killer.pos.z > floorz + 2`). | 0.4 | new |
| M10 | **Meteor** | Melee | A launched monster lands on another (the Meteor node) and the fall kills either one. Both deaths pay. | Exists: tag `meteor` on the victim this tic (launch.zs:85). Needs: the blow's inflictor to be a Meteor helper or the tag read at the kill (today it reads as a punch, S7). | 0.4 | new |
| M11 | **Ground Pound** (shared name) | Melee | Melee's two-fist shockwave kills it. +0.1 per other monster the same pound killed. | Exists: tag `pound` (twohand.zs:141). See the shared X1 for the Saber's landing, which already uses this name. | 0.3 + 0.1 each, to 0.7 | rework of Ground Pound (X1) |
| M12 | **Bouncer** | Melee | The Clear Out palm thrust kills it (or Ring Out pays if it went into a pit). | Exists: tag `clearout` (twohand.zs:186). | 0.3 | new |
| M13 | **Splattered** | Melee | A monster you punched into a wall dies of the wall. One idea with the ShieldSaw's wall slam: see X2. | Needs: Melee's splat.zs:75 to send the `splat` tag GBOVR_TREES lists (it does not today). | see X2 | new (X2) |
| M14 | **Parry Punish** (becomes the chain A19) | Melee | You parried its blow with the Guard, then killed it within 3 s; within 1 s pays more. | Exists: tag `parry` on the attacker (guard.zs:198), a ledger entry with its tic. | 0.5; 0.7 inside 1 s (big moment) | new |
| M15 | **Release** | Melee | The Guard's stored charge, let out (Absorb and Release), kills it. +0.15 per other kill of the same release. | Exists: tag `guard.release` (guard.zs:274), the blow lands on the same tic. | 0.4 + 0.15 each, to 0.85 | new |
| M16 | **Iron Guard** | Daring | A kill landed within 2 s after the Guard soaked a blow of 20 or more from in front. | Exists: tag `guard` on the attacker (guard.zs:244). Needs: the soaked amount (`RSQML_Service "guard.soaked"`, pawn) to keep chip blows out. | 0.3 | new |
| M17 | **Hadouken!** | Melee | A fireball you punched back kills (its shooter or anything). Replaces Return to Sender's 0.4 for that kill. | Exists: the returned missile is a monster's (`RS_ScoreShots.BornOfMonster`), tag `hadouken` on the shooter (gloves.zs:645). Needs: Melee to answer `"returned.by"` for a missile it sent back (0 Hadouken, 1 Swat Back, 2 Reflect Guard), so the kill can be told apart from a saber or shield return. | 0.6 (stacks with Poetic Justice) | new |
| M18 | **Backhand** | Melee | A fireball your open palm swatted back (Swat Back) kills. Replaces Return to Sender. | Needs: `"returned.by"` = 1 (above); tag `swat.back` exists (gloves.zs:797). | 0.6 | new |
| M19 | **Mirror Guard** | Melee | A shot the raised Guard reflected kills. Replaces Return to Sender. Includes level 3's reflected bullet (today it reads as your own gun, S16). | Needs: `"returned.by"` = 2; for the bullet, tag `guard.reflect` (guard.zs:215) read at the kill. | 0.5 | new |
| M20 | **Human Shield** | Daring | You kill something (any tool) while your off hand holds a monster in the Headlock; 0.6 if the held monster took a shot meant for you in the last 2 s. | Needs: `RSQML_Service "headlock.held"` (objectArg pawn -> the held monster); tag `shield.human` exists (guard.zs:354). | 0.4; 0.6 | new |
| M21 | **Friendly Fire** | Daring | The monster in your Headlock is killed by another monster's attack. You get the kill (as Ring Out gives it). | Exists: `"headlock.holding"` = 1 on the victim at death, killer a monster. Handler change: give the kill to the holder like `RS_ScoreShots.LaunchedBy`. | 0.6, big moment | new |
| M22 | **Beatdown** | Melee | The Headlock combo's kill came after 3+ punches landed in the same hold. Rides on the existing Headlock combo. | Exists: the run of `glove` entries after `grab.hold` on the victim's chain. | +0.1 per punch past 2, to 0.4 | rework of combo Headlock |
| M23 | **Toss** | Melee | A monster you threw out of the Headlock dies, or kills what it hits; both dying pays Two for One (+0.3). | Exists: `RSQML_Tossed` / `RSQML_ThrownInto` on the body (headlock.zs:555, 602), its blows 'Melee' from the body (headlock.zs:593). Fixes S8 (read as a punch today). | 0.35; +0.3 both | new |
| M24 | **Piledriver** | Melee | The Headlock Slam (held monster driven into the floor) kills it or what stands there. | Exists: tag `slam` (headlock.zs:480). | 0.5, big moment | new |
| M25 | **Sleeper Hold** | Melee | The Chokehold kills it. One idea with the Force choke: see X3. | Exists: tag `choke` (headlock.zs:274). | see X3 | rework of Choked (X3) |
| M26 | **Cut Loose** | Melee | A Headlock Uppercut (launch out of the hold) kills it, now or on landing. | Exists: tag `headlock.launch` (gloves.zs:959). | 0.4 | new |
| M27 | **Butt Stroke** | Melee | The gun-butt shove itself kills it (Melee's shove, or BD22 VR's butt strike that it reads). Replaces Boot for that kill. | Exists: 'Kick' with the pawn as inflictor and a gun as ReadyWeapon (shove.zs:315); BD22 VR's strike: Melee reads it landing (shove.zs:511). Needs: a `shove` tag so Score tells it from a BD boot (S9). | 0.3 | new |
| M28 | **No Mercy** | Daring | A kill on a monster that is knocked down (Rifle Butt or the Knockdown count). | Exists: tag `butt.knockdown` (shove.zs:495). Needs: GBOVR to tag its Knockdown count (`knockdown`, listed in GBOVR_TREES 4.1, not sent today). | 0.3 | new |
| M29 | **Come Get Some** | Daring | The doubled punch after a Taunt kills a monster the Taunt turned on you, inside its window. | Exists: tag `taunt` on each monster turned (twohand.zs:111), its tic in the ledger. | 0.4 | new |
| M30 | **Rip and Tear** | Efficiency | A run of fist kills with no other weapon's kill between, each within 10 s. | Exists: kills by `RSQ_Glove`; a counter on the tracker. (The fist case of the shared streak X10; listed here because the fists are the heart of it.) | 0.1 per kill past 2, to 0.5 | new (X10) |
| M31 | **K.O.** | Melee | GBOVR's Finisher (the last hit of a 3+ chain on a staggered, low monster) kills. | Exists: GBOVR up_fists.zs:391 sends `finisher`, but that collides with Score's BD fatality tool (S5). Needs: renamed `fist.finisher`. | 0.5, big moment | new |
| M32 | **Shatter** | Melee | A frozen monster (Frost Fist) is shattered to death by a punch. | Exists: tag `shatter` (up_fists.zs:203). | 0.4 | new |
| M33 | **Live Wire** | Melee | Shock Fist's arc kills a monster you did not punch. +0.15 per further arc kill of that punch. | Exists: tag `arc` on each arced monster (up_fists.zs:263). | 0.3 + 0.15, to 0.6 | new |
| M34 | **Blast Radius** | Melee | Explosive Fist's blast kills a monster other than the one punched. +0.15 per extra. | Exists: tag `fist.explosive` (up_fists.zs:177). Needs: the tag on each blasted monster (today on the punched target only). | 0.25 + 0.15, to 0.7 | new |

Not proposed (utility or no fact): the cigarette, Slappers Only as a mode (Brawler already pays every glove kill),
Star Punch (no longer offered), Catch and Bullet Time Fists (parked).

---

## 2. Saber (RSQ Saber + the Saber tree)

What exists: Twin Blades, Pulled In, Choked, Slammed, Ground Pound (the Force jump landing), Juggle, Riposte /
Perfect Riposte (the saber's `"blocked"` / `"perfect"`), Return to Sender, Poetic Justice, Rally, Hurled and Boomerang
for the throw, Cleaved, the Deflect and Remote Down awards. A cut is dealt with the saber weapon as inflictor
(`UBQS_Saber` or `UBQS_SaberOff`, 'Saber', zscript.txt ~2116), so **which hand cut** is already a fact.

| # | Name (proposal) | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| S-1 | **Run Through** | Melee | A stab (thrust along the blade) kills it. | Needs: a `saber.stab` tag on every stab (zscript.txt ~2116, where `stab` is known); today only the Point Taken upgrade tags `stab.lunge`. | 0.25 | new |
| S-2 | **Lunge** | Daring | A stab driven by your whole body (head moving forward at 0.8 m/s) kills it. Replaces S-1. | Exists: tag `stab.lunge` (zscript.txt:2105), Point Taken learned. | 0.4 | new |
| S-3 | **Skewered** | Melee | You draw the blade out of an impaled monster and it dies of it (Run Through's finish). | Exists: tag `impale` (zscript.txt:2122) then the finishing 'Saber' blow of `mo.health + 1` (zscript.txt:2216). Needs: a `saber.unskewer` tag at that line to be exact. | 0.5, big moment | new |
| S-4 | **High Ground** | Melee | A cut on a low monster takes it apart (the High Ground node). Replaces Cleaved for that kill. | Exists: tag `sever` (GBOVR up_saber.zs:183). | 0.4 | new (supersedes Cleaved) |
| S-5 | **Ataru** | Melee | The kill ends a run of cuts alternating main blade and off blade, each within half a second. | Exists: inflictor class `UBQS_Saber` vs `UBQS_SaberOff` per cut; a per-player run like Flurry's (`RS_ScoreShots.NoteGlove`). | 0.15 per cut past 2, to 0.45 | new |
| S-6 | **Saberstaff** | Melee | The staff's back blade or its spin kills it; +0.15 per other monster the same spin killed. | Exists: tag `staff.spin` (GBOVR 4.2). Needs: a tag on the back-blade and twirl cuts (zscript.txt ~2265 deals them as plain 'Saber'). | 0.3 + 0.15, to 0.75 | new |
| S-7 | **Double Throw** | Style | Both sabers are thrown and each kills, within one second of each other. | Exists: two `UBQS_Thrown` inflictors, told apart by their `master` weapon (main / off). | 0.4 on the second kill | new |
| S-8 | **Shish Kebab** | Style | One bolt the saber sent back kills two or more (Piercing Return). | Exists: the same `UBQS_Bolt` inflictor killing again (the pattern `Hurled` uses, `tracker.hurlBy`). | 0.3 per extra kill, to 0.9 | new |
| S-9 | **Disarmed** | Melee | You kill a monster your Force Pull already disarmed (Force Pull 3+). | Needs: `UBQS_SaberService "disarmed"` (the saber keeps the list already, zscript.txt ~6754). | 0.3 | new |
| S-10 | **Mass Choke** | Melee | A Force choke kills one of two or more monsters held at once (Force Grip 3+). | Exists: `"gripped"` = 1 on another monster in reach at the kill; 'Force' with DMG_NO_PAIN (zscript.txt:5548). | +0.2 per other held, to 0.6, on top of Choked | new |
| S-11 | **Unlimited Power** | Melee | Force Lightning kills it; +0.15 per other target of the same bolt that died. | Needs: a `force.lightning` tag on each struck monster (today only on the first, zscript.txt:5433); its blows are 'Saber' from UBQS_Force and read as a Force push (S13). | 0.35 + 0.15, to 0.8 | new |
| S-12 | **Shockwave** | Melee | One Force push (or its all-round shockwave, Force Push 3+) kills two or more. | Exists: several 'Saber' kills from UBQS_Force on one tic, same player. | 0.2 per extra kill, to 0.6 | new |
| S-13 | **Back Off** | Melee | The X of your two blades (Cross Guard) turned a shot that kills. Replaces Return to Sender's 0.4. | Exists: tag `crossguard` on the source (zscript.txt:2954). Needs: the turned missile marked so the kill knows the X turned it. | 0.5 | new |
| S-14 | **Clash Break** | Melee | A monster staggered by your blade-lock shockwave (Clash) is killed within 3 s. | Exists: tag `clash` (zscript.txt:2989). | 0.35 | new |
| S-15 | **Remote Kill** | Daring | Your thrown saber kills a monster you could not see when you let go. One idea with the disc: see X8. | see X8 | see X8 | new (X8) |
| S-16 | **Second Pass** | Melee | Returning Blade's second pass over the marks kills a monster the first pass did not. | Exists: tag `boomerang` (GBOVR 4.2 lists it). Needs: the tag sent at the second pass. | 0.35 | new |
| S-17 | **Parry Riposte (saber)** | Melee | A saber parry (blade moving into the shot) then the parried monster killed within 3 s. Today it shares Perfect Riposte with the shield. | Exists: `"perfect"` (zscript.txt:2672). Proposal: keep Perfect Riposte, add the tool `saber.parry` to the ledger so combos can name it. | 0.7 (existing) | rework (ledger only) |
| S-18 | **Deflection Volley** | Melee | Rally, but every return in the run came off the blade with your hand MOVING into the shot (parries). | Exists: `"perfect"` on each shooter in the run. | +0.2 on top of Rally | new |
| S-19 | **Saber Over Shield** | Melee | The lit blade resting on the shield parries a shot that kills (Spartan 1), or the bash cuts and kills (Spartan 2). | Exists: tag `spartan` (ShieldSaw guard.zs:460, 817). | 0.4 | new |
| S-20 | **Force Speed Duel** | Daring | A saber kill inside Force Speed's slow motion, of a monster that was attacking you. Bullet Time already multiplies style; this pays the duel. | Exists: tag `force.speed` (zscript.txt:5394; on the player) and `RS_Melee.InAttack` / `RS_ScoreShots.FiredWithin`. | 0.3 | new |

---

## 3. ShieldSaw (RSQ ShieldSaw + the ShieldSaw tree)

What exists: Shield Work (bash 0.3, grind 0.2), Hurled, Boomerang, Ground Down, Clean Sweep, Bank Shot, Shield Wall,
Riposte / Perfect Riposte, Return to Sender, Poetic Justice. Bash and wall slam land as 'Melee' with the pawn as
inflictor (guard.zs:806/819, state.zs:1517); the grind 'Saw' from the pawn (guard.zs:1082); the disc 'Saw' from
`SSQ_Disc` (disc.zs:574, 584, 600).

| # | Name (proposal) | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| D1 | **Wall Slam** | Melee | A monster you bashed into a wall dies of the wall. One idea with Melee's Wall Splat: see X2. | Needs: `SSQ_ScoreService "slammed"` (tics since a wall slam on that monster). Today only the Wall Slam upgrade tags `slam.saw` (state.zs:1509). | see X2 | new (X2) |
| D2 | **Shield Dash** | Daring | The bash at the end of a Shield Dash kills it. | Exists: tag `dash.bash` from `Wedge` (guard.zs ~957). | 0.4 | new |
| D3 | **Stampede** | Melee | One Charge (a bash while moving forward) kills two or more in its wedge. | Exists: tag `charge` on each (guard.zs:883 -> Wedge). | 0.2 per kill past the first, to 0.6 | new |
| D4 | **Bit Off More** | Daring | A monster clawing your revving shield (Rev Shield) is ground to death on it. | Exists: tag `rev.block` (guard.zs:288), its 'Saw' blow next line. | 0.5 | new |
| D5 | **Homecoming** | Melee | The disc kills on its way home without having killed on the way out (a recall, Hunter's Return, Buzzsaw Return). Boomerang replaces it when there was an out-kill. | Exists: `"thrown.leg"` = 1 (score.zs); tag `buzz.return` (disc.zs:532). | 0.3 | new |
| D6 | **Trick Shot** | Style | The disc kills after bouncing off walls; more per bounce. Bank Shot pays the Ricochet's new lock; this pays the bounces. | Needs: `SSQ_ScoreService "disc.bounces"` (the disc counts them for Wall Bounces already). | 0.2 per bounce, to 0.6 | new |
| D7 | **Perfect Return** | Melee | A shot turned by a PERFECT block kills. On top of Return to Sender. | Needs: the shield to mark which turned shots came off a perfect block (`SSQ_ScoreMemory.Turned` takes a flag). | +0.2 | new |
| D8 | **Eyes in the Back** | Daring | The shield on your back (Back Plate) blocked that monster's attack, then you killed it within 3 s. | Exists: tag `backplate` (guard.zs:379). | 0.5 | new |
| D9 | **Hold the Line** | Melee | Shield Wall, but the shield turned away blows from 2 or more different monsters in the last 2 s. | Exists: `"blocked"` on each monster in reach (Shield Wall already walks them). | 0.25 + 0.1 per extra monster, to 0.55 | rework of Shield Wall |
| D10 | **Buzzsaw** | Melee | A grind kill on something that took at least 1.5 s of grinding in the hand. | Needs: the grind start tic per body (`grindWho` / `grindWhen`, guard.zs ~1065) answered as `"grind.held"`. | 0.3 (replaces the grind's 0.2) | rework of Shield Work |
| D11 | **Disc Interrupt** | Melee | The thrown disc kills a monster in the middle of its attack. Part of the shared X7 (Counter for every melee). | see X7 | see X7 | rework (X7) |
| D12 | **Cleaver** | Melee | The disc cut it in two only because of the Cleaver node (it was over the base tier). Stacks on Cleaved. | Exists: tag `cleave.saw` (disc.zs:573, 583). | +0.2 | new |
| D13 | **Shield Bash Reflect** | Melee | A bullet the muzzle block sent back kills its shooter at point blank (under 2 m). | Exists: `"returned"` / `"returned.from"` and `ev.edgeDistance`. | +0.2 on Poetic Justice | new |
| D14 | **Guardian Angel** | Daring | You kill a monster while the shield blocked 3 or more of its shots in the last 3 s (it was pouring fire into you). | Needs: a block count per source (`SSQ_ScoreMemory.Blocked` keeps one tic per source today). | 0.4 | new |
| D15 | **Battering Ram** | Melee | A bashed body thrown into another kills it (GBOVR's Battering Ram). Part of the shared Bowling, X4. | Exists: tag `ram` (GBOVR, guard.zs:865 asks it). | see X4 | rework (X4) |
| D16 | **Round Trip** | Melee | The disc killed a lock, came home, was caught, and the very next throw killed the next lock within 3 s. | Exists: two `SSQ_Disc` inflictors; the disc's catch. Needs: `"disc.caught"` tic. | 0.3 | new |
| D17 | **Clean Sweep (both throws)** | Melee | Today's Clean Sweep, extended to the saber's throw: every marked lock dead. See X9. | see X9 | 0.5 (existing) | rework (X9) |

---

## 4. Whip (RSQ Whip, the coiled MIT-model whip, and its tree)

**Today Score cannot see this whip at all.** Its blows are damage type `'Whip'` (whip.zs:1979; it used to be
'Melee'), and Score's whip facts read RSQ Grapple's old whip (`RSQGR_Service "whipped"`, 'Melee'). So a crack kill
pays no Lashed, and the combo ledger files it as **`gun`** (S2). Facts that exist in the Whip code: the crack
(`RSQWP_Perks.Hurt(v, pmo, pmo, dmg, 'Whip')`, whip.zs:2709), the flail smash (`Hurt(hit, v, pmo, ...)`, the swung
monster as inflictor, whip.zs:2141), the swung monster's own hurt (`Hurt(v, null, pmo, ...)`, :2148), Tarzan
(core.zs:360), the wrap (`BeginWrap`, :1990), the yank (`Yank`, :1919, no damage), the lasso and Bola touches
(:2011, :2047), Crack Shot and Return Crack (:2805, :2834). `RSQWP_Events.Whipped(v, pmo)` (fx.zs:66) is an empty stub
called before every whip blow: the natural place to note blows for Score.

| # | Name (proposal) | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| W1 | **Bullwhip** (was Lashed) | Melee | A crack kills it. A heavy crack (top half of the speed range, the Heavy sound) pays more. | Exists: 'Whip' with the pawn as inflictor. Needs: `RSQWP_Service "crack.k"` (0..1, the `hk` of whip.zs:2702) for the heavy/light split. | 0.2 light, 0.35 heavy | rework of Lashed (S2) |
| W2 | **Wrecking Ball** | Melee | The monster you swing on the whip (flail) smashes into another and kills it. | Exists: 'Whip' with a monster as inflictor (whip.zs:2141). Needs: `"flailing"` (pawn -> the wrapped monster), because with Gun Bonsai VR the inflictor becomes the pawn (fx.zs:57). | 0.4 | new |
| W3 | **Two Birds** | Melee | One flail smash kills both the monster you swing and the one it hits. | Exists: the two kills on one tic (whip.zs:2141 and :2148). | +0.3 on the second | new |
| W4 | **Yanked In** | Melee | A monster your whip yanked to you dies to a melee blow within 2 s of the yank. Paid per finisher by the named chains (Get Over Here! A86, Reel and Deal A87, Meat Hook A88, Yank and Bank A89, Into the Blades A90), not folded into Reeled In. | Needs: `RSQWP_Service "yanked"` (tics since yanked, `Yank`, whip.zs:1919), noted in the ledger as `whip.yank`. | 0.5-0.6 (the chains) | new (combos) |
| W5 | **Grand Entrance** | Daring | The yank pulled YOU to a heavy monster (or a boss), and you killed it within 2 s of arriving. | Needs: `"yank.self"` (the heavy branch of `Yank`, whip.zs ~1952). | 0.5 | new |
| W6 | **Lassoed** | Melee | A lassoed monster is killed within 3 s of the lasso landing; from 6 m or more, +0.2. | Exists: tag `lasso` (whip.zs:2011). Needs: the throw distance (`"lasso.dist"`). | 0.3; +0.2 far | new |
| W7 | **Roundup** | Melee | Every monster one Bola tied up is dead within 3 s of each other. | Exists: tag `bola` on each tied monster (whip.zs:2047). | 0.5 on the last, big moment | new |
| W8 | **Crack Shot** | Style | A monster's missile your crack blew up in the air kills a monster with its blast. | Needs: the blown missile marked (`"whip.shot"` by inflictor); today `crack.shot` is tagged on the shooter only (whip.zs:2805). | 0.35 | new |
| W9 | **Cracked Back** | Melee | A missile your crack sent back at its shooter kills. Replaces Return to Sender (harder than a block). | Exists: the missile is a monster's (`BornOfMonster`), tag `crack.return` (whip.zs:2834). | 0.55 | new |
| W10 | **Tarzan** | Daring | You swing in on the rope and your arrival kills the monster. Replaces Swinging. | Exists: tag `tarzan` (core.zs:362) and the 'Whip' blow (core.zs:360). | 0.5, big moment | new |
| W11 | **Rope Fighter** | Daring | Swinging and Dismount, for the whip's own rope: a kill while the whip's rope holds you off the ground, or after you let go and before you land. | Needs: `RSQWP_Service "swinging"` / `"airborne"` (the whip carries its own fork of Grapple's line code, but answers nothing). | 0.35 / 0.4 (existing pays) | rework of Swinging, Dismount (S17) |
| W12 | **Stun Lock** | Melee | A crack held the monster in pain (Stun) and a different tool killed it before it recovered. | Exists: tag `crack.stun` (whip.zs:2730). | 0.3 | new |
| W13 | **Pull and Punch** | Melee | A yanked monster arrives staggered and your fist kills it as a counter (the Pull and Punch node). | Exists: tag `pull.punch` (whip.zs:1948) then a glove kill. Named chain Get Over Here! (A86) pays it; listed here as the Whip's half. | see A86 | new (combo) |
| W14 | **Heavy Haul** | Daring | You yanked a heavy monster off its feet (over the base light mass: Heavy Yank) and it died within 2 s of landing. | Exists: tag `yank.heavy` (whip.zs:1944). | 0.35 | new |
| W15 | **Snap Kill** | Melee | A crack finishes a monster you marked from across the room (the marked crack that flies to it), from 6 m or more. | Needs: `"crack.marked"` (the crack flew to a mark) and the distance at the crack. | 0.3 | new |
| W16 | **Ringmaster** | Style | Three different monsters each killed by a different whip move (crack, flail, lasso/yank) inside 10 s. | Exists once W1, W2, W6 exist: their kinds on the tracker. | 0.5 on the third | new |
| W17 | **Fly Ball (whip)** | Style | A monster your yank lifted is killed in the air on its way to you. One idea with the hook's Fly Ball: see X6. | Needs: `"yanked"` (W4). | see X6 | rework (X6) |

---

## 5. Shared across the four (one move in several mods is one idea)

| # | Name (proposal) | Family | Trigger | Mods and detection | Pay | Status |
|---|---|---|---|---|---|---|
| X1 | **Ground Pound** | Melee | A ground shockwave of yours kills: the Saber's Force jump landing, or Melee's two-fist pound. | Saber: today's test (LandSlam, zscript.txt:5617). Melee: tag `pound`. One row, so the name is not used twice. | 0.3 + 0.1 per extra kill, to 0.7 | rework of Ground Pound |
| X2 | **Wall Splat** | Melee | A monster you knocked into a wall dies of the wall: a punch (Wall Splat / Wallflower) or a shield bash (Wall Slam). Stacks with a Gun Bonsai slam row if any. | Melee: tag `splat` (needs adding, splat.zs:75). ShieldSaw: `"slammed"` (needs adding, state.zs Slam). | 0.4; big moment when the wall hit kills a monster of 400+ base | new |
| X3 | **Choked** | Melee | A choke kills: the Force grip, or Melee's Chokehold in the Headlock. | Saber: today's test ('Force', DMG_NO_PAIN). Melee: tag `choke`. | 0.3 (existing) | rework of Choked |
| X4 | **Bowling** | Style | A body you threw kills what it hits (or both die): the hook's yank (today), the Force fling, the Headlock toss, the bash's Battering Ram, the whip's flail, a Meteor. | Grapple: today. Saber: needs `"flung.by"` on the slam body. Melee: `RSQML_Tossed` / `ThrownInto`, tag `meteor`. ShieldSaw: tag `ram`. Whip: W2. | 0.5 + 0.25 per later pin, to 1.25 (existing) | rework of Bowling |
| X5 | **Reeled In** | Melee | A monster pulled to you dies to a melee blow within 2 s: the hook (today) and the Force pull (Pulled In, today). The whip's yank is left out on purpose and paid by its own named chains (6.0, W4), so each pairing can pay differently. Only change: Reeled In's chain bonus (+0.15 per Reeled In inside 4 s) also counts whip-yank kills in the run. | Whip: needs `"yanked"`. | 0.3 + 0.15 chain (existing) | rework of Reeled In (chain count only) |
| X6 | **Fly Ball** | Style | Killed in the air while something of yours was throwing it: the hook (today), the whip's yank (W17), the Force fling. | Whip / Saber: as X4 / X5. | 0.35 (existing) | rework of Fly Ball |
| X7 | **Counter** (all melee) | Melee | Any melee blow kills a monster in its attack: punch (today), cut, stab, bash, grind, crack, disc. Fists read the glove's own wind-up flag. | Fists: `"punch.counter"` (better than the state sniff, S10). Others: `RS_Melee.InAttack` / `RS_ScoreShots.FiredWithin` (exists). | 0.3 (existing) | rework of Counter |
| X8 | **Blind Throw** | Daring | A thrown weapon (saber, disc, lasso) kills a monster you could not see when it left your hand. | The physical family's Blind-fire notes the head at the fire tic (`RS_PhysicalNotes`); the same check at the spawn of `UBQS_Thrown` / `SSQ_Disc` (`RS_ScoreShots.WorldThingSpawned`). | 0.4 | new |
| X9 | **Clean Sweep** | Melee | A throw at 2+ marks kills the last of them, all dead: the disc (today) and the saber. | Saber: its marks are `UBQS_LockMark` with `tracer` (zscript.txt:4531), the same shape as `SSQ_LockMark`. | 0.5 (existing) | rework of Clean Sweep |
| X10 | **Weapon Master** | Efficiency | A run of kills with the same melee mod (fists, saber, ShieldSaw or whip), nothing else killing between, each within 10 s. M30 is the fists' case. | The melee kind of each kill (S2's fix gives the whip one). | 0.1 per kill past 2, to 0.5 | new |
| X11 | **Giant Slayer** | Daring | A melee kill (any of the four) on a monster of 400+ base (Baron and up); 1.0 at 2000+ (a Cyberdemon). | `ev.basePoints` and the melee kind. | 0.5; 1.0 | new |
| X12 | **Multi-Kill** | Melee | One swing, crack, bash, grind or palm thrust kills two or more on the same tic. | Same player, same melee kind, same tic (the backlog's "Chain", for melee). | 0.25 per extra, to 0.75 | new |
| X13 | **Death from Above** | Daring | A melee kill dropping onto it: you are at least 1 m above its head and falling (Force jump, dismount, a ledge). | `killer.vel.z < 0` and `killer.pos.z - (victim.pos.z + victim.height) >= 32`. | 0.4 | new |
| X14 | **Juggler** | Style | A kill with one hand while your other weapon is still in flight: the saber or the disc thrown, the other hand punching, cutting or shooting. | `RS_ScoreShots.thrown` holds a live `UBQS_Thrown` / `SSQ_Disc` of this player whose leg is not this kill's inflictor. | 0.25 | new |
| X15 | **Misdirection** | Melee | A shot you sent back kills a monster that did NOT fire it: a saber deflect, a shield turn, a swat aside, a crack knocking it away. (Poetic Justice is the shooter's own death.) | `RS_ScoreShots.BornOf(inflictor)` != victim; shield `"returned.from"`. | +0.25 on Return to Sender | new |
| X16 | **No Guns** (end-of-map award) | Melee | At the map's end, 75% or more of your kills on it were by the four melee mods; 100% pays double. A fighting award, not a utility one. | The kill kinds on the tracker; paid as an award row like Indiana Jones. | 20% of the map target; 40% at 100% | new |

---

## 6. Named combos for the ledger (the major section)

The ledger (`RS_ComboSeed.Combos`, combo.zs) pays the chain of tools on one monster: order kept, 3 s break, the
last step is the killing blow, earlier steps may have other tools between them. Every row below is a proposal in
that format: **opener > follow-up > finisher**. The owner names; the names are only so the rows can be talked about.

### 6.0 Rules these rows assume

- **Groups in patterns:** `glove` = any punch (`glove.jab`, `glove.hook`, `glove.upper`); `saber` = any blade blow
  (`saber.cut`, `saber.stab`, `saber.throw`, `saber.spin`); `return` = any sent-back shot (6.6); `gun` = any gun;
  `gun.<class>` = one class (lane D's ids: `gun.pistol`, `gun.shotgun`, `gun.rifle`, `gun.explosive`, `gun.energy`,
  `gun.fire`). Lane D writes the uppercut as `punch.upper`; it is the same tool as `glove.upper` here (one spelling
  to be picked).
- **The finisher must deal the killing blow.** Moves that deal no damage (`whip.yank`, `whip.wrap`, `grab.hold`,
  `force.pull`, `taunt`) appear as openers or middles only.
- **Rows that are already combos keep their tools.** Riposte / Perfect Riposte cover a block (`shield.block`,
  `saber.block`, and now `saber.parry`) plus the finisher; Pulled In covers `force.pull > melee`; Reeled In covers
  `hook > melee`. So no 2-tool row here opens with those; a 3-tool row may, because its middle tool is new (today's
  rule: a table combo must name a tool those rows do not cover).
- **The whip yank is NOT folded into Reeled In** (this replaces X5's proposal for the whip): the yank's finishers are
  named rows below (Get Over Here!, Reel and Deal...), so each pairing can pay its own.
- **Parry Punish (M14) becomes a table row** (`parry > any`, 0.5); the named parry pairs pay more and win.
- **Slow motion as a step suffix, `@slow`:** the step landed while RSQ_SlowMo had the world slowed (Score already
  asks `slowmo.active` per kill; the ledger would keep it per entry). SlowMo is not a tool: it modifies a step. Used
  sparingly (6.5) because Bullet Time already multiplies style.
- **Pays:** 2-tool 0.4 to 0.6, 3-tool 0.9 to 1.0, 4-tool 1.2 (today's 2-tool rows are 0.4-0.5, 3-tool 0.9). The
  best-paying match wins; a named row replaces the generic pay for the tools it names (today's subtraction rule).
  Every named 3-tool row is a big moment (as today).

### 6.1 Two-tool chains inside lane A (99)

**Fists open**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A1 | Rising Dragon | `glove.upper > saber.cut` | 0.5 |
| A2 | Skyskewer | `glove.upper > saber.stab` | 0.55 |
| A3 | Up and Away | `glove.upper > saber.throw` | 0.5 |
| A4 | Spike | `glove.upper > shield.disc` | 0.5 |
| A5 | Batter Up | `glove.upper > shield.bash` | 0.5 |
| A6 | Air Lash | `glove.upper > whip.crack` | 0.5 |
| A7 | Launch Pad | `glove.upper > force.push` | 0.45 |
| A8 | Hang Up | `glove.upper > force.grip` | 0.5 |
| A9 | Cross Cut | `glove.hook > saber.cut` | 0.4 |
| A10 | Feint | `glove.jab > saber.stab` | 0.45 |
| A11 | Fist and Shield | `glove > shield.bash` | 0.4 |
| A12 | Knuckle Crack | `glove > whip.crack` | 0.4 |
| A13 | Jedi Jab | `glove > force.push` | 0.4 |
| A14 | Punch and Pitch | `glove > shield.disc` | 0.4 |

**The gun-butt shove opens**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A15 | Make Room | `shove > saber.cut` | 0.4 |
| A16 | Backlash | `shove > whip.crack` | 0.4 |
| A17 | Clearance | `shove > shield.disc` | 0.4 |
| A18 | Get Back | `shove > force.push` | 0.4 |

**The Guard opens** (parry, reflect, release)

| # | Name | Pattern | Pay |
|---|---|---|---|
| A19 | Parry Punish | `parry > any` (was row M14) | 0.5 |
| A20 | Knuckle Sandwich | `parry > glove` | 0.55 |
| A21 | Counter Cut | `parry > saber` | 0.6 |
| A22 | Turn the Tables | `parry > shield.bash` | 0.55 |
| A23 | Recoil | `parry > whip.crack` | 0.55 |
| A24 | Bounce Back | `guard.reflect > glove.upper` | 0.5 |
| A25 | Pressure Valve | `guard.release > glove` | 0.5 |

**The Taunt opens**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A26 | Bait and Blade | `taunt > saber` | 0.5 |
| A27 | Bait and Bash | `taunt > shield.bash` | 0.5 |
| A28 | Bait and Lash | `taunt > whip.crack` | 0.5 |

**The Headlock opens** (hold, slam, toss)

| # | Name | Pattern | Pay |
|---|---|---|---|
| A29 | Execution | `grab.hold > saber` | 0.5 |
| A30 | Bulldog | `grab.hold > shield.bash` | 0.5 |
| A31 | Flog | `grab.hold > whip.crack` | 0.5 |
| A32 | Send-Off | `grab.hold > force.push` | 0.5 |
| A33 | Ground and Pound | `slam > glove` | 0.5 |
| A34 | Pin Down | `slam > saber.stab` | 0.55 |
| A35 | Skeet Disc | `headlock.toss > shield.disc` | 0.5 |
| A36 | Fetch | `headlock.toss > whip.crack` | 0.5 |
| A37 | Target Practice | `headlock.toss > saber.throw` | 0.5 |

(The Headlock combo `grab.hold > hands` stays as it is, 0.5.)

**Two-hand moves open**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A38 | Crowd Control | `clearout > whip.crack` | 0.45 |
| A39 | Spread and Shred | `clearout > shield.disc` | 0.45 |
| A40 | Aftershock | `pound > saber.cut` | 0.45 |
| A41 | Quake | `pound > shield.bash` | 0.4 |

**Returned shots open**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A42 | Street Fighter | `hadouken > glove.upper` | 0.6 |
| A43 | Shoto | `hadouken > saber.cut` | 0.5 |
| A44 | Tennis | `return > return` (two different return tools) | 0.5 |

**The saber and the Force open**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A45 | Pommel | `saber.cut > glove` | 0.4 |
| A46 | Edge and Board | `saber.cut > shield.bash` | 0.4 |
| A47 | Cut and Lash | `saber.cut > whip.crack` | 0.4 |
| A48 | Off the Blade | `saber.stab > force.push` | 0.5 |
| A49 | Stab and Jab | `saber.stab > glove` | 0.4 |
| A50 | Distraction | `saber.throw > glove` | 0.5 |
| A51 | Covering Throw | `saber.throw > shield.bash` | 0.5 |
| A52 | Throw and Go | `saber.throw > saber.cut` | 0.4 |
| A53 | Air Traffic | `saber.throw > shield.disc` | 0.5 |
| A54 | Shove and Snap | `force.push > whip.crack` | 0.4 |
| A55 | Clay Saber | `force.push > saber.throw` | 0.5 |
| A56 | Helpless | `force.grip > saber.cut` | 0.5 |
| A57 | Sitting Target | `force.grip > saber.throw` | 0.5 |
| A58 | Pinned | `force.grip > shield.disc` | 0.5 |
| A59 | Strung Up | `force.grip > whip.crack` | 0.5 |
| A60 | Hung Out to Dry | `force.grip > glove` | 0.5 |
| A61 | Sith Ambush | `force.lightning > saber.cut` | 0.5 |
| A62 | Shock and Awe | `force.lightning > glove` | 0.5 |
| A63 | Leap Strike | `force.jump > saber.cut` | 0.5 |
| A64 | Superhero Landing | `force.jump > glove` | 0.5 |

**The ShieldSaw opens**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A65 | Shield and Fist | `shield.bash > glove` | 0.4 |
| A66 | Bash and Slash | `shield.bash > saber.cut` | 0.5 |
| A67 | Hoplite | `shield.bash > saber.stab` | 0.55 |
| A68 | Bash and Lash | `shield.bash > whip.crack` | 0.4 |
| A69 | Follow-Through | `shield.disc > glove` | 0.4 |
| A70 | Saw and Saber | `shield.disc > saber.cut` | 0.5 |
| A71 | Cleanup Crack | `shield.disc > whip.crack` | 0.4 |
| A72 | Throw and Follow | `shield.disc > shield.bash` | 0.4 |
| A73 | Crossfire | `shield.disc > saber.throw` | 0.5 |
| A74 | Blitz | `shield.dash > glove.upper` | 0.5 |
| A75 | Spartan Charge | `shield.dash > saber` | 0.5 |
| A76 | Up Against the Wall | `shield.slam > glove` | 0.5 |
| A77 | Nailed | `shield.slam > saber.stab` | 0.55 |
| A78 | Breakthrough | `shield.charge > saber.cut` | 0.5 |

(Lion Tamer `whip > shield.bash` and Disc Jockey `force.push > shield.disc` stay as they are.)

**The whip opens**

| # | Name | Pattern | Pay |
|---|---|---|---|
| A79 | Crack and Smack | `whip.crack > glove` | 0.4 |
| A80 | Zorro | `whip.crack > saber` | 0.5 |
| A81 | Big Top | `whip.crack > shield.disc` | 0.5 |
| A82 | Tied Up | `whip.wrap > saber.cut` | 0.5 |
| A83 | On a Leash | `whip.wrap > glove` | 0.5 |
| A84 | Tethered | `whip.wrap > shield.disc` | 0.5 |
| A85 | Strangler | `whip.wrap > force.grip` | 0.5 |
| A86 | **Get Over Here!** | `whip.yank > glove` (Pull and Punch's stagger makes it a counter too) | 0.6 |
| A87 | Reel and Deal | `whip.yank > saber.cut` | 0.5 |
| A88 | Meat Hook | `whip.yank > saber.stab` | 0.55 |
| A89 | Yank and Bank | `whip.yank > shield.bash` | 0.5 |
| A90 | Into the Blades | `whip.yank > shield.grind` | 0.55 |
| A91 | Rope-a-Dope | `whip.lasso > glove` | 0.5 |
| A92 | Hogtie | `whip.lasso > saber.cut` | 0.5 |
| A93 | Roped and Diced | `whip.lasso > shield.disc` | 0.5 |
| A94 | Bound | `whip.lasso > force.grip` | 0.5 |
| A95 | Tetherball | `whip.flail > glove` | 0.5 |
| A96 | Batting Practice | `whip.flail > shield.disc` | 0.5 |
| A97 | Swashbuckler | `whip.tarzan > saber.cut` | 0.6 |
| A98 | Jungle Law | `whip.tarzan > glove` | 0.5 |
| A99 | Cannonball | `whip.tarzan > shield.bash` | 0.5 |

### 6.2 Three-tool chains inside lane A (29)

| # | Name | Pattern (opener > follow-up > finisher) | Pay |
|---|---|---|---|
| T1 | **Ringside** | `whip.yank > grab.hold > glove` (yank it in, headlock it, punch it) | 0.9 |
| T2 | This Is Sparta | `shield.block > shield.bash > saber` (block, bash, cut) | 0.9 |
| T3 | Sky Combo | `glove.upper > whip.crack > saber.cut` (launch, crack, cut in the air) | 0.9 |
| T4 | Bounty Hunter | `whip.lasso > force.pull > saber.cut` | 0.9 |
| T5 | Vibranium | `shield.disc > shield.dash > glove` (throw, dash in, punch) | 0.9 |
| T6 | Force Arrest | `force.pull > grab.hold > glove` | 0.9 |
| T7 | Matador | `taunt > shield.block > saber.stab` (call it, take its charge, run it through) | 0.9 |
| T8 | Hot Potato | `return > return > return` (three different return tools) | 1.0 |
| T9 | Pinball | `shield.bash > whip.yank > shield.bash` (bash away, yank back, bash again) | 0.9 |
| T10 | Paddleball | `shove > whip.yank > glove` | 0.9 |
| T11 | Dragon Fist | `parry > glove.upper > glove` (parry, launch, finish in the air) | 0.9 |
| T12 | Iron Maiden | `grab.hold > slam > shield.bash` (headlock, piledrive, bash it while it is down) | 0.9 |
| T13 | Freight Train | `shield.dash > glove.upper > saber.cut` | 0.9 |
| T14 | Puppeteer | `whip.wrap > force.grip > saber.cut` | 0.9 |
| T15 | Whirlwind | `whip.flail > force.push > shield.disc` | 0.9 |
| T16 | Gladiator | `whip.lasso > shield.bash > saber.stab` (net, shield, spear) | 0.9 |
| T17 | Jedi Brawler | `force.grip > glove > saber.cut` | 0.9 |
| T18 | Wrecking Crew | `whip.flail > shield.bash > glove` | 0.9 |
| T19 | Catch and Release | `headlock.toss > whip.yank > glove` (throw it away, yank it back, punch) | 0.9 |
| T20 | Lightning Round | `force.lightning > whip.crack > glove` | 0.9 |
| T21 | Three-Point Landing | `force.jump > shield.bash > saber.cut` | 0.9 |
| T22 | Launch Sequence | `glove.upper > force.grip > saber.throw` | 0.9 |
| T23 | **Super Combo** | `hadouken > glove.upper > saber.cut` | 1.0 |
| T24 | Snare | `parry > whip.wrap > saber.stab` | 0.9 |
| T25 | Lure | `taunt > whip.lasso > glove` | 0.9 |
| T26 | Full Contact | `shove > glove.upper > shield.bash` | 0.9 |
| T27 | Saber Dance | `saber.throw > whip.yank > saber.cut` | 0.9 |
| T28 | Rubber Band | `force.push > whip.yank > glove` (push it away, yank it back, punch) | 0.9 |
| T29 | Juggle Act | `glove.upper > shield.disc > whip.crack` | 0.9 |

### 6.3 Four tools

| # | Name | Pattern | Pay |
|---|---|---|---|
| Q1 | **Grand Master** | one tool from each of `fists`, `saber`, `shieldsaw`, `whip`, any order. One rule, not 24 rows: a chain whose actions cover all four groups. | 1.2, replaces the generic, big moment |

### 6.4 Chains with the other lanes' tools (75)

Their ids are the other lanes' (`hook.*` and `grab.*` Grapple / Distance Grab; the grenade's existing touch ids
`freeze.nade`, `stun.nade`, `flash`, `smoke`, `fire.nade` registered in group `grenade` as lane B proposes;
`gun.<class>` as lane D proposes; `rig.draw` today's).

**Two tools: lane A opens, a gun finishes**

| # | Name | Pattern | Pay |
|---|---|---|---|
| G1 | Trap Shooter | `glove.upper > gun.shotgun` | 0.5 |
| G2 | Pop Fly | `glove.upper > gun.rifle` | 0.45 |
| G3 | Pistol Juggle | `glove.upper > gun.pistol` | 0.5 |
| G4 | Fireworks | `glove.upper > gun.explosive` | 0.5 |
| G5 | Hostage | `grab.hold > gun.pistol` | 0.5 |
| G6 | Close Quarters | `grab.hold > gun.shotgun` | 0.5 |
| G7 | Pistol Whip | `shove > gun.pistol` | 0.5 |
| G8 | Breach | `shove > gun.shotgun` | 0.5 |
| G9 | Butt and Burst | `shove > gun.rifle` | 0.45 |
| G10 | Duelist | `parry > gun.pistol` | 0.55 |
| G11 | Come Closer | `taunt > gun.shotgun` | 0.5 |
| G12 | Frontier | `whip.crack > gun.pistol` | 0.5 |
| G13 | Rodeo | `whip.lasso > gun` | 0.45 |
| G14 | Closer | `whip.yank > gun.shotgun` | 0.5 |
| G15 | Gift Wrapped | `whip.wrap > gun.explosive` | 0.5 |
| G16 | Swing Shot | `whip.tarzan > gun.shotgun` | 0.5 |
| G17 | Overcharge | `force.lightning > gun.energy` | 0.5 |
| G18 | Covering Fire | `saber.throw > gun.rifle` | 0.45 |
| G19 | Blade and Buckshot | `saber.cut > gun.shotgun` | 0.45 |
| G20 | Riot Control | `shield.bash > gun.shotgun` | 0.5 |
| G21 | Door Kicker | `shield.dash > gun.shotgun` | 0.5 |
| G22 | Tremor | `pound > gun.shotgun` | 0.45 |
| G23 | Spread Out | `clearout > gun.explosive` | 0.45 |
| G24 | Clay Toss | `headlock.toss > gun.shotgun` | 0.5 |

(Clay Pigeon, Sitting Duck, Pull! and Gun Kata stay as the any-gun rows; a class row pays more and wins.)

**Two tools: a gun opens, lane A finishes** (soften it up, finish it by hand)

| # | Name | Pattern | Pay |
|---|---|---|---|
| G25 | Buckshot Brawl | `gun.shotgun > glove` | 0.4 |
| G26 | Clean Up | `gun.shotgun > saber.cut` | 0.4 |
| G27 | Suppress and Storm | `gun.rifle > shield.bash` | 0.45 |
| G28 | Rocket Punch | `gun.explosive > glove` | 0.5 |
| G29 | Shoot and Snap | `gun.pistol > whip.crack` | 0.4 |
| G30 | Hot Hands | `gun.fire > glove` | 0.5 |
| G31 | Fire Whip | `gun.fire > whip.crack` | 0.45 |
| G32 | Plasma Blade | `gun.energy > saber.cut` | 0.45 |

**Two tools: the Tactical Rig, the hook, Distance Grab**

| # | Name | Pattern | Pay |
|---|---|---|---|
| G33 | High Noon | `whip.crack > rig.draw` | 0.6 |
| G34 | Hostage Draw | `grab.hold > rig.draw` | 0.6 |
| G35 | Slingshot | `force.push > hook.yank` (the yank's landing kills) | 0.5 |
| G36 | Spring Back | `shield.bash > hook.yank` | 0.45 |
| G37 | Catch This | `grab.throw > glove` | 0.45 |
| G38 | Serve and Volley | `grab.throw > shield.bash` | 0.45 |
| G39 | Toss and Crack | `grab.throw > whip.crack` | 0.45 |
| G40 | Two Throws | `grab.throw > shield.disc` | 0.45 |
| G41 | Alley-Oop | `glove.upper > grab.throw` | 0.5 |

(Fast Hands `melee > rig.draw`, Lasso `whip > hook.yank`, Pitch and Slice `grab.throw > saber.cut` stay.)

**Two tools: the grenade**

| # | Name | Pattern | Pay |
|---|---|---|---|
| G42 | Dazed and Confused | `stun.nade > glove` | 0.5 |
| G43 | Ice Breaker | `freeze.nade > glove` | 0.55 |
| G44 | Cold Shoulder | `freeze.nade > shield.bash` | 0.5 |
| G45 | Cold Cut | `freeze.nade > saber.cut` | 0.5 |
| G46 | Blind Side | `flash > saber` | 0.5 |
| G47 | Ninja | `smoke > saber.stab` | 0.55 |
| G48 | Hot Lash | `fire.nade > whip.crack` | 0.45 |
| G49 | Shell Shock | `grenade > glove` | 0.45 |
| G50 | Frag and Slash | `grenade > saber.cut` | 0.45 |
| G51 | Air Mail | `glove.upper > grenade` | 0.5 |
| G52 | Hold This | `grab.hold > grenade` (you hold it while your grenade goes off on it) | 0.6 |
| G53 | Special Delivery | `force.grip > grenade` | 0.5 |
| G54 | Package Deal | `whip.wrap > grenade` | 0.5 |
| G55 | Fire in the Hole | `shove > grenade` | 0.45 |

**Two tools with slow motion** (few on purpose: Bullet Time already multiplies style)

| # | Name | Pattern | Pay |
|---|---|---|---|
| G56 | F.E.A.R. Effect | `shove > gun.shotgun@slow` (today's award, moved into the ledger) | 0.6 |
| G57 | Neo | `hadouken@slow > glove` (punch a slowed fireball back, then the shooter) | 0.6 |
| G58 | Time Slash | `force.push@slow > saber.cut` | 0.5 |

**Three tools across lanes**

| # | Name | Pattern | Pay |
|---|---|---|---|
| G59 | Wrestlemania | `hook.yank > grab.hold > glove` (the hook's Ringside) | 0.9 |
| G60 | Hook, Line and Sinker | `hook.yank > shield.bash > saber.cut` | 0.9 |
| G61 | Suplex City | `hook.yank > grab.hold > headlock.toss` | 0.9 |
| G62 | Ice Age | `freeze.nade > whip.crack > glove` | 0.9 |
| G63 | Deep Freeze | `freeze.nade > glove.upper > gun.rifle` | 0.9 |
| G64 | Smoke and Mirrors | `smoke > shield.dash > saber.stab` | 0.9 |
| G65 | Breach and Clear | `flash > shield.dash > gun.shotgun` | 0.9 |
| G66 | Hot Package | `grab.hold > headlock.toss > grenade` | 0.9 |
| G67 | Big Game Hunter | `whip.lasso > grenade > gun.rifle` | 0.9 |
| G68 | Skeet Champion | `glove.upper > whip.crack > gun.shotgun` | 0.9 |
| G69 | Saloon Brawl | `whip.lasso > glove > gun.pistol` | 0.9 |
| G70 | Gunsmoke | `whip.crack > shove > gun.pistol` | 0.9 |
| G71 | **High Noon Showdown** | `taunt > whip.crack > rig.draw` | 1.0 |
| G72 | Riot Squad | `shield.block > shield.bash > gun.shotgun` | 0.9 |
| G73 | Scoundrel | `force.push > saber.throw > gun.pistol` | 0.9 |
| G74 | Plasma Knight | `gun.energy > shield.bash > saber.cut` | 0.9 |
| G75 | Demolition Derby | `grab.throw > glove.upper > gun.explosive` | 0.9 |

**One slow-motion rule (not a row):** **Matrix**: a 3-tool chain whose every step landed in one slow-motion
window pays +0.3 (Style) on top of the combo.

### 6.5 How the generic 2-, 3- and 4-tool pay should scale

Today: 2 tools 0.2, 3 tools 0.4, 4 or more 0.6, flat; a named row replaces the generic for the tools it names.
With dozens of tools in the series, a five-tool chain pays the same as a four, and four guns' classes would count
like four mods. Proposed:

| Part | Proposal |
|---|---|
| **By distinct actions** | 2: 0.2, 3: 0.45, 4: 0.75, 5: 1.0, 6 or more: 1.2. Each extra tool is harder than the last, so the step grows. The per-kill cap (3x) still holds. |
| **What counts as one action** | Every gun class is still the one action `gun` for the generic count (the owner's rule; Switcharoo pays varying guns); named rows may name classes. Every `glove.*` is `glove`; every `whip.*` but the yank is `whip` (the yank counts as its own, like the hook's bite + yank today counts as one). Upgrade tags never count (S1). |
| **Breadth (new)** | +0.1 for each different *mod* in the chain past two (groups `fists`, `saber`, `shieldsaw`, `whip`, `hook`, `grab`, `grenade`, `gun`, `rig`), to +0.4. Four tools from four mods beat four tools from two. |
| **Tempo (new)** | The whole chain, first move to kill, inside 2 s: the generic part x1.25. A slow chain (gaps near the 3 s break) is unchanged. |
| **Named rows** | 2-tool 0.4-0.6, 3-tool 0.9-1.0, 4-tool 1.2. They replace the generic for their tools; tools past them still pay as generic (today's subtraction: Lion Tamer in a 3-tool chain = Lion Tamer + 3-Tool minus 2-Tool). |
| **Big moments** | Any named 3-tool row, a generic 5+, or breadth of 4+ mods. |
| **Repeats** | The same tool again with nothing between is one run (today). A named pattern may repeat a tool with another between (Pinball `shield.bash > whip.yank > shield.bash`); `RS_Combo.Match` already allows it. |

Worked example: `whip.yank > grab.hold > glove` = Ringside 0.9. The same chain with a saber cut finishing and a shotgun
blast between (`whip.yank > grab.hold > gun > saber.cut`): no named row, 4 actions 0.75 + breadth (fists, whip,
gun, saber: 4 mods) +0.2 = 0.95, x1.25 if inside 2 s.

### 6.6 Tool ids the ledger needs

Existing ids stay (`saber.cut`, `saber.throw`, `saber.return`, `saber.block`, `force.push`, `force.pull`,
`force.grip`, `shield.bash`, `shield.disc`, `shield.block`, `grab.hold`, `glove`, `punch`, `kick`, `blade`,
`finisher`, `whip`...).

| Mod | New tool ids | Where the fact is |
|---|---|---|
| Melee | `glove.jab`, `glove.hook`, `glove.upper` (refine `glove` by `punch.kind` at the blow); `shove` (split from `kick`); `parry`; `guard.release`; `hadouken`, `swat` (split from `saber.return`); `guard.reflect`; `headlock.toss`; `slam`; `pound`; `clearout`; `taunt`; `splat` | service.zs, gloves.zs:645/797/949, guard.zs:198/215/274, headlock.zs:480/593, twohand.zs:111/141/186, shove.zs:315 |
| Saber | `saber.stab`; `saber.parry` (the `"perfect"` memory); `saber.spin`; `saber.crossguard`; `saber.clash`; `force.lightning` (split from `force.push`); `force.slam` (the fling, split from `force.grip`); `force.jump` (the landing, split from `force.grip`) | zscript.txt ~2116, 2265, 2954, 2989, 5303, 5475, 5617 |
| ShieldSaw | `shield.grind` (split from `shield.bash`); `shield.slam`; `shield.charge`; `shield.dash`; `shield.perfect` | guard.zs:883/957/1082, state.zs Slam |
| Whip | `whip.crack`, `whip.flail`, `whip.wrap`, `whip.yank`, `whip.lasso`, `whip.bola`, `whip.shot`, `whip.return`, `whip.tarzan` | whip.zs:1990/2011/2047/2141/2709/2805/2834, core.zs:360 |
| Step suffix | `@slow` on any step | Score asks RSQ_SlowMo `slowmo.active` when the ledger records the entry |

New groups (`RegisterTool(id, groups)`): **`fists`** (every `glove.*`, `shove`, `pound`, `clearout`, `slam`,
`headlock.toss`, `splat`, `hadouken`, `swat`, `parry`, `guard.*`, `taunt`), **`shieldsaw`** (every `shield.*`),
**`return`** (`saber.return`, `shield.block` by a turned shot, `hadouken`, `swat`, `guard.reflect`, `whip.return`),
**`throw`** (`saber.throw`, `shield.disc`, `whip.lasso`, `headlock.toss`, `grab.throw`). Existing groups to widen:
`whip` (prefix, already works once the ids are `whip.*`), `hands` (today an exact list of `kick`, `punch`, `glove`;
it must accept `glove.*`), `melee` (`RS_Tool.IsMelee` must know the new ids).

---

## 7. Stale or wrong now

| # | Item | What is wrong | Proposed fix |
|---|---|---|---|
| S1 | **The combo ledger counts upgrade hooks as tools** | `RS_ScoreService "touch"` appends any id as a new run (awards.zs, combo.zs `Touch`). Melee sends `hit.heavy`, `hit.body`, `punch.uppercut`, `juggle` right after the punch's blow (gloves.zs:984-987); GBOVR sends `crit`, `headshot`, `backstab`, `combo.3`, `combo.dempsey`, `finisher`, `fist.explosive`, `shatter`, `arc`, `burn`, `bloodrush`, `berserk.earned`, `lucky`; the saber `stab.lunge`, `impale`, `barrage`, `force.speed` (on the player himself), `return.sender`; the ShieldSaw `cleave.saw`, `spartan`, `buzz.return`, `rev.block`, `charge`, `dash.bash`, `slam.saw`, `reflect.saw`, `backplate`; the Whip `crack`, `crack.stun`, `pull.punch`, `yank.heavy`, ... One body uppercut with Heavy Hands = a 4-Tool Combo (0.6) plus a slow-motion big moment, and Variety / melee Combo stand down. | Register these ids as **tags** (a group `tag` via `RegisterTool`): the ledger stores them on the current run instead of opening a new one, `Tools()` skips them, and bonuses read them. Only real moves become tools (6.6). |
| S2 | **Lashed, and the whip tool, are blind to RSQ Whip** | Lashed (`hook.zs`) and `MK_WHIP` (`melee.zs` KindOf) need `'Melee'` plus `RSQGR_Service "whipped"`: RSQ Grapple's old whip. RSQ Whip deals `'Whip'` (whip.zs:1979). Its crack is `MK_NONE`, and `RS_Tool.Classify` falls through to **`gun`**. So Lion Tamer, Lasso and Circus Act cannot fire with RSQ Whip, and crack-then-shot is one `gun` run. | Classify `'Whip'` (pawn inflictor: crack; monster inflictor: flail) as `whip.*`; a new `RS_Svc.WHIP` entry for `RSQWP_Service`; rework Lashed as W1. |
| S3 | **RSQ Whip's own touch ids are outside the `whip` group** | `crack`, `lasso`, `bola`, `tarzan`, `crack.shot`, `crack.return`, `yank.heavy`, `pull.punch`, `crack.stun` (whip.zs:291) are unknown tools. `crack` is only sent with the Sting upgrade. | Rename to `whip.*` (or register them) and send the move ids whether or not an upgrade is learned. |
| S4 | **Variety lumps the whip with the hook** | `RS_Bonus_Variety` T_HOOK takes `MK_WHIP` (dead, S2); a whip kill adds no tool. T_HANDS lumps the gloves with BD boots and blades. | T_WHIP and T_FISTS of their own. |
| S5 | **`finisher` means two things** | Score's tool `finisher` is a Brutal Doom fatality; GBOVR's Finisher node touches `finisher` too (up_fists.zs:391). | GBOVR sends `fist.finisher`. |
| S6 | **Ground Pound names two moves** | Score's Ground Pound is the Saber's Force jump landing; RSQ Melee's Ground Pound is the two-fist shockwave (tag `pound`), which Score scores as a punch. | One row, X1. |
| S7 | **Melee's non-punch blows read as punches (or as a shield bash)** | Without Gun Bonsai VR, `RSQML.Blow` returns the pawn (core.zs:103), so Ground Pound, Clear Out, Meteor, the Headlock Slam, the Chokehold and the Guard's release land as `'Melee'` from the pawn: `MK_FIST` (Brawler 0.5, Counter, Knockdown on a staggered monster), and **`MK_BASH` (Shield Work 0.3) if the ShieldSaw is in the off hand** (`RS_Melee.ShieldInHand`). With Gun Bonsai VR the `RSQML_GloveBlow` helper is still `MK_FIST`. | Read Melee's tags at the kill before the damage-type fallback; give these moves their own kinds. |
| S8 | **The Headlock toss reads as a punch** | Its blows are `'Melee'` with the thrown body as inflictor (headlock.zs:593). Without Distance Grab, `KindOf` returns `MK_FIST`: Brawler, and Knockdown on a body held in pain. | M23 Toss, from `RSQML_Tossed`. |
| S9 | **The gun-butt shove pays Boot** | Melee's shove is `'Kick'` (shove.zs:315), so it is `MK_BOOT` (Boot 0.2) and tool `kick`; Gun Kata (`hands > gun`) fires for shove-then-shot. It is the gun hand, not a boot. | Tool `shove`, row M27, chains Pistol Whip (G7) and Breach (G8). |
| S10 | **Counter and Knockdown sniff states** | Counter reads the victim's Missile/Melee states (its own comment: BD's monsters leave "Missile" at once) plus a fired-shot window; Melee now answers `"punch.counter"` from the glove's own wind-up read. Counter is fists only. | X7. |
| S11 | **Flurry re-derives what Melee answers** | `RS_ScoreShots.NoteGlove` rebuilds the left-right run; Melee gives `"punch.chain"`, `"punch.kinds"`, `"punch.run"`. | Read Melee's (keeps one definition of a run). |
| S12 | **Uppercut finisher "not built"** | Score README says no row reads `"punch.kind"`; Melee has answered it since 11-01. | M1. |
| S13 | **Force Lightning reads as a Force push** | Its blows are `'Saber'` from `UBQS_Force` (zscript.txt:5475): `MK_FORCE`, tool `force.push`; it can pay Juggle and Ring Out as a push. | Tool `force.lightning`, row S-11. |
| S14 | **The Force jump landing is filed as `force.grip`** | LandSlam is `'Force'` from `UBQS_Force` (zscript.txt:5617); Classify makes every `'Force'` blow `force.grip`, so Sitting Duck (`force.grip > gun`) fires off a landing. The fling's slam (5303) likewise. | Tools `force.jump`, `force.slam`. |
| S15 | **Every returned missile is labelled `saber.return`** | Classify: a monster's missile now yours is `saber.return` (combo.zs). A Hadouken, a Swat Back, a Reflect Guard and a whip Return Crack all read as the saber. | Melee and Whip answer `"returned.by"`; tools `hadouken`, `swat`, `guard.reflect`, `whip.return`. |
| S16 | **Reflect Guard 3's returned bullet reads as your gun** | `source.DamageMobj(pawn, pawn, back, 'Hitscan')` (guard.zs:218): tool `gun`, no Return to Sender. | M19. |
| S17 | **The rope rows ask only RSQ Grapple** | Swinging, Dismount, Indiana Jones, Reeled In, Ping-Pong, Fly Ball, Bowling and Ring Out's hook branch ask `RSQGR_Service`. RSQ Whip has its own rope, wrap and yank (a fork of Grapple's line, renamed RSQWP_) and answers nothing, so with the Whip alone they are silent. | `RSQWP_Service` answers the same request names; `RS_Svc` asks both. Indiana Jones pays traversal, which the owner's rule ("utility does not pay") may now cut; flagged, not decided here. |
| S18 | **Ring Out does not know the whip** | `RS_ScoreShots.NoteLaunch` notes Force, kick and `'Melee'` blows; the whip's `'Whip'` crack and its yank (no damage) are not noted, so a monster cracked or yanked off a ledge into a pit pays nobody. | Note `'Whip'` blows and the yank. |
| S19 | **Shield Work pays the grind less than the bash for a held grind** | A 1.5 s revved grind and a one-tic touch both pay 0.2. | D10. |
| S20 | **Melee's Wall Splat has no Score hook** | GBOVR_TREES 4.1 lists `splat`; splat.zs:75 never sends it. A wall kill pays as a plain punch (or not at all: the helper is the inflictor). | Add the tag; X2. |
| S21 | **Docs disagree with the code** | Whip README: "No RSQ Score hooks" (it touches the ledger, whip.zs:291). Score README's tool list has no Melee ids. `Score/BONUS_IDEAS.md` still lists Pistol-whip, Bash and Parried as unbuilt backlog, and rejects Bullet Time and "Interrupted", both since built. | Update when the rows land. |
| S22 | **Twin Blades gives no reward for USING both** | It pays any saber kill while both are lit, even if the off saber never moved. | S-5 Ataru pays alternating cuts; Twin Blades could drop to 0.1 or stand down when Ataru pays. |
