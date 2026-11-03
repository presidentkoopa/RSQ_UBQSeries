#!/bin/bash
# trc_run.sh <name> <secs> <script> -- one rig run of the cigarette ritual with frame dumps (TEST ONLY)
# Builds the probe (this folder) to $S/trcprobe.pk3; scripts: trc_script*.txt (A ritual doom2, B full order + SlowMo,
# C door, D cancels, E level change; 11-02: F the whole ritual from realistic hand-to-mouth poses (doom2, AFTER=SlowMo), G the zone
# cue, H the same on the full order, V / Z the computed drawn points (trc_marks 1), P / Q one gun out of a holster (trc_weap 1)).
# 11-03: X1 / X2 / X3 every switch and holster with the cigarette in the hand / mouth / lit, R the whole ritual and its
# other ends, S the stray-cigarette repro (gen_scripts_1103.py writes them; LO_* for the full order, GB_* with Gun Bonsai VR).
# Trimmed logs of the runs: evidence/. Example: ./trc_run.sh trcA 500 "$(cat trc_scriptA.txt)"
# env: EXTRA (pk3s before TacticalRig), TR (a TacticalRig pk3 other than pk3/, e.g. the one before a change), AFTER (pk3s after), EVERY (dump every n frames, 0 none), IWAD
name=$1; secs=$2; script=$3
S=/home/claude/scratch/trcig
R=$(cd "$(dirname "$0")/../../../.." && pwd)
mkdir -p $S && (cd "$(dirname "$0")" && rm -f $S/trcprobe.pk3 && zip -qr $S/trcprobe.pk3 zscript.txt CVARINFO.txt MAPINFO.txt TRNSLATE.txt)
D=$S/frames/$name; rm -rf $D; mkdir -p $D
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log
sed -i -E '/^(rsqdg_|rsqls_|ssq_|ubqs_|rsqdgt_|rsqtr_|rsqtrt_|rsqsm_|rsm_|trc_)/d' /home/claude/g9/rig/config/qzdoom.ini
cd /home/claude/g9/rig && env QZ_DUMP_EVERY=${EVERY:-0} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout $secs ./qz -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file $EXTRA ${TR:-$R/pk3/RSQ_TacticalRig.pk3} $AFTER $S/trcprobe.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$script" > $L/$name.out 2>&1
echo "rc=$? frames $(ls $D | wc -l) log $L/$name.log"
