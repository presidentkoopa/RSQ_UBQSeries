# RSQ Melee: where each README claim comes from

Commit read: 50f608e63 (2026-11-27), then remapped the same day to the working tree after the swat became every fist's,
the trigger painted a barrel's target, the shove's barrel launch took the shove's speed test, and a thrown or whipped barrel
became the same launch (two rows added after H19, so the old H20 and later are two higher; H12, W2, W15 and L6 re-read) (the H11 to H14, H19, H45, H51
rows and L2, L3, L10, L11 were re-read and rewritten). Paths are inside `Melee/`. `G` is `zscript/rsqml/gloves.zs`, `C` is
`zscript/rsqml/core.zs`, `S` is `zscript/rsqml/shove.zs`, `H` is `zscript/rsqml/headlock.zs`, `K` is
`zscript/rsqml/club.zs`, `D` is `zscript/rsqml/guard.zs`, `T` is `zscript/rsqml/twohand.zs`, `Y` is
`zscript/rsqml/gestcopy.zs`, `B` is `zscript/rsqml/barrelfly.zs`, `P` is `zscript/rsqml/sparks.zs`, `L` is
`zscript/rsqml/slappers.zs`, `W` is `zscript/rsqml/splat.zs`, `N` is `zscript/rsqml/launch.zs`, `V` is
`zscript/rsqml/service.zs`; other files are named in full (`handsync.zs` and
`rsmenu.zs` are in `zscript/rsqml/`). Each line number is the line that does the thing, not the start of its function.
`H<n>` is the n-th row of How to play, `W<n>` the n-th row of Works with, `L<n>` the n-th Limit, in the README's order.
A default named in a claim is cited at its CVARINFO line.

Numbers a claim gives for Guard, Hadouken, Heavy Hands, Wall Splat, Ground Pound and Clear Out are the fallback each
`RSQML.Num(...)` call carries, used when RSQ Gun Bonsai VR is not loaded (`C:145`). The two-hand thresholds (H38, H39)
are the constants in Melee's own two-hand reader (gestcopy.zs).

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | A hand is read only while it holds a fist: an empty hand, a glove (RSQ_Glove*, SPO_Glove*), Doom's Fist | G:434, G:441, G:600, G:601 | RSQML_Gloves.FistIn; IsFist; WorldTick |
| H1 | Brutal Doom's fists and BD22 VR's free off fist only while rsqml_bdfists is on (default true) | G:444, G:447, G:450, CVARINFO.txt:16 | RSQML_Gloves.IsFist |
| H2 | Arms on a hand under 0.6 x Min Speed, the rehit wait over; travel counts at 0.25 m/s or more for at most 14 tics | G:676, G:679, G:224, G:225 | RSQML_Gloves.Swing |
| H2 | A punch after 0.15 m of travel averaging Min Speed (2.0); the hand is measured against the body at the view's height | G:694, G:223, G:696, G:642, G:617, CVARINFO.txt:23 | RSQML_Gloves.Swing; Read |
| H2 | The whoosh on the tic the swing arms, only for a swing forward or rising | G:701, G:1405 | RSQML_Gloves.Swing; SwingsOut |
| H3 | Contact: the fist a sphere of 0.09 m plus rsqml_punch_pad (4) against the body's cylinder, with no wall between | G:706, G:707, G:845, G:847, CVARINFO.txt:28 | RSQML_Gloves.Swing; Contact |
| H3 | The blow must drive toward the body; then Deliver | G:739, G:740 | RSQML_Gloves.Swing |
| H3 | Power 0..1 between Min Speed and Full Speed (7); damage Punch Damage (10) x (1 + power); blood; one DamageMobj | G:1439, G:1483, G:1525, G:1526, CVARINFO.txt:24, CVARINFO.txt:30 | RSQML_Gloves.Deliver |
| H3 | Spark sized by power; buzz in that hand; knock (2 + 6 x power) x 100 / mass along the fist's way | G:1521, P:52, G:1535, G:1548, G:1552 | RSQML_Gloves.Deliver; RSQML_Spark.Punch |
| H3 | The hand is disarmed after a hit and arms again after rsqml_punch_rehit (6) tics | G:741, G:746, G:643, CVARINFO.txt:25 | RSQML_Gloves.Swing |
| H4 | Not rising and not a hook is a jab; jab1, jab2, jab3 in turn | G:557, G:1385, G:1386 | RSQML_Gloves.Classify; HitSound |
| H5 | A hook: sideways share over 0.6 and over the forward share; hookr or hookl by the hand swung | G:556, G:1377, G:1378 | RSQML_Gloves.Classify; HitSound |
| H5 | Jab and hook share one damage line and one knock line (no branch on the kind) | G:1483, G:1552 | RSQML_Gloves.Deliver |
| H6 | Uppercut: the swing's path or its last tic rising past rsqml_punch_uppercut_rise (0.5) | G:571, G:1431, CVARINFO.txt:26 | RSQML_Gloves.ClassifySwing; Deliver |
| H6 | Lift (5 + 4 x power) x 100 / mass (0.1 to 1.5), a boss x 0.3; back (2 + 3 x power); staggered for the air time | G:1551, G:1606, G:1607, G:1611, G:1619, G:1622 | RSQML_Gloves.Launch |
| H6 | No launch above rsqml_punch_lift_cap (3 m) | G:1616, G:1617, CVARINFO.txt:27 | RSQML_Gloves.Launch |
| H7 | A counter: the monster in its Missile or Melee states; the red spark | G:1454, C:209, C:211, P:51 | RSQML_Gloves.Deliver; RSQML.InAttack; RSQML_Spark.Punch |
| H7 | Arcade only: the red burst and COUNTER!, the word through RSQVR_Service; Impact Words on by default | P:240, P:244, P:254, P:279, P:284, CVARINFO.txt:93 | RSQML_Impact.Hit; Word |
| H8 | Hard is power 0.67 or more, or a kill; the big burst; shards on every blow | P:242, P:247, P:249 | RSQML_Impact.Hit |
| H8 | Hit stop: a living monster held 2 + round(3 x power) tics; rsqml_hitstop (true) | P:251, P:252, CVARINFO.txt:94 | RSQML_Impact.Hit |
| H8 | The words; FATALITY! on a kill; one word a player every 14 tics; Arcade is the default | P:278, P:279, P:230, P:277, CVARINFO.txt:92 | RSQML_Impact.Word |
| H9 | Any PowerStrength: damage x 5 | G:1496, G:1497 | RSQML_Gloves.Deliver |
| H10 | No body met: a line with a special along the fist's path this tic is worked (Use, UseThrough, Push or Impact); a buzz | G:709, G:720, G:724, C:254, C:257 | RSQML_Gloves.Swing; RSQML.UseLineAlong |
| H11 | An uppercut meeting a barrel, with Barrel Launch on (default true): launched, no damage | G:713, G:783, G:802, B:86, CVARINFO.txt:33 | RSQML_Gloves.Swing; KickBarrel; RSQML_FlyingBarrel.Launch |
| H11 | 28 units a tic to the monster that hand has painted; with none, along the direction it was given | B:29, B:61, B:74, B:79, B:80 | RSQML_FlyingBarrel.Launch |
| H11 | The direction given: the fist's own way when 0.3 or more of it lies across the floor, else from you to the barrel; a painted monster comes before Distance Grab's lock | G:801, G:795, G:797 | RSQML_Gloves.KickBarrel |
| H11 | Goes off on a wall, floor or ceiling, a foe, or after 105 tics; the barrel's own class put back and blown up with you as its target | B:130, B:142, B:145, B:32, B:150, B:154, B:157 | RSQML_FlyingBarrel.Tick; Boom |
| H12 | A hand that can paint: a fist as the punch reader counts it, the main hand's gun, or a hand RSQDG_ThrowService "hold.full" says is carrying; its own fire held (read, not taken), Barrel Launch on | G:287, G:291, G:599, G:369, G:371 | RSQML_Gloves.PaintHand; Carrying; WorldTick; PaintTick |
| H12 | This machine says its hand's aim each tic the trigger is held and the hand is under PAINT_STILL (1.2 m/s); the event carries hand, yaw and pitch | G:306, G:326, G:328, G:272, G:339 | RSQML_Gloves.SendPaint; NetworkProcess |
| H12 | The pick: a foe within PAINT_CONE (25 degrees) of the line and REACH (1536) of the hand, the smallest angle, in the player's sight | G:347, G:271, G:355, G:357, B:31 | RSQML_Gloves.PaintPick |
| H12 | Kept until the trigger is up, it dies, or another is picked; a buzz on a new one; the ring kept over it (RQRG Q, green, gone 2 tics after it is last kept) | G:371, G:370, G:382, G:385, G:395, G:398, B:180, B:185, B:187 | RSQML_Gloves.PaintTick; RSQML_PaintMark |
| H12 | A launch asks which monster that hand has painted (alive) | B:61, G:302, S:337 | RSQML_FlyingBarrel.Launch; RSQML_Gloves.Painted; RSQML_Shove.BarrelShove |
| H13 | Any fist at SWAT_MPS (1.5) or more, rsqml_swat on (default true), meets a monster's missile on its path; read every tic, after the Hadouken, and the swing goes on to the punch | G:672, G:1282, G:1295, G:665, G:707, G:740, CVARINFO.txt:19 | RSQML_Gloves.Swing; Swat |
| H13 | Knocked aside at its own speed and made yours; slap, buzz, spark | G:1317, G:1320, G:1321, G:1327, G:1328, G:1329 | RSQML_Gloves.Swat |
| H14 | A monster's hitscan, rsqml_bullets on (default true): a fist at swat speed with rsqml_swat on, its path within reach of the shot's line, between shooter and player | G:975, G:976, G:1008, G:1010, G:1013, CVARINFO.txt:20 | RSQML_Gloves.WorldHitscanPreFired |
| H14 | The shot is cancelled; with no Swat Back level nothing is sent back | G:1014, G:1015, G:1027 | RSQML_Gloves.WorldHitscanPreFired |
| H15 | The main hand only; a gun is a ready weapon that is not a fist and not flagged melee | S:205, S:223, S:245, S:246 | RSQML_Shove.Swing; GunIn |
| H15 | 0.15 m of travel averaging 2.0 m/s is a swing; not drawn back, not swung down; then rsqml_shove_mps (3.6) | S:217, S:219, S:227, S:286, S:259, S:260, S:287, CVARINFO.txt:51, CVARINFO.txt:52 | RSQML_Shove.Swing; ShoveAct |
| H15 | 12 tics between shoves; the envelope is 60 units along the swing from the hand, padded 12, each body with a clear line | S:261, S:292, S:293, S:59, S:352, S:57, S:58, S:369, S:371 | RSQML_Shove.ShoveAct; ButtShove |
| H15 | No damage: a thrust of 800 / mass (1 to 12) away from you, the Pain state (not NOPAIN, not a boss) | S:376, S:389, S:443, S:445, S:448 | RSQML_Shove.ButtShove; ShoveHit |
| H15 | Extra knock by class: ZombieMan and ShotgunGuy back 10 up 7.5, DoomImp back 5 up 5, others up only | S:431, S:432, S:435, S:455 | RSQML_Shove.KnockOf; Knock |
| H15 | Swing sound, hit sound, alert 200, buzz in the main hand | S:353, S:403, S:405, S:62, S:406 | RSQML_Shove.ButtShove |
| H16 | A shove that landed, from the shover's machine: rsm_pulse with rsqml_shove_slowmo_ms (1000, clamped 30 to 2000) at 35 | S:399, S:408, S:416, S:417, S:418, S:63, CVARINFO.txt:55, CVARINFO.txt:60 | RSQML_Shove.ButtShove; Pulse |
| H17 | The window opens with the pulse and stays only while RSQSM_Service says slowmo.active | S:420, S:308, S:564, S:566 | RSQML_Shove.Pulse; NetworkProcess; FearTick |
| H17 | The shover's shotgun hit on a monster: blood spawned again | S:630, S:632, S:638, S:641, S:574 | RSQML_Shove.WorldThingDamaged; IsShotgun |
| H17 | A kill: blood mist with rsqml_fear_mist (true), the extreme death, the award to RS_ScoreService, the name on screen 52 tics | S:646, S:648, S:649, S:529, S:530, S:713, S:747, CVARINFO.txt:64 | RSQML_Shove.WorldThingDamaged; RenderOverlay; RSQML_FearMark.ModifyDamage |
| H18 | No body struck: a line with a special within 60 units along the shove is worked; a buzz | S:398 | RSQML_Shove.ButtShove |
| H19 | Sent only for a swing that averages rsqml_shove_mps and comes BUTT_WAIT (12) tics after the last shove or launch, while Barrel Launch is on; the launch starts that wait | S:235, S:259, S:260, S:261, S:262, S:264, S:270, S:59 | RSQML_Shove.Swing; ShoveAct |
| H19 | The nearest barrel within 72 units of the gun hand and within 60 degrees of the shove is launched, for the main hand (its painted monster, else along the shove) | S:314, S:333, S:334, S:337 | RSQML_Shove.BarrelShove |
| H20 | "barrel.throw": Barrel Launch on and a barrel by IsBarrel; the player and hand from intArg; "painted" answers 0 with no painted monster; the direction unpacked as the shove's; launched as a throw | V:136, V:138, V:141, V:144, V:146, V:148 | RSQML_Service.GetInt |
| H20 | The same launch: that hand's painted monster, else along the direction; a throw raises no dust and plays no hit sound | B:61, B:79, B:90, B:98 | RSQML_FlyingBarrel.Launch |
| H20 | Distance Grab asks when its throw test passes (over 0.5 m/s), never for a set-down, and only lets go on 1; with its lock held it asks "painted" | ../DistanceGrab/zscript/rsqdg/hold.zs:366, ../DistanceGrab/zscript/rsqdg/hold.zs:386, ../DistanceGrab/zscript/rsqdg/hold.zs:461, ../DistanceGrab/zscript/rsqdg/hold.zs:466 | RSQDG_Hold.Release; MeleeThrow |
| H21 | A club strike on a barrel with Barrel Launch on: launched for that hand before any blow, by the swing's own speed test and hit test | K:861, K:864, K:753, K:754, K:806, K:820, K:833 | RSQML_ClubHand.Strike; Tick; Sweep |
| H21 | The whip's sound for a pistol whip, the shove's for a butt strike | B:93, B:95, B:98, B:100 | RSQML_FlyingBarrel.Launch |
| H22 | rsqml_barrel_slowmo (true): RSQSM_Service start.barrel for 3000 ms, stop when it goes off | B:103, B:106, B:34, B:160, CVARINFO.txt:34 | RSQML_FlyingBarrel.Launch; Boom |
| H23 | The off grip is read by raw key code from rsqml_keys_off ("443 436") and eaten when the Headlock takes it | H:82, H:92, H:98, H:99, CVARINFO.txt:89 | RSQML_Headlock.InputProcess |
| H23 | The nearest living monster within rsqml_headlock_reach (0.30 m) of the off palm, not a boss, not over rsqml_headlock_mass (400) | H:122, H:124, H:126, H:127, H:143, H:144, H:151, CVARINFO.txt:81, CVARINFO.txt:82, CVARINFO.txt:83 | RSQML_Headlock.FindMonster |
| H23 | Held frozen for rsqml_headlock_secs (3); its face (0.85 of its height) at the hand's height, turned to you; a buzz in the off hand | H:209, H:237, H:334, H:372, H:362, H:385, H:248, CVARINFO.txt:84 | RSQML_Headlock.NetworkProcess; StartCollar; TickCollars; Hold |
| H24 | The grip up ends the hold; so do the hold time, your death or its death | H:104, H:204, H:325 | RSQML_Headlock.InputProcess; NetworkProcess; TickCollars |
| H25 | The off hand holding a monster is not a fist for the reader | G:596 | RSQML_Gloves.WorldTick |
| H26 | Each blow on the held monster is a step: x1, x1.5, x2.5; rsqml_headlock_combo (true) | G:1491, G:1492, H:266, H:270, CVARINFO.txt:95 | RSQML_Gloves.Deliver; RSQML_Headlock.ComboStep; ComboMult |
| H26 | The third: let go, 4 tics of hit-stop, then 26 units a tic x 100 / mass (0.35 to 1.6) away from you | G:1531, H:280, H:285, H:287, H:276, H:291, H:275, H:293 | RSQML_Gloves.Deliver; RSQML_Headlock.ComboFinish |
| H26 | Each monster it meets: 10 to 150 by its speed, shoved along, staggered 24 tics | H:667, H:673, H:675, H:676, H:637 | RSQML_Bowl.Tick |
| H27 | Any damage of yours on the monster you hold: its pain sound and its pain frame for 6 tics | H:576, H:578, H:579, H:392 | RSQML_Headlock.WorldThingDamaged |
| H27 | Extra blood 0.3, 0.6, then 1.0 of the blow; rsqml_headlock_blood (true) | H:581, H:584, H:587, CVARINFO.txt:87 | RSQML_Headlock.WorldThingDamaged |
| H28 | The off palm against the body, across the ground within 60 degrees of facing; a peak of rsqml_headlock_throw (3.0) then under 0.6 of the peak | H:434, H:455, H:460, H:462, CVARINFO.txt:86 | RSQML_Headlock.ThrowSwing |
| H28 | Let go, in its Pain state; its velocity the hand's (fastest 2-tic average of the last 6); counted as rsqml_headlock_weight (30) percent | H:465, H:466, H:467, H:472, H:494, CVARINFO.txt:88 | RSQML_Headlock.ThrowSwing; PalmVel |
| H28 | Melee's own toss: a wall or a body met at 3 m/s or more hurts it and the body by the energy over 15 joules a point | H:500, H:724, H:704, H:731, H:734, H:735 | RSQML_Headlock.ThrowSwing; RSQML_Tossed.DoEffect |
| H29 | The club runs only with BrutalWeapon, RSVR_MeleeHandler and RSVR_MeleeYield present; the eight long guns with rsqml_butt (1) | K:288, K:289, K:557, K:559, K:566, CVARINFO.txt:69 | RSQML_Club.On; RSQML_ClubHand.KindOf |
| H29 | Needs the engine's two-hand steadying, rsqml_butt_speed (2.4 m/s) at the stock, rsqml_butt_fwd (0.5) of it forward, not muzzle-led | K:726, K:748, K:749, K:750, CVARINFO.txt:70, CVARINFO.txt:71 | RSQML_ClubHand.Tick |
| H29 | Bodies on the gun's path and within 90 units ahead of the stock (pad 16): the shove's hit, no damage; the pulse once a swing; a line worked | K:766, K:771, K:474, K:475, K:907, K:928, K:774 | RSQML_ClubHand.Tick; Sweep; Strike |
| H30 | Pistol whip: BrutalPistol, Revolver, BrutalRevolver in the main hand, their off-hand classes in the off hand; rsqml_pistol_whip (true) | K:568, K:569, K:582, K:583, CVARINFO.txt:72 | RSQML_ClubHand.KindOf; KindOfOff |
| H30 | rsqml_whip_speed (5.0 m/s) at the muzzle, rsqml_whip_down (0.25) of it downward | K:727, K:742, CVARINFO.txt:73, CVARINFO.txt:74 | RSQML_ClubHand.Tick |
| H30 | Lands MeleeStrikeNormal (MeleeStrike1Berserked under the Berserk), a second at twice the swing needed; the whip sound; AxeAttack into a wall | K:900, K:902, K:894, K:984 | RSQML_ClubHand.Strike; WallCheck |
| H31 | Boxing Gloves (default false): at a map start or respawn, 3 tics in, the two gloves are given, not raised | L:80, L:84, L:93, L:115, L:152, L:153, CVARINFO.txt:12 | RSQML_Slappers.PlayerEntered; PlayerRespawned; WorldTick; GiveGloves |
| H31 | The glove class asks for slot 1; with Boxing Gloves or Slappers Only on it draws as the boxing glove | G:43, G:114, G:128 | RSQ_Glove Default; RSQML_HandLook.Gloved; Look |
| H32 | Slappers Only (default false) flipped on: gloves given, every weapon but the gloves, Fist, Melee_Attacks and RSQ_Hands stashed, gloves put on both hands | L:95, L:109, L:62, L:63, L:208, CVARINFO.txt:6 | RSQML_Slappers.WorldTick; IsGun; Strip |
| H32 | Weapon pickups become nothing; a weapon given later goes within 8 tics; off, the stash comes back with the ammo you had | L:50, L:73, L:125, L:111, L:238, L:241 | RSQML_Slappers.CheckReplacement; WorldThingSpawned; WorldTick; Restore |
| H33 | Guard row (default false) at level 1; only with Gloved() and a glove as the ready weapon, the off hand empty or a glove | C:79, D:72, D:160, D:161, D:162, CVARINFO.txt:40 | RSQML.MoveLevel; RSQML_Guard.GuardLevel; GuardHands |
| H33 | Both hands within 0.35 m of the pawn across, 0.25 m below to 0.15 m above the eyes, for 4 tics | D:124, D:20, D:21, D:22, D:13, D:203 | RSQML_Guard.Pose; Soak |
| H33 | A blow from within 55 degrees: 60% of it, a push back, the flash and tick, a buzz in both hands | D:210, D:14, D:261, D:263, D:265, D:266, D:267, D:389 | RSQML_Guard.Soak; RSQML_Body.ModifyDamage |
| H33 | 35 or more breaks it: full damage, no Guard for 14 tics | D:249, D:250, D:253, D:15, D:258 | RSQML_Guard.Soak |
| H34 | Hadouken row (default false): a fist at Min Speed or more, read every tic, meets a monster's missile within 256 units | G:662, G:664, G:1137, G:1143, CVARINFO.txt:41 | RSQML_Gloves.Swing; ReturnFire |
| H34 | Sent at its shooter at speed x 1.15, hitting for x 1.5 | G:1146, G:1147, G:1069, D:404 | RSQML_Gloves.ReturnFire; SendBack; RSQML_Body.ModifyDamage |
| H35 | A fist at Min Speed with the Hadouken sends a bullet back (else it is the swat's); the round flies from the hand at the shooter with the shot's damage x 1.5 | G:1006, G:1007, G:1018, G:1019, G:1041, G:1046 | RSQML_Gloves.WorldHitscanPreFired; ReturnBullet |
| H36 | Heavy Hands row (default false): knock x 1.25; frozen 2 tics, 4 at power 0.5 or more; chicks and stars | G:1539, G:1549, G:1556, G:1558, G:1559, CVARINFO.txt:43 | RSQML_Gloves.Deliver |
| H37 | Wall Splat row (default false): armed 12 tics by a punch; a wall refusing its move at 3 units a tic or more | G:1564, G:1565, W:19, W:20, W:43, CVARINFO.txt:42 | RSQML_Gloves.Deliver; RSQ_Splat.DoEffect |
| H37 | 10 to 20 damage by speed, bounced back at 0.45, frozen 5 tics, staggered 15 | W:56, W:79, W:21, W:80, W:81 | RSQ_Splat.Slam |
| H38 | Ground Pound row (default false); a glove (RSQ_Glove) in both hands; the event's speed 3.0 or more | T:78, T:127, T:130, T:132, T:134, CVARINFO.txt:45 | RSQML_TwoHand.NetworkProcess; Pound |
| H38 | Melee's own reader: each hand 2.0 m/s down, half or more of its speed downward, 0.60 m below the eyes, within 120 ms; the slower hand's speed is sent | Y:286, Y:289, Y:290, Y:292, Y:314, Y:344, Y:380 | RSQML_GCopy.TwoHand; Announce |
| H38 | 30 damage within 2.5 m, thrown out 4 and up 3 by weight, staggered 15 tics; thud, pixel ring, quake, buzz in both hands | T:135, T:136, T:155, T:156, T:158, T:23, T:160, T:163, T:164, T:165 | RSQML_TwoHand.Pound |
| H39 | Clear Out row (default false); nothing but RSQ_Glove in either hand, and a glove in a hand to give the level | T:79, T:174, T:177, T:39, T:40, CVARINFO.txt:46 | RSQML_TwoHand.NetworkProcess; ClearOut; Best |
| H39 | Melee's own reader: each hand 2.5 m/s forward, 0.6 of its speed, pitched 20 degrees or more, not below the 0.60 m line, hands 0.25 m apart sideways | Y:298, Y:299, Y:300, Y:331, Y:332, Y:355, Y:356 | RSQML_GCopy.TwoHand |
| H39 | 15 damage within 2.5 m and 45 degrees either side, in sight; push 14 by weight; staggered 10 tics | T:179, T:180, T:181, T:182, T:199, T:25, T:201, T:209 | RSQML_TwoHand.ClearOut |
| H40 | Human Shield row (default false): the hold lasts 60 seconds at most while the grip is held, the monster faces the way you face | H:255, H:237, H:385, CVARINFO.txt:85 | RSQML_Headlock.ShieldOn; StartCollar; Hold |
| H41 | With Barrel Launch off and Uppercut Barrels (default false) on: up 5 to 9 under the lift cap, as fast forward, no damage, you its target | G:713, G:786, G:802, G:805, G:806, G:808, CVARINFO.txt:35 | RSQML_Gloves.Swing; KickBarrel |
| H42 | VR Punch (rsqml_bd_punch, default 0), only while the club runs: Melee_Attacks in the main hand or RSQ_Hands' free closed hand | K:393, K:438, K:441, K:442, CVARINFO.txt:76 | RSQML_Club.WorldTick; Punches |
| H42 | 2.5 m/s, 0.7 of it forward, the hand 0.25 m ahead, 0.15 m of forward travel; Brutal Doom's strike actor flies from the hand | K:1026, K:1028, K:1029, K:1030, K:1072, K:1075, K:1082 | RSQML_BDPunch.Tick |
| H42 | Melee's own punch then deals no damage and still does the rest | G:541, G:1520, G:1523 | RSQML_Gloves.BD22Punches; Deliver |
| H43 | Star Punch: Gun Bonsai VR level on a glove, a banked star, an uppercut, that hand's fire or alt fire down | G:1468, G:1472, G:1473, G:1474 | RSQML_Gloves.Deliver |
| H43 | The star sound and a longer, stronger buzz; a star banked on a counter, the first landed punch and every second after, 3 at most | G:1533, G:1535, G:1583, G:1585, G:1588 | RSQML_Gloves.Deliver |
| H44 | Juggle: the glove's level, the monster this player launched still off the floor, within 70 tics: launched again | G:1481, G:1482, G:1596, G:1551, N:40 | RSQML_Gloves.Deliver; RSQML_Launched.AgeFor |
| H45 | Catch: the glove's level, a fist under 1.5 m/s, a monster's missile at the hand still coming in; held at the hand | G:1229, G:1230, G:1239, G:1225 | RSQML_Gloves.CatchTick |
| H45 | Thrown by the hand at Min Speed or more, 6 tics after the catch, onto a monster within 12 degrees; held past its time it goes off | G:1205, G:1209, G:1256, G:1217, G:1221 | RSQML_Gloves.CatchTick; CatchAim |
| H46 | Parry: a player node; both hands driven forward at 1.0 m/s, the push and the Guard both inside the node's window | D:200, D:142, D:34, D:147, D:202 | RSQML_Guard.Soak; Pose |
| H46 | No damage; the attacker knocked back and staggered | D:222, D:224, D:233 | RSQML_Guard.Soak |
| H47 | rsqml_pair kind 1 (both hands apart): the Guard's charge released if there is one, else the Taunt | T:74, T:78, D:289, D:290, D:303, D:307 | RSQML_TwoHand.NetworkProcess; RSQML_Guard.Release |
| H47 | Taunt: a player node; monsters in range that see you target you; the next punch in the window does double | T:100, T:113, T:114, T:105, G:1502 | RSQML_TwoHand.Taunt; RSQML_Gloves.Deliver |
| H48 | Slam: the off glove's level; the off hand's move this tic 0.7 or more downward at the node's speed | H:444, H:449, H:451 | RSQML_Headlock.ThrowSwing |
| H48 | Let go, put on the floor, hurt by mass, weight share and speed squared; monsters round it staggered | H:536, H:538, H:543, H:558, H:562 | RSQML_Headlock.Slam |
| H49 | Headlock Uppercut: the off glove's level, an uppercut on the monster you hold: more damage, let go, a higher launch | G:1488, G:1489, G:1542, G:1551 | RSQML_Gloves.Deliver |
| H50 | Brutal Doom Fists off: Melee_Attacks (and what is made from it) and RSQ_Hands are not fists | G:444, G:447, G:467 | RSQML_Gloves.IsFist; BDFistsOn |
| H51 | Palm Swat off: no fist swats a missile or a bullet; the Hadouken is read before it and does not ask the row | G:672, G:1008, G:665, G:1006 | RSQML_Gloves.Swing; WorldHitscanPreFired |
| H52 | Gun Butt Shove off: no shove; with BD22 VR Reloaded and Brutal Doom loaded the reader runs on Shove Slow Mo instead | S:286, S:125, S:138 | RSQML_Shove.ShoveAct; Wanted; WorldTick |
| H53 | Headlock off: no monster is found, so the press is never claimed or eaten | H:122, H:181, H:194 | RSQML_Headlock.FindMonster; ClaimNow; WorldTick |
| H54 | Impact Style Classic (0): Hit returns at once; the spark is spawned by Deliver before it | P:233, P:240, G:1521 | RSQML_Impact.Arcade; Hit; RSQML_Gloves.Deliver |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Gun Bonsai VR: RSQ_MeleeUpgradeService, only while it answers loaded 1; numbers by upgrade.num | C:62, C:63, C:145 | RSQML.GBAny; GB; Num |
| W1 | With it: the row off is level 0, else the glove's or the player's level; a fist that is no glove plays the row; the Uppercut on a glove is its level | C:75, C:76, C:77, C:103, C:113, G:1443 | RSQML.MoveLevel; UnlockLevel; FistLevel; RSQML_Gloves.Deliver |
| W1 | The greyed rows and the answer behind them; Start With Guard | MENUDEF.txt:56, MENUDEF.txt:58, MENUDEF.txt:62, MENUDEF.txt:66, MENUDEF.txt:68, V:80, D:73 | MENUDEF RSQML_Options; RSQML_Service.GetIntUI; RSQML_Guard.GuardLevel |
| W1 | Its other nodes read here by name | G:1609, G:648, G:1507, G:1285, G:1157, D:95, T:138, H:129, H:337, H:480, S:593, S:598 | RSQML_Gloves.Launch; Swing; Deliver; Swat; ReturnFire; RSQML_Guard.WorldTick; RSQML_TwoHand.Pound; RSQML_Headlock.FindMonster; TickCollars; ThrowSwing; RSQML_Shove.GunHand |
| W1 | A glove is its own inflictor; other blows of a glove are claimed for it | G:495, C:154 | RSQML_Gloves.FistInflictor; RSQML.Claim |
| W2 | Distance Grab: near.dist decides the press; -2 means the hand is Distance Grab's | H:182, H:184, H:185, H:186 | RSQML_Headlock.ClaimNow |
| W2 | The throw handed to headlock.throw; headlock.caught for the catch | H:482, H:248 | RSQML_Headlock.ThrowSwing; StartCollar |
| W2 | Barrel Lock-On: lockon.kick takes the uppercut's barrel unless that hand has painted a monster; lockon.on turns the kick on | G:795, G:797, G:826, G:713 | RSQML_Gloves.KickBarrel; LockOnKicks; Swing |
| W3 | SlowMo: rsm_pulse; start.barrel and stop; slowmo.active; scale | S:418, B:106, B:160, S:564, P:353, P:396, P:456, H:654 | RSQML_Shove.Pulse; FearTick; RSQML_FlyingBarrel.Launch; Boom; RSQML_Clock.W; RSQML_Ring.Tick; RSQML_PixelWave.Tick; RSQML_Bowl.Tick |
| W3 | The butt strike asks for the same pulse | K:928 | RSQML_ClubHand.Strike |
| W4 | Score: touch by move id; grab.hold every 70 tics; the award | C:122, H:347, H:350, S:386, G:1148, W:76, T:148, S:648 | RSQML.Touch; RSQML_Headlock.TickCollars; RSQML_Shove.ButtShove; WorldThingDamaged |
| W4 | punch.* answered from the glove or the fist helper | V:89, V:97, V:110 | RSQML_Service.GetInt |
| W5 | VisualRewards: the word asked of RSQVR_Service worldword; nothing else draws it | P:281, P:284 | RSQML_Impact.Word |
| W7 | Tactical Rig: the off hand in a rig region (rig.region 0 or more) is never the Headlock's | H:111, H:114, H:178 | RSQML_Headlock.RigBusy; ClaimNow |
| W8 | Grapple: climbing, swinging or reeling quiets the shove and the copy's two-hand events, and 9 tics after | S:191, S:195, S:197, S:46, S:181, Y:256, Y:283 | RSQML_Shove.Quiet; Read; RSQML_GCopy.Quiet; TwoHand |
| W9 | Wheel: wr_RigService IsOpen does the same | S:192, S:196, Y:257 | RSQML_Shove.Quiet; RSQML_GCopy.Quiet |
| W10 | Miniboss: a monster carrying RSQMB_Ward for which RSQMB_Service bossfor headlock is 1 is refused | H:152, H:164, H:168 | RSQML_Headlock.FindMonster; MinibossRefuses |
| W11 | BD22 VR Reloaded with RSVR_MeleeYield: the club runs; owns answers 1; the shove leaves its guns alone | K:289, V:61, V:62, S:272, S:277 | RSQML_Club.On; RSQML_Service.Owns; RSQML_Shove.ShoveAct |
| W11 | Its settings copied once; rsq_butt is not | K:320, K:336, K:341, K:349 | RSQML_Club.WorldLoaded; Migrate |
| W11 | Hand Model Auto: the FBX hand when RSQ_HandTone exists; its rsq_hand_tone worn | G:113, G:122, G:152 | RSQML_HandLook.BD22VR; UseFbx; Tone |
| W12 | Without RSVR_MeleeYield: ours does nothing; its KickAttack near your shove asks for the pulse | S:279, S:282, S:343, S:140, S:512 | RSQML_Shove.ShoveAct; ButtShove; WorldTick; WatchBDButt |
| W13 | Brutal Doom: Melee_Attacks and what is made from or replaces it is a fist; barrels by the replacement chain; its mist by name; its swing sound | G:474, G:757, S:675, S:353 | RSQML_Gloves.IsBDFistClass; IsBarrel; RSQML_Shove.FearMist; ButtShove |
| W14 | SuperPunchOut: a class named SPO_Glove... is a glove | C:171 | RSQML.IsGloveName |
| W2 | A barrel Distance Grab throws is launched on "barrel.throw"; "hold.full" lets a carrying hand paint | V:136, V:148, G:291 | RSQML_Service.GetInt; RSQML_Gloves.Carrying |
| W15 | RSQML_Service: the requests it answers | V:87, V:88, V:126, V:136, V:150, V:157, V:165, V:170, V:171, V:178, V:184, V:190, V:196, V:205, V:210, V:222, V:223, V:71 | RSQML_Service.GetInt; GetDouble; GetIntUI |
| W15 | RSQML_GCopyService: reader, pair.reader, pair.ago | Y:406, Y:407, Y:411 | RSQML_GCopyService.GetInt |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Out of VR, or with both hand fields equal, no hand position is given | C:279, C:280 | RSQML_Hands.Pos |
| L2 | KEYCONF holds comments only; the only button reads; the grip by key code | KEYCONF.txt:1, G:369, G:1472, K:416, Y:274, H:92 | KEYCONF; RSQML_Gloves.PaintTick; Deliver; RSQML_Club.SendPose; RSQML_GCopy.PalmOut; RSQML_Headlock.InputProcess |
| L3 | Three kinds of punch only; no hand shape but the fist is read or drawn; the shove needs a gun | G:220, G:129, S:223 | RSQML_Gloves; RSQML_HandLook.Look; RSQML_Shove.Swing |
| L4 | Jab and hook: one damage line, one knock line | G:1483, G:1552 | RSQML_Gloves.Deliver |
| L5 | The shove and the butt strike land no damage | S:376, K:907 | RSQML_Shove.ButtShove; RSQML_ClubHand.Strike |
| L6 | The shove reads the main hand only; the off hand's club is the pistol or revolver only; of guns only the main hand's paints, and the whipped barrel takes the off hand's paint (none) | S:205, K:582, G:287, K:864 | RSQML_Shove.Swing; RSQML_ClubHand.KindOfOff; RSQML_Gloves.PaintHand; RSQML_ClubHand.Strike |
| L7 | Not a gun: the fists and anything flagged melee; with BD22 VR Reloaded and Brutal Doom the shove itself never lands | S:245, S:246, S:118, S:343 | RSQML_Shove.GunIn; BD22QLoaded; ButtShove |
| L8 | A wall between fist and body blocks the punch; a hand moving away from the body is no punch | G:903, G:905, G:739 | RSQML_Gloves.ClearPath; Swing |
| L9 | A yaw step over 15 degrees a tic drops the fist's velocity; 8 degrees clears the shove's rings | G:630, G:229, S:155, S:47 | RSQML_Gloves.Read; RSQML_Shove.Read |
| L10 | Only a monster's missile that can do damage is listed; only within 256 units | G:956, G:1136, G:1137, G:1293 | RSQML_Gloves.WorldThingSpawned; ReturnFire; Swat |
| L11 | Painted only while that hand can paint and its fire is down; with nothing painted the launch takes the direction it was given; no sound is played for a paint | G:371, B:61, B:79, G:385 | RSQML_Gloves.PaintTick; RSQML_FlyingBarrel.Launch |
| L12 | The Guard: boxing gloves only; a blow with no attacker is not guarded | D:160, D:209 | RSQML_Guard.GuardHands; Soak |
| L13 | Ground Pound and Clear Out need RSQ_Glove in hand | T:127, T:40 | RSQML_TwoHand.Pound; Best |
| L14 | Not held: a player, a boss, a monster over the mass; no room at a wall ends the hold | H:143, H:144, H:378, H:330 | RSQML_Headlock.FindMonster; Hold; TickCollars |
| L15 | Console player only: the claim, the throw, the shove's reader, the copy's reader | H:176, H:329, S:131, Y:154 | RSQML_Headlock.ClaimNow; TickCollars; RSQML_Shove.Me; RSQML_GCopy.Me |
| L16 | The window gives up 4 tics after opening if SlowMo is not slowing; at most 175 tics | S:567, S:527, S:535, S:562 | RSQML_Shove.FearTick; FearOpen |
| L17 | Slappers Only off gives back the stash only; a pickup it replaced or destroyed is gone | L:50, L:73, L:235 | RSQML_Slappers.CheckReplacement; WorldThingSpawned; Restore |
