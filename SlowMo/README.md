# RSQ SlowMo

The world slows down, you don't. Monsters, their shots, falls and sounds near you run slower while you
move at full speed. Enemy bullets become visible rounds you can step or lean away from. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3
(script only, no engine changes). The design is the owner's RS_SlowMo, brought to Quest.

## Load order

```
doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE
          -> RSQ_SlowMo.pk3   (from pk3/)
```

- **Plain Doom 2 without Brutal Doom:** works. Nothing in the code needs a Brutal Doom class.
- **Other RSQ pk3s needed:** none. It works alone.
- If **Xortts' BTX** or **RS_SlowMo** is loaded, this mod stands down (two slow-motion systems
  compound). *Yield to Other Mods* under *Tuning and Debug* turns that off.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ SlowMo.
- **Button to bind:** the first row of the mod's menu, *Slow Motion*, or Customize Controls -> section
  "RSQ SlowMo" -> "Slow motion on/off". Optional: the wrist cross does the same.

## What to do in VR

- **Start / stop slow motion:** press your bound key, or cross your wrists in front of your face (your gun
  hand past the other one) and hold them there a moment. Hands merely close together (a two-hand grip, a
  hand reload) do nothing.
- **Dodge a round:** step out of its line, or lean your head about 30 cm out of its path.
- **Smoke (with RSQ Tactical Rig):** spitting out the cigarette starts 6 s of slow motion.

## Features

All rows are on the front page except the ones marked *Tuning and Debug*.
"On" = on by default (CVARINFO); "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Slow Motion | (key) | Bind your toggle here. |
| World Speed | 0.25 | A slider from 0.05 (near-freeze) to 0.95 of normal speed. Every slow motion uses it unless another mod asks for its own speed. |
| Ease In and Out | Standard | Snap / Standard / Gradual. |
| Dodgeable Bullets | On | In slow motion an enemy's hitscan becomes a visible round, same damage. Brutal Doom's bullets slow to the same speed. |
| Wrist Cross | On | Crossing your wrists in front of your face toggles slow motion. |
| Adrenaline | Option | Slow motion costs adrenaline, earned from kills, hurt and near misses. There is no meter on screen: a pickup sound when full, an "oof" when there is not enough. |
| Haptics | On | Rumble on both hands when slow motion starts and ends. Needs the engine's quake haptics above 0. |
| Lean Out of Bullets | On | Leaning out of a slowed round's path makes it miss. A lean held for about 2 s becomes your new stance and stops counting. |
| Smooth Walkers | On | The nearest 12 walking monsters move a little every tic instead of stepping. |
| Color Drain | Option | Colours fade a little while time is slowed (35 % at full depth). |
| Wrist Cross = 4 s Burst | Option | The wrist cross starts a 4-second burst instead of toggling. |
| Close-Call Slow-Mo | Option | Automatic: a rocket or fireball about to hit you up close starts a short (0.7 s) pulse. |
| Reload Slowdown | Option | Automatic: a reload buys a short moment of slow motion. |
| Other Mods' Auto Slow-Mo | On | Automatic: RSQ Score's big moments and Gun Bonsai VR's perks may slow time. |
| Miniboss Window Slow-Mo | On | Automatic: RSQ Miniboss's slow window after a thrall dies. |
| Slow Own Missiles | On | Your own rockets slow too. |
| Shot Trails | On | Your shots leave a fading trail. |
| Missile Wakes | On | Slowed missiles leave a wake. |
| Keep Adrenaline Between Levels | On | The meter carries to the next level. |
| Auto Slow-Mo Cooldown (Tuning and Debug) | 25 s | After an automatic slow motion ends, the next automatic one waits this long. Your own starts are never held back. |
| Yield to Other Mods (Tuning and Debug) | On | Stand down if Xortts' BTX or RS_SlowMo is loaded. |
| Debug Log (Tuning and Debug) | Option | Every start, and every refused one, is written to the console with its name and tic. |
| Reset All (Tuning and Debug) | - | Resets every SlowMo setting. |

Every other row under *Tuning and Debug* is a number for the features above.

## Test it

Items marked **(not yet headset-confirmed)** were built on 2026-10-31 or later and only ran on the
simulated rig (no sound, no haptics there).

1. Load the pack. Options -> Radiant Silvergun Options shows *RSQ SlowMo*. No script error.
2. Bind *Slow Motion* and press it. The world slows to a quarter speed over a moment; you hear Doom's
   power-up pickup sound. Press again: it eases back, with Doom's lift-stop sound.
   **(the stock cues are not yet headset-confirmed)**
3. Move *World Speed* to 0.05 and press the key: the world almost stops. At 0.95 it barely slows.
   **(not yet headset-confirmed; rig: a test projectile flew at 0.050, 0.250 and 0.950 of its speed at
   0.05, 0.25 and 0.95)**
4. Cross your wrists in front of your face (gun hand past the other) and hold. Slow motion toggles. Then
   hold a pistol two-handed, and reload by hand: nothing toggles. **(not yet headset-confirmed; rig: a
   two-hand grip and a hand reload toggled it before 2026-11-02, now only crossed wrists do)**
5. In slow motion, watch a walking demon close up. It glides instead of step, stand, step.
   **(not yet headset-confirmed)**
6. Let a zombieman shoot at you. A visible round flies at you. Step aside: it whizzes past.
7. Again, but lean your head about 30 cm sideways out of its path without stepping. It misses.
   **(not yet headset-confirmed)**
8. Turn on *Color Drain*. In slow motion colours fade a little. **Check both eyes** (the rig only saw
   the left). **(not yet headset-confirmed)**
9. Turn on *Close-Call Slow-Mo*. Let an imp's fireball come straight at you. Time slows briefly before it
   hits. A second one within 25 s of the first slow motion ending does not slow time.
   **(not yet headset-confirmed)**
10. Turn on *Wrist Cross = 4 s Burst*. The wrist cross gives 4 s of slow motion, then it eases back.
    **(not yet headset-confirmed)**
11. With RSQ Tactical Rig and its cigarettes on: smoke and spit one out. Slow motion lasts its full 6 s.
    **(not yet headset-confirmed)**
12. Fire your own Brutal Doom gun in slow motion. Your tracers move at world speed, not crawling.
    **(not yet headset-confirmed)**
13. With RSQ Melee: shove the gun in your main hand into a zombieman. The world slows briefly as he is
    knocked back, every shove (no cooldown). **(not yet headset-confirmed; rig: 8 shoves 3 s apart, 8 pulses
    of 300 ms at 35 %)**
14. Turn on *Adrenaline* with an empty meter and press the key. You hear "oof" and a low buzz; nothing
    slows. Kill a few monsters and try again.
15. With RSQ Accessibility: Rumble Strength 0.5, then start slow motion: the start rumble is half as strong;
    0: none. **(not yet headset-confirmed; rig: start rumble 0.30 at 0.5, 0.60 at 1)**
16. *Debug Log* on (Tuning and Debug), then play: every automatic start or refusal shows in the console
    with its name and tic.

## Works with

- **RSQ Tactical Rig:** spitting out the cigarette starts slow motion (its *Slow Motion After a Smoke*);
  deliberate, so the cooldown never holds it back.
- **RSQ Wheel:** the ring slows time while open, also while slow motion is easing out.
- **RSQ Saber / RSQ ShieldSaw:** their perfect-parry / perfect-block slow-mo options pulse this clock
  (deliberate: never held back).
- **RSQ Score:** big kills ask for a short slow-mo pulse (automatic: *Other Mods' Auto Slow-Mo* and the
  cooldown).
- **RSQ Melee:** a landed gun butt shove asks for a 300 ms pulse at 35 % (its switch is in that mod, not
  here). Deliberate: never held back. **(not yet headset-confirmed)**
- **RSQ Grapple, RSQ Whip:** read the world's speed so they slow with it.
- **RSQ Miniboss:** can hold slow motion through its window (automatic: *Miniboss Window Slow-Mo* and the
  cooldown; one window counts once).
- **RSQ Accessibility:** Gesture Ease on the wrist cross, a floor on how fast slow motion may ease, and
  other shared settings. Rumble Strength scales every SlowMo rumble (not yet headset-confirmed). SlowMo has
  no tap windows, so Slower Taps changes nothing here.
- **Gun Bonsai VR patch:** its slow-motion perks read and pulse this clock (automatic, like Score's).

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
- **Xortts' BTX**: nothing is taken from it; this mod only recognises it by
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
- Xortts' BTX (a slow-motion mod):
  Nothing is taken from it: this mod only recognises it by class name so the two don't
  compound.
- QuestZDoom (Emawind and Team Beef):
  The engine, and the hand-pose script API the gesture reads.

SHARING
- Free to share as part of the Radiant Silvergun Quest series.

## For other mods

This section is for modders, not for play. Nothing links: find things by name.

**Start slow motion** (e.g. RSQ Tactical Rig's cigarette):

```
EventHandler.SendNetworkEvent("rsqsm_start:<who>", ms, speedPct, flags);
```

From the one machine that decided it (a hand gesture, a local test). `<who>` is your trigger's name (shown in
the Debug Log); `ms` the hold (0 = 4 s); `speedPct` the world's speed in percent, 5-100 (0 = the player's
World Speed slider); `flags` 1 = automatic (needs *Other Mods' Auto Slow-Mo* and waits out the cooldown),
0 = deliberate (never held back). It eases in and out on the player's ramps. A held toggle outranks it.

From synced play code (the same on every machine), the service does the same and answers 1 let in, 0 refused:

```
let it = ServiceIterator.Find("RSQSM_Service"); let s = it.Next();
if (s) s.GetInt("start", "<who>", ms, speed);        // speed 0.05-1.0, 0 = the slider; "start.auto" = automatic
```

**Read it:** `RSQSM_Service` `GetInt` answers -1 when the clock is not running: `adrenaline.add` (intArg = amount),
`adrenaline` (0..100), `slowmo.active` / `active` (1 while slowing or easing), `running` (1 while held or
pulsing), `scale` (world speed in permille).

**RS_SlowMo's old doors still work:** `rsm_toggle`, `rsm_on`, `rsm_off`, `rsm_pulse <hold ms> <speed %>`
(deeper wins, longer wins). An `rsm_pulse` carries no name, so SlowMo tells the series' callers apart by what
they send (clock.zs ResolvePulses): Melee's shove, the cigarette and a perfect parry/block are deliberate;
anything else is automatic.
