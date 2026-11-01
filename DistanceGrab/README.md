# RSQ Distance Grab

Point at a thing across the room with your palm, pull it to your hand, carry it, throw it. Up close, the
grip takes things, holds a monster in a headlock, swaps the guns in your two hands, lifts doors and
flips switches. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3 (script only, no
engine changes). Most of the feel (the pull's arc and tumble, how thrown things fall, the carry's tip
and sag) is ported from the owner's desktop RS_WorldHands.

## Load order

```
doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3
          -> BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> RSQ_DistanceGrab.pk3   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** works. Every Brutal Doom class is looked up by name and skipped
  when it is missing (policy.zs, near.zs). The body shield was rig-tested on plain Doom (DECISIONS D36).
  Without Brutal Doom VR, an empty hand after a hand swap is the fist.
- **Other RSQ pk3s needed:** none. It works alone.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Distance Grab.
- **Buttons to bind:** none. The distance grab is a palm gesture, and the up-close grip reads the
  controller grips directly.
- **Optional buttons** (only used if you turn on *Button Fallback*, off by default): Customize
  Controls -> section "RSQ Distance Grab" -> "Grab / pull (main hand)" and "Grab / pull (off hand)".
  The same two are on the mod's *Controls* page as "Grab Main Hand" / "Grab Off Hand".
- The grip key numbers (`rsqdg_keys_main` 446, `rsqdg_keys_off` 443 436) are not on the menu. The
  Tactical Rig notes that 446 is the main grip only with the engine's secondary button mappings off;
  if the main grip does nothing up close, that is the first suspect.

## What to do in VR

- **Aim:** turn your palm out (a quarter turn of the wrist) with the hand raised, not hanging at your
  side. A beam, a dot and a faint cone show where you reach.
- **Lock:** keep the palm out on a thing. It glows.
- **Pull:** tip your wrist up sharply as you turn the palm back. The thing flies to your palm.
- **Change your mind:** turn the palm back slowly. The lock lets go.
- **Catch:** it lands in your palm. A pickup is used on the catch; a barrel (or corpse) is carried.
- **Throw:** swing the arm forward. It lets go by itself as the swing slows. A wind-up never throws.
- **Drop:** turn the palm back with the arm still.
- **Two hands:** put the other, empty palm on a held thing. It gets lighter.
- **Hit with it:** swing a held barrel into a monster.
- **Walk-up grab:** put your palm on a thing within about 30 cm and squeeze the grip. Let go of the grip
  to let go.
- **Headlock:** off hand, grip on a living monster within reach. It is held in front of you for 3 s.
  Swing the off hand hard to throw it.
- **Swap guns between hands:** controllers together, both palms up, squeeze a grip.
- **Lift a door:** hand flat on a manual door, grip (or Use, or palm out against it), raise the hand.
- **Flip a switch:** lay your palm, turned out, on the switch.

## Features

Rows are on the front page unless a page is named. "On" = on by default (CVARINFO); "Option" = off by
default.

| Menu row | Default | What it does |
|---|---|---|
| Distance Grab | On | The whole mod. |
| Reach | Standard (512 units, about 15 m) | How far the grab reaches. Short / Standard / Long / Room. |
| Aim | Standard (12 deg) | How precisely you must point. Precise / Standard / Generous. |
| Gesture | Standard | How strict the palm and flick are. Relaxed / Standard / Strict. |
| Not With Melee | On | A hand holding a saber, chainsaw, fist or another mod's hand system does not reach. |
| Flight Path | WorldHands | How a pulled thing flies: Steer, Lob or WorldHands (the arc and tumble). |
| Pull Speed | Standard | Gentle / Standard / Snappy. |
| Throw Strength | Standard | Soft / Standard / Strong. |
| Heavy Slows You | On | Carrying something heavy slows your walk. |
| Beam | On | The beam from your palm. |
| Haptics | On | Rumble and buzzes for lock, pull, catch and strain. |
| Lift Doors | On | Take hold of a manual door and lift it by hand. |
| What You Can Grab: Barrels, Weapons, Powerups, Ammo, Health, Armor, Keys, +1 Bonuses | On | Which kinds of thing the distance grab may pull. |
| What You Can Grab: Corpses | Option | Pull and carry corpses (off since 10-31, owner's call). |
| What You Can Grab: Walk-Up Grab | On | The grip with your palm on a thing takes it. |
| What You Can Grab: Swap Hands (palms up, grip) | On | Swaps the guns in your two hands. |
| What You Can Grab: Off-Hand Headlock | On | The off grip holds a living monster (up to demon weight) for 3 s. |
| What You Can Grab: Headlock: Human Shield (hold until let go) | Option | The headlock lasts as long as you hold the grip, monster facing away. |
| What You Can Grab: Headlock: Throw At (m/s, 0 = never) | 3.0 | Swing the off hand past this to throw the held monster. |
| What You Can Grab: Headlock Throw Weight % | 30 | A thrown monster counts as this share of its weight (lower = faster toss). |
| What You Can Grab: Line of Sight | On | You cannot grab through a wall. |
| What You Can Grab: Use Pickups on Catch | On | A caught pickup is used at once. Off: you carry it instead. |
| What You Can Grab: Tip With Wrist | On | A held thing tips with your wrist. |
| What You Can Grab: Pull Gravity | Option | A pull sags under gravity. |
| What You Can Grab: Duck Under Doors | On | A pull dips under a low doorway. |
| What You Can Grab: Grip / Use / Palm Takes Door | On | The three ways to take hold of a door. |
| What You Can Grab: Palm Flips Switches | On | A palm laid on a switch flips it. |
| Beam and Feel: Yield to Laser Sight | On | Hides the grab beam on a hand RSQ Laser Sight is already lighting. |
| Beam and Feel: Show When Idle | On | The beam shows even when it has found nothing. |
| Beam and Feel: Dot / Reach Cone / Target Glow / Voxel Flash | On | The dot, the cone, the glow on the target, the flash on a voxel target. |
| Beam and Feel: Recolour Target | Option | Recolours the target itself. |
| Beam and Feel: Approach Ping / Rumble / Held Back Rumble / Catch Flash | On | Haptic and visual feedback. Rumble needs the engine's quake haptics above 0; turn Rumble off to get the plain buzz instead. |
| Beam and Feel: Palm Gate | On | The reach only arms with the palm out and the hand raised. |
| Beam and Feel: Button Fallback | Option | Lets the bound grab buttons work as well as the gesture. |
| Catch and Carry (Tuning and Debug): Throw Aim Assist (deg) | 12 | A throw within 12 deg of a monster bends onto it. 0 = off. |
| Catch and Carry: Barrel Blast: Thrown At (m/s) | 4 | A barrel thrown at least this hard goes off where it lands. |
| Catch and Carry: Hit With What You Hold | On | A held thing swung into a monster hurts it. |
| Catch and Carry: Hit-Stop (thrown hits) | Option (Off) | A monster hit by a thrown thing freezes 3, 4 or 6 tics. |
| Catch and Carry: Two-Hand Lift | 2.0 | Two palms on a thing make it handle this many times lighter. |
| Catch and Carry: Body Shield (held corpse/barrel) | On | A held corpse or barrel stops shots and fireballs. A barrel goes off. |
| Catch and Carry: Sounds (whoosh, thud) | On | Stock Doom sounds: revenant swing on a throw, punch on a catch or landing. |
| Catch and Carry: Pull Trail / Landing Dust | On | A faint trail behind a pull, dust on a hard landing. |
| Tuning and Debug: Report Actions / Report Refusals | Option | Logging for testing. |
| Tuning and Debug: Reset All | - | Resets every Distance Grab setting. |

Every other row under *Tuning and Debug* is a number for the features above.

## Test it

Items marked **(not yet headset-confirmed)** were built on 2026-10-31 or later and only ran on the
simulated rig. Older items were also never recorded as run on the headset after the 10-27 WorldHands
port.

1. Load the pack. Options -> Radiant Silvergun Options shows *RSQ Distance Grab*. No script error.
2. Hold your hand at your side, palm in. No beam, nothing reaches.
3. Raise the hand and turn the palm out at a clip or stimpack. Beam, dot and cone show; the item glows.
4. Tip the wrist up sharply. The item arcs and tumbles into your palm and is used. You feel a rumble
   build and a hit on the catch.
5. Lock a barrel, then turn the palm back slowly. The glow stops; nothing moves.
6. Pull a barrel. It is carried at your palm and your walk slows. Tip your wrist: it tips with it.
7. Wind up behind you: it must not let go. Then swing forward hard: it flies and, if thrown at 4 m/s or
   more, goes off where it lands. You hear a whoosh. **(not yet headset-confirmed; the sounds were never
   heard)**
8. Throw a barrel a little to the side of a monster (within 12 deg). It bends onto the monster.
   **(not yet headset-confirmed)**
9. Hold a barrel, put the other empty palm on it. It moves more easily and sits between your hands.
   **(not yet headset-confirmed)**
10. Hold a barrel in front of an imp's fireball. The barrel takes it and goes off.
    **(not yet headset-confirmed)**
11. Swing a held barrel steadily through a monster. It is hurt and staggered, with a thud.
    **(not yet headset-confirmed)**
12. Walk up to an item, palm on it, grip. It is taken. Let go of the grip.
13. Controllers together, palms up, grip. Your two guns swap hands.
14. Off hand, grip on an imp in reach. It freezes in front of you for 3 s; punch it with the main hand.
15. Headlock again, then swing the off hand hard. The imp is thrown and hurts what it hits.
    **(not yet headset-confirmed; on the rig the 6.6 m/s toss was never seen hitting anything)**
16. Turn on *Headlock: Human Shield*. The monster stays held, facing away, while you keep the grip.
    **(not tested on the rig either; the off grip is a raw key there)**
17. Hand flat on a manual door, grip, raise the hand. The door follows; let go past about 40 % and it
    opens fully, before that it drops shut. The door's own sound plays.
18. Palm turned out on a wall switch. It flips once. **(not yet headset-confirmed)**
19. Turn *Hit-Stop (thrown hits)* to Beat. A monster hit by a throw freezes briefly.
    **(not yet headset-confirmed)**
20. With RSQ Laser Sight loaded and a gun in the hand, the grab beam on that hand hides.

## Works with

- **RSQ Laser Sight:** with *Yield to Laser Sight* on, the grab beam hides on a hand the laser lights.
- **RSQ Tactical Rig:** a hand in a holster (or holding the cigarette or Zippo) does not distance-grab;
  the walk-up grip yields to a holster. The rig asks this mod whether a hand holds a door.
- **RSQ Saber / RSQ ShieldSaw:** a hand holding them does not reach (*Not With Melee*).
- **RSQ Score:** holding a monster in the headlock counts as a touch for its combos. Throws are
  credited to you.
- **RSQ Grapple:** can use this mod's grab buttons (its own setting).
- **RSQ Accessibility:** colour-blind palette, Photosensitive Mode, Gesture Ease, Off-Hand Modifier,
  Cue Size, vignette, sound cues. Shared settings only act with it loaded. Its Steady Hands is **not wired
  into this mod yet** (handoff task A).
- **Gun Bonsai VR patch:** its grab perks (Long Arm, Iron Grip and others) grow this mod's settings.

## Known limits / open issues

- The grip is **eaten**: when something is in reach, the grip press goes to the walk-up grab, swap or
  headlock, and anything else bound to that grip does not see it (D31, by design).
- The walk-up grab, swap and headlock still fire on a hand holding the Tactical Rig's lit cigarette or
  Zippo (D35, open).
- Headlock weight uses Doom mass (imp 100, demon 400, baron 1000). A mod that changes monster mass
  changes what you can hold (D34).
- Under Brutal Doom, monsters are heavy (BD zombies are mass 300), so headlock tosses are slow; *Headlock
  Throw Weight %* is the dial (D37, D38). Feel not checked in the headset.
- A held thing's roll direction has not been checked against the headset; it may tip the wrong way.
- A lifted door may step at 35 Hz (a ceiling moved from script has no smoothing).
- The *Rumble* route is felt only when the engine's quake haptics level is above 0.
- No haptic of any kind was felt on the rig. Every rumble needs a hand on a controller.

## Credits

RSQ_DistanceGrab -- credits (from CREDITS.txt, unchanged):

Point at a thing across the room, pull it to your hand, carry it, throw it; lift doors by hand.
Part of the Radiant Silvergun Quest series. For stock QuestZDoom 17.3: ZScript and lumps only, no
engine changes. The code is new, ported in part from the project owner's desktop RS_WorldHands and
written for this pack.

WHAT THIS PK3 SHIPS, AND WHOSE IT IS
- No sounds of its own. Like RS_WorldHands, the grab is heard only through the world: the
  things you pull and throw, what they hit, and a door's own sound as you lift it.
- From RS_WorldHands (presidentkoopa, the project owner; his desktop hand system):
  The pull's flight path and its end-over-end tumble, the gravity, drag and flutter of
  everything that leaves a hand, a held thing tipping with the wrist and sagging by its
  weight, and the strain rumble: his designs and numbers, re-written here for stock QZD.
- Generated for this pack (original, procedural; nothing sampled or ripped):
  The beam and the reach cone (models/rsqdg/rsqbeam*, rsqcone*) and the cone's placeholder
  sprites (sprites/rsqdg/RSQC*, RSQE*, RSQB*): tools/gen_cone.py.
- The aim dot's glow (sprites/rsqdg/RSQTA0.png, the same image as graphics/rsqdglo.png):
  Added with the first laser models; no outside source is recorded for it.
- Ideas, no code or assets taken:
  The dot: QuestZDoom's bundled laser sight (GPL-3). The cone's look: DXR's debug wire cone
  (hw_weapon.cpp). The beam: the lightsaber blade's crossed-plane trick.
- QuestZDoom (Emawind and Team Beef):
  The engine, and the hand-pose script API the grab reads.

SHARING
- Free to share as part of the Radiant Silvergun Quest series.

Sounds (SNDINFO.txt): Doom's own `dsskeswg` (whoosh) and `dspunch` (thud), pitched by speed and weight.
