# RS_Score — credits

**The scoring design is ijon's.** RS_Score is a ZScript rebuild of the score
system from *Dakka* / *Vanilla VR Dakka Points*, which is released under the
WTFPL. What came from there:

- The bonus taxonomy — the thirteen bonuses and the three families they sit in
  (Efficiency, Style, Daring), and every number attached to them: the time
  windows, the thresholds, the multipliers.
- The reward loop — a per-map target score derived from a monster census, crossed
  repeatedly, alternating between ammo regeneration and an extra life.
- The HUD layout — the score line above a 120-pixel bar in a bracket, animated
  life pips above it, the breakdown stacking downward in family colours.
- The score HUD graphics: `SCOREBG1-4`, `SCOREBR1-4`, `SCOREBKT`, `HUD_LIF1-4`.
  ijon's own work, reused with credit.
- The two fonts, carried as `RSSCFON` and `RSSCFN2`. In *Dakka*'s credits the
  clean BIGFONT used for the score line is by **Blue Shadow** and the breakdown
  font is by **Jimmy**. Neither is licensed to us; they are here because this
  fork is private and never distributed.
- The colour definitions in `TEXTCOLO.txt`, renamed `RSScore_*` so that loading
  *Dakka* alongside this pack cannot have one definition win over the other.

**Not carried across:** *Dakka*'s reward sounds (People Can Fly, *Painkiller*) and
its revival fire-and-explosion actors. The extra-life mechanic is implemented; the
spectacle is not.

## What is ours, and is not ijon's

- The bonus registry — bonuses as classes contributed by whichever mod owns the
  fact they measure, rather than a fixed list in one file.
- The anti-farming rule (`rs_score_farmpercent`). *Dakka* paid full points for a
  resurrected monster, which made an Arch-vile an endless score fountain.
- The multiplier caps (`rs_score_cap_*`), all defaulting to off so that out of the
  box the arithmetic is *Dakka*'s exactly.
- Generalised ammo regeneration. *Dakka* regenerated a hardcoded list of its own
  eight ammo classes at fixed rates; this gives back a percentage of whatever ammo
  the player actually carries, so it works for any weapon set. The amounts are
  therefore **not** *Dakka*'s and cannot be.
- Measuring gravity from the actor rather than assuming it, so the Air bonus is
  right under a jump modifier, in low gravity and in water.
