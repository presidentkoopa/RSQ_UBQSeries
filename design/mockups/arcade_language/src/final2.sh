#!/bin/bash
cd /home/claude/scratch/arcmock
B='bd_tips 0; screenblocks 12; crosshair 0; show_messages 0'
export QZ_RES=960
EVERY=1 ./run.sh R1 04 300 "$B; set am_atk 30; set am_spawn \"DoomImp 300 10;ShotgunGuy 240 -170;ZombieMan 380 170\"; wait 26; freeze; wait 45; freeze; wait 7; freeze; wait 45; freeze; wait 7; freeze; wait 45; freeze; wait 30; kill monsters; wait 60; freeze; wait 45; quit"
EVERY=1 ./run.sh R2 02 240 "$B; set am_spawn \"DoomImp 260 -60;DoomImp 300 150;DoomImp 280 -200\"; wait 52; freeze; wait 50; netevent am_hide -1; wait 45; quit"
EVERY=1 ./run.sh R3 04 300 "$B; set am_pos \"670 -40 270\"; set am_spawn \"ExplosiveBarrel 200 -40;ZombieMan 330 -60;ShotgunGuy 380 50;ZombieMan 300 120;DoomImp 420 -10\"; wait 34; freeze; wait 45; netevent am_hide 0; wait 40; netevent am_hide 0; freeze; wait 8; kill monsters; wait 5; freeze; wait 45; quit"
