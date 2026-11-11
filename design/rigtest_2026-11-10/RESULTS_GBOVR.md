# Rig pass 2026-11-11: RSQ Gun Bonsai VR's own screens and rows (GBOVR)

The owner's order from `run.sh` (doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4f > LOB > Champions >
GunBonsai 0.10.6 > every RSQ pk3, built from HEAD after 3e60c376) plus a test-only probe (`evidence/GB_probe/`:
readouts, and a picker that presses Enter on the open level-up menu through its own `MenuEvent`, the path a
player's Enter takes). MAP01. Three launches counted (GB2, GB3 at 720 px, GB4 at 480 px; GB1 was a probe bug run).
No script error from this pack in any launch (the 4 errors are BD_VoxelPack's voxeldef.txt). The start line reads
"Initializing Gun Bonsai v0.10.6+RSQ..." (one of the 11-10 fixes, now in a log).

How XP was given: Gun Bonsai's own `bonsai-debug,p-xp` for player XP; for a weapon, the probe adds exactly enough XP
to that weapon's record (Gun Bonsai's `w-xp` only reaches the main hand). The level-ups then go the real way:
Display Info (`netevent bonsai-show-info`, the I key's netevent) opens the waiting level's cards (for a weapon in
neither hand the record's own `StartLevelUp`), the card menu sends `bonsai-choose-level-up-option`, Gun Bonsai's
giver installs it. No Add All anywhere in these runs.

All rows: **rig only, not headset-confirmed.**

| Check | Result | What was shown | Evidence |
|---|---|---|---|
| 1 Both hands' gauges, colour cycle | **shown** | Off hand top left, main hand top right, both "Melee Hands"; the frames and bars go blue, magenta, orange over ~1.5 s (t59 to t100). Dual HUD off: one gauge in Gun Bonsai's place (in item 6's frames) | GB_1_gauges_colour_cycle_both_hands.jpg (crop x4 of the VR HUD panel), GB_6_score_line_vs_shieldsaw_gauge.jpg |
| 2 Status screen | **shown** | Opened by Display Info with nothing waiting. PLAYER STATUS (level 13, XP 4/7, the upgrades list, scrolling to the last), a MAIN card and an OFFHAND card (glove pictures, name, LV 2, 1/1800), each hand's WEAPON STATUS list, DESCRIPTION with the selected upgrade's text and numbers (Lunge: "+44%"; Momentum). No ITEMS slots, no WEAPON BOND panel. Rows walked: 17 (main gun, 2 upgrades, off gun, 2 upgrades, 11 player upgrades). A second press steps to the other gun (log: focus hand 1, then 0) | GB_2_status_screen_cursor_main_upgrade_and_player_upgrade.jpg, GB_GB3_log.txt (GBP STATUS) |
| 3 Level-up card | **shown** | Weapon cards (Melee Hands, Lightsaber, Frag) and a player card ("LEVEL 1"): title, four cards in orange, cyan, magenta, green, each with name, text, a NEW box and its number 1-4 | GB_3_levelup_cards_fists_saber_player.jpg, GB_3_levelup_card_grenade_480px.jpg |
| 4 A level-up on each tree | **shown (log)** | Weapon trees: **Fists** Heavy Hands, Pistol Whip, Human Shield on the two gloves; **Melee** Lunge on the glove, Executioner on the saber; **Saber** Deflector; **Force** Force Sensitive picked on The Force's card and stored on the main saber's record (the one-pool rule); **ShieldSaw** Lockstep; **Whip** Sting; **Grenade** Strong Arm. Player trees: **SlowMo** Longer; **Guard** Guard 1 then 2; **Two hands/body** Akimbo 1-2, Crossfire, Southpaw, Steady Aim; **Grapple** Grapple, then Momentum, Long Line, Slingshot; **Gunslinger** Smoker, Quick Draw; **Critical Hits** Critical Hits; **Kill Rewards** Gastropub, then Rich Bits 1-2 and Magnet 1-3, then Lucky Kill (the parents held). Each pick logged as "GBP PICK ... by Enter" followed by Gun Bonsai's own "gained a level of" line; the bag dumps show them stored | GB_GB2_log.txt (fists, saber, Force, ShieldSaw, whip, Crossfire; bag tag 3), GB_GB3_log.txt (player trees), GB_GB4_log.txt (grenade, Kill Rewards) |
| 5 Greyed HUD rows | **shown** | Row dump: Dual HUD on, Single HUD Follows grey 1, ShieldSaw Gauge and the six HUD Position rows grey 0; Dual HUD off, the reverse. Frames: the six HUD Position sliders dimmed with Dual HUD off; Single HUD Follows' value dim with it on, white with it off; ShieldSaw Gauge dimmer with it off (the option rows dim only faintly; the sliders clearly) | GB_5_options_page_dual_hud_on_off.jpg, GB_5_single_hud_shieldsaw_rows_zoom.jpg, GB_GB3_log.txt (GBP OPT) |
| 6 ShieldSaw gauge band | **shown** | ShieldSaw carried, gloves in both hands. Row on, Dual HUD on: band top 51 h 75 drop 109, Score GaugeShift 0.109, the third gauge drawn between the two and Score's line below it. Dual HUD off: band -1, shift 0.000, no third gauge, Score's line back up. On again: 0.109. Row off: -1 / 0.000 | GB_6_score_line_vs_shieldsaw_gauge.jpg, GB_GB3_log.txt (GBP BAND) |

## Seen on the way (not this pack's bugs unless said; nothing fixed)

- **Score's line sits on the main hand gauge's weapon name** in every frame (Dual HUD on, ShieldSaw gauge off):
  "SCORE: 0" covers "Melee Hands" / "Lightsaber". Same in the 11-10 A4 frames. Which moves is the owner's call
  (Score's place, or the gauge's name row).
- **The gauges and Score's line draw over menus**: on the options page they cover the top rows (Ammo and Health
  Row to Single HUD Follows); on the status and card screens they sit above, clear of them.
- **The first Display Info press opens the status screen on the off hand's gun** (`AdvanceMenuHand` steps before
  opening). The README says only that a second press steps to the other gun; it holds.
- **The whip has no picture** on the status screen (an empty MAIN box; the README's known gap says icon or pickup
  sprite: the whip has neither). The Fist (rsq_hands) shows "?".
- Brutal Doom's tips show despite `bd_tips 0`, and a Tactical Rig line ("TACTICAL RIG EYE HEIGHT ...") once under
  the card title (GB3); neither is this pack's.
- The Ammo and Health Row is not drawn: Brutal Doom's status bar is at the bottom (as in the 11-10 frames).

## Not shown

- Refusing a level (Back), toggling or tuning an upgrade on the status screen, paging past four cards, keys 1-4:
  not run. The Mockup screens with GBOVR Menus and HUD off (Gun Bonsai's own menus): not run.
