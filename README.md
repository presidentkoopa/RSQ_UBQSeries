# RSQ_UBQSeries — the Ultra Badass Quest series

**Version 0.8a — 2026-10-26.** Ready-to-load pk3s are in [`pk3/`](pk3/).

Six standalone add-ons for **Doom VR on the Quest**, all in one place: a distance grab, a laser
sight, a shield-saw, a lightsaber, a tactical rig and slow motion. Each one is its own pk3. Load
any of them, in any order, alone or all together.

They target **stock QuestZDoom 17.3** (TeamBeef / Emawind). There are no engine changes. Everything
is ZScript and data lumps.

| | Mod | pk3 | What it is |
|---|---|---|---|
| ✋ | [DistanceGrab](DistanceGrab/) | `RSQ_DistanceGrab.pk3` | Turn your palm out, flick, and pull items, guns, barrels and bodies to your hand. Then carry them, throw them, and hit things with them. |
| 🔴 | [LaserSight](LaserSight/) | `RSQ_LaserSight.pk3` | A laser on every gun in every mod, in both hands, with no per-weapon setup. Any colour, plus lock-on and headshot cues. |
| 🛡️ | [ShieldSaw](ShieldSaw/) | `UltraBadassShieldSaw.pk3` | A shield on your off shoulder that blocks, bashes and turns shots back, and doubles as a throwable saw disc that hunts the targets you ring. Built on **Ermac's** ShieldSaw from Rusted Legacy. |
| ⚔️ | [QuestSaber](QuestSaber/) | `UltraBadassQuestSaber.pk3` | A volumetric lightsaber, with an optional second one in the off hand. Cut, block, deflect, throw, and use the Force. |
| 🎒 | [TacticalRig](TacticalRig/) | `RSQ_TacticalRig.pk3` | Weapons carried on your body (hips, chest, shoulders), doors you lift open by hand, and Ermac's cigarette. Built on **Ermac's** Virtual Tactical Vest idea. |
| ⏱️ | [SlowMo](SlowMo/) | `RSQ_SlowMo.pk3` | The world slows, you don't. Enemy bullets become rounds you can see and dodge. |

---

## Install

1. Grab the pk3s you want from [`pk3/`](pk3/).
2. Add them to your QuestZDoom load order the way you normally load mods, **after** your weapon
   pack. The tested order is:

   ```
   doom2.wad -> brutal22test6 -> BD_VoxelPack -> any of the six, in any order
   ```

3. Settings live under **Options** in the game:

   | Mod | Options menu entry |
   |---|---|
   | DistanceGrab | **Distance Grab** |
   | LaserSight | **Laser Sight** |
   | ShieldSaw | **RS ShieldSawQ Options** |
   | QuestSaber | **Ultra Badass QuestSaber** |
   | TacticalRig | **Tactical Rig** |
   | SlowMo | **RSQ SlowMo** |

   Every mod's menu has a **reset** row that puts all of its settings back to default.

## What each one does, and how to use it

### DistanceGrab
- **Reach:** turn your palm out (roll your hand so the palm faces away). Whatever you could take
  glows **amber**; once it's yours it glows **green**. A beam, a dot and the reach cone show where
  you're pointing.
- **Pull:** flick your wrist **up**. The thing flies to your hand: heavy things slower and lazier,
  light ones snappier. Keep your hand open and you catch it.
- **Carry and throw:** roll your palm back to let go, or snap your arm and let go to throw.
  Thrown things hit with their weight; barrels can go off on a hard landing. Heavy loads slow you.
- **Options worth knowing:** *Feel tuning* (all the headset numbers on one page), *Hold before it
  locks* (a short delay so you see amber before green), *Flight path* Steer or Arc (a lob, with
  an Arc height slider), *Duck under doorways*, *Voxel targets flash instead*.
- Stands down on a hand holding a melee weapon, the shield or the Force hand. An optional button
  fallback is under Customize Controls → Distance Grab.

### LaserSight
- **On as soon as you hold a gun**, in either hand, on every weapon from any mod. Melee weapons
  and off-hand utilities don't get one. Toggle each hand under Customize Controls → Laser Sight.
- **Looks:** any colour by picker, per hand and per weapon slot, beam and dot separately; colour
  cycling; beam width, taper, fade, length and glow; dot size and glow (bloom, real light or
  both); IR mode, visible only with the light-amp goggles.
- **Cues:** on a live enemy the dot pulses and can tighten; a lined-up headshot can change colour.
- **Learned from each gun** (after its first shot): a **spread ring** at the dot showing where its
  shots land, and for a weapon that throws gravity grenades a **grenade arc** ending where the
  grenade will land.
- **Range readout:** distance by the gun or at the dot, in metres, feet or map units (Laser
  Sight → Range Readout; off by default).

### ShieldSaw
- **Draw / stow:** reach to your off shoulder and press **Use**; press Use there again to put it
  back.
- **Block:** shots that cross the shield's face are stopped or turned back (back at the shooter,
  where you look, or off the face); fireballs are batted away before they reach you; blocked
  melee staggers. Meet a shot with a moving shield for a **perfect block**.
- **Bash:** shove the shield into an enemy.
- **Rev and throw:** hold **either off-hand button** to rev the saw and ring targets as you sweep;
  release while snapping your arm forward to throw. It visits the ringed targets in order and
  comes back; press again while it flies to call it back.
- Shield size, fit and placement are under *Shield Fit*; everything else under *Tuning* and
  *Advanced*.

### QuestSaber
- **The saber** is in weapon slot 1. Swing to cut; the blade blocks and deflects shots, and two
  blades clash and lock. It can be thrown (it comes back, or drops until you call it).
- **The off hand** holds a second saber by default (*dual*), and the Force: push, pull, grip and
  jump, by gesture.
- **Keys** (Customize Controls → Ultra Badass QuestSaber): blade on/off, second blade, training
  remote.
- A deep options menu covers the look, the beam, swing and trail, contact and blocking,
  deflecting, throwing, the Force, sound and feel, and the training remote.

### TacticalRig
- **Six regions on your body**, one weapon class each: two hips (slot 2), chest (slot 3),
  chest or small of the back (slot 4, menu), left shoulder (slots 5-6), right shoulder (7 and up).
- **Holster:** bring the gun into its region and grip (or press Use). **Draw:** reach in
  with an empty hand and grip or Use; with several weapons there a small radial opens
  round your hand: move toward one and let go.
- The regions stay on your body when you look around; turns carry them. A ring shows a
  region when your hand is near; the weapon last put there shows as its pickup.
- **Fit it to you:** *Measure my height* scales the rig to you; *Move the regions with your
  hands* lets you grip a ring and carry it where your hand naturally goes.
- **Doors:** hand flat on a door, take hold (grip, Use or palm out) and lift. Let go
  past 40% open and it finishes by itself; before that it drops shut. Locked doors need
  their key.
- **Ermac's cigarette** (off by default): a pocket on your left chest. Take one, hold it
  at your mouth to light it (or light it with Ermac's Zippo in your other hand, an
  option). While it burns the world slows (with SlowMo loaded); it heals you slowly
  under 35 health, and a butt flicked away draws monsters into each other.

### SlowMo
- **Start it** with the key (Customize Controls → RSQ SlowMo), by crossing your wrists
  in front of your face, with Ermac's cigarette, or (options) on reloading and with an
  adrenaline meter earned from kills, hurts and near misses.
- **The world slows, you don't:** monsters, missiles, gibs and effects near you move,
  animate and sound slower; you, your guns and the series' hand effects stay real-time.
- **Dodgeable bullets:** enemy hitscans become visible rounds on the same line, with the
  same damage. Sidestep them, block them with the shield, deflect them with the saber.
  Brutal Doom's bullets slow to the same speed. Your shots leave trails.
- Same events as RS_SlowMo (`rsm_pulse`, `rsm_toggle`, `rsm_on`, `rsm_off`), so other
  mods can ask for a moment. Stands down if Bullet Time X is loaded.

## They work together

The four mods never link against each other. Each checks for the others by name at run time, so
a missing mod is simply never found:

- The **grab stands down on a hand holding a melee weapon**, the shield or the Force hand, since
  a swing is full of the grab's palm-out flick. A **QuestSaber hilt with its blade switched off can
  grab**: the saber reports this through its `UBQS_SaberService` (`saber.lit`).
- The **grab's beam hides on a hand where the laser already draws a beam**. The laser reports this
  through `RSQLS_SightService` (`laser.beam` / `laser.active`).
- The **laser stays off** melee weapons and off-hand utilities.
- A **weapon pack can place the laser's muzzle** on each gun: provide a `Service` whose class
  name contains `LaserMuzzleService` and answer `GetString("laser.muzzle", <weapon class>, <hand>)`
  with `"forward up side"` in metres from the grip (or `""` to leave a gun alone).
- The ShieldSaw and the saber share the hands cleanly: saber in the main hand, shield in the off.
- The **grab stands down on a hand the rig is using** (reaching into a holster, holding a door,
  the cigarette or the Zippo): the rig reports this through `RSQTR_RigService` (`rig.busy`).
- The **rig leaves the off shoulder to the ShieldSaw** while the shield hangs there.
- **Ermac's cigarette asks SlowMo for slow motion** through RS_SlowMo's own `rsm_pulse` event;
  without SlowMo it is simply a cigarette.
- **SlowMo's rounds** are ordinary projectiles to the shield and the saber, so they block and
  deflect them.

Rumble on all of them goes through the one route the Quest runtime honours: amplitude-shaped,
fading, on the correct controller, and **only when something happens** (a hit, a block, a catch,
a lock). Nothing buzzes constantly.

## Repository layout

```
RSQ_UBQSeries/
├── pk3/             ready-to-load builds of all six (identical contents to the tested builds)
├── DistanceGrab/    source, docs/ (DECISIONS, HANDOFF), tools/ (asset generators, rig tests)
├── LaserSight/      source, docs/HANDOFF, tools/gen_assets.py
├── ShieldSaw/       source, README (full manual), HANDOFF
├── QuestSaber/      source, CREDITS, docs/HANDOFF_polish
├── TacticalRig/     source, README, docs/HANDOFF, tools/ (sound generator)
├── SlowMo/          source, README, docs/HANDOFF, tools/ (sound generator)
├── tools/rig17/     how the real QuestZDoom 17.3 test engine was built, and the test runners
└── build_all.sh     rebuilds every pk3 into pk3/
```

Each folder carries its **full git history** from the repo it came from (merged with
`git subtree`), so `git log -- ShieldSaw/` shows every ShieldSaw commit.

## Building

```sh
./build_all.sh
```

This needs `zip`. Each mod also keeps its original script (DistanceGrab and LaserSight use
`build.ps1` on Windows; ShieldSaw, TacticalRig and SlowMo use `build.sh`). `build_all.sh` packs
exactly the same files.

## Status (0.8a, 2026-10-26)

- **Tested on the real QuestZDoom 17.3 engine** (the qzd17.3 tag, 4.14.3), built headless
  for testing ([tools/rig17](tools/rig17/)), and on the older 4.12 build. All four load together
  in both orders, menus open, a fight runs, and the full Brutal Doom + VoxelPack load order
  pulls and catches with no script errors.
- An independent review of every change was done and its findings fixed.
- **Not yet played on a headset.** Feel numbers (rumble strength, arc height, throw thresholds)
  are first guesses.

New since 0.8a (not yet in a release):

- **TacticalRig** and **SlowMo**, both new. Tested on the real 17.3 engine with the full Brutal
  Doom + VoxelPack load order and all six packs: no script errors. An independent review of
  both was done and its findings fixed and re-tested.
- **DistanceGrab:** stands down on a hand the rig is using.

What's new in 0.8a:

- **DistanceGrab:** the hand's up/down angle was read upside down (what you could grab, the
  "not at the floor" check and the wrist flick). Fixed and re-tested. Voxel items flash instead
  of wearing the thin glow. A "Feel tuning" page collects the headset numbers.
- **LaserSight phase 3:** a spread ring and a grenade arc, both learned by watching each gun
  fire; per-weapon muzzle points through a `LaserMuzzleService`; a range readout. Also fixed:
  the beam started at the grip instead of the muzzle on every gun.

What changed, what's measured and what's still open is in each mod's handoff:
[DistanceGrab](DistanceGrab/docs/HANDOFF_2026-10-26.md) ·
[LaserSight](LaserSight/docs/HANDOFF_2026-10-26.md) ·
[ShieldSaw](ShieldSaw/HANDOFF.md) ·
[QuestSaber](QuestSaber/docs/HANDOFF_polish.md) ·
[TacticalRig](TacticalRig/docs/HANDOFF_2026-10-26.md) ·
[SlowMo](SlowMo/docs/HANDOFF_2026-10-26.md)

- **ShieldSaw and QuestSaber:** the polish pass (weapon switching with the shield drawn, rumble on
  the right controller, every setting on a menu, reset rows, many fixes from two reviews).

Known limits:

- Not yet played on a headset (above).
- LaserSight's range readout has not been seen on screen yet; the grab's doorway duck has no
  measured run.
- The spread ring and grenade arc appear only after a gun has fired once, and are re-learned
  after loading a saved game.
- In co-op, a bullet the shield turns back is credited to a helper actor, so friendly-fire rules
  don't apply to it.
- The top of the saber's haptic power slider saturates.
- SlowMo can't slow doors, lifts or engine particles on stock 17.3; its cost on the Quest CPU in
  a big Brutal Doom fight is not measured yet.

## Credits

- **QuestZDoom**: Emawind and Team Beef. The engine, and the off-hand weapon and attack-pose script
  API all six mods are built on.
- **Ermac**, co-designer of DoomVR ([Rusted Legacy](https://github.com/iAmErmac/rusted-legacy),
  DXR, RS_Main):
  - **The ShieldSaw is his.** The throwable ShieldSaw first appeared in his Rusted Legacy (MIT),
    and this mod started from it. Its shield and saw models (which he split into working parts
    himself), their textures, the hand that holds it and its sounds are all Ermac's, under his
    MIT licence. The Quest version here re-implements the behaviour as a standalone off-hand mod.
  - In the QuestSaber: the Force and impact FX sprites and the choke loop.
  - **The TacticalRig is built on his Virtual Tactical Vest idea**, and the cigarette is his
    tribute idea: its cigarette, butt and smoke models and textures come from that mod, and the
    Zippo is his voxel lighter from ZBlood-VR (his own model, per its credits).
  - Much of his work is MIT-licensed; sharing it here is the project owner's decision. See
    [ShieldSaw/README.md](ShieldSaw/README.md) and [QuestSaber/CREDITS.txt](QuestSaber/CREDITS.txt).
- **li-gnrcwpn**: the training remote's ready beep.
- The project owner's libraries: RS_CombatFX (the rig's holster, draw and foley sounds),
  RS_Ballistics (SlowMo's tracer mesh and near-miss whiz and crack), RS_SlowMo (SlowMo's design
  and events).
- **Bullet Time X** (Xortts): nothing is taken from it; SlowMo only recognises it by class name
  so the two don't compound.
- Everything else (meshes, skins, generated sounds, code) was made for these mods.
