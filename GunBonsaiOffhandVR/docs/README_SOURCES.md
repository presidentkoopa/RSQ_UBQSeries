# RSQ Gun Bonsai VR: where each README claim comes from

Commit read: 7bd62b727 (2026-11-27). Paths are inside `GunBonsaiOffhandVR/` unless they start with another mod's
folder. The shadowed Gun Bonsai files, in `ca.ancilla.bonsai/`: `E` is `EventHandler.zsc`, `P` is `PerPlayerStats.zsc`,
`W` is `WeaponInfo.zsc`, `H` is `HUD.zsc`, `SD` is `menu/StatusDisplay.zsc`, `DB` is `debug.zsc`, `DOT` is
`upgrades/Dot.zsc`. The series' own files: `C` is `rsq/zscript/core.zs`, `S` is `rsq/zscript/service.zs`, `HS` is
`rsq/zscript/hudservice.zs`, `M` is `rsq/ui/menus.zs`, `R` is `rsq/ui/router.zs`, `DI` is `rsq/ui/dispatch.zs`, `DA` is
`rsq/ui/data.zs`, `SK` is `rsq/ui/skin.zs`, `AH` is `rsq/ui/skin_a_hud.zs`, `AM` is `rsq/ui/skin_a_menus.zs`, `L` is
`rsq/ui/legendoom.zs`, `DR` is `rsq/ui/draw.zs`, `N` is `rsq/ui/needs.zs`. Other files are named in full. Each line
number is the line that does the thing, not the start of its function.

**What is in the pk3.** `build.ps1:25` to `:28` and `build_all.sh:149` (repo root) zip the whole folder except the build
script, git files, `readme.txt`, `tools/`, `docs/` and old pk3s. So `pk3/RSQ_GunBonsaiVR.pk3` holds: the series' own
lumps (`zscript.txt` and the fifteen files it includes under `rsq/`, `menudef.rsq`, `language.rsq`, `mapinfo.rsq`,
`sndinfo.rsq`, `bonsairc.rsq`, `cvarinfo.txt`, `keyconf.txt`, `graphics/`, `sounds/rsq/`), the ten files under
`ca.ancilla.bonsai/` (Gun Bonsai 0.10.6's files, changed by the series, replacing Gun Bonsai's by path:
`zscript.txt:5` to `:7`), `COPYING.md` and `README.md`. Gun Bonsai itself is not in the pk3 and not in this repo: what
its untouched files do (the upgrade givers, its settings, its KEYCONF and its default key) could not be read.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H0 | The info key is Gun Bonsai's event `bonsai-show-info`; this pk3's KEYCONF holds one console alias and no key | E:237, keyconf.txt:3 | TFLV_EventHandler.NetworkProcess; KEYCONF alias |
| H0 | The screens act on the engine's menu keys and typed keys only | M:99, M:131, M:254, M:303 | RSQUI_LevelUpMenu.MenuEvent, OnUIEvent; RSQUI_StatusMenu.OnUIEvent, MenuEvent |
| H1 | Dual HUD draws one gauge per hand that holds a weapon; a weapon in either hand is enough | E:173, E:174, E:175, E:118, cvarinfo.txt:8 | TFLV_EventHandler.RenderOverlay; ShouldDrawHUD |
| H1 | Main hand's anchor top right, off hand's top left | H:107, H:108, H:111, H:112, cvarinfo.txt:25, cvarinfo.txt:26, cvarinfo.txt:29, cvarinfo.txt:30 | TFLV_HUD.CalibrateForHand |
| H1 | The gauge's text: player level, player XP, weapon name, weapon level and XP; the two bars | H:467, H:469, H:482, H:499, H:453, H:456 | TFLV_HUD.DrawHUD |
| H1 | Colour Cycle on: frame and bars take the cycle all the time; defaults on | H:434, H:441, H:442, H:401, cvarinfo.txt:39, cvarinfo.txt:43 | TFLV_HUD.DrawHUD; CycleOr |
| H1 | With GBOVR Menus and HUD on the bars and the text pulse | H:444, H:450, H:461, H:593, cvarinfo.txt:67 | TFLV_HUD.DrawHUD; RSQGB_BarLife.Tint |
| H2 | Damage a player deals to a monster is sent to his stats; not friendly, not self, not a non-monster | E:335, E:338, E:300, E:302, E:303 | TFLV_EventHandler.WorldThingDamaged; GetPlayerDamageSource |
| H2 | XP = damage x the damage-to-XP factor; overkill removed; over 100 spawn health x (log10 - 1); added to the weapon's record | P:1338, P:1340, P:1342, P:1346, P:1392, W:227 | TFLV_PerPlayerStats.GetXPForDamage; OnDamageDealt; TFLV_WeaponInfo.AddXP |
| H3 | A hitscan opens a bracket for the hand the engine names and closes it after; damage inside pays that hand's record | E:363, E:381, P:847, P:1197, P:1202 | WorldHitscanPreFired; WorldHitscanFired; PushHitscan; ResolveCredit |
| H3 | The same for a railgun shot | E:399, E:409 | WorldRailgunPreFired; WorldRailgunFired |
| H4 | A missile whose target is a player is resolved as it spawns: claimed, inherited, else scored | E:415, E:418, P:1362, P:1091, P:1094, P:1098 | WorldThingSpawned; OnProjectileCreated; ResolveSpawn |
| H4 | The score: position up to 3, direction up to 2, fire frames 2.5, trigger 0.5; the higher wins | P:1023, P:1034, P:1044, P:1049, P:1052 | ScoreHandFor |
| H4 | Things a known shot spawns inherit its record | E:431, P:804 | WorldThingSpawned; InheritProvenance |
| H5 | An inflictor that is one of the player's own weapons pays that weapon's record, made if it has none | P:1169, P:1182, P:745, P:746 | ResolveCredit; InfoForOwnedWeapon |
| H6 | A burn keeps a weighted credit list; each application adds its stacks for the gun being credited; XP is split by weight | DOT:122, DOT:40, P:1120, P:1392 | TFLV_Upgrade_Dot.GiveStacks; AddCredit; ResolveCredit; OnDamageDealt |
| H7 | Each tic each hand's weapon gets its record; the old record's upgrades deactivate, the new one's activate | P:1555, P:598, P:551, P:553, P:556 | TickStats; RebuildWeaponInfo; CreateInfoForHand |
| H7 | A weapon with no record gets a new one at XP 0, level 0 | P:622, P:624, W:40, W:41 | GetOrCreateInfoFor; TFLV_WeaponInfo.Init |
| H8 | Incoming damage goes through the player's upgrades and both hands' weapons' upgrades | P:1481, P:1487 | TFLV_PerPlayerStats.ModifyDamage |
| H9 | Crossing the level's cost: the level-up event, the flash, the sound, the ready message; chosen at once when choices are 0 or 1 | W:229, W:235, W:238, W:241, W:244, W:245, W:247 | TFLV_WeaponInfo.AddXP; Fanfare |
| H10 | The info key first tries each hand's weapon level, main hand first | E:238, E:195, E:197, W:268, W:270 | NetworkProcess; ShowInfo; TFLV_WeaponInfo.StartLevelUp |
| H10 | Gun Bonsai's weapon level-up menu name is pointed at a router that opens this mod's screen | menudef.rsq:135, menudef.rsq:137, R:40, R:18, DI:98, AH:12, AM:398 | MENUDEF; RSQUI_WeaponLevelUpRouter.Init; RSQUI_Routing.RouteTick; RSQUI_Dispatch.MenuFor; RSQUI_A_Skin.WeaponLevelUpMenu |
| H10 | Title is the weapon's tag; four cards a page; description; NEW or the level it goes to | M:61, AM:318, AM:326, AM:374, AM:382, AM:386 | RSQUI_LevelUpMenu.Init; RSQUI_A_CardsDraw.Draw; DrawCard |
| H11 | Left / up one card back, right / down one on, wrapping; page keys four | M:106, M:110, M:113, M:115 | RSQUI_LevelUpMenu.MenuEvent |
| H12 | Select sends the choice to Gun Bonsai and closes | M:117, M:88, M:89, E:252, E:221 | MenuEvent; Pick; NetworkProcess; ChooseLevelUpOption |
| H12 | A finished level: XP less the cost, level up one, 1 player XP, a new cost, the upgrade added | W:306, W:307, W:308, W:309, W:315 | TFLV_WeaponInfo.FinishLevelUp |
| H13 | Keys 1 to 4 pick that card of the page shown | M:136, M:138, M:139 | RSQUI_LevelUpMenu.OnUIEvent |
| H14 | Back sends choice -1; a refused weapon level costs its whole cost, a refused player level half | M:124, W:279, P:1298 | MenuEvent; TFLV_WeaponInfo.RejectLevelUp; TFLV_PerPlayerStats.RejectLevelUp |
| H15 | Player XP reaching the cost: event, two blends (35 and 105 tics), sound, message; chosen at once when choices are 0 or 1 | P:1256, P:1257, P:1266, P:1267, P:1273, P:1277 | AddPlayerXP; TFLV_PerPlayerStats.Fanfare |
| H16 | With no weapon level started, the info key starts a waiting player level | E:199, P:1288, P:1289 | ShowInfo; TFLV_PerPlayerStats.StartLevelUp |
| H16 | The player level-up screen and its title | menudef.rsq:141, menudef.rsq:143, AH:13, AM:403, M:53 | MENUDEF; RSQUI_A_Skin.PlayerLevelUpMenu; RSQUI_LevelUpMenu.Init |
| H17 | Nothing waiting: the first browse starts on the main hand, later ones step to the next hand holding a weapon; the status menu opens | E:205, E:206, E:207, P:430 | ShowInfo; AdvanceMenuHand |
| H17 | The status menu name is pointed at this mod's STATUS screen; the cursor starts on the hand Gun Bonsai stepped to | menudef.rsq:129, menudef.rsq:131, R:28, AH:11, M:174, M:175 | MENUDEF; RSQUI_StatusRouter.Init; RSQUI_StatusMenu.Init |
| H17 | PLAYER STATUS with level, XP, upgrades; a card per hand with picture, name, LV, XP; WEAPON STATUS; DESCRIPTION | AM:126, AM:128, AM:130, AM:138, AM:117, AM:169, AM:179, AM:180, AM:182, AM:190, AM:193, AM:266 | RSQUI_A_StatusMenu.DrawPlayerPanel; Drawer; DrawGun; DrawDescription |
| H18 | Up / down move one row and wrap; the rows in order; the description text | M:308, M:309, M:292, M:194, M:195, M:197, M:345, M:353 | RSQUI_StatusMenu.MenuEvent; Move; Rebuild; RowDescription |
| H19 | On a weapon row: right or select jumps to its first upgrade, left to the first player upgrade; no such row, nothing | M:322, M:333, M:300 | MenuEvent; JumpTo |
| H20 | Select on an upgrade row sends the toggle; the hand is sent first; Gun Bonsai flips `enabled` | M:329, M:331, M:238, DI:136, E:258, E:275, E:277, E:280, W:66, P:1232 | MenuEvent; SendHand; RSQUI_Handler.NetworkProcess; ToggleUpgrade |
| H20 | An upgrade that is off is grey and marked [OFF] | AM:250, AM:252 | RSQUI_A_StatusMenu.DrawList |
| H21 | Left / right send the tune by -1 / +1; clamped from 1 to max_level; nothing when off; shown level/max | M:313, M:318, E:262, E:292, W:76, W:78, P:1242, P:1244, AM:254 | MenuEvent; TuneUpgrade; DrawList |
| H22 | The info key typed while the screen is open: the other hand's weapon, or close; only a one-character key name | M:256, M:261, M:265, M:273, M:283 | RSQUI_StatusMenu.OnUIEvent; IsInfoKey |
| H23 | The bottom row: per hand reserve and magazine on that hand's side, the face, health, armour | AH:28, AH:46, AH:50, AH:51, AH:65, AH:71, AH:78 | RSQUI_A_Skin.DrawHud; DrawBottom |
| H23 | Two pools: the smaller is the magazine; one pool: the reserve only | DA:56, DA:58, DA:63 | RSQUI_Hand.ReadAmmo |
| H23 | Drawn only with the skin on and the row on; both default on | DI:34, cvarinfo.txt:67, cvarinfo.txt:73 | RSQUI_Dispatch.BottomOn |
| H24 | A new `LD<Slot>Effect_<Power>` item starts the card; 105 tics up, 14 folding, a title look every 10 | L:97, L:253, L:262, L:48, L:49, L:50, L:521 | RSQGB_LDHud.Parse; UiTick; DrawCard |
| H24 | LegenDoom's messages 12300 to 12303 are detached while the card is live and the card switch is on | L:265, L:273, L:275 | UiTick; HideLD |
| H24 | The card: title, rarity and gun, description (first paragraph), icon; centred under the gauges; it shrinks to the row | L:530, L:534, L:541, L:563, L:441, L:447 | DrawCard; RenderOverlay |
| H24 | Card switch, default on | L:85, cvarinfo.txt:50 | CardOn |
| H25 | For each hand's weapon with a power: the row under its gauge; icon, name, drain line, X3 for Murderous | L:423, L:424, L:431, L:488, L:493, L:498, L:467, L:499 | RenderOverlay; DrawRow |
| H25 | Row switch, default on; the same power on the STATUS screen | L:86, cvarinfo.txt:51, AM:212, AM:223 | RowOn; RSQUI_A_StatusMenu.DrawGun |
| H26 | A Distance Grab throw, the hook, or a thrown gun with no record: XP to the pool, no weapon | P:1374, P:1376 | OnDamageDealt |
| H26 | A throw is this player's, a blast it set off, or 105 tics old at most | P:897, P:898, P:900 | IsSuiteThrow |
| H26 | Every base level cost of pool XP is 1 player XP | P:919, P:920, P:922 | AddPoolXP |
| H27 | A weapon nobody owns that still has a record pays that record | P:325, P:1133, P:1134, P:1138 | IsLooseWeapon; ResolveCredit |
| H28 | Force damage (inflictor or master `UBQS_Force`) pays the Force hand's record, else the main saber's | P:309, P:311, P:316, P:317, P:318, P:1123, P:1129 | IsForceCause; ForceInfo; ResolveCredit |
| H28 | The Force hand is not a candidate in the guess | P:305, P:1008, P:1009 | IsInertHand; ScoreHandFor |
| H29 | `BrutalAxe` and `RSQ_Off_BrutalAxe` share one record, found from either; never pruned | W:115, W:121, P:533, P:657 | TFLV_WeaponInfo.OneWeaponKey; Holds; GetInfoFor; PruneStaleInfo |
| H30 | Score XP only with the factor above 0; the rise is split over kills of the last 70 tics by spawn health; a throw's share pools | P:1586, P:1618, P:1623, P:1629, P:1631, P:1632, P:1431 | TickStats; OnKill |
| H31 | The alias sends `bonsai-debug,hands`; it prints the hands and the counters | keyconf.txt:3, E:264, DB:23, DB:84, DB:95 | KEYCONF; NetworkProcess; TFLV_Debug.DebugCommand; ShowHandsConsole |
| H32 | Dual HUD off: one gauge with Gun Bonsai's own HUD settings, for the preferred hand, else the other | E:181, E:182, H:81, P:498, P:500, cvarinfo.txt:14 | RenderOverlay; TFLV_HUD.Draw; GetInfoForHUD |
| H33 | Single HUD Follows: 0 main, 1 off, 2 the hand that last earned XP | P:496, P:1328, menudef.rsq:38, menudef.rsq:39, menudef.rsq:40, menudef.rsq:70 | GetInfoForHUD; AddXPTo; MENUDEF |
| H34 | Skin off: no skin object, the routers stay Gun Bonsai's own menus | SK:25, SK:31, DI:96, R:14, R:31 | RSQUI_Skin.On; Current; RSQUI_Dispatch.MenuFor; RSQUI_Routing.RouteTick |
| H34 | Gun Bonsai's status menu shows the stepped hand, labels it and says to press again | SD:15, SD:34, SD:35, E:206 | TFLV_Menu_StatusDisplay.Init; ShowInfo |
| H34 | No bottom row and no pulse with the skin off | DI:34, H:444, H:537 | BottomOn; DrawHUD; RSQGB_BarLife.MockupOn |
| H35 | Cycle off: Gun Bonsai's colour unless a level waits | H:397, H:401, H:434 | CycleOn; CycleOr; DrawHUD |
| H36 | Card off: LegenDoom's messages are not detached and no card is drawn | L:265, L:392, L:404 | UiTick; RenderOverlay |
| H37 | Row off: the row is asked for its place only (alpha 0) | L:431, L:472 | RenderOverlay; DrawRow |
| H38 | Left layout: `vr_control_scheme` 10 or more; the gauges reflect; the ammo sides follow | H:163, H:165, H:122, H:123, DA:13, AH:46 | TFLV_HUD.RSQ_LeftLayout; CalibrateForHand; RSQUI_Hand.OnLeft |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Loads after Gun Bonsai; its files replace Gun Bonsai's by path; version string | build.ps1:8, zscript.txt:5, zscript.txt:6, E:15 | build script; ZSCRIPT header; TFLV_EventHandler.OnRegister |
| W1 | The three menu names are redefined; a link on Gun Bonsai's options page | menudef.rsq:129, menudef.rsq:135, menudef.rsq:141, menudef.rsq:30, menudef.rsq:33 | MENUDEF |
| W1 | Juggler and Rapid Fire act on each hand's own psprite | ca.ancilla.bonsai/upgrades/Juggler.zsc:37, ca.ancilla.bonsai/upgrades/Juggler.zsc:38, ca.ancilla.bonsai/upgrades/RapidFire.zsc:52, ca.ancilla.bonsai/upgrades/RapidFire.zsc:55 | TFLV_Upgrade_Juggler.Tick; TFLV_Upgrade_RapidFire.Tick |
| W2 | `loaded` 0 (Unlocks is false), `present` 1, in play, ui and data scope | C:310, C:314, C:315, C:321, C:328, C:329 | RSQ_MeleeUpgradeService.Unlocks; GetIntUI; GetIntData; GetInt |
| W2 | `level`, `plevel`, `unlocked`, `punlocked` return 0 before anything is read | C:330 | GetInt |
| W2 | `weapon.level`, `weapon.xp` | C:342, C:350, C:351 | GetInt |
| W2 | `claim` | C:371, C:377, C:379 | GetInt |
| W2 | `credit.push`, `credit.pop` | C:382, C:388 | GetInt |
| W2 | `stagger`, at most 350 tics | C:391, C:397 | GetInt |
| W2 | `freeze`, at most 700 tics; the shatter; a boss slowed; a hit of 20 or more | C:403, C:409, C:410, C:540, C:565, C:509 | GetInt; RSQ_Dazed.Freeze; ModifyDamage |
| W2 | `knockdown`, at most 10, not a boss | C:413, C:416, C:419 | GetInt |
| W2 | `whip.mark`, 70 tics | C:424, C:430, C:508, C:559 | GetInt; RSQ_Dazed.Mark |
| W2 | `is.melee` | C:433, C:442 | GetInt |
| W2 | `kr.luckyfx`, text `kr.lucky`, number `force.start`, `upgrade.num` 0 | C:448, C:466, C:481, C:482 | GetInt; GetString; GetDouble |
| W2 | Any other request (`ram`, `head.mps`) falls through to 0 | C:458, C:483 | GetInt; GetDouble |
| W3 | `RSQGB_Service` and each request | S:40, S:112, S:113, S:121, S:124, S:125, S:126, S:127, S:128, S:166, S:177 | RSQGB_Service; RSQGB_Read.IntOf; StrOf |
| W3 | -1 or empty with no record | S:123, S:165 | IntOf; StrOf |
| W4 | `RSQ_HudService`: `gauges.top`, `gauges.bottom`, permille, -1 when none | HS:8, HS:12, HS:13, HS:17 | RSQ_HudService.GetIntUI |
| W5 | `RSQTHP_MarkerGBVR`: `stunned` | C:748, C:752, C:755 | RSQTHP_MarkerGBVR.GetInt |
| W6 | Melee asks `claim`, `stagger`, `is.melee` of the service whatever `loaded` says, and gates its moves on `loaded` | Melee/zscript/rsqml/core.zs:154, Melee/zscript/rsqml/core.zs:163, Melee/zscript/rsqml/core.zs:193, Melee/zscript/rsqml/core.zs:63 | RSQML.Claim; Stagger; IsSlapperClass; GB |
| W6 | Glove and fist pictures by name | AM:87, AM:88, AM:90 | RSQUI_GunPic.Get |
| W7 | The Saber's classes by name; the Saber gates on `loaded` | P:305, P:309, P:316, P:318, QuestSaber/zscript.txt:7543 | IsInertHand; IsForceCause; ForceInfo; UBQS_Upg.Svc |
| W8 | ShieldSaw: bracket round the bash, the grind and the rev block; the returned bullet claimed; `ram` asked; gated on `loaded` | ShieldSaw/zscript/ssq/guard.zs:849, ShieldSaw/zscript/ssq/guard.zs:851, ShieldSaw/zscript/ssq/state.zs:1368, ShieldSaw/zscript/ssq/guard.zs:327, ShieldSaw/zscript/ssq/guard.zs:626, ShieldSaw/zscript/ssq/guard.zs:909, ShieldSaw/zscript/ssq/score.zs:192 | SSQ code; SSQ_Upg.Svc |
| W9 | Whip: the bracket; Long Thong read behind `loaded`; the whip's picture | Whip/zscript/rsqwp/fx.zs:62, Whip/zscript/rsqwp/fx.zs:65, Whip/zscript/rsqwp/whip.zs:131, Whip/zscript/rsqwp/whip.zs:135, AM:78, AM:86 | RSQWP_Perks.Hurt; RSQWP_Whip.GbRefresh; RSQUI_GunPic.Get |
| W10 | Grenade: `claim` for the thrown grenade, the quick grenade, bomblets and type blasts; types gated on `loaded` | Grenade/zscript/rsqgn/hand.zs:777, Grenade/zscript/rsqgn/hand.zs:841, Grenade/zscript/rsqgn/thrown.zs:367, Grenade/zscript/rsqgn/kinds.zs:255, Grenade/zscript/rsqgn/kinds.zs:197, Grenade/zscript/rsqgn/upg.zs:18 | RSQGN code; RSQGN_Upg.Svc |
| W11 | Distance Grab's throw service and the three requests | P:894, P:897, P:898, P:899, DistanceGrab/zscript/rsqdg/throw.zs:375 | IsSuiteThrow; RSQDG service |
| W12 | The Rig's thrown gun is the inflictor and has no owner; its nodes read behind `loaded` | TacticalRig/zscript/rsqtr/rig.zs:1703, P:325, P:1374, TacticalRig/zscript/rsqtr/rig.zs:252, TacticalRig/zscript/rsqtr/rig.zs:259 | RSQTR code; IsLooseWeapon; OnDamageDealt |
| W13 | This mod asks `hook.dealing`; the Grapple answers -1 to every request not starting `g2.`; its kick is dealt by the player with no bracket | P:911, P:913, Grapple/zscript/rsqgr/service.zs:53, Grapple/zscript/rsqgr/core.zs:791 | IsSuiteHook; RSQGR_Service.GetInt |
| W14 | Score asks the gauges' band; this mod reads Score's four numbers each frame; `rs_score_hide` only put back | Score/zscript/rsscore/hud.zs:621, Score/zscript/rsscore/hud.zs:624, DA:138, DA:141, DA:142, DA:143, DI:66, DI:87 | RS Score HUD; RSQUI_Data.ReadScore; RSQUI_Dispatch.Housekeep; Manage |
| W15 | `bonsai-level-up` sent by this mod's copies and heard by VisualRewards; it asks `RSQGB_Service`; the marker; Kill Rewards' asks | P:1262, W:235, VisualRewards/pk3/zscript/rsqthp/damnums/events.zs:237, VisualRewards/pk3/zscript/rsqthp/damnums/events.zs:259, VisualRewards/pk3/zscript/rsqthp/damnums/events.zs:292, VisualRewards/pk3/zscript/rsqthp/handler.zs:135, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:104, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:929 | Fanfare; RSQVR code |
| W15 | The card's letters are the QVW glyphs when present, else SmallFont | L:331, L:336, L:345 | RSQGB_LDHud.Sotn |
| W16 | Wheel reads level, permille, upgrades; the watch card reads `weapon.level`, `weapon.xp`; its icons as fallbacks | Wheel/zscript/wheel/wr_q_bonsai.zs:53, Wheel/zscript/wheel/wr_q_bonsai.zs:56, Wheel/zscript/wheel/wr_q_bonsai.zs:57, Wheel/zscript/wheel/wr_q_watch.zs:141, Wheel/zscript/wheel/wr_q_watch.zs:143, AM:86, AM:90 | WR code; RSQUI_GunPic.Get |
| W17 | Gun Cards reads level, permille, upgrades | GunCards/zscript/rsqgc/bonsai.zs:49, GunCards/zscript/rsqgc/bonsai.zs:52, GunCards/zscript/rsqgc/bonsai.zs:53 | RSQGC code |
| W18 | Miniboss reads level, xp, xp.next; its ward makes a boss | Miniboss/zscript/rsqmb/bossfight.zs:273, Miniboss/zscript/rsqmb/bossfight.zs:388, C:200, C:202, C:416, C:540 | RSQMB code; RSQM.IsBoss |
| W19 | Glow In The Dark reads name, level, xp.permille | GlowInTheDark/zscript/rsqgd/react.zs:255, GlowInTheDark/zscript/rsqgd/react.zs:265, GlowInTheDark/zscript/rsqgd/react.zs:268, GlowInTheDark/zscript/rsqgd/react.zs:269 | RSQGD code |
| W20 | SlowMo and LaserSight gate on `loaded` | SlowMo/zscript/rsqsm/clock.zs:171, LaserSight/zscript/rsqls/sight.zs:263 | GbRefresh |
| W20 | This mod's SlowMo calls sit in three helpers with no caller | C:134, C:237, C:245 | RSQM.Slowed; Pulse; Charge |
| W22 | LegenDoom: items by name, icons by folder, strings, message ids; the rows greyed without it | L:95, L:123, L:128, L:273, menudef.rsq:90, menudef.rsq:92, N:12, N:29 | Parse; RarityOf; Loc; HideLD; MENUDEF; RSQGB_Needs.Loaded |
| W23 | BD22 VR: the round by name, tied to the hand that traced this tic; the round's own trace opens the bracket | P:1073, P:1076, P:1078, E:369 | TraceProvenance; WorldHitscanPreFired |
| W23 | The axe; the slot service; `rsq_hud_nohp` | W:115, L:139, AH:69, AH:70 | OneWeaponKey; SlotOf; DrawBottom |
| W24 | Brutal Doom: `bd_sbartype` set to 5 while the row draws, saved and put back; the fist sprite | DI:70, DI:82, DI:83, DI:87, AM:90 | Housekeep; Manage; RSQUI_GunPic.Get |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No upgrade class: the ZSCRIPT lump includes fifteen files, none an upgrade file; the header says so; BONSAIRC is one comment | zscript.txt:2, zscript.txt:10, zscript.txt:24, bonsairc.rsq:1 | ZSCRIPT; BONSAIRC |
| L2 | `loaded` 0 and every level 0 | C:310, C:328, C:330 | Unlocks; GetInt |
| L3 | This mod's classes extend Gun Bonsai's | R:23, build.ps1:8 | RSQUI_StatusRouter |
| L4 | Only menu events and typed keys are handled | M:99, M:131, M:254, M:303 | MenuEvent; OnUIEvent |
| L5 | Back refuses | M:119, M:124 | RSQUI_LevelUpMenu.MenuEvent |
| L6 | Digits past 4 are ignored | M:139 | OnUIEvent |
| L7 | No weapon record in either hand closes the STATUS screen on its first tic | M:246 | RSQUI_StatusMenu.Ticker |
| L8 | The second press is matched as a typed character against a one-character key name; both guns are drawn | M:273, M:283, AM:117 | IsInfoKey; RSQUI_A_StatusMenu.Drawer |
| L9 | Nothing over a menu, the automap or with screenblocks above 11 | E:119, E:120, E:122, DI:126, DI:127, L:387 | ShouldDrawHUD; RSQUI_Handler.RenderOverlay; RSQGB_LDHud.RenderOverlay |
| L10 | The frame and bars use the same cycle whether or not a level waits, while the cycle is on | H:434, H:441, H:442 | DrawHUD |
| L11 | Gauge Size (`rsq_ui_hud_scale`) is read only in the bottom row's frame; the gauges take Gun Bonsai's own HUD settings | menudef.rsq:63, DR:71, AH:25, H:102 | MENUDEF; RSQUI_Pen.HudFrame; DrawHud; CalibrateForHand |
| L12 | The per-hand anchors are read only for a hand's gauge; the single gauge uses Gun Bonsai's settings | H:107, H:111, H:81 | CalibrateForHand; Draw |
| L13 | The guess, and its counters in the hands dump | P:1098, P:1103, P:1106, DB:95 | ResolveSpawn; ShowHandsConsole |
| L14 | 96 records, the oldest dropped; a minute at most | P:209, P:210, P:713, P:715, P:816 | PushProvenance; PruneProvenance |
| L15 | The records are cleared whenever the stats are set up again (new map, load) | P:1537 | Initialize |
| L16 | `bd_sbartype` is put back only by this code | DI:85, DI:87 | Manage |
| L17 | Only message ids 12300 to 12303 are removed | L:273 | HideLD |
| L18 | The upgrade strings: first and last name lines; 197 `_Name` keys | language.rsq:5, language.rsq:608 | LANGUAGE |
