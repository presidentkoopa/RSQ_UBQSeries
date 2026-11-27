# RSQ Miniboss

A Boss fight you earn and call in. Killing, chaining kills and moving through the map fill the Boss meter; when it is full you turn the inside of your off-hand wrist to your eyes and press Use on the Start Fight card (or wait), and a Boss lands with its thralls around you. Beat it for a world tier step, a Score life crate and a kiosk of legendary weapons; four Boss fights fill the Big Boss bar, and a Big Boss comes alone. The menu calls the mod **RSQ Boss**. LegenDoom Lite and Mikk-'s Champions are built in.

<a name="how-to-play"></a>
## How to play

"Boss" is the miniboss of a fight; "thralls" are the monsters that land with it. "Watch check" is the back of a wrist turned to your eyes; "pulse check" is the inside of the off-hand wrist turned to your eyes. Distances: 32 map units are 1 m.

| Do this | What happens | Needs |
|---|---|---|
| Kill monsters, kill again within 3 s, and keep moving | The Boss meter (right of RSQ Score's bar) fills: a kill 10 + its health / 50 (at most 30), +6 a step of a chain (at most +30), 2 points every 2 s you moved 3 m; 1000 is full | Bosses: On (default); Meter Speed (default 1) |
| The same with RSQ Score or Gun Bonsai VR loaded | A kill counts 4 while Score fills it; each kill's Score style points add x0.25 (at most 120), Gun Bonsai XP on the main hand's gun x0.2 | Meter Fills From: Both (default); RSQ Score / RSQ Gun Bonsai VR |
| Fill the meter | It turns gold and beats; RSQ Glow In The Dark's map glow beats red while it waits. A fight's own monsters never fill it, and nothing fills it during a fight, the 20 s after one, or after this map's Boss | |
| Leave a full meter alone | The Boss comes by itself 60 s after the meter filled; while little is happening to you (the director's intensity under 0.15) each tic counts twice. It comes when the rules allow; until then one line under the meter says why: No Boss: Too Early, Map Limit, Cooldown, Low Health, Near Exit, Too Busy, No Room, or Boss: Get Ready | Arrives By Itself (default 60 s); Director: On (default) |
| Check your pulse: the inside of the off-hand wrist under 60 degrees off facing your eyes, the wrist within 50 degrees of where your head points (kept to 75 and 65) | The Start Fight card shows on the inside of that wrist: grey; gold (START FIGHT?) when the meter is full, nothing is called and Call It In is on; BIG BOSS! when a Big Boss is due. It stays 2 s after (or Gun Cards' Stays After when longer). Not while the off hand steadies the gun | Wrist Card: On (default) |
| Press Use while the gold card shows | The fight is called in, with a chime, past every wait (time, map limit, cooldown, health, exit, busy, the director); only No Monsters and No Room still stop it. This is the only call: the watch check and Use call nothing | Call It In and Wrist Card: On (default) |
| Watch your sides and back when the fight comes | 3 s of slow motion and dark. Each thrall's spot is marked by its crosshair 0.75 s before it lands, at your sides and behind, 400 to 700 units out, 0.5 to 1 s apart; each fights the moment it lands. The Boss lands in front last, 1.25x size, and cannot be hurt for 1.5 s | Arrival: Around You (default); slow motion RSQ SlowMo, dark RSQ Glow In The Dark |
| Kill the thralls | While thralls live the Boss takes 20% of each blow (every thrall up) to 100% (none left), and its ring of fire burns. Each thrall's death takes away the Champion power it gave the Boss | Thralls (default 3, up to 3 more by world tier) |
| Shoot the Boss | It has 3 lives (X3 on its bar). Each life lasts about 20 s of your own recent damage (never under its own health). A life lost: it refills, cannot be hurt for 5 s (GUARD on its bar), throws 6 ammo bits at its feet, and steps up: its bar's colour one up, 15% faster, one fresh thrall (it drops no gun, as every thrall) | Lives (default 3); Boss Life by Time: On (default); Boss Steps Up: On (default); the ammo bits: RSQ VisualRewards with Kill Rewards on |
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
| Pull that hand's trigger | Bought if your gold covers it (Common 150, Uncommon 250, Rare 500, Epic 900): BD22 VR makes the real legendary and hands it over. One weapon a kiosk: once one is bought the other offers grey out, and a trigger on one is refused with a buzz and ONE WEAPON PER KIOSK | Kiosk prices (defaults as shown) |
| Press that hand's alt fire on an offer, or trigger LUCKY then trigger an offer | LUCKY: one Score life spent (no Rank lost), the offer one rarity up. Once a kiosk, and not after a weapon is bought there. A Boss kiosk's offers stop at Rare: its card offers LUCKY only under Rare (elsewhere under Epic) | a Score life |
| Point at REPAIR and pull the trigger | Every gun you carry back to full condition, 1 gold a missing point (at least 10) | RSQ Gun Cards' Weapon Condition |
| Walk 0.75 m past the kiosk's range | It folds away. It stays where it is until the map ends | |
| Fill the Big Boss bar (+25% a Boss fight, won or lost) | A Big Boss is due: it is called like a Boss (Use on the card, which reads BIG BOSS!) or comes by itself; never held by the map limit | Big Boss: On (default) |
| Fight a Big Boss | Its arrival card shows its weak points and HP; it lands alone, each life worth about 60 s of your damage. 3 weak points (60 health); each one broken throws 10 health and 10 armour bits, a CRITICAL! 40 and 25; CRITICAL! is x3 for 4 s | Big Boss: On (default); RSQ Monsters for an EX Big Boss |
| Kill a Big Boss's summons while it shows GUARD | After its window it takes no damage while its own summons live (lines of light join them to it), 20 s at most | Big Boss Guard: On (default) |
| Beat a Big Boss | As a Boss win, and its kiosk has five Epic offers, no LUCKY | |
| Get a REVENGE or a REVIVE | Your damage x1.5 for 10 s; DAMAGE UP | RSQ SlowMo's DOWN |
| Deal any damage | Your damage is +10% for each world tier colour above Common (x1.9 at Red) | Your Damage a Colour (default 0.1); RSQ Monsters |
| Kill, fight on unhurt; or take heavy damage, go DOWN, lose a Score life, die | Rank (0 to 100) moves (a lost Score life: Rank Down per Life, 8, once); every 8 points is the next world tier colour, inside a window the map sets (Common on the first map up to Red on the second-to-last). RANK nn under the meter | Rank Difficulty and Rank Ceiling: On (default); RSQ Monsters |
| Hit a melee strike on a knocked-down or dazed monster outside a Boss fight | VR Finisher: it is gibbed, BD22's two fatality bonus items drop, 100 Score points, a 1 s slow. Not over 1000 spawn health, not a boss | VR Finisher: On (default); BD22 (knocked down) or Gun Bonsai VR (dazed) |
| Do a BD22 fatality, stealth kill or execution | No scene: the monster's body is gibbed where it stood and the finisher is paid | No BD22 Fatalities: On (default); Brutal Doom 22 |
| Bring a legendary monster (3x health) under half its health | It transforms: full health again, a stat boost and x2 damage; killed, it drops loot by its health | LegenDoom Lite (stands down while LegenDoom is loaded) |
| Kill a Champion | Champions' colour powers and its item bundle (about half the monsters at Ultra-Violence: Champion Chance, Difficulty Based) | Champions (built in) |
| Call a fight with Arrival: Classic | Every thrall lands in front, then the Boss; all are held and cannot be hurt until a 5 s count ends | Arrival: Classic (default Around You) |
| Press Use on the Start Fight card | Nothing: the card stays grey and the fight only comes by itself | Call It In: Off (default On) |
| Call a fight that would wait | It comes anyway (only the map limit and cooldown still hold it); with no room, the spot is taken anywhere it fits | Ignore Spawn Restrictions: On (default Off) |
| Call a fight with Graves Rise on | RSQ Graveyards' tombstones raise Legion of Bones undead as it lands (one a stone, or one per thrall a stone; the map or a radius) | Graves Rise: On (default Off); Legion of Bones and RSQ Graveyards |
| Play with Rank Difficulty off | The world tier stays where RSQ Monsters' page sets it; Boss wins and losses still step it | Rank Difficulty: Off (default On) |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Boss

| Option | Default | What it does |
|---|---|---|
| Bosses | On | Boss fights: the meter fills and a Boss with its thralls arrives. |
| Call It In | On | Use on the gold Start Fight card calls a full meter's Boss in; the watch check does not (off: it only comes by itself). |
| Wrist Card | On | A card inside the off-hand wrist, gold when the fight can be called; Use on it calls the fight in (with Call It In on). |
| Boss Effects | Light | Light draws fewer of the repeated effect pieces (same art); Full draws every one. |
| **Fight** | | |
| Thralls | 3 (1 to 8) | Thralls that come with each Boss. |
| Lives | 3 (1 to 9) | A Boss's lives in all (3: it dies on the third). |
| Arrival | Around You | Around You lands the thralls at your sides and behind; Classic lands all in front after a charge. |
| Rank Difficulty | On | Rank (0-100) rises with good play and falls when you struggle and sets the difficulty; off, the Monster Tier stays where you set it. |
| Rank Ceiling | On | The map sets how high Rank can go: Common on the first map up to Red on the second-to-last; your play moves it in the three colours under. |
| Your Damage a Colour | 0.1 (0 to 0.3) | Your damage goes up this much for each colour the monsters are above Common. |
| Comeback Damage | 1.5 (1 to 3) | A REVENGE or a REVIVE multiplies your damage by this for a few seconds. |
| Comeback Seconds | 10 (0 to 30) | How long the comeback damage lasts, in seconds (0: none). |
| Telegraphed Attack | On | Every so often a Boss winds up a big attack with weak points; break them all in time for BREAK!. |
| Melee Finishers | On | A melee strike on a staggered thrall or a Boss in BREAK! finishes it for health, armour and Score. |
| **Boss Traits** | | |
| Boss Traits | On | Each Boss (not a Big Boss) comes with one trait, named under its bar. |
| Summoner | On | It casts and green rings mark where its fodder lands; hurt it during the cast and fewer land. |
| Charger | On | Two stamps and a line on the floor, then it rushes along the line; sidestep it and it is stunned. |
| Shielded | On | A shell blocks hits from the front; hit it from behind or break the points on the shell's rim. |
| Splitter | On | Each life it loses, it splits into two smaller halves; both must die. |
| **Big Boss** | | |
| Big Boss | On | A bar that fills a quarter for every Boss you beat; full, a Big Boss comes. |
| Boss Kiosk | On | A Boss won drops a kiosk of legendary weapons to buy with gold. |
| LegenDoom Lite | (page) | Legendary monsters for players without LegenDoom. Stands down by itself while LegenDoom is loaded. |
| Test and Debug | (page) | The meter, arrival, fight, rank, big attack, finisher, Big Boss, kiosk and Champions numbers, and the logs. |
| Reset All | (button) | Puts every RSQ Boss setting back to its default. |

<details><summary>RSQ Boss: Test And Debug (194 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Boss Meter** | | |
| Meter Speed | 1 (0.25 to 4) | Multiplies everything that fills the Boss meter. |
| Meter Fills From | Both | What fills the meter besides kills, chains and time: Score style, Gun Bonsai XP, or both. |
| Score Style Fill | 0.25 (0 to 2) | Meter points for each Score style point. |
| Gun Bonsai XP Fill | 0.2 (0 to 2) | Meter points for each Gun Bonsai XP point. |
| Show Meter | On | The Boss meter on the HUD. |
| Meter Size | 1.5 (0.5 to 2.5) | The Boss meter's size. |
| Effects | On | The original art: thrall links and markers, the fire ring and the bursts. |
| **When It Comes** | | |
| Arrives By Itself (s) | 60 (0 to 300) | Seconds after the meter fills that the Boss comes by itself (0: only when called). |
| Map Start Wait (s) | 60 (0 to 300) | Never in a map's first this many seconds. |
| Cooldown (s) | 90 (0 to 600) | Seconds after one Boss began before the next may come. |
| Per Map Cap | 1 (1 to 10) | The most Bosses a map. |
| Wait Under Health | 40 (0 to 100) | The Boss waits while your health is under this. |
| Wait Over Monsters | 3 (0 to 20) | The Boss waits while more awake monsters than this are after you. |
| Ignore Spawn Restrictions | Off | A due Boss comes regardless of the map start, low health, the exit, busy fights and room. |
| Nearest Arrival | 384 (128 to 2048) | The arrival spot is at least this far from you (map units). |
| Farthest Arrival | 1024 (256 to 4096) | The arrival spot is at most this far from you (map units). |
| Exit Distance | 768 (0 to 2048) | The Boss waits while you are within this of an exit line. |
| **Landing** | | |
| Landing Slow Motion (s) | 4 (0 to 5) | Seconds of slow motion for a Classic landing (0: none). |
| Landing At Slowest | On | The landing's slow motion runs at the slowest speed, not Slow Depth. |
| Landing In The Dark | On | The world goes dark through the landing. |
| Slow Depth | -1 (0 to 90) | World speed of the landing's slow motion when Landing At Slowest is off. |
| Boss Music | On | The Boss track plays over the fight. |
| **Arrival Around You** | | |
| Stage Turn (s) | 3 (0 to 5) | Seconds of the stage turn (the landing's slow motion and dark). |
| Thrall Ring Nearest | 400 (128 to 1536) | The thralls' ring round you, nearest (map units). |
| Thrall Ring Farthest | 700 (192 to 2048) | The thralls' ring round you, farthest (map units). |
| Clear in Front (deg) | 60 (0 to 150) | No thrall lands within this many degrees either side of where you face. |
| Thrall Gap Least (s) | 0.5 (0.1 to 3) | Seconds between one thrall's landing and the next, at least. |
| Thrall Gap Most (s) | 1 (0.1 to 3) | Seconds between one thrall's landing and the next, at most. |
| Spot Mark (s) | 0.75 (0.25 to 2) | Seconds a thrall's landing spot is marked before it lands. |
| Landing Invulnerable (s) | 1.5 (0 to 5) | Seconds the Boss stays invulnerable and still once it has landed. |
| **Fight** | | |
| Camping Pressure | On | Staying put too long in a fight sends the nearest thrall straight at you. |
| Camping After (s) | 8 (2 to 60) | Seconds within the radius that count as camping. |
| Camping Radius | 128 (32 to 1024) | How far you may move and still be camping (map units). |
| Graves Rise | Off | With Legion of Bones and RSQ Graveyards, a Boss calling in wakes the tombstones. |
| Graves Rise Mode | Single Map | One risen per stone or the thrall count per stone, over the map or within the radius. |
| Graves Radius | 1024 | Graves Rise's radius (map units). |
| Legendary Thralls | On | With LegenDoom, every thrall is made legendary. |
| Inherit Powers | On | The Boss inherits its thralls' powers. |
| Power Cap | 5 (0 to 12) | The most distinct powers a Boss inherits. |
| Invulnerable (s) | 5 (0 to 15) | Seconds a Boss is invulnerable after it loses a life. |
| Score Awards | On | Boss fights send their awards to RSQ Score. |
| Boss Life by Time | On | A Boss's life lasts about Boss Life seconds of your own damage. |
| Boss Life (s) | 20 (5 to 120) | Seconds of your own damage each Boss life is worth. |
| Thrall Health (x) | 1.5 (0.5 to 5) | Thralls' health multiplier at Rank 0. |
| Top Thrall Health (x) | 2 (0.5 to 8) | Thralls' health multiplier at Rank 100. |
| Boss Steps Up | On | A Boss steps up each life: a colour up, faster, fresh thralls. |
| Each Life Faster By | 0.15 (0 to 1) | The share of speed a Boss gains each life. |
| Fresh Thralls Each Life | 1 (0 to 6) | Fresh thralls a Boss brings each life. |
| **Rank and Director** | | |
| Show Rank | On | "RANK nn" in its colour under the Boss meter. |
| Rank Speed | 1 (0 to 4) | How fast play moves Rank. |
| Rank | -1 (-1 to 100) | The Rank itself (-1: starts from the Monster Tier). |
| Starting Rank | 0 (0 to 100) | The Rank a new game starts at. |
| Rank Up per Life | 4 (0 to 24) | Rank gained for a Score life earned. |
| Rank Down per Life | 8 (0 to 24) | Rank lost for a Score life lost. |
| Director | On | The director holds a called fight while it is hot, brings it sooner when you coast, and gives a relax after. |
| Director Hold (s) | 6 (0 to 30) | The most seconds the director holds a fight. |
| Relax After (s) | 20 (0 to 120) | Seconds of relax after a fight: no meter fill, monsters fire less from range. |
| **Big Attack** | | |
| Red Room | On | The room glows red, with a red light on the Boss, while it winds up. |
| Boss Big Attack | By Kind | Which big attack a Boss uses: by its kind, or one for all. |
| Break Staggers Thralls | On | BREAK! staggers the Boss's living thralls too, so they can be finished. |
| Windup Low Rank (s) | 20 (3 to 60) | Seconds between wind-ups at the lowest Rank. |
| Windup Top Rank (s) | 10 (3 to 60) | Seconds between wind-ups at the top Rank. |
| Windup Length (s) | 3 (1 to 8) | Seconds to break every weak point. |
| Each Act Sooner | 0.15 (0 to 0.5) | Each later life winds up this much sooner. |
| Each Act Harder | 0.25 (0 to 2) | Each later life's attack is this much harder. |
| Big Attack Damage | 15 (1 to 100) | One hit of a big attack at the lowest tier. |
| Damage per Tier | 0.06 (0 to 0.5) | The big attack's extra damage for each tier up. |
| Big Boss Attack (x) | 1.5 (0.5 to 5) | A Big Boss's big attack multiplier. |
| Weak Point Health | 40 (10 to 2000) | A Boss's weak point's health. |
| Big Boss Point Health | 60 (10 to 2000) | A Big Boss's weak point's health. |
| Break Length (s) | 3 (0.5 to 10) | Seconds a Boss staggers in BREAK!. |
| Break Damage (x) | 2 (1 to 10) | The damage multiplier a Boss takes in BREAK!. |
| Big Boss Break (s) | 4 (0.5 to 10) | Seconds a Big Boss staggers in BREAK!. |
| Big Boss Break (x) | 3 (1 to 10) | The damage multiplier a Big Boss takes in BREAK!. |
| Point Drop Health | 10 (0 to 100) | Health dropped for each weak point broken in a fight with no thralls. |
| Point Drop Armour | 10 (0 to 100) | Armour dropped for each weak point broken in a fight with no thralls. |
| Break Drop Health | 40 (0 to 200) | Health dropped for a full BREAK! in a fight with no thralls. |
| Break Drop Armour | 25 (0 to 200) | Armour dropped for a full BREAK! in a fight with no thralls. |
| **Boss Traits** | | |
| Summon Every (s) | 15 (3 to 60) | Seconds between a Summoner's casts. |
| Summon Cast (s) | 1.5 (1 to 5) | Seconds the rings show before the fodder lands. |
| Summon Least | 2 (1 to 8) | Fodder a cast, at least. |
| Summon Most | 3 (1 to 8) | Fodder a cast, at most. |
| Fodder Cap | 6 (0 to 24) | The most of a Summoner's fodder alive at once. |
| Cast Cut (%) | 10 (1 to 50) | Percent of its life's health dealt during a cast that takes one ring away. |
| Charge Every (s) | 10 (3 to 60) | Seconds between a Charger's charges. |
| Charge Windup (s) | 1.2 (1 to 4) | Seconds of the charge's wind-up. |
| Charge Speed | 26 (8 to 64) | The rush's speed (map units a tic). |
| Charge Damage | 20 (0 to 100) | A charge hit's damage at the lowest tier. |
| Charge Knockback | 20 (0 to 60) | How far a charge hit knocks you back. |
| Charge Stun (s) | 2 (0.5 to 10) | Seconds a Charger is stunned after a miss. |
| Stun Damage (x) | 1.5 (1 to 5) | The damage a stunned Charger takes (x). |
| Charge Sooner (x) | 0.5 (0.1 to 1) | After a hit, the next charge's wait (x). |
| Shell Arc (deg) | 90 (30 to 180) | Degrees either side of a Shielded Boss's facing that its shell blocks. |
| Shell Points | 3 (1 to 6) | Points on the shell's rim. |
| Shell Point Health | 120 (10 to 1000) | Each shell point's health. |
| Split Size (x) | 0.7 (0.3 to 1) | Each split's size (x). |
| Split Damage (x) | 0.75 (0.1 to 1) | A half's damage (x). |
| Split Warning (%) | 15 (1 to 60) | SPLITTING! shows when this percent of its life is left (or a second of your damage). |
| **Finishers** | | |
| Fists and Kicks | On | Punches, kicks and the headlock combo can finish. |
| Saber | On | The saber can finish. |
| ShieldSaw | On | The ShieldSaw (the grind, the disc) can finish. |
| Whip | On | The whip can finish. |
| BD22 Blades | On | BD22's axe, chainsaw and sword can finish. |
| Finished Thrall Dies | On | A finished thrall dies. |
| VR Finisher | On | A melee strike on any staggered monster finishes it, anywhere. |
| No BD22 Fatalities | On | BD22's fatality, stealth kill and execution scenes never start (the body is gibbed instead). |
| Finisher Most Health | 1000 (100 to 10000) | Monsters over this spawn health are not finished. |
| VR Finisher Score | 100 (0 to 2000) | Score points for each VR finisher. |
| Finisher Slow (s) | 1 (0 to 5) | Seconds of slow motion for every finisher (0: none). |
| Boss Finisher Slow (s) | 2 (0 to 5) | Seconds of slow motion for a Boss finished in BREAK!. |
| Finisher Health | 25 (0 to 200) | Health a finisher gives (a Boss's twice). |
| Finisher Armour | 15 (0 to 200) | Armour a finisher gives (a Boss's twice). |
| Finisher Score | 250 (0 to 5000) | Score points a finisher gives (a Boss's twice). |
| Blade Reach (m) | 2.5 (0.5 to 10) | A blade blow counts within this many metres past the target's edge. |
| Stagger Under (%) | 25 (0 to 90) | A thrall staggers once when a blow takes it under this percent of its health (0: never). |
| Stagger Length (s) | 2 (0 to 10) | Seconds a thrall's stagger lasts. |
| **Big Boss** | | |
| Big Boss Life (s) | 60 (30 to 180) | Seconds of your own recent damage each Big Boss life is worth. |
| Big Boss Act Change (s) | 2 (0 to 10) | Seconds a Big Boss is invulnerable after it loses a life. |
| Damage Measured Over (s) | 180 (30 to 900) | Your damage per second is measured over this many seconds of fighting. |
| Judge After (s) | 10 (1 to 120) | Under this many seconds measured, a life is the monster's spawn health. |
| Big Boss Summons | On | A Big Boss summons its own as it winds up. |
| Summon Count | 2 (0 to 12) | How many it summons (one more each later life). |
| Most Summons Alive | 6 (0 to 24) | Never more than this many of its summons alive. |
| Big Boss Guard | On | After EXPOSED! a Big Boss raises a guard shield while its summons attack. |
| Guard Most (s) | 20 (3 to 120) | The guard drops after this many seconds at the latest. |
| Black Knight Bodies | On | The Black Knight's lives are his bodies; each Big Boss life its own phase. |
| Big Boss Arrival Card | On | The Big Boss arrival card before it drops in. |
| Arrival Card (s) | 3.3 (1 to 8) | How long the arrival card shows. |
| Supersmith Pentagrams | On | The Obsidian Tyrant's third life plants pentagrams to heal. |
| Pentagram Every (s) | 15 (4 to 120) | One pentagram every this many seconds between wind-ups. |
| Pentagram Health | 400 (50 to 3000) | Each pentagram's health. |
| Critical Target (s) | 3 (1 to 10) | CRITICAL TARGET!'s countdown in seconds. |
| Pentagram Heal (%) | 4 (0 to 20) | Percent of its life it heals a second standing on a pentagram. |
| Supersmith Speed (x) | 1.35 (1 to 3) | How much faster SUPERSMITH+ is until its next EXPOSED!. |
| Fill Big Boss Bar | (button) | Fills the Big Boss bar a quarter, as a Boss won (test). |
| Empty Big Boss Bar | (button) | Empties the Big Boss bar (test). |
| **Boss Kiosk** | | |
| Kiosk Range (m) | 3 (1 to 6) | Metres from the kiosk that it opens within. |
| Kiosk Wait (s) | 2 (0.5 to 5) | Seconds you stand still before it opens. |
| Common Price (Gold) | 150 (0 to 2000) | The gold a Common offer costs. |
| Uncommon Price (Gold) | 250 (0 to 3000) | The gold an Uncommon offer costs. |
| Rare Price (Gold) | 500 (0 to 5000) | The gold a Rare offer costs. |
| Epic Price (Gold) | 900 (0 to 8000) | The gold an Epic offer costs. |
| Repair Gold per Point | 1 (0 to 10) | Repair: gold for each missing condition point over every gun you carry. |
| Repair Minimum (Gold) | 10 (0 to 200) | Repair: the least a repair costs. |
| **Counts as Boss** | | |
| Boss Kill Rewards | On | Kill Rewards treat it as a boss: the boss fountain, and it always drops. |
| Legendary Boss Health | On | Made legendary, it gets the higher of LegenDoom's boss and normal legendary health. |
| No Yank | On | The grapple's and whip's yank and throw refuse it. |
| No Headlock | On | The melee headlock refuses it. |
| No Morph | Off | It can't be morphed. |
| Mapwide Roar | Off | Its sight and death sounds at full volume across the map. |
| **Champions** | | |
| Champion Chance | -1 (-1 to 256) | The chance a monster is a Champion (changes take effect on the next map). |
| Mutation Chance | 16 (0 to 256) | The chance a Champion gets a mutation. |
| Item Bundles | On | Champions drop item bundles. |
| Health Bonus Style | true | Champions' health bonuses as Doom's or as food items. |
| Champion Colours | On | Champions are coloured by their kind. |
| Champion Particles | On | Champions give off particles. |
| Flat Creep Sprites | On | Champions' creep is drawn as flat sprites. |
| Champion Icons | On | An icon over each Champion. |
| Icon Size | 0.2 (0 to 1) | The Champion icon's size. |
| Icon Alpha | 0.75 (0 to 1) | The Champion icon's opacity. |
| New Ice Colour | On | A new ice colour (experimental). |
| Friendly Champions | Off | Friendly monsters can be Champions (experimental). |
| Projectile Glow | Off | Champions' projectiles glow in their colour (experimental). |
| Projectile Creep | Off | Champions' projectiles spawn creep (experimental). |
| Force Champion Type | off | Forces every Champion to one type (debug). |
| LegenDoom Champions | Off | Champions work with LegenDoom's legendaries. |
| Boosted Legendaries | On | Transformed legendary Champions get boosted abilities. |
| Dormant Legendaries | Off | Legendary monsters become Champions after transforming. |
| Colourblind Icons | Off | Colourblind icons for Colourful Hell beside the Champion icons. |
| **Champion Weights** | | |
| Reset Weights | (button) | Puts every Champion weight back to its default. |
| Dark Red | 10 (0 to 10) | Dark Red: respawns if its corpse is not disposed of. |
| Red | 10 (0 to 10) | Red: spawns with double health. |
| Orange | 10 (0 to 10) | Orange: explodes on death. |
| Yellow | 10 (0 to 10) | Yellow: moves twice as fast. |
| Dark Green | 10 (0 to 10) | Dark Green: leaves a trail of damaging creep. |
| Green | 10 (0 to 10) | Green: teleports around the map. |
| Cyan | 10 (0 to 10) | Cyan: pushes you around with gusts of wind. |
| Blue | 10 (0 to 10) | Blue: splits into projectiles on death. |
| Indigo | 10 (0 to 10) | Indigo: spawns two clones on death. |
| Violet | 10 (0 to 10) | Violet: fires extra projectiles at random. |
| Pink | 10 (0 to 10) | Pink: resurrects enemies at the cost of its own life. |
| Black | 10 (0 to 10) | Black: deals double damage. |
| Grey | 10 (0 to 10) | Grey: dodges your attacks. |
| White | 10 (0 to 10) | White: leaves a trail of slowing creep. |
| Bronze | 3 (0 to 10) | Bronze: slower, stronger and less hurt by pain. |
| Silver | 2 (0 to 10) | Silver: pulls you in with a magnetic field. |
| Gold | 1 (0 to 10) | Gold: a Midas touch on nearby enemies. |
| **Mutation Weights** | | |
| Titan | 2 (0 to 10) | Titan: massively boosted stats. |
| Undying | 1 (0 to 10) | Undying: never dies. |
| Ghost | 6 (0 to 10) | Ghost: phases in and out of reality. |
| Airborne | 8 (0 to 10) | Airborne: floats at will. |
| Hybrid | 7 (0 to 10) | Hybrid: has a second Champion effect. |
| **Logs** | | |
| Kiosk Log | Off | Console lines for the kiosk: drops, purchases, refusals and the gold earned. |
| Debug Log | Off | Console lines for every rule as it fires. |

</details>

<details><summary>RSQ Boss: Legendoom Lite (27 rows)</summary>

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

</details>

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
| RSQ VisualRewards | Arrival beams, words over monsters (WEAK!, CRITICAL!, BOSS DEFEATED!, trait words), pops, toasts, the BOSS INCOMING / WIN / LOSS banners, the Boss music scene, and 6 ammo bits each time a Boss loses a life ("burst.ammo"). It asks "bossfor rewards", "wasboss", "bigboss", "bossfight", "tier", "miniboss", "thrall", "boss", "bigname", "meter.*" |
| RSQ Glow In The Dark | The map glow beats red while the meter waits, goes dark for the landing, grey while thralls stand, red in a wind-up, a wave at the Boss's death. It asks "miniboss", "boss", "colour" |
| RSQ Monsters | The world tier (rsq_mon_worldtier) sets fight colours and is stepped by wins, losses and Rank; Boss and thrall types from its ColorfulHell roster; EX monsters are the Big Bosses (each with its own kit, its act given as RSQMB_ActPhase); tier changes are held back during a fight |
| RSQ Gun Cards | Its wrist reader answers the pulse check ("pulse"); its Stays After and Watch Card: Always are read for the card (Always shows it whenever its face is turned to you and you look its way); REPAIR uses its Weapon Condition ("cnd.on", "cnd.worn", "cnd.fix"). It asks "fightcard.up" |
| BD22 VR Reloaded | The kiosk's offers and purchases (RSLD_KioskService); the Boss's own legendary drop is taken by the kiosk ("kiosk.take"). Its fatality, execution and stealth-kill tokens are taken (No BD22 Fatalities); its knock-down counts as staggered |
| LegenDoom | Thralls and the Boss are made legendary (Legendary Thralls); the Boss gets the higher of LegenDoom's boss and normal legendary health; LegenDoom Lite stands down |
| RSQ Tactical Rig | Asks "callin" (its watch-check gun move leaves Use alone while it is 1; always 0 now: the watch check calls no fight) and "wasboss" |
| RSQ Melee, RSQ Grapple | Ask "bossfor" ("headlock", "yank"), and Grapple "shielded" and "invulnerable": a Boss refuses the headlock and the yank (No Headlock, No Yank). Their melee damage types count for finishers |
| RSQ ShieldSaw | Asks "bossfor" "ldhealth" (a Boss's legendary health). Its grind and disc count for finishers |
| RSQ Saber, RSQ Whip | Their damage types count for finishers |
| RSQ Graveyards with Legion of Bones | Graves Rise ("bones.graves"); its stones beat with the waiting meter ("stones.pulse") |
| RSQ Accessibility (being removed) | Photosensitive Mode calms the flashes; Text Size places the meter without Score; colour-blind letters on trait words; Rumble Backup on a CHARGER!'s stamps; its Wrist Turn says which side of the wrist is the watch. Without it every one of these is off and the watch is the back of the wrist |
| Services this mod answers | RSQMB_Service: miniboss, thrall, wasboss, lives, invulnerable, shield, living, legendary, colour, bossfight, tier, bigboss, ex, ex.ready, rank, director, director.relax, bossfights, fightcard.up, meter, meter.ready, bossfor (rewards, yank, headlock, ldhealth), rank.life; ui: meter.bottom, meter.x, meter.w, meter.h; objects: boss, thrall, fight.target; strings: powers, bigname; always 0: enraged, greed, window, segments, shielded, callin. RSQMB_GCopyService: reader, inspect, inspect.tics, inspect.any, pulse, pose.why |

## Limits

- There is no key of its own: every call is Use on the Start Fight card (with Call It In on), or the timer. The watch check and Use call nothing.
- Use is not taken from the engine: the press that calls a fight also does whatever Use does where you stand.
- With the meter full, any Use press while the gold card shows, or within 2 s of a pulse check (the card lingers), calls the fight, even one meant for a door.
- The card needs VR hand poses; out of VR a fight only comes by itself.
- One Boss a map (Per Map Cap 1); after it the meter fills no more on that map and the Big Boss bar shows in its place.
- The kiosk needs BD22 VR Reloaded's kiosk service (it needs LegenDoom) and RSQ Score; without them a won Boss drops its legendary as before. Offers are only for guns you carry; with none, there is no kiosk. One weapon a kiosk (REPAIR is not limited).
- Nothing in a fight changes colour or body: RSQ Monsters' tier changes are turned back while it is on, and Rank waits to write the world tier until it ends.
- A thrall drops no gun.
- The Boss never gets the engine's BOSS flag; it counts as a boss only for the rows under Counts as Boss.
- A Big Boss comes alone; without RSQ Monsters it is the map's strongest monster type.
- Without RSQ VisualRewards there are no beams (Doom's teleport fog instead), the big words are printed on screen, and a Boss's lost life throws no ammo bits.

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
Written from the code at commit a283738bb, 2026-11-27; updated the same day for the owner's answers (F1 to F4, one weapon a kiosk, the ammo burst when a Boss loses a life).
