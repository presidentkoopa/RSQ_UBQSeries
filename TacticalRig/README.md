# RSQ Tactical Rig

Your guns live on your body: reach for your hip, chest or shoulder, grip, and the gun is in your hand.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. Built on
Ermac's idea, his Virtual Tactical Vest for Doom VR, with new code that reads your real controller poses.

## Standout feature: a holster rig you work with your hands

Six gun holsters hang on your body: both hips, both sides of the chest and both shoulders. Put your hand in one and
your controller ticks. Grip with a gun in that hand and it goes in. Grip again with the hand empty and you draw it
back out. Each holster holds exactly the gun you put there, and nothing else ever moves it. Hold a gun at a full
holster and the two swap in one motion. Each hand works its own holsters, so you can draw a pistol with your off
hand while the rifle stays in your main hand.

With Brutal Doom's weapons, the stored gun hangs where you put it, drawn with the 3D model you hold in your hand:
muzzle down at the hips, butt toward the middle on the chest, slung across your back from the shoulders. Look down and you see your loadout.
A small light in each full holster shows its ammo: green, yellow when low or needing a reload, red and blinking
when empty.

None of this exists in QuestZDoom. The engine gives scripts your hand positions and nothing more. Everything else
here (the body, the holsters, the torso that follows your turns) is worked out in ZScript, every tic.

## Features

**Holsters**
- Six gun holsters, one gun each, any gun. A gun put in one holster leaves any other it was in.
- Quick Swap: a gun in your hand at a full holster swaps at once, no wait.
- Each holster's ring fades in as a hand comes near and turns green with the hand inside.
- Holsters keep their guns from level to level. After a death or pistol start a holster stays empty until you
  own that gun again, then it is back where you kept it.
- Optional: new guns you pick up go straight into the first empty holster (off by default).
- Optional: each full holster shows its round count as small digits above the ring (off by default).
- Brutal Doom's two-gun weapons (dual pistols and the like) go in as one gun, so a draw gives you one.

**The torso**
- The holsters hang on a torso that turns with stick turns: every snap and smooth turn carries it round exactly.
  Looking around never moves it.
- Room turns are followed when you hold your gun ready. Turn your real body in the room with both hands in front of
  you, at chest or gun-ready height: once your head has been 45 degrees or more off the torso for 1.5 s, the torso
  eases round to face you. Reaching to a holster, glancing aside or looking down never turns it.
- Recenter by hand: hold both controllers against your chest for 0.4 s and the torso snaps to where you face, with a
  soft click and a tick in both hands. Or bind the Recenter Torso key.
- It recenters on its own at map start, level change, loaded save and respawn.
- The rig hangs from your neck, not your face, so a nod to look down at a holster does not slide it away.
- Optional visible torso (off by default): the Doom marine or Quake's Grunt, coloured by your armour, breathing red
  at low health, fading as you look down so your holsters stay in view. The marine wears a helmet that only shows in
  mirrors, and a map's mirrors show the 3D guns and hands you are actually holding.

**More on the body**
- Grenade spot on the belt buckle: grip it and the pack's hand grenade comes to your main hand; grip again and your
  gun comes back. A grenade hangs there while you have one, and its light shows the count (green 2+, yellow 1, red 0).
- Keyring beside it: every key you carry hangs from a ring on your belt, swaying as you move.
- Optional: take the keys off the ring and touch them to a locked door to open it (off by default).
- Two saber spots below the hips for RSQ Saber's hilts, each on its own hand's side.

**Throw your gun**
- Swing hard and press: the gun leaves your hand, flies with your swing and lands as a pickup.
- A thrown gun that hits a monster hurts and staggers it. Heavier guns and harder throws hit harder.

**Fit it to you**
- Measure My Height scales the whole rig to your body.
- Seated play: the rig hangs from your seated eyes.
- Move Holsters by Hand: grab any holster, carry it where you want, let go. A mirror in front of you shows your front
  and back while you do it.
- Four holster profiles (two standing, two seated), each with its own ring colour.

**Ermac's cigarette** (optional tribute, off by default)
- A pocket of cigarettes on your chest. Put one in your mouth, light it with the Zippo in your off hand, smoke,
  flick it away, and the world drops into slow motion (with RSQ SlowMo loaded).

## How To Play

1. Add RSQ_TacticalRig.pk3 to your load order and play in VR: the rig switches itself off without controllers.
2. Stand straight and pick Options → Radiant Silvergun Options → RSQ Tactical Rig → Measure My Height. Sitting? Turn
   on Seated.
3. Pick up a gun. Lower your hand to your hip until the controller ticks and the ring turns green. Grip. The gun is
   holstered and your hand is empty.
4. Hand back at the hip, grip: drawn. Try a shoulder with a long gun, a chest holster for a cross-draw.
5. Fill all six. Now swap in a fight: gun in hand at a full holster, one grip, new gun out.
6. Turn your body in the room with your gun up, and feel the holsters come round after you. If they ever end up
   off to one side, put both controllers on your chest for a moment.
7. Holsters not where your hands fall? Turn on Move Holsters by Hand and drag them.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Holster a gun | Hand with a gun inside a holster ring, then grip (or Use) | A full holster swaps: its gun comes out to that hand |
| Draw a gun | Empty hand inside a full holster, then grip (or Use) | Each hand draws into itself |
| Throw a gun | Swing the hand fast (2.5 m/s) outside every holster, then grip, or Use with the main hand | Lands as a pickup you can take again |
| Grenade | Either hand at the belt buckle, grip | Again with the grenade in hand: your gun comes back |
| Saber | Main hand at the main-side saber spot, off hand at the other | Needs RSQ Saber; a saber put on any empty holster goes to its own spot |
| Whip | The whip's hand at the whip holster, grip (or Use): put away, or drawn | Needs RSQ Whip. Main-hand hip, 8 cm behind and 9 cm outside the saber spot, same height; the hand RSQ Whip's Whip In names. Never goes in a gun holster: a draw from another holster, the weapon wheel or a slot key leaves it in its own; a whip put on an empty gun holster goes home |
| Flare | Off hand at the flare holster, grip: an unlit flare comes up; grip with an unlit flare: it goes back | Needs RSQ FnF; the mirror of the whip holster on the off-hand hip, the same flares as FnF's chest pocket. A lit flare cannot go in (FnF's rule: the grip drops it at your feet, burning). An off-hand draw from another holster puts an unlit flare back here, lets a lit one fall |
| Recenter torso | Both controllers against your chest (within 0.20 m of a point 0.30 m under your eyes) for 0.4 s | No grip, Use or fire held; let go before doing it again |
| Recenter Torso key | Bindable: Customize Controls → RSQ Tactical Rig, or the rig's own page | |
| Move a holster | Move Holsters by Hand on: grip inside a ring, carry it, let go | The keyring moves the same way |
| Keys to a door | Keys Open Doors by Hand on: grip at the keyring, hold, touch a locked door | The engine's own lock check decides |
| Move a gun to the other hand | Move Gun at Watch on, RSQ Gestures loaded: hold the watch check, press Use | A gun in the other hand swaps |
| Cigarette | Main hand at the chest pocket (left chest for right-handers), grip or Use | Cigarette in the main hand, Zippo in the off hand |
| ...into the mouth | Cigarette at your lips, Use | Use anywhere else flicks it away |
| ...light it | Zippo's flame at the tip, off-hand fire | Off-hand fire elsewhere flicks the lid open or shut |
| ...finish | Use while smoking flicks it early | Any holster grip or weapon switch also ends it |

- Use acts for whichever hand is in a holster, the main hand first. The main hand's grip reaches the rig only when
  the engine sends it as a key (its secondary button mappings off); Use always works. The grip keys can be changed
  under Tuning and Debug.
- A hand must rest in a holster for 3 tics before a press counts, so a hand passing through does nothing.
- On PC (SteamVR), an off-hand draw made while the engine is steadying a two-handed gun arrives when you let go of
  the grip.
- Left-handed: the engine's left-handed setting swaps main and off hand, the saber spots and the shield's shoulder.
  The cigarette pocket and the way guns hang mirror too (following RSQ Accessibility's handedness when it is loaded).

## Menu

Options → Radiant Silvergun Options → RSQ Tactical Rig

| Row | Default | What it does |
|---|---|---|
| Tactical Rig | On | The whole rig |
| Grip Holsters | On | Grips holster and draw |
| Use Holsters | On | Use holsters and draws too |
| Move Gun at Watch (Use) | Off | Use during RSQ Gestures' watch check moves that hand's gun across |
| Reach | Standard | Holster size: Tight, Standard, Easy |
| Holster Rings | Hand Nearby | Never, Hand Nearby, Always |
| Seated | Off | Hang the rig from your seated eyes (this machine only) |
| Measure My Height | | Reads your headset height and scales the rig |
| Move Holsters by Hand | Off | Grab and place holsters |
| Mirror | While Moving Holsters | Off, While Moving Holsters, Always |
| Holster Profiles | | Save and load four layouts |
| Torso Follows Room Turns | On | The torso follows a real turn made with your hands in front |
| Recenter: Both Hands to Chest | On | The recenter gesture |
| Recenter Torso | | Bind the recenter key |
| Torso | Off | Show a torso |
| Torso Style | Doom marine | Doom marine or Quake Grunt |
| Helmet | On | The marine's helmet, seen in mirrors |
| Cigarettes | Off | Ermac's cigarette pocket |

**Rig Options**

| Row | Default | What it does |
|---|---|---|
| Quick Swap | On | A full holster swaps without the press delay |
| Keep Holsters Between Levels | On | Holsters keep their guns |
| Ammo Light on Holsters | On | The green / yellow / red light |
| Ammo Count on Holsters | Off | Round count above each full holster |
| New Guns Go to a Holster | Off | A new gun fills the first empty holster |
| Grenade Spot | On | The belt-buckle grenade |
| Show Grenade in Holster | On | A grenade hangs there while you have one |
| Throw Guns | On | Swing-and-press throws |
| Main Hand Throws With Use | On | The main hand throws on Use |
| Thrown Guns Hurt | On | Thrown guns damage and stagger |
| Keyring | On | Keys on your belt |
| Keys Open Doors by Hand | Off | Touch keys to locked doors |
| Show Stored Guns | On | Holstered guns drawn on the body |
| Stored Gun Size | Standard | Small, Standard, Large |
| Haptics | On | Controller ticks |
| Messages | Off | Short text notes |
| Mirror Shows | Both | Front, Back or Both |
| Torso Fades Looking Down | On | The torso thins as you look down |
| Holsters Hang From Neck | On | A nod does not slide the rig |
| Torso Turns With Head and Hands | Off | Older turn rule: head and both hands turning together |
| Torso Catches Up With Head | Off | Older turn rule: a head held round eases the torso after it |
| Leave Shoulder to ShieldSaw | On | Off shoulder is the shield's while it is stowed there |
| Saber on Hip Too | Off | The main saber also clips to the hips |
| Whip Holster | On | RSQ Whip's whip has its own holster on the main-hand hip |
| Show Whip in Holster | On | The whip hangs coiled there while it is in neither hand |
| Flare Holster | On | RSQ FnF's flares have their own holster on the off-hand hip |
| Show Flare in Holster | On | A flare hangs there while you carry one |
| Slow Motion After a Smoke | On | RSQ SlowMo when the cigarette is flicked |
| Refill Each Level | On | The pocket refills |

**Holster Profiles**: Save and Load for Standing A (blue), Standing B (orange), Seated A (purple), Seated B (yellow).

**Tuning and Debug**: Reach (1.0), Stored Gun Size (1.0), Stored Gun Length (0.25 m), Back Gun Length (0.70 m),
Stored Gun Turn (0), Flip These Guns (blank), Mirror Distance (1.0 m), Body Turn Angle (35) and Body Turn Delay
(1.0 s) for Torso Catches Up With Head, Torso: Ignore Looking Down Past (25 degrees), Press Delay (3 tics), Throw
Swing Speed (2.5 m/s), Thrown Gun Damage (1.0), Main Grip Keys (446), Off Grip Keys (443 436), Reset All. Sub pages:
- Holster Positions: forward, left, up and size in metres from your eyes for every holster, the grenade spot, the
  keyring, both saber spots, the whip holster and the flare holster (their side value is toward the main hand for the
  whip, toward the off hand for the flare: 0.06 m back, 0.30 m out, 0.84 m down, size 0.09). Hips 0.70 m down, 0.18 m out; chest 0.46 down, 0.12 out, 0.10 forward; shoulders
  0.10 down, 0.18 out, 0.08 back.
- Torso Fit: Height (-0.20 m), Forward (-0.04 m), Size (1.0), Helmet Height (0), Low Health Glow (under 35).
- Cigarette: Mouth Zone Size (1.0), Mouth Cigarette Forward (0.12 m), Mouth Cigarette Down (0.07 m), Smoke Time
  (2 s), Slow Motion Seconds (6), Slow Motion Speed (25%), Pack Size (3).

## Works with

Runs alone on any load order. It finds the rest by name:
- **Brutal Doom / BD22 VR Reloaded**: stored guns are drawn with the measured 3D models of Brutal Doom's weapon set
  (a gun missing from that table is not drawn on the body); the grenade spot hands out Brutal Doom's VR grenade; an
  empty off hand gets BD22 VR's hands; off-hand draws use its off-hand gun copies.
- **RSQ Grenade**: without Brutal Doom's grenade, the spot hands out RSQ Grenade's, and glows in the colour of the
  kind in your hand.
- **RSQ Saber**: the two saber spots appear, and holster and draw both hilts.
- **RSQ ShieldSaw**: its shield hangs on this torso and turns with it; its Recenter key recenters both. The off
  shoulder is left to the stowed shield.
- **RSQ Gestures**: the watch-check gun move.
- **RSQ SlowMo**: the slow motion after a smoke.
- **RSQ Accessibility**: Seated Play, handedness, rumble strength, text size and colour-blind ring colours apply here.
- **RSQ Distance Grab** leaves a hand alone while it is in a holster or holds the cigarette or Zippo; **RSQ Melee**'s
  Headlock waits while your off hand is in a holster.
- **RSQ Wheel** marks where a gun is holstered; **RSQ Score** reads holster draws for its quick-draw bonus; **RSQ
  FlashFlare** hangs its pocket on this torso.
- **Gun Bonsai + RSQ Gun Bonsai VR**: Gun Toss makes thrown guns hit harder and stagger longer; Boomerang Gun flies a
  thrown gun back to its holster, or to your hand at level 2; Smoker lengthens the smoke's slow motion and makes you
  untouchable through it; Chain Smoker adds cigarettes to the pack.

## Credits and licence

- **Ermac** (iAmErmac, DoomVR co-designer; Rusted Legacy, DXR): the idea, his Virtual Tactical Vest for Doom VR, and
  the cigarette tribute. From that mod, the cigarette, butt and smoke, modelled by him. The cigarette's texture is an
  atlas shared with a Sketchfab cigarette-pack model (its brand art blanked here). The Zippo is the voxel lighter from
  his ZBlood-VR.
- **id Software**: the marine torso and helmet (the Doom Eternal Classic Slayer, a rip shared on Sketchfab, cut and
  recoloured in the project owner's RS_VRBody; skins halved for the Quest). The Quake torso is Quake's Grunt (1996),
  cut into a torso by Vittorio Romeo's original Quake VR mod, recoloured in RS_VRBody and converted to MD3 here.
- **presidentkoopa** (project owner): the holster spheres (from RS_Holsters); holster, draw and foley sounds (from
  RS_CombatFX).
- **Pixabay** ("freesound_community", Pixabay Content License): the Zippo and cigarette sounds
  ("zippo-lighter-open-light-close", "cigarette-suck"), trimmed and converted to mono OGG.
- Stock Doom sounds for the recenter click and a thrown gun's hit.
- Generated for this pack: the stored-gun fit table and placeholder sprites.
- **QuestZDoom** (Emawind and Team Beef): the engine, and the off-hand weapon and hand-pose API the rig reads.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms; sharing other
people's work in this pack is the project owner's decision.
