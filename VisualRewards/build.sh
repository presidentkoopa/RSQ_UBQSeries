#!/bin/sh
# build.sh -- regenerate the art from coldcite's originals, then pack RSQ_VisualRewards.pk3 from pk3/ (RSQ VisualRewards;
# until 2026-11-03 this folder was TopHPBars and built RSQ_HPBars.pk3).
# original_1.04/ is the source art.
set -e
cd "$(dirname "$0")"
python3 tools/gen_art.py
python3 tools/gen_dn_art.py
rm -f RSQ_VisualRewards.pk3
(cd pk3 && zip -q -r -X ../RSQ_VisualRewards.pk3 .)
echo "built RSQ_VisualRewards.pk3"
