# RSQ Accessibility
### Doom Arcade VR · one page of settings for the whole series: see it, hold it, sit down, play with one hand

One page under Radiant Silvergun Options holds the series' shared settings: colour-blind colours, calmer flashes,
bigger cues and text, which hand is your main hand, smoother aim, slower taps, a comfort vignette, seated play, rumble
strength, and buttons for the moves that normally need a second hand. Most of these settings do their work inside the
other RSQ mods. Each mod reads them by name, so a mod you have not loaded is not affected, and every mod still plays
alone. This pack also does a few things itself: arrows round your view for hits and shots you cannot see, a slow-motion
label, the vignette, and the series' gesture reader (the watch check and the two-hand gestures).

*[GIF to come: an imp firing from behind, the red arrow at the edge of the view, then turning to face it]*

---

## What it feels like

- **Your colours.** Colour Blind Mode moves the series' cues onto colours your eyes can tell apart, the same three
  colours in every mod.
- **Calmer flashes.** Photosensitive Mode keeps every series flash and pulse to 2.5 a second or less, and strong
  flashes at 40% brightness.
- **Bigger, if you want it.** Cue Size scales the series' dots, rings, glows and markers (x0.5 to x3). Text Size
  scales the series' HUD text (x1 to x3).
- **Hits you cannot see.** With Sound Cues on, a hit or a shot from out of view shows as an arrow round the middle of
  your view, pointing to where it came from, and a short rumble on that side.
- **Steadier aim.** Steady Hands smooths small shakes out of your hands for the mods that aim, and lets fast swings
  through.
- **Sit down.** Seated Play tells the series you are sitting, so belts, guards and holsters come down with you.
- **One hand.** One-Handed gives you a button that lets your main hand play the off hand's part, and buttons for the
  off-hand gestures.
- **Easier gestures.** Gesture Ease widens the series' gesture windows and lowers their speeds. Slower Taps gives
  every tap and double-tap half again as long.
- **Less sick.** The Comfort Vignette darkens the edge of your view while a rope or a Force jump throws you around.

---

## How to play

Open *Options → Radiant Silvergun Options → Accessibility* and set what you need. Almost everything is off until you
turn it on. Two rows are on from the start: **Steady Hands** (On) and **Seated Play** (Auto).

| Do this | What happens |
|---|---|
| Set **Sound Cues** to Visual, Rumble or Both | Hits and shots from out of view show as arrows and / or a rumble on that side; slow motion starting and stopping is labelled and / or felt |
| Set **Comfort Vignette** to Light, Medium or Strong | The edge of your view darkens while a series mod says you are being thrown around |
| Set **Handedness** to Left-Handed | QuestZDoom's own Control Scheme is set to left-handed too, and the series lays out the body for a left-hander |
| Turn on **One-Handed**, bind **Off-Hand Modifier** and hold it | Your main controller plays the off hand's part while you hold it |
| Stand up straight and pick **Measure Standing Height** | Your standing eye height is saved, so Seated Play knows how far you have sat down |
| Turn on **Fit to My Body**, pick **Measure Me**, close the menu, stand tall, arms straight out | After 2 seconds your eye height and reach are measured for 1 second, and the gesture zones are scaled to your body |
| Hold your gun up in front of your face and turn the back of your wrist to you, as you check a watch | The watch check: a light tick in that hand, and the mods that use it answer (Gun Cards shows the card, Tactical Rig and Miniboss use it with Use) |
| Turn on **Two-Hand Gestures** and sweep both hands down past your hips together | "both hands down" is recognised (RSQ Melee's Ground Pound uses it) |

**No keys are bound for you.** The One-Handed buttons are on this page and in Customize Controls, under
"RSQ Accessibility". They only do anything while **One-Handed** is on.

---

## Controls

- **Keys: nine, none bound for you.** Off-Hand Modifier (held), Grab Pull, Grab Reach (held), Force Push, Force Pull,
  Force Grip (held), Shield Throw, Flick Reload, Wrist Cross. Bind them on this page (One Hand) or in Customize
  Controls, under "RSQ Accessibility". They do nothing while **One-Handed** is off. The series' keys pass (2026-11-10)
  kept all nine: they are how a one-handed or seated player does the gestures.
- **Hands and buttons.** This pack fires, grabs and throws nothing itself, so it takes no trigger, grip or Use of its
  own. Its one button read: while a trigger is held, no hand counts as palm out. The Off-Hand Modifier hands the off
  hand's part to your main controller while you hold it.
- **Gestures it reads** (for the other mods): the watch check, in either hand; the four two-hand gestures (both hands
  down, both hands apart, both palms out, both palms thrust); and punches and gun-butt shoves, by name only.
- **Menu buttons:** Measure Standing Height, Measure Me, Reset All and Reset Every Mod. No key of this pack became a
  menu button.

---

## Seeing

### Colour Blind Mode

Off, Protanopia, Deuteranopia, Tritanopia or High Contrast. The series uses three roles for its cues: idle (searching,
nothing found), could (noticed, you could take it) and have (taken, locked, yours). With a mode set, every mod that
carries the series' colour table draws those roles in that mode's colours:

| Mode | Idle | Could | Have |
|---|---|---|---|
| Protanopia, Deuteranopia | grey | amber | azure |
| Tritanopia | grey | red | cyan |
| High Contrast | dim grey | yellow | magenta |

The table (`tools/cb_template.zs`) says each pair was checked with `tools/cvd.py` (Machado 2009 / Viénot 1999,
CIEDE2000). This pack's own off-view arrows use the same colours: a hit in the "have" colour, a shot coming in the
"could" colour.

*[Image to come: the same scene with Off, Deuteranopia and High Contrast]*

### Photosensitive Mode

Off by default. On: in the mods that read it, a strong flash starts at most every 14 tics (2.5 a second), and is drawn
at 40% of its brightness. Pulses and flickers are capped at 2.5 cycles a second. Some mods drop a flash or a fast
sparkle altogether (see Plays well with). The numbers follow WCAG 2.3.1 (no more than 3 flashes in any second), as
the code says.

### Cue Size and Text Size

**Cue Size** (1.00, from 0.50 to 3.00): the series' dots, rings, glows and markers, and this pack's off-view arrows.
**Text Size** (1.00, from 1.00 to 3.00): the series' HUD text and Gun Bonsai VR's screens, and this pack's
slow-motion label and gesture names. At 1.5 and above, the series' centre-screen messages use the big font.

---

## Hands

### Handedness

**Follow QuestZDoom** (the default), **Right-Handed** or **Left-Handed**.

Which controller is your main hand belongs to QuestZDoom, and no mod can move the main gun to the other controller. So
choosing Right- or Left-Handed here also sets QuestZDoom's Control Scheme: Right-Handed sets it to the right-handed
scheme, and Left-Handed sets it back to the left-handed scheme you last used (A or B; A if you never used one). Follow
QuestZDoom leaves the engine alone.

The series reads Handedness only for body layout that no hand owns: the Tactical Rig's cigarette pocket and the way
holstered guns hang, and which side Gun Bonsai VR's HUD panels sit on.

If you change the Control Scheme in QuestZDoom's own menu afterwards, that is the newer choice: the next time the game
starts, Handedness goes back to Follow QuestZDoom.

### Steady Hands

On by default. Both hands' positions and directions go through a 1-euro filter (Casiez, Roussel and Vogel, CHI 2012):
it smooths a still hand hard and lets a fast one through almost untouched. The mods that aim with your hands use the
smoothed pose: Distance Grab, Laser Sight's dot, Grapple, Whip, ShieldSaw and the Wheel. Off, they use the raw pose.
The filter's numbers come from `tools/steady_sim.py`, a simulation (3 mm tremor at 6 Hz and 1.5 mm noise; a 0.6 m
swing in 5 tics): the shake drops to about a quarter, with at most a fifth of a tic of lag on the swing. That is a
simulation, not a measurement of real hands.

### Slower Taps

Off by default. Every tap and double-tap window in the series that reads it is half again as long (x1.5).

### Hold to Toggle

Off by default. Held inputs become press-on, press-off: this pack's Off-Hand Modifier, Grab Reach and Force Grip
buttons, RSQ Grapple's Fire Hook key and the Saber's Force trigger. (Since the 11-10 keys pass the Whip has no key and
ShieldSaw locks by holding the trigger, so neither has a held key to toggle.)

### Gesture Ease

0.0 by default, up to 1.0. At 1.0, gesture tolerances (angles, reaches, gaps) are twice as wide and gesture speeds and
hold times are halved; in between, in proportion. It applies in the mods that read it: Distance Grab, ShieldSaw,
SlowMo's wrist cross, Grapple, Whip and the Saber, and in this pack's own gesture reader:

- **The watch check:** the box wider every way (the nearest distance halved), the gun's tilt allowed wider (at most
  90 degrees), the hand allowed to move faster and drift further; the twist needed to start and to stay, and the
  hold, lower.
- **The two-hand gestures:** the 120 ms "together" window and the chest's reach wider; the speeds, the straightness
  shares, the palms' distance ahead, their gap, their upward pitch and their hold lower. The hip and chest lines are
  where your body is, so they do not move.
- **Punches:** the punch speed lower.

The Test and Debug sliders show the values before the ease.

---

## One hand

Turn on **One-Handed**, then bind the buttons you need. With One-Handed off, none of them does anything.

- **Off-Hand Modifier** (held): while you hold it, your main controller plays the off hand's part. The off hand's
  aim, gestures and buttons come from the main controller, and the main hand reads no gestures of its own. A light
  tick in the main hand tells you it changed (a little stronger going on than off).
- **Gesture buttons**, each for a move that is normally a gesture:

| Button | What it does | Read by |
|---|---|---|
| Grab Pull | Distance Grab's wrist flick: pulls what a hand has locked | RSQ Distance Grab |
| Grab Reach (held) | Distance Grab's palm out, held | RSQ Distance Grab |
| Force Push | The Force push | RSQ Saber |
| Force Pull | The Force pull | RSQ Saber |
| Force Grip (held) | The Force grip | RSQ Saber |
| Shield Throw | ShieldSaw's forward flick | RSQ ShieldSaw |
| Flick Reload | The flick reload | RSQ ShieldSaw, RSQ Saber |
| Wrist Cross | Turns slow motion on or off | RSQ SlowMo |

The Force jump is already a button (Jump, held), so it has none here.

---

## Comfort

### Comfort Vignette

Off, Light, Medium or Strong. Darkens the edge of each eye's view while a series mod reports a comfort moment: a
Grapple or Whip swing, reel, climb or yank in the air (stronger the faster you move), and a Saber Force jump. It eases
in over 0.2 s and out over 0.4 s so it never snaps. It is drawn per eye by QuestZDoom as a post-process pass, so it
stays on your view with no lag.

| | Edge darkness | Starts darkening |
|---|---|---|
| Light | 55% | 62% of the way from the middle of the eye to its corner |
| Medium | 75% | 48% |
| Strong | 92% | 34% |

**Vignette on Knockback** (Off): the vignette also comes on when you are thrown (your speed jumps by more than 8 map
units a tic in one tic, to over 12) and stays while you fly, for up to 3 seconds; and on a long fall (falling faster
than 10 map units a tic). It needs Comfort Vignette set.

*[GIF to come: a grapple swing with Comfort Vignette on Medium, seen from inside the headset view]*

### Slow-Mo Ease

0.0 s by default, up to 2.0 s. RSQ SlowMo eases into and out of slow motion over at least this long (0 keeps
SlowMo's own ease).

### Seated Play

**Auto** (the default), **Standing** or **Seated**. Seated tells the series you are sitting; Auto decides from your
headset height.

- **Your seated eyes** follow the highest your headset has been lately, easing down 2 cm a second, rising at once, and
  dropping straight to the headset once it has stayed 0.20 m lower for a second.
- **Your standing height** is the one saved by **Measure Standing Height**. Without it, it is the tallest steady
  headset height seen since the map began or the game was loaded (held within 3 cm for a second). On Seated, with
  nothing better known, it is taken as at least 1.62 m.
- **Auto** calls you seated once your eyes have been 0.25 m or more below standing for 2 seconds, and standing again
  once they have been within 0.15 m for 1 second. Auto uses only your own heights, so a short player standing is not
  called seated; until it has seen you stand (or you measured), it says standing. If you start a map sitting, Auto
  cannot tell until you stand once: use Measure Standing Height, or Seated.
- **While you are DOWN** (RSQ SlowMo's Be Quick or Be Dead), Auto does not switch either way: DOWN crouches only the
  in-game view, so ducking for real while down is not sitting. It picks up again when you get up. Without SlowMo,
  nothing changes.

What the series does with it: Tactical Rig hangs its belt and holsters from your seated eyes; Melee lowers its Guard
pose; the Wheel lowers its eye line; ShieldSaw brings its shield mount down; Measure Me adds the drop back so the gesture zones fit your
standing body.

---

## Cues and rumble

### Sound Cues

Off, **Visual**, **Rumble** or **Both**.

- **A hit on you** from a monster or anything else, and **a shot coming at you** (a monster's missile within 20
  degrees of heading at you and within 2048 map units, or a monster's hitscan aimed at you). Visual: an arrow round the
  middle of the view pointing to where it came from, for 1.2 s, fading. A hit is a filled red chevron with a bar
  across; a shot coming is an open amber chevron. No arrow while the source is within 35 degrees of where you look.
  Rumble: a short rumble on the controller on that side when the source is more than 40 degrees off where your body
  faces. A burst of shots from one monster is one arrow, renewed.
- **Slow motion starting and stopping** (RSQ SlowMo). Visual: "Slow Motion" in light blue near the top of the view
  while it lasts, then "Normal Speed" in grey, fading over a second. Rumble: both controllers, a longer rumble starting
  and a shorter one stopping.
- **Ready to grip** (Rumble): a short tick on the Force hand when the Saber's Force Grip finds a new target.

**Wake Cues** (Off; needs Sound Cues): a monster within 1536 map units that wakes up aimed at you, teleports (jumps
more than 96 units while moving under 20 a tic), or teleports in beside a teleport fog, also gets a cue: a grey
double chevron and a short rumble on that side.

*[Image to come: the three arrow kinds round the view]*

### Rumble Strength and Rumble Backup

**Rumble Strength** (1.0, from 0.0 to 2.0): every series rumble is multiplied by this; 0 is no rumble at all.

**Rumble Backup** (Off): QuestZDoom's Quake Haptics setting at 0 silences the rumble route the series uses. With
Rumble Backup on, the series' rumbles come as the engine's shot buzz on that controller instead: every one feels the
same, but you feel them. That is this pack's own cues (the off-view and wake cues, the slow-motion cues, the modifier
tick, the brace cue), the watch-check tick, the "ready" tick the Saber's Force Grip asks for, and (since 2026-11-10)
the rumbles of every series mod that loads with this pack: RSQ Saber, ShieldSaw, Melee, SlowMo, Tactical Rig, Whip,
Distance Grab, Grenade and Flash and Flare. Each asks this pack by name as one of its rumbles starts; on its own, or
with Rumble Backup off, it rumbles exactly as before. A mod's rumbles come at most one buzz a controller every 5 tics
(the buzz is 150 ms long). RSQ Wheel and RSQ Grapple already buzz this way by themselves; RSQ Distance Grab's pulse
setting too. The earthquakes of RSQ Monsters (Brutal Doom's) and RSQ Grenade's explosions shake you, they are not a
mod's rumble, and are not covered.

---

## Two-hand brace

QuestZDoom's Two Handed Weapons setting latches a brace when you press the off-hand grip with your hands close
together, and while it is latched the off-hand gun goes dead: it does not fire and is not drawn.

- **Two-Hand Brace** (QuestZDoom's): **Off** turns QuestZDoom's Two Handed Weapons off and keeps your own value;
  **QuestZDoom's** puts that value back. If you turn Two Handed Weapons on again in QuestZDoom's own menu, the next
  start puts this row back to QuestZDoom's.
- **Brace Cue** (Off; Rumble, Sound, Both): the moment the brace latches with a gun in your off hand (one that uses
  ammo; a fist on the gun is the two-handed hold itself), a rumble on the off hand and / or Doom's switch click.

---

## Gestures

This pack carries the series' gesture reader (it was the separate pk3 RSQ Gestures until 0.99a). It reads your hands
only while a mod has asked about them in the last second, while Two-Hand Gestures is on, or while you are measuring.
Distances are metres from your eyes, in your own frame, so a tall, short or seated player makes the same gesture.

### The watch check

Hold the gun up in front of your face, still, and turn your wrist as you would to check a watch. Held for 6 tics, it
counts, and a light tick plays in that hand (**Tick When Ready**, On). It drops when the wrist turns back under 20
degrees. The drop is always at least 5 degrees under the start: if Twist Off is set at or above Twist On, Twist On
minus 5 is used, so the pose cannot flicker at the edge.

- **Watch Check** (On): Off switches the pose off; the mods that use it then fall back to their own.
- **Wrist Turn** (Watch Side): which way the wrist must turn: **Watch Side** (the back of the wrist to your face),
  **Palm Up**, or **Either Way**.
- **Watch Check Twist (deg)** (35, from 20 to 90): how far the wrist must turn to start.
- The box it must be in (Test and Debug): from 0.30 m below to 0.20 m above your eyes, 0.15 to 0.65 m in front, at most
  0.35 m to either side; the gun pointing at most 60 degrees up or down; the hand slower than 1.2 m a second.

*[GIF to come: the watch check with the Gun Cards card appearing]*

### Two-hand gestures

**Two-Hand Gestures** (Off) switches the four on; each has its own row under it (all On). A mod that uses one (RSQ
Melee's Ground Pound and Clear Out) keeps them read while it asks, even with this row off.

| Gesture | Row | What it takes (defaults) |
|---|---|---|
| Both hands down | Both Hands Down | Both hands swept down past your hips (0.60 m below your eyes), each at 2.0 m/s, mostly downward |
| Both hands apart | Both Hands Apart | Both hands thrown apart from within 0.50 m of your chest (0.40 m below your eyes), the gap opening at 2.0 m/s |
| Both palms out | Both Palms Out | Each hand at least 0.25 m in front of your eyes, pointing at least 40 degrees up, at least 0.25 m apart, held 400 ms |
| Both palms thrust | Both Palms Thrust | Both hands driven forward at 2.5 m/s, mostly forward, pointing at least 20 degrees up, never while braced |

The two hands must move within 120 ms of each other (x1.5 with Slower Taps), and the same gesture waits 500 ms
before it can fire again. QuestZDoom reads no fingers, so "palm out" is read as a hand pointing up and not pulling a
trigger.

### The rest

- **Fit to My Body** (Off) and **Measure Me**: 2 seconds after you pick Measure Me (time to close the menu and stand
  tall, arms straight out to your sides), your eye height and reach are measured for a second. The zones then scale
  from the body the defaults were set for (eyes 1.60 m high, reach 0.70 m), between x0.6 and x1.4. Measuring turns
  Fit to My Body on.
- **Show Gesture Names** (On): a small grey line low in the view names each gesture as it is recognised ("watch check
  (main)", "jab (off)", "gun-butt shove (main)", "both hands down"...), half-transparent, gone in 1.5 s. Text Size
  makes it bigger.
- **Quiet:** while RSQ Grapple says you are on the rope, or RSQ Wheel is open, and for a quarter second after, no punch,
  shove or two-hand gesture is read.
- The reader also names punches (jab, hook, uppercut) and gun-butt shoves, but no series mod asks it for them now
  (RSQ Melee reads its own). Only the names show.

---

## Menus

- **Menus** (Full): **Simple** takes the "Test and Debug" link off every series mod's front page (and RSQ Monsters'
  "Monster Diagnostics" link), so each front page is its everyday switches and nothing else. Full puts them back.
  Nothing is deleted. This page is not touched.
- **Reset All** (asks first): every setting on this page and its Test and Debug page goes back to its default.
  Handedness, Two-Hand Brace, your Measure Me body and your Measure Standing Height are kept.
- **Reset Every Mod** (asks first): runs the Reset All row of every loaded RSQ mod's page, as that mod runs it.
  Accessibility is kept. The console says how many were reset.

---

## Plays well with

Every mod below finds this pack by name. Without it, a setting left in your ini does nothing, and each mod plays as it
always has.

- **RSQ Distance Grab:** Colour Blind Mode colours; Photosensitive Mode dims its laser bursts to 40%, spaces them 14 tics
  apart and slows its flashing and its "tell" pulse to a cycle of at least 14 tics; Cue Size scales its beam, dot and
  rim; Gesture Ease lowers the flick angle and widens the palm and door-palm tolerances and the palm's pitch; Steady
  Hands smooths its aim; Rumble Strength; One-Handed: Grab Pull launches a locked item, Grab Reach holds the palm, and
  the Off-Hand Modifier moves the off hand's grab to the main controller.
- **RSQ Laser Sight:** Colour Blind Mode colours; Photosensitive Mode caps its lock and headshot pulses at 2.5 a second
  and dims its sparks; Cue Size scales the dot, glow, arc and bent beam; Text Size scales the range readout; Steady
  Hands smooths the dot's line (the beam stays on the gun as drawn).
- **RSQ Grapple** and **RSQ Whip:** the Comfort Vignette while you swing, reel, climb or are yanked in the air; Hold to
  Toggle for Grapple's Fire Hook key; Slower Taps for their tap; Gesture Ease widens the reach for grabbing the rope; Steady
  Hands smooths their aim; Cue Size (Whip's marks); Text Size (Grapple's messages); the Off-Hand Modifier; Colour
  Blind Mode; Rumble Strength.
- **RSQ Saber:** the Comfort Vignette on a boosted Force jump; Force Push, Force Pull and Force Grip buttons and Flick
  Reload; the Off-Hand Modifier holds the Force up from the main hand; Hold to Toggle latches the Force trigger;
  Gesture Ease lowers its throw and Force gesture speeds and widens the grip cone; Sound Cues' ready tick on the
  Force hand; Photosensitive Mode drops its 17.5-a-second sparkle and gates and dims its bursts; Cue Size; Text Size
  for the training remote's text; Slower Taps; Colour Blind Mode; Rumble Strength.
- **RSQ ShieldSaw:** Shield Throw and Flick Reload buttons; Gesture Ease (throw speed
  and forward share, the flick reload, the zones); Seated Play brings its shield mount down with your eyes; Steady
  Hands smooths the aim its locks and throw share; Photosensitive Mode dims and gates its flashes; Cue Size scales its lock marks; Colour Blind Mode; Rumble Strength.
- **RSQ SlowMo:** Seated Play on Auto waits while you are DOWN (asked by name: SlowMo's `down`); Slow-Mo Ease; Wrist Cross button; Gesture Ease for the wrist cross (the gap and the hold);
  Photosensitive Mode calms its HUD, its countdown and its plate (no flash ring, still trails); Text Size for its
  countdown; Colour Blind Mode; Rumble Strength. Sound Cues read its slow motion.
- **RSQ Tactical Rig:** Handedness sets the body layout (the cigarette pocket, the way holstered guns hang); Seated
  Play hangs the rig from your seated eyes and skips its standing-height learning; Text Size for its ammo digits and
  messages; Photosensitive Mode makes the cigarette ember and the lighter glow steady instead of pulsing; Colour Blind
  Mode; Rumble Strength. Its Watch Check Move (its own row) uses the watch check: Use while the watch check is held
  moves the gun to your other hand.
- **RSQ Melee:** the two-hand gestures: both hands down is Ground Pound, both palms thrust is Clear Out, both hands
  apart is the Guard's Absorb and Release (without this pack it reads them itself with a copy of the same reader); Seated Play lowers the Guard; the Off-Hand Modifier; Rumble Strength.
- **RSQ Wheel:** Slower Taps for its double-tap, hold and recenter windows; Steady Hands for pointing at cards; Seated
  Play lowers its eye line; Photosensitive Mode softens its breathing and sweep to 40% and halves the sweep's speed;
  Colour Blind Mode greys the cards and colours only the hovered one; Rumble Strength. While it is open, gestures are
  quiet.
- **RSQ Gun Cards** and **RSQ Miniboss:** the watch check (Gun Cards shows the card; Miniboss uses it with Use to call
  a Bossfight). Miniboss: Photosensitive Mode steadies its pulses; Text Size for its HUD.
- **RSQ Score:** Photosensitive Mode dims its reward flashes to 40%, spaces them 14 tics apart and turns off its
  whole-view flashes; Text Size scales its HUD and wrist digits; Colour Blind Mode swaps its bonus rows' family colours and marks the next life with an icon.
- **RSQ VisualRewards:** Photosensitive Mode fades kill rewards, calms its words, beams and damage numbers, and dims
  and gates its health-bar flash; Cue Size scales its health-bar icons; Colour Blind Mode.
- **RSQ Gun Bonsai VR:** its two-hand fist upgrades (Ground Pound, Clear Out, Absorb and Release, Taunt) are offered
  when this reader or RSQ Melee's copy of it is there; Text Size scales its screens; Handedness sets which side its HUD panels sit on;
  Photosensitive Mode calms its gauges and turns off its HUD colour cycle; Colour Blind Mode.
- **RSQ Grenade:** no chain-reaction screen shake with Photosensitive Mode on or a Comfort Vignette set.
- **RSQ Graveyards:** Photosensitive Mode holds the gravestones' pulse steady.
- **RSQ Monsters:** Menus: Simple hides its "Monster Diagnostics" link.
- **Reset Every Mod** and **Menus: Simple** reach every series page under Radiant Silvergun Options.

---

## Options

*Options → Radiant Silvergun Options → Accessibility.* One page, with Test and Debug below it. Defaults in brackets.

| Section | Rows |
|---|---|
| Seeing | Colour Blind Mode (Off; Protanopia, Deuteranopia, Tritanopia, High Contrast) · Photosensitive Mode (Off) · Cue Size (1.00; 0.50 to 3.00) · Text Size (1.00; 1.00 to 3.00) |
| Hands | Handedness (Follow QuestZDoom; Right-Handed, Left-Handed) · Steady Hands (On) · Slower Taps (Off) · Hold to Toggle (Off) · Gesture Ease (0.0; 0.0 to 1.0) |
| One Hand | One-Handed (Off) · Off-Hand Modifier · Grab Pull · Grab Reach · Force Push · Force Pull · Force Grip · Shield Throw · Flick Reload · Wrist Cross (keys, none bound) |
| Comfort | Comfort Vignette (Off; Light, Medium, Strong) · Vignette on Knockback (Off) · Slow-Mo Ease (s) (0.0; 0.0 to 2.0) · Seated Play (Auto; Standing, Seated) · Measure Standing Height |
| Cues and Rumble | Sound Cues (Off; Visual, Rumble, Both) · Wake Cues (Off) · Rumble Strength (1.0; 0.0 to 2.0) · Rumble Backup (Off) |
| Two-Hand Brace | Two-Hand Brace (QuestZDoom's; Off) · Brace Cue (Off; Rumble, Sound, Both) |
| Gestures | Watch Check (On) · Wrist Turn (Watch Side; Either Way, Palm Up) · Watch Check Twist (deg) (35; 20 to 90) · Tick When Ready (On) · Two-Hand Gestures (Off) · Both Hands Down (On) · Both Hands Apart (On) · Both Palms Out (On) · Both Palms Thrust (On) · Fit to My Body (Off) · Measure Me · Show Gesture Names (On) |
| Menus | Menus (Full; Simple) |
| (bottom) | Test and Debug · Reset All · Reset Every Mod |
| Test and Debug | Debug Log (Off). Watch Check: Twist On (35 deg) · Twist Off (20 deg) · Hold (6 tics) · Below Eyes (0.30 m) · Above Eyes (0.20 m) · Nearest (0.15 m) · Furthest (0.65 m) · To the Side (0.35 m) · Gun Tilt Max (60 deg) · Hand Still (1.2 m/s) · Drift Allowed (0.05 m) · Tick Strength (0.35). One Hand: Still Under (0.30 m/s). Both Hands: Together (120 ms) · Peak Age (180 ms) · Refire (500 ms) · Down Speed (2.0 m/s) · Down Straightness (0.50) · Hips Below Eyes (0.60 m) · Apart Speed (2.0 m/s) · Chest Below Eyes (0.40 m) · Apart From Chest (0.50 m) · Palms Ahead (0.25 m) · Palms Held (400 ms) · Palms Up (40 deg) · Palms Apart (0.25 m) · Thrust Speed (2.5 m/s) · Thrust Straightness (0.60) · Thrust Palms Up (20 deg). Punch and Shove: Punch Speed (2.0 m/s) · Punch Repeat (6 tics) · Uppercut Rise (0.50) · Punch Kept (300 ms) · Shove Share (0.60). Gesture Debug Log (Off; Events, Events + Hands, Events + Hands + Cost) |

**Watch Check Twist (deg)** on the main page and **Twist On** on Test and Debug are the same setting.

*[Image to come: the Accessibility page]*

---

## Status

| | |
|---|---|
| **rig only, not headset-confirmed** (2026-11-10, the batched rig test) | Every launch loaded every RSQ pk3, this one included, with no script error from our packs, on doom2, brutal22test6, BD_VoxelPack, BD22 VR Reloaded 2.0.4f, LOB, Champions, Gun Bonsai and the series (`design/rigtest_2026-11-10/RESULTS.md`). Those launches came before the 11-10 fixes below. No setting on this page was exercised in them (the packed batch, next row, exercised some) |
| **rig only, not headset-confirmed** (2026-11-11, `design/rigtest_2026-11-10/RESULTS_SEATREMOTE.md`) | **Seated Play on Auto waits while you are DOWN** (RSQ SlowMo, asked by name: `down`). Standing at 1.60 m (reference learned 1.60), then DOWN (a lethal hit held at 1 HP, SlowMo answering `down` 1): the headset dropped 0.50 m to 1.10 for 3.8 s; the seated eyes followed it to 1.10 for 2.8 s and Auto stayed **standing** throughout. Head back up, the target killed, up (SlowMo `down` 0): the same 0.50 m drop was called **seated** 2 s after the seated eyes reached 1.10, and standing again 1 s after rising (`design/rigtest_2026-11-10/evidence/SEAT_DOWN_log.txt`). Not shown: the run without SlowMo (code: no SlowMo answer means not down) |
| **rig only, not headset-confirmed** (2026-11-10 night, the packed batch: `design/rigtest_2026-11-10/RESULTS_P4.md` N7, `RESULTS_P1.md` N6 and M6) | **Seated Play on Auto** (N7, the 11-10 fix with no 1.62 m floor): a short player standing at 1.30 m from the start was never called seated; at 1.60 m a 0.15 m dip stayed standing; a sudden 0.50 m drop was called seated about 2 s later, and standing again about 1 s after rising (`design/rigtest_2026-11-10/evidence/P4_N7_seated_log.txt`). **Rumble Backup from RSQ Melee** (N6): with Rumble Backup on and Quake Haptics 0, Melee's guard soak, landed punches, the swat, Ground Pound and Clear Out each sent this pack's buzz to that hand's controller (log lines, `P1_C_log.txt`, `P1_B_log.txt`). **Two two-hand gestures** as RSQ Melee uses them: both hands swung down read as Ground Pound, both palms thrust as Clear Out (`P1_C_log.txt`) |
| **rig only, not headset-confirmed** (2026-11-09) | The pack loads with no script error or warning of its own on doom2, brutal22test6, BD_VoxelPack, BD22 VR Reloaded 2.0.4e, LOB 1.05, Champions, Gun Bonsai 0.10.6 and the rest of the series, and Accessibility is listed under Radiant Silvergun Options (log: `design/rigtest_2026-11-09/logs/main_A-G_I.log`). No setting on this page was exercised in that run. That run used BD22 VR 2.0.4e, not 2.0.4f |
| **rig only, not headset-confirmed, older build** (2026-10-31, as RSQ Gestures, on doom2, brutal22test6, BD_VoxelPack and BD22 VR Reloaded 2.0.3h + hotfix) | The gesture reader: jab, hook and uppercut named; a gun swing named a shove, not a punch; no punch while braced or with both hands together; quiet while the Wheel was open and while on the Grapple rope; the watch check entering, held, dropped, its tick reaching the right controller (0.24); Watch Check off answering "not answering"; both hands apart and both hands down; Measure Me (eyes 1.60 m, reach 0.62 m). Logs: `Accessibility/tools/rigtest_gestures/qolprobe/evidence_1031.txt`, `.../punchprobe/evidence_1031.txt`. The reader has changed since (the watch-check twist was 45 / 30 then, now 35 / 20; hand sync added 11-03; thrust and pull events removed), so this is not the current build |
| **Headset-confirmed** | Nothing recorded in the repo. (The old README said version 0.99 was played and confirmed in the headset; no log or owner note in the repo says which parts, and the gesture reader was folded in after that.) |
| **code only, not shown** | Everything else on this page: Colour Blind Mode, Photosensitive Mode, Cue Size, Text Size, Handedness and its Control Scheme switch, Steady Hands, Slower Taps, Hold to Toggle, Gesture Ease, One-Handed and its buttons, the Comfort Vignette and Vignette on Knockback, Slow-Mo Ease, Seated Play other than Auto, and Measure Standing Height, Sound Cues and Wake Cues, Rumble Strength, Rumble Backup for the mods not named above, Two-Hand Brace and Brace Cue, the current watch check and the other two-hand gestures, Fit to My Body, Show Gesture Names, Menus: Simple, Reset All, Reset Every Mod, and every "Plays well with" line |
| **code only, not shown** (fixed 2026-11-10, commit d8c79eb2) | A code read found these; each is fixed in code and only load-checked (no error from this pack on doom2, brutal22test6, BD_VoxelPack, LOB 1.05, Champions, Gun Bonsai 0.10.6 and the series; BD22 VR was not in that load). None was exercised. **Rumble Backup** now also covers the watch-check tick (it goes through this pack's rumble route), and its text says what it covers: this pack's rumbles and the Saber's ready tick, not other mods'. **Gesture Ease** now applies to this pack's watch check, two-hand gestures and punches. **Sound Cues' "ready"** text says only the Saber's Force Grip sends it. **Menus: Simple** knows RSQ Monsters and RSQ Graveyards, so "Monster Diagnostics" is hidden. **Reset All** keeps your Measure Standing Height. **Twist Off** is held at least 5 degrees under Twist On. **Measure Me** says "RSQ Accessibility". **Gesture names** follow Text Size |
| **not yet run** | Nothing. The batch's checks for this pack, N6 and N7, have run (above) |
| **rig only, not headset-confirmed** (2026-11-10) | **Rumble Backup for every series mod**: on the rig (no rumble there; the log of the route is the evidence) RSQ SlowMo's slow-motion rumbles sent this pack's buzz the same tic on both controllers with Rumble Backup on and Quake Haptics 0, and none with Rumble Backup off or Quake Haptics 0.8; left-handed, the left controller is the main hand (design/rigtest_2026-11-10/evidence/RUMBLE_SM_*). RSQ Melee's calls were shown too (N6, above). The other mods' calls are the same helper: code only, load-checked |
| **Known open** (from reading the code) | **Rumble Backup's buzz is a real (0.1-unit, harmless) player trace** on the machine whose player it is, so other mods' "a hitscan is starting" hooks see it there (RSQ Gun Bonsai VR's hitscan bracket, cleared each tic): single-player it is nothing, in a netgame it is the one part that is not the same on every machine. RSQ Whip's Hold to Toggle code (its old hook keys) has no key to act on since the 11-10 keys pass |

Code comments say several things were measured on the rig (Handedness trading the two hands' poses, the brace
latching with a fist, the watch-check wrist direction on 11-02, the hands drifting while walking on 11-03, the Hold to
Toggle save fix and the slow-motion label fix on 10-31), and a commit message (2026-11-06) says the watch check held at
a roll of -22.8 degrees with the new numbers. Those logs are not in the repo, so they are not counted here. The test
scripts `Accessibility/tools/rigtest/qol.sh` and `sweep.sh` exist; their output is not in the repo either.

---

## Under the hood

- **Stock QuestZDoom 17.3:** ZScript and data only, no engine changes. No other mod is required. Every other mod is
  found by name while the game runs, never linked.
- **How the series knows this pack is loaded:** it looks for the class `RSQA_Menu`. A mod that does not find it reads
  every setting as off, so a value left in the ini does nothing on its own.
- **Settings:** the `rsqa_*` settings are server settings (single-player VR; the userinfo has a size limit); the
  gesture settings `rsqg_*` are your own; `rsqa_debug` is not saved. Each mod reads them through its own copy of
  `tools/a11y_template.zs` (the `<PREFIX>_A11y` class) and the colours through its copy of `tools/cb_template.zs`
  (`<PREFIX>_CB`), written by `tools/gen_a11y.sh` and `tools/gen_cb.sh`.
- **Engine settings it changes, from the menu only:** Handedness sets `vr_control_scheme` (kept in `rsqa_left_scheme`
  for the way back); Two-Hand Brace sets `vr_two_handed_weapons` (kept in `rsqa_brace_keep`).
- **Buttons:** each One-Handed key sends the local console event `rsqa_key <code> <down>`, checked on the machine that
  pressed (One-Handed, Hold to Toggle), which sends one network event: `rsqa_mod <0|1>` for the modifier, `rsqa_alt
  <code> <0|1>` for the gesture buttons (1 Grab Pull, 2 Grab Reach, 3 Force Push, 4 Force Pull, 5 Force Grip, 6 Shield
  Throw, 7 Flick Reload), or RSQ SlowMo's `rsm_toggle` for the Wrist Cross. Series mods hear `rsqa_alt` in their own
  network handlers. Measure Standing Height is the console event `rsqa_measure`; Measure Me is the network event
  `rsqg_measure`; the two-hand gestures go out as `rsqg_pair <kind> <hundredths of m/s>`.
- **`RSQA_Service`** (by name): `GetInt` / `GetIntData("swap", "", player)` (1 while the main hand plays the off hand),
  `"steady"` (Steady Hands on), `"seated"` (that player is seated); `GetInt("vignette", source, player, strength)` (a
  comfort moment this tic, strength 0 to 1; the strongest wins); `GetInt("ready", "", player, hand)` (a ready tick);
  `GetDouble` / `GetDoubleData("steady", "x"|"y"|"z"|"angle"|"pitch"|"roll"|"dx"|"dy"|"dz", player, hand)` (the
  smoothed pose; `GetDouble` brings the filter up to this tic first), `"seated.drop"`, `"seated.eye"`, `"stand.eye"`
  (metres), `"rumble"` (Rumble Strength), `"taps"` (1.5 or 1.0).
- **`RSQG_Service`** (by name, the gesture reader): `"inspect"` (0 not, 1 entering, 2 held; -1 with Watch Check off),
  `"inspect.tics"`, `"inspect.any"`, `"pair.ago"` (asking keeps the two-hand gestures read), `"mainleft"`, `"braced"`,
  `"braced.tics"`, `"punch"`, `"punch.kind"`, `"punch.speed"`, `"shove"`, `"quiet"`;
  `GetDouble("hand.x"|"hand.y"|"hand.z"|"hand.roll"|"hand.pitch"|"punch.speed", "", hand)`. In the series today, Gun
  Cards, Tactical Rig and Miniboss ask `"inspect"` and Melee asks `"pair.ago"`; the rest are asked by the rig probes in
  `tools/rigtest_gestures`. (`"still"`, `"thrust"`, `"palms"`, `"punch.ago"`, `"shove.ago"` and `"shove.speed"` went
  on 2026-11-10: nothing in the repo asked for them.)
- **The hands:** QuestZDoom writes the controllers only when it renders a frame. `RSQG_HandSync` carries each frame's
  controller offset to where the body is this tic, so a still hand on a walking body is not read as a swing. The eyes
  are rebuilt from the headset height; the vertical is scaled by the level's pixel stretch (1.2) before any comparison.
- **The vignette** is the post-process shader `RSQA_Vignette` (`shaders/pp/rsqa_vignette.fp`), switched on only while
  it has something to show.
- **Rumble** is `A_QuakeEx` waves re-issued every tic on one controller (X the left, Y the right), scaled by
  QuestZDoom's Quake Haptics level and by Rumble Strength. Rumble Backup at Quake Haptics 0 sends a 0.1-unit trace that
  touches nothing, which makes the engine buzz that hand once (150 ms) (`RSQA_Buzz.Backup`). Series mods reach it by
  name: `RSQA_Service` `GetInt("buzz", prefix, playerNumber, 1 left / 0 right controller)` as a rumble starts (their
  copy of `tools/a11y_template.zs`, `RumbleBackup`); only the machine whose player it is sends the buzz.
- **Event handlers:** `RSQG_HandSync`, `RSQA_Handler` (buttons, vignette, cues, brace cue), `RSQA_QoL` (Steady Hands,
  Seated Play, knockback, wake cues), `RSQA_MenuMode` (Simple / Full), `RSQG_Handler` (the gesture reader).
- **Radiant Silvergun Options:** this pack carries the series' shared menu pieces (`zscript/rsqa_rsmenu.zs`,
  generated from `tools/rsmenu`): one "Radiant Silvergun Options" row however many series pk3s load, its pages in the
  series' order.
- **Saves:** the modifier, the Hold to Toggle latches, the cue memory and the filters are not saved; a modifier held
  across a save is let go after the load.
- **Single player:** cues, the vignette and rumble are for the console player only. QuestZDoom has no netplay.

---

## Credits

The full list is in **CREDITS.txt**.

- **presidentkoopa:** the project, the design of one shared menu that finds the loaded series mods, the shared setting
  names, and RS_Gestures (written for his UZDXREMA engine), whose one-hand and both-hands detectors, settings and
  event shape the gesture reader is ported from.
- **QuestZDoom** (Emawind and Team Beef): the engine and its option menu classes, which the menu extends.
- **The 1-euro filter:** Casiez, Roussel and Vogel (CHI 2012), behind Steady Hands.
- **Colour checks:** Machado 2009 and Viénot 1999 colour-vision models, CIEDE2000 (`tools/cvd.py`).
- **The code** is new, written for this pack. The gun-butt shove's blow, its slow motion and the F.E.A.R. Effect moved
  to RSQ Melee on 2026-11-01; their credits are in its CREDITS.txt.
