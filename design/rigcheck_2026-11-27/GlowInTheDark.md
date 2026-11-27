# RSQ Glow In The Dark: rig check 2026-11-27 (agent C)

Rig: rig2 (head yaw turns the view), Freedoom 2 MAP01, rig only. Run **C_gd1** (Glow In The Dark alone + the test probe;
`rsqgd_debug 1`; logs/C_gd1.log, script logs/C_s_gd1.txt), frames every 6th render at 640 (frames/GlowInTheDark/).
Also C_sc4 (Score's life flash), C_sm4 / C_dumptest (SlowMo's DOWN red map), C_gy1 (Miniboss heartbeat).
The menu buttons were sent as their network events (`rsqgd_shuffle`, `rsqgd_randomize`, `rsqgd_recolour`); the reactions
by the mod's own test events (`rsqgd_test_mb`, `_wave`, `_combo`, `_slowmo`, `_flare`). Mean brightness of a frame was
measured (grey level 0-255) where darkness is claimed.

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN/PARTLY) |
|---|---|---|---|
| Start a map: every room's walls glow, a band up from the floor and down from the ceiling (14) | WORKS | frames/GlowInTheDark/gd1_before_f30_off_f762_off_dark_f810_on_f840.png (f30 before the glow is written: plain walls) and gd1_glow_f36_shuffle_...png (f36: both bands lit, red) | one colour pair per tag group / new colours every map: not checked (one map) |
| Each room's light x0.625 (15) | WORKS | frame mean grey 37.3 before (f30) -> 21.8 with the glow (f60) = x0.58 | |
| Liquids, guessed liquids, hurt floors, teleporters, switches amber, exits green, locked doors in key colour, key pickup, ordinary doors, keys/powerups bright, stronger in the dark, splash flares (16-27) | CAN'T TEST | not identified in the frames taken (MAP01 start, head yawed 0/90/180/270: gd1_sheet_all_frames.png f6-f156) | |
| Shuffle Profile: another profile, new colours (28) | WORKS | gd1_glow_... f180 (orange/yellow) and f216 (teal) after `rsqgd_shuffle` at C_SHUFFLE (C_gd1.log:64) | |
| Randomize Look: a new made-up look, Profile set to Custom (29) | WORKS | C_gd1.log:66 "[RSQGD] randomized look (tic 252): profile 0 ..." (0 = Custom); frame f270 purple | |
| Randomize Colours (30) | PARTLY | sent (C_gd1.log:67) | no change I can tell from the frames that follow (the Boss-tint test began 40 tics later) |
| The three buttons do nothing during a Boss tint, with the console line (31) | WORKS | C_gd1.log:68-69 under `rsqgd_test_mb 1`: "Glow In The Dark: colours held during a Boss fight or sequence" | |
| Step Profile, Pair Darkness to Profile (32-33) | CAN'T TEST | menu rows; not driven (rig2 can send menu keys, not run in this batch) | |
| Change a glow setting: the map written again within a second (34) | FIXED (was PARTLY) | Glow off then on: the glow is back within about 1 s (f834 purple) | for the frames between (f798-f828) the map is almost black (mean grey 7.2, against 21.8 with the glow and 40.1 off): darker than either state, until the glow is rewritten — **FIXED 2026-11-27.** Cause: the darkness (ddz.zs, RSQGD_DDZ_Handler) follows rsqgd_enabled within a tic or two (its UiTick network event), while the glow waited for handler.zs Second (once every 35 tics) and then a budget of planes a tic: for up to a second the map had the darkness and no glow. Fix: handler.zs WorldTick reads the switch every tic and SwitchNow sets the darkness (ChangeLighting) and writes every plane in that same tic. Rig F_gd1 (fixed) vs F_gd1old (the rig check's pk3), the same script, whole-frame mean grey: old: on -> 7.1 for 76 frames, then 19.0; fixed: off 40.0 -> on 23.4 with no frame between (F_gd1.log "[RSQGD] tic 160: Glow In The Dark switched on: darkness and every plane (211 sectors) written this tic"); frames/GlowInTheDark/F_gd1_glow_back_on_old_vs_fixed.png. Turning it off is now one step too (old: the glow stayed on the relit map, mean 50.4, for 72 frames) |
| Reroll Never / On Death / Level Up / Timed, secrets, liquid colour modes, one colour per, blend, pickups bright, lights (35-45) | CAN'T TEST | option variants not run | |
| Turn the mod off: the map's own light, no lit walls (46) | WORKS | f762 (off): plain walls, mean grey 40.1 (brighter than the map's own 37.3 at f30) | |
| Works with Miniboss: the map takes the Boss's colour and throbs (152) | WORKS | test event: f396 deep red throb (gd1_glow_...png), the frames f330-f440 pulsing (sheet) | |
| Works with Gun Bonsai: a level-up wave (155-156) | WORKS | C_gd1.log:71 "[RSQGD] level-up (test) tic 460: wave from player 0"; f492 a pale wave over the walls | |
| Works with SlowMo: drains to grey; DOWN's red map (153) | WORKS | sheet f546-f600 greyer under `rsqgd_test_slowmo 1`; DOWN red map: frames/SlowMo/sm4_DOWN_panel_...png, dumptest f70 | |
| Works with Score: combo glow (154) | CAN'T TEST | no difference I can tell in the frames after `rsqgd_test_combo 10` | |
| Works with Score: life flash (154) | WORKS | C_sc4.log:287 "[RSQGD] life flash t559: grey and white until t664, the map's own colours strongly until t734, settled by t769" | |

## Counts
(2026-11-27 fix job: line 34 FIXED: now WORKS 10, FIXED 1, PARTLY 1, CAN'T TEST 4)
WORKS 10, PARTLY 2, CAN'T TEST 4 (rows; the CAN'T TEST rows group about 30 README lines), BROKEN 0.
