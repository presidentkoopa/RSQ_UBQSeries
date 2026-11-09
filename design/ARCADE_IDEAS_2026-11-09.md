# Arcade ideas, 2026-11-09

Nine ideas kept by the owner on 2026-11-09, for a stew ("we want to try and cook up a stew with these"). Nothing here is built or designed to the end. Each one: what the player
sees and does, the decision it makes, what it uses from the series, what would have to be made, and what is open.

---

## 1. Ride it (Claude's)

**Sees / does:** you hook a cacodemon. Heavy monsters pull you to them, so you land on its back. Hold it in a
headlock and turn its head: it fires where you point it, into its own crowd. When it dies, you fall.
**Decision:** ride it through the room or jump off.
**Uses:** RSQ Grapple (heavy monsters pull you to them, `Grapple/README.md:72`); RSQ Melee's Headlock (up to mass 400,
`Melee/README.md:120`); RSQ Whip as reins; RSQ Monsters (a higher colour or an EX is a harder ride).
**Make:** riding (the player carried by the monster every tic) and steering it.
**Open:** steer only the head (where it fires), or where it walks too. VR comfort: being carried while your head
moves on its own is exactly the case handoff section 4 warns about.

## 2. The holster thief (Claude's)

**Sees / does:** a lost soul dives at you, rips the shotgun off your hip and flies for the door with it. Pull it back
out of the air, or crack the soul down with the whip.
**Decision:** guard your body or fight the room.
**Uses:** RSQ Tactical Rig (guns live on your body); RSQ Distance Grab (pull guns and catch them,
`DistanceGrab/README.md:20`); RSQ Whip (the crack, `Whip/README.md:22`); Gun Bonsai VR (the gun keeps its levels).
**Make:** the thief, and taking a gun out of a holster.
**Open:** what brings the thief. It should be something you do (a full holster left unguarded, a gun with high
levels), not chance.

## 3. Call it down (Claude's)

**Sees / does:** when your Bossfight is ready, throw a flare. The miniboss teleports in where the flare lands, and
anything standing there is telefragged. You pick the spot: into the thickest part of the crowd.
**Decision:** where the fight lands.
**Uses:** RSQ Miniboss (the Bossfight's arrival where you can see it); RSQ FnF (the throw, `FlashFlare/README.md:26-28`);
RSQ Monsters' EX forms could be what lands.
**Make:** the arrival point taken from the flare.
**Open:** how much the telefrag kills: everything under the landing spot (a room clear), or only the small fry (the
throw is about placing the fight).

## 4. The chunk boss (owner's)

**Owner:** "for ex monsters, we could set it so that they take damage by killing other specific monsters. so, a
boosted legendary champion black cacodemon EX would have like 60k hit points, but if we only need to kill specific
monsters or accomplish specific things, to damage it in chunks, that could be something"
**What the player sees (Claude's reading):** a huge Black Cacodemon EX, boosted and Legendary, that your bullets do
nothing to. Its health bar is cut into chunks. Somewhere in the crowd are the monsters that matter. Kill one and a
chunk comes off the boss. The fight becomes a hunt through the crowd, with the boss above it the whole time.
**Uses:** RSQ Monsters' EX forms (Black Cacodemon EX: 10,000 health on its own,
`Monsters/zscript/monsters/cacodemon/RS_Cacodemon.zs:1756`; spawnable by name); Champions and LegenDoom for the boost;
DOWN's crosshairs, edge arrows and target lines to mark the monsters that matter (handoff 3.2); VisualRewards' HP bars
and the large HUD bar of handoff 6.2 for the chunks. "Specific things" could be the keypad (nc-keypad), the key monster
or a reflected shot.
**Make:** a boss your guns can't hurt (handoff section 7, "no-damage monsters"), and the link from a marked kill to a
chunk.
**Open (asked, owner: "dunno"):** does a kill take the chunk off by itself (the boss flinches, its bar drops), or does
it leave something you have to get to the boss (a soul thrown into it, a barrel locked onto it)?

## 5. The circle (owner's)

**Owner:** "i had a prototype once of a blue circle on the floor which moved itself smartly through the map, towards
keys or doors. combining pathfinding with objectives. it went well. my plan was to try and stay inside the shape as it
moved. ... we could find fun game modes based on autonomous color shapes."
**Uses:** zdoom-pathfinding (disasteroftheuniverse, MIT: a navmesh for each map, baked ahead of time by its generator
tool and saved as JSON; A* plus a funnel at runtime; an agent moves only within one connected group of the mesh);
Vortex's Universal Objective System (VUOS 0.4.0, MIT) for where it goes; RSQ Monsters' 13 colours for what colour it is.
**Make:** the shape (a flat thing on the floor in a ladder colour); a baked navmesh for every map.

Ideas 6-9 are game modes under idea 5: a shape plus a rule about it.

## 6. Ghosts (Claude's)

**Sees / does:** four coloured circles hunt you through the map's corridors, each by its own rule. Red comes straight
at you, pink cuts you off ahead, cyan flanks you, and yellow wanders (Pac-Man's ghosts). Touch one and its colour's
monsters teleport in on top of you. Grab an OmniShield and it flips: they run, you chase, and catching one pays out.
**Decision:** the route you take through the map, every second.
**Uses:** pathfinding; OmniShields as the power pellet; RSQ Monsters (each circle's colour is a tier); RSQ Miniboss's
teleport-in.

## 7. The bubble (Claude's)

**Sees / does:** a pale circle drifts toward the exit. Inside it you have slow motion; step out and the world runs at
full speed. It doesn't wait for you.
**Decision:** fight in comfort inside it, or break out to grab the thing it's leaving behind.
**Uses:** pathfinding; VUOS for where it goes; RSQ SlowMo started and stopped by name (`rsqsm_start`,
`SlowMo/zscript/rsqsm/clock.zs:34`).

## 8. Push it (Claude's)

**Sees / does:** a circle only moves toward the next objective while you stand in it with no monster inside. Monsters
know this and crowd into it to stall it.
**Decision:** stay in and hold the line, or step out and clear the crowd while it stops. In co-op, one player holds it
while the others clear.
**Uses:** pathfinding; VUOS objectives; the arena rooms drawn in `tools/mapview/`.

## 9. The kill zone (Claude's)

**Sees / does:** the chunk boss (idea 4) can only be hurt while it's inside the circle, and the circle won't stop for
it. You lure the boss in with Grapple, Whip, flares and noise, then throw everything you have.
**Decision:** fight the boss where it is, or spend time herding it.
**Uses:** idea 4; RSQ Grapple and RSQ Whip pulls; RSQ FnF flares as bait.

---

## The shelf: outside mods the owner supplied (2026-11-09)

Available, not planned for. "We don't have to use these, but we now have these to be used." The owner singled out the
keypad.

| Mod | What it is |
|---|---|
| nc-keypad (Blue Shadow, v2.0) | Doom 3 keypad: a line in the map runs it, a 3-digit code opens it, a correct code runs a reward script; up to 16 per map. Today a flat menu worked with movement keys and fire, so in VR it becomes real buttons. Art and sounds are id's Doom 3. |
| zdoom-pathfinding | see idea 5 |
| VUOS 0.4.0 | objectives and waypoints, made for keys, bosses, exits and secrets, plus random bounties; other mods can add their own; MIT |
| OmniShields | shields earned by kill count (5 s per 20 kills, 30 s per 100), plus speed, jump and firepower versions. Owner: a great fit |
| SoftPermaDeath (Snarboo) | ACS lives: a killing blow sends you back to a respawn point, lives dropped where you fell, punishment by skill. Owner: a great fit |
| ZMovement 3.2.1 (Ivory Duke) | dash, air dash, wall jump, wall slide, crouch slide, double jump, ledge grab, hook. Replaces the player class (`ZMovePlayer : DoomPlayer`), so it comes in pieces. Owner: a great fit |
| PBImps | Project Brutality's ceiling-climbing imp, plus a probe that tells a monster it has no clear shot. Calls PB-only actors, so it gets rebuilt on our imps |
| Anti-Agitation | the revenant's homing missile, steering only on one frame in three (dodgeable homing) |
| ProjectileCrossFireDetonation | every stock projectile can be shot down with 1 HP, so crossing shots blow up |
| ArchvileSummonsImpAndPinky | the arch-vile stops reviving and throws two slow boss-brain cubes, each hatching an imp or a pinky |
| LostSoul_PossessAndRevive | a lost soul flies into a corpse, brings it back, and is used up doing it |
| ZSCALE | a measuring map (128 vs 90 units a square); looks like it belongs to another project |
