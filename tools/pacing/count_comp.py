import struct, re, json, glob, os, sys
sys.path.insert(0,'.')
FAM = {3004:0, 84:0, 9:1, 65:2, 3001:3, 3002:4, 58:5, 3005:6, 3006:7, 71:8, 69:9, 3003:10, 66:11, 67:12, 68:13, 64:14, 16:15, 7:16}
def maps(path):
    d=open(path,'rb').read()
    _,n,o=struct.unpack('<4sii',d[:12])
    L=[struct.unpack('<ii8s',d[o+16*i:o+16*i+16]) for i in range(n)]
    L=[(p,s,nm.rstrip(b'\0').decode('latin1').upper()) for p,s,nm in L]
    out=[]
    for i,(p,s,nm) in enumerate(L):
        if i+1>=len(L) or L[i+1][2] not in ('THINGS','TEXTMAP'): continue
        fam=[0]*17
        hexen=any(L[k][2]=='BEHAVIOR' for k in range(i+1,min(i+15,len(L))))
        tp,ts,ln=L[i+1]
        if ln=='THINGS':
            t=d[tp:tp+ts]; sz=20 if hexen else 10
            for k in range(ts//sz):
                r=t[k*sz:(k+1)*sz]
                if hexen:
                    typ,fl=struct.unpack_from('<HH',r,10)
                    ok=(fl&4) and (fl&256)
                else:
                    typ,fl=struct.unpack_from('<HH',r,6); ok=(fl&4) and not (fl&16)
                if typ in FAM and ok: fam[FAM[typ]]+=1
        else:
            txt=d[tp:tp+ts].decode('latin1')
            for blk in re.findall(r'thing\s*(?://[^\n]*)?\s*\{([^}]*)\}',txt,re.I):
                m=re.search(r'type\s*=\s*(\d+)',blk)
                if not m or int(m.group(1)) not in FAM: continue
                if re.search(r'skill4\s*=\s*true',blk,re.I) and not re.search(r'single\s*=\s*false',blk,re.I): fam[FAM[int(m.group(1))]]+=1
        out.append({'map':nm,'fam':fam})
    return out
allm=[]
for f in sorted(glob.glob('/tmp/comp/Maps/*.wad')):
    ms=maps(f)
    if ms: ms[0]['map']=os.path.basename(f)[:-4].upper(); allm.append(ms[0])
groups={}
for m in allm:
    mm=re.fullmatch(r'([A-Z]+\d*?)(\d\d)',m['map'])
    if not mm: continue
    groups.setdefault(mm.group(1),[]).append(m)
for g in groups: groups[g].sort(key=lambda x:x['map'])
json.dump(groups,open('counts_comp.json','w'))
print(len(allm),'maps;',len(groups),'sets')
for g,v in sorted(groups.items(),key=lambda x:-len(x[1])):
    c=[sum(x['fam']) for x in v]
    print('%-6s %3d maps  monsters median %4d max %5d total %6d'%(g,len(v),sorted(c)[len(c)//2],max(c),sum(c)))
