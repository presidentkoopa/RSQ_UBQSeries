# Rig check: RSQ PlayLog (2026-11-27, agent A)

Rig: `rig2`, `qz_hz 35`, Freedoom 2 + `TestRig/maps/rig01.wad`; `RSQ_PlayLog` (+ `RSQ_GunCards` in P1 for the WRIST lines)
from `rsq_ubqseries/pk3/`. Menus were driven with the fake A button and `rig_key Axis4Minus` (the stick's menu-down key);
the probe logs each menu change (`AP MENU`). Logs and scripts: `design/rigcheck_2026-11-27/logs/A_P1..P4.log`,
`A_P*_script.txt`, and the file Start Log File wrote: `logs/A_P3_rsqplay.txt`. Rig only, not headset.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | Record Play Log on (Options > RSQ Play Log): lines from now on (16) | WORKS | A_P1.log:88 (off), 92 (`RSQPL_Menu`, row 0), 136-137 (A on the row: `rsqpl_on` true), then `RSQLOG` lines | |
| 2 | Start Log File: `logfile rsqplay.txt`, the console copied into it (17) | WORKS | A_P3.log:113-122 (row 1, then a confirmation box, A = yes); A_P3_rsqplay.txt:1, 18 (`Log started`, the echo `LINE_INSIDE_RSQPLAY` in the file) | The row asks "are you sure" first (a SafeCommand); the README does not say so |
| 3 | Stop Log File: copying stops (18) | WORKS | A_P3_rsqplay.txt:24-33 then last line `Log stopped`; the next echo (`LINE_AFTER_STOP`) is in no file | Also asks for confirmation first |
| 4 | Start a map: MAP line (19) | WORKS | A_P1.log:146 (`MAP MAP01 "Hydroelectric Plant" monsters 0 skill 2`) | Saved-game load not tried |
| 5 | Leave a map: END line (20) | WORKS | A_P1.log:656 (`END MAP01 11.7 s, kills 1 of 2, deaths 0`) | |
| 6 | Swing faster than 1.0 m/s then slow: SWING with hand, speed, tics, ahead/up, weapon, throw-fast at 2.2 (21) | WORKS | A_P1.log:233 (1.29 m/s, no throw-fast), 252 (`SWING main 3.60 m/s over 6 tics, ahead 1.00 up 0.00, holding Pistol, throw-fast`) | |
| 7 | Off hand within 0.8 m of the eyes: WRIST every 7 tics and on change, with why each pose is not met (22) | WORKS | A_P1.log:122, 130, 149, 157 ... (every 7 tics, watch / pulse state and the reasons), 275 (a new line on the change of pose) | With RSQ Gun Cards loaded |
| 8 | Kill a monster: KILL line (23) | WORKS | A_P1.log:423 (`KILL DoomImp (60 health) with BulletPuff at 5.4 m, Hitscan`) | |
| 9 | Get hurt: HURT line (24) | WORKS | A_P2.log:204 (`HURT 9 by DoomImp (None), health 91`) | |
| 10 | Die: DIED line (25) | WORKS | A_P2.log:259-261 (`DIED by DoomPlayer (DoomPlayer)` after `kill`) | Death by a monster not run |
| 11 | FPS once a second; HITCH for waits of 50 ms+ (26) | WORKS | A_P1.log:190 (`FPS 36 draws, longest wait 31 ms`), 430 (`HITCH 253 ms`), 454 (`FPS 28 draws, longest wait 253 ms`) | |
| 12 | Reset All: Record Play Log back to Off (27) | WORKS | A_P4.log:92 (on), 146 (row 5), 156 (confirmation box), 191 (`rsqpl_on` false) | Was NEEDS MENU; real verdict on rig2 |
