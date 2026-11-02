# RSQ Whip

`pk3/RSQ_Whip.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3.

## What it is

A bullwhip. The leather part is simulated as a chain of 20 links with the bend springs and dampers of a validated
research whip (MIT's Whip Project, see Credits), so it hangs, trails and cracks from how you really move your arm.
One model always: the same physics whether it hangs, swings or cracks (no calm/active modes). The chain moves with
your body: walking, turning (snap or stick) and teleports carry it along without swinging it, so only your arm
moves it. An idle whip hangs and settles.
A lazy swing does not crack. Bring the whip back over your shoulder and it stiffens into a line behind you; swing
forward and it follows your hand like a rod, then lets go: one crack per swing. A crack hurts and stuns a monster, throws a switch, and flicks a loose pickup to you. As a weapon
in slot 1 it can also mark a target, fly to it, wrap round a monster, swing it into others, or yank it to you.
A lash that catches an edge (a beam, a doorway top, a ledge lip) becomes a rope you can swing on, reel up,
climb and mantle over. ZScript and data only, no engine change.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
`RSQ_Whip.pk3`

- **Needs no other RSQ pk3.** It carries its own copy of the rope code; RSQ Grapple is not needed. The two load
  together (separate binds, separate settings).
- **Plain Doom 2 without Brutal Doom:** the code looks up no Brutal Doom class. The 10-30 rig runs were done
  both standalone (freedoom2) and in the Brutal Doom order (HANDOFF.md).

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Whip. Numbers are on its "Tuning and Debug" page,
  with "Reset All" at the bottom.
- **The weapon:** "Whip Weapon in Slot 1" is on by default, so you are given the whip and it sits in slot 1
  beside Brutal Doom's melee weapons. Nothing to bind for the weapon.
- **Which hand:** "Whip In" (Main Hand / Off Hand, default Main Hand). There is only ever one whip, in that hand.
  With Off Hand, pick it in the off hand's slot 1; if it ends up in the other hand (any hand switch), it is moved
  back within a second.
- **Binds (optional, for the bind-driven whip and for climbing):** Options -> Customize Controls -> section
  **RSQ Whip**:
  - **Whip (Main)** and **Whip (Off)**: brings the whip out of that hand, whatever you are holding.
  - **Grab Whip (Main)** and **Grab Whip (Off)**: take hold of the rope to climb it. RSQ DistanceGrab's grab
    binds also work ("Grips From Grab", on).
  - No controller buttons are bound by default.

## What to do in VR

With the whip weapon in hand:
- Swing your arm. For a deliberate crack: bring the whip back over your shoulder (hand at shoulder height or
  higher, the handle pointing up and back). The thong stiffens and rises behind you. Swing forward: it follows the
  handle and cracks at the end of the swing. A snap of the forearm without the wind-up can still crack.
- Hold the trigger and point: a target is marked (switches, keys and powerups within 8 m are marked first).
- Alt-fire while holding the trigger: the mark moves to the next target.
- Crack while something is marked: the whip flies to it and wraps round a monster.
- Keep the trigger held: the wrapped monster stays on the whip and swings with your arm.
- Pull back hard: yank it. Light ones fly to you. Heavy ones (and bosses) pull you to them instead.
- Lasso (whip in the main hand only): close your off hand on the handle or the thong (off controller there, grip
  pressed), whirl it, let go of the grip. It ropes the monster in that direction. The piece between your hands
  is held straight; the rest hangs from the off hand.
- On a rope (the whip caught an edge): trigger held = reel in, alt-fire = let go.

With the binds (Whip (Main)/(Off)):
- Whip Style "Real": hold the bind, the whip uncoils; crack it yourself; let go and it rolls up.
- Whip Style "Assist": press the bind, a lash is thrown for you at what you point at.
- On a rope: hold the bind to reel, release to hang, tap to let go and fly.

On any rope:
- Push the stick to pump the swing. Haul down on the whip in the air to pump it.
- Put a free hand on the rope with Grab Whip and climb hand over hand.
- Reel up to a ledge lip, or slap a free hand on the lip with Grab: you mantle up and over.

## Features

Front page of RSQ Whip. "On" = on by default (CVARINFO default). "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Whip | On | The whip at all. |
| Whip Weapon in Slot 1 | On | You carry the whip weapon in slot 1. |
| Whip In | Main Hand | Which hand the whip weapon is in: Main Hand or Off Hand. One whip, in that hand. |
| Whip Style | Real | For the binds: Real (hold, crack it yourself) or Assist (press, it cracks for you). |
| Whip Aim | Assist | Free (hits what the tip touches), Assist (what is nearest the tip), Lock (other hand points, alt-fire holds; the crack flies to it). |
| Catch Edges (snag) | On | A lash that catches an edge wraps round it and becomes a rope. |
| Throws Switches | On | A crack on a switch line uses it. |
| Fetches Pickups | On | A crack flicks a loose pickup near it to you. |
| Leash (Lock) | On | Lock aim: keep the bind held on a locked monster and it is pulled to you. |
| Stun | On | A crack knocks a monster into pain (breaks off its attack). |
| Lasso (off-hand grip) | On | Off hand on the thong with its grip down whirls it as a lasso. |
| Swing a Wrapped Monster (flail) | On | A wrapped or lassoed monster swings with your arm and smashes into others. |
| Keep the Mark When You Lift | On | Lifting the whip for the crack does not move the mark; only alt-fire moves it. |
| Yank Grace (no yank right after a wrap) | Option | No yank for about 1/3 s after a wrap, so the crack's follow-through does not yank. |
| Crack Fireballs Out of the Air | Option | A crack passing through a monster's missile blows it up. |
| Cracked Fireballs and Rockets | Explode where cracked | Or "Knocked away, explode there": the missile is sent off along the crack. |
| Hit-Stop (a crack freezes it) | Option | A crack freezes the monster for 3-6 tics (harder = longer). |
| Mantle Over Ledges | On | Reel up to a lip, or Grab it with a free hand: up and over. |
| Keep Momentum on Landing | On | The swing's speed carries on when you land. |
| Rope Climbing | On | A free hand on Grab Whip climbs the rope. |

Always on, no row of its own:
- **Crack damage by speed.** A harder crack hurts more: a quarter of "Damage (hardest crack)" at the crack speed,
  all of it at "Hardest Crack Speed" (both on Tuning and Debug). A crack in the top half sounds the Heavy crack,
  otherwise the Light one.
- **The body's frame.** The whip is carried with your body. Snap turns, stick turns, walking, stairs and teleports
  do not swing it, and they never count toward a crack.
- **One physics model (11-02 rebuild).** 16 sub-steps a tic, the reference whip's bend spring and damper at every
  joint, links held to length, light air drag and a speed cap that is always on. The handle follows your hand
  through a light smoothing filter (under one tic of lag), sub-step by sub-step, so per-tic hand jitter does not
  kick the thong. Walls: a link that hits one slides along it and then rests against it; nothing switches modes.
- **Wind-up and swing.** Over the shoulder the thong stiffens. A forward swing drives it like a rod and then lets
  it go. The wind-up never cracks by itself. After a crack the whip has to calm (or wind up again) before it can
  crack again.
- **Never in walls.** Each tic every link must be in sight of the one before it (a thong just bent over a ledge's
  lip or a corner counts as in sight). A link found past a wall is put back on your side of it. If links keep
  ending up in walls, the whip is laid out again from your hand.
- **The lock mark** is the series' lock diamond: a white centre in a gold ring (the ring uses RSQ
  Accessibility's colour-blind palette; Cue Size scales it).
- **Damage type "Whip".** It used to be Brutal Doom's "Melee", and Brutal Doom's monsters answer that by handing
  you a stealth-kill fatality. The whip no longer starts one.

Tuning and Debug also has the physics sliders (11-02): **Leather Stiffness**
(x reference, 1), **Leather Damping** (x reference, 0.25: at 1 the lasso cannot lift the thong), **Whip Air Drag** (1: it settles in about a second) and
**Hand Smoothing** (0.8 tics; 0 = the raw hand).

Not on the menu (deliberately): the lasso's test switch (rig only) and the off controller's grip key codes
(default "443 436", the same codes RSQ DistanceGrab reads).

## Test it

Load only the base order plus `RSQ_Whip.pk3`. Any map with monsters works; a map with a beam or ledge helps for
the rope steps. Steps marked **(not yet headset-confirmed)** were only run on the simulated rig. Steps 2b to 2g
are the 11-02 fixes. They were measured on the rig only, so all of them are not yet headset-confirmed.

1. Open the menu: Radiant Silvergun Options shows "RSQ Whip". Open it and check the rows above are there.
2. Press 1 until the whip weapon is up. The handle and the thong hang from your hand.
2b. Stand still with the whip out: it hangs and settles, no shaking. **(not yet headset-confirmed)**
2c. Snap turn several times with your hand still: no crack, and the whip stays where it was relative to you.
    **(not yet headset-confirmed)**
2d. Walk around, up and down stairs, with your hand still: no crack. The whip comes along with you.
    **(not yet headset-confirmed)**
2e. Bring the whip back over your shoulder: the thong stiffens and rises behind you. Swing forward: one crack at
    the end of the swing, then it goes slack. **(not yet headset-confirmed)**
2f. Options -> RSQ Whip -> Whip In: Off Hand. Pick the whip in the off hand: one whip, in the off hand. Back to
    Main Hand: it moves to the main hand, still only one. Also try a hand switch with the whip out: you never get
    two. **(not yet headset-confirmed)**
2g. Hold the trigger on a monster: the mark is a white diamond in a gold ring. **(not yet headset-confirmed)**
3. Swing slowly. The thong trails and droops. No crack.
4. Lift and snap the forearm at a monster. You hear a crack where the tip arrives, and the monster flinches
   into pain.
5. Crack damage by speed: a soft crack and a hard crack on the same monster. The hard one should hurt more,
   and you hear the heavy crack for it (the light crack for the soft one). **(not yet headset-confirmed)**
6. Hold the trigger and point at a monster: a mark shows on it. Lift the whip for a crack while still pointing
   loosely: the mark should stay on the same monster. Alt-fire: the mark moves to the next one.
   **(not yet headset-confirmed)**
7. Crack with the mark on: the whip flies to it and wraps round it. Keep the trigger held and sweep your arm:
   the monster swings round with your arm and hits others it meets. **(not yet headset-confirmed)**
8. Wrapped, pull back hard: an imp should fly to you. Try a heavy monster: you should be pulled toward it.
   Brutal Doom: no Brutal Doom melee or fatality starts when it arrives, and the whip does not stick in a wall.
   **(not yet headset-confirmed)**
9. Lasso: off controller at the handle or the thong, press its grip. Whirl it with the off hand. Let go of the
   grip toward a monster: it gets roped. **(not yet headset-confirmed)**
10. Point at a switch and crack it: the switch is used. Crack near a loose pickup: it flies to you.
11. Crack upward at a beam or a doorway top: it wraps and you hang on a rope. Trigger held reels you up.
    Push the stick to pump. Alt-fire to let go: you fly and keep your speed on landing.
12. On a rope, take hold with a free hand (Grab Whip, or DistanceGrab's grab) and pull down: you climb.
13. Reel up to a ledge lip: you mantle over it.
14. Options, one at a time, then turn each back off:
    - Hit-Stop: a crack freezes the monster for a beat. **(not yet headset-confirmed)**
    - Crack Fireballs Out of the Air: crack an imp's fireball: it bursts where cracked. Then set Cracked
      Fireballs and Rockets to "Knocked away": it flies off and bursts away from you.
      **(not yet headset-confirmed)**
    - Yank Grace: after a wrap, the crack's own follow-through no longer yanks the monster at once.
      **(not yet headset-confirmed)**
15. Bind Whip (Main) and switch to a gun. Hold the bind: the whip comes out of that hand. Release: it rolls up. Try Whip Style "Assist": a press throws a lash for you.
16. "Reset All" on Tuning and Debug puts everything back.
17. Load RSQ Accessibility (Steady Hands on). Hold the mark on one of two monsters standing close together: it
    stays on that one. A crack still goes where you swing. Steady Hands off: as before.
    **(not yet headset-confirmed)**
18. Accessibility's Rumble Strength 0: the whip's buzzes stop; 2: stronger. **(not yet headset-confirmed)**
19. The 11-02 physics rebuild (rig only, not headset-confirmed): hold still: the whip hangs dead still. Shake your
    hand a little: the thong does not twitch. Walk and snap turn: it comes along calmly. Wind up and crack: one
    crack, the tip whips over in one clean stroke. Whip a nearby wall: the thong slides down it and lies at its
    foot; no shaking, no extra cracks.

## Works with

- **RSQ Grapple:** loads beside it. Separate binds and settings. Not needed.
- **RSQ DistanceGrab:** its grab binds take hold of the whip's rope ("Grips From Grab"). The lasso reads the
  same off-grip key codes DistanceGrab uses.
- **RSQ SlowMo:** a leashed monster slides to you at the slowed world speed.
- **RSQ HP Bars:** the hit-stop option shows HP Bars' frozen marker (it reads the monster's freeze, not the
  whip).
- **RSQ Accessibility:** Hold to Toggle on the Whip binds (Real style becomes press out, press in), Gesture Ease
  widens the rope grab reach, the colour-blind palette. Steady Hands (on in Accessibility): the lock and the
  mark (what a crack flies to) and where a hook is fired use the smoothed hand; the lash, the crack, the lasso and
  the climb stay on the raw hand. Slower Taps: the tap that lets go of a rope is 1.5x longer. Rumble Strength
  scales the whip's rumbles x0 to x2 (0 = none). All inert without Accessibility.

## Known limits / open issues

- **Sounds (2026-11-01):** the cracks and swishes are real recordings from Pixabay, picked by the owner; the hit is
  stock Doom's punch. The old generated sounds are gone. Not yet heard in the headset.
- The leather and handle skins are also generated here (CREDITS.txt).
- **Physics rebuild 11-02: rig only, not headset-confirmed.** Without a wind-up, a swing that starts with the thong
  lying on the floor does not crack on the rig (it did before, with the old lighter-toward-the-tip thong); the
  deliberate wind-up cracks every time. The lasso whirls slower than before (it throws, but letting go at a slow
  point of the circle can drop it). Leather Damping 1 (the reference's) makes the lasso too stiff to lift.
- Never run on your headset. Feel numbers are guesses: crack speed, handle 24 cm, length 3.8 m, lock cone 7
  degrees, arm pump, mantle, lasso reach 0.30 m, flail speed. The 11-02 numbers are guesses too, tuned only on the
  rig's scripted swing: the wind-up pose (handle 27 deg up, no further forward than 70 deg off your facing, hand no
  lower than 40 cm under the eyes), how fast it stiffens (8 tics), when the swing lets go (55% of its peak), the
  idle damping.
- The lasso works only with the whip in the main hand (with Whip In = Off Hand the main hand holds your gun).
- A hand switch made by another mod (or "switchhand") moves the gun in the other hand as the engine does it.
  With Whip In set, the whip goes back to its hand within a second.
- A knocked-away rocket can climb steeply and burst on the ceiling (only one crack style measured).
- A missile blown up near you still hurts you; it keeps its shooter.
- Snag reach is uneven: the same throw caught a lip from 30 units but not from 50+.
- No RSQ Score or HP Bars hooks (Grapple's service and perks were not copied). **Gun Bonsai (2026-11-02):** with RSQ
  Gun Bonsai VR loaded, every point the whip deals is paid to the whip weapon's own record (its `Hurt` deals the
  hit inside the patch's claim bracket, asked by name), so the whip levels like a weapon; the patch's BONSAIRC
  types it melee. Without the patch nothing changes. A flail smash is then dealt as the player's hit without
  thrust (the smash does its own knock). Not yet run.
- The RSQ Accessibility wiring (2026-11-01: Steady Hands, Slower Taps, Rumble Strength) ran on the simulated rig only: it loads clean with
  and without Accessibility, in the Brutal Doom order too. Its effect on this mod's aim was not measured on the rig.
- Not run: left-handed, Quest performance (desktop: about 0.15 ms a tic out, 0.25 lashing).

## Credits

From CREDITS.txt, unchanged:

Code: ZScript written for the Radiant Silvergun Quest series (presidentkoopa), for stock QuestZDoom 17.3 by
Emawind84 and Team Beef. No engine change.

The thong's physics (11-02) are built on Moses C. Nah's "Whip Project - Targeting with a Whip" (MIT Newman Lab,
github.com/MosesAndLily/whip-project-targeting, BSD 3-Clause, Copyright (c) 2020 Moses C. Nah + MIT Newman Lab):
its whip model's bend stiffness (0.242 N m/rad), damping (0.092 N m s/rad), link (0.072 m) and node mass
(0.012 kg) are used, scaled to this whip's length and to tics (whip.zs). Its code is not included.

The first version was simulated the way runevision (Rune Skovbo Johansen) describes Eye of the Temple's whip in his devlog
"Trials and triumphs of whips and levers" (2017): a chain of links kept in arrays, a spring step between
neighbours that pulls one more than the other because the whip thins toward the tip, and one sweep per link from
where it was to where it is. The idea is his; the code is the series' own. Verlet rope references the owner
pointed to: dylnli/rope (after Sebastian Lague) and chrischristakis/RopePhysics.

The line a snag or a leash becomes (swing, reel, pump, climb hand over hand, let go, the monster slide) is
RSQ_Grapple's core, forked and renamed (RSQWP_), with its measured pendulum and climbing.

The look is generated here, from nothing (tools/gen_whip.py): the plaited thong and wrapped handle skins
(models/rsqwp/rsqwhip.png, rsqwhiph.png) on RSQ_Grapple's rope tube (rsqrope.md3, its tools/gen_rope.py).

Sounds (2026-11-01, chosen by the owner): "crack_heavy", "crack_light" and "three_whip_swishes" from Pixabay
(pixabay.com/sound-effects, Pixabay Content License: royalty-free, no attribution required; the authors'
names were not recorded with the files). Converted to mono OGG, trimmed, the swishes cut into three
(sounds/RSWPCRK1-2, RSWPSWS1-3). The unfurl is a swish; the hit is stock Doom's punch (DSPUNCH).
The old generated sounds were removed.

Reference (old README): Eye of the Temple.
