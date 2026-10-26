# Port scope — what is done, what is wrong, and what Quest could have

Written 2026-10-24, after the package first loaded. It is a correction as much
as a plan: reading the headers of the files I did not port turned up three
defects in the code I did write, each one caused by replacing tested code with a
guess.

Line counts are real. Desktop system: **12,074** lines across
`RS_WorldHands/zscript/hands/`. This package: **2,158**.

---

## STATUS 2026-10-26

- **A1 fixed** — `mass.zs` + `MASSDEF` ported; flight steers on kilograms (D17), and lifts off the floor (D18).
- **A2 fixed for the throw** — palm velocity is differenced in the pawn's frame
  (`aim.zs`), lane 1's change, without porting `rs_swing.zs`/`rs_throw.zs`.
  Measured in the rig: walking at ~5 u/tic and opening a still hand → 0.0 m/s,
  a drop; a 30 cm/tic hand jerk → 10.5 m/s, a throw. A real throw now also
  carries the body's velocity. The fuller `rs_throw.zs` model (arm/object mass
  split) is still unported.
- **A3 fixed** — `policy.zs`, adapted (see DECISIONS: GRIPSUBJ is fork-only, so it
  did NOT port as-is). In the rig: HealthBonus refused, TechLamp refused (the old
  rule pulled every solid decoration), Soulsphere refused until `rsqdg_powerups`,
  barrel chosen over a nearer clip.
- **Haptics and sound done** (Part D items 3 and 5) — `feel.zs`, D14–D16.
- **New bug found and fixed:** turning the palm back out to catch re-locked the
  object already flying at you. The cone now skips anything in flight or in a hand.

---

## PART A — DEFECTS IN WHAT IS ALREADY BUILT

These are not gaps. They are things that are in the package now, that I
described to the owner as working, and that do not.

### A1. Mass is fake. `flight.zs` steers on a number that is 100 for everything.

I wrote that a barrel turns lazily and a clip snaps to the hand, off the actor's
own `Mass`, "no table to maintain". `rs_mass.zs:9-15` says exactly why that
cannot work:

> **WHY NOT `Actor.Mass`.** Doom has a Mass field and it is nearly useless for
> this. It defaults to **100 on every actor**, and the engine reads it for
> exactly one thing — `ApplyKickback`'s thrust divisor. So a Clip and a
> Cyberdemon both report 100, and an **inherited 100 cannot be told apart from a
> deliberate 100**. Trusting it would make a pistol clip as heavy as a player.

It is trusted for **monsters only**, because there the numbers were authored —
50 for a Lost Soul, 400 for a Cacodemon, 1000 for a Cyberdemon, which read as
kilograms closely enough that a second table would be worse.

So right now every non-monster flies identically, which is the exact failing
that was the argument for impulse-and-steer over the parabola in the first
place. **The whole justification for D9 is currently unrealised.**

Fix: port `rs_mass.zs` (396 lines). It is the dependency, not an enhancement.

### A2. The throw counts the player's own movement.

`hold.zs` differences the palm position and uses the peak. `rs_throw.zs:3-6`
says what that is missing:

> `RS_Swing` already keeps the peak of the last ~180 ms of hand movement,
> already measures it **relative to the player** so walking is not a throw, and
> already **discards a snap turn**.

Mine does neither. Walk forward and open your hand and the object is thrown;
snap-turn while holding something and it is thrown sideways. On stock there is
no `VRTurnYaw` to subtract, but the fix lane 1 identified is better anyway:
difference the hand position **in the pawn's own frame**, so a turn rotates hand
and pawn together and cancels with no accumulator.

Fix: port `rs_swing.zs` (428) with lane 1's body-frame change, then
`rs_throw.zs` (401) on top of it.

### A3. The policy grabs abstract quantities.

`cone.zs`'s `Grabbable` is `if (a.bSPECIAL) return true;`. That is precisely the
rule `rs_grabpolicy.zs:4-8` was written to replace:

> The rule this replaces was two lines inside the reach code: a pickup in the
> world, yes; everything else, no. Which means a barrel is not grabbable, a
> corpse is not grabbable, and **a health bonus — a +1, an abstract quantity
> wearing a sprite — is exactly as grabbable as a medikit**.

And it states that the distinction **is not derivable**: Doom gives a medikit and
a health bonus the same flags and very nearly the same collision cylinder, which
is also why the two-hand question cannot be answered from an actor's size. It has
to be a table, ordered, first match wins, so a rule for `HealthBonus` can
overrule the rule for `Inventory`.

Fix: port `rs_grabpolicy.zs` (906). Lane 1 established it has **zero fork-only
symbols** and moves as-is. There is no reason it was not done first.

---

## PART B — THE PORT, FILE BY FILE

| file | lines | verdict |
|---|---|---|
| `rs_grabpolicy.zs` | 906 | **PORT AS-IS.** Zero fork symbols. Fixes A3. Highest value per hour in the whole list. |
| `rs_mass.zs` | 396 | **PORT.** Fixes A1 and makes D9 mean something. |
| `rs_swing.zs` | 428 | **PORT with one change** — body-frame differencing in place of the fork's native velocity and `VRTurnYaw`. Fixes half of A2. |
| `rs_throw.zs` | 401 | **PORT** once swing is in. Fixes the rest of A2. Lane 7 called its `keep = armKg/(armKg+objectKg)` the best thing in the package. |
| `rs_held.zs` | 1748 | **PORT SELECTIVELY.** My `hold.zs` (209) covers one hand holding one thing. Missing: two hands on one object, hand-to-hand passing, the flag-ownership ledger (`hOwnsFlags`), the serialization discipline. Its two-slot table shape is already copied and correct. |
| `rs_flight.zs` | 604 | **PORT.** The shared registry of everything in the air, thrown or dropped, with one corrected gravity so a dropped medikit and a thrown one fall at the same rate. Carries a specific trap: gravity is **added back**, never scaled, because `Actor.Gravity` is saved state and a quicksave mid-flight would persist a third of it forever. |
| `rs_route.zs` | 139 | **PORT, one break.** Using a held thing by bringing it to your face. Needs `HmdPos`, which is fork-only; stock's `HmdPosition` is a different quantity (raw tracking-space metres, un-rotated). Substitute `(pmo.Pos.xy, p.viewz)` and lose horizontal lean. |
| `rs_distance.zs` | 1305 → 454 | **REPLACED, deliberately.** D9 chose impulse over the written parabola. But D9 also said keep the parabola behind a cvar for an A/B, and that was not done — so there is nothing to compare against. |
| `rs_grab.zs` | 1747 → 609 | **REPLACED, deliberately.** The gesture trigger and pose gate replace the grip-arbiter machinery, which has no referent on stock (`GripHeld*`, `GripContext*`, `GrabClaim*` are all zero hits). |
| `rs_grabviz.zs` | 709 → 525 | **REPLACED, deliberately.** No beam native; `VisualThinker` instead. |
| `rs_stabilize.zs` | 911 | **DO NOT PORT.** Lane 7: built on absent natives, not portable. |
| `rs_handnet.zs` | 119 | **DROP.** Netplay, which the owner has said is not a concern on Quest. |

**Port total: roughly 4,600 lines of tested code**, of which `rs_grabpolicy.zs`
and `rs_mass.zs` (1,302) fix live defects and should go first.

---

## PART C — WHAT QUEST COULD HAVE THAT WE HAVE NOT TOUCHED

All verified at stock by lane 2 and unused by anything in this package or the
desktop one. The desktop build never had most of these because the fork gave it
a different way.

### C1. A force shove, for one call. `A_QuakeEx` with `QF_AFFECTACTORS`.

`QF_AFFECTACTORS` plus `thrustMultiplier` plus `QF_SHAKEONLY` is **a radial
kinetic push with distance falloff and no damage**, in a single call. We are
already using `A_QuakeEx` for haptics (or will be). This is a shove gesture —
palm out, flick forward instead of up — essentially free, and nothing in the
family has it.

### C2. A mark on the surface, with no actor. `A_SprayDecal`.

Takes an arbitrary **offset and direction**, so it can paint "this is what your
hand is pointing at" onto whatever the idle line hits, with no actor spawned and
no beam. Cheaper than the laser's terminus flare and it reads at any distance.
Caution: `cl_maxdecals` defaults to 20, so a continuous mark would evict the
map's bullet holes — this is for a moment, not a hold.

### C3. Arbitrary 2D, drawn in the world. Canvas textures.

`ANIMDEFS canvastexture` → `TexMan.GetCanvas` → the **whole 2D API**, including
`DrawThickLine`, `Shape2D` meshes and text → a `TextureID` that a
`VisualThinker` can wear. That is a real reticle, a range readout or a target
name, rendered in world space and depth-correct — which the head-locked HUD quad
can never be. This is the single biggest unexploited capability for VR UI on
this engine.

### C4. Visual motion with no physical motion. `Actor.WorldOffset`.

Moves the **rendered** model without touching `Pos`, so the collider, the
blockmap link and every trace stay where they were. That is weight sag on a
carried object, a lead/lag on a pulled one, and a settle on the catch — all
without the physics or the grab tests seeing a thing. The desktop build had no
equivalent and faked some of this by moving the actor.

### C5. The cone in one native. `Level.SphericalCoords`.

`clearscope`, returns yaw delta, pitch delta and distance from a viewpoint to a
target in one call. No trig, no trace, and **callable from `ui`** — which means a
drawing layer could do its own targeting at frame rate rather than reading a
35 Hz publication. Worth measuring against the current dot-product cone before
committing either way.

### C6. Local-only sound and animation.

`Object.S_StartSoundAt(Vector3, …)` places a sound **at a point with no actor** —
exactly what the laser's terminus and the flying object want. `CHANF_LOCAL`
makes a sound only the acting player hears, from play scope. `SetAnimationUI`
drives a model animation locally without replication, for a purely visual hand
reaction.

### C7. Attachment models share model 0's bones.

Under `+DECOUPLEDANIMATIONS`, extra model slots are skinned to slot 0's bone
matrices. Verified. For IQM meshes it means a hand and a held thing can animate
as one rig. The guns are MD3, which ignores the shared bones — but this is the
mechanism behind any future hand-plus-object work, and it exists today.

### C8. Persistence in one string. `Dictionary.ToString()` / `FromString()`.

Per-player tuning, learned clip timings, remembered preferences — serialised into
a single string with no new lump and no cvar per value.

---

## PART D — SUGGESTED ORDER

1. **`rs_grabpolicy.zs`** — ports as-is, fixes A3, biggest behaviour gain.
2. **`rs_mass.zs`** — fixes A1, and without it D9's whole argument is unrealised.
3. **Haptics** (`A_QuakeEx`) — an hour, and it changes the feel of everything
   already built. Acquire tick, lock thump, arrival ramp, catch snap.
4. **`rs_swing.zs` + `rs_throw.zs`** — fixes A2.
5. **Sound** (C6) — cheap, and the mechanic is currently silent.
6. **The voxel/model swap (D12)** — the owner's own favourite, but it carries
   the `Become` and `AskTake` hazards and wants building when it can be tested
   the same session.
7. **`rs_flight.zs`**, then **`rs_held.zs`** two-hand and passing, then
   **`rs_route.zs`**.
8. **The parabola behind a cvar**, so D9's A/B can actually happen.
9. Then the new capabilities: C3 (world-space canvas UI) is the one with the
   most in it, C1 (the shove) is the cheapest.

**Not in this list and still open:** D11, the off-hand skeletal question, parked
with the dual weapons; drawing the hands at all, which has two verified IQMs and
no MODELDEF; and the coordination `Service` from D8, which has no consumers yet
because nothing else on Quest asks.
