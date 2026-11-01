# RSQ SlowMo

The world slows down, you don't. Monsters, their shots, falls and sounds near you run slower while you
move at full speed. Enemy bullets become visible rounds you can step or lean away from, and (as an
option) catch and throw back. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3
(script only, no engine changes). The design is the owner's RS_SlowMo, brought to Quest.

## Load order

```
doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3
          -> BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> RSQ_SlowMo.pk3   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** works. Nothing in the code needs a Brutal Doom class. Without
  Brutal Doom the bullet-catch ting and the drop clink are silent (they are Brutal Doom's casing sounds).
- **Other RSQ pk3s needed:** none. It works alone.
- If **Bullet Time X** or **RS_SlowMo** is loaded, this mod stands down (two slow-motion systems
  compound). *Yield to Other Mods* under *Tuning and Debug* turns that off.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ SlowMo.
- **Button to bind:** the first row of the mod's menu, *Slow Motion*, or Customize Controls -> section
  "RSQ SlowMo" -> "Slow motion on/off". Optional: the wrist cross does the same.
- The bullet catch reads the off-hand grip directly (no binding). Its key numbers are not on the menu.

## What to do in VR

- **Start / stop slow motion:** press your bound key, or cross your wrists in front of your face and hold
  them there a moment.
- **Dodge a round:** step out of its line, or lean your head about 30 cm out of its path.
- **Catch a round (option):** off hand empty, hold the grip and close the hand on a slowed round.
- **Throw it back:** flick the hand (2.5 m/s) toward a monster.
- **Drop it:** open the hand without a flick.
- **Smoke (with RSQ Tactical Rig):** spitting out the cigarette starts 6 s of slow motion.

## Features

All rows are on the front page except *Yield to Other Mods* and *Reset All* (under *Tuning and Debug*).
"On" = on by default (CVARINFO); "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Slow Motion | (key) | Bind your toggle here. |
| World Speed | Standard (0.25) | How slow the world gets: Light / Medium / Standard / Bullet Time. |
| Ease In and Out | Standard | Snap / Standard / Gradual. |
| Dodgeable Bullets | On | In slow motion an enemy's hitscan becomes a visible round, same damage. Brutal Doom's bullets slow to the same speed. |
| Wrist Cross | On | Crossing your wrists in front of your face toggles slow motion. |
| Reload Slowdown | Option | A reload buys a short moment of slow motion. |
| Adrenaline | Option | Slow motion costs adrenaline, earned from kills, hurt and near misses. There is no meter on screen: a pickup sound when full, an "oof" when there is not enough. |
| Haptics | On | Rumble on both hands when slow motion starts and ends; on the off hand for a catch and a throw-back. Needs the engine's quake haptics above 0. |
| Lean Out of Bullets | On | Leaning out of a slowed round's path makes it miss. A lean held for about 2 s becomes your new stance and stops counting. |
| Smooth Walkers | On | The nearest 12 walking monsters move a little every tic instead of stepping. |
| Catch Bullets | Option | Catch a slowed round in the empty off hand, flick it back as your own bullet, or drop it. |
| Color Drain | Option | Colours fade a little while time is slowed (35 % at full depth). |
| Close-Call Slow-Mo | Option | A rocket or fireball about to hit you up close starts a short (0.7 s) slow-mo pulse. |
| Head-Bound Rounds Glow | Option | A slowed round heading for your head glows brighter and bigger; ones that will miss dim. |
| Wrist Cross = 4 s Burst | Option | The wrist cross starts a 4-second burst instead of toggling. |
| Slow Own Missiles | On | Your own rockets slow too. |
| Shot Trails | On | Your shots leave a fading trail. |
| Missile Wakes | On | Slowed missiles leave a wake. |
| Keep Adrenaline Between Levels | On | The meter carries to the next level. |
| Yield to Other Mods (Tuning and Debug) | On | Stand down if Bullet Time X or RS_SlowMo is loaded. |
| Reset All (Tuning and Debug) | - | Resets every SlowMo setting. |

Every other row under *Tuning and Debug* is a number for the features above.

## Test it

Items marked **(not yet headset-confirmed)** were built on 2026-10-31 or later and only ran on the
simulated rig (no sound, no haptics there).

1. Load the pack. Options -> Radiant Silvergun Options shows *RSQ SlowMo*. No script error.
2. Bind *Slow Motion* and press it. The world slows to a quarter speed over a moment; you hear Doom's
   power-up pickup sound. Press again: it eases back, with Doom's lift-stop sound.
   **(the stock cues are not yet headset-confirmed)**
3. Cross your wrists in front of your face and hold. Slow motion toggles.
4. In slow motion, watch a walking demon close up. It glides instead of step, stand, step.
   **(not yet headset-confirmed)**
5. Let a zombieman shoot at you. A visible round flies at you. Step aside: it whizzes past.
6. Again, but lean your head about 30 cm sideways out of its path without stepping. It misses.
   **(not yet headset-confirmed)**
7. Turn on *Catch Bullets*. Empty off hand, hold the grip, close it on a round. It stops in your palm
   with a ting. Flick toward a monster: the round flies back and hurts it. Catch another and open the
   hand gently: it drops with a clink. **(not yet headset-confirmed)**
8. Turn on *Color Drain*. In slow motion colours fade a little. **Check both eyes** (the rig only saw
   the left). **(not yet headset-confirmed)**
9. Turn on *Close-Call Slow-Mo*. Let an imp's fireball come straight at you. Time slows briefly before it
   hits. **(not yet headset-confirmed)**
10. Turn on *Head-Bound Rounds Glow*. Rounds aimed at your head look brighter than ones that will miss.
    **(not yet headset-confirmed; the difference was not readable on the rig)**
11. Turn on *Wrist Cross = 4 s Burst*. The wrist cross gives 4 s of slow motion, then it eases back.
    **(not yet headset-confirmed)**
12. With RSQ Tactical Rig and its cigarettes on: smoke and spit one out. Slow motion lasts its full 6 s.
    **(not yet headset-confirmed)**
13. Fire your own Brutal Doom gun in slow motion. Your tracers move at world speed, not crawling.
    **(not yet headset-confirmed)**
14. With RSQ Gestures: shove the gun in your main hand into a zombieman. The world slows briefly as he is
    knocked back. **(not yet headset-confirmed; rig: the pulse arrived, 300 ms at 35 %)**
15. Turn on *Adrenaline* with an empty meter and press the key. You hear "oof" and a low buzz; nothing
    slows. Kill a few monsters and try again.

## Works with

- **RSQ Tactical Rig:** spitting out the cigarette starts slow motion (its *Slow Motion After a Smoke*).
- **RSQ Wheel:** the ring slows time while open, also while slow motion is easing out.
- **RSQ Saber / RSQ ShieldSaw:** their perfect-parry / perfect-block slow-mo options pulse this clock.
- **RSQ Score:** big kills ask for a short slow-mo pulse.
- **RSQ Gestures:** a landed gun butt shove (or BD22 VR Reloaded's own butt strike, when it is loaded) asks
  for a 300 ms pulse at 35 % (Gestures' *Slow-Mo After a Shove*, on by default; the row is in RSQ Gestures'
  menu, not here). While that slow motion lasts, Gestures' F.E.A.R. Effect doubles shotgun gore. Nothing
  changed in SlowMo for it. **(new 2026-11-01, not yet headset-confirmed)**
- **RSQ Grapple, RSQ Whip:** read the world's speed so they slow with it.
- **RSQ Miniboss:** can hold slow motion through its window.
- **RSQ Accessibility:** Gesture Ease on the wrist cross, a floor on how fast slow motion may ease, and
  other shared settings. Its Steady Hands is **not wired into the catch yet** (handoff task A).
- **Gun Bonsai VR patch:** its slow-motion perks read and pulse this clock.

## Known limits / open issues

- Doors, lifts and moving floors and ceilings keep their speed.
- Engine particles keep their speed; actor-based effects slow.
- Music, and sounds not made by a slowed thing, keep their pitch.
- The near-miss whiz and crack are recordings from the owner's RS_Ballistics library, not stock Doom or
  Brutal Doom sounds.
- A thing let go of on the last tic of the ease-out should get its normal sound pitch back; this was read
  from the code, not heard.
- Bullets on a lean: Brutal Doom's own tracers going through the lean test were not rig-tested.
- The Wheel stopping a slow motion you started yourself on close is a Wheel-side issue (its handoff).

## Credits

From the old README, unchanged:

- The design is RS_SlowMo's (the project owner's): its events, settings and the rule of
  standing down for another slow-motion mod.
- The round's tracer mesh and the near-miss whiz and crack recordings: RS_Ballistics
  (the project owner's library).
- **Bullet Time X** by Xortts: nothing is taken from it; this mod only recognises it by
  class name so the two don't compound.
- The clock's cue sounds are stock Doom sounds played by name (DSGETPOW, DSPSTOP, DSITEMUP,
  DSNOWAY; SNDINFO.txt).
- What the pk3 ships and whose it is: [CREDITS.txt](CREDITS.txt).
- QuestZDoom: Emawind and Team Beef.

RSQ_SlowMo -- credits (from CREDITS.txt, unchanged):

The world slows, you don't. Part of the Radiant Silvergun Quest series. For stock QuestZDoom 17.3:
ZScript and lumps only, no engine changes. The code is new, written for this pack.

WHAT THIS PK3 SHIPS, AND WHOSE IT IS
- The project owner (presidentkoopa):
  The design: RS_SlowMo's (made for his engine build): its events (rsm_pulse, rsm_toggle,
  rsm_on, rsm_off, rsm_state), its settings and the rule of standing down for another
  slow-motion mod.
  The round's tracer mesh (models/rsqsm/btracer.obj, btracer.png) and the near-miss whiz
  and crack recordings (sounds/rsqsm/smwhiz1-4, smcrak1-2): his RS_Ballistics library.
- Generated for this pack:
  The round's placeholder sprite (sprites/rsqsm/RSQRA0.png).
- id Software (Doom), played by name from the IWAD, NOT shipped:
  The clock's cues: DSGETPOW (slowing), DSPSTOP (back to speed), DSITEMUP (meter full),
  DSNOWAY (not enough adrenaline). See SNDINFO.txt.
- Brutal Doom (Sergeant Mark IV), played by name, NOT shipped:
  A caught bullet's ting (weapons/casing1) and a dropped one's clink (weapons/casing): its
  casing sounds. Without Brutal Doom loaded they are silent.
- Bullet Time X (Xortts):
  Nothing is taken from it: this mod only recognises it by class name so the two don't
  compound.
- QuestZDoom (Emawind and Team Beef):
  The engine, and the hand-pose script API the gesture reads.

SHARING
- Free to share as part of the Radiant Silvergun Quest series.

## For other mods

`RSQSM_Service` (found by name). `GetInt` answers -1 when the clock is not running:
`adrenaline.add` (intArg = amount), `adrenaline` (0..100), `slowmo.active` / `active` (1 while slowing or
easing), `scale` (world speed in permille). Other mods can also ask for a pulse with the network event
`rsm_pulse <hold ms> <depth %>` (deeper wins, longer wins). This section is for modders, not for play.
