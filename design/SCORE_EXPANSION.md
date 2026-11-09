# RSQ Score expansion (owner, 2026-11-09 01:32-01:35)

"We will need new expanded things for Score to check now that melee has been expanded and the monster rosters,
especially the CH aspect of it. MG too and its headhunter thing." / "Once we expand Score some we will then prune
it, but I want a big tree to prune, lol." / "I want us to expand score, so we will get on this now."

Score today: ~190 rows (`Score/zscript/rsscore/`). `boost.zs:40` already has the hook "for a later monster set (RS
Monsters' 13 colour tiers and EX tier)": subclass `RS_ScoreTierRow`; nothing fills it yet.

## A. Wrong today (bugs, found by reading the code)
1. **MG tiers pay Common money.** Base = `victim.GetSpawnHealth()` (`event.zs:83`), the class default. MG tiers set
   health on the live monster (`RS_MGMonster.ApplyTier`, `TierMaxHealth`), so a White MG imp (1200 hp) pays 60.
2. **CH tier changes pay 25%.** Anti-farming (`handler.zs:342-361`): a monster not on the map at load pays
   `rs_score_farmpercent` (25%). A CH retier swaps in a NEW actor (`RS_Retier.Swap`), so the new colour pays 25%.
   Encounter spawns hit the same rule. To check: whether CH map spawns (via the Colourset RandomSpawner, and the rare
   colours' stub -> `A_SpawnItemEx`) are in the load census at all, or are all paying 25%.
3. **MG head shots are invisible.** `RS_Row_Headshot` reads BD22 damage types (Head / MinorHead). MG detects head
   shots by hit height (`RS_MGMonster.mgLastWasHeadshot`), which Score never sees.

## B. New rows: the roster
- **Tier rows** for the RSQ ladder (13 colours), EX and boss variants, via the `RS_ScoreTierRow` hook. Rarer pays more.
- **Rarity**: pays by how rare the spawn roll was (a 1-in-1843 White).
- **Full Spectrum**: all 13 colours killed in one map (Rainbow for our ladder).
- **Colour Chain**: the same colour N times in a row (Radiant Silvergun).
- **Nipped in the Bud**: killed while flashing, before it tiers up. **Fresh Paint**: killed just after it tiered up.
- **Upset / tier Giant Slayer**: a low tier kills a top tier (infighting), or you kill a top tier with a weak weapon.
- **Gang War**: a CH monster kills an MG monster or the reverse. **Mixed Bag**: both sets in one combo.

## C. New rows: MeatGrinder
- **Headhunter**: MG head-pops; a streak of them.
- **Reactive deaths** (gib, burn, freeze, shock, melt) feed the rows Score already has (Pop, Barbecue, Ice Breaker,
  Live Wire...) instead of going unseen.
- **Splitter**: kill an Abyss monster and both lost souls it splits into.
- **Kill a top-tier MG monster mid-attack** (its aggression).

## D. New rows: Virtual Cop / Time Crisis (panels 1, 2)
- **Justice Shot**: kill during its wind-up, before it fires.
- **Read It**: dodge the flashing shot, then kill whoever fired it.

## E. Melee (audit each move against existing rows first, then add what's missing)
Human Shield kills; kills by a barrel kicked with an uppercut; a swatted or knocked-away bullet that kills; Guard into a
counter kill; Ground Pound / Clear Out multi-kills; Headlock throw kills; Heavy Hands freeze into a kill.

## F. Melee + SlowMo: the shove and the F.E.A.R. Effect
- **Owner:** "if there is not an option to always slow time when gun butt shove, then I want one."
  **It exists:** `rsqml_shove_slowmo` (on by default) asks SlowMo for a pulse on every landed shove, length
  `rsqml_shove_slowmo_ms` = **300 ms**; SlowMo's own gate `rsqsm_trig_shove` (on). Check the menu shows both clearly,
  and whether 300 ms is long enough to shoot.
- **Owner's F.E.A.R. Effect:** "buttshove with shotgun, time slows, shoot with shotgun, kill monster, monster explodes
  into blood mist." **Today** (`Melee/zscript/rsqml/shove.zs:437-470`): while the shove's slow motion lasts, every
  shotgun hit bleeds twice and a kill pays 200 ("F.E.A.R. Effect"). **Missing:** the shotgun kill in that window
  exploding the monster into blood mist.

## G. Later: encounters
Rows for whatever encounters get built (rescued, token collected, weak point hit...). Not now.

Pruning comes after: the owner wants the big tree first.
