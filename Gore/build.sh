#!/bin/sh
# build.sh -- pack RSQ_Gore.pk3 (explicit include list). tools/ and generated/ stay out: they are the generator's input
# and its review files. The pk3's generated content (zscript/rsqgo/cards.zs and graphics/rsqgo/, the baked frames the
# tracks show) is written by tools/gen_gore.py; run it (and tools/gore_lint.py) before packing.
cd "$(dirname "$0")" && rm -f RSQ_Gore.pk3 && \
zip -q -r -X RSQ_Gore.pk3 zscript.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt README.md MODELDEF.residue MODELDEF.chunks TEXTURES.residue ANIMDEFS.residue GLDEFS.residue zscript graphics && echo "built RSQ_Gore.pk3"
