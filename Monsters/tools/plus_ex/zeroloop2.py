import re,glob,sys
for f in sorted(glob.glob('/home/claude/wt_plusex/Monsters/zscript/monsters/plus/*.zs')):
    src=open(f).read()
    for m in re.finditer(r'^class (\w+) : (\w+)[^\n]*\n\{(.*?)\n\}',src,re.M|re.S):
        cls=m.group(1); body=m.group(3)
        si=body.find('\tStates')
        if si<0: continue
        lines=body[si:].split('\n')
        seq=[]; labels={}
        for L in lines:
            c=re.sub(r'//.*','',L).strip()
            if not c or c in ('States','{','}'): continue
            lm=re.match(r'^([\w\.]+):$',c)
            if lm: labels[lm.group(1).lower()]=len(seq); continue
            fm=re.match(r'^(Goto|Loop|Stop|Wait|Fail)\b\s*(\S*)',c,re.I)
            if fm: seq.append(('flow',fm.group(1).lower(),fm.group(2).rstrip(';'))); continue
            tm=re.match(r'^("?\S+"?)\s+("[^"]+"|\S+)\s+(-?\d+|random\([^)]*\))',c)
            if tm:
                d=tm.group(3); n=len(tm.group(2).strip('"'))
                dur=0 if d=='0' else 1
                for k in range(n): seq.append(('frame',dur,c))
        # walk: from each frame index follow 0-dur frames, loop->last label start
        def labstart(i):
            best=0
            for l,v in labels.items():
                if v<=i and v>=best: best=v
            return best
        # graph over zero-tic frames incl. jump edges
        import collections
        G=collections.defaultdict(set)
        for i,e in enumerate(seq):
            if e[0]=='frame':
                if e[1]!=0: continue
                G[i].add(i+1)
                for lab in re.findall(r'"(\w+)"',e[2]):
                    if lab.lower() in labels: G[i].add(labels[lab.lower()])
                mm=re.search(r'A_Jump\w*\([^;]*?,\s*(\d+)\s*\)',e[2])
                if mm and 'A_Jump(' in e[2]: G[i].add(i+int(mm.group(1)))
            elif e[1]=='loop': G[i].add(labstart(i-1))
            elif e[1]=='goto':
                t=e[2].split('+'); lab=t[0].lower()
                if lab in labels: G[i].add(labels[lab]+(int(t[1]) if len(t)>1 else 0))
        def isz(i): return i<len(seq) and (seq[i][0]=='flow' and seq[i][1] in ('loop','goto') or (seq[i][0]=='frame' and seq[i][1]==0))
        color={}
        def dfs(u,path):
            color[u]=1
            for v in G[u]:
                if not isz(v): continue
                if color.get(v)==1:
                    print(cls,'possible zero-tic cycle:',' | '.join((seq[x][2][:60] if seq[x][0]=='frame' else str(seq[x])) for x in path[path.index(v):]+[v])[:400]); return True
                if not color.get(v) and dfs(v,path+[v]): return True
            color[u]=2; return False
        for st in range(len(seq)):
            if isz(st) and not color.get(st):
                if dfs(st,[st]): break
        continue
        for start in range(len(seq)):
            i=start; seen=set(); ok=False
            while i<len(seq) and i not in seen:
                seen.add(i); e=seq[i]
                if e[0]=='frame':
                    if e[1]!=0: ok=True; break
                    i+=1; continue
                if e[1]=='loop': i=labstart(i-1); continue
                if e[1]=='goto':
                    t=e[2].split('+'); lab=t[0].lower()
                    if '::' in lab or lab not in labels: ok=True; break
                    i=labels[lab]+(int(t[1]) if len(t)>1 else 0); continue
                ok=True; break
            if not ok and i in seen:
                print(cls, 'zero-tic cycle from', seq[start][2][:80] if seq[start][0]=='frame' else seq[start]); break
