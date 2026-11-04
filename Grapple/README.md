# RSQ Grapple

A grappling hook in each hand: aim it with your real arm, fire, and fling yourself across the map or drag monsters
to your feet.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

Two hooks, one per controller, each fired along the exact line your hand points. Out of the box it plays like
jpalomo's classic jp_grapple, rebuilt number for number. Switch modes and it becomes a full rope: hang from it,
swing on it, pump it with the stick, climb it hand over hand, wrap it round corners and mantle over ledges.
All of it is ZScript on stock QuestZDoom 17.3. No engine changes.

## Standout feature: climbing the rope hand over hand

Set the wall hook to Rope (or turn on Swing and Momentum), fire at a high ledge and hang. Reach up with an empty
hand, hold Grab Rope and pull down. Your body rises by exactly how far your hand moved. Let go, reach up with the
other hand, take hold, pull again. Push down to lower yourself. Both hands can hold the rope at once, and the climb
follows their average, so it stays smooth. Only an empty hand takes hold: a climb never takes a gun out of your
hand. The rope is drawn running through your upper hand. When you reach the lip, push the stick forward and you
mantle up and over.

## Features

**The hook**
- One hook per hand, fired from the controller along where it points. A hand pushed through a wall fires from
  your eye instead.
- **OG wall hook (default):** jpalomo's fling. The claw bites and throws you toward it in one burst; your momentum
  carries you on.
- **Rope wall hook:** the rope pulls you straight to the claw and you stop there, hanging if you are in the air.
  Hold to reel in, tap to let go.
- **Swing and Momentum (optional, off):** a real pendulum. Hang, swing, pump with the stick, keep your speed when
  you let go or land.
- Fire a second time while the claw is still flying to call it back.
- **Hook Thump:** a thump in your hand when the claw bites or the rope catches you.

**On the rope (Rope mode or Swing on)**
- **Climb hand over hand** with a free hand on Grab Rope. Both hands at once.
- **Mantle:** hanging under a lip, push the stick forward to go up and over.
- **Rope wraps corners:** swing past a corner and the rope bends round it instead of snapping.
- **Calm swing (Swing on):** pull the stick back to brake a swing in about a second.
- **Ledge hop:** let go near the top of a wall and you get a small hop over the lip.
- **Slack rope lets go:** a rope lying slack on the floor for 3 seconds releases itself.

**Monsters**
- **OG monster hook (default):** jpalomo's throw. A hooked monster is yanked toward you in one burst.
- **Slide:** it slides along the floor to your feet.
- **Yank:** it flies to you on an arc, tumbling, and lands stunned. Throw damage from its speed.
- **Lasso:** it hangs at rope length and follows your arm. A hard flick throws it.
- Anything over 1000 mass, or any boss, is too heavy to come. It becomes an anchor and you go to it.
- **Split Pull (optional, Slide mode):** the pull is shared by weight. You go part of the way, it comes the rest.

**Extras**
- **Whip (optional, off):** the same binds crack a short whip. It hits the first thing in reach and knocks it out
  of its attack. Crack it at something above you and it wraps round and becomes a rope.
- **Hook Switches and Doors (optional, off):** the claw uses a switch or door it hits, with the map's own rules.
- **Aim Dot (optional, off):** a faint dot where the claw would bite, while an empty hand points.
- **Rope look:** jpalomo's chain links (default) or a smooth cable.
- **Look sets:** JP (jpalomo's art and sounds, default), Combat FX or Ballistics.
- **Score stunts:** with RSQ Score loaded, swinging across a gap pays Indiana Jones points.

## How To Play

1. **Bind the hooks.** There are no default binds. Open Options → Customize Controls, find the **RSQ Grapple**
   section and bind Fire Hook (Main) and Fire Hook (Off). Stick clicks work well. Bind Grab Rope (Main) and
   Grab Rope (Off) to your grips if you want to climb (or use RSQ Distance Grab's grab binds, which also take
   hold of the rope).
2. **First swing (OG):** point at a wall across a gap and press Fire Hook. The claw bites and flings you toward
   it. Aim a little high to clear the gap.
3. **Pull monsters:** fire at an imp. It is thrown to your feet. Heavy monsters pull you to them instead.
4. **Try the rope:** set Wall Hook to Rope. Fire at a ledge above you. The rope pulls you up and you hang. Hold
   the button to reel in, tap it to drop. Reach up with an empty hand, hold Grab Rope and pull down to climb.
   Push the stick forward under the lip to mantle.
5. **Master the swing:** turn on Swing and Momentum. Fire at a ceiling, step off a ledge and lean into the swing
   with the stick. Let go at the top of the arc to fly. Pull the stick back to calm it down.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Fire hook | Fire Hook (Main) or Fire Hook (Off) | Fires from that controller along where it points. No default bind. |
| Recall a miss | Press again while the claw is flying | |
| Reel in | Hold the fire bind while latched | Rope or Swing mode. Holding from the shot reels at once. |
| Let go | Tap the fire bind (release within 8 tics) while latched | Rope or Swing mode. |
| Climb | Hold Grab Rope with an empty hand touching the rope, pull down; push up to lower | Within 16 map units of the rope. Distance Grab's binds also work. |
| Pump a swing | Movement stick | Swing mode, in the air. |
| Calm a swing | Stick pulled back past half | |
| Mantle | Stick forward while hanging under a lip | |
| Lasso flick | A hard flick of the arm (3 m/s) | Lasso mode. Throws the held monster that way. |
| Whip | Fire binds | Only with Whip on. |

Key binds (Options → Customize Controls → RSQ Grapple): Fire Hook (Main), Fire Hook (Off), Grab Rope (Main),
Grab Rope (Off). Left-handed play works: the engine's left-handed scheme swaps which controller is main.

## Menu

Options → Radiant Silvergun Options → RSQ Grapple

| Row | Default | What it does |
|---|---|---|
| Grapple | On | The hook is available. |
| Wall Hook | OG | OG: a one-off fling toward the claw. Rope: pulled to the claw, then hang. |
| Swing and Momentum | Off | The swinging rope that keeps your speed, whatever Wall Hook says. |
| Range | Standard | How far the claw reaches: Short, Standard (780), Long. |
| Swing Feel | Standard | Floaty, Standard or Snappy: claw speed, reel, lean and top speed together. |
| Rope Climbing | On | A free hand on Grab Rope climbs. |
| Two Hands on the Rope | On | Both hands may hold at once. Off: a new hand takes over. |
| Hook Thump | On | A thump in the hand on a bite or a catch. |
| Calm Swing (Stick Back) | On | Stick back brakes a swing. |
| Slack Rope Lets Go | On | A slack rope on the floor lets go after 3 seconds. |
| Rope Wraps Corners | On | The rope bends round corners. |
| Mantle (Stick Forward) | On | Stick forward under a lip climbs over it. |
| Hook Switches and Doors | Off | The claw uses switches and doors it hits. |
| Aim Dot (Empty Hand) | Off | A faint dot where the claw would bite. |
| Rope Look | Chain | Chain links or a cable. |
| Monster Hook | OG | OG, Slide, Yank or Lasso. |
| Monster Pull | Standard | Gentle, Standard or Strong: slide speed and heaviest monster pulled. |
| Split Pull by Weight | Off | Slide mode: share the pull by weight. |
| Lasso Flick Throw | On | A hard flick throws a lassoed monster. |
| Tumble | Spin | How a yanked monster turns in the air: Off, Spin, Flip, Both. |
| Throw Damage | On | A yanked monster is hurt by its landing or what it hits. |
| Whip | Off | The binds crack a whip instead of firing the claw. |
| Look | JP | JP, Combat FX or Ballistics art and sound. |
| Score Stunts | On | Gap crossings pay RSQ Score's Indiana Jones. |

**Tuning and Debug** holds every number:

| Row | Default | What it does |
|---|---|---|
| Range | 780 | Claw reach, map units. |
| Hook Speed | 40 | Claw flight speed, units per tic. |
| Reel Speed | 12 | Rope taken in per tic while reeling. |
| Swing Lean | 0.25 | How hard the stick pumps a swing. |
| Top Speed | 30 | Speed cap on the rope. |
| Monster Pull | 10 | How fast a sliding monster comes. |
| Heaviest Pulled | 1000 | Heavier monsters are anchors. |
| Chain Links | 160 | Most chain links per rope. |
| Link Size | 0.125 | Size of each link. |
| Rope Pieces | 12 | Pieces a slack cable is drawn in. |
| Rope Thickness | 0.6 | Cable thickness. |
| Shortest Rope | 32 | Rope length when fully reeled. |
| Rope Height | 0.60 | Where the rope meets your body, share of your height. |
| Air Drag | 0.002 | Swing speed lost to air each tic. |
| Rope Friction | 0.025 | A small constant loss that settles a swing. |
| Ledge Hop | 6 | Lift when letting go at the top of a wall. |
| Keep Momentum | On | A swing keeps its speed when you land. |
| Return Speed | 64 | How fast the claw comes back. |
| Tap to Let Go (tics) | 8 | A press shorter than this is a tap. |
| Stop Distance | 16 | A sliding monster stops this far from you. |
| Free Hand Only | On | Only an empty hand may climb. |
| Grips From Grab | On | RSQ Distance Grab's grab binds take hold of the rope. |
| Grab Reach | 16 | How close the hand must be to the rope. |
| Climb Speed Cap | 8 | Most the body moves per tic by hand. |
| Heaviest Thrown | 1000 | Heaviest monster the Yank throws. |
| Throw Air | 0.27 | Gravity on a yanked monster in free flight, share of Doom's. |
| Throw Turns | 1 | Whole turns over a yank. |
| Throw Stun | 8 | Tics a yanked monster stays stunned after landing. |
| Lasso Speed | 24 | Fastest a lassoed monster follows your arm. |
| Whip Reach | 192 | Whip length, map units. |
| Whip Damage | 12 | Damage of a crack. |
| Whip Stun | On | A crack knocks the monster into pain. |
| Whip Snag | On | The tip wraps round things above your hand. |
| Debug Log | Off | Logs every hook tic to the console. |
| Reset All | — | Puts every setting back to its default. |

## Works with

RSQ Grapple runs alone. It finds the other mods by name, so load order among RSQ pk3s does not matter.

- **RSQ Gun Bonsai VR (with Gun Bonsai):** the hook becomes something you earn. It does not fire until the
  Grapple node is learned, and the Momentum node takes the place of the Swing and Momentum row. Upgrades: Long
  Line (range), Fast Reel (faster claw and harder yank), Heavy Haul (pull heavier monsters, stagger bosses), Get
  Over Here (what comes to you arrives staggered), Bowling (what comes to you strikes what is in its way), Barbed
  Claw (the bite hurts), Slingshot (faster release from a swing), Steady Line (a still swing settles faster),
  Double Hook (two hooked monsters slammed together), Zip Kick (arriving fast on a monster hurts it), Scorpion
  (an empty fist punches what the hook brings in; needs RSQ Melee) and Twin Lines (two wall ropes at once). The
  hook earns its own XP.
- **RSQ Distance Grab:** its grab binds also take hold of the rope.
- **RSQ SlowMo:** you and the claw stay at full speed while hooked monsters move at the slowed world's pace.
- **RSQ Score:** Indiana Jones points for gap crossings, plus the hook's stunts for its scoring.
- **RSQ Miniboss:** a miniboss set to "Can't Be Yanked" is treated as a boss: an anchor.
- **RSQ VisualRewards:** HP bars show when a monster is hooked or stunned by the hook.
- **RSQ Gestures** and **RSQ Melee:** no gestures or melee swings are read while you climb, swing or reel.
- **RSQ Accessibility:** Steady Hands smooths the aim and the aim dot. Hold to Toggle latches the fire bind.
  Slower Taps lengthens the tap window. One-Handed lets the main controller fire the off hook. Gesture Ease
  widens Grab Reach. The Comfort Vignette reacts to rope speed. Rumble Strength scales the thump.
- **Brutal Doom / BD22 VR Reloaded:** BD22 VR's fists count as an empty hand for climbing.

## Credits and licence

The hook's art and sound are jpalomo's, from the grappling hook in his mod pack (jp_grapple.pk3):
- claw sprites OCLW (open) and CCLW (shut), shipped here as RSGH / RSGK
- chain link tenda0 (the 40 px hires version), shipped here as RSGR
- sounds dschain, dsswish, dspulchn, dsmtalht, dsmeatht, shipped here as RSGCHAIN, RSGSWISH, RSGPULCH, RSGMETAL,
  RSGMEAT
- the OG wall and monster modes (the defaults) reproduce his Hook_HitWall and Hook_HitEnemy thrusts and his
  HookShot's flight, number for number.

Thank you, jpalomo.

Code: ZScript written for the Radiant Silvergun Quest series by presidentkoopa, for stock QuestZDoom 17.3 by
Emawind84 and Team Beef. No engine changes.

The Yank is RSQ Distance Grab's pull path ported number for number (its path, arc, timing, tumble, air gravity,
arc measuring, voxel table and voxel turn fix): presidentkoopa's RS_WorldHands design.

Look sets, all presidentkoopa's own libraries:
- Combat FX: RS_CombatFX's shared draw (WEAPDRAW), holster x3 (HOLSTR, HOLSTR2, HOLSTR3) and unsorted foley x3
  (FOLEY1-3), shipped as RSGXDRAW, RSGXHOL1-3, RSGXFOL1-3.
- Ballistics: RS_Ballistics' near-miss whiz x4 (whizby1/5/9/14) and near crack x2 (bullet_crack_near_01/04),
  shipped as RSGBWZ1-4 and RSGBCRK1-2, and its tracer mesh (btracer.obj/.png, shipped as models/rsqgr/btracer.*).
- RSGBA0 is a 1x1 transparent placeholder: the sprite name the tracer mesh is bound to.
