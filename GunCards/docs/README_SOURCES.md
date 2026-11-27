# RSQ Gun Cards: where each README claim comes from

Commit read: e2b60912e (2026-11-27). Paths are inside `GunCards/` unless they start with another mod's folder. `C` is
`zscript/rsqgc/card.zs`, `D` is `zscript/rsqgc/cnd.zs`, `S` is `zscript/rsqgc/side.zs`, `I` is `zscript/rsqgc/items.zs`,
`G` is `zscript/rsqgc/gestcopy.zs`, `M` is `zscript/rsqgc/modelcard.zs`, `P` is `zscript/rsqgc/spots.zs`, `W` is
`zscript/rsqgc/worldcard.zs`, `L` is `zscript/rsqgc/look.zs`, `B` is `zscript/rsqgc/bonsai.zs`, `R` is
`zscript/rsqgc/rsmenu.zs`, `MR` is `zscript/rsqgc/menurows.zs`, `HS` is `zscript/rsqgc/handsync.zs`, `MC` is
`zscript/rsqgc/mcard_states.zs`; other files are named in full. Each line number is the line that does the thing, not
the start of its function. `H<n>` is the n-th How to play row, `K` the Keys section, `X<n>` the n-th Works with row,
`L<n>` the n-th Limit. The watch check rows (H6, H15, H16, H39, X1, X7, X16, L4, L15 to L18) were
rewritten against the working tree of 2026-11-27 ("look at it, it shows"); every other number was moved to the same tree.
The rows for "Built 2026-11-27: BD22 VR weapons" (H7's LAUNCHER row, H10, H21, H26, H41 to H45, X5, L7, L10, L18, L19)
were written against the working tree after that build (on top of 911aa161e), and every other number was moved to it
with `tools/readme/remap_sources.py GunCards HEAD`.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Show Cards 1 (the default) always wants the small card | C:844, CVARINFO.txt:5 | RSQGC_GunCard.Wanted |
| H1 | A gun is a weapon whose rounds can be counted (it has Ammo1); it is shown when wanted | C:463, C:1080, C:1085, C:1192 | Loaded; WorldTick |
| H1 | Right of a main hand (the mirrored hand gets the other side) | C:1480 | TiltTo |
| H1 | The panel, by weapon slot; the word MAGAZINE with a magazine, AMMO without | C:1364, C:987, C:1366, C:1367 | Draw; StyleFor |
| H1 | Big: the magazine (Ammo2) or the one pile; small: the reserve in gold, only with a magazine | C:467, C:468, C:481, C:1390, C:1396 | Loaded; Reserve; Draw |
| H2 | The off hand's layers are owned by the off-hand gun; a class not listed in an RSQGCOFF lump has no small card | C:1137, C:1316, M:33, M:55, M:57 | WorldTick; Draw; McRead; McUse |
| H3 | Green above half, yellow to the low share (0.25), red at or under it; 0 is red; no magazine: no colour above 0 | C:506, C:507, C:508, C:511, C:512, C:513, C:1338, CVARINFO.txt:40, CVARINFO.txt:43 | MagColour; Draw |
| H4 | Empty magazine with a reserve: RELOAD, then a red 0, every 52 tics | C:1374, C:1377, C:501, C:1387, C:1389 | Draw |
| H5 | A rise of the gun's pile is a pickup: +N for rsqgc_plus_tics (52), adding up inside that time, shown up to +99 | C:157, C:160, C:161, C:1394, CVARINFO.txt:52 | Track; Draw |
| H6 | The watch check is asked of Gun Cards' own reader only; without the reader the same rule is used directly | C:900, C:870, C:871, C:872 | Watching; Inspect |
| H6 | The rule: the back of the wrist under 80 degrees off facing the eyes and the wrist under 50 degrees off the gaze to start; 88 and 65 to stay | G:270, G:271, G:274, G:275, G:335, G:345 | RSQGC_GCopy.Checked; WatchRule |
| H6 | The face from angle, pitch and roll together (the left hand mirrored); no place, stillness or hold: 2 the tic it is met | G:308, G:309, G:324, G:358, G:393 | FaceOff; GazeOff; Look1; Inspect |
| H6 | Counts while the answer is 2 and for rsqgc_linger (70) tics after; Watch Card 1 by default | C:900, C:901, C:1051, CVARINFO.txt:7, CVARINFO.txt:48 | Watching; WorldTick |
| H6 | Fades over rsqgc_fade (4) tics; the watch card is drawn on that wrist and the hand's small card is cleared | C:1128, C:1186, C:1188, C:1233, CVARINFO.txt:44 | WorldTick; DrawSide |
| H7 | MAG / AMMO / RELOAD and RESERVE, the counts, +N in green | S:190, S:191, S:193, S:195 | RSQGC_SideCard.GunRows |
| H7 | MODE, GRENADES, KILLS (red), GOLD | S:296, S:299, S:300, S:304 | RSQGC_SideCard.Build |
| H7 | LAUNCHER n after MODE, only where the weapon has a launcher: exactly the classes Rifle, RSQ_Off_Rifle, Machinegun | S:297, S:252, S:253, S:256, C:451, C:452 | Build; LauncherRow; RSQGC_GunCard.Launcher |
| H7 | MODE from a GunModeService; grenades from the first pile found; gold only on the off hand, from RSQ Score | C:700, C:277, C:280, C:285, C:286, C:264, C:267 | ModeOf; Grenades; Gold |
| H8 | An empty hand or fists with a watch check is the Status card | C:333, C:1066, C:1153 | EmptyHand; WorldTick |
| H8 | H and A, health big (red at 25 or less), armour blue, the key row, GOLD | S:393, S:394, S:396, S:397, S:398, S:400 | RSQGC_SideCard.BuildStatus |
| H8 | Key icons lit or dim, only the map's kinds; other keys +N; G:n | S:207, S:214, S:220, S:224, C:640, C:644, CVARINFO.txt:41, CVARINFO.txt:42 | KeyRow; MapKeys |
| H9 | A bare off hand's status card is drawn in the world (owner 2026-11-27) | C:1066, C:1141, C:1144 | WorldTick |
| H10 | A weapon with no Ammo1 is an item; the item card is built only for the five classes named (the saber and its off-hand twin, the flare, the flashlight, the cigarettes) | I:29, I:32, I:36, C:1078, C:1079, C:1240, C:1249 | RSQGC_Items.IsItem; OwnCard; WorldTick; DrawSide |
| H10 | Name, count big (red at 0), state, H, A, G:n, keys, GOLD; in the near half | S:369, S:375, S:377, S:378, S:379, S:381, S:382, S:384, S:356 | BuildItem; HText |
| H10 | Flares, battery, cigarettes; LIT / UNLIT, ON / OFF | I:52, I:55, I:63, I:91, I:92, I:97, I:98 | Count; State |
| H10 | Watch Shows: Status shows the Status card for an item too | C:1185 | WorldTick |
| H11 | The off hand's check does not count while two-handing: the engine's flag, or within 16 units of the gun hand and 8 of its line | C:1057, C:782, C:769, C:786, C:778, C:790 | WorldTick; TwoHanding |
| H12 | A hand fired when the engine says its shot was traced, or its rounds went down; a kill within 35 tics goes to the later hand, to neither on a tie | C:177, C:183, C:163, C:142, C:201, C:203, C:208, C:213 | Track; WorldThingDamaged |
| H13 | A cooking RSQGN_Grenade: the fuse count is the big number, amber or red; shown unless Show Cards is Off | C:297, C:299, C:1111, C:1345, C:1346 | FuseCount; WorldTick; Draw |
| H14 | On Look: 4 units to rsqgc_glance_reach (0.7 m) from the eyes, within rsqgc_glance_cone (30) | C:860, C:885, C:887, CVARINFO.txt:45, CVARINFO.txt:46 | Wanted; Glance |
| H15 | Inspect: the same reader, the same linger; a hand whose watch card is up draws no small card | C:857, C:858, C:1085, C:1188 | Wanted; WorldTick |
| H16 | On Reload: BT_RELOAD or that hand's reload bit, and rsqgc_linger after | C:850, C:851, C:852 | Wanted |
| H17 | Show Cards Off: no small card, and no fuse count | C:843, C:1111 | Wanted; WorldTick |
| H18 | Always: watching without the pose; not drawn under 60 degrees off square (0.50) or over 45 off the gaze; then the small card | C:1059, C:1093, C:761, C:792, C:1100, C:1103 | WorldTick |
| H18 | With the watch card up, the small card is drawn beside it | C:1187 | WorldTick |
| H19 | Watch Card 0: the pose is not read for a card | C:1021, C:1051 | WorldTick |
| H20 | Watch Shows 1: the Status card | C:1184, C:1185, CVARINFO.txt:8 | WorldTick |
| H21 | Both: the gun rows, H and A, the keys and G:n, CND, GOLD, LAUNCHER on the first of those lines left free, and nothing more | S:274, S:275, S:276, S:277, S:283, S:287, S:288, S:289, S:291 | RSQGC_SideCard.Build |
| H22 | Gun Bonsai rows: LV and a bar, up to 4 upgrades, dark when off, +N MORE | S:305, S:311, S:323, S:329, S:337, B:46, CVARINFO.txt:9 | Build; RSQGC_Bonsai.Entry |
| H23 | Both guns: the off hand's card stands down; the other gun's rounds take the small number | C:1047, C:1122, C:1123, C:1321, CVARINFO.txt:31 | WorldTick; Draw |
| H24 | Hide at Eye: within rsqgc_eye_reach (0.30 m), pointing within 25 degrees of the look | C:1084, C:321, C:323, CVARINFO.txt:13, CVARINFO.txt:51 | WorldTick; AtEye |
| H25 | Tilt: each tic, capped by rsqgc_tilt_max (20) | C:1467, C:1484, CVARINFO.txt:14, CVARINFO.txt:50 | TiltTo |
| H26 | Draw in World: no layers, world quads placed each tic; an item with a card of its own gets the status card | C:1157, C:1174, C:1144, C:1146, I:36, CVARINFO.txt:12, CVARINFO.txt:23 | WorldTick; RSQGC_Items.OwnCard |
| H26 | Any other weapon with no ammo pile: the full world card, its name in the title, no AMMO row, the big number not drawn | C:1168, C:1171, W:68, W:69, W:83, W:85, W:249 | WorldTick; RSQGC_WorldCard.Fill; Place |
| H26 | The world small card's title: RELOAD, +N, MAG or AMMO | W:79 | RSQGC_WorldCard.Fill |
| H27 | A blow of more than rsqgc_cnd_bighit (20) takes rsqgc_cnd_wear (3) off each held gun, one class once, not under 0 | D:479, D:478, D:487, D:490, D:497, CVARINFO.txt:57, CVARINFO.txt:58, CVARINFO.txt:59 | RSQGC_CndHandler.WorldThingDamaged; BigHit |
| H27 | A gun not yet in the book is at 100 | D:239 | RSQGC_CndBook.Get |
| H28 | The player's damage is scaled on hit by the gun that fired it | D:260, D:269, D:274 | RSQGC_CndBook.ModifyDamage |
| H28 | The table for most guns: 0.90, 0.85, 0.80, 0.70, 0.60, then 1.20, 1.50, 1.80 | D:151, D:152, D:153, D:154, D:155, D:156, D:157, D:158 | RSQGC_Cnd.Curve |
| H28 | Own tables for the Bruiser and Precision names | D:119, D:132, D:94, D:95 | Curve; Profile |
| H29 | The sequence starts at a trigger pull and ends when the gun is ready; a tic added or taken, never under 1 | D:614, D:615, D:624, D:627, D:599, CVARINFO.txt:60 | WorldTick; RateTick |
| H29 | Rates: 0.85, 0.67, 0.70, then 1.05, 1.20, 1.25 | D:152, D:153, D:154, D:155, D:156, D:158 | Curve |
| H30 | Backfire from the 50 band (0.005 to 0.07); misfire under 30; an Overheat gun has no backfire | D:153, D:125, D:158, D:156, D:159 | Curve |
| H30 | 1 to 5, 4 to 12, 8 to 20; no armour; capped to leave 1 health, under BUDDHA; one a second a hand | D:436, D:443, D:448, D:449, D:427, D:453 | RSQGC_CndHandler.Shot |
| H30 | The word goes to RSQVR_Service "toast"; a sound plays either way | D:457, D:206, D:455 | Shot; RSQGC_Cnd.Toast |
| H31 | CND, a bar and the number, when Condition on Card is on; five colours | S:236, S:242, D:185, D:169, D:173, CVARINFO.txt:62 | CndRow; CardValue; Colour |
| H32 | "cnd.repair": +n to each held gun under 100; VisualRewards asks it for a steel bit | D:697, D:537, D:538, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:1115 | SvcInt; RepairHeld |
| H33 | "cnd.fix": every carried gun to 100; Miniboss's kiosk asks it | D:700, D:580, Miniboss/zscript/rsqmb/kiosk.zs:1413 | SvcInt; FixAll |
| H34 | At 0 after a big hit, with Lose Gun at 0: BROKE and the gun is taken | D:501, D:514, D:515, CVARINFO.txt:61 | BigHit; BreakGun |
| H35 | The Spot rows; moving one saves a spot for the class of the gun in hand; greyed with none | MENUDEF.txt:116, P:203, P:207, P:146, C:1351 | OptionMenuItemRSQGCSpotSlider.SetSliderValue; EditGun; Draw |
| H35 | A gun with no spot uses the Placement sliders | P:75 | RSQGC_Spots.Find |
| H36 | Edit Spot For picks the hand; an RSQ_Off_ copy falls back to its gun's spot | MENUDEF.txt:113, P:137, P:73 | EditHand; Find |
| H37 | The two reset rows | MENUDEF.txt:122, MENUDEF.txt:124, P:249, P:250 | OptionMenuItemRSQGCSpotReset.MenuEvent |
| H38 | Two rows for another pack's cvars, greyed when the cvar does not exist | MENUDEF.txt:50, MENUDEF.txt:52, MR:14 | OptionMenuItemRSQGCOtherOption.IsGrayed |
| H39 | Hand Numbers: a mid-screen print every 5 tics; the watch check's answers and each wrist's two angles | C:1020, C:1000, C:1012, C:1009, C:1010, C:1011, CVARINFO.txt:54 | WorldTick; ShowHands |
| H40 | Two net events, refused by hand without sv_cheats | D:640, D:642, D:647, D:657 | RSQGC_CndHandler.NetworkProcess |
| H41 | Any other weapon with no ammo pile: the Weapon card is built, not the item card | C:1136, C:1240, C:1250 | WorldTick; DrawSide |
| H41 | Its name in the labels' row in place of the gun rows; then the same lines (GRENADES, KILLS, GOLD); Both: the same name over the status rows | S:267, S:268, S:299, S:300, S:304, S:273 | RSQGC_SideCard.Build |
| H41 | No small card: a weapon with nothing to count is not a gun | C:463, C:1080 | Loaded; WorldTick |
| H42 | A blow: an inflictor that is not the player, not a traced shot's puff, not an explosion | C:206, C:235, C:236 | WorldThingDamaged; BlowHand |
| H42 | A hand counts when it holds a weapon with no Ammo1, or one flagged a melee weapon, and is not an empty hand; the body's edge within 128 units of that hand; the nearer hand wins | C:244, C:245, C:246, C:247, C:231 | BlowHand |
| H42 | The blow's hand goes before the hand that fired | C:207, C:213 | WorldThingDamaged |
| H43 | RESERVE is the Ammo1 pile divided by what one round costs, rounded down; the same number on the small card, the watch card and for RELOAD and +N | C:485, C:1321, C:1374, C:490, S:186, S:196 | Reserve; Draw; Pile; GunRows |
| H43 | What a round costs: the weapon's AmmoUse1 when over 1, else 3 for BrutalRevolver and its off-hand copy, else 1 | C:434, C:435, C:388 | PerRound; IsA |
| H44 | With NoReloading, or with IsPlayingAsPurist on any gun but the SSG and the GrenadeLauncher, a gun has no magazine: AMMO and the Ammo1 pile, no reserve | C:412, C:413, C:414, C:424, C:468, C:481 | NoMag; HasMagazine; Loaded; Reserve |
| H44 | The tokens are looked up by name when asked; without the class the answer is 0 | C:396, C:397 | CountOf |
| H45 | LAUNCHER: the token RFGLoaded for the main hand's gun, RSM_LoadedOff for the off hand's; -1 (no line) without the token class | C:453, C:454, C:455, C:458 | Launcher |
| H45 | The Machinegun without RSM_VR: a rocket in its Ammo2 and no FiredMGGrenade; the Rifle as Purist: no line | C:456, C:457 | Launcher |
| H45 | 1 in orange, 0 dark; the world card's row | S:257, W:90, W:91 | LauncherRow; RSQGC_WorldCard.Fill |

## Keys

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| K | No key: the handlers listed in MAPINFO have no input override; the only buttons read are L1's | MAPINFO.txt:8, C:850, D:596 | (there is no KEYCONF lump in GunCards/) |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | The wrist checks read the raw hand: body fit and the one-hand swap are read only by copied parts the checks do not use; no tick, no name on screen | G:278, G:156, G:45, G:47, G:49 | RawPos; VScale; RSQGC_GPose.Src |
| X2 | RSQ Gun Bonsai VR: the three requests, and the older service | B:46, B:49, B:52, B:53, B:56, B:58, B:59 | RSQGC_Bonsai.Entry |
| X3 | RSQ Score: "gold" | C:265, C:267 | Gold |
| X4 | RSQ Grenade: its pile while its grenade is carried; the fuse requests; its RSQGCOFF lists its grenade | C:277, C:279, C:299, C:304, Grenade/RSQGCOFF.txt:3 | Grenades; FuseCount; FuseAmber |
| X5 | Brutal Doom / BD22 VR: the no-reloading tokens and the two guns that keep a magazine as Purist; BrutalRevolver's 3 a round; the launcher's classes and tokens; RSM_LauncherService is not asked (no ServiceIterator names it) | C:412, C:413, C:414, C:435, C:451, C:452, C:453, C:456 | NoMag; PerRound; Launcher |
| X5 | Brutal Doom / BD22 VR: GrenadeAmmo, the fists, the real magazines, the off-hand copies, the two HUD cvars | C:280, C:333, C:369, C:370, C:372, C:376, C:684, P:73, MENUDEF.txt:50, MENUDEF.txt:52 | Grenades; EmptyHand; RealMag; NameOf; RSQGC_Spots.Find |
| X6 | The weapon sets: RSQB_GN_Ammo; "firemode" of any GunModeService | C:285, C:700, C:704 | Grenades; ModeOf |
| X7 | RSQ Miniboss: "fightcard.up" stands the off-hand watch card down; its kiosk and fight call ask this mod | C:764, C:766, C:1109, Miniboss/zscript/rsqmb/kiosk.zs:225, Miniboss/zscript/rsqmb/kiosk.zs:226, Miniboss/zscript/rsqmb/kiosk.zs:1402, Miniboss/zscript/rsqmb/kiosk.zs:1413, Miniboss/zscript/rsqmb/bossfight.zs:409, Miniboss/zscript/rsqmb/bossfight.zs:523 | FightCardUp; WorldTick |
| X8 | RSQ VisualRewards: "toast"; "levelcard" hides the small card (Level Card Swap, at most 175 tics); steel bits | D:205, D:206, C:1553, C:1557, C:1558, C:1115, CVARINFO.txt:35, VisualRewards/pk3/zscript/rsqthp/damnums/events.zs:309, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:1105, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:1115 | RSQGC_Cnd.Toast; RSQGC_Service.GetInt; WorldTick |
| X9 | RSQ Wheel: its palette, font set and plate are followed; it reads two cvars here and asks "cnd.get" | L:77, L:78, L:59, L:85, L:86, C:1329, Wheel/zscript/wheel/wr_q_watch.zs:59, Wheel/zscript/wheel/wr_q_gunlook.zs:48, Wheel/zscript/wheel/wr_stats.zs:326 | RSQGC_LookState.Refresh; RSQGC_Look.Plate; Draw |
| X10 | RSQ Flashlight & Flare: the two services and classes | I:52, I:90, I:55, I:96, I:73, I:74 | RSQGC_Items.Count; State; Label |
| X11 | RSQ Saber: SABER | I:72 | Label |
| X12 | RSQ Tactical Rig: CIGARETTES and the pack count; the Rig asks the copy's service | I:75, I:61, TacticalRig/zscript/rsqtr/rig.zs:2180 | Label; Count |
| X13 | RSQ Laser Sight asks the copy's service | LaserSight/zscript/rsqls/sight.zs:452 | (Laser Sight's code) |
| X14 | BD22_VoxelPack: its key voxels, else Freedoom's | C:556 | KeyArt |
| X15 | Every RSQGCOFF lump is read | M:33, M:43 | McRead |
| X16 | RSQGC_Service: "levelcard" and the cnd requests | C:1548, C:1552, C:1553, C:1563, D:692, D:693, D:695, D:697, D:698, D:699, D:700, D:707, D:708, D:709, D:710 | RSQGC_Service.GetInt; GetDouble; RSQGC_Cnd.SvcInt; SvcDouble |
| X16 | RSQGC_GCopyService: "reader", "inspect", "pulse", "inspect.tics", "inspect.any", GetString "pose.why"; the pulse check's 60 and 75 degrees | G:414, G:418, G:419, G:420, G:421, G:427, G:272, G:273 | RSQGC_GCopyService.GetInt; GetString |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Buttons read: reload (On Reload only), each hand's fire and alt fire (Weapon Condition only) | C:845, C:850, D:590, D:596, D:597 | Wanted; RSQGC_CndHandler.WorldTick |
| L2 | Cards only for the weapon in each hand | C:1077 | WorldTick |
| L3 | The console player only, and only while alive | C:1017, C:1024 | WorldTick |
| L4 | No tracked hands: On Look and the reader answer no | C:879, G:281, G:335 | Glance; RSQGC_GCopy.RawGood; Checked |
| L5 | Off hand: the small card by RSQGCOFF; the watch card is laid on layers the off-hand weapon owns | M:57, C:1137, C:1253 | McUse; WorldTick; DrawSide |
| L6 | A weapon with nothing to count is not a gun for the small card | C:1080 | WorldTick |
| L7 | Kills: the 35 tic window; the handler is a level one, so a new map starts at 0 | C:201, MAPINFO.txt:8 | WorldThingDamaged |
| L7 | A blow: any actor of the player's inside the reach counts (no test of which weapon made it); explosions are left out; fists are an empty hand | C:235, C:236, C:244, C:247 | BlowHand |
| L8 | 999 and +99 | C:1390, C:1394 | Draw |
| L9 | The hand-drawn watch card has no sideways move; In has 13 places 2 cm apart | S:128, C:1522, MC:13, MC:14 | RSQGC_SideCard.Sync; Depth |
| L10 | World: an item with a card of its own gets the status card; the big number is white or red at 0 | C:1144, I:36, W:71 | WorldTick; RSQGC_Items.OwnCard; RSQGC_WorldCard.Fill |
| L11 | Keys by words in the class name; any other key is counted | C:531, C:532, C:533, C:535, C:545 | KeyType; HeldKeys |
| L12 | Wear comes only from damage to the player; not a gun: melee, no ammo type, the NOTGUN words, a grenade that is no launcher; kept by class name | D:477, D:77, D:78, D:79, D:84, D:181 | RSQGC_CndHandler.WorldThingDamaged; RSQGC_Cnd.IsGun; Of |
| L13 | Spread and pellets are only answers to a caller | D:707, D:695, D:708 | SvcDouble; SvcInt |
| L14 | Spots: one cvar, 4000 characters, the oldest dropped; the spot rows name no cvar, so Reset All passes them | CVARINFO.txt:27, P:29, P:107, P:185, R:457 | RSQGC_Spots.Save; OptionMenuItemRSQGCSpotSlider.Init; OptionMenuItemRSQGCResetAll.Add |
| L15 | No box, stillness or hold in the rule: two angle tests only; the angles are constants, no cvar | G:335, G:270, G:274 | RSQGC_GCopy.Checked |
| L16 | The gaze is the pawn's angle and pitch (the head) | G:323 | GazeOff |
| L17 | The reader's change of answer only logs (Debug Log); no rumble, no on-screen name | G:361 | Look1 |
| L18 | Stays After 70 by default; settings generation 1 moves a saved value of exactly 35 to 70, once | CVARINFO.txt:48, CVARINFO.txt:49, C:114, C:115, C:118, C:119, C:124, C:126 | RSQGC_GunCard.OnRegister; Migrate |
| L19 | Told by name: the two guns that keep a magazine as Purist, BrutalRevolver, the launcher's three classes; the Railgun has no row in PerRound | C:414, C:435, C:451, C:452, C:434 | NoMag; PerRound; Launcher |
