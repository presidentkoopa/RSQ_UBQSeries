# RSQ Distance Grab
### Doom Arcade VR · turn your palm out, pull the barrel across the room, and throw it back at them

Turn a hand palm-out toward anything lying in the room and it lights up. Flick your wrist and it flies to your hand in
an arc, turning over as it comes. Catch it, carry it, club a monster with it, or throw it with your own arm: a barrel
thrown hard goes off where it lands.

*[GIF to come: a barrel pulled across the room, caught, and thrown into a crowd, where it goes off]*

---

## What it feels like

- **No buttons.** Your hand is the trigger. Turn your palm out and a beam and a faint cone come out of it; turn it back
  and they are gone. Even your gun hand can reach: turn the gun on its side.
- **Things tell you they are yours.** What your hand is on glows amber. Hold it there and it locks: green, breathing
  faster. A low hum in the controller says you have it.
- **Flick it to you.** Tip your wrist up as you turn your palm back, and the thing leaves the floor and flies to your
  hand in an arc, end over end, leaving a faint green trail. The controller rumbles harder as it closes in.
- **Catch it.** Have your palm out when it gets there. A pickup is used on the spot (a gun goes into the hand that
  caught it, a medikit heals you); a barrel is in your hand.
- **Carry it.** It sits a little in front of your hand and tips with your wrist. Heavy things hang lower, swing slower
  and trail behind your hand. Put your other hand on it and it is lighter.
- **Throw it.** Swing and let go. How hard you swung is how hard it flies, and weight matters: a keycard leaves at
  your hand's speed, a barrel at a third of it. A throw near a monster bends onto it.
- **Barrels are bombs.** A barrel thrown hard goes off where it lands, and the kill is yours.
- **Hit them with it.** Swing a carried barrel into an imp and it takes the blow.
- **Hide behind it.** A barrel or a body held up in front of you stops the fireballs that would cross it.
- **Doors and switches by hand.** Put your palm flat on a door and lift. Lay it on a switch and it flips.

---

## How to play

| Do this | What happens |
|---|---|
| Turn a hand palm-out (a quarter turn of the wrist, hand raised, not hanging at your side) | A beam and a cone from that hand. The thing it is on glows amber |
| Keep it there | It locks: green. You can look away now; the lock stays |
| Tip your wrist up sharply as you turn your palm back | It flies to that hand |
| Turn your palm back without the flick | You let go of the lock |
| Have your palm out when it arrives | Caught: a pickup is used, anything else is in your hand |
| Your hand turned away when it arrives | It drops at your feet |
| Carrying it: swing and turn your palm back mid-swing | Thrown, along your swing |
| Carrying it: turn your palm back with your hand still | Set down |
| Squeeze the grip while carrying | The grip holds it now: let go of the grip to throw it or set it down |
| Squeeze the grip with your palm on a pickup, a barrel or a flare (within 30 cm) | Taken straight into that hand, no pull |
| Your other, empty palm on the thing you carry | Both hands on it: it handles as if half as heavy |
| Palm out against a door (or the grip, or Use), then raise your hand | The door lifts with your hand |
| Palm out on a switch | It flips |

On a desktop there are two keys, **G** (main hand) and **H** (off hand), read only when **Grab Keys** is on.

---

## Pulling things to your hand

**Reach** is about 15 metres, and the **Aim Width** is 12 degrees either side of where your hand points. They are two
separate settings: how far you can pull from and how precisely you have to point. Through a wall is not pointing at it
(**Line of Sight**).

When you point between two things, the one you are pointing straight at wins, then the nearer one. Some things also
count as nearer than they are, so the dull thing beside the good thing does not steal it:

| Kind | How hard it competes for your hand |
|---|---|
| Barrels | Most |
| Weapons, keys, RSQ FnF flares | More |
| Powerups, and anything else a mod leaves lying in the world | Plain |
| Ammo, health, armour | Less |
| +1 health and armour bonuses | Less again |
| Corpses (off by default) | Least |

**What it never takes:** a living monster, something already in a hand or in the air, something invisible or drawn as
nothing, a barrel already going off, a projectile, another player, or RSQ VisualRewards' Kill Rewards bits (those are
left to RSQ Saber's Force pull).

**The flight.** By default a pulled thing takes the **Arc**: placed on a hump between where it was and your hand, re-aimed
at your hand every tic, so it lands in your palm even if you move. It flies at 22 m/s, between a sixth of a second and a
little over a second, so near and far pulls arrive at the same pace, with a soft pick-up and a settle into your hand. The
hump is a quarter of the distance high and comes down under a low ceiling; it ducks under door lintels. On the way it
turns once end over end and once about its own up. If it meets a wall it drops there.

**Flight Path** has two other choices: **Steer**, where the thing is pushed toward your hand and heavy things come
slower and turn lazier, and **Lob**, a lob re-aimed at your hand every tic that peaks about a metre up.

*[GIF to come: the beam idle (blue), on a shotgun (amber), locked (green), then the shotgun pulled to the hand in an arc]*

---

## Catching

A thing in the air is yours to catch once it is close to your palm. If your palm is out, you have it.

- **Use Pickups on Catch** (on): a caught pickup is used as if you walked over it. Off: everything is carried instead,
  so you can pull a medikit across the room and take it somewhere.
- **A gun goes to the hand that caught it.** Catch it with your off hand and it comes up in your off hand, and stays
  there until you move it. Not melee weapons, off-hand-only or two-handed guns, the saber or the ShieldSaw.
- **A gun you already have with full ammo** cannot be picked up. It stays in your hand to carry or throw, and the screen
  says so. Caught in the off hand, your own copy of that gun comes up in the off hand as well.
- **Missed it?** It stops on your palm for a moment (4 tics), then drops. A miss never hurts you or spends the item.

A green bloom flashes at your palm on a catch, with a thud: deeper and louder the heavier the thing.

*[GIF to come: a medikit pulled and caught; then a shotgun caught in the off hand and coming up there]*

---

## Carrying

A carried thing is held on a spring, not glued to your hand. It sits 30 cm in front of your hand plus half its own size,
so it is never in your face, and walls stop it: push it against a wall and it stays at the wall. Hold it back more than
1.5 metres for half a second (stuck behind a corner, or you walked off) and you let go of it.

- **Weight.** A clip follows your hand through any move. A barrel lags, hangs lower and dips when you swing it. With
  **Heavy Slows You** on, carrying 120 kg halves your walking speed; one barrel leaves you about two-thirds of it.
- **Tip With Wrist:** it tilts as you turn your wrist from the moment you caught it. A voxel (BD_VoxelPack's barrels,
  ammo and guns) turns all three ways.
- **Two hands.** Put your other, empty palm on it (within its body and a quarter metre) and it handles as if half as
  heavy: it follows faster, sags less and throws harder. It sits between your hands.
- **Hit With What You Hold.** Swing a carried thing into a monster at 3 m/s or more and it takes a blow, by the thing's
  weight and the swing's speed, once per swing. Most of the swing stops there, and you feel it.
- **Body Shield.** A carried barrel or corpse (20 kg or more) stops enemy fireballs that would cross it: they go off on
  it. A barrel that takes the hit goes off.

*[GIF to come: a barrel carried, then swung into an imp]*
*[GIF to come: a barrel held up as a shield, an imp's fireball bursting on it]*

---

## Throwing

Swing, and let go while your hand is moving. The throw takes the fastest moment of your forward stroke over the last
fifth of a second, measured against your body, so walking and turning are never a throw. A wind-up faster than the
throw is not what leaves your hand.

- **Weight.** Your arm counts as 30 kg moving with the thing. A keycard leaves at your hand's speed, a shotgun at about
  nine-tenths of it, a 60 kg barrel at a third. Then it is multiplied by 2.5, because a VR arm has none of the body
  behind it.
- **Running throws carry the run.** Thrown while moving, your own speed goes with it. Set down, it does not.
- **It flies like a real thing.** Everything that leaves a hand falls at real gravity, a long lazy arc rather than
  Doom's drop. Thrown things spin; flat sprites turn end over end; all of it settles when it lands.
- **Aim assist.** A throw within 12 degrees of a monster you can see is turned onto it, with its lob corrected to come
  down on its middle. Your speed is kept.
- **The hit.** What a thrown thing hits takes damage by its weight and speed: a shotgun at 12 m/s about 17, a barrel at
  5 m/s about 50. A blow of 20 or more knocks the monster into its pain and shoves it. A pickup flies straight through
  monsters in Doom, so passing through one counts as a hit too. The kill is yours.
- **Barrels go off.** A barrel thrown at 4 m/s or more goes off at its first hard stop (a wall, a monster, a hard
  landing), credited to you. Set down gently, it does not.
- **Hit-Stop** (off by default): a monster a thrown thing hits freezes for a beat (3, 4 or 6 tics).
- A hard landing kicks up dust, and every throw has a whoosh: higher the faster.

*[GIF to come: a thrown barrel arcing into a group of zombies and going off]*

---

## Barrel Lock-On

For when you have a barrel and want it in someone's face (on by default).

- **When it wakes up:** while your other hand carries a barrel, or you stand within punching reach of one. Then your
  free palm, turned out, picks the monster instead of an item.
- **The lock:** the monster wears the green "have" glow. Taking it needs the 12-degree cone; keeping it, twice that.
  Point at another monster and the lock moves. Take your palm off it and it holds 3 seconds, then half a second more in
  which a throw still goes to it (or where it last stood).
- **The throw:** a barrel thrown with a lock is aimed onto the monster and steered after it in flight, so it lands. A
  harder swing throws it flatter and faster; the softest it goes is the lob that just reaches. It ducks under lintels and
  window tops on the way.
- **With RSQ Melee:** a barrel your uppercut kicks goes to the lock too, if the lock is roughly ahead (within 60
  degrees).

*[GIF to come: a barrel in one hand, the other palm locking an imp, the barrel thrown wide and curving onto it]*

---

## Doors and switches

- **Lift a door.** Put a hand on a door's face and take hold: palm out against it, the grip, or Use. Raise your hand and
  the door rises with it, two and a half times your hand's travel, capped at four times the door's own speed (a wide
  door is heavier). The door's own opening sound plays, its pitch following how fast you lift.
- **Let go past 40% open** and the door finishes opening by itself, then waits and closes as it always did. **Let go
  before that** and it drops shut.
- Ordinary doors (the ones you open with Use), from their front, and not while already moving. Locked doors still need
  their key, with the usual message.
- **Flip a switch.** Lay your palm, turned out, on a switch and it flips, exactly as a Use press would: its key check,
  sound and texture. Once per touch: take your hand off before it flips again.

*[GIF to come: a hand on a door, lifting it halfway and letting go; the door finishes opening]*
*[Still to come: a palm flat on a switch]*

---

## When your hand will not reach

So that fighting never pulls the room into the fight, a hand stands down while:

- **you two-hand a gun:** QuestZDoom's two-hand grip, BD22 VR Reloaded's two-hand holds, or your off hand on the gun
  (5 to 70 cm ahead of the gun hand, within 20 cm of the barrel). Both hands stand down, and stay down half a second
  after you let go.
- **it is fighting** (**Not With Melee**): wearing RSQ Melee's boxing gloves, or moving at punch speed in the last
  three-quarters of a second.
- **it holds a melee weapon, a lit saber or another mod's hand** (a switched-off saber hilt can still reach; a bare fist
  is an empty hand and reaches).
- **RSQ Tactical Rig is using it** (a holster, the radial, a door, the cigarette or the Zippo).

A hand that is already locked, pulling or carrying keeps going: the flick, the catch and the throw are fast on purpose.
Hold your palm out for half a second on a hand that cannot reach because of what it holds, and the screen says why, for example "Distance Grab:
the off hand does not reach -- a lit saber".

---

## The colours

| | Beam and cone | The thing |
|---|---|---|
| **Searching** | Blue, faint | |
| **On something** | Amber | An amber glow in its own outline, breathing slowly |
| **Locked** | Green | A green glow, brighter, breathing twice as fast |
| **In the air, in your hand** | Hidden | No glow |

The glow is a copy of the thing's own sprite drawn in light, so nothing about the thing itself changes. A thing drawn as
a voxel flashes its own colour instead (**Voxel Flash**), because a flat glow in front of a solid voxel looks like a
card. **Recolour Target** (off) tints the thing itself as well.

With RSQ Accessibility's colour-blind setting on, the colours become the series' pairs: grey, amber and azure for
protanopia and deuteranopia; grey, red and cyan for tritanopia; grey, yellow and magenta for High Contrast. "Locked" is
also clearly brighter and wider than "on something", so colour is never the only difference.

*[Still to come: the three beam states side by side, and the amber and green glows on a barrel]*

---

## Plays well with

- **RSQ Score:** reads every throw. **Thrown** (paid by how hard it landed), **Heavy Throw** (a throw of 100 kg or more), **Powder Keg** (killed by the blast of a
  barrel your throw set off, down the chain), **Air Catch** (thrown, caught back out of the air, thrown again), **Full
  Hands** (a shot kill while a hand carries something), **Body Blow** (a thrown corpse), **Hand-Me-Down** (a dead
  monster's gun thrown), **Clubbed** (a carried thing swung), **Throwaway** (a gun thrown). Combos with a throw: Alley-Oop,
  Catch This, Batter Up, Bait and Hook, Serve and Volley, Two Throws, Toss and Crack, Kitchen Sink, Bait and Switch,
  Fetch!, Pitch and Slice. Combos with a **thrown keg** (a thrown barrel's blast): Hot Seat, Aftershock, Demolition. With a
  swing: Batting Practice. Score's Life Crate registers itself, so you can pull it to you.
- **RSQ Melee:** its **Headlock** owns the off-hand grip on a living monster; when a monster is nearer your palm than
  anything this would take, the grip is the Headlock's. A monster you throw out of the Headlock flies through this
  pack's throw (your strength, its weight, the aim assist), and hurts what it hits and itself by the same rule. Its
  gloves and punches stand a hand down (above). Its **uppercut** sends a barrel to your Barrel Lock-On target (Score:
  **Field Goal**).
- **RSQ FnF:** pick up a flare you dropped or threw (its own **Flares** switch), and throw it again. With Brutal
  Doom, a burning flare that hits a small monster sets it alight.
- **RSQ Grenade:** its barrels are still Doom barrels underneath, so they are pulled, carried and thrown like any barrel,
  and go off on a hard throw. Its grenade pickups count as ammunition. Score's Kitchen Sink and Demolition combos mix the
  two.
- **RSQ Tactical Rig:** holsters come first; a hand in one never reaches or grips here. The rig leaves a hand lifting a
  door alone, and its key ring lifts doors through this pack's door lift.
- **RSQ SlowMo:** its locked-barrel cue knows when a Barrel Lock-On barrel lands on its monster.
- **RSQ Laser Sight:** both beams show at once. **Yield to Laser Sight** hides this beam on a hand Laser Sight already
  lights.
- **RSQ Saber:** a lit saber hand does not reach; a switched-off hilt does. Its Force hand stands this pack down.
- **RSQ VisualRewards:** its Kill Rewards bits are never taken here.
- **RSQ Accessibility:** One-Handed (the Off-Hand Modifier lets one controller play the off hand, and its Pull and Reach
  buttons stand in for the flick and the palm), Gesture Ease (wider palm tolerance, an easier flick), Steady Hands (the
  cone points from a smoothed hand), Photosensitive Mode (catch blooms and pulses dimmed and slowed), Cue Size, Rumble
  Strength, the colour-blind palettes, and Reset Every Mod.
- **Brutal Doom and BD22 VR Reloaded:** Brutal Doom's own barrels, floor guns and +1 bonuses are recognised for what
  they replace. BD22 VR Reloaded's axe goes to the hand that grabbed it, and its two-hand holds stand the grab down.

---

## Options

*Options → Radiant Silvergun Options → RSQ Distance Grab.* Everything is on one page; the fine-tuning numbers are under
Test and Debug. Defaults in brackets.

| Section | Rows |
|---|---|
| (top) | Distance Grab (On) · Reach (512 map units, about 15 m) · Aim Width (12°) · Not With Melee (On) · Line of Sight (On) · Palm Gate (On) |
| Pull | Flight Path (Arc; Steer, Lob) · Pull Gravity (Off) · Duck Under Doors (On) · Pull Trail (On) · Use Pickups on Catch (On) |
| Carry and Throw | Throw Strength (1.0) · Heavy Slows You (On) · Tip With Wrist (On) · Hit With What You Hold (On) · Body Shield (On) · Hit-Stop (Off; Tap 3, Beat 4, Heavy 6 tics) · Barrel Lock-On (On) · Sounds (On) · Landing Dust (On) |
| What You Can Grab | Barrels · Flares · Weapons · Powerups · Ammo · Health · Armor · Keys · +1 Bonuses (all On) · Corpses (Off) · Walk-Up Grab (On) |
| Doors and Switches | Lift Doors (On) · Grip Takes Door · Use Takes Door · Palm Takes Door (On; greyed with Lift Doors off) · Palm Flips Switches (On) |
| Beam | Beam · Dot · Reach Cone · Show When Idle (On) · Yield to Laser Sight (Off) · Target Glow (On) · Voxel Flash (On) · Recolour Target (Off) · Catch Flash (On) |
| Feel | Haptics (On) · Rumble · Approach Ping · Held Back Rumble (On; greyed with Haptics off) |
| Controls | Grab Keys (Off) · Main Hand Key (G) · Off Hand Key (H) (greyed while Grab Keys is off; still bindable) |
| Test and Debug: Gesture | Palm Roll (90°) · Roll Tolerance (30°) · Min Hand Pitch (-30°) · Flick Strength (5°/tic) · Lock Delay (0 tics) · Two-Hand Reach (0.2 m) · Hand Lead (1 tic) · Pose Jump Cutoff (1 m) · Walk-Up Reach (0.30 m) · Main Grip Key Codes (446) · Off Grip Key Codes (443 436) |
| Test and Debug: Pull | Arc Speed (22 m/s) · Arc Height (0.25) · Arc Pull-In (1.6) · Shortest Flight (6 tics) · Longest Flight (40 tics) · Pull Smoothness (0.6) · Pull Spin (1 turn) · Tumble (1) · Lob Height (1 m) · Pull Speed (12) · Steering (40) · Pull Strength (10 kg) · Flight Width (2) · Give Up After (140 tics) |
| Test and Debug: Catch and Carry | Catch Distance (24) · Catch Window (4 tics) · Hold Distance (0.30 m) · Hold Stiffness (0.6) · Max Hold Speed (40) · Break Distance (1.5 m) · Half Speed Mass (120 kg) · Heavy Sag (1.0) · Two-Hand Lift (2.0) |
| Test and Debug: Throw | Throw Boost (2.5) · Throw Aim Assist (12°) · Throw Spin (1.0) · Throw Gravity (0.27) · Flutter (0.35) · Air Time Limit (1400 tics) · Arm Weight (30 kg) · Impact Damage (15 joules a point) · Min Impact Speed (3 m/s) · Stagger From (20 damage) · Barrel Blast (4 m/s) · Swing Hits From (3 m/s) |
| Test and Debug: Beam and Feel | Beam Width (1.0) · Beam Brightness (0.8) · Dot Size (1.0) · Cone Brightness (0.45) · Glow Brightness (1.0) · Pulse Period (24 tics) · Rumble Strength (1.0) · Locked Rumble (0.15) · Door Commit Point (0.40) · Door Lift Gain (2.5) |
| Test and Debug: logs | Report Actions (Off) · Report Refusals (Off) |

The main page ends with **Reset All**, which resets both pages. **Palm Gate** off means a hand reaches whatever its pose;
it only works with **Grab Keys** on (without the keys, your palm is the input, so the row greys out). **Rumble** off swaps the rumble for single fixed buzzes in rhythm (a tick to lock, a ping that speeds up as
the thing closes, one tick or two on the catch). **Steering**, **Pull Speed** and **Pull Gravity** are for the Steer and
Lob paths; **Arc Speed**, **Arc Height**, **Arc Pull-In** and **Pull Smoothness** for the Arc.

The Arc's numbers, Pull Spin, Tumble, the air (Throw Gravity, Flutter, Air Time Limit), Tip With Wrist and Heavy Sag are
the server's settings; everything else is each player's own.

---

## Known concerns

- (Fixed 11-10, code only, not run.) A gun you already carry with full ammo still can't be taken, as walking over it
  leaves it on the floor; now **AMMO FULL** floats over it for a second (with RSQ VisualRewards; a short line on screen
  without it), your hand gets a soft buzz, and it drops at your feet for when you're low.

## Status

| | |
|---|---|
| **Shown on the rig** (2026-11-09) | The pack loaded with no script error of its own on doom2, brutal22test6, BD_VoxelPack, BD22 VR Reloaded and the rest of the series, and its row appears under Radiant Silvergun Options. Nothing of the grab itself was exercised in that run |
| **Shown on the rig, earlier build** (2026-11-03, the pack's own evidence file) | With both palms turned out (scripted poses), the main hand locked a clip at range; the Kill Rewards health and ammo bits lying beside it were refused |
| **Headset-confirmed** | Nothing yet |
| **Code only, not yet shown** | Everything else on this page: the pull, the catch, carrying, throwing, swings, the shield, Barrel Lock-On, doors, switches, haptics and sounds |

The 11-03 log is a picture of what the code did then. It is not proof of the current build.

---

## Under the hood

- **Reading the hands.** QuestZDoom gives script ten pose fields and nothing else: no hand speed, no grip, no vibrate
  call. So every motion is differenced from the pose. The hands are taken where the last rendered frame put them,
  carried to where the body is now, so a slow frame never reads as a swing. A pose that jumps a metre in one tic (a menu
  opening, tracking lost, a save being drawn) is not trusted: nothing locks, a carried thing stops where it is, and
  nothing is thrown.
- **The throw** is the fastest two-tic window of the last seven that moves away from you (within 60 degrees of your
  facing), measured in the room's frame so walking, snap turns and head turns are never a throw. For two tics after a
  head turn the throw is blind, because the engine reports the hands swung the other way for one tic.
- **The flick** is a rate, not a distance: 5 degrees of wrist pitch upward in one tic, anywhere in the last fifth of a
  second. A slow lift of the forearm never fires it.
- **The cone** is measured in the room, not in Doom's vertically squashed map space, so pointing up is as easy as
  pointing sideways. Candidates are scored on angle first, distance a quarter as much, then divided by the square root
  of their kind's weight. A preference, never a veto. The sight check runs last, only for a thing that would win. The
  drawn cone is the volume that is tested: one model frame per degree, scaled by reach.
- **What may be taken** is an ordered table, first match wins, and it follows replacements: Brutal Doom's barrel, which
  replaces Doom's with no parent, is still a barrel; its +1 bonus is still a bonus. Other mods add their own things by
  name through `RSQDG_GrabRuleService` (`grab.rule`, `grab.deny`, `grab.weight`, `grab.forget`, after `grab.hello`);
  their rules sit above the table, and the menu's kind switches still apply.
- **Weights** come from `MASSDEF` lumps, which any pk3 may ship (a later line wins): exact class, then a measured gun
  from a weapon-weight service if one is loaded, then the class's ancestors and what it replaces, then a monster's Doom
  Mass, then a clamped volume guess. Asked by other mods through `RSQDG_MassService` (`mass.kg`, `mass.flags`,
  `mass.stated`, `mass.grams`).
- **Borrowed state, one owner.** The flight, the carry and the settle each save a thing's own flags and size before
  touching them and put them back on every way out. A released thing stays pass-through and uncollectable until it fits
  where it is (at most two seconds). A pickup flies 2 units wide, not at its pickup-trigger size.
- **The carry** is a spring: velocity toward a point ahead of the hand, the arm's part scaled by weight and your body's
  own motion carried in full. Walls refuse it; the gap is the strain the rumble plays and that ends the hold.
- **The impact** is a thrown thing's speed halving in a tic, judged with real gravity, once per throw. Damage is its
  kinetic energy over 15 joules a point. The thing is the inflictor and the thrower the source, so kills, infighting and
  barrel chains are credited to you.
- **Haptics** ride the engine's quake-to-controller path: a wave quake issued every tic is a per-hand amplitude dial.
  The fixed buzz (the pulse route) comes from a hitscan that touches nothing. The two cannot share a controller, so they
  are routes, not layers, and the rumble runs only while it means something. With `cl_capfps` on it falls back to the
  pulse.
- **Told to other mods**, found by name, nothing linked: every service whose name contains `GrabEventService` hears
  `pull.lock`, `pull.unlock`, `pull.start`, `pull.caught`, `pull.refused`, `pull.missed`, `pull.blocked`, `pull.aborted`,
  `hold.throw`, `hold.drop`, `hold.hit`, `hold.block`, `throw.hit` and `throw.impact`. `RSQDG_ThrowService` answers who
  threw a thing, how hard it landed, whether its throw set it off and how often it was caught back (for ten seconds), and
  carries the Headlock throw, `near.dist` and the Barrel Lock-On requests. `RSQDG_DoorService` answers `door.holding`.
- **Netplay.** Doors, switches and the walk-up grip travel as network events and run on every machine. The palm-out
  reach, the pull, the carry and the throw are decided and run for the player whose machine has the hands. Built and
  tested for single player.
- **Quest budget.** The cone is one blockmap walk per hand per tic, the table's answer cached per class, three render actors per
  hand for the beam, dot and cone, particles for the trail and dust.
- **Stock QuestZDoom 17.3:** ZScript and data only. No engine changes.

## Credits

The full list is in **CREDITS.txt**.

- **presidentkoopa:** his desktop RS_WorldHands, whose designs and numbers are re-written here for stock QuestZDoom: the
  pull's path and its tumble, the gravity, drag and flutter of everything that leaves a hand, a held thing tipping with
  the wrist and sagging by its weight, and the strain rumble.
- **Generated for this pack** (procedural, original): the beam and the reach cone models, and the cone's placeholder
  sprites, by `tools/gen_cone.py`. The aim dot's glow has no outside source recorded.
- **Ideas, no code or art taken:** the dot from QuestZDoom's bundled laser sight; the cone's look from DXR's debug wire
  cone; the beam from the lightsaber blade's crossed planes.
- **id Software's Doom:** the whoosh and the thud are Doom's own revenant swing and punch, pitched by speed and weight.
  This pack ships no sounds.
- **QuestZDoom** (Emawind and Team Beef): the engine and its hand-pose API.
