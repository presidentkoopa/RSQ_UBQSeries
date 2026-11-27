# mod_web_edges.py <repo>: counts the mod web's strings and writes mod_web_edges.json.
# A string from A to B: A's ZScript names a Service class that B declares (by its name in quotes: a lookup through
# ServiceIterator.Find, directly or through a helper). Comments are left out, and so is the shared options-menu code
# every mod carries (rsmenu.zs), which only greys menu rows, and the How To Play page code being added to each mod
# (howto*.zs, 2026-11-27, still being built).
# 2026-11-27: RSQ Accessibility is being removed, so it is neither scanned nor a target. The folders Monsters and
# MonsterRecolour are not read (owner's order): RSQ Monsters is a node with the strings the other mods' code names
# by its service names (RSQMN_..., named as RSQ Monsters' in RSQ Score's README); what Monsters itself asks is not known
# here. DEAD lists strings found in code that the asking mod's README says nothing calls.
import os,re,sys,json
root=sys.argv[1]
MODS=['DistanceGrab','FlashFlare','GlowInTheDark','Grapple','Graveyard','Grenade','GunBonsaiOffhandVR','GunCards','LaserSight',
      'Melee','Miniboss','QuestSaber','Score','ShieldSaw','SlowMo','TacticalRig','VisualRewards','Wheel','Whip']
SKIP=('tools','docs','original','jp_original','renders','test','tests','DarkDoomZ','ca.ancilla.bonsai')
DEAD={('GunBonsaiOffhandVR','SlowMo'):'GunBonsaiOffhandVR/README.md, Works with: its calls to SlowMo are in code nothing calls'}
def strip(t):
    t=re.sub(r'/\*.*?\*/','',t,flags=re.S); return re.sub(r'//[^\n]*','',t)
src={}
for m in MODS:
    t=[]
    for dp,dn,fn in os.walk(os.path.join(root,m)):
        dn[:]=[d for d in dn if d not in SKIP]
        for f in fn:
            if f.lower().endswith('rsmenu.zs') or f.lower().startswith('howto'): continue
            if f.lower().endswith(('.zs','.zsc')) or f.lower()=='zscript.txt':
                t.append(strip(open(os.path.join(dp,f),encoding='utf-8',errors='replace').read()))
    src[m]='\n'.join(t)
svc={}
for m in MODS:
    for n in re.findall(r'class\s+(\w+)\s*:\s*Service\b',src[m]): svc[n]=m
edges={}
for m in MODS:
    for n in set(re.findall(r'"(\w+)"',src[m])):
        o=svc.get(n)
        if n.startswith('RSQMN_') and n.endswith('Service'): o='Monsters'
        if o and o!=m and (m,o) not in DEAD: edges.setdefault((m,o),set()).add(n)
print(len(svc),'services')
for (a,b),v in sorted(edges.items()): print(f'{a} -> {b}: {",".join(sorted(v))}')
deg={}
for (a,b) in edges: deg[b]=deg.get(b,0)+1
print('asked by:',sorted(deg.items(),key=lambda x:-x[1])); print(len(edges),'edges')
json.dump([[a,b] for (a,b) in sorted(edges)],open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'mod_web_edges.json'),'w'))
