# RSQ_UBQSeries — the Ultra Badass Quest series

Four standalone add-ons for **Doom VR on the Quest**, all in one place: a distance grab, a laser
sight, a shield-saw and a lightsaber. Each one is its own pk3. Load any of them, in any order,
alone or all together.

They target **stock QuestZDoom 17.3** (TeamBeef / Emawind). There are no engine changes. Everything
is ZScript and data lumps.

| | Mod | pk3 | What it is |
|---|---|---|---|
| ✋ | [DistanceGrab](DistanceGrab/) | `RSQ_DistanceGrab.pk3` | Turn your palm out, flick, and pull items, guns, barrels and bodies to your hand. Then carry them, throw them, and hit things with them. |
| 🔴 | [LaserSight](LaserSight/) | `RSQ_LaserSight.pk3` | A laser on every gun in every mod, in both hands, with no per-weapon setup. Any colour, plus lock-on and headshot cues. |
| 🛡️ | [ShieldSaw](ShieldSaw/) | `UltraBadassShieldSaw.pk3` | A shield on your off shoulder that blocks, bashes and turns shots back, and doubles as a throwable saw disc that hunts the targets you ring. |
| ⚔️ | [QuestSaber](QuestSaber/) | `UltraBadassQuestSaber.pk3` | A volumetric lightsaber, with an optional second one in the off hand. Cut, block, deflect, throw, and use the Force. |

---

## Install

1. Grab the pk3s you want from [`pk3/`](pk3/).
2. Load them **after** your weapon pack. The tested order is:

   ```
   doom2.wad -> brutal22test6 -> BD_VoxelPack -> any of the four, in any order
   ```

3. Settings live under **Options** in the game:

   | Mod | Options menu entry |
   |---|---|
   | DistanceGrab | **Distance Grab** |
   | LaserSight | **Laser Sight** |
   | ShieldSaw | **RS ShieldSawQ Options** |
   | QuestSaber | **Ultra Badass QuestSaber** |

   Every mod's menu has a **reset** row that puts all of its settings back to default.

## Quick controls

**DistanceGrab.** Turn your palm out to arm the reach. What you could take glows amber, and green
once it's locked. Flick your wrist up to pull it. Keep your hand open to catch it, then roll your
palm back to let go, or snap your arm to throw. Heavy things pull slower, carry with lag and slow
you down. *(Optional button fallback: Customize Controls → Distance Grab.)*

**LaserSight.** It's on as soon as you hold a gun. Toggle each hand under Customize Controls →
Laser Sight. Melee weapons and off-hand utilities (the shield, the Force hand) don't get a laser.

**ShieldSaw.** Reach to your off shoulder and press **Use** to draw it, and press Use there again
to put it back. Hold **either off-hand button** to rev the saw and ring targets. Release while
snapping your arm forward to throw, and press again while it flies to call it back. Shots that
cross the shield's face are stopped or turned back. Shove it into an enemy to bash.

**QuestSaber.** It's in weapon slot 1. Swing to cut; the blade blocks and deflects. Your off hand
holds a second saber or the Force (push, pull, grip, jump). Keys under Customize Controls → Ultra
Badass QuestSaber: blade on/off, second blade, training remote.

## They work together

The four mods never link against each other. Each checks for the others by name at run time, so
a missing mod is simply never found:

- The **grab stands down on a hand holding a melee weapon**, the shield or the Force hand, since
  a swing is full of the grab's palm-out flick. A **QuestSaber hilt with its blade switched off can
  grab**: the saber reports this through its `UBQS_SaberService` (`saber.lit`).
- The **grab's beam hides on a hand where the laser already draws a beam**. The laser reports this
  through `RSQLS_SightService` (`laser.beam` / `laser.active`).
- The **laser stays off** melee weapons and off-hand utilities.
- The ShieldSaw and the saber share the hands cleanly: saber in the main hand, shield in the off.

Rumble on all of them goes through the one route the Quest runtime honours: amplitude-shaped,
fading, on the correct controller, and **only when something happens** (a hit, a block, a catch,
a lock). Nothing buzzes constantly.

## Repository layout

```
RSQ_UBQSeries/
├── pk3/             ready-to-load builds of all four (identical contents to the tested builds)
├── DistanceGrab/    source, docs/ (DECISIONS, HANDOFF), tools/ (asset generators, rig tests)
├── LaserSight/      source, docs/HANDOFF, tools/gen_assets.py
├── ShieldSaw/       source, README (full manual), HANDOFF
├── QuestSaber/      source, CREDITS, docs/HANDOFF_polish
└── build_all.sh     rebuilds every pk3 into pk3/
```

Each folder carries its **full git history** from the repo it came from (merged with
`git subtree`), so `git log -- ShieldSaw/` shows every ShieldSaw commit.

## Building

```sh
./build_all.sh
```

This needs `zip`. Each mod also keeps its original script (DistanceGrab and LaserSight use
`build.ps1` on Windows; ShieldSaw uses `build.sh`). `build_all.sh` packs exactly the same files.

## Status (2026-10-26)

All four are on their **polish** pass:

- Rig-tested on a Linux QuestZDoom build with posed controllers.
- All four load together in both orders, menus open, and a fight runs with no script errors.
- An independent review of every change was done and its findings fixed.
- **Not yet played on a headset.** Feel numbers (rumble strength, arc height, throw thresholds)
  are first guesses.

What changed, what's measured and what's still open is in each mod's handoff:
[DistanceGrab](DistanceGrab/docs/HANDOFF_2026-10-26.md) ·
[LaserSight](LaserSight/docs/HANDOFF_2026-10-26.md) ·
[ShieldSaw](ShieldSaw/HANDOFF.md) ·
[QuestSaber](QuestSaber/docs/HANDOFF_polish.md)

Known limits:

- In co-op, a bullet the shield turns back is credited to a helper actor, so friendly-fire rules
  don't apply to it.
- The top of the saber's haptic power slider saturates.

## Credits

- **QuestZDoom**: Emawind and Team Beef. The engine, and the off-hand weapon and attack-pose script
  API all four mods are built on.
- **Ermac**, co-designer of DoomVR (DXR, Rusted Legacy / RS_Main): the hand the ShieldSaw is held
  in, and the Force and impact FX sprites and choke loop in the QuestSaber. Used with his blessing.
  See [QuestSaber/CREDITS.txt](QuestSaber/CREDITS.txt).
- **li-gnrcwpn**: the training remote's ready beep.
- Everything else (meshes, skins, generated sounds, code) was made for these mods.
