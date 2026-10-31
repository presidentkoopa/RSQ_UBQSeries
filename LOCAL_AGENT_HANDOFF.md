# Local agent handoff: RSQ_UBQSeries on the owner's PC

Written 2026-10-31 by the cloud lane, for a coding agent running on the owner's Windows PC (with a shell, the real
QuestZDoom and his headset). Read all of it before touching anything.

## 0. What this repo is

RSQ_UBQSeries is the owner's (presidentkoopa) series of VR mods for **stock QuestZDoom 17.3**, one folder per mod.
The built pk3s live in `pk3/` and are committed. GitHub: https://github.com/presidentkoopa/RSQ_UBQSeries (branch
`main`, the only branch). His local clone is `E:\DOOMWork\RSQ_UBQSeries`.

**First step, always:** `git pull` in `E:\DOOMWork\RSQ_UBQSeries`. The cloud lane is still merging work (section 4).

## 1. The owner's rules (non-negotiable)

- **No engine changes.** Stock QuestZDoom 17.3; everything is ZScript, DECORATE, MODELDEF and data.
- **Load order he plays (PCVR, SteamVR):** doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 ->
  BD22_VR-Reloaded_2_0_3h.pk3 -> BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> the RSQ pk3s.
  Launch args he uses: `+vr_mode 10 +vid_preferbackend 0`.
- **Zero script errors from our packs** in that load order before anything is called done. The 4
  "No sprites specified for voxel" errors from BD_VoxelPack's voxeldef are the parent's own; ignore them.
- **Shown working only.** Working means seen in game (frames, the headset) or a log of the behaviour. "It compiles"
  is not working. Say what you could not test.
- **Look at it before claiming anything visual.**
- **No hands drawn on props and no hand fitting** (saber, whip, cigarette, lighter: hands were removed on his order).
  Brutal Doom owns the hand poses.
- **No procedural / synthesized sounds.** Stock Doom or Brutal Doom sounds only.
- **Never modify other people's mods**: ToxicFrog's Gun Bonsai (our addon is `GunBonsaiOffhandVR/` only), Lewisk3's
  minimap (no minimap work at all).
- **No new mods.** Features go inside the existing ones.
- Picks marked **Yes** are ON by default; **Option** picks are OFF by default, with a menu row and in that mod's
  "Reset All" list. The owner's picks are in `PICKS_2026-10-31.md`.
- Don't send him files. Built pk3s go in `pk3/` and are pushed to GitHub.
- No console steps for the owner. If something needs a console command, it's a menu row instead.
- Keep questions short and give him answers to pick from.

## 2. Building (Windows)

```
cd E:\DOOMWork\RSQ_UBQSeries
python tools\build_all.py                 # every mod into pk3\
python tools\build_all.py Wheel GunCards  # just those folders
```

`tools/build_all.py` packs exactly what `build_all.sh` packs (checked file-for-file on 2026-10-31). Don't use
PowerShell's Compress-Archive: older versions write backslashes into the zip, which the engine can't read.

**Commit only the pk3s of the mods you changed.** Rebuilding everything rewrites every pk3's bytes; restore the
others with `git checkout -- pk3/<name>.pk3` before committing.

Commit messages end with two lines:
```
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01Me4ZUnje3xdgvFFi6vj9Uh
```
(use your own session link if your lane has one). Push to `main`.

## 3. Testing on the PC

- Run the owner's QuestZDoom with the load order above plus the RSQ pk3s you're testing, `+logfile rsq.log`, and
  each mod's debug cvar where it has one (`rsqdg_debug 1`, `ssq_debug 1`, `rsqls_debug 1`, `rsqtr_debug_throw 1`,
  `ubqs_diag 3` for saber parry decisions).
- Search the log for `Script error` from our pk3s before anything else.
- The cloud lane tested everything on a **simulated** OpenXR headset (scripted hand poses, software renderer, no
  sound, no haptics). Real-headset checks are worth more than anything the cloud could do. Report results as
  "headset-confirmed" only when the owner (or you, in his headset) actually saw it.
- Most mods have test probes under `<Mod>/tools/rigtest/` (QuestSaber's under `QuestSaber/docs/`). They're
  test-only pk3 sources and never ship. They were written for the Linux rig's console poses (`qz_rhand` etc.),
  which don't exist on the real engine, but their logging code is reusable.

## 4. Work the cloud lane still has running (don't touch these folders until it's merged)

Four cloud agents are building the owner's "QoL round" picks (PICKS_2026-10-31.md, bottom table):

| Lane | Folders |
|---|---|
| SlowMo + Grapple | `SlowMo/`, `Grapple/` |
| HP Bars + Wheel | `TopHPBars/`, `Wheel/` |
| Gestures + GunCards | `Gestures/`, `GunCards/` |
| Accessibility | `Accessibility/` |

`git log` on main shows each one as a "Merge ..." commit when it lands. Pull before you start, and again before you
touch any of those folders.

## 5. Task A: wire Steady Hands into the mods that aim (do after the Accessibility lane is merged)

**What the owner asked:** "steadier hands would be great in general" (pick AC6, ON by default).

**What the Accessibility lane is building:** a shared, smoothed hand pose (main and off: position and direction)
from RSQ_Accessibility, using a tremor filter (e.g. a 1-euro filter) that smooths jitter but keeps up with a fast
swing within a tic or two. **Read `Accessibility/` after the merge for the exact service name, request strings and
cvar** (its README and the merge commit message say them). It also lists which mods should read it.

**Wire it into these, for POINTING and AIMING only (never for hits, swings or throws, which need the raw hand):**
1. `Wheel/`: pointing at cards (the ring's hand ray).
2. `Grapple/`: where the hook is aimed when fired (`zscript/rsqgr/`, the fire direction).
3. `LaserSight/`: the dot only (`zscript/rsqls/sight.zs` DrawHand: muzzle and dir). The beam is a HUD model glued
   to the gun and can't be smoothed.
4. `DistanceGrab/`: the aim cone that picks what to lock (`zscript/rsqdg/aim.zs`, `cone.zs`). Not the throw
   velocity (`aim.zs PalmVelocity`): throws must stay raw.
5. Catching: `SlowMo/`'s bullet catch (the catch test only, not the flick that throws back).

**How, in each mod:**
- Ask RSQ_Accessibility through its service (`ServiceIterator.Find(...)`), never a hard class reference, so the mod
  still loads and works without RSQ_Accessibility. With no answer, use the raw hand exactly as today.
- Respect the Steady Hands setting (off = raw).
- Netplay: the series computes hand-driven decisions on the console player's machine and sends network events.
  Keep that pattern; don't read another player's smoothed pose locally.

**How to check (in the headset):** point at a Wheel card and hold still: the highlight shouldn't flicker between
neighbours. Laser dot on a far wall: visibly steadier. A fast swing still lands where you swung (no lag you can feel).
DistanceGrab lock: holding on a far item keeps the lock instead of chattering. Then Steady Hands off: everything
behaves exactly as before.

## 6. Task B: headset pass over everything built on 2026-10-31

Everything below ran on the simulated rig only. Check each in the headset and write the result into that mod's
HANDOFF/DECISIONS doc ("headset-confirmed" or what went wrong). Fix what's wrong, rebuild, push.

**DistanceGrab** (`docs/DECISIONS.md` D36-D38)
- Throwing lets go on a forward swing only (a wind-up never throws). Barrels go off when thrown hard (>= 4 m/s).
- Aim assist bends a throw onto a monster within 12 degrees.
- Two hands on a held thing make it lighter; a held corpse/barrel blocks fireballs (corpse grabbing is now OFF by default).
- Swinging a held barrel into a monster hurts it; palm turned out on a switch flips it.
- Headlock: throw the held monster (faster toss, same damage as before); Human Shield option.
- Sounds: whoosh on throws, thud on catch/landing (stock Doom sounds) -- **never heard yet**.
- Open: a 6.6 m/s headlock toss was never seen hitting anything on the rig (it flew over the target).

**LaserSight**
- The dot lands on the bullets (BD 2.0 fires 3.85 deg left / 3.36 deg up of the controller; the dot follows that).
- Shotgun: the dot no longer jumps short after the first blast. Grenade launcher: the arc lands where grenades land.
- Off when pointed down past 55 deg or while switching. The dot wobbles on liquids, glints on metal. The dot sits on an
  angled monster's body.

**SlowMo**
- Smooth walkers in slow-mo; lean dodge (lean your head ~30 cm out of a round's path); bullet catch option (grip
  near a slowed round, flick to throw back, open to drop); colour drain option (**check BOTH eyes**).
- Sweep fixes: cigarette slow-mo lasts its 6 s; your own BD tracers no longer crawl.

**Saber**: swept-arc cuts; parry/clash double knock in the hand; stab = one target, 1.5x, no shove; parry now counts
against real monster fire (it never did before); hit-stop and parry slow-mo options. Braced off-hand saber stays drawn
(SteamVR two-hand hold).

**Whip**: crack damage by speed; lasso by closing the off hand on the thong (works without the SteamVR latch);
flail a leashed monster into others; mark lock; yank-grace option; cracked rockets option; crack fireballs option.

**ShieldSaw**: bash shows the owner's five-frame burst at plate height (never on the floor); a bash never triggers
BD's stealth-kill cutscene; wall slam; saber-over-shield widens the block; perfect block = double knock; hit-stop and
perfect-block slow-mo options.

**Tactical Rig**: gun throw never fires while walking or turning; a thrown gun hurts; keys-to-doors option; holster
ammo count option (small green digits). **Not done:** holstered guns may look squashed (MDL_CORRECTPIXELSTRETCH);
it was backed out because it couldn't be checked against a holstered gun on the rig. Check it in the mirror
(`rsqtr_mirror 2`) with and without the flag before deciding.

**Grapple**: a press after a menu fires from the hand; momentum kept only while the rope moves you; two hands on the
rope; bite thump; lasso and split-pull options.

**Wheel**: ring clicks with quake rumble at 0; its own world freeze without SlowMo is now an OPTION (off); the ring
slows time again while slow-mo is easing out.

**HP Bars**: frozen (snowflake) and held (padlock) markers; Aimed Only option.

**Gestures**: shared "braced" answer; punch answer (jab/hook/uppercut).

**GunCards**: On Reload and Tilt to Your Eyes options; the watch-card flash and world Left/Right fixed.

**Accessibility**: Rumble Backup, Two-Hand Brace and Brace Cue options; Hold to Toggle after a load fixed.

**Haptics**: nothing about rumble could be felt on the rig. Every "double knock", "thump" and "tick" needs a hand on a
controller.

## 7. Where things are written down

- `PICKS_2026-10-31.md`: every pick the owner made today, with his notes.
- Per mod: `docs/DECISIONS.md` / `HANDOFF*.md` / `README.md`.
- The Quest engine teardown (what the engine allows, cited to source): https://github.com/presidentkoopa (repo
  `RSQ_QuestEngineSurvey`, local `E:\DOOMWork\RSQ_QuestEngineSurvey`). Read `surveys/00_CAPABILITIES.md` §0 and §7
  (the gotchas) before writing engine-facing code.
- ZScript traps this repo hit: identifiers are case-insensitive (a const `WRAP` clashes with `Wrap()`, a function
  `Is()` with the `is` keyword); `auto` is reserved; UI scope can't call play functions; a static helper calling
  `AttackDir` must be in a `play` class; 3-element vectors through `out` parameters crash the VM.
