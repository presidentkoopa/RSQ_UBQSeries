#!/bin/bash
# frames.sh <name> <run.sh args...> -- one rig run with every frame dumped, kept as PNG (TEST ONLY; the PPM dumps go)
n=$1; shift
F=/home/claude/scratch/mlframes/$n; rm -rf $F; mkdir -p $F
QZ_DUMP_EVERY=1 QZ_DUMP_DIR=$F QZ_RES=${QZ_RES:-320} ./run.sh $n "$@"
python3 - "$F" <<'P'
import sys, glob, os
from PIL import Image
for f in glob.glob(sys.argv[1] + '/*.ppm'):
    Image.open(f).save(f[:-4] + '.png'); os.remove(f)
P
echo "frames: $(ls $F | wc -l) in $F"
