import json,random,re
exec(open('newplan.py').read().split("for name,title in")[0].replace("C=json.load(open('counts.json'))","C=json.load(open('counts_comp.json'))"))
def route(name): return C[name]
rows=[]
for name in C:
    if len(C[name])<3: continue
    R=[run(name,s) for s in range(100)]
    avg=lambda k:sum(r[k] for r in R)/len(R)
    b=[sum(r['bought'][i] for r in R)/len(R) for i in range(4)]
    rows.append((name,len(C[name]),avg('hrs'),R[0]['big'],b[3]))
rows.sort(key=lambda r:-r[1])
tot=sum(r[2] for r in rows)
for r in rows: print('%-5s %3d maps %5.1f h  Big Bosses %2d  oranges %.1f'%r)
print('all sets: %.0f h, %d maps'%(tot,sum(r[1] for r in rows)))
