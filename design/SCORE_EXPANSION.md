# RSQ Score expansion (owner, 2026-11-09 01:32-01:35)

"We will need new expanded things for Score to check now that melee has been expanded and the monster rosters,
especially the CH aspect of it. MG too and its headhunter thing." / "Once we expand Score some we will then prune
it, but I want a big tree to prune, lol." / "I want us to expand score, so we will get on this now."

Score today: ~190 rows (`Score/zscript/rsscore/`). `boost.zs:40` already has the hook "for a later monster set (RS
Monsters' 13 colour tiers and EX tier)": subclass `RS_ScoreTierRow`; nothing fills it yet.

## A. Wrong today (bugs, found by reading the code)
1. **MG tiers pay Common money.** Base = `victim.GetSpawnHealth()` (`event.zs:83`), the class default. MG tiers set
   health on the live monster (`RS_MGMonster.ApplyTier`, `TierMaxHealth`), so a White MG imp (1200 hp) pays 60.
2. **CH tier changes pay the raised-monster rate.** (Correction 11-09: `rs_score_farmpercent` defaults to **100** (Score/CVARINFO.txt:40); 25 is only the code fallback, so at default settings this cut nothing. The census bug below was real at any setting: CH map spawns were never in the census, so each CH map's reward threshold fell to its 5000 floor and Untouchable's targets to their minimums. Fixed.)
   Was titled: CH tier changes pay 25%. Anti-farming (`handler.zs:342-361`): a monster not on the map at load pays
   `rs_score_farmpercent` (25%). A CH retier swaps in a NEW actor (`RS_Retier.Swap`), so the new colour pays 25%.
   Encounter spawns hit the same rule. To check: whether CH map spawns (via the Colourset RandomSpawner, and the rare
   colours' stub -> `A_SpawnItemEx`) are in the load census at all, or are all paying 25%.
3. **MG head shots are invisible.** `RS_Row_Headshot` reads BD22 damage types (Head / MinorHead). MG detects head
   shots by hit height (`RS_MGMonster.mgLastWasHeadshot`), which Score never sees.

Owner, 2026-11-09 02:16: MG monsters gib at normal-monster damage at every tier ("gib at normal, I don't see that an issue"): the gib threshold stays at the class health while base pay uses the tier health.

## B. New rows: the roster
- **Tier rows** for the RSQ ladder (13 colours), EX and boss variants, via the `RS_ScoreTierRow` hook. Rarer pays more.
- **Rarity**: pays by how rare the spawn roll was (a 1-in-1843 White).
- **Full Spectrum**: all 13 colours killed in one map (Rainbow for our ladder).
- **Colour Chain**: the same colour N times in a row (Radiant Silvergun).
- **Keep the Change** (owner's name, was "Nipped in the Bud"): killed while flashing, before it tiers up. **Fresh Paint**: killed just after it tiered up.
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

**Built 11-09 (code only, nothing run: owner's rule for this batch)** in `Score/zscript/rsscore/rows_panels.zs`, with
their watcher `RS_ScorePanels` (an EventHandler, registered in `Score/MAPINFO.txt`).
- **Justice Shot** (Counterplay, 0.4 of base; a big moment on 700+ base): your GUN kills a monster that is in an attack
  and has not fired. "In an attack" = the engine's JUSTATTACKED flag (A_Chase sets it as it sends the monster into its
  missile attack and clears it at the next A_Chase, so it holds wherever the Missile state jumps: Brutal Doom's own
  attack states, CH's IceWeave/HM/Missile2 labels) OR the state is inside its Missile / Melee sequence (stock, MG, and
  melee attacks, which set no flag). "Not fired" = no damaging missile (Brutal Doom's damage-0 trails and sparks are not
  shots), no SlowMo round, no hitscan (WorldHitscanPreFired, before the trace, so misses count) from it in the last 35
  tics. Not in Pain. A melee blow into an attack stays Counter's.
  Limits: a monster that fired under 1 s ago and has started a new attack does not pay; a hitscan another mod cancels
  before Score's handler hears it is not seen; a Lost Soul mid-charge pays (its charge fires nothing); a Brutal Doom
  melee lunge that leaves its Melee sequence at once is not seen; attacks made by scripts with no A_Chase are not seen.
- **Read It** (Counterplay, 0.5): a monster's shot aimed at you (its shooter's target was you when it spawned) passed
  within 48 map units (1.5 m) of your body and never hurt you, and you kill that monster within 3 s. The shot's path is
  sampled every tic as a segment, so a fast one cannot slip between samples. Missiles and SlowMo's slowed bullet rounds
  only: a plain hitscan bullet is no thing that flies, so it cannot be dodged in this sense. A shot you swatted or sent
  back is not a dodge (the return rows pay it).

## E. Melee (audit each move against existing rows first, then add what's missing)
Human Shield kills; kills by a barrel kicked with an uppercut; a swatted or knocked-away bullet that kills; Guard into a
counter kill; Ground Pound / Clear Out multi-kills; Headlock throw kills; Heavy Hands freeze into a kill.

**The audit (11-09, by reading).** Every RSQ Melee move (Melee/README.md Features, and the Gun Bonsai VR nodes Melee
plays) against the Score rows that pay it. Paths are `Score/zscript/rsscore/`. NEW = added 11-09 in `rows_melee2.zs`
(names are proposals, the owner renames).

| Melee move | What pays it today (file:line) | 11-09 |
|---|---|---|
| Jab / hook / uppercut (gloves) | Shoryuken rows.zs:114, Liver Shot :123, Glass Jaw :132, Textbook :141, Triple Threat :150, Dempsey Roll :161, Flurry melee.zs:836, Knockdown melee.zs:822, Counter melee.zs:806, Combo melee.zs:464, Weapon Master rows.zs:289, Giant Slayer rows.zs:322 | NEW Star Punch (the Star Punch node) |
| Punch with a NON-glove fist (Doom's Fist, Brutal Doom's fists, an empty hand) | only the generic fist rows (Knockdown, Counter, Combo, Giant Slayer): its tool is "punch", so Shoryuken and the punch-kind rows never fire, and Melee's punch tags land after the killing blow | gap, not changed (needs Melee to name the punch kind before the blow) |
| Uppercut launch, Juggle node | Air Combo rows.zs:176, Juggle melee.zs:622 | NEW Meteor (the Meteor node: the launched body lands on another) |
| Open-palm swat (missile knocked ASIDE) | read as a saber return: Return to Sender melee.zs:443 under the wrong tool | NEW Swatted (replaces Return to Sender for it); Melee now lists it, `returned.by` 3; tools.zs names it swat.aside |
| Swat Back / Hadouken (missiles) | Return to Sender melee.zs:443 (PUNCH 0.6), Poetic Justice :506, Misdirection rows.zs:373, Rally melee.zs:685; combos Street Fighter, Shoto, Neo, Return Fire combos.zs:51-54 | - |
| Fists and palms meeting BULLETS: knocked away | the shot is cancelled (gloves.zs WorldHitscanPreFired returns true): it can kill nothing | nothing to pay |
| Fists and palms meeting bullets: sent back (RSQML_Round) | nothing: the round is the player's own missile, so tools.zs read it as a gun shot | FIXED: tools.zs reads Melee's `returned.by` on RSQML_Round, so Return to Sender / Poetic Justice / Rally pay it |
| Catch (node) | Return to Sender (it is returned.by 0, a punch) | - |
| Hadouken into a shove into the shotgun | Return Fire combos.zs:53 | - |
| Guard: a blow soaked | nothing (its "guard" tag lands on no blow, so the ledger drops it) | NEW Rope-a-Dope (Melee now remembers, `guarded`) |
| Guard: Parry | combos Parry Punish, Counter Cut, Knuckle Sandwich, Dragon Fist combos.zs:56-59 | - |
| Guard: Reflect Guard | Return to Sender GUARD 0.5 melee.zs:443 | - |
| Guard: Absorb and Release | Release rows.zs:199; Pressure Valve combos.zs:60 | NEW Full Release (2+ kills in one release) |
| Wall Splat | Wall Splat rows.zs:1424 | - |
| Heavy Hands (freeze, knock) | nothing reads its hit.heavy tag | NEW Seeing Stars (killed within 1 s of the freezing punch) |
| Ground Pound | Ground Pound melee.zs:727 (one kill); Multi-Kill rows.zs:391 (0.25 a kill past the first); Tremor, Quake combos.zs:78-79 | NEW Seismic (2+ in one pound, replaces Multi-Kill there) |
| Clear Out | Bouncer rows.zs:190; Multi-Kill; Get Back!, Spread Out combos.zs:80-81 | NEW Out of My Way (2+ in one clear-out) |
| Taunt | Come Get Some, Come Closer combos.zs:76-77 | - |
| Uppercut Kicks Barrels (+ Distance Grab's Barrel Lock-On) | without the lock-on: nothing (its blast read as a gun kill); with it: Powder Keg physical.zs:394 (as a throw) | NEW Field Goal (Melee now remembers the kick, `barrel.kicked`) |
| Gun-butt shove (ours, BD22 VR's butt strike, Pistol Whip) | Butt Stroke rows.zs:240; Pistol Whip, Executioner, Riot Shield, Make Room, Fire in the Hole, Backlash combos.zs:41-48 | - |
| Rifle Butt (node: knockdown) | nothing reads its butt.knockdown tag | NEW Down for the Count |
| F.E.A.R. Effect | F.E.A.R. Effect combo.zs:86 (shove > gun.shotgun@slow, 0.6); Melee's 200-point award is taken at 0 (handler.zs:764) | NEW Red Mist (a shotgun kill in the window on a monster you did NOT shove); the blood mist (F) |
| Headlock hold | Headlock combo.zs:82; Hostage, Close Quarters, Hold This, Execution, Flog, Title Belt, Bouncer combos.zs:62-70 | - |
| Headlock throw | Toss rows.zs:208 (its own landing), Bowling hook.zs:140 (what it struck), Suplex, Clay Toss combos | covered: no new row |
| Headlock Slam, Chokehold, Headlock Uppercut | Piledriver rows.zs:221, Choked melee.zs:587, Cut Loose rows.zs:231 | - |
| Human Shield: the held monster dies of monster fire | Infighter (every player), never the holder | NEW Meat Shield (melee.zs LaunchedBy now names the holder: a Ring Out for him; Meat Shield replaces Ring Out's row) |
| Human Shield: you kill while holding one | nothing | NEW Human Shield |
| Slappers Only | the glove rows | NEW Bare Knuckle (a glove kill with Slappers Only on) |
| Hit sparks, hand models, gloves' look | not moves | - |

Found while auditing (fixed): `Melee/zscript/rsqml/gloves.zs` dropped dead entries from `returned` and `returnedMult`
but not `retHand` (the Bullet Time Fists loop), so after one there every later "returned.by" answer read the wrong hand.

## F. Melee + SlowMo: the shove and the F.E.A.R. Effect
- **Owner:** "if there is not an option to always slow time when gun butt shove, then I want one."
  **It exists:** `rsqml_shove_slowmo` (on by default) asks SlowMo for a pulse on every landed shove, length
  `rsqml_shove_slowmo_ms` = **300 ms**; SlowMo's own gate `rsqsm_trig_shove` (on). Check the menu shows both clearly,
  and whether 300 ms is long enough to shoot.
- **Owner's F.E.A.R. Effect:** "buttshove with shotgun, time slows, shoot with shotgun, kill monster, monster explodes
  into blood mist." **Today** (`Melee/zscript/rsqml/shove.zs:437-470`): while the shove's slow motion lasts, every
  shotgun hit bleeds twice and a kill pays 200 ("F.E.A.R. Effect"). **Missing:** the shotgun kill in that window
  exploding the monster into blood mist.

**Done 11-09 (code only, nothing run).**
- **The shove's slow motion, measured from the code.** Melee asks `rsm_pulse <rsqml_shove_slowmo_ms> 35`. SlowMo
  (`clock.zs` Pulse, WorldTick) holds the pulse ceil(ms x 35 / 1000) tics, eases in over rsm_ramp_in 0.15 s (1 / 5.25
  of the way a tic) and out over rsm_ramp_out 0.40 s (1 / 14 a tic), and its "slowmo.active" (the F.E.A.R. window,
  shove.zs FearTick; Score's @slow) lasts until the world is back at full speed. At **300 ms**: held 11 tics, at full
  depth (35%) from tic 4, so only ~7 tics (0.2 s) at full depth, then ~10 tics of ease out: the whole window ~21 tics,
  **0.6 s of real time**, and only ~0.3 s more than the world would have had anyway (~11 world tics pass in it).
  Bringing the gun back from a 3.6 m/s thrust, aiming and firing takes longer than that. **New default 1000 ms**: held
  35 tics, ~31 (0.9 s) at full depth, window ~45 tics (1.3 s). The Test and Debug slider now goes to 2000 ms (the code
  already allowed it). A player who already saved 300 keeps 300 (an archived cvar); Reset All gives 1000.
- **The menu, in plain words.** Melee: "Always Slow Time on Shove" (was "Slow-Mo After Shove"), "F.E.A.R. Blood Mist",
  and "Slow Time Length (ms)" on Test and Debug. SlowMo's own gate (Triggers page) now reads "Melee Gun Butt Shove"
  (was "Melee Shove"); both must be on.
- **The blood mist** (`rsqml_fear_mist`, server, on; shove.zs). When the window opens, every living monster within
  2048 units of the shover gets `RSQML_FearMark`. A shotgun blow of his in the window that would kill it is spent and
  replaced by one blow of damage type 'Extreme' past its gib health (same source and puff, so Score still reads a
  shotgun kill): the engine always makes that the extreme death and clears its damage type, so Brutal Doom's
  `Death.Shotgun` cannot catch it and the monster's **XDeath** runs (Brutal Doom's gib bursts, e.g. Imps.dec XDeath ->
  ImpXDeath, GoreGroups.dec, which already throw BloodMistExtraBig). Then the mist bursts from the body's middle:
  with Brutal Doom, by name, **BloodmistXXBig** x10 + **BloodmistExtraBig** x10 (Gore/Blood.dec), or
  **GreenBloodMistExtraBig/GreenBloodMistBig** for green blood (Baron, Hell Knight: Green_Blood) and
  **BlueBloodMistExtraBig/BlueBloodMistBig** for blue (Cacodemon: Blue_Blood). **Without Brutal Doom**: 24 of the
  monster's own blood type flung out, over its XDeath (stock zombies, imp, SS) or its normal death (no XDeath). No mist
  for a monster with no blood. A blow that forces pain or refuses extreme deaths, or a monster that cannot die of it,
  is left alone and still gets the mist.

## G. Later: encounters
Rows for whatever encounters get built (rescued, token collected, weak point hit...). Not now.

Pruning comes after: the owner wants the big tree first.
