# RSQ Accessibility (RSQ Accessibility)

**The one thing:** one settings page every mod in the series reads: handedness, seated play, Steady Hands,
colour-blind colours, and one Reset for all of them.

One shared Accessibility page for the whole Radiant Silvergun Quest series: colour-blind colours, left- or
right-handed play, photosensitive mode, one-handed play, a comfort vignette, bigger cues and text, sound cues
you can see or feel, and one Reset for every series mod. For stock QuestZDoom 17.3, in VR. It needs no other
pk3. On its own only a few rows do something you can see; the rest work through the other series mods, which
read these settings when this pk3 is loaded and behave as before when it is not.

Pk3: `pk3/RSQ_Accessibility.pk3`. Works on plain Doom 2 with or without Brutal Doom.

## Features

- **One menu.** Options -> Radiant Silvergun Options -> **Accessibility**. Every loaded series mod has its own
  row on Radiant Silvergun Options beside it.
- **Colour Blind Mode.** Protanopia, Deuteranopia, Tritanopia or High Contrast colours across the series.
- **Handedness.** Right- or Left-Handed. Choosing one also sets QuestZDoom's own Control Scheme, so the gun
  moves to that controller; the series mods lay out holsters, pockets and HUD sides for that hand. The
  left-handed scheme you were using (A or B) is remembered and put back.
- **Photosensitive Mode.** The series' flashes, flickers and pulses come at most about 2.5 times a second, and
  strong flashes at 40 % brightness.
- **One-Handed play.** An Off-Hand Modifier button: while held, your main controller plays the off hand's part.
  Gesture Buttons: a button for each gesture the series asks for (grab pull, grab reach, Force push, pull and
  grip, shield throw, flick reload, wrist cross), so you press instead of moving.
- **Gesture Ease.** Gestures up to twice as forgiving: wider angles, lower speeds, shorter holds.
- **Hold to Toggle.** Buttons you would hold latch on a press and let go on the next press.
- **Comfort.** A Comfort Vignette (Light, Medium or Strong) darkens the edge of your view while a series mod
  moves you: a grapple swing, reel, climb or yank, a boosted Force jump. Vignette on Knockback adds a big
  knockback and a long fall. Min SlowMo Ease keeps every slow-motion ease from being shorter than you like. One
  Comfort Preset row sets the three together.
- **Seated Play.** Standing, Seated, or Auto (seated once your eyes sit 0.25 m or more below standing for 2 s;
  standing again once within 0.15 m for 1 s). Measure Standing Height stores where your standing eyes are.
- **Steady Hands.** A tremor filter on both hands' pointing, offered to the series' aiming (never to swings or
  throws). On by default.
- **Slower Taps.** Every tap and double-tap window in the series is 1.5x longer.
- **Cue Size and Text Size.** The series' dots, rings, glows and markers x0.5 to x3; its HUD text x1 to x3.
- **Sound Cues.** Visual: an arrow round the middle of the view for a hit on you, or a shot coming at you, from
  out of view, and a "Slow Motion" / "Normal Speed" label when slow motion starts and stops. Rumble: the
  controller on that side buzzes; both controllers at slow motion's start and stop; a short buzz when a series
  mod says a lock or grab is ready. Wake Cues add a monster waking at you, or teleporting in, out of view: a grey
  double chevron and a rumble on its side.
- **Rumble Strength and Rumble Backup.** Every rumble this pk3 sends x0 to x2 (0 is none). Rumble Backup keeps
  those rumbles coming when QuestZDoom's Quake Haptics level is 0, as the engine's own short shot buzz.
- **Two-Hand Brace.** Off turns QuestZDoom's Two Handed Weapons off, so gripping near your gun never latches the
  brace that kills the off-hand gun. QuestZDoom's puts your own value back. Brace Cue tells you the moment the
  brace latches with a gun in the off hand: a rumble, Doom's switch click, or both.
- **Menus.** Simple hides the series pages' niche sub-pages, so each front page is the everyday switches only.
- **Reset All** for this page (Handedness and Two-Hand Brace are kept) and **Reset Every Series Mod**, which
  runs every loaded series mod's own Reset All (Accessibility is kept).

## How to play

Open Options -> Radiant Silvergun Options -> Accessibility. Most rows take effect at once.

**Left-handed.** Set Handedness to Left-Handed. The gun moves to your left controller and the series mods
follow it. Right-Handed moves it back. Follow QuestZDoom leaves the engine's own setting alone. If you later
change QuestZDoom's Control Scheme in its own menu, the newer choice wins and Handedness reads Follow QuestZDoom
on the next start.

**One-handed.** Turn One-Handed On, then bind the buttons in Customize Controls, section **RSQ Accessibility**
(or on the Accessibility page and its Gesture Buttons page). No button is bound by default. They work only while
One-Handed is On.

- **Off-Hand Modifier**: hold it and move your main hand; it acts as your off hand. You feel a tick on the main
  controller as the hand changes parts, and a lighter one as it changes back. With Hold to Toggle On, one press
  swaps, the next press swaps back.
- **Grab Pull** and **Grab Reach** (Distance Grab): press Grab Pull instead of the wrist flick; hold Grab Reach
  instead of holding your palm out.
- **Force Push**, **Force Pull**, **Force Grip** (the Saber's Force): press instead of the Force gesture; hold
  Force Grip for as long as you would hold the grip.
- **Shield Throw** (ShieldSaw): press instead of the forward flick.
- **Flick Reload** (ShieldSaw and the Saber): press instead of the flick.
- **Wrist Cross** (SlowMo): press instead of crossing your wrists.

**Seated.** Stand up straight and pick Measure Standing Height. Then set Seated Play to Seated, or leave it on
Auto and sit down: after two seconds the series treats you as seated and brings things like the Tactical Rig's
holsters down to your seated eyes. Stand up again and Auto puts them back.

**Comfort.** Pick Comfort Preset -> Comfort for the lot (Comfort Vignette Medium, Min SlowMo Ease 1 s,
Photosensitive Mode On), or set each row yourself. The preset row reads Custom when the three match neither
preset.

**Cues.** Set Sound Cues to Visual, Rumble or Both. Let a monster shoot you from behind: an arrow appears at
the edge of your view on that side, and the controller on that side buzzes. Turn on Wake Cues too and a monster
waking at you out of view gives a grey double chevron and a rumble.

**Reset.** Reset All on this page asks first, then resets this page. Reset Every Series Mod asks first, then
runs every loaded series mod's own Reset All and prints how many it reset.

## Settings

Options -> Radiant Silvergun Options -> **Accessibility**.

| Menu row | Default | What it does |
|---|---|---|
| Colour Blind Mode | Off | Off / Protanopia / Deuteranopia / Tritanopia / High Contrast colours across the series. |
| Handedness | Follow QuestZDoom | Right-Handed or Left-Handed also sets QuestZDoom's Control Scheme. The left-handed scheme you used (A or B) is remembered. |
| Photosensitive Mode | Off | Series flashes, flickers and pulses at most about 2.5 a second; strong flashes at 40 % brightness. |
| One-Handed | Off | Turns on the Off-Hand Modifier and the Gesture Buttons. |
| Off-Hand Modifier | (no bind) | Held: your main controller plays the off hand's part. |
| Gesture Buttons | page | The button for each gesture (see below). |
| Gesture Ease | 0.0 | 0 to 1: gestures up to twice as forgiving (wider angles, lower speeds, shorter holds). |
| Hold to Toggle | Off | Held buttons latch on a press and let go on the next press (the modifier, Grab Reach, Force Grip, and the series' held binds). |
| Comfort Preset | Off | Off, or Comfort = Comfort Vignette Medium + Min SlowMo Ease 1 s + Photosensitive Mode On. Reads Custom when the three match neither. |
| Comfort Vignette | Off | Off / Light / Medium / Strong dark edge during a comfort moment a series mod reports (grapple swings, reels, climbs, yanks; a Force jump). |
| Vignette on Knockback | Off | The vignette also on a big knockback and a long fall. Needs Comfort Vignette above Off. |
| Min SlowMo Ease | 0.0 | 0 to 2 s: no slow-motion ease shorter than this (0 = SlowMo's own). |
| Seated Play | Auto | Standing / Seated / Auto. |
| Measure Standing Height | row | Stores your standing eye height (at least 1.62 m). |
| Steady Hands | On | Smooths both hands' pointing for the series' aiming. |
| Slower Taps | Off | Every tap and double-tap window in the series x1.5. |
| Cue Size | 1.00 | Series dots, rings, glows and markers, x0.5 to x3. |
| Text Size | 1.00 | Series HUD text, x1 to x3. |
| Sound Cues | Off | Off / Visual / Rumble / Both: hits and shots from out of view, slow motion starting and stopping, lock or grab ready. |
| Wake Cues | Off | Sound Cues also mark a monster waking or teleporting in out of view. Needs Sound Cues above Off. |
| Rumble Strength | 1.0 | Every rumble from this pk3 x0 to x2 (0 = none). |
| Rumble Backup | Off | With QuestZDoom's Quake Haptics level at 0, this pk3's rumbles still come, as the engine's short shot buzz on that controller. |
| Two-Hand Brace | QuestZDoom's | Off turns QuestZDoom's Two Handed Weapons off; QuestZDoom's puts your own value back. |
| Brace Cue | Off | Off / Rumble / Sound / Both the moment the brace latches with a gun in the off hand. |
| Menus | Full | Simple hides the series pages' niche sub-pages. |
| Reset All | row | Resets this page (keeps Handedness and Two-Hand Brace). Asks first. |
| Reset Every Series Mod | row | Runs every loaded series mod's own Reset All. Accessibility is kept. Asks first. |

**Gesture Buttons** (a page; the same rows are in Customize Controls under RSQ Accessibility; no default binds)

| Menu row | Default | What it does |
|---|---|---|
| Grab Pull | (no bind) | Distance Grab's wrist-flick pull. |
| Grab Reach | (no bind) | Held: Distance Grab's palm-out reach. |
| Force Push | (no bind) | The Saber's Force push. |
| Force Pull | (no bind) | The Saber's Force pull. |
| Force Grip | (no bind) | Held: the Saber's Force grip. |
| Shield Throw | (no bind) | The ShieldSaw's forward flick. |
| Flick Reload | (no bind) | The flick reload (ShieldSaw and the Saber). |
| Wrist Cross | (no bind) | SlowMo's toggle. |

## Works with

Accessibility is a shared service: other mods read it, it does not change them.

- **Read by**: RSQ Distance Grab, RSQ Gestures, RSQ Grapple, RSQ Gun Bonsai VR, RSQ LaserSight, RSQ Melee,
  RSQ Saber, RSQ Score, RSQ ShieldSaw, RSQ SlowMo, RSQ Tactical Rig, RSQ HP Bars, RSQ Wheel, RSQ Whip. Each
  carries the series' helper that reads these settings only while this pk3 is loaded.
- **Not read by**: RSQ GunCards, RSQ Miniboss, RSQ Grenade.
- **RSQ SlowMo**: Accessibility asks SlowMo whether slow motion is on, for the Sound Cues label and rumble.
  Wrist Cross sends SlowMo's own toggle.
- **The Gesture Buttons**: Grab Pull and Grab Reach go to Distance Grab; Force Push, Pull and Grip to the
  Saber; Shield Throw to the ShieldSaw; Flick Reload to the ShieldSaw and the Saber.
- **Handedness**: read by the Tactical Rig and Gun Bonsai VR for body layout no hand owns (the pocket, the way
  holstered guns hang, the HUD sides).
- **Seated Play**: the Tactical Rig reads it directly; the rest ask the service.
- **Menus Simple**: hides the sub-page links on the front pages of the Saber, ShieldSaw, Tactical Rig,
  Distance Grab, SlowMo, LaserSight, Grapple, Melee, Wheel, Score and HP Bars.

Gun Bonsai VR has no nodes that change Accessibility: it is never gated.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s. The RSQ pk3s load in any order
among themselves; Accessibility is first in the owner's order.

## Known limits

- Rumble Backup only reaches this pk3's own rumbles. The other mods' rumbles cannot use the backup route.
- The Saber's deflect aim follows your head, which Steady Hands does not smooth.
- A grounded blast does not move a QuestZDoom VR body, so Vignette on Knockback fires on knockback in the air
  and on long falls.
- Reset Every Series Mod works only from its menu row.
- The Gesture Buttons do nothing while One-Handed is Off.

## For other mods

Service class **RSQA_Service** (find it with `ServiceIterator.Find("RSQA_Service")`). Requests:

- `GetInt("swap", "", pn)` / `GetIntData("swap", "", pn)`: 1 while that player's main hand plays the off
  hand's part (One-Handed on and the modifier held or latched).
- `GetInt("vignette", source, pn, strength 0..1)`: report a comfort moment this tic; the strongest wins.
  Returns the Comfort Vignette level.
- `GetInt("ready", "", pn, hand)`: a lock / grab-ready cue on that hand (a short rumble when Sound Cues has
  Rumble).
- `GetIntData("steady", "", pn)`: 1 when Steady Hands is on. `GetDoubleData` / `GetDouble("steady", comp, pn,
  hand)`: the filtered pose; hand 0 main, 1 off; comp `x y z` (map units), `angle pitch roll` (degrees), `dx dy
  dz` (unit aim direction). Off: the raw pose.
- `GetIntData("seated", "", pn)`: 1 while that player is seated. `GetDoubleData("seated.drop" /
  "seated.eye" / "stand.eye", "", pn)`: metres.
- `GetDoubleData("rumble")`: the Rumble Strength multiplier, 0 to 2. `GetDoubleData("taps")`: 1.5 with
  Slower Taps, else 1.0.

Network events this pk3 sends, which series mods hear in their own NetworkProcess:

- `rsqa_mod <0|1>`: the Off-Hand Modifier held (or latched on) / let go.
- `rsqa_alt <code> <0|1>`: a gesture button, 1 press / 0 release. Codes: 1 Pull, 2 Reach (held), 3 Force
  Push, 4 Force Pull, 5 Force Grip (held), 6 Throw, 7 Reload. The Wrist Cross sends SlowMo's `rsm_toggle`.

The settings are server cvars named `rsqa_*`; a series mod reads them with `CVar.FindCVar` and keeps its own
behaviour when they are absent.

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

The colour-vision simulation in `tools/cvd.py` follows Machado 2009 and Vienot 1999. The Steady Hands filter is
the 1-euro filter (Casiez, Roussel, Vogel, CHI 2012).
