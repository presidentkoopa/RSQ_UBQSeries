#!/bin/bash
# TEST ONLY: run.sh name secs script -- under the shared rig lock; strips archived grapple cvars, then run17 on doom2
exec 9>/home/claude/rig.lock; flock -x 9
sed -i -E '/^(rsqgr_|grp_|grv_|rsqml_)/d' /home/claude/g9/rig/config/qzdoom.ini
export IWAD=/home/claude/iwad/doom2/doom2.wad
/home/claude/RSQ_UBQSeries/tools/rig17/run17.sh "$@"
L=/home/claude/scratch/logs/$1.log
echo "script errors: $(grep -c 'Script error' $L)"; grep -B1 -A3 "Script error" $L | head -12
