# RSQ ShieldSaw

**v0.8a — 2026-10-26.** A shield that is also a throwable saw disc, in your off hand, for **stock
QuestZDoom 17.3** (TeamBeef / emawind84 build). Standalone pk3: loads with any weapon pack, needs
no engine changes, replaces no player class.

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
is not recorded here either. This version re-implements the behaviour for stock QuestZDoom 17.3 as
a standalone off-hand mod: the mount, blocking and deflection, the bash, the rev and lock-on
throw.

Loads happily beside **RSQ_Saber** — two separate mods, either load order, either one
absent. Saber in the main hand, shield in the off.

## How it plays

It hangs over your off shoulder. Reach up and press **Use**: it is in your hand.

**Lock on with Use**, held with the shield away from your shoulder: sweep it across enemies and a
ring goes on each, one at a time, biggest over the one the disc will visit first, and your hand
buzzes as each lands. A lock *stays* locked: once it is on, it holds until it dies, leaves a much
wider cone, or is out of sight for 3 s; the rings stay 5 s after you let go of Use.

**Hold the off trigger** and the blades deploy and the saw revs (grind, bash). **Let go of it while
your arm snaps forward** and it flies, spinning in the plane your wrist gave it,
visiting the ringed targets in the order you ringed them. Let go still, or across your body, and
it stays in your hand and keeps the marks for a second. Press again while it flies to recall it.
It always comes back — past three seconds it stops asking the level's permission and flies
straight to your hand. Catch it, or it lands on the mount.

Fodder is bisected. Mid-tier takes the disc and is ground for a while. Heavies turn it away.

**What crosses its face is stopped**, and in three ways, not one:

- **Fireballs are turned before they reach you.** Every tic, missiles whose path will cross the
  plate in the next few tics are batted away — including ones that would have missed.
- **Bullets are stopped at the muzzle.** A hitscan whose ray crosses the plate and is coming at
  you is cancelled before it is ever traced, and goes straight back out.
- **Melee and blasts** are caught the old way, at the moment of impact.

A turned shot goes **where you are looking** by default, helped onto the nearest enemy near your
gaze. Catch a fireball, turn your head, send it.

**Perfect block**: meet a shot with a *moving* plate instead of holding the shield in its way. The
return is 60% faster, a melee attacker is always staggered and shoved — and you know it happened:
it rings a tone higher, buzzes twice as long and blooms white at the contact point.

**Bash**: drive the shield forward. Everything in front of it is hit, shoved and lifted off the
floor. It reaches a fifth further than the grind does, because a shove is the whole shield with
your arm behind it.

## Options

`Options → Radiant Silvergun Options → RSQ ShieldSaw`. The front page has the everyday choices:
starting with it (and in hand), drawing with Use, what locks on and what throws, the most locks,
four presets (**Shield Size**, **Throw Feel**, **Block Assist**, **Damage**; Standard is the
shipped defaults, Custom once you change one of their numbers), where turned shots go, blocked
melee and Brutal Doom v22 monsters. **Shield Options** lists the block and bash switches (**Double
Block Radius** doubles the blocking plate, the shield you see unchanged; **On Manual Store** is what
the off hand holds once you put the shield away), **Look and Sound** where the shield shows. Last,
**Tuning and Debug**: every number (**Shield Fit**, **Throw and Disc**, **Lock-On**, **Block and
Bash**, **Mount Position**), the debug switches and Reset All.

## Gun Bonsai upgrades

With Gun Bonsai's VR patch loaded, the ShieldSaw levels like a weapon and its upgrades are read by
name (`RSQ_MeleeUpgradeService`; all off without the patch):

- **Broadening**: the blocking plate grows 20% a level, to double at level 5 (it replaces Double
  Block Radius while the patch is loaded).
- **Lockstep**: one more lock a level.
- **Bulwark**: a perfect block needs a slower plate.
- **Rebound**: a returned bullet hits harder.
- **Battering Ram**: what you bash is thrown into whatever stands behind it.
- **Ricochet**: a wall the disc hits turns it toward a new target instead of home.
- **Meat Grinder**: a kill while the disc is stuck frees it at full speed toward the next lock.
- **Hunter's Return**: on the way home it swerves through enemies near its path.

## Controls

Keys of its own (Draw, Throw, Lock) are in **Customize Controls** under RSQ ShieldSaw.

| | |
|---|---|
| **Use**, off hand at the shoulder | draw / put back |
| **Draw** key (Customize Controls) | draw / put back from anywhere |
| **Off trigger**, held | rev the saw (grind, bash) |
| **Use**, held away from the shoulder | lock on: sweep the shield over enemies, one ring each |
| the trigger, let go with the arm snapping forward | throw: to the rings in order, or where you point |
| the trigger, pressed while it flies | recall |

The lock-on is its own button (the owner, 10-27: the trigger used to rev, lock and throw at once).
*Lock On With* picks it: **Use** (default, nothing to bind), **Lock Key** (bind the off grip or any
key to "ShieldSaw: lock on (hold)" in Customize Controls), or **Throw Button** (the old way).
A lock is kept 3 s out of sight; the rings stay 5 s after you let go, so you can lock, rev, then throw.

*Draw With Use* (on by default): turn it off to use the Draw key alone; the shoulder
is then no grab, its marker is hidden, and RSQ_TacticalRig keeps that shoulder for weapons.

*BD22 Monsters* (off by default): Brutal Doom's monsters are tougher than Doom's,
so on the normal limits nearly everything from an imp up stops the disc. On: it slices through anything up
to 250 health (to the revenant), sticks and grinds up to 1200 (to the baron), and glances off bigger.

The throw is the off trigger alone by default (*Throw Button*): QZD's stock binds put the off alt behind a
grip shift, the same grip that arms the two-hand grab.

## Notes

- **Netplay**: one small pose event a tic while it is out; every decision — block, sweep, muzzle,
  throw — runs from that synced pose, so every machine agrees.
- The plate's geometry is **measured off the mesh**, not tuned by eye, and the size slider picks
  between five baked meshes because MODELDEF cannot scale a model at run time.
- Saw voice and block sparks come from RS_CombatFX (chainsaw archetype).

Details, measurements and the engine's traps: `HANDOFF.md` in the repository.

## Credits

- **id Software** -- the shield saw itself, from *Doom: The Dark Ages*: its design, and the mesh
  Ermac ripped from the game.
- **Ermac** ([Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), MIT code) -- brought the
  shield saw to Doom VR first; his two shield models (the first about three days' work to make
  work, the second a game rip whose parts he separated); the version this mod started from, with
  its hand model and sounds.
- **QuestZDoom** (Emawind, Team Beef) -- the engine and its off-hand weapon and attack-pose API.
- President_Koopa -- this standalone Quest version: its design, its testing on the headset, and
  the direction of every change.
