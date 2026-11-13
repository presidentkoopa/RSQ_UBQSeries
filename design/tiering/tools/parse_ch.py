#!/usr/bin/env python3
"""Parse RSQ Monsters (ColorfulHell rebuild) classes: per family x tier stats.
Read-only over /home/claude/rsq_ubqseries/Monsters/zscript/monsters.
Writes JSON + CSV to /tmp/econ3/tiering/data/.
Damage numbers are ESTIMATES (mean of rolls; Doom 'Damage N' = N*4.5)."""
import re, os, json, glob, csv, statistics as st

ROOT = "/home/claude/rsq_ubqseries/Monsters/zscript/monsters"
OUT = "/tmp/econ3/tiering/data"
os.makedirs(OUT, exist_ok=True)

ID = {  # id defaults: health, speed, painchance, mass
 'ZombieMan':(20,8,200,100),'ShotgunGuy':(30,8,170,100),'ChaingunGuy':(70,8,170,100),
 'DoomImp':(60,8,200,100),'Demon':(150,10,180,400),'Spectre':(150,10,180,400),
 'Cacodemon':(400,8,128,400),'LostSoul':(100,8,256,50),'PainElemental':(400,8,128,400),
 'HellKnight':(500,8,50,1000),'BaronOfHell':(1000,8,50,1000),'Revenant':(300,10,100,500),
 'Fatso':(600,8,80,1000),'Arachnotron':(500,12,128,600),'Archvile':(700,15,10,500),
 'Cyberdemon':(4000,16,20,1000),'SpiderMastermind':(3000,12,40,1000),'Actor':(1000,0,0,100)}
# mean damage of id codepointer attacks (vanilla formulas)
IDATK = {'A_PosAttack':9,'A_SPosAttackUseAtkSound':27,'A_SPosAttack':27,'A_CPosAttack':9,
 'A_TroopAttack':13.5,'A_SargAttack':22.5,'A_HeadAttack':22.5,'A_BruisAttack':36,
 'A_SkullAttack':13.5,'A_SkelMissile':45,'A_SkelFist':33,'A_FatAttack1':54,'A_FatAttack2':54,
 'A_FatAttack3':54,'A_BspiAttack':22.5,'A_CyberAttack':90+64,'A_SpidRefire':0,'A_VileAttack':20+70,
 'A_PainAttack':13.5,'A_BulletAttack':9}

def mean_expr(s):
    s = s.strip()
    m = re.match(r'^\(?\s*f?random\w*\s*(?:\[\w*\])?\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)\s*\)?$', s)
    if m: return (float(m.group(1))+float(m.group(2)))/2
    m = re.match(r'^\(?\s*(-?[\d.]+)\s*\*\s*f?random\w*\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)\s*\)?$', s)
    if m: return float(m.group(1))*(float(m.group(2))+float(m.group(3)))/2
    m = re.match(r'^\(?\s*f?random\w*\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)\s*\*\s*(-?[\d.]+)\s*\)?$', s)
    if m: return float(m.group(3))*(float(m.group(1))+float(m.group(2)))/2
    m = re.match(r'^\(?\s*(-?[\d.]+)\s*\)?$', s)
    if m: return float(m.group(1))
    return None

def split_args(a):
    out, depth, cur = [], 0, ''
    for ch in a:
        if ch == '(' : depth += 1
        if ch == ')' : depth -= 1
        if ch == ',' and depth == 0: out.append(cur); cur=''
        else: cur += ch
    out.append(cur); return [x.strip() for x in out]

def calls(text, fn):
    res = []
    for m in re.finditer(r'\b'+fn+r'\s*\(', text):
        i = m.end(); depth = 1; j = i
        while j < len(text) and depth:
            if text[j]=='(' : depth+=1
            elif text[j]==')': depth-=1
            j+=1
        res.append(split_args(text[i:j-1]))
    return res

classes = {}
for f in sorted(glob.glob(ROOT+"/**/*.zs", recursive=True)):
    lines = open(f, encoding='utf-8', errors='replace').read().split('\n')
    starts = [(i, re.match(r'^class\s+(\w+)\s*(?::\s*(\w+))?', l)) for i,l in enumerate(lines)]
    starts = [(i,m) for i,m in starts if m]
    for k,(i,m) in enumerate(starts):
        end = starts[k+1][0] if k+1 < len(starts) else len(lines)
        body = '\n'.join(lines[i:end])
        classes[m.group(1)] = dict(name=m.group(1), parent=m.group(2) or '', file=os.path.relpath(f, "/home/claude/rsq_ubqseries"), line=i+1, body=body)

def default_block(b):
    m = re.search(r'Default\s*\{(.*?)\n\s*\}', b, re.S)
    return m.group(1) if m else ''

def prop(c, key):
    d = default_block(c['body'])
    m = re.search(r'^\s*'+key+r'\s+([^;]+);', d, re.M|re.I)
    return m.group(1).strip() if m else None

def resolve(name, key, idx=None):
    seen = 0
    while name and seen < 12:
        c = classes.get(name)
        if c:
            v = prop(c, key)
            if v is not None: return v
            name = c['parent']
        else:
            if name in ID and idx is not None: return str(ID[name][idx])
            return None
        seen += 1
    return None

def resolve_num(name, key, idx):
    seen=0
    while name and seen<12:
        c = classes.get(name)
        if c:
            d = default_block(c['body'])
            m = re.search(r'^\s*'+key+r'\s+(-?[\d.]+)\s*;', d, re.M)
            if m: return m.group(1)
            name = c['parent']
        else:
            return str(ID[name][idx]) if name in ID else None
        seen+=1
    return None

IDVOL = {'ZombieMan':9,'ShotgunGuy':27,'ChaingunGuy':18,'DoomImp':13.5,'Demon':22.5,'Spectre':22.5,'Cacodemon':22.5,
 'LostSoul':13.5,'PainElemental':13.5,'HellKnight':36,'BaronOfHell':36,'Revenant':45,'Fatso':162,'Arachnotron':22.5,
 'Archvile':90,'Cyberdemon':152.5,'SpiderMastermind':27}

def id_root(name):
    seen=0
    while name and seen<12:
        if name in ID and name!='Actor': return name
        c = classes.get(name)
        if not c: return name
        name = c['parent']; seen+=1
    return 'Actor'

def proj_damage(pname, depth=0):
    c = classes.get(pname)
    if not c or depth>4: return None
    d = default_block(c['body'])
    dmg = None
    m = re.search(r'DamageFunction\s*\((.*)\)\s*;', d)
    if m: dmg = mean_expr(m.group(1))
    else:
        m = re.search(r'^\s*Damage\s+\(([^;]*)\)\s*;', d, re.M)
        if m: dmg = mean_expr(m.group(1))
        else:
            m = re.search(r'^\s*Damage\s+([\d.]+)\s*;', d, re.M)
            if m: dmg = float(m.group(1))*4.5
    if dmg is None and c['parent'] in classes:
        dmg = proj_damage(c['parent'], depth+1)
    ex = 0
    for a in calls(c['body'], 'A_Explode'):
        v = mean_expr(a[0]) if a and a[0] else 128
        if v: ex = max(ex, v*0.5)
    return (dmg or 0) + ex

def attack_damage(c):
    """Per state label: summed estimated damage of attack calls."""
    b = c['body']
    sm = re.search(r'States\s*\{(.*)', b, re.S)
    if not sm: return {}
    stx = sm.group(1)
    labels = {}
    cur = None
    for line in stx.split('\n'):
        lm = re.match(r'^\s*([A-Za-z][\w.]*)\s*:\s*(//.*)?$', line)
        if lm: cur = lm.group(1); labels.setdefault(cur, ''); continue
        if cur: labels[cur] += line+'\n'
    res = {}
    for lab, t in labels.items():
        if re.match(r'(Death|XDeath|Raise|Spawn|Pain|Crush|Death\.|XDeath\.|Pain\.)', lab): continue
        dmg = 0.0
        for a in calls(t, 'A_CustomBulletAttack'):
            try:
                n = mean_expr(a[2]) or 1; dv = mean_expr(a[3]) or 0
                norand = len(a) > 6 and 'NORANDOM' in ' '.join(a[5:])
                dmg += n * dv * (1 if norand else 2)
            except Exception: pass
        for fn in ('A_CustomMissile','A_SpawnProjectile','A_FireCustomMissile'):
            for a in calls(t, fn):
                p = a[0].strip('"')
                pd = proj_damage(p)
                if pd: dmg += pd
        for a in calls(t, 'A_CustomMeleeAttack'):
            v = mean_expr(a[0]) if a and a[0] else None
            if v: dmg += v
        for a in calls(t, 'A_MeleeAttack'): pass
        for a in calls(t, 'A_CustomComboAttack'):
            pd = proj_damage(a[0].strip('"')) or 0; dmg += pd
        for a in calls(t, 'A_RailAttack'):
            v = mean_expr(a[0]); dmg += v or 0
        for k,v in IDATK.items():
            dmg += v * len(re.findall(r'\b'+k+r'\b', t))
        # repeated frames: 'POSS FFF 4 A_CustomBulletAttack' fires per letter
        if dmg:
            mult = 1.0
            fr = re.findall(r'^\s*\w{4}\s+([A-Z\[\]\\]+)\s+-?\d+\s+(?:Bright\s+)?(?:Fast\s+)?A_(?:CustomBulletAttack|CustomMissile|SpawnProjectile|CustomMeleeAttack)', t, re.M)
            if fr:
                tot = sum(len(x) for x in fr); mult = tot/len(fr)
            res[lab] = round(dmg*mult,1)
    return res

ABIL = [
 ('heal_others', r'A_RadiusGive\([^)]*Health|HealThing|A_VileChase|RaiseActor|A_RaiseChildren|A_RaiseSiblings'),
 ('self_heal', r'A_SetHealth|GiveBody|health\s*\+='),
 ('hop_leap', r'A_ChangeVelocity|ThrustThingZ|A_Recoil|vel\.z\s*=|A_SkullAttack|A_Leap'),
 ('ice', r'"Ice"|IceDamage|Freeze|DamageType\s+"Cold"|"Frost'),
 ('fire', r'DamageType\s+"Fire"|"Fire"'),
 ('poison', r'Poison|"Gas"|Toxic'),
 ('split_or_spawn_on_death', None),
 ('summons', None),
 ('teleport_warp', r'A_Warp\(|Teleport|A_Blink|SetOrigin'),
 ('translucent', r'RenderStyle\s+"(Translucent|Add|Shadow|Fuzzy|SoulTrans|Subtract)"|\+SHADOW|A_SetTranslucent|A_FadeOut|A_FadeIn|Alpha\s+0\.'),
 ('nopain_or_armour', r'\+NOPAIN|PainChance\s+0\s*;|\+REFLECTIVE|\+INVULNERABLE|bINVULNERABLE|\+NORADIUSDMG|\+DONTRIP|\+NODAMAGETHRUST|\+NOBLOOD'),
 ('fast', r'A_FastChase|\+ALWAYSFAST|\+MISSILEEVENMORE'),
 ('retier_others', r'Pain\.\w+:|AbyssMark'),
 ('rail', r'A_RailAttack'),
 ('homing', r'\+SEEKERMISSILE|A_Tracer|A_SeekerMissile'),
 ('shield_reflect', r'\+REFLECTIVE|\+SHIELDREFLECT|\+MIRRORREFLECT|\+AIMREFLECT'),
 ('flying', r'\+FLOAT|\+NOGRAVITY'),
]
MONCLS = None

def deathspawns(c):
    b = c['body']
    out = set()
    sm = re.search(r'States\s*\{(.*)', b, re.S)
    if not sm: return out, out
    stx = sm.group(1); cur=None; dsp=set(); msp=set()
    for line in stx.split('\n'):
        lm = re.match(r'^\s*([A-Za-z][\w.]*)\s*:\s*(//.*)?$', line)
        if lm: cur = lm.group(1); continue
        for a in calls(line, 'A_SpawnItemEx') + calls(line, 'A_SpawnItem'):
            n = a[0].strip('"')
            cc = classes.get(n)
            if cc and ('Monster;' in default_block(cc['body']) or re.search(r'Colourset|Zombie|Imp\d|Demon\d|Soul\d|LSoul|Caco\d', n)) and not n.startswith('RS_ColorTierIcon'):
                if cur and (cur.startswith('Death') or cur.startswith('XDeath') or 'Grow' in cur): dsp.add(n)
                elif cur and not cur.startswith('Pain.'): msp.add(n)
    return dsp, msp

FAM_NAMES = {0:'Chaingunner',1:'Revenant',2:'Mancubus',3:'Arch-Vile',4:'Baron',5:'Lost Soul',6:'Pain Elemental',
 7:'Cyberdemon',8:'Spider Mastermind',9:'Demon',10:'Cacodemon',11:'Hell Knight',12:'Arachnotron',13:'Imp',
 14:'Shotgunner',15:'Spectre',16:'Zombieman'}
TIERN = ['','Common','Green','Blue','Purple','Cyan','Brown','Yellow','FireBlu','Gray','Red','Abyss','Black','White']

# ladder from RS_Retier.zs ClassFor
rt = open(ROOT+"/RS_Retier.zs").read()
cf = rt[rt.index('static Name ClassFor'):rt.index('static Name GateFor')]
ladder = {}
fam = None
for line in cf.split('\n'):
    m = re.search(r'if \(fam == (\d+)\)', line)
    if m: fam = int(m.group(1)); ladder[fam] = {}
    m = re.search(r"if \(tier == (\d+)\) return '(\w+)'", line)
    if m and fam is not None: ladder[fam][int(m.group(1))] = m.group(2)

def info(cn):
    c = classes.get(cn)
    if not c: return dict(cls=cn, missing=True)
    hp = resolve(cn, 'Health', 0); sp = resolve(cn, 'Speed', 1); pc = resolve_num(cn, 'PainChance', 2)
    body = c['body']
    # include parent bodies (RS_ only) for ability scan
    full = body; p = c['parent']; k=0
    while p in classes and k<6: full += classes[p]['body']; p = classes[p]['parent']; k+=1
    ab = [k for k,rx in ABIL if rx and re.search(rx, full)]
    dsp, msp = deathspawns(c)
    if dsp: ab.append('spawns_on_death:'+','.join(sorted(dsp)))
    if msp: ab.append('spawns_in_fight:'+','.join(sorted(msp)))
    atk = attack_damage(c)
    if not atk and c['parent'] in classes: atk = attack_damage(classes[c['parent']])
    if not atk and id_root(cn) in IDVOL: atk = {'(id attack)': IDVOL[id_root(cn)]}
    rs = prop(c,'RenderStyle'); al = prop(c,'Alpha'); tr = 'Translation' in default_block(body)
    df = re.findall(r'DamageFactor\s+("?\w*"?\s*,?\s*[\d.]+)', default_block(body))
    return dict(cls=cn, parent=c['parent'], idroot=id_root(cn), file=c['file'], line=c['line'],
                health=int(float(hp)) if hp and re.match(r'^-?[\d.]+$',hp) else hp,
                speed=float(sp) if sp and re.match(r'^-?[\d.]+$',sp) else sp,
                painchance=pc, renderstyle=rs, alpha=al, has_translation=tr, damagefactors=df,
                tag=(prop(c,'Tag') or '').strip('"'), abilities=ab, attacks=atk,
                volley=max(atk.values()) if atk else 0)

rows = []
for f in range(17):
    for t in range(1,14):
        cn = ladder[f][t]
        d = info(cn); d['family']=FAM_NAMES[f]; d['fam']=f; d['tier']=t; d['colour']=TIERN[t]
        rows.append(d)
# EX forms
ex = [n for n in classes if n.endswith('EX') and n.startswith('RS_') and 'Monster;' in default_block(classes[n]['body'])]
exrows = [info(n) for n in sorted(ex)]

json.dump(dict(ladder=rows, ex=exrows), open(OUT+'/ch_ladder.json','w'), indent=1)
with open(OUT+'/ch_ladder.csv','w',newline='') as fh:
    w = csv.writer(fh)
    w.writerow(['family','tier','colour','class','parent','idroot','file:line','health','hp_x_common','speed','painchance','volley_est','volley_x_common','renderstyle','alpha','abilities'])
    for f in range(17):
        fam_rows=[r for r in rows if r['fam']==f]
        base = fam_rows[0]
        for r in fam_rows:
            hx = round(r['health']/base['health'],2) if isinstance(r['health'],int) and isinstance(base['health'],int) else ''
            vx = round(r['volley']/base['volley'],2) if base['volley'] else ''
            w.writerow([r['family'],r['tier'],r['colour'],r['cls'],r['parent'],r['idroot'],f"{r['file']}:{r['line']}",r['health'],hx,r['speed'],r['painchance'],r['volley'],vx,r['renderstyle'],r['alpha'],'; '.join(r['abilities'])])
print("ok", len(rows), "ladder rows,", len(exrows), "EX")
