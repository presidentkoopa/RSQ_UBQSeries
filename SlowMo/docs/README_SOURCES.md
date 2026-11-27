# RSQ SlowMo: where each README claim comes from

Commit read: 1a846b85c (2026-11-27). Paths are inside `SlowMo/`. `C` is `zscript/rsqsm/clock.zs`, `D` is
`zscript/rsqsm/down.zs`; the other `.zs` files are in `zscript/rsqsm/` and are named in full, as are the lumps. Each line
number is the line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | The pose: hands closer than Wrist Gap (0.16 m), main hand at least CROSS_M (0.03 m) on the off hand's side | C:2340, C:2317, CVARINFO.txt:30 | RSQSM_Clock.LocalGesture |
| H1 | The pose's box: 0.12 to 0.6 m ahead of the head, 0.40 m below to 0.15 m above eye level | C:2341 | RSQSM_Clock.LocalGesture |
| H1 | Held for Wrist Hold (12 tics) it sends rsm_toggle 1; the hands must part first and 20 tics pass | C:2344, C:2348, C:2342, C:2350, C:2351, CVARINFO.txt:31 | RSQSM_Clock.LocalGesture |
| H1 | rsm_toggle 1 flips the held slow motion under the Wrist Cross switch; a sound and a rumble in each hand on a change | C:365, C:627, C:641, C:642, C:643, CVARINFO.txt:29 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.Aim |
| H2 | The key sends rsm_toggle 2, which flips the held slow motion under the Slow Motion Key switch; no default bind | KEYCONF.txt:1, KEYCONF.txt:3, C:366, CVARINFO.txt:83 | KEYCONF alias; RSQSM_Clock.NetworkProcess |
| H3 | With Adrenaline on and the meter under To Start (25): refused, a buzz on hand 0 and the *usefail sound | C:615, C:620, C:621, CVARINFO.txt:20, CVARINFO.txt:21 | RSQSM_Clock.Aim |
| H4 | While held on (or a dive is up) the meter drains 100 over Full Meter (10 s); at zero the hold ends through Aim(false, heldWho), with the same cue as any other ending | C:1725, C:1726, C:1729, C:639, CVARINFO.txt:22 | RSQSM_Clock.Adrenaline; RSQSM_Clock.Aim |
| H5 | A kill by a player earns Per Kill (12) | C:1747, C:1758, CVARINFO.txt:24 | RSQSM_Clock.WorldThingDied; RSQSM_Clock.WorldThingDamaged |
| H5 | Damage a player takes earns half its amount | C:1752 | RSQSM_Clock.WorldThingDamaged |
| H5 | A round passing a head earns Per Near Miss (4) | round.zs:208, CVARINFO.txt:25 | RSQSM_Round.NearMisses |
| H5 | Nothing is earned while held on or diving; a chime at 100 | C:1715, C:1720 | RSQSM_Clock.AddAdrenaline |
| H6 | A new level sets the meter to 0, then takes the carried one when Keep Adrenaline is on; it is stored on the player when a level ends | C:287, C:288, C:293, C:318, CVARINFO.txt:26 | RSQSM_Clock.WorldLoaded; RSQSM_Clock.WorldUnloaded |
| H7 | The Crisis Dive key sends rsqsm_dodge; no default bind | KEYCONF.txt:4, KEYCONF.txt:5, C:372 | KEYCONF alias; RSQSM_Clock.NetworkProcess |
| H7 | The leap: the engine's jump, a push of Leap + Dive Burst (16 + 8) the way the stick points or the pawn faces, Dive Lift (3) upward | C:1065, C:1067, C:1071, C:1079, C:1080, CVARINFO.txt:73, CVARINFO.txt:74, CVARINFO.txt:75 | RSQSM_Clock.Dodges |
| H7 | The world heads for the dive's World Speed (0.10) while a dive is up | C:1246, C:1022, CVARINFO.txt:72 | RSQSM_Clock.WorldTick; RSQSM_Clock.DodgeDepth |
| H7 | It ends dead, after 6 s, on the ground after 2 tics, or when the meter empties | C:1036, C:1019, C:1729 | RSQSM_Clock.Dodges; RSQSM_Clock.Adrenaline |
| H7 | The diver's own movement takes Hang (0.5) of the world's slowing | C:1108, CVARINFO.txt:76 | RSQSM_Clock.SlowMe |
| H7 | Needs the Crisis Dive switch, and To Start adrenaline with Adrenaline on | C:1051, C:1057, CVARINFO.txt:84 | RSQSM_Clock.Dodges |
| H8 | Refused dead, off the ground, crouch factor under 0.75, water level 2 or more, or no jumping allowed: a debug log line only | C:1052, C:1054 | RSQSM_Clock.Dodges |
| H9 | Turning the hold on zeroes any pulse and restarts the countdown | C:632 | RSQSM_Clock.Aim |
| H10 | Slow Me Too scales the player's step, vertical speed and gravity by the world's factor to the power of Strength | C:1109, C:1127, C:1138, C:1140, CVARINFO.txt:77, CVARINFO.txt:78 | RSQSM_Clock.SlowMe |
| H11 | A player, and any inventory item with an owner, is never slowed | C:1363, C:1364 | RSQSM_Clock.RealTime |
| H12 | Only actors within Range (3000) of a player are slowed | C:1394, C:1498, CVARINFO.txt:14 | RSQSM_Clock.NearAPlayer; RSQSM_Clock.FactorFor |
| H12 | A slowed actor's states last longer, its velocity and gravity are scaled | C:1550, C:1559, C:1563 | RSQSM_Clock.Process |
| H12 | Its sounds are pitched down by Sound Follows, never below 0.4 | C:1592, C:1685, CVARINFO.txt:11 | RSQSM_Clock.Process; RSQSM_Clock.Repitch |
| H13 | A player's own missile is real time only with Slow My Shots off (or DOWN, or smoking at full speed) | C:1375, C:1377, CVARINFO.txt:15 | RSQSM_Clock.RealTime |
| H13 | Slowed missiles leave a wake particle | C:1593, C:1695, CVARINFO.txt:19 | RSQSM_Clock.Process; RSQSM_Clock.Wake |
| H14 | A player's hitscan while slowed leaves a particle trail from the muzzle to the hit, if 32 units or longer | round.zs:79, round.zs:80, round.zs:85, round.zs:99, CVARINFO.txt:18 | RSQSM_Shots.WorldHitscanFired |
| H15 | A monster's hitscan while slowed is cancelled and a round is spawned in its place | round.zs:25, round.zs:26, round.zs:43, round.zs:71, CVARINFO.txt:16 | RSQSM_Shots.WorldHitscanPreFired |
| H15 | The round flies at Round Speed (14) at the set world speed | round.zs:66, round.zs:68, C:1290, CVARINFO.txt:17 | RSQSM_Shots.WorldHitscanPreFired; RSQSM_Clock.Refresh |
| H15 | A hit deals the shot's own damage | round.zs:48, round.zs:165 | RSQSM_Round.SpecialMissileHit |
| H16 | The lean: head Lean Needed (0.06 m) off its baseline, stick centred, the pawn moved with it; sent as rsqsm_lean | body.zs:107, body.zs:121, CVARINFO.txt:41 | RSQSM_Body.LocalHead |
| H16 | A round on the side leaned away from, farther off centre than radius less the lean, passes | body.zs:139, body.zs:140, round.zs:162 | RSQSM_Body.LeanDodges; RSQSM_Round.SpecialMissileHit |
| H16 | Other slowed enemy bullets are let through the same way | body.zs:171, body.zs:172 | RSQSM_Body.LeanPass |
| H16 | Needs the Lean Out of Bullets row | C:219, CVARINFO.txt:40 | RSQSM_Clock.LeanOn |
| H17 | A round whose closest pass was within 64 units: a crack under 22, else a whiz; a buzz in each hand; adrenaline | round.zs:198, round.zs:203, round.zs:204, round.zs:205, round.zs:206, round.zs:208 | RSQSM_Round.NearMisses |
| H18 | One tic's damage must reach Heavy Hit Size (75%) of max health | C:2264, C:2269, CVARINFO.txt:113 | RSQSM_Clock.HeavyHits |
| H18 | The special attackers: legendary, champion, miniboss, thrall, +BOSS, big demon | C:2215, C:2216, C:2218, C:2219, C:2220, C:2221, C:2190 | RSQSM_Clock.SpecialKind; RSQSM_Clock.BigKind |
| H18 | The four extras: Arch-Vile fire, thrown up by 10 or more, over 60 degrees off the view, armour gone | C:2235, C:2243, C:2272, C:2273, C:2170, C:2171 | RSQSM_Clock.HeavyNote; RSQSM_Clock.HeavyHits |
| H18 | It slows for HH_MS (3 s); never on a killing hit or while DOWN | C:2296, C:2169, C:2266, C:2268, CVARINFO.txt:112 | RSQSM_Clock.HeavyHits |
| H19 | Barrel Near You: a barrel dies within 2 m of a living player | C:2109, C:2031, CVARINFO.txt:107 | RSQSM_Clock.BarrelDeath; RSQSM_Clock.BarrelNear |
| H19 | Barrel Multi Kill: one barrel's blast kills a second monster the same tic | C:2117, CVARINFO.txt:105 | RSQSM_Clock.BarrelDeath |
| H19 | Chain Reaction: a barrel dies to another barrel's blast | C:2105, CVARINFO.txt:106 | RSQSM_Clock.BarrelDeath |
| H19 | The cue slows for Blast Time (3000 ms) | C:2130, C:2015, CVARINFO.txt:101 | RSQSM_Clock.BarrelCues; RSQSM_Clock.BlastMs |
| H20 | An automatic trigger is refused until Auto Cooldown (25 s) after the last automatic pulse ended | C:721, C:754, CVARINFO.txt:66 | RSQSM_Clock.Trigger |
| H20 | Heavy Hit shares that wait only with Cooldown: Shared; the default is No Limit | C:2296, CVARINFO.txt:118 | RSQSM_Clock.HeavyHits |
| H21 | The stored bar: the meter, drawn whenever Stored Bar and Adrenaline are on, with a tick at To Start | countdown.zs:245, countdown.zs:362, countdown.zs:374, CVARINFO.txt:56 | RSQSM_Countdown.StoreOn; RSQSM_Countdown.RenderOverlay |
| H21 | The countdown bar shows for automatic slows (every slow with Adrenaline off), under the stored row, with the cause word | countdown.zs:51, countdown.zs:381, countdown.zs:394, CVARINFO.txt:50 | RSQSM_Countdown.ShowsFor; RSQSM_Countdown.RenderOverlay |
| H21 | The rows end left of Score's bar | countdown.zs:114 | RSQSM_Countdown.Slot |
| H22 | The hold is the buddha flag; a lethal hit that leaves the player at 1 HP starts DOWN | D:354, D:694, D:699, D:723, CVARINFO.txt:123 | RSQSM_Down.Hold; RSQSM_Down.PlayerHit |
| H22 | The clock starts at Clock (9 s) times 1, 2/3 or 1/3 by the DOWN count | D:744, D:218, D:217, CVARINFO.txt:124 | RSQSM_Down.Start; RSQSM_Down.StartShare |
| H22 | The world goes to DEPTH (0.05) while anyone is DOWN | C:1249, D:78 | RSQSM_Clock.WorldTick |
| H22 | The hit sound, the ringing, a rumble in each hand | D:758, D:759, D:762, D:763, CVARINFO.txt:160 | RSQSM_Down.Start |
| H22 | The target: the attacker if alive within 1024, or in sight within 2048; else a copy is queued to spawn in view | D:777, D:790, D:795, D:85, D:86, D:1061 | RSQSM_Down.Start; RSQSM_Down.SpawnInView |
| H22 | The boost: a light, full-bright, x1.15 size, plus half its spawn health | D:1176, D:1178, D:1180, D:1182, D:1183, D:82 | RSQSM_Down.Boost |
| H23 | Falling, Crush, no source, a player as source, or a non-monster: the hold lets go and the killing damage is dealt | D:706, D:707, D:708, D:709, D:713, D:719, D:720 | RSQSM_Down.PlayerHit |
| H24 | While DOWN the speed factor is CRAWL_K (a third) | D:246, D:81, D:1633 | RSQSM_Down.Crawl; RSQSM_DownWatch.GetSpeedFactor |
| H24 | A downed player's own missiles are real time | C:1380 | RSQSM_Clock.RealTime |
| H24 | While DOWN the hold stays armed | D:340 | RSQSM_Down.Armed |
| H25 | The crosshair: in sight and within 38 degrees | plate.zs:281, plate.zs:223 | RSQSM_Plate.MarksTick |
| H25 | Past 75 degrees the edge arrow, else the trail of six chevrons at eye level | plate.zs:287, plate.zs:224, plate.zs:366, plate.zs:373, downhud.zs:640 | RSQSM_Plate.MarksTick; RSQSM_Plate.Trail; RSQSM_DownHud.DrawEdges |
| H25 | The grey world with its tint, for the console player while DOWN | downlook.zs:104, downlook.zs:182, downlook.zs:183, CVARINFO.txt:150 | RSQSM_Down.LookTick; RSQSM_Down.GreyApply |
| H26 | Only the target and the bonus monsters buy time | D:653 | RSQSM_Down.WorldThingDamaged |
| H26 | Up to 10 bonus monsters from the nearest 20 in sight within 2048 | D:134, D:135, D:136, D:157, D:164 | RSQSM_Down.BonusStep |
| H26 | A bonus monster's mark: a white crosshair | plate.zs:123, plate.zs:92 | RSQSM_Plate.BonusTick |
| H26 | Time bought: damage over spawn health times the monster's seconds, capped at the Clock | D:659, D:660, D:630, D:631, D:633, D:640, CVARINFO.txt:129, CVARINFO.txt:130, CVARINFO.txt:131, CVARINFO.txt:132 | RSQSM_Down.WorldThingDamaged; RSQSM_Down.SecsPerMonster |
| H26 | The pool pours in at most 1 less Slowest Clock Drain (0.25) a tic | D:457, D:459, CVARINFO.txt:126 | RSQSM_Down.ClockTick |
| H27 | The last owed target dead: Revive | D:1293 | RSQSM_Down.TargetDown |
| H27 | Health raised to 100, 66 or 33% of max by the DOWN count | D:1343, D:1407 | RSQSM_Down.Revive; RSQSM_Down.UpHealthShare |
| H27 | The tier is the third of the clock at the kill | D:1322, D:1323, D:240 | RSQSM_Down.Revive; RSQSM_Down.TierAt |
| H27 | Invulnerable 5 / 3 / 1 s and slow motion 3 / 1.5 / 5 s by tier | D:1333, D:1334, D:1398, CVARINFO.txt:133, CVARINFO.txt:134, CVARINFO.txt:135, CVARINFO.txt:136, CVARINFO.txt:137, CVARINFO.txt:138 | RSQSM_Down.Revive |
| H27 | Armour raised to the tier's share of 100 when nothing is banked | D:1356, D:1358, CVARINFO.txt:139, CVARINFO.txt:140, CVARINFO.txt:141 | RSQSM_Down.Revive |
| H27 | Each held gun's magazine (its second ammo) filled | D:1364, D:1564 | RSQSM_Down.Revive; RSQSM_Down.ReloadHeld |
| H28 | The clock at zero: Fail, which deals the killing damage | D:376, D:1467 | RSQSM_Down.WorldTick; RSQSM_Down.Fail |
| H29 | With Wrist Cross Bursts on the gesture sends rsqsm_burst | C:2347, C:395, CVARINFO.txt:61 | RSQSM_Clock.LocalGesture; RSQSM_Clock.NetworkProcess |
| H29 | The burst: a 4000 ms pulse, its share of the meter (ms over Full Meter) taken first | C:887, C:901, C:902 | RSQSM_Clock.Burst |
| H30 | With Adrenaline off a held start sets an end Slow Motion Length (6 s) away, and the hold ends there | C:630, C:1230, C:235, CVARINFO.txt:23 | RSQSM_Clock.Aim; RSQSM_Clock.WorldTick; RSQSM_Clock.HeldSecs |
| H31 | A reload starts when the hand's weapon enters a reload state, or ammo moves between its two ammo types while it is not ready | C:1881, C:1825, C:1877 | RSQSM_Clock.Reloads; RSQSM_Clock.HandReloading |
| H31 | It slows for Reload Time (1200 ms) | C:1915, C:1918, CVARINFO.txt:32, CVARINFO.txt:33 | RSQSM_Clock.Reloads |
| H31 | A reload within 105 tics of a reload button press gets none | C:1860, C:1863, C:1906, C:1908, C:1794 | RSQSM_Clock.Reloads |
| H32 | A missile whose path passes the player within 14 tics, inside 400 units, sets off Close Call Time (700 ms) | C:1197, C:1199, C:1202, C:1204, C:1205, C:1171, C:1172, CVARINFO.txt:59, CVARINFO.txt:60 | RSQSM_Clock.CloseCalls |
| H33 | The grenade classes and the over-under class | C:1971, C:1972 | RSQSM_Clock.BlastKind |
| H33 | A player's own blast slows for Blast Time | C:2012, C:2013, CVARINFO.txt:98, CVARINFO.txt:99 | RSQSM_Clock.BlastAt |
| H34 | With Lower View on the DOWN target height is CROUCH_K (0.4) of standing | D:517, D:79, D:220, CVARINFO.txt:145 | RSQSM_Down.Crouch |
| H35 | Colour Drain sets the shader's amount from the clock: Colour Drain Amount (0.35) at full depth | body.zs:202, body.zs:207, body.zs:209, body.zs:216, CVARINFO.txt:46, CVARINFO.txt:47, GLDEFS.txt:7 | RSQSM_Body.RenderOverlay |
| H36 | rsm_state prints the clock | C:396, C:397 | RSQSM_Clock.NetworkProcess |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Accessibility is found by its class RSQA_Menu | a11y.zs:27, C:546 | RSQSM_A11y.Cv; RSQSM_Clock.A11yLoaded |
| X1 | A bare rsm_toggle while it is loaded is its button, under the Accessibility Button switch | C:366, C:367, CVARINFO.txt:87 | RSQSM_Clock.NetworkProcess |
| X1 | Gesture Ease widens the gap and the box and shortens the hold | C:2335, C:2336, C:2340, C:2344 | RSQSM_Clock.LocalGesture |
| X1 | Min SlowMo Ease is a floor under both ramps | C:236, C:237 | RSQSM_Clock.RampIn; RSQSM_Clock.RampOut |
| X1 | Rumble Strength scales every rumble; Rumble Backup is called as one starts | C:2377, C:2398 | RSQSM_Buzz.Start; RSQSM_Buzz.Tick |
| X1 | Photosensitive Mode: no refill glint, a slower dimmer DOWN bar beat, no crosshair fly in, a still edge arrow | countdown.zs:386, downhud.zs:610, plate.zs:312, downhud.zs:644 | RSQSM_Countdown.RenderOverlay; RSQSM_DownHud.DrawArcade; RSQSM_Plate.Crosshair; RSQSM_DownHud.EdgeFrame |
| X1 | Colour blind mode: the trail, the round, the countdown bar | round.zs:88, round.zs:143, countdown.zs:296 | RSQSM_Shots.WorldHitscanFired; RSQSM_Round.CBLook; RSQSM_Countdown.BarColor |
| X1 | Text Size scales the bars' fallback place without Score | countdown.zs:271 | RSQSM_Countdown.ScoreSpot2 |
| X2 | rsm_on is the Wheel's: held on under the Wheel switch, with no Slow Motion Length; rsm_off ends it | C:370, C:630, C:373, CVARINFO.txt:86 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.Aim |
| X2 | A held start needs To Start adrenaline and drains the meter | C:615, C:1725 | RSQSM_Clock.Aim; RSQSM_Clock.Adrenaline |
| X3 | A pulse with rsqml_fear the same tic is Melee's shove: deliberate, under the Gun Butt Shove switch | C:381, C:428, CVARINFO.txt:88 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.ResolvePulses |
| X3 | start.barrel (3000 ms by default) and stop | C:2527, C:2530, C:2531 | RSQSM_Service.GetInt |
| X3 | RSQML_Spark slows with the world; RSQML_Dizzy stays real time | C:1327, C:1334 | RSQSM_Clock.SeriesRule |
| X4 | A pulse with rsqtr_cigslowmo the same tic is the cigarette; its third argument asks for full speed movement | C:387, C:431, C:479, CVARINFO.txt:89 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.ResolvePulses; RSQSM_Clock.SmokeStart |
| X4 | The smoke's own end is kept; only death and DOWN end it | C:482, C:524, C:525 | RSQSM_Clock.SmokeStart; RSQSM_Clock.SmokeKeep |
| X4 | What is left is carried on the player to the next level and resumed | C:322, C:282, C:521 | RSQSM_Clock.WorldUnloaded; RSQSM_Clock.WorldLoaded; RSQSM_Clock.SmokeKeep |
| X4 | The smoker's missiles are real time while his full speed lasts | C:1383 | RSQSM_Clock.RealTime |
| X4 | A smoke during a running slow, or a world slow during a smoke, is added after it | C:737 | RSQSM_Clock.Trigger |
| X4 | Getting up in the top tier tells the joined services down.revive | D:1388, D:1390 | RSQSM_Down.Revive |
| X5 | Saber: the parry (500 ms at 35%), Force Speed (other lengths at 35%), the training remote (ubqs_remoteslowmo) | C:454, C:449, C:441, C:562, CVARINFO.txt:90, CVARINFO.txt:92 | RSQSM_Clock.ResolvePulses; RSQSM_Clock.ParryOrBlock |
| X6 | ShieldSaw: the block | C:448, C:455, C:563, CVARINFO.txt:91 | RSQSM_Clock.ResolvePulses; RSQSM_Clock.ParryOrBlock |
| X6 | SSQ_BashHit slows with the world | C:1331 | RSQSM_Clock.SeriesRule |
| X7 | Grenade: the Skeet Window and the Quick Grenade, named by rsqgn_skeetslowmo and rsqgn_quickslowmo | C:384, C:385, C:436, C:439, CVARINFO.txt:93 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.ResolvePulses |
| X7 | RSQGN_Thrown and RSQGN_HandBlast count for Grenade Blast | C:1971 | RSQSM_Clock.BlastKind |
| X7 | Its blasts slow; its barrel is real time while alive | C:1324, C:1333, C:1370 | RSQSM_Clock.SeriesRule; RSQSM_Clock.RealTime |
| X8 | Score's two pulses are automatic, under the Score switch | C:465, C:570, C:572, CVARINFO.txt:94 | RSQSM_Clock.ResolvePulses; RSQSM_Clock.IsScorePulse |
| X8 | start.reward: life.used or life.up | C:2542, C:2543, C:2546, C:2547 | RSQSM_Service.GetInt |
| X8 | DOWN reads Score's lives; a life spent sets the count to 0 | D:451, D:428, D:432 | RSQSM_Down.LivesOf; RSQSM_Down.WatchLives |
| X8 | The Revenge award; Score's monster.name; Score's font when its service class exists | D:1292, D:1603, D:1591, downhud.zs:171, downhud.zs:186 | RSQSM_Down.TargetDown; RSQSM_Down.Award; RSQSM_Down.NameOf; RSQSM_DownHud.Text |
| X8 | The bars take their place from Score's hud.cx, hud.bar.bottom, hud.bar.w | countdown.zs:265, countdown.zs:266, countdown.zs:267 | RSQSM_Countdown.ScoreSpot2 |
| X8 | A claw dodged by leaning is sent to Score as a touch | C:2662 | RSQSM_ClawDodge.AbsorbDamage |
| X9 | Gun Bonsai VR is its service RSQ_MeleeUpgradeService answering loaded 1 | C:170, C:171 | RSQSM_Clock.GbRefresh |
| X9 | Longer: the burst 5000 / 6000 / 8000 ms, the meter 25% longer a level | C:212, C:213 | RSQSM_Clock.BurstMs; RSQSM_Clock.AdrSecs |
| X9 | Deeper: x0.8, 0.6, 0.4; Cheaper: 20% less a level | C:154, C:214 | RSQSM_Clock.Depth; RSQSM_Clock.CostK |
| X9 | Lean Dodge gates the lean; the menu row is a gated row; level 2 dodges a claw | C:222, MENUDEF.txt:75, C:2629, C:2630, C:2648, C:2660 | RSQSM_Clock.LeanOn; RSQSM_Service.GetIntUI; RSQSM_ClawDodge.AbsorbDamage |
| X9 | Matrix: the drain at least 0.85 | body.zs:201, body.zs:208 | RSQSM_Body.RenderOverlay |
| X9 | Its three pulses are automatic, under the Gun Bonsai VR switch | C:466, C:577, CVARINFO.txt:95 | RSQSM_Clock.ResolvePulses; RSQSM_Clock.IsBonsaiPulse |
| X9 | adrenaline.add | C:2459 | RSQSM_Service.GetInt |
| X10 | Miniboss's window pulse is automatic, under the Boss switch, and never outlasts the window | C:467, C:607, C:1233, CVARINFO.txt:68, MENUDEF.txt:161 | RSQSM_Clock.ResolvePulses; RSQSM_Clock.MinibossWindow; RSQSM_Clock.WorldTick |
| X10 | start.bossfight: automatic, no shared cooldown | C:2555 | RSQSM_Service.GetInt |
| X10 | Its miniboss and thralls are special attackers; a Bossfight skips Heavy Hit's own cooldown | C:2218, C:2219, C:2251, C:2290 | RSQSM_Clock.SpecialKind; RSQSM_Clock.BossfightOn; RSQSM_Clock.HeavyHits |
| X10 | The DOWN target in a fight is the service's fight.target, not boosted | D:831, D:767, D:847 | RSQSM_Down.FightTarget; RSQSM_Down.Start; RSQSM_Down.AddTarget |
| X10 | arrow.add / arrow.clear | C:2454, C:2455, arrows.zs:43 | RSQSM_Service.GetInt; RSQSM_Arrows.AddArrow |
| X10 | With its meter size cvar present the bars use it in place of Bar Size | countdown.zs:107, countdown.zs:108 | RSQSM_Countdown.Slot |
| X11 | Locked Barrel asks RSQDG_ThrowService lockon.met | C:2141, C:2142, C:2104, CVARINFO.txt:104 | RSQSM_Clock.LockedBarrel; RSQSM_Clock.BarrelDeath |
| X12 | Grapple's four requests | C:2500, C:2501, C:2502, C:2503, CVARINFO.txt:108 | RSQSM_Service.GetInt |
| X12 | RSQGR_Fire slows with the world | C:1329 | RSQSM_Clock.SeriesRule |
| X13 | VisualRewards: the banner, the toast, the DOWN music scene | D:1432, D:1381, D:1446, D:1504 | RSQSM_Down.Banner; RSQSM_Down.Revive; RSQSM_Down.Toast; RSQSM_Down.DownMusic |
| X13 | The words over monsters | plate.zs:98, plate.zs:93, plate.zs:126 | RSQSM_Plate.Word; RSQSM_Plate.BonusTick |
| X13 | The bank: with its Kill Rewards handler and setting, banked armour is paid up to Bank Armour Cap (250) | D:1314, D:1348, D:1351, D:1305, CVARINFO.txt:142 | RSQSM_Down.BankAvailable; RSQSM_Down.Revive; RSQSM_Down.Bank |
| X13 | Its QVW glyphs draw the cause word when present | countdown.zs:226 | RSQSM_Countdown.DrawCause |
| X13 | An unrecognised pulse is Other Mods, automatic | C:468 | RSQSM_Clock.ResolvePulses |
| X14 | Glow In The Dark: down.redmap answers 1 while the console player is DOWN with Red Map on | C:2580, C:2582, C:2584, CVARINFO.txt:144 | RSQSM_Service.DownAsk |
| X14 | Fog Colour 7 takes the opposite hue of the sector's glow colour | downlook.zs:86, downlook.zs:88, downlook.zs:91 | RSQSM_Down.FogOf |
| X15 | DarkDoomZ: its ddz_mode set to 12 or 11 while DOWN, single player, and put back | downlook.zs:278, downlook.zs:281, downlook.zs:293, downlook.zs:303, downlook.zs:275, CVARINFO.txt:155 | RSQSM_Down.DdzTick; RSQSM_Down.DdzLet; RSQSM_Down.DdzMode |
| X16 | LiveReverb is found by its class DistanceCheckerCeiling; the sector's environment is 0 standing, its own while DOWN | reverb.zs:49, reverb.zs:69, reverb.zs:85, reverb.zs:92, CVARINFO.txt:121 | RSQSM_Reverb.WorldTick; RSQSM_Reverb.Hold |
| X17 | LegenDoom: the target is given its guaranteed legendary pickup; a legendary is a special attacker | D:1136, D:1144, C:2215 | RSQSM_Down.Boost; RSQSM_Clock.SpecialKind |
| X18 | Champions: found by its handler; a non-champion killer in the fight is swapped; the first candidate Champions makes a champion is the target | D:985, D:779, D:785, D:1014, D:1020 | RSQSM_Down.ChampionsOn; RSQSM_Down.Start; RSQSM_Down.ChampRoll |
| X18 | A target at 1 HP that is buddha, invisible and not shootable counts as killed; a champion is a special attacker | D:1235, D:1238, C:2216 | RSQSM_Down.WatchTargets; RSQSM_Clock.SpecialKind |
| X19 | A fast small enemy missile is slowed further, to the round speed | C:1503, C:1506 | RSQSM_Clock.FactorFor |
| X19 | Such a bullet is let through a leaning player | body.zs:55, body.zs:172 | RSQSM_Body.SlowedBullet; RSQSM_Body.LeanPass |
| X19 | The reload states, the grenade and over-under classes, the barrel by replacement | C:1826, C:1828, C:1830, C:1832, C:1834, C:1971, C:1972, C:2046 | RSQSM_Clock.HandReloading; RSQSM_Clock.BlastKind; RSQSM_Clock.BarrelClass |
| X19 | With the Sounds row off the heartbeat is heartbeat1 / heartbeat2 when that sound exists | D:491, D:492 | RSQSM_Down.Heartbeat |
| X20 | The rival classes; stood down unless rsm_yield is 0; the tick returns | C:245, C:250, C:1224, CVARINFO.txt:8 | RSQSM_Clock.RivalLoaded; RSQSM_Clock.StoodDown; RSQSM_Clock.WorldTick |
| X21 | Any other rsm_pulse: othermod, automatic, the Other Mods switch | C:468, C:676, CVARINFO.txt:67 | RSQSM_Clock.ResolvePulses; RSQSM_Clock.CatOn |

## For other mods

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| S1 | rsm_toggle: argument 1 the wrist cross, 2 the key, bare the Accessibility button when loaded | C:362, C:365, C:366, C:367 | RSQSM_Clock.NetworkProcess |
| S2 | rsm_on, rsm_off (stopping is never refused) | C:370, C:373, C:614 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.Aim |
| S3 | rsm_pulse: queued, resolved in the tick; 30 ms to 30 s, 5% to 100%, longer and slower win; not while held on | C:374, C:377, C:426, C:870, C:871, C:874, C:875, C:863, C:716 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.ResolvePulses; RSQSM_Clock.Pulse; RSQSM_Clock.Trigger |
| S4 | rsqsm_start:<who>: 0 ms is 4 s, 0 speed is the slider, flag 1 automatic, the Other Mods switch | C:388, C:390, C:391, C:393, C:790, C:791, C:792, C:787 | RSQSM_Clock.NetworkProcess; RSQSM_Clock.Start |
| S5 | rsqsm_burst, rsqsm_dodge, rsm_state | C:395, C:372, C:396 | RSQSM_Clock.NetworkProcess |
| S6 | The marker events read the same tic | C:381, C:384, C:385, C:386, C:387 | RSQSM_Clock.NetworkProcess |
| S7 | slowmo.active, active, scale, running | C:2461, C:2464, C:2465, C:2468 | RSQSM_Service.GetInt |
| S8 | trigger.auto, trigger.score | C:2475, C:2479, C:2483, C:2486 | RSQSM_Service.GetInt |
| S9 | adrenaline.add, adrenaline, countdown | C:2459, C:2460, C:2558 | RSQSM_Service.GetInt |
| S10 | start, start.auto, start.bossfight, start.barrel, start.reward, stop | C:2506, C:2507, C:2551, C:2555, C:2526, C:2527, C:2540, C:2546, C:2528, C:2530 | RSQSM_Service.GetInt |
| S11 | g2.slow, g2.addtime, g2.slam, g2.fullspeed | C:2500, C:2501, C:2502, C:2503 | RSQSM_Service.GetInt |
| S12 | arrow.add, arrow.clear; 32 at most | C:2450, C:2454, C:2455, arrows.zs:30, arrows.zs:53 | RSQSM_Service.GetInt; RSQSM_Arrows.AddArrow |
| S13 | down, down.hold, down.any, down.redmap, down.left | C:2578, C:2579, C:2580, C:2586 | RSQSM_Service.DownAsk |
| S14 | down.count, down.uphealth, down.owed, down.killed, down.mark | C:2591, C:2596, C:2597, C:2599, C:2600, C:2607 | RSQSM_Service.DownAsk |
| S15 | down.target through GetInt: 0, or 1 to 3 by the clock's third | C:2517, C:2523, C:2524 | RSQSM_Service.GetInt |
| S16 | down.bank | C:2564, D:1305 | RSQSM_Service.GetInt; RSQSM_Down.Bank |
| S17 | GetIntUI: countdown, the down requests, countdown.bottom, menu.locked | C:2615, C:2616, C:2617, C:2625, C:2628 | RSQSM_Service.GetIntUI |
| S18 | GetObject answers null; the class overrides only GetInt, GetObject and GetIntUI | C:2447, C:2570, C:2572, C:2612 | RSQSM_Service |
| S19 | The join: services named RSQDownJoin are told each event | D:1575, D:1578, D:764, D:858, D:666, D:1292, D:1387, D:1390, D:1464 | RSQSM_Down.Tell |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | KEYCONF has two menu keys and no default bind line | KEYCONF.txt:3, KEYCONF.txt:5 | KEYCONF |
| L2 | The only button bits read are the reload buttons; the stick is read for the dive and the lean | C:1860, C:1070, body.zs:106 | RSQSM_Clock.Reloads; RSQSM_Clock.Dodges; RSQSM_Body.LocalHead |
| L3 | A trigger and the burst are refused while held on | C:716, C:890 | RSQSM_Clock.Trigger; RSQSM_Clock.Burst |
| L4 | One scale and one meter in the handler | C:62, C:70 | RSQSM_Clock |
| L5 | A new level starts with the hold off and the scale at 1 | C:267 | RSQSM_Clock.WorldLoaded |
| L6 | MAXSCAN 4000; only actors near a player are gathered | C:126, C:1407, C:1458 | RSQSM_Clock.Consider; RSQSM_Clock.Gather |
| L7 | A player's shot, a melee attack or a reach of 128 or less is never a round | round.zs:25, round.zs:27 | RSQSM_Shots.WorldHitscanPreFired |
| L8 | Classes named rsq, ubqs, ssq are real time unless on the SLOW or DIES_SLOW list | C:1354, C:1355, C:1320, C:1333, C:1342 | RSQSM_Clock.ClassRule; RSQSM_Clock.SeriesRule |
| L9 | RELOAD_CAP_MS 10000 | C:1788, C:1915 | RSQSM_Clock.Reloads |
| L10 | Close Call skips missiles with Speed 40 or more and a player's own | C:1177, C:1188 | RSQSM_Clock.WatchCloseCall; RSQSM_Clock.CloseCalls |
| L11 | DODGE_MAX_TICS is 6 seconds | C:1019, C:1036 | RSQSM_Clock.Dodges |
| L12 | Stood down: the clock's tick returns, a held start returns, DOWN is not armed | C:1224, C:612, D:343 | RSQSM_Clock.WorldTick; RSQSM_Clock.Aim; RSQSM_Down.Armed |
| L13 | The hold is not taken when the buddha flag is already set, and DOWN needs the hold | D:353, D:699 | RSQSM_Down.Hold; RSQSM_Down.PlayerHit |
| L14 | Without Score's service the lives watch returns before any reset; each DOWN adds one to the count | D:425, D:432, D:731, D:218, D:1407 | RSQSM_Down.WatchLives; RSQSM_Down.Start |
| L15 | The panel, the plate and the grey world are the console player's; DarkDoomZ needs single player | downhud.zs:265, D:399, downlook.zs:102, downlook.zs:281 | RSQSM_DownHud.Draw; RSQSM_Down.WorldTick; RSQSM_Down.LookTick; RSQSM_Down.DdzTick |
| L16 | Nothing is drawn over a menu or the automap | countdown.zs:307, downhud.zs:264, arrows.zs:123 | RSQSM_Countdown.RenderOverlay; RSQSM_DownHud.Draw; RSQSM_Arrows.RenderOverlay |
