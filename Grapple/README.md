# RSQ Grapple

A grappling hook in each hand: aim it with your real arm, fire, and fling yourself across the map or drag monsters
to your feet.

> **Waiting on Grapple 2.0.** This page describes the Grapple as it is today. Its known bugs and the next version are
> held for the Grapple 2.0 update (owner, 2026-11-10; `design/PLANNED_PROJECTS.md`). A new page is drafted
> (`README_draft.md`) and waits for 2.0 too.

**Status:** rig only, not headset-confirmed (older builds, 10-27 to 11-03, logs in `test/evidence/`; and a clean load
on the full series order on 11-09 and 11-10). The one Fire Hook key and Fire Hook From (11-10): code only, not shown.
Nothing is headset-confirmed: the owner played earlier builds in his headset, but the repo records no feature confirmed
working there.

New on 11-06 (the commit says a rig log showed it; that log is not in the repo, so: code only, not shown): the Rope wall
hook pulls at jp_grapple's speed and lets go when you arrive; hanging, climbing and mantling are Swing and Momentum's.

Two hooks, one per controller, each fired along the exact line your hand points. Out of the box it plays like
jpalomo's classic jp_grapple, rebuilt number for number. Turn on Swing and Momentum and it becomes a full rope: hang from it,
swing on it, pump it with the stick, climb it hand over hand, wrap it round corners and mantle over ledges.
All of it is ZScript on stock QuestZDoom 17.3. No engine changes.

## Standout feature: climbing the rope hand over hand

Turn on Swing and Momentum, fire at a high ledge and hang. Reach up with an empty
hand, take hold of the rope (RSQ Distance Grab's grab keys) and pull down. Your body rises by exactly how far your hand moved. Let go, reach up with the
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
- **Rope wall hook:** the rope pulls you straight to the claw at jp_grapple's speed (the distance / 12 map units a tic,
  so any gap takes about a third of a second) and lets go the moment you arrive. None of the pull's speed is kept.
- **Swing and Momentum (optional, off):** a real pendulum. Hang, swing, pump with the stick, keep your speed when
  you let go or land.
- Fire a second time while the claw is still flying to call it back.
- **Hook Thump:** a thump in your hand when the claw bites or the rope catches you.

**On the rope (Swing on; Wraps Corners also in Rope mode)**
- **Climb hand over hand** with a free hand on the rope (taken with RSQ Distance Grab's grab keys). Both hands at once.
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
- **Whip (optional, off):** the Fire Hook key cracks a short whip. It hits the first thing in reach and knocks it out
  of its attack. Crack it at something above you and it wraps round and becomes a rope.
- **Hook Switches and Doors (optional, off):** the claw uses a switch or door it hits, with the map's own rules.
- **Aim Dot (optional, off):** a faint dot where the claw would bite, while an empty hand points.
- **Rope look:** jpalomo's chain links (default) or a smooth cable.
- **Look sets:** JP (jpalomo's art and sounds, default), Combat FX or Ballistics.
- **Score stunts:** with RSQ Score loaded, swinging across a gap pays Indiana Jones points.

## How To Play

1. **Bind the hook.** There is no default bind. Open Options → Customize Controls, find the **RSQ Grapple**
   section and bind **Fire Hook** (one key since 11-10; **Fire Hook From** on the page picks the hand, the off hand
   by default). Stick clicks work well. To climb, close the controller's grip on the rope, or just hold an empty hand
   still on it (Touch Holds Rope); RSQ Distance Grab's grab keys work too. Grapple's own Grab Rope keys went 11-10.
2. **First swing (OG):** point at a wall across a gap and press Fire Hook. The claw bites and flings you toward
   it. Aim a little high to clear the gap.
3. **Pull monsters:** fire at an imp. It is thrown to your feet. Heavy monsters pull you to them instead.
4. **Try the rope:** set Wall Hook to Rope. Fire at a ledge above you. The rope pulls you up fast and lets go when
   you get there. To hang, turn on Swing and Momentum: hold the button to reel in, tap it to drop, reach up with an
   empty hand, grip the rope (or hold the hand still on it) and pull down to climb, push the stick forward under the lip to mantle.
5. **Master the swing:** turn on Swing and Momentum. Fire at a ceiling, step off a ledge and lean into the swing
   with the stick. Let go at the top of the arc to fly. Pull the stick back to calm it down.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Fire hook | Fire Hook (the hand set by Fire Hook From, off hand by default) | Fires from that controller along where it points. No default bind. |
| Recall a miss | Press again while the claw is flying | |
| Reel in | Hold Fire Hook while latched | Swing mode. Holding from the shot reels at once. |
| Let go | Tap Fire Hook (release within 8 tics) while latched | Swing mode (or Rope mode, before you arrive; it lets go by itself on arrival). |
| Take hold of the rope | An empty hand on the rope, then one of: that controller's **grip**; RSQ Distance Grab's grab key for that hand; or **touch**: keep the hand still on the rope a moment (6 tics, under 0.4 m/s), no button | Within 16 map units of the rope. The grip is read by key code (Main / Off Grip Keys, 446 and 443 436). Distance Grab's keys need Grab Keys Hold Rope on. Touch needs Touch Holds Rope on, a hand at least 0.3 m out along the rope from your body, and a hand that came to the rope (one already lying on it when the hook bit doesn't count). |
| Climb | Holding the rope, pull down; push up to lower | |
| Let go of the rope | Let go of the grip or the grab key; a touch hold lets go when the hand moves about 1 m (twice Grab Reach) off the rope | A key's hold and a touch hold are separate: letting go of the key never drops a touch hold, and the reverse. After a key's hold the hand must leave the rope before touch takes it again. |
| Pump a swing | Movement stick | Swing mode, in the air. |
| Calm a swing | Stick pulled back past half | |
| Mantle | Stick forward while hanging under a lip | |
| Lasso flick | A hard flick of the arm (3 m/s) | Lasso mode. Throws the held monster that way. |
| Whip | Fire Hook | Only with Whip on. |

**Keys:** one, **Fire Hook** (Options → Customize Controls → RSQ Grapple, or the page's Controls). No default bind. On
11-10 it replaced four keys: Fire Hook (Main), Fire Hook (Off), Grab Rope (Main) and Grab Rope (Off). Which hand
fires is the menu row **Fire Hook From** (Off Hand by default, or Main Hand). The rope is taken with the controller's
grip, RSQ Distance Grab's grab keys, or by touch (an empty hand held still on it). The trigger and Use are not read. The gestures are the Lasso's arm flick and the touch hold. Left-handed
play works: the engine's left-handed scheme swaps which controller is main.

## Menu

Options → Radiant Silvergun Options → RSQ Grapple. One page; the raw numbers are on **Test and Debug**; **Reset All**
at the foot resets both. Greyed rows keep their setting but do nothing in the current mode: Wraps Corners needs Wall
Hook "Rope" or Swing and Momentum on (OG makes no rope); the climbing rows, Mantle, Calm Swing, Slack Rope Lets Go and
Keep Momentum need Swing and Momentum (the Rope wall hook lets go on arrival, so it is never hung from); the Monsters rows need their Monster Hook mode; the Whip rows need Whip Instead of Hook. With RSQ Gun
Bonsai VR loaded the page's top line reads "GunBonsaiOVR detected. Mod features unlocked via upgrades." and Grapple
and Swing and Momentum stay greyed until their nodes (Grapple, Momentum) are learned. Learning one turns its row on;
the row can still turn it off.

| Row | Default | What it does |
|---|---|---|
| Grapple | On | The hook is available. With Gun Bonsai VR: once its Grapple node is learned. |
| Wall Hook | OG | OG: a one-off fling toward the claw. Rope: pulled to the claw at jp_grapple's speed, let go on arrival. |
| Swing and Momentum | Off | The swinging rope that keeps your speed, whatever Wall Hook says. With Gun Bonsai VR: once its Momentum node is learned. |
| Range | 780 | How far the claw reaches, map units. |
| Hook Thump | On | A thump in the hand on a bite or a catch. |
| Aim Dot | Off | A faint dot where the claw would bite. |
| Hook Uses Switches | Off | The claw uses switches and doors it hits. |
| Score Stunts | On | Gap crossings pay RSQ Score's Indiana Jones. |
| **Rope** | | |
| Rope Climbing | On | A free hand holding the rope (the grip, Distance Grab's grab keys, or touch) climbs. |
| Two Hands on Rope | On | Both hands may hold at once. Off: a new hand takes over. |
| Empty Hand Only | On | Only an empty hand may climb. |
| Grab Keys Hold Rope | On | RSQ Distance Grab's grab keys take hold of the rope (the controller's grip always does). |
| Touch Holds Rope | On | An empty hand held still on the rope a moment takes it, no button; it lets go about 1 m off the rope. |
| Wraps Corners | On | The rope bends round corners. |
| Mantle Over Ledges | On | Stick forward under a lip climbs over it. |
| Calm Swing | On | Stick back brakes a swing (Swing and Momentum). |
| Slack Rope Lets Go | On | A slack rope on the floor lets go after 3 seconds (Swing and Momentum). |
| Keep Momentum | On | A swing keeps its speed when you land (Swing and Momentum). |
| Rope Look | Chain | Chain links or a cable. |
| **Monsters** | | |
| Monster Hook | OG | OG, Slide, Yank or Lasso. |
| Split Pull by Weight | Off | Slide: share the pull by weight. |
| Lasso Flick Throw | On | Lasso: a hard flick throws the monster. |
| Tumble | Spin | Yank and Lasso: how a thrown monster turns in the air: Off, Spin, Flip, Both. |
| Throw Damage | On | Yank and Lasso: a thrown monster is hurt by its landing or what it hits. |
| Art and Sound | JP | JP, Combat FX or Ballistics art and sound. |
| **Whip** | | |
| Whip Instead of Hook | Off | The Fire Hook key cracks a whip instead of firing the claw. |
| Whip Stun | On | A crack knocks the monster into pain. |
| Whip Snag | On | The tip wraps round things above your hand (the rope). |
| **Controls** | | |
| Fire Hook | Unbound | The one hook key (also in Customize Controls, "RSQ Grapple"). |
| Fire Hook From | Off Hand | Which hand Fire Hook fires from: Main Hand or Off Hand. Your own setting. |
| Test and Debug | | The page below. |
| Reset All | | Every setting on both pages back to its default. |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| **Hook** | | |
| Hook Speed | 40 | Claw flight speed, units per tic. |
| Return Speed | 64 | How fast the claw comes back. |
| Tap to Let Go (tics) | 8 | A press shorter than this is a tap. |
| **Rope** | | |
| Reel Speed | 12 | Rope taken in per tic while reeling (and the lasso's reel). |
| Shortest Rope | 32 | Rope length when fully reeled. |
| Rope Height | 0.60 | Where the rope meets your body, share of your height. |
| Ledge Hop | 6 | Lift when letting go at the top of a wall. |
| Grab Reach | 16 | How close the hand must be to the rope. |
| Climb Speed Cap | 8 | Most the body moves per tic by hand. |
| Top Speed | 30 | Speed cap on the rope and on a yank. |
| Swing Lean | 0.25 | How hard the stick pumps a swing. |
| Air Drag | 0.002 | Swing speed lost to air each tic. |
| Rope Friction | 0.025 | A small constant loss that settles a swing. |
| **Rope Look** | | |
| Chain Links | 160 | Most chain links per rope. |
| Link Size | 0.125 | Size of each link. |
| Rope Pieces | 12 | Pieces a slack cable is drawn in. |
| Rope Thickness | 0.6 | Cable thickness. |
| **Monsters** | | |
| Heaviest Pulled | 1000 | Heavier monsters (and bosses) are anchors. |
| Slide Speed | 10 | How fast a sliding monster comes. |
| Stop Distance | 16 | A pulled monster stops this far from you. |
| Heaviest Thrown | 1000 | Heaviest monster the Yank and Lasso throw. |
| Widest Thrown | 64 | Widest monster (radius) they throw. |
| Tallest Thrown | 110 | Tallest monster they throw. |
| Throw Air | 0.27 | Gravity on a thrown monster in free flight, share of Doom's. |
| Throw Turns | 1 | Whole turns over a throw. |
| Throw Stun | 8 | Tics a thrown monster stays stunned after landing. |
| Lasso Speed | 24 | Fastest a lassoed monster follows your arm. |
| **Whip** | | |
| Whip Reach | 192 | Whip length, map units. |
| Whip Damage | 12 | Damage of a crack. |
| Snag Height | 16 | How far above the hand the tip must hit to snag. |
| Debug Log | Off | Logs every hook tic to the console. |

## Works with

RSQ Grapple runs alone. It finds the other mods by name, so load order among RSQ pk3s does not matter.

- **RSQ Gun Bonsai VR (with Gun Bonsai):** the hook becomes something you earn. It does not fire until the
  Grapple node is learned (a press before then says "Grapple: learn it in Gun Bonsai"), and the Momentum node unlocks
  the Swing and Momentum row (learning turns the row on; the row can still turn it off). Upgrades: Long Line (range), Fast Reel (faster claw and harder yank), Heavy Haul (pull heavier monsters, stagger bosses), Get
  Over Here (what comes to you arrives staggered), Bowling (what comes to you strikes what is in its way), Barbed
  Claw (the bite hurts), Slingshot (faster release from a swing), Steady Line (a still swing settles faster),
  Double Hook (two hooked monsters slammed together), Zip Kick (arriving fast on a monster hurts it), Scorpion
  (an empty fist punches what the hook brings in; needs RSQ Melee) and Twin Lines (two wall ropes at once). The
  hook earns its own XP.
- **RSQ Distance Grab:** its grab keys are how you take hold of the rope (none bound by default).
- **RSQ SlowMo:** you and the claw stay at full speed while hooked monsters move at the slowed world's pace.
- **RSQ Score:** Indiana Jones points for gap crossings, plus the hook's stunts for its scoring.
- **RSQ Miniboss:** a miniboss set to "Can't Be Yanked" is treated as a boss: an anchor.
- **RSQ VisualRewards:** HP bars show when a monster is hooked or stunned by the hook.
- **RSQ Accessibility (its gesture reader)** and **RSQ Melee:** no gestures or melee swings are read while you climb, swing or reel.
- **RSQ Accessibility:** Steady Hands smooths the aim and the aim dot. Hold to Toggle latches the Fire Hook key.
  Slower Taps lengthens the tap window. One-Handed's Off-Hand Modifier lets the main controller fire the off hook. Gesture Ease
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
