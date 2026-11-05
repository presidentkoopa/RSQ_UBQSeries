# RSQ Melee

Fight with your body: real punches read from your real swing, an open palm that swats fireballs aside, a gun-butt
shove, and a headlock that holds a monster still while you work on it.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): the hands measured against the frame your headset drew, so walking and strafing never swing a punch, a shove or a guard.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. It needs no
other mod and works on plain Doom 2.

## Standout feature: it knows which punch you threw

Put up your fists (any fists: Doom's, Brutal Doom's, an empty hand, or Melee Hands) and throw a punch. The mod follows your fist the whole way in: it only counts once your hand
has travelled 15 cm toward the monster on consecutive tics, and the harder you swing, the harder it lands, up to
twice the base damage at full speed. It reads the shape of the swing against the line to the monster, not where you
look or how you hold the controller. Straight in is a jab. Across is a hook. Rising is an uppercut, and an uppercut
lifts the monster off its feet.

Tap a hand's trigger and that hand opens. Now swing your open palm through an imp's fireball and you knock it aside.
Turn the Hadouken on and a fist punched into a fireball sends it straight back at whoever threw it. Bullets too: a
palm or fist meeting a monster's shot knocks it away or returns it.

Walking, strafing and turning never count as a swing: your hands are measured against the frame your headset just
drew, so only your arms throw punches.

## Features

**The hands**
- Melee Hands for both hands: Ermac's hand, or BD22 VR Reloaded's hand when that mod is loaded (or pick one).
- Optional boxing gloves (off by default): always fists, no open palm.
- Fist or open palm per hand: tap that hand's trigger to switch.
- Jab, hook and uppercut, read from the swing. Damage scales with speed, from 10 at 2 m/s up to 20 at 7 m/s.
- Uppercuts launch, capped at 3 m of air.
- Open-palm swat: a palm swung at 1.5 m/s or more through a monster's missile knocks it aside.
- Fists and palms meet bullets: a monster's bullet met by your hand is knocked away (or returned with the Hadouken).
- Hit sparks on every blow, with an adjustable size.
- Slappers Only (off by default): gloves on both hands, every gun put away, gun pickups gone. Turn it off and your
  guns come back.

**Moves you switch on** (off by default; with RSQ Gun Bonsai VR they are earned as upgrades instead)
- **Guard**: both hands up at your face with no gun in either, and a blow from in front is soaked: you take 60% and
  step back. A blow too big for it breaks the guard.
- **Hadouken**: a punch into a monster's missile sends it back at its shooter.
- **Wall Splat**: a monster you punch into a wall slams into it, hurts and reels.
- **Heavy Hands**: a landed punch freezes the monster for a beat and knocks it further.
- **Ground Pound**: both fists swung down together send a shockwave round you (both hands read by RSQ Accessibility's gesture reader, or by Melee itself without it).
- **Clear Out**: both palms thrust forward together shove everything in front of you back hard (read the same way).

**The gun-butt shove** (on by default)
- Swing the gun in your main hand forward at a monster, hard (3.6 m/s), and the stock hits like Brutal Doom's kick,
  knocking it back.
- A landed shove asks RSQ SlowMo for a short slow-motion beat. Inside it, the F.E.A.R. Effect: every shotgun hit
  bleeds twice.

**The Headlock** (on by default)
- Your off hand's grip on a living monster within 0.30 m holds it frozen in front of you for 3 seconds, so your main
  hand can punch it. Up to demon weight.
- Every blow you land on the monster you hold bleeds more: 1.3x, then 1.6x, then 2x.
- Swing the off hand hard (3 m/s) while holding and you throw it.
- Optional Human Shield (off by default): held as long as you grip, turned to face away from you.

## How To Play

1. Add RSQ_Melee.pk3 to your load order and play in VR.
2. Everything works straight away. A hand punches whenever it holds fists: Doom's Fist, Brutal Doom's fists and
   BD22 VR's free off hand, an empty hand, or Melee Hands. For Melee's own hands (Ermac's or BD22 VR's hand, or
   boxing gloves), turn on Options → Radiant Silvergun Options → RSQ Melee → Start With Melee Hands (or Slappers Only
   for a fists-only run). The hands come up in both hands at the next level start; after that they live in slot 1.
3. Walk up to an imp and throw a jab, then a hook with the other hand. Then an uppercut from low down.
4. Tap your off-hand trigger to open that palm. When the next fireball comes, swing your palm through it.
5. Reach out with your off hand, grip a zombie, hold it, and punch it with your main hand. Swing the off hand to throw
   it away.
6. Holding a gun? Drive the stock forward into a face.
7. Want more? Turn on Guard, Hadouken, Wall Splat and Heavy Hands one at a time.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Punch | Swing a Melee Hand into a monster | Must travel 15 cm toward it, averaging 2 m/s or more |
| Jab / hook / uppercut | Straight in / across / rising | Uppercut rises past about 30 degrees |
| Fist or open palm | Tap that hand's trigger (main trigger or off-hand trigger) | A tap: let go within 10 tics, no punch landed |
| Swat | Open palm swung at 1.5 m/s or more through a missile or bullet | |
| Hadouken | Fist punched into a missile or bullet | Hadouken on |
| Guard | Both hands up at your face, no gun in either | Within 0.35 m of your head across, 0.25 m below to 0.15 m above your eyes; Guard on |
| Gun-butt shove | Main hand with a gun, driven forward at 3.6 m/s | 12 tics between shoves |
| Headlock | Off-hand grip on a monster within 0.30 m | Up to mass 400 (a demon) |
| Throw a held monster | Swing the off hand at 3 m/s or more | Within 60 degrees of where you face |
| Ground Pound | Both fists swung down hard together | Ground Pound on |
| Clear Out | Both palms thrust forward together | Clear Out on |

- The off-hand grip is read from the keys the engine sends for it (443, or 436 while the main grip is held).
- With RSQ Distance Grab loaded, one grip press goes to one mod: the Headlock takes it only when a holdable monster is
  nearer your palm than anything Distance Grab would grab.

## Menu

Options → Radiant Silvergun Options → RSQ Melee. One page, and one sub menu, **Test and Debug**. With RSQ Gun Bonsai VR
loaded the page starts with "GunBonsaiOVR detected. Mod features unlocked via upgrades." and the rows marked GB are greyed
while that upgrade is not learned (they do nothing until then). Learning one turns its row on; the row can still turn
it off. Hadouken and Heavy Hands are not greyed: the gloves learn them, but any other fist still plays the row (and the
row off turns them off on the gloves too).

| Row | Default | What it does |
|---|---|---|
| **Hands** | | |
| Start With Melee Hands | Off | The hands at each level start, up in both hands |
| Hand Model | Auto | Auto (FBX with BD22 VR), Ermac, or FBX (BD22 VR) |
| Boxing Gloves | Off | The hands wear boxing gloves (always fists) |
| Slappers Only | Off | Gloves only, guns put away |
| Open-Palm Swat | On | Palms knock missiles aside |
| Swat Bullets | On | Hands meet monsters' bullets too |
| Hit Spark Size | 1.0 | Size of the hit sparks |
| **Gun Butt Shove** | | |
| Gun Butt Shove | On | The stock strike |
| Slow-Mo After Shove | On | A short RSQ SlowMo beat and the F.E.A.R. Effect |
| **Headlock** | | |
| Headlock | On | Off-hand grip holds a monster |
| Human Shield (GB) | Off | Held while you grip, facing away |
| Extra Blood | On | Blows on a held monster bleed more |
| **Moves** | | |
| Guard (GB) | Off | The guard (level 1 without Gun Bonsai VR) |
| Start With Guard (Gun Bonsai VR) | Off | With Gun Bonsai VR, Guard at level 1 before it is learned |
| Hadouken | Off | Punches return missiles |
| Wall Splat (GB) | Off | Punched into a wall, it slams |
| Heavy Hands | Off | Heavier punches |
| Ground Pound (GB) | Off | Two-fist shockwave (no other mod needed) |
| Clear Out (GB) | Off | Two-palm shove (no other mod needed) |
| Reset All | | Every setting on both pages back to default |

**Test and Debug**: Punch Damage (10), Min Speed (2.0 m/s), Full Speed (7.0 m/s), Re-Hit Wait (6 tics), Uppercut Rise
(0.50), Lift Cap (3.0 m), Extra Reach (4); Shove Speed (3.6 m/s), Slow-Mo Length (300 ms); Headlock Reach (0.30 m),
Heaviest (400), Seconds (3.0), Throw At (3.0 m/s, 0 never), Throw Weight % (30), Off Grip Keys (443 436); Debug Log
(Off); Reset All.

## Works with

Runs alone. It finds the others by name:
- **Gun Bonsai + RSQ Gun Bonsai VR**: the gloves level like weapons. Guard, Hadouken, Wall Splat, Heavy Hands,
  Ground Pound and Clear Out become upgrades, joined by the Fists tree (Uppercut as an unlock, Launcher, Juggle,
  Meteor, Star Punch, combos), the Guard's tree (Parry, Reflect Guard, Absorb and Release, Swat Back) and the
  Grappler's nodes for the Headlock (heavier holds, Slam, Chokehold, Headlock Uppercut, Human Shield). Other fists
  can't learn the glove upgrades: they always uppercut and play Hadouken, Heavy Hands and Wall Splat by their Melee rows.
- **BD22 VR Reloaded**: the shove stands down for BD22 VR's own butt strike (the slow-mo beat still follows its hits);
  Melee Hands use its FBX hand and skin tone. Its fists punch (main hand, and the off hand while it is free). With
  BD22 VR's own VR Punching on, its blow does the damage and Melee adds the rest (which punch, the knock, the
  uppercut's lift, the Headlock's moves), so a swing never hits twice. With a Brutal Doom fist, the trigger tap that
  opens your palm also throws that fist's own trigger punch.
- **Brutal Doom**: the shove plays Brutal Doom's swing and kick sounds, and its monsters react to the kick themselves.
- **RSQ Distance Grab**: a monster thrown out of the Headlock flies through its throw code; the two share the grip.
- **RSQ Accessibility (its gesture reader)**: reads both hands for Ground Pound and Clear Out when it is loaded; without it Melee reads them with its own copy of that two-hand reader (the same moves and numbers).
- **RSQ SlowMo**: the beat after a shove, and the F.E.A.R. window.
- **RSQ Score**: the Headlock combo, the F.E.A.R. Effect award, returned missiles.
- **RSQ Tactical Rig**: the Headlock waits while your off hand is in a holster.
- **RSQ Accessibility**: rumble strength, seated play and the Off-Hand Modifier apply.
- **RSQ Grapple, RSQ Weapon Wheel**: the shove stays quiet on the rope or with the wheel open.
- **RSQ Wheel, RSQ Gun Bonsai VR**: the gloves have their own icon (a red boxing glove) on the Wheel's card and Gun
  Bonsai VR's status screen, whichever look the hands wear (not yet seen on the rig or in the headset).

## Credits and licence

- **presidentkoopa** (project owner): the code; the gloves, punch reader, punch classification and Star Punch from
  his SuperPunchOut; the gun-butt shove from his BD22 VR Reloaded; the Headlock from RSQ Distance Grab (its feel from
  his RS_WorldHands); the swing reader from RS_Gestures; the Fists tree sounds from his RS Combat FX and RS
  Ballistics libraries; the bullet tracer mesh from RS_Ballistics; the gloves' icon (sprites/rsqml/RMICA0.png,
  original pixel art drawn by RSQ Wheel's sources/icons/gen_item_icons.py).
- **Ermac** (iAmErmac): the boxing-glove mesh and fit (PunchOutVR / Virtual Punch Out); the hand model from Rusted
  Legacy / Doom Force Unleashed, MIT licence (credits/Ermac_RustedLegacy_LICENSE.txt).
- Punch and star sounds from Punch Out Doom (DerrickDavison), through Virtual Punch Out. Punch-Out!! is Nintendo's.
- **Brutal Doom** (Sergeant Mark IV): the fist and kick numbers and the monsters' kick thrusts, parsed, not shipped;
  its sounds played by name when loaded.
- **id Software**: stock Doom sounds played by name (swing, punch, the guard and the swat).
- Hit sparks: Capcom vs. SNK 2 sparks, ripped and converted by Phantom.of.the.Server (property of Capcom,
  non-commercial); the Hadouken burst from his Random Sprite Rips (non-commercial). Readmes in credits/.
- Impact bursts: "VFX Hit Impact" by kiddolink, a paid asset pack bought for this series; not for re-sale or
  redistribution as an asset pack.
- Gun Bonsai is by Rebecca "ToxicFrog" Kelly (MIT).
- **QuestZDoom** (Emawind and Team Beef): the engine.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms.
