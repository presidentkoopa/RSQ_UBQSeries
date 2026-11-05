# RSQ Miniboss

Fill the Bossfight meter with stylish kills, check your watch, and call the fight in: a miniboss and its thralls
teleport in where you can see them, and you choose how to take them apart.

Status: 0.99 — the set piece was played and confirmed working in the headset; the **Bossfight** (called-in fights,
11-05) is new and **rig only, not headset-confirmed**.

RSQ is a series of VR mods for stock QuestZDoom 17.3, built in ZScript alone with no engine changes. RSQ Miniboss is a
rebuild of Tartlman's Minibosses! with new rules, and it reads monsters by their health, never their class name, so it
works the same on Doom's monsters, Brutal Doom's and most monster packs.

## Standout feature: the Bossfight

No miniboss is picked when a level loads any more. You earn it.

- **The meter** sits under RSQ Score's bar (above RSQ SlowMo's countdown bar and Score's combo rows). It fills most from
  RSQ Score's style points (style bonuses and combos), then kill chains (kills within 3 seconds), Gun Bonsai XP, and
  slowly from time spent pushing into the map. Without RSQ Score each kill counts for more. It is kept from map to map.
- **How it looks**: coldcite's Top HP Bars block bar lying down, the same rim, well and size as RSQ SlowMo's countdown bar
  and the side gauges, with a crowned skull at its left. Red while it fills (the skull lights up from the jaw as it does),
  with a band of light running through it.
- **Full**, it tells you without words: a sting, the bar turns gold and comes alive (the band runs gold, the bar and the
  skull swell with a slow beat, a glint crosses it every few seconds), and (with RSQ Glow In The Dark) the map's glow
  beating red like a heart. With RSQ Accessibility's Photosensitive Mode: no glint, a slower, dimmer beat. If a due
  Bossfight has to wait, the reason shows small on the bar (for example NO ROOM IN VIEW).
- **Call it in**: hold the watch check (the wrist turned to your eyes) and press Use. Or wait: it comes by itself about
  a minute after the meter filled.
- **It arrives in view, at a distance**: somewhere you can see, 12 to 32 m away, with room for the whole crew, in a
  burst of the original Minibosses! teleport fog, and the world slows for the landing (with RSQ SlowMo).
- **Who comes scales with you**: the monster types already in this map, stronger ones as your Gun Bonsai level, this
  map's score and your Bossfights won climb.
- **It waits** (and says why on the bar) during a map's first minute, near the exit, while your health is low, while
  more than 3 awake monsters are after you, when there is no room in view, during the cooldown, and after 2 a map.
- **Kill its miniboss** for a guaranteed drop (a gun from this map's types that you don't have yet; under Brutal Doom,
  whose map guns are not guns until touched, one from your weapon slots no higher than one above your best; else a power-up),
  three times the boss bits from RSQ VisualRewards' Kill Rewards, Champions' own loot for the powers it inherited, and
  RSQ Score's Miniboss and Bossfight rows.

Then the set piece itself:

- While its thralls live, the miniboss shrugs off most of your damage (80% with all of them up, less for each one down).
- It has three lives, shown as orbs circling its head. Knock one off and it refills, turns invulnerable behind a ring of
  flames, and when they go out its dead thralls rise again.
- Every thrall you kill **slows time** around you (with RSQ SlowMo loaded). Kill another inside the window and the window
  stretches. Chain the whole crew in one long slow-motion sweep.
- Hit the miniboss while its thralls still stand and you arm the **greed rule**. If the slow window runs out with the
  miniboss and a thrall still alive, every monster on the map is enraged: twice as fast and far quicker to shoot, until
  the miniboss dies. Kill it while its thralls still stand, before the rage comes, and RSQ Score pays a Greedy bonus.

## Features

**Bossfight**
- Meter: Score style x 0.25 (at most 120 a kill), 4 a kill (10 + health / 50 without Score, at most 30), +6 per kill in a
  chain (at most +30), Gun Bonsai XP x 0.2 (needs RSQ Gun Bonsai VR), 2 every 2 seconds you moved. x Meter Speed. A
  Bossfight's own monsters never fill it, and it is frozen while one runs.
- The call-in reads the watch check from RSQ Accessibility (which now holds RSQ Gestures), or RSQ Gun Cards' copy of it, or this mod's own copy (so it works
  with neither loaded). Use is only read while a watch check is held.
- The spot: the map's own monster start spots in front of you and points along your view, each tested with a probe the
  size of the monster that would stand there (floor, ceiling, walls, other monsters), the miniboss's spot in your line
  of sight, at least half its thralls fitting round it.
- Tier 0 to 4: Gun Bonsai player level / 2 + this map's score / 4000 + Bossfights won / 2. Tier 0 sends a middling type
  from the map, tier 4 the strongest; thralls are weaker types; tier 3 and up brings one more thrall.
- With LegenDoom 3.0, Champions and the LDL x BD22 VR patch loaded: legendary weapons drop only from a Bossfight's monsters
  (the patch asks this mod by name). LegenDoom without Champions is unchanged.
- Classic Pick at Level Load (Test and Debug, off) brings back the old way: a miniboss chosen from the level's own
  monsters at the start.

**The fight**
- **Thrall Shield**: damage cut by up to 80%, shared out per living thrall.
- **Lives**: 3 by default. Each lost life gives 5 seconds of invulnerability plus 1 second per living thrall.
- **Revive Thralls**: dead thralls rise when that invulnerability ends.
- **Slow window**: 4 seconds per thrall kill, +3 seconds for each chained kill, up to 12 seconds.
- **Greed Enrages Monsters**: struck while thralls live, then the window ends with a thrall still up: map-wide rage until the
  miniboss dies. Everything enraged is put back exactly as it was afterwards.
- **Effects**: the original Minibosses!' art, in each set piece's own colour: a BFG ball over each thrall, plasma beads
  along its link, BFG and plasma bursts when a link breaks, life orbs circling the boss (the last one swells with its
  health), flames while it is invulnerable; red sparks over enraged monsters. The IWAD's sprites drawn by a small pooled
  set of VisualThinkers (Effects Density sets the beads, flames and the cap), only within 4000 units of you.
- Sounds are Doom's own: a BFG burst for a lost life, a fireball pop for a thrall, the Icon of Sin's roar for the rage.

**Counts as a boss** (each on its own switch; the engine's boss flag is never set)
- **Boss Kill Rewards**: RSQ VisualRewards' Kill Rewards treat it as a boss kill.
- **Can't Be Yanked**: RSQ Grapple and RSQ Whip pull you to it instead of yanking it.
- **Can't Be Headlocked**: RSQ Melee's headlock refuses it.
- **Legendary Boss Health**: made legendary here, it gets the higher of LegenDoom's (Lite 4.2 or 3.0) boss and normal legendary health (none when LegenDoom 3.0's Legendary Monsters is Disabled).
- **Map-wide Roar** (optional, off by default): its sight and death sounds carry across the map.
- **Can't Be Morphed** (optional, off by default).

**With other monster mods**
- **LegenDoom Lite or LegenDoom 3.0**: every thrall is made legendary, and a legendary thrall makes the miniboss legendary too. With LegenDoom 3.0 and the LDL x BD22 VR patch, the legendary miniboss drops a BD22 VR gun; with Champions too, only a Bossfight's monsters drop legendary guns.
- **Champions**: champion thralls are picked first, and the miniboss inherits their powers, up to 4. Yellow, White, Dark
  Green, Cyan and Titan powers pass on as they are; Dark Red and Undying add a life each (up to +2); Black adds 50% damage;
  any other colour or mutation makes it 50% tougher (up to x2).

## How To Play

1. Add the pk3 to your load order. Fight as usual: stylish kills and quick chains fill the Bossfight meter under the score.
2. When the bar turns gold and the skull lights up, find a spot you like, look out over open ground, check your watch and press Use.
3. Watch them land. The beaded lines run from each thrall into the miniboss; the orbs over its head are its lives.
4. The safe way: kill the thralls first. Each kill slows time, so line the next one up fast to chain the window. With
   the crew down, the miniboss takes full damage.
5. The greedy way: hit the miniboss early. If you cannot finish it or its crew before the slow window ends, the whole
   map comes at you at double speed.
6. When a life breaks, back off: the flames mean it cannot be hurt, and its fallen thralls are about to stand up.
7. Kill it and grab the drop.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Call a Bossfight in | Watch check + Use, with the meter full | Off with "Call It In": it then only comes by itself. |
| Find the miniboss | Look for the lines and the circling orbs | Flames: invulnerable. Last orb swelling: last life. |
| Start a slow window | Kill a thrall | Needs RSQ SlowMo for the slow motion itself. |
| Chain the window | Kill another thrall before it ends | +3 s each, up to 12 s. |
| Arm the greed rule | Hit the miniboss while a thrall lives | Clear every thrall in time to disarm it. |

## Menu

**Options → Radiant Silvergun Options → RSQ Miniboss**

| Row | Default | What it does |
|---|---|---|
| Bossfights | On | The meter fills and called-in fights come. |
| Meter Speed | 1.00 | How fast the meter fills (0.25 to 4). |
| Call It In: Watch Check + Use | On | Off: a full meter's fight only comes by itself. |
| Effects | On | Links, orbs, flames, teleport fog and sparks. Per player. |
| Effects Density | Low | Low (Quest-safe), Medium, High: beads a link, flames, and the cap on effects drawn. Per player. |
| *Fight* | | |
| Thralls | 3 | Thralls per miniboss, 1 to 8. |
| Lives | 3 | Lives in all. |
| *Rules* | | |
| Legendary Thralls (LegenDoom) | On | With LegenDoom (Lite or 3.0), every thrall is made legendary. |
| Revive Thralls | On | Dead thralls rise when its invulnerability ends. |
| Inherit Powers | On | The miniboss inherits its thralls' powers. |
| Greed Enrages Monsters | On | The greed rule. |
| Score Awards | On | Sends awards to RSQ Score. |
| *Counts as a Boss* | | |
| Boss Kill Rewards | On | Counts as a boss for Kill Rewards. |
| Legendary Boss Health | On | Higher of LegenDoom's boss and normal legendary health. |
| Can't Be Yanked | On | Grapple and Whip cannot yank it. |
| Can't Be Headlocked | On | Melee's headlock refuses it. |
| Can't Be Morphed | Off | Immune to morphing. |
| Map-wide Roar | Off | Sight and death sounds at full volume map-wide. |
| Test and Debug | | The page below. |
| Reset All | | Resets every RSQ Miniboss setting (both pages). |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| *Bossfight* | | |
| Arrives By Itself (s) | 60 | Seconds after the meter filled that it comes by itself (0: only when called). |
| Map Start Wait (s) | 60 | Never in a map's first seconds. |
| Cooldown (s) | 90 | Seconds after one began before the next may come. |
| Per Map Cap | 2 | Most Bossfights a map. |
| Wait Under Health | 40 | It waits while your health is under this. |
| Wait Over Awake Monsters | 3 | It waits while more awake monsters than this are after you. |
| Nearest Arrival | 384 | The arrival spot's least distance (map units; 32 = 1 m). |
| Farthest Arrival | 1024 | Its greatest distance. |
| Exit Distance | 768 | It waits within this of an exit. |
| Landing Slow Motion (s) | 3.0 | RSQ SlowMo for the landing (0: none). |
| Bits Multiplier | 3 | Times more Kill Rewards boss bits for a Bossfight's miniboss. |
| Score Style Fill | 0.25 | Meter points per Score style point. |
| Gun Bonsai XP Fill | 0.20 | Meter points per Gun Bonsai XP point. |
| Score Per Tier | 4000 | This map's score that raises the tier by one. |
| Show Meter | On | The meter on the HUD. Per player. |
| Meter Size | 1.5 | Its size. Per player. |
| *Classic* | | |
| Classic Pick at Level Load | Off | The old way: a miniboss chosen from the level's monsters at the start. |
| Per Map | 1 | Classic: minibosses per level, 0 to 4. |
| Map Chance | 100 | Classic: % chance a level gets any. |
| *Fight* | | |
| Thrall Range | 1024 | Classic: how far from the miniboss a thrall may stand. |
| Power Cap | 4 | Most distinct powers inherited (legendary not counted). |
| Thrall Shield | 80 | % of damage shrugged off with every thrall alive. |
| Invulnerable (s) | 5.0 | Seconds invulnerable after a lost life. |
| Per Thrall (s) | 1.0 | Extra seconds per living thrall. |
| *Slow Window* | | |
| Window (s) | 4.0 | Seconds of slow time per thrall kill. |
| Chain Bonus (s) | 3.0 | Extra seconds per chained kill. |
| Window Cap (s) | 12 | The window's longest, seconds. |
| Slow Depth | -1 | World speed % in the window; -1 uses RSQ SlowMo's own. |
| Rage Speed | 2.00 | Enraged monsters' speed multiplier. |
| Effects Range | 4000 | Effects drawn only within this distance of you. Per player. |
| Debug Log | Off | Console lines for every rule as it fires. |

## Works with

- **Alone**: the whole Bossfight works: the meter fills from kills, chains and time, the watch check is read by this mod's
  own copy, and the set piece runs in full. Without RSQ SlowMo there is no slow motion (the window still times the
  greed rule and chains).
- **RSQ Score**: its style points fill the meter most; the meter sits under its bar and its combo rows go below; Thrall
  Slow Kill, Miniboss, Greedy and Bossfight rows.
- **RSQ SlowMo**: the landing and each thrall kill slow the world; its countdown bar sits under the meter.
- **RSQ Glow In The Dark**: the heartbeat while the meter is full; the map's glow takes the miniboss's colour while it lives.
- **RSQ Gun Bonsai VR** (with Gun Bonsai): XP fills the meter; the player level raises the tier.
- **RSQ Accessibility (Gestures), RSQ Gun Cards**: their watch-check reader is used first when loaded.
- **RSQ VisualRewards**: HP bars mark the miniboss and its thralls; Kill Rewards treat it as a boss, a Bossfight's x3 more.
- **RSQ Grapple, RSQ Whip, RSQ Melee**: refuse to yank or headlock it (switches above).
- **RSQ ShieldSaw and RSQ Gun Bonsai VR**: read its true legendary health when it was made legendary here.
- **RSQ Tactical Rig**: its optional "watch check + Use moves the gun" also reads Use at the watch check; with both on, a
  call-in press also moves the gun.
- **LegenDoom Lite 4.2, LegenDoom 3.0 and Champions**: see Features. All optional and found by name; with LegenDoom 3.0 under
  BD22 VR, load the LDL x BD22 VR patch after it (rig only, not headset-confirmed).
- **Brutal Doom, XMVE**: a Bossfight brings the map's own (replaced) types. Brutal Doom's gore and props are never enraged.

## Credits and licence

- Origin: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, November 2019; "All code by me. Special thanks to the Hideous
  Destructor server for helping me out!"). The idea of a miniboss with extra lives, thralls tied to it by trails, damage
  cut per living thrall, invulnerability after a lost life and thralls raised again comes from it. This is a rebuild; its
  code is not copied. Its to-do list asked for LegenDoom compatibility, and this delivers it.
- Set-piece design (legendary thralls, inherited powers, slow time on a thrall's death, the chain, the greed rule) and
  the Bossfight (the meter, the call-in, the arrival in view, scaling, the payoff): presidentkoopa.
- The arrival's idea of spawning at the map's own monster start spots: Dynamic Enemy Reinforcements v3 by Joshua Hard
  (MIT). Its code is not copied.
- Effects design (the IWAD sprites BFS1, APLS, BFE1, APBX, BAL2, FIRE in AddStencil): Tartlman's Minibosses!.
- Code: written for this pack. No sprites or sounds are shipped (the IWAD's own sprites and sounds are used by name).
- Recognised by name, not shipped: Champions, LegenDoom Lite, LegenDoom 3.0, RSQ SlowMo, RSQ Score, RSQ Glow In The Dark, RSQ Gun Bonsai VR, RSQ Accessibility (Gestures), RSQ Gun Cards.
- QuestZDoom: Emawind and Team Beef.

Free to share as part of the Radiant Silvergun Quest series.
