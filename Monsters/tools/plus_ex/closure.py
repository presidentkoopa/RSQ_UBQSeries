import json,re,sys
p=json.load(open('/home/claude/scratch_plusex/plus_idx.json'))
o=json.load(open('/home/claude/scratch_plusex/ch104_idx.json'))
ours=set(l.strip().lower() for l in open('/home/claude/scratch_plusex/our_classes.txt'))
roots=sys.argv[1:]
ROOTS=set(r.lower() for r in roots)
seen={};order=[]
def refs(a):
    t=a['ctext']
    s=set(x.lower() for x in re.findall(r'"([\w\.]+)"',t))
    if a['parent']: s.add(a['parent'].lower())
    return s
def resolve(n):
    # returns ('plus'|'ours'|'104only'|None, info)
    if n in p and not n.endswith('_c') is False: pass
    if n in p:
        base=n[:-2] if n.endswith('_c') else None
        return 'plus'
    if n in o:
        return 'ours' if ('rs_'+n) in ours else '104only'
    return None
stack=list(r.lower() for r in roots)
while stack:
    n=stack.pop()
    if n in seen: continue
    k=resolve(n)
    if k is None: continue
    seen[n]=k
    if k=='plus':
        a=p[n]
        # if _C and 104 has base and ours has it: mark mapped, still record
        base=n[:-2] if n.endswith('_c') else None
        if base and base in o and ('rs_'+base) in ours:
            seen[n]='plus->ours:'+base; continue
        par=a['parent'].lower()
        if n.startswith('common') and par and ('rs_'+par) in ours and n not in ROOTS:
            seen[n]='mapped:'+par; continue
        if n.startswith('common') and par in seen and str(seen[par]).startswith('mapped') and n not in ROOTS:
            seen[n]=seen[par]; continue
        if n.startswith('common') and par.startswith('common') and par in p and n not in ROOTS:
            pp=p[par]['parent'].lower()
            if ('rs_'+pp) in ours: seen[n]='mapped:'+pp; continue
        order.append(n)
        if n.startswith('newiconchp'): seen[n]='icon'; continue
        for r in refs(a): stack.append(r)
    elif k=='104only':
        a=o[n]
        for r in refs(a): stack.append(r)
tot=0
for n,k in sorted(seen.items(),key=lambda x:x[1]):
    if k=='plus':
        a=p[n];L=a['endline']-a['line']+1;tot+=L
        print('%-6s %-40s %-30s %5d %s:%d'%(k,a['name'],a['parent'],L,a['file'],a['line']))
    elif k.startswith('mapped') or k=='104only': print('%-6s %s'%(k,n))
print('NEW LINES',tot)
