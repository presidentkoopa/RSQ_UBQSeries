# RSQ Accessibility

One menu that makes the whole Radiant Silvergun Quest series playable your way: one hand, seated, left-handed, colour blind, motion sensitive or light sensitive.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (rig only, not headset-confirmed): the gesture reader folded in from RSQ Gestures (11-05);
the looser watch check, Watch Check Twist 35 degrees (11-06, was 45).

RSQ is a series of VR mods for stock QuestZDoom 17.3, built in ZScript alone with no engine changes. This pk3 holds
the settings every series mod reads. Each mod keeps its own behaviour when this pk3 is absent, and nothing changes until
you change a setting here.

## Standout feature: play the series with one hand

Turn on **One-Handed** and bind the **Off-Hand Modifier**. Hold it, and your main hand plays the off hand's part: it
reaches behind you for the ShieldSaw, makes the off-hand distance grab, the off-hand whip, grapple, punch and
saber moves. A short tick in the main hand tells you it has switched parts. Let go and it is your main hand again.

Then there are the moves that are pure motion: a wrist flick, a palm turned out, a Force push. Each one has a **Gesture
Button** you can bind to any key or button. Hold to Toggle turns every held button into a press-on, press-off switch, so
nothing needs a button held down.

Doing this across a whole series of separate mods, in stock QuestZDoom, with nothing linked together, is the trick: every
mod asks this pk3 by name, and works exactly as before when it is not there.

## Features

**Seeing**
- **Colour Blind Mode**: Protanopia, Deuteranopia, Tritanopia or High Contrast. Series mods recolour their cues and
  rings so meaning never rides on red against green alone.
- **Photosensitive Mode**: flashes, flickers and pulses from the series come at most 2.5 times a second, and strong
  flashes at 40% brightness.
- **Cue Size** (x0.5 to x3) for the dots, rings, glows and markers the series draws. **Text Size** (x1 to x3) for the
  series' HUD text and the Gun Bonsai screens.

**Hearing and feeling**
- **Sound Cues**: an arrow round the middle of your view, a rumble on that side, or both, for a hit on you or a shot
  coming at you from out of view. Hits are big filled arrows, incoming shots open chevrons. One arrow per attacker, so a
  burst of tracers is one cue.
- **Wake Cues**: the same cue (a grey double chevron) when a monster within range wakes up aimed at you or teleports in
  out of view.
- A steady "Slow Motion" label and a long soft rumble when RSQ SlowMo starts, "Normal Speed" and a short rumble when it
  stops (with Sound Cues on).
- **Rumble Strength**: every series rumble from x0 (none) to x2.
- **Rumble Backup**: if QuestZDoom's own Quake Haptics level is 0, series rumbles still arrive, as the engine's own
  short shot buzz on the same controller.

**Comfort**
- **Comfort Vignette**: darkens the edge of each eye's view while a grapple or whip swings, yanks or climbs you, and on a
  Force jump. It is a per-eye post-process pass, so it moves with your head with no lag, and it eases in and out so it
  never snaps. Light, Medium or Strong.
- **Vignette on Knockback**: the vignette also on a big knockback (a rocket blast, an Arch-vile's toss) and on a long fall.
- **Slow-Mo Ease**: the slowest a slow-motion change may ramp, up to 2 seconds.

**Body and hands**
- **Handedness**: Right- or Left-Handed here also sets QuestZDoom's own Control Scheme, so the guns, the hands and every
  series holster, pocket and HUD move to the same side. It remembers which of QuestZDoom's two left-handed schemes you
  used. Follow QuestZDoom leaves the engine alone.
- **Seated Play**: Standing, Seated or Auto. Auto calls you seated once your eyes have been 25 cm or more below your
  standing height for 2 seconds, and standing again within 15 cm for 1 second. Series mods lower their holsters and mounts
  with you.
- **Measure Standing Height**: stand straight and pick the row. Without it, your standing height is learned from a head
  held steady, never lower than 1.62 m.
- **Steady Hands**: a 1-euro filter on both hands' poses (strong smoothing when a hand is still, almost none when it
  moves fast), offered to every series mod that aims from a hand.
- **Gesture Ease**: wider gesture tolerances (up to x2) and lower speeds and holds (down to half).
- **Slower Taps**: every tap and double-tap window in the series x1.5.
- **Two-Hand Brace**: turns QuestZDoom's Two Handed Weapons off, so gripping near your gun never latches the brace that
  makes the off-hand gun go dead. Setting it back restores your own value.
- **Brace Cue**: a rumble, a click, or both the moment the brace latches with a gun in your off hand.

**Menus**
- **Menus: Simple** takes the Test and Debug link off each series mod's page, leaving the everyday switches. Full puts it back.
- **Reset Every Mod** runs the Reset All row of every loaded series mod in one go (this page is kept).

## How To Play

1. Load this pk3 with any RSQ mods. Load order among RSQ pk3s does not matter.
2. Open **Options → Radiant Silvergun Options → Accessibility**. Everything starts off or neutral.
3. Left-handed? Set **Handedness** to Left-Handed once. QuestZDoom's control scheme follows.
4. Prone to motion sickness? Set **Comfort Vignette: Medium**, **Slow-Mo Ease 1 s** and **Photosensitive Mode**, then try **Vignette on Knockback**.
5. Playing seated? Leave **Seated Play** on Auto, or set Seated. Stand once and pick **Measure Standing Height** first
   for the best fit.
6. One hand only? Turn on **One-Handed**, bind **Off-Hand Modifier** to a button you can reach, then open **Gesture
   Buttons** and bind the moves you use. Turn on **Hold to Toggle** if holding a button is hard.
7. Hard of hearing? Set **Sound Cues** to Both and turn on **Wake Cues**.

## Controls

All binds are optional and have no default key. Find them under **RSQ Accessibility** in Customize Controls, or as
Control rows on the menu page. They act only while **One-Handed** is on.

| Action | How (VR) | Notes |
|---|---|---|
| Off-Hand Modifier | Hold the bound button | Main hand plays the off hand's part while held. With Hold to Toggle: press on, press off. |
| Grab Pull | Press | RSQ Distance Grab's wrist flick: whatever a hand has locked flies to it. |
| Grab Reach | Hold | RSQ Distance Grab's palm-out reach. Toggles with Hold to Toggle. |
| Force Push | Press | RSQ Saber's Force push. |
| Force Pull | Press | RSQ Saber's Force pull. |
| Force Grip | Hold | RSQ Saber's Force grip. Toggles with Hold to Toggle. |
| Shield Throw | Press | RSQ ShieldSaw's forward flick: at the ringed targets, or along your aim. |
| Flick Reload | Press | The flick-reload of the main gun while the ShieldSaw or saber holds the off hand. |
| Wrist Cross | Press | Toggles RSQ SlowMo, the same as crossing your wrists. |
| Measure Standing Height | Stand straight, pick the menu row | Prints your eye height to the console. |

Left-handed play: set Handedness (above). The rumbles and cue arrows follow the engine's main hand.

## Gestures (the series' gesture reader)

RSQ Gestures was folded into Accessibility on 2026-11-05: one fewer pk3. Accessibility now carries the series'
gesture reader, unchanged: the same answers to every mod that asks (by the same names), the same settings (your saved
values carry over). Without Accessibility, Gun Cards, Tactical Rig and Melee read the gestures they need themselves, as
before.

> **Upgrading: remove the old RSQ_Gestures.pk3.** Loading an old `RSQ_Gestures.pk3` beside this Accessibility gives
> duplicate class errors (both define RSQG_Service, RSQG_Handler and the rest) and the game will not start. Delete it
> or move it out of your mod folder.

QuestZDoom 17.3 gives a mod two hand positions and their angles, once a frame, and nothing else. The reader keeps a
quarter second of movement for each hand, measures everything in metres from your own eyes, and turns it into named
gestures any RSQ mod can ask about by name. It measures nothing unless a mod asked in the last second or a switch is on.

**The watch check.** Raise the gun in front of your face and turn the back of your wrist toward you, as if checking a watch. Hold it
for a moment. Your controller gives a light tick, and **RSQ Gun Cards** shows that weapon's card.
With **RSQ Tactical Rig**'s optional Watch Check Move switched on, pressing Use in that pose moves the gun to
your other hand.

It is a real pose detector, not a button. It checks where the hand is (in front of your eyes, between upper
chest and just above eye level), which way the gun points (not at the floor or ceiling), how far the wrist has
turned, which way it has turned, and that the hand is still. Once it holds, you can move the gun a little while
you read. Left and right hands are mirrored correctly.

**Poses**
- **Watch check:** gun up in front of you, back of the wrist to your face, held briefly. A light tick in that
  controller when it holds.
- **Still:** how long each hand has been at rest.

**One hand**
- **Punch:** jab, hook or uppercut, named from how an empty hand travelled against the way you face.
- **Shove:** the same swing with a gun in hand, one hand or two (named "gun-butt shove" on screen). Never counted as a punch.
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

**Fit to your body:** Options → Radiant Silvergun Options → Accessibility → Gestures → Measure Me. Close the menu,
stand tall and hold both arms straight out to your sides. Two seconds later it measures for one second and shows your
eye height and reach. Fit to My Body turns on by itself.

| Action | How (VR) | Notes |
|---|---|---|
| Watch check | Gun hand 0.15 to 0.65 m in front of your eyes, from 0.30 m below to 0.20 m above eye level, within 0.35 m to the side. Gun no more than 60° up or down. Back of the wrist turned at least 35° toward your face (Watch Check Twist; 45° before 11-06). Hold still about 0.2 s. | Either hand. Holds while the twist stays above 20°. |
| Jab, hook, uppercut | Empty hand moves 0.15 m toward where you face at 2 m/s or faster | Uppercut: mostly upward. Hook: mostly sideways. |
| Shove | The same swing with a gun in that hand, or both hands on the gun | Never a punch. |
| Both hands down | Both hands moving down at 2 m/s, ending below your hips (0.60 m below your eyes), within 0.12 s of each other | |
| Both hands apart | From within 0.50 m of your chest, the gap between your hands opening at 2 m/s | |
| Both palms out | Both hands at least 0.25 m in front of your eyes, above your hips, pointing 40° up or more, still, triggers released, 0.25 m apart sideways, held 0.4 s | QuestZDoom reads no fingers, so "palm out" means hand up and trigger off. |
| Both palms thrust | Both hands driven forward at 2.5 m/s, mostly forward, pointing at least 20° up, above your hips, 0.25 m apart | Not while braced on a two-hand gun. |
| Measure Me | Menu button, then stand tall with arms straight out to the sides | |

No buttons or key binds for gestures. Every distance above scales with Fit to My Body. Left-handed play works: the
engine's left-handed control scheme swaps the hands, and the watch check's twist direction follows.

## Menu

**Options → Radiant Silvergun Options → Accessibility**. One page; its **Test and Debug** page holds the debug log and the gesture tuning numbers.
Accessibility is never gated by Gun Bonsai VR.

| Row | Default | What it does |
|---|---|---|
| **Seeing** | | |
| Colour Blind Mode | Off | Off, Protanopia, Deuteranopia, Tritanopia, High Contrast. |
| Photosensitive Mode | Off | Series flashes and pulses at most 2.5 a second, strong flashes at 40%. |
| Cue Size | 1.00 | x0.5 to x3. |
| Text Size | 1.00 | x1 to x3. |
| **Hands** | | |
| Handedness | Follow QuestZDoom | Right- or Left-Handed also sets QuestZDoom's Control Scheme. |
| Steady Hands | On | Smoothed hand poses for the series. |
| Slower Taps | Off | Tap windows x1.5. |
| Hold to Toggle | Off | Held binds (modifier, reach, Force grip, ShieldSaw lock key) become toggles. |
| Gesture Ease | 0.0 | 0 to 1: gestures wider (x1 to x2), speeds and holds lower (x1 to x0.5). |
| **One Hand** | | |
| One-Handed | Off | Enables the Off-Hand Modifier and the gesture buttons below. |
| Off-Hand Modifier | (unbound) | The bind itself. |
| Grab Pull, Grab Reach, Force Push, Force Pull, Force Grip, Shield Throw, Flick Reload, Wrist Cross | (unbound) | The gesture buttons (see Controls). |
| **Comfort** | | |
| Comfort Vignette | Off | Off, Light, Medium, Strong. |
| Vignette on Knockback | Off | Also on big knockbacks and long falls. |
| Slow-Mo Ease (s) | 0.0 | The slowest a slow-motion change may ramp, up to 2 s. 0 keeps RSQ SlowMo's own. |
| Seated Play | Auto | Standing, Seated, Auto. |
| Measure Standing Height | | Stores your standing eye height. |
| **Cues and Rumble** | | |
| Sound Cues | Off | Off, Visual, Rumble, Both. |
| Wake Cues | Off | Also cue monsters waking or teleporting in (needs Sound Cues). |
| Rumble Strength | 1.0 | x0 to x2. |
| Rumble Backup | Off | Rumbles as the engine's buzz when Quake Haptics is 0. |
| **Two-Hand Brace** | | |
| Two-Hand Brace | QuestZDoom's | Off turns QuestZDoom's Two Handed Weapons off. |
| Brace Cue | Off | Off, Rumble, Sound, Both. |
| **Gestures** | | |
| Watch Check | On | Off: the watch check is never read. RSQ Gun Cards then uses its own look-at-the-gun test. |
| Wrist Turn | Watch Side | Which way the wrist turns for the watch check: Watch Side (back of the wrist), Palm Up, or Either Way. |
| Watch Check Twist (deg) | 35 | How far the wrist must turn for the watch check (the same setting as Test and Debug's Twist On). Lower is looser. 45 before 11-06. |
| Tick When Ready | On | A light tick in that controller when the watch check holds. |
| Two-Hand Gestures | Off | Reads the two-hand gestures all the time. Mods that use them switch them on while they need them. |
| Both Hands Down, Both Hands Apart, Both Palms Out, Both Palms Thrust | On | Each two-hand gesture may fire. |
| Fit to My Body | Off | Scales every gesture zone to your measured eye height and reach. |
| Measure Me | | Measures you (see Gestures above). |
| Show Gesture Names | On | Names each recognised gesture low in your view. |
| **Menus** | | |
| Menus | Full | Full or Simple (Simple hides each series mod's Test and Debug link). |
| Test and Debug | | Debug Log (Off): the knockback and wake detections, to the console. Then the gesture numbers (below). |
| Reset All | | Resets this page and Test and Debug, gestures included (Handedness, Two-Hand Brace and your measured body are kept). |
| Reset Every Mod | | Runs every loaded series mod's own Reset All. |

**Test and Debug, Gestures rows** (headed "Gestures: ..."):

| Row | Default | What it does |
|---|---|---|
| **Watch Check** | | |
| Twist On (deg) | 35 | How far the wrist must turn to start the watch check. |
| Twist Off (deg) | 20 | Below this twist the watch check lets go. |
| Hold (tics) | 6 | How long the pose is held before it counts (35 tics = 1 second). |
| Below Eyes (m) | 0.30 | Lowest the watch-check hand may be. |
| Above Eyes (m) | 0.20 | Highest. |
| Nearest (m) | 0.15 | Nearest in front of your eyes. |
| Furthest (m) | 0.65 | Furthest. |
| To the Side (m) | 0.35 | Furthest to either side. |
| Gun Tilt Max (deg) | 60 | Steepest the gun may point. |
| Hand Still (m/s) | 1.2 | The hand must be slower than this to start. |
| Drift Allowed (m) | 0.05 | How far the hand may drift once held. |
| Tick Strength | 0.35 | Strength of the tick. |
| **One Hand** | | |
| Still Under (m/s) | 0.30 | Below this a hand counts as still. |
| **Both Hands** | | |
| Together (ms) | 120 | How far apart in time two hands may move and still be one gesture. |
| Peak Age (ms) | 180 | Each hand's fastest moment must be this recent. |
| Refire (ms) | 500 | Wait before the same two-hand gesture fires again. |
| Down Speed (m/s) | 2.0 | Downward speed for both hands down. |
| Down Straightness | 0.50 | Share of the movement that must be downward. |
| Hips Below Eyes (m) | 0.60 | Where your hips are. |
| Apart Speed (m/s) | 2.0 | How fast the gap opens. |
| Chest Below Eyes (m) | 0.40 | Where your chest is. |
| Apart From Chest (m) | 0.50 | Hands must start this close to your chest. |
| Palms Ahead (m) | 0.25 | Each hand at least this far in front. |
| Palms Held (ms) | 400 | How long palms out is held. |
| Palms Up (deg) | 40 | How far up each hand points. |
| Palms Apart (m) | 0.25 | Side gap between the hands (thrust too). |
| Thrust Speed (m/s) | 2.5 | Forward speed for both palms thrust. |
| Thrust Straightness | 0.60 | Share of the movement that must be forward. |
| Thrust Palms Up (deg) | 20 | How far up each hand points. |
| **Punch and Shove** | | |
| Punch Speed (m/s) | 2.0 | Average speed over the swing. |
| Punch Repeat (tics) | 6 | Wait before the same hand punches again. |
| Uppercut Rise | 0.50 | Upward share that makes an uppercut. |
| Punch Kept (ms) | 300 | How long a punch or shove stays "just happened" for other mods. |
| Shove Share | 0.60 | The other hand moving this much the same way makes it a two-hand shove. |
| **Debug** | | |
| Gesture Debug Log | Off | Off, Events, Events + Hands (once a second), Events + Hands + Cost. |

## Works with

- **Alone**: the vignette, the off-view and wake cues, the slow-motion label, Handedness, Two-Hand Brace and the brace
  cue all work with no other mod loaded.
- **The RSQ series**: every series mod reads these settings by name. Distance Grab, Grapple, Whip, Melee, the gesture reader,
  ShieldSaw and Saber honour the Off-Hand Modifier. Grapple and Whip swings and the Saber's Force jump drive the comfort
  vignette. Distance Grab, ShieldSaw and Saber answer the gesture buttons; RSQ SlowMo answers Wrist Cross and Slow-Mo
  Ease.
- **RSQ Gun Bonsai VR**: Text Size scales its screens.
- **Brutal Doom / BD22 VR Reloaded**: nothing special is needed. The brace cue only fires with a real gun (one that uses
  ammo) in the off hand, not Brutal Doom's empty fist.
- **Gestures** (found by name, load order does not matter): **RSQ Gun Cards**' watch card shows on the watch check
  (Watch Check Off: Gun Cards uses its own test). **RSQ Tactical Rig**'s Watch Check Move: Use during the watch check
  moves the gun to your other hand. **RSQ Melee**: both hands down is Ground Pound, both palms thrust is Clear Out, both
  hands apart releases the Guard (Melee switches these on while you have the moves). **RSQ Gun Bonsai VR**'s Fists tree
  needs RSQ Melee and someone reading both hands (this reader, or Melee's own copy). **RSQ Grapple** and **RSQ Wheel**:
  gestures go quiet on the rope or while the Wheel is open. Slower Taps widens the two-hand window by half; Rumble
  Strength scales the tick.

## Credits and licence

- Design, the shared menu and the shared setting names: presidentkoopa.
- Code: new, written for this pack.
- Gestures: ported from presidentkoopa's RS_Gestures (REMA): the one-hand and both-hands detectors, their settings
  and event shape. The watch check is new, made for the RSQ weapon cards; the punch reader follows RSQ Melee's gloves.
- QuestZDoom: Emawind and Team Beef. The menu builds on its option menu classes.

Free to share as part of the Radiant Silvergun Quest series.
