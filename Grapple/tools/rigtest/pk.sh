#!/bin/sh
# TEST ONLY: repack pk3/RSQ_Grapple.pk3 alone, with build_all.sh's include list for Grapple.
cd "$(dirname "$0")/../.." && rm -f ../pk3/RSQ_Grapple.pk3 && \
zip -q -r -X ../pk3/RSQ_Grapple.pk3 zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt CREDITS.txt MODELDEF.txt zscript sprites sounds models && echo "packed pk3/RSQ_Grapple.pk3"
