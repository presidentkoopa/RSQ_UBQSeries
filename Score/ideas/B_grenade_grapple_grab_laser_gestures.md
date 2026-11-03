# RSQ Score ideas, lane B: Grenade, Grapple, Distance Grab, Laser Sight, Gestures

Written 2026-11-03 by lane B (read-only pass, no mod code changed). **Everything here is a proposal**: names, pays and
patterns are for the owner to cut or keep. Pays are multipliers of the kill's base (the monster's spawn health), on
Score's existing scale: about 0.2 to 0.5 for something you can do often, 0.9 to 1.2 for a hard three-step, 1.0 and up
only for something rare. The per-kill cap (`rs_score_cap_kill` 300 = 3x base) still holds over all of it.

"Rig only" applies to every detection claim below: facts were read from code, nothing here was run.

## Summary

| | New | Rework (stale) |
|---|---|---|
| Grapple (single-kill rows) | 8 | 3 (Boarding Party from Reeled In, Hanging Shot from Swinging, Line Drive naming) |
| Distance Grab (rows) | 7 | 2 (Bulwark Return, Gun Toss) |
| Grenade (rows) | 17 | 0 (Slow Burn kept as XP only) |
| Laser Sight | 1 (weak, likely cut) | 0 |
| Gestures | 2 (+3 cross-references to Melee moves it triggers) | 0 |
| **Named 2-tool combos** | **55** (plus 2 existing kept: Lasso, Pitch and Slice) | - |
| **Named 3-tool combos** | **27** (plus Circus Act kept) | - |
| Generic chain pay | rescaled: 0.2 / 0.45 / 0.75 / 1.0, +0.1 Cross-Mod | - |
| New tool ids for the ledger | 17 (plus group registrations for 16 ids mods already send) | - |
| Stale or wrong today | - | **24** |

The biggest section is the combos (section 6). The biggest finding is in section 8: the Grapple perks' kills
(Zip Kick, Barbed Claw, the Bowling perk, Double Hook) and the Distance Grab held-thing swing all read as **punches**
today and pay Brawler 0.5; grenades are **"gun"** in the combo ledger; and many "touch" ids that mods already send
count as extra tools, so one move pays a 2-Tool Combo by itself.

---

## 1. How this lane's tools reach Score today (the facts, read from code)

- **Grapple** (`Grapple/zscript/rsqgr/service.zs`, `RSQGR_Service` -> `RSQGR_Events.Answer`): per monster "hooked"
  (tics since on the line, 0 while on it), "hooked.by", "hooked.heavy" (you reeled to it), "bites", "volleys"
  (Ping-Pong), "yanked" (1 on the throw path, 2 flying after), "landing" (its own throw hurt it), "struck" /
  "struck.by" / "pin" (a thrown body hit it), "whipped", "stunned"; per player "swinging", "reeling", "climbing",
  "airborne", "released", "landed", "flight.dist", "flight.drop", "gaps". **The claw bites any shootable thing with
  health**, barrels included (`hook.zs` `RSQGR_Tracer`: skips players, missiles, unshootables, nothing else), and the
  ledger keeps a record for any actor it bit (`Rec`), so a hooked barrel's "hooked" / "landing" can be asked.
  Perks (`perks.zs`): `ZipTick` touches `zip.kick`, `OnArrive` touches `scorpion`, `OnBite` (Barbed Claw, Double Hook
  -> `StartSlam` / `EndSlam`), `Bowl`. Their blows go through `RSQGR_Perks.Hurt`, which sets "hook.dealing".
  Default monster mode is **Slide**; Yank and Lasso are options. Default wall mode since 11-02 is the **pull** (no
  swing; you hang still where it stops).
- **Distance Grab** (`DistanceGrab/zscript/rsqdg/throw.zs`, `RSQDG_ThrowService`): per object "throw.by", "throw.age",
  "throw.cms", "throw.blast", "throw.juggle"; per hand "hold.full". `Strike` (a thrown thing hits: object = inflictor,
  thrower = source), `Impact` (a thrown monster from Melee's Headlock takes its own landing: `DamageMobj(null,
  thrower, 'Melee')`), the blast chain (`WorldThingDied` marks barrels set off by a thrown blast). `hold.zs` ~721: a
  HELD thing swung into a monster (`DamageMobj(held, pawn, 'Melee')` + Stagger into Pain). `hold.zs` ~892
  (`ShieldTick`): a held corpse/barrel stops a missile; Body Shield 3 turns it back at the shooter (`m.target = pawn`)
  and touches `body.shield` on the shooter. Distance Grab holds **no living monster** (the Headlock is RSQ Melee's).
- **Grenade** (`Grenade/zscript/rsqgn/`): the blast is `A_Explode` called ON the thrown grenade (`thrown.zs`
  `RSQGN_Thrown.Blast`), so at the kill the **inflictor is the grenade actor** and its fields are readable: `cooked`
  (tics cooked in hand, already answered by `RSQGN_Service "cooked"`), `kind`, `sticky` / `stuckTo`, `age` (tics
  since thrown), `dmgMult` (Teeth / Skeet raise it), `fuse`, `fuseTotal`. Other inflictors: `RSQGN_HandBlast` (went
  off in the hand, `hand.zs Boom`), `RSQGN_Bomblet` (Cluster), `RSQGN_FireField` (Incendiary, `'Fire'`). Touches sent
  today: `freeze.nade`, `stun.nade`, `flash`, `smoke`, `charm`, `infight`, `fire.nade` (every 7 tics a monster burns),
  `sticky` (on the monster), and `skeet` / `teeth` / `impact` (on the grenade or the pawn: see stale). GBOVR's Slow
  Burn touches `slow.burn` from `OnKill` (`up_grenade.zs`).
  **With BD22 VR Reloaded loaded RSQ Grenade stands down**: the grenade is BD22 VR's (`rs_brutal22weaponsq
  src/zscript/rsg/grenade.zs`, `RSG_State.Throw` spawns BD's `HandGrenade`, gives it `GrenadeTime` = cooked/16;
  `HandGrenade` spawns `FragGrenadeExplosion`, five `A_Explode`s; `Boom` in the hand spawns `FragGrenadeExplosion`
  with target = the player). **The grenade is ONE move in two mods: every grenade idea below is one idea with two
  detectors**, the RSQ one (class names `RSQGN_*`, the fields above) and the BD one (`HandGrenade` /
  `FragGrenadeExplosion`; the cook needs one new answer from `RSG_Handler`, see each row).
- **Score** sees none of the grenade specially: in `combo.zs RS_Tool.Classify` a resting/detonating grenade
  (`bMissile` cleared in `Detonate`) falls through to `"gun"`; `RS_Physical.ShotKind` says SHOT_NONE, so Variety gives
  it no tool bit.
- **Laser Sight** (`LaserSight/zscript/rsqls/sight.zs`, `RSQLS_SightService`): "laser.active", "laser.beam" per hand
  (console player only), "head.on" (a dot on a monster's head, only with GBOVR Headshot Reaction 2).
- **Gestures** (`Gestures/zscript/rsqg/gestures.zs` service): "braced", "braced.tics", "still", "punch.kind",
  "shove", "pair.ago"... local player only; it acts on nothing. RSQ Melee turns its events into moves that touch
  Score: `taunt`, `pound`, `clearout` (`Melee/zscript/rsqml/twohand.zs`).

---

## 2. Grapple (a combo modifier first; these are its single-kill rows)

The owner: "Did we grapple an enemy to us? Did we grapple a barrel, throw it, and make a kill? Did we grapple an
opponent towards us and then beat their face in, or saw or saber or whip them?" The last two are combos (section 6);
the barrel and the perks need rows. Grapple's behaviour is unchanged by every idea here.

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| G1 | **Hooked Keg** | Style | Killed by the blast of a barrel your hook bit (it slid, was yanked, or its throw's landing set it off), within 3 s of the line letting go. Each further kill of that blast within 1 s adds more (like Powder Keg). The owner's "grapple a barrel... make a kill". | Kill: `ev.inflictor` is the barrel (a non-monster, `RSQDG_Mass` explode flag or simply `!bIsMonster && bShootable`). `RS_Grapple.Ask("hooked", inflictor)` <= 105 and `Ask("hooked.by", inflictor) == killerNum` (service.zs keeps records for any bitten actor). The crowd count on `RS_PhysicalNotes` like `kegKills`. Ledger: new tool `hook.keg` (Classify: inflictor has a hook record from this player). | 0.4, +0.2 per earlier kill, to 1.2 | new |
| G2 | **Special Order** | Style | A barrel you hooked to you, then caught/carried and threw with Distance Grab, killed (its hit or its blast). Two tools, one barrel. | Kill passes Thrown or Powder Keg, AND the inflictor's Grapple record (`hooked.by` = you, `hooked` <= 350). Supersedes nothing; stacks with Thrown/Powder Keg. | 0.4 | new |
| G3 | **Boarding Party** | Daring | You reeled yourself to a monster too heavy to come (a boss or heavy, the hook latched as an anchor) and killed it in melee within 2 s of arriving. | `RS_Grapple.Ask("hooked.heavy", v) == 1` + Reeled In's window; finishing blow melee (`RS_Melee.Kind`). Replaces Reeled In on that kill (bigger pay for the bigger target). | 0.6 | new (Reeled In rework) |
| G4 | **Zip Kick** | Melee | The Zip Kick (GBOVR, arriving on a monster by rope at 3+ m/s) killed it. Pays more the faster you came. | Today the kill reads as MK_FIST (see stale S1). Fix: `RS_Melee.KindOf` asks Grapple a new "zipped" (tics since `ZipTick` struck it; noted before `Hurt`, like "landing") -> new MK_ZIP. Speed: `ZipTick` already has `ms`; expose "zip.speed". Ledger: register `zip.kick` in group `hook` (it already touches). | 0.35, +0.05 per m/s over 3, to 0.6 | new (fixes a wrong Brawler) |
| G5 | **Torn Out** | Melee | Barbed Claw's tear (the claw ripped out of a living monster) killed it. | `OnLetGo` -> `Hurt(v, hook, pawn)`: needs Grapple to note "torn" before the blow; KindOf -> MK_HOOK. | 0.4 | new (fixes a wrong Brawler) |
| G6 | **Head-On** | Style | Double Hook: the two monsters slammed together and this one died of it. Both dying in the slam pays the second one more. | `EndSlam` notes "struck" both ways already; add a "slam" marker (or touch new tool `hook.slam`) so it is told from Bowling. KindOf -> MK_HOOK (today MK_FIST, stale S3). | 0.5; 1.0 when both die | new (Bowling rework) |
| G7 | **Scorpion** | Melee | GBOVR Scorpion's automatic counterpunch killed what the hook brought. | `OnArrive` touches `scorpion` before the punch lands; the kill's finishing tool is `glove`. Row: chain's last two steps `scorpion`, `glove` on one tic. Make `scorpion` ActionOf `glove` (stale S5). | 0.3 (replaces Counter on that kill) | new |
| G8 | **Hanging Shot** (Swinging split) | Daring | A kill while hanging STILL on a latched rope (the default pull mode's hang). | Today Swinging pays this (stale S6). Needs "rope.speed" or "hanging" from the service (player vel while latched); split: still = Hanging Shot, moving = Swinging. | 0.15 | rework of Swinging |
| G9 | **Rope Burn** | Daring | Killed while you are being PULLED along the rope (pull mode, in flight to the claw, not yet stopped). The "shoot on the zip line" moment. | Service: latched + `airborne` + player speed >= 6 u/tic (needs "pulling" answer, `core.zs` PullAll knows). | 0.35 | new |
| G10 | **Long Line** | Style | A hook kill (Hard Landing, Fly Ball, Bowling, Reeled In) on a monster bitten 12 m (408 units) or more away. | Needs the bite distance: `Bitten()` has `by` and `v`; add "hooked.dist". | +0.15 on top | new |
| G11 | **Line Drive** | Style | A body your hook threw struck a monster and the struck one died to your shot within 1 s (Bowling's finish-inside-1-s case, but the finisher is a gun). | Bowling already pays this case 0.5; this is the NAME for it in the breakdown when the finisher is a shot. Display-only split. | (Bowling's) | rework (naming) |

Not proposed: anything for the climb, Twin Lines or Slingshot by themselves (movement, no kill). They count only
through Swinging / Dismount / Rope Burn / Indiana Jones when a kill follows.

---

## 3. Distance Grab (objects only: barrels, corpses, guns, clips)

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| D1 | **Clubbed** | Melee | A thing you were HOLDING, swung into a monster, killed it (a barrel or corpse as a club). | `hold.zs` swing hit: inflictor = held object, source = pawn, `'Melee'`, and `RSQDG_Hold.IsHeld(inf)` true at the blow. Needs DG to answer "hold.by" for an object (it knows `held[hand]`). KindOf -> new MK_CLUB (today MK_FIST: stale S10). New tool `grab.swing`. | 0.3, +0.1 for a corpse | new (fixes a wrong Brawler) |
| D2 | **Keg Shot** | Daring | A barrel you threw, shot by you while still in the air, blew up and killed. The barrel Skeet. | Today a barrel you shoot pays nothing (Powder Keg is only for a throw's own landing). Needs DG: in `WorldThingDied` for a logged barrel still aloft (`lgAloft`) whose killer is its thrower, mark "throw.shot" (and carry it down the chain like `lgBlast`). Then: inflictor barrel, `throw.shot == 1`. | 0.8, +0.2 per further kill of that blast, to 1.4; big moment | new |
| D3 | **Chain Reaction** | Style | A barrel YOUR GRENADE set off killed it (grenade -> barrel -> body). | Barrel's death inflictor is `RSQGN_Thrown` / `FragGrenadeExplosion` from you: Score notes it in its own `WorldThingDied` (barrel, inflictor grenade, target you); kill whose inflictor is that barrel pays. Ledger tool `grenade`. | 0.4 | new |
| D4 | **Sandbag** | Style | Killed within 3 s after the corpse or barrel in your hand stopped THAT monster's shot (Riposte for the body shield). | `ShieldTick` knows the shooter (`m.target` before it is changed): needs "shielded" (tics since your held thing stopped its shot) per monster, or a touch `grab.shield` on the shooter for every stop (today only Body Shield 3 touches). | 0.35 | new |
| D5 | **Bulwark Return** (Body Shield 3) | Melee | A shot your held thing turned back killed its shooter. | Today it pays Return to Sender + Poetic Justice as a `saber.return` tool (stale S12). Keep those rows; fix the tool to `grab.shield` and give it its own breakdown name. | (Return to Sender 0.4 + Poetic Justice 0.3) | rework |
| D6 | **Gun Toss** (DG side) | Style | A floor gun you pulled and threw killed (any gun, not only a monster's drop). | Hand-Me-Down only pays a monster's drop; extend to any weapon thrown with DG (inflictor `is "Weapon"` + `throw.by`). One move with the Tactical Rig's thrown gun (`gun.toss`): ONE idea; the rig lane names it. | 0.25 | rework of Hand-Me-Down |
| D7 | **Heavy Throw** | Style | A thrown thing of 100 kg or more killed (two-hand lifts, Heavy Lift). | `RSQDG_Mass.Kg(inflictor)` (mass.zs) at the kill; add "throw.kg" to the ledger answer. | +0.15 on Thrown | new |
| D8 | **Two Birds** | Style | One throw killed two monsters (the hit and the landing, or two in its path). Barrels are Powder Keg's; this is the solid throw. | Same inflictor, two kills within 10 tics; `RS_PhysicalNotes` keeps the last thrown inflictor and a count. | 0.3 on the second, +0.15 each after, to 0.75 | new |
| D9 | **Bodycheck** | Style | A monster thrown out of RSQ Melee's Headlock (it flies through DG's throw) struck another and the struck one died of it. | Strike: inflictor = the thrown live monster, `throw.by` = you (already classified `grab.throw`). Row: inflictor `bIsMonster && health > 0`. Body Blow pays a CORPSE; this is the live body. One move (Melee's headlock, DG's throw): ONE idea. | 0.4 | new |
| D10 | **Air Catch / Thrown / Powder Keg / Body Blow / Full Hands** | - | as today | unchanged | - | keep (see S11 for the 10 s window) |

---

## 4. Grenade (RSQ Grenade, or BD22 VR's grenade when it stands down: one move, two detectors)

New tool id `grenade` for every blast. Rows read the grenade from `ev.inflictor`. For BD's grenade: inflictor
`FragGrenadeExplosion` (from `HandGrenade`); its cook needs `RSG_Handler` to remember the last throw's `cooked` per
player (or stamp it on the `HandGrenade` it spawns) and answer it by name.

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| N1 | **Frag Out** | Efficiency | Each kill by one grenade's blast after the first (a multi-kill). | Same inflictor actor, kills within 3 tics (both A_Explode parts and BD's five land over 1-2 tics). Count on `RS_PhysicalNotes` (inflictor + count + tic). | 0.2 per earlier victim, to 1.0; big moment from the 4th | new |
| N2 | **Cooked** | Daring | Killed by a grenade cooked in the hand. Pays more the less fuse it had left when thrown. | RSQ: `RSQGN_Service "cooked"` on the inflictor (exists), against `fuseTotal`. BD: needs the cook from `RSG_Handler` (above). | 0.2 at 1 s cooked, +0.1 per further half second, to 0.6 | new |
| N3 | **Airburst** | Style | The grenade went off in the air (a cooked throw timed to burst over them, not on the floor). | Inflictor `pos.z - floorz >= 24` at the kill (frozen in the event: copy at Create). Excludes Skeet (N4). | 0.35 | new |
| N4 | **Trap Shot** | Daring | Your grenade, shot by you in the air (GBOVR Skeet), killed. | `hand.zs NetworkProcess "rsqgn_skeet"` raises `dmgMult` and detonates: needs a `skeeted` flag on `RSQGN_Thrown` answered by name. Today it touches `skeet` on the grenade itself (stale S16). | 0.6; big moment | new |
| N5 | **Tagged** | Style | A Sticky grenade riding a monster killed THAT monster. | `RSQGN_Thrown.stuckTo == victim` (needs a "stuck.to" GetObject answer). | 0.35 | new |
| N6 | **Hot Potato** | Style | A Sticky grenade riding a monster killed OTHER monsters around it (it ran into its friends). | `stuckTo` set and != victim. Each such kill. | 0.4 | new |
| N7 | **Direct Hit** | Style | An Impact grenade burst on this monster (the thing it touched) and killed it. | Impact kind (`kind == IMPACT`), victim within its radius + 4 of the grenade at the blast, grenade `age` <= fuse. Needs `impact` touched on the MONSTER it hit (stale S16). | 0.4 | new |
| N8 | **Long Bomb** | Style | A grenade kill 15 m (510 units) or more from where it left your hand. GBOVR tree's `throw.far`. | Needs the throw origin on `RSQGN_Thrown` (spawn pos: add a field, or `age` x speed as a proxy). | 0.25, +0.05 per 5 m, to 0.45 | new |
| N9 | **Carom** | Style | The grenade bounced off a wall at least once before the kill (GBOVR Bounce's bank shots; tree `bank.shot`). | Needs a wall-bounce counter on `RSQGN_Thrown` (BounceType Doom: count in `Tick` when `vel.xy` turns, or override a bounce hook). | 0.3, +0.1 per extra wall, to 0.5 | new |
| N10 | **Hold My Beer** | Daring | A grenade that went off IN YOUR HAND killed a monster. If you live through it, more. | Inflictor `RSQGN_HandBlast` (BD: `FragGrenadeExplosion` whose target is you, no `HandGrenade` thrown: needs the BD hand boom marked). Survive: `killerHealth > 0` at the tic after (Commit). Swan Song may also fire if you die. | 0.5; 0.8 if you live | new |
| N11 | **Cluster Bomb** | Style | A Cluster bomblet killed it. | Inflictor `RSQGN_Bomblet`, target you. | 0.25 (Frag Out counts bomblets of one grenade together: parent link needed, bomblet.master is the weapon, so add a `parent` field) | new |
| N12 | **Ice Breaker** | Melee | A monster frozen by your Freeze grenade shattered (the x2 hit) and died, by any tool. | `freeze.nade` touched on it (kinds.zs) and the GBOVR freeze state's shatter ("shatter" touch exists in up_fists for the Frost Fist; needs the same touch from `RSQ_Dazed` for any shatter) within the freeze. | 0.5 | new |
| N13 | **Civil War** | Efficiency | A monster your Infight grenade turned killed another monster: paid to YOU (today Infighter pays everyone). | Victim's killer is a monster carrying `RSQGN_Infight` given by you (`RSQGN_Turned` keeps who): credit the thrower. | 0.4 | new (Infighter rework for this case) |
| N14 | **Turncoat** | Efficiency | A monster your Charm grenade made friendly killed a monster. | Killer carries `RSQGN_Charmed` from you. | 0.4 | new |
| N15 | **Blindside** | Daring | Killed while blinded by your Flash or Smoke grenade (it lost you and could not see you). | `flash` / `smoke` touched within the effect's length; and `victimCouldSee == false` (Curveball's fact). Replaces Curveball on that kill. | 0.3 | new |
| N16 | **Barbecue** | Style | Your Incendiary fire finished it. | Inflictor `RSQGN_FireField`, dt `'Fire'`. | 0.25 | new |
| N17 | **Teeth** | Style | A grenade whose pin you pulled with your teeth killed (GBOVR Teeth 1 "pays Score"). | `hand.zs teethPin[n]` is per player and is lost at the throw: needs a `teeth` flag on `RSQGN_Thrown` at `Throw`. (Today's `teeth` touch lands on the pawn: stale S16.) | 0.15 | new |
| N18 | **Slow Burn** | - | GBOVR's slow-mo re-pulse on a cooked kill. | Bullet Time already multiplies style in slow motion. **No row**; drop the `slow.burn` touch from the chain (it is on a dead body anyway). | - | keep as XP only |

---

## 5. Laser Sight and Gestures (checked; honest: little)

**Laser Sight.** It is an aiming aid. Its only fight-facing fact, "head.on", already feeds GBOVR's Critical Hits
Headshot, whose `headshot` touch is the Melee/GBOVR lane's to score. One idea, probably to cut:

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| L1 | **Iron Sights** | Daring | A gun kill at 20 m+ with that hand's laser off (toggled off or pointed past its cutoff). | `RSQLS_SightService "laser.active"` for the shooting hand (`RS_Physical.ShotHand`). Console player only (QZD has no netplay). Risk: a player who never runs the laser farms it; only meaningful if the laser is on by default for everyone. | 0.15 | new (owner's call; likely cut) |

**Gestures.** It reads hands and acts on nothing. What it adds to fighting:

| # | Name | Family | Trigger | Detection | Pay | Status |
|---|---|---|---|---|---|---|
| E1 | **Braced** | Efficiency | A shot kill at 20 m+ while the gun was two-handed (braced) for half a second or more. From BONUS_IDEAS. | Gestures "braced.tics" >= 18 at the shot (console player). Without Gestures: the engine's two-hand latch is not play-scope, so nothing. | 0.15 | new |
| E2 | **Freehand** | Daring | The inverse: a shot kill at 20 m+ one-handed, the other hand busy (a held thing, a rope, a grenade) or empty. So neither grip is "correct". | Not braced (E1's fact) and distance; stacks with Full Hands only if the cap allows. | 0.15 | new |
| - | Taunt, Ground Pound, Clear Out | Melee's moves, triggered by Gestures events, scored as tools `taunt`, `pound`, `clearout` (Melee already touches them). Combos using them are in section 6 (Come Get Some, Get Back!). The watch check, Measure Me, palms out: utility, never paid. | | | | cross-reference |

---

## 6. CROSS-TOOL COMBOS (the main job)

### 6.1 How patterns read

`a > b > c`: in order, last step the finishing blow, other tools may sit between (as `RS_Combo.Match` does today), no
3 s gap. Groups: `hook` (hook.bite, hook.yank, hook.keg, hook.slam, zip.kick), `grab` (grab.throw, grab.swing,
grab.keg, grab.shield, grab.hold), `grenade` (grenade and its kinds), `melee`, `hands` (kick, punch, glove,
punch.uppercut...), `force`, `shield`, `saber`, `whip`, `gun` (and `gun.<class>`). Tool ids owned by other lanes
(Melee, Whip, ShieldSaw, Saber, guns) are written as those mods send them today; where a lane renames them, the
pattern follows.

**One rule this needs first (stale S5/S9):** Reeled In, Fly Ball, Bowling and Ping-Pong are "rows that are combos";
the freshness rule (`RS_Bonus_Chain.Evaluate` step 2) blocks any table combo whose tools they already cover. So
`hook > saber.cut` can never fire while Reeled In exists. **Proposal:** Reeled In becomes the generic name for
hook > melee, and the named variants below REPLACE its base pay (its chain bonus +0.15 per earlier reel stays on top).
Same for Fly Ball (hook.yank > X in the air).

### 6.2 Grapple opens: 2-tool

The owner's "grapple an opponent towards us and then beat their face in, or saw or saber or whip them".

| Combo | Pattern | Pay | Note |
|---|---|---|---|
| **Come Here!** | hook > glove \| punch | 0.5 | the face-punch; replaces Reeled In's 0.3 base |
| **Fish Out of Water** | hook > punch.uppercut | 0.6 | uppercut what arrives |
| **Punt** | hook > kick | 0.5 | |
| **Meat Hook** | hook > blade | 0.55 | the chainsaw/axe on what arrives |
| **Harpoon** | hook > saber.cut | 0.5 | |
| **Doorstop** | hook > shield.bash | 0.5 | |
| **Sawmill** | hook > shield.saw | 0.55 | if the ShieldSaw lane splits the revved grind from the bash (`shield.saw`) |
| **Crack the Line** | hook > whip | 0.5 | RSQ Whip's crack, or the Grapple's own old whip (`whip`) |
| **Collar** | hook > grab.hold | 0.45 | hook brings it, the off hand takes the Headlock, any finisher (a Headlock kill) |
| **Hook Shot** | hook > gun.shotgun \| gun.ssg | 0.45 | point-blank shotgun on arrival |
| **Reel and Deal** | hook > gun | 0.3 | any other gun on arrival |
| **Bungee** | hook > force.push | 0.5 | pulled in, Force-pushed out to its death (Slammed / Ring Out may stack) |
| **Strung Up** | hook > force.grip | 0.5 | |
| **Special Delivery** | hook > grenade | 0.6 | yanked or slid into your grenade's blast |
| **Tether Ball** | hook > grab.throw | 0.45 | a thrown barrel finishes what you hooked |
| **Disc Golf** | hook > shield.disc | 0.45 | hook it out of cover, then the disc |
| **Swoop** | zip.kick > melee | 0.6 | Zip Kick in, finish by hand or blade |
| **Drop In** | zip.kick > gun | 0.45 | |
| **Get Down** | hook > pound | 0.55 | yank it to your feet, Ground Pound (Melee) |
| **Hooked Keg** (chain form) | hook.keg > any | 0.4 | the barrel's blast wounded it, anything finished it; the kill-by-blast case is row G1 |

### 6.3 Into the hook (the hook as the link or finisher): 2-tool

| Combo | Pattern | Pay | Note |
|---|---|---|---|
| **Catch of the Day** | punch.uppercut > hook.yank | 0.6 | launched, then yanked out of the air to its death (Hard Landing or Fly Ball) |
| **Rebound** | force.push > hook.yank | 0.5 | pushed away, hooked back, the yank kills (Ping-Pong needs two bites; this is one) |
| **Lasso** | whip > hook.yank | 0.5 | exists |
| **Bait and Hook** | grab.throw > hook | 0.45 | a thrown thing staggers it, the hook takes it (Hard Landing / Reeled In finish) |
| **Snatch** | grenade.stun \| flash > hook | 0.5 | stunned or blinded, reeled in |
| **Ice Fishing** | freeze.nade > hook.yank | 0.7 | a frozen monster yanked; the landing shatters it (x2) |
| **Turnabout** | shield.block \| saber.block > hook | 0.5 | blocked its attack, hooked it in (Riposte covers block > X: this is the hook variant, replaces Riposte's base) |

### 6.4 Distance Grab opens: 2-tool

| Combo | Pattern | Pay | Note |
|---|---|---|---|
| **Pitch and Slice** | grab.throw > saber.cut | 0.5 | exists |
| **Batter Up** | grab.throw > gun | 0.35 | thrown thing staggers it, shot finishes |
| **Brickbat** | grab.throw > glove \| punch | 0.45 | throw, then close and punch |
| **Follow Through** | grab.throw > kick | 0.45 | |
| **Shot Put** | grab.throw > shield.disc | 0.45 | |
| **Throw and Go** | grab.throw > blade | 0.5 | |
| **Strike Two** | grab.throw > grab.swing | 0.45 | throw one thing, club with the other hand's |
| **Batting Practice** | grab.swing > gun | 0.4 | clubbed with a barrel, then shot |
| **Swing and Let Fly** | grab.swing > grab.throw | 0.5 | club it, then throw the club at it |
| **Aftershock** | grab.keg > melee | 0.5 | charge into the smoke of your thrown barrel and finish by hand |
| **Sandbag Riposte** | grab.shield > gun | 0.4 | the held body took its shot, you shot back (the combo form of D4) |
| **Sandbag Slash** | grab.shield > saber.cut \| blade | 0.5 | |
| **Bodycheck** (chain form) | grab.hold > grab.throw | 0.5 | Headlock, then throw it to its death (a Headlock throw kill; Melee's headlock + DG's throw = one move pair) |
| **Hot Seat** | force.push > grab.keg | 0.5 | pushed onto the barrel you then threw/blew |

### 6.5 Grenade opens or links: 2-tool

| Combo | Pattern | Pay | Note |
|---|---|---|---|
| **Mop Up** | grenade > gun | 0.3 | the blast wounded it, the gun finished |
| **Into the Breach** | grenade > melee | 0.45 | run into the smoke and finish by hand, blade or saber |
| **Stun and Gun** | stun.nade > gun | 0.45 | |
| **Stun and Saw** | stun.nade > blade \| shield.saw | 0.55 | |
| **Lights Out** | flash > melee | 0.5 | it cannot see you; you walk up and finish it |
| **Out of the Smoke** | smoke > melee | 0.5 | |
| **Cold Cut** | freeze.nade > saber.cut \| blade | 0.6 | shatter with a blade |
| **Ice Breaker** (chain form) | freeze.nade > hands \| shield.bash | 0.6 | shatter with a fist or the shield (row N12 is the single kill) |
| **Into the Fire** | fire.nade > force.push | 0.5 | pushed back into your fire (the kill by fire or by the push) |
| **Flush Out** | grenade > hook | 0.5 | the blast drives it out of cover, the hook takes it |
| **Hog-Tied** | bola \| lasso > grenade | 0.55 | RSQ Whip's bola or lasso holds it, your grenade lands at its feet |
| **Shield Up** | shield.block > grenade | 0.4 | blocked it behind the shield, then the grenade it never saw coming |
| **Get Back!** | clearout > grenade | 0.5 | Melee's Clear Out shoves them away, the grenade follows |
| **Come Get Some** | taunt > hands | 0.4 | Melee's Taunt turns it on you, the doubled punch kills (gesture-driven) |
| **Pin Cushion** | sticky > gun | 0.45 | tagged with a Sticky grenade, then shot before it blew |

### 6.6 Three-tool chains

| Combo | Pattern | Pay | Note |
|---|---|---|---|
| **Scorpion Sting** | hook > scorpion > melee | 1.0 | hook, the automatic counter, then your own finisher |
| **Finish Him!** | hook > hands > finisher | 1.1 | hooked in, punched, Brutal Doom fatality |
| **Kite** | hook > punch.uppercut > hook.yank | 1.1 | hook in, uppercut up, yank it down out of the air |
| **Ringmaster** | whip > hook > shield.bash | 1.0 | Lion Tamer with a hook between |
| **Hang the Meat** | hook > kick > blade | 1.0 | |
| **Collar and Pound** | hook > grab.hold > hands | 1.0 | hook, Headlock, punch (Headlock combo + hook) |
| **Catch and Release** | hook > grab.hold > grab.throw | 1.0 | hook, Headlock, throw it to its death |
| **Reel and Hurl** | hook > shield.bash > shield.disc | 1.0 | |
| **Grappling Strike** | hook.heavy > zip.kick > saber.cut | 1.2 | reel yourself to the big one, zip-kick it, cut it down (needs G3's `hooked.heavy` as a step) |
| **Over Here, Over There** | hook > force.push > gun | 0.9 | pull in, push out, shoot in flight (Yo-Yo with the hook) |
| **Strung Out** | hook > force.grip > gun | 0.9 | |
| **Deep Freeze** | freeze.nade > hook.yank > hands | 1.2 | freeze, yank, shatter by hand |
| **Butcher Shop** | stun.nade > hook > blade | 1.1 | |
| **Blind Date** | flash > grab.hold > hands | 1.0 | Headlock a blinded monster and pound it |
| **Smoke and Mirrors** | smoke > zip.kick > saber.cut | 1.2 | out of the smoke on the rope |
| **Hot Potato** | sticky > hook > grenade | 1.2 | tag it, yank it into its pack, it goes off there |
| **Return Address** | force.pull > sticky > force.push | 1.2 | pull it in, stick a grenade on it, push it home (the kill by the blast) |
| **Kitchen Sink** | grab.throw > grenade > gun | 1.0 | everything you can throw, then the gun |
| **Shield and Sword** | grab.shield > grab.throw > saber.cut | 1.0 | the body took its shot, you threw the body, then cut |
| **Batter, Pitcher, Catcher** | grab.throw > force.push > gun | 0.9 | |
| **Bait and Switch** | grab.throw > hook > melee | 1.0 | |
| **Fetch!** | hook.keg > grab.throw > gun | 1.0 | your hooked barrel's blast, a thrown thing, then the gun (or with G2: hook the barrel, throw it, shoot the survivor) |
| **Demolition** | grenade > grab.keg > gun | 1.0 | grenade, barrel, gun: three blasts' worth |
| **Bowling for Keeps** | hook.slam > grab.throw > gun | 1.0 | Double Hook slam, a thrown thing, shot |
| **Ice Sculpture** | freeze.nade > grab.throw > shield.bash | 1.1 | frozen, staggered by a throw, shattered by the shield |
| **Swat Team** | flash > hook > gun.shotgun \| gun.ssg | 1.0 | blind it, reel it, shotgun |
| **Circus Act** | whip > hook.yank > gun | 0.9 | exists |
| **Get Back, Get Over Here** | clearout > hook > hands | 1.0 | shove them all off, hook one back, punch |

### 6.7 Guns by class, slow motion, and the generic pay

- **Guns by class.** Propose the ledger names the gun: `gun.pistol`, `gun.shotgun`, `gun.ssg`, `gun.rifle`,
  `gun.minigun`, `gun.rocket`, `gun.plasma`, `gun.bfg`, `gun.flamer`, read in Classify from the striking weapon
  (the BD lane parses the BD22 class families), with group `gun` so every existing `> gun` pattern still matches.
  Varying gun classes inside one chain stays Switcharoo's (not a new tool for the generic count).
- **Slow motion.** Bullet Time already multiplies style (50 %); a slow-motion copy of each combo would double-pay.
  Proposal: no slow-motion combos, except that a 3-tool named combo finished in slow motion counts as a big moment
  even without 4 tools. SlowMo's own `lean` (lean dodge) touch can be a step: **Matrix** `lean > gun` 0.4 (the
  SlowMo lane names it).
- **Generic pay scaling** (today 0.2 / 0.4 / 0.6): **2 tools 0.2, 3 tools 0.45, 4 tools 0.75, 5+ tools 1.0**. The
  steps grow because each extra tool is harder in 3 s. Plus **Cross-Mod +0.1** when the chain's tools come from three
  or more different mods (hook + grenade + saber), once per kill. The per-kill 3x cap keeps it bounded.
- **Named pay bands** (for the naming pass): plain 2-tool 0.3-0.5; 2-tool with a status or air/hard step 0.55-0.7;
  3-tool 0.9-1.1; 3-tool with a timing feat (freeze shatter, heavy reel, smoke, sticky) 1.2.

### 6.8 Tool ids the ledger needs

New (Score's Classify or the owning mod's touch):

| Tool id | What | Source |
|---|---|---|
| `grenade` | any blast of your grenade (RSQ or BD) | Classify: inflictor `RSQGN_Thrown` / `RSQGN_HandBlast` / `RSQGN_Bomblet` / `HandGrenade` / `FragGrenadeExplosion` |
| `grenade.fire` | Incendiary burn | register today's `fire.nade` -> group grenade (or rename) |
| `hook.keg` | a barrel your hook bit blew up on it | Classify: inflictor has a Grapple record from this player |
| `hook.slam` | Double Hook's slam | Grapple `EndSlam` touch |
| `hook.heavy` | you reeled yourself to it (anchor) | Poll: `hooked.heavy == 1` noted instead of `hook.bite` |
| `grab.swing` | a held thing swung into it | Classify: inflictor held by this player (DG "hold.by") |
| `grab.keg` | a barrel your throw set off | Classify: `throw.blast == 1` (split from `grab.throw`) |
| `grab.shield` | your held thing stopped its shot / turned it back | DG `ShieldTick` touch (rename `body.shield`, touch on every stop) |
| `gun.<class>` x9 | the gun by class | Classify (above) |

Group registrations for ids mods already send (`RS_ScoreRegistry.RegisterTool`, from each mod's OnRegister or the
service's "tool" request): `zip.kick` -> hook; `scorpion` -> hands, ActionOf glove; `freeze.nade`, `stun.nade`,
`flash`, `smoke`, `charm`, `infight`, `fire.nade` -> grenade; `sticky`, `skeet`, `impact`, `teeth` -> grenade,
ActionOf grenade (modifiers, not tools); `body.shield` -> grab; `taunt`, `pound`, `clearout` -> hands (Melee's lane
confirms).

**A modifier rule** (new, needed by every lane): a touch that describes HOW a blow landed (uppercut, scorpion,
sticky, skeet, teeth, zip on a hook) must be ActionOf the blow it rides, so it can be named in a pattern but never
counts as an extra tool by itself. `RS_Tool.ActionOf` today only knows `hook.yank`.

---

## 7. Notes for the naming pass

- Several names collide with things that exist: "Get Over Here" and "Bowling" are GBOVR nodes (so the combo is
  "Come Here!"); "Skeet" is Score's victim-in-the-air row (so the grenade one is "Trap Shot"); "Bank Shot" is the
  ShieldSaw's (so the grenade one is "Carom"); "Return to Sender" is taken (so "Return Address").
- Reachability: Hard Landing, Fly Ball and the base Bowling need Monster Hook = Yank or Lasso (the default is Slide)
  or the GBOVR Bowling perk. Say so in Score's README so the owner is not surprised.

---

## 8. STALE OR WRONG today (Score bonuses and ledger facts for these mods)

| # | What | Why it is wrong now | Where | Fix |
|---|---|---|---|---|
| S1 | **Zip Kick kills pay Brawler 0.5** (+ Knockdown / Counter) | `ZipTick` hurts with inflictor = the pawn, `'Melee'`; `RS_Melee.KindOf` only knows the hook's blows with NO inflictor, so it is MK_FIST | Grapple perks.zs `ZipTick`; Score melee.zs `KindOf` | G4 |
| S2 | **Barbed Claw bite/tear kills pay Brawler** | inflictor = the hook actor, `'Melee'` -> MK_FIST | perks.zs `OnBite` / `OnLetGo` | G5 |
| S3 | **Double Hook and the Bowling perk pay Bowling + Brawler** | inflictor = the other monster / the thrown body -> MK_FIST, while "struck" makes Bowling fire too | perks.zs `EndSlam`, `Bowl` | G6, MK_HOOK when "struck" == 0 whatever the inflictor |
| S4 | **Zip Kick counts as two tools** | the blow classifies `hook.bite` (hook.dealing) and the perk touches `zip.kick`: one move = 2-Tool Combo 0.2 | perks.zs `ZipTick`; combo.zs `Classify` | register + ActionOf |
| S5 | **Scorpion counts as an extra tool** | glove blow + `scorpion` touch: hook > glove > scorpion > gun reads as 4 tools (0.6 + big moment) | perks.zs `OnArrive` | ActionOf glove |
| S6 | **Swinging pays for hanging still** | since 11-02 the default is the pull: you hang still on a latched rope, "swinging" answers 1 whenever latched and off the floor. Hang from a ceiling and shoot: +0.35 Daring every kill | service.zs `Answer "swinging"`; hook.zs `RS_Bonus_Swinging` | G8 split |
| S7 | **Dismount pays for a plain drop** | pull mode's let go drops you with no speed; a kill within 1 s of landing still pays 0.4 | hook.zs `RS_Bonus_Dismount` | require release speed >= 6 u/tic (needs a "released.speed" answer) |
| S8 | **Indiana Jones measured only with the swing** | the pull crosses gaps too; thresholds unmeasured in pull mode | service.zs `Landed` | re-measure (README already says so) |
| S9 | **Reeled In blocks every hook > melee named combo** | freshness rule in `RS_Bonus_Chain.Evaluate`; one flat 0.3 for a punch, a saw or a saber alike | combo.zs, hook.zs | 6.1 rework |
| S10 | **Swinging a held barrel/corpse pays Brawler 0.5 + Knockdown** | inflictor = the held thing, never thrown, `'Melee'`; DG's Stagger puts it in Pain -> Knockdown; ledger says `punch` | DG hold.zs ~721; melee.zs `KindOf` | D1 |
| S11 | **Thrown's 10 s memory** | a barrel thrown, picked up again and swung within 10 s reads as a throw (Thrown) | DG throw.zs `Ask` | after S10's "hold.by", held wins |
| S12 | **Body Shield 3 return kills are a `saber.return` tool, plus `body.shield`** | the turned missile is "born of a monster" -> saber.return; the touch on the shooter makes it a 2-tool chain for one move | DG hold.zs `ShieldTick`; combo.zs `Classify` | D5 |
| S13 | **Headlock-throw landing kills pay as a punch** | DG `Impact`: `DamageMobj(null, thrower, 'Melee')` on the thrown monster -> MK_FIST / `punch`. One move in two mods (Melee holds, DG throws) | DG throw.zs `Impact` | DG notes "landing" for it (or Melee's lane names it); KindOf -> MK_THROW |
| S14 | **Grenade blasts are "gun" in the ledger** | `Detonate` clears `bMissile`, Classify falls to `gun`: grenade > gun is ONE tool, no combo | combo.zs `Classify` | `grenade` tool |
| S15 | **Variety ignores grenades** | ShotKind NONE, not thrown, no bit | hook.zs `RS_Bonus_Variety.Tools` | add T_GRENADE |
| S16 | **Grenade's `skeet`, `teeth`, `impact` touches go nowhere** | `skeet` is touched on the grenade actor, `teeth` and `impact` on the pawn; the ledger is per monster, so they never join a chain | Grenade hand.zs `NetworkProcess`, thrown.zs `Tick` | flags on the grenade read at the kill (N4, N7, N17) |
| S17 | **Incendiary makes one grenade a 2-tool combo** | the blast is `gun`, then `fire.nade` touched every 7 tics: gun > fire.nade = 2-Tool 0.2 | kinds.zs `RSQGN_FireField` | group + ActionOf |
| S18 | **The kinds' ids are separate tools** | `freeze.nade`, `stun.nade`, `flash`, `smoke`, `charm`, `infight` have no group: a Stun grenade then its own blast = 2 tools | kinds.zs `Effect` | register in `grenade` |
| S19 | **Infight/Charm kills pay everyone Infighter** | your Infight/Charm grenade's work pays as monster-on-monster to all players | Score Infighter; kinds.zs `RSQGN_Turned` | N13, N14 |
| S20 | **BD22 VR's grenade has no cook fact** | `RSG_State.Throw` turns the cook into `GrenadeTime` on the projectile and keeps nothing a scorer can ask | rs_brutal22weaponsq rsg/grenade.zs | one service answer |
| S21 | **`slow.burn` touch on a dead body** | GBOVR `OnKill` touches the victim after its death: harmless noise in the ledger | up_grenade.zs `RSQ_Upgrade_SlowBurn` | drop the touch |
| S22 | **The README's Distance Grab rows say nothing of the Headlock or Body Shield** | Full Hands/Thrown text is from 10-27; the Headlock moved to Melee 11-01, Body Shield became a GBOVR unlock | Score README | text |
| S23 | **Hooked barrels are invisible** | the ledger only polls monsters (`WorldThingDamaged` needs `bIsMonster`); Grapple's barrel record is never read | combo.zs | G1, `hook.keg` |
| S24 | **Reeled In / Hard Landing never checked with the pull or the Slide default** | Score's hook rows were measured with Yank and the swing (README) | hook.zs | re-measure |
