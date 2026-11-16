import re,glob,json
D='/home/claude/wt_plusex/Monsters/zscript/monsters/plus/'
BODIES=['RS_BlackSpectreEX','RS_WhiteSPEX','RS_WhiteSPEXSplit','RS_WhiteSPEXSplit2','RS_BlackArchEX','RS_BlackArchEXVoid','RS_WhiteArchEX','RS_WhiteArchEXClone','RS_BlackCybieEX','RS_WhiteCybieEX','RS_WhiteCybieEXCore','RS_WhiteMindES','RS_WhiteSPPlus','RS_WhiteSPFusion','RS_WhiteSPFusion2','RS_WhiteSPFusion3','RS_WhiteSP11Old','RS_BlackLSoulOld3']
labels={}
src=''.join(open(f).read() for f in glob.glob(D+'*.zs'))
for m in re.finditer(r'^class (\w+) : (\w+)[^\n]*\n\{(.*?)\n\}',src,re.M|re.S):
    if m.group(1) in BODIES:
        L=re.findall(r'^\t(\w+(?:\.\w+)?):',m.group(3),re.M)
        labels[m.group(1)]=[l for l in L if l.lower() not in ('spawn','scripted','idle')]
for b in ('RS_WhiteSP11Old','RS_BlackLSoulOld3'): labels[b]=['See','Missile','Melee','Pain','Death']
PAR={'RS_WhiteSPEXSplit':'RS_WhiteSPEX','RS_WhiteSPEXSplit2':'RS_WhiteSPEX','RS_WhiteArchEXClone':'RS_WhiteArchEX','RS_WhiteCybieEXCore':'RS_WhiteCybieEX','RS_WhiteSPFusion':'RS_WhiteSPPlus','RS_WhiteSPFusion2':'RS_WhiteSPFusion','RS_WhiteSPFusion3':'RS_WhiteSPFusion'}
for c,pc in PAR.items():
    if c in labels and pc in labels: labels[c]=list(dict.fromkeys(labels[c]+labels[pc]))
# children inherit parent's labels
for b in BODIES:
    if b not in labels: labels[b]=['See','Missile','Pain','Death']
cases='\n'.join('\t\tif (c == "%s") { static const String L[] = {%s}; }'%(b,'') for b in [])  # unused
fn=['\tstatic void Labels(Name c, out Array<String> a)\n\t{\n\t\ta.Clear();']
for b,L in labels.items():
    fn.append('\t\tif (c == \'%s\') { %s return; }'%(b,' '.join('a.Push("%s");'%l for l in L)))
fn.append('\t}')
open('/home/claude/scratch_plusex/probe/labels.zs','w').write('class RSPX_Labels\n{\n'+'\n'.join(fn)+'\n}\n')
print({k:len(v) for k,v in labels.items()})
