# RSQ_Miniboss (UBQ / RSQ suite)

The owner's set-piece miniboss, rebuilt from the abandoned minibosses.pk3 (kept unmodified in `original/`; the owner, 10-27: "Miniboss was abandoned so its ours. We can rebuild and optimize the hell out of it and integrate whatever we want."). Credit the original: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, Nov 2019; "All code by me. Special thanks to the Hideous Destructor server"), on hiatus since 2019. (The original used Doom 2 IWAD sprites as placeholder effects; this rebuild uses engine particles only.) Tartlman's own to-do list included "special legendoom compatibility" -- which this rebuild delivers.

## The design (owner, 10-27)
- A miniboss is fed by THRALLS (three, by default): boosted legendary champions (Champions + LegenDoom Lite), joined to it by trails. It INHERITS the powers of all its thralls.
- Killing a thrall SLOWS TIME (RSQ_SlowMo): a window to damage the miniboss -- or to kill another thrall, which keeps the slow time going.
- Clear the thralls, then fight the miniboss.
- Greedy play: attack the miniboss directly and you probably won't kill it before the slow-down runs out; then ALL monsters get double aggression and speed until the miniboss dies.
- The original's mechanics to keep and optimise: miniboss lives (default 3), living thralls cut the miniboss's damage taken, losing a life gives a short invulnerability, dead thralls revive when it ends.
- Later: this is where RS Monsters' EX tier is reached (EX is not tier-locked).

## As built (agent-mb, 10-27) -- measured on rig C (QZD 17.3 script, stock engine)

Load after the series. `RSQ_Miniboss.pk3` (`./build.sh`). Options -> RSQ Miniboss. What each setting does: `CVARINFO.txt`.

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

**Score** (`RS_ScoreService "award"`, by name, just the push): "Thrall Slow Kill" 100 (a thrall killed in the window), "Miniboss" 500, "Greedy" 1000 (killed with thralls alive and no rage). Unknown labels pay onto Score's Base row until its rows exist.

**For other mods**: `RSQMB_Service` (see `zscript/rsqmb/service.zs`): `miniboss`, `thrall`, `enraged`, `lives`, `invulnerable`, `shield`, `greed`, `window`, `living`, `legendary`; objects `boss` / `thrall`; string `powers`. Console: `netevent rsqmb_state`, `netevent rsqmb_choose`.

**FX** (engine particles, 0 actors; the original warped 30 actors per thrall every tic): a dotted link per living thrall with white beads running INTO the miniboss, a marker over each thrall, a faint grey line to a dead thrall that will rise, one orb per life circling its head (the last one red and pulsing), a gold ring while invulnerable, a red spark rising off each enraged monster. Drawn only within 4000 units of you.

**Cost** (`rsqmb_debug 1`, MSTimeF): 0.015-0.05 ms/tic of script on the full order; choosing 1.2 ms once (MAP02, 70 monsters); starting the rage 0.8 ms once; 6-20 particles spawned per tic.

## Owner (10-27 22:49): powers fall away
The miniboss inherits its thralls' abilities -- up to four active champion / mutation / boosted effects -- and
they GO DOWN as we whittle it away. (1.0 caps inheritance at 4 but keeps them all until death.) Open: what
strips a power -- each thrall killed, each life lost, health thresholds, or a mix. Ask the owner, then build.
