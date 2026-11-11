# RSQ Gun Bonsai VR
### Doom Arcade VR · two hands, two guns that level, and one skill tree for every RSQ weapon and move

Gun Bonsai levels your guns as you fight. This pack (RSQ_GunBonsaiVR.pk3, "GBOVR") makes it work with two hands in
VR: each hand's gun earns its own XP, has its own gauge and its own upgrades. It also turns Gun Bonsai into the RSQ
series' progression: your fists, sabers, ShieldSaw, whip, grenade and grappling hook level up too, and their moves
open one by one down branching trees.

*[GIF to come: a punch kill, the off hand's gauge filling, the level-up cards, an Uppercut picked]*

---

## What it feels like

- **Two hands, two guns, two records.** A kill with the off-hand pistol pays the pistol, not the rifle in your other
  hand. Each hand has its own Gun Bonsai gauge in its own top corner.
- **Credit follows the gun.** A rocket's blast, a burn still ticking after you switched guns, a Brutal Doom round
  arriving a tic later: each pays the gun that fired it.
- **Your fists level up.** Start with a punch. Level the glove and pick an Uppercut, then a Launcher, then a Ground
  Pound. The left fist and the right fist are levelled apart.
- **Every series weapon has a tree.** Saber, ShieldSaw, whip and grenade level like guns. The grappling hook,
  holster draws, slow motion, Kill Rewards and criticals grow when *you* level.
- **Moves are earned.** With this pack loaded, many moves of the other RSQ mods are locked until you learn them, and
  their menu rows grey out until then. Without it, each mod plays as it always did.
- **A new look for Gun Bonsai's screens.** The status screen and the level-up cards are redrawn for the headset,
  with both guns on one screen.

---

## How to play

| Do this | What happens |
|---|---|
| Fight | The gun (or fist, blade, grenade) that did the damage earns XP |
| A gauge glows | That weapon has a level waiting |
| Press Gun Bonsai's **Display Info** key (I by default) | A waiting level opens its cards: the main hand's first, then the off hand's, then a player level. Nothing waiting: the status screen |
| Press it again | The status screen steps to the other hand's gun |
| On the cards: left / right (or up / down), Enter, or 1-4 | Move between the cards and pick one |
| On the cards: Back | Refuses the level (Gun Bonsai's own rule) |
| On the status screen: up / down | Walk the list: main gun, its upgrades, off-hand gun, its upgrades, your player upgrades |
| On an upgrade: Enter / left / right | Switch it off or on, or change the level it plays at |

Seven weapon levels make one player level (Gun Bonsai's default). A player level offers player upgrades: the
grapple, the rig, slow motion, criticals, the Guard and the rest below.

### Controls

| Control | Where it comes from |
|---|---|
| **Display Info** (I by default; Controls, section "Gun Bonsai") | Gun Bonsai's own key (its KEYCONF: `bonsai-show-info`). The only key this pack uses |
| **Debug: Add All**, **Debug: Add Incremental** | Menu buttons on *RSQ Gun Bonsai VR → Test and Debug* (MENUDEF Command rows), not keys |
| **Reset All** | Menu button at the foot of the RSQ Gun Bonsai VR page |

This pack adds no key of its own. Its `keyconf.txt` holds console aliases only (`bonsai-hands`, `rsqgb_add_all`,
`rsqgb_add_step`), with no key section and no default bind. (Gun Bonsai's own LegenDoom key, Cycle Legendoom Weapon
Effect, is Gun Bonsai's and only matters with LegenDoom loaded.)

---

## Gun Bonsai, in brief

Gun Bonsai is **Rebecca "ToxicFrog" Kelly's** mod (MIT licence). Your weapons gain XP from the damage they do (more
against monsters with a lot of health). When a weapon levels up you pick one of several random upgrades
(four by default) for it; picking one you have raises its level. Every seven weapon levels you pick a player
upgrade, which works whatever you hold. Its own options page, its upgrades and its LegenDoom support are untouched.

This pack needs Gun Bonsai 0.10.6 loaded **before** it. It replaces ten of Gun Bonsai's files by path
(under `ca.ancilla.bonsai/`) and adds its own code beside them. No Gun Bonsai art or sound is shipped here.

---

## What the VR edition adds to Gun Bonsai

### Two live hands
- Stock Gun Bonsai knows one weapon: the one in your main hand. Here both hands are live. A weapon held only in the
  off hand still gets a HUD.
- Each hand's upgrades work only on that hand's shots. The chaingun's upgrades never fire on the other hand's
  rounds.
- Upgrades that tick (Rapid Fire, Juggler) run on the hand that holds their weapon. Defensive upgrades on either
  hand's gun protect you.
- A weapon live in one hand is never rebound to the other hand's record, in every Gun Bonsai binding mode.

### Who gets the XP
For each hit the pack works out which weapon caused it, in this order:
1. a burn (Gun Bonsai's damage over time) pays the guns that lit it, in proportion to how much each lit;
2. the Force (RSQ Saber) pays the Force hand's record, and only the Force's own blows do;
3. a gun you threw away (RSQ Tactical Rig) pays its own record, or the player pool if it has none;
4. damage a mod brackets for a weapon (the ShieldSaw's bash and grind, the whip's hit) pays that weapon;
5. a shot a mod claimed for a weapon (a grenade, Melee's glove helpers, the ShieldSaw's returned bullet);
6. a weapon that is itself the inflictor (a saber cut, a glove punch);
7. something spawned by one of these (a rocket's blast, fragments, a batted shot) inherits it;
8. a hitscan by you, from the hand the engine says fired it, or a Brutal Doom VR round born in the tic one hand fired;
9. otherwise a guess from both hands' position, aim, firing state and buttons. The bare Force hand is never guessed.

**The player pool.** A Distance Grab throw (and a barrel blast it sets off), a Headlock throw and the grappling
hook's own blows pay no weapon. Their XP goes to a pool, and every 1200 of it (Gun Bonsai's base level cost) is one
player XP.

**Score XP** (Gun Bonsai's XP from Score setting) goes to the weapon credited with the kill, split by the victims'
health when several kills land together.

**Force Learns From Saber** (on): when the main saber earns XP, the Force hand gets 50% of it on top (Force XP
Share). Nothing else feeds the Force.

### XP Source: Damage, Style or Both
- **Damage** (default): Gun Bonsai's own.
- **Style**: needs RSQ Score. Damage pays nothing. Each kill's style points (Score's bonus rows) become XP:
  the finishing tool takes half, the tools that set the kill up share the other half (one tool takes it all), and
  10% more goes to the player pool (Style Player Share). Gun Bonsai's own score-to-XP stands down.
- **Both**: the damage XP and the style on top.
- Without RSQ Score, Style and Both read as Damage.

### Stock Gun Bonsai Upgrades: Silvergun or All
- **Silvergun** (default) takes eight of Gun Bonsai's upgrades out of the pool everywhere, BD22's guns included:
  Dark Harvest, Life Leech, Armour Leech, Ammo Leech, Intuition, Juggler, Player Damage and Thorns. An upgrade a save
  already has keeps working.
- **All** puts them back.
- On the gloves, both sabers and the ShieldSaw, and on the whip, the grenade and the Force hand when their packs are
  loaded, Gun Bonsai's elemental upgrades and Rapid Fire are never offered. Gun Bonsai's other stock upgrades can
  still be offered on them.

### Smaller fixes
- The XP bars fill in VR. Gun Bonsai cut the fill with a screen clip that misses the HUD in the headset; here it
  is cropped from the art instead.
- Gun Bonsai's level-up flash and its elemental flashes are dimmed and slowed under RSQ Accessibility's
  Photosensitive Mode.
- The status screen says which hand it shows ("Mainhand" / "Offhand", "press again for other hand").
- `netevent bonsai-debug,hands` (console alias `bonsai-hands`) prints each hand's record and the credit counters.

---

## How the trees work

- **Weapon nodes** sit on one weapon's record and are offered when that weapon levels up. Each glove, each saber,
  the ShieldSaw, the whip and the grenade has its own record.
- **Player nodes** sit in your player upgrades and are offered when you level up. A player node is offered only
  while the mod that does its move is loaded.
- **Parents.** A node is offered only once its parent is learned (at the level shown) and while it is under its cap.
- **The move is the other mod's.** This pack offers the node, stores its level and holds its numbers. RSQ Melee,
  Saber, ShieldSaw, Whip, Grenade, Grapple, Tactical Rig, SlowMo, Laser Sight and VisualRewards ask for the level by
  name and do the move. A few nodes do their own work here (marked "here").
- **Learning turns its row on.** A mod row that a node unlocks is greyed until the node is learned. Learning it
  switches that row on once; the row can still turn it off afterwards. A row that is your own setting is switched on
  only on your own machine; a server row only by the game's settings controller.
- **Switched off is off.** An upgrade you switch off on the status screen counts as level 0.
- Levels are written "1 / 2 / 3" for each level in turn. 35 tics are one second.

Never offered any more, kept so old saves load: Star Punch, Chain Choke, Slow Motion (the unlock), Ammo Readout,
Keys by Hand, and the whole Distance Grab tree (Long Arm, Iron Grip, Heavy Hitter, Air Catch, Powder Keg, Dead Eye,
Heavy Lift, Snap Pull, Body Shield).

---

## The Fists tree (RSQ Melee)

On Melee's own hands (and SuperPunchOut's gloves when that pack is loaded). Each glove is levelled apart; the
Grappler branch is the off glove's only. With RSQ Melee loaded but none of these learned, you still punch, swat,
shove and Headlock (Melee's base moves). Without RSQ Melee there are no gloves and none of this is offered.

*[picture to come: the Fists tree as a diagram]*

### Power

| Node | After | Levels | What it does |
|---|---|---|---|
| **Heavy Hands** | (root) | 4 | A landed punch freezes what it hit for 2 / 3 / 4 / 4 tics, 2 more for a punch at half speed or faster. Knockback +25% a level. Turns on Melee's Heavy Hands row |
| **Haymaker** | Heavy Hands 1 | 5 | The harder the punch, the more it adds: +15% a level for the slowest, +50% a level at full speed |
| **Uppercut** | Heavy Hands 1 | 3 | The unlock: until learned, a rising punch is a jab. Learned, it lifts. Levels 2 and 3 throw 2 more units a tic each |
| **Launcher** | Uppercut 2 | 3 | What you uppercut hangs in pain for the flight and staggers 20 / 30 / 40 tics when it lands; 3 more units a tic of lift a level |
| **Juggle** | Launcher 1 | 3 | A punch on a monster you launched, within 2 s and still in the air: x1.75 / 2.0 / 2.25, and Melee lifts it again |
| **Meteor** | Launcher 2 | 3 | A launched monster that comes down on another hurts both: 20 / 30 / 40 plus its fall speed |
| **Ground Pound** | Launcher 3 | 3 | Both fists swung down hard together (3 m/s each): a shockwave 2.5 / 3 / 3.5 m round you for 30 / 40 / 50. With Knockdown on that glove, what it hits goes down for a count of 2. Turns on Melee's Ground Pound row |
| **Clear Out** | Heavy Hands 2 | 3 | Both palms thrust forward: everything in a 90° wedge 2.5 / 3 / 3.5 m deep takes 15 / 20 / 25, is shoved (14 / 16 / 18 units a tic for an imp's weight) and staggered 10 tics. Turns on Melee's Clear Out row |
| **Body Blow** | Heavy Hands 2 | 4 | A hit below the chest winds it: it acts slower for 53 / 71 / 89 / 107 tics |
| **Wallflower** | Haymaker 2 | 5 | A monster punched into a wall slams into it: 10 / 15 / 20 / 25 / 30, up to double for a fast slam, and reels 15 / 20 / 25 / 30 / 35 tics. Turns on Melee's Wall Splat row |
| **Knockdown** | Wallflower 2 or Body Blow 3 | 5 | Glove damage within 2 s of 44 / 38 / 32 / 26 / 20% of its starting health puts it on the floor for a count of 3 / 4 / 5 / 6 / 7, the Super Punch-Out!! announcer counting. No bosses |

Ground Pound and Clear Out are offered only when something reads both hands: RSQ Accessibility's gestures or Melee's
own copy of that reader.

### Elemental (one element per glove)

Learning one closes the other three on that glove. The other glove may take another. The element's own blast, arc
or burn is paid to the glove. The looks are particles and bursts for now.

| Node | After | Levels | What it does (here) |
|---|---|---|---|
| **Explosive Fist** | Haymaker 1 | 4 | A punch at half power or more blasts round the hit: 80 / 96 / 112 / 128 map units, 15 / 20 / 25 / 30 damage, never to you. A Berserk doubles the radius |
| **Frost Fist** | Body Blow 1 | 4 | It freezes solid for 52 / 69 / 86 / 103 tics. The next punch shatters the ice for x2.5 / 3.0 / 3.5 / 4.0. A boss is slowed instead |
| **Shock Fist** | One-Two 1 | 3 | The hit arcs to the 1 / 2 / 3 nearest monsters within 3 m, each taking 50 / 60 / 70% of the punch and an 8-tic stagger |
| **Fire Fist** | Heavy Hands 2 | 4 | It burns for 3 / 4 / 5 / 6 s, 3 damage every half second. A punch on a burning monster flares for x1.5 |

### Combos

| Node | After | Levels | What it does |
|---|---|---|---|
| **One-Two** | (root) | 5 | Alternating hands, each within half a second: each hit adds 15% a level to the next, up to four in a row (here) |
| **Three-Hit** | One-Two 2 | 3 | Jab, jab, hook within a second: the hook does x1.75 / 2.0 / 2.25 and staggers 10 tics (here). It also counts as a critical |
| **Dempsey** | Three-Hit 1 | 3 | Alternating hooks, each within 0.6 s: +10% a level for each hook after the first (here), and the glove re-arms in 4 / 3 / 2 tics instead of 6 (Melee) |
| **Finisher** | Three-Hit 2 and Executioner | 3 | The last hit of a chain of three or more on a staggered monster with 30 / 35 / 40% of its health or less kills it, with a 0.3 s slow-motion pulse (RSQ SlowMo). No bosses (here) |

### Counter

The Guard is a player node (below). **Start With Guard** on RSQ Melee's page counts as Guard 1 for the parents here.

| Node | After | Levels | What it does |
|---|---|---|---|
| **Counterpunch** | Guard | 4 | A punch while it winds up an attack: x1.5 / 1.75 / 2.0 / 2.25, and it reels 26 / 35 / 44 / 53 tics (here) |
| **Swat Back** | Guard | 3 | The open palm's swat sends the missile back at its shooter, x1.15 / 1.30 / 1.45 |
| **Hadouken** | Swat Back 1 or Counterpunch 1 | 4 | A punched missile flies back at whoever fired it: x1.5 / 1.75 / 2.0 / 2.25 damage, +15% speed a level. Turns on Melee's Hadouken row |
| **Catch** | Hadouken 2 | 3 | An open palm held still catches a missile, holds it 3 / 4 / 5 s, and the hand throws it at x1.75 / 2.0 / 2.25 |
| **Bullet Time Fists** | Hadouken 3 | 3 | Needs RSQ SlowMo. In slow motion a punch through a slowed round sends it home at x2 / 2.5 / 3 its damage |

### Grappler (the off glove)

The Headlock and its throw are Melee's base moves; these grow them.

| Node | After | Levels | What it does |
|---|---|---|---|
| **Human Shield** | (root) | 3 | 1 the hold lasts as long as you grip (a minute at most), turned to face away; 2 it takes the blows meant for you from its side; 3 x1.5. Turns on Melee's Human Shield row |
| **Headlock Uppercut** | Human Shield 1, and Uppercut on either glove | 3 | An uppercut on the one you hold lets go and launches it higher, x1.75 / 2.0 / 2.25 |
| **Heavier Headlock** | Human Shield 1 | 3 | Heavier monsters can be held: up to 600 / 800 / 1000 mass (an Arachnotron, then a Baron or Mancubus) |
| **Slam** | Heavier Headlock 1 | 3 | Swing the holding hand down hard (3 m/s): it is driven into the floor, x1.25 / 1.5 / 1.75, and what stands within 1.5 m staggers 15 tics |
| **Throw Into** | Human Shield 2 | 3 | A monster thrown out of the Headlock hits x1.25 / 1.5 / 1.75, and the toss bends onto a monster |
| **Chokehold** | Human Shield 2 | 3 | A held monster is hurt 3 / 4 / 5 every second |

### Berserk

Doom's Berserk pack makes a punch do x5 (RSQ Melee). These grow it.

| Node | After | Levels | What it does (here) |
|---|---|---|---|
| **Rage** | (root) | 3 | While the Berserk lasts, every other node on this glove counts one level higher (never opening a child early). 2: Melee doubles the hit-stop; 3: knockback x1.5 |
| **Blood Rush** | Rage 1 | 3 | A fist kill under the Berserk gives 10 / 15 / 20 armour, with a red flash |
| **Berserk Meter** | Rage 2 | 3 | 300 fist damage fills a meter; full, it gives a Berserk for 25 / 30 / 35 s without a pack. It has a gauge (see The HUD) |

### Gun hand (the gun-butt shove, RSQ Melee)

The shove reads the better of your two gloves.

| Node | After | Levels | What it does |
|---|---|---|---|
| **Pistol Whip** | (root) | 3 | A shoved monster staggers 10 / 20 / 30 tics, and your next hit on it within 2 s does x1.5 / 1.75 / 2.0 |
| **Rifle Butt** | Pistol Whip 2 | 3 | A shove at 4 m/s or more with a long gun (slot 3 and up) knocks a non-boss down for a count of 3 / 4 / 5 |

### Player nodes for the fists

| Node | After | Levels | What it does |
|---|---|---|---|
| **Guard** | (root) | 4 | Needs RSQ Melee. Both fists up at your face: a blow from in front does 60 / 50 / 40 / 30%; one of 35 / 45 / 55 / 65 or more breaks it. Turns on Melee's Guard row |
| **Parry** | Guard | 3 | Hands driven into the blow 4 / 6 / 8 tics before it lands: it does nothing, and the attacker reels 26 / 35 / 44 tics |
| **Reflect Guard** | Guard 2 | 3 | A missile that meets the raised Guard goes back at its shooter, x1.25 / 1.5 / 1.75; at 3 a bullet does too |
| **Absorb and Release** | Reflect Guard 2 | 3 | What the Guard takes charges it (up to 150 / 200 / 250); both hands thrown apart let it out within 4 / 5 / 6 m. Needs the two-hand reader |
| **Taunt** | (root) | 3 | Needs RSQ Melee and the two-hand reader. Both hands thrown apart: what can see you within 10 m turns on you, and your next punch within 3 / 4 / 5 s does double |

---

## Any melee weapon

On any weapon Gun Bonsai calls melee: gloves, sabers, the ShieldSaw, the whip, Brutal Doom's axe and fists.
All three done here.

| Node | After | Levels | What it does |
|---|---|---|---|
| **Lunge** | (root) | 5 | The faster your head travels as the blow lands, the harder: +15% a level for each m/s over 0.5, up to 3 m/s over |
| **Executioner** | (root) | 5 | A staggered monster (no boss) with 15 / 20 / 25 / 30 / 35% of its health or less dies to the next melee hit, through any resistance it has |
| **Adrenaline** | (root) | 5 | Each melee kill charges RSQ SlowMo's adrenaline meter 4 a level. A big moment (three melee kills in 3 s, a monster of 400 health or more, an execution) slows time for 0.45 / 0.6 / 0.75 / 0.9 / 1.05 s, deeper each level (55% down to 35% speed), at most once every 3 s |

---

## The Saber tree (RSQ Saber)

On both sabers' records. The Force hand levels too, and its level-ups offer these same nodes, judged on and stored in
the **main saber's** record, so the blade and the Force share one pool. Several of these were the saber's own
behaviour: under this pack they become unlocks, and without it the saber is exactly as it was.

| Branch | Node | After | Levels | What it does |
|---|---|---|---|---|
| Focus | **Battle Meditation** | (root) | 4 | A throw starts with 1 mark under this pack; 2 / 3 / 4 / 5 marks |
| Focus | **Saber Throw** | Battle Meditation 1 | 3 | When its route is done, the thrown saber finds 1 / 2 / 3 more enemies |
| Focus | **Saber Barrage** | Battle Meditation 2 | 3 | The thrown saber cuts what it passes on its way home, for 65 / 80 / 95% of a cut |
| Focus | **Returning Blade** | Saber Barrage 1 | 2 | The thrown saber flies its marks again before it comes home (2: a third time) |
| Blade | **Elegant Weapon** | (root) | 4 | Damage builds while the blade keeps moving: +10% a level each half second, up to 2 s; drops back when it stops |
| Blade | **Aggressive Negotiations** | Elegant Weapon 1 | 4 | A block primes the blade: the next cut within 1.0 / 1.5 / 2.0 / 2.5 s does x1.5 / 1.75 / 2.0 / 2.25 |
| Blade | **Strike True** | Elegant Weapon 1 | 3 | A cut freezes what it hits 3 / 4 / 6 tics. Turns on the saber's Hit-Stop row (sets it to Heavy, the most the level can use) |
| Blade | **Kyber Attunement** | Elegant Weapon 2 | 4 | The blade grows: 54 cm, then 65 / 76 / 88 / 99 cm |
| Blade | **High Ground** | Aggressive Negotiations 2 | 3 | A cut on a monster (no boss) with 25 / 30 / 35% of its health or less cuts it apart (here) |
| Stab | **Point Taken** | (root) | 3 | A stab driven in with your body (head forward at 0.8 m/s or more): x2.25 / 2.5 / 2.75 |
| Stab | **Run Through** | Point Taken 1 | 3 | A stabbed monster is held on the blade 26 / 35 / 43 tics; pull out and one with 15% or less is finished |
| Deflect | **Deflector** | (root) | 5 | A bolt the saber sent back hits +15% a level harder (here) |
| Deflect | **Return to Sender** | Deflector 1 | 3 | A turned shot goes back at its shooter: 1 when you look within 30° of it; 2 also when the shot would pass within 20° of it; 3 always. Until this or Guided Return, turned shots go straight off the blade |
| Deflect | **Guided Return** | Deflector 1 | 2 | A turned shot goes where you look (onto the enemy nearest your gaze); 2: where your off hand points |
| Deflect | **Piercing Return** | Return to Sender 1 or Guided Return 1 | 3 | A returned bolt goes through 1 / 2 / 3 bodies |
| Deflect | **Precognition** | Deflector 2 | 3 | The blade parries at a slower swing (74 / 59 / 49% of the speed) and blocks a wider line |
| Dual | **Two Sabers** | (root, main saber) | 1 | The second saber is an unlock under this pack |
| Dual | **Assault** | Two Sabers | 4 | Cuts that alternate between your sabers stack: +10% a level each, up to five (here) |
| Dual | **Double-Bladed** | (root) | 3 | 1 the saber's second blade can be lit; 2 it cuts on the backswing (75%); 3 the twirl cuts all round you |
| Dual | **Cross Guard** | Two Sabers (main saber) | 3 | The crossed blades turn what they stop: 1 straight back; 2 at the shooter; 3 and opening the X pushes what is in front away |
| Dual | **Clash** | Cross Guard 2 | 2 | Bringing the blades together releases a shockwave 3 / 4 m round you, staggering 20 tics |
| Force | **Force Sensitive** | (root) | 1 | Under this pack there is no Force until this is learned |
| Force | **Force Push** | Force Sensitive | 4 | 40 / 70 / 100 / 130% of the saber's own strength; 2+: the cone opens 10° a level; 3+: a shockwave all round you too. Turns on the saber's alt-trigger row |
| Force | **Force Pull** | Force Sensitive | 4 | 40 / 70 / 100 / 130%; 2+: what arrives is stunned; 3+: it is disarmed (no ranged attacks) |
| Force | **Force Grip** | Force Sensitive | 4 | 40 / 70 / 100 / 130%; 2+: it lifts and crushes harder the longer you hold; 3+: it holds more than one |
| Force | **Force Jump** | Force Sensitive | 3 | 40 / 70 / 100%; 2+: landing is a slam that throws everything near you. Turns on the saber's Force Jump row |
| Force | **Force Speed** | Force Sensitive and any power at 2 | 3 | The Force hand held up and still for a second, gripping nothing, starts 3 / 4 / 5 s of slow motion (RSQ SlowMo) |
| Force | **Force Lightning** | Force Push 2 and Force Grip 2 | 3 | The Force hand turned palm-down and aimed at a monster for half a second, then flicked: lightning for a second, 8 / 11 / 14 a tic, into 2 / 3 / 4 targets |

A power not yet learned (after Force Sensitive) works at **Force Base Strength** (0, so not at all).

---

## The ShieldSaw tree (RSQ ShieldSaw)

| Branch | Node | After | Levels | What it does |
|---|---|---|---|---|
| Throw | **Lockstep** | (root) | 4 | A throw starts at 1 lock under this pack; 2 / 3 / 4 / 5 |
| Throw | **Ricochet** | Lockstep 1 | 3 | The thrown disc bounces off a wall toward 1 / 2 / 3 new targets |
| Throw | **Wall Bounces** | Ricochet 2 | 3 | It bounces off 4 / 5 / 6 walls on its way to its marks (the row's 3, plus one a level) |
| Throw | **Hunter's Return** | Ricochet 1 | 3 | On the way home it swerves through 1 / 2 / 3 enemies near its path |
| Throw | **Meat Grinder** | Hunter's Return 1 | 3 | A kill while embedded frees the disc to its next lock at full speed (2+: or a new target); the grind +0 / 25 / 50% |
| Throw | **Cleaver** | Meat Grinder 1 | 3 | The hit tiers rise: cut in two at 100 / 140 / 200 health or less (70), stuck and ground at 800 / 1000 / 1200 (600) |
| Block | **Broadening** | (root) | 5 | The blocking plate grows +20% a level, to double at 5. Replaces the ShieldSaw's Double Block Radius row |
| Block | **Bulwark** | Broadening 1 | 4 | A wider perfect-block window: a plate at 74 / 59 / 49 / 42% of the speed still counts |
| Block | **Rebound** | Bulwark 1 | 4 | Shots the shield turns hit x1.25 / 1.40 / 1.55 / 1.70 (here) |
| Block | **Back Plate** | Broadening 2 | 2 | The shield on your back blocks (1) and turns shots (2). Turns on the Block While Holstered row |
| Block | **Shield Wall** | Bulwark 2 | 3 | A perfect block slows time 0.75 / 1.0 / 1.25 s (RSQ SlowMo). Turns on the Perfect-Block Slow-Mo row |
| Block | **Reflect** | Rebound 2 | 2 | A bullet the shield stops and sends back does x1.5 / x2 |
| Bash | **Battering Ram** | (root) | 3 | A bashed monster flies as a missile for 21 tics: what it hits takes 10 / 14 / 18 plus its speed, and it takes half (here) |
| Bash | **Wall Slam** | Battering Ram 1 | 3 | A body bashed into a wall takes +50 / 100 / 150% and is stunned 20 / 30 / 40 tics longer |
| Bash | **Strike True** | Battering Ram 1 | 3 | A bash freezes the monster 4 / 5 / 6 tics. Turns on the Hit-Stop row and raises Hit-Stop Tics to 6 |
| Bash | **Charge** | Wall Slam 1 | 3 | A bash while you move forward at 2 m/s or more strikes everything in a wedge 1.5 / 2 / 2.5 m deep |
| Bash | **Shield Size** | Battering Ram 2 | 2 | Large (x1.25), then Largest (x1.5) |
| Bash | **Shield Dash** | Charge 1 | 3 | Thrust the shield forward at 3 m/s with the stick forward: you dash 3 / 4 / 5 m, landing as a bash; 2 s between |
| Grind | **Hungry Blades** | (root) | 3 | A grind hit 8 / 10 / 12 (6); an embedded disc 4 / 5 / 6 a tic (3) |
| Grind | **Rev Shield** | Hungry Blades 1 | 2 | A revving shield held up grinds what claws it; 2: it turns a blocked missile even with the Deflect row off |
| Grind | **Buzzsaw Return** | Hungry Blades 2 | 3 | The disc coming home grinds what it passes for 65 / 80 / 95% of a grind hit |
| Link | **Spartan** | Broadening 1, and Deflector 1 on a saber | 2 | With the lit blade resting on the shield, a shot the shield turns goes straight at its shooter; 2: a bash in that stance cuts too, paid to the saber |

---

## The Whip tree (RSQ Whip)

RSQ Whip asks for these levels once a second. The Rope perks and the Leash's four (2026-11-10) are RSQ Grapple's
perks with Grapple's numbers, on the whip's own tree (the Grapple's are player perks; these are the whip weapon's).
The Leash is RSQ Whip's **Whip and Gun** mode (the whip in one hand, a gun in the other): a marked crack with the
trigger still held pulls the monster in.
Status: rig only, not headset-confirmed (2026-11-10, Add All against none: `design/rigtest_2026-11-10/evidence/PERKS_*`;
the staggers are shown as Gun Bonsai VR's stagger being asked, not in frames).

| Branch | Node | After | Levels | What it does |
|---|---|---|---|---|
| Crack | **Sting** | (root) | 4 | A crack does +25% a level (12, then 15 / 18 / 21 / 24) |
| Crack | **Stun** | Sting 1 | 3 | The pain a crack causes is held 20 / 30 / 40 tics |
| Crack | **Strike True** | Sting 1 | 3 | A crack freezes the monster 3 / 4 / 6 tics. Turns on the whip's hit-stop row |
| Crack | **Crack Shot** | Sting 2 | 3 | A crack through a monster's missile blows it up; 2-3: and hurts what stands within 2 / 2.5 m by the missile's damage. Turns on the whip's fireball row |
| Crack | **Return Crack** | Crack Shot 1 | 3 | The cracked missile goes back at its shooter instead, x1.25 / 1.5 / 1.75 |
| Reach | **Long Thong** | (root) | 3 | The thong x1.25 / 1.5 / 1.75 (1.8 m to 2.25 / 2.7 / 3.15 m); the lasso reaches four times it |
| Reach | **Quick Mark** | Long Thong 1 | 3 | Pickups and switches are marked 2 m further a level; 3: two pickups at once, one crack fetching both |
| Wrap | **Heavy Yank** | (root) | 3 | A yanked monster flies to you up to 600 / 800 / 1000 mass (400) |
| Wrap | **Pull and Punch** | Heavy Yank 1 | 3 | Needs RSQ Melee. A yanked monster arrives staggered 26 / 35 / 44 tics, so the free hand's punch counts as a counter |
| Lasso | **Lasso** | (root) | 2 | The unlock: the off hand on the thong whirls it as a lasso; 2: a lassoed monster is held 50% longer. Turns on the Lasso row |
| Lasso | **Bola** | Lasso 2 | 2 | The lasso takes two monsters at once (2: three) |
| Rope | **Snag** | (root) | 2 | The unlock: a lash that catches an edge above the hand becomes a rope; 2: edges from the hand's height up. Turns on the Snag row |
| Rope | **Mantle** | Snag 1 | 2 | Reel up to a lip, or lay a hand on it, and go over; 2: from a swing too. Turns on the Mantle row |
| Rope | **Momentum** | Snag 1 | 3 | The swing's speed carries on when you land; 2-3: its top speed 36 / 42 (30). Turns on the carry row |
| Rope | **Tarzan** | Momentum 2 | 3 | Swinging into a monster at 3 m/s or more hurts it 20 / 30 / 40 times your share of the speed and knocks it flat |
| Rope | **Fast Reel** | Snag 1 | 4 | The rope reels you in 10% faster a level (3 a tic, up to 4.2), and a leashed monster comes 10% faster a level (10, up to 14). RSQ Grapple's numbers |
| Rope | **Steady Line** | Momentum 1 | 3 | Hanging with the stick centred, the swing's air drag x4 / x7 / x10, so it settles fast; pushing the stick still pumps. RSQ Grapple's numbers |
| Rope | **Slingshot** | Momentum 1 | 3 | Letting go of a swing in mid-air carries you on x1.1 / 1.2 / 1.3. RSQ Grapple's numbers |
| Leash | **Heavy Lash** | Fast Reel 1 | 3 | Offered only with RSQ Whip's Whip and Gun and Leash on. The Leash's mass limit x1.5 / 2 / 2.5; one still too heavy to come staggers 20 / 30 / 40 tics when caught (once per 3 s) |
| Leash | **Barbed Claw** | Fast Reel 1 | 4 | Offered only with Whip and Gun and Leash on. The Leash's catch does 8 / 12 / 16 / 20, tearing free of a living monster 12 / 18 / 24 / 30 |
| Leash | **Get Over Here** | Heavy Lash 1 | 3 | Offered only with Whip and Gun and Leash on. A leashed monster arrives staggered 35 / 50 / 65 tics |
| Leash | **Bowling** | Get Over Here 1 | 3 | Offered only with Whip and Gun and Leash on. A leashed monster strikes what stands in its path for 10 / 15 / 20 plus half its speed, staggers it 25 / 35 / 45 tics and shoves it aside |

---

## The Grenade tree (RSQ Grenade)

The grenade is a weapon of its own and its thrown grenades are paid to it.

| Branch | Node | After | Levels | What it does |
|---|---|---|---|---|
| Carry | **Bandolier** | (root) | 4 | Carry 10 / 12 / 14 / 16 (8); a backpack doubles it |
| Carry | **Scavenger** | Bandolier 1 | 3 | Grenades lying in a map: 6+3 / 8+4 / 10+5 singles and packs (4+2); 3: one Kill Rewards ammo bit in four is a grenade (RSQ VisualRewards) |
| Throw | **Strong Arm** | (root) | 3 | Throw strength x1.25 / 1.5 / 1.75 |
| Throw | **Flat Arc** | Strong Arm 1 | 2 | Arc 0.25 / 0.15 (0.35) and gravity 0.22 / 0.18 (0.27): flatter and further |
| Throw | **Bounce** | Strong Arm 1 | 3 | Wall bounce 0.40 / 0.55 / 0.70 (0.25): bank shots round corners |
| Throw | **Skeet** | Strong Arm 2 | 3 | Shoot your own grenade in the air and it bursts there at x1.5 / 1.75 / 2.0 |
| Throw | **Skeet Window** | Skeet 1 | 3 | Needs RSQ SlowMo. Eight tics after a throw, slow motion for 15 / 20 / 25 tics and the grenade drawn full bright. Turns on the Skeet Window row |
| Fuse | **Cook Sense** | (root) | 2 (3 with RSQ Gun Cards) | 1 a tick in the holding hand at each second of the fuse; 2 the flash runs amber, then red; 3 the grenade's Gun Cards card counts the seconds |
| Fuse | **Short Fuse** | Cook Sense 1 | 2 | Fuse 2.5 / 2.0 s (3.0) |
| Fuse | **Slow Burn** | Cook Sense 1 | 3 | Needs RSQ SlowMo. A kill by a grenade cooked a second or more, while the world is slowed, slows it again for 0.75 / 1.0 / 1.25 s (here) |
| Blast | **Big Bang** | (root) | 3 | Both radii +15% a level (200 / 255 to 290 / 370 at 3) |
| Blast | **Frag** | Big Bang 1 | 3 | Both damages +15% a level (85 / 75 to 123 / 109 at 3) |
| Blast | **Cluster** | Frag 2 | 3 | The blast throws 3 / 4 / 5 bomblets 2-4 m out (30 damage over 96 units each, 1 s fuse) |
| Blast | **Sticky** | Frag 1 | 2 | It sticks to the first monster it touches (2: or a wall) and goes off there |
| Style | **Teeth** | (root) | 3 | 1 a pin pulled with your teeth pays RSQ Score's Teeth; 2-3 the throw after it does +15 / +30% |

**The kinds.** Each is an unlock (the frag is always yours). The holding hand's alt trigger cycles the kinds you own.
Learning one turns on RSQ Grenade's All Types row.

| Kind | After | Levels | What it does |
|---|---|---|---|
| **Impact Grenade** | Cook Sense 1 | 2 | Bursts on first contact, no fuse; 2: +15% damage |
| **Incendiary Grenade** | Big Bang 1 | 3 | Leaves fire over its radius for 4 / 5 / 6 s, 5 a second |
| **Freeze Grenade** | Frag 1 | 3 | No blast damage: what is inside freezes 3 / 4 / 5 s (bosses slowed); a hard hit on a frozen one shatters it for x2 |
| **Stun Grenade** | Cook Sense 1 | 3 | Half the damage; what is inside staggers 3 / 4 / 5 s |
| **Smoke Grenade** | Cook Sense 2 | 3 | A cloud 4 / 5 / 6 m wide for 12 / 16 / 20 s; monsters in it, or looking through it, lose their target |
| **Flash Grenade** | Cook Sense 2 | 3 | No damage; what is inside is stunned 3 / 4 / 5 s and loses its target |
| **Charm Grenade** | Flash 1 | 3 | What is inside fights for you 15 / 20 / 25 s; bosses immune |
| **Infight Grenade** | Flash 1 | 3 | What is inside turns on the nearest monster 15 / 20 / 25 s; bosses immune |

---

## The Grapple tree (RSQ Grapple; player nodes)

| Node | After | Levels | What it does |
|---|---|---|---|
| **Grapple** | (root) | 1 | The unlock: under this pack the hook fires only once this is learned. Turns on the Grapple row |
| **Momentum** | Grapple | 1 | The rope's Swing and Momentum mode: hang, swing, pump, keep your speed. Turns on its row |
| **Long Line** | Grapple | 4 | The claw flies +20% a level further |
| **Fast Reel** | Grapple | 4 | The claw's flight, the fling and the yank +10% a level faster (x1.4 at 4); the ropes' reel and slide too |
| **Barbed Claw** | Long Line 1 | 4 | The bite does 8 / 12 / 16 / 20; tearing it out of a living monster 12 / 18 / 24 / 30 |
| **Heavy Haul** | Fast Reel 1 | 3 | Things +50% a level heavier and +15% a level bigger come to you; a boss on the line staggers 20 / 30 / 40 tics |
| **Get Over Here** | Heavy Haul 1 | 3 | What the hook brings you arrives staggered 35 / 50 / 65 tics |
| **Bowling** | Get Over Here 1 | 3 | It strikes what is in its way (10 / 15 / 20 and more), knocks it aside 25 / 35 / 45 tics and comes on |
| **Scorpion** | Get Over Here 2 | 3 | Needs RSQ Melee. What the hook brings you is punched by an empty fist at full power, x1.25 / 1.5 / 1.75, as a counter |
| **Double Hook** | Heavy Haul 2 | 3 | A monster on each hand's hook: they are slammed together for 35 / 50 / 65, 50 / 65 / 80 tics |
| **Twin Lines** | Momentum | 2 | A wall rope from each hand at once; holding one's reel takes it in; 2: letting one go flings you along the other |
| **Slingshot** | Momentum | 3 | Letting go of a swing in the air carries you +10% a level further |
| **Steady Line** | Momentum | 3 | Hanging with the stick centred, the swing settles x4 / x7 / x10 faster |
| **Zip Kick** | Momentum, and Slingshot 2 or Steady Line 2 | 3 | Arriving on a monster by the rope at 3 m/s or more hurts it 20 / 30 / 40, times your speed over 3 m/s (up to x3), and knocks it on |

**The hook's XP** goes to the player pool: 15 a bite, 15 a yank, 1 a metre swinging (40 a latch at most), half the
monster's health for a kill it was in on (in the last 3 s), 40 a Double Hook slam, all times **Grapple XP** (1.0).

---

## Gunslinger (RSQ Tactical Rig; player nodes)

| Node | After | Levels | What it does |
|---|---|---|---|
| **Quick Draw** | (root) | 5 | The gun you just drew from a holster hits +10% a level, for 1 s plus a quarter second a level (here) |
| **Pair Draw** | Quick Draw 1 | 3 | A gun drawn as a pair: both hands +8% a level, for 2.5 / 3.0 / 3.5 s (here) |
| **Showdown** | Quick Draw 2 | 3 | Needs RSQ SlowMo. A kill with the gun you drew, within 2 s, slows the world 0.45 / 0.6 / 0.75 s (here) |
| **Gun Toss** | (root) | 3 | Offered only while the Rig's gun throwing row is on. A thrown gun hits x1.5 / 2.0 / 2.5 and staggers 10 tics longer a level |
| **Boomerang Gun** | Gun Toss 2 | 2 | Gun throwing on, too. A thrown gun that hits a monster flies back to its holster (2: to your hand) |
| **Smoker** | (root) | 3 | The cigarette flick's slow motion runs 8 / 10 / 12 s (6), and nothing can hurt you while it does |
| **Chain Smoker** | Smoker 1 | 3 | The pack holds 4 / 5 / 6 (3) |
| **Target Lock** | Quick Draw 1 | 2 | Needs RSQ Laser Sight. The dot grows and pulses on a live monster; 2: it turns the target colour. Turns on those rows |
| **Headshot Reaction** | Target Lock 1 | 2 | The top fifth of a monster turns the dot the headshot colour; 2: a gun hit there counts as a Headshot. Turns on its row |

---

## SlowMo (RSQ SlowMo; player nodes)

Your slow-motion key works from the start; these lengthen and deepen it.

| Node | After | Levels | What it does |
|---|---|---|---|
| **Longer** | (root) | 3 | The burst lasts 5 / 6 / 8 s (4) |
| **Deeper** | (root) | 3 | World speed 0.2 / 0.15 / 0.1 (your World Speed row, 0.25, until learned) |
| **Cheaper** | Longer 1 | 3 | With the adrenaline meter on, slow motion costs 20 / 40 / 60% less |
| **Second Wind** | Cheaper 1 | 4 | Every kill charges the adrenaline meter 3 more a level (here) |
| **Marksman** | Deeper 1 | 5 | Everything you hit while the world is slowed takes +8% a level (here) |
| **Time Dilation** | Marksman 1 | 3 | A kill while slowed keeps it slowed 0.4 / 0.55 / 0.7 s more and gives 2 adrenaline a level back (here) |
| **Dodger** | Deeper 1 | 4 | While slowed you take 8% a level less (here) |
| **Lean Dodge** | Dodger 1 | 2 | Leaning out of a slowed round's path makes it miss; 2: a claw too. Turns on the lean row |
| **Matrix** | Deeper 3 | 1 | The colour drain and the shot trails at full while slowed. Turns on both rows |

---

## Kill Rewards (RSQ VisualRewards; player nodes)

Offered only while VisualRewards' Kill Rewards is loaded.

| Node | After | Levels | What it does |
|---|---|---|---|
| **Gastropub** | (root) | 3 | +25 / 50 / 75% bits a kill |
| **Rich Bits** | Gastropub 1 | 3 | A health or armour bit is worth x2 / 3 / 4; an ammo bit 8 / 11 / 14 rounds |
| **Magnet** | Gastropub 1 | 3 | Bits within 2 / 3 / 4 m drift to you. Turns on its row |
| **Lucky Kill** | Rich Bits 1 | 3 | A kill landed by a critical, a Headshot, a Backstab, a Finisher or an RSQ Score big moment drops x2 / 3 / 4, with a big burst |

---

## Critical Hits (player nodes, always offered)

| Node | After | Levels | What it does (here) |
|---|---|---|---|
| **Critical Hits** | (root) | 3 | A hit while a monster winds up its attack is a critical: x1.75 / 2.0 / 2.25, and it is stunned 1 s; hits on a stunned one do x1.5 / 1.75 / 2.0. Three criticals in 15 tics at most. Level 1 melee only, level 2 guns too |
| **Headshot** | Critical Hits 1 | 3 | A hit in the top fifth of a monster: x2.5 / 3.0 / 3.5; a shotgun's later pellets count half |
| **Backstab** | Critical Hits 1 | 3 | A melee hit from behind (within 60° of its back): x4 / 5 / 6; a kill this way is silent |

---

## Two hands and the body (player nodes, always offered)

All done here.

| Node | Levels | What it does |
|---|---|---|
| **Akimbo** | 5 | While both hands are firing (each within a third of a second): +6% a level |
| **Crossfire** | 4 | A hit on something other than what your other hand hit in the last second: +10% a level |
| **Alternator** | 4 | Each hit with the other hand's gun within two thirds of a second adds 4% a level to the next, up to four in a row |
| **Southpaw** | 4 | Whatever your off hand holds hits +6% a level |
| **Evasion** | 4 | Moving your head at 1.2 m/s or more, you take 8% a level less |
| **Steady Aim** | 4 | A bullet fired with your head still (under 0.2 m/s) hits +5% a level |

---

## The HUD

*[picture to come: both hands' gauges in the headset, the off hand's top left, the main hand's top right]*

- **Dual HUD** (on): each hand's gun gets Gun Bonsai's own gauge. The main hand's is top right, the off hand's top
  left, mirrored as a pair. An empty hand draws no gauge. A left-hander (RSQ Accessibility's handedness, else
  QuestZDoom's Control Scheme) gets the pair swapped.
- **Single HUD** (Dual HUD off): one gauge in Gun Bonsai's own place, following **Single HUD Follows** (Main Hand,
  Off Hand, or the Last to Earn XP), falling back to whichever hand holds a gun. The row is greyed while Dual HUD is
  on.
- **HUD Position**: each gauge's place across and down, and its mirror (None, Left-Right, Up-Down, Both). Dual HUD
  only: the six rows are greyed while it is off.
- **HUD Colour Cycle** (on for both): the gauge's frame and its two bars cycle through Gun Bonsai's level-up
  rainbow all the time. Speed, Spread (the gap between frame and bars) and Intensity per hand; 1.0 each is Gun
  Bonsai's own. A waiting level-up cycles whatever the switch.
- **The bars breathe** (with GBOVR Menus and HUD on): each XP bar pulses slowly around its own colour, warms toward
  amber and quickens past 60% full, flashes toward white when XP comes in, and flares when a level is ready.
- **No HUD over a menu** (owner 11-11): while any menu is open (the options, the status screen, the level-up cards),
  the gauges, the Berserk gauges and the Ammo and Health Row are not drawn. RSQ Score's line and RSQ Miniboss's meter
  hide the same way.
- **RSQ Score's line** sits centred just below the two gauges (it moves down until it clears the lower gauge, in
  Dual HUD or single HUD; Score's own Across and Down rows still place it below that).
- (The ShieldSaw Gauge, a third gauge for the ShieldSaw on the shoulder, was removed on 11-11 by the owner: its row
  and setting are gone.)
- **Berserk Meter Gauge** (on): a tall red gauge on the glove's side for each glove that has learned Berserk Meter.
  It fills with that glove's fist damage, then drains as the earned Berserk runs out. Hidden under a Berserk pack.
  **Gauge Animation** (on): a band of light rising through it, a breathing edge, a glint when full.
- **Ammo and Health Row** (on, with GBOVR Menus and HUD on): along the bottom, each hand's reserve and magazine on
  its own side, health, the face and armour in the middle. While it is on, Brutal Doom's own HUD is switched to a
  type that draws nothing (put back when the row goes off).
- **Ammo Row and Berserk Gauge Size** (1.5) sizes the Ammo and Health Row and the Berserk gauge; **HUD Inset** keeps the screens and that
  row clear of the headset's edge. Gun Bonsai's own gauge size is on Gun Bonsai's page.
- **Colour-blind modes** (RSQ Accessibility): the two bars take the series' colour pair for that vision, a waiting
  level makes the whole gauge pulse in brightness, the Colour Cycle and the warming are off.
  **Photosensitive Mode**: no cycling, breathing or flashes; the earned-Berserk pulse stays slow.

### The screens

With **GBOVR Menus and HUD** on, Gun Bonsai's status screen and level-up menus are replaced by the owner's mockups.
Off, Gun Bonsai's own menus come back unchanged.

*[picture to come: the status screen with both guns]*
*[picture to come: the level-up cards]*

- **The status screen**: PLAYER STATUS (your level, XP and player upgrades) on the left; a card for each hand's gun
  (its picture, name, level, XP) with its WEAPON STATUS list beside it; a DESCRIPTION box with the selected
  upgrade's text and numbers along the bottom. Upgrades you switched off show as [OFF]. **Display Info** opens it
  on the main hand's gun first; pressing it again steps to the other gun.
- **Gun pictures:** the gun's icon or pickup sprite. A blank one (a 1x1 or TNT1 sprite) counts as none. The whip
  shows the series' whip icon (a copy of RSQ Wheel's, shipped in this pack). The bare fist shows Brutal Doom's own fist
  sprite (FISTD0), then RSQ Melee's glove icon for that hand (RMICA0 / RMICB0), then RSQ Wheel's fist icon. RSQ
  Melee's gloves show their own icons. Anything with no picture at all shows "?".
- **The level-up cards**: the gun's name (or "LEVEL n" for a player level) as the title, then up to four cards in
  orange, cyan, magenta and green, each with the upgrade's name, its text and the level it takes it to. More than
  four: page with left and right.
- The mockup's ITEMS slots and WEAPON BOND panel are not drawn: no feature fills them.

---

## Plays well with

- **RSQ Melee:** the Fists tree. Melee asks this pack for the levels and numbers of its moves by name and does
  them: the uppercut, Wall Splat, Ground Pound, Clear Out, Guard, Hadouken, Heavy Hands, Human Shield and the rest.
  Its rows for them grey out until learned, and **Start With Guard** counts as Guard 1 here. Melee also asks this
  pack to stagger, knock down or mark a monster (Wall Splat, Ground Pound, Pistol Whip) and whether a weapon is a
  melee weapon (Slappers Only, Guard). The pack's critical, Finisher, element and Lucky Kill bursts and sounds are
  Melee's, played by name.
- **RSQ Saber:** the Saber tree and the Force. The Force's own blows pay the Force hand; Force Learns From Saber
  shares the saber's XP.
- **RSQ ShieldSaw, RSQ Whip, RSQ Grenade, RSQ Grapple, RSQ Tactical Rig, RSQ SlowMo, RSQ Laser Sight:** their trees
  above; each reads its levels by name. The ShieldSaw's turned shots, the grenade's cook and the Rig's last draw are
  read back for Rebound, Slow Burn and the Gunslinger nodes. Slow-motion pulses go to SlowMo.
- **RSQ VisualRewards:** the Kill Rewards nodes. Its damage numbers read each hand's gun level from this pack, and
  its monster bars show a star over a monster this pack holds staggered or stunned.
- **RSQ Score:** XP Source Style reads each kill's style and combo chain. Many nodes report their move to Score's
  combo ledger (crits, headshots, shatters, Finishers...). Score's line sits centred just below the hand gauges (it asks this pack where they end).
- **RSQ Gun Cards** and **RSQ Wheel:** show each gun's Gun Bonsai level and upgrades, read from this pack's service.
  Gun Cards adds Cook Sense's third level.
- **RSQ Glow In The Dark:** a gold wave at a level-up, read from this pack's service.
- **RSQ Miniboss:** can set its tier from your Gun Bonsai player level and fill its meter from Gun Bonsai XP.
- **RSQ Distance Grab:** a throw's XP goes to the player pool. It has no tree.
- **RSQ Accessibility:** handedness, colour-blind modes, Photosensitive Mode, Text Size on the screens; its
  gestures are the two-hand reader Ground Pound, Clear Out, Absorb and Release and Taunt need.
- **Brutal Doom VR (BD22 VR):** its True Bullets rounds pay the hand that fired them. Its fists are typed melee.
  Cleaver's tiers follow its gib tiers.
- **LegenDoom and Champions:** "a share of its health" (Knockdown, Executioner, Finisher, High Ground) uses the
  boosted health these give. Gun Bonsai's own LegenDoom support is untouched.
- **SuperPunchOut:** its gloves are melee and can take the Fists tree.

---

## Options

*Radiant Silvergun Options → RSQ Gun Bonsai VR* (also at the foot of Gun Bonsai's own options page). Raw numbers
are under Test and Debug. **Reset All** resets every setting on both pages.

| Section | Rows |
|---|---|
| (top) | Stock Gun Bonsai Upgrades (Silvergun / All; Silvergun) · XP Source (Damage / Style / Both; Damage) · Force Learns From Saber (On) · Force XP Share (50) |
| HUD | GBOVR Menus and HUD (On) · Ammo and Health Row (On; greyed with GBOVR Menus and HUD off) · Ammo Row and Berserk Gauge Size (1.50) · Dual HUD (On) · Single HUD Follows (Main Hand / Off Hand / Last to Earn XP; Main Hand; greyed with Dual HUD on) · Berserk Meter Gauge (On) · Gauge Animation (On) |
| HUD Position (greyed with Dual HUD off) | Main HUD Across (0.99) · Main HUD Down (0.02) · Main HUD Mirror (None / Left-Right / Up-Down / Both; Both) · Off HUD Across (0.01) · Off HUD Down (0.02) · Off HUD Mirror (Up-Down) |
| HUD Colour Cycle | Main HUD Colour Cycle (On) · Main HUD Cycle Speed (1.0) · Main HUD Cycle Spread (1.0) · Main HUD Cycle Intensity (1.0) · Off HUD Colour Cycle (On) · Off HUD Cycle Speed (1.0) · Off HUD Cycle Spread (1.0) · Off HUD Cycle Intensity (1.0) |
| Test and Debug | Force Base Strength (0.00) · Grapple XP (1.0) · Style XP Scale (1.0) · Style Player Share (10) · HUD Inset (0.04) · Debug Log: Style XP and Learned Rows (Off) · Debug: Add All · Debug: Add Incremental |

**Debug: Add All** gives every node of this pack at its cap, through the trees' own parents and caps (the player's
and every weapon you carry). **Debug: Add Incremental** adds one level of every node offered right now. Gun Bonsai's
stock upgrades are never touched. A saber-tree node offered on the Force hand is stored on the main saber, as a real
level-up stores it. **Debug Log: Style XP and Learned Rows** prints the Style XP payments and each row a learned node switches on.

*[picture to come: the RSQ Gun Bonsai VR options page]*

---

## Status

| | |
|---|---|
| **code only, not shown** (2026-11-11, the owner's five HUD decisions, `design/rigtest_2026-11-10/RESULTS_HUD11.md`; not run on the rig by the owner's order "no rig test, code only until i say") | The ShieldSaw Gauge removed (drawing, row, setting, service band). No gauge, Berserk gauge or Ammo and Health Row while a menu is open. The `gauges.bottom` service that puts RSQ Score's line centred under the gauges. Display Info opening on the main hand first. The whip's and the bare fist's pictures on the status screen. The pack compiles in the owner's order with no script error or warning of its own (load check before the order) |
| **rig only, not headset-confirmed** (2026-11-11, `design/rigtest_2026-11-10/RESULTS_GBOVR.md`, the owner's order, the pk3 built after the 11-10 fixes; XP given by debug, every level taken through Display Info and the cards' Enter, no Add All) | **The status screen** (PLAYER STATUS, both guns' cards and WEAPON STATUS lists, the DESCRIPTION box, the list walked to its end, a second press stepping to the other gun; no ITEMS or WEAPON BOND panel) (`evidence/GB_2_status_screen_cursor_main_upgrade_and_player_upgrade.jpg`). **The level-up cards**, weapon and player (`GB_3_levelup_cards_fists_saber_player.jpg`, `GB_3_levelup_card_grenade_480px.jpg`). **A level-up on every tree:** Fists, Melee, Saber, the Force (stored on the main saber), ShieldSaw, Whip, Grenade; SlowMo, Guard, Two hands and the body, Grapple, Gunslinger, Critical Hits, Kill Rewards (Gastropub, Rich Bits, Magnet, Lucky Kill in order) (`GB_GB2_log.txt`, `GB_GB3_log.txt`, `GB_GB4_log.txt`). **Both gauges' Colour Cycle** after the fixes (`GB_1_gauges_colour_cycle_both_hands.jpg`). **The greyed rows:** Single HUD Follows with Dual HUD on; the six HUD Position rows and ShieldSaw Gauge (since removed) with it off (`GB_5_options_page_dual_hud_on_off.jpg`, row dump in `GB_GB3_log.txt`). **Score's line** moved down only while the ShieldSaw gauge was drawn (shift 0.109 with it, 0 with Dual HUD off or the row off; gauge removed since) (`GB_6_score_line_vs_shieldsaw_gauge.jpg`). The start line "v0.10.6+RSQ" |
| **rig only, not headset-confirmed** (2026-11-10, design/rigtest_2026-11-10, the owner's order with BD22 VR 2.0.4f, Legion of Bones, Champions and Gun Bonsai; the pk3 built 2026-11-09, before the 11-10 fixes below) | Loads with no script error of its own. Both hands' Gun Bonsai gauges drawn, the off hand's ("Fist") top left and the main hand's ("Rifle") top right, their frames changing colour from frame to frame (evidence/A4_score_wrist_steps_aside.jpg, A4_remote_wrist_panel_full.jpg) |
| **rig only, not headset-confirmed** (2026-11-10, the debug Add All in the batch's runs: `design/rigtest_2026-11-10/RESULTS.md`, `RESULTS_P2.md`) | Nodes given by Add All at work in play: the whip tree's Rope perks against none (Fast Reel, Steady Line, Slingshot, Heavy Lash, Barbed Claw, Get Over Here, Bowling; `design/rigtest_2026-11-10/evidence/PERKS_*`; the stagger they ask for was logged as asked, not seen); Two Sabers giving the second saber (`P2B_log.txt`); Force Sensitive gating Force Pull (not learned: nothing; learned: the pull) (`P2E_log.txt`); the ShieldSaw's Ricochet (`P2G_log.txt`). Only Add All against none: no level-by-level climb |
| **rig only, not headset-confirmed** (2026-11-09, design/rigtest_2026-11-09/batch3 launch logs, full order) | The pack's start line, "RSQ Gun Bonsai VR: stock upgrades: Silvergun (8 pruned)" |
| **rig only, not headset-confirmed** (2026-11-03, VisualRewards/test/evidence/merge_vr_gbnodes.txt, doom2 and a probe that grants nodes) | The Kill Rewards path offered by its parents (Gastropub alone, then Rich Bits and Magnet, then Lucky Kill), VisualRewards reading each level, a Lucky Kill; Bandolier and Scavenger granted on the grenade and ammo bits giving grenades |
| **code only, not shown** (the rest of the 11-10 fixes; the start line, Score's line, the Force's pool, the hidden placeholders and the greyed rows are shown above) | Elemental upgrades and Rapid Fire barred on the whip, the grenade and the Force hand. Skeet Window and Slow Burn offered only with RSQ SlowMo loaded. Heavy Hands, Hadouken and Wallflower capped on their learned level (Rage's +1 no longer closes them early). Debug: Add All / Add Incremental store saber-tree nodes on the main saber, as a real level-up does (the real level-up's storing is shown above). Learning a node switches a user row only on that player's own machine and a server row only on the settings controller's. Headshot Reaction 2 counts gun hits (puffs and bullets), not only hits that named the player. Critical Hits makes a monster's token only on a critical. HUD Size renamed Ammo Row and Berserk Gauge Size; Debug Log renamed Debug Log: Style XP and Learned Rows. The unused full-gauge art and the old HUD drawing code removed. readme.txt, docs/ and this draft no longer go into the pk3 |
| **code only, not shown** | Everything else on this page: every tree's moves in play (learning one is shown above), the Ammo and Health Row (in the 11-10 frames the base status bar is drawn at the bottom instead), the bars' breathing, the HUD Colour Cycle switches and sliders, the Berserk gauge, Style XP, the hook's XP, the Force's 50% share, the debug rows. GBOVR_TREES.md records headless probe runs of most trees on 2026-11-02 and an XP-credit measurement on 2026-11-03 (xpprobe; the Force share was 25% then), and commit 756de18c's message reports the Colour Cycle on the rig on 11-07; none of their logs or frames are in the repo, so they are not counted as shown |
| **not yet run** | On the screens: refusing a level (Back), toggling or tuning an upgrade on the status screen, paging past four cards, keys 1-4, and the screens with GBOVR Menus and HUD off. Seen in the 11-11 frames, for the owner: Score's line sat on the main gauge's weapon name; the gauges drew over the options page's top rows; the whip had no picture on the status screen; Display Info opened on the off hand (all four changed 11-11, code only, above) |

Known gaps (from reading the code): Gun Bonsai's other stock upgrades can still be offered on all the series
weapons. Only the whip's gun picture ships for the status screen; the rest fall back to each gun's icon or pickup sprite.

---

## Under the hood

- **Stock QuestZDoom 17.3, ZScript and data only.** Gun Bonsai 0.10.6 must load first. The console's start line
  reads "Initializing Gun Bonsai v0.10.6+RSQ..." (Gun Bonsai 0.10.6, this pack's build). Two ZSCRIPT lumps: the
  shadowed Gun Bonsai files compile in Gun Bonsai's own tree; `zscript.txt` adds new classes only. Every other mod
  is found by class or service name while the game runs; nothing links.
- **Shadowed Gun Bonsai files:** `EventHandler.zsc`, `HUD.zsc`, `PerPlayerStats.zsc`, `WeaponInfo.zsc`,
  `WeaponTypeInference.zsc`, `debug.zsc`, `menu/StatusDisplay.zsc`, `upgrades/Dot.zsc`, `upgrades/Juggler.zsc`,
  `upgrades/RapidFire.zsc`.
- **Credit:** a provenance record per spawned shot (a weighted list of weapon records), a hitscan bracket opened in
  `WorldHitscanPreFired` and closed in `WorldHitscanFired`, a claim bracket for script damage, and a scored guess.
  Mods can claim a shot with `TFLV_VR_Attribution.Claim(shot, weapon, hint)`; the hint (hitscan, projectile, melee)
  keeps Gun Bonsai's type guess right for a gun whose bullets travel.
- **Services:**
  - `RSQ_MeleeUpgradeService`: `loaded`, `level` / `unlocked` (a node on a weapon, or the best on anything carried),
    `plevel` / `punlocked` (player nodes), `weapon.level` / `weapon.xp`, `claim`, `credit.push` / `credit.pop`,
    `stagger`, `freeze`, `knockdown`, `whip.mark`, `ram`, `is.melee`, `kr.luckyfx`; GetString `kr.lucky`; GetDouble
    `upgrade.num` (every move's numbers), `head.mps`, `force.start`.
  - `RSQGB_Service`: a gun's `level`, `xp`, `xp.next`, `xp.permille`, `count`, `hand`, `player.level`, and the
    strings `upgrades` ("Name:level:max:Class:on:Colour|...") and `name`.
  - `RSQ_HudService` (ui): `gauges.bottom` (permille of the screen's height, the lowest hand gauge drawn; -1 while
    none is drawn).
  - `RSQTHP_MarkerGBVR`: `stunned`, for the monster bars.
- **Network events:** Gun Bonsai's `bonsai-show-info`, `bonsai-choose-level-up-option`, `bonsai-toggle-upgrade` and
  `bonsai-tune-upgrade`; this pack's `rsqui-menu-hand` (which hand the status screen acts on), `rsqgb_dbg_all` and
  `rsqgb_dbg_step` (the debug rows; console aliases `rsqgb_add_all`, `rsqgb_add_step`), `bonsai-debug,hands`. Slow
  motion is asked of RSQ SlowMo with its `rsm_pulse`. QuestZDoom has no netplay.
- **Event handlers** (MAPINFO): `RSQ_MeleeHandler` (head speed, two-hand timing, helper traces, learned rows),
  `RSQ_HookHandler` (the hook's XP), `RSQUI_Handler` (the screens, the settings version), `RSQ_StyleXP`,
  `RSQ_StockHandler` (re-checks Stock Gun Bonsai Upgrades every map and once a second), `RSQUI_Gauges` (the Berserk
  gauge), `RSQ_DebugGrant`.
- **One token per monster** (`RSQ_Dazed`) holds every timed state this pack puts on it: stagger, winded, down,
  disarmed, frozen, burning, stunned, the Pistol Whip mark. It is made only when one of those is put on a monster.
- **Server and user settings:** Stock Gun Bonsai Upgrades, XP Source, the Force rows, Grapple XP, the Style numbers,
  GBOVR Menus and HUD, Ammo Row and Berserk Gauge Size, HUD Inset and Ammo and Health Row are server settings; the hands' HUD rows, ShieldSaw
  Gauge and the Berserk gauge rows are your own. Debug Log is not saved.
- **Saves:** a learned upgrade is kept by its class name, so renamed nodes keep their old classes
  (`RSQ_Upgrade_ReturnFire` is Hadouken, `WallSplat` Wallflower, `Momentum` Elegant Weapon, `RiposteEdge` Aggressive
  Negotiations, `DualHarmony` Assault, `ForceChoke` Force Grip, `BitScavenger` Gastropub), and nodes no longer
  offered stay defined. A save from before "GBOVR Menus and HUD" turns any old screen look On once.
- **Removing the pack** while the Ammo and Health Row is on leaves Brutal Doom's `bd_sbartype` at 5: turn the row off
  first, or set it back by hand.

---

## Credits

- **Rebecca "ToxicFrog" Kelly:** Gun Bonsai (MIT). The ten shadowed files are derived from Gun Bonsai 0.10.6;
  its licence is in COPYING.md. Gun Bonsai's HUD art (Sungraphica, CC-BY-4.0, with Craneo), item and effect sprites
  (Willibab), Freedoom sprites and sounds (GameSupplyGuy) stay in Gun Bonsai's pk3 and are drawn from there.
- **presidentkoopa:** this pack, its trees and screens (from his mockups), and SuperPunchOut, whose sounds it uses:
  the hit and the knock from Punch Out Doom / Virtual Punch Out, and the Super Punch-Out!! announcer's count
  (Punch-Out!! is Nintendo's). The HUD Colour Cycle's tuning is from his earlier fork.
- **coldcite:** the Top HP Bars bar art the Berserk gauge is made from ("feel free to use this in your mods").
- **RSQ Melee's** bursts (kiddolink's "VFX Hit Impact", bought for this series) and sparks are played by name, not
  shipped here.
- **id Software / GZDoom:** stock sounds played by name (the item pickup, the ice break).
- **QuestZDoom** (Emawind and Team Beef): the engine and its two-hand weapon API.
