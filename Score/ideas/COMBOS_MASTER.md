# RSQ Score: the combo master list (2- and 3-tool pass)

Proposals only. Nothing here is built, measured or approved; every name is a placeholder for the owner to rename,
and every pay is a starting number for the rig, then the headset. Written 2026-11-03 by the combo pass, read only,
from `Score/ideas/A_*.md`, `B_*.md`, `C_*.md`, `D_*.md`, `Score/README.md` (the combo system) and
`Score/zscript/rsscore/combo.zs` (the ledger, `RS_ComboSeed.Combos`, `RS_Combo.Match`, `RS_Bonus_Chain`).
The owner fills in names and cuts in `NAMING_SHEET.csv` (one row per item, every lane's single bonuses too).

## Counts

| | |
|---|---|
| Tool ids in the one vocabulary | **89** (24 exist in the ledger today, 42 readable from facts the mods already send, 23 need a small answer from the owning mod) |
| Tags (facts about a blow, never tools) | 10 families, listed in 1.4 |
| Lane chains read | **338** (A 204, B 84 of which 3 restate existing combos, C 30, D 20) |
| ... after splitting B's `a \| b` alternatives into rows | 342 patterns (6 alternatives split out; A's Grand Master is a rule, C's Iaido Cut folds into bonus C T4) |
| ... after deduplication | **321** distinct lane chains (21 merges: the same pattern, or the same idea under another id) |
| Existing named combos kept (combo.zs table 13 + rows that are combos 7) | 20 |
| **New chains added by this pass** | **482**: 361 two-tool from the matrix, 12 slow-motion two-tool, 109 three-tool |
| **Named chains in the master table** | **823** (632 two-tool, 191 three-tool); 620 readable today, 203 need an answer from a mod |

"Readable today" means every step's fact is already sent or answered by its mod; Score itself still has to add the
row and its own classification (Score-side work only). "Needs" names the small answer the owning mod must add.

---

## 1. One tool-id vocabulary for the whole series

### 1.1 How an id is built (the ledger's own rules, kept)

- **`mod.move`**, lower case. `RS_Tool.InGroup` already matches a pattern step against the prefix before the first
  dot, so `saber` answers every `saber.*`, `gun` every `gun.*`, `grenade` every `grenade.*`. No new matching code for that.
- **Groups** beyond the prefix are registered (`RS_ScoreRegistry.RegisterTool(id, groups)`, as today): see 1.5.
- **Counts as** (the *action*): the generic count counts actions, not ids. Every `gun.*` is the one action `gun` (the
  owner's rule; varying guns stays Switcharoo's), every `glove.*` is `glove`, every `grenade.*` is `grenade`, every
  `hook.*` is `hook` (today bite + yank already count as one), every `whip.*` is `whip` except `whip.yank` (lane A's
  rule), `saber.stab/spin` count as `saber.cut`, `shield.grind/dash/slam` as `shield.bash`. `RS_Tool.ActionOf` gets
  this table instead of its one `hook.yank` line.
- **Tags are not tools** (lane A's S1, lane B's "modifier rule": adopted). Upgrade hooks and "how it landed" facts
  (`hit.heavy`, `crit`, `cleave.saw`, `zip.kick`, `scorpion`, `skeet`...) are registered with the group `tag`; the
  ledger stores them on the current run instead of opening a new one, `RS_Combo.Tools()` skips them, and rows read
  them. Today one Heavy Hands body uppercut is a 4-Tool Combo and a slow-motion moment by itself: this ends that.
- **Step suffix `@slow`** (lane A's, adopted; lane C's virtual first step `slow` becomes `@slow` on the first step):
  the step landed while slow motion was on. The ledger keeps one flag per entry (Score asks `slowmo.active` at the
  touch: readable today). When RSQ_SlowMo answers `trigger.auto`, only a slow motion the player started counts.
  Lane B's worry (Bullet Time already multiplies style) is answered by one rule: a kill whose chain row names `@slow`
  gets no Bullet Time / Stretched Second share for that row (the slow is already in the row's pay).
- **Step condition `+tag`**: a step may require a tag or one of Score's own conditions on that blow: `+air` (victim
  airborne), `+pb` (Point-Blank), `+head` (BD22 headshot), `+scorpion`, `+boomerang`. Lane D's `air` / `pb` / `head`
  condition words are these.
- **Victim filter `| filter`** after the pattern (lane C's, adopted: it fits, the victim is in hand when the chain is
  matched, and every filter is a token read by name, as `boost.zs` does). A filtered row needs no extra rule to beat its
  unfiltered twin: it pays more and the best-paying match wins. Filters in 1.6.
- **No alternation inside a step.** Lane B wrote `glove | punch`; `|` is the filter mark now, so B's alternatives were
  replaced by a group (`hands`, `block`) or split into separate rows (marked in the source column).

### 1.2 The clashes, resolved

| Clash | Resolution | Why |
|---|---|---|
| `punch.upper` (D) vs `glove.upper` (A) | **`glove.upper`**, with `glove.jab`, `glove.hook`; plain `glove` when the kind is not known. Melee's `punch.uppercut` touch becomes a tag (redundant). | RSQ Melee's gloves are the tool `glove` today; the prefix keeps every `glove > ...` pattern matching every punch. `punch` stays Brutal Doom's own fists. |
| Gun Bonsai VR's `finisher` vs Score's fatality tool `finisher` | Score's tool is **renamed `fatality`** (Score-only: nothing else sends it). GBOVR's Finisher node sends the **tag `fist.finisher`**. | "Finisher" is also the word for every pattern's last step; and GBOVR's touch was counting as a second tool on one punch (A S5). |
| Two "Ground Pound"s (the saber's Force-jump landing; Melee's two-fist shockwave) | Two **tools**, `force.jump` and `pound` (two mods, two moves); **one bonus row**, X1 Ground Pound, pays either. | A tool id says what the hands did; the row says what it is worth. |
| Melee's gun-butt shove / BD22 VR's butt strike / BD22 VR's pistol whip | **One tool, `shove`**, whichever mod delivered it. D's `pistolwhip` folds in. `shove` is in `fists` and `melee`, **not** `hands`, so shove > gun is no longer Gun Kata; Pistol Whip (`shove > gun.pistol`) and Breach (`shove > gun.shotgun`) are its rows. | The handoff's rule (D cites it), and S9 / C15 (it pays Boot today). |
| Gun classes (B nine, D six) | **D's six**: `gun.pistol`, `gun.shotgun`, `gun.rifle`, `gun.explosive`, `gun.energy`, `gun.fire`, plus plain **`gun`** for a weapon outside the class table. B's fold in: `ssg` > shotgun, `minigun` > rifle, `rocket` > explosive, `plasma` / `bfg` > energy, `flamer` > fire. BD's axe and saw are `blade.axe` / `blade.saw`. | D parsed the BD22 classes; the prefix matches only one level (`gun.shotgun.ssg` would not answer `gun.shotgun` without registering). Six is what a pattern needs. |
| Grenade kinds | **`grenade.<kind>`**: frag, stun, freeze, flash, smoke, fire, sticky, impact, cluster, charm, infight; all one action `grenade`. Today's touch ids (`stun.nade`, `freeze.nade`, `flash`, `smoke`, `fire.nade`, `sticky`, `charm`, `infight`) are mapped by Score. `cooked`, `skeet`, `teeth`, `airburst` are tags. BD22 VR's hand grenade is `grenade.frag`; the Grenade Launcher's and the Rifle's 40 mm are `gun.explosive`. A pattern step `grenade` means any kind. | One throw is one tool (B S17 / S18: a Stun grenade and its own blast were two tools). |
| Hook / whip / grab ids | **Grapple**: `hook.bite`, `hook.yank`, `hook.heavy`, `hook.zip` (replaces `zip.kick` as the tool; the touch becomes a tag), `hook.slam`, `hook.keg`; all one action. Grapple's Lasso *mode* is a hook mode (`hook.bite`). **Whip**: `whip.crack` (B/C/D's bare `whip`), `whip.flail`, `whip.wrap`, `whip.yank`, `whip.lasso`, `whip.bola`, `whip.tarzan`, `whip.shot`, `whip.return`; the existing Lion Tamer, Lasso, Circus Act keep the group `whip`. **Grab**: `grab.throw` (objects), `grab.swing`, `grab.keg`, `grab.shield` (Distance Grab); `grab.hold` stays the Headlock's id (RSQ Melee sends it; groups `grab` and `headlock`). **The Headlock's throw is `headlock.throw`** whichever mod carried it: A's `headlock.toss`, C's `headlock.throw` and B's `grab.hold > grab.throw` are one. | The whip's pull and the hook's pull are different mods and stay different ids, so Reeled In does not swallow the whip (A's choice). A live body out of the Headlock is a Melee move, an object is DG's. |
| `gun.throw` (C) | **`throw.gun`** (group `throw`). | A `gun.*` id would join the group `gun`, so Clay Pigeon would fire on a thrown pistol. |
| `shield.charge` (A) / `shield.saw` (B) | `shield.charge` folds into **`shield.dash`** (a tag `charge` keeps the difference); `shield.saw` is **`shield.grind`**. | Same moves. |
| `parry` (A) and the saber's / shield's perfect blocks | **`guard.parry`** (the Guard), `saber.parry`, `shield.perfect`; group **`parry`** = the saber's and the shield's (Perfect Riposte, as today), group **`block`** = the saber's and the shield's blocks (Riposte, as today). The Guard's parry stays out of both: A's Parry Punish is the Guard's own Riposte, so no existing row changes reach. | Three mods parry; the existing rows keep the reach they were measured with. |
| Every returned shot is `saber.return` today (A S15, B S12) | Split by owner: `saber.return`, `shield.return`, `hadouken`, `swat`, `guard.reflect`, `whip.return`, `grab.shield`; group **`return`**. | Names the hand that did it. |
| `slam` (Melee's Piledriver) vs the shield's wall slam vs the Force fling | `headlock.slam`, `shield.slam`, `force.slam`. | Three moves. |

### 1.3 The tool table

Group = the prefix plus the registered groups. Status: **exists** (the ledger records it under this id today),
**readable** (the mod already sends or answers the fact; Score's Classify or id map changes), **needs** (the owning mod
must add the answer named).

| id | group(s) | counts as | which mod sends it | status | needs / note |
|---|---|---|---|---|---|
| `glove` | fists, hands, melee | `glove` | RSQ Melee (RSQ_Glove blow) | exists | any punch whose kind is not known |
| `glove.jab` | fists, glove, hands, melee | `glove` | RSQ Melee | readable | Score asks RSQML_Service "punch.kind" on the glove at the blow (answered since 11-01) |
| `glove.hook` | fists, glove, hands, melee | `glove` | RSQ Melee | readable | as glove.jab (punch.kind 1) |
| `glove.upper` | fists, glove, hands, melee | `glove` | RSQ Melee | readable | as glove.jab (punch.kind 2). Replaces lane D's punch.upper and Melee's punch.uppercut touch (now a tag) |
| `shove` | fists, melee | `shove` | RSQ Melee (gun-butt shove) + BD22 VR (butt strike, pistol whip) | needs | RSQ Melee: touch `shove` on the victim for its own shove and for the BD22 VR butt strike it already reads (shove.zs:315/511); BD22 VR: mark the pistol whip (it lands as BD's punch today) |
| `guard.parry` | fists, guard | `guard.parry` | RSQ Melee (Guard) | readable | Melee touches `parry` today (guard.zs:198); Score maps the id |
| `guard.reflect` | fists, guard, return | `guard.reflect` | RSQ Melee (Reflect Guard) | needs | RSQ Melee: answer "returned.by" = 2 for a shot the Guard sent back; level 3's bullet read by the `guard.reflect` tag |
| `guard.release` | fists, guard, melee | `guard.release` | RSQ Melee (Absorb and Release) | readable | tag guard.release, blow on the same tic (guard.zs:274) |
| `hadouken` | fists, return | `hadouken` | RSQ Melee (punched fireball) | needs | RSQ Melee: answer "returned.by" = 0 for a missile it sent back |
| `swat` | fists, return | `swat` | RSQ Melee (Swat Back) | needs | RSQ Melee: "returned.by" = 1 |
| `taunt` | fists | `taunt` | RSQ Melee (Gestures event) | exists | Melee touches `taunt` today |
| `pound` | fists, melee | `pound` | RSQ Melee (two-fist Ground Pound) | readable | Melee touches `pound` today; Score must read it before the 'Melee' fallback (A S7) |
| `clearout` | fists, melee | `clearout` | RSQ Melee (Clear Out palm thrust) | readable | Melee touches `clearout` today; as pound |
| `grab.hold` | fists, grab, headlock | `grab.hold` | RSQ Melee (Headlock, off hand) | exists | deals no damage: opener or middle only |
| `headlock.throw` | fists, headlock, melee, throw | `headlock.throw` | RSQ Melee (+ Distance Grab carries the throw) | readable | RSQML_Tossed / ThrownInto on the body, DG's "headlock.throw"; today it reads as grab.throw or punch (A S8, B S13). Replaces A's headlock.toss and B's grab.hold > grab.throw |
| `headlock.slam` | fists, headlock, melee | `headlock.slam` | RSQ Melee (Piledriver) | readable | tag `slam` (headlock.zs:480) |
| `headlock.choke` | fists, headlock, melee | `headlock.choke` | RSQ Melee (Chokehold) | readable | tag `choke` (headlock.zs:274) |
| `headlock.launch` | fists, headlock, melee | `headlock.launch` | RSQ Melee (Headlock Uppercut) | exists | Melee touches `headlock.launch` (gloves.zs:959) |
| `punch` | hands, melee | `punch` | Brutal Doom fists (Score) | exists | BD's fists; the pistol whip moves to shove |
| `kick` | hands, melee | `kick` | Brutal Doom boots (Score) | exists | fix: a missile is never a kick (D stale 1, the GL's GrenadeMissile is 'Kick') |
| `blade` | melee | `blade` | Score (any 'Saw'/'Cut' not claimed) | exists | kept for other weapon sets |
| `blade.saw` | blade, melee | `blade` | BD22 VR Chain_saw (Score class table) | readable | inflictor SSawPuff2/3, SawDamageHorizontal* |
| `blade.axe` | blade, melee | `blade` | BD22 VR BrutalAxe, thrown axe included (Score class table) | readable | AxeAttack*, AxePuffs, ThrowedAxe*; thrown = tag `thrown` |
| `fatality` | melee | `fatality` | Brutal Doom fatality (Score, dt 'Fatality') | exists | RENAMED from Score's `finisher` (Score-only; nothing else sends it). GBOVR's Finisher node becomes the tag fist.finisher |
| `saber.cut` | melee, saber | `saber.cut` | QuestSaber | exists |  |
| `saber.stab` | melee, saber | `saber.cut` | QuestSaber | needs | QuestSaber: tag `saber.stab` on every stab (zscript.txt ~2116); today only Point Taken tags stab.lunge |
| `saber.spin` | melee, saber | `saber.cut` | QuestSaber (staff back blade / twirl) | needs | QuestSaber: a tag on back-blade and twirl cuts (~2265) |
| `saber.throw` | melee, saber, throw | `saber.throw` | QuestSaber | exists |  |
| `saber.return` | return, saber | `saber.return` | QuestSaber (deflected bolt) / the Force | exists | narrowed: a Hadouken, Swat, Reflect Guard, whip return and Body Shield return get their own ids (A S15, B S12) |
| `saber.block` | block, saber | `saber.block` | QuestSaber | exists | deals no damage |
| `saber.parry` | block, parry, saber | `saber.block` | QuestSaber ("perfect") | readable | Score polls the saber's "perfect" memory as it polls "blocked" |
| `saber.clash` | melee, saber | `saber.clash` | QuestSaber (blade-lock shockwave) | readable | tag `clash` (zscript.txt:2989) |
| `force.push` | force, melee | `force.push` | QuestSaber | exists |  |
| `force.pull` | force | `force.pull` | QuestSaber | exists | deals no damage |
| `force.grip` | force, melee | `force.grip` | QuestSaber | exists | choke and hold only, once force.jump / force.slam are split out (A S14) |
| `force.lightning` | force, melee | `force.lightning` | QuestSaber | needs | QuestSaber: tag `force.lightning` on every struck monster (today the first only, :5433) |
| `force.slam` | force, melee | `force.slam` | QuestSaber (the fling's slam) | needs | QuestSaber: answer "flung.by" on the slammed body (:5303) |
| `force.jump` | force, melee | `force.jump` | QuestSaber (Force jump landing) | readable | Score's own Ground Pound test (LandSlam, :5617) already tells it apart |
| `shield.bash` | melee, shield | `shield.bash` | RSQ ShieldSaw | exists | the bash only, once the grind is split |
| `shield.grind` | melee, shield | `shield.bash` | RSQ ShieldSaw (revved grind) | readable | 'Saw' from the pawn with the shield in hand (today folded into shield.bash). Replaces B's shield.saw |
| `shield.dash` | melee, shield | `shield.bash` | RSQ ShieldSaw (Shield Dash / Charge) | readable | tags dash.bash / charge (guard.zs ~883/957). A's shield.charge folds in here |
| `shield.slam` | melee, shield | `shield.bash` | RSQ ShieldSaw (wall slam) | needs | RSQ ShieldSaw: answer "slammed" (tics since a wall slam) |
| `shield.disc` | melee, shield, throw | `shield.disc` | RSQ ShieldSaw | exists |  |
| `shield.block` | block, shield | `shield.block` | RSQ ShieldSaw | exists | the block only (no damage) |
| `shield.perfect` | block, parry, shield | `shield.block` | RSQ ShieldSaw | needs | RSQ ShieldSaw: flag perfect blocks (SSQ_ScoreMemory.Turned takes a flag) |
| `shield.return` | return, shield | `shield.return` | RSQ ShieldSaw (turned shot) | readable | split from shield.block: Classify already sees the turned shot |
| `whip.crack` | melee, whip | `whip` | RSQ Whip ('Whip', pawn inflictor); RSQ Grapple's old whip | readable | Score must classify 'Whip' (today the crack is filed as gun, A S2). Lane B/C/D's bare `whip` = this |
| `whip.flail` | melee, whip | `whip` | RSQ Whip (swung monster) | needs | RSQ Whip: answer "flailing" (with Gun Bonsai VR the inflictor becomes the pawn) |
| `whip.wrap` | whip | `whip` | RSQ Whip (BeginWrap) | needs | RSQ Whip: answer "wrapped" (tics since); no damage |
| `whip.yank` | whip | `whip.yank` | RSQ Whip (Yank) | needs | RSQ Whip: answer "yanked" (whip.zs:1919); no damage |
| `whip.lasso` | throw, whip | `whip` | RSQ Whip | readable | Whip touches `lasso` today (:2011); Score maps the id |
| `whip.bola` | throw, whip | `whip` | RSQ Whip | readable | Whip touches `bola` today (:2047) |
| `whip.tarzan` | melee, whip | `whip` | RSQ Whip (rope swing arrival) | readable | tag `tarzan` + the 'Whip' blow (core.zs:360) |
| `whip.shot` | whip | `whip` | RSQ Whip (Crack Shot) | needs | RSQ Whip: mark the blown missile ("whip.shot" by inflictor) |
| `whip.return` | return, whip | `whip` | RSQ Whip (Return Crack) | readable | tag crack.return + a monster-born missile |
| `hook.bite` | hook | `hook` | RSQ Grapple | exists | no damage of its own |
| `hook.yank` | hook | `hook` | RSQ Grapple | exists | the throw, or a body it threw striking |
| `hook.heavy` | hook | `hook` | RSQ Grapple (reeled to an anchor) | readable | Grapple answers "hooked.heavy"; Score notes it instead of hook.bite |
| `hook.zip` | hook, melee | `hook` | RSQ Grapple (Zip Kick) | needs | RSQ Grapple: answer "zipped" (tics since ZipTick struck); its `zip.kick` touch becomes a tag. Replaces zip.kick as a tool |
| `hook.slam` | hook, melee | `hook` | RSQ Grapple (Double Hook slam) | needs | RSQ Grapple: a "slam" marker at EndSlam |
| `hook.keg` | hook | `hook` | RSQ Grapple (a hooked barrel's blast) | readable | Grapple keeps a record for any bitten actor; Classify reads the inflictor's |
| `grab.throw` | grab, throw | `grab.throw` | Distance Grab | exists | objects; a live monster out of the Headlock is headlock.throw |
| `grab.swing` | grab, melee | `grab.swing` | Distance Grab (held thing as a club) | needs | Distance Grab: answer "hold.by" for an object |
| `grab.keg` | grab | `grab.throw` | Distance Grab (thrown barrel's blast) | readable | "throw.blast" = 1 |
| `grab.shield` | grab, return | `grab.shield` | Distance Grab (body shield) | needs | Distance Grab: touch `grab.shield` on the shooter at every stop (today body.shield, Body Shield 3 only) |
| `throw.gun` | throw | `throw.gun` | Tactical Rig (thrown gun) + Distance Grab (floor gun) | needs | Tactical Rig: always touch `throw.gun` (today gun.toss, Gun Toss node only); DG's thrown Weapon is classifiable. Replaces C's gun.throw (a gun.* id would join group gun) |
| `grenade.frag` | grenade | `grenade` | RSQ Grenade / BD22 VR HandGrenade | readable | Classify: inflictor RSQGN_Thrown / RSQGN_HandBlast / HandGrenade / FragGrenadeExplosion (today `gun`, B S14) |
| `grenade.stun` | grenade | `grenade` | RSQ Grenade | readable | sent today as stun.nade; Score maps it |
| `grenade.freeze` | grenade | `grenade` | RSQ Grenade | readable | sent as freeze.nade |
| `grenade.flash` | grenade | `grenade` | RSQ Grenade | readable | sent as flash |
| `grenade.smoke` | grenade | `grenade` | RSQ Grenade | readable | sent as smoke |
| `grenade.fire` | grenade | `grenade` | RSQ Grenade (Incendiary) | readable | sent as fire.nade every 7 tics (one run) |
| `grenade.sticky` | grenade | `grenade` | RSQ Grenade | readable | sent as sticky on the monster |
| `grenade.impact` | grenade | `grenade` | RSQ Grenade | needs | RSQ Grenade: touch impact on the MONSTER hit (today the pawn) |
| `grenade.cluster` | grenade | `grenade` | RSQ Grenade (bomblets) | readable | inflictor RSQGN_Bomblet |
| `grenade.charm` | grenade | `grenade` | RSQ Grenade | readable | sent as charm |
| `grenade.infight` | grenade | `grenade` | RSQ Grenade | readable | sent as infight |
| `gun` |  | `gun` | Score (any shot no other row claims) | exists | a gun outside the class table (another weapon set) stays plain gun |
| `gun.pistol` | gun | `gun` | BD22 VR: BrutalPistol, BrutalRevolver, Revolver | readable | Score class table: inflictor, then the firing hand's weapon |
| `gun.shotgun` | gun | `gun` | BD22 VR: Shot_Gun, SSG, AssaultShotgun | readable | B's gun.ssg folds in |
| `gun.rifle` | gun | `gun` | BD22 VR: Rifle, Machinegun, BrutalSMG, MiniGun, Sniper | readable | B's gun.minigun folds in |
| `gun.explosive` | gun | `gun` | BD22 VR: Rocket_Launcher, GrenadeLauncher, NukeLauncher, 40 mm ShortGrenade | readable | B's gun.rocket folds in |
| `gun.energy` | gun | `gun` | BD22 VR: Plasma_Gun, RailGun, BFG9000, BFG10k, Unmaker | readable | B's gun.plasma / gun.bfg fold in |
| `gun.fire` | gun | `gun` | BD22 VR: Flamethrower2 (and its Burning* spread) | readable | B's gun.flamer folds in |
| `rig.draw` | rig | `rig.draw` | Tactical Rig (Score's Quick Draw window) | exists | off-hand draws need a hand argument on rig.drawtic (C stale 8) |
| `rig.draw.hip` | rig, rig.draw | `rig.draw` | Tactical Rig | needs | Tactical Rig: answer "rig.drawregion" |
| `rig.draw.chest` | rig, rig.draw | `rig.draw` | Tactical Rig | needs | as rig.draw.hip |
| `rig.draw.shoulder` | rig, rig.draw | `rig.draw` | Tactical Rig | needs | as rig.draw.hip |
| `lean` | dodge | `lean` | RSQ SlowMo (claw dodge) | exists | touched today on the claw dodge; the round dodge needs the same touch on round.target (C S6) |

### 1.4 Tags (stored on the blow's run; never counted as a tool)

| From | Tags |
|---|---|
| RSQ Melee | punch.uppercut (drop: glove.upper says it), hit.heavy, hit.body, juggle, wall (Wall Splat: needs splat.zs:75), meteor, shield.human |
| Gun Bonsai VR (all trees) | crit, headshot, backstab, combo.3, combo.dempsey, fist.finisher (RENAMED from finisher), fist.explosive, shatter, arc, burn, bloodrush, berserk.earned, lucky, knockdown, ram, sever, staff.spin, boomerang, slow.burn (drop: lands on a dead body) |
| QuestSaber | stab.lunge, impale, crossguard, barrage, return.sender, force.speed (on the player: a player fact, not a chain fact) |
| RSQ ShieldSaw | cleave.saw, spartan, buzz.return, rev.block, charge, dash.bash, slam.saw, reflect.saw, backplate |
| RSQ Whip | crack (Sting), crack.stun, crack.marked, pull.punch, yank.heavy |
| RSQ Grapple | zip.kick (on hook.zip), scorpion (on the glove it rides), torn (Barbed Claw) |
| RSQ Grenade | cooked, skeet, teeth, airburst, hand (went off in the hand) |
| Distance Grab | heavy (throw.kg >= 100), juggle (throw.juggle) |
| Tactical Rig | boomerang (gun flew back to the hand: boomerang.gun touch), empty (thrown empty), thrown (axe) |
| Score's own conditions | air (victim airborne, Juggle/Skeet facts), pb (Point-Blank, 64 units), head (BD22 damage type Head/MinorHead), far (edge distance >= 768) |

### 1.5 Registered groups

| group | members |
|---|---|
| `hands` | punch, kick, glove, glove.* (widened: today an exact list) |
| `fists` | every RSQ Melee move: glove.*, shove, guard.*, hadouken, swat, taunt, pound, clearout, grab.hold, headlock.* |
| `melee` | RS_Tool.IsMelee widened to every new damaging hand move (glove.*, shove, headlock.throw/slam/choke, saber.stab/spin, force.*, shield.*, whip.crack/flail/tarzan, hook.zip/slam, grab.swing, blade.*, fatality) |
| `headlock` | grab.hold + headlock.* |
| `block` | shield.block, shield.perfect, saber.block, saber.parry (what Riposte covers today; the Guard and the body shield keep their own rows, Parry Punish and Sandbag) |
| `parry` | saber.parry, shield.perfect (Perfect Riposte's) |
| `return` | saber.return, shield.return, hadouken, swat, guard.reflect, whip.return, grab.shield |
| `throw` | saber.throw, shield.disc, whip.lasso, whip.bola, headlock.throw, grab.throw, throw.gun |
| `rig.draw` | rig.draw.hip / .chest / .shoulder (a second-level group, registered) |
| `dodge` | lean |
| prefixes | `saber`, `force`, `shield`, `whip`, `hook`, `grab`, `grenade`, `gun`, `blade`, `rig`, `guard`, `headlock`, `glove`, `throw` (from the id itself) |
| `any` | everything (today) |

### 1.6 Victim filters

| filter | the victim | status |
|---|---|---|
| `champ` | any active champion (RS_Boost.ChampActive) | readable |
| `<Colour>` | that colour's token: Green, Cyan, Silver, Grey, Orange, Blue, Pink, Ghost (VISIBILITYPULSE test), Balloon (mutation test)... | readable |
| `armoured` | Bronze, Gold or Titan | readable |
| `legend` | a LegenDoom legendary | readable |
| `legend.rising` | a legendary within 2 s of rising (Score notes the first tic it sees LDLegendaryMonsterTransformed) | readable (Score-side note) |
| `legend.dormant` | a legendary that has not risen yet | readable |
| `thrall` | carries RSQMB_Thrall | readable |
| `miniboss` | carries RSQMB_Ward | readable |
| `DarkRed.corpse` | the Dark Red champion's shootable corpse (champion_ShootableCorpse) | readable (needs Score's credit fix, C stale 10) |

---

## 2. The generic chain pay, one rule

Lanes A and B proposed almost the same scale; this is the merge.

| Part | Rule |
|---|---|
| **Count** | Distinct *actions* in the chain (the "counts as" column). Tags never count. The same action again (with or without others between) adds nothing. |
| **Scale** | 2 actions **0.2**, 3 **0.45**, 4 **0.75**, 5 **1.0**, 6 or more **1.2** (today 0.2 / 0.4 / 0.6). Each extra tool inside 3 s gaps is harder than the last, so the step grows. |
| **Breadth** | **+0.1 per mod past two** in the chain, to **+0.3** (mods: Melee, Saber, ShieldSaw, Whip, Grapple, Distance Grab, Grenade, guns, Tactical Rig, Brutal Doom's own boots/fists/blades/fatality). A offered to +0.4, B +0.1 once at three mods; the middle keeps a 6-mod chain under the cap's reach. |
| **Tempo** | The whole chain, first move to kill, inside **2 s** (70 tics): the generic part **x1.25**. |
| **Named rows** | One named row per kill, the best-paying match (today). It **replaces the generic pay for the actions it names**; the actions past it pay as generic: generic part = Scale(all) - Scale(named), then breadth and tempo apply to that remainder only. A chain fully covered by its name gets no breadth or tempo (the name prices the mix). |
| **Rows that are combos already** (Reeled In, Ping-Pong, Fly Ball, Bowling, Pulled In, Riposte, Perfect Riposte) | **Changed** (lane B's S9): today the freshness rule blocks every table combo whose tools such a row covers, so `hook > saber.cut` can never fire while Reeled In does. New rule: a table combo covered entirely by such a row **may still fire when it pays more than that row's base pay**; the chain then pays (table pay - row base), so the kill earns the table combo's pay in total, never both. The row's own run bonus stays on top (Reeled In's +0.15 per earlier reel, Bowling's pins, Ping-Pong's volleys). A table combo that names a fresh tool works as today. Reeled In becomes the generic name for hook > melee; Come Here!, Harpoon, Doorstop... are its named variants. |
| **Cap** | The chain is **one Style bonus**: named + generic + breadth + tempo, all charged against the per-kill cap (`rs_score_cap_kill` 300 = 3x base). Variety and the melee Combo stand down on a kill whose chain mixed two tools (today). |
| **Big moment** | A named row of 3 or more tools, a generic chain of 5 or more actions, or 4 or more mods. |
| **Pay bands for named rows** | 2-tool 0.4 to 0.6; 3-tool 0.9 to 1.0, 1.2 for a timing feat (freeze shatter, heavy reel, smoke, sticky: B's band); a victim filter or `@slow` adds 0.1 to 0.2. A named row must pay **more than any broader named row it sits under** (Gun Kata, Fast Hands, Reeled In...), or the best-pay rule means it never fires: every fill row below was raised to the parent + 0.05 where needed, and lane rows that do not are flagged in section 5. |
| **Rules kept as rules** | Grand Master (A Q1): one action from each of `fists`, `saber`, `shield`, `whip` in one chain, 1.2, replaces the generic. Matrix (A): a 3-tool chain with every step `@slow` +0.3; it overlaps the `@slow` rows below, so keep one of the two. |

Worked example: `whip.yank > grab.hold > gun.shotgun > saber.cut`, inside 2 s. No row names all four (Ringside ends
on `glove`). The best match, `whip.yank > saber.cut` (Reel and Deal, 0.5), names 2 actions. Generic: Scale(4) 0.75
- Scale(2) 0.2 = 0.55; breadth: Whip, Melee, guns, Saber = 4 mods, +0.2; tempo x1.25 on (0.55 + 0.2) = 0.94. Total
0.5 + 0.94 = 1.44 x base, inside the 3x cap, a big moment (4 actions, 4 mods).

---

## 3. The matrix: opener x finisher, two tools

Every opener the series has (rows) against every killing blow (columns). **L** = a lane chain or an existing combo
already names this pair (a narrow group such as `hands`, `saber` or `grenade` counts; the broad `any`, `melee`, `gun`
do not, so a class row still gets its own name). **N** = named by this pass (in section 4, source "new (matrix)").
**.** = not a sequence a player would do in VR (same action twice; a gun followed by another gun, which is
Switcharoo's; a rocket or a grenade at arm's length; a throw at something you are holding; nothing to grab; no landing
to kill it).

Column key: Pun `glove`, Upp `glove.upper`, Shv `shove`, HdT `headlock.throw`, Cut `saber.cut`, Stb `saber.stab`, SbT `saber.throw`, Psh `force.push`, Grp `force.grip`, Bsh `shield.bash`, Grd `shield.grind`, Dsc `shield.disc`, Crk `whip.crack`, HkY `hook.yank`, Tos `grab.throw`, Bld `blade`, Fat `fatality`, Nad `grenade`, Pis `gun.pistol`, Sht `gun.shotgun`, Rif `gun.rifle`, Exp `gun.explosive`, Enr `gun.energy`, Flm `gun.fire`, Drw `rig.draw`.

| opener | Pun | Upp | Shv | HdT | Cut | Stb | SbT | Psh | Grp | Bsh | Grd | Dsc | Crk | HkY | Tos | Bld | Fat | Nad | Pis | Sht | Rif | Exp | Enr | Flm | Drw |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `glove` | . | . | N | N | L | L | . | L | . | L | . | . | L | . | . | N | N | . | N | N | . | . | . | . | N |
| `glove.upper` | . | . | . | . | L | L | L | L | L | L | N | L | L | L | L | N | N | L | L | L | L | L | . | . | N |
| `shove` | N | N | . | N | L | N | . | L | . | L | N | . | L | N | N | L | N | L | L | L | . | . | . | N | N |
| `hadouken` | N | L | . | . | L | N | N | N | N | N | . | N | N | . | . | N | . | N | N | N | . | . | N | . | N |
| `swat` | N | N | . | . | N | N | N | N | N | N | . | N | N | . | . | N | . | N | N | N | . | . | N | . | N |
| `guard.parry` | L | N | N | N | L | L | . | N | N | L | N | . | L | . | . | N | N | . | L | N | . | . | N | . | N |
| `grab.hold` | L | N | N | L | L | L | . | L | N | L | N | . | L | . | . | N | N | L | L | L | . | . | . | . | L |
| `saber.cut` | L | N | N | . | . | . | . | N | . | L | . | N | L | . | . | N | N | . | . | L | . | . | L | . | N |
| `saber.stab` | L | N | . | . | . | . | . | L | . | N | . | . | N | . | . | N | . | . | . | N | . | . | . | . | . |
| `saber.throw` | L | N | . | . | L | . | . | N | N | L | . | L | N | N | N | N | . | N | N | . | L | N | N | . | N |
| `force.push` | N | N | . | . | N | . | L | . | . | N | . | L | L | L | N | N | . | N | N | N | N | N | N | . | . |
| `force.pull` | N | N | N | N | N | N | . | N | N | N | N | . | N | . | . | N | N | . | . | N | . | . | N | N | N |
| `force.grip` | L | N | . | . | L | N | L | N | . | N | N | L | L | N | N | N | N | L | N | . | N | N | N | N | N |
| `shield.bash` | L | N | . | . | L | L | N | N | . | . | . | N | L | L | N | N | N | N | . | L | . | . | . | . | N |
| `shield.grind` | N | N | . | . | N | . | . | N | . | . | . | . | N | . | . | N | . | . | . | N | . | . | . | . | . |
| `shield.disc` | L | N | . | . | L | . | L | N | N | L | N | . | L | N | N | N | . | N | . | . | N | N | . | . | N |
| `shield.block` | N | N | N | N | N | N | N | N | N | N | N | N | N | . | N | N | N | L | N | N | N | . | N | N | N |
| `whip.crack` | L | N | . | . | L | . | N | N | N | L | . | L | . | L | N | N | N | N | L | N | . | . | . | . | L |
| `whip.wrap` | L | N | . | . | L | N | N | N | L | N | N | L | . | . | N | N | N | L | N | N | N | . | N | N | N |
| `whip.yank` | L | N | N | N | L | L | . | N | N | L | L | . | N | . | . | N | N | . | N | L | . | . | . | N | N |
| `whip.lasso` | L | N | . | . | L | N | N | N | L | N | N | L | . | N | N | N | N | L | . | N | N | N | . | . | N |
| `hook` | L | L | N | N | L | N | . | L | L | L | L | . | L | . | L | L | N | . | N | L | . | . | N | N | N |
| `grab.throw` | L | N | . | . | L | . | N | N | N | L | . | L | L | L | . | L | . | N | . | N | N | N | . | . | N |
| `grenade.frag` | L | . | . | . | L | . | . | N | . | N | . | N | N | L | . | N | N | . | . | . | L | . | . | . | . |
| `grenade.stun` | L | N | N | N | N | N | N | N | N | N | L | N | N | L | N | L | N | . | N | N | N | N | N | N | N |
| `grenade.freeze` | L | N | . | N | L | N | N | N | N | L | N | N | N | L | N | L | N | . | . | N | N | N | N | N | N |
| `grenade.flash` | N | N | N | N | L | L | N | . | N | N | . | N | . | L | N | N | N | . | N | N | N | . | . | . | N |
| `grenade.smoke` | N | . | . | . | N | L | N | . | N | . | . | N | . | . | N | N | . | . | . | N | N | . | . | N | N |
| `grenade.fire` | N | . | . | . | . | . | . | L | . | N | . | N | L | . | . | . | . | . | . | . | . | . | . | N | . |
| `grenade.sticky` | . | N | . | . | . | . | . | N | N | . | . | N | N | . | . | . | . | . | . | . | N | N | . | . | N |
| `gun.pistol` | N | N | N | . | N | . | . | . | . | N | . | . | L | . | . | N | N | . | . | . | . | . | . | . | . |
| `gun.shotgun` | L | N | N | . | L | . | . | . | . | N | . | . | N | . | . | N | N | . | . | . | . | . | . | . | . |
| `gun.rifle` | N | . | . | . | N | . | . | . | . | L | . | . | . | . | . | N | N | . | . | . | . | . | . | . | . |
| `gun.explosive` | L | . | . | . | N | . | . | . | . | . | . | . | . | . | . | L | N | . | . | . | . | . | . | . | . |
| `gun.energy` | N | . | . | . | L | . | . | . | . | N | . | . | . | . | . | . | . | . | . | . | . | . | . | . | . |
| `gun.fire` | L | . | . | . | N | . | . | . | . | N | . | . | L | . | . | N | . | . | . | . | . | . | . | . | . |
| `rig.draw` | L | . | N | . | N | . | . | . | . | N | . | . | N | . | . | N | . | . | . | . | . | . | . | . | . |

Cells: 151 L, 361 N, 413 not sensible. **Slow motion as a suffix**: 12 more two-tool rows put `@slow` on the steps where a
slowed world changes what the hands can do (a parry, a block, a swat, a thrown thing shot in the air, a lean); they
pay over their plain twins. **Three tools**: 109 strong opener > follow-up > finisher sequences were added by hand (bring
it, launch or stagger it, finish it with another mod; defence into offence; a status grenade into a hold), plus a few
victim-filtered ones where a champion's power changes the fight.

Pay of a fill row: 0.4; +0.1 when the opener is a control or defence move (hold, pull, wrap, block, parry, status
grenade); +0.05 for an air or return opener (uppercut, Hadouken, Swat); +0.05 for a hard finisher (uppercut, stab, the
hook's throw, the Headlock throw, a fatality, the saber throw); a gun opener 0.4; at most 0.6; then raised above any
broader row it sits under. Three-tool: 0.9, 1.0 with a defence, status, `@slow` or filter step.

---

## 4. Every named chain

Sorted by the opening tool (fists, saber, Force, ShieldSaw, whip, hook, grab, thrown gun, grenade, Brutal Doom, guns,
rig, SlowMo, then the broad groups). id is stable (built from the pattern, so it survives a rename). Pay is a
multiplier of the kill's base. "Alternate names" are the other names lanes offered for the same chain. Source: the
lane and row number, `existing`, or `new`. Placeholder names of fill rows are mechanical on purpose ("Yank into
Buckshot"): they are for the owner to rename.

| id | placeholder name | alternate names | ordered pattern | pay | readable today / needs | source |
|---|---|---|---|---|---|---|
| cb_glove__blade | Punch into Chainsaw |  | `glove > blade` | 0.40 | readable today | new (matrix) |
| cb_glove__fatality | Punch into Fatality |  | `glove > fatality` | 0.45 | readable today | new (matrix) |
| cb_glove__force_push | Jedi Jab |  | `glove > force.push` | 0.4 | readable today | A A13 |
| cb_glove__gun_pistol | Punch into Pistol |  | `glove > gun.pistol` | 0.45 | readable today | new (matrix) |
| cb_glove__gun_shotgun | Punch into Buckshot |  | `glove > gun.shotgun` | 0.45 | readable today | new (matrix) |
| cb_glove__headlock_throw | Punch into Suplex |  | `glove > headlock.throw` | 0.45 | readable today | new (matrix) |
| cb_glove__rig_draw | Punch into Quick Draw |  | `glove > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_glove__shield_bash | Fist and Shield |  | `glove > shield.bash` | 0.4 | readable today | A A11 |
| cb_glove__shield_disc | Punch and Pitch |  | `glove > shield.disc` | 0.4 | readable today | A A14 |
| cb_glove__shove | Punch into Shove |  | `glove > shove` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_glove__whip_crack | Knuckle Crack |  | `glove > whip.crack` | 0.4 | readable today | A A12 |
| cb_glove__glove_upper__gun_shotgun | One-Two-Skeet |  | `glove > glove.upper > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_glove__glove_upper__saber_throw | Rising Ace |  | `glove > glove.upper > saber.throw` | 0.90 | readable today | new (3-tool) |
| cb_glove__shove__gun_shotgun | Jab, Shove, Blast |  | `glove > shove > gun.shotgun` | 0.90 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_glove_hook__saber_cut | Cross Cut |  | `glove.hook > saber.cut` | 0.4 | readable today | A A9 |
| cb_glove_jab__saber_stab | Feint |  | `glove.jab > saber.stab` | 0.45 | needs: QuestSaber tags every stab | A A10 |
| cb_glove_upper__blade | Uppercut into Chainsaw |  | `glove.upper > blade` | 0.45 | readable today | new (matrix) |
| cb_glove_upper__fatality | Uppercut into Fatality |  | `glove.upper > fatality` | 0.50 | readable today | new (matrix) |
| cb_glove_upper__force_grip | Hang Up |  | `glove.upper > force.grip` | 0.5 | readable today | A A8 |
| cb_glove_upper__force_push | Launch Pad |  | `glove.upper > force.push` | 0.45 | readable today | A A7 |
| cb_glove_upper__grab_throw | Alley-Oop |  | `glove.upper > grab.throw` | 0.5 | readable today | A G41 |
| cb_glove_upper__grenade | Air Mail |  | `glove.upper > grenade` | 0.5 | readable today | A G51 |
| cb_glove_upper__gun_explosive | Fireworks |  | `glove.upper > gun.explosive` | 0.5 | readable today | A G4 |
| cb_glove_upper__gun_pistol | Pistol Juggle |  | `glove.upper > gun.pistol` | 0.5 | readable today | A G3 |
| cb_glove_upper__gun_rifle | Pop Fly |  | `glove.upper > gun.rifle` | 0.45 | readable today | A G2 |
| cb_glove_upper__gun_shotgun | Trap Shooter | Launch Pad (also offered as `glove.upper > gun.shotgun+air`) | `glove.upper > gun.shotgun` | 0.5 | readable today | A G1, D |
| cb_glove_upper__hook_yank | Catch of the Day |  | `glove.upper > hook.yank` | 0.6 | readable today | B |
| cb_glove_upper__rig_draw | Uppercut into Quick Draw |  | `glove.upper > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_glove_upper__saber_cut | Rising Dragon |  | `glove.upper > saber.cut` | 0.5 | readable today | A A1 |
| cb_glove_upper__saber_stab | Skyskewer |  | `glove.upper > saber.stab` | 0.55 | needs: QuestSaber tags every stab | A A2 |
| cb_glove_upper__saber_throw | Up and Away |  | `glove.upper > saber.throw` | 0.5 | readable today | A A3 |
| cb_glove_upper__shield_bash | Batter Up |  | `glove.upper > shield.bash` | 0.5 | readable today | A A5 |
| cb_glove_upper__shield_disc | Spike |  | `glove.upper > shield.disc` | 0.5 | readable today | A A4 |
| cb_glove_upper__shield_grind | Uppercut into Grind |  | `glove.upper > shield.grind` | 0.45 | readable today | new (matrix) |
| cb_glove_upper__whip_crack | Air Lash |  | `glove.upper > whip.crack` | 0.5 | readable today | A A6 |
| cb_glove_upper__force_grip__gun_pistol | Hang Time |  | `glove.upper > force.grip > gun.pistol` | 0.90 | readable today | new (3-tool) |
| cb_glove_upper__force_grip__saber_throw | Launch Sequence |  | `glove.upper > force.grip > saber.throw` | 0.9 | readable today | A T22 |
| cb_glove_upper__gun_pistol__gun_shotgun_w_air | Air Show |  | `glove.upper > gun.pistol > gun.shotgun+air` | 1.0 | readable today | D |
| cb_glove_upper__hook_yank__saber_cut | Down to Earth |  | `glove.upper > hook.yank > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_glove_upper__shield_disc__whip_crack | Juggle Act |  | `glove.upper > shield.disc > whip.crack` | 0.9 | readable today | A T29 |
| cb_glove_upper__whip_crack__gun_shotgun | Skeet Champion |  | `glove.upper > whip.crack > gun.shotgun` | 0.9 | readable today | A G68 |
| cb_glove_upper__whip_crack__saber_cut | Sky Combo |  | `glove.upper > whip.crack > saber.cut` | 0.9 | readable today | A T3 |
| cb_glove_upper_slow__gun_shotgun | Slow Trap Shooter |  | `glove.upper@slow > gun.shotgun` | 0.55 | readable today | new (matrix, @slow) |
| cb_hands__gun | Gun Kata |  | `hands > gun` | 0.4 | readable today | existing (combo.zs) |
| cb_kick__gun_shotgun_w_pb | Door Kick |  | `kick > gun.shotgun+pb` | 0.5 (replaces Gun Kata) | readable today | D |
| cb_kick__glove_upper__gun_shotgun | Boot Camp |  | `kick > glove.upper > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_shove__blade | Shove and Cleave |  | `shove > blade` | 0.5 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | C C12 |
| cb_shove__fatality | Shove into Fatality |  | `shove > fatality` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__force_push | Get Back |  | `shove > force.push` | 0.4 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A A18 |
| cb_shove__glove | Shove into Punch |  | `shove > glove` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__glove_upper | Shove into Uppercut |  | `shove > glove.upper` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__grab_throw | Shove into Pitch |  | `shove > grab.throw` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__grenade | Fire in the Hole |  | `shove > grenade` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A G55 |
| cb_shove__gun_w_head | Executioner |  | `shove > gun+head` | 0.6 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | D |
| cb_shove__gun_fire | Shove into Flamer |  | `shove > gun.fire` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__gun_pistol | Pistol Whip | Pistol Kata | `shove > gun.pistol` | 0.5 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A G7, D |
| cb_shove__gun_rifle | Butt and Burst |  | `shove > gun.rifle` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A G9 |
| cb_shove__gun_shotgun | Breach |  | `shove > gun.shotgun` | 0.5 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A G8 |
| cb_shove__gun_shotgun_slow | F.E.A.R. Effect |  | `shove > gun.shotgun@slow` | 0.6 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A G56, D |
| cb_shove__headlock_throw | Shove into Suplex |  | `shove > headlock.throw` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__hook_yank | Shove into Hook Throw |  | `shove > hook.yank` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__rig_draw | Shove into Quick Draw |  | `shove > rig.draw` | 0.55 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__saber_cut | Make Room |  | `shove > saber.cut` | 0.4 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A A15 |
| cb_shove__saber_stab | Shove into Stab |  | `shove > saber.stab` | 0.45 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip); QuestSaber tags every stab | new (matrix) |
| cb_shove__shield_bash | Riot Shield |  | `shove > shield.bash` | 0.5 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | C C13 |
| cb_shove__shield_disc | Clearance |  | `shove > shield.disc` | 0.4 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A A17 |
| cb_shove__shield_grind | Shove into Grind |  | `shove > shield.grind` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shove__whip_crack | Backlash |  | `shove > whip.crack` | 0.4 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A A16 |
| cb_shove__glove_upper__gun_pistol | Space Maker |  | `shove > glove.upper > gun.pistol` | 0.90 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_shove__glove_upper__shield_bash | Full Contact |  | `shove > glove.upper > shield.bash` | 0.9 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A T26 |
| cb_shove__whip_wrap__gun_shotgun | Push and Leash |  | `shove > whip.wrap > gun.shotgun` | 0.90 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip); RSQ Whip answers wrapped | new (3-tool) |
| cb_shove__whip_yank__glove | Paddleball |  | `shove > whip.yank > glove` | 0.9 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip); RSQ Whip answers yanked | A T10 |
| cb_block__any | Riposte |  | `block > any` | 0.4 | readable today | existing row (own class) |
| cb_block__hook | Turnabout |  | `block > hook` | 0.5 | readable today | B |
| cb_guard_parry__any | Parry Punish |  | `guard.parry > any` | 0.5 | readable today | A A19 |
| cb_guard_parry__blade | Parry into Chainsaw |  | `guard.parry > blade` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__fatality | Parry into Fatality |  | `guard.parry > fatality` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__force_grip | Parry into Grip |  | `guard.parry > force.grip` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__force_push | Parry into Push |  | `guard.parry > force.push` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__glove | Knuckle Sandwich |  | `guard.parry > glove` | 0.55 | readable today | A A20 |
| cb_guard_parry__glove_upper | Parry into Uppercut |  | `guard.parry > glove.upper` | 0.60 | readable today | new (matrix) |
| cb_guard_parry__gun_energy | Parry into Plasma |  | `guard.parry > gun.energy` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__gun_pistol | Duelist |  | `guard.parry > gun.pistol` | 0.55 | readable today | A G10 |
| cb_guard_parry__gun_shotgun | Parry into Buckshot |  | `guard.parry > gun.shotgun` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__headlock_throw | Parry into Suplex |  | `guard.parry > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__rig_draw | Parry into Quick Draw |  | `guard.parry > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__saber | Counter Cut |  | `guard.parry > saber` | 0.6 | readable today | A A21 |
| cb_guard_parry__shield_bash | Turn the Tables |  | `guard.parry > shield.bash` | 0.55 | readable today | A A22 |
| cb_guard_parry__shield_grind | Parry into Grind |  | `guard.parry > shield.grind` | 0.55 | readable today | new (matrix) |
| cb_guard_parry__shove | Parry into Shove |  | `guard.parry > shove` | 0.55 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_guard_parry__whip_crack | Recoil |  | `guard.parry > whip.crack` | 0.55 | readable today | A A23 |
| cb_guard_parry__glove_upper__glove | Dragon Fist |  | `guard.parry > glove.upper > glove` | 0.9 | readable today | A T11 |
| cb_guard_parry__grab_hold__headlock_throw | Reversal |  | `guard.parry > grab.hold > headlock.throw` | 1.00 | readable today | new (3-tool) |
| cb_guard_parry__saber_cut__force_push | Riposte and Repel |  | `guard.parry > saber.cut > force.push` | 1.00 | readable today | new (3-tool) |
| cb_guard_parry__shove__gun_shotgun | Counter Breach |  | `guard.parry > shove > gun.shotgun` | 1.00 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_guard_parry__shove__rig_draw | Parry, Shove, Draw |  | `guard.parry > shove > rig.draw` | 1.00 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_guard_parry__whip_wrap__saber_stab | Snare |  | `guard.parry > whip.wrap > saber.stab` | 0.9 | needs: RSQ Whip answers wrapped; QuestSaber tags every stab | A T24 |
| cb_guard_parry_slow__hands | Slow Parry Punish |  | `guard.parry@slow > hands` | 0.55 | readable today | new (matrix, @slow) |
| cb_guard_parry_slow__glove_upper__glove | Slow Dragon Fist |  | `guard.parry@slow > glove.upper > glove` | 1.00 | readable today | new (3-tool) |
| cb_guard_reflect__glove_upper | Bounce Back |  | `guard.reflect > glove.upper` | 0.5 | needs: RSQ Melee answers returned.by | A A24 |
| cb_guard_release__glove | Pressure Valve |  | `guard.release > glove` | 0.5 | readable today | A A25 |
| cb_guard_release__glove_upper__gun_rifle | Blow-Off Valve |  | `guard.release > glove.upper > gun.rifle` | 0.90 | readable today | new (3-tool) |
| cb_parry__any | Perfect Riposte |  | `parry > any` | 0.7 | readable today | existing row (own class) |
| cb_hadouken__blade | Hadouken into Chainsaw |  | `hadouken > blade` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__force_grip | Hadouken into Grip |  | `hadouken > force.grip` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__force_push | Hadouken into Push |  | `hadouken > force.push` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__glove | Hadouken into Punch |  | `hadouken > glove` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__glove_upper | Street Fighter |  | `hadouken > glove.upper` | 0.6 | needs: RSQ Melee answers returned.by | A A42 |
| cb_hadouken__grenade | Hadouken into Grenade |  | `hadouken > grenade` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__gun_energy | Hadouken into Plasma |  | `hadouken > gun.energy` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__gun_pistol | Hadouken into Pistol |  | `hadouken > gun.pistol` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__gun_shotgun | Hadouken into Buckshot |  | `hadouken > gun.shotgun` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__rig_draw | Hadouken into Quick Draw |  | `hadouken > rig.draw` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__saber_cut | Shoto |  | `hadouken > saber.cut` | 0.5 | needs: RSQ Melee answers returned.by | A A43 |
| cb_hadouken__saber_stab | Hadouken into Stab |  | `hadouken > saber.stab` | 0.50 | needs: RSQ Melee answers returned.by; QuestSaber tags every stab | new (matrix) |
| cb_hadouken__saber_throw | Hadouken into Saber Throw |  | `hadouken > saber.throw` | 0.50 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__shield_bash | Hadouken into Bash |  | `hadouken > shield.bash` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__shield_disc | Hadouken into Disc |  | `hadouken > shield.disc` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__whip_crack | Hadouken into Crack |  | `hadouken > whip.crack` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_hadouken__glove__glove_upper | Fireball Combo |  | `hadouken > glove > glove.upper` | 1.00 | needs: RSQ Melee answers returned.by | new (3-tool) |
| cb_hadouken__glove_upper__saber_cut | Super Combo |  | `hadouken > glove.upper > saber.cut` | 1.0 | needs: RSQ Melee answers returned.by | A T23 |
| cb_hadouken__shove__gun_shotgun | Return Fire |  | `hadouken > shove > gun.shotgun` | 1.00 | needs: RSQ Melee answers returned.by; RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_hadouken_slow__glove | Neo |  | `hadouken@slow > glove` | 0.6 | needs: RSQ Melee answers returned.by | A G57 |
| cb_return__return | Tennis |  | `return > return` | 0.5 | readable today | A A44 |
| cb_return__return__return | Hot Potato |  | `return > return > return` | 1.0 | readable today | A T8 |
| cb_swat__blade | Swat into Chainsaw |  | `swat > blade` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__force_grip | Swat into Grip |  | `swat > force.grip` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__force_push | Swat into Push |  | `swat > force.push` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__glove | Swat into Punch |  | `swat > glove` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__glove_upper | Swat into Uppercut |  | `swat > glove.upper` | 0.50 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__grenade | Swat into Grenade |  | `swat > grenade` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__gun_energy | Swat into Plasma |  | `swat > gun.energy` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__gun_pistol | Swat into Pistol |  | `swat > gun.pistol` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__gun_shotgun | Swat into Buckshot |  | `swat > gun.shotgun` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__rig_draw | Swat into Quick Draw |  | `swat > rig.draw` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__saber_cut | Swat into Slash |  | `swat > saber.cut` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__saber_stab | Swat into Stab |  | `swat > saber.stab` | 0.50 | needs: RSQ Melee answers returned.by; QuestSaber tags every stab | new (matrix) |
| cb_swat__saber_throw | Swat into Saber Throw |  | `swat > saber.throw` | 0.50 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__shield_bash | Swat into Bash |  | `swat > shield.bash` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__shield_disc | Swat into Disc |  | `swat > shield.disc` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__whip_crack | Swat into Crack |  | `swat > whip.crack` | 0.45 | needs: RSQ Melee answers returned.by | new (matrix) |
| cb_swat__glove_upper__gun_pistol | Backhand Spring |  | `swat > glove.upper > gun.pistol` | 1.00 | needs: RSQ Melee answers returned.by | new (3-tool) |
| cb_swat_slow__glove_upper | Slow Backhand |  | `swat@slow > glove.upper` | 0.50 | needs: RSQ Melee answers returned.by | new (matrix, @slow) |
| cb_clearout__grenade | Get Back! |  | `clearout > grenade` | 0.5 | readable today | B |
| cb_clearout__gun_explosive | Spread Out |  | `clearout > gun.explosive` | 0.45 | readable today | A G23 |
| cb_clearout__shield_disc | Spread and Shred |  | `clearout > shield.disc` | 0.45 | readable today | A A39 |
| cb_clearout__whip_crack | Crowd Control |  | `clearout > whip.crack` | 0.45 | readable today | A A38 |
| cb_clearout__hook__hands | Get Back, Get Over Here |  | `clearout > hook > hands` | 1.0 | readable today | B |
| cb_pound__gun_shotgun | Tremor |  | `pound > gun.shotgun` | 0.45 | readable today | A G22 |
| cb_pound__saber_cut | Aftershock |  | `pound > saber.cut` | 0.45 | readable today | A A40 |
| cb_pound__shield_bash | Quake |  | `pound > shield.bash` | 0.4 | readable today | A A41 |
| cb_taunt__gun_shotgun | Come Closer |  | `taunt > gun.shotgun` | 0.5 | readable today | A G11 |
| cb_taunt__hands | Come Get Some |  | `taunt > hands` | 0.4 | readable today | B |
| cb_taunt__saber | Bait and Blade |  | `taunt > saber` | 0.5 | readable today | A A26 |
| cb_taunt__shield_bash | Bait and Bash |  | `taunt > shield.bash` | 0.5 | readable today | A A27 |
| cb_taunt__whip_crack | Bait and Lash |  | `taunt > whip.crack` | 0.5 | readable today | A A28 |
| cb_taunt__guard_parry__glove_upper | Sucker Punch |  | `taunt > guard.parry > glove.upper` | 1.00 | readable today | new (3-tool) |
| cb_taunt__shield_block__gun_shotgun | Come and Get It |  | `taunt > shield.block > gun.shotgun` | 1.00 | readable today | new (3-tool) |
| cb_taunt__shield_block__saber_stab | Matador |  | `taunt > shield.block > saber.stab` | 0.9 | needs: QuestSaber tags every stab | A T7 |
| cb_taunt__whip_crack__rig_draw | High Noon Showdown |  | `taunt > whip.crack > rig.draw` | 1.0 | readable today | A G71 |
| cb_taunt__whip_lasso__glove | Lure |  | `taunt > whip.lasso > glove` | 0.9 | readable today | A T25 |
| cb_grab_hold__blade | Headlock into Chainsaw |  | `grab.hold > blade` | 0.50 | readable today | new (matrix) |
| cb_grab_hold__fatality | Headlock into Fatality |  | `grab.hold > fatality` | 0.55 | readable today | new (matrix) |
| cb_grab_hold__force_grip | Headlock into Grip |  | `grab.hold > force.grip` | 0.50 | readable today | new (matrix) |
| cb_grab_hold__force_push | Send-Off |  | `grab.hold > force.push` | 0.5 | readable today | A A32 |
| cb_grab_hold__glove_upper | Headlock into Uppercut |  | `grab.hold > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_grab_hold__grenade | Hold This |  | `grab.hold > grenade` | 0.6 | readable today | A G52 |
| cb_grab_hold__gun_pistol | Hostage |  | `grab.hold > gun.pistol` | 0.5 | readable today | A G5, D |
| cb_grab_hold__gun_shotgun | Close Quarters |  | `grab.hold > gun.shotgun` | 0.5 | readable today | A G6 |
| cb_grab_hold__hands | Headlock |  | `grab.hold > hands` | 0.5 | readable today | existing (combo.zs) |
| cb_grab_hold__hands__on_champ | Title Belt |  | `grab.hold > hands \| champ` | 0.6 | readable today | C C17 |
| cb_grab_hold__headlock_throw | Suplex | Bodycheck | `grab.hold > headlock.throw` | 0.5 | readable today | B, C C2 |
| cb_grab_hold__headlock_throw__on_orange | Hot Potato |  | `grab.hold > headlock.throw \| Orange` | 0.7 | readable today | C C18 |
| cb_grab_hold__headlock_throw__on_thrall | Throne Toss |  | `grab.hold > headlock.throw \| thrall` | 0.6 | readable today | C C26 |
| cb_grab_hold__rig_draw | Hostage Draw |  | `grab.hold > rig.draw` | 0.6 | readable today | A G34 |
| cb_grab_hold__saber | Execution |  | `grab.hold > saber` | 0.5 | readable today | A A29 |
| cb_grab_hold__shield_bash | Bulldog |  | `grab.hold > shield.bash` | 0.5 | readable today | A A30 |
| cb_grab_hold__shield_grind | Headlock into Grind |  | `grab.hold > shield.grind` | 0.50 | readable today | new (matrix) |
| cb_grab_hold__shove | Headlock into Shove |  | `grab.hold > shove` | 0.50 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_grab_hold__whip_crack | Flog |  | `grab.hold > whip.crack` | 0.5 | readable today | A A31 |
| cb_grab_hold__glove__blade | Hold Still |  | `grab.hold > glove > blade` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold__glove__headlock_throw | Beat and Toss |  | `grab.hold > glove > headlock.throw` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold__glove__rig_draw | Hold, Hit, Draw |  | `grab.hold > glove > rig.draw` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold__hands__gun_shotgun | Bouncer |  | `grab.hold > hands > gun.shotgun` | 0.9 | readable today | D |
| cb_grab_hold__headlock_choke__saber_cut | Choke and Cut |  | `grab.hold > headlock.choke > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold__headlock_launch__gun_shotgun | Cut Loose Skeet |  | `grab.hold > headlock.launch > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold__headlock_slam__gun_shotgun | Slam and Blam |  | `grab.hold > headlock.slam > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold__headlock_slam__shield_bash | Iron Maiden |  | `grab.hold > headlock.slam > shield.bash` | 0.9 | readable today | A T12 |
| cb_grab_hold__headlock_throw__grenade | Hot Package |  | `grab.hold > headlock.throw > grenade` | 0.9 | readable today | A G66 |
| cb_grab_hold__headlock_throw__shield_disc | Toss and Disc |  | `grab.hold > headlock.throw > shield.disc` | 0.90 | readable today | new (3-tool) |
| cb_grab_hold_slow__headlock_throw | Time Out |  | `grab.hold@slow > headlock.throw` | 0.9 | readable today | C C1 |
| cb_grab_hold_slow__headlock_throw__gun_shotgun | Slow Toss and Skeet |  | `grab.hold@slow > headlock.throw > gun.shotgun` | 1.00 | readable today | new (3-tool) |
| cb_headlock_slam__glove | Ground and Pound |  | `headlock.slam > glove` | 0.5 | readable today | A A33 |
| cb_headlock_slam__saber_stab | Pin Down |  | `headlock.slam > saber.stab` | 0.55 | needs: QuestSaber tags every stab | A A34 |
| cb_headlock_throw__gun_shotgun | Clay Toss |  | `headlock.throw > gun.shotgun` | 0.5 | readable today | A G24 |
| cb_headlock_throw__saber_throw | Target Practice |  | `headlock.throw > saber.throw` | 0.5 | readable today | A A37 |
| cb_headlock_throw__shield_disc | Skeet Disc |  | `headlock.throw > shield.disc` | 0.5 | readable today | A A35 |
| cb_headlock_throw__whip_crack | Fetch |  | `headlock.throw > whip.crack` | 0.5 | readable today | A A36 |
| cb_headlock_throw__whip_yank__glove | Catch and Release |  | `headlock.throw > whip.yank > glove` | 0.9 | needs: RSQ Whip answers yanked | A T19 |
| cb_saber_block__saber_cut__force_push | Defend, Cut, Repel |  | `saber.block > saber.cut > force.push` | 1.00 | readable today | new (3-tool) |
| cb_saber_cut__blade | Slash into Chainsaw |  | `saber.cut > blade` | 0.40 | readable today | new (matrix) |
| cb_saber_cut__fatality | Slash into Fatality |  | `saber.cut > fatality` | 0.45 | readable today | new (matrix) |
| cb_saber_cut__force_push | Slash into Push |  | `saber.cut > force.push` | 0.40 | readable today | new (matrix) |
| cb_saber_cut__glove | Pommel |  | `saber.cut > glove` | 0.4 | readable today | A A45 |
| cb_saber_cut__glove_upper | Slash into Uppercut |  | `saber.cut > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_saber_cut__gun_energy | Laser Sword |  | `saber.cut > gun.energy` | 0.5 | readable today | D |
| cb_saber_cut__gun_shotgun | Blade and Buckshot |  | `saber.cut > gun.shotgun` | 0.45 | readable today | A G19 |
| cb_saber_cut__rig_draw | Slash into Quick Draw |  | `saber.cut > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_saber_cut__shield_bash | Edge and Board |  | `saber.cut > shield.bash` | 0.4 | readable today | A A46 |
| cb_saber_cut__shield_disc | Slash into Disc |  | `saber.cut > shield.disc` | 0.40 | readable today | new (matrix) |
| cb_saber_cut__shove | Slash into Shove |  | `saber.cut > shove` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_saber_cut__whip_crack | Cut and Lash |  | `saber.cut > whip.crack` | 0.4 | readable today | A A47 |
| cb_saber_cut__force_grip__saber_throw | Hold and Hurl |  | `saber.cut > force.grip > saber.throw` | 0.90 | readable today | new (3-tool) |
| cb_saber_cut__force_push__gun_energy | Jedi Gunner |  | `saber.cut > force.push > gun.energy` | 0.9 | readable today | D |
| cb_saber_cut__force_push__gun_shotgun | Slash and Blast |  | `saber.cut > force.push > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_saber_parry_slow__saber_cut | Slow Counter Cut |  | `saber.parry@slow > saber.cut` | 0.75 | readable today | new (matrix, @slow) |
| cb_saber_stab__blade | Stab into Chainsaw |  | `saber.stab > blade` | 0.40 | needs: QuestSaber tags every stab | new (matrix) |
| cb_saber_stab__force_push | Off the Blade |  | `saber.stab > force.push` | 0.5 | needs: QuestSaber tags every stab | A A48 |
| cb_saber_stab__glove | Stab and Jab |  | `saber.stab > glove` | 0.4 | needs: QuestSaber tags every stab | A A49 |
| cb_saber_stab__glove_upper | Stab into Uppercut |  | `saber.stab > glove.upper` | 0.45 | needs: QuestSaber tags every stab | new (matrix) |
| cb_saber_stab__gun_shotgun | Stab into Buckshot |  | `saber.stab > gun.shotgun` | 0.40 | needs: QuestSaber tags every stab | new (matrix) |
| cb_saber_stab__shield_bash | Stab into Bash |  | `saber.stab > shield.bash` | 0.40 | needs: QuestSaber tags every stab | new (matrix) |
| cb_saber_stab__whip_crack | Stab into Crack |  | `saber.stab > whip.crack` | 0.40 | needs: QuestSaber tags every stab | new (matrix) |
| cb_saber_stab__force_push__shield_disc | Skewer and Spin |  | `saber.stab > force.push > shield.disc` | 0.90 | needs: QuestSaber tags every stab | new (3-tool) |
| cb_saber_throw__blade | Saber Throw into Chainsaw |  | `saber.throw > blade` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__force_grip | Saber Throw into Grip |  | `saber.throw > force.grip` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__force_push | Saber Throw into Push |  | `saber.throw > force.push` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__glove | Distraction |  | `saber.throw > glove` | 0.5 | readable today | A A50 |
| cb_saber_throw__glove_upper | Saber Throw into Uppercut |  | `saber.throw > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_saber_throw__grab_throw | Saber Throw into Pitch |  | `saber.throw > grab.throw` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__grenade | Saber Throw into Grenade |  | `saber.throw > grenade` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__gun_energy | Saber Throw into Plasma |  | `saber.throw > gun.energy` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__gun_explosive | Saber Throw into Rocket |  | `saber.throw > gun.explosive` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__gun_pistol | Saber Throw into Pistol |  | `saber.throw > gun.pistol` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__gun_rifle | Covering Fire |  | `saber.throw > gun.rifle` | 0.45 | readable today | A G18 |
| cb_saber_throw__hook_yank | Saber Throw into Hook Throw |  | `saber.throw > hook.yank` | 0.45 | readable today | new (matrix) |
| cb_saber_throw__rig_draw | Saber Throw into Quick Draw |  | `saber.throw > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_saber_throw__saber_cut | Throw and Go |  | `saber.throw > saber.cut` | 0.4 | readable today | A A52 |
| cb_saber_throw__shield_bash | Covering Throw |  | `saber.throw > shield.bash` | 0.5 | readable today | A A51 |
| cb_saber_throw__shield_disc | Air Traffic |  | `saber.throw > shield.disc` | 0.5 | readable today | A A53 |
| cb_saber_throw__whip_crack | Saber Throw into Crack |  | `saber.throw > whip.crack` | 0.40 | readable today | new (matrix) |
| cb_saber_throw__force_pull__saber_cut | Return Flight |  | `saber.throw > force.pull > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_saber_throw__hook__glove | Throw and Fetch |  | `saber.throw > hook > glove` | 0.90 | readable today | new (3-tool) |
| cb_saber_throw__whip_yank__saber_cut | Saber Dance |  | `saber.throw > whip.yank > saber.cut` | 0.9 | needs: RSQ Whip answers yanked | A T27 |
| cb_saber_throw_slow__gun_pistol | Slow Covering Fire |  | `saber.throw@slow > gun.pistol` | 0.50 | readable today | new (matrix, @slow) |
| cb_force_grip__blade | Grip into Chainsaw |  | `force.grip > blade` | 0.50 | readable today | new (matrix) |
| cb_force_grip__fatality | Grip into Fatality |  | `force.grip > fatality` | 0.55 | readable today | new (matrix) |
| cb_force_grip__force_push | Grip into Push |  | `force.grip > force.push` | 0.50 | readable today | new (matrix) |
| cb_force_grip__glove | Hung Out to Dry |  | `force.grip > glove` | 0.5 | readable today | A A60 |
| cb_force_grip__glove_upper | Grip into Uppercut |  | `force.grip > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_force_grip__grab_throw | Grip into Pitch |  | `force.grip > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_force_grip__grenade | Special Delivery |  | `force.grip > grenade` | 0.5 | readable today | A G53 |
| cb_force_grip__gun | Sitting Duck |  | `force.grip > gun` | 0.5 | readable today | existing (combo.zs) |
| cb_force_grip__gun_energy | Grip into Plasma |  | `force.grip > gun.energy` | 0.55 | readable today | new (matrix) |
| cb_force_grip__gun_explosive | Grip into Rocket |  | `force.grip > gun.explosive` | 0.55 | readable today | new (matrix) |
| cb_force_grip__gun_fire | Grip into Flamer |  | `force.grip > gun.fire` | 0.55 | readable today | new (matrix) |
| cb_force_grip__gun_pistol | Grip into Pistol |  | `force.grip > gun.pistol` | 0.55 | readable today | new (matrix) |
| cb_force_grip__gun_rifle | Grip into Rifle |  | `force.grip > gun.rifle` | 0.55 | readable today | new (matrix) |
| cb_force_grip__hook_yank | Grip into Hook Throw |  | `force.grip > hook.yank` | 0.55 | readable today | new (matrix) |
| cb_force_grip__rig_draw | Grip into Quick Draw |  | `force.grip > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_force_grip__saber_cut | Helpless |  | `force.grip > saber.cut` | 0.5 | readable today | A A56 |
| cb_force_grip__saber_cut__on_ghost | Exorcism |  | `force.grip > saber.cut \| Ghost` | 0.6 | readable today | C C28 |
| cb_force_grip__saber_stab | Grip into Stab |  | `force.grip > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_force_grip__saber_throw | Sitting Target |  | `force.grip > saber.throw` | 0.5 | readable today | A A57 |
| cb_force_grip__shield_bash | Grip into Bash |  | `force.grip > shield.bash` | 0.50 | readable today | new (matrix) |
| cb_force_grip__shield_disc | Pinned |  | `force.grip > shield.disc` | 0.5 | readable today | A A58 |
| cb_force_grip__shield_grind | Grip into Grind |  | `force.grip > shield.grind` | 0.50 | readable today | new (matrix) |
| cb_force_grip__whip_crack | Strung Up |  | `force.grip > whip.crack` | 0.5 | readable today | A A59 |
| cb_force_grip__force_push__shield_disc | Choke and Chuck |  | `force.grip > force.push > shield.disc` | 0.90 | readable today | new (3-tool) |
| cb_force_grip__glove__saber_cut | Jedi Brawler |  | `force.grip > glove > saber.cut` | 0.9 | readable today | A T17 |
| cb_force_grip__saber_throw__gun_pistol | Strung Target |  | `force.grip > saber.throw > gun.pistol` | 0.90 | readable today | new (3-tool) |
| cb_force_jump__glove | Superhero Landing |  | `force.jump > glove` | 0.5 | readable today | A A64 |
| cb_force_jump__saber_cut | Leap Strike |  | `force.jump > saber.cut` | 0.5 | readable today | A A63 |
| cb_force_jump__saber_cut__force_push | Landing Party |  | `force.jump > saber.cut > force.push` | 1.00 | readable today | new (3-tool) |
| cb_force_jump__shield_bash__saber_cut | Three-Point Landing |  | `force.jump > shield.bash > saber.cut` | 0.9 | readable today | A T21 |
| cb_force_lightning__glove | Shock and Awe |  | `force.lightning > glove` | 0.5 | needs: QuestSaber tags every struck monster | A A62 |
| cb_force_lightning__gun_energy | Overcharge |  | `force.lightning > gun.energy` | 0.5 | needs: QuestSaber tags every struck monster | A G17 |
| cb_force_lightning__saber_cut | Sith Ambush |  | `force.lightning > saber.cut` | 0.5 | needs: QuestSaber tags every struck monster | A A61 |
| cb_force_lightning__whip_crack__glove | Lightning Round |  | `force.lightning > whip.crack > glove` | 0.9 | needs: QuestSaber tags every struck monster | A T20 |
| cb_force_pull__blade | Pull into Chainsaw |  | `force.pull > blade` | 0.50 | readable today | new (matrix) |
| cb_force_pull__fatality | Pull into Fatality |  | `force.pull > fatality` | 0.55 | readable today | new (matrix) |
| cb_force_pull__force_grip | Pull into Grip |  | `force.pull > force.grip` | 0.50 | readable today | new (matrix) |
| cb_force_pull__force_push | Pull into Push |  | `force.pull > force.push` | 0.50 | readable today | new (matrix) |
| cb_force_pull__glove | Pull into Punch |  | `force.pull > glove` | 0.50 | readable today | new (matrix) |
| cb_force_pull__glove_upper | Pull into Uppercut |  | `force.pull > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_force_pull__gun | Pull! |  | `force.pull > gun` | 0.5 | readable today | existing (combo.zs) |
| cb_force_pull__gun_energy | Pull into Plasma |  | `force.pull > gun.energy` | 0.55 | readable today | new (matrix) |
| cb_force_pull__gun_fire | Pull into Flamer |  | `force.pull > gun.fire` | 0.55 | readable today | new (matrix) |
| cb_force_pull__gun_shotgun | Pull into Buckshot |  | `force.pull > gun.shotgun` | 0.55 | readable today | new (matrix) |
| cb_force_pull__headlock_throw | Pull into Suplex |  | `force.pull > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_force_pull__melee | Pulled In |  | `force.pull > melee` | 0.3 | readable today | existing row (own class) |
| cb_force_pull__rig_draw | Pull into Quick Draw |  | `force.pull > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_force_pull__saber_cut | Pull into Slash |  | `force.pull > saber.cut` | 0.50 | readable today | new (matrix) |
| cb_force_pull__saber_cut__on_silver | Opposites Attract |  | `force.pull > saber.cut \| Silver` | 0.6 | readable today | C C21 |
| cb_force_pull__saber_stab | Pull into Stab |  | `force.pull > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_force_pull__shield_bash | Pull into Bash |  | `force.pull > shield.bash` | 0.50 | readable today | new (matrix) |
| cb_force_pull__shield_grind | Pull into Grind |  | `force.pull > shield.grind` | 0.50 | readable today | new (matrix) |
| cb_force_pull__shove | Pull into Shove |  | `force.pull > shove` | 0.50 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_force_pull__whip_crack | Pull into Crack |  | `force.pull > whip.crack` | 0.50 | readable today | new (matrix) |
| cb_force_pull__force_push__gun | Yo-Yo |  | `force.pull > force.push > gun` | 0.9 | readable today | existing (combo.zs) |
| cb_force_pull__glove_upper__gun_shotgun | Come Here, Go Up |  | `force.pull > glove.upper > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_force_pull__grab_hold__blade | Pull and Carve |  | `force.pull > grab.hold > blade` | 0.90 | readable today | new (3-tool) |
| cb_force_pull__grab_hold__glove | Force Arrest |  | `force.pull > grab.hold > glove` | 0.9 | readable today | A T6 |
| cb_force_pull__grab_hold__headlock_throw__on_silver | Magnet Toss |  | `force.pull > grab.hold > headlock.throw \| Silver` | 1.00 | readable today | new (3-tool) |
| cb_force_pull__grenade_sticky__force_push | Return Address |  | `force.pull > grenade.sticky > force.push` | 1.2 | readable today | B |
| cb_force_pull__shield_bash__saber_cut | Jedi Hoplite |  | `force.pull > shield.bash > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_force_push__blade | Push into Chainsaw |  | `force.push > blade` | 0.40 | readable today | new (matrix) |
| cb_force_push__glove | Push into Punch |  | `force.push > glove` | 0.40 | readable today | new (matrix) |
| cb_force_push__glove__on_legend_rising | Rising Uppercut |  | `force.push > glove \| legend.rising` | 0.7 | readable today | C C25 |
| cb_force_push__glove_upper | Push into Uppercut |  | `force.push > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_force_push__grab_keg | Hot Seat |  | `force.push > grab.keg` | 0.5 | readable today | B |
| cb_force_push__grab_throw | Push into Pitch |  | `force.push > grab.throw` | 0.40 | readable today | new (matrix) |
| cb_force_push__grenade | Push into Grenade |  | `force.push > grenade` | 0.40 | readable today | new (matrix) |
| cb_force_push__gun | Clay Pigeon |  | `force.push > gun` | 0.5 | readable today | existing (combo.zs) |
| cb_force_push__gun_energy | Push into Plasma |  | `force.push > gun.energy` | 0.55 | readable today | new (matrix) |
| cb_force_push__gun_explosive | Push into Rocket |  | `force.push > gun.explosive` | 0.55 | readable today | new (matrix) |
| cb_force_push__gun_pistol | Push into Pistol |  | `force.push > gun.pistol` | 0.55 | readable today | new (matrix) |
| cb_force_push__gun_rifle | Push into Rifle |  | `force.push > gun.rifle` | 0.55 | readable today | new (matrix) |
| cb_force_push__gun_shotgun | Push into Buckshot |  | `force.push > gun.shotgun` | 0.55 | readable today | new (matrix) |
| cb_force_push__hook_yank | Slingshot | Rebound | `force.push > hook.yank` | 0.5 | readable today | A G35, B |
| cb_force_push__saber_cut | Push into Slash |  | `force.push > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_force_push__saber_throw | Clay Saber |  | `force.push > saber.throw` | 0.5 | readable today | A A55 |
| cb_force_push__shield_bash | Push into Bash |  | `force.push > shield.bash` | 0.40 | readable today | new (matrix) |
| cb_force_push__shield_disc | Disc Jockey |  | `force.push > shield.disc` | 0.5 | readable today | existing (combo.zs) |
| cb_force_push__whip_crack | Shove and Snap |  | `force.push > whip.crack` | 0.4 | readable today | A A54 |
| cb_force_push__force_pull__saber_cut | Push-Pull |  | `force.push > force.pull > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_force_push__grenade_frag__gun_rifle | Push, Pop, Pick Off |  | `force.push > grenade.frag > gun.rifle` | 0.90 | readable today | new (3-tool) |
| cb_force_push__hook__glove_upper | Away and Back |  | `force.push > hook > glove.upper` | 0.90 | readable today | new (3-tool) |
| cb_force_push__saber_throw__gun_pistol | Scoundrel |  | `force.push > saber.throw > gun.pistol` | 0.9 | readable today | A G73 |
| cb_force_push__whip_yank__glove | Rubber Band |  | `force.push > whip.yank > glove` | 0.9 | needs: RSQ Whip answers yanked | A T28 |
| cb_force_push_slow__gun_shotgun | Slow Clay Pigeon |  | `force.push@slow > gun.shotgun` | 0.55 | readable today | new (matrix, @slow) |
| cb_force_push_slow__saber_cut | Time Slash |  | `force.push@slow > saber.cut` | 0.5 | readable today | A G58 |
| cb_shield_bash__blade | Bash into Chainsaw |  | `shield.bash > blade` | 0.40 | readable today | new (matrix) |
| cb_shield_bash__blade__on_armoured | Crack the Shell |  | `shield.bash > blade \| armoured` | 0.6 | readable today | C C16 |
| cb_shield_bash__fatality | Bash into Fatality |  | `shield.bash > fatality` | 0.45 | readable today | new (matrix) |
| cb_shield_bash__force_push | Bash into Push |  | `shield.bash > force.push` | 0.40 | readable today | new (matrix) |
| cb_shield_bash__glove | Shield and Fist |  | `shield.bash > glove` | 0.4 | readable today | A A65 |
| cb_shield_bash__glove_upper | Bash into Uppercut |  | `shield.bash > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_shield_bash__grab_throw | Bash into Pitch |  | `shield.bash > grab.throw` | 0.40 | readable today | new (matrix) |
| cb_shield_bash__grenade | Bash into Grenade |  | `shield.bash > grenade` | 0.40 | readable today | new (matrix) |
| cb_shield_bash__gun_shotgun | Riot Control |  | `shield.bash > gun.shotgun` | 0.5 | readable today | A G20 |
| cb_shield_bash__hook_yank | Spring Back |  | `shield.bash > hook.yank` | 0.45 | readable today | A G36 |
| cb_shield_bash__rig_draw | Bash into Quick Draw |  | `shield.bash > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_shield_bash__saber_cut | Bash and Slash |  | `shield.bash > saber.cut` | 0.5 | readable today | A A66 |
| cb_shield_bash__saber_stab | Hoplite |  | `shield.bash > saber.stab` | 0.55 | needs: QuestSaber tags every stab | A A67 |
| cb_shield_bash__saber_throw | Bash into Saber Throw |  | `shield.bash > saber.throw` | 0.45 | readable today | new (matrix) |
| cb_shield_bash__shield_disc | Bash into Disc |  | `shield.bash > shield.disc` | 0.40 | readable today | new (matrix) |
| cb_shield_bash__whip_crack | Bash and Lash |  | `shield.bash > whip.crack` | 0.4 | readable today | A A68 |
| cb_shield_bash__force_push__shield_disc | Discus |  | `shield.bash > force.push > shield.disc` | 0.9 | readable today | existing (combo.zs) |
| cb_shield_bash__glove_upper__gun_shotgun | Bash and Launch |  | `shield.bash > glove.upper > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_shield_bash__hook__shield_grind | Bash, Reel, Grind |  | `shield.bash > hook > shield.grind` | 0.90 | readable today | new (3-tool) |
| cb_shield_bash__whip_yank__shield_bash | Pinball |  | `shield.bash > whip.yank > shield.bash` | 0.9 | needs: RSQ Whip answers yanked | A T9 |
| cb_shield_block__blade | Block into Chainsaw |  | `shield.block > blade` | 0.50 | readable today | new (matrix) |
| cb_shield_block__fatality | Block into Fatality |  | `shield.block > fatality` | 0.55 | readable today | new (matrix) |
| cb_shield_block__force_grip | Block into Grip |  | `shield.block > force.grip` | 0.50 | readable today | new (matrix) |
| cb_shield_block__force_push | Block into Push |  | `shield.block > force.push` | 0.50 | readable today | new (matrix) |
| cb_shield_block__glove | Block into Punch |  | `shield.block > glove` | 0.50 | readable today | new (matrix) |
| cb_shield_block__glove_upper | Block into Uppercut |  | `shield.block > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_shield_block__grab_throw | Block into Pitch |  | `shield.block > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_shield_block__grenade | Shield Up |  | `shield.block > grenade` | 0.4 | readable today | B |
| cb_shield_block__gun_energy | Block into Plasma |  | `shield.block > gun.energy` | 0.50 | readable today | new (matrix) |
| cb_shield_block__gun_fire | Block into Flamer |  | `shield.block > gun.fire` | 0.50 | readable today | new (matrix) |
| cb_shield_block__gun_pistol | Block into Pistol |  | `shield.block > gun.pistol` | 0.50 | readable today | new (matrix) |
| cb_shield_block__gun_rifle | Block into Rifle |  | `shield.block > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_shield_block__gun_shotgun | Block into Buckshot |  | `shield.block > gun.shotgun` | 0.50 | readable today | new (matrix) |
| cb_shield_block__headlock_throw | Block into Suplex |  | `shield.block > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_shield_block__rig_draw | Block into Quick Draw |  | `shield.block > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_shield_block__saber_cut | Block into Slash |  | `shield.block > saber.cut` | 0.50 | readable today | new (matrix) |
| cb_shield_block__saber_stab | Block into Stab |  | `shield.block > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_shield_block__saber_throw | Block into Saber Throw |  | `shield.block > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_shield_block__shield_bash | Block into Bash |  | `shield.block > shield.bash` | 0.50 | readable today | new (matrix) |
| cb_shield_block__shield_disc | Block into Disc |  | `shield.block > shield.disc` | 0.50 | readable today | new (matrix) |
| cb_shield_block__shield_grind | Block into Grind |  | `shield.block > shield.grind` | 0.50 | readable today | new (matrix) |
| cb_shield_block__shove | Block into Shove |  | `shield.block > shove` | 0.50 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_shield_block__whip_crack | Block into Crack |  | `shield.block > whip.crack` | 0.50 | readable today | new (matrix) |
| cb_shield_block__shield_bash__glove_upper | Shield Uppercut |  | `shield.block > shield.bash > glove.upper` | 1.00 | readable today | new (3-tool) |
| cb_shield_block__shield_bash__gun_shotgun | Riot Squad |  | `shield.block > shield.bash > gun.shotgun` | 0.9 | readable today | A G72 |
| cb_shield_block__shield_bash__saber | This Is Sparta |  | `shield.block > shield.bash > saber` | 0.9 | readable today | A T2 |
| cb_shield_block__shove__gun_shotgun | Wall and Breach |  | `shield.block > shove > gun.shotgun` | 1.00 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_shield_block__whip_wrap__saber_cut | Block and Bind |  | `shield.block > whip.wrap > saber.cut` | 1.00 | needs: RSQ Whip answers wrapped | new (3-tool) |
| cb_shield_block_slow__shield_bash | Slow Shield Wall |  | `shield.block@slow > shield.bash` | 0.50 | readable today | new (matrix, @slow) |
| cb_shield_block_slow__shield_bash__saber_cut | Slow Sparta |  | `shield.block@slow > shield.bash > saber.cut` | 1.00 | readable today | new (3-tool) |
| cb_shield_dash__glove_upper | Blitz |  | `shield.dash > glove.upper` | 0.5 | readable today | A A74 |
| cb_shield_dash__gun_shotgun | Door Kicker |  | `shield.dash > gun.shotgun` | 0.5 | readable today | A G21 |
| cb_shield_dash__saber | Spartan Charge | Breakthrough (also offered as `shield.dash > saber.cut`) | `shield.dash > saber` | 0.5 | readable today | A A75, A A78 |
| cb_shield_dash__glove_upper__saber_cut | Freight Train |  | `shield.dash > glove.upper > saber.cut` | 0.9 | readable today | A T13 |
| cb_shield_dash__shove__gun_shotgun | Battering Breach |  | `shield.dash > shove > gun.shotgun` | 0.90 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_shield_disc__blade | Disc into Chainsaw |  | `shield.disc > blade` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__force_grip | Disc into Grip |  | `shield.disc > force.grip` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__force_push | Disc into Push |  | `shield.disc > force.push` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__glove | Follow-Through |  | `shield.disc > glove` | 0.4 | readable today | A A69 |
| cb_shield_disc__glove_upper | Disc into Uppercut |  | `shield.disc > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_shield_disc__grab_throw | Disc into Pitch |  | `shield.disc > grab.throw` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__grenade | Disc into Grenade |  | `shield.disc > grenade` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__gun_explosive | Disc into Rocket |  | `shield.disc > gun.explosive` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__gun_rifle | Disc into Rifle |  | `shield.disc > gun.rifle` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__hook_yank | Disc into Hook Throw |  | `shield.disc > hook.yank` | 0.45 | readable today | new (matrix) |
| cb_shield_disc__rig_draw | Disc into Quick Draw |  | `shield.disc > rig.draw` | 0.55 | readable today | new (matrix) |
| cb_shield_disc__saber_cut | Saw and Saber |  | `shield.disc > saber.cut` | 0.5 | readable today | A A70 |
| cb_shield_disc__saber_throw | Crossfire |  | `shield.disc > saber.throw` | 0.5 | readable today | A A73 |
| cb_shield_disc__shield_bash | Throw and Follow |  | `shield.disc > shield.bash` | 0.4 | readable today | A A72 |
| cb_shield_disc__shield_grind | Disc into Grind |  | `shield.disc > shield.grind` | 0.40 | readable today | new (matrix) |
| cb_shield_disc__whip_crack | Cleanup Crack |  | `shield.disc > whip.crack` | 0.4 | readable today | A A71 |
| cb_shield_disc__force_pull__saber_cut | Disc and Draw |  | `shield.disc > force.pull > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_shield_disc__hook__shield_grind | Disc and Drag |  | `shield.disc > hook > shield.grind` | 0.90 | readable today | new (3-tool) |
| cb_shield_disc__shield_dash__glove | Vibranium |  | `shield.disc > shield.dash > glove` | 0.9 | readable today | A T5 |
| cb_shield_disc__whip_yank__glove | Disc and Yank |  | `shield.disc > whip.yank > glove` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_shield_grind__blade | Grind into Chainsaw |  | `shield.grind > blade` | 0.40 | readable today | new (matrix) |
| cb_shield_grind__force_push | Grind into Push |  | `shield.grind > force.push` | 0.40 | readable today | new (matrix) |
| cb_shield_grind__glove | Grind into Punch |  | `shield.grind > glove` | 0.40 | readable today | new (matrix) |
| cb_shield_grind__glove_upper | Grind into Uppercut |  | `shield.grind > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_shield_grind__gun_shotgun | Grind into Buckshot |  | `shield.grind > gun.shotgun` | 0.40 | readable today | new (matrix) |
| cb_shield_grind__saber_cut | Grind into Slash |  | `shield.grind > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_shield_grind__whip_crack | Grind into Crack |  | `shield.grind > whip.crack` | 0.40 | readable today | new (matrix) |
| cb_shield_grind__force_push__shield_disc | Sawblade Send-Off |  | `shield.grind > force.push > shield.disc` | 0.90 | readable today | new (3-tool) |
| cb_shield_slam__glove | Up Against the Wall |  | `shield.slam > glove` | 0.5 | needs: RSQ ShieldSaw answers slammed | A A76 |
| cb_shield_slam__saber_stab | Nailed |  | `shield.slam > saber.stab` | 0.55 | needs: RSQ ShieldSaw answers slammed; QuestSaber tags every stab | A A77 |
| cb_whip__hook_yank | Lasso |  | `whip > hook.yank` | 0.5 | readable today | existing (combo.zs) |
| cb_whip__shield_bash | Lion Tamer |  | `whip > shield.bash` | 0.5 | readable today | existing (combo.zs) |
| cb_whip__hook__shield_bash | Ringmaster |  | `whip > hook > shield.bash` | 1.0 | readable today | B |
| cb_whip__hook_yank__gun | Circus Act |  | `whip > hook.yank > gun` | 0.9 | readable today | existing (combo.zs) |
| cb_whip_bola__grenade | Hog-Tied |  | `whip.bola > grenade` | 0.55 | readable today | B |
| cb_whip_crack__any__on_legend_dormant | Crack of Doom |  | `whip.crack > any \| legend.dormant` | 0.6 | readable today | C C24 |
| cb_whip_crack__blade | Crack into Chainsaw |  | `whip.crack > blade` | 0.40 | readable today | new (matrix) |
| cb_whip_crack__fatality | Crack into Fatality |  | `whip.crack > fatality` | 0.45 | readable today | new (matrix) |
| cb_whip_crack__force_grip | Crack into Grip |  | `whip.crack > force.grip` | 0.40 | readable today | new (matrix) |
| cb_whip_crack__force_push | Crack into Push |  | `whip.crack > force.push` | 0.40 | readable today | new (matrix) |
| cb_whip_crack__glove | Crack and Smack |  | `whip.crack > glove` | 0.4 | readable today | A A79 |
| cb_whip_crack__glove_upper | Crack into Uppercut |  | `whip.crack > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_whip_crack__grab_throw | Crack into Pitch |  | `whip.crack > grab.throw` | 0.40 | readable today | new (matrix) |
| cb_whip_crack__grenade | Crack into Grenade |  | `whip.crack > grenade` | 0.40 | readable today | new (matrix) |
| cb_whip_crack__gun_pistol | Frontier | Cowboy | `whip.crack > gun.pistol` | 0.5 | readable today | A G12, D |
| cb_whip_crack__gun_shotgun | Crack into Buckshot |  | `whip.crack > gun.shotgun` | 0.40 | readable today | new (matrix) |
| cb_whip_crack__rig_draw | High Noon |  | `whip.crack > rig.draw` | 0.6 | readable today | A G33 |
| cb_whip_crack__saber | Zorro |  | `whip.crack > saber` | 0.5 | readable today | A A80 |
| cb_whip_crack__saber_cut__on_grey | Matador's Cape |  | `whip.crack > saber.cut \| Grey` | 0.6 | readable today | C C23 |
| cb_whip_crack__saber_throw | Crack into Saber Throw |  | `whip.crack > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_whip_crack__shield_disc | Big Top |  | `whip.crack > shield.disc` | 0.5 | readable today | A A81 |
| cb_whip_crack__shove__gun_pistol | Gunsmoke |  | `whip.crack > shove > gun.pistol` | 0.9 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | A G70 |
| cb_whip_crack__whip_yank__glove_upper | Crack, Yank, Rise |  | `whip.crack > whip.yank > glove.upper` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_whip_crack_slow__gun | Bullet Ballet |  | `whip.crack@slow > gun` | 0.9 | readable today | C C11 |
| cb_whip_crack_slow__gun_pistol | Slow Frontier |  | `whip.crack@slow > gun.pistol` | 0.95 | readable today | new (matrix, @slow) |
| cb_whip_flail__glove | Tetherball |  | `whip.flail > glove` | 0.5 | needs: RSQ Whip answers flailing | A A95 |
| cb_whip_flail__shield_disc | Batting Practice |  | `whip.flail > shield.disc` | 0.5 | needs: RSQ Whip answers flailing | A A96 |
| cb_whip_flail__force_push__shield_disc | Whirlwind |  | `whip.flail > force.push > shield.disc` | 0.9 | needs: RSQ Whip answers flailing | A T15 |
| cb_whip_flail__shield_bash__glove | Wrecking Crew |  | `whip.flail > shield.bash > glove` | 0.9 | needs: RSQ Whip answers flailing | A T18 |
| cb_whip_lasso__blade | Lasso into Chainsaw |  | `whip.lasso > blade` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__fatality | Lasso into Fatality |  | `whip.lasso > fatality` | 0.55 | readable today | new (matrix) |
| cb_whip_lasso__force_grip | Bound |  | `whip.lasso > force.grip` | 0.5 | readable today | A A94 |
| cb_whip_lasso__force_push | Lasso into Push |  | `whip.lasso > force.push` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__glove | Rope-a-Dope |  | `whip.lasso > glove` | 0.5 | readable today | A A91 |
| cb_whip_lasso__glove_upper | Lasso into Uppercut |  | `whip.lasso > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_whip_lasso__grab_throw | Lasso into Pitch |  | `whip.lasso > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__grenade | Hog-Tied (whip.lasso) |  | `whip.lasso > grenade` | 0.55 | readable today | B |
| cb_whip_lasso__gun | Rodeo |  | `whip.lasso > gun` | 0.45 | readable today | A G13 |
| cb_whip_lasso__gun_explosive | Lasso into Rocket |  | `whip.lasso > gun.explosive` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__gun_rifle | Lasso into Rifle |  | `whip.lasso > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__gun_shotgun | Lasso into Buckshot |  | `whip.lasso > gun.shotgun` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__hook_yank | Lasso into Hook Throw |  | `whip.lasso > hook.yank` | 0.55 | readable today | new (matrix) |
| cb_whip_lasso__rig_draw | Lasso into Quick Draw |  | `whip.lasso > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__saber_cut | Hogtie |  | `whip.lasso > saber.cut` | 0.5 | readable today | A A92 |
| cb_whip_lasso__saber_stab | Lasso into Stab |  | `whip.lasso > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_whip_lasso__saber_throw | Lasso into Saber Throw |  | `whip.lasso > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_whip_lasso__shield_bash | Lasso into Bash |  | `whip.lasso > shield.bash` | 0.55 | readable today | new (matrix) |
| cb_whip_lasso__shield_disc | Roped and Diced |  | `whip.lasso > shield.disc` | 0.5 | readable today | A A93 |
| cb_whip_lasso__shield_grind | Lasso into Grind |  | `whip.lasso > shield.grind` | 0.50 | readable today | new (matrix) |
| cb_whip_lasso__force_grip__gun_rifle | Rope and Hold |  | `whip.lasso > force.grip > gun.rifle` | 0.90 | readable today | new (3-tool) |
| cb_whip_lasso__force_pull__saber_cut | Bounty Hunter |  | `whip.lasso > force.pull > saber.cut` | 0.9 | readable today | A T4 |
| cb_whip_lasso__glove__gun_pistol | Saloon Brawl |  | `whip.lasso > glove > gun.pistol` | 0.9 | readable today | A G69 |
| cb_whip_lasso__grenade__gun_rifle | Big Game Hunter |  | `whip.lasso > grenade > gun.rifle` | 0.9 | readable today | A G67 |
| cb_whip_lasso__shield_bash__saber_stab | Gladiator |  | `whip.lasso > shield.bash > saber.stab` | 0.9 | needs: QuestSaber tags every stab | A T16 |
| cb_whip_lasso__whip_yank__blade | Rope and Saw |  | `whip.lasso > whip.yank > blade` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_whip_tarzan__glove | Jungle Law |  | `whip.tarzan > glove` | 0.5 | readable today | A A98 |
| cb_whip_tarzan__gun_shotgun | Swing Shot |  | `whip.tarzan > gun.shotgun` | 0.5 | readable today | A G16 |
| cb_whip_tarzan__saber_cut | Swashbuckler |  | `whip.tarzan > saber.cut` | 0.6 | readable today | A A97 |
| cb_whip_tarzan__shield_bash | Cannonball |  | `whip.tarzan > shield.bash` | 0.5 | readable today | A A99 |
| cb_whip_tarzan__glove__gun_shotgun | Swing, Swat, Shoot |  | `whip.tarzan > glove > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_whip_wrap__blade | Wrap into Chainsaw |  | `whip.wrap > blade` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__fatality | Wrap into Fatality |  | `whip.wrap > fatality` | 0.55 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__force_grip | Strangler |  | `whip.wrap > force.grip` | 0.5 | needs: RSQ Whip answers wrapped | A A85 |
| cb_whip_wrap__force_push | Wrap into Push |  | `whip.wrap > force.push` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__glove | On a Leash |  | `whip.wrap > glove` | 0.5 | needs: RSQ Whip answers wrapped | A A83 |
| cb_whip_wrap__glove_upper | Wrap into Uppercut |  | `whip.wrap > glove.upper` | 0.55 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__grab_throw | Wrap into Pitch |  | `whip.wrap > grab.throw` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__grenade | Package Deal |  | `whip.wrap > grenade` | 0.5 | needs: RSQ Whip answers wrapped | A G54 |
| cb_whip_wrap__gun_energy | Wrap into Plasma |  | `whip.wrap > gun.energy` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__gun_explosive | Gift Wrapped |  | `whip.wrap > gun.explosive` | 0.5 | needs: RSQ Whip answers wrapped | A G15 |
| cb_whip_wrap__gun_fire | Wrap into Flamer |  | `whip.wrap > gun.fire` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__gun_pistol | Wrap into Pistol |  | `whip.wrap > gun.pistol` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__gun_rifle | Wrap into Rifle |  | `whip.wrap > gun.rifle` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__gun_shotgun | Wrap into Buckshot |  | `whip.wrap > gun.shotgun` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__rig_draw | Wrap into Quick Draw |  | `whip.wrap > rig.draw` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__saber_cut | Tied Up |  | `whip.wrap > saber.cut` | 0.5 | needs: RSQ Whip answers wrapped | A A82 |
| cb_whip_wrap__saber_stab | Wrap into Stab |  | `whip.wrap > saber.stab` | 0.55 | needs: RSQ Whip answers wrapped; QuestSaber tags every stab | new (matrix) |
| cb_whip_wrap__saber_throw | Wrap into Saber Throw |  | `whip.wrap > saber.throw` | 0.55 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__shield_bash | Wrap into Bash |  | `whip.wrap > shield.bash` | 0.55 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__shield_disc | Tethered |  | `whip.wrap > shield.disc` | 0.5 | needs: RSQ Whip answers wrapped | A A84 |
| cb_whip_wrap__shield_grind | Wrap into Grind |  | `whip.wrap > shield.grind` | 0.50 | needs: RSQ Whip answers wrapped | new (matrix) |
| cb_whip_wrap__force_grip__saber_cut | Puppeteer |  | `whip.wrap > force.grip > saber.cut` | 0.9 | needs: RSQ Whip answers wrapped | A T14 |
| cb_whip_wrap__force_grip__saber_cut__on_ghost | Spirit Bound |  | `whip.wrap > force.grip > saber.cut \| Ghost` | 1.00 | needs: RSQ Whip answers wrapped | new (3-tool) |
| cb_whip_wrap__glove__gun_shotgun | Leash and Blast |  | `whip.wrap > glove > gun.shotgun` | 0.90 | needs: RSQ Whip answers wrapped | new (3-tool) |
| cb_whip_wrap__glove_upper__shield_disc | Wrapped and Launched |  | `whip.wrap > glove.upper > shield.disc` | 0.90 | needs: RSQ Whip answers wrapped | new (3-tool) |
| cb_whip_yank__blade | Yank into Chainsaw |  | `whip.yank > blade` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__fatality | Yank into Fatality |  | `whip.yank > fatality` | 0.55 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__force_grip | Yank into Grip |  | `whip.yank > force.grip` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__force_push | Yank into Push |  | `whip.yank > force.push` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__glove | Get Over Here! |  | `whip.yank > glove` | 0.6 | needs: RSQ Whip answers yanked | A A86 |
| cb_whip_yank__glove_upper | Yank into Uppercut |  | `whip.yank > glove.upper` | 0.65 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__gun_fire | Yank into Flamer |  | `whip.yank > gun.fire` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__gun_pistol | Yank into Pistol |  | `whip.yank > gun.pistol` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__gun_shotgun | Closer |  | `whip.yank > gun.shotgun` | 0.5 | needs: RSQ Whip answers yanked | A G14 |
| cb_whip_yank__headlock_throw | Yank into Suplex |  | `whip.yank > headlock.throw` | 0.55 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__rig_draw | Yank into Quick Draw |  | `whip.yank > rig.draw` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__saber_cut | Reel and Deal |  | `whip.yank > saber.cut` | 0.5 | needs: RSQ Whip answers yanked | A A87 |
| cb_whip_yank__saber_stab | Meat Hook |  | `whip.yank > saber.stab` | 0.55 | needs: RSQ Whip answers yanked; QuestSaber tags every stab | A A88 |
| cb_whip_yank__shield_bash | Yank and Bank |  | `whip.yank > shield.bash` | 0.5 | needs: RSQ Whip answers yanked | A A89 |
| cb_whip_yank__shield_grind | Into the Blades |  | `whip.yank > shield.grind` | 0.55 | needs: RSQ Whip answers yanked | A A90 |
| cb_whip_yank__shove | Yank into Shove |  | `whip.yank > shove` | 0.50 | needs: RSQ Whip answers yanked; RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_whip_yank__whip_crack | Yank into Crack |  | `whip.yank > whip.crack` | 0.50 | needs: RSQ Whip answers yanked | new (matrix) |
| cb_whip_yank__glove__rig_draw | Yank, Jab, Draw |  | `whip.yank > glove > rig.draw` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_whip_yank__glove_upper__gun_shotgun | Yank and Launch |  | `whip.yank > glove.upper > gun.shotgun` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_whip_yank__grab_hold__glove | Ringside |  | `whip.yank > grab.hold > glove` | 0.9 | needs: RSQ Whip answers yanked | A T1 |
| cb_whip_yank__saber_cut__force_push | Reel, Slice, Repel |  | `whip.yank > saber.cut > force.push` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_whip_yank__shield_bash__gun_shotgun | Pull and Bash |  | `whip.yank > shield.bash > gun.shotgun` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_hook__blade | Meat Hook |  | `hook > blade` | 0.55 | readable today | B |
| cb_hook__fatality | Hook into Fatality |  | `hook > fatality` | 0.55 | readable today | new (matrix) |
| cb_hook__force_grip | Strung Up |  | `hook > force.grip` | 0.5 | readable today | B |
| cb_hook__force_push | Bungee |  | `hook > force.push` | 0.5 | readable today | B |
| cb_hook__glove_upper | Fish Out of Water |  | `hook > glove.upper` | 0.6 | readable today | B |
| cb_hook__grab_hold | Collar |  | `hook > grab.hold` | 0.45 | readable today | B |
| cb_hook__grab_throw | Tether Ball |  | `hook > grab.throw` | 0.45 | readable today | B |
| cb_hook__grenade | Special Delivery |  | `hook > grenade` | 0.6 | readable today | B |
| cb_hook__gun | Reel and Deal |  | `hook > gun` | 0.3 | readable today | B |
| cb_hook__gun_energy | Hook into Plasma |  | `hook > gun.energy` | 0.50 | readable today | new (matrix) |
| cb_hook__gun_fire | Hook into Flamer |  | `hook > gun.fire` | 0.50 | readable today | new (matrix) |
| cb_hook__gun_pistol | Hook into Pistol |  | `hook > gun.pistol` | 0.50 | readable today | new (matrix) |
| cb_hook__gun_shotgun | Hook Shot | Get Over Here (also offered as `hook.yank > gun.shotgun+pb`) | `hook > gun.shotgun` | 0.45 | readable today | B, D |
| cb_hook__hands | Come Here! |  | `hook > hands` | 0.5 | readable today | B |
| cb_hook__headlock_throw | Hook into Suplex |  | `hook > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_hook__kick | Punt |  | `hook > kick` | 0.5 | readable today | B |
| cb_hook__melee | Reeled In |  | `hook > melee` | 0.3 +0.15 per earlier one in 4 s, to 0.75 | readable today | existing row (own class) |
| cb_hook__pound | Get Down |  | `hook > pound` | 0.55 | readable today | B |
| cb_hook__rig_draw | Hook into Quick Draw |  | `hook > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_hook__saber_cut | Harpoon |  | `hook > saber.cut` | 0.5 | readable today | B |
| cb_hook__saber_stab | Hook into Stab |  | `hook > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_hook__shield_bash | Doorstop |  | `hook > shield.bash` | 0.5 | readable today | B |
| cb_hook__shield_disc | Disc Golf |  | `hook > shield.disc` | 0.45 | readable today | B |
| cb_hook__shield_grind | Sawmill |  | `hook > shield.grind` | 0.55 | readable today | B |
| cb_hook__shove | Hook into Shove |  | `hook > shove` | 0.50 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_hook__whip_crack | Crack the Line |  | `hook > whip.crack` | 0.5 | readable today | B |
| cb_hook__any__hook | Ping-Pong |  | `hook > any > hook` | 0.4 a volley | readable today | existing row (own class) |
| cb_hook__force_grip__gun | Strung Out |  | `hook > force.grip > gun` | 0.9 | readable today | B |
| cb_hook__force_grip__saber_cut | Reeled and Held |  | `hook > force.grip > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_hook__force_push__gun | Over Here, Over There |  | `hook > force.push > gun` | 0.9 | readable today | B |
| cb_hook__glove__glove_upper | Reel and Rally |  | `hook > glove > glove.upper` | 0.90 | readable today | new (3-tool) |
| cb_hook__glove__glove_upper__on_cyan | Eye of the Storm |  | `hook > glove > glove.upper \| Cyan` | 1.00 | readable today | new (3-tool) |
| cb_hook__glove_w_scorpion__melee | Scorpion Sting |  | `hook > glove+scorpion > melee` | 1.0 | readable today | B |
| cb_hook__glove_upper__gun_shotgun | Reel, Launch, Blast |  | `hook > glove.upper > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_hook__glove_upper__hook_yank | Kite |  | `hook > glove.upper > hook.yank` | 1.1 | readable today | B |
| cb_hook__grab_hold__headlock_slam | Reel and Piledrive |  | `hook > grab.hold > headlock.slam` | 0.90 | readable today | new (3-tool) |
| cb_hook__grab_hold__headlock_throw__on_thrall | Thrall Toss |  | `hook > grab.hold > headlock.throw \| thrall` | 1.00 | readable today | new (3-tool) |
| cb_hook__hands__fatality | Finish Him! |  | `hook > hands > fatality` | 1.1 | readable today | B |
| cb_hook__kick__blade | Hang the Meat |  | `hook > kick > blade` | 1.0 | readable today | B |
| cb_hook__saber_cut__force_push | Harpoon Push |  | `hook > saber.cut > force.push` | 0.90 | readable today | new (3-tool) |
| cb_hook__shield_bash__gun_shotgun | Doorstop Breach |  | `hook > shield.bash > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_hook__shield_bash__shield_disc | Reel and Hurl |  | `hook > shield.bash > shield.disc` | 1.0 | readable today | B |
| cb_hook__shove__gun_shotgun | Reel and Breach |  | `hook > shove > gun.shotgun` | 0.90 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_hook_bite__any__on_balloon | Kite String |  | `hook.bite > any \| Balloon` | 0.6 | readable today | C C22 |
| cb_hook_bite__any__on_green | Short Leash |  | `hook.bite > any \| Green` | 0.6 | readable today | C C19 |
| cb_hook_bite__hook_zip | Express Delivery |  | `hook.bite > hook.zip` | 0.5 | needs: RSQ Grapple answers zipped | C C15 |
| cb_hook_heavy__hook_zip__saber_cut | Grappling Strike |  | `hook.heavy > hook.zip > saber.cut` | 1.2 | needs: RSQ Grapple answers zipped | B |
| cb_hook_keg__any | Hooked Keg |  | `hook.keg > any` | 0.4 | readable today | B |
| cb_hook_keg__grab_throw__gun | Fetch! |  | `hook.keg > grab.throw > gun` | 1.0 | readable today | B |
| cb_hook_slam__grab_throw__gun | Bowling for Keeps |  | `hook.slam > grab.throw > gun` | 1.0 | needs: RSQ Grapple marks the slam | B |
| cb_hook_yank__any | Bowling |  | `hook.yank > any` | 0.5 +0.25 per later pin, to 1.25 (the struck body) | readable today | existing row (own class) |
| cb_hook_yank__any_w_air | Fly Ball |  | `hook.yank > any+air` | 0.35 | readable today | existing row (own class) |
| cb_hook_yank__melee__on_cyan | Against the Wind |  | `hook.yank > melee \| Cyan` | 0.6 | readable today | C C20 |
| cb_hook_yank__grab_hold__glove | Wrestlemania | Collar and Pound (also offered as `hook > grab.hold > hands`) | `hook.yank > grab.hold > glove` | 0.9 | readable today | A G59, B |
| cb_hook_yank__grab_hold__headlock_throw | Suplex City | Catch and Release (also offered as `hook > grab.hold > headlock.throw`) | `hook.yank > grab.hold > headlock.throw` | 0.9 | readable today | A G61, B |
| cb_hook_yank__shield_bash__saber_cut | Hook, Line and Sinker |  | `hook.yank > shield.bash > saber.cut` | 0.9 | readable today | A G60 |
| cb_hook_yank__shove__gun_pistol | Gunslinger |  | `hook.yank > shove > gun.pistol` | 0.9 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | D |
| cb_hook_zip__gun | Drop In | Drive-By | `hook.zip > gun` | 0.45 | needs: RSQ Grapple answers zipped | B, C C14 |
| cb_hook_zip__melee | Swoop |  | `hook.zip > melee` | 0.6 | needs: RSQ Grapple answers zipped | B |
| cb_hook_zip__glove__gun_shotgun | Zip, Jab, Blast |  | `hook.zip > glove > gun.shotgun` | 0.90 | needs: RSQ Grapple answers zipped | new (3-tool) |
| cb_hook_slow__gun_shotgun | Slow Hook Shot |  | `hook@slow > gun.shotgun` | 0.50 | readable today | new (matrix, @slow) |
| cb_hook_slow__glove_upper__gun_shotgun | Slow Reel and Launch |  | `hook@slow > glove.upper > gun.shotgun` | 1.00 | readable today | new (3-tool) |
| cb_grab_keg__melee | Aftershock |  | `grab.keg > melee` | 0.5 | readable today | B |
| cb_grab_shield__blade | Sandbag Slash (blade) |  | `grab.shield > blade` | 0.5 | needs: Distance Grab touches grab.shield on every stop | B |
| cb_grab_shield__gun | Sandbag Riposte |  | `grab.shield > gun` | 0.4 | needs: Distance Grab touches grab.shield on every stop | B |
| cb_grab_shield__saber_cut | Sandbag Slash |  | `grab.shield > saber.cut` | 0.5 | needs: Distance Grab touches grab.shield on every stop | B |
| cb_grab_shield__grab_throw__saber_cut | Shield and Sword |  | `grab.shield > grab.throw > saber.cut` | 1.0 | needs: Distance Grab touches grab.shield on every stop | B |
| cb_grab_swing__grab_throw | Swing and Let Fly |  | `grab.swing > grab.throw` | 0.5 | needs: Distance Grab answers hold.by | B |
| cb_grab_swing__gun | Batting Practice |  | `grab.swing > gun` | 0.4 | needs: Distance Grab answers hold.by | B |
| cb_grab_swing__glove_upper__gun_shotgun | Club, Launch, Blast |  | `grab.swing > glove.upper > gun.shotgun` | 0.90 | needs: Distance Grab answers hold.by | new (3-tool) |
| cb_grab_throw__blade | Throw and Go |  | `grab.throw > blade` | 0.5 | readable today | B |
| cb_grab_throw__force_grip | Pitch into Grip |  | `grab.throw > force.grip` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__force_push | Pitch into Push |  | `grab.throw > force.push` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__glove | Catch This | Brickbat (also offered as `grab.throw > hands`) | `grab.throw > glove` | 0.45 | readable today | A G37, B |
| cb_grab_throw__glove_upper | Pitch into Uppercut |  | `grab.throw > glove.upper` | 0.50 | readable today | new (matrix) |
| cb_grab_throw__grab_swing | Strike Two |  | `grab.throw > grab.swing` | 0.45 | needs: Distance Grab answers hold.by | B |
| cb_grab_throw__grenade | Pitch into Grenade |  | `grab.throw > grenade` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__gun | Batter Up | Fastball | `grab.throw > gun` | 0.35 | readable today | B, D |
| cb_grab_throw__gun_explosive | Pitch into Rocket |  | `grab.throw > gun.explosive` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__gun_rifle | Pitch into Rifle |  | `grab.throw > gun.rifle` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__gun_shotgun | Pitch into Buckshot |  | `grab.throw > gun.shotgun` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__hook | Bait and Hook |  | `grab.throw > hook` | 0.45 | readable today | B |
| cb_grab_throw__kick | Follow Through |  | `grab.throw > kick` | 0.45 | readable today | B |
| cb_grab_throw__rig_draw | Pitch into Quick Draw |  | `grab.throw > rig.draw` | 0.40 | readable today | new (matrix) |
| cb_grab_throw__saber_cut | Pitch and Slice |  | `grab.throw > saber.cut` | 0.5 | readable today | existing (combo.zs) |
| cb_grab_throw__saber_throw | Pitch into Saber Throw |  | `grab.throw > saber.throw` | 0.45 | readable today | new (matrix) |
| cb_grab_throw__shield_bash | Serve and Volley |  | `grab.throw > shield.bash` | 0.45 | readable today | A G38 |
| cb_grab_throw__shield_disc | Two Throws | Shot Put | `grab.throw > shield.disc` | 0.45 | readable today | A G40, B |
| cb_grab_throw__whip_crack | Toss and Crack |  | `grab.throw > whip.crack` | 0.45 | readable today | A G39 |
| cb_grab_throw__force_pull__saber_cut | Pitch and Pull |  | `grab.throw > force.pull > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_grab_throw__force_push__gun | Batter, Pitcher, Catcher |  | `grab.throw > force.push > gun` | 0.9 | readable today | B |
| cb_grab_throw__glove_upper__gun_explosive | Demolition Derby |  | `grab.throw > glove.upper > gun.explosive` | 0.9 | readable today | A G75 |
| cb_grab_throw__glove_upper__gun_shotgun | Pitch, Launch, Blast |  | `grab.throw > glove.upper > gun.shotgun` | 0.90 | readable today | new (3-tool) |
| cb_grab_throw__grenade__gun | Kitchen Sink |  | `grab.throw > grenade > gun` | 1.0 | readable today | B |
| cb_grab_throw__hook__melee | Bait and Switch |  | `grab.throw > hook > melee` | 1.0 | readable today | B |
| cb_grab_throw__hook__shield_bash | Pitch and Reel |  | `grab.throw > hook > shield.bash` | 1.05 | readable today | new (3-tool) |
| cb_grab_throw__shove__gun_shotgun | Brick and Breach |  | `grab.throw > shove > gun.shotgun` | 0.90 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_grab_throw__whip_yank__glove | Pitch and Yank |  | `grab.throw > whip.yank > glove` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_grab_throw_slow__gun_shotgun | Slow Clay Toss |  | `grab.throw@slow > gun.shotgun` | 0.50 | readable today | new (matrix, @slow) |
| cb_throw_gun__gun_w_boomerang | Homing Pigeon |  | `throw.gun > gun+boomerang` | 0.9 | needs: Tactical Rig always touches throw.gun | C C7 |
| cb_throw_gun__rig_draw | Tuco |  | `throw.gun > rig.draw` | 0.5 | needs: Tactical Rig always touches throw.gun | C C6 |
| cb_throw_gun__shove__rig_draw | Empty, Shove, Draw |  | `throw.gun > shove > rig.draw` | 1.00 | needs: Tactical Rig always touches throw.gun; RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_grenade__glove | Shell Shock |  | `grenade > glove` | 0.45 | readable today | A G49 |
| cb_grenade__gun | Mop Up |  | `grenade > gun` | 0.3 | readable today | B |
| cb_grenade__gun_rifle | Flush Out |  | `grenade > gun.rifle` | 0.4 | readable today | D |
| cb_grenade__hook | Flush Out |  | `grenade > hook` | 0.5 | readable today | B |
| cb_grenade__melee | Into the Breach |  | `grenade > melee` | 0.45 | readable today | B |
| cb_grenade__saber_cut | Frag and Slash |  | `grenade > saber.cut` | 0.45 | readable today | A G50 |
| cb_grenade__grab_keg__gun | Demolition |  | `grenade > grab.keg > gun` | 1.0 | readable today | B |
| cb_grenade__shove__gun_shotgun | Demolition |  | `grenade > shove > gun.shotgun` | 0.9 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | D |
| cb_grenade_fire__force_push | Into the Fire |  | `grenade.fire > force.push` | 0.5 | readable today | B |
| cb_grenade_fire__glove | Firebomb into Punch |  | `grenade.fire > glove` | 0.50 | readable today | new (matrix) |
| cb_grenade_fire__gun_fire | Firebomb into Flamer |  | `grenade.fire > gun.fire` | 0.40 | readable today | new (matrix) |
| cb_grenade_fire__shield_bash | Firebomb into Bash |  | `grenade.fire > shield.bash` | 0.50 | readable today | new (matrix) |
| cb_grenade_fire__shield_disc | Firebomb into Disc |  | `grenade.fire > shield.disc` | 0.50 | readable today | new (matrix) |
| cb_grenade_fire__whip_crack | Hot Lash |  | `grenade.fire > whip.crack` | 0.45 | readable today | A G48 |
| cb_grenade_fire__force_push__gun_fire | Fan the Flames |  | `grenade.fire > force.push > gun.fire` | 0.90 | readable today | new (3-tool) |
| cb_grenade_flash__blade | Flash into Chainsaw |  | `grenade.flash > blade` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__fatality | Flash into Fatality |  | `grenade.flash > fatality` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__force_grip | Flash into Grip |  | `grenade.flash > force.grip` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__glove | Flash into Punch |  | `grenade.flash > glove` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__glove_upper | Flash into Uppercut |  | `grenade.flash > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__grab_throw | Flash into Pitch |  | `grenade.flash > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_grenade_flash__gun_pistol | Flash into Pistol |  | `grenade.flash > gun.pistol` | 0.50 | readable today | new (matrix) |
| cb_grenade_flash__gun_rifle | Flash into Rifle |  | `grenade.flash > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_grenade_flash__gun_shotgun | Flash into Buckshot |  | `grenade.flash > gun.shotgun` | 0.50 | readable today | new (matrix) |
| cb_grenade_flash__headlock_throw | Flash into Suplex |  | `grenade.flash > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__hook | Snatch (grenade.flash) |  | `grenade.flash > hook` | 0.5 | readable today | B |
| cb_grenade_flash__melee | Lights Out |  | `grenade.flash > melee` | 0.5 | readable today | B |
| cb_grenade_flash__rig_draw | Flash into Quick Draw |  | `grenade.flash > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_grenade_flash__saber | Blind Side |  | `grenade.flash > saber` | 0.5 | readable today | A G46 |
| cb_grenade_flash__saber_throw | Flash into Saber Throw |  | `grenade.flash > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__shield_bash | Flash into Bash |  | `grenade.flash > shield.bash` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__shield_disc | Flash into Disc |  | `grenade.flash > shield.disc` | 0.55 | readable today | new (matrix) |
| cb_grenade_flash__shove | Flash into Shove |  | `grenade.flash > shove` | 0.55 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_grenade_flash__grab_hold__blade | Blind and Butcher |  | `grenade.flash > grab.hold > blade` | 1.00 | readable today | new (3-tool) |
| cb_grenade_flash__grab_hold__hands | Blind Date |  | `grenade.flash > grab.hold > hands` | 1.0 | readable today | B |
| cb_grenade_flash__hook__gun_shotgun | Swat Team |  | `grenade.flash > hook > gun.shotgun` | 1.0 | readable today | B |
| cb_grenade_flash__shield_dash__gun_shotgun | Breach and Clear |  | `grenade.flash > shield.dash > gun.shotgun` | 0.9 | readable today | A G65 |
| cb_grenade_flash__shove__gun_shotgun | Flashbang Breach |  | `grenade.flash > shove > gun.shotgun` | 1.00 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_grenade_flash__whip_wrap__saber_cut | Blinded and Bound |  | `grenade.flash > whip.wrap > saber.cut` | 1.00 | needs: RSQ Whip answers wrapped | new (3-tool) |
| cb_grenade_frag__blade | Frag into Chainsaw |  | `grenade.frag > blade` | 0.50 | readable today | new (matrix) |
| cb_grenade_frag__fatality | Frag into Fatality |  | `grenade.frag > fatality` | 0.50 | readable today | new (matrix) |
| cb_grenade_frag__force_push | Frag into Push |  | `grenade.frag > force.push` | 0.50 | readable today | new (matrix) |
| cb_grenade_frag__shield_bash | Frag into Bash |  | `grenade.frag > shield.bash` | 0.50 | readable today | new (matrix) |
| cb_grenade_frag__shield_disc | Frag into Disc |  | `grenade.frag > shield.disc` | 0.50 | readable today | new (matrix) |
| cb_grenade_frag__whip_crack | Frag into Crack |  | `grenade.frag > whip.crack` | 0.50 | readable today | new (matrix) |
| cb_grenade_frag__hook__glove | Flush and Punch |  | `grenade.frag > hook > glove` | 0.90 | readable today | new (3-tool) |
| cb_grenade_frag_slow__gun_rifle | Slow Airburst Pick-Off |  | `grenade.frag@slow > gun.rifle` | 0.50 | readable today | new (matrix, @slow) |
| cb_grenade_freeze__blade | Cold Cut (blade) |  | `grenade.freeze > blade` | 0.6 | readable today | B |
| cb_grenade_freeze__fatality | Freeze into Fatality |  | `grenade.freeze > fatality` | 0.55 | readable today | new (matrix) |
| cb_grenade_freeze__force_grip | Freeze into Grip |  | `grenade.freeze > force.grip` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__force_push | Freeze into Push |  | `grenade.freeze > force.push` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__glove | Ice Breaker | (also offered as `grenade.freeze > hands`) | `grenade.freeze > glove` | 0.55 | readable today | A G43, B |
| cb_grenade_freeze__glove_upper | Freeze into Uppercut |  | `grenade.freeze > glove.upper` | 0.60 | readable today | new (matrix) |
| cb_grenade_freeze__grab_throw | Freeze into Pitch |  | `grenade.freeze > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__gun_energy | Freeze into Plasma |  | `grenade.freeze > gun.energy` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__gun_explosive | Freeze into Rocket |  | `grenade.freeze > gun.explosive` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__gun_fire | Freeze into Flamer |  | `grenade.freeze > gun.fire` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__gun_rifle | Freeze into Rifle |  | `grenade.freeze > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__gun_shotgun | Freeze into Buckshot |  | `grenade.freeze > gun.shotgun` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__headlock_throw | Freeze into Suplex |  | `grenade.freeze > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_freeze__hook_yank | Ice Fishing |  | `grenade.freeze > hook.yank` | 0.7 | readable today | B |
| cb_grenade_freeze__rig_draw | Freeze into Quick Draw |  | `grenade.freeze > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__saber_cut | Cold Cut |  | `grenade.freeze > saber.cut` | 0.5 | readable today | A G45, B |
| cb_grenade_freeze__saber_stab | Freeze into Stab |  | `grenade.freeze > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_grenade_freeze__saber_throw | Freeze into Saber Throw |  | `grenade.freeze > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_freeze__shield_bash | Cold Shoulder | Ice Breaker (shield.bash) | `grenade.freeze > shield.bash` | 0.5 | readable today | A G44, B |
| cb_grenade_freeze__shield_disc | Freeze into Disc |  | `grenade.freeze > shield.disc` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__shield_grind | Freeze into Grind |  | `grenade.freeze > shield.grind` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__whip_crack | Freeze into Crack |  | `grenade.freeze > whip.crack` | 0.50 | readable today | new (matrix) |
| cb_grenade_freeze__force_push__gun_rifle | Ice Skate |  | `grenade.freeze > force.push > gun.rifle` | 1.00 | readable today | new (3-tool) |
| cb_grenade_freeze__glove_upper__gun_rifle | Deep Freeze |  | `grenade.freeze > glove.upper > gun.rifle` | 0.9 | readable today | A G63 |
| cb_grenade_freeze__glove_upper__gun_shotgun | Ice Pop |  | `grenade.freeze > glove.upper > gun.shotgun` | 1.00 | readable today | new (3-tool) |
| cb_grenade_freeze__grab_throw__shield_bash | Ice Sculpture |  | `grenade.freeze > grab.throw > shield.bash` | 1.1 | readable today | B |
| cb_grenade_freeze__hook_yank__hands | Deep Freeze |  | `grenade.freeze > hook.yank > hands` | 1.2 | readable today | B |
| cb_grenade_freeze__shield_bash__blade__on_armoured | Cold Steel |  | `grenade.freeze > shield.bash > blade \| armoured` | 1.00 | readable today | new (3-tool) |
| cb_grenade_freeze__shield_bash__saber_cut | Freeze and Fracture |  | `grenade.freeze > shield.bash > saber.cut` | 1.00 | readable today | new (3-tool) |
| cb_grenade_freeze__whip_crack__glove | Ice Age |  | `grenade.freeze > whip.crack > glove` | 0.9 | readable today | A G62 |
| cb_grenade_smoke__blade | Smoke into Chainsaw |  | `grenade.smoke > blade` | 0.55 | readable today | new (matrix) |
| cb_grenade_smoke__force_grip | Smoke into Grip |  | `grenade.smoke > force.grip` | 0.55 | readable today | new (matrix) |
| cb_grenade_smoke__glove | Smoke into Punch |  | `grenade.smoke > glove` | 0.55 | readable today | new (matrix) |
| cb_grenade_smoke__grab_throw | Smoke into Pitch |  | `grenade.smoke > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_grenade_smoke__gun_fire | Smoke into Flamer |  | `grenade.smoke > gun.fire` | 0.50 | readable today | new (matrix) |
| cb_grenade_smoke__gun_rifle | Smoke into Rifle |  | `grenade.smoke > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_grenade_smoke__gun_shotgun | Smoke into Buckshot |  | `grenade.smoke > gun.shotgun` | 0.50 | readable today | new (matrix) |
| cb_grenade_smoke__melee | Out of the Smoke |  | `grenade.smoke > melee` | 0.5 | readable today | B |
| cb_grenade_smoke__rig_draw | Smoke into Quick Draw |  | `grenade.smoke > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_grenade_smoke__saber_cut | Smoke into Slash |  | `grenade.smoke > saber.cut` | 0.55 | readable today | new (matrix) |
| cb_grenade_smoke__saber_stab | Ninja |  | `grenade.smoke > saber.stab` | 0.55 | needs: QuestSaber tags every stab | A G47 |
| cb_grenade_smoke__saber_throw | Smoke into Saber Throw |  | `grenade.smoke > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_smoke__shield_disc | Smoke into Disc |  | `grenade.smoke > shield.disc` | 0.55 | readable today | new (matrix) |
| cb_grenade_smoke__grab_hold__blade | Ghost Hold |  | `grenade.smoke > grab.hold > blade` | 1.00 | readable today | new (3-tool) |
| cb_grenade_smoke__hook__saber_stab | Out of the Fog |  | `grenade.smoke > hook > saber.stab` | 1.00 | needs: QuestSaber tags every stab | new (3-tool) |
| cb_grenade_smoke__hook_zip__saber_cut | Smoke and Mirrors |  | `grenade.smoke > hook.zip > saber.cut` | 1.2 | needs: RSQ Grapple answers zipped | B |
| cb_grenade_smoke__shield_dash__saber_stab | Smoke and Mirrors |  | `grenade.smoke > shield.dash > saber.stab` | 0.9 | needs: QuestSaber tags every stab | A G64 |
| cb_grenade_sticky__force_grip | Sticky into Grip |  | `grenade.sticky > force.grip` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__force_push | Sticky into Push |  | `grenade.sticky > force.push` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__glove_upper | Sticky into Uppercut |  | `grenade.sticky > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_grenade_sticky__gun | Pin Cushion |  | `grenade.sticky > gun` | 0.45 | readable today | B |
| cb_grenade_sticky__gun_explosive | Sticky into Rocket |  | `grenade.sticky > gun.explosive` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__gun_rifle | Sticky into Rifle |  | `grenade.sticky > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__rig_draw | Sticky into Quick Draw |  | `grenade.sticky > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__shield_disc | Sticky into Disc |  | `grenade.sticky > shield.disc` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__whip_crack | Sticky into Crack |  | `grenade.sticky > whip.crack` | 0.50 | readable today | new (matrix) |
| cb_grenade_sticky__force_push__grenade | Return to the Pack |  | `grenade.sticky > force.push > grenade` | 0.90 | readable today | new (3-tool) |
| cb_grenade_sticky__hook__grenade | Hot Potato |  | `grenade.sticky > hook > grenade` | 1.2 | readable today | B |
| cb_grenade_stun__blade | Stun and Saw |  | `grenade.stun > blade` | 0.55 | readable today | B |
| cb_grenade_stun__fatality | Stun into Fatality |  | `grenade.stun > fatality` | 0.55 | readable today | new (matrix) |
| cb_grenade_stun__force_grip | Stun into Grip |  | `grenade.stun > force.grip` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__force_push | Stun into Push |  | `grenade.stun > force.push` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__glove | Dazed and Confused |  | `grenade.stun > glove` | 0.5 | readable today | A G42 |
| cb_grenade_stun__glove_upper | Stun into Uppercut |  | `grenade.stun > glove.upper` | 0.55 | readable today | new (matrix) |
| cb_grenade_stun__grab_throw | Stun into Pitch |  | `grenade.stun > grab.throw` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__gun | Stun and Gun |  | `grenade.stun > gun` | 0.45 | readable today | B |
| cb_grenade_stun__gun_energy | Stun into Plasma |  | `grenade.stun > gun.energy` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__gun_explosive | Stun into Rocket |  | `grenade.stun > gun.explosive` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__gun_fire | Stun into Flamer |  | `grenade.stun > gun.fire` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__gun_pistol | Stun into Pistol |  | `grenade.stun > gun.pistol` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__gun_rifle | Stun into Rifle |  | `grenade.stun > gun.rifle` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__gun_shotgun | Stun into Buckshot |  | `grenade.stun > gun.shotgun` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__headlock_throw | Stun into Suplex |  | `grenade.stun > headlock.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_stun__hook | Snatch |  | `grenade.stun > hook` | 0.5 | readable today | B |
| cb_grenade_stun__rig_draw | Stun into Quick Draw |  | `grenade.stun > rig.draw` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__saber_cut | Stun into Slash |  | `grenade.stun > saber.cut` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__saber_stab | Stun into Stab |  | `grenade.stun > saber.stab` | 0.55 | needs: QuestSaber tags every stab | new (matrix) |
| cb_grenade_stun__saber_throw | Stun into Saber Throw |  | `grenade.stun > saber.throw` | 0.55 | readable today | new (matrix) |
| cb_grenade_stun__shield_bash | Stun into Bash |  | `grenade.stun > shield.bash` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__shield_disc | Stun into Disc |  | `grenade.stun > shield.disc` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__shield_grind | Stun and Saw (shield.grind) |  | `grenade.stun > shield.grind` | 0.55 | readable today | B |
| cb_grenade_stun__shove | Stun into Shove |  | `grenade.stun > shove` | 0.50 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_grenade_stun__whip_crack | Stun into Crack |  | `grenade.stun > whip.crack` | 0.50 | readable today | new (matrix) |
| cb_grenade_stun__glove__fatality | Dizzy Finish |  | `grenade.stun > glove > fatality` | 1.00 | readable today | new (3-tool) |
| cb_grenade_stun__grab_hold__headlock_throw | Dazed and Tossed |  | `grenade.stun > grab.hold > headlock.throw` | 1.00 | readable today | new (3-tool) |
| cb_grenade_stun__hook__blade | Butcher Shop |  | `grenade.stun > hook > blade` | 1.1 | readable today | B |
| cb_grenade_stun__hook__glove_upper | Stun, Reel, Launch |  | `grenade.stun > hook > glove.upper` | 1.00 | readable today | new (3-tool) |
| cb_grenade_stun__shield_bash__blade | Stun and Saw Through |  | `grenade.stun > shield.bash > blade` | 1.00 | readable today | new (3-tool) |
| cb_blade_saw__gun_shotgun | Rip and Pump |  | `blade.saw > gun.shotgun` | 0.4 | readable today | D |
| cb_gun__kick__on_darkred_corpse | Curb Stomp |  | `gun > kick \| DarkRed.corpse` | 0.5 | readable today | C C29 |
| cb_gun_energy__glove | Plasma into Punch |  | `gun.energy > glove` | 0.40 | readable today | new (matrix) |
| cb_gun_energy__saber_cut | Plasma Blade |  | `gun.energy > saber.cut` | 0.45 | readable today | A G32 |
| cb_gun_energy__shield_bash | Plasma into Bash |  | `gun.energy > shield.bash` | 0.40 | readable today | new (matrix) |
| cb_gun_energy__force_grip__saber_cut | Charge and Choke |  | `gun.energy > force.grip > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_gun_energy__shield_bash__saber_cut | Plasma Knight |  | `gun.energy > shield.bash > saber.cut` | 0.9 | readable today | A G74 |
| cb_gun_explosive__blade_saw | Mop-Up |  | `gun.explosive > blade.saw` | 0.5 | readable today | D |
| cb_gun_explosive__fatality | Rocket into Fatality |  | `gun.explosive > fatality` | 0.40 | readable today | new (matrix) |
| cb_gun_explosive__glove | Rocket Punch |  | `gun.explosive > glove` | 0.5 | readable today | A G28 |
| cb_gun_explosive__gun_rifle | Over-Under |  | `gun.explosive > gun.rifle` | 0.4 | readable today | D |
| cb_gun_explosive__saber_cut | Rocket into Slash |  | `gun.explosive > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_gun_explosive__force_push__shield_disc | Blast and Bowl |  | `gun.explosive > force.push > shield.disc` | 0.90 | readable today | new (3-tool) |
| cb_gun_explosive__gun_fire__blade_saw | Scorched Earth |  | `gun.explosive > gun.fire > blade.saw` | 0.9 | readable today | D |
| cb_gun_fire__blade | Flamer into Chainsaw |  | `gun.fire > blade` | 0.40 | readable today | new (matrix) |
| cb_gun_fire__glove | Hot Hands |  | `gun.fire > glove` | 0.5 | readable today | A G30 |
| cb_gun_fire__saber_cut | Flamer into Slash |  | `gun.fire > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_gun_fire__shield_bash | Flamer into Bash |  | `gun.fire > shield.bash` | 0.40 | readable today | new (matrix) |
| cb_gun_fire__whip_crack | Fire Whip |  | `gun.fire > whip.crack` | 0.45 | readable today | A G31 |
| cb_gun_fire__shield_bash__blade | Burn and Saw |  | `gun.fire > shield.bash > blade` | 0.90 | readable today | new (3-tool) |
| cb_gun_pistol__blade | Pistol into Chainsaw |  | `gun.pistol > blade` | 0.40 | readable today | new (matrix) |
| cb_gun_pistol__fatality | Pistol into Fatality |  | `gun.pistol > fatality` | 0.40 | readable today | new (matrix) |
| cb_gun_pistol__glove | Pistol into Punch |  | `gun.pistol > glove` | 0.40 | readable today | new (matrix) |
| cb_gun_pistol__glove_upper | Pistol into Uppercut |  | `gun.pistol > glove.upper` | 0.40 | readable today | new (matrix) |
| cb_gun_pistol__saber_cut | Pistol into Slash |  | `gun.pistol > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_gun_pistol__shield_bash | Pistol into Bash |  | `gun.pistol > shield.bash` | 0.40 | readable today | new (matrix) |
| cb_gun_pistol__shove | Pistol into Shove |  | `gun.pistol > shove` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_gun_pistol__whip_crack | Shoot and Snap |  | `gun.pistol > whip.crack` | 0.4 | readable today | A G29 |
| cb_gun_pistol__whip_yank__glove | Shoot and Yank |  | `gun.pistol > whip.yank > glove` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_gun_rifle__blade | Rifle into Chainsaw |  | `gun.rifle > blade` | 0.40 | readable today | new (matrix) |
| cb_gun_rifle__fatality | Rifle into Fatality |  | `gun.rifle > fatality` | 0.40 | readable today | new (matrix) |
| cb_gun_rifle__glove | Rifle into Punch |  | `gun.rifle > glove` | 0.40 | readable today | new (matrix) |
| cb_gun_rifle__saber_cut | Rifle into Slash |  | `gun.rifle > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_gun_rifle__shield_bash | Suppress and Storm |  | `gun.rifle > shield.bash` | 0.45 | readable today | A G27 |
| cb_gun_rifle__force_pull__saber_cut | Snipe and Pull |  | `gun.rifle > force.pull > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_gun_shotgun__blade | Buckshot into Chainsaw |  | `gun.shotgun > blade` | 0.40 | readable today | new (matrix) |
| cb_gun_shotgun__fatality | Buckshot into Fatality |  | `gun.shotgun > fatality` | 0.40 | readable today | new (matrix) |
| cb_gun_shotgun__glove | Buckshot Brawl |  | `gun.shotgun > glove` | 0.4 | readable today | A G25 |
| cb_gun_shotgun__glove_upper | Buckshot into Uppercut |  | `gun.shotgun > glove.upper` | 0.45 | readable today | new (matrix) |
| cb_gun_shotgun__saber_cut | Clean Up |  | `gun.shotgun > saber.cut` | 0.4 | readable today | A G26 |
| cb_gun_shotgun__shield_bash | Buckshot into Bash |  | `gun.shotgun > shield.bash` | 0.40 | readable today | new (matrix) |
| cb_gun_shotgun__shove | Buckshot into Shove |  | `gun.shotgun > shove` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_gun_shotgun__whip_crack | Buckshot into Crack |  | `gun.shotgun > whip.crack` | 0.40 | readable today | new (matrix) |
| cb_gun_shotgun__hook__glove | Wound, Reel, Punch |  | `gun.shotgun > hook > glove` | 0.90 | readable today | new (3-tool) |
| cb_gun_shotgun__shield_bash__saber_cut | Buckshot Hoplite |  | `gun.shotgun > shield.bash > saber.cut` | 0.90 | readable today | new (3-tool) |
| cb_rig_draw__blade | Quick Draw into Chainsaw |  | `rig.draw > blade` | 0.40 | readable today | new (matrix) |
| cb_rig_draw__hands | Saloon Brawl |  | `rig.draw > hands` | 0.5 | readable today | C C3 |
| cb_rig_draw__rig_draw | Swap Meet |  | `rig.draw > rig.draw` | 0.5 | needs: rig.draw entries carry the drawn class (Score-side) so two different guns can be told apart | C C8 |
| cb_rig_draw__saber_cut | Quick Draw into Slash |  | `rig.draw > saber.cut` | 0.40 | readable today | new (matrix) |
| cb_rig_draw__shield_bash | Quick Draw into Bash |  | `rig.draw > shield.bash` | 0.40 | readable today | new (matrix) |
| cb_rig_draw__shove | Quick Draw into Shove |  | `rig.draw > shove` | 0.40 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (matrix) |
| cb_rig_draw__whip_crack | Quick Draw into Crack |  | `rig.draw > whip.crack` | 0.40 | readable today | new (matrix) |
| cb_rig_draw__force_push__gun_pistol | Draw and Shove Off |  | `rig.draw > force.push > gun.pistol` | 0.90 | readable today | new (3-tool) |
| cb_rig_draw__shove__gun | Draw, Shove, Fire |  | `rig.draw > shove > gun` | 0.9 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | C C30 |
| cb_rig_draw__whip_yank__glove | Draw, Yank, Punch |  | `rig.draw > whip.yank > glove` | 0.90 | needs: RSQ Whip answers yanked | new (3-tool) |
| cb_rig_draw_slow__gun | High Noon |  | `rig.draw@slow > gun` | 0.9 | readable today | C C4 |
| cb_lean__gun | Slip and Shoot |  | `lean > gun` | 0.4 | readable today | C C9 |
| cb_lean__hands | Rope-a-Dope |  | `lean > hands` | 0.5 | readable today | C C10 |
| cb_lean_slow__gun | Slow Slip and Shoot |  | `lean@slow > gun` | 0.50 | readable today | new (matrix, @slow) |
| cb_lean_slow__shove__gun_shotgun | Slip, Shove, Blast |  | `lean@slow > shove > gun.shotgun` | 1.00 | needs: RSQ Melee touches `shove` (+ BD22 VR marks its pistol whip) | new (3-tool) |
| cb_melee__rig_draw | Fast Hands |  | `melee > rig.draw` | 0.5 | readable today | existing (combo.zs) |
| cb_any_slow__any__on_miniboss | Kingslayer |  | `any@slow > any \| miniboss` | 0.9 | readable today | C C27 |

Rules (not rows): **Grand Master** (A Q1, 1.2, see section 2), **Matrix** (A, +0.3, overlaps `@slow`).
Folded into a single-kill bonus: C5 Iaido Cut (`rig.draw.saber > saber.cut`) is bonus C T4 Iaido (the draw-window cut
is one blow, not a chain).

---

## 5. Dedupe log and flags

### 5.1 Merged (kept entry <- the other)

| kept | merged in | from | key |
|---|---|---|---|
| Slingshot | Rebound | B | `force.push > hook.yank` |
| Lasso | Lasso | B | `whip.crack > hook.yank` |
| Pitch and Slice | Pitch and Slice | B | `grab.throw > saber.cut` |
| Catch This | Brickbat | B | `grab.throw > hands` |
| Two Throws | Shot Put | B | `grab.throw > shield.disc` |
| Cold Cut | Cold Cut | B | `grenade.freeze > saber.cut` |
| Ice Breaker | Ice Breaker | B | `grenade.freeze > hands` |
| Cold Shoulder | Ice Breaker (shield.bash) | B | `grenade.freeze > shield.bash` |
| Wrestlemania | Collar and Pound | B | `hook > grab.hold > hands` |
| Suplex City | Catch and Release | B | `hook > grab.hold > headlock.throw` |
| Circus Act | Circus Act | B | `whip.crack > hook > gun` |
| Bodycheck | Suplex | C C2 | `grab.hold > headlock.throw` |
| Drop In | Drive-By | C C14 | `hook.zip > gun` |
| Trap Shooter | Launch Pad | D | `glove.upper > gun.shotgun` |
| Hook Shot | Get Over Here | D | `hook > gun.shotgun` |
| Hostage | Hostage | D | `grab.hold > gun.pistol` |
| Batter Up | Fastball | D | `grab.throw > gun` |
| Frontier | Cowboy | D | `whip.crack > gun.pistol` |
| Pistol Whip | Pistol Kata | D | `shove > gun.pistol` |
| F.E.A.R. Effect | F.E.A.R. Effect | D | `shove > gun.shotgun@slow` |
| Spartan Charge | Breakthrough | A A78 | `shield.dash > saber` |

Specialisations were **not** merged: a narrower row that names a class, a kind or an uppercut (Spike under Punch and
Pitch, Dazed and Confused under Shell Shock, Fish Out of Water under Come Here!, Time Out under Suplex) is its own row
and pays more.

### 5.2 Lane rows that never fire as written (pay no more than a broader row)

| row | pattern | note |
|---|---|---|
| Shield Up | `shield.block > grenade` | pays no more than broader Riposte (0.40): raise it or it never fires |
| Cannonball | `whip.tarzan > shield.bash` | pays no more than broader Lion Tamer (0.50): raise it or it never fires |
| Yank and Bank | `whip.yank > shield.bash` | pays no more than broader Lion Tamer (0.50): raise it or it never fires |
| Punt | `hook > kick` | pays no more than broader Come Here! (0.50): raise it or it never fires |
| Shell Shock | `grenade > glove` | pays no more than broader Into the Breach (0.45): raise it or it never fires |
| Frag and Slash | `grenade > saber.cut` | pays no more than broader Into the Breach (0.45): raise it or it never fires |
| Hot Lash | `grenade.fire > whip.crack` | pays no more than broader Into the Breach (0.45): raise it or it never fires |
| Snatch (grenade.flash) | `grenade.flash > hook` | pays no more than broader Flush Out (0.50): raise it or it never fires |
| Snatch | `grenade.stun > hook` | pays no more than broader Flush Out (0.50): raise it or it never fires |

### 5.3 Names used more than once (bonus or combo; the owner picks)

| name | used by |
|---|---|
| aftershock | combo pound > saber.cut; combo grab.keg > melee |
| batter up | combo glove.upper > shield.bash; combo grab.throw > gun |
| batting practice | combo whip.flail > shield.disc; combo grab.swing > gun |
| bouncer | bonus A M12; combo grab.hold > hands > gun.shotgun |
| carom | bonus B N9; bonus D Grenade Launcher |
| clean sweep | bonus A D17; bonus A X9 |
| come get some | bonus A M29; combo taunt > hands |
| crossfire | bonus D cross-weapon; combo shield.disc > saber.throw |
| deep freeze | combo grenade.freeze > glove.upper > gun.rifle; combo grenade.freeze > hook.yank > hands |
| demolition | bonus C 6; combo grenade > grab.keg > gun; combo grenade > shove > gun.shotgun |
| direct hit | bonus B N7; bonus D Rocket Launcher |
| fireworks | bonus C 7; combo glove.upper > gun.explosive |
| flush out | combo grenade > hook; combo grenade > gun.rifle |
| fly ball | bonus A W17; bonus A X6 |
| glass | bonus D Sniper (Ruger); bonus D Railgun |
| ground pound | bonus A M11; bonus A X1 |
| high noon | combo whip.crack > rig.draw; combo rig.draw@slow > gun |
| homecoming | bonus A D5; bonus C T7 |
| hooked keg | bonus B G1; combo hook.keg > any |
| hot potato | bonus B N6; combo return > return > return; combo grenade.sticky > hook > grenade; combo grab.hold > headlock.throw \| Orange |
| ice breaker | bonus B N12; combo grenade.freeze > glove |
| matador | bonus C 2; combo taunt > shield.block > saber.stab |
| meat hook | combo whip.yank > saber.stab; combo hook > blade |
| parry punish | bonus A M14; combo guard.parry > any |
| reel and deal | combo whip.yank > saber.cut; combo hook > gun |
| ringmaster | bonus A W16; combo whip > hook > shield.bash |
| riot control | bonus C M8; combo shield.bash > gun.shotgun |
| rip and tear | bonus A M30; bonus D Chainsaw |
| rope-a-dope | combo whip.lasso > glove; combo lean > hands |
| saloon brawl | combo whip.lasso > glove > gun.pistol; combo rig.draw > hands |
| smoke and mirrors | combo grenade.smoke > shield.dash > saber.stab; combo grenade.smoke > hook.zip > saber.cut |
| special delivery | combo force.grip > grenade; combo hook > grenade |
| strung up | combo force.grip > whip.crack; combo hook > force.grip |
| throw and go | combo saber.throw > saber.cut; combo grab.throw > blade |
| two birds | bonus A W3; bonus B D8 |

Also one idea in two forms (a bonus row and a chain): Under-Barrel (D, Rifle) and Over-Under (`gun.explosive >
gun.rifle`); Curb Stomp (C row 10 and C29); Hooked Keg (B G1 and its chain form); F.E.A.R. Effect (Melee's award, C's
rework and the `@slow` chain); Come Get Some (A M29 and B's `taunt > hands`); Ice Breaker (B N12 and the chain).
Build one of each pair.

