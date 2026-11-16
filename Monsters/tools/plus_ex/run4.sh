#!/bin/bash
# run1.sh <boss> <kill> <child> <totaltics> [hp] [timerskip]
B=$1; K=$2; C=$3; T=$4; HP=${5:-0}; SK=${6:-0}
N=plusex_${TAG:-}$B
cd /home/claude/rig/work || exit 1
P=/home/claude/scratch_plusex/P2 BDVR=/mnt/user-data/outputs/rel4/BD22_VR-Reloaded_2.0.5a.pk3 MAP=01 EVERY=${EVERY:-35} EXTRA="+set sv_cheats 1" \
 flock /home/claude/rig.lock /home/claude/scratch_plusex/bf.sh $N ${SECS:-400} "set rspx_boss $B; set rspx_kill $K; set rspx_child $C; set rspx_hp $HP; set rspx_timerskip $SK; $FORCE wait $T; wait 10; quit" /home/claude/scratch_plusex/${PROBE:-probe.pk3}
