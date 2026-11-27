# Rig check: RSQ Controls (2026-11-27, agent A)

Rig: `rig2` (menus reachable: the fake A / B buttons, the right stick, and `rig_key <key>` real key events), `qz_hz 35`.
`RSQ_Controls.pk3` from `rsq_ubqseries/pk3/` (built 12:30), alone (C0-C2) or with `RSQ_TacticalRig` (C3-C5), Freedoom 2.
C1 started from the rig's own ini (never asked); its saved ini (`logs/A_C1_saved_qzdoom.ini`) was the start of C2, C3 and C5.
The probe logs every menu change (`AP MENU <class> <menu> sel <row> gametic`). Logs and scripts:
`design/rigcheck_2026-11-27/logs/A_C*.log`, `A_C*_script.txt`. Frames: `frames/Controls/`. Rig only, not headset.

**Load:** `RSQ_Controls.pk3` compiles and boots (A_C0.log: no script error). (An earlier run by another agent at 12:29,
`rigdata/logs/lc2_Controls.log`, failed with `Unknown identifier 'BINDS'` in howto.zs:1180-1182; the pk3 in the repo was rebuilt
at 12:30 and that error is gone.)

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | First start: about a second in, a screen offers RSQoopaControls; Yes writes every bind, double bind and setting; No changes nothing; Back is No (16) | WORKS | A_C1.log:108 (`RSQCT_FirstRun` opened at gametic 34, Yes preselected, sel 8), 148 (A answers), 176 (`vr_crouch_use_button` false); saved ini: all 34 lines of RSQoopaControls.cfg present, no key outside the file changed (compared by script against the rig's starting ini); c1.jpg (the screen) | Back closed the screen and changed no key (A_C4.log:175-194), but there the binds already equalled the layout, so "No changes nothing" is not separately proven |
| 2 | Start again: no screen (18) | WORKS | A_C2.log:75-135 (no menu until F1; `rsqct_layout_asked` 1129514440 kept) | |
| 3 | F1 (or the row) opens How To Play on CONTROLS: LEFT / RIGHT CONTROLLER panels, press / double / right grip + press, dashes (19) | WORKS | A_C1.log:179-184 (F1 key -> `RSQCT_HowToMenu`); c1.jpg (the CONTROLS tab, both panels, the three columns, dashes) | |
| 4 | Left / right on the page: next tab CONTROLS, BODY, one per mod (20) | WORKS | c3.jpg g42 -> g70 (the right stick pushed right: CONTROLS -> BODY; tabs CONTROLS, BODY, TACTICAL RIG with the Rig loaded) | The left stick and `rig_key RightArrow` did not move it further in that run (frames g84-g113 stay on BODY); the right stick is the Quest's way and works |
| 5 | Left-handed scheme: the LEFT panel shows the main hand's buttons, X / Y for A / B, LEFT GRIP + PRESS (21) | WORKS | c4.jpg g90 (`vr_control_scheme 10`: LEFT CONTROLLER lists TRIGGER main-hand fire, GRIP modifier, X use / slot 3, Y recenter torso; column "LEFT GRIP + PRESS") | |
| 6 | Use RSQoopaControls row, then Yes: every button set, natural crouch on, nothing else (22) | WORKS | A_C3.log:249-263 (Options row reached with the stick, sel 1), 275 (`MessageBoxMenu`: "Do you really want to do this?", c3.jpg g175), 299-322 (A = Yes: the unbound Tab / Pad_B and the changed Pad_X are back to `+wr_wheel`, `rsqtr_recenter`, `ssq_draw`) | Was NEEDS MENU; real verdict on rig2 |
| 7 | `exec RSQoopaControls.cfg`: the same lines (23) | WORKS | A_C4.log:79-113 (`+wait 1;exec .../pk3/RSQoopaControls.cfg` on the command line: all 27 binds, 6 double binds and `vr_crouch_use_button false` read back) | |
| 8 | SHOW ME under a body move: menus close, the ghost hand does the move (24) | CAN'T TEST | A_C5.log:159-163 (SHOW ON MY BODY on the BODY tab: menus closed, `T_GHOST show on my body: MOUTH`, 21 mirror markers); c4.jpg (the MOUTH list has no SHOW ME row) | The BODY tab opened on MOUTH, whose list has no SHOW ME; a SHOW ME row (seen under L SHOULDER, c3.jpg) was not reached in this pass |
| 9 | New game: ~5 s into the first map, one line "HOW TO PLAY: OPTIONS > RADIANT SILVERGUN OPTIONS" (25) | WORKS | A_C2.log:251-253 (at map tic 175) | Without VisualRewards: a plain print, as the README says |

Note (not a README claim): the menu button / Escape key (`rig_key Escape`) did not close the How To page (A_C3.log:207, A_C4.log:223, the
page stayed open); B (Back) closes it (A_C2.log:433).
