# RSQ Tactical Rig

Guns holstered on your body. Reach to a hip, the chest or a shoulder and grip to put a gun away or draw
it. Also: a grenade spot on the belt buckle, a keyring, throwing a gun away, saber spots, a mirror, an
optional torso and helmet, and Ermac's cigarette (optional). Part of the Radiant Silvergun Quest series,
for stock QuestZDoom 17.3 (script only, no engine changes). Built on Ermac's idea, his Virtual Tactical
Vest for Doom VR; this is a new implementation that keeps the rig on your body, not your head.

## Load order

```
doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE
          -> RSQ_TacticalRig.pk3   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** loads and the holsters work (rig-tested on vanilla doom2 with the
  series, 10-27). What needs Brutal Doom: the stored-gun pictures (only guns measured from the Brutal
  Doom load order are shown) and Brutal Doom's empty hand (otherwise your empty hand is the fist). The grenade
  spot shows when Brutal Doom's `HandGrenades` exists, or (11-01) RSQ Grenade's own grenade without Brutal Doom.
- **Other RSQ pk3s needed:** none. RSQ SlowMo is needed only for slow motion after a smoke; RSQ Saber
  only for the saber spots.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Tactical Rig.
- **Buttons to bind:** none needed. The rig reads the controller grips directly, and Use works too (*Use
  Holsters*). Optional: **Recenter Torso** (Options -> Customize Controls -> section *RSQ Tactical Rig*, or the row
  on the rig's own page) turns the torso to where you look.
- If a grip does nothing: the grip key numbers are on *Tuning and Debug* as *Main Grip Keys* (446) and
  *Off Grip Keys* (443 436). 446 is the main grip only with the engine's secondary button mappings off;
  Use always works.
- First time: stand straight, look ahead, and press *Measure My Height* on the front page. Playing
  seated: turn on *Seated*.

## What to do in VR

- **Holster:** reach to a holster with a gun in your hand and squeeze the grip. The hand is left empty.
- **Draw:** reach to a full holster with an empty hand and squeeze the grip.
- **Recenter the torso:** hold both controllers against your chest for about half a second, without pressing
  anything. You hear a soft click and feel a tick in both hands: the torso and every holster now face where your
  head faces. Do this when the torso is not where you want it; the bound key *Recenter Torso* does the same. It also recenters on its own at every map start,
  level change, loaded save and respawn.
- **Turning round in your room:** hold your gun (or both hands) in front of you at chest height and face the new
  way. After about 1.5 s the torso eases round to where you face (*Torso Follows Room Turns*, on). Looking round, or
  reaching to the side or down for a holster, does not turn it.
- **Swap:** grip at a full holster with a gun in hand. The two swap.
- **Grenade:** grip at the belt buckle. The hand grenade comes to your main hand (Brutal Doom's, or RSQ
  Grenade's without Brutal Doom). Grip there again to get your gun back.
- **Throw a gun away:** swing the hand fast and grip, away from any holster (the main hand: swing fast and press Use,
  since its grip is the gun's own; *Main Hand Throws With Use*, on). The gun flies and lands as a
  pickup.
- **Keys to a door (option):** grip at the keyring, hold the grip, touch the keys to a locked door.
- **Move a gun to the other hand (option, needs RSQ Gestures):** turn on *Move Gun at Watch (Use)*. Check
  your watch with the hand holding the gun (RSQ Gestures' watch check, the one that shows RSQ Gun Cards'
  watch card) and press Use: the gun goes to the other hand. A gun already in the other hand comes back (they
  swap). The hand left empty holds its empty hand (Brutal Doom's hands, or nothing / the fist).
- **Move a holster (option):** turn on *Move Holsters by Hand*, grip inside a sphere, carry it, let go. The
  keyring moves the same way.
- **Cigarette (option):** main hand grips at the left chest pocket: the cigarette is in that hand, the Zippo in
  the off hand. **While it is out, Use is the cigarette's** (no doors, switches or holsters on Use). Bring it to
  your mouth: a small glow at its tip, a light tick and a soft click say it is in reach. Press Use: it stays in
  your mouth (a press up to 0.3 s after you left the spot still counts) and your gun is back in that hand. Press
  Use anywhere else: you flick it away. In the mouth it sits a little out in front of your face, tip up, so you
  see it at the bottom of your view, always in the same place (*Mouth Cigarette Forward / Down*). **To light it,
  bring the Zippo's flame to the cigarette's tip** (the glow and a tick in the off hand) **and pull the off-hand
  trigger:** it lights and you smoke (*Smoke Time*, 2 s). The off-hand trigger anywhere else only flicks the Zippo
  open or shut; Use plays no part in lighting. Then it flicks out of your mouth, the Zippo goes away and (with RSQ
  SlowMo) the world slows.

**Cigarette: how it ends** (the owner, 11-03, final; rig only, not headset-confirmed)

1. **Any switch away ends it, and the switch is carried out.** With the cigarette out (in your hand, in your
   mouth, or lit), anything that takes you away from it ends it: a weapon switch of either hand (wheel, keys,
   next / previous, a slot), switchhand, either hand's grip at a holster, another mod switching, death, a level
   change, *Cigarettes* off, the flick, the smoke done. An unlit cigarette goes back in the pocket, a lit one is
   flicked away. Your main hand gets what you switched to, in that one press (a next / previous key works from
   the gun you had before the cigarette; a holster press draws, puts away or swaps as always); with no switch
   (the flick, the smoke done) it keeps or gets back its gun.
2. **The Zippo leaves the off hand in the same tic.** The off hand then gets the off-hand copy of the main
   hand's gun if you own one (Brutal Doom VR's Dual copy, `RSQ_Off_<gun>`), otherwise your empty off hand
   (Brutal Doom VR's hands; nothing on plain Doom 2). A gun the switch itself put in the off hand (switchhand,
   an off-hand holster draw) stays. Every tic, with no cigarette out, anything of the cigarette or the Zippo
   in a hand is taken away. The cigarette is never a gun to the rig (never thrown or holstered), and a press
   at the pocket never throws the gun in your hand.

| You have | What you can do |
|---|---|
| Cigarette in the hand | Use at the mouth (in), Use elsewhere (flick it), main grip at the pocket (back in) |
| Cigarette in the mouth, unlit | Off-hand trigger away from the tip: Zippo open / shut. Main grip at your mouth: back in the hand |
| Zippo's flame at the cigarette's tip | Off-hand trigger: it lights |
| Smoking | Wait (*Smoke Time*), or Use: it flicks out (slow motion either way) |
| Any of these | A switch or holster in either hand, *Cigarettes* off or the rig off (unlit: pocket, lit: flicked), death (gone), next level (unlit: pocket, guns back): the main hand gets what you switched to, the off hand its copy of that gun or the empty hand |

**The stray cigarette (11-03, rig).** "Sometimes the cigarette shows up here and there" had three causes, all
reproduced on the rig before the fix (`tools/rigtest/cigprobe`, script S; `evidence/trc1103_S_before.txt`):
the rig counted the cigarette in your hand as a gun, so a quick swing with the grip (reaching for the pocket fast)
**threw it** and left the hand-held cigarette lying in the world as a pickup for good; **switchhand** moved the
cigarette into the off hand (or the Zippo into the main hand), where it stayed drawn and the off hand lost its
gun; and a grip at a holster **holstered** the cigarette there. Now the cigarette and the Zippo are never guns to
the rig, switchhand ends the ritual at once, and a holster press ends it (rule 1). The old "Zippo put away alone"
also lost the Zippo for good when the off hand held a gun (the off hand's lowering took longer than its 6-tic
check), and its queued raise could be dropped after 2 s, leaving the Zippo in the hand with no cigarette.

Rig 11-03 (rig only, not headset-confirmed): every exit above, for the cigarette in the hand, in the mouth and lit:
the owner's switch keys (B / Y), switchhand 1 and 0, either hand's grip at a hip holster, another mod emptying the
off hand. Each ended it, the count refunded when unlit, the Zippo gone, the hands back to the guns from before
(doom2: chaingun / shotgun in the off hand; full order: BD's hands and the shotgun), and no cigarette, Zippo or
mouth prop left (`evidence/trc1103_*.txt`). The whole ritual completes on doom2, with Gun Bonsai VR (Smoker granted)
and on the full order, SlowMo's world speed 1000 -> 250 permille on the flick.

## Holsters

Six gun holsters: left hip, right hip, left chest, right chest, left shoulder, right shoulder. Two saber
spots just below the hips (with RSQ Saber): the main saber's on the main hand's side, drawn and put away
by the main hand; the second saber's on the off hand's side, by the off hand. The second saber has no key
of its own, so its spot is the only way to put it away and take it out; it stays away until drawn there
(across map changes and saves). The grenade spot is on the belt buckle. A holster holds exactly the gun
you put there. Each hand holsters and draws its own gun. **One gun in, one gun out** (11-02): drawing from a
holster gives that one gun, in the hand that drew it; the other one stays where it was (in its holster, or in
the other hand). Brutal Doom's Dual keeps its own key. Brutal Doom's two-gun weapon (BD22's *DualPistols* and
kin) goes into a holster as its single gun and comes out as one.

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
| Seated | Option | The rig hangs from your seated eyes. This machine only. |
| Measure My Height | - | Scales the rig to your eye height. |
| Move Holsters by Hand | Option | Grip a sphere (a holster or the keyring), carry it, let go: it is saved. |
| Mirror | While Moving Holsters | A copy of you about a metre out: Off / While Moving Holsters / Always. Only you see it. |
| Holster Profiles | - | Save and load four layouts: Standing A (Blue), Standing B (Orange), Seated A (Purple), Seated B (Yellow). The keyring's place is in them; a profile saved before 2026-11-01 puts the keyring at its default. |
| Torso Follows Room Turns | On | You physically turn in your room: when your head has faced more than 45 degrees away from the torso for 1.5 s, with both hands held in front of you the whole time (each at chest or gun-ready height: no lower than 0.40 m under your eyes and no higher than 0.10 m over them, within 0.55 m of your neck along the floor, within 40 degrees of where you look; an off hand on a long gun's fore-end, ahead of the main hand, counts), no hand in a holster and not looking down, the torso eases round to your head in about half a second and lands on it. Reaching to the side for holsters (hands low or at arm's length), looking round for under 1.5 s, or looking aside with your hands left in front of the torso never turns it. Snaps stay exact. (11-03 19:31; rig only, not headset-confirmed.) |
| Recenter: Both Hands to Chest | On | Both controllers held against your chest (each within 0.20 m of a point 0.12 m in front of and 0.30 m under your eyes, measured in the direction you look) for 0.4 s, with no grip, Use or trigger pressed: the torso turns to where your head faces, with a soft click and a tick in both hands. With the torso already facing within 20 degrees of your head, a hand inside any holster also stops it (so it cannot fire while you draw from the chest holsters). After it fires, move a hand away before it can fire again. (11-03; rig only, not headset-confirmed.) |
| Recenter Torso | - | The same as a key: bind it here or in Customize Controls (section *RSQ Tactical Rig*). |
| Torso | Option | A torso the holsters sit on, coloured by armour, breathing red at low health. |
| Torso Style | Doom marine | Doom marine or Quake Grunt. |
| Helmet | On | With the marine torso: a helmet only mirrors show. |
| Cigarettes | Option | Ermac's cigarette pocket (3, refilled each level) and the ritual above. |
| Rig Options: Quick Swap | On | A gun in hand at a full holster swaps at once. |
| Rig Options: Keep Holsters Between Levels | On | What each holster holds carries to the next level. |
| Rig Options: Ammo Light on Holsters | On | A full holster's light: green, yellow (low or reload), red (empty). |
| Rig Options: Ammo Count on Holsters | Option | Small digits above a full holster, in the ammo light's colour: its gun's rounds (the magazine for a gun that has one). |
| Rig Options: New Guns Go to a Holster | Option | A gun you did not have goes into the first empty holster. |
| Rig Options: Grenade Spot | On | The belt-buckle grenade spot: Brutal Doom's hand grenade, or RSQ Grenade's without Brutal Doom. Its light is your grenade count: green 2+, yellow 1, red none. |
| Rig Options: Show Grenade in Holster | On | While you have a grenade and it is not in your hand, a grenade hangs at the grenade spot on the belt buckle, following the torso (11-03; rig only, not headset-confirmed; below). |
| Rig Options: Throw Guns | On | A fast swing plus grip, outside a holster, throws the gun away. |
| Rig Options: Main Hand Throws With Use | On | The main hand also throws on a Use press with that swing (its grip is the gun's own). |
| Rig Options: Thrown Guns Hurt | On | A thrown gun that hits a monster hurts and staggers it, by the gun's weight and the throw speed. |
| Rig Options: Keyring | On | The keys you carry hang on a ring on your belt. |
| Rig Options: Keys Open Doors by Hand | Option | Grip the ring to take the keys; touch them to a locked door to open it (the game's own key check). |
| Rig Options: Show Stored Guns | On | The holstered gun shows at its holster. *Stored Gun Size*: Small / Standard / Large. |
| Rig Options: Haptics | On | Rumble on holster and draw. |
| Rig Options: Messages | Option | Text messages from the rig. |
| Rig Options: Mirror Shows | Both | Front / Back / Both. |
| Rig Options: Torso Fades Looking Down | On | The torso fades as you look down. |
| Rig Options: Holsters Hang From Neck | On | The rig hangs from a neck 10 cm behind and 10 cm under your eyes (estimated from the headset's place and pitch), not from the headset: nodding or looking down no longer slides the holsters forward; moving your whole body still moves them. Standing upright looking level the holsters are exactly where you set them. (11-03, rig only, not headset-confirmed.) |
| Rig Options: Leave Shoulder to ShieldSaw | On | The off shoulder is left to RSQ ShieldSaw's shield while it hangs there. |
| Rig Options: Saber on Hip Too | Option | The saber also clips to the hips. |
| Rig Options: Slow Motion After a Smoke | On | RSQ SlowMo starts as the smoked cigarette flicks out of your mouth (6 s at 25 %, on the *Cigarette* page). |
| Rig Options: Refill Each Level | On | The cigarette pocket refills each level. |
| Tuning and Debug: Holster Positions / Torso Fit / Cigarette | - | Sliders for each holster and the keyring (its *Toward Off Hand* is mirrored for a left-handed layout), the torso and helmet, and the cigarette: *Mouth Zone Size* (1.0, 0.5 to 1.5: how far from the mouth still counts), *Mouth Cigarette Forward* (0.12 m) and *Mouth Cigarette Down* (0.07 m: where the cigarette sits in your mouth, from your eyes; at these its lit tip is at the bottom-centre of your view), *Smoke Time (s)* 1 to 5 in half seconds (2), *Slow Motion Seconds*, *Slow Motion Speed*, *Pack Size*. |
| Rig Options: Torso Turns With Head and Hands | Option | Your head and both hands (held in front of you) turned the same way turn the torso and the holsters with you. OFF since 11-03 18:56: it is a guess, and reaching both hands to the side while looking there turned the torso 90 degrees (the owner's headset). |
| Rig Options: Torso Catches Up With Head | Option | A head held turned further than *Body Turn Angle*, for *Body Turn Delay*, while looking level, eases the torso round to it. OFF since 11-03 18:56 (a guess too). |
| Tuning and Debug: Body Turn Angle / Delay | 35 / 1 s | Used only with *Torso Catches Up With Head* on. Every snap and smooth turn carries the torso by exactly the turn whatever these say (11-03; rig only, not headset-confirmed). |
| Tuning and Debug: Torso: Ignore Looking Down Past | 25 | Looking further down than this (degrees) never turns the torso: it neither counts toward the turn nor continues one (11-03, the owner's headset: "looking down and turning my head seems to turn the torso some"). |
| Tuning and Debug: Throw Swing Speed (m/s) | 2.5 | How fast the hand must swing to throw a gun. |
| Tuning and Debug: Thrown Gun Damage | 1.0 | Multiplier on thrown-gun hits. |
| Tuning and Debug: Reset All | - | Resets every Tactical Rig setting. |

The throw debug log (`rsqtr_debug_throw`) is not on the menu.

**Stick turns + recenter (the owner's choice, 11-03 18:56; rig only, not headset-confirmed).** The owner's headset:
"I am constantly finding myself with the torso 90 degrees turned when it should be facing forward, this makes the
holsters useless". The torso guessed a body turn from the head and hands (head and both hands turning together, and a
head held round for a second), and reaching to the side for a holster while looking there is exactly that. Now the
torso (holsters, torso model, helmet, and RSQ ShieldSaw's shield on it) turns ONLY with the tracking space: with snap
turning (*vr_snapTurn* over 10, the engine's default 45) only a snap turns it, by exactly the snap; with smooth turning
the 11-03 step matcher carries it. A real turn in the room leaves it until you recenter (above). Measured on the rig
(`tools/rigtest/turnprobe`, `gen_rec_script.py`, `rec_check.py`; `evidence/recenter_*.txt`): reaching
both hands 75-95 degrees out to one side while looking 90 degrees there swung the torso 75 degrees before (snap
turning), 0.00 after; 16 snaps right then left exact (45.00 each) at 90 and 35 fps, also with a live head and hands and
while looking down; a smooth 360 0.00 off (with sway within 0.8); a real 360 in the room leaves the torso at 0.00; a real
90 left it 89.98 off until both hands went to the chest (0.07 m from the chest point) for 0.4 s: one recenter, 0.00 off,
and the next snap exact; the key's command recentered a real 90 back to 0.00; seated with the torso facing the head, a
one-handed chest-holster draw, both hands at the chest with a grip held, with Use held, for only 0.3 s, and both hands in
both chest holsters (and in the pose) for 1.1 s: no recenter; a loaded save, a level change and a respawn each left the
torso 0.00 from the head after a real 90. RSQ ShieldSaw's shield on it: the same to the hundredth. Script errors: 0.

**Torso follows room turns (the owner's pick, 11-03 19:31: "the torso follows snap turn, great, but if i physically
stand and turn, it stays in place"; smart catch-up; rig only, not headset-confirmed).** There is no body tracker, so a
turn in the room is read from how it looks: the head held more than 45 degrees off the torso for 1.5 s with BOTH hands
in front of you (in the head's frame) the whole time, no hand in a holster, not looking down. Then the torso eases round
(0.3 of what is left each tic, at most 12 degrees a tic: 16 tics for 90) and lands on the head. Thresholds from the rig
(`gen_room_script.py rmmeasure`, `room_check.py`; from the neck along the floor / off the look / from the eyes): gun at
the ready 0.47 m / 32 deg / -0.30 m; hands at the chest 0.23 / 18 / -0.30; a two-hand long gun 0.34 / 17 / -0.24 and
fore-end 0.65 / 0 / -0.22; the owner's reach (both hands 75-95 degrees round, looking 90 there) main hand 0.58 / 5 /
-0.55, off hand 0.47 / 25 / -0.45; hands at a hip -0.80; a hand in the hip holster -0.85, in the chest holsters -0.61.
Measured (`evidence/roomfollow_after.txt`): a real 90 left, back right, left with a two-hand long gun, and right slowly:
the torso landed 1.66 s after the head stopped (1.06 s for the slow one, whose head was already 45 off before it
stopped), 0.00 from the head, ShieldSaw's shield with it, and the next snap exact; the owner's reach held 3.4 s (20 down,
and level), both hands at the hip, and the reach with smooth turning: no room turn (0.00); a look 60 and 90 aside with
hands in front for 1.3 s (the count reached 40 and 44 of 52) and a look 75 aside for 3 s with the hands left in front of
the torso: 0.00; a draw from the hip holster looking 60 there (level and 20 down) and from a chest holster looking 50
there, 3.4 s each: 0.00; 16 snaps right then left 45.00 each at 90 and 35 fps, with and without live sway; switched off,
the same scripts tic for tic as 3bf3d2f19 (`evidence/roomfollow_off_vs_3bf3d2f19.txt`). Script errors: 0 (rig alone, +
Gun Bonsai + all RSQ, the full BD order: only BD_VoxelPack's 4 voxeldef lines; `evidence/roomfollow_errors.txt`).

**The torso and looking down (11-03; rig only, not headset-confirmed).** Two causes of the torso moving under you: a
look down at a side holster (45-60 degrees of pitch with the head turned) held a second counted as the body turning,
since only past 78 degrees was looking down ignored; and the rig hung from the headset, which swings forward and down
round your neck every time you nod. Measured on the rig (`tools/rigtest/bodyprobe`, `evidence/trb1103_*.txt`): the
head 30 / 50 / 70 degrees down and held 60 degrees round for 2 s swung the body 53 degrees before, 0 after; a level look
held round still turns it (90 -> 146.5 both times); a nod round a neck 10 cm behind and under the eyes moved the
pawn 1.24 / 1.39 / 0.96 map units (3.6 / 4.1 / 2.8 cm) at 30 / 50 / 70 degrees and the holsters with it before, 0.00
after; looking level the holsters are where they were to the hundredth of a unit. The neck is an estimate (10 cm and
10 cm), and the engine gives ZScript no headset roll, so a sideways head tilt is not taken out. Height is as before
(the pawn's eye height, or the seated eyes), since neither follows a nod.

**The grenade in its holster (owner 11-03 17:10: "When I have a grenade in my inventory I should see it in the
designated grenade holster"; rig only, not headset-confirmed).** Why nothing showed: the spot drew no picture at all.
A holster only ever shows the gun you put there (and only guns in the fit table; BD's grenade sprite was taken off the
body on 10-27), the grenade spot never holds one, and what it did draw, its ring and count light, shows only with a
hand within 2.5 ring radii (*Holster Rings: Hand Nearby*). The count was read from the right item all along (BD22's
`GrenadeAmmo` on the Brutal Doom order, RSQ Grenade's `RSQGN_Ammo` without it; logged on both). Now, with one or more
grenades and none in either hand (drawn, being drawn, or Brutal Doom's Purist grenade), a 13 cm grenade (x *Stored Gun
Size*) hangs in the spot, ring and spoon toward you, its top leaning 35 degrees out so you see its side looking down.
The mesh is found by name: BD22 VR Reloaded's (`models/bd/Grenade/nade.md3`; the BD voxel pack has no grenade voxel),
else RSQ Grenade's (the same file), else the grenade ammo's pickup sprite (BD22 without BD22 VR: shown, but a sprite
seen from straight above is thin). No count digits: tried, and from straight above they were edge-on, smeared or an
unreadable blob on the rig, so the count stays the spot's light. Frames: `docs/grenade_holster_doom2_rig.png`,
`docs/grenade_holster_fullorder_rig.png` (0, 1, 3 grenades, in hand, back, switch off, rings at 3 and 0); probe and logs
`tools/rigtest/nadeprobe` (`evidence/trnD_before_1103.txt`: nothing at the spot with 1 and 3 grenades before).

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
   With a grenade in your inventory, look down at the buckle, hands away: a grenade hangs there. Take it out: the spot
   is empty; put it back: it is there again. Throw your last one: nothing hangs there. **(11-03, rig only, not
   headset-confirmed)**
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
14. **The cigarette ritual** (2026-11-02; rig only, not headset-confirmed). Turn on *Cigarettes*.
    a. Main hand grips at the left chest pocket: the cigarette is in that hand, the Zippo in the off hand.
    b. Stand at a door, hand out in front, press Use: the cigarette flicks away; the door does **not** open.
    c. Take another. Bring your hand to your lips the way you really would (the controller ends up near your
       chin): a glow at the tip, a tick, a click. Press Use: it stays in your mouth and your gun is back.
       Try it lower (the controller a hand below the chin) and quickly (a tap): both should work. At your chest
       there is no cue, and Use flicks it.
    d. Look ahead: the cigarette is at the bottom-centre of your view, tip up; look around, nod: it stays put in
       the view. Off-hand trigger away from it: the Zippo opens. Again: it shuts. Main grip at your mouth: the
       cigarette is back in your hand; put it in your mouth again.
    e. In each state (in the hand, in the mouth, lit): press either hand's weapon switch, or grip a holster with
       either hand. It ends: unlit back in the pocket (the count goes back up), lit flicked away; the Zippo is
       gone at once; the main hand has the gun you switched to, the off hand its Dual copy (a pistol, shotgun,
       rifle you hold two of) or your empty hand. Nothing of the cigarette is left anywhere.
    f. Bring the Zippo's flame to the cigarette's tip (glow and tick), pull the off-hand trigger: it lights and
       you smoke.
       After *Smoke Time* it flicks out of your mouth and with RSQ SlowMo the world slows.
    g. Cancels: turn *Cigarettes* off, die, go to the next level. Each time the Zippo is gone too.
    Rig 11-03: d-g and the stray cigarette (scripts X1-X3, R, S; `gen_scripts_1103.py`; above). Rig 11-03, the
    final rules: every exit with the switch carried out, lighting by the off-hand trigger, the mouth cigarette
    placed ten ways (scripts E1-E3, R2, L, M, FV; `gen_scripts_1103b.py`; frames `docs/cig_mouth_view_*.png`).
    Rig 11-02 (`tools/rigtest/cigprobe`, scripts F (doom2), G (cue), H (full order with BD22 VR Reloaded 2.0.3l
    and all RSQ pk3s), V/Z (drawn points); frames `docs/cig_zone_rig.png`): all of a-g with realistic poses,
    world speed 1000 -> 250 permille on the flick. Haptics and sounds could not be felt or heard on the rig.
15. **One gun out of a holster** (2026-11-02; not yet headset-confirmed). With two pistols (Brutal Doom VR's
    off-hand copy, or BD22's dual pistols in hand): holster one at the hip, draw it. You get one pistol in that
    hand; the off hand keeps what it had. Rig 11-02, full load order (`trc_scriptQ.txt`, `docs/holster_one_gun_rig.png`):
    with the old *Draw Pairs* set to Always, one BrutalPistol; BD22's DualPistols went in as one BrutalPistol and
    came out as one. (The *Draw Pairs* row is retired: Dual is its own key, the owner's rule of 10-27.)
16. Turn on *Move Holsters by Hand*: grip a sphere, move it, let go. Turn it off to play.
17. With RSQ Saber (Start With Dual Sabers On): off hand to the second saber's spot below the off-side hip,
    grip: the second saber goes in and the off hand holds the Force (Brutal Doom Quest's fist, or the bare
    Force hand). Grip again: it comes back to the off hand. The main hand there does nothing.
    **(not yet headset-confirmed; rig: the saber's in / out events logged, 11-01)**
18. With RSQ Accessibility, Seated Play Seated (or Auto once it has seen you sit), this mod's own *Seated* Off:
    sit down. The holsters hang from your seated eyes, in reach, as with *Seated* On. Seated Play Standing:
    as before. **(not yet headset-confirmed; rig: headset at 1.2 m, the rig hung from 90 instead of 97, the
    left hip at 70.2 instead of 77.2)**
19. With RSQ Accessibility: Rumble Strength 0, reach into a holster: no rumble. 2: stronger.
    **(not yet headset-confirmed)**
20. With RSQ Gestures: turn on *Move Gun at Watch (Use)*. Gun in the main hand, off hand empty: check your
    watch with the main hand and press Use. The gun goes to the off hand; the main hand is empty. Check your
    watch with the off hand and press Use: it comes back. Gun in both hands: the two swap. Turn the row off:
    Use at the watch check does nothing. Off hand in a hip holster while you press Use: the holster acts,
    no gun moves. **(not yet headset-confirmed; rig 11-01: plain Doom 2 pistol / shotgun across, back and
    swapped both ways; Brutal Doom order Rifle and Shot_Gun across and back, Brutal Doom's hands in the
    empty off hand; nothing with the row off or a hand in a holster)**
21. Turn on *Holster Rings* Always: a sphere shows at the keyring. Turn on *Move Holsters by Hand*, grip the
    keyring's sphere, carry it, let go: the keys hang there now. Save a holster profile, move the keyring
    again, load the profile: it is back. **(not yet headset-confirmed; rig 11-01: moved by hand to 0.30
    forward, 0.60 under the eyes; saved, moved, loaded back; an older profile put it at its default)**
22. **Stick turns + recenter** (11-03 18:56; rig only, not headset-confirmed). Turn on *Torso* and look down.
    a. Reach both hands out to one side while looking there, hold, come back: the torso does not turn.
    b. Snap turn round in a full circle and back: the torso turns with every snap and ends facing forward.
    c. Physically turn round 90 degrees in your room: the torso stays where it was. Hold both controllers to
       your chest for half a second: click, tick in both hands, the torso faces where you look.
    d. Draw from a chest holster with one hand: no click. Hands to your chest with a grip held: no click.
    e. Bind *Recenter Torso*, turn round in the room, press it: the torso faces where you look.
    f. Turn round in the room, then load a save / go to the next level / die and respawn: the torso faces you.
23. **Torso Follows Room Turns** (11-03 19:31; rig only, not headset-confirmed). Turn on *Torso*.
    a. Hold a gun at your chest and physically turn 90 degrees in your room: within about 2 s the torso eases round
       and faces where you look. Same with a long gun held in both hands.
    b. Reach both hands out to one side while looking there and hold 3 s: the torso does not turn.
    c. Look 60-90 degrees aside with the gun in front for about a second, look back: no turn.
    d. Look at your hip and draw from the hip holster: no turn.
    e. Snap turn a full circle and back: exact, as before. Switch it off: a room turn leaves the torso until you
       recenter, as before.

## Works with

- **RSQ Gestures:** its watch check is what *Move Gun at Watch (Use)* waits for (asked by name). Without
  it there is no watch check and the row does nothing.
- **RSQ SlowMo:** the smoked cigarette flicking out of your mouth starts slow motion (*Slow Motion After a
  Smoke*), through RSQ SlowMo's `rsm_pulse <ms> <depth %>` network event (by name; nothing links). Without
  RSQ SlowMo the event goes nowhere.
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
- **Gun Bonsai VR patch:** the Gunslinger tree (GBOVR_TREES.md 4.8). Quick Draw -> Pair Draw, Showdown (Quick Draw 2);
  **Smoker** (1-3): the flick's slow motion runs 2 s longer a level (6 -> 8, 10, 12) and nothing can hurt you while it
  does; **Chain Smoker** (after Smoker) adds 1 / 2 / 3 to the pack. Ammo Count, Keys to Doors and Cigarettes stay
  menu rows (owner, 11-03: never unlocks; the cigarette is yours from the start). **Gun Toss** makes a
  thrown gun hit x1.5 / 2.0 / 2.5 and stagger longer; **Boomerang Gun** (after Gun Toss 2): a thrown gun that hits flies
  back to the holster it came from (2: into your hand). Without the patch nothing changes.

## Known limits / open issues

- **Smooth turning and the torso (11-03 18:56).** With snap turning only a snap turns the torso. With smooth
  turning (*vr_snapTurn* 10 or less) the engine adds the stick's turn to the headset's yaw before ZScript sees
  either, so a smooth turn and the head and both hands turning together look the same: on the rig, reaching both
  hands 75-95 degrees out to the side while looking 90 degrees there turned the torso 75 degrees (as far as the hand
  that turned least) and held it there while the reach was held; it came back as the hands came back. Snap turning
  has no such case (0.00). Play with snap turning, or recenter after such a reach.
- **Torso Follows Room Turns cannot tell a turn from a held look (11-03 19:31).** Standing still and looking 45+
  degrees to one side for 1.5 s with both hands held in front of you at chest height (as if aiming there) looks
  exactly like turning your body there, so the torso turns. Hands low or out to the side (reaching for holsters),
  a hand in a holster, or looking down never turns it. With smooth turning the step matcher already carries a rigid
  head-and-hands turn before the 1.5 s are up.

- **Holstered guns may look squashed** (a model flag was tried and backed out because it could not be
  checked on the rig). Check in the mirror.
- **Zippo and cigarette sounds (2026-11-01):** real recordings from Pixabay, picked by the owner (open, light,
  close; the drag and the breath after it; the tip catching uses the Zippo's light). The flick uses the rig's own
  foley. Not yet heard in the headset.
- **The cigarette's Use takeover** holds off the engine's use (doors, switches), the rig's Use holsters and the
  watch move. Hand-on-door systems in other mods (RSQ Distance Grab's and Brutal Doom VR's doors by hand) read
  the Use key themselves when a hand touches a door; they are not stood down.
- **The mouth zone** (11-02, rig only, not headset-confirmed). Why it failed before: it was a 0.15 m ball around
  a point 7 cm in front of the eyes and 9 cm under them, tested on the controller only. With a real hand at the
  lips the controller sits a palm's width lower; a hand-below-the-chin pose (controller 0.23 m under the eyes)
  measured 0.154 m out, so Use flicked the cigarette away. Very quick taps could also be lost (the engine only
  sees Use if it is held when a tic is built). Now: a capsule from the lips (4 cm forward, 6 under the eyes) to
  just under the chin (8 forward, 19 under), 0.08 m round it (x *Mouth Zone Size*), turning and nodding with
  the headset; the nearer of the controller and the drawn filter counts; a Use key going down is caught as an
  input event as well. Measured (distance / 0.080): controller at the lips 0.018, at the chin 0.023, a hand
  lower 0.038 (all in); 28 cm under the eyes 0.080 (edge); chest 0.132, pocket 0.267, rest 0.331 (out).
- **The drawn cigarette and flame are measured** (`tools/measure_handprops.py`: the baked meshes through the
  engine's own hand-model transform; rig frames show the computed points on the drawn ones). The filter is
  0.5 cm forward, 2.8 left, 1.3 up of the main controller; the flame 1 cm behind and 3.5 cm over the off
  controller (the old estimate was 6 cm over). The flame lights within 0.10 m of the cigarette's burning half.
- **The cigarette in the mouth** (11-03, rig only, not headset-confirmed). It was always in the same place in
  the head's frame (measured ten ways on the rig, also from the rendered camera), but 7 cm forward and 9 cm
  under the eyes is 52 degrees under the view's centre, past a headset's lower edge, so only a sliver showed and
  where depended on the smallest nod; a look steeper than 60 degrees also left it behind. Now 12 cm forward,
  7 cm under, tilted 5 degrees up: its tip 21 degrees under the centre, the same in all ten placements. It sticks
  out further than a real one. The engine gives scripts no headset roll (a sideways tilt shifts it a centimetre
  or two), and it follows your head a tic behind while you turn.
- **Main grip at the mouth / the pocket** needs the main grip to reach the rig (*Main Grip Keys*, 446 only with
  the engine's secondary button mappings off). Use always works for the mouth.
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
`RSQTR_BodyService` (found by name): `GetDouble("body.yaw", "", 0, 0, pawn)` is the body's heading in degrees (the
console player's pawn only, brought up to date this tic first), or 999. RSQ ShieldSaw hangs its shield on it.
`GetDouble("body.recenter", "", 0, 0, pawn)` recenters it (to the head's facing, with the click and the tick) and
answers the new heading (11-03; RSQ ShieldSaw's own Recenter Torso key uses it).
