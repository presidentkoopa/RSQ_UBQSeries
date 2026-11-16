#!/bin/bash
S=/home/claude/scratch_plusex
mkdir -p $S/frames
run() { B=$1; shift; EVERY=${EVERY:-10} SECS=${SECS:-600} $S/run5.sh $B "$@" | head -1
  R=/home/claude/rig/work/runs/plusex_${TAG:-}$B; mkdir -p $S/frames/${TAG:-}$B; rm -f $S/frames/${TAG:-}$B/*
  python3 -I -c "
import glob,os,sys
from PIL import Image
fs=sorted(glob.glob('$R/frames/*.ppm'))
for f in fs:
    Image.open(f).convert('RGB').save('$S/frames/${TAG:-}$B/'+os.path.basename(f)[:-4]+'.jpg',quality=70)
print(len(fs),'frames')"
  find $R/frames -name '*.ppm' -delete
  cp $R/run.log $S/frames/${TAG:-}$B/run.log
  echo "$B errors: $(grep -a -c 'Script error' $R/run.log) vm: $(grep -a -c -i 'VM abort\|Execution could not' $R/run.log)"; }
"$@"
