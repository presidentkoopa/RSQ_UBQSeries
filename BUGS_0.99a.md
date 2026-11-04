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

## LaserSight
8. REAL BUG: with RSQ Gun Bonsai VR loaded, Target Lock and Headshot Reaction ignore their menu switches and turn on
   only as Gun Bonsai upgrades (sight.zs `GbRefresh`, `Lock`/`Recolor`/`Head`). Those upgrades exist only when RSQ
   TacticalRig is loaded too (`RSQ_LaserPerk` -> `RSQ_RigPerk.ModLoaded` needs `RSQTR_RigService`). So with Gun
   Bonsai VR but no TacticalRig, Target Lock (default on) can never turn on. Fix: fall back to the switches when the
   upgrade path isn't available.

## GunCards
9. JFO/JDUI font (Zedas, Blackmore1014) has no reuse licence; it is the default card font. Blocker for the public
   1.0 (the JFO licence question).
10. The empty-hand Status card never shows with Draw in the World on (card.zs `!rsqgc_world`). Limitation; decide.
11. "Show Cards: Inspect Gesture" quietly behaves as "When You Look at the Gun" without RSQ Gestures; label it.

## Wheel
12. Fold Warning defaults to 25 tics, but its slider steps by 35 (0-105): the default is off the scale.
13. Stale comments: wr_q_gunlook.zs header still describes the Edge Sweep (off by default); KEYCONF `[`/`]` comment
    talks about UZDXREMA's binds. Per-gun rumble weight only applies through the quake-rumble route; with QZD's
    quake haptic level 0 every card gets the same pulse.
