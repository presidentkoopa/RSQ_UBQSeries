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
