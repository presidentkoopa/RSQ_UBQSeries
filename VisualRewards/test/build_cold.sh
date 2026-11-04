#!/bin/bash
# build_cold.sh -- TEST ONLY: coldcite's unmodified 1.04 as a pk3 (coexistence test) and his cost probe.
set -e
ME="$(cd "$(dirname "$0")/.." && pwd)"
SC=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad
rm -f $SC/coldcite_1.04.pk3 $SC/coldbench.pk3
(cd "$ME/original_1.04" && zip -q -r -X $SC/coldcite_1.04.pk3 .)
T=$(mktemp -d); mkdir -p $T/zscript
cp "$ME/test/probe_cold.zs" $T/zscript/coldbench.zs
printf 'version "4.14"\n#include "zscript/coldbench.zs"\n' > $T/zscript.txt
printf 'GameInfo { AddEventHandlers = "RSQTHPT_ColdBench" }\n' > $T/MAPINFO.txt
(cd $T && zip -q -r -X $SC/coldbench.pk3 .); rm -rf $T
echo "built $SC/coldcite_1.04.pk3 $SC/coldbench.pk3"
