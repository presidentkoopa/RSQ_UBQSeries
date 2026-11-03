#!/bin/bash
# TEST ONLY: run.sh <name> <secs> "<pk3s>" "<console script>" -- one qzd17.3 rig run on doom2 under the shared rig lock.
# Rebuilds bossprobe.pk3; strips archived series cvars first. The log: /home/claude/scratch/logs/<name>.log
T=$(cd "$(dirname "$0")" && pwd)
(cd $T/bossprobe && rm -f ../bossprobe.pk3 && zip -q -r ../bossprobe.pk3 .)
exec 9>/home/claude/rig.lock; flock -x 9
sed -i -E '/^(rsqmb_|rsqgb_|rsqgr_|rsqwp_|rsqml_|mbp_|grv_|whp_|mlp_|LD_|qz_)/d' /home/claude/g9/rig/config/qzdoom.ini
PK3S="$3" IWAD=${IWAD:-/home/claude/iwad/doom2/doom2.wad} bash $(cd "$T/../../.." && pwd)/tools/rig17/run17.sh "$1" "$2" "$4" >/dev/null
L=/home/claude/scratch/logs/$1.log
echo "== $1: script errors $(grep -c 'Script error' $L)"
grep -v GL_EXT $L | grep -iE "script error|VM abort|exception|unknown (class|actor|identifier)|tried to|errors? while" | grep -v "No sprites specified for voxel" | head
