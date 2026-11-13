import re,os,json
root='/home/claude/rsq_ubqseries/Monsters/zscript/monsters'
src={}
for dp,dn,fns in os.walk(root):
  for f in fns:
    if f.endswith('.zs'):
      p=os.path.join(dp,f); L=open(p,encoding='latin-1').read().split('\n')
      for i,l in enumerate(L):
        m=re.match(r'^class\s+(\w+)',l)
        if m: src[m.group(1).lower()]=(os.path.relpath(p,root),i+1,L)
def body(c):
  f,ln,L=src[c.lower()]
  out=[]
  for j in range(ln-1,len(L)):
    out.append((j+1,L[j]))
    if j>ln and L[j].startswith('}'): break
  return f,out
LD=json.load(open('/tmp/rscripts/ladder.json'))
dials={}
for fam,d in LD['dial'].items():
  f,b=body(d); ent=[]
  for ln,s in b:
    m=re.search(r'DropItem\s+"(\w+)",\s*(\d+),\s*(\d+)',s)
    if m: ent.append((m.group(1),int(m.group(3)),f"{f}:{ln}"))
  dials[fam]=ent
json.dump(dials,open('/tmp/econ3/ladder/scripts/dials.json','w'),indent=0)
seen=set()
for fam,ent in dials.items():
  for c,w,loc in ent:
    if c.lower() in seen: continue
    seen.add(c.lower())
    f,b=body(c)
    txt=' '.join(s.strip() for ln,s in b)
    if 'RS_Zom.CV' in txt:
      # compact
      acts=re.findall(r'(\w+):|A_JumpIf\(RS_Zom\.CV\(\'(\w+)\', 1\) == (\d)\s*,\s*"(\w+)"\)|A_Jump\((\d+),\s*"(\w+)"\)|A_SpawnItemEx\("(\w+)"|Goto (\w+)',txt)
      s=[]
      for a in acts:
        if a[0]: s.append(a[0]+':')
        elif a[1]: s.append(f"if {a[1]}=={a[2]}->{a[3]}")
        elif a[4]: s.append(f"jump{a[4]}->{a[5]}")
        elif a[6]: s.append(f"spawn {a[6]}")
        elif a[7]: s.append(f"goto {a[7]}")
      print(f"{c} [{f}:{b[0][0]}] "+' | '.join(s))
