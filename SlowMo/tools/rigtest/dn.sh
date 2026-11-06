#!/bin/bash
# TEST ONLY (never ships). RSQ SlowMo's DOWN / REVIVE, ONE batched run on the full order:
# doom2 (Freedoom 2 stand-in, /home/claude/gamedata) -> brutal22test6 -> BD_VoxelPack -> BD22 VR 2.0.3z -> XMVE 04-07 ->
# every RSQ pk3 except GunBonsaiVR -> smdown.   dn.sh <name> <secs> [dump-every]
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; HUB="$(dirname "$(dirname "$(dirname "$HERE")")")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; EVERY=${3:-0}
RIG=/home/claude/rsq_weapondepot/tools/rig/bin; G=/home/claude/gamedata; P=/home/claude/rs_brutal22weaponsq/pk3
( cd "$HERE/smdown" && rm -f "$B/smdown.pk3" && zip -q -r -X "$B/smdown.pk3" . )
RSQ=""; for f in "$HUB"/pk3/RSQ_*.pk3; do case "$f" in *GunBonsaiVR*) ;; *) RSQ="$RSQ $f";; esac; done
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"; rm -f "$B/logs/$NAME.log"
cp "$RIG/config/qzdoom.ini" "$B/qzdoom.ini.bak"
QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR="$D" QZ_RES=480 EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "$RIG/qz" -iwad "$G/doom2.wad" -file "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" \
  "$P/03_BD22_VR-Reloaded_2.0.3z.pk3" "$P/04_XMVE_MonsterExpansion1.3.1-BD22.pk3" "$P/05_XMVE_MonsterExpansion_TUD.pk3" \
  "$P/06_XMVE_MonsterExpansion_Doom2.pk3" "$P/07_XMVE_MonstersNoDropGuns-BD22.pk3" \
  $RSQ "$B/smdown.pk3" -nosound -warp 1 -skill 3 \
  +set dn_mode 1 +logfile "$B/logs/$NAME.log" "+wait 1; notarget; screenblocks 10; vr_hud_scale 0.55; wait 900; quit" > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
cp "$B/qzdoom.ini.bak" "$RIG/config/qzdoom.ini"
echo "script errors: $(grep -c 'Script error' "$B/logs/$NAME.log")"
