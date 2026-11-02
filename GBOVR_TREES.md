# GBOVR_TREES.md: the UBQS progression design (DRAFT, L0 in progress)

Started 2026-11-02 by the local lane, from `GBOVR_SWARM_HANDOFF.md`. Repo `main` @ 9cc70f6b2.
Nothing here is decided until the owner strikes or keeps it. Nothing below was run in the engine: every
fact is read from the code at that commit, file and line given.

Sections 1 and 2 are L0 steps 1 and 2 (the audit, the off-hand XP check). Section 3 (the trees) is written
after the owner's verdicts on section 2.

---

## 1. Off-hand XP: how a hit is credited today (L0 step 2, read from code, not yet run)

Gun Bonsai VR keeps **two live weapon records**, one per hand (`ca.ancilla.bonsai/PerPlayerStats.zsc:199`
`infoForOffhandWeapon`). Damage is credited by **provenance**, not by which hand is "current"
(`PerPlayerStats.zsc:1243` `OnDamageDealt` -> `ResolveCredit` at `:1010`). The order `ResolveCredit` tries:

1. a DoT's own credit record;
2. an open **claim bracket** (`credit.push` / `credit.pop` on `RSQ_MeleeUpgradeService`, `rsq/zscript/core.zs:251`):
   damage by the player's own body goes to the weapon that opened it (the ShieldSaw's bash uses this);
3. an actor some mod **claimed** (`"claim"`, `core.zs:240`: the actor's `master` must be the Weapon);
4. **the inflictor is itself one of the player's weapons** -> that weapon's record (`:1040` `InfoForOwnedWeapon`);
5. inherited provenance (the inflictor's target / master / tracer);
6. an open hitscan bracket;
7. otherwise a **guess** (`ScoreHandFor`, `:930`): nearer hand by position, then by aim direction, then whichever
   hand's psprite is in its fire states. With one hand empty it is that hand, no guess.

What that means for each off-hand tool:

| Tool | Inflictor on a hit | Credited to | Verdict |
|---|---|---|---|
| Off-hand punch (Melee's hands / gloves) | the glove weapon itself (`RSQ_GloveOff`; `rsq/zscript/up_gloves.zs:4`) | **its own record**, path 4 | works; `RSQ_Glove` and `RSQ_GloveOff` are two classes, so **each hand is its own tree** and levels separately |
| Off saber | the saber weapon itself (`UBQS_SaberOff`; `rsq/zscript/up_melee.zs:151` reads `e.Inflictor` as the saber) | **its own record**, path 4 | works; two classes, two trees. The Force reads the best level on either saber (`core.zs:46` `LevelAny`) |
| Whip | the whip's hook actor (`Whip/zscript/rsqwp/whip.zs:1420`), `null` (`:1427`) or the **player** (`:1903`); never `RSQWP_WhipWeapon` | **a guess (path 7)**, which can be the gun in the other hand | **broken for XP**: the whip earns nothing of its own; `RSQWP_Perks` is a stub (`Whip/zscript/rsqwp/fx.zs:29`, "no upgrades, factor 1"); not in `bonsairc.rsq`'s `type` line |
| Grenade | `RSQGN_Thrown`, `target` = the player, no `master` (`Grenade/zscript/rsqgn/hand.zs:333`) | registered at spawn (`EventHandler.zsc:361`) by **a guess (path 7)** | **unreliable**: the thrown grenade is a missile with target = player, so Gun Bonsai sees it, but nothing names the `RSQGN_Grenade` weapon; the guess picks a hand by position at spawn |
| Grapple | hook; `RSQGR_Service "hook.dealing"` | the **player pool** (`PerPlayerStats.zsc:841`, `:1250`), by design | works as player XP, not a weapon's |
| Distance Grab throw, Headlock throw | thrown object | the **player pool** (`IsSuiteThrow`) | works as player XP |
| ShieldSaw bash / grind | the player's body inside a claim bracket | the ShieldSaw (`credit.push`) | works |

**Design consequence.** Per-hand trees already exist for fists and sabers, for free, because each hand holds a
different weapon class. That also means a player levels the left fist and the right fist separately. The owner
decides whether that is wanted (two trees, or one tree read as the best of both hands as the Force does).

**L1 work this reveals** (plumbing, not design):
- Whip: open a claim bracket around each whip hit (or set the hook's `master` to the whip weapon and `"claim"` it),
  and add `RSQWP_WhipWeapon` to `bonsairc.rsq` (`type ... : MELEE`).
- Grenade: set `RSQGN_Thrown.master` to the `RSQGN_Grenade` weapon at the throw and `"claim"` it, so the blast and
  its kills pay the grenade.
- Stock-upgrade option (handoff L1.1): confirmed, `bonsairc.rsq:30` disables only the elementals and RapidFire on
  our weapons; LifeLeech, Bandoliers, Juggler, Cleave, Sweep, Shield etc. still roll on fists and sabers.

**Not done:** the live check the handoff asks for (`netevent bonsai-debug,info` after real off-hand hits). The
local lane does not launch the game by the owner's rule; the rig or the owner's headset does that check.

---

## 2. The audit: every upgrade we ship today (L0 step 1)

Source: `GunBonsaiOffhandVR/rsq/zscript/up_*.zs` and `bonsairc.rsq` @ 9cc70f6b2. "Today" is one line read
from the code. "Proposed" is the local lane's verdict for the owner to strike or keep: **keep** (and where it
goes), **rework** (what changes), **cut** (why). Levels are uncapped unless a cap is given.

### 2.1 Fists (on `RSQ_Glove` / `RSQ_GloveOff`; Melee does the move, we set the numbers)

| # | Upgrade | Today (code) | Proposed | Path / parent |
|---|---|---|---|---|
| 1 | Heavy Hands | hit-stop 2 tics at lv1 to 4 at lv3, +2 for a punch at half speed or more; knockback +25% a level; cap 4 | **keep** | Power: root (the first thing a fist learns) |
| 2 | Haymaker | damage x (1 + lv x (0.15 + 0.35 x punch power)) | **keep** | Power: after Heavy Hands |
| 3 | Body Blow | a hit below the chest winds the monster 35 + 18 x lv tics (every state longer) | **keep** | Power: after Heavy Hands |
| 4 | Wall Splat | monster knocked into a wall at 3+ units/tic takes 5 + 5 x lv (x2 at 6+), reels 10 + 5 x lv tics; cap 5 | **keep** | Power: after Haymaker |
| 5 | Star Punch | clean hits bank stars (SPO rule); an uppercut with the trigger held spends one: x(1.5 + 0.5 lv), lifts, staggers 1 s | **rework**: the uppercut becomes its own unlock node ("Uppercut", then "Launcher" = the lift); the star banking is SPO's rule and reads as a second resource | Power: Uppercut -> Launcher |
| 6 | Knockdown | damage in 2 s >= (0.5 - 0.06 lv) of start health puts a non-boss down for a 2 + lv count (max 8) | **keep** | Power: capstone, after Wall Splat |
| 7 | One-Two | alternating-hand hits inside 0.5 s add 15% x lv each, up to 4 | **keep** | Speed: root. Note: needs both hands, so it sits on whichever hand levels (see section 1) |
| 8 | Counterpunch | a punch during the monster's wind-up does x(1.25 + 0.25 lv) and staggers 17 + 9 lv tics | **keep** | Counter: after Guard |
| 9 | Hadouken (class `RSQ_Upgrade_ReturnFire`) | a punched missile returns at x(1.25 + 0.25 lv), 15% x lv faster; cap 4 | **keep** | Counter: after Counterpunch; the slow-mo projectile punch is its capstone (real projectiles only) |

### 2.2 Any melee weapon (fists, sabers, ShieldSaw: `info.IsMelee()`)

| # | Upgrade | Today | Proposed | Path |
|---|---|---|---|---|
| 10 | Lunge | damage x (1 + 0.15 lv x (head m/s - 0.5), up to 3) | **keep** | Body: shared by every melee tree |
| 11 | Executioner | a staggered monster at <= (0.10 + 0.05 lv) of start health dies to the next melee hit (bosses excluded) | **keep** | Power capstone candidate for fists and saber alike |
| 12 | Adrenaline | big melee moments (3 kills in 3 s, a 400+ hp kill, an execution) pulse slow-mo 0.3 + 0.15 lv s and charge SlowMo's meter 4 x lv a kill | **keep** | the melee -> SlowMo link |

### 2.3 Saber (`UBQS_Saber` / `UBQS_SaberOff`; the saber does the work, reads levels by name)

| # | Upgrade | Today | Proposed | Path |
|---|---|---|---|---|
| 13 | Momentum | +10% x lv per half second the blade keeps moving, up to 2 s | **keep** | Blade: root |
| 14 | Riposte Edge | a block primes the next cut: x(1.5 + 0.25 (lv-1)) within 35 + 17 (lv-1) tics | **keep** | Blade: after Momentum |
| 15 | Dual Harmony | cuts alternating between the two sabers stack +10% x lv, up to 5 | **keep** | Dual: after "Second Blade" (new unlock node) |
| 16 | Deflector | a bolt the saber sent back hits +15% x lv; cap 5 | **keep** | Deflect: root |
| 17 | Piercing Return | a returned bolt passes through lv bodies | **keep** | Deflect: after Deflector |
| 18 | Saber Throw | the thrown saber finds lv more enemies on its route | **keep** | Throw: root |
| 19 | Force Push | unlearned 60% (`rsq_force_start`); lv1 full, +15% a level; 2+ cone +10 deg a level; 3+ shockwave | **keep**, under a new "The Force" unlock root; rework the 60% baseline to 0% under GBOVR if the owner wants the Force earned | Force |
| 20 | Force Pull | same baseline; 2+ stuns what arrives; 3+ disarms (no ranged attacks) | **keep** | Force |
| 21 | Force Choke | same baseline; 2+ lifts and crushes harder; 3+ holds lv-1 at once | **keep** | Force |
| 22 | Chain Choke | a choke kill jumps the grip to the nearest enemy within 256 + 64 lv units | **keep** | Force: after Force Choke |
| 23 | Force Jump | same baseline; 2+ the landing is a slam | **keep** | Force |
| new | Focus (lock-ons) | `ubqs_locks` defaults to 5 today | **new**: with GBOVR loaded locks start at 1; each level adds one | Blade or Deflect root, owner's call |
| new | Second Blade | the dual on/off is a saber row today | **new** unlock node | Dual: root |

### 2.4 ShieldSaw (`SSQ_ShieldSaw`)

| # | Upgrade | Today | Proposed | Path |
|---|---|---|---|---|
| 24 | Ricochet | the thrown disc bounces off a wall to lv more targets | **keep** | Throw: root |
| 25 | Hunter's Return | on the way home the disc swerves through lv enemies within 160 + 32 lv | **keep** | Throw: after Ricochet |
| 26 | Meat Grinder | a kill while embedded frees the disc to its next lock; grind +25% a level after 1 | **keep** | Throw: after Hunter's Return |
| 27 | Lockstep | +1 lock-on a level, cap 3 | **keep** | Throw: beside Ricochet |
| 28 | Broadening | the block plate +20% a level to double at 5 (replaces the Double Block Radius row) | **keep** | Block: root |
| 29 | Bulwark | the perfect-block window widens: 1 / (1 + 0.35 lv) of the speed needed | **keep** | Block: after Broadening |
| 30 | Rebound | shots the shield turns hit x(1.1 + 0.15 lv) | **keep** | Block: after Bulwark |
| 31 | Battering Ram | a bashed monster becomes a missile for 21 tics: hits others for 6 + 4 lv + speed | **keep** | Saw/Bash: root |

### 2.5 Grapple (player perks; `RSQ_Grapple` does the work)

| # | Upgrade | Today | Proposed | Path |
|---|---|---|---|---|
| 32 | Long Line | range +20% a level | **keep** | Line |
| 33 | Fast Reel | reel +15% a level | **keep** | Line |
| 34 | Heavy Haul | heavier (+50%) and bigger (+15%) things come; a boss on the line staggers 10 + 10 lv; cap 3 | **keep** | Haul |
| 35 | Get Over Here | what arrives is staggered 20 + 15 lv tics; cap 3 | **keep** | Haul |
| 36 | Bowling | what arrives strikes what is in its way for 5 + 5 lv; cap 3 | **keep** | Haul: after Get Over Here |
| 37 | Barbed Claw | bite 4 + 4 lv, tear-out 6 + 6 lv | **keep** | Line |
| 38 | Slingshot | letting go of a swing carries +10% a level; cap 3 | **keep** | Swing |
| 39 | Steady Line | the hang settles x(1 + 3 lv) faster; cap 3 | **keep** | Swing |
| 40 | Double Hook | a monster on each hook, slammed together for 20 + 15 lv; from player level 5; cap 3 | **keep** | Haul: capstone |
| new | Grapple (unlock) | the hook is always there today | **new**: a player-level unlock (the owner's "unlockable") | root |

### 2.6 Distance Grab (player perks)

| # | Upgrade | Today | Proposed | Path |
|---|---|---|---|---|
| 41 | Long Arm | the grab reaches +15% a level | **keep** | Grab |
| 42 | Iron Grip | heavier things come (+50%) and weigh less (+25%) a level | **keep**, and it is the Headlock link ("bigger enemies" = a heavier Headlock mass through the throw service) | Grab -> Fists' Grappler |
| 43 | Heavy Hitter | a thrown thing hits +15% a level, leaves the hand faster; cap 5 | **keep** | Throw |
| 44 | Air Catch | catch window +25% a level; a re-caught thing hits +20% a level | **keep** | Throw: after Heavy Hitter |
| 45 | Powder Keg | a barrel a throw set off blasts +15% a level; cap 5 | **keep** | Throw |

### 2.7 Tactical Rig, two hands, body, SlowMo (player perks)

| # | Upgrade | Today | Proposed | Path |
|---|---|---|---|---|
| 46 | Quick Draw | the gun just drawn from a holster hits +10% a level for 1 s + 0.25 s a level; cap 5 | **keep** | Gunslinger (Rig) |
| 47 | Pair Draw | a pair draw: both hands +8% a level for 2 s + 0.5 s a level; cap 3 | **keep** | Gunslinger |
| 48 | Showdown | a kill with the just-drawn gun within 2 s pulses slow-mo 0.3 + 0.15 lv s; needs SlowMo; cap 3 | **keep** | Gunslinger -> SlowMo link |
| 49 | Akimbo | both hands firing inside 12 tics: +6% a level (guns only); cap 5 | **keep** or **cut**: a flat number the player cannot feel; owner's call | Gunslinger |
| 50 | Crossfire | each hand on a different target: +10% a level (guns only) | **keep** or **cut**: same reason | Gunslinger |
| 51 | Alternator | alternating-hand gun hits stack +4% a level, up to 4 | **keep** or **cut**: same reason | Gunslinger |
| 52 | Southpaw | the off hand hits +6% a level | **cut**: a flat number with no move behind it | - |
| 53 | Steady Aim | a hitscan fired with the head still (< 0.2 m/s) hits +5% a level | **cut**: same | - |
| 54 | Evasion | head moving at 1.2+ m/s: take 8% less a level, cap 4 | **keep** | Body |
| 55 | Guard | both hands up: take 70% - 10% x lv (floor 30%); a blow of 25 + 10 lv breaks it (the move is Melee's) | **keep** | Fists Counter: root |
| 56 | Marksman | +8% a level to everything hit while slowed; cap 5 | **keep** | SlowMo |
| 57 | Dodger | take 8% less a level while slowed, cap 4 | **keep** | SlowMo |
| 58 | Second Wind | every kill charges the meter 3 x lv | **keep** | SlowMo |
| 59 | Time Dilation | a kill while slowed re-pulses 0.25 + 0.15 lv s and refunds 2 lv; cap 3 | **keep** | SlowMo |
| new | Slow Motion (unlock), Longer Slow-Mo | the owner's "unlock it, lengthen it" | **new** | SlowMo: root |

### 2.8 Missing entirely

- **Whip:** no upgrades, no XP (section 1). **Owner, 11-02: the whip gets its own path.** About 6-8 nodes to
  design; `RSQWP_Perks` is the stub to fill.
- **Grenade:** no upgrades; XP by guess (section 1). **Owner, 11-02: the grenade earns as a weapon of its own and
  gets its own path.** It already is a Weapon class (`RSQGN_Grenade`); the thrown actor must name it (L1).
- **Owner's note, 11-02, to check in L1:** while the off hand supports a two-handed gun (BD22 VR Two-Hand Aim),
  the off hand earns XP today, as he recalls it. Where that XP lands is to be read in `ScoreHandFor` with an
  empty off hand (`PerPlayerStats.zsc:937`: with no off-hand weapon the main hand is chosen, no guess).
- **Gestures, Wheel, LaserSight, GunCards, Miniboss, TopHPBars:** no path today; each gets a line in section 3
  (a path, feeds another path, or "no progression" with the reason). TopHPBars has no MENUDEF at all.

### 2.9 The menu rows that could become unlocks or levels (step 1, second half)

Menu rows per mod (`MENUDEF`, Option and Slider rows): Melee 25, QuestSaber 23, ShieldSaw 139, Whip 58,
Grenade 21, Grapple 64, DistanceGrab 119, TacticalRig 107, SlowMo 53, Gestures 50, Wheel 111, LaserSight 57,
GunCards 39, Miniboss 28. Melee's rows read in full; the rest are listed per tree in section 3 as each tree is
designed (reading all 900 rows at once serves nobody).

Melee today (`Melee/MENUDEF.txt:31-55`): Melee Hands (model), Boxing Gloves, Open-Palm Swat, Slappers Only,
Start With Melee Hands, Gun Butt Shove, Slow-Mo After a Shove, Headlock, Headlock: Human Shield, Headlock Punch
Extra Blood, Guard, Hadouken, Wall Splat, Heavy Hands, Hit Spark Size. Candidates for nodes: the **uppercut**
(a base punch kind today), the **swat** (Counter path root before Guard?), **Human Shield** (Grappler path),
**Slow-Mo After a Shove** (the shove -> SlowMo link). The Headlock itself stays base (owner, 11-01).

---

## 3. The possibility space, per mod (owner, 11-02: "a game within a game; think big")

The owner's frame: XP bars and level-ups make this a game of its own. The audit above sorted what exists. This
section starts from what each mod lets a body DO today (read from its README @ 9cc70f6b2) and lists what a
progression could make of it. Everything is a candidate until the owner keeps or strikes it. "Needs" names what
is not there yet. Nothing here needs an engine change unless it says so; QuestZDoom 17.3 is fixed.

Two facts that widen the field:
- **Punching bullets in slow motion is possible, but parked (owner, 11-02).** RSQ SlowMo's *Dodgeable Bullets*
  (on by default) turns an enemy's hitscan into a visible round while time is slowed: `RSQSM_Round`, drawn as
  RS_Ballistics' tracer mesh scaled to a 14-unit streak (`SlowMo/MODELDEF.txt`). So the handoff's "hitscan
  cannot be punched" holds only outside slow motion. The bullet CATCH (a round held in the off hand) was removed
  from SlowMo on the owner's word the same day (`SlowMo/zscript/rsqsm/body.zs:3`): there is no model of a round
  sitting in a hand and no hand pose for holding one, and hand fitting is off the table. Owner: design it, but
  switch it off. So: **Catch** is designed as an Option (off) that waits on a held-round model and a pose;
  **Bullet Time Fists** is designed as a PUNCH through the streak (no pose, no new model, the streak turns round)
  and also ships off until the owner has seen it in the headset.
- **Elemental fists are allowed** (owner, 11-02: "no reason not to have explosive or freezing punches"). That
  overrides the 10-27 rule in `bonsairc.rsq:28` ("no elemental damage on these"). They are ours to write with
  punch art, not Gun Bonsai's stock elementals re-enabled.

### 3.1 Fists (RSQ Melee owns the moves)

**The body can do today:** jab, hook, uppercut (lifts), weak to strong punch by hand speed, open-palm swat of
a fireball, Guard, Hadouken, Wall Splat, Heavy Hands, gun-butt shove (BD's pistol whip and butt strike when
BD22 VR is loaded), Headlock with punches and a throw, Human Shield, boxing gloves, two independent fists.

**Possibilities, by branch:**

- **Power** (hit harder, hit heavier): Heavy Hands -> Haymaker -> Body Blow -> Wall Splat -> Knockdown. New:
  **Uppercut** as an unlock (today it is a base punch kind; owner: "we unlock uppercut") -> **Launcher** (the lift
  grows a level: an imp 0.9 m today) -> **Meteor** (a launched monster falls onto others and hurts them: the
  Battering Ram pattern, `core.zs:424` `RSQ_Rammed`, pointed down) -> **Juggle** (hit it again in the air for
  more). **Ground Pound** (both fists down together, Gestures' "both hands down": a shockwave at your feet).
- **Elemental** (new, owner 11-02): **Explosive Fist** (a landed punch blasts a small radius, scaled by punch
  power; the Berserk doubles it), **Frost Fist** (the monster freezes solid for 1 s + 0.5 s a level, blue-tinted,
  cannot act; the next punch shatters it for x2; Needs: a frozen state in `RSQ_Dazed`, a blue translation, and
  HP Bars' snowflake marker already exists for it), **Shock Fist** (the hit arcs to one more monster a level),
  **Fire Fist** (a burn the fist owns, not Gun Bonsai's). One element per fist? Both fists different elements is
  the two-fist payoff.
- **Combos** (new): One-Two -> **Three-Hit** (jab-jab-hook inside a second: the third hits x2 with a bigger spark)
  -> **Dempsey** (alternating hooks, each faster) -> **Finisher** (a combo's last hit on a staggered monster is an
  Executioner kill with the full spark burst). A combo counter the Score can read.
- **Counter** (defence turns into offence): Guard -> **Parry** (a Guard moved INTO the blow: the attacker staggers;
  the saber's and shield's perfect block, for fists) -> Counterpunch -> **Swat Back** (the open-palm swat sends
  the fireball at its shooter, Hadouken's little brother) -> Hadouken -> **Catch** (catch a fireball in an open
  hand, hold it, throw it: Distance Grab's catch and throw service; **Option, off**: needs a held model and a
  hand pose, owner 11-02) -> **Bullet Time Fists** (capstone: in slow motion a punch through a slowed round
  returns it; a punch, not a catch, so no pose; **off until headset-seen**, owner 11-02).
- **Grappler** (the off hand): Headlock (base) -> Human Shield -> **Headlock Uppercut** (an uppercut out of a
  Headlock launches it) -> **Heavier Headlock** (Distance Grab's Iron Grip raises the mass cap: 400 today, a
  Baron is 1000) -> **Slam** (swing the off hand DOWN: the held monster hits the floor, a shockwave) -> **Throw
  Into** (a Headlock throw that hits another monster hurts both; Distance Grab's throw aim assist bends it).
- **Berserk** (new): the Berserk pack is the fists' power-up. **Rage** (Berserk also gives +1 level to every fist
  upgrade while it lasts) -> **Blood Rush** (a fist kill extends Berserk 5 s a level; melee "replaces the need
  for weapons") -> **Berserk Meter** (fist hits fill a meter that grants a short Berserk without a pack).
- **Gun hand** (the shove): **Pistol Whip** (a shove with a pistol staggers longer and the next shot on that
  monster is x1.5) -> **Rifle Butt** (a shove with a long gun can knock down). Feeds Gunslinger.
- **Taunt** (new, needs Gestures' two-hand events): "both hands apart" = a taunt; nearby monsters turn on you and
  your next punch is x2 for 3 s. Score hook `taunt`.

**Art:** each punch kind has a CvS2 spark today (jab orange, hook blue, uppercut violet). The level grows the
frames: level 1 plays the first 3 of 10 kiddolink frames, each level adds frames, the capstone plays the full
burst at 1.5x. Elements recolour the same frames (frost blue, fire orange-red, shock yellow).

**Open:** left fist and right fist are two records today. Elemental per fist wants two trees; everything else
wants one. Proposal: one tree, read as the best of either hand, with the element the one per-hand choice.

### 3.2 Saber (RSQ Saber owns the moves)

**Today:** cut, stab (x1.5), block, parry (double knock), cross guard (two blades), blade lock, mark and throw
(5 locks), recall, Force push (main alt), Force by gesture (push / pull / choke / throw), Force jump, flick
reload, second saber via the Rig holster, blade length and colour.

**Possibilities:**
- **Focus:** locks start at 1 under GBOVR, +1 a level (owner). Then **Chain Throw** (the thrown saber visits
  marks and cuts on the way back), **Boomerang** (a second pass).
- **Blade:** Momentum -> Riposte Edge -> **Hit-Stop** (the option becomes levels: 3, 4, 6 tics) -> **Reach**
  (blade length 54 cm at level 0 up to 99 cm: the five presets are five levels) -> **Sever** (a cut on a monster
  under a share of its health gibs it).
- **Stab:** **Lunge Stab** (a stab with the head moving forward is x2) -> **Impale** (a stabbed monster is held on
  the blade for a second).
- **Deflect:** Deflector -> Piercing Return -> **Aimed Return** (turned shots go where you look; the option becomes
  an unlock) -> **Return to Sender** (to the shooter) -> **Parry Window** (Bulwark for sabers).
- **Dual:** Second Blade (unlock) -> Dual Harmony -> **Cross Guard** (the X block becomes an unlock that also
  reflects) -> **Blade Lock Shock** (a blade lock releases a shockwave).
- **The Force:** The Force (unlock; without it the powers are off, not at 60%) -> Push / Pull / Choke / Jump
  (each its own node and levels, as today) -> Chain Choke -> **Force Speed** (a Force gesture starts slow motion:
  the SlowMo link) -> **Force Lightning** (new power; Needs: a new UBQS_Force power) -> **Force Repulse** (push
  level 3's shockwave as its own node).
- **Rig link:** Saber on Hip, flick reload with the Force hand: **Quick Ignite** (a drawn saber cuts x1.5 for 1 s).

### 3.3 ShieldSaw (RSQ ShieldSaw owns the moves)

**Today:** draw from the back, block, perfect block, bash, wall slam, rev and grind, lock (5) and throw, recall
and catch, saber over shield, hit tiers (weak cut in two, mid ground, heavies turn it), block while holstered
(option), double radius (option), muzzle block, return bullets, shield size presets.

**Possibilities:**
- **Throw:** Lockstep (locks from 1 under GBOVR, like the saber) -> Ricochet -> Hunter's Return -> Meat Grinder ->
  **Wall Bounces** (3 today: a level each) -> **Cleaver** (hit tiers rise: slice heavier monsters a level).
- **Block:** Broadening -> Bulwark -> Rebound -> **Back Plate** (Block While Holstered as an unlock) -> **Shield
  Wall** (a perfect block pulses slow motion: the option becomes a node) -> **Reflect** (returned bullets x2).
- **Bash:** Battering Ram -> **Wall Slam** levels -> **Hit-Stop** levels -> **Charge** (a bash while moving
  forward fast knocks a crowd) -> **Shield Size** (Standard -> Large -> Largest as levels).
- **Grind:** **Hungry Blades** (grind damage a level) -> **Rev Shield** (a revving shield blocks AND grinds what
  touches it) -> **Buzzsaw Return** (a recalled disc grinds through what it passes).
- **Saber link:** Saber Over Shield (x1.3 today) -> **Spartan** (blade over shield also parries).

### 3.4 Whip (RSQ Whip owns the moves; own path, owner 11-02)

**Today:** crack (damage by speed, light/heavy), mark and lock, wrap a monster and swing it (flail), yank (light
ones fly to you, heavy ones pull you), lasso (off hand on the thong), snag edges to a rope, reel / hang / let
go, climb, mantle, fetch pickups, throw switches, stun on crack, crack fireballs (option), hit-stop (option).

**Possibilities (about 6-8 nodes to pick from):**
- **Crack:** **Sting** (crack damage a level) -> **Stun** (the pain lasts longer) -> **Crack Shot** (crack fireballs
  out of the air: the option becomes an unlock) -> **Return Crack** (the cracked missile flies back at the
  shooter) -> **Hit-Stop**.
- **Reach:** **Long Thong** (whip length a level) -> **Quick Mark** (more lock marks, pickups from farther).
- **Wrap:** **Flail** (a swung monster hurts what it hits, more a level) -> **Choke** (a wrapped monster takes
  damage over time) -> **Disarm** (a yank on a shooter stops its ranged attacks: `RSQ_Dazed.disarmUntil` exists)
  -> **Heavy Yank** (pull heavier monsters to you instead of being pulled).
- **Lasso:** Lasso (unlock) -> **Rope Them In** (a lassoed monster drags into others) -> **Bola** (two monsters).
- **Rope:** Snag (unlock) -> Mantle -> Momentum -> **Tarzan** (a swing kick: arriving on a monster at speed hurts
  it).
- **Fists link:** **Pull and Punch** (a yanked monster arrives staggered: Counterpunch counts).

### 3.5 Grenade (RSQ Grenade owns the moves; own weapon path, owner 11-02)

**Today:** pin by ring or teeth, cook, throw at arm speed, bounce and roll, 3 s fuse, red flash, scatter per
map, carry 8 (16 with a backpack). One blast: 85/200 then 75/255.

**Possibilities (about a dozen):**
- **Carry:** **Bandolier** (carry +2 a level) -> **Scavenger** (more scattered per map).
- **Throw:** **Strong Arm** (throw strength a level) -> **Flat Arc** (less arc, more range) -> **Bounce** (wall
  bounce kept a level: bank shots).
- **Fuse:** **Cook Sense** (the tick speeds up more clearly; a haptic per second) -> **Short Fuse** (fuse down to 2 s)
  -> **Impact** (a cooked grenade thrown with under 0.5 s left bursts on contact).
- **Blast:** **Big Bang** (radius a level) -> **Frag** (damage a level) -> **Cluster** (lv submunitions on the blast)
  -> **Incendiary** (fire left behind) -> **Flash** (monsters inside are stunned instead of hurt: a second grenade
  kind, chosen by cooking with the off hand?) -> **Sticky** (sticks to the first monster it touches).
- **Style:** **Teeth** (the teeth pull pays Score) -> **Skeet** (shoot your own grenade in the air: it bursts
  there; it is an actor, so a hitscan can hit it) -> **Return Pull** (Distance Grab pulls a thrown grenade back).
- **SlowMo link:** a kill by a cooked grenade in slow-mo re-pulses slow-mo (Time Dilation counts it already once
  the grenade pays its own XP).

### 3.6 Grapple (RSQ Grapple owns the moves; player perks)

**Today:** fire the claw, pull to it or swing, reel, hang, let go with speed, pump, calm, climb (two hands),
hook a monster (slide / yank / lasso), lasso flick throw, hook switches (option), score stunts.

**Possibilities:** **Grapple** (unlock at a player level; owner) -> Line (Long Line, Fast Reel, Barbed Claw) ->
Haul (Heavy Haul, Get Over Here, Bowling, Double Hook) -> Swing (Slingshot, Steady Line, **Momentum** as an
unlock of the Swing and Momentum option) -> new: **Hook Switches** (the option as an unlock), **Zip Kick**
(arriving on a monster via the rope hurts it: your speed as damage), **Scorpion** (a yanked monster that arrives
at a fist is punched automatically at full power: the Fists link), **Twin Lines** (a hook from each hand on
geometry: a web).

### 3.7 Distance Grab (RSQ Distance Grab owns the moves; player perks)

**Today:** palm-out aim, lock, flick pull, catch (pickups used; barrels and corpses carried), throw with aim
assist, drop, two-hand lighter, hit with a held thing, walk-up grab, lift doors, flip switches, body shield.

**Possibilities:** Grab (Long Arm, Iron Grip, **Reach** presets as levels) -> Throw (Heavy Hitter, Air Catch,
Powder Keg, **Dead Eye**: aim assist 12 deg a level) -> new: **Corpse Grab** (unlock; the option is off today),
**Body Shield** (unlock), **Catch** (catch a monster's fireball in the palm: the Fists Counter link), **Pull
Small** (pull a small monster, zombie or imp, to your hand: a Headlock without walking), **Heavy Lift** (two-hand
lift as levels), **Pull Gravity** off as an unlock. The Headlock throw already flies through this mod's throw
when loaded; Iron Grip and Heavy Hitter should read onto it.

### 3.8 Tactical Rig (player perks)

**Today:** six holsters, grip or Use to holster / draw / swap, grenade spot, throw a gun away (it hurts), keyring
and keys to doors (option), move gun at watch (option), move holsters, profiles, torso, cigarette ritual with slow
motion after (option), ammo lights, ammo count (option), new guns to a holster (option).

**Possibilities:** Gunslinger (Quick Draw, Pair Draw, Showdown) -> new: **Holsters** (start with 2 of the 6; a
level opens one: hips, chest, shoulders), **Quartermaster** (New Guns Go to a Holster as an unlock), **Ammo
Readout** (the holster digits as an unlock), **Gun Toss** (thrown-gun damage a level) -> **Boomerang Gun** (a
thrown gun comes back to the holster), **Keys by Hand** (unlock), **Smoker** (the cigarette unlock; owner
named it) -> **Long Drag** (smoke slow-mo 6 s + 2 s a level) -> **Chain Smoker** (pack size).

### 3.9 SlowMo (player perks; owner: "unlock it, lengthen it")

**Today:** toggle by key or wrist cross, world speed 0.25, ease, dodgeable bullets (drawn as a tracer streak),
lean dodge, adrenaline meter (option), colour drain, 4 s burst option, triggers page for every mod's pulse. The
bullet catch was removed 11-02 on the owner's word (no held-round model, no hand pose).

**Possibilities:** **Slow Motion** (unlock at a player level) -> **Longer** (the burst / meter a level) ->
**Deeper** (world speed 0.5 at level 1 down to 0.25 then 0.1) -> **Cheaper** (adrenaline cost a level) ->
Marksman, Dodger, Second Wind, Time Dilation -> new: **Lean Dodge** (unlock), **Matrix** (colour drain and
trails as the visual reward of the top level). A bullet catch is not here: it is the Fists' parked Catch node. Every other mod's slow-mo trigger (saber parry, shield block,
shove, cigarette) is a node in THAT mod's tree that asks SlowMo.

### 3.10 Miniboss (a reward source, not a tree)

**Today:** a miniboss fed by thralls, slow window on a thrall kill, greed rule, lives, score awards.

**Possibilities:** **Trophy** (a miniboss kill grants a free upgrade pick on the weapon that killed it),
**Greedy Trophy** (a Greedy kill grants a player level), **Inherit** (the player holds one of the miniboss's
thrall powers until the level ends). Needs: Gun Bonsai's `bonsai-choose-level-up-option` path for a free pick.

### 3.11 Gestures, Wheel, LaserSight, GunCards, TopHPBars

- **Gestures:** no progression. It reads hands and acts on nothing (WHO_OWNS_WHAT). Its events (taunt, both hands
  down) are the triggers other trees use.
- **Wheel:** no progression. UI; it already shows Gun Bonsai levels. One candidate only: the ring's own slow time
  while open, lengthened by the SlowMo tree.
- **LaserSight:** no progression (an aid; Accessibility is never gated and this sits next to it). Candidate if the
  owner wants one: Target Lock / Headshot Reaction as Gunslinger unlocks.
- **GunCards:** no progression. UI; shows level and XP already.
- **TopHPBars:** no progression; it must READ the new states (frozen, held, stunned) so every elemental and
  grappler node shows on the bar. Its snowflake, padlock and stun markers exist.

### 3.12 How the systems feed each other (the links, for the overview diagram)

| From | To | The link |
|---|---|---|
| Fists (Adrenaline, combos, Rage) | SlowMo | melee moments pulse and charge slow motion |
| SlowMo (rounds as actors, bullet catch) | Fists capstone | punching bullets in slow motion |
| Distance Grab (Iron Grip, Heavy Hitter, aim assist) | Fists Grappler | heavier Headlock, harder and aimed Headlock throw |
| Distance Grab (catch) | Fists Counter | catching a fireball by hand |
| Grapple (Scorpion), Whip (Pull and Punch) | Fists Counter | a pulled monster arrives into a counterpunch |
| Saber (Force Speed) | SlowMo | a Force gesture starts slow motion |
| Saber (Saber Over Shield) | ShieldSaw | the blade widens and parries on the shield |
| Rig (draws, cigarette) | Gunslinger, SlowMo | draws buff guns; the smoke slows time |
| Grenade (Skeet, Return Pull) | SlowMo, Distance Grab | shoot or recall your own grenade |
| Miniboss | every tree | a kill is a free pick or a level |
| Player levels | Grapple, SlowMo, Force, Second Blade, holsters, cigarette | the unlocks |

## 3.13 The player pool (owner, 11-02: "do we need to look at the player upgrades?")

Two things, both read from Gun Bonsai 0.10.6's own source (`ca.ancilla.bonsai/upgrades/`, cvarinfo):

- **Stock player upgrades** (per player, not per weapon; the weapon-info `disabled_upgrades` list cannot hide
  them): Bandoliers, Blast Shaping, ECM, Hazard Suit, Indestructable (only with that mod), Intuition, Juggler,
  Player Damage, Thorns, Tough As Nails. Whether the Hidden option hides these too: owner's pick pending.
- **Dilution.** Gun Bonsai offers `bonsai_upgrade_choices_per_player_level` = 4 random picks from every
  suitable player upgrade. Our player pool after the verdicts is about 45 nodes (SlowMo 10, Grapple 13, Distance
  Grab 10, Rig 8, Guard, Taunt, Critical Hits 3, Evasion) plus the stock ten if shown. Four random picks from 55
  means an unlock the player wants (Slow Motion, Grapple, the Force) may not show for many levels. Fix pending the
  owner's pick: unlocks shown first, or more choices grouped by mod, or Gun Bonsai's four as they are.
- Note: a melee weapon's level costs half (`bonsai_level_cost_mul_for_melee` 0.5): fists and sabers level twice
  as fast as guns, which suits trees this deep.
- **The owner's rotation also runs "Universal Kill Rewards" v1.0** (`som_kr`, read 11-02): every kill drops 1 to 3
  bits of health, armour or ammo (ammo for the current weapon). That stands in for Gun Bonsai's Dark Harvest, the
  three Leeches and much of Bandoliers, and overlaps our Blood Rush (heal on a fist kill). The owner: "this will
  negate some GB player upgrades"; the per-upgrade verdicts below take it into account.
- **Owner, 11-02: "we get rid of stock GB ones that don't mesh with us."** The pruning is of Gun Bonsai's stock
  upgrades (player and weapon), not of ours; every one of ours stays. The player pool's dilution is accepted.
- **Kill Rewards folds into GBOVR as a player path (owner, 11-02), credit SoM:** Scavenger (more bits a kill),
  Rich Bits (each bit worth more), Magnet (bits fly to you). Its menu rows come along; the owner drops the pk3.
  Nodes in section 4.
- **Kill Rewards' permissions** (its `readme.txt`): "Feel free to use anything in this mod for yourself. It really
  isn't that complicated of a mod, so I don't need credit, unless you wanted to." Author: SoM. We may fold it,
  change it, or run beside it; we credit SoM either way. Its bits are plain `Health` and `BasicArmorBonus`
  subclasses plus an ammo bit that reads the current weapon's ammo types; ZScript 4.2.4.
- **Stock player upgrades, owner's verdicts (11-02):** shown: Bandoliers, Blast Shaping, ECM, Hazard Suit, Tough
  As Nails. Hidden with the option: Intuition (HP Bars does it), Juggler, Player Damage, Thorns. Indestructable
  needs its own mod; untouched.
- **Stock weapon upgrades on our melee weapons, owner's verdicts (11-02):** keep showing: Cleave, Sweep, Shield,
  Swiftness, Weapon Damage. Hidden: Dark Harvest, Life Leech, Armour Leech, Ammo Leech (Kill Rewards covers
  them), and the elementals and Rapid Fire already disabled by `bonsairc.rsq`. So the L1 "stock-upgrade option"
  is a PRUNED list, not all-or-nothing. **Its row (owner, 11-02): "Stock Gun Bonsai Upgrades: Silvergun / All"**,
  Silvergun the default (the pruned list), All = everything stock; no None ("that's goofy"). **The pruned list
  applies to BD22's guns too** (he runs Kill Rewards with BD22, so Dark Harvest and the Leeches are covered there
  as well). Mechanism unchanged: the hidden names are appended to each weapon info's `disabled_upgrades` at
  creation and on a cvar change (section 2 of the handoff); the four player upgrades need a second route, since
  the player bag has no such list: our own `IsSuitableForPlayer` cannot be put on stock classes, so GBOVR's
  handler strips them from the offered list on `bonsai-level-up` (to prove on the rig).
- **Kill Rewards verdicts (11-02):** bits drop as today (random by the ratios; the What I Need and By Monster
  designs are not wanted); Scavenger, Rich Bits, Magnet and Lucky Kill all in.
- **Blood Rush reworked (11-02):** a fist kill under the Berserk gives 5 + 5 lv armour, not health (Kill Rewards
  already drops health).
- Distance Grab verdict (11-02): Body Shield in as an unlock, with his rule: **what it stops hurts it, so a held
  barrel can go off in your hands**; Corpse Grab, Catch and Pull Small struck.

## 3.14 Kill Rewards, folded in (owner, 11-02)

**His words:** "I love the current implementation, I don't want to lose anything, but the menu I do not
understand." "I would kill a boss or legendary champion and like 200 bits would come out, it was awesome" (or
2000). And: "an option to have Kill Rewards On by Default: Yes / No, which lets us get the bits from the start."

**What it does today** (`som_kr.txt`, read in full): on a monster's death, N bits burst out (spawned 32 up, thrown
1-6 sideways and up, random heading). N: in **HP Ratio** mode, spawn health / 10 (x3 for a boss), at least 1; in
**Range** mode, a random 1-3 (x3 boss). Each bit is health (25, red: SoM's readme says "a single point", his code
says `Inventory.Amount 25`), armour (10 green armour, blue) or ammo (5 rounds of the gun in hand, or of any gun
carried, green), weighted 1:1:1. Bits live forever unless a timer is set. Three BD
boot-smear corpses are blacklisted. The fountains the owner loves are HP Ratio: a Cyberdemon gives 1200.
(Range mode has a bug in the source: its chance test is inverted, so at 100% only bosses drop. HP Ratio is the
mode that works and the one that is kept as base; Range mode is dropped from the menu, its cvars kept.)

**The fold.** The handler, the three bit classes and every cvar move into GBOVR's `rsq/` tree under our names
(`rsqgb_kr_*`), credit SoM in CREDITS and the README, behaviour unchanged. Then:

- **Menu row: "Kill Rewards: On"** (Yes by default, the owner's pick). Yes = bits from the first kill, no unlock
  needed. No = no bits at all unless a path node below grants them. One row, one meaning.
- **The menu, in plain words** (replacing Mode / Ratios / Ticks x Multiplier; every old cvar still exists and sits
  on Tuning and Debug with its old name, so nothing is lost):

| Row | Default | Means |
|---|---|---|
| Kill Rewards | On | Monsters burst into bits when they die. |
| Bits per Kill | Standard | How many: Few (1 per 20 health), Standard (1 per 10, today's), Many (1 per 5). |
| Boss Fountain | x3 | A boss gives this many times more: x1, x3 (today's), x5. |
| What Drops | Even Mix | Even Mix (1:1:1, today's), Mostly Health, Mostly Armour, Mostly Ammo, What I Need (see below). |
| Bits Vanish After | Never | Never (today's), 15 s, 30 s, 1 min. |
| Ammo Bits Give | The Gun in Hand | Or Any Gun I Carry. |
| Bits Fly to Me | Off | Bits inside 1 m drift to your hand (the Magnet node turns this up). |

- **"A way for monsters to drop them that makes sense"** (owner's pick pending, section 4 asks):
  - **What I Need:** the mix leans to what you are short of: under half health, more red; armour under 50, more
    blue; the gun in hand under a quarter of its ammo, more green. Doom's own economy, read live.
  - **By monster:** gun-carrying zombies drop ammo bits of their gun (bullets, shells, chaingun bullets); beasts
    (imps, demons, cacodemons) drop health; armoured ones (knights, barons, arachnotrons, mancubi) drop armour;
    bosses drop the even mix as a fountain.
  - **As today:** random by the ratios.

- **The path** (player nodes, offered at player level-ups; everything above works at level 0):

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Scavenger (new) | root (player) | 1-3: +25% bits a kill a level | GBOVR | more bits | - |
| Rich Bits (new) | Scavenger 1 | 1-3: a health or armour bit is worth 2, 3, 4; an ammo bit 8, 11, 14 | GBOVR | bits glow brighter a level | - |
| Magnet (new) | Scavenger 1 | 1-3: bits inside 2, 3, 4 m drift to your hand | GBOVR | a faint pull trail (Combat FX) | - |
| Lucky Kill (new) | Rich Bits 1 | 1-3: a kill that was a critical, a Finisher or a Score big moment drops double, triple, x4 | GBOVR (reads `crit`, `finisher`, Score) | a bigger burst | `lucky` |

Sprites: SoM's three orbs (`ABITA0`, `HBITA0`, `MBITA0`) stay, recoloured by RS Combat FX's palette if the owner
wants; the series' lock-diamond colours are not used here (bits are not marks).

## 4. The trees

Written per system once the owner approves its branches (section 3). Every node: parent(s), what each level
does in numbers, who owns the move, art, Score hook. "Exists" = shipped today at those numbers; "new" = to build.
The owner strikes or keeps each node; a struck node is deleted here, not kept as history.

**Base numbers the Fists tree stands on** (Melee @ 9cc70f6b2): a punch does 10 x (1 + power), power 0 at 2 m/s
to 1 at 7 m/s (`gloves.zs:707`); the uppercut lifts 5 to 9 map units a tic and knocks back 2 to 5 (`:756`); the
Headlock holds up to mass 400 for 3 s, its toss at 3 m/s or more hits for 0.5 x kg x v^2 / 15 (`headlock.zs:439`);
the gun-butt shove does 14, 62 under the Berserk (`shove.zs:308`); **the punch does not read the Berserk at all**
(no `PowerStrength` in `gloves.zs`). Hit sparks: jab orange, hook blue, uppercut violet, each about a monster's
head.

**Art and sound rule, every tree (owner, 11-02): RS Ballistics and RS Combat FX are the source for art and
sounds, as a general rule** (the owner's own packs, cloned at `E:\DOOMWork\RS_Ballistics` and `RS_CombatFX`).

**The hit-art family (owner, 11-02, from the contact sheets in `GunBonsaiOffhandVR/docs/art/`):** three sources,
three styles, so a rule, not a mix:
- **CvS2 sparks are the blow itself**: jab (Normal Spark), hook and swat (Special), uppercut (Super), Guard
  (Guard), as Melee ships them, all 15 frames (24 for Guard) already played. Small, about a monster's head.
  "Jab, hook, uppercut and guard need work": the owner wants them better, not bigger; the unused CvS2 colourings
  2-4 and the three Slash sets are the material for that (e.g. a colouring per hand, Slash for the saber).
- **kiddolink's five impacts (paid; "I want that one in there for sure") are what a blow DOES, and only on the
  moments that earn it**: combos (Three-Hit's third blow, Dempsey, Finisher), criticals, perfects (Parry, perfect
  block), elemental fists and the launches. "I can't be seeing those for every damn punch." Recoloured per element
  with the highlights kept white-hot (sheet 1), scaled 0.75x for a combo step up to 1.5x for a Finisher or
  critical, and **frames by level**: a node at level 1 plays frames 1-3 of the burst, +2 a level, the full 9 at
  the cap. 96 px, 9 frames each (not 10 as the handoff said).
- **Hit Effect 01** (48 px pixel art) does not match either; not used.
- **Candidate (owner, 11-02: "this whole bottom row is promising"):** the Thunder Force IV "Fire Leo 04 Rynex"
  rip (Magma Dragoon, "credits not necessary"; Technosoft's art, same standing as the CvS2 rips): its bottom
  row of shaded energy spheres in blue, white, orange and red. Fits Kill Rewards' bits (red health, blue
  armour, a recolour for ammo), the Force Grip's held orb and the Freeze grenade's burst. Its path on disk is
  needed when it is used.
- **Two more candidates (owner, 11-02, pasted sheets):** a FIREBALL and FIREBALL COLLISION strip (orange burst,
  about 11 collision frames): Fire Fist's flare and the Incendiary grenade; and a strip of dark spheres with blue
  arcs crawling over them (12 frames, two flash frames): Shock Fist's arc, the Stun grenade, Force Lightning's
  held charge. Paths on disk needed when used.
- Sounds for all of the above from RS Combat FX / RS Ballistics, never from the example mods.
The spark's size follows Melee's Hit Spark Size slider.

**Two fists, two records, as today (owner, 11-02: "it was fine before").** Each hand earns XP from the damage it
does, levels on its own and picks its own upgrades; a fist's upgrades apply to its own punches. Nothing in the
tree changes that. Each glove may carry one element.

### 4.1 Fists (owner approved all eight branches, 11-02)

**A. Power** (the fist hits harder and heavier)

| Node | Parent | Levels (numbers) | Owns the move | Art | Score hook |
|---|---|---|---|---|---|
| Heavy Hands (exists) | root | 1-4: hit-stop 2, 3, 4, 4 tics (+2 at half power or more); knockback +25% a level | Melee | spark frames 3/5/7/9 | `hit.heavy` |
| Haymaker (exists) | Heavy Hands 1 | 1-5: damage x (1 + lv x (0.15 + 0.35 x power)); a full-power punch at 5 is x3.5 | GBOVR (damage) | spark scale +10% a level | - |
| Body Blow (exists) | Heavy Hands 2 | 1-4: a hit below the chest winds it 35 + 18 lv tics; it acts 20% + 7% lv slower | GBOVR (`RSQ_Dazed`) | spark drawn low, grey puff | `hit.body` |
| Uppercut (new unlock) | Heavy Hands 1 | 1: a rising punch is an uppercut (without it a rising punch reads as a jab and does not lift); 2-3: lift +2 units a tic a level (an imp 0.9 m -> 1.4 m -> 1.9 m) | Melee | Super Spark violet, frames 4/7/10 | `punch.uppercut` |
| Launcher (new) | Uppercut 2 | 1-3: the lifted monster is held in pain for the flight and staggers 10 + 10 lv tics on landing; lift +3 units a tic a level on top | Melee | the spark trails up with it (3 frames) | `launch` |
| Juggle (new) | Launcher 1 | 1-3: a punch on a monster you launched inside 2 s, while it is off the floor, does x1.5 + 0.25 lv and lifts it again | GBOVR (damage), Melee (re-lift) | the spark at the air hit, white | `juggle` |
| Meteor (new) | Launcher 2 | 1-3: a launched monster that falls onto another hurts both for 10 + 10 lv + its fall speed (the Battering Ram pattern, `RSQ_Rammed`, asked by Melee as the ShieldSaw does) | Melee asks GBOVR `ram` | dust ring on landing | `meteor` |
| Wallflower (exists as Wall Splat; renamed by the owner 11-02, the class `RSQ_Upgrade_WallSplat` stays for saves) | Haymaker 2 | 1-5: a monster knocked into a wall at 3+ units a tic takes 5 + 5 lv (x2 at 6+), reels 10 + 5 lv tics | Melee | smash burst (exists) | `splat` |
| Knockdown (exists) | Wall Splat 2 or Body Blow 3 | 1-5: damage inside 2 s of 44%, 38%, 32%, 26%, 20% of its start health puts a non-boss down for a 3, 4, 5, 6, 7 count | GBOVR (`RSQ_Dazed`) | the count (SPO announcer, exists) | `knockdown` |
| Ground Pound (new) | Launcher 3 | 1-3: both fists swung down together at 3+ m/s (Gestures' "both hands down"): a shockwave 2 + 0.5 lv m round you for 20 + 10 lv; with Knockdown owned, non-bosses in it go down for a 2 count | Melee (the move), Gestures (the read) | dust ring (Random Sprite Rips), screen thump | `pound` |
| Clear Out (new; owner 11-02) | Heavy Hands 2 | 1-3: both palms out, thrust forward together at 2.5+ m/s: everything in a 90-degree wedge 2 + 0.5 lv m in front is shoved back hard (Force Push's throw, by hand) for 10 + 5 lv and staggers 10 tics; empty hands or fists. Needs: a two-palm thrust read in Gestures (it has "both palms out" still, and a one-hand thrust) | Melee (the move), Gestures (the read) | a wide RS Combat FX shockwave, 3 frames a level | `clearout` |

**Power: BUILT 11-02 (L2, branch A).** Gun Bonsai VR: the new nodes are in `rsq/zscript/up_fists.zs`, the existing
ones in `up_gloves.zs` now take their parents and caps as above; Star Punch is no longer offered (kept for saves).
Melee: the Uppercut unlock in `gloves.zs` Deliver; the launch marker (Launcher's landing stagger, Juggle's window,
Meteor) in `launch.zs`; Ground Pound and Clear Out in `twohand.zs`, on RSQ Gestures' `rsqg_pair` (0 both hands down,
3 both palms thrust, the latter new in Gestures). Gestures' two-hand events are also read while a mod asks
("pair.ago"), so its Two-Hand Events row may stay off. Melee rows Ground Pound and Clear Out (off) play them at
level 1 without Gun Bonsai VR. Score hooks: hit.heavy, hit.body, punch.uppercut, launch, juggle, meteor, pound,
clearout. **Headless runs 11-02** (`tools/qzd_hidden_run.ps1`, QZD 17.3, doom2 + Melee + Gestures + Gun Bonsai 0.10.6 +
GBOVR + a test-only probe that grants nodes and lands punches through Melee's own Deliver): parses, 0 warnings. The
offer list follows the parents (nothing learned: Heavy Hands only of the Power nodes; Heavy Hands 2: + Haymaker, Body
Blow, Uppercut, Clear Out; Launcher gone at its cap of 3). A rising punch without Uppercut landed as a jab, with it as
an uppercut. Juggle: an off-hand jab 8 tics after the launch hit for 35 (20 x 1.75) and lifted it again; Launcher 3:
"landed, staggered 40 tics". Meteor 2: the falling imp hit the one below for 47 each (30 + its fall speed 17). Ground
Pound 1: a 2.5 m/s "both hands down" refused, 3.5 m/s hit 6 imps for 30 each, paid as `RSQML_GloveBlow`, Knockdown
owned. Clear Out 1: 2 imps in front shoved for 15, the one behind untouched. **Not provable headless:** Gestures'
reading of real hands (the thrust and the down are sent by the probe here), how any of it looks. **Art not yet
done** (frames by level, the kiddolink launch bursts, the dust ring): its own pass. **For the owner:** at full levels
the approved lifts stack (Uppercut 3 + Launcher 3, with Heavy Hands' knock): a full-power uppercut threw an imp up at
30 map units a tic, about 16 m of air. **Owner, 11-02: "cap it".** Melee's Tuning row Uppercut Lift Cap (`rsqml_punch_lift_cap`,
3 m of air, 0 = no cap) bounds every launch (uppercut, Launcher, Juggle, Headlock Uppercut); headless: the same stack
now launches at 13.0 (3 m), and 30.0 again with the cap at 0.

**B. Elemental** (one element per glove; picking one closes the other three on that glove; the other glove may
take a different one)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Explosive Fist (new) | Haymaker 1 | 1-4: a punch at half power or more blasts 64 + 16 lv units round the hit for 10 + 5 lv (not you); under the Berserk the radius doubles | GBOVR (the blast, claimed to the glove) | kiddolink impact white, frames by level, a flash | `fist.explosive` |
| Frost Fist (new) | Body Blow 1 | 1-4: the monster freezes solid 1 + 0.5 lv s (no action, blue tint; HP Bars' snowflake); the next punch on a frozen monster shatters it: x2 + 0.5 lv and the freeze ends; a boss is slowed 50% instead | GBOVR (`RSQ_Dazed.frozen`, new state) | spark recoloured blue, ice shards on the shatter | `shatter` |
| Shock Fist (new) | One-Two 1 | 1-3: the hit arcs to lv nearest monsters within 3 m for 40% + 10% lv of the punch, each staggered 8 tics | GBOVR | a beam (Random Sprite Rips) recoloured yellow, 2 frames a level | `arc` |
| Fire Fist (new) | Heavy Hands 2 | 1-4: the monster burns 3 a half second for 2 + lv s; punching a burning monster flares it: +50% | GBOVR (its own burn, not Gun Bonsai's) | spark orange-red, fire frames | `burn` |

**Elemental: BUILT 11-02 (L2, branch B), all in Gun Bonsai VR** (`up_fists.zs`; the freeze and the burn are new
`RSQ_Dazed` states in `core.zs`: `IsFrozen` / `Freeze` / `Thaw`, `IsBurning` / `Ignite`; each element's own hits go
through `RSQM.GloveHit`, a helper paid to the glove and marked Gun Bonsai PRI_NULL so no stock upgrade procs from it).
Frozen = the engine's `freezetics` and its Ice translation; a boss gets Body Blow's winding at full factor instead.
**Headless 11-02:** the four offered together once their parents were held, and learning one closed the other three
on that glove only (main Frost, off Explosive; main Shock, off Fire). Frost: a demon frozen 52 tics, the next punch
75 (30 x 2.5) and the freeze ended. Explosive: 4 imps within 80 units took 15 each, the one 400 away none. Shock: 10
(half the punch) arced to the nearest imp. Fire: 3 every 17 tics, the flare punch 30 (20 x 1.5). **Look:** particles
(white burst, ice shards, a yellow arc, flames) and stock sounds (rocket blast, Hexen's ice break, plasma hit) until the
art pass; HP Bars' snowflake waits for item 7.

**C. Combos** (the chain is read from Melee's `punch.chain` and a new `punch.kinds`, the last three kinds)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| One-Two (exists) | root | 1-4: each alternating-hand hit inside 0.5 s adds 15% lv, up to 4 in a row | GBOVR | - | `combo.count` (the chain length, always on with One-Two) |
| Three-Hit (new) | One-Two 2 | 1-3: jab, jab, hook inside 1 s: the hook does x1.5 + 0.25 lv, staggers 10 tics, full spark | GBOVR; Melee exposes `punch.kinds` | the hook's spark at 10 frames | `combo.3` |
| Dempsey (new) | Three-Hit 1 | 1-3: alternating hooks each inside 0.6 s: the re-hit window shrinks 6 -> 4 -> 3 -> 2 tics so you can punch faster, and each hook in the run adds 10% lv | Melee (re-hit), GBOVR (damage) | sparks alternate blue and orange | `combo.dempsey` |
| Finisher (new) | Three-Hit 2, needs Executioner owned | 1-3: the last hit of a 3+ chain on a staggered monster at 25% + 5% lv health or less kills it, full burst at 1.5x, a 300 ms slow-mo pulse (with SlowMo) | GBOVR (Executioner's rule) | the full burst, 1.5x | `finisher` |

**Combos: BUILT 11-02 (L2, branch C).** Melee: `punch.kinds` (this player's landed punches inside 1 s, oldest first,
digits kind + 1, so jab, jab, hook = 112) and `punch.run` (the Dempsey run: alternating hooks, each inside 21 tics) on
`RSQML_Service`; in a run a glove with Dempsey re-arms at Dempsey.rehit. Gun Bonsai VR: Three-Hit, Dempsey, Finisher in
`up_fists.zs`; Executioner's kill-after-resistance probe is now `RSQ_Upgrade_Executioner.KillBlow`, which Finisher uses.
Finisher's "3+ chain" = One-Two's chain or three kinds inside a second, whichever is longer. **Headless 11-02:** the
offer list followed the parents (Three-Hit at One-Two 2; Finisher only with Three-Hit 2 and Executioner). Jab, jab, hook
on a demon: 20, 26, 64 (the hook 20 x One-Two 1.6 x Three-Hit 2.0). Four alternating hooks: 20, 28, 38, 49 (Dempsey's
+10% a hook on top of One-Two). Jab, jab, hook, jab on a Baron at 300: the fourth killed it (191), where Executioner 1
alone (below 150) would not. **Not provable headless:** Dempsey's faster re-arm (the probe lands punches through
Deliver, not the swing reader); the look (the hook's full spark, the Finisher's burst at 1.5x) waits for the art pass.

**D. Counter** (defence turns into offence)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Guard (exists; a player upgrade today) | root | Owner, 11-02: a **Start With Guard** toggle (Melee row; on = Guard at level 1 from the start, off = earned at a player level-up). Either way it levels: 1-4: both fists up at the face: a blow from in front does 60%, 50%, 40%, 30%; a blow of 35 + 10 lv breaks it | Melee | Guard flash (exists) | `guard` |
| Parry (new) | Guard 1 | 1-3: a Guard whose hands move INTO the blow (1 m/s toward it, inside 4, 6, 8 tics of impact): no damage, double knock, the attacker staggers 17 + 9 lv tics | Melee (`guard.zs`) | Guard flash white and bigger; CvS2 Guard set 2 | `parry` |
| Reflect Guard (new; owner 11-02) | Guard 2 | 1-3: a missile that hits the Guard is turned back at its shooter at x1.0 + 0.25 lv (a Hadouken without the punch); at 3 bullets are turned too (a Guard-wide muzzle block, the ShieldSaw's rule) | Melee (`guard.zs`), ShieldSaw's return pattern | Guard flash + the missile's own trail reversed | `guard.reflect` |
| Absorb and Release (new; owner 11-02) | Reflect Guard 2 | 1-3: every blow and shot the Guard takes charges it (the damage soaked, up to 100 + 50 lv); throw both hands out (Gestures' "both hands apart") to release it: a blast 3 + lv m round you for the charge, knocking monsters back; the charge drains 5 a second unreleased | Melee (the move), Gestures (the read) | the Guard flash grows with the charge; release = kiddolink burst at 2x, white | `guard.release` |
| Counterpunch (exists) | Guard 1 | 1-4: a punch during its wind-up does x1.25 + 0.25 lv and staggers 17 + 9 lv tics | GBOVR | counter sound (exists) | `counter` |
| Swat Back (new) | Guard 1 | 1-3: the open-palm swat sends the missile at its shooter instead of aside, at x1.0 + 0.15 lv damage | Melee (the swat) | Special Spark blue, frames 4/7/10 | `swat.back` |
| Hadouken (exists) | Swat Back 1 or Counterpunch 1 | 1-4: a punched missile returns at x1.25 + 0.25 lv, 15% lv faster | Melee | Super Spark + Hadouken burst (exists) | `hadouken` |
| Catch (new, **Option, off**) | Hadouken 2 | 1-3: an open hand on a missile at under 1.5 m/s holds it 2 + lv s; thrown through Distance Grab's throw at x1.5 + 0.25 lv. Parked: needs a held model and a hand pose (owner, 11-02) | Melee, Distance Grab (throw) | - | `catch` |
| Bullet Time Fists (new, **off until headset-seen**) | Hadouken 3, needs SlowMo | 1-3: in slow motion a punch through a slowed round (`RSQSM_Round`) returns it to its shooter at its own damage x1.5 + 0.5 lv. To check first: the round is a Projectile with the monster as target, so Hadouken's missile test may already see it | Melee | the streak turns round, Super Spark | `bullet.punch` |

**Counter: BUILT 11-02 (L2, branch D).** Gun Bonsai VR: Swat Back (glove), Parry, Reflect Guard, Absorb and Release
(player, `RSQ_GuardPerk`) in `up_fists.zs`; Counterpunch and Swat Back stand on the player's Guard (`GuardOwned`: learned,
or Melee's Start With Guard row for level 1), Hadouken on Swat Back or Counterpunch. Melee: the row **Start With Guard
(Gun Bonsai VR)**, off by default so nothing changes until it is turned on; `guard.zs` does Parry (both hands driven
forward at 1 m/s inside Parry.window tics; **found headless: the push carries the hands out of the Guard's box, so the
Guard had dropped by the time the blow landed; a parry now counts while the Guard was up within the same window**),
Reflect Guard (missiles about to hit, from in front; at 3, a ranged non-melee hit more than 96 units off is sent back
at its shooter at the same multiplier), Absorb and Release (charge = what got soaked, a parried blow, a reflected roll;
released on Gestures' "both hands apart", rsqg_pair 1). One `SendBack` in `gloves.zs` now sends back every returned
missile, and the returned list carries each one's damage multiplier. Catch and Bullet Time Fists: not built (parked
off, as designed). **Headless 11-02** (the probe drives Melee's own controller stand-in, `RSQML_Sim`, to raise and
push the Guard): the offer lists follow the parents (no Guard: no Counterpunch, Swat Back, Parry; Hadouken only after
Swat Back); Guard 2 soaked 20 to 10; two blows during a push: 0 through, "PARRY"; a bullet from an imp 300 away: 0
through, the imp took 18 (10 x 1.75); a fireball at the raised Guard went back and hit its frozen imp for 32 (18 x
1.75); charge 65 released for 64 on both imps in reach; Swat Back sent a fireball back for 7 (6 x 1.15); the Hadouken,
now on SendBack, 37 (21 x 1.75). **Not provable headless:** real hands, the look.

**E. Grappler** (the off hand; the Headlock and its throw are base)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Human Shield (exists as a Melee option; becomes the unlock) | root | 1: hold as long as the grip (a minute at most), facing away; 2: it soaks every shot; 3: shots that hit it hurt it x1.5 | Melee | - | `shield.human` |
| Headlock Uppercut (new) | Human Shield 1, needs Uppercut | 1-3: an uppercut on the held monster lets go and launches it at x1.5 the lift, for x1.5 + 0.25 lv | Melee | Super Spark, the launch trail | `headlock.launch` |
| Heavier Headlock (new) | Human Shield 1 | 1-3: the mass cap 400 -> 600 (Arachnotron), 800, 1000 (Baron, Mancubus); Distance Grab's Iron Grip adds 100 a level on top | Melee (reads `plevel IronGrip` too) | - | - |
| Slam (new) | Heavier Headlock 1 | 1-3: swing the off hand DOWN at 3+ m/s while holding: the monster hits the floor for the toss damage x (1 + 0.25 lv) and a 1.5 m shockwave staggers what stands there 15 tics | Melee | dust ring + Super Spark | `slam` |
| Throw Into (new) | Human Shield 2 | 1-3: the toss already hurts a body it hits (`RSQML_Tossed`); this makes it x (1 + 0.25 lv) and, with Distance Grab, bends the throw 12 degrees onto a monster | Melee, Distance Grab (aim) | smash (exists) | `throw.into` |
| Chokehold (new, candidate) | Human Shield 2 | 1-3: a held monster takes 2 + lv a second and cannot attack while held | Melee | - | `choke` |

**Grappler: BUILT 11-02 (L2, branch E).** Gun Bonsai VR: the six in `up_fists.zs` (`RSQ_GrappleUpgrade`), offered
only to the off glove; Headlock Uppercut needs Uppercut on either glove. Melee reads them from the off glove
(`RSQML.GrappleLevel`) wherever it is: Human Shield replaces the row under Gun Bonsai VR (`ShieldOn`), its level 2-3
redirect in `RSQML_Body` (a blow from within 60 degrees of the held monster's side goes to it); Heavier Headlock in
`FindMonster` (Iron Grip on top only with it learned); Slam and Throw Into in `ThrowSwing` (Throw Into marks the thrown
monster, `RSQML_ThrownInto`, and `RSQML_Body` multiplies what it hits, so Distance Grab's flight counts too; the 12-degree
bend is on Melee's own toss, Distance Grab having its own aim assist); Chokehold in `TickCollars`; Headlock Uppercut in
`Deliver` (the damage is Melee's: the uppercut is the main glove's, so an off-glove node never sees that punch's
damage). **Headless 11-02** (the probe moves the off hand through `RSQML_Sim` and presses the grip with Melee's own
`rsqml_hgrip` event): offered on the off glove only, after their parents; Chokehold 3 a second; Human Shield 2: a 10 at
you went to the held imp (you 5000 -> 5000); Headlock Uppercut 35 (20 x 1.75), let go, launched up 13.5 (9 x 1.5);
a Baron (1000) not held at the default 400, held at Heavier Headlock 3; Slam at 4.9 m/s: 30; Throw Into: bent onto a
monster, the impact 29 -> 36 on both. **Note:** Melee's own toss stops within about 2 m on the ground (friction), as
before. **Not provable headless:** real hands, the look.

**F. Berserk** (Doom's Berserk pack is the fists' power-up; today it does nothing to a punch)

**Base, a Melee fix (owner, 11-02): while you hold the Berserk a punch does x5** (a full-power punch 100; Doom's
own fist is x10). No upgrade needed; the branch builds on the pack.

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Rage (new) | root | 1-3: while the Berserk lasts every fist upgrade you own counts 1 level higher (2: and the hit-stop doubles; 3: and knockback x1.5) | GBOVR (the level bump), Melee (reads it) | spark tinted red, full frames | `berserk.punch` |
| Blood Rush (new) | Rage 1 | 1-3: a fist kill under the Berserk heals 5 + 5 lv (the Berserk's own health rule, repeated) | GBOVR (OnKill) | red flash | `bloodrush` |
| Berserk Meter (new) | Rage 2 | 1-3: fist damage fills a meter (300 points); full, it grants a Berserk of 20 + 5 lv s without a pack | GBOVR (gives `PowerStrength` with a timer) | a meter on the skin HUD | `berserk.earned` |

Note: Doom's Berserk strength lasts the whole level once picked up (only the red fade decays), so "extend
Berserk" is not a node; the meter is the way to earn one without a pack.

**Berserk: BUILT 11-02 (L2, branch F).** Rage raises the glove's other nodes' levels by 1 while any PowerStrength is
held (`RSQ_Upgrade_Rage.Tick`; taken back when it ends or the glove leaves the hand), so Melee's moves and Gun Bonsai
VR's own nodes all see it; `Has` / `LevelOf` look through the raise, so it never opens a child early. Blood Rush follows
the owner's 11-02 rework: **armour** (5 + 5 lv), not health. Berserk Meter: 300 points of that glove's fist damage
without the Berserk give `RSQ_EarnedStrength` (a PowerStrength that runs out after 20 + 5 lv s); its meter is not on
the HUD yet. Melee reads any PowerStrength for the x5. **Headless 11-02:** under PowerStrength Heavy Hands and Haymaker
read 1 -> 2 and back after; Knockdown stayed unoffered (Body Blow 2 raised to 3 did not open it); a full punch 200
(20 x 5 x Haymaker 2); Blood Rush gave 15 armour (its level 1 raised to 2 by Rage); the meter: 240 points no
Berserk, 300 an earned one ("berserk yes, earned yes").

**G. Gun hand** (the shove; with BD22 VR loaded the strike is BD's own and Melee only reads it landing)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Pistol Whip (new) | root | 1-3: a shove or BD's pistol whip staggers 10 lv tics longer, and the next shot on that monster inside 2 s does x1.25 + 0.25 lv | GBOVR (a mark on the monster, `ModifyDamageDealt`) | the mark: a brief white ring | `whip.pistol` |
| Rifle Butt (new) | Pistol Whip 2 | 1-3: a shove with a long gun at 4+ m/s knocks a non-boss down for a 2 + lv count (Knockdown's count) | Melee (shove) asks GBOVR `stagger` / knockdown | the count | `butt.knockdown` |

**Gun hand: BUILT 11-02 (L2, branch G). A call made here, for the owner to keep or change:** Pistol Whip and Rifle
Butt are glove nodes (this table lists them in the Fists tree, not marked player), and the shove reads the best of
either glove, since a gun is in hand when it lands. Pistol Whip's mark sits on the monster (`RSQ_Dazed.Mark`, its
`ModifyDamage` on the victim's side, so a gun's shot sees it: one tic of hits, a blast's pellets all count). Rifle Butt:
a long gun = weapon slot 3 and up; not on BD22 VR Reloaded's own strike (its speed is not ours to read).
**Headless 11-02:** a 4.5 m/s shove with the pistol: "whipped (level 2)", the next pistol shot 26 (15 x 1.75); a 5 m/s
shove with the shotgun: knocked down (Rifle Butt).

**H. Taunt** (needs Gestures' two-hand events on; a player upgrade)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Taunt (new) | root (player) | 1-3: "both hands apart" with empty hands or fists: monsters within 10 m turn on you, and your next punch inside 3, 4, 5 s does x2; at 3 monsters within 3 m also stagger 10 tics | Melee (the move), Gestures (the read) | a shout (stock Doom player sound), a pulse round you | `taunt` |

**Taunt: BUILT 11-02 (L2, branch H).** A player node offered while RSQ Melee and RSQ Gestures are loaded; "both hands
apart" releases the Guard's charge first if there is one, else it is a Taunt (Melee `twohand.zs`); the shout is the
player's `*pain100` until the art and sound pass. **Headless 11-02:** 3 imps turned on you, the next punch doubled
(60 = 20 x Haymaker 1.5 x 2).

**I. Critical Hits (owner, 11-02: "consider the concept of critical hits as a player upgrade")**

A player upgrade, not a fist's. **The owner's example (11-02): Mikk's "Critical Shots" (`mk-crits.pk3`, read
from his rotation folder, concept only; its sounds and sparks are ripped from other games and are not ours to
use).** Its three rules, read from `csh_classes/core.txt`: a **critical** is a hit landed while the monster is in
the first 10 tics of its attack wind-up: the monster is stunned (frozen in its pain frame 50 tics, no pain
interrupts) and the hit does x2; hits on a stunned monster do x2 again; at most 3 crits per 15 tics (anti-spam).
A **headshot** is an inflictor landing in the top fifth of the monster: x4 hitscan, x2 projectile, less when
stacked by a multi-pellet shot. A **backstab** is a melee hit from behind inside an angle: x10. Each has its own
flash and sound.

Here, as nodes (the art is ours: kiddolink's bursts and the CvS2 Super Spark for the big moment, RS Combat FX /
RS Ballistics for sound and flash; the owner: "especially for melee, maybe in general"):

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Critical Hits (new) | root (player) | a hit during the monster's attack wind-up is a critical: x1.5 + 0.25 lv, and it is stunned 1 s (`RSQ_Dazed.Stagger`, which Executioner reads); hits on a stunned monster do x1.25 + 0.25 lv; at most 3 crits per 15 tics. Scope (owner, 11-02): level 1 melee only (fists, sabers, ShieldSaw, whip); level 2 adds guns; level 3 the numbers | GBOVR (`ModifyDamageDealt`, `RSQ_Dazed`) | the full kiddolink burst at 1.5x + Super Spark; a Combat FX hit sound | `crit` |
| Headshot (new) | Critical Hits 1 | a hit whose contact point is in the top fifth of the monster: x2 + 0.5 lv (a punch: the glove's contact point, so an uppercut or hook to the chin is a headshot; a gun: the puff). Stacked pellets count half | GBOVR | a smaller burst at the head, red | `headshot` |
| Backstab (new) | Critical Hits 1 | a melee hit from behind, inside 60 degrees of the monster's back: x3 + lv; a kill this way makes no noise | GBOVR | the burst, white, no sound | `backstab` |

Overlap, on purpose: Counterpunch (a fist's node) is the same moment as a critical. With both learned they stack
once (the critical's stun, Counterpunch's longer stagger and bigger multiplier), never twice (the example's
"don't multiply" rule). A Finisher's blow and a Three-Hit's third hit always count as a critical.

**Critical Hits: BUILT 11-02 (L2, branch I).** Player nodes (`RSQ_CritPerk`). A melee blow = Melee's damage types
(Melee, Kick) or a weapon Gun Bonsai calls melee. The critical's flash is RSQ Melee's Super Spark (by name) and the
counter sound until the art pass; Headshot red, Backstab white particles. Counterpunch on the punching glove: the stun
stands, Counterpunch's multiplier instead of the critical's. A Three-Hit's third hit counts as a critical.
**Headless 11-02:** a punch into a demon's wind-up 35 (20 x 1.75), the next on the stunned demon 30 (20 x 1.5);
Headshot 500 and Backstab 800 under an earned Berserk with Haymaker 2 (20 x 5 x 2 x 2.5, and x 4).

**ART PASS (11-02, L2):** Melee `tools/bursts.py` builds ten burst sets from kiddolink's zip (MLK1-5 as drawn or white,
MLKE/F/S/R/H for explosive, frost, shock, fire and red), `sparks.zs` `RSQML_Burst` plays them frames by level
(`args[0]`; 3 at level 1, +2 a level, all at the cap), Gun Bonsai VR spawns them by name (`RSQM.Burst`). CvS2's angle
variants 2-4 are in (`tools/sparks.py`), picked by the fist's travel. Where each burst goes is in Melee's README.
**Headless 11-02:** a straight jab drew the 56-degree streak (mirrored for the off hand), a hook the 11-degree one, an
uppercut the 79-degree one; the level-1 bursts (the lift, Three-Hit, the shatter, Parry) were gone after 9 tics, the
full ones (Explosive Fist at its cap, a critical, the release, Reflect Guard 3) ran 16-18.

**THE FISTS TREE IS BUILT (11-02):** all nine branches, every kept node, each run in the engine headless. Not built:
Catch and Bullet Time Fists (parked off, as designed). **Owed:** the art and sound pass (kiddolink bursts by level,
CvS2 colourings, RS Combat FX sounds; today's looks are placeholders: particles, stock sounds, the existing sparks);
the Berserk Meter on the HUD; HP Bars' new states (frozen, held, disarmed); the owner's headset for everything a hand
does (Gestures' reads, the swings, the look).

**Counts:** 42 nodes (38 + Reflect Guard, Absorb and Release, Critical Hits, Clear Out), 14 exist, 28 new, 2
parked off. **Every Fists node was kept by the owner, 11-02** (Rig link on the Saber was his one strike so far).

### 4.2 Saber (owner approved Focus, Blade, Stab, Deflect, Dual, The Force, 11-02; "keep the names Star-Warsy")

**Base numbers** (RSQ Saber README @ 9cc70f6b2): a cut does 30 (15-60 on the menu); a stab one target at x1.5,
no shove; 5 lock-on targets a throw; blade 54, 65, 76, 88 or 99 cm; hit-stop option 3, 4 or 6 tics; perfect parry
slow-mo half a second (option); the Force at 60% unlearned under GBOVR today (`rsq_force_start`). Two sabers are
two records, like the fists; the Force reads the best of either.

Names: the display name is the Star Wars one; a node that exists keeps its class name for saves (in brackets).

**Focus** (the marks)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Battle Meditation (new; the Lockstep idea for sabers) | root | under GBOVR a throw starts at 1 lock; 1-4: +1 lock a level (5 at 4, today's default) | Saber (`ubqs_locks` read as base + level) | one more diamond a level | - |
| Saber Barrage (new) | Battle Meditation 2 | 1-3: the thrown saber also cuts what it passes on the way back, for 50% + 15% lv of a cut | Saber | the return trail cuts (Combat FX slash) | `barrage` |
| Returning Blade (new) | Saber Barrage 1 | 1-2: the saber makes a second pass over its marks before coming home (2: a third) | Saber | - | `boomerang` |
| Saber Throw (exists: `RSQ_Upgrade_SaberThrow`) | Battle Meditation 1 | 1-3: once its route is done the saber finds lv more enemies | Saber | - | `throw.extra` |

**Blade** (the forms)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Elegant Weapon (exists as Momentum: `RSQ_Upgrade_Momentum`) | root | 1-4: +10% lv per half second the blade keeps moving, up to 2 s (x1.4 lv at full) | Saber | hum rises with it (exists) | - |
| Aggressive Negotiations (exists as Riposte Edge: `RSQ_Upgrade_RiposteEdge`) | Elegant Weapon 1 | 1-4: a block primes the blade: the next cut inside 1 s + 0.5 s lv does x1.5 + 0.25 (lv-1) | Saber | white edge flash | `riposte` |
| Strike True (new: hit-stop) | Elegant Weapon 1 | 1-3: a cut freezes the monster 3, 4, 6 tics (today's option becomes levels) | Saber | - | - |
| Kyber Attunement (new: reach) | Elegant Weapon 2 | 1-4: the blade grows 54 -> 65 -> 76 -> 88 -> 99 cm (today's five presets as levels; the menu length is the floor) | Saber | the blade itself | - |
| High Ground (new: sever) | Aggressive Negotiations 2 | 1-3: a cut on a monster at 20% + 5% lv of its health or less gibs it (bosses: no) | Saber | BD's gib or Doom's XDeath | `sever` |

**Stab**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Point Taken (new: lunge stab) | root | 1-3: a stab with the head moving forward at 0.8+ m/s does x2 + 0.25 lv (on top of the stab's x1.5) | Saber (reads head speed as Lunge does) | Combat FX pierce flash | `stab.lunge` |
| Run Through (new: impale) | Point Taken 1 | 1-3: a stabbed monster is held on the blade 0.5 + 0.25 lv s (it cannot act; pulling the blade out finishes a monster under 15%) | Saber | the monster on the blade | `impale` |

**Deflect**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Deflector (exists: `RSQ_Upgrade_Deflector`; name kept, owner) | root | 1-5: a bolt the saber turns hits +15% lv | GBOVR (damage) | - | `deflect` |
| Return to Sender (new) | Deflector 1 | 1-3: turned shots go to the shooter (today's "where turned shots go" option becomes this); 2: within 20 degrees of it even when you look away; 3: always | Saber | - | `return.sender` |
| Guided Return (new: aimed) | Deflector 1 | 1-2: turned shots go where you look (the other option), 2: where the off hand points | Saber | - | - |
| Piercing Return (exists: `RSQ_Upgrade_PiercingReturn`) | Return to Sender 1 or Guided Return 1 | 1-3: a returned bolt passes through lv bodies | Saber | - | - |
| Precognition (new: parry window) | Deflector 2 | 1-3: the blade counts as meeting the shot at a slower swing (1 / (1 + 0.35 lv) of the speed, Bulwark's rule) and the block width grows 1.5 -> 2.0 -> 2.5 | Saber | - | `parry.saber` |

**Dual**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Two Sabers (new: the second saber unlock) | root | 1: the second saber (today's Start With Dual Sabers row becomes this under GBOVR; the row stays without it) | Saber, Rig (its holster) | - | - |
| Double-Bladed (new; owner 11-02: "second blade on the saber should be an unlock too") | root | 1: the saber's own second blade (the staff, lit and doused by the main alt today when Main-Hand Force Push is off) is an unlock; 2: the back blade cuts on the backswing for 75%; 3: a spin (a fast wrist roll) cuts all round you | Saber | the second blade itself; Combat FX arc on the spin | `staff.spin` |
| Assault (exists as Dual Harmony: `RSQ_Upgrade_DualHarmony`; renamed by the owner) | Two Sabers 1 | 1-4: cuts alternating between the two sabers stack +10% lv, up to 5 | GBOVR | - | `dual.chain` |
| Cross Guard (new) | Two Sabers 1 | 1-3: the X block (exists, stops everything from in front) now also turns what it stops: 1 back the way it came, 2 at the shooter, 3 and the X releases a push when opened | Saber | the X flash | `crossguard` |
| Clash (new: blade lock shock) | Cross Guard 2 | 1-2: a blade lock (the two blades brought together) releases a shockwave 2 + lv m that staggers | Saber | the lock's sparks, bigger | `clash` |

**The Force**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Force Sensitive (new: the unlock) | root | 1: the Force gestures work (under GBOVR an unlearned Force does nothing, not 60%: `rsq_force_start` -> 0) | Saber | - | - |
| Force Push (exists: `RSQ_Upgrade_ForcePush`) | Force Sensitive 1 | 1-4: full strength at 1, +15% a level; 2+ the cone opens 10 degrees a level; 3+ a shockwave all round you too | Saber | exists | `force.push` |
| Force Pull (exists) | Force Sensitive 1 | 1-4: as today; 2+ what arrives is stunned; 3+ it is disarmed | Saber | exists | `force.pull` |
| Force Grip (exists as Force Choke) | Force Sensitive 1 | 1-4: as today; 2+ lifts and crushes harder the longer held; 3+ holds lv-1 at once | Saber | exists | `force.grip` |
| Force Jump (exists) | Force Sensitive 1 | 1-3: as today; 2+ the landing is a slam | Saber | exists | `force.jump` |
| Force Speed (new) | Force Sensitive 2 | 1-3: a Force gesture held still for a second starts slow motion for 2 + lv s through RSQ SlowMo (the SlowMo link) | Saber asks SlowMo `rsm_pulse` | SlowMo's own | `force.speed` |
| Force Lightning (new power) | Force Push 2 and Force Grip 2 | 1-3: the off hand's alt with fingers spread (hand still, pointed at a monster for half a second, then a flick): a chain of lightning for 5 + 3 lv a tic over 1 s to lv + 1 targets. Needs: a new UBQS_Force power and its art (RS Ballistics' arc) | Saber | RS Ballistics arc, blue-white | `force.lightning` |

**Counts:** 27 nodes (28 with Double-Bladed, less Chain Choke), 9 exist, 18 new. Struck by the owner: the Rig
link (Quick Ignite) and Chain Choke (`RSQ_Upgrade_ChainChoke` goes; a save that has it keeps a dead upgrade,
which Gun Bonsai tolerates). Force Sensitive, Push, Pull, Grip, Jump, Speed and Lightning kept; Double-Bladed as
unlock, backswing, spin; Force Repulse struck (Push's level 3 shockwave is enough). Saber tree: 26 nodes,
reviewed in full. ShieldSaw: Throw, Block, Bash, Grind branches and the Spartan link in. Whip: Crack, Reach,
Wrap, Lasso, Rope and the Fists link in (all six). Grenade: Carry, Throw, Fuse, Blast, Style and the SlowMo link
in (all six). Grapple: the nine under a player-level unlock, plus Momentum (unlock), Zip Kick and Scorpion;
Hook Switches struck; Twin Lines kept. Distance Grab: Heavy Lift and Straight Pull in; Corpse Grab, Body Shield,
Catch and Pull Small: his answer was lost by the picker, re-asked in chat. Tactical Rig: Ammo Readout and Gun
Toss, Boomerang Gun, Keys by Hand, Smoker, Chain Smoker in; Holsters-as-unlock, Quartermaster and Long Drag
struck. SlowMo: Slow Motion (unlock), Longer, Deeper, Cheaper, Lean Dodge (unlock), Matrix all in. Miniboss: "no Miniboss Gun Bonsai stuff, maybe later" (section 3.10
is parked). LaserSight: Target Lock and Headshot Reaction become Gunslinger unlocks; HP Bars draws the new states
(frozen, held, stunned), not a path; Gestures, Wheel, GunCards: no progression. **Unlock pace: picks at player
level-ups, Gun Bonsai's own way** (each player level offers a few unlocks and perks; the player chooses the
order). **Owner, 11-02:
Focus, Blade and Stab nodes all kept; the deep-lore names (Ataru, Makashi, Djem So, Mou Kei, Shiak) rejected:
"have you seen Star Wars?" Names must be ones a film-goer knows. His picks: Elegant Weapon, Aggressive
Negotiations, Strike True, High Ground, Point Taken. Deflect and Dual nodes all kept; Deflector keeps its name,
Return to Sender, Two Sabers, Assault (was Dual Harmony); Double-Bladed added as an unlock on his word.**

### 4.3 ShieldSaw (branches Throw, Block, Bash, Grind and the Spartan link approved 11-02)

**Base numbers** (`ShieldSaw/CVARINFO.txt`, README): 5 locks a throw (`ssq_locks`), lock cone 25 deg, range 1200;
wall bounces 3; hit tiers: at or under 70 health bisected, at or under 600 embedded and ground (BD22 option: 250 /
1200); embed 3 a tic, grind 6 a hit every 4 tics; a full-rev throw +60% damage and speed; returned bullets x1.0;
blocked melee stuns and shoves; bash hit-stop option 4 tics; perfect block slow-mo half a second (option);
shield size Standard / Large / Largest; Double Block Radius option (replaced by Broadening under GBOVR).

**Throw**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Lockstep (exists: `RSQ_Upgrade_Lockstep`; reworked) | root | under GBOVR a throw starts at 1 lock; 1-4: +1 a level (5 at 4, today's default) | ShieldSaw (`ssq_locks` as base + level) | one more diamond a level | - |
| Ricochet (exists) | Lockstep 1 | 1-3: off a wall the disc turns to lv more targets | ShieldSaw | wall sparks (exist) | `ricochet` |
| Hunter's Return (exists) | Ricochet 1 | 1-3: on the way home it swerves through lv enemies within 160 + 32 lv units | ShieldSaw | - | `hunter` |
| Meat Grinder (exists) | Hunter's Return 1 | 1-3: a kill while embedded frees the disc to its next lock at full speed (2+: or a new target); the grind +25% a level after 1 | ShieldSaw | - | `grinder` |
| Wall Bounces (new) | Ricochet 2 | 1-3: 3 bounces today -> 4, 5, 6 before the disc comes home | ShieldSaw (`Wall Bounces` as base + level) | - | - |
| Cleaver (new) | Meat Grinder 1 | 1-3: the hit tiers rise: bisect at or under 70 -> 100, 140, 200; grind at or under 600 -> 800, 1000, 1200 (BD22 tiers scale the same) | ShieldSaw | BD's gib | `cleave.saw` |

**Block**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Broadening (exists) | root | 1-5: the plate +20% a level, double at 5 | ShieldSaw (`SSQ_Guard.GrowFor`) | - | - |
| Bulwark (exists) | Broadening 1 | 1-4: a perfect block at a slower plate: 1 / (1 + 0.35 lv) of the speed | ShieldSaw | - | `perfect.block` |
| Rebound (exists) | Bulwark 1 | 1-4: shots the shield turns hit x1.1 + 0.15 lv | GBOVR (damage) | - | `rebound` |
| Back Plate (new) | Broadening 2 | 1: a shield on your back blocks (today's Block While Holstered option becomes this); 2: it turns shots too | ShieldSaw | - | `backplate` |
| Shield Wall (new) | Bulwark 2 | 1-3: a perfect block pulses slow motion 0.5 + 0.25 lv s through RSQ SlowMo (today's option becomes levels) | ShieldSaw asks SlowMo | SlowMo's own | - |
| Reflect (new) | Rebound 2 | 1-2: returned BULLETS (the muzzle block's) do x1.5, x2 (`ssq_hitscan_damage` as base x level) | ShieldSaw | - | `reflect.saw` |

**Bash**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Battering Ram (exists) | root | 1-3: a bashed monster is a missile for 21 tics: it hits others for 6 + 4 lv + its speed, and is hurt itself | GBOVR (`RSQ_Rammed`) | ram sound (exists) | `ram` |
| Wall Slam (new: levels) | Battering Ram 1 | 1-3: a bashed body into a wall takes +50% a level and hangs stunned 10 + 10 lv tics longer (today's always-on wall slam as base) | ShieldSaw | the owner's five-frame burst (exists) | `slam.saw` |
| Strike True (new: hit-stop; the saber's name, same idea) | Battering Ram 1 | 1-3: a bash freezes the monster 4, 5, 6 tics (today's option becomes levels) | ShieldSaw | - | - |
| Charge (new) | Wall Slam 1 | 1-3: a bash while you move forward at 2+ m/s (the stick or your body) strikes everything in a 1 + 0.5 lv m wedge, each shoved | ShieldSaw | a Combat FX shockwave | `charge` |
| Shield Size (new) | Battering Ram 2 | 1-2: Standard -> Large -> Largest (today's presets as levels; the menu preset is the floor) | ShieldSaw | the shield itself | - |
| Shield Dash (new; owner 11-02: "some kind of movement dash forward so we can close and bash") | Charge 1 | 1-3: thrust the shield forward at 3+ m/s with the stick pushed forward: you dash 2 + lv m the way the shield faces and the thrust lands as a bash at the end; 2 s cooldown; stopped by walls and bodies. It moves the pawn as RSQ Grapple's pull does (eased, capped at the grapple's 30 units a tic), never the camera on its own | ShieldSaw | a Combat FX speed streak, the bash burst at the end | `dash.bash` |

**Grind**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Hungry Blades (new) | root | 1-3: grind 6 -> 8, 10, 12 a hit; embed 3 -> 4, 5, 6 a tic | ShieldSaw | more sparks | `grind` |
| Rev Shield (new) | Hungry Blades 1 | 1-2: a revving shield held up blocks AND grinds what touches the plate (a melee monster that claws it is ground); 2: and the blades turn a blocked missile | ShieldSaw | - | `rev.block` |
| Buzzsaw Return (new) | Hungry Blades 2 | 1-3: a recalled disc grinds what it passes on the way home for 50% + 15% lv of a grind hit | ShieldSaw | - | `buzz.return` |

**Spartan (the Saber link; needs both mods)**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Spartan (new) | Broadening 1 and the saber's Deflector 1 | 1-2: the lit blade over the shield (x1.3 wider today) also PARRIES: a shot meeting the blade is turned at the shooter; 2: the shield's bash while the blade rests on it cuts too | ShieldSaw (reads the saber's level by name) | the blade's parry flash | `spartan` |

**Counts:** 22 nodes, 8 exist, 14 new. **Owner, 11-02: every ShieldSaw node kept; Shield Dash added on his word.**

### 4.4 Whip (own path, owner 11-02; branches Crack, Reach, Wrap, Lasso, Rope and the Fists link approved)

**Base numbers** (`Whip/CVARINFO.txt`): reach 128 units (3.8 m); a crack does 12 at a tip speed of 50 units a tic,
a quarter at the slowest crack that counts; stun on a crack (on); snag edges (on); lasso (on); flail (on); a
leashed monster slides at 10, reel 12, speed cap 30, momentum kept on landing. The whip earns no XP today; L1
claims its hits for `RSQWP_WhipWeapon` (section 1) and adds it to the `type : MELEE` line.

**Crack**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Sting (new) | root | 1-4: a crack does +25% a level (12 -> 24 at 4) | Whip (`RSQWP_Perks.Factor`, the stub) | Combat FX crack flash, frames by level | `crack` |
| Stun (new: levels) | Sting 1 | 1-3: the pain a crack causes is held 10 + 10 lv tics (the stun exists; the hold is new, `RSQ_Dazed.Stagger` by name) | Whip asks GBOVR `stagger` | - | `crack.stun` |
| Crack Shot (new) | Sting 2 | 1: a crack through a monster's missile blows it up (today's option becomes this); 2-3: and hurts what stands within 1 + 0.5 lv m of it | Whip | the missile's own death | `crack.shot` |
| Return Crack (new) | Crack Shot 1 | 1-3: the cracked missile is sent back at its shooter instead (today's "knocked away" option, aimed), at x1.0 + 0.25 lv | Whip | - | `crack.return` |
| Strike True (new: hit-stop) | Sting 1 | 1-3: a crack freezes the monster 3, 4, 6 tics (today's option becomes levels) | Whip | - | - |

**Reach**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Long Thong (new) | root | 1-3: reach 128 -> 160, 192, 224 units (3.8 -> 6.7 m) | Whip (`rsqwp_whip_reach` as base + level) | the whip itself | - |
| Quick Mark (new) | Long Thong 1 | 1-3: pickups and switches are marked from 8 m -> 10, 12, 14 m; 3: two marks at once, the crack takes the nearer | Whip | - | - |

**Wrap**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Heavy Yank (new) | root | 1-3: the mass under which a yanked monster flies to you (instead of pulling you) rises 400 -> 600, 800, 1000 | Whip | - | `yank.heavy` |

(Owner, 11-02: Flail levels, Choke and Disarm struck; the flail stays as the base move it is today. Crack and
Reach nodes all kept.)

**Lasso**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Lasso (exists as an option; becomes the unlock) | root | 1: the off hand on the thong whirls it as a lasso; 2: the rope holds 50% longer | Whip | - | `lasso` |
| Bola (new) | Lasso 2 | 1-2: the lasso takes two monsters at once (2: three); they are swung together | Whip | - | `bola` |

**Rope**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Snag (exists as an option; becomes the unlock) | root | 1: a lash that catches an edge becomes a rope; 2: edges 16 -> 32 units above the hand count | Whip | - | `snag` |
| Mantle (exists as an option) | Snag 1 | 1: reel up to a lip or Grab it and go over; 2: from a swing too | Whip | - | `mantle` |
| Momentum (exists as an option) | Snag 1 | 1: the swing's speed carries on landing; 2-3: speed cap 30 -> 36, 42 | Whip | - | `swing.whip` |
| Tarzan (new) | Momentum 2 | 1-3: arriving on a monster from a swing at 3+ m/s hurts it 10 + 10 lv x your speed share and knocks it flat | Whip | a Combat FX impact | `tarzan` |

**Pull and Punch (the Fists link; needs RSQ Melee)**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Pull and Punch (new) | Heavy Yank 1 | 1-3: a yanked monster arrives staggered 17 + 9 lv tics (Counterpunch's window), so the free hand's punch counts as a counter | Whip asks GBOVR `stagger`; Melee's Counterpunch reads it | the counter sound | `pull.punch` |

**Counts:** 16 nodes after the owner's verdicts (11-02): Sting, Stun, Crack Shot, Return Crack, Strike True, Long
Thong, Quick Mark, Heavy Yank, Lasso, Bola, Snag, Mantle, Momentum, Tarzan, Pull and Punch kept; Flail levels,
Choke, Disarm, Rope Them In struck. 5 exist as options; all 16 are new as upgrades.

### 4.5 Grenade (own weapon path, owner 11-02; branches Carry, Throw, Fuse, Blast, Style and the SlowMo link approved)

**Base numbers** (`Grenade/CVARINFO.txt`, README): fuse 3.0 s; a throw at 2.5+ m/s, strength x1.0 of the hand, arc
0.35, gravity 0.27, bounces 0.5 floor / 0.25 wall; blast 85 over 200 then 75 over 255; carry 8 (16 with a
backpack); start with 3; scatter up to 4 singles and 2 packs a map. The grenade earns no reliable XP today; L1
names the weapon on the thrown actor (section 1). `RSQGN_Grenade` is a Weapon already, so it levels like one.

**Carry**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Bandolier (new) | root | 1-4: carry 8 -> 10, 12, 14, 16 (the backpack doubles whatever the cap is) | Grenade | - | - |
| Scavenger (new; the grenade's) | Bandolier 1 | 1-3: scattered grenades a map 4 + 2 -> 6 + 3, 8 + 4, 10 + 5 (singles + packs); 3: a Kill Rewards ammo bit may be a grenade | Grenade | - | - |

**Throw**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Strong Arm (new) | root | 1-3: throw strength x1.0 -> 1.25, 1.5, 1.75 | Grenade (`rsqgn_throw` as base x level) | - | `throw.far` |
| Flat Arc (new) | Strong Arm 1 | 1-2: arc 0.35 -> 0.25, 0.15 and gravity 0.27 -> 0.22, 0.18: it flies flatter and further | Grenade | - | - |
| Bounce (new) | Strong Arm 1 | 1-3: wall bounce 0.25 -> 0.4, 0.55, 0.7: bank shots round corners | Grenade | a clink per bounce (exists) | `bank.shot` |

**Fuse**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Cook Sense (new) | root | 1: a haptic tick in the hand at each second of the fuse; 2: the flash's colour runs amber -> red with the fuse; 3: the count is spoken (SPO's announcer, 3-2-1) | Grenade, Accessibility (rumble strength) | the flash (exists) | - |
| Short Fuse (new) | Cook Sense 1 | 1-2: fuse 3.0 -> 2.5, 2.0 s | Grenade (`rsqgn_fuse` as base - level) | - | - |

**Blast** (the frag grenade's own numbers)

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Big Bang (new) | root | 1-3: both radii +15% a level (200 / 255 -> 290 / 370 at 3) | Grenade | RS Ballistics blast, bigger | - |
| Frag (new) | Big Bang 1 | 1-3: both damages +15% a level (85 / 75 -> 123 / 109 at 3) | Grenade | - | - |
| Cluster (new) | Frag 2 | 1-3: the blast throws 2 + lv small bomblets (30 over 96 each) 2-4 m out, fused 1 s | Grenade | RS Ballistics small blasts | `cluster` |
| Sticky (new) | Frag 1 | 1-2: the grenade sticks to the first monster it touches (2: or wall); it goes off there | Grenade | - | `sticky` |

**Kinds** (owner, 11-02: "impact grenade, incendiary grenade, freeze grenade, stun grenade, smoke grenade, flash
grenade, charm grenade, infight grenade; RS Ballistics and RS Combat FX have what we need"). Each kind is an
unlock on the grenade's record; the frag is the base kind. **Choosing a kind (owner, 11-02): the grenade's alt
trigger cycles the kinds you own, and the Weapon Wheel's grenade card opens a fan of them.** The chosen kind
shows on the grenade itself: **its skin recoloured per kind, the WIDE BAND way (owner, 11-02, from the mock-ups
in `Grenade/docs/grenade_kinds_mockup.png` and `grenade_kinds_mockup2.png`)**: the red stripe on Gomuz's skin
(rows 38-50 of `nade.png`) widened to rows 24-64 and the red spoon patch, both in the kind's colour, the body as
shipped; the fuse flash stays the whole-skin red of `nade_red.png`. Colours: Frag as shipped (red), Impact orange
(255,120,20), Incendiary amber (255,200,40), Freeze sky blue (70,190,255), Stun violet (170,80,255), Smoke a
darker grey (140,140,150), Flash pure white and full bright (255,255,255; the owner: "flash needs to be more
white", smoke and flash looked alike), Charm pink (255,110,190), Infight green (60,220,90). The Rig's
grenade-spot light takes the same colour. The skins are generated, never hand-painted: the L6 lane extends
`Grenade/tools/gen_red.py` into a `gen_kinds.py` (the mock-up script's band method, scratchpad only, is its
starting point). **Smoke (owner): "be sure to smartly optimize smoke"**: one cloud actor,
a dozen RS Combat FX puffs at most, the lose-target pass runs twice a second over one blockmap iterator of the
cloud's radius, nothing per tic.

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Impact (new) | Cook Sense 1 | 1: bursts on first contact, no fuse (thrown only; cooking it is the frag's job); 2: +15% damage | Grenade | RS Ballistics blast | `impact` |
| Incendiary (new) | Big Bang 1 | 1-3: the blast leaves fire 3 + lv s over its radius, 5 a second to what stands in it | Grenade | RS Combat FX fire | `fire.nade` |
| Freeze (new) | Frag 1 | 1-3: no blast damage; monsters inside freeze solid 2 + lv s (`RSQ_Dazed.frozen`, the Frost Fist's state; bosses slowed 50%); a frozen monster hit hard shatters (x2) | Grenade, GBOVR (the state) | RS Combat FX frost burst, blue | `freeze.nade` |
| Stun (new) | Cook Sense 1 | 1-3: half blast damage; monsters inside are staggered 2 + lv s (`RSQ_Dazed.Stagger`) | Grenade asks GBOVR | a dull thud, a ring | `stun.nade` |
| Smoke (new) | Cook Sense 2 | 1-3: a cloud 3 + lv m wide for 8 + 4 lv s. Doom's sight test cannot see actors, so the cloud cannot truly block sight; the owner's pick pending: monsters inside or behind it lose their target every half second while it lasts, or the kind is struck | Grenade | RS Combat FX smoke | `smoke` |
| Flash (new) | Cook Sense 2 | 1-3: no damage; monsters within the radius are stunned 2 + lv s and lose their target | Grenade asks GBOVR | a white flash, no blast | `flash` |
| Charm (new) | Flash 1 | 1-3: monsters inside fight for you for 10 + 5 lv s (`bFriendly` on, then off; bosses immune) | Grenade | RS Combat FX pink haze | `charm` |
| Infight (new) | Flash 1 | 1-3: monsters inside turn on the nearest monster for 10 + 5 lv s (their target set to it; bosses immune) | Grenade | a red haze | `infight` |

**Style**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Teeth (new) | root | 1: a pin pulled with the teeth pays Score `teeth`; 2-3: and the throw that follows does +15%, +30% | Grenade | - | `teeth` |
| Skeet (new) | Strong Arm 2 | 1-3: shooting your own grenade in the air bursts it there at x1.25 + 0.25 lv (it is an actor; a hitscan hits it) | Grenade | the blast, higher | `skeet` |
| Skeet Window (new; owner 11-02; needs SlowMo) | Skeet 1 | 1-3: a few tics after a throw (8), slow motion kicks in for 10 + 5 lv tics and the grenade draws full bright, a window to line up the shot; an Option row too (off without the node) | Grenade asks SlowMo `rsm_pulse`; the grenade's own bright flag | the grenade lit, SlowMo's own | `skeet.window` |

(Return Pull struck, 11-02. Teeth, Skeet and Slow Burn kept.)

**SlowMo link**

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Slow Burn (new; needs SlowMo) | Cook Sense 1 | 1-3: a kill by a grenade that was cooked at least 1 s, while the world is slowed, re-pulses slow motion 0.5 + 0.25 lv s | GBOVR OnKill (reads the grenade's cook time from the thrown actor) | SlowMo's own | `slow.burn` |

**Counts:** 24 nodes, all new (Carry 2, Throw 3, Fuse 2, Blast 4, Kinds 8, Style 3, SlowMo link 1, plus Short
Fuse's child moved). **Owner, 11-02: Carry, Throw, Fuse and Blast nodes all kept; the eight Kinds are his.** The
handoff asked for about a dozen; the owner wanted more.

### 4.6 Grapple (the nine under a player-level unlock; Momentum unlock, Zip Kick, Scorpion, Twin Lines approved; Hook Switches struck)

**Base numbers** (`Grapple/CVARINFO.txt`): range 1024 units, claw 40 a tic, reel 12, speed cap 30, a hooked monster
slides at 10, lasso follows at 24; Swing and Momentum off by default (pull to the claw and stop).

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Grapple (new: the unlock) | root (player) | 1: the hook fires at all under GBOVR (without GBOVR the mod is as today) | Grapple | - | - |
| Long Line (exists) | Grapple 1 | 1-4: range +20% a level | Grapple | - | - |
| Fast Reel (exists) | Grapple 1 | 1-4: reel and slide +15% a level | Grapple | - | - |
| Barbed Claw (exists) | Long Line 1 | 1-4: the bite 4 + 4 lv, the tear-out 6 + 6 lv | Grapple | - | `bite` |
| Heavy Haul (exists) | Fast Reel 1 | 1-3: heavier (+50%) and bigger (+15%) things come; a boss on the line staggers 10 + 10 lv | Grapple | - | `haul` |
| Get Over Here (exists) | Heavy Haul 1 | 1-3: what arrives is staggered 20 + 15 lv tics | Grapple asks GBOVR `stagger` | - | `goh` |
| Bowling (exists) | Get Over Here 1 | 1-3: what arrives strikes what is in its way for 5 + 5 lv | Grapple | - | `bowling` |
| Double Hook (exists) | Heavy Haul 2 | 1-3: a monster on each hook slammed together for 20 + 15 lv | Grapple | - | `double.hook` |
| Momentum (new: the unlock) | Grapple 1 | 1: Swing and Momentum (hang, swing, pump, keep your speed) under GBOVR; the option stays without it | Grapple | - | - |
| Slingshot (exists) | Momentum 1 | 1-3: letting go of a swing carries +10% a level | Grapple | - | `slingshot` |
| Steady Line (exists) | Momentum 1 | 1-3: the hang settles x(1 + 3 lv) faster | Grapple | - | - |
| Zip Kick (new) | Momentum 2 | 1-3: arriving on a monster via the rope at 3+ m/s hurts it 10 + 10 lv x your speed share and knocks it back | Grapple | a Combat FX impact | `zip.kick` |
| Scorpion (new; needs RSQ Melee) | Get Over Here 2 | 1-3: a yanked monster that arrives at an empty fist is punched at full power automatically, x1.0 + 0.25 lv, as a counter | Grapple asks Melee (`RSQML_Service`) | the Super Spark | `scorpion` |
| Twin Lines (new) | Long Line 2 | 1-2: a hook from each hand on geometry at once: you hang between them and pull toward either; 2: letting one go slingshots you along the other | Grapple | two ropes | `twin.lines` |

**Counts:** 14 nodes, 9 exist, 5 new.

### 4.7 Distance Grab (Long Arm, Iron Grip, Heavy Hitter, Air Catch, Powder Keg; Dead Eye, Heavy Lift, Straight Pull, Body Shield approved; Corpse Grab, Catch, Pull Small struck)

**Base numbers** (README): reach 512 units (15 m), aim 12 deg, throw aim assist 12 deg, two-hand lift x2.0,
barrel blast at 4 m/s, pull gravity off, body shield on.

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Long Arm (exists) | root (player) | 1-4: reach +15% a level | Distance Grab | the beam, longer | - |
| Iron Grip (exists) | Long Arm 1 | 1-4: heavier things come (+50% a level) and weigh you down less (+25%); **also raises the Headlock's mass cap +100 a level** (Fists: Heavier Headlock) | Distance Grab; Melee reads `plevel IronGrip` | - | - |
| Heavy Hitter (exists) | Iron Grip 1 | 1-5: a thrown thing hits +15% a level and a heavy one leaves the hand faster | GBOVR (damage), Distance Grab (the arm) | - | `throw.hit` |
| Air Catch (exists) | Heavy Hitter 1 | 1-4: the catch window +25% a level; a re-caught thing hits +20% a level | GBOVR, Distance Grab | catch flash (exists) | `juggle.grab` |
| Powder Keg (exists) | Heavy Hitter 1 | 1-5: a barrel a throw set off blasts +15% a level | GBOVR | - | `keg` |
| Dead Eye (new) | Heavy Hitter 2 | 1-3: throw aim assist 12 -> 16, 20, 24 deg | Distance Grab | - | - |
| Heavy Lift (new) | Iron Grip 2 | 1-3: two palms make a thing x2.0 -> 2.5, 3.0, 3.5 lighter | Distance Grab | - | - |
| Straight Pull (new) | Long Arm 2 | 1: a pull flies straight, no sag (Pull Gravity off is the default; this node makes WorldHands' arc a straight line for a pull you flick hard); 2: pulls are 25% faster | Distance Grab | - | - |
| Body Shield (exists as an option; becomes the unlock) | Iron Grip 1 | 1: a held corpse or barrel stops shots and fireballs; **what it stops hurts it, so a barrel can go off in your hands** (owner, 11-02); 2: a corpse lasts 50% more; 3: a shot it stops is turned back | Distance Grab | - | `body.shield` |

**Counts:** 9 nodes, 5 exist, 4 new.

### 4.8 Tactical Rig: Gunslinger (Quick Draw, Pair Draw, Showdown; Ammo Readout, Gun Toss, Boomerang Gun, Keys by Hand, Smoker, Chain Smoker approved; Holsters-as-unlock, Quartermaster, Long Drag struck)

**Base numbers** (README): six holsters; a thrown gun hurts by its weight and speed (x1.0); the cigarette: 3 a
level, 2 s smoke, then 6 s of slow motion at 25%; ammo count on holsters (option, off); keys to doors (option).

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Quick Draw (exists) | root (player) | 1-5: the gun just drawn hits +10% a level for 1 s + 0.25 s a level | GBOVR | - | `quick.draw` |
| Pair Draw (exists) | Quick Draw 1 | 1-3: a pair draw: both hands +8% a level for 2 s + 0.5 s a level | GBOVR | - | `pair.draw` |
| Showdown (exists; needs SlowMo) | Quick Draw 2 | 1-3: a kill with the just-drawn gun inside 2 s pulses slow motion 0.3 + 0.15 lv s | GBOVR asks SlowMo | SlowMo's own | `showdown` |
| Ammo Readout (new) | root | 1: the small digits above each full holster (today's option) | Rig | the digits (exist) | - |
| Gun Toss (exists as a feature; levels new) | root | 1-3: a thrown gun hurts x1.0 -> 1.5, 2.0, 2.5 and staggers 10 lv tics longer | Rig (`Thrown Gun Damage` as base x level) | - | `gun.toss` |
| Boomerang Gun (new) | Gun Toss 2 | 1: a thrown gun that hits a monster flies back to the holster it came from (2: to your hand) | Rig | the gun's return arc | `boomerang.gun` |
| Keys by Hand (exists as an option; becomes the unlock) | root | 1: grip the keyring, touch the keys to a locked door | Rig | - | - |
| Smoker (exists as an option; becomes the unlock) | root | 1: the cigarette pocket and its ritual, 3 a level; the smoke's 6 s slow motion as today | Rig | - | `smoke` |
| Chain Smoker (new) | Smoker 1 | 1-3: pack 3 -> 4, 5, 6 a level | Rig (`Pack Size` as base + level) | - | - |
| LaserSight: Target Lock (exists as a LaserSight feature, on; under GBOVR an unlock) | Quick Draw 1 | 1: the dot grows and pulses on a live monster; 2: the dot's colour changes on a monster | LaserSight (reads the level by name; without GBOVR as today) | the dot (exists) | - |
| LaserSight: Headshot Reaction (exists as an option; under GBOVR an unlock) | Target Lock 1 | 1: the top fifth of a monster turns the dot the headshot colour (pulse on); 2: and a hit there counts as a Headshot for Critical Hits level 2 | LaserSight; GBOVR reads it | the dot (exists) | `headshot.cue` |

**Counts:** 11 nodes, 3 exist as upgrades, 8 new (4 of them existing features or options made unlocks).

### 4.9 SlowMo (all ten approved)

**Base numbers** (README): world speed 0.25; wrist cross toggles or a 4 s burst (option); adrenaline meter
(option) earned from kills, hurt and near misses; dodgeable bullets on; lean dodge on; colour drain option;
automatic triggers wait a 25 s cooldown.

| Node | Parent | Levels | Owns | Art | Score |
|---|---|---|---|---|---|
| Slow Motion (new: the unlock) | root (player) | 1: the key and the wrist cross work under GBOVR (other mods' pulses still fire; a pulse is theirs). Without GBOVR the mod is as today | SlowMo (reads `plevel` by name) | - | - |
| Longer (new) | Slow Motion 1 | 1-3: the burst 4 -> 5, 6, 8 s; the meter's capacity +25% a level | SlowMo | - | - |
| Deeper (new) | Slow Motion 1 | 1-3: world speed 0.5 at level 0 under GBOVR -> 0.35, 0.25 (today's), 0.1 | SlowMo | colour drain deepens with it | - |
| Cheaper (new) | Longer 1 | 1-3: with the meter on, slow motion costs 20% less a level | SlowMo | - | - |
| Marksman (exists) | Deeper 1 | 1-5: +8% a level to everything hit while slowed | GBOVR | - | - |
| Dodger (exists) | Deeper 1 | 1-4: take 8% less a level while slowed | GBOVR | - | - |
| Second Wind (exists) | Cheaper 1 | 1-4: every kill charges the meter 3 more a level | GBOVR | - | - |
| Time Dilation (exists) | Marksman 1 | 1-3: a kill while slowed re-pulses 0.25 + 0.15 lv s and refunds 2 lv | GBOVR | - | `dilation` |
| Lean Dodge (exists as a feature, on; under GBOVR an unlock) | Dodger 1 | 1: leaning your head out of a slowed round's path makes it miss; 2: a lean also makes a melee claw miss | SlowMo | - | `lean` |
| Matrix (new) | Deeper 3 | 1: colour drain and shot trails at full while slowed; the top level's look | SlowMo | drain + trails (exist as options) | - |

**Counts:** 10 nodes, 5 exist, 5 new.

### 4.10 Kill Rewards (section 3.14; the four path nodes approved) and Critical Hits (section 4.1 I) are player nodes too.

## 5. The player pool, together

Everything offered at a player level-up (Gun Bonsai's own way: 4 random picks from the suitable pool; the owner
accepts the dilution and prunes stock instead):

- **Unlocks:** Slow Motion, Grapple, Momentum (grapple), Force Sensitive, Two Sabers, Double-Bladed, Smoker,
  Keys by Hand, Human Shield, Lasso, Snag, Body Shield, Taunt, Critical Hits. (Saber and Whip unlocks sit on
  their weapon's record, not the player's: they are listed here only because they gate a whole branch.)
- **Perks:** Guard, Evasion, Critical Hits' Headshot and Backstab; SlowMo's 9; Grapple's 13; Distance Grab's 8;
  Gunslinger's 10; Kill Rewards' 4. About 45 of ours.
- **Stock, shown:** Bandoliers, Blast Shaping, ECM, Hazard Suit, Tough As Nails. **Stock, hidden:** Intuition,
  Juggler, Player Damage, Thorns.

A fresh player (player level 0, every weapon level 0, Kill Rewards on): Melee's hands with the punch (jab,
hook; the uppercut is an unlock), the swat, the Headlock and its throw; Guard if Start With Guard is on; every
weapon at its base; bits from the first kill. No slow motion, no grapple, no Force, one saber (its own second
blade dark), the whip cracks but does not lasso or snag, the grenade as today.

## 6. L1 plumbing this design needs (the handoff's L1, updated)

**Status (11-02, local lane; nothing run yet, compile proof is the owner's):** 1 built as `rsq/zscript/stock.zs`
(Gun Bonsai's own Register / Unregister on its registry, so the pruned names leave the pool everywhere; the row
"Stock Gun Bonsai Upgrades: Silvergun / All", `rsq_stock_mode`). 2 built: `RSQ_Upgrade_Base.Has / PHas / LevelOf` (first named Level, which the headless run caught: ZScript is
case-insensitive and every upgrade has a `level` field).
3 built: service "unlocked" / "punlocked" ("upgrade.num" entries come with each node). 4 built: the whip's `Hurt`
deals inside the claim bracket and `RSQWP_WhipWeapon` is typed melee; the thrown grenade names `RSQGN_Grenade` as
master and is claimed. 5 built: `rsq/zscript/killrewards.zs` (SoM's rules under `rsqgb_kr_*`, the plain page,
Range mode's inverted chance fixed, the ammo bit reads the toucher not consoleplayer, bits read Scavenger / Rich
Bits / Magnet by name once those nodes exist); the row "Kill Rewards: On". 6 partly: the Berserk x5 on a punch is
in Melee; the two-palm thrust is in Gestures (11-02, with Power); `punch.kinds` waits for Combos. 7 (HP Bars) waits for the new `RSQ_Dazed`
states. **Built 11-02 into pk3/RSQ_GunBonsaiVR, RSQ_Whip, RSQ_Grenade, RSQ_Melee; not run; not committed.**
**Headless runs, 11-02 (owner: "you check it headless"; `tools/qzd_hidden_run.ps1`, the series' copy of his SPO
runner without its SPO-only companion; QZD 17.3-m, doom2 + Melee, Whip, Grenade, Gun Bonsai 0.10.6, GBOVR last;
+vr_mode 0, no hands):** both runs "script parsing took ~790 ms", 0 warnings, 0 errors, every pack at its real
lump count. The first attempt found 20 "Numeric type expected" errors from the helper named `Level` (fixed:
`LevelOf`). Proven in the log: "stock upgrades: Silvergun (8 pruned)" on load, "All (8 restored)" within a second
of `rsq_stock_mode 1`, "Silvergun (8 pruned)" again on `0`; Kill Rewards on MAP01's 21 kills: a 20-hp Zombieman
burst into 2 bits, a 60-hp DoomImp into 6 (By Health, 1 per 10), the mix random 1:1:1. **Not provable headless:**
the whip and grenade XP claims (their hits are hand-driven), the Berserk punch, bit pickup, the menus' look. Those
are the owner's headset.

1. The stock-upgrade row "Stock Gun Bonsai Upgrades: Silvergun / All" (section 3.13): a run-time append to
   `disabled_upgrades` for the hidden weapon upgrades on EVERY weapon info (guns too), and a strip of the four
   hidden player upgrades from the offered list. Prove on the rig: a fist level-up offers none of the hidden.
2. `Has(info, "RSQ_Upgrade_X", minLevel)` and the player-level equivalent, used by every `IsSuitableFor*`.
3. The service queries the mods read: `GetInt("level" / "plevel", "<node>")` exist; add `"unlocked"` as a
   convenience (level >= 1) and `"upgrade.num"` entries for every new number above.
4. Whip XP: claim bracket or `master` + `"claim"`; `type RSQWP_WhipWeapon : MELEE`. Grenade XP: `RSQGN_Thrown.master`
   = the grenade weapon + `"claim"`.
5. Kill Rewards folded in under `rsqgb_kr_*`, credit SoM, the plain menu, the On-by-default row.
6. Melee base fixes the design assumes: the Berserk x5 on a punch; `punch.kinds` on `RSQML_Service`; a two-palm
   thrust in Gestures (Clear Out, Force Repulse is struck so only Clear Out needs it).
7. HP Bars reads the new states (frozen, held, disarmed) from `RSQ_Dazed`. The old Star Punch is folded into Uppercut and Launcher;
Lunge, Executioner and Adrenaline stay shared melee nodes (section 2.2) and are not repeated here.

**Owner's verdicts so far (11-02):** two fists, two records; one element per glove; Guard with a Start With
Guard toggle, levelled to Parry, Reflect, Absorb and Release; Berserk pack x5 as base in Melee; Power branch:
all ten kept, Wall Splat renamed Wallflower; Elemental: all four kept; Combos: all four kept; Counter: Guard,
Parry, Reflect Guard, Absorb and Release, Counterpunch, Swat Back, Hadouken, Catch (off), Bullet Time Fists
(off) kept; Grappler: all six kept; Berserk: all three kept; Gun hand: both kept, plus Clear Out (a two-palm
shove); Taunt kept; Critical Hits added as a player upgrade (example mod to come). Saber branches: Focus, Blade,
Stab, Deflect, Dual, The Force in; Rig link out; Star Wars names. Art and sounds from RS Ballistics and RS
Combat FX as the general rule.
