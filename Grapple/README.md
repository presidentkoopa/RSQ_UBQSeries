# RSQ Grapple

`pk3/RSQ_Grapple.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3.

## What it is

A grappling hook that fires from either hand. Hook a wall or ceiling and the rope pulls you straight to where the
claw bit, and you stop there (the default since 2026-11-02). Turn on "Swing and
Momentum" and you hang on the rope instead: swing across gaps Indiana Jones style, reel yourself up, tap to let go
and fly on with your speed. Either way you can climb the rope hand over hand. Hook a monster and it slides to you
(or, as options, is yanked through the air in an arc, or held on the rope like a lasso).
The look and sound are jpalomo's grappling hook by default. ZScript and data only, no engine change.

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
- **Default (Swing and Momentum off):**
  - **Pulled in:** when the claw bites a wall or ceiling you are pulled straight to it, without holding anything,
    and stop just short of it (Shortest Rope, 32 units). The stick does nothing during the pull.
  - **Stop:** stopped on a floor (the claw was at your feet, or you hit a wall at floor level), the rope lets go by
    itself. Stopped in the air, you hang there, still, until you let go.
  - **Let go:** a quick tap of the same button. You drop from where you are, keeping no speed; near the top of a
    wall you get the small Ledge Hop.
  - **Hanging:** climb down or up the rope by hand; hold the button to reel back in. Reaching the floor lets go.
- **Swing and Momentum on (the behaviour of 10-27 to 11-01):**
  - **Reel:** hold the button. You are pulled up the rope.
  - **Hang:** release. You swing on the rope.
  - **Let go:** a quick tap of the same button. You fly on and keep your speed.
  - **Pump the swing:** push the stick forward or sideways in time with the swing.
  - **Calm the swing:** pull the stick back while hanging. The swing dies in about a second.
- **Climb:** an empty hand on the rope, hold Grab Rope, pull down. Both hands can hold the rope.
- **Miss:** press again while the claw is flying to call it back.
- **Monster:** hook it; it slides to you. Tap to let go of it.
- **Lasso (option):** the hooked monster hangs at rope length and follows your arm. Swing it into others; flick
  the arm hard to throw it.

## Features

"On" = on by default (CVARINFO). "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Grapple | On | The hook at all. |
| Wall Hook | Rope | Rope (a pull to the claw, or a swing with Swing and Momentum on) or Yank (jpalomo's one-off throw toward the wall). |
| Swing and Momentum | Option | Off: the rope pulls you to the claw and you stop there. On: hang, swing, pump, and keep your speed when you let go or land. |
| Range | Standard | Preset: Short, Standard, Long. |
| Swing Feel | Standard | Preset: Floaty, Standard, Snappy. Its reel speed also sets the pull's speed (1.5x Reel Speed: 18 u/tic at Standard). |
| Rope Climbing | On | A free hand on Grab Rope climbs the rope. |
| Two Hands on the Rope | On | Both hands may hold the rope at once; the climb is their average. |
| Hook Thump | On | A thump in the hand when the hook bites or the rope catches your fall. |
| Calm Swing (Stick Back) | On | Swing and Momentum only: stick back while hanging brakes the swing. |
| Slack Rope Lets Go | On | Swing and Momentum only: a rope lying slack on the floor for 3 s lets go by itself. (The pull lets go as soon as it stops on a floor.) |
| Hook Switches and Doors | Option | The claw hitting a switch or door uses it and comes back. |
| Aim Dot (Empty Hand) | Option | A faint dot where the claw would bite while an empty hand points. |
| Rope Look | Chain | Chain (jpalomo's links) or Cable. |
| Monster Hook | Slide | Slide, Yank (thrown through the air in an arc) or Lasso (held at rope length). |
| Monster Pull | Standard | Preset: Gentle, Standard, Strong. |
| Split Pull by Weight | Option | You and the monster share the pull by weight: you go part of the way. |
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
4. Default (Swing and Momentum off): fire at a wall point about 10 m away, a little above your head, and let go
   of the button: you are pulled straight to it in well under a second and stop just short of it, hanging still.
   Tap the button: you drop (with a small hop if you were near the top of the wall). **(not yet headset-confirmed)**
5. Default: fire at a wall at waist height: you are pulled along the floor, stop at the wall, and the rope lets
   go by itself. Walking is normal at once. **(not yet headset-confirmed)**
6. Default: from a ledge, fire at the ceiling over a pit: you are pulled up to it and hang. An empty hand on the
   rope with Grab Rope, push up: you lower yourself; pull down: you climb back. **(not yet headset-confirmed)**
7. Turn on "Swing and Momentum". Hold the button: you reel up. Release: you hang and swing.
8. Swing and Momentum on: step off a ledge on the rope: you swing across. Pump with the stick in time. Tap the
   button at the top: you let go and fly on, keeping speed. After landing, walking is normal speed at once (no
   slide). **(not yet headset-confirmed)**
9. Swing and Momentum on, hanging and swinging, pull the stick back: the swing dies in about a second.
   **(not yet headset-confirmed)**
10. Either mode, hanging: an empty hand on the rope with Grab Rope, pull down: you climb. Add the other hand: both
    hold, the climb is their average. One hand still, the other shaking: no net climb. **(not yet headset-confirmed)**
11. Swing and Momentum on: hook the floor and stand still: after 3 s the rope lets go by itself.
    **(not yet headset-confirmed)**
12. Fire at nothing far away: press again while it flies: it comes back.
13. Hook an imp: it slides to you and stops in front. A Cyberdemon: you are pulled to it instead.
14. Options, one at a time, then back to default:
    - Monster Hook: Yank. A hooked imp flies through the air in an arc, spins, lands in front of you.
    - Monster Hook: Lasso. The imp hangs at rope length and follows your arm; sweep it into a zombie (both hurt).
      Flick the arm hard: it is thrown that way. Tap: it drops. **(not yet headset-confirmed)**
    - Split Pull by Weight: hook an imp: you both move, meeting in between; a heavier demon: you go most of the
      way. **(not yet headset-confirmed)**
    - Hook Switches and Doors: hook a switch: it is used and the claw comes back. (Doors not rig-tested.)
      **(not yet headset-confirmed)**
    - Aim Dot (Empty Hand): point an empty hand at a wall: a faint dot where the claw would bite.
      **(not yet headset-confirmed)**
    - Wall Hook: Yank: hooking a wall throws you straight at it.
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
- **Gun Bonsai with the RSQ Gun Bonsai VR patch:** nine hook perks (Long Line, Fast Reel, Heavy Haul, Get Over
  Here, Bowling, Barbed Claw, Slingshot, Steady Line, Double Hook), now a tree (GBOVR_TREES.md 4.6): **Grapple** is an
  unlock -- under the patch the hook fires only once it is learned -- and **Momentum** is the Swing and Momentum
  option as an unlock; the nine hang from them (Double Hook after Heavy Haul 2, no longer "from player level 5").
  New: **Zip Kick** (arrive on a monster by the rope at 3 m/s or more: 20 / 30 / 40, more the faster), **Scorpion**
  (needs RSQ Melee: what the hook brings is punched by your empty fist at full power as a counter) and **Twin Lines**
  (a wall rope from each hand; under the patch one at a time until it is learned; hold one's reel to pull toward
  it; 2: let one go and you are flung along the other). Without the patch nothing changes.
- **RSQ Accessibility:** Hold to Toggle on the hook binds, Gesture Ease, colour-blind cues. Steady Hands (on in
  Accessibility): the hook is fired along the smoothed hand, and the aim dot follows it; the climb, the rope, the
  lasso and the lash stay on the raw hand. Slower Taps: Tap to Let Go is 1.5x longer. Rumble Strength 0: no bite
  thump (the thump is the engine's one fixed buzz, so other values leave it as it is). Inert without it.

## Known limits / open issues

- The pull (the default, 2026-11-02) ran on the simulated rig only: its speed (18 u/tic at Standard, about 0.6 s
  for 10 m), the stop 32 units short of the claw and the still hang are not felt in the headset yet.
- Pull mode: hanging, you stay where the pull stopped, at any angle (no swing, no sliding under the claw). Two
  ropes out at once pull you between their two points. The stick does nothing during the pull or the hang.
- Pull mode: stopped against the face of a wall below its top, you hang there; the tap's Ledge Hop (6 u/tic) is
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
  - the "Yank" wall mode reproduces his Hook_HitWall thrust (hook.acs).
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
