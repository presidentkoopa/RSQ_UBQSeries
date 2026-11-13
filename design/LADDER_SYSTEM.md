# The ladder system: one ladder for every monster set (branch `wip/2026-11-13-ladder-system`)

Owner, 2026-11-13 08:54: "if you have this written down and if you have rules in place to prevent you from drifting
you may start this work on a new branch, yes a new branch this time so we can test this system".

**This is a test branch. It is never merged into main without the owner's word.**

## What the system is (the owner's go-ahead was for these nine points, nothing else)
The numbers and the reasons are in `design/BD_XMVE_TIERING.md` (the rule) and the simulator's results
(`/tmp/econ3/sim`, 495 setups; summary in the session).

| # | Point | State at the start of this branch |
|---|---|---|
| 1 | **Spawn mix C, the sliding window.** The world tier S is the centre colour. Colours below it weigh 0.55 per step, colours above 0.30 per step; Black and White ×0.15 until the centre reaches them. Every colour is used. | to build (ColorfulHell has no world tier yet) |
| 2 | **Black and White are boss-grade under the world rule:** health 1.25× and 1.5× the family's Abyss, not ColorfulHell's literal boss health. | BD/XMVE: built on main (RS_BDTier). ColorfulHell: to build |
| 3 | **EX is its own step above White.** A Black EX never steps down to the plain White. | BD/XMVE: built on main (EX steps). ColorfulHell: to build |
| 4 | **BD22 and XMVE monsters are placed by strength against ColorfulHell's colours** (the challenge check, `design/tiering/ladder/bd22_on_ladder.json`, `xmve_on_ladder.json`), so both sets can share a map and a colour means the same strength. | to build, as a choice beside main's placement by health |
| 5 | **Ladder health:** the 43 ColorfulHell steps where health drops are lifted to the family's running maximum ×1.05 a step; two are kept (the Gray Lost Soul hive, the Cyan zombie trio). | to build |
| 6 | **The owner's colour order stays.** | nothing to build |
| 7 | **The tier tint wins over Champions' and Universal Entropy's tints;** Champions keep their particles and icons. | to build |
| 8 | **A miniboss missed-window tier-up stops at world tier + 3.** | built on main (fix 7, 75ddcdc8) |
| 9 | **The same 13-colour-plus-EX ladder for every set.** | the frame the others hang on |

## Rules against drift (they apply to every commit on this branch)
1. **Only the nine points.** Anything else that turns up (a bug, a better idea, a missing piece) is written in "Found on the
   way" below and NOT built. If a point cannot be built without a design call it does not already make, stop and ask
   the owner through AskUserQuestion, in plain words, with answers to pick.
2. **One switch, default off.** Everything new hangs on `rsq_mon_ladder` (server, default 0). With it off the game plays
   exactly as main does. No existing default changes.
3. **This branch only.** No push to main, no merge, no pk3 into PK3TEST. Only RSQ Monsters is changed (and its pk3).
   Other packs are read, never edited.
4. **Numbers come from the design data, generated, never typed by hand** (`design/tiering/` and `design/tiering/ladder/`,
   through a script kept in `design/tiering/tools/`).
5. **No cuts for performance.** Nothing is capped or thinned for Quest or anything else; that is the owner's call alone.
6. **Shown, not claimed.** Nothing is called working until a rig log or frames show it on the owner's load order:
   doom2 -> TUD -> LegenDoom -> brutal22test6 -> BD_VoxelPack -> BD22 VR -> XMVE 04/06/05/07 -> Legion of Bones ->
   Champions -> NoMoreHitscans -> Universal Entropy -> SpawnAdjuster -> environment -> mk-crits -> RegenShield ->
   ShotgunSpawner -> Gun Bonsai -> the RSQ pk3s, on **Black Metal**, with no script errors. Everything is labelled
   "rig only, not headset-confirmed".
7. **One commit per point**, its message naming the point. This file is updated in the same commit.
8. **Words:** miniboss, never bossfight; no terms from the earlier project.
9. **Stay in this lane.** The other session's branches and files are not checked or touched unless the owner says so.

## Test plan (rig, the owner's order, Black Metal)
- With `rsq_mon_ladder 0`: load, no script errors, spawns as on main (control run).
- With `rsq_mon_ladder 1` at world tiers 1, 4, 8, 11, 12, 13, 14: count every monster's colour on MAP01-MAP03 and
  compare with the window's expected shares; health of Black and White against 1.25× / 1.5× Abyss; EX present and never
  stepped down; BD22 and XMVE monsters on their strength colour; the 41 lifted steps' health; the tint after Champions
  and Universal Entropy have run (frames).

## Progress
- (none yet)

## Found on the way (not built)
- (none yet)
