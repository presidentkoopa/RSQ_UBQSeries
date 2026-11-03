#!/bin/bash
# trb_run.sh <name> <secs> -- one rig run of the torso probe (TEST ONLY). env: TR (a TacticalRig pk3 other than pk3/),
# EXTRA (pk3s before it), AFTER (after), IWAD. Script: trb_script.txt (gen_body_script.py).
name=$1; secs=$2
S=/home/claude/scratch/trbody; mkdir -p $S
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$D/../../../.." && pwd)
(cd "$D" && rm -f $S/trbprobe.pk3 && zip -qr $S/trbprobe.pk3 zscript.txt CVARINFO.txt MAPINFO.txt)
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log
sed -i -E '/^(rsqtr_|trb_|trc_)/d' /home/claude/g9/rig/config/qzdoom.ini
cd /home/claude/g9/rig && env QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout $secs ./qz -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file $EXTRA ${TR:-$R/pk3/RSQ_TacticalRig.pk3} $AFTER $S/trbprobe.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$(cat $D/trb_script.txt)" > $L/$name.out 2>&1
echo "rc=$? log $L/$name.log"
