# RSQ Wheel

A weapon wheel for VR: a ring of weapon cards opens around your hand. Point either hand at a card and
let go of the button (or pull the trigger, or reach into the card) and that gun is in that hand. Rest the
beam on a card and a data sheet in the middle tells you about the gun: ammo, kills, shots, accuracy. A
slot with several guns fans them out. It is the owner's REMA weapon wheel (RS_WeaponSelectionSystem),
the ring only, brought to stock QuestZDoom 17.3.

Pk3: `pk3/RSQ_Wheel.pk3`.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
**RSQ_Wheel.pk3**

- Works on plain Doom 2 without Brutal Doom (run on freedoom2 on the rig). With BD22_VoxelPack the cards show
  the guns' pickup voxels; without it they show flat icons.
- Needs no other RSQ pk3 to work alone. Slowing time while the ring is open needs **RSQ_SlowMo**; without
  it time runs on unless you turn on Stop Time Without SlowMo.

## Setup

Customize Controls, section **RSQ Wheel** (also the Control rows on the Wheel's front page):

| Customize Controls name | Menu row | Default key | What it does |
|---|---|---|---|
| Wheel: hold, point, release | Hold, Point, Release | Left thumbstick click | Hold, point, let go to take. Tap: the ring stays up. Tap twice: back to the last gun. |
| Wheel: open | Open or Close | none | Tap to open, tap to close (either hand picks). |
| Wheel: main hand | Main Hand Wheel | `[` | Opens on the main hand. |
| Wheel: off hand | Off Hand Wheel | `]` | Opens on the off hand. |
| Wheel: cycle main-hand model / off-hand model | (not on the menu) | none | ModelSwapper only. |

A default key is only set when nothing else already uses it.

Menu: Options -> Radiant Silvergun Options -> **RSQ Wheel**. Pages: **Picking**, **Ring and Cards**,
**Data Sheet**, **Tuning and Debug** (Reset All is there).

## What to do in VR

- **Pick**: hold the thumbstick click, point either hand at a card, let go.
- **Pick at range**: point at a card and pull that hand's trigger.
- **Reach in**: put your hand into a card and press Use (or pull the trigger).
- **Pull a card out**: hand in a card, snap it back toward you.
- **Throw a gun back**: snap the hand holding a gun toward the ring (not at a card). The hand goes empty.
- **Two guns at once**: one hand on each card when you let go; each hand takes its own gun.
- **Compare**: one hand on each of two different cards; the sheet compares them side by side.
- **Open a fan**: rest the beam on a crowded slot's card, or press Use on it.
- **Arrange a slot**: on a fan card, hold the trigger, move onto another place in the fan, let go.
- **Last gun**: double-tap the wheel button.
- **Wrist card** (when on): bring a forearm up across your chest as if checking a watch.

## Features

Front page (RSQ Wheel):

| Row | Default | What it does |
|---|---|---|
| Weapon Wheel | On | The ring on or off. |
| Either Hand Picks | On | The hand on a card owns the beam; the other shows a dimmer beam and takes over when it is on a card. |
| Opens On | Whichever key you press | Which hand an empty-handed press opens on. |
| Palette | Standard | Standard, Doom, Hell, Tech. |
| Font | Ermac's digits | Status bar numerals, small gold / grey numerals, DoomFont only, Ermac's digits. |
| Ring Plates | Its own (Ermac style) | Or the status bar's stone. |
| Card Look | Colour by Gun | Colour by Gun (below) or Classic (the ring as it was before 2026-11-02). |
| Size | 1.0 | Ring size. |
| Sound | On | The ring's sounds. |
| Controller Rumble | 1.0 | Card ticks in the controller (QuestZDoom's own haptics switch still overrules it). |

Picking page:

| Row | Default | What it does |
|---|---|---|
| Two Hands Compare | On | Two different cards under two hands: side-by-side sheet. |
| Open on the Gun You Hold | Option (off) | The ring opens with your gun's card under your hand. |
| Wrist Card | Option (off) | The watch pose shows that hand's gun card over the wrist. RSQ Gun Cards' watch card takes over when it is loaded and on. |
| Open at Level Start | Option (off) | The ring opens when a level starts. |
| Slow Time While Open | On | With RSQ_SlowMo: the world slows while the ring is up. |
| Closing Ends My SlowMo | Option (off) | Slow motion you started before opening also ends when the ring closes. |
| Stop Time Without SlowMo | Option (off) | Without RSQ_SlowMo, the ring freezes the world itself while open. |
| Pull a Card Out (0 = off) | 1.5 | How hard a snap pulls a card out. |
| Throw a Gun Back (0 = off) | 2.6 | How hard a snap throws a gun back. |
| Reach In (0 = off) | 7.0 | How far in front of or behind a card your hand may be and still touch it. |
| Hold to Pick (tics) | 9 | |
| Double Tap: Last Gun (tics) | 10 | |
| Feel Each Gun's Weight | 1.0 | Card ticks shaped by the gun: light pistol, heavy BFG. |
| Ring Follows Past (degrees, 0 = off) | 45 | Turn away more than this and the ring swings round to stay in front. |
| Folds After (tics) | 140 | |
| Fold Warning (tics, 0 = off) | 25 | |
| Re-centre Window (tics, 0 = off) | 10 | The same key again this soon re-centres the ring instead of closing it. |

Ring and Cards page: Gun Models on Cards (On), Ammo Counts and Gauges (On), Ammo Readout (LED segments),
Hover Halo Breathes (Option, off), Edge Sweep (On), Colour Cards by Rarity (On), Mark Guns You Hold (On), Slot Number on Cards (On), Cards Face You (On),
Crowded Slot Opens As (Fan), Flash When You Take a Gun (On), Spark Colour (Slot colour), Hovered Card
Lights the Room (On), Background Stars (0 = off), Idle Shimmer (0), Taken Card Spins (360).

Data Sheet page: Show Data Sheet (On), Weapon Stats (On), Track Kills and Accuracy (On), Kills and Accuracy
This Level (Option, off), Gun Bonsai Level and Upgrades (On), Card When Pointing at a Gun (On), Compare With
the Gun You Hold (On), and readers for other mods, all On and silent when the mod is absent: LegenDoom
Rarity, LegenDoom Effects Row, DoomRL Arsenal Tier, DoomRL Mod Upgrades Row, Combined Arms Meters, Final
Doomer Set, MetaDoom Demon Keys, ModelSwapper, Lithium, Lithium RPG Stats (ACS). Also read with no row (on,
silent when absent): DOOM Infinite, Pandemonia (with Anarchy and Insurrection), Doomablo, Guncaster, BorderDoom.

### Colour by Gun (Card Look, on by default; owner's pick 2026-11-02, mock-ups A, B and C together)

- **Each gun its own colour.** Every card is washed in its gun's colour, with a bright rim, slot stripe and a boxed
  slot number in it. The colour is the one RSQ Gun Cards gives that gun (slot 2 gold, 3 red, 4 white, 5 green,
  6 teal, 7 blue; measured from Gun Cards' own panel art by `tools/gen_glow_art.py`), and it follows Gun Cards'
  Card Colour setting when Gun Cards is loaded (one colour for all, or By Ammo Type). A gun with a rarity tier keeps
  its tier colour (Colour Cards by Rarity). Ammo counts, on the cards and the sheet's ammo row, are in the ammo
  type's colour (Gun Cards' rule: bullets gold, shells red, rockets orange, cells cyan); a dry gun stays dry red.
- **Lit stone.** The plates are lit warm from the top in the gun's colour and shade cool toward the bottom (both
  Ring Plates choices). The data sheet's header is a filled band in the hovered gun's colour with the name light on
  it. A faint soft halo sits behind the ring and never changes.
- **Motion and light.** A halo in its colour sits behind the hovered card (it breathes only with Hover Halo
  Breathes, off by default). The beam's tip wears the series' lock-on mark (RSQ ShieldSaw's: white centre, ring in
  the gun's colour). A spark runs round each card's edge (Edge Sweep). Idle Shimmer, above 0, gives every other
  card a slow soft halo too.
- **A calm hover (2026-11-02, after the owner's headset report).** The ring never changes size or place when you
  point at a card. Only the card you point at changes: it lights up in its colour, steps a little toward you and
  grows 6% (Hovered Card Grows), easing in over 4 tics and then holding still. A data sheet too tall for the middle
  of the ring shrinks to fit instead of pushing the ring out. Gone: the light that ran round the ring card to card
  (the "hexagon wire"), the halo behind the ring brightening in the hovered gun's colour, and the hovered card and
  its room light breathing. Saved settings are updated once on the first load (Hover Halo Breathes off, Hovered
  Card Grows 0.06).
- Colours are chosen when the ring opens or the hover changes; each tic only moves brightness and position.
- **Colour Blind Mode** (RSQ Accessibility, read when the ring opens; also in the Classic look): every card goes
  neutral (the series' grey) and only the hovered card is coloured, in the series' highlight colour for that
  mode (amber for protanopia / deuteranopia, red for tritanopia, yellow for high contrast); so are the beam, the
  room light, the card's halo, the mark and the sheet band. The sweep and mark stay: they carry the hover without
  colour.
- **Photosensitive Mode** (RSQ Accessibility): the breathing (when on) and the sweep at 40% strength, the sweep at
  half speed.

Always on (no row):

- **SHARES**: the sheet names the other guns you carry on the same ammo.
- **One hand on each card**: each hand takes its own gun at the release.
- **Fan, last used first**: a crowded slot shows the gun you used last on its card, the rest last-used first.
- **Dry click**: a gun with no ammo at all is not taken; you hear Brutal Doom's dry click (Doom's switch
  click without BD) and the hand keeps its gun.
- **Drag to arrange**: a slot you rearranged keeps that order (remembered; Reset All leaves it).
- **Ring clicks without quake rumble**: with QuestZDoom's Quake Haptics level at 0, card ticks still come as
  a flat short buzz.
- **Slows again while slow-mo eases out**: with RSQ_SlowMo, opening the ring while slow motion is easing
  back slows time again.
- The ring holds you still while it is up.

Tuning and Debug page: ring distance, radius, height, lean, wrist roll, stick deadzone, card sizes and
effects, sparks, volume, model size and spin, sheet and wrist card sizes, palette / font by name, Print
Diagnostics on Open, Reset All.

## Test it

Load the order above plus RSQ_Wheel.pk3. Start MAP01 and pick up a few guns.

1. Hold the left thumbstick click. The ring opens round your hand. Point at a card, let go: that gun is in
   that hand.
2. Let go over nothing: the ring closes, gun unchanged.
3. Tap the button: the ring stays up. Point and pull the trigger: you get that gun.
4. Double-tap the button: that hand goes back to the gun it had before.
5. Point with the off hand: its beam takes over and the gun goes into the off hand.
6. Rest the beam on a card: the sheet shows rounds, reserve, kills, shots, accuracy. A gun on the same ammo
   as another lists it under SHARES. (SHARES: not yet headset-confirmed)
7. One hand on each of two different cards: the sheet compares them. Let go of the button: each hand takes
   its own gun. (each hand its own gun: not yet headset-confirmed)
8. Hand into a card, snap it toward you: you pull that gun out. Snap a gun-holding hand toward the ring:
   the gun files away and the hand goes empty.
9. Rest on a slot with several guns: they fan out; the last one you used is on the slot's card. (last-used
   first: not yet headset-confirmed)
10. On a fan card, hold the trigger, move onto another place, let go: that gun keeps the new place next
    time. (not yet headset-confirmed)
11. Pick a gun with no ammo at all: you hear a dry click and keep your gun. (not yet headset-confirmed)
12. Turn your head 90 degrees away: the ring swings round to stay in front.
13. Set QuestZDoom's Quake Haptics level to 0. Card ticks still come as a short buzz. (not yet
    headset-confirmed)
14. Without RSQ_SlowMo: time runs while the ring is open. Turn on **Stop Time Without SlowMo**: the world
    freezes while it is open. (not yet headset-confirmed)
15. Turn on **Open on the Gun You Hold**: the ring opens with your gun's card under your hand. (not yet
    headset-confirmed)
16. Turn on **Kills and Accuracy This Level**: the sheet adds a LEVEL row; it starts at zero on the next
    level. (not yet headset-confirmed)
17. Turn on **Wrist Card** (Picking): forearm across the chest, the gun's card shows over the wrist.
18. Palette and Font: each choice changes the ring at once.
19. Reset All (Tuning and Debug).

Card Look (2026-11-02, rig only: **not yet headset-confirmed**):

30. Open the ring. Each card is in its gun's colour (pistol gold, shotgun red, chaingun white, rocket launcher
    green, plasma teal, BFG blue) with a boxed slot number in that colour; the counts are gold, red, orange, cyan.
31. Point at a card: it lights up in its own colour with a halo behind it, a diamond mark sits where the beam
    meets it, the sheet's header is a band in its colour. No wire runs round the ring.
32. Point at one card, then another: the ring stays exactly the same size and place; only the card you point at
    grows a little and holds still.
33. A small spark runs round every card's edge. Edge Sweep off: gone. Hover Halo Breathes on: the halo breathes.
34. Card Look -> Classic, reopen the ring: the ring as it was before the Card Look (with the calm hover).
35. RSQ_GunCards loaded, its Card Colour -> By Ammo Type, reopen: the cards take the ammo colours, the same as
    the gun cards on your wrist.
36. RSQ_Accessibility, Colour Blind Mode -> Deuteranopia, reopen: grey cards; only the one you point at is amber.
37. RSQ_Accessibility, Photosensitive Mode on: the sweep is fainter and slower.

With other mods:

20. RSQ_SlowMo: opening the ring slows the world; closing it lets it go. Open it again while slow motion
    is easing back: it slows again. (easing case: not yet headset-confirmed)
21. RSQ_LaserSight: with the ring up, the idle hand shows only the laser, not two beams.
22. RSQ_TacticalRig: a holstered gun's sheet has a HOLSTER row (not run with a gun really holstered).
23. Gun Bonsai 0.10.6 + RSQ_GunBonsaiVR: the sheet shows level and upgrades; the comparison has a BONSAI row
    (not run on the rig: Gun Bonsai was not there).
24. RSQ_GunCards with its Watch Card on: the Wheel's Wrist Card stands down.
25. RSQ_Gestures: while the ring is open, Gestures names no thrusts or punches.
26. Load RSQ_Accessibility (Steady Hands on). Point at a card and hold still: the highlight stays on that card and
    does not flicker to its neighbour. Steady Hands off: as before. **(not yet headset-confirmed)**
27. Accessibility's Slower Taps on: a tap a little longer than before still leaves the ring up, and a slower double
    tap still brings the last gun back. **(not yet headset-confirmed)**
28. Accessibility's Seated Play Seated, sitting down: the watch pose still shows the Wrist Card.
    **(not yet headset-confirmed)**
29. Accessibility's Rumble Strength 0: the ring's ticks stop. 2: stronger. **(not yet headset-confirmed)**

## Works with

- **RSQ_SlowMo** (read): slows the world while the ring is up; knows when slow motion is easing.
- **RSQ_LaserSight** (read): hides the ring's idle beam where the laser draws.
- **RSQ_TacticalRig** (read): HOLSTER row on the sheet.
- **RSQ_GunBonsaiVR** (read, with Gun Bonsai 0.10.6): level, upgrades, BONSAI row, wrist card level.
- **RSQ_GunCards**: when its watch card is on, the Wheel's Wrist Card stands down. Gun Cards follows the
  Wheel's palette, font set and ring plates. The Card Look follows Gun Cards' colours: its slot colours are measured
  from Gun Cards' panel art, and its Card Colour setting (`rsqgc_color`, read by name) is honoured when loaded.
- **RSQ_Gestures** asks the Wheel whether it is open, and stays quiet while it is.
- ModelSwapper: names the model a gun wears; the trigger on the sheet swaps to its Models page.
- **RSQ_Accessibility** (read, by name; nothing changes without it):
  - Steady Hands (on in Accessibility): the beam that points at cards, the other hand's compare aim and Card When
    Pointing at a Gun use the smoothed hand. Reaching into a card, pulling a card out and throwing a gun back stay on
    the raw hand. Steady Hands off: exactly as before.
  - Seated Play: the Wrist Card's watch pose is measured from your seated eyes.
  - Slower Taps: Hold to Pick, Double Tap: Last Gun and the Re-centre Window are 1.5x longer.
  - Rumble Strength: every ring rumble x0 to x2 (0 = none).
  - Colour Blind Mode (`rsqa_colorblind`, through `wr_CB` from `Accessibility/tools/cb_template.zs`): neutral cards,
    the hovered one in the series' highlight colour (Card Look above).
  - Photosensitive Mode (`rsqa_photosafe`, `wr_A11y.Photo`): the Card Look's breathing and sweep tamed.

## Known limits / open

- Everything from 2026-10-31 ran on the simulated rig only: SHARES, two-hand pick, fan last-used first, dry
  click, drag to arrange, Open on the Gun You Hold, Kills and Accuracy This Level, clicks at quake rumble 0,
  own freeze option, slowing again while slow-mo eases out. The older README also says the Wheel as a whole
  was "not yet on a headset": gesture speeds and the wrist pose are first guesses.
- SHARES names were cut to 10 characters after the rig check; check the sheet reads well.
- Not run on the rig: the HOLSTER row with a gun really holstered, the Gun Bonsai rows.
- No painted card faces, no room effects (laser fog, light sweep, floor marks): these need the REMA engine.
  Their settings are not on the menu on purpose.
- The ring is drawn per tic (35 a second), not per frame.
- The RSQ_Accessibility wiring (Steady Hands, Seated Play, Slower Taps, Rumble Strength, 2026-11-01) ran on the
  simulated rig only (loads clean with and without it; a pick with Steady Hands on still took the gun).
- Smoother (owner's pick 40, 2026-11-01): the billboard groups and the colour cache are looked up by key instead of
  scanned, and each card's basis is worked out once a tic and reused by the hit tests (camera-facing ones still turn
  to each caller, as before). No behaviour change: on the rig 8100 ray and touch tests against a copy of the old code
  matched exactly, and a scripted point-and-pick took the same gun. The cost of a tic with the ring open did not move
  measurably on the rig (handler time 1.18 -> 1.24 ms, within run-to-run noise); one hit test got about 15% cheaper.

- Card Look (2026-11-02) ran on the simulated rig only. Seen there in frames: the colours, plates, halo, mark,
  sweep, sheet band, Colour Blind Mode and Classic.
- Calm hover (2026-11-02) ran on the simulated rig only, **not headset-confirmed**: on doom2 and on the full BD
  order the ring's radius, centre and every other card's size stayed the same across no hover and two different
  hovered guns (before the fix an eight-row sheet moved the radius 9.87 -> 11.01 and the hovered card swung
  1.0x-1.2x); frames show the wire and the halo swell gone. A crowded slot still fans out when you rest on it
  (Open a fan): that is its own feature, not the ring resizing. Not seen: how the breathing and sweep feel in a
  headset (the rig dumps stills), and Photosensitive Mode's effect (numbers only). A custom palette (Palette row)
  does not recolour gun colours: they are Gun Cards' colours, not palette roles.

## Credits

`CREDITS.txt`:

```
RSQ Wheel -- credits
====================

The wheel is the project owner's (presidentkoopa): RS_WeaponSelectionSystem, written for his
UZDXREMA (REMA) engine and spun out of RS_VR_Unified. This is that ring, brought to stock
QuestZDoom 17.3 for the Radiant Silvergun Quest series.

QuestZDoom: Emawind and Team Beef -- the engine, and the off-hand weapon and hand-pose script API
the ring reads.

The art it draws is the IWAD's own, referenced by lump name and never copied: STBAR (the card and
sheet plates), STCFN033-095 (DoomFont), STTNUM0-9, STTMINUS, STTPRCNT (the numerals).

The quake-wave route to the controllers' rumble is the series' (RSQ ShieldSaw's SSQ_Buzzer).

Sounds (sounds/wr_*.ogg) came across with the wheel from REMA.

The ring's own plates and digits (graphics/WRE*.png, tools/gen_ring_art.py) are drawn from Ermac's Force
Unleashed holo HUD art in tools/card_art/, used with the owner's blessing (his doom-force-unleashed devbuild,
models/common). The cards on the guns that use the rest of that art are now their own mod, RSQ Gun Cards.

The Card Look's lock-on mark (graphics/WRLKRB.png, WRLKCB.png) is the series' own, copied from RSQ ShieldSaw
(sprites/SSQRB0.png, SSQCB0.png). Its other art (graphics/WREPLATG, WRECHIP, WREHALO, WREDISC,
WRESPARK, WRSHADE) is drawn by tools/gen_glow_art.py; its gun colours are measured from RSQ Gun Cards' panel art.
```

## Appendix: for builders

- `zscript/wheel/zscript.zs` -- REMA's ring (changes marked `RSQ:`)
- `zscript/wheel/wr_q_shim.zs` -- billboards, reflection stubs, VR hooks for stock QZD
- `zscript/wheel/wr_q_look.zs` -- palettes and font sets; `WRPALS.txt`, `WRFONTS.txt` (any pk3 can add a
  palette or font set with its own WRPALS / WRFONTS lump)
- `zscript/wheel/wr_q_watch.zs` -- the wrist card
- `zscript/wheel/wr_q_gunlook.zs` -- the Card Look (Colour by Gun): Gun Cards' colours, and the ring's added parts
  (an `extend class wr_Rig`; the hooks in zscript.zs are marked `RSQ GL:`)
- `zscript/wheel/wr_cb.zs` -- the series' colour-blind palette (`Accessibility/tools/gen_cb.sh wr`)
- `tools/gen_glow_art.py` -- the Card Look's art (graded plate, slot box, halos, spark, the copied
  lock-on mark) and its Gun Cards colour table
- `tools/gen_assets.py` -- writes the quad models, TEXTURES and the palette table
- `tools/rig/` -- the rig runner and probe (test only)
- `WHEEL_WORK_QUEUE.md` -- the owner's queued REMA wheel work (not started).
