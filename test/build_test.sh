#!/bin/bash
# build_test.sh [out.pk3] -- TEST pk3: the shipped files (build.sh's include list) plus the
# harness (test/harness.zs, never shipped).
set -e
ME="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-/tmp/rsqgr_test.pk3}"
T=$(mktemp -d)
cd "$ME"
cp -r zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt CREDITS.txt MODELDEF.txt zscript sprites sounds models $T/
cp test/harness.zs $T/zscript/rsqgr_harness.zs
echo '#include "zscript/rsqgr_harness.zs"' >> $T/zscript.txt
cat test/harness_cvarinfo.txt >> $T/CVARINFO.txt
printf '\nGameInfo { AddEventHandlers = "RSQGRH_Harness" }\n' >> $T/MAPINFO.txt
rm -f "$OUT"; (cd $T && zip -q -r -X "$OUT" .)
rm -rf $T
echo "built $OUT"
