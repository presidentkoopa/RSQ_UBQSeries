#!/bin/bash
# TEST ONLY (never ships). The VisualRewards merge's runs on the real QZD 17.3 rig (tools/rig17/run17.sh), doom2.wad.
#   tools/rigprobe/run_vr.sh <name> <secs> "<console>" <pk3s...>   (absolute paths; the probe pk3 is appended last)
# The probe pk3 holds zscript_vr.txt (VRP_*: Kill Rewards census, services, cvars; names only, so it loads with any set) and,
# with DN3=1, the damage-number probe zscript_dn3.txt as well (it names VisualRewards' classes: load VisualRewards then).
# KEEPINI=1 keeps the ini's rsqgb_kr_* / rsqthp_* values (the old-ini test); otherwise they are stripped first.
# Log: /home/claude/scratch/logs/<name>.log. FRAMES=n dumps every n-th frame (left eye) to $SC/vrframes/<name>/.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; SER="$(cd "$HERE/../../.." && pwd)"
SC=${SC:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad}
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
P=$(mktemp -d); mkdir -p "$P/z"
cp "$HERE/zscript_vr.txt" "$P/z/vr.zs"; sed -i '1d' "$P/z/vr.zs"
{ echo 'version "4.14"'; echo '#include "z/vr.zs"'; } > "$P/zscript.txt"
cp "$HERE/CVARINFO_vr.txt" "$P/CVARINFO.txt"
H='"VRP_Probe"'
if [ -n "${DN3:-}" ]; then
  cp "$HERE/zscript_dn3.txt" "$P/z/dn3.zs"; sed -i '1d' "$P/z/dn3.zs"; echo '#include "z/dn3.zs"' >> "$P/zscript.txt"
  cat "$HERE/CVARINFO_dn3.txt" >> "$P/CVARINFO.txt"; H="$H, \"THPDN3_Probe\""
fi
echo "GameInfo { AddEventHandlers = $H }" > "$P/MAPINFO.txt"
mkdir -p $SC/vrprobe; rm -f $SC/vrprobe/$NAME.pk3; (cd "$P" && zip -q -r -X $SC/vrprobe/$NAME.pk3 .); rm -rf "$P"
F=$SC/vrframes/$NAME; rm -rf $F
if [ -n "${FRAMES:-}" ]; then mkdir -p $F; export QZ_DUMP_EVERY=$FRAMES QZ_DUMP_DIR=$F; fi
export IWAD=${IWAD:-/home/claude/iwad/doom2/doom2.wad} PK3S="$* $SC/vrprobe/$NAME.pk3"
STRIP='/^(rsqthp_|rsqgb_|rsqmb_|vrp_|dn3_)/d'; [ -n "${KEEPINI:-}" ] && STRIP='/^(vrp_|dn3_)/d'
flock -o -x /home/claude/rig.lock bash -c "sed -i -E '$STRIP' /home/claude/g9/rig/config/qzdoom.ini; bash \"\$0\" \"\$@\"" "$SER/tools/rig17/run17.sh" "$NAME" "$SECS" "$SCRIPT${QUITAT:+; wait $QUITAT; quit}" >/dev/null
if [ -n "${FRAMES:-}" ]; then python3 -c "
import glob
from PIL import Image
for f in glob.glob('$F/*.ppm'):
    Image.open(f).save(f[:-4]+'.png')
"; rm -f $F/*.ppm; echo "frames: $(ls $F | wc -l) in $F"; fi
L=/home/claude/scratch/logs/$NAME.log
echo "== $NAME: script errors (not voxeldef): $(grep -i -E 'script error|VM abort|exception|errors while compiling' $L | grep -v -i voxeldef | wc -l), voxeldef lines $(grep -c -i 'No sprites specified for voxel' $L)"
grep -i -E "script error|VM abort|exception|Called from|errors while compiling|Unable to|unknown class|not found" $L | grep -v -i voxeldef | head -10
