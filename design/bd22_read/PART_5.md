# BD22 VR Reloaded bug read, part 5: zscript/rsld ld_* files, and ldl_patch (2026-11-27)
Commit read: edfaf63. Nothing was run. Nothing was changed.

First thing to know: **ldl_patch does not ship.** `ldl_patch/build.py:11-15` refuses to build ("RETIRED (2026-11-06): the LD
mode lives inside BD22 VR now"), `pk3/` holds no LD patch pk3, and `README.md:29` tells the player not to load the old
`LD_BD22VR_Patch.pk3`. The class the two RSQ mods ask for, `RSLDP_Service`, is ALSO defined inside the shipped mod
(`src/zscript/rsld/handler.zs:1534-1554`). Both copies are written down below.

## Files read
| file | lines | read to the end? |
|---|---|---|
| src/zscript/rsld/ld_g10_fx.zs | 113 | yes |
| src/zscript/rsld/ld_g11_stream.zs | 376 | yes |
| src/zscript/rsld/ld_g1_fx.zs | 157 | yes |
| src/zscript/rsld/ld_g2_choked.zs | 44 | yes |
| src/zscript/rsld/ld_g2_core.zs | 202 | yes |
| src/zscript/rsld/ld_g2_fx.zs | 603 | yes |
| src/zscript/rsld/ld_g2_proj.zs | 117 | yes |
| src/zscript/rsld/ld_g2_spread.zs | 47 | yes |
| src/zscript/rsld/ld_g5_core.zs | 391 | yes |
| src/zscript/rsld/ld_g5_fx.zs | 794 | yes |
| src/zscript/rsld/ld_g7_fx.zs | 580 | yes |
| src/zscript/rsld/ld_g8_fx.zs | 104 | yes |
| src/zscript/rsld/ld_g8_rules.zs | 805 | yes |
| ldl_patch/src/CVARINFO.rsldp | 6 | yes |
| ldl_patch/src/MAPINFO.rsldp | 5 | yes |
| ldl_patch/src/MENUDEF.rsldp | 25 | yes |
| ldl_patch/src/ZSCRIPT.rsldp | 8 | yes |
| ldl_patch/src/zscript/rsldp/data.zs | 48 | yes |
| ldl_patch/src/zscript/rsldp/effects.zs | 204 | yes |
| ldl_patch/src/zscript/rsldp/handler.zs | 554 | yes |
| ldl_patch/src/zscript/rsldp/pickup.zs | 183 | yes |
| ldl_patch/src/zscript/rsldp/tables.zs | 1166 | yes |

`git ls-files src/zscript/rsld` confirms the 13 ld_* files (4333 lines); `git ls-files ldl_patch/src` the 9 patch files (2199 lines).
Read outside the part, to confirm or kill a suspicion only: core.zs (whole), handler.zs 300-409, 440-839, 940-1054,
1525-1570, pickup.zs 225-394, data.zs 1-75, numbers_g11.zs (whole), CVARINFO.rsld, MAPINFO.rsld, muzzle.zs 365-500,
ldl_patch/build.py, ldl_patch/README.md 1-30, and greps of src/actors/Weapons/*.dec and src/DECORATE.rsqdual*.

## RSLDP_Service: what it overrides and what each answers

Two definitions of the same class name exist in the repo.

**The retired patch, `ldl_patch/src/zscript/rsldp/effects.zs:176-204`** (`class RSLDP_Service : Service`):
| override | line | request it answers | answer |
|---|---|---|---|
| `GetString` (play) | effects.zs:188-191 | `"ld_prefix"` (compared with `~==`, so any letter case), stringArg = a weapon class name | `"LD" + slot name` (e.g. `"LDShotgun"`) if the class is one of the 22 rows of `RSLDP_Data.Family` (data.zs:16-27), else `""`. Every other request: `""` |
| `GetStringUI` (ui) | effects.zs:193-196 | the same one request | the same |
| `GetStringData` (data scope) | effects.zs:200-203 | the same one request | the same |

All three call `Prefix()` (effects.zs:178-186). It does NOT override `GetInt`, `GetIntUI`, `GetIntData`, `GetDouble`,
`GetDoubleUI`, `GetDoubleData`, `GetObject*`, `GetName*`, nor the old `Get` / `UiGet`: those return the engine's defaults.
`Prefix()` here does not know an off-hand copy (`RSQ_Off_<Gun>` gives `""`) and does not check that LegenDoom is loaded.

**The shipped mod, `src/zscript/rsld/handler.zs:1534-1554`** (same class name, "the name stays"):
| override | line | request | answer |
|---|---|---|---|
| `GetString` | handler.zs:1548-1549 | `"ld_prefix"` | `Prefix(stringArg)` |
| `GetStringUI` | handler.zs:1550-1551 | `"ld_prefix"` | `Prefix(stringArg)` |
| `GetStringData` | handler.zs:1552-1553 | `"ld_prefix"` | `Prefix(stringArg)` |

Its `Prefix()` (handler.zs:1536-1547) returns `""` when LegenDoom is not loaded (`RSLD.On()`), strips a leading
`RSQ_Off_`, and looks the class up in the shipped `RSLD_Data.Family` (data.zs:16-40, the 2.0.5o list with every BD22 gun).
No `GetInt*` / `GetDouble*` override here either.

The two callers: RSQ Wheel calls `GetStringData("ld_prefix", base)` (`/home/claude/rsq_ubqseries/Wheel/zscript/wheel/wr_compat_legendoom.zs:90-94`);
Gun Bonsai Offhand VR calls `GetStringUI("ld_prefix", cn, 0, 0, null)` (`/home/claude/rsq_ubqseries/GunBonsaiOffhandVR/rsq/ui/legendoom.zs:138-139`).
Both getters are overridden in both copies, so each caller gets an answer from whichever copy is loaded. Not checked: that
QuestZDoom 17.3's own `Service` class has `GetStringData` (the engine's zscript is not in the repo; the shipped mod uses
the same override, so a build that loads proves it).

## tables.zs against src/zscript/rsld/tables.zs
Compared with `diff` after renaming the class prefix. `Repl[]` (56 rows) is the same row for row. `Rolls[]` (1035 rows:
BFG9000 132, Chaingun 115, Chainsaw 90, Fists 96, Pistol 116, PlasmaRifle 127, RocketLauncher 132, Shotgun 113,
SuperShotgun 114) is the same row for row. No row drifted. The only differences: the header comment line, and the patch's
`Implemented[]` list (56 names, patch tables.zs:67-125), which the shipped file does not have (the shipped mod asks
"does an RSLD_Fx_<name> class exist", pickup.zs:265-275). No duplicate rows. Two rows spell a name in LegenDoom's own
other letter case (`Fists|Common|QuarterMaster` tables.zs:479, `Chaingun|Epic|GyroJet` tables.zs:307): harmless, every
lookup is by `~==` or by class name (handler.zs:156, core.zs:93).

## Findings, worst first

## B5.1: Chargeup, Beam, Blazing, Prototype and Overkill on the guns added in 2.0.5o: the gun fires its normal shot as well
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g5_core.zs:22-25, 232-244 (the hold token), 366-375 (Overkill); ld_g11_stream.zs:5-8, 141
  (the stream's hold); ld_g5_fx.zs:484 (Chargeup's hold); data.zs:31-39, 57-67 (the guns added to the nine slots, and
  that a drop hands over a random gun of the slot's group); pickup.zs:265-275 (what is re-rolled).
- What the code does: these five effects stop the gun's own shot with a token (`RSLD_G5BlockMain` / `RSLD_G5BlockOff`)
  that "the first line of the guns' Fire states" reads. Only these weapon files read it: BFG.dec, BrutalRevolver.dec,
  DUalRifle.dec, DualPistol.dec, DualPlasma.dec, Minigun.dec, Pistol.dec, Plasma.dec, Rifle.dec, RocketLauncher.dec,
  SSG.dec, Shotgun.dec, and the off-hand pistol, rifle, plasma, shotgun, SSG and minigun in DECORATE.rsqdual /
  DECORATE.rsqdualmg (grep of `RSLD_G5Block`: 0 hits in every other weapon file).
- Why it is wrong: since 2.0.5o these guns carry the same slots' legendaries and none has the hook: BrutalSMG, MP40
  (pistol slot); AssaultShotgun, Revolver (shotgun slot); Machinegun, MG42, Sniper (chaingun slot); GrenadeLauncher,
  IncendiaryLauncher, Devastator (rocket slot); RailGun (plasma slot); BFG10k, NukeLauncher, Unmaker,
  HellishMissileLauncher (BFG slot); and the off-hand SMG, MP40, Assault Shotgun, Railgun, Revolver. On them:
  a Beam / Blazing / Prototype gun fires its own shot AND the stream every tic (the file's head says the shot is
  "REPLACED"); a Chargeup gun fires normally while the trigger is held, plays the charge sounds, and on release fires
  again with the stored attacks on top; an Overkill launcher fires through its cooldown and with fewer than 5 loaded.
  A legendary drop picks one of these guns at random (data.zs:57-67), so it is common, not rare. Nothing re-rolls the
  effect for a gun that cannot hold its trigger: `Carried()` only asks whether the effect's class exists.
- Checked: every `RSLD_G5Block` / `RSLD_Jammed` line in src (listed above); FxFor is called with the gun in hand
  (handler.zs:1037), no per-gun filter found in pickup.zs 225-394. Not read: each added gun's whole Fire state (other
  readers' part), so "fires normally" rests on the hook being absent, not on a run.
- Sure?: certain that the hook is missing on those guns; likely for what the player sees. One rig run settles it: force
  Chargeup on an MG42 and hold the trigger.
- Fix A: add the same first line and `RSLD_Jammed` state to the Fire (and Hold) states of the 15 guns and 5 off-hand
  copies (2 to 6 lines a gun, about 20 places).
- Fix B: in pickup.zs, re-roll these five effects when the drop's gun is not one with the hook (one small list and one
  test in `Carried`, about 10 lines, 1 file).
- Or intended: only if the owner wants trigger-hold legendaries to stack on top of those guns' normal fire.
- Already known?: no (the 11-24 list's Q6 asked for the guns to get a slot; this is what came with it).

## B5.2: Chargeup on the BFG or the super shotgun releases more shots than the ammo pays for
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g5_fx.zs:499-501, 516-519 (the stored count is capped by rounds loaded), 571-577 (the bill);
  ld_g5_core.zs:159-166 (`Loaded`); core.zs:265-275 (`Take` never goes below 0); src/actors/Weapons/BFG.dec:5-6
  (50 cells a shot, no magazine); SSG.dec:7-8 (two shells a blast).
- What the code does: while the trigger is held it stores up to `min(10, rounds loaded)` attacks. On release the gun
  fires once and every other stored attack goes out with it; afterwards it takes `stored x (what the gun's own shot
  took)` from the pool, as far as the pool goes.
- Why it is wrong: "rounds loaded" counts ammo units, not shots. A BFG with 100 cells stores 10 attacks, fires 10 BFG
  balls, and can only be billed the 50 cells left: 10 balls for 100 cells (the right price is 500). A super shotgun
  with 2 shells stores 2, fires two full blasts and can only be billed 0: the second blast is free. The file's own
  rule is "stored attacks are counted against what is LOADED" and LegenDoom's "each taking its round".
- Checked: `Take` clamps at the pool (core.zs:272); `per` is the gun's own shot's cost (ld_g5_fx.zs:574); pistols, the
  pump, the minigun and the rocket launcher cost 1 a shot, so they are right.
- Sure?: likely (arithmetic from the code; not run). Settle: rig, Chargeup BFG with 100 cells, count the balls.
- Fix A: cap the stored count by `loaded / cost of one shot` (cost = `max(1, w.AmmoUse1)` for a gun without a
  magazine, 2 for the SSG's two-barrel blast or the last pull's `magTaken`): about 6 lines in ld_g5_fx.zs.
- Or intended: no; it reads as an oversight.
- Already known?: no.

## B5.3: Choked and Slug do nothing, and added pellets have no spread, on shotguns and bullet guns outside the spread table
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g2_spread.zs:22-30 (the only nine sequences: Shot_Gun, SSG, BrutalPistol, BrutalRevolver,
  MiniGun, Rifle); ld_g2_core.zs:32-46 (`FindSeq`), 60-76 (`Volley` returns 0, 0, 0 for an unknown gun), 80-96, 99-110,
  113-118 (`Fresh`); ld_g2_fx.zs:162-165 (Choked: "no pattern ... left as fired"), 198-199 (Slug: pump and SSG only);
  data.zs:20-23, 33-35 (the guns of those slots).
- What the code does: the shot-shape effects look the gun up in a table generated from six weapon files. A gun not in
  it gets sequence "none": `PatternPellets` is 0 and the volley's spread is 0.
- Why it is wrong: these guns carry the same legendaries and are not in the table: AssaultShotgun and Revolver
  (shotgun slot); BrutalSMG, MP40, DualPistols (pistol slot); Machinegun, MG42, Sniper, DualRifles (chaingun slot;
  DualRifles and DualPistols derive from BrutalWeapon, not from Rifle / BrutalPistol: DUalRifle.dec:1,
  DualPistol.dec:1). On them: a **Choked** legendary changes nothing; a **Slug** legendary changes nothing (and is not
  re-rolled: `Carried("Slug")` only looks at the cvar); **Renegade**, **TwinShot** and **ShortRange** add their pellets
  with zero spread, so every added pellet lands on the exact aim point (an Assault Shotgun's extra 50% is a slug in the
  middle of the pattern; TripleThreat's two side copies are two single points).
- Checked: `w is c` does match the Purist and `RSQ_Off_` copies of the six table guns (they derive from them:
  Shotgun.dec:1026, DECORATE.rsqdual:4250 and the like), so those are right. The table's numbers still match the
  weapons (Shotgun.dec:483-486, SSG.dec:252-255, 332, 342, Pistol.dec:345, Rifle.dec:348, 395, Minigun.dec:308,
  BrutalRevolver.dec:140): only its line numbers in comments are 4 behind.
- Sure?: certain from the code for "none" guns; what the Assault Shotgun's pellets look like on a wall is not run.
- Fix A: add the missing guns to `SEQS` in ldl_patch/tools/g2_spread.py and regenerate (about 9 rows, 1 tool, 1
  generated file); add their pellet counts to g2_choked.py for Choked.
- Fix B: re-roll Choked and Slug when the drop's gun has no sequence (pickup.zs, about 8 lines), and in `Fresh` fall
  back to the original pellet's own offset from the aim when the volley is unknown (ld_g2_core.zs, 3 lines).
- Or intended: no.
- Already known?: partly. LD2 covers Slug with the cvar off ("Re-roll it", changed in 2.0.5n); Slug on a gun that is
  not the pump or SSG is new.

## B5.4: A Recursive gun's replayed shots are taken for a fresh pull of whatever gun is in that hand now
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g5_fx.zs:702-736 (the replay, 70 and 140 tics after the shot; the hitscans at 715-719);
  handler.zs:462-467 (`PullOf` is called before the `LAF_ABSPOSITION` test), 312-332 (`NewPull` calls `OnPull`),
  738-741 (damage with no tag goes to this tic's pull).
- What the code does: the replay calls `mo.LineAttack(... LAF_ABSPOSITION ...)`. The handler's WorldHitscanPreFired
  first makes a pull for the weapon NOW in that hand, calls that gun's effect's `OnPull`, and only then returns because
  of `LAF_ABSPOSITION`. The replay's damage then finds that pull and runs that effect's `ModifyDamage`.
- Why it is wrong: fire a Recursive shotgun, switch that hand to another legendary gun inside 4 seconds, and the
  replays act on the new gun's legendary: Burst starts a burst (the new gun fires two shots by itself), Doubletap's
  free / paid turn flips, WindUp and Focusing count a shot, SixShooter / Advanced roll a damage factor that then
  multiplies all the replayed pellets, Stealth takes back alerts. With the Recursive gun still in hand it is harmless
  (Recursive has no `OnPull`; `replaying` stops its `OnPellet`).
- Checked: `replaying` is only read by Recursive itself (ld_g5_fx.zs:763, 777); the handler has no "replay" flag;
  replayed projectiles are kept out of Recursive by `mine` (777) but also reach the held gun's `OnMissile` the same way
  (handler.zs:696-701).
- Sure?: likely (read, not run). Settle: rig, Recursive on the shotgun, switch to a Burst pistol, watch the log at +70.
- Fix A: in `RSLD_G5Replay.Fire` set the handler's `refiring` flag around the LineAttacks and tag each replayed
  projectile to the Recursive pull's own shot (keep the `RSLD_Shot` in the replay): about 8 lines, 2 files.
- Or intended: no.
- Already known?: no. Small extra in the same code: the replay's sound comes from the slot (`FireSound`,
  ld_g5_core.zs:327-337), so a Recursive SMG replays with "Pistol/Fire", an MG42 with "Chaingun/Fire", a Railgun
  with "Plasma/Fire".

## B5.5: Fist and chainsaw legendaries on the Axe, Dragonslayer, Flamethrower and Flame Cannon mostly do nothing
- Kind: wrong behaviour
- Where: src/zscript/rsld/data.zs:31-32 (2.0.5o: BrutalAxe, DSweap in the Fists slot; Flamethrower2, FlameCannon in the
  Chainsaw slot); ld_g7_fx.zs:28-31 (`Fist` = a melee pull of slot 0, `Saw` = a melee pull of slot 1, `StrikeHit` = the
  inflictor is a punch strike), and every effect below them; ld_g5_fx.zs:295, 479 (slot 0 always takes the fist path).
- What the code does: ColdBlooded, Lunging, Facekicking, OnePunch, NorthernStar and Extended's fist half change damage
  only when the inflictor is a fist strike; Lacerating, Extended, RazorEdge, Imaginary only on a melee pull of slot 1.
  Burst and Chargeup in slot 0 only run their "fists" code (store punches, add strikes).
- Why it is wrong: the axe hits with `A_Saw` and `AxeAttack` missiles (Axe.dec:310-312), the flamethrower with flame
  projectiles: neither is a fist strike or a slot-1 melee pull. So a "Lunging Axe" or "Lacerating Flamethrower" is a
  legendary that changes nothing, while OnePunch and Chargeup still play "Plasma/Charge" every time the axe's trigger
  is held (ld_g7_fx.zs:353, ld_g5_fx.zs:449) and Chargeup stores punches that only a real fist punch ever spends.
  Blaster does work: plasma balls come out of the axe hand while its trigger is held (ld_g7_fx.zs:406-432).
- Checked: `IsStrike` (handler.zs:578-593) is true only for MeleeStrike* / KickAttack classes and for things
  rsq/fists.zs recorded. rsvr/melee.zs:1497 records VR bar contact with speed 0; whether a VR axe swing goes through
  that record (and so counts as a strike) I did not read: that file is another reader's.
- Sure?: unsure for the VR axe (one read of rsvr/melee.zs around 1497 settles it); likely for the flamethrowers and
  the Dragonslayer.
- Fix A: re-roll the G7 effects when the drop's gun is not Melee_Attacks / Chain_Saw (pickup.zs, one list, about 8
  lines).
- Fix B: make the G7 tests accept the axe's and Dragonslayer's own hits (ld_g7_fx.zs `StrikeHit` and `Fist`, about 10
  lines), and leave the flamethrowers to Fix A.
- Or intended: only if "any effect of the slot may land on any gun of the slot, duds included" is accepted.
- Already known?: no.

## B5.6: A trigger hold can outlive a map change (the token's clock is the old map's)
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g5_core.zs:229-244 (`Block` stamps `refreshed = level.maptime`), 342-351
  (`RSLD_G5Token.DoEffect`: clears only when `level.maptime - refreshed > 1`); ld_g7_fx.zs:76, 148-154 (`RSLD_G7NoTurn`
  is the same class).
- What the code does: the token is UNCLEARABLE and stays in the inventory with Amount 1. On the next map
  `level.maptime` starts at 0, so `0 - 20000 > 1` is false: the token stays on until something renews it or the new
  map's clock passes the old map's.
- Why it is wrong: the comment says "a level change never leaves a trigger held". If the hand that held a Chargeup /
  Beam / Blazing / Prototype / cooling Overkill gun at the exit does not hold such a gun in the first tics of the next
  map (inventory reset by the map, a hub, a different off-hand gun), that hand's trigger is dead on every hooked gun
  for as long as the last map was played. While the same gun stays in the hand `WhileHeld` renews the stamp at tic 1
  and nothing shows.
- Checked: nothing in handler.zs 940-1045 clears the tokens at map start; the handler's own `RSLD_JamMain` / `JamOff`
  are set and taken every tic (handler.zs:1010-1018) and do not have this.
- Sure?: unsure how often a player meets it (needs the gun to leave that hand across the change); certain that the
  test is one-sided. Settle: rig, exit a map with a Chargeup gun in hand on a map list that resets inventory.
- Fix A: in `DoEffect` also clear when `level.maptime < refreshed` (1 line, ld_g5_core.zs:349).
- Or intended: no.
- Already known?: no.

## B5.7: Netplay: one shared "last pickup" memory lets a shared pickup run its rules several times
- Kind: netplay
- Where: src/zscript/rsld/ld_g8_rules.zs:165-176 (`st.lastItem / lastTic / lastPn / lastRet`, one set for the whole
  level), 348 and 682-701 (`ShareItem` picks the item up for the other players from inside the first player's rule);
  handler.zs:779-786 (`OnPickup` is called once for every passive the picker owns).
- What the code does: the first `OnPickup` call of a pickup runs the rules and remembers the item; the later calls for
  the same item return the remembered answer. A Quartermaster share inside the rule makes the other player pick up a
  copy, which overwrites the memory with the copy.
- Why it is wrong: back in the first player's loop the item no longer matches, so each further owned passive runs the
  whole ammo rule again on the same item: Scrounger / Hoarder add again on the already raised amount, ActionHero and
  Collector give again, and the share goes out again. Single player never shares to players, so it does not happen
  there (marines have no RSLD_Amp).
- Checked: `st.sharing` stops the receiver from re-sharing but not the picker from re-running. Also in netplay,
  `Watch` (ld_g8_rules.zs:731-750) counts a vanished berserk / map / powerup item for every player standing within
  about 56 units of it, not only the one who took it.
- Sure?: likely (read, not run; needs two players and two owned passives).
- Fix A: keep the memory per player (`lastItem[pn]`...) and restore it after `ShareItem` (about 6 lines).
- Or intended: no.
- Already known?: no.

## B5.8: A Stealth gun takes back every alert you have made, not only its own shot's
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g10_fx.zs:26-29, 74-84.
- What the code does: at each pull and again the tic after, `Quiet` clears `SoundTarget` in every sector of the map
  where it is this player, then alerts only within 64 units.
- Why it is wrong: sectors keep `SoundTarget` from earlier shots and from the other hand's gun fired the same tic.
  With a Stealth gun in one hand, a loud gun in the other stops waking monsters that have not looked yet (ambush
  monsters stay deaf), and one Stealth shot wipes the alert left by any earlier loud gun.
- Checked: there is no record of which sectors this pull alerted; the loop is over `level.Sectors` with only the
  `== mo` test.
- Sure?: certain from the code; how much a player notices is small.
- Fix A: only clear when no other pull of this player (either hand, a non-Stealth effect or none) fired this tic or
  the tic before (handler's `lastPullTic`), about 4 lines; earlier alerts are then still lost.
- Or intended: yes if "Stealth quiets you" is meant broadly; then say so in the comment.
- Already known?: no.

## B5.9: Burst on the fists: the two added punches ignore the swing speed and may be credited to the other hand
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g5_fx.zs:266-267 (`strikeCls / strikeAng / strikePit / strikeSpd` per PLAYER, not per
  hand), 336-368; ld_g7_fx.zs:88-99 (`Swing` needs the strike to be recorded); handler.zs:606-612 (`StrikeHand`: an
  unrecorded strike goes to the nearest controller).
- What the code does: punches 2 and 3 are spawned at the fist but never `RSQ_Fists.Record`ed.
- Why it is wrong: punch 1 gets x1 to x2 for arm speed, punches 2 and 3 never do; with both hands close together the
  added punches can be read as the other hand's (a gun in that hand: the strike is dropped as "not a LegenDoom attack",
  handler.zs:678). Two fists punching inside 4 tics share one stored direction.
- Checked: `mine` stops the added strikes from starting a burst of their own (ld_g5_fx.zs:338): that part is right.
- Sure?: likely; small.
- Fix A: `RSQ_Fists.Record(a, c.hand, <the first punch's speed>)` after the spawn and index the four arrays by
  `pn * 2 + hand` (about 6 lines).
- Or intended: no.
- Already known?: no.

## B5.10: A hitch when a Burst / Quickdraw / Doubletap / Chargeup shot is stepped out in one tic
- Kind: performance
- Where: src/zscript/rsld/ld_g5_core.zs:251-289 (`ShotCount`: a blockmap search plus a walk of up to three sectors'
  whole thing lists), 312-324 (`StepToShot` calls it before each of up to 64 steps), 118-136 (`InStop`: 36
  `FindStateByString` calls each time); ld_g5_fx.zs:320, 414, 678.
- What the code does: to find "the shot is out" it recounts, after every weapon state, every actor in the player's
  sector, the hand's sector and the sector 64 ahead.
- Why it is wrong: in a big open sector full of Brutal Doom's gore, casings and decorations that is hundreds of
  actors times up to 65 times in one tic, on every such shot, worst when no shot comes (dry gun: all 48 or 64 steps
  run). On a Quest that is a visible frame drop tied to the trigger. Smaller ones of the same kind: Explosive spawns
  one damage actor and one LegenDoom effect actor per pellet (28 for a Tactical SSG blast, ld_g2_fx.zs:305-324);
  Stealth scans every sector twice per shot (ld_g10_fx.zs:79-83); every `s.Log(String.Format(...))` builds its string
  even with the debug log off (for example once per pellet in Sniper, ld_g2_fx.zs:122).
- Checked: `Cadence` only calls `InStop` inside a trigger cycle (ld_g5_core.zs:188); `Watch` uses a 128-unit blockmap
  search once a tic (ld_g8_rules.zs:752): both fine.
- Sure?: unsure of the size (not measured). Settle: rig with a profiler line or a headset run in a large outdoor map.
- Fix A: count the fresh projectiles once before the loop and inside it only read `cur[k].pellets` plus a check of
  the newest thinker; or stop the loop at the first state with tics > 0 after a shot action (about 15 lines).
- Fix B: guard the log lines with `if (RSLD.Debug())` at the call sites that sit in per-pellet paths.
- Or intended: no.
- Already known?: no.

## B5.11: Heavy on an off-hand gun works out its extra knockback from the main hand's gun
- Kind: wrong behaviour
- Where: src/zscript/rsld/ld_g2_fx.zs:272-273 (`s.mo.player.ReadyWeapon.Kickback`).
- What the code does: "the thrust the engine already gave" is computed from the main-hand weapon's Kickback even when
  the pull is the off hand's (`s.weapon` is the gun that fired).
- Why it is wrong: wrong hand's data; the extra push is a little too big or too small when the two guns' Kickback
  differ.
- Checked: `s.weapon` is set for every pull (handler.zs:322).
- Sure?: certain; barely visible.
- Fix A: use `s.weapon ? s.weapon.Kickback : gameinfo.defKickback` (1 line).
- Or intended: no.
- Already known?: no.

## B5.12: The retired patch pk3 and the current pack cannot be loaded together (same class twice)
- Kind: dead code
- Where: ldl_patch/src/zscript/rsldp/effects.zs:176 and src/zscript/rsld/handler.zs:1534 (both `class RSLDP_Service`);
  ldl_patch/build.py:11-15; ldl_patch/README.md:1-3, 22-27; README.md:29; src/README.txt:146.
- What the code does: both define `RSLDP_Service`. An old `LD_BD22VR_Patch.pk3` left in a load order next to a 2.0.4+
  BD22 VR stops the game at start with a "defined twice" script error.
- Why it is wrong: it is not, as long as nobody loads the old pk3: the build refuses, pk3/ has none, three READMEs say
  so. It is listed because the task described the patch as shipping, and because the two services differ (the old
  one: no `RSQ_Off_` strip, no "LegenDoom loaded" test, the 22-gun family).
- Checked: pk3/ listing; build.py; both class bodies.
- Sure?: certain.
- Fix A: none needed in code. If the folder is only kept for its tools and evidence, move `ldl_patch/src` to
  `ldl_patch/old_src` or delete it so nobody builds it by habit (0 lines of code).
- Or intended: yes: retired on 2026-11-06, kept for reference.
- Already known?: not in the 11-24 list; documented in the READMEs.

## B5.13: Faults inside the retired patch (they reach no player while it stays retired)
- Kind: dead code
- Where and what, each certain from the code unless said:
  - ldl_patch/src/zscript/rsldp/handler.zs:219-232, 262-278: shots are counted as "ammo units gone, at most 30", so on
    the BFG (50 cells a shot) Annoying ("doesn't use ammo") still costs 20 cells, Unlikely gives back about 10 of 50,
    Efficient 15 of 50.
  - handler.zs:198-205, 337-374 and effects.zs:146-163: only the main hand's gun decides the effect; an off-hand gun's
    hits get the main hand's legendary (the shipped mod's LD1, fixed there in 2.0.5n).
  - effects.zs:116: Lucky rolls per damage event (per pellet), LegenDoom per shot.
  - handler.zs:387: sound "items/clippickup" is used nowhere else in the repo and is not a GZDoom name I know; if
    Brutal Doom does not define it Thieving is silent (not checkable: brutal22test6.pk3 is not here).
  - MENUDEF.rsldp:22: "Debug Log" is On/Off on an int cvar (the shipped menu's LD10, "left as is").
  - MENUDEF.rsldp:24: submenu "LegenDoom" and MENUDEF.rsldp:16 `pukename LDMenuToggle` name things in LegenDoom's
    own pk3: not checkable here.
  - CVARINFO.rsldp: all four cvars (rsldp_reroll, rsldp_screen_name, rsldp_bossfight_only, rsldp_debug) are defined
    once, read (effects.zs:49, handler.zs:539, 480, 32) and have a menu row (MENUDEF.rsldp:19-22). No fault.
  - MENUDEF.rsldp:7 `AddOptionMenu "BrutalMenu"`: the menu exists when BD22 VR is loaded (src/MENUDEF.rsq:10 extends
    it too); without Brutal Doom it would be a start-up error, which is not a supported load.
- Why it is wrong: see each line.
- Checked: the whole of the five patch .zs files and four lumps.
- Sure?: certain for the first three and the cvar row; the sound and LegenDoom names are not checkable.
- Fix A: none while retired. If the patch is ever revived, port the shipped mod's per-hand pull logic instead of
  patching these.
- Or intended: retired code.
- Already known?: the off-hand point is LD1 (owner: "Fix it", changed in 2.0.5n in the shipped mod); the Debug row is
  LD10 ("Left as is: invisible").

### Seen again in my files, already in BUGS_FROM_CODE_READ_2026-11-24.md (already known, not re-counted)
- LD9: reloading one gun pauses the other hand's speed-up (`HandBusy` asks about the player, not the hand,
  ld_g5_core.zs:97-104; the same test also ends a stream and blocks a Chargeup start, ld_g11_stream.zs:151, 172,
  ld_g5_fx.zs:491). Owner: "Rig check list: confirm on the rig".
- LD2: Slug with "Slug Legendary: Primary Fire Only" off does nothing (ld_g2_fx.zs:196-197). Owner: "Re-roll it",
  changed in 2.0.5n; a Slug gun owned before the switch is turned off still does nothing, and the comment at
  ld_g2_fx.zs:188 still says "off = LD's Slug does nothing".
- LD1: Convincing sets damage to 0 for damage with no pull (ld_g1_fx.zs:62). Owner: "Fix it", changed in 2.0.5n
  (handler.zs:731-744 now returns no shot for those cases).
- LD11: DualWield (ld_g5_fx.zs:786-794) never rolls from 2.0.5n; the class is left and its comment still describes the
  gate giving Dual Pistols. Owner: "dualweild seems like a pointless legendary in a vr game".

## Things that looked wrong and are not (so the next reader does not chase them)
- Chargeup's `OnPellet` calls `s.FirePellet` without the G2 `Hold` / `Restore` (ld_g5_fx.zs:546-553). The comment at
  ld_g2_core.zs:120-121 says FirePellet reuses the pellet object `OnPellet` holds. It no longer does: the handler uses
  its own `pelX` (handler.zs:57, 520-530). Harmless; the comment and the Hold / Restore calls are leftovers.
- Chargeup's cloned projectiles (ld_g5_fx.zs:555-569) do not clone again: each clone is tagged, and
  WorldThingSpawned skips a tagged missile (handler.zs:672).
- Scrounger / Hoarder and "an owned ammo's HandlePickup ends the chain before RSLD_Amp": the handler moves RSLD_Amp to
  the head of the inventory every tic (handler.zs:961-965).
- `Fists|Common|QuarterMaster` and `Chaingun|Epic|GyroJet` in the roll table against `RSLD_Fx_Quartermaster` /
  `RSLD_Fx_Gyrojet`: every lookup ignores letter case. Whittling and Gravitic have classes in fx_g0.zs:209, 220.
  Favoured has none on purpose (ld_g1_fx.zs:157).
- Focusing keeps its spread factor in `s.d2` and the handler writes `s.d2` after a reshaped pellet (handler.zs:493):
  the chaingun-slot guns fire one pellet a pull and a new pull every tic, so the factor is always fresh. It would go
  wrong on a gun that fires two pellets in one pull; no Focusing gun does today.
- Suspenseful ORs 0x10000 into `s.i2`, which G2 uses for the sequence cache: Suspenseful never asks for a sequence.
- `Marksman` and the others reading `Base|...` numbers divide by them: a missing number gives a float division by
  zero (no abort in the VM), and the generated rows are there (numbers_g11.zs checked row by row for the stream keys).
- NorthernStar's closing blow of 20000 (ld_g7_fx.zs:467-490): it is the engine's own radius-thrust rule with
  LegenDoom's number, monsters only.
- Blazing's rocket fuel is not reset on a new press (ld_g11_stream.zs:325-336): LegenDoom's fuel is an inventory count
  that carries over too.
- A Beam / Chargeup gun with nothing loaded does nothing on the trigger (no click, no automatic reload): the hold
  sends Fire to `RSLD_Jammed`, "the hand works as in Ready". By design; reload by hand works.
- The stream's damage actor `LD_PlasmaBeamPuff` starts with "LD", which the handler normally skips: it is tagged to the
  pull first (ld_g11_stream.zs:295-296), so the damage ratio does apply.
- `RSLD_G2.Muzzle` for the fists (Blaster): no muzzle table, so in VR the ball leaves from the controller
  (muzzle.zs:457-460), flat screen from the body's middle (ld_g2_core.zs:191-192). As the comment says.
- Plasmatic / Gyrojet call `RSQ_Recoil.Kick` once per pellet (ld_g2_proj.zs:56-59): recoil.zs:260 allows one kick a
  tic per hand.
- ld_g2_spread.zs and ld_g2_choked.zs are generated; their numbers match the weapon files today (see B5.3 "Checked").

## Not read or not checkable
- Everything in my part was read to its last line.
- LegenDoom 3.0's pk3 is not on this machine. Every LegenDoom class named in a string (LDPerfectJammed,
  LDOnePunchCooldownGiver, LDNorthernStarDamager, LDBlazingRocket2, LD_FinalBeamPuff, LDShieldingShield, the
  LD<Slot>Upgrade* items, the givers in ld_g8_rules.zs and so on), its state labels used by `RSLD.LDVisual`
  ("Pahticools", "DeathAnimation") and the menu / script names in MENUDEF.rsldp were NOT checked. A wrong name is
  never a crash here (every one is looked up at run time and tested for null) but the effect would silently do less.
  ldl_patch/evidence/ldmode/*.log are the owner's rig proofs for them; I did not read those logs.
- Brutal Doom (brutal22test6.pk3) is not here. Not checked: that `Rocket2`, `Tracer`, `Alerter`, `Marine_Rifle`,
  `HealthPlus`, `ArmorShard`, `Stimpack2`, `Medikit2`, `HeavyArmor`, `LightArmor`, `SoulSphereHealth`, `BerserkPack`,
  `MeleeStrikeNormal`, `MeleeStrike1Berserked` exist and are the kind the code casts them to (for example
  `Health(GetDefaultByType(HealthPlus))` in ld_g8_rules.zs:417: if HealthPlus were a CustomInventory, NanoCircuit,
  Collector and Spiritual would give no health); what `GetMissileDamage` returns for Rocket2 / Plasma_Ball /
  SuperBFGBall (Marksman, Decaying and the stream ratios rest on it); the sounds "Explosion", "Explode2" and
  "Weapons/GrenadeFire", which only the rsld ZScript names (every other sound these files play is also used by the
  repo's own weapon DECORATE).
- Whether a trigger-hold legendary also stops the gun's ALT fire is decided in g6_ammo.zs and the weapons' AltFire
  states: not my part.
- QuestZDoom 17.3's engine zscript is not in the repo: `Service.GetStringData`, `mo.OverrideAttackPosDir`,
  `AttackDir`, `OffhandDir`, `BT_OFFHANDATTACK`, `PSP_OFFHANDWEAPON` were taken as given (the shipped mod uses them
  throughout).
