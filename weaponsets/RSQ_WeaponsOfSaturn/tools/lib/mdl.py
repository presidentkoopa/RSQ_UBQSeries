"""Build a pack's MODELDEF from BD22 VR's: every block of a BD22 gun is copied under the pack's class for that gun."""
import re, os, sys
sys.path.insert(0, '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/tools')
import handtone_build
BD = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src'
SRC = ['MODELDEF.bd.txt', 'MODELDEF.rsr', 'MODELDEF.rsrpump', 'MODELDEF.rsm', 'MODELDEF.rsb', 'MODELDEF.rsq', 'MODELDEF.rsbullet', 'MODELDEF.rsqoff', 'MODELDEF.rsqdual']
BLOCK = re.compile(r'^([ \t]*)Model[ \t]+"?(\w+)"?\s*\{(.*?)^[ \t]*\}', re.S | re.I | re.M)
def nocomment(t): return re.sub(r'//[^\n]*', '', re.sub(r'/\*.*?\*/', '', t, flags=re.S))
def build(alias, helpers):
    """alias: {pack class: BD class}; helpers: classes copied as they are.
    -> {lump name: text}, files, keyed {class: set((sprite, frame))}, sprites, missing files"""
    by_bd = {}
    for k, v in alias.items(): by_bd.setdefault(v.lower(), []).append(k)
    lumps = {}; files = set(); keyed = {}; sprites = set(); missing = []
    for f in SRC:
        raw = open(os.path.join(BD, f), encoding='latin-1').read()
        out = []
        for m in BLOCK.finditer(raw):
            cls, body = m.group(2), m.group(3)
            if cls.lower() in by_bd: targets = by_bd[cls.lower()]
            elif cls in helpers: targets = [cls]
            else: continue
            code = nocomment(body)
            pm = re.search(r'^\s*Path\s+"([^"]*)"', code, re.M | re.I)
            path = pm.group(1).rstrip('/') if pm else ''
            for fm in re.finditer(r'^\s*(?:Model\s+\d+|Skin\s+\d+|SurfaceSkin\s+\d+\s+\d+)\s+"([^"]+)"', code, re.M | re.I):
                name = fm.group(1)
                for cand in (path + '/' + name, name):
                    if os.path.isfile(os.path.join(BD, cand)): files.add(cand); break
                else: missing.append((f, cls, name))
            fr = set()
            for fm in re.finditer(r'^\s*FrameIndex\s+(\S+)\s+(\S+)\s+\d+\s+\d+', code, re.M | re.I):
                fr.add((fm.group(1).upper(), fm.group(2).upper())); sprites.add(fm.group(1).upper())
            for t in targets:
                keyed.setdefault(t, set()).update(fr)
                out.append('Model %s\n{%s}\n' % (t, body))
        if out:
            head = "// from BD22 VR's %s (RS_Brutal22WeaponsQ), by tools/port/mdl.py: the gun class names are this pack's\n\n" % f
            txt, n = handtone_build.transform(head + '\n'.join(out))
            lumps['MODELDEF.' + f.split('.', 1)[1].replace('.txt', '')] = txt
    return lumps, files, keyed, sprites, missing
