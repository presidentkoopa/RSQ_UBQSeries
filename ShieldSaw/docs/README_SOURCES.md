# RSQ ShieldSaw: where each README claim comes from

Commit read: 1a846b85c (2026-11-27), then the controls change of 2026-11-27 (owner; uncommitted when this was written):
the How to play, Works with and Limits rows below cite the working tree after it. Paths are inside `ShieldSaw/`. `S` is
`zscript/ssq/state.zs`, `G` is `zscript/ssq/guard.zs`, `D` is `zscript/ssq/disc.zs`, `P` is `zscript/ssq/pose.zs`, `W` is
`zscript/ssq/shield.zs`; other files are named in full (`../Wheel/...` and `../TacticalRig/...` are those mods' files).
Each line number is the line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | One key, with no default bind; its event, with the shield away, draws it: what the off hand held is remembered, the shield is the off hand weapon, a sound and a buzz | KEYCONF.txt:8, KEYCONF.txt:10, S:1214, S:1220, S:863, S:867, S:876, S:877 | KEYCONF alias and addmenukey; SSQ_Handler.NetworkProcess; Draw |
| H2 | In the off hand, the key's event stows it: the remembered weapon is handed back, else RSQ Saber's off blade or RSQ_Hands | S:1221, S:936, S:918, S:919, S:311 | SSQ_Handler.NetworkProcess; Stow; Unstow; HandBack |
| H3 | In flight, the key's event recalls the disc; Recall is Home | S:1222, D:528, D:485 | SSQ_Handler.NetworkProcess; SSQ_Disc.Recall; Home |
| H4 | With the shield drawn, main attack held and a fresh main hand aim is the lock input; the aim is sent by the player's own machine while both hold | S:762, S:1504, S:1514, S:1198, S:1205 | SSQ_Handler.LocksTick; SendAim; NetworkProcess |
| H4 | One ring every ssq_paint_every (3) tics, the best in the main hand's cone only, up to the wanted count (5); a sound and a buzz in the off hand for each | S:799, S:802, S:810, S:812, S:817, S:818, W:244, D:120, CVARINFO.txt:29, CVARINFO.txt:36 | SSQ_Handler.LocksTick; SSQ_FX.Buzz; SSQ_Disc.WantLocks |
| H4 | A target must be within the lock cone (25 degrees), the lock range (1200) and in sight | D:279, D:280, D:297, D:299, D:300, CVARINFO.txt:30, CVARINFO.txt:33 | SSQ_Disc.FindTargets |
| H4 | The button is only read from the player's command: nothing takes it from the main hand's gun | S:762, S:535 | SSQ_Handler.LocksTick; InputProcess |
| H5 | Letting go of the lock input keeps the rings ssq_keep_marks (175) tics, then they are cleared | S:764, S:776, CVARINFO.txt:37 | SSQ_Handler.LocksTick |
| H6 | The off trigger held raises the rev a tic at a time to ssq_rev_tics (21); released it falls by 2 a tic; the loop's pitch climbs; blade frames | W:127, W:128, W:129, W:134, W:135, W:47, W:48, CVARINFO.txt:58 | SSQ_ShieldSaw.A_SSQ_Held; Frame |
| H7 | The press of off attack with the shield drawn and rings on clears every ring | S:496, S:497, S:500, S:502 | SSQ_Handler.WorldTick; ClearLocks |
| H8 | The grind needs a full rev and Grind Damage above 0; a body on the plate is hit, each no oftener than Grind Gap (4 tics); blood, sound, sparks, buzz | G:1023, W:52, G:1098, G:1115, G:1129, G:1130, G:1132, G:1135, G:1136, G:1137, CVARINFO.txt:59, CVARINFO.txt:60 | SSQ_Guard.HeldTick; SSQ_ShieldSaw.Revved |
| H9 | With the shield drawn: the arm's peak speed at or over ssq_throw_arm (2.2 m/s) and the forward test (cosine 0.35 of the look direction) arm a throw; it is thrown the next tic | S:567, S:570, S:574, S:579, S:582, S:553, S:566, CVARINFO.txt:23, CVARINFO.txt:26 | SSQ_Handler.FlickTick; Throw |
| H9 | With rings shown the disc leaves halfway between the swing and the first ringed monster (when that is not behind the swing), carries the shown rings in order, steers to each and goes home after the last | D:231, D:233, D:234, D:317, D:322, D:375, D:376, D:675, D:677 | SSQ_Disc.Launch; FindLocks; Tick; Next |
| H10 | With no marks shown the disc takes a fresh cone along the throw; with no lock at all it goes home after 2 seconds | D:318, D:381 | SSQ_Disc.FindLocks; Tick |
| H10 | A wall is bounced off while bounces are left (ssq_bounces, 3), else the disc goes home | D:95, D:149, D:150, D:256, CVARINFO.txt:188 | SSQ_Disc Bounce state; WallBounce; Begin |
| H11 | The swing gives the bonus: 0 at ssq_throw_arm, 1 at twice it, linear; it scales the launch speed and the hit by up to ssq_rev_throw_bonus (0.6) | D:199, D:200, D:202, D:562, CVARINFO.txt:61 | SSQ_Disc.Launch; SpecialMissileHit |
| H12 | Draw sets a 10 tic hold; while it runs no swing is read | S:550, S:873, S:504, S:559 | SSQ_Handler.Draw; WorldTick; FlickTick |
| H13 | A bash that lands starts its 10 tic cooldown; while it runs nothing is thrown, and a swing seen the tic before is dropped | G:1143, G:1016, S:561, S:566 | SSQ_Guard.HeldTick; SSQ_Handler.FlickTick |
| H14 | At or under 70 spawn health, not a boss: forced gib damage and the disc goes on | D:566, D:589, D:594, D:598, D:602, CVARINFO.txt:51 | SSQ_Disc.SpecialMissileHit |
| H14 | At or under 600, on the way out: the disc embeds for ssq_embed_tics (21) and grinds every third tic | D:567, D:605, D:611, D:614, D:422, D:424, CVARINFO.txt:52, CVARINFO.txt:53 | SSQ_Disc.SpecialMissileHit; Tick |
| H14 | Otherwise a glance at ssq_glance_scale (0.4) and the disc is sent away from the body | D:623, D:624, D:629, D:630, CVARINFO.txt:55 | SSQ_Disc.SpecialMissileHit |
| H15 | On the way home, a fresh hand pose within ssq_catch_radius (24) of the disc is a catch, when Catch on Return is on | D:448, D:451, D:452, CVARINFO.txt:42, CVARINFO.txt:43 | SSQ_Disc.Tick |
| H15 | A catch draws the shield with a buzz; otherwise the disc ends at the mount (the shoulder when mounted, else the middle of the player) and the shield is stowed: drawn there only when mounted | S:968, S:974, S:976, D:454, D:461, S:237, S:238, S:1012 | SSQ_Handler.DiscHome; MountPos; Props; SSQ_Disc.Tick |
| H16 | With Shield Blocks on, an attack whose line crosses the plate does zero damage; block sound, buzz and sparks | G:370, G:411, G:422, G:472, G:474, G:486, CVARINFO.txt:64 | SSQ_Guard.AbsorbDamage |
| H17 | A blocked missile comes back as a new one of its class owned by the player, when Blocked Shots is Returned | G:502, G:505, G:823, G:830, CVARINFO.txt:69 | SSQ_Guard.AbsorbDamage; Deflect |
| H17 | Aim 3 (default): mirrored off the face, with the plate's own travel added | G:745, G:748, G:752, G:756, G:757, CVARINFO.txt:70 | SSQ_Guard.DeflectDir |
| H17 | With Turn Shots Early on, a missile whose path crosses the plate is turned in flight and becomes the player's | G:665, G:686, G:687, G:693, G:698, G:787, G:797, CVARINFO.txt:74 | SSQ_Guard.DoEffect; BatBack |
| H18 | A monster's hitscan whose line crosses a player's plate is cancelled before the trace | S:1116, S:1118, S:1142, S:1145, G:561, CVARINFO.txt:81 | SSQ_Handler.WorldHitscanPreFired; SSQ_Guard.StopsHitscan |
| H18 | A bullet goes back from the plate with the stopped shot's damage times ssq_hitscan_damage (1.0) | G:587, G:592, G:634, CVARINFO.txt:82, CVARINFO.txt:83 | SSQ_Guard.StopsHitscan |
| H19 | Melee is damage from the attacker itself within its reach; blocked, it is put in pain, and shoved when Blocked Melee is 2 | G:397, G:399, G:491, G:494, G:495, G:498, CVARINFO.txt:84 | SSQ_Guard.AbsorbDamage |
| H20 | Perfect: the plate moving into the attack at ssq_perfect_speed (25 units a second) or more, best of the last windows | G:433, G:438, G:444, G:445, G:446, CVARINFO.txt:44, CVARINFO.txt:45 | SSQ_Guard.AbsorbDamage |
| H20 | It rings higher, knocks twice, blooms; a missile returns at 1.6 times; a melee attacker is always staggered and shoved twice as far | G:472, G:474, G:480, G:482, G:492, G:495, G:498, G:505 | SSQ_Guard.AbsorbDamage |
| H21 | A bash needs Shield Bash on, no cooldown, and a push along the face (one tic's, or the decaying sum) of ssq_bash_speed (45 units a second) | G:1025, G:1036, G:1037, G:1044, CVARINFO.txt:88, CVARINFO.txt:92 | SSQ_Guard.HeldTick |
| H21 | It hits a body in front of the face, damage 10 to 40 by the push, thrust and lift scaled by mass, a long buzz, a burst, 10 tics cooldown | G:1139, G:1141, G:1143, G:848, G:880, G:881, G:882, G:884, G:886, G:900 | SSQ_Guard.HeldTick; Bash |
| H22 | A bashed body is watched; stopped by a line it was moving into at ssq_slam_min or more, it is slammed | G:907, S:1315, S:1330, S:1341, S:1342, S:1344, CVARINFO.txt:101, CVARINFO.txt:103 | SSQ_Guard.Bash; SSQ_Handler.ArmSlam; SlamTick |
| H22 | Slam damage is 2 times the impact, 5 to 40; pain, a freeze of ssq_slam_stun (8), a rebound | S:1359, S:1382, S:1383, S:1384, CVARINFO.txt:104 | SSQ_Handler.Slam |
| H23 | Shield in the off hand and a main gun with a Reload state: the barrel dropping 45 degrees inside the window to 40 below level enters Reload | zscript/ssq/offflick.zs:29, zscript/ssq/offflick.zs:41, zscript/ssq/offflick.zs:50, zscript/ssq/offflick.zs:51, zscript/ssq/offflick.zs:53, zscript/ssq/offflick.zs:55, zscript/ssq/offflick.zs:64 | SSQ_OffFlick.IsGun; WorldTick; Reload |
| H24 | With Off Hand Switch at Keep Shield, an off hand that lost the shield gets it back the same tic | S:488, S:627, S:638, S:639, S:640, CVARINFO.txt:68 | SSQ_Handler.WorldTick; PinHands |
| H25 | A dead player's drawn shield is stowed | S:468, S:470 | SSQ_Handler.WorldTick |
| H26 | Braced: main hand weapon named UBQS_ (not the Force hand), lit, two or more of nine blade points over the face within the gap | S:1405, S:1414, S:1416, S:1427, S:1433, S:1434, S:1442, CVARINFO.txt:113, CVARINFO.txt:115 | SSQ_Handler.BraceNow |
| H26 | The stance is sent as an event and widens the held plate by ssq_brace_widen (1.3) | S:1452, S:1259, G:239, G:344, CVARINFO.txt:114 | SSQ_Handler.SendBrace; NetworkProcess; SSQ_Guard.Plate; BraceK |
| H27 | RSQ Wheel sends the key's event when the shield's card is taken and the shield is not in the off hand, whichever hand took it | ../Wheel/zscript/wheel/zscript.zs:10825, ../Wheel/zscript/wheel/zscript.zs:10988, S:1220 | wr_Rig.commit; SSQ_Handler.NetworkProcess |
| H28 | On the Wheel's assignment screen the shield's card is sent only to the ring the Rig allows (the off shoulder); the Rig mounts it; a mounted shield is found by name every tic and drawn at that holster | ../Wheel/zscript/wheel/wr_web.zs:436, ../Wheel/zscript/wheel/wr_web.zs:452, ../TacticalRig/zscript/rsqtr/rig.zs:1348, ../TacticalRig/zscript/rsqtr/hooks.zs:57, S:221, S:225, S:1013 | wr_Rig.webPick; RSQTR_Rig.WebAssign; RSQTR_Hooks.SawSlot; SSQ_Handler.MountTick; Props |
| H28 | While mounted the holster is the shield's: a gun there loses it and the Wheel refuses a gun for it | ../TacticalRig/zscript/rsqtr/hooks.zs:72, ../TacticalRig/zscript/rsqtr/rig.zs:1404, ../Wheel/zscript/wheel/wr_web.zs:443 | RSQTR_Hooks.ShieldHolster; RSQTR_Rig.ShieldTick; wr_Rig.webPick |
| H29 | Clear sends the unassign event for the shield's card; the Rig clears the mount | ../Wheel/zscript/wheel/wr_web.zs:461, ../TacticalRig/zscript/rsqtr/rig.zs:1414 | wr_Rig.webPick; RSQTR_Rig.WebUnassign |
| H30 | The off hand's grip (not Use) at the mounted shoulder sends the key's event, unless the disc is out | ../TacticalRig/zscript/rsqtr/rig.zs:3340, ../TacticalRig/zscript/rsqtr/rig.zs:3342, ../TacticalRig/zscript/rsqtr/rig.zs:3344, ../TacticalRig/zscript/rsqtr/rig.zs:3345, ../TacticalRig/zscript/rsqtr/hooks.zs:90 | RSQTR_Rig.Press; RSQTR_Hooks.SawState |
| H31 | With Offhand Weapon Cycle on, a key whose binding holds "weapnext 1" or "weapprev 1" sends the cycle event; the key is not eaten | S:530, S:531, S:533, S:534, S:535, CVARINFO.txt:169 | SSQ_Handler.InputProcess |
| H31 | Stowed: drawn when the pick is the shield. Drawn: stowed and the pick comes up in the off hand | S:1234, S:1236, S:1237, S:481, S:1244, S:1246, S:1247, S:1249 | SSQ_Handler.NetworkProcess; WorldTick |
| H32 | Start in Hand counts 3 tics from the give, then draws | S:400, S:490, CVARINFO.txt:133 | SSQ_Handler.Give; WorldTick |
| H33 | Start With Shield off: the shield is not given | S:391, CVARINFO.txt:6 | SSQ_Handler.Give |
| H34 | Off Hand Switch: Allow Switch: a real weapon arriving in the off hand stows the shield; a filler or an empty hand is pinned back | S:488, S:683, S:688, MENUDEF.txt:65 | SSQ_Handler.WorldTick; HoldOrYield |
| H35 | Block While Holstered on, without Gun Bonsai VR: the plate of a stowed and mounted shield blocks and turns | G:244, G:261, G:262, G:267, CVARINFO.txt:67 | SSQ_Guard.Plate; BackPlate; PlateTurns |
| H36 | Hit Stop on: a bashed body, and the source of a perfect block, is frozen for ssq_hitstop_tics (4) | G:353, G:360, G:361, G:904, G:453, CVARINFO.txt:106, CVARINFO.txt:107 | SSQ_Guard.HitStop; HitStopTics; Bash; AbsorbDamage |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Tactical Rig (RSQTR_RigService "rig.locked" for SSQ_ShieldSaw, "region.x" / ".y" / ".z"): the mount and its place; no answer, no mount | S:216, S:217, S:221, S:224, S:226 | SSQ_Handler.MountTick |
| X1 | With Turn With the Rig on (RSQTR_BodyService "body.yaw"): the body yaw is the Rig's, and the own keeper is not run; the mounted shield faces with it | S:165, S:167, S:169, S:173, S:1014 | SSQ_Handler.BodyKeep; Props |
| X1 | The Rig's side: the grip at the mounted shoulder, the holster kept from guns | ../TacticalRig/zscript/rsqtr/rig.zs:3345, ../TacticalRig/zscript/rsqtr/hooks.zs:72 | RSQTR_Rig.Press; RSQTR_Hooks.ShieldHolster |
| X3 | RSQ Gun Bonsai VR is RSQ_MeleeUpgradeService answering "loaded" 1; levels and numbers are asked by name | zscript/ssq/score.zs:186, zscript/ssq/score.zs:192, zscript/ssq/score.zs:198, zscript/ssq/score.zs:206 | SSQ_Upg.Any; Svc; Lv; Num |
| X3 | Lockstep: with the patch on, the lock count is Max Locks less 4 plus the level, never under 1 | D:121, D:122 | SSQ_Disc.WantLocks |
| X3 | Broadening, Shield Size, Bulwark, Rebound, Reflect | G:152, G:99, G:438, G:595, G:598 | SSQ_Guard.GrowFor; SizeFor; AbsorbDamage; StopsHitscan |
| X3 | Rev Shield, Hungry Blades, Spartan, Charge, Shield Dash, Battering Ram | G:306, G:296, G:290, G:917, G:1041, G:909 | SSQ_Guard.RevShield; GrindDamage; Spartan; Charge; HeldTick; Bash |
| X3 | Wall Slam; Ricochet, Meat Grinder, Hunter's Return, Cleaver, Hungry Blades, Buzzsaw Return, Wall Bounces on the disc | S:1358, D:106, D:107, D:108, D:109, D:110, D:111, D:112 | SSQ_Handler.Slam; SSQ_Disc.Claim |
| X3 | Back Plate, Shield Wall and Strike True gate their rows: greyed while not learned | G:262, G:264, G:275, G:277, G:361, G:362, zscript/ssq/score.zs:125, MENUDEF.txt:126, MENUDEF.txt:138, MENUDEF.txt:148 | SSQ_Guard.BackPlate; ShieldWallMs; HitStopTics; SSQ_ScoreService.GetIntUI |
| X3 | Damage is credited to the ShieldSaw (credit.push / credit.pop, the disc's and turned shots' master, the returned bullet's claim) | G:849, G:851, G:1131, G:1133, D:104, G:791, G:832, G:626 | SSQ_Guard.Bash; HeldTick; SSQ_Disc.Claim; SSQ_Guard.BatBack; Deflect; StopsHitscan |
| X4 | RSQ SlowMo: a perfect block sends rsm_pulse for 500 ms when Perfect Block Slow Motion is on (default off) | G:274, G:275, G:458, G:460, CVARINFO.txt:110 | SSQ_Guard.ShieldWallMs; AbsorbDamage |
| X5 | RSQ Score (RS_ScoreService "touch"): moves are reported as they land | zscript/ssq/score.zs:218, zscript/ssq/score.zs:220, S:1361, G:423 | SSQ_Upg.Touch; SSQ_Handler.Slam; SSQ_Guard.AbsorbDamage |
| X5 | SSQ_ScoreService answers locked, blocked, returned, perfect, grind.held, thrown.leg, disc.grinding, returned.from | zscript/ssq/score.zs:134, zscript/ssq/score.zs:144, zscript/ssq/score.zs:145, zscript/ssq/score.zs:146, zscript/ssq/score.zs:148, zscript/ssq/score.zs:164, zscript/ssq/score.zs:165, zscript/ssq/score.zs:173 | SSQ_ScoreService.GetInt; GetObject |
| X6 | RSQ Saber: the brace reads the UBQS_ class name, UBQS_SaberService "saber.lit" and ubqs_size | S:1414, S:1415, S:1416, S:1417 | SSQ_Handler.BraceNow |
| X6 | UBQS_SaberOff is handed the off hand when the shield leaves and displaced nothing; a UBQS_ weapon arriving by itself is not a yield | S:311, S:919, S:304, S:683 | SSQ_Handler.HandBack; Unstow; IsFiller; HoldOrYield |
| X7 | RSQ Wheel: taking the shield's card sends the key's event; the event is the Draw and Put Back key's | ../Wheel/zscript/wheel/zscript.zs:10988, S:1214, S:1220 | wr_Rig.commit; SSQ_Handler.NetworkProcess |
| X7 | RSQ Wheel (wr_RigService "offhand.pick" within 2 tics): the shield is stowed and the picked weapon stays, under either Off Hand Switch setting | S:487, S:692, S:696, S:697, S:709, S:710 | SSQ_Handler.WorldTick; WheelPickedOff; YieldToPick |
| X7 | The assignment screen: only the off shoulder ring takes the shield; Clear un-mounts it | ../Wheel/zscript/wheel/wr_web.zs:436, ../Wheel/zscript/wheel/wr_web.zs:461 | wr_Rig.webPick |
| X8 | BD22 VR Reloaded's RSQ_Hands: handed back when nothing else was displaced, never remembered as the earlier weapon | S:311, S:863 | SSQ_Handler.HandBack; Draw |
| X8 | The flick reload obeys rsq_flick when it exists; other layers are forwarded to RSQ_Hands' placement hook | zscript/ssq/offflick.zs:39, zscript/ssq/offflick.zs:41, W:162, W:167 | SSQ_OffFlick.WorldTick; SSQ_ShieldSaw.ModifyBobLayer3D |
| X9 | Brutal Doom: inventory named SK... is lifted for the bash's hit and the blocked melee's pain, and given back if the monster lives | W:223, W:205, W:207, W:232, G:850, G:494 | SSQ_FX.Lift; Hit; Restore; SSQ_Guard.Bash; AbsorbDamage |
| X10 | LegenDoom: a monster with LDLegendaryMonsterToken and not yet transformed adds its refill to the tier health, unless LD_legendarymonsters is 0 | D:650, D:654, D:655, D:657, D:668 | SSQ_Disc.TierHealth |
| X11 | RSQ Miniboss (RSQMB_Ward, RSQMB_Service "bossfor" "ldhealth"): the higher health share | D:661, D:665, D:666 | SSQ_Disc.TierHealth |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | The shield is flagged an off hand weapon that cannot switch hands | W:22, W:23 | SSQ_ShieldSaw Default |
| L2 | Away, nothing is drawn unless mounted, and the mount is the Rig's answer | S:1012, S:221 | SSQ_Handler.Props; MountTick |
| L3 | Off VR no pose and no aim is sent; the held plate, the rings and the swing need a fresh pose | S:1464, S:1503, G:234, S:769, S:559 | SSQ_Handler.SendPose; SendAim; SSQ_Guard.Plate; SSQ_Handler.LocksTick; FlickTick |
| L3 | The key's event needs no pose | S:1220 | SSQ_Handler.NetworkProcess |
| L4 | Buttons read for the shield: main attack (rings) and off attack (rev, clearing the rings); the Rig reads the grip at the mounted shoulder | S:762, S:496, W:127, ../TacticalRig/zscript/rsqtr/rig.zs:3342 | SSQ_Handler.LocksTick; WorldTick; SSQ_ShieldSaw.A_SSQ_Held; RSQTR_Rig.Press |
| L5 | No button throws: the swing alone, held off for 10 tics after a draw and while the bash cooldown runs | S:582, S:559, S:561 | SSQ_Handler.FlickTick |
| L6 | Off attack recalls nothing; only the key's event does | S:497, S:1222 | SSQ_Handler.WorldTick; NetworkProcess |
| L7 | A thrown shield stops no bullet, and no plate is up unless it is drawn, or stowed and mounted | S:1139, G:234, G:244 | SSQ_Handler.WorldHitscanPreFired; SSQ_Guard.Plate |
| L8 | A player's own shots are never tested | S:1118 | SSQ_Handler.WorldHitscanPreFired |
| L8 | Outside deathmatch the disc, the bash and grind skip players; rings skip players and friendly monsters | D:546, G:1079, D:293, D:294 | SSQ_Disc.SpecialMissileHit; SSQ_Guard.HeldTick; SSQ_Disc.FindTargets |
| L9 | The cut and the embed both exclude a boss | D:589, D:605 | SSQ_Disc.SpecialMissileHit |
| L10 | With Bash Needs Sight on, a body out of sight is skipped | G:1053, G:1106, CVARINFO.txt:95 | SSQ_Guard.HeldTick |
| L11 | Past ssq_home_patience (105 tics) of returning the disc stops clipping | D:439, D:441, CVARINFO.txt:41 | SSQ_Disc.Tick |
| L11 | At 12 seconds of age the disc is ended and the shield is stowed | D:346, D:534, S:968 | SSQ_Disc.Tick; Done; SSQ_Handler.DiscHome |
| L12 | Entering a map sets the state to stowed, and a shield found in the off hand while not drawn is put away | S:388, S:482 | SSQ_Handler.Give; WorldTick |
| L13 | One key section with one key | KEYCONF.txt:9, KEYCONF.txt:10 | KEYCONF |
