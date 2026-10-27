#!/bin/sh
# build.sh -- pack RSQ_Grapple.pk3 (explicit include list; jp_original/ is source material and does not ship).
cd "$(dirname "$0")" && rm -f RSQ_Grapple.pk3 && \
zip -q -r -X RSQ_Grapple.pk3 zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt CREDITS.txt zscript sprites sounds && echo "built RSQ_Grapple.pk3"
