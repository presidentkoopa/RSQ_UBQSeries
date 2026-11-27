# RSQ Saber: where each README claim comes from

Commit read: 692b3e53c (2026-11-27); `QuestSaber/` is unchanged at be048d6e1, the commit the README is stamped with and
the one other mods' lines are cited at. Paths are inside `QuestSaber/` unless they start with another mod's folder. `Z`
is `zscript.txt`, `HIP` is `zscript/ubqs_hip.zs`, `FL` is `zscript/ubqs_fling.zs`; the lumps are named in full
(`CVARINFO`, `MENUDEF`, `KEYCONF`: they have no extension). Each line number is the line that does the thing, not the
start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H0 | Each saber is its class's hand; the fire and alt fire bits follow that hand | Z:1232, Z:1233, Z:738, Z:1113 | UBQS_SaberBase.DoEffect; A_UBHold; TickFireLatch |
| H0 | No hand position: not lit, and DoEffect stops before the hum, the cut and the blocks | Z:1047, Z:1051, Z:1305 | UBQS_SaberBase.HandLive; Lit; DoEffect |
| H1 | Every 5 tics, while Sabers is on and Slappers Only is not, a player without the saber is given it when Start With Saber is on; the Force item with it | Z:7024, Z:7032, Z:7033, Z:7036, Z:7037, Z:7065, Z:7095, CVARINFO:8, CVARINFO:66 | UBQS_Bridge.WorldTick |
| H1 | Slot 1 | Z:463, KEYCONF:1 | UBQS_SaberBase Default; KEYCONF AddSlotDefault |
| H2 | Raised; the Ready state runs four ignition frames of 2 tics; lit and the ignition sound once a draw; then the hum loop | Z:3372, Z:3383, Z:3386, Z:702, Z:704, Z:1324, Z:1327 | UBQS_SaberBase states Select, Ready; A_UBOn; DoEffect |
| H3 | The second saber is given while Dual Sabers allows it, and brought up in an off hand that is empty or holds a filler, unless the main weapon is two-handed | Z:7083, Z:7085, Z:7110, Z:7147, Z:7158, Z:7161, Z:7166, Z:3492, CVARINFO:9, MENUDEF:132 | UBQS_Bridge.WorldTick; UBQS_SaberOff Default |
| H4 | The saber just in the main hand: an off hand that is empty, RSQ_Hands or a Melee glove gets the Force hand, when no second saber is due there | Z:6979, Z:6984, Z:6985, Z:6989, Z:6937, Z:6934 | UBQS_Bridge.ForceCombo; ForceHandIsEmpty |
| H4 | The main hand not the saber: a Force hand in the off hand is replaced the same tic; only with Force Only With Saber | Z:6958, Z:6961, Z:6972, Z:6892, Z:6901, CVARINFO:87 | UBQS_Bridge.ForceCombo; ForceOnlyWithSaber; SaberMain |
| H5 | The tip's travel this tic, the body's own taken out; at Swing to Cut (8) or more it cuts | Z:1360, Z:1363, Z:1395, Z:1400, CVARINFO:38, MENUDEF:181 | UBQS_SaberBase.DoEffect |
| H5 | The cut's damage call, the hit sound at the body, one buzz a swing; the whoosh at real speed, 8 tics apart | Z:2200, Z:2225, Z:2235, Z:1404, Z:1406 | UBQS_SaberBase.CutLine; DoEffect |
| H6 | Damage x clamp(speed / 20, 0.5, 2); Damage 30, the menu 15 to 60 | Z:2105, Z:2107, Z:2187, CVARINFO:19, MENUDEF:148 | UBQS_SaberBase.CutLine |
| H6 | The shove along the swing, scaled by 100 / mass | Z:2219, Z:2221 | UBQS_SaberBase.CutLine |
| H7 | The same monster again after 8 tics; a 3 unit pad; a sight check from the owner | Z:2103, Z:2104, Z:2186 | UBQS_SaberBase.CutLine; CutCandidate |
| H8 | The decaying sum (x0.75 a tic) counted at 0.6: a steady speed s gives 2.4 s, so 3.4 reaches 8; the whoosh needs the real speed | Z:1371, Z:1372, Z:1400, Z:1404 | UBQS_SaberBase.DoEffect |
| H9 | Stab: the hand's step within 30 degrees of the blade and the blade turned under 30; the first body only; x1.5; no shove | Z:2079, Z:2080, Z:2142, Z:2173, Z:2187, Z:2219 | UBQS_SaberBase.CutLine |
| H10 | A missile whose path (lookahead tics of its velocity) comes within its radius + Block Width of the swept blade is turned | Z:2323, Z:2324, Z:2344, Z:2353, Z:2354, CVARINFO:42, CVARINFO:79, MENUDEF:205, MENUDEF:207 | UBQS_SaberBase.Deflect |
| H10 | 1.2 times its speed; aim 1: the monster nearest the gaze within 14 degrees, else where you look; it becomes yours | Z:2366, Z:2369, Z:2432, Z:2434, Z:2436, Z:2449, CVARINFO:77, MENUDEF:183 | UBQS_SaberBase.BatBack |
| H11 | Every monster hitscan is tested before it is traced; the ray within Block Width of the swept blade, in front of you, is stopped | Z:6755, Z:6758, Z:6775, Z:2828, Z:2840, Z:2842 | UBQS_Bridge.WorldHitscanPreFired; UBQS_SaberBase.StopsHitscan |
| H11 | The return bolt: UBQS_Bolt at the shooter, 20 damage, speed 60 | Z:2765, Z:2775, Z:356, Z:355 | UBQS_SaberBase.BlockFx; UBQS_Bolt Default |
| H12 | Melee: the line from the attacker's middle to yours within Block Width of the blade; damage 0; pain and a push; the block's bolt | Z:2650, Z:2653, Z:2573, Z:2666, Z:2674, Z:2687, Z:2688, Z:2690 | UBQS_SaberBase.ModifyDamage; BladeInPath |
| H13 | A missile or a blast that reached you: tested on contact; the missile itself is sent back and flies on through you; a blast is stopped | Z:2635, Z:2637, Z:2906, Z:2913, Z:2915, Z:2894, Z:2896 | UBQS_SaberBase.ModifyDamage; ContactBlock |
| H14 | Parry: the tip's step 6 or more, at least 0.3 into the shot; gain up to 2; double knock; higher clash; starburst; the bolt's speed and the melee push times the gain | Z:2703, Z:2712, Z:2737, Z:2734, Z:2756, Z:2775, Z:2688 | UBQS_SaberBase.ParryGain; BlockFx; ModifyDamage |
| H15 | A trace along the blade that meets a wall or a flat: the burn sound, 5 tics apart; on a wall the scorch decal and an ember | Z:2931, Z:2934, Z:2937, Z:2938, Z:2939, Z:2944, Z:2945, DECALDEF:1 | UBQS_SaberBase.Burn |
| H16 | Contact at 3.5 units, not with both nearest points within 0.75 of the emitters; clash, crack, lock loop, starburst, double knock | Z:3102, Z:3103, Z:3110, Z:3142, Z:3148, Z:3149, Z:3150, Z:3153, Z:3162 | UBQS_SaberBase.Clash |
| H16 | Held: the loop swells, a flicker and a buzz every other tic; the lock ends more than 4 tics after the last touch; only the main saber runs it | Z:3167, Z:3171, Z:3176, Z:3117, Z:1419 | UBQS_SaberBase.Clash; DoEffect |
| H17 | Guarding for 2 tics after a touch; from within 100 degrees of the body's yaw and with either blade in the attack's path: damage 0 | Z:3126, Z:2961, Z:2588, Z:2593, Z:2603, Z:2605, Z:2606, Z:2608 | UBQS_SaberBase.Clash; Guarding; ModifyDamage |
| H18 | Fire held paints: every 3 tics the monster nearest the hand's line inside 14 degrees and 1536 units, in sight; a lock mark and a buzz; up to Lock On Targets | Z:3396, Z:758, Z:818, Z:826, Z:827, Z:834, Z:843, Z:848, Z:849, Z:850, Z:793, CVARINFO:20, MENUDEF:189 | UBQS_SaberBase.A_UBHold; Paint; MostLocks |
| H18 | The mark's ring is shaded with the saber's blade colour | Z:4646 | UBQS_LockMark.Follow |
| H19 | Let go with marks: thrown when the peak is 1.0 m/s or more and within 60 degrees of the first live mark | Z:745, Z:753, Z:998, Z:999, FL:9, FL:10, FL:33 | UBQS_SaberBase.A_UBHold; MarkedRelease; UBQS_Fling.TowardMark |
| H19 | The marks become the route; each in turn; the first leg turns at most 9 degrees a tic; then home | Z:3217, Z:4253, Z:4386, FL:11, FL:43 | UBQS_SaberBase.Throw; UBQS_Thrown.Launch; Tick; UBQS_Fling.Turn |
| H20 | Not thrown: the marks kept 35 tics, cleared after; a new press inside that keeps them | Z:753, Z:1281, Z:732 | UBQS_SaberBase.A_UBHold; DoEffect; A_UBHoldBegin |
| H21 | Nothing marked: thrown when the peak (the fastest 2-tic window of the last 7 samples) reaches Throw Speed and the motion is within dot 0.55 of where you look | Z:754, Z:1011, Z:1018, Z:949, Z:976, Z:982, CVARINFO:82, MENUDEF:209 | UBQS_SaberBase.A_UBHold; ThrowRelease; ThrowPeak |
| H21 | 60% the arm's motion, 40% the hand's aim; 14 + 30k units a tic and range 512 x (0.8 + 0.8k), k from 2.2 to 5.0 m/s | Z:3241, Z:3242, Z:3243, Z:3244, Z:3245, FL:6 | UBQS_SaberBase.Throw |
| H22 | Slower, or not toward the view: nothing but the 35 tic keep | Z:754, Z:755 | UBQS_SaberBase.A_UBHold |
| H23 | The wrist's roll under 45 or over 135 degrees: end over end; else flat | Z:3223 | UBQS_SaberBase.Throw |
| H24 | The second blade lit on every throw | Z:3215 | UBQS_SaberBase.Throw |
| H24 | Cuts within the blade's length, 1.5 x Damage, each monster 10 tics apart; turns missiles in reach; scorches | Z:4555, Z:4562, Z:4566, Z:4569, Z:4587, Z:4591, Z:4531, Z:4537 | UBQS_Thrown.SpinCut; SpinDeflect; BurnAlong |
| H24 | A wall ends a free throw; on a route it goes through | Z:4373, Z:4389, Z:4392 | UBQS_Thrown.Tick |
| H25 | Home at 30 units a tic with no clipping; caught inside 26 units once 17 tics old; lit, the catch sound | Z:4414, Z:4418, Z:4413, Z:3259, Z:3264 | UBQS_Thrown.Tick; UBQS_SaberBase.Caught |
| H25 | The range run out, or 12 seconds out: home | Z:4375, Z:4368 | UBQS_Thrown.Tick |
| H26 | Fire (a fresh press) or alt fire with the saber out: Recall; it lifts 8 tics, then up to 34 units a tic | Z:725, Z:727, Z:766, Z:4273, Z:4276, Z:4414, Z:4416 | UBQS_SaberBase.A_UBHoldBegin; A_UBAltFire; UBQS_Thrown.Recall; Tick |
| H27 | 140 tics homing: it falls, shuts off on the floor; walked over (within the body's radius + 24) it is caught | Z:4420, Z:4436, Z:4438, Z:4445 | UBQS_Thrown.Tick |
| H28 | Main alt fire with the Force on and Force Push on Alt on: Push from the saber's hand along its aim | Z:3400, Z:773, Z:778, Z:785, Z:786, CVARINFO:60, CVARINFO:85, MENUDEF:193 | UBQS_SaberBase.A_UBAltFire; ForcePush |
| H28 | 448 units, 40 degrees, thrust by 2400 / mass, 8 damage; missiles in the cone sent at the gazed monster (14 degrees) or along the push | Z:5079, Z:5081, Z:5097, Z:5102, Z:5103, Z:5104, Z:5106, Z:5147, Z:5148 | UBQS_Force.Push; PushMissiles |
| H29 | Push and Pull share one ready time, 1.5 s; before it, the off sound at 0.25 | Z:5073, Z:5074, Z:5210 | UBQS_Force.Push; Pull |
| H30 | The second saber's alt fire is left to the Force item; held, it reads the off hand's gesture | Z:772, Z:4912, Z:4914, Z:4937 | UBQS_SaberBase.A_UBAltFire; UBQS_Force.DoEffect |
| H30 | Hand speed at Gesture Sharpness or more and within Gesture Straightness of the view: Push along thrust + view; one gesture a hold | Z:5002, Z:5009, Z:5025, Z:5029, Z:4935, CVARINFO:96, CVARINFO:97, MENUDEF:215, MENUDEF:217 | UBQS_Force.Gesture; DoEffect |
| H31 | Away from the view: Pull; 768 units, 30 degrees; monsters thrust toward you and lifted; pickups queued and flown in at 16 a tic, then touched; thrown sabers recalled | Z:5030, Z:5223, Z:5237, Z:5254, Z:5255, Z:5241, Z:5243, Z:5291, Z:5287, Z:5216 | UBQS_Force.Gesture; Pull; PulledTick |
| H32 | Still (under 1.5) for 8 tics: the monster within 12 degrees and 1024 units, not a boss, mass 600 or less, is gripped | Z:5035, Z:5038, Z:5039, Z:5344, Z:5345, Z:5352, Z:5353, Z:5752 | UBQS_Force.Gesture; FindGrip; GripMass |
| H32 | No gravity, held at the hand's aim, 18 damage a second, the grip loop; the aim outline whenever a Force button exists for the off hand | Z:5371, Z:5413, Z:5418, Z:5433, Z:5440, Z:5381, Z:5310, Z:5323 | UBQS_Force.StartGrip; GripTick; AimTick |
| H33 | Button up: the grip ends; flung at 3.5 x the hand's velocity, 40 at most; stopped dead it takes 3 x its speed | Z:5402, Z:5469, Z:5472, Z:5473, Z:5487, Z:5489, Z:5492 | UBQS_Force.GripTick; EndGrip; SlamTick |
| H34 | The Force hand: fire and alt fire are both the Force's button | Z:4909, Z:4911 | UBQS_Force.DoEffect |
| H35 | The saber in the main hand and a Fist, a Melee glove, RSQ_Hands or a class named fist in the off hand: its alt fire is the Force's button | Z:4913, Z:4974, Z:4977, Z:4979, Z:4981 | UBQS_Force.DoEffect; FistOff |
| H36 | The off hand only; the roll now against the roll 7 tics ago, 75 degrees or more, the hand at 1.2 or less, 21 tics apart; sent as ubqs_twist | Z:909, Z:897, Z:898, Z:899, Z:900, Z:914, Z:915, Z:917 | UBQS_SaberBase.TwistTick |
| H36 | That hand's saber in hand toggles its second blade, with the on or off sound | Z:6707, Z:6713, Z:929, Z:930 | UBQS_Bridge.NetworkProcess; UBQS_SaberBase.ToggleBack |
| H37 | The second blade cuts, turns missiles, burns, and counts for the melee block and the bullet stop | Z:2035, Z:1415, Z:1418, Z:2574, Z:2833 | UBQS_SaberBase.CutAlong; DoEffect; BladeInPath; StopsHitscan |
| H38 | Jump held from the ground with a saber in either hand or the Force hand: +0.55 a tic while rising in the first 8 air tics; else the fall held at 5 a tic | Z:5502, Z:5505, Z:5507, Z:5532, Z:5533, Z:5537, Z:5542, Z:5543, Z:4875, CVARINFO:86, MENUDEF:195 | UBQS_Force.ForceJump; DoEffect |
| H39 | +user3 pressed with the saber in the main hand and Dual Sabers on: the second saber put away or brought out | Z:7006, Z:7009, Z:7014, Z:6836, Z:6844, Z:6845 | UBQS_Bridge.DualKey; SetDual |
| H39 | Put away: RSQ_Hands if that class exists, else the Force hand when allowed | Z:6847, Z:6852 | UBQS_Bridge.SetDual |
| H40 | A saber or the Force hand in the off hand, a non-melee main weapon with a Reload state: 45 degrees down inside 4 tics, ending 40 below level, re-armed above 15 below; its Reload state is set | Z:7604, Z:7605, Z:7589, Z:7593, Z:7577, Z:7578, Z:7579, Z:7580, Z:7611, Z:7616, Z:7618, Z:7620, Z:7628, Z:7629 | UBQS_OffFlick.WorldTick; IsGun; Reload |
| H41 | The menu row runs the alias, the alias sends ubqs_remote; with a saber held a remote is spawned 112 units ahead | MENUDEF:154, KEYCONF:6, Z:6722, Z:6736, Z:6737, Z:6140 | UBQS_Bridge.NetworkProcess; UBQS_Remote.HoldsSaber |
| H41 | It keeps 56 to 300 units out; the charge sound and glow, then a bolt; a bolt does 2 to its trainee | Z:6399, Z:6434, Z:6421, Z:6457, Z:6448, Z:6552 | UBQS_Remote.Tick; Fire; UBQS_RemoteBolt.DoSpecialDamage |
| H42 | A turned bolt may hit the remote; a hit counts and kicks it away; 4 hits: down, 25 health, 105 tics, the next round | Z:6541, Z:6476, Z:6479, Z:6492, Z:6482, Z:6124, Z:6191, Z:6196, Z:6125, Z:6202, Z:6164 | UBQS_RemoteBolt.CanCollideWith; UBQS_Remote.DamageMobj; Down; Level |
| H43 | The 30 s clock out, or no saber for more than 10 tics: TRAINING OVER with rounds, streak, points | Z:6129, Z:6379, Z:6134, Z:6376, Z:6207 | UBQS_Remote.Tick; TrainingOver |
| H43 | The button again: your remote is destroyed, "Training remote dismissed" | Z:6729, Z:6732, Z:6735 | UBQS_Bridge.NetworkProcess |
| H44 | No saber held: the message, no remote | Z:6736 | UBQS_Bridge.NetworkProcess |
| H45 | Lightsaber, SWSP_Saber, DSweap (Sword Becomes Saber), Chainsaw with Xim's loaded: replaced when spawned, and swapped when carried | Z:6635, Z:6638, Z:6641, Z:6643, Z:6645, Z:6748, Z:6749, Z:7055, Z:7059, Z:7065, CVARINFO:57, MENUDEF:171 | UBQS_Bridge.IsTheirs; CheckReplacement; WorldTick |
| H46 | No Rig service and Show Sabers on: each owned saber not in a hand is hung 0.21 m to its side, 0.84 m under the eyes; nothing here takes it | HIP:35, HIP:42, HIP:48, HIP:50, HIP:54, HIP:55, HIP:58, HIP:19, HIP:20, HIP:70, HIP:77, CVARINFO:52, MENUDEF:134 | UBQS_HipShow.WorldTick; Hang |
| H47 | Force Push on Alt off: main alt fire toggles the second blade, once a press | Z:773, Z:775 | UBQS_SaberBase.A_UBAltFire |
| H48 | The Force off: either saber's alt fire toggles its second blade; the Force item does nothing; no Force hand is given | Z:772, Z:773, Z:775, Z:4875, Z:5069, Z:7111, MENUDEF:152 | UBQS_SaberBase.A_UBAltFire; UBQS_Force.DoEffect; Push; UBQS_Bridge.WorldTick |
| H49 | Turned Shots Go 0: no direction is picked, so the shooter; 2: the mirror off the blade | Z:2369, Z:2444, MENUDEF:183 | UBQS_SaberBase.BatBack |
| H50 | Hit Stop: the cut monster's freezetics; the menu's 3, 4, 6 | Z:2211, MENUDEF:83, MENUDEF:86, MENUDEF:88, CVARINFO:47, MENUDEF:185 | UBQS_SaberBase.CutLine |
| H51 | Parry Slow Motion: a parry sends rsm_pulse 500 35 | Z:2743, Z:2744, CVARINFO:49, MENUDEF:187 | UBQS_SaberBase.BlockFx |
| H52 | Dual Sabers off: no second saber is given or raised, the Force hand is; nothing takes a held second saber away | Z:6802, Z:7083, Z:7110, Z:7111, Z:7121, Z:7122, Z:7104 | UBQS_Bridge.DualMode; WorldTick |
| H53 | Start With Saber off: given only in place of another mod's saber | Z:7037, Z:7065, MENUDEF:130 | UBQS_Bridge.WorldTick |
| H54 | Sabers off: no handing out, no replacement, no bullet stop; the weapon's own code does not read it | Z:7032, Z:6748, Z:6758, Z:1305, MENUDEF:128 | UBQS_Bridge.WorldTick; CheckReplacement; WorldHitscanPreFired; UBQS_SaberBase.DoEffect |
| H55 | Force Jump off | Z:5502 | UBQS_Force.ForceJump |
| H56 | Force Only With Saber off: the Force hand is raised into an empty off hand whatever the main hand holds, when no second saber is due | Z:6892, Z:7111, Z:7125, Z:7128, Z:7135, MENUDEF:197 | UBQS_Bridge.ForceOnlyWithSaber; WorldTick |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | The Rig sends a saber put on an empty holster home, and its second saber holster sends ubqs_dual_in / ubqs_dual_out | TacticalRig/zscript/rsqtr/rig.zs:3356, TacticalRig/zscript/rsqtr/rig.zs:3368, TacticalRig/zscript/rsqtr/rig.zs:3391 | (the Rig's Press) |
| W1 | This mod acts on the two events; putting away needs a holster (the Rig's handler found, rsqtr_on not off) | Z:6717, Z:6719, Z:6824, Z:6811, Z:6812 | UBQS_Bridge.NetworkProcess; SetDual; HolsterThere |
| W1 | Second Saber Starts 0 with a holster: given put away; the mark is an inventory item, dropped only when there is no holster or no dual | Z:7091, Z:7092, Z:6596, Z:7104, CVARINFO:14, MENUDEF:167 | UBQS_Bridge.WorldTick; UBQS_DualAway |
| W1 | The Rig reads ubqs_show; this mod's hip draw stands down for the Rig's service | TacticalRig/zscript/rsqtr/rig.zs:3990, HIP:35, HIP:48 | (the Rig's DrawMarkers); UBQS_HipShow.WorldTick |
| W2 | The Wheel's own icon and home hand for the saber | Wheel/zscript/wheel/zscript.zs:5510, Wheel/zscript/wheel/zscript.zs:5525, Wheel/zscript/wheel/zscript.zs:10709 | (the Wheel's ownBases, ownIcon, homeHandOf) |
| W2 | The icons this mod sets | Z:477, Z:6023 | UBQS_SaberBase Default; UBQS_ForceHand Default |
| W3 | Gun Bonsai VR's service by name, counted only when it answers "loaded" 1; levels and numbers asked by name | Z:7534, Z:7537, Z:7542, Z:7548 | UBQS_Upg.Svc; Lv; Num |
| W3 | Credit: a turned shot's master, the bolt's master, the thrown saber's tracer, the Force item's master | Z:2451, Z:2772, Z:3205, Z:5560 | UBQS_SaberBase.BatBack; BlockFx; Throw; UBQS_Force.UpgRefresh |
| W3 | Force Sensitive; a power only once learned; 40% at level 1, +30% a level | Z:4884, Z:5072, Z:5748, Z:5744, Z:5574 | UBQS_Force.DoEffect; Push; Learned; FScale; UpgRefresh |
| W3 | Two Sabers; Double-Bladed (the second blade, its cut from 2); Deflector; Return to Sender and Guided Return; Battle Meditation and Strike True cap the rows | Z:7048, Z:7010, Z:924, Z:2035, Z:2376, Z:2395, Z:2398, Z:2401, Z:794, Z:803 | UBQS_Bridge.WorldTick; DualKey; UBQS_SaberBase.ToggleBack; CutAlong; BatBack; MostLocks; HitStopTics |
| W3 | The greyed rows ask this mod's service "menu.locked" | MENUDEF:183, MENUDEF:185, MENUDEF:189, MENUDEF:193, MENUDEF:195, MENUDEF:201, Z:7350, Z:7355 | UBQS_SaberService.GetIntUI |
| W4 | The parry's pulse; the remote's 300 ms and 1500 ms pulses and its ubqs_remoteslowmo, which SlowMo reads | Z:2744, Z:6573, Z:6192, Z:6178, Z:6179, SlowMo/zscript/rsqsm/clock.zs:386, SlowMo/zscript/rsqsm/clock.zs:562 | UBQS_SaberBase.BlockFx; UBQS_RemoteBolt.CountDeflect; UBQS_Remote.Down; Slow; (SlowMo's NetworkProcess, ParryOrBlock) |
| W4 | Effects left in the world ask RSQSM_Service "scale" every tic | Z:3731, Z:3736, Z:3808 | UBQS_Clock.W; UBQS_FX.Tick |
| W5 | Awards "Deflect" and "Remote Down" and touches go to RS_ScoreService | Z:176, Z:183, Z:6480, Z:6572, Z:6189, Z:7557, Z:7562 | UBQS_Data.Award; UBQS_Remote.DamageMobj; Down; UBQS_Upg.Touch |
| W5 | UBQS_RemoteOut carried while the remote is out; Score looks it up by name; Score names UBQS_Thrown | Z:6378, Z:6214, Z:6519, Score/zscript/rsscore/wrist.zs:57, Score/zscript/rsscore/melee.zs:134 | UBQS_Remote.Tick; OnDestroy; (Score's wrist, melee) |
| W5 | blocked, perfect, pulled, thrown.leg answered | Z:7370, Z:7371, Z:7372, Z:7373 | UBQS_SaberService.GetInt |
| W6 | The remote's messages offered to RSQVR_Service "toast" first; VisualRewards asks UBQS_SaberService; "gripped" answered | Z:6106, Z:6111, Z:6372, Z:6735, VisualRewards/pk3/zscript/rsqthp/handler.zs:135, Z:7383 | UBQS_Remote.Toast; UBQS_SaberService.GetInt |
| W7 | Accessibility is read only while its menu class is loaded; Rumble Strength, Rumble Backup | Z:7669, Z:7800, Z:3669, Z:3700 | UBQS_CB.Mode; UBQS_A11y.Rumble; UBQS_Buzzer.Start; Pulse |
| W7 | Gesture Ease on the throw, the Force gestures and the flick; Steady Hands on lock on and grip; Slower Taps on the kept marks | Z:7753, Z:1011, Z:5002, Z:7618, Z:5339, Z:7803, Z:755 | UBQS_A11y.Low; Tap; ThrowRelease; Gesture; UBQS_OffFlick.WorldTick; FindGrip |
| W7 | Photosensitive Mode (starburst, lock flicker, grip crackle); Hold to Toggle; the Off-Hand Modifier; the gesture buttons | Z:4173, Z:3171, Z:5396, Z:4922, Z:4919, Z:4819, Z:6667, Z:6671, Z:5052, Z:5058, Z:7636 | UBQS_ClashFlash.Burst; Clash; GripTick; UBQS_Force.DoEffect; Alt; UBQS_Bridge.NetworkProcess; UBQS_OffFlick.NetworkProcess |
| W7 | Cue Size, Text Size, the colour-blind pair, the Comfort Vignette, the ready cue | Z:4633, Z:6285, Z:4958, Z:5524, Z:5313 | UBQS_LockMark.MarkFor; UBQS_Remote.Panel; UBQS_Force.DoEffect; ForceJump; AimTick |
| W8 | Distance Grab asks saber.lit; the answer: 1 thrown or lit, 0 doused, -1 no saber | DistanceGrab/zscript/rsqdg/reach.zs:206, Z:7395, Z:7400, Z:7402, Z:7403 | (Distance Grab's reach); UBQS_SaberService.GetInt |
| W9 | Laser Sight skips a melee weapon or a CHEATNOTWEAPON hand; the saber is +MELEEWEAPON, the Force hand +CHEATNOTWEAPON | LaserSight/zscript/rsqls/sight.zs:519, Z:467, Z:6020 | (Laser Sight's sight); UBQS_SaberBase Default; UBQS_ForceHand Default |
| W10 | Slappers Only read by cvar name: nothing handed out | Z:4991, Z:7033 | UBQS_Force.SlappersOn; UBQS_Bridge.WorldTick |
| W10 | Melee's glove by class name: replaced by the Force hand, remembered, given back; kept in the off hand it is a fist for the Force | Z:4986, Z:6983, Z:6990, Z:6972, Z:4979, Melee/zscript/rsqml/core.zs:183 | UBQS_Force.MeleeGlove; UBQS_Bridge.ForceCombo; UBQS_Force.FistOff; (Melee's IsSlapperClass) |
| W11 | Gun Cards, ShieldSaw and Whip name the saber's classes | GunCards/zscript/rsqgc/items.zs:59, ShieldSaw/zscript/ssq/state.zs:311, ShieldSaw/zscript/ssq/state.zs:1414, Whip/zscript/rsqwp/swing.zs:154 | (their own code) |
| W12 | RSQ_Hands by class name: the put-away second saber's off hand; with it and a gun in the main hand the second saber is not raised | Z:6847, Z:6942, Z:7116, Z:7118, Z:7120, Z:7157, Z:7158 | UBQS_Bridge.SetDual; ForceHandIsEmpty; WorldTick |
| W12 | rsq_flick honoured by the flick reload | Z:7603, Z:7605 | UBQS_OffFlick.WorldTick |
| W13 | DSweap behind Sword Becomes Saber; BT_USER3 | Z:6638, Z:6641, Z:7006, CVARINFO:57 | UBQS_Bridge.IsTheirs; DualKey |
| W14 | Lightsaber, SWSP_Saber, Chainsaw when Xim's lump or pickup text is found | Z:6635, Z:6643, Z:6645 | UBQS_Bridge.IsTheirs |
| W15 | The service's requests | Z:7337, Z:7350, Z:7370, Z:7371, Z:7372, Z:7373, Z:7383, Z:7395 | UBQS_SaberService.GetIntUI; GetInt |
| W15 | The network events acted on | Z:6667, Z:6683, Z:6707, Z:6717, Z:6722 | UBQS_Bridge.NetworkProcess |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | KEYCONF has the slot line and one alias; the menu row runs the alias | KEYCONF:1, KEYCONF:6, MENUDEF:154 | KEYCONF; MENUDEF Command |
| L2 | The buttons read: fire and alt fire of the saber's hand, the Force's off-hand bits, jump, +user3; the two-hand flag | Z:738, Z:1113, Z:4911, Z:5507, Z:7006, Z:2498 | A_UBHold; TickFireLatch; UBQS_Force.DoEffect; ForceJump; UBQS_Bridge.DualKey; GrippedInput |
| L3 | `doused` is written by Flick alone, called from the ubqs_ignite event alone; A_UBOn and Caught clear it; KEYCONF has no alias for it | Z:1076, Z:6683, Z:6702, Z:702, Z:3259, KEYCONF:6 | UBQS_SaberBase.Flick; UBQS_Bridge.NetworkProcess; A_UBOn; Caught |
| L4 | The twist returns for the main hand; the main saber's second blade: alt fire (Force Push on Alt off, or the Force off) and the throw | Z:909, Z:773, Z:775, Z:3215 | UBQS_SaberBase.TwistTick; A_UBAltFire; Throw |
| L5 | The off hand's alt fire returns before the toggle while the Force is on | Z:772 | UBQS_SaberBase.A_UBAltFire |
| L6 | The throw is decided only when fire is up; the free throw's test against the view | Z:745, Z:1018 | UBQS_SaberBase.A_UBHold; ThrowRelease |
| L7 | Not friendly monsters, not players outside deathmatch, not without sight | Z:2085, Z:2086, Z:2186 | UBQS_SaberBase.CutCandidate; CutLine |
| L8 | Every block is the attack's line against the blade's own segment, within Block Width | Z:2573, Z:2828, Z:2906, Z:2653 | UBQS_SaberBase.BladeInPath; StopsHitscan; ContactBlock; ModifyDamage |
| L9 | One gesture a hold: `fired` is cleared only when the button goes down again | Z:4935, Z:4937 | UBQS_Force.DoEffect |
| L10 | Grip: no boss, mass 600; Push and Pull skip a monster that cannot be thrust | Z:5352, Z:5353, Z:5752, Z:5099, Z:5247 | UBQS_Force.FindGrip; GripMass; Push; Pull |
| L11 | Mass 0x7FFFFFFF: damage but no velocity (cut, Push, Pull) | Z:2219, Z:5103, Z:5255 | UBQS_SaberBase.CutLine; UBQS_Force.Push; Pull |
| L12 | The Force jump's own test for a saber or the Force hand | Z:5505 | UBQS_Force.ForceJump |
| L13 | Lock on and the gaze help take monsters only (players in deathmatch) | Z:834, Z:2538 | UBQS_SaberBase.Paint; GazeTarget |
| L14 | The hip draw only shows; putting away without a holster is refused unless by the Dual button | HIP:58, Z:6824 | UBQS_HipShow.WorldTick; UBQS_Bridge.SetDual |
| L15 | The hand flag is put back to the class's every tic; a saber in the wrong slot is cleared or switched | Z:1232, Z:1233, Z:7077, Z:7081 | UBQS_SaberBase.DoEffect; UBQS_Bridge.WorldTick |
| L16 | Five sizes; the nearest is taken | Z:29, Z:506, MENUDEF:60 | UBQS_Data.Size; UBQS_SaberBase.ResolveSizeIdx |
| L17 | The world saber: its setting (no row), or the off hand under the two-hand flag | CVARINFO:68, Z:1678, Z:1679 | UBQS_SaberBase.WorldUp |
| L18 | Under the two-hand flag the off saber's fire is read here, only with a saber in the main hand | Z:2496, Z:2497, Z:2498 | UBQS_SaberBase.GrippedInput |
