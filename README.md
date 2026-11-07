# Radiant Silvergun

Nineteen VR mods for Doom on stock QuestZDoom 17.3 PCVR or Mobile: holsters on your body, a real lightsaber, a simulated bullwhip, a
grenade you pin with your teeth, a world you can slow down, and a dozen more, all built in ZScript alone.

Status: 0.99 — every mod played and confirmed working in the headset. The newer additions, the 1.0 round of 11-06
and the 11-07 additions included, are rig only, not headset-confirmed (each mod's README lists them, and says where
something is built but not yet shown on the rig). A full headset pass takes the series to 1.0.

## DOWN: the arcade revive

New on 11-07 in RSQ SlowMo (rig only, not headset-confirmed; off by default: the DOWN row on RSQ SlowMo's page).
When a monster's killing hit lands, you are not dead yet: it holds you at 1 HP, before any RSQ Score life is spent.
You drop into a crouch and crawl, and the world slows to its deepest while your own shots fly at normal speed. A panel
low in your view shows a **DEATH IN** clock of 9 real seconds, a line for each target, and the reward bar.

- **Targets to kill:** the monster that downed you (or a boosted copy of it spawned in view), and one more each time you
  go down (1, then 2, then 3...; back to 1 when a Score life is spent). Each target has its own crosshair; arrows at the
  edge of your view and a trail at eye level lead you to it. While DOWN no hit can kill you: only the clock can.
- **The clock:** damage you deal buys time, never above 9 seconds.
- **The reward bar:** three 3-second steps, the tall one first, draining. Killing a target while others remain fills it
  again. The step you are in at the last kill is your tier.
- **REVIVE:** kill them all and you get up at once. By the tier: invulnerable 5 / 3 / 1 s and slow motion 3 / 1.5 / 5 s;
  the top tier also gives Score's Revival Fire, +1 cigarette and +1 grenade. Health and armour come from the bits your
  kills banked while DOWN (without a bank: 100 / 66 / 33 %), and both held guns' magazines are filled for free.
- **The clock at zero:** a Score life is spent, or you die.

It draws on RSQ Score (lives, Revival Fire, the Revenge row, target names and font), RSQ VisualRewards (the bits bank,
REVENGE and REVIVE, target HP bars), RSQ Glow In The Dark (the red map), RSQ Tactical Rig (the cigarette), RSQ Grenade
(the grenade), and Champions and LegenDoom (targets made real Champions, and their colours) when they are loaded. RSQ
SlowMo still loads alone. Details: [SlowMo's README](SlowMo/README.md) and [design/NEAR_DEATH.md](design/NEAR_DEATH.md).

Project directed and coordinated by presidentkoopa, with ideas and assets from Ermac and the people credited below.

## The series at a glance

| | Mod | pk3 | In one line |
|---|---|---|---|
| 🎒 | [Tactical Rig](TacticalRig/) | `RSQ_TacticalRig.pk3` | Holsters on your real body, a torso that turns with you, an ammo pouch, Ermac's cigarette. |
| ♿ | [Accessibility](Accessibility/) | `RSQ_Accessibility.pk3` | One-handed, seated, left-handed, colour-blind and comfort options for the whole series, and the gesture reader the other mods ask (watch check, both hands together). |
| ⚔️ | [Saber](QuestSaber/) | `RSQ_Saber.pk3` | A lightsaber that cuts with your real swing, turns bolts, flies to marked enemies; the Force in your other hand. |
| 🛡️ | [ShieldSaw](ShieldSaw/) | `RSQ_ShieldSaw.pk3` | Block, bash and grind with a buzzsaw shield, then throw it through your targets and catch it. |
| 🥊 | [Melee](Melee/) | `RSQ_Melee.pk3` | It knows which punch you threw: jabs, hooks, uppercuts, palm swats, gun-butt shoves, headlocks. |
| 🐍 | [Whip](Whip/) | `RSQ_Whip.pk3` | A simulated bullwhip that cracks from your wrist, wraps monsters and swings you across the room. |
| 💣 | [Grenade](Grenade/) | `RSQ_Grenade.pk3` | Pull the pin with your hand or your teeth, cook it, throw it with your arm, shoot it out of the air. |
| 🔥 | [FnF (Flash and Flare)](FlashFlare/) | `RSQ_FnF.pk3` | Strike a road flare with a flick and throw it; a chest-clip flashlight with a visible beam. |
| 🪝 | [Grapple](Grapple/) | `RSQ_Grapple.pk3` | A hook in each hand: fling yourself across the map, climb the rope, drag monsters to you. |
| ✋ | [Distance Grab](DistanceGrab/) | `RSQ_DistanceGrab.pk3` | Palm out, flick your wrist, and anything across the room flies into your hand. |
| 🔴 | [Laser Sight](LaserSight/) | `RSQ_LaserSight.pk3` | A laser from every gun's real barrel in both hands, the dot where the shot will land. |
| ⏱️ | [SlowMo](SlowMo/) | `RSQ_SlowMo.pk3` | The world slows, you don't: watch enemy rounds come and lean out of their way. |
| 🏆 | [Score](Score/) | `RSQ_Score.pk3` | An arcade scorer: every kill pays for how you did it, every tool chains into combos. |
| 👹 | [Miniboss](Miniboss/) | `RSQ_Miniboss.pk3` | Each level crowns a champion fed by thralls, and dares you to go for the head first. |
| ❤️ | [VisualRewards](VisualRewards/) | `RSQ_VisualRewards.pk3` | HP bars, damage numbers in the room, level-up moments, monsters that burst into loot. |
| 🃏 | [Gun Cards](GunCards/) | `RSQ_GunCards.pk3` | Holo ammo cards on your guns; check your watch for health, armour and keys. |
| 🎡 | [Wheel](Wheel/) | `RSQ_Wheel.pk3` | A weapon ring in the air: point at a gun with either hand and it's in that hand. |
| 🌈 | [Glow In The Dark](GlowInTheDark/) | `RSQ_GlowInTheDark.pk3` | Rooms lit in their own colours, breathing liquids, 35 looks, a map that reacts to you. |
| 🌳 | [Gun Bonsai VR](GunBonsaiOffhandVR/) | `RSQ_GunBonsaiVR.pk3` | Each hand earns its own XP and upgrades in Gun Bonsai, with 170+ body-built upgrades. |

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
3. Enemy mods, after XMVE: Legion of Bones (LOB_v1.05; after BD and XMVE, so BD's monsters keep BD's bullets and
   RSQ Graveyard's Bones Bridge works), then LegenDoom Lite, then Champions (mk-champions)
4. Gun Bonsai (ToxicFrog's, not included), if you use RSQ Gun Bonsai VR
5. The RSQ pk3s, in any order

With BD22 VR's own LegenDoom mode, LegenDoom 3.0 loads first instead, before brutal22test6 (see BD22 VR's README).

Plain Doom 2 with RSQ mods and nothing else works too. A few features need their partner loaded (each README says
which); nothing breaks without it.

Every mod's settings live in **Options → Radiant Silvergun Options**, one page per mod. No console commands needed.

Also in [pk3/](pk3/): `RSQ_Graveyard.pk3`, presidentkoopa's RSQ Edition of m8f's Graveyards (GPLv3): a gravestone
where you died, kept between sessions, animated and candle-lit. Its settings are under Radiant Silvergun Options →
RSQ Graveyards. It is not one of the nineteen and needs none of them.

## The mods

**[RSQ Tactical Rig](TacticalRig/README.md)** (RSQ_TacticalRig.pk3)
Your guns live on your body: six holsters on hips, chest and shoulders, plus spots for grenades, sabers, the whip, a
flare and an ammo pouch. Reach, grip, draw. The torso follows your stick turns and real room turns, and recenters
when you hold both hands to your chest. Throw a gun at a monster, wear a marine torso, smoke Ermac's cigarette.

**[RSQ Accessibility](Accessibility/README.md)** (RSQ_Accessibility.pk3)
One menu that makes the whole series playable your way: one hand, seated, left-handed, colour blind, motion
sensitive or light sensitive. It also carries the series' gesture reader (RSQ Gestures until 11-05, folded in): it
tells the other mods what your hands are doing, the watch check and both hands together. Remove any old
RSQ_Gestures.pk3 from your folder: loaded beside this Accessibility it gives duplicate class errors.

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
own arm. Eight grenade types. Shoot it out of the air. (With BD22 VR Reloaded, its own grenade takes over, unless Replace
Brutal Doom's Grenade is on.)

**[RSQ FnF (Flash and Flare)](FlashFlare/README.md)** (RSQ_FnF.pk3)
A road flare you pull from your chest and strike with a flick of the wrist, and a flashlight clipped to your chest
with a beam you can see in the air.

**[RSQ Grapple](Grapple/README.md)** (RSQ_Grapple.pk3)
A grappling hook in each hand: aim with your real arm, fire, fling yourself across the map, climb the rope hand over
hand, or drag monsters to your feet.

**[RSQ Distance Grab](DistanceGrab/README.md)** (RSQ_DistanceGrab.pk3)
Turn your palm out at anything across the room, flick your wrist, and it flies into your hand. Catch it out of the
air.

**[RSQ Laser Sight](LaserSight/README.md)** (RSQ_LaserSight.pk3)
A laser on every gun in both hands, out of the gun's own barrel, with the dot where the shot will land.

**[RSQ SlowMo](SlowMo/README.md)** (RSQ_SlowMo.pk3)
The world slows down. You don't. Watch enemy rounds coming and lean out of their way. DOWN, the arcade revive
(above), lives here too, off by default.

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
  models. His MIT licence covers his code, not ripped meshes.
- **id Software**: the shield saw's design (Doom: The Dark Ages), the Doom Eternal Classic Slayer torso and helmet
  (rips, prepared in RS_VRBody), Quake's Grunt (cut into a torso by **Vittorio Romeo**'s Quake VR mod), and the stock
  Doom sounds the mods play by name.
- **ToxicFrog** (Rebecca Kelly): Gun Bonsai (MIT), which RSQ Gun Bonsai VR extends and does not include.
- **JohnnyDoom**'s UAC Survival Pack (with Froon, Saegiru, Pa1nki113r, and saegiru's Emergency Flare): the grenade's
  and the flare's sounds, sprites and rules.
- **Moses C. Nah, MIT Newman Lab**: the whip model's numbers (BSD 3-Clause).
- **Caligari87**'s DarkDoomZ (zlib), which Glow In The Dark works alongside and whose flashlight FnF's DarkDoomZ light
  style is rewritten from; **m8f**'s Graveyards (GPLv3), carried in its RSQ Edition; **Jakie** (SnakieJakie)'s More
  Lights, merged into Glow In The Dark's glowing flats; **Bullet Time X** (Xortts),
  which SlowMo only recognises by name so the two don't compound; **li-gnrcwpn** (the saber remote's beep); the
  ColorfulMaps and GlowingLiquids authors behind Glow In The Dark 1.1; and every author named in each mod's README
  and CREDITS file.

Sharing other people's work in this series is the project owner's decision. Borrowed assets keep their authors'
terms; each mod's README and CREDITS file says whose is whose.
