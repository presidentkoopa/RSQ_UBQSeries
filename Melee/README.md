# Melee (RSQ Melee)

**The one thing:** your real swing is the punch: how fast you hit is how hard it lands, with uppercuts that lift, a
gun-butt shove that slows time, a Hadouken that punches a fireball back at its shooter, and a Headlock you throw
monsters out of.

Fighting with your body: Melee's own hands (Ermac's hand or BD22 VR's FBX hand, fist or open palm), the punch, the
open-palm swat, SuperPunchOut's boxing gloves, Slappers Only, the Guard, the Hadouken, Wall Splat, Heavy Hands,
Ground Pound, Clear Out, the gun-butt shove with its slow-motion beat and the F.E.A.R. Effect, and the off-hand
Headlock with its throw. Each blow shows its own hit spark. For stock QuestZDoom 17.3, VR; script and data only, no
engine changes. Needs no other mod: everything works on plain Doom 2 alone. Best with RSQ Gun Bonsai VR (the moves
grow into its trees), RSQ SlowMo (the shove's slow motion), RSQ Gestures (the two-hand moves) and RSQ Distance Grab
(the Headlock throw).

## Features

**Melee's hands.**
- Ermac's hand, or BD22 VR's FBX hand worn in its Hand Skin Tone when that mod is loaded (Melee Hands: Auto). Each
  hand is a fist or an open palm; tap that hand's fire to switch.
- Boxing Gloves: SuperPunchOut's gloves on both hands, always fists.
- Start With Melee Hands hands you Melee's hands at each level start and raises them in both hands.
- Slappers Only: the boxing gloves on both hands at once, every gun put away in a stash, gun pickups vanish while it
  lasts. You keep the series' melee and whatever the loaded game calls melee. Off: your guns come back (no free
  ammo), each in the hand it was in.
- Melee's hands are weapon slot 1.

**The punch.**
- A fist thrown at a monster from a slow hand is a punch: 2 m/s on average for the weakest, 7 m/s for full power
  (Punch Damage 10, doubled at full speed). Straight, from the side or rising: a jab, a hook or an uppercut, read from
  the whole swing in real space.
- **The uppercut lifts** the monster into the air, held in its pain for the flight. No launch goes higher than
  Uppercut Lift Cap.
- **The Berserk pack makes a punch x5** while you hold it.
- A punch never lands through a wall, and a hand pulled back out of a body is not a punch.
- Star Punch's bank, One-Two chains, body blows and counters are read on every punch for Gun Bonsai VR's glove
  upgrades.

**Sending it back.**
- **Open-Palm Swat:** an open palm swung through a monster's missile (1.5 m/s or more) knocks it aside.
- **Hadouken:** a fist at punch speed that meets a monster's missile sends it back at whoever fired it, 15 % faster,
  hitting for 150 %.
- **Guard:** both hands up at your face, no gun in either hand, and a blow from in front (within 55 degrees) does
  60 % of its damage; you slide back a step. A blow of 35 or more breaks the guard: full damage, no guard for 0.4 s.

**Hitting harder.**
- **Wall Splat (Wallflower):** a monster your punch knocks into a wall slams into it: 10 damage, up to 20 for a hard
  slam, bounces off and reels.
- **Heavy Hands:** a landed punch freezes the monster for a beat (2 tics, 4 at half speed or more) and knocks it 25 %
  further.
- **Ground Pound:** both fists swung down hard together: a shockwave round you that hurts, pushes out and staggers.
  Needs RSQ Gestures.
- **Clear Out:** both palms thrust forward together: everything in a 90-degree wedge in front is shoved back hard, hurt
  and staggered. Needs RSQ Gestures.

Guard, Hadouken, Wall Splat, Heavy Hands, Ground Pound and Clear Out are Gun Bonsai upgrades. With RSQ Gun Bonsai VR
loaded each works only once Gun Bonsai has granted it, at the learned level's numbers, and Melee's rows for them do
nothing. Without Gun Bonsai VR each has a Melee row, off by default, that plays it at the upgrade's level 1.

**The gun-butt shove and the F.E.A.R. Effect.**
- **Gun Butt Shove:** with a gun in your main hand, shove it hard at a monster within about 2 m: BD22 VR Reloaded's
  butt strike. 14 damage (62 with the Berserk), knocked away from you, once every 12 tics. Stands down when BD22 VR
  Reloaded is loaded: its own strike is the one.
- **Slow-Mo After a Shove:** a landed shove (ours, or BD22 VR Reloaded's) asks RSQ SlowMo for a short pulse of slow
  motion (300 ms at 35 % world speed).
- **The F.E.A.R. Effect:** while that slow motion lasts, every shotgun hit of yours on a monster bleeds twice, and a
  shotgun kill in it is RSQ Score's F.E.A.R. Effect.

**The Headlock.**
- The off hand's grip on a living monster within 30 cm holds it by the collar, its face at your hand, facing you, for
  3 s, so the main hand can punch it. Up to demon weight (Doom mass 400). No shrinking, no new art: any monster.
- Each punch on a held monster shows its pain frame with its pain sound and a spark at its face. **Headlock Punch Extra
  Blood:** it bleeds more, x1.3, x1.6, then x2.0.
- **The throw:** swing the off hand hard while it holds one and the monster is thrown, across the ground, within 60
  degrees of where you face. It counts as Headlock Throw Weight % of its weight.
- **Human Shield:** held as long as you hold the grip (a minute at most), turned to face away from you.
- A boss cannot be held, nor a miniboss RSQ Miniboss says cannot.

**Hit sparks.** Capcom vs. SNK 2's, one per blow, at the impact point: a jab the Normal Spark (orange), a hook and
the swat the Special Spark (blue), an uppercut and the Hadouken's return the Super Spark (violet, with the Hadouken
hit burst), the Guard taking a blow the Guard flash (blue, in front of your eyes). Each spark comes at four angles and
the one nearest the blow's travel is drawn. About a monster's head in size; Hit Spark Size scales them all. Impact
bursts (kiddolink's "VFX Hit Impact") on the moments that earn them: the uppercut's lift, Juggle, Meteor, Ground
Pound, Clear Out, Slam, Parry and Reflect Guard, the Guard's release.

## How to play

No buttons to bind. Each hand's own fire is the fist / palm switch; the Headlock reads the off-hand grip.

- **Fist or open palm:** tap a hand's fire (main hand: fire; off hand: the off-hand fire). Each hand starts as a fist.
  Boxing gloves stay fists.
- **Jab, hook, uppercut:** from a slow hand, throw a fist at a monster: at least 15 cm of travel, 2 m/s for the weakest
  punch, 7 m/s for full power. Straight in is a jab, from the side a hook, rising into the chin an uppercut. An
  uppercut lifts the monster.
- **Swat:** tap fire for the open palm, then swing the palm sideways through a monster's fireball. It is knocked aside.
- **Hadouken:** fist up near your face; when a monster's fireball comes, punch it. It flies back at whoever fired it.
- **Guard:** put a fist or empty hand on each side of your face, no gun in either hand, and hold. A blow from in front
  is soaked. Release the Guard's charge (Gun Bonsai VR's Absorb and Release) by throwing both hands apart.
- **Wall Splat:** punch a monster toward a wall about a metre behind it. It slams and reels.
- **Heavy Hands:** nothing to do; a landed punch stops the monster for a beat and sends it further.
- **Ground Pound:** swing both fists down hard together, past your hips, at 3 m/s or more. A shockwave goes out round
  you.
- **Clear Out:** with nothing but Melee's hands in either hand, thrust both palms forward together, side by side.
  Everything in front is shoved back.
- **Gun-butt shove:** with a gun in your main hand, drive it forward hard (3.6 m/s) into a monster within about 2 m. It
  is knocked away and, with RSQ SlowMo, the world slows for a beat.
- **The F.E.A.R. Effect:** in that slow beat, shoot the monster with a shotgun. Every hit bleeds twice; the kill is the
  F.E.A.R. Effect.
- **Headlock:** put your off hand on a living monster (within 30 cm) and squeeze the grip. You hold it by the collar,
  its face at your hand, for 3 s. Punch it with the other hand.
- **Throw it:** while you hold one, swing the off hand hard (3 m/s) across the ground toward where you face. It flies.
  Let go of the grip to drop it instead.
- **Human Shield:** with the row on, the hold lasts as long as you hold the grip, the monster facing away from you.
- **Slappers Only:** turn the row on and you have the gloves on both hands and no guns. Turn it off and your guns
  come back.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Melee**.

| Menu row | Default | What it does |
|---|---|---|
| Melee Hands | Auto (FBX with BD22 VR) | Auto: BD22 VR's FBX hand when RSQ's BD22 VR weapons mod is loaded, else Ermac's. Or Ermac / FBX (BD22 VR). |
| Boxing Gloves | Off | Melee's hands wear SuperPunchOut's boxing gloves: always fists (no open palm, no swat). |
| Open-Palm Swat | On | An open palm swung through a monster's missile knocks it aside. |
| Slappers Only | Off | Boxing gloves on both hands, every gun put away, gun pickups vanish while it lasts. |
| Start With Melee Hands | Off | Hands you Melee's hands at each level start and raises them in both hands. |
| Gun Butt Shove | On | The main hand's shove with a gun hits. Stands down with BD22 VR Reloaded. |
| Slow-Mo After a Shove | On | A landed butt shove asks RSQ SlowMo for a short pulse; the F.E.A.R. Effect runs while it lasts. |
| Headlock | On | The off hand's grip on a living monster holds it. |
| Headlock: Human Shield (hold until let go) | Off | Held as long as the grip is, facing away. With RSQ Gun Bonsai VR this row does nothing: Human Shield is the off glove's upgrade. |
| Headlock Punch Extra Blood | On | Punching a monster you hold bleeds more: x1.3, x1.6, then x2.0. |
| Guard | Off | Without Gun Bonsai VR: both hands up at your face soak a blow from in front. |
| Start With Guard (Gun Bonsai VR) | Off | With RSQ Gun Bonsai VR: the Guard at level 1 before it is learned. |
| Hadouken | Off | Without Gun Bonsai VR: a punch sends a monster's missile back at its shooter. |
| Wall Splat (Wallflower) | Off | Without Gun Bonsai VR: a monster punched into a wall slams into it. |
| Heavy Hands | Off | Without Gun Bonsai VR: a landed punch freezes the monster for a beat and knocks it further. |
| Ground Pound | Off | Without Gun Bonsai VR: both fists swung down together, a shockwave round you. Needs RSQ Gestures. |
| Clear Out | Off | Without Gun Bonsai VR: both palms thrust forward together, everything in front shoved back. Needs RSQ Gestures. |
| Hit Spark Size | 1.0 | Hit and guard sparks times this (1.0 = about a monster's head). |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Punch Min Speed | 2.0 | m/s on average for the weakest punch. |
| Punch Full Speed | 7.0 | m/s for full power. |
| Punch Damage | 10 | A punch's damage; doubled at full speed. |
| Uppercut Lift Cap (m of air) | 3.0 | No launch goes higher than this; 0 = no cap. |
| Butt Shove Speed (m/s) | 3.6 | The shove must average this to hit. |
| Shove Slow-Mo Length (ms) | 300 | The slow-motion pulse after a shove. |
| Headlock: Reach (m) | 0.30 | Metres from the palm to the monster's body. |
| Headlock: Heaviest | 400 | The heaviest it can hold (Doom mass: imp 100, demon 400, baron 1000). |
| Headlock: Seconds | 3.0 | How long it stays held before it breaks free. |
| Headlock: Throw At (m/s, 0 = never) | 3.0 | The off hand swung past this while holding throws the monster. |
| Headlock Throw Weight % | 30 | A thrown monster counts as this share of its weight. |
| Debug Log | Off | Off / Each Decision / Also Each F.E.A.R. Hit, to the console. |
| Reset All | - | Every RSQ Melee setting back to its default. |

## Works with

- **RSQ Gun Bonsai VR** (with Gun Bonsai): Guard, Hadouken, Wall Splat, Heavy Hands, Ground Pound and Clear Out are
  its upgrades; it pays a returned missile, a wall slam and the two-hand moves to the glove. Its glove upgrades read
  the last punch through Melee's service.
- **BD22 VR (RS_Brutal22WeaponsQ):** Melee Hands' Auto shows its FBX hand, worn in its Hand Skin Tone.
- **BD22 VR Reloaded:** the shove stands down; its own butt strike starts the slow motion and the F.E.A.R. Effect.
- **RSQ SlowMo:** the slow motion after a shove, and whether it is still running for the F.E.A.R. Effect.
- **RSQ Score:** the Headlock is its Headlock combo; a shotgun kill in the shove's slow motion is its F.E.A.R. Effect
  combo. Score asks Melee which hand sent a missile back.
- **RSQ Distance Grab:** a thrown Headlock monster flies through its throw (strength, weight, aim assist, impact).
  The off grip press is decided between the two mods each tic, so they never both take it. Without it, Melee's own toss.
- **RSQ Gestures:** Ground Pound and Clear Out come from its two-hand events; its Two-Hand Events row may stay off, a
  player who has either move keeps them read. The Guard's release and Taunt answer its "both hands apart".
- **RSQ Miniboss:** with its "Can't Be Headlocked" on, the Headlock refuses a miniboss as it refuses a boss.
- **RSQ Grapple:** the shove is quiet on the rope. Its Scorpion asks Melee for an automatic punch on a monster the hook
  brings in.
- **RSQ Wheel:** the shove is quiet with the ring open.
- **RSQ Tactical Rig:** a hand in a holster is the rig's; the Headlock does not take it.
- **RSQ Accessibility:** Rumble Strength, Seated Play (the Guard's box), the Off-Hand Modifier.

Gun Bonsai VR's nodes that change Melee (GBOVR_TREES.md 4.1, the Fists tree, and the Guard's player nodes): Power
(Uppercut as an unlock, then its levels, Launcher, Juggle, Meteor, Heavy Hands, Ground Pound, Clear Out, Knockdown),
Elemental (one element per glove), Combos (One-Two, Dempsey: in a run of alternating hooks a glove re-arms faster;
Star Punch), Counter (Hadouken, Catch on a still open palm, Bullet Time Fists with RSQ SlowMo, Swat Back: the swat
sends the missile back at its shooter; Guard, Parry: both guarding hands driven into the blow; Reflect Guard: a
missile about to hit the raised Guard goes back; Absorb and Release; Taunt doubles the next punch), Grappler (Human
Shield, Heavier Headlock, Slam: the holding hand swung down, Throw Into, Chokehold, Headlock Uppercut), Berserk
(Rage under the Berserk: more hit-stop and knock; Berserk Meter), and the gun hand's Pistol Whip and Rifle Butt on
the shove. Until a glove learns Uppercut, a rising punch from it lands as a jab and lifts nothing.

## Load order

After Brutal Doom, the voxel pack, BD22 VR Reloaded, the monster packs and Gun Bonsai, among the RSQ pk3s; any order
among them. RSQ Gun Bonsai VR loads right after Gun Bonsai.

## Known limits

- The swat and the Hadouken see a monster's missiles only, not hitscan bullets.
- With RSQ Gun Bonsai VR loaded, the six upgrade rows do nothing until Gun Bonsai grants the move; without it each
  plays level 1.
- Ground Pound and Clear Out need RSQ Gestures; without it neither happens.
- The Headlock holds a monster by the collar, not lifted: it stays on its feet.
- The butt shove's speed is measured at the hand (BD22 VR Reloaded measures at the stock's tip).

## For other mods

`ServiceIterator.Find("RSQML_Service")`. GetInt unless said: "loaded" (1); "punch.glove" (objectArg a damage
inflictor: 1 when it is one of the gloves); "punch.kind" (0 jab, 1 hook, 2 uppercut; -1 not a glove); "punch.body"
(landed below the chest); "punch.counter" (into an attack wind-up); "punch.star" (a Star Punch); "punch.chain"
(One-Two: alternating hits in a row); "punch.hand" (0 main, 1 off); "punch.height" (where the glove met it, permille
of the body's height); "punch.kinds" (the last three punches inside 1 s, digits kind + 1); "punch.run" (Dempsey:
alternating hooks in a row); GetDouble "punch.power" (0..1) and "punch.speed" (m/s); "guard" (the pawn: tics the
Guard has been up); "headlock.claim" (the pawn: 1 while the off grip press is the Headlock's); "headlock.holding" (a
monster: 1 while held); "returned.by" (a missile: 0 a punch, 1 Swat Back, 2 the Guard; -1 not ours); "launch.age" (a
monster, intArg the player: tics since that player's uppercut launched it, while still in the air; -1 not);
"autopunch" (a monster, intArg the player, doubleArg a damage share: that player's empty fist punches it now).

## Credits

See `CREDITS.txt` (in the pk3, with `credits/`):

- Code: ZScript for the Radiant Silvergun Quest series (presidentkoopa), for stock QuestZDoom 17.3 by Emawind84 and
  Team Beef. No engine change.
- Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); the glove mesh and its fit are Ermac's
  (iAmErmac, PunchOutVR / Virtual Punch Out); punch and star sounds from Punch Out Doom (DerrickDavison) through
  Virtual Punch Out. Punch-Out!! is Nintendo's.
- A glove's punch is Brutal Doom's own fist numbers (Sergeant Mark IV; brutal22test6), parsed, not shipped. The
  upgrades and their numbers stay in RSQ Gun Bonsai VR, an addon for Rebecca "ToxicFrog" Kelly's Gun Bonsai (MIT).
- The gun-butt shove is BD22 VR Reloaded's butt strike (the owner's own mod), ported; numbers from Brutal Doom.
  Sounds played by name, not shipped: Brutal Doom's Melee/SwingStrong and Kick/flesh when it is loaded, otherwise
  stock Doom's skeleton/swing and punch (id Software). Slow motion is RSQ_SlowMo's; the award RSQ_Score's.
- The Headlock, Human Shield and the headlock throw: RSQ Distance Grab's (presidentkoopa; its feel ported from his
  desktop RS_WorldHands).
- Hand model by Ermac (iAmErmac), Rusted Legacy / Doom Force Unleashed, MIT licence
  (`credits/Ermac_RustedLegacy_LICENSE.txt`). The FBX hand is BD22 VR's (RS_Brutal22WeaponsQ, presidentkoopa); its skin
  tones are read from BD22 VR's own pk3, none shipped here.
- Capcom vs. SNK 2 hit sparks, ripped and converted by Phantom.of.the.Server; property of Capcom, non-commercial
  (`credits/CvS2hitsparks_Readme.txt`).
- Random Sprite Rips, ripped by Phantom.of.the.Server: "Use it freely. The sprites are property of their respective
  game companies, so they cannot be used for any commercial purposes." (`credits/RandomSpriteRips_Readme.txt`).
- Fists tree sounds from the owner's RS Combat FX and RS Ballistics libraries (presidentkoopa).
- Impact bursts: "VFX Hit Impact" by kiddolink, a paid asset pack bought by presidentkoopa for this series; used under
  the purchase's licence, not for re-sale or redistribution as an asset pack.
- Sounds played by name, not shipped: stock Doom 2's DSTINK (the guard) and DSSKEPCH (the swat).
