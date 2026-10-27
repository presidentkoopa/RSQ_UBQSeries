#!/bin/sh
# TEST ONLY, never ships: builds grprobe.pk3 (probe handler + GRTEST map) next to this script.
cd "$(dirname "$0")" && mkdir -p probe/maps && python3 mkmap.py probe/maps/GRTEST.wad && \
cd probe && rm -f ../grprobe.pk3 && zip -q -r ../grprobe.pk3 . && echo "built grprobe.pk3"
