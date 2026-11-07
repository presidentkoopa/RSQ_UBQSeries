#!/bin/bash
# TEST ONLY (never ships). RSQ SlowMo's DOWN v3 + Score's life crate + Graves Rise, ONE batched run on the full order:
# doom2 -> brutal22test6 -> BD_VoxelPack -> BD22 VR -> XMVE 04-07 -> Legion of Bones 1.05 -> every RSQ pk3 except GunBonsaiVR -> smdown.
#   dn.sh <name> <secs> [dump-every] [dn_mode: 1 v3c, 2 v3d, 3 v3e] [console wait tics]
#   DN_EXTRA="-singletics" (one tic a rendered frame: every tic captured)
#   DN_LD=<LegenDoom pk3>   loaded FIRST (before brutal22test6); DN_CHAMP=<Champions pk3> after Legion of Bones
#   DN_RSQ=<dir>            the RSQ pk3s from there instead of pk3/ (e.g. the last commit's, while other lanes rebuild)
#   DN_LOAD=1               load only: boot and quit
#   DN_RES=960              the rendered eye size (default 480)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; HUB="$(dirname "$(dirname "$(dirname "$HERE")")")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; EVERY=${3:-0}; MODE=${4:-1}; WAIT=${5:-1800}
RIG=/home/claude/rsq_weapondepot/tools/rig/bin; G=/home/claude/gamedata; P=/home/claude/rs_brutal22weaponsq/pk3
IWAD=$G/doom2.wad
( cd "$HERE/smdown" && rm -f "$B/smdown.pk3" && zip -q -r -X "$B/smdown.pk3" . )
RSQ=""; for f in "${DN_RSQ:-$HUB/pk3}"/RSQ_*.pk3; do case "$f" in *GunBonsaiVR*) ;; *) RSQ="$RSQ $f";; esac; done
BD22=$(ls "$P"/03_BD22_VR-Reloaded_*.pk3 | head -1)
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"; rm -f "$B/logs/$NAME.log"
CON="+wait 1; notarget; screenblocks 10; vr_hud_scale 0.55; wait $WAIT; quit"
[ -n "${DN_LOAD:-}" ] && { CON="+wait 5; quit"; MODE=0; }
QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR="$D" QZ_RES=${DN_RES:-480} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "$RIG/qz" -iwad "$IWAD" -file ${DN_LD:-} "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" \
  "$BD22" "$P/04_XMVE_MonsterExpansion1.3.1-BD22.pk3" "$P/05_XMVE_MonsterExpansion_TUD.pk3" \
  "$P/06_XMVE_MonsterExpansion_Doom2.pk3" "$P/07_XMVE_MonstersNoDropGuns-BD22.pk3" "$G/LOB_v1.05.pk3" ${DN_CHAMP:-} \
  $RSQ "$B/smdown.pk3" -nosound -warp 1 -skill 3 ${DN_EXTRA:-} \
  +set dn_mode $MODE +logfile "$B/logs/$NAME.log" "$CON" < /dev/null > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
git -C /home/claude/rsq_weapondepot checkout tools/rig/bin/config/qzdoom.ini
echo "script errors: $(grep -a -c -i -E 'Script error|VM abort|Execution could not continue' "$B/logs/$NAME.log" "$B/logs/$NAME.out" | tr '\n' ' ')"
