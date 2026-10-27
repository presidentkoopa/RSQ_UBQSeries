# Decisions — RSQ_DistanceGrab

Owner decisions, as made. One line per decision, with the shape it implies and
the citation it rests on. The reasoning lives in
`C:\Users\Command\Desktop\GRAB_AND_OBJECT_MANIPULATION_ON_QUESTZDOOM_2026-10-24.md`;
this file is the record of what was chosen, so nobody has to re-read 1754 lines
to find out.

All engine citations are against **stock qzd17.3**, which is the git tree
`670d19eba6^` in `E:\DOOMWork\QZD17-engine`. That checkout's HEAD is NOT stock.

---

## D1 — INPUT CHANNEL: a KEYCONF action + netevent. DECIDED 2026-10-24.

Not a usercmd bit. The owner took the §7.2 recommendation.

**Why this and not a bit.** Every bit is contested by mods we cannot see or
modify, and our own census only ever saw our own packages — the lesson learned
twice, first on `BT_USE` and then on `BT_USER1..4`. A KEYCONF action consumes no
usercmd bit at all, so contention is **structurally impossible** however many
foreign mods are loaded. It is also the channel `UltraBadassQuestSaber` already
uses for all its non-trigger inputs, so there is a shipping precedent on this
engine.

**The shape:**

- `addkeysection` + `addmenukey` register a rebindable action that appears in the
  stock Customize Controls menu.
- `defaultbind` gives a working default **without writing the owner's ini**,
  which is read-only.
- `+name` / `-name` falls through to alias lookup when it is not a buttonMap
  action, and key-up rewrites `+` to `-`, so **press and release arrive as two
  separate netevents**.
- `netevent` reaches `NetworkProcess` / `NetworkCommandProcess` at the **top of
  the tic, before `P_PlayerThink`** — earlier than `WorldTick`, so better timing
  than reading a bit.
- Replicated, and `player >= 0` identifies who pressed it.

**The one real cost, and its fix.** A netevent is an **edge, not a continuously
readable held state**. A hold-based gesture therefore needs the held state
tracked mod-side, and a dropped release would leave it stuck on. So the held
state gets a **lease**: it expires unless re-asserted, the same shape as the grip
arbiter's `LEASE_TICS`. About a dozen lines, and it buys immunity from every
other mod on the system.

**Carry the target's network ID, never a raw pointer.** `Object.GetNetworkID()`
is a `uint` and a `ConsoleEvent` carries three ints, so one argument does it.
Every actor already carries a replicated, `clearscope`, savegame-stable network
ID — `p_mobj.cpp:4996` enables networking on every actor at spawn. Mind the
recycling trap: IDs come off a free list, so a stored ID can resolve to a
different actor. Validate on use.

### Consequences of taking this instead of `BT_USE`

- The `ui InputProcess` conditional-consume machinery (§7.4) is **not needed**.
  It stays on record as the fallback if the decision is ever revisited, and it is
  the only true suppression route: `G_Responder` calls the ZScript responder at
  `g_game.cpp:1088` and returns if it ate the event, while `C_DoKey` is not
  reached until `:1152`.
- No geometric hand-picking is forced on us. `BT_USE` is one bit for two hands
  (there is no `BT_OFFHANDUSE`; the full list is `constants.zs:832-870`), which
  would have required "the hand with a cone target wins, main breaks the tie".
  A KEYCONF action can simply be bound per hand.
- We do not inherit the `doublebind pad_a "slot 3"` collision in the stock VR
  layout, where a quickly-retried grab would switch weapon.
- `RS_ShieldSawQ`'s existing `BT_USE` reads (`zscript/ssq/state.zs:270-274` and
  `:916`) are left alone. The shield keeps the bit; we never contend for it.

### Still worth copying from the shield

Its `OnPress` (`state.zs:321-342`) computes hand-to-shoulder distance and
`return`s if `!atMount`. It never writes `cmd.buttons`. A press at the shoulder
draws the shield; anywhere else it passes straight through to the door. That is
observe-and-yield, shipped, on Quest — and it stays the reference implementation
for how our gate behaves even though we are no longer sharing a bit.

---

## D2–D13 — DECIDED 2026-10-24

Taken in one sitting. Where the owner went against the report's recommendation
it is marked, with the reason, because a future session will otherwise "correct"
it back.

| # | Decision | |
|---|---|---|
| **D2** | **Three acts** — point → lock → launch. Lock on the **press edge**, catch on the hold. | as recommended |
| **D3** | **Wrist tip only.** Mode 1, differencing `AttackPitch`. **Mode 0 dropped** — frame-broken on stock. | as recommended |
| **D4** | **Release decides, by speed.** Moving = throw, at rest = drop. No separate throw input. | as recommended |
| **D5** | **Stand-off carry.** Object floats where it was grabbed, not dragged to the face. Must **freeze on `menuactive`**. | as recommended |
| **D6** | **Moot — no decision needed.** See below. | — |
| **D7** | **TWO systems.** Claw and distance grab stay separate. | **against the recommendation** |
| **D8** | **A `Service`**, shipped with the grab, reachable by name only, answering "what is in this hand's way" with evidence rather than permission. | as recommended |
| **D10** | **Laser blocked by walls.** `VisualThinker` chain for the shaft; `ModifyBobLayer3D` on a psprite for hand-glued parts. Route psprite layers by **explicit caller, never layer id**. | as recommended |
| **D11** | **Parked** with the dual-weapon question. | deferred |
| **D12** | **Voxel/model swap on lock AND through the flight.** | **against the recommendation** |
| **D13** | **Built-in network ID** for identity after acquisition. | as recommended |

### D6 was never a question for this mechanic

"Does a held monster keep thinking?" came from the Power Loader, whose purpose
is seizing and crushing Aliens, and from the saber's Force grip. **The distance
grab cannot hold a living monster at all.** `rs_grabpolicy.zs:694-696`:

```zscript
if (a.bISMONSTER)
{
    if (a.Health > 0) return null;
```

Only corpses are ever grabbable, and the policy says why — *"it is a way of
deleting monsters. A corpse is a prop, and one worth having."* The synthesis
report was writing about all three systems together and carried the question
across. Nothing to decide.

### D7 — why two systems, against the recommendation

The report argued one system because *"they differ by three numbers and a
bool."* That understates it: **the claw grabs living Aliens and crushes them;
the distance grab refuses anything living** (D6 above). That is not a parameter
difference, it is a different mechanic.

The cost the report warned of is real and must be managed rather than dismissed:
two systems means **two flag-ownership implementations that can both touch one
actor**, which is the §11.2 trap. Mitigation: the two must never hold the same
object at once, and whichever takes an object is the single named owner of its
flag backup. The desktop tree states that rule three times because it bit three
times.

### D12 — voxel through the flight, against the recommendation

The owner wants the swap to persist for the whole gesture: *"being able to
distance grab a sprite and have it turn into a 3d model in the air while flying
to me, or a voxel, was a lot of fun."* The report recommended lock-only and
warned that keeping it through flight **must be tested against two specific
paths**:

- **`Become`** (`rs_distance.zs:747-765`) swaps the actor mid-catch, so the lent
  model is on the object that is being discarded.
- **`AskTake`** / `OnTake` can consume the object on the way in — a weapon that
  equips, a third copy that becomes ammo — so there is nothing left to take the
  model back off.

Both must be handled before this ships, or an object ends up permanently wearing
a borrowed model with nothing able to remove it. Same shape as the flag-ownership
trap: whoever lends is the single owner of the restore, on every exit path
including the unplanned ones.

---

## Open, carried forward

- **D9 — the flight: parabola or impulse.** The one genuinely open *design*
  question. Recommendation on record: build impulse-and-steer, keep the parabola
  behind a cvar, settle it in the headset. Lanes 1 and 7 disagree and the
  disagreement is real — lane 7 is right on the engineering, lane 1 right on the
  risk, since the parabola is the only finished part and `MeasureArc` exists
  because a kinematic path can be route-planned and an impulse path cannot.
- Every other decision has a recommendation in §13 and none has been taken yet.

---

## D9 — THE FLIGHT: impulse-and-steer, parabola behind a cvar. DECIDED 2026-10-24.

The owner took the §10.1 recommendation. Lanes 1 and 7 disagreed here and the
disagreement was real: lane 1 ports `RS_Pull` almost whole, lane 7 wanted it
deleted.

**Why impulse wins on the engineering.** `RS_Pull` flies a **kinematic**
parabola — `a.Vel = (0,0,0)` in five places, position written per step — which
fights the engine exactly where `rs_throw.zs:9-13` says to use it: *"AND THEN
DOOM DOES EVERYTHING ELSE. `P_XYMovement` and `P_ZMovement` give gravity,
floors, ceilings, stairs, wall sliding, bouncing and impact — for a thrown
object those are not features to implement, they are what an actor with a
velocity already does."* A scripted path also **cannot carry mass**, so a barrel
and a clip fly identically while the outbound throw has the best weight model in
the package (`rs_mass.zs`), and it **cannot be a reel** — a continuous pull-in
rather than a launch-and-arrive.

**The shape:** a launch velocity, `P_XYMovement`/`P_ZMovement` own the flight,
with bounded steering acceleration toward a lead point scaled by `1/mass`.

**Why the parabola stays behind a cvar.** It is the only *finished* part of the
desktop flight — `MeasureArc`, `flyHold`, the tumble, the flag ownership and the
radius shrink are all tuned against each other. The two paths share acquisition,
lock, catch, hold and release; only the ~300 ms between launch and arrival
differs, which makes it the cheapest thing in the system to A/B. **Do not delete
`RS_Pull` before both have been flown in the headset.**

### THE ONE LESSON AT RISK — check it, do not assume it

Lane 7 asserts all of §11's hard-won lessons carry forward. **§11.3 is the one
that does not obviously survive, because an impulse path has no arc to plan.**

The desktop lesson: *"Clamping is the wrong remedy: it does not lower the arc,
it SQUASHES it, pinning the object to whatever surface it met and dragging it
there. Every 'it hops and settles instead of sailing' report is that clamp doing
its job."* `MeasureArc` exists precisely because a kinematic path **can** be
planned against a whole route — it samples one point per 24 units, takes
`minCeil` and `maxFloor` over the entire path, and decides the shape **once, at
launch**.

An impulse path gets mass and the engine's physics for free and **loses route
planning**: a pull under a low doorway stops being a flatter arc and becomes a
steering problem. The generalised rule still applies — *decide the shape of a
motion once, at the start, against the whole route; clamping per-tic against a
local obstacle deforms it instead of avoiding it* — but the mechanism that
delivered it does not port. **This is the specific thing to watch when the
impulse path meets a doorway.**

Also carried forward regardless of path (§11.3, smaller): a Doom pickup's
`radius` is a **pickup-trigger volume, not a physical hull** — a clip is radius
20, the same as a shotgun guy — and *"flying a 40-unit-wide box through a
doorway for an object the size of a fist is what produced twelve blocked pulls
in one session, every one of them a radius-20 pickup and not one of them a
radius-10 barrel."*

And §11.1's dwell requirement is path-independent and **will** bite on Quest: a
state that exists for zero tics cannot be observed by anything reading last
tic's value, so every arrival, catch and handover needs a dwell. The trap hides
at short range because the residual error is a constant number of units, so it
appears only on the first long pull — *"the loader's clean record is no evidence
against it"* at 72 units when the cone reaches 512.

---

## Corrections to this file

**The Aliens `MENUDEF.ae` bug I recorded here on 2026-10-24 was already fixed,
and I removed it.** I relayed it from `AUDIT_2026-10-23_bugs_and_qol.md` §4.1
without checking the file. `MENUDEF.ae` carries its own comment dated
2026-10-23 recording the fix, and the design changed as well: those values were
usercmd button masks, which was the wrong shape for the choice — *"'Either' let
the grip and the trigger both grab, and 'Use key' put `BT_USE` in the mask,
which grabs a magazine AND opens the door behind it."* It is `rsr_grab_with`
now, picking one input and intercepting it for the duration of the reload.

Lesson for this file: an audit document records what was true when it was
written. Check the tree before repeating it.

---

## D14–D18 — TAKEN 2026-10-26, distance grab + feedback pass

Scope set by the owner this session: **the distance grab and its feedback only.**
Hand models, two-hand holds, hand-to-hand passing and the D12 voxel/model swap
are out of scope for now.

| # | Decision | |
|---|---|---|
| **D14** | **Haptics are rhythm, not strength.** One per-hand route exists on stock: `SpawnPlayerMissile` buzzes the firing hand at a fixed 0.8 for a fixed 150 ms, and the Quest runtime ignores a request while the channel is busy. So: tick on lock, tick on launch, an approach ping that speeds up (16 → 7 tics apart), silence for the last 2.5 catch radii, tick on catch (two if heft ≥ 0.55), tick on release. | new |
| **D15** | **The buzz actor is NOT a missile.** `RSVR_Buzz` is `Projectile;`, and Brutal22Q's recoil/flash hooks treat every player missile as a shot except `RSVR_Buzz` by name. `RSQDG_Buzz` has no `+MISSILE`: P_CheckMissileSpawn treats it as an MBF grenade, the haptic still fires, `WorldThingSpawned` sees `bMissile == false`. Verified in the rig: `missile=0`, and `QzDoom_Vibrate(150, chan, 0.8)` once per buzz. | new |
| **D16** | **`A_QuakeEx` rejected for haptics.** It gives per-side amplitude but shakes the view by the same map units, and half its samples are zero (random ± intensity). ShieldSawQ's `SSQ_FX.Buzz` comment ("the view does not shake") is not true at useful strengths. | new |
| **D17** | **Mass becomes a share of the pull, `k/(k+kg)`**, `k = rsqdg_pull_kg` (10). Cruise speed scales by `sqrt(share)` (floor 15%), steering authority by `share` (floor 5%). The desktop throw's own `armKg/(armKg+kg)` shape, pointed the other way. Timeout is per pull: `max(menu, 2 × travel + 1 s)`. | new |
| **D18** | **A pull lifts the object off the floor first.** Found in the rig: Doom's ground friction (~9%/tic) applies to a grounded actor regardless of `NOGRAVITY`, and at the barrel's 0.14 share it won — the barrel slid at a third of its cruise. Launch now pops it 1 unit up with ≥1.5 u/tic rise, and it is kept off the floor while it still has to climb. A pull down off a ledge is not lifted. | new |

### Policy: what changed from the desktop table, and why

- `GRIPSUBJ_*` and `POSE_*` **dropped**. `GRIPSUBJ_*` is a fork engine constant —
  zero hits in stock wadsrc and zero declarations in the desktop's own zscript —
  so lane 1's "zero fork-only symbols, ports as-is" was wrong; a verbatim copy
  does not compile.
- **Weapons ON** by default (desktop: off). The desktop objection was to a HAND
  grab of a gun; a pull is the pickup from further away, which this package has
  always done.
- **Powerups are a switch, OFF by default** (desktop: denied outright). Catching
  a megasphere off a ledge has an obvious meaning for a pull that it does not
  have for a hand.
- Walk-over suppression, the ammo-pouch branch and `Become`/`AskTake` **not
  ported** — near-grab features or D12 hazards.
- Mod registration keeps the desktop protocol (`grab.hello/rule/weight/forget`,
  any Service whose name contains `GrabRuleService`) and adds `grab.deny`.

### Things found on stock that a future session will otherwise get wrong

- **The WeaponDepot rig's prebuilt engine is not 17.3.** `tools/rig/bin/qzdoom`
  lacks the `S_StartSoundAt` native and its `res/qzdoom.pk3` declares ZScript
  **4.12**; the rig's own build.sh names `25cecc097` (2026-07-15). The `qzd17.3`
  tag is `9afc750` (2026-08-18, ZScript 4.14.2), 329 commits later. So this
  package avoids `Object.FindClass` and `S_StartSoundAt` and runs on both.
  Rebuilding the rig from `9afc750` needs SDL2 dev files for its CMake configure
  step, which were not obtainable in the cloud session.
- **`670d19eba6` (quoted at the top of this file as the stock base) is a commit
  in the owner's local checkout only** — it is not on emawind84/gzdoom. The
  public stock ref is tag `qzd17.3` = `9afc750`.

## D19 — THE LASER IS THREE MODELS, NOT A BEAD CHAIN. 2026-10-26.

Owner, in the headset: the bead laser "looks like it's having a seizure, there's
no way this will work". 48 billboards re-placed 35x/s against a hand rendered at
headset rate, motes wrapping end to end. Removed entirely.

| piece | what | from |
|---|---|---|
| beam | model: 3 crossed planes x (core + halo), soft bell skin, additive | the lightsaber-blade trick |
| dot | one glow sprite at the hit, scaled with distance | QZD's bundled laser-sight (GPL-3: idea only, no code) |
| cone | wire edges + 2 rings + faint shell, 1 MD3 frame per degree of half-angle | DXR `hw_weapon.cpp` DrawDebugWireCone/SolidCone |

**The length trick.** An actor's `Scale.X` scales both horizontal model axes,
`Scale.Y` only the vertical. The beam is authored along +Z and the actor pitched
+90 past the aim, so `Scale.Y` = exact length, `Scale.X` = width. The cone cannot
use it (its width and length must both follow its own axis), hence one frame per
degree and uniform scale = reach / 256.

**CORRECTPIXELSTRETCH** on both: the 1.2 stretch is applied in world space after
rotation (r_data/models.cpp), so they are authored and aimed in ROOM space — the
same space cone.zs tests in — and land exactly on map-space endpoints.

Cone skin fades in over the first 30% of reach (the edge tubes converging at the
palm crowded the beam near the eye). All three colour by state via translation
(new `RSQDG_Idle` blue). Verified by frame dump in the rig; lag vs DXR's per-frame
C++ drawing is ~1 tic, untested in a headset.

## D20 — THE HAND END IS DRAWN ONE TIC AHEAD. 2026-10-26.

Why the beam/cone lag and the gun does not: the renderer places the weapon from
the pose it read THAT frame; script places actors once per tic and the renderer
draws a blend of the last two tics — where the hand WAS, 0–1 tic ago. Fix: place
the hand end at palm + v x `rsqdg_lead` (tics, default 1.0), v differenced per
tic in world space; direction and the idle beam's wall point are led the same
way; a >0.5 m/tic jump leads nothing. With Pos = hand+v and Prev = last hand+v,
the renderer's Prev+(Pos-Prev)f = hand + v·f: lag and lead cancel.

Measured by `tools/rigtest/leadsim.py` (engine interpolation formula, 35 Hz
sampling of a pose up to one 90 Hz frame old):

| motion | no lead avg/max | lead 1.0 avg/max |
|---|---|---|
| slow sweep 1 Hz 30 cm | 4.0 / 6.7 cm | 1.1 / 2.8 cm |
| fast sweep 3 Hz 20 cm | 7.9 / 13.3 cm | 4.3 / 8.4 cm |
| 2 m/s swing, hard stop | 1.7 / 7.8 cm | 0.3 / 4.2 cm (overshoot) |

1.0 beats 1.2/1.3/1.5 overall. The fast-sweep residual is direction reversal
within a tic, which no linear lead can follow. The real fix is drawing in the
renderer (DXR did) — available on UZDXREMA, not on stock QZD.

## D21 — HAPTICS: THE RUMBLE ROUTE, AND WHY IT IS A ROUTE. 2026-10-26.

Reverses D16's rejection of `A_QuakeEx`, on the synthesis report's §1.1/§8.4 plus
three things read this session:

- **Amplitude without noise.** `QF_WAVE`, `mulWave 17.5`, duration 2 re-issued
  every tic: the quake is always at countdown 1 when drawn (spawned in WorldTick,
  ticked once by RunThinkers the same tic — dthinker.cpp:153-160), so the wave's
  phase is π·(1 − ticFrac) and the jigger is never negative. Without QF_WAVE it
  is a random ±intensity draw: half the frames nothing. Peak = 4 × intensity ×
  `vr_quake_haptic_level`, so intensity = amp / 3.2. **Measured** (rig, gdb on
  `QzDoom_Vibrate`): 330 rumble writes, amplitudes 0.00–1.00, none negative, all
  on the main hand's channel, the other hand at 0.
- **It and the pulse cannot share a controller.** `TBXR_Vibrate` refuses a
  request while the channel has time left. The quake writes BOTH channels every
  frame (a 0-amplitude hand still gets a 10 ms request) after that frame's
  haptics update and before the next tic — so any missile buzz during a rumble
  is dropped. Hence a route switch (`rsqdg_rumble`), not a layer: with rumble on,
  every event is a spike in the rumble's own amplitude timeline.
- **The price:** while the rumble runs, everyone else's buzz (a weapon's fire
  buzz) is dropped too. So it runs only while it means something — locked,
  flying, a spike, a strained carry — never while merely pointing or carrying
  freely.

Vocabulary: lock 0.55 spike then a steady `rsqdg_rumble_lock` (0.15) × heft;
launch 0.75; flight builds 0.10→0.40 × heft with 0.60 ramp ticks; silence in the
last stretch; catch 1.0 (twice, 2 tics apart, if heavy); carry strain
(metres held back − 0.08) × 1.5, cap 0.6. Off-route (`rsqdg_rumble 0`): the D16
pulse rhythm, verified unchanged (7 × 150 ms vibrates, zero quake writes).

## D22 — THE CARRY IS A SPRING TOWARD A STAND-OFF. 2026-10-26.

Resolves the HANDOFF's open "D5 vs hold.zs". `vel = bodyVel + clamp(armVel ×
share + (target − pos) × k)` — the body's own motion fed forward in full, only
the arm's scaled by mass (review: scaling the whole palm delta made walking with
a barrel a permanent 0.8 m lag, constant rumble, and dropped it at a run;
re-measured walking: strain 0.00–0.07, no rumble); target = palm + hand direction × (`rsqdg_hold_dist` 0.30 m +
the object's half-size), per-axis room→map. k = `rsqdg_hold_k` × (0.33 + 0.67 ×
share); vmax × sqrt(share). Light things stay glued to the hand, heavy ones
trail; walls refuse, so pinning happens on its own, and the refusal is
**strain**, which the rumble plays and which ends the hold after 18 tics past
`rsqdg_hold_break` (1.5 m). Pickups are thinned to half their height while
held (their radius is a trigger, the flight's lesson). A bad pose freezes
(velocity 0) and throws nothing. Measured: barrel settles 0.59 m ahead of the
palm, strain decays 0.59 → 0.00 in ~16 tics; pushed into a wall it pins (strain
25 m, rumble 0.6) and is let go at tic 18.

## D23 — THE THROW HAS WEIGHT AND A LANDING. 2026-10-26.

Release keeps `arm/(arm+kg)` of the hand's speed (`rsqdg_arm_kg` 30: keycard ≈
all of it, 60 kg barrel a third — the MASSDEF comment's own numbers). Thrown
things go to `throw.zs`: the loader's TickFlung (speed below half of last tic =
impact; one impact per throw), plus an overlap test because pickups are not
solid and fly through monsters. Damage = ½mv² / `rsqdg_throw_j` (15 J/pt).
**Doom gravity is ~4.4 g** (1 u/tic², 28.3 u/m vertically), so vertical speed is
scaled by √(g/g_doom) before it counts — found when the first rig run blew a
barrel up after a gentle throw from hand height. MASSDEF `impact explode` now
read (and through the replacee chain, so BD22's `ExplosiveBarrel1` obeys it):
≥ `rsqdg_throw_explode` 6 m/s sets it off, thrower credited. The thrower's
horizontal velocity, added at release so the object keeps up with you, is taken
back out of the impact speed (Doom walking is ~8 m/s). On release the object's
collision, size and collectability go to a **settle list** that restores each the
first tic it fits (a solid barrel made solid inside the player locks both), with
10 tics of uncollectability after a throw; anything that borrows the object next
(flight, hold) makes the settle hand back first. Not `+MISSILE`
(report §5.4). Measured: clip at 8.9 m/s hit a ShotgunGuy for 1; barrel throw
2.3 m/s → landing, no explosion at 6; BD22 barrel went off at 4.1 m/s with the
threshold at 2.

## D24 — HEAVY THINGS SLOW YOU. 2026-10-26.

`RSQDG_Burden` inventory token, `GetSpeedFactor = 1/(1 + kg/rsqdg_burden_kg)`
(120: barrel 0.67, two barrels 0.5). The only hook that works in VR (report
§5.1). Given, rewritten and destroyed every tic by the hold handler; destroyed on
map change. Measured: 0.67 while the barrel is held, gone the tic it is let go,
survives save/load with the carry.

## D25 — THE TARGET GLOWS: "COULD" AND "HAVE". 2026-10-26.

The saber's `UBQS_GripGlow` twin (report §8.3): AddStencil, `SetShade`, wears the
host's sprite/frame/angle/scale/flips/offset ×1.06, 1.5 units toward the eye,
Prev offset with the host so it interpolates with it. Could = amber at the
saber's 0.55 strength; have = green, twice the tempo, peak 0.32 — measured in a
frame dump that 0.55+ of additive green over Doom's green barrel is a solid slab.
Default ON; the translation flash (`rsqdg_lightup`) is now default OFF and still
available. Caveat: with the self-taking lock the "could" state is brief — the cone
only runs with the palm out, and a target found with the palm out locks almost at
once. It shows in full only where a lock is refused.


## D26 — A HILT IS NOT A SWING: YIELD BY EVIDENCE. 2026-10-26.
`rsqdg_yield` stood the hand down for any UBQS_ weapon, so with the saber's dual
mode the off hand never grabbed. The evidence that a saber is not being swung is
its blade being off. The psprite frame does not carry it (world saber on = frame
18 always, rig). So the saber publishes `saber.lit` through a Service and the
grab asks by name; no answer means busy, the old behaviour.

## D27 — THE DWELL IS OPTIONAL. 2026-10-26.
`rsqdg_lock_dwell` defaults to 0 so nothing changes until the owner tries it.

## D28 — ONE BEAM PER HAND. 2026-10-26.
With RSQ_LaserSight drawing on a gun hand, the grab's beam doubled it. The laser
publishes `laser.active`; the grab hides only its beam there (dot and cone say
what the grab would take, which the laser does not). `rsqdg_beam_yield`.

## D29 — THE ARC IS BACK FOR THE A/B, AND THE PULL DUCKS. 2026-10-26.
D9 promised the parabola behind a cvar. RS_Pull is not in this tree, so the arc
is rebuilt on D9's own terms: no kinematic path, the engine still moves it; each
tic the velocity is the ballistic solution onto the palm for the time left, so
walls, floors and the moving hand all still work. Steer stays the default.
Time of flight is chosen by height (a lob peaks at g t^2/8): `rsqdg_arc_apex`,
the ceiling midway, and no faster than twice full flight speed.
Ducking: a lintel is a lower ceiling a few units ahead; capping vel.z to pass
under it is cheaper than routing, and the engine still owns everything else.

## D30 — WORLDHANDS' GRAB, PORTED; THE RENDER-RATE BEAM LEFT. 2026-10-27.

The owner wants RS_WorldHands' fine details. Taken, with its numbers: the written pull path
(now the default flight, mode 2; Steer and Lob stay selectable -- in WorldHands mass never
changed the pull, so a barrel and a clip now fly the same path, and Steer is the mode where mass
still shows), the tumble (sprites by render flags; voxels by SetModelFlag + WorldOffset, which
stock has), the air for everything let go (0.27 g added back; drag; flutter), the carry's wrist
turn, sag and strain rumble, and its silence. Changed for this engine: the wrist turn is relative
to the catch, because here the palm pose IS the hold and the wrist is always rolled a quarter turn.

Left, and why:
- WorldStep (fork-only): the air runs on WorldTick; RSQ_SlowMo scales Gravity by f^2, so the
  add-back (GetGravity-based) slows with it and stays under its impulse threshold.
- VoxelOverride, FollowHandMode/FollowHandOfs, level.VRHaptic, HandVelAtPoint, MainHandRoll,
  Level.SetBeam/ClaimBeam: fork natives. Their stock substitutes are noted where used; the
  sag lowers the carried thing instead of the drawing.
- WorldHands' impact model (momentum both ways, 0.1 J scale, 200 cap): ours (D23) feeds the
  scorer's ledger and was tuned against Doom gravity; kept.
- Its reach ovals, volume box, two-hand holds, passing, routing to the face: hand-model or
  near-grab features, outside this pack (D12 scope).
- RENDER-RATE BEAM AND CONE (the laser agent's idea: a psprite layer the renderer places with
  the controller each frame). Measured in the rig: a layer is drawn in a hand's frame only when
  its CALLER is that hand's weapon (models.cpp RenderHUDModel), and its model is looked up by
  the caller's CLASS, so on the off hand -- BD22Q's free, grabbing hand -- only a VOXEL can be
  drawn (found by sprite frame). A voxel wire cone at the cone's size is 1.3 to 4 map units per
  voxel: frame dumps show blocky staircases near the hand where the MD3 cone has 0.55-unit tubes.
  The layer also turns about a point 0.30 m behind the palm (the HUD origin) and would need a
  root VOXELDEF the hub build does not ship. So the beam and cone stay world models with the
  one-tic lead (D20); they were made to agree with the tested cone instead.
