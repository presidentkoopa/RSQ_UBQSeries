#!/bin/bash
# build_test.sh [out.pk3] -- TEST pk3: this branch (which already carries core's merged files,
# or, before core's first commit, core's working tree overlaid from $CORE), my fragments in
# marked blocks, plus the harness (never shipped). Usage: CORE=/path/to/core build_test.sh out.pk3
set -e
ME="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-/tmp/rsqgr_test.pk3}"
T=$(mktemp -d)
if [ -n "$CORE" ]; then
  (cd "$CORE" && tar cf - --exclude=.git --exclude=jp_original --exclude='*.pk3' .) | (cd $T && tar xf -)
  cp "$ME"/zscript/rsqgr/monster.zs "$ME"/zscript/rsqgr/looks.zs "$ME"/zscript/rsqgr/whip.zs $T/zscript/rsqgr/
  cp -r "$ME"/sounds "$ME"/models "$ME"/sprites $T/
  F="$ME/test/fragments"
  cat $F/CVARINFO.txt >> $T/CVARINFO.txt
  cat $F/SNDINFO.txt >> $T/SNDINFO.txt
  cat $F/MAPINFO.txt >> $T/MAPINFO.txt
  cat $F/MODELDEF.txt >> $T/MODELDEF.txt
  cat $F/zscript.txt >> $T/zscript.txt
  cat $F/MENUDEF_values.txt >> $T/MENUDEF.txt
  python3 - "$T/MENUDEF.txt" "$F" <<'PY'
import sys
p,f=sys.argv[1],sys.argv[2]; s=open(p).read()
main=open(f+'/MENUDEF_main.txt').read(); tun=open(f+'/MENUDEF_tuning.txt').read()
k='\tSubmenu "Rope and Tuning", "RSQGR_Tuning"'; assert k in s; s=s.replace(k, main+k,1)
k='\tOption "Debug Log", "rsqgr_debug", "OnOff"'; assert k in s; s=s.replace(k, tun+k,1)
open(p,'w').write(s)
PY
else
  (cd "$ME" && tar cf - --exclude=.git --exclude=jp_original --exclude=test --exclude='*.pk3' .) | (cd $T && tar xf -)
fi
cp "$ME/test/harness.zs" $T/zscript/rsqgr_harness.zs
echo '#include "zscript/rsqgr_harness.zs"' >> $T/zscript.txt
cat "$ME/test/harness_cvarinfo.txt" >> $T/CVARINFO.txt
printf '\nGameInfo { AddEventHandlers = "RSQGRH_Harness" }\n' >> $T/MAPINFO.txt
rm -f "$OUT"; (cd $T && zip -q -r -X "$OUT" .)
rm -rf $T
echo "built $OUT"
