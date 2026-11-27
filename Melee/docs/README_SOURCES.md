# RSQ Melee: where each README claim comes from

Commit read: 50f608e63 (2026-11-27). Paths are inside `Melee/`. `G` is `zscript/rsqml/gloves.zs`, `C` is
`zscript/rsqml/core.zs`, `S` is `zscript/rsqml/shove.zs`, `H` is `zscript/rsqml/headlock.zs`, `K` is
`zscript/rsqml/club.zs`, `D` is `zscript/rsqml/guard.zs`, `T` is `zscript/rsqml/twohand.zs`, `Y` is
`zscript/rsqml/gestcopy.zs`, `B` is `zscript/rsqml/barrelfly.zs`, `P` is `zscript/rsqml/sparks.zs`, `L` is
`zscript/rsqml/slappers.zs`, `W` is `zscript/rsqml/splat.zs`, `N` is `zscript/rsqml/launch.zs`, `V` is
`zscript/rsqml/service.zs`, `A` is `zscript/rsqml/a11y.zs`; other files are named in full (`handsync.zs` and
`rsmenu.zs` are in `zscript/rsqml/`). Each line number is the line that does the thing, not the start of its function.
`H<n>` is the n-th row of How to play, `W<n>` the n-th row of Works with, `L<n>` the n-th Limit, in the README's order.
A default named in a claim is cited at its CVARINFO line.

Numbers a claim gives for Guard, Hadouken, Heavy Hands, Wall Splat, Ground Pound and Clear Out are the fallback each
`RSQML.Num(...)` call carries, used when RSQ Gun Bonsai VR is not loaded (`C:145`). The two-hand thresholds (H36, H37)
are the defaults in Melee's own copy of the reader, used when `RSQG_Service` is not loaded.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | A hand is read only while it holds a fist: an empty hand, a glove (RSQ_Glove*, SPO_Glove*), Doom's Fist | G:325, G:332, G:487, G:489 | RSQML_Gloves.FistIn; IsFist; WorldTick |
| H1 | Brutal Doom's fists and BD22 VR's free off fist only while rsqml_bdfists is on (default true) | G:335, G:338, G:341, CVARINFO.txt:16 | RSQML_Gloves.IsFist |
| H2 | Arms on a hand under 0.6 x Min Speed, the rehit wait over; travel counts at 0.25 m/s or more for at most 14 tics | G:569, G:572, G:230, G:231 | RSQML_Gloves.Swing |
| H2 | A punch after 0.15 m of travel averaging Min Speed (2.0); the hand is measured against the body at the view's height | G:587, G:229, G:589, G:530, G:505, CVARINFO.txt:22 | RSQML_Gloves.Swing; Read |
| H2 | The whoosh on the tic the swing arms, only for a swing forward or rising | G:594, G:1286 | RSQML_Gloves.Swing; SwingsOut |
| H3 | Contact: the fist a sphere of 0.09 m plus rsqml_punch_pad (4) against the body's cylinder, with no wall between | G:599, G:600, G:731, G:733, CVARINFO.txt:27 | RSQML_Gloves.Swing; Contact |
| H3 | The blow must drive toward the body; then Deliver | G:632, G:633 | RSQML_Gloves.Swing |
| H3 | Power 0..1 between Min Speed and Full Speed (7); damage Punch Damage (10) x (1 + power); blood; one DamageMobj | G:1320, G:1364, G:1406, G:1407, CVARINFO.txt:23, CVARINFO.txt:29 | RSQML_Gloves.Deliver |
| H3 | Spark sized by power; buzz in that hand; knock (2 + 6 x power) x 100 / mass along the fist's way | G:1402, P:52, G:1416, G:1429, G:1433 | RSQML_Gloves.Deliver; RSQML_Spark.Punch |
| H3 | The hand is disarmed after a hit and arms again after rsqml_punch_rehit (6) tics | G:634, G:639, G:531, CVARINFO.txt:24 | RSQML_Gloves.Swing |
| H4 | Not rising and not a hook is a jab; jab1, jab2, jab3 in turn | G:448, G:1266, G:1267 | RSQML_Gloves.Classify; HitSound |
| H5 | A hook: sideways share over 0.6 and over the forward share; hookr or hookl by the hand swung | G:447, G:1258, G:1259 | RSQML_Gloves.Classify; HitSound |
| H5 | Jab and hook share one damage line and one knock line (no branch on the kind) | G:1364, G:1433 | RSQML_Gloves.Deliver |
| H6 | Uppercut: the swing's path or its last tic rising past rsqml_punch_uppercut_rise (0.5) | G:462, G:1312, CVARINFO.txt:25 | RSQML_Gloves.ClassifySwing; Deliver |
| H6 | Lift (5 + 4 x power) x 100 / mass (0.1 to 1.5), a boss x 0.3; back (2 + 3 x power); staggered for the air time | G:1432, G:1487, G:1488, G:1492, G:1500, G:1503 | RSQML_Gloves.Launch |
| H6 | No launch above rsqml_punch_lift_cap (3 m) | G:1497, G:1498, CVARINFO.txt:26 | RSQML_Gloves.Launch |
| H7 | A counter: the monster in its Missile or Melee states; the red spark | G:1335, C:209, C:211, P:51 | RSQML_Gloves.Deliver; RSQML.InAttack; RSQML_Spark.Punch |
| H7 | Arcade only: the red burst and COUNTER!, the word through RSQVR_Service; Impact Words on by default | P:240, P:244, P:254, P:279, P:284, CVARINFO.txt:92 | RSQML_Impact.Hit; Word |
| H8 | Hard is power 0.67 or more, or a kill; the big burst; shards on every blow | P:242, P:247, P:249 | RSQML_Impact.Hit |
| H8 | Hit stop: a living monster held 2 + round(3 x power) tics; rsqml_hitstop (true) | P:251, P:252, CVARINFO.txt:93 | RSQML_Impact.Hit |
| H8 | The words; FATALITY! on a kill; one word a player every 14 tics; Arcade is the default | P:278, P:279, P:230, P:277, CVARINFO.txt:91 | RSQML_Impact.Word |
| H9 | Any PowerStrength: damage x 5 | G:1377, G:1378 | RSQML_Gloves.Deliver |
| H10 | No body met: a line with a special along the fist's path this tic is worked (Use, UseThrough, Push or Impact); a buzz | G:602, G:613, G:617, C:254, C:257 | RSQML_Gloves.Swing; RSQML.UseLineAlong |
| H11 | An uppercut meeting a barrel, with Barrel Launch on (default true): launched, no damage | G:606, G:676, G:688, B:91, CVARINFO.txt:32 | RSQML_Gloves.Swing; KickBarrel; RSQML_FlyingBarrel.Launch |
| H11 | 28 units a tic to the nearest living foe it can see within 1536; with none, the way it was hit | B:19, B:21, B:56, B:78, B:85 | RSQML_FlyingBarrel.Nearest; Launch |
| H11 | Goes off on a wall, floor or ceiling, a foe, or after 105 tics; the barrel's own class put back and blown up with you as its target | B:127, B:139, B:142, B:22, B:147, B:151, B:154 | RSQML_FlyingBarrel.Tick; Boom |
| H12 | A press of that hand's fire let go within 10 tics, no punch landed since the press, flips fist and open palm; a click | G:280, G:283, G:244, G:285, G:286 | RSQML_Gloves.TapShape |
| H12 | An open palm does not punch; only RSQ_Glove's own Ready states draw an open hand | G:555, G:559, G:131, G:70 | RSQML_Gloves.Swing; RSQML_HandLook.Look; RSQ_Glove states |
| H13 | Open palm at SWAT_MPS (1.5) or more, rsqml_swat on (default true), meets a monster's missile on its path | G:554, G:1163, G:1176, CVARINFO.txt:18 | RSQML_Gloves.Swing; Swat |
| H13 | Knocked aside at its own speed and made yours; slap, buzz, spark | G:1198, G:1201, G:1202, G:1208, G:1209, G:1210 | RSQML_Gloves.Swat |
| H14 | A monster's hitscan, rsqml_bullets on (default true): the hand's path within reach of the shot's line, between shooter and player | G:859, G:860, G:890, G:892, G:895, CVARINFO.txt:19 | RSQML_Gloves.WorldHitscanPreFired |
| H14 | The shot is cancelled; with no Swat Back level nothing is sent back | G:896, G:898, G:910 | RSQML_Gloves.WorldHitscanPreFired |
| H15 | The main hand only; a gun is a ready weapon that is not a fist and not flagged melee | S:205, S:223, S:245, S:246 | RSQML_Shove.Swing; GunIn |
| H15 | 0.15 m of travel averaging 2.0 m/s is a swing; not drawn back, not swung down; then rsqml_shove_mps (3.6) | S:217, S:219, S:227, S:277, S:278, S:279, CVARINFO.txt:50, CVARINFO.txt:51 | RSQML_Shove.Swing; ShoveAct |
| H15 | 12 tics between shoves; the envelope is 60 units along the swing from the hand, padded 12, each body with a clear line | S:284, S:59, S:342, S:57, S:58, S:359, S:361 | RSQML_Shove.ShoveAct; ButtShove |
| H15 | No damage: a thrust of 800 / mass (1 to 12) away from you, the Pain state (not NOPAIN, not a boss) | S:366, S:379, S:433, S:435, S:438 | RSQML_Shove.ButtShove; ShoveHit |
| H15 | Extra knock by class: ZombieMan and ShotgunGuy back 10 up 7.5, DoomImp back 5 up 5, others up only | S:421, S:422, S:425, S:445 | RSQML_Shove.KnockOf; Knock |
| H15 | Swing sound, hit sound, alert 200, buzz in the main hand | S:343, S:393, S:395, S:62, S:396 | RSQML_Shove.ButtShove |
| H16 | A shove that landed, from the shover's machine: rsm_pulse with rsqml_shove_slowmo_ms (1000, clamped 30 to 2000) at 35 | S:389, S:398, S:406, S:407, S:408, S:63, CVARINFO.txt:54, CVARINFO.txt:59 | RSQML_Shove.ButtShove; Pulse |
| H17 | The window opens with the pulse and stays only while RSQSM_Service says slowmo.active | S:410, S:300, S:554, S:556 | RSQML_Shove.Pulse; NetworkProcess; FearTick |
| H17 | The shover's shotgun hit on a monster: blood spawned again | S:620, S:622, S:628, S:631, S:564 | RSQML_Shove.WorldThingDamaged; IsShotgun |
| H17 | A kill: blood mist with rsqml_fear_mist (true), the extreme death, the award to RS_ScoreService, the name on screen 52 tics | S:636, S:638, S:639, S:519, S:520, S:703, S:737, CVARINFO.txt:63 | RSQML_Shove.WorldThingDamaged; RenderOverlay; RSQML_FearMark.ModifyDamage |
| H18 | No body struck: a line with a special within 60 units along the shove is worked; a buzz | S:388 | RSQML_Shove.ButtShove |
| H19 | Sent for any gun swing (2.0 m/s), before the shove's own speed test, while Barrel Launch is on | S:235, S:254, S:261, S:52 | RSQML_Shove.Swing; ShoveAct |
| H19 | The nearest barrel within 72 units of the gun hand and within 60 degrees of the shove is launched | S:304, S:320, S:324, S:327 | RSQML_Shove.BarrelShove |
| H20 | rsqml_barrel_slowmo (true): RSQSM_Service start.barrel for 3000 ms, stop when it goes off | B:100, B:103, B:24, B:157, CVARINFO.txt:33 | RSQML_FlyingBarrel.Launch; Boom |
| H21 | The off grip is read by raw key code from rsqml_keys_off ("443 436") and eaten when the Headlock takes it | H:82, H:92, H:98, H:99, CVARINFO.txt:88 | RSQML_Headlock.InputProcess |
| H21 | The nearest living monster within rsqml_headlock_reach (0.30 m) of the off palm, not a boss, not over rsqml_headlock_mass (400) | H:122, H:124, H:126, H:127, H:143, H:144, H:151, CVARINFO.txt:80, CVARINFO.txt:81, CVARINFO.txt:82 | RSQML_Headlock.FindMonster |
| H21 | Held frozen for rsqml_headlock_secs (3); its face (0.85 of its height) at the hand's height, turned to you; a buzz in the off hand | H:209, H:237, H:334, H:372, H:362, H:385, H:248, CVARINFO.txt:83 | RSQML_Headlock.NetworkProcess; StartCollar; TickCollars; Hold |
| H22 | The grip up ends the hold; so do the hold time, your death or its death | H:104, H:204, H:325 | RSQML_Headlock.InputProcess; NetworkProcess; TickCollars |
| H23 | The off hand holding a monster is not a fist for the reader | G:486 | RSQML_Gloves.WorldTick |
| H24 | Each blow on the held monster is a step: x1, x1.5, x2.5; rsqml_headlock_combo (true) | G:1372, G:1373, H:266, H:270, CVARINFO.txt:94 | RSQML_Gloves.Deliver; RSQML_Headlock.ComboStep; ComboMult |
| H24 | The third: let go, 4 tics of hit-stop, then 26 units a tic x 100 / mass (0.35 to 1.6) away from you | G:1412, H:280, H:285, H:287, H:276, H:291, H:275, H:293 | RSQML_Gloves.Deliver; RSQML_Headlock.ComboFinish |
| H24 | Each monster it meets: 10 to 150 by its speed, shoved along, staggered 24 tics | H:667, H:673, H:675, H:676, H:637 | RSQML_Bowl.Tick |
| H25 | Any damage of yours on the monster you hold: its pain sound and its pain frame for 6 tics | H:576, H:578, H:579, H:392 | RSQML_Headlock.WorldThingDamaged |
| H25 | Extra blood 0.3, 0.6, then 1.0 of the blow; rsqml_headlock_blood (true) | H:581, H:584, H:587, CVARINFO.txt:86 | RSQML_Headlock.WorldThingDamaged |
| H26 | The off palm against the body, across the ground within 60 degrees of facing; a peak of rsqml_headlock_throw (3.0) then under 0.6 of the peak | H:434, H:455, H:460, H:462, CVARINFO.txt:85 | RSQML_Headlock.ThrowSwing |
| H26 | Let go, in its Pain state; its velocity the hand's (fastest 2-tic average of the last 6); counted as rsqml_headlock_weight (30) percent | H:465, H:466, H:467, H:472, H:494, CVARINFO.txt:87 | RSQML_Headlock.ThrowSwing; PalmVel |
| H26 | Melee's own toss: a wall or a body met at 3 m/s or more hurts it and the body by the energy over 15 joules a point | H:500, H:724, H:704, H:731, H:734, H:735 | RSQML_Headlock.ThrowSwing; RSQML_Tossed.DoEffect |
| H27 | The club runs only with BrutalWeapon, RSVR_MeleeHandler and RSVR_MeleeYield present; the eight long guns with rsqml_butt (1) | K:288, K:289, K:557, K:559, K:566, CVARINFO.txt:68 | RSQML_Club.On; RSQML_ClubHand.KindOf |
| H27 | Needs the engine's two-hand steadying, rsqml_butt_speed (2.4 m/s) at the stock, rsqml_butt_fwd (0.5) of it forward, not muzzle-led | K:726, K:748, K:749, K:750, CVARINFO.txt:69, CVARINFO.txt:70 | RSQML_ClubHand.Tick |
| H27 | Bodies on the gun's path and within 90 units ahead of the stock (pad 16): the shove's hit, no damage; the pulse once a swing; a line worked | K:766, K:771, K:474, K:475, K:891, K:912, K:774 | RSQML_ClubHand.Tick; Sweep; Strike |
| H28 | Pistol whip: BrutalPistol, Revolver, BrutalRevolver in the main hand, their off-hand classes in the off hand; rsqml_pistol_whip (true) | K:568, K:569, K:582, K:583, CVARINFO.txt:71 | RSQML_ClubHand.KindOf; KindOfOff |
| H28 | rsqml_whip_speed (5.0 m/s) at the muzzle, rsqml_whip_down (0.25) of it downward | K:727, K:742, CVARINFO.txt:72, CVARINFO.txt:73 | RSQML_ClubHand.Tick |
| H28 | Lands MeleeStrikeNormal (MeleeStrike1Berserked under the Berserk), a second at twice the swing needed; the whip sound; AxeAttack into a wall | K:884, K:886, K:878, K:968 | RSQML_ClubHand.Strike; WallCheck |
| H29 | Boxing Gloves (default false): at a map start or respawn, 3 tics in, the two gloves are given, not raised | L:80, L:84, L:93, L:115, L:152, L:153, CVARINFO.txt:12 | RSQML_Slappers.PlayerEntered; PlayerRespawned; WorldTick; GiveGloves |
| H29 | The glove class asks for slot 1; with Boxing Gloves or Slappers Only on it draws as the boxing glove and never opens | G:43, G:116, G:130, G:272 | RSQ_Glove Default; RSQML_HandLook.Gloved; Look; RSQML_Gloves.PalmOpen |
| H30 | Slappers Only (default false) flipped on: gloves given, every weapon but the gloves, Fist, Melee_Attacks and RSQ_Hands stashed, gloves put on both hands | L:95, L:109, L:62, L:63, L:208, CVARINFO.txt:6 | RSQML_Slappers.WorldTick; IsGun; Strip |
| H30 | Weapon pickups become nothing; a weapon given later goes within 8 tics; off, the stash comes back with the ammo you had | L:50, L:73, L:125, L:111, L:238, L:241 | RSQML_Slappers.CheckReplacement; WorldThingSpawned; WorldTick; Restore |
| H31 | Guard row (default false) at level 1; only with Gloved() and a glove as the ready weapon, the off hand empty or a glove | C:79, D:72, D:160, D:161, D:162, CVARINFO.txt:39 | RSQML.MoveLevel; RSQML_Guard.GuardLevel; GuardHands |
| H31 | Both hands within 0.35 m of the pawn across, 0.25 m below to 0.15 m above the eyes, for 4 tics | D:124, D:20, D:21, D:22, D:13, D:203 | RSQML_Guard.Pose; Soak |
| H31 | A blow from within 55 degrees: 60% of it, a push back, the flash and tick, a buzz in both hands | D:210, D:14, D:261, D:263, D:265, D:266, D:267, D:389 | RSQML_Guard.Soak; RSQML_Body.ModifyDamage |
| H31 | 35 or more breaks it: full damage, no Guard for 14 tics | D:249, D:250, D:253, D:15, D:258 | RSQML_Guard.Soak |
| H32 | Hadouken row (default false): a fist at Min Speed or more, read every tic, meets a monster's missile within 256 units | G:561, G:563, G:1020, G:1026, CVARINFO.txt:40 | RSQML_Gloves.Swing; ReturnFire |
| H32 | Sent at its shooter at speed x 1.15, hitting for x 1.5 | G:1029, G:1030, G:952, D:404 | RSQML_Gloves.ReturnFire; SendBack; RSQML_Body.ModifyDamage |
| H33 | A fist needs the Hadouken for a bullet; the round flies from the hand at the shooter with the shot's damage x 1.5 | G:897, G:901, G:902, G:924, G:929 | RSQML_Gloves.WorldHitscanPreFired; ReturnBullet |
| H34 | Heavy Hands row (default false): knock x 1.25; frozen 2 tics, 4 at power 0.5 or more; chicks and stars | G:1420, G:1430, G:1437, G:1439, G:1440, CVARINFO.txt:42 | RSQML_Gloves.Deliver |
| H35 | Wall Splat row (default false): armed 12 tics by a punch; a wall refusing its move at 3 units a tic or more | G:1445, G:1446, W:19, W:20, W:43, CVARINFO.txt:41 | RSQML_Gloves.Deliver; RSQ_Splat.DoEffect |
| H35 | 10 to 20 damage by speed, bounced back at 0.45, frozen 5 tics, staggered 15 | W:56, W:79, W:21, W:80, W:81 | RSQ_Splat.Slam |
| H36 | Ground Pound row (default false); a glove (RSQ_Glove) in both hands; the event's speed 3.0 or more | T:78, T:127, T:130, T:132, T:134, CVARINFO.txt:44 | RSQML_TwoHand.NetworkProcess; Pound |
| H36 | Melee's own reader: each hand 2.0 m/s down, half or more of its speed downward, 0.60 m below the eyes, within 120 ms; the slower hand's speed is sent | Y:286, Y:289, Y:290, Y:292, Y:314, Y:344, Y:380 | RSQML_GCopy.TwoHand; Announce |
| H36 | 30 damage within 2.5 m, thrown out 4 and up 3 by weight, staggered 15 tics; thud, pixel ring, quake, buzz in both hands | T:135, T:136, T:155, T:156, T:158, T:23, T:160, T:163, T:164, T:165 | RSQML_TwoHand.Pound |
| H37 | Clear Out row (default false); nothing but RSQ_Glove in either hand, and a glove in a hand to give the level | T:79, T:174, T:177, T:39, T:40, CVARINFO.txt:45 | RSQML_TwoHand.NetworkProcess; ClearOut; Best |
| H37 | Melee's own reader: each hand 2.5 m/s forward, 0.6 of its speed, pitched 20 degrees or more, not below the 0.60 m line, hands 0.25 m apart sideways | Y:298, Y:299, Y:300, Y:331, Y:332, Y:355, Y:356 | RSQML_GCopy.TwoHand |
| H37 | 15 damage within 2.5 m and 45 degrees either side, in sight; push 14 by weight; staggered 10 tics | T:179, T:180, T:181, T:182, T:199, T:25, T:201, T:209 | RSQML_TwoHand.ClearOut |
| H38 | Human Shield row (default false): the hold lasts 60 seconds at most while the grip is held, the monster faces the way you face | H:255, H:237, H:385, CVARINFO.txt:84 | RSQML_Headlock.ShieldOn; StartCollar; Hold |
| H39 | With Barrel Launch off and Uppercut Barrels (default false) on: up 5 to 9 under the lift cap, as fast forward, no damage, you its target | G:606, G:679, G:688, G:691, G:692, G:694, CVARINFO.txt:34 | RSQML_Gloves.Swing; KickBarrel |
| H40 | VR Punch (rsqml_bd_punch, default 0), only while the club runs: Melee_Attacks in the main hand or RSQ_Hands' free closed hand | K:393, K:438, K:441, K:442, CVARINFO.txt:75 | RSQML_Club.WorldTick; Punches |
| H40 | 2.5 m/s, 0.7 of it forward, the hand 0.25 m ahead, 0.15 m of forward travel; Brutal Doom's strike actor flies from the hand | K:1010, K:1012, K:1013, K:1014, K:1056, K:1059, K:1066 | RSQML_BDPunch.Tick |
| H40 | Melee's own punch then deals no damage and still does the rest | G:432, G:1401, G:1404 | RSQML_Gloves.BD22Punches; Deliver |
| H41 | Star Punch: Gun Bonsai VR level on a glove, a banked star, an uppercut, that hand's fire or alt fire down | G:1349, G:1353, G:1354, G:1355 | RSQML_Gloves.Deliver |
| H41 | The star sound and a longer, stronger buzz; a star banked on a counter, the first landed punch and every second after, 3 at most | G:1414, G:1416, G:1464, G:1466, G:1469 | RSQML_Gloves.Deliver |
| H42 | Juggle: the glove's level, the monster this player launched still off the floor, within 70 tics: launched again | G:1362, G:1363, G:1477, G:1432, N:40 | RSQML_Gloves.Deliver; RSQML_Launched.AgeFor |
| H43 | Catch: the glove's level, an open palm under 1.5 m/s, a monster's missile at the palm still coming in; held at the hand | G:1111, G:1112, G:1121, G:1107 | RSQML_Gloves.CatchTick |
| H43 | Thrown by the hand at Min Speed or more, 6 tics after the catch, onto a monster within 12 degrees; held past its time it goes off | G:1087, G:1091, G:1138, G:1099, G:1103 | RSQML_Gloves.CatchTick; CatchAim |
| H44 | Parry: a player node; both hands driven forward at 1.0 m/s, the push and the Guard both inside the node's window | D:200, D:142, D:34, D:147, D:202 | RSQML_Guard.Soak; Pose |
| H44 | No damage; the attacker knocked back and staggered | D:222, D:224, D:233 | RSQML_Guard.Soak |
| H45 | rsqg_pair kind 1 (both hands apart): the Guard's charge released if there is one, else the Taunt | T:80, T:84, D:289, D:290, D:303, D:307 | RSQML_TwoHand.NetworkProcess; RSQML_Guard.Release |
| H45 | Taunt: a player node; monsters in range that see you target you; the next punch in the window does double | T:100, T:113, T:114, T:105, G:1383 | RSQML_TwoHand.Taunt; RSQML_Gloves.Deliver |
| H46 | Slam: the off glove's level; the off hand's move this tic 0.7 or more downward at the node's speed | H:444, H:449, H:451 | RSQML_Headlock.ThrowSwing |
| H46 | Let go, put on the floor, hurt by mass, weight share and speed squared; monsters round it staggered | H:536, H:538, H:543, H:558, H:562 | RSQML_Headlock.Slam |
| H47 | Headlock Uppercut: the off glove's level, an uppercut on the monster you hold: more damage, let go, a higher launch | G:1369, G:1370, G:1423, G:1432 | RSQML_Gloves.Deliver |
| H48 | Brutal Doom Fists off: Melee_Attacks (and what is made from it) and RSQ_Hands are not fists | G:335, G:338, G:358 | RSQML_Gloves.IsFist; BDFistsOn |
| H49 | Palm Swat off: the open palm swats nothing | G:554 | RSQML_Gloves.Swing |
| H50 | Gun Butt Shove off: no shove; with BD22 VR Reloaded and Brutal Doom loaded the reader runs on Shove Slow Mo instead | S:277, S:125, S:138 | RSQML_Shove.ShoveAct; Wanted; WorldTick |
| H51 | Headlock off: no monster is found, so the press is never claimed or eaten | H:122, H:181, H:194 | RSQML_Headlock.FindMonster; ClaimNow; WorldTick |
| H52 | Impact Style Classic (0): Hit returns at once; the spark is spawned by Deliver before it | P:233, P:240, G:1402 | RSQML_Impact.Arcade; Hit; RSQML_Gloves.Deliver |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Gun Bonsai VR: RSQ_MeleeUpgradeService, only while it answers loaded 1; numbers by upgrade.num | C:62, C:63, C:145 | RSQML.GBAny; GB; Num |
| W1 | With it: the row off is level 0, else the glove's or the player's level; a fist that is no glove plays the row; the Uppercut on a glove is its level | C:75, C:76, C:77, C:103, C:113, G:1324 | RSQML.MoveLevel; UnlockLevel; FistLevel; RSQML_Gloves.Deliver |
| W1 | The greyed rows and the answer behind them; Start With Guard | MENUDEF.txt:54, MENUDEF.txt:56, MENUDEF.txt:60, MENUDEF.txt:64, MENUDEF.txt:66, V:70, D:73 | MENUDEF RSQML_Options; RSQML_Service.GetIntUI; RSQML_Guard.GuardLevel |
| W1 | Its other nodes read here by name | G:1490, G:536, G:1388, G:1166, G:1040, D:95, T:138, H:129, H:337, H:480, S:583, S:588 | RSQML_Gloves.Launch; Swing; Deliver; Swat; ReturnFire; RSQML_Guard.WorldTick; RSQML_TwoHand.Pound; RSQML_Headlock.FindMonster; TickCollars; ThrowSwing; RSQML_Shove.GunHand |
| W1 | A glove is its own inflictor; other blows of a glove are claimed for it | G:386, C:154 | RSQML_Gloves.FistInflictor; RSQML.Claim |
| W2 | Distance Grab: near.dist decides the press; -2 means the hand is Distance Grab's | H:182, H:184, H:185, H:186 | RSQML_Headlock.ClaimNow |
| W2 | The throw handed to headlock.throw; headlock.caught for the catch | H:482, H:248 | RSQML_Headlock.ThrowSwing; StartCollar |
| W2 | Barrel Lock-On: lockon.kick takes the uppercut's barrel; lockon.on turns the kick on | G:686, G:712, G:606 | RSQML_Gloves.KickBarrel; LockOnKicks; Swing |
| W3 | SlowMo: rsm_pulse; start.barrel and stop; slowmo.active; scale | S:408, B:103, B:157, S:554, P:353, P:396, P:456, H:654 | RSQML_Shove.Pulse; FearTick; RSQML_FlyingBarrel.Launch; Boom; RSQML_Clock.W; RSQML_Ring.Tick; RSQML_PixelWave.Tick; RSQML_Bowl.Tick |
| W3 | The butt strike asks for the same pulse | K:912 | RSQML_ClubHand.Strike |
| W4 | Score: touch by move id; grab.hold every 70 tics; the award | C:122, H:347, H:350, S:376, G:1031, W:76, T:148, S:638 | RSQML.Touch; RSQML_Headlock.TickCollars; RSQML_Shove.ButtShove; WorldThingDamaged |
| W4 | punch.* answered from the glove or the fist helper | V:79, V:87, V:100 | RSQML_Service.GetInt |
| W5 | VisualRewards: the word asked of RSQVR_Service worldword; nothing else draws it | P:281, P:284 | RSQML_Impact.Word |
| W6 | Accessibility: settings count only while RSQA_Menu exists; Rumble Strength; Rumble Backup | A:27, C:349, C:351, C:369 | RSQML_A11y.Cv; RSQ_Buzz.Start; Tick |
| W6 | Off-Hand Modifier: the controller for a hand; the shove is not read while it is held | A:83, C:281, S:159, S:167 | RSQML_A11y.Ctrl; RSQML_Hands.Pos; RSQML_Shove.Read |
| W6 | Seated Play: the Guard's box lowered by the seat drop | D:117 | RSQML_Guard.Pose |
| W6 | RSQG_Service asked for pair.ago; Melee's copy only without it | T:62, T:64, T:67, Y:171, Y:379 | RSQML_TwoHand.WorldTick; RSQML_GCopy.WorldTick; Announce |
| W7 | Tactical Rig: the off hand in a rig region (rig.region 0 or more) is never the Headlock's | H:111, H:114, H:178 | RSQML_Headlock.RigBusy; ClaimNow |
| W8 | Grapple: climbing, swinging or reeling quiets the shove and the copy's two-hand events, and 9 tics after | S:191, S:195, S:197, S:46, S:181, Y:256, Y:283 | RSQML_Shove.Quiet; Read; RSQML_GCopy.Quiet; TwoHand |
| W9 | Wheel: wr_RigService IsOpen does the same | S:192, S:196, Y:257 | RSQML_Shove.Quiet; RSQML_GCopy.Quiet |
| W10 | Miniboss: a monster carrying RSQMB_Ward for which RSQMB_Service bossfor headlock is 1 is refused | H:152, H:164, H:168 | RSQML_Headlock.FindMonster; MinibossRefuses |
| W11 | BD22 VR Reloaded with RSVR_MeleeYield: the club runs; owns answers 1; the shove leaves its guns alone | K:289, V:51, V:52, S:263, S:268 | RSQML_Club.On; RSQML_Service.Owns; RSQML_Shove.ShoveAct |
| W11 | Its settings copied once; rsq_butt is not | K:320, K:336, K:341, K:349 | RSQML_Club.WorldLoaded; Migrate |
| W11 | Hand Model Auto: the FBX hand when RSQ_HandTone exists; its rsq_hand_tone worn | G:115, G:124, G:158 | RSQML_HandLook.BD22VR; UseFbx; Tone |
| W12 | Without RSVR_MeleeYield: ours does nothing; its KickAttack near your shove asks for the pulse | S:270, S:273, S:333, S:140, S:502 | RSQML_Shove.ShoveAct; ButtShove; WorldTick; WatchBDButt |
| W13 | Brutal Doom: Melee_Attacks and what is made from or replaces it is a fist; barrels by the replacement chain; its mist by name; its swing sound | G:365, G:650, S:665, S:343 | RSQML_Gloves.IsBDFistClass; IsBarrel; RSQML_Shove.FearMist; ButtShove |
| W14 | SuperPunchOut: a class named SPO_Glove... is a glove | C:171 | RSQML.IsGloveName |
| W15 | RSQML_Service: the requests it answers | V:77, V:78, V:116, V:123, V:130, V:138, V:143, V:144, V:151, V:157, V:163, V:169, V:178, V:183, V:195, V:196, V:61 | RSQML_Service.GetInt; GetDouble; GetIntUI |
| W15 | RSQML_GCopyService: reader, pair.reader, pair.ago | Y:406, Y:407, Y:411 | RSQML_GCopyService.GetInt |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Out of VR, or with both hand fields equal, no hand position is given | C:279, C:280 | RSQML_Hands.Pos |
| L2 | KEYCONF holds comments only; the only button reads; the grip by key code | KEYCONF.txt:1, G:280, G:1353, K:416, Y:274, H:92 | KEYCONF; RSQML_Gloves.TapShape; Deliver; RSQML_Club.SendPose; RSQML_GCopy.PalmOut; RSQML_Headlock.InputProcess |
| L3 | Three kinds of punch only; an open palm returns before any punch; the shove needs a gun | G:226, G:559, S:223 | RSQML_Gloves; Swing; RSQML_Shove.Swing |
| L4 | Jab and hook: one damage line, one knock line | G:1364, G:1433 | RSQML_Gloves.Deliver |
| L5 | The shove and the butt strike land no damage | S:366, K:891 | RSQML_Shove.ButtShove; RSQML_ClubHand.Strike |
| L6 | The shove reads the main hand only; the off hand's club is the pistol or revolver only | S:205, K:582 | RSQML_Shove.Swing; RSQML_ClubHand.KindOfOff |
| L7 | Not a gun: the fists and anything flagged melee; with BD22 VR Reloaded and Brutal Doom the shove itself never lands | S:245, S:246, S:118, S:333 | RSQML_Shove.GunIn; BD22QLoaded; ButtShove |
| L8 | A wall between fist and body blocks the punch; a hand moving away from the body is no punch | G:789, G:791, G:632 | RSQML_Gloves.ClearPath; Swing |
| L9 | A yaw step over 15 degrees a tic drops the fist's velocity; 8 degrees clears the shove's rings | G:518, G:235, S:155, S:47 | RSQML_Gloves.Read; RSQML_Shove.Read |
| L10 | The open palm: no punch, no Hadouken; gloved hands never open | G:553, G:559, G:272 | RSQML_Gloves.Swing; PalmOpen |
| L11 | Only a monster's missile that can do damage is listed; only within 256 units | G:842, G:1019, G:1020, G:1174 | RSQML_Gloves.WorldThingSpawned; ReturnFire; Swat |
| L12 | The Guard: boxing gloves only; a blow with no attacker is not guarded | D:160, D:209 | RSQML_Guard.GuardHands; Soak |
| L13 | Ground Pound and Clear Out need RSQ_Glove in hand | T:127, T:40 | RSQML_TwoHand.Pound; Best |
| L14 | Not held: a player, a boss, a monster over the mass; no room at a wall ends the hold | H:143, H:144, H:378, H:330 | RSQML_Headlock.FindMonster; Hold; TickCollars |
| L15 | Console player only: the claim, the throw, the shove's reader, the copy's reader | H:176, H:329, S:131, Y:154 | RSQML_Headlock.ClaimNow; TickCollars; RSQML_Shove.Me; RSQML_GCopy.Me |
| L16 | The window gives up 4 tics after opening if SlowMo is not slowing; at most 175 tics | S:557, S:517, S:525, S:552 | RSQML_Shove.FearTick; FearOpen |
| L17 | Slappers Only off gives back the stash only; a pickup it replaced or destroyed is gone | L:50, L:73, L:235 | RSQML_Slappers.CheckReplacement; WorldThingSpawned; Restore |
