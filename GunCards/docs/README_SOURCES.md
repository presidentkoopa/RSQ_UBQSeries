# RSQ Gun Cards: where each README claim comes from

Commit read: e2b60912e (2026-11-27). Paths are inside `GunCards/` unless they start with another mod's folder. `C` is
`zscript/rsqgc/card.zs`, `D` is `zscript/rsqgc/cnd.zs`, `S` is `zscript/rsqgc/side.zs`, `I` is `zscript/rsqgc/items.zs`,
`G` is `zscript/rsqgc/gestcopy.zs`, `M` is `zscript/rsqgc/modelcard.zs`, `P` is `zscript/rsqgc/spots.zs`, `W` is
`zscript/rsqgc/worldcard.zs`, `L` is `zscript/rsqgc/look.zs`, `B` is `zscript/rsqgc/bonsai.zs`, `R` is
`zscript/rsqgc/rsmenu.zs`, `MR` is `zscript/rsqgc/menurows.zs`, `HS` is `zscript/rsqgc/handsync.zs`, `MC` is
`zscript/rsqgc/mcard_states.zs`; other files are named in full. Each line number is the line that does the thing, not
the start of its function. `H<n>` is the n-th How to play row, `K` the Keys section, `X<n>` the n-th Works with row,
`L<n>` the n-th Limit.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Show Cards 1 (the default) always wants the small card | C:709, CVARINFO.txt:5 | RSQGC_GunCard.Wanted |
| H1 | A gun is a weapon whose rounds can be counted (it has Ammo1); it is shown when wanted | C:331, C:980, C:985, C:1088 | Loaded; WorldTick |
| H1 | Right of a main hand (the mirrored hand gets the other side) | C:1374 | TiltTo |
| H1 | The panel, by weapon slot; the word MAGAZINE with a magazine, AMMO without | C:1258, C:884, C:1260, C:1261 | Draw; StyleFor |
| H1 | Big: the magazine (Ammo2) or the one pile; small: the reserve in gold, only with a magazine | C:335, C:336, C:349, C:1284, C:1290 | Loaded; Reserve; Draw |
| H2 | The off hand's layers are owned by the off-hand gun; a class not listed in an RSQGCOFF lump has no small card | C:1037, C:1210, M:33, M:55, M:57 | WorldTick; Draw; McRead; McUse |
| H3 | Green above half, yellow to the low share (0.25), red at or under it; 0 is red; no magazine: no colour above 0 | C:373, C:374, C:375, C:378, C:379, C:380, C:1232, CVARINFO.txt:40, CVARINFO.txt:43 | MagColour; Draw |
| H4 | Empty magazine with a reserve: RELOAD, then a red 0, every 52 tics | C:1268, C:1271, C:368, C:1281, C:1283 | Draw |
| H5 | A rise of the gun's pile is a pickup: +N for rsqgc_plus_tics (52), adding up inside that time, shown up to +99 | C:135, C:138, C:139, C:1288, CVARINFO.txt:51 | Track; Draw |
| H6 | The watch check is asked of RSQ Accessibility first, else of Gun Cards' own copy | C:771, C:772, C:736, C:761 | Watching; Inspect; OwnInspect |
| H6 | The own copy's pose: 0.15 to 0.65 m ahead of the eyes, 0.30 m below to 0.20 m above, 0.35 m to a side, pitch within 60 degrees | G:243, G:244, G:245, G:246 | RSQGC_GCopy.InspectPose |
| H6 | The back of the wrist (way 2), 35 degrees of twist, slower than 1.2 m/s, held 6 tics; kept down to 20 degrees | G:253, G:255, G:262, G:265, G:274, G:277 | InspectPose; Inspect1 |
| H6 | Counts once held (level 2) and for rsqgc_linger (35) tics after; Watch Card 1 by default | C:775, C:776, C:952, CVARINFO.txt:7, CVARINFO.txt:47, CVARINFO.txt:48 | Watching; WorldTick |
| H6 | Fades over rsqgc_fade (4) tics; the watch card is drawn on that wrist and the hand's small card is cleared | C:1028, C:1082, C:1084, C:1129, CVARINFO.txt:44 | WorldTick; DrawSide |
| H7 | MAG / AMMO / RELOAD and RESERVE, the counts, +N in green | S:189, S:190, S:192, S:194 | RSQGC_SideCard.GunRows |
| H7 | MODE, GRENADES, KILLS (red), GOLD | S:274, S:276, S:277, S:281 | RSQGC_SideCard.Build |
| H7 | MODE from a GunModeService; grenades from the first pile found; gold only on the off hand, from RSQ Score | C:567, C:217, C:220, C:225, C:226, C:204, C:207 | ModeOf; Grenades; Gold |
| H8 | An empty hand or fists with a watch check is the Status card | C:273, C:967, C:1051 | EmptyHand; WorldTick |
| H8 | H and A, health big (red at 25 or less), armour blue, the key row, GOLD | S:370, S:371, S:373, S:374, S:375, S:377 | RSQGC_SideCard.BuildStatus |
| H8 | Key icons lit or dim, only the map's kinds; other keys +N; G:n | S:206, S:213, S:219, S:223, C:507, C:511, CVARINFO.txt:41, CVARINFO.txt:42 | KeyRow; MapKeys |
| H9 | A bare off hand's status card is drawn in the world (owner 2026-11-27) | C:967, C:1041, C:1042 | WorldTick |
| H10 | A weapon with no Ammo1 is an item; its watch check builds the item card | I:24, C:978, C:979, C:1143 | RSQGC_Items.IsItem; WorldTick; DrawSide |
| H10 | Name, count big (red at 0), state, H, A, G:n, keys, GOLD; in the near half | S:346, S:352, S:354, S:355, S:356, S:358, S:359, S:361, S:333 | BuildItem; HText |
| H10 | Flares, battery, cigarettes; LIT / UNLIT, ON / OFF | I:39, I:42, I:50, I:78, I:79, I:84, I:85 | Count; State |
| H10 | Watch Shows: Status shows the Status card for an item too | C:1081 | WorldTick |
| H11 | The off hand's check does not count while two-handing: the engine's flag, or within 16 units of the gun hand and 8 of its line | C:958, C:649, C:636, C:653, C:645, C:657 | WorldTick; TwoHanding |
| H12 | A hand fired when the engine says its shot was traced, or its rounds went down; a kill within 35 tics goes to the later hand, to neither on a tie | C:155, C:161, C:141, C:120, C:179, C:181, C:183, C:188 | Track; WorldThingDamaged |
| H13 | A cooking RSQGN_Grenade: the fuse count is the big number, amber or red; shown unless Show Cards is Off | C:237, C:239, C:1011, C:1239, C:1240 | FuseCount; WorldTick; Draw |
| H14 | On Look: 4 units to rsqgc_glance_reach (0.7 m) from the eyes, within rsqgc_glance_cone (30) | C:729, C:751, C:753, CVARINFO.txt:45, CVARINFO.txt:46 | Wanted; Glance |
| H15 | Inspect: the same reader, the same linger; a hand whose watch card is up draws no small card | C:721, C:725, C:985, C:1084 | Wanted; WorldTick |
| H16 | On Reload: BT_RELOAD or that hand's reload bit, and rsqgc_linger after | C:715, C:716, C:717 | Wanted |
| H17 | Show Cards Off: no small card, and no fuse count | C:708, C:1011 | Wanted; WorldTick |
| H18 | Always: watching without the pose; not drawn under 60 degrees off square (0.50) or over 45 off the gaze; then the small card | C:960, C:993, C:628, C:659, C:1000, C:1003 | WorldTick |
| H18 | With the watch card up, the small card is drawn beside it | C:1083 | WorldTick |
| H19 | Watch Card 0: the pose is not read for a card | C:922, C:952 | WorldTick |
| H20 | Watch Shows 1: the Status card | C:1080, C:1081, CVARINFO.txt:8 | WorldTick |
| H21 | Both: the gun rows, H and A, the keys and G:n, CND, GOLD, and nothing more | S:256, S:257, S:258, S:259, S:265, S:269 | RSQGC_SideCard.Build |
| H22 | Gun Bonsai rows: LV and a bar, up to 4 upgrades, dark when off, +N MORE | S:282, S:288, S:300, S:306, S:314, B:46, CVARINFO.txt:9 | Build; RSQGC_Bonsai.Entry |
| H23 | Both guns: the off hand's card stands down; the other gun's rounds take the small number | C:948, C:1022, C:1023, C:1215, CVARINFO.txt:31 | WorldTick; Draw |
| H24 | Hide at Eye: within rsqgc_eye_reach (0.30 m), pointing within 25 degrees of the look | C:984, C:261, C:263, CVARINFO.txt:13, CVARINFO.txt:50 | WorldTick; AtEye |
| H25 | Tilt: each tic, capped by rsqgc_tilt_max (20) | C:1361, C:1378, CVARINFO.txt:14, CVARINFO.txt:49 | TiltTo |
| H26 | Draw in World: no layers, world quads placed each tic; an item gets the status card | C:1055, C:1070, C:1042, C:1042, CVARINFO.txt:12, CVARINFO.txt:23 | WorldTick |
| H26 | The world small card's title: RELOAD, +N, MAG or AMMO | W:72 | RSQGC_WorldCard.Fill |
| H27 | A blow of more than rsqgc_cnd_bighit (20) takes rsqgc_cnd_wear (3) off each held gun, one class once, not under 0 | D:479, D:478, D:487, D:490, D:497, CVARINFO.txt:56, CVARINFO.txt:57, CVARINFO.txt:58 | RSQGC_CndHandler.WorldThingDamaged; BigHit |
| H27 | A gun not yet in the book is at 100 | D:239 | RSQGC_CndBook.Get |
| H28 | The player's damage is scaled on hit by the gun that fired it | D:260, D:269, D:274 | RSQGC_CndBook.ModifyDamage |
| H28 | The table for most guns: 0.90, 0.85, 0.80, 0.70, 0.60, then 1.20, 1.50, 1.80 | D:151, D:152, D:153, D:154, D:155, D:156, D:157, D:158 | RSQGC_Cnd.Curve |
| H28 | Own tables for the Bruiser and Precision names | D:119, D:132, D:94, D:95 | Curve; Profile |
| H29 | The sequence starts at a trigger pull and ends when the gun is ready; a tic added or taken, never under 1 | D:614, D:615, D:624, D:627, D:599, CVARINFO.txt:59 | WorldTick; RateTick |
| H29 | Rates: 0.85, 0.67, 0.70, then 1.05, 1.20, 1.25 | D:152, D:153, D:154, D:155, D:156, D:158 | Curve |
| H30 | Backfire from the 50 band (0.005 to 0.07); misfire under 30; an Overheat gun has no backfire | D:153, D:125, D:158, D:156, D:159 | Curve |
| H30 | 1 to 5, 4 to 12, 8 to 20; no armour; capped to leave 1 health, under BUDDHA; one a second a hand | D:436, D:443, D:448, D:449, D:427, D:453 | RSQGC_CndHandler.Shot |
| H30 | The word goes to RSQVR_Service "toast"; a sound plays either way | D:457, D:206, D:455 | Shot; RSQGC_Cnd.Toast |
| H31 | CND, a bar and the number, when Condition on Card is on; five colours | S:235, S:241, D:185, D:169, D:173, CVARINFO.txt:61 | CndRow; CardValue; Colour |
| H32 | "cnd.repair": +n to each held gun under 100; VisualRewards asks it for a steel bit | D:697, D:537, D:538, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:1115 | SvcInt; RepairHeld |
| H33 | "cnd.fix": every carried gun to 100; Miniboss's kiosk asks it | D:700, D:580, Miniboss/zscript/rsqmb/kiosk.zs:1413 | SvcInt; FixAll |
| H34 | At 0 after a big hit, with Lose Gun at 0: BROKE and the gun is taken | D:501, D:514, D:515, CVARINFO.txt:60 | BigHit; BreakGun |
| H35 | The Spot rows; moving one saves a spot for the class of the gun in hand; greyed with none | MENUDEF.txt:116, P:203, P:207, P:146, C:1245 | OptionMenuItemRSQGCSpotSlider.SetSliderValue; EditGun; Draw |
| H35 | A gun with no spot uses the Placement sliders | P:75 | RSQGC_Spots.Find |
| H36 | Edit Spot For picks the hand; an RSQ_Off_ copy falls back to its gun's spot | MENUDEF.txt:113, P:137, P:73 | EditHand; Find |
| H37 | The two reset rows | MENUDEF.txt:122, MENUDEF.txt:124, P:249, P:250 | OptionMenuItemRSQGCSpotReset.MenuEvent |
| H38 | Two rows for another pack's cvars, greyed when the cvar does not exist | MENUDEF.txt:50, MENUDEF.txt:52, MR:14 | OptionMenuItemRSQGCOtherOption.IsGrayed |
| H39 | Hand Numbers: a mid-screen print every 5 tics | C:921, C:897, C:913, CVARINFO.txt:53 | WorldTick; ShowHands |
| H40 | Two net events, refused by hand without sv_cheats | D:640, D:642, D:647, D:657 | RSQGC_CndHandler.NetworkProcess |

## Keys

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| K | No key: the handlers listed in MAPINFO have no input override; the only buttons read are L1's | MAPINFO.txt:8, C:715, D:596 | (there is no KEYCONF lump in GunCards/) |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Accessibility: RSQG_Service "inspect" asked; the own copy stands down when that service exists | C:736, C:738, G:131, G:225 | Inspect; RSQGC_GCopy.ReaderHere; Asked |
| X1 | The looser pose when neither reader answers: 5 to 17 units, 35 degrees, across by 55, twist 45 | C:783, C:785, C:788, C:796 | Watching |
| X1 | Inspect then falls to On Look; body fit and the one-hand swap are read | C:729, G:149, G:39, G:41, G:43 | Wanted; VScale; RSQGC_GPose.Src |
| X2 | RSQ Gun Bonsai VR: the three requests, and the older service | B:46, B:49, B:52, B:53, B:56, B:58, B:59 | RSQGC_Bonsai.Entry |
| X3 | RSQ Score: "gold" | C:205, C:207 | Gold |
| X4 | RSQ Grenade: its pile while its grenade is carried; the fuse requests; its RSQGCOFF lists its grenade | C:217, C:219, C:239, C:244, Grenade/RSQGCOFF.txt:3 | Grenades; FuseCount; FuseAmber |
| X5 | Brutal Doom / BD22 VR: GrenadeAmmo, the fists, the real magazines, the off-hand copies, the two HUD cvars | C:220, C:273, C:309, C:310, C:312, C:316, C:551, P:73, MENUDEF.txt:50, MENUDEF.txt:52 | Grenades; EmptyHand; RealMag; NameOf; RSQGC_Spots.Find |
| X6 | The weapon sets: RSQB_GN_Ammo; "firemode" of any GunModeService | C:225, C:567, C:571 | Grenades; ModeOf |
| X7 | RSQ Miniboss: "fightcard.up" stands the off-hand watch card down; its kiosk and fight call ask this mod | C:631, C:633, C:1009, Miniboss/zscript/rsqmb/kiosk.zs:225, Miniboss/zscript/rsqmb/kiosk.zs:226, Miniboss/zscript/rsqmb/kiosk.zs:1402, Miniboss/zscript/rsqmb/kiosk.zs:1413, Miniboss/zscript/rsqmb/bossfight.zs:407 | FightCardUp; WorldTick |
| X8 | RSQ VisualRewards: "toast"; "levelcard" hides the small card (Level Card Swap, at most 175 tics); steel bits | D:205, D:206, C:1447, C:1451, C:1452, C:1015, CVARINFO.txt:35, VisualRewards/pk3/zscript/rsqthp/damnums/events.zs:309, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:1105, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:1115 | RSQGC_Cnd.Toast; RSQGC_Service.GetInt; WorldTick |
| X9 | RSQ Wheel: its palette, font set and plate are followed; it reads two cvars here and asks "cnd.get" | L:77, L:78, L:59, L:85, L:86, C:1223, Wheel/zscript/wheel/wr_q_watch.zs:59, Wheel/zscript/wheel/wr_q_gunlook.zs:48, Wheel/zscript/wheel/wr_stats.zs:326 | RSQGC_LookState.Refresh; RSQGC_Look.Plate; Draw |
| X10 | RSQ Flashlight & Flare: the two services and classes | I:39, I:77, I:42, I:83, I:60, I:61 | RSQGC_Items.Count; State; Label |
| X11 | RSQ Saber: SABER | I:59 | Label |
| X12 | RSQ Tactical Rig: CIGARETTES and the pack count; the Rig asks the copy's service | I:62, I:48, TacticalRig/zscript/rsqtr/rig.zs:2180 | Label; Count |
| X13 | RSQ Laser Sight asks the copy's service | LaserSight/zscript/rsqls/sight.zs:452 | (Laser Sight's code) |
| X14 | BD22_VoxelPack: its key voxels, else Freedoom's | C:423 | KeyArt |
| X15 | Every RSQGCOFF lump is read | M:33, M:43 | McRead |
| X16 | RSQGC_Service: "levelcard" and the cnd requests | C:1442, C:1446, C:1447, C:1457, D:692, D:693, D:695, D:697, D:698, D:699, D:700, D:707, D:708, D:709, D:710 | RSQGC_Service.GetInt; GetDouble; RSQGC_Cnd.SvcInt; SvcDouble |
| X16 | RSQGC_GCopyService: its four requests; -1 while RSQ Accessibility is loaded | G:292, G:298, G:300, G:302, G:303, G:304 | RSQGC_GCopyService.GetInt |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Buttons read: reload (On Reload only), each hand's fire and alt fire (Weapon Condition only) | C:710, C:715, D:590, D:596, D:597 | Wanted; RSQGC_CndHandler.WorldTick |
| L2 | Cards only for the weapon in each hand | C:977 | WorldTick |
| L3 | The console player only, and only while alive | C:918, C:925 | WorldTick |
| L4 | No tracked hands: On Look and the readers answer no | C:745, G:48, C:778 | Glance; RSQGC_GPose.PoseGood; Watching |
| L5 | Off hand: the small card by RSQGCOFF; the watch card is laid on layers the off-hand weapon owns | M:57, C:1037, C:1147 | McUse; WorldTick; DrawSide |
| L6 | A weapon with nothing to count is not a gun for the small card | C:980 | WorldTick |
| L7 | Kills: the 35 tic window; the handler is a level one, so a new map starts at 0 | C:179, MAPINFO.txt:8 | WorldThingDamaged |
| L8 | 999 and +99 | C:1284, C:1288 | Draw |
| L9 | The hand-drawn watch card has no sideways move; In has 13 places 2 cm apart | S:127, C:1416, MC:13, MC:14 | RSQGC_SideCard.Sync; Depth |
| L10 | World: an item gets the status card; the big number is white or red at 0 | C:1042, W:64 | WorldTick; RSQGC_WorldCard.Fill |
| L11 | Keys by words in the class name; any other key is counted | C:398, C:399, C:400, C:402, C:412 | KeyType; HeldKeys |
| L12 | Wear comes only from damage to the player; not a gun: melee, no ammo type, the NOTGUN words, a grenade that is no launcher; kept by class name | D:477, D:77, D:78, D:79, D:84, D:181 | RSQGC_CndHandler.WorldThingDamaged; RSQGC_Cnd.IsGun; Of |
| L13 | Spread and pellets are only answers to a caller | D:707, D:695, D:708 | SvcDouble; SvcInt |
| L14 | Spots: one cvar, 4000 characters, the oldest dropped; the spot rows name no cvar, so Reset All passes them | CVARINFO.txt:27, P:29, P:107, P:185, R:457 | RSQGC_Spots.Save; OptionMenuItemRSQGCSpotSlider.Init; OptionMenuItemRSQGCResetAll.Add |
