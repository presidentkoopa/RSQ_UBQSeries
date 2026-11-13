# HANDOFF (latest first)

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
