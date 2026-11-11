# measure: each ladder family's colour health (ClassFor bodies, EX excluded), rank per family, mean rank over families
import re,glob,sys
root=sys.argv[1]
files=glob.glob(root+'/**/*.zs',recursive=True)
txt={f:open(f,errors='replace').read() for f in files}
cls={}
for f,s in txt.items():
    for m in re.finditer(r'^class\s+(\w+)\s*(?::\s*(\w+))?[^{;]*\{',s,re.M):
        start=m.end(); depth=1;i=start
        while depth and i<len(s):
            if s[i]=='{':depth+=1
            elif s[i]=='}':depth-=1
            i+=1
        body=s[start:i]
        d=body.split('States')[0]
        h=re.search(r'^\s*Health\s+(\d+)',d,re.M)
        cls[m.group(1).lower()]=(m.group(2).lower() if m.group(2) else None, int(h.group(1)) if h else None)
VAN={'zombieman':20,'shotgunguy':30,'chaingunguy':70,'doomimp':60,'demon':150,'spectre':150,'lostsoul':100,'cacodemon':400,'hellknight':500,'baronofhell':1000,'revenant':300,'fatso':600,'arachnotron':500,'archvile':700,'painelemental':400,'cyberdemon':4000,'spidermastermind':3000}
def health(c):
    c=c.lower()
    while c:
        if c in cls:
            p,h=cls[c]
            if h is not None: return h
            c=p
        elif c in VAN: return VAN[c]
        else: return None
src=open(root+'/RS_Retier.zs').read()
body=src[src.index('static Name ClassFor('):]; body=body[:body.index('\n\t}\n')]
tab={};fam=None
for l in body.split('\n'):
    m=re.search(r'fam == (\d+)',l)
    if m: fam=int(m.group(1))
    m=re.search(r"tier == (\d+)\) return '(\w+)'",l)
    if m: tab[(fam,int(m.group(1)))]=m.group(2)
names=['Common','Green','Blue','Purple','Yellow','Red','FireBlu','Gray','Abyss','Black','White','Cyan','Brown']
ranks={t:[] for t in range(1,14)}
rows=[]
for f in range(17):
    hs={t:health(tab[(f,t)]) for t in range(1,14)}
    rows.append((f,tab[(f,1)],hs))
    if any(v is None for v in hs.values()): print('missing',f,hs); continue
    vals=sorted(hs.values())
    for t,v in hs.items():
        # average rank for ties
        lo=vals.index(v)+1; hi=len(vals)-vals[::-1].index(v)
        ranks[t].append((lo+hi)/2)
for f,c,hs in rows: print(f,c,' '.join(str(hs[t]) for t in range(1,14)))
order=sorted(range(1,14),key=lambda t:sum(ranks[t])/len(ranks[t]))
for t in order: print(f"{names[t-1]:8s} #{t:2d} mean rank {sum(ranks[t])/len(ranks[t]):5.2f} over {len(ranks[t])}")
