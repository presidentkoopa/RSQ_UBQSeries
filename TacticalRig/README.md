# RSQ Tactical Rig

Guns holstered on your body. Reach to a hip, the chest or a shoulder and grip to put a gun away or draw
it. Also: a grenade spot on the belt buckle, a keyring, throwing a gun away, saber spots, a mirror, an
optional torso and helmet, and Ermac's cigarette (optional). Part of the Radiant Silvergun Quest series,
for stock QuestZDoom 17.3 (script only, no engine changes). Built on Ermac's idea, his Virtual Tactical
Vest for Doom VR; this is a new implementation that keeps the rig on your body, not your head.

## Load order

```
doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3
          -> BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> RSQ_TacticalRig.pk3   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** loads and the holsters work (rig-tested on vanilla doom2 with the
  series, 10-27). What needs Brutal Doom: the stored-gun pictures (only guns measured from the Brutal
  Doom load order are shown) and Brutal Doom's empty hand (otherwise your empty hand is the fist). The grenade
  spot shows when Brutal Doom's `HandGrenades` exists, or (11-01) RSQ Grenade's own grenade without Brutal Doom.
- **Other RSQ pk3s needed:** none. RSQ SlowMo is needed only for slow motion after a smoke; RSQ Saber
  only for the saber spots.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Tactical Rig.
- **Buttons to bind:** none. The rig reads the controller grips directly, and Use works too (*Use
  Holsters*).
- If a grip does nothing: the grip key numbers are on *Tuning and Debug* as *Main Grip Keys* (446) and
  *Off Grip Keys* (443 436). 446 is the main grip only with the engine's secondary button mappings off;
  Use always works.
- First time: stand straight, look ahead, and press *Measure My Height* on the front page. Playing
  seated: turn on *Seated*.

## What to do in VR

- **Holster:** reach to a holster with a gun in your hand and squeeze the grip. The hand is left empty.
- **Draw:** reach to a full holster with an empty hand and squeeze the grip.
- **Swap:** grip at a full holster with a gun in hand. The two swap.
- **Grenade:** grip at the belt buckle. The hand grenade comes to your main hand (Brutal Doom's, or RSQ
  Grenade's without Brutal Doom). Grip there again to get your gun back.
- **Throw a gun away:** swing the hand fast and grip, away from any holster. The gun flies and lands as a
  pickup.
- **Keys to a door (option):** grip at the keyring, hold the grip, touch the keys to a locked door.
- **Move a gun to the other hand (option, needs RSQ Gestures):** turn on *Move Gun at Watch (Use)*. Check
  your watch with the hand holding the gun (RSQ Gestures' watch check, the one that shows RSQ Gun Cards'
  watch card) and press Use: the gun goes to the other hand. A gun already in the other hand comes back (they
  swap). The hand left empty holds its empty hand (Brutal Doom's hands, or nothing / the fist).
- **Move a holster (option):** turn on *Move Holsters by Hand*, grip inside a sphere, carry it, let go. The
  keyring moves the same way.
- **Cigarette (option):** main hand grips at the left chest pocket; bring it to your mouth and pull the
  trigger; off-hand trigger opens the Zippo; hold the flame to the tip; off-hand trigger again to smoke
  and spit it out.

## Holsters

Six gun holsters: left hip, right hip, left chest, right chest, left shoulder, right shoulder. Two saber
spots just below the hips (with RSQ Saber): the main saber's on the main hand's side, drawn and put away
by the main hand; the second saber's on the off hand's side, by the off hand. The second saber has no key
of its own, so its spot is the only way to put it away and take it out; it stays away until drawn there
(across map changes and saves). The grenade spot is on the belt buckle. A holster holds exactly the gun
you put there. Each hand holsters and draws its own gun. Brutal Doom's Dual keeps its own key (*Draw
Pairs*: Never).

The keyring is a spot of its own (2026-11-01): by default on the front of the belt, off-hand side (0.14 m
forward, 0.13 m toward the off hand, 0.70 m under the eyes, sphere 0.12 m), where it always hung. It has a
sphere like the holsters, moves with *Move Holsters by Hand*, is saved and loaded with the holster profiles,
and has its own sliders (*Holster Positions: Keyring*). It is not a gun holster: gripping it never takes or
gives a gun, only the keys (with *Keys Open Doors by Hand*).

Moving a gun to the other hand (*Move Gun at Watch (Use)*) follows the holsters' rules: sabers, the
ShieldSaw, the cigarette and Zippo, fists / empty hands and Brutal Doom's off-hand dual copies never move,
and a hand holding one of those blocks the move. Brutal Doom's Dual stays on its own key. While either
hand is inside a holster, Use belongs to that holster and nothing moves.

## Features

Rows are on the front page unless a page is named. "On" = on by default (CVARINFO); "Option" = off by
default.

| Menu row | Default | What it does |
|---|---|---|
| Tactical Rig | On | The whole mod. |
| Grip Holsters | On | The grips holster and draw. |
| Use Holsters | On | Use holsters and draws too. |
| Move Gun at Watch (Use) | Option | While RSQ Gestures' watch check is up on a hand, Use moves that hand's gun to the other hand (a gun there swaps). Does nothing without RSQ Gestures. |
| Reach | Standard | How big the holster spheres are: Tight / Standard / Easy. |
| Holster Rings | Hand Nearby | The wireframe sphere on each holster and the keyring: Never / Hand Nearby / Always. Green with your hand inside. |
| Draw Pairs | Never | Bring Brutal Doom's off-hand copy along: Never / If Holstered as a Pair / Always. |
| Seated | Option | The rig hangs from your seated eyes. This machine only. |
| Measure My Height | - | Scales the rig to your eye height. |
| Move Holsters by Hand | Option | Grip a sphere (a holster or the keyring), carry it, let go: it is saved. |
| Mirror | While Moving Holsters | A copy of you about a metre out: Off / While Moving Holsters / Always. Only you see it. |
| Holster Profiles | - | Save and load four layouts: Standing A (Blue), Standing B (Orange), Seated A (Purple), Seated B (Yellow). The keyring's place is in them; a profile saved before 2026-11-01 puts the keyring at its default. |
| Torso | Option | A torso the holsters sit on, coloured by armour, breathing red at low health. |
| Torso Style | Doom marine | Doom marine or Quake Grunt. |
| Helmet | On | With the marine torso: a helmet only mirrors show. |
| Cigarettes | Option | Ermac's cigarette pocket (3, refilled each level). |
| Rig Options: Quick Swap | On | A gun in hand at a full holster swaps at once. |
| Rig Options: Keep Holsters Between Levels | On | What each holster holds carries to the next level. |
| Rig Options: Ammo Light on Holsters | On | A full holster's light: green, yellow (low or reload), red (empty). |
| Rig Options: Ammo Count on Holsters | Option | Small digits above a full holster, in the ammo light's colour: its gun's rounds (the magazine for a gun that has one). |
| Rig Options: New Guns Go to a Holster | Option | A gun you did not have goes into the first empty holster. |
| Rig Options: Grenade Spot | On | The belt-buckle grenade spot: Brutal Doom's hand grenade, or RSQ Grenade's without Brutal Doom. Its light is your grenade count: green 2+, yellow 1, red none. |
| Rig Options: Throw Guns | On | A fast swing plus grip, outside a holster, throws the gun away. |
| Rig Options: Thrown Guns Hurt | On | A thrown gun that hits a monster hurts and staggers it, by the gun's weight and the throw speed. |
| Rig Options: Keyring | On | The keys you carry hang on a ring on your belt. |
| Rig Options: Keys Open Doors by Hand | Option | Grip the ring to take the keys; touch them to a locked door to open it (the game's own key check). |
| Rig Options: Show Stored Guns | On | The holstered gun shows at its holster. *Stored Gun Size*: Small / Standard / Large. |
| Rig Options: Haptics | On | Rumble on holster and draw. |
| Rig Options: Messages | Option | Text messages from the rig. |
| Rig Options: Mirror Shows | Both | Front / Back / Both. |
| Rig Options: Torso Fades Looking Down | On | The torso fades as you look down. |
| Rig Options: Leave Shoulder to ShieldSaw | On | The off shoulder is left to RSQ ShieldSaw's shield while it hangs there. |
| Rig Options: Saber on Hip Too | Option | The saber also clips to the hips. |
| Rig Options: Slow Motion After a Smoke | On | RSQ SlowMo starts as you spit the cigarette out (6 s at 25 %, on the *Cigarette* page). |
| Rig Options: Refill Each Level | On | The cigarette pocket refills each level. |
| Tuning and Debug: Holster Positions / Torso Fit / Cigarette | - | Sliders for each holster and the keyring (its *Toward Off Hand* is mirrored for a left-handed layout), the torso and helmet, and the cigarette. |
| Tuning and Debug: Throw Swing Speed (m/s) | 2.5 | How fast the hand must swing to throw a gun. |
| Tuning and Debug: Thrown Gun Damage | 1.0 | Multiplier on thrown-gun hits. |
| Tuning and Debug: Reset All | - | Resets every Tactical Rig setting. |

The throw debug log (`rsqtr_debug_throw`) is not on the menu.

## Test it

Items marked **(not yet headset-confirmed)** were built on 2026-10-31 or later and only ran on the
simulated rig.

1. Load the pack. Options -> Radiant Silvergun Options shows *RSQ Tactical Rig*. No script error.
2. Press *Measure My Height* standing straight.
3. Hold a gun, reach to the right hip. A sphere appears and turns green. Grip: the gun goes in, your hand
   is empty, you hear a holster sound and feel a rumble. The gun shows hanging at the hip.
4. Empty hand to the right hip, grip: the gun comes back.
5. Try both chest holsters (cross-draw) and both shoulders. **(the chest pair is new on 10-31, not yet
   headset-confirmed)**
6. Holster the shotgun, walk to the next level. It is still in that holster (*Keep Holsters Between
   Levels*). **(not yet headset-confirmed)**
7. Grip at the belt buckle. The hand grenade comes to your main hand; the buckle light shows your count.
   Grip there again: your gun is back. **(not yet headset-confirmed)**
8. Walk and turn with a gun and the grip held normally. The gun must **not** be thrown.
   **(not yet headset-confirmed)**
9. Swing hard and grip, away from any holster, at an imp. The gun flies, hits, the imp flinches, freezes
   briefly and is shoved; you hear Doom's punch. The gun lands as a pickup. **(not yet headset-confirmed)**
10. Look down at the belt: your keys hang on a ring. Turn on *Keys Open Doors by Hand*, grip the ring,
    touch the keys to a locked door. It opens if one fits; otherwise "you need a key".
    **(not yet headset-confirmed)**
11. Turn on *Ammo Count on Holsters*. Small digits float above a full holster while its ring shows.
    **(not yet headset-confirmed)**
12. Set *Mirror* to Always. Check a holstered gun in the mirror: does it look squashed? (open issue
    below). **(not yet headset-confirmed)**
13. Turn on *Torso*. Look down: the marine torso, green or blue with your armour, fading as you look
    down. *Helmet* shows only in the mirror.
14. Turn on *Cigarettes*. Main hand grips at the left chest pocket: the cigarette is in that hand, the
    Zippo in the off hand. Bring it to your mouth, pull the main trigger: it stays at your mouth and your
    gun is back. Off-hand trigger: the Zippo opens. Hold the flame to the tip: it lights. Off-hand trigger
    again: it flares, you spit it out end over end, and (with RSQ SlowMo) the world slows for 6 s. The
    butt smoulders where it lands and draws monsters. **(reworked 10-31, not yet headset-confirmed)**
15. Turn on *Move Holsters by Hand*: grip a sphere, move it, let go. Turn it off to play.
16. With RSQ Saber (Start With Dual Sabers On): off hand to the second saber's spot below the off-side hip,
    grip: the second saber goes in and the off hand holds the Force (Brutal Doom Quest's fist, or the bare
    Force hand). Grip again: it comes back to the off hand. The main hand there does nothing.
    **(not yet headset-confirmed; rig: the saber's in / out events logged, 11-01)**
17. With RSQ Accessibility, Seated Play Seated (or Auto once it has seen you sit), this mod's own *Seated* Off:
    sit down. The holsters hang from your seated eyes, in reach, as with *Seated* On. Seated Play Standing:
    as before. **(not yet headset-confirmed; rig: headset at 1.2 m, the rig hung from 90 instead of 97, the
    left hip at 70.2 instead of 77.2)**
18. With RSQ Accessibility: Rumble Strength 0, reach into a holster: no rumble. 2: stronger.
    **(not yet headset-confirmed)**
19. With RSQ Gestures: turn on *Move Gun at Watch (Use)*. Gun in the main hand, off hand empty: check your
    watch with the main hand and press Use. The gun goes to the off hand; the main hand is empty. Check your
    watch with the off hand and press Use: it comes back. Gun in both hands: the two swap. Turn the row off:
    Use at the watch check does nothing. Off hand in a hip holster while you press Use: the holster acts,
    no gun moves. **(not yet headset-confirmed; rig 11-01: plain Doom 2 pistol / shotgun across, back and
    swapped both ways; Brutal Doom order Rifle and Shot_Gun across and back, Brutal Doom's hands in the
    empty off hand; nothing with the row off or a hand in a holster)**
20. Turn on *Holster Rings* Always: a sphere shows at the keyring. Turn on *Move Holsters by Hand*, grip the
    keyring's sphere, carry it, let go: the keys hang there now. Save a holster profile, move the keyring
    again, load the profile: it is back. **(not yet headset-confirmed; rig 11-01: moved by hand to 0.30
    forward, 0.60 under the eyes; saved, moved, loaded back; an older profile put it at its default)**

## Works with

- **RSQ Gestures:** its watch check is what *Move Gun at Watch (Use)* waits for (asked by name). Without
  it there is no watch check and the row does nothing.
- **RSQ SlowMo:** spitting out the cigarette starts slow motion (*Slow Motion After a Smoke*).
- **RSQ Grenade** (2026-11-01, asked by name): without Brutal Doom's `HandGrenades`, the grenade spot hands out RSQ
  Grenade's grenade the same way (grip at the buckle: the grenade to the main hand; grip again: your gun back) and
  its light counts those grenades. Brutal Doom's comes first (with Brutal Doom VR loaded RSQ Grenade stands down).
  Rig 11-01 (`gren_rig_b`, plain Doom 2): out at the buckle, the pistol back on the second grip; Brutal Doom order
  (`gren_load_c2`): Brutal Doom's `HandGrenades` handed out as before. Not yet headset-confirmed.
- **RSQ Distance Grab:** doors are lifted there now, not here. A hand in a holster, or holding the
  cigarette or Zippo, does not distance-grab.
- **RSQ Saber:** the two saber spots below the hips; the second saber's spot puts it away and draws it
  (off hand). *Saber on Hip Too* adds the hips. With the rig's *Tactical Rig* switch Off, a put-away second
  saber comes back to the off hand.
- **RSQ ShieldSaw:** the off shoulder is left to its stowed shield (*Leave Shoulder to ShieldSaw*).
- **RSQ Accessibility:** Handedness also mirrors the cigarette pocket and how stored guns hang;
  colour-blind holster colours; Photosensitive Mode; Gesture Ease; Text Size. Shared settings only act
  with it loaded. Also (2026-11-01, not yet headset-confirmed): Seated Play turns on the seated rig (it hangs
  from your seated eyes) whenever Accessibility says you are seated, as well as with this mod's own *Seated*
  row; Rumble Strength scales every rig rumble. Steady Hands is not used: the holsters, pocket and key ring are
  reach-in tests (where the hand is), not pointing, so they read the raw hand. The rig has no tap windows, so
  Slower Taps changes nothing here.
- **Gun Bonsai VR patch:** some of its perks need the rig (and SlowMo).

## Known limits / open issues

- **Holstered guns may look squashed** (a model flag was tried and backed out because it could not be
  checked on the rig). Check in the mirror.
- **Zippo and cigarette sounds (2026-11-01):** real recordings from Pixabay, picked by the owner (open, light,
  close; the drag and the breath after it; the tip catching uses the Zippo's light). Not yet heard in the headset.
- SteamVR two-handed grip: a holster still takes the press, but a gun drawn into the off hand arrives only
  when you let go of the grip (the engine holds it). Nothing happens on Quest today.
- Only guns measured into the fit table show at a holster; the muzzle direction could not be read by eye
  for several (BrutalSMG, Rocket_Launcher, Plasma_Gun, Unmaker, GrenadeLauncher, BFG10k, Railgun,
  NukeLauncher, FlameCannon, HellishMissileLauncher, DSweap).
- The second saber's holster: rig-tested by its network events only (11-01), not yet with a real grip in
  the headset.
- Brutal Doom Quest's per-gun hand poses are not copied into the mirror.
- Saved holster positions are kept over new defaults.
- Seated mode and the mirror are per machine. Other players see your hand props at your body, not your
  hand.
- The rig has about 60 user settings; every loaded mod's user settings share one size limit.
- Earlier docs said Ermac's cigarette heals you under 35 health and that a *Zippo Lights It* switch
  exists. Neither is in the current code or menu.

## Credits

From the old README, unchanged:

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

RSQ_TacticalRig -- credits (from CREDITS.txt, unchanged):

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
- Pixabay ("freesound_community", Pixabay Content License; chosen by the owner, 2026-11-01):
  the Zippo and cigarette sounds (rtzpopen, rtzplite, rtzpclos, rtinhale, rtexhale).
- Generated for this pack:
  The stored-gun fit table RSQTRFIT (tools/measure_pickups.py), the placeholder sprites.
- QuestZDoom (Emawind and Team Beef):
  The engine, and the off-hand weapon and hand-pose script API the rig reads.

SHARING
- Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors'
  terms; sharing other people's work in this pack is the project owner's decision.

A thrown gun striking a body plays stock Doom's punch (doom2.wad DSPUNCH; SNDINFO.txt).

## For other mods

`RSQTR_RigService` (found by name): `rig.region` (the holster a hand is in, or -1), `rig.busy` (1 while a
hand is in a holster, holds a Distance Grab door, the cigarette or the Zippo), `rig.drawtic` /
`rig.drawn` (when that player last drew from a holster and what came out). `rig.regionname` names place 8
"Keyring"; `rig.region` answers 8 only while the keyring is carried in *Move Holsters by Hand*.
Holster profiles (`rsqtr_profile1..4`, "f,l,u,rad|..." by place index) now fill index 8 with the keyring
(its "l" is toward the off hand); it was empty before. This section is for modders, not for play.
