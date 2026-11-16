# apply_readme_art.py <repo>: gives every README the same presentation.
#   - the page's animated title above its first heading (mods/<key>_title.gif), once
#   - every "## Heading" becomes an animated word header in the page's colour (heads/<key>/<slug>.gif), with an
#     <a name="slug"> in front of it so links to the section keep working
#   - a still divider (mods/<key>_divider.png) before each of those headers, and in place of a "---" rule
# Safe to run again: a page already done only gets headers for any new "## " lines.
import sys,os,re
HERE=os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(HERE,'readme_art_lib.py')).read().split("if __name__")[0])
ART='design/readme_art'
C2=dict(COL); C2.update({'brown':((150,84,30),(236,170,100)),'white':((200,204,214),(255,255,255)),'abyss':((90,50,190),(190,150,255))})
TXT={'yellow':'gold','cyan':'cyan','green':'green','purple':'purple','black':'steel','fireblu':'orange','blue':'blue','red':'red','gray':'steel','brown':'brown','white':'white','abyss':'abyss'}
PAGES={ # README path: (key, alt for the title or None, colour)
'README.md':('front',None,None),
'GunBonsaiOffhandVR':('gunbonsaioffhandvr','RSQ Gun Bonsai VR','yellow'),'Accessibility':('accessibility','RSQ Accessibility','cyan'),'Score':('score','RSQ Score','green'),
'SlowMo':('slowmo','RSQ SlowMo','purple'),'Miniboss':('miniboss','RSQ Miniboss','black'),'VisualRewards':('visualrewards','RSQ Visual Rewards','fireblu'),
'TacticalRig':('tacticalrig','RSQ Tactical Rig','green'),'GunCards':('guncards','RSQ Gun Cards','blue'),'FlashFlare':('flashflare','RSQ FnF','yellow'),
'Grenade':('grenade','RSQ Grenade','red'),'DistanceGrab':('distancegrab','RSQ Distance Grab','cyan'),'LaserSight':('lasersight','RSQ Laser Sight','red'),
'QuestSaber':('questsaber','RSQ Saber','blue'),'GlowInTheDark':('glowinthedark','RSQ Glow In The Dark','fireblu'),'Graveyard':('graveyard','RSQ Graveyard','gray'),
'Monsters':('monsters','RSQ Monsters','purple'),'Melee':('melee','RSQ Melee','red'),'ShieldSaw':('shieldsaw','RSQ ShieldSaw','brown'),'Wheel':('wheel','RSQ Wheel','white'),
'Whip':('whip','RSQ Whip','brown'),'Grapple':('grapple','RSQ Grapple','abyss'),
'MonsterRecolour':('monsterrecolour','RSQ Monster Recolour','red'),'weaponsets/GNRC_Reloaded':('gnrc_reloaded','GNRC Reloaded VR','yellow'),
'weaponsets/WoS_Reloaded':('wos_reloaded','WoS Reloaded','purple'),'WADs':('wads','WADs','green'),'Renders':('renders','Renders','red'),'TestRig':('testrig','TestRig','cyan')}
FRONT_CYCLE=['steel','lime','cyan','orange','gold','pink','blue','green','red','purple']
OK=set(chr(c) for c in F1)
def plain(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h); return re.sub(r'[`*]','',h).strip()
def slug(h):
    s=plain(h).lower(); s=re.sub(r'[^\w\- ]','',s,flags=re.UNICODE); return s.replace(' ','-')
def art_text(h):
    s=plain(h).upper()
    for a,b in (('’',"'"),('‘',"'"),('“','"'),('”','"'),('—','-'),('–','-'),('·','-'),('É','E')): s=s.replace(a,b)
    s=''.join(c for c in s if c in OK); s=re.sub(r' +',' ',s).strip()
    def w(x,sc): return (mask(x).width+2)*sc
    for cand in (s, s.split(' (')[0], s.split(' (')[0].split(':')[0], s[:44].rsplit(' ',1)[0]):
        cand=cand.strip()
        if cand and w(cand,3)<=880: return cand,3
        if cand and w(cand,2)<=880: return cand,2
    return s[:30],2
def run(root):
    made=0
    for path,(key,title,col) in PAGES.items():
        f=path if path.endswith('.md') else path+'/README.md'
        full=os.path.join(root,f); raw=open(full,'rb').read(); nl='\r\n' if b'\r\n' in raw else '\n'
        L=raw.decode('utf-8').split(nl); up='../'*f.count('/')
        div=f'<p align="center"><img src="{up}{ART}/mods/{key}_divider.png" alt=""></p>'
        if title and not any(f'{key}_title.gif' in l for l in L[:3]):
            L=[f'<p align="center"><img src="{up}{ART}/mods/{key}_title.gif" alt="{title}"></p>','']+L
        out=[]; fence=False; seen={}; n=0
        for l in L: # anchors already on the page, so a re-run numbers repeats the same way
            m=re.match(r'<a name="([^"]+)"></a><img [^>]*heads/',l)
            if m: seen[re.sub(r'-\d+$','',m.group(1))]=seen.get(re.sub(r'-\d+$','',m.group(1)),0)+1
        seen2={}
        for i,l in enumerate(L):
            if l.lstrip().startswith('```'): fence=not fence
            if not fence and l.strip()=='---' and (i==0 or L[i-1].strip()==''):
                out.append(div); continue
            if not fence and l.startswith('## '):
                h=l[3:].strip(); s=slug(h); k=seen2.get(s,0); seen2[s]=k+1; anchor=s if k==0 else f'{s}-{k}'
                text,sc=art_text(h); look=TXT[col] if col else FRONT_CYCLE[n%len(FRONT_CYCLE)]; n+=1
                os.makedirs(os.path.join(root,ART,'heads',key),exist_ok=True)
                gp=os.path.join(root,ART,'heads',key,anchor[:60]+'.gif')
                COL[look]=C2[look]; header(text,look,gp,sc=sc); made+=1
                prev=[x for x in out if x.strip()]
                if not prev or prev[-1]!=div: out+=[div,'']
                alt=plain(h).replace('"','&quot;')
                out.append(f'<a name="{anchor}"></a><img src="{up}{ART}/heads/{key}/{anchor[:60]}.gif" alt="{alt}"{" height=\"44\"" if sc==3 else ""}>')
                continue
            out.append(l)
        open(full,'wb').write(nl.join(out).encode('utf-8'))
    print(made,'headers made')
if __name__=='__main__': run(sys.argv[1])
