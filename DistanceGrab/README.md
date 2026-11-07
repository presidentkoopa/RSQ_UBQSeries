# RSQ Distance Grab

Turn your palm out at anything across the room, flick your wrist, and it flies into your hand.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New since the headset pass (tested on the rig, headset check pending): Kill Rewards bits are never grabbed; the throw measured against the frame your headset drew, so walking and stairs are no throw.

New on 11-06 (rig only, not headset-confirmed): throws that follow through, never drop at your feet while walking and
never go backwards; RSQ FnF flares can be grabbed; a gun caught in the off hand is equipped there every time.

New on 11-07 (rig only, not headset-confirmed): release to throw. A carried thing never lets go by itself; squeeze
the grip on a thing you caught and it stays in your hand until you let the grip go, then flies at your hand's speed.

New on 11-07 (rig only, not headset-confirmed): Barrel Lock-On. With a barrel in your other hand, or a barrel within
punching reach, turn a free palm at a monster: it glows green and is locked. A barrel you throw, or uppercut with RSQ
Melee, flies to it, follows it if it moves, and hits and goes off.

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
- **Guns go to the hand that grabbed them,** main or off. A gun caught in the off hand is equipped there at once,
  even one you already own (D40).

**Carry and throw**
- **Carry:** a barrel (or a corpse, if switched on) stays in your hand on a spring. Heavy things trail, sag and
  tip with your wrist. Walls stop it.
- **Two-hand lift:** lay your other empty palm on what you carry and it handles twice as light.
- **Release to throw:** a carried thing never lets go by itself. Squeeze the grip on what you caught and it is the
  grip's: swing as hard as you like, it stays. Let the grip go mid-swing and it flies at your hand's speed and
  direction; let go gently and it is set down. A barrel thrown hard explodes where it lands.
- **Impacts hurt:** thrown things deal damage from their speed and weight, stagger what they hit hard enough,
  and a light aim assist bends a throw onto a nearby monster.
- **Club with it:** swing what you carry into a monster to hit it.
- **Body shield:** a held barrel or corpse stops bullets and fireballs. A barrel goes off when it is hit.
- **Heavy slows you:** carrying 120 kg halves your speed.

**Barrel Lock-On** (on by default)
- **One lock per player.** Either free palm sets it (a gun hand turned sideways counts); either hand's barrel uses it.
- **The palm picks the monster over an item** while your other hand holds a barrel, or you stand within punching reach
  of a barrel (Doom's punch range, 64 map units from your body to the barrel's side). Otherwise the palm finds items
  as before. The locked monster wears the grab's green glow.
- **Sticky:** locking needs the 12-degree cone (Aim Width); keeping it needs twice that. Your palm on another monster
  takes the lock at once. With no palm on it the lock holds 3 seconds, then for half a second more (no glow) a
  throw or an uppercut still goes to that monster, or where it last was.
- **A thrown barrel always lands on the lock:** its arc is solved to reach it and it steers after the monster in
  flight. The swing sets how hard it hits (harder is flatter, faster, more impact); the softest is the lob that just
  reaches. An arc that would meet a lower ceiling on the way (a window's or a door's top) is thrown flatter. Letting go
  with the hand still sets it down, as always. Only barrels steer; anything else keeps the throw's aim assist.
- **RSQ Melee's uppercut barrel** goes to the lock when the lock is roughly ahead (within 60 degrees of the kick), and
  hits and goes off like a thrown barrel. Otherwise it flies where you punched. Barrel Lock-On on also turns Melee's
  uppercut barrel kick on.
- **For RSQ SlowMo's Locked Barrel cue:** Distance Grab answers by name which barrel's steering ended on its locked
  monster (the newest eight). Built, loads clean, NOT shown on the rig.

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
4. **Carry and throw a barrel:** pull a barrel and catch it, then squeeze the grip: now it is held by the grip and
   your palm can turn freely. Swing toward a monster and let the grip go to throw it. Let go with the hand still to
   set it down. (Before you squeeze, the palm holds it and rolling the palm back lets go, the same way.)
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
| Hold a caught thing | Squeeze the grip while carrying it | The grip owns it now, as a walk-up grab: the palm can roll freely. It never lets go by itself. |
| Throw | Let the grip go mid-swing | Flies at the forward stroke's speed and direction (never the wind-up's). Walking is no swing. Before the grip is squeezed, rolling the palm back mid-swing throws the same way. |
| Set down | Let go (grip, or palm before the grip) with the hand still | |
| Two-hand lift | Other palm on the carried object, that hand empty | |
| Walk-up grab | Grip with the palm within 0.30 m of a pickup or barrel | Release the grip to drop; release while moving to throw. |
| Lift a door | Hand on the door, then grip, Use or palm out, and lift | Ordinary manual doors, from the front. |
| Flip a switch | Palm out against the switch | |

**Key binds** (Options → Radiant Silvergun Options → RSQ Distance Grab, Controls: Main Hand Key, Off Hand Key; or
Customize Controls → RSQ Distance Grab). Desktop defaults G and H; no controller defaults. These binds only drive the
grab when Grab Keys is on (off by default; the key rows are greyed until then): press to lock or catch, release to
pull or let go.
RSQ Grapple and RSQ Whip also use them to take hold of a rope.

Left-handed play works: the engine's left-handed scheme swaps the hands, and the palm test reads both wrists the
same way.

## Menu

Options → Radiant Silvergun Options → RSQ Distance Grab. One page (the old What You Can Grab, Beam and Feel and
Controls pages are on it); every raw number, the grip key codes and the logs are on **Test and Debug**; **Reset All**
at the foot resets both. Distance Grab has no Gun Bonsai VR gating. A row is greyed while the switch it hangs from is
off (the door rows under Lift Doors, the rumbles under Haptics, the two key rows under Grab Keys).

| Row | Default | What it does |
|---|---|---|
| Distance Grab | On | The whole mechanic. |
| Reach | 512 | How far you can pull from, map units (about 15 m). |
| Aim Width | 12 | The cone's half-angle in degrees: how precisely you must point. |
| Not With Melee | On | A melee hand (weapon, gloves, a punch just thrown, a lit saber) does not reach. |
| Line of Sight | On | No grabbing through walls. |
| Palm Gate | On | The hand reaches only with the palm turned out. Off: whatever its pose. |
| **Pull** | | |
| Flight Path | Arc | Steer, Lob or Arc (WorldHands' path). |
| Pull Gravity | Off | Lets a Steer pull sag. |
| Duck Under Doors | On | A pull dips under a lower ceiling ahead. |
| Pull Trail | On | A faint trail behind a pulled thing. |
| Use Pickups on Catch | On | Off: everything caught is carried instead. |
| **Carry and Throw** | | |
| Throw Strength | 1.00 | Scales how hard a release throws. |
| Heavy Slows You | On | Carrying heavy things slows you. |
| Tip With Wrist | On | A held thing tips as you turn your wrist. |
| Hit With What You Hold | On | A held thing swung into a monster hits it. |
| Body Shield | On | A held corpse or barrel stops shots and fireballs. |
| Hit-Stop | Off | A monster hit by a thrown thing freezes for a beat: Off, Tap, Beat, Heavy. |
| Barrel Lock-On | On | A free palm locks a monster; barrels thrown, or uppercut with RSQ Melee, go to it (above). |
| Sounds | On | Whoosh on a throw, thud on a catch and a landing. |
| Landing Dust | On | A hard landing kicks up dust. |
| **What You Can Grab** | | |
| Barrels, Flares, Weapons, Powerups, Ammo, Health, Armor, Keys, +1 Bonuses | On | Each kind its own switch. Flares are RSQ FnF flares lying on the floor, dropped or thrown (once landed); a flare you throw into a monster sets it on fire (FnF, with Brutal Doom). |
| Corpses | Off | |
| Walk-Up Grab | On | Grip with the palm on a thing takes it. |
| **Doors and Switches** | | |
| Lift Doors | On | Doors can be lifted by hand. |
| Grip Takes Door | On | The grip takes hold of a door. |
| Use Takes Door | On | Use takes hold of a door. |
| Palm Takes Door | On | A palm turned out against a door takes hold. |
| Palm Flips Switches | On | A palm on a switch flips it. |
| **Beam** | | |
| Beam | On | The beam from your palm. |
| Dot | On | The dot where the beam lands. |
| Reach Cone | On | The faint cone. |
| Show When Idle | On | Draw the beam even when it finds nothing. |
| Yield to Laser Sight | Off | Hide the grab beam on a hand RSQ Laser Sight is lighting. |
| Target Glow | On | The target glows in its own outline. |
| Voxel Flash | On | A voxel target flashes its colour instead. |
| Recolour Target | Off | Tint the target itself. |
| Catch Flash | On | A green bloom at the palm on a catch. |
| **Feel** | | |
| Haptics | On | Controller feedback. |
| Rumble | On | Rumble feedback (needs the engine's quake haptics above 0). |
| Approach Ping | On | A ping that speeds up as a pull closes. |
| Held Back Rumble | On | Rumble when a carried thing is held back by a wall. |
| **Controls** | | |
| Grab Keys | Off | The grab keys below drive the grab too (the palm gesture always works). |
| Main Hand Key / Off Hand Key | G / H (desktop) | The grab keys; greyed until Grab Keys is on. |
| Test and Debug | | The page below. |
| Reset All | | Every setting on both pages back to its default. |

Living monsters are never pulled.

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| **Gesture** | | |
| Palm Roll / Roll Tolerance | 90 / 30 | Palm-out roll and how far off still counts, degrees. |
| Min Hand Pitch | -30 | The hand must be above this pitch to reach. |
| Flick Strength | 5 | Wrist pitch per tic that counts as the pull flick. |
| Lock Delay (tics) | 0 | Tics the cone must hold the same target before it locks. |
| Two-Hand Reach (m) | 0.20 | How close to the barrel line the off hand counts as two-handing. |
| Hand Lead (tics) | 1.0 | The beam is drawn ahead of the hand to hide lag. |
| Pose Jump Cutoff (m) | 1.0 | A hand jump this big in one tic is ignored. |
| Walk-Up Reach (m) | 0.30 | How close the palm must be for a walk-up grab. |
| Main / Off Grip Key Codes | 446 / 443 436 | The raw grip key codes the walk-up grab reads. |
| **Pull** | | |
| Arc Speed | 22 | Metres a second; the flight time is distance over this. |
| Arc Height | 0.25 | Arc height as a share of the distance. |
| Arc Pull-In | 1.6 | Above 1 a pull starts slow. |
| Shortest / Longest Flight (tics) | 6 / 40 | Limits on an Arc pull's time. |
| Pull Smoothness | 0.6 | How softly a pull settles into the hand. |
| Pull Spin (turns) | 1.0 | Turns about its own up across a pull. |
| Tumble | 1.0 | End-over-end turns across a pull. |
| Lob Height (m) | 1.0 | How high a Lob peaks. |
| Pull Speed / Steering / Pull Strength | 12 / 40 / 10 kg | The Steer pull. |
| Flight Width | 2 | A pulled thing's flying radius. |
| Give Up After (tics) | 140 | A pull that cannot arrive is dropped after at least this. |
| **Catch and Carry** | | |
| Catch Distance / Catch Window | 24 / 4 tics | |
| Hold Distance (m) / Hold Stiffness | 0.30 / 0.6 | The carry's spring. |
| Max Hold Speed | 40 | Fastest a carried thing moves. |
| Break Distance (m) | 1.5 | Held back this far for half a second and you let go. |
| Half Speed Mass (kg) | 120 | Carrying this much halves your speed. |
| Heavy Sag | 1.0 | Heavy things hang lower. |
| Two-Hand Lift | 2.0 | The other palm on a held thing makes it this many times lighter. |
| **Throw** | | |
| Throw Boost | 2.5 | A throw's speed multiplier. |
| Throw Aim Assist (deg) | 12 | A throw within this of a monster bends to hit it. |
| Throw Spin | 1.0 | How fast a thrown thing turns. |
| Throw Gravity | 0.27 | Share of Doom's gravity a thrown thing falls at. |
| Flutter | 0.35 | Sideways wobble of a light, fluttering thing in the air. |
| Air Time Limit (tics) | 1400 | The air lets go of something that never lands after this. |
| Arm Weight (kg) | 30 | The arm's mass in a throw. |
| Impact Damage | 15 | Joules of a thrown thing per point of damage. |
| Min Impact Speed (m/s) | 3.0 | Below this a thrown thing does not hurt. |
| Stagger From (damage) | 20 | A hit this hard knocks a monster into pain. |
| Barrel Blast (m/s) | 4 | A barrel thrown this fast goes off where it lands (0 never). |
| Swing Hits From (m/s) | 3.0 | A held thing slower than this is not a hit. |
| **Beam and Feel** | | |
| Beam Width / Beam Brightness | 1.0 / 0.8 | |
| Dot Size | 1.0 | |
| Cone Brightness | 0.45 | |
| Glow Brightness / Pulse Period | 1.0 / 24 tics | |
| Rumble Strength / Locked Rumble | 1.0 / 0.15 | |
| Door Commit Point / Door Lift Gain | 0.40 / 2.5 | Let go past this much open and the door finishes; door travel per hand travel. |
| Report Actions / Report Refusals | Off | Log what the grab does / why it refused (the Barrel Lock-On's too). |

## Works with

RSQ Distance Grab runs alone. It finds the other mods by name, so load order among RSQ pk3s does not matter.

- **Brutal Doom / BD22 VR Reloaded:** grab BD's floor guns straight into either hand. BD's fists count as an
  empty hand. BD22 VR's two-hand aim stands the grab down.
- **RSQ Laser Sight:** both beams show at once by default; Yield to Laser Sight hides the grab's.
- **RSQ Tactical Rig:** a hand reaching into a holster, or holding the rig's cigarette or Zippo, belongs to the
  rig.
- **RSQ Melee:** a gloved hand, or one that just punched, does not reach. The off-hand Headlock takes a grip
  press when a monster is nearer than anything to grab, and a monster thrown from the Headlock flies with Distance
  Grab's throw. Melee's uppercut barrel goes to the Barrel Lock-On's lock (asked by name).
- **RSQ SlowMo:** its Locked Barrel cue asks by name whether a barrel met its lock (built, loads clean, NOT shown on
  the rig).
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
