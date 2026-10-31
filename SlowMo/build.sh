#!/bin/sh
# build.sh -- pack RSQ_SlowMo.pk3 (explicit include list).
cd "$(dirname "$0")" && rm -f RSQ_SlowMo.pk3 && \
zip -q -r -X RSQ_SlowMo.pk3 zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt MODELDEF.txt GLDEFS.txt CREDITS.txt zscript sprites sounds models && echo "built RSQ_SlowMo.pk3"
