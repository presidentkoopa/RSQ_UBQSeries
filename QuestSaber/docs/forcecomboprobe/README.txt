FORCE COMBO PROBE (test only, never ships; docs/ is not packed). 2026-11-03, "Force Only With the Saber" (ubqs_force_saber).
- zscript.txt + MAPINFO.txt: FCP_Probe, one FCP line each tic the main / off / pending weapon changes; netevents
  fcp_saber, fcp_main n, fcp_direct n (the Wheel's instant equip), fcp_offgun n, fcp_offforce, fcp_next (level change,
  inventory kept, no intermission). ubqs_diag 4 makes the Saber print its own UBQS COMBO line per swap.
- gen.py writes seq_A.txt (saber in, rifle by key, rifle hand reload, M203 open, saber back, off-hand gun kept) and
  seq_B.txt (level changes, save/load, Wheel-style instant switch, death) from the Depot rig's mags.py / m203.py
  geometry and the B22 probe's boot dump (RSQ_WeaponDepot tools/rig/probe, loaded beside FCP for run A).
- Runs: tools/rig17/run17.sh, IWAD doom2, absolute PK3S. Logs: log_*.txt. Rig only, not headset-confirmed.
