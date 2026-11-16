import json,re,sys,subprocess,collections
sys.path.insert(0,'/home/claude/scratch_plusex')
import conv
P=conv.P;O=conv.O;OURS=conv.OURS;OC=conv.OURS_CASE
ROOTNAMES={'commonblackspectreex2':'RS_BlackSpectreEX','commonwhitespiderex2':'RS_WhiteSPEX','commonwhitespiderex3':'RS_WhiteSPEXSplit',
 'commonwhitespiderex4':'RS_WhiteSPEXSplit2','commonblackarchex2':'RS_BlackArchEX','commonblackarchex3':'RS_BlackArchEXVoid',
 'commonwhitearchex2':'RS_WhiteArchEX','commonwhitearchex3':'RS_WhiteArchEXClone','commonblackcybieex2':'RS_BlackCybieEX',
 'commonwhitecybieex2':'RS_WhiteCybieEX','commonwhitecybieex3':'RS_WhiteCybieEXCore','commonwhitemind2':'RS_WhiteMindES',
 'commonwhitespider2':'RS_WhiteSPPlus','commonwhitespider3':'RS_WhiteSPFusion','commonwhitespider4':'RS_WhiteSPFusion2','commonwhitespider5':'RS_WhiteSPFusion3'}
TIERS={'RS_BlackSpectreEX':12,'RS_WhiteSPEX':13,'RS_WhiteSPEXSplit':13,'RS_WhiteSPEXSplit2':13,'RS_BlackArchEX':12,'RS_BlackArchEXVoid':12,
 'RS_WhiteArchEX':13,'RS_WhiteArchEXClone':13,'RS_BlackCybieEX':12,'RS_WhiteCybieEX':13,'RS_WhiteCybieEXCore':13,'RS_WhiteMindES':13,
 'RS_WhiteSPPlus':13,'RS_WhiteSPFusion':13,'RS_WhiteSPFusion2':13,'RS_WhiteSPFusion3':13}
R=json.load(open('/home/claude/scratch_plusex/roots.json'))
# full new set
new=collections.OrderedDict()
for r,names in R.items():
    for n in names: new.setdefault(n.lower(),r)
for k in ('commonwhitespider2','commonwhitespider4','commonwhitespider5'): new.setdefault(k,'CommonWhiteSpider3')
# icons excluded
NM={}
def base(n): return n[:-2] if n.lower().endswith('_c') else n
# mapping for every plus/104 name we may reference
for k,a in P.items():
    if k in ROOTNAMES: NM[k]=ROOTNAMES[k]; continue
    b=base(a['name']).lower()
    if b!=k and ('rs_'+b) in OURS: NM[k]=OC['rs_'+b]; continue
    if ('rs_'+k) in OURS: NM[k]=OC['rs_'+k]; continue
    par=a['parent'].lower()
    if k.startswith('common') and ('rs_'+par) in OURS: NM[k]=OC['rs_'+par]; continue
    if k.startswith('common') and par.startswith('common') and par in P and ('rs_'+P[par]['parent'].lower()) in OURS: NM[k]=OC['rs_'+P[par]['parent'].lower()]; continue
for k,a in O.items():
    if ('rs_'+k) in OURS and k not in NM: NM[k]=OC['rs_'+k]
# new classes
coll=[]
for k in new:
    if k in NM and k not in ROOTNAMES: continue
    if k in ROOTNAMES: continue
    nn='RS_'+base(P[k]['name'])
    if nn.lower() in OURS: nn='RS_P'+base(P[k]['name']); coll.append(k)
    NM[k]=nn
conv.NAMEMAP=NM
json.dump({'NM':NM,'new':list(new),'coll':coll},open('/home/claude/scratch_plusex/names.json','w'),indent=0)
todo=[k for k in new if (k in ROOTNAMES) or (NM.get(k,'').lower() not in OURS)]
print(len(todo),'to port; collisions renamed',coll)
conv.ACSMAP.update({'x:exboss':'A_Log("A chill runs down your spine")',
 'x:wvileexarmorsteal_c':'{ RS_PlusEX.WVileArmorSteal(self); }','x:wvileextimer_c':'{ RS_PlusEX.WVileTimer(self); }',
 'x:wvileextimer2_c':'{ RS_PlusEX.WVileTimer2(self); }','x:wvileextimestop':'{ RS_PlusEX.WVileTimeStop(self); }',
 'acs_namedterminate:wvileextimer_c':'{ RS_PlusEX.WVileTimerStop(self); }','x:cybiespecialkill_c':'',
 'call:ch_blacksubtier':'2'})
for k in list(P):
    if k.startswith('announce'): pass
import glob
# announcers
src=open('/tmp/chplus/source/Bosses.acs',encoding='latin-1').read()
for m in re.findall(r'script\s+"(Announce\w+)"',src,re.I): conv.ACSMAP['x:'+m.lower()]=''
FILES=collections.OrderedDict()
owner={}
for r,names in R.items():
    for n in names:
        owner.setdefault(n.lower(),set()).add(r)
for k in ('commonwhitespider2','commonwhitespider4','commonwhitespider5'): owner[k]={'CommonWhiteSpider3'}
FN={'CommonBlackSpectreEX2':'spectre','CommonWhiteSpiderEX2':'whitespider','CommonBlackArchEX2':'blackarch','CommonWhiteArchEX2':'whitearch',
 'CommonBlackCybieEX2':'blackcybie','CommonWhiteCybieEX2':'whitecybie','CommonWhiteMind2':'whitemind','CommonWhiteSpider3':'fusion'}
for k in todo:
    rs=owner[k]
    f='shared' if len(rs)>1 else FN[list(rs)[0]]
    a=P[k]
    par=a['parent']
    pl=par.lower()
    if not par: parent='Actor'
    elif pl in conv.ENGINE_PARENTS: parent=conv.ENGINE_PARENTS[pl]
    elif pl in NM: parent=NM[pl]
    elif pl in O and ('rs_'+pl) in OURS: parent=OC['rs_'+pl]
    else: parent=par; conv.NOTES.append('PARENT? %s : %s'%(a['name'],par))
    nn=NM[k] if k in NM else ROOTNAMES[k]
    tier=TIERS.get(nn)
    icon=None
    if tier: icon='\toverride void Tick() { Super.Tick(); RS_PlusEX.Icon(self, %d); }'%tier
    FILES.setdefault(f,[]).append(conv.convert(a,nn,parent,tier=tier,iconfn=icon))
import os
os.makedirs('/home/claude/scratch_plusex/gen',exist_ok=True)
for f,cl in FILES.items():
    open('/home/claude/scratch_plusex/gen/%s.zs'%f,'w').write('\n\n'.join(cl)+'\n')
    print(f,len(cl))
print('\n'.join(sorted(set(conv.NOTES))))
STUBS={
 'darknesstokenblackspectreex':'RS_DarknessTokenBlackSpectreEX','bvileexdarknesstoken':'RS_BVileEXDarknessToken','blackminddarknesstoken':'RS_BlackMindDarknessToken'}
for f in list(FILES):
    txt=open('/home/claude/scratch_plusex/gen/%s.zs'%f).read()
    for k,nn in STUBS.items():
        m=re.search(r'class %s : Powerup[^\n]*\n\{.*?\n\}\n'%nn,txt,re.S)
        if m:
            src=P[k]
            stub=('// STUBBED (owner 2026-11-16: no Abyss-style screen darkening). CHP %s:%d (%s) is a Powerup\n'
                  '// with Powerup.Color "00 00 00",0.5 and A_Light(-20/-30/-25) on pickup: it darkens the player\'s screen.\n'
                  '// Here it is an item no one can hold (MaxAmount 0): every give is refused, every take finds nothing.\n'
                  'class %s : Inventory\n{\n\tDefault\n\t{\n\t\tInventory.MaxAmount 0;\n\t\t+INVENTORY.UNDROPPABLE\n\t}\n}\n')%(src['file'].replace('DECORATE_dir/',''),src['line'],src['name'],nn)
            txt=txt[:m.start()]+stub+txt[m.end():]
    open('/home/claude/scratch_plusex/gen/%s.zs'%f,'w').write(txt)
