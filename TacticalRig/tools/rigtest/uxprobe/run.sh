#!/bin/bash
# TEST ONLY (never ships). The 11-08 new-player changes (rules shown, free by hand, buzz vocabulary, overlap, auto height, tip, diamond, pulse), on the QZD 17.3 rig.
#   run.sh <name> <secs> "<console script>|-norun" [alone]
# Order (full): doom2 -> brutal22test6 -> LOB -> BD_VoxelPack -> newest BD22 VR -> XMVE 04-07 -> Champions -> RSQ pk3s
# (other lanes' from git HEAD, staged in $T/head; this checkout's RSQ_TacticalRig.pk3). "alone": doom2 + the Rig only.
# Frames (QZ_DUMP_EVERY) in $T/frames/<name>, log in $T/logs/<name>.log. The probe (zscript.txt here) is loaded last
# unless NOPROBE=1.
set -u
NAME=$1; SECS=$2; SCRIPT=$3; MODE=${4:-full}
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../../.." && pwd)"
T=${T:-/home/claude/scratch/trux}; G=/home/claude/gamedata; BD=/home/claude/rs_brutal22weaponsq/pk3
RIG=/home/claude/rsq_weapondepot/tools/rig/bin
PROBEDIR=${PROBEDIR:-$HERE}   # fire/: the rig-version-free fire probe (item 3, A/B against git HEAD)
mkdir -p $T/logs $T/frames; (cd "$PROBEDIR" && rm -f $T/truxprobe.pk3 && zip -qr $T/truxprobe.pk3 zscript.txt MAPINFO.txt $(ls CVARINFO.txt 2>/dev/null))
files=()
if [ "$MODE" = full ]; then
  files+=($G/brutal22test6.pk3 $G/LOB_v1.05.pk3 $G/BD_VoxelPack.pk3 "$(ls -t $BD/03_BD22_VR*.pk3 | head -1)")
  for f in $BD/0[4-7]_XMVE*.pk3; do files+=("$f"); done
  files+=($G/mk-champions20210309.pk3)
  for f in $T/head/RSQ_*.pk3; do case $(basename $f) in RSQ_GunBonsaiVR.pk3|RSQ_Graveyard.pk3) ;; *) files+=("$f");; esac; done
fi
files+=("${RIGPK3:-$REPO/pk3/RSQ_TacticalRig.pk3}")   # RIGPK3: another build of the Rig (e.g. git HEAD's, for an A/B)
[ -z "${NOPROBE:-}" ] && files+=($T/truxprobe.pk3)
D=$T/frames/$NAME; rm -rf $D; mkdir -p $D; rm -f $T/logs/$NAME.log
# the disk is small: frame dumps become PNGs as they come (squeeze.sh)
SQ=/home/claude/scratch/trux/tools/squeeze.sh; [ -x $SQ ] && { $SQ $D & SQPID=$!; }
if [ "$SCRIPT" = "-norun" ]; then extra=(-norun); else extra=(-warp 1 -skill 3 "+$SCRIPT"); fi
QZ_DUMP_EVERY=${EVERY:-0} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout $SECS "$RIG/qz" -iwad $G/doom2.wad -file "${files[@]}" -nosound ${EXTRA:-} \
  +logfile $T/logs/$NAME.log "${extra[@]}" > $T/logs/$NAME.out 2>&1
RC=$?; [ -n "${SQPID:-}" ] && { touch $D/.stop; wait $SQPID; rm -f $D/.stop; }
echo "rc=$RC frames=$(ls $D | wc -l) log=$T/logs/$NAME.log files=${#files[@]}"
(cd "$RIG/.." && git checkout -q bin/config/qzdoom.ini 2>/dev/null)
echo "script errors: $(grep -c 'Script error' $T/logs/$NAME.log)"
