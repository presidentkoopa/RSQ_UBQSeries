#!/bin/bash
# rc3_run.sh NAME CLASS ON(1/0): TEST ONLY. The sheet run for one class (rc3demo), the art on (rsrc_on 1) or the live tint
# only (0). ART: the art pk3s (rsrecolour/ split in two by colour: one zip holds at most 65,535 entries); RC3DEMO: rc3demo
# zipped. The two halves (as shipped..Yellow, FireBlu..White): front, side, attack, a plain death frozen mid-fall, dead.
N=$1; C=$2; ON=$3
H(){ echo "netevent rc3_row -140 52 $1;wait 3;netevent rc3_tier;netevent rc3_calm;wait 45;netevent rc3_face 0 0;netevent rc3_mark 1$2;wait 40;netevent rc3_face 90 0;netevent rc3_mark 2$2;wait 40;netevent rc3_attack ${ATK:-4};netevent rc3_mark 3$2;wait 40;netevent rc3_kill 0 ${KF:-10};netevent rc3_mark 4$2;wait 50;netevent rc3_go;netevent rc3_mark 5$2;wait 80;netevent rc3_mark 6$2;wait 12"; }
SC="god;notarget;wait 40;netevent rc3_clean 1;netevent rc3_light 224;netevent rc3_cls_$C;$(H 701 1);$(H 608 2);wait 10;quit"
EVERY=${EVERY:-2} EXTRA="+set ue_recolour 0 +set rsqls_on 0 +set rsqthp_on 0 +set r_drawplayersprites 0 +set rsrc_on $ON +set sv_cheats 1" \
 flock /home/claude/rig.lock bash "$(dirname "$(readlink -f "$0")")/rc2_full.sh" $N 400 "$SC" \
 ${ART:?the art pk3s} /home/claude/wt_recolour/TestRig/maps/rig01.wad ${RC3DEMO:-/home/claude/scratch_rcA/rc3demo.pk3}
T=/home/claude/rig/work/runs/$N; grep -a "RC3\|rc3\|RSRC" $T/run.log | head -40
