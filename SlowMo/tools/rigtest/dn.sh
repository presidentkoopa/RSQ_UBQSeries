#!/bin/bash
# TEST ONLY (never ships). RSQ SlowMo's DOWN v2, ONE batched run on the full order:
# Freedoom 2 (doom2 stand-in) -> brutal22test6 -> BD_VoxelPack -> BD22 VR 2.0.4 -> XMVE 04-07 -> every RSQ pk3 except
# GunBonsaiVR -> smdown.   dn.sh <name> <secs> [dump-every] [ld]
#   ld: the extra run, LegenDoom 3.0 loaded first and smchamp (a stand-in class named champion_Token), dn_mode 2
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; HUB="$(dirname "$(dirname "$(dirname "$HERE")")")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; EVERY=${3:-0}; LD=${4:-}
RIG=/home/claude/rsq_weapondepot/tools/rig/bin; G=/home/claude/gamedata; P=/home/claude/rs_brutal22weaponsq/pk3
IWAD=/home/claude/gamedata_fd/freedoom-0.13.0/freedoom2.wad
( cd "$HERE/smdown" && rm -f "$B/smdown.pk3" && zip -q -r -X "$B/smdown.pk3" . )
( cd "$HERE/smchamp" && rm -f "$B/smchamp.pk3" && zip -q -r -X "$B/smchamp.pk3" . )
RSQ=""; for f in "$HUB"/pk3/RSQ_*.pk3; do case "$f" in *GunBonsaiVR*) ;; *) RSQ="$RSQ $f";; esac; done
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"; rm -f "$B/logs/$NAME.log"
cp "$RIG/config/qzdoom.ini" "$B/qzdoom.ini.bak"
FIRST=""; EXTRA=""; MODE=1
CON="+wait 1; notarget; screenblocks 10; vr_hud_scale 0.55; wait 19; qz_lstick \"0 1\"; wait 8; qz_lstick \"0 0\"; wait 42; qz_lstick \"0 1\"; wait 8; qz_lstick \"0 0\"; wait 572; vr_crouch_use_button 0; wait 430; quit"
if [ -n "$LD" ]; then FIRST="/mnt/user-data/uploads/1f3eb79e-LegenDoom_3.0.pk3"; EXTRA="$B/smchamp.pk3"; MODE=2; CON="+wait 1; notarget; screenblocks 10; vr_hud_scale 0.55; wait 200; quit"; fi
QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR="$D" QZ_RES=480 EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "$RIG/qz" -iwad "$IWAD" -file $FIRST "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" \
  "$P/03_BD22_VR-Reloaded_2.0.4.pk3" "$P/04_XMVE_MonsterExpansion1.3.1-BD22.pk3" "$P/05_XMVE_MonsterExpansion_TUD.pk3" \
  "$P/06_XMVE_MonsterExpansion_Doom2.pk3" "$P/07_XMVE_MonstersNoDropGuns-BD22.pk3" \
  $RSQ $EXTRA "$B/smdown.pk3" -nosound -warp 1 -skill 3 \
  +set dn_mode $MODE +logfile "$B/logs/$NAME.log" "$CON" > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
cp "$B/qzdoom.ini.bak" "$RIG/config/qzdoom.ini"
echo "script errors: $(grep -c 'Script error' "$B/logs/$NAME.log")"
