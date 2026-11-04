# RSQ SlowMo

The world slows down. You don't. Enemy bullets turn into rounds you can watch coming and lean out of the way of.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New since the headset pass (tested on the rig, headset check pending): the Real-Time Countdown bar.

Stock QuestZDoom 17.3 has no world clock that a mod can slow. This mod builds one in ZScript. Every monster,
missile, gib and sound near you is time-dilated, not frozen. Each one still moves every frame, just by less,
so slow motion stays smooth in a headset instead of stuttering. Your head and hands always run in real time.

## Standout feature: dodge the bullet with your body

Slow time down. A zombieman fires. His shot doesn't land instantly any more. It leaves his muzzle as a
glowing round you can see, flying down the same line with the same damage. Lean your head to one side,
the way you would in real life. The round goes past where you were. You hear it whiz by, or crack if it was
close, and both controllers buzz.

That lean is real. The mod tracks how far your head moves off its resting spot. If your head moved at least
6 cm (and you weren't walking with the stick), a slowed round passing on the side you leaned away from misses.
A round aimed at where you are now still hits. Brutal Doom's own projectile bullets slow down to the same
dodgeable speed. Your shield and saber stop the rounds like any other projectile.

## Features

**The clock**
- Everything within range of you slows: movement, falling, animation, attacks and deaths. Sounds drop in pitch.
- It eases in and out (0.15 s in, 0.4 s out by default) and never snaps.
- Your own rockets slow too (you can switch that off).
- Players, what they carry and the series' hand-held effects (saber, shield, grabbed objects, rig props) are never slowed.

**Bullets you can dodge**
- In slow motion, an enemy hitscan becomes a visible round carrying the same damage, puff and damage type.
- Rounds fly at about 14 map units a tic and speed up as the world comes back.
- Near misses play whiz and crack recordings and rumble both hands.
- Your own shots leave a short, fading trail from the muzzle to where they hit.
- Slowed rockets and fireballs leave a faint wake.

**Your body in slow motion**
- **Lean out of bullets.** On by default. See above.
- **Slow Me Too.** On by default. Your own walking, jumping and falling slow with the world. Your head and hands never do.
- **Shootdodge.** A bound key throws you into a leap and slows the world to 10% until you land. Max Payne's dive, in VR.
- **Smooth walkers.** Slowed monsters glide through their steps every frame instead of jerking forward a few times a second.

**Ways in**
- A bound key, or a gesture: cross your wrists in front of your face.
- An optional 4-second burst on the wrist cross instead of a toggle.
- Other mods can start it: opening the RSQ Wheel, a Melee shove, the Tactical Rig cigarette, a Saber perfect parry, a ShieldSaw perfect block, Score's big kills, Miniboss's slow window and Gun Bonsai VR perks.
- Every trigger has its own on/off switch. Automatic triggers wait out a 25-second cooldown so they don't fire all the time. The ones you start yourself are never held back.
- Optional and off by default: **Close-Call** (a rocket or fireball about to hit you up close sets off a short slow) and **Reload Slowdown** (a reload buys a moment of slow motion).

**Adrenaline (optional, off by default)**
- Slow motion costs a meter. You earn 12 per kill, 4 per near miss and half a point per point of damage you take.
- You need 25 to start. A full meter lasts 10 seconds held on. The meter carries over to the next level.
- With too little in the meter you get a short buzz and the player "oof".

**On the HUD**
- **SlowMo Gauge.** A vertical bar at the side of your view. With Adrenaline on it shows the meter, with a tick at the start line. With Adrenaline off it shows only while time is slowed, filled by how slow. It's animated: a band of light rises through it, the top edge breathes and a full gauge glints.
- **Real-Time Countdown Bar.** A horizontal bar, green by default, that appears whenever time is slowed by something you didn't choose: a kill moment, the cigarette, a parry, Miniboss's window, a close call. It counts down the real seconds until the world is back at full speed, including the ease out. It hits zero just as time catches up. If something pushes the slow motion longer, the bar refills smoothly with a glint. It sits under RSQ Score's bar and above Score's bonus list. Without Score, it goes where Score's bar would be.
- **Color Drain** (optional, off by default). Colours fade out while time is slowed.

## How To Play

1. **Bind a key.** Options → Radiant Silvergun Options → RSQ SlowMo → *Slow Motion*. Or skip it and use the gesture.
2. **Try the gesture.** Cross your wrists in front of your face, like blocking a punch, and hold for a third of a second. Time slows. Cross them again to bring it back. Uncross between tries.
3. **Find a zombieman or a chaingunner.** Slow time and watch his shots come at you as rounds. Lean your head sideways out of the line. Listen for the whiz.
4. **Shoot back while they crawl.** Your hands run at full speed and theirs don't. That's the whole advantage.
5. **Shootdodge.** Bind *Shootdodge*. Push the thumbstick the way you want to dive and press it. You leap, the world drops to 10%, and you hang in the air while you shoot. Time comes back when you land.
6. **Master it.** Turn on Adrenaline if free slow motion feels too strong. Then slow motion becomes something you earn from kills and close calls, and spend carefully.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Slow motion on/off | Bound key: *Slow Motion* (Controls: "RSQ SlowMo" → "Slow motion on/off") | No default binding. Toggles held slow motion. |
| Slow motion on/off (gesture) | Cross your wrists in front of your face and hold about 1/3 s | Wrists within 16 cm of each other, main hand at least 3 cm across onto the off-hand side, 12–60 cm in front of your eyes, from 40 cm below eye level to 15 cm above. Uncross before the next one. |
| 4-second burst | The same wrist cross, with *Wrist Cross = 4 s Burst* on | A timed slow instead of a toggle. |
| Shootdodge | Bound key: *Shootdodge* (Controls: "RSQ SlowMo" → "Shootdodge"), thumbstick for direction | Only while standing on the ground (not crouched, not in deep water, and only where the map allows jumping). Leaps the way the stick points, forward if it's centred. Ends when you land, die, run out of adrenaline or after 6 s. |
| Lean out of a round | Move your head sideways at least 6 cm, without the stick | Only while time is slowed. Your resting spot follows your head over 2 s, so a lean you hold stops counting. |
| Accessibility button | RSQ Accessibility's slow-motion button | Only with RSQ Accessibility loaded. |
| Open the Wheel | RSQ Wheel's own control | Opening the Wheel slows time, and closing it lets time go. |

**Left-handed play:** with QuestZDoom's left-handed control scheme, the wrist cross is mirrored and each
rumble goes to the correct hand.

## Menu

Options → Radiant Silvergun Options → **RSQ SlowMo**

| Row | Default | What it does |
|---|---|---|
| Slow Motion | unbound | The key that toggles slow motion. |
| Shootdodge | unbound | The shootdodge key. |
| World Speed | 0.25 | How fast the world runs while slowed, from 0.05 (near freeze) to 0.95. |
| Ease In and Out | Standard | Snap, Standard (0.15 s in / 0.4 s out) or Gradual (0.6 s / 1.2 s). |
| Dodgeable Bullets | On | Enemy hitscans become visible rounds in slow motion. |
| Adrenaline | Off | Slow motion costs a meter you earn. |
| Haptics | On | All of this mod's rumbles. |
| Lean Out of Bullets | On | Leaning out of a slowed round's path makes it miss. |
| Smooth Walkers | On | Nearby slowed monsters move a little every frame. |
| Color Drain | Off | Colours fade while time is slowed. |
| SlowMo Gauge | On | The vertical gauge on the HUD. |
| Gauge Side | Left | Left or right side of your view. |
| Gauge Animation | On | The gauge's rising light, breathing edge and glint. |
| Real-Time Countdown Bar | On | The bar that counts down to real time during slow motion you didn't start. |
| Bar Animation | On | The bar's sweeping band, breathing edge and refill glint. |
| Bar Size | 1.5 | Length of the countdown bar. |
| Bar Colour | Green | 17 colours, or Random (a new one each time it appears). |
| Wrist Cross = 4 s Burst | Off | The wrist cross starts a 4 s burst instead of toggling. |
| Slow Me Too | On | Your own walking, jumping and falling slow with the world. |
| Slow Me Too Strength | 1.0 | 1 is as slow as the world, 0.5 half as much, 0 not at all. |
| Shootdodge World Speed | 0.10 | The world's speed during a shootdodge. |
| Shootdodge Leap | 12 | The dive's push, in map units a tic (0 = just the jump). |
| Shootdodge Hang | 0.5 | How much of the world's slowing your dive takes (1 = a jump hangs ten times as long at 10%). |
| Slow Own Missiles | On | Your rockets slow with the world. |
| Shot Trails | On | Your shots leave a fading trail in slow motion. |
| Missile Wakes | On | Slowed missiles leave a faint wake. |
| Keep Adrenaline Between Levels | On | The meter carries over. |

**Triggers** (one switch for every way slow motion can start; a switch only stops a start, never a stop)

| Row | Default | What it does |
|---|---|---|
| Manual Key | On | Your Slow Motion key. |
| Shootdodge | On | Your Shootdodge key. |
| Wrist Cross | On | The wrist-cross gesture. |
| Burst | On | The wrist cross's 4 s burst. |
| Wheel | On | Opening RSQ Wheel. |
| Accessibility Button | On | RSQ Accessibility's slow-motion button. |
| Melee Shove | On | RSQ Melee's gun-butt shove. |
| Cigarette | On | RSQ Tactical Rig's cigarette. |
| Saber Parry | On | RSQ Saber's perfect parry. |
| ShieldSaw Block | On | RSQ ShieldSaw's perfect block. |
| Miniboss Window | On | RSQ Miniboss's slow window (automatic). |
| Close-Call | Off | A rocket or fireball about to hit you up close (automatic). |
| Reload Slowdown | Off | A reload buys a moment of slow motion (automatic). |
| Score | On | RSQ Score's big moments and hit-stop (automatic). |
| Gun Bonsai VR | On | Gun Bonsai VR's Adrenaline, Showdown and Time Dilation perks (automatic). |
| Other / Unknown Mods | On | Any other mod that asks for slow motion. |
| Auto Slow-Mo Cooldown (s) | 25 | Seconds after an automatic slow ends before the next automatic one can start (0 = none). |

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Ease In | 0.15 | Seconds to slow down. |
| Ease Out | 0.40 | Seconds to come back to full speed. |
| Range | 3000 | Map units around a player that slow. |
| Sound Follows | 1.0 | How far slowed sounds drop in pitch. |
| Round Speed | 14 | A round's speed at the set World Speed, map units a tic. |
| Wrist Gap | 0.16 | How close the wrists must be, metres. |
| Wrist Hold | 12 | Tics to hold the wrist cross. |
| Reload Time | 1200 | How long a reload's slow motion lasts, ms. |
| Adrenaline to Start | 25 | The meter needed to start slow motion. |
| Full Meter Time | 10 | Seconds a full meter lasts held on. |
| Adrenaline per Kill | 12 | Earned per kill. |
| Adrenaline per Near Miss | 4 | Earned per round that passes close. |
| Lean Needed (m) | 0.06 | How far your head must move to count as a lean. |
| Lean Baseline (s) | 2.0 | How fast your resting spot catches up with your head. |
| Smooth Range | 1024 | Map units from you that walkers are smoothed. |
| Smooth Walkers | 12 | How many of the nearest walkers are smoothed. |
| Color Drain Amount | 0.35 | How much colour goes at full depth. |
| Gauge Size | 1.5 | The gauge's height. |
| Close-Call Time (ms) | 700 | How long a close call's slow motion lasts. |
| Yield to Other Mods | On | Stand down if another slow-motion mod is loaded. |
| Debug Log | Off | Print every trigger to the console: its name, when, and what happened. |
| Reset All | — | Puts every RSQ SlowMo setting back to its default. |

## Works with

RSQ SlowMo runs on its own. It finds the other mods by name at run time and links to none of them.

- **RSQ Score:** a big kill can ask for a short slow-motion moment, or an optional hit-stop. Score pays a
  share of a kill's style when it lands in slow motion (full for slow motion you started, half for automatic,
  none for Score's own). The countdown bar slots in under Score's bar and moves Score's bonus list below it.
- **RSQ Wheel:** opening the Wheel slows time while you pick.
- **RSQ Melee, RSQ Tactical Rig, RSQ Saber, RSQ ShieldSaw, RSQ Miniboss:** the shove, the cigarette, the
  perfect parry, the perfect block and the miniboss window each start slow motion, each with its own switch.
  The saber and the shield also stop rounds.
- **RSQ Accessibility:** its slow-motion button works here. Its Min SlowMo Ease sets a floor under both eases,
  Gesture Ease widens and shortens the wrist cross, Rumble Strength scales every rumble, and Text Size scales the
  countdown bar. Colour-blind play recolours the rounds (a quarter larger, in the colour that means "dodge this"),
  your shot trails and the countdown bar. Photosensitive Mode drops the bar's glint and holds its edge still.
- **Gun Bonsai with RSQ Gun Bonsai VR:** the Adrenaline, Showdown and Time Dilation perks pulse slow motion
  (switchable). The slow-motion upgrades shape it: **Longer** stretches the burst (up to 8 s) and the meter,
  **Deeper** slows the world further (down to 10%), **Cheaper** spends the meter more slowly, and **Matrix** turns
  on the full colour drain and shot trails. With the patch loaded, leaning out of bullets is unlocked by its
  **Lean Dodge** upgrade instead of the menu row. At its second level, a lean also dodges a monster's claw.
- **Brutal Doom / BD22 VR Reloaded:** Brutal Doom fires many enemy bullets as fast projectiles, and those slow to the same
  dodgeable speed as the rounds. Reload Slowdown catches Brutal Doom's reloads too.
- **Xortts' Bullet Time X or RS_SlowMo:** two slow-motion systems would stack on each other, so RSQ SlowMo
  stands down and says so in the console. Turn off *Yield to Other Mods* to run both anyway.
- **For modders:** start slow motion with `netevent rsqsm_start:<name> <ms> <speed %> <flags>`, or with
  `RSQSM_Service` `GetInt("start", ...)` from synced play code. RS_SlowMo's `rsm_toggle`, `rsm_on`, `rsm_off` and
  `rsm_pulse` also work.

## Credits and licence

- **presidentkoopa** (project owner): the design, from his RS_SlowMo (its events, settings and the rule of
  standing down for another slow-motion mod); the round's tracer mesh and the near-miss whiz and crack
  recordings, from his RS_Ballistics library.
- **coldcite** (Top HP Bars 1.04, 2017: "Feel free to use this in your mods. You don't have to ask my
  permission!"): the SlowMo gauge and the Real-Time Countdown bar are built from his health-bar art,
  recoloured.
- **id Software** (Doom): the clock's cue sounds (DSGETPOW, DSPSTOP, DSITEMUP, DSNOWAY), played by name from
  your IWAD. They are not shipped.
- **Xortts' Bullet Time X:** nothing is taken from it. This mod only recognises it by name so the two don't stack.
- **QuestZDoom** (Emawind and Team Beef): the engine and the hand-pose API the gesture reads.
- The round's placeholder sprite was generated for this pack. The code is new, written for this pack.

Free to share as part of the Radiant Silvergun Quest series. See [CREDITS.txt](CREDITS.txt).
