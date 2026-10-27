#!/bin/sh
# build.sh -- pack RSQ_TacticalRig.pk3 (explicit include list).
cd "$(dirname "$0")" && rm -f RSQ_TacticalRig.pk3 && \
zip -q -r -X RSQ_TacticalRig.pk3 zscript.txt RSQTRFIT.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt SNDINFO.txt TRNSLATE.txt MODELDEF.txt TEXTURES.txt GLDEFS.txt CREDITS.txt zscript sprites sounds models graphics 2>/dev/null; echo "built RSQ_TacticalRig.pk3"
