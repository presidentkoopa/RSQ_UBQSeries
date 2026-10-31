#!/bin/bash
# TEST ONLY (never ships). The QoL round on the rig, the owner's Brutal Doom order:
#   tools/rigtest/qol.sh <name> <secs> "<console script>"
# Packs RSQ_Gestures.pk3 (build.sh) and qolprobe; EXTRA = more pk3s after ours (RSQ_Wheel for GE1).
# Env: OUT (logs and frames), QZ_DUMP_EVERY / QZ_RES for frames, MAP (warp), GDB=1 logs every controller rumble
# (VRMode::Vibrate) as T_VIBRATE lines in <name>.out (as GunCards/tools/rigtest/run.sh does).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
RIG=/home/claude/rsq_weapondepot/tools/rig/bin; G=/home/claude/gamedata
OUT=${OUT:-${TMPDIR:-/tmp}/rsqg}; NAME=$1; SECS=$2; SCRIPT=$3
sh "$HERE/build.sh" >/dev/null
mkdir -p "$OUT"; D="$OUT/$NAME"; rm -rf "$D"; mkdir -p "$D"
( cd "$HERE/qolprobe" && rm -f "$OUT/qolprobe.pk3" && zip -q -r -X "$OUT/qolprobe.pk3" . )
cp "$RIG/config/qzdoom.ini" "$OUT/$NAME.ini"
PRE=()
if [ -n "${GDB:-}" ]; then
	printf '%s\n' 'set pagination off' 'set breakpoint pending on' 'break VRMode::Vibrate(float, int, float) const' 'commands' 'silent' \
		'printf "T_VIBRATE dur=%.0f chan=%d amp=%.2f\n", $xmm0.v4_float[0], $esi, $xmm1.v4_float[0]' 'continue' 'end' \
		'break s3d::OpenXRDeviceMode::Vibrate(float, int, float) const' 'commands' 'silent' \
		'printf "T_VIBRATE_XR dur=%.0f chan=%d amp=%.2f\n", $xmm0.v4_float[0], $esi, $xmm1.v4_float[0]' 'continue' 'end' 'run' > "$OUT/gdb.cmd"
	PRE=(stdbuf -oL gdb -q -batch -x "$OUT/gdb.cmd" --args)
fi
cd "$RIG"
[ -e libGLESv3.so ] || ln -sf /usr/lib/x86_64-linux-gnu/libGLESv2.so.2 libGLESv3.so
QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-240} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH="$RIG" \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "${PRE[@]}" ./qzdoom -config "$OUT/$NAME.ini" -iwad "$G/doom2.wad" \
  -file "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" "$G/BD22_VR-Reloaded_2_0_3h.pk3" "$G/BD22_VR-Reloaded_2.0.3ha_hotfix.pk3" \
  "$HERE/build/RSQ_Gestures.pk3" ${EXTRA:-} "$OUT/qolprobe.pk3" \
  -nosound -warp ${MAP:-1} -skill 3 +logfile "$D.log" "+$SCRIPT" > "$D.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$D.log"
rm -f "$OUT/$NAME.ini"
e=$(grep -c "Script error" "$D.log"); v=$(grep -A1 "Script error" "$D.log" | grep -c -i "voxeldef\|No sprites specified")
echo "script errors: $((e - v)) (+$v BD voxeldef)"
grep -E "errors? while compiling|Execution could not|VM abort|Unknown identifier|Attempt to" "$D.log" | head -6
