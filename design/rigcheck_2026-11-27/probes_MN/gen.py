#!/usr/bin/env python3
# gen.py <name> <kind> [tier]: writes scripts/<name>.one
#  kind fight: an RSQ Miniboss fight called in; each thrall killed alone, then the Boss through its lives, a drop list per death
#  kind map:   five Doom monsters spawned 200-260 ahead (replaced by the Monster Set), each killed alone, a drop list per death
import sys
name, kind = sys.argv[1], sys.argv[2]; tier = sys.argv[3] if len(sys.argv) > 3 else '1'
SH = f'/home/claude/rigdata/probes/MN/shots/{name}'
def look(tag):
    return f'echo MN_LOOK_{tag}; netevent mn_look -1 96 0; qz_hmd "0 1.6 0 -40 0 0"; wait 4; screenshot; qz_hmd "0 1.6 0 0 0 0"; wait 2'
c = [f'wait 150; god; notarget; set screenshot_dir {SH}; set rsqmb_debug 1; set rsqmb_bf_first 0; set rsqmb_bf_auto 0; set mn_invlog 0; set rsqmb_rank_on 0']
if kind.startswith('map') and kind != 'map':
    c.append(f'set rsq_monster_set {kind[3:]}; set rsq_mon_worldtier {tier}; map MAP01; wait 160; god; notarget')
elif tier != '1':
    c.append(f'set rsq_mon_worldtier {tier}; wait 40')
c.append('netevent mn_mons 0; netevent mn_dropreset')
if kind == 'fight':
    c.append('netevent rsqmb_fill 1000; wait 10; set rsqmb_bf_exit 0; netevent rsqmb_callin; wait 330; netevent rsqmb_state; netevent mn_mons 1')
    for i in range(6):
        c.append(f'echo MN_THRALL{i}; netevent mn_dropreset')
        c.append(f'netevent mn_mbone 0; wait 140; netevent mn_dropsum; {look("T"+str(i))}')
    for i in range(4):
        c.append(f'echo MN_BOSS{i}; netevent mn_dropreset; netevent mn_mbone 1 1; wait 320; netevent mn_dropsum; netevent rsqmb_state; {look("B"+str(i))}; wait 60')
    c.append('echo MN_FIGHTEND; netevent mn_dropreset; netevent mn_killall; wait 320; netevent mn_dropsum; netevent rsqmb_state')
else:
    for i, m in enumerate(['ZombieMan', 'ShotgunGuy', 'ChaingunGuy', 'DoomImp', 'Demon', 'HellKnight']):
        c.append(f'echo MN_KILL{i}_{m}; netevent mn_dropreset; set mn_cls {m}; netevent mn_spawn 200 0; wait 10; netevent mn_tier; netevent mn_kill 1; wait 140; netevent mn_dropsum; {look(str(i))}')
    c.append('echo MN_KILLALL; netevent mn_dropreset; netevent mn_mons 0; netevent mn_killall; wait 320; netevent mn_dropsum')
c.append('netevent mn_f6; netevent mn_mons 0; wait 3; quit')
open(f'/home/claude/rigdata/probes/MN/scripts/{name}.one', 'w').write('; '.join(c))
print('; '.join(c)[:300])
