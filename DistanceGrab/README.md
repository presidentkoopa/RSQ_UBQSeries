# RSQ Distance Grab

Turn your palm out at anything across the room, flick your wrist, and it flies into your hand.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New since the headset pass (tested on the rig, headset check pending): Kill Rewards bits are never grabbed; the throw measured against the frame your headset drew, so walking and stairs are no throw.

Gravity-glove grabbing for Doom in VR, built on stock QuestZDoom 17.3 in ZScript alone. No buttons in the
gesture: your palm is the trigger. Pull ammo, health, keys and guns to you, catch them out of the air, carry a
barrel in one hand, throw it at an imp and watch it go off. Lift doors by hand. Everything has weight: a keycard
snaps to you, a barrel heaves.

## Standout feature: the pull and the catch

Turn your hand palm out toward a medikit. A blue beam reaches from your palm; the medikit glows amber as the cone
finds it, then green as your hand takes hold. Flick your wrist up as you roll your palm back. The medikit lifts off
the floor, arcs across the room tumbling end over end, dips under the door frame, and slows into your hand.
Turn your palm back out and you catch it: it heals you on the spot, or a gun you pull goes into the hand that grabbed
it. Turn your hand away and it drops at your feet. Your hand rumbles as it locks, as the pull builds, and hard on
the catch.

## Features

**Reach and pull**
- **The palm is the trigger.** Palm out arms the reach and holds it. A wrist flick pulls. Rolling the palm back
  at rest lets go. Nothing to press, so nothing can get stuck.
- **A true cone in the room:** 12° wide, about 15 m long, and it will not reach through walls.
- **Clear signals:** a beam from the palm, a dot where it lands and a faint cone showing exactly what can be
  taken. Targets glow amber when considered, green when locked.
- **The WorldHands pull (default):** an authored arc that starts slow, speeds up, lifts out of alcoves, ducks
  under doorways, tumbles and spins, then settles softly into your palm. Steer and Lob paths are also offered.
- **Weight:** every object has a mass. Light things fly, heavy ones resist.
- **Catch it:** an open palm takes it out of the air. Pickups are used on the catch (or carried, if you prefer).
- **Guns go to the hand that grabbed them,** main or off.

**Carry and throw**
- **Carry:** a barrel (or a corpse, if switched on) stays in your hand on a spring. Heavy things trail, sag and
  tip with your wrist. Walls stop it.
- **Two-hand lift:** lay your other empty palm on what you carry and it handles twice as light.
- **Throw:** swing your arm and it lets go by itself as the swing peaks. A barrel thrown hard explodes where it
  lands.
- **Impacts hurt:** thrown things deal damage from their speed and weight, stagger what they hit hard enough,
  and a light aim assist bends a throw onto a nearby monster.
- **Club with it:** swing what you carry into a monster to hit it.
- **Body shield:** a held barrel or corpse stops bullets and fireballs. A barrel goes off when it is hit.
- **Heavy slows you:** carrying 120 kg halves your speed.

**Up close**
- **Walk-up grab:** grip with your palm on a pickup or barrel (or a corpse, if switched on) to take it straight
  into your hand.
- **Lift doors by hand:** put a hand on a door, take hold and lift. The door's own sound speeds up with your
  hand. Let go past 40% open and it finishes opening; let go sooner and it drops shut. Keys are still honoured.
- **Palm on a switch** flips it.

**Plays nice**
- Stands down while you two-hand a gun, while a hand holds a melee weapon or a lit saber, wears RSQ Melee's
  gloves or has just thrown a punch. A hand that cannot reach says why on screen.
- Doom's own sounds only: a whoosh on a throw, higher the faster; a thud on a catch or landing, deeper the
  heavier.

## How To Play

1. **Reach:** raise a hand and turn it a quarter turn so your palm faces outward, not pointing at the floor.
   The beam appears. Point it at a pickup. The pickup glows amber, then green: you have it.
2. **Pull:** flick your wrist up sharply as you roll your palm back. The thing flies to you. Turn your palm out
   again before it arrives to catch it.
3. **Change your mind:** roll your palm back slowly, with no flick. The lock lets go and nothing moves.
4. **Carry and throw a barrel:** pull a barrel and catch it. It stays in your hand. Swing your arm toward a
   monster to throw it. Roll your palm back with the hand still to set it down.
5. **Up close:** walk to an item, put your palm near it and squeeze the grip. For a door, lay a hand on it, grip,
   and lift.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Arm the reach | Palm out: wrist turned 90° (±30°), hand no lower than 30° below level | Either hand. Each hand reaches on its own. |
| Lock a target | Hold the cone on it with the palm out | Locks at once by default. The lock survives looking away. |
| Pull | Flick the wrist up (5° per tic or faster) as you roll the palm back | |
| Let go of a lock | Roll the palm back slowly | |
| Catch | Palm out when the object reaches your hand | A miss drops it at your feet. |
| Throw | Swing the arm forward past 2.5 m/s while carrying | Lets go as the swing slows. Rolling the palm back mid-swing throws too. |
| Set down | Roll the palm back with the hand still | |
| Two-hand lift | Other palm on the carried object, that hand empty | |
| Walk-up grab | Grip with the palm within 0.30 m of a pickup or barrel | Release the grip to drop; release while moving to throw. |
| Lift a door | Hand on the door, then grip, Use or palm out, and lift | Ordinary manual doors, from the front. |
| Flip a switch | Palm out against the switch | |

**Key binds** (Options → Radiant Silvergun Options → RSQ Distance Grab → Controls, or Customize Controls → RSQ
Distance Grab): Grab Main Hand, Grab Off Hand. Desktop defaults G and H; no controller defaults. These binds only
drive the grab when Button Fallback is on (off by default): press to lock or catch, release to pull or let go.
RSQ Grapple and RSQ Whip also use them to take hold of a rope.

Left-handed play works: the engine's left-handed scheme swaps the hands, and the palm test reads both wrists the
same way.

## Menu

Options → Radiant Silvergun Options → RSQ Distance Grab

| Row | Default | What it does |
|---|---|---|
| Distance Grab | On | The whole mechanic. |
| Reach | Standard | Short, Standard (512 units, about 15 m), Long, Room. |
| Aim | Standard | Cone width: Precise, Standard (12°), Generous. |
| Gesture | Standard | Relaxed, Standard or Strict palm and flick. Strict adds a short lock delay. |
| Not With Melee | On | A melee hand (weapon, gloves, a punch just thrown, a lit saber) does not reach. |
| Flight Path | WorldHands | Steer, Lob or WorldHands. |
| Pull Speed | Standard | Gentle, Standard or Snappy. |
| Throw Strength | Standard | Soft, Standard or Strong. |
| Heavy Slows You | On | Carrying heavy things slows you. |
| Beam | On | The beam from your palm. |
| Haptics | On | Controller feedback. |
| Lift Doors | On | Doors can be lifted by hand. |

**What You Can Grab**

| Row | Default | What it does |
|---|---|---|
| Barrels | On | |
| Weapons | On | |
| Powerups | On | Spheres, berserk, suit, map. |
| Corpses | Off | |
| Ammo | On | |
| Health | On | |
| Armor | On | |
| Keys | On | |
| +1 Bonuses | On | Health and armor bonuses. |
| Walk-Up Grab | On | Grip with the palm on a thing takes it. |
| Walk-Up Reach (m) | 0.30 | How close the palm must be. |
| Line of Sight | On | No grabbing through walls. |
| Use Pickups on Catch | On | Off: everything caught is carried instead. |
| Tip With Wrist | On | A held thing tips as you turn your wrist. |
| Pull Gravity | Off | Lets a Steer pull sag. |
| Duck Under Doors | On | A pull dips under a lower ceiling ahead. |
| Grip Takes Door | On | The grip takes hold of a door. |
| Use Takes Door | On | Use takes hold of a door. |
| Palm Takes Door | On | A palm turned out against a door takes hold. |
| Palm Flips Switches | On | A palm on a switch flips it. |

Living monsters are never pulled.

**Beam and Feel**

| Row | Default | What it does |
|---|---|---|
| Yield to Laser Sight | Off | Hide the grab beam on a hand RSQ Laser Sight is lighting. |
| Show When Idle | On | Draw the beam even when it finds nothing. |
| Dot | On | The dot where the beam lands. |
| Reach Cone | On | The faint cone. |
| Target Glow | On | The target glows in its own outline. |
| Voxel Flash | On | A voxel target flashes its colour instead. |
| Recolour Target | Off | Tint the target itself. |
| Approach Ping | On | A ping that speeds up as a pull closes. |
| Rumble | On | Rumble feedback (needs the engine's quake haptics above 0). |
| Held Back Rumble | On | Rumble when a carried thing is held back by a wall. |
| Catch Flash | On | A green bloom at the palm on a catch. |
| Palm Gate | On | Off: the hand reaches whatever its pose. |
| Button Fallback | Off | The grab binds drive the grab too. |

**Controls:** Grab Main Hand, Grab Off Hand (see Controls above).

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Hand Lead | 1.0 | Tics the beam is drawn ahead of the hand to hide lag. |
| Pose Jump Cutoff | 1.0 m | A hand jump this big in one tic is ignored. |
| Min Impact Speed | 3.0 m/s | Below this a thrown thing does not hurt. |
| Max Hold Speed | 40 | Fastest a carried thing moves. |
| Report Actions | Off | Log what the grab does. |
| Report Refusals | Off | Log why it refused. |
| Reset All | — | Puts every setting back to its default. |

Gesture page: Reach (512), Spread (12), Palm Roll (90), Roll Tolerance (30), Min Hand Pitch (-30), Flick Strength
(5), Lock Delay (0), Two-Hand Reach (0.20 m: how close to the barrel line the off hand counts as two-handing).

Pull page: Arc Speed (22), Arc Height (0.25), Arc Pull-In (1.6), Tumble (1.0), Lob Height (1.0), Pull Speed (12),
Steering (40), Pull Strength (10 kg), Flight Width (2), Give Up After (140 tics).

Catch and Carry page: Catch Distance (24), Catch Window (4 tics), Throw Strength (1.0), Throw Boost (2.5), Throw
Lets Go At (2.5 m/s), Stagger From (20 damage), Arm Weight (30 kg), Impact Damage (15 joules a point), Barrel
Blast: Thrown At (4 m/s), Throw Aim Assist (12°), Hit With What You Hold (On), Swing Hits From (3 m/s), Hit-Stop
(Off), Two-Hand Lift (2.0), Body Shield (On), Sounds (On), Hold Distance (0.30 m), Hold Stiffness (0.6), Break
Distance (1.5 m), Half Speed Mass (120 kg), Heavy Sag (1.0), Throw Gravity (0.27), Pull Smoothness (0.6), Pull
Spin (1.0), Throw Spin (1.0), Pull Trail (On), Landing Dust (On).

Beam and Glow page: Beam Width (1.0), Beam Brightness (0.8), Dot Size (1.0), Cone Brightness (0.45), Glow
Brightness (1.0), Pulse Period (24 tics).

Haptics and Doors page: Rumble Strength (1.0), Locked Rumble (0.15), Door Commit Point (0.40), Door Lift Gain
(2.5).

## Works with

RSQ Distance Grab runs alone. It finds the other mods by name, so load order among RSQ pk3s does not matter.

- **Brutal Doom / BD22 VR Reloaded:** grab BD's floor guns straight into either hand. BD's fists count as an
  empty hand. BD22 VR's two-hand aim stands the grab down.
- **RSQ Laser Sight:** both beams show at once by default; Yield to Laser Sight hides the grab's.
- **RSQ Tactical Rig:** a hand reaching into a holster, or holding the rig's cigarette or Zippo, belongs to the
  rig.
- **RSQ Melee:** a gloved hand, or one that just punched, does not reach. The off-hand Headlock takes a grip
  press when a monster is nearer than anything to grab, and a monster thrown from the Headlock flies with Distance
  Grab's throw.
- **RSQ Saber** and **RSQ ShieldSaw:** a lit saber or a ShieldSaw hand stands down.
- **RSQ Grapple** and **RSQ Whip:** the grab binds take hold of their ropes.
- **RSQ Score:** a kill with a swung object scores as Clubbed, and thrown objects feed its scoring.
- **RSQ Accessibility:** One-Handed mode adds Reach and Pull buttons. Gesture Ease loosens the palm test and the
  flick. Cue Size and Photosensitive Mode tame the glows and flashes. Rumble Strength scales the haptics.
- **RSQ Gun Bonsai VR:** does not change the grab. It is everyone's from the start.

## Credits and licence

Code: written for the Radiant Silvergun Quest series by presidentkoopa, for stock QuestZDoom 17.3: ZScript and
lumps only, no engine changes. New, ported in part from presidentkoopa's desktop RS_WorldHands.

- **From RS_WorldHands** (presidentkoopa's desktop hand system): the pull's flight path and its end-over-end
  tumble, the gravity, drag and flutter of everything that leaves a hand, a held thing tipping with the wrist and
  sagging by its weight, and the strain rumble. His designs and numbers, rewritten for stock QZD.
- **Generated for this pack** (original, procedural; nothing sampled or ripped): the beam and the reach cone
  (models/rsqdg/rsqbeam*, rsqcone*) and the cone's placeholder sprites (sprites/rsqdg/RSQC*, RSQE*, RSQB*), made
  by tools/gen_cone.py.
- **The aim dot's glow** (sprites/rsqdg/RSQTA0.png, the same image as graphics/rsqdglo.png): added with the
  first laser models; no outside source is recorded for it.
- **Ideas, no code or assets taken:** the dot from QuestZDoom's bundled laser sight (GPL-3); the cone's look from
  DXR's debug wire cone; the beam from the lightsaber blade's crossed-plane trick.
- **Sounds:** none of its own. The whoosh and thud are Doom's own DSSKESWG and DSPUNCH, pitched by speed and
  weight.
- **QuestZDoom** (Emawind84 and Team Beef): the engine, and the hand-pose script API the grab reads.

Free to share as part of the Radiant Silvergun Quest series.
