#!/bin/bash
# TEST ONLY (never ships). How often slow motion starts (smfreq probe), on the real qzd17.3 rig via tools/rig17/run17.sh.
#   smfreq.sh <name> <secs> "<console script>"
#     ORDER=full  (default) doom2 + /home/claude/scratch/lo2 01-07 + Gun Bonsai + every pk3/ RSQ pk3
#     ORDER=alone doom2 + RSQ_SlowMo only      ORDER=melee doom2 + SlowMo + Melee
#     SM=<pk3>    test another SlowMo build (e.g. the "before" copy) in place of pk3/RSQ_SlowMo.pk3
# Log: /home/claude/scratch/logs/<name>.log
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; MOD="$(dirname "$(dirname "$HERE")")"; HUB="$(dirname "$MOD")"
B="$HERE/build"; mkdir -p "$B"
NAME=$1; SECS=$2; SCRIPT=$3
( cd "$HERE/smfreq" && rm -f "$B/smfreq.pk3" && zip -q -r -X "$B/smfreq.pk3" . )
SM=${SM:-$HUB/pk3/RSQ_SlowMo.pk3}
LO=/home/claude/scratch/lo2
RSQ=$(ls $HUB/pk3/RSQ_*.pk3 | grep -v RSQ_SlowMo.pk3 | tr '\n' ' ')
case "${ORDER:-full}" in
  full)  FILES="$LO/01_brutal22test6.pk3 $LO/02_BD22_VoxelPack.pk3 $LO/03_BD22_VR-Reloaded_2.0.3j.pk3 $LO/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $LO/05_XMVE_MonsterExpansion_TUD.pk3 $LO/06_XMVE_MonsterExpansion_Doom2.pk3 $LO/07_XMVE_MonstersNoDropGuns-BD22.pk3 ${GB:-/home/claude/scratch/upg/GunBonsai-0.10.6.pk3} $RSQ $SM ${EXTRA:-}";;
  alone) FILES="$SM ${EXTRA:-}";;
  melee) FILES="$SM $HUB/pk3/RSQ_Melee.pk3 ${EXTRA:-}";;
esac
[ -n "${NOPROBE:-}" ] || FILES="$FILES $B/smfreq.pk3"
sed -i -E '/^(rsqsm_|rsm_|rsqml_|rs_score|rsqmb_|smf_)/d' /home/claude/g9/rig/config/qzdoom.ini 2>/dev/null
PK3S="$FILES" IWAD=/home/claude/iwad/doom2/doom2.wad bash "$HUB/tools/rig17/run17.sh" "$NAME" "$SECS" "$SCRIPT"
L=/home/claude/scratch/logs/$NAME.log
echo "log=$L"
echo "script errors (not BD_VoxelPack's voxeldef): $(grep 'Script error' "$L" | grep -v -c 'VoxelPack.pk3:voxeldef')"
grep -E "errors? while compiling|Attempt to|Unknown identifier|VM execution aborted|Script error" "$L" | grep -v voxeldef | head -10
