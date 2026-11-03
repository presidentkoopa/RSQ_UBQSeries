FORCE HAND PROBE (test only, never ships; docs/ is not packed). 2026-11-03, the "Our Hand" switch.
- zscript.txt: FHP_Probe (netevent fhp_arm / fhp_imps: one FHP line a tic with the off hand's class, sprite
  and frame and the Force's state) and FHP_Cand (an off-hand weapon drawing candidate poses, fhp_cand 0..6).
- MODELDEF.txt needs models/fhp/cand.md3 = BD22 VR's fbx_oh_hold_R.md3 frames 0 2 3 18 23 and models/fhp/free.md3 =
  fbx_oh_free_R.md3 frames 0 1 (cut with Melee/tools/md3_frames.py; BD22's pk3 is LZMA: extract with Python's
  zipfile, Info-ZIP unzip cannot) and models/fhp/fhp_hand.png = fbx_hand.png. Not committed (BD22's assets).
- run.sh (a private copy of the Linux rig17 engine, frames with DUMP=1), seq.py <mesh> <lefty> [gb] (the
  idle / Force up / push / pull / grip / turned sequence), frames.py + sheet.py (frame <-> tic by timestamp,
  contact sheets), err.sh (the three zero-error orders). Paths are this cloud session's.
Frames: ../forcehand_1103/.
