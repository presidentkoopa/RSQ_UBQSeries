#!/bin/bash
# trt_run.sh <name> <script: snap|smooth|room|look> <secs> -- one rig run of the turn probe (TEST ONLY).
# env: PK3S (absolute, space-separated: the RSQ pk3s under test, TacticalRig and ShieldSaw among them), FPS (vid_maxfps,
# default 90), PRECMD (console commands before the script), IWAD, PROBE=ss (RSQ ShieldSaw without RSQ TacticalRig), PROBE=old
# (pk3s from before the 11-03 keeper or the recenter), PROBE=ssold (ShieldSaw alone, from before the recenter).
name=$1; which=$2; secs=$3
S=/home/claude/scratch/trturn; mkdir -p $S
D=$(cd "$(dirname "$0")" && pwd)
P=$S/trtprobe_$$; rm -rf $P; mkdir -p $P; cp $D/CVARINFO.txt $D/MAPINFO.txt $P/; if [ "$PROBE" = ss ]; then cp $D/zscript_ss.txt $P/zscript.txt; elif [ "$PROBE" = ssold ]; then sed '/TRR BEGIN/,/TRR END/d' $D/zscript_ss.txt > $P/zscript.txt; elif [ "$PROBE" = old ]; then sed '/TRQ BEGIN/,/TRQ END/d; /TRR BEGIN/,/TRR END/d' $D/zscript.txt > $P/zscript.txt; else cp $D/zscript.txt $P/; fi
(cd $P && rm -f $S/trtprobe_$name.pk3 && zip -qr $S/trtprobe_$name.pk3 zscript.txt CVARINFO.txt MAPINFO.txt); rm -rf $P
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log
sed -i -E '/^(rsqtr_|ssq_|trt_)/d' /home/claude/g9/rig/config/qzdoom.ini
cd /home/claude/g9/rig && env QZ_RES=${QZ_RES:-120} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout $secs ./qz -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file $PK3S $S/trtprobe_$name.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+set vid_maxfps ${FPS:-90}; ${PRECMD} $(cat $D/turn_$which.txt)" > $L/$name.out 2>&1
echo "rc=$? log $L/$name.log"
