# RSQ Grapple

`pk3/RSQ_Grapple.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3.

## What it is

A grappling hook that fires from either hand. Hook a wall or ceiling and you hang on a rope: swing across gaps
Indiana Jones style, reel yourself up, climb the rope hand over hand, tap to let go and fly on. Hook a monster
and it slides to you (or, as options, is yanked through the air in an arc, or held on the rope like a lasso).
The look and sound are jpalomo's grappling hook by default. ZScript and data only, no engine change.

## Load order

doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3 ->
BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> `RSQ_Grapple.pk3`

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
| Wall Hook | Swing | Swing (a rope) or Yank (jpalomo's pull straight to the wall). |
| Range | Standard | Preset: Short, Standard, Long. |
| Swing Feel | Standard | Preset: Floaty, Standard, Snappy. |
| Rope Climbing | On | A free hand on Grab Rope climbs the rope. |
| Two Hands on the Rope | On | Both hands may hold the rope at once; the climb is their average. |
| Hook Thump | On | A thump in the hand when the hook bites or the rope catches your fall. |
| Calm Swing (Stick Back) | On | Stick back while hanging brakes the swing. |
| Slack Rope Lets Go | On | A rope lying slack on the floor for 3 s lets go by itself. |
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

On Tuning and Debug, also: "Keep Momentum" (on), "Tap to Let Go (tics)" (8), "Free Hand Only" (on: only an
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
4. Hold the button: you reel up. Release: you hang and swing.
5. Step off a ledge on the rope: you swing across. Pump with the stick in time. Tap the button at the top: you
   let go and fly on, keeping speed. After landing, walking is normal speed at once (no slide).
   **(not yet headset-confirmed)**
6. Hanging and swinging, pull the stick back: the swing dies in about a second. **(not yet headset-confirmed)**
7. Hanging, an empty hand on the rope with Grab Rope, pull down: you climb. Add the other hand: both hold, the
   climb is their average. One hand still, the other shaking: no net climb. **(not yet headset-confirmed)**
8. Hook the floor and stand still: after 3 s the rope lets go by itself. **(not yet headset-confirmed)**
9. Fire at nothing far away: press again while it flies: it comes back.
10. Hook an imp: it slides to you and stops in front. A Cyberdemon: you are pulled to it instead.
11. Options, one at a time, then back to default:
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
12. Tuning and Debug -> "Tap to Let Go (tics)": lower it to 3: a medium press now reels instead of letting go.
    **(not yet headset-confirmed)**
13. "Reset All" puts everything back.
14. Load RSQ Accessibility (Steady Hands on). Hold a hand still on a far wall spot and fire: the claw lands on that
    spot. Steady Hands off: as before. **(not yet headset-confirmed)**
15. Accessibility's Slower Taps on: a press a little longer than "Tap to Let Go" still lets go of the rope.
    **(not yet headset-confirmed)**
16. Accessibility's Rumble Strength 0: no bite thump. **(not yet headset-confirmed)**

## Works with

- **RSQ DistanceGrab:** its grab binds take hold of the rope ("Grips From Grab"). The Yank arc is
  DistanceGrab's flight path, ported.
- **RSQ SlowMo:** a hooked monster slides at the slowed world speed; a yanked monster takes the same arc at any
  speed. Your own swing runs in real time.
- **RSQ Score:** "Indiana Jones" for a gap crossed on the rope (Score Stunts), plus hook bonuses (Reeled In,
  Ping-Pong, Bowling and others).
- **RSQ HP Bars:** "hooked" and "stunned" markers over hooked and yanked monsters.
- **RSQ Gestures:** the rope is never read as a gesture.
- **RSQ Whip:** loads beside it; separate binds and settings.
- **Gun Bonsai with the RSQ Gun Bonsai VR patch:** nine hook perks (Long Line, Fast Reel, Heavy Haul, Get Over
  Here, Bowling, Barbed Claw, Slingshot, Steady Line, Double Hook). Without the patch nothing changes.
- **RSQ Accessibility:** Hold to Toggle on the hook binds, Gesture Ease, colour-blind cues. Steady Hands (on in
  Accessibility): the hook is fired along the smoothed hand, and the aim dot follows it; the climb, the rope, the
  lasso and the lash stay on the raw hand. Slower Taps: Tap to Let Go is 1.5x longer. Rumble Strength 0: no bite
  thump (the thump is the engine's one fixed buzz, so other values leave it as it is). Inert without it.

## Known limits / open issues

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
