# RSQ Grapple: where each README claim comes from

Commit read: b95023e8e (2026-11-27); the line numbers were moved, and the air spike's rows (H6a, H6b, H6c, L2a, L2b) added, for the code as changed after it on 2026-11-27 (the air spike back, the pull-to-you's code deleted). Paths are inside `Grapple/`. `C` is `zscript/rsqgr/core.zs`, `I` is
`zscript/rsqgr/input.zs`, `U` is `zscript/rsqgr/util.zs`, `CL` is `zscript/rsqgr/claw.zs`, `S` is
`zscript/rsqgr/service.zs`; other files are named in full. Each line number is the line that does the thing, not the
start of its function. `jp_original/` is not included by `zscript.txt` (lines 7 to 13 are the only includes) and is not
described.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Fire Hook is one key, `+rsqgr_hook`, which sends the local event `rsqgr_presskey` | KEYCONF.txt:6, KEYCONF.txt:7 | KEYCONF addmenukey, alias |
| H1 | The press packs the hand's pose and sends the network event `rsqgr_fire`; that event fires the claw | I:24, I:60, I:99, C:206 | RSQGR_Input.ConsoleProcess; SendPress; NetworkProcess; RSQGR_Core.Fire |
| H1 | The off hand is the hook hand unless Hook Hand is 1 | U:21, CVARINFO.txt:6 | RSQGR_Util.HookCtrl |
| H1 | The line is the one a gun in that hand fires (the engine's AttackDir / OffhandDir) | U:126, I:92 | RSQGR_Util.FireDir; RSQGR_Input.NetworkProcess |
| H1 | 40 units a tic, out to the range (default 780) | C:82, C:317, U:29, CVARINFO.txt:5 | RSQGR_Core.StepFlight; RSQGR_Util.Range |
| H1 | It bites the first monster, wall, floor or ceiling in its step | C:328, C:338, C:347 | RSQGR_Core.StepFlight |
| H2 | Letting go does nothing: only `rsqgr_presskey` is handled | I:20, KEYCONF.txt:8 | RSQGR_Input.ConsoleProcess |
| H3 | Aim dot while the hook is idle, with a real pose, Aim Dot on | I:116, I:118, CVARINFO.txt:8 | RSQGR_AimDot.WorldTick |
| H3 | Gold on a monster, cyan on the world | I:128, I:130 | RSQGR_AimDot.WorldTick |
| H4 | A world bite that is no ledge: the fling, toward a point 15 units short of the bite | C:508 | RSQGR_Core.ArriveWorld |
| H4 | The shove is added to your speed: flat distance / 12 toward it, height difference / 16 up | C:582, C:583 | RSQGR_Core.Fling |
| H4 | The claw stays shut 16 tics, then comes back | C:507, C:81, CL:147 | RSQGR_Core.ArriveWorld; RSQGR_Claw.Tick |
| H5 | Ledge: a wall bite no more than 40 units under the top of the floor behind it | C:549, C:77 | RSQGR_Core.LedgeSpot |
| H5 | Ledge: or a floor bite; either way the top is above what you can step up | C:557, C:561 | RSQGR_Core.LedgeSpot |
| H5 | Ledge: floor at that height and room for your height | C:564 | RSQGR_Core.LedgeSpot |
| H5 | You are carried up the face, then over the lip; it gives up after 45 tics | C:501, C:931, C:932, C:921 | RSQGR_Core.ArriveWorld; TickMantle |
| H6 | Every monster bite starts the pull to it | C:480 | RSQGR_Core.ArriveMonster |
| H6 | The pull's speed is distance / 12, at least 20 units a tic | C:704, C:76 | RSQGR_Core.StartPull |
| H6 | Arriving is the kick | C:757, C:761 | RSQGR_Core.TickPull |
| H6 | 30 damage, knocked back, stunned | C:803, C:56, C:811, C:817 | RSQGR_Core.Kick |
| H6 | Kick-off: 8 units a tic away and up about 1.5 m | C:878, C:872, C:58, C:60 | RSQGR_Core.KickOff |
| H6a | The air spike's test: not on the ground, both hands' downward speed at least 3 m/s | C:599, C:602, C:78, C:980, C:985 | RSQGR_Core.SpikeSwing; DownSpeeds; DownOf |
| H6a | It is tested every tic of the pull to a monster; a spike ends the pull before any kick | C:743 | RSQGR_Core.TickPull |
| H6a | You hang with no speed, the claw lets go | C:623, C:627, C:630, C:1078 | RSQGR_Core.StartSpike; WorldTick |
| H6a | The monster falls 30 units a tic to its floor (or for 105 tics), then the landing | C:652, C:653, C:654, C:79 | RSQGR_Core.TickSpike |
| H6a | Landing: blood x4, six flames, a ring; live monsters within 160 units shoved and stunned 15 tics | C:667, C:671, C:674, C:683, C:684, C:685, C:80, C:57 | RSQGR_Core.SpikeImpact |
| H6a | Then the hang ends and you fall | C:691 | RSQGR_Core.SpikeImpact |
| H6a | Both hands' pose is read every tic; three tics of it are needed for a speed | C:1072, C:956, C:972 | RSQGR_Core.WorldTick; ReadHands; HandVel |
| H6b | A kick on a monster that lives opens the window: that monster, 15 tics | C:860, C:57 | RSQGR_Core.Kick |
| H6b | The window is tested each tic nothing else plays; closed past its tic, when the monster is dead, and skipped while you hang for a claw | C:1083, C:641, C:642, C:643 | RSQGR_Core.WorldTick; KickSpike |
| H6c | On the ground the test answers no | C:599 | RSQGR_Core.SpikeSwing |
| H7 | The sky or a portal is a miss; the end of the reach is a miss; the claw comes back | C:356, C:367, C:438 | RSQGR_Core.StepFlight; Missed |
| H8 | A press with a claw already flying launches another (counted, not stopped) | C:205, C:206 | RSQGR_Core.Fire |
| H9 | A press while any bite plays (the pull, the lift, a spiked monster's fall) is ignored | C:183, C:185, C:186 | RSQGR_Core.Fire |
| H9 | A claw arriving while a bite plays lets go | C:449, C:450 | RSQGR_Core.Busy |
| H10 | Each kick adds one to the chain and names it in the word | C:797, C:832 | RSQGR_Core.Kick |
| H10 | Landing ends the chain and sets it to 0 | C:1185, C:298 | RSQGR_Core.AirTick; EndChain |
| H11 | A press in the air in a kick-chain hangs you: velocity zero, height held | C:212, C:217, C:223, C:1078, C:1079 | RSQGR_Core.Fire; WorldTick |
| H11 | The hang ends when the claw bites | C:237 | RSQGR_Core.WaitBit |
| H11 | No claw still flying: you drop and the chain is cancelled | C:255, C:258 | RSQGR_Core.CheckWait |
| H12 | A press while hanging reels the claws in and cancels the chain | C:180, C:270, C:275 | RSQGR_Core.Fire; CancelHang |
| H13 | Jump (a fresh press) in the air after a kick-off, once per kick-off | C:1163, C:1166, C:1168, C:880 | RSQGR_Core.AirTick; KickOff |
| H13 | Up to 1.5 m, less under a ceiling | C:1169, C:1172, C:61 | RSQGR_Core.AirTick |
| H13 | It marks up to 5 monsters in reach and in sight | C:1180, C:1004, C:1010, C:72 | RSQGR_Core.AirTick; PlaceMarkers |
| H14 | Aim Assist: only in the air, only with the option on | C:191 | RSQGR_Core.Fire |
| H14 | It turns the claw to the chosen monster's middle | C:198 | RSQGR_Core.Fire |
| H14 | Only monsters the double jump marked for you, inside 10 degrees, in sight, nearest the line | C:520, C:523, C:517, C:75, C:529, C:530 | RSQGR_Core.AssistTarget |
| H15 | Hooking a marked monster takes its mark off and asks for its time | C:472, C:1031, C:1032 | RSQGR_Core.ArriveMonster; MarkerHooked |
| H16 | Double Jump Always: in the air, not after a kick-off's own, not spent, not rising, not in water, flying or noclip, option on | C:1148, C:1149, CVARINFO.txt:14 | RSQGR_Core.AirTick |
| H16 | A fresh jump press: one rise of up to 1.5 m, spent until you land | C:1152, C:1154, C:1155, C:1157, C:1144 | RSQGR_Core.AirTick |
| H17 | Two-handing with Firing Line on: the main hand gun's line | U:109, U:113 | RSQGR_Util.FireDir |
| H17 | No Aim Trim while two-handing | U:32, U:33 | RSQGR_Util.AimTrimYaw; AimTrimPitch |
| H18 | Landing: chain ended, marks cleared, the plain double jump given back | C:1183, C:1185, C:296, C:1144 | RSQGR_Core.AirTick; EndChain |
| H19 | Dead: the bite is ended, the claw destroyed, the chain zeroed | C:1066, C:1067, CL:140 | RSQGR_Core.WorldTick; RSQGR_Claw.Tick |
| H20 | Hook Hand 1 reads the main hand's position and angles | U:21, U:23, U:81, U:86, MENUDEF.txt:37, MENUDEF.txt:73 | RSQGR_Util.HookCtrl; HookRaw; HandYaw; HandPitch |
| H21 | Aim Trim turns the line, clamped to 15 degrees each way | U:32, U:33, U:127, U:128, MENUDEF.txt:55, MENUDEF.txt:57 | RSQGR_Util.AimTrimYaw; AimTrimPitch; FireDir |
| H22 | Firing Line off: the hand's yaw and pitch; two-handing, the view | U:116, U:117, U:80, U:85 | RSQGR_Util.FireDir; HandYaw; HandPitch |
| H23 | Range is read for the claw, the dot, the marks and Aim Assist | C:190, I:123, C:995, C:527, MENUDEF.txt:65 | RSQGR_Core.Fire; RSQGR_AimDot.WorldTick; PlaceMarkers; AssistTarget |
| H24 | rsqgr_apex_hover: at the top of the rise a slow is asked, 35 or 25 tics; default off | C:1112, C:1118, C:1122, C:70, C:71, CVARINFO.txt:13 | RSQGR_Core.AirTick |
| H24 | No menu row names rsqgr_apex_hover | MENUDEF.txt:27, MENUDEF.txt:50 | the two pages (no such row in either) |
| H25 | A bare `netevent rsqgr_fire` fires along the live pose | I:77, I:96, I:97 | RSQGR_Input.NetworkProcess |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQ Wheel's service `wr_RigService` is asked "IsOpen"; 1 = the press is ignored | I:84, I:85 | RSQGR_Input.NetworkProcess |
| W2 | SlowMo: each kick asks "g2.slow" for 1.5 s less 0.3 s a link; none when that reaches 0 | C:852, C:853, C:854, C:62, C:63 | RSQGR_Core.Kick |
| W2 | SlowMo: the double jump adds 18 tics ("g2.addtime") | C:1177, C:64 | RSQGR_Core.AirTick |
| W2 | SlowMo: a hooked mark adds 9 or 18 tics | C:1032, C:1017, C:73, C:74 | RSQGR_Core.MarkerHooked; PlaceMarkers |
| W2 | SlowMo: "Chain Cancelled!" asked at the cancel and every tic of the fall | C:284, C:1108 | RSQGR_Core.ChainCancel; AirTick |
| W2 | SlowMo: full-speed movement asked ("g2.fullspeed") | C:950 | RSQGR_Core.FullSpeed |
| W2 | SlowMo: the spike's landing asks "g2.slam" | C:688 | RSQGR_Core.SpikeImpact |
| W2 | Without SlowMo the asks return -2 and nothing slows | U:154, U:155 | RSQGR_Util.SlowMo |
| W3 | Melee: "dizzy" for the stun's length | C:816, C:818, U:162 | RSQGR_Core.Kick; RSQGR_Util.Melee |
| W3 | Melee: its `RSQML_Burst4` drawn gold; without it, the particle puff | C:822, C:824, C:828, C:831 | RSQGR_Core.Kick |
| W4 | VisualRewards: the kick's word on a living monster; a world word on a kill | C:845, C:842 | RSQGR_Core.Kick |
| W4 | VisualRewards: the mark's held word; without it, four turning particles | C:1018, C:1052, CL:378 | RSQGR_Core.PlaceMarkers; TickMarkers; RSQGR_Fx.Marker |
| W5 | Miniboss: guarded = no chain link, knockback, stun or slow; the kick-off still happens | C:785, C:788, C:794, C:795, U:191 | RSQGR_Core.Kick; RSQGR_Util.MinibossGuarded |
| W5 | Miniboss: a guarded one is not spiked; the guarded bounce returns before the window is set | C:603, C:606, C:795, C:860 | RSQGR_Core.SpikeSwing; Kick |
| W7 | Brutal Doom VR Reloaded: the bore when its `RSQ_Muzzle` handler runs and Gun Bore is on | U:99, U:100, U:102, U:125 | RSQGR_Util.BoreActive; FireDir |
| W8 | Brutal Doom: only a live monster that counts as a kill (or a boss) is bitten; its `HeadHitbox` is not | U:276, U:277, U:278, U:280 | RSQGR_Util.Biteable |
| W9 | Gun Bonsai VR: only the shared menu code looks for it; the Grapple's pages have no gated row | zscript/rsqgr/rsmenu.zs:109, MENUDEF.txt:27, MENUDEF.txt:50 | RSQGR_RSMenu.GbLoaded |
| W10 | Grenade: "g2.neon" asked at the spike's landing, "safe", with your player number; -2 without RSQ Grenade | C:665, C:666 | RSQGR_Core.SpikeImpact |
| W10 | The landing itself deals no damage to the spiked monster (blood is drawn, no DamageMobj) | C:667 | RSQGR_Core.SpikeImpact |
| W11 | `RSQGR_Service` answers only requests that start "g2." | S:49, S:53 | RSQGR_Service.GetInt |
| W11 | The player's numbers, the events, the monster's records | S:61, S:62, S:63, S:65, S:81, S:89, S:94 | RSQGR_Service.GetInt; GetString |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | The only button read is jump (these are the only reads of the player's buttons) | C:1092, C:1152, C:1166 | RSQGR_Core.WorldTick; AirTick |
| L1 | No rope: a world bite is one added shove and a timed let-go | C:507, C:508 | RSQGR_Core.ArriveWorld |
| L2 | The hands are read every tic | C:1072 | RSQGR_Core.WorldTick |
| L2 | The one gesture test: both hands down, in the pull and in the window after a kick; no other code reads the hands' speed | C:743, C:643, C:602, C:964 | RSQGR_Core.TickPull; KickSpike; SpikeSwing; ReadHands (its debug line) |
| L2a | The spike's landing: no damage of its own | C:667, C:684, C:685 | RSQGR_Core.SpikeImpact |
| L2b | A monster at its floor lands on the spike's first tic of falling | C:652, C:653 | RSQGR_Core.TickSpike |
| L3 | No default bind: KEYCONF has a key section, a menu key and two aliases, and no defaultbind | KEYCONF.txt:5, KEYCONF.txt:6, KEYCONF.txt:7, KEYCONF.txt:8 | KEYCONF |
| L4 | Not bitten: the shooter, a player, a dead or unshootable thing, a non-monster, a friend, one that is neither a kill nor a boss | U:268, U:269, U:276, U:277 | RSQGR_Util.Biteable |
| L4 | What is not biteable is skipped by the claw's trace | CL:253 | RSQGR_Tracer.TraceCallback |
| L5 | Sky or portal: a miss | C:356 | RSQGR_Core.StepFlight |
| L6 | Both hands at one point: the press waits, at most 10 tics, then is dropped | I:23, I:29, I:36, I:15 | RSQGR_Input.ConsoleProcess; Collapsed; UiTick |
| L7 | No pose: the claw leaves from under the eyes, along the view; no dot | U:71, U:64, U:80, U:85, I:116 | RSQGR_Util.HandPos; ChestPos; HandYaw; HandPitch; RSQGR_AimDot.WorldTick |
| L8 | The pull ends if the monster is gone or dead | C:733, C:736 | RSQGR_Core.TickPull |
| L8 | The pull ends after 6 tics of no headway or 70 tics | C:765, C:768 | RSQGR_Core.TickPull |
| L9 | The rise is cut to the room under the ceiling, at launch and every tic | C:873, C:874, C:1135, C:1139, C:1155, C:1169 | RSQGR_Core.KickOff; AirTick |
| L10 | The dot needs the hook idle: no bite playing and no hang | I:118, C:444 | RSQGR_AimDot.WorldTick; RSQGR_Core.Idle |
