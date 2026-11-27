# BD22 VR Reloaded bug read, part 9: lumps, settings, keys, menus and assets (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

Scripts used for the complete checks are under /tmp/p9 (none in the repo). Two things outside the repo were opened
read-only to settle "is this base Brutal Doom's" instead of guessing: `/mnt/user-data/uploads/1_00_brutal22test6.pk3`
(base Brutal Doom, found on this machine) and the repo's own `pk3/02_BD22_VoxelPack.pk3` and
`pk3/03_BD22_VR-Reloaded_3.0rc.pk3`. QuestZDoom's own `qzdoom.pk3` and LegenDoom are not on this machine: where a name is
"the engine's" or "LegenDoom's" that is from memory or from the code's own comments, and it says so.

## Files read
| file | lines | read to the end? |
|---|---|---|
| build.py | 34 | yes |
| VERSION | 1 | yes |
| tools/handtone_build.py (build.py calls it on every MODELDEF) | 43 | yes |
| src/ANIMDEFS.rsq | 23 | yes |
| src/CVARINFO.rsq | 75 | yes |
| src/CVARINFO.rsqdual | 16 | yes |
| src/CVARINFO.rsqvox | 10 | yes |
| src/KEYCONF.rsq | 13 | yes |
| src/KEYCONF.rsqmoon | 3 | yes |
| src/MENUDEF.rsq | 253 | yes |
| src/MENUDEF.rsqdual | 30 | yes |
| src/MENUDEF.rsqvox | 20 | yes |
| src/README.txt | 190 | yes |
| src/RSQGCOFF.rsq | 68 | yes |
| src/SBARINFO.rsq | 1124 | yes |
| src/SNDINFO.rsq | 258 | yes |
| src/SNDINFO.rsr | 16 | yes |
| src/SNDINFO.rsld | 62 | yes |
| src/SURFACES.rsq | 75 | yes |
| src/TRNSLATE.rsq | 6 | yes |
| src/Voxeldef.txt, src/Voxeldef.cruel.txt | 2 + 2 | yes |
| src/ZSCRIPT.nosniper, .rsvr, .rsx, .rsz | 2, 63, 7, 45 | yes |
| src/LICENSE_Dakka_WTFPL.txt | 29 | no: a licence text, not opened |
| src/MODELDEF.rsqmoonammo, rsqmoondual, rsbullet, rsqcase, rsrpump, rsqaxedual | 28, 82, 100, 103, 143, 223 | yes, by eye |
| src/MODELDEF.rsmnade (409), rsb (490), rsqdual (536), rsqmoon (540), rsm (615), rsq (1138), rsr (2091), rsqvox (2273), rsqoff (6046), purist (11999), bd.txt (14221), rsqgc (135108) | 175,466 | first 300 lines of each by eye (see note), every line by script |
| src/MODELDEF.rsqdualmg (492) | 492 | first 296 by eye, every line by script |
| For the cross-checks only (other readers own them): CVARINFO.rsld / rsr / rsb / rsvr / rsx, MENUDEF.rsld / rsx, MAPINFO.rsld / rsvr / rsx / nosniper | all | yes |

Note on the 300-line reads: runs of `FrameIndex` lines were printed joined on one row; three rows longer than 1,400
characters (the AssaultShotgun block in MODELDEF.rsqoff, .purist and .bd.txt) were cut on screen. The script read all of them.

## Counts for each check (so nothing is silently skipped)

| check | how many checked | faults |
|---|---|---|
| MODELDEF: lumps / blocks / FrameIndex lines | 19 / 3,529 / 135,677 | 0 parse faults, 0 stray text |
| MODELDEF: model files named (path + name, exact case) | 3,562 (3,329 in src, 233 `.kvx` in the voxel pack) | 0 missing, 0 wrong case |
| MODELDEF: Skin and SurfaceSkin files named (exact case) | 3,336 + 1,499 | 0 missing, 0 wrong case |
| MODELDEF: frame index inside the mesh's frame count (md3 header read) | 135,677 (kvx and obj count as 1 frame) | 0 |
| MODELDEF: SurfaceSkin surface inside the mesh's surface count; every surface skinned | 1,499 | 0 |
| MODELDEF: same class + sprite + frame defined in two blocks, any lump | 134,854 keys | 0 (none twice, so none conflicting) |
| MODELDEF: actor classes named | 100 | 0 (97 in src; BFG10k, PuristBFG10k, Melee_Attacks are base Brutal Doom's, seen in its pk3) |
| MODELDEF: sprite names the engine must already know | 570 | 7 known only through the voxel pack: B9.3 |
| MODELDEF: the build's hand-slot rewrite (no index above 1, hand `Model` line last, hand skin on model 0) | 147 hand blocks | 0 |
| (a) cvars defined (8 CVARINFO lumps) | 122 | 0 defined twice; 0 clash with base BD's 87; 0 never read; 0 read only by a menu |
| (a) named reads of a cvar (GetCVar, FindCVar, CVar.GetCVar, IfCVarInt, menu rows) | 354 | 23 names not defined here: 1 base BD's, 8 engine's, 12 other mods', 2 defined nowhere (`rsr_test_offdraw`, `lanec_flamelog`: test switches, every read null-checked) |
| (a) type against the getter or helper used | 138 | 0 |
| (a) `user` cvar read without a player | 14 sites | B9.9 |
| (a) slider range against the code's clamp | 9 sliders | 0 (4 clamps are wider than the slider, none narrower) |
| (a) code fallback against the CVARINFO default | about 100 | 7: B9.12 |
| (b) MENUDEF rows with a cvar / an option list / a submenu / a command | 84 / 74 / 52 / 6 | 0 missing here; 10 submenu targets and 1 command are QuestZDoom's or LegenDoom's (cannot see) |
| (b) menus defined, reachable | 8 | 0 unreachable (4 by rows, 4 put in place by `zscript/rsld/menu.zs`); 2 option lists no row uses: B9.7 |
| (c) KEYCONF aliases / binds / slot lines | 0 / 0 / 4 | 0 (the four classes exist and are weapons) |
| (c) net events sent / heard | 10 / 36 | 0 sent and unheard; 26 heard that nothing in src sends (test probes): B9.8 |
| (d) SNDINFO names (3 lumps) / file paths, exact case | 217 / 148 | 0 |
| (d) sound names used in code | 1,096 uses, 267 names | 0 of the pack's own; 57 names not in src or base BD SNDINFO, all accounted for below |
| (e) sprite frames used in states (134 code files) | 2,988 | 0 that a player sees; 21 names only in src with no lump and no model, all never shown |
| (f) files the build ships / `#include` lines / zscript files included / actors files | 911 / 93 / 91 / 33 | 0 |
| (f) same 8-character lump name as a base BD sound or sprite | 152 + 107 | 0 |
| (g) MAPINFO class names | 36 + 1 MenuDelegateClass | 0 missing; 1 handler class in src that no MAPINFO names: B9.1 |

## Findings, worst first

## B9.1: The Recoil row does nothing: no gun kicks, on or off
- Kind: wrong behaviour (dead code behind a live menu row)
- Where: src/MAPINFO.rsvr:5 and src/MAPINFO.rsx:2 (the two handler lists; `RSQ_Recoil` is in neither);
  src/zscript/rsq/recoil.zs:52 (`class RSQ_Recoil : EventHandler`); src/ZSCRIPT.rsvr:51 (compiled);
  src/MENUDEF.rsq:133 (`Option "Recoil", "rsq_recoil", "OnOff"`); src/CVARINFO.rsq:57; src/README.txt:102-105.
- What the code does: recoil.zs is compiled, and its whole effect is in the handler's own `WorldHitscanPreFired`,
  `WorldRailgunPreFired`, `WorldThingSpawned` and `WorldTick` (recoil.zs:286-307). An event handler only runs if a
  MAPINFO `AddEventHandlers` line names it. None does. The one other caller, src/zscript/rsld/ld_g2_proj.zs:56, asks
  `EventHandler.Find("RSQ_Recoil")`, gets null and skips.
- Why it is wrong: CHANGELOG.md:749 ("Recoil is gone", the owner's 1.99 headset pass) is where it was switched off. Since
  then 2.0.5n added the Recoil row (CHANGELOG.md:64-66, "They worked before and had no row"), "each gun kicks in its own
  hand" (CHANGELOG.md:32-35) and five new recoil profiles (CHANGELOG.md:56-58), all inside a handler that never runs. The
  player has a Recoil row, on by default, that changes nothing, and README.txt still sells recoil for 22 guns.
- Checked: every MAPINFO.* in src (36 names, script); grep of all of src for `RSQ_Recoil`; the built
  pk3/03_BD22_VR-Reloaded_3.0rc.pk3 (its two MAPINFO lumps: no `RSQ_Recoil`). The guns' visible kick that remains is the
  mesh animation (hands.zs:21, "recoil is in the meshes"), which this row does not touch.
- Sure?: certain that the handler is not registered. Which way to fix is the owner's choice.
- Fix A: if the owner wants the 2.0.5n recoil: add `"RSQ_Recoil"` to the list in src/MAPINFO.rsvr:5 (1 line, 1 file).
  It must stay before `RSQ_PlayerRounds` (playerrounds.zs:42 says so); MAPINFO.rsx loads after MAPINFO.rsvr, so it does.
  It is then untested code from three builds (it spun guns round the shoulder at 1.99): needs a headset look.
- Fix B: if "Recoil is gone" stands: remove the row (MENUDEF.rsq:132-133), keep the cvar declared, and take recoil out of
  README.txt:102-105 and 171-173 (about 8 lines, 2 files).
- Or intended: true only if the owner knows the row is a placeholder.
- Already known?: partly. Q2, SH4, SH5 and SH9 are about recoil (owner: "Yes: a Recoil row", "Fix it", "Add them") and
  all treat recoil as running. None says the handler is not registered.

## B9.2: Turning a Voxels row Off probably still shows voxels
- Kind: setting or menu
- Where: src/Voxeldef.txt:1-2, src/Voxeldef.cruel.txt:1-2; src/zscript/rsq/voxels.zs:4-5; src/MENUDEF.rsqvox:5-19.
- What the code does: the two lumps hold only a comment saying they "replace the BD voxel pack's own Voxeldef.txt".
  voxels.zs lends a voxel model to an actor only while its category is on.
- Why it is wrong: the engine reads every VOXELDEF lump from every loaded file; a later file with the same name does not
  remove an earlier one. So the voxel pack's own lumps (pk3/02_BD22_VoxelPack.pk3 `Voxeldef.txt`, `Voxeldef.cruel.txt`,
  both full) still swap those sprites for voxels everywhere, always. With a row Off the pack lends nothing and the
  engine draws the voxel anyway. The repo's own logs agree the voxel pack's lump is still parsed: CHANGELOG.md:100, 106
  and 305 report "the 4 voxeldef.txt errors from 02_BD22_VoxelPack.pk3" with this pack loaded.
- Checked: both lumps; the voxel pack's lumps; voxels.zs:1-60, 93-98. Could not see the engine source here: the
  "every lump is read" rule is from memory of GZDoom's voxel loader.
- Sure?: likely. Settles in a minute: set every Voxels row Off and look at a medikit or a shotgun pickup; then type
  `r_drawvoxels 0` and look again.
- Fix A: the voxel pack is shipped in the owner's own set (pk3/02_BD22_VoxelPack.pk3): empty its two Voxeldef lumps
  there, and delete src/Voxeldef.txt and src/Voxeldef.cruel.txt, which do nothing (2 lumps in the voxel pack, 2 files).
- Or intended: if the headset already shows sprites with the rows Off, the engine differs from what is said here.
- Already known?: no.

## B9.3: Without the voxel pack loaded the game probably stops at startup
- Kind: crash or abort
- Where: src/MODELDEF.rsqvox:566 (`LSKL`), 1247-1328 (`SW01` to `SW05`), 1959 and the DSOL rows after it;
  src/zscript/rsq/voxels.zs:11 ("Without the voxel pack loaded the holders have no models and everything stays a sprite").
- What the code does: MODELDEF.rsqvox keys models on 570 sprite names. The engine must already know a sprite name (some
  actor state uses it) or it stops with "Unknown sprite ... in model definition". Seven names are used by no state in
  src and none in base Brutal Doom: DSOL, LSKL, SW01, SW02, SW03, SW04, SW05. Only the voxel pack's own DECORATE names
  them (its Sphere.txt:62, SkullColumn.txt:41, ExampleSwitches.txt:22-85).
- Why it is wrong: the voxels.zs comment promises the pack runs without the voxel pack. README.md:25 lists the voxel
  pack in the load order but nothing says the pack will not start without it.
- Checked: every state line in src (2,988 sprite frames) and in base BD; `GetSpriteIndex` calls (voxels.zs:33 is a
  run-time lookup and does not make a name known). ARM3, ARM4, MEDI, PMAP, PSTR, PVIS, also in no src or BD state, are the
  engine's own actors' sprites (from memory). The missing `.kvx` files themselves only print a message.
- Sure?: likely (the "Unknown sprite" stop is from memory of the engine; the repo's own comments at MODELDEF.bd.txt:35-36
  and rsb_guns.zs:1141 say the same). Settles by starting once without the voxel pack.
- Fix A: name the seven sprites in a never-spawned actor, as RSB_Sprites does (rsb_guns.zs:1142): one small class in
  voxels.zs with `DSOL A 0; LSKL A 0; SW01 A 0; ...` (about 12 lines, 1 file).
- Fix B: say in README.md and README.txt that the voxel pack is required, and correct voxels.zs:11.
- Already known?: no.

## B9.4: HUD Type "Gun Bonsai VR" can be picked without that mod, and then there is no HUD
- Kind: setting or menu
- Where: src/MENUDEF.rsq:244-253 (`OptionValue "HUDType"`, row `5, "Gun Bonsai VR"`); src/MENUDEF.rsq:67;
  src/SBARINFO.rsq:188, 465, 754, 963 (the fullscreen bar draws for sbartype1 to 4 only);
  src/zscript/rsq/bottomhud.zs:46 (the VR Row draws on 6 only).
- What the code does: the list replaces Brutal Doom's own HUD Type list (its MENUDEF.TXT:703), so both this page and
  Brutal Doom's show six choices. On 5 nothing in this pack draws anything.
- Why it is wrong: the comment on the line above says "5 is left out", and the row is there. A player without RSQ Gun
  Bonsai VR who picks it loses health, armour and ammo from view.
- Checked: SBARINFO.rsq whole; bottomhud.zs:1-60. Not seen: Gun Bonsai VR itself (bottomhud.zs:12 says it sets 5 by
  itself while its row draws, so the player never needs to pick 5).
- Sure?: certain for this pack's side.
- Fix A: delete the row `5, "Gun Bonsai VR"` (1 line). The menu then shows "Unknown" while Gun Bonsai VR holds the value
  at 5; if that reads badly, Fix B.
- Fix B: keep the row and have menutrim.zs drop it when Gun Bonsai VR's class is not loaded (the same trick as Rig
  Pouch Only; an option list entry cannot be trimmed that way, so this needs a second list without 5 and a row swap).
- Already known?: no.

## B9.5: On the default HUD (VR Row) the console gets "ACS: I don't know what sbartype6 is." at every spawn
- Kind: wrong behaviour (console noise only)
- Where: src/zscript/rsq/bottomhud.zs:18-29 (sets `bd_sbartype` to 6); base Brutal Doom's own script, src/Options.acs:66-73
  inside its pk3 ("BDRespawn": takes sbartype1 to 4, then gives `"sbartype" + the number`). No actor `sbartype5` or
  `sbartype6` exists in src or in base BD.
- Why it is wrong: ACS prints that line when asked to give a class that does not exist. Nothing breaks; the bar is
  blank on 6 as designed.
- Checked: grep of src for `sbartype5` / `sbartype6` (none); base BD's Tokens.dec:330 (sbartype4 is the last).
  Not checked: that the compiled ACS in base BD matches its source.
- Sure?: likely. Settles by reading the console after a map start on VR Row.
- Fix A: two empty tokens in a DECORATE lump of this pack: `Actor sbartype5 : bd_Token { +INVENTORY.UNDROPPABLE }` and
  the same for 6 (2 lines). Brutal Doom never takes them away again (it takes 1 to 4 only), which changes nothing: no
  bar reads them.
- Or intended: if the owner does not mind the line.
- Already known?: no.

## B9.6: Rows for mods that are not loaded are still on the page (same complaint as Rig Pouch Only)
- Kind: setting or menu
- Where: src/MENUDEF.rsq:60-61 ("Legendary Economy", the FIRST row of BD22 VR WEAPONS); 146-149 ("Slow Motion Only",
  "Slow Motion Boost"); 188-189 ("Slow Motion Speed"); src/zscript/rsq/menutrim.zs:11-12 (trims one row only).
- What the code does: Legendary Economy is read only by the LegenDoom mode (kiosk.zs:46, 198; handler.zs:883), which
  does nothing without LegenDoom 3.0. The slow-motion rows only matter with RSQ SlowMo (grenade.zs:58-63: without its
  service the world's speed is always 1).
- Why it is wrong: the owner's own words on 11-25, quoted in menutrim.zs:1-2: "why does it say rig pouch only when there
  is no tactical rig loaded?". And one of these rows bites: with "Slow Motion Only" On and no RSQ SlowMo,
  grenade.zs:66 makes "Shoot Grenades" never work, with nothing said.
- Checked: every read of the four cvars (script list); grenade.zs:56-86; kiosk.zs:46, 198.
- Sure?: certain.
- Fix A: add the four to menutrim.zs's two tables, each with a class of its mod (for LegenDoom the test RSLD.On already
  uses; for RSQ SlowMo the class `RSQSM_Service`) (about 6 lines, 1 file).
- Or intended: Q5 / LD4 in the 11-24 list left the Miniboss rows showing; the owner may want the same here.
- Already known?: no for these rows. Related: Q5 and LD4 (owner kept those rows), and the 2.0.6a Rig Pouch Only trim.

## B9.7: Butt Strike, Pistol Whip, the melee hit flash and Lift Doors have no row anywhere; README says to turn Butt Strike on
- Kind: setting or menu
- Where: src/MENUDEF.rsq:3 ("every other row is on Test and Debug"), 164-202 (the Test and Debug page);
  README.md:161, 165 ("Off until you turn them on: Butt Strike"); src/README.txt:78-83, 90-92;
  src/MENUDEF.rsq:226-242 (`RSQ_BashFXOpt`, `RSQ_BashTintOpt`: option lists no row uses);
  src/CVARINFO.rsq:42-53; src/CVARINFO.rsvr:39-45.
- What the code does: 41 of the 122 cvars have no menu row. Among them are settings the code still reads and the
  READMEs still describe: `rsq_butt` (off by default; melee.zs:727), `rsq_butt_speed`, `rsq_pistol_whip` (melee.zs:747),
  `rsq_whip_speed` (the 2.0.3g slider "Pistol Whip: Swing Needed"), `rsq_bash_flash` / `rsq_bash_fx` / `rsq_bash_tint`
  (the 2.0.3d "Melee Hit Flash" On / Off the owner asked for, and its Style and colour), `rsq_door` and its five
  (2.0.3f "Lift Doors by Hand"), `rsq_no_trigger_punch`, `rsq_punch_use`, `rsa_rl_lock_cone`.
- Why it is wrong: without RSQ Melee loaded a player cannot turn Butt Strike on except from the console, and cannot turn
  the pistol whip, the hit flash or door lifting off. CHANGELOG.md:93 says 2.0.5m changed "no setting", and the two
  hit-flash lists were renamed in 2.0.5n (CHANGELOG.md:67) for rows that are no longer there.
- Checked: all five MENUDEF lumps (84 cvar rows) by script; the full list of the 41: rsa_rl_lock_cone rsb_flick_speed
  rsg_rsq_nade rsld_reroll rsq_ballistics_cfg rsq_bash_flash rsq_bash_fx rsq_bash_tint rsq_butt rsq_butt_speed rsq_door
  rsq_door_commit rsq_door_gain rsq_door_grip rsq_door_palm rsq_door_use rsq_dual_start rsq_hud_noammo rsq_hud_nohp
  rsq_hud_vrrow_ver rsq_no_trigger_punch rsq_pistol_whip rsq_punch_use rsq_round_speed rsq_switch_log rsq_whip_speed
  rsr_eat_grip rsr_grab_buttons rsr_grip_keys rsr_magrelease rsvr_axe_edge rsvr_axe_hold rsvr_axe_keys
  rsvr_axe_lock_range rsvr_axe_pick_cone rsvr_axe_seek_log rsvr_axe_throw_blend rsvr_butt_fwd rsvr_melee_down
  rsvr_melee_log rsvr_melee_swing. (rsq_hud_nohp / noammo have their rows in RSQ Gun Cards, CVARINFO.rsq:74-75.)
- Sure?: certain that the rows are absent. Whether each was dropped on purpose is the owner's to say.
- Fix A: put the player-facing ones back on Test and Debug under a "Melee" header: Butt Strike, Pistol Whip, Pistol Whip
  Swing (slider 2 to 10), Melee Hit Flash, Hit Flash Style (`RSQ_BashFXOpt`), Hit Flash Colour (`RSQ_BashTintOpt`), Lift
  Doors (about 16 lines, 1 file).
- Fix B: if they are meant to be console-only: delete the two unused lists (MENUDEF.rsq:226-242) and take "Butt Strike"
  out of README.md:165 and the melee menu lines out of README.txt:78-92.
- Already known?: partly. Q3 (owner: rows for recoil, SSG, side port; the flick speed stays console only) and SH2 (the
  dual-pistol start row removed on purpose). The melee and door rows are not in the list.

## B9.8: With LegenDoom loaded, console net events give health, legendaries and spawns to anyone, with no cheat check
- Kind: netplay (and a console cheat in single player)
- Where: src/zscript/rsld/handler.zs:1255-1470 (`NetworkProcess`): `rsld_testlegend` (1265), `rsld_fx...` (1272),
  `rsld_target...` (1291), `rsld_health:` (1343), and 20 more probes; also src/zscript/rsq/roster.zs:98
  (`rsq_moon_count`) and src/zscript/rsq/counters.zs:164 (`rsq_ontop`), which only print.
- What the code does: 26 event names are heard that nothing in src sends; they are the rig's probes, typed as
  `netevent <name>`. The only gate is "LegenDoom is loaded" (handler.zs:1257). `netevent rsld_health:999` sets the
  sender's health; `rsld_testlegend` hands a legendary; `rsld_target<class>` spawns any class.
- Why it is wrong: no `sv_cheats` test and no `rsld_debug` test, so in a net game any player can use them.
- Checked: the handler's first 50 lines and lines 1340-1348; the sent / heard lists (script). The other reader of
  handler.zs has the body.
- Sure?: certain that there is no gate in the lines read.
- Fix A: one line after handler.zs:1263 (the real "rsld_drop"): `if (!sv_cheats && RSLD.DebugLevel() == 0) return;`
  (1 line, 1 file; `rsld_debug` is `server noarchive`, so only the host can open the probes).
- Or intended: single-player rig tooling the owner wants left open.
- Already known?: no.

## B9.9: Six per-player settings are read as "this machine's" in game code (multiplayer only)
- Kind: netplay
- Where: src/zscript/rsq/alts.zs:41 with 33 (`rsa_rl_lock`, declared `user` at CVARINFO.rsr:34, read with FindCVar and
  then given to EVERY player as the token RSA_Opt_RLLock); src/zscript/rsr/rsr_pump.zs:502 with 82-86 (`rsr_sideport`,
  `user`, decides how many loading ports a shotgun has); src/zscript/rsg/grenade.zs:475 (`rsr_assist`);
  src/zscript/rsq/casemodels.zs:106, 117 (`rsq_casing_models`, `rsq_casing_size`, set a casing actor's model and Scale);
  src/zscript/rsq/bullet.zs:127 (`rsq_round_speed`).
- Why it is wrong: FindCVar on a `user` cvar returns the local machine's value. In a net game each machine then runs
  different game code for the same player: Rocket Lock-On and the side port can differ between machines.
- Checked: all 122 cvars' read sites by script (10 FindCVar sites on `user` cvars, 4 helper sites). The other FindCVar
  sites on `user` cvars are fine: draw code (handler.zs:1494) or logs (switch.zs:139, melee.zs:1979).
- Sure?: certain about the reads; the pack's README already calls scopes and hand tone single player only.
- Fix A: declare `rsa_rl_lock` as `server` like its four neighbours (CVARINFO.rsr:34, 1 word; rlock.zs:83 reads it per
  player and keeps working), and read `rsr_sideport` with the player (`RSR.PlayerInt(p, 'rsr_sideport', 1)`), which needs
  the player passed into `RSP_Guns.Ports` (about 6 call sites).
- Or intended: if multiplayer is not supported, say so in the README and leave it.
- Already known?: `rsq_round_speed` is in SH3 ("still unused"). The rest: no.

## B9.10: The off hand's magazine count is missing on most of Brutal Doom's own HUD layouts
- Kind: wrong behaviour
- Where: src/SBARINFO.rsq:30 (classic bar: drawn) and 216 (ZDoom type, 16:9: drawn). Not drawn: 351-355 (ZDoom type,
  4:3), 536-543 and 680-687 (Brutal Simple), 775-778 and 879-882 (Minimal), 987-990 (Full Helmet).
- What the code does: `RSQ_HudMagOff` is drawn in 2 of the 9 places that draw `RSQ_HudMag`.
- Why it is wrong: a player with a gun in each hand on HUD Type 2, 3 or 4 sees one magazine only. The default HUD
  (VR Row) is drawn by bottomhud.zs and shows both, so this only shows after changing HUD Type.
- Checked: all 1,124 lines. The file is generated (tools/hud/make_sbarinfo.py, line 1), so the fix belongs there.
- Sure?: certain.
- Fix A: have make_sbarinfo.py add the `InInventory RSQ_HudHasMagOff` line after every magazine line (7 places), with a
  place for each layout to be chosen in the headset.
- Or intended: if only VR Row and the ZDoom type are meant to carry it.
- Already known?: no.

## B9.11: The README inside the pk3 describes an older pack; version names disagree
- Kind: misleading text
- Where and what:
  - src/README.txt:1 says 2.0.5g; VERSION says 2.0.6b; the built file is pk3/03_BD22_VR-Reloaded_3.0rc.pk3 (it is this
    tree byte for byte); README.txt:41, 47 name `03_BD22_VR-Reloaded_2.0.4w.pk3`; CHANGELOG.md:14 says the current build
    is 2.0.5l, its newest entry is 2.0.5n, and it has no entry for 2.0.6a (menutrim.zs), 2.0.6b or 3.0rc.
  - README.txt:76-78 "GUN BASH: your kick key ... bashes with the gun". Removed in 2.0.2 (DECORATE.rsqbash:1,
    CVARINFO.rsq:40-41: "the kick key is BD22's boot again").
  - README.txt:78 "Pick its impact effect and its colour in the menu", 90-92 "its rows say 'without RSQ Melee'",
    124-126 "33 rows ... 'Reload: tuning and debug'": none of these rows or names exist now (B9.7).
  - README.txt:100-105 recoil for 22 guns (B9.1).
  - README.txt:128 "Every option defaults to how Brutal Doom behaves": True Bullets, Ballistics Low, Instant Switch,
    non-standard reloads and VR Row are on by default (CVARINFO.rsx:12, CVARINFO.rsq:5, 71, 4).
  - build.py:3-4 "On main it is the public number (1.9x)": this is main and VERSION is 2.0.6b; and `python build.py`
    writes `BD22_VR-Reloaded_2.0.6b.pk3`, not the `03_..._3.0rc` name that is shipped.
- Sure?: certain.
- Fix A: rewrite src/README.txt from README.md (it ships to every player inside the pk3); add the 2.0.6a, 2.0.6b and
  3.0rc entries to CHANGELOG.md; set VERSION to what is shipped; fix build.py's docstring (4 files).
- Already known?: no.

## B9.12: Seven code fallbacks differ from the CVARINFO default
- Kind: setting or menu (harmless while the cvars exist)
- Where: src/zscript/rsq/fists.zs:131 (`rsq_punch` fallback 0, default 1, CVARINFO.rsq:7);
  src/zscript/rsr/rsr_m203.zs:160, vreload.zs:1088, 1100 (`rsr_reload` 0, default 1);
  src/zscript/rsq/ballistics.zs:29 (`rsq_ballistics` 0, default 1); src/zscript/rsq/muzzle.zs:241
  (`sv_rsq_twohand_spread` 1.0, default 0.5); src/zscript/rsq/scope_real.zs:298 (scope mode: missing cvar means Dot,
  default is 3x).
- Why it is wrong: a fallback is only used if the cvar is missing, which cannot happen while the CVARINFO lumps ship, so
  no player sees it. `rsq_punch` is the one to line up: its default was changed to 1 in 2.0.5n and the fallback was not.
- Checked: about 100 fallbacks (76 by script through the helpers, the rest by eye); all others agree.
- Sure?: certain.
- Fix A: change the five literals (5 lines, 5 files), or leave them: each falls back to "feature off", which is a
  defensible choice.
- Or intended: "missing means off" is a reasonable rule; then only fists.zs:131 is out of step with its own comment.
- Already known?: no.

## B9.13: About 0.3 MB of files ship that nothing names
- Kind: dead code
- Where: src/sounds/rsb/flame/flamer_blast.ogg, flamer_loop.ogg, flamer_start.ogg, ft_lighthiss.ogg (no SNDINFO line);
  src/models/rsq/ammo_hand.md3 and rsq_ring.md3 (no MODELDEF block since the FBX hands; MODELDEF.rsrpump:134 still says
  ammo_hand.md3 "is already in the packs"); src/models/rsq/ammobox/ammoa_empty.png, ammoa_noammo.png;
  src/rsqvox/bnuka.png, magaa.png, mboxa.png; src/sprites/rsqcandle/WICKA0.png, WICKB0.png, WICKC0.png (no state, no
  model, no GetSpriteIndex names WICK).
- Checked: every file under sounds/, models/, rsqvox/ and sprites/ against every SNDINFO, MODELDEF and script (the 17
  hand-tone skins are named at run time by handtone.zs:137 and are in use).
- Sure?: certain nothing in src names them. Another mod of the series could ask for one by path (the two ammobox skins
  and WICK look like that); the owner will know.
- Fix A: delete the ones no other mod uses (up to 14 files).
- Already known?: no.

## Things that looked wrong and are not (so the next reader does not chase them)
- Case: every model, skin, sound and `#include` path in src matches its file's case exactly (about 8,600 names checked), and
  the voxel pack's 233 `.kvx` names match the voxel pack. Nothing to fix for Android.
- src/zscript/rsr/rsb_guns.zs:678-736 play `weapons/9mmclip1`, `9mmclip2`, `9mmslide`, defined nowhere. Rows 5 and 6 of
  that table are never selected (rsb_guns.zs:34-37 returns 1, 2, 3, 7, 10, 11 only).
- 21 sprite names with no lump and no model (RBTG, RBTP, RBTW, RBV*, RBW*, RQUQ, RQUH, RQUX and spare frames of RBGP,
  RBRP, RBSP, RQUP, RQHN K) are only in the two never-spawned actors that make names known (rsb_guns.zs:1142,
  rsr_pump.zs:1040). `SupF: RQSP F` (hands.zs:118) has no model, and no gun's support letter is F (handtable.zs:60).
- 32 more no-lump sprite names (KIKF, R2RL, RIBA, DEAG, PISG ...) and the raw sound names `AmmoAPIN`, `PRSDRAW`,
  `RAIL_UZ`, `RAIL_ZM`, `ROCKPKUP`, `USASPUL1`, `weapons/aim`, `weapons/empty`, `pickups/slowmo` are in base Brutal
  Doom's own lines, carried over in this pack's copies of its files. Base BD's, not this pack's.
- `criticalshots/*` (axegrab.zs:280-284) and the cvars `csh_*`, `rsqa_*`, `rsqgn_replace_bd`, `ld_*` belong to other
  mods; every read is null-checked.
- SNDINFO.rsld's bare lump names (`LDLEGEN1` ...) are LegenDoom's and `dsempty` / `dsswtchn` ... are the engine's or
  Doom's; the 15 `$random` members of menu/quit1 and quit2 are stock Doom sound names.
- A cvar and a class share a name five times (`rsq_flick` / `RSQ_Flick`, `rsq_hands`, `rsq_recoil`, `rsr_assist`,
  `rsg_vr`). The classes are only ever used as types or with a dot, so nothing resolves to the cvar.
- `weaponsection "Brutal_Doom"` three times (KEYCONF.rsq:4, 12; KEYCONF.rsqmoon:2) only re-reads the same saved slots.
- OptionValue `HUDType` is defined here and in base BD: the later one wins, on purpose (B9.4 is about its row 5).
- `Option ... "OnOff"` on int cvars (`rsr_reload`, `rsq_recoil`, `rsq_punch`, `rsg_*`) writes 0 / 1, which is what each
  reader tests.
- All 9 sliders start on a step inside their range, and no clamp in code is tighter than its slider.
- tools/handtone_build.py's block pattern does not match a block whose class line carries a comment before the `{`
  (all of MODELDEF.rsbullet and MODELDEF.rsqcase). Those 12 blocks have no FBX hand, so the built pk3 is right; a hand
  block written that way would silently keep slot 0 and miss Hand Skin Tone.
- The SURFACES.rsq header comment contains `surface name { ... }`; ballistics.zs:517-519 strips `//` first.
- SBARINFO.rsq draws `RSQ_HudRes` twice at the same spot in the classic bar (lines 31, 37, 46): same number, same place.
- The "ACS preset" scripts in base BD (BD_Main.acs:290, 347, 405) set HUD Type back to 1 when a Brutal Doom preset is
  applied; the one-time move to VR Row (bottomhud.zs:21-29) does not run again. That is the player's own choice of preset.

## Not read or not checkable
- MODELDEF lumps past line 300 were checked by script, not by eye (as the task says). A wrong number that is still a
  legal number (an Offset, a Scale, a frame that exists but is the wrong pose) cannot be found that way.
- Whether a frame index is the right POSE, and whether a sprite frame a weapon shows is keyed for the class that shows
  it (a model is per class), was not checked: (e) only asks "is there a lump or any model block".
- QuestZDoom's own pk3 and LegenDoom's pk3 are not on this machine: `VROptionsMenu`, `QuickMenu`,
  `InfoAndCreditsMenu`, `ExperimentalMenu`, `CommandLineProfileMenu`, `LegenDoom`, `pukename LDMenuToggle`, the `vr_*`
  cvars and stock sound names are taken as theirs without being seen.
- Engine behaviour stated from memory, not from source: VOXELDEF lumps all being read (B9.2), the "Unknown sprite" stop
  (B9.3), the ACS message (B9.5), pk3 name lookups ignoring case.
- src/LICENSE_Dakka_WTFPL.txt was not opened.
