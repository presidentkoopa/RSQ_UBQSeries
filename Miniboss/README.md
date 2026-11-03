# RSQ Miniboss (RSQ Miniboss)

**The one thing:** every map has a miniboss fed by three thralls; kill a thrall and time slows, get greedy and
the whole map enrages.

Once per map, one strong monster becomes a miniboss, fed by three nearby monsters: its **thralls**. Dotted
particle lines join each thrall to it. While thralls live the miniboss shrugs off most damage and carries their
powers; kill a thrall and time slows, a window to hurt the miniboss or kill the next thrall. Rebuilt from
Tartlman's Minibosses! v0.1.1 for stock QuestZDoom 17.3 (ZScript and lumps only, no engine changes). Works on
plain Doom 2 and on Brutal Doom: no monster class is named. Best with RSQ SlowMo (the slow window), Champions and
LegenDoom Lite (the thralls' powers) and RSQ Score (the awards). Loads and works alone.

## Features

**The set piece.**
- One miniboss per map, chosen from the strongest third of the level's monsters a moment after the map starts.
  Never a monster that already has the engine's boss flag, and never a Dark Red or Undying champion.
- Three thralls, the best monsters within range of it and none stronger than it: champions first, then
  legendaries, then the nearest.
- Dotted particle lines join each living thrall to the miniboss, with white beads running into it. A marker
  floats over each thrall.

**The shield.**
- With every thrall alive the miniboss shrugs off 80 % of the damage it takes. Each dead thrall lowers that in
  a straight line; with all thralls dead it takes full damage.

**Slow time.**
- Killing a thrall opens a 4 s slow window (RSQ SlowMo slows the world). Killing another thrall inside the
  window adds 3 s, up to 12 s.
- Without RSQ SlowMo the window still opens for the chain and greed rules; time does not slow.

**Lives.**
- The miniboss has three lives in all. Bring it down and it loses an orb instead of dying, refills to the most
  health it has had, and is invulnerable for 5 s plus 1 s per living thrall (a gold ring shows). It dies on its
  third life.
- One orb per life circles its head; the last one is red and pulsing.
- When the invulnerability ends, dead thralls rise again. A gibbed thrall stays dead. A faint grey line leads
  to a dead thrall that will rise.

**Inherited powers.**
- With Champions loaded, the miniboss gets its thralls' powers: Yellow, White, Dark Green, Cyan and Titan work
  exactly as on a champion; Dark Red and Undying each add a life (at most two); Black adds 50 % damage dealt;
  every other colour or mutation adds 50 % toughness (capped at double). The same colour twice counts once; at
  most four distinct powers.
- With LegenDoom Lite loaded, every thrall is made legendary, and any legendary thrall makes the miniboss
  legendary too.
- Powers stay until the miniboss dies.

**The greed rule.**
- Hit the miniboss while thralls live and its greed is armed. When the slow window runs out (or 4 s after the
  hit if no window was running) with the miniboss alive and a thrall still standing, every monster on the map
  is enraged until the miniboss dies: twice as fast, firing twice as often. Red sparks rise off every enraged
  monster and the Icon of Sin's sight sound plays.
- Clearing the thralls first disarms it.

**Score.**
- With RSQ Score, three awards on their own rows: Thrall Slow Kill (a thrall killed in the slow window),
  Miniboss, and Greedy (the miniboss killed with thralls alive and no rage). Score pays each as a share of
  that kill's base points (0.3x, 1x and 1.5x), so a Cyberdemon miniboss pays more than an imp.

**Counts as a Boss.**
- A miniboss never gets the engine's boss flag (that would switch off yanks, throws, the headlock, knockdowns and
  Gun Bonsai's melee bonuses across the series). It counts as a boss only in the systems below, each on its
  own switch: RSQ Gun Bonsai VR's boss kill rewards, LegenDoom's legendary health, RSQ Grapple's and RSQ Whip's
  yank, RSQ Melee's headlock, a map-wide roar and morph immunity.

## How to play

Nothing to bind. Put the headset on and find the monster the dotted lines run into.

1. Follow the lines to the miniboss. The orbs circling its head are its lives; the markers over the monsters
   at the other ends of the lines are its thralls.
2. Shoot the miniboss while all its thralls live and it barely loses health. Kill a thrall instead: an
   imp-fireball burst, its line shatters, and the world slows for about 4 s.
3. Kill the next thrall inside that window to keep the slow going (3 s more each, up to 12 s).
4. With every thrall dead the miniboss takes full damage. Bring it down: a BFG blast sound, a lost orb, a gold
   ring while it is invulnerable. Shots do nothing while the ring shows.
5. When the ring ends the dead thralls rise. Clear them again, and kill the miniboss on its last life.
6. Do not get greedy. If you hit the miniboss while thralls live and the slow window runs out with a thrall
   still standing, every monster on the map turns fast and aggressive until the miniboss dies.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Miniboss**.

| Menu row | Default | What it does |
|---|---|---|
| Minibosses | On | Minibosses appear at all. |
| How Often | Every Map | Rare (25 % of maps) / Some Maps (50 %) / Every Map (100 %). Sets Map Chance. |
| Fight | Standard | Easier (2 thralls, 2 lives, 50 % shield, 3 s invulnerable) / Standard (3, 3, 80 %, 5 s) / Harder (5, 4, 90 %, 8 s). |
| Legendary Thralls | On | With LegenDoom Lite: every thrall is made legendary. |
| Inherit Powers | On | The miniboss gets its thralls' powers, kept until it dies. |
| Revive Thralls | On | Dead thralls rise when the miniboss's invulnerability ends. |
| Greed Rule | On | The greed rule above. |
| Effects | On | The lines, orbs, ring, markers and sparks (particles only). |
| Score Awards | On | Sends the three awards to RSQ Score. |

**Counts as a Boss** (same page):

| Menu row | Default | What it does |
|---|---|---|
| Boss Kill Rewards | On | RSQ Gun Bonsai VR's kill rewards treat it as a boss: the boss fountain and every bit drops. |
| LegenDoom: Best Health | On | When this mod makes it legendary, it gets the higher of LegenDoom's boss legendary health and its normal one. Off: the normal one, always. |
| Can't Be Yanked | On | RSQ Grapple's and RSQ Whip's yank and throw refuse it as they refuse a boss: the line pulls you to it instead. |
| Can't Be Headlocked | On | RSQ Melee's headlock refuses it as it refuses a boss. |
| Map-wide Roar | Off | Its sight and death sounds play at full volume across the map. |
| Can't Be Morphed | Off | It cannot be morphed while it is a miniboss. |

**Tuning and Debug** (submenu; every number lives here):

| Menu row | Default | What it does |
|---|---|---|
| Per Map | 1 | Minibosses chosen per level (0-4). |
| Map Chance | 100 | % chance a level gets any. |
| Thralls | 3 | Thralls per miniboss (1-8). |
| Lives | 3 | Lives in all (3 = it dies on the third). |
| Thrall Range | 1024 | How far from the miniboss a thrall may stand (map units). |
| Power Cap | 4 | Most distinct powers inherited (legendary not counted). |
| Thrall Shield | 80 | % of damage shrugged off with every thrall alive. |
| Invulnerable Time | 5.0 | Seconds invulnerable after a lost life. |
| Per Thrall | 1.0 | Seconds added per living thrall. |
| Slow Window | 4.0 | Seconds of slow time a thrall's death buys. |
| Chain Bonus | 3.0 | Seconds added for another thrall killed in the window. |
| Window Cap | 12 | The window's longest, in seconds. |
| Slow Depth | -1 | World speed % in the window; -1 = RSQ SlowMo's own depth. |
| Rage Speed | 2.00 | Enraged monsters' speed multiplier. |
| Effects Range | 4000 | Effects drawn only within this distance of you (map units). |
| Debug Lines | Off | Console lines for every rule as it fires. |
| Reset All | | Every RSQ Miniboss setting back to its default. |

## Works with

- **RSQ SlowMo:** each thrall death asks SlowMo for the slow window; another thrall killed inside it extends
  the slow.
- **RSQ Score:** the three awards (Thrall Slow Kill, Miniboss, Greedy), each on its own row, paid as a share
  of the kill's base points.
- **RSQ Gun Bonsai VR:** with Boss Kill Rewards on, a miniboss kill pays the boss fountain and every bit drops.
- **RSQ Grapple and RSQ Whip:** with Can't Be Yanked on, the hook or the whip pulls you to the miniboss
  instead of yanking it.
- **RSQ Melee:** with Can't Be Headlocked on, the headlock refuses the miniboss.
- **RSQ HPBars:** marks the miniboss with a crown and its thralls with chain links.
- **RSQ ShieldSaw:** reads the miniboss's legendary health for the disc's tier health.
- **Champions** and **LegenDoom Lite** (not RSQ): thralls are made legendary; the miniboss inherits their
  champion powers.
- Gun Bonsai VR has no Miniboss nodes.

## Load order

After BD22, the monster packs, Champions, LegenDoom Lite and Gun Bonsai, with the other RSQ pk3s. Order among
the RSQ pk3s does not matter: everything it talks to is found by name at run time.

## Known limits

- Revived thralls come back at plain health.
- A thrall killed by infighting opens the slow window too, but pays no award.
- Greed can come due before any thrall has died: hit the miniboss with no window running and the 4 s fuse
  starts.
- LegenDoom: Best Health applies only when this mod makes the miniboss legendary. A monster LegenDoom Lite
  made legendary on its own before it was chosen keeps the normal legendary health.
- Built for LegenDoom Lite.

## For other mods

`RSQMB_Service`, found by name (`ServiceIterator.Find("RSQMB_Service")`). Pass the monster as the object
argument; requests without one answer for the level. -1 means unknown. Cheap first test: the monster carries
the `RSQMB_Ward` inventory (by name); only then ask.

GetInt:
- `miniboss` 1 for a living miniboss (no object: how many are alive).
- `thrall` 1 for a thrall bound to a living miniboss.
- `enraged` 1 while enraged by the greed rule (no object: 1 while any rage runs).
- `lives` lives left, the current one included.
- `invulnerable` 1 while its lost-life invulnerability lasts.
- `shield` damage it takes now, permille (0 while invulnerable).
- `greed` 1 while its greed is armed.
- `window` tics left in the slow window.
- `living` its living thralls (asked of a miniboss or a thrall).
- `legendary` 1 if it inherited legendary status.
- `bossfor` 1 when the monster is a miniboss and the named system's switch is on. The string argument names
  the system: `"rewards"` (a living miniboss, or one that died this tic or the last), `"yank"`, `"headlock"`
  (a living miniboss), `"ldhealth"` (this mod made it legendary with the higher of LegenDoom's boss and
  normal legendary health; stays 1 for that monster).

GetObject: `boss` (a thrall's miniboss; or the n-th miniboss), `thrall` (a miniboss's n-th thrall, dead or
alive). GetString: `powers` (what it inherited, comma-separated).

It sends: `rsm_pulse` to RSQ SlowMo; `RS_ScoreService` `award` to RSQ Score.

Console: `netevent rsqmb_state` prints every miniboss; `netevent rsqmb_choose` picks minibosses again now.

## Credits

Credit the original: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, November 2019; "All code by me. Special
thanks to the Hideous Destructor server for helping me out!"), on hiatus since 2019. The original used Doom 2
IWAD sprites as placeholder effects; this rebuild uses engine particles only. Tartlman's own to-do list asked
for "special legendoom compatibility", which this rebuild delivers. Tartlman's original files stay unmodified
in `original/`. Its code is not copied: this is a rebuild.

The set-piece design (thralls as boosted legendary champions, the inherited powers, slow time on a thrall's
death, the chain, the greed rule) is the project owner's (presidentkoopa). All code (zscript/rsqmb) was written
for this pack. No sprites or sounds are shipped: the cues use the IWAD's own sounds by name (weapons/bfgx,
imp/shotx, brain/sight, vile/raise).

Not shipped, only recognised by name (nothing links): Champions (its champion_* tokens and cvars), LegenDoom
Lite (its LDLegendaryMonster* tokens and LDLegendaryMonsterPickupGuaranteed), RSQ_SlowMo (rsm_pulse,
RSQSM_Service), RSQ_Score (RS_ScoreService "award"). QuestZDoom: Emawind and Team Beef.

Free to share as part of the Radiant Silvergun Quest series. `CREDITS.txt` holds the same credits.
