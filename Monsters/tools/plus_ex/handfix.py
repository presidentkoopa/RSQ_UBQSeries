# hand edits applied after place.sh (each one is a reviewed change; keep in step with the report)
import re,sys
D='/home/claude/wt_plusex/Monsters/zscript/monsters/plus/'
def sub(f,old,new,count=1,regex=False):
    p=D+f; s=open(p).read()
    if regex:
        s2,n=re.subn(old,new,s)
    else:
        n=s.count(old); s2=s.replace(old,new)
    if n==0 or (count and n!=count):
        print('HANDFIX MISS',f,repr(old[:60]),n); 
    open(p,'w').write(s2)
sub('RS_PlusWhiteMind.zs','\t\tDropItem "VoidOrb";','\t\t// CHP: DropItem "VoidOrb" -- a cross-mod pickup no pack here defines (stripped as in the 1.04 port, RS_MastermindFX.zs)')
sub('RS_PlusWhiteCybieEX.zs','\t\tDropItem "BiggerThickerLonger";','\t\t// CHP: DropItem "BiggerThickerLonger" -- cross-mod pickup, stripped as in the 1.04 port (RS_Cyberdemon.zs)')
# The Everlasting Machine's thralls: CHP's CommonWhiteSpidBlack* (16/16_W:16400..) are the Black bosses with
# Species "MMind", +THRUSPECIES, +DONTHARMSPECIES (they and the Mastermind leave each other alone) and their own
# death states (the same deaths, gore chain and announcer-free). Here: our Black bodies with that species and those flags.
TH=['BlackZombie1','BlackSG3','BlackImp1','BlackCGuy2','BlackDemon3','BlackSpectre2','BlackRevenant3','BlackCaco2','BlackHK2','BlackSP2','BlackFatso2']
p=D+'RS_PlusWhiteMind.zs'; s=open(p).read()
for t in TH:
    s=s.replace('DropItem "RS_%s", 255, 1;'%t,'DropItem "RS_WhiteSpid%s", 255, 1;'%t)
s+='\n// The Everlasting Machine\'s thralls (CHP 16/16_W:16400-21150, CommonWhiteSpidBlack*): our Black bodies, in the\n// Mastermind\'s species so they and it leave each other alone. CHP\'s rewritten death states for them are not ported\n// (each keeps its 1.04 death; CHP\'s differ only by the announcer-free gore lines).\n'
for t in TH:
    s+='class RS_WhiteSpid%s : RS_%s { Default { Species "MMind"; +THRUSPECIES +DONTHARMSPECIES } }\n'%(t,t)
open(p,'w').write(s)
# CHP's sounds under rsplus/ (SNDINFO.plusex)
import glob,json
NEED=['4thwall','binary','glitch','hellsmith/active','hellsmith/death','hellsmith/pain','hellsmith/sight','letterc','puzslv','reactor1','romeex/act','romeex/atk1','romeex/atk2','romeex/ded','romeex/ph2','romeex/ph3','romeex/see','spmdash','spmding','spmfx1','spmhop1','spmlaser','spmsummn','spmtarg','spmtarg2','spmwarp1','spmwarp2','time01','time02','time03','tornado/active','tornado/death','tornado/form','tornado/pain','tornado/see','truromro','wind/away','wmindfly','wmindrag','wspexact','wspexatk','wspexdt2','wspexdth','wspexpai','wspexsit','wvexactv','wvexdeth','wvexdscr','wvexpain','wvexsigt','wvextake']
for p in glob.glob(D+'RS_Plus*.zs'):
    if p.endswith('RS_PlusEX.zs'): continue
    s=open(p).read()
    labels=set(x.lower() for x in re.findall(r'^\t(\w+):',s,re.M))
    def rep(m):
        v=m.group(1)
        if v.lower() in NEED and v.lower() not in labels: return '"rsplus/%s"'%v.lower()
        return m.group(0)
    s=re.sub(r'"([\w/]+)"',rep,s)
    open(p,'w').write(s)
# CHP's leaves (LEF1/LEF2) are Champions' sprite names with another picture (Monsters/docs/SPRITE_CLASHES_2026-11-16.md
# removed ours): CHP's frames ship as RLF1/RLF2 (sprites/monsters/plus).
for p in glob.glob(D+'RS_Plus*.zs'):
    s=open(p).read(); s2=re.sub(r'^(\t\t)LEF([12]) ',r'\1RLF\2 ',s,flags=re.M)
    if s2!=s: open(p,'w').write(s2)
# CHP colours its tags and obituaries with its own TEXTCOLO names (\c[ColorKX] black, \c[ColorWX], \c[ColorW]) that this
# pack does not define: the text is kept, the colour codes are taken out (a black name is unreadable on the HUD).
for p in glob.glob(D+'RS_Plus*.zs'):
    s=open(p).read()
    s2=re.sub(r'^(\t\t(?:Tag|Obituary|HitObituary)\s+"[^\n]*)$',lambda m: m.group(1).replace('\\c-','') if True else '',s,flags=re.M|re.I)
    s2=re.sub(r'^(\t\t(?:Tag|Obituary|HitObituary)\s+"[^\n]*)$',lambda m: re.sub(r'\\c\[\w+\]','',m.group(1)),s2,flags=re.M|re.I)
    if s2!=s: open(p,'w').write(s2)
