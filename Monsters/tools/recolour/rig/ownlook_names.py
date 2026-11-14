#!/usr/bin/env python3
"""TEST ONLY: RS_BDTier.zs's KeepsOwnLook name rule (OwnLookName) in Python, run over every ACTOR name in unpacked
DECORATE text (BD22, XMVE: unpack into your own new empty dirs; this only reads text). Prints the classes whose answer
changed against the old substring rule (2026-11-13): those that now follow the body's colour, those that now keep their
own look. Keep SUB / WORD / BODY in step with RS_BDTier.zs.

    python3 -I ownlook_names.py /tmp/bd22_text /tmp/xmve_text"""
import re, os, sys
names=set()
for root in sys.argv[1:]:
    for d,_,fs in os.walk(root):
        for f in fs:
            p=os.path.join(d,f)
            try: t=open(p,errors='ignore').read()
            except: continue
            for m in re.finditer(r'(?im)^\s*actor\s+([A-Za-z0-9_]+)', t): names.add(m.group(1))
OLD=["blood","smoke","fire","flame","flare","spark","puff","tracer","casing","shell","explo","light","plasma","splash","water","dust","trail","bullet","shock","steam","fog","ring","ember","burn","brass","mist","droped","dropped","gun","rifle","weapon","ammo","clip","mag"]
SUB=["blood","gore","smearer","smoke","flame","flare","spark","puff","tracer","casing","plasma","splash","steam","brass","fog","particle","flashlight","shrapnel","explosion","bullet","mist"]
WORD=["fire","light","shell","water","dust","trail","shock","ring","ember","burn","drop","rifle","weapon","ammo","clip","mag"]
BODY=["guy","gunner","zombie","man","marine","dead","head","gib","death","xdeath","half","dying","frozen","major","soldier","trooper","corpse","body","torso","arm","leg","grabbed","throwed","punched","execute"]
def words(n):
    w=''
    for i,c in enumerate(n):
        up=c.isupper() and c.isascii(); lo=c.islower() and c.isascii()
        if not up and not lo: w+=' '; continue
        if up and i>0:
            p=n[i-1]; q=n[i+1] if i+1<len(n) else ''
            if (p.islower()) or (p.isupper() and q.islower()): w+=' '
        w+=c.lower()
    return w
MODS=["champion_","ld","rsq","rs_","ssq","ue_"]
def new(n):
    low=n.lower()
    if any(low.startswith(m) for m in MODS): return True
    if any(s in low for s in SUB): return True
    ws=words(n).split()
    if any(x.startswith(s) for x in ws for s in WORD): return True
    gun=any('gun' in x for x in ws)
    if gun and not any(any(b in x for b in BODY) for x in ws): return True
    return False
old=lambda n: any(s in n.lower() for s in OLD)
gained=sorted(n for n in names if old(n) and not new(n))
lost=sorted(n for n in names if new(n) and not old(n))
print(len(names),'classes; now FOLLOW the body (were skipped):',len(gained)); print(' '.join(gained))
print('\nnow SKIPPED (followed before):',len(lost)); print(' '.join(lost))
