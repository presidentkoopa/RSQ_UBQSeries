#!/bin/sh
# build.sh -- regenerate the art from coldcite's originals, then pack RSQ_TopHPBars.pk3 from pk3/.
# original_1.04/ is the source art.
set -e
cd "$(dirname "$0")"
python3 tools/gen_art.py
rm -f RSQ_TopHPBars.pk3
(cd pk3 && zip -q -r -X ../RSQ_TopHPBars.pk3 .)
echo "built RSQ_TopHPBars.pk3"
