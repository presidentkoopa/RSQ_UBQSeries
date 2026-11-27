#!/usr/bin/env python3
# genk.py: the kit (Brutal-Doom-less, Doom's monsters) colour runs. Writes MN_K1.one and MN_K2.one
import sys
D='/home/claude/rigdata/probes/MN/scripts/'
head = 'wait 40; god; notarget; set rsq_mon_bdtier_debug 1; netevent mn_killall; wait 10; netevent mn_dropreset; notarget; god; set mn_heal 40; set mn_filter RS_BD'
def res(dts):
    out=[]
    for dt in dts:
        out.append(f'set mn_dt {dt}; netevent mn_dmg 20; wait 2')
    return '; '.join(out)
k1=[head, 'echo MN_FLASH; set mn_cls DoomImp; netevent mn_spawn 112 0; wait 5; netevent mn_tier; netevent mn_watch 60; set rsq_mon_worldtier 2; wait 62; netevent mn_tier; netevent mn_kill 1; wait 20']
for c in range(2, 11):
    k1.append(f'echo MN_C{c}; set rsq_mon_worldtier {c}; wait 20; set mn_cls DoomImp; netevent mn_spawn 112 0; wait 3; netevent mn_tier; netevent rs_bdtier_dump; '
              + res(['Bullet', 'Fire', 'Ice', 'Melee']) + '; set mn_dt Bullet; ' + (f'netevent mn_pinv 200; ' if c == 5 else '') + 'netevent mn_watch 200; wait 200; netevent mn_tier; '
              + ('set mn_cls DoomImp; netevent mn_spawn 300 25; wait 2; netevent mn_dmg 50; netevent mn_watch 230; wait 230; ' if c == 6 else '')
              + ('netevent mn_dmg 70; netevent mn_watch 60; wait 60; netevent mn_tier; ' if c == 10 else '')
              + 'netevent mn_kill 1; wait 70; netevent mn_corpse; netevent mn_killall; wait 10')
k1.append('set rsq_mon_worldtier 1; wait 20; quit')
open(D+'MN_K1.one','w').write('; '.join(k1))
k2=[head, 'set rsq_mon_worldtier 10; wait 20']
for t, name in [(11,'ABYSS'), (12,'BLACK'), (13,'WHITE'), (15,'PASTWHITE')]:
    k2.append(f'echo MN_{name}; set mn_cls DoomImp; netevent mn_spawn 160 0; wait 5; netevent rs_tierof; wait 2; netevent rs_retier {t}; wait 45; netevent rs_tierof; netevent rs_bdtier_dump; netevent mn_tier; '
              + 'set mn_filter Imp; netevent mn_dmg 10; netevent mn_watch 40; wait 40; netevent mn_dmg 300; wait 5; netevent mn_mons 1; netevent mn_watch 420; wait 420; netevent mn_mons 1; set mn_filter RS_BD; '
              + 'netevent mn_kill 1; wait 140; netevent mn_mons 1; netevent mn_killall; wait 20; netevent mn_killall; wait 10')
k2.append('echo MN_TIERSOFF; set mn_cls DoomImp; netevent mn_spawn 160 0; wait 5; netevent rs_bdtier_dump; set rsq_mon_bdtier 0; wait 30; netevent rs_bdtier_dump; netevent mn_tier; set rsq_mon_bdtier 1; wait 30; netevent rs_bdtier_dump; netevent mn_tier')
k2.append('echo MN_CONSOLE; netevent rs_tierof; netevent rs_retier 7; wait 45; netevent rs_tierof; netevent rs_retier_up; wait 45; netevent rs_tierof; netevent rs_retier_all 9; wait 45; netevent rs_bdtier_dump; netevent rs_retier_all_up; wait 45; netevent rs_bdtier_dump; netevent rs_bdtier_classes; netevent rs_carry_dump; wait 3; quit')
open(D+'MN_K2.one','w').write('; '.join(k2))
