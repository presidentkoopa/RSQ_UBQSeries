#!/bin/bash
# trh_run.sh <name> <secs> <script> -- one rig run of the whip / flare holster probe, with frame dumps (TEST ONLY)
# env: EXTRA (pk3s before TacticalRig), TR (a TacticalRig pk3 other than pk3/), AFTER (pk3s after: RSQ_Whip, RSQ_FnF ...),
# EVERY (dump every n frames, 0 none), IWAD. Scripts: trh_script*.txt (gen_trh_scripts.py). Trimmed logs: evidence/.
name=$1; secs=$2; script=$3
S=/home/claude/scratch/trhol
R=$(cd "$(dirname "$0")/../../../.." && pwd)
mkdir -p $S && (cd "$(dirname "$0")" && rm -f $S/trhprobe.pk3 && zip -qr $S/trhprobe.pk3 zscript.txt MAPINFO.txt)
D=$S/frames/$name; rm -rf $D; mkdir -p $D
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log
# a private config (the rig is shared by other lanes: their runs set vr_control_scheme and mod cvars in the shared ini),
# and the rig's lock (/home/claude/rig.lock) so two runs never share the engine at once
C=$S/qzdoom_trh.ini; [ -f $C ] || cp /home/claude/g9/rig/config/qzdoom.ini $C
sed -i -E '/^(rsqdg_|rsqls_|ssq_|ubqs_|rsqdgt_|rsqtr_|rsqtrt_|rsqsm_|rsm_|trc_|rsqgn_|rsqff_|rsqwp_)/d; s/^vr_control_scheme=.*/vr_control_scheme=0/' $C
cd /home/claude/g9/rig && flock -x /home/claude/rig.lock env QZ_DUMP_EVERY=${EVERY:-0} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout $secs ./qz -config $C -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file $EXTRA ${TR:-$R/pk3/RSQ_TacticalRig.pk3} $AFTER $S/trhprobe.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$script" > $L/$name.out 2>&1
echo "rc=$? frames $(ls $D | wc -l) log $L/$name.log"
