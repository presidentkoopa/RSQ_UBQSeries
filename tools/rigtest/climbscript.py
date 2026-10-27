import sys
# builds a console script: hang, then N hand-over-hand strokes (alternating hands), then lowering
def pose(h, y, x=None):
    if h=='l': return 'qz_lhand "%.3f %.3f -0.15 30 0 0"'%(-0.05 if x is None else x, y)
    return 'qz_rhand "%.3f %.3f -0.15 30 0 0"'%(0.05 if x is None else x, y)
s=['wait 2','map GRTEST','wait 10','netevent grp_tp 300 512 0',(sys.argv[4] if len(sys.argv)>4 else 'use Fist'),'rsqgr_debug 1','qz_rhand "0.25 1.3 -0.1 110 0 0"','wait 8',
   'event rsqgr_press 0','wait 14','event rsqgr_release 0','wait 40']
strokes=int(sys.argv[1]) if len(sys.argv)>1 else 3
for k in range(strokes):
    h='l' if k%2==0 else 'r'; hi=1 if h=='l' else 0
    s.append(pose(h,1.75)); s.append('wait 3'); s.append('event rsqgr_grip %d'%hi); s.append('wait 2')
    for y in [1.65,1.55,1.45,1.35,1.25,1.15]:
        s.append(pose(h,y)); s.append('wait 1')
    s.append('wait 2'); s.append('event rsqgr_ungrip %d'%hi if False else 'wait 0')
    # the other hand takes over on its press; this one lets go after
    s.append('event rsqgr_ungrip %d'%hi); s.append(pose(h,1.3, 0.25 if h=='r' else -0.25)); s.append('wait 6')
if len(sys.argv)>2:
    # lower: grip off hand low, push it up
    s.append(pose('l',1.15)); s.append('wait 3'); s.append('event rsqgr_grip 1'); s.append('wait 2')
    for y in [1.25,1.35,1.45,1.55,1.65,1.75]:
        s.append(pose('l',y)); s.append('wait 1')
    s.append('wait 4'); s.append('event rsqgr_ungrip 1')
s+=['wait 30', sys.argv[3] if len(sys.argv)>3 else '', 'quit']
print('; '.join(x for x in s if x))
