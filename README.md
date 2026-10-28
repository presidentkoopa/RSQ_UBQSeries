# RSQ_UBQSeries — the Ultra Badass Quest series

**Version 1.0 — 2026-10-27.** Ready-to-load pk3s are in [`pk3/`](pk3/).

Standalone add-ons for **Doom VR on the Quest**, all in one place: a distance grab, a
shield-saw, a lightsaber, a tactical rig, slow motion, a laser sight, a grappling hook, HP bars and one
shared Accessibility menu.

**Each one works alone; together they make one arcade game.** They talk through services, never hard
links, so any combination loads. Gun Bonsai Offhand VR (progression: everything you use levels up in your
hands) and RSQ Score (style and cross-mod combos) are the arcade room on top, and neither needs Brutal
Doom: they read what monsters do, not what they're called, so the same arcade runs on vanilla Doom,
Golden Souls, Ashes or any monster set. Each one is its own pk3. Load
any of them, in any order, alone or all together.

They target **stock QuestZDoom 17.3** (TeamBeef / Emawind). There are no engine changes. Everything
is ZScript and data lumps.

| | Mod | pk3 | What it is |
|---|---|---|---|
| ✋ | [DistanceGrab](DistanceGrab/) | `RSQ_DistanceGrab.pk3` | Turn your palm out, flick, and pull items, guns, barrels and bodies to your hand. Then carry them, throw them, and hit things with them. Lift doors open by hand. |
| 🛡️ | [ShieldSaw](ShieldSaw/) | `UltraBadassShieldSaw.pk3` | A shield on your off shoulder that blocks, bashes and turns shots back, and doubles as a throwable saw disc that hunts the targets you ring. id Software's shield saw from *Doom: The Dark Ages*, brought to Doom VR first by **Ermac** in Rusted Legacy. |
| ⚔️ | [QuestSaber](QuestSaber/) | `UltraBadassQuestSaber.pk3` | A volumetric lightsaber, with a second one for the off hand on the Dual key. Cut, block, deflect, throw, and use the Force. |
| 🎒 | [TacticalRig](TacticalRig/) | `RSQ_TacticalRig.pk3` | Guns holstered on your hips and shoulders, spots for the saber, a torso and helmet, a mirror, and Ermac's cigarette. Built on **Ermac's** Virtual Tactical Vest idea. |
| ⏱️ | [SlowMo](SlowMo/) | `RSQ_SlowMo.pk3` | The world slows, you don't. Enemy bullets become rounds you can see and dodge. |
| 🔴 | [LaserSight](LaserSight/) | `RSQ_LaserSight.pk3` | A laser from each gun's own barrel, in either hand, fading with distance, with a dot on whatever it hits. |
| 🪝 | [Grapple](Grapple/) | `RSQ_Grapple.pk3` | A grappling hook from either hand: swing across gaps, reel, climb hand over hand, slide or yank monsters to you, a whip. jpalomo's hook art and sound. |
| ❤️ | [TopHPBars](TopHPBars/) | `RSQ_TopHPBars.pk3` | coldcite's Top HP Bars, series version: colour-blind schemes, an overheal strip, hooked / stunned / locked / gripped markers. |
| 🏆 | [Score](Score/) | `RSQ_Score.pk3` | The arcade score: style, daring and melee bonuses, cross-mod combos, extra lives; names Champions and LegenDoom Lite kills. Built on ijon's Dakka points. |
| 👹 | [Miniboss](Miniboss/) | `RSQ_Miniboss.pk3` | A set-piece miniboss each map, fed by three thralls (boosted legendary champions with Champions + LegenDoom Lite): kill a thrall to slow time, get greedy and every monster enrages. Rebuilt from Tartlman's Minibosses!. |
| 🌳 | [GunBonsaiOffhandVR](GunBonsaiOffhandVR/) | `Gameplay_GB_VR_Offhand_Patch.0.10.6.pk3` | The arcade room's progression: Gun Bonsai for VR -- a gauge and upgrades per hand, melee and boxing-glove upgrades, Slappers Only, saber / ShieldSaw / hook upgrade paths, XP from damage or style, the screens. Needs Gun Bonsai 0.10.6 (ToxicFrog, not included) loaded just before it. |
| ♿ | [Accessibility](Accessibility/) | `RSQ_Accessibility.pk3` | One Accessibility menu for every series mod you load: colour-blind modes and handedness. |

---

## Install

1. Grab the pk3s you want from [`pk3/`](pk3/).
2. Add them to your QuestZDoom load order the way you normally load mods, **after** your weapon
   pack. The tested order is:

   ```
   doom2.wad -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded (1.99x-lb-r7-saveload or later)
             -> (optional) Champions -> LegenDoom Lite -> any of the mods, in any order
             -> GunBonsai-0.10.6.pk3 -> Gameplay_GB_VR_Offhand_Patch.0.10.6.pk3 (last; only with Gun Bonsai)
   ```

3. Settings live under **Options** in the game:

   | Mod | Options menu entry |
   |---|---|
   | DistanceGrab | **Distance Grab** |
   | ShieldSaw | **Ultra Badass ShieldSaw** |
   | QuestSaber | **Ultra Badass QuestSaber** |
   | TacticalRig | **Tactical Rig** |
   | SlowMo | **RSQ SlowMo** |
   | LaserSight | **Laser Sight** |
   | Grapple | **Grapple** |
   | TopHPBars | **RSQ HP Bars** |
   | Score | **RSQ Score** |
   | Miniboss | **RSQ Miniboss** |
   | GunBonsaiOffhandVR | **Gun Bonsai** (its own menu) and **Gun Bonsai VR** |
   | Accessibility | **Accessibility** |

   Every menu ends with **Tuning and Debug**, which holds a **Reset All** row.

## What each one does, and how to use it

### DistanceGrab
- **Reach:** turn your palm out (roll your hand so the palm faces away). Whatever you could take
  glows **amber**; once it's yours it glows **green**. A beam, a dot and the reach cone show where
  you're pointing.
- **Pull:** flick your wrist **up**. The thing flies to your hand: heavy things slower and lazier,
  light ones snappier. Keep your hand open and you catch it.
- **Carry and throw:** roll your palm back to let go, or snap your arm and let go to throw.
  Thrown things hit with their weight; barrels can go off on a hard landing. Heavy loads slow you.
- **Doors:** put a hand flat on a door, take hold (the grab's grip, Use or palm out) and lift.
  Let go past 40% open and it finishes by itself; before that it drops shut. Locked doors need
  their key. The door's own sound plays as fast as you lift it.
- **Options worth knowing:** *Flight Path* Steer or Arc (a lob, with *Arc Height*), *Lock Delay*
  (Gesture: amber before green), *Duck Under Doors* (Pull), *Voxel Flash* (Beam and Glow).
- Stands down on a hand holding a melee weapon, the shield or the Force hand. An optional button
  fallback is under Customize Controls → Distance Grab.

### ShieldSaw
- **Draw / stow:** reach to your off shoulder and press **Use**; press Use there again to put it
  back. Or bind **Draw** and turn *Draw With Use* off: the key alone.
- **Block:** shots that cross the shield's face are stopped or turned back (back at the shooter,
  where you look, or off the face); fireballs are batted away before they reach you; blocked
  melee staggers. Meet a shot with a moving shield for a **perfect block**.
- **Bash:** shove the shield into an enemy.
- **Rev:** hold the **off trigger**.
- **Lock on:** hold **Use** (away from the shoulder) and sweep the shield over enemies, one ring
  each. Or bind the off grip or any key to *ShieldSaw: lock on (hold)* and pick it in *Lock On
  With*. Rings stay 5 s after you let go.
- **Throw:** let go of the trigger while snapping your arm forward. It visits the ringed targets in
  order and comes back; press the trigger again while it flies to call it back.
- **BD22 Monsters** (option): for Brutal Doom's tougher monsters, it slices through up to
  250 health and grinds up to 1200.
- **Options:** the everyday switches on the front page (*Double Block Radius*, *On Manual Store*,
  turned shots, perfect block, the bash...); *Shield Fit*, *Throw and Disc*, *Lock-On*, *Block and
  Bash* and *Mount Position* one page down. With Gun Bonsai's VR patch it levels up: Broadening
  grows the plate, Lockstep adds locks, and more ([ShieldSaw/README.md](ShieldSaw/README.md)).

### QuestSaber
- **The saber** is in weapon slot 1. Swing to cut; the blade blocks and deflects shots, and two
  blades clash and lock. Against Brutal Doom it blocks on contact, as the ShieldSaw does: claws
  and bites (Brutal Doom's invisible short-range missiles) are stopped and stagger the monster,
  and its tracer bullets are turned back (*Blade Block Reach* sets how wide the blade blocks). It can be thrown (it comes back, or drops until you call it).
- **The second saber:** the Dual key (Brutal Doom's own, or the saber's) brings it into the off hand
  and puts it away; *Second Saber* can make it always out, or off.
- **The Force** in the off hand: push, pull, grip and jump, by gesture.
- **Keys** (Customize Controls → Ultra Badass QuestSaber): blade on/off, second blade, training
  remote.
- **Options:** the everyday switches on one page; Look, Swing and Cuts, Block and Deflect,
  Throwing, The Force, Sound and Haptics, Training Remote, Controls and Presets one page down.

### TacticalRig
- **Four gun holsters** (both hips, both shoulders) and, with the QuestSaber, **two saber spots**
  below the hips. A holster holds exactly the gun you put there: grip (or Use) with a gun in your
  hand to put it in (a full one swaps), grip with the hand empty to draw.
- **Each hand holsters and draws its own gun**; the engine's *switchhand* moves guns between
  hands. Dual is left to its own key.
- The holsters stay on your body when you look around; turns carry them. A sphere shows a holster
  when your hand is near; the gun stored there shows as its pickup model.
- **Seated:** one switch for playing seated. The rig hangs from your seated head height instead
  of the standing view height, and catches up if you stand.
- **Fit it to you:** *Measure My Height*, *Move Holsters by Hand*, four *Holster Profiles*, and a
  **mirror** that shows you wearing it, front and back.
- **A torso** (optional): the Doom marine's (default) or Quake's Grunt, green or blue with your
  armour, red at low health; with the marine, a **helmet** only mirrors show. It fades as you
  look down.
- **Mirror body:** with the torso on, map mirrors also show your held gun and both hands (Brutal
  Doom Quest's own gun models, firing frames included), and hide the sprite marine so you see one
  body. Flat sprite guns get no mirror copy.
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
- Other mods can read it through `RSQSM_Service` (`active`, `scale`, `adrenaline`,
  `adrenaline.add`; see [SlowMo/README.md](SlowMo/README.md)).
- **Dodgeable bullets:** enemy hitscans become visible rounds on the same line, with the
  same damage. Sidestep them, block them with the shield, deflect them with the saber.
  Brutal Doom's bullets slow to the same speed. Your shots leave trails.
- Same events as RS_SlowMo (`rsm_pulse`, `rsm_toggle`, `rsm_on`, `rsm_off`), so other
  mods can ask for a moment. Stands down if Bullet Time X is loaded.

## They work together

The mods never link against each other. Each checks for the others by name at run time, so
a missing mod is simply never found:

- The **grab stands down on a hand holding a melee weapon**, the shield or the Force hand, since
  a swing is full of the grab's palm-out flick. A **QuestSaber hilt with its blade switched off can
  grab**: the saber reports this through its `UBQS_SaberService` (`saber.lit`).
- The ShieldSaw and the saber share the hands cleanly: saber in the main hand, shield in the off.
- The **grab stands down on a hand the rig is using** (in a holster, holding the cigarette or the
  Zippo): the rig reports this through `RSQTR_RigService` (`rig.busy`), and asks the grab's
  `RSQDG_DoorService` whether a hand holds a door.
- The **rig leaves the off shoulder to the ShieldSaw** while the shield hangs there, unless the
  ShieldSaw's *Draw With Use* is off (its Draw key only): then the rig keeps it.
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
├── pk3/             ready-to-load builds of every mod (identical contents to the tested builds)
├── DistanceGrab/    source, CREDITS, docs/ (DECISIONS, HANDOFF), tools/ (asset generators, rig tests)
├── ShieldSaw/       source, README (full manual), HANDOFF
├── QuestSaber/      source, CREDITS, docs/HANDOFF_polish
├── TacticalRig/     source, README, CREDITS, docs/HANDOFF, tools/ (sound generator, pickup measurer)
├── SlowMo/          source, README, CREDITS, docs/HANDOFF, tools/ (sound generator)
├── LaserSight/      source, docs/HANDOFF, tools/ (muzzle measurer, beam generator)
├── Grapple/         source, README, ROADMAP (Hook 1.0), HANDOFF, jp_original/ (jpalomo's hook, source material)
├── TopHPBars/       pk3/ (the mod), original_1.04/ (coldcite's), tools/ (art generator, colour-vision check)
├── Accessibility/   source, README, tools/ (colour-vision simulation, palette generator)
├── Miniboss/        source, README (design as built), CREDITS (Tartlman), original/ (Minibosses! v0.1.1)
├── GunBonsaiOffhandVR/  the Gun Bonsai VR patch: source, README, COPYING (Gun Bonsai's MIT notice), rsq/ (our code)
├── Score/           source, README (the arcade layer, combo table), CREDITS (Dakka)
├── tools/rig17/     how the real QuestZDoom 17.3 test engine was built, and the test runners
└── build_all.sh     rebuilds every pk3 into pk3/
```

Each folder carries its **full git history** from the repo it came from (merged with
`git subtree`), so `git log -- ShieldSaw/` shows every ShieldSaw commit.

## Building

```sh
./build_all.sh
```

This needs `zip`. Each mod also keeps its original script (DistanceGrab uses
`build.ps1` on Windows; ShieldSaw, TacticalRig and SlowMo use `build.sh`). `build_all.sh` packs
exactly the same files.

### LaserSight
- **Rebuilt (2026-10-27).** Each gun's barrel and muzzle are measured from Brutal Doom Quest's own
  gun models, for every resting pose and every firing frame, so the beam leaves the barrel and stays
  on it in full-auto. A gun in each hand gets its own beam.
- The beam fades out with distance; the **dot** stays on whatever it hits.
- Melee weapons get nothing. Guns with no model to measure (sprite guns) get the dot only.
- The beam hides during reloads and inspections (frames that move the gun more than 6 cm).
- DistanceGrab's beam makes way for it (*Yield to Laser Sight*).

## Status (1.0, 2026-10-27)

New in 1.0 (since 0.9, same day):

- **Grapple** (hook, rope, swing, climb, Yank, whip), **TopHPBars**, **Accessibility** (colour-blind,
  handedness, photosensitivity, one-handed, comfort vignette, cue/text size, sound cues, hold to toggle,
  Simple/Full menus), **Score** in the repo, and **Miniboss** (Tartlman's Minibosses!, rebuilt).
- **Score:** hook combos and the general combo system (order matters, 3 s window, named combos), Champions
  and LegenDoom Lite rows, a living "Score:" label.
- **Gun Bonsai patch:** hook upgrades, the screens on with Doom's own fonts, XP Source (Damage / Style /
  Both), an optional ShieldSaw gauge.
- **Champions + LegenDoom Lite** compatibility across the suite; two independent reviews, their findings
  fixed. Tested on the full order (doom2, brutal22test6, BD_VoxelPack, BD22 VR-Reloaded r7, Champions,
  LegenDoom Lite, every mod, Gun Bonsai + patch) and vanilla: save, load twice, map change, no script
  errors besides BD_VoxelPack's voxeldef lines. **Not yet played on a headset.**

## Status (0.9, 2026-10-27)

New in 0.9:

- **LaserSight** is back, rebuilt: beam from each gun's barrel in either hand, fading with
  distance, dot on the target. Shown leaving the muzzle on 12 Brutal Doom guns in rig frames.
- **QuestSaber blocks Brutal Doom's attacks:** measured over 30 s against a real BD imp, 0 of 132
  claws landed with the blade in the way (93 hits, 1860 damage before); rifle zombie bullets 22 of
  364 (9 with two sabers).
- **TacticalRig:** Seated mode and the mirror body (above).
- Tested together on the full load order (doom2, brutal22test6, BD_VoxelPack, BD22 VR-Reloaded
  1.99x-lb-r7-saveload, all six plus Gun Bonsai and the VR patch): play, save, load twice, next
  map, with no script errors besides BD_VoxelPack's own voxeldef lines. **Not yet played on a
  headset.**

## Status (0.8a, 2026-10-26)

- **Tested on the real QuestZDoom 17.3 engine** (the qzd17.3 tag, 4.14.3), built headless
  for testing ([tools/rig17](tools/rig17/)), and on the older 4.12 build. The mods of that release load together
  in both orders, menus open, a fight runs, and the full Brutal Doom + VoxelPack load order
  pulls and catches with no script errors.
- An independent review of every change was done and its findings fixed.
- **Not yet played on a headset.** Feel numbers (rumble strength, arc height, throw thresholds)
  are first guesses.

New since 0.8a (not yet in a release):

- **TacticalRig** and **SlowMo**, both new. Tested on the real 17.3 engine with the full Brutal
  Doom + VoxelPack load order and the whole series: no script errors. An independent review of
  both was done and its findings fixed and re-tested.
- **DistanceGrab:** stands down on a hand the rig is using; doors lifted by hand moved here from
  the rig.
- **Every options menu** rebuilt in BD22 VR Weapons' style: short labels, no notes, niche settings
  one page down, Tuning and Debug last.
- **CREDITS.txt** in every pk3 (the ShieldSaw's credits are in its README).

What's new in 0.8a:

- **DistanceGrab:** the hand's up/down angle was read upside down (what you could grab, the
  "not at the floor" check and the wrist flick). Fixed and re-tested. Voxel items flash instead
  of wearing the thin glow. (0.8a had a "Feel tuning" page; its rows now live on their own pages.)
- **LaserSight** was in 0.8a; it is out of the build now and being rebuilt (above).

What changed, what's measured and what's still open is in each mod's handoff:
[DistanceGrab](DistanceGrab/docs/HANDOFF_2026-10-26.md) ·
[ShieldSaw](ShieldSaw/HANDOFF.md) ·
[QuestSaber](QuestSaber/docs/HANDOFF_polish.md) ·
[TacticalRig](TacticalRig/docs/HANDOFF_2026-10-26.md) ·
[SlowMo](SlowMo/docs/HANDOFF_2026-10-26.md) ·
[LaserSight](LaserSight/docs/HANDOFF_2026-10-26.md)

- **ShieldSaw and QuestSaber:** the polish pass (weapon switching with the shield drawn, rumble on
  the right controller, every setting on a menu, reset rows, many fixes from two reviews).

Known limits:

- Not yet played on a headset (above).
- The grab's doorway duck has no measured run.
- In co-op, a bullet the shield turns back is fired by a helper actor, so friendly-fire rules
  don't see a player source (the kill itself is credited to the player).
- The top of the saber's haptic power slider saturates.
- SlowMo can't slow doors, lifts or engine particles on stock 17.3; its cost on the Quest CPU in
  a big Brutal Doom fight is not measured yet.

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
- Everything else (meshes, skins, generated sounds, code) was made for these mods.
