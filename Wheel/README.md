# RSQ Wheel

A weapon ring that hangs in the air in front of you. Point at a gun with either hand and it is in your hand.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New since the headset pass (tested on the rig, headset check pending): the fist, lightsaber and whip card icons; the fist always on the ring.

New on 11-06 (rig only, not headset-confirmed): the text in JFO with proportional spacing; one fist card; one card per gun (BD22 VR's off-hand versions); the shield, saber, whip and grenade from either hand to their own hand; alt-fire locks a gun to its Tactical Rig holster (replaced 11-07 by the holster web, below); Freeze Time While Open.

New on 11-07 (rig only, not headset-confirmed): the **holster web** (design/PARKED.md). Main-hand alt-fire on a card
opens it: your marine with RSQ Tactical Rig's six holsters as numbered rings fitted to his body from your active profile.
Point at a ring and pull the trigger: the gun's sprite flies into it, the ring flashes, the controller kicks, the gun goes
into that holster, and the Wheel stays open. Off-hand alt-fire puts a card in or out of the next/prev rotation (a light
runs round a card in the rotation; a holstered card sits back with an outline; a plain card is Wheel only); on a
holstered card it gives a dull tick. next/prev skip Wheel-only and holstered guns. Shown on the rig: all of that. Without
RSQ Tactical Rig: main-hand alt-fire is a dull tick, the rotation and next/prev work alone (shown in the log). The marine centred on his body between each pair of rings: shown on the rig. Not shown:
the fly-in mid-flight (too fast for the rig's frames).
New on 11-09 (rig only, not headset-confirmed): **the ring's text is in RSQ Score's font** (the one "SCORE:" is drawn
in), because the owner's headset showed every word on the cards as a row of blobs. Why: the words were in JFO, whose
letters are 32-pixel stone shapes. In the headset they were drawn about 6 pixels tall, and at that size JFO's gaps
(1-3 pixels of 32 inside a letter, 2 between letters) are less than a pixel, so each letter smeared into a solid slab.
Score's font is a 12-pixel block font with 2-pixel strokes and gaps and a dark outline, and the Wheel now keeps a pixel
of air between its letters, so it holds together much smaller. Shown on the rig: the same card in JFO, Score's font,
Score's combo font and DoomFont, next to each other (tools/rigshots/font_score_vs_jfo_1109.png). Score's font reads
best, and it is the only one that still reads "WHIP" once the frame is blurred to look like the headset
(font_score_vs_jfo_blur_1109.png). A config set to JFO (the old default) moves to Score's font once. The others,
including JFO, are still in Look > Font. Very small text (the body of the info card) is still small: if it does not
read in the headset, the size is the next thing to change, not the font.
The web's ring numbers (11-07, rig only, not headset-confirmed): big, in RSQ Score's combo font when Score is loaded (shown on the rig), else in JFO, bigger (not shown).
Web View (11-07, rig only, not headset-confirmed): **Marine** (default, as above) or **Mirror**: the web shows RSQ
Tactical Rig's own mirror of you (the one Move Holsters by Hand shows), filling the panel, with the six rings on the real holster
spots as the mirror shows them (your left on your left). Shown on the rig with the Rig's torso on: the mirror on the
panel with all six rings on it, a ring picked by pointing, the gun flying in and its sprite in the ring. With RSQ
ShieldSaw's Take It From set to Over the Shoulder, the off-shoulder ring (1 right-handed) is the ShieldSaw's: it shows
the ShieldSaw's card art and its name, and a gun picked onto it gets only a dull tick (shown on the rig, Mirror view).
Mirror big (11-07, rig only, not headset-confirmed): the mirror and its rings (grown with it) take about 90% of the
panel's height and 91% of its width, centred, nothing over its edges, Clear still below (shown on the rig).
Not shown: Marine view with the ShieldSaw's ring, ring 2 for a left-handed player, the Rig off (the web falls back to
Marine).

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. This is presidentkoopa's weapon wheel from his
own engine, rebuilt in ZScript alone so it runs on the stock engine. No engine changes.

## Standout feature: the cards are things you can grab

Hold the wheel button and a ring of cards opens in front of your hand, one per gun, each with the gun's own 3D pickup
model turning on it. Now treat them as objects.

Reach into a card and yank your hand back toward you: the gun comes out of the ring and into that hand. Flick the gun
you are holding back at the ring: it files itself away, its card bursts, and your hand is empty again. Put one hand
on the rifle and the other on the shotgun, let go of the button, and each hand takes its own gun in one move.

Every card has a weight. Sweep across the ring and the pistol answers with a short light tick in your controller, the
BFG with a long heavy thud. After a while you can find a gun by feel.

## Features

**Picking**
- Hold, point, release: one button. Either hand points; letting go takes the card under a hand.
- Tap instead and the ring stays up; pick with either trigger from any distance, or Use with your hand inside a card.
- Two hands, two cards, one release: each hand takes the gun it is on.
- Pull a card out of the ring with a snap of the hand. Throw a gun back to put it away.
- Double tap: straight back to the gun you held before.
- A gun with no ammo at all is not taken: you hear a dry click and keep what you had.
- The ring stays in view: turn well away and it swings round to sit ahead of you again.
- Folds away by itself if you leave it alone, with a rumble just before it goes.

**The cards**
- Colour by Gun: each card washed in its gun's colour, lit from the top, with a halo behind the card you are on.
- The gun's pickup model (from BD_VoxelPack) turning on its card. A gun without one keeps its icon.
- The fist is always on the ring, as slot 1's first card: also when a fan would hide it, when a mod leaves it out
  of the weapon slots, and when you have none (taking the card gives you the fist). One fist card: the hand that
  takes it gets its own fist (Doom's Fist, Brutal Doom's fists, or BD22 VR's off-hand fist).
- One card per gun: a gun with an off-hand version (BD22 VR's) shows once, and the hand that takes it gets its own
  version (the off hand the off-hand copy, the main hand the gun).
- Either hand can take RSQ ShieldSaw's shield, RSQ Saber's saber, RSQ Whip's whip and RSQ Grenade's grenade: the
  shield always ends up in the off hand (drawn by ShieldSaw itself), the others always in the main hand.
- Main-hand alt-fire on a gun's card opens the holster web (above; needs RSQ Tactical Rig): a trigger on a ring
  assigns the gun to that holster, Clear unassigns it. Off-hand alt-fire puts a card in or out of the next/prev
  rotation. (Rig only, not headset-confirmed.)
- The fist, the lightsaber, the whip and the ShieldSaw have their own icons: LegenDoom's brass knuckles, a pixel-art
  lightsaber, a coiled whip and a round saw-shield (credits in CREDITS.txt; the ShieldSaw's rig only, not
  headset-confirmed). So do RSQ Melee's gloves (a red boxing glove), and, when a mod puts them in a weapon slot, RSQ
  FnF's flare (a burning road flare) and flashlight (a torch with its beam) and RSQ Saber's Force hand (an open hand
  with blue push waves); drawn for the series (these four cards not yet seen on the rig or in the headset).
- Ammo counts and gauges, a slot number, and a mark on the guns you are holding.
- A big arsenal folds into one card per slot. Rest on a slot and its guns fan out; Use opens the fan at once.
- Hold the trigger on a gun in a fan and drag it to a new place in its slot. The order is saved.
- A fan lists the guns you used last first.
- Sparks and a spin on the card you take, and an optional light the hovered card throws on the room.

**The data sheet**
- A panel in the middle of the ring about the gun under your hand: damage, rate of fire, accuracy and more where the
  weapon mod declares them.
- Your kills and hit rate with each gun, counted as you play, so it works with any weapon.
- The other guns you carry that share its ammo.
- Point at a gun lying on the floor (with the ring closed) and its sheet appears.

**Time**
- With RSQ SlowMo loaded, time slows while the ring is open.
- Without it, the ring can stop time instead (optional, off by default).
- Freeze Time While Open (off by default): the ring stops time while it is open, with or without RSQ SlowMo.

**Wrist card** (optional, off by default): bring your forearm up across your chest as if checking a watch and the gun in
that hand shows a small card.

## How To Play

1. Load the pk3. Nothing else is needed.
2. Press and hold the left thumbstick. The ring opens in front of your main hand.
3. Point either hand at a card. It steps forward and your controller ticks.
4. Let go. The gun is in the hand that pointed at it, ready to fire, with no lower-and-raise animation.
5. Try a quick tap instead: the ring stays up. Look around it, read the sheet, then pull the trigger on the card you
   want. Tap the button again to close it.
6. Once that feels natural: put a hand inside a card and snap it back toward you. Then flick a gun back at the ring.
7. Double tap the button to swap back to the gun you had before.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Open the ring, pick, close | Hold the left thumbstick click, point, release | Held at least 9 tics (about a quarter second). Release over nothing just closes. |
| Open and leave it up | Tap the left thumbstick click | Tap again to close. |
| Back to your last gun | Double tap the left thumbstick click | Second press within 10 tics. |
| Take the card you point at | Trigger or off-hand trigger | Any distance. The press never reaches your gun. |
| Take the card your hand is in | Use | With your hand inside the card. |
| Holster web | Main-hand alt-fire on a card | Needs RSQ Tactical Rig. Trigger on a ring assigns the gun to that holster; Clear unassigns it. Alt-fire on the same card again closes the web. |
| Rotation in / out | Off-hand alt-fire on a card | next/prev step through the guns in the rotation. On a holstered card: a dull tick. |
| Pull a gun out | Hand inside a card, snap it back toward you | Faster than about 1.5 m/s. |
| Put a gun away | Snap the hand holding it toward the ring, not at a card | Faster than about 2.6 m/s. The hand goes back to its fist. |
| Pick for both hands | One hand on each of two cards, release the button | Each hand takes its own gun. |
| Open a crowded slot | Rest on its card, or Use while pointing at it | The fan opens after 7 tics on its own. |
| Reorder a slot | Hold the trigger on a fan card, move to a new place, let go | Let go without moving and it is a pick. |
| Page the data sheet | Trigger next, alt fire back | Only when there is a second page (ModelSwapper). |
| Re-centre the ring | Press the same open key again within 10 tics of opening | |
| Wrist card | Forearm up across the chest, wrist 15 to 50 cm from your eyes, hand pointing across your body | Off by default. Hold for 8 tics. |
| Inspect a floor gun | Point at it for 18 tics with the ring closed | |
| Open or Close | Bindable | No default bind. |
| Main Hand Wheel | Bindable | Default `[`, if that key is free. |
| Off Hand Wheel | Bindable | Default `]`, if that key is free. |
| Cycle main / off hand model | Bindable in Customize Controls | ModelSwapper only. No default bind. |

A key that is already bound is never taken: the defaults only land where they are free.

Left-handed play: main hand and off hand follow QuestZDoom's own handedness setting, and so does the rumble.

## Menu

Options → Radiant Silvergun Options → RSQ Wheel (one page; Test and Debug and Reset All at its foot)

| Row | Default | What it does |
|---|---|---|
| Weapon Wheel | On | Off stops the ring from opening. |
| Either Hand Picks | On | Both hands point at and pick from one ring. Off: only the hand that opened it picks. |
| Opens On | Whichever key you press | Which hand the open keys summon the ring on: as pressed, always main, or always off. |
| Sound | On |  |
| Controller Rumble | 1.0 | 0 to 2. QuestZDoom's own haptics switch still overrules it. |
| Size | 1.00 | The whole ring. |
| *Controls* | | |
| Hold, Point, Release | Left thumbstick click | Key bind. |
| Open or Close | Unbound | Key bind. |
| Main Hand Wheel | `[` | Key bind. |
| Off Hand Wheel | `]` | Key bind. |
| *Picking* | | |
| Two Hands Compare | Off | A hand on each of two cards shows the two side by side. |
| Open on Your Gun | Off | The ring opens with your current gun's card under your hand. |
| Wrist Card | Off | The watch-check card. RSQ Gun Cards' watch card takes over when that mod's is on. |
| Open at Level Start | Off |  |
| Slow Time While Open | On | Needs RSQ SlowMo, or Freeze Without SlowMo below. |
| Closing Ends SlowMo | Off | Off leaves slow motion you started yourself running when the ring closes. |
| Freeze Without SlowMo | Off | Without RSQ SlowMo, the ring freezes the world while it is open. |
| Freeze Time While Open | Off | The ring stops the world while it is open, with or without RSQ SlowMo (then SlowMo is not used). |
| Pull a Card Out | 1.5 | Hand speed for the pull, in map units a tic (about m/s). 0 turns it off. |
| Throw a Gun Back | 2.6 | Hand speed for the throw. 0 turns it off. |
| Reach In | 7.0 | How far in front of or behind a card your hand can be and still touch it. 0 turns it off. |
| Feel Each Gun's Weight | 1.0 | 0 gives every card the same tick. |
| *Look* | | |
| Palette | Standard | Standard, Doom, Hell or Tech. |
| Font | RSQ Score's font | The ring's text: RSQ Score's font (the "SCORE:" font, the default from 11-09), RSQ Score's combo font, JFO, or the older sets (Ermac's digits, DoomFont, the status bar's numerals). |
| Ring Plates | Its own (Ermac style) | Or the status bar's stone. |
| Card Look | Colour by Gun | Or Classic. |
| Web View | Marine | Or Mirror: RSQ Tactical Rig's mirror of you on the holster web. |
| Gun Models on Cards | On | The gun's pickup voxel on its card. |
| Ammo Counts | On | Counts and gauges on the cards. |
| Ammo Readout | LED segments | Or LCD, punched out, or Lozenge badge. |
| Rarity Colours | On | With a weapon mod that has rarity tiers. |
| Mark Guns You Hold | On |  |
| Slot Numbers | On |  |
| Cards Face You | On |  |
| Crowded Slot Opens As | Fan | Or Constellation. |
| Hover Halo Breathes | Off |  |
| Edge Sweep | Off | A spark running round each card's edge. |
| Flash on Pick | On |  |
| Spark Colour | Slot colour | Or White hot, or Rainbow. |
| Hover Lights the Room | On | One light, on the hovered card. |
| Background Stars | 0 | 0 = none. |
| *Data Sheet* | | |
| Show Data Sheet | On |  |
| Weapon Stats | On |  |
| Track Kills and Accuracy | On | Counted by this mod as you play. |
| This Level's Kills | Off | Adds a kills and accuracy row for this level only. |
| Gun Bonsai Rows | On | With Gun Bonsai and RSQ Gun Bonsai VR. |
| Point at a Gun | On | Point at a gun on the floor to see its sheet. |
| Compare With Yours | Off | That sheet shows the difference from your current gun. |
| *Other Mods* | | |
| LegenDoom Rarity | On | Reader for LegenDoom: the card in the rarity's colour, the rarity ("EPIC") on the sheet's top row and the legendary's name ("MURDEROUS SHOTGUN") on the row under it. With the LDL x BD22 VR patch (its 11-04 build), BD22 VR's guns too (rig only, not headset-confirmed). |
| LegenDoom Effects | On | The power, in LegenDoom's own words, under it. |
| Reset All | | Every setting back to its default (both pages, and the settings with no row). |

Each Other Mods reader does nothing unless its mod is loaded.

**Other mods parked (owner 2026-11-09):** only LegenDoom is read for now (and Gun Bonsai, above). The readers for DoomRL
Arsenal, Doomablo, Pandemonia (+ Anarchy, Insurrection), Guncaster, MetaDoom, BorderDoom, Doom Infinite, Combined Arms,
Final Doomer, ModelSwapper and Lithium are switched off and their rows hidden; about half of them read nothing on stock
QuestZDoom 17.3 anyway (design/PARKED.md).

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| *Picking* | | |
| Hold to Pick (tics) | 9 | Shorter is a tap, longer is a hold. |
| Double Tap (tics) | 10 | 0 turns the double tap off. |
| Ring Follows Past (deg) | 45 | Turn further than this and the ring swings back ahead. 0 = off. |
| Folds After (tics) | 140 | Untouched for this long, the ring closes. A new card under your hand restarts the clock. |
| Fold Warning (tics) | 25 | The ring fades and your hand feels a tick this long before it folds. 0 = off. |
| Re-centre Window (tics) | 10 | The same key this soon after opening re-centres instead of closing. 0 = off. |
| *Ring* | | |
| Ring Distance Ahead | 34 | Map units in front of your hand (34 is about a metre). |
| Ring Radius | 5.0 |  |
| Height Above Hand | 2.0 |  |
| Lean Toward You | 12 | Degrees. |
| Wrist Roll Spins the Ring | 0.00 |  |
| Stick Deadzone | 0.20 |  |
| Card Width | 4.20 |  |
| Card Height | 3.00 |  |
| Hovered Card Steps Out | 1.50 |  |
| Hovered Card Grows | 0.06 |  |
| Other Cards Fade To | 0.55 |  |
| Cards Grow In (tics) | 6 |  |
| Card Shadow | 0.32 |  |
| Shadow Offset | 0.35 |  |
| Face Parallax | 0.06 |  |
| Idle Breathing | 0.35 |  |
| Breathing Speed | 1.7 |  |
| Low Ammo Below (share) | 0.25 |  |
| Low Ammo Pulse | 0.35 |  |
| Model Turn Speed | 1.50 |  |
| Model Size | 0.16 |  |
| Model Stand-Off | 3.0 |  |
| *Cards* | | |
| Flat Ring Up To (weapons) | 10 | Up to this many guns, each gets its own card; beyond it, one card per slot. |
| Fan Close Forgiveness (tics) | 6 |  |
| Constellation Lines Apart (tics) | 2 |  |
| Star Brightness | 0.50 |  |
| Light Size | 44 |  |
| Light Holds Across Gaps (tics) | 3 |  |
| Sparks | 18 | Particles per pick. |
| Spark Speed | 1.4 |  |
| Volume | 0.65 |  |
| Idle Shimmer | 0.00 |  |
| Taken Card Spins (deg) | 360 |  |
| *Data Sheet* | | |
| Data Sheet Size | 1.00 | In card widths. |
| Pointing at a Gun: Rest For (tics) | 18 |  |
| Wrist Card: Hold the Pose (tics) | 8 |  |
| Wrist Card Size | 0.6 |  |
| Palette by Name | Standard | A palette added by another pk3. |
| Font Set by Name | Score | A font set added by another pk3. |
| Debug Log | Off | Prints diagnostics when the ring opens. |

## Works with

Runs on its own with any weapon mod.

- **RSQ SlowMo:** time slows while the ring is open. Slow motion you started yourself is left alone unless you ask.
- **RSQ Gun Cards:** the ring's colours are Gun Cards' colours, so a gun looks the same on both. Gun Cards' watch card
  replaces the Wheel's wrist card when it is on.
- **Gun Bonsai with RSQ Gun Bonsai VR:** the data sheet shows each gun's level, progress and upgrades.
- **RSQ TacticalRig:** the data sheet shows where each gun is holstered; alt-fire on a card locks that gun to its holster.
- **RSQ Laser Sight:** the ring's beam stands down on the idle hand when the laser already lights it.
- **RSQ Accessibility:** Steady Hands smooths card pointing. Slower Taps stretches the tap, hold and double-tap
  windows. Seated Play moves the wrist card's pose to your seated eyes. Colour-blind mode turns the cards neutral and
  colours only the one you are on. Photosensitive mode softens the motion.
- **BD22 VR Reloaded / Brutal Doom:** a gun thrown back from the off hand leaves that hand its own fist; an empty gun
  gives Brutal Doom's dry click. BD_VoxelPack's pickup models turn on the cards.

## Credits and licence

- The wheel is presidentkoopa's: RS_WeaponSelectionSystem, written for his UZDXREMA engine and spun out of
  RS_VR_Unified, brought here to stock QuestZDoom 17.3.
- QuestZDoom by Emawind and Team Beef: the engine, and the off-hand weapon and hand-pose script API the ring reads.
- The art drawn from the IWAD is the IWAD's own, used by lump name and never copied: STBAR, STCFN033-095 (DoomFont),
  STTNUM0-9, STTMINUS, STTPRCNT.
- The ring's plates and digits are drawn from Ermac's Force Unleashed holo HUD art, used with the owner's blessing.
- The text is RSQ Score's two fonts (from ijon's Dakka: the score font by Blue Shadow, the combo font by Jimmy), as
  RSQ Score carries them (CREDITS.txt).
- The JFO font set is JFO, the JDUI font by Zedas, in Blackmore1014's edit "JDUI Brutal Doom Ultimate Edition", as RSQ Gun
  Cards and RSQ VisualRewards ship it, with credit to both (CREDITS.txt).
- The lock-on mark is the series' own, from RSQ ShieldSaw. The glow art is drawn by this pack's tools; its gun colours
  are measured from RSQ Gun Cards' panel art.
- The rumble route to the controllers is the series' (RSQ ShieldSaw).
- Sounds came across with the wheel from UZDXREMA.
