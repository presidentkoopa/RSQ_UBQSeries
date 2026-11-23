#!/bin/sh
# build.sh -- pack RSQ_Miniboss.pk3 (explicit include list).
cd "$(dirname "$0")" && rm -f RSQ_Miniboss.pk3 && \
zip -q -r -X RSQ_Miniboss.pk3 zscript.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt CREDITS.txt README.md MODELDEF.txt VOXELDEF.txt TRNSLATE.txt SNDINFO.txt KEYCONF.txt zscript graphics models sprites voxels && echo "built RSQ_Miniboss.pk3"
