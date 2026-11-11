# Rig 11-11: the last five checks (rig only, not headset-confirmed)

The owner asked for these five on 11-11. Three launches, all on the owner's order from `run.sh` (doom2 > brutal22test6 >
BD_VoxelPack > BD22 VR 2.0.4f > LOB > Champions > GunBonsai > every RSQ pk3, RSQ_GunBonsaiVR included). Extras: the
rig02 arena (`TestRig/bossfight_rig/rig02.wad`, which takes MAP01), the LaserSight readout probe (`lsr.pk3`) and a test
probe (`evidence/LAST_rig_scripts/last_probe_zscript.txt`, scratch only, never ships). No script error from our packs
in any launch (the 4 errors in each are BD_VoxelPack's VOXELDEF, as always).

- **LASTA** (720 px an eye): one map, then one reload for Start With Melee Hands. Checks 1, 2 (the muzzle guard), 3, 5.
- **LASTB** (1080 px): the gloves reload, the Wheel again, the two menus, the plate's Absorb route. Checks 2, 4, 5.
- **LASTC** (120 px, every tic rendered, no frames): the far zombie's own attacks on the plate. Check 2.

| Check | Shown / not | What was shown | Evidence |
|---|---|---|---|
| 1 Saber: the training remote's deflect slow, from the Saber side | **SHOWN** (log) | The Saber held lit, the remote out (`netevent ubqs_remote`), `ubqs_diag 3`. The rig cannot turn to face a drone that circles all the way round, so the probe holds the remote 8 units past the blade tip on the line from your middle through the tip; its bolts are its own (aimed by `Fire()`, speed 9). **With Gun Bonsai VR and Deflector not learned** (t1178 to t1291): three bolts `SBX_DEFLECT ... DEFLECTED` by the blade, each stopped dead (the owner's 11-03 "block free, deflect earned"): no deflect counted, no slow. **After Add All** (Deflector learned): `SBX_DEFLECT t1371 ... near 1.59 need 5.00 -> DEFLECTED` (the Saber's own line, in the player's tick); the remote's count went 0 -> 1 in that same tic (0 at the start of t1371, 1 at the start of t1372; the count and `Slow(300)` are one block in the bolt's Tick, `QuestSaber/zscript.txt` 6576-6583); SlowMo received the request at t1375: `rsm_pulse (300 35)`, `ubqs_remoteslowmo`, `trigger saber.remote t1375: started 300 ms at 35%`, pulse 11 tics. The same for t1429 -> t1430, t1493 -> t1496, t1537 -> t1539 (the fourth knocked it down: 1500 ms, pulse 53 tics, the deflect's 300 ms merged) and t1720. Not one bolt stung (stung 0). | `evidence/LAST_SABER_remote_deflect_slow_log.txt` |
| 2 ShieldSaw: a far bullet blocked by the plate | **SHOWN** (log) | rig02's west half (flat floor 0), you at (-440 -300), a vanilla ZombieMan 400 units (11.76 m) ahead at (-40 -300), its floor 0, line of sight; the plate held facing it (`n(1 0 0)`, C(-427 -295 37)). A real hitscan from the zombie (its LineAttack, BulletPuff, at your middle): Absorb route (`ssq_hitscan_guard 0`) `guard kind 1 BLOCKED dmg 2 from Zombieman ... A(-40 -300 42)`, hp 100 -> 100 (LASTB t227); the default muzzle guard `ATE a hitscan from Zombieman`, hp 100 -> 100 (LASTA t491). **The zombie's own attacks** (LASTC, held at its spot, firing at will): Absorb route `BLOCKED dmg 6` (t785); default `BLOCKED dmg 2` (t1308) and `ATE` (t1703, its ricochet struck the zombie for 9); in 1600 tics not one damage line on you (the rest of its sprayed shots missed you). | `evidence/LAST_SSQ_far_zombie_blocked_log.txt` |
| 3 LaserSight: At the Dot in Feet | **SHOWN** (frames + log) | BD22's pistol, the beam 29 degrees up into rig02's ceiling, Range Readout At the Dot, units Feet: "45 ft" under the dot, read in the frame (log: `text "45 ft" (13.61 m, 441 u)`). On a wall (beam level, 16 m): the log reads "53 ft", but in the frame the first digit lies behind the rig's HUD plate (a rig HUD position, not the readout). | `evidence/LAST_LS_at_the_dot_feet.jpg`, `_log.txt` |
| 4 SlowMo: menu header and Photosensitive Mode | **SHOWN** (frames + log) | RSQ SlowMo's page, row 59 `OptionMenuItemRSQSMBreathTitle` "BE QUICK OR BE DEAD", the header in gold over its section. RSQ Accessibility's page, row 2 "Photosensitive Mode" (ON in the frame). What it does, per the README ("still letters"): with `rsqa_photosafe 0` three frames of the header differ (the Q, the K and the D's breathe; mean pixel difference 6.7 to 9.0, 75 to 123 pixels over 60); with it on, three frames are identical (difference 0.0, 0 pixels), and the probe read `RSQSM_A11y.Photo() 1` | `evidence/LAST_SM_menu_header_photosensitive.jpg`, `_log.txt` |
| 5 Wheel: the glove card, gloves in slot 1 by Melee | **SHOWN** (frames + log) | `rsqml_gloves 1` and a map load: both gloves given (`RSQ_Glove 1 RSQ_GloveOff 1`). No addslot: slot 1 reads `... rsq_hands* RSQ_Off_BrutalAxe RSQ_Glove* RSQ_GloveOff* UBQS_Saber* ...` (Melee's KEYCONF). `+wr_wheel`: the ring has two slot-1 MELEE HANDS cards wearing Melee's red glove with the gold cuff (RMICA0 / RMICB0). | `evidence/LAST_WHEEL_glove_cards_slot1.jpg`, `_log.txt` |

Scripts and the probe: `evidence/LAST_rig_scripts/` (LASTA, LASTB, LASTC).

## Findings (nothing changed)
- **Under Gun Bonsai VR the remote's deflect slow needs Deflector.** Until it is learned the blade stops the bolt (by the
  owner's 11-03 rule), so no deflect is counted and SlowMo is never asked. The Saber README's "0.3 s on every bolt you send back"
  holds (an unlearned blade does not send it back), but a player may expect the slow on a block too. Whether a stopped
  bolt should count for the remote is the owner's call.
- **The slow starts 2 to 4 tics after the deflect** (t1371 -> t1375, t1429 -> t1430, t1493 -> t1496): the request goes
  through a network event, which SlowMo handles when it arrives. About a tenth of a second at most.
- The rig only refreshes the plate's pose on rendered tics, so at 1080 px (a frame every ~8 tics) most of a walking
  zombie's hits found no plate (LASTB's AI part; no guard line at all). LASTC rendered every tic and blocked them. A rig
  trap (`ShieldSaw/zscript/ssq/guard.zs` Plate() needs a fresh pose), not a headset concern.
- Brutal Doom's tip line ("TIP 55") drew across the SlowMo menu in LASTB despite `bd_tips 0`; it does not cover the header.
