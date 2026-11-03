#!/bin/bash
# TEST ONLY (never ships). RSQ_Whip + the whp probe on the qzd17.3 rig (/home/claude/g9/rig, tools/rig17).
#   tools/rigtest/whp.sh <name> <secs> "<console script>"
#   BD=1   the owner's order first (doom2 -> 01 brutal22test6 -> 02 voxels -> 03 BD22 VR-Reloaded 2.0.3j -> 04-07 XMVE)
#   ALL=1  every other RSQ pk3 in pk3/ too (the owner's full set); GB=1 keeps RSQ_GunBonsaiVR in it
#   PRE="a.pk3 b.pk3"  loaded after the BD order and before the RSQ pk3s (e.g. GunBonsai itself before RSQ_GunBonsaiVR)
#   OUT=dir  where the test pk3s, logs and frames go (default: the scratchpad); QZ_DUMP_EVERY=n dumps frames
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; GR="$(dirname "$(dirname "$HERE")")"; HUB="$(dirname "$GR")"
# SRC=dir: pack that Whip folder instead (a before/after baseline, e.g. a `git archive HEAD Whip` copy)
WSRC=${SRC:-$GR}
B=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/whp}; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; SCRIPT=$3
LO=${LO:-/home/claude/scratch/lo2}
( cd "$WSRC" && rm -f "$B/RSQ_Whip_test.pk3" && zip -q -r -X "$B/RSQ_Whip_test.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt MODELDEF.txt zscript sprites sounds models )
( cd "${PROBE:-$HERE/whp}" && rm -f "$B/whp.pk3" && zip -q -r -X "$B/whp.pk3" . )
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"
files=()
[ -n "${BD:-}" ] && for f in "$LO"/0*.pk3; do files+=("$f"); done
for f in ${PRE:-}; do files+=("$f"); done
ALLDIR=${ALLDIR:-$HUB/pk3}
if [ -n "${ALL:-}" ]; then for f in "$ALLDIR"/RSQ_*.pk3; do case "$(basename "$f")" in RSQ_Whip.pk3) ;; RSQ_GunBonsaiVR.pk3) [ -n "${GB:-}" ] && files+=("$f");; *) files+=("$f");; esac; done; fi
files+=("$B/RSQ_Whip_test.pk3" "$B/whp.pk3")
# a private copy of the rig's ini (its controller binds: Shift=+oh_attack, Alt=+oh_altatk), so other lanes' runs on the
# same rig never share this one's config
CFG="$B/whp_qzdoom.ini"; [ -f "$CFG" ] || cp /home/claude/g9/rig/config/qzdoom.ini "$CFG"
sed -i -E '/^(rsqwp_|whp_)/d' "$CFG" 2>/dev/null
rm -f "$B/logs/$NAME.log"
cd /home/claude/g9/rig && QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout "$SECS" ./qz -config "$CFG" -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file "${files[@]}" \
  -nosound -warp ${MAP:-1} -skill 3 +logfile "$B/logs/$NAME.log" "+$SCRIPT" > "$B/logs/$NAME.out" 2>&1
rc=$?
echo "load order: ${files[*]##*/}"
echo "rc=$rc frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
echo "script errors: $(grep -c 'Script error' "$B/logs/$NAME.log")"
grep -B3 "while compiling" "$B/logs/$NAME.log" | head -12; grep -E "Unknown identifier|VM execution|abort" "$B/logs/$NAME.log" | head -10
grep -A2 "Script error" "$B/logs/$NAME.log" | grep -v -i voxeldef | head -20
