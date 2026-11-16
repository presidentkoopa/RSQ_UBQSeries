# HANDOFF (latest first)

## 2026-11-16 06:00: 0.8 (owner 03:30 "all seven", 03:33 five mechanics, 03:45 standalone first, 03:51 version 0.8)
Rig only, not headset-confirmed. Evidence: rigtest_2026-11-16/ (RIG_LOGS.md, SUITE_REPORT.md, frames).
Fixes (review /home/claude/suggestions/WoS_Reloaded_suggestions.md):
- 1 Chaingun spots: RSQWS_ChaingunSpot (RandomSpawner replaces Chaingun) gives the Rotary Cannon or the Maschine Rifle,
  half each, map pickups and Chaingunner drops alike (rig, Rotary Cannon / Maschine Rifle: WoS alone 12/8 placed and
  11/9 dropped of 20 each; with the Series 5/5 placed, 4/6 dropped of 10 each).
  The Rotary Cannon no longer replaces Chaingun itself. LegenDoom replaces Chaingun with its own pickup: with LegenDoom
  loaded nothing of ours spawns there (LegenDoom's business; noted only).
- 2 full cost: Nova Ball 5, Nova 5, Hyper Nova 40 cells, else reload (reserve) or dry click. TakeUpTo is unused now.
  Found on the way: DryWait's `Goto Ready` resolved in the abstract RSQWS_Gun (the load's "Attempt to get invalid state
  Ready from actor RSQWS_Gun"): after any dry click the gun hung out of its states. Now A_Jump by name; the warning is gone.
- 3 Knuckles: trigger punches (basics' numbers 2 x 1-10, berserk x10, 64 units, WoS's FistPuff) when not in VR, or when
  Punches is off and RSQ Melee is not loaded; otherwise free as before.
- 4 RSQTRFIT.wos: tools/make_rsqtrfit.py runs TacticalRig/tools/measure_pickups.py --held on the set's pk3 (all guns
  but the Knuckles, plus the dual copies). Mirror frames show the guns on the body; the old pack's holsters are empty.
- 5 rsq_hud_noammo declared and read by the set's HUD (+ its own menu row). Gun Cards (GunCards/zscript/rsqgc/card.zs,
  source only, its pk3 not rebuilt here): any Fist is an empty hand (status card for the Knuckles), and the basics'
  RSQB_GN_Ammo counts as grenades. Not done: the off-hand model card for the basics' grenade (needs a bridge MODELDEF
  like bridge_grenade, bigger than "small and safe") and the fuse count for it.
- 6 charge: zscript/wos/charge.zs RSQWS_ChargeGlow: the round's own sprite + a point light at RSQ_Muzzle.Where, growing,
  a self-made buzz loop (tools/make_chargehum.py) with rising pitch / volume, RSQB_GN_Buzzer pulses (Rumble Strength,
  Rumble Backup by name). Grows only, fades after the shot; dimmer and slower with rsqa_photosafe.
- 7 flash rows (zscript/rsq/flash.zs, patched in build.py): RailGun (Nova Rifle, its rounds' PLASMABALL blue rather than
  the review's green), NukeLauncher (Titan orange), RSQWS_1911 (own row: bigger warmer flash, RS Ballistics' pistol_mag
  tail already in the pack). The 1911's fire sound was already its own.
Mechanics (owner 03:33):
- Butt strike: BD22 VR's own (rsvr/melee.zs RIFLEBUTT / SGBUTT / SSGBUTT / MP40BUTT rows) for the Maschine Rifle, Riot
  Gun, Coach Gun, MP40; the blow is RSQWS_ButtStrike (WoS kick 2 x 5-15, a lower WoS punch thud), 18-tic rest after a
  strike. Needs both hands (the engine's steadying: off GRIP within 50 cm). Menu: Butt Strike (rsqws_butt, on).
- Hold to charge (Nova Ball 13 tics, Hyper Nova 34): let go early = no shot, nothing spent, a fizzle (picked as the
  simplest); a beep and one hard pulse when full; it waits full until let go. Dual off-hand Nova fires when full.
- Chain Saw rev burst (alt): 35 tics revved (chain runs by itself, cuts x2: RSQWS_SawCutRev), then 70 tics before the
  next (alt coughs). melee.zs reads RSQWS_Motorsaw.Revving.
- Coach Gun point blank: RSQWS_PointBlank (event handler): both barrels, a kill within 72 units of the monster's edge,
  4-tic window -> the monster's own XDeath (Death.Extreme). No damage change.
- Rotary Cannon: off hand within 9 units of the front 55% of the hand-to-muzzle line, off trigger held (20 tics linger)
  or a swipe >= 2.5 units/tic (35 tics) -> PreSpin (spin frames, sound, off-hand rumble); the trigger fires that tic.
  A fast reach to the barrels counts as a swipe (only spins; harmless).
Version: build.py NAME, VERSION = 'WoS_Reloaded', '0.8' (WoS_Reloaded_0.8.pk3), menu title, ZSCRIPT.zs header. No pk3
committed. README.md (player-first) in the pack.
Build note: build.py's inputs (/home/claude/src/saturn, wosvox, rs_combatfx, ...) are not on this machine, so the set
folder's pack files were edited directly and build.py was given the same changes (patches, MELEE_0333, handlers, version)
so a rebuild keeps them; src/ holds the hand-written files (charge.zs, SNDINFO.rsqws, RSQTRFIT.wos, README.md, sound).
Suite: 14 of 14 on tree 87f1f959 (out/suite.json). The rig's doom2.wad is now Doom II; the Saturn V lock-on and both
door checks depend on Freedoom 2 MAP01's layout and fail on Doom II with the old pack too, so those three ran on
Freedoom 2 (MT_GAMEDATA to a dir with doom2.wad -> freedoom2.wad). tools/suite.py: the charged alts are held (althold).
Series load: GunBonsai + WoS + 20 RSQ pk3s + this Gun Cards: 0 script errors. RSQ_Miniboss needs LegenDoom and
Champions to compile (its own dependency, not ours). RSQ_GunBonsaiVR needs Gun Bonsai.
Open: headset test of everything above; the Gun Cards pk3 rebuild; basics' grenade model card in Gun Cards.

## 2026-11-12 18:05 — building
Done: SPEC.md (owner-agreed), CLAUDE.md (rules), ARCH.md; tools/seat_1911.py (+json): the BW 1911 seated in the FBX
pistol hand; tools/dec2zs.py + gen_og.sh: WoS's 108 non-weapon actors -> src/zscript/wos/og_actors.gen.zs (compiles;
only errors left = the weapons it references); tools/compile_check.py (pack + load once on the rig, prints errors).

Facts the next step needs:
- Sources: WoS unpacked at /home/claude/src/saturn (ACTORS/*.txt, SOUNDS, SPRITES); Voxels of Saturn at
  /home/claude/src/wosvox; BD22 VR at /home/claude/presidentkoopa/rsq_bd_vr_reloaded/src; the earlier (DECORATE) port's
  tools at /home/claude/work/port (zs_port.py copies BD22 VR's systems with RSQ_Alias; mdl.py copies MODELDEF blocks;
  build.py has every protocol as DECORATE: protocol(), pump_protocol(), break_protocol(), slug_protocol(), m203_protocol()).
- Rig: /home/claude/presidentkoopa/rsq_meshturbator/rig (prebuilt QZD 17.3), IWAD = Freedoom 2 0.13.0 symlinked as
  /home/claude/rig/packs/doom2.wad. Rig-only probe + robot hands: /home/claude/work/rigtest (probe pk3 source,
  rel.py magazine/pump, m203.py, feat.py). Known engine quirk: the off trigger going down moves OffhandPos ~6 map
  units (pump grab test compensates).
- Weapon protocols: Reload label = the entry (RSR_Start; flick also enters Reload). BD frames: pistol fire PIST A(shot)
  B C D, ready PIST E. The 1911 shows PIST frames too (keyed to bw_1911.md3) so BrutalPistol's hand, recoil and muzzle
  rows apply (seat puts its muzzle within 0.2 cm of BrutalPistol's); its RSR row (19) comes from its card, moved by
  the seat; table axes map to hooks by (L, U, -F).
- WoS ammo convention: Ammo1 = reserve, Ammo2 = loaded. Magazine fill: cap = Ammo2.MaxAmount, minus 1 when empty for
  chambered guns (WoS's 10/11, 15/16 with ExtendedMags).

Next: src/zscript/wos/gun.zs (RSQWS_Gun base: RSR / RSP / RSB / RSM protocols, kick, semi, dual), then the 12 guns,
then build.py (systems + MODELDEF + voxels + sounds + menu), then the rig suite.

## Paused 2026-11-12 (owner: "Pause all work for now. 5hr limit.")
Done since 18:05:
- tools/build.py: assembles out/tree (src + WoS assets + Voxels of Saturn + BD22 VR model blocks / scripts via tools/lib/mdl.py,
  zs_port.py, stubs.zs, CVARINFO.base, MENUDEF.base, MODELDEF.rsqm203). `--pk3` refuses unless out/suite.json says the suite
  passed on this exact tree (sha256 in out/tree.sha256). Weapon Effects = rsqws_fx (OG / Enhanced) gates ballistics, true bullets, flash.
- tools/row_1911.py -> row_1911.json: reload row 19 moved with the gun (method checked exactly on BD row 2). The card's well Axis leaned
  11 deg sideways; re-measured from the mesh's own reload frames 7-9 (18.7 deg down the grip). Owner told.
- gen_og.sh: zombies dropped (no monsters).
- Compile check (out/tree): BD22 VR systems compile; my return-null errors fixed (ResolveState(null)); remaining errors are only the
  guns not written yet (og_actors references RSQWS_MP40 / RSQWS_Knuckles).
Next, in order:
1. Motorsaw / Knuckles: owner answer: "this will load with RSQ series, read RSQ Melee" -> read RSQ Melee (RSQ_UBQSeries) before writing them.
2. Write MP40 (4 tics/shot, open bolt: Chambered false, racks), MachineRifle (+ RSM underbarrel: old port build.py m203_protocol),
   Riotgun (pump: pump_protocol / slug_protocol in /home/claude/work/port/build.py; set rsr_pump_guns row 1), Coachgun (break: rsb row 1;
   one barrel / alt both; alt with one shell fires the one), Minigun (spin-up, RotaryPlasma alt, row 17 ammo box), SaturnV (alt = rlock.zs:
   port it with rsa_rl_lock on, Rocket2 -> RSQWS_SaturnRocket, RSA_Handler.AltDown stub false, RSVR_AxeLock class from rsvr/melee.zs),
   NovaRifle (charge NovaBall, scope), TITAN (Nova 5 / HyperNova 40). WoS A_SetPitch / A_ZoomFactor / Offset recoil dropped (VR).
3. Open questions for the owner: RSQWS/dry = Doom 2 dsswtchn (my pick, confirm); Enhanced fire sounds (none mapped yet: ask).


## 2026-11-12 evening (owner: "you do the zscript continue rebuilding. save rig test til end")
- All twelve weapons are in src/zscript/wos: gun.zs (base + the quick kick as a mixin, RSQWS_KickMix), pistols.zs, smgs.zs,
  shotguns.zs, heavy.zs, melee.zs. The Knuckles are a Fist (RSQ Melee punches with any Fist; triggers free).
- Motorsaw: owner chose "Port BD22 VR's contact saw": rsvr/melee.zs is carried with KindOf = the Motorsaw only; cuts are
  RSQWS_SawCut (WoS damage random 1-10). Needs rsq/pose.zs (RSQ_PoseHandler before RSVR_MeleeHandler). stubs_melee.zs.
- Saturn V alt: rsq/rlock.zs (always on, Rocket2 -> RSQWS_SaturnRocket).
- 1911: an agent re-seated it on the FBX pistol hand in one pass (grip into the hand, pad on the trigger; tools/seat_1911.*,
  old seat kept as landmark_seat). The 1911 now has its own muzzle and ejection-port rows (row_1911.json Muzzle / CasingPort).
- A Goto inside a mixin is resolved in the mixin (no Ready there): the kick froze the gun. Fixed with A_Jump(256, "Ready").
- tools/suite.py + tools/suite/probe: the one rig suite (pickup, raise, fire, alt, kick, stock / hand / flick reload, dual).
  Rig facts learned: the off hand near the gun steadies it (two-hand grip) and the gun cannot flick -> flick with the off hand
  away; the pump waits for the hand after every shot in VR (robot 3 after each shot); the robots keep the first hand turn
  they find (no search per shell).

## 2026-11-12 22:15: delivered 0.1.0 (suite passed on tree 8e5014c7), owner testing
- OG = WoS sounds only (hand reload too: zscript/wos/ogsnd.gen.zs); Enhanced = WoS shot + RS Ballistics (BD22 VR's flash.zs table), Combat FX reloads.
- HUD = GBOVR's bottom row (tools/lib/stubs.zs RSQ_AmmoHud), stands down with GBOVR. rsq_hud_nohp option.
- Pickups: Voxels of Saturn + BD22 voxel pack (MP40 MP40I0, Nova SRCGA, Motorsaw CSAWA); 1911 = BD pistG0 recoloured to the
  1911 skin (tools/pickup_1911.py). The owner's voxel M1911 upload was rejected by him (removed).
- Flick = BD22 VR's rules only (no "Reloading = Flick" mode). Pump = BD22 VR's (a trigger pull pumps it).
- Open: Motorsaw alt fire (nothing), dry click sound (Doom 2 switch), 1911 recoil-follow rows borrowed from BrutalPistol.
- Waiting on the owner's headset test.

## 2026-11-13 basics (owner 01:41)
- The basics both weapon sets carry (tools/lib/basics.py, identical in both; owner: "the mods themselves will have basic
  pistol whip, jab hook uppercut, lift doors, uppercut barrels, quick grenade"):
  - Grenade: RSQ Grenade's own code (Grenade/zscript/rsqgn weapon, hand, thrown, upg, scatter) as RSQB_GN_, slot 0, the
    frag only (no kinds, no alt fire), Doom's explosion (MISL), barrels take each blast part twice. Pin by the other
    hand's ring or the teeth, arm throw, cook, Quick Grenade key ("Grenade" key section). Stands down for RSQ_Grenade.pk3.
  - Punches: BD22 VR's fists.zs, reading jab / hook / uppercut by direction; an uppercut into a barrel kicks it up and
    away with no damage (RSQ Melee's numbers). Own switch rsqb_punch (on; menu "Punches"). Stand down for RSQ Melee.
  - Pistol whip: BD22 VR's melee.zs PISTOL kind on the pistols (BrutalPistol rows), main and off hand.
  - Doors: Distance Grab's door.zs (palm against a manual door, Use, lift). Stands down for Distance Grab.
- RSQ Grenade no longer stands down for the weapon sets: BD22 VR's grenade placeholder is RSQB_GrenadeLink now.
- RSQ Melee's shove stands down only with Brutal Doom loaded (shove.zs BD22QLoaded checks BrutalWeapon); pk3 rebuilt.
- Suite: two more runs, BASICS alone and BASICS_WITH_SERIES (RSQ Grenade, Melee, Distance Grab).
