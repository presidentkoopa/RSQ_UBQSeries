# RSQ Accessibility: where each README claim comes from

Commit read: 7bd62b727 (2026-11-27). Paths are inside `Accessibility/` unless they start with another mod's folder.
`C` is `zscript/rsqa_core.zs`, `Q` is `zscript/rsqa_qol.zs`, `N` is `zscript/rsqa_hand.zs`, `G` is
`zscript/rsqg/gestures.zs`, `P` is `zscript/rsqg/pose.zs`, `A` is `zscript/rsqg/a11y.zs`, `HS` is
`zscript/rsqg/handsync.zs`, `M` is `MENUDEF.txt`, `V` is `CVARINFO.txt`, `K` is `KEYCONF.txt`. `Saber` is
`QuestSaber/zscript.txt`. Each line number is the line that does the thing, not the start of its function.

The watch check's numbers are the sliders' defaults after the code's fixed ease: `WATCH_EASE` 1.25 (G:499) and
`PULSE_EASE` 1.6 (G:500). Nearest 0.15 / 1.25 = 0.12 m; furthest 0.65 x 1.25 = 0.81 m; below 0.30 x 1.25 = 0.375 m;
above 0.20 x 1.25 = 0.25 m; side 0.35 x 1.25 = 0.44 m; tilt 60 x 1.25 = 75 degrees; twist 35 / 1.25 = 28 degrees;
still 1.2 x 1.25 = 1.5 m/s; hold 6 / 1.25 = 5 tics; drop 20 / 1.25 = 16 degrees. The pulse check: 0.15 / 1.6 = 0.09 m,
0.65 x 1.6 = 1.04 m, 0.30 x 1.6 = 0.48 m, 0.20 x 1.6 = 0.32 m, 0.35 x 1.6 = 0.56 m, 35 / 1.6 = 22 degrees,
1.2 x 1.6 = 1.92 m/s, 6 / 1.6 = 4 tics.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | The watch check's space: ahead, below / above, side, the gun's tilt | G:508, G:509, G:510, G:511, V:75, V:76, V:77, V:78, V:79, V:80 | RSQG_Handler.PoseWay |
| H1 | The fixed ease 1.25 on top of the sliders; the twist needed is divided by it | G:499, G:506, G:488 | RSQG_Handler.PoseWay; InspectPose |
| H1 | Twist 35 by default, the back of the wrist (way 2) | G:557, G:523, V:70, V:73 | RSQG_Handler.TwistOn; PoseWay |
| H1 | Slower than 1.5 m/s to start; the hold of 5 tics | G:565, G:566, G:569, G:583, V:74, V:81 | RSQG_Handler.Inspect1 |
| H1 | Held: the name is set and the hand is ticked | G:476, G:478, G:273, V:68, V:69 | RSQG_Handler.SetInspect; TickHand |
| H1 | The name is drawn small, grey, low in view, for 52 tics | G:72, G:255, G:261, V:130 | RSQG_Handler.RenderOverlay |
| H1 | Measured only while a mod asked in the last second (or the two-hand switch, debug or a measurement) | G:202, G:341, G:917 | RSQG_Handler.Running; WorldTick; Inspect |
| H1 | Askers of "inspect" | GunCards/zscript/rsqgc/card.zs:718, LaserSight/zscript/rsqls/sight.zs:449, TacticalRig/zscript/rsqtr/rig.zs:2176, Miniboss/zscript/rsqmb/bossfight.zs:403 | RSQGC card Inspect; RSQLS WatchCheck; RSQTR GestureInspect; RSQMB WatchCheck |
| H2 | Drops under the off twist (20, kept 5 under the start, divided by the ease) or outside the space by more than the slack (0.05 m) | G:558, G:577, G:578, G:581, V:71, V:82 | RSQG_Handler.TwistOff; Inspect1 |
| H3 | The pulse check: the same pose the other way, ease 1.6, its own stillness and hold | G:500, G:491, G:605, G:606, G:610, G:621 | RSQG_Handler.PulseWay; Pulse1 |
| H3 | Held: named "pulse check" and ticked | G:597, G:599 | RSQG_Handler.SetPulse |
| H3 | Measured only for a hand asked for in the last second; off with the watch check | G:404, G:920 | RSQG_Handler.Update; Pulse |
| H3 | RSQ Boss asks "pulse" for the off hand | Miniboss/zscript/rsqmb/bossfight.zs:544 | RSQMB PulseCheck |
| H4 | Both hands down: downward speed, the downward share, at or under the hip line | G:786, G:787, G:789, G:815, V:99, V:100, V:101 | RSQG_Handler.TwoHand |
| H4 | The two hands within the window (120 ms) | G:783, G:843, G:878, V:96 | RSQG_Handler.TwoHand; Together |
| H4 | Announced: the event rsqg_pair with the kind, and the name | G:845, G:887, G:889, G:890 | RSQG_Handler.Announce |
| H4 | Read while the switch is on or a mod asked "pair.ago" in the last second; each kind's own switch | G:198, G:411, G:794, G:941, V:89, V:92 | RSQG_Handler.TwoHandWanted; Update; TwoHand; PairAgoMs |
| H4 | RSQ Melee asks, only with a move that uses it | Melee/zscript/rsqml/twohand.zs:61, Melee/zscript/rsqml/twohand.zs:64 | RSQML two-hand WorldTick |
| H5 | Both hands apart: from within 0.50 m of the chest point 0.40 m under the eyes; the gap opening at 2.0 m/s | G:790, G:791, G:821, G:823, G:825, G:847, G:856, V:93, V:102, V:103, V:104 | RSQG_Handler.TwoHand |
| H6 | Both palms thrust: forward speed and share, above the hips, pointing up, not braced | G:797, G:798, G:799, G:800, G:832, G:833, V:95, V:112, V:113, V:114 | RSQG_Handler.TwoHand |
| H6 | Side by side 0.25 m; announced as kind 3 | G:861, G:862, G:864, V:111 | RSQG_Handler.TwoHand |
| H7 | Both palms out: ahead, above the hips, still, pointing up, no fire held | G:766, G:767, G:768, G:770, G:792, G:804, V:85, V:105, V:110 | RSQG_Handler.PalmOut; TwoHand |
| H7 | 0.25 m apart, held 400 ms, announced as kind 2 | G:803, G:861, G:866, G:869, V:94, V:106 | RSQG_Handler.TwoHand |
| H7 | No mod hears kind 2: the one hearer takes 0, 3 and 1 | Melee/zscript/rsqml/twohand.zs:78, Melee/zscript/rsqml/twohand.zs:79, Melee/zscript/rsqml/twohand.zs:80 | RSQML two-hand NetworkProcess |
| H8 | A punch: armed on a slow hand, 0.15 m of travel at an average of 2.0 m/s | G:105, G:650, G:659, G:669, G:671, V:118 | RSQG_Handler.Punch1 |
| H8 | Named jab, hook or uppercut with the hand | G:716, G:718, G:719, G:636 | RSQG_Handler.Punch1; Classify |
| H8 | Runs only inside the reader's update (awake); no series mod asks for punches | G:345, G:419, G:987, G:990 | RSQG_Handler.WorldTick; Update; RSQG_Service.GetInt (a search of every mod's ZScript finds no call of "punch" or "shove" on RSQG_Service) |
| H9 | A gun in that hand: named "gun-butt shove", never a punch | G:707, G:710, G:711, G:744 | RSQG_Handler.Punch1; Carry |
| H10 | Quiet while RSQ Grapple's hook is busy or RSQ Wheel is open, and 9 tics after | G:68, G:228, G:231, G:235, G:239 | RSQG_Handler.Quiet |
| H10 | Quiet stops punches, shoves and the two-hand gestures | G:418, G:776 | RSQG_Handler.Update; TwoHand |
| H11 | Steady Hands on by default; both hands filtered every tic | V:52, Q:46, Q:87, Q:356 | RSQA_QoL.SteadyOn; SteadyTick; WorldTick |
| H11 | The smoothed pose when on, the raw one when off | Q:99, Q:120, C:402 | RSQA_QoL.Steady; Pick; RSQA_Service.GetDoubleData |
| H12 | Auto: seated after 0.25 m below standing for 2 s, standing after within 0.15 m for 1 s | Q:141, Q:142, Q:194, Q:196, V:48 | RSQA_QoL.SeatTick |
| H12 | Seated is answered from the mode and that flag; the drop in metres | Q:163, Q:169, C:391, C:403 | RSQA_QoL.IsSeated; SeatDrop; RSQA_Service |
| H12 | Auto has no standing height until a head held steady for a second, or the measured one | Q:153, Q:155, Q:188, Q:190, Q:193 | RSQA_QoL.StandEye; SeatTick |
| H13 | Every key is dropped while One Handed is off (the default) | C:94, C:95, V:15 | RSQA_Handler.ConsoleProcess |
| H14 | Off-Hand Modifier: the key, its press and release, the event rsqa_mod | K:14, K:24, K:25, C:109 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H14 | The swap is kept per player; a tick on the main hand, 0.45 going on and 0.25 going off | C:118, C:121 | RSQA_Handler.NetworkProcess |
| H14 | Here: the off hand's pose comes from the main controller, and the main hand is not read | P:52, A:83, G:368, G:378 | RSQG_Pose.Src; RSQG_A11y.Ctrl; RSQG_Handler.Update |
| H15 | Grab Pull: the key; code 1 pressed goes out as rsqa_alt | K:15, K:26, C:110 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H15 | RSQ Distance Grab: a locked thing is launched to the hand | DistanceGrab/zscript/rsqdg/grab.zs:174, DistanceGrab/zscript/rsqdg/grab.zs:148, DistanceGrab/zscript/rsqdg/grab.zs:155 | RSQDG grab NetworkProcess; Alt |
| H16 | Grab Reach: the key, press and release; code 2 | K:16, K:27, K:28, C:100, C:110 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H16 | RSQ Distance Grab: the hand (the off hand's part while swapped) counts as palm out while held | DistanceGrab/zscript/rsqdg/grab.zs:164, DistanceGrab/zscript/rsqdg/grab.zs:166, DistanceGrab/zscript/rsqdg/grab.zs:167, DistanceGrab/zscript/rsqdg/grab.zs:434 | RSQDG Alt; grab WorldTick |
| H17 | Force Push: the key; code 3 | K:17, K:29, C:110 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H17 | RSQ Saber: codes 3 to 5 go to the presser's Force; 3 pushes; only with the Force out in the off hand | Saber:6673, Saber:6677, Saber:5060, Saber:5062, Saber:5064 | UBQS handler NetworkProcess; UBQS_Force.Alt |
| H18 | Force Pull: the key; code 4; RSQ Saber pulls | K:18, K:30, Saber:5065 | KEYCONF; UBQS_Force.Alt |
| H19 | Force Grip: the key, press and release; code 5 | K:19, K:31, K:32, C:100 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H19 | RSQ Saber: held, the Force hand is up and grips what it points at | Saber:5066, Saber:4936, Saber:4945 | UBQS_Force.Alt; UBQS_Force off-hand tick |
| H20 | Shield Throw: the key; code 6 | K:20, K:33, C:110 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H20 | RSQ ShieldSaw: drawn, thrown at the ringed targets, else along the aim | ShieldSaw/zscript/ssq/state.zs:1261, ShieldSaw/zscript/ssq/state.zs:1266 | SSQ state NetworkProcess |
| H21 | Flick Reload: the key; code 7 | K:21, K:34, C:110 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H21 | Heard by RSQ ShieldSaw with the saw in the off hand and by RSQ Saber with a saber or the Force hand there: the main gun's Reload | ShieldSaw/zscript/ssq/offflick.zs:71, ShieldSaw/zscript/ssq/offflick.zs:77, ShieldSaw/zscript/ssq/offflick.zs:78, Saber:7642, Saber:7648, Saber:7650 | SSQ_OffFlick.NetworkProcess; UBQS_OffFlick.NetworkProcess |
| H22 | Wrist Cross: the key; code 8 sends rsm_toggle with no argument | K:22, K:35, C:99 | KEYCONF; RSQA_Handler.ConsoleProcess |
| H22 | RSQ SlowMo: a bare rsm_toggle with this mod loaded is its Accessibility Button, default on | SlowMo/zscript/rsqsm/clock.zs:362, SlowMo/zscript/rsqsm/clock.zs:367, SlowMo/zscript/rsqsm/clock.zs:666, SlowMo/CVARINFO.txt:87 | RSQSM clock NetworkProcess; trigger switch |
| H23 | Hold to Toggle: codes 0, 2 and 5 flip on a press and ignore the release | C:100, C:101, C:104, C:105, C:106, V:29 | RSQA_Handler.ConsoleProcess |
| H23 | RSQ Saber's Force trigger latches the same way | Saber:4928 | UBQS_Force off-hand tick |
| H24 | Slower Taps: the reader's together window x1.5 | G:783, A:97, C:45, V:54 | RSQG_Handler.TwoHand; RSQG_A11y.TapScale; RSQA_Set.Taps |
| H24 | RSQ Wheel's double tap and RSQ Saber's kept marks | Wheel/zscript/wheel/zscript.zs:1070, Saber:753 | wr double tap; UBQS throw release |
| H25 | Gesture Ease: tolerances x1 to x2, thresholds x1 to x0.5 | A:46, A:47, A:48, G:159, G:160, V:17 | RSQG_A11y.Ease; Wide; Low |
| H26 | The vignette's darkness by level; in a seventh a tic, out a fourteenth; off in a menu | C:185, C:186, C:295, C:302, C:304, V:19 | RSQA_Handler.VignetteTick; DrawVignette |
| H26 | Only a reported comfort moment raises it | C:190, C:194, C:426 | RSQA_Handler.Comfort; RSQA_Service.GetInt |
| H26 | Reported by RSQ Grapple's hook and RSQ Saber's boosted Force jump | Grapple/zscript/rsqgr/util.zs:203, Grapple/zscript/rsqgr/core.zs:773, Saber:5530 | RSQGR_Util.Comfort; UBQS_Force jump |
| H27 | Knockback: speed up by more than 8 to over 12 within 2 tics of a hit; a fall faster than 10 | Q:223, Q:224, Q:225, Q:242, Q:246, Q:259, V:53 | RSQA_QoL.KnockTick |
| H27 | Needs the row and a Comfort Vignette level; held while flying | Q:253, Q:257, Q:260 | RSQA_QoL.KnockTick |
| H28 | A hit on you is noted with its source | C:226, C:229 | RSQA_Handler.WorldThingDamaged |
| H28 | Drawn only more than 35 degrees out of view, red, for 42 tics | C:69, C:286, C:323, C:326, C:331, V:26 | RSQA_Handler.RenderOverlay; DrawThreats |
| H29 | A monster's missile within 2048 units and 20 degrees of coming at you; a monster's hitscan with you as its target | C:235, C:241, C:242, C:243, C:249, C:251 | RSQA_Handler.WorldThingSpawned; WorldHitscanFired |
| H29 | Amber, an open arrow (no bar) | C:331, C:356 | RSQA_Handler.DrawThreats |
| H30 | The rumble: more than 40 degrees off the body's facing, on that side, stronger for a hit | C:276, C:277, C:278 | RSQA_Handler.Note |
| H31 | Slow motion asked of RSQ SlowMo by name; both controllers buzz, longer starting | C:205, C:207, C:214, C:215 | RSQA_Handler.SlowMoTick |
| H31 | The label: "Slow Motion" while on, "Normal Speed" fading over 35 tics | C:368, C:369, C:374, C:375 | RSQA_Handler.DrawSlowMo |
| H32 | Wake Cues: monsters within 1536 units; woke on you, teleported, teleported in | Q:268, Q:278, Q:335, Q:340, Q:342, Q:343, Q:345, V:55 | RSQA_QoL.WakeOn; WakeTick |
| H32 | Grey double arrow; a light buzz | C:332, C:350, C:278 | RSQA_Handler.DrawThreats; Note |
| H33 | Rumble Strength scales this mod's rumbles; 0 is none; given to askers as "rumble" | C:44, C:467, C:468, C:469, C:398, V:47, M:116 | RSQA_Buzz.Start; RSQA_Service.GetDoubleData |
| H34 | Rumble Backup: on, Quake Haptics 0, strength above 0: a 0.1-unit trace in place of the rumble | C:472, C:500, C:501, C:506, V:35 | RSQA_Buzz.Start; Backup |
| H34 | Other mods ask "buzz"; at most one a controller every 5 tics for those | C:436, C:439, C:496, C:504 | RSQA_Service.GetInt; RSQA_Buzz.Backup |
| H35 | Handedness Right or Left sets vr_control_scheme to the last one used that side | N:58, N:59, N:69, N:73, N:81, N:89, V:7, V:8, V:9 | OptionMenuItemRSQAHanded.SetSelection; RememberLeft; RightScheme; LeftScheme |
| H35 | At start, a Handedness that disagrees with the engine goes back to Follow QuestZDoom | N:38, N:47 | OptionMenuItemRSQAHanded.Init; Reconcile |
| H36 | Two Hand Brace Off keeps your value and turns vr_two_handed_weapons off; the other choice puts it back | N:129, N:130, N:134, N:135, V:40, V:43 | OptionMenuItemRSQABrace.SetSelection |
| H37 | Brace Cue: a gun (it uses ammo) in the off hand as the latch goes on: a buzz on the off hand and / or a click | C:167, C:168, C:169, C:171, C:172, V:44 | RSQA_Handler.BraceTick |
| H38 | Colour Blind recolours the hit and shot arrows | C:319, C:333, C:335, C:336, V:6 | RSQA_Handler.DrawThreats |
| H39 | Cue Size scales the arrows (0.5 to 3) | C:41, C:316, C:318, M:80 | RSQA_Set.Cue; RSQA_Handler.DrawThreats |
| H40 | Text Size scales the slow motion label and the gesture names (1 to 3) | C:42, C:370, C:371, G:259, M:82 | RSQA_Handler.DrawSlowMo; RSQG_Handler.RenderOverlay |
| H41 | Measure Height: the row's event; the headset height is saved and shown | M:108, Q:202, Q:204, Q:213, Q:215 | RSQA_QoL.ConsoleProcess |
| H41 | Seated Play uses the measured height first | Q:152, Q:153 | RSQA_QoL.StandEye |
| H42 | Measure Me: the row's event; armed, 2 s to stand, 1 s measured | M:132, G:294, G:296, G:299, G:335, G:336 | RSQG_Handler.NetworkProcess; WorldTick |
| H42 | Eye height and reach measured, saved, Fit to Body turned on | G:310, G:312, G:322, G:323, G:324 | RSQG_Handler.Measure |
| H42 | The scales, 0.6 to 1.4, used by the watch check and the two-hand lines | G:283, G:289, G:504, G:788 | RSQG_Handler.VScale; HScale; PoseWay; TwoHand |
| H43 | Seated Play: Seated always answers seated | Q:147, Q:163 | RSQA_QoL.SeatMode; IsSeated |
| H44 | Watch Check Off: neither check is measured; "inspect" and "pulse" answer -1 | M:128, V:67, G:401, G:404, G:482, G:917, G:920 | RSQG_Handler.Update; InspectOff; Inspect; Pulse |
| H45 | Wrist Turn: 1 one side, 2 the other, 0 either; the pulse check takes the other side, or side 1 with Either Way | M:176, M:310, M:311, M:312, G:522, G:523, G:524, G:491 | RSQG_Handler.PoseWay; PulseWay |
| H46 | Tick When Ready off: no tick | M:178, G:270 | RSQG_Handler.TickHand |
| H47 | Gesture Names off: nothing drawn | M:192, G:252 | RSQG_Handler.RenderOverlay |
| H48 | Menus: Simple removes links into a series mod's own pages from each front page; Full restores them | M:136, C:566, C:570, C:584, C:595, C:601, C:648 | RSQA_MenuMode.UiTick; Apply; Niche |
| H49 | Reset All: the list of settings reset (no Handedness, brace, measurements) | M:141 | MENUDEF SafeCommand |
| H50 | Reset Every Mod: each loaded mod's own Reset All run once; this page skipped | M:143, Q:379, Q:381, Q:398, Q:416, Q:419, Q:422 | OptionMenuItemRSQAResetSeries.MenuEvent; Walk |
| H51 | Forget Height resets the measured standing height | M:172 | MENUDEF SafeCommand |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W0 | RSQG_Service's whole-number requests | G:979, G:980, G:981, G:982, G:983, G:984, G:985, G:986, G:987, G:988, G:989, G:990, G:991 | RSQG_Service.GetInt |
| W0 | RSQG_Service's numbers and its text | G:1009, G:1010, G:1011, G:1012, G:1013, G:1014, G:1024 | RSQG_Service.GetDouble; GetString |
| W0 | The event rsqg_pair with the kind and hundredths | G:887 | RSQG_Handler.Announce |
| W0 | RSQA_Service: swap, steady, seated (any scope) | C:388, C:390, C:391 | RSQA_Service.GetIntData |
| W0 | RSQA_Service: rumble, taps, steady, seated.drop, seated.eye, stand.eye | C:398, C:399, C:402, C:403, C:404, C:405 | RSQA_Service.GetDoubleData |
| W0 | RSQA_Service: vignette, ready, buzz | C:426, C:427, C:436 | RSQA_Service.GetInt |
| W0 | The events rsqa_mod and rsqa_alt | C:109, C:110 | RSQA_Handler.ConsoleProcess |
| W0 | A mod reads the settings only while the class RSQA_Menu exists | A:27, zscript/rsqa_menu.zs:7 | RSQG_A11y.Cv (the series' template) |
| W1 | RSQ Gun Cards asks "inspect"; its copy stands down | GunCards/zscript/rsqgc/card.zs:718, GunCards/zscript/rsqgc/gestcopy.zs:131 | Inspect; ReaderHere |
| W2 | RSQ Laser Sight: "inspect" holds the laser off; "steady"; Cue Size; Text Size; Colour Blind; Photosensitive | LaserSight/zscript/rsqls/sight.zs:449, LaserSight/zscript/rsqls/sight.zs:486, LaserSight/zscript/rsqls/hand.zs:149, LaserSight/zscript/rsqls/sight.zs:1013, LaserSight/zscript/rsqls/sight.zs:1373, LaserSight/zscript/rsqls/sight.zs:552, LaserSight/zscript/rsqls/sight.zs:100 | RSQLS sight and hand |
| W3 | RSQ Tactical Rig: "inspect"; Seated; Handedness; Text Size; Colour Blind; Photosensitive; Rumble Strength; Rumble Backup | TacticalRig/zscript/rsqtr/rig.zs:2176, TacticalRig/zscript/rsqtr/rig.zs:2233, TacticalRig/zscript/rsqtr/body.zs:279, TacticalRig/zscript/rsqtr/body.zs:376, TacticalRig/zscript/rsqtr/rig.zs:4271, TacticalRig/zscript/rsqtr/rig.zs:1207, TacticalRig/zscript/rsqtr/cig.zs:1368, TacticalRig/zscript/rsqtr/body.zs:802, TacticalRig/zscript/rsqtr/body.zs:826 | RSQTR rig, body, cig |
| W4 | RSQ Boss: "inspect"; "pulse"; Text Size; Colour Blind; Photosensitive; Rumble Backup | Miniboss/zscript/rsqmb/bossfight.zs:403, Miniboss/zscript/rsqmb/bossfight.zs:544, Miniboss/zscript/rsqmb/hud.zs:108, Miniboss/zscript/rsqmb/traits.zs:195, Miniboss/zscript/rsqmb/hud.zs:206, Miniboss/zscript/rsqmb/traits.zs:582 | RSQMB bossfight, hud, traits |
| W5 | RSQ Melee: "pair.ago"; hears rsqg_pair 0, 3, 1; the modifier; Seated; Rumble Strength; Rumble Backup | Melee/zscript/rsqml/twohand.zs:64, Melee/zscript/rsqml/twohand.zs:73, Melee/zscript/rsqml/twohand.zs:78, Melee/zscript/rsqml/twohand.zs:79, Melee/zscript/rsqml/twohand.zs:80, Melee/zscript/rsqml/core.zs:281, Melee/zscript/rsqml/guard.zs:117, Melee/zscript/rsqml/core.zs:349, Melee/zscript/rsqml/core.zs:369 | RSQML twohand, core, guard |
| W6 | RSQ Distance Grab: the two keys; the modifier; "steady"; Gesture Ease; Cue Size; Colour Blind; Photosensitive; Rumble Strength; Rumble Backup | DistanceGrab/zscript/rsqdg/grab.zs:174, DistanceGrab/zscript/rsqdg/reach.zs:42, DistanceGrab/zscript/rsqdg/reach.zs:162, DistanceGrab/zscript/rsqdg/reach.zs:468, DistanceGrab/zscript/rsqdg/reach.zs:125, DistanceGrab/zscript/rsqdg/laser.zs:440, DistanceGrab/zscript/rsqdg/tell.zs:104, DistanceGrab/zscript/rsqdg/laser.zs:284, DistanceGrab/zscript/rsqdg/feel.zs:337, DistanceGrab/zscript/rsqdg/feel.zs:356 | RSQDG grab, reach, laser, tell, feel |
| W7 | RSQ Saber: the four keys; the modifier; Hold to Toggle; Slower Taps; "steady" for painting; "vignette"; "ready"; Gesture Ease; Cue Size; Text Size; Colour Blind; Photosensitive; Rumble Strength; Rumble Backup | Saber:6673, Saber:7642, Saber:4825, Saber:4925, Saber:4928, Saber:753, Saber:826, Saber:5530, Saber:5319, Saber:1004, Saber:4639, Saber:6291, Saber:5975, Saber:3177, Saber:3675, Saber:3706 | UBQS handlers and UBQS_Force |
| W8 | RSQ ShieldSaw: the two keys; "steady"; Gesture Ease; Cue Size; Colour Blind; Photosensitive; Rumble Strength; Rumble Backup | ShieldSaw/zscript/ssq/state.zs:1261, ShieldSaw/zscript/ssq/offflick.zs:71, ShieldSaw/zscript/ssq/state.zs:1482, ShieldSaw/zscript/ssq/offflick.zs:50, ShieldSaw/zscript/ssq/state.zs:847, ShieldSaw/zscript/ssq/state.zs:839, ShieldSaw/zscript/ssq/shield.zs:284, ShieldSaw/zscript/ssq/shield.zs:241, ShieldSaw/zscript/ssq/shield.zs:386 | SSQ state, offflick, shield |
| W9 | RSQ SlowMo: the Accessibility Button; Slow Mo Ease; Gesture Ease on its wrist cross; Text Size; Colour Blind; Photosensitive; Rumble Strength; Rumble Backup | SlowMo/zscript/rsqsm/clock.zs:367, SlowMo/zscript/rsqsm/clock.zs:236, SlowMo/zscript/rsqsm/clock.zs:2340, SlowMo/zscript/rsqsm/countdown.zs:271, SlowMo/zscript/rsqsm/round.zs:141, SlowMo/zscript/rsqsm/countdown.zs:354, SlowMo/zscript/rsqsm/clock.zs:2377, SlowMo/zscript/rsqsm/clock.zs:2398 | RSQSM clock, countdown, round |
| W9 | This mod asks RSQ SlowMo "slowmo.active" and "down" | C:205, C:207, Q:175, Q:176, Q:191 | RSQA_Handler.SlowMoTick; RSQA_QoL.IsDown; SeatTick |
| W10 | RSQ Whip: the modifier; Rumble Strength; Rumble Backup | Whip/zscript/rsqwp/util.zs:52, Whip/zscript/rsqwp/whip.zs:1355, Whip/zscript/rsqwp/whip.zs:1461 | RSQWP util, whip |
| W11 | RSQ Wheel: Slower Taps; "seated.drop"; "steady"; Colour Blind; Photosensitive; Rumble Strength; Rumble Backup | Wheel/zscript/wheel/zscript.zs:1070, Wheel/zscript/wheel/zscript.zs:8835, Wheel/zscript/wheel/zscript.zs:8872, Wheel/zscript/wheel/wr_q_gunlook.zs:38, Wheel/zscript/wheel/wr_q_gunlook.zs:146, Wheel/zscript/wheel/wr_q_shim.zs:1208, Wheel/zscript/wheel/wr_q_shim.zs:1229 | wr zscript, gunlook, shim |
| W11 | This mod asks RSQ Wheel "IsOpen" | G:220, G:231 | RSQG_Handler.Quiet |
| W12 | RSQ Grapple sends "vignette"; this mod asks it "g2.mode" and "g2.air" (and the old "climbing", "swinging", "reeling") | Grapple/zscript/rsqgr/util.zs:203, G:219, G:228, G:229, G:230 | RSQGR_Util.Comfort; RSQG_Handler.Quiet |
| W13 | RSQ Score: Text Size; Colour Blind; Photosensitive | Score/zscript/rsscore/hud.zs:127, Score/zscript/rsscore/cb.zs:21, Score/zscript/rsscore/hud.zs:214 | RSSC hud, cb |
| W14 | RSQ VisualRewards: Cue Size; Text Size; Colour Blind; Photosensitive | VisualRewards/pk3/zscript/rsqthp/bar.zs:457, VisualRewards/pk3/zscript/rsqvr/banners.zs:403, VisualRewards/pk3/zscript/rsqthp/handler.zs:252, VisualRewards/pk3/zscript/rsqvr/banners.zs:883 | RSQTHP bar, banners, handler |
| W15 | RSQ Gun Bonsai VR: Text Size; Colour Blind; Handedness | GunBonsaiOffhandVR/rsq/ui/draw.zs:57, GunBonsaiOffhandVR/rsq/ui/legendoom.zs:220, GunBonsaiOffhandVR/ca.ancilla.bonsai/HUD.zsc:160 | RSQGB ui; TFLV_HUD |
| W16 | RSQ Grenade: Rumble Strength; Rumble Backup; Photosensitive and Comfort Vignette read by name | Grenade/zscript/rsqgn/weapon.zs:149, Grenade/zscript/rsqgn/weapon.zs:175, Grenade/zscript/rsqgn/explosions.zs:90, Grenade/zscript/rsqgn/explosions.zs:91 | RSQGN weapon, explosions |
| W17 | RSQ FnF: Rumble Strength; Rumble Backup | FlashFlare/zscript/rsqff/items.zs:143, FlashFlare/zscript/rsqff/items.zs:167 | RSQFF items (line numbers at the commit; the working copy of this file has since moved by three lines) |
| W18 | RSQ Monsters: Rumble Backup; Photosensitive | Monsters/zscript/monsters/RSQ_QuakeFeel.zs:22, Monsters/zscript/monsters/RS_Retier.zs:1188 | RSQ_QuakeFeel; RS_Retier |
| W19 | RSQ Graveyards: Photosensitive | Graveyard/zscript/gy_Stone.zs:445 | gy_Stone |
| W20 | RSQ PlayLog asks "inspect", "pulse" and "pose.why" | PlayLog/zscript/rsqpl/log.zs:118, PlayLog/zscript/rsqpl/log.zs:123 | RSQPL log |
| W21 | The weapon sets: Rumble Strength; Rumble Backup; Photosensitive | weaponsets/GNRC_Reloaded/zscript/rsqb/gn_weapon.zs:140, weaponsets/GNRC_Reloaded/zscript/rsqb/gn_weapon.zs:166, weaponsets/GNRC_Reloaded/zscript/rsvr/melee.zs:1527, weaponsets/WoS_Reloaded/zscript/rsqb/gn_weapon.zs:166, weaponsets/WoS_Reloaded/zscript/wos/charge.zs:42 | gn_weapon; melee; charge |
| W22 | QuestZDoom: vr_control_scheme, vr_two_handed_weapons, vr_quake_haptic_level | N:53, N:130, C:500 | SetSelection (both rows); RSQA_Buzz.Backup |
| W23 | Every loaded series mod: the front pages Simple thins; the pages Reset Every Mod walks | C:557, C:570, Q:392 | RSQA_MenuMode.UiTick; OptionMenuItemRSQAResetSeries.RunAll |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No default bind (only a section, nine menu keys and their aliases); every key dropped with One Handed off | K:13, K:14, K:22, K:24, K:35, C:95, V:15 | KEYCONF; RSQA_Handler.ConsoleProcess |
| L2 | A key only sends an event; this mod itself hears only rsqa_mod | C:99, C:109, C:110, C:116 | RSQA_Handler.ConsoleProcess; NetworkProcess |
| L3 | Code 7 is heard in two places, each tied to its own off-hand item | ShieldSaw/zscript/ssq/offflick.zs:71, ShieldSaw/zscript/ssq/offflick.zs:77, Saber:7642, Saber:7648 | SSQ_OffFlick.NetworkProcess; UBQS_OffFlick.NetworkProcess |
| L4 | The wrist cross move is read in RSQ SlowMo; this reader has no such request | SlowMo/zscript/rsqsm/clock.zs:2318, SlowMo/zscript/rsqsm/clock.zs:2348, G:992 | RSQSM LocalGesture; RSQG_Service.GetInt |
| L5 | The reader's one outgoing event is rsqg_pair; a held check only names and ticks | G:887, G:476, G:478 | RSQG_Handler.Announce; SetInspect |
| L6 | Nothing is measured unless asked in the last second, the two-hand events are wanted, debug 1 or 2 is on, or a measurement runs | G:67, G:202, G:341, G:343 | RSQG_Handler.Running; WorldTick |
| L7 | No pose out of VR; answers only for the console player | P:56, G:912 | RSQG_Pose.PoseGood; RSQG_Handler.Asked |
| L8 | The watch check starts only on a still hand; both hands at one point is no pose | G:565, G:569, P:60 | RSQG_Handler.Inspect1; RSQG_Pose.PoseGood |
| L9 | Palms out is the hand pointing up | G:768, V:110 | RSQG_Handler.PalmOut |
| L10 | The one button test in the reader: fire and alt fire block palms out | G:766 | RSQG_Handler.PalmOut |
| L11 | Auto holds while RSQ SlowMo answers "down" | Q:176, Q:191 | RSQA_QoL.IsDown; SeatTick |
| L12 | The vignette's only inputs: a mod's "vignette" request, the knockback and the fall | C:426, Q:257, Q:260 | RSQA_Service.GetInt; RSQA_QoL.KnockTick |
| L13 | No threat or slow motion cue over a menu | C:285 | RSQA_Handler.RenderOverlay |
| L14 | The backup is one fixed trace, whatever the rumble's strength or length | C:497, C:506 | RSQA_Buzz.Backup |
| L15 | Reset All's list leaves out rsqa_handed, rsqa_brace_off, rsqa_stand_eye, rsqg_body_eye and rsqg_body_reach; Forget Height resets rsqa_stand_eye | M:141, M:172 | MENUDEF SafeCommand rows |
