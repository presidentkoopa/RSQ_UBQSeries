<p align="center"><img src="../design/readme_art/mods/questsaber_title.gif" alt="RSQ Saber"></p>

# RSQ Saber

A lightsaber for your own hands: it cuts what your real swing passes it through, harder the faster, and a blade held in the way stops shots, bolts and claws. Hold a hand's fire to lock on to monsters and let go on a swing to throw the saber round them and back to your hand. A second saber lives in the off hand, the Force (Push, Pull, Grip, a Force jump) comes with the saber, and a training remote stings you for practice.

<a name="how-to-play"></a>
## How to play

"Main hand" and "off hand" are the engine's two weapon hands. "Fire" is a hand's trigger; "alt fire" is that hand's alt fire. Each saber is read from the hand it is in: the main saber from the main hand's buttons, the second saber from the off hand's. Speeds of the blade are map units a tic (34 units are a metre and 35 tics a second, so 8 units a tic is about 8 m/s). Without a VR hand position the blade is not lit and none of the hand rows work.

| Do this | What happens | Needs |
|---|---|---|
| Start a game, or respawn | You are given the saber (weapon slot 1) and the Force. It is given again within 5 tics whenever you do not carry it | Sabers: On (default); Start With Saber: On (default) |
| Pick the saber from weapon slot 1 | It comes up in the main hand, the blade runs out over 8 tics with the ignition sound, then it hums. It always lights when drawn | |
| Leave the off hand empty (the main hand's weapon must not be a two-handed one) | The second saber comes up in the off hand by itself within 5 tics, lit | Dual Sabers: On (default) |
| Bring the saber into the main hand with the off hand empty and no second saber due there | The bare Force hand comes into the off hand. Switch the main hand off the saber and the Force hand leaves the same tic | The Force: On (default); Force Only With Saber: On (default); Dual Sabers: Off, or the second saber put away |
| Swing the lit blade so its tip travels 8 units a tic or more through a monster | It is cut: blood, sparks, smoke, a hit sound at the body and a buzz in that hand. A swing that fast also whooshes, at most once every 8 tics | Swing to Cut (default 8) |
| Swing faster or slower | A cut does half of Damage at 10 units a tic or less, Damage at 20, twice Damage at 40 or more: 15 to 60. The cut monster is shoved along the swing, lighter ones further | Damage (default 30) |
| Keep the blade in a monster | The same monster is cut again only after 8 tics. Nothing is cut through a wall | |
| Push or lean the blade into a monster without a fast swing | It still cuts once the blade's travel over the last few tics adds up: a steady 3.4 units a tic or so is enough. No whoosh | Swing to Cut (default 8) |
| Drive the hand along the blade's own line (within 30 degrees) with the blade turning less than 30 degrees | A stab: only the first monster along the blade is hit, for 1.5 times the damage, and it is not shoved | |
| Hold or swing the blade so a monster's missile crosses it (within 1.5 units of the blade plus the missile's own radius, tested 3 tics along the missile's path) | The missile is turned: it flies where you look, onto the monster nearest your gaze within 14 degrees if there is one, at 1.2 times its speed, and is yours. Clash sound, sparks, a flash | Block Width (default 1.5); Shot Lookahead (default 3 tics); Turned Shots Go: Your Aim (default) |
| Put the blade on the line of a monster's bullet (within 1.5 units of the blade, swept over the last tic) | The bullet is stopped before it is fired. One bolt in your blade's colour goes back at the shooter: 20 damage at 60 units a tic | Block Width (default 1.5) |
| Hold the blade across the line from a monster's middle to yours as it hits you in melee | No damage. The monster flinches and is pushed back, and a bolt goes back at it | Block Width (default 1.5) |
| Let a missile or a blast reach your body with the blade on its line | No damage. The missile itself goes back off the blade; a blast is stopped | Block Width (default 1.5) |
| Move the blade's tip 6 units a tic or more into the shot or claw as it is blocked | A parry: the buzz knocks twice, a white starburst at the blade, a higher clash, the return bolt up to twice as fast and a melee attacker pushed up to twice as hard | |
| Push the blade into a wall, a floor or a ceiling | A burn sound, at most every 5 tics. On a wall it leaves a scorch mark and an ember | |
| Bring your two lit blades within 3.5 units of each other (not hilt against hilt) | A clash: a crack, a white starburst, sparks, the buzz knocks twice. Held together they lock: a looping snarl, a flickering light and a buzz every other tic, until they are apart for more than 4 tics | A saber in each hand |
| Hold the two blades crossed while something attacks from within 100 degrees of where your body faces | The cross guard: an attack whose line crosses either blade (within 1.5 units) does no damage | A saber in each hand; Block Width (default 1.5) |
| Hold a saber hand's fire and point that hand at monsters | Lock on: every 3 tics the monster nearest the hand's line (within 14 degrees, within 1536 units, in sight) gets a lock mark, a diamond ring in the blade's colour, with a short buzz; up to 5 | Lock On Targets (default 5) |
| Let go of fire with monsters marked, the arm moving at 1.0 m/s or more toward the first mark (within 60 degrees) | The saber is thrown. It flies to each marked monster in turn, curving in at up to 9 degrees a tic on the first, cutting them, then comes home | |
| Let go of fire with monsters marked and the hand still or moving away | Nothing is thrown. The marks stay 35 tics; press fire again in that time and they are picked back up | |
| Hold fire, swing, and let go with nothing marked, the hand at 2.2 m/s or more (its fastest 2 tics of the last 7) and within about 57 degrees of where you look | The saber is thrown along the arm's motion, steadied toward where the hand points: 14 units a tic at 2.2 m/s up to 44 at 5 m/s, out 410 to 819 units, then home | Throw Speed (default 2.2 m/s) |
| Let go of fire with nothing marked and the hand slower than that, or not toward where you look | Nothing | Throw Speed (default 2.2 m/s) |
| Throw with the wrist upright, or turned on its side | Upright it spins end over end; on its side it spins flat like a disc | |
| Watch the thrown saber | Its second blade lights as it leaves. It cuts every monster within a blade's length for 1.5 times Damage (45), each at most every 10 tics, turns missiles it meets, and scorches walls. A wall ends a free throw; a marked throw passes through walls | Damage (default 30) |
| Wait for the thrown saber | It flies to that hand at 30 units a tic, through walls if it must, and is caught within 26 units with the blade lit. After 12 seconds out it heads home whatever it was doing | |
| Press that hand's fire or alt fire while its saber is out of the hand | It is called back at once: it lifts for 8 tics, then flies to the hand at up to 34 units a tic | |
| Let the saber fail to reach your hand for 140 tics | It falls, shuts off and lies on the floor. Walk over it, or press that hand's fire, and you have it back | |
| Press alt fire on the main saber's hand | One Force Push a press from that hand, along where it points: monsters within 448 units and 40 degrees are thrown back (lighter ones further) and take 8 damage, and missiles in the cone are sent back: at the monster you look at (within 14 degrees), else along the push | The Force: On (default); Force Push on Alt: On (default) |
| Press it again, or try a Pull, within 1.5 seconds | A quiet click and nothing else: Push and Pull share one 1.5 second wait | |
| Hold alt fire on the second saber's hand and thrust that hand at 2 units a tic or more (about 2.1 m/s) within about 57 degrees of where you look | Force Push, half way between the thrust and where you look. One gesture a hold: let go of the button before the next | The Force: On (default); Gesture Sharpness (default 2.0); Gesture Straightness (default 0.55) |
| Hold that alt fire and yank the hand back toward you as fast | Force Pull: monsters within 768 units and 30 degrees (half way between where the hand points and where you look) are yanked toward you and lifted, pickups there fly to you and are taken, and your thrown sabers come home | The Force: On (default) |
| Hold that alt fire with the hand still (under 1.5 units a tic) for 8 tics, pointing within 12 degrees of a monster | Force Grip: it rises, hangs where the hand points and follows it, and takes 18 damage a second with a choking loop. Not bosses, nothing heavier than mass 600, nothing past 1024 units. A dim outline on a monster shows what a grip would take, whenever that hand points at one | The Force: On (default) |
| Let go of that alt fire while a monster is gripped | It is dropped. With the hand moving it is flung at 3.5 times the hand's speed (40 units a tic at most), and when it stops dead it takes 3 times its speed as damage | |
| Hold fire or alt fire on the bare Force hand and thrust, yank or hold still | The same Push, Pull and Grip | The bare Force hand in the off hand |
| With the saber in the main hand and a fist in the off hand (Doom's Fist, BD22 VR's RSQ_Hands, RSQ Melee's glove), hold the off hand's alt fire and thrust, yank or hold still | The same Push, Pull and Grip. The fist's own fire still punches | The Force: On (default) |
| Fight with a second blade lit | It cuts, blocks, turns shots and burns walls from the pommel end as the first blade does | |
| Hold jump with a saber in either hand, or the bare Force hand in the off hand | A Force jump: you keep rising for the first 8 tics of the jump; keep holding and you fall no faster than 5 units a tic | The Force: On (default); Force Jump: On (default) |
| Press Brutal Doom's Dual button (+user3) with the saber in the main hand | The second saber is put away (the off hand goes back to its empty hand or the Force hand), or brought out again | Dual Sabers: On (default) |
| With the second saber or the bare Force hand in the off hand and a gun in the main hand, flick the gun's barrel down 45 degrees within 4 tics to 40 degrees below level | The gun's own Reload state starts. Raise it above 15 degrees below level before the next flick | A main-hand gun with a Reload state |
| Open the options and press Training Remote with a saber in a hand | The training remote appears 112 units ahead, circles you between 56 and 300 units away, beeps, glows and fires red bolts at you: 2 damage each | |
| Turn a bolt back into the remote | A hit, and it is knocked away. Four hits within the round's 30 seconds: REMOTE DOWN, 25 health, and after 3 seconds it rises one round harder | |
| Let the round's 30 seconds run out, hold no saber for more than 10 tics, or press Training Remote again | The training is over and the remote leaves. On the clock or with no saber: TRAINING OVER with your rounds, best streak and points. On the button: "Training remote dismissed" | |
| Press Training Remote with no saber in a hand | "Training remote: draw your saber first" | |
| Walk over another saber mod's saber on the map (Wardust's Lightsaber, SWSP_Saber, Brutal Doom's sword, Xim's Star Wars Doom chainsaw) | It is this saber. One you already carry is swapped for this saber too | Sabers: On (default); Sword Becomes Saber: On (default) for Brutal Doom's sword |
| Look down at your hip while a saber you own is not in a hand | It is drawn hanging there, 21 cm to its side and 84 cm under the eyes: the main saber on the main hand's side, the second on the other. It cannot be taken from there | Show Sabers: On (default); RSQ Tactical Rig not loaded |
| Press alt fire on the main saber's hand | The main saber's second blade lights or goes dark, once a press | Force Push on Alt: Off (default On) |
| Press alt fire on either saber's hand | That saber's second blade lights or goes dark; no Push, Pull, Grip or Force jump, and no Force hand is handed out | The Force: Off (default On) |
| Turn a missile with the blade | It goes back at whoever fired it, or straight off the blade as a mirror | Turned Shots Go: At Shooter, or Mirrored (default Your Aim) |
| Cut a monster | It freezes for 3, 4 or 6 tics | Hit Stop: Light, Medium or Heavy (default Off) |
| Parry | Half a second of slow motion | Parry Slow Motion: On (default Off); RSQ SlowMo |
| Start a game | One saber only: the bare Force hand comes into the empty off hand while the saber is in the main hand. A second saber you already hold is not taken away | Dual Sabers: Off (default On) |
| Start a game | You are not given the saber. You have it once you pick up another mod's saber | Start With Saber: Off (default On) |
| Start a game | Nothing is given or swapped and bullets are not stopped at the muzzle. A saber you already carry still cuts, blocks and throws | Sabers: Off (default On) |
| Hold jump with a saber out | An ordinary jump | Force Jump: Off (default On) |
| Hold any weapon in the main hand with the off hand empty | The bare Force hand comes into the off hand whatever the main hand holds | Force Only With Saber: Off (default On); Dual Sabers: Off, or the second saber put away |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Saber

| Option | Default | What it does |
|---|---|---|
| **Sabers** | | |
| Sabers | On | Turns the saber on or off. |
| Start With Saber | On | You begin holding a saber; off, you find it and pick it up. |
| Dual Sabers | On | Start with a second saber as the off hand's weapon. |
| Show Sabers | On | Each saber you own and do not hold is drawn where it hangs. |
| **Blades** | | |
| Main Colour | Blue | The main blade's colour. |
| Main Length | 76 cm | The main blade's length. |
| Off Colour | Red | The off blade's colour. |
| Saber Sound | Graflex | The saber's sound set. |
| **Fighting** | | |
| Damage | 30 (15 to 60) | How hard a cut hits. |
| Rumble | On | Controller rumble on cuts and clashes. |
| The Force | On | The Force at all: push, pull, choke and jump. |
| Training Remote | (button) | Summons the training remote, or sends it away. |
| Test and Debug | (page) | Second saber and blade details, cut and Force choices, raw numbers and the debug view. |
| Reset All | (button) | Puts every RSQ Saber setting back to its default. |

<details><summary>RSQ Saber: Test And Debug (26 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Sabers** | | |
| Second Saber Starts | Put Away | Whether the second saber starts put away or in your hand. |
| Hand on the Hilt | On | Draws a hand gripping the hilt. |
| Sword Becomes Saber | On | Brutal Doom's sword is replaced by the saber. |
| Off Length | Same | The off blade's length, or the same as the main blade. |
| Blade Light | Low | How many dynamic lights each blade casts. |
| Off Blade Light | On | The off blade casts its own dynamic light. |
| **Fighting** | | |
| Swing to Cut | 8 (3 to 20) | How fast the blade must travel to cut. |
| Turned Shots Go | Your Aim | Where a turned shot goes (with Gun Bonsai VR its Deflect upgrades decide). |
| Hit Stop | Off | Tics a cut monster freezes (with Gun Bonsai VR its Strike True upgrade unlocks this). |
| Parry Slow Motion | Off | A perfect parry slows the world for a moment. |
| Lock On Targets | 5 (1 to 5) | How many targets a saber throw locks on (with Gun Bonsai VR its Battle Meditation upgrade unlocks this). |
| **The Force** | | |
| Force Push on Alt | On | The main saber's alt trigger pushes with the Force. |
| Force Jump | On | A Force jump, which changes how you move. |
| Force Only With Saber | On | The Force works only while you hold a saber. |
| Force Hand | Our Hand | The bare Force hand's look: our hand or the original. |
| Lightning Beam | On | Force Lightning is drawn as a beam per hop. |
| **Blade** | | |
| Block Width | 1.5 (0.5 to 6) | How far off a blade's line a shot or blade still counts as blocked. |
| Shot Lookahead (tics) | 3 (1 to 6) | Tics of a shot's path the blade is tested against. |
| Throw Speed (m/s) | 2.2 (1 to 6) | How fast your hand must move to throw the saber with nothing locked. |
| Swing Hum Boost | 1.1 (0 to 3) | How much louder the hum gets on a hard swing (0 steady). |
| **Force Gestures** | | |
| Gesture Sharpness | 2 (0.5 to 6) | How sharp a push or pull gesture must be. |
| Gesture Straightness | 0.55 (0.2 to 0.95) | How straight a push or pull gesture must be. |
| **Other** | | |
| Remote Start Level | 2 (1 to 3) | The training remote's starting level. |
| Rumble Hand | Auto | Which controller the rumble goes to. |
| Debug View | Off | Shows the blade-line dots or the glow readout. |
| Reset All | (button) | Puts every RSQ Saber setting back to its default. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Tactical Rig | The Rig holsters and draws the sabers (its own code, by class name): a saber put on any empty holster goes to its own, and the second saber's holster sends this mod `ubqs_dual_in` and `ubqs_dual_out`, which put the second saber away and bring it into the off hand. With the Rig, Second Saber Starts: Put Away (default) starts the second saber in that holster. A holstered second saber stays holstered across maps and saves. The Rig draws the hip sabers and reads Show Sabers; this mod then draws none |
| RSQ Wheel | The Wheel shows a saber card with its own icon and, picked with either hand, puts the saber in the main hand; the second saber is left as it is (the Wheel's own code). This mod sets the saber's icon (WRISABER) and the Force hand's (WRIFORCE) |
| RSQ Gun Bonsai VR | The sabers and the Force level up: turned shots, return bolts and the thrown saber are credited to the saber that sent them, the Force's damage to a saber. With it loaded and its Unlock RSQ Features on: no Force until Force Sensitive is learned, and each power only once learned (40% at level 1, full at 3); the second saber needs Two Sabers; the second blade needs Double-Bladed (its cut from level 2); a blade stops a shot but does not send it back until Deflector, then Return to Sender and Guided Return choose where it goes; Lock On Targets and Hit Stop are capped by Battle Meditation and Strike True. It adds Force Speed, Force Lightning, Momentum, Riposte Edge, Piercing Return, Saber Throw, Saber Barrage, Returning Blade, Kyber Attunement, Point Taken, Run Through, Precognition, Cross Guard, Clash and Chain Choke, whose numbers this mod asks for by name. Rows behind an unlearned upgrade are greyed |
| RSQ SlowMo | With Parry Slow Motion on, a parry asks for 500 ms of slow motion (`rsm_pulse`). The training remote asks for 300 ms on every deflect and 1500 ms when it goes down, and sends `ubqs_remoteslowmo` so SlowMo's own Training Remote row decides. Sparks, smoke, rings and embers left in the world play at the world's slowed speed |
| RSQ Score | Deflect and Remote Down are paid as awards. Stabs, Force slams, Force Lightning, Cross Guard returns, clash waves and more are reported as touches. While the remote is out Score's wrist digits make room for the remote's wrist panel (it looks for `UBQS_RemoteOut`). Score asks this mod when a monster was blocked, parried or pulled and which way a thrown saber is flying |
| RSQ VisualRewards | The remote's short messages are shown as its toasts. Its HP bars ask this mod whether a Force grip holds a monster |
| RSQ Distance Grab | It asks this mod whether a hand's saber is lit (`saber.lit`): a lit or thrown saber keeps that hand busy (Distance Grab's own code) |
| RSQ Laser Sight | It draws no laser from a hand holding a melee weapon or the Force hand unless its own melee setting is on. Both sabers are melee weapons (Laser Sight's own code) |
| RSQ Melee | With its Slappers Only on, this mod hands out no saber, second saber or Force. Its off-hand glove counts as an empty hand: the Force hand takes its place while the saber is in the main hand and the glove comes back after. With the glove kept in the off hand, its alt fire is the Force |
| RSQ Gun Cards, RSQ ShieldSaw, RSQ Whip | They name the saber's classes in their own code: the card reads SABER; the ShieldSaw treats a filled off hand and a braced saber by name; the Whip counts the Force hand as an empty hand |
| BD22 VR Reloaded | Its RSQ_Hands is the off hand's empty hand: a put-away second saber leaves RSQ_Hands there, not the Force hand, and with a gun in the main hand the second saber does not come up by itself. Its `rsq_flick` setting switches this mod's flick reload off too |
| Brutal Doom | Its sword (DSweap) becomes the saber (Sword Becomes Saber, default On). Its Dual button (+user3) puts the second saber away and brings it out |
| Wardust's Lightsaber, SWSP_Saber, Xim's Star Wars Doom | Their saber is replaced by this one on the map and in your inventory |
| Any mod, by name | This mod answers `UBQS_SaberService`: `saber.lit` (hand 0 or 1: 1 lit or thrown, 0 blade off, -1 no saber), `gripped` (a monster), `blocked`, `perfect`, `pulled` (tics since, or -1), `thrown.leg` (0 out, 1 home), and for the menu `menu.locked`. It acts on the network events `ubqs_remote`, `ubqs_twist`, `ubqs_dual_in`, `ubqs_dual_out`, `ubqs_blade2`, `ubqs_ignite` and RSQ Accessibility's `rsqa_alt` |

## Limits

- There are no keys. KEYCONF adds the saber to slot 1 and one alias, `ubqs_remote_toggle`, which is the menu's Training Remote button.
- Buttons read: each saber hand's fire and alt fire, jump, and Brutal Doom's +user3. No grip key, Use button or stick is read; the engine's two-hand grip flag is.
- Nothing a player can press turns the blade off: the saber is lit whenever it is in a hand. `ubqs_ignite` and `ubqs_blade2` are still answered, but only a typed `netevent` reaches them.
- No wrist twist lights a second blade. A second blade shows on a thrown saber, and from alt fire with Force Push on Alt off (or The Force off).
- The second saber's alt fire is never the second blade while The Force is on: it is held for the Force gestures.
- Holding a hand's fire never throws: the throw is the let-go. With nothing marked, a throw that is not toward where you look does nothing.
- The blade does not cut players outside deathmatch, friendly monsters, or anything it cannot see from your body.
- The blade is not a shield: only an attack whose own line passes within Block Width of the blade is stopped, so where you hold it is the whole of it.
- One Force gesture a hold: after a Push, a Pull or a Grip, let go of the button before the next.
- Force Grip takes no boss and nothing over mass 600; Push and Pull do not move a monster that cannot be thrust.
- A monster of mass 0x7FFFFFFF (how some mods mark one that cannot be moved) is cut, pushed and pulled for damage but never moved.
- The Force jump works only with a saber in a hand or the Force hand in the off hand.
- The training remote is not a monster: it cannot be locked on, and Your Aim's help onto the nearest monster never picks it.
- Without RSQ Tactical Rig there is no holster: the sabers drawn at the hip are a picture, and the second saber is put away only by +user3.
- The sabers stay in their own hand and can't be moved to the other hand.
- The blade comes in five lengths and no others: 54, 65, 76, 88 and 99 cm.
- The whole saber drawn as a world model (`ubqs_world_saber`) has no menu row; it is used by itself only for the off hand under a two-hand grip.
- With the off hand gripping the main hand's weapon (the engine's two-hand grip), the second saber's fire is read only while the main hand holds a saber.

## Credits

The full list is in **CREDITS.txt**.

- **presidentkoopa:** the saber itself, its design and its handling.
- **Ermac** (RS_Main, DXR, Rusted Legacy): the combat effect sprites used for the Force and the blade's impacts (the
  choke's lightning arcs, the blast smoke, the hand flare), the Force choke loop, and the Original Force hand.
- **Brutal Doom 22 VR Reloaded** (presidentkoopa): the hand on the hilt and Our Hand, from its FBX hand in its magazine
  hold. The FBX's own author and licence are not recorded.
- **QuestZDoom** (Emawind): the engine, and the off-hand weapon and hand API this pack is built on.
- **danger_doughnut52** (dinopixel.com): the saber's icon, "Jedi Lightsaber (Star Wars)" pixel art.
- **li-gnrcwpn:** the training remote's ready beep.
- **The saber model** is believed to come from Star Wars Jedi Outcast (Raven Software / LucasArts), and **the saber
  sounds** from a lightsaber sound font library; their authors are not recorded. Force Lightning's crackle is from the
  owner's RS Ballistics sounds. The blade and glow shapes and the generated sounds are this pack's own.

---
Written from the code at commit be048d6e1, 2026-11-27.
