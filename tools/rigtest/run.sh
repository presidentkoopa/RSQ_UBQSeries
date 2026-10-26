#!/bin/bash
# TEST ONLY, never ships. One rig run of RSQ_DistanceGrab with the probe.
#   tools/rigtest/run.sh <name> <secs> "<console script>"        plain
#   GDB=1 tools/rigtest/run.sh ...                                 + every QzDoom_Vibrate logged
# Needs: the RSQ_WeaponDepot rig (tools/rig/bin, prebuilt QZD for Linux, poses from cvars)
#   RIG=<path to that bin dir>   IWAD=<freedoom2.wad or doom2.wad>
# Logs land in tools/rigtest/logs/<name>.log (engine log) and .out (stdout, incl. T_VIBRATE).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; PKG="$(cd "$HERE/../.." && pwd)"
RIG=${RIG:?set RIG to the WeaponDepot rig bin dir}; IWAD=${IWAD:?set IWAD}
name=$1; secs=$2; script=$3
L="$HERE/logs"; mkdir -p "$L"; rm -f "$L/$name.log" "$L/$name.out"
( cd "$HERE/probe" && rm -f "$L/probe.pk3" && zip -q -r "$L/probe.pk3" . )
PK3=${PK3:-$PKG/RSQ_DistanceGrab.pk3}
cd "$RIG"; [ -e libGLESv3.so ] || ln -sf /usr/lib/x86_64-linux-gnu/libGLESv2.so.2 libGLESv3.so
ARGS=(-iwad "$IWAD" -file "$PK3" "$L/probe.pk3" -nosound -warp "${MAP:-1}" -skill 3 +logfile "$L/$name.log" "+$script")
export QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH="$RIG"
set +e
if [ -n "$GDB" ]; then timeout "$secs" gdb -q -batch -x "$HERE/gdbvib.cmd" --args ./qzdoom "${ARGS[@]}" > "$L/$name.out" 2>&1
else timeout "$secs" ./qzdoom "${ARGS[@]}" > "$L/$name.out" 2>&1; fi
echo "rc=$?"
