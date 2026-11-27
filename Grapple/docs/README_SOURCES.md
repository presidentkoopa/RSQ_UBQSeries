# RSQ Grapple: where each README claim comes from

Commit read: b95023e8e (2026-11-27). Paths are inside `Grapple/`. `C` is `zscript/rsqgr/core.zs`, `I` is
`zscript/rsqgr/input.zs`, `U` is `zscript/rsqgr/util.zs`, `CL` is `zscript/rsqgr/claw.zs`, `S` is
`zscript/rsqgr/service.zs`; other files are named in full. Each line number is the line that does the thing, not the
start of its function. `jp_original/` is not included by `zscript.txt` (lines 7 to 13 are the only includes) and is not
described.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Fire Hook is one key, `+rsqgr_hook`, which sends the local event `rsqgr_presskey` | KEYCONF.txt:6, KEYCONF.txt:7 | KEYCONF addmenukey, alias |
| H1 | The press packs the hand's pose and sends the network event `rsqgr_fire`; that event fires the claw | I:24, I:60, I:99, C:221 | RSQGR_Input.ConsoleProcess; SendPress; NetworkProcess; RSQGR_Core.Fire |
| H1 | The off hand is the hook hand unless Hook Hand is 1 | U:21, CVARINFO.txt:8 | RSQGR_Util.HookCtrl |
| H1 | The line is the one a gun in that hand fires (the engine's AttackDir / OffhandDir) | U:126, I:92 | RSQGR_Util.FireDir; RSQGR_Input.NetworkProcess |
| H1 | 40 units a tic, out to the range (default 780) | C:87, C:332, U:29, CVARINFO.txt:7 | RSQGR_Core.StepFlight; RSQGR_Util.Range |
| H1 | It bites the first monster, wall, floor or ceiling in its step | C:343, C:353, C:362 | RSQGR_Core.StepFlight |
| H2 | Letting go does nothing: only `rsqgr_presskey` is handled | I:20, KEYCONF.txt:8 | RSQGR_Input.ConsoleProcess |
| H3 | Aim dot while the hook is idle, with a real pose, Aim Dot on | I:116, I:118, CVARINFO.txt:10 | RSQGR_AimDot.WorldTick |
| H3 | Gold on a monster, cyan on the world | I:128, I:130 | RSQGR_AimDot.WorldTick |
| H4 | A world bite that is no ledge: the fling, toward a point 15 units short of the bite | C:523 | RSQGR_Core.ArriveWorld |
| H4 | The shove is added to your speed: flat distance / 12 toward it, height difference / 16 up | C:597, C:598 | RSQGR_Core.Fling |
| H4 | The claw stays shut 16 tics, then comes back | C:522, C:86, CL:147 | RSQGR_Core.ArriveWorld; RSQGR_Claw.Tick |
| H5 | Ledge: a wall bite no more than 40 units under the top of the floor behind it | C:564, C:78 | RSQGR_Core.LedgeSpot |
| H5 | Ledge: or a floor bite; either way the top is above what you can step up | C:572, C:576 | RSQGR_Core.LedgeSpot |
| H5 | Ledge: floor at that height and room for your height | C:579 | RSQGR_Core.LedgeSpot |
| H5 | You are carried up the face, then over the lip; it gives up after 45 tics | C:516, C:1018, C:1019, C:1008 | RSQGR_Core.ArriveWorld; TickMantle |
| H6 | Every monster bite starts the pull to it | C:495 | RSQGR_Core.ArriveMonster |
| H6 | The pull's speed is distance / 12, at least 20 units a tic | C:781, C:76 | RSQGR_Core.StartPull |
| H6 | Arriving is the kick | C:846, C:850 | RSQGR_Core.TickPull |
| H6 | 30 damage, knocked back, stunned | C:892, C:56, C:900, C:906 | RSQGR_Core.Kick |
| H6 | Kick-off: 8 units a tic away and up about 1.5 m | C:965, C:959, C:58, C:60 | RSQGR_Core.KickOff |
| H7 | The sky or a portal is a miss; the end of the reach is a miss; the claw comes back | C:371, C:382, C:453 | RSQGR_Core.StepFlight; Missed |
| H8 | A press with a claw already flying launches another (counted, not stopped) | C:220, C:221 | RSQGR_Core.Fire |
| H9 | A press while being pulled or lifted is ignored | C:191, C:193, C:194 | RSQGR_Core.Fire |
| H9 | A claw arriving while a bite plays lets go | C:464, C:465 | RSQGR_Core.Busy |
| H10 | Each kick adds one to the chain and names it in the word | C:886, C:921 | RSQGR_Core.Kick |
| H10 | Landing ends the chain and sets it to 0 | C:1318, C:313 | RSQGR_Core.AirTick; EndChain |
| H11 | A press in the air in a kick-chain hangs you: velocity zero, height held | C:227, C:232, C:238, C:1210, C:1211 | RSQGR_Core.Fire; WorldTick |
| H11 | The hang ends when the claw bites | C:252 | RSQGR_Core.WaitBit |
| H11 | No claw still flying: you drop and the chain is cancelled | C:270, C:273 | RSQGR_Core.CheckWait |
| H12 | A press while hanging reels the claws in and cancels the chain | C:189, C:285, C:290 | RSQGR_Core.Fire; CancelHang |
| H13 | Jump (a fresh press) in the air after a kick-off, once per kick-off | C:1296, C:1299, C:1301, C:967 | RSQGR_Core.AirTick; KickOff |
| H13 | Up to 1.5 m, less under a ceiling | C:1302, C:1305, C:61 | RSQGR_Core.AirTick |
| H13 | It marks up to 5 monsters in reach and in sight | C:1313, C:1137, C:1143, C:72 | RSQGR_Core.AirTick; PlaceMarkers |
| H14 | Aim Assist: only in the air, only with the option on | C:206 | RSQGR_Core.Fire |
| H14 | It turns the claw to the chosen monster's middle | C:213 | RSQGR_Core.Fire |
| H14 | Only monsters the double jump marked for you, inside 10 degrees, in sight, nearest the line | C:535, C:538, C:532, C:75, C:544, C:545 | RSQGR_Core.AssistTarget |
| H15 | Hooking a marked monster takes its mark off and asks for its time | C:487, C:1164, C:1165 | RSQGR_Core.ArriveMonster; MarkerHooked |
| H16 | Double Jump Always: in the air, not after a kick-off's own, not spent, not rising, not in water, flying or noclip, option on | C:1281, C:1282, CVARINFO.txt:16 | RSQGR_Core.AirTick |
| H16 | A fresh jump press: one rise of up to 1.5 m, spent until you land | C:1285, C:1287, C:1288, C:1290, C:1277 | RSQGR_Core.AirTick |
| H17 | Two-handing with Firing Line on: the main hand gun's line | U:109, U:113 | RSQGR_Util.FireDir |
| H17 | No Aim Trim while two-handing | U:32, U:33 | RSQGR_Util.AimTrimYaw; AimTrimPitch |
| H18 | Landing: chain ended, marks cleared, the plain double jump given back | C:1316, C:1318, C:311, C:1277 | RSQGR_Core.AirTick; EndChain |
| H19 | Dead: the bite is ended, the claw destroyed, the chain zeroed | C:1199, C:1200, CL:140 | RSQGR_Core.WorldTick; RSQGR_Claw.Tick |
| H20 | Hook Hand 1 reads the main hand's position and angles | U:21, U:23, U:81, U:86, MENUDEF.txt:37, MENUDEF.txt:75 | RSQGR_Util.HookCtrl; HookRaw; HandYaw; HandPitch |
| H21 | Aim Trim turns the line, clamped to 15 degrees each way | U:32, U:33, U:127, U:128, MENUDEF.txt:57, MENUDEF.txt:59 | RSQGR_Util.AimTrimYaw; AimTrimPitch; FireDir |
| H22 | Firing Line off: the hand's yaw and pitch; two-handing, the view | U:116, U:117, U:80, U:85 | RSQGR_Util.FireDir; HandYaw; HandPitch |
| H23 | Range is read for the claw, the dot, the marks and Aim Assist | C:205, I:123, C:1128, C:542, MENUDEF.txt:67 | RSQGR_Core.Fire; RSQGR_AimDot.WorldTick; PlaceMarkers; AssistTarget |
| H24 | rsqgr_apex_hover: at the top of the rise a slow is asked, 35 or 25 tics; default off | C:1245, C:1251, C:1255, C:70, C:71, CVARINFO.txt:15 | RSQGR_Core.AirTick |
| H24 | No menu row names rsqgr_apex_hover | MENUDEF.txt:27, MENUDEF.txt:50 | the two pages (no such row in either) |
| H25 | A bare `netevent rsqgr_fire` fires along the live pose | I:77, I:96, I:97 | RSQGR_Input.NetworkProcess |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQ Wheel's service `wr_RigService` is asked "IsOpen"; 1 = the press is ignored | I:84, I:85 | RSQGR_Input.NetworkProcess |
| W2 | SlowMo: each kick asks "g2.slow" for 1.5 s less 0.3 s a link; none when that reaches 0 | C:941, C:942, C:943, C:62, C:63 | RSQGR_Core.Kick |
| W2 | SlowMo: the double jump adds 18 tics ("g2.addtime") | C:1310, C:64 | RSQGR_Core.AirTick |
| W2 | SlowMo: a hooked mark adds 9 or 18 tics | C:1165, C:1150, C:73, C:74 | RSQGR_Core.MarkerHooked; PlaceMarkers |
| W2 | SlowMo: "Chain Cancelled!" asked at the cancel and every tic of the fall | C:299, C:1241 | RSQGR_Core.ChainCancel; AirTick |
| W2 | SlowMo: full-speed movement asked ("g2.fullspeed") | C:1073 | RSQGR_Core.FullSpeed |
| W2 | Without SlowMo the asks return -2 and nothing slows | U:154, U:155 | RSQGR_Util.SlowMo |
| W3 | Melee: "dizzy" for the stun's length | C:905, C:907, U:162 | RSQGR_Core.Kick; RSQGR_Util.Melee |
| W3 | Melee: its `RSQML_Burst4` drawn gold; without it, the particle puff | C:911, C:913, C:917, C:920 | RSQGR_Core.Kick |
| W4 | VisualRewards: the kick's word on a living monster; a world word on a kill | C:934, C:931 | RSQGR_Core.Kick |
| W4 | VisualRewards: the mark's held word; without it, four turning particles | C:1151, C:1185, CL:378 | RSQGR_Core.PlaceMarkers; TickMarkers; RSQGR_Fx.Marker |
| W5 | Miniboss: guarded = no chain link, knockback, stun or slow; the kick-off still happens | C:874, C:877, C:883, C:884, U:191 | RSQGR_Core.Kick; RSQGR_Util.MinibossGuarded |
| W6 | Accessibility: "vignette" asked while the hook carries you, strength by speed | C:862, C:1020, C:1262, U:196, U:203 | RSQGR_Core.TickPull; TickMantle; AirTick; RSQGR_Util.ComfortBySpeed; Comfort |
| W7 | Brutal Doom VR Reloaded: the bore when its `RSQ_Muzzle` handler runs and Gun Bore is on | U:99, U:100, U:102, U:125 | RSQGR_Util.BoreActive; FireDir |
| W8 | Brutal Doom: only a live monster that counts as a kill (or a boss) is bitten; its `HeadHitbox` is not | U:276, U:277, U:278, U:280 | RSQGR_Util.Biteable |
| W9 | Gun Bonsai VR: only the shared menu code looks for it; the Grapple's pages have no gated row | zscript/rsqgr/rsmenu.zs:109, MENUDEF.txt:27, MENUDEF.txt:50 | RSQGR_RSMenu.GbLoaded |
| W10 | Grenade: "g2.neon" is asked only in the spike's landing | C:744 | RSQGR_Core.SpikeImpact |
| W10 | Every monster bite goes to the pull, so no spike is started | C:494, C:495 | RSQGR_Core.ArriveMonster |
| W11 | `RSQGR_Service` answers only requests that start "g2." | S:44, S:48 | RSQGR_Service.GetInt |
| W11 | The player's numbers, the events, the monster's records | S:56, S:57, S:58, S:60, S:76, S:85, S:90 | RSQGR_Service.GetInt; GetString |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | The only button read is jump (these are the only reads of the player's buttons) | C:1225, C:1285, C:1299 | RSQGR_Core.WorldTick; AirTick |
| L1 | No rope: a world bite is one added shove and a timed let-go | C:522, C:523 | RSQGR_Core.ArriveWorld |
| L2 | The hands are read every tic | C:1204 | RSQGR_Core.WorldTick |
| L2 | The swing is tested only in the air hold, and the yank only with pickWin set or in Scorpion's hold; ArriveMonster clears pickWin and starts the pull | C:703, C:817, C:1031, C:494, C:495 | RSQGR_Core.TickAirHold; TickPull; TickScorp; ArriveMonster |
| L3 | No default bind: KEYCONF has a key section, a menu key and two aliases, and no defaultbind | KEYCONF.txt:5, KEYCONF.txt:6, KEYCONF.txt:7, KEYCONF.txt:8 | KEYCONF |
| L4 | Not bitten: the shooter, a player, a dead or unshootable thing, a non-monster, a friend, one that is neither a kill nor a boss | U:268, U:269, U:276, U:277 | RSQGR_Util.Biteable |
| L4 | What is not biteable is skipped by the claw's trace | CL:253 | RSQGR_Tracer.TraceCallback |
| L5 | Sky or portal: a miss | C:371 | RSQGR_Core.StepFlight |
| L6 | Both hands at one point: the press waits, at most 10 tics, then is dropped | I:23, I:29, I:36, I:15 | RSQGR_Input.ConsoleProcess; Collapsed; UiTick |
| L7 | No pose: the claw leaves from under the eyes, along the view; no dot | U:71, U:64, U:80, U:85, I:116 | RSQGR_Util.HandPos; ChestPos; HandYaw; HandPitch; RSQGR_AimDot.WorldTick |
| L8 | The pull ends if the monster is gone or dead | C:810, C:813 | RSQGR_Core.TickPull |
| L8 | The pull ends after 6 tics of no headway or 70 tics | C:854, C:857 | RSQGR_Core.TickPull |
| L9 | The rise is cut to the room under the ceiling, at launch and every tic | C:960, C:961, C:1268, C:1272, C:1288, C:1302 | RSQGR_Core.KickOff; AirTick |
| L10 | The dot needs the hook idle: no bite playing and no hang | I:118, C:459 | RSQGR_AimDot.WorldTick; RSQGR_Core.Idle |
