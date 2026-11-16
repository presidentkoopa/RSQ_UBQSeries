import zipfile,struct,os,sys,json,re
U='/mnt/user-data/uploads'; B='/home/claude/presidentkoopa/rsq_bd_vr_reloaded/pk3'
files=['/home/claude/rig/packs/doom2.wad','/home/claude/rsq_ubqseries/WADs/TUD_NoEndInSight_.wad',U+'/975b943c-0.99-LegenDoom_3.0.pk3',U+'/1_00_brutal22test6.pk3',B+'/02_BD22_VoxelPack.pk3','/mnt/user-data/outputs/rel4/BD22_VR-Reloaded_2.0.5a.pk3',B+'/04_XMVE_MonsterExpansion1.3.1-BD22.pk3',B+'/06_XMVE_MonsterExpansion_Doom2.pk3',B+'/05_XMVE_MonsterExpansion_TUD.pk3',B+'/07_XMVE_MonstersNoDropGuns-BD22.pk3',U+'/eea375c1-2.1-Enemies_LegionOfBones_v1.05.pk3',U+'/4ee2f317-2.2-Enemies-mk-champions20210309.pk3',U+'/3be205c2-2.3-Enemies_NoMoreHitscans-main.zip',U+'/4f980dcf-2.4-Enemies_UniversalEntropy.pk3',U+'/0092a05c-2.5-Enemies_SpawnAdjuster_SliderBar10.5.zip']
import glob
files+=[f for f in glob.glob(U+'/*3.0*-Environmental_*')+glob.glob(U+'/*4.0*-Gameplay_*')]
files+=glob.glob('/home/claude/rig/work/gate_rel4/RSQ_*.pk3')
want=json.loads(sys.argv[1])  # {'sprites':[prefixes],'sounds':[lumps]}
def entries(f):
    out=[]
    if f.lower().endswith('.wad'):
        d=open(f,'rb').read(); n,off=struct.unpack('<ii',d[4:12])
        for i in range(n):
            o,s,nm=struct.unpack('<ii8s',d[off+16*i:off+16*i+16]); out.append(('',nm.rstrip(b'\0').decode('latin-1').upper()))
    else:
        try: z=zipfile.ZipFile(f)
        except Exception as e: print('skip',f,e); return out
        for n in z.namelist():
            if n.endswith('/'): continue
            nl=n.lower()
            if nl.endswith(('.wad','.pk3')): out.append(('embedded',n))
            ns=nl.split('/')[0] if '/' in nl else ''
            out.append((ns,os.path.splitext(n.split('/')[-1])[0].upper()[:8]))
    return out
for f in files:
    if not os.path.exists(f): print('MISSING FILE',f); continue
    hits=[]
    for ns,nm in entries(f):
        if ns=='embedded': hits.append('EMBEDDED '+nm); continue
        if any(nm.startswith(p) for p in want['sprites']) and ns in ('sprites','',): hits.append(nm)
        if nm in want['sounds'] and ns in ('sounds','','music'): hits.append('snd:'+nm)
    if hits: print(os.path.basename(f), sorted(set(hits))[:30])
