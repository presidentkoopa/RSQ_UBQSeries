# RSQ Gestures

The series' body reader: it watches both controllers and tells the other RSQ mods what your hands are doing.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New since the headset pass (tested on the rig, headset check pending): the punch and shove reader measured against the frame your headset drew, so walking and strafing are no gesture.

QuestZDoom 17.3 gives a mod two hand positions and their angles, once a frame, and nothing else. No hand
velocity, no finger tracking, no gesture system. RSQ Gestures builds all of that in ZScript: it keeps a quarter
second of movement for each hand, measures everything in metres from your own eyes, and turns it into named
gestures that any RSQ mod can ask about by name. No engine changes.

On its own it does very little you can see. Its job is to make the other mods feel like they read your body.

## Standout feature: the watch check

Raise the gun in front of your face and turn the back of your wrist toward you, as if checking a watch. Hold it
for a moment. Your controller gives a light tick, and **RSQ Gun Cards** shows that weapon's card.
With **RSQ Tactical Rig**'s optional Watch Check Move switched on, pressing Use in that pose moves the gun to
your other hand.

It is a real pose detector, not a button. It checks where the hand is (in front of your eyes, between upper
chest and just above eye level), which way the gun points (not at the floor or ceiling), how far the wrist has
turned, which way it has turned, and that the hand is still. Once it holds, you can move the gun a little while
you read. Left and right hands are mirrored correctly.

## Features

**Poses**
- **Watch check:** gun up in front of you, back of the wrist to your face, held briefly. A light tick in that
  controller when it holds.
- **Still:** how long each hand has been at rest.

**One hand**
- **Punch:** jab, hook or uppercut, named from how an empty hand travelled against the way you face.
- **Shove:** the same swing with a gun in hand, one hand or two. Never counted as a punch.
- **Thrust and pull:** a fast move along the hand's own pointing line, away from you or back.
- A swing with a blade (axe, sword, chainsaw) is neither. A braced two-hand gun or both hands driving the same
  way together is never a punch.

**Both hands**
- **Both hands down:** both swept hard down past your hips together.
- **Both hands apart:** thrown apart from your chest.
- **Both palms out:** both hands held out in front, pointing up, side by side, triggers released.
- **Both palms thrust:** both palms driven forward together, side by side.

**Fit and comfort**
- **Measure Me** fits every zone to your eye height and reach, so a tall, short or seated player makes the same
  gesture.
- **Quiet moments:** nothing is read as a gesture while you climb, swing or reel on an RSQ Grapple rope, or
  while the RSQ Wheel is open, and for a quarter second after.
- **Gesture names:** a small grey line low in your view names each gesture as it is recognised, then fades.
- **Cheap when idle:** it measures nothing unless a mod has asked in the last second or a switch is on.

## How To Play

1. Load it with the RSQ mods that use it (see Works with). It needs no setup.
2. **Watch check:** hold your gun up in front of your face, about a forearm away, and turn the back of your
   wrist toward your eyes. Hold still for a fraction of a second. You feel a tick.
3. **Fit it to your body:** open Options → Radiant Silvergun Options → RSQ Gestures and press Measure Me. Close
   the menu, stand tall and hold both arms straight out to your sides. Two seconds later it measures for one
   second and shows your eye height and reach. Fit Zones to My Body turns on by itself.
4. **Watch the names:** leave Show Gesture Names on while you learn. When a punch, shove or two-hand move
   registers, its name appears low in your view.
5. **Tune if needed:** if the watch check is hard to hit, lower Inspect Twist. If it triggers by accident, raise
   Inspect Hold.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Watch check | Gun hand 0.15 to 0.65 m in front of your eyes, from 0.30 m below to 0.20 m above eye level, within 0.35 m to the side. Gun no more than 60° up or down. Back of the wrist turned at least 45° toward your face. Hold still about 0.2 s. | Either hand. Holds while the twist stays above 30°. |
| Jab, hook, uppercut | Empty hand moves 0.15 m toward where you face at 2 m/s or faster | Uppercut: mostly upward. Hook: mostly sideways. |
| Shove | The same swing with a gun in that hand, or both hands on the gun | Never a punch. |
| Thrust / pull | Hand moves 2 m/s along its own pointing line, away or back | |
| Both hands down | Both hands moving down at 2 m/s, ending below your hips (0.60 m below your eyes), within 0.12 s of each other | |
| Both hands apart | From within 0.50 m of your chest, the gap between your hands opening at 2 m/s | |
| Both palms out | Both hands at least 0.25 m in front of your eyes, above your hips, pointing 40° up or more, still, triggers released, 0.25 m apart sideways, held 0.4 s | QuestZDoom reads no fingers, so "palm out" means hand up and trigger off. |
| Both palms thrust | Both hands driven forward at 2.5 m/s, mostly forward, pointing at least 20° up, above your hips, 0.25 m apart | Not while braced on a two-hand gun. |
| Measure Me | Menu button, then stand tall with arms straight out to the sides | |

No buttons or key binds. Every distance above scales with Fit Zones to My Body. Left-handed play works: the
engine's left-handed control scheme swaps the hands, and the watch check's twist direction follows.

## Menu

Options → Radiant Silvergun Options → RSQ Gestures

| Row | Default | What it does |
|---|---|---|
| Inspect Twist Way | Back of Wrist (watch) | Which way the wrist turns for the watch check: back of wrist, pulse side, or either. |
| Inspect Twist (degrees) | 45 | How far the wrist must turn to start the watch check. |
| Inspect Hold (tics) | 6 | How long the pose is held before it counts (35 tics = 1 second). |
| Watch Check Off | Off | On: the watch check is never read. RSQ Gun Cards then uses its own look-at-the-gun test. |
| Watch Check Tick | On | A light tick in that controller when the watch check holds. |
| Show Gesture Names | On | Names each recognised gesture low in your view. |
| Thrust and Pull Events | Off | Broadcasts thrust, pull, punch and shove as game events. No current RSQ mod listens for them. |
| Two-Hand Events | Off | Reads the two-hand gestures all the time. Mods that use them switch them on while they need them. |
| Both Hands Down | On | This two-hand gesture may fire. |
| Both Hands Apart | On | This two-hand gesture may fire. |
| Both Palms Out | On | This two-hand gesture may fire. |
| Both Palms Thrust | On | This two-hand gesture may fire. |
| Fit Zones to My Body | Off | Scales every zone to your measured eye height and reach. |
| Measure Me | — | Measures you (see How To Play). |

**Tuning and Debug** holds every number:

| Row | Default | What it does |
|---|---|---|
| Twist To Drop (degrees) | 30 | Below this twist the watch check lets go. |
| Lowest (below eyes) | 0.30 m | Lowest the watch-check hand may be. |
| Highest (above eyes) | 0.20 m | Highest. |
| Nearest (in front) | 0.15 m | Nearest in front of your eyes. |
| Furthest (in front) | 0.65 m | Furthest. |
| To The Side | 0.35 m | Furthest to either side. |
| Gun Points Up/Down At Most | 60° | Steepest the gun may point. |
| Hand Still Under (m/s) | 1.2 | The hand must be slower than this to start. |
| Drift Allowed Once On (m) | 0.05 | How far the hand may drift once held. |
| Thrust Speed (m/s) | 2.0 | Speed along the hand for a thrust or pull. |
| Thrust Fresher Than (ms) | 150 | The fastest moment must be this recent. |
| Thrust Repeat (tics) | 12 | Wait before the same hand thrusts again. |
| Still Under (m/s) | 0.30 | Below this a hand counts as still. |
| Together Within (ms) | 120 | How far apart in time two hands may move and still be one gesture. |
| Peak Fresher Than (ms) | 180 | Each hand's fastest moment must be this recent. |
| Refire After (ms) | 500 | Wait before the same two-hand gesture fires again. |
| Down: Speed (m/s) | 2.0 | Downward speed for both hands down. |
| Down: How Straight | 0.50 | Share of the movement that must be downward. |
| Hips Below Eyes (m) | 0.60 | Where your hips are. |
| Apart: Speed (m/s) | 2.0 | How fast the gap opens. |
| Chest Below Eyes (m) | 0.40 | Where your chest is. |
| Thrown From Within (m) | 0.50 | Hands must start this close to your chest. |
| Palms: In Front (m) | 0.25 | Each hand at least this far in front. |
| Palms: Held (ms) | 400 | How long palms out is held. |
| Palms: Pointing Up (degrees) | 40 | How far up each hand points. |
| Palms: Apart Sideways (m) | 0.25 | Side gap between the hands (thrust too). |
| Thrust: Speed (m/s) | 2.5 | Forward speed for both palms thrust. |
| Thrust: How Straight | 0.60 | Share of the movement that must be forward. |
| Thrust: Pointing Up (degrees) | 20 | How far up each hand points. |
| Punch Speed (m/s) | 2.0 | Average speed over the swing. |
| Punch Repeat (tics) | 6 | Wait before the same hand punches again. |
| Uppercut Rise | 0.50 | Upward share that makes an uppercut. |
| Punch Answered For (ms) | 300 | How long a punch or shove stays "just happened" for other mods. |
| Two-Hand Shove Share | 0.60 | The other hand moving this much the same way makes it a two-hand shove. |
| Watch Check Tick Strength | 0.35 | Strength of the tick. |
| Debug Log | Off | Writes gestures and hand numbers to the console. |
| Reset All | — | Puts every setting back to its default. |

## Works with

RSQ Gestures runs alone and needs nothing else. It finds the other mods by name, so load order among RSQ pk3s
does not matter.

- **RSQ Gun Cards:** the watch check shows the weapon card. With Watch Check Off, Gun Cards falls back to its own
  test.
- **RSQ Tactical Rig:** with its optional Watch Check Move on, Use during the watch check moves the gun to your
  other hand.
- **RSQ Melee:** both hands down is Ground Pound, both palms thrust is Clear Out, and both hands apart releases
  the Guard. Melee asks for these while you have the moves, so the Two-Hand Events switch can stay off.
- **RSQ Gun Bonsai VR:** the Fists tree needs RSQ Melee and RSQ Gestures loaded.
- **RSQ Grapple** and **RSQ Wheel:** gestures go quiet while you are on the rope or the Wheel is open.
- **RSQ Accessibility:** One-Handed mode's Off-Hand Modifier lets the main controller play the off hand.
  Slower Taps widens the two-hand timing window by half. Rumble Strength scales the tick. Measure Me works seated
  too.

## Credits and licence

Code: ZScript for the Radiant Silvergun Quest series by presidentkoopa, for stock QuestZDoom 17.3 by Emawind84
and Team Beef. No engine changes.

Ported from presidentkoopa's RS_Gestures, written for his REMA engine (UZDXREMA): the one-hand pose and impulse
detectors (still, thrust, pull) and the both-hands detectors (both down, both apart, both palms out), their
settings and their event shape. The watch check is new here, made for the RSQ weapon cards. The punch reader
follows RSQ Melee's boxing gloves. The hand reading follows RSQ Grapple's, and the shared Radiant Silvergun
Options menu is the series' own.

The gun-butt shove's blow (BD22 VR Reloaded's, with Brutal Doom's numbers and sounds), its slow motion and the
F.E.A.R. Effect now live in RSQ Melee, with their credits in its CREDITS.txt.
