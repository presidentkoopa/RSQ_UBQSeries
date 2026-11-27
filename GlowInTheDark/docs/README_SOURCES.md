# RSQ Glow In The Dark: where each README claim comes from

Commit read: a283738bb (2026-11-27). Paths are inside `GlowInTheDark/` unless they start with another mod's folder.
`H` is `zscript/rsqgd/handler.zs`, `R` is `zscript/rsqgd/react.zs`, `T` is `zscript/rsqgd/things.zs`, `V` is
`zscript/rsqgd/service.zs`, `D` is `zscript/rsqgd/ddz.zs`, `L` is `zscript/rsqgd/liquid.zs`, `P` is
`zscript/rsqgd/profiles.zs`, `M` is `zscript/rsqgd/menu.zs`; other files are named in full. Each line number is the line
that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | At map start (not a save) every sector's floor and ceiling glow is written from the look | H:208, H:264, H:268, H:570, H:573 | RSQGD_Handler.WorldLoaded; WriteSector |
| H1 | Classic (1.1): "R" both planes, height 64; each channel 25 + 0..230; one key per tag group (the highest tag, 0 untagged) for Classic and Custom at By Profile | P:31, H:348, H:235, H:331, H:335, H:336, H:337, CVARINFO.txt:6 | RSQGD_Profiles.Row; RSQGD_Handler.PickColour; WorldLoaded; RebuildLook |
| H1 | Every Map: a new seed each map; the switches on | H:288, H:289, CVARINFO.txt:5, CVARINFO.txt:7, CVARINFO.txt:14, H:458 | RSQGD_Handler.ChooseSeed; ComputePlane |
| H2 | Compress at preset 3: light x (1 - 96/256); sky rooms x Sky Sectors (1.0) | D:58, D:77, D:86, D:95, CVARINFO.ddz:9, CVARINFO.ddz:10, CVARINFO.ddz:13 | RSQGD_DDZ_Handler.ChangeLighting |
| H3 | A listed flat is a liquid of a kind; Classic's liquid style 0 is the kind's own colour; 128 x Glow Height / 64 tall; living: breathes at the kind's rate | L:102, L:104, H:401, H:405, H:415, H:419, H:421, H:423, H:424, L:43, CVARINFO.txt:15, CVARINFO.txt:16, CVARINFO.txt:18 | RSQGD_Liquid.Classify; RSQGD_Handler.ComputePlane |
| H4 | Not listed: guessed by name (or the floor's TERRAIN) only with the row on | L:107, L:83, L:84, L:85, L:86, L:87, L:88, L:92, CVARINFO.txt:20 | RSQGD_Liquid.Classify; Heuristic |
| H5 | A damaging floor that is not a liquid: red, 40 a minute | H:249, H:433, H:436, H:437, CVARINFO.txt:21 | RSQGD_Handler.WorldLoaded; ComputePlane |
| H6 | A floor named GATE...: cyan shimmer, with Switches and Exits on | H:251, H:448, H:451, CVARINFO.txt:28 | RSQGD_Handler.WorldLoaded; ComputePlane |
| H7 | A line with a special used, shot or pushed (not a door or exit): amber on all three parts of its front | T:100, T:42, T:74, T:75, T:76 | RSQGD_Handler.ScanThings; KindColour; PaintLine |
| H8 | Exits (used or shot only): green, breathing 18 a minute | T:98, T:101, T:43, T:120, T:122, T:123 | RSQGD_Handler.ScanThings; KindColour; ThingsTick |
| H9 | Locked doors: the lock's colour (red, blue, yellow, else lavender) at 0.45, breathing 18 a minute | T:95, T:96, T:97, T:30, T:31, T:32, T:34, T:61, T:122 | RSQGD_Handler.ScanThings; LockColour; PaintLine; ThingsTick |
| H10 | Any player holding the key: 50 a minute, brighter | T:121, T:122, T:124, T:131 | RSQGD_Handler.ThingsTick; HaveKey |
| H11 | Ordinary doors: a faint cool colour, with the row on | T:99, T:41, CVARINFO.txt:29 | RSQGD_Handler.ScanThings; KindColour |
| H12 | Keys and powerups drawn bright at Keys; normal once picked up | T:147, T:150, T:179, T:187, T:208, CVARINFO.txt:31 | RSQGD_Handler.ItemKind; ItemWanted; GlowItem; ItemLightsSecond |
| H13 | Darker rooms: up to x1.6 strength, x1.4 height | H:483, H:484, H:485, CVARINFO.txt:23 | RSQGD_Handler.ComputePlane |
| H14 | Something dying within 24 units of a liquid floor: an 18-tic flare in its colour | H:751, H:753, H:756, H:758, H:30, CVARINFO.txt:19 | RSQGD_Handler.WorldThingDied; Flare |
| H15 | Shuffle Profile: another named profile at random, re-rolled 2 tics later; on Custom or Random Profile only a re-roll | MENUDEF.txt:104, H:814, H:817, H:822, H:614, H:825 | RSQGD_Handler.NetworkProcess; WorldTick |
| H16 | Randomize Look: every Custom setting drawn, Profile set to Custom, re-rolled 2 tics later | MENUDEF.txt:106, H:828, H:865, H:875, H:881, H:882, H:884, H:613, H:890 | RSQGD_Handler.RandomizeLook; RandomizeApply |
| H17 | Randomize Colours: the menu row runs the alias, a network event; a re-roll, the profile kept | MENUDEF.txt:117, KEYCONF.txt:2, H:833, H:840 | RSQGD_Handler.NetworkProcess |
| H18 | Refused while the boss tint, a timed tint, the life flash or any DOWN holds; the line only on the presser's machine | H:806, H:808, H:835, H:837, H:301, H:303 | RSQGD_Handler.NetworkProcess; SequenceBusySynced |
| H19 | Profile steps through every row by name, left, right or a click; 37 rows | MENUDEF.txt:100, M:43, M:44, M:50, M:37, P:29, P:65 | OptionMenuItemRSQGDProfile.MenuEvent; Activate; Step |
| H20 | Pair Darkness to Profile: the profile's mode and preset fields; greyed below the named rows | MENUDEF.txt:234, M:87, M:88, M:71 | OptionMenuItemRSQGDPairing.Activate; IsGrayed |
| H21 | Settings read once a second; a change rebuilds the look and rewrites the map | H:616, H:666, H:673, H:675 | RSQGD_Handler.WorldTick; Second |
| H22 | Never: the seed is rsqgd_seed (1337); a re-roll writes a new one there | H:287, CVARINFO.txt:9, H:311 | RSQGD_Handler.ChooseSeed; Reroll |
| H23 | On Death: deaths counted by the session; a new seed at the next map start or load; at once in a netgame | H:918, H:288, H:727, H:737 | RSQGD_Session.PlayerDied; RSQGD_Handler.ChooseSeed; AfterLoad; PlayerDied |
| H24 | Level Up: a re-roll on a Gun Bonsai level up | H:905, R:239, R:254 | RSQGD_Handler.LevelUp; BonsaiEvent; PollBonsai |
| H25 | Timed: every rsqgd_reroll_min (5) minutes since the map started or the last re-roll | H:693, H:260, H:313, CVARINFO.txt:8 | RSQGD_Handler.Second; WorldLoaded; Reroll |
| H26 | Secret Rooms Shimmer: gold on a secret sector while it is still secret | H:250, H:441, H:443, CVARINFO.txt:22 | RSQGD_Handler.WorldLoaded; ComputePlane |
| H27 | (two rows) Liquid Colour: Room Colour skips the liquid branch (the room's colour); Own Colour forces style 0 | H:401, H:458, H:465, H:405, MENUDEF.txt:38, MENUDEF.txt:40 | RSQGD_Handler.ComputePlane |
| H28 | One Colour Per: Tag Group, Each Room, or the profile | H:330, H:331, H:335 | RSQGD_Handler.RebuildLook |
| H29 | Blend Rooms: each floor colour mixed half way to its neighbours' average | H:339, H:373 | RSQGD_Handler.RebuildLook; BlendNeighbours |
| H30 | Plus Health: health and armour; Plus Ammo: ammo and weapons too | T:157, T:158, T:159, T:179 | RSQGD_Handler.ItemKind; ItemWanted |
| H31 | Lights over the largest pools and on the most important items, capped by the rows (default 0) | T:253, T:272, T:281, T:216, T:219, T:227, CVARINFO.txt:67, CVARINFO.txt:68 | RSQGD_Handler.SpawnLiquidLights; ItemLightsSecond |
| H32 | Off: each plane gets the map's own glow; DarkDoomZ mode 0 and no gains or fog; no lines; items normal | H:391, D:57, D:58, D:60, D:63, T:85, T:177 | RSQGD_Handler.ComputePlane; RSQGD_DDZ_Handler.ChangeLighting; ScanThings; ItemWanted |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQMB_Service "miniboss" every 10 tics; the first live boss's "colour", else 0xB00008; the heartbeat tint and its climb | H:617, R:34, R:35, R:96, R:99, R:104, H:493, H:494, H:495, CVARINFO.txt:35, CVARINFO.txt:36 | RSQGD_Handler.PollMiniboss; MinibossColour; ComputePlane |
| W1 | Darken: DarkDoomZ's post-gain lowered by rsqgd_mb_dark (48) while it lives, put back after | H:619, R:135, R:146, R:153, CVARINFO.txt:38, CVARINFO.txt:39 | RSQGD_Handler.WorldTick; Darken |
| W1 | Miniboss asks event.tint, event.dark, event.wave, event.reroll | Miniboss/zscript/rsqmb/bossfight.zs:248, Miniboss/zscript/rsqmb/bossfight.zs:1207, Miniboss/zscript/rsqmb/fight.zs:54, Miniboss/zscript/rsqmb/fight.zs:124 | (Miniboss's calls) |
| W1 | The answers: a tint for its seconds; DarkDoom Black held, alone only; a wave from the actor; a re-roll refused at Never | V:65, V:66, V:75, R:58, R:64, V:54, V:72 | RSQGD_Service.GetInt; RSQGD_Handler.DropDark |
| W2 | RSQSM_Service "active" and "scale": drained toward a cold grey | R:190, R:191, R:193, H:490, H:155 | RSQGD_Handler.PollSlowMo; ComputePlane; Drain |
| W2 | "down.redmap": deep red, beating; "down.any" holds the buttons; "down" per player stops the drop darkness | R:201, H:501, H:502, H:303, R:83 | RSQGD_Handler.PollSlowMo; ComputePlane; SequenceBusySynced; AnyDown |
| W2 | SlowMo asks "ddz.original"; answered while the drop darkness holds | SlowMo/zscript/rsqsm/downlook.zs:288, V:41 | (SlowMo's DOWN darkness); RSQGD_Service.GetIntData |
| W3 | RS_ScoreService "kill.serial" per player; each kill within 4 s adds 0.08, up to 10; fades after 4 s | R:212, R:218, R:222, R:224, H:487, H:623, CVARINFO.txt:42, CVARINFO.txt:43 | RSQGD_Handler.PollScore; ComputePlane; WorldTick |
| W3 | Score asks event.lifeflash; grey and white 105 tics, then its own colours strongly, then 35 tics back | Score/zscript/rsscore/handler.zs:1175, V:70, H:535, H:536, H:541, H:553, H:559, H:560 | RSQGD_Service.GetInt; RSQGD_Handler.StartLifeFlash; LifeFlash |
| W4 | RSQGB_Service "name", "level", "xp.permille" per hand; a wave on a full bar, once a level, in the wave colour | R:255, R:265, R:268, R:269, R:271, H:904, CVARINFO.txt:40, CVARINFO.txt:41 | RSQGD_Handler.PollBonsai; LevelUp |
| W5 | Plain Gun Bonsai's "bonsai-level-up" for a weapon, only without RSQGB_Service | H:804, R:238, R:240, R:248 | RSQGD_Handler.NetworkProcess; BonsaiEvent |
| W6 | Grenade asks "enabled" and reads the sector's glow colour | Grenade/zscript/rsqgn/explosions.zs:615, Grenade/zscript/rsqgn/explosions.zs:630, V:35 | (Grenade's RoomTint, RoomHueTint); RSQGD_Service.GetIntData |
| W7 | DarkDoomZ's flashlight removed here; FnF has its own copy of the spill light | D:3, D:4, FlashFlare/zscript/rsqff/ddzlight.zs:115 | (headers) |
| W8 | Accessibility: no class, cvar or service of it is read; only comments name it | H:532, zscript/rsqgd/rsmenu.zs:387 | (comments) |
| W9 | DarkDoomZ built in: its cvars under its own names; its handler; the separate pk3 must not load too | CVARINFO.ddz:9, CVARINFO.ddz:16, CVARINFO.ddz:6, MAPINFO.txt:3, D:13, CREDITS.txt:65 | (CVARINFO, MAPINFO) |
| W10 | The shared menu code looks for RSQ_MeleeUpgradeService | zscript/rsqgd/rsmenu.zs:109 | RSQGD_RSMenu.GbLoaded |
| W11 | One Radiant Silvergun Options entry; this page added | MENUDEF.txt:11, MENUDEF.txt:19, MENUDEF.txt:24 | MENUDEF |
| W12 | The service's reads and events | V:34, V:35, V:36, V:37, V:38, V:39, V:40, V:41, V:51, V:57, V:63, V:70, V:72, V:73, V:92 | RSQGD_Service.GetIntData; GetInt; GetStringData |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | What is written: plane glow (drawn on walls), wall parts' additive colour, item brightness; real lights capped at 0 by default | H:570, H:573, T:52, T:53, T:187, CVARINFO.txt:67, CVARINFO.txt:68 | RSQGD_Handler.WriteSector; SetTier; GlowItem |
| L2 | An exit not used or shot is not lit | T:101 | RSQGD_Handler.ScanThings |
| L3 | DarkDoomZ keeps the light levels from the map's start and writes every sector from them when a setting moves | D:31, D:76, D:79, D:92, D:113, R:146 | RSQGD_DDZ_Handler.WorldLoaded; ChangeLighting; RSQGD_Handler.Darken |
| L4 | The drop darkness only when not multiplayer | R:58 | RSQGD_Handler.DropDark |
| L5 | Timed counts from lastRollTic, set to 0 at each map start | H:260, H:693 | RSQGD_Handler.WorldLoaded; Second |
| L6 | The three buttons refused while a sequence holds | H:301, H:303, H:806, H:835 | RSQGD_Handler.SequenceBusySynced; NetworkProcess |
| L7 | Loading darkdoomz.pk3 too stops the engine | CVARINFO.ddz:6, CVARINFO.ddz:7, CREDITS.txt:65 | (CVARINFO header) |
| L8 | No key: one alias | KEYCONF.txt:1, KEYCONF.txt:2 | KEYCONF |
| L9 | The six test events | H:851, H:852, H:853, H:854, H:855, H:856 | RSQGD_Handler.NetworkProcess |
