#!/bin/bash
# TEST ONLY. Side-by-side shots for the port: no glow mod / 1.1 / this port, random and fixed colours.
cd "$(dirname "$0")"
NEW=/home/claude/RSQ_UBQSeries/pk3/RSQ_GlowInTheDark.pk3
OLD=/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca/4eb37ffb-Environmental_Lighting03_GlowInTheDark.pk3
while read tag map x y a; do
  ./shoot.sh ${tag}_none $map $x $y $a "echo none"
  ./shoot.sh ${tag}_old $map $x $y $a "echo old" $OLD
  ./shoot.sh ${tag}_new $map $x $y $a "rsqgd_debug 1" $NEW
  ./shoot.sh ${tag}_oldfix $map $x $y $a "color_ovrand 1" $OLD
  ./shoot.sh ${tag}_newfix $map $x $y $a "rsqgd_fixed 1" $NEW
  ./shoot.sh ${tag}_new11 $map $x $y $a "rsqgd_fixed 1; rsqgd_liquid_own 0" $NEW
done <<'SPOTS'
m02 2 900 1100 60
m11 11 200 1500 45
m22 22 -600 480 45
m25 25 -800 250 60
m09 9 100 150 45
m11w 11 -400 1900 180
SPOTS
