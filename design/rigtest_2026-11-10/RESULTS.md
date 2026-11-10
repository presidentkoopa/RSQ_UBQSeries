# Batched rig test 2026-11-10: results so far (rig only, not headset-confirmed)

Linux QuestZDoom 17.3 rig, the owner's order (doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4f > LOB > Champions >
GunBonsai > every RSQ pk3), plus TestRig/bossfight_rig (rig02.wad, rtp probe) and the r10 probe (evidence/r10probe).
Every launch: zero script errors from our packs (BD_VoxelPack's 4 voxeldef errors only). Logs and scripts in evidence/.

| Check | Result | Evidence |
|---|---|---|
| B7 rename | Menus read Minibosses / Miniboss Meter Fills From / Other Mods Treat It as a Boss; the landing's line MINIBOSS INCOMING; the called-in kill pays ONE row, "Miniboss Called" -> Score's Miniboss row (15000 = 3x), no Bossfight row | B7_miniboss_menu.jpg, L1_log.txt |
| B8 stack | thrall bar, the miniboss's bar with its tier gem and Champion power icon on the right, three life bars. Then the shield icon was REMOVED (owner 11-10) | B8_stack_before_shield_removed.png |
| GUARD! / TARGET! (owner's condition for removing the shield) | GUARD! on the shielded hit; TARGET! over the miniboss in the window and one-on-one, gone on a life lost, GUARD! on hits during the 175-tic invulnerability, TARGET! back the tic it ends; it follows the miniboss into a new body | L5_log.txt (R10 WORDS lines) |
| V3 HP bar icons | gem + power icon left of the bar; Tier Gem and Champion Icons off: ours go, Champions' own icon back; on again. Champion frames logged against tokens: all 9 seen colours match | V3_hpbar_icons_on_off_on.jpg, L2 R10 MON lines |
| R3 floating tier gems | drawn (were invisible: no art). Busy with the colour-blind aid on | V3 frame |
| R4 Score Champion rows | "+21 White Champion" with its snowflake icon | R4_score_champion_row.jpg |
| A4 saber only (owner 11-10) | with the rifle: "draw your saber first", no remote; with the saber: summoned; switched to the rifle: TRAINING OVER, the remote gone. Score's wrist digit shown before, hidden while the remote is out, back after | L7_log.txt, A4_score_wrist_steps_aside.jpg |
| A5/H3/X1 one throw | the Saber and the ShieldSaw read the same posed swing alike: 2.06 m/s and 3.09 m/s (rig02, no monsters, 120 px, every tic rendered); the Saber at 2.06 (needs 2.50): no throw; at 3.09: thrown. The ShieldSaw locked something both times, and a locked release always throws, so its threshold is not shown. BD22 VR's axe and grenade not run | L8_log.txt |
| Saber wrist twist | NOT SHOWN: this rig does not pass a posed controller's roll to ZScript (known, TestRig/bossfight_rig README), and with Gun Bonsai VR loaded the second blade needs its Double-Bladed upgrade | L8_log.txt |
| ShieldSaw trigger-hold lock | holding the off trigger painted a lock (\"1 locked\") | L8_log.txt |
| Menus | Tier Gem and Champion Icons (On), Beam Sparkle (Quest) (Off), Saber Throw Speed (m/s) 2.50, ShieldSaw Throw Hand Speed (m/s) 2.50, Graves Rise Mode greyed with Graves Rise off | menus_new_rows.jpg |
| S5 Be Quick or Be Dead | the name over the panel in the middle, sinking; the breathing letters (two frames differ in the D's and K) | S5_* |
| A4 remote panel + 30 s round | :30 / :28 in gold, pips light per hit (3 of 4 at t250), the knock-down at 4, R1 -> R2, the clock held while down and back to :30 when it rises; the clock running out: TRAINING OVER, the remote gone | A4_*, L6_log.txt |
| G1 Quick Grenade | BD22's Toss Grenade (+user1): queued t646, out t663 (17 tics), 45.3 u/tic, fuse 105, one grenade spent. The Quick Grenade key did NOTHING at first: QuestZDoom's netevent command marks every event it sends as manual (gzdoom src/events.cpp:2454) and Grenade dropped all manual events; fixed (hand.zs NetworkProcess lets rsqgn_quick through). After the fix the key: queued t715, out t732, same speed. Needs rsqgn_replace_bd (or BD22 VR's Use RSQ Grenade Instead) with BD22 VR loaded: otherwise RSQ Grenade stands down and BD22's own toss is the quick throw, by design. Pin/toss sounds and the BD22 comparison not logged | L9_log.txt (RSQGN quick, R10 INV lines) |
| L1 beam on between shots / reload / switch | the pistol's beam on idle and through 7 shots; on the shotgun after the switch, gone while the gun lowers for the quick throw and back with it. DURING A BD22 VR HAND RELOAD (mag dropped, gun EMPTY t352-444) THE BEAM STAYED ON: the gun stays in a measured pose while the hand reloads, so the README's "hides while you reload" is not what happens with hand reloading | L9_laser_reload_switch_quicknade.jpg (t220-t740) |
| L6 Beam Sparkle | NOT SHOWN: no spark seen along the pistol's beam at 480 or 1080 px (sparks are ~3 cm, designed near invisible); nothing logs a spark | L9c_sparkle_1080_none_seen.png |

Not yet run: Melee M1-M9, Grenade G2, LaserSight L2-L5, Saber A1-A3/A5, ShieldSaw H1-H3, Distance Grab D3, BD22 VR X1,
Tactical Rig T1, SlowMo S1/S3/S4, Miniboss B1-B6, VisualRewards V1-V2, Monsters R1-R2.
Rig traps learned: poses are read per RENDERED frame, so a swing test needs a tiny eye (QZ_RES 120, no frame dumps) to render every tic; a saber or shield release with a painted mark always throws (barrels in MAP01 get marked): test throws in rig02 with -nomonsters.
Notes: the rig's HUD sits where the off-hand panel is in these poses (the panel draws over Gun Bonsai's HUD frames).
