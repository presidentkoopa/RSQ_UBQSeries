#!/usr/bin/env python3
"""TEST ONLY: console scripts for the gore rig runs (rcGdemo + rcE_full.sh).
    rcg_script.py census            every class of rcGdemo's list, 13 a row in FireBlu Red Gray Black White Green, each killed
                                    by another damage type (2000 damage, then again at just enough), every piece counted
    rcg_script.py sheet CLS[,CLS..] posed rows for the sheets (see sheet())"""
import sys
BIG = (27, 28)       # Cyberdemon, Mastermind: 6 a row
NCLS = 32
RUNGS = 'netevent rcg_rungs 8100912 13020000 0'
def census(classes, dmgs=(2000, 0), wait=110):
    s = ['god', 'notarget', 'wait 60', 'netevent rcg_clean 1', 'netevent rcg_sample 1']
    for ci in classes:
        n, sp = (6, 150) if ci in BIG else (13, 72)
        for dmg in dmgs:
            s += ['netevent rcg_row -140 %d %d' % (sp, ci + 100 * n), 'wait 3', RUNGS, 'netevent rcg_tier', 'wait 3', 'netevent rcg_tier', 'wait 3',
                  'netevent rcg_kill -1 %d 0' % dmg, 'wait %d' % wait]
    s += ['netevent rcg_wipe', 'netevent rcg_dump', 'wait 10', 'quit']
    return s
AIR = 14
def sheet(classes, kill=0, dmg=2000, x=-180, sp=46):
    """gibbed monsters: per class a row of six (rcg_rungs: FireBlu Red Gray Black White Green) at x X, SP apart, seen
    from the player start (x -320), light 224: alive (phase code 3k+1), then killed by Brutal Doom's damage type KILL
    (rcGdemo's DT; 0 'None' at 2000: the extreme death) with every piece held to fall straight down (rcg_hold), frozen
    in the air AIR tics later (code 3k+2), let go, frozen again once landed (code 3k+3)."""
    s = ['god', 'notarget', 'wait 60', 'netevent rcg_clean 1', 'netevent rcg_light 224', 'netevent rcg_at -320 0',
         'netevent rcg_rungs 8100912 13020000 0']
    for k, ci in enumerate(classes):
        s += ['netevent rcg_row %d %d %d' % (x, sp, ci + 600), 'wait 3', 'netevent rcg_tier', 'wait 3', 'netevent rcg_tier',
              'netevent rcg_face 0', 'netevent rcg_light 224', 'wait 6', 'netevent rcg_phase %d' % (3 * k + 1), 'wait 12',
              'netevent rcg_phase 0', 'netevent rcg_hold 90', 'netevent rcg_kill %d %d 0' % (kill, dmg), 'wait %d' % AIR,
              'netevent rcg_freeze 1', 'wait 3', 'netevent rcg_phase %d' % (3 * k + 2), 'wait 12', 'netevent rcg_phase 0', 'netevent rcg_go',
              'wait 60', 'netevent rcg_freeze 1', 'wait 3', 'netevent rcg_phase %d' % (3 * k + 3), 'wait 12', 'netevent rcg_phase 0']
    s += ['wait 5', 'quit']
    return s

def pieces(pairs, rungs='8100912 13020000 0', sp=28, at=-330, dx=0):
    """the close-up grid: per pose one or two of rcGdemo's PIECES (front + 100 * back, +1 each), one per colour of the
    rungs, dropped as Brutal Doom spawns them (frozen in the air two tics in: phase code 2k+1, shown by rcGdemo's marker), held to fall straight down on their spots (rcg_pieces keeps their
    sideways speed at 0 for 60 tics), then everything frozen (landed: code 2k+2); seen from x AT, light 224."""
    s = ['god', 'notarget', 'wait 60', 'netevent rcg_clean 1', 'netevent rcg_light 224', 'netevent rcg_at %d 0' % at,
         'netevent rcg_rungs %s' % rungs]
    for k, pr in enumerate(pairs):
        s += ['netevent rcg_pieces %d %d %d' % (pr, sp, dx), 'wait 1', 'netevent rcg_freeze 1', 'netevent rcg_light 224', 'wait 3',
              'netevent rcg_phase %d' % (3 * k + 1), 'wait 12', 'netevent rcg_phase 0', 'netevent rcg_go', 'wait 50', 'netevent rcg_freeze 1', 'wait 3',
              'netevent rcg_phase %d' % (2 * k + 2), 'wait 12', 'netevent rcg_phase 0']
    s += ['wait 5', 'quit']
    return s

if __name__ == '__main__':
    if sys.argv[1] == 'census':
        cl = [int(x) for x in sys.argv[2].split(',')] if len(sys.argv) > 2 else list(range(NCLS))
        dm = tuple(int(x) for x in sys.argv[3].split(',')) if len(sys.argv) > 3 else (2000, 0)
        print('; '.join(census(cl, dm, int(sys.argv[4]) if len(sys.argv) > 4 else 110)))
    elif sys.argv[1] == 'pieces':
        print('; '.join(pieces([int(x) for x in sys.argv[2].split(',')], sp=int(sys.argv[3]), at=int(sys.argv[4]), dx=int(sys.argv[5]))))
    elif sys.argv[1] == 'sheet':
        print('; '.join(sheet([int(x) for x in sys.argv[2].split(',')], *[int(v) for v in sys.argv[3:]])))
