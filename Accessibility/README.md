# RSQ Accessibility

One shared settings page for the whole Radiant Silvergun Quest series: colour-blind colours, left- or
right-handed, photosensitive mode, one-handed play, comfort vignette, bigger cues and text, sound cues you
can see or feel, and one Reset for every series mod. Most of it does nothing by itself: the other series
mods read these settings when this pk3 is loaded, and behave as before when it is not.

Pk3: `pk3/RSQ_Accessibility.pk3`.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
**RSQ_Accessibility.pk3** (with any other RSQ pk3s, in any order)

- Works on plain Doom 2 without Brutal Doom.
- Needs no other pk3 to load. On its own only a few rows do something you can see (Handedness, Sound
  Cues, Wake Cues, Two-Hand Brace, Brace Cue, Comfort Vignette on knockback, Reset Every Series Mod).
  The rest show up through the other series mods (see "Works with").

## Setup

- Menu: Options -> Radiant Silvergun Options -> **Accessibility**.
- Buttons (only for One-Handed play). Customize Controls, section **RSQ Accessibility**, or the same rows on
  the Accessibility page and its Gesture Buttons page. No default binds:
  - **Off-Hand Modifier** (held: your main controller plays the off hand's part)
  - **Grab Pull**, **Grab Reach** (Distance Grab)
  - **Force Push**, **Force Pull**, **Force Grip** (Saber's Force)
  - **Shield Throw** (ShieldSaw), **Flick Reload** (ShieldSaw and Saber), **Wrist Cross** (SlowMo)
  - These buttons work only while **One-Handed** is On.

## What to do in VR

- Seated Play, Measure Standing Height: stand up straight, then pick the row.
- Off-Hand Modifier: hold the button and move your main hand; it acts as your off hand.
- Gesture buttons: press instead of doing the gesture (flick, palm out, wrist cross).

## Features

| Row | Default | What it does |
|---|---|---|
| Colour Blind Mode | Off | Protanopia / Deuteranopia / Tritanopia / High Contrast colours across the series. |
| Handedness | Follow QuestZDoom | Right- or Left-Handed also sets QuestZDoom's Control Scheme. The left-handed scheme you used (A or B) is remembered. |
| Photosensitive Mode | Option (off) | Series flashes at 40 % strength; flashes, flickers and pulses at most about 2.5 a second. |
| One-Handed | Option (off) | Turns on the Off-Hand Modifier and the Gesture Buttons. |
| Off-Hand Modifier | button | See Setup. |
| Gesture Buttons | page | The button for each gesture (see Setup). |
| Gesture Ease | 0 | Up to twice as forgiving gestures: wider angles, lower speeds, shorter holds. |
| Hold to Toggle | Option (off) | Held buttons latch on a press and let go on the next press (Force trigger, grapple reel, shield lock, the modifier, held gesture buttons). |
| Comfort Preset | Off | One row: Comfort = Comfort Vignette Medium + Min SlowMo Ease 1 s + Photosensitive Mode. Shows "Custom" when the three match neither. |
| Comfort Vignette | Off | Light / Medium / Strong dark edge while a grapple swings, reels, climbs or yanks, and on a boosted Force jump. |
| Vignette on Knockback | Option (off) | The vignette also on a big knockback and a long fall. Needs Comfort Vignette above Off. |
| Min SlowMo Ease | 0 | No slow-motion ease shorter than this many seconds (0 = SlowMo's own). |
| Seated Play | Auto | Standing / Seated / Auto (seated once your eyes sit 0.25 m+ below standing for 2 s). |
| Measure Standing Height | row | Stores your standing eye height. |
| Steady Hands | On | Smooths both hands' pointing (a tremor filter). |
| Slower Taps | Option (off) | Every tap and double-tap window in the series 1.5x longer. |
| Cue Size | 1.0 | Series dots, rings, glows and markers x0.5 to x3. |
| Text Size | 1.0 | Series HUD text x1 to x3. |
| Sound Cues | Off | Visual: arrows round the view for hits and shots from out of view, and a "Slow Motion" label. Rumble: the controller on that side, slow-mo start / stop, ready cues. Both. |
| Wake Cues | Option (off) | Sound Cues also mark a monster waking or teleporting in out of view (grey double chevron and rumble). Needs Sound Cues above Off. |
| Rumble Strength | 1.0 | Rumble x0 to x2 (0 = none). |
| Rumble Backup | Option (off) | With QuestZDoom's Quake Haptics level at 0, this pk3's rumbles still come, as the engine's short shot buzz. |
| Two-Hand Brace | QuestZDoom's | Off turns QuestZDoom's Two Handed Weapons off, so gripping near the gun never kills the off-hand gun. QuestZDoom's puts your own value back. |
| Brace Cue | Off | Rumble / Sound (Doom's switch click) / Both the moment the brace latches with a gun in the off hand. |
| Menus | Full | Simple hides the series pages' niche sub-pages. |
| Reset All | row | Resets this page (keeps Handedness and Two-Hand Brace). |
| Reset Every Series Mod | row | Runs every loaded series mod's own Reset All. Accessibility is kept. |

## Test it

Load the order above plus RSQ_Accessibility.pk3. Add the mod named in a step when that step needs it.

1. Open Options -> Radiant Silvergun Options. The **Accessibility** row is there. Open it.
2. Handedness -> Left-Handed. Your gun moves to the left controller. Back to Right-Handed: it moves back.
   Follow QuestZDoom leaves the scheme as it is.
3. Sound Cues -> Visual. Let a monster shoot you from behind. An arrow shows at the edge of the view on
   that side.
4. Sound Cues -> Rumble. The same hit buzzes the controller on that side. Rumble Strength 0: no buzz.
   Rumble Strength 2: stronger.
5. Turn on Wake Cues (Sound Cues still on). A monster waking out of view gives a grey double chevron and a
   rumble on its side. (not yet headset-confirmed)
6. Comfort Vignette -> Medium, Vignette on Knockback On. Get blown into the air or fall a long way: the
   view edge darkens. (not yet headset-confirmed)
7. Two-Hand Brace -> Off. Hold a gun in each hand and grip with the off hand near the main gun. The off-hand
   gun keeps working. Back to QuestZDoom's: the brace latches again. (not yet headset-confirmed)
8. Brace Cue -> Both. Grip near the gun with a gun in the off hand: a rumble and a switch click as it
   latches. (not yet headset-confirmed)
9. Rumble Backup On, then set QuestZDoom's own Quake Haptics level to 0. Step 4's rumble still comes, as a
   short flat buzz. (not yet headset-confirmed)
10. Comfort Preset -> Comfort. Comfort Vignette, Min SlowMo Ease and Photosensitive Mode change together.
    Change one by hand: the preset row reads Custom. (not yet headset-confirmed)
11. Load RSQ_HPBars.pk3. Colour Blind Mode -> High Contrast: HP bars switch to the high-contrast set.
    Photosensitive Mode On: the bar's hit flash is dimmer and slower.
12. Load RSQ_Score.pk3. Text Size 2: the score display grows.
13. Load RSQ_Grapple.pk3. Comfort Vignette Medium: swinging on a rope darkens the view edge.
14. One-Handed On, bind Grab Pull, load RSQ_DistanceGrab.pk3. The button does the wrist-flick pull.
15. Load RSQ_GunCards.pk3 or RSQ_SlowMo.pk3, change some of their settings, then **Reset Every Series Mod**.
    Their settings go back to default; Accessibility's stay. (not yet headset-confirmed)
16. Steady Hands (On by default), with RSQ_LaserSight loaded: hold the dot on a far wall. It shakes less than
    with Steady Hands Off. (not yet headset-confirmed)
17. Seated Play -> Seated (or Auto: Measure Standing Height standing, then sit down), with RSQ_TacticalRig loaded:
    the holsters hang from your seated eyes, in reach. (not yet headset-confirmed)
18. Slower Taps On, with RSQ_Wheel loaded: a slower double tap of the wheel button still brings the last gun
    back. (not yet headset-confirmed)

## Works with

Accessibility is a shared service: other mods read it, it does not change them.

- **Read by**: RSQ_DistanceGrab, RSQ_Gestures, RSQ_Grapple, RSQ_GunBonsaiVR, RSQ_LaserSight, RSQ_Saber,
  RSQ_Score, RSQ_ShieldSaw, RSQ_SlowMo, RSQ_TacticalRig, RSQ_HPBars, RSQ_Wheel, RSQ_Whip (each carries the
  series' helper that reads these settings only while this pk3 is loaded).
- **Not read by**: RSQ_GunCards, RSQ_Miniboss, RSQ_Grenade.
- Wired 2026-11-01 (not yet headset-confirmed):
  - Steady Hands (aiming only, never swings or throws): Wheel pointing, Grapple fire aim and aim dot,
    LaserSight dot and grenade arc, DistanceGrab's lock cone, Whip lock/mark aim, ShieldSaw throw aim,
    SlowMo's bullet catch, the Saber's lock painting and Force grip target.
  - Seated Play: Tactical Rig's body, ShieldSaw's mount, Wheel's wrist card, Gestures' Measure Me, Gun
    Bonsai VR's Guard pose.
  - Slower Taps: Wheel, Grapple, Whip, the Saber's keep-marks window, Gestures' two-hands window.
  - Rumble Strength: every direct rumble in Wheel, Grapple, LaserSight, DistanceGrab, Whip, ShieldSaw,
    Saber, SlowMo, Tactical Rig, Gestures and Gun Bonsai VR (fixed-strength pulses switch off at 0).
- What changes, by row (from the round-two notes):
  - Photosensitive Mode: saber clash bursts and flash light, grab catch blooms, shield block stars, Score
    flashes, laser pulse, HP bar hit flash, choke crackle.
  - Colour Blind Mode: HP bars, Score, Saber, Gun Bonsai VR HUD, and the mods that carry the series palette.
  - Cue Size: grab beam / dot / bloom, Force outline and lock diamonds, shield lock rings, laser dot and
    arc, HP-bar markers.
  - Text Size: SlowMo's label, Tactical Rig's prints, laser range readout, Score's display, Gun Bonsai
    VR screens.
  - Comfort Vignette: Grapple swings / reels / climbs / yanks, the Saber's Force jump.
  - Min SlowMo Ease: RSQ_SlowMo.
  - Gesture Ease: Distance Grab's palm roll, SlowMo's wrist cross, and other gestures.
  - Gesture buttons: Grab Pull / Reach -> DistanceGrab; Force Push / Pull / Grip -> Saber; Shield Throw
    -> ShieldSaw; Flick Reload -> ShieldSaw and Saber; Wrist Cross -> SlowMo.
  - Menus Simple: hides sub-pages on Grapple, SlowMo, Saber and others.
  - Handedness: Tactical Rig's cigarette pocket and holster hang, Gun Bonsai VR's HUD sides.
- Reads **RSQ_SlowMo** (when slow motion starts and stops, for Sound Cues).

## Known limits / open

- Everything from 2026-10-31 ran on the simulated rig only: Rumble Backup, Two-Hand Brace, Brace Cue,
  Reset Every Series Mod, Rumble Strength, Seated Play, Comfort Preset, Vignette on Knockback, Steady Hands,
  Slower Taps, Wake Cues.
- **Rumble Backup only reaches this pk3's own rumbles**: there is no shared "buzz" request yet, so the other
  mods' rumbles can't use the backup route.
- The Saber's deflect aim follows your head, which Steady Hands does not smooth.
- A grounded blast does not move a QuestZDoom VR body, so Vignette on Knockback fires on knockback in the
  air and long falls.
- Reset Every Series Mod works only from its menu row.

## Credits

`CREDITS.txt`, unchanged:

```
RSQ_Accessibility -- credits
============================

One shared Accessibility menu and settings for the Radiant Silvergun Quest series. For stock
QuestZDoom 17.3: ZScript and lumps only, no engine changes. The code is new, written for this pack.

WHAT THIS PK3 SHIPS, AND WHOSE IT IS
  The project owner (presidentkoopa)
      The design: one shared menu that detects which series mods are loaded, and the shared
      setting names (rsqa_colorblind, rsqa_handed).
  QuestZDoom (Emawind and Team Beef)
      The engine and its option menu classes, which the menu extends.

SHARING
  Free to share as part of the Radiant Silvergun Quest series.
```

From the old README and the code: colour-vision simulation in `tools/cvd.py` follows Machado 2009 and
Vienot 1999; the Steady Hands filter is the 1-euro filter (Casiez, Roussel, Vogel, CHI 2012).
