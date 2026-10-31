#!/bin/bash
# TEST ONLY (never ships): pack RSQ_Gestures.pk3 (the build_all.sh list) and the probe into build/
T="$(cd "$(dirname "$0")" && pwd)"; G="$(dirname "$(dirname "$T")")"; B="$T/build"; mkdir -p "$B"
rm -f "$B/RSQ_Gestures.pk3" "$B/gprobe.pk3"
(cd "$G" && zip -q -r -X "$B/RSQ_Gestures.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt CREDITS.txt README.md zscript)
(cd "$T/gprobe" && zip -q -r -X "$B/gprobe.pk3" .)
echo "built $B/RSQ_Gestures.pk3 $B/gprobe.pk3"
