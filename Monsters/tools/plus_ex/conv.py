# DECORATE -> ZScript converter for the CHP EX bosses (RSQ Monsters conventions)
import json,re,sys
P=json.load(open('/home/claude/scratch_plusex/plus_idx.json'))
O=json.load(open('/home/claude/scratch_plusex/ch104_idx.json'))
OURS=set(l.strip().lower() for l in open('/home/claude/scratch_plusex/our_classes.txt'))
OURS_CASE={l.strip().lower():l.strip() for l in open('/home/claude/scratch_plusex/our_classes.txt')}
NAMEMAP={}   # lower plus/104 name -> our class name (set by driver)
def ourname(n):
    k=n.lower()
    if k in NAMEMAP: return NAMEMAP[k]
    return None
ENGINE_PARENTS={'fastprojectile':'FastProjectile','archvilefire':'ArchvileFire','cacodemonball':'CacodemonBall','powerspeed':'PowerSpeed',
 'powerprotection':'PowerProtection','powerup':'Powerup','powerupgiver':'PowerupGiver','inventory':'Inventory','randomspawner':'RandomSpawner',
 'bulletpuff':'BulletPuff','customInventory':'CustomInventory'}
FLOWRE=re.compile(r'^(goto\s+\S.*|loop|stop|wait|fail)$',re.I)
NAMEPROPS={'renderstyle','damagetype','species','decal','paintype','deathtype','bloodtype','bouncetype','inventory.icon','powerup.type','powerup.mode','defthreshold'}
def split_args(s):
    out=[];d=0;cur='';q=False
    for i,c in enumerate(s):
        if q:
            cur+=c
            if c=='"' and s[i-1]!='\\': q=False
            continue
        if c=='"': q=True; cur+=c; continue
        if c in '([': d+=1
        if c in ')]': d-=1
        if c==',' and d==0: out.append(cur); cur=''; continue
        cur+=c
    out.append(cur)
    return out
def find_call(s,start):
    # s[start] == '(' ; return index of matching ')'
    d=0;q=False
    for i in range(start,len(s)):
        c=s[i]
        if q:
            if c=='"' and s[i-1]!='\\': q=False
            continue
        if c=='"': q=True
        elif c=='(': d+=1
        elif c==')':
            d-=1
            if d==0: return i
    return -1
NOTES=[]
def map_strings(expr,labels):
    def rep(m):
        s=m.group(1)
        if s.lower() in labels: return m.group(0)
        o=ourname(s)
        return '"%s"'%o if o else m.group(0)
    return re.sub(r'"([\w\.]+)"',rep,expr)
def conv_expr(e):
    e=re.sub(r'\b(momx|velx)\b','vel.x',e,flags=re.I)
    e=re.sub(r'\b(momy|vely)\b','vel.y',e,flags=re.I)
    e=re.sub(r'\b(momz|velz)\b','vel.z',e,flags=re.I)
    return e
ACSMAP={}  # script name lower -> replacement action text ('' strips)
def conv_action(a,labels,actor):
    a=a.strip()
    if not a: return ''
    # function name
    m=re.match(r'([\w\.]+)\s*(\(.*\))?\s*$',a,re.S)
    if not m: 
        NOTES.append('UNPARSED action in %s: %s'%(actor,a)); return a
    fn=m.group(1); args=m.group(2)
    fl=fn.lower()
    inner=args[1:-1] if args else ''
    A=[x.strip() for x in split_args(inner)] if args else []
    if fl in ('acs_namedexecutealways','acs_namedexecute','acs_namedterminate','acs_namedexecutewithresult'):
        sn=A[0].strip('"').lower()
        key=(fl if fl=='acs_namedterminate' else 'x')+':'+sn
        if key in ACSMAP: return ACSMAP[key]
        if sn in ACSMAP: return ACSMAP[sn]
        NOTES.append('UNMAPPED ACS %s in %s'%(a,actor)); return '/*ACS?*/'
    if fl=='a_changeflag':
        f=A[0].strip('"'); v=A[1].lower()
        v={'1':'true','0':'false'}.get(v,v)
        f=f.replace('.','')  # INVENTORY.x unlikely
        if f.upper()=='MISSILEMORE': return '{ RS_MissileChance.SetMore(self, %s); }'%v
        if f.upper()=='MISSILEEVENMORE': return '{ RS_MissileChance.SetEvenMore(self, %s); }'%v
        return '{ b%s = %s; }'%(f.upper(),v)
    if fl in ('a_setuservar','a_setuservarfloat'):
        var=A[0].strip('"'); val=conv_expr(map_strings(A[1],labels))
        val=re.sub(r'^\s*\w+\s*=\s*','',val) if re.match(r'^\s*\w+\s*=[^=]',val) else val
        return '{ %s = %s; }'%(var.lower(),val)
    if fl=='thrustthing':
        A[0]='int(%s)'%A[0]
        return 'ThrustThing(%s)'%', '.join(conv_expr(x) for x in A)
    if fl in ('a_killchildren','a_killmaster','a_killsiblings','a_damagechildren','a_damagemaster','a_damagetarget','a_damageself') :
        A=[('"%s"'%x if re.match(r'^[A-Za-z_]\w*$',x) and x.lower() not in('true','false') and not x.upper().startswith(('KILS_','DMSS_','AAPTR_')) else x) for x in A]
    if fl=='a_customrailgun':
        A=[('0' if x.lower()=='"none"' and i in (2,3) else x) for i,x in enumerate(A)]
    if args is None: return fn
    out=fn+'('+', '.join(conv_expr(map_strings(x,labels)) for x in A)+')' if inner.strip() else fn+'()'
    # nested CallACS inside expressions
    def cacs(m):
        sn=m.group(1).lower()
        if 'call:'+sn in ACSMAP: return ACSMAP['call:'+sn]
        NOTES.append('UNMAPPED CallACS %s in %s'%(sn,actor)); return '0'
    out=re.sub(r'CallACS\s*\(\s*"(\w+)"\s*\)',cacs,out,flags=re.I)
    return out
INVFLAGS={'autoactivate','invbar','alwayspickup','additivetime','noscreenblink','undroppable','untossable','quiet','persistentpower','hubpower','alwaysrespawn','bigpowerup','neverrespawn','keepdepleted','ignoreskill','noscreenflash','fancypickupsound','noattenpickupsound','transfer','isarmor','ishealth','autoactivate'}
KW={'bright','fast','slow','nodelay','canraise'}
def conv_frame(line,labels,actor):
    s=line.strip()
    # sprite
    toks=[]
    m=re.match(r'("[^"]*"|\S+)\s+("[^"]*"|\S+)\s+(-?\d+|random\s*\([^)]*\))\s*(.*)$',s,re.I|re.S)
    if not m: NOTES.append('UNPARSED frame in %s: %s'%(actor,s)); return '\t\t'+s+';'
    spr,frm,dur,rest=m.groups()
    kws=[]
    while True:
        rest=rest.strip()
        mm=re.match(r'(bright|fast|slow|nodelay|canraise)\b',rest,re.I)
        if mm: kws.append(mm.group(1).capitalize() if mm.group(1).lower()!='nodelay' else 'NoDelay'); rest=rest[mm.end():]; continue
        mm=re.match(r'(offset|light)\s*\(',rest,re.I)
        if mm:
            j=find_call(rest,mm.end()-1); kws.append(mm.group(1).capitalize()+rest[mm.end()-1:j+1]); rest=rest[j+1:]; continue
        break
    if re.search(r'"NewIconCHP',rest,re.I): rest=''
    gore=''
    if re.search(r'"(CHRandom_GibGenerator|CHNashGore\w*|CHGore_\w*)"',rest,re.I):
        gore='   // CHP: %s -- gore chain stripped (standing order), the frame stays'%rest.strip(); rest=''
    act=conv_action(rest,labels,actor) if rest else ''
    if act.startswith('/*ACS?*/'): act=''
    if re.match(r'a_chase\(',act,re.I): act=act.replace('""','null')
    out='\t\t%s %s %s'%(spr,frm,dur)+(' '+' '.join(kws) if kws else '')+(' '+act if act else '')+('' if act.startswith('{') else ';')+gore
    return out
def tidy_prop(line,actor,members,flagsout):
    s=line.strip()
    if not s: return ''
    sl=s.lower()
    if re.match(r'^[+-]',s):
        fl=re.findall(r'[+-][\w\.]+',s)
        for f in fl:
            if f.lower() in ('+doombounce',): flagsout.append('\t\tBounceType "Doom";'); continue
            if f[1:].lower() in INVFLAGS: f=f[0]+'INVENTORY.'+f[1:].upper()
            if f[1:].lower()=='hexenbounce':
                flagsout.append('\t\tBounceType "%s";   // CHP: %s'%('Hexen' if f[0]=='+' else 'None',f)); continue
            if f[1:].lower()=='donthurtspecies': f=f[0]+'DONTHARMSPECIES   // CHP: '+f+' (its deprecated name)'
            flagsout.append('\t\t'+f)
        return None
    if sl=='translation none': return '\t\t// CHP: Translation None (the default)'
    if sl in ('monster','projectile','clearflags'): return '\t\t%s;'%s.capitalize()
    if sl.startswith('game ') or sl.startswith('spawnid'): return None
    m=re.match(r'var\s+(int|float|double)\s+(\w+)\s*(\[\s*\d+\s*\])?\s*;?',s,re.I)
    if m:
        t=m.group(1).lower(); t='double' if t=='float' else t
        members.append('\t%s %s%s;'%(t,m.group(2).lower(),m.group(3) or '')); return None
    m=re.match(r'([\w\.]+)\s*(.*)$',s)
    pn,val=m.group(1),m.group(2).strip().rstrip(';')
    pl=pn.lower()
    if pl=='damage' and val.startswith('('):
        return '\t\tDamageFunction %s;   // CHP: %s'%(conv_expr(val),s)
    if pl=='dropitem':
        a=split_args(val) if ',' in val else val.split()
        a=[x.strip() for x in a]
        nm=a[0].strip('"'); o=ourname(nm) or nm
        if nm.lower() in ('rareamorpool','rarearmorpool') or nm.lower().startswith('rl'):
            return '\t\t// CHP: %s -- DRLA stripped per owner 2026-08-05'%s
        return '\t\tDropItem "%s"%s;'%(o,''.join(', '+x for x in a[1:]))
    if pl in ('damagefactor','painchance','damagefactor') and re.match(r'^[A-Za-z_]\w*\s*,',val):
        i=val.find(','); val='"%s"%s'%(val[:i].strip(),val[i:])
    if pl=='powerup.type':
        v=val.strip('"')
        if not v.lower().startswith('power'): v='Power'+v
        val='"%s"'%v
    if pl in NAMEPROPS and val and not val.startswith('"'):
        if pl=='bouncetype' and val.lower()=='doom': val='Doom'
        val='"%s"'%val
    if pl in ('seesound','painsound','deathsound','activesound','attacksound','meleesound','howlsound','bouncesound','wallbouncesound','crushpainsound') and val and not val.startswith('"'):
        val='"%s"'%val
    # multi-value space separated (e.g. Powerup.Color "x" 0.5 or Scale) leave; commas ok
    return '\t\t%s%s;'%(pn,(' '+val) if val else '')
def convert(actor,newname,parent,extra_members=None,cite=None,tier=None,iconfn=None,post_states=None):
    raw=actor['text']
    t=re.sub(r'/\*.*?\*/',lambda m:re.sub(r'[^\n]','',m.group(0)),raw,flags=re.S)
    b=t.find('{'); e=t.rfind('}')
    body=t[b+1:e]
    lines=body.split('\n')
    props=[];flags=[];members=list(extra_members or []);states=[]
    # find states
    mode='props'; labels=set()
    # collect labels first
    sm=re.search(r'\bstates\b',body,re.I)
    if sm:
        st=body[sm.end():]
        for L in st.split('\n'):
            L2=re.sub(r'//.*','',L)
            for lm in re.finditer(r'^\s*([\w\.]+)\s*:',L2): labels.add(lm.group(1).lower())
    depth=0
    for L in lines:
        com=''
        mm=re.search(r'//.*$',L)
        code=L
        # careful with // inside strings
        if mm:
            pre=L[:mm.start()]
            if pre.count('"')%2==0: com=mm.group(0); code=pre
        c=code.strip()
        if mode=='props':
            if re.match(r'^states\b',c,re.I):
                mode='states'; continue
            if c=='{' or c=='}' : continue
            if not c:
                if com: props.append('\t\t'+com)
                continue
            r=tidy_prop(c,newname,members,flags)
            if r: props.append(r+(('   '+com) if com else ''))
            elif com: props.append('\t\t'+com)
        else:
            if c=='{' : continue
            if c=='}' : mode='done'; continue
            if c.startswith('{'): c=c[1:].strip()
            if c.endswith('}') and c.count('{')<c.count('}'): c=c[:-1].strip(); mode2='done'
            if not c:
                if com: states.append('\t\t'+com)
                continue
            # label(s), possibly followed by frame
            while True:
                lm=re.match(r'^([\w\.]+)\s*:\s*',c)
                if lm and not re.match(r'^\w+\s*::',c):
                    states.append('\t%s:'%lm.group(1)); c=c[lm.end():].strip()
                    if not c: break
                    continue
                break
            if not c:
                if com: states[-1]+= '   '+com
                continue
            if FLOWRE.match(c):
                w=c.split()[0].capitalize()
                rest=c[len(c.split()[0]):]
                states.append('\t\t%s%s;%s'%(w,rest,('   '+com) if com else ''))
                continue
            states.append(conv_frame(c,labels,newname)+(('   '+com) if com else ''))
    fl_l=[f.strip().lower() for f in flags]
    more='+missilemore' in fl_l; even='+missileevenmore' in fl_l
    if any(x in fl_l for x in ('+missilemore','+missileevenmore','-missilemore','-missileevenmore')):
        flags=[f for f in flags if f.strip().lower() not in ('+missilemore','+missileevenmore','-missilemore','-missileevenmore')]
        mult=0.0625 if (more and even) else (0.125 if even else (0.5 if more else 1.0))
        flags.append('\t\tMissileChanceMult %s;   // CHP: %s'%(mult,' '.join(f for f in fl_l if 'missile' in f and 'more' in f).upper()))
    out=[]
    out.append('class %s : %s   // CHP %s:%d (%s)'%(newname,parent,actor['file'].replace('DECORATE_dir/',''),actor['line'],actor['name']))
    out.append('{')
    out+=members
    if tier: 
        out.append('\toverride void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, %d); }'%tier)
    if iconfn:
        out.append(iconfn)
    out.append('\tDefault')
    out.append('\t{')
    out+=props+flags
    out.append('\t}')
    if states:
        out.append('\tStates')
        out.append('\t{')
        out+=states
        out.append('\t}')
    out.append('}')
    return '\n'.join(out)
