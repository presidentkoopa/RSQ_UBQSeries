import sys, re; sys.path.insert(0,'/home/claude/presidentkoopa/rsq_meshturbator/rig'); import rig
P='/home/claude/rsq_ubqseries/pk3'
ORDER=['RSQ_Monsters','RSQ_Accessibility','RSQ_Score','RSQ_SlowMo','RSQ_VisualRewards','RSQ_GlowInTheDark','RSQ_Grenade','RSQ_Miniboss','RSQ_TacticalRig','RSQ_DistanceGrab','RSQ_Melee','RSQ_Grapple','RSQ_Whip','RSQ_Wheel','RSQ_GunCards','RSQ_LaserSight','RSQ_ShieldSaw','RSQ_Saber','RSQ_FnF','RSQ_Graveyard']
def go(name, script, extra=[], secs=600, dump=0, order=None):
    t=rig.run(name,[P+'/'+o+'.pk3' for o in (order or ORDER)]+extra,script,secs=secs,dump=dump)
    L=t.splitlines(); out=[]
    for i,l in enumerate(L):
        if re.search(r'Script error|VM abort|VM execution|FATAL|exception|Unknown class|not found|Bad ',l):
            out.append(l+(' | '+L[i+1] if i+1<len(L) and 'Script error' in l else ''))
    return t, out
if __name__=='__main__':
    t,o=go(sys.argv[1], sys.argv[2])
    seen=[]
    for l in o:
        if l not in seen: seen.append(l)
    print('\n'.join(seen[:60]) or 'NO ERRORS'); print(len(t.splitlines()),'lines')
