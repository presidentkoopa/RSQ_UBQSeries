# RS_ShieldSawQ

**v0.2 — 2026-10-22.** Loads clean on stock QuestZDoom 17.3 (Linux headless build of
`emawind84/gzdoom @ questzdoom`); draw / throw / return / stow and the block (claw, fireballs,
return-to-sender) verified by scripted console runs against a real imp. Not yet run in a headset.

## Features

- Lives over the **offhand shoulder**. Reach over, **off trigger**: it's in your hand. Hold it; **alt-fire** revs; release moving to throw, release slow to put it back; still holding when it comes home with your hand near it catches it
- **Block what crosses the face** — missiles, hitscan, melee, blasts — decided in the sim via
  `AbsorbDamage`, so it is identical on every machine; also while holstered
- Blocked projectiles **cancelled or returned to sender**; blocked melee **stuns / stuns and shoves**
- **Perfect Block**: move the shield into the hit for a bigger stun, shove and a faster return
- **Rev** on the off trigger: blades deploy, saw voice climbs, grinds what it touches, revved throws hit harder
- **Bash**: shove it into something
- **Throw** from the real arm, spinning in the plane your wrist gave it; **lock-on** up to 5 targets;
  **hit tiers** by authored health (fodder bisected, mid-tier embedded and ground, heavies glance);
  **breadcrumb return** that never goes through a wall; **catch** it or let it land on the mount
- **Ermac's hand** on it (Rusted Legacy, MIT), his placement
- **Netplay**: one small pose event a tic while drawn; every damage decision runs from it
- Saw voice and block sparks pulled from RS_CombatFX (chainsaw archetype, `RSS0/RSS1/RSH0`)
- Options menu: `RS ShieldSawQ Options`, with Controls / Placement / Tuning / Debug submenus

A shield saw for **stock QuestZDoom 17.3** (TeamBeef / Emawind84 build). Standalone: loads with
any weapon pack (BD22 Quest, Vanilla VR Plus, plain Doom), no engine changes, no player class
replacement. Ermac's hand holds it (Rusted Legacy, MIT).

Design and reasons: `ShieldSaw_Quest_Design.md` in the zDoomVR project.

## How it plays

- It hangs on your **off shoulder**. Reach over, press the **grip**: it's in your off hand.
- Hold the **off trigger**: the blades deploy and the saw revs. Revved, it grinds what it touches,
  and a revved throw hits harder.
- **What crosses its face is stopped**: fireballs, bullets, claws, blasts. Sparks where it hit; a
  demon that swung at it reels. Blocked fireballs go back at whoever fired them.
- **Shove** it into something: a bash.
- Press the grip **while your arm is moving**: it flies, in the plane your wrist gave it, visiting
  up to five locked targets. Fodder is bisected, mid-tier takes the disc and is ground for a
  while, heavies turn it away. It comes home the way it went -- never through a wall. A hand near
  it on the way back **catches** it; otherwise it lands on your shoulder.
- Press the grip at the shoulder to put it back; press it while the disc flies to recall it.
- The shield on your back guards your back.

## Setup on the headset

1. Load `RS_ShieldSawQ.pk3` after your BD22 pack (or alone). Nothing to bind: the off trigger and
   off alt-fire are QZD's own bindings.
2. `vr_quake_haptic_level` above 0 for the buzzes.
3. Options -> RS ShieldSawQ Options -> Debug -> *Draw the guard plate*: hold the shield up and check
   the red ring sits on the drawn rim (the `ssq_plate_*` cvars move it).

Desktop / no-motion route: *Shield saw: draw / put back / recall* and *Shield saw: throw along
aim* in Customize Controls.

## Netplay

Every damage decision runs in the sim from a pose every machine has: while the shield is drawn,
your machine sends one small event a tic (`ssq-pose`). Grip edges are synced the same way, or by
the user button. Buddies see the shield on your back, in flight, and in your hand (as a world
prop, a tic behind; `ssq_held_world`).

## Known limits (stock engine)

- The zone beside the headset silences whatever is in the off hand while your hand is in it, so
  the trigger there is the shield's alone, on the first tic.
- Hand pose is sampled 35 times a second; a very fast flick is a few samples.
- One haptic strength (the engine's quake route); duration is ours.
- Left-handed mode (`ssq_lefthanded`) is written but untested in a headset.
- Not tested in a headset yet at all: everything below the headless load and the scripted
  draw / throw / return / stow sequence is a reasoned first guess.

## Files

```
zscript/ssq/pose.zs    the synced off-hand pose
zscript/ssq/guard.zs   the block (AbsorbDamage), grind, bash, debug ring
zscript/ssq/shield.zs  the off-hand weapon, rev, placement hook, haptics
zscript/ssq/disc.zs    flight, locks, tiers, breadcrumb return, catch
zscript/ssq/state.zs   stowed / drawn / flying, mount, loadout swap, input, net events
zscript/ssq/props.zs   the world prop and the mount marker
```
