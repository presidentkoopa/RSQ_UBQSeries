# Score (RSQ Score)

**The one thing:** every move in the series is a word in one language, so a kill made with the whip, the shove
and the shotgun in slow motion is one named combo that pays.

An arcade score for Doom. Every kill pays the monster's health in points; bonuses add to that for how you got
the kill, and a chain of different tools on one monster pays as a combo, named or not. The score and its bar sit
at the top right with the bonuses listing under it as they land; each map has a target, and every time you cross
it you get a reward (by default an extra life). For stock QuestZDoom 17.3, in VR. Needs no other mod: it works
on plain Doom 2 and on Brutal Doom, and no monster class is named. The series' own rows (saber, shield, hook,
whip, fists, grenade, grab, rig, slow motion, miniboss) fire only when their mod is loaded. Built on the owner's
RS_Score, which is built on ijon's Dakka scoring.

## Features

**What pays.**
- A kill pays the monster's spawn health as base points. Only real kills count: Brutal Doom's gore helpers and
  Champions' clones pay nothing.
- Bonuses are multipliers of that base, added together and applied once. On one kill they add at most three
  times its base (Kill Bonus Cap).
- Bonuses sit in five families, each its own colour in the list: **Efficiency** (Spree, Untouchable,
  Infighter), **Style** (Switcharoo, Air, Curveball, Coach Gun, Darwin, Telefragged, and the VR and thrown
  rows: No-Look, Off-hand, Two Guns, Thrown, Powder Keg, Stretched Second...), **Daring** (Brawler, Redline,
  Swan Song, Point-Blank, Blind-fire, Quick Draw, Hot Swap, Swinging, Dismount, Indiana Jones, and the
  Champions, LegenDoom and Miniboss rows), **Melee** (the series' hands and blades: Fatality, Cleaved, Hurled,
  Boomerang, Shield Work, Choked, Lashed, Reeled In, Weapon Master, Multi-Kill...), and **Counterplay**
  (defence turned into a kill: Riposte, Perfect Riposte, Return to Sender, Poetic Justice, Rally, Shield Wall,
  Hold the Line, Back Off, Misdirection, Eyes in the Back).
- Every row, what triggers it and what it pays: `ideas/NAMING_SHEET.csv` (its "status 11-03" column says
  which are built). Names are proposals until the owner renames them.

**Combos and chains.**
- Every monster remembers the tools that touched it, in order. A kill pays for the chain that led to it.
- Order matters. The chain breaks after 3 seconds between moves. Guns count as a tool.
- Every move in the series has one name (the gun, the shotgun, a saber cut, a Force grip, the shield's disc, a
  whip yank, the hook's zip, a thrown thing, a stun grenade, a holster draw, a lean...). A named combo is a
  pattern of those moves, from a data table: Lion Tamer (whip, then shield bash), Clay Pigeon (Force push,
  then gun), F.E.A.R. Effect (the owner's: a gun-butt shove, then a shotgun kill in the slow beat that follows; every shotgun hit in that beat bleeds twice, and the kill pays the combo), and well over two
  hundred more. One named row per kill, the best-paying match.
- An unnamed chain still pays: 2, 3, 4, 5 or 6 actions pay 0.2, 0.45, 0.75, 1.0 or 1.2 of the base; a chain
  that mixes more than two mods pays a little more; the whole chain inside 2 seconds pays x1.25.
- A pattern step can ask how it landed (in your own slow motion, in the air, point-blank, a headshot) and what
  it landed on (a champion, a legendary, a thrall, the miniboss).

**Slow motion.**
- Stretched Second: a kill while RSQ SlowMo has the world slowed pays half of its style, daring and melee
  bonuses again (Slow Motion Style). A slow motion you started yourself pays the full share; an automatic one
  (the miniboss window, a Gun Bonsai VR pulse) half; Score's own pulses nothing. A plain kill in slow motion
  pays nothing more. At 10 % speed or slower the share is x1.5.
- Big moments (Fatality, Perfect Riposte, Swan Song, a three-step named combo, five actions in one chain, four
  mods in one chain, and more) ask RSQ SlowMo for about a second of slow motion. At most one every 6 seconds.
- Hit-Stop on Big Kills (option): a big kill stops the world for a beat before the slow motion follows.

**The target and the reward.**
- Each map gets a target from a census of its monsters. Every time you cross a multiple of it you get a
  reward: by default an extra life. With a life in hand you are caught at 1 HP instead of dying, with a sound
  and a short warm flash.
- Other reward modes: ammo regeneration (a share of whatever ammo you carry), alternating with a life, or
  nothing at all.

**The HUD.**
- The word "Score:", the number and a bar, with life pips above it and the bonuses listing under it as they
  land, each in its family's colour. Small, Standard or Large; four places.
- The Living Label: "Score:" slowly breathes and changes colour, warms toward gold before a reward and goes
  white after a big combo.
- Score on the Wrist (option, VR): the running total in small gold digits just above your off-hand controller.

## How to play

Nothing to bind: play. The score is at the top right; glance at it between fights. A few bonuses come from VR
moves:

- **No-Look:** shoot something 60 degrees or more away from where your head faces.
- **Blind-fire:** hold the gun round a corner and hit something your eyes cannot see.
- **Off-hand:** kill with the off hand's trigger alone. **Two Guns:** a kill from each hand's trigger within
  a second of each other.
- **Point-Blank:** kill from right up close. **Air:** kill while you are off the ground.
- **Chains:** mix your tools on one monster inside 3 seconds and finish it. Whip it, bash it with the shield,
  shoot it; Force-push it and shoot it in the air; shove it with the gun butt, cross your wrists for slow
  motion and finish it with the shotgun. The row under the score names what you did.
- **Counterplay:** block or parry a monster's attack with the shield or the saber, then kill it. Send a shot
  back into the one that fired it.
- **The target:** keep the bar filling. When it fills you get a life (a pip above the bar). Get killed with
  one in hand and you are caught at 1 HP.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Score**.

| Menu row | Default | What it does |
|---|---|---|
| Show Score | Yes | The score display on or off. |
| Size | Standard | Small / Standard / Large. Sets the Size number. |
| Place | Top Right | Top Right / Top Left / Top Centre / Bottom Right. Sets Across and Down. |
| Living Label | On | The word "Score:" slowly breathes and changes colour; warms toward gold before a reward. |
| Target Reward | Life Every Time | What crossing the target pays: Ammo, Then Life / Life, Then Ammo / Ammo Only / Life Every Time / Nothing. |
| New Map Keeps | Nothing | What survives a map change: Nothing / Total / Total and Rewards / Everything. |
| Slow Motion Moments | On | A big moment asks RSQ SlowMo for about a second of slow motion. Nothing without SlowMo. |
| Hit-Stop on Big Kills | Off | A big kill (a big moment, or a monster of 400 health or more) stops the world for a beat through RSQ SlowMo, then the slow motion follows. At most once a second, never while the world is already slowed. Nothing without SlowMo. |
| Score on the Wrist | Off | The running score in small gold digits just above your off-hand controller (VR only). Hidden with Show Score -> No. |
| Bar Flash | On | The score line and bar flash when points land. |
| Screen Flash | On | The whole view flashes a colour on a reward and when a life is spent. |

**Tuning and Debug** (submenu):

| Menu row | Default | What it does |
|---|---|---|
| Size | 100 | Display size, by number. |
| Across | 85 | Display place across the screen, by number. |
| Down | 10 | Display place down the screen, by number. |
| Bonus Display Time | 35 | How long a bonus row stays, in tics. |
| Raised Monster Pay | 100 | % of base paid by a monster that was not on the map at the start (raised, spawned). 100 = full. |
| Kill Bonus Cap | 300 | Bonuses on one kill add at most this % of its base (0 = no cap). |
| Melee Bonus Cap | 0 | Cap on the Melee family, % (0 = off). |
| Counterplay Bonus Cap | 0 | Cap on the Counterplay family, % (0 = off). |
| Slow Motion Cooldown | 6 | Seconds between slow-motion moments. |
| Slow Motion Style | 50 | A kill in slow motion pays this % of its style, daring and melee bonuses again (Stretched Second). |
| Reset All | | Every RSQ Score setting back to its default. |

Not on the menu (console or ini): the target's numbers (`rs_score_monstermin`, `rs_score_monstermax`,
`rs_score_monsterscalar`, `rs_score_interval`), the ammo regen share (`rs_score_regenpercent`), and the
Efficiency, Style and Daring caps (`rs_score_cap_efficiency`, `rs_score_cap_style`, `rs_score_cap_daring`).

## Works with

Score is a shared service: the series' mods name their moves to it, send it awards, and read its kills.

- **RSQ SlowMo:** a big moment slows the world for about a second; a kill while the world is slowed pays
  Stretched Second; Hit-Stop on Big Kills. Without SlowMo, nothing slows and Stretched Second never pays.
- **RSQ Melee:** the fists' rows (Shoryuken, Liver Shot, Glass Jaw, Dempsey Roll, K.O....), the Headlock
  combos, F.E.A.R. Effect.
- **RSQ Saber:** the stab, the lunge, the impale, the staff spin, the Force rows, Deflect and Remote Down from
  the training remote, Twin Blades, Pulled In.
- **RSQ ShieldSaw:** Shield Work, Hurled, Boomerang, Ground Down, Riposte, Perfect Riposte, Shield Wall, Clean
  Sweep, Bank Shot, Buzzsaw, Wall Splat.
- **RSQ Grapple:** Reeled In, Ping-Pong, Bowling, Hard Landing, Fly Ball, Swinging, Dismount, Zip Kick, and
  the Indiana Jones award for a roped crossing over a gap.
- **RSQ Whip:** Lashed, Wrecking Ball, Tarzan, Stun Lock, Snap Kill, Chain Swing.
- **RSQ Grenade:** Cooked, Airburst, Tagged, Cluster Bomb, Teeth, Trap Shot, Contact and the rest.
- **RSQ DistanceGrab:** Thrown, Powder Keg, Air Catch, Body Blow, Hand-Me-Down, Full Hands, Clubbed.
- **RSQ TacticalRig:** Quick Draw, Hot Swap, Iaido, Armory.
- **RSQ Miniboss:** Thrall Slow Kill, Miniboss and Greedy on their own rows, paid as a share of the kill's base;
  Chain Gang, Rage Quit, Riot Control, Severed.
- **Champions** and **LegenDoom Lite** (not RSQ): champion colours, mutations and legendaries pay their own
  Daring rows (a Gold Champion, a Legendary, Legend Denied, a Legendary Champion...).
- **BD22 VR's guns:** Hold Streak, Double Tap, Hand Cannon, Headshot, Direct Hit, Danger Close, Rip and Tear
  and more.
- **RSQ Accessibility:** Text Size grows the display; Photosensitive Mode holds the label still and dims the
  flashes; a colour-blind setting recolours the families and stops the label's colour cycle. Inert without it.
- **RSQ Gun Bonsai VR:** its XP Source: Style turns a kill's bonus points into weapon XP, split along the combo
  chain; its Lucky Kill reads which kills were big moments; with its ShieldSaw Gauge on, the score display
  moves down to make room. Gun Bonsai VR has no Score nodes of its own.
- **Gun Bonsai's own score-to-XP:** if you turn it on, set Gun Bonsai's damage-to-XP to 0, or every kill pays
  XP twice.

## Load order

With the other RSQ pk3s, after Brutal Doom, the monster packs, Champions, LegenDoom and Gun Bonsai. Order
among the RSQ pk3s does not matter: everything it talks to is found by name at run time.

## Known limits

- Bowling's second pin is not reachable yet: a thrown body stops at the first thing it hits.
- The combo names and pays are proposals; the owner renames them after 1.0.
- The two fonts are not licensed for distribution: this version is the owner's, not for the public hub.

## For other mods

`RS_ScoreService`, found by name (`ServiceIterator.Find("RS_ScoreService")`). Nothing links.

GetInt:
- `touch` (string: the tool id; int: the player number; object: the monster): records that move on that
  monster's chain. Send it BEFORE the blow lands: a kill is scored inside the blow.
- `award` (string: the row's label; int: the points; object: the player): a flat award on a labelled row.
  Returns the points paid.
- `combo` (string: `"<name>|<pattern>"`; int: pay in permille), from `OnRegister`: adds a named combo.
- `tool` (string: `"<id>|<groups,...>"`), from `OnRegister`: adds a tool id and the groups a pattern may name
  it by.
- `kill.serial` (int: player): the newest kill's serial. `kill.style` / `kill.base` (int: player; double:
  serial): that kill's bonus points / base points. `kill.big` (object: the body): 1 if its kill was a big
  moment.
- `score`, `progress` (permille to the next reward), `lives`, `rewards` (object: the pawn), also through
  `GetIntUI`, for a HUD that draws the score itself.

GetString: `kill.chain` (int: player; double: serial): the chain, finishing blow last (`"gun>whip>shield.bash"`).
GetObject: `kill.victim`.

Linked: a bonus is a class (`RS_ScoreBonus`: `Family`, `DisplayName`, `Evaluate`, `Commit`, `AfterOthers`,
`BigMoment`) registered from a `StaticEventHandler.OnRegister` with `RS_ScoreRegistry.RegisterBonus`;
`RS_ScoreRegistry.RegisterCombo(name, pattern, mult)` and `RegisterTool(id, groups)` do what the service's
`combo` and `tool` do. A monster-tier row subclasses `RS_ScoreTierRow`.

Score asks, each by name and only when loaded: RSQ Grapple, RSQ ShieldSaw, RSQ Saber, RSQ DistanceGrab, RSQ
TacticalRig, RSQ SlowMo, RSQ Whip, RSQ Melee, RSQ Grenade, RSQ Miniboss, RSQ Gun Bonsai VR (`RSQ_HudService`
`shield.gauge.drop`) and RSQ Accessibility. It sends RSQ SlowMo `rsm_pulse` on a big moment and a big kill.

## Credits

The scoring design, the bonus taxonomy, the reward loop, the HUD layout and its graphics are **ijon's**, from
*Dakka* (<https://github.com/0dot0repeating/dakka>), released under the WTFPL. This is a rebuild of those
rules in ZScript, not a copy of the code. What came from there:

- The bonus taxonomy: the thirteen bonuses and the three families they sit in (Efficiency, Style, Daring),
  and every number attached to them: the time windows, the thresholds, the multipliers.
- The reward loop: a per-map target score derived from a monster census, crossed repeatedly, alternating
  between ammo regeneration and an extra life.
- The HUD layout: the score line above a 120-pixel bar in a bracket, animated life pips above it, the
  breakdown stacking downward in family colours.
- The score HUD graphics: `SCOREBG1-4`, `SCOREBR1-4`, `SCOREBKT`, `HUD_LIF1-4`. ijon's own work, reused with
  credit.
- The two fonts, carried as `RSSCFON` and `RSSCFN2`. In *Dakka*'s credits the clean BIGFONT used for the score
  line is by **Blue Shadow** and the breakdown font is by **Jimmy**. They come with *Dakka*, a public
  repository, and are carried here with that credit.
- The colour definitions in `TEXTCOLO.txt`, renamed `RSScore_*` so that loading *Dakka* alongside this pack
  cannot have one definition win over the other.

Not carried across: *Dakka*'s reward sounds (People Can Fly, *Painkiller*) and its revival fire-and-explosion
actors. The extra-life mechanic is implemented; the spectacle is not.

Ours, and not ijon's: the bonus registry (bonuses as classes contributed by whichever mod owns the fact they
measure); the anti-farming rule (`rs_score_farmpercent`; *Dakka* paid full points for a resurrected monster);
the multiplier caps (`rs_score_cap_*`); generalised ammo regeneration (a percentage of whatever ammo the player
carries, so the amounts are not *Dakka*'s and cannot be); measuring gravity from the actor so the Air bonus
is right under a jump modifier, in low gravity and in water.

The Quest series version: the Brutal Doom kill rule, the Melee and Counterplay families, the physical bonuses,
the suite bonuses, the combo system, the slow-motion moments, the menu and the light revival cue are the Quest
series', built on the owner's RS_Score (presidentkoopa), which is built on ijon's design. Publishing: this
version is delivered to the owner, not to the public series hub, because the fonts above are not licensed for
distribution; sharing it is the owner's decision. `CREDITS.md` holds the same credits.
