# BD22 VR Reloaded bug read, part 3: zscript/rsq (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

Base Brutal Doom (brutal22test6.pk3), QuestZDoom's engine source and the other RSQ mods are not in the repo. Where a
finding rests on one of them it says so.

## Files read
All 39 files under `src/zscript/rsq/`, every line, with the Read tool.

| file | lines | read to the end? |
|---|---|---|
| alts.zs | 60 | yes |
| ballistics.zs | 582 | yes |
| bash.zs | 105 | yes |
| bottomhud.zs | 136 | yes |
| bullet.zs | 149 | yes |
| casemodels.zs | 123 | yes |
| casings.zs | 188 | yes |
| counters.zs | 465 | yes |
| dual.zs | 593 | yes |
| dualhands.zs | 136 | yes |
| dualtable.zs | 53 | yes |
| fistmoves.zs | 37 | yes |
| fists.zs | 301 | yes |
| flamespout.zs | 115 | yes |
| flash.zs | 154 | yes |
| flick.zs | 512 | yes |
| gcsprites.zs | 115 | yes |
| gunmoves.zs | 258 | yes (the three long table lines 54-56 read as text, not checked number by number) |
| handler.zs | 79 | yes |
| hands.zs | 1390 | yes (1-700, 700-1390) |
| handtable.zs | 171 | yes |
| handtone.zs | 148 | yes |
| hit.zs | 183 | yes |
| holecap.zs | 23 | yes |
| menutrim.zs | 28 | yes |
| muzzle.zs | 601 | yes |
| playerrounds.zs | 385 | yes |
| pose.zs | 314 | yes |
| recoil.zs | 364 | yes |
| rlock.zs | 274 | yes |
| roster.zs | 190 | yes |
| rounds.zs | 42 | yes |
| scope.zs | 312 | yes |
| scope_real.zs | 407 | yes |
| semiauto.zs | 35 | yes |
| shotfx.zs | 324 | yes |
| switch.zs | 143 | yes |
| voxels.zs | 159 | yes |
| voxtable.zs | 123 | yes |
| total | 9,777 | |

Also opened to confirm or kill a suspicion: `src/ZSCRIPT.rsvr`, `ZSCRIPT.rsx`, `ZSCRIPT.rsz`, `ZSCRIPT.nosniper`, all
`MAPINFO.*`, `CVARINFO.*` and `MENUDEF.*` (by search), `SNDINFO.rsq` (by search), `SURFACES.rsq` 1-25,
`MODELDEF.rsqdual` / `.rsm` (parts), `zscript/rsvr/vrhand.zs` 1-120 and 301-321, `zscript/rsvr/melee.zs` 215-240,
`zscript/rsr/rsr_m203.zs` 820-835, `zscript/rsld/ld_g2_proj.zs` 50-62, `DECORATE.rsqdual` (class heads, off magazines),
`actors/Weapons/*.dec` (class heads, AmmoType lines), `CHANGELOG.md` (parts), `BUGS_FROM_CODE_READ_2026-11-24.md` (whole).

### The include list against the folder
- `src/ZSCRIPT.rsvr` includes 34 of the 39 files (lines 5, 12-22, 28-38, 46-56); `src/ZSCRIPT.rsx` includes the other 5
  (playerrounds, shotfx, handtone, holecap, menutrim; lines 3-7).
- Every file in the folder is included exactly once. No file is left out. No file is included twice. No include in any of
  the four ZSCRIPT lumps names a file that does not exist.
- The comment at `src/ZSCRIPT.rsvr:25-27` speaks of scope.zs being listed twice by "another lane": it is listed once.
- One class of this folder is compiled and never switched on: see B3.1.

## Findings, worst first

## B3.1: The Recoil row does nothing: no gun kicks, on or off
- Kind: setting or menu
- Where: `src/MAPINFO.rsvr:5` (the handler list); `src/zscript/rsq/recoil.zs:52` (class RSQ_Recoil);
  `src/MENUDEF.rsq:132-133` (row "Recoil", tip "Firing kicks the gun in your hand"); `src/CVARINFO.rsq:57`;
  `src/README.txt:102-105`; `src/zscript/rsld/ld_g2_proj.zs:56-57`
- What the code does: RSQ_Recoil is an EventHandler. An EventHandler only runs when a MAPINFO `AddEventHandlers` line names
  it. The four MAPINFO lumps name 28 + 5 + 2 + 1 handlers; RSQ_Recoil is in none of them. Nothing else creates it.
  `EventHandler.Find("RSQ_Recoil")` in ld_g2_proj.zs therefore returns null (it is guarded, so no abort).
- Why it is wrong: the menu has a Recoil row, the README lists RECOIL as a feature, and 2.0.5n changed recoil.zs three
  times (one kick a hand, five more guns, the row) on the owner's "Fix it" / "Add them" / "Yes". None of that can run.
  `CHANGELOG.md:749-750` (the owner's 1.99 headset pass) says "Recoil is gone. It turned the gun model, so the gun spun
  around the shoulder and pulled away from the hands": the handler looks to have been taken off the list then, and the
  2026-11-24 code read told the owner "Recoil is on".
- Checked: searched all of `src/` for `RSQ_Recoil` and for `AddEventHandlers`; the repo has one commit, so the history of
  the list cannot be seen.
- Sure?: certain that it is not registered. What the owner wants (recoil back, or the row gone) is his call.
- Fix A: recoil back: add `"RSQ_Recoil"` to `src/MAPINFO.rsvr:5` (1 line). Before that, look again at why 1.99 took it
  out; and note recoil.zs:355 only takes last tic's kick back when the gun did not touch its layer, so during A_Lower /
  A_Raise (which add to y) the kick piles up each tic.
- Fix B: recoil stays off: remove the row (`MENUDEF.rsq:132-133`), the README paragraph, the two calls in
  ld_g2_proj.zs, and mark recoil.zs unused (about 10 lines, 4 files).
- Or intended: only if the owner knows recoil is off and the row is a leftover.
- Already known?: no. It contradicts Q2, SH4, SH5 and SH9, which all took recoil to be running. Owner said (Q2) "Yes: a
  Recoil row is added in 2.0.5n", (SH4) "Fix it", (SH5) "Add them".

## B3.2: The default reload gesture (point off-screen and pull the trigger) never reloads; with two guns no gesture reloads at all
- Kind: wrong behaviour
- Where: `src/zscript/rsq/flick.zs:462-489` (RSQ_HotdGate), `:211-232` (GateLayer), `:180-187` (the gesture's branch)
- What the code does: the gate that turns an off-screen trigger pull into a reload is two layers called by an item,
  RSQ_HotdGate. GateLayer gives the item with `mo.GiveInventory('RSQ_HotdGate', 1)` and, if it is still not in the
  inventory, returns (line 227-228). RSQ_HotdGate is a CustomInventory with only the states Gate and GateLate.
- Why it is wrong: stock CustomInventory.TryPickup only puts the item in the inventory when it has a `Use` state
  (`(useok || pickupstate == NULL) && FindState('Use') != NULL`); with neither Pickup nor Use it returns false and
  GiveInventory destroys the item. So the item is never held, the two layers are never made, RSQ_Flick.Gate never runs.
  With Reload Gesture on its default (0), line 180-187 `continue`s before the old flick code, so the old flick does not
  run either. Result with defaults: a gun in each hand reloads only on the Reload button; a lone SSG's gesture, a lone
  rifle's launcher gesture and the main gun beside a saber / Zippo / shield have no gesture. Also one actor is spawned and
  destroyed every tic for every player.
- Checked: RSQ_HotdGate is named nowhere else in `src/` or `tools/`; `CHANGELOG.md:145` marks 2.0.5e "code only, not run,
  not headset-confirmed". The engine's CustomInventory script is not in the repo: the TryPickup rule is from GZDoom 4.14's
  own `inv_misc.zs` as I know it, not read here.
- Sure?: likely. Settles it: in game, `printinv` shows no RSQ_HotdGate; or with `rsq_switch_log 1` no "RSQ off-screen"
  line ever prints.
- Fix A: give RSQ_HotdGate a Use state so it can be held: `Use: TNT1 A 0; Fail;` (2 lines, flick.zs).
- Fix B: make the two gate states states of RSQ_HotdStates (a Weapon, which GiveInventory can give) and call the layers
  with that as the caller (about 10 lines, flick.zs).
- Once it runs, one more thing to guard: a held launcher press leaves the gun in `Hold` (-1 tics, no A_WeaponReady,
  flick.zs:508-510); if the gate layers are removed while it is held (line 214-220: the option changed, an off-hand gun
  arrives with Dual Reload Gesture off) nothing puts the gun back in Ready. Put it back in GateLayer's `!want` branch.
- Or intended: no.
- Already known?: no.

## B3.3: The off-hand Silvergun shoots from its grip, right and low of its barrel
- Kind: wrong behaviour
- Where: `src/zscript/rsq/muzzle.zs:310` (`if (n == 'BrutalRevolver')`), `:369-372` (HasBore), `:420-427` (OffWhere);
  `src/actors/Weapons/BrutalRevolver.dec:263` (`RSQ_Off_BrutalRevolver : BrutalRevolver`)
- What the code does: Muzzle() finds the Silvergun's row by exact class name. The off-hand version's class name is
  RSQ_Off_BrutalRevolver, so it gets (0, 0, 0): no muzzle, HasBore false. Every other off-hand copy is matched with `is`.
- Why it is wrong: with no row, the off-hand Silvergun's shot is not moved to the muzzle and not turned onto the drawn
  barrel (playerrounds.zs:223-228, 266), so it goes 3.85 degrees right and 3.36 low of the barrel (muzzle.zs:361-362),
  and its muzzle glow goes to the controller (muzzle.zs:84). "Two Silverguns" makes this the left gun of the pair.
- Checked: BrutalRevolver's parent is BrutalWeapon, not Revolver, so the later `w is 'Revolver'` does not catch it.
- Sure?: certain from the code; the size of the miss is the file's own number.
- Fix A: `if (w is 'BrutalRevolver')` at muzzle.zs:310 (1 line). It stays ahead of the Revolver line.
- Or intended: no.
- Already known?: no.

## B3.4: With HUD Type "VR Row" the belt and tank guns show no magazine, a reserve up to 10 too high, and the Machinegun shows its grenades as the magazine
- Kind: wrong behaviour
- Where: `src/zscript/rsq/bottomhud.zs:94-107` (ReadAmmo), `:59-75`; against `src/zscript/rsq/counters.zs:141-159`
  (GunAmmo) and `:192-213` (Hud)
- What the code does: the VR Row reads the weapon's Ammo1 and Ammo2 only; with two pools the one with the smaller
  MaxAmount is called the magazine. The other HUD types read RSQ_HudMag / RSQ_HudRes, which counters.zs fills from the
  nine guns' real magazines (RSQ_Mag_<gun>) and takes the lent rounds out of the reserve.
- Why it is wrong: MG42, Flamethrower2, IncendiaryLauncher, Unmaker, Devastator, NukeLauncher, HellishMissileLauncher and
  Minigun have one AmmoType, so the row shows no magazine and a reserve that includes the up to 10 lent rounds
  (counters.zs:22, 284-302). The Machinegun has AmmoType2 "AmmoRocket" (`actors/Weapons/Machinegun.dec:8-11`), so the row
  calls whichever of Clip2 / AmmoRocket has the smaller cap "the magazine". HUD Ammo (rsq_hud_ammo, Reserve Only) is
  not read by the row at all. The VR Row is the default HUD Type since 2.0.5n (bottomhud.zs:21-28).
- Checked: AmmoType lines of Minigun.dec, MG42.dec, Flamethrower.dec, Machinegun.dec; bottomhud.zs's own note "Code only,
  not run in the headset" (line 15).
- Sure?: certain from the code.
- Fix A: in RenderOverlay take the numbers from the player's RSQ_HudMag / RSQ_HudHasMag / RSQ_HudRes / RSQ_HudMagOff /
  RSQ_HudHasMagOff counts (already set every tic), keep ReadAmmo for the icon only (about 12 lines, bottomhud.zs).
- Or intended: only if the row must match Gun Bonsai VR's numbers even where they are wrong for these guns.
- Already known?: no.

## B3.5: A long hitch at the start of every map (hand skin tone reads every MODELDEF one character at a time)
- Kind: performance
- Where: `src/zscript/rsq/handtone.zs:39-45` (Parse), `:47-70` (StripComments), `:72-103`, `:118-119`
- What the code does: RSQ_HandTone is a per-map EventHandler; `parsed` starts false on every map. On the first tic it
  reads every MODELDEF lump loaded (this pack's alone are 4,052,638 bytes, of which `MODELDEF.rsqgc` is 3,004,304; Brutal
  Doom's and other mods' come on top), copies each one byte at a time in script (`ByteAt` + `AppendCharacter`, line
  51-68), then lowercases it and runs three whole-string replaces.
- Why it is wrong: that is four million script loop turns and string appends on the first tic of each map, on a Quest,
  to find a list of class names that never changes while the game runs. It runs even with Hand Skin Tone at 0.
- Checked: sizes with `wc -c src/MODELDEF.*`; the handler is in `MAPINFO.rsx:2`; a save keeps `parsed`, so a load does
  not pay again, a new map does.
- Sure?: likely (the work is certain, the seconds are not measured). Settles it: time the first tic of a map with and
  without RSQ_HandTone on the list.
- Fix A: have `tools/handtone_build.py` write the class list into a generated .zs table, and drop Parse (about 20 lines).
- Fix B: parse once per session in a StaticEventHandler and skip lumps that do not contain "fbx_hand.png" with one
  IndexOf before stripping (about 15 lines).
- Or intended: no.
- Already known?: no.

## B3.6: Holding an MG42 or Machinegun, reloading an off-hand Rifle takes its rounds out of the belt in the gun
- Kind: wrong behaviour
- Where: `src/zscript/rsq/counters.zs:258-269` (RealTick), `:351-381` (OffFill, the one case handled);
  `src/DECORATE.rsqdual:2528, 2582-2591` (RSQ_Off_Rifle fills from Clip2)
- What the code does: RealTick reads any drop of the reserve item since last tic as shots of the held gun: it takes the
  drop off the magazine and gives back to the reserve whatever the lent rounds did not cover.
- Why it is wrong: the reserve also drops when something else takes from it. MG42 and Machinegun share Clip2 with the
  Rifle, and the off-hand Rifle's reload takes Clip2 one round at a time. Each round it takes is charged to the belt and
  handed back to the pouch, so the Rifle's magazine is filled out of the MG's belt. The off-hand Minigun has this exact
  correction (`h.lastRes[pn][GUN_MINIGUN] -= n`, line 378); no other gun does.
- Checked: comment at counters.zs:117 lists Clip2's guns (Rifle, Sniper, MG42, Machinegun); the off-hand rule lets a
  Rifle sit in the off hand beside any main gun (dual.zs:80-94).
- Sure?: likely. Settles it: main MG42 at 100, off-hand Rifle empty, reload the Rifle, read the belt.
- Fix A: a static `RSQ_Counters.NotAShot(mo, class, n)` that lowers `lastRes` for every gun on that reserve, called from
  the off-hand copies' fill states the way RSQ_OffFillMinigun is (about 15 lines, counters.zs, plus one line per fill
  state in DECORATE.rsqdual).
- Fix B: count shots by the gun's own fire states (a token given per shot) instead of by the reserve dropping.
- Or intended: no.
- Already known?: no.

## B3.7: With two weapons out, a main-hand Ruger or Machinegun is held by no hand
- Kind: wrong behaviour
- Where: `src/zscript/rsq/dualhands.zs:59-110`; `src/zscript/rsq/hands.zs:1305-1306, 1309-1310` (DFbxTrgSni / DFbxTrgMGun,
  never chosen); `src/MODELDEF.rsqdual` (no block for Sniper or Machinegun)
- What the code does: while the off hand holds anything but RSQ_Hands, RSQ_DualHands draws each gun's hand as a layer
  called by the gun. For row 22 (Sniper) it picks "DGunF" (Trigger(22) is ""), for row 27 (Machinegun) "DTrgI" /
  "DSqzI". Every other gun with an FBX hand has its own `if (i == ...)` line; these two do not.
- Why it is wrong: a layer called by the gun is drawn with the gun's own MODELDEF blocks. The dual-wield MODELDEF lumps (rsqdual,
  rsqdualmg, rsqaxedual, rsqmoondual) have blocks for 29 classes and none for Sniper or Machinegun, and the sprites RQGS / RQGT have no graphics, so nothing is drawn: the gun
  floats. The states made for them (DFbxTrgSni, DFbxSqzSni, DFbxTrgMGun, DFbxSqzMGun) are never used.
- Checked: class list of MODELDEF.rsqdual / rsqdualmg / rsqaxedual / rsqmoondual; no RQGS* or RQGT* file under `src/`.
- Sure?: likely. Settles it: Ruger in the main hand, a pistol in the off hand, look at the right hand.
- Fix A: two lines in dualhands.zs (`if (i == 22) label = firing ? "DFbxSqzSni" : "DFbxTrgSni";`, the same for 27 with
  MGun) and two MODELDEF.rsqdual blocks (Sniper: RQFN A/B; Machinegun: RQV2 A/B) from the generator.
- Or intended: only if those two guns are meant to have no hand in dual wield, as the chainsaw and sword are
  (dualhands.zs:62).
- Already known?: no.

## B3.8: The Silvergun, the Ruger and the Railgun have no muzzle flash light and no gunshot tail; the Silvergun and Ruger throw no round, no ricochet and plain chips
- Kind: drifted copy
- Where: `src/zscript/rsq/flash.zs:58-75`; `src/zscript/rsq/bullet.zs:63-115`; `src/zscript/rsq/hit.zs:67-128`;
  `src/zscript/rsq/rounds.zs:20-41`; `src/zscript/rsq/muzzle.zs:205-214` (HandGunName); against
  `src/zscript/rsq/recoil.zs:212-216` (the aliases)
- What the code does: the four tables are keyed by gun class name. HandGunName gives an off-hand copy its gun's name and
  any main-hand gun its own class name. None of the four tables has BrutalRevolver or Sniper; flash.zs also has no
  RailGun, Devastator, NukeLauncher, IncendiaryLauncher, Flamethrower2 or FlameCannon.
- Why it is wrong: recoil.zs was given five aliases in 2.0.5n ("five guns had no profile"); the same guns are still
  missing from the flash, round, hit and chip tables. The Silvergun is the pack's own revolver and gets none of the four.
- Checked: README.txt:106 says "MUZZLE FLASH 18 guns" and flash.zs has 18 rows, so the launchers may be meant; the
  Silvergun was added after the tables were generated (roster.zs:4-6).
- Sure?: certain from the code. Which of the missing guns should have rows is the owner's call.
- Fix A: an alias step as in recoil.zs: BrutalRevolver as Revolver, Sniper as Rifle (and RailGun a flash row) in each of
  the four files (about 12 lines, 4 files; the files say GENERATED, so carry it into tools/bd22_plus.py).
- Or intended: for the launchers and flamers, possibly. Not for the Silvergun.
- Already known?: partly. SH5, owner said: "Add them" (recoil only). The other four tables are not there.

## B3.9: Out of VR, or for another player in a net game, a worn gun's shots start at the wrong place
- Kind: netplay
- Where: `src/zscript/rsq/muzzle.zs:488-519`, `:453-457` (Where), `:251-263` (CndSpread)
- What the code does: WorldHitscanPreFired re-fires every main-hand hitscan with LAF_ABSPOSITION from `at` unless
  `!ok && !bore && k == 1.0`. Out of VR, `ok` and `bore` are false and `at` is RSVR_VRHand.HandPos(mo), which is the
  pawn's AttackPos. `k` is not 1.0 when RSQ Gun Cards' Weapon Condition answers a spread above 1.
- Why it is wrong: AttackPos is only written for the console player while in VR (`pose.zs:9-12`: for everyone else "those
  fields hold class defaults -- zero"). So with a worn gun and Gun Cards loaded, a player not in VR on this machine fires
  from the map's origin or from a stale point, and the machines of a net game disagree.
- Checked: vrhand.zs:17-21 (InVR), :301-304 (Now); RSQGC_Service is another mod, not in the repo.
- Sure?: likely for the code path; unsure how often it is met (QuestZDoom is nearly always in VR, single player).
- Fix A: when `!ok && !bore`, re-fire without LAF_ABSPOSITION and with the event's own offsets (3 lines).
- Or intended: no.
- Already known?: no.

## B3.10: A haptic buzz from another RSQ mod throws a puff and four sparks at your hand (True Bullets on)
- Kind: wrong behaviour
- Where: `src/zscript/rsq/shotfx.zs:250-278`, `:282-310`; against `src/zscript/rsq/ballistics.zs:72-75, 146-149` and
  `flash.zs:137`, `recoil.zs:288`
- What the code does: RSQ_ShotFX.WorldHitscanFired draws the tracer and then calls Impact for every player hitscan that
  is not melee. Draw returns for a line under 1 unit; Impact has no such test. The RSQ series' buzz is a 0.1-unit
  LAF_NOINTERACT hitscan (ballistics.zs:69-71); the flash, the recoil and the wall chips all skip it, this does not.
- Why it is wrong: each buzz (Rumble Backup, DistanceGrab, Grapple, Wheel) with a gun in hand spawns RSQ_DakkaPuff and
  up to four bouncing sparks at the controller. The same Impact also runs where a shot hit a monster or ended in mid-air.
- Checked: sv_rsq_true_bullets is true by default (CVARINFO.rsx:12). Whether the engine raises WorldHitscanFired for a
  trace that touched nothing is not readable here; ballistics.zs:148 is written as if it does.
- Sure?: likely. Settles it: Rumble Backup on, a pistol in hand, watch the hand when it buzzes.
- Fix A: at shotfx.zs:258 return when `RSQ_Ballistics.IsBuzzTrace(e.AttackLineFlags, e.AttackDistance)` or when
  `(e.DamagePosition - e.AttackPos).Length() < 1` (2 lines).
- Or intended: no.
- Already known?: no.

## B3.11: Every pellet makes its own actor, trace, light actor and sound; a shotgun blast on a computer wall lights nine lights
- Kind: performance
- Where: `src/zscript/rsq/bullet.zs:117-141` (no cap); `src/zscript/rsq/hit.zs:156-182`, `:119-126`;
  `src/zscript/rsq/ballistics.zs:130-159, 168-215`; `src/zscript/rsq/shotfx.zs:162-163, 187-197`
- What the code does: per hitscan event (one a pellet): one LineTrace (Impact), one RSQ_ImpactLight with a sound on
  CHANF_OVERLAP, dust particles, and with True Bullets off one RSQ_Bullet. The tracer and debris have caps (24 / 64); the
  round, the light actor and the sound have none. hit.zs's head says shotguns get no ricochet and no light per pellet, but
  the "every gun" rows (tech 60, screen 50, light 90, lava 80) light every pellet. With True Bullets on (default) each
  flying round lays about 7 RSQ_DakkaDot actors a tic, each running two script calls a tic for 5 tics, up to 600 alive.
- Why it is wrong: ballistics.zs:6 promises "Hard caps keep it cheap on Quest"; the per-pellet parts are outside the caps.
  An SSG or Minigun burst is where a Quest would feel it.
- Checked: caps at ballistics.zs:14-17, shotfx.zs:162-163; nothing was timed.
- Sure?: unsure how much is felt. Settles it: frame time on the Quest, SSG and Minigun into a wall, Ballistics Low,
  True Bullets on and off.
- Fix A: one impact sound and one light a tic per hand (as flash.zs does with lastFlash), and a live cap on RSQ_Bullet
  (about 15 lines, hit.zs and bullet.zs).
- Or intended: the dots' cap of 600 is a choice; the uncapped parts are not written down as one.
- Already known?: no.

## B3.12: Holding the rocket launcher's lock-on with nothing in the cone scans the whole map every tic
- Kind: performance
- Where: `src/zscript/rsq/rlock.zs:155-197`, `:107-108`
- What the code does: Paint is throttled by `lastPaint`, which is only set when a lock is taken (line 198). With alt held
  and nothing in the cone it runs every tic: a BlockThingsIterator of radius 4096, and for each monster nearer the line
  than the last a CheckSight and a String.Format for a log line (182-186) whether or not the log is on.
- Why it is wrong: PAINT_TICS (4) is meant to pace it; it does not pace the misses, which are the costly case.
- Checked: Logs() is only tested at line 194, after the loop.
- Sure?: certain for the code; the cost depends on the map.
- Fix A: set `lastPaint[n] = Level.maptime` on a miss too, and build `nearWhat` only when Logs() (4 lines).
- Or intended: no.
- Already known?: no.

## B3.13: The belt and tank guns top their magazine up by themselves at the start of each map
- Kind: wrong behaviour
- Where: `src/zscript/rsq/counters.zs:23-24` (`inited` is the handler's, one handler a map), `:270-282`
- What the code does: `top = !inited[pn][g] || fill`. On a new map `inited` is false, so the first tic the gun is held
  the magazine is filled from the pouch with no reload, and RSQ_NoMag (a magazine taken out) is cleared.
- Why it is wrong: the rounds are kept in inventory "so it survives a map change" (line 216); the free refill and the
  magazine putting itself back are not what a reload mod means. On the first ever hold it is right.
- Checked: the only other reset of `inited` is option off / not VR (line 252).
- Sure?: likely. Settles it: leave a map with the MG42 at 30, look at it on the next map.
- Fix A: remember "set up once" as an inventory token a gun (RSQ_Init_<gun>) in place of `inited` (about 8 lines).
- Or intended: possibly, as a kindness at map start.
- Already known?: no.

## B3.14: No menu row for the melee hit flash (on / off, style, colour), Punch Switches Open, No Trigger Punch, the lock-on cone
- Kind: setting or menu
- Where: `src/CVARINFO.rsq:10, 11, 44-46, 63`; `src/CVARINFO.rsr:35`; read at `bash.zs:20-33`, `fists.zs:57, 78, 278`,
  `rlock.zs:162-163`, `bullet.zs:127-128`
- What the code does: rsq_bash_flash, rsq_bash_fx, rsq_bash_tint, rsq_punch_use, rsq_no_trigger_punch, rsa_rl_lock_cone
  and rsq_round_speed are defined and read. No MENUDEF lump in `src/` has a row for any of them.
- Why it is wrong: bash.zs:19 says "add option for melee hit flash on off"; melee.zs:1261 names the row "Punch Switches
  Open"; bullet.zs:17 calls rsq_round_speed "the slider". The earlier read (SH8) saw the flash style row at
  MENUDEF.rsq 165-172; it is not there now.
- Checked: searched every MENUDEF.* for the seven names and for "flash" / "punch".
- Sure?: certain that there are no rows here. They may live in RSQ Melee's menu, which is not in the repo.
- Fix A: add the rows to RSQ_Options (7 lines, MENUDEF.rsq), or say in the README that they are console only.
- Or intended: if the 2.0.5m regroup dropped them on purpose.
- Already known?: partly. SH8, owner said: "Name them plainly" (the row has since gone). SH3: rsq_round_speed "still
  unused".

## B3.15: The scope can switch itself off as the gun comes up, and the red dot stays when the scope is off
- Kind: wrong behaviour
- Where: `src/zscript/rsq/scope_real.zs:282-286` (early return), `:312-319`; `src/zscript/rsq/hands.zs:804-821`
- What the code does: `altWas` is only updated while a scoped gun is held in VR. If alt fire is down on the tic the Ruger
  or Railgun becomes the ready weapon and `altWas` is a stale false, that counts as a press: the scope goes off with the
  "ads/out" sound. In DOT mode the reticle layer is shown whenever the mode says dot; it does not read `scopeOff`, so
  with the picture off the dot is still drawn on plain glass. The camera also keeps rendering while the player is dead.
- Why it is wrong: small, but each is a visible oddity on the two scoped guns.
- Checked: `scopeOff` is the handler's field and hands.zs does not read it.
- Sure?: likely (the first needs alt held through a switch).
- Fix A: update `altWas` before the early return; in hands.zs hide the reticle when RSQ_ScopeReal's `scopeOff` is set;
  Shutdown when `mo.health <= 0` (about 8 lines).
- Or intended: the dot staying may be meant (a dot costs nothing).
- Already known?: no.

## B3.16: Brutal Doom's auto reload can stay switched off after dual wielding across a map change
- Kind: wrong behaviour
- Where: `src/zscript/rsq/dual.zs:15` (`forcedNoAuto`, the handler's), `:434-445`
- What the code does: with a gun in the off hand NoAutoReload is set to 1 and `forcedNoAuto` remembers it. When the off
  gun goes, the token is set back from bd_noautoreload, but only if `forcedNoAuto` is true. The flag is per map; the
  token is inventory and travels.
- Why it is wrong: leave a map with two guns, arrive with one (or put the off gun away on the first tic) and the token
  stays 1: the main gun no longer reloads by itself though the player's Brutal Doom option says it should.
- Checked: bd_noautoreload and NoAutoReload are Brutal Doom's (not in the repo); BD22 may set the token again itself at
  map start, which would hide this.
- Sure?: unsure. Settles it: exit a map dual wielding, switch to one gun, empty it.
- Fix A: keep the flag as an inventory token (RSQ_ForcedNoAuto) instead of a handler field (4 lines).
- Or intended: no.
- Already known?: no.

## B3.17: Instant Weapon Switch can run a gun's ready frames many times in one tic
- Kind: wrong behaviour
- Where: `src/zscript/rsq/switch.zs:118-126`
- What the code does: after a switch it steps the new weapon's layer state by state, up to 96 times, until the hand's
  ready flag is set or the layer reaches `to.GetReadyState()` (the first state of Ready).
- Why it is wrong: a weapon whose Select ends in a ready loop that is not the Ready label's first state (Brutal Doom has
  Ready3 / dual ready loops) and that does not call A_WeaponReady on its first frames is stepped through that loop, its
  actions run each step, up to 96 in a tic. The 2026-11-27 note in the file fixed this for RSQ_Hands only.
- Checked: cannot see BD22's base weapons; the guns redefined in `actors/Weapons` belong to another part.
- Sure?: unsure. Settles it: `rsq_switch_log 1` and look for "ready after 96 select frames".
- Fix A: stop also when the state was already visited in this run (a small array of seen states, 5 lines).
- Or intended: no.
- Already known?: no.

## B3.18: Small ones, each real but low
- Kind: wrong behaviour / netplay / performance (as marked)
- (a) wrong behaviour, unsure. `muzzle.zs:498-516`: the comment says "melee traces are left as they are", but a melee
  hitscan fired while holding a gun with a muzzle row is still re-fired from the muzzle (`ok` is true), which adds the
  barrel's length to its reach. Fix: `if (e.AttackLineFlags & LAF_ISMELEEATTACK) return false;` unless k != 1 (1 line).
  Not known whether BD22 fires such a trace with a gun out.
- (b) wrong behaviour, likely. `ballistics.zs:409-415` with `:173-174`: a rocket or plasma ball that hits a monster is
  followed by a trace through actors of twice its speed plus 16 units, so a wall up to about 130 units behind the
  monster gets the impact sound, ricochet, light and chips. Fix: trace without TRF_THRUACTORS and stop on an actor.
- (c) netplay, certain from the code. `casemodels.zs:110-120` reads the console player's rsq_vox_casings in play code and
  then sets the casing's scale; `casings.zs:132-187`, `flamespout.zs:63-98`, `fists.zs:136-137`, `flash.zs:28-30`,
  `muzzle.zs:453-486` place things from the VR hand of whichever player fired, which only that player's machine knows
  (pose.zs:9-15). `handtone.zs:20` and `scope_real.zs:39-44` say the hands are off in multiplayer; hands.zs has no such
  test. Fix: either gate these on `!multiplayer` like the scope, or read RSQ_PoseHandler.Of. Intended if the pack is
  single player only; then say so in the README.
- (d) wrong behaviour, unsure. `counters.zs:123-135` sets MaxAmount of Clip2, Gas, AmmoM202, SoulAmmo, DevastatorAmmo,
  Nuke, MiniHellRocketAmmo and RSQ_MinigunAmmo back to Brutal Doom's every tic, so another mod's bigger ammo bag for
  those eight is undone. Nothing in `zscript/rsld` raises them. Fix: only lower the cap by what this file added.
- (e) wrong behaviour, unsure. `dual.zs:564-590` with `:190-204`: the off-hand service's "equip" gives the gun (bare) to a
  player who does not own it. Fix: return 0 when neither version is owned.
- (f) performance, low. Every tic for every player: `counters.zs:38-41` builds five class names from strings for each of
  nine guns; `recoil.zs:320` (if B3.1 is fixed) walks each hand's weapon class chain with up to 28 string compares a
  level; `flick.zs:73-109` looks up 15 classes by name. Fix: cache by class once.
- (g) wrong behaviour, low. `gunmoves.zs:23, 30`: Mirrored and Blends have 27 entries for 29 rows, so rows 27
  (Machinegun) and 28 (FlameCannon) always read "does not blend". If those models do blend between frames the hands
  step where the gun glides.
- (h) wrong behaviour, low. `dual.zs:356-366`: the 18 start rounds are given only when `maptime < 35`; a player who
  respawns later in a co-op map gets none.
- Already known?: no for all eight.

## B3.19: Dead code and stale text
- Kind: dead code / misleading text
- `hands.zs:879-924`: `offPunchTic` is never set above -1, so lines 904-923 never run; `press` (884) is unused.
  Already known: SH11, owner said "Clean it all" (the jab was removed; this remainder stayed).
- `hands.zs:742-743, 1098-1102, 112-113`: RSK_M203Handler.TriggerGrip always returns false (rsr_m203.zs:826-829), so
  SupM1 / SupM2 and the hook override are never used. Not known. Intended (1.32, owner: "option 2").
- `hands.zs:1327-1330` DFbxTrgSaw / DS and `:236` ScopeRing: never chosen. ScopeRing already known: RL9, owner said
  "Clean it all" (left in place).
- `counters.zs:19, 48-80`: REAL[] is all 1, so the counter branch never runs. Already known: SH11 (left in place).
- `flick.zs:70, 346-357, 391`: `autoWatch` is only set with a gun in each hand, where no hand reload can be under way.
  Already known: RL9 (left in place). The header at `flick.zs:31-35` still says a lone main gun's hand reload is started
  and finished by the button; 2.0.5h (line 373-382) took that away. Not known.
- `dual.zs:1-10` (header: "you get a copy by picking up a second one"), `:402-414` (Pistol Start, HasDual tokens),
  `:484-488` ("Find a second ..."), `:493-509` (WorldThingDestroyed): all overtaken by GrantBoth (`:370-378`), which
  gives the off-hand version with the gun. rsq_dual_start is still defined (CVARINFO.rsqdual:3) and read (dual.zs:403)
  with no row. Already known: SH2, owner said "this option should go if it does nothing"; SH11.
- `scope.zs:303-311` DotOk: called by nothing. Not known.
- `flamespout.zs:99` reads `lanec_flamelog`, which no CVARINFO defines: the log can never be switched on. Not known.
- `handtone.zs:20`, `scope_real.zs:39-44`: "the hands are off in multiplayer (hands.zs)": they are not (B3.18 c).
  handtone.zs:20 already known: SH11.
- `ZSCRIPT.rsvr:25-27`: the "duplicate include" note describes something that is not there.
- `roster.zs:40`: the comment on MOON_SPAWN_OFS speaks of the Clip2 and the SMG spawner; it is the Minigun box's offset.
- Fix: delete or correct, about 120 lines over 8 files; none changes what a player sees.

## Things that looked wrong and are not (so the next reader does not chase them)
- `bash.zs:20`: `RSQ.PlayerInt(PlayerPawn(target), ...)` would abort on a null target, but the only spawner
  (`rsvr/melee.zs:229-231`) sets target to a damage source that has a player, before PostBeginPlay runs.
- `switch.zs:44, 76` and `flick.zs:303, 310, 354, 379, 383, 431, 448`: `CVar.GetCVar(...).GetInt()` with no null test;
  rsq_instant_switch and rsq_switch_log are both defined (CVARINFO.rsq:71-72).
- Every cvar read in the folder is defined in a CVARINFO of this repo, except the engine's (vr_*), Brutal Doom's
  (bd_sbartype, bd_noautoreload), RSQ Accessibility's (rsqa_handed) and lanec_flamelog (B3.19). All are null-guarded.
- `hit.zs` / `flash.zs` sounds (`rsb/impact/*`, `rsb/glass`, `rsb/ricochet`, `rsb/flame/hiss`, `rsb/tail/*/int|ext`): all
  defined in `SNDINFO.rsq`. `ANIMDEFS.rsq:23` has the RSQSCOPE camera texture.
- Sprites with no graphics (QDBR, RQGF, RQGN, RQHR, the Q*** card names): they carry models, by design (gcsprites.zs:2-4).
  RSS3, RSU1, RSU4, RSU5, RSH0, RSDP, RSBM, RQRT files exist.
- `ballistics.zs:527-530` Parse: "surface name {" on one line would put the brace in the name, but SURFACES.rsq puts
  the brace on its own line.
- `dualtable.zs:21-25` MagMax against the off magazines' MaxAmount in DECORATE.rsqdual / rsqdualmg / BrutalRevolver.dec:
  all 12 match. All 13 Dual Options cvars exist and have rows; rsq_dual_moonlight is true, so "Two Silverguns" can go dual.
- Slider ranges against the code's clamps: rsq_offscreen_deg 40-85 (same), sv_rsq_round_speed 20-900 (code 10-1000),
  rsq_casing_size 0.5-2.5 (code 0.25-4.0): the menu is always inside the clamp.
- `MENUDEF.rsq:245-253`: HUD Type has the value 6 "VR Row" that bottomhud.zs sets; `menutrim.zs` looks in RSQ_Options,
  where the Rig Pouch Only row is (MENUDEF.rsq:83).
- `rlock.zs:100-101` Unmark(n, null) for a destroyed lock: Find(null) finds that entry, so it is removed.
- `playerrounds.zs:345-367` piercing round: one step past the hit point is enough, because an actor is met once on its
  crossing line, not once a unit (engine behaviour, not readable here; see below).
- `recoil.zs:279` integer division and `:260` one kick a tic: as meant.
- `holecap.zs`: the ring holds dead entries after holes expire; that only makes the cap a little stricter.
- `fists.zs:221` division by speed: guarded by `speed < thr` first.
- `handtable.zs` arrays: all 29 long, all guarded; `fistmoves.zs` guarded.
- Fallbacks that differ from the CVARINFO default (rsq_punch 0 against 1 at fists.zs:131, rsq_ballistics 0 against 1,
  the dual rows 0 against true, rsq_reload_gesture): harmless, the cvars exist.

## Not read or not checkable
- Brutal Doom's own classes and states named here by string and not in the repo: Melee_Attacks, MeleeStrikeNormal,
  MeleeStrike1Berserked, KickAttack, Rocket2, PlayerMuzzle1-3, PistolCasing, EmptyBrass, ShotgunCasing, MGLinks,
  FlamethrowerProjectileNew/2/3, BigFireBallWithGravity, Shotgunparticles2, DetectFloorBullet, DetectCeilBullet,
  PistolSpawner and the other spawners, Clip1, Clip2, ClipBox2, the HasDual tokens, StartDualWield, NoAutoReload,
  Reloading, FiredPrimary, IsPlayingAsPurist, BackpackItem, PowerStrength, SniperPuff. A wrong spelling would fail quietly.
  Three rest on base facts I could not see: `roster.zs:166` needs the map's Clip2 to exist at maptime 0 (if BD22 swaps
  it in a tic later, no Minigun ammo box is ever placed) and ClipBox2 to descend from Clip2; `muzzle.zs:61, 70-73`
  needs PlayerMuzzle to be a missile with the player as target; `voxels.zs:159` declares `DeathSphere`, which is a
  startup error if BD22 still has that class.
- Other RSQ mods named by string: RSQ_GloveOff, UBQS_*, SSQ_ShieldSaw, RSQTR_*, RSQFF_*, RSQWP_WhipWeapon, RSQGN_Grenade,
  RSQ_Glove, RSQGC_Service, RSQTR_RigService, RSQA_Menu, RSLD_AltDown: not in the repo.
- Engine behaviour taken from the files' own comments or from memory, not read: CustomInventory.TryPickup (B3.2), whether
  WorldHitscanFired comes for a trace that hits nothing (B3.10), how LineTrace meets an actor it starts inside
  (piercing round), whether a rail event's AttackAngle includes the angle offset muzzle.zs adds (if not, the Ruger's
  piercing round in True Bullets mode is not turned onto the barrel: `playerrounds.zs:304-309`), QuestZDoom's per-hand
  weapon flags used by switch.zs and dual.zs, and whether `PlayerInfo.attackdown` is read the way semiauto.zs says.
- `flick.zs:307, 411-455`: an off-screen pull sends the gun into Brutal Doom's Reload. If that Reload bounces straight
  back to Ready on a full magazine with the trigger still held, the gun would fire at the floor a tic later. BD22's
  Reload states were not read here.
- `gunmoves.zs:54-56`, `handtable.zs` and `recoil.zs` numbers: read, not checked against the meshes or the sheets.
- The weapons' DECORATE (`src/actors/Weapons`, `DECORATE.*`) and `zscript/rsr`, `rsvr`, `rsg`, `rsld` are other parts;
  only the lines listed at the top were opened.
