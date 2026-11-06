# RSQ SlowMo

The world slows down. You don't. Enemy bullets turn into rounds you can watch coming and lean out of the way of.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New since the headset pass (tested on the rig, headset check pending): the Real-Time Countdown bar.

New on 11-06 (rig only, not headset-confirmed): the two bars (stored slow-mo and countdown) with the cause line under
the countdown; Heavy Hit Slowdown; the Grenade Blast and Over-Under Blast triggers; Reload When.

New on 11-06 (rig only, not headset-confirmed): **DOWN**. A hit that would kill you holds you at 1 HP instead. The world
drops to its slowest (5%) for 6 s while you keep full speed, a heartbeat plays (Brutal Doom's own; stock Doom's lift
thud pitched down without it), and a red bar under the slow-mo bars counts the window down with "DOWN" under it. No
single hit can finish you in the first second. Get 3 kills before it runs out and you **REVIVE**: time comes back,
health goes to 50 (or stays, if already higher), every gun's magazine is filled from its reserve, plus one cigarette
(RSQ Tactical Rig) and one grenade (RSQ Grenade, or Brutal Doom's). Run out of time, or take a killing hit after the
first second, and you die, unless an RSQ Score life catches you: DOWN always comes before a Score life. Then DOWN rests
60 s. Joins by name: RSQ Glow In The Dark turns the map blood red, RSQ VisualRewards drops medkits (+25) from the kills
and shows the kill count and the REVIVE word, RSQ Score pays "Down" and "Revive".

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
- More automatic triggers, each off by default (owner 11-06): **Grenade Blast** (Brutal Doom's hand grenade or RSQ Grenade's, yours; 3 seconds), **Over-Under Blast** (the 40 mm under BD22 VR's Rifle and Machinegun, `ShortGrenade`; the same Blast Time), and **Reload When: Always / Low Health** (Low Health At, 25 by default).
- **Heavy Hit Slowdown** (on, owner 11-06; rig only, not headset-confirmed). One hit (everything you take in one tic) of at least Heavy Hit Size (75% of your max health by default) slows the world for 3 seconds, you with it. It fires when the hit came from a LegenDoom legendary, a Champions champion, RSQ Miniboss's miniboss or one of its thralls, a boss (Doom's BOSS flag) or a big demon (Cyberdemon, Spider Mastermind, Baron of Hell, Hell Knight, Mancubus, Arch-Vile, Revenant, and Brutal Doom's and XMVE's versions of them). Or, whatever hit you, when one of four extras is true (each its own row, on): **Arch-Vile Blast** (an Arch-Vile's flame attack), **Blasted Off Your Feet** (the hit throws you up: your vertical speed rises by 10 map units a tic or more; a jump is about 7.4), **Hit From Behind** (the attacker is more than 60 degrees off where your head faces) and **Armour Broken** (the hit takes your last armour). Never on a hit that kills you. Its cooldown: Once per 20 s, Once per 60 s, Use Shared (the automatic cooldown the other triggers share) or No Limit (default); during a Bossfight every heavy hit fires.
- Optional and off by default: **Close-Call** (a rocket or fireball about to hit you up close sets off a short slow) and **Reload Slowdown** (a reload buys a moment of slow motion).

**Adrenaline (optional, off by default)**
- Slow motion costs a meter. You earn 12 per kill, 4 per near miss and half a point per point of damage you take.
- You need 25 to start. A full meter lasts 10 seconds held on. The meter carries over to the next level.
- With too little in the meter you get a short buzz and the player "oof".

**On the HUD**
- **Two bars (2026-11-06; rig only, not headset-confirmed).** Under Score (and under Miniboss's Bossfight meter) sit two bars side by side. LEFT, the **stored slow-mo bar** (the old charge bar, back): with Adrenaline on, it is the meter, filling as you earn and draining while you spend; dim below Adrenaline: To Start (a white tick marks that line). Its hourglass has black trim. RIGHT, the **countdown bar**, shown while the game slowed time by itself (an automatic trigger: Miniboss, Score, Gun Bonsai VR, close call, reload, grenade blast, over-under blast, heavy hit, other mods); its hourglass has brown trim. **Under it, one short line says what caused it** (owner 11-06; Miniboss's wait-line look), and goes with the bar: HEAVY HIT: <the monster's name> (e.g. HEAVY HIT: CYBERDEMON), ARCH-VILE BLAST, BLASTED, HIT FROM BEHIND, ARMOUR BROKEN, GRENADE BLAST, OVER-UNDER BLAST, RELOAD, CLOSE CALL, MINIBOSS, SCORE, GUN BONSAI, OTHER MOD, or another mod's own name when it uses the named door. **With Adrenaline off, your own slow motion shows the countdown bar and its line too** (owner 11-06): SLOW MOTION (your key or the Accessibility button), WRIST CROSS, WHEEL, SHOOTDODGE, BURST, CIGARETTE, SHOVE, PARRY, BLOCK, BOSSFIGHT (Miniboss's landing). With Adrenaline on, your own slow motion (key, wrist cross, Wheel, shootdodge, cigarette, shove, parry, block) spends the stored bar instead and shows no countdown. One bar alone is centred; when the other appears the pair glides so both are centred. The pair is never wider than Score's bar; while the Bossfight meter shows, the pair spans exactly its row.
- **How the countdown runs.** Green by default. It starts full and drains over that slow motion's real seconds, reaching zero just as time catches up (the ease out included). A burst lasts its 4 s (longer with Gun Bonsai VR's Longer); another mod's slow motion lasts what it asked for. Your own slow motion held on (Adrenaline off) drains over your Slow Motion Length (6 s by default). A shootdodge has no set length (it ends when you land), so the bar sits full until then. A new or longer slow motion refills it smoothly with a glint. The bars sit under RSQ Score's bar (under RSQ Miniboss's Bossfight meter when that is loaded), each with a pixel-art hourglass at its left. Without Score, they go where Score's bar would be.
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
| Slow motion on/off | Bound key: *Slow Motion* (Controls: "RSQ SlowMo" → "Slow motion on/off") | No default binding. Toggles slow motion; with Adrenaline off it ends by itself after Slow Motion Length. |
| Slow motion on/off (gesture) | Cross your wrists in front of your face and hold about 1/3 s | Wrists within 16 cm of each other, main hand at least 3 cm across onto the off-hand side, 12–60 cm in front of your eyes, from 40 cm below eye level to 15 cm above. Uncross before the next one. |
| 4-second burst | The same wrist cross, with *Wrist Cross = 4 s Burst* on | A timed slow instead of a toggle. |
| Shootdodge | Bound key: *Shootdodge* (Controls: "RSQ SlowMo" → "Shootdodge"), thumbstick for direction | Only while standing on the ground (not crouched, not in deep water, and only where the map allows jumping). Leaps the way the stick points, forward if it's centred. Ends when you land, die, run out of adrenaline or after 6 s. |
| Lean out of a round | Move your head sideways at least 6 cm, without the stick | Only while time is slowed. Your resting spot follows your head over 2 s, so a lean you hold stops counting. |
| Accessibility button | RSQ Accessibility's slow-motion button | Only with RSQ Accessibility loaded. |
| Open the Wheel | RSQ Wheel's own control | Opening the Wheel slows time, and closing it lets time go. |

**Left-handed play:** with QuestZDoom's left-handed control scheme, the wrist cross is mirrored and each
rumble goes to the correct hand.

## Menu

Options → Radiant Silvergun Options → **RSQ SlowMo**. One page (the Triggers list is on it); the raw numbers and the
debug log are on **Test and Debug**; **Reset All** at the foot resets both. With RSQ Gun Bonsai VR loaded the page's
top line reads "GunBonsaiOVR detected. Mod features unlocked via upgrades." and Lean Out of Bullets stays greyed until
the Lean Dodge node is learned (the row still turns the lean off). A row is greyed while the switch it hangs from is
off (Keep Adrenaline, the bar rows, Wrist Cross Bursts, Burst).

| Row | Default | What it does |
|---|---|---|
| Slow Motion Key | unbound | The key that toggles slow motion. |
| Shootdodge Key | unbound | The shootdodge key. |
| World Speed | 0.25 | How fast the world runs while slowed, from 0.05 (near freeze) to 0.95. With Gun Bonsai VR's Deeper learned, slower still: x0.8, 0.6, 0.4 of this. |
| Slow Motion Length | 6 s | With Adrenaline off, your slow motion (key, wrist cross, Wheel, Accessibility button) ends by itself after this many seconds, 1 to 30; press again to end it sooner. Greyed while Adrenaline is on: the meter decides then. |
| **Slow Motion** | | |
| Dodgeable Bullets | On | Enemy hitscans become visible rounds in slow motion. |
| Lean Out of Bullets | On | Leaning out of a slowed round's path makes it miss. With Gun Bonsai VR: also needs Lean Dodge. |
| Slow Me Too | On | Your own walking, jumping and falling slow with the world. |
| Slow My Missiles | On | Your rockets slow with the world. |
| Smooth Walkers | On | Nearby slowed monsters move a little every frame. |
| Adrenaline | Off | Slow motion costs a meter you earn. |
| Keep Adrenaline | On | The meter carries over to the next level. |
| Haptics | On | All of this mod's rumbles. |
| Yield to Other Mods | On | Stand down if another slow-motion mod is loaded. |
| **Look** | | |
| Colour Drain | Off | Colours fade while time is slowed. |
| Shot Trails | On | Your shots leave a fading trail in slow motion. |
| Missile Wakes | On | Slowed missiles leave a faint wake. |
| Stored Slow-Mo Bar | On | The adrenaline meter as a bar left of the countdown (needs Adrenaline on). |
| Countdown Bar | On | The bar that counts down an automatic slow motion to real time (your own too, with Adrenaline off), with the cause line under it. |
| Bar Animation | On | The bar's sweeping band, breathing edge and refill glint. |
| Bar Colour | Green | 17 colours, or Random (a new one each time it appears). |
| **Your Triggers** (a switch only stops a start, never a stop) | | |
| Slow Motion Key | On | Your Slow Motion key. |
| Shootdodge | On | Your Shootdodge key. |
| Wrist Cross | On | The wrist-cross gesture. |
| Wrist Cross Bursts | Off | The wrist cross starts a 4 s burst instead of toggling. |
| Burst | On | That 4 s burst. |
| Wheel | On | Opening RSQ Wheel. |
| Accessibility Button | On | RSQ Accessibility's slow-motion button. |
| Melee Shove | On | RSQ Melee's gun-butt shove. |
| Cigarette | On | RSQ Tactical Rig's cigarette. With the Rig's Move at Full Speed While Smoking on, you are not slowed during it. |
| Saber Parry | On | RSQ Saber's perfect parry. |
| ShieldSaw Block | On | RSQ ShieldSaw's perfect block. |
| **Automatic Triggers** (they wait out the cooldown) | | |
| Miniboss | On | RSQ Miniboss's slow window. |
| Close Call | Off | A rocket or fireball about to hit you up close. |
| Reload | Off | A reload buys a moment of slow motion. |
| Reload When | Always | Always, or only at or under Low Health At. |
| Grenade Blast | Off | Your grenade's blast (Brutal Doom's or RSQ Grenade's). |
| Over-Under Blast | Off | The blast of BD22 VR's Rifle / Machinegun 40 mm (secondary fire). |
| Score | On | RSQ Score's big moments and hit-stop. |
| Gun Bonsai VR | On | Gun Bonsai VR's Adrenaline, Showdown and Time Dilation perks. |
| Other Mods | On | Any other mod that asks for slow motion. |
| **Heavy Hit Slowdown** | | |
| Heavy Hit Slowdown | On | A heavy hit from a legendary, champion, miniboss or thrall, boss or big demon slows time 3 s (you too). Never on a hit that kills you, never while you are DOWN. |
| *DOWN* | | |
| DOWN | On | A hit that would kill you holds you at 1 HP: the world at its slowest, a window to get kills and REVIVE. |
| Kills Needed | 3 | Kills inside the window to REVIVE (1 to 10). |
| Window (s) | 6 | Real seconds to get them (2 to 30). |
| Cooldown (s) | 60 | After DOWN ends, pass or fail, it can't trigger again for this long (0 to 300). |
| Repeat Without Limit | Off | No cooldown at all. |
| Red Map | On | RSQ Glow In The Dark turns the map deep blood red while you are DOWN. |
| Power-Up Drops | On | Each kill that counts drops RSQ VisualRewards' medkit (+25 health). Needs RSQ VisualRewards. |
| Heavy Hit Size (% of max health) | 75 | What one tic's damage must add up to. |
| Arch-Vile Blast | On | Also on any heavy hit that is an Arch-Vile's flame attack. |
| Blasted Off Your Feet | On | Also on any heavy hit that throws you up (vertical speed up 10+ map units a tic). |
| Hit From Behind | On | Also on any heavy hit from an attacker over 60 degrees off where your head faces. |
| Armour Broken | On | Also on any heavy hit that takes your last armour. |
| Cooldown | No Limit | Once per 20 s, Once per 60 s, Use Shared (the Auto Cooldown) or No Limit. During a Bossfight it fires on every heavy hit. |
| Test and Debug | | The page below. |
| Reset All | | Every setting on both pages back to its default. |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| Ease In (s) | 0.15 | Seconds to slow down. |
| Ease Out (s) | 0.40 | Seconds to come back to full speed. |
| Range | 3000 | Map units around a player that slow. |
| Sound Follows | 1.0 | How far slowed sounds drop in pitch. |
| Round Speed | 14 | A round's speed at the set World Speed, map units a tic. |
| Slow Me Too Strength | 1.0 | 1 is as slow as the world, 0.5 half as much, 0 not at all. |
| Auto Cooldown (s) | 25 | Seconds after an automatic slow ends before the next automatic one can start (0 = none). |
| Shootdodge: World Speed | 0.10 | The world's speed during a shootdodge. |
| Shootdodge: Leap | 12 | The dive's push, in map units a tic (0 = just the jump). |
| Shootdodge: Hang | 0.5 | How much of the world's slowing your dive takes (1 = a jump hangs ten times as long at 10%). |
| Wrist Gap (m) | 0.16 | How close the wrists must be. |
| Wrist Hold (tics) | 12 | Tics to hold the wrist cross. |
| Reload Time (ms) | 1200 | How long a reload's slow motion lasts. |
| Close Call Time (ms) | 700 | How long a close call's slow motion lasts. |
| Blast Time (ms) | 3000 | A grenade or over-under blast's slow motion. |
| Low Health At | 25 | The health line for Reload When = Low Health. |
| Adrenaline: To Start | 25 | The meter needed to start slow motion. |
| Adrenaline: Full Meter (s) | 10 | Seconds a full meter lasts held on. |
| Adrenaline: Per Kill | 12 | Earned per kill. |
| Adrenaline: Per Near Miss | 4 | Earned per round that passes close. |
| Lean Needed (m) | 0.06 | How far your head must move to count as a lean. |
| Lean Baseline (s) | 2.0 | How fast your resting spot catches up with your head. |
| Smooth Range | 1024 | Map units from you that walkers are smoothed. |
| Smooth Walkers | 12 | How many of the nearest walkers are smoothed. |
| Colour Drain Amount | 0.35 | How much colour goes at full depth. |
| Bar Size | 1.5 | Size of the two bars (the pair never wider than Score's bar). While RSQ Miniboss's meter shows, the pair spans the meter's row instead. |
| Debug Log | Off | Print every trigger to the console: its name, when, and what happened. |

## Works with

RSQ SlowMo runs on its own. It finds the other mods by name at run time and links to none of them.

- **RSQ Score:** a big kill can ask for a short slow-motion moment, or an optional hit-stop. Score pays a
  share of a kill's style when it lands in slow motion (full for slow motion you started, half for automatic,
  none for Score's own). The two slow-mo bars slot in under Score's bar (and under RSQ Miniboss's Bossfight meter) and move Score's bonus list below them.
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
  **Deeper** slows the world further (down to 10% at the default World Speed), **Cheaper** spends the meter more slowly,
  and **Matrix** turns on the full colour drain and shot trails (learning it switches both rows on; either row can still
  turn its part off). With the patch loaded, leaning out of bullets also needs its
  **Lean Dodge** upgrade (the menu row still turns it off). At its second level, a lean also dodges a monster's claw.
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
  permission!"): the countdown bar is built from his health-bar art,
  recoloured.
- **id Software** (Doom): the clock's cue sounds (DSGETPOW, DSPSTOP, DSITEMUP, DSNOWAY), played by name from
  your IWAD. They are not shipped.
- **Xortts' Bullet Time X:** nothing is taken from it. This mod only recognises it by name so the two don't stack.
- **QuestZDoom** (Emawind and Team Beef): the engine and the hand-pose API the gesture reads.
- The round's placeholder sprite was generated for this pack. The code is new, written for this pack.

Free to share as part of the Radiant Silvergun Quest series. See [CREDITS.txt](CREDITS.txt).
