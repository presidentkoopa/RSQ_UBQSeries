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
  font is by **Jimmy**. They come with *Dakka*, a public repository, and are
  carried here with that credit (owner, 10-27: the score stays public).
- The colour definitions in `TEXTCOLO.txt`, renamed `RSScore_*` so that loading
  *Dakka* alongside this pack cannot have one definition win over the other.

- The six score sounds in `sounds/score/` (`points_reward`, `points_fullheal`,
  `point_revive`, `points_ammoregen`, `points_ammoregen_start`, `points_fizzle`):
  *Dakka*'s own files, byte for byte (same names and sizes, same git blob hashes as
  `pk3/sounds/score/` in *Dakka*'s repository, github.com/0dot0repeating/dakka,
  checked 2026-11-04). They came in with RS_Score's first commit (29e9ca3,
  2026-10-03). *Dakka*'s CREDITS.txt gives them as "Score reward sounds: People Can
  Fly, in Painkiller": they are *Painkiller*'s sounds, and *Dakka*'s WTFPL does not
  list them among the files it covers.

**The revival, rebuilt (owner 11-05: "i wanted an optimized version of that"):** *Dakka*'s
revival (`decorate/main/scorestuff.dec` DakkaReviveExplosion, RevivalFlame, RevivalFlameGround,
RevivalIntervention; `acs/score/score_reward.h` Score_CheckRevival) is rebuilt in `revive.zs` from
its numbers: the A_Explode(384, 256) blast with no self-damage, the protection, the ring 80 out
turning 2.5 degrees a tic for 70 tics with flames on eight spokes rising 2.5 a tic, and the last
burst. Its actors are not copied: a fixed pool of 32 flames does the drawing. *Dakka*'s flame
sprite (DFLM) is **not** carried: *Dakka*'s CREDITS give its minigun flames as Duke Nukem 3D /
Hexen and its WTFPL does not list them. The flames are doom2.wad's Arch-vile fire (FIRE A-H),
read from the IWAD the player already has.

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

## The Quest series version

The Brutal Doom kill rule, the Melee family, the physical bonuses, the suite bonuses, the
slow-motion moments, the menu and the pooled revival fire are the Quest series' (2026-10-27), built on
the owner's RS_Score (presidentkoopa), which is built on ijon's design. The breathing "Score:" word's colours (the calm-blue-to-warm
breath, the white-gold reaction, the letter wave) are from the owner's own earlier Score HUD (hf_score_hud.zs
ScoreLabelColor / HF_ScoreReact). It is published with the series, the two
fonts above shipping with credit to Blue Shadow and Jimmy (owner's decision).
