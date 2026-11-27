# RSQ Score: where each README claim comes from

Commit read: d66896944 (2026-11-27). A file named without a folder is in `Score/zscript/rsscore/`; `CVARINFO.txt`, `MENUDEF.txt`, `MAPINFO.txt` and `zscript.txt` are in `Score/`; a path that starts with another mod's folder is that mod's. For a bonus row the lines given are, in order of line number: the line its class starts on, its `const` numbers, the line of its name (`DisplayName` / `RowName`) and the first line of its `Evaluate` (or `Ask`, `Mult`, `AfterOthers`); the rule itself is the body of that function. For every other row each line is the line that does the thing. Every line number in this file was looked up in the files at this commit by the text of the line, not typed by hand.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Press the engine's help key (the menu's own note: F1 / Read This!) | MENUDEF.txt:164, MENUDEF.txt:166, glossary.zs:19 | MENUDEF ListMenu ReadThisMenu; RSQSC_GlossaryMenu |
| H2 | Open Options, Radiant Silvergun Options, RSQ Score, Glossary | MENUDEF.txt:150, MENUDEF.txt:159, MENUDEF.txt:161 | MENUDEF RSQSC_Options; ListMenu RSQSC_Glossary |
| H3 | In the Glossary, press Up or Down | glossary.zs:129, glossary.zs:130, glossary.zs:119, glossary.zs:27, glossary.zs:110 | RSQSC_GlossaryMenu.MenuEvent; Move; Scroll |
| H4 | In the Glossary, press Page Up or Page Down | glossary.zs:131, glossary.zs:132, glossary.zs:120 | RSQSC_GlossaryMenu.MenuEvent; Move |
| H5 | In the Glossary, press Left or Right | glossary.zs:133, glossary.zs:134, glossary.zs:34, glossary.zs:102, glossary.zs:86, glossary.zs:101 | RSQSC_GlossaryMenu.MenuEvent; SetTab; Init |
| H6 | In the Glossary, press Enter | glossary.zs:135 | RSQSC_GlossaryMenu.MenuEvent |
| H7 | In the Glossary, press Back | glossary.zs:137 | RSQSC_GlossaryMenu.MenuEvent |
| H8 | Point at a tab and click (it acts when the button is let go) | glossary.zs:158, glossary.zs:160, glossary.zs:163 | RSQSC_GlossaryMenu.MouseEvent |
| H9 | Point at one of the 9 rows shown and click | glossary.zs:166, glossary.zs:169 | RSQSC_GlossaryMenu.MouseEvent |
| H10 | Read the Glossary's page | glossary.zs:237, glossary.zs:35, glossary.zs:273, glossary.zs:274, glossary.zs:294, glossary.zs:296, glossary.zs:297, glossary.zs:301, glossary.zs:233 | RSQSC_GlossaryMenu.Drawer |
| H11 | On the rig, with the Glossary open, set rs_score_glosstest to 1, 2, 3, 4, 5 or 6 in the... | glossary.zs:145, glossary.zs:147, glossary.zs:149, CVARINFO.txt:190 | RSQSC_GlossaryMenu.Ticker |
| H12 | Kill a monster the level counts, a Lost Soul, or a monster that replaces a counted one | handler.zs:103, handler.zs:111, handler.zs:114, event.zs:84, handler.zs:658, tracker.zs:301, hud.zs:200 | RS_ScoreHandler.IsScorable; RS_ScoreEvent.Create; AwardKiller; RS_ScoreTracker.AddScore; RS_ScoreHUD.DrawScoreLine |
| H13 | Kill in a way a row below names | handler.zs:992, handler.zs:646, handler.zs:647, CVARINFO.txt:63, handler.zs:1023, hud.zs:421, CVARINFO.txt:96 | RS_ScoreHandler.PayRows; AwardKiller; AddRowAt; RS_ScoreHUD.DrawBreakdown |
| H14 | Kill a monster that was not on the map by its first tic (raised, or spawned later) | handler.zs:457, handler.zs:458, handler.zs:152, CVARINFO.txt:40 | RS_ScoreHandler.WorldThingDied; CensusAfterFirstTic |
| H15 | Let the level kill a monster with no blow of yours (a crusher, a floor) | handler.zs:411 | RS_ScoreHandler.WorldThingDied |
| H16 | Fill the reward bar | handler.zs:1034, handler.zs:1048, handler.zs:1053, handler.zs:1086, handler.zs:1099, handler.zs:1112, handler.zs:223, handler.zs:226, CVARINFO.txt:25, CVARINFO.txt:10, CVARINFO.txt:11, CVARINFO.txt:12, CVARINFO.txt:13 | RS_ScoreHandler.CheckRewards; RunRewardCue; ComputeThreshold |
| H17 | Start a new game | handler.zs:259, handler.zs:260, handler.zs:1612, CVARINFO.txt:41 | RS_ScoreHandler.StartLives; RS_ScoreNewGame.NewGame |
| H18 | Take a hit that would have killed you while you hold a Score life | handler.zs:1348, handler.zs:1415, tracker.zs:239, handler.zs:1418, handler.zs:1421, handler.zs:1435, handler.zs:1436, revive.zs:84, handler.zs:1437, revive.zs:233, handler.zs:1139, handler.zs:1445, handler.zs:1444, CVARINFO.txt:91 | RS_ScoreHandler.RunExtraLives; RS_ScoreTracker.NoteHit; RS_ScoreReviveFire.Begin; RS_ScoreReviveGuard |
| H19 | Die anyway while holding lives (a telefrag, forced damage) | handler.zs:1378, handler.zs:1381 | RS_ScoreHandler.RunExtraLives |
| H20 | Finish a map and start the next | handler.zs:237, handler.zs:284, handler.zs:295, handler.zs:299, handler.zs:305, CVARINFO.txt:32 | RS_ScoreHandler.PlayerEntered; ScoreReset |
| H21 | Walk over the gold life crate | lifecrate.zs:15, lifecrate.zs:100, lifecrate.zs:105, Miniboss/zscript/rsqmb/tierup.zs:146 | RSQ_ScoreLifeCrate.TryPickup |
| H22 | Shoot a monster in the head: the bullet's puff or the missile lands at or above its kin... | head.zs:300, head.zs:283, head.zs:445, head.zs:463, head.zs:100, head.zs:101, CVARINFO.txt:138, CVARINFO.txt:139, CVARINFO.txt:140 | RS_ScoreHead.VerdictAt; Judge; Outcome; DealPending; Route |
| H23 | Fire a gun | crit.zs:444, crit.zs:427, crit.zs:436, crit.zs:463, crit.zs:183, crit.zs:230, crit.zs:216, crit.zs:392, CVARINFO.txt:175, CVARINFO.txt:176, CVARINFO.txt:177, CVARINFO.txt:178, CVARINFO.txt:179, CVARINFO.txt:180, CVARINFO.txt:182 | RS_ScoreCritHandler.Roll; WorldThingSpawned; RollShot; CritBlow; RS_ScoreCritBrain.Land; RS_ScoreCritController.InitStun; ModifyDamage |
| H24 | Punch, saw or kick (a melee hitscan) | crit.zs:462, crit.zs:552 | RS_ScoreCritHandler.CritBlow; WorldHitscanPreFired |
| H25 | Make a kill that its row calls a big moment | handler.zs:698, handler.zs:699, handler.zs:709, handler.zs:744, handler.zs:740, CVARINFO.txt:68, CVARINFO.txt:69 | RS_ScoreHandler.BigMomentPulse |
| H26 | Look up at the top middle of your view | hud.zs:116, hud.zs:52, hud.zs:368, hud.zs:641, hud.zs:642, CVARINFO.txt:98, CVARINFO.txt:99, CVARINFO.txt:97, CVARINFO.txt:82 | RS_ScoreHUD.RenderOverlay; DrawLives; ColumnOf |
| H27 | Open any menu, or the automap | hud.zs:81, hud.zs:80 | RS_ScoreHUD.RenderOverlay |
| H28 | Kill again before the last kill's time runs out (2 to 10 s, by that monster's health: 2... | bonuses.zs:24, bonuses.zs:26, bonuses.zs:27, bonuses.zs:28, bonuses.zs:29, bonuses.zs:30, bonuses.zs:33, bonuses.zs:35 | RS_Bonus_Spree.Evaluate |
| H29 | Kill without taking damage, once a tenth of the map's monsters (20 to 100 kills) or of ... | bonuses.zs:69, bonuses.zs:71, bonuses.zs:72, bonuses.zs:73, bonuses.zs:76, bonuses.zs:90 | RS_Bonus_Untouchable.Evaluate |
| H30 | Let one monster kill another | bonuses.zs:106, bonuses.zs:108, bonuses.zs:111, bonuses.zs:113 | RS_Bonus_Infighter.Evaluate |
| H31 | Kill after hitting with two different guns inside the last 72 to 144 tics (by the monst... | bonuses.zs:124, bonuses.zs:126, bonuses.zs:127, bonuses.zs:128, bonuses.zs:129, bonuses.zs:130, bonuses.zs:132, bonuses.zs:134 | RS_Bonus_Switcharoo.Evaluate |
| H32 | Kill while off the ground on a jump that reaches more than 64 units above the floor you... | bonuses.zs:156, bonuses.zs:158, bonuses.zs:159, bonuses.zs:160, bonuses.zs:162, bonuses.zs:168 | RS_Bonus_Air.Evaluate |
| H33 | Kill a monster that has no clear line to you from its feet, middle or head | bonuses.zs:178, bonuses.zs:180, bonuses.zs:182, bonuses.zs:184 | RS_Bonus_Curveball.Evaluate |
| H34 | Kill with a blow of damage type SSG | bonuses.zs:201, bonuses.zs:203, bonuses.zs:204, bonuses.zs:207, bonuses.zs:212 | RS_Bonus_Scrapping.Evaluate |
| H35 | Let a monster kill itself | bonuses.zs:234, bonuses.zs:236, bonuses.zs:238, bonuses.zs:240 | RS_Bonus_Darwin.Evaluate |
| H36 | Kill by telefrag | bonuses.zs:248, bonuses.zs:250, bonuses.zs:252, bonuses.zs:255 | RS_Bonus_Telefrag.Evaluate |
| H37 | Kill with a fist, saw or axe: the weapon that struck or the one in the main hand is Fis... | bonuses.zs:271, bonuses.zs:274, bonuses.zs:340 | RS_Bonus_Brawler.Evaluate |
| H38 | Kill while your own health is 25 or less | bonuses.zs:392, bonuses.zs:394, bonuses.zs:395, bonuses.zs:398, bonuses.zs:400 | RS_Bonus_Redline.Evaluate |
| H39 | Land a kill after you have died | bonuses.zs:418, bonuses.zs:420, bonuses.zs:423, bonuses.zs:425 | RS_Bonus_SwanSong.Evaluate |
| H40 | Kill within 64 units, measured edge to edge | bonuses.zs:442, bonuses.zs:444, bonuses.zs:445, bonuses.zs:448, bonuses.zs:450 | RS_Bonus_PointBlank.Evaluate |
| H41 | Make a melee kill that gibs the monster | melee.zs:351, melee.zs:353, melee.zs:355, melee.zs:356 | RS_Bonus_Cleaved.Evaluate |
| H42 | Make melee kills of different kinds within 4 s (saber, disc, bash, grind, blade, fist, ... | melee.zs:466, melee.zs:468, melee.zs:469, melee.zs:470, melee.zs:472, melee.zs:492 | RS_Bonus_Combo.Evaluate |
| H43 | Make a melee kill on a monster at least 2 units off the floor (not a flyer) that your p... | melee.zs:624, melee.zs:626, melee.zs:628, melee.zs:629 | RS_Bonus_Juggle.Evaluate |
| H44 | Punch, kick, push or whip a monster, then let the level or another monster kill it with... | melee.zs:715, melee.zs:717, melee.zs:719, melee.zs:720 | RS_Bonus_RingOut.Evaluate |
| H45 | Kill with a melee blow while the monster is in its Missile or Melee states, or within 1... | melee.zs:808, melee.zs:810, melee.zs:812, melee.zs:813 | RS_Bonus_Counter.Evaluate |
| H46 | Kill with a fist while the monster is in its Pain states | melee.zs:824, melee.zs:826, melee.zs:828, melee.zs:829 | RS_Bonus_Knockdown.Evaluate |
| H47 | Kill a monster that is 24 units or more above its floor (not a flyer, not standing on a... | physical.zs:454, physical.zs:456, physical.zs:457, physical.zs:459, physical.zs:460 | RS_Bonus_Skeet.Evaluate |
| H48 | Kill with a shot that leaves more than 60 degrees away from where your head faces | physical.zs:496, physical.zs:498, physical.zs:499, physical.zs:501, physical.zs:502 | RS_Bonus_NoLook.Evaluate |
| H49 | Kill with a shot while your eyes have no line to the monster and a point within 40 unit... | physical.zs:522, physical.zs:524, physical.zs:525, physical.zs:527, physical.zs:529 | RS_Bonus_BlindFire.Evaluate |
| H50 | Kill with a shot fired by the off hand's trigger alone | physical.zs:581, physical.zs:583, physical.zs:585, physical.zs:586 | RS_Bonus_OffHand.Evaluate |
| H51 | Kill with a shot from one hand's trigger within 1 s of a shot kill from the other hand's | physical.zs:731, physical.zs:733, physical.zs:734, physical.zs:736, physical.zs:742 | RS_Bonus_TwoGuns.Evaluate |
| H52 | Hit one monster with two or more different tools, no more than 3 s between moves, and k... | combo.zs:503, combo.zs:505, combo.zs:506, combo.zs:507, combo.zs:508, combo.zs:518, combo.zs:558 | RS_Bonus_Chain.Evaluate |
| H53 | Bring a new tool into a fight (kills no more than 10 s apart) once three or more are in... | hook.zs:316, hook.zs:321, hook.zs:322, hook.zs:323, hook.zs:324, hook.zs:326, hook.zs:372 | RS_Bonus_Variety.Evaluate |
| H54 | Make three or more kills in a row with one melee mod (fists, saber, ShieldSaw or whip),... | rows.zs:294, rows.zs:296, rows.zs:297, rows.zs:298, rows.zs:300, rows.zs:307 | RS_Row_WeaponMaster.Evaluate |
| H55 | Make a melee kill on a monster of 400 spawn health or more | rows.zs:327, rows.zs:329, rows.zs:330, rows.zs:332, rows.zs:333 | RS_Row_GiantSlayer.Evaluate |
| H56 | Make a melee kill while falling, your feet 34 units or more above the monster's head | rows.zs:343, rows.zs:345, rows.zs:346, rows.zs:348, rows.zs:349 | RS_Row_DeathFromAbove.Evaluate |
| H57 | Kill more than one monster with one blast, bolt or thrown thing inside 1 s, or with one... | rows.zs:396, rows.zs:398, rows.zs:400, rows.zs:427 | RS_Row_MultiKill.Evaluate |
| H58 | Make three or more shot kills while one trigger stays held | rows.zs:937, rows.zs:939, rows.zs:940, rows.zs:942, rows.zs:943 | RS_Row_HoldStreak.Evaluate |
| H59 | Hit a monster twice with a pistol within 10 tics; the second hit kills | rows.zs:964, rows.zs:966, rows.zs:968, rows.zs:969 | RS_Row_DoubleTap.Evaluate |
| H60 | Kill a monster from full health with one round of BrutalRevolver or Revolver | rows.zs:983, rows.zs:985, rows.zs:986, rows.zs:988, rows.zs:989 | RS_Row_HandCannon.Evaluate |
| H61 | Kill with a head shot (the killing blow itself) | rows.zs:1003, rows.zs:1005, rows.zs:1006, rows.zs:1008, rows.zs:1009 | RS_Row_Headshot.Evaluate |
| H62 | Kill with a gun from 768 units or more, the shot within 2 degrees of where your head fa... | rows.zs:1025, rows.zs:1027, rows.zs:1028, rows.zs:1029, rows.zs:1030, rows.zs:1033, rows.zs:1036, rows.zs:1038 | RS_Row_SightsUp.Evaluate |
| H63 | Kill with a rocket's direct hit (the inflictor's class starts Rocket), not its splash | rows.zs:1055, rows.zs:1057, rows.zs:1059, rows.zs:1060 | RS_Row_DirectHit.Evaluate |
| H64 | Kill a monster of 400 spawn health or more with a chainsaw | rows.zs:1091, rows.zs:1093, rows.zs:1095, rows.zs:1096 | RS_Row_RipAndTear.Evaluate |
| H65 | Shoot a monster dead while it is in its attack and before its shot has left (none in th... | rows_panels.zs:181, rows_panels.zs:183, rows_panels.zs:184, rows_panels.zs:186, rows_panels.zs:193 | RS_RowPanel_JusticeShot.Evaluate |
| H66 | Let a monster's shot pass within 48 units of you without hurting you, then kill that mo... | rows_panels.zs:204, rows_panels.zs:206, rows_panels.zs:208, rows_panels.zs:209 | RS_RowPanel_ReadIt.Evaluate |
| H67 | Kill with a blow of damage type Fatality | melee.zs:341, melee.zs:343, melee.zs:345, melee.zs:346 | RS_Bonus_Fatality.Evaluate |
| H68 | Kill with a blow of damage type Kick, HeadKick or Stomp | melee.zs:643, melee.zs:645, melee.zs:647, melee.zs:648 | RS_Bonus_Boot.Evaluate |
| H69 | Swing hard enough that the second or third stacked blow of one swing kills | melee.zs:571, melee.zs:573, melee.zs:574, melee.zs:576, melee.zs:577 | RS_Bonus_HeavySwing.Evaluate |
| H70 | Kill with a nuke while you stand within 768 units and live | rows.zs:1068, rows.zs:1070, rows.zs:1072, rows.zs:1073 | RS_Row_DangerClose.Evaluate |
| H71 | Kill a monster of 1000 spawn health or more with the Unmaker | rows.zs:1082, rows.zs:1084, rows.zs:1086, rows.zs:1087 | RS_Row_Unmade.Evaluate |
| H72 | Kill with a thrown axe (class ThrowedAxe...) | rows.zs:1101, rows.zs:1103, rows.zs:1105, rows.zs:1106 | RS_Row_Tomahawk.Evaluate |
| H73 | Kill with a glove at the end of a run of punches, left and right in turn, each within 1... | melee.zs:838, melee.zs:840, melee.zs:841, melee.zs:843, melee.zs:844 | RS_Bonus_Flurry.Evaluate |
| H74 | Kill with an uppercut | rows.zs:114, rows.zs:116, rows.zs:118, rows.zs:119 | RS_Row_Shoryuken.Evaluate |
| H75 | Kill with a punch below the chest | rows.zs:124, rows.zs:126, rows.zs:128, rows.zs:129 | RS_Row_LiverShot.Evaluate |
| H76 | Kill with a punch in the top fifth of the body | rows.zs:137, rows.zs:139, rows.zs:141, rows.zs:142 | RS_Row_GlassJaw.Evaluate |
| H77 | Jab, jab, hook inside 1 s; the hook kills | rows.zs:146, rows.zs:148, rows.zs:150, rows.zs:151 | RS_Row_Textbook.Evaluate |
| H78 | Jab, hook, uppercut inside 1 s; the uppercut kills | rows.zs:155, rows.zs:157, rows.zs:159, rows.zs:160 | RS_Row_TripleThreat.Evaluate |
| H79 | Kill with the third or later of alternating hooks | rows.zs:166, rows.zs:168, rows.zs:169, rows.zs:171, rows.zs:172 | RS_Row_DempseyRoll.Evaluate |
| H80 | Punch dead a monster your uppercut launched, while it is in the air | rows.zs:181, rows.zs:183, rows.zs:185, rows.zs:186 | RS_Row_AirCombo.Evaluate |
| H81 | Kill with the Clear Out | rows.zs:195, rows.zs:197, rows.zs:199, rows.zs:200 | RS_Row_Bouncer.Evaluate |
| H82 | Kill with the Guard's release | rows.zs:204, rows.zs:206, rows.zs:208, rows.zs:209 | RS_Row_Release.Evaluate |
| H83 | Throw a monster out of the Headlock; its own landing kills it | rows.zs:213, rows.zs:215, rows.zs:217, rows.zs:218 | RS_Row_Toss.Evaluate |
| H84 | Kill with the Headlock Slam | rows.zs:226, rows.zs:228, rows.zs:230, rows.zs:231 | RS_Row_Piledriver.Evaluate |
| H85 | Kill with the Headlock Uppercut | rows.zs:236, rows.zs:238, rows.zs:240, rows.zs:241 | RS_Row_CutLoose.Evaluate |
| H86 | Kill with the gun-butt shove | rows.zs:245, rows.zs:247, rows.zs:249, rows.zs:250 | RS_Row_ButtStroke.Evaluate |
| H87 | Knock a monster's missile aside by hand (RSQ Melee answers `returned.by` 3); it kills s... | rows_melee2.zs:45, rows_melee2.zs:47, rows_melee2.zs:49, rows_melee2.zs:50 | RS_RowM2_Swatted.Evaluate |
| H88 | Soak a monster's blow on your Guard, then kill it within 3 s | rows_melee2.zs:56, rows_melee2.zs:58, rows_melee2.zs:59, rows_melee2.zs:60, rows_melee2.zs:62, rows_melee2.zs:63 | RS_RowM2_RopeADope.Evaluate |
| H89 | Kill two or more with one Ground Pound | rows_melee2.zs:74, rows_melee2.zs:76, rows_melee2.zs:77, rows_melee2.zs:79, rows_melee2.zs:80 | RS_RowM2_Seismic.Evaluate |
| H90 | Kill two or more with one Clear Out | rows_melee2.zs:86, rows_melee2.zs:88, rows_melee2.zs:89, rows_melee2.zs:91, rows_melee2.zs:92 | RS_RowM2_OutOfMyWay.Evaluate |
| H91 | Kill two or more with one Guard release | rows_melee2.zs:99, rows_melee2.zs:101, rows_melee2.zs:102, rows_melee2.zs:104, rows_melee2.zs:105 | RS_RowM2_FullRelease.Evaluate |
| H92 | Hold a monster in the Headlock while something else kills it | rows_melee2.zs:113, rows_melee2.zs:115, rows_melee2.zs:117, rows_melee2.zs:118 | RS_RowM2_MeatShield.Evaluate |
| H93 | Kill another monster while your off hand holds one as a Human Shield | rows_melee2.zs:128, rows_melee2.zs:130, rows_melee2.zs:132, rows_melee2.zs:133 | RS_RowM2_HumanShield.Evaluate |
| H94 | Kick a barrel with an uppercut; its blast kills | rows_melee2.zs:143, rows_melee2.zs:145, rows_melee2.zs:147, rows_melee2.zs:148 | RS_RowM2_FieldGoal.Evaluate |
| H95 | Land a Heavy Hands punch, then kill that monster within 1 s | rows_melee2.zs:158, rows_melee2.zs:160, rows_melee2.zs:161, rows_melee2.zs:163, rows_melee2.zs:164 | RS_RowM2_SeeingStars.Evaluate |
| H96 | Launch a monster with an uppercut so that it comes down on another and kills it | rows_melee2.zs:181, rows_melee2.zs:183, rows_melee2.zs:185, rows_melee2.zs:186 | RS_RowM2_Meteor.Evaluate |
| H97 | Kill with a Star Punch | rows_melee2.zs:190, rows_melee2.zs:192, rows_melee2.zs:194, rows_melee2.zs:195 | RS_RowM2_StarPunch.Evaluate |
| H98 | Knock a monster down with the Rifle Butt shove, then kill it inside the chain's 3 s | rows_melee2.zs:201, rows_melee2.zs:203, rows_melee2.zs:205, rows_melee2.zs:206 | RS_RowM2_DownForTheCount.Evaluate |
| H99 | Kill with a glove while Slappers Only is on | rows_melee2.zs:210, rows_melee2.zs:212, rows_melee2.zs:214, rows_melee2.zs:215 | RS_RowM2_BareKnuckle.Evaluate |
| H100 | Kill with a shotgun in your F.E.A.R. window a monster you did not shove | rows_melee2.zs:226, rows_melee2.zs:228, rows_melee2.zs:230, rows_melee2.zs:231 | RS_RowM2_RedMist.Evaluate |
| H101 | Knock a monster into a wall so that the wall kills it (a punch, or the shield's slam) | rows.zs:1417, rows.zs:1419, rows.zs:1421, rows.zs:1422 | RS_Row_WallSplat.Evaluate |
| H102 | Throw a monster out of the Headlock so that it strikes and kills another | hook.zs:140, hook.zs:142, hook.zs:143, hook.zs:144, hook.zs:145, hook.zs:147, hook.zs:148 | RS_Bonus_Bowling.Evaluate |
| H103 | Choke a monster to death with the Force grip, or with the Headlock's Chokehold | melee.zs:589, melee.zs:591, melee.zs:593, melee.zs:594 | RS_Bonus_Choked.Evaluate |
| H104 | Fling a body out of the Force grip so that it dies hitting something | melee.zs:606, melee.zs:608, melee.zs:610, melee.zs:611 | RS_Bonus_Slammed.Evaluate |
| H105 | Force pull a monster, then kill it with a melee blow within 2 s | melee.zs:656, melee.zs:658, melee.zs:660, melee.zs:661 | RS_Bonus_PulledIn.Evaluate |
| H106 | Kill with a saber cut or throw while a saber is lit in each hand | melee.zs:672, melee.zs:674, melee.zs:676, melee.zs:677 | RS_Bonus_TwinBlades.Evaluate |
| H107 | Kill with the Force jump's landing, or with RSQ Melee's two-fist pound | melee.zs:729, melee.zs:731, melee.zs:733, melee.zs:741 | RS_Bonus_GroundPound.Evaluate |
| H108 | Kill with a lunging stab | rows.zs:453, rows.zs:455, rows.zs:457, rows.zs:458 | RS_Row_Lunge.Evaluate |
| H109 | Kill by drawing the blade out of an impaled monster | rows.zs:462, rows.zs:464, rows.zs:466, rows.zs:467 | RS_Row_Impaled.Evaluate |
| H110 | Turn a shot with crossed blades; it kills | rows.zs:472, rows.zs:474, rows.zs:476, rows.zs:477 | RS_Row_BackOff.Evaluate |
| H111 | Throw both sabers; each kills within 1 s of the other | rows.zs:482, rows.zs:484, rows.zs:485, rows.zs:487, rows.zs:488 | RS_Row_DoubleThrow.Evaluate |
| H112 | Kill with a stab | rows.zs:1364, rows.zs:1366, rows.zs:1368, rows.zs:1369 | RS_Row_RunThrough.Evaluate |
| H113 | Kill with a blow the ledger knows as saber.spin | rows.zs:1373, rows.zs:1375, rows.zs:1377, rows.zs:1378 | RS_Row_Saberstaff.Evaluate |
| H114 | Kill with Force Lightning | rows.zs:1382, rows.zs:1384, rows.zs:1386, rows.zs:1387 | RS_Row_UnlimitedPower.Evaluate |
| H115 | Kill a monster whose chain carries the tag "clash" | rows.zs:1391, rows.zs:1393, rows.zs:1395, rows.zs:1396 | RS_Row_ClashBreak.Evaluate |
| H116 | Knock a bolt back into RSQ Saber's training remote | awards.zs:31, awards.zs:34 | RS_Award_Deflect.Evaluate |
| H117 | Knock RSQ Saber's training remote out of the air | awards.zs:37, awards.zs:40 | RS_Award_RemoteDown.Evaluate |
| H118 | Kill with the thrown ShieldSaw disc or a thrown saber | melee.zs:366, melee.zs:368, melee.zs:369, melee.zs:370, melee.zs:372, melee.zs:380 | RS_Bonus_Hurled.Evaluate |
| H119 | Kill with the shield in the off hand: its bash, or its grind | melee.zs:397, melee.zs:399, melee.zs:400, melee.zs:402, melee.zs:403 | RS_Bonus_ShieldWork.Evaluate |
| H120 | Block a monster's attack with the shield or the saber, then kill it within 3 s | melee.zs:413, melee.zs:415, melee.zs:416, melee.zs:418, melee.zs:419 | RS_Bonus_Riposte.Evaluate |
| H121 | Make a perfect block, then kill that monster within 3 s | melee.zs:429, melee.zs:431, melee.zs:433, melee.zs:434 | RS_Bonus_PerfectRiposte.Evaluate |
| H122 | Kill with a shot you sent back | melee.zs:445, melee.zs:447, melee.zs:448, melee.zs:449, melee.zs:450, melee.zs:452, melee.zs:453 | RS_Bonus_ReturnToSender.Evaluate |
| H123 | Kill a monster with its own shot, sent back | melee.zs:508, melee.zs:510, melee.zs:512, melee.zs:513 | RS_Bonus_PoeticJustice.Evaluate |
| H124 | Kill with shots sent back one after another, each within 3 s | melee.zs:687, melee.zs:689, melee.zs:690, melee.zs:692, melee.zs:698 | RS_Bonus_Rally.Evaluate |
| H125 | Kill with a shot sent back a monster that did not fire it | rows.zs:378, rows.zs:380, rows.zs:382, rows.zs:383 | RS_Row_Misdirection.Evaluate |
| H126 | Kill on a throw's way home after the same throw killed on its way out | melee.zs:531, melee.zs:533, melee.zs:535, melee.zs:536 | RS_Bonus_Boomerang.Evaluate |
| H127 | Kill on a throw's way home when it did not kill on its way out | rows.zs:525, rows.zs:527, rows.zs:529, rows.zs:530 | RS_Row_Homecoming.Evaluate |
| H128 | Kill while your thrown saber or disc is still in flight (and is not what killed) | rows.zs:358, rows.zs:360, rows.zs:362, rows.zs:363 | RS_Row_Juggler.Evaluate |
| H129 | Stick the disc in a monster and let it grind it dead | melee.zs:554, melee.zs:556, melee.zs:558, melee.zs:559 | RS_Bonus_GroundDown.Evaluate |
| H130 | Throw the disc at two or more locks; it kills the last one standing | melee.zs:753, melee.zs:755, melee.zs:757, melee.zs:758 | RS_Bonus_CleanSweep.Evaluate |
| H131 | Kill a monster the disc locked after the throw (at a wall) | melee.zs:767, melee.zs:769, melee.zs:771, melee.zs:772 | RS_Bonus_BankShot.Evaluate |
| H132 | Kill while the shield in your off hand blocked another monster within 2048 units in the... | melee.zs:781, melee.zs:783, melee.zs:784, melee.zs:785, melee.zs:787, melee.zs:788 | RS_Bonus_ShieldWall.Evaluate |
| H133 | Kill while the shield blocked two or more other monsters in the last 2 s | rows.zs:549, rows.zs:551, rows.zs:552, rows.zs:553, rows.zs:554, rows.zs:555, rows.zs:557, rows.zs:558 | RS_Row_HoldTheLine.Evaluate |
| H134 | Kill with the bash that ends a Shield Dash | rows.zs:506, rows.zs:508, rows.zs:510, rows.zs:511 | RS_Row_ShieldDash.Evaluate |
| H135 | Grind dead a monster that was clawing your revving shield | rows.zs:515, rows.zs:517, rows.zs:519, rows.zs:520 | RS_Row_BitOffMore.Evaluate |
| H136 | Let the shield on your back block a monster, then kill it inside the chain's 3 s | rows.zs:540, rows.zs:542, rows.zs:544, rows.zs:545 | RS_Row_EyesInTheBack.Evaluate |
| H137 | Gib a monster with the disc on a kill tagged cleave.saw | rows.zs:577, rows.zs:579, rows.zs:581, rows.zs:582 | RS_Row_Cleaver.Evaluate |
| H138 | Grind a monster dead after 52 tics (1.5 s) or more of grinding | rows.zs:1401, rows.zs:1403, rows.zs:1404, rows.zs:1406, rows.zs:1407 | RS_Row_Buzzsaw.Evaluate |
| H139 | Kill with the whip (a blow of damage type Whip from you) | hook.zs:293, hook.zs:295, hook.zs:296, hook.zs:297, hook.zs:298, hook.zs:300, hook.zs:301 | RS_Bonus_Lashed.Evaluate |
| H140 | Kill with a thing you threw with Distance Grab | physical.zs:372, physical.zs:374, physical.zs:375, physical.zs:376, physical.zs:377, physical.zs:379, physical.zs:380 | RS_Bonus_Thrown.Evaluate |
| H141 | Kill with the blast of a barrel your throw set off | physical.zs:394, physical.zs:396, physical.zs:397, physical.zs:398, physical.zs:399, physical.zs:401, physical.zs:414 | RS_Bonus_PowderKeg.Evaluate |
| H142 | Catch a thrown thing back out of the air, throw it again, and kill with it | physical.zs:435, physical.zs:437, physical.zs:438, physical.zs:439, physical.zs:441, physical.zs:442 | RS_Bonus_AirCatch.Evaluate |
| H143 | Kill with a shot while a hand carries something with Distance Grab | physical.zs:597, physical.zs:599, physical.zs:601, physical.zs:602 | RS_Bonus_FullHands.Evaluate |
| H144 | Kill with a corpse you threw | physical.zs:616, physical.zs:618, physical.zs:620, physical.zs:621 | RS_Bonus_BodyBlow.Evaluate |
| H145 | Kill with a thrown weapon that a dying monster dropped | physical.zs:632, physical.zs:634, physical.zs:636, physical.zs:637 | RS_Bonus_HandMeDown.Evaluate |
| H146 | Kill with a thrown thing of 100 kg or more | rows.zs:715, rows.zs:717, rows.zs:719, rows.zs:720 | RS_Row_HeavyThrow.Evaluate |
| H147 | Swing a thing you hold into a monster and kill it | rows.zs:1431, rows.zs:1433, rows.zs:1434, rows.zs:1436, rows.zs:1437 | RS_Row_Clubbed.Evaluate |
| H148 | Kill with a gun you threw | rows.zs:728, rows.zs:730, rows.zs:731, rows.zs:733, rows.zs:734 | RS_Row_Throwaway.Evaluate |
| H149 | Draw a gun from a holster and kill with a shot of it within 42 tics | physical.zs:471, physical.zs:473, physical.zs:474, physical.zs:477, physical.zs:478 | RS_Bonus_QuickDraw.Evaluate |
| H150 | Kill, draw a different gun from a holster within 3 s, and kill with it within 3 s of th... | physical.zs:649, physical.zs:651, physical.zs:652, physical.zs:654, physical.zs:655 | RS_Bonus_HotSwap.Evaluate |
| H151 | Draw the saber from a holster and kill with a saber blow within 42 tics | rows.zs:742, rows.zs:744, rows.zs:746, rows.zs:747 | RS_Row_Iaido.Evaluate |
| H152 | Draw a grenade from the rig and kill with a grenade within 3 s | rows.zs:763, rows.zs:765, rows.zs:766, rows.zs:768, rows.zs:769 | RS_Row_PinPulled.Evaluate |
| H153 | Kill with three different guns, each just drawn from a holster, inside 6 s | rows.zs:785, rows.zs:787, rows.zs:788, rows.zs:790, rows.zs:806 | RS_Row_Armory.Evaluate |
| H154 | Kill with a grenade cooked 1 s or more in the hand | rows.zs:828, rows.zs:830, rows.zs:831, rows.zs:832, rows.zs:834, rows.zs:835 | RS_Row_Cooked.Evaluate |
| H155 | Kill with a grenade that goes off 24 units or more above the floor (not in your hand) | rows.zs:845, rows.zs:847, rows.zs:848, rows.zs:850, rows.zs:851 | RS_Row_Airburst.Evaluate |
| H156 | Stick a Sticky grenade on a monster; its blast kills that monster | rows.zs:860, rows.zs:862, rows.zs:864, rows.zs:865 | RS_Row_Tagged.Evaluate |
| H157 | Kill with a grenade that goes off in your hand | rows.zs:869, rows.zs:871, rows.zs:872, rows.zs:874, rows.zs:875 | RS_Row_HoldMyBeer.Evaluate |
| H158 | Kill with a Cluster bomblet | rows.zs:884, rows.zs:886, rows.zs:888, rows.zs:889 | RS_Row_ClusterBomb.Evaluate |
| H159 | Turn a monster with an Infight or Charm grenade; it kills another | rows.zs:903, rows.zs:905, rows.zs:907, rows.zs:908 | RS_Row_CivilWar.Evaluate |
| H160 | Kill a monster your Flash or Smoke grenade touched inside the chain's 3 s | rows.zs:912, rows.zs:914, rows.zs:916, rows.zs:917 | RS_Row_Blindside.Evaluate |
| H161 | Kill with your Incendiary's fire | rows.zs:925, rows.zs:927, rows.zs:929, rows.zs:930 | RS_Row_Barbecue.Evaluate |
| H162 | Kill with your own grenade, shot in the air | rows.zs:1446, rows.zs:1448, rows.zs:1450, rows.zs:1451 | RS_Row_TrapShot.Evaluate |
| H163 | Kill with a grenade whose pin you pulled with your teeth | rows.zs:1456, rows.zs:1458, rows.zs:1460, rows.zs:1461 | RS_Row_Teeth.Evaluate |
| H164 | Kill with an Impact grenade's burst | rows.zs:1465, rows.zs:1467, rows.zs:1469, rows.zs:1470 | RS_Row_Contact.Evaluate |
| H165 | Kill while RSQ SlowMo has the world slowed | physical.zs:698, physical.zs:700, physical.zs:701, physical.zs:703, physical.zs:704 | RS_Bonus_BulletTime.Evaluate |
| H166 | Kill while the world speeds back up at the end of a slow motion | rows.zs:1492, rows.zs:1494, rows.zs:1496, rows.zs:1497 | RS_Row_LastGrain.Evaluate |
| H167 | (RSQ SlowMo's award "Revenge") | awards.zs:63, awards.zs:66 | RS_Award_Revenge.Evaluate |
| H168 | (another mod's award "Revive") | awards.zs:69, awards.zs:72 | RS_Award_Revive.Evaluate |
| H169 | Kill the Boss you called in | awards.zs:54 | RS_Award_Miniboss.Evaluate |
| H170 | (RSQ Miniboss's award "Finisher") | awards.zs:77, awards.zs:80 | RS_Award_Finisher.Evaluate |
| H171 | (another mod's award "Thrall Slow Kill") | awards.zs:48, awards.zs:51 | RS_Award_ThrallSlowKill.Evaluate |
| H172 | Score anything while RSQ Miniboss's Rank is above 0 | awards.zs:84, awards.zs:87 | RS_Award_Rank.Evaluate |
| H173 | Kill thralls one after another while RSQ Miniboss answers "window" above 0 | rows.zs:1312, rows.zs:1315, rows.zs:1323 | RS_Row_ChainGang.Evaluate |
| H174 | Kill the Boss while RSQ Miniboss answers "enraged" 1 | rows.zs:1343, rows.zs:1345, rows.zs:1347, rows.zs:1348 | RS_Row_RageQuit.Evaluate |
| H175 | Kill a monster that carries RSQ Miniboss's RSQMB_Rage | rows.zs:1353, rows.zs:1355, rows.zs:1357, rows.zs:1358 | RS_Row_RiotControl.Evaluate |
| H176 | Kill a Dark Red champion | boost.zs:217 | RS_Bonus_ChampDarkRed.Evaluate |
| H177 | Kill a Red champion | boost.zs:218 | RS_Bonus_ChampRed.Evaluate |
| H178 | Kill an Orange champion | boost.zs:219 | RS_Bonus_ChampOrange.Evaluate |
| H179 | Kill a Yellow champion | boost.zs:220 | RS_Bonus_ChampYellow.Evaluate |
| H180 | Kill a Dark Green champion | boost.zs:221 | RS_Bonus_ChampDarkGreen.Evaluate |
| H181 | Kill a Green champion | boost.zs:222 | RS_Bonus_ChampGreen.Evaluate |
| H182 | Kill a Cyan champion | boost.zs:223 | RS_Bonus_ChampCyan.Evaluate |
| H183 | Kill a Blue champion | boost.zs:224 | RS_Bonus_ChampBlue.Evaluate |
| H184 | Kill an Indigo champion | boost.zs:225 | RS_Bonus_ChampIndigo.Evaluate |
| H185 | Kill a Violet champion | boost.zs:226 | RS_Bonus_ChampViolet.Evaluate |
| H186 | Kill a Pink champion | boost.zs:227 | RS_Bonus_ChampPink.Evaluate |
| H187 | Kill a Black champion | boost.zs:228 | RS_Bonus_ChampBlack.Evaluate |
| H188 | Kill a Grey champion | boost.zs:229 | RS_Bonus_ChampGrey.Evaluate |
| H189 | Kill a White champion | boost.zs:230 | RS_Bonus_ChampWhite.Evaluate |
| H190 | Kill a Bronze champion | boost.zs:232 | RS_Bonus_ChampBronze.Evaluate |
| H191 | Kill a Silver champion | boost.zs:233 | RS_Bonus_ChampSilver.Evaluate |
| H192 | Kill a Gold champion | boost.zs:234 | RS_Bonus_ChampGold.Evaluate |
| H193 | Kill a Titan champion | boost.zs:250, boost.zs:253, boost.zs:254 | RS_Bonus_MutTitan.Evaluate |
| H194 | Kill an Undying champion after its heart | boost.zs:259, boost.zs:261, boost.zs:262 | RS_Bonus_MutUndying.Evaluate |
| H195 | Kill a Ghost champion | boost.zs:271, boost.zs:273 | RS_Bonus_MutGhost.Evaluate |
| H196 | Kill a Balloon champion | boost.zs:279, boost.zs:281 | RS_Bonus_MutBalloon.Evaluate |
| H197 | Kill a champion with two colours | boost.zs:286, boost.zs:288 | RS_Bonus_MutHybrid.Evaluate |
| H198 | Kill a Bronze champion with a melee blow | rows.zs:1112, rows.zs:1114, rows.zs:1116, rows.zs:1117 | RS_Row_ImmovableObject.Evaluate |
| H199 | Kill a Balloon champion with anything but a shot | rows.zs:1121, rows.zs:1123, rows.zs:1125, rows.zs:1126 | RS_Row_Pop.Evaluate |
| H200 | Gib a champion | rows.zs:1134, rows.zs:1136, rows.zs:1138, rows.zs:1139 | RS_Row_Pinata.Evaluate |
| H201 | Kill champions one after another, each within 5 s | rows.zs:1143, rows.zs:1145, rows.zs:1146, rows.zs:1147, rows.zs:1149, rows.zs:1155 | RS_Row_ChampionStreak.Evaluate |
| H202 | Kill an Orange champion with a melee blow or within 64 units | rows.zs:1166, rows.zs:1168, rows.zs:1170, rows.zs:1171 | RS_Row_TooClose.Evaluate |
| H203 | Kill a Black champion in one blow from full health | rows.zs:1179, rows.zs:1181, rows.zs:1183, rows.zs:1184 | RS_Row_GlassCannon.Evaluate |
| H204 | Kill a monster that carries a Gold champion's token and is no champion itself | rows.zs:1188, rows.zs:1190, rows.zs:1192, rows.zs:1193 | RS_Row_FoolsGold.Evaluate |
| H205 | Kill an Undying champion within 2 s of its heart | rows.zs:1197, rows.zs:1199, rows.zs:1200, rows.zs:1202, rows.zs:1203 | RS_Row_Heartbreaker.Evaluate |
| H206 | Kill a champion with a blow of type Fatality | rows.zs:1213, rows.zs:1215, rows.zs:1217, rows.zs:1218 | RS_Row_ChampionFatality.Evaluate |
| H207 | Kill champions of 5, 10 and all 14 colours in one map | rows.zs:1222, rows.zs:1225, rows.zs:1234 | RS_Row_Rainbow.Evaluate |
| H208 | Kill a LegenDoom legendary after it has risen | boost.zs:296, boost.zs:299, boost.zs:300 | RS_Bonus_Legendary.Evaluate |
| H209 | Kill a legendary before it rises | boost.zs:311, boost.zs:314, boost.zs:315 | RS_Bonus_LegendDenied.Evaluate |
| H210 | Kill a risen legendary whose champion powers are on | boost.zs:326, boost.zs:329, boost.zs:330 | RS_Bonus_LegendChampion.Evaluate |
| H211 | Kill a legendary in one blow from 3 x its spawn health | rows.zs:1260, rows.zs:1262, rows.zs:1264, rows.zs:1265 | RS_Row_OneTapLegend.Evaluate |
| H212 | Kill a risen legendary within 2 s of the first blow Score sees on it after it rose | rows.zs:1275, rows.zs:1277, rows.zs:1278, rows.zs:1280, rows.zs:1281 | RS_Row_StrikeWhileItRises.Evaluate |
| H213 | Kill two legendaries within 10 s | rows.zs:1291, rows.zs:1293, rows.zs:1294, rows.zs:1296, rows.zs:1297 | RS_Row_LegendSlayer.Evaluate |
| H214 | Kill a Green tier monster | rows_roster.zs:160 | RS_RR_TierGreen.Evaluate |
| H215 | Kill a Blue tier monster | rows_roster.zs:161 | RS_RR_TierBlue.Evaluate |
| H216 | Kill a Cyan tier monster | rows_roster.zs:162 | RS_RR_TierCyan.Evaluate |
| H217 | Kill a Purple tier monster | rows_roster.zs:163 | RS_RR_TierPurple.Evaluate |
| H218 | Kill a Yellow tier monster | rows_roster.zs:164 | RS_RR_TierYellow.Evaluate |
| H219 | Kill a FireBlu tier monster | rows_roster.zs:165 | RS_RR_TierFireBlu.Evaluate |
| H220 | Kill an Abyss tier monster | rows_roster.zs:166 | RS_RR_TierAbyss.Evaluate |
| H221 | Kill a Brown tier monster | rows_roster.zs:167 | RS_RR_TierBrown.Evaluate |
| H222 | Kill a Gray tier monster | rows_roster.zs:168 | RS_RR_TierGray.Evaluate |
| H223 | Kill a Red tier monster | rows_roster.zs:169 | RS_RR_TierRed.Evaluate |
| H224 | Kill a Black Boss | rows_roster.zs:171, rows_roster.zs:175, rows_roster.zs:176 | RS_RR_TierBlack.Evaluate |
| H225 | Kill a White Boss | rows_roster.zs:179, rows_roster.zs:183, rows_roster.zs:184 | RS_RR_TierWhite.Evaluate |
| H226 | Kill an EX boss | rows_roster.zs:189, rows_roster.zs:193, rows_roster.zs:194 | RS_RR_EXBoss.Evaluate |
| H227 | Kill a monster whose spawn roll was 1 in 20 or rarer | rows_roster.zs:208, rows_roster.zs:210, rows_roster.zs:211, rows_roster.zs:214, rows_roster.zs:215 | RS_RR_Rarity.Evaluate |
| H228 | Kill all 13 tiers yourself in one map | rows_roster.zs:227, rows_roster.zs:229, rows_roster.zs:230, rows_roster.zs:233, rows_roster.zs:235 | RS_RR_FullSpectrum.Evaluate |
| H229 | Kill the same tier (not Common) three or more times in a row | rows_roster.zs:259, rows_roster.zs:261, rows_roster.zs:262, rows_roster.zs:265, rows_roster.zs:266 | RS_RR_ColourChain.Evaluate |
| H230 | Kill a monster while it flashes, about to move up a tier | rows_roster.zs:290, rows_roster.zs:292, rows_roster.zs:293, rows_roster.zs:296, rows_roster.zs:297 | RS_RR_KeepTheChange.Evaluate |
| H231 | Kill a monster within 3 s of it moving up a tier | rows_roster.zs:309, rows_roster.zs:311, rows_roster.zs:312, rows_roster.zs:315, rows_roster.zs:316 | RS_RR_FreshPaint.Evaluate |
| H232 | Let a Common, Green or Blue monster kill a Black Boss, a White Boss or an EX | rows_roster.zs:328, rows_roster.zs:330, rows_roster.zs:333, rows_roster.zs:334 | RS_RR_Upset.Evaluate |
| H233 | Kill a Black Boss, a White Boss or an EX with a pistol, a punch, a glove, a kick or the... | rows_roster.zs:345, rows_roster.zs:347, rows_roster.zs:350, rows_roster.zs:351 | RS_RR_TierSlayer.Evaluate |
| H234 | Kill while a latched rope holds you off the ground | hook.zs:239, hook.zs:241, hook.zs:242, hook.zs:243, hook.zs:245, hook.zs:247, hook.zs:250 | RS_Bonus_Swinging.Evaluate |
| H235 | Let go of a swing at 6 units a tic or more, then kill within 3 s in the air or 1 s afte... | hook.zs:266, hook.zs:268, hook.zs:269, hook.zs:270, hook.zs:271, hook.zs:273, hook.zs:274 | RS_Bonus_Dismount.Evaluate |
| H236 | Kill on the second or later of whip swings latched one after another | rows.zs:1475, rows.zs:1477, rows.zs:1478, rows.zs:1480, rows.zs:1481 | RS_Row_ChainSwing.Evaluate |
| H237 | Swing a monster on the whip into another; the smash kills it | rows.zs:588, rows.zs:590, rows.zs:592, rows.zs:593 | RS_Row_WreckingBall.Evaluate |
| H238 | Swing in on the rope; your arrival kills | rows.zs:601, rows.zs:603, rows.zs:605, rows.zs:606 | RS_Row_Tarzan.Evaluate |
| H239 | Stun a monster with a whip crack (tag crack.stun), then kill it with another tool | rows.zs:612, rows.zs:614, rows.zs:616, rows.zs:617 | RS_Row_StunLock.Evaluate |
| H240 | Yank a heavy monster with the whip (tag yank.heavy); it dies within 2 s | rows.zs:625, rows.zs:627, rows.zs:628, rows.zs:630, rows.zs:631 | RS_Row_HeavyHaul.Evaluate |
| H241 | Kill with a marked whip crack (tag crack.marked) from 204 units (6 m) or more | rows.zs:640, rows.zs:642, rows.zs:643, rows.zs:645, rows.zs:646 | RS_Row_SnapKill.Evaluate |
| H242 | Hook a monster, then kill it with a melee blow within 2 s | hook.zs:85, hook.zs:87, hook.zs:88, hook.zs:89, hook.zs:90, hook.zs:91, hook.zs:93, hook.zs:106 | RS_Bonus_ReeledIn.Evaluate |
| H243 | Hook a monster, send it flying, hook it again, then kill it | hook.zs:121, hook.zs:123, hook.zs:124, hook.zs:125, hook.zs:126, hook.zs:128, hook.zs:129 | RS_Bonus_PingPong.Evaluate |
| H244 | Let the hook's throw itself kill the monster | hook.zs:165, hook.zs:167, hook.zs:169, hook.zs:170 | RS_Bonus_HardLanding.Evaluate |
| H245 | Kill a monster while your hook is throwing it | hook.zs:179, hook.zs:181, hook.zs:183, hook.zs:184 | RS_Bonus_FlyBall.Evaluate |
| H246 | Kill with the blast of a barrel your hook bit | rows.zs:652, rows.zs:654, rows.zs:655, rows.zs:656, rows.zs:657, rows.zs:659, rows.zs:665 | RS_Row_HookedKeg.Evaluate |
| H247 | Reel yourself to a monster too heavy to pull, then kill it in melee within 2 s | rows.zs:677, rows.zs:679, rows.zs:680, rows.zs:682, rows.zs:683 | RS_Row_BoardingParty.Evaluate |
| H248 | Kill with a blow the ledger knows as hook.zip | rows.zs:694, rows.zs:696, rows.zs:698, rows.zs:699 | RS_Row_ZipKick.Evaluate |
| H249 | Kill with a fist on a blow tagged scorpion | rows.zs:703, rows.zs:705, rows.zs:707, rows.zs:708 | RS_Row_Scorpion.Evaluate |
| H250 | (another mod's award) | awards.zs:24, awards.zs:27 | RS_Award_IndianaJones.Evaluate |
| H251 | Kill with a fist on a blow tagged fist.finisher | rows.zs:254, rows.zs:256, rows.zs:258, rows.zs:259 | RS_Row_KO.Evaluate |
| H252 | Kill on a blow tagged shatter | rows.zs:264, rows.zs:266, rows.zs:268, rows.zs:269 | RS_Row_Shatter.Evaluate |
| H253 | Kill on a blow tagged arc | rows.zs:273, rows.zs:275, rows.zs:277, rows.zs:278 | RS_Row_LiveWire.Evaluate |
| H254 | Kill on a blow tagged fist.explosive | rows.zs:282, rows.zs:284, rows.zs:286, rows.zs:287 | RS_Row_BlastRadius.Evaluate |
| H255 | Kill on a blow tagged shatter a monster your Freeze grenade touched | rows.zs:893, rows.zs:895, rows.zs:897, rows.zs:898 | RS_Row_IceBreaker.Evaluate |
| H256 | Kill a monster of 400 spawn health or more, or make a big-moment kill | handler.zs:746, handler.zs:754, handler.zs:755, handler.zs:756, handler.zs:723, CVARINFO.txt:77 | RS_ScoreHandler.BigMomentPulse; HitStopMs |
| H257 | In VR, look at your off hand | wrist.zs:19, wrist.zs:76, wrist.zs:83, wrist.zs:81, CVARINFO.txt:105 | RS_ScoreWrist.Show |
| H258 | Fill the reward bar | handler.zs:1060, handler.zs:1045, handler.zs:1046, handler.zs:1290, CVARINFO.txt:47 | RS_ScoreHandler.CheckRewards; RunAmmoRegen |
| H259 | Fill the reward bar | handler.zs:1032, hud.zs:260 | RS_ScoreHandler.CheckRewards; RS_ScoreHUD.DrawBar |
| H260 | Finish a map and start the next | handler.zs:290, handler.zs:292, handler.zs:293, handler.zs:71 | RS_ScoreHandler.ScoreReset; WorldLoaded |
| H261 | Take a killing hit while you hold a life | revive.zs:85, handler.zs:1580 | RS_ScoreReviveFire.Begin; RS_ScoreHandler.ReviveFire |
| H262 | Fill the reward bar, or take a killing hit while you hold a life | handler.zs:1089, handler.zs:1438, CVARINFO.txt:88, CVARINFO.txt:92, CVARINFO.txt:85 | RS_ScoreHandler.CheckRewards; RunExtraLives |
| H263 | Shoot a monster in the head | head.zs:441, combo.zs:165 | RS_ScoreHead.Outcome; RS_ComboLedger.CondOf |
| H264 | Fire a gun | crit.zs:112 | RS_ScoreCritBrain.ModifyDamage |
| H265 | Kill anything | hud.zs:94, hud.zs:95, hud.zs:96 | RS_ScoreHUD.RenderOverlay |
| H266 | Kill anything | hud.zs:99 | RS_ScoreHUD.RenderOverlay |
| H267 | Kill a roster monster | rows_roster.zs:141, rows_roster.zs:155 | RS_RosterRow.Evaluate; RS_RosterTierRow.Evaluate |
| H268 | Kill with many bonuses of one family | handler.zs:634, CVARINFO.txt:51 | RS_ScoreHandler.AwardKiller |

## How to play: the named combos

Each named combo is one line of the two tables. The words of the legend above the README's combo table: `tools.zs:148` to `tools.zs:164` (RS_Tool.InGroup: the groups), `tools.zs:186` to `tools.zs:188` (RS_Tool.StepMatches: `+air`, `+pb`, `+head`), `combo.zs:155` (RS_ComboLedger.CondOf: `@slow` is the player's own slow motion), `boost.zs:132` to `boost.zs:139` (RS_Boost.VictimIs: the words after `|`), `combo.zs:97` (the 3 s gap), `combo.zs:489` (the last step is the killing blow), `combo.zs:617` (the best match).

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| K1 | Lion Tamer: whip > shield.bash, 0.5 | combo.zs:67 | RS_ComboSeed.Combos |
| K2 | Clay Pigeon: force.push > gun, 0.5 | combo.zs:68 | RS_ComboSeed.Combos |
| K3 | Sitting Duck: force.grip > gun, 0.5 | combo.zs:69 | RS_ComboSeed.Combos |
| K4 | Pull!: force.pull > gun, 0.5 | combo.zs:70 | RS_ComboSeed.Combos |
| K5 | Disc Jockey: force.push > shield.disc, 0.5 | combo.zs:71 | RS_ComboSeed.Combos |
| K6 | Gun Kata: hands > gun, 0.4 | combo.zs:72 | RS_ComboSeed.Combos |
| K7 | Fast Hands: melee > rig.draw, 0.5 | combo.zs:73 | RS_ComboSeed.Combos |
| K8 | Lasso: whip > hook.yank, 0.5 | combo.zs:74 | RS_ComboSeed.Combos |
| K9 | Pitch and Slice: grab.throw > saber.cut, 0.5 | combo.zs:75 | RS_ComboSeed.Combos |
| K10 | Circus Act: whip > hook.yank > gun, 0.9 | combo.zs:76 | RS_ComboSeed.Combos |
| K11 | Yo-Yo: force.pull > force.push > gun, 0.9 | combo.zs:77 | RS_ComboSeed.Combos |
| K12 | Discus: shield.bash > force.push > shield.disc, 0.9 | combo.zs:78 | RS_ComboSeed.Combos |
| K13 | Headlock: grab.hold > hands, 0.5 | combo.zs:82 | RS_ComboSeed.Combos |
| K14 | F.E.A.R. Effect: shove > gun.shotgun@slow, 0.6 | combo.zs:86 | RS_ComboSeed.Combos |
| K15 | Trap Shooter: glove.upper > gun.shotgun, 0.5 | combos.zs:25 | RS_ComboTable.Add |
| K16 | Rising Dragon: glove.upper > saber.cut, 0.5 | combos.zs:26 | RS_ComboTable.Add |
| K17 | Spike: glove.upper > shield.disc, 0.5 | combos.zs:27 | RS_ComboTable.Add |
| K18 | Catch of the Day: glove.upper > hook.yank, 0.6 | combos.zs:28 | RS_ComboTable.Add |
| K19 | Air Lash: glove.upper > whip.crack, 0.5 | combos.zs:29 | RS_ComboTable.Add |
| K20 | Alley-Oop: glove.upper > grab.throw, 0.5 | combos.zs:30 | RS_ComboTable.Add |
| K21 | Air Mail: glove.upper > grenade, 0.5 | combos.zs:31 | RS_ComboTable.Add |
| K22 | Fireworks: glove.upper > gun.explosive, 0.5 | combos.zs:32 | RS_ComboTable.Add |
| K23 | One-Two-Skeet: glove > glove.upper > gun.shotgun, 0.9 | combos.zs:33 | RS_ComboTable.Add |
| K24 | Cross Cut: glove.hook > saber.cut, 0.4 | combos.zs:34 | RS_ComboTable.Add |
| K25 | Fist and Shield: glove > shield.bash, 0.4 | combos.zs:35 | RS_ComboTable.Add |
| K26 | Knuckle Crack: glove > whip.crack, 0.4 | combos.zs:36 | RS_ComboTable.Add |
| K27 | Jedi Jab: glove > force.push, 0.4 | combos.zs:37 | RS_ComboTable.Add |
| K28 | Punch and Pitch: glove > shield.disc, 0.4 | combos.zs:38 | RS_ComboTable.Add |
| K29 | Slow Trap Shooter: glove.upper@slow > gun.shotgun, 0.55 | combos.zs:39 | RS_ComboTable.Add |
| K30 | Feint: glove.jab > saber.stab, 0.45 | combos.zs:40 | RS_ComboTable.Add |
| K31 | Skyskewer: glove.upper > saber.stab, 0.55 | combos.zs:41 | RS_ComboTable.Add |
| K32 | Pistol Whip: shove > gun.pistol, 0.5 | combos.zs:43 | RS_ComboTable.Add |
| K33 | Executioner: shove > gun+head, 0.6 | combos.zs:45 | RS_ComboTable.Add |
| K34 | Riot Shield: shove > shield.bash, 0.5 | combos.zs:46 | RS_ComboTable.Add |
| K35 | Make Room: shove > saber.cut, 0.4 | combos.zs:47 | RS_ComboTable.Add |
| K36 | Fire in the Hole: shove > grenade, 0.45 | combos.zs:48 | RS_ComboTable.Add |
| K37 | Backlash: shove > whip.crack, 0.4 | combos.zs:49 | RS_ComboTable.Add |
| K38 | Street Fighter: hadouken > glove.upper, 0.6 | combos.zs:51 | RS_ComboTable.Add |
| K39 | Shoto: hadouken > saber.cut, 0.5 | combos.zs:52 | RS_ComboTable.Add |
| K40 | Return Fire: hadouken > shove > gun.shotgun, 1 | combos.zs:53 | RS_ComboTable.Add |
| K41 | Neo: hadouken@slow > glove, 0.6 | combos.zs:54 | RS_ComboTable.Add |
| K42 | Backhand Spring: swat > glove.upper > gun.pistol, 1 | combos.zs:55 | RS_ComboTable.Add |
| K43 | Parry Punish: guard.parry > any, 0.5 | combos.zs:56 | RS_ComboTable.Add |
| K44 | Counter Cut: guard.parry > saber, 0.6 | combos.zs:57 | RS_ComboTable.Add |
| K45 | Knuckle Sandwich: guard.parry > glove, 0.55 | combos.zs:58 | RS_ComboTable.Add |
| K46 | Dragon Fist: guard.parry > glove.upper > glove, 0.9 | combos.zs:59 | RS_ComboTable.Add |
| K47 | Pressure Valve: guard.release > glove, 0.5 | combos.zs:60 | RS_ComboTable.Add |
| K48 | Hostage: grab.hold > gun.pistol, 0.5 | combos.zs:62 | RS_ComboTable.Add |
| K49 | Close Quarters: grab.hold > gun.shotgun, 0.5 | combos.zs:63 | RS_ComboTable.Add |
| K50 | Hold This: grab.hold > grenade, 0.6 | combos.zs:64 | RS_ComboTable.Add |
| K51 | Execution: grab.hold > saber, 0.5 | combos.zs:65 | RS_ComboTable.Add |
| K52 | Suplex: grab.hold > headlock.throw, 0.5 | combos.zs:66 | RS_ComboTable.Add |
| K53 | Flog: grab.hold > whip.crack, 0.5 | combos.zs:67 | RS_ComboTable.Add |
| K54 | Title Belt: grab.hold > hands \| champ, 0.6 | combos.zs:68 | RS_ComboTable.Add |
| K55 | Bouncer: grab.hold > hands > gun.shotgun, 0.9 | combos.zs:69 | RS_ComboTable.Add |
| K56 | Choke and Cut: grab.hold > headlock.choke > saber.cut, 0.9 | combos.zs:70 | RS_ComboTable.Add |
| K57 | Slam and Blam: grab.hold > headlock.slam > gun.shotgun, 0.9 | combos.zs:71 | RS_ComboTable.Add |
| K58 | Clay Toss: headlock.throw > gun.shotgun, 0.5 | combos.zs:72 | RS_ComboTable.Add |
| K59 | Ground and Pound: headlock.slam > glove, 0.5 | combos.zs:73 | RS_ComboTable.Add |
| K60 | Pin Down: headlock.slam > saber.stab, 0.55 | combos.zs:74 | RS_ComboTable.Add |
| K61 | Come Get Some: taunt > hands, 0.4 | combos.zs:76 | RS_ComboTable.Add |
| K62 | Come Closer: taunt > gun.shotgun, 0.5 | combos.zs:77 | RS_ComboTable.Add |
| K63 | Tremor: pound > gun.shotgun, 0.45 | combos.zs:78 | RS_ComboTable.Add |
| K64 | Quake: pound > shield.bash, 0.4 | combos.zs:79 | RS_ComboTable.Add |
| K65 | Get Back!: clearout > grenade, 0.5 | combos.zs:80 | RS_ComboTable.Add |
| K66 | Spread Out: clearout > gun.explosive, 0.45 | combos.zs:81 | RS_ComboTable.Add |
| K67 | Laser Sword: saber.cut > gun.energy, 0.5 | combos.zs:84 | RS_ComboTable.Add |
| K68 | Blade and Buckshot: saber.cut > gun.shotgun, 0.45 | combos.zs:85 | RS_ComboTable.Add |
| K69 | Edge and Board: saber.cut > shield.bash, 0.4 | combos.zs:86 | RS_ComboTable.Add |
| K70 | Pommel: saber.cut > glove, 0.4 | combos.zs:87 | RS_ComboTable.Add |
| K71 | Slash and Blast: saber.cut > force.push > gun.shotgun, 0.9 | combos.zs:88 | RS_ComboTable.Add |
| K72 | Distraction: saber.throw > glove, 0.5 | combos.zs:89 | RS_ComboTable.Add |
| K73 | Covering Fire: saber.throw > gun.rifle, 0.45 | combos.zs:90 | RS_ComboTable.Add |
| K74 | Air Traffic: saber.throw > shield.disc, 0.5 | combos.zs:91 | RS_ComboTable.Add |
| K75 | Throw and Go: saber.throw > saber.cut, 0.4 | combos.zs:92 | RS_ComboTable.Add |
| K76 | Return Flight: saber.throw > force.pull > saber.cut, 0.9 | combos.zs:93 | RS_ComboTable.Add |
| K77 | Helpless: force.grip > saber.cut, 0.5 | combos.zs:94 | RS_ComboTable.Add |
| K78 | Hung Out to Dry: force.grip > glove, 0.5 | combos.zs:95 | RS_ComboTable.Add |
| K79 | Special Delivery: force.grip > grenade, 0.5 | combos.zs:96 | RS_ComboTable.Add |
| K80 | Pinned: force.grip > shield.disc, 0.5 | combos.zs:97 | RS_ComboTable.Add |
| K81 | Strung Up: force.grip > whip.crack, 0.5 | combos.zs:98 | RS_ComboTable.Add |
| K82 | Exorcism: force.grip > saber.cut \| Ghost, 0.6 | combos.zs:99 | RS_ComboTable.Add |
| K83 | Jedi Brawler: force.grip > glove > saber.cut, 0.9 | combos.zs:100 | RS_ComboTable.Add |
| K84 | Superhero Landing: force.jump > glove, 0.5 | combos.zs:101 | RS_ComboTable.Add |
| K85 | Leap Strike: force.jump > saber.cut, 0.5 | combos.zs:102 | RS_ComboTable.Add |
| K86 | Come Here, Go Up: force.pull > glove.upper > gun.shotgun, 0.9 | combos.zs:103 | RS_ComboTable.Add |
| K87 | Force Arrest: force.pull > grab.hold > glove, 0.9 | combos.zs:104 | RS_ComboTable.Add |
| K88 | Jedi Hoplite: force.pull > shield.bash > saber.cut, 0.9 | combos.zs:105 | RS_ComboTable.Add |
| K89 | Clay Saber: force.push > saber.throw, 0.5 | combos.zs:106 | RS_ComboTable.Add |
| K90 | Slingshot: force.push > hook.yank, 0.5 | combos.zs:107 | RS_ComboTable.Add |
| K91 | Hot Seat: force.push > grab.keg, 0.5 | combos.zs:108 | RS_ComboTable.Add |
| K92 | Scoundrel: force.push > saber.throw > gun.pistol, 0.9 | combos.zs:109 | RS_ComboTable.Add |
| K93 | Push-Pull: force.push > force.pull > saber.cut, 0.9 | combos.zs:110 | RS_ComboTable.Add |
| K94 | Time Slash: force.push@slow > saber.cut, 0.55 | combos.zs:111 | RS_ComboTable.Add |
| K95 | Off the Blade: saber.stab > force.push, 0.5 | combos.zs:112 | RS_ComboTable.Add |
| K96 | Stab and Jab: saber.stab > glove, 0.4 | combos.zs:113 | RS_ComboTable.Add |
| K97 | Shock and Awe: force.lightning > glove, 0.5 | combos.zs:114 | RS_ComboTable.Add |
| K98 | Sith Ambush: force.lightning > saber.cut, 0.5 | combos.zs:115 | RS_ComboTable.Add |
| K99 | Overcharge: force.lightning > gun.energy, 0.5 | combos.zs:116 | RS_ComboTable.Add |
| K100 | Riot Control: shield.bash > gun.shotgun, 0.5 | combos.zs:119 | RS_ComboTable.Add |
| K101 | Bash and Slash: shield.bash > saber.cut, 0.5 | combos.zs:120 | RS_ComboTable.Add |
| K102 | Spring Back: shield.bash > hook.yank, 0.45 | combos.zs:121 | RS_ComboTable.Add |
| K103 | Bash and Lash: shield.bash > whip.crack, 0.4 | combos.zs:122 | RS_ComboTable.Add |
| K104 | Shield and Fist: shield.bash > glove, 0.4 | combos.zs:123 | RS_ComboTable.Add |
| K105 | Crack the Shell: shield.bash > blade \| armoured, 0.55 | combos.zs:124 | RS_ComboTable.Add |
| K106 | Bash and Launch: shield.bash > glove.upper > gun.shotgun, 0.9 | combos.zs:125 | RS_ComboTable.Add |
| K107 | Shield Up: shield.block > grenade, 0.5 | combos.zs:126 | RS_ComboTable.Add |
| K108 | This Is Sparta: shield.block > shield.bash > saber, 0.9 | combos.zs:127 | RS_ComboTable.Add |
| K109 | Riot Squad: shield.block > shield.bash > gun.shotgun, 0.9 | combos.zs:128 | RS_ComboTable.Add |
| K110 | Shield Uppercut: shield.block > shield.bash > glove.upper, 1 | combos.zs:129 | RS_ComboTable.Add |
| K111 | Slow Sparta: shield.block@slow > shield.bash > saber.cut, 1 | combos.zs:130 | RS_ComboTable.Add |
| K112 | Blitz: shield.dash > glove.upper, 0.5 | combos.zs:131 | RS_ComboTable.Add |
| K113 | Door Kicker: shield.dash > gun.shotgun, 0.5 | combos.zs:132 | RS_ComboTable.Add |
| K114 | Spartan Charge: shield.dash > saber, 0.5 | combos.zs:133 | RS_ComboTable.Add |
| K115 | Saw and Saber: shield.disc > saber.cut, 0.5 | combos.zs:134 | RS_ComboTable.Add |
| K116 | Crossfire: shield.disc > saber.throw, 0.5 | combos.zs:135 | RS_ComboTable.Add |
| K117 | Follow-Through: shield.disc > glove, 0.4 | combos.zs:136 | RS_ComboTable.Add |
| K118 | Throw and Follow: shield.disc > shield.bash, 0.4 | combos.zs:137 | RS_ComboTable.Add |
| K119 | Cleanup Crack: shield.disc > whip.crack, 0.4 | combos.zs:138 | RS_ComboTable.Add |
| K120 | Vibranium: shield.disc > shield.dash > glove, 0.9 | combos.zs:139 | RS_ComboTable.Add |
| K121 | Sawblade Send-Off: shield.grind > force.push > shield.disc, 0.9 | combos.zs:140 | RS_ComboTable.Add |
| K122 | Turnabout: block > hook, 0.5 | combos.zs:141 | RS_ComboTable.Add |
| K123 | Hoplite: shield.bash > saber.stab, 0.55 | combos.zs:142 | RS_ComboTable.Add |
| K124 | Nailed: shield.slam > saber.stab, 0.55 | combos.zs:143 | RS_ComboTable.Add |
| K125 | Up Against the Wall: shield.slam > glove, 0.5 | combos.zs:144 | RS_ComboTable.Add |
| K126 | Ringmaster: whip > hook > shield.bash, 1 | combos.zs:147 | RS_ComboTable.Add |
| K127 | Frontier: whip.crack > gun.pistol, 0.5 | combos.zs:148 | RS_ComboTable.Add |
| K128 | High Noon: whip.crack > rig.draw, 0.6 | combos.zs:149 | RS_ComboTable.Add |
| K129 | Zorro: whip.crack > saber, 0.5 | combos.zs:150 | RS_ComboTable.Add |
| K130 | Big Top: whip.crack > shield.disc, 0.55 | combos.zs:151 | RS_ComboTable.Add |
| K131 | Crack and Smack: whip.crack > glove, 0.4 | combos.zs:152 | RS_ComboTable.Add |
| K132 | Crack of Doom: whip.crack > any \| legend.dormant, 0.6 | combos.zs:153 | RS_ComboTable.Add |
| K133 | Bullet Ballet: whip.crack@slow > gun, 0.9 | combos.zs:154 | RS_ComboTable.Add |
| K134 | Tetherball: whip.flail > glove, 0.5 | combos.zs:155 | RS_ComboTable.Add |
| K135 | Tetherball Disc: whip.flail > shield.disc, 0.5 | combos.zs:156 | RS_ComboTable.Add |
| K136 | Rope-a-Dope: whip.lasso > glove, 0.5 | combos.zs:157 | RS_ComboTable.Add |
| K137 | Rodeo: whip.lasso > gun, 0.45 | combos.zs:158 | RS_ComboTable.Add |
| K138 | Hogtie: whip.lasso > saber.cut, 0.5 | combos.zs:159 | RS_ComboTable.Add |
| K139 | Roped and Diced: whip.lasso > shield.disc, 0.5 | combos.zs:160 | RS_ComboTable.Add |
| K140 | Bound: whip.lasso > force.grip, 0.5 | combos.zs:161 | RS_ComboTable.Add |
| K141 | Hog-Tied: whip.bola > grenade, 0.55 | combos.zs:162 | RS_ComboTable.Add |
| K142 | Saloon Brawl: whip.lasso > glove > gun.pistol, 0.9 | combos.zs:163 | RS_ComboTable.Add |
| K143 | Bounty Hunter: whip.lasso > force.pull > saber.cut, 0.9 | combos.zs:164 | RS_ComboTable.Add |
| K144 | Jungle Law: whip.tarzan > glove, 0.5 | combos.zs:165 | RS_ComboTable.Add |
| K145 | Swing Shot: whip.tarzan > gun.shotgun, 0.5 | combos.zs:166 | RS_ComboTable.Add |
| K146 | Swashbuckler: whip.tarzan > saber.cut, 0.6 | combos.zs:167 | RS_ComboTable.Add |
| K147 | Cannonball: whip.tarzan > shield.bash, 0.55 | combos.zs:168 | RS_ComboTable.Add |
| K148 | On a Leash: whip.wrap > glove, 0.5 | combos.zs:169 | RS_ComboTable.Add |
| K149 | Tied Up: whip.wrap > saber.cut, 0.5 | combos.zs:170 | RS_ComboTable.Add |
| K150 | Tethered: whip.wrap > shield.disc, 0.5 | combos.zs:171 | RS_ComboTable.Add |
| K151 | Gift Wrapped: whip.wrap > gun.explosive, 0.5 | combos.zs:172 | RS_ComboTable.Add |
| K152 | Package Deal: whip.wrap > grenade, 0.5 | combos.zs:173 | RS_ComboTable.Add |
| K153 | Strangler: whip.wrap > force.grip, 0.5 | combos.zs:174 | RS_ComboTable.Add |
| K154 | Puppeteer: whip.wrap > force.grip > saber.cut, 0.9 | combos.zs:175 | RS_ComboTable.Add |
| K155 | Get Over Here!: whip.yank > glove, 0.6 | combos.zs:176 | RS_ComboTable.Add |
| K156 | Closer: whip.yank > gun.shotgun, 0.5 | combos.zs:177 | RS_ComboTable.Add |
| K157 | Reel and Deal: whip.yank > saber.cut, 0.5 | combos.zs:178 | RS_ComboTable.Add |
| K158 | Yank and Bank: whip.yank > shield.bash, 0.55 | combos.zs:179 | RS_ComboTable.Add |
| K159 | Into the Blades: whip.yank > shield.grind, 0.55 | combos.zs:180 | RS_ComboTable.Add |
| K160 | Yank and Launch: whip.yank > glove.upper > gun.shotgun, 0.9 | combos.zs:181 | RS_ComboTable.Add |
| K161 | Ringside: whip.yank > grab.hold > glove, 0.9 | combos.zs:182 | RS_ComboTable.Add |
| K162 | Reel and Run Through: whip.yank > saber.stab, 0.55 | combos.zs:183 | RS_ComboTable.Add |
| K163 | Fish Out of Water: hook > glove.upper, 0.6 | combos.zs:186 | RS_ComboTable.Add |
| K164 | Harpoon: hook > saber.cut, 0.5 | combos.zs:187 | RS_ComboTable.Add |
| K165 | Doorstop: hook > shield.bash, 0.5 | combos.zs:188 | RS_ComboTable.Add |
| K166 | Come Here!: hook > hands, 0.5 | combos.zs:189 | RS_ComboTable.Add |
| K167 | Hook Shot: hook > gun.shotgun, 0.45 | combos.zs:190 | RS_ComboTable.Add |
| K168 | Care Package: hook > grenade, 0.6 | combos.zs:191 | RS_ComboTable.Add |
| K169 | Collar: hook > grab.hold, 0.45 | combos.zs:192 | RS_ComboTable.Add |
| K170 | Crack the Line: hook > whip.crack, 0.5 | combos.zs:193 | RS_ComboTable.Add |
| K171 | Sawmill: hook > shield.grind, 0.55 | combos.zs:194 | RS_ComboTable.Add |
| K172 | Meat Hook: hook > blade, 0.55 | combos.zs:195 | RS_ComboTable.Add |
| K173 | Strung Out: hook > force.grip > gun, 0.9 | combos.zs:196 | RS_ComboTable.Add |
| K174 | Kite: hook > glove.upper > hook.yank, 1.1 | combos.zs:197 | RS_ComboTable.Add |
| K175 | Finish Him!: hook > hands > fatality, 1.1 | combos.zs:198 | RS_ComboTable.Add |
| K176 | Reel and Hurl: hook > shield.bash > shield.disc, 1 | combos.zs:199 | RS_ComboTable.Add |
| K177 | Wrestlemania: hook.yank > grab.hold > glove, 0.9 | combos.zs:200 | RS_ComboTable.Add |
| K178 | Suplex City: hook.yank > grab.hold > headlock.throw, 0.9 | combos.zs:201 | RS_ComboTable.Add |
| K179 | Hook, Line and Sinker: hook.yank > shield.bash > saber.cut, 0.9 | combos.zs:202 | RS_ComboTable.Add |
| K180 | Hooked Keg: hook.keg > any, 0.4 | combos.zs:203 | RS_ComboTable.Add |
| K181 | Fetch!: hook.keg > grab.throw > gun, 1 | combos.zs:204 | RS_ComboTable.Add |
| K182 | Drop In: hook.zip > gun, 0.45 | combos.zs:205 | RS_ComboTable.Add |
| K183 | Swoop: hook.zip > melee, 0.6 | combos.zs:206 | RS_ComboTable.Add |
| K184 | Catch This: grab.throw > glove, 0.45 | combos.zs:209 | RS_ComboTable.Add |
| K185 | Batter Up: grab.throw > gun, 0.35 | combos.zs:210 | RS_ComboTable.Add |
| K186 | Bait and Hook: grab.throw > hook, 0.45 | combos.zs:211 | RS_ComboTable.Add |
| K187 | Serve and Volley: grab.throw > shield.bash, 0.45 | combos.zs:212 | RS_ComboTable.Add |
| K188 | Two Throws: grab.throw > shield.disc, 0.45 | combos.zs:213 | RS_ComboTable.Add |
| K189 | Toss and Crack: grab.throw > whip.crack, 0.45 | combos.zs:214 | RS_ComboTable.Add |
| K190 | Kitchen Sink: grab.throw > grenade > gun, 1 | combos.zs:215 | RS_ComboTable.Add |
| K191 | Bait and Switch: grab.throw > hook > melee, 1 | combos.zs:216 | RS_ComboTable.Add |
| K192 | Aftershock: grab.keg > melee, 0.5 | combos.zs:217 | RS_ComboTable.Add |
| K193 | Sandbag Riposte: grab.shield > gun, 0.4 | combos.zs:218 | RS_ComboTable.Add |
| K194 | Into the Breach: grenade > melee, 0.45 | combos.zs:221 | RS_ComboTable.Add |
| K195 | Mop Up: grenade > gun, 0.3 | combos.zs:222 | RS_ComboTable.Add |
| K196 | Flush Out: grenade > hook, 0.5 | combos.zs:223 | RS_ComboTable.Add |
| K197 | Shell Shock: grenade > glove, 0.5 | combos.zs:224 | RS_ComboTable.Add |
| K198 | Frag and Slash: grenade > saber.cut, 0.5 | combos.zs:225 | RS_ComboTable.Add |
| K199 | Demolition: grenade > grab.keg > gun, 1 | combos.zs:226 | RS_ComboTable.Add |
| K200 | Ice Breaker: grenade.freeze > glove, 0.55 | combos.zs:227 | RS_ComboTable.Add |
| K201 | Cold Cut: grenade.freeze > saber.cut, 0.55 | combos.zs:228 | RS_ComboTable.Add |
| K202 | Cold Shoulder: grenade.freeze > shield.bash, 0.55 | combos.zs:229 | RS_ComboTable.Add |
| K203 | Ice Fishing: grenade.freeze > hook.yank, 0.7 | combos.zs:230 | RS_ComboTable.Add |
| K204 | Ice Pop: grenade.freeze > glove.upper > gun.shotgun, 1 | combos.zs:231 | RS_ComboTable.Add |
| K205 | Dazed and Confused: grenade.stun > glove, 0.55 | combos.zs:232 | RS_ComboTable.Add |
| K206 | Stun and Gun: grenade.stun > gun, 0.45 | combos.zs:233 | RS_ComboTable.Add |
| K207 | Snatch: grenade.stun > hook, 0.55 | combos.zs:234 | RS_ComboTable.Add |
| K208 | Dizzy Finish: grenade.stun > glove > fatality, 1 | combos.zs:235 | RS_ComboTable.Add |
| K209 | Butcher Shop: grenade.stun > hook > blade, 1.1 | combos.zs:236 | RS_ComboTable.Add |
| K210 | Lights Out: grenade.flash > melee, 0.5 | combos.zs:237 | RS_ComboTable.Add |
| K211 | Blind Side: grenade.flash > saber, 0.55 | combos.zs:238 | RS_ComboTable.Add |
| K212 | Swat Team: grenade.flash > hook > gun.shotgun, 1 | combos.zs:239 | RS_ComboTable.Add |
| K213 | Breach and Clear: grenade.flash > shield.dash > gun.shotgun, 0.9 | combos.zs:240 | RS_ComboTable.Add |
| K214 | Out of the Smoke: grenade.smoke > melee, 0.5 | combos.zs:241 | RS_ComboTable.Add |
| K215 | Ninja: grenade.smoke > saber.stab, 0.55 | combos.zs:242 | RS_ComboTable.Add |
| K216 | Batting Practice: grab.swing > gun, 0.4 | combos.zs:243 | RS_ComboTable.Add |
| K217 | Ghost Hold: grenade.smoke > grab.hold > blade, 1 | combos.zs:244 | RS_ComboTable.Add |
| K218 | Pin Cushion: grenade.sticky > gun, 0.45 | combos.zs:245 | RS_ComboTable.Add |
| K219 | Hot Potato: grenade.sticky > hook > grenade, 1.2 | combos.zs:246 | RS_ComboTable.Add |
| K220 | Return to the Pack: grenade.sticky > force.push > grenade, 0.9 | combos.zs:247 | RS_ComboTable.Add |
| K221 | Hot Lash: grenade.fire > whip.crack, 0.5 | combos.zs:248 | RS_ComboTable.Add |
| K222 | Fan the Flames: grenade.fire > force.push > gun.fire, 0.9 | combos.zs:249 | RS_ComboTable.Add |
| K223 | Rocket Punch: gun.explosive > glove, 0.5 | combos.zs:252 | RS_ComboTable.Add |
| K224 | Over-Under: gun.explosive > gun.rifle, 0.4 | combos.zs:253 | RS_ComboTable.Add |
| K225 | Mop-Up Saw: gun.explosive > blade.saw, 0.5 | combos.zs:254 | RS_ComboTable.Add |
| K226 | Hot Hands: gun.fire > glove, 0.5 | combos.zs:255 | RS_ComboTable.Add |
| K227 | Fire Whip: gun.fire > whip.crack, 0.45 | combos.zs:256 | RS_ComboTable.Add |
| K228 | Plasma Blade: gun.energy > saber.cut, 0.45 | combos.zs:257 | RS_ComboTable.Add |
| K229 | Shoot and Snap: gun.pistol > whip.crack, 0.4 | combos.zs:258 | RS_ComboTable.Add |
| K230 | Buckshot Brawl: gun.shotgun > glove, 0.4 | combos.zs:259 | RS_ComboTable.Add |
| K231 | Clean Up: gun.shotgun > saber.cut, 0.4 | combos.zs:260 | RS_ComboTable.Add |
| K232 | Suppress and Storm: gun.rifle > shield.bash, 0.45 | combos.zs:261 | RS_ComboTable.Add |
| K233 | Rip and Pump: blade.saw > gun.shotgun, 0.4 | combos.zs:262 | RS_ComboTable.Add |
| K234 | Door Kick: kick > gun.shotgun+pb, 0.5 | combos.zs:263 | RS_ComboTable.Add |
| K235 | Showdown: rig.draw@slow > gun, 0.9 | combos.zs:266 | RS_ComboTable.Add |
| K236 | Draw and Shove Off: rig.draw > force.push > gun.pistol, 0.9 | combos.zs:267 | RS_ComboTable.Add |
| K237 | Tuco: throw.gun > rig.draw, 0.5 | combos.zs:268 | RS_ComboTable.Add |
| K238 | Slip and Shoot: lean > gun, 0.4 | combos.zs:269 | RS_ComboTable.Add |
| K239 | Bob and Weave: lean > hands, 0.5 | combos.zs:270 | RS_ComboTable.Add |
| K240 | Tennis: return > return, 0.5 | combos.zs:271 | RS_ComboTable.Add |
| K241 | Volley: return > return > return, 1 | combos.zs:272 | RS_ComboTable.Add |
| K242 | Kingslayer: any@slow > any \| miniboss, 0.5 | combos.zs:273 | RS_ComboTable.Add |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQ Score's own service, `RS_ScoreService`: Score answers by service name | awards.zs:91, awards.zs:95, awards.zs:107, awards.zs:116, awards.zs:130, awards.zs:149, awards.zs:150, awards.zs:151, awards.zs:156, awards.zs:164, awards.zs:173, awards.zs:182, awards.zs:199, awards.zs:204, awards.zs:207, awards.zs:208, awards.zs:215, awards.zs:264, awards.zs:265, awards.zs:266, awards.zs:267, awards.zs:268, awards.zs:269, awards.zs:270, awards.zs:271, awards.zs:233, awards.zs:234, awards.zs:244, awards.zs:255 | RS_ScoreService.GetInt; GetString; GetObject; GetIntUI; Read |
| W2 | Any mod that links Score: the registry and the engine score field | bonus.zs:308, bonus.zs:187, bonus.zs:197, handler.zs:827 | RS_ScoreRegistry; RS_ScoreHandler.Pay |
| W3 | RSQ Grapple: names asked of RSQGR_Service, none answered | svc.zs:19, tools.zs:288, tools.zs:289, tools.zs:290, tools.zs:292, tools.zs:294, combo.zs:309, combo.zs:310, combo.zs:314, hook.zs:157, hook.zs:132, hook.zs:206, hook.zs:213, hook.zs:215, hook.zs:216, Grapple/zscript/rsqgr/service.zs:53 | RS_Svc.NameOf; RS_Tool.Classify; RS_ComboLedger.Poll; RS_Bonus_Bowling; RS_Bonus_PingPong; RS_Rope.Ask; (Grapple) RSQGR_Service.GetInt |
| W4 | RSQ ShieldSaw: names asked of SSQ_ScoreService | svc.zs:20, combo.zs:329, combo.zs:331, melee.zs:285, melee.zs:522, melee.zs:226, melee.zs:562, rows.zs:1410, melee.zs:928, melee.zs:930, melee.zs:164, tools.zs:71 | RS_Svc.NameOf; RS_ComboLedger.Poll; RS_Melee.ReturnedOf; ThrownLeg; ShieldInHand; RS_ScoreShots.Classes; RS_Tool.IsTag |
| W5 | RSQ Saber: names asked of UBQS_SaberService | svc.zs:21, combo.zs:321, combo.zs:323, combo.zs:324, combo.zs:326, melee.zs:297, melee.zs:206, tools.zs:266, tools.zs:267, tools.zs:277, tools.zs:335, wrist.zs:57, tools.zs:69, awards.zs:34, awards.zs:40 | RS_Svc.NameOf; RS_ComboLedger.Poll; RS_Melee.SaberLit; AskAny; RS_Tool.Classify; IsTag; RS_ScoreWrist.FindGlyphs |
| W6 | RSQ Distance Grab: names asked of RSQDG_ThrowService | svc.zs:22, physical.zs:148, physical.zs:384, physical.zs:385, physical.zs:445, rows.zs:723, physical.zs:605, rows.zs:1439, lifecrate.zs:55, lifecrate.zs:60 | RS_Svc.NameOf; RS_Physical.ThrownBy; RS_Bonus_Thrown; RS_Bonus_AirCatch; RS_Row_HeavyThrow; RS_Bonus_FullHands; RS_Row_Clubbed; RSQ_ScoreLifeCrate.GrabRule |
| W7 | RSQ Tactical Rig: names asked of RSQTR_RigService | svc.zs:23, physical.zs:488, physical.zs:490, tools.zs:47, tools.zs:80 | RS_Svc.NameOf; RS_Bonus_QuickDraw.Evaluate; RS_Tool.Canon; IsTag |
| W8 | RSQ SlowMo: names asked of RSQSM_Service | svc.zs:24, physical.zs:104, physical.zs:105, physical.zs:710, physical.zs:714, rows.zs:1500, handler.zs:1332, handler.zs:1405, hud.zs:178, handler.zs:1175, handler.zs:1130, handler.zs:1446, handler.zs:1137, handler.zs:1138, handler.zs:751, tools.zs:162, handler.zs:912, rows_panels.zs:96 | RS_Svc.NameOf; RS_Physical.SlowKind; RS_Bonus_BulletTime.AfterOthers; RS_Row_LastGrain; RS_ScoreHandler.DownHolds; RunExtraLives; SlowMoReward; RunRewardCue; HitStopMs; AwardExternal; RS_ScoreHUD.CountdownShift; RS_ScorePanels.WorldThingSpawned |
| W9 | RSQ Whip: names asked of RSQWP_Service; what it answers now | svc.zs:25, combo.zs:316, combo.zs:317, combo.zs:318, tools.zs:331, hook.zs:304, rows.zs:1484, hook.zs:210, hook.zs:224, tools.zs:280, Whip/zscript/rsqwp/service.zs:110, Whip/zscript/rsqwp/service.zs:118 | RS_Svc.NameOf; RS_ComboLedger.Poll; RS_Tool.Classify; RS_Bonus_Lashed; RS_Row_ChainSwing; RS_Rope.Ask; (Whip) RSQWP_Events.Answer |
| W10 | RSQ Melee: names asked of RSQML_Service | svc.zs:26, tools.zs:356, melee.zs:818, rows.zs:132, rows.zs:142, rows.zs:151, rows.zs:175, rows_melee2.zs:195, rows.zs:189, tools.zs:326, melee.zs:1221, rows_melee2.zs:136, rows_melee2.zs:66, rows_melee2.zs:151, rows_melee2.zs:234, melee.zs:308, tools.zs:318, rows_melee2.zs:218, tools.zs:41, tools.zs:62, handler.zs:893, combo.zs:86 | RS_Svc.NameOf; RS_Tool.GloveKind; Classify; Canon; IsTag; RS_Bonus_Counter; RS_Rows.Punch callers; RS_ScoreShots.LaunchedBy; RS_Melee2.Ask callers; RS_Melee.IsGlove; RS_ScoreHandler.AwardExternal |
| W11 | RSQ Grenade: names asked of RSQGN_Service | svc.zs:27, handler.zs:421, combo.zs:142, combo.zs:143, combo.zs:144, rows.zs:838, tools.zs:282, tools.zs:283, tools.zs:284, tools.zs:25, tools.zs:32 | RS_Svc.NameOf; RS_ScoreHandler.WorldThingDied; RS_ComboLedger.WorldThingDamaged; RS_Row_Cooked; RS_Tool.Classify; Canon |
| W12 | RSQ Miniboss: names asked of RSQMB_Service | svc.zs:28, handler.zs:773, handler.zs:249, rows.zs:1320, rows.zs:1348, gold.zs:118, gold.zs:119, hud.zs:180, boost.zs:137, boost.zs:138, rows.zs:1358, handler.zs:903, handler.zs:904, handler.zs:906, awards.zs:80, Miniboss/zscript/rsqmb/tierup.zs:146 | RS_Svc.NameOf; RS_ScoreHandler.RankMult; RankLife; AwardExternal; RS_Row_ChainGang; RS_Row_RageQuit; RS_Row_RiotControl; RS_ScoreGold.WorldTick; RS_Boost.VictimIs; RS_ScoreHUD.CountdownShift |
| W13 | RSQ Monsters: names asked of RSQMN_RosterService | svc.zs:29, rows_roster.zs:53, rows_roster.zs:54, rows_roster.zs:218, rows_roster.zs:300, rows_roster.zs:319, rows_roster.zs:321, rows_roster.zs:52 | RS_Svc.NameOf; RS_Roster |
| W14 | RSQ VisualRewards: names asked of RSQVR_Service | handler.zs:1153, handler.zs:1154, handler.zs:1161, handler.zs:1168, handler.zs:1121, handler.zs:1448, handler.zs:1453, handler.zs:1125, hud.zs:343, hud.zs:183 | RS_ScoreHandler.Banner; Toast; WorldWord; RunRewardCue; RunExtraLives; RS_ScoreHUD.DrawLives; CountdownShift |
| W15 | RSQ Glow In The Dark: name asked of RSQGD_Service | handler.zs:1181, handler.zs:1182, handler.zs:1140 | RS_ScoreHandler.GlowFlash |
| W16 | RSQ Graveyard: name asked of gy_RSQService | handler.zs:1317, handler.zs:1322 | RS_ScoreHandler.TellGraveyard |
| W17 | RSQ Gun Bonsai VR: names asked of RSQ_HudService | hud.zs:621, hud.zs:624, hud.zs:625, tools.zs:66 | RS_ScoreHUD.GaugeShift; RS_Tool.IsTag |
| W18 | RSQ Accessibility: settings read by name | cb.zs:21, hud.zs:474, a11y.zs:34, a11y.zs:22, a11y.zs:21, handler.zs:798, hud.zs:127, wrist.zs:90 | RS_ScoreCB.Mode; RSSC_A11y; RS_ScoreHandler.Pay; RS_ScoreHUD.Layout; DrawBreakdown; RS_ScoreWrist.Show |
| W19 | Brutal Doom and BD22 VR Reloaded: class names read | head.zs:169, head.zs:191, head.zs:429, crit.zs:388, crit.zs:486, tools.zs:218 | RS_ScoreHead.Classes; CheckReplacement; Outcome; RS_ScoreCritHandler.OnRegister; RoundOf; RS_Tool.GunClassOf |
| W20 | Champions: class and setting names read | boost.zs:104, boost.zs:83, boost.zs:184, boost.zs:99, handler.zs:1482, hud.zs:520 | RS_Boost; RS_ScoreHandler.ChampIconOf; RS_ScoreHUD.DrawBreakdown |
| W21 | LegenDoom: lump and class names read | boost.zs:92, boost.zs:102, boost.zs:103 | RS_Boost.LegenDoomLoaded; Legendary; Transformed |
| W22 | Critical Shots (mk-crits) or RandomCrits: class names read | crit.zs:375, crit.zs:382, crit.zs:407 | RS_ScoreCritHandler.OnRegister; WorldThingSpawned |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No keys; only the fire buttons are read | tracker.zs:332, tools.zs:250, tracker.zs:167 | RS_ScoreTracker.Tick; NoteFire; RS_Tool.GunClass |
| L2 | Default: lives and bar wiped at each map | handler.zs:305, handler.zs:288, handler.zs:255 | RS_ScoreHandler.ScoreReset; StartLives |
| L3 | Only a killing hit spends a life | tracker.zs:239, handler.zs:1405 | RS_ScoreTracker.NoteHit; RS_ScoreHandler.RunExtraLives |
| L4 | 10 faces at most | hud.zs:332 | RS_ScoreHUD.DrawLives |
| L5 | What is not a kill | handler.zs:112, handler.zs:396, handler.zs:370 | RS_ScoreHandler.IsScorable; WorldThingDied |
| L6 | Full base once a body | handler.zs:462, handler.zs:203 | RS_ScoreHandler.WorldThingDied; AddToCensus |
| L7 | Replaces | handler.zs:601 | RS_ScoreHandler.AwardKiller |
| L8 | Chain gap 3 s, last step kills | combo.zs:97, combo.zs:99, combo.zs:489 | RS_ComboLedger; RS_Combo.Match |
| L9 | One named combo a kill | combo.zs:617 | RS_Bonus_Chain.Evaluate |
| L10 | Grapple rows silent | Grapple/zscript/rsqgr/service.zs:53, hook.zs:69, hook.zs:154 | (Grapple) RSQGR_Service.GetInt; RS_Grapple.HookedByKiller; RS_Bonus_Bowling.Evaluate |
| L11 | Whip rope rows silent | Whip/zscript/rsqwp/service.zs:110, hook.zs:254, rows.zs:1483 | (Whip) RSQWP_Events.Answer; RS_Bonus_Swinging.Evaluate; RS_Row_ChainSwing.Evaluate |
| L12 | Miniboss answers 0 | Miniboss/zscript/rsqmb/service.zs:93, rows.zs:1316 | (Miniboss) RSQMB_Service.GetInt; RS_Row_ChainGang.Thrall |
| L13 | Monsters never crit | crit.zs:111 | RS_ScoreCritBrain.ModifyDamage |
| L14 | What is never a head shot | head.zs:282, head.zs:294 | RS_ScoreHead.Judge; VerdictAt |
| L15 | Skill Gold off | gold.zs:172, gold.zs:177 | RS_ScoreSkillGold.Enabled; Pay |
| L16 | Glossary pointer and text | glossary.zs:158, glossary.zs:173, glossary_data.zs:1 | RSQSC_GlossaryMenu.MouseEvent; glossary_data.zs |
| L17 | VR only | wrist.zs:83 | RS_ScoreWrist.Show |
| L18 | Five names used twice | rows.zs:199, combos.zs:69, rows.zs:1357, combos.zs:119, rows_melee2.zs:62, combos.zs:157, rows.zs:659, combos.zs:203, rows.zs:897, combos.zs:227 | RS_Row_* DisplayName; RS_ComboTable.Add |
