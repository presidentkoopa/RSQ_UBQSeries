# RSQ Tactical Rig

Your guns live on your body: reach for your hip, chest or shoulder, grip, and the gun is in your hand.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): the whip and flare holsters, the ammo pouch, the items always shown on the body and in the mirror, the torso following room turns.

New on 11-05 (code only, not rig-tested, not headset-confirmed): the cigarette's slow motion at full speed, its 5-30 s
slider, cigarettes earned by RSQ Score points, minibosses refilling the pocket.

New on 11-06 (rig only, not headset-confirmed): the keyring appears with your first key; Keys Open Doors by off-hand
trigger or a raise; Holster Lock with RSQ Wheel (replaced 11-07 by holster assignment, below).

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. Built on
Ermac's idea, his Virtual Tactical Vest for Doom VR, with new code that reads your real controller poses.

New on 11-07 (rig only, not headset-confirmed): holsters are **assigned**. A gun put by hand into an unassigned holster,
or picked for one in RSQ Wheel's holster web, owns it, in the holster or in your hand, until the Wheel unassigns or
reassigns it; no other gun goes in. Holding an assigned gun at another gun's full holster sends yours home and brings
that one to your hand. Holster Lock and New Guns to Holsters are gone (assignment replaces them). Shown on the rig.

Also 11-07 (rig only, not headset-confirmed): RSQ Wheel's Web View: Mirror draws this mod's own mirror, small, on the
Wheel's holster web (shown on the rig). With RSQ ShieldSaw's Take It From set to Over the Shoulder, the off-shoulder gun
holster is the ShieldSaw's, whether the shield is there or in your hand: a gun put there by hand gets a dull tick and
stays in your hand (shown on the rig: the main hand), the web cannot assign it, and a gun that had it loses it (not shown).

Also 11-07 (rig only, not headset-confirmed): Brutal Doom 22 VR's dual wield with an assigned gun. Holding the same gun in
both hands, put the off hand's copy in a holster and the gun goes home to its own holster, from both hands. At its own
holster (or an empty unassigned one) both hands go empty; at another gun's holster with that gun in it, the off hand goes
empty and your main hand takes that gun. Shown on the rig with dual Rifles on the full Brutal Doom order (its own holster
and another gun's; an empty unassigned holster not shown).
A gun with no holster yet, held in both hands: put the off hand's copy in a free holster with no gun assigned and that
holster becomes the gun's, the gun goes in, and both hands go empty (shown on the rig, dual Rifles, full order).

## Standout feature: a holster rig you work with your hands

Six gun holsters hang on your body: both hips, both sides of the chest and both shoulders. Put your hand in one and
your controller ticks. Grip with a gun in that hand and it goes in. Grip again with the hand empty and you draw it
back out. Each holster holds exactly the gun you put there, and nothing else ever moves it. Hold a gun at a full
holster and the two swap in one motion. Each hand works its own holsters, so you can draw a pistol with your off
hand while the rifle stays in your main hand.

With Brutal Doom's weapons, and with vanilla Doom's Pistol, Shotgun, Super Shotgun, Chaingun, Rocket Launcher, Plasma Rifle,
BFG9000 and Chainsaw (drawn in Brutal Doom's matching held models, carried in this pk3), the stored gun hangs where you put it, drawn with the 3D model you hold in your hand:
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
- Assigned holsters: a gun put by hand into an unassigned holster, or picked for one in RSQ Wheel's holster web, owns
  it until the Wheel unassigns or reassigns it; no other gun goes in. Holding an assigned gun at another gun's full
  holster sends yours home and brings that one to your hand. Brutal Doom 22 VR's dual wield follows the same rules
  (above). (Rig only, not headset-confirmed.)
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
- Keyring beside it: every key you carry hangs from a ring on your belt, swaying as you move. It appears with your
  first key; with no keys there is nothing on the belt.
- Optional, Keys Open Doors (off by default): grab the keys off the ring. With the OFF hand: hold them at a locked
  door and pull the off-hand trigger to unlock and open it, or hold off-hand alt-fire and raise your hand to lift the
  door (RSQ Distance Grab's door lift, the door following your hand; without Distance Grab the raise opens it). The
  main hand opens a locked door by touching the keys to it. (Rig only, not headset-confirmed.)
- Two saber spots below the hips for RSQ Saber's hilts, each on its own hand's side.
- A whip holster on your main-hand hip for RSQ Whip, the whip hanging coiled there whenever it is out of your hand.
  It never ends up in a gun holster.
- A flare holster on your off-hand hip for RSQ FnF, sharing its chest pocket's flares, with a flare hanging there
  while you carry one.
- An ammo pouch just left of the buckle for Brutal Doom 22 VR's hand reloads: reach into it for the magazine, shell
  or round (a 10 cm reach since 11-05). Its light shows the reserve of the gun in your hand (green, yellow, red).
  Ammo Pouch off: BD22 VR takes ammo from anywhere again.
- Holster rings: gun holsters (hips, chest, shoulders) are blue (or their profile's colour); every other spot (grenade,
  keyring, sabers, whip, flare, pouch, FnF's pocket and clip, the cigarette pocket) is magenta; green with a hand inside.
  A ring with its item in it is drawn faint, so the item shows solid.
- The cigarettes left in your pocket stand in it on your chest, and the mirror shows your grenade, cigarettes and
  RSQ ShieldSaw's shield along with your holsters.

**Throw your gun** (off by default: switch on Throw Guns)
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
  flick it away, and the world drops into slow motion (with RSQ SlowMo loaded) while you move at full speed.
- With RSQ Score, every N points can earn a cigarette; with RSQ Miniboss, killing a miniboss refills the pocket.

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
8. Playing BD22 VR Reloaded? When a reload asks for a magazine, reach your off hand into the ammo pouch just left of
   your belt buckle; its light tells you how much reserve the gun in your hand has left.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Holster a gun | Hand with a gun inside a holster ring, then grip (or Use) | A full holster swaps: its gun comes out to that hand |
| Draw a gun | Empty hand inside a full holster, then grip (or Use) | Each hand draws into itself |
| Throw a gun | Throw Guns on: swing the hand fast (2.5 m/s) outside every holster, then grip, or Use with the main hand (Throw With Use) | Lands as a pickup you can take again |
| Grenade | Either hand at the belt buckle, grip | Again with the grenade in hand: your gun comes back |
| Saber | Main hand at the main-side saber spot, off hand at the other | Needs RSQ Saber; a saber put on any empty holster goes to its own spot |
| Whip | The whip's hand at the whip holster (main-hand hip), grip or Use | Needs RSQ Whip; draws or puts away. A whip put on an empty gun holster goes home |
| Flare | Off hand at the flare holster (off-hand hip), grip | Needs RSQ FnF; an unlit flare comes up or goes back. A lit one cannot go in: while it is lit, the off hand's grip at any Rig spot does nothing |
| Ammo pouch | Off hand in the pouch left of the buckle, press as BD22 VR's reload asks | With BD22 VR's pouch-only setting on, reloads take ammo only from here |
| Recenter torso | Both controllers against your chest (within 0.20 m of a point 0.30 m under your eyes) for 0.4 s | No grip, Use or fire held; let go before doing it again |
| Recenter Torso key | Bindable: Customize Controls → RSQ Tactical Rig, or the rig's own page | |
| Move a holster | Move Holsters by Hand on: grip inside a ring, carry it, let go | The keyring moves the same way |
| Keys to a door | Keys Open Doors on: grip at the keyring, hold. Off hand: at a locked door pull the trigger (unlock and open), or hold alt-fire and raise the hand (lift it). Main hand: touch the door | The engine's own lock check decides. While the off hand holds the keys its trigger and alt-fire are the keys' |
| Move a gun to the other hand | Move Gun at Watch on: hold the watch check, press Use | A gun in the other hand swaps. While an RSQ Miniboss Bossfight is ready to call, that press calls it in instead and the gun stays |
| Cigarette | Main hand at the chest pocket (left chest for right-handers), grip or Use | Cigarette in the main hand, Zippo in the off hand |
| ...into the mouth | Cigarette at your lips, Use | Use anywhere else flicks it away |
| ...light it | Zippo's flame at the tip, off-hand fire | Off-hand fire elsewhere flicks the lid open or shut |
| ...finish | Use while smoking flicks it early | Any holster grip or weapon switch also ends it |

- Use acts for whichever hand is in a holster, the main hand first. The main hand's grip reaches the rig only when
  the engine sends it as a key (its secondary button mappings off); Use always works. The grip keys can be changed
  under Test and Debug.
- A hand must rest in a holster for 3 tics before a press counts, so a hand passing through does nothing.
- On PC (SteamVR), an off-hand draw made while the engine is steadying a two-handed gun arrives when you let go of
  the grip.
- Left-handed: the engine's left-handed setting swaps main and off hand, the saber spots and the shield's shoulder.
  The cigarette pocket and the way guns hang mirror too (following RSQ Accessibility's handedness when it is loaded).

## Menu

Options → Radiant Silvergun Options → RSQ Tactical Rig. One page; the raw numbers are on its **Test and Debug** page.
Tactical Rig has no Gun Bonsai VR line: none of its rows is unlocked by an upgrade (the Gunslinger nodes only add to
what the rows already do: Smoker, Chain Smoker, Gun Toss, Boomerang Gun).

| Row | Default | What it does |
|---|---|---|
| **Holsters** | | |
| Tactical Rig | On | The whole rig |
| Grip Holsters | On | Grips holster and draw |
| Use Holsters | On | Use holsters and draws too |
| Holster Rings | Hand Nearby | Never, Hand Nearby, Always. Gun holsters blue (profile colour), other spots magenta |
| Holster Reach | 1.00 | Holster size (0.5 to 2) |
| Quick Swap | On | A full holster swaps without the press delay |
| Keep Between Levels | On | Holsters keep their guns |
| Move Gun at Watch | Off | Use during the watch check moves that hand's gun across (not while a Bossfight is ready to call: the press is its call-in) |
| Hang From Neck | On | A nod does not slide the rig |
| **Spots** | | |
| Grenade Spot | On | The belt-buckle grenade |
| Show Grenade | On | A grenade hangs there while you have one |
| Saber on Hip Too | Off | The main saber also clips to the hips |
| Whip Holster | On | RSQ Whip's whip has its own holster on the main-hand hip |
| Flare Holster | On | RSQ FnF's flares have their own holster on the off-hand hip |
| Ammo Pouch | On | A pouch left of the belt buckle (off-hand side): with Brutal Doom 22 VR, hand reloads take magazines, shells and rounds from it only. Off: they take ammo from anywhere |
| Show Ammo Pouch | On | The pouch on the belt, its light the reserve of the gun in your hand (green, yellow, red) |
| Shoulder to ShieldSaw | On | Off shoulder is the shield's while it is stowed there. With RSQ ShieldSaw's Take It From set to Over the Shoulder, the off-shoulder gun holster is the ShieldSaw's either way (11-07, rig only, not headset-confirmed) |
| Keyring | On | Keys on your belt |
| Keys Open Doors | Off | Take the keys to locked doors: off-hand trigger opens, off-hand alt-fire held and a raise lifts; the main hand opens by touch |
| **Stored Guns** | | |
| Show Stored Guns | On | Holstered guns drawn on the body |
| Stored Gun Size | 1.00 | Their size (0.25 to 3) |
| Ammo Light | On | The green / yellow / red light on a full holster |
| Ammo Count | Off | Round count above each full holster |
| **Gun Throwing** | | |
| Throw Guns | Off | Swing-and-press throws |
| Throw With Use | Off | The main hand throws on Use too (greyed while Throw Guns is off) |
| Thrown Guns Hurt | On | Thrown guns damage and stagger (greyed while Throw Guns is off) |
| **Body** | | |
| Seated | Off | Hang the rig from your seated eyes (this machine only) |
| Measure My Height | | Reads your headset height and scales the rig |
| Torso | Off | Show a torso |
| Torso Style | Doom Marine | Doom Marine or Quake Grunt |
| Helmet | On | The marine's helmet, seen in mirrors |
| Torso Fades Looking Down | On | The torso thins as you look down |
| Torso Follows Room Turns | On | The torso follows a real turn in the room: your head held 45+ degrees round for 1.5 s, hands anywhere except in a holster or reaching far out to the side; looking down never turns it |
| Head and Hands Turn | Off | Older turn rule: head and both hands turning together |
| Torso Catches Up | Off | Older turn rule: a head held round eases the torso after it |
| Recenter by Hands | On | The recenter gesture: both hands to the chest |
| Recenter Torso | | Bind the recenter key |
| **Cigarettes** | | |
| Cigarettes | Off | Ermac's cigarette pocket |
| Smoke Slows Time | On | RSQ SlowMo when the cigarette is flicked (with SlowMo's Adrenaline off, its countdown bar shows how long is left) |
| Smoke Slow-Mo Time (s) | 6 | How long that slow motion lasts (5-30 s) |
| Move at Full Speed While Smoking | On | You are not slowed in the smoke's slow motion (needs this RSQ SlowMo or newer) |
| Cigarette Every N Score (0 Off) | 0 | With RSQ Score, every this many points earns one cigarette, up to the Pack Size |
| Minibosses Refill Cigarettes | On | With RSQ Miniboss, killing a miniboss fills the pocket to the Pack Size |
| Refill Each Level | On | The pocket refills |
| Unlit Cigarette Goes Away | On | A cigarette left unlit in your mouth for 7 s drops out, used up (Test and Debug: Unlit Goes Away After) |
| Show Cigarettes | On | The cigarettes left in the pocket stand in it on your chest |
| **Setup** | | |
| Move Holsters by Hand | Off | Grab and place holsters |
| Mirror | While Moving | Off, While Moving, Always |
| Mirror Shows | Both | Front, Back or Both |
| Haptics | On | Controller ticks |
| Messages | Off | Short text notes |
| **Holster Profiles** | | Save and Load for Standing A (blue), Standing B (orange), Seated A (purple), Seated B (yellow) |
| Test and Debug | | The page below |
| Reset All | | Every row on this page and on Test and Debug |

The whip, flare and saber shown at their Rig spots follow those mods' own Show rows (RSQ Whip "Show Whip", RSQ FnF
"Show Flare", RSQ Saber "Show Sabers"); the Rig has no Show row of its own for them.

**Test and Debug**: Stored Guns: Gun Length (0.25 m), Back Gun Length (0.70 m), Gun Turn (0), Flip These Guns (blank).
Body: Body Turn Angle (35) and Body Turn Delay (1.0 s) for Torso Catches Up, Ignore Looking Down (25 degrees), Mirror
Distance (1.0 m). Hands: Press Delay (3 tics), Throw Speed (2.5 m/s) and Thrown Gun Damage (1.0) (both greyed while
Throw Guns is off), Main Grip Keys (446),
Off Grip Keys (443 436), Empty Hand Weapon (blank: the fist). Torso Fit: Torso Height (-0.20 m), Torso Forward
(-0.04 m), Torso Size (1.0), Helmet Height (0), Low Health Glow (under 35). Cigarette: Mouth Zone Size (1.0), In Mouth
Forward (0.12 m), In Mouth Down (0.07 m), Smoke Time (2 s), Unlit Goes Away After (7 s), Slow Motion (6 s), Slow Motion Speed (25%), Pack Size (3).
Holster Positions: forward, left, up and size in metres from your eyes for every holster, the grenade spot, the
keyring, both saber spots, the whip and flare holsters and the ammo pouch (hips 0.70 m down, 0.18 m out; chest 0.46
down, 0.12 out, 0.10 forward; shoulders 0.10 down, 0.18 out, 0.08 back; whip and flare 0.84 down, 0.30 out, 0.06
back, whip 0.08 size; pouch 0.62 down, 0.14 toward the off hand, 0.20 forward, 0.10 size; cigarette pocket 0.08). Debug:
Throw Debug Log (Off).

## Works with

Runs alone on any load order. It finds the rest by name:
- **Brutal Doom / BD22 VR Reloaded**: stored guns are drawn with the measured 3D models of Brutal Doom's weapon set
  (a gun missing from that table is not drawn on the body; vanilla Doom's eight guns use the same models, shipped here); the grenade spot hands out Brutal Doom's VR grenade; an
  empty off hand gets BD22 VR's hands; off-hand draws use its off-hand gun copies.
- **RSQ Grenade**: without Brutal Doom's grenade, the spot hands out RSQ Grenade's, and glows in the colour of the
  kind in your hand.
- **RSQ SlowMo** (new on 11-06, rig only, not headset-confirmed): getting up from DOWN (REVIVE) puts one cigarette
  back in the pocket, up to the Pack Size, while Cigarettes is on. Since DOWN v3 (11-07, rig only, not
  headset-confirmed): only when you get up on the reward bar's top step.
- **RSQ Saber**: the two saber spots appear, and holster and draw both hilts.
- **RSQ ShieldSaw**: its shield hangs on this torso and turns with it; its Recenter key recenters both. The off
  shoulder is left to the stowed shield.
- **RSQ Whip**: its whip holster and the coiled whip shown there. **RSQ FnF**: its flare holster, sharing the
  pocket's flares, and its pocket hangs on this torso. FnF's chest pocket and flashlight clip show the same fading
  holster sphere as the Rig's own places (Holster Markers), at FnF's own size.
- **RSQ Accessibility (its gesture reader)**: the watch-check gun move.
- **RSQ SlowMo**: the slow motion after a smoke.
- **RSQ Miniboss**: while its Bossfight is ready to call, the watch check + Use calls it in and Move Gun at Watch skips
  that press (asked by name, RSQMB_Service "callin").
- **RSQ Accessibility**: Seated Play, handedness, rumble strength, text size and colour-blind ring colours apply here.
- **RSQ Distance Grab** lifts a locked door held by the off hand's keys (its own door events, by name);
- **RSQ Distance Grab** leaves a hand alone while it is in a holster or holds the cigarette or Zippo; **RSQ Melee**'s
  Headlock waits while your off hand is in a holster.
- **RSQ Wheel** marks where a gun is holstered, and its holster web assigns a gun to a holster or clears it (Web View Mirror draws this mod's mirror there); **RSQ Score** reads holster draws for its quick-draw bonus; and the hand reloads of **BD22 VR
  Reloaded** take ammo from the pouch when its pouch-only setting is on.
- **Gun Bonsai + RSQ Gun Bonsai VR**: Gun Toss makes thrown guns hit harder and stagger longer; Boomerang Gun flies a
  thrown gun back to its holster, or to your hand at level 2 (both offered only while Throw Guns is on); Smoker lengthens the smoke's slow motion and makes you
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
