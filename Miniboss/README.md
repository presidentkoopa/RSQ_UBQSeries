# RSQ Miniboss

Once per map, one strong monster becomes a miniboss, fed by three nearby monsters, its **thralls**. Dotted
particle lines join each thrall to it. While thralls live, the miniboss shrugs off most damage and has
their powers. Kill a thrall and time slows (with RSQ_SlowMo): a window to hurt the miniboss or kill the
next thrall. The miniboss has three lives; after each lost life it is briefly invulnerable and dead thralls
rise again. Get greedy (hit the miniboss while thralls live and let the window run out) and every monster
on the map turns fast and aggressive until the miniboss dies. Rebuilt from Tartlman's Minibosses! v0.1.1.

Pk3: `pk3/RSQ_Miniboss.pk3`.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
**RSQ_Miniboss.pk3** (after the other series pk3s and any monster
mods)

- Works on plain Doom 2 without Brutal Doom (run on vanilla doom2 on the rig). No monster class is named.
- Needs no other RSQ pk3 to load. **The slow-time window needs RSQ_SlowMo**; without it a thrall's death
  still opens the window for the chain and greed rules, but time does not slow. Score awards need RSQ_Score.
- Champions and LegenDoom Lite (optional, not RSQ): thralls are made legendary, and the miniboss inherits
  their champion powers.

## Setup

- No buttons to bind.
- Menu: Options -> Radiant Silvergun Options -> **RSQ Miniboss**. Numbers and Reset All are on its
  **Tuning and Debug** page.

## What to do in VR

Nothing special. Find the monster the particle lines run into; kill its thralls first.

## How to read it

- **Miniboss**: white beads run along dotted lines into it; one orb per life circles its head (the last one
  red and pulsing); a gold ring while it is invulnerable.
- **Thrall**: a marker over it and a dotted line to the miniboss. A faint grey line goes to a dead thrall
  that will rise.
- **Thrall killed**: an imp-fireball burst sound and the line shatters.
- **Life lost**: a BFG blast sound and a burst.
- **Rage**: the Icon of Sin's sight sound; red sparks rise off every enraged monster.

## Features

Front page (RSQ Miniboss):

| Row | Default | What it does |
|---|---|---|
| Minibosses | On | Minibosses appear at all. |
| How Often | Every Map | Rare (25 %) / Some Maps (50 %) / Every Map. |
| Fight | Standard | Easier (2 thralls, 2 lives, 50 % shield, 3 s invulnerable) / Standard (3, 3, 80 %, 5 s) / Harder (5, 4, 90 %, 8 s). |
| Legendary Thralls | On | With LegenDoom Lite: every thrall is made legendary (BD imp 80 -> 240 HP). |
| Inherit Powers | On | The miniboss gets its thralls' powers (Champions colours, extra lives, more damage or toughness; legendary if any thrall is). Kept until it dies. |
| Revive Thralls | On | Dead thralls rise when the miniboss's invulnerability ends. A gibbed thrall stays dead. |
| Greed Rule | On | Hit the miniboss while thralls live; when the slow window runs out (or 4 s after the hit with no window) and it and a thrall still stand, every monster is enraged: twice as fast, fires twice as often. Clearing the thralls first disarms it. |
| Effects | On | The lines, orbs, ring, markers and sparks (particles only). |
| Score Awards | On | Sends RSQ_Score: Thrall Slow Kill 100, Miniboss 500, Greedy 1000 (killed with thralls alive and no rage). |

Tuning and Debug page:

| Row | Default |
|---|---|
| Per Map | 1 |
| Map Chance | 100 % |
| Thralls | 3 |
| Lives | 3 (in all: it dies on the third) |
| Thrall Range | 1024 map units |
| Power Cap | 4 distinct powers |
| Thrall Shield | 80 % damage shrugged off with every thrall alive (less per dead thrall) |
| Invulnerable Time | 5 s |
| Per Thrall | +1 s per living thrall |
| Slow Window | 4 s |
| Chain Bonus | +3 s per thrall killed in the window |
| Window Cap | 12 s |
| Slow Depth | -1 (RSQ_SlowMo's own) |
| Rage Speed | x2 |
| Effects Range | 4000 map units |
| Debug Lines | Off (prints to the console only) |
| Reset All | |

## Test it

Load the order above plus RSQ_SlowMo.pk3 and RSQ_Miniboss.pk3 (add RSQ_Score.pk3 for step 9). Use a map
with plenty of monsters (MAP02 or later). A miniboss needs at least one other monster within range of it.
Built 2026-10-27; its handoff says it was never run on a headset.

1. Start the map. Within a second, dotted particle lines with white beads join a few monsters to one strong
   one. Orbs circle the strong one's head (three, the last red).
2. Shoot the miniboss while all thralls live: it barely loses health (80 % shrugged off).
3. Kill a thrall: a burst sound, its line shatters, the world slows for about 4 s.
4. Kill a second thrall inside that window: the slow lasts about 3 s longer.
5. With every thrall dead, the miniboss takes full damage. Bring it down: it does not die but loses an orb,
   with a BFG blast sound and a gold ring. Shots do nothing while the ring shows (5 s, +1 s per living
   thrall).
6. When the ring ends, dead thralls rise (a faint grey line led to each). A gibbed one stays dead.
7. Kill it on its third life.
8. Greed: on a new map, hit the miniboss while thralls live and let the slow window run out with a thrall
   alive. The Icon of Sin's sight sound plays; every monster sheds red sparks, moves twice as fast and fires
   more. It ends when the miniboss dies.
9. With RSQ_Score: killing a thrall during the slow window, the miniboss, and a greedy kill each add points.
10. Fight -> Easier: two thralls, two orbs. How Often -> Rare: most maps have none.
11. Effects Off: no lines, orbs or sparks; the rules still work.
12. Reset All (Tuning and Debug).

## Works with

- **RSQ_SlowMo** (sent to): each thrall death asks for the slow window.
- **RSQ_Score** (sent to): the three awards.
- Champions and LegenDoom Lite: powers inherited, thralls made legendary.
- Other mods can ask it (RSQMB_Service): is this a miniboss / thrall, enraged, lives, invulnerable,
  shield, greed, window. RSQ_TopHPBars asks "miniboss" and "thrall" for its crown and chain-link marks (2026-11-01).
- Does not read RSQ_Accessibility.

## Known limits / open

- Never headset-run: effect readability, sizes, colours, how long the fight takes.
- Score shows the three awards on their own rows (Thrall Slow Kill, Miniboss, Greedy; 2026-11-01, rig-checked).
- Open questions from the owner's notes: lives 3 in all (the original had 3 extra); greed counts even
  before any thrall died (4 s fuse); revived thralls come back at plain health; thrall kills by
  infighting open the window too (no award).

## The owner's design and ideas (kept as written)

The design below is what was built, except its "Later" line (RS Monsters' EX tier). The "Idea for later"
under "powers stay" (orbs per thrall, orbs in the puzzle) is not built: discuss before building.

### The design (owner, 10-27)
- A miniboss is fed by THRALLS (three, by default): boosted legendary champions (Champions + LegenDoom Lite), joined to it by trails. It INHERITS the powers of all its thralls.
- Killing a thrall SLOWS TIME (RSQ_SlowMo): a window to damage the miniboss -- or to kill another thrall, which keeps the slow time going.
- Clear the thralls, then fight the miniboss.
- Greedy play: attack the miniboss directly and you probably won't kill it before the slow-down runs out; then ALL monsters get double aggression and speed until the miniboss dies.
- The original's mechanics to keep and optimise: miniboss lives (default 3), living thralls cut the miniboss's damage taken, losing a life gives a short invulnerability, dead thralls revive when it ends.
- Later: this is where RS Monsters' EX tier is reached (EX is not tier-locked).

### Owner (10-27 23:53): powers stay
Keep all inherited powers until the miniboss dies (as 1.0 does) -- the owner prefers it to stripping them.
Idea for later (owner never built it): the original's orbs around the miniboss blink out as each thrall dies;
work them into the puzzle somehow. 1.0 shows one orb per LIFE and a link per thrall; a later pass could give
each thrall an orb of its colour/power, and make the orbs part of the play. Discuss before building.

More ideas (thrall orbs, orbs as a puzzle, EX tier, open questions): `docs/IDEAS.md`.

## Credits

From the old README:

> Credit the original: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, Nov 2019; "All code by me. Special thanks to the Hideous Destructor server"), on hiatus since 2019. (The original used Doom 2 IWAD sprites as placeholder effects; this rebuild uses engine particles only.) Tartlman's own to-do list included "special legendoom compatibility" -- which this rebuild delivers.

> Tartlman's original files stay in `original/` (owner, 10-28: "I like the og style. Keep.").

`CREDITS.txt`, unchanged:

```
RSQ_Miniboss -- credits
=======================

The Radiant Silvergun Quest series' set-piece miniboss. For stock QuestZDoom 17.3: ZScript and lumps only, no
engine changes.

WHERE IT COMES FROM
  Minibosses! v0.1.1 by Tartlman (ZDoom forum, November 2019; "All code by me. Special thanks to
  the Hideous Destructor server for helping me out!"), on hiatus since 2019 -- the origin of this
  mod: a miniboss with extra lives, thralls tied to it by trails, damage cut per living thrall,
  invulnerability after a lost life and thralls raised again when it ends. Kept unmodified in the
  repo's original/ folder. Its code is not copied: this is a rebuild. Its to-do list asked for
  "special legendoom compatibility"; this rebuild delivers it.

WHAT THIS PK3 SHIPS, AND WHOSE IT IS
  The project owner (presidentkoopa)
      The set-piece design: thralls as boosted legendary champions, the inherited powers, slow time
      on a thrall's death, the chain, the greed rule.
  Written for this pack
      All code (zscript/rsqmb). The effects are engine particles: no sprites or sounds are shipped
      (the cues use the IWAD's own sounds by name: weapons/bfgx, imp/shotx, brain/sight, vile/raise).

NOT SHIPPED, ONLY RECOGNISED BY NAME (nothing links)
  Champions (its champion_* tokens and cvars), LegenDoom Lite (its LDLegendaryMonster* tokens and
  LDLegendaryMonsterPickupGuaranteed), RSQ_SlowMo (rsm_pulse, RSQSM_Service), RSQ_Score
  (RS_ScoreService "award").
  QuestZDoom: Emawind and Team Beef.

SHARING
  Free to share as part of the Radiant Silvergun Quest series.
```

## Appendix: as built, for builders (the earlier README, unchanged)

### As built (agent-mb, 10-27) -- measured on rig C (QZD 17.3 script, stock engine)

Load after the series. `RSQ_Miniboss.pk3` (`./build.sh`). Options -> Radiant Silvergun Options -> RSQ Miniboss. What each setting does: `CVARINFO.txt`.

**Choosing** (tic 10, after LegenDoom Lite's tic 1-2 marking and Champions' tic-3 delayer): 1 miniboss per map (`rsqmb_per_map`), from the strongest third of the level's monsters weighted by spawn health (never BOSS-flagged, never a Dark Red / Undying champion), with 3 thralls (`rsqmb_thralls`) within 1024 units, none stronger than it: champions first, legendaries next, then the nearest. No class names: the same on Doom's and Brutal Doom's monsters. With LegenDoom Lite, every thrall is made legendary by LDL's own `LDLegendaryMonsterPickupGuaranteed` (measured: BD imp 80 -> 240 hp).

**Inheritance** (a "power", read from the two mods' code): a Champions colour is a token plus a controller thinker; a controller can't be made from outside without linking, so:
- TOKEN powers (Yellow, White, Dark Green, Cyan, Titan): the token is given; Champions' own handler does the work. Measured: Yellow on a legendary miniboss, after its transform, BaronBall 30.0 vs 15.0 default (Champions' boosted x2). Under `champion_Dormant 1` they sleep until the miniboss is a transformed legendary, as on any champion.
- LIFE powers (Dark Red, Undying): +1 life each, at most +2 (measured: lives 3 -> 4).
- STAT powers: Black +50% damage dealt (cap x2); every other colour or mutation +50% toughness (damage taken / toughness, cap x2).
- Legendary: any legendary thrall makes the miniboss legendary (measured: BD Baron 1200 -> 3600).
- Same colour twice counts once; at most 4 distinct powers (`rsqmb_inherit_max`), thrall order; legendary not counted.

**Lives / shield / invulnerability / revive** (the original's, kept and fixed): 3 lives in all (`rsqmb_lives`). BUDDHA holds it at 1 hp; it then refills to the most health it has had and is invulnerable 5 s + 1 s per LIVING thrall (measured 175 / 210 / 245 / 280 tics for 0-3 living). Hit while invulnerable: 0 damage. Living thralls cut damage taken linearly: 80% with all alive (taken 20.0 / 46.7 / 73.3 / 100%; the original's integer division made it 20% or nothing). All of it lives in `ModifyDamage` on a token (Champions overwrites `DamageFactor` itself). When the invulnerability ends the dead thralls rise (`A_RaiseSelf`, tried for 5 s); a gibbed-away (destroyed) thrall is gone for good.

**Slow time**: a thrall's death opens a 4 s window (`rsqmb_slow`) and asks RSQ_SlowMo for it by `rsm_pulse` (re-sent each second; depth = SlowMo's own `rsm_depth`). Another thrall killed in the window adds 3 s (`rsqmb_slow_chain`), up to 12 s (`rsqmb_slow_max`). Measured: 140 -> 205 (chain) -> capped 210 at a 6 s cap; SlowMo scale 250 permille in the window.

**Greed**: a player striking the miniboss while thralls live arms it. It comes due when the slow window runs out (struck with none running: 4 s later). Miniboss alive and a thrall standing then -> EVERY monster enraged until the miniboss dies: Speed x2 (`rsqmb_rage_speed`), `MissileChanceMult` and `MinMissileChance` halved (the fire threshold halves at every range), reaction spent. Clearing the thralls first disarms it. Measured: 70 monsters on MAP02 (BD) 4.0/0.5/200 -> 8.0/0.25/100, back after the kill; restored only where nobody changed a value since (LegenDoom's transform mid-rage keeps its own 0.0625). RSQ_SlowMo never writes a monster's Speed, so the two compose. Save/load twice mid-rage: no double application (12.0 stays 12.0).

**Score** (`RS_ScoreService "award"`, by name, just the push): "Thrall Slow Kill" 100 (a thrall killed in the window), "Miniboss" 500, "Greedy" 1000 (killed with thralls alive and no rage). Score has a row of its own for each (2026-11-01).

**For other mods**: `RSQMB_Service` (see `zscript/rsqmb/service.zs`): `miniboss`, `thrall`, `enraged`, `lives`, `invulnerable`, `shield`, `greed`, `window`, `living`, `legendary`; objects `boss` / `thrall`; string `powers`. Console: `netevent rsqmb_state`, `netevent rsqmb_choose`.

**FX** (engine particles, 0 actors; the original warped 30 actors per thrall every tic): a dotted link per living thrall with white beads running INTO the miniboss, a marker over each thrall, a faint grey line to a dead thrall that will rise, one orb per life circling its head (the last one red and pulsing), a gold ring while invulnerable, a red spark rising off each enraged monster. Drawn only within 4000 units of you.

**Cost** (`rsqmb_debug 1`, MSTimeF): 0.015-0.05 ms/tic of script on the full order; choosing 1.2 ms once (MAP02, 70 monsters); starting the rage 0.8 ms once; 6-20 particles spawned per tic.
