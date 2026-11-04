# 0.99a bug and refine list

Found while rewriting the READMEs from the code (11-03 evening). None fixed yet; bugfix and refine only.

## SlowMo
1. With the Gun Bonsai VR patch loaded, the "Lean Out of Bullets" row is ignored: the lean depends only on the
   patch's Lean Dodge upgrade, which starts unlearned (clock.zs `LeanOn`). Decide: the row should still turn it off,
   and say in the menu that the upgrade is needed with Gun Bonsai VR.
2. With Adrenaline off, the gauge measures its fill against `rsm_depth`. It ignores the Deeper upgrade and the
   shootdodge's 10%, so during those it just sits at full (gauge.zs). Minor.
3. CREDITS.txt lists only the gauge art RSQSMGE/RSQSMGF. The other bar art also comes from coldcite's bar and is
   missing: RSQSMGW, and the countdown bar's RSQSMHE/RSQSMHW.

## Score
4. CREDITS.md doesn't say where the shipped sounds in sounds/score/ come from (points_reward, fullheal,
   point_revive, ammoregen, ammoregen_start, fizzle).
5. CREDITS.md contradicts itself on the fonts: carried with credit vs not licensed for distribution. The owner's
   call (ties into the JFO licence question).
6. Menu gaps:
   - `rs_score_cap_efficiency`, `rs_score_cap_style` and `rs_score_cap_daring` are in Reset All but have no menu
     rows.
   - `rs_score_norewards`, `rs_score_regenpercent` and `rs_score_monstermin/max/scalar/interval` have no rows and are
     not in Reset All.
   - The Bonus Display Time slider starts at 35, so the HUD's "0 hides the breakdown" setting can't be reached.
   (Menu rows wait for the owner's menu redesign.)
7. rows.zs:995: the Headshot row's "UNMEASURED" comment is stale. Headshot was verified against brutal22test6's
   files (damage type `Head`; SCORE_SWARM_HANDOFF.md). Update the comment.
