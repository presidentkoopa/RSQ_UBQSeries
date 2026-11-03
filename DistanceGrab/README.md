# RSQ Distance Grab

Point at a thing across the room with your palm, pull it to your hand, carry it, throw it. Up close, the
grip takes things, lifts doors and flips switches. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3 (script only, no
engine changes). Most of the feel (the pull's arc and tumble, how thrown things fall, the carry's tip
and sag) is ported from the owner's desktop RS_WorldHands.

**Moved to RSQ Melee (2026-11-01):** the **Headlock** (the off hand's grip on a living monster, Human Shield,
the headlock throw) is [RSQ_Melee](../Melee/)'s now, with its settings (`rsqml_headlock*`). Distance Grab
keeps everything about objects. With both loaded, a monster thrown out of the Headlock still flies through
this mod's throw (its strength, weight, boost, aim assist and impact), and the two never fight over a grip
press: Melee takes it only when a monster is nearer the palm than anything this mod would take.

## Load order

```
doom2.wad -> 01 brutal22test6.pk3 -> 02 BD22_VoxelPack.pk3 -> 03 BD22_VR-Reloaded_2.0.3l.pk3
          -> 04-07 XMVE -> the RSQ pk3s, RSQ_DistanceGrab.pk3 among them   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** works. Every Brutal Doom class is looked up by name and skipped
  when it is missing (policy.zs). The body shield was rig-tested on plain Doom (DECISIONS D36).
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
  A gun you already own can be pulled too: the catch gives its ammo and the floor copy is used up (ammo
  full: it stays in your hand as a thing to carry or drop, as before).
- **A gun goes to the hand that grabbed it** (distance catch or walk-up grip, a gun you own too): off hand
  into the off hand, where it stays until you move it back yourself (the Tactical Rig, QuestZDoom's
  switch-hand) or holster it; main hand into the main hand. When it cannot (the same gun is already in the
  other hand, or it is a melee weapon, which BD22 VR hands over itself), a short line on screen says why.
- **Two-handing stands it down:** while you two-hand a gun (QuestZDoom's two-hand grip, BD22 VR's own
  two-hand hold, or the off hand ON the gun: in front of the gun hand and within 20 cm of the barrel line)
  there is no reach, lock, beam, cone or walk-up grab, and it stays off for half a second after the hands
  part, so canting the gun never fires it. An off hand merely raised beside the gun still reaches.
- **Fighting hands stand it down:** a hand wearing RSQ Melee's boxing gloves never reaches, and a hand
  that moves at punch speed does not reach for 0.75 s afterwards. An idle empty hand turned palm out
  still reaches.
- **Throw:** swing the arm forward. It lets go by itself as the swing slows. A wind-up never throws.
- **Drop:** turn the palm back with the arm still.
- **Two hands:** put the other, empty palm on a held thing. It gets lighter.
- **Hit with it:** swing a held barrel into a monster.
- **Walk-up grab:** put your palm on a thing within about 30 cm and squeeze the grip. Let go of the grip
  to let go.
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
| Not With Melee | On | A hand holding a saber, chainsaw or another mod's hand system does not reach; nor a hand in RSQ Melee's gloves, or one that moved at punch speed (RSQ Melee's Punch Min Speed, 2 m/s without it) in the last 0.75 s. An idle bare hand or fist still reaches. |
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
| What You Can Grab: Line of Sight | On | You cannot grab through a wall. |
| What You Can Grab: Use Pickups on Catch | On | A caught pickup is used at once. Off: you carry it instead. |
| What You Can Grab: Tip With Wrist | On | A held thing tips with your wrist. |
| What You Can Grab: Pull Gravity | Option | A pull sags under gravity. |
| What You Can Grab: Duck Under Doors | On | A pull dips under a low doorway. |
| What You Can Grab: Grip / Use / Palm Takes Door | On | The three ways to take hold of a door. |
| What You Can Grab: Palm Flips Switches | On | A palm laid on a switch flips it. |
| Beam and Feel: Yield to Laser Sight | Option | Hides the grab beam on a hand RSQ Laser Sight is already lighting. Off: both beams show. (`rsqdg_ls_yield`; renamed from `rsqdg_beam_yield` on 11-02 so an old ini's `true` no longer applies.) |
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
| Gesture: Two-Hand Reach (m) | 0.2 | With a gun in the main hand, an off hand 5-70 cm in front of it and this close to the barrel line is on the gun: the grab stands down. 0 = only the engine's two-hand grip and BD22 VR's two-hand count. (`rsqdg_twohand_r`, replaced `rsqdg_steady_m` on 11-02.) |
| Catch and Carry: Two-Hand Lift | 2.0 | Two palms on a thing make it handle this many times lighter. |
| Catch and Carry: Body Shield (held corpse/barrel) | On | A held corpse or barrel stops shots and fireballs. A barrel goes off. |
| Catch and Carry: Sounds (whoosh, thud) | On | Stock Doom sounds: revenant swing on a throw, punch on a catch or landing. |
| Catch and Carry: Pull Trail / Landing Dust | On | A faint trail behind a pull, dust on a hard landing. |
| Tuning and Debug: Report Actions / Report Refusals | Option | Logging for testing. Report Refusals prints every refusal with its reason: why a hand with its palm out may not reach, and for "nothing in the cone" the nearest thing and the test it failed. |
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
13. (Swapping guns between hands was removed on 11-01: use the Tactical Rig, holster with one hand and draw
    with the other.)
14. (The Headlock, its throw and Human Shield are tested in RSQ_Melee's README. With RSQ_Melee loaded: a headlock
    throw flies and lands like a thrown barrel here.)
15. Hand flat on a manual door, grip, raise the hand. The door follows; let go past about 40 % and it
    opens fully, before that it drops shut. The door's own sound plays.
16. Palm turned out on a wall switch. It flips once. **(not yet headset-confirmed)**
17. Turn *Hit-Stop (thrown hits)* to Beat. A monster hit by a throw freezes briefly.
    **(not yet headset-confirmed)**
18. With RSQ Laser Sight loaded and a gun in the main hand, raise the off hand beside it (30-45 cm away) and
    turn that palm out at an item: you see BOTH the laser from the gun and the grab beam from the off hand.
    The same with the gun hand's own palm turned out. Turn *Yield to Laser Sight* on: the grab beam on the
    hand the laser lights hides. **(rig only, not headset-confirmed: frames 11-02 on the full order with BD's
    Shotgun, an old ini still holding `rsqdg_beam_yield=true`)**
19. Load RSQ Accessibility (Steady Hands on). Point at a far item and hold: the lock stays on it instead of
    chattering. Throw something hard: it still flies where you threw. Steady Hands off: as before.
    **(not yet headset-confirmed; on the rig a 3-degree hand shake moved the cone 0.6 degrees on, 3 off)**
20. Accessibility's Rumble Strength 0: the grab's rumbles stop; 2: stronger. **(not yet headset-confirmed)**
21. Pull or walk-up grab a gun with the OFF hand, one you do not have and one you own but are not holding: it
    goes into the off hand and stays there. With the MAIN hand: it goes into the main hand (an owned gun too).
    Grab a copy of the gun the other hand holds: its ammo goes up and a line on screen says it is already in
    that hand. **(rig only, not headset-confirmed: 11-02, BD Shotgun, SSG, Chaingun, Rocket Launcher, Plasma
    Gun, both hands, distance and walk-up)**
22. Pull a floor copy of a gun you own with its ammo full: the game refuses it, it stays in your hand to carry
    or drop, and a line on screen says so. **(rig only, not headset-confirmed: 11-02)**
23. Two-hand a gun (off hand on its front) and cant it sideways with both palms turned out: no beam, no cone,
    no lock. The same with QuestZDoom's two-hand grip (off grip squeezed near the gun). Let go and part the
    hands: about half a second later the beam comes back. An off hand raised BESIDE the gun still reaches.
    **(rig only, not headset-confirmed: 11-02)**
24. Punch the air a few times with an empty hand or Brutal Doom's fists, then turn that palm out at an item at
    once: no beam and no lock for about 0.75 s, then it reaches. With RSQ Melee's boxing gloves on, that hand
    never reaches. Hold an empty hand still, palm out: it reaches as before. **(not yet headset-confirmed; rig
    11-02)**

## Works with

- **RSQ Laser Sight:** both beams show (the laser from the gun, the grab beam from the hand). With *Yield to
  Laser Sight* on, the grab beam hides on a hand the laser lights.
- **Brutal Doom / BD22 VR Reloaded:** its floor guns (BDWeaponSpawner) pull, give their ammo when owned, and go
  to the hand that grabbed them. BD22 VR's two-hand tokens (RSQ_TwoHandAimed, RSQ_TwoHandRifle, RSVR_MeleeTwo)
  count as two-handing (asked by name). Its own axe pull is left to it (melee weapons are not moved by this mod).
- **RSQ Tactical Rig:** a hand in a holster (or holding the cigarette or Zippo) does not distance-grab;
  the walk-up grip yields to a holster. The rig asks this mod whether a hand holds a door.
- **RSQ Saber / RSQ ShieldSaw:** a hand holding them does not reach (*Not With Melee*).
- **RSQ Score:** throws are credited to you. (The Headlock's "grab.hold" touch is RSQ_Melee's now.)
- **RSQ Melee:** a hand in its boxing gloves does not reach; its Punch Min Speed is the punch speed above. Its Headlock asks `near.dist` (which mod takes the off grip press) and hands a thrown monster
  to `headlock.throw` (RSQDG_ThrowService); this mod asks it `headlock.claim` back. Without Melee, nothing
  changes here.
- **RSQ Grapple:** can use this mod's grab buttons (its own setting).
- **RSQ Accessibility:** colour-blind palette, Photosensitive Mode, Gesture Ease, Off-Hand Modifier,
  Cue Size, vignette, sound cues. Steady Hands (on in Accessibility): the aim cone that picks what to lock
  (and the idle beam's far end) points from the smoothed hand; throws, catches, the carry and the palm gate
  stay on the raw hand. Steady Hands off: as before. Rumble Strength scales the grab's rumble x0 to x2 (0 =
  none; the pulse route's fixed buzz is only switched off at 0). Shared settings only act with it loaded.
- **Gun Bonsai VR patch:** none. The grab has no tree (owner, 11-03: "a needed player thing"; its 11-02 tree was
  dropped): with the patch loaded it is exactly its rows, nothing waits to be learned.

## Known limits / open issues

- The grip is **eaten**: when something is in reach, the grip press goes to the walk-up grab, and
  anything else bound to that grip does not see it (D31, by design).
- The walk-up grab still fires on a hand holding the Tactical Rig's lit cigarette or Zippo (D35, open).
- A monster held by an old (before 11-01) save's headlock keeps its borrowed no-gravity after loading with
  this version (the hold moved to RSQ_Melee and this mod no longer releases it).
- A held thing's roll direction has not been checked against the headset; it may tip the wrong way.
- A lifted door may step at 35 Hz (a ceiling moved from script has no smoothing).
- The *Rumble* route is felt only when the engine's quake haptics level is above 0.
- No haptic of any kind was felt on the rig. Every rumble needs a hand on a controller.
- A gun caught by the off hand while the main hand is still switching, or while QuestZDoom's two-hand grip is
  latched, waits to be raised (the grip: until it is let go). Only the plain case was run on the rig.
- One gun cannot be in both hands: QuestZDoom keeps one weapon per class, so grabbing a copy of the gun the
  other hand holds gives its ammo and says so (BD22 VR's Dual key gives its own off-hand copies).
- A gun you own with full ammo is refused by the game's own pickup: it is carried in the hand instead, with a
  line on screen saying so.
- With RSQ Melee's gloves on, that hand never distance-grabs.
- With RSQ Saber loaded its second saber starts in the off hand, lit (its *Start With Dual Sabers*). A hand
  holding a lit saber never distance-grabs (*Not With Melee*); a line on screen says so when you hold that palm
  out. Switch the blade off, holster it, or turn *Not With Melee* off.
- Brutal Doom's own pickups decide what a floor gun gives: the Plasma Gun and Rifle give a dual-wield token
  when you already own one, and any gun whose Purist version you hold gives ammo only. Then there is no gun
  to move to the grabbing hand, and nothing moves.

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
