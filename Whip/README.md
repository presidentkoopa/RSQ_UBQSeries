# Bullwhip (RSQ Whip)

**The one thing:** a real bullwhip, simulated: MIT Newman Lab's reference whip (Moses C. Nah's "Whip Project --
Targeting with a Whip"), run node for node as a position-based (XPBD) chain with the reference's bend spring and
damper at every joint, so every crack, wrap and swing comes from how you actually move your arm.

A bullwhip for VR. The thong is 25 links of 7.2 cm (1.8 m of leather) that trails, loads and cracks from how you
really move your arm: nothing is scripted. Held, it sits coiled at the handle; wind it up over your shoulder and it
pays out; swing and it cracks. A crack hurts and stuns a monster, throws a switch, and flicks a loose pickup to
you. As a weapon in slot 1 it marks a target, flies to it, wraps round a monster, swings it into others, or yanks
it to you. The off hand can take the thong and whirl it as a lasso. A lash that catches an edge, or an aimed crack
at a wall or ceiling, becomes a rope you swing on, reel up, climb and mantle over. It runs on stock QuestZDoom
17.3 in VR, on plain Doom 2 or with Brutal Doom, and needs no other RSQ pk3 (it carries its own rope code; RSQ
Grapple is not needed, and both load together).

Pk3: `pk3/RSQ_Whip.pk3`.

## Features

**The whip.**
- One physics model, always: 16 sub-steps a tic, the reference whip's bend spring and damper at every joint,
  links held to length, light air drag and a speed cap. The same model whether it hangs, swings, cracks or
  whirls; no calm or active modes.
- Held coiled: not attacking, the thong is a coil at the handle with a short tail (0.29 m) hanging from it. A
  wind-up pays it out to its full length; about a second after it has gone quiet it reels back into the coil.
  Payout and reel-in speed up and slow down gradually.
- The deliberate attack: bring the whip back over your shoulder (hand at shoulder height or higher, the handle
  pointing up and back) and the thong stiffens into a line behind you. Swing forward and it follows the handle
  like a rod, then lets go: one crack per swing, at the end of the swing. The wind-up never cracks by itself; a
  lazy swing never cracks.
- The body's frame: the whip is carried with your body. Walking, stairs, snap turns, stick turns and teleports
  carry it along without swinging it, and never count toward a crack. Only your arm moves it.
- The handle follows your hand through a light smoothing filter (under one tic of lag), so hand jitter does not
  kick the thong. A handle of 24 cm: turning the wrist whips the thong.
- Walls: a link that hits one slides along it and rests against it. Every link must stay in sight of the one
  before it; a link found past a wall is put back on your side, and a thong that keeps ending up in walls is
  laid out again from your hand.
- Light and heavy cracks: a crack's hardness is the tip's speed between Crack Speed and Hardest Crack Speed.
  Damage scales with it (a quarter of Damage (hardest crack) at the crack speed, all of it at the hardest). A
  crack past halfway sounds the heavy crack, otherwise the light one.

**The crack.**
- Hurts what the fast outer half of the thong touches, harder the faster; the crack hits hardest and knocks the
  monster into pain, breaking off the attack it was winding up (Stun).
- Throws a switch it lands on (Throws Switches). Flicks a loose pickup near it to you (Fetches Pickups).
- Its own damage type, "Whip": Brutal Doom's monsters do not answer it with a stealth-kill fatality.
- Hit-Stop (option): a crack freezes the monster for 3 to 6 tics, harder = longer. RSQ HP Bars shows its
  snowflake for it.
- Crack Fireballs Out of the Air (option): a crack through a monster's missile blows it up where it is, or
  (Cracked Fireballs and Rockets: Knocked away) sends it off along the crack to explode away from you.
- Crack Knocks Enemies Back (option, off): a crack that does not kill knocks the monster about, and a marked
  crack's wrap swings it round with your arm. Off, it takes the damage, pain and sparks and stays put; a pull
  back still yanks it, and a thrown lasso still swings it.

**The weapon** (slot 1, beside the melee weapons; one whip, in the hand Whip In names).
- Always out while it is the weapon in that hand: swing it and it cracks.
- Hold the trigger and point: a mark shows on the target. Switches, keys and powerups within 8 m are marked
  first. Alt-fire moves the mark to the next nearest. Keep the Mark When You Lift: lifting the whip for the
  crack does not move the mark.
- The mark is the series' lock diamond: a white centre in a gold ring.
- Crack while something is marked: the whip flies to it and wraps round a monster.
- Wrapped, with the trigger held, the monster swings with your arm at the rope's length and smashes into the
  monsters it meets (Swing a Wrapped Monster).
- The yank is a gesture: a violent pull back. Light monsters fly to you on an arc; medium ones stagger part of
  the way; heavy ones, bosses and RSQ Miniboss's minibosses do not move, and the yank swings you to them
  instead. A gentle tug only drags. Yank Grace (option): no yank for about a third of a second after a wrap.
- Leash (Lock aim): a locked crack on a monster with the button still held catches it and pulls it to you.
  Under RSQ SlowMo it slides at the slowed world speed.

**The lasso** (whip in the main hand).
- Close your off hand on the handle or the thong (the off controller within Lasso Grip Reach with its grip
  pressed, or the engine's two-hand grip) and the off hand holds the thong. The piece between your hands is
  held straight; the rest hangs from the off hand.
- Whirl it: while the off hand draws a circle, the loop is helped round with it and the leather's damping is
  eased off. The help comes in and goes out gradually.
- Let go of the grip anywhere on the circle and the lasso flies out along the loop's path at the whirl's speed,
  and ropes the monster nearest that way (reach: four whip lengths, 7.2 m). A thrown lasso never cracks.

**The rope.**
- Catch Edges (snag): a fast tip that meets an edge above your hand (a beam, a doorway top, a ledge lip) wraps
  round it and becomes a rope.
- Aimed Swing: with the whip in hand, hold the other hand's alt-fire. A thin dotted ray comes out of that hand
  with the series' diamond where it ends: gold where the whip can anchor (a wall or a ceiling within Whip Swing
  Reach), red where it cannot (out of reach, sky, a floor, a portal, a 3D middle texture, a polyobject). With it
  gold, crack as usual: the whip stretches out to the spot, latches, and gives you a small hop if you are
  standing. A ceiling gives the overhead swing; a wall a sideways or diagonal swing round a point beside you.
  While the ray is held that button is the whip's, so the gun in that hand does not alt-fire.
- On a rope: trigger held reels in, alt-fire lets go. Push the stick to lean the swing; haul down on the whip
  in the air to pump it. Your speed carries on when you land (Keep Momentum on Landing).
- The let-go is forgiven: you fly off at the fastest speed of your last 3 tics on the rope.
- Chain swings: the whip comes off a rope already uncoiled, so you can aim the next spot and crack again.
- Rope Climbing: a free (empty) hand on Grab Whip takes hold of the rope and climbs it hand over hand. RSQ
  DistanceGrab's grab binds work too.
- Mantle Over Ledges: reel up to a ledge lip, or lay a free hand on it with Grab Whip, and you go up and over by
  physics, no teleport.

**The binds** (optional; the weapon needs none).
- Whip (Main) / Whip (Off): Whip Style Real: hold the bind and the whip uncoils from that hand, whatever it
  holds; crack it yourself; let go and it rolls up. Assist: a press throws a lash for you at what you point at.
  On a rope: hold to reel, release to hang, tap to let go.
- Whip Aim: Free (the crack hits what the tip touches), Assist (what is nearest the tip), Lock (the other hand
  points, alt-fire holds; the crack flies to it).

## How to play

Press 1 until the whip is up (Whip Weapon in Slot 1 is on by default; nothing to bind). The handle sits in your
hand with the thong coiled at it. Whip In (Main Hand by default) says which hand; there is only ever one whip.

1. **Crack.** Bring the whip back over your shoulder: hand at shoulder height or higher, the handle pointing up
   and back. The thong stiffens and rises behind you. Swing forward: one crack at the end of the swing. Hold
   still about a second and it coils up again. A swing without the wind-up stays coiled and does not crack.
2. **Mark and fly.** Hold the trigger and point at a monster: a white diamond in a gold ring marks it. Alt-fire
   moves the mark to the next one. Wind up and crack with the mark on: the whip flies to it and wraps round it.
3. **Swing it.** Keep the trigger held and sweep your arm: the wrapped monster swings round with you and hits
   what it meets.
4. **Yank.** Wrapped, pull your hand back hard. An imp flies to you. A Baron does not move: you swing to it.
5. **Lasso.** Bring the off controller to the handle or the thong and press its grip: the off hand holds the
   thong. Whirl the off hand in a circle; within a moment the loop swings round fast and flat. Let go of the
   grip as the loop heads toward a monster: it is roped. Let go anywhere else: it flies out, never drops.
6. **Switches and pickups.** Point at a switch and crack it: it is used. Crack near a loose pickup: it flies to
   you.
7. **Rope.** Crack upward at a beam or a doorway top: it wraps and you hang. Trigger held reels you up. Push
   the stick to lean the swing. Alt-fire lets go: you fly, and keep your speed when you land.
8. **Aimed swing.** With the whip out, hold the other hand's alt-fire and point at a ceiling or a wall: gold ray
   and diamond. Wind up and crack: the whip stretches to the spot and you get a small hop. Step off a ledge and
   swing; let go on the upswing. Point at the next spot and crack again for a chain.
9. **Climb and mantle.** On a rope, put a free hand on it with Grab Whip (Customize Controls, section RSQ Whip)
   and pull down: you climb. Reel up to a ledge lip, or slap a free hand on the lip: you mantle over.

With the binds, bind **Whip (Main)** or **Whip (Off)**: hold it and the whip comes out of that hand whatever it
holds; let go and it rolls up. Whip Style Assist throws a lash for you with a press. No controller buttons are
bound by default.

The settings are in Options -> Radiant Silvergun Options -> **RSQ Whip**; the numbers and Reset All are on its
**Tuning and Debug** page.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Whip**:

| Menu row | Default | What it does |
|---|---|---|
| Whip | On | The whip at all. |
| Whip Weapon in Slot 1 | On | You carry the whip weapon in slot 1. |
| Whip In | Main Hand | Which hand the whip weapon is in: Main Hand or Off Hand. One whip, in that hand. |
| Whip Style | Real (hold, crack it yourself) | For the binds: Real, or Assist (press, it cracks for you). |
| Whip Aim | Assist | Free, Assist, or Lock (other hand points, alt-fire holds). |
| Catch Edges (snag) | On | A lash that catches an edge wraps round it and becomes a rope. |
| Aimed Swing (other hand's alt-fire aims) | On | The other hand's alt-fire aims a ray; a crack with the ray gold swings you from that wall or ceiling. |
| Whip Swing Reach (m) | 9 | How far the aimed swing can anchor, 3 to 20 m. |
| Throws Switches | On | A crack on a switch line uses it. |
| Fetches Pickups | On | A crack flicks a loose pickup near it to you. |
| Leash (Lock) | On | Lock aim: keep the bind held on a locked monster and it is pulled to you. |
| Stun | On | A crack knocks a monster into pain (breaks off its attack). |
| Lasso (off-hand grip) | On | Off hand on the thong with its grip down whirls it as a lasso. |
| Crack Knocks Enemies Back | Off | A crack that does not kill knocks the monster about, and a marked crack's wrap swings it with your arm. |
| Swing a Wrapped Monster (flail) | On | A wrapped or lassoed monster swings with your arm and smashes into others. |
| Keep the Mark When You Lift | On | Lifting the whip for the crack does not move the mark; only alt-fire moves it. |
| Yank Grace (no yank right after a wrap) | Off | No yank for about 1/3 s after a wrap. |
| Crack Fireballs Out of the Air | Off | A crack passing through a monster's missile blows it up. |
| Cracked Fireballs and Rockets | Explode where cracked | Or Knocked away, explode there. |
| Hit-Stop (a crack freezes it) | Off | A crack freezes the monster for 3 to 6 tics (harder = longer). |
| Mantle Over Ledges | On | Reel up to a lip, or Grab it with a free hand: up and over. |
| Keep Momentum on Landing | On | The swing's speed carries on when you land. |
| Rope Climbing | On | A free hand on Grab Whip climbs the rope. |

**Tuning and Debug**:

| Menu row | Default | What it does |
|---|---|---|
| Crack Speed (lower = easier) | 20 | How fast the tip must go to crack, room units a tic, 10 to 50. |
| Damage (hardest crack) | 12 | A crack's full damage, 0 to 40. A crack at the crack speed does a quarter. |
| Hardest Crack Speed | 43 | The tip speed that lands all the damage, 25 to 120. |
| Lasso Grip Reach (m) | 0.30 | How near the handle or thong the off controller must be to take the lasso, 0.1 to 0.6. |
| Aim Reach | 40 | Assist aim's reach round the crack, map units, 16 to 96. |
| Switch/Key/Powerup Mark Range | 256 | Switches, keys and powerups this close are marked first, 0 to 768 (256 = 8 m). |
| Pulled Off Feet Up To (mass) | 400 | Up to this mass a yanked monster flies to you, 50 to 1000. |
| Can't Be Pulled From (mass) | 1000 | From this mass (and bosses) the yank swings you to it, 200 to 5000. |
| Thickness | 1.0 | The thong's thickness, 0.2 to 2.0. |
| Leather Stiffness (x reference) | 1.0 | Bend stiffness, times the reference whip's, 0.25 to 4.0. |
| Leather Damping (x reference) | 1.0 | Bend damping, times the reference whip's, 0 to 4.0. |
| Whip Air Drag | 1.0 | 0 to 4.0 (1: the thong settles in about a second). |
| Hand Smoothing (tics, 0 = off) | 0.8 | How far behind the hand the handle follows, 0 to 2.0. |
| Reel Speed | 12 | Rope taken in per tic while reeling, 2 to 30. |
| Shortest Rope | 32 | Reeled all the way in, 16 to 128. |
| Top Speed | 30 | Speed cap on the rope, 10 to 60. |
| Swing Lean (stick) | 0.25 | How hard the movement stick leans a swing, 0 to 1.0. |
| Arm Pump (0 = off) | 0.12 | Hauling down on the whip in the air adds this much to the swing, 0 to 0.3. |
| Air Drag | 0.002 | Share of the swing's speed lost per tic, 0 to 0.01. |
| Rope Friction | 0.025 | A constant loss that brings the swing to rest, 0 to 0.1. |
| Ledge Hop | 6 | Lift when letting go at the top of a wall, 0 to 12. |
| Free Hand Only | On | Only an empty hand may take hold of the rope, never a gun hand. |
| Grips From Grab | On | RSQ DistanceGrab's grab binds take hold of the rope too. |
| Grab Reach | 16 | How near the rope the hand must be to take hold, 4 to 40. |
| Climb Speed Cap | 8 | The most the body moves per tic by the hand, 2 to 20. |
| Heaviest Leashed | 1000 | Heavier than this (or a boss) is an anchor and does not come, 100 to 5000. |
| Leash Pull | 10 | A leashed monster slides to you this fast, 2 to 30. |
| Snag Edge Height | 16 | How far above the hand an edge must be to snag, 0 to 64. |
| Rope Meets Body (height) | 0.6 | Where the rope meets the body, as a fraction of height, 0.1 to 1.0. |
| Rope Draw Pieces | 12 | Most pieces a slack line is drawn in, 2 to 32. |
| Leash Stops At | 16 | A leashed monster stops this far from you, 0 to 64. |
| Let-Go Return Speed | 64 | A let-go line coming back to the hand, 8 to 160. |
| Debug Log | Off | Off, Events, Every tic, Cost, Snags and grip keys. |
| Reset All | | Puts every RSQ Whip setting back to its default (asks first). |

Not on the menu, on purpose: the off controller's grip key codes (`rsqwp_keys_off`, default "443 436", the same
codes RSQ DistanceGrab reads) and the lasso's test switch.

## Works with

- **RSQ Gun Bonsai VR** (with Gun Bonsai): the whip weapon levels up. Every point the whip deals is paid to the
  whip's own record, so it levels like a weapon. Its tree takes over these rows, which become nodes learned on
  the whip: Lasso (level 2 holds the rope 50 % longer), Catch Edges (Snag; level 2 snags edges from the hand's
  height up), Mantle Over Ledges (level 2: from a swing too), Keep Momentum on Landing (Momentum; levels 2-3
  raise the swing's speed cap to 36 and 42), Crack Fireballs Out of the Air (Crack Shot; levels 2-3 also hurt
  what stands near the burst), Knocked away (Return Crack: the missile goes back at its shooter, harder a
  level), Hit-Stop (Strike True: 3 / 4 / 6 tics whatever the crack). New nodes: Sting (a harder crack a level),
  Stun (the crack's pain held longer), Long Thong (the thong x1.25, 1.5, 1.75), Quick Mark (switches and
  pickups marked from 2 m further a level; at 3 a second pickup is marked and one crack fetches both), Heavy
  Yank (the mass that flies to you 600 / 800 / 1000), Pull and Punch (a yanked monster arrives staggered), Bola
  (the lasso ties one or two more monsters to its catch), Tarzan (swing into a monster: hurt and knocked flat).
  Without Gun Bonsai VR, every row works as a plain option.
- **RSQ HP Bars**: a monster the whip has wrapped or tied shows the hooked icon; a hit-stop shows the frozen
  snowflake.
- **RSQ Score**: the crack, lasso, bola, Tarzan swing, Crack Shot, Return Crack, Pull and Punch, heavy yank and
  crack stun are reported to Score's combo ledger; Score reads what the whip is doing through `RSQWP_Service`.
- **RSQ Miniboss**: with its "Can't Be Yanked" on, a miniboss is heavy as a boss is: the yank swings you to it.
- **RSQ DistanceGrab**: its grab binds take hold of the whip's rope (Grips From Grab). The lasso reads the same
  off-grip key codes DistanceGrab reads.
- **RSQ SlowMo**: a leashed monster slides to you at the slowed world speed; the whip itself runs in real time.
- **RSQ Grapple**: loads beside it. Separate binds and settings. Not needed.
- **RSQ Accessibility**: Hold to Toggle on the Whip binds (Real becomes press out, press in); Gesture Ease widens
  the rope grab reach; Slower Taps make the tap that lets go of a rope 1.5x longer; Rumble Strength scales the
  whip's rumbles x0 to x2; Steady Hands: the mark, the aimed swing's ray and where a hook is fired use the smoothed
  hand, while the lash, the crack, the lasso and the climb stay on the raw hand; the Off-Hand Modifier swaps the hands; Cue Size
  scales the lock mark and the aim diamond; the colour-blind palette recolours them; comfort moments on the rope
  are reported for the vignette. All inert without Accessibility.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s; after RSQ Gun Bonsai VR. Its place
among the other RSQ pk3s does not matter: every mod it talks to is found by name at run time.

## Known limits

- The lasso works only with the whip in the main hand (with Whip In = Off Hand the main hand holds your gun).
- A hand switch made by another mod (or "switchhand") moves the gun in the other hand as the engine does it;
  the whip goes back to its hand within a second.
- A rope does not wrap round corners or pillars: a rope that loses sight of its anchor for 3 checks lets go.
- The aimed swing refuses portals, 3D middle textures and polyobjects.
- A missile blown up near you still hurts you; it keeps its shooter.
- The aim ray and the mark read your own hand pose; single player is exact.

## For other mods

**`RSQWP_Service`** (a `Service`, found by name; -1 when the whip is absent or the answer is older than 10 s):
- The player (`objectArg` = the pawn): `"swinging"`, `"airborne"`, `"released"`, `"landed"`, `"swings"`,
  `"rope.speed"`, `"released.speed"`.
- The monster (`objectArg` = the monster): `"whipped"`, `"crack.k"`, `"wrapped"`, `"wrapped.by"`, `"yanked"`,
  `"flailing"`.
- A missile (`objectArg` = the missile): `"returned"`.

Each is documented line by line at the top of `zscript/rsqwp/service.zs`. The crack and the smash are noted
before the blow lands, so a scorer hearing the death already reads `"whipped"` as 0.

**`RSQTHP_MarkerWhip`**: answers RSQ HP Bars' `"hooked"` for a wrapped or tied monster.

The whip asks, by name: `RSQ_MeleeUpgradeService` (`"level"` per node, `"credit.push"` / `"credit.pop"`,
`"stagger"`), `RS_ScoreService` (`"touch"`), `RSQMB_Service` (`"bossfor"` `"yank"`), `RSQSM_Service` (`"scale"`),
and RSQ Accessibility's settings and `RSQA_Service`.

## Credits

`CREDITS.txt`:

```
RSQ_Whip -- credits
===================

Code: ZScript written for the Radiant Silvergun Quest series (presidentkoopa), for stock QuestZDoom 17.3 by
Emawind84 and Team Beef. No engine change.

The thong's physics are built on Moses C. Nah's "Whip Project - Targeting with a Whip" (MIT Newman Lab,
github.com/MosesAndLily/whip-project-targeting, BSD 3-Clause, Copyright (c) 2020 Moses C. Nah + MIT Newman Lab):
its whip model's bend stiffness (0.242 N m/rad), damping (0.092 N m s/rad), link (0.072 m) and node mass
(0.012 kg) are used node for node (25 links, 1.8 m), converted to map units and tics (whip.zs). Its code is not
included.

The first version was simulated the way runevision (Rune Skovbo Johansen) describes Eye of the Temple's whip in his devlog
"Trials and triumphs of whips and levers" (2017): a chain of links kept in arrays, a spring step between
neighbours that pulls one more than the other because the whip thins toward the tip, and one sweep per link from
where it was to where it is. The idea is his; the code is the series' own. Verlet rope references the owner
pointed to: dylnli/rope (after Sebastian Lague) and chrischristakis/RopePhysics.

The line a snag or a leash becomes (swing, reel, pump, climb hand over hand, let go, the monster slide) is
RSQ_Grapple's core, forked and renamed (RSQWP_), with its measured pendulum and climbing.

The look is generated here, from nothing (tools/gen_whip.py): the plaited thong and wrapped handle skins
(models/rsqwp/rsqwhip.png, rsqwhiph.png) on RSQ_Grapple's rope tube (rsqrope.md3, its tools/gen_rope.py).

Sounds (chosen by the owner): "crack_heavy", "crack_light" and "three_whip_swishes" from Pixabay
(pixabay.com/sound-effects, Pixabay Content License: royalty-free, no attribution required; the authors'
names were not recorded with the files). Converted to mono OGG, trimmed, the swishes cut into three
(sounds/RSWPCRK1-2, RSWPSWS1-3). The unfurl is a swish; the hit is stock Doom's punch (DSPUNCH).
The old generated sounds were removed.
```

Reference: Eye of the Temple.
