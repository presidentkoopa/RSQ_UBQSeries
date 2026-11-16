#!/bin/bash
# run.sh <name> <secs> [extra args]: the owner's full order (/home/claude/rig/work/boss/boss_full.sh) with gate_rel3's pk3s
# (hardlinked into /home/claude/rig/work/wm/pk3) and this lane's RSQ_VisualRewards.pk3, BD22 VR 2.0.4z, MAP01, flock'd,
# sv_cheats 1, rsqtr_eye_m 1.6, the probe; frames every EVERY-th drawn frame (default 1), RES px (default 720)
N=$1; S=$2; shift 2
W=/home/claude/rig/work/wm
export P=$W/pk3 BDVR=/home/claude/rsq_bd_vr_reloaded/BD22_VR-Reloaded_2.0.4z.pk3 MAP=01 EVERY=${EVERY:-1} RES=${RES:-720}
export EXTRA="+set sv_cheats 1 +set rsqtr_eye_m 1.6 $EXTRA"
flock /home/claude/rig.lock bash /home/claude/rig/work/boss/boss_full.sh $N $S "${SC:-wait 900;wait 10;quit}" "$@"
