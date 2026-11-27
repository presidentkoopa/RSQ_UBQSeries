# RSQ Score: where each README claim comes from

Commit read: d66896944 (2026-11-27), then the working tree of the same day over commit 8eaad88ea (the owner's three answers: lives kept across maps, the rows for today's Grapple and Whip, the rows no mod can trigger removed; rows H269 to H272 and L19 are new, and the rows of removed README rows are gone, so the numbers have gaps). A file named without a folder is in `Score/zscript/rsscore/`; `CVARINFO.txt`, `MENUDEF.txt`, `MAPINFO.txt` and `zscript.txt` are in `Score/`; a path that starts with another mod's folder is that mod's. For a bonus row the lines given are, in order of line number: the line its class starts on, its `const` numbers, the line of its name (`DisplayName` / `RowName`) and the first line of its `Evaluate` (or `Ask`, `Mult`, `AfterOthers`); the rule itself is the body of that function. For every other row each line is the line that does the thing. Every line number in this file was looked up in the files at this commit by the text of the line, not typed by hand.

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
| H11 | On the rig, with the Glossary open, set rs_score_glosstest to 1, 2, 3, 4, 5 or 6 in the... | glossary.zs:145, glossary.zs:147, glossary.zs:149, CVARINFO.txt:194 | RSQSC_GlossaryMenu.Ticker |
| H12 | Kill a monster the level counts, a Lost Soul, or a monster that replaces a counted one | handler.zs:103, handler.zs:111, handler.zs:114, event.zs:84, handler.zs:660, tracker.zs:296, hud.zs:206 | RS_ScoreHandler.IsScorable; RS_ScoreEvent.Create; AwardKiller; RS_ScoreTracker.AddScore; RS_ScoreHUD.DrawScoreLine |
| H13 | Kill in a way a row below names | handler.zs:985, handler.zs:648, handler.zs:649, CVARINFO.txt:66, handler.zs:1016, hud.zs:427, CVARINFO.txt:99 | RS_ScoreHandler.PayRows; AwardKiller; AddRowAt; RS_ScoreHUD.DrawBreakdown |
| H14 | Kill a monster that was not on the map by its first tic (raised, or spawned later) | handler.zs:459, handler.zs:460, handler.zs:152, CVARINFO.txt:43 | RS_ScoreHandler.WorldThingDied; CensusAfterFirstTic |
| H15 | Let the level kill a monster with no blow of yours (a crusher, a floor) | handler.zs:413 | RS_ScoreHandler.WorldThingDied |
| H16 | Fill the reward bar | handler.zs:1027, handler.zs:1041, handler.zs:1046, handler.zs:1079, handler.zs:1092, handler.zs:1105, handler.zs:223, handler.zs:226, CVARINFO.txt:25, CVARINFO.txt:10, CVARINFO.txt:11, CVARINFO.txt:12, CVARINFO.txt:13 | RS_ScoreHandler.CheckRewards; RunRewardCue; ComputeThreshold |
| H17 | Start a new game | handler.zs:261, handler.zs:262, handler.zs:1605, CVARINFO.txt:44 | RS_ScoreHandler.StartLives; RS_ScoreNewGame.NewGame |
| H18 | Take a hit that would have killed you while you hold a Score life | handler.zs:1341, handler.zs:1408, tracker.zs:236, handler.zs:1411, handler.zs:1414, handler.zs:1428, handler.zs:1429, revive.zs:84, handler.zs:1430, revive.zs:233, handler.zs:1132, handler.zs:1438, handler.zs:1437, CVARINFO.txt:94 | RS_ScoreHandler.RunExtraLives; RS_ScoreTracker.NoteHit; RS_ScoreReviveFire.Begin; RS_ScoreReviveGuard |
| H19 | Die anyway while holding lives (a telefrag, forced damage) | handler.zs:1371, handler.zs:1374 | RS_ScoreHandler.RunExtraLives |
| H20 | Finish a map and start the next | handler.zs:237, handler.zs:286, handler.zs:294, handler.zs:295, handler.zs:299, CVARINFO.txt:35 | RS_ScoreHandler.PlayerEntered; ScoreReset |
| H21 | Walk over the gold life crate | lifecrate.zs:15, lifecrate.zs:100, lifecrate.zs:105, Miniboss/zscript/rsqmb/tierup.zs:146 | RSQ_ScoreLifeCrate.TryPickup |
| H22 | Shoot a monster in the head: the bullet's puff or the missile lands at or above its kin... | head.zs:300, head.zs:283, head.zs:445, head.zs:463, head.zs:100, head.zs:101, CVARINFO.txt:142, CVARINFO.txt:143, CVARINFO.txt:144 | RS_ScoreHead.VerdictAt; Judge; Outcome; DealPending; Route |
| H23 | Fire a gun | crit.zs:444, crit.zs:427, crit.zs:436, crit.zs:463, crit.zs:183, crit.zs:230, crit.zs:216, crit.zs:392, CVARINFO.txt:179, CVARINFO.txt:180, CVARINFO.txt:181, CVARINFO.txt:182, CVARINFO.txt:183, CVARINFO.txt:184, CVARINFO.txt:186 | RS_ScoreCritHandler.Roll; WorldThingSpawned; RollShot; CritBlow; RS_ScoreCritBrain.Land; RS_ScoreCritController.InitStun; ModifyDamage |
| H24 | Punch, saw or kick (a melee hitscan) | crit.zs:462, crit.zs:552 | RS_ScoreCritHandler.CritBlow; WorldHitscanPreFired |
| H25 | Make a kill that its row calls a big moment | handler.zs:700, handler.zs:701, handler.zs:711, handler.zs:746, handler.zs:742, CVARINFO.txt:71, CVARINFO.txt:72 | RS_ScoreHandler.BigMomentPulse |
| H26 | Look up at the top middle of your view | hud.zs:122, hud.zs:52, hud.zs:374, hud.zs:647, hud.zs:648, CVARINFO.txt:101, CVARINFO.txt:102, CVARINFO.txt:100, CVARINFO.txt:85 | RS_ScoreHUD.RenderOverlay; DrawLives; ColumnOf |
| H27 | Open any menu, or the automap | hud.zs:87, hud.zs:86 | RS_ScoreHUD.RenderOverlay |
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
| H41 | Make a melee kill that gibs the monster | melee.zs:350, melee.zs:352, melee.zs:354, melee.zs:355 | RS_Bonus_Cleaved.Evaluate |
| H42 | Make melee kills of different kinds within 4 s (saber, disc, bash, grind, blade, fist, ... | melee.zs:464, melee.zs:466, melee.zs:467, melee.zs:468, melee.zs:470, melee.zs:490 | RS_Bonus_Combo.Evaluate |
| H43 | Make a melee kill on a monster at least 2 units off the floor (not a flyer) that your p... | melee.zs:622, melee.zs:624, melee.zs:626, melee.zs:627 | RS_Bonus_Juggle.Evaluate |
| H44 | Punch, kick, push or whip a monster, then let the level or another monster kill it with... | melee.zs:713, melee.zs:715, melee.zs:717, melee.zs:718 | RS_Bonus_RingOut.Evaluate |
| H45 | Kill with a melee blow while the monster is in its Missile or Melee states, or within 1... | melee.zs:806, melee.zs:808, melee.zs:810, melee.zs:811 | RS_Bonus_Counter.Evaluate |
| H46 | Kill with a fist while the monster is in its Pain states | melee.zs:822, melee.zs:824, melee.zs:826, melee.zs:827 | RS_Bonus_Knockdown.Evaluate |
| H47 | Kill a monster that is 24 units or more above its floor (not a flyer, not standing on a... | physical.zs:454, physical.zs:456, physical.zs:457, physical.zs:459, physical.zs:460 | RS_Bonus_Skeet.Evaluate |
| H48 | Kill with a shot that leaves more than 60 degrees away from where your head faces | physical.zs:496, physical.zs:498, physical.zs:499, physical.zs:501, physical.zs:502 | RS_Bonus_NoLook.Evaluate |
| H49 | Kill with a shot while your eyes have no line to the monster and a point within 40 unit... | physical.zs:522, physical.zs:524, physical.zs:525, physical.zs:527, physical.zs:529 | RS_Bonus_BlindFire.Evaluate |
| H50 | Kill with a shot fired by the off hand's trigger alone | physical.zs:581, physical.zs:583, physical.zs:585, physical.zs:586 | RS_Bonus_OffHand.Evaluate |
| H51 | Kill with a shot from one hand's trigger within 1 s of a shot kill from the other hand's | physical.zs:731, physical.zs:733, physical.zs:734, physical.zs:736, physical.zs:742 | RS_Bonus_TwoGuns.Evaluate |
| H52 | Hit one monster with two or more different tools, no more than 3 s between moves, and k... | combo.zs:485, combo.zs:487, combo.zs:488, combo.zs:489, combo.zs:490, combo.zs:500, combo.zs:534 | RS_Bonus_Chain.Evaluate |
| H53 | Bring a new tool into a fight (kills no more than 10 s apart) once three or more are in... | hook.zs:195, hook.zs:200, hook.zs:201, hook.zs:202, hook.zs:203, hook.zs:205, hook.zs:249 | RS_Bonus_Variety.Evaluate |
| H54 | Make three or more kills in a row with one melee mod (fists, saber, ShieldSaw or whip),... | rows.zs:256, rows.zs:258, rows.zs:259, rows.zs:260, rows.zs:262, rows.zs:269 | RS_Row_WeaponMaster.Evaluate |
| H55 | Make a melee kill on a monster of 400 spawn health or more | rows.zs:289, rows.zs:291, rows.zs:292, rows.zs:294, rows.zs:295 | RS_Row_GiantSlayer.Evaluate |
| H56 | Make a melee kill while falling, your feet 34 units or more above the monster's head | rows.zs:305, rows.zs:307, rows.zs:308, rows.zs:310, rows.zs:311 | RS_Row_DeathFromAbove.Evaluate |
| H57 | Kill more than one monster with one blast, bolt or thrown thing inside 1 s, or with one... | rows.zs:358, rows.zs:360, rows.zs:362, rows.zs:389 | RS_Row_MultiKill.Evaluate |
| H58 | Make three or more shot kills while one trigger stays held | rows.zs:764, rows.zs:766, rows.zs:767, rows.zs:769, rows.zs:770 | RS_Row_HoldStreak.Evaluate |
| H59 | Hit a monster twice with a pistol within 10 tics; the second hit kills | rows.zs:791, rows.zs:793, rows.zs:795, rows.zs:796 | RS_Row_DoubleTap.Evaluate |
| H60 | Kill a monster from full health with one round of BrutalRevolver or Revolver | rows.zs:810, rows.zs:812, rows.zs:813, rows.zs:815, rows.zs:816 | RS_Row_HandCannon.Evaluate |
| H61 | Kill with a head shot (the killing blow itself) | rows.zs:830, rows.zs:832, rows.zs:833, rows.zs:835, rows.zs:836 | RS_Row_Headshot.Evaluate |
| H62 | Kill with a gun from 768 units or more, the shot within 2 degrees of where your head fa... | rows.zs:852, rows.zs:854, rows.zs:855, rows.zs:856, rows.zs:857, rows.zs:860, rows.zs:863, rows.zs:865 | RS_Row_SightsUp.Evaluate |
| H63 | Kill with a rocket's direct hit (the inflictor's class starts Rocket), not its splash | rows.zs:882, rows.zs:884, rows.zs:886, rows.zs:887 | RS_Row_DirectHit.Evaluate |
| H64 | Kill a monster of 400 spawn health or more with a chainsaw | rows.zs:918, rows.zs:920, rows.zs:922, rows.zs:923 | RS_Row_RipAndTear.Evaluate |
| H65 | Shoot a monster dead while it is in its attack and before its shot has left (none in th... | rows_panels.zs:181, rows_panels.zs:183, rows_panels.zs:184, rows_panels.zs:186, rows_panels.zs:193 | RS_RowPanel_JusticeShot.Evaluate |
| H66 | Let a monster's shot pass within 48 units of you without hurting you, then kill that mo... | rows_panels.zs:204, rows_panels.zs:206, rows_panels.zs:208, rows_panels.zs:209 | RS_RowPanel_ReadIt.Evaluate |
| H67 | Kill with a blow of damage type Fatality | melee.zs:340, melee.zs:342, melee.zs:344, melee.zs:345 | RS_Bonus_Fatality.Evaluate |
| H68 | Kill with a blow of damage type Kick, HeadKick or Stomp | melee.zs:641, melee.zs:643, melee.zs:645, melee.zs:646 | RS_Bonus_Boot.Evaluate |
| H69 | Swing hard enough that the second or third stacked blow of one swing kills | melee.zs:569, melee.zs:571, melee.zs:572, melee.zs:574, melee.zs:575 | RS_Bonus_HeavySwing.Evaluate |
| H70 | Kill with a nuke while you stand within 768 units and live | rows.zs:895, rows.zs:897, rows.zs:899, rows.zs:900 | RS_Row_DangerClose.Evaluate |
| H71 | Kill a monster of 1000 spawn health or more with the Unmaker | rows.zs:909, rows.zs:911, rows.zs:913, rows.zs:914 | RS_Row_Unmade.Evaluate |
| H72 | Kill with a thrown axe (class ThrowedAxe...) | rows.zs:928, rows.zs:930, rows.zs:932, rows.zs:933 | RS_Row_Tomahawk.Evaluate |
| H73 | Kill with a glove at the end of a run of punches, left and right in turn, each within 1... | melee.zs:836, melee.zs:838, melee.zs:839, melee.zs:841, melee.zs:842 | RS_Bonus_Flurry.Evaluate |
| H74 | Kill with an uppercut | rows.zs:113, rows.zs:115, rows.zs:117, rows.zs:118 | RS_Row_Shoryuken.Evaluate |
| H75 | Kill with a punch below the chest | rows.zs:123, rows.zs:125, rows.zs:127, rows.zs:128 | RS_Row_LiverShot.Evaluate |
| H76 | Kill with a punch in the top fifth of the body | rows.zs:136, rows.zs:138, rows.zs:140, rows.zs:141 | RS_Row_GlassJaw.Evaluate |
| H77 | Jab, jab, hook inside 1 s; the hook kills | rows.zs:145, rows.zs:147, rows.zs:149, rows.zs:150 | RS_Row_Textbook.Evaluate |
| H78 | Jab, hook, uppercut inside 1 s; the uppercut kills | rows.zs:154, rows.zs:156, rows.zs:158, rows.zs:159 | RS_Row_TripleThreat.Evaluate |
| H79 | Kill with the third or later of alternating hooks | rows.zs:165, rows.zs:167, rows.zs:168, rows.zs:170, rows.zs:171 | RS_Row_DempseyRoll.Evaluate |
| H80 | Punch dead a monster your uppercut launched, while it is in the air | rows.zs:180, rows.zs:182, rows.zs:184, rows.zs:185 | RS_Row_AirCombo.Evaluate |
| H81 | Kill with the Clear Out | rows.zs:194, rows.zs:196, rows.zs:198, rows.zs:199 | RS_Row_Bouncer.Evaluate |
| H82 | Kill with the Guard's release | rows.zs:203, rows.zs:205, rows.zs:207, rows.zs:208 | RS_Row_Release.Evaluate |
| H83 | Throw a monster out of the Headlock; its own landing kills it | rows.zs:212, rows.zs:214, rows.zs:216, rows.zs:217 | RS_Row_Toss.Evaluate |
| H84 | Kill with the Headlock Slam | rows.zs:225, rows.zs:227, rows.zs:229, rows.zs:230 | RS_Row_Piledriver.Evaluate |
| H85 | Kill with the Headlock Uppercut | rows.zs:235, rows.zs:237, rows.zs:239, rows.zs:240 | RS_Row_CutLoose.Evaluate |
| H86 | Kill with the gun-butt shove | rows.zs:244, rows.zs:246, rows.zs:248, rows.zs:249 | RS_Row_ButtStroke.Evaluate |
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
| H101 | Knock a monster into a wall so that the wall kills it (a punch, or the shield's slam) | rows.zs:1227, rows.zs:1229, rows.zs:1231, rows.zs:1232 | RS_Row_WallSplat.Evaluate |
| H102 | Throw a monster out of the Headlock so that it strikes and kills another | hook.zs:84, hook.zs:86, hook.zs:88, hook.zs:89 | RS_Bonus_Bowling.Evaluate |
| H103 | Choke a monster to death with the Force grip, or with the Headlock's Chokehold | melee.zs:587, melee.zs:589, melee.zs:591, melee.zs:592 | RS_Bonus_Choked.Evaluate |
| H104 | Fling a body out of the Force grip so that it dies hitting something | melee.zs:604, melee.zs:606, melee.zs:608, melee.zs:609 | RS_Bonus_Slammed.Evaluate |
| H105 | Force pull a monster, then kill it with a melee blow within 2 s | melee.zs:654, melee.zs:656, melee.zs:658, melee.zs:659 | RS_Bonus_PulledIn.Evaluate |
| H106 | Kill with a saber cut or throw while a saber is lit in each hand | melee.zs:670, melee.zs:672, melee.zs:674, melee.zs:675 | RS_Bonus_TwinBlades.Evaluate |
| H107 | Kill with the Force jump's landing, or with RSQ Melee's two-fist pound | melee.zs:727, melee.zs:729, melee.zs:731, melee.zs:739 | RS_Bonus_GroundPound.Evaluate |
| H108 | Kill with a lunging stab | rows.zs:415, rows.zs:417, rows.zs:419, rows.zs:420 | RS_Row_Lunge.Evaluate |
| H109 | Kill by drawing the blade out of an impaled monster | rows.zs:424, rows.zs:426, rows.zs:428, rows.zs:429 | RS_Row_Impaled.Evaluate |
| H110 | Turn a shot with crossed blades; it kills | rows.zs:434, rows.zs:436, rows.zs:438, rows.zs:439 | RS_Row_BackOff.Evaluate |
| H111 | Throw both sabers; each kills within 1 s of the other | rows.zs:444, rows.zs:446, rows.zs:447, rows.zs:449, rows.zs:450 | RS_Row_DoubleThrow.Evaluate |
| H112 | Kill with a stab | rows.zs:1183, rows.zs:1185, rows.zs:1187, rows.zs:1188 | RS_Row_RunThrough.Evaluate |
| H114 | Kill with Force Lightning | rows.zs:1192, rows.zs:1194, rows.zs:1196, rows.zs:1197 | RS_Row_UnlimitedPower.Evaluate |
| H115 | Kill a monster whose chain carries the tag "clash" | rows.zs:1201, rows.zs:1203, rows.zs:1205, rows.zs:1206 | RS_Row_ClashBreak.Evaluate |
| H116 | Knock a bolt back into RSQ Saber's training remote | awards.zs:23, awards.zs:26 | RS_Award_Deflect.Evaluate |
| H117 | Knock RSQ Saber's training remote out of the air | awards.zs:29, awards.zs:32 | RS_Award_RemoteDown.Evaluate |
| H118 | Kill with the thrown ShieldSaw disc or a thrown saber | melee.zs:365, melee.zs:367, melee.zs:368, melee.zs:369, melee.zs:371, melee.zs:379 | RS_Bonus_Hurled.Evaluate |
| H119 | Kill with the shield in the off hand: its bash, or its grind | melee.zs:396, melee.zs:398, melee.zs:399, melee.zs:401, melee.zs:402 | RS_Bonus_ShieldWork.Evaluate |
| H120 | Block a monster's attack with the shield or the saber, then kill it within 3 s | melee.zs:412, melee.zs:414, melee.zs:415, melee.zs:417, melee.zs:418 | RS_Bonus_Riposte.Evaluate |
| H121 | Make a perfect block, then kill that monster within 3 s | melee.zs:428, melee.zs:430, melee.zs:432, melee.zs:433 | RS_Bonus_PerfectRiposte.Evaluate |
| H122 | Kill with a shot you sent back | melee.zs:444, melee.zs:446, melee.zs:447, melee.zs:448, melee.zs:451, melee.zs:452 | RS_Bonus_ReturnToSender.Evaluate |
| H123 | Kill a monster with its own shot, sent back | melee.zs:506, melee.zs:508, melee.zs:510, melee.zs:511 | RS_Bonus_PoeticJustice.Evaluate |
| H124 | Kill with shots sent back one after another, each within 3 s | melee.zs:685, melee.zs:687, melee.zs:688, melee.zs:690, melee.zs:696 | RS_Bonus_Rally.Evaluate |
| H125 | Kill with a shot sent back a monster that did not fire it | rows.zs:340, rows.zs:342, rows.zs:344, rows.zs:345 | RS_Row_Misdirection.Evaluate |
| H126 | Kill on a throw's way home after the same throw killed on its way out | melee.zs:529, melee.zs:531, melee.zs:533, melee.zs:534 | RS_Bonus_Boomerang.Evaluate |
| H127 | Kill on a throw's way home when it did not kill on its way out | rows.zs:487, rows.zs:489, rows.zs:491, rows.zs:492 | RS_Row_Homecoming.Evaluate |
| H128 | Kill while your thrown saber or disc is still in flight (and is not what killed) | rows.zs:320, rows.zs:322, rows.zs:324, rows.zs:325 | RS_Row_Juggler.Evaluate |
| H129 | Stick the disc in a monster and let it grind it dead | melee.zs:552, melee.zs:554, melee.zs:556, melee.zs:557 | RS_Bonus_GroundDown.Evaluate |
| H130 | Throw the disc at two or more locks; it kills the last one standing | melee.zs:751, melee.zs:753, melee.zs:755, melee.zs:756 | RS_Bonus_CleanSweep.Evaluate |
| H131 | Kill a monster the disc locked after the throw (at a wall) | melee.zs:765, melee.zs:767, melee.zs:769, melee.zs:770 | RS_Bonus_BankShot.Evaluate |
| H132 | Kill while the shield in your off hand blocked another monster within 2048 units in the... | melee.zs:779, melee.zs:781, melee.zs:782, melee.zs:783, melee.zs:785, melee.zs:786 | RS_Bonus_ShieldWall.Evaluate |
| H133 | Kill while the shield blocked two or more other monsters in the last 2 s | rows.zs:511, rows.zs:513, rows.zs:514, rows.zs:515, rows.zs:516, rows.zs:517, rows.zs:519, rows.zs:520 | RS_Row_HoldTheLine.Evaluate |
| H134 | Kill with the bash that ends a Shield Dash | rows.zs:468, rows.zs:470, rows.zs:472, rows.zs:473 | RS_Row_ShieldDash.Evaluate |
| H135 | Grind dead a monster that was clawing your revving shield | rows.zs:477, rows.zs:479, rows.zs:481, rows.zs:482 | RS_Row_BitOffMore.Evaluate |
| H136 | Let the shield on your back block a monster, then kill it inside the chain's 3 s | rows.zs:502, rows.zs:504, rows.zs:506, rows.zs:507 | RS_Row_EyesInTheBack.Evaluate |
| H137 | Gib a monster with the disc on a kill tagged cleave.saw | rows.zs:539, rows.zs:541, rows.zs:543, rows.zs:544 | RS_Row_Cleaver.Evaluate |
| H138 | Grind a monster dead after 52 tics (1.5 s) or more of grinding | rows.zs:1211, rows.zs:1213, rows.zs:1214, rows.zs:1216, rows.zs:1217 | RS_Row_Buzzsaw.Evaluate |
| H139 | Kill with the whip's Wide Swing (a blow of damage type Whip from you) | hook.zs:139, hook.zs:141, hook.zs:143, hook.zs:144, tools.zs:277, melee.zs:114 | RS_Bonus_Lashed.Evaluate; RS_Tool.Classify; RS_Melee.KindFromTool |
| H269 | Kill two or more monsters with one Wide Swing of the whip | hook.zs:152, hook.zs:154, hook.zs:155, hook.zs:157, hook.zs:158, hook.zs:164, rows.zs:386, Whip/zscript/rsqwp/lash.zs:158 | RS_Bonus_WideSwing.Evaluate; Supersedes; RS_Row_MultiKill.Earlier; (Whip) RSQWP_Whip.Sweep |
| H270 | Crack the whip down at the ground (the Ground Crack), then kill a monster its shockwave caug... | hook.zs:173, hook.zs:175, hook.zs:176, hook.zs:178, hook.zs:179, hook.zs:183, hook.zs:186, combo.zs:365, tools.zs:36, melee.zs:249, Whip/zscript/rsqwp/lash.zs:249 | RS_Bonus_GroundCrack.Evaluate; Supersedes; RS_ComboLedger.SinceTool; RS_Tool.Canon; RS_Melee.Airborne; (Whip) RSQWP_Whip.GroundImpact |
| H271 | Hook a monster and fly to it; arriving is the kick, and the kick kills it | hook.zs:105, hook.zs:107, hook.zs:109, hook.zs:110, tools.zs:287, hook.zs:59, melee.zs:113, Grapple/zscript/rsqgr/core.zs:787, Grapple/zscript/rsqgr/core.zs:803 | RS_Bonus_HookKick.Evaluate; RS_Tool.Classify; RS_Grapple.KickNow; RS_Melee.KindFromTool; (Grapple) RSQGR_Core.Kick |
| H272 | Air-spike a hooked monster (both hands swung down in the air); the explosion where it lands... | hook.zs:118, hook.zs:120, hook.zs:121, hook.zs:123, hook.zs:124, hook.zs:127, hook.zs:65, tools.zs:288, Grapple/zscript/rsqgr/core.zs:622, Grapple/zscript/rsqgr/core.zs:666, Grenade/zscript/rsqgn/barrel.zs:186 | RS_Bonus_AirSpike.Evaluate; BigMoment; RS_Grapple.SpikedBy; RS_Tool.Classify; (Grapple) RSQGR_Core.StartSpike; SpikeImpact; (Grenade) RSQGN_NeonSpike.SetOff |
| H140 | Kill with a thing you threw with Distance Grab | physical.zs:372, physical.zs:374, physical.zs:375, physical.zs:376, physical.zs:377, physical.zs:379, physical.zs:380 | RS_Bonus_Thrown.Evaluate |
| H141 | Kill with the blast of a barrel your throw set off | physical.zs:394, physical.zs:396, physical.zs:397, physical.zs:398, physical.zs:399, physical.zs:401, physical.zs:414 | RS_Bonus_PowderKeg.Evaluate |
| H142 | Catch a thrown thing back out of the air, throw it again, and kill with it | physical.zs:435, physical.zs:437, physical.zs:438, physical.zs:439, physical.zs:441, physical.zs:442 | RS_Bonus_AirCatch.Evaluate |
| H143 | Kill with a shot while a hand carries something with Distance Grab | physical.zs:597, physical.zs:599, physical.zs:601, physical.zs:602 | RS_Bonus_FullHands.Evaluate |
| H144 | Kill with a corpse you threw | physical.zs:616, physical.zs:618, physical.zs:620, physical.zs:621 | RS_Bonus_BodyBlow.Evaluate |
| H145 | Kill with a thrown weapon that a dying monster dropped | physical.zs:632, physical.zs:634, physical.zs:636, physical.zs:637 | RS_Bonus_HandMeDown.Evaluate |
| H146 | Kill with a thrown thing of 100 kg or more | rows.zs:552, rows.zs:554, rows.zs:556, rows.zs:557 | RS_Row_HeavyThrow.Evaluate |
| H147 | Swing a thing you hold into a monster and kill it | rows.zs:1241, rows.zs:1243, rows.zs:1244, rows.zs:1246, rows.zs:1247 | RS_Row_Clubbed.Evaluate |
| H148 | Kill with a gun you threw | rows.zs:565, rows.zs:567, rows.zs:568, rows.zs:570, rows.zs:571 | RS_Row_Throwaway.Evaluate |
| H149 | Draw a gun from a holster and kill with a shot of it within 42 tics | physical.zs:471, physical.zs:473, physical.zs:474, physical.zs:477, physical.zs:478 | RS_Bonus_QuickDraw.Evaluate |
| H150 | Kill, draw a different gun from a holster within 3 s, and kill with it within 3 s of th... | physical.zs:649, physical.zs:651, physical.zs:652, physical.zs:654, physical.zs:655 | RS_Bonus_HotSwap.Evaluate |
| H151 | Draw the saber from a holster and kill with a saber blow within 42 tics | rows.zs:579, rows.zs:581, rows.zs:583, rows.zs:584 | RS_Row_Iaido.Evaluate |
| H152 | Draw a grenade from the rig and kill with a grenade within 3 s | rows.zs:600, rows.zs:602, rows.zs:603, rows.zs:605, rows.zs:606 | RS_Row_PinPulled.Evaluate |
| H153 | Kill with three different guns, each just drawn from a holster, inside 6 s | rows.zs:622, rows.zs:624, rows.zs:625, rows.zs:627, rows.zs:643 | RS_Row_Armory.Evaluate |
| H154 | Kill with a grenade cooked 1 s or more in the hand | rows.zs:665, rows.zs:667, rows.zs:668, rows.zs:669, rows.zs:671, rows.zs:672 | RS_Row_Cooked.Evaluate |
| H155 | Kill with a grenade that goes off 24 units or more above the floor (not in your hand) | rows.zs:682, rows.zs:684, rows.zs:685, rows.zs:687, rows.zs:688 | RS_Row_Airburst.Evaluate |
| H156 | Stick a Sticky grenade on a monster; its blast kills that monster | rows.zs:697, rows.zs:699, rows.zs:701, rows.zs:702 | RS_Row_Tagged.Evaluate |
| H157 | Kill with a grenade that goes off in your hand | rows.zs:706, rows.zs:708, rows.zs:709, rows.zs:711, rows.zs:712 | RS_Row_HoldMyBeer.Evaluate |
| H158 | Kill with a Cluster bomblet | rows.zs:721, rows.zs:723, rows.zs:725, rows.zs:726 | RS_Row_ClusterBomb.Evaluate |
| H159 | Turn a monster with an Infight or Charm grenade; it kills another | rows.zs:730, rows.zs:732, rows.zs:734, rows.zs:735 | RS_Row_CivilWar.Evaluate |
| H160 | Kill a monster your Flash or Smoke grenade touched inside the chain's 3 s | rows.zs:739, rows.zs:741, rows.zs:743, rows.zs:744 | RS_Row_Blindside.Evaluate |
| H161 | Kill with your Incendiary's fire | rows.zs:752, rows.zs:754, rows.zs:756, rows.zs:757 | RS_Row_Barbecue.Evaluate |
| H162 | Kill with your own grenade, shot in the air | rows.zs:1256, rows.zs:1258, rows.zs:1260, rows.zs:1261 | RS_Row_TrapShot.Evaluate |
| H163 | Kill with a grenade whose pin you pulled with your teeth | rows.zs:1266, rows.zs:1268, rows.zs:1270, rows.zs:1271 | RS_Row_Teeth.Evaluate |
| H164 | Kill with an Impact grenade's burst | rows.zs:1275, rows.zs:1277, rows.zs:1279, rows.zs:1280 | RS_Row_Contact.Evaluate |
| H165 | Kill while RSQ SlowMo has the world slowed | physical.zs:698, physical.zs:700, physical.zs:701, physical.zs:703, physical.zs:704 | RS_Bonus_BulletTime.Evaluate |
| H166 | Kill while the world speeds back up at the end of a slow motion | rows.zs:1286, rows.zs:1288, rows.zs:1290, rows.zs:1291 | RS_Row_LastGrain.Evaluate |
| H167 | (RSQ SlowMo's award "Revenge") | awards.zs:49, awards.zs:52 | RS_Award_Revenge.Evaluate |
| H169 | Kill the Boss you called in | awards.zs:40 | RS_Award_Miniboss.Evaluate |
| H170 | (RSQ Miniboss's award "Finisher") | awards.zs:57, awards.zs:60 | RS_Award_Finisher.Evaluate |
| H172 | Score anything while RSQ Miniboss's Rank is above 0 | awards.zs:64, awards.zs:67 | RS_Award_Rank.Evaluate |
| H173 | Kill RSQ Miniboss's thralls one after another, each within 12 s of the last | rows.zs:1141, rows.zs:1143, rows.zs:1145, rows.zs:1152, rows.zs:1146, rows.zs:1150 | RS_Row_ChainGang.Evaluate; Thrall; Earlier |
| H175 | Kill a monster that carries RSQ Miniboss's RSQMB_Rage | rows.zs:1172, rows.zs:1174, rows.zs:1176, rows.zs:1177 | RS_Row_RiotControl.Evaluate |
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
| H198 | Kill a Bronze champion with a melee blow | rows.zs:939, rows.zs:941, rows.zs:943, rows.zs:944 | RS_Row_ImmovableObject.Evaluate |
| H199 | Kill a Balloon champion with anything but a shot | rows.zs:948, rows.zs:950, rows.zs:952, rows.zs:953 | RS_Row_Pop.Evaluate |
| H200 | Gib a champion | rows.zs:961, rows.zs:963, rows.zs:965, rows.zs:966 | RS_Row_Pinata.Evaluate |
| H201 | Kill champions one after another, each within 5 s | rows.zs:970, rows.zs:972, rows.zs:973, rows.zs:974, rows.zs:976, rows.zs:982 | RS_Row_ChampionStreak.Evaluate |
| H202 | Kill an Orange champion with a melee blow or within 64 units | rows.zs:993, rows.zs:995, rows.zs:997, rows.zs:998 | RS_Row_TooClose.Evaluate |
| H203 | Kill a Black champion in one blow from full health | rows.zs:1006, rows.zs:1008, rows.zs:1010, rows.zs:1011 | RS_Row_GlassCannon.Evaluate |
| H204 | Kill a monster that carries a Gold champion's token and is no champion itself | rows.zs:1015, rows.zs:1017, rows.zs:1019, rows.zs:1020 | RS_Row_FoolsGold.Evaluate |
| H205 | Kill an Undying champion within 2 s of its heart | rows.zs:1024, rows.zs:1026, rows.zs:1027, rows.zs:1029, rows.zs:1030 | RS_Row_Heartbreaker.Evaluate |
| H206 | Kill a champion with a blow of type Fatality | rows.zs:1040, rows.zs:1042, rows.zs:1044, rows.zs:1045 | RS_Row_ChampionFatality.Evaluate |
| H207 | Kill champions of 5, 10 and all 14 colours in one map | rows.zs:1049, rows.zs:1052, rows.zs:1061 | RS_Row_Rainbow.Evaluate |
| H208 | Kill a LegenDoom legendary after it has risen | boost.zs:296, boost.zs:299, boost.zs:300 | RS_Bonus_Legendary.Evaluate |
| H209 | Kill a legendary before it rises | boost.zs:311, boost.zs:314, boost.zs:315 | RS_Bonus_LegendDenied.Evaluate |
| H210 | Kill a risen legendary whose champion powers are on | boost.zs:326, boost.zs:329, boost.zs:330 | RS_Bonus_LegendChampion.Evaluate |
| H211 | Kill a legendary in one blow from 3 x its spawn health | rows.zs:1087, rows.zs:1089, rows.zs:1091, rows.zs:1092 | RS_Row_OneTapLegend.Evaluate |
| H212 | Kill a risen legendary within 2 s of the first blow Score sees on it after it rose | rows.zs:1102, rows.zs:1104, rows.zs:1105, rows.zs:1107, rows.zs:1108 | RS_Row_StrikeWhileItRises.Evaluate |
| H213 | Kill two legendaries within 10 s | rows.zs:1118, rows.zs:1120, rows.zs:1121, rows.zs:1123, rows.zs:1124 | RS_Row_LegendSlayer.Evaluate |
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
| H256 | Kill a monster of 400 spawn health or more, or make a big-moment kill | handler.zs:748, handler.zs:756, handler.zs:757, handler.zs:758, handler.zs:725, CVARINFO.txt:80 | RS_ScoreHandler.BigMomentPulse; HitStopMs |
| H257 | In VR, look at your off hand | wrist.zs:19, wrist.zs:76, wrist.zs:83, wrist.zs:81, CVARINFO.txt:109 | RS_ScoreWrist.Show |
| H258 | Fill the reward bar | handler.zs:1053, handler.zs:1038, handler.zs:1039, handler.zs:1283, CVARINFO.txt:50 | RS_ScoreHandler.CheckRewards; RunAmmoRegen |
| H259 | Fill the reward bar | handler.zs:1025, hud.zs:266 | RS_ScoreHandler.CheckRewards; RS_ScoreHUD.DrawBar |
| H260 | Finish a map and start the next | handler.zs:292, handler.zs:294, handler.zs:295, handler.zs:71 | RS_ScoreHandler.ScoreReset; WorldLoaded |
| H261 | Take a killing hit while you hold a life | revive.zs:85, handler.zs:1573 | RS_ScoreReviveFire.Begin; RS_ScoreHandler.ReviveFire |
| H262 | Fill the reward bar, or take a killing hit while you hold a life | handler.zs:1082, handler.zs:1431, CVARINFO.txt:91, CVARINFO.txt:95, CVARINFO.txt:88 | RS_ScoreHandler.CheckRewards; RunExtraLives |
| H263 | Shoot a monster in the head | head.zs:441, combo.zs:162 | RS_ScoreHead.Outcome; RS_ComboLedger.CondOf |
| H264 | Fire a gun | crit.zs:112 | RS_ScoreCritBrain.ModifyDamage |
| H265 | Kill anything | hud.zs:100, hud.zs:101, hud.zs:102 | RS_ScoreHUD.RenderOverlay |
| H266 | Kill anything | hud.zs:105 | RS_ScoreHUD.RenderOverlay |
| H267 | Kill a roster monster | rows_roster.zs:141, rows_roster.zs:155 | RS_RosterRow.Evaluate; RS_RosterTierRow.Evaluate |
| H268 | Kill with many bonuses of one family | handler.zs:636, CVARINFO.txt:54 | RS_ScoreHandler.AwardKiller |

## How to play: the named combos

Each named combo is one line of the two tables. The words of the legend above the README's combo table: `tools.zs:145` to `tools.zs:161` (RS_Tool.InGroup: the groups), `tools.zs:183` to `tools.zs:185` (RS_Tool.StepMatches: `+air`, `+pb`, `+head`), `combo.zs:152` (RS_ComboLedger.CondOf: `@slow` is the player's own slow motion), `boost.zs:132` to `boost.zs:139` (RS_Boost.VictimIs: the words after `|`), `combo.zs:94` (the 3 s gap), `combo.zs:471` (the last step is the killing blow), `combo.zs:585` (the best match).

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| K1 | Lion Tamer: whip > shield.bash, 0.5 | combo.zs:65 | RS_ComboSeed.Combos |
| K2 | Clay Pigeon: force.push > gun, 0.5 | combo.zs:66 | RS_ComboSeed.Combos |
| K3 | Sitting Duck: force.grip > gun, 0.5 | combo.zs:67 | RS_ComboSeed.Combos |
| K4 | Pull!: force.pull > gun, 0.5 | combo.zs:68 | RS_ComboSeed.Combos |
| K5 | Disc Jockey: force.push > shield.disc, 0.5 | combo.zs:69 | RS_ComboSeed.Combos |
| K6 | Gun Kata: hands > gun, 0.4 | combo.zs:70 | RS_ComboSeed.Combos |
| K7 | Fast Hands: melee > rig.draw, 0.5 | combo.zs:71 | RS_ComboSeed.Combos |
| K9 | Pitch and Slice: grab.throw > saber.cut, 0.5 | combo.zs:72 | RS_ComboSeed.Combos |
| K11 | Yo-Yo: force.pull > force.push > gun, 0.9 | combo.zs:74 | RS_ComboSeed.Combos |
| K12 | Discus: shield.bash > force.push > shield.disc, 0.9 | combo.zs:75 | RS_ComboSeed.Combos |
| K13 | Headlock: grab.hold > hands, 0.5 | combo.zs:79 | RS_ComboSeed.Combos |
| K14 | F.E.A.R. Effect: shove > gun.shotgun@slow, 0.6 | combo.zs:83 | RS_ComboSeed.Combos |
| K15 | Trap Shooter: glove.upper > gun.shotgun, 0.5 | combos.zs:30 | RS_ComboTable.Add |
| K16 | Rising Dragon: glove.upper > saber.cut, 0.5 | combos.zs:31 | RS_ComboTable.Add |
| K17 | Spike: glove.upper > shield.disc, 0.5 | combos.zs:32 | RS_ComboTable.Add |
| K19 | Air Lash: glove.upper > whip.crack, 0.5 | combos.zs:33 | RS_ComboTable.Add |
| K20 | Alley-Oop: glove.upper > grab.throw, 0.5 | combos.zs:34 | RS_ComboTable.Add |
| K21 | Air Mail: glove.upper > grenade, 0.5 | combos.zs:35 | RS_ComboTable.Add |
| K22 | Fireworks: glove.upper > gun.explosive, 0.5 | combos.zs:36 | RS_ComboTable.Add |
| K23 | One-Two-Skeet: glove > glove.upper > gun.shotgun, 0.9 | combos.zs:37 | RS_ComboTable.Add |
| K24 | Cross Cut: glove.hook > saber.cut, 0.4 | combos.zs:38 | RS_ComboTable.Add |
| K25 | Fist and Shield: glove > shield.bash, 0.4 | combos.zs:39 | RS_ComboTable.Add |
| K26 | Knuckle Crack: glove > whip.crack, 0.4 | combos.zs:40 | RS_ComboTable.Add |
| K27 | Jedi Jab: glove > force.push, 0.4 | combos.zs:41 | RS_ComboTable.Add |
| K28 | Punch and Pitch: glove > shield.disc, 0.4 | combos.zs:42 | RS_ComboTable.Add |
| K29 | Slow Trap Shooter: glove.upper@slow > gun.shotgun, 0.55 | combos.zs:43 | RS_ComboTable.Add |
| K30 | Feint: glove.jab > saber.stab, 0.45 | combos.zs:44 | RS_ComboTable.Add |
| K31 | Skyskewer: glove.upper > saber.stab, 0.55 | combos.zs:45 | RS_ComboTable.Add |
| K32 | Pistol Whip: shove > gun.pistol, 0.5 | combos.zs:47 | RS_ComboTable.Add |
| K33 | Executioner: shove > gun+head, 0.6 | combos.zs:49 | RS_ComboTable.Add |
| K34 | Riot Shield: shove > shield.bash, 0.5 | combos.zs:50 | RS_ComboTable.Add |
| K35 | Make Room: shove > saber.cut, 0.4 | combos.zs:51 | RS_ComboTable.Add |
| K36 | Fire in the Hole: shove > grenade, 0.45 | combos.zs:52 | RS_ComboTable.Add |
| K37 | Backlash: shove > whip.crack, 0.4 | combos.zs:53 | RS_ComboTable.Add |
| K38 | Street Fighter: hadouken > glove.upper, 0.6 | combos.zs:55 | RS_ComboTable.Add |
| K39 | Shoto: hadouken > saber.cut, 0.5 | combos.zs:56 | RS_ComboTable.Add |
| K40 | Return Fire: hadouken > shove > gun.shotgun, 1 | combos.zs:57 | RS_ComboTable.Add |
| K41 | Neo: hadouken@slow > glove, 0.6 | combos.zs:58 | RS_ComboTable.Add |
| K42 | Backhand Spring: swat > glove.upper > gun.pistol, 1 | combos.zs:59 | RS_ComboTable.Add |
| K43 | Parry Punish: guard.parry > any, 0.5 | combos.zs:60 | RS_ComboTable.Add |
| K44 | Counter Cut: guard.parry > saber, 0.6 | combos.zs:61 | RS_ComboTable.Add |
| K45 | Knuckle Sandwich: guard.parry > glove, 0.55 | combos.zs:62 | RS_ComboTable.Add |
| K46 | Dragon Fist: guard.parry > glove.upper > glove, 0.9 | combos.zs:63 | RS_ComboTable.Add |
| K47 | Pressure Valve: guard.release > glove, 0.5 | combos.zs:64 | RS_ComboTable.Add |
| K48 | Hostage: grab.hold > gun.pistol, 0.5 | combos.zs:66 | RS_ComboTable.Add |
| K49 | Close Quarters: grab.hold > gun.shotgun, 0.5 | combos.zs:67 | RS_ComboTable.Add |
| K50 | Hold This: grab.hold > grenade, 0.6 | combos.zs:68 | RS_ComboTable.Add |
| K51 | Execution: grab.hold > saber, 0.5 | combos.zs:69 | RS_ComboTable.Add |
| K52 | Suplex: grab.hold > headlock.throw, 0.5 | combos.zs:70 | RS_ComboTable.Add |
| K53 | Flog: grab.hold > whip.crack, 0.5 | combos.zs:71 | RS_ComboTable.Add |
| K54 | Title Belt: grab.hold > hands \| champ, 0.6 | combos.zs:72 | RS_ComboTable.Add |
| K55 | Bouncer: grab.hold > hands > gun.shotgun, 0.9 | combos.zs:73 | RS_ComboTable.Add |
| K56 | Choke and Cut: grab.hold > headlock.choke > saber.cut, 0.9 | combos.zs:74 | RS_ComboTable.Add |
| K57 | Slam and Blam: grab.hold > headlock.slam > gun.shotgun, 0.9 | combos.zs:75 | RS_ComboTable.Add |
| K58 | Clay Toss: headlock.throw > gun.shotgun, 0.5 | combos.zs:76 | RS_ComboTable.Add |
| K59 | Ground and Pound: headlock.slam > glove, 0.5 | combos.zs:77 | RS_ComboTable.Add |
| K60 | Pin Down: headlock.slam > saber.stab, 0.55 | combos.zs:78 | RS_ComboTable.Add |
| K61 | Come Get Some: taunt > hands, 0.4 | combos.zs:80 | RS_ComboTable.Add |
| K62 | Come Closer: taunt > gun.shotgun, 0.5 | combos.zs:81 | RS_ComboTable.Add |
| K63 | Tremor: pound > gun.shotgun, 0.45 | combos.zs:82 | RS_ComboTable.Add |
| K64 | Quake: pound > shield.bash, 0.4 | combos.zs:83 | RS_ComboTable.Add |
| K65 | Get Back!: clearout > grenade, 0.5 | combos.zs:84 | RS_ComboTable.Add |
| K66 | Spread Out: clearout > gun.explosive, 0.45 | combos.zs:85 | RS_ComboTable.Add |
| K67 | Laser Sword: saber.cut > gun.energy, 0.5 | combos.zs:88 | RS_ComboTable.Add |
| K68 | Blade and Buckshot: saber.cut > gun.shotgun, 0.45 | combos.zs:89 | RS_ComboTable.Add |
| K69 | Edge and Board: saber.cut > shield.bash, 0.4 | combos.zs:90 | RS_ComboTable.Add |
| K70 | Pommel: saber.cut > glove, 0.4 | combos.zs:91 | RS_ComboTable.Add |
| K71 | Slash and Blast: saber.cut > force.push > gun.shotgun, 0.9 | combos.zs:92 | RS_ComboTable.Add |
| K72 | Distraction: saber.throw > glove, 0.5 | combos.zs:93 | RS_ComboTable.Add |
| K73 | Covering Fire: saber.throw > gun.rifle, 0.45 | combos.zs:94 | RS_ComboTable.Add |
| K74 | Air Traffic: saber.throw > shield.disc, 0.5 | combos.zs:95 | RS_ComboTable.Add |
| K75 | Throw and Go: saber.throw > saber.cut, 0.4 | combos.zs:96 | RS_ComboTable.Add |
| K76 | Return Flight: saber.throw > force.pull > saber.cut, 0.9 | combos.zs:97 | RS_ComboTable.Add |
| K77 | Helpless: force.grip > saber.cut, 0.5 | combos.zs:98 | RS_ComboTable.Add |
| K78 | Hung Out to Dry: force.grip > glove, 0.5 | combos.zs:99 | RS_ComboTable.Add |
| K79 | Special Delivery: force.grip > grenade, 0.5 | combos.zs:100 | RS_ComboTable.Add |
| K80 | Pinned: force.grip > shield.disc, 0.5 | combos.zs:101 | RS_ComboTable.Add |
| K81 | Strung Up: force.grip > whip.crack, 0.5 | combos.zs:102 | RS_ComboTable.Add |
| K82 | Exorcism: force.grip > saber.cut \| Ghost, 0.6 | combos.zs:103 | RS_ComboTable.Add |
| K83 | Jedi Brawler: force.grip > glove > saber.cut, 0.9 | combos.zs:104 | RS_ComboTable.Add |
| K84 | Superhero Landing: force.jump > glove, 0.5 | combos.zs:105 | RS_ComboTable.Add |
| K85 | Leap Strike: force.jump > saber.cut, 0.5 | combos.zs:106 | RS_ComboTable.Add |
| K86 | Come Here, Go Up: force.pull > glove.upper > gun.shotgun, 0.9 | combos.zs:107 | RS_ComboTable.Add |
| K87 | Force Arrest: force.pull > grab.hold > glove, 0.9 | combos.zs:108 | RS_ComboTable.Add |
| K88 | Jedi Hoplite: force.pull > shield.bash > saber.cut, 0.9 | combos.zs:109 | RS_ComboTable.Add |
| K89 | Clay Saber: force.push > saber.throw, 0.5 | combos.zs:110 | RS_ComboTable.Add |
| K91 | Hot Seat: force.push > grab.keg, 0.5 | combos.zs:111 | RS_ComboTable.Add |
| K92 | Scoundrel: force.push > saber.throw > gun.pistol, 0.9 | combos.zs:112 | RS_ComboTable.Add |
| K93 | Push-Pull: force.push > force.pull > saber.cut, 0.9 | combos.zs:113 | RS_ComboTable.Add |
| K94 | Time Slash: force.push@slow > saber.cut, 0.55 | combos.zs:114 | RS_ComboTable.Add |
| K95 | Off the Blade: saber.stab > force.push, 0.5 | combos.zs:115 | RS_ComboTable.Add |
| K96 | Stab and Jab: saber.stab > glove, 0.4 | combos.zs:116 | RS_ComboTable.Add |
| K97 | Shock and Awe: force.lightning > glove, 0.5 | combos.zs:117 | RS_ComboTable.Add |
| K98 | Sith Ambush: force.lightning > saber.cut, 0.5 | combos.zs:118 | RS_ComboTable.Add |
| K99 | Overcharge: force.lightning > gun.energy, 0.5 | combos.zs:119 | RS_ComboTable.Add |
| K100 | Riot Control: shield.bash > gun.shotgun, 0.5 | combos.zs:122 | RS_ComboTable.Add |
| K101 | Bash and Slash: shield.bash > saber.cut, 0.5 | combos.zs:123 | RS_ComboTable.Add |
| K103 | Bash and Lash: shield.bash > whip.crack, 0.4 | combos.zs:124 | RS_ComboTable.Add |
| K104 | Shield and Fist: shield.bash > glove, 0.4 | combos.zs:125 | RS_ComboTable.Add |
| K105 | Crack the Shell: shield.bash > blade \| armoured, 0.55 | combos.zs:126 | RS_ComboTable.Add |
| K106 | Bash and Launch: shield.bash > glove.upper > gun.shotgun, 0.9 | combos.zs:127 | RS_ComboTable.Add |
| K107 | Shield Up: shield.block > grenade, 0.5 | combos.zs:128 | RS_ComboTable.Add |
| K108 | This Is Sparta: shield.block > shield.bash > saber, 0.9 | combos.zs:129 | RS_ComboTable.Add |
| K109 | Riot Squad: shield.block > shield.bash > gun.shotgun, 0.9 | combos.zs:130 | RS_ComboTable.Add |
| K110 | Shield Uppercut: shield.block > shield.bash > glove.upper, 1 | combos.zs:131 | RS_ComboTable.Add |
| K111 | Slow Sparta: shield.block@slow > shield.bash > saber.cut, 1 | combos.zs:132 | RS_ComboTable.Add |
| K115 | Saw and Saber: shield.disc > saber.cut, 0.5 | combos.zs:133 | RS_ComboTable.Add |
| K116 | Crossfire: shield.disc > saber.throw, 0.5 | combos.zs:134 | RS_ComboTable.Add |
| K117 | Follow-Through: shield.disc > glove, 0.4 | combos.zs:135 | RS_ComboTable.Add |
| K118 | Throw and Follow: shield.disc > shield.bash, 0.4 | combos.zs:136 | RS_ComboTable.Add |
| K119 | Cleanup Crack: shield.disc > whip.crack, 0.4 | combos.zs:137 | RS_ComboTable.Add |
| K121 | Sawblade Send-Off: shield.grind > force.push > shield.disc, 0.9 | combos.zs:138 | RS_ComboTable.Add |
| K123 | Hoplite: shield.bash > saber.stab, 0.55 | combos.zs:139 | RS_ComboTable.Add |
| K124 | Nailed: shield.slam > saber.stab, 0.55 | combos.zs:140 | RS_ComboTable.Add |
| K125 | Up Against the Wall: shield.slam > glove, 0.5 | combos.zs:141 | RS_ComboTable.Add |
| K127 | Frontier: whip.crack > gun.pistol, 0.5 | combos.zs:144 | RS_ComboTable.Add |
| K128 | High Noon: whip.crack > rig.draw, 0.6 | combos.zs:145 | RS_ComboTable.Add |
| K129 | Zorro: whip.crack > saber, 0.5 | combos.zs:146 | RS_ComboTable.Add |
| K130 | Big Top: whip.crack > shield.disc, 0.55 | combos.zs:147 | RS_ComboTable.Add |
| K131 | Crack and Smack: whip.crack > glove, 0.4 | combos.zs:148 | RS_ComboTable.Add |
| K132 | Crack of Doom: whip.crack > any \| legend.dormant, 0.6 | combos.zs:149 | RS_ComboTable.Add |
| K133 | Bullet Ballet: whip.crack@slow > gun, 0.9 | combos.zs:150 | RS_ComboTable.Add |
| K184 | Catch This: grab.throw > glove, 0.45 | combos.zs:155 | RS_ComboTable.Add |
| K185 | Batter Up: grab.throw > gun, 0.35 | combos.zs:156 | RS_ComboTable.Add |
| K187 | Serve and Volley: grab.throw > shield.bash, 0.45 | combos.zs:157 | RS_ComboTable.Add |
| K188 | Two Throws: grab.throw > shield.disc, 0.45 | combos.zs:158 | RS_ComboTable.Add |
| K189 | Toss and Crack: grab.throw > whip.crack, 0.45 | combos.zs:159 | RS_ComboTable.Add |
| K190 | Kitchen Sink: grab.throw > grenade > gun, 1 | combos.zs:160 | RS_ComboTable.Add |
| K192 | Aftershock: grab.keg > melee, 0.5 | combos.zs:161 | RS_ComboTable.Add |
| K194 | Into the Breach: grenade > melee, 0.45 | combos.zs:164 | RS_ComboTable.Add |
| K195 | Mop Up: grenade > gun, 0.3 | combos.zs:165 | RS_ComboTable.Add |
| K197 | Shell Shock: grenade > glove, 0.5 | combos.zs:166 | RS_ComboTable.Add |
| K198 | Frag and Slash: grenade > saber.cut, 0.5 | combos.zs:167 | RS_ComboTable.Add |
| K199 | Demolition: grenade > grab.keg > gun, 1 | combos.zs:168 | RS_ComboTable.Add |
| K200 | Ice Breaker: grenade.freeze > glove, 0.55 | combos.zs:169 | RS_ComboTable.Add |
| K201 | Cold Cut: grenade.freeze > saber.cut, 0.55 | combos.zs:170 | RS_ComboTable.Add |
| K202 | Cold Shoulder: grenade.freeze > shield.bash, 0.55 | combos.zs:171 | RS_ComboTable.Add |
| K204 | Ice Pop: grenade.freeze > glove.upper > gun.shotgun, 1 | combos.zs:172 | RS_ComboTable.Add |
| K205 | Dazed and Confused: grenade.stun > glove, 0.55 | combos.zs:173 | RS_ComboTable.Add |
| K206 | Stun and Gun: grenade.stun > gun, 0.45 | combos.zs:174 | RS_ComboTable.Add |
| K208 | Dizzy Finish: grenade.stun > glove > fatality, 1 | combos.zs:175 | RS_ComboTable.Add |
| K210 | Lights Out: grenade.flash > melee, 0.5 | combos.zs:176 | RS_ComboTable.Add |
| K211 | Blind Side: grenade.flash > saber, 0.55 | combos.zs:177 | RS_ComboTable.Add |
| K214 | Out of the Smoke: grenade.smoke > melee, 0.5 | combos.zs:178 | RS_ComboTable.Add |
| K215 | Ninja: grenade.smoke > saber.stab, 0.55 | combos.zs:179 | RS_ComboTable.Add |
| K216 | Batting Practice: grab.swing > gun, 0.4 | combos.zs:180 | RS_ComboTable.Add |
| K217 | Ghost Hold: grenade.smoke > grab.hold > blade, 1 | combos.zs:181 | RS_ComboTable.Add |
| K218 | Pin Cushion: grenade.sticky > gun, 0.45 | combos.zs:182 | RS_ComboTable.Add |
| K220 | Return to the Pack: grenade.sticky > force.push > grenade, 0.9 | combos.zs:183 | RS_ComboTable.Add |
| K221 | Hot Lash: grenade.fire > whip.crack, 0.5 | combos.zs:184 | RS_ComboTable.Add |
| K222 | Fan the Flames: grenade.fire > force.push > gun.fire, 0.9 | combos.zs:185 | RS_ComboTable.Add |
| K223 | Rocket Punch: gun.explosive > glove, 0.5 | combos.zs:188 | RS_ComboTable.Add |
| K224 | Over-Under: gun.explosive > gun.rifle, 0.4 | combos.zs:189 | RS_ComboTable.Add |
| K225 | Mop-Up Saw: gun.explosive > blade.saw, 0.5 | combos.zs:190 | RS_ComboTable.Add |
| K226 | Hot Hands: gun.fire > glove, 0.5 | combos.zs:191 | RS_ComboTable.Add |
| K227 | Fire Whip: gun.fire > whip.crack, 0.45 | combos.zs:192 | RS_ComboTable.Add |
| K228 | Plasma Blade: gun.energy > saber.cut, 0.45 | combos.zs:193 | RS_ComboTable.Add |
| K229 | Shoot and Snap: gun.pistol > whip.crack, 0.4 | combos.zs:194 | RS_ComboTable.Add |
| K230 | Buckshot Brawl: gun.shotgun > glove, 0.4 | combos.zs:195 | RS_ComboTable.Add |
| K231 | Clean Up: gun.shotgun > saber.cut, 0.4 | combos.zs:196 | RS_ComboTable.Add |
| K232 | Suppress and Storm: gun.rifle > shield.bash, 0.45 | combos.zs:197 | RS_ComboTable.Add |
| K233 | Rip and Pump: blade.saw > gun.shotgun, 0.4 | combos.zs:198 | RS_ComboTable.Add |
| K234 | Door Kick: kick > gun.shotgun+pb, 0.5 | combos.zs:199 | RS_ComboTable.Add |
| K235 | Showdown: rig.draw@slow > gun, 0.9 | combos.zs:202 | RS_ComboTable.Add |
| K236 | Draw and Shove Off: rig.draw > force.push > gun.pistol, 0.9 | combos.zs:203 | RS_ComboTable.Add |
| K237 | Tuco: throw.gun > rig.draw, 0.5 | combos.zs:204 | RS_ComboTable.Add |
| K238 | Slip and Shoot: lean > gun, 0.4 | combos.zs:205 | RS_ComboTable.Add |
| K239 | Bob and Weave: lean > hands, 0.5 | combos.zs:206 | RS_ComboTable.Add |
| K240 | Tennis: return > return, 0.5 | combos.zs:207 | RS_ComboTable.Add |
| K241 | Volley: return > return > return, 1 | combos.zs:208 | RS_ComboTable.Add |
| K242 | Kingslayer: any@slow > any \| miniboss, 0.5 | combos.zs:209 | RS_ComboTable.Add |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQ Score's own service, `RS_ScoreService`: Score answers by service name | awards.zs:71, awards.zs:75, awards.zs:87, awards.zs:96, awards.zs:110, awards.zs:129, awards.zs:130, awards.zs:131, awards.zs:136, awards.zs:144, awards.zs:153, awards.zs:162, awards.zs:179, awards.zs:184, awards.zs:187, awards.zs:188, awards.zs:195, awards.zs:244, awards.zs:245, awards.zs:246, awards.zs:247, awards.zs:248, awards.zs:249, awards.zs:250, awards.zs:251, awards.zs:213, awards.zs:214, awards.zs:224, awards.zs:235 | RS_ScoreService.GetInt; GetString; GetObject; GetIntUI; Read |
| W2 | Any mod that links Score: the registry and the engine score field | bonus.zs:308, bonus.zs:187, bonus.zs:197, handler.zs:829 | RS_ScoreRegistry; RS_ScoreHandler.Pay |
| W3 | RSQ Grapple: the three names asked of RSQGR_Service; its two blows as tools | svc.zs:21, hook.zs:51, hook.zs:59, hook.zs:65, tools.zs:287, tools.zs:288, tools.zs:110, Grapple/zscript/rsqgr/service.zs:81, Grapple/zscript/rsqgr/service.zs:82, Grapple/zscript/rsqgr/service.zs:83 | RS_Svc.NameOf; RS_Grapple.Ask; KickNow; SpikedBy; RS_Tool.Classify; ModOf; (Grapple) RSQGR_Service.GetInt |
| W4 | RSQ ShieldSaw: names asked of SSQ_ScoreService | svc.zs:22, combo.zs:315, combo.zs:317, melee.zs:284, melee.zs:520, melee.zs:225, melee.zs:560, rows.zs:1220, melee.zs:926, melee.zs:928, melee.zs:163, tools.zs:68 | RS_Svc.NameOf; RS_ComboLedger.Poll; RS_Melee.ReturnedOf; ThrownLeg; ShieldInHand; RS_ScoreShots.Classes; RS_Tool.IsTag |
| W5 | RSQ Saber: names asked of UBQS_SaberService | svc.zs:23, combo.zs:307, combo.zs:309, combo.zs:310, combo.zs:312, melee.zs:296, melee.zs:205, tools.zs:263, tools.zs:264, tools.zs:274, tools.zs:329, wrist.zs:57, tools.zs:66, awards.zs:26, awards.zs:32 | RS_Svc.NameOf; RS_ComboLedger.Poll; RS_Melee.SaberLit; AskAny; RS_Tool.Classify; IsTag; RS_ScoreWrist.FindGlyphs |
| W6 | RSQ Distance Grab: names asked of RSQDG_ThrowService | svc.zs:24, physical.zs:148, physical.zs:384, physical.zs:385, physical.zs:445, rows.zs:560, physical.zs:605, rows.zs:1249, lifecrate.zs:55, lifecrate.zs:60 | RS_Svc.NameOf; RS_Physical.ThrownBy; RS_Bonus_Thrown; RS_Bonus_AirCatch; RS_Row_HeavyThrow; RS_Bonus_FullHands; RS_Row_Clubbed; RSQ_ScoreLifeCrate.GrabRule |
| W7 | RSQ Tactical Rig: names asked of RSQTR_RigService | svc.zs:25, physical.zs:488, physical.zs:490, tools.zs:45, tools.zs:77 | RS_Svc.NameOf; RS_Bonus_QuickDraw.Evaluate; RS_Tool.Canon; IsTag |
| W8 | RSQ SlowMo: names asked of RSQSM_Service | svc.zs:26, physical.zs:104, physical.zs:105, physical.zs:710, physical.zs:714, rows.zs:1294, handler.zs:1325, handler.zs:1398, hud.zs:184, handler.zs:1168, handler.zs:1123, handler.zs:1439, handler.zs:1130, handler.zs:1131, handler.zs:753, tools.zs:159, handler.zs:914, rows_panels.zs:96 | RS_Svc.NameOf; RS_Physical.SlowKind; RS_Bonus_BulletTime.AfterOthers; RS_Row_LastGrain; RS_ScoreHandler.DownHolds; RunExtraLives; SlowMoReward; RunRewardCue; HitStopMs; AwardExternal; RS_ScoreHUD.CountdownShift; RS_ScorePanels.WorldThingSpawned |
| W9 | RSQ Whip: the damage type Whip and the touch ground.crack; RSQWP_Service is not asked | tools.zs:277, tools.zs:36, tools.zs:109, tools.zs:94, svc.zs:15, Whip/zscript/rsqwp/whip.zs:1330, Whip/zscript/rsqwp/lash.zs:249 | RS_Tool.Classify; Canon; ModOf; ActionOf; RS_Svc; (Whip) RSQWP_Whip.DmgType; GroundImpact |
| W10 | RSQ Melee: names asked of RSQML_Service | svc.zs:27, tools.zs:350, melee.zs:816, rows.zs:131, rows.zs:141, rows.zs:150, rows.zs:174, rows_melee2.zs:195, rows.zs:188, tools.zs:321, melee.zs:1214, rows_melee2.zs:136, rows_melee2.zs:66, rows_melee2.zs:151, rows_melee2.zs:234, melee.zs:307, tools.zs:313, rows_melee2.zs:218, tools.zs:39, tools.zs:57, handler.zs:895, combo.zs:83 | RS_Svc.NameOf; RS_Tool.GloveKind; Classify; Canon; IsTag; RS_Bonus_Counter; RS_Rows.Punch callers; RS_ScoreShots.LaunchedBy; RS_Melee2.Ask callers; RS_Melee.IsGlove; RS_ScoreHandler.AwardExternal |
| W11 | RSQ Grenade: names asked of RSQGN_Service | svc.zs:28, handler.zs:423, combo.zs:139, combo.zs:140, combo.zs:141, rows.zs:675, tools.zs:279, tools.zs:280, tools.zs:281, tools.zs:288, tools.zs:25, tools.zs:32 | RS_Svc.NameOf; RS_ScoreHandler.WorldThingDied; RS_ComboLedger.WorldThingDamaged; RS_Row_Cooked; RS_Tool.Classify; Canon |
| W12 | RSQ Miniboss: names asked of RSQMB_Service | svc.zs:29, handler.zs:775, handler.zs:251, gold.zs:118, gold.zs:119, hud.zs:186, boost.zs:137, boost.zs:138, rows.zs:1146, rows.zs:1177, handler.zs:906, handler.zs:908, awards.zs:60, Miniboss/zscript/rsqmb/tierup.zs:146 | RS_Svc.NameOf; RS_ScoreHandler.RankMult; RankLife; AwardExternal; RS_Row_ChainGang.Thrall; RS_Row_RiotControl; RS_ScoreGold.WorldTick; RS_Boost.VictimIs; RS_ScoreHUD.CountdownShift |
| W13 | RSQ Monsters: names asked of RSQMN_RosterService | svc.zs:30, rows_roster.zs:53, rows_roster.zs:54, rows_roster.zs:218, rows_roster.zs:300, rows_roster.zs:319, rows_roster.zs:321, rows_roster.zs:52 | RS_Svc.NameOf; RS_Roster |
| W14 | RSQ VisualRewards: names asked of RSQVR_Service | handler.zs:1146, handler.zs:1147, handler.zs:1154, handler.zs:1161, handler.zs:1114, handler.zs:1441, handler.zs:1446, handler.zs:1118, hud.zs:349, hud.zs:189 | RS_ScoreHandler.Banner; Toast; WorldWord; RunRewardCue; RunExtraLives; RS_ScoreHUD.DrawLives; CountdownShift |
| W15 | RSQ Glow In The Dark: name asked of RSQGD_Service | handler.zs:1174, handler.zs:1175, handler.zs:1133 | RS_ScoreHandler.GlowFlash |
| W16 | RSQ Graveyard: name asked of gy_RSQService | handler.zs:1310, handler.zs:1315 | RS_ScoreHandler.TellGraveyard |
| W17 | RSQ Gun Bonsai VR: names asked of RSQ_HudService | hud.zs:627, hud.zs:630, hud.zs:631, tools.zs:63 | RS_ScoreHUD.GaugeShift; RS_Tool.IsTag |
| W19 | Brutal Doom and BD22 VR Reloaded: class names read | head.zs:169, head.zs:191, head.zs:429, crit.zs:388, crit.zs:486, tools.zs:215 | RS_ScoreHead.Classes; CheckReplacement; Outcome; RS_ScoreCritHandler.OnRegister; RoundOf; RS_Tool.GunClassOf |
| W20 | Champions: class and setting names read | boost.zs:104, boost.zs:83, boost.zs:184, boost.zs:99, handler.zs:1475, hud.zs:526 | RS_Boost; RS_ScoreHandler.ChampIconOf; RS_ScoreHUD.DrawBreakdown |
| W21 | LegenDoom: lump and class names read | boost.zs:92, boost.zs:102, boost.zs:103 | RS_Boost.LegenDoomLoaded; Legendary; Transformed |
| W22 | Critical Shots (mk-crits) or RandomCrits: class names read | crit.zs:375, crit.zs:382, crit.zs:407 | RS_ScoreCritHandler.OnRegister; WorldThingSpawned |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No keys; only the fire buttons are read | tracker.zs:327, tools.zs:247, tracker.zs:164 | RS_ScoreTracker.Tick; NoteFire; RS_Tool.GunClass |
| L2 | Bar empty each map; lives wiped only with Nothing or Total | handler.zs:299, handler.zs:292, handler.zs:295, handler.zs:307, CVARINFO.txt:35 | RS_ScoreHandler.ScoreReset; CVARINFO |
| L19 | A saved Nothing is moved to Plus Rewards once | hud.zs:62, hud.zs:78, hud.zs:79, hud.zs:84, CVARINFO.txt:106 | RS_ScoreHUD.Migrate; RenderOverlay; CVARINFO |
| L3 | Only a killing hit spends a life | tracker.zs:236, handler.zs:1398 | RS_ScoreTracker.NoteHit; RS_ScoreHandler.RunExtraLives |
| L4 | 10 faces at most | hud.zs:338 | RS_ScoreHUD.DrawLives |
| L5 | What is not a kill | handler.zs:112, handler.zs:398, handler.zs:372 | RS_ScoreHandler.IsScorable; WorldThingDied |
| L6 | Full base once a body | handler.zs:464, handler.zs:203 | RS_ScoreHandler.WorldThingDied; AddToCensus |
| L7 | Replaces | handler.zs:603 | RS_ScoreHandler.AwardKiller |
| L8 | Chain gap 3 s, last step kills | combo.zs:94, combo.zs:96, combo.zs:471 | RS_ComboLedger; RS_Combo.Match |
| L9 | One named combo a kill | combo.zs:585 | RS_Bonus_Chain.Evaluate |
| L10 | Grapple: two rows, no hook combos, the spike needs RSQ Grenade | hook.zs:105, hook.zs:118, tools.zs:288, combos.zs:152, Grapple/README.md:101 | RS_Bonus_HookKick; RS_Bonus_AirSpike; RS_Tool.Classify; RS_ComboTable.Add; (Grapple) README Limits |
| L11 | Whip: Lashed on every Wide Swing kill; Wide Swing from the second; Ground Crack needs the air | hook.zs:144, hook.zs:162, hook.zs:181, Whip/zscript/rsqwp/lash.zs:250, Whip/zscript/rsqwp/lash.zs:254, melee.zs:248 | RS_Bonus_Lashed.Evaluate; RS_Bonus_WideSwing.Evaluate; RS_Bonus_GroundCrack.Evaluate; (Whip) RSQWP_Whip.GroundImpact |
| L12 | Chain Gang counts by itself; the first gives nothing | rows.zs:1150, rows.zs:1156, rows.zs:1158 | RS_Row_ChainGang.Earlier; Evaluate |
| L13 | Monsters never crit | crit.zs:111 | RS_ScoreCritBrain.ModifyDamage |
| L14 | What is never a head shot | head.zs:282, head.zs:294 | RS_ScoreHead.Judge; VerdictAt |
| L15 | Skill Gold off | gold.zs:172, gold.zs:177 | RS_ScoreSkillGold.Enabled; Pay |
| L16 | Glossary pointer and text | glossary.zs:158, glossary.zs:173, glossary_data.zs:1 | RSQSC_GlossaryMenu.MouseEvent; glossary_data.zs |
| L17 | VR only | wrist.zs:83 | RS_ScoreWrist.Show |
| L18 | Two names used twice | rows.zs:198, combos.zs:73, rows.zs:1176, combos.zs:122 | RS_Row_* DisplayName; RS_ComboTable.Add |
