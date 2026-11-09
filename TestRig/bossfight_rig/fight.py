import sys, re, os, shutil; sys.path.insert(0,'/tmp/rt'); import b, rig
W='/tmp/rt/rig02.wad'
S=("god; rsqmb_debug 1; rsqmb_bf_ignore 1; rsq_mon_bf_boss %d; rsq_mon_bf_thralls %d; wait 20; netevent rsqmb_fill 1000; wait 3; netevent rsqmb_callin; netevent rt_auto; wait 2600; quit")
for name,bb,tt,dump in [('b4_own',0,0,6),('b4_mgch',2,1,0)]:
    t=rig.run(name,[W]+[b.P+'/'+o+'.pk3' for o in b.ORDER]+['/tmp/rt/probe.pk3'],S%(bb,tt),secs=1500,dump=dump,res=480,extra_env={'QZ_SNDLOG':'1'})
    print('=====',name); seen=set()
    for l in t.splitlines():
        if l in seen: continue
        seen.add(l)
        if re.search(r'^RTP t|Script error|VM abort|VM execution|exception|RSQMB (BOSSFIGHT|Miniboss From|arrival|window|tier|life|bossfight (failed|spot|drop))',l): print(l[:260])
