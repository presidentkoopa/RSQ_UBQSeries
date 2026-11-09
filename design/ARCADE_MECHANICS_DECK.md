# Arcade mechanics deck (owner + Claude, 2026-11-09 01:00-01:26)

Owner's list of seminal arcade and board games. For each: Claude's read (the takeaway mechanic + what is unique),
the owner's take (his words, lightly tidied), and where we landed. Ideas only: nothing is built, nothing is chosen
to build. Process agreed: mechanics -> Doom with our parts -> filter (Doom Arcade VR, VR-friendly) -> encounter
sketches -> owner picks 2-3 -> one built as a test in one MapsOfChaos combat zone.

Our parts: RSQ Monsters (Vanilla / BD22 / MeatGrinder / ColorfulHell, 13 colour tiers, the tier-change flash, any set
spawnable by name inside any level), Miniboss, SlowMo + DOWN (slow-mo on demand, per-target crosshairs, edge arrows,
chevron trail, target lines, real Champion copies), Score, VisualRewards (bits), DoorCards, the room map
(tools/mapview), QuestSaber + Force powers + training drone, Melee (throws, axe), Grapple/Whip, GBOVR (player screen
with item slots), LegenDoom, Champions (no licence: can't ship its art), Corruption Cards, the 8 arcade mockups.

## Gun games (on rails)

**Virtual Cop.** Claude: a ring on each enemy closes green -> yellow -> red before it fires, so you read who shoots
first; shooting the gun from a criminal's hand (Justice Shot) pays a bonus; civilians cost you; accuracy grade at the
end. Owner: agreed; "our arrows and slowmo can be of use here. We can dynamically resize and scale enemies if we need
to." -> Panel 1. Now that tiers make some monsters far more dangerous, the ring marks "this one is the problem".

**Time Crisis.** Claude: a pedal to hide behind cover (safe, reload) and stand to shoot; the enemy whose shot will hit
you flashes red; a timer per section. Owner: "Doom's maps aren't built to provide cover spots. We will need to rework
this, maybe the timer?" -> Landed: no cover. Its red flash and section timer are panels 2 and 6, rules other
encounters use, not an encounter of their own.

**House of the Dead 2.** Claude: rescuing civilians pays and changes your path; bosses show a weak point; limbs come
off where you shoot; crates hide pickups. Owner: rescues are more a Metal Slug thing (see there). "HotD2 has giant
bosses with targeted weak points. I'm seeing a large Imp, towering, with active crosshairs appearing on parts of its
body being the only way to damage it. A large health bar on our HUD to show its depletion. 'Weak Point' text
underlined, and that line extending at an angle to the weak point." -> Claude: doable with what we have: scale the
monster up; the hit height is measurable (MG's head band does it); markers on body parts; DOWN already draws HUD lines
and icons that track a spot in the world. Open: does the weak point stay put, or move after each hit?

**Jurassic Park (1994) / The Lost World (1997).** Claude: the threat is too big to kill, you shoot to drive it off or
stun it while the ride carries you; big chase set pieces; rescuing named people. Owner: "we can't do chase scenes,
but we could pick a point in the map and have the player run to it; we spawn in a massive threat like a Champion EX
tier and have it motivate the player to run to the marked spot. Workshop this some." -> Claude's workshop,
**Jurassic Run**: a DOWN chevron trail marks the goal; a huge EX/Champion arrives behind you, slightly slower than
your sprint, unkillable but stunnable (explosions/grenades buy ~2 s, the JP tranquiliser); chumps spawn on the route
as blockers; SlowMo on its lunges; reaching the spot slams a door or teleports you out; pays for time and for how
close it got (Crazy Taxi near-miss tips). Variant: carry a rescued scientist, which slows you.

**Alien 3: The Gun / Gunblade NY / Beast Busters.** Claude (less sure on these): mounted heavy gun against a swarm;
helicopter ride with endless fire across a building face; three players with grenades, bosses that mutate. Owner:
"I dunno, skip this." -> Skipped.

**Star Wars Trilogy Arcade.** Claude: switches between flying and shooting, and lightsaber duels where you deflect
blaster bolts. Owner: "Our lightsaber and Force powers can play on this for sure. We have a training drone we could
expand into something."

## Run-and-gun, brawlers, shooters

**Metal Slug.** Claude: freeing prisoners drops weapons/items; strong weapons have limited ammo then back to the
pistol; one hit kills you; vehicles; enemies react with fear and comedy. Owner: "Explosions. Massive pixel
explosions. And our rescue civilian / science team thing. We can help them teleport out or something. Add it to our
tally at the end: Rescued X/Y." Also from HotD2: "maybe we source some civilian or scientist sprites? Walk up to them
and Use to free them?" -> Claude: BD's rescuable marines show it works; civilian sprites need a source we may ship.
Explosion art: design/assets/fx_sheets/ (Reactorcore pack: licence to confirm).

**Smash TV.** Claude: game-show arena, waves pour through the doors, prizes land on the floor to grab mid-fight, a
host, pick your path room by room. Owner: "melee monsters coming at you in waves while you mow them down and collect
prizes. Do they have to be prizes for us? Maybe puzzle pieces? For what? We have LegenDoom and shit so maybe we use a
lot of these ideas to work towards collecting required trinkets to summon an EX tier bossfight." -> Claude: agreed;
that is the peak (panel 8) built from pieces: tokens on the floor mid-wave, the full set summons the boss.

**Double Dragon.** Claude: knock out an enemy and take its weapon; some moves are overpowered and players find them;
the brothers fight at the end. Owner: "We have a comprehensive set of melee maneuvers and throwing as well as an axe,
maybe we will try to find a baseball bat and a pipe... maybe get them on our enemy sprites as attached 3D weapons at
their hand points." Claude objected (sprites have no hand points). Owner: "SuperPunch, our online repo, proved 3D
gloves can be done. For this, we would only need to draw our weapon actor near the monster holding it, and intercept
monster attacks as an animated swing of the whatever." -> Landed: a 3D weapon model follows the monster at hand
height on its weapon side (a few placement numbers per family, measured once from the sprites); the melee attack
plays a swing on the model timed to the hit; knocked down, it drops that weapon as a pickup. Next: read how
SuperPunch drew its gloves and reuse it.

**Gauntlet Legends.** Claude: generators spawn until destroyed; health drains over time ("Warrior needs food
badly"); keys and shared loot. Owner: "We can easily spawn in monsters and Champions has a selection of food
sprites. Or we could find others." -> Claude: Champions has no licence, so its food sprites can't ship; find or draw
others.

**D&D: Shadow over Mystara.** Claude: a brawler with an inventory (limited-use spells and items on a ring menu),
branching paths, gold and shops. Owner: "We have gold bits as an idea, and an inventory would be a great idea for us
since our GBOVR player screen has slots for items." (Gold bits: Hackfraud kill rewards, design/PARKED.md.)

**DoDonPachi.** Claude: a chain gauge, each hit keeps it alive, a pause breaks it; tiny hitbox; laser slows you;
hidden second loop with a true boss. Owner: no comment.

**Radiant Silvergun.** Claude: three enemy colours; same colour in a row builds a chain bonus; weapons level up by
use; a sword absorbs bullets. Owner: "We have a ton of colors so pattern building and execution would be super fun."

**Neo Geo.** Claude: one cartridge for arcade and home, a memory card that carried progress; fighters with comeback
meters (Samurai Shodown's rage). Owner: "impressive frame count for explosions."

## Puzzle and rhythm

**Bust-a-Move.** Claude: match three of a colour, everything hanging from them falls; the ceiling drops; bank shots.
Owner's encounter: "Clearing a room of monsters means turning them a certain color by shooting them; they do not take
damage. Some monsters are keyed. Assume 30 monsters, all infighting different ones with each hit for maximum chaos
(constant retargeting and rechasing) but taking no damage. Three coloured monsters are key, and when you kill that
one you kill all monsters currently that colour. But the infighting makes it hard for you to get control over the
colour crowd." -> Claude: the best idea on the list. Painting is cosmetic only (a painted imp keeps its stats; the MG
colour tables can paint). Open: what does a hit paint? One step along the ladder per hit, or each weapon paints its own
colour (switching guns sets up the colour crowd: Radiant Silvergun inside Bust-a-Move).

**DDR.** Claude: body is the controller; steps on the beat graded Perfect/Great/Good/Miss; combo; life bar. Owner:
"QZD doesn't give us what we need for this. But you're right, movement = style. We design expanded movesets to keep
us in the air: dashes, wall runs; the hookshot and whip help here too. Certain events / set pieces need constant
slowmo so we can stay in the air while targeting what we need."

## Board and paper games

**Where's Waldo.** Claude: find one figure in a dense crowd; decoys; a checklist of hidden extras. Owner: likes it.
Earlier (00:39): spawn a ton of monsters and keep spawning every X tics; some are real threats that get the Virtual
Cop crosshair when they attack, maybe contextual slow-mo and arrows; many are chumps; one is the target (a Boosted
Legendary Champion, an EX or a high tier). DOWN already has most of the toolkit. Open: is the target hidden until it
gives itself away, or marked from the start and protected by the crowd?

**Guess Who.** Claude: eliminate suspects with yes/no trait questions. Owner: likes it. Claude: fits Waldo (each kill
reveals one trait of the hidden target).

**Clue / Risk.** Claude: deduction by elimination; territory earns reinforcements. Owner: "I don't know about the
other two." -> Claude: drop Risk; Clue's deduction can live inside Guess Who and Waldo.

## Short list so far
Bust-a-Move (colour crowd), weak-point giant boss (HotD2), Jurassic Run, Smash TV tokens -> EX bossfight, rescues
(Rescued X/Y on the tally), Where's Waldo / Guess Who, monster melee weapons (Double Dragon), movement + constant
slow-mo set pieces (DDR), saber/Force + training drone (SWTA). Next to workshop: owner's pick.
