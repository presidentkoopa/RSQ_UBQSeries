# Ultra Badass ShieldSaw

**v0.7 — 2026-10-23.** A shield that is also a throwable saw disc, in your off hand, for **stock
QuestZDoom 17.3** (TeamBeef / emawind84 build). Standalone pk3: loads with any weapon pack, needs
no engine changes, replaces no player class. Ermac's hand holds it (Rusted Legacy, MIT).

Loads happily beside **UltraBadassQuestSaber** — two separate mods, either load order, either one
absent. Saber in the main hand, shield in the off.

## How it plays

It hangs over your off shoulder. Reach up and press **Use**: it is in your hand.

**Hold either off-hand button.** The blades deploy and the saw revs; at the same time it paints
lock-on targets, one at a time, as you sweep your hand across them — a ring goes on each, biggest
over the one the disc will visit first, and your hand buzzes as each lands. A lock *stays* locked:
once it is on, it holds until it dies, leaves a much wider cone, or is out of sight for a moment.

**Let go while your arm snaps forward** and it flies, spinning in the plane your wrist gave it,
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

`Options → Ultra Badass ShieldSaw`:

- **Blocked Projectiles**, **Turned shots go** (back at the shooter / where you look / off the
  face), **Aim help on a turned shot**
- **Turn shots before they reach you** (the sweep) and **Guard generosity**, in cm, on top of the
  measured plate
- **Stop bullets at the muzzle**, **Send stopped bullets back**
- **Blocked Melee**, **Block Feedback and Haptics**, **Perfect Block**
- **Hand Speed to Throw**, **Back in Hand on Return**, **Lock on Targets Max**, **Hit Tiers**
- **Fit** — shield size (1.0 to 1.5, model and block area together), where the disc sits in cm
  from the controller, the block radius and depth, and a ring that draws the block area
- **Tuning** — throw and return speeds, the lock cone and range, the bash (reach, knockback,
  lift), the grind, the rev
- **Debug** — decisions and key codes to the console, and the plate drawn as particles

## Controls

Bind in **Customize Controls**; there are no keys of our own.

| | |
|---|---|
| **Use**, off hand at the shoulder | draw / put back |
| **Offhand Attack** or **Offhand Alt Attack**, held | rev and lock on |
| the same, released with the arm snapping forward | throw |
| the same, pressed while it flies | recall |

Either off-hand button works, because QZD's stock binds put the alt behind a grip shift — the same
grip that arms the two-hand grab. `ssq_lock_button` forces one or the other if you prefer.

## Notes

- **Netplay**: one small pose event a tic while it is out; every decision — block, sweep, muzzle,
  throw — runs from that synced pose, so every machine agrees.
- The plate's geometry is **measured off the mesh**, not tuned by eye, and the size slider picks
  between five baked meshes because MODELDEF cannot scale a model at run time.
- Saw voice and block sparks come from RS_CombatFX (chainsaw archetype).
- Engine study behind the defence work:
  `_reports/QZD173_MELEE_STUDY_2026-10-23.md`.

Details, measurements and the engine's traps: `HANDOFF.md`.
