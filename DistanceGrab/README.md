# RSQ Distance Grab (RSQ Distance Grab)

**The one thing:** gravity gloves: palm out at a thing across the room and it flies into your hand; carry it,
swing it, throw it, hide behind it.

Point at a thing across the room with your palm, pull it to your hand, carry it, throw it. Up close, the grip
takes things, lifts doors and flips switches. Part of the Radiant Silvergun Quest series, for stock QuestZDoom
17.3 in VR (script only, no engine changes). It needs no other pk3 and works on plain Doom 2 with or without
Brutal Doom. Most of the feel (the pull's arc and tumble, how thrown things fall, the carry's tip and sag) is
ported from the owner's desktop RS_WorldHands.

Pk3: `pk3/RSQ_DistanceGrab.pk3`. The Headlock (the off hand's grip on a living monster, Human Shield, the
headlock throw) belongs to RSQ Melee; this mod keeps everything about objects.

## Features

**The reach.**
- Turn your palm out with the hand raised and a beam, a dot and a faint cone show where you reach. Keep it on
  a thing and it glows: locked.
- Reach, Aim and Gesture presets: how far (Short / Standard / Long / Room), how precisely you must point
  (Precise / Standard / Generous), how strict the palm and flick are (Relaxed / Standard / Strict).
- You cannot grab through a wall (Line of Sight).
- A hand that is fighting stands down: one holding a saber, chainsaw or another mod's hand system, one wearing
  RSQ Melee's boxing gloves, or one that moved at punch speed in the last 0.75 s (Not With Melee). An idle bare
  hand or fist still reaches.
- Two-handing a gun stands it down: QuestZDoom's two-hand grip, BD22 VR's own two-hand hold, or the off hand on
  the gun (in front of the gun hand and within 20 cm of the barrel line). It stays off for half a second after
  the hands part, so canting the gun never fires it. An off hand merely raised beside the gun still reaches.

**The pull.**
- Tip your wrist up sharply and the thing flies to your palm, arcing and tumbling (Flight Path WorldHands), or
  steered straight (Steer), or lobbed (Lob). Pull Speed: Gentle / Standard / Snappy.
- A pull dips under a low doorway (Duck Under Doors). Pull Gravity lets it sag.
- What you can pull: barrels, weapons, powerups, ammo, health, armour, keys, +1 bonuses, each its own switch;
  corpses are off by default. A living monster is never pulled from range.
- A caught pickup is used at once (Use Pickups on Catch); off, you carry it instead. A barrel or corpse is
  carried.
- A gun you already own can be pulled: the catch gives its ammo and the floor copy is used up. Ammo full: it
  stays in your hand as a thing to carry or drop, and a line on screen says so.
- A gun goes to the hand that grabbed it: off hand into the off hand, where it stays until you move it
  yourself; main hand into the main hand. When it cannot (the same gun is already in the other hand, or it is a
  melee weapon), a line on screen says why.

**The carry.**
- A held thing follows your palm on a spring; walls refuse it. It tips with your wrist (Tip With Wrist) and heavy
  things hang lower (Heavy Sag). Carrying something heavy slows your walk (Heavy Slows You).
- Put the other, empty palm on a held thing and it gets lighter (Two-Hand Lift).
- A held corpse or barrel stops shots and fireballs (Body Shield). A barrel goes off.
- Swing a held thing into a monster and it is hurt and staggered (Hit With What You Hold).

**The throw.**
- Swing the arm forward and it lets go by itself as the swing slows. A wind-up never throws. Turn the palm back
  with the arm still to drop it.
- Throw Strength: Soft / Standard / Strong. A throw within 12 degrees of a monster bends onto it (Throw Aim
  Assist). Damage comes from the thing's weight and speed: a keycard stings, a shotgun hurts, a barrel at a run
  is a weapon.
- A barrel thrown at 4 m/s or more goes off where it lands (Barrel Blast).
- Hit-Stop, off by default: a monster hit by a thrown thing freezes 3, 4 or 6 tics.
- Stock Doom sounds by weight: a whoosh on the throw (higher the faster), a thud on a catch or landing (deeper
  the heavier). A faint trail behind a pull; dust on a hard landing.

**The grip up close.**
- Walk-Up Grab: put your palm on a thing within about 30 cm and squeeze the grip. It is taken (a pickup used, a
  barrel or corpse carried). Let go of the grip to let go; let go while moving to throw.
- Lift Doors: hand flat on a manual door, take hold (grip, Use, or a palm turned out against it), raise the
  hand. The door's ceiling follows your hand at your hand's speed and its own sound plays as fast as you lift.
  Let go past the commit point (40 % open) and it finishes opening by itself; before that it drops shut.
- Palm Flips Switches: lay your palm, turned out, on a switch.

**Beam and feel.**
- The beam, the dot, the reach cone, the glow on the target, a flash on a voxel target; Recolour Target as an
  option. The beam shows even when it has found nothing (Show When Idle).
- Haptics: a hum while locked, a rumble that builds through the pull, a hit on the catch, a shudder when a
  carried thing is held back (Rumble); or a plain buzz in rhythm (Rumble off); an Approach Ping that speeds up
  as the thing closes; a green bloom at the palm on a catch (Catch Flash).
- Yield to Laser Sight, off by default: hides the grab beam on a hand RSQ Laser Sight is already lighting.
- Button Fallback, off by default: the bound grab buttons work as well as the gesture.

## How to play

There is nothing to bind. The distance grab is a palm gesture, and the grip up close reads the controller grips
directly.

1. **Aim.** Raise a hand and turn the palm out (a quarter turn of the wrist). A hand hanging at your side does
   nothing. A beam, a dot and a faint cone show where you reach.
2. **Lock.** Keep the palm out on a thing. It glows.
3. **Pull.** Tip your wrist up sharply as you turn the palm back. The thing flies to your palm.
4. **Change your mind.** Turn the palm back slowly. The lock lets go.
5. **Catch.** It lands in your palm. A pickup is used; a barrel or corpse is carried.
6. **Carry.** Walk with it. Tip your wrist and it tips. Put your other, empty palm on it and it gets lighter.
   Swing it into a monster to hit with it.
7. **Throw.** Swing the arm forward. It lets go as the swing slows. Aim a little to the side of a monster and
   the throw bends onto it. A barrel thrown hard goes off where it lands.
8. **Drop.** Turn the palm back with the arm still.

**Walk-up grab.** Put your palm on a thing within about 30 cm and squeeze the grip. Let go of the grip to let
go. While something is in reach, the grip press goes to the grab and nothing else bound to that grip sees it.

**Lift a door.** Hand flat on a manual door, squeeze the grip (or press Use, or turn the palm out against it),
and raise the hand. Keep lifting until it is well past a third open, then let go: it opens fully. Let go earlier
and it drops shut.

**Flip a switch.** Lay your palm, turned out, on the switch. It flips once.

**Guns.** Pull or walk-up grab a gun with the off hand and it goes into the off hand and stays there; with the
main hand, into the main hand. Grab a copy of the gun the other hand holds and its ammo goes up, with a line on
screen saying it is already in that hand.

**Optional buttons.** Turn on Button Fallback (Beam and Feel), then bind in Customize Controls, section **RSQ
Distance Grab**: **Grab / pull (main hand)** and **Grab / pull (off hand)**. The same two are on the mod's
Controls page as Grab Main Hand / Grab Off Hand. On a keyboard they default to G and H; no controller button is
bound by default.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Distance Grab**.

| Menu row | Default | What it does |
|---|---|---|
| Distance Grab | On | The whole mod. |
| Reach | Standard (512 units, about 15 m) | Short / Standard / Long / Room: how far the grab reaches. |
| Aim | Standard (12 deg) | Precise / Standard / Generous: how precisely you must point. |
| Gesture | Standard | Relaxed / Standard / Strict: how strict the palm and flick are. |
| Not With Melee | On | A fighting hand does not reach (saber, chainsaw, another mod's hand system, RSQ Melee's gloves, punch speed in the last 0.75 s). |
| Flight Path | WorldHands | Steer / Lob / WorldHands: how a pulled thing flies. |
| Pull Speed | see Known limits | Gentle / Standard / Snappy. |
| Throw Strength | Standard | Soft / Standard / Strong. |
| Heavy Slows You | On | Carrying something heavy slows your walk. |
| Beam | On | The beam from your palm. |
| Haptics | On | Rumble and buzzes for lock, pull, catch and strain. |
| Lift Doors | On | Take hold of a manual door and lift it by hand. |
| What You Can Grab | page | See below. |
| Beam and Feel | page | See below. |
| Controls | page | Grab Main Hand, Grab Off Hand (the optional buttons). |
| Tuning and Debug | page | Every number, and Reset All. |

**What You Can Grab**

| Menu row | Default | What it does |
|---|---|---|
| Barrels | On | Barrels may be pulled. |
| Weapons | On | Guns may be pulled. |
| Powerups | On | Spheres, berserk, suit, map. |
| Corpses | Off | Pull and carry corpses. |
| Ammo | On | Ammunition. |
| Health | On | Medikits, stimpacks. |
| Armor | On | Armour. |
| Keys | On | Keys. |
| +1 Bonuses | On | The +1 health and armour bonuses. |
| Walk-Up Grab | On | The grip with your palm on a thing takes it. |
| Walk-Up Reach (m) | 0.30 | How close the palm must be. |
| Line of Sight | On | You cannot grab through a wall. |
| Use Pickups on Catch | On | A caught pickup is used at once. Off: you carry it. |
| Tip With Wrist | On | A held thing tips with your wrist. |
| Pull Gravity | Off | A pull sags under gravity. |
| Duck Under Doors | On | A pull dips under a low doorway. |
| Grip Takes Door | On | The grip takes hold of a door. |
| Use Takes Door | On | Use takes hold of a door. |
| Palm Takes Door | On | A palm turned out against a door takes hold. |
| Palm Flips Switches | On | A palm laid on a switch flips it. |

**Beam and Feel**

| Menu row | Default | What it does |
|---|---|---|
| Yield to Laser Sight | Off | Hides the grab beam on a hand RSQ Laser Sight is lighting. Off: both beams show. |
| Show When Idle | On | The beam shows even when it has found nothing. |
| Dot | On | The dot where the beam lands. |
| Reach Cone | On | The faint cone: the volume the grab tests. |
| Target Glow | On | The glow on the target. |
| Voxel Flash | On | A voxel-drawn target flashes its colour instead. |
| Recolour Target | Off | Recolours the target itself. |
| Approach Ping | On | The speeding-up ping during a pull. |
| Rumble | On | Haptics by amplitude (needs QuestZDoom's quake haptics above 0). Off: the plain fixed buzz. |
| Held Back Rumble | On | A shudder when a carried thing is held back. |
| Catch Flash | On | A green bloom at the palm on a catch. |
| Palm Gate | On | The reach only arms with the palm out and the hand raised. |
| Button Fallback | Off | The bound grab buttons work as well as the gesture. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Gesture | page | Reach 512, Spread 12, Palm Roll 90, Roll Tolerance 30, Min Hand Pitch -30, Flick Strength 5.0, Lock Delay 0, Two-Hand Reach 0.20 (m: an off hand this close to the barrel line is on the gun; 0 = only the engine's two-hand grip and BD22 VR's own count). |
| Pull | page | Arc Speed 22, Arc Height 0.25, Arc Pull-In 1.6, Tumble 1.0, Lob Height 1.00, Pull Speed 12, Steering 40, Pull Strength 10 (kg), Flight Width 2, Give Up After 140 (tics). |
| Catch and Carry | page | Catch Distance 24, Catch Window 4, Throw Strength 1.00, Throw Boost 2.50, Throw Lets Go At (m/s, 0 = palm only) 2.50, Stagger From (damage) 20, Arm Weight 30, Impact Damage 15, Barrel Blast: Thrown At (m/s) 4.0, Throw Aim Assist (deg) 12, Hit With What You Hold On, Swing Hits From (m/s) 3.0, Hit-Stop (thrown hits) Off, Two-Hand Lift 2.00, Body Shield (held corpse/barrel) On, Sounds (whoosh, thud) On, Hold Distance 0.30, Hold Stiffness 0.60, Break Distance 1.50, Half Speed Mass 120, Heavy Sag 1.00, Throw Gravity 0.27, Pull Smoothness 0.60, Pull Spin (turns) 1.00, Throw Spin 1.00, Pull Trail On, Landing Dust On. |
| Beam and Glow | page | Beam Width 1.00, Beam Brightness 0.80, Dot Size 1.00, Cone Brightness 0.45, Glow Brightness 1.00, Pulse Period 24. |
| Haptics and Doors | page | Rumble Strength 1.0, Locked Rumble 0.15, Door Commit Point 0.40, Door Lift Gain 2.50. |
| Hand Lead | 1.0 | Tics the hand end of the beam is drawn ahead of the hand. |
| Pose Jump Cutoff | 1.00 | Metres of hand travel in one tic that means the pose lied (a menu, tracking loss). |
| Min Impact Speed | 3.0 | m/s below which a landing is not an impact. |
| Max Hold Speed | 40 | The fastest a held thing moves, map units a tic. |
| Report Actions | Off | Logs what the grab did. |
| Report Refusals | Off | Logs every refusal with its reason: why a palm-out hand may not reach, and for "nothing in the cone" the nearest thing and the test it failed. |
| Reset All | row | Resets every Distance Grab setting. Asks first. |

## Works with

- **RSQ Laser Sight:** both beams show (the laser from the gun, the grab beam from the hand). With Yield to
  Laser Sight on, the grab beam hides on a hand the laser lights.
- **Brutal Doom / BD22 VR Reloaded:** its floor guns pull, give their ammo when owned, and go to the hand that
  grabbed them. BD22 VR's two-hand tokens count as two-handing. Its own axe pull is left to it (melee weapons
  are not moved by this mod).
- **RSQ Tactical Rig:** a hand the rig is using (reaching into a holster or its radial, holding the cigarette or
  the Zippo) does not reach; the walk-up grip yields to a holster. The rig asks this mod whether a hand holds a
  door.
- **RSQ Saber / RSQ ShieldSaw:** a hand holding a lit saber or the shield does not reach (Not With Melee).
- **RSQ Melee:** a hand in its boxing gloves does not reach; its Punch Min Speed is the punch speed above. Its
  Headlock takes the off grip press only when a monster is nearer the palm than anything this mod would take.
  A monster thrown out of the Headlock flies through this mod's throw (its strength, weight, boost, aim assist
  and impact).
- **RSQ Score:** a kill by a held thing swung into a monster is named to Score as a club.
- **RSQ Grapple:** can use this mod's grab buttons (its own setting).
- **RSQ Accessibility:** colour-blind palette, Photosensitive Mode, Gesture Ease, Off-Hand Modifier and the Grab
  Pull / Grab Reach buttons, Cue Size, Sound Cues, Rumble Strength. Steady Hands smooths the aim cone that
  picks what to lock (and the idle beam's far end); throws, catches, the carry and the palm gate stay on the raw
  hand.

Gun Bonsai VR has no nodes for the grab: with the patch loaded it is exactly its rows, nothing waits to be
learned.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s, in any order among them.

## Known limits

- The grip is eaten: when something is in reach, the grip press goes to the walk-up grab, and anything else
  bound to that grip does not see it.
- The walk-up grab still fires on a hand holding the Tactical Rig's lit cigarette or Zippo.
- Pull Speed's presets do not match the defaults: Standard sets Arc Speed to 15 while the default is 22, so the
  row does not read Standard until you pick one.
- A lifted door may step at 35 Hz (a ceiling moved from script has no smoothing).
- The Rumble route is felt only when QuestZDoom's quake haptics level is above 0.
- One gun cannot be in both hands: QuestZDoom keeps one weapon per class, so grabbing a copy of the gun the
  other hand holds gives its ammo and says so (BD22 VR's Dual key gives its own off-hand copies).
- A gun you own with full ammo is refused by the game's own pickup: it is carried in the hand instead, with a
  line on screen saying so.
- A gun caught by the off hand while the main hand is still switching, or while QuestZDoom's two-hand grip is
  latched, waits to be raised (the grip: until it is let go).
- With RSQ Saber loaded its second saber starts in the off hand, lit. A hand holding a lit saber never
  distance-grabs; a line on screen says so when you hold that palm out. Switch the blade off, holster it, or
  turn Not With Melee off.
- Brutal Doom's own pickups decide what a floor gun gives: the Plasma Gun and Rifle give a dual-wield token when
  you already own one, and any gun whose Purist version you hold gives ammo only. Then there is no gun to move
  to the grabbing hand.

## For other mods

Everything is asked by name; nothing links.

- **RSQDG_ThrowService** (play): `GetInt("hold.full", "", hand, 0, pawn)` 1 while that hand of the console
  player holds something; `GetInt("near.dist", "", hand, 0, pawn)` map units to the nearest walk-up thing, -1
  none; `GetInt("headlock.throw", "", pn, weight %, monster)` throws a monster the way a held thing is thrown;
  `GetInt("headlock.caught", "", pn, 0, monster)` the catch's thud and tick in the off hand; `GetInt("throw.by"
  / "throw.age" / "throw.cms" / "throw.blast" / "throw.juggle", "", 0, 0, actor)` about a recent throw (-1 when
  it is not one; remembered ten seconds).
- **RSQDG_GrabRuleService** (play): `GetInt("grab.hello")` 1; `GetInt("grab.rule", className, 0, 0, null,
  category)` / `GetInt("grab.deny", className)` register what may or may not be pulled; `GetInt("grab.weight",
  ...)`; `GetInt("grab.forget", className)`.
- **RSQDG_MassService** (play): `GetDouble("mass.kg" / "mass.drag", "", 0, 0, actor)`; `GetInt("mass.hello")`
  1; `GetInt("mass.stated" / "mass.flags" / "mass.grams", "", 0, 0, actor)`.
- **RSQDG_DoorService**: `GetInt("door.holding", "", hand)` 1 while that hand of the console player holds a
  door, else -1.
- It asks, by name: RSQA_Service (Accessibility), RSQTR_RigService (`rig.busy`, `rig.region`),
  UBQS_SaberService (`saber.lit`), RSQLS_SightService, RSQML_Service (`headlock.claim`), RS_ScoreService
  (`touch grab.swing`), RS_WeaponWeightService (a gun's weight), and any **GrabEventService** with
  `GetInt("grab.event", what, hand, fromAir, actor, 'RSQ_DistanceGrab')` for `pull.lock`, `pull.unlock`,
  `pull.start`, `pull.refused`, `pull.caught`, `hold.wear`, `hold.hit`, `hold.block`, `hold.drop`,
  `throw.hit`, `throw.impact`.
- Network events it sends: `rsqdg_press <hand>` / `rsqdg_release <hand>` (the optional buttons), `rsqdg_ngrip`,
  `rsqdg_doorgrab`, `rsqdg_doorlift`, `rsqdg_doorrel`, `rsqdg_switch`.

## Credits

`CREDITS.txt`, unchanged:

```
RSQ_DistanceGrab -- credits
===========================

Point at a thing across the room, pull it to your hand, carry it, throw it; lift doors by hand.
Part of the Radiant Silvergun Quest series. For stock QuestZDoom 17.3: ZScript and lumps only, no
engine changes. The code is new, ported in part from the project owner's desktop RS_WorldHands and
written for this pack.

WHAT THIS PK3 SHIPS, AND WHOSE IT IS
  No sounds of its own. Like RS_WorldHands, the grab is heard only through the world: the
      things you pull and throw, what they hit, and a door's own sound as you lift it.
  From RS_WorldHands (presidentkoopa, the project owner; his desktop hand system)
      The pull's flight path and its end-over-end tumble, the gravity, drag and flutter of
      everything that leaves a hand, a held thing tipping with the wrist and sagging by its
      weight, and the strain rumble: his designs and numbers, re-written here for stock QZD.
  Generated for this pack (original, procedural; nothing sampled or ripped)
      The beam and the reach cone (models/rsqdg/rsqbeam*, rsqcone*) and the cone's placeholder
      sprites (sprites/rsqdg/RSQC*, RSQE*, RSQB*): tools/gen_cone.py.
  The aim dot's glow (sprites/rsqdg/RSQTA0.png, the same image as graphics/rsqdglo.png)
      Added with the first laser models; no outside source is recorded for it.
  Ideas, no code or assets taken
      The dot: QuestZDoom's bundled laser sight (GPL-3). The cone's look: DXR's debug wire cone
      (hw_weapon.cpp). The beam: the lightsaber blade's crossed-plane trick.
  QuestZDoom (Emawind and Team Beef)
      The engine, and the hand-pose script API the grab reads.

SHARING
  Free to share as part of the Radiant Silvergun Quest series.
```

Sounds (SNDINFO.txt): Doom's own `dsskeswg` (whoosh) and `dspunch` (thud), pitched by speed and weight.
