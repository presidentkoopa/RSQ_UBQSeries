#!/bin/sh
# build.sh -- pack RSQ_Score.pk3 (explicit include list; the Linux twin of build.ps1).
cd "$(dirname "$0")" && rm -f RSQ_Score.pk3 && \
zip -q -r -X RSQ_Score.pk3 zscript.txt MAPINFO.txt CVARINFO.txt SNDINFO.txt TEXTCOLO.txt MENUDEF.txt RSSCFON.fon2 RSSCFN2.fon2 zscript sounds graphics 2>/dev/null; echo "built RSQ_Score.pk3"
