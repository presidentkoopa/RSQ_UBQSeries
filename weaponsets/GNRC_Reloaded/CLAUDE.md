# GNRC_Reloaded: rules for every session

Led's Generic Weapon Mod rebuilt in ZScript for VR on the WoS_Reloaded base (QuestZDoom 17.3). The agreed plan is
PLAN.md; it is the owner's, change it only on his word.

1. Questions go to the owner, one at a time, short. Never decide a design, mesh, sound or behaviour he has not decided.
2. No new meshes (owner). BD22 VR's meshes, hands and reload systems; GNRC's voxel pack for pickups.
3. No ACS. No engine changes. QZD 17.3 / ZScript 4.14 APIs only.
4. Nothing is "working" until the rig suite shows it. No pk3 leaves without a passing suite; the build enforces it.
5. One rig suite at the end, unattended; one report with the logs.
6. Commit to main. Never create branches.

Rebuild: `python3 tools/gen_gnrc.py` (GNRC's non-weapon actors), `python3 tools/build.py`, `python3 tools/compile_check.py out/tree`,
`python3 tools/suite.py`, then `python3 tools/build.py --pk3`.
