# Weapon Wheel (RSQ Wheel)

**The one thing:** a data sheet for every gun you own -- ammo, kills, shots, accuracy, Gun Bonsai level, what
the gun's own mod knows about it -- on a wheel that works with any weapon set you load.

A weapon wheel for VR: a ring of weapon cards opens around your hand. Point either hand at a card and let go
of the button (or pull the trigger, or reach into the card) and that gun is in that hand. Rest the beam on a
card and a data sheet in the middle of the ring tells you about the gun. A slot with several guns fans them
out. It runs on stock QuestZDoom 17.3 in VR, on plain Doom 2 or with Brutal Doom, and needs no other RSQ pk3.
With BD22_VoxelPack the cards show the guns' pickup voxels; without it they show flat icons. Slowing time
while the ring is open needs RSQ SlowMo; without it, time runs on unless you turn on Stop Time Without SlowMo.

Pk3: `pk3/RSQ_Wheel.pk3`.

## Features

**The ring.**
- One button: hold it, point either hand at a card, let go. Tap it and the ring stays up. Tap twice and the
  hand goes back to the gun it had before.
- Either hand picks: the hand on a card owns the beam; the other hand shows a dimmer beam and takes over when
  it is on a card.
- Pick at range with the trigger, or reach into a card with your hand. When both answer, the hand wins.
- Pull a card out: hand in a card, snap it back toward you. Throw a gun back: snap the hand holding a gun
  toward the ring, and the hand goes empty.
- Two guns at once: one hand on each card when you let go; each hand takes its own gun.
- A crowded slot fans out its guns (or spreads them as a constellation round the card), the gun you used last
  on the slot's card and the rest last-used first. On a fan card, hold the trigger and move it to another
  place in the fan; the slot keeps that order.
- Dry click: a gun with no ammo at all is not taken. You hear Brutal Doom's dry click (Doom's switch click
  without BD) and the hand keeps its gun.
- The ring follows you: turn away past an angle and it swings round to stay in front. It folds away on its
  own after a while, with a warning first.
- The ring holds you still while it is up.
- Slow time while open: with RSQ SlowMo the world slows while the ring is up and lets go when it closes.
  Opening the ring while slow motion is easing back slows it again. Without SlowMo, an option lets the ring
  stop the world itself.
- Options: open with your gun's card under your hand; open at level start; a wrist card.
- Gun models on the cards (the pickup voxels, turning), ammo counts and gauges with a low-ammo pulse, a mark
  on the guns you hold, slot numbers, a flash and a spin when you take a gun, one light on the hovered card,
  background stars, sparks.
- Card ticks in the controller, shaped by the gun's weight (a light pistol, a heavy BFG). With QuestZDoom's
  quake haptics at 0 they still come as a short flat buzz.
- Palettes (Standard, Doom, Hell, Tech), font sets (the status bar's numerals, small gold or grey numerals,
  DoomFont, Ermac's digits) and ring plates (Ermac style, or the status bar's stone). All the art is the
  WAD's own, by lump name.
- Grenade kinds: with RSQ Grenade, the grenade's card fans out the other kinds you own; pick one and it is
  the kind in hand.

**Colour by Gun** (the Card Look, on by default; Classic is the ring as it was).
- Each card is washed in its gun's colour with a bright rim, slot stripe and boxed slot number: the colour
  RSQ Gun Cards gives that gun (slot 2 gold, 3 red, 4 white, 5 green, 6 teal, 7 blue), following Gun Cards'
  Card Colour setting when Gun Cards is loaded. A gun with a rarity tier keeps its tier colour. Ammo counts
  are in the ammo type's colour (bullets gold, shells red, rockets orange, cells cyan); a dry gun stays dry
  red.
- Lit stone: the plates are lit warm from the top in the gun's colour and shade cool toward the bottom. The
  data sheet's header is a band in the hovered gun's colour. A faint halo sits behind the ring.
- A calm hover: the ring never changes size or place when you point at a card. Only the hovered card
  changes: it lights up in its colour, steps a little toward you and grows a little, then holds still. A
  halo sits behind it (it breathes only with Hover Halo Breathes). The beam's tip wears the series' lock-on
  mark. A spark runs round each card's edge (Edge Sweep). A sheet too tall for the ring shrinks to fit.

**The data sheet.** Rest the beam on a card:
- Rounds loaded and in reserve, the gun's stats (damage, rate of fire, accuracy, pellets, magazine) where the
  gun's own mod tells them, and kills, shots and accuracy counted by the Wheel itself as you play, on every
  weapon from any mod. An option adds the same counts for this visit to this level.
- SHARES: the other guns you carry on the same ammo.
- Compare: one hand on each of two different cards, and the sheet compares them side by side.
- Point at a gun on the floor and the sheet shows it, against what that hand holds.
- GUN BONSAI: level, progress and upgrades, with Gun Bonsai and RSQ Gun Bonsai VR loaded.
- HOLSTER: where the gun is holstered, with RSQ Tactical Rig.
- Readers for other weapon mods, each silent when its mod is absent: LegenDoom rarity and effects, DoomRL
  Arsenal tier and mod upgrades, Combined Arms meters, Final Doomer set, MetaDoom demon keys.

**The wrist card** (off by default). Bring a forearm up across your chest as if checking a watch, hold it a
moment, and a card stands over that wrist with the gun's name, rounds loaded and in reserve, its kills and hit
rate once it has been fired, and its Gun Bonsai level. Lower the arm and it folds away. When RSQ Gun Cards is
loaded with its watch card on, Gun Cards' card takes over.

## How to play

Bind the one button first: Customize Controls, section **RSQ Wheel**, **Wheel: hold, point, release**. The
left thumbstick click is the default when nothing else uses it. **Wheel: open** (tap to open, tap to close),
**Wheel: main hand** and **Wheel: off hand** (`[` and `]` when free) are there too; the front page of the
Wheel's menu has the same four rows.

1. **Pick.** Hold the button. The ring opens round your hand. Point either hand at a card and let go: that gun
   is in that hand. Let go over nothing and the ring closes, gun unchanged.
2. **Leave it up.** Tap the button instead of holding it. The ring stays. Point at a card and pull that hand's
   trigger to take the gun.
3. **Last gun.** Tap the button twice: that hand goes back to the gun it had before.
4. **Reach in.** Put your hand into a card and press Use, or pull the trigger. Snap the hand back toward you
   to pull the card out. Snap a hand that holds a gun toward the ring (not at a card) to throw the gun back:
   the hand goes empty.
5. **Two at once.** One hand on each of two cards when you let go: each hand takes its own gun. Rest both on
   two different cards first and the sheet compares them.
6. **Read the sheet.** Rest the beam on a card and the sheet in the middle fills in. Point at a gun on the
   floor and hold still a moment: its card comes up against the gun in that hand.
7. **Fans.** Rest the beam on a slot with several guns, or press Use on it: they fan out. On a fan card, hold
   the trigger, move onto another place in the fan, let go: the slot keeps that order.
8. **Re-centre.** Press the same hand's key again just after opening and the ring re-centres instead of
   closing. Turn more than 45 degrees away and it swings round to stay in front.
9. **Wrist card** (turn on Wrist Card under Picking): forearm up across the chest, wrist in front of your
   face, as if checking a watch.

The settings are in Options -> Radiant Silvergun Options -> **RSQ Wheel**: a front page and the pages
**Picking**, **Ring and Cards**, **Data Sheet** and **Tuning and Debug** (Reset All is there).

## Settings

Options -> Radiant Silvergun Options -> **RSQ Wheel**:

| Menu row | Default | What it does |
|---|---|---|
| Weapon Wheel | On | The ring on or off. |
| Either Hand Picks | On | The hand on a card owns the beam; the other takes over when it is on a card. |
| Opens On | Whichever key you press | Which hand an empty-handed press opens on: Whichever key you press, Main hand, Off hand. |
| Palette | Standard | Standard, Doom, Hell, Tech. |
| Font | Ermac's digits | Status bar numerals, Small gold numerals, Small grey numerals, DoomFont only, Ermac's digits. |
| Ring Plates | Its own (Ermac style) | Or Status bar stone. |
| Card Look | Colour by Gun | Colour by Gun, or Classic (the ring as it was). |
| Size | 1.0 | Ring size, 0.3 to 3.0. |
| Sound | On | The ring's sounds. |
| Controller Rumble | 1.0 | Card ticks in the controller, 0 to 2.0 (QuestZDoom's own haptics switch still overrules it). |
| Hold, Point, Release | Left thumbstick click | The one button (bind). |
| Open or Close | none | Tap to open, tap to close (bind). |
| Main Hand Wheel | `[` | Opens on the main hand (bind). |
| Off Hand Wheel | `]` | Opens on the off hand (bind). |

**Picking**:

| Menu row | Default | What it does |
|---|---|---|
| Two Hands Compare | On | Two different cards under two hands: a side-by-side sheet. |
| Open on the Gun You Hold | Off | The ring opens with your gun's card under your hand. |
| Wrist Card | Off | The watch pose shows that hand's gun card over the wrist. RSQ Gun Cards' watch card takes over when it is loaded and on. |
| Open at Level Start | Off | The ring opens when a level starts. |
| Slow Time While Open | On | With RSQ SlowMo: the world slows while the ring is up. |
| Closing Ends My SlowMo | Off | Slow motion you started before opening also ends when the ring closes. |
| Stop Time Without SlowMo | Off | Without RSQ SlowMo, the ring stops the world itself while open. |
| Pull a Card Out (0 = off) | 1.5 | How hard a snap pulls a card out, 0 to 4.0. |
| Throw a Gun Back (0 = off) | 2.6 | How hard a snap throws a gun back, 0 to 5.0. |
| Reach In (0 = off) | 7.0 | How far in front of or behind a card your hand may be and still touch it, 0 to 20. |
| Hold to Pick (tics) | 9 | A press held this long is a hold, not a tap, 3 to 35. |
| Double Tap: Last Gun (tics) | 10 | Two taps this close bring the last gun back, 0 to 20. |
| Feel Each Gun's Weight | 1.0 | Card ticks shaped by the gun: light pistol, heavy BFG, 0 to 1.0. |
| Ring Follows Past (degrees, 0 = off) | 45 | Turn away more than this and the ring swings round to stay in front, 0 to 120. |
| Folds After (tics) | 140 | The ring folds away on its own after this long, 35 to 700. |
| Fold Warning (tics, 0 = off) | 25 | The warning before it folds, 0 to 105. |
| Re-centre Window (tics, 0 = off) | 10 | The same key again this soon re-centres the ring instead of closing it, 0 to 35. |

**Ring and Cards**:

| Menu row | Default | What it does |
|---|---|---|
| Gun Models on Cards | On | The gun's pickup voxel turning on its card; a gun without one keeps its icon. |
| Ammo Counts and Gauges | On | The count and the gauge under each name. |
| Ammo Readout | LED segments | LED segments, LCD, punched out, or Lozenge badge. |
| Hover Halo Breathes | Off | The halo behind the hovered card breathes. |
| Edge Sweep | On | A spark runs round each card's edge. |
| Colour Cards by Rarity | On | A gun with a rarity tier takes its tier colour. |
| Mark Guns You Hold | On | A mark on the cards of the guns in your hands. |
| Slot Number on Cards | On | The slot number on each card. |
| Cards Face You | On | Cards turn to face you. |
| Crowded Slot Opens As | Fan | Fan, or Constellation (stars round the card). |
| Flash When You Take a Gun | On | A burst at the card you took. |
| Spark Colour | Slot colour | Slot colour, White hot, Rainbow. |
| Hovered Card Lights the Room | On | One light, on the hovered card only. |
| Background Stars (0 = off) | 0 | Stars behind the ring, 0 to 200. |
| Idle Shimmer | 0 | A slow soft halo on every card, 0 to 1.0. |
| Taken Card Spins (degrees) | 360 | How far the taken card spins, -720 to 720. |

**Data Sheet** (every reader is on by default and silent when its mod is absent):

| Menu row | Default | What it does |
|---|---|---|
| Show Data Sheet | On | The sheet in the middle of the ring. |
| Weapon Stats | On | Damage, rate of fire, accuracy, pellets, magazine. |
| Track Kills and Accuracy | On | Counted by the Wheel as you play, on every weapon. |
| Kills and Accuracy This Level | Off | A LEVEL row with the same counts for this visit to this level. |
| Gun Bonsai Level and Upgrades | On | With Gun Bonsai and RSQ Gun Bonsai VR loaded. |
| Card When Pointing at a Gun | On | Point at a gun on the floor and the sheet shows it. |
| Compare With the Gun You Hold | On | Against what that hand holds. |
| LegenDoom Rarity | On | The gun's rarity, in its colour. |
| LegenDoom Effects Row | On | Its legendary effects. |
| DoomRL Arsenal Tier | On | The assembly tier. |
| DoomRL Mod Upgrades Row | On | Its mod packs. |
| Combined Arms Meters | On | The four classes' meters. |
| Final Doomer Set | On | Which of the nine sets. |
| MetaDoom Demon Keys | On | The Unmaker's demon keys. |
| ModelSwapper | On | The model a gun wears (see Known limits). |
| Lithium | On | Lithium's weapon fields (see Known limits). |
| Lithium RPG Stats (ACS) | On | The only reader that calls another mod's own script; guarded. |

**Tuning and Debug** (every slider is live):

| Menu row | Default | What it does |
|---|---|---|
| Ring Distance Ahead | 34 | How far ahead of the hand the ring sits, 5 to 120. |
| Ring Radius | 5.0 | 1.0 to 40. |
| Height Above Hand | 2.0 | -8 to 12. |
| Lean Toward You | 12 | Degrees, -30 to 30. |
| Wrist Roll Spins the Ring | 0 | 0 to 1.0. Off by default: a controller reports a lot of roll just from how you hold it. |
| Stick Deadzone | 0.2 | 0.05 to 0.9. |
| Card Width | 4.2 | 1.0 to 12. |
| Card Height | 3.0 | 1.0 to 12. |
| Hovered Card Steps Out | 1.5 | 0 to 6. |
| Hovered Card Grows | 0.06 | 0 to 0.5. |
| Other Cards Fade To | 0.55 | 0.05 to 1.0. |
| Cards Grow In (tics) | 6 | 0 to 20. |
| Card Shadow | 0.32 | 0 to 1.0. |
| Shadow Offset | 0.35 | 0 to 1.5. |
| Face Parallax | 0.06 | 0 to 0.25. |
| Idle Breathing | 0.35 | 0 to 2.0. |
| Breathing Speed | 1.7 | 0.2 to 6.0. |
| Low Ammo Below (share) | 0.25 | The loaded share below which the gauge pulses, 0 to 0.9. |
| Low Ammo Pulse | 0.35 | 0 to 1.0. |
| Model Turn Speed | 1.5 | 0 to 6. |
| Model Size | 0.16 | 0.02 to 1.0. |
| Model Stand-Off | 3.0 | 0 to 12. |
| Flat Ring Up To (weapons) | 10 | Below this many weapons every one gets its own card; from it on, one card per slot. 0 to 30. |
| Fan Close Forgiveness (tics) | 6 | 0 to 20. |
| Constellation Lines Apart (tics) | 2 | 0 to 12. |
| Star Brightness | 0.5 | 0 to 1.0. |
| Light Size | 44 | 8 to 160. |
| Light Holds Across Gaps (tics) | 3 | 0 to 12. |
| Sparks | 18 | 0 to 80. |
| Spark Speed | 1.4 | 0.2 to 4.0. |
| Volume | 0.65 | 0 to 1.0. |
| Data Sheet Size | 1.0 | In card widths, 0.5 to 2.0. |
| Pointing at a Gun: Rest For (tics) | 18 | 0 to 70. |
| Wrist Card: Hold the Pose (tics) | 8 | 2 to 30. |
| Wrist Card Size | 0.6 | 0.5 to 2.0. |
| Palette by Name | Standard | A palette added by another pk3's WRPALS lump, by its name. |
| Font Set by Name | Ermac | A font set added by another pk3's WRFONTS lump, by its name. |
| Print Diagnostics on Open | Off | Prints what the ring did to the console. |
| Reset All | | Puts every RSQ Wheel setting back to its default (asks first). A slot order you arranged is kept. |

## Works with

- **RSQ SlowMo**: the world slows while the ring is up and lets go when it closes. Slow motion you started
  yourself is left running unless Closing Ends My SlowMo is on; slow motion that is easing back is slowed
  again.
- **RSQ LaserSight**: with the ring up, the idle hand shows only the laser, not two beams.
- **RSQ Tactical Rig**: a holstered gun's sheet has a HOLSTER row naming where it hangs.
- **RSQ Gun Bonsai VR** (with Gun Bonsai): the sheet's GUN BONSAI level and upgrade rows, the comparison's
  BONSAI row, the wrist card's level. No Gun Bonsai VR node changes the Wheel.
- **RSQ Gun Cards**: when its watch card is on, the Wheel's Wrist Card stands down. Gun Cards follows the
  Wheel's palette, font set and ring plates. The Card Look uses Gun Cards' colours and honours its Card
  Colour setting.
- **RSQ Grenade**: the grenade's card fans out the kinds you own; picking one sets the kind.
- **RSQ Gestures** asks the Wheel whether it is open, and reads no gestures while it is.
- **RSQ Accessibility**:
  - Steady Hands: the beam that points at cards, the compare aim and Card When Pointing at a Gun use the
    smoothed hand. Reaching in, pulling a card out and throwing a gun back stay on the raw hand.
  - Seated Play: the wrist card's watch pose is measured from your seated eyes.
  - Slower Taps: Hold to Pick, Double Tap: Last Gun and the Re-centre Window are 1.5x longer.
  - Rumble Strength: every ring rumble x0 to x2 (0 = none).
  - Colour Blind Mode: every card goes neutral grey and only the hovered card is coloured, in the series'
    highlight colour for that mode (amber for protanopia and deuteranopia, red for tritanopia, yellow for
    high contrast); so are the beam, the room light, the halo, the mark and the sheet band. The sweep and the
    mark carry the hover without colour.
  - Photosensitive Mode: the breathing (when on) and the sweep at 40 % strength, the sweep at half speed.
- **ModelSwapper**: Wheel: cycle main-hand model / off-hand model (no default keys) ask ModelSwapper to cycle
  the model on that hand.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s; after RSQ Gun Bonsai VR and
RSQ Gun Cards. Its place among the other RSQ pk3s does not matter: every mod it talks to is found by name at
run time.

## Known limits

- Stock QuestZDoom cannot read another mod's fields by name, so the readers that need that show nothing:
  the ModelSwapper and Lithium rows, MetaDoom's plasma heat, and the Doomablo, DOOM Infinite, Pandemonia,
  Guncaster and BorderDoom readers (which for that reason have no menu row). LegenDoom, DoomRL Arsenal,
  Combined Arms, Final Doomer and MetaDoom's demon keys read another way and work.
- Without ModelSwapper's fields there is no Models page on the ring.
- No painted card faces and no room effects (laser fog, light sweep, floor marks): the engine cannot draw
  them. Their settings are not on the menu on purpose.
- The ring is drawn per tic (35 a second), not per frame.
- A custom palette (Palette row) does not recolour the Card Look's gun colours: they are Gun Cards' colours.
- The default keys `[` and `]` only take when nothing else already uses them.

## For other mods

**`wr_RigService`** (a `Service`, found by name):
- `GetInt("IsOpen")`: 1 while the ring is open. `GetInt("OpenHand")`: 0 main, 1 off. `GetInt("HasAnchor")`:
  1 once the open ring has a real position.
- `GetDouble("RingClearance")`: the ring's radius in map units. `GetDouble("AnchorX" / "AnchorY" / "AnchorZ")`
  and `GetDouble("AnchorYaw")`: where it sits (0 when closed).
- `GetObject("HoveredWeapon", objectArg: PlayerPawn)`: the Weapon the ring is pointed at, or null.

**Network events** the ring answers (the binds send them): `wr_press` (arg 1 down, 0 up: hold, point,
release), `wr_toggle_any`, `wr_toggle_main`, `wr_toggle_off` (`wr_toggle` is an old spelling of
`wr_toggle_off`), `wr_ms_cycle_main`, `wr_ms_cycle_off`.

**Palettes and font sets**: any pk3 can add a palette or a font set with its own `WRPALS` / `WRFONTS` lump
(the format is at the top of `zscript/wheel/wr_q_look.zs`); Palette by Name and Font Set by Name pick it.

The Wheel asks, by name: `RSQSM_Service` (`running`, `active`; events `rsm_on`, `rsm_off`),
`RSQLS_SightService` (`laser.beam`), `RSQTR_RigService` (`rig.holster`, `rig.regionname`), `RSQGB_Service`
(Gun Bonsai level and upgrades), `RSQGN_Service` (`kinds.owned`, `kind`, `kind.colour.of`, `kind.name`,
`kind.set`), `RSQA_Service` (`steady`), and the cvars `rsqgc_watch`, `rsqgc_color`, `rsqa_colorblind`,
`rsqa_photosafe`, `rsqa_rumble_scale` and ModelSwapper's `rs_fm_bridge_cmd_main` / `rs_fm_bridge_cmd_off`.

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
