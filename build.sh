#!/bin/sh
# build.sh -- pack RSQ_LaserSight.pk3 (explicit include list; the Linux twin of build.ps1).
# tools/ and docs/ stay out: tools WRITE lumps, docs are prose.
cd "$(dirname "$0")" && rm -f RSQ_LaserSight.pk3 && \
zip -q -r -X RSQ_LaserSight.pk3 zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt MODELDEF.txt \
	VOXELDEF.txt ANIMDEFS.txt zscript sprites models/rsqls && echo "built RSQ_LaserSight.pk3 ($(du -k RSQ_LaserSight.pk3 | cut -f1) KB)"
