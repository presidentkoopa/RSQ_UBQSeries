# RSQ Tactical Rig

**The one thing:** holsters on your real body: reach to a hip, your chest or a shoulder and the gun is there; and
Ermac's cigarette: light it, take a drag, flick it, and time slows.

`pk3/RSQ_TacticalRig.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3, in VR.

Guns holstered on your body. Reach to a hip, the chest or a shoulder and grip to put a gun away or draw it. Also a
grenade spot on the belt buckle, a keyring, throwing a gun away, saber spots, a mirror, an optional torso and helmet,
and Ermac's cigarette. Script only, no engine changes. Built on Ermac's idea, his Virtual Tactical Vest for Doom VR;
this is a new implementation that keeps the rig on your body, not your head. It needs no other RSQ pk3: RSQ SlowMo
only for slow motion after a smoke, RSQ Saber only for the saber spots, RSQ Gestures only for moving a gun at the
watch. Works with plain Doom 2; with Brutal Doom you also get the stored-gun pictures and Brutal Doom's empty hand.

## Features

**The holsters.**
- Six gun holsters: left hip, right hip, left chest, right chest, left shoulder, right shoulder. Each holds exactly
  the gun you put there. Each hand holsters and draws its own gun.
- Grip or Use at a holster: a gun in hand goes in; an empty hand draws. A gun in hand at a full holster swaps at
  once ("Quick Swap").
- One gun in, one gun out: a draw gives that one gun, in the hand that drew it. Brutal Doom's two-gun weapon goes in
  as its single gun and comes out as one; Brutal Doom's Dual keeps its own key.
- What each holster holds carries to the next level. A gun you did not have can go into the first empty holster
  ("New Guns Go to a Holster").
- The stored gun shows at its holster, with a light for its ammo: green, yellow (low or reload), red (empty). Small
  digits above it count its rounds ("Ammo Count on Holsters").
- A wireframe sphere on each holster when your hand is near, green with your hand inside.
- The rig hangs on your body, not your head. Look around and the holsters stay put; a stick or snap turn carries them
  round. A head held turned for a second is taken as your body turning and the rig eases round. It hangs from your
  neck, so nodding or looking down does not slide the holsters forward.
- Measure My Height scales the rig to your eye height. Seated hangs it from your seated eyes.
- Move Holsters by Hand: grip a sphere, carry it, let go. Four saved layouts: Standing A (Blue), Standing B (Orange),
  Seated A (Purple), Seated B (Yellow).
- The mirror: a copy of you about a metre out, front, back or both, so you can see your shoulders and back. Only you
  see it.

**The grenade spot.** On the belt buckle. Grip it and the hand grenade comes to your main hand: Brutal Doom's, or RSQ
Grenade's without Brutal Doom. Its light is your grenade count: green 2 or more, yellow 1, red none.

**The keyring.** The keys you carry hang on a ring on the front of your belt, off-hand side, swinging as you move.
"Keys Open Doors by Hand": grip the ring to take the keys, touch them to a locked door and it opens if one fits (the
game's own key check). The keyring is its own spot, moved and saved like a holster; it never takes or gives a gun.

**The throw.**
- Swing a hand fast and press, away from any holster, and the gun in it flies and lands as a pickup. The off hand
  throws on its grip. The main hand throws on a Use press with that swing ("Main Hand Throws With Use"), since its
  grip is the gun's own.
- A thrown gun that hits a monster hurts and staggers it, by the gun's weight and the throw speed ("Thrown Guns
  Hurt"); Doom's punch sound.
- Walking, running and snap turns are never a swing: only your arm counts.

**Move a gun to the other hand** (option, needs RSQ Gestures). Check your watch with the hand holding the gun and
press Use: the gun goes to the other hand. A gun already there comes back, so the two swap. Sabers, the ShieldSaw,
the cigarette and Zippo, fists and empty hands never move.

**The saber spots** (with RSQ Saber). Two spots just below the hips. The main saber's is on the main hand's side,
drawn and put away by the main hand; the second saber's is on the off hand's side, by the off hand. The second saber
has no key of its own, so its spot is the only way to put it away and take it out; it stays away until drawn there,
across levels and saves. "Saber on Hip Too" lets the saber clip to the hips as well.

**The torso and helmet** (option). A torso the holsters sit on, the Doom marine or Quake's Grunt, coloured by your
armour (green, blue) and breathing red at low health. It fades as you look down. With the marine, a helmet that only
the mirror shows.

**Ermac's cigarette.** Turn on "Cigarettes" and a pocket of three is yours from the start, on your left chest
pocket, refilled each level. The ritual:
- Main hand grips at the pocket: the cigarette is in that hand, the Zippo in the off hand. While it is out, Use
  belongs to the cigarette: no doors, switches or holsters on Use.
- Bring it to your mouth: a glow at its tip, a light tick and a soft click say it is in reach. Press Use and it stays
  in your mouth; your gun is back in that hand. Press Use anywhere else and you flick it away.
- In the mouth: off-hand trigger opens and lights the Zippo, again shuts it. Bring the flame to the cigarette (the
  glow and tick again) and press Use: it lights and you smoke for "Smoke Time (s)".
- Then it flicks out of your mouth, you exhale, the Zippo goes away and, with RSQ SlowMo loaded, the world slows for
  "Slow Motion Seconds" at "Slow Motion Speed". Use while smoking flicks it early; slow motion either way.
- Any weapon switch or holster press in either hand ends it: an unlit cigarette goes back in the pocket, a lit one is
  flicked away, the Zippo goes, and both hands get back the guns they had before. The Zippo always goes with the
  cigarette; nothing of either stays in a hand, and neither is ever a gun to the rig (no throw, no holster).

## How to play

Nothing needs binding. The rig reads the controller grips directly, and Use works at a holster too.

1. **First time.** Stand straight, look ahead, and press "Measure My Height" on the mod's front page (Options ->
   Radiant Silvergun Options -> RSQ Tactical Rig). Playing seated, turn on "Seated".
2. **Holster.** With a gun in your hand, reach to your hip. A sphere appears and turns green. Squeeze the grip: the
   gun goes in with a holster sound and a rumble, and your hand is empty. The gun shows hanging at the hip.
3. **Draw.** Empty hand to a full holster, squeeze the grip: the gun comes back.
4. **Swap.** Grip at a full holster with a gun in hand. The two swap.
5. **Cross-draw.** The chest holsters sit either side of your breastbone; the shoulders are reached over each
   shoulder. Reach across your body for the opposite chest holster.
6. **Grenade.** Grip at your belt buckle. The hand grenade is in your main hand. Grip there again to get your gun
   back.
7. **Throw a gun away.** Away from any holster, swing the hand hard toward an imp and press: the off hand's grip,
   or Use for the main hand. The gun flies, hits, the imp flinches and is shoved; the gun lands as a pickup.
8. **Keys to a door.** Turn on "Keys Open Doors by Hand". Look down at your belt: your keys hang on a ring. Grip the
   ring, hold the grip, and touch the keys to a locked door.
9. **Move a gun to the other hand.** With RSQ Gestures, turn on "Move Gun at Watch (Use)". Check your watch with the
   hand holding the gun (RSQ Gestures' watch check) and press Use.
10. **Lay out your holsters.** Turn on "Move Holsters by Hand". The mirror appears in front of you. Grip inside a
    sphere, carry it where you want it, let go. Save the layout under Holster Profiles. Turn the row off to play.
11. **Smoke.** Turn on "Cigarettes". Main hand to your left chest pocket, grip: the cigarette is in that hand, the
    Zippo in the other. Bring it to your lips (the controller ends up near your chin): glow, tick, click. Press Use:
    it is in your mouth. Off-hand trigger: the Zippo opens, lit. Bring the flame up to the cigarette: glow and tick.
    Press Use: it lights. Smoke. It flicks out of your mouth and the world slows.

If a grip does nothing, the grip key numbers are on Tuning and Debug as "Main Grip Keys" (446) and "Off Grip Keys"
(443 436). 446 is the main grip only with the engine's secondary button mappings off; Use always works.

## Settings

**RSQ Tactical Rig** (front page)

| Menu row | Default | What it does |
|---|---|---|
| Tactical Rig | On | The whole mod. |
| Grip Holsters | On | The grips holster and draw. |
| Use Holsters | On | Use holsters and draws too. |
| Move Gun at Watch (Use) | Off | While RSQ Gestures' watch check is up on a hand, Use moves that hand's gun to the other hand (a gun there swaps). Nothing without RSQ Gestures. |
| Reach | Standard | How big the holster spheres are: Tight, Standard, Easy. |
| Holster Rings | Hand Nearby | The wireframe sphere on each holster and the keyring: Never, Hand Nearby, Always. |
| Seated | Off | The rig hangs from your seated eyes. This machine only. |
| Measure My Height | | Scales the rig to your eye height. |
| Move Holsters by Hand | Off | Grip a sphere (a holster or the keyring), carry it, let go: it is saved. |
| Mirror | While Moving Holsters | A copy of you about a metre out: Off, While Moving Holsters, Always. Only you see it. |
| Holster Profiles | | Save and load four layouts: Standing A (Blue), Standing B (Orange), Seated A (Purple), Seated B (Yellow). The keyring's place is in them. |
| Torso | Off | A torso the holsters sit on, coloured by armour, breathing red at low health. |
| Torso Style | Doom marine | Doom marine or Quake Grunt. |
| Helmet | On | With the marine torso: a helmet only the mirror shows. |
| Cigarettes | Off | Ermac's cigarette pocket (3, refilled each level) and the ritual. |

**Rig Options**

| Menu row | Default | What it does |
|---|---|---|
| Quick Swap | On | A gun in hand at a full holster swaps at once. |
| Keep Holsters Between Levels | On | What each holster holds carries to the next level. |
| Ammo Light on Holsters | On | A full holster's light: green, yellow (low or reload), red (empty). |
| Ammo Count on Holsters | Off | Small digits above a full holster, in the ammo light's colour: its gun's rounds. |
| New Guns Go to a Holster | Off | A gun you did not have goes into the first empty holster. |
| Grenade Spot | On | The belt-buckle grenade spot: Brutal Doom's hand grenade, or RSQ Grenade's without Brutal Doom. |
| Throw Guns | On | A fast swing plus a press, outside a holster, throws the gun away. |
| Main Hand Throws With Use | On | The main hand also throws on a Use press with that swing (its grip is the gun's own). |
| Thrown Guns Hurt | On | A thrown gun that hits a monster hurts and staggers it, by the gun's weight and the throw speed. |
| Keyring | On | The keys you carry hang on a ring on your belt. |
| Keys Open Doors by Hand | Off | Grip the ring to take the keys; touch them to a locked door to open it. |
| Show Stored Guns | On | The holstered gun shows at its holster. |
| Stored Gun Size | Standard | Small, Standard, Large. |
| Haptics | On | Rumble on holster and draw. |
| Messages | Off | Text messages from the rig. |
| Mirror Shows | Both | Front, Back or Both. |
| Torso Fades Looking Down | On | The torso fades as you look down. |
| Holsters Hang From Neck | On | The rig hangs from your neck, not the headset: a nod does not slide the holsters. |
| Leave Shoulder to ShieldSaw | On | The off shoulder is left to RSQ ShieldSaw's shield while it hangs there. |
| Saber on Hip Too | Off | The saber also clips to the hips. |
| Slow Motion After a Smoke | On | RSQ SlowMo starts as the smoked cigarette flicks out of your mouth. |
| Refill Each Level | On | The cigarette pocket refills each level. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Holster Positions | | Sliders for each place (below). |
| Torso Fit | | Sliders for the torso and helmet (below). |
| Cigarette | | Sliders for the cigarette (below). |
| Reach | 1.0 | Scales every holster's radius. |
| Stored Gun Size | 1.0 | Size of the stored gun shown at its holster. |
| Stored Gun Length | 0.25 | Metres: every measured gun stored on the body. |
| Back Gun Length | 0.70 | Metres: a gun over the shoulders, on the back. |
| Stored Gun Turn | 0 | Degrees: turn every stored gun, for a pack whose models face another way. |
| Flip These Guns | (blank) | Weapon class names shown turned round. |
| Mirror Distance | 1.0 | Metres from your eyes to the mirror. |
| Body Turn Angle | 35 | A head held turned further than this is taken as your body turning. |
| Body Turn Delay | 1.00 | Seconds to wait first (0: at once). |
| Torso: Ignore Looking Down Past | 25 | Looking further down than this (degrees) never turns the torso. |
| Press Delay | 3 | Tics a hand must be in a holster before a press counts. |
| Throw Swing Speed (m/s) | 2.50 | How fast the hand must swing to throw a gun. |
| Thrown Gun Damage | 1.0 | Multiplier on thrown-gun hits. |
| Main Grip Keys | 446 | Key codes that are the main grip. |
| Off Grip Keys | 443 436 | Key codes that are the off grip. |
| Reset All | | Resets every RSQ Tactical Rig setting. |

*Holster Positions* (metres from your eyes in the body's frame: Forward, Left, Up and the sphere's Size; the
keyring's "Toward Off Hand" is mirrored for a left-handed layout)

| Place | Forward | Left | Up | Size |
|---|---|---|---|---|
| Left Hip | 0.00 | 0.18 | -0.70 | 0.14 |
| Right Hip | 0.00 | -0.18 | -0.70 | 0.14 |
| Grenade Spot | 0.12 | 0.00 | -0.62 | 0.08 |
| Left Chest | 0.10 | 0.12 | -0.46 | 0.11 |
| Right Chest | 0.10 | -0.12 | -0.46 | 0.11 |
| Keyring | 0.14 | 0.13 (Toward Off Hand) | -0.70 | 0.12 |
| Left Shoulder | -0.08 | 0.18 | -0.10 | 0.14 |
| Right Shoulder | -0.08 | -0.18 | -0.10 | 0.14 |
| Left Saber | 0.02 | 0.21 | -0.84 | 0.10 |
| Right Saber | 0.02 | -0.21 | -0.84 | 0.10 |

*Torso Fit*

| Menu row | Default | What it does |
|---|---|---|
| Height | -0.20 | Metres from your eyes down to the collar. |
| Forward | -0.04 | Metres forward of your eyes. |
| Size | 1.00 | The torso's size. |
| Helmet Height | 0.00 | Metres to raise or lower the helmet. |
| Low Health Glow | 35 | Health under which the torso breathes red. |

*Cigarette*

| Menu row | Default | What it does |
|---|---|---|
| Mouth Zone Size | 1.0 | How far from the mouth still counts (0.5 to 1.5). |
| Smoke Time (s) | 2.0 | Seconds you smoke once it is lit, before it flicks out (1 to 5). |
| Slow Motion Seconds | 6 | How long RSQ SlowMo runs after the flick. |
| Slow Motion Speed | 25 | How slow, percent speed. |
| Pack Size | 3 | How many in the pocket. |

## Works with

- **RSQ SlowMo:** the smoked cigarette flicking out of your mouth starts slow motion ("Slow Motion After a Smoke").
  Without RSQ SlowMo the ritual ends with the flick.
- **RSQ Gestures:** its watch check is what "Move Gun at Watch (Use)" waits for. Without it the row does nothing.
- **RSQ Grenade:** without Brutal Doom's hand grenade, the grenade spot hands out RSQ Grenade's grenade the same way,
  and its light counts those grenades in the kind's colour. Brutal Doom's comes first.
- **RSQ Distance Grab:** a hand in a holster, or holding the cigarette or Zippo, does not distance-grab; a hand
  lifting one of its doors is busy to the rig.
- **RSQ Saber:** the two saber spots below the hips; the second saber's spot puts it away and draws it. "Saber on Hip
  Too" adds the hips. With "Tactical Rig" off, a put-away second saber comes back to the off hand.
- **RSQ ShieldSaw:** the off shoulder is left to its stowed shield ("Leave Shoulder to ShieldSaw"). With the shield
  at the back or neck, or drawn by its key only, the shoulder is the rig's.
- **RSQ Score:** a draw from a holster feeds its Quick Draw; a thrown gun's hit and a Boomerang Gun's return pay
  bonuses.
- **RSQ Wheel:** badges a holstered gun's card with where it hangs.
- **RSQ Accessibility:** Handedness mirrors the cigarette pocket, the keyring and how stored guns hang; colour-blind
  holster colours; Photosensitive Mode; Gesture Ease; Text Size; Seated Play turns on the seated rig whenever it says
  you are seated; Rumble Strength scales every rig rumble. Inert without it.

**Gun Bonsai with the RSQ Gun Bonsai VR patch:** the Gunslinger tree. Quick Draw, Pair Draw and Showdown reward a
draw from a holster. Smoker makes the flick's slow motion run 2 s longer a level and nothing can hurt you while it
runs; Chain Smoker adds to the pack. Gun Toss makes a thrown gun hit x1.5, 2.0, 2.5 and stagger longer; Boomerang Gun
flies a thrown gun that hits back to the holster it came from (level 2: into your hand). The cigarette, the ammo
count and the keys are menu rows, never unlocks. Without the patch nothing changes.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s. Needs no other RSQ pk3; any order
among them.

## Known limits

- Holstered guns may look squashed. Check in the mirror.
- Only guns measured into the fit table show at a holster; the muzzle direction could not be read by eye for several
  (BrutalSMG, Rocket_Launcher, Plasma_Gun, Unmaker, GrenadeLauncher, BFG10k, Railgun, NukeLauncher, FlameCannon,
  HellishMissileLauncher, DSweap).
- The cigarette's Use takeover holds off the engine's use (doors, switches), the rig's Use holsters and the watch
  move. Hand-on-door systems in other mods (RSQ Distance Grab's and Brutal Doom VR's doors by hand) read the Use key
  themselves when a hand touches a door; they are not stood down.
- Main grip at the mouth or the pocket needs the main grip to reach the rig ("Main Grip Keys", 446 only with the
  engine's secondary button mappings off). Use always works for the mouth.
- The neck the rig hangs from (10 cm behind and 10 cm under your eyes) is an estimate, and the engine gives no
  headset roll, so a sideways head tilt is not taken out.
- SteamVR two-handed grip: a holster still takes the press, but a gun drawn into the off hand arrives only when you
  let go of the grip. Nothing happens on Quest.
- Brutal Doom Quest's per-gun hand poses are not copied into the mirror.
- Saved holster positions are kept over new defaults.
- Seated mode and the mirror are per machine. Other players see your hand props at your body, not your hand.
- The rig has about 60 user settings; every loaded mod's user settings share one size limit.

## For other mods

`RSQTR_RigService`, found by name:

- `GetInt("rig.region", "", hand)`: the holster that hand is in, or -1 (the console player only). Place 8 is the
  keyring; it answers 8 only while the keyring is carried in Move Holsters by Hand.
- `GetInt("rig.busy", "", hand, 0, pawn)`: 1 while the hand is in a holster, holds a Distance Grab door, the
  cigarette or the Zippo (the console player only).
- `GetInt("rig.drawtic", "", hand, 0, pawn)`: when that player last drew from a holster this map, or -1.
- `GetString("rig.drawn", "", hand, 0, pawn)`: the weapon class that draw brought up, or "".
- `GetInt("rig.holster", "<weapon class>", 0, 0, pawn)`: the place that gun is holstered in, or -1.
- `GetString("rig.regionname", "", place)`: that place's name ("Left hip", "Keyring", ...).

Holster profiles (`rsqtr_profile1..4`, "f,l,u,rad|..." by place index) hold index 8 as the keyring (its "l" is
toward the off hand).

What it asks of others, by name: RSQ SlowMo's `rsm_pulse` event; `RSQG_Service` (`inspect`); `RSQGN_Service`
(`kind.colour`); `RSQDG_DoorService` (`door.holding`); `RS_ScoreService` (`touch`); `RSQ_MeleeUpgradeService`
(`plevel`); RSQ Saber's `ubqs_dual_in` event; `RSQA_Service`.

## Credits

- **Ermac**: the vest and the cigarette are his ideas (Virtual Tactical Vest). The cigarette,
  butt and smoke come from that mod, whose credits name him as their modeller; the cigarette's
  texture is an atlas it shares with a Sketchfab cigarette-pack model (a real brand's pack art,
  blanked out here). The Zippo is the voxel lighter from his ZBlood-VR, credited to him there.
- **The marine torso** is the Doom Eternal Classic Slayer (id Software): a rip shared on
  Sketchfab, cut to torso and shoulder pads and recoloured green / blue / red in the project
  owner's RS_VRBody (provenance in its `models/marine/PROVENANCE.md`); skins halved to 1024
  here for the Quest.
- **The helmet** is the Doom Eternal Classic Slayer's helmet (id Software), a rip, prepared
  (shell, visor, interior; green / blue / red skins) in the project owner's RS_VRBody
  (provenance in its `models/helmet/PROVENANCE.md`).
- **The Quake torso** is Quake's Grunt (id Software, *Quake*, 1996): Vittorio Romeo's original
  Quake VR mod cut it into a torso, and the project owner's RS_VRBody recoloured its skin.
  Converted here from Quake's .mdl to MD3.
- The holster spheres are the project owner's, from his RS_Holsters.
- Holster, draw and foley sounds: RS_CombatFX (the project owner's effects library).
- The Zippo and cigarette sounds: Pixabay ("freesound_community"), "zippo-lighter-open-light-close" and
  "cigarette-suck".
- QuestZDoom: Emawind and Team Beef.
- Sharing other people's work in this pack is the project owner's decision.

RSQ_TacticalRig -- credits (from CREDITS.txt):

The Radiant Silvergun Quest Ermac Rig, part of the Radiant Silvergun Quest series. For stock QuestZDoom 17.3:
ZScript and lumps only, no engine changes. The code is new, written for this pack.

WHAT THIS PK3 SHIPS, AND WHOSE IT IS
- Ermac (iAmErmac -- DoomVR co-designer; Rusted Legacy, DXR):
  The idea: his Virtual Tactical Vest for Doom VR (body holsters, and the cigarette as a
  tribute). From that mod: the cigarette, the butt and the smoke (models/rsqtr/rtcig*,
  rtbutt.md3, graphics/RTCIGSMK.png); its credits name him as their modeller. The
  cigarette's texture is an atlas shared with a Sketchfab cigarette-pack model (a real
  brand's pack art, blanked out here).
  The Zippo (models/rsqtr/rtzippo*, rtzipfl.md3): the voxel lighter from his ZBlood-VR,
  credited to him there.
- id Software:
  The marine torso (models/rsqtr/rtmarine.iqm, rtmtor_*, rtmsho_*): the Doom Eternal Classic
  Slayer, a rip shared on Sketchfab, cut to torso and shoulder pads and recoloured
  green / blue / red in the project owner's RS_VRBody (its models/marine/PROVENANCE.md);
  skins halved to 1024 here for the Quest.
  The helmet (models/rsqtr/rthelm*): the Doom Eternal Classic Slayer's helmet, a rip,
  prepared in RS_VRBody (its models/helmet/PROVENANCE.md): shell, visor, interior, with
  green / blue / red skins.
  The Quake torso (models/rsqtr/rttorso*): Quake's Grunt (Quake, 1996), cut into a torso by
  Vittorio Romeo's original Quake VR mod and recoloured in RS_VRBody; converted here from
  Quake's .mdl to MD3 (tools/mdl2md3.py).
- The project owner (presidentkoopa):
  The holster spheres (models/rsqtr/rtwire*), from his RS_Holsters.
  Holster, draw and foley sounds (sounds/rsqtr/rthols*, rtdraw, rtfoly*), from his
  RS_CombatFX effects library.
- Pixabay ("freesound_community", Pixabay Content License; chosen by the owner):
  the Zippo and cigarette sounds: "zippo-lighter-open-light-close" (rtzpopen, rtzplite,
  rtzpclos) and "cigarette-suck" (rtinhale, rtexhale), trimmed and converted to mono OGG.
- Generated for this pack:
  The stored-gun fit table RSQTRFIT (tools/measure_pickups.py), the placeholder sprites.
- QuestZDoom (Emawind and Team Beef):
  The engine, and the off-hand weapon and hand-pose script API the rig reads.

SHARING
- Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors'
  terms; sharing other people's work in this pack is the project owner's decision.

A thrown gun striking a body plays stock Doom's punch (doom2.wad DSPUNCH; SNDINFO.txt).
