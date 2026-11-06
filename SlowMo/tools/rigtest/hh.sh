#!/bin/bash
# TEST ONLY (never ships). Heavy Hit Slowdown / cause line / Blast Time / Miniboss Ignore Spawn Restrictions on the rig,
# real BD order: doom2 (Freedoom 2 stand-in) -> brutal22test6 -> BD_VoxelPack -> BD22 VR 2.0.3y -> XMVE 04-07 -> SlowMo,
# Miniboss -> smheavy.   hh.sh <name> <mode> <secs> [dump-every]
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; HUB="$(dirname "$(dirname "$(dirname "$HERE")")")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; MODE=$2; SECS=$3; EVERY=${4:-0}
RIG=/home/claude/rsq_weapondepot/tools/rig/bin; G=/home/claude/gamedata; P=/home/claude/rs_brutal22weaponsq/pk3
( cd "$HERE/smheavy" && rm -f "$B/smheavy.pk3" && zip -q -r -X "$B/smheavy.pk3" . )
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"; rm -f "$B/logs/$NAME.log"
QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-480} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "$RIG/qz" -iwad "$G/doom2.wad" -file "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" \
  "$P/03_BD22_VR-Reloaded_2.0.3y.pk3" "$P/04_XMVE_MonsterExpansion1.3.1-BD22.pk3" "$P/05_XMVE_MonsterExpansion_TUD.pk3" \
  "$P/06_XMVE_MonsterExpansion_Doom2.pk3" "$P/07_XMVE_MonstersNoDropGuns-BD22.pk3" \
  "$HUB/pk3/RSQ_SlowMo.pk3" "$HUB/pk3/RSQ_Miniboss.pk3" ${EXTRA:-} "$B/smheavy.pk3" -nosound -warp ${MAP:-1} -skill 3 \
  +set hh_mode $MODE +logfile "$B/logs/$NAME.log" "+wait 1; notarget; screenblocks 10; ${SCRIPT:-wait 3000; quit}" > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini
echo "script errors: $(grep -c 'Script error' "$B/logs/$NAME.log")"
