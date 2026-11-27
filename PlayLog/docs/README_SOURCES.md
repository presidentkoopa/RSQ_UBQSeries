# RSQ PlayLog: where each README claim comes from

Commit read: a283738bb (2026-11-27). Paths are inside `PlayLog/` unless they start with another mod's folder. `G` is
`zscript/rsqpl/log.zs`, `S` is `zscript/rsqpl/handsync.zs`; other files are named in full. Each line number is the line
that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Record Play Log is rsqpl_on, off by default; every line checks it | MENUDEF.txt:3, MENUDEF.txt:10, CVARINFO.txt:2, G:44 | RSQPL_Log.On |
| H2 | Start Log File runs `logfile rsqplay.txt`; the tip about the folder and starting over | MENUDEF.txt:11, MENUDEF.txt:12 | MENUDEF |
| H3 | Stop Log File runs `logfile` | MENUDEF.txt:14 | MENUDEF |
| H4 | MAP: lump, title, monsters, skill; not on a saved game | G:58, G:59 | RSQPL_Log.WorldLoaded |
| H5 | END: seconds, kills of total, deaths | G:65, G:66, G:134 | RSQPL_Log.WorldUnloaded; WorldThingDied |
| H6 | SWING: a hand against the body; starts at 1.0 m/s, ends after 2 tics under 0.6; peak, tics, ahead, up, the hand's weapon, throw-fast at 2.2 | G:24, G:25, G:26, G:77, G:80, G:85, G:89, G:93, G:94, G:98, G:99, G:100, G:102 | RSQPL_Log.WorldTick |
| H6 | Only with VR hands and a live pawn | G:73, G:74 | RSQPL_Log.WorldTick |
| H7 | WRIST: the off hand within 0.8 m of the eye; RSQG_Service "inspect", "pulse", "pose.why" for hand 1; every 7 tics or on change | G:75, G:110, G:112, G:113, G:117, G:118, G:120, G:122, G:123 | RSQPL_Log.Wrist |
| H8 | KILL: a monster whose target is your pawn; class, spawn health, the inflictor else the main hand's weapon, metres, damage type | G:139, G:141, G:142, G:143, G:145, G:146 | RSQPL_Log.WorldThingDied |
| H9 | HURT: your player damaged: amount, source, type, health | G:151, G:153, G:154 | RSQPL_Log.WorldThingDamaged |
| H10 | DIED: your player: inflictor and target | G:132, G:135, G:136 | RSQPL_Log.WorldThingDied |
| H11 | FPS each second (draws, longest wait); HITCH at 50 ms or more, at most 3 a second | G:27, G:160, G:167, G:168, G:170 | RSQPL_Log.RenderOverlay |
| H12 | Reset All resets rsqpl_on | MENUDEF.txt:19 | MENUDEF |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQG_Service by exact class name: "inspect", "pulse", "pose.why"; without it the loop finds nothing and no line is written | G:113, G:115, G:117, G:118, G:123, Accessibility/zscript/rsqg/gestures.zs:965 | RSQPL_Log.Wrist |
| W2 | Gun Cards' RSQGC_GCopyService answers the same three requests; it is never asked here | GunCards/zscript/rsqgc/gestcopy.zs:408, GunCards/zscript/rsqgc/gestcopy.zs:418, GunCards/zscript/rsqgc/gestcopy.zs:419, GunCards/zscript/rsqgc/gestcopy.zs:427, G:117 | (Gun Cards' service); RSQPL_Log.Wrist |
| W3 | Weapons and monsters named by class | G:101, G:135, G:145 | RSQPL_Log.WorldTick; WorldThingDied |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Every action is a console line | G:59, G:65, G:100, G:122, G:135, G:145, G:153, G:167, G:170 | RSQPL_Log (all) |
| L2 | The file is the engine's logfile of the console | MENUDEF.txt:12 | MENUDEF |
| L3 | One FPS line a second (about 48 characters); WRIST every 7 tics at most when unchanged | G:168, G:170, G:120 | RSQPL_Log.RenderOverlay; Wrist |
| L4 | Only the console player | G:72, G:132, G:140, G:151 | RSQPL_Log.WorldTick; WorldThingDied; WorldThingDamaged |
| L5 | No hands or a dead pawn: no SWING or WRIST | G:73, G:74, G:75 | RSQPL_Log.WorldTick |
| L6 | Over 30 m/s in a tic skipped | G:86 | RSQPL_Log.WorldTick |
| L7 | A kill only when the monster's target was you | G:141 | RSQPL_Log.WorldThingDied |
| L8 | mapStart and deaths are reset before the saved-game test | G:55, G:56, G:58 | RSQPL_Log.WorldLoaded |
| L9 | The page is added to the main Options menu; the Test and Debug page holds one blank line | MENUDEF.txt:1, MENUDEF.txt:3, MENUDEF.txt:25 | MENUDEF |
| L10 | No KEYCONF | zscript.txt:6, zscript.txt:7, MAPINFO.txt:4 | (the mod's lumps: no KEYCONF) |
