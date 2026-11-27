# RSQ Grenade: where each README claim comes from

Commit read: 0252337bd (2026-11-27). Paths are inside `Grenade/` unless they start with another mod's folder. `H` is
`zscript/rsqgn/hand.zs`, `T` is `zscript/rsqgn/thrown.zs`, `K` is `zscript/rsqgn/kinds.zs`, `U` is
`zscript/rsqgn/upg.zs`, `W` is `zscript/rsqgn/weapon.zs`, `B` is `zscript/rsqgn/barrel.zs`, `X` is
`zscript/rsqgn/explosions.zs`, `S` is `zscript/rsqgn/scatter.zs`, `L` is `zscript/rsqgn/bdlaunch.zs`; other files are
named in full. Each line number is the line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | A player who enters or respawns without the grenade is given it, and grenades up to rsqgn_start (3) | H:400, H:401, H:409, H:410, H:411, CVARINFO.txt:9 | RSQGN_Handler.PlayerEntered; PlayerRespawned; Equip |
| H1 | Slot 9; given without being put in the hand; only while the grenade is on | W:55, W:64, H:407, CVARINFO.txt:3 | RSQGN_Grenade Default; Equip |
| H2 | Slot 9 (and added to slot 9 by KEYCONF); the ready state allows no fire; ring in is frame 0 | W:55, KEYCONF.txt:12, W:84, H:368 | RSQGN_Grenade.A_RSQGNReady; RSQGN_Handler.HeldFrame |
| H3 | One grenade a pickup, carry 8, a backpack raises it to 16; the pack gives 3 | W:12, W:13, W:15, W:35 | RSQGN_Ammo Default; RSQGN_Pack Default |
| H3 | Scatter: singles and packs beside the map's items up to the caps (4 and 2) | S:21, S:43, S:44, S:54, S:55, CVARINFO.txt:10, CVARINFO.txt:11, CVARINFO.txt:12 | RSQGN_Scatter.WorldLoaded; Plan |
| H4 | One key, an alias for a network event, with no default bind; the event queues a quick throw | KEYCONF.txt:3, KEYCONF.txt:14, H:639 | KEYCONF alias and addmenukey; RSQGN_Handler.NetworkProcess |
| H4 | +user1 pressed this tic does the same | H:750 | RSQGN_Handler.QuickTick |
| H4 | Off with rsqgn_quick; pin sound at tic 7, toss at 15, out at 17, next press at 22 | H:727, H:718, H:719, H:720, H:721, H:736, H:737, H:754, H:755, H:756, CVARINFO.txt:8 | RSQGN_Handler.QuickPress; QuickTick |
| H4 | Thrown by the pawn at 45 units a tic; one grenade used; the type in hand | H:763, H:784, H:790 | RSQGN_Handler.QuickThrow |
| H5 | No grenades: a toast or a mid-screen print, nothing thrown | H:729, H:732 | RSQGN_Handler.QuickPress |
| H6 | Refused while the pin is out | H:728 | RSQGN_Handler.QuickPress |
| H7 | The other hand's primary fire, pressed within RING_GRAB (12 cm) of the ring point, takes the ring; a buzz in that hand | H:907, H:942, H:943, H:949, H:222, H:952 | RSQGN_Handler.Local |
| H8 | The ring held and the hand more than RING_GRAB + PULL (20 cm) away sends the pin event; pin out, sound, buzz in the other hand | H:956, H:223, H:960, H:672, H:675, H:676 | RSQGN_Handler.Local; NetworkProcess |
| H8 | Pin out is frame 1, whose model hides the ring surface; nothing burns until the spoon goes | H:369, MODELDEF.txt:35, H:474 | RSQGN_Handler.HeldFrame; WorldTick |
| H9 | Teeth: fire or alt fire on the grenade hand held with the controller, grenade or ring within rsqgn_mouth_r (0.15 m) of the lips-to-chin line for rsqgn_face_hold (12) tics | H:964, H:1024, H:1026, H:1019, H:1036, H:1039, H:1041, H:1047, CVARINFO.txt:21, CVARINFO.txt:22, CVARINFO.txt:24 | RSQGN_Handler.Local; MouthDist; MouthReach; Face |
| H9 | The lips are 4 cm ahead of and 6 cm under the eyes, the chin end 8 cm ahead and 19 cm under; the buzz goes to the grenade hand | H:228, H:229, H:230, H:231, H:676 | RSQGN_Handler constants; NetworkProcess |
| H10 | The squeeze is fire or alt fire on the grenade hand; both up is the let-go; at or over rsqgn_throw_min (2.2 m/s) it is thrown | H:924, H:925, H:985, H:989, H:991, CVARINFO.txt:18 | RSQGN_Handler.Local |
| H10 | The speed is the fastest 2-tic window of the last 7 tics that goes ahead of the body (else the fastest of all) | H:224, H:1147, H:1155, H:1157, H:168 | RSQGN_Handler.Peak; RSQGN_Fling.Ahead |
| H10 | Leaves at GAIN 4 x strength 0.5 = twice the hand, capped at 30 m/s; steeper than 40 degrees is laid down; the pawn's velocity is added; from the grenade's place in the hand | H:155, H:156, H:175, H:1083, H:1085, H:1077, H:1088, H:1091, H:1093, H:1099, CVARINFO.txt:19 | RSQGN_Fling.Mult; RSQGN_Handler.LaunchVel; SendThrow |
| H11 | Slower than the threshold: the cook event; spoon gone, sound, buzz; the fuse is rsqgn_fuse (3 s) | H:992, H:690, H:691, H:693, H:694, H:339, CVARINFO.txt:13 | RSQGN_Handler.Local; NetworkProcess; FuseTics |
| H12 | While cooking any let-go throws; the throw keeps what is left of the fuse | H:997, H:1002, H:811, H:845 | RSQGN_Handler.Local; Throw |
| H13 | Cooked for the whole fuse: a blast at the body, one grenade taken, the two parts of the blast | H:479, H:545, H:547, H:1179, H:1180 | RSQGN_Handler.WorldTick; Boom; RSQGN_HandBlast states |
| H14 | A flash every 16 tics down to every 2, red for half of it, with a tick; in the hand and thrown | H:350, H:520, H:521, H:523, H:370, T:149, T:152, T:162 | RSQGN_Handler.FlashPeriod; Flash; HeldFrame; RSQGN_Thrown.Tick |
| H15 | Pin out, spoon on: the other hand's fire within RING_GRAB x 0.6 (7.2 cm) of the ring point puts the pin back; sound, buzz, nothing used | H:973, H:975, H:681, H:682, H:683, H:684 | RSQGN_Handler.Local; NetworkProcess |
| H16 | Not in a hand any more, or dead, with the spoon gone: dropped at the feet with the fuse that is left | H:466, H:470, H:801, H:802, H:804, H:811 | RSQGN_Handler.WorldTick; DropLive; Throw |
| H17 | The same with the spoon still on: the pin state is reset | H:471 | RSQGN_Handler.WorldTick |
| H18 | Alt fire pressed with the pin in sends the type event unless the row is off, the hand is at the mouth, or no other type is owned | H:915, H:929, H:930, H:932, H:934, CVARINFO.txt:25 | RSQGN_Handler.Local |
| H18 | The next owned type in the list's order; a sound, a buzz; the held skin is the type's | H:643, H:646, H:647, K:9, K:41, W:93 | RSQGN_Handler.NetworkProcess; RSQGN_Kind.Next; A_RSQGNReady |
| H18 | At All Types without Gun Bonsai VR every type is owned | K:35, K:36, CVARINFO.txt:26 | RSQGN_Kind.Owns |
| H19 | The fuse ending sets it off; 85 over 200 then 75 over 255 on the next tic, hurting the thrower | T:165, T:323, T:324, T:342, T:343 | RSQGN_Thrown.Tick; Boom state; Blast |
| H19 | Doom bounce on floors, walls and actors; gravity and bounce from the rows; ground drag to a stop | T:74, T:77, T:78, H:859, H:860, H:861, T:135, T:138, CVARINFO.txt:14, CVARINFO.txt:15, CVARINFO.txt:16 | RSQGN_Thrown Default; RSQGN_Handler.Throw; RSQGN_Thrown.Tick |
| H20 | Impact bursts on a bounce or the floor once age is 2 or more; full damage share | T:104, T:107, K:49 | RSQGN_Thrown.Tick; RSQGN_Kind.DamageShare |
| H21 | Incendiary: full share; a fire field over the blast radius (200) for (3 + level) seconds, level 1 without the patch; 1 damage every 7th tic to monsters in it | K:50, K:195, K:203, T:345, K:355, K:362, K:364 | RSQGN_Kind.DamageShare; Effect; RSQGN_Thrown.Blast; RSQGN_FireField.Burn |
| H22 | Freeze: no damage share; monsters within the radius and in sight frozen (2 + level) seconds; not bosses | K:48, K:174, K:175, K:212, K:221, K:273, K:283 | RSQGN_Kind.DamageShare; Inside; Effect; RSQGN_Daze.On; Freeze |
| H23 | Stun: half share; held in the Pain state (2 + level) seconds | K:47, K:227, K:290, K:303 | RSQGN_Kind.DamageShare; Effect; RSQGN_Daze.Stagger; DoEffect |
| H24 | Smoke: a cloud of radius 34 x (3 + level) / 2 = 68 units for 8 + 4 x level = 12 seconds; a monster in it or whose line to its target crosses it loses the target, every world tic it is so | K:209, K:410, K:418, K:425, H:61 | RSQGN_Kind.Effect; RSQGN_Smoke.Pass; Blinds; RSQGN_Geo.Vu |
| H25 | Flash: staggered (2 + level) seconds and the target forgotten | K:233, K:234 | RSQGN_Kind.Effect |
| H26 | Charm: not bosses; turned for (10 + 5 x level) seconds; made friendly to the thrower | K:237, K:242, K:476, K:477 | RSQGN_Kind.Effect; RSQGN_Charmed.Turn |
| H27 | Infight: not bosses; its target kept on the nearest other monster | K:237, K:242, K:502 | RSQGN_Kind.Effect; RSQGN_Infight.Keep |
| H28 | A hitscan or railgun shot by this machine's player: the firing hand's ray within the reach of a thrown grenade 6 or more tics old sends the event that sets it off | H:566, H:567, H:581, H:609, H:614, H:620, H:662, T:58 | RSQGN_Handler.WorldRailgunPreFired; WorldHitscanPreFired; ShotTest; NetworkProcess |
| H28 | The reach is rsqgn_shot_r (0.35 m), never over 12 units; a player's damaging projectile passing that near does the same | T:55, T:56, H:452, T:252, T:253, T:263, T:264, CVARINFO.txt:28 | RSQGN_Thrown.ShotR; RSQGN_Handler.WorldTick; RSQGN_Thrown.ShotByMissile |
| H28 | In the air it is marked a skeet and the new blast adds the gold sequence; another player's shot makes him the blast's owner; the row | T:275, T:278, T:283, T:287, X:413, X:535, U:75, U:76, CVARINFO.txt:27 | RSQGN_Thrown.Shot; RSQGN_Boom.ForGrenade; Begin; RSQGN_Slow.CanShoot |
| H29 | No grenades and no pin out: the main hand picks a new weapon, the off hand is cleared | H:485, H:532, H:536, H:537 | RSQGN_Handler.WorldTick; Empty |
| H30 | Our barrel replaces the map's; it stands 5 tics, blinks 5 x 2 tics, then blasts | B:264, B:97, B:102, B:106, B:126 | RSQGN_BarrelSwap.CheckReplacement; RSQGN_Barrel Death state |
| H30 | One of the first five sequences at random unless the row picks one; 128 damage over 128 x Barrel Blast Radius (1.5) = 192 | X:480, X:627, B:87, B:88, X:45, X:70, CVARINFO.txt:37, CVARINFO.txt:38, CVARINFO.txt:47 | RSQGN_Boom.Begin; RSQGN_Barrel.A_RSQGN_Blast; RSQGN_Fx.BarrelReach; ChainRadius |
| H31 | A barrel killed by another barrel's blast is one link deeper; bigger down the chain; the blink 10, 8, 6, 6, 4 tics | B:64, B:65, B:66, X:489, X:490, X:491, X:492, X:76 | RSQGN_Barrel.Die; RSQGN_Boom.Begin; RSQGN_Fx.BlinkFor |
| H31 | Reach 160, 192, 224 x 1.5 from the third barrel; the kick from the third barrel; the rows | X:70, X:71, B:87, X:547, X:550, X:53, CVARINFO.txt:62, CVARINFO.txt:68, CVARINFO.txt:69 | RSQGN_Fx.ChainRadius; RSQGN_Barrel.A_RSQGN_Blast; RSQGN_Boom.Begin; RSQGN_Fx.Escalates |
| H32 | Every Chain Mega Every'th barrel (3) plays the mega flipbook at Mega Explosion Size (0.6), every Chain Mushroom Every'th (5) the mushroom, which wins; in place of the barrel's own sequence | X:487, X:488, X:493, X:494, X:44, X:522, X:524, X:532, CVARINFO.txt:64, CVARINFO.txt:65, CVARINFO.txt:66 | RSQGN_Boom.Begin; RSQGN_Fx.MegaSize |
| H32 | Only with the sky over the blast while Big Blasts Outdoors Only is on; the damage is the barrel's own call | X:421, X:422, X:503, X:505, B:88, CVARINFO.txt:67 | RSQGN_Boom.BigHere; Begin; RSQGN_Barrel.A_RSQGN_Blast |
| H33 | Arc: that share of the throw's ground speed added upward (default 0) | H:1086, CVARINFO.txt:20 | RSQGN_Handler.LaunchVel |
| H34 | Only in Slow Motion: shots count only while the world is slowed | U:77, U:78, U:57, H:573, CVARINFO.txt:29 | RSQGN_Slow.CanShoot; Slowed; RSQGN_Handler.ShotTest |
| H35 | Faster in Slow Motion: the grenade runs rsqgn_slowmo_speed (0.5) of the way from the world's speed to real speed | U:67, U:68, U:70, T:234, T:236, CVARINFO.txt:30, CVARINFO.txt:31 | RSQGN_Slow.GrenadeFactor; RSQGN_Thrown.Slow |
| H36 | Your Fire Burns You: Yes burns players; Auto only with Brutal Doom's barrel class or BD22 VR's hand class loaded | K:324, K:327, K:329, K:362, CVARINFO.txt:33 | RSQGN_FireRule.SelfBurns; RSQGN_FireField.Burn |
| H37 | Alt Fire Changes Type off: no type event is sent | H:932, H:934 | RSQGN_Handler.Local |
| H38 | Frag Only: no other type is owned, so there is no next type | K:34, K:35, H:933 | RSQGN_Kind.Owns; RSQGN_Handler.Local |
| H39 | Pin With Your Teeth off: the mouth hold is not counted | H:1033 | RSQGN_Handler.Face |
| H40 | Quick Grenade off: the press returns at once, from the key or +user1 | H:727 | RSQGN_Handler.QuickPress |
| H41 | Shoot Grenades off: no shot test (unless Gun Bonsai VR's Skeet is learned) and no projectile test | U:75, U:76, H:574, H:446 | RSQGN_Slow.CanShoot; RSQGN_Handler.ShotTest; WorldTick |
| H42 | Grenades off: nothing given, nothing scattered; a grenade in a hand keeps the handling alive | H:313, H:314, H:407, S:19, H:329, H:442 | RSQGN_Handler.Active; Equip; RSQGN_Scatter.WorldLoaded; Live; WorldTick |
| H43 | Barrels off: no replacement; a barrel of ours already standing plays the stock death | B:260, B:96, B:131, B:134 | RSQGN_BarrelSwap.CheckReplacement; RSQGN_Barrel Death and StockDeath states |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | SlowMo's scale is asked by service name; the thrown grenade's speed, fall and fuse run at it; real speed when rsqsm_slow_own is off | U:52, U:55, U:65, U:66, T:143, T:236, T:237 | RSQGN_Slow.WorldScale; GrenadeFactor; RSQGN_Thrown.Tick; Slow |
| W1 | The blast effects keep their own clock at the world's speed | U:101, U:104, U:105, B:512, X:575 | RSQGN_Clock.Ask; RSQGN_BarrelLayer.Tick; RSQGN_Boom.Tick |
| W1 | Quick Grenade: at age 8, from the thrower's machine, rsm_pulse for 1500 ms and rsqgn_quickslowmo | T:114, T:210, T:212, T:213, H:722 | RSQGN_Thrown.Tick; QuickSlow |
| W1 | Skeet Window (its level above 0): at age 8, rsm_pulse for its tics and rsqgn_skeetslowmo, if the row is on | T:113, T:218, T:222, T:225, T:226, H:852, CVARINFO.txt:32 | RSQGN_Thrown.Tick; SkeetWindow; RSQGN_Handler.Throw |
| W1 | SlowMo reads the two events by name | SlowMo/zscript/rsqsm/clock.zs:384, SlowMo/zscript/rsqsm/clock.zs:385 | (SlowMo's NetworkProcess) |
| W1 | A revive gives one grenade | U:291, U:307 | RSQGN_RSQDownJoin.GetInt |
| W2 | Gun Bonsai VR's service by name; counted loaded only when it answers "loaded" 1 | U:12, U:18 | RSQGN_Upg.Any; Svc |
| W2 | The thrown grenade, the bomblets and the fire field are claimed for the grenade weapon | H:838, H:841, T:364, T:367, K:253, K:255 | RSQGN_Handler.Throw; RSQGN_Thrown.Cluster; RSQGN_Kind.Claim |
| W2 | With it, a type is owned only when learned | K:36, K:37 | RSQGN_Kind.Owns |
| W2 | The upgrade names read: ShortFuse, StrongArm, FlatArc, Bounce, Bandolier, Scavenger, BigBang, Frag, Cluster, Sticky, Teeth, Skeet, SkeetWindow, CookSense, Impact, the type's own | H:340, H:1082, H:858, H:509, S:57, T:336, T:352, H:848, H:850, T:279, H:852, H:482, K:49, K:194 | RSQGN_Handler.FuseTics; LaunchVel; Throw; Carry; RSQGN_Scatter.Plan; RSQGN_Thrown.Blast; Cluster; Shot; RSQGN_Kind.DamageShare; Effect |
| W2 | Freeze, Stun and Flash ask its "freeze" and "stagger" | K:220, K:226, K:232 | RSQGN_Kind.Effect |
| W2 | The two gated menu rows and what unlocks them | MENUDEF.txt:47, MENUDEF.txt:112, U:128, U:129 | RSQGN_Service.GetIntUI |
| W3 | Touches sent to RS_ScoreService: sticky, freeze.nade, stun.nade, flash, charm / infight, fire.nade, smoke | U:40, U:42, T:198, K:222, K:228, K:235, K:243, K:365, K:410 | RSQGN_Upg.Touch and its callers |
| W3 | Answers: cooked, teeth, skeet, impact, turned.by | U:169, U:172, U:175, U:188, U:189, U:190, U:194, U:198 | RSQGN_Service.GetInt |
| W4 | "No grenades" is offered to RSQVR_Service as a toast first; the type's name as a world word on the hand | H:211, H:732, K:82, H:650 | RSQGN_Handler.Toast; QuickPress; RSQGN_Kind.PopWord; NetworkProcess |
| W5 | The off hand card's MODELDEF blocks, sprite names and gun list ship here | MODELDEF.guncards.txt:1, zscript/rsqgn/gcsprites.zs:6, RSQGCOFF.txt:3 | (generated lumps) |
| W5 | fuse.count / fuse.amber answered only while cooking with Cook Sense 3 | U:266, U:272, U:275, U:276 | RSQGN_Service.GetInt |
| W6 | kinds.owned, kind, kind.set (refused while the spoon is gone or the type is not owned), kind.name, kind.colour.of | U:203, U:209, U:210, U:212, U:213, U:136, U:138, U:253 | RSQGN_Service.GetInt; GetString |
| W6 | The Wheel eats +user1 and the rsqgn_quickthrow key while it is open | Wheel/zscript/wheel/zscript.zs:963, Wheel/zscript/wheel/zscript.zs:964 | (the Wheel's input handler) |
| W7 | The Rig names this grenade's class for its grenade spot | TacticalRig/zscript/rsqtr/rig.zs:1437 | (the Rig's constant) |
| W7 | kind.colour answered; a grenade in the off hand is hand 1 | U:260, U:264, H:357 | RSQGN_Service.GetInt; RSQGN_Handler.HandOf |
| W9 | Room Complement: Glow In The Dark's service must say enabled; the sector's glow turned half way round | X:462, X:615, X:616, X:617, X:619 | RSQGN_Boom.Begin; RoomTint |
| W9 | The Neon Crescent takes the room's own glow hue | X:520, X:630, X:636, CVARINFO.txt:48 | RSQGN_Boom.Begin; RoomHueTint |
| W10 | Kill Colour: the tier asked of RSQMN_RosterService, the highest kept | X:649, X:651, X:652, X:653 | RSQGN_Boom.OnKill |
| W11 | g2.neon: the Neon Crescent forced, set off at the actor, credited to the player; 128 over the barrel's reach | U:159, U:162, U:167, B:181, B:184, B:186, B:88, B:173 | RSQGN_Service.GetInt; RSQGN_NeonSpike.SetOff; A_RSQGN_SpikeBlast |
| W11 | Grapple asks this service by name | Grapple/zscript/rsqgr/core.zs:743 | (Grapple's code) |
| W12 | BD22 VR is found by its handler class; with it and no replace setting this mod is not active; rsg_rsq_nade counts as replace; the default is on | H:294, H:303, H:306, H:312, CVARINFO.txt:7 | RSQGN_Handler.BDVR; ReplacesBD; Active |
| W12 | Not active: nothing given or scattered, no quick throw; a grenade in a hand still handled | H:407, S:19, H:458, H:639, H:326, H:329, H:638 | Equip; RSQGN_Scatter.WorldLoaded; WorldTick; NetworkProcess; Held; Live |
| W12 | The launcher's requests: kind.next, kind.share, kind.word, burst (the blast of that type) | U:222, U:229, U:146, U:257, U:241, U:245, U:248, H:1189 | RSQGN_Service.GetInt; GetDouble; RSQGN_RoundBlast |
| W12 | A revive gives GrenadeAmmo while BD22 VR's grenade is in charge | U:297, U:299, U:300 | RSQGN_RSQDownJoin.GetInt |
| W13 | Added to slot 9 after Brutal Doom's own list | KEYCONF.txt:12 | KEYCONF addslotdefault |
| W13 | Both barrel class names replaced unless Replace BD Barrels is off with BD's barrel present | B:262, B:263, B:264, B:228, CVARINFO.txt:41 | RSQGN_BarrelSwap.CheckReplacement; ReplacesBD |
| W13 | BD's launcher shots by class name: rockets play the rocket flipbook, grenades the grenade blast; their drawing-only actors removed | L:26, L:56, L:68, L:78, L:22, CVARINFO.txt:70 | RSQGN_BDLaunchers.IsShot; WorldThingSpawned; On |
| W13 | Auto fire rule: Brutal Doom's barrel class or BD22 VR's hand class | K:327, K:329 | RSQGN_FireRule.SelfBurns |
| W14 | Mode 2 (default) watches other mods' actors by words in the class name and fits them under the ceiling | X:197, X:258, X:259, X:271, X:279, X:291, CVARINFO.txt:71 | RSQGN_CeilFit.Mode; RSQGN_CeilWatch.Looks; WorldThingSpawned; Fit |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Out of VR the hand code returns before anything is read; the quick throw is not behind that test | H:894, H:40, H:458, H:639 | RSQGN_Handler.Local; RSQGN_Geo.InVR; WorldTick; NetworkProcess |
| L2 | The buttons read: the grenade hand's fire and alt fire, the other hand's fire, +user1; the one key | H:906, H:907, H:915, H:750, KEYCONF.txt:3 | RSQGN_Handler.Local; QuickTick |
| L3 | The other hand's fire is read from the player's command; nothing in the mod eats a button (it has no input handler) | H:905, H:907 | RSQGN_Handler.Local |
| L4 | Pin out, spoon on: only the let-go of the squeeze cooks or throws | H:971, H:985 | RSQGN_Handler.Local |
| L5 | No grenade in a hand: the hand code resets and returns; a thrown grenade goes off only by fuse, Impact touch or a shot | H:897, T:104, T:165, T:287 | RSQGN_Handler.Local; RSQGN_Thrown.Tick; Shot |
| L6 | The only shaping of the throw's angle is the cap on the upward angle | H:1088 | RSQGN_Handler.LaunchVel |
| L7 | 6 tics of grace; an attack reaching 128 units or less never counts; only thrown grenades are tested | T:58, H:452, H:614, H:575, H:592 | RSQGN_Handler.WorldTick; ShotTest |
| L8 | Both parts of the blast hurt their source | T:342, T:343 | RSQGN_Thrown.Blast |
| L9 | The quick grenade's gravity 0.7, floor bounce 0.6, wall bounce 0.3 | H:786, H:787, H:788 | RSQGN_Handler.QuickThrow |
| L10 | A hand more than 96 units from the body's middle throws from the middle; a wall between stops the start point | H:815, H:824 | RSQGN_Handler.Throw |
| L11 | A new map (not a saved game) resets the pin state; no scatter on a saved game or a reopened map | H:396, H:397, S:18 | RSQGN_Handler.WorldLoaded; RSQGN_Scatter.WorldLoaded |
| L12 | Only the two barrel class names are replaced, when a thing spawns | B:258, B:262 | RSQGN_BarrelSwap.CheckReplacement |
| L13 | The flipbook finale is chosen only in the barrel branch, at depth 1 or more | X:470, X:485, X:497 | RSQGN_Boom.Begin |
| L14 | 8 lights at most; the effects cap (600) and what plays past it | X:32, X:560, B:237, B:292, B:739, CVARINFO.txt:50 | RSQGN_Fx.LIGHT_CAP; RSQGN_Boom.Begin; RSQGN_BarrelSwap.Cap; RSQGN_BarrelBook.Room; RSQGN_BarrelFX.Step |
| L15 | One key section with one key | KEYCONF.txt:13, KEYCONF.txt:14 | KEYCONF addkeysection and addmenukey |
