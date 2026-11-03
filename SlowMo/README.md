# RSQ SlowMo

**The one thing:** slow motion with no engine change: every monster and every shot slows while your hands stay on
real time, enemy bullets become rounds you can lean out of, and a Shootdodge leaps you through it.

`pk3/RSQ_SlowMo.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3, in VR.

The world slows down, you don't. Monsters, their shots, falls and sounds near you run slower while your head and
hands move at full speed. Enemy bullets become visible rounds you can step or lean away from. Script only, no engine
changes; the design is the owner's RS_SlowMo, brought to Quest. It needs no other RSQ pk3 and works with plain Doom 2
or Brutal Doom. If Xortts' BTX or RS_SlowMo is loaded it stands down, so two slow-motion systems never compound.

## Features

**The clock.**
- Press your Slow Motion key and the world slows to "World Speed" (a quarter speed by default); press again and it
  eases back. Doom's power-up sound going in, the lift-stop sound coming out.
- Everything near you is slowed, not frozen: every slowed thing still moves every tic, by the slowed amount, so
  nothing stutters in the headset. Falls slow, missiles slow, sounds drop in pitch.
- Nothing tracked is slowed: you, what you carry, and the series' hand-held things (the saber, the shield, the whip,
  the grab) stay on real time.
- Ease In and Out: Snap, Standard or Gradual.
- Haptics: a rumble in both hands when slow motion starts and ends.

**Shootdodge.** Press the Shootdodge key while standing on the ground: you leap the way the stick points (forward if
it is centred) and the world slows to "Shootdodge World Speed" until you land. Your own dive hangs in the air by
"Shootdodge Hang". It ends when you land, die, run out of adrenaline, or after 6 seconds.

**Slow Me Too.** Your own walking, jumping and falling slow with the world, so a jump hangs and a step takes longer.
Your head and hands are tracked and never slow. "Slow Me Too Strength" sets how much of the world's slowing you take.

**Dodgeable Bullets.** In slow motion an enemy's hitscan does not land at once: it becomes a visible round leaving
the same muzzle along the same line, same damage. Step out of its way and it misses. Near misses whiz and crack
past you and buzz your hands. Brutal Doom's own bullets slow to the same speed. The ShieldSaw and the saber stop a
round like any projectile.

**Lean Out of Bullets.** Lean your head out of a slowed round's path and it misses. A lean held for about 2 seconds
becomes your new stance and stops counting.

**Adrenaline** (option). Slow motion costs adrenaline, earned from kills, from being hurt and from near misses. A
pickup sound when the meter is full, an "oof" when there is not enough to start. The meter carries between levels.

**The SlowMo Gauge.** A vertical gauge at the side of your view (coldcite's Top HP Bars bar stood on end, in cyan).
With Adrenaline on it is the meter: dim below "Adrenaline to Start" (a white tick marks that line), pulsing while slow
motion spends it. With Adrenaline off it shows only while the world is slowed, filled by how slow. Its colour moves
as it fills, from deep blue through cyan to near white. Gauge Animation: a band of light rises through the fill, its
top edge breathes, a full gauge glints.

**Looks.**
- Smooth Walkers: the nearest 12 walking monsters glide a little every tic instead of step, stand, step.
- Color Drain (option): colours fade a little while time is slowed.
- Shot Trails: your own shots leave a fading trail. Missile Wakes: slowed missiles leave a wake. Slow Own Missiles:
  your own rockets slow too.

**Triggers.** Every way slow motion can start has its own on/off row. Yours (the key, the wrist cross, the burst,
the Wheel, the Accessibility button, a Melee shove, the cigarette, a Saber parry, a ShieldSaw block, the Shootdodge)
are never held back. Automatic ones (Miniboss's window, Close-Call, Reload Slowdown, Score, Gun Bonsai VR, other mods)
wait out the Auto Slow-Mo Cooldown after the last automatic one ends. A row only stops a start; turning slow motion
off always works.

**Close-Call** (option): a rocket or fireball about to hit you up close slows time for a moment. **Reload Slowdown**
(option): a reload buys a moment of slow motion.

**Returns, blocks and catches in slow motion.** A slowed shot is slowed in its speed and in its own Speed value
together, and your blade, shield, whip and hands are never slowed. So when you block, deflect or punch a slowed shot
it reads the shot as it is that moment, and a return (the saber's bat, a Melee send-back, the whip's crack) sends it
off at the world's pace. Once it is your own missile it stays slowed with the world and goes back to full speed when
the clock does. A shot that turns back on itself is a return and the clock leaves it alone.

## How to play

Bind two keys in Options -> Customize Controls, section **RSQ SlowMo**: **Slow motion on/off** and **Shootdodge**.
The first two rows of the mod's own menu (Options -> Radiant Silvergun Options -> RSQ SlowMo) bind the same keys.

1. **Slow the world.** Press Slow motion on/off. The world eases down to a quarter speed. Press it again to bring it
   back.
2. **Or cross your wrists.** Bring your gun hand across in front of your face, past your other hand, and hold them
   there a moment. Slow motion toggles. Hands merely close together (a two-hand grip, a hand reload) do nothing. With
   "Wrist Cross = 4 s Burst" on, the cross gives a 4-second burst instead.
3. **Shootdodge.** Stand on the ground, push the stick the way you want to go (or leave it centred to go forward) and
   press Shootdodge. You leap that way, the world drops to a tenth speed, and you hang in the air through the dive.
   Shoot on the way. When you land, time comes back.
4. **Dodge a round.** In slow motion a zombieman's bullet is a visible round flying at you. Step out of its line, or
   lean your head sideways out of its path without stepping: it whizzes past.
5. **Watch the gauge.** The cyan bar at the side of your view. With Adrenaline on it is your meter: kill, take hits
   and dodge close to fill it; slow motion drains it. Below the white tick there is not enough to start.
6. **Smoke** (with RSQ Tactical Rig): spit out the cigarette and the world slows for the smoke's own time.

## Settings

**RSQ SlowMo** (front page)

| Menu row | Default | What it does |
|---|---|---|
| Slow Motion | (key) | Bind your toggle here. |
| Shootdodge | (key) | Bind the dive here. |
| World Speed | 0.25 | How slow, 0.05 (near-freeze) to 0.95. Every slow motion uses it unless another mod asks for its own. |
| Ease In and Out | Standard | Snap, Standard or Gradual. |
| Dodgeable Bullets | On | In slow motion an enemy's hitscan becomes a visible round, same damage. |
| Adrenaline | Off | Slow motion costs adrenaline, earned from kills, hurt and near misses. |
| Haptics | On | Rumble on both hands when slow motion starts and ends. |
| Lean Out of Bullets | On | Leaning out of a slowed round's path makes it miss. |
| Smooth Walkers | On | The nearest walking monsters move a little every tic instead of stepping. |
| Color Drain | Off | Colours fade a little while time is slowed. |
| SlowMo Gauge | On | The gauge at the side of your view: the meter, or how slow while it runs. |
| Gauge Side | Left | Or Right. |
| Gauge Animation | On | A band of light rising through the fill, a breathing edge, a glint when full. |
| Wrist Cross = 4 s Burst | Off | The wrist cross starts a 4-second burst instead of toggling. |
| Slow Me Too | On | Your own walking, jumping and falling slow with the world. Head and hands never. |
| Slow Me Too Strength | 1.0 | How much of the world's slowing you take: 1 as slow as the world, 0.5 half, 0 none. |
| Shootdodge World Speed | 0.10 | How slow the world is through a dive. |
| Shootdodge Leap | 12 | The dive's thrust, map units a tic, on top of the jump (0 = the jump alone). |
| Shootdodge Hang | 0.5 | How much of the world's slowing your own dive takes. 1 = as slow as the world (a jump hangs ten times as long at 10%); 0.5 = a dive of about 1.7 s; 0 = a normal jump. |
| Slow Own Missiles | On | Your own rockets slow too. |
| Shot Trails | On | Your shots leave a fading trail. |
| Missile Wakes | On | Slowed missiles leave a wake. |
| Keep Adrenaline Between Levels | On | The meter carries to the next level. |

**Triggers**

| Menu row | Default | Kind | Starts slow motion when |
|---|---|---|---|
| Manual Key | On | Yours | you press your Slow Motion key. |
| Shootdodge | On | Yours | you press your Shootdodge key while standing on the ground. |
| Wrist Cross | On | Yours | you cross your wrists in front of your face. |
| Burst | On | Yours | the wrist cross starts its 4 s burst ("Wrist Cross = 4 s Burst" on). |
| Wheel | On | Yours | RSQ Wheel opens. |
| Accessibility Button | On | Yours | you press RSQ Accessibility's slow-motion button. |
| Melee Shove | On | Yours | an RSQ Melee gun butt shove lands. |
| Cigarette | On | Yours | you spit out an RSQ Tactical Rig cigarette. |
| Saber Parry | On | Yours | an RSQ Saber perfect parry (its own slow-mo option on). |
| ShieldSaw Block | On | Yours | an RSQ ShieldSaw perfect block (its own slow-mo option on). |
| Miniboss Window | On | Automatic | RSQ Miniboss's slow window opens. |
| Close-Call | Off | Automatic | a rocket or fireball is about to hit you up close. |
| Reload Slowdown | Off | Automatic | you reload. |
| Score | On | Automatic | RSQ Score's big moment or hit-stop. |
| Gun Bonsai VR | On | Automatic | the Gun Bonsai VR patch's Adrenaline, Showdown or Time Dilation perk. |
| Other / Unknown Mods | On | Automatic | any other mod's pulse, or a mod's named call (see For other mods). |
| Auto Slow-Mo Cooldown (s) | 25 | | After an automatic slow motion ends, the next automatic one waits this long. |

Saber Parry and ShieldSaw Block send the same pulse; SlowMo tells them apart by whose option is on and what is in your
hands. With a saber in one hand and the ShieldSaw in the other it needs both rows on.

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Ease In | 0.15 | Seconds to slow down over. |
| Ease Out | 0.40 | Seconds to come back over. |
| Range | 3000 | Map units around a player that slow. |
| Sound Follows | 1.0 | How far slowed things' sounds drop in pitch. |
| Round Speed | 14 | A dodgeable round's speed at the set depth, map units a tic. |
| Wrist Gap | 0.16 | How close the wrists must be, metres. |
| Wrist Hold | 12 | Tics to hold the cross. |
| Reload Time | 1200 | Reload Slowdown's hold, ms. |
| Adrenaline to Start | 25 | Needed to start slow motion. |
| Full Meter Time | 10 | A full meter lasts this long, seconds. |
| Adrenaline per Kill | 12 | Earned per kill. |
| Adrenaline per Near Miss | 4 | Earned per near miss. |
| Lean Needed (m) | 0.06 | How far the head must be off its baseline to count as a lean. |
| Lean Baseline (s) | 2.0 | The baseline follows the head over this long. |
| Smooth Range | 1024 | Map units from a player within which walkers are smoothed. |
| Smooth Walkers | 12 | The nearest this many walkers. |
| Color Drain Amount | 0.35 | How much colour goes at full depth. |
| Gauge Size | 1.0 | The gauge's height, as a multiple. |
| Close-Call Time (ms) | 700 | How long a Close-Call pulse holds. |
| Yield to Other Mods | On | Stand down if Xortts' BTX or RS_SlowMo is loaded. |
| Debug Log | Off | Every start, and every refused one, written to the console with its name and tic. |
| Reset All | | Resets every RSQ SlowMo setting. |

## Works with

- **RSQ Tactical Rig:** spitting out the cigarette starts slow motion for the smoke's own time. Row: Cigarette.
- **RSQ Wheel:** the ring slows time while open, also while slow motion is easing out. Row: Wheel.
- **RSQ Saber / RSQ ShieldSaw:** their perfect-parry and perfect-block slow-mo options pulse this clock. Rows: Saber
  Parry, ShieldSaw Block.
- **RSQ Score:** big moments and hit-stop ask for a short pulse (automatic). Row: Score. Score also reads what is
  slowing the world to score it.
- **RSQ Melee:** a landed gun butt shove asks for a short pulse (Melee has its own switch too). Row: Melee Shove.
- **RSQ Grapple, RSQ Whip:** read the world's speed so they slow with it.
- **RSQ Grenade:** its Skeet Window (a Gun Bonsai VR node) pulses slow motion while the grenade is in the air
  (automatic; row Other / Unknown Mods).
- **RSQ Miniboss:** holds slow motion through its window (automatic; one window counts once). Row: Miniboss Window.
- **RSQ Accessibility:** its slow-motion button (row Accessibility Button), Gesture Ease on the wrist cross, a floor
  on how fast slow motion may ease, Hold to Toggle, Photosensitive Mode, and Rumble Strength on every SlowMo rumble.
  Inert without it.

**Gun Bonsai with the RSQ Gun Bonsai VR patch:** its Adrenaline, Showdown and Time Dilation perks pulse this clock
(row Gun Bonsai VR). Your own key, wrist cross, burst and Shootdodge work from the start. Deeper takes the world past
your World Speed (0.2, 0.15, 0.1); Longer stretches the burst (5, 6, 8 s) and the meter; Cheaper makes the meter go
further; Lean Dodge takes over the Lean Out of Bullets row (level 2: a lean also dodges a monster's claw); Matrix
forces the colour drain and shot trails while slowed. Without the patch nothing changes.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s. Needs no other RSQ pk3; any order
among them.

## Known limits

- Doors, lifts and moving floors and ceilings keep their speed.
- Engine particles keep their speed; actor-based effects slow.
- Music, and sounds not made by a slowed thing, keep their pitch.
- The near-miss whiz and crack are recordings from the owner's RS_Ballistics library, not stock Doom or Brutal Doom
  sounds.
- A Shootdodge needs you standing on the ground, not crouched, not swimming, on a map that allows jumping.

## For other mods

Nothing links: find things by name.

**Start slow motion** (e.g. RSQ Tactical Rig's cigarette), from the one machine that decided it:

```
EventHandler.SendNetworkEvent("rsqsm_start:<who>", ms, speedPct, flags);
```

`<who>` is your trigger's name (shown in the Debug Log); `ms` the hold (0 = 4 s); `speedPct` the world's speed in
percent, 5-100 (0 = the player's World Speed slider); `flags` 1 = automatic (waits out the cooldown), 0 = deliberate
(never held back). Both need the Other / Unknown Mods row on. It eases in and out on the player's ramps. A held
toggle outranks it.

From synced play code, the service does the same and answers 1 let in, 0 refused:

```
let it = ServiceIterator.Find("RSQSM_Service"); let s = it.Next();
if (s) s.GetInt("start", "<who>", ms, speed);        // speed 0.05-1.0, 0 = the slider; "start.auto" = automatic
```

**Read it:** `RSQSM_Service` `GetInt` answers -1 when the clock is not running: `adrenaline.add` (intArg = amount;
answers the meter), `adrenaline` (0..100), `slowmo.active` / `active` (1 while slowing or easing), `running` (1 while
held, pulsing or in a Shootdodge), `scale` (world speed in permille), `trigger.auto` (1 an automatic trigger is
slowing the world, 0 a deliberate one, -1 nothing), `trigger.score` (1 while the running pulse is RSQ Score's own).

**RS_SlowMo's doors still work:** `rsm_toggle`, `rsm_on`, `rsm_off`, `rsm_pulse <hold ms> <speed %>` (deeper wins,
longer wins), `rsm_state` (prints the clock). An `rsm_pulse` carries no name, so SlowMo tells the series' callers
apart by what they send: Melee's shove, the cigarette, a Saber parry and a ShieldSaw block are deliberate; Miniboss,
Score, Gun Bonsai VR and anything else are automatic. Each has its row on Triggers. `rsm_toggle 1` is the wrist
cross, `rsm_toggle 2` the key; a bare `rsm_toggle` is RSQ Accessibility's button while that mod is loaded, else the
key. `rsm_on` is the Wheel's. `rsqsm_dodge` is the Shootdodge key.

## Credits

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

RSQ_SlowMo -- credits (from CREDITS.txt):

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
- coldcite (Top HP Bars 1.04, 2017: "Feel free to use this in your mods. You don't have to ask my permission!"):
  The SlowMo gauge (graphics/RSQSMGE, RSQSMGF) is his style-A health bar stood on end, the fill recoloured
  cyan pixel by pixel (TopHPBars/tools/gen_gauges.py in the series repo).
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
