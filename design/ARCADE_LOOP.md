# The arcade loop (owner, 2026-11-08 18:36: "i think i like this, yes")

Owner on the mockups (2026-11-08 22:37): "all of these fonts and shit are great, i really love all of this". The look
of the eight panels (our real fonts, Doom colours, glow and outline, no boxes) is approved as the arcade look.

From the eight mockups (design/mockups/arcade_language/). Each panel highlighted a different piece of gameplay. Panels
3-8 are one loop at three timescales; panels 1-2 are tools for set pieces only.

## What each panel is, as gameplay

| Panel | What it shows | The gameplay it stands for | Layer |
|---|---|---|---|
| 3 Shot words | GOOD / GREAT / AMAZING / PERFECT on the head you hit | **Skill is seen.** A run of good shots climbs a ladder you can read in the world. | Shot |
| 4 Hit number + combo | +20 rolling to +45, TRAP SHOOTER stamped above | **Points live where they happen.** Score's grading made visible at the kill, not on a HUD. | Shot |
| 5 Lit target | A barrel outlined, "+500" | **The level suggests what to do next.** Pinball targets: a lit thing is worth more now. | Fight |
| 6 Room timer | Clock over the door, ROOM CLEAR, TIME BONUS | **A reason to hurry.** Each fight has a pace; clearing fast pays. | Fight |
| 7 Level tally + grade | KILLS / ITEMS / SECRET count up, "S" slams in | **The verdict.** Doom's own intermission (kills, items, secrets, time, par) turned into a grade. | Level |
| 8 Jackpot / frenzy | FRENZY over a clock, JACKPOT +6100, bits burst | **The peak you earn.** Playing well across the layers triggers it; bits are what it pays. | Peak |
| 1 Lock-on ring | Ring on an Imp closing green to red | **Read one enemy's intent.** Only in set pieces (Bossfight, marked target, a triggered challenge). | Set piece |
| 2 Danger flash | Only the shot that will hit you flashes | **Dodge what matters.** Only in set pieces, where one threat matters. | Set piece |

## The loop

1. **Shot** (3, 4): every hit is graded and shown where it lands. Feeds the fight and the peak.
2. **Fight** (5, 6): the level lights targets and sets a pace; clearing pays a time bonus. Feeds the level and the peak.
3. **Level** (7): the grade at the end, on Doom's own counts.
4. **Peak** (8): a run of play across 1-2 triggers a jackpot / frenzy challenge; bits pay out. In a challenge, 1 and 2 may appear.

## What exists already (design/CHALLENGE_BUILDING_BLOCKS.md)
- Shot: RS Score already tags headshots, airborne, point-blank, Sights Up/Glass distances, Quick Draw, Direct Hit;
  VisualRewards already draws per-hit words and numbers. Nothing counts a STREAK of good shots yet.
- Fight: nothing lights targets; no room or fight clock; rooms can come from the map's structure (tools/mapview/).
- Level: Doom's intermission counts exist; no grade.
- Peak: Miniboss's Bossfight has the whole meter -> arrival -> payoff -> cooldown shape; bits exist but drop from
  every monster and DOWN's bank only works while DOWN; Score pays 25% for spawned monsters.

## Open (owner decides)
- Which layer to build first.
