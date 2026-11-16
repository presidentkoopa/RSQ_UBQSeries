# EX boss dossier: the Big Boss pool (2026-11-16)

Read from source, not run in game: **[V]** read from source, **[I]** a reading of how it plays. Written for the Big Boss
rethink (design/BIG_BOSS.md section 10: the stage-turn arrival, phases with weak-point windows). Timings in tics (35 a
second). Weak points as fractions of the drawn sprite: h from 0 (feet) to 1 (top); w from -0.5 (left) to +0.5 (right).
Ours are RSQ Monsters' ports of Colourful Hell 1.04 (`Monsters/zscript/monsters/`, state for state); the Plus ones were
read from Colourful Hell Plus R3.0.1's Common versions (ported 11-16 in `Monsters/zscript/monsters/plus/`, b5d71aa0da).

| # | Boss | Family | Health | Natural window opener | Personality |
|---|---|---|---|---|---|
| 1 | Player X | Zombieman | 5,000 | its super shotgun jams (20-tic reload) [V] | the deathmatch tryhard: strafes, rocket-jumps, teabags |
| 2 | LET ME SEE YOUR WARFACE (Chaingunner Warlord) | Chaingunner | 8,999 | the 40-tic BigBomb charge | a drill sergeant with a doomsday arsenal |
| 3 | Smoking Black Imp EX (Imp Warlord) | Imp | 8,600 | the Kamehameha / BigShot charge; its two charge orbs are its own weak points [V] | a chain-smoking anime villain who announces his special |
| 4 | SHOCKMASTER RETURNS | Cacodemon | 10,000 | fading back in from Phase | a storm cloud with a grudge |
| 5 | Terminator MK II | Hell Knight | 11,000 | the Resistance charge-up, or the 36-tic Homing beeps | a relentless cyborg that beeps before it kills |
| 6 | The Black Knight unleashed | Revenant | 7,500 (+ wraith 6,666, shadow 20,000) | when its shield drops | Monty Python's knight, but it works |
| 7 | The thing from the bog | Mancubus | 18,000 | the Burp wind-up (36 tics, then 12 standing) | a swamp god with indigestion |
| 8 | Macross Missile Spam EX | Arachnotron | 12,000 | landing after its hover barrage, or the 36 tics of sight-lines | everything is a missile |
| 9 | BENELLUS, GOD OF SHOTGUNS, ANGRIER | Shotgunner (White) | 12,537 | the 29-tic ShotgunRounded charge | a deity whose sacrament is buckshot |
| 10 | The vengeful soul | Lost Soul (White) | 12,500 | the 18-tic stretch before a shapeshift | a grief that wears every face that ever killed you |
| 11 | THE BACKSTABBER UNSILENCED | Spectre (Plus) | 7,250 | right after the backstab | a shadow that wants you to know it's behind you |
| 12 | AHH HELP!!! | Arch-vile (Plus) | 2,700 (then the Void) | when the tornado spin ends | a panicking wind spirit |
| 13 | Void Strikes back | Arch-vile (Plus) | 4,166 | during Summon, the one time it has a body | an absence that counts your blows |
| 14 | Time to die | Arch-vile (White, Plus) | 20,800 | ScreamofTime, when it plants itself | a cosmic clerk who has filed your death certificate |
| 15 | Obsidian Tyrant | Cyberdemon (Plus) | 24,000 | its built-in 100-tic exhaustion after BigHell [V] | a blacksmith who forges earthquakes |
| 16 | It crashes doom II | Cyberdemon (White, Plus) | 32,767 (+ Romero head 3,000) | the end of OVERDRIVE, or a phase change | the game itself, breaking on purpose |
| 17 | WHITE HOT SPIDER | Arachnotron (White, Plus) | 9,500 (splits 3, then 9) | the KRAKATOA charge | a volcano that learned to walk |
| 18 | Everlasting White Spidey | Mastermind (White, Plus) | 20,000, regenerates | the FloorCrack landing, or the once-only roar | a god-machine that won't stop healing |
| 19 | Fusion White Arachnotron | Arachnotron (White, Plus) | 4,000 (splits, ~8,500 in all) | the red-dot aim | a sniper colony pretending to be one spider |

## Ours (10, from Colourful Hell 1.04)

**1. Player X** (`RS_BlackZombieEX`, 5,000). Doom player sprite (PLAY), speed 28, pain chance 16.
- Attacks: close (<300) jump-in super shotgun, 8 pellets of 6-18, jams every second shot (20-tic reload, shell eject);
  mid (<840) 4 plasma bolts, widening spread; far chaingun taps that can turn into rockets; a fairly rare BFG ball
  (100-200); punch 60-120. Rocket barrage: hops up and sideways, 3 rockets (also on pain, 84/256). Strafes. Taunts over
  your corpse with a laugh.
- Tells: BFG hum plus 24 bright tics; the shotgun reload; the laugh.
- Weak points: head 0.88h; gun 0.55h +0.15w; chest 0.65h. Window: the shotgun jam [V].

**2. LET ME SEE YOUR WARFACE** (`RS_BlackCGuyEX`, 8,999; CHAINGUNNER WARLORD). HCPO chaingun major, 58x64, speed 20.
- RapidFire (a proximity beep, then exploding tracers); RedSpam (two 15-tic charge spirals, 14 red BFG-style shots
  10-120, then a 22-88 blast over 256); YellowBomb (within 1,200: a lobbed bomb that grows through pulsing blasts up
  to 312 radius); BigBomb (40 tics charging with the BFG sound, a seeker 30-80 and a 386-radius blast with clusters).
- Below 5,000 it fires more often and is always fast. Explodes on death.
- Weak points: head 0.85h; chaingun 0.5h +0.25w; ammo belt 0.6h. Window: the 40-tic BigBomb charge (breaking all three
  could cancel the shot [I]).

**3. Smoking Black Imp EX** (`RS_BlackImpEX`, 8,600; IMP WARLORD). AGUR, ~81 tall, speed 19, poison smoke trail.
- Kamehameha: its cry at full volume to the whole map, two charge orbs at +-32 to the side, 42 up; 20 tics later a
  railgun (20-80). Smokeout: a beeping marker on you, then a smoke/fire column under you. OneShot: 30 fireballs in a
  narrowing cone. BigShot: 24 tics charging, a slow seeking orb (50-120, 256 blast). SpamShotRain: ~40 bouncing seekers.
- On pain, 64/256: vanishes in smoke and teleports.
- Weak points: the two charge orbs (0.52h, +-0.4w, just outside the body); head 0.9h; chest 0.6h. Window: the
  Kamehameha or BigShot charge [V].

**4. SHOCKMASTER RETURNS** (`RS_BlackCacoEX`, 10,000). HELE, floats, speed 21 (42 in phase 2), afterimages.
- Electro1 (13-ball fan), Electro3 (charge, then an eye beam plus rails 20-80), Electro4/5 (slow orbs into zapper
  fields), Electro2 (orbiting red spikes, 100 HP each, that dash at you; floor-crawling ripper bolts).
- Phase: fades to 10%, drifts, reappears (on pain 88/256). Below 6,500 once: 7 spikes and speed 42. Below 5,000:
  orbs that split into fire storms.
- Weak points: eye 0.5h; jaw 0.3h; horn tips 0.9h +-0.3w. Window: fading back in from Phase.

**5. Terminator MK II** (`RS_BlackHKEX`, 11,000). BRUC bruiser, ~110 tall, speed 14 (18 below 5,000).
- By range: under 500 BigSlash (3 floor blades), spread missiles, fast beam, grenades; 500-1,500 BigMis (3 rockets),
  a 15-missile spread, a bouncing seeker grenade, DeathBeam (charge, speed-90 bolt), FastBeam (a beep, plasma or a
  rail); over 1,500 Homing (two beeps over 36 tics, a seeker 80-125).
- On pain (128/256) squashes flat and teleports; in phase 2 Resistance (charge-up, 40% less damage for 7 s, ripper
  orbs).
- Weak points: head 0.9h; arm cannon 0.4h +0.28w; chest core 0.6h. Window: the Resistance charge-up, or the Homing
  beeps.

**6. The Black Knight unleashed** (`RS_BlackRevenantEX`, 7,500, then two more forms). DKNT, speed 14, sword reach 92.
- Far: DartCleave (9 darts into fire jets), ShieldBlast (16 fireballs plus a homing flame), Dash. Within 1,000: 4
  bouncing nail mines; a hook chain that pulls you in.
- On pain (178/256) a reflective, invulnerable shield for 50 tics, plus an orbiting second shield. On death drops sword
  and shield and rises as a wraith ("Just a shade wound", 6,666, through walls, fire rain, soul seekers); ~7 s later
  its Shadow ("The Black Knight's shadow", 20,000, slow, through walls), which dies when the wraith dies.
- Weak points: helmet 0.9h; shield arm 0.55h -0.3w; sword arm 0.55h +0.3w. Window: when the shield drops.
- Known: its shadows' hurt-buff (RevBuffEx) is a stub in ours.

**7. The thing from the bog** (`RS_BlackFatsoEX`, 18,000). BDEM shadow beast, ~120 wide, 139 tall, speed 16 (21 below
5,500).
- Under 500 Breath (14 ripping poison fireballs); under 2,000 BigBombs, Weave1 (5 big orbs swept across), Weave2 (14
  slow homing orbs); further BiggerBomb (seeker 50-200, 258 blast) and fast shots. Phase 2: GroundSplashes, Burp (9
  crawling blobs that leave acid puddles). Resists plasma.
- Weak points: head 0.85h; belly/mouth 0.4h; shoulders 0.7h +-0.3w. Window: the Burp wind-up.

**8. Macross Missile Spam EX** (`RS_BlackSPEX`, 12,000). BSP2 arachnotron, speed 21, sees invisible.
- Set 1: twin bouncing lasers, rocket salvos, a jump 100 up to hover and rain ~40 seeking fireballs, slithering
  cluster bombs. Below 7,000 set 2: airborne laser storm, weaving rocket pods, a spiral shot, 6 blue rail sight-lines
  then 6 bombs, a rocket trio. Ignores pain while airborne.
- Weak points: brain dome 0.75h; gun pods 0.45h +-0.25w. Window: landing after a hover barrage, or the sight-lines.

**9. BENELLUS, GOD OF SHOTGUNS, ANGRIER** (`RS_WhiteSGEX`, 12,537). BENE, ~150 tall, floating, speed 31.
- Far: FocusedHitScan (7 tight blasts) or ShotgunRounded. Near: SG (a wild spray up to 180 degrees), Gifts (4 bouncing
  shotgun mines), FocusedFire (a spark cage, 28 fast sparks), ShotgunRounded (29-tic spark charge, then two ghost
  shotguns appear 128 units either side of you and fire after 13 tics, plus two Shotgun Shrine turrets, 800 HP each).
- On pain drops a Shrine (176/256) and teleports (128/256). On death it rains shotguns.
- Weak points: face 0.75h; chest 0.55h; crown 0.9h [I: rotating-gun frames]. Window: the ShotgunRounded charge.

**10. The vengeful soul** (`RS_WhiteLSoulEX`, 12,500). ETHS ghost soul, floating, through walls.
- Shapeshifts: above 6,000 into Cacodemon, Revenant or Hell Knight; below into Baron, Arch-vile or Mancubus, each with
  that monster's best volleys. Soul form: a fast ice beam, or a seeking soul charge. Two invulnerable skulls orbit it;
  on attack they break off, become hittable, charge, swell and hatch into a Revenant, Hell Knight or Cacodemon.
- On pain (64/256) Reset: a 70-tic wander-teleport, fresh skulls.
- Weak points: skull core 0.65h; flame wisps 0.4h +-0.3w (soul form only). Window: the 18-tic stretch before a
  shapeshift.
- Known: its Baron form fires one fewer ball per volley in ours.

## Plus (9, Colourful Hell Plus R3.0.1)

**11. THE BACKSTABBER UNSILENCED** (Black Spectre EX, 7,250). Mode 1: 45% visible, afterimages, ranged. Mode 2: 12%
visible, through walls, lunges. Weaving shadow balls; a spiral that bursts into 72 balls; DarkBeam (32 piercing bolts).
A hidden counter builds, then a 20-tic shriek, it warps 38 units behind you and hits twice (40-99 each).
Weak points: head 0.7h +0.2w; back 0.5h; tail 0.3h -0.3w. Window: right after the backstab.

**12. AHH HELP!!!** (Black Arch-vile EX, 2,700). Wind vile, speed 20/24/30 as it weakens. Leaves (a big wind push),
Tornado spin (sucks you in), MindWave, a floor-ploughing tornado. On pain calls Mr Bones, dashes. On death becomes the
Void. Weak points: head 0.9h; hands 0.5h +-0.35w; torso 0.6h. Window: when the tornado spin ends.

**13. Void Strikes back** (4,166). No body sprite, a particle cloud, random speed and size. Dimming waves, a Black Hole
(pulls, pulses, bursts), MindWave, Shockwave (12 floor walls). Counts hits: at 8 summons revenants; at 14 (darkness:
stubbed in our port). Weak points: three "eyes" pinned in the cloud at 0.5h (-0.25, 0, +0.25w). Window: during Summon.

**14. Time to die** (White Arch-vile EX, 20,800). Floats, through walls, speed 60, a clock face over its head. A
courage meter (hides, approaches, attacks); raises corpses one tier up. Below 12,500 ENDOFTIME: half damage, a
300-second countdown; at zero it turns invulnerable, freezes you and fires until you die (owner deciding). Bolts,
Rings of Time (warps behind you, stops time), eyes, a rail, a scream, armour steal, clones.
Weak points: the floating clock face; hourglass hands 0.5h +-0.35w; head 0.9h. Window: ScreamofTime; or each window
could add time back to the countdown [idea].

**15. Obsidian Tyrant** (Black Cyberdemon EX, Hell Smith, 24,000). Hammer smash (5 pentagram floor lines, a quake),
Charge (reflects shots), HellShotCombo, LightningCall, homing fire, FlameBlast. Below 14,000 portal summons; below
4,000 Supersmith. BigHell: invulnerable while it summons a hellfire pentagram, 12 hammer slams x 8 shockwaves, then
stands vulnerable for 100 tics. Weak points: head 0.85h; forge hands 0.46h +-0.17w. Window: the 100-tic exhaustion [V].

**16. It crashes doom II** (White Cyberdemon EX, 32,767). Never flinches. Below 24,576 summons GlitchBarons; below
8,192 through walls, OVERDRIVE (16 random attacks). Rocket seizures, sweeping glitch lasers, FourthWall (a giant
homing floor wall), GlitchTrap (a cage around you), CodeLeakage, shield orbs, mines, sky lasers, BFG spam. On death
"The one behind it all" (Romero head, 3,000) teleports onto you and spams BFG shots.
Weak points: head 0.85h; arm cannon 0.8h -0.2w; chest core 0.55h. Window: the end of OVERDRIVE, or a phase change.

**17. WHITE HOT SPIDER** (White Arachnotron EX, 9,500). Fire trail, side hops. Bolt volleys, flares, fire bombs, flame
blast, mini-spiders, webs (slow to 20%), KRAKATOA below 5,000 (two eyes charge 10 tics, lava shots). Splits 3 x 2,200,
then 9 x 500. Weak points: eyes 0.6h; flank vents 0.4h +-0.35w. Window: the KRAKATOA charge.

**18. Everlasting White Spidey** (White Mastermind, 20,000). Never flinches, regenerates. Below 13,000 flies; below
6,000 "I AM EVERLASTING", camouflage. Twin rapid fire, spread fire, plasma rockets, FloorCrack (jump, quake ring),
a zapper storm, eye beam, Nukes (floor marks, then drops), sentinel spiders, a shield, lightning, webs.
Weak points: brain 0.75h; twin guns 0.3h +-0.1w. Window: the FloorCrack landing, or the roar.

**19. Fusion White Arachnotron** (4,000). Hover bolt fans, red-dot sniping (two 12-tic laser sights, then a rail),
slime, egg-laying runs, mini-spiders, webs. Splits 2 x 1,250, then 2 x 500 each, then mini-spiders.
Weak points: brain 0.6h; front legs 0.3h +-0.3w. Window: the red-dot aim.

Not determined: in-game feel and timing (nothing was run); Benellus's weak points; Plus's other subtier copies.
