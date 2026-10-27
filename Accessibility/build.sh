#!/bin/sh
# build.sh -- pack RSQ_Accessibility.pk3 (explicit include list).
cd "$(dirname "$0")" && rm -f RSQ_Accessibility.pk3 && \
zip -q -r -X RSQ_Accessibility.pk3 zscript.txt CVARINFO.txt MENUDEF.txt CREDITS.txt zscript && echo "built RSQ_Accessibility.pk3"
