"""Build a pack's MODELDEF from BD22 VR's: every block of a BD22 gun is copied under the pack's class for that gun."""
import re, os, sys
sys.path.insert(0, os.path.join(os.environ.get('RSQGW_BD22VR', '/home/claude/rsq_bd_vr_reloaded'), 'tools'))
import handtone_build
BD = os.path.join(os.environ.get('RSQGW_BD22VR', '/home/claude/rsq_bd_vr_reloaded'), 'src')	# BD22 VR Reloaded's checkout (RSQGW_BD22VR to change it)
SRC = ['MODELDEF.bd.txt', 'MODELDEF.rsr', 'MODELDEF.rsrpump', 'MODELDEF.rsm', 'MODELDEF.rsb', 'MODELDEF.rsq', 'MODELDEF.rsbullet', 'MODELDEF.rsqoff', 'MODELDEF.rsqdual']
BLOCK = re.compile(r'^([ \t]*)Model[ \t]+"?(\w+)"?\s*\{(.*?)^[ \t]*\}', re.S | re.I | re.M)
def nocomment(t): return re.sub(r'//[^\n]*', '', re.sub(r'/\*.*?\*/', '', t, flags=re.S))
def build(alias, helpers, drop=()):
    """alias: {pack class: BD class}; helpers: classes copied as they are; drop: model folders (models/bd/<name>) of BD22
    guns the pack does not have: a block naming any file in one is left out, so the file is not carried.
    -> {lump name: text}, files, keyed {class: set((sprite, frame))}, sprites, missing files, dropped block count"""
    by_bd = {}
    for k, v in alias.items(): by_bd.setdefault(v.lower(), []).append(k)
    lumps = {}; files = set(); keyed = {}; sprites = set(); missing = []; dropped = 0
    dropdirs = tuple('models/bd/%s/' % d.lower() for d in drop)
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
            named = [fm.group(1) for fm in re.finditer(r'^\s*(?:Model\s+\d+|Skin\s+\d+|SurfaceSkin\s+\d+\s+\d+)\s+"([^"]+)"', code, re.M | re.I)]
            if dropdirs and any((path + '/' + nm).lower().startswith(dropdirs) or nm.lower().startswith(dropdirs) for nm in named):
                dropped += 1
                continue
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
    return lumps, files, keyed, sprites, missing, dropped
