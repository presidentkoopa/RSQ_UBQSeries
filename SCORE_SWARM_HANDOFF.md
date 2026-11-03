# RSQ Score: handoff for the local coding swarm

Rewritten 2026-11-03; this replaces the earlier version. Read `LOCAL_AGENT_HANDOFF.md` first for the rules, the build
and the load order. Run `git pull` before anything.

## What Score is

RSQ Score is the arcade scoring for the whole RSQ series: every kill pays points, and how you killed pays more.

- **History:** it came from ijon's Dakka mod (13 bonuses) and was rebuilt in ZScript. It grew to 89 bonuses and
  13 named combos, written when the series was much smaller.
- **The goal now:** Score must know every way to fight and kill in today's series. That means every combat move in
  every RSQ mod, Gun Bonsai VR's upgrades, BD22 VR's weapons, Champions and LegenDoom Lite, Miniboss and SlowMo, and
  the 2- and 3-tool combos between them.
- **Score pays for fighting and killing only.** Utility actions (holstering, reloading, the cigarette, the Zippo)
  never pay by themselves. They count only as part of a kill, the way Quick Draw pays for a kill shot right after a
  draw.
- **One move is one move,** whichever mod delivers it. Example: Melee's gun-butt shove, BD22's butt strike and its
  pistol whip are the single tool `shove`.

Code: `Score/zscript/rsscore/`. The design notes are in `Score/README.md` (appendix).

## The material (all in `Score/ideas/`, committed)

| File | What it is |
|---|---|
| `NAMING_SHEET.csv` | **The master list.** 1,166 rows: 221 new bonuses, 41 reworks, 72 stale-or-bug fixes, 823 named combos and the generic combo rule. Columns: id, kind, mod or area, placeholder name, trigger, proposed pay, readable today / needs, owner name, keep/cut, notes. |
| `COMBOS_MASTER.md` | The shared tool vocabulary (89 tool ids, plus tags), the generic combo rule, the opener × finisher matrix, every named chain, and section 5's flags (rows that can never fire, duplicate names, ideas present twice). |
| `A_…`, `B_…`, `C_…`, `D_…md` | The four idea lanes' full write-ups, with the detection detail (file, function, facts) for every row. |

Every name in the sheet is a **placeholder**, every pay a starting guess, and nothing in it has been built or
measured.

**Grapple changed after the sheet was written (2026-11-03, commit 61543d021):** its default is now jpalomo's
original: a one-off fling toward a wall or ceiling (never held there), and a one-off yank of a monster toward you.
The rope pull, slide, swing and lasso are options, off by default. Re-check every Grapple row in the sheet (kills
while hanging on the rope, Dismount, the slide-in rows, Indiana Jones) against the new default.

## Step 1: expand the list (the owner wants more)

- **Add rows to `NAMING_SHEET.csv`** in the same format, with a new stable id each.
- **Use the tool ids from `COMBOS_MASTER.md`.** If you need a new tool, add it to that vocabulary table, with the
  mod that sends it.
- **Ground every row in real code:** say where it lands and what facts exist, or what small answer a mod must add.
  Mark it "readable today" or "needs".
- **Merge near-duplicates** instead of adding copies.
- Keep to fighting and killing. Utility actions count only as part of a kill.
- Don't fill in "owner name" or "keep/cut": those columns are the owner's.

## Step 2: the owner names and cuts

The owner fills in "owner name" and "keep/cut" himself. Don't build anything until he says the sheet is ready. Ask
him with answers to pick if anything in it is unclear.

## Step 3: build what he kept, in this order

1. **The stale-or-bug fixes (kind = stale-fix).** These make today's scoring honest:
   - Score can't see the rebuilt Whip;
   - Grapple perk kills, swung barrels and thrown rig guns pay as punches;
   - BD22's grenade counts as a kick;
   - grenades are invisible to combos;
   - upgrade hooks count as extra tools on one blow;
   - the slow-motion bonus pays automatic slow-mo and Score's own hit-stop;
   - Brawler misses the chainsaw and axe;
   - and the rest in the sheet.
2. **The groundwork, from `COMBOS_MASTER.md`:**
   - the shared tool ids;
   - upgrade effects as tags, not tools;
   - the `@slow` step, the `+air` / `+pb` / `+head` conditions and the `| filter` victim filters;
   - one named combo per kill, the best one;
   - the generic combo rule;
   - the Reeled In change.
3. **The small additions in each mod** that the "needs" rows ask for. Each row names the mod and the answer it must
   give.
   - Mods are found by name or service at run time, never by a compile-time class.
   - Every mod still works alone.
4. **The kept bonuses.**
5. **The kept combos.** A combo is one row in Score's combo data table (`RS_ComboSeed.Combos` in `combo.zs`, or a
   mod's own registered combo). Names come from the sheet, so a rename never needs code.
6. **Rename the slow-motion bonus**, currently "Bullet Time". The owner picks the name; the sheet lists options.

For each step:
- show it working on the rig: a log line for each bonus or combo firing in a scripted scenario;
- zero script errors from our packs, on doom2 alone and on the owner's full load order;
- commit per mod, only the pk3s you changed;
- label anything VR-only "rig only, not headset-confirmed".

## Then

The owner's headset pass on Score. Score is the last pass before RSQ 1.0.
