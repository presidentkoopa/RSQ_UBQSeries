# RSQ Grapple

**The one thing:** fling the hook from either hand and it takes you to the wall, or takes the monster to you;
turn on the swing, reel up, and put both hands on the rope.

A grappling hook that fires from either hand. Hook a wall, ceiling or floor and you are flung toward the
claw; hook a monster and it is thrown to you. By default it behaves as jpalomo's jp_grapple did, number for
number; options add a rope you hang from, swinging with momentum, climbing hand over hand, and monsters that
slide in, fly in an arc or hang on a lasso. For stock QuestZDoom 17.3, in VR. Needs no other RSQ mod. ZScript
and data only, no engine change.

## Features

**The hook.**
- Fires from whichever hand pressed, along where that hand points. One hook per hand; both can be out at once.
- The claw flies at 40 units a tic and reaches 780 units, then comes back. Press again while it flies to
  call it back.
- **Wall Hook: OG** (default): the moment the claw bites a wall, ceiling or floor you are thrown toward it
  once, jpalomo's way: your speed is the flat distance divided by 12, plus a lift from the height difference.
  Nothing holds you after; you fly, land and carry on with your speed. The claw stays shut 16 tics and
  comes back.
- **Wall Hook: Rope**: the rope pulls you straight to the claw and you stop 32 units short, hanging still.
  On a floor the rope lets go by itself. Tap to drop (you keep no speed); near the top of a wall the tap gives
  a small Ledge Hop.
- **Swing and Momentum** (option, works with either Wall Hook): hold to reel up the rope, release to hang and
  swing, tap to let go and fly on with your speed. Pump the swing with the stick; pull the stick back to calm
  it.
- A thump in the hand when the hook bites or the rope catches your fall (Hook Thump).
- A rope lying slack on the floor for 3 seconds lets go by itself (Slack Rope Lets Go).
- Switches and doors the claw hits can be used (Hook Switches and Doors, off by default).
- A faint aim dot where the claw would bite, shown while an empty hand points (Aim Dot, off by default).

**Climbing.**
- Hanging on the rope, a free hand that takes hold of it climbs: pull down to go up, push up to lower
  yourself. Both hands can hold the rope at once; the climb is their average.
- Only an empty hand may climb, never a gun hand (Free Hand Only). With Brutal Doom's hands loaded, the fist
  counts as empty; without it, an empty slot or the stock Fist does.

**Monsters.**
- **Monster Hook: OG** (default): a hooked monster is thrown toward you once, jpalomo's way; floor friction
  stops it in front of you.
- **Slide**: it slides to you along the floor and stops a short way off. Tap to let go of it.
- **Yank**: it is thrown through the air to your feet in an arc, tumbling (Tumble: Spin, Flip, Both or Off).
  Throw Damage hurts it on landing or striking something.
- **Lasso**: it hangs at rope length and follows your arm. Swing it into others; a hard flick of the arm
  throws it that way (Lasso Flick Throw).
- A boss, or anything heavier than Heaviest Pulled, is an anchor: it does not come, you are flung toward it.
- Split Pull by Weight (Slide only): you and the monster share the pull by weight.
- A dangling monster that makes no progress toward you for about 1.5 seconds is dropped.

**The whip.** Whip (off by default) makes the same binds crack a short whip instead of firing the claw: it
hits the first thing in reach, knocks it into its pain state (Whip Stun), and if the tip meets something above
the hand it wraps round it and becomes the rope (Whip Snag). This is the hook's own whip, not RSQ Whip.

**Looks.** Rope Look: Chain (jpalomo's links) or Cable. Look: JP (jpalomo's sounds and claw), Combat FX or
Ballistics (the claw flies as a tracer streak and throws sparks on a wall hit).

## How to play

Bind the keys first. Options -> Customize Controls -> section **RSQ Grapple**: **Fire Hook (Main)**,
**Fire Hook (Off)**, **Grab Rope (Main)**, **Grab Rope (Off)**. Nothing is bound by default. The Grapple's menu
is Options -> Radiant Silvergun Options -> RSQ Grapple.

**Fire.** Point a hand at a wall and press its Fire Hook. The claw flies out along the chain. When it bites you
are thrown at it; hit the wall, land, keep moving. Point high at a wall or at the ceiling over a pit and you
go up and over in an arc. Point at the floor ahead and you slide to the claw. Press again at any time to fire
again. Miss, and a second press while the claw flies calls it back.

**Hook a monster.** Point at it and fire. It is thrown at you and slides to a stop in front of you. A boss or
a very heavy monster does not come: you go to it instead.

**Rope (Wall Hook: Rope).** Fire at a high wall. The rope pulls you straight up to the claw and you hang just
short of it. Tap Fire Hook to drop. Hold it to reel in. Near the top of a wall, a tap hops you over the lip.

**Swing and Momentum (turn it on in the menu).**
1. Fire at something above you and step off the ledge. You hang and swing on the rope.
2. Hold Fire Hook to reel up. Release to hang.
3. Push the stick forward or sideways in time with the swing to pump it. Pull the stick back to calm it.
4. Tap Fire Hook at the top of the swing: you let go and fly on with your speed.

**Climb.** Hanging, reach an empty hand to the rope, hold Grab Rope, and pull down. Let go, reach up with the
other hand, hold, pull. Both hands can hold at once. Push up to lower yourself. RSQ DistanceGrab's grab binds
also take hold of the rope (Grips From Grab).

**Lasso (Monster Hook: Lasso).** Hook a monster. It hangs at rope length and follows your arm. Sweep it into
other monsters; both are hurt. Flick the arm hard to throw it. Tap to drop it.

**Whip (Whip on).** Press Fire Hook: a short lash cracks from the hand along where it points. Hit a monster
and it breaks off its attack. Crack it at a ledge or beam above you and it wraps on; then it is the rope,
swing and reel as usual.

## Settings

Options -> Radiant Silvergun Options -> RSQ Grapple. Presets (Range, Swing Feel, Monster Pull) set the numbers
on the Tuning and Debug page; Standard is the default.

| Menu row | Default | What it does |
|---|---|---|
| Grapple | On | The hook at all. |
| Wall Hook | OG | OG: a one-off fling toward the claw. Rope: pulled to the claw, stop and hang there. |
| Swing and Momentum | Off | On: hang, swing, pump and keep your speed, whatever Wall Hook says. |
| Range | Standard | Short (600), Standard (780), Long (3072). |
| Swing Feel | Standard | Floaty, Standard, Snappy: claw speed, reel speed, swing lean and top speed. |
| Rope Climbing | On | A free hand on Grab Rope climbs the rope. |
| Two Hands on the Rope | On | Both hands may hold the rope at once; the climb is their average. |
| Hook Thump | On | A thump in the hand when the hook bites or the rope catches your fall. |
| Calm Swing (Stick Back) | On | Hanging, the stick pulled back calms the swing in about a second. |
| Slack Rope Lets Go | On | A rope lying slack on the floor for 3 seconds lets go by itself. |
| Hook Switches and Doors | Off | The claw hitting a switch or door uses it and comes back. |
| Aim Dot (Empty Hand) | Off | A faint dot where the claw would bite while an empty hand points. |
| Rope Look | Chain | Chain (jpalomo's links) or Cable. |
| Monster Hook | OG | OG (thrown toward you once), Slide, Yank (through the air in an arc), Lasso (held at rope length). |
| Monster Pull | Standard | Gentle, Standard, Strong: slide speed and the heaviest thing that comes. |
| Split Pull by Weight | Off | Slide only: you and the monster share the pull by weight. |
| Lasso Flick Throw | On | Lasso: a hard flick of the arm throws the held monster that way. |
| Tumble | Spin | Yank only: Off, Spin, Flip, Both. |
| Throw Damage | On | Yank and Lasso: a thrown monster's landing or strike hurts it. |
| Whip | Off | The hook binds crack a whip instead of firing the claw. |
| Look | JP | JP, Combat FX or Ballistics: look and sound set. |
| Score Stunts | On | A gap crossed on the rope pays RSQ Score's "Indiana Jones". |

**Tuning and Debug** (every number; "Reset All" at the bottom puts everything back)

| Menu row | Default | What it does |
|---|---|---|
| Range | 780 | How far the claw reaches before it comes back. |
| Hook Speed | 40 | Claw flight, units a tic. |
| Reel Speed | 12 | Rope taken in per tic while the bind is held. |
| Swing Lean | 0.25 | How hard the stick leans a swing. |
| Top Speed | 30 | Speed cap on the rope and on a yank. |
| Monster Pull | 10 | How fast a hooked monster slides to you. |
| Heaviest Pulled | 1000 | Heavier than this (or a boss) is an anchor and does not come. |
| Chain Links | 160 | Most chain links per rope. |
| Link Size | 0.125 | Chain link size. |
| Rope Pieces | 12 | Most pieces a slack rope is drawn in. |
| Rope Thickness | 0.6 | Rope radius, map units. |
| Shortest Rope | 32 | Shortest rope when reeled all the way in. |
| Rope Height | 0.6 | Where the rope meets the body, as a fraction of your height. |
| Air Drag | 0.002 | Share of swing speed lost per tic. |
| Rope Friction | 0.025 | A constant loss that brings the swing to rest. |
| Ledge Hop | 6 | Lift when letting go at the top of a wall. |
| Keep Momentum | On | A swing keeps its speed when you land. |
| Return Speed | 64 | The claw coming back. |
| Tap to Let Go (tics) | 8 | A press released within this is a tap (let go); held longer, it reels. |
| Stop Distance | 16 | How far from you a sliding monster stops. |
| Free Hand Only | On | Only an empty hand may climb, never a gun hand. |
| Grips From Grab | On | RSQ DistanceGrab's grab binds take hold of the rope too. |
| Grab Reach | 16 | How near the rope the hand must be to take hold. |
| Climb Speed Cap | 8 | Most the body moves per tic by the hand. |
| Heaviest Thrown | 1000 | Heaviest monster the Yank throws; heavier slides. |
| Throw Air | 0.27 | Gravity on a yanked monster once it flies on its own, times Doom's. |
| Throw Turns | 1 | Whole tumbles over the flight. |
| Throw Stun | 8 | Tics a yanked monster stays in its pain frame after landing. |
| Lasso Speed | 24 | Fastest a held monster follows your arm. |
| Whip Reach | 192 | Whip reach from the hand. |
| Whip Damage | 12 | Whip damage. |
| Whip Stun | On | A whip hit knocks the monster into its pain state. |
| Whip Snag | On | The whip tip wraps round something above the hand and becomes the rope. |
| Debug Log | Off | Log every hook tic to the console. |

## Works with

- **RSQ DistanceGrab:** its grab binds take hold of the rope (Grips From Grab). The Yank's arc is
  DistanceGrab's flight path.
- **RSQ SlowMo:** a sliding monster moves at the slowed world speed. Your own hook, rope and swing run in real
  time.
- **RSQ Score:** a gap crossed on the rope pays "Indiana Jones" (Score Stunts). Score also reads the hook's
  events through RSQGR_Service (bites, rehooks after a monster was knocked away, bowling strikes).
- **RSQ HP Bars:** reads "hooked" and "stunned" from RSQGR_Service for its markers over hooked and stunned
  monsters.
- **RSQ Miniboss:** with Miniboss's "Can't Be Yanked" on, a miniboss is too heavy to come, as a boss is: the
  hook flings you to it.
- **RSQ Melee:** needed by the Scorpion upgrade (below).
- **RSQ Whip:** loads beside it; separate binds and settings.
- **RSQ Accessibility:** Hold to Toggle on the hook binds (press to fire and hold on, press again to let go).
  Steady Hands fires the hook along the smoothed hand and the aim dot follows it; the climb, rope and lasso
  stay on the raw hand. Slower Taps makes Tap to Let Go 1.5x longer. Gesture Ease widens Grab Reach. Rumble
  Strength 0 removes the bite thump. One-Handed's Off-Hand Modifier fires the off hook from the main hand.
  Colour-blind palette on its cues. Inert without it.

**Gun Bonsai VR (RSQ_GunBonsaiVR):** with the patch loaded the hook fires only once the **Grapple** node is
learned, and **Momentum** is the Swing and Momentum option as an unlock. From them hang Long Line (range +20% a
level), Fast Reel (the claw, the OG fling and the OG throw 10% faster a level), Barbed Claw (the bite and the
tear-out hurt), Heavy Haul (heavier and bigger things come; a boss on the line is staggered), Get Over Here
(what arrives is staggered), Bowling (what arrives strikes what is in its way), Double Hook (a monster on each
hook slammed together), Slingshot (letting go of a swing carries more speed), Steady Line (the hang settles
faster), Zip Kick (arriving on a monster by the rope at 3 m/s or more hurts it), Scorpion (needs RSQ Melee:
what the hook brings to you is punched by your empty fist as a counter) and Twin Lines (a wall rope from each
hand at once; at 2, letting one go flings you along the other). Without the patch nothing changes.

## Load order

After Brutal Doom and the monster packs, after Gun Bonsai and RSQ_GunBonsaiVR, beside the other RSQ pk3s.
Works on plain Doom 2 without Brutal Doom.

## Known limits

- A boss, or anything over Heaviest Pulled, never comes; you are flung toward it instead. jpalomo's original
  threw even a Cyberdemon.
- Rope mode: hanging, you stay where the pull stopped, at any angle. The stick does nothing during the pull or
  the hang. Two ropes out at once pull you between their two points.
- Rope mode: stopped against the face of a wall below its top, you hang there. The Ledge Hop is the only help
  over a lip; there is no mantle.
- The rope does not wrap round corners: swing round one and it slips and lets go.
- The claw sprite is jpalomo's 15-unit claw: large right at the hand at launch.
- jpalomo's art and sounds are slated for replacement (see Credits).

## For other mods

`RSQGR_Service` (find it by name with `ServiceIterator`; absent is -1 / null). GetInt, objectArg the player's
pawn (intArg hand, 0 main / 1 off, where it applies) or the monster:

- Player: `hook.phase`, `swinging`, `reeling`, `climbing`, `airborne`, `released`, `landed`, `rope.speed`,
  `released.speed`, `flight.dist`, `flight.drop`, `gaps`.
- Monster: `hooked`, `hooked.by`, `hooked.heavy`, `bites`, `volleys`, `yanked`, `landing`, `struck`,
  `struck.by`, `pin`, `whipped`, `stunned`.
- Gun Bonsai VR's ledger (pawn): `xp.bites`, `xp.yanks`, `xp.kills`, `xp.killhp`, `xp.slams`, `xp.swing`,
  `hook.dealing`.
- GetObject: `hook.victim` (pawn, hand), `hooked.by` (monster), `struck.ball` (monster).

Everything that hurts is noted before the blow lands, so a scorer reading inside WorldThingDied sees it.

It asks other mods by name: `RS_ScoreService` ("award" Indiana Jones, "touch" scorpion), `RSQSM_Service`
("scale"), `RSQMB_Service` ("bossfor" yank), `RSQA_Service`, `RSQ_MeleeUpgradeService` ("plevel", "stagger"),
`RSQML_Service` ("autopunch").

## Credits

The hook's art and sound are jpalomo's, from the grappling hook in his mod pack
(jp_grapple.pk3, kept unmodified in jp_original/ of the source repo):
  - claw sprites OCLW (open) and CCLW (shut), shipped here as RSGH / RSGK
  - chain link tenda0 (the 40 px hires version), shipped here as RSGR
  - sounds dschain, dsswish, dspulchn, dsmtalht, dsmeatht, shipped here as
    RSGCHAIN, RSGSWISH, RSGPULCH, RSGMETAL, RSGMEAT
  - the OG wall and monster modes (the defaults) reproduce his Hook_HitWall and
    Hook_HitEnemy thrusts (hook.acs) and his HookShot's flight, number for number.
Thank you, jpalomo.

SLATED FOR REPLACEMENT: this hook is the series' own rebuild, so its look and sound
should be ours too. jpalomo's art and sounds stay as the default until replacements are made from
the owner's RS_CombatFX library (and other cleared sources); then the JP set becomes optional or goes.

Code: ZScript written for the Radiant Silvergun Quest series (presidentkoopa), for
stock QuestZDoom 17.3 by Emawind84 and Team Beef. No engine change.

Monster side (the throw, the whip, the look sets):
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

`jp_original/` is the source material: jp_grapple.pk3 (the hook from jpalomo's mod pack, parent missing), kept
unmodified for its art (OCLW/CCLW claw, tenda0) and sounds (dschain, dsswish, dspulchn, dsmtalht, dsmeatht). It
is not loaded as-is.
