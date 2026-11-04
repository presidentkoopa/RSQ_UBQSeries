#!/bin/bash
# TEST ONLY (never ships). Damage-number probe on the real QZD 17.3 rig (tools/rig17/run17.sh), doom2.wad.
#   tools/rigprobe/run_dn.sh <name> <secs> "<console>" <pk3s...>   (absolute paths; the probe is appended last)
# Log: /home/claude/scratch/logs/<name>.log. FRAMES=n dumps every n-th frame to $SC/dnframes/<name>/.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; SER="$(cd "$HERE/../../.." && pwd)"
SC=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
P=$(mktemp -d); cp "$HERE/zscript_dn.txt" "$P/zscript.txt"; cp "$HERE/CVARINFO_dn.txt" "$P/CVARINFO.txt"
echo 'GameInfo { AddEventHandlers = "THPDN_Probe" }' > "$P/MAPINFO.txt"
mkdir -p $SC/dnprobe; rm -f $SC/dnprobe/$NAME.pk3; (cd "$P" && zip -q -r -X $SC/dnprobe/$NAME.pk3 .); rm -rf "$P"
F=$SC/dnframes/$NAME; rm -rf $F
if [ -n "${FRAMES:-}" ]; then mkdir -p $F; export QZ_DUMP_EVERY=$FRAMES QZ_DUMP_DIR=$F; fi
export IWAD=/home/claude/iwad/doom2/doom2.wad PK3S="$* $SC/dnprobe/$NAME.pk3"
flock -o -x /home/claude/rig.lock bash "$SER/tools/rig17/run17.sh" "$NAME" "$SECS" "god; notarget; $SCRIPT${QUITAT:+; wait $QUITAT; quit}"
if [ -n "${FRAMES:-}" ]; then python3 -c "
import glob
from PIL import Image
for f in glob.glob('$F/*.ppm'):
    Image.open(f).save(f[:-4]+'.png')
"; rm -f $F/*.ppm; echo "frames: $(ls $F | wc -l) in $F"; fi
L=/home/claude/scratch/logs/$NAME.log
echo "script errors (not voxeldef): $(grep -i -E 'script error|VM abort|exception' $L | grep -v -i voxeldef | wc -l)"
grep -i -E "script error|VM abort|exception|Called from|Tried to" $L | grep -v -i voxeldef | head -10
