# RSQ ShieldSaw

`pk3/RSQ_ShieldSaw.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3.

## What it is

A shield that is also a throwable saw disc, in your off hand. It stops what crosses its face: fireballs are
turned before they reach you, bullets are stopped at the muzzle and sent back, claws and blasts are caught on
contact. Drive it forward to bash. Hold the off trigger and the blades come out and the saw revs. Let go while
your arm snaps forward and it flies, visits the targets you locked, and comes back. It is the shield saw from
*Doom: The Dark Ages*, brought to Doom VR first by Ermac in Rusted Legacy; this mod started from his version
and re-implements it as a standalone off-hand mod. No engine change, no player class replaced.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
`RSQ_ShieldSaw.pk3`

- **Needs no other RSQ pk3.**
- **Plain Doom 2 without Brutal Doom:** works. Brutal Doom's hands class is looked up by name at run time, never
  required; earlier rig rounds ran on freedoom2 (HANDOFF.md). "BD22 Monsters" (off) is only for Brutal Doom's
  tougher monsters.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ ShieldSaw. Front page, then "Shield Options",
  "Look and Sound", and "Tuning and Debug" (every number, debug switches, "Reset All").
- **You start with it** ("Start With Shield", on), on your back, not in hand ("Start in Hand", off).
- **Where you take it from:** front page, "Take It From": Small of the Back (default), Behind the Neck, Small of
  Back or Neck, or Over the Off Shoulder (the old mount, the default until 2026-10-31).
- **Binds (optional):** Options -> Customize Controls -> section **RSQ ShieldSaw**:
  - **ShieldSaw: draw / put back / recall**: draw or put back from anywhere, or recall a thrown disc.
  - **ShieldSaw: throw along aim**: a backup throw.
  - **ShieldSaw: lock on (hold)**: only needed if "Lock On With" is set to "Lock Key".
  - Nothing else to bind: Use, the off trigger and the off alt are QuestZDoom's own.

## What to do in VR

- **Draw:** reach behind you to the small of your back (default "Take It From") and press Use. Press Use there
  again to put it back. ("Draw With Use", on.) The spot hangs on your body, not your head: look around as you
  reach and it stays where your back is (see "Reach zones").
- **Block:** hold the shield's face toward what is coming.
- **Perfect block:** move the shield into the attack as it lands, instead of holding it still.
- **Bash:** shove the shield forward into a monster.
- **Wall slam:** bash a monster toward a wall.
- **Rev:** hold the off trigger. The blades come out; what touches them is ground.
- **Lock on:** hold Use with the shield away from the mount and sweep it over enemies. A lock mark goes on each
  (the series' diamond: green ring, white centre), a buzz each.
- **Throw:** let go of the off trigger while your arm snaps forward. It flies to the marks in order, or where
  you point.
- **Recall:** press the off trigger while it flies. Catch it as it comes back, or it lands on the mount.
- **Saber over shield:** with RSQ Saber in your main hand, rest the lit blade across the shield's front.

## Features

"On" = on by default (CVARINFO). "Option" = off by default.

Front page:

| Menu row | Default | What it does |
|---|---|---|
| Start With Shield | On | Every player spawns with it. |
| Start in Hand | Off | Start with it drawn. |
| Draw With Use | On | Use at the mount draws and puts back. Off: only the Draw key. |
| Take It From | Small of the Back | Or Behind the Neck, Small of Back or Neck, Over the Off Shoulder. |
| Lock On With | Use | Use (away from the mount), Lock Key, or Throw Button (the old way). |
| Throw Button | Off Trigger | What throws on a flicked release: Off Alt, Either, Off Trigger. |
| Max Locks | 5 | Targets one throw visits. |
| Shield Size | Standard | Preset: Standard, Large, Largest. |
| Throw Feel | Standard | Preset: Easy, Standard, Deliberate. |
| Block Assist | Standard | Preset: Low, Standard, High. |
| Damage | Standard | Preset: Low, Standard, High. |
| Turned Shots Go | Off the Face and My Swing | Or To Shooter, Where I Look, Off the Face. |
| Blocked Melee | Stun and Shove | Or Stun, Nothing. |
| BD22 Monsters | Option | Brutal Doom's monsters: slices up to 250 health, grinds up to 1200. |

Shield Options page:

| Menu row | Default | What it does |
|---|---|---|
| Shield Blocks | On | The block at all. |
| Block While Holstered | Option | A shield on your back still blocks. |
| Double Block Radius | Option | The blocking plate is twice as wide (the shield you see is unchanged). |
| Blocked Projectiles | Returned | Or Cancelled. |
| Turn Shots Early | On | Shots about to cross the plate are turned, even ones that would miss. |
| Muzzle Block | On | A bullet whose line crosses the plate is stopped before it is fired. |
| Return Bullets | On | A stopped bullet goes back out. |
| Perfect Block | On | Plate moving into the attack: faster return, always staggers, rings bright, buzzes twice. |
| Shield Bash | On | Shove the shield: hit, shove, lift. |
| Bash Needs Sight | On | Bash and grind cannot reach through a wall or door. |
| Wall Slam | On | A bashed body that hits a wall takes extra damage and hangs stunned. |
| Hit-Stop | Option | A bash or a perfect block freezes the monster for a beat (4 tics). |
| Perfect Block Slow-Mo | Option | Half a second of slow motion on a perfect block. Needs RSQ SlowMo. |
| Saber Over Shield | On | RSQ Saber's lit blade across the shield widens the block (x1.3). |
| Hit Tiers | On | Thrown disc: weak monsters cut in two, mid-tier ground, heavies turn it away. |
| Catch on Return | On | The disc comes back to your hand. |
| On Manual Store | Fist | What the off hand holds after you put it away: Fist or Previously Held Weapon. |
| Off-Hand Switch | Keep Shield | Or Allow Switch (a weapon switch can take the off hand). |

Look and Sound page: Block Feedback (on), Positional Sound (on), Show Mount (When Needed), Shield on Back (off),
Others See Shield (Netgame Only), Spin Direction (Normal).

Tuning and Debug -> Mount Position: where each spot is and how big its grab is (the numbers below), and Eyes to
Neck.

Tuning and Debug -> Throw and Disc -> Wall Bounces (3): a wall between the thrown disc and its next ringed
target is bounced off (sparks off the wall); it turns to the target when it sees it again, else comes home.
0: the first wall sends it home.

Always on, no row: the lock mark over each locked target is the series' shared diamond, a GREEN outer ring round
a WHITE centre, four animated frames (sprites SSQR ring, SSQC centre). With RSQ Accessibility's colour-blind
modes the ring takes that mode's "locked" colour (azure for protanopia and deuteranopia, cyan for tritanopia,
magenta for high contrast) and the centre stays white. The first target the disc visits has the biggest mark;
"Ring Size" (Tuning and Debug) and Accessibility's Cue Size scale them all.

Always on, no row: the bash's visible burst (a small flash and sparks at the body), and a bash never starts
Brutal Doom's stealth-kill cutscene.

## Reach zones

All numbers are room metres in the BODY's frame, from your eyes as they are when you look straight ahead.
"Off side" is toward your off hand (the left for a right-handed player).

- **The body, not the head.** The spot turns with your body: a snap or smooth turn turns it; turning your head
  does not. Your body turning in the room cannot be seen, so a head held more than 35 degrees round for over a
  second is taken as the body turning and the spot eases round (at most 3 degrees a tic), the RSQ Tactical Rig's
  rule. While your off hand is reaching into the zone that catch-up waits, so looking over your shoulder while
  you reach does not move it. It hangs from your neck (your eyes sit about 9 cm in front of it: "Eyes to Neck",
  an estimate), so turning your head about your neck does not slide it either.
- **The height is your eyes, not the game's.** It hangs from your standing eye height read from the headset (the
  highest it has been lately, easing down 2 cm a second; crouching or sitting for over a second takes it down to
  your head). The game's own eye height is a fixed 1.45 m whatever your height, which put the old spots 15-25 cm
  too low for a standing adult.
- **Small of the Back** (default): a ball of radius 0.30 m (0.60 m across) centred 0.30 m behind your eyes,
  0.10 m to the off side, 0.62 m below them (belt height). Only behind the hip line: the hand must be at least
  0.14 m behind your eyes. Off hand behind you at the belt, anywhere from the spine to behind your off hip.
- **Behind the Neck**: a ball of radius 0.26 m centred 0.22 m behind your eyes, 0.08 m to the off side, 0.18 m
  below them, the hand at least 0.06 m behind your eyes: reach over your off shoulder from the front.
- **Over the Off Shoulder**: as it was until 2026-10-31, only now turning with your body: 0.27 m behind your eyes,
  0.12 m to the off side, 0.36 m below the game's eye height, radius 0.30 m.
- **With RSQ Tactical Rig** (its Use draw on): a hand inside one of the rig's holsters is the rig's press, never
  the shield's, wherever that holster is set.

## Test it

Load only the base order plus `RSQ_ShieldSaw.pk3`. Steps marked **(not yet headset-confirmed)** were only run
on the simulated rig (2026-10-31 onward).

1. Menu: Radiant Silvergun Options -> RSQ ShieldSaw. Pages and rows above are there.
2. Start a map. Reach to the small of your back and press Use: the shield is in your off hand. Press Use there
   again: it goes back. **(the new zone: not yet headset-confirmed)**
2a. Turn your head left and right, and look over your off shoulder, while reaching: Use still draws. With "Show
   Mount: Always" (Look and Sound), the marker stays put while you turn your head; a snap turn carries it round.
   **(not yet headset-confirmed)**
3. Stand in front of an imp's fireballs with the shield up: they are turned before they reach you and fly where
   the plate sends them.
4. A zombie's bullets: stopped at the plate, sent back.
5. Let an imp claw at the shield: it is stunned and shoved back.
6. Perfect block: swing the shield into a fireball as it arrives. A higher ring, a double buzz, a white bloom.
7. Bash an imp: it is hit, shoved and lifted. A small flash and sparks at the body, at plate height, never on
   the floor. **(not yet headset-confirmed)**
8. Bash an imp that has not seen you yet: no Brutal Doom stealth-kill cutscene; the camera stays with you.
   **(not yet headset-confirmed)**
9. Wall slam: bash an imp into a wall. It hits the wall, takes extra damage and hangs in its pain frame a moment.
   **(not yet headset-confirmed)**
10. Hold the off trigger: blades out, saw revs. Push it into a monster: it grinds.
11. Hold Use with the shield away from your back and sweep over three monsters: a lock mark on each, a green
    ring round a white centre, the first the biggest. **(the new mark: not yet headset-confirmed)** Rev, then let go
    of the trigger while snapping your arm forward: it visits each mark, then comes back. Catch it.
12. Throw again; press the off trigger while it flies: it comes back.
13. Let go of the trigger with your arm still: nothing is thrown.
14. Mark a monster round a corner and throw: the disc bounces off the wall in between (sparks), turns to the
    mark and comes home. **(not yet headset-confirmed)**
15. Take It From "Behind the Neck": reach over your off shoulder to behind your neck and press Use: it draws and
    puts back there. "Small of Back or Neck": both spots answer. "Over the Off Shoulder": the old shoulder grab
    answers. **(not yet headset-confirmed)**
16. Options, one at a time, then back off:
    - Hit-Stop: a bashed monster freezes for a beat; so does one whose attack you perfectly blocked.
      **(not yet headset-confirmed)**
    - Perfect Block Slow-Mo: needs RSQ SlowMo loaded. A perfect block slows the world for half a second.
      **(not yet headset-confirmed)**
    - BD22 Monsters: a thrown disc cuts a Brutal Doom imp in two instead of grinding it.
17. With RSQ Saber loaded: lit saber in the main hand, rest it across the shield's front. Block a fireball at
    the plate's edge: blocks wider. Lift the blade off: back to normal. **(not yet headset-confirmed)**
18. "Reset All" (Tuning and Debug) puts everything back.
19. Load RSQ Accessibility (Steady Hands on). Hold the lock on one monster in a group: the rings go on the one
    you point at without jumping to its neighbour. Steady Hands off: as before. **(not yet headset-confirmed)**
20. Sit down (with or without Accessibility's Seated Play): after a second the back and neck spots come down with
    your head; reach behind you as in step 2. **(not yet headset-confirmed)**
21. Accessibility's Rumble Strength 0: the shield's buzzes stop; 2: stronger. **(not yet headset-confirmed)**
22. Accessibility's colour-blind mode (e.g. Deuteranopia): the lock marks' ring turns azure, the centre stays white.
    **(not yet headset-confirmed)**
23. With RSQ Tactical Rig: put your off hand in the rig's left-shoulder holster with Take It From "Behind the
    Neck" and press Use: the rig answers, not the shield. Over the Off Shoulder: the rig leaves that shoulder to the
    shield. **(not yet headset-confirmed)**

## Works with

- **RSQ Saber:** saber in the main hand, shield in the off. Saber Over Shield widens the block. Either load
  order, either absent.
- **RSQ SlowMo:** the Perfect Block Slow-Mo option.
- **RSQ Tactical Rig:** with the shield on your back (Take It From: back or neck) the rig keeps its off-shoulder
  holster, and a hand in any rig holster is the rig's press. Over the Off Shoulder: the rig leaves its off-shoulder
  holster to the shield. With "Draw With Use" off the shoulder is the rig's.
- **RSQ Score:** blocks, perfect blocks, turned shots and disc kills pay bonuses.
- **RSQ HP Bars:** a locked monster shows the "locked" marker; hit-stop shows the frozen marker.
- **Gun Bonsai with the RSQ Gun Bonsai VR patch:** the ShieldSaw levels up (the tree: GBOVR_TREES.md 4.3).
  **Throw:** under the patch a throw starts at **1 lock**; **Lockstep** adds one a level, to the Locks row (5) at
  level 4; **Ricochet** after it, then **Hunter's Return**, **Meat Grinder**; **Wall Bounces** (after Ricochet 2: the
  Wall Bounces row and one more a level); **Cleaver** (after Meat Grinder: cut in two at or under 100 / 140 / 200,
  stuck and ground at or under 800 / 1000 / 1200; Brutal Doom's tiers rise by the same share). **Block:**
  Broadening, then Bulwark, then Rebound; **Back Plate** (after Broadening 2: the shield on your back blocks; 2 it
  turns shots too -- replaces Block While Holstered under the patch); **Shield Wall** (after Bulwark 2: a perfect
  block slows time 0.75 / 1 / 1.25 s -- replaces Perfect-Block Slow-Mo); **Reflect** (after Rebound 2: a returned
  bullet x1.5, x2). **Bash:** Battering Ram, then **Wall Slam** (+50% a level, stunned 10 + 10 tics a level longer)
  and **Strike True** (a bash freezes them 4 / 5 / 6 tics -- replaces the Hit-Stop rows); **Charge** (after Wall Slam: a
  bash while moving forward at 2 m/s or more -- stick or body -- strikes a wedge 1.5 / 2 / 2.5 m deep); **Shield Size**
  (after Battering Ram 2: Large, then Largest; the Shield Size row is the floor); **Shield Dash** (after Charge: thrust
  the shield forward hard with the stick pushed forward and you dash 3 / 4 / 5 m the way it faces, landing a bash; 2 s
  between). **Grind:** **Hungry Blades** (a grind hit 6 -> 8 / 10 / 12, a stuck disc 3 -> 4 / 5 / 6 a tic); **Rev
  Shield** (after it: a revving shield held up grinds what claws it; 2: turns a blocked shot even with the Deflect row
  off); **Buzzsaw Return** (after Hungry Blades 2: the disc coming home grinds what it passes for 65 / 80 / 95% of a
  grind hit). **Spartan** (the Saber link: after Broadening here and the saber's Deflector): with the lit blade resting
  on the shield every shot the shield turns goes straight at its shooter, even with the Deflect row off; 2: a bash in
  that stance cuts as well, paid to the saber. Without the patch nothing changes.
- **Fixed 11-02:** the hand throw now bounces off walls (the Wall Bounces row only reached the One-Handed throw), and
  a monster under the cut-in-two tier is cut in two (the cut dealt only an ordinary hit, so a Doom imp took about 40
  and lived); a bullet the shield on your back stops goes back out (its trace started inside your own body, so your
  own shield blocked it).
- **Brutal Doom VR (BD22Q):** its off-hand hands give way to the shield; flick reload with a gun in the main
  hand and the shield in the off follows BD22Q's flick setting.
- **RSQ Accessibility:** its comfort, colour-blind and gesture settings. Steady Hands (on in Accessibility):
  painting locks and the aimed share of a throw use the smoothed hand; blocks, bashes and how hard you throw stay on
  the raw hand. Seated Play: the back and neck spots follow your headset's height anyway; the shoulder spot comes down by
  Seated Play's seat drop. Rumble Strength
  scales the shield's rumbles x0 to x2 (0 = none). Inert without it.

## Known limits / open issues

- The body frame (2026-11-02) ran on the simulated rig only. Telling a snap or smooth turn from a head turn rests
  on how QuestZDoom 17.3 writes the controller angles (measured on the rig: a tic after the pawn's angle). If a
  snap turn does not carry the spot round in the headset, the 35-degree catch-up still brings it round in about
  a second; say so and it is the first thing to look at. A turn that lands on a frame the renderer skipped is
  left to that catch-up too.
- "Eyes to Neck" (9 cm) is an anatomical estimate, not a measurement.

- Not felt in a headset: the flick throw on the trigger alone, Use as the lock button, rumble strengths, throw
  speed 60.
- The grind now runs every tic while revved: a real cost increase on Quest.
- The grind follows the plate's real path, so walking fast may read as the grind reaching backwards.
- A returned bullet is fired by a helper, so co-op friendly-fire rules do not apply to it, and Gun Bonsai cannot
  credit its damage.
- Planting the shield in the floor: not built (owner said no).
- The RSQ Accessibility wiring (2026-11-01: Steady Hands, Seated Play, Rumble Strength) ran on the simulated rig only: it loads clean with
  and without Accessibility, in the Brutal Doom order too. Its effect on this mod's aim was not measured on the rig.
- Where Ermac's first shield mesh came from, and where the hand and sounds came from before Rusted Legacy, is
  not recorded.

## Credits

From the old README, unchanged:

**Where it comes from.** The shield saw is id Software's: the weapon of *Doom: The Dark Ages*
(2025). Ermac brought it to Doom VR first, in his mod
[Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), and this mod started from his version.
The meshes, in Ermac's own words (his conversation with the project owner, 2026-10-27): he worked
on two shield models. The first took him about three days to make work; the second was ripped from
the game, and he separated its parts in a day. This pack carries two shield meshes --
`shield.md3` (the held shield: holder, bolt, handle, back, rim) and `shieldsaw.md3` (the HD shield
front with its separate saw-blade parts) -- and which of his two each one is, and where the first
came from, is not recorded here. The ripped one is id Software's mesh, and the MIT licence of his
Rusted Legacy code (`models/hand/LICENSE_RustedLegacy_MIT.txt`) does not make it MIT. The hand
that holds it and the sounds come with Rusted Legacy's ShieldSaw; where they came from before that
is not recorded here either.

- Saw voice and block sparks come from RS_CombatFX (chainsaw archetype).
- **id Software** -- the shield saw itself, from *Doom: The Dark Ages*: its design, and the mesh
  Ermac ripped from the game.
- **Ermac** ([Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), MIT code) -- brought the
  shield saw to Doom VR first; his two shield models (the first about three days' work to make
  work, the second a game rip whose parts he separated); the version this mod started from, with
  its hand model and sounds.
- **QuestZDoom** (Emawind, Team Beef) -- the engine and its off-hand weapon and attack-pose API.
- President_Koopa -- this standalone Quest version: its design, its testing on the headset, and
  the direction of every change.

SNDINFO: "RS_ShieldSawQ sounds. Lumps are Ermac's; the aliases are ours."
