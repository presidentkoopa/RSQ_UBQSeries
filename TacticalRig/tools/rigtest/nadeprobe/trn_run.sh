#!/bin/bash
# trn_run.sh <name> <secs> <script> -- one rig run of the grenade-holster probe, with frame dumps (TEST ONLY)
# env: EXTRA (pk3s before TacticalRig), TR (a TacticalRig pk3 other than pk3/), AFTER (pk3s after), EVERY (dump every n
# frames, 0 none), IWAD. Scripts: trn_script*.txt (gen_trn_scripts.py). Trimmed logs: evidence/.
name=$1; secs=$2; script=$3
S=/home/claude/scratch/trnade
R=$(cd "$(dirname "$0")/../../../.." && pwd)
mkdir -p $S && (cd "$(dirname "$0")" && rm -f $S/trnprobe.pk3 && zip -qr $S/trnprobe.pk3 zscript.txt MAPINFO.txt)
D=$S/frames/$name; rm -rf $D; mkdir -p $D
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log
sed -i -E '/^(rsqdg_|rsqls_|ssq_|ubqs_|rsqdgt_|rsqtr_|rsqtrt_|rsqsm_|rsm_|trc_|rsqgn_)/d' /home/claude/g9/rig/config/qzdoom.ini
cd /home/claude/g9/rig && env QZ_DUMP_EVERY=${EVERY:-0} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout $secs ./qz -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file $EXTRA ${TR:-$R/pk3/RSQ_TacticalRig.pk3} $AFTER $S/trnprobe.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$script" > $L/$name.out 2>&1
echo "rc=$? frames $(ls $D | wc -l) log $L/$name.log"
