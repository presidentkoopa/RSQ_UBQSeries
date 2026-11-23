#!/bin/sh
# build.sh -- pack RSQ_Miniboss.pk3 (explicit include list).
cd "$(dirname "$0")" && rm -f RSQ_Miniboss.pk3 && \
zip -q -r -X RSQ_Miniboss.pk3 zscript.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt CREDITS.txt README.md MODELDEF.txt VOXELDEF.txt TRNSLATE.txt SNDINFO.txt KEYCONF.txt DECORATE CVARINFO.ldlite MENUDEF.ldlite SNDINFO.ldlite LANGUAGE.ldlite GLDEFS.ldlite CREDITS.ldlite zscript graphics models sprites voxels decorate filter sounds && echo "built RSQ_Miniboss.pk3"
