#!/bin/bash
# usage: test.sh "<console command string>"   -> packs, runs, and on a timeout screenshots the window
cd /home/claude/work && rm -f UltraBadassShieldSaw.pk3 && (cd RS_ShieldSawQ && zip -q -r ../UltraBadassShieldSaw.pk3 . -x '.git/*' 'docs/*' 'build.sh' '.gitignore' 'README.md')
cd /home/claude/ref/run
export LD_LIBRARY_PATH=/home/claude/ref/build/zmusic/inst/lib
pgrep -x Xvfb >/dev/null || (Xvfb :78 -screen 0 1024x768x24 >/dev/null 2>&1 &); sleep 1
DISPLAY=:78 stdbuf -o0 ./qzdoom -iwad /home/claude/ref/iwad/freedoom-0.13.0/freedoom2.wad -file /home/claude/work/UltraBadassShieldSaw.pk3 -nosound -nostartup -warp 1 +ssq_debug 1 +sv_cheats 1 "+$1" -config /home/claude/ref/run/qzd.ini > run.log 2>&1 &
PID=$!
LIMIT=${2:-90}
for i in $(seq 1 $LIMIT); do sleep 1; kill -0 $PID 2>/dev/null || break; done
if kill -0 $PID 2>/dev/null; then
  DISPLAY=:78 import -window root /home/claude/ref/run/stuck.png
  kill $PID 2>/dev/null
  echo "DID NOT FINISH in ${LIMIT}s -> stuck.png"
else
  echo "finished"
fi
grep -n -i 'ssq:\|script error\|abort\|VM \|unknown\|fatal' run.log | grep -v 'pw.conf\|ALSOFT' | head -30
