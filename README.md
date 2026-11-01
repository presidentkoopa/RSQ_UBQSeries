# RSQ_UBQSeries — the Radiant Silvergun Quest series

**Version 1.0 — 2026-10-27; menus and names 2026-10-28; picks and QoL rounds 2026-10-31; READMEs 2026-11-01.**
Ready-to-load pk3s are in [`pk3/`](pk3/). **Every mod's own README has a "Test it" checklist** -- start there.

Standalone add-ons for **Doom VR on the Quest 17.3 PCVR or Mobile**, all in one place: a distance grab, a
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
| 🛡️ | [ShieldSaw](ShieldSaw/) | `RSQ_ShieldSaw.pk3` | A shield (stowed at the small of your back by default) that blocks, bashes and turns shots back, and doubles as a throwable saw disc that hunts the targets you ring. id Software's shield saw from *Doom: The Dark Ages*, brought to Doom VR first by **Ermac** in Rusted Legacy. |
| ⚔️ | [QuestSaber](QuestSaber/) | `RSQ_Saber.pk3` | A lightsaber (layered glowing shells that read as a solid beam), with a second one in the off hand from the start (Start With Dual Sabers). Cut, block, deflect, throw, and use the Force. |
| 🎒 | [TacticalRig](TacticalRig/) | `RSQ_TacticalRig.pk3` | Six gun holsters (hips, chest, shoulders), a holster for each saber, a grenade spot, a torso and helmet, a mirror, and Ermac's cigarette. Built on **Ermac's** Virtual Tactical Vest idea. |
| ⏱️ | [SlowMo](SlowMo/) | `RSQ_SlowMo.pk3` | The world slows, you don't. Enemy bullets become rounds you can see and dodge. |
| 🔴 | [LaserSight](LaserSight/) | `RSQ_LaserSight.pk3` | A laser from each gun's own barrel, in either hand, fading with distance, with a dot on whatever it hits. |
| 🪝 | [Grapple](Grapple/) | `RSQ_Grapple.pk3` | A grappling hook from either hand: swing across gaps, reel, climb hand over hand, slide or yank monsters to you, a whip. jpalomo's hook art and sound. |
| ❤️ | [TopHPBars](TopHPBars/) | `RSQ_HPBars.pk3` | coldcite's Top HP Bars, series version: colour-blind schemes, an overheal strip, hooked / stunned / locked / gripped markers. |
| 🏆 | [Score](Score/) | `RSQ_Score.pk3` | The arcade score: style, daring and melee bonuses, cross-mod combos, extra lives; names Champions and LegenDoom Lite kills. Built on ijon's Dakka points. |
| 👹 | [Miniboss](Miniboss/) | `RSQ_Miniboss.pk3` | A set-piece miniboss each map, fed by three thralls (boosted legendary champions with Champions + LegenDoom Lite): kill a thrall to slow time, get greedy and every monster enrages. Rebuilt from Tartlman's Minibosses!. |
| 🌳 | [GunBonsaiOffhandVR](GunBonsaiOffhandVR/) | `RSQ_GunBonsaiVR.pk3` | The arcade room's progression: Gun Bonsai for VR -- a gauge and upgrades per hand, melee and boxing-glove upgrades, Slappers Only, saber / ShieldSaw / hook upgrade paths, XP from damage or style, the screens. Needs Gun Bonsai 0.10.6 (ToxicFrog, not included) loaded just before it. |
| 🐍 | [Whip](Whip/) | `RSQ_Whip.pk3` | A simulated bullwhip from either hand (Eye of the Temple's method): it cracks from how you swing your arm, stings and stuns, throws switches, fetches pickups, locks on with the other hand and leashes monsters, catches edges to swing from, climb and mantle over. Needs no other mod. |
| 🎡 | [Wheel](Wheel/) | `RSQ_Wheel.pk3` | REMA's weapon wheel: weapon cards in a ring around your hand -- point and pull, or reach in -- with a data sheet in the middle. Drawn in the game's own status-bar stone and DoomFont. |
| 🃏 | [GunCards](GunCards/) | `RSQ_GunCards.pk3` | A small card beside each wrist with the rounds in the gun and the reserve; check your watch and the full card lies on both sides of the wrist: name, rounds, Gun Bonsai level and upgrades. Each gun its own colour. Ermac's art. Needs no other mod. |
| 🤲 | [Gestures](Gestures/) | `RSQ_Gestures.pk3` | What your hands are doing, for the other mods: hold the gun up and twist your wrist to inspect it (RSQ Gun Cards' watch card), thrust and pull, both hands down, thrown apart or palms out. Ported from RS_Gestures. Does nothing on its own. |
| ♿ | [Accessibility](Accessibility/) | `RSQ_Accessibility.pk3` | One Accessibility menu for every series mod you load: colour-blind modes and handedness. |

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
| 4 | DistanceGrab | Pull, carry, throw, doors, walk-up grip, hand swap, Headlock |
| 5 | Saber | Then check it with the rig's saber holsters |
| 6 | ShieldSaw | Then saber + shield together (saber over shield) |
| 7 | Whip | |
| 8 | Grapple | |
| 9 | SlowMo | Then the saber's / shield's / rig's slow-mo options start doing something |
| 10 | Gestures, then GunCards | GunCards' watch card comes from Gestures' wrist twist |
| 11 | Wheel | |
| 12 | HP Bars | Its frozen / held / hooked markers read the other mods |
| 13 | Score | Combos need the tools above loaded to fire |
| 14 | Miniboss | Best with Champions + LegenDoom Lite |
| 15 | Gun Bonsai VR addon | Last, right after GunBonsai-0.10.6 |

After that, the full set together.

---

## Install

1. Grab the pk3s you want from [`pk3/`](pk3/).
2. Add them to your QuestZDoom load order the way you normally load mods, **after** your weapon
   pack. The tested order is:

   ```
   doom2.wad -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded_2_0_3h -> BD22_VR-Reloaded_2.0.3ha_hotfix
             -> (optional) Champions -> LegenDoom Lite -> any of the mods, in any order
             -> GunBonsai-0.10.6.pk3 -> RSQ_GunBonsaiVR.pk3 (last; only with Gun Bonsai)
   ```

3. Settings live under **Options → Radiant Silvergun Options** (in both the simple and the full
   Options menu). That one page lists every series mod you loaded, in a fixed order whatever your
   load order, plus Accessibility; a mod you didn't load has no row, and any one mod alone still
   shows its page there.

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
   | Accessibility | **Accessibility** |

   Each page follows Brutal Doom Quest 2.0's options page: one short front page of real choices with
   named values, **preset rows** where a feel spans many numbers (*Swing Feel: Light / Standard /
   Heavy*, *Block Assist*, *Throw Feel*...; Standard is always the shipped defaults, and a row shows
   *Custom* once you change one of its numbers by hand), a sub-page only for a list of switches, and
   **Tuning and Debug** last, which holds every number and a **Reset All** row. No setting was
   removed or renamed in code, so saved settings carry over.

4. **Renamed pk3s (2026-10-28).** If you had an older build, delete these from your load order and
   use the new names: `UltraBadassQuestSaber.pk3` → `RSQ_Saber.pk3`, `UltraBadassShieldSaw.pk3` →
   `RSQ_ShieldSaw.pk3`, `RSQ_TopHPBars.pk3` → `RSQ_HPBars.pk3`,
   `Gameplay_GB_VR_Offhand_Patch.0.10.6.pk3` → `RSQ_GunBonsaiVR.pk3` (still loaded right after
   `GunBonsai-0.10.6.pk3`). Loading an old and a new copy of the same mod together is not supported.
   The per-mod entries in Options (Distance Grab, Tactical Rig, Laser Sight...) are gone: everything is
   under Radiant Silvergun Options.

## What each one does, and how to use it

Each mod's own README is the manual: every feature with its exact menu row and default, the moves in VR,
and a **Test it** checklist. Those READMEs were written from the code on 2026-11-01; the per-mod notes
that used to sit here were from 1.0 (2026-10-27) and had gone stale (four holsters where there are six),
so they were removed rather than kept wrong.

## They work together

The mods never link against each other: each looks the others up by name at run time, so any
combination loads and a missing mod is simply never found. What each mod changes when another is
loaded is in that mod's README, under **Works with**.

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
├── Whip/           a simulated bullwhip (PROJECT WHIP): source, README, HANDOFF, tools/ (whipsim.py, gen_whip.py, rigtest/)
├── Wheel/           REMA's weapon wheel (RS_WeaponSelectionSystem, ring only): source, README, tools/ (asset generator, rig runner)
├── GunCards/        the cards on the guns (Ermac's art): source, README, CREDITS, tools/ (voxel generators, card_art/)
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

## Status (menus and names, 2026-10-28)

- **Radiant Silvergun Options:** one parent page under Options for the whole series (how it stays
  one page in any load order: [tools/rsmenu](tools/rsmenu/rsmenu_template.zs)). Every mod's own
  Options entry is gone.
- **Every options page rebuilt after Brutal Doom Quest 2.0's:** short front pages (7-20 rows, at
  most one slider), named preset rows, switch lists one page down, every number on Tuning and
  Debug. Every cvar keeps a row ([tools/rsmenu/menutool.py](tools/rsmenu/menutool.py) checks it).
- **Names:** the series is *Radiant Silvergun Quest*; no "Badass" anywhere a player sees it. pk3s,
  menu titles, Customize Controls sections and pickup names say RSQ (renames under Install).
- Tested on the QZD 17.3 rig (each mod alone, all together in two orders, the full Brutal Doom
  order and vanilla). **Not yet seen on a headset.**

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
