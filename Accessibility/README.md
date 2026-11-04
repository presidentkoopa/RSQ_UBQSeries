# RSQ Accessibility

One menu that makes the whole Radiant Silvergun Quest series playable your way: one hand, seated, left-handed, colour blind, motion sensitive or light sensitive.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

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
- **Min SlowMo Ease**: the slowest a slow-motion change may ramp, up to 2 seconds.
- **Comfort Preset**: one row that sets Vignette Medium, Min SlowMo Ease 1 s and Photosensitive Mode together.

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
- **Menus: Simple** takes the niche sub-page links off the series' front pages, leaving the everyday switches. Full puts them back.
- **Reset Every Series Mod** runs the Reset All row of every loaded series mod in one go (this page is kept).

## How To Play

1. Load this pk3 with any RSQ mods. Load order among RSQ pk3s does not matter.
2. Open **Options → Radiant Silvergun Options → Accessibility**. Everything starts off or neutral.
3. Left-handed? Set **Handedness** to Left-Handed once. QuestZDoom's control scheme follows.
4. Prone to motion sickness? Pick **Comfort Preset: Comfort**, then try **Vignette on Knockback**.
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

## Menu

**Options → Radiant Silvergun Options → Accessibility**

| Row | Default | What it does |
|---|---|---|
| Colour Blind Mode | Off | Off, Protanopia, Deuteranopia, Tritanopia, High Contrast. |
| Handedness | Follow QuestZDoom | Right- or Left-Handed also sets QuestZDoom's Control Scheme. |
| Photosensitive Mode | Off | Series flashes and pulses at most 2.5 a second, strong flashes at 40%. |
| One-Handed | Off | Enables the Off-Hand Modifier and the Gesture Buttons. |
| Off-Hand Modifier | (unbound) | The bind itself. |
| Gesture Buttons | | Sub page of binds (see Controls). |
| Gesture Ease | 0.0 | 0 to 1: gestures wider (x1 to x2), speeds and holds lower (x1 to x0.5). |
| Hold to Toggle | Off | Held binds (modifier, reach, Force grip, ShieldSaw lock key) become toggles. |
| Comfort Preset | Off | Off or Comfort (Vignette Medium, Min SlowMo Ease 1 s, Photosensitive On). Shows Custom otherwise. |
| Comfort Vignette | Off | Off, Light, Medium, Strong. |
| Vignette on Knockback | Off | Also on big knockbacks and long falls. |
| Min SlowMo Ease | 0.0 | Seconds, up to 2. 0 keeps RSQ SlowMo's own. |
| Seated Play | Auto | Standing, Seated, Auto. |
| Measure Standing Height | | Stores your standing eye height. |
| Steady Hands | On | Smoothed hand poses for the series. |
| Slower Taps | Off | Tap windows x1.5. |
| Cue Size | 1.00 | x0.5 to x3. |
| Text Size | 1.00 | x1 to x3. |
| Sound Cues | Off | Off, Visual, Rumble, Both. |
| Wake Cues | Off | Also cue monsters waking or teleporting in (needs Sound Cues). |
| Rumble Strength | 1.0 | x0 to x2. |
| Rumble Backup | Off | Rumbles as the engine's buzz when Quake Haptics is 0. |
| Two-Hand Brace | QuestZDoom's | Off turns QuestZDoom's Two Handed Weapons off. |
| Brace Cue | Off | Off, Rumble, Sound, Both. |
| Menus | Full | Full or Simple. |
| Reset All | | Resets this page (Handedness and Two-Hand Brace are kept). |
| Reset Every Series Mod | | Runs every loaded series mod's own Reset All. |

## Works with

- **Alone**: the vignette, the off-view and wake cues, the slow-motion label, Handedness, Two-Hand Brace and the brace
  cue all work with no other mod loaded.
- **The RSQ series**: every series mod reads these settings by name. Distance Grab, Grapple, Whip, Melee, Gestures,
  ShieldSaw and Saber honour the Off-Hand Modifier. Grapple and Whip swings and the Saber's Force jump drive the comfort
  vignette. Distance Grab, ShieldSaw and Saber answer the Gesture Buttons; RSQ SlowMo answers Wrist Cross and Min SlowMo
  Ease.
- **RSQ Gun Bonsai VR**: Text Size scales its screens.
- **Brutal Doom / BD22 VR Reloaded**: nothing special is needed. The brace cue only fires with a real gun (one that uses
  ammo) in the off hand, not Brutal Doom's empty fist.

## Credits and licence

- Design, the shared menu and the shared setting names: presidentkoopa.
- Code: new, written for this pack.
- QuestZDoom: Emawind and Team Beef. The menu builds on its option menu classes.

Free to share as part of the Radiant Silvergun Quest series.
