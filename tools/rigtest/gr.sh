#!/bin/bash
# gr.sh <name> <secs> <script> [full]  -- RSQ_Grapple on rig H. full=1: owner's load order.
sed -i -E '/^(rsqgr_|grp_)/d' /home/claude/g9/rigH/config/qzdoom.ini
EXTRA=${EXTRA-$(cd "$(dirname "$0")" && pwd)/grprobe.pk3}
G=/home/claude/work/RSQGR_core/RSQ_Grapple.pk3
D=/mnt/user-data/uploads/DOOMWork; U=/home/claude/scratch/ubq_zip
if [ "$4" = "1" ]; then
  export PK3S="$D/brutal22test6.pk3 $D/BD_VoxelPack.pk3 $D/BD22_VR-Reloaded_1.99x-lb-r7-saveload.pk3 $U/UltraBadassQuestSaber.pk3 $U/UltraBadassShieldSaw.pk3 $U/RSQ_TacticalRig.pk3 $U/RSQ_SlowMo.pk3 $U/RSQ_DistanceGrab.pk3 $U/RSQ_Score.pk3 $G $EXTRA"
else
  export PK3S="$G $EXTRA"
fi
/home/claude/scratch/run17H.sh "$1" "$2" "$3"
L=/home/claude/scratch/logsH/$1.log
grep -n -i -E "script error|error|abort|exception|unknown|T_FAIL|warning" $L | grep -v -i -E "voxeldef|GL_EXTENSIONS" | head -30
