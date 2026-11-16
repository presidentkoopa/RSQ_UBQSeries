#!/bin/sh
# build.sh -- pack RSQ_SlowMo.pk3 (explicit include list; keep it in step with tools/build_all.py. 11-16: graphics/,
# TEXTURES.txt, TRNSLATE.txt and README.md were missing, so a pk3 built here had no DOWN plate art: "Material RSPWHT not found").
cd "$(dirname "$0")" && rm -f RSQ_SlowMo.pk3 && \
zip -q -r -X RSQ_SlowMo.pk3 zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt MODELDEF.txt GLDEFS.txt TEXTURES.txt TRNSLATE.txt CREDITS.txt README.md zscript graphics sprites sounds models && echo "built RSQ_SlowMo.pk3"
