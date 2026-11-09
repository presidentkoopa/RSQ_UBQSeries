# Monster sets (owner, 2026-11-08 17:00) — vision, not a plan yet

The series' three Big Projects (owner, 2026-11-08 17:02): **Score pruning, GBOVR pruning, Monster Assembly.**
All monster work happens in one dedicated pass later.

The owner's words, condensed:
- RS Monsters will hold three monster sets that can be called up or in on the fly:
  1. the coloured tiers of Colourful Hell (RS Monsters was based on it),
  2. sgtMarkIV's MeatGrinder enemies, which the owner has already recoloured and re-tiered the same way (in a separate
     folder on his PC; "so it can be done"),
  3. Brutal Doom's monsters.
- Challenge design comes after the monsters are done. Possibilities he named: timed challenges, special miniboss
  encounters, "a million arcade possibilities". Big project.

Known gates (from design/RSMONSTERS_SCORE_GBOVR_STUDY.md and design/UNIFY_STUDY.md):
- RS Monsters' README says it needs the UZDXREMA engine. Owner (17:02): only one or two things need REMA and they can be
  separated out. Not yet compiled on stock QuestZDoom 17.3.
- Its `replaces` would push BD22's monsters out; "called up or in on the fly" means a spawner, not blanket replacement.
- Size: its source is about 142 MB; the series' combined size is ~91 MB today.
- Champions and LegenDoom also change monsters at runtime; they must not double-tier the same monster.

## Restart point (owner, 2026-11-08 23:18)
"Let's start by assuming we have no ideas and no gamemodes; we have these conceptual images and a robust miniboss
program for right now." First: make RS Monsters Quest-friendly (study: design/RSMONSTERS_QUEST_STUDY.md). Then he
points us to the MeatGrinder set, folded into RS Monsters, so we can design against monsters close to stock and BD
(MeatGrinder) as well as Colourful Hell's big changes.
