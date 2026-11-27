# RSQ Graveyards: where each README claim comes from

Commit read: a283738bb (2026-11-27). Line numbers moved to the working tree after the 2026-11-27 build of rising
made rare (Rise Chance 15, settings generation 1). Paths are inside `Graveyard/` unless they start with another mod's folder. `E` is
`zscript/gy_EventHandler.zs`, `S` is `zscript/gy_Storage.zs`, `T` is `zscript/gy_Stone.zs`, `B` is
`zscript/rsqgy/bones.zs`; other files are named in full. Each line number is the line that does the thing, not the
start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | A player's death (not a monster's) is stored: the spot, the obituary "Here lies <name>, killed by <killer>." with the date and map time, under the map's checksum, written to the three settings | E:88, E:97, E:99, E:107, E:109, S:138, S:144, S:145, S:201, S:202, S:203 | gy_EventHandler.worldThingDied; gy_Storage.registerDeath; write |
| H1 | Alone no spawn is sent at the death; the store is sent once when the map comes up (first world tic after a new map or a load) | E:114, E:30, E:35, E:47, E:81, E:235 | gy_EventHandler.worldThingDied; worldTick |
| H2 | In a netgame the dying player's machine sends the spawn at once; every machine makes the stone | E:114, E:121, E:137 | gy_EventHandler.worldThingDied; networkProcess |
| H3 | Only this map's records are sent; a stone at each stored spot, one of four classes by the spot | S:38, S:40, E:169, E:170, E:171, E:172, T:598, T:599, T:600, T:601, textures.txt:1 | gy_Storage.Next; gy_EventHandler.spawnStone |
| H3 | Alone, a stone standing in a loaded save whose record is still stored is kept; its key is skipped | E:61, E:63, E:128 | gy_EventHandler.worldTick; networkProcess |
| H4 | Pop from 0.05 over 24 tics, peak 1.35 at 35% of the way; stones made in the first 35 tics wait up to 35 tics; later ones at once; both rows | T:82, T:88, T:236, T:260, T:261, T:269, T:539, T:540, T:86, cvarinfo.txt:6, cvarinfo.txt:7 | gy_Stone.PostBeginPlay; animate; popScale |
| H5 | Squash and stretch: 0.05 deep at 1.5 degrees a tic (240 tics, about 7 s, a breath) | T:250, T:252, T:253, cvarinfo.txt:8, cvarinfo.txt:9 | gy_Stone.animate |
| H6 | Candle within gy_light_cull (640) of the nearest player, 3D; 0.05 a tic (20 tics) fade; radius 72; flicker | T:283, T:286, T:287, T:542, T:303, T:318, T:381, cvarinfo.txt:12, cvarinfo.txt:13, cvarinfo.txt:14, cvarinfo.txt:16 | gy_Stone.updateLight; flicker |
| H7 | Living Stones: light colour and tint from (110,170,230) to (250,240,140), one breath each 2000 ms (0.18 degrees a ms), Uniform by default; 8 tint steps | T:388, T:390, T:413, T:428, T:436, T:453, T:465, cvarinfo.txt:19, cvarinfo.txt:20, trnslate.txt:5 | gy_Stone.lightColor; livingPulse; livingRgb; updateTint |
| H8 | Use: VisualRewards loaded, an anchor for 140 tics, each line asked as "word.hold"; a second Use resets the anchor's life | T:133, T:145, T:149, T:152, T:159, T:590 | gy_Stone.Used; showWords |
| H8 | The lines: name (gold on a gold stone), KILLED BY <killer>, the date, MAP TIME <time>, wrapped at 20 characters | T:177, T:178, T:180, T:185, T:205 | gy_Stone.obituaryLines; wrapInto |
| H9 | No VisualRewards, or this machine's rsqvr_words off: the obituary printed, only for the user's own machine | T:136, T:145, T:161, T:162 | gy_Stone.Used; showWords |
| H10 | Remove Map Gravestones: the menu row runs the alias; this map's records dropped, every stone removed, the message printed | menudef.txt:88, keyconf.txt:4, E:145, E:147, E:148, E:149, S:171, E:222, language.txt:4 | gy_EventHandler.networkProcess; gy_Storage.clearThisMap; removeStonesOnMap |
| H11 | Remove All Gravestones: every record dropped, every stone removed, the message printed | menudef.txt:90, keyconf.txt:3, E:139, E:141, E:142, E:143, S:153, S:154, S:155, language.txt:3 | gy_EventHandler.networkProcess; gy_Storage.clearAll |
| H12 | The two console aliases send the same events | keyconf.txt:3, keyconf.txt:4 | KEYCONF alias |
| H13 | At most MAP_CAP (200) records a map; past it the oldest of this map go, and their stones are destroyed | S:67, S:82, S:94, S:96, S:147, E:110, T:52 | gy_Storage.trimThisMap; registerDeath; gy_Stone.removeKeyed |
| H14 | Score's "stone.life": "Here <name> lost a life, killed by <killer>." with the map time, kind 2, stored and spawned at once | E:255, E:266, E:271, E:274, E:276 | gy_RSQService.GetInt |
| H14 | The gold stone: gold tint, amber candle 2.2 times the radius with a second light half its size, a third of the flicker | T:454, T:464, trnslate.txt:2, T:395, T:303, T:559, T:331, T:561, T:380, T:560 | gy_Stone.updateTint; lightColor; updateLight; flicker |
| H15 | A monster's death with Legion of Bones loaded and the bridge on; its kind from the table or a vanilla parent | B:403, B:406, B:407, B:170, B:172, cvarinfo.txt:24 | gy_BonesHandler.WorldThingDied; gy_Bones.LobLoaded; BridgeOn |
| H15 | Rise Chance rolled once (15); a loser not queued | B:421, B:87, B:93, cvarinfo.txt:26 | gy_BonesHandler.WorldThingDied; gy_Bones.Chance; RollRise |
| H15 | Due after 25 tics and a delay rolled 0..4 (0, 170, 345, 520, 695 tics) with Random Delay on | B:428, B:429, B:430, B:95, B:73, B:70, cvarinfo.txt:29 | gy_BonesHandler.WorldThingDied; gy_Bones.RollDelay; WaitOf |
| H15 | The rising actor, its target the killer (the corpse's target), Legion of Bones' fire and the teleport sound; the corpse removed | B:416, B:565, B:238, B:280, B:284, B:285, B:603 | gy_BonesHandler.WorldThingDied; WorldTick; gy_Bones.RiseAt; Risen |
| H16 | Something On It: blocked, the wait again (at least HOLD_MIN 35 tics), counted; after HOLD_MAX (4) the nearest free spot beside, else stays dead | B:558, B:240, B:577, B:578, B:378, B:377, B:562, B:564, B:566, B:569, cvarinfo.txt:25 | gy_BonesHandler.WorldTick; gy_Bones.RiseAt |
| H16 | The spots beside: 3 rings of 8, in sight of the corpse and within a step of its floor | B:256, B:258, B:264, B:267, B:269 | gy_Bones.RiseNear |
| H17 | Legion of Bones' own raisers: rolled before the bridge test; a loser held on its corpse frame for good; a winner with Random Delay put on the wait frame its delay picks | B:405, B:473, B:474, B:511, B:513, B:166, B:524, B:526 | gy_BonesHandler.WorldThingDied; LobDied; LobTick; gy_Bones.Hold |
| H18 | Animate Gravestones off: scale back to 1, no animation | T:107, T:111, T:113, T:114, T:115 | gy_Stone.Tick |
| H19 | Pop In off: full size from the start | T:86, T:94, T:243, T:245 | gy_Stone.PostBeginPlay; animate |
| H20 | Grave Light off: the light fades to 0 and is removed | T:283, T:289, T:293 | gy_Stone.updateLight |
| H21 | Candle Flicker off: factor 1 | T:377 | gy_Stone.flicker |
| H22 | Living Stones off: warm candle (b, 0.72 b, 0.42 b); gold stone: gold tint and amber | T:396, T:395, T:454, T:463, T:464 | gy_Stone.lightColor; updateTint |
| H23 | Wave: phase by 2D distance to the nearest player, 360 degrees per 512 units | T:416, T:418, T:419, menudef.txt:116, menudef.txt:53 | gy_Stone.livingPulse |
| H24 | Chaos: rate 0.55 to 1.6 and a start of its own, from the spot | T:421, T:423, T:425, T:426, menudef.txt:54 | gy_Stone.livingPulse |
| H25 | What Stops a Rise: Nothing: no blocking test, it rises on time | B:558, B:565, B:240, menudef.txt:60 | gy_BonesHandler.WorldTick; gy_Bones.RiseAt |
| H26 | Random Delay off: -1, Legion of Bones' LOB_Respawn | B:95, B:78, B:76 | gy_Bones.RollDelay; WaitFor; WaitTics |
| H27 | Bones Bridge off: no queue for those corpses, waiting ones dropped, Legion of Bones' spawners not handed back | B:406, B:552, B:360 | gy_BonesHandler.WorldThingDied; WorldTick; gy_BonesReplacer.CheckReplacement |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Score asks gy_RSQService "stone.life" with the pawn when a life is spent; answered as H14; Score's debug setting read | Score/zscript/rsscore/handler.zs:1315, E:255, E:277, E:278 | (Score's TellGraveyard); gy_RSQService.GetInt |
| W2 | Miniboss asks "bones.graves" (thrall classes, player x 1000 + a stone's count, radius, spot), only when its Graves Rise Chance roll wins | Miniboss/zscript/rsqmb/bossfight.zs:1230, Miniboss/zscript/rsqmb/bossfight.zs:1242, E:253, B:213, B:227, B:229 | (Miniboss's Graves); gy_Bones.GravesAsked |
| W2 | Needs Legion of Bones; stones in range nearest first; one or one per thrall in a ring; 4 tics between stones, 12 between risers; each tries up to 8 times, 35 tics apart, near spots in 3 rings | B:215, B:623, B:626, B:637, B:640, B:644, B:613, B:375, B:584, B:585, B:564 | gy_Bones.GravesAsked; gy_BonesHandler.RaiseGraves; WorldTick |
| W2 | Miniboss asks "stones.pulse" (colour, seconds) on each beat; the candle up to 1.6 times, leaning 85% to the colour; full bright over 0.35 of the beat | Miniboss/zscript/rsqmb/bossfight.zs:1254, E:254, T:348, T:356, T:302, T:544, T:311, T:545, T:122 | gy_Stone.PulseAll; pulse; updateLight; Tick |
| W3 | RSQVR_Service "loaded" and "word.hold"; rsqvr_words (VisualRewards' Monster Words) read for this machine | T:144, T:145, T:159, T:161, VisualRewards/pk3/CVARINFO.txt:119 | gy_Stone.showWords |
| W4 | Photosensitive Mode: class RSQA_Menu and rsqa_photosafe; no flicker, no swell, no full bright, a 0.5 lean held for PULSE_HOLD (60) tics, Living held at 0.5 | T:442, T:443, T:444, T:445, T:446, T:377, T:302, T:122, T:366, T:546, T:412 | gy_Stone.photoSafe; flicker; updateLight; Tick; pulseEnv; livingPulse |
| W5 | Legion of Bones found by SkullZombieSpawn; LOB_Respawn read; with the bridge on its spawners handed back to the replacement loaded before it, or the original; rows greyed without it | B:170, B:76, B:359, B:360, B:361, B:362, B:349, zscript/rsqgy/menu_rows.zs:19, zscript/rsqgy/menu_rows.zs:40, menudef.txt:82, menudef.txt:84, menudef.txt:120, menudef.txt:122 | gy_Bones.LobLoaded; WaitTics; gy_BonesReplacer.CheckReplacement; Before; OptionMenuItemRSQGYIfLoaded.IsGrayed |
| W6 | The Brutal Doom / XMVE table to one of 13; their death helpers never rise | zscript/rsqgy/bones_table.zs:1, zscript/rsqgy/bones_table.zs:192, zscript/rsqgy/bones_table.zs:231, B:183, B:184 | gy_BonesTable.Kind; Never; gy_Bones.KindOf |
| W7 | The shared menu code looks for RSQ_MeleeUpgradeService; this page has no gated row | zscript/rsqgy/rsmenu.zs:109, menudef.txt:63 | RSQGY_RSMenu.GbLoaded |
| W8 | One Radiant Silvergun Options entry; this mod's page added to it | menudef.txt:13, menudef.txt:21, menudef.txt:26 | MENUDEF |
| W9 | The service's three requests; anything else 0 | E:253, E:254, E:255 | gy_RSQService.GetInt |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Alone no spawn at the death; the stone comes with the next map load; Score's is spawned at once | E:114, E:81, E:276 | gy_EventHandler.worldThingDied; worldTick; gy_RSQService.GetInt |
| L2 | Three `nosave` string settings hold the store, read and written whole | cvarinfo.txt:1, cvarinfo.txt:2, cvarinfo.txt:3, S:29, S:30, S:31, S:201, S:202, S:203 | gy_Storage.of; write |
| L3 | 200 a map; no cap across maps; the store parsed whole at map start, each death, each Score life | S:67, S:29, E:43, E:106, E:273 | gy_Storage.trimThisMap; of |
| L4 | Records are matched by the map's checksum | S:38, S:40, S:138 | gy_Storage.Next; registerDeath |
| L5 | Not solid (no SOLID flag), radius 16, height 1; Used is its only action | T:25, T:27, T:28, T:133 | gy_Stone Default; Used |
| L6 | The candle only inside the cull distance of the nearest player | T:283, cvarinfo.txt:16 | gy_Stone.updateLight |
| L7 | Netgame: settings from the arbitrator's userinfo, distances from the nearest player | T:496, T:521, T:503, T:509 | gy_Stone.lookPlayer; boolCvar; nearestPlayerDist |
| L8 | The remove events are handled on every machine, each clearing its own store | E:139, E:141, E:145, E:147, E:118 | gy_EventHandler.networkProcess |
| L9 | A corpse back to life before its rise is dropped | B:556, B:496 | gy_BonesHandler.WorldTick; LobTick |
| L10 | Only the 13 vanilla kinds rise: no lost soul, pain elemental, Cyberdemon or Mastermind | B:42, B:43, B:186, B:187 | gy_Bones.Vanilla; KindOf |
| L11 | Nothing of the Bones without Legion of Bones | B:403, B:215, B:541 | gy_BonesHandler.WorldThingDied; gy_Bones.GravesAsked; gy_BonesHandler.WorldTick |
| L12 | No key section: two aliases only | keyconf.txt:3, keyconf.txt:4 | KEYCONF |
| L13 | A saved Rise Chance of exactly 50 moved to 15 once: at startup by the settings generation (gy_cfgver 1), and in a game saved before it when that game loads (a server setting comes back from the save) | B:310, B:311, B:317, B:318, B:325, B:396, B:397, cvarinfo.txt:32 | gy_BonesReplacer.OnRegister; Migrate; MoveChance; gy_BonesHandler.WorldLoaded |
