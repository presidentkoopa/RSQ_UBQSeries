# Training Room: the challenges (design only)

Read-only study of `/home/claude/wt_fix2`, 2026-11-27. Nothing was changed, built or run. "README Mod:N" means line N of
`Mod/README.md` (the Do / Get / Needs rows, written from code). `file:line` is code. **[gap]** marks something no mod can
measure today. Siblings: `architecture.md` (the hub pad, the 16 x 8 grid of 64u cells, floors 0..256, ceiling 512,
spawn MapSpots on cell centres), `teaching.md` (CUE, SHOW, TRY, CONFIRM). This file is the content of each station.

## 0. What every challenge assumes

- **Controls are RSQoopaControls** (`design/controls/rsq_standard_controls.ini`). The modifier is the right grip. Off
  trigger is `+oh_attack`. Pad X is the ShieldSaw. R stick click is the hook, and modifier + R stick click is the Wheel.
  Modifier + R stick up is the Quick Grenade (`+user1`). L stick click is SlowMo, and modifier + L stick click is Crisis
  Dive. Pad A is Use, pad B is Recenter Torso. Pad Y is next item, and modifier + Pad Y is use item.
- **The owner's decision (17:00), and the code agrees.** The ShieldSaw locks on with the off hand's own trigger, and a
  forward flick of the off arm throws it (`ShieldSaw/zscript/ssq/state.zs:1539`: "the off hand locks on now";
  `state.zs:838`, `shield.zs:127` read `BT_OFFHANDATTACK`; README ShieldSaw:17,21). The same press also revs the saw. So
  sweeping across a monster in reach while you lock also grinds it.
- **Gun Bonsai VR gates nothing today.** Its service answers `loaded` 0 always, and "RSQ ShieldSaw ... RSQ Saber ... RSQ
  Grenade ... play as without this mod" (README GunBonsaiOffhandVR:116-128,142). ShieldSaw's own code takes 5 locks
  whenever the patch is not "on" (`ShieldSaw/zscript/ssq/disc.zs:118-122`). README ShieldSaw:200's "a throw rings 1
  monster until Lockstep" and `teaching.md` 9.2's note are therefore not current. Raise 3-5 targets, not 1.
- **Monsters** are named by Doom's class. They are spawned with replacement, so Brutal Doom 22 puts in its own:
  ZombieMan -> RifleZombie, DoomImp -> Imp, Demon -> BullDemon, Fatso -> Mancubus (from the BD22 `replaces` lines quoted
  in `design/`). Doom's own numbers, health / mass: ZombieMan 20/100, ShotgunGuy 30/100, DoomImp 60/100, ChaingunGuy
  70/100, Demon 150/400, LostSoul 100/50, Cacodemon 400/400, Revenant 300/500, HellKnight 500/1000, BaronOfHell
  1000/1000. BD22's own: RifleZombie 40, Imp 80 (`design/` tiering notes). These numbers are not measured here.
  **Measure them on the rig before a pass threshold depends on them.**
- **Three channels report a pass, and no mod changes for any of them:**
  (a) **services in play.** A room controller can read these in the headset: `RSQGR_Service` g2.*,
  `RS_ScoreService` kill.serial / kill.chain / kill.style, `RSQTR_RigService` rig.*, `RSQGC_GCopyService` inspect,
  `UBQS_SaberService`, `SSQ_ScoreService`, `RSQSM_Service`, `RSQMB_Service`. The room can also offer its own
  `...GrabEventService` (Distance Grab tells it every lock, pull, catch and throw, README DistanceGrab:224) and its own
  `...RSQDownJoin` (SlowMo tells it down.start / down.up / down.fail, README SlowMo:282).
  (b) **the Score row line, on the rig.** With `rs_score_debug 1` every kill prints `RS_Score[killer]: <class> ... |
  <Row> <mult>` for each row that paid (`Score/zscript/rsscore/handler.zs:848-869`, `bonus.zs:90`: the row's display
  name). Awards print `RS_Score: award <label> paid <n>` (`handler.zs:952`).
  (c) **each mod's debug line, on the rig** (`ssq_debug`, `rsqgr_debug`, `rsqwp_debug`, `rsqml_debug`, `rsqgn_debug`,
  `rsqdg_debug`, `rsqmb_debug`, `rsqtr_messages`, `developer 1` for SlowMo's rounds). PlayLog's `RSQLOG KILL / SWING /
  WRIST / HURT` lines run beside all of them (README PlayLog).
- **What success says:** first, the words the mods already show (KICK!, COUNTER!, REVIVE!, REVENGE!, BOSS DEFEATED!,
  1UP, REMOTE DOWN). Then the room's own line through VisualRewards' existing `RSQVR_Service` "toast" / "worldword".
  Score pays its own rows by itself. The room adds no Score row (see the gap in §5).

---

## 1. The challenges, in skill order

Each station has three steps. **L** learn (held targets, one move), **U** use (live targets, the move under pressure),
**M** master (the move inside a chain, scored by name). Cells and heights follow `architecture.md`: P0 = 0, P1 = 64,
P2 = 128, P3 = 256.

### C1. Report In: recenter and the watch (Tactical Rig, Gun Cards)
- **Room:** hub only. A pistol is in the main hand, the off hand is empty, and one yellow key lies in an alcove (Distance Grab can pull it later).
- **Goal:** recenter the torso (pad B, or both hands at the chest for 0.4 s, README TacticalRig:45). Check the watch with the
  gun hand for the Weapon card, then with the empty hand for the Status card (README GunCards:19-21).
- **Pass:** `RSQGC_GCopyService` "inspect" (hand) = 1 for hand 0 with a gun, then for hand 1 empty. PlayLog writes a `WRIST`
  line. The recenter is `RSQTR_BodyService` "body.yaw" moving to the head's yaw.
- **L** both checks. **U** empty the magazine and check the watch on RELOAD (big number red, README GunCards:16-17), then
  reload. **M** take the key and confirm its lit icon on the Status card.
- **Says:** the cards themselves; toast `REPORTING IN`.
- **[gap]** The watch check is a pose only ("no box, no stillness ... names nothing", README GunCards Limits). The room
  cannot know the card was read, only that the wrist turned.

### C2. Quick Draw (Tactical Rig holsters)
- **Room:** 3 ZombieMan on P1 cells 6-8 cells out, rising one at a time. Pistol and shotgun given.
- **Goal:** holster the gun in the hand and draw the other. The main hand uses **Use (pad A)** in the holster. Its grip is the
  modifier and sends no key (README TacticalRig:9,15-16). The off hand uses its grip (README TacticalRig:17).
- **Pass:** `rig.drawtic` (hand) changes and `rig.drawn` names the gun. **Score rows:** Quick Draw (kill within 42 tics of a
  draw, README Score:165), Hot Swap (:166), Armory (:169).
- **L** one holster and one draw, no target. **U** Quick Draw on each of 3 zombies. **M** Armory: three guns, each just
  drawn, three kills inside 6 s.
- **Says:** Score's Quick Draw / Armory rows; toast `QUICK DRAW`.

### C3. Loadout: the Wheel, the holster web, inventory (Wheel, Tactical Rig, ShieldSaw, Grenade)
- **Room:** hub. Shotgun, pistol, grenade and ShieldSaw given. No monsters until M.
- **Goal:** open the Wheel (modifier + R stick click). Put a gun in the off hand with off alt fire on its card (README Wheel:21).
  Assign the shotgun to a hip with main alt fire on the card and then trigger on a ring (README Wheel:180). Mount the
  ShieldSaw on the off shoulder, its only legal ring (README ShieldSaw:40). Pick a grenade kind from the fan.
- **Pass:** `RSQTR_RigService` "rig.locked" (shotgun class) >= 0. "rig.locked" ("SSQ_ShieldSaw") = the off shoulder.
  `rig.owner` (place) names the gun. The Rig's `T_ASSIGN` line with `rsqtr_messages 1`.
- **L** one assignment. **U** the full loadout of 2 hips, the shoulder shield and one grenade kind, then draw each from the body.
  **M** 4 imps rise: kill them using only body draws, with no Wheel open (Armory or Hot Swap pays).
- **Says:** the web's mirror (Web View: Mirror); toast `LOADOUT SAVED`.
- **[gap]** "Inventory management" has no series content. The Wheel has "no inventory page" (README Wheel Limits). No
  series item sits on the engine's inventory bar that pad Y / modifier + pad Y cycle and use. Champions' item bundles are
  the only candidate found (README Miniboss:50), and they are not verified.

### C4. Reach (Distance Grab)
- **Room:** ammo and health on P2 pedestals 6-12 m away. Two barrels in the hub. 2 DoomImp on P1 at 10 m. A palm switch.
- **Goal:** turn the palm out, lock, flick the wrist to pull, and catch with the palm out (README DistanceGrab:17,19). Carry a
  barrel and throw it at a locked imp (:24,39). Flip the switch with the palm (:46), which is the gesture every later
  station starts with.
- **Pass:** the room's own GrabEventService hears "grab.event" lock / pull / catch / throw / hit (README DistanceGrab:224).
  **Score rows:** Thrown (README Score:156), Powder Keg (:157), Air Catch (:158), Full Hands (:159).
- **L** pull and catch 3 pickups. **U** a barrel to a locked imp (Powder Keg). **M** Air Catch: throw, re-catch in the air,
  throw again, and kill.
- **Says:** AMMO FULL / HEALTH FULL toasts on a refused catch; the Powder Keg row.

### C5. Brawler: punch combos and the barrel uppercut (Melee)
- **Room:** fists only (the Wheel's fist card). 3 ZombieMan, 1 DoomImp, 2 barrels, all on P0 in the open.
- **Goal:** jab, hook, uppercut (README Melee:16-19). Paint an imp with the fist's trigger held, then uppercut a barrel at it
  (README Melee:24-25). Punch a switch line (it works as Use).
- **Pass:** **Score rows:** Textbook (jab, jab, hook inside 1 s, README Score:90), Triple Threat (jab, hook, uppercut :91),
  Field Goal (:107), Shoryuken, Flurry. `rsqml_debug 1` names each punch kind. `RSQML_Service` "punch.kind".
- **L** one of each punch on a held zombie. **U** Textbook and then Triple Threat. **M** Field Goal and Counter (punch an imp
  in its attack frames) in one wave.
- **Says:** POW! / COUNTER! / FATALITY! (VisualRewards words, README Melee:20-21; switch line :23); the rows.

### C6. Headlock (Melee, with Distance Grab's throw)
- **Room:** 2 DoomImp (mass 100) close together on P0, plus 1 HellKnight (mass 1000) as a "can't take it" lesson.
- **Goal:** off grip with the palm within 0.30 m of a monster (README Melee:36, Heaviest 400). Hit it three times with the main
  hand, and the third throws it (:39). Or swing the off hand across and throw it into the other imp.
- **Pass:** `RSQML_Service` "headlock.holding" / "headlock.by". `rsqml_debug 1`: "RSQML headlock: holding ...", "headlock
  combo: third blow" (`Melee/zscript/rsqml/*.zs`). **Score rows:** Toss (README Score:96), Bowling (:115).
- **L** grab and release. **U** the three-hit combo. **M** Bowling: the thrown imp kills the other.
- **Says:** the rows; Bowling is a big moment (SlowMo's short slow).
- Human Shield is off by default (README Melee:53). Teach it only if the owner turns it on.

### C7. Frag Out: grenade kinds (Grenade, Tactical Rig grenade spot, Wheel fan)
- **Room:** 5 ZombieMan grouped on P1, 2 DoomImp apart on P2, and a barrel chain of 5 barrels under an opening to the sky
  (a mega blast every 3rd barrel, README Grenade:44-45).
- **Goal:** take one from the buckle (pad A, README TacticalRig:30). Pull the pin by ring or by teeth (README Grenade:20,22).
  Cook it (:24). Cycle the kind with alt fire (:31). Shoot your own grenade in the air (:41). Use the Quick Grenade too (:17).
- **Pass:** `RSQGN_Service` "teeth" / "skeet" / "cooked" / "turned.by" on the thrown grenade (README Grenade:164).
  **Score rows:** Teeth (README Score:179), Cooked (:170), Trap Shot (:178), Pin Pulled (:168), Civil War (Infight or
  Charm, :175), Blindside (:176).
- **L** ring pull, throw, Frag on the group. **U** teeth, cook 1 s, Airburst. **M** Trap Shot plus Civil War in one wave.
- **Says:** the type's name popping on the grenade (VisualRewards); the gold skeet burst; the rows.

### C8. Lash (Whip)
- **Room:** 4 ZombieMan in an arc 2 m out (Wide Swing reach 2.6 m), 3 DoomImp clustered 3-4 m away on P0, and 1 HellKnight
  (mass 1000: the shockwave only makes it flinch).
- **Goal:** a wide level swing (70 degrees in 1/5 s, 2 m/s or more, README Whip:17). A ground crack (1.6 m/s down, then stop
  dead, :19), then shoot the lifted imps before they land.
- **Pass:** `rsqwp_debug 1`: `T_WPW ... WIDE SWING ... N hit`, `GROUND CRACK`, `IMPACT ... N thrown up`
  (`Whip/zscript/rsqwp/*.zs`). **Score rows:** Lashed (README Score:151), Wide Swing (2+ kills, :152), Ground Crack
  (kill while airborne within 2 s, :153).
- **L** one wide swing, then one crack. **U** Ground Crack on 2 imps. **M** Wide Swing 3 kills (a big moment from the third).
- **Says:** SlowMo's half-second / one-second slows (README Whip:18,24); the rows.

### C9. Remote: the saber (Saber)
- **Room:** open floor (the remote circles 56-300 units away). Later 5 DoomImp on P1-P2 spread across 40 degrees.
- **Goal:** Training Remote (`netevent ubqs_remote`, README QuestSaber:53): turn 4 bolts back within 30 s for REMOTE DOWN
  (:54). Then hold the saber's trigger to mark up to 5 and **let go with the arm moving** to throw (:31-32).
- **Pass:** **awards** Deflect and Remote Down (`RS_Score: award Deflect paid n`, README Score:128-129). `UBQS_SaberService`
  "blocked" / "perfect" / "thrown.leg". **Score rows:** Hurled (:130), Boomerang (:138), Twin Blades (:119).
- **L** one remote round. **U** two rounds in a row (the remote rises harder each time). **M** marked throw of 3+, then
  Boomerang (a kill on the way out and on the way home).
- **Says:** REMOTE DOWN, then TRAINING OVER with rounds, best streak and points (the Saber's own).
- **Teach the contrast with C10:** the saber throws on the **trigger's let-go**, and the ShieldSaw throws on a **flick with no
  button**.

### C10. Disc: the ShieldSaw (owner's 17:00 layout)
- **Room:** 5 DoomImp on P1 pedestals in a 40 degree fan at 8-15 m (lock cone 25 degrees, range 1200 units, README
  ShieldSaw:17). 1 Cacodemon (400 hp: the disc embeds). 1 BaronOfHell (1000: a glance) on P0. Imps fire (blocking).
- **Goal:** pad X draws the shield. Block and perfect-block a fireball (README ShieldSaw:28,32). **Hold the off trigger and
  sweep the shield across the targets to ring them** (:17). **Flick the off arm forward, 2.2 m/s or more** (:21). Hold the
  off hand out for the catch (:27).
- **Pass:** `ssq_debug 1`: `ssq: p0 THROW speed ... locks N` (`state.zs:1040`), `ssq: p0 disc home, CAUGHT` (`state.zs:1050`),
  `ssq: perfect block of DoomImpBall's shot` (`guard.zs:570`). In play: `SSQ_ScoreService` "blocked" / "perfect" /
  "thrown.leg". **Score rows:** Clean Sweep (2+ locks, the last one killed, README Score:142), Hurled (:130), Perfect
  Riposte (:133), Return to Sender (:134), Bank Shot (:143).
- **L** ring 3 held imps, throw, catch. **U** 5 rings, Clean Sweep, catch. **M** perfect block, then a throw that kills on the
  way home (Boomerang), with the disc embedding in the caco.
- **Says:** the rings' ticks and the catch buzz; Clean Sweep is a big moment.
- **Notes:** BD22's Imp (80 hp) is over the Bisect Limit (70), so it embeds instead of being cut in two unless "BD22
  Monsters" is on (README ShieldSaw:107,142). Pick the targets after measuring. The rig check passed lock-on with the
  **main** hand (`design/rigcheck_2026-11-27/ShieldSaw.md` row 4). The off-hand lock is compiled, not re-verified, and this
  station is its re-check.

### C11. Hook: the grapple (Grapple)
- **Room:** a P2 ledge 10 m out (its face within 40u of the top bites as a ledge, README Grapple:16). A P3 wall. 3 ShotgunGuy
  standing on P1 cells 6-15 m apart. 1 Demon on P0 for the air spike. Ceiling 512 (the kick-off rises 1.5 m).
- **Goal:** off hand aims, R stick click fires (README Grapple:12). Hook the ledge (:16), hook a monster and kick it (:17), chain
  kicks before landing (:24), then the air spike with both hands down (:18).
- **Pass:** `RSQGR_Service` "g2.last" "ledge.land", "kick", "kick.kill", "spike.land"; "g2.chain.best" >= N
  (`Grapple/zscript/rsqgr/service.zs:28-46`). `rsqgr_debug 1`: `bite: LEDGE LIP`, `KICK n: ...`. **Score rows:** Kick
  (README Score:154), Air Spike (:155, needs RSQ Grenade), Air (:45), Death from Above (:69).
- **L** ledge, then one kick on a held ShotgunGuy. **U** a 3-kick chain (g2.chain.best >= 3). **M** chain into an air spike
  that kills (Air Spike row).
- **Says:** KICK!, KICK! x2 ... (VisualRewards, README Grapple:90); "Chain Cancelled!" on a failed hang.

### C12. Bullet Time: SlowMo and the Crisis Dive (SlowMo)
- **Room:** 3 ChaingunGuy (hitscan, so their shots become visible rounds in slow motion, README SlowMo:26) on P2 behind half
  cover. The adrenaline meter is filled by the room (`RSQSM_Service` "adrenaline.add").
- **Goal:** start slow motion by crossing the wrists or with L stick click (README SlowMo:12). Lean 6 cm out of a round (:27).
  Crisis Dive with modifier + L stick click and kill in the air (:18).
- **Pass:** `RSQSM_Service` "slowmo.active", "scale". `developer 1`: `RSQ_SlowMo: round passed player 0 at N units`
  (`SlowMo/zscript/rsqsm/round.zs:188`) and `leaned out of a ...` (`body.zs:143`). **Score rows:** Stretched Second (x1.5 at
  10% speed or slower: the dive, README Score:181), Read It (a shot passes within 48u, then kill its shooter, :79), Last
  Grain.
- **L** slow motion on and off both ways. **U** let 3 rounds pass, then Read It. **M** a dive kill of 2 (Stretched Second at
  the dive's depth).
- **Says:** the blue meter and green countdown bar; the whiz and crack.
- **[gap]** No service or log line says "a dive started / landed". SlowMo's service has no dive flag, and the room must
  infer it from scale <= 100 plus the player off the ground.

### C13. Be Quick or Be Dead (SlowMo DOWN)
- **Room:** health set to 15 and armour to 0. One Score life given first (`RS_ScoreService` "givelife"), so a failed DOWN costs
  that life and not the run (`SlowMo/zscript/rsqsm/down.zs:4-12,54`). 1 ShotgunGuy at 6 m, plus 3 DoomImp as "+time"
  targets.
- **Goal:** take the killing hit and go DOWN. Follow the chevrons. Kill the TARGET before DEATH IN ends (README SlowMo:33-38).
- **Pass:** the room's own RSQDownJoin service hears down.start, then down.up (down.revive in the top third), or down.fail.
  `RSQSM_Service` "down.left" gives the margin. **Award** Revenge (`RS_Score: award Revenge paid`, README Score:183).
- **L** one DOWN, with the target in sight. **U** the target behind you (the turn marker). **M** get up in the top third
  (REVIVE!, slow 3 s, invulnerable 5 s) and then win the next 10 s without being hit.
- **Says:** REVIVE! and REVENGE! world words and toasts (README VisualRewards:31-32); MAGS REFILLED.

### C14. Style Sheet: Score rows by name (Score)
- **Room:** a mixed wave of 4 ZombieMan, 3 DoomImp, 1 Demon, 1 Cacodemon. 2 barrels. Every tool from C2-C12 allowed.
- **Goal:** make one kill with several tools in turn, and bring new tools into a fight.
- **Pass:** `RS_ScoreService` kill.chain (for example "gun>whip>shield.bash") counts the tools of each kill in play.
  **Score rows:** Combo Chain 3-Tool / 4-Tool (README Score:65), Variety (a big moment at five tools, :66), plus any named
  combo from the 171.
- **L** one 2-Tool kill. **U** a 3-Tool kill and Variety +0.3. **M** Variety at five (the big moment) inside one wave.
- **Says:** Score's own rows under its bar; the Glossary (How To Play SCORE tab) names what was earned.

### C15. Boss Call (Miniboss)
- **Room:** the full arena, and the hub pad cleared. **Real monster Things must be in the map at load** (a sealed closet):
  `BfScan` builds the Boss roster from the actors on the map, and with none the fight refuses with "No Boss: No Monsters"
  (`Miniboss/zscript/rsqmb/bossfight.zs:155-176,743`). The meter is set with `netevent rsqmb_fill 1000`
  (`handler.zs:485-489`), or filled for real in M.
- **Goal:** check the pulse with the inside of the off wrist and see the gold card (README Miniboss:18). Press Use (:19). Kill the
  thralls first, break both WEAK! points (:23), finish a staggered thrall or the CRITICAL! Boss in melee (:25). Then stand
  2 s at the kiosk and REPAIR or buy one (:34-38).
- **Pass:** `RSQMB_Service` "bossfight", "lives", "meter.ready". `rsqmb_debug 1`: `MINIBOSS FIGHT CALLED IN (the Start Fight
  card)` (`bossfight.zs:699`). **Awards** Miniboss Called / Boss and Finisher (README Score:184-185); **row** Chain Gang
  (:187). The kiosk test door is `netevent rsqmb_kiosk <1|2> <hand> <offer>` (`kiosk.zs:1496-1502`).
- **L** card plus Use, then watch the arrival. **U** win the fight. **M** fill the meter for real and win with a Finisher and
  Chain Gang x3.
- **Says:** BOSS INCOMING / BOSS DEFEATED! banners, the life crate and 1UP, the kiosk.
- **Limits that shape the station:** one Boss a map (Per Map Cap 1, README Miniboss Limits), so it runs once per map load.
  Thralls land 400-700u around you and the Boss 384-1024u in front, in sight (README Miniboss:20;
  `design/CHALLENGE_BUILDING_BLOCKS.md` §1). The 1024 x 512 arena in `architecture.md` is too shallow behind the hub for
  "Around You". Use Arrival: Classic (all land in front) in the room, or make the arena deeper. The kiosk needs BD22 VR
  Reloaded with LegenDoom and Score, and offers only guns you carry.

---

## 2. Why this order (each one reuses the last)

C1 teaches the wrist poses that C15's pulse card needs, and the Recenter that every holster needs. C2 introduces body
places, and C3 assigns them, mounting the shield C10 uses. C4's palm switch becomes the room's "start" for every later
station, and its barrel throw comes back in C5 (uppercut) and C7 (chains). C5's fists come before C6's grip, and C6's
throw is Distance Grab's throw from C4. C7 draws from C2's buckle and C3's fan. C8 teaches "a hand move is the attack"
before the two throwing weapons. C9 teaches lock-and-throw on the trigger's **release**, and C10 teaches it again on a
**flick**, so the two rules are met side by side, on purpose. C11 adds height, and its kicks ask for SlowMo, which C12
then gives to the player's own hand. C13 is SlowMo's failure state. C14 grades everything at once. C15 is the series'
set piece and can run only once per load.

## 3. Final exam: "Arcade Run" (one wave sequence, about 4 minutes)

1. **Draw** (C2/C3): 3 ZombieMan rise on P1. Only body draws are allowed (Armory).
2. **Hook and disc** (C11 + C10): 5 DoomImp rise on far P2 cells. Ring them, throw, and grapple to a ShotgunGuy on P3 while the
   disc flies (Juggler: a kill while the disc is out, README Score:140). Catch on landing.
3. **Crowd** (C8 + C7 + C5): 6 ZombieMan and 2 barrels in the pit. Ground Crack, then grenade or barrel. A Field Goal or
   Powder Keg is wanted.
4. **Down** (C13): one scripted killing hit at health 15. Get up (REVIVE!).
5. **Boss** (C15): the pulse card is gold. Use calls it in, and you win it with one Finisher.
- **Pass:** survive (a DOWN you get up from is allowed; a Score life spent is a fail), the Boss defeated, **and** Variety's
  big moment (five tools) at least once in the run. All three are readable in play: `RSQMB_Service` "bossfight" / the
  Boss award, `RS_ScoreService` "lives", and kill.chain.
- **Grade:** the Score total for the run, so the owner can compare runs. Score already keeps it (`score`).

## 4. The owner's 5-minute headset smoke test (8 stations at L, in this order)

| Time | Station (step L) | What it proves |
|---|---|---|
| 0:00 | C1 Report In | RSQoopaControls loaded, pad B recenter, both watch cards |
| 0:30 | C2 Quick Draw (Use at the hip) | the Rig under the modifier layout (main hand by Use) |
| 1:00 | C3 Loadout (assign shotgun + mount shield) | the Wheel's web and the Rig's mount |
| 1:30 | **C10 Disc** (3 rings, flick, catch) | **today's change: off-trigger lock**, not yet re-verified on the rig |
| 2:30 | C11 Hook (ledge + one kick) | R stick click, the off hand's aim, KICK! |
| 3:15 | C7 Frag Out (Quick Grenade with modifier + R stick up) | `+user1`, a blast, SlowMo's Quick Grenade slow |
| 3:45 | C13 Be Quick or Be Dead (L) | DOWN, the chevrons, REVIVE! |
| 4:30 | C15 Boss Call (L: card + Use only) | the pulse card and the call. Stop at BOSS INCOMING |

The rig runs the same 8 stations from a script: hands posed with `qz_lhand` / `qz_rhand`, buttons with `qz_ltrigger` /
`qz_rbuttons`, and the test doors `netevent rsqgr_fire`, `ubqs_remote`, `rsqmb_fill`, `rsqmb_callin`. Each pass is
read from channels (b) and (c) above. Rig only is not headset, so the smoke test stays the owner's.

## 5. What the code cannot measure today (a mod would need a signal)

1. **Score's rows are not readable in play.** Which rows paid on a kill exists only in the debug line
   (`handler.zs:848-869`). `kill.chain` and `kill.style` are readable, but a row's name is not. Any "Textbook" /
   "Clean Sweep" pass in the headset needs one read-only query, for example `kill.rows`, in Score. An unknown award label
   pays onto the Base row (`design/CHALLENGE_BUILDING_BLOCKS.md` §2), so the room cannot pay its own "station passed" row
   without a new `RS_Award_*` class.
2. **Miniboss:** the roster comes only from monsters on the map at the scan (`bossfight.zs:155-176`). There is one Boss per map
   and no test door resets that cap, so C15 runs once per load.
3. **SlowMo:** there is no dive state in `RSQSM_Service` and no near-miss count. Near misses print only at `developer 1`.
4. **Gun Cards:** the watch check is a pose. Nothing can tell that the card was read.
5. **ShieldSaw:** the ring count is not in `SSQ_ScoreService` (blocked, perfect, returned, thrown.leg, grind only). "locks N" is
   a debug line, so a "ring all 5" pass in the headset is inferred from the throw's kills.
6. **Saber remote:** rounds and best streak show on its TRAINING OVER panel but are not answered by `UBQS_SaberService`.
   Only the Deflect / Remote Down awards are visible to others.
7. **Inventory:** there is no series item on the engine's inventory bar (pad Y / modifier + pad Y). "Inventory management" has
   nothing to train beyond the Wheel and holsters until one exists.
8. **The main grip (key 446):** the Rig's and Distance Grab's main grip arrives only from modifier + R trigger, which is
   main alt fire. This is the open question in `design/controls/CONTROLS.md:326-329`. C2 and C3 teach Use for the main
   hand until the owner answers.
9. **Determinism:** XMVE's random spawners, Champions (about half the monsters at Ultra-Violence, README Miniboss:50),
   LegenDoom Lite and the Monster Tier change what a spawn is. A pass threshold needs those pinned, which is the owner's
   decision below.
