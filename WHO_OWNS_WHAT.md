# Who owns what (2026-11-01)

One home per mechanic, so a feature is tuned in one place and never built twice. **Read this before adding a
feature**; if it overlaps a row, it goes in that row's mod, or the owner decides first.

The owner's model (11-01, agreed): "GBOVR is upgrades only for the mods it detects. RS Score is points and combos
for only the mods it detects." **RSQ Melee owns fighting with your body; Distance Grab owns objects; Gestures only
reads hands; Gun Bonsai VR only levels things up; Score only scores.** The melee merge happened on 2026-11-01 (the
owner approved RSQ Melee as its own pk3, an exception to his no-new-mods rule). No mod requires another: each only
gains features when another is loaded.

## Hands and melee

| Mechanic | Home |
|---|---|
| Reading the hands (watch check, thrust, pull, punch kind, shove, braced, still) | Gestures (answers only; acts on nothing) |
| Punch damage and hit feel, SuperPunchOut's boxing gloves, Slappers Only, Start With Gloves | RSQ Melee |
| Guard, Heavy Hands, Hadouken, Wall Splat: the moves | RSQ Melee (with Gun Bonsai VR: only once its upgrade is learned; without it: a Melee row each, off) |
| Guard, Heavy Hands, Hadouken, Wall Splat and the other glove upgrades: offering, levels, numbers | Gun Bonsai VR addon (same class names, so saves keep them) |
| Gun-butt shove (reads its own swing; stands down for BD22 VR's own), slow-mo after a shove, F.E.A.R. Effect | RSQ Melee |
| Headlock (off hand holds a monster, Human Shield, the headlock throw) | RSQ Melee (the thrown monster flies through Distance Grab's throw when it is loaded) |
| Walk-up grab, carry, throw, distance pull | Distance Grab |
| Doors by hand, palm switches | Distance Grab |
| Moving a gun between hands | Tactical Rig (holster with one hand, draw with the other) |
| Saber, ShieldSaw, Whip, Grapple melee | their own mods |

## Body and gear

| Mechanic | Home |
|---|---|
| Holsters (guns, sabers, grenade spot), keyring, gun throw, cigarette | Tactical Rig |
| The hand grenade on plain Doom (pin by ring or teeth, throw by hand, cook, red fuse, grenades scattered per map); stands down for Brutal Doom VR's own grenade | Grenade (own pk3, owner-approved 11-01) |
| Barrels: how a barrel goes off (the lit blink, six explosions at random, their sounds); Doom's barrel gameplay kept; stands down for Brutal Doom's barrels unless Replace Brutal Doom's Barrels | Grenade (owner 11-09: "part of grenade?"; no new mod) |
| Explosions' look, barrels and grenades: the new grenade blast (Original selectable), Explosion Colour (Normal / Room Complement / Kill Colour / Grenade Kind), the explosion light, the room's contexts (wall, low ceiling, open sky, water, liquid floors, chain, crowd gib) | Grenade (owner 11-09; explosions.zs). The look only: the slow motion of a barrel's or grenade's blast stays SlowMo's (Barrel Multi-Kill, Chain Reaction, Barrel Near You, Grenade Blast); Glow In The Dark's glow and Monsters' tiers are read by name |
| Second saber's draw and stow | Tactical Rig holster + Saber (its dual on/off) |
| Weapon picking by wheel | Wheel |
| Ammo / status cards on the wrist | GunCards (watch check from Gestures) |

## Shared services (read by others, own no gameplay)

| Service | Home | Read by |
|---|---|---|
| Handedness, colour-blind, Steady Hands, Seated Play, Slower Taps, Rumble Strength, one Reset | Accessibility | every mod (see its README) |
| Time slowing (`rsm_pulse`, `slowmo.active`) | SlowMo | Saber, ShieldSaw, Rig cigarette, Melee (shove slow-mo, F.E.A.R. window), Score, Miniboss, Wheel |
| Scoring, combos, awards (counts what the others do; does no melee itself) | Score | Melee (F.E.A.R. Effect award; the Headlock's "grab.hold" touch), Miniboss |
| Upgrade levels and their numbers (`RSQ_MeleeUpgradeService`) | Gun Bonsai VR addon | Melee, Saber, ShieldSaw, Distance Grab, Grapple, Wheel, Gun Cards |
| The last punch, the Guard, which mod takes an off-grip press (`RSQML_Service`) | Melee | Gun Bonsai VR (glove upgrades), Distance Grab |
| Monster markers | VisualRewards (the HP bars) | reads the others |
| Arrival beams (a monster another mod brings in arrives on a beam, hidden until its reveal) and monster words (GUARD!, TARGET!: one-off and held words over a monster in RS Score's font) and pops (`RSQVR_Service` "beam", "word", "word.hold", "word.clear", "pop") | VisualRewards (rsqvr/beams.zs, words.zs) | Miniboss (the Bossfight's arrival, its words and thrall-kill pops) |
