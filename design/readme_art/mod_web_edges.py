import os,re,sys,json
root=sys.argv[1]
MODS=['Accessibility','DistanceGrab','FlashFlare','GlowInTheDark','Grapple','Graveyard','Grenade','GunBonsaiOffhandVR','GunCards','LaserSight','Melee','Miniboss','Monsters','QuestSaber','Score','ShieldSaw','SlowMo','TacticalRig','VisualRewards','Wheel','Whip']
SKIP=('tools','docs','original','jp_original','renders','test','tests','DarkDoomZ','ca.ancilla.bonsai')
src={}
for m in MODS:
    t=[]
    for dp,dn,fn in os.walk(os.path.join(root,m)):
        dn[:]=[d for d in dn if d not in SKIP]
        for f in fn:
            if f.lower().endswith(('.zs','.zsc')) or f.lower() in('zscript.txt',):
                try:t.append(open(os.path.join(dp,f),encoding='utf-8',errors='replace').read())
                except:pass
    src[m]='\n'.join(t)
svc={}
for m in MODS:
    for n in re.findall(r'class\s+(\w+)\s*:\s*Service\b',src[m]): svc[n]=m
edges={}
for m in MODS:
    for n in set(re.findall(r'ServiceIterator\.Find\(\s*"(\w+)"',src[m])):
        o=svc.get(n)
        if o and o!=m:
            # requests near
            edges.setdefault((m,o),set()).add(n)
print(len(svc),'services');
for k,v in sorted(svc.items(),key=lambda x:x[1]): print('  ',v,k)
deg={}
for (a,b),v in sorted(edges.items()):
    print(f'{a} -> {b}: {",".join(sorted(v))}'); deg[b]=deg.get(b,0)+1
print(sorted(deg.items(),key=lambda x:-x[1])); print(len(edges),'edges')
json.dump([[a,b] for (a,b) in edges],open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'mod_web_edges.json'),'w'))
