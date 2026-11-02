#!/bin/bash
# run.sh <name> <bd|alone> "<extra pk3s>" "<console script>" -- one rig run of RSQ_Melee + the probe (doom2 MAP01)
R=/home/claude/RSQ_UBQSeries; T=$R/Melee/tools/rigtest
(cd $T/probe && rm -f ../probe.pk3 && zip -q -r ../probe.pk3 .)
sed -i -E '/^(rsqml_|rsqg_|rsq_|rsqdg_|mlp_|rs_score|rsm_|rsqsm_|qz_)/d' /home/claude/g9/rig/config/qzdoom.ini
LO=""; if [ "$2" = bd ]; then LO="$(ls /home/claude/scratch/lo2/0*.pk3 | tr '\n' ' ')"; fi
PK3S="$LO ${MELEE:-$R/pk3/RSQ_Melee.pk3} $3 $T/probe.pk3" IWAD=/home/claude/iwad/doom2/doom2.wad bash $R/tools/rig17/run17.sh $1 ${SECS:-60} "$4" >/dev/null
L=/home/claude/scratch/logs/$1.log
echo "== $1 errors:"; grep -v GL_EXT $L | grep -iE "script error|VM abort|exception|unknown (class|actor)|tried to|error" | grep -v "No sprites specified for voxel" | head
