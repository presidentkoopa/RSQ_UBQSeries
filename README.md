# RSQ_UBQSeries — the Radiant Silvergun Quest series

VR add-ons for **Doom VR on stock QuestZDoom 17.3** (PCVR or Quest), one folder and one pk3 each. No engine
changes: everything is ZScript and data. Ready-to-load pk3s are in [`pk3/`](pk3/).

**Each mod works alone; together they make one arcade game.** They find each other by name at run time, so any
combination loads, in any order among themselves. Brutal Doom VR Reloaded is the weapon set they are played with,
but the series is not a Brutal Doom pack: each mod's README says what it does on plain Doom 2.

**Each mod's README is its manual** — what it does, how you play it in VR, every menu row with its default, what it
does with the other mods. [WHO_OWNS_WHAT.md](WHO_OWNS_WHAT.md) says which mod owns each mechanic.

## The mods

Each mod has one thing it does that nothing else does. That is the first line of its README, and it is this column:

| | Mod | pk3 | The one thing |
|---|---|---|---|
| ✋ | [DistanceGrab](DistanceGrab/) | `RSQ_DistanceGrab.pk3` | Gravity gloves: palm out at a thing across the room and it flies into your hand; carry it, swing it, throw it, hide behind it. Yours from the start, no levelling. |
| 🥊 | [Melee](Melee/) | `RSQ_Melee.pk3` | Your real swing is the punch: how fast you hit is how hard it lands, with uppercuts that lift, a gun-butt shove that slows time, a Hadouken that punches a fireball back at its shooter, and a Headlock you throw monsters out of. |
| 🛡️ | [ShieldSaw](ShieldSaw/) | `RSQ_ShieldSaw.pk3` | Rev the shield, lock your targets, and throw it as a saw disc that cuts through them, grinds the one it sticks in, and comes back to your hand. id Software's shield saw (*Doom: The Dark Ages*), brought to Doom VR first by **Ermac**. |
| ⚔️ | [QuestSaber](QuestSaber/) | `RSQ_Saber.pk3` | A blade that really blocks: it reads its own sweep against every shot in flight, so a bolt that crosses the blade is stopped and sent back where you look. And the Force from the off hand: push, pull, grip, jump, lightning. |
| 🎒 | [TacticalRig](TacticalRig/) | `RSQ_TacticalRig.pk3` | Holsters on your real body: reach to a hip, your chest or a shoulder and the gun is there. And Ermac's cigarette: light it, take a drag, flick it, and time slows. |
| ⏱️ | [SlowMo](SlowMo/) | `RSQ_SlowMo.pk3` | Slow motion with no engine change: every monster and every shot slows while your hands stay on real time, enemy bullets become rounds you can lean out of, and a Shootdodge leaps you through it. |
| 🔴 | [LaserSight](LaserSight/) | `RSQ_LaserSight.pk3` | The laser comes out of the gun's real barrel in either hand, and the dot is where the shot truly lands (Brutal Doom VR's own shot line), with the grenade launcher's arc. |
| 🪝 | [Grapple](Grapple/) | `RSQ_Grapple.pk3` | Fling the hook from either hand and it takes you to the wall, or takes the monster to you; turn on the swing, reel up, and put both hands on the rope. |
| 🐍 | [Whip](Whip/) | `RSQ_Whip.pk3` | A real bullwhip, simulated: MIT Newman Lab's reference whip, run node for node as a position-based chain, so every crack, wrap and swing comes from how you actually move your arm. |
| 🎡 | [Wheel](Wheel/) | `RSQ_Wheel.pk3` | A data sheet for every gun you own — ammo, kills, shots, accuracy, Gun Bonsai level, what the gun's own mod knows about it — on a wheel that works with any weapon set you load. |
| 🃏 | [GunCards](GunCards/) | `RSQ_GunCards.pk3` | A holo ammo card riding the gun itself, and a glance at your watch brings up the whole card on the back of your wrist. |
| 🤲 | [Gestures](Gestures/) | `RSQ_Gestures.pk3` | It reads how your real hands move — a watch check, a thrust, a punch and what kind, a gun-butt shove, both hands together — and every other mod in the series fights with that. |
| ❤️ | [TopHPBars](TopHPBars/) | `RSQ_HPBars.pk3` | A health bar over every monster you hurt that also shows what each series mod is doing to it right now — hooked, stunned, locked, gripped, frozen, held, raised — in six colour sets, three built for colour-blind eyes. |
| 🏆 | [Score](Score/) | `RSQ_Score.pk3` | Every move in the series is a word in one language, so a kill made with the whip, the shove and the shotgun in slow motion is one named combo that pays. |
| 👹 | [Miniboss](Miniboss/) | `RSQ_Miniboss.pk3` | Every map has a miniboss fed by three thralls; kill a thrall and time slows, get greedy and the whole map enrages. Rebuilt from Tartlman's Minibosses!. |
| 🌳 | [GunBonsaiOffhandVR](GunBonsaiOffhandVR/) | `RSQ_GunBonsaiVR.pk3` | Each hand earns its own XP, and every tool in the series has a tree to climb: the fists, the saber, the shield, the whip, the grenade, the hook, slow motion, the rig. An addon for ToxicFrog's Gun Bonsai 0.10.6 (not included), loaded right after it. |
| 💣 | [Grenade](Grenade/) | `RSQ_Grenade.pk3` | A grenade you work with your hands: pull the pin with the other hand or your teeth, cook it, and throw it with your own arm. Stands down for BD22 VR's own grenade. |
| ♿ | [Accessibility](Accessibility/) | `RSQ_Accessibility.pk3` | One settings page every mod in the series reads: handedness, seated play, Steady Hands, colour-blind colours, and one Reset for all of them. |

## Install

1. Take the pk3s you want from [`pk3/`](pk3/).
2. Load them **after** your weapon set and monster packs. The order the series is played with:

   ```
   doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded (2.0.3p)
             -> 04-07 XMVE Monster Expansion (BD22 versions)
             -> LegenDoom Lite, Champions, your other gameplay mods
             -> GunBonsai-0.10.6.pk3 -> RSQ_GunBonsaiVR.pk3 (only with Gun Bonsai, right after it)
             -> the other RSQ mods, in any order
   ```

   02-07 are the BD22 VR Weapons repo's `pk3/` folder (RS_Brutal22WeaponsQ). The four "No sprites specified for
   voxel" errors at start-up are the voxel pack's own.

3. Settings: **Options -> Radiant Silvergun Options**, one row per RSQ mod you loaded:

   | Mod | Row |
   |---|---|
   | QuestSaber | **RSQ Saber** |
   | ShieldSaw | **RSQ ShieldSaw** |
   | DistanceGrab | **RSQ Distance Grab** |
   | Grapple | **RSQ Grapple** |
   | LaserSight | **RSQ Laser Sight** |
   | TacticalRig | **RSQ Tactical Rig** |
   | SlowMo | **RSQ SlowMo** |
   | Score | **RSQ Score** |
   | Miniboss | **RSQ Miniboss** |
   | TopHPBars | **RSQ HP Bars** |
   | GunBonsaiOffhandVR | **RSQ Gun Bonsai VR** (Gun Bonsai's own menu stays where Gun Bonsai puts it) |
   | Whip | **RSQ Whip** |
   | Wheel | **RSQ Wheel** |
   | GunCards | **RSQ Gun Cards** |
   | Gestures | **RSQ Gestures** |
   | Melee | **RSQ Melee** |
   | Grenade | **RSQ Grenade** |
   | Accessibility | **Accessibility** |

   Every page has **Reset All** on its last page; Accessibility's Reset resets every series mod.

4. Keys: **Options -> Customize Controls**, one section per mod (Slow Motion and Shootdodge, the saber's ignite,
   the shield's draw, the whip, the wheel, Gun Bonsai VR's level-up menu). The hand moves need no keys.

## Trying them one at a time

Add **one mod per session** on top of your weapon set, play a map, then add the next. Every mod works alone, so a
problem you see belongs to the mod you just added. A good order, simple and visible first, the mods that read the
others last: Accessibility, LaserSight, TacticalRig, DistanceGrab, Melee, Saber, ShieldSaw, Whip, Grapple, SlowMo,
Gestures then GunCards, Wheel, HP Bars, Score, Miniboss, Gun Bonsai VR (right after Gun Bonsai), Grenade.

## Building and checking

```
python tools/build_all.py              # every mod into pk3/
python tools/build_all.py Whip Wheel   # just those folders
python tools/series_check.py           # the sanity check: every service, request, event and class name the
                                       # mods reach by string, then a headless run of the whole load order
```

Each folder is one mod's source and carries its git history (`git log -- ShieldSaw/`). `tools/qzd_hidden_run.ps1`
runs the desktop QuestZDoom headless for checks; `tools/rig17/` is the Linux rig. None of it ships.

## Credits

- **QuestZDoom**: Emawind and Team Beef. The engine, and the off-hand weapon and attack-pose script API all the mods
  are built on.
- **id Software**: the shield saw (*Doom: The Dark Ages*): its design, and the mesh Ermac ripped from the game; the
  Doom Eternal Classic Slayer, whose torso the TacticalRig wears (a rip, prepared in the project owner's RS_VRBody)
  and the Classic Slayer's helmet the rig's mirror shows (a rip, also prepared in RS_VRBody); and Quake's Grunt, its
  other torso.
- **Ermac**, co-designer of DoomVR ([Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), DXR, RS_Main):
  - Brought the shield saw to Doom VR first, in Rusted Legacy. In his words, he worked on two shield models: the
    first took him about three days to make work, the second was a rip from the game whose parts he separated in a
    day. Which of the ShieldSaw's two meshes is which is not recorded ([ShieldSaw/README.md](ShieldSaw/README.md)).
    The ShieldSaw started from his version, with its hand model and sounds. His MIT licence covers his code, not the
    ripped mesh.
  - In the QuestSaber: the Force and impact FX sprites and the choke loop.
  - **The TacticalRig is built on his Virtual Tactical Vest idea**, and the cigarette is his tribute idea: the
    cigarette, butt and smoke come from that mod (its credits name him as their modeller; the cigarette's texture
    atlas is shared with a Sketchfab pack model), and the Zippo is the voxel lighter from his ZBlood-VR, credited to
    him there.
- Sharing other people's work in this series is the project owner's decision. See
  [ShieldSaw/README.md](ShieldSaw/README.md) and each mod's CREDITS.txt ([QuestSaber](QuestSaber/CREDITS.txt),
  [TacticalRig](TacticalRig/CREDITS.txt), [DistanceGrab](DistanceGrab/CREDITS.txt), [SlowMo](SlowMo/CREDITS.txt)).
- **li-gnrcwpn**: the training remote's ready beep.
- **Vittorio Romeo**: his original Quake VR mod cut Quake's Grunt into the torso the TacticalRig can wear.
- **jpalomo**: the grapple's hook art and sound.
- **coldcite**: Top HP Bars, which RSQ HP Bars is built on. **Tartlman**: Minibosses!, which RSQ Miniboss was rebuilt
  from. **ToxicFrog**: Gun Bonsai, which RSQ Gun Bonsai VR is an addon for. **SoM**: Universal Kill Rewards, folded
  into Gun Bonsai VR's player path with his permission. **ijon**: Dakka's scoring, the root of RSQ Score.
- The project owner's libraries: RS_CombatFX (the rig's holster, draw and foley sounds), RS_Ballistics (SlowMo's
  tracer mesh and near-miss whiz and crack), RS_SlowMo (SlowMo's design and events).
- **Bullet Time X** (Xortts, CC BY-NC 4.0): SlowMo's Shootdodge and Slow Me Too follow its model (a forced jump, time
  slowed until you land, the player's own movement divided with the world's), written here from scratch; nothing of
  its code or assets is used, and SlowMo recognises it by class name so the two never run together.
- Everything else (meshes, skins, code) was made for these mods.
