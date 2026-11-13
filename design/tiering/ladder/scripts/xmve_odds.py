import re,sys,json
def spawners(path):
    L=open(path,encoding='latin-1').read().replace('\r','').split('\n')
    actors=[];cur=None;st=None
    for i,l in enumerate(L,1):
        s=l.split('//')[0]
        m=re.match(r'\s*Actor\s+(\w+).*?Replaces\s+(\w+)',s,re.I)
        if m: cur={'name':m.group(1),'rep':m.group(2),'line':i,'states':{},'order':[]}; actors.append(cur); st=None; continue
        if not cur: continue
        m=re.match(r'^\s*(\w+)\s*:\s*$',s)
        if m: st=m.group(1).lower(); cur['states'][st]=[]; cur['order'].append(st); continue
        if st: cur['states'][st].append((i,s.strip()))
    return actors
def dist(a,state,depth=0):
    res={};rem=1.0;state=state.lower()
    if state not in a['order']: return {'?MISSING:'+state:1.0}
    idx=a['order'].index(state); s=state
    while True:
        for ln,l in a['states'][s]:
            m=re.search(r'A_Jump\s*\((\d+)\s*,\s*"(\w+)"\s*\)',l)
            if m:
                p=min(1,int(m.group(1))/256)*rem
                sub=dist(a,m.group(2),depth+1) if depth<6 else {}
                for k,v in sub.items(): res[k]=res.get(k,0)+p*v
                rem-=p; continue
            m=re.search(r'A_SpawnItemEx\s*\(\s*"(\w+)"',l)
            if m: res[m.group(1)]=res.get(m.group(1),0)+rem; return res
            if re.match(r'(?i)stop',l): return res
        idx+=1
        if idx>=len(a['order']): return res
        s=a['order'][idx]
out={}
for a in spawners(sys.argv[1]):
    if 'spawn' not in a['states']: continue
    d=dist(a,'spawn'); out[a['rep']]={'spawner':a['name'],'line':a['line'],'odds':d}
    print(f"{a['name']} replaces {a['rep']} (Decorate.txt:{a['line']}): "+', '.join(f"{k} {v*100:.1f}%" for k,v in sorted(d.items(),key=lambda x:-x[1])))
json.dump(out,open(sys.argv[2],'w'),indent=1)
