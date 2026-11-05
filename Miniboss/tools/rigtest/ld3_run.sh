#!/bin/bash
# TEST ONLY (2026-11-04): RSQ Miniboss with full LegenDoom 3.0 vs LegenDoom Lite 4.2, on the owner's full order:
#   doom2 -> lo2 01-07 (03 = newest rs_brutal22weaponsq/pk3/03_*) -> Gun Bonsai 0.10.6 -> LegenDoom (3.0 or Lite 4.2)
#   -> Champions (mk-champions 2021-03-09) -> LDL_BD22VR_Patch -> every RSQ pk3 -> ld3probe (last)
#   ld3_run.sh <name> <ld3|ldl|none> [secs]     MB=<RSQ_Miniboss.pk3 to test> (default pk3/RSQ_Miniboss.pk3)
#   NOPATCH=1 leaves the LDL patch out; ALONE=1 loads doom2 + Miniboss (+ LegenDoom when asked) + probe only.
# Log: /home/claude/scratch/logs/<name>.log. Rig only, not headset-confirmed.
T=$(cd "$(dirname "$0")" && pwd); R=$(cd "$T/../../.." && pwd)
NAME=$1; V=$2; SECS=${3:-150}
SC=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/mbld3
mkdir -p $SC; rm -f $SC/ld3probe.pk3; (cd $T/ld3probe && zip -q -r -X $SC/ld3probe.pk3 .)
case $V in
  ld3) LD=/mnt/user-data/uploads/Desktop/LegenDoom_3.0.pk3;;
  ldl) LD=/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca/a95b1a86-LegenDoomLite_4.2.pk3.zip;;
  *)   LD="";;
esac
CH=/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca/a09b1892-mk-champions20210309.pk3
PP=/home/claude/rs_brutal22weaponsq/pk3/LDL_BD22VR_Patch.pk3; [ -n "${NOPATCH:-}" ] && PP=""
MB=${MB:-$R/pk3/RSQ_Miniboss.pk3}
VR=$(ls /home/claude/rs_brutal22weaponsq/pk3/03_*.pk3 | sort | tail -1)
LO="/home/claude/scratch/lo2/01_brutal22test6.pk3 /home/claude/scratch/lo2/02_BD22_VoxelPack.pk3 $VR $(ls /home/claude/scratch/lo2/0[4-7]*.pk3 | tr '\n' ' ')"
ALL="$(ls $R/pk3/RSQ_*.pk3 | grep -v RSQ_Miniboss.pk3 | tr '\n' ' ') $MB"
if [ -n "${ALONE:-}" ]; then L="$LD $MB $SC/ld3probe.pk3"
else L="$LO /home/claude/scratch/upg/GunBonsai-0.10.6.pk3 $LD $CH $PP $ALL $SC/ld3probe.pk3 ${EXTRA:-}"; fi
S=${SCRIPT:-$(cat $T/ld3_script.txt)}
exec 9>/home/claude/rig.lock; flock -x 9
sed -i -E '/^(rsqmb_|rsqgb_|rsldp_|mbx_|LD_|ld_|champion_|qz_)/Id' /home/claude/g9/rig/config/qzdoom.ini
PK3S="$L" IWAD=/home/claude/iwad/doom2/doom2.wad bash $R/tools/rig17/run17.sh "$NAME" "$SECS" "$S" >/dev/null
LG=/home/claude/scratch/logs/$NAME.log
echo "== $NAME ($V): $(echo $VR | xargs basename); script errors (not voxeldef): $(grep -i -E 'script error|VM abort|exception|errors while compiling|Execution could not continue' $LG | grep -v -i voxeldef | wc -l), voxeldef lines $(grep -c -i 'No sprites specified for voxel' $LG)"
grep -i -E "script error|VM abort|exception|Called from|errors while compiling|Unknown class|Execution could not continue" $LG | grep -v -i voxeldef | head -12
