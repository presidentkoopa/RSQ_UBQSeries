# RSQ_UBQSeries — the Radiant Silvergun Quest series

VR add-ons for **Doom VR on stock QuestZDoom 17.3** (PCVR or Quest), one folder and one pk3 each. No engine
changes: everything is ZScript and data. Ready-to-load pk3s are in [`pk3/`](pk3/).

**Each mod works alone; together they make one arcade game.** They find each other by name at run time, so
any combination loads in any order. Brutal Doom VR Reloaded is the tested weapon set, but the series is not a
Brutal Doom pack: each mod's README says what it does on plain Doom 2.

**[WHO_OWNS_WHAT.md](WHO_OWNS_WHAT.md)** says which mod owns each mechanic. **Each mod's README is its manual**: every feature with its exact menu row and default, the moves in VR, what
it does with the other mods, and a **Test it** checklist. Anything built on 2026-10-31 or later ran on a
simulated headset only and is marked *not yet headset-confirmed* there.

| | Mod | pk3 | What it is |
|---|---|---|---|
| ✋ | [DistanceGrab](DistanceGrab/) | `RSQ_DistanceGrab.pk3` | Palm out at a thing across the room, pull it to your hand, carry it, throw it. Up close the grip takes things, lifts doors, flips switches. |
| 🥊 | [Melee](Melee/) | `RSQ_Melee.pk3` | Fighting with your body: punches and SuperPunchOut's boxing gloves, Slappers Only, Guard, Hadouken, Wall Splat, Heavy Hands, the gun-butt shove with its slow-mo and the F.E.A.R. Effect, the off-hand Headlock. New 11-01 (moved from Gun Bonsai VR, Gestures, Distance Grab). |
| 🛡️ | [ShieldSaw](ShieldSaw/) | `RSQ_ShieldSaw.pk3` | A shield (stowed at the small of your back by default) that blocks, bashes and turns shots back, and throws as a saw disc. id Software's shield saw (*Doom: The Dark Ages*), brought to Doom VR first by **Ermac**. |
| ⚔️ | [QuestSaber](QuestSaber/) | `RSQ_Saber.pk3` | A lightsaber, and a second one for the off hand (on/off in the menu). Cut, stab, block, parry, deflect, throw, and the Force (also from an off-hand fist). |
| 🎒 | [TacticalRig](TacticalRig/) | `RSQ_TacticalRig.pk3` | Six gun holsters (hips, chest, shoulders), a holster for each saber, a grenade spot, a keyring, gun throwing, a mirror, an optional torso and helmet, and Ermac's cigarette. Built on **Ermac's** Virtual Tactical Vest idea. |
| ⏱️ | [SlowMo](SlowMo/) | `RSQ_SlowMo.pk3` | The world slows, you don't. Enemy bullets become rounds you can step or lean away from, and (option) catch and throw back. |
| 🔴 | [LaserSight](LaserSight/) | `RSQ_LaserSight.pk3` | A laser from each gun's own barrel, in either hand, with a dot where the shot lands (Brutal Doom VR 2.0's real shot line) and a grenade launcher's arc. |
| 🪝 | [Grapple](Grapple/) | `RSQ_Grapple.pk3` | A grappling hook from either hand: swing, reel, climb hand over hand, two hands on the rope, yank monsters to you. jpalomo's hook art and sound. |
| 🐍 | [Whip](Whip/) | `RSQ_Whip.pk3` | A simulated bullwhip: cracks from how you swing, stings and stuns, lassos and leashes monsters, throws switches, catches edges to swing and climb. |
| 🎡 | [Wheel](Wheel/) | `RSQ_Wheel.pk3` | A weapon wheel for VR: a ring of weapon cards around your hand, point and let go (or reach in), a data sheet per gun. The owner's REMA wheel. |
| 🃏 | [GunCards](GunCards/) | `RSQ_GunCards.pk3` | Ammo cards on your guns in Ermac's holo style; check your watch for the full card (or, empty-handed, health/armour/keys). |
| 🤲 | [Gestures](Gestures/) | `RSQ_Gestures.pk3` | Reads your hands (watch check, thrust, pull, punch, shove, braced) and answers the other mods. Does nothing to the game by itself. |
| ❤️ | [TopHPBars](TopHPBars/) | `RSQ_HPBars.pk3` | coldcite's Top HP Bars with colour-blind sets, an overheal strip and icons for what the other mods are doing to a monster. |
| 🏆 | [Score](Score/) | `RSQ_Score.pk3` | The arcade score: style bonuses, cross-mod combos, a map target and extra lives. The owner's RS_Score on ijon's Dakka scoring. |
| 👹 | [Miniboss](Miniboss/) | `RSQ_Miniboss.pk3` | A miniboss each map fed by three thralls; kill a thrall to slow time, get greedy and every monster enrages. Rebuilt from Tartlman's Minibosses!. |
| 🌳 | [GunBonsaiOffhandVR](GunBonsaiOffhandVR/) | `RSQ_GunBonsaiVR.pk3` | An addon for ToxicFrog's Gun Bonsai 0.10.6 (not included): each hand its own XP, upgrades and HUD, upgrade paths for the series' tools (the gloves' and Guard need RSQ Melee). Loaded right after Gun Bonsai. |
| 💣 | [Grenade](Grenade/) | `RSQ_Grenade.pk3` | A hand grenade worked by hand on plain Doom 2: the other hand (or your teeth) pulls the pin, throw it with your arm, cook it, watch it flash red. Brutal Doom VR's handling; stands down for BD22 VR's own grenade. |
| ♿ | [Accessibility](Accessibility/) | `RSQ_Accessibility.pk3` | One settings page for the whole series: colour-blind, handedness, one-handed, comfort, cues, and one Reset for every mod. |

## Testing them one at a time

Add **one mod per session** on top of your Brutal Doom order, play a map, go through that mod's
**Test it** checklist (in its README), then add the next. Every mod works alone, so a problem you see
belongs to the mod you just added. Features built on 2026-10-31 or later ran on a simulated headset
only and are marked **not yet headset-confirmed** in each README; nothing about rumble could be felt there.

A suggested order -- simple and visible first, the mods that read the others last:

| # | Add | Why here |
|---|---|---|
| 1 | Accessibility | Handedness, colour-blind modes, Steady Hands, seated play: set once, every later mod reads it |
| 2 | LaserSight | One visible thing per gun; quick to confirm the load order is right |
| 3 | TacticalRig | Holsters; later mods (saber, ShieldSaw) hang on it |
| 4 | DistanceGrab | Pull, carry, throw, doors, walk-up grip |
| 5 | Melee | Punches and gloves, the gun-butt shove, the Headlock (its throw flies through Distance Grab's throw now) |
| 6 | Saber | Then check it with the rig's saber holsters |
| 7 | ShieldSaw | Then saber + shield together (saber over shield) |
| 8 | Whip | |
| 9 | Grapple | |
| 10 | SlowMo | Then the saber's / shield's / rig's slow-mo options start doing something |
| 11 | Gestures, then GunCards | GunCards' watch card comes from Gestures' wrist twist |
| 12 | (Melee, again) | With SlowMo now loaded, recheck the shove's slow-mo and the F.E.A.R. Effect |
| 13 | Wheel | |
| 14 | HP Bars | Its frozen / held / hooked markers read the other mods |
| 15 | Score | Combos need the tools above loaded to fire |
| 16 | Miniboss | Best with Champions + LegenDoom Lite |
| 17 | Gun Bonsai VR addon | Last, right after GunBonsai-0.10.6; with Melee loaded, Guard, Hadouken, Wall Splat, Heavy Hands become its upgrades |
| 18 | Grenade | Plain Doom 2 only (with Brutal Doom VR it stands down); then with Tactical Rig's buckle and Gun Cards' count |

After that, the full set together.

---

## Install

1. Take the pk3s you want from [`pk3/`](pk3/).
2. Load them **after** your weapon set. The tested order:

   ```
   doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j
             -> 04-07 XMVE Monster Expansion (BD22 versions) -> (optional) Champions -> LegenDoom Lite
             -> any RSQ mods, in any order
             -> GunBonsai-0.10.6.pk3 -> RSQ_GunBonsaiVR.pk3 (last; only with Gun Bonsai)
   ```

   02-07 are the BD22 VR Weapons repo's `pk3/` folder (RS_Brutal22WeaponsQ). The four "No sprites specified for
   voxel" errors at start-up are the voxel pack's own.

3. Settings: **Options -> Radiant Silvergun Options**. One row per RSQ mod you loaded:

   | Mod | Row under Radiant Silvergun Options |
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

## Building

```
python3 tools/build_all.py              # every mod into pk3/
python3 tools/build_all.py Whip Wheel   # just those folders
```

`build_all.sh` packs the same files. Each folder is one mod's source; most carry their full git history
(`git log -- ShieldSaw/`). `tools/rig17/` is the headless QuestZDoom 17.3 used for testing (it never ships).

## Status (2026-11-01)

- Everything loads together on the Brutal Doom order and on plain Doom 2 with no script errors from the
  RSQ pk3s (simulated headset).
- Built 2026-10-31 to 11-01 and **not yet headset-confirmed**: the owner's teardown picks and QoL rounds
  (see [PICKS_2026-10-31.md](PICKS_2026-10-31.md)), the walk-up grip / Headlock, real whip sounds, and RSQ Melee
  (11-01: the melee moves gathered into one pk3; checked on the simulated rig and the owner's load order only).
- Nothing about rumble could be felt on the simulated headset.
- Older release notes are in the git history.

## Credits

- **QuestZDoom**: Emawind and Team Beef. The engine, and the off-hand weapon and attack-pose script
  API all the mods are built on.
- **id Software**: the shield saw (*Doom: The Dark Ages*): its design, and the mesh Ermac ripped
  from the game; the Doom Eternal Classic Slayer, whose torso the TacticalRig wears (a rip,
  prepared in the project owner's RS_VRBody) and the Classic Slayer's helmet the rig's mirror shows
  (a rip, also prepared in RS_VRBody); and Quake's Grunt, its other torso.
- **Ermac**, co-designer of DoomVR ([Rusted Legacy](https://github.com/iAmErmac/rusted-legacy),
  DXR, RS_Main):
  - Brought the shield saw to Doom VR first, in Rusted Legacy. In his words, he worked on two
    shield models: the first took him about three days to make work, the second was a rip from
    the game whose parts he separated in a day. Which of the ShieldSaw's two meshes is which is
    not recorded ([ShieldSaw/README.md](ShieldSaw/README.md)). The ShieldSaw started from his
    version, with its hand model and sounds. His MIT licence covers his code, not the ripped mesh.
  - In the QuestSaber: the Force and impact FX sprites and the choke loop.
  - **The TacticalRig is built on his Virtual Tactical Vest idea**, and the cigarette is his
    tribute idea: the cigarette, butt and smoke come from that mod (its credits name him as their
    modeller; the cigarette's texture atlas is shared with a Sketchfab pack model), and the Zippo
    is the voxel lighter from his ZBlood-VR, credited to him there.
- Sharing other people's work in this series is the project owner's decision. See
  [ShieldSaw/README.md](ShieldSaw/README.md) and each mod's CREDITS.txt
  ([QuestSaber](QuestSaber/CREDITS.txt), [TacticalRig](TacticalRig/CREDITS.txt),
  [DistanceGrab](DistanceGrab/CREDITS.txt), [SlowMo](SlowMo/CREDITS.txt)).
- **li-gnrcwpn**: the training remote's ready beep.
- **Vittorio Romeo**: his original Quake VR mod cut Quake's Grunt into the torso the
  TacticalRig can wear.
- The project owner's libraries: RS_CombatFX (the rig's holster, draw and foley sounds),
  RS_Ballistics (SlowMo's tracer mesh and near-miss whiz and crack), RS_SlowMo (SlowMo's design
  and events).
- **Bullet Time X** (Xortts): nothing is taken from it; SlowMo only recognises it by class name
  so the two don't compound.
- Everything else (meshes, skins, code) was made for these mods. A few sounds are still generated here
  (four saber sounds, the rig's Zippo and cigarette); they break the owner's stock-or-real rule and are
  waiting for real recordings.
