#!/bin/bash
# build_test.sh [out.pk3] -- TEST pk3: the shipped pk3/ tree plus the probe (never shipped).
set -e
ME="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rsqthp_test.pk3}"
T=$(mktemp -d)
cp -r "$ME"/pk3/. $T/
cp "$ME"/test/probe.zs $T/zscript/rsqthp/zz_probe.zs
echo '#include "zscript/rsqthp/zz_probe.zs"' >> $T/zscript.txt
cat "$ME"/test/probe_cvarinfo.txt >> $T/CVARINFO.txt
printf '\nGameInfo { AddEventHandlers = "RSQTHPT_Probe" }\n' >> $T/MAPINFO.txt
if [ -n "$TESTGR" ]; then   # the grapple yank probe: only with RSQ_Grapple loaded before this pk3
  cp "$ME"/test/probe_gr.zs $T/zscript/rsqthp/zz_probe_gr.zs
  echo '#include "zscript/rsqthp/zz_probe_gr.zs"' >> $T/zscript.txt
  printf 'server noarchive int thpt_yank = 0;\nserver noarchive int thpt_yankidx = 0;\n' >> $T/CVARINFO.txt
  printf 'GameInfo { AddEventHandlers = "RSQTHPT_Yank" }\n' >> $T/MAPINFO.txt
fi
rm -f "$OUT"; (cd $T && zip -q -r -X "$OUT" .)
rm -rf $T
echo "built $OUT"
