# RSQ_SlowMo — the world slows, you don't

Slow motion for **stock QuestZDoom 17.3**, in script: ZScript and lumps only, no
engine changes. RS_SlowMo's design (made for the project owner's engine build) brought
to Quest, with the same events and settings, plus enemy bullets you can see and dodge.
Part of the Radiant Silvergun Quest series
([RSQ_UBQSeries](https://github.com/presidentkoopa/RSQ_UBQSeries)).

## How it works

Stock 17.3 has no world clock to slow, so this mod slows each thing near you itself.
Nothing freezes and stutters: every slowed thing still moves every tic, by less.

- **Motion:** speeds scale by the slow-motion factor and gravity by its square, so falls
  and arcs slow exactly; a missile's speed scales so homing stays slowed; sliding on the
  floor and pushes (thrusts, knockback, scripted kicks) scale too.
- **Time:** every animation state lasts longer by the same factor, so monsters walk,
  aim, fire and die at the slowed rate.
- **Sound:** what a slowed thing is playing drops in pitch with it.
- **You don't slow:** you, what you carry, and the series' own hand-held effects (the
  grab's beam, the rig's props, the shield, the saber) stay on real time. Your own rockets do slow (menu).
- Only things within range of a player are slowed (3000 map units by default).

## Dodgeable bullets (on by default)

In slow motion an enemy's hitscan becomes a **visible round** on the same line, with the
same damage, damage type and puff. It flies at about 14 m/s at the default depth.
Step out of its way and it misses (a whiz or a crack as it passes your head); the
ShieldSaw and the saber stop it like any projectile; when it hits, it hurts exactly as
the shot would have, credited to the shooter, so monsters still fight each other over
it. Brutal Doom's bullets (fired as fast projectiles) slow to the same speed. Your own
shots leave a fading trail.

## Starting it

- **A key:** Customize Controls → RSQ SlowMo → *Slow motion on/off*.
- **A gesture:** cross your wrists in front of your face and hold a moment.
- **Ermac's cigarette** (RSQ_TacticalRig): the world slows while it burns.
- **Reloading** (optional, off by default): a short moment as you reload. Works with
  Brutal Doom's reloads.
- **Adrenaline** (optional, off by default): slow motion then costs adrenaline, earned
  from kills, the hurt you take and near misses; it ends when the meter runs dry.
- **Other mods:** `netevent rsm_pulse <hold ms> <depth %>`, RS_SlowMo's own event —
  deeper wins, longer wins, eased by this mod's ramps. Also `rsm_toggle`, `rsm_on`,
  `rsm_off` and `rsm_state` (prints the clock).

## Settings

**Options → Radiant Silvergun Options → RSQ SlowMo**: how slow (`rsm_depth`, default 0.25), ease in and out
(`rsm_ramp_in` / `rsm_ramp_out`), sound pitch, range, round speed, trails, wakes, the
gesture, the reload moment, adrenaline, haptics, and Reset All under *Tuning and Debug*.

## With other slow-motion mods

Two slow-motion systems compound and cannot see each other. If **Bullet Time X** or
**RS_SlowMo** is loaded, this mod stands down and says so in the console
(`rsm_yield 0` runs it anyway).

## Limits on stock 17.3

- Doors, lifts and other moving floors and ceilings keep their speed.
- Engine particles (some effects mods use them) keep their speed; actor-based effects slow.
- Music and sounds not made by a slowed thing keep their pitch.

## Install

Load after your weapon pack. Tested order:
`doom2.wad -> brutal22test6 -> BD_VoxelPack -> the series, any order`.

## Credits

- The design is RS_SlowMo's (the project owner's): its events, settings and the rule of
  standing down for another slow-motion mod.
- The round's tracer mesh and the near-miss whiz and crack recordings: RS_Ballistics
  (the project owner's library).
- **Bullet Time X** by Xortts: nothing is taken from it; this mod only recognises it by
  class name so the two don't compound.
- The clock's cue sounds are generated (`tools/gen_sounds.py`).
- What the pk3 ships and whose it is: [CREDITS.txt](CREDITS.txt).
- QuestZDoom: Emawind and Team Beef.


## For other mods

`RSQSM_Service` (a `Service`, found by name, e.g. `ServiceIterator.Find("RSQSM_Service")`).
`GetInt` answers -1 when the clock is not running (the mod not loaded, or a request it doesn't know):

| request | args | answer |
|---|---|---|
| `adrenaline.add` | `intArg` = amount | adds to the meter (0..100; only with *Adrenaline* on), returns the meter |
| `adrenaline` | | the meter, 0..100 |
| `slowmo.active` / `active` | | 1 while slow motion is doing something this tic (slowed or easing) and not stood down for another slow-motion mod, else 0 |
| `scale` | | the world's speed now, in permille (1000 = not slowed) |

The Gun Bonsai VR patch's slow-motion perks read `active`. A kill earns adrenaline from the
killing blow's own source, so a hitscan kill counts (before, it named only its puff and earned
nothing: measured, a pistol kill 0 -> 0; after, +12).
