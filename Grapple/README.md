# RSQ Grapple

`pk3/RSQ_Grapple.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3.

## What it is

A grappling hook that fires from either hand. By default it is jpalomo's jp_grapple (THE OG, since 2026-11-03):
hook a wall, ceiling or floor and you are flung toward the claw once, at his speed, and then let go -- your
momentum and normal physics carry you on. Hook a monster and it is flung toward you once. The numbers are his
ACS, converted exactly (rig: the same launch velocity to 0.001 and the same flight, tic for tic, as his own pk3).
Options: a rope that pulls you to the claw and holds you there, "Swing and Momentum" (hang, swing across gaps,
reel, tap to let go and fly on), climbing the rope hand over hand, and monsters that slide in, fly in an arc or
hang on a lasso. The look and sound are jpalomo's by default. ZScript and data only, no engine change.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
`RSQ_Grapple.pk3`

- **Needs no other RSQ pk3.**
- **Plain Doom 2 without Brutal Doom:** works. Brutal Doom's hands class is checked by name only (for the free
  hand that climbs). The handoff records rig runs on vanilla doom2 and on the full order.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Grapple. Every number is on its "Tuning and Debug" page,
  with "Reset All" at the bottom.
- **Binds (you must bind these):** Options -> Customize Controls -> section **RSQ Grapple**:
  - **Fire Hook (Main)** and **Fire Hook (Off)**: fire, reel, let go. No controller button is bound by
    default (the owner's plan was the stick clicks).
  - **Grab Rope (Main)** and **Grab Rope (Off)**: hold to take hold of the rope with that hand, to climb.
    RSQ DistanceGrab's grab binds also work ("Grips From Grab", on).

## What to do in VR

- **Fire:** point the hand and press its Fire Hook. The claw flies where the hand points.
- **Default (THE OG):** the claw flies at 40 units a tic and reaches 780 units (20 tics), as his did.
  - **Wall, ceiling or floor:** the moment it bites you are thrown toward it: 1/12 of the flat distance per tic
    toward the claw, plus about 1/16 of the height difference upward. 600 units away that is 48 u/tic (about
    50 m/s). Nothing holds you after: you fly, hit what you hit, land and slide on with your speed. The claw stays
    shut where it bit for 16 tics and comes back. Press again at any time to fire again.
  - **Monster:** it is thrown toward you the same way (1/12 of the distance per tic; its height difference / 8 as
    its vertical speed). Floor friction stops it about 0.9 of the way: in front of you.
- **Wall Hook: Rope** (option): the rope pulls you straight to the claw and you stop just short of it (32 units),
  hanging still; on a floor the rope lets go by itself. Tap to let go (you drop, keeping no speed; near the top of
  a wall a small Ledge Hop). Hanging, climb the rope by hand or hold the button to reel in.
- **Swing and Momentum on** (option, whatever Wall Hook says):
  - **Reel:** hold the button. You are pulled up the rope.
  - **Hang:** release. You swing on the rope.
  - **Let go:** a quick tap of the same button. You fly on and keep your speed.
  - **Pump the swing:** push the stick forward or sideways in time with the swing.
  - **Calm the swing:** pull the stick back while hanging. The swing dies in about a second.
- **Climb:** an empty hand on the rope, hold Grab Rope, pull down. Both hands can hold the rope.
- **Miss:** press again while the claw is flying to call it back.
- **Monster (Slide option):** hook it; it slides to you. Tap to let go of it.
- **Lasso (option):** the hooked monster hangs at rope length and follows your arm. Swing it into others; flick
  the arm hard to throw it.

## Features

"On" = on by default (CVARINFO). "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Grapple | On | The hook at all. |
| Wall Hook | OG | OG (jpalomo's one-off fling toward the claw) or Rope (pulled to the claw, you stop and hang there). |
| Swing and Momentum | Option | On: the swing rope (hang, swing, pump, keep your speed), whatever Wall Hook says. |
| Range | Standard | Preset: Short (768), Standard (780, the OG's reach), Long (3072). |
| Swing Feel | Standard | Preset: Floaty, Standard, Snappy. Claw speed and the rope's reel; the Rope pull runs at 1.5x Reel Speed. |
| Rope Climbing | On | A free hand on Grab Rope climbs the rope. |
| Two Hands on the Rope | On | Both hands may hold the rope at once; the climb is their average. |
| Hook Thump | On | A thump in the hand when the hook bites or the rope catches your fall. |
| Calm Swing (Stick Back) | On | Swing and Momentum only: stick back while hanging brakes the swing. |
| Slack Rope Lets Go | On | Swing and Momentum only: a rope lying slack on the floor for 3 s lets go by itself. (The pull lets go as soon as it stops on a floor.) |
| Hook Switches and Doors | Option | The claw hitting a switch or door uses it and comes back. |
| Aim Dot (Empty Hand) | Option | A faint dot where the claw would bite while an empty hand points. |
| Rope Look | Chain | Chain (jpalomo's links) or Cable. |
| Monster Hook | OG | OG (jpalomo's one-off throw toward you), Slide, Yank (thrown through the air in an arc) or Lasso (held at rope length). |
| Monster Pull | Standard | Preset: Gentle, Standard, Strong (slide speed, and the heaviest thing that comes at all). |
| Split Pull by Weight | Option | Slide only: you and the monster share the pull by weight: you go part of the way. |
| Lasso Flick Throw | On | With Lasso: a hard flick of the arm throws the held monster that way. |
| Tumble | Spin | Yank only: Off, Spin, Flip, Both. |
| Throw Damage | On | Yank and Lasso: a thrown monster's landing or strike hurts it. |
| Whip | Option | The hook binds crack an older, simpler whip instead of firing the claw (not RSQ Whip). |
| Look | JP | JP, Combat FX or Ballistics look and sound set. |
| Score Stunts | On | A gap crossed on the rope pays RSQ Score's "Indiana Jones". |

On Tuning and Debug, also: "Keep Momentum" (on; only matters with Swing and Momentum on), "Tap to Let Go (tics)" (8), "Free Hand Only" (on: only an
empty hand may climb, never a gun hand), "Grips From Grab" (on), "Whip Stun" and "Whip Snag" (on), "Debug Log".

## Test it

Load only the base order plus `RSQ_Grapple.pk3`. Steps marked **(not yet headset-confirmed)** were only run on
the simulated rig (2026-10-31 onward).

1. Bind Fire Hook (Main), Fire Hook (Off), Grab Rope (Main), Grab Rope (Off). Menu: Radiant Silvergun Options ->
   RSQ Grapple shows the rows above.
2. Open the menu, close it, then fire at once: the claw leaves from your hand, not your chest.
   **(not yet headset-confirmed)**
3. Fire at a high wall: the claw flies along the chain and bites. Hook Thump: a thump in that hand.
   **(not yet headset-confirmed)**
4. Default: fire at a wall about 10 m away at hand height: you are thrown at it fast (about 26 m/s at 10 m),
   hop a little, hit it, and are free at once; nothing holds you. Same as jp_grapple. **(not yet headset-confirmed)**
5. Default: fire at a wall high up, or at the ceiling over a pit: you are thrown up and toward it in an arc and
   fall back under normal gravity, keeping your speed. **(not yet headset-confirmed)**
6. Default: fire at the floor a few metres ahead: you slide toward the claw and stop by friction.
   **(not yet headset-confirmed)**
7. Wall Hook: Rope: fire at a high wall: you are pulled straight to it and hang 32 units short; tap to drop. An
   empty hand on the rope with Grab Rope, push up: you lower yourself; pull down: you climb back.
   **(not yet headset-confirmed)**
7b. Turn on "Swing and Momentum". Hold the button: you reel up. Release: you hang and swing.
8. Swing and Momentum on: step off a ledge on the rope: you swing across. Pump with the stick in time. Tap the
   button at the top: you let go and fly on, keeping speed. After landing, walking is normal speed at once (no
   slide). **(not yet headset-confirmed)**
9. Swing and Momentum on, hanging and swinging, pull the stick back: the swing dies in about a second.
   **(not yet headset-confirmed)**
10. Rope or Swing, hanging: an empty hand on the rope with Grab Rope, pull down: you climb. Add the other hand: both
    hold, the climb is their average. One hand still, the other shaking: no net climb. **(not yet headset-confirmed)**
11. Swing and Momentum on: hook the floor and stand still: after 3 s the rope lets go by itself.
    **(not yet headset-confirmed)**
12. Fire at nothing far away: press again while it flies: it comes back.
13. Default: hook an imp 10 m away: it is thrown at you and slides to a stop in front of you. A Cyberdemon (a boss,
    too heavy): you are thrown toward it instead. **(not yet headset-confirmed)**
14. Options, one at a time, then back to default:
    - Monster Hook: Slide. A hooked imp slides to you and stops in front.
    - Monster Hook: Yank. A hooked imp flies through the air in an arc, spins, lands in front of you.
    - Monster Hook: Lasso. The imp hangs at rope length and follows your arm; sweep it into a zombie (both hurt).
      Flick the arm hard: it is thrown that way. Tap: it drops. **(not yet headset-confirmed)**
    - Split Pull by Weight: hook an imp: you both move, meeting in between; a heavier demon: you go most of the
      way. **(not yet headset-confirmed)**
    - Hook Switches and Doors: hook a switch: it is used and the claw comes back. (Doors not rig-tested.)
      **(not yet headset-confirmed)**
    - Aim Dot (Empty Hand): point an empty hand at a wall: a faint dot where the claw would bite.
      **(not yet headset-confirmed)**
    - Wall Hook: Rope (step 7).
    - Rope Look: Cable. Look: Combat FX, Ballistics.
15. Tuning and Debug -> "Tap to Let Go (tics)": lower it to 3: a medium press on a rope you hang from now reels
    instead of letting go.
    **(not yet headset-confirmed)**
16. "Reset All" puts everything back.
17. Load RSQ Accessibility (Steady Hands on). Hold a hand still on a far wall spot and fire: the claw lands on that
    spot. Steady Hands off: as before. **(not yet headset-confirmed)**
18. Accessibility's Slower Taps on: a press a little longer than "Tap to Let Go" still lets go of the rope.
    **(not yet headset-confirmed)**
19. Accessibility's Rumble Strength 0: no bite thump. **(not yet headset-confirmed)**

## Works with

- **RSQ DistanceGrab:** its grab binds take hold of the rope ("Grips From Grab"). The Yank arc is
  DistanceGrab's flight path, ported.
- **RSQ SlowMo:** a hooked monster slides at the slowed world speed; a yanked monster takes the same arc at any
  speed. Your own swing runs in real time.
- **RSQ Score:** "Indiana Jones" for a gap crossed on the rope (Score Stunts), plus hook bonuses (Reeled In,
  Ping-Pong, Bowling and others). Score's rope awards were measured with the swing; with the pull they were not
  checked.
- **RSQ HP Bars:** "hooked" and "stunned" markers over hooked and yanked monsters.
- **RSQ Gestures:** the rope is never read as a gesture.
- **RSQ Whip:** loads beside it; separate binds and settings.
- **RSQ Miniboss** (2026-11-03, by name): with Miniboss's "Can't Be Yanked" on (the default) a miniboss is too heavy
  to come, as a boss is: the hook pulls you to it (`RSQMB_Service` `bossfor` `"yank"`). Rig only, not headset-confirmed.
- **Gun Bonsai with the RSQ Gun Bonsai VR patch:** nine hook perks (Long Line, Fast Reel, Heavy Haul, Get Over
  Here, Bowling, Barbed Claw, Slingshot, Steady Line, Double Hook), now a tree (GBOVR_TREES.md 4.6): **Grapple** is an
  unlock -- under the patch the hook fires only once it is learned -- and **Momentum** is the Swing and Momentum
  option as an unlock; the nine hang from them (Double Hook after Heavy Haul 2, no longer "from player level 5").
  New: **Zip Kick** (arrive on a monster by the rope at 3 m/s or more: 20 / 30 / 40, more the faster), **Scorpion**
  (needs RSQ Melee: what the hook brings is punched by your empty fist at full power as a counter) and **Twin Lines**
  (after Momentum: a rope from each hand; you hang between them; hold one's reel and the other pays out, so you
  are drawn to that one; 2: let one go and you are flung along the other). Without the patch nothing changes.
  **Fast Reel** (11-03, "faster claw + harder yank"): the claw flies, and the OG fling and OG yank launch, 10% faster
  a level (x1.4 at 4; the claw 40 -> 56 a tic). The yank's lift stays the OG's. No cap, as the OG has none: Long
  Line 4 + Fast Reel 4 from 1380 flings you at 160 u/tic and the wall stops you (rig).
  With the OG defaults: Get Over Here and Scorpion act when a thrown monster arrives in front of you; Bowling
  strikes what is in its path; Double Hook pairs two monsters bitten within 16 tics; Barbed Claw tears when the
  claw lets go; Zip Kick counts a fling as the rope. Slingshot, Steady Line and Twin Lines sit under Momentum (the
  swing rope). Rig only, not headset-confirmed.
- **RSQ Accessibility:** Hold to Toggle on the hook binds, Gesture Ease, colour-blind cues. Steady Hands (on in
  Accessibility): the hook is fired along the smoothed hand, and the aim dot follows it; the climb, the rope, the
  lasso and the lash stay on the raw hand. Slower Taps: Tap to Let Go is 1.5x longer. Rumble Strength 0: no bite
  thump (the thump is the engine's one fixed buzz, so other values leave it as it is). Inert without it.

## Known limits / open issues

- THE OG default (2026-11-03) ran on the simulated rig only, against jpalomo's own pk3 there
  (test/evidence/og_1103.txt). Not felt in the headset yet.
- One difference from the OG, on purpose: a boss, or anything over 1000 mass, is still an anchor (you are flung
  toward it; Heavy Haul raises the limit). The OG throws even a Cyberdemon at you.
- The OG's aim: his projectile climbed a few degrees less than the hand points (rig: 16.9 vs 20 degrees); ours flies
  where the hand points. The fling from where it bites is his, exactly.
- Rope mode: hanging, you stay where the pull stopped, at any angle (no swing, no sliding under the claw). Two
  ropes out at once pull you between their two points. The stick does nothing during the pull or the hang.
- Rope mode: stopped against the face of a wall below its top, you hang there; the tap's Ledge Hop (6 u/tic) is
  the only help over a lip. There is no automatic mantle.

- Feel not checked in the headset: reel speed, top speed, pump, the tap window, the brake, the 3 m/s lasso
  flick, whether the aim dot is visible enough, the lasso at speed, the thump.
- The claw sprite is jpalomo's 15-unit claw: large right at the hand at launch.
- The rope does not wrap round corners: it slips and lets go.
- A monster dangling on the rope outside Lasso mode is dropped after about 1.5 s without progress.
- jpalomo's art and sounds are slated for replacement (see Credits).
- The RSQ Accessibility wiring (2026-11-01: Steady Hands, Slower Taps, Rumble Strength) ran on the simulated rig only: it loads clean with
  and without Accessibility, in the Brutal Doom order too. Its effect on this mod's aim was not measured on the rig.
- Not run: Cheello's Voxel Doom II, netplay.

## Credits

From CREDITS.txt, unchanged:

The hook's art and sound are jpalomo's, from the grappling hook in his mod pack
(jp_grapple.pk3, kept unmodified in jp_original/ of the source repo):
  - claw sprites OCLW (open) and CCLW (shut), shipped here as RSGH / RSGK
  - chain link tenda0 (the 40 px hires version), shipped here as RSGR
  - sounds dschain, dsswish, dspulchn, dsmtalht, dsmeatht, shipped here as
    RSGCHAIN, RSGSWISH, RSGPULCH, RSGMETAL, RSGMEAT
  - the OG wall and monster modes (the defaults) reproduce his Hook_HitWall and
    Hook_HitEnemy thrusts (hook.acs) and his HookShot's flight, number for number.
Thank you, jpalomo.

SLATED FOR REPLACEMENT (owner, 10-27): this hook is the series' own rebuild, so its look and sound
should be ours too. jpalomo's art and sounds stay as the default until replacements are made from
the owner's RS_CombatFX library (and other cleared sources); then the JP set becomes optional or goes.

Code: ZScript written for the Radiant Silvergun Quest series (presidentkoopa), for
stock QuestZDoom 17.3 by Emawind84 and Team Beef. No engine change.

==== monster side (the throw, the whip, the look sets) ====
The Yank is RSQ_DistanceGrab's WorldHands path ported number for number (its path,
arc, timing, tumble, 0.27 air, MeasureArc, the voxel table and the voxel turn fix):
the owner's RS_WorldHands design, as RSQ_DistanceGrab carries it.
Look sets (rsqgr_looks), all the owner's own libraries:
  - Combat FX: RS_CombatFX's shared draw (WEAPDRAW), holster x3 (HOLSTR, HOLSTR2,
    HOLSTR3) and unsorted foley x3 (FOLEY1-3), shipped as RSGXDRAW, RSGXHOL1-3,
    RSGXFOL1-3. The well records no further provenance for these takes.
  - Ballistics: RS_Ballistics' near-miss whiz x4 (whizby1/5/9/14) and near crack x2
    (bullet_crack_near_01/04), shipped as RSGBWZ1-4 and RSGBCRK1-2, and its tracer
    mesh (models/bullet/btracer.obj/.png, shipped as models/rsqgr/btracer.*).
  - RSGBA0 is a 1x1 transparent placeholder: the sprite name the tracer mesh is bound to.

From the old README: `jp_original/` is the source material: jp_grapple.pk3 (the hook from jpalomo's mod pack,
parent missing), kept unmodified for its art (OCLW/CCLW claw, tenda0) and sounds (dschain, dsswish, dspulchn,
dsmtalht, dsmeatht). It is not loaded as-is.
