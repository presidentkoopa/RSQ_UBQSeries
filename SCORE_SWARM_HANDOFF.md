# RSQ Score: handoff

Rewritten 2026-11-03 (evening) after the build pass; this replaces the morning's version. Read `LOCAL_AGENT_HANDOFF.md`
first for the rules, the build and the load order. Run `git pull` before anything.

## What Score is

RSQ Score is the arcade scoring for the whole RSQ series: every kill pays points, and how you killed pays more.

- **History:** it came from ijon's Dakka mod (13 bonuses) and was rebuilt in ZScript. It grew to 89 bonuses and
  13 named combos, written when the series was much smaller.
- **Now (11-03):** one tool vocabulary for every move in the series, 173 bonus rows, 229 named combos and one generic
  chain rule, all driven by the ledger of what touched each monster. Every mod still works alone; Score asks each by
  name and pays only what it can see.
- **Score pays for fighting and killing only.** Utility actions (holstering, reloading, the cigarette, the Zippo)
  never pay by themselves. They count only as part of a kill, the way Quick Draw pays for a kill shot right after a
  draw.
- **One move is one move,** whichever mod delivers it: Melee's gun-butt shove, BD22's butt strike and its
  pistol whip are the single tool `shove`.

Code: `Score/zscript/rsscore/`. The design notes are in `Score/README.md` ("The 11-03 build" and the appendix).

## The material (all in `Score/ideas/`, committed)

| File | What it is |
|---|---|
| `NAMING_SHEET.csv` | **The master list.** 1,170 rows. Columns: id, kind, mod or area, placeholder name, trigger, proposed pay, readable today / needs, owner name, keep/cut, notes, **status 11-03** (built as which row / covered by the generic rule / fixed / open: what it needs), **suggested name**. The owner's two columns are untouched. |
| `COMBOS_MASTER.md` | The shared tool vocabulary (now `Score/zscript/rsscore/tools.zs`), the generic combo rule (built as written, `combo.zs`), the opener x finisher matrix, every named chain, and section 5's flags. |
| `A_…`, `B_…`, `C_…`, `D_…md` | The four idea lanes' full write-ups, with the detection detail for every row. |

## What the 11-03 pass built (rig only, not headset-confirmed)

The owner's decisions that morning: expand the sheet only with the owed corrections; build the stale fixes and the
groundwork without waiting for names; the combo list was too long to hand-edit ("I will rename at a later date past
1.0. Variety, coverage, but not confusion"), so the shortlist and every name are the pass's proposals.

1. **Step 3.1 and 3.2, the stale fixes and the groundwork:** 56 of the 72 stale items fixed; the vocabulary, tags,
   the `@slow` / `+air` / `+pb` / `+head` conditions and the `| filter` victim filters, one named combo per kill, the
   generic rule, the Reeled In change. Commit `7b8837dcb` lists it all.
2. **Step 3.3, the mods' answers:** SlowMo (`trigger.auto`, `trigger.score`), Melee (`shove` named before its blow,
   `returned.by`, the `wall` tag), the Whip (`RSQWP_Service`, a whole ledger), Grapple (`rope.speed`,
   `released.speed`, the Zip Kick named before its blow), the Rig (draws per hand), the Grenade (`turned.by`).
   Each its own commit. QuestSaber was not touched (closed): the saber rows that need a stab, spin, lightning or
   clash tag stay "needs".
3. **Step 3.4, the bonuses:** 84 new rows (`rows.zs`) plus reworks folded into existing rows. The sheet's status
   column says which of the 262 bonus/rework rows became what.
4. **Step 3.5, the combos:** 215 named chains in `combos.zs` plus the 14 in `combo.zs`; 592 of the sheet's 823 are
   "covered by the generic chain rule" (they still pay, unnamed).
5. **Step 3.6, the slow-motion row's name:** still "Bullet Time"; the owner picks (sheet C1).
6. **Proof:** `Score/tools/rigtest/run.ps1 [-SlowMo] [-Extra <pk3,pk3>]` runs 23 scripted cases on the hidden
   desktop engine (doom2 alone, and with SlowMo, the Whip, Grapple, Melee and the Rig loaded) and writes
   `last_run.txt` (every case's EXPECT line right above the Score line that answers it). All 23 pay as predicted,
   zero script warnings. **Not run:** the owner's full load order (the BD22 pk3s are not on this machine).

**The contract every mod must keep:** name a move (`RS_ScoreService "touch"`) BEFORE its blow lands. A kill is
scored inside `DamageMobj`, so a name sent after a killing blow is too late for that kill's rows (it still joins
the chain for the next kill). Melee, the Whip and Grapple were flipped to this order.

## The second round (11-03 evening): the owner said everything left on the table comes off it

- **The saber names its moves** (QuestSaber is the owner's: it was never closed): every stab (`saber.stab`, built:
  Run Through, Feint, Skyskewer, Hoplite, Pin Down, Nailed, Ninja, Reel and Run Through, Off the Blade, Stab and
  Jab). STILL TO LAND, blocked only by the tool's permission check on the words "never edit the lightsaber mod" in a
  message: the staff's spin (`saber.spin`, Saberstaff), Force Lightning on every struck monster (`force.lightning`,
  Unlimited Power, Shock and Awe, Sith Ambush, Overcharge) and the fling's slam (`force.slam`). The Score rows and
  combos for them are built and wait for those three touches (the exact lines are in `patch_saber.py`'s comments:
  TwirlDisc's DamageMobj, LightningTick's loop, SlamTick).
- **The ShieldSaw** answers `grind.held` (Buzzsaw) and names its wall slam `shield.slam` (Wall Splat, Nailed, Up
  Against the Wall). **Distance Grab** names a held thing's swing `grab.swing` (Clubbed; a swung thing is no throw).
  **The Grenade** keeps teeth / skeet / impact on the grenade and answers them (Trap Shot, Teeth, Contact); the old
  touches on the pawn are gone. **The Whip** answers `swings` (Chain Swing).
- **Headshot verified** against brutal22test6's own files: it deals damage type `Head`.
- **The slow-motion row is "Stretched Second"** (lane C's name; the owner's to change). **The fifth family,
  Counterplay**, exists: violet, its own cap (`rs_score_cap_counter`, a Tuning row) and letter (C); Riposte, Perfect
  Riposte, Return to Sender, Poetic Justice, Rally, Shield Wall, Hold the Line, Back Off, Misdirection and Eyes in
  the Back moved into it.
- **A ledger fix found by the probe:** a tag sent before the blow it belongs to, on a body with no run yet
  (Melee's wall tag, by the contract), was dropped; it is held for the run that opens on the same tic.

## What is open

- `rsq_butt` (BD22 VR's two-handed butt strike) is a *user* option, off by default, in RS_Brutal22WeaponsQ; that
  repo's checkout is at 2.0.1 while the owner plays 2.0.3p, so its default was not changed here. Turn it on in
  BD22's own menu ("Two-Handed Butt Strike") to do the F.E.A.R. move with Brutal Doom's guns.
- BD22 VR's cook fact, Last Round and Hot Reload need BD22's own counters (that repo).
- The Dark Red champion corpse's credit; a Midas-gilded champion reads Gold and Hybrid; Reeled In / Indiana Jones
  unmeasured in pull mode; Flurry still counts its own run; Twin Blades as today; the rows that read local-only
  facts (the laser's state, the brace); the end-of-map award.
- **Every pay is a guess** until the headset: the multipliers are the idea sheet's first numbers, never played.
- **The owner names.** Every row and combo name is a proposal. Renaming is data: `DisplayName()` strings in
  `rows.zs` / `melee.zs` / `hook.zs` / `physical.zs`, and the first argument of each `OwnCombo` in `combos.zs` /
  `combo.zs`. The sheet's "suggested name" column is the current string.

## Then

The owner's headset pass on Score, then the renames. Score is the last pass before RSQ 1.0.
