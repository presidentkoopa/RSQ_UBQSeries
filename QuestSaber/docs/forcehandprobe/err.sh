#!/bin/bash
# TEST ONLY: zero-script-error runs (no probe), doom2 MAP01
SP=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/fhprobe; RIG=/home/claude/g9/rigSB; R=/home/claude/RSQ_UBQSeries/pk3
GB=/home/claude/scratch/upg/GunBonsai-0.10.6.pk3; RSQ=$(ls $R/*.pk3 | tr '\n' ' ')
SC='god; ubqs_dual_mode 0; qz_lhand "-0.12 1.42 -0.38 30 0 0"; wait 70; openmenu UBQS_Options; wait 20; closemenu; wait 5; summon DoomImp; wait 5; +oh_altatk; wait 8; qz_lhand "-0.12 1.42 -0.62 30 0 0"; wait 10; -oh_altatk; qz_lhand "-0.12 1.42 -0.38 30 0 0"; ubqs_fhand_mesh 1; wait 20; +oh_altatk; wait 30; -oh_altatk; ubqs_fhand_mesh 0; wait 20; +oh_altatk; wait 30; -oh_altatk; ubqs_fhand_mesh 1; resetcvar ubqs_fhand_mesh; wait 5; ubqs_fhand_mesh; wait 35; quit'
run() { name=$1; shift; D=$SP/out/$name; rm -rf $D; mkdir -p $D
  cp $RIG/config/qzdoom.ini.orig $RIG/config/qzdoom.ini
  (cd $RIG && env QZ_RES=200 EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=$RIG timeout 580 ./qz -iwad /home/claude/iwad/doom2/doom2.wad -file "$@" -nosound -warp 1 -skill 3 +logfile $D/log "+$SC" > $D/out 2>&1)
  echo "$name rc=$? ours=$(grep -i -E 'script error|VM abort|Called from|Tried to access|Unknown identifier|division by zero|address zero' $D/log | grep -v -i voxel | wc -l) voxeldef=$(grep -i -c 'No sprites specified for voxel' $D/log) fhand=$(grep -i '"ubqs_fhand_mesh" is' $D/log | tail -1)"; }
run e_saber $R/RSQ_Saber.pk3
run e_gbrsq $GB $RSQ
L=/home/claude/scratch/lo2
run e_full $L/01_brutal22test6.pk3 $L/02_BD22_VoxelPack.pk3 /home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.3p.pk3 $L/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $L/05_XMVE_MonsterExpansion_TUD.pk3 $L/06_XMVE_MonsterExpansion_Doom2.pk3 $L/07_XMVE_MonstersNoDropGuns-BD22.pk3 $GB $RSQ
echo ERRDONE
