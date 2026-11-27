<p align="center"><img src="../design/readme_art/mods/monsters_title.gif" alt="RSQ Monsters"></p>

# RSQ Monsters

RSQ Monsters puts every monster on one ladder of thirteen colours, numbered by strength: Common, Green, Blue, Purple, Cyan, Brown, Yellow, FireBlu, Gray, Red, Abyss, and the two boss colours, Black and White. One setting, the Monster Tier (Common to Red on the menu), sets the colour the monsters stand at: every monster on the map moves to it, every new one spawns at it, and RSQ Miniboss raises it for a Boss won and lowers it for a Boss lost. A monster about to change flashes full bright, for 5 to 25 tics, in the colour it is becoming, and a changed monster stays itself: the share of health it had lost, its Champions champion, its LegenDoom legendary, its Universal Entropy size and its place in RSQ Score's count go with it.

The Monster Set picks which monsters the maps get: Brutal Doom's and XMVE's own (BD22 XMVE, the default; Doom's own when Brutal Doom is not loaded), Doom's own whatever else is loaded (Vanilla), or Colourful Hell's (ColorfulHell). Brutal Doom's, XMVE's and Doom's monsters get the tier kit, the same body with more health, damage and speed, less flinching and a power for each colour (Green's acid, Blue's zap, Purple's extra shot, Cyan's ice and sideways hop, Brown's healing, Yellow's fire, FireBlu's twin shots and death blast, Gray's stone skin, Red's rage, Abyss's phasing and rising again, and Black's and White's call for help), and Painted Colour Art draws Brutal Doom's and XMVE's monsters from painted frames in their colour, or a tint of it, down to their corpses, crawlers, limbs and gibs. Colourful Hell's set is 17 families in 13 colours, each colour its own monster with its own name, health and attacks, with the Black and White bosses, 16 EX bosses (Colourful Hell 1.04 and Colourful Hell Plus), its own switches and drops, and railguns that fire a travelling beam you can step out of. It also chooses where RSQ Miniboss's Boss and thralls come from and fills the Big Boss pool, can float each monster's tier gem over its head (Tier Icons, off by default), and has Monster Diagnostics on Test and Debug to spawn any colour of any family, read the aimed monster's tier and step it up.

<a name="how-to-play"></a>
## How to play

RSQ Monsters has no keys: it changes the monsters you fight. "Kit" is the tier kit a Brutal Doom, XMVE or Doom monster carries; "ColorfulHell monster" is one of Colourful Hell's. The page is Options > Radiant Silvergun Options > RSQ Monsters. 35 tics are 1 s.

| Do this | What happens | Needs |
|---|---|---|
| Start a map with Brutal Doom loaded | Brutal Doom's and XMVE's own monsters spawn as their mods ship them (nothing replaces them); each one with a Doom family gets a tier kit at the Monster Tier's colour. At Common the kit changes nothing | Monster Set: BD22 XMVE (default) |
| Start a map without Brutal Doom loaded | Doom's own monsters spawn, with the same kits | Monster Set: BD22 XMVE (default) |
| Set Monster Tier (Common to Red) | Within 8 tics every kit monster and every ColorfulHell monster on the map starts its tier flash and moves by the same number of colours; monsters spawned later come at the new colour | Tiers: On (default) |
| Watch a monster change tier | For 5 to 25 tics (each picks its own wait, so a room ripples) it shows, every 3 tics, the colour it is becoming, full bright, then its own. Then it changes. A second change asked while it flashes starts the wait again | |
| Fight a kit monster above Common | More health, rising evenly to x2.5 at Red (Cacodemon x2.08, Lost Soul x2.4, Arachnotron x2.0); more damage, from x1.11 at Green to x1.83 at Red; speed never lower (x1.0 to x1.5 at Red, by family); it flinches less | Monster Set: BD22 XMVE (default) |
| Look at a kit monster above Common | It is drawn from the painted frame for its colour where one exists, else it wears the colour's tint | Painted Colour Art: On (default); the frames: RSQ_BDXMTiers_<Colour>.pk3 loaded |
| Kill a coloured kit monster | Its corpse, crawler, last stand, limbs and gibs keep its colour. Blood, smoke, fire, sparks, casings and pickups keep their own look | |
| Do a Brutal Doom fatality on a coloured monster | The gore and corpse you throw keep the victim's colour, and your fatality frames are drawn from the painted art in that colour | Brutal Doom; Painted Colour Art: On (default) |
| Fight a Green kit monster | Its shots leave a 3 s acid patch where they land, and its hits leave one under what they hit (one a second at most). Standing in it costs 5 health a second | Monster Tier Green |
| Fight a Blue kit monster | Its shots fly 20% faster and zap where they land: 8 damage to you within 48 units (plus your width), in sight of the spot | Monster Tier Blue |
| Fight a Purple kit monster | Each attack fires one more shot, 6 degrees to one side | Monster Tier Purple |
| Fight a Cyan kit monster | Its shots are ice; a hit slows you to half speed for 1 s. When your aim is on it (within 6 degrees, 1536 units) it may hop sideways (4 tries in 10, every 20 tics). Ice does a fifth to it; fire and melee do x1.5 | Monster Tier Cyan |
| Fight a Brown kit monster | Every 3 s every other monster on its side within 512 units gets 5% of its full health back, and the nearest one gets a 2 s shield that halves what it takes (tan sparks) | Monster Tier Brown |
| Fight a Yellow kit monster | Its shots leave a 2 s flame patch where they land, and its hits set you alight: 2 fire damage every 10 tics for 2 s. Fire does half to it; ice does x1.2 | Monster Tier Yellow |
| Fight a FireBlu kit monster | Every shot has a blue twin 4 degrees off. Fire does a quarter to it. When it dies it blasts 64 damage over 128 units | Monster Tier FireBlu |
| Fight a Gray kit monster | Stone: x0.8 speed, never flinches, takes half from explosions and 0.65 from everything else; its shots are grey | Monster Tier Gray |
| Hurt a Red kit monster to half health, or into its pain frames | It rages: x1.4 speed, never flinches, attacks far more often, red sparks. Ice does x1.4 to it. When it dies it throws 3 to 5 red bolts (3 damage each) | Monster Tier Red |
| Kill a monster that came from a coloured one | A monster called in by another (its master), or a Lost Soul born within 128 units of a kit Pain Elemental, takes the higher of its own colour and its summoner's | |
| Kill a monster that rises out of a coloured body mid-map | A death stage, or the same family born again on the spot, takes the body's colour, not the Monster Tier's | |
| Kill a ColorfulHell monster with ice | It dies its own death; no monster of this mod is left standing as a frozen statue | |
| Change a ColorfulHell monster's tier | Its body is swapped for that colour's monster. It keeps the share of health it had lost, its Champions champion, its LegenDoom legendary, its Universal Entropy size and its place in RSQ Score's count; it does not count as a kill | On Tier Change: Instant Full (default): a flashed change keeps the share |
| Raise the Monster Tier with ColorfulHell monsters about | A body that got its colour from a change stands on its family's ladder health, so no step up loses health (the Black and White bosses keep their own) | |
| Raise a ColorfulHell Spectre past Yellow | It stays a Spectre: its FireBlu is the stealthy FireBlu Spectre (one that spawned FireBlu follows the Monster Tier too), its Abyss is the Demon's body (Colourful Hell's own) and still a Spectre, and it steps on to the Black and White Spectres | ColorfulHell monsters |
| Take on a Boss fight from RSQ Miniboss | Its Boss and thralls come from Colourful Hell's roster at the colours the fight asks for; nothing in the fight changes tier until the fight ends (no flash, no swap) | RSQ Miniboss; Boss From: ColorfulHell (default); Thralls From: As Boss (default) |
| Meet an EX boss | "A chill runs down your spine" is printed as any of the 16 EX bosses arrives | ColorfulHell monsters (a Boss fight's Boss at Black or White, or a raised spawn cap) |
| Fight Time to die (the White Arch-vile EX) | Under 12,500 health (an RSQ Miniboss Big Boss: from its second life) it can steal: a white flash, every point of your armour taken, 20 damage and 10 s at a quarter speed. At any time it can start End of Time: a count of 300 s on screen (300, 200, 100, 50, 20, then 10 to 1) with a clock and quakes; at zero it cannot be hurt, holds you still and fires until you die. Killing it ends the count | ColorfulHell monsters |
| Face a ColorfulHell monster's railgun | After its own wind-up a glowing beam head flies at you at No More Hitscans' speed (80 without it) and the beam grows behind it. Only the head hurts: step out of its path and it misses. RSQ SlowMo slows it like any shot | ColorfulHell monsters |
| Kill a ColorfulHell monster | It drops Colourful Hell's bundles: health and armour bonuses, backpacks, ammo, weapons, powerups, armour, medikits, by the drop settings (Health Drops also sets the armour bonuses) | Drops: Standard (default) |
| Open Test and Debug, pick Family, press a spawn row (C0001 to A0003) | That monster of the family stands 160 units in front of you, facing you, dormant until Wake; the console names it. A row the family lacks is grey | Spawn Hostile: Off (default) |
| Press Spawn All | The whole family in a line, 72 units apart | |
| Press Wake | The spawned monsters wake and come for you | |
| Press Diagnose | One console line for each spawned monster: its class, name, health, ladder tier | |
| Press Remove All | Every monster the rows spawned is removed; none counts as a kill | |
| Look at a monster and press What Is It | The console says what it is: a ColorfulHell monster's family and tier (and its place past White), a kit monster's family, rung, entry colour, tier and EX steps, or "not on the ladder". The aimed monster is the one your view meets, else the one a shot your way would take | |
| Look at a monster and press One Tier Up | It flashes and goes one colour up from the colour it is heading for (twice inside one flash: two). A kit monster can pass White (each step past White is an EX step); a ColorfulHell monster stops at White. A Boss fight's monster refuses | |
| Press Map One Tier Up | Every living monster on the ladder goes one colour up, each through its flash | |
| Press God Mode (Test and Debug) | The engine's god mode, on or off | |
| Type `netevent rs_retier 7` in the console (any tier 1 to 13) | The aimed monster goes to that tier | |
| Type `netevent rs_retier_all 9` in the console | Every living monster on the ladder goes to that tier | |
| Type `netevent rs_bdtier_dump`, `rs_bdtier_classes` or `rs_carry_dump` in the console | Lists: every kit monster's numbers; every loaded monster class that gets no kit; every living monster's colour, champion and legendary state | |
| Fight an Abyss kit monster | Every hit turns it see-through for 1 s, and while it is, half of what hits it passes through. Every 6 to 10 s it steps out beside or behind you (teleport fog). It dies once and rises again 3 s later if its body can | A tier change past Red (One Tier Up, or another mod's ask) |
| Fight a Black kit monster | Takes 0.6 of every hit, never flinches; at half health two more of its kind arrive beside it at the Monster Tier's colour. When it dies: 8 bolts and a dark burst | A tier change past Red |
| Fight a White kit monster | As Black, and it steps out beside or behind you every 8 to 12 s, and calls two more again at a quarter health | A tier change past Red |
| Push a kit monster past White | Each step past White is an EX step: +10% health and +5% damage each; it is a White, and it also rages as Red and phases as Abyss | One Tier Up, or another mod's ask |
| Set Monster Set to ColorfulHell | From the next map (or a restart) every Doom monster is Colourful Hell's. With the spawn caps at their default (Common) every spawn is the Common one, then raised by the Monster Tier; Doom's projectiles of six monsters become Colourful Hell's | Monster Set: ColorfulHell (default BD22 XMVE) |
| Set Monster Tier to Cyan, Brown, FireBlu or Gray with ColorfulHell monsters | The colour is stepped past while it is off: Cyan and Brown come as Yellow, FireBlu and Gray as Red. A colour switched off is never stepped into Black or White | Monster Set: ColorfulHell; Extra Colours: Off (default) |
| Raise a family's spawn cap (Test and Debug, ColorfulHell Spawn Caps) | That family rolls Colourful Hell's own weights up to that colour, then the Monster Tier raises the roll; 13 is the family's whole roll, Black, White and EX bosses included | Monster Set: ColorfulHell; Caps On: On (default) |
| Set Extra Colours to On or Half | Cyan, Brown, Abyss, FireBlu and Gray spawn (Half: Cyan, Brown and Abyss half as often) and are no longer stepped past | Monster Set: ColorfulHell (default Off) |
| Set Black Boss or White Boss to Off | A Black boss comes as Red; a White one as Black (Red with both off). This holds for spawns, tier changes and RSQ Miniboss's picks | (default On) |
| Set EX Bosses | How often a Black or White boss that has an EX form comes as it: Never, Rare (24 in 256, default), Half, Always | ColorfulHell monsters |
| Set Drops to Scarce, Generous or None | Writes the seven drop settings at once (Test and Debug shows each; the row reads Custom when they match none) | (default Standard) |
| Set White Arachnotron Boss, Black Lost Soul Boss or White Mastermind Boss | Which body that boss gets: Spider (default), Old, Fusion or New; Queen Bee (default) or Old; Armed (default), Everlasting or Either. A tier change to that colour gives the same pick | ColorfulHell monsters |
| Turn on Tier Icons | The tier's gem (Common A to White M) floats up off each monster and shows for 30 tics: once a second off a kit monster, from its own loops off a ColorfulHell monster | Tier Icons: On (default Off) |
| Turn Painted Colour Art off | Kit monsters wear the tint only | Painted Colour Art: Off (default On) |
| Turn Tiers off | Every kit stands down to its mod's own look and numbers, and the Monster Tier counts as Common everywhere (ColorfulHell spawns, RSQ Miniboss's fights); a Boss won or lost does not move it. On again, each kit goes back, plus every step made while it was off. Monsters spawned while it was off get a kit on the next map | Tiers: Off (default On) |
| Change tier with On Tier Change set | Keep Share: the share of health lost is kept even on an instant change. Always Full: full health after every change | On Tier Change (default Instant Full) |
| Set Cyan Monsters Dodge, Lead-Aimed Shots, Red Boss Form, Orange Revenant, Normal Rocket Damage, Abyss Shot Markers | Colourful Hell's own switches for its monsters (Test and Debug, ColorfulHell Switches) | ColorfulHell monsters |
| Set Boss From or Thralls From | RSQ Miniboss takes its Boss from the map's own monsters (Monster Set) or Colourful Hell, and its thralls as the Boss, from Colourful Hell, or from the map's own monsters | RSQ Miniboss |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Monsters

| Option | Default | What it does |
|---|---|---|
| Monster Tier | Common | How tough every monster is, by colour. Changes the monsters on the map now. Beating a Boss raises it. |
| Monster Set | BD22 XMVE | Which monsters the maps get: vanilla, Brutal Doom and XMVE on the colour tiers, or ColorfulHell. |
| Painted Colour Art | On | Monsters are drawn from painted art in their tier colour where it exists; off uses the tint only. |
| Tier Icons | Off | A gem showing each monster's tier floats above it (ColorfulHell's colour-blind aid). |
| Tiers | On | Monsters take the Monster Tier's colour; off, every monster stays as its mod ships it. |
| On Tier Change | Instant Full | When a monster changes tier: keep the health it lost, full health on an instant change, or always full. |
| **Boss** | | |
| Boss From | ColorfulHell | Where a miniboss fight's Boss comes from: the monster set or ColorfulHell. |
| Thralls From | As Boss | Where the Boss's thralls come from: as the Boss, ColorfulHell, or the map's own monsters. |
| **ColorfulHell** | | |
| Extra Colours | Off | ColorfulHell's extra colours (Cyan, Brown, Abyss, FireBlu, Gray): off, on, or half as often. |
| Black Boss | On | Black bosses spawn; off, they become Red. |
| White Boss | On | White bosses spawn; off, they become Black. |
| EX Bosses | Rare | How often a Black or White boss is an EX boss: never, rare, half or always. |
| Drops | Standard | ColorfulHell's drops all at once: standard, scarce, generous or none. |
| Test and Debug | (page) | Every other setting: monster diagnostics, spawn caps, ColorfulHell's own switches and logs. |
| Reset All | (button) | Puts every RSQ Monsters setting back to its default. |

<details><summary>RSQ Monsters: Test And Debug (70 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **World** | | |
| God Mode | (button) | Toggles god mode, for testing. |
| **Monster Diagnostics** | | |
| Family | Chaingunner | The monster family the spawn rows below spawn. |
| Spawn Hostile | Off | A spawned monster acts at once; off, it stands still until Wake. |
| C0001 |  | Spawns this family's Common monster. |
| T0001 |  | Spawns this family's tier monster T0001. |
| T0002 |  | Spawns this family's tier monster T0002. |
| T0004 |  | Spawns this family's tier monster T0004. |
| T0005 |  | Spawns this family's tier monster T0005. |
| T0010 |  | Spawns this family's tier monster T0010. |
| T0003 |  | Spawns this family's tier monster T0003. |
| T0007 |  | Spawns this family's tier monster T0007. |
| T0006 |  | Spawns this family's tier monster T0006. |
| T0008 |  | Spawns this family's tier monster T0008. |
| T0009 |  | Spawns this family's tier monster T0009. |
| B0001 |  | Spawns this family's first boss. |
| B0002 |  | Spawns this family's second boss. |
| X0001 |  | Spawns this family's first EX boss. |
| X0002 |  | Spawns this family's second EX boss. |
| A0001 |  | Spawns this family's extra row A0001. |
| A0002 |  | Spawns this family's extra row A0002. |
| A0003 |  | Spawns this family's extra row A0003. |
| Spawn All | (button) | Spawns the whole family in a line. |
| Remove All | (button) | Removes every monster the diagnostics spawned. |
| Diagnose | (button) | Logs a diagnosis of the spawned monsters. |
| Wake | (button) | Wakes the dormant spawned monsters. |
| **Aimed Monster** | | |
| What Is It | (button) | Tells the tier of the monster you aim at. |
| One Tier Up | (button) | Moves the monster you aim at one tier up. |
| Map One Tier Up | (button) | Moves every monster on the map one tier up. |
| **ColorfulHell Spawn Caps** | | |
| Caps On | On | Caps the highest colour each ColorfulHell family may spawn at. |
| Zombieman | 1 (1 to 13) | The highest colour Zombiemen spawn at (1 Common, 13 White, the full roster). |
| Shotgunner | 1 (1 to 13) | The highest colour Shotgunners spawn at. |
| Chaingunner | 1 (1 to 13) | The highest colour Chaingunners spawn at. |
| Imp | 1 (1 to 13) | The highest colour Imps spawn at. |
| Demon | 1 (1 to 13) | The highest colour Demons spawn at. |
| Spectre | 1 (1 to 13) | The highest colour Spectres spawn at. |
| Cacodemon | 1 (1 to 13) | The highest colour Cacodemons spawn at. |
| Lost Soul | 1 (1 to 13) | The highest colour Lost Souls spawn at. |
| Pain Elemental | 1 (1 to 13) | The highest colour Pain Elementals spawn at. |
| Hell Knight | 1 (1 to 13) | The highest colour Hell Knights spawn at. |
| Baron of Hell | 1 (1 to 13) | The highest colour Barons of Hell spawn at. |
| Revenant | 1 (1 to 13) | The highest colour Revenants spawn at. |
| Mancubus | 1 (1 to 13) | The highest colour Mancubi spawn at. |
| Arachnotron | 1 (1 to 13) | The highest colour Arachnotrons spawn at. |
| Arch-Vile | 1 (1 to 13) | The highest colour Arch-Viles spawn at. |
| Cyberdemon | 1 (1 to 13) | The highest colour Cyberdemons spawn at. |
| Spider Mastermind | 1 (1 to 13) | The highest colour Spider Masterminds spawn at. |
| **ColorfulHell Switches** | | |
| Cyan | Off | Cyan monsters: off, on, or half as often. |
| Brown | Off | Brown monsters: off, on, or half as often. |
| Abyss | Off | Abyss monsters: off, on, or half as often. |
| FireBlu | Off | FireBlu monsters on or off. |
| Gray | Off | Gray monsters on or off. |
| Abyss Shot Markers | Off | Puts markers on Abyss monsters' shots. |
| Cyan Monsters Dodge | On | Cyan monsters jump to dodge. |
| Lead-Aimed Shots | On | Some monsters aim their shots ahead of where you are moving. |
| Red Boss Form | Power | The Red Baron's and Red Arch-Vile's form: power, rage, or either at random. |
| Orange Revenant | Ghost | The Orange Revenant: a no-clip ghost with four escort souls, fast and solid, or either. |
| White Arachnotron Boss | Spider | Which body the White Arachnotron boss has. |
| Black Lost Soul Boss | Queen Bee | Which body the Black Lost Soul boss has. |
| White Mastermind Boss | Armed | Which body the White Mastermind boss has: heavily armed, everlasting, or either. |
| Normal Rocket Damage | On | The Cyberdemon's rocket deals normal damage instead of its own damage type. |
| Health Drops | Standard | How often monsters drop health. |
| Backpack Drops | Standard | How often monsters drop backpacks. |
| Ammo Drops | Normal | How often monsters drop ammo. |
| Extra Drops | Normal | How often monsters drop extras. |
| Weapon Drops | Normal | How often monsters drop weapons (chainsaw, SSG, plasma, rocket launcher, BFG). |
| Powerup Drops | Normal | How often monsters drop powerups (berserk, soulsphere, megasphere, blursphere). |
| Armour Drops | Normal | How often monsters drop green and blue armour. |
| **Logs** | | |
| Tier Log | Off | Logs the colour ladder's work, for the rig. |
| Painted Art Log | Off | Logs what the painted art draws and its time a tic. |
| Plus Boss Log | Off | Logs the White Arch-Vile EX's armour steal. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Miniboss | Reads the Monster Tier (`rsq_mon_worldtier`) and Tiers (`rsq_mon_bdtier`): its fight colours (thralls one colour above the Monster Tier, the Boss two) and the step it writes for a Boss won or lost; its Rank writes the Monster Tier at a new game. Reads Boss From and Thralls From, and asks `RSQMN_RosterService` "set.class", "set.class.ex", "class.set", "class.tier", "tier.next" and "retier". Its EX classes (by "class.tier") and the two bodies in this mod's `RSQBIGBS` lump are its Big Boss pool. This mod holds every monster carrying RSQ Miniboss's `RSQMB_Thrall`, `RSQMB_Ward` or `RSQMB_Called` (asking `RSQMB_Service` "miniboss" and "bossfight") out of every tier change, and lets the act it gives a Big Boss (`RSQMB_ActPhase`) choose a Colourful Hell boss's phase |
| RSQ Score | Asks `RSQMN_RosterService` "tier", "ex", "spawn.odds", "tier.next", "tier.ago", "tier.from" (and "set") for its tier rows. When a ColorfulHell body is swapped this mod asks `RS_ScoreService` "census.take" for the old body and then "census.add" for the new one, so a tier change does not cut its points. "headshot" is passed on to Score's own head check |
| RSQ VisualRewards | Asks "tier" for the tier gem beside each health bar |
| RSQ Grenade | Asks "tier" for Explosion Colour's Kill Colour |
| RSQ SlowMo | A travelling beam is a missile, so SlowMo slows it; its particles ask `RSQSM_Service` "scale" so they slow with the world |
| Brutal Doom 22, XMVE | Found by class name (`BrutalWeapon`, `Brutal_Blood`, `BD_Token`). A table of 193 classes (and anything that is a Doom monster's child or replaces one) gives each its family; 24 are exempt (the code calls them scripted map pieces), and three health-bar bosses get the health curve and the tint only. Brutal Doom's `GoFatality` marks a fatality |
| Champions | A swapped body keeps its champion (Champions' own record and revive build it again); a Champions tint put over a tier colour is taken off the next tic |
| LegenDoom | A swapped body is made legendary again by LegenDoom's own item, risen again if it had risen, with the share of legendary health it had. Its health settings are read |
| Universal Entropy | A swapped body keeps its size and voice; its colour put over a tier colour at spawn is taken off |
| Legion of Bones | Its classes, listed by name, never take a body's colour |
| No More Hitscans | Its tracer speed (`nmh_projspeed`) is the travelling beam's speed |
| RSQ_BDXMTiers_<Colour>.pk3 | The painted frames, read by path (`rsrecolour/<colour>/<frame>.png`, and each colour's `sprites.txt`). Without them every kit monster wears the tint |
| Every series mod | One Radiant Silvergun Options entry; this mod adds the RSQ Monsters page to it |
| (its own service) | `RSQMN_RosterService`: GetInt "set", "tier", "ex", "spawn.odds", "tier.next", "tier.ago", "tier.from", "headshot", "retier", "class.set", "class.tier"; GetString "set.class", "set.class.ex". Any other request: -1 or "" |

## The ColorfulHell ladder

Each colour of each family is its own monster: its name and spawn health, from the code (`zscript/monsters/RS_Retier.zs` `ClassFor`, and each class). The Common ones are Doom's own monsters with Doom's health. Under a tier change or a Monster Tier above Common a body gets its family's ladder health instead, where that is higher. A name in brackets has no name of its own in the code.

<details><summary>17 families, 13 colours (220 monsters: the Spectre's Abyss is the Demon's)</summary>

| Family | Its colours: name (spawn health) |
|---|---|
| Zombieman | Common: Zombieman (Doom's own) · Green: Green Zombie (40) · Blue: Blue Zombieman (60) · Purple: Purple Zombieman (95) · Cyan: Cyan Zombieman (30) · Brown: (RS_BrownZombie2) (100) · Yellow: Orange Zombiewoman (140) · FireBlu: FireBlu Zombie (70) · Gray: Gray Zombieman (110) · Red: Red ZombieUnman (186) · Abyss: Abyss Infected Zombie (200) · Black: Player 9 (2500) · White: UNDERTAKER (2800) |
| Shotgunner | Common: Former Sergeant (Doom's own) · Green: Green Former Sergeant (45) · Blue: Blue Former Sergeant (55) · Purple: Purple Former Sergeant (75) · Cyan: Cyan Shotgun dood (60) · Brown: Muddy guy (155) · Yellow: Yellow Former Sergeant (85) · FireBlu: Gun guy with skin condition (225) · Gray: snipah (155) · Red: Red RNG Former Sergeant (150) · Abyss: Shotgun of the abyss (300) · Black: Shotgun Crew Commander (1950) · White: BENELLUS,GOD OF SHOTGUNS (5000) |
| Chaingunner | Common: Former Captain (Doom's own) · Green: Green Chaingunner (85) · Blue: Blue Chaingunner (105) · Purple: Purple Chaingunner (120) · Cyan: Jetpack Larry (125) · Brown: Brown Noise Maker (250) · Yellow: Orange Former Captain (200) · FireBlu: Bad makeup day (450) · Gray: That is bad camo (275) · Red: Red Chaingunner (300) · Abyss: Abyss Captain (500) · Black: ITS MR GENERAL TO YOU,MAGGOT (4500) · White: The crazy lady scientist (7777) |
| Imp | Common: Imp (Doom's own) · Green: Green Imp (70) · Blue: Blue Imp (83) · Purple: pImp (105) · Cyan: Cyanide Imp (125) · Brown: medium evil imp (215) · Yellow: Orange Imp (145) · FireBlu: Now THATS ugly (125) · Gray: Stoned Imp (265) · Red: Red Imp (200) · Abyss: Abyss Imp (300) · Black: Smoking Black Imp (3800) · White: Imp Master (6666) |
| Demon | Common: Pinky (Doom's own) · Green: Greeny (170) · Blue: Bluey (205) · Purple: Purply (260) · Cyan: Ice Worm (270) · Brown: Brownie (420) · Yellow: Yellowy (325) · FireBlu: FireBluey (205) · Gray: Coiling menace (700) · Red: Red-y (400) · Abyss: Bad dog (600) · Black: FRESH MEAT (4500) · White: YOU KNOW WHO I AM (8000) |
| Spectre | Common: Spectre (Doom's own) · Green: Green Spectre (175) · Blue: Blue Spectre (210) · Purple: Purple Spectre (250) · Cyan: Ice Worm II (270) · Brown: Brown hide (300) · Yellow: Yellow Spectre (320) · FireBlu: FireBluey (205, the Demon's body, unseen) · Gray: Uhm (450) · Red: Red Spectre (394) · Abyss: Bad dog (600) · Black: Backstabber (3000) · White: Tentacle monster? (7500) |
| Cacodemon | Common: Cacodemon (Doom's own) · Green: Green Cacodemon (450) · Blue: Blue Cacodemon (480) · Purple: Purple Cacodemon (528) · Cyan: FrostBaller (500) · Brown: Gruelsome (500) · Yellow: Yellow Cacolich (720) · FireBlu: One Ugly Tomatoe (800) · Gray: Stone Cold Cacodemon (650) · Red: Red Cacodemon (830) · Abyss: Abyssmal Tomatoe quality (1100) · Black: SHOCKMASTER (5000) · White: PLEASE NO (5000) |
| Lost Soul | Common: LostSoul (Doom's own) · Green: Green LostSoul (120) · Blue: Blue LostSoul (145) · Purple: Purple LostSoul (150) · Cyan: Cyan LostSoul (80) · Brown: THE CUBE (125) · Yellow: Yellow LostSoul (180) · FireBlu: Charred skull (175) · Gray: A hive (50) · Red: Bloody Red LostSoul (240) · Abyss: beetlejuice (380) · Black: Queen Bee (1500) · White: The shifter (4500) |
| Pain Elemental | Common: Pain elemental (Doom's own) · Green: Bad Gas Green Pain elemental (500) · Blue: Blue Pain elemental (610) · Purple: Purple Pain elemental (790) · Cyan: Icey weird Pain elemental (963) · Brown: Ball of fleshy bits (800) · Yellow: Volcanic Orange Pain elemental (900) · FireBlu: the fuck is that (800) · Gray: The nasty hive (1450) · Red: Red rage elemental (1111) · Abyss: Spooky Skull! (1600) · Black: Hell Soul Elemental (5000) · White: Against thee wicked (5000) |
| Hell Knight | Common: HellKnight (Doom's own) · Green: Green HellKnight (600) · Blue: Blue HellKnight (666) · Purple: Royal Purple HellKnight (730) · Cyan: Cyanide HellKnight (700) · Brown: Lion? (700) · Yellow: Orange Bruiser (999) · FireBlu: Knight with clown armor (900) · Gray: Gray knight (800) · Red: Red Knightmare (1300) · Abyss: Abyss Bruiser (1850) · Black: Terminator (5555) · White: Ghost of 1993 (5000) |
| Baron of Hell | Common: BaronOfHell (Doom's own) · Green: Green BaronOfHell (1170) · Blue: Blue Blood Baron (1309) · Purple: Royal BaronOfHell (1500) · Cyan: Cyanide bitten BaronOfHell (1666) · Brown: Brown Baron Boi (2250) · Yellow: Grand Orange BaronOfHell (1888) · FireBlu: How awkward! (2300) · Gray: Statue? (2000) · Red: Power Baron of Red (2100) · Abyss: (RS_AbyssBaron2) (3333) · Black: Baron from Abyss (8907) · White: Hell's Slice and Dicer (13069) |
| Revenant | Common: Revenant (Doom's own) · Green: Green Revenant (360) · Blue: Blue Revenant (420) · Purple: Purple Revenant (515) · Cyan: Cyan Revenant chains (480) · Brown: Mummy mummy (666) · Yellow: Terrifying Orange (NoClip?) Revenant (666) · FireBlu: Skeleton on fire! (720) · Gray: Punchout master (660) · Red: a Bloody Red Revenant (830) · Abyss: Abyss Revenant (1000) · Black: The Black Knight (4500) · White: Lichest Lich (8866) |
| Mancubus | Common: Mancubus (Doom's own) · Green: Green Mancubus (750) · Blue: Blue Mancubus (850) · Purple: Purple Mancubus (950) · Cyan: Crystal Fatso (720) · Brown: What big hands you got (850) · Yellow: Orange Mancubus (1250) · FireBlu: Big blob of fireblu (1400) · Gray: Big Gray and Ugly (1000) · Red: Red Horned Mancubus (1600) · Abyss: Ralph Bluetawn (2150) · Black: The thing from the swamp (9001) · White: Angry Mama (15000) |
| Arachnotron | Common: Arachnotron (Doom's own) · Green: Green Arachnotron (600) · Blue: Blue Arachnotron (700) · Purple: Purple Arachnotron (800) · Cyan: Cyan Flying Spider (777) · Brown: Brown Recluse (600) · Yellow: Orange Brainchoton (777) · FireBlu: Ugly floater (999) · Gray: Metal Spider? (600) · Red: Red Rage Arachnotron (1000) · Abyss: Eye see (1850) · Black: Macross Missile Spam (5342) · White: White Spider (7000) |
| Arch-Vile | Common: Archvile (Doom's own) · Green: Green Archvile (750) · Blue: Blue Archvile (860) · Purple: Purple Archvile (1001) · Cyan: Barnie (1200) · Brown: That's a messy vile (1400) · Yellow: Golden Archvile (1333) · FireBlu: Horrible sight (1000) · Gray: Like a stone (1400) · Red: Grand Redfirevile (3200) · Abyss: Aliens? (2500) · Black: Void Gazes Back (7750) · White: Here I am (13000) |
| Cyberdemon | Common: CyberDemon (Doom's own) · Green: Green CyberDemon (5000) · Blue: Blue CyberDemon (5800) · Purple: Purple CyberDemon (6400) · Cyan: Akinator (8083) · Brown: ComposterDemon (7557) · Yellow: Less cyber yellow Cybie (7777) · FireBlu: (RS_FireBluCybie2) (7777) · Gray: Stoner Cybie (8888) · Red: Red Overlord (10000) · Abyss: Unholy diver (12000) · Black: He Will Smith You (14500) · White: It runs doom (21000) |
| Spider Mastermind | Common: Spider MasterMind (Doom's own) · Green: Green Spider MasterMind (4200) · Blue: Frosty Blue Spider MasterMind (5600) · Purple: Purple Spider MasterMind (6666) · Cyan: Cyanide Master(Mind) (7777) · Brown: Death N Decay Master (8858) · Yellow: Yellow MasterMind (7777) · FireBlu: It's horrifying! (8007) · Gray: Rocky Road Spider (8007) · Red: Red MasterMind (10000) · Abyss: Abys$&#124;<%#¤e£Mind (12222) · Black: Pseudo Old God (11111) · White: Heavily Armed Spidey (15000) |

</details>

<details><summary>The 16 EX bosses and Colourful Hell Plus's other boss bodies</summary>

| Family | Body | Name (spawn health) | Comes from |
|---|---|---|---|
| Zombieman | RS_BlackZombieEX | Player X (5000) | the Black gate's EX roll (Colourful Hell 1.04) |
| Chaingunner | RS_BlackCGuyEX | LET ME SEE YOUR WARFACE (8999) | the Black gate's EX roll (1.04) |
| Shotgunner | RS_WhiteSGEX | BENELLUS,GOD OF SHOTGUNS,ANGRIER (12537) | the White gate's EX roll (1.04) |
| Imp | RS_BlackImpEX | Smoking Black Imp EX (8600) | the Black gate's EX roll (1.04) |
| Cacodemon | RS_BlackCacoEX | SHOCKMASTER RETURNS (10000) | the Black gate's EX roll (1.04) |
| Lost Soul | RS_WhiteLSoulEX | The vengeful soul (12500) | the White gate's EX roll (1.04) |
| Hell Knight | RS_BlackHKEX | Terminator MK II (11000) | the Black gate's EX roll (1.04) |
| Revenant | RS_BlackRevenantEX | The Black Knight unleashed (7500) | the Black gate's EX roll (1.04) |
| Mancubus | RS_BlackFatsoEX | The thing from the bog (18000) | the Black gate's EX roll (1.04) |
| Arachnotron | RS_BlackSPEX | Macross Missile Spam EX (12000) | the Black gate's EX roll (1.04) |
| Spectre | RS_BlackSpectreEX | THE BACKSTABBER UNSILENCED (7250) | the Black gate's EX roll (Colourful Hell Plus) |
| Arch-Vile | RS_BlackArchEX | AHH HELP!!! (2700) | the Black gate's EX roll (Plus) |
| Arch-Vile | RS_WhiteArchEX | Time to die (20800) | the White gate's EX roll (Plus) |
| Cyberdemon | RS_BlackCybieEX | Obsidian Tyrant (24000) | the Black gate's EX roll (Plus) |
| Cyberdemon | RS_WhiteCybieEX | It crashes doom II (32767) | the White gate's EX roll (Plus) |
| Arachnotron | RS_WhiteSPEX | WHITE HOT SPIDER (9500) | the White gate's EX roll (Plus) |
| Spider Mastermind | RS_WhiteMindES | Everlasting White Spidey (20000) | White Mastermind Boss: Everlasting or Either; RSQ Miniboss's Big Boss pool |
| Arachnotron | RS_WhiteSPFusion | White Spider, the Fusion (4000) | White Arachnotron Boss: Fusion; RSQ Miniboss's Big Boss pool |
| Arachnotron | RS_WhiteSPPlus, RS_WhiteSP11Old | White Spider, New and Old | White Arachnotron Boss: New, Old |
| Lost Soul | RS_BlackLSoulOld3 | the Old Black Lost Soul | Black Lost Soul Boss: Old |

</details>

## Limits

- The Monster Tier stops at Red, also when it is set higher (in the console, or by RSQ Miniboss after a Boss win): a value above Red counts as Red, on a new map too. Abyss, Black, White and the steps past White come only from a change another mod asks for or from Test and Debug.
- A change of Monster Set takes hold on the next map or a restart; the monsters already there stay as they are.
- The Monster Tier is a server setting kept in a saved game: loading a save brings back the tier it was made at.
- Kit colours and powers need a monster with a Doom family; a monster with none keeps its mod's own look and numbers (it only takes a coloured body's colour when it rises out of one).
- ColorfulHell's front-page rows (Extra Colours, Black Boss, White Boss, EX Bosses, Drops) touch only ColorfulHell monsters: in the default BD22 XMVE set they change RSQ Miniboss's Colourful Hell bosses and thralls and nothing on the map.
- With the spawn caps at their default, a ColorfulHell map is all Common until the Monster Tier rises: Colourful Hell's own colour roll, its Black and White bosses and its EX bosses come only with a raised cap or in a Boss fight.
- With ColorfulHell, every Doom imp ball, Cacodemon ball, Baron ball, Mancubus shot, Arachnotron plasma and rocket spawned in the game is Colourful Hell's copy, whoever fires it (Doom's own rocket launcher too).
- Only a ColorfulHell monster's railgun travels; a Brutal Doom or XMVE railgun is its mod's own.
- Colourful Hell Plus's attacks that blacken your screen do nothing here (the owner's rule: no darkening). Colourful Hell's own bonus and ambush events are kept, but nothing starts them (as in Colourful Hell).
- A Boss fight's monsters never change tier while the fight is on: What Is It still works, One Tier Up says it keeps its tier.
- Test and Debug's logs print to the console and the screen.
- There are no keys: every control is a menu row (and the console events above).

## Credits

- **Colourful Hell** by **Hege Cactus** ([its thread](https://forum.zdoom.org/viewtopic.php?t=47980)): every
  ColorfulHell monster, its colours, names, numbers, attacks, sounds and switches, rebuilt in ZScript from its
  DECORATE, and its sprites (670 of them added from Colourful Hell 1.04 on 2026-11-16; sprites whose names clash with
  Brutal Doom 22, XMVE, Legion of Bones or Champions were renamed, `docs/SPRITE_CLASHES_2026-11-16.md`).
- **Colourful Hell Plus** by **Dewzanity** ([its thread](https://forum.zdoom.org/viewtopic.php?p=1247515)), built on
  Colourful Hell 1.04: its R3.0.1 boss bodies (the Black Spectre, Arch-vile and Cyberdemon EX, the White Arachnotron,
  Arch-vile and Cyberdemon EX, the Everlasting White Spidey, the Fusion and New White Arachnotrons), with their
  attacks, sounds and sprites. The code also follows this edition in places.
- **presidentkoopa:** his Hackfraud (HF) tree, where the tier-change flash and the On Tier Change rule come from;
  RS Monsters.
- **id Software:** the Doom monsters, sprites and sounds the Common forms use, read from the IWAD.
- **QuestZDoom** (Emawind and Team Beef): the engine.

---
Written from the code at commit 678a73284, 2026-11-27; updated for the owner's answers F1, F2, F3 and F7 the same day.
