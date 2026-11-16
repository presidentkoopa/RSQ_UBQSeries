# Bugfix review, 2026-11-16: every code change from the README session, for the bugfix lane to check

The README session (the owner with Claude, 2026-11-16 09:17 to 11:xx) read each mod's code to rewrite its README. Two
agents read RSQ Tactical Rig and RSQ Wheel in full and listed what looked like defects. The owner went through them
one by one and said fix, log or remove. This file lists **every code change that session made**, so the bugfix lane can
check each one.

**None of it has been run.** Not load-checked, not on the rig, not in the headset. No pk3 was rebuilt. Every item below
is **code only, not shown** until someone shows it.

A default that changed only reaches fresh settings and Reset All: a saved config keeps the value it has.

## A. Defaults changed at the owner's word

| # | Mod | Setting | Was | Now | File | Owner |
|---|---|---|---|---|---|---|
| A1 | Grenade | Replace Brutal Doom's Grenade (`rsqgn_replace_bd`) | false | **true** | `Grenade/CVARINFO.txt` | "Make it on" |
| A2 | Melee | Two-Handed Butt Strike (`rsqml_butt`) | 0 | **1** | `Melee/CVARINFO.txt` | "ideally it is on by default", "Yes, default on" |
| A3 | Tactical Rig | Torso (`rsqtr_vest`) | false | **true** | `TacticalRig/CVARINFO.txt` | "Torso on" |
| A4 | Tactical Rig | Cigarettes (`rsqtr_cig`) | false | **true** | `TacticalRig/CVARINFO.txt` | "Cigarettes on" |
| A5 | Wheel | Freeze Time While Open (`wr_freeze`) | false | **true** | `Wheel/CVARINFO.txt` | "Freeze by default" |

A1 and A2 are on main since commit 64da223d0. A3 to A5 and everything in B and C came after it.

**To check:**
- A1: with BD22 VR Reloaded loaded, a new game hands out RSQ Grenade's grenades and BD22 VR's own grenade stands down
  (it reads the same cvar by name). The Tactical Rig's buckle gives RSQ Grenade's.
- A2: see B1, which is what makes it hold.
- A3: the torso draws from the first map; nothing else assumes it is off (the mirror, the fade looking down).
- A4: a new game has a pack of three; the pocket's ring and the ritual work with nothing else changed.
- A5: opening the ring stops the world with and without RSQ SlowMo, and closing it starts it again. With it on, Slow
  Time While Open no longer matters (the code asks SlowMo only when Freeze is off: `zscript.zs` near 4689).

## B. Code changed

| # | Mod | What was wrong | What changed | Where | Risk |
|---|---|---|---|---|---|
| B1 | Melee | On the first map with BD22 VR Reloaded, `Migrate()` copied that pack's `rsq_butt` over `rsqml_butt`. Its default there is 0 (`src/CVARINFO.rsq:49` at BD22 VR 7c3ed23), so A2 would have been switched off again for everyone who never touched it | The one `CopyI("rsq_butt", "rsqml_butt")` line is gone. Speed and forward share still copy | `Melee/zscript/rsqml/club.zs`, `Migrate()` | Low. A player who had deliberately turned BD22 VR's butt strike OFF now gets it on |
| B2 | Tactical Rig | **Shoulder to ShieldSaw** off did not give the off shoulder back to guns: `ShieldHolster()` never read the row, so a gun was still refused there | `ShieldHolster()` returns -1 (no claim) when `rsqtr_yield_shield` is off | `TacticalRig/zscript/rsqtr/hooks.zs` about line 53 | **Medium.** `ShieldHolster()` has about fifteen callers in `rig.zs` and one in `ghost.zs`; all of them now treat that shoulder as an ordinary gun holster when the row is off. The 11-07 note above the function says the shoulder was the ShieldSaw's "whether the shield is on the shoulder or in the hand": that was the owner's rule then, and this changes it only with the row off (it is on by default) |
| B3 | Tactical Rig | "No flares left" printed with Messages off; the other short lines did not | It now needs **Messages** on, like the others. The refusal buzz is unchanged | `TacticalRig/zscript/rsqtr/rig.zs` about line 3264 | Low |
| B4 | Tactical Rig | The mirror read `p.mo.health` with no check that `p.mo` exists | `rig && p.mo && p.mo.health > 0` | `TacticalRig/zscript/rsqtr/mirror.zs` about line 255 | Low |
| B5 | Tactical Rig | Holster Rings had a third choice, "Always While Moving Holsters", that drew exactly as "Hand Nearby" | The choice is off the menu. `RingMode()` is untouched: a saved 2 still reads as 1 | `TacticalRig/MENUDEF.txt` (`RSQTR_Markers`), comment in `CVARINFO.txt` | Low. A config holding 2 shows an unnamed value on that row until it is changed |
| B6 | Tactical Rig | Two settings nothing used: `rsqtr_cig_zippo`, `rsqtr_pairs` | Both lines deleted; `rsqtr_pairs` taken out of Reset All's extra list | `TacticalRig/CVARINFO.txt`, `TacticalRig/MENUDEF.txt` | Low to medium. `rig.zs` about line 2936 still does `CVar.FindCVar("rsqtr_pairs")` in its settings-version step; it is null-checked. An old ini line naming either cvar now loads as an unknown cvar (the comment said "kept so old ini lines load") |
| B7 | Wheel | The grenade's fan of kinds could never open on the default ring: fans exist only with Group by Slot off and more guns than Flat Ring Up To (99) | On a ring built without fans, the grenade's own gun card (never a slot's card, never BACK) may open, and only its kinds. New helpers `nadeCard()` / `nadeFan()`; the three fan gates read `(mFansEnabled \|\| nadeFan(...))`; `expandSlot()` narrows `variants` to the grenade alone when fans are off | `Wheel/zscript/wheel/zscript.zs` about lines 896, 964, 4371-4380, 4392-4404, 10241 | **High. The one to look at first.** Untested logic in the ring's hover and expand path. To check: default ring, grenade alone in its slot: rest 7 tics on its card or press Use: the kinds fan opens, a kind is picked, the ring closes. Grenade sharing a slot: open the slot, then the same on the grenade's card. No other card may fan. Group by Slot off with few guns: the same. Nothing else about hover, the data sheet or the holster web may change. Compile: `(Class<Weapon>)(mTypes[cardIndex])` casts a `Class<Inventory>` |
| B8 | Wheel | **Open at Level Start** always opened on the off hand | `openRig(opensOnHand())` | `Wheel/zscript/wheel/zscript.zs` about line 8836 | Low |
| B9 | Wheel | With Slow Time While Open on, every level load set Bullet Time X's `bt_adrenaline_unlimited` to 1, though the Wheel no longer drives that mod | The lines are gone | `Wheel/zscript/wheel/zscript.zs` about line 3443 | Low. If anyone still plays the Wheel with Bullet Time X and relied on it, it is their setting again |
| B10 | Wheel | Console `wr_reset` skipped Group by Slot, Keep Out of Walls and Inspect Within | `wr_group_slots wr_walls wr_inspect_reach` added to the alias | `Wheel/KEYCONF` line 54 | Low |
| B11 | Wheel | Ammo Readout's "LCD, punched out" drew exactly as "LED segments" | The choice is off the menu | `Wheel/MENUDEF.txt` (`wr_Readouts`) | Low. A saved 1 shows an unnamed value and draws as before |
| B12 | Wheel | **Face Parallax** only moves painted faces, which are off with no row to turn them on | The slider is off the Test page. The cvar and its code stay | `Wheel/MENUDEF.txt` | Low |

## C. Logged, not changed

| # | Mod | What | Owner |
|---|---|---|---|
| C1 | Tactical Rig / Gun Bonsai VR | Boomerang Gun level 1 never finds "the holster it came from" (a draw clears it) and files the gun in the first empty holster with no assignment check (`rig.zs` about 1503, 1670, 2265) | "Log for GBOVR pass" |
| C2 | Distance Grab | The lock is at once (Lock Delay 0), so amber shows only for a refused lock | "leave it as is for now" |

## D. Read in the code, the owner has not yet said

From the Distance Grab and Grenade reads (asked 10:32, not answered when this was written):

- Distance Grab: a walk-up grip on a gun you own with full ammo carries it, while the console line says "left at your
  feet" (`near.zs` about 272-284).
- Distance Grab: **Duck Under Doors** does nothing on the default Arc pull (`flight.zs` about 1049-1079).
- Distance Grab: the burning barrel can be grabbed and thrown but never goes off.
- Distance Grab: Lift Doors and Palm Flips Switches ignore the master **Distance Grab** row and Not With Melee
  (`door.zs` about 148-150). A palm works any Use line, an exit included.
- Grenade: Infight's grenade is green (0x3CDC5A) and its sparks and haze red (0xFF3C3C) (`kinds.zs` about 57, 94).
- Grenade: Cluster bomblets use the older burst (`thrown.zs` about 426).
- Grenade: switching weapons while cooking sets the grenade off at your body.
- Grapple: **Fire Hook** has no default key. The owner asked whether his main-hand stick click could fire it "from my
  mainhand"; the hook always leaves the off hand today.
- Tactical Rig: a debug line still says the "Grip inside the ring" hint text is shown (`rig.zs` about 2797); the words
  were removed.
- Wheel: Weapon Condition, crit and fire mode never show on the data sheet on QuestZDoom (their readers answer "not
  there", `wr_q_shim.zs` about 886-895); no reader for the GNRC or WoS weapon sets.

## What the lane needs to rebuild

`RSQ_Grenade.pk3`, `RSQ_Melee.pk3`, `RSQ_TacticalRig.pk3`, `RSQ_Wheel.pk3` (and the READMEs inside the others that were
rewritten the same day: ShieldSaw, Saber, Grapple, DistanceGrab).
