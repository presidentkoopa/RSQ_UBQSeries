#!/bin/bash
# full_monA.sh <name> <secs> "<script>" [extra files] : the owner's full order, his saved ini (mod cvars merged into the
# rig's own ini; monA/owner_base.ini), Black Metal (-skill 6), Q = the monster-tiering worktree /home/claude/wt_monA
N=$1; S=$2; SC=$3; shift 3
M=/home/claude/presidentkoopa/rsq_meshturbator; RIG=$M/rig/bin; U=/mnt/user-data/uploads; B=/home/claude/presidentkoopa/rsq_bd_vr_reloaded; Q=/home/claude/wt_whipdoc
BDVR=${BDVR:-/home/claude/rsq_bd_vr_reloaded/pk3/03_BD22_VR-Reloaded_2.0.4x.pk3}
T=/home/claude/rig/work/runs/wp13_$N; mkdir -p $T/frames; find $T/frames -name '*.ppm' -delete
cp /home/claude/rig/work/monA/owner_base.ini $T/config.ini
OWN="+set champion_OverrideChance -1 +set champion_Mutations 25 +set champion_dormant 1 +set champion_booster 1 +set champion_legendoom 1 +set champion_Colours 1 +set LD_legendarychance 1 +set LD_legendarymonsters 1 +set ue_recolour 5 +set ue_resize 0 +set csh_headshot_enabled false +set LOB_Respawn 2 +set rs_score_startmode 2 +set rsqmb_bf_cap 2 +set bonsai_base_level_cost 750 +set bonsai_gun_levels_per_player_level 2 +set rsq_monster_set 1 +set rsqtr_eye_m 1.6"
cd $RIG
ALSOFT_DRIVERS=null QZ_DUMP_EVERY=${EVERY:-10} QZ_DUMP_DIR=$T/frames QZ_RES=${RES:-480} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
 timeout $S ./qz -config $T/config.ini -iwad /home/claude/rig/packs/doom2.wad -file $Q/WADs/TUD_NoEndInSight_.wad $U/975b943c-0.99-LegenDoom_3.0.pk3 $U/1_00_brutal22test6.pk3 \
 $B/pk3/02_BD22_VoxelPack.pk3 $BDVR $B/pk3/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $B/pk3/06_XMVE_MonsterExpansion_Doom2.pk3 $B/pk3/05_XMVE_MonsterExpansion_TUD.pk3 $B/pk3/07_XMVE_MonstersNoDropGuns-BD22.pk3 \
 $U/eea375c1-2.1-Enemies_LegionOfBones_v1.05.pk3 $U/4ee2f317-2.2-Enemies-mk-champions20210309.pk3 $U/3be205c2-2.3-Enemies_NoMoreHitscans-main.zip $U/4f980dcf-2.4-Enemies_UniversalEntropy.pk3 $U/0092a05c-2.5-Enemies_SpawnAdjuster_SliderBar10.5.zip \
 $U/628af564-3.01-Environmental_BloomBoost.pk3 $U/3691af8a-3.02-Environmental_Subtlelights.pk3 $U/21d6728e-3.03-Environmental_LiveReverb.pk3 $U/674fb083-3.04-Environmental_MTOLiquids.pk3 $U/82b0e39b-3.05-Environmental_NiceWallBlood.pk3 $U/18865c66-3.06-Environmental_OpenWindows.pk3 $U/7b4c8f9c-3.07-Environmental_UA_AmbientDecorations.pk3 $U/b5b2ded4-3.08-Environmental_UA_CosmoAmbienceScript_edited.pk3 $U/c8e835c8-3.09-Environmental_UA_UniversalAmbience.pk3 \
 $U/a17683ac-4.01-Gameplay_CriticalHitsAmdHeadshots_mk-crits.pk3 $U/660cd406-4.02-Gameplay_RegenShield.zip $U/49bb603b-4.03-Gameplay_ShotgunSpawner.wad $U/c3dc8315-4.04-Gameplay_GunBonsai-0.10.6.pk3 \
 $(ls $Q/pk3/RSQ_*.pk3 | tr '\n' ' ') "$@" -nomusic +logfile $T/run.log -warp ${MAP:-01} -skill ${SKILL:-6} +set sv_cheats 1 $OWN $EXTRA "+$SC" </dev/null >$T/run.out 2>&1
RC=$?
echo "rc=$RC frames=$(ls $T/frames | wc -l)"
grep -a -i -E -A2 'Script error|VM abort|Execution could not|Script warning' $T/run.log | grep -v -E '^--$' | sort | uniq -c | sort -rn | head -40
