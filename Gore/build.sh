#!/bin/sh
# build.sh -- pack RSQ_Gore.pk3 (explicit include list). tools/ and generated/ stay out: they are the generator's input
# and output, read at build time, never at run time.
cd "$(dirname "$0")" && rm -f RSQ_Gore.pk3 && \
zip -q -r -X RSQ_Gore.pk3 zscript.txt MAPINFO.txt CVARINFO.txt README.md zscript && echo "built RSQ_Gore.pk3"
