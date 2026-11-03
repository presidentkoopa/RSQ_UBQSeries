#!/bin/bash
# TEST ONLY: melee_run.sh <name> <script file> -- RSQ Melee's own probe (case 4, the headlock) + RSQ Miniboss + bossprobe, doom2 MAP01
M0=$(cd "$(dirname "$0")" && pwd); R=$(cd "$M0/../../.." && pwd); T=$R/Melee/tools/rigtest; M=$R/Miniboss/tools/rigtest
(cd $T/probe && rm -f ../probe.pk3 && zip -q -r ../probe.pk3 .)
"$M/run.sh" "$1" ${SECS:-60} "$R/pk3/RSQ_Melee.pk3 $R/pk3/RSQ_Miniboss.pk3 $M/bossprobe.pk3 $T/probe.pk3" "$(cat "$2")"
