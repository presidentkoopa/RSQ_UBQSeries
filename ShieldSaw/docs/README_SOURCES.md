# RSQ ShieldSaw: where each README claim comes from

Commit read: 1a846b85c (2026-11-27). Paths are inside `ShieldSaw/`. `S` is `zscript/ssq/state.zs`, `G` is
`zscript/ssq/guard.zs`, `D` is `zscript/ssq/disc.zs`, `P` is `zscript/ssq/pose.zs`, `W` is `zscript/ssq/shield.zs`;
other files are named in full. Each line number is the line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Use held with the shield stowed runs the press; a hand inside the grab (zone 1 or less) draws; the draw sounds and buzzes | S:828, S:837, S:886, S:887, S:898, S:1229, S:1230 | SSQ_Handler.WorldTick; OnPress; Draw |
| H1 | The default spot is the small of the back: 30 cm behind, 10 cm to the off side, 62 cm below the eyes, 30 cm reach, never in front of the 14 cm line | CVARINFO.txt:143, CVARINFO.txt:149, CVARINFO.txt:150, CVARINFO.txt:151, CVARINFO.txt:152, S:405, S:396, S:439 | SSQ_Handler.SpotCentre; SpotFrac |
| H1 | What the off hand held is remembered and steps aside; Draw With Use is on by default | S:1218, S:1222, CVARINFO.txt:172 | SSQ_Handler.Draw |
| H2 | The marker shows while not thrown (When Needed), not on the key route, and is brightest inside the grab, brighter in the near zone | S:1357, S:1358, S:1359, S:1368, CVARINFO.txt:175 | SSQ_Handler.Props |
| H3 | A Use press with the shield drawn and the hand at the spot stows it | S:838, S:899 | SSQ_Handler.WorldTick; OnPress |
| H3 | On Manual Store: Fist forgets the earlier weapon and hands back RSQ_Hands if the player has it, else nothing | S:1290, S:1249, S:1272, S:604, S:605, CVARINFO.txt:66 | SSQ_Handler.Stow; Unstow; FistBack |
| H4 | One key, with no default bind; its event draws, stows, or recalls | KEYCONF.txt:7, KEYCONF.txt:11, S:1589, S:1590, S:1591 | KEYCONF alias and addmenukey; SSQ_Handler.NetworkProcess |
| H5 | The off trigger held raises the rev a tic at a time to ssq_rev_tics (21); released it falls by 2 a tic; the loop's pitch climbs; blade frames | W:127, W:128, W:129, W:134, W:135, W:47, W:48, CVARINFO.txt:58 | SSQ_ShieldSaw.A_SSQ_Held; Frame |
| H6 | The grind needs a full rev and Grind Damage above 0; a body on the plate is hit, each no oftener than Grind Gap (4 tics); blood, sound, sparks, buzz | G:1021, W:52, G:1096, G:1113, G:1127, G:1128, G:1130, G:1133, G:1134, G:1135, CVARINFO.txt:59, CVARINFO.txt:60 | SSQ_Guard.HeldTick; SSQ_ShieldSaw.Revved |
| H7 | With Lock On With not Use, the lock is the throw button; the throw button is the off trigger by default | S:651, S:652, S:624, CVARINFO.txt:31, CVARINFO.txt:174 | SSQ_Handler.LockHeld; SecHeld |
| H7 | One ring every ssq_paint_every (3) tics, the best in the cone only, up to the wanted count (5); a sound and a buzz for each | S:1154, S:1157, S:1165, S:1167, S:1172, S:1173, D:119, CVARINFO.txt:29, CVARINFO.txt:36 | SSQ_Handler.LocksTick; SSQ_Disc.WantLocks |
| H7 | A target must be within the lock cone (25 degrees), the lock range (1200) and in sight | D:272, D:273, D:290, D:292, D:293, CVARINFO.txt:30, CVARINFO.txt:33 | SSQ_Disc.FindTargets |
| H8 | Letting go of the throw button runs the release | S:843, S:845 | SSQ_Handler.WorldTick |
| H8 | With a live mark, the release throws only when the arm moves at MARK_MPS (1 m/s) or more, within 60 degrees of the first mark | S:933, S:936, S:938, S:940, P:169, P:170, P:193 | SSQ_Handler.OnRelease; SSQ_Fling.TowardMark |
| H8 | The disc leaves halfway between the swing and the first mark, carries the shown marks in order, steers to each and goes home after the last | D:226, D:228, D:229, D:310, D:315, D:368, D:369, D:667, D:669 | SSQ_Disc.Launch; FindLocks; Tick; Next |
| H9 | With nothing marked: arm speed at or over ssq_throw_arm (2.2 m/s) and the forward test (cosine 0.35 of the look direction) | S:916, S:920, S:921, S:940, CVARINFO.txt:25, CVARINFO.txt:26 | SSQ_Handler.OnRelease |
| H9 | With no marks shown the disc takes a fresh cone along the throw; with no lock at all it goes home after 2 seconds | D:311, D:374 | SSQ_Disc.FindLocks; Tick |
| H9 | A wall is bounced off while bounces are left (ssq_bounces, 3), else the disc goes home | D:94, D:148, D:149, D:249, CVARINFO.txt:192 | SSQ_Disc Bounce state; WallBounce; Begin |
| H10 | A release that is not a throw keeps the marks for ssq_keep_marks (175 tics) | S:941, S:1131, CVARINFO.txt:37 | SSQ_Handler.OnRelease; LocksTick |
| H11 | The rev at the throw adds up to ssq_rev_throw_bonus (0.6) of speed and of damage | S:1305, D:188, D:197, D:554, CVARINFO.txt:61 | SSQ_Handler.Throw; SSQ_Disc.Launch; SpecialMissileHit |
| H12 | At or under 70 spawn health, not a boss: forced gib damage and the disc goes on | D:558, D:581, D:586, D:590, D:594, CVARINFO.txt:51 | SSQ_Disc.SpecialMissileHit |
| H12 | At or under 600, on the way out: the disc embeds for ssq_embed_tics (21) and grinds every third tic | D:559, D:597, D:603, D:606, D:415, D:417, CVARINFO.txt:52, CVARINFO.txt:53 | SSQ_Disc.SpecialMissileHit; Tick |
| H12 | Otherwise a glance at ssq_glance_scale (0.4) and the disc is sent away from the body | D:615, D:616, D:621, D:622, CVARINFO.txt:55 | SSQ_Disc.SpecialMissileHit |
| H13 | A press of the throw button while the disc flies recalls it; Recall is Home | S:846, D:520, D:477 | SSQ_Handler.WorldTick; SSQ_Disc.Recall; Home |
| H14 | On the way home, a fresh hand pose within ssq_catch_radius (24) of the disc is a catch, when Catch on Return is on | D:440, D:443, D:444, CVARINFO.txt:42, CVARINFO.txt:43 | SSQ_Disc.Tick |
| H14 | A catch draws the shield with a buzz; otherwise the disc ends at the mount and the shield is stowed | S:1324, S:1330, S:1333, D:446, D:453 | SSQ_Handler.DiscHome; SSQ_Disc.Tick |
| H15 | With Shield Blocks on, an attack whose line crosses the plate does zero damage; block sound, buzz and sparks | G:368, G:409, G:420, G:470, G:472, G:484, CVARINFO.txt:64 | SSQ_Guard.AbsorbDamage |
| H16 | A blocked missile comes back as a new one of its class owned by the player, when Blocked Shots is Returned | G:500, G:503, G:821, G:828, CVARINFO.txt:69 | SSQ_Guard.AbsorbDamage; Deflect |
| H16 | Aim 3 (default): mirrored off the face, with the plate's own travel added | G:743, G:746, G:750, G:754, G:755, CVARINFO.txt:70 | SSQ_Guard.DeflectDir |
| H16 | With Turn Shots Early on, a missile whose path crosses the plate is turned in flight and becomes the player's | G:663, G:684, G:685, G:691, G:696, G:785, G:795, CVARINFO.txt:74 | SSQ_Guard.DoEffect; BatBack |
| H17 | A monster's hitscan whose line crosses a player's plate is cancelled before the trace | S:1492, S:1494, S:1518, S:1521, G:559, CVARINFO.txt:81 | SSQ_Handler.WorldHitscanPreFired; SSQ_Guard.StopsHitscan |
| H17 | A bullet goes back from the plate with the stopped shot's damage times ssq_hitscan_damage (1.0) | G:585, G:590, G:632, CVARINFO.txt:82, CVARINFO.txt:83 | SSQ_Guard.StopsHitscan |
| H18 | Melee is damage from the attacker itself within its reach; blocked, it is put in pain, and shoved when Blocked Melee is 2 | G:395, G:397, G:489, G:492, G:493, G:496, CVARINFO.txt:84 | SSQ_Guard.AbsorbDamage |
| H19 | Perfect: the plate moving into the attack at ssq_perfect_speed (25 units a second) or more, best of the last windows | G:431, G:436, G:442, G:443, G:444, CVARINFO.txt:44, CVARINFO.txt:45 | SSQ_Guard.AbsorbDamage |
| H19 | It rings higher, knocks twice, blooms; a missile returns at 1.6 times; a melee attacker is always staggered and shoved twice as far | G:470, G:472, G:478, G:480, G:490, G:493, G:496, G:503 | SSQ_Guard.AbsorbDamage |
| H20 | A bash needs Shield Bash on, no cooldown, and a push along the face (one tic's, or the decaying sum) of ssq_bash_speed (45 units a second) | G:1023, G:1034, G:1035, G:1042, CVARINFO.txt:88, CVARINFO.txt:92 | SSQ_Guard.HeldTick |
| H20 | It hits a body in front of the face, damage 10 to 40 by the push, thrust and lift scaled by mass, a long buzz, a burst, 10 tics cooldown | G:1137, G:1139, G:1141, G:846, G:878, G:879, G:880, G:882, G:884, G:898 | SSQ_Guard.HeldTick; Bash |
| H21 | A bashed body is watched; stopped by a line it was moving into at ssq_slam_min or more, it is slammed | G:905, S:1688, S:1703, S:1714, S:1715, S:1717, CVARINFO.txt:101, CVARINFO.txt:103 | SSQ_Guard.Bash; SSQ_Handler.ArmSlam; SlamTick |
| H21 | Slam damage is 2 times the impact, 5 to 40; pain, a freeze of ssq_slam_stun (8), a rebound | S:1732, S:1755, S:1756, S:1757, CVARINFO.txt:104 | SSQ_Handler.Slam |
| H22 | Each controller within 0.20 m of the chest point for 14 tics, no Use or fire button held, Chest Recenter on: the body yaw becomes the head's | S:330, S:331, S:332, S:333, S:352, S:355, S:357, S:358, S:361, CVARINFO.txt:161 | SSQ_Handler.RecenterGesture |
| H22 | A soft click and a tick in both hands; the gesture runs only in the keeper's own branch, not while the Rig's body answers | S:365, S:371, S:379, S:242, S:302 | SSQ_Handler.RecenterGesture; RecenterFeel; BodyKeep |
| H23 | The body yaw turns by the keeper's step each tic; with snap turning only snaps turn it; the mount and the stowed shield use the body yaw | S:271, zscript/ssq/turnkeep.zs:136, zscript/ssq/turnkeep.zs:140, S:164, S:165, S:1390 | SSQ_Handler.BodyKeep; SSQ_TurnKeeper.Step; SSQ_Handler.BodyYaw; Props |
| H24 | Shield in the off hand and a main gun with a Reload state: the barrel dropping 45 degrees inside the window to 40 below level enters Reload | zscript/ssq/offflick.zs:29, zscript/ssq/offflick.zs:41, zscript/ssq/offflick.zs:50, zscript/ssq/offflick.zs:51, zscript/ssq/offflick.zs:53, zscript/ssq/offflick.zs:55, zscript/ssq/offflick.zs:64 | SSQ_OffFlick.IsGun; WorldTick; Reload |
| H25 | With Off Hand Switch at Keep Shield, an off hand that lost the shield gets it back the same tic | S:822, S:986, S:997, S:998, S:999, CVARINFO.txt:68 | SSQ_Handler.WorldTick; PinHands |
| H26 | A dead player's drawn shield is stowed | S:803, S:805 | SSQ_Handler.WorldTick |
| H27 | ssq_throw has no key; with the shield drawn it throws along the view at 3 times the speed floor (12), flat | KEYCONF.txt:8, S:1632, S:1635, S:1652, S:1657, CVARINFO.txt:27 | KEYCONF alias; SSQ_Handler.NetworkProcess; ThrowAlongAim |
| H28 | ssq_recenter has no key; it sets the recenter flag and the keeper takes the head's yaw | KEYCONF.txt:9, S:1584, S:248, S:252 | KEYCONF alias; SSQ_Handler.NetworkProcess; BodyKeep |
| H29 | Braced: main hand weapon named UBQS_ (not the Force hand), lit, two or more of nine blade points over the face within the gap | S:1778, S:1787, S:1789, S:1800, S:1806, S:1807, S:1815, CVARINFO.txt:113, CVARINFO.txt:115 | SSQ_Handler.BraceNow |
| H29 | The stance is sent as an event and widens the held plate by ssq_brace_widen (1.3) | S:1825, S:1630, G:239, G:342, CVARINFO.txt:114 | SSQ_Handler.SendBrace; NetworkProcess; SSQ_Guard.Plate; BraceK |
| H30 | Lock On With: Use: Use held with the hand not in the mount paints | S:651, S:653, S:657, MENUDEF.txt:75 | SSQ_Handler.LockHeld |
| H31 | Throw Button: Off Alt reads the off hand's alt fire; the rev stays on the off trigger | S:623, W:127, MENUDEF.txt:67 | SSQ_Handler.SecHeld; SSQ_ShieldSaw.A_SSQ_Held |
| H32 | Throw Button: Either reads both off hand buttons | S:625, MENUDEF.txt:68 | SSQ_Handler.SecHeld |
| H33 | With Offhand Weapon Cycle on, a key whose binding holds "weapnext 1" or "weapprev 1" sends the cycle event; the key is not eaten | S:871, S:872, S:874, S:875, S:876, CVARINFO.txt:173 | SSQ_Handler.InputProcess |
| H33 | Stowed: drawn when the pick is the shield. Drawn: stowed and the pick comes up in the off hand | S:1603, S:1605, S:1606, S:815, S:1613, S:1615, S:1617, S:1619 | SSQ_Handler.NetworkProcess; WorldTick |
| H34 | The neck spot: 22 cm behind, 18 cm below the eyes, never in front of the 6 cm line; spot 2 or 3 tests it | S:404, S:397, S:430, CVARINFO.txt:153, CVARINFO.txt:155, MENUDEF.txt:100, MENUDEF.txt:101 | SSQ_Handler.SpotCentre; ZoneFrac |
| H35 | The shoulder spot (0): 27 cm behind, 12 cm to the off side, 30 cm below the view height, 30 cm reach | S:426, S:495, S:496, CVARINFO.txt:138, CVARINFO.txt:139, CVARINFO.txt:140, CVARINFO.txt:141, MENUDEF.txt:98 | SSQ_Handler.ZoneFrac; MountPos |
| H36 | Draw With Use off: the press at the mount does nothing and the marker is hidden | S:897, S:1359 | SSQ_Handler.OnPress; Props |
| H37 | Start in Hand counts 3 tics from the give, then draws | S:735, S:824, CVARINFO.txt:133 | SSQ_Handler.Give; WorldTick |
| H38 | Start With Shield off: the shield is not given | S:726, CVARINFO.txt:6 | SSQ_Handler.Give |
| H39 | On Manual Store: Last Weapon keeps the remembered weapon, which is handed back | S:1290, S:1271, MENUDEF.txt:87 | SSQ_Handler.Stow; Unstow |
| H40 | Off Hand Switch: Allow Switch: a real weapon arriving in the off hand stows the shield; a filler or an empty hand is pinned back | S:822, S:1042, S:1047, MENUDEF.txt:81 | SSQ_Handler.WorldTick; HoldOrYield |
| H41 | Block While Holstered on, without Gun Bonsai VR: the stowed plate blocks and turns | G:242, G:259, G:260, G:265, CVARINFO.txt:67 | SSQ_Guard.Plate; BackPlate; PlateTurns |
| H42 | Hit Stop on: a bashed body, and the source of a perfect block, is frozen for ssq_hitstop_tics (4) | G:351, G:358, G:359, G:902, G:451, CVARINFO.txt:106, CVARINFO.txt:107 | SSQ_Guard.HitStop; HitStopTics; Bash; AbsorbDamage |
| H43 | Body Turns With Hands on: head and both level controllers round the same way start the body turning to them | S:277, zscript/ssq/turnkeep.zs:290, zscript/ssq/turnkeep.zs:299, zscript/ssq/turnkeep.zs:304, CVARINFO.txt:159 | SSQ_Handler.BodyKeep; SSQ_TurnKeeper.With |
| H44 | Body Catches Up on: the head more than 35 degrees off the body for more than 35 tics eases the body round | S:279, S:292, S:294, S:297, S:157, S:158, CVARINFO.txt:160 | SSQ_Handler.BodyKeep |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Tactical Rig (RSQTR_BodyService "body.yaw") with Turn With the Rig on: the body yaw is the Rig's, and the own keeper is not run | S:236, S:238, S:240, S:244, S:248 | SSQ_Handler.BodyKeep |
| X1 | ssq_recenter goes to the Rig's body ("body.recenter") | S:305, S:310 | SSQ_Handler.BodyKeep |
| X1 | Class RSQTR_Rig with rsqtr_use on: a hand inside a Rig holster is not a grab | S:454, S:457, S:458, S:482, S:440 | SSQ_Handler.InRigHolster; SpotFrac |
| X2 | RSQ Accessibility is found by its class RSQA_Menu; without it every setting reads off | zscript/ssq/a11y.zs:28 | SSQ_A11y.Cv |
| X2 | Rumble Strength scales each buzz; Rumble Backup is called as a knock starts | W:241, W:242, W:386, zscript/ssq/a11y.zs:95, zscript/ssq/a11y.zs:159 | SSQ_FX.Buzz; SSQ_Buzzer.Tick; SSQ_A11y.Rumble; RumbleBackup |
| X2 | Gesture Ease: lower throw speed, mark speed and forward test; wider near zone; easier flick | S:916, S:936, S:940, S:445, zscript/ssq/offflick.zs:50, zscript/ssq/offflick.zs:53, zscript/ssq/a11y.zs:48, zscript/ssq/a11y.zs:49 | SSQ_Handler.OnRelease; ZoneK; SSQ_OffFlick.WorldTick; SSQ_A11y.Wide; Low |
| X2 | Steady Hands: the smoothed aim is sent with the pose and used for the locks and the throw's aim share | S:1862, S:1869, S:1569, S:1143, S:1157, D:205 | SSQ_Handler.SendPose; NetworkProcess; LocksTick; SSQ_Disc.Launch |
| X2 | Seated Play: the seat drop is sent with the pose and lowers the mount | S:517, S:1848, S:1571, S:510, S:496 | SSQ_Handler.LocalSeatCm; SendPose; NetworkProcess; SeatUnits; MountPos |
| X2 | Photosensitive Mode: a new block flash at most every 14 tics, dimmed to 40% | W:284, W:287, W:325, zscript/ssq/a11y.zs:22, zscript/ssq/a11y.zs:23 | SSQ_FX.FlashOk; Sparks |
| X2 | Colour blind modes shade the ring; High Contrast: every mark fully lit, a fifth larger; Cue Size scales the marks | D:718, S:1194, S:1196, S:1202, S:1203, zscript/ssq/cb.zs:21 | SSQ_LockMark.PostBeginPlay; SSQ_Handler.LocksTick; SSQ_CB.Mode |
| X2 | One-Handed: with the Off-Hand Modifier held and the shield stowed, the main hand's pose is the one sent | S:1844, S:1845, zscript/ssq/a11y.zs:78 | SSQ_Handler.SendPose; SSQ_A11y.Swapped |
| X2 | The Shield Throw button (rsqa_alt 6) throws at the rings, else along the aim; the Flick Reload button (rsqa_alt 7) reloads | S:1637, S:1641, zscript/ssq/offflick.zs:71, zscript/ssq/offflick.zs:78 | SSQ_Handler.NetworkProcess; SSQ_OffFlick.NetworkProcess |
| X3 | RSQ Gun Bonsai VR is RSQ_MeleeUpgradeService answering "loaded" 1; levels and numbers are asked by name | zscript/ssq/score.zs:186, zscript/ssq/score.zs:192, zscript/ssq/score.zs:198, zscript/ssq/score.zs:206 | SSQ_Upg.Any; Svc; Lv; Num |
| X3 | Lockstep: with the patch on, the lock count is Max Locks less 4 plus the level, never under 1 | D:120, D:121 | SSQ_Disc.WantLocks |
| X3 | Broadening, Shield Size, Bulwark, Rebound, Reflect | G:152, G:99, G:436, G:593, G:596 | SSQ_Guard.GrowFor; SizeFor; AbsorbDamage; StopsHitscan |
| X3 | Rev Shield, Hungry Blades, Spartan, Charge, Shield Dash, Battering Ram | G:304, G:294, G:288, G:915, G:1039, G:907 | SSQ_Guard.RevShield; GrindDamage; Spartan; Charge; HeldTick; Bash |
| X3 | Wall Slam; Ricochet, Meat Grinder, Hunter's Return, Cleaver, Hungry Blades, Buzzsaw Return, Wall Bounces on the disc | S:1731, D:105, D:106, D:107, D:108, D:109, D:110, D:111 | SSQ_Handler.Slam; SSQ_Disc.Claim |
| X3 | Back Plate, Shield Wall and Strike True gate their rows: greyed while not learned | G:260, G:262, G:273, G:275, G:359, G:360, zscript/ssq/score.zs:125, MENUDEF.txt:162, MENUDEF.txt:174, MENUDEF.txt:184 | SSQ_Guard.BackPlate; ShieldWallMs; HitStopTics; SSQ_ScoreService.GetIntUI |
| X3 | Damage is credited to the ShieldSaw (credit.push / credit.pop, the disc's and turned shots' master, the returned bullet's claim) | G:847, G:849, G:1129, G:1131, D:103, G:789, G:830, G:624 | SSQ_Guard.Bash; HeldTick; SSQ_Disc.Claim; SSQ_Guard.BatBack; Deflect; StopsHitscan |
| X4 | RSQ SlowMo: a perfect block sends rsm_pulse for 500 ms when Perfect Block Slow Motion is on (default off) | G:272, G:273, G:456, G:458, CVARINFO.txt:110 | SSQ_Guard.ShieldWallMs; AbsorbDamage |
| X5 | RSQ Score (RS_ScoreService "touch"): moves are reported as they land | zscript/ssq/score.zs:218, zscript/ssq/score.zs:220, S:1734, G:421 | SSQ_Upg.Touch; SSQ_Handler.Slam; SSQ_Guard.AbsorbDamage |
| X5 | SSQ_ScoreService answers locked, blocked, returned, perfect, grind.held, thrown.leg, disc.grinding, returned.from | zscript/ssq/score.zs:134, zscript/ssq/score.zs:144, zscript/ssq/score.zs:145, zscript/ssq/score.zs:146, zscript/ssq/score.zs:148, zscript/ssq/score.zs:164, zscript/ssq/score.zs:165, zscript/ssq/score.zs:173 | SSQ_ScoreService.GetInt; GetObject |
| X6 | RSQ Saber: the brace reads the UBQS_ class name, UBQS_SaberService "saber.lit" and ubqs_size | S:1787, S:1788, S:1789, S:1790 | SSQ_Handler.BraceNow |
| X6 | UBQS_SaberOff is handed the off hand when the shield leaves and displaced nothing; a UBQS_ weapon arriving by itself is not a yield | S:610, S:1272, S:597, S:1042 | SSQ_Handler.HandBack; Unstow; IsFiller; HoldOrYield |
| X7 | RSQ Wheel (wr_RigService "offhand.pick" within 2 tics): the shield is stowed and the picked weapon stays, under either Off Hand Switch setting | S:821, S:1051, S:1055, S:1056, S:1068, S:1069 | SSQ_Handler.WorldTick; WheelPickedOff; YieldToPick |
| X7 | The draw event the Wheel sends is the Draw and Put Back key's | S:1586, S:1589 | SSQ_Handler.NetworkProcess |
| X8 | BD22 VR Reloaded's RSQ_Hands: handed back as the fist, never remembered as the earlier weapon | S:604, S:605, S:1218 | SSQ_Handler.FistBack; Draw |
| X8 | The flick reload obeys rsq_flick when it exists; other layers are forwarded to RSQ_Hands' placement hook | zscript/ssq/offflick.zs:39, zscript/ssq/offflick.zs:41, W:162, W:167 | SSQ_OffFlick.WorldTick; SSQ_ShieldSaw.ModifyBobLayer3D |
| X9 | Brutal Doom: inventory named SK... is lifted for the bash's hit and the blocked melee's pain, and given back if the monster lives | W:223, W:205, W:207, W:232, G:848, G:492 | SSQ_FX.Lift; Hit; Restore; SSQ_Guard.Bash; AbsorbDamage |
| X10 | LegenDoom: a monster with LDLegendaryMonsterToken and not yet transformed adds its refill to the tier health, unless LD_legendarymonsters is 0 | D:642, D:646, D:647, D:649, D:660 | SSQ_Disc.TierHealth |
| X11 | RSQ Miniboss (RSQMB_Ward, RSQMB_Service "bossfor" "ldhealth"): the higher health share | D:653, D:657, D:658 | SSQ_Disc.TierHealth |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | The shield is flagged an off hand weapon that cannot switch hands | W:22, W:23 | SSQ_ShieldSaw Default |
| L2 | Off VR no pose is sent; the held plate needs a fresh pose; a press needs a fresh pose at the mount | S:1837, G:234, S:886, S:895 | SSQ_Handler.SendPose; SSQ_Guard.Plate; SSQ_Handler.OnPress |
| L2 | The key's event and ssq_throw need no pose | S:1589, S:1635 | SSQ_Handler.NetworkProcess |
| L3 | Buttons read for the shield: Use, off attack, off alt attack; main attack and alt attack only hold the chest gesture off | S:621, S:623, S:624, S:625, S:828, W:127, S:355 | SSQ_Handler.SecHeld; WorldTick; SSQ_ShieldSaw.A_SSQ_Held; SSQ_Handler.RecenterGesture |
| L4 | Use is read from the player's command and no key is eaten | S:828, S:876 | SSQ_Handler.WorldTick; InputProcess |
| L5 | A thrown shield stops no bullet, and no plate is up unless it is drawn or stowed | S:1515, G:234, G:242, G:250 | SSQ_Handler.WorldHitscanPreFired; SSQ_Guard.Plate |
| L6 | A player's own shots are never tested | S:1494 | SSQ_Handler.WorldHitscanPreFired |
| L6 | Outside deathmatch the disc, the bash and grind skip players; rings skip players and friendly monsters | D:538, G:1077, D:286, D:287 | SSQ_Disc.SpecialMissileHit; SSQ_Guard.HeldTick; SSQ_Disc.FindTargets |
| L7 | The cut and the embed both exclude a boss | D:581, D:597 | SSQ_Disc.SpecialMissileHit |
| L8 | With Bash Needs Sight on, a body out of sight is skipped | G:1051, G:1104, CVARINFO.txt:95 | SSQ_Guard.HeldTick |
| L9 | Past ssq_home_patience (105 tics) of returning the disc stops clipping | D:432, D:434, CVARINFO.txt:41 | SSQ_Disc.Tick |
| L9 | At 12 seconds of age the disc is ended and the shield is stowed | D:339, D:526, S:1324 | SSQ_Disc.Tick; Done; SSQ_Handler.DiscHome |
| L10 | Entering a map sets the state to stowed, and a shield found in the off hand while not drawn is put away | S:723, S:816 | SSQ_Handler.Give; WorldTick |
| L11 | The chest gesture does not fire with a button held, or with a hand in the mount while the body is near the head | S:355, S:356, S:357 | SSQ_Handler.RecenterGesture |
| L12 | One key section with one key | KEYCONF.txt:10, KEYCONF.txt:11 | KEYCONF |
