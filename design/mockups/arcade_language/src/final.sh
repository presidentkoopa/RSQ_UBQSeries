#!/bin/bash
cd /home/claude/scratch/arcmock
B='bd_tips 0; screenblocks 12; crosshair 0; show_messages 0'
export QZ_RES=960
EVERY=1 ./run.sh F1 04 220 "$B; set am_atk 35; set am_spawn \"DoomImp 330 20;ShotgunGuy 260 -170;ZombieMan 400 170\"; wait 80; kill monsters; wait 70; quit"
EVERY=1 ./run.sh F2 02 200 "$B; set am_spawn \"DoomImp 380 -40;DoomImp 450 170;DoomImp 420 -230\"; wait 46; freeze; wait 14; netevent am_mask -1 16711935; wait 10; netevent am_mask -2 65280; wait 10; quit"
EVERY=1 ./run.sh F3 04 240 "$B; set am_pos \"670 -40 270\"; set am_spawn \"ExplosiveBarrel 230 60;ZombieMan 330 -60;ShotgunGuy 380 50;ZombieMan 300 120;DoomImp 420 -10\"; wait 40; freeze; wait 14; netevent am_mask 0 16711935; wait 10; netevent am_unmask; freeze; wait 20; kill monsters; wait 6; freeze; wait 14; quit"
EVERY=2 EXTRAFILES=/home/claude/rsq_ubqseries/pk3/RSQ_VisualRewards.pk3 ./run.sh F5 04 220 "$B; set rsqthp_on 0; set rsqthp_dmg 0; set rsqgb_kr_amount 2; set rsqgb_kr_chance 100; set rsqgb_kr_magnet 0; set rsqthp_lvl 0; set am_pos \"640 900 270\"; set am_spawn \"DoomImp 260 -140;DoomImp 330 30;ZombieMan 230 160;ShotgunGuy 380 -40;DoomImp 420 200;ZombieMan 300 -260\"; wait 30; kill monsters; wait 22; freeze; wait 16; quit"
EVERY=4 ./run.sh F6 04 120 "$B; set am_pos \"1990 640 0\"; wait 50; quit"
