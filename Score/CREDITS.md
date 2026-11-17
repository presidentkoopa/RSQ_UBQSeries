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

## Critical Hits: one hybrid system, Mikk-'s *Critical Shots* and cyber_c001's *RandomCrits*, side by side

Owner 2026-11-17: "we can build a hybrid critical system and credit both"; "Random only". `zscript/rsscore/crit.zs` is one
critical system made of two mods: **RandomCrits decides which shots crit** (a coloured random crit shot) and **Critical
Shots is what a crit does when it lands** (an mk crit). Credited to both authors equally.

### Mikk-'s *Critical Shots* (mk-crits): what a crit does

**The crit's payoff is Mikk-'s** (owner 2026-11-17: "i just want a god damn critical hit with the art style sounds and
rules of mk"). `zscript/rsscore/crit.zs` ports the CRITICAL HIT part of his *Critical Shots* (mk-crits,
`csh_classes/core.txt` csh_Brain / csh_critController, `delayer.txt`, `visuals.txt`, `handler.txt`): his damage factor,
his stun, his stunned-damage factor, his `csh_critical_*` settings for those with the same meanings and defaults
(renamed `rs_score_crit_*`), his menu rows for them, his seven visual effects and his sixteen sound choices. His head
shots and backstabs are not ported, and (owner, "Random only") neither is his timing trigger (a blow in the first 10 tics
of a monster's attack) nor its Prevent Fast Crits and Prevent Damage Stacking settings. The author gave public
permission on the ZDoom forum: "You're welcome to use this in your own projects."

Ours, and not his: the names (so mk-crits and Score can both load), the stand-down while mk-crits is loaded, the fix for
a monster with no Pain state (his `setState(findState("Pain"))` removed such a monster mid-damage and the next line
aborted the VM), the guards on his FX and sound numbers, the "crit" fact on Score's combo ledger, and a sound name his
SNDINFO never defined (`criticalshots/dks/meat`, now `rs_score_crit/dks/meat` on his `dks_meat.ogg`).

The files, his, byte for byte: `sprites/rscrit/` (his CRIT, HSHT, BCKS and TF2C sprites renamed RCRA, RCRB, RCRC, RCRD;
the cooke-blood X057, X058, X059 renamed RCRE, RCRF, RCRG) and `sounds/rscrit/` (his `sounds/` folders, the files his
sound list uses). The sounds and effects come from commercial games; the owner was told and chose to keep them.
mk-crits' credits.txt for them, as it reads:

```
Critical Shots - a mini-mod by Mikk.

Visual FX: 
	Hit Sparks 			-		Neoworm's Touhou Rips (https://forum.zdoom.org/viewtopic.php?f=37&t=15908&start=15)
	Metal Slug Blood 	- 		Metal Slug 2/X c. SNK - Ripped by Kevin Huff - https://www.spriters-resource.com/neo_geo_ngcd/ms2/sheet/32529/
	Blood Splat			-		Major Cooke (ripped from tf2 for AEoD)

Sounds: 
	Various 			- 		Dark Souls c. Bandai Namco & From Software.
	Critical Hit		-		Megaman ZX c. Capcom & IntiCreates, ripped by Team Kiira - https://www.sounds-resource.com/ds_dsi/megamanzx/sound/7180/
	COD Hitmarker SFX 	- 		Call of Duty, downloaded from: https://www.myinstants.com/instant/hitmarkermp3/
	Various	Headshots	-		Counter Strike: Global Offensive & Counter Strike: Condition Zero c.Valve Software 
	Various Crits		-		Team Fortress 2 c. Valve Software
```

### cyber_c001's *RandomCrits*: which shots crit

**The random crit shot is cyber_c001's** (*RandomCrits*, `Gameplay_RandomCrits.pk3`; owner 2026-11-17: "let's have
randomcrits colored random critical shot"). From its `zscript/random_criticals/event_handler.txt`, `trnslate_consts.txt`
and `trnslate.txt`: a player's shot rolls the crit chance as it is fired (in WorldThingSpawned, on a missile whose target
is a player), carries a token and is drawn in the crit colour while it flies; a hitscan, with nothing in flight, rolls as
it hits. Its player chance (`randomcrits_pcrchance`, 0.15) is Score's `rs_score_crit_random_chance`; its player
projectile colour (`randomcrits_pprojclr`) is `rs_score_crit_colour`, with its colour list in the menu (Score's default
is its colour 4, Cyan, owner 11-17; RandomCrits' own default is 1, Black). Its thirteen
colour translations are carried as they read, renamed only (`randomcrits_*` -> `RSQSC_Crit*`, Score's TRNSLATE.txt).
The roll and the token are written again in Score's code, not copied. The pk3 carries no licence file. Its in-game
credits read: "Critical hit system and sounds: Valve. Programming: cyber_c001", with thanks to the ZDoom Wiki, marrub,
Marisa Kirisame, Boondorl, XLightningStormL, NiGHTMARE and Solid-Head.

**Not used from RandomCrits:** its TF2 crit sounds (`sounds/crit/tf2/`: not carried; mk's sound plays for every crit),
its own damage multiplier (mk's is used), its enemy crits (owner: "monsters cannot crit player, this game is dangerous
enough with our monster tiers"), and its crit-chance boosts from damage dealt or taken (none built yet).

Ours, and not cyber_c001's: BD22 VR Reloaded's flying rounds treated as shots (rolled and coloured as they spawn, their
delivered hitscan matched to them), melee hitscans left out, the chance kept per player on Score's tracker as a stat other
systems can read and raise (`crit.chance`), one crit per blow, and the stand-down while RandomCrits is loaded.

## What is ours, and is not ijon's

- The bonus registry — bonuses as classes contributed by whichever mod owns the
  fact they measure, rather than a fixed list in one file.
- The anti-farming rule (`rs_score_farmpercent`). *Dakka* paid full points for a
  resurrected monster, which made an Arch-vile an endless score fountain.
- The multiplier caps (`rs_score_cap_*`): the family caps default to off; the total cap
  (`rs_score_cap_kill`) defaults to 300.
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
