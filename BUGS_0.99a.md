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

## DistanceGrab
14. "Grab Main Hand" / "Grab Off Hand" bind rows and the G/H binds only work with Button Fallback on (off by
    default); neither menu nor bind rows say so.
15. Main-hand walk-up grab reads raw key 446, which per near.zs is only sent with `vr_secondary_button_mappings` off;
    with it on, the walk-up grab probably never fires. Measure.
16. KEYCONF comment names the section "Distance Grab" (it is "RSQ Distance Grab"); `rsqdg_path_tmin/tmax`,
    `air_flutter`, `air_maxtics`, `keys_main/off` have no rows despite "every cvar keeps its row".
17. Dead code: Gun Bonsai VR has no grab tree any more; Dead Eye, Heavy Lift, Straight Pull, Body Shield 3 can never
    run. Remove or leave documented.

## Grapple
18. With Gun Bonsai VR loaded, the hook does nothing until the Grapple node is learned, with no on-screen message.
    Add a short message ("Learn Grapple in Gun Bonsai").
19. Rope Climbing, Two Hands, Mantle, Wraps Corners, Slack Rope Lets Go, ledge hop, tap-to-let-go only work in Rope
    mode or with Swing on; Calm Swing only with Swing on. The menu doesn't say so (menu redesign).
20. `rsqgr_whip_above`, `rsqgr_yank_radius`, `rsqgr_yank_height` have no rows; CREDITS.txt carries a "SLATED FOR
    REPLACEMENT" dev note.

## Gestures
21. "Thrust and Pull Events" gates punch/shove/thrust/pull events no RSQ mod listens to (only Melee's two-hand
    event is used): no effect anywhere.
22. Loaded alone it shows nothing (Show Gesture Names, on by default, has nothing to show).
23. RSQ_Gestures.pk3 still carries the old README: rebuild once the hands lane's Gestures changes are committed.

## Gun Bonsai VR
24. Ground Pound, Clear Out, Absorb and Release are offered without RSQ Gestures and then do nothing (tooltips say
    "Needs RSQ Gestures"); Taunt checks correctly (up_fists.zs ~90, ~106, guard nodes ~437). Gate like Taunt.
25. The Force hand's records earn XP but every Force node is offered only on saber records: a Force-hand level-up can
    only offer generic upgrades. Decide (owner).
26. The binding warning fires at Gun Bonsai's default (mode 1); stale-record pruning runs only in mode 0.
27. Dead Tuning rows: First Star After / Star Every (Star Punch no longer offered).
28. No menu rows: dual HUD on/off, which hand a single HUD follows, per-hand HUD positions/mirroring (menu redesign).
29. Skins don't mirror for left-handers while Gun Bonsai's gauges do. Check visually.
30. COPYING.md ends mid-sentence (Sungraphica hud.xcf line). Old `readme.txt` still ships in the pk3. zscript.txt
    comment says nine replaced files; there are ten.
31. Uncapped nodes: One-Two, Lunge, Executioner, Adrenaline. Decide.

## VisualRewards
32. JFO Metal (default number font) has no reuse licence (same JFO question).
33. The CRIT word can only show when another mod asks; none does (Critical Shots is after 2.0).
34. CVARINFO comments for Number Colour / Damage Type Colours are stale (they apply only with Hit Colours = damnums').
35. Kill Rewards: with Bits Fly to Me at 0 (default), a VR player standing still never picks bits up. Consider a
    non-zero default (owner).

## Repo hygiene
36. `git pull --rebase --autostash` in the shared checkout can race another lane's write and leave the tree
    mid-rebase (happened once 11-03, restored by hand; backup ref `refs/backup/readme-lane-autostash` can go).

## Accessibility
37. "Menus: Simple" uses a stale list (rsqa_core.zs `RSQA_MenuMode` FRONT, `Niche()` SERIES): with Simple on,
    VisualRewards loses HP Bars / Damage Numbers / Level-Up / Tuning (only Kill Rewards + Reset All left); Melee is
    listed as `RSQ_MeleeOptions` / `rsq_melee` (real page `RSQML_Options`), so Simple skips it; Miniboss, Whip,
    Wheel, Grenade, Glow In The Dark, FnF, Gestures, Gun Cards missing. Fix the lists.
38. The shared rsmenu template's `Rank()` also names `RSQ_MeleeOptions`: Melee sorts as "unknown" on Radiant
    Silvergun Options (cosmetic; the template is copied into every mod).

## Miniboss
39. CVARINFO comment on `rsqmb_boss_rewards` still says Gun Bonsai VR's kill rewards (now VisualRewards).

## ShieldSaw
40. No CREDITS.txt; the pk3 ships id Software's ripped mesh (licence note needed).
41. Stale comments: state.zs input summary (lock-on/throw now Use / off trigger); CVARINFO `ssq_perfect` "faster
    return" (really 1.6x faster turned shot + doubled shove).
42. RSQ_ShieldSaw.pk3 still carries the old README: rebuild once the hands lane's ShieldSaw changes are committed.

## TacticalRig
43. SlowMo files the cigarette's slow motion as "automatic", not "smoke", whenever Gun Bonsai VR's Smoker is level 1+
    (clock.zs ~358 matches only length == Slow Motion Seconds x 1000; cig.zs SmokeSecs adds 2 s per level). Smoke
    rules and switch don't apply. Fix: tag the pulse by name instead of by length.
44. Guns from packs other than Brutal Doom / BD22 VR / RSQ Saber are never drawn on the body (rig.zs DrawMarkers hides
    anything not in RSQTRFIT); fit.zs header claims a pickup-size fallback that no longer exists; Flip These Guns /
    Stored Gun Turn do little for them. Decide: restore the fallback or fix the comments.
45. Menu leftovers: unused OptionValue "RSQTR_Pairs"; `rsqtr_debug_throw` missing from Reset All; stray comment text
    on `rsqtr_icon_turn` in CVARINFO; Body Turn Angle/Delay only act with "Torso Catches Up With Head" on.
46. cig.zs header still says "Rig only, not headset-confirmed" (owner confirmed every mod in the headset 11-03).

## FnF
47. "Start With ... and after dying": the starting flares are given once per pawn (RSQFF_Given is UNCLEARABLE), so a
    respawn doesn't refill the pocket, contrary to the CVARINFO comment / old menu wording. Decide which is intended.
48. The chest pocket has no marker (only a sound/buzz on a good take, "No flares left" when empty).
49. `rsqff_keys_off` is in Reset All with no menu row; burn.zs comment names a nonexistent `rsqff_husk` (fixed 10 s);
    handler.zs carries an old "rig only" label.

## Grenade
50. Shoot Thrown Grenades: any player's shot sets off anyone's thrown grenade (co-op); not stated. Decide/document.
51. Off-hand grenade path (ring pulled with the main trigger, kind change on off-hand alt fire) follows from the code
    but is untested on the rig.

## Melee
52. No Melee Hands by default: Start With Melee Hands and Slappers Only are off and nothing else gives the gloves,
    so on defaults punches, swat, Hadouken, bullet-meeting and Headlock punches can't be used. Owner: default on?
53. No menu rows: off-hand grip keys, re-hit wait, uppercut rise, reach pad (in Reset All).
54. Shoot Thrown Grenades: a hitscan is tested against BOTH hands' rays (the shot doesn't say which hand fired), so
    a pointing hand that didn't fire can set a grenade off. Predates 11-03.
