# RSQ Miniboss

Every level picks a champion from its own monsters, binds it to a crew of thralls that feed it, and dares you to go for the head first.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

RSQ is a series of VR mods for stock QuestZDoom 17.3, built in ZScript alone with no engine changes. RSQ Miniboss is a
rebuild of Tartlman's Minibosses! with new rules, and it reads monsters by their health, never their class name, so it
works the same on Doom's monsters, Brutal Doom's and most monster packs.

## Standout feature: the set piece

A few seconds into a level, the miniboss is chosen: usually the toughest thing on the map. Its thralls are the best
monsters around it. Glowing beaded lines run from each thrall into the miniboss, showing who feeds whom.

- While its thralls live, the miniboss shrugs off most of your damage (80% with all of them up, less for each one down).
- It has three lives, shown as orbs circling its head. Knock one off and it refills, turns invulnerable behind a gold
  ring, and when the ring ends its dead thralls rise again.
- Every thrall you kill **slows time** around you (with RSQ SlowMo loaded). Kill another inside the window and the window
  stretches. Chain the whole crew in one long slow-motion sweep.
- Hit the miniboss while its thralls still stand and you arm the **greed rule**. If the slow window runs out with the
  miniboss and a thrall still alive, every monster on the map is enraged: twice as fast and far quicker to shoot, until
  the miniboss dies. Kill it while its thralls still stand, before the rage comes, and RSQ Score pays a Greedy bonus.

You choose: clear the crew the safe way, or go for the throat and live with the consequences.

## Features

**Choosing**
- One miniboss per level by default (up to 4), drawn from the strongest third of the level's monsters, weighted by
  health. A Baron among imps is nearly always the one.
- Up to 3 thralls (1 to 8), the best monsters within 1024 units, never stronger than their miniboss.
- Monsters the engine already treats as bosses are never picked.

**The fight**
- **Thrall Shield**: damage cut by up to 80%, shared out per living thrall.
- **Lives**: 3 by default. Each lost life gives 5 seconds of invulnerability plus 1 second per living thrall.
- **Revive Thralls**: dead thralls rise when that invulnerability ends.
- **Slow window**: 4 seconds per thrall kill, +3 seconds for each chained kill, up to 12 seconds.
- **Greed Rule**: struck while thralls live, then the window ends with a thrall still up: map-wide rage until the
  miniboss dies. Everything enraged is put back exactly as it was afterwards.
- **Effects**: thrall links, life orbs (the last one burns red), the invulnerability ring, shatter lines when a thrall
  dies, red sparks over enraged monsters. All engine particles, drawn only within 4000 units of you.
- Sounds are Doom's own: a BFG burst for a lost life, a fireball pop for a thrall, the Icon of Sin's roar for the rage.

**Counts as a boss** (each on its own switch; the engine's boss flag is never set)
- **Boss Kill Rewards**: RSQ VisualRewards' Kill Rewards treat it as a boss kill.
- **Can't Be Yanked**: RSQ Grapple and RSQ Whip pull you to it instead of yanking it.
- **Can't Be Headlocked**: RSQ Melee's headlock refuses it.
- **LegenDoom: Best Health**: made legendary here, it gets the higher of LegenDoom Lite's boss and normal legendary health.
- **Map-wide Roar** (optional, off by default): its sight and death sounds carry across the map.
- **Can't Be Morphed** (optional, off by default).

**With other monster mods**
- **LegenDoom Lite**: every thrall is made legendary, and a legendary thrall makes the miniboss legendary too.
- **Champions**: champion thralls are picked first, and the miniboss inherits their powers, up to 4. Yellow, White, Dark
  Green, Cyan and Titan powers pass on as they are; Dark Red and Undying add a life each (up to +2); Black adds 50% damage;
  any other colour or mutation makes it 50% tougher (up to x2).

## How To Play

1. Add the pk3 to your load order. A miniboss is picked on every level by default.
2. Look for the beaded lines. The monster they all run into is the miniboss; the life orbs over its head confirm it.
3. The safe way: kill the thralls first. Each kill slows time, so line the next one up fast to chain the window. With
   the crew down, the miniboss takes full damage.
4. The greedy way: hit the miniboss early. If you cannot finish it or its crew before the slow window ends, the whole
   map comes at you at double speed.
5. When a life breaks, back off. The gold ring means it cannot be hurt, and its fallen thralls are about to stand up.
6. Too hard or too easy? Change **Fight** to Easier or Harder, or **How Often** to Rare or Some Maps.

## Controls

RSQ Miniboss adds no buttons. You fight it with whatever you play with.

| Action | How (VR) | Notes |
|---|---|---|
| Find the miniboss | Look for the lines and the circling orbs | Gold ring: invulnerable. Last orb red: last life. |
| Start a slow window | Kill a thrall | Needs RSQ SlowMo for the slow motion itself. |
| Chain the window | Kill another thrall before it ends | +3 s each, up to 12 s. |
| Arm the greed rule | Hit the miniboss while a thrall lives | Clear every thrall in time to disarm it. |

## Menu

**Options → Radiant Silvergun Options → RSQ Miniboss**

| Row | Default | What it does |
|---|---|---|
| Minibosses | On | Minibosses appear at all. |
| How Often | Every Map | Rare (25%), Some Maps (50%), Every Map (100%). |
| Fight | Standard | Easier, Standard, Harder: thralls, lives, shield and invulnerability together. |
| Legendary Thralls | On | With LegenDoom Lite, every thrall is made legendary. |
| Inherit Powers | On | The miniboss inherits its thralls' powers. |
| Revive Thralls | On | Dead thralls rise when its invulnerability ends. |
| Greed Rule | On | The greed rule. |
| Effects | On | Links, orbs, ring and sparks. Per player. |
| Score Awards | On | Sends awards to RSQ Score. |
| Boss Kill Rewards | On | Counts as a boss for Kill Rewards. |
| LegenDoom: Best Health | On | Higher of LegenDoom's boss and normal legendary health. |
| Can't Be Yanked | On | Grapple and Whip cannot yank it. |
| Can't Be Headlocked | On | Melee's headlock refuses it. |
| Map-wide Roar | Off | Sight and death sounds at full volume map-wide. |
| Can't Be Morphed | Off | Immune to morphing. |

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Per Map | 1 | Minibosses per level, 0 to 4. |
| Map Chance | 100 | % chance a level gets any. |
| Thralls | 3 | Thralls per miniboss, 1 to 8. |
| Lives | 3 | Lives in all. |
| Thrall Range | 1024 | How far from the miniboss a thrall may stand (map units). |
| Power Cap | 4 | Most distinct powers inherited (legendary not counted). |
| Thrall Shield | 80 | % of damage shrugged off with every thrall alive. |
| Invulnerable Time | 5.0 | Seconds invulnerable after a lost life. |
| Per Thrall | 1.0 | Extra seconds per living thrall. |
| Slow Window | 4.0 | Seconds of slow time per thrall kill. |
| Chain Bonus | 3.0 | Extra seconds per chained kill. |
| Window Cap | 12 | The window's longest, seconds. |
| Slow Depth | -1 | World speed % in the window; -1 uses RSQ SlowMo's own. |
| Rage Speed | 2.00 | Enraged monsters' speed multiplier. |
| Effects Range | 4000 | Effects drawn only within this distance of you. Per player. |
| Debug Lines | Off | Console lines for every rule as it fires. |
| Reset All | | Resets every RSQ Miniboss setting. |

## Works with

- **Alone**: the whole set piece works: lives, shield, revives, greed and rage. Without RSQ SlowMo the window still runs
  (it times the greed rule and chains), there is just no slow motion.
- **RSQ SlowMo**: each thrall kill slows the world to SlowMo's depth for the window.
- **RSQ Score**: Thrall Slow Kill (a thrall killed inside the window), Miniboss and Greedy awards, each paid as a share of
  that kill's own score.
- **RSQ VisualRewards**: HP bars mark the miniboss and its thralls; Kill Rewards treat it as a boss (switch above).
- **RSQ Glow In The Dark**: the map's glow reacts while a miniboss lives.
- **RSQ Grapple, RSQ Whip, RSQ Melee**: refuse to yank or headlock it (switches above).
- **RSQ ShieldSaw and RSQ Gun Bonsai VR**: read its true legendary health when it was made legendary here.
- **LegenDoom Lite and Champions**: see Features. Both are optional and found by name.
- **Brutal Doom**: works as is. Brutal Doom's gore and props are never enraged.

## Credits and licence

- Origin: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, November 2019; "All code by me. Special thanks to the Hideous
  Destructor server for helping me out!"). The idea of a miniboss with extra lives, thralls tied to it by trails, damage
  cut per living thrall, invulnerability after a lost life and thralls raised again comes from it. This is a rebuild; its
  code is not copied. Its to-do list asked for LegenDoom compatibility, and this delivers it.
- Set-piece design (legendary thralls, inherited powers, slow time on a thrall's death, the chain, the greed rule):
  presidentkoopa.
- Code: written for this pack. Effects are engine particles; no sprites or sounds are shipped (the IWAD's own sounds are
  used by name).
- Recognised by name, not shipped: Champions, LegenDoom Lite, RSQ SlowMo, RSQ Score.
- QuestZDoom: Emawind and Team Beef.

Free to share as part of the Radiant Silvergun Quest series.
