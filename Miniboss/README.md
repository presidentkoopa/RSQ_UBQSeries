# RSQ Miniboss

A Boss fight you earn and call in. Killing, chaining kills and moving through the map fill the Boss meter; when it is full you check your wrist and press Use (or wait), and a Boss lands with its thralls around you. Beat it for a world tier step, a Score life crate and a kiosk of legendary weapons; four Boss fights fill the Big Boss bar, and a Big Boss comes alone. The menu calls the mod **RSQ Boss**. LegenDoom Lite and Mikk-'s Champions are built in.

<a name="how-to-play"></a>
## How to play

"Boss" is the miniboss of a fight; "thralls" are the monsters that land with it. "Watch check" is the back of a wrist turned to your eyes; "pulse check" is the inside of the off-hand wrist turned to your eyes. Distances: 32 map units are 1 m.

| Do this | What happens | Needs |
|---|---|---|
| Kill monsters, kill again within 3 s, and keep moving | The Boss meter (right of RSQ Score's bar) fills: a kill 10 + its health / 50 (at most 30), +6 a step of a chain (at most +30), 2 points every 2 s you moved 3 m; 1000 is full | Bosses: On (default); Meter Speed (default 1) |
| The same with RSQ Score or Gun Bonsai VR loaded | A kill counts 4 while Score fills it; each kill's Score style points add x0.25 (at most 120), Gun Bonsai XP on the main hand's gun x0.2 | Meter Fills From: Both (default); RSQ Score / RSQ Gun Bonsai VR |
| Fill the meter | It turns gold and beats; RSQ Glow In The Dark's map glow beats red while it waits. A fight's own monsters never fill it, and nothing fills it during a fight, the 20 s after one, or after this map's Boss | |
| Leave a full meter alone | The Boss comes by itself 60 s after the meter filled; while little is happening to you (the director's intensity under 0.15) each tic counts twice | Arrives By Itself (default 60 s); Director: On (default) |
| With the meter full, check your watch (the back of either wrist under 80 degrees off facing your eyes, the wrist within 50 degrees of where your head points; once met, kept to 88 and 65) and press Use while it is met or within 8 tics after | The fight is called in, with a chime. It comes when the rules allow; until then one line under the meter says why: No Boss: Too Early, Map Limit, Cooldown, Low Health, Near Exit, Too Busy, No Room, or Boss: Get Ready | Call It In: On (default) |
| Check your pulse: the inside of the off-hand wrist under 60 degrees off facing your eyes, the wrist within 50 degrees of where your head points (kept to 75 and 65) | The Start Fight card shows on the inside of that wrist: grey; gold (START FIGHT?) when the meter is full and nothing is called; BIG BOSS! when a Big Boss is due. It stays 2 s after (or Gun Cards' Stays After when longer). Not while the off hand steadies the gun | Wrist Card: On (default) |
| Press Use while the gold card shows | The fight is called in past every wait (time, map limit, cooldown, health, exit, busy, the director); only No Monsters and No Room still stop it | Wrist Card: On (default) |
| Watch your sides and back when the fight comes | 3 s of slow motion and dark. Each thrall's spot is marked by its crosshair 0.75 s before it lands, at your sides and behind, 400 to 700 units out, 0.5 to 1 s apart; each fights the moment it lands. The Boss lands in front last, 1.25x size, and cannot be hurt for 1.5 s | Arrival: Around You (default); slow motion RSQ SlowMo, dark RSQ Glow In The Dark |
| Kill the thralls | While thralls live the Boss takes 20% of each blow (every thrall up) to 100% (none left), and its ring of fire burns. Each thrall's death takes away the Champion power it gave the Boss | Thralls (default 3, up to 3 more by world tier) |
| Shoot the Boss | It has 3 lives (X3 on its bar). Each life lasts about 20 s of your own recent damage (never under its own health). A life lost: it refills, cannot be hurt for 5 s (GUARD on its bar), and steps up: its bar's colour one up, 15% faster, one fresh thrall | Lives (default 3); Boss Life by Time: On (default); Boss Steps Up: On (default) |
| Shoot the WEAK! points while the Boss winds up | Every 20 s (Rank 0) to 10 s (Rank 100) it roars, the room goes red and 2 WEAK! points (40 health each) with gold crosshairs show on its front for 3 s. Break both: CRITICAL!, it staggers 3 s taking x2 damage, and its thralls stagger as long | Telegraphed Attack: On (default) |
| Miss, and dodge what comes | The attack fires: a fan of big shots aimed at you, a fire ring along the floor with two gaps (step into a gap or jump it), or a slow ball aimed where you stood. 15 damage a hit at the lowest tier, more each tier and life | Telegraphed Attack: On (default) |
| Hit a staggered thrall or the Boss in CRITICAL! with melee (punch, kick, headlock, saber, ShieldSaw, whip, BD22's axe, chainsaw or sword) | Finisher: +25 health, +15 armour, 250 Score points (the Boss: twice), a 1 s slow (Boss 2 s); the thrall dies. A thrall staggers 2 s, once, when a blow takes it under 25% of its most health | Melee Finishers: On (default) |
| Stand within 4 m of one spot for 8 s in a fight | The nearest living thrall is sent straight at you, roaring, and shoots less while it closes | Camping Pressure: On (default) |
| Hurt a SUMMONER! while it casts (green rings on the floor, 1.5 s) | Every 10% of its life's health you deal takes one ring away; what is left lands as 2 to 3 lower monsters (at most 6 alive), every 15 s | Boss Traits and Summoner: On (default) |
| Sidestep a CHARGER! after its two stamps and the line on the floor | It rushes the line, hits the wall or skids, and is stunned 2 s taking x1.5 damage. Caught: 20 damage, knocked back, and the next charge comes sooner | Boss Traits and Charger: On (default) |
| Hit a SHIELDED! Boss from behind, or break its 3 WEAK! rim points | Blows within 90 degrees of its front are BLOCKED. All three points broken: the shell shatters for the rest of that life. CRITICAL! opens it too | Boss Traits and Shielded: On (default) |
| Kill both halves of a SPLITTER! | SPLITTING! warns near the end of each life but the last; it becomes two at 0.7 size dealing x0.75, the life's health split between them; the life ends when both are down | Boss Traits and Splitter: On (default) |
| Kill the Boss | BOSS DEFEATED!; the world tier goes up one; Score's Miniboss Called row (1500); RSQ Score's life crate where it died; the Big Boss bar +25%; the Boss kiosk beside it. The thralls left go free | Tier change: RSQ Monsters; crate: RSQ Score; kiosk: see below |
| Walk over the life crate | +1 Score life (RSQ Score's own crate) | RSQ Score |
| Spend a Score life during the fight, or leave the map with it on | The fight is lost: the Boss and thralls leave on beams (no drops, no kill), BOSS WINS!, the world tier goes down one. The Big Boss bar still gets +25% | Tier change: RSQ Monsters |
| Stand still for 2 s within 3 m of the kiosk | It opens and turns to face you: up to three legendary offers for guns you carry, priced in Score gold. Shut while a fight lands or runs | Boss Kiosk: On (default); BD22 VR Reloaded with LegenDoom, RSQ Score |
| Point a hand at an offer (or put your hand in it) | Its card shows (the gun, rarity, effect, what you have on that gun) and a dotted beam runs to it. That hand's trigger then belongs to the kiosk: the gun does not fire | Boss Kiosk: On (default) |
| Pull that hand's trigger | Bought if your gold covers it (Common 150, Uncommon 250, Rare 500, Epic 900): BD22 VR makes the real legendary and hands it over. Each offer once | Kiosk prices (defaults as shown) |
| Press that hand's alt fire on an offer, or trigger LUCKY then trigger an offer | LUCKY: one Score life spent, the offer one rarity up. Once a kiosk; a Boss kiosk's offers stop at Rare | a Score life |
| Point at REPAIR and pull the trigger | Every gun you carry back to full condition, 1 gold a missing point (at least 10) | RSQ Gun Cards' Weapon Condition |
| Walk 0.75 m past the kiosk's range | It folds away. It stays where it is until the map ends | |
| Fill the Big Boss bar (+25% a Boss fight, won or lost) | A Big Boss is due: it is called like a Boss (watch check and Use, or the card, which reads BIG BOSS!) or comes by itself; never held by the map limit | Big Boss: On (default) |
| Fight a Big Boss | Its arrival card shows its weak points and HP; it lands alone, each life worth about 60 s of your damage. 3 weak points (60 health); each one broken throws 10 health and 10 armour bits, a CRITICAL! 40 and 25; CRITICAL! is x3 for 4 s | Big Boss: On (default); RSQ Monsters for an EX Big Boss |
| Kill a Big Boss's summons while it shows GUARD | After its window it takes no damage while its own summons live (lines of light join them to it), 20 s at most | Big Boss Guard: On (default) |
| Beat a Big Boss | As a Boss win, and its kiosk has five Epic offers, no LUCKY | |
| Get a REVENGE or a REVIVE | Your damage x1.5 for 10 s; DAMAGE UP | RSQ SlowMo's DOWN |
| Deal any damage | Your damage is +10% for each world tier colour above Common (x1.9 at Red) | Your Damage a Colour (default 0.1); RSQ Monsters |
| Kill, fight on unhurt; or take heavy damage, go DOWN, lose a Score life, die | Rank (0 to 100) moves; every 8 points is the next world tier colour, inside a window the map sets (Common on the first map up to Red on the second-to-last). RANK nn under the meter | Rank Difficulty and Rank Ceiling: On (default); RSQ Monsters |
| Hit a melee strike on a knocked-down or dazed monster outside a Boss fight | VR Finisher: it is gibbed, BD22's two fatality bonus items drop, 100 Score points, a 1 s slow. Not over 1000 spawn health, not a boss | VR Finisher: On (default); BD22 (knocked down) or Gun Bonsai VR (dazed) |
| Do a BD22 fatality, stealth kill or execution | No scene: the monster's body is gibbed where it stood and the finisher is paid | No BD22 Fatalities: On (default); Brutal Doom 22 |
| Bring a legendary monster (3x health) under half its health | It transforms: full health again, a stat boost and x2 damage; killed, it drops loot by its health | LegenDoom Lite (stands down while LegenDoom is loaded) |
| Kill a Champion | Champions' colour powers and its item bundle (about half the monsters at Ultra-Violence: Champion Chance, Difficulty Based) | Champions (built in) |
| Call a fight with Arrival: Classic | Every thrall lands in front, then the Boss; all are held and cannot be hurt until a 5 s count ends | Arrival: Classic (default Around You) |
| Do the watch check and press Use | Nothing. The Start Fight card still calls the fight | Call It In: Off (default On) |
| Call a fight that would wait | It comes anyway (only the map limit and cooldown still hold it); with no room, the spot is taken anywhere it fits | Ignore Spawn Restrictions: On (default Off) |
| Call a fight with Graves Rise on | RSQ Graveyards' tombstones raise Legion of Bones undead as it lands (one a stone, or one per thrall a stone; the map or a radius) | Graves Rise: On (default Off); Legion of Bones and RSQ Graveyards |
| Play with Rank Difficulty off | The world tier stays where RSQ Monsters' page sets it; Boss wins and losses still step it | Rank Difficulty: Off (default On) |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Boss: Legendoom Lite

| Option | Default | What it does |
|---|---|---|
| **Legendary Enemy Options** | | |
| Legendary Health % | 300 (100 to 10000) |  |
| Legendary Damage x | 2 (1 to 10) |  |
| Legendary Boss Health % | 200 (100 to 10000) |  |
| Legendary Boss Damage x | 1.5 (1 to 10) |  |
| Legendary Extra Chance | No Extra Chance |  |
| DIE.exe | false |  |
| Legendary Monsters | false |  |
| Legendary Bosses | totally gotta have em |  |
| Legendary Constraints | true |  |
| Legendary Map Markers | Off |  |
| Legendary Allies Allowed | Off |  |
| Legendary Debug Mode | Off |  |
| **\cqover time every X seconds.** | | |
| Legendaries Over Time | Off |  |
| LoT Interval | 60 |  |
| **\cqare dropped from Legendary enemies.** | | |
| Item Drop Type | Standard item drops |  |
| **\cqof health for a tier directly** | | |
| Tier 1 Health % | 100 |  |
| Tier 2 Health % | 250 |  |
| Tier 3 Health % | 500 |  |
| Tier 4 Health % | 750 |  |
| Tier 5 Health % | 1000 |  |
| **\cqflagged enemies, like cyberdemons.** | | |
| Boss Tier 1 Health % | 1500 |  |
| Boss Tier 2 Health % | 3500 |  |
| Boss Tier 3 Health % | 7000 |  |
| Boss Tier 4 Health % | 12500 |  |
| Boss Tier 5 Health % | 25000 |  |
| **Access to other compatible menus through here** | | |
| Yholl Mod Options | (page) |  |
| Other Mod Options | (page) |  |

<details><summary>Other Yholl-made Mod menus (2 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| DRLA Options | (page) |  |
| Final Doomer Options | (page) |  |

</details>

<details><summary>All other compatible Mod menus (2 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| Colourful Hell | (page) |  |
| Shades of Doom | (page) |  |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Score | Its style points and kill serial fill the meter; the meter sits right of its bar; Boss wins send its "Miniboss Called" row, finishers its "Finisher" row; a Score life spent in a fight loses it; its life crate drops on a win; its gold pays the kiosk and its lives pay LUCKY. Score sends "rank.life" and asks "rank" and "meter.bottom" |
| RSQ Gun Bonsai VR | Its XP on the main hand's gun fills the meter (asked: "level", "xp", "xp.next"). Its daze (RSQ_Dazed) counts as staggered for the VR Finisher |
| RSQ SlowMo | The landing's slow motion ("start.bossfight"), edge arrows on landing thralls ("arrow.add", "arrow.clear"), finisher slow ("g2.slow"). Its DOWN gives the comeback (RSQMB_RSQDownJoin "down.revenge", "down.up") and moves Rank. The Boss bar steps aside while you are DOWN. It asks "meter.x", "meter.w", "meter.h", "meter.bottom", "miniboss", "thrall", "bossfight", "colour", "fight.target" and "window" |
| RSQ VisualRewards | Arrival beams, words over monsters (WEAK!, CRITICAL!, BOSS DEFEATED!, trait words), pops, toasts, the BOSS INCOMING / WIN / LOSS banners and the Boss music scene. It asks "bossfor rewards", "wasboss", "bigboss", "bossfight", "tier", "miniboss", "thrall", "boss", "bigname", "meter.*" |
| RSQ Glow In The Dark | The map glow beats red while the meter waits, goes dark for the landing, grey while thralls stand, red in a wind-up, a wave at the Boss's death. It asks "miniboss", "boss", "colour" |
| RSQ Monsters | The world tier (rsq_mon_worldtier) sets fight colours and is stepped by wins, losses and Rank; Boss and thrall types from its ColorfulHell roster; EX monsters are the Big Bosses (each with its own kit, its act given as RSQMB_ActPhase); tier changes are held back during a fight |
| RSQ Gun Cards | Its wrist reader answers the watch and pulse checks ("inspect", "pulse"); its Stays After and Watch Card: Always are read for the card (Always shows it whenever its face is turned to you and you look its way); REPAIR uses its Weapon Condition ("cnd.on", "cnd.worn", "cnd.fix"). It asks "fightcard.up" |
| BD22 VR Reloaded | The kiosk's offers and purchases (RSLD_KioskService); the Boss's own legendary drop is taken by the kiosk ("kiosk.take"). Its fatality, execution and stealth-kill tokens are taken (No BD22 Fatalities); its knock-down counts as staggered |
| LegenDoom | Thralls and the Boss are made legendary (Legendary Thralls); the Boss gets the higher of LegenDoom's boss and normal legendary health; LegenDoom Lite stands down |
| RSQ Tactical Rig | Asks "callin" (its watch-check gun move leaves Use alone while a call is possible) and "wasboss" |
| RSQ Melee, RSQ Grapple | Ask "bossfor" ("headlock", "yank"), and Grapple "shielded" and "invulnerable": a Boss refuses the headlock and the yank (No Headlock, No Yank). Their melee damage types count for finishers |
| RSQ ShieldSaw | Asks "bossfor" "ldhealth" (a Boss's legendary health). Its grind and disc count for finishers |
| RSQ Saber, RSQ Whip | Their damage types count for finishers |
| RSQ Graveyards with Legion of Bones | Graves Rise ("bones.graves"); its stones beat with the waiting meter ("stones.pulse") |
| RSQ Accessibility (being removed) | Photosensitive Mode calms the flashes; Text Size places the meter without Score; colour-blind letters on trait words; Rumble Backup on a CHARGER!'s stamps; its Wrist Turn says which side of the wrist is the watch. Without it every one of these is off and the watch is the back of the wrist |
| Services this mod answers | RSQMB_Service: miniboss, thrall, wasboss, lives, invulnerable, shield, living, legendary, colour, bossfight, tier, bigboss, ex, ex.ready, rank, director, director.relax, bossfights, fightcard.up, meter, meter.ready, callin, bossfor (rewards, yank, headlock, ldhealth), rank.life; ui: meter.bottom, meter.x, meter.w, meter.h; objects: boss, thrall, fight.target; strings: powers, bigname; always 0: enraged, greed, window, segments, shielded. RSQMB_GCopyService: reader, inspect, inspect.tics, inspect.any, pulse, pose.why |

## Limits

- There is no key of its own: every call is the watch check and Use, the Start Fight card and Use, or the timer.
- Use is not taken from the engine: the press that calls a fight also does whatever Use does where you stand.
- With the meter full, any Use press within 8 tics of a watch check, or within 2 s of a pulse check (the card lingers), calls the fight, even one meant for a door.
- The watch check and the card need VR hand poses; out of VR a fight only comes by itself.
- The watch check and Use is read only while the meter (or the Big Boss bar) is full and nothing is called.
- One Boss a map (Per Map Cap 1); after it the meter fills no more on that map and the Big Boss bar shows in its place.
- The kiosk needs BD22 VR Reloaded's kiosk service (it needs LegenDoom) and RSQ Score; without them a won Boss drops its legendary as before. Offers are only for guns you carry; with none, there is no kiosk.
- Nothing in a fight changes colour or body: RSQ Monsters' tier changes are turned back while it is on, and Rank waits to write the world tier until it ends.
- A thrall drops no gun.
- The Boss never gets the engine's BOSS flag; it counts as a boss only for the rows under Counts as Boss.
- A Big Boss comes alone; without RSQ Monsters it is the map's strongest monster type.
- Without RSQ VisualRewards there are no beams (Doom's teleport fog instead) and the big words are printed on screen.

## Credits

The full list is in **CREDITS.txt**.

- **Tartlman** (*Minibosses!* v0.1.1, 2019): the mod this rebuilds (a miniboss with extra lives and thralls tied to it
  by trails) and its effects in the IWAD's own sprites. Kept unmodified in original/. The thrall markers, chains and ring
  of fire are rebuilt to match its effect actors' settings and states and its controller's placement exactly (owner
  2026-11-17); the rest of its code is not copied.
- **presidentkoopa:** the set piece's design, the miniboss fight (the meter, the call-in, the arrival, the drops) and the
  reworked fight (the staggered arrival, the HUD bars, the words).
- **Joshua Hard** (*Dynamic Enemy Reinforcements* v3, MIT): the idea of landing reinforcements on the map's own
  monster start spots (none of its code).
- **coldcite** (*Top HP Bars*): the bar art, via RSQ VisualRewards.
- **id Software:** the sprites, sounds and small-font X, read from the IWAD (not shipped).
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.

---
Written from the code at commit a283738bb, 2026-11-27.
