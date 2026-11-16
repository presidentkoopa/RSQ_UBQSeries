import json,os,shutil,re,glob
d=json.load(open('/home/claude/scratch_plusex/snd.json'))
M='/home/claude/wt_plusex/Monsters'
RENL={'HLWIND':'RSPHLWND','Q2WIND':'RSPQ2WND'}
os.makedirs(M+'/sounds/plus',exist_ok=True)
for l,src in d['copy'].items():
    ext=os.path.splitext(src)[1]
    dst=M+'/sounds/plus/'+RENL.get(l,l)+ext.lower()
    shutil.copyfile(src,dst)
# logical names: prefix rsplus/
names=[]
out=[]
for c in d['sndinfo']:
    toks=c.split(None,2) if c.startswith('$') else c.split()
    if c.lower().startswith('$random'):
        m=re.match(r'\$random\s+(\S+)\s*\{(.*)\}',c,re.I)
        n=m.group(1); mem=m.group(2).split()
        names.append(n.lower())
        out.append('$random rsplus/%s { %s }'%(n.lower(),' '.join('rsplus/'+x.lower() for x in mem)))
    else:
        n,l=c.split()[:2]
        names.append(n.lower())
        out.append('rsplus/%-28s %s'%(n.lower(),RENL.get(l.upper(),l.upper())))
hdr='''// SNDINFO.plusex -- Colourful Hell Plus R3.0.1's sounds for its new boss bodies (zscript/monsters/plus), 2026-11-16.
// CHP's own SNDINFO lines, every logical name under rsplus/ (so no other mod's "tornado/form" or "wind/away" changes:
// XMVE defines both), lumps in sounds/plus. HLWIND and Q2WIND are renamed RSPHLWND / RSPQ2WND: XMVE ships other bytes
// under those lump names and loads earlier. The four NA_* lumps are byte for byte XMVE's, kept under their names.
'''
open(M+'/SNDINFO.plusex','w').write(hdr+'\n'.join(out)+'\n')
json.dump(sorted(set(names)),open('/home/claude/scratch_plusex/sndnames.json','w'))
print(len(out),'lines',len(d['copy']),'lumps')
