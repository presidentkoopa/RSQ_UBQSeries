# RSQ LaserSight: where each README claim comes from

Commit read: 692b3e53c (2026-11-27). Paths are inside `LaserSight/` unless they start with another mod's folder. `S` is
`zscript/rsqls/sight.zs`, `B` is `zscript/rsqls/beam.zs`, `L` is `zscript/rsqls/learn.zs`, `H` is
`zscript/rsqls/hand.zs`, `HD` is `zscript/rsqls/head.zs`, `M` is `zscript/rsqls/muzzles.zs`, `ST` is
`zscript/rsqls/sets.zs`, `BB` is `zscript/rsqls/bdbore.zs`, `A` is `zscript/rsqls/a11y.zs`, `CB` is
`zscript/rsqls/cb.zs`; other files are named in full. Each line number is the line that does the thing, not the start
of its function. Rows are numbered in the README's order.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Both hands are drawn, each from its own weapon | S:647, S:685 | RSQLS_Sight.WorldTick; DrawHand |
| H1 | A measured gun is one whose class has a row in the beam table (or, for a weapon set's gun, the row of the gun it stands for) | S:687, B:140, B:143, B:144 | DrawHand; RSQLS_Beams.Find |
| H1 | The table: Brutal Doom's classes, the Purist copies, the RSQ_Off_ copies, the sets' own rows | M:16, M:17, M:24, M:205, ST:9, ST:62 | RSQLS_Muzzles.CLASSES; RSQLS_Sets.ALIAS, CLASSES |
| H1 | The pose row of the frame the gun is drawn in; its muzzle and barrel from the table | S:691, S:718, S:719 | DrawHand |
| H1 | The beam is drawn only with Show Beam on and a pose row | S:928, S:942 | DrawHand |
| H1 | Brightest at the muzzle, straight fade, gone at the fade length (3 m) | B:202, S:932, CVARINFO.txt:23 | RSQLS_Beams.Tint; DrawHand |
| H1 | The beam is the longest length that does not pass the hit | B:224, S:933 | RSQLS_Beams.Length; DrawHand |
| H1 | The dot is put where the trace from the muzzle along the barrel hits | S:827, S:830, S:1007 | DrawHand |
| H1 | Switches read: Laser Sight, Show Dot, Show Beam, Main Hand / Off Hand, all default on | S:637, S:630, S:631, S:469, CVARINFO.txt:5, CVARINFO.txt:7, CVARINFO.txt:8, CVARINFO.txt:9, CVARINFO.txt:21 | WorldTick; HandLive |
| H1 | Per Hand by default: main red (ff 20 10), off green (20 ff 30) | S:559, S:560, CVARINFO.txt:41, CVARINFO.txt:42, CVARINFO.txt:43 | ColorOf |
| H2 | A gun with no row: no placement, the trace starts at the controller along the hand's aim | S:702, S:724, S:731 | DrawHand |
| H2 | No pose row, so no beam; the dot is still placed | S:928, S:949, S:1007 | DrawHand |
| H3 | The test: MELEEWEAPON, or CHEATNOTWEAPON and not measured, with Show on Melee off: the hand is not live (beam, dot, arc, ring all hidden) | S:518, S:519, S:649, S:440, CVARINFO.txt:10 | HandLive; WorldTick; HideHand |
| H3 | A weapon flagged MELEEWEAPON never counts as measured | S:518 | HandLive |
| H3 | The sabers, the whip and the glove are flagged MELEEWEAPON | QuestSaber/zscript.txt:467, Whip/zscript/rsqwp/weapon.zs:45, Melee/zscript/rsqml/gloves.zs:49 | UBQS_SaberBase, RSQWP_WhipWeapon, RSQ_Glove Default |
| H3 | The ShieldSaw, the Force hand, the hand grenade and a weapon set's bare hand are flagged CHEATNOTWEAPON | ShieldSaw/zscript/ssq/shield.zs:27, QuestSaber/zscript.txt:6020, Grenade/zscript/rsqgn/weapon.zs:66, weaponsets/WoS_Reloaded/zscript/rsq/hands.zs:281 | SSQ_ShieldSaw, UBQS_ForceHand, RSQGN_Grenade, RSQ_Hands Default |
| H4 | No weapon in the hand: not live, before any setting but the hand's own switch is read | S:471 | HandLive |
| H5 | On a wall: turned to the wall's normal, 0.4 units off it | S:962, S:975, S:976, S:1005 | DrawHand |
| H5 | On a floor or ceiling: laid flat, 0.3 units off | S:978, S:981, S:983, S:986 | DrawHand |
| H5 | Size grows with distance: Dot Size x (0.03 + distance / 2000) | S:1013, CVARINFO.txt:13 | DrawHand |
| H5 | Glow mode 3 (Both): the bloom at Glow Size (1.8) times the dot, and a point light on the dot | S:1039, S:1043, S:1051, S:1057, S:1065, CVARINFO.txt:15, CVARINFO.txt:16 | DrawHand |
| H6 | The trace looks Trace Range (2048); no hit or a sky hit hides the dot | S:789, S:827, S:832, S:956, CVARINFO.txt:33 | DrawHand |
| H6 | With no hit the beam is the shortest length that reaches the fade length | S:842, B:218, B:220 | DrawHand; RSQLS_Beams.Length |
| H7 | Hostile: a monster, alive, not friendly | S:872 | DrawHand |
| H7 | The dot is drawn on the body | S:1002 | DrawHand; OnBody |
| H7 | x (1.25 + 0.12 sin) at Lock Pulse Rate 2.2 | S:1014, S:1018, S:1019, S:1020, CVARINFO.txt:32 | DrawHand |
| H7 | The beam x 1.35 on a hostile with Target Lock | S:938 | DrawHand |
| H7 | Target Lock is the row rsqls_lock, default on | S:269, CVARINFO.txt:30 | RSQLS_Sight.Lock |
| H8 | No length at or under the distance to the hit: no beam; the lengths start at 10 cm (times vr_weaponScale) | B:223, B:224, S:934, S:949, M:11 | RSQLS_Beams.Length; DrawHand |
| H9 | Pitch below minus Aim Down Off (55): the hand is not live | S:522, S:523, H:36, CVARINFO.txt:12 | HandLive; RSQLS_Hand.Pitch |
| H10 | A pending weapon switch: the main hand is not live | S:526 | HandLive |
| H11 | Each hand's fire or alt fire is noted; 35 tics kept | S:157, S:158, S:151, S:160 | RSQLS_Sight.Busy |
| H11 | A frame with no measurement keeps the last measured pose unless busy; a measured frame sets it | S:699, S:700 | DrawHand |
| H11 | With no pose the beam hides; the dot is still traced from the class's first placement | S:949, S:702 | DrawHand |
| H12 | Either hand's watch check above 0 and this hand not aimed: not live | S:486 | HandLive |
| H12 | The watch check is asked of RSQG_Service, else RSQGC_GCopyService ("inspect") | S:449, S:451, S:452, S:453 | RSQLS_Sight.WatchCheck |
| H12 | Aimed: within 40 degrees of the view | S:458, S:465 | RSQLS_Sight.Aimed |
| H13 | The off hand is not live while the engine's two hand steadied flag is set; the code's note that only PC VR sets it | S:507, S:503, S:505 | HandLive (and its comment) |
| H14 | Beam brightness = Beam Brightness x (1 - (1 - Beam in Daylight) x the sector's light at the muzzle) | S:921, S:922, S:936, S:937, CVARINFO.txt:22, CVARINFO.txt:24 | DrawHand |
| H15 | Liquid by texture name: WATER, NUKAGE, LAVA, BLOOD, SLIME, FALL | S:675, S:677 | RSQLS_Sight.Surface |
| H15 | On liquid: size x (1 + 0.18 sin), brightness x 0.75; behind Dot Reacts to Surface | S:1024, S:1028, S:1029, S:1032, CVARINFO.txt:34 | DrawHand |
| H16 | Metal by texture name: METAL, SUPPORT, DOOR, STEEL, SHAWN, PLAT, PIPE; glow scale x 1.5 | S:676, S:678, S:1040 | Surface; DrawHand |
| H17 | Every missile spawned is looked at a tic later; only the console player's | L:160, L:172 | RSQLS_Learn.WorldThingSpawned; WorldTick |
| H17 | A missile with gravity is a lob; learned only with that hand's trigger held; the fastest that tic | L:176, L:194, L:203 | RSQLS_Learn.WorldTick |
| H17 | Its speed, gravity, climb and yaw are stored and marked known | L:241, L:242, L:243, L:244, L:245 | RSQLS_Learn.WorldTick |
| H17 | Kept for the session (a static handler) | L:32 | RSQLS_Learn |
| H17 | With Grenade Arc on and the arc known, the path is stepped a tic at a time | S:778, S:779, S:803, S:807, S:810 | DrawHand |
| H17 | 24 dots along it; the dot at its last point | S:342, S:902, S:1131, S:823 | DrawHand; LayArc |
| H17 | With Arc With Beam on the beam is laid along the path, never straight | S:782, S:783, S:910 | DrawHand; LayArcBeam |
| H17 | Defaults on | CVARINFO.txt:72, CVARINFO.txt:73 | |
| H18 | Health 0 or less: both hands hidden, readout updated (hidden) | S:639, S:642, S:643 | WorldTick |
| H19 | With Show on Melee on the hand is live | S:519 | HandLive |
| H19 | Not in the table: no placement, so the trace starts at the controller and there is no beam | S:702, S:724, S:928 | DrawHand |
| H20 | On a hostile with Target Lock and Colour on Target: the Target Colour (ff e0 20) | S:601, S:603, CVARINFO.txt:37, CVARINFO.txt:38 | ColorOf |
| H20 | The beam's colour and the dot's are both asked with the hostile flag | S:898, S:899 | DrawHand |
| H21 | The dot's size x (1 - Lock Tighten) | S:1017, S:1020, CVARINFO.txt:31 | DrawHand |
| H22 | Head is judged only on a hostile | S:881, S:883 | DrawHand |
| H22 | With Headshot Reaction: mixed toward the Headshot Colour (ff ff ff) by a sine at Headshot Pulse Rate (4), in 8 steps | S:605, S:607, S:610, S:611, S:613, CVARINFO.txt:64, CVARINFO.txt:65, CVARINFO.txt:66, CVARINFO.txt:67 | ColorOf |
| H23 | Headshot Pulse off: the Headshot Colour itself | S:615 | ColorOf |
| H24 | Dot Only on Enemies: no dot unless hostile | S:955, S:956, CVARINFO.txt:75 | DrawHand |
| H25 | Dot Range Limit above 0 and the hit further: no dot | S:953, S:956, CVARINFO.txt:36 | DrawHand |
| H26 | Off at mode 0; the main hand's range, else the off hand's | S:1332, S:1333, S:1334, CVARINFO.txt:81 | UpdateReadout |
| H26 | Feet, map units, or metres with one decimal under 10 | S:1345, S:1346, S:1347, CVARINFO.txt:82 | UpdateReadout |
| H26 | At Dot only while the dot shows; else beside the gun | S:1363, S:1388, S:1398 | UpdateReadout |
| H26 | Drawn in the dot's colour | S:901, S:1342, S:1465 | DrawHand; UpdateReadout |
| H27 | A hitscan with that hand's trigger held, not a melee line, is counted | L:141, L:148, L:149, L:150 | RSQLS_Learn.WorldHitscanPreFired |
| H27 | Nothing until three; the angle 95% fall inside | L:104, L:110 | RSQLS_Learn.Spread; Pct |
| H27 | The ring is off by default and not drawn under Ring Minimum Spread (0.75) | S:1253, S:1255, S:1265, CVARINFO.txt:78, CVARINFO.txt:79 | LayRing |
| H28 | Only When Ready: not live unless the hand's ready bits are set | S:527, S:529, S:530, S:531, CVARINFO.txt:11 | HandLive |
| H29 | Infrared Only: everything hides unless the pawn has PowerLightAmp | S:634, S:635, S:640, CVARINFO.txt:18 | WorldTick |
| H30 | Colour Mode 0: the main hand's colour for both | S:560, MENUDEF.txt:39 | ColorOf |
| H31 | Colour Mode 2: the dot's own colour per hand | S:564, S:566, MENUDEF.txt:41, CVARINFO.txt:44, CVARINFO.txt:45 | ColorOf |
| H32 | Colour per Slot: the colour of the weapon's slot number, 0 to 9 | S:570, S:572, S:575, CVARINFO.txt:46 | ColorOf |
| H33 | Cycle Colours: hue = time x Cycle Speed (60) / 35 + 180 for the off hand; the dot only with Dot Cycles Too | S:591, S:595, S:596, CVARINFO.txt:59, CVARINFO.txt:60, CVARINFO.txt:61 | ColorOf |
| H34 | Beam Sparkle: a particle beside the beam, the colour half way to white, every few tics | S:943, S:944, S:101, S:111, S:124, CVARINFO.txt:74 | DrawHand; Sparkle |
| H35 | Arc With Beam off: no bent beam, and the straight beam is already switched off for an arc | S:782, S:783, S:918 | DrawHand |
| H36 | Grenade Arc off: the arc is never asked for | S:778 | DrawHand |
| H37 | Aim Down Off 0: the test is skipped | S:523 | HandLive |
| H38 | Dot Glow: the bloom in modes 1 and 3, the light in modes 2 and 3, else hidden or removed | S:1043, S:1055, S:1057, S:1070, MENUDEF.txt:31, MENUDEF.txt:32, MENUDEF.txt:33 | DrawHand |
| H39 | Dot Lead: the muzzle and the hit are moved on by their last tic's movement times the lead (0 to 2) | S:846, S:851, S:859, CVARINFO.txt:26 | DrawHand |
| H40 | Show Beam off: no beam | S:631, S:928 | WorldTick; DrawHand |
| H41 | Show Dot off: the dot is hidden | S:630, S:956 | WorldTick; DrawHand |
| H42 | Main Hand / Off Hand off: that hand is not live | S:469 | HandLive |
| H43 | Laser Sight off: both hands hidden | S:637, S:639, S:642 | WorldTick |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | The service class | S:1497 | RSQLS_SightService |
| W1 | "laser.active": the live bit of that hand; set when a beam, a bent beam or a dot drew | S:1501, S:1502, S:656 | GetInt; WorldTick |
| W1 | "laser.beam": the beam bit; set for a beam or a bent beam | S:1503, S:1504, S:657 | GetInt; WorldTick |
| W1 | "laser.line" and "laser.dot" are the only GetDouble requests; x y z dx dy dz | S:1514, S:1516, S:1517, S:1519, S:1520, S:1521, S:1522, S:1523, S:1524 | GetDouble |
| W1 | The beam's line is kept when the straight beam draws, and for a bent beam the first step of the arc | S:948, S:914, S:915, S:233 | DrawHand; BeamLine |
| W1 | The dot's line is kept for straight traces only, and answered only while that hand is live | S:829, S:793, S:241 | DrawHand; DotLine |
| W1 | "head.on" | S:1507, S:1508, S:279, S:280 | GetInt; HeadOn |
| W1 | Any other GetInt request: -1 | S:1509 | GetInt |
| W1 | "menu.gated", "menu.locked" with TargetLock, TargetColour, Headshot | S:1539, S:1541, S:1546, S:1547, S:1548 | GetIntUI |
| W1 | The masks are the console player's | S:624 | WorldTick |
| W2 | The service class and its one request | S:1559, S:1563 | RSQLS_MuzzleService.GetString |
| W2 | The hand's weapon; none: "" | S:1567, S:1568 | GetString |
| W2 | Brutal Doom's line first, else the console player's beam line; "x y z" | S:1571, S:1572, S:1573, S:1574 | GetString |
| W3 | The Wheel asks "laser.beam" and hides its own beam on that hand | Wheel/zscript/wheel/wr_q_shim.zs:1365, Wheel/zscript/wheel/wr_q_shim.zs:1328 | wr_VRState.laserBeamOn; WorldTick |
| W3 | The Wheel asks "laser.line" and points along it | Wheel/zscript/wheel/wr_q_shim.zs:1372, Wheel/zscript/wheel/zscript.zs:8861 | wr_VRState.laserLine; wr_Rig.laserLine |
| W3 | A hand with no beam answers 0 | S:622, S:657, S:1504 | WorldTick; GetInt |
| W4 | Distance Grab asks "laser.beam"; its rsqdg_ls_yield (default false) decides | DistanceGrab/zscript/rsqdg/laser.zs:415, DistanceGrab/zscript/rsqdg/laser.zs:403, DistanceGrab/CVARINFO.txt:241 | RSQDG laser LaserOn |
| W5 | VisualRewards asks "muzzle.at" of services named ...MuzzleService | VisualRewards/pk3/zscript/rsqvr/worldwords.zs:253, VisualRewards/pk3/zscript/rsqvr/worldwords.zs:257 | MuzzleAt |
| W6 | The watch check is RSQG_Service "inspect" (RSQ Accessibility's gestures) | S:449, S:451, Accessibility/zscript/rsqg/gestures.zs:965, Accessibility/zscript/rsqg/gestures.zs:979 | WatchCheck; RSQG_Service |
| W6 | Steady Hands: the dot's muzzle and direction, and the arc's yaw and pitch, from RSQA_Service "steady" | S:746, S:803, H:144, H:149, H:151 | DrawHand; RSQLS_Hand.Steadied |
| W6 | Colour-blind play: the hand colours swapped for the pair; read only while RSQ Accessibility is loaded | S:552, S:554, S:599, CB:21, CB:29, CB:31, CB:32 | CBHand; ColorOf; RSQLS_CB.Mode, Rgb |
| W6 | Colour-blind play: no target recolour; the lock pulse 0.25 deep | S:602, S:1019 | ColorOf; DrawHand |
| W6 | Photosensitive Mode: pulse rates capped at 2.5; sparks at 40% and twice the gap | S:1018, S:610, A:37, A:20, S:101, S:122, A:35, A:22 | DrawHand; ColorOf; RSQLS_A11y.Hz, Dim; Sparkle |
| W6 | Cue Size on the dot, the arc's dots and the bent beam; Text Size on the digits | S:1013, S:1121, S:1168, S:1373, A:57, A:58 | DrawHand; LayArc; LayArcBeam; UpdateReadout |
| W7 | RSQGC_GCopyService "inspect", when the first gives no answer | S:452, S:453 | WatchCheck |
| W8 | RS_ScoreService "head.at" is asked first; 0 or more is the answer | S:318, S:881, S:882, Score/zscript/rsscore/awards.zs:164 | ScoreSvc; DrawHand |
| W8 | RS_ScoreHeadSensor is a head box | HD:94, HD:97, S:293 | RSQLS_Head.BoxOwner; BoxClasses |
| W9 | Asks RSQ_MeleeUpgradeService "loaded" and "plevel", and looks for RSQTR_RigService | S:262, S:263, S:264, S:266, S:267 | GbRefresh |
| W9 | The three rows are locked only while that gate is on | S:269, S:270, S:271, S:1538, S:1542 | Lock; Recolor; Head; GetIntUI |
| W9 | Gun Bonsai VR answers "loaded" 0 as it stands | GunBonsaiOffhandVR/rsq/zscript/core.zs:310, GunBonsaiOffhandVR/rsq/zscript/core.zs:314, GunBonsaiOffhandVR/rsq/zscript/core.zs:328 | RSQ_MeleeUpgradeService.Unlocks; GetIntUI; GetInt |
| W9 | "head.on" needs the gate on and Headshot Reaction level 2 | S:279 | HeadOn |
| W10 | With Follow BD Shots (default on) and RSQ_Muzzle running, the dot's muzzle and direction are that pack's | S:737, S:740, S:741, BB:62, BB:64, CVARINFO.txt:35 | DrawHand; RSQLS_BDBore.Active |
| W10 | The bore: 3.8541 left, 3.3629 up | BB:5, BB:6, BB:109 | RSQLS_BDBore.Line |
| W10 | The RSQ_Off_ copies have rows; a measured gun passes the flag test | M:205, S:518 | RSQLS_Muzzles.CLASSES; HandLive |
| W11 | Head boxes: HeadHitbox and HeadshotTargetBase | HD:94, HD:97, HD:98, HD:181 | RSQLS_Head.BoxOwner; Judge |
| W11 | Blood heights | HD:138, HD:140, HD:189 | RSQLS_Head.BloodHead; Judge |
| W12 | Each set gun's row: the gun it stands for and the class whose beam rows it draws | ST:9, ST:11, B:143 | RSQLS_Sets.ALIAS; RSQLS_Beams.Find |
| W12 | The WoS 1911: its own rows and its own muzzle | ST:10, ST:57, ST:58, ST:62 | RSQLS_Sets.OWN, CLASSES |
| W12 | The knuckles and saws name no beam rows | ST:13, ST:17, ST:38, ST:40 | RSQLS_Sets.ALIAS |
| W13 | mk-crits: found by csh_Brain and csh_headshot_enabled | HD:159, HD:162, HD:163 | RSQLS_Head.MkCrits |
| W13 | Its rule: the top fifth, and the refused classes | HD:169, HD:194, HD:196, HD:197 | MkRefused; Judge |
| W14 | M8F found by its handler's name; its switch held at 0 while ours is on | S:178, S:210, S:220, CVARINFO.txt:6 | M8FLoaded; M8FQuiet |
| W14 | Put back when ours is off, when a menu is open or the game is not in a level, and on map unload | S:224, S:196, S:1474 | M8FQuiet; UiTick; WorldUnloaded |
| W15 | LaserColorService "laser.color"; an answer of 0 or more is the colour | S:582, S:586, S:587 | ColorOf |
| W16 | LaserMuzzleService "laser.muzzle": "forward up side", used only for a gun with no placement | S:1291, S:1295, S:1300, S:728, S:729 | MuzzleFor; DrawHand |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | No KEYCONF lump in the mod (the tracked files: `git ls-files LaserSight`); the handlers have no InputProcess or NetworkProcess | MAPINFO.txt:5 | the four handlers registered |
| X1 | The buttons read: each hand's fire and alt fire, for the beam's keep and for learning | S:157, S:158, L:81, L:82, L:94 | RSQLS_Sight.Busy; RSQLS_Learn.NoteTriggers, AltHeld |
| X2 | A straight beam needs a pose row; a bent beam is drawn for a gun with no row too | S:928, S:905 | DrawHand |
| X3 | A melee weapon: not live; with Show on Melee, live but no row, so no beam | S:519, S:928 | HandLive; DrawHand |
| X4 | The hand grenade is CHEATNOTWEAPON and has no row | Grenade/zscript/rsqgn/weapon.zs:66, S:519 | RSQGN_Grenade Default; HandLive |
| X5 | No weapon: not live, before Show on Melee is read | S:471 | HandLive |
| X6 | A shot is stored under the class name, with "#alt" when alt fire is held; the arc and the ring read the plain class name | L:67, L:126, L:103 | KeyOf; Arc; Spread |
| X7 | Any hitscan counted for the gun, or a straight missile, stops the arc | L:131 | RSQLS_Learn.Arc |
| X7 | A static handler; its note that it is not saved | L:32, L:29 | RSQLS_Learn |
| X8 | 96 units from the hand, 30 degrees of its aim, 6 units a tic, the trigger within 8 tics | L:188, L:184, L:190, L:193, L:194, L:74, L:88 | RSQLS_Learn.WorldTick; Triggered |
| X9 | At most 140 tics; each step is a trace that stops the path | S:343, S:807, S:813, S:818 | DrawHand |
| X10 | 72 lengths, 10 cm to 6 m; no setting names a width | M:8, M:11, B:224 | RSQLS_Muzzles; RSQLS_Beams.Length |
| X11 | The beam is a weapon layer handed to the gun; the dot is an actor moved in WorldTick | B:246, B:249, S:620, S:1007 | RSQLS_Beams.Show; WorldTick; DrawHand |
| X12 | One hand's range; At Dot needs the dot visible, else the gun's place | S:1333, S:1363, S:1398 | UpdateReadout |
| X13 | M8F's switch is held before the hands and Show rows are looked at | S:637, S:638, S:640 | WorldTick |
| X14 | The console player only | S:624, L:138, L:172 | WorldTick; RSQLS_Learn |
| X15 | The halo look is behind tests that are never true | S:941, S:1169 | DrawHand; LayArcBeam |
