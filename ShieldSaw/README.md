# RSQ ShieldSaw

**The one thing:** rev the shield, lock your targets, and throw it as a saw disc that cuts through them, grinds the
one it sticks in, and comes back to your hand.

`pk3/RSQ_ShieldSaw.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3, in VR.

A shield that is also a throwable saw disc, in your off hand. It stops what crosses its face: fireballs are turned
before they reach you, bullets are stopped at the muzzle and sent back, claws are caught on contact. Shove it to bash.
Hold the off trigger and the blades come out and the saw revs. Let go while your arm snaps forward and it flies,
visits the targets you locked, and comes back. It is the shield saw from *Doom: The Dark Ages*, brought to Doom VR
first by Ermac in Rusted Legacy; this mod started from his version and is a standalone off-hand mod. It needs no
other RSQ pk3 and no engine change, and replaces no player class. It works with plain Doom 2 and with Brutal Doom
(the "BD22 Monsters" row is for Brutal Doom's tougher monsters).

## Features

**The shield.**
- You start with it, on your back ("Start With Shield"). Draw it with Use at the mount, or start with it in hand.
- Three mounts to take it from: the small of your back (default), behind your neck, or over your off shoulder. The
  spot hangs on your body, not your head: look around while you reach and it stays where your back is.
- It blocks what crosses its face. Fireballs are turned ("Blocked Projectiles": Returned, or Cancelled). Where a
  turned shot goes is your choice: back to the shooter, where you look, off the face, or off the face and along your
  swing (default).
- Shots about to cross the plate are turned early, even ones that would have missed ("Turn Shots Early").
- Muzzle block: a bullet whose line crosses the plate is stopped before it is fired, and sent back out ("Return
  Bullets").
- Blocked melee stuns and shoves the attacker ("Blocked Melee": Stun and Shove, Stun, or Nothing).
- Perfect block: move the plate into the attack as it lands. The shot goes back faster, the attacker always
  staggers, the ring flashes bright, a double buzz.
- A shield on your back can still block ("Block While Holstered", off by default).
- Block feedback: a spark where the attack crossed the face, a buzz in the hand, sounds heard where they happen.

**The bash.**
- Shove the shield forward into a monster: it is hit, shoved and lifted. A steady lean counts too, not only a snap.
- Wall slam: a bashed body that hits a wall takes extra damage and hangs stunned.
- Bash and grind cannot reach through a wall or a door ("Bash Needs Sight").
- Hit-Stop (option): a bash or a perfect block freezes the monster for a beat.
- A bash never starts Brutal Doom's stealth-kill cutscene.

**The rev and the grind.**
- Hold the off trigger: the blades come out and the saw revs up. Anything touching the blades is ground, a hit at a
  time, every body on its own clock.
- A throw at full rev flies faster and hits harder.

**The throw.**
- Lock on: hold Use with the shield away from the mount and sweep it over enemies. A lock mark goes on each, one at
  a time, a buzz each, up to "Max Locks" (5). The first target's mark is the biggest.
- Let go of the throw button while your arm snaps forward and the disc flies. It visits the marks in order, or goes
  where you point if there are none. A slow release puts it away instead of throwing.
- A wall between the disc and its next mark is bounced off (sparks), up to "Wall Bounces" times; it turns to the
  mark when it sees it again, else comes home.
- Hit tiers, by the victim's health: weak monsters are cut in two and the disc rips through; mid-tier monsters take
  the disc and are ground for a while; heavies turn it away with a glancing hit. "BD22 Monsters" raises the tiers
  for Brutal Doom.
- It comes home along the way it went out, never through a wall. Your hand near it catches it ("Catch on Return");
  otherwise it lands on the mount.
- Recall: press the off trigger while it flies.
- A backup throw along your aim and a draw / put back / recall key, for anyone with no hand motion to read.

**Saber over shield.** With RSQ Saber's lit blade in your main hand resting across the shield's front, the block is
wider (x1.3).

**The lock marks.** The series' shared diamond: a green ring round a white centre, animated. With RSQ Accessibility's
colour-blind modes the ring takes that mode's "locked" colour and the centre stays white.

**Your hands stay yours.** The off hand gives up whatever it held when you draw, and gets it back (or a fist) when you
put the shield away. A weapon switch cannot take the off hand unless you let it ("Off-Hand Switch").

## How to play

Put the headset on. The shield is on your back, at the small of your back, to your off side.

1. **Draw it.** Reach your off hand behind you to the small of your back and press Use. The shield is in your off
   hand. Press Use there again to put it back. ("Take It From" moves the mount: Behind the Neck is reached over your
   off shoulder; Small of Back or Neck answers at both; Over the Off Shoulder is the old spot.) Turn your head as you
   reach: the spot stays put. A snap or smooth turn carries it round with your body.
2. **Block.** Hold the shield's face toward what is coming. A fireball that crosses the face is turned; a zombie's
   bullet is stopped and sent back; an imp's claw is caught and the imp is stunned and shoved. A fireball you can see
   fly under the rim hits you.
3. **Perfect block.** Instead of holding still, swing the shield into the attack as it arrives. A higher ring, a
   double buzz, a white bloom, and the shot goes back harder.
4. **Bash.** Shove the shield forward into a monster. It is hit, shoved and lifted; a flash and sparks at the body.
   Bash it toward a wall for a wall slam.
5. **Rev.** Hold the off trigger. The blades come out and the saw winds up. Push the spinning blades into a monster
   to grind it.
6. **Lock on.** With the shield in hand and away from your back, hold Use and sweep the shield over enemies. A green
   and white mark goes on each with a buzz, the first the biggest. Up to five.
7. **Throw.** Let go of the off trigger while your arm is snapping forward. The disc flies to each mark in order and
   then comes home. Let go with your arm still and nothing happens; it stays in your hand. Rev first for a harder,
   faster throw.
8. **Catch or recall.** Hold your off hand out as it comes back and it lands in your hand. Press the off trigger
   while it flies to call it home early. If you do not catch it, it goes back on the mount.
9. **Saber over shield.** With RSQ Saber loaded, light the saber in your main hand and rest the blade across the
   shield's front. The block grows wider while the blade is there.

Nothing needs binding: Use, the off trigger and the off alt are QuestZDoom's own. The optional keys are in
Options -> Customize Controls, section **RSQ ShieldSaw**:

- **ShieldSaw: draw / put back / recall**: draw or put back from anywhere, or recall a thrown disc.
- **ShieldSaw: throw along aim**: a throw along where you point, no arm motion needed.
- **ShieldSaw: lock on (hold)**: only needed if "Lock On With" is set to "Lock Key".

The menu is Options -> Radiant Silvergun Options -> RSQ ShieldSaw.

## Settings

**RSQ ShieldSaw** (front page)

| Menu row | Default | What it does |
|---|---|---|
| Start With Shield | On | Every player spawns with it. |
| Start in Hand | Off | Start with it drawn. |
| Draw With Use | On | Use at the mount draws and puts back. Off: only the Draw key does. |
| Take It From | Small of the Back | Or Behind the Neck, Small of Back or Neck, Over the Off Shoulder. |
| Lock On With | Use | Use (away from the mount), Lock Key, or Throw Button. |
| Throw Button | Off Trigger | What throws on a flicked release: Off Alt, Either, Off Trigger. |
| Max Locks | 5 | Targets one throw visits (0 to 5). |
| Shield Size | Standard | Preset: Standard, Large, Largest. |
| Throw Feel | Standard | Preset: Easy, Standard, Deliberate (how hard you must swing). |
| Block Assist | Standard | Preset: Low, Standard, High (how much a turned shot is helped onto an enemy). |
| Damage | Standard | Preset: Low, Standard, High (throw, bash and grind together). |
| Turned Shots Go | Off the Face and My Swing | Or To Shooter, Where I Look, Off the Face. |
| Blocked Melee | Stun and Shove | Or Stun, Nothing. |
| BD22 Monsters | Off | Hit tiers for Brutal Doom's tougher monsters: cut in two up to 250 health, ground up to 1200. |

**Shield Options**

| Menu row | Default | What it does |
|---|---|---|
| Shield Blocks | On | The block at all. |
| Block While Holstered | Off | A shield on your back still blocks. |
| Double Block Radius | Off | The blocking plate is twice as wide (the shield you see is unchanged). |
| Blocked Projectiles | Returned | Or Cancelled. |
| Turn Shots Early | On | Shots about to cross the plate are turned, even ones that would miss. |
| Muzzle Block | On | A bullet whose line crosses the plate is stopped before it is fired. |
| Return Bullets | On | A stopped bullet goes back out. |
| Perfect Block | On | Plate moving into the attack: faster return, always staggers, rings bright, buzzes twice. |
| Shield Bash | On | Shove the shield: hit, shove, lift. |
| Bash Needs Sight | On | Bash and grind cannot reach through a wall or door. |
| Wall Slam | On | A bashed body that hits a wall takes extra damage and hangs stunned. |
| Hit-Stop | Off | A bash or a perfect block freezes the monster for a beat. |
| Perfect Block Slow-Mo | Off | Half a second of slow motion on a perfect block. Needs RSQ SlowMo. |
| Saber Over Shield | On | RSQ Saber's lit blade across the shield widens the block. |
| Hit Tiers | On | Thrown disc: weak monsters cut in two, mid-tier ground, heavies turn it away. |
| Catch on Return | On | The disc comes back to your hand. |
| On Manual Store | Fist | What the off hand holds after you put it away: Fist or Previously Held Weapon. |
| Off-Hand Switch | Keep Shield | Or Allow Switch (a weapon switch can take the off hand). |

**Look and Sound**

| Menu row | Default | What it does |
|---|---|---|
| Block Feedback | On | Block sparks and haptics. |
| Positional Sound | On | Contacts are heard where they happen, not at your feet. |
| Show Mount | When Needed | The mount's marker: Never, When Needed, Always. |
| Shield on Back | Off | Draw the shield on your back while it is stowed. |
| Others See Shield | Netgame Only | The held shield as a world prop: Only Me, Everyone, Netgame Only. |
| Spin Direction | Normal | Or Flipped, if the disc rolls the wrong way. |

**Tuning and Debug** holds every number, in five sub-pages, plus:

| Menu row | Default | What it does |
|---|---|---|
| Debug Log | Off | Grip edges, pose and decisions to the console. |
| Show Block Area | Off | Draws the guard plate as particles. |
| Reset All | | Puts every RSQ ShieldSaw setting back. |

*Shield Fit*

| Menu row | Default | What it does |
|---|---|---|
| Shield Size | 1.0 | The whole shield, model and plate together (1.0 to 1.5). |
| Disc Forward | -15.4 | Where the plate sits along the controller, cm. |
| Disc Side | -7.5 | Where the plate sits to the controller's side, cm. |
| Disc Up | -5.0 | Where the plate sits up the controller, cm. |
| Block Radius | 29.2 | The plate's radius, cm. |
| Block Depth | 4 | cm either side of the face that still counts as the shield. |

*Throw and Disc*

| Menu row | Default | What it does |
|---|---|---|
| Throw Hand Speed | 60 | Arm speed (units/s) below which a release puts it away instead of throwing. |
| Throw Speed | 1.6 | Launch speed scale. |
| Arm or Aim | 0.7 | 1 = throw along the arm's own direction, 0 = along where the hand points. |
| Aim Forward | 0.35 | How closely the throw must go where you look (0 = any direction). |
| Slowest Throw | 12 | The slowest a throw can leave at, units/tic. |
| Disc Weight | 5.0 | kg; a heavier disc keeps less of the hand's speed. |
| Disc Wind-Up | 0.05 | How fast a flying disc speeds up while it has a target. |
| Disc Top Speed | 34 | Units/tic it winds up to. |
| Return Speed | 22 | Units/tic on the way home. |
| Return Patience | 105 | Tics of returning before it ignores geometry and flies straight home. |
| Catch Radius | 24 | Hand within this of the returning disc = caught. |
| Breadcrumb Gap | 4 | Tics between the breadcrumbs it follows home. |
| Throw Damage | 1.0 | Thrown-disc damage scale. |
| Bisect Limit | 70 | Health at or under which a monster is cut in two. |
| Embed Limit | 600 | Health at or under which the disc sticks and grinds. |
| Glance Damage | 0.4 | Damage scale of a glancing hit on a heavy. |
| Embed Damage | 3 | Damage per tic while stuck. |
| Embed Time | 21 | Tics the disc stays stuck. |
| Rev Time | 21 | Tics from still to full rev. |
| Grind Damage | 6 | Per grind hit. |
| Grind Gap | 4 | Tics between grind hits on the same body. |
| Rev Throw Bonus | 0.6 | A full-rev throw adds this fraction of damage and speed. |
| Revved Blade Reach | 6.0 | cm the deployed blades add to the plate. |
| Wall Bounces | 3 | Walls a thrown disc bounces off on its way to its marks (0 = the first wall sends it home). |

*Lock-On*

| Menu row | Default | What it does |
|---|---|---|
| Lock Cone | 25 | Half-angle from the hand's forward a target is locked in. |
| Lock Range | 1200 | How far a lock reaches. |
| Lock Keep Angle | 60 | A lock is kept out to here, wider than the cone it was taken in. |
| Out of Sight Grace | 105 | Tics a lock may stay out of the cone or out of sight before it drops. |
| Lock Gap | 3 | Tics between targets going on as you sweep. |
| Rings Kept | 175 | Tics your marks survive a release that was not a throw. |
| Ring Size | 1.0 | Size of the lock mark. |

*Block and Bash*

| Menu row | Default | What it does |
|---|---|---|
| Deflect Assist | 14 | Degrees of help putting a turned shot onto an enemy. |
| Guard Margin | 0 | cm added to the plate's rim for the early turn and the bullet stop. |
| Early Turn Lookahead | 1.0 | Tics of a shot's path tested ahead against the plate. |
| Turned Shot Speed | 1.0 | A turned shot's speed, as a multiple of its own. |
| Bullet Return Damage | 1.0 | The returned bullet's damage, as a multiple of the one you ate. |
| Melee Shove | 12 | How far a blocked melee attacker is shoved. |
| Perfect Block Speed | 25 | Plate speed into the attack that counts as a perfect block. |
| Bash Speed | 45 | Arm speed along the face that counts as a bash. |
| Bash Damage | 1.0 | Bash damage scale. |
| Bash Reach | 1.2 | How much the bash opens the plate, for the shove only. |
| Leaned Bash | 0.6 | How much of a sustained push counts as a bash (0 = fast shoves only). |
| Bash Knockback | 1.35 | How far a bashed body goes. |
| Bash Lift | 2.5 | The lift under the shove. |
| Wall Slam Damage | 1.0 | The slam's damage scale. |
| Wall Slam Stun | 8 | Tics the slammed body is frozen. |
| Hit-Stop Tics | 4 | How long Hit-Stop freezes a monster. |
| Brace Block Size | 1.3 | The block's radius with the saber over the shield, as a multiple. |

*Mount Position* (cm; the shoulder rows are from eye height, the back and neck rows from your eyes in your body's
frame)

| Menu row | Default | What it does |
|---|---|---|
| Mount Forward | -27 | The shoulder mount, forward (negative = behind). |
| Mount Side | 12 | The shoulder mount, to the off side. |
| Mount Up | -30 | The shoulder mount, up from eye height. |
| Small of Back: Behind | -30 | The back spot, behind your eyes. |
| Small of Back: Side | 10 | The back spot, to the off side. |
| Small of Back: Down | -62 | The back spot, below your eyes (belt height). |
| Small of Back: Reach | 30 | The back grab's radius. |
| Neck: Behind | -22 | The neck spot, behind your eyes. |
| Neck: Side | 8 | The neck spot, to the off side. |
| Neck: Down | -18 | The neck spot, below your eyes. |
| Neck: Reach | 26 | The neck grab's radius. |
| Eyes to Neck | 9 | How far your eyes sit in front of the neck your head turns on. |
| Grab Reach | 30 | The shoulder grab's radius. |
| Grab Zone | 1.6 | The zone over the shoulder, as a multiple of the reach. |
| Back Yaw | 0 | The stowed shield's yaw. |
| Back Pitch | 0 | The stowed shield's pitch. |
| Back Roll | 0 | The stowed shield's roll. |
| Back Size | 1.0 | The stowed shield's size. |
| Held X | 0 | The held shield's offset, cm. |
| Held Y | 0 | The held shield's offset, cm. |
| Held Z | 0 | The held shield's offset, cm. |
| Held Yaw | 0 | The held shield's angle, degrees. |
| Held Pitch | 0 | The held shield's angle, degrees. |
| Held Roll | 0 | The held shield's angle, degrees. |

## Works with

- **RSQ Saber:** saber in the main hand, shield in the off. Saber Over Shield widens the block while the lit blade
  rests across the front. Either load order, either absent.
- **RSQ SlowMo:** the Perfect Block Slow-Mo option pulses half a second of slow motion.
- **RSQ Miniboss:** a miniboss it made legendary gets the higher of LegenDoom's boss and normal legendary health when
  the disc works out its hit tier.
- **RSQ Tactical Rig:** with the shield at your back or neck, the rig keeps its off-shoulder holster, and a hand in
  any rig holster is the rig's press, never the shield's. Over the Off Shoulder: the rig leaves that shoulder to the
  shield. With "Draw With Use" off the shoulder is the rig's.
- **RSQ Score:** blocks, perfect blocks, turned shots, grinds and disc kills pay bonuses.
- **RSQ HP Bars:** a locked monster shows the "locked" marker.
- **Brutal Doom VR (BD22Q):** its off-hand hands give way to the shield. With a gun in the main hand and the shield in
  the off, a flick down reloads the gun, following BD22Q's flick setting.
- **RSQ Accessibility:** Steady Hands smooths the lock sweep and the aimed share of a throw (blocks, bashes and how
  hard you throw stay on the raw hand). Seated Play brings the mounts down to your seated height. Rumble Strength
  scales the shield's buzzes (0 = none). Photosensitive Mode dims the block flashes. One-Handed: the Off-Hand Modifier
  swaps hands and the Shield Throw gesture button throws. Hold to Toggle latches the lock key. Colour-blind modes
  recolour the lock marks. Inert without it.

**Gun Bonsai with the RSQ Gun Bonsai VR patch:** the ShieldSaw levels up. Under the patch a throw starts at one lock
and Lockstep adds one a level up to the Max Locks row; Ricochet, Hunter's Return, Meat Grinder, Wall Bounces and
Cleaver grow the throw. Broadening, Bulwark, Rebound, Back Plate (replaces Block While Holstered), Shield Wall
(replaces Perfect Block Slow-Mo) and Reflect grow the block. Battering Ram, Wall Slam, Strike True (replaces
Hit-Stop), Charge, Shield Size and Shield Dash grow the bash. Hungry Blades, Rev Shield and Buzzsaw Return grow the
grind. Spartan, with RSQ Saber, turns every blocked shot straight at its shooter while the blade rests on the shield.
Without the patch nothing changes.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s. Needs no other RSQ pk3; any order
among them.

## Known limits

- Telling a snap or smooth turn from a head turn rests on how QuestZDoom 17.3 writes the controller angles. If a
  snap turn does not carry the mount round at once, the catch-up (a head held more than 35 degrees round for a
  second) brings it round in about a second.
- "Eyes to Neck" (9 cm) is an anatomical estimate, not a measurement.
- The grind runs every tic while revved: a real cost on Quest.
- The grind follows the plate's real path, so walking fast can read as the grind reaching backwards.
- A returned bullet is fired by a helper actor, so co-op friendly-fire rules do not see a player as its source.
- Where Ermac's first shield mesh came from, and where the hand and sounds came from before Rusted Legacy, is not
  recorded.

## For other mods

Service `SSQ_ScoreService`, found by name:

- `GetInt("locked", "", 0, 0, monster)`: 1 a lock mark is on it now (any player's), 0 not.
- `GetInt("blocked", "", 0, 0, monster)`: tics since the shield blocked an attack from that monster, or -1 (kept 10 s).
- `GetInt("perfect", "", 0, 0, monster)`: tics since a perfect block of that monster's attack, or -1 (kept 10 s).
- `GetInt("returned", "", 0, 0, actor)`: 0 if that actor is a shot the shield turned, or a monster a returned bullet
  hit this tic or the last; -1.
- `GetObject("returned.from", "", 0, 0, actor)`: the monster that fired a shot the shield turned, or the shooter of a
  returned bullet that hit that actor; null if neither.
- `GetInt("grind.held", "", 0, 0, monster)`: tics the hand-held grind has been on it; -1 not being ground.
- `GetInt("thrown.leg", "", 0, 0, disc)`: 0 the disc is on its way out (or stuck grinding), 1 flying home; -1 not a disc.
- `GetInt("disc.grinding", "", 0, 0, disc)`: 0 the disc is stuck in a monster grinding it; -1 not.

Network events it accepts: `ssq-draw` (draw, put back, or recall), `ssq-throw` (throw along the aim), `ssq-lock 1/0`
(the lock key), and RSQ Accessibility's `rsqa_alt` button 6 (the Shield Throw gesture).

What it asks of others, by name: `RSQ_MeleeUpgradeService` (the Gun Bonsai VR patch: levels and numbers),
`RS_ScoreService` (`touch`), `RSQMB_Service` (`bossfor` `ldhealth`), `UBQS_SaberService` (`saber.lit`),
`RSQA_Service` (`swap`, `vignette`), and RSQ SlowMo's `rsm_pulse` event.

## Credits

**Where it comes from.** The shield saw is id Software's: the weapon of *Doom: The Dark Ages*
(2025). Ermac brought it to Doom VR first, in his mod
[Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), and this mod started from his version.
The meshes, in Ermac's own words (his conversation with the project owner): he worked
on two shield models. The first took him about three days to make work; the second was ripped from
the game, and he separated its parts in a day. This pack carries two shield meshes --
`shield.md3` (the held shield: holder, bolt, handle, back, rim) and `shieldsaw.md3` (the HD shield
front with its separate saw-blade parts) -- and which of his two each one is, and where the first
came from, is not recorded here. The ripped one is id Software's mesh, and the MIT licence of his
Rusted Legacy code (`models/hand/LICENSE_RustedLegacy_MIT.txt`) does not make it MIT. The hand
that holds it and the sounds come with Rusted Legacy's ShieldSaw; where they came from before that
is not recorded here either.

- Saw voice and block sparks come from RS_CombatFX (chainsaw archetype).
- The Gun Bonsai VR tree's effects and sounds (Charge's shockwave SSQV, Shield Dash's streak SSQK and whoosh, Charge's
  rolling blast): from the owner's wells RS Combat FX and RS Ballistics, one asset at a time; `tools/fxpull.py` is the
  record of each pull.
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
