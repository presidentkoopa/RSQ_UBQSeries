#!/bin/bash
# run.sh name secs script  -- strips archived grapple cvars, then run17
sed -i -E '/^(rsqgr_|grp_|grv_)/d' /home/claude/g9/rig/config/qzdoom.ini
export IWAD=/home/claude/iwad/doom2/doom2.wad
/home/claude/RSQ_UBQSeries/tools/rig17/run17.sh "$@"
L=/home/claude/scratch/logs/$1.log
echo "script errors: $(grep -c 'Script error' $L)"; grep -A2 "Script error" $L | grep -v voxeldef | head -8
