# Radiant Silvergun Quest

Twenty VR mods for Doom on stock QuestZDoom 17.3: holsters on your body, a real lightsaber, a simulated bullwhip, a
grenade you pin with your teeth, a world you can slow down, and a dozen more, all built in ZScript alone.

Status: 0.99 — every mod played and confirmed working in the headset; the newest additions are tested on the rig with a
headset check pending (each mod's README lists them). A full headset pass takes the series to 1.0.

By presidentkoopa, with ideas and assets from Ermac and the people credited below.

## Why this is new

QuestZDoom 17.3 is the engine that runs Doom on the Quest and on PC VR. To a mod it gives two hand positions and
their angles, once a frame. That is all. There is no body, no hand speed, no gestures, no holsters, no physics rope,
no way to slow the world, no shared menu for a family of mods.

This series builds every one of those things in ZScript, on the stock engine, with no engine changes:

- **A body.** A torso that turns with your stick turns and follows a real turn in the room, with holsters that stay
  on it while you look around.
- **Hands that mean something.** Swing speed, punches classified as jab, hook or uppercut, wrist flicks, a palm
  turned out, a watch check, two hands moving together: all read from those two positions.
- **Physics the engine never had.** A bullwhip simulated as 25 links of leather at 16 sub-steps a tic, grapple ropes
  you swing and climb hand over hand, thrown sabers and shields that fly a route and come home.
- **A world clock.** SlowMo slows every monster, missile and sound near you while you keep your own speed.
- **One family.** Every mod loads alone and finds the others by name at run time. Load any set in any order: they
  share one Radiant Silvergun Options menu, stand down for each other's hands, and feed each other's scores, upgrades
  and reactions.

## Get it and play

Download the pk3s you want from [pk3/](pk3/). Each RSQ mod works on its own; take one or take them all.

Load order, as the owner plays it:

1. doom2.wad
2. The Brutal Doom stack: brutal22test6.pk3, BD_VoxelPack, Brutal Doom 22 VR Reloaded (03_*), XMVE Monster Expansion
3. Gun Bonsai (ToxicFrog's, not included), if you use RSQ Gun Bonsai VR
4. The RSQ pk3s, in any order

Plain Doom 2 with RSQ mods and nothing else works too. A few features need their partner loaded (each README says
which); nothing breaks without it.

Every mod's settings live in **Options → Radiant Silvergun Options**, one page per mod. No console commands needed.

## The mods

### On your body

**[RSQ Tactical Rig](TacticalRig/README.md)** (RSQ_TacticalRig.pk3)
Your guns live on your body: six holsters on hips, chest and shoulders, plus spots for grenades, sabers, the whip, a
flare and an ammo pouch. Reach, grip, draw. The torso follows your stick turns and real room turns, and recenters
when you hold both hands to your chest. Throw a gun at a monster, wear a marine torso, smoke Ermac's cigarette.

**[RSQ Gestures](Gestures/README.md)** (RSQ_Gestures.pk3)
The series' body reader. It watches both controllers and tells the other mods what your hands are doing: the watch
check, a thrust, a shove, both hands together.

**[RSQ Accessibility](Accessibility/README.md)** (RSQ_Accessibility.pk3)
One menu that makes the whole series playable your way: one hand, seated, left-handed, colour blind, motion
sensitive or light sensitive.

### In your hands

**[RSQ Saber](QuestSaber/README.md)** (RSQ_Saber.pk3)
A lightsaber that cuts what your real swing passes through. Turn bolts with the blade, parry them back, cross two
blades into a guard. Mark enemies and throw it: it flies to each one and comes home. The Force is in your other hand.

**[RSQ ShieldSaw](ShieldSaw/README.md)** (RSQ_ShieldSaw.pk3)
A buzzsaw shield for your off hand: block, bash, rev it into a grinder, then paint targets and hurl it through all of
them and catch it on the way back.

**[RSQ Melee](Melee/README.md)** (RSQ_Melee.pk3)
Fight with your body. It knows which punch you threw. Swat fireballs with an open palm, drive a gun butt into a face,
hold a monster in a headlock while you work on it.

**[RSQ Whip](Whip/README.md)** (RSQ_Whip.pk3)
A real bullwhip: a simulated thong that cracks when you snap your wrist, wraps round monsters, pulls them to you, and
catches a beam so you can swing across the room.

**[RSQ Grenade](Grenade/README.md)** (RSQ_Grenade.pk3)
A hand grenade you work like a real one: pull the pin with your other hand or your teeth, cook it, throw it with your
own arm. Eight grenade types. Shoot it out of the air. (With BD22 VR Reloaded, its own grenade takes over.)

**[RSQ FnF (Flash and Flare)](FlashFlare/README.md)** (RSQ_FnF.pk3)
A road flare you pull from your chest and strike with a flick of the wrist, and a flashlight clipped to your chest
with a beam you can see in the air.

### Reaching the world

**[RSQ Grapple](Grapple/README.md)** (RSQ_Grapple.pk3)
A grappling hook in each hand: aim with your real arm, fire, fling yourself across the map, climb the rope hand over
hand, or drag monsters to your feet.

**[RSQ Distance Grab](DistanceGrab/README.md)** (RSQ_DistanceGrab.pk3)
Turn your palm out at anything across the room, flick your wrist, and it flies into your hand. Catch it out of the
air.

**[RSQ Laser Sight](LaserSight/README.md)** (RSQ_LaserSight.pk3)
A laser on every gun in both hands, out of the gun's own barrel, with the dot where the shot will land.

### The game around you

**[RSQ SlowMo](SlowMo/README.md)** (RSQ_SlowMo.pk3)
The world slows down. You don't. Watch enemy rounds coming and lean out of their way.

**[RSQ Score](Score/README.md)** (RSQ_Score.pk3)
An arcade scorer for VR Doom. Every kill pays for how you pulled it off, and every tool in the series chains into
combos.

**[RSQ Miniboss](Miniboss/README.md)** (RSQ_Miniboss.pk3)
Every level picks a champion from its own monsters, binds it to a crew of thralls that feed it, and dares you to go
for the head first.

**[RSQ VisualRewards](VisualRewards/README.md)** (RSQ_VisualRewards.pk3)
HP bars over every monster, damage numbers in the room with you, level-up moments you can read in a headset, and
monsters that burst into health, armour and ammo.

**[RSQ Gun Cards](GunCards/README.md)** (RSQ_GunCards.pk3)
Holographic ammo cards on your guns, and a status card on your wrist when you check your watch.

**[RSQ Wheel](Wheel/README.md)** (RSQ_Wheel.pk3)
A weapon ring that hangs in the air in front of you. Point at a gun with either hand and it is in that hand.

**[RSQ Glow In The Dark](GlowInTheDark/README.md)** (RSQ_GlowInTheDark.pk3)
Every room lit by its own colour, liquids breathing in their own light, the doors and keys you need standing out.
35 looks, and the map reacts to minibosses, level-ups, kill chains and slow motion.

**[RSQ Gun Bonsai VR](GunBonsaiOffhandVR/README.md)** (RSQ_GunBonsaiVR.pk3)
Two hands, two guns, two careers: Gun Bonsai rebuilt so each hand earns its own XP and grows its own upgrades, with
more than 170 new upgrades built around what you do with your body. Needs ToxicFrog's Gun Bonsai.

## Credits

- **presidentkoopa**: the series, its design and its code; his own mods and libraries it draws on (Brutal Doom 22 VR
  Reloaded, SuperPunchOut, RS_Grenade, RS_Holsters, RS_VRBody, RS_CombatFX, RS_Ballistics, RS_SlowMo, Glow In The
  Dark 1.1).
- **QuestZDoom**: Emawind and Team Beef. The engine, and the off-hand weapon and hand-pose script API every mod here
  is built on.
- **Ermac** (iAmErmac), co-designer of DoomVR (Rusted Legacy, DXR, RS_Main): the shield saw's first VR version, the
  Virtual Tactical Vest idea the Tactical Rig is built on, the cigarette tribute and Zippo, the boxing-glove and hand
  models, and the Force and impact effects in the saber. His MIT licence covers his code, not ripped meshes.
- **id Software**: the shield saw's design (Doom: The Dark Ages), the Doom Eternal Classic Slayer torso and helmet
  (rips, prepared in RS_VRBody), Quake's Grunt (cut into a torso by **Vittorio Romeo**'s Quake VR mod), and the stock
  Doom sounds the mods play by name.
- **ToxicFrog** (Rebecca Kelly): Gun Bonsai (MIT), which RSQ Gun Bonsai VR extends and does not include.
- **JohnnyDoom**'s UAC Survival Pack (with Froon, Saegiru, Pa1nki113r, and saegiru's Emergency Flare): the grenade's
  and the flare's sounds, sprites and rules.
- **Moses C. Nah, MIT Newman Lab**: the whip model's numbers (BSD 3-Clause).
- **Caligari87**'s DarkDoomZ, which Glow In The Dark and the flashlight work alongside; **Bullet Time X** (Xortts),
  which SlowMo only recognises by name so the two don't compound; **li-gnrcwpn** (the saber remote's beep); the
  ColorfulMaps and GlowingLiquids authors behind Glow In The Dark 1.1; and every author named in each mod's README
  and CREDITS file.

Sharing other people's work in this series is the project owner's decision. Borrowed assets keep their authors'
terms; each mod's README and CREDITS file says whose is whose.
