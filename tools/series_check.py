#!/usr/bin/env python3
"""series_check.py -- a sanity check across the series' mods (owner, 2026-11-03: "18 interacting mods").

    python tools/series_check.py            both parts
    python tools/series_check.py static     the contract check only (seconds, no engine)
    python tools/series_check.py gate       the headless gate only (the hidden engine, the owner's full load order)

PART 1, THE CONTRACT CHECK (static). The mods talk to each other by NAME STRINGS, which nothing checks at compile
time: a service request (`GetInt("rope.speed")`), a network event (`SendNetworkEvent("rsm_pulse")`), a class reached
by string (`is "RSQSM_Round"`, `Spawn("...")`, `FindInventory("...")`). A renamed one returns -1 or null and the
feature silently stops. This part lists:
  - services asked for (ServiceIterator.Find) that no mod in the series declares;
  - requests asked of a series service that its class never compares against (by literal or by prefix);
  - network events sent, or bound to a key/menu, that no handler in the series looks for;
  - class names reached by string that no mod, the engine (qzdoom.pk3) or the rest of the load order declares.
Heuristics, not a compiler: a request's service is the nearest ServiceIterator.Find above it in the same file (or
the file's only one); an answer is any string literal compared in the service's file. Read the lists as leads.

PART 2, THE HEADLESS GATE. tools/qzd_hidden_run.ps1 with the OWNER'S FULL LOAD ORDER (the ZDL file: BD22, the
monster packs, Gun Bonsai, every RSQ pk3 from pk3/) plus tools/series_check/probe (asks for every series service and
one handler per mod at tic 35). Fails on a script error or warning, a MISSING service or handler, or a mod saying it
stood down / refused. What it cannot see: a headset, hands, how anything looks.

The report goes to tools/series_check/last_report.md (gitignored by the owner's choice: this tool is local).
"""
import os, re, sys, glob, zipfile, subprocess, datetime

HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ZDL = r'C:\Users\Command\Desktop\questtest_fixed.zdl'
ENGINE = r'E:\DOOMWork\QZD17-engine\build\Release'
OUT_DIR = os.path.join(HUB, 'tools', 'series_check')
REPORT = os.path.join(OUT_DIR, 'last_report.md')

MODS = ['Accessibility', 'DistanceGrab', 'Gestures', 'Grapple', 'Grenade', 'GunBonsaiOffhandVR', 'GunCards', 'LaserSight',
        'Melee', 'Miniboss', 'QuestSaber', 'Score', 'ShieldSaw', 'SlowMo', 'TacticalRig', 'TopHPBars', 'Wheel', 'Whip']
SKIP_DIRS = ('test', 'tests', 'tools', 'docs', 'probe', 'evidence', '_old', 'ca.ancilla.bonsai', 'original')
CMP = r'(?:~==|==|!=)'   # every way a ZScript compares a string: `~==`, `==`, `!=`
SRC_EXT = ('.zs', '.zsc', '.txt', '.rsq')

# names the series asks for that belong to OTHER mods or the owner's engine build (REMA), absent on QZD by design
KNOWN_FOREIGN_SERVICES = {'RS_WeaponWeightService', 'RS_WeaponArchetypeService', 'RS_TierColorService', 'LaserMuzzleService',
                          'LaserColorService', 'GrabEventService'}
KNOWN_FOREIGN_EVENTS = {'bonsai-choose-level-up-option', 'bonsai-toggle-upgrade', 'bonsai-tune-upgrade', 'bonsai-debug'}


def source_files(mod):
    root = os.path.join(HUB, mod)
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x.lower() not in SKIP_DIRS and not x.startswith('.')]
        for f in files:
            if f.lower().endswith(SRC_EXT) or f.upper() in ('KEYCONF', 'MENUDEF', 'CVARINFO', 'MAPINFO', 'ZSCRIPT', 'DECORATE'):
                yield os.path.join(d, f)


def read(p):
    try:
        return open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return ''


def strip_comments(s):
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    return re.sub(r'//[^\n]*', '', s)


# ---------------------------------------------------------------------------------------------------------------
def static_check():
    out = []
    files = {}            # path -> text (comments stripped)
    for m in MODS:
        for p in source_files(m):
            files[p] = strip_comments(read(p))

    # classes the series declares
    classes = {}          # name -> (mod, file)
    for p, s in files.items():
        for mm in re.finditer(r'^\s*class\s+(\w+)', s, re.M):
            classes[mm.group(1)] = (p.replace(HUB + os.sep, '').split(os.sep)[0], p)
    # services: class X : Service  -> answers (literals compared in that file)
    services = {}         # name -> set of literals, set of prefixes
    for p, s in files.items():
        for mm in re.finditer(r'^\s*class\s+(\w+)\s*:\s*Service\b', s, re.M):
            name = mm.group(1)
            lits = set(re.findall(CMP + r'\s*"([^"]+)"', s)) | set(re.findall(r'"([^"]+)"\s*' + CMP, s)) \
                | set(re.findall(r'case\s+"([^"]+)"', s)) | set(re.findall(r"case\s+'([^']+)'", s)) \
                | set(re.findall(CMP + r"\s*'([^']+)'", s))
            prefixes = set()
            for pm in re.finditer(r'\.Left\((\d+)\)\s*' + CMP + r'\s*"([^"]+)"', s):
                prefixes.add(pm.group(2))
            for pm in re.finditer(r'\.IndexOf\(\s*"([^"]+)"', s):
                prefixes.add(pm.group(1))
            # Name-typed switches: `switch (request)` with `case 'x':` are in lits already
            if name in services:
                lits |= services[name][0]; prefixes |= services[name][1]
            services[name] = (lits, prefixes)
            # a service that delegates: every string literal in the file counts (over-inclusive on purpose)
    # 1. services asked for
    asked_services = {}   # name -> set of files
    for p, s in files.items():
        for mm in re.finditer(r'ServiceIterator\.Find\(\s*"([^"]+)"', s):
            asked_services.setdefault(mm.group(1), set()).add(p)
    # Score's RS_Svc enum table
    svc_zs = files.get(os.path.join(HUB, 'Score', 'zscript', 'rsscore', 'svc.zs'), '')
    score_map = dict(re.findall(r'case\s+(\w+):\s*return\s+"([^"]+)"', svc_zs))
    out.append('## 1. Services asked for\n')
    for name in sorted(asked_services):
        if name in services: continue
        tag = 'another mod\'s or REMA\'s (absent on QZD by design)' if name in KNOWN_FOREIGN_SERVICES else 'NOT DECLARED BY THE SERIES'
        out.append(f'- `{name}`: {tag}; asked in ' + ', '.join(sorted(rel(p) for p in asked_services[name])))
    out.append('')

    # 2. requests vs answers
    out.append('## 2. Requests a series service never compares against\n')
    out.append('(the ask, its file, and the service it was attributed to; "answers" = literals and prefixes found in that service\'s file)\n')
    unanswered = []
    unattributed = []
    for p, s in files.items():
        finds = [(mm.start(), mm.group(1)) for mm in re.finditer(r'ServiceIterator\.Find\(\s*"([^"]+)"', s)]
        dyn = [mm.start() for mm in re.finditer(r'ServiceIterator\.Find\(\s*[A-Za-z_]', s)]   # Find(variable): unknown service
        # a variable bound to a service: `let s = ServiceIterator.Find("S").Next()`, `svc = ...Find("S")...`, `Service s; ... s = it.Next()`
        # every binding of a variable to a NAMED service, by position: `x = ServiceIterator.Find("S")`,
        # `let x = ...Find("S").Next()`, `let it = Find("S"); x = it.Next()`, a helper `x = RSQM.Svc("S")`
        binds = []   # (pos, var, service)
        for vm in re.finditer(r'(\w+)\s*=\s*ServiceIterator\.Find\(\s*"([^"]+)"\s*\)', s): binds.append((vm.start(), vm.group(1), vm.group(2)))
        for vm in re.finditer(r'let\s+(\w+)\s*=\s*ServiceIterator\.Find\(\s*"([^"]+)"\s*\);\s*\n\s*(?:Service\s+)?(\w+)\s*=\s*\1\.Next\(\)', s):
            binds.append((vm.start(), vm.group(3), vm.group(2)))
        for vm in re.finditer(r'(\w+)\s*=\s*[\w.]+\(\s*"(\w+Service)"\s*\)', s): binds.append((vm.start(), vm.group(1), vm.group(2)))
        # `let it = ServiceIterator.Find("S"); ... Service s; while (s = it.Next())`: s is S from that point
        for vm in re.finditer(r'let\s+(\w+)\s*=\s*ServiceIterator\.Find\(\s*"([^"]+)"\s*\);', s):
            tail = s[vm.end():vm.end() + 400]
            nm = re.search(r'\b(\w+)\s*=\s*' + re.escape(vm.group(1)) + r'\.Next\(\)', tail)
            if nm: binds.append((vm.end() + nm.start(), nm.group(1), vm.group(2)))
        binds.sort()
        # every assignment of a variable, named or not: a later `let svc = SomeHelper()` with no string UNBINDS it
        assigns = [(mm.start(1), mm.group(1)) for mm in re.finditer(r'(?:let\s+|Service\s+)?\b(\w+)\s*=(?!=)', s)]
        for am in re.finditer(r'(\w+)\.Get(?:Int|Double|String)\(\s*"([^"]+)"', s):
            req = am.group(2)
            var = am.group(1)
            last = [a for a in assigns if a[1] == var and a[0] < am.start()]
            svc = None
            if last:
                near = [b for b in binds if b[1] == var and abs(b[0] - last[-1][0]) <= 12]
                if near: svc = near[-1][2]
            if not svc: unattributed.append((rel(p), req))
            # a variable this file never binds to a named service (a helper with no string, a field): unknown, skipped
            if not svc or svc not in services: continue
            lits, prefixes = services[svc]
            ok = req in lits or any(req.startswith(pf) for pf in prefixes)
            if not ok: unanswered.append((svc, req, rel(p)))
        # Score's typed asks: RS_Svc.X(RS_Svc.WHICH, "req")
        for am in re.finditer(r'RS_Svc\.\w+\(\s*RS_Svc\.(\w+)\s*,\s*"([^"]+)"', s):
            svc = score_map.get(am.group(1)); req = am.group(2)
            if not svc or svc not in services: continue
            lits, prefixes = services[svc]
            if not (req in lits or any(req.startswith(pf) for pf in prefixes)): unanswered.append((svc, req, rel(p)))
    seen = set()
    for svc, req, f in sorted(unanswered):
        if (svc, req) in seen: continue
        seen.add((svc, req))
        out.append(f'- `{svc}` <- `"{req}"` (asked in {f})')
    if not seen: out.append('- none')
    out.append(f'\n({len(unattributed)} asks whose service this check could not name -- a helper with no string, a field -- were not judged.)')
    out.append('')

    # 3. network events
    sent = {}
    for p, s in files.items():
        for mm in re.finditer(r'SendNetworkEvent\(\s*"([^"]+)"', s): sent.setdefault(mm.group(1), set()).add(rel(p))
        for mm in re.finditer(r'netevent\s+([A-Za-z_][\w:.\-]*)', s): sent.setdefault(mm.group(1), set()).add(rel(p) + ' (alias)')
    handled, hprefix = set(), set()
    for p, s in files.items():
        for mm in re.finditer(r'e\.[Nn]ame\s*' + CMP + r'\s*"([^"]+)"', s): handled.add(mm.group(1))
        for mm in re.finditer(r"e\.[Nn]ame\s*" + CMP + r"\s*'([^']+)'", s): handled.add(mm.group(1))
        for mm in re.finditer(r'e\.[Nn]ame\.Left\(\d+\)\s*' + CMP + r'\s*"([^"]+)"', s): hprefix.add(mm.group(1))
        for mm in re.finditer(r'e\.[Nn]ame\.IndexOf\(\s*"([^"]+)"', s): hprefix.add(mm.group(1))
        # a handler that copies the name first (`String n = e.Name; if (n == "x")`), and Name-typed switches
        if re.search(r'=\s*e\.[Nn]ame\b', s):
            for mm in re.finditer(r'\b\w+\s*' + CMP + r'\s*"([^"]+)"', s): handled.add(mm.group(1))
        for mm in re.finditer(r"case\s+'([^']+)'\s*:", s): handled.add(mm.group(1))
    out.append('## 3. Network events nobody in the series handles\n')
    n3 = 0
    for ev in sorted(sent):
        base = ev.split(':')[0]
        if ev in handled or base in handled or any(ev.startswith(pf) for pf in hprefix): continue
        if ev in KNOWN_FOREIGN_EVENTS: continue
        n3 += 1
        out.append(f'- `{ev}` sent from ' + ', '.join(sorted(sent[ev])))
    if not n3: out.append('- none')
    out.append('')

    # 4. class names reached by string
    known = set(classes)
    known |= engine_classes()
    known |= order_classes()
    refs = {}
    pats = [r'\bis\s+"(\w+)"', r'Spawn\(\s*"(\w+)"', r'FindInventory\(\s*"(\w+)"', r'GiveInventoryType\(\s*"(\w+)"',
            r'FindClass\(\s*"(\w+)"', r'EventHandler\.Find\(\s*"(\w+)"', r'RSQM\.Has\(\s*"(\w+)"', r'\(Class<\w+>\)\s*\(\s*"(\w+)"',
            r'GiveInventory\(\s*"(\w+)"', r'SetInventory\(\s*"(\w+)"', r'CountInv\(\s*"(\w+)"', r'A_SpawnItemEx\(\s*"(\w+)"',
            r'A_SpawnProjectile\(\s*"(\w+)"', r'SpawnMissile\w*\(\s*"(\w+)"', r'GetClassName\(\)\s*==\s*"(\w+)"']
    for p, s in files.items():
        for pat in pats:
            for mm in re.finditer(pat, s):
                refs.setdefault(mm.group(1), set()).add(rel(p))
    out.append('## 4. Class names reached by string that nothing declares (series, engine, or the rest of the load order)\n')
    n4 = 0
    for name in sorted(refs):
        if name in known: continue
        n4 += 1
        out.append(f'- `{name}` in ' + ', '.join(sorted(refs[name])[:4]))
    if not n4: out.append('- none')
    out.append('')
    out.append(f'Declared: {len(classes)} series classes, {len(services)} services; asked: {len(asked_services)} services, '
               f'{len(sent)} events sent or bound, {len(refs)} class names by string.\n')
    return '\n'.join(out)


def rel(p):
    return os.path.relpath(p, HUB).replace(os.sep, '/')


def classes_in_zip(path):
    names = set()
    try:
        z = zipfile.ZipFile(path)
    except (OSError, zipfile.BadZipFile):
        return names
    for n in z.namelist():
        ln = n.lower()
        if not (ln.endswith(('.zs', '.zsc', '.txt', '.dec', '.zscript')) or os.path.basename(ln) in ('zscript', 'decorate')):
            continue
        try:
            s = z.read(n).decode('utf-8', 'replace')
        except Exception:
            continue
        for mm in re.finditer(r'^\s*(?:class|actor|Actor|ACTOR|Class)\s+(\w+)', s, re.M):
            names.add(mm.group(1))
    return names


_engine = None
def engine_classes():
    global _engine
    if _engine is None:
        _engine = set()
        for p in glob.glob(os.path.join(ENGINE, '*.pk3')):
            _engine |= classes_in_zip(p)
    return _engine


def order_files():
    files = []
    for line in read(ZDL).splitlines():
        if line.startswith('file'):
            files.append(line.split('=', 1)[1].strip())
    return files


_order = None
def order_classes():
    global _order
    if _order is None:
        _order = set()
        for f in order_files():
            base = os.path.basename(f)
            # every other pk3/zip in the order (BD22, the monster packs, Gun Bonsai); the RSQ ones are the series' sources
            if f.lower().endswith(('.pk3', '.zip')) and not base.startswith('RSQ_'):
                _order |= classes_in_zip(f)
    return _order


# ---------------------------------------------------------------------------------------------------------------
def gate():
    out = ['## 5. The headless gate (the owner\'s full load order + the probe)\n']
    files = []
    for f in order_files():
        base = os.path.basename(f)
        if base.startswith('RSQ_') and base.endswith('.pk3'):
            local = os.path.join(HUB, 'pk3', base)
            files.append(local if os.path.exists(local) else f)   # the repo's build of each RSQ pk3, not the Desktop copy
        else:
            files.append(f)
    # a file the ZDL names by a version that has moved on (03_BD22_VR-Reloaded_2.0.3o -> p): the newest of its kind
    for i, f in enumerate(files):
        if os.path.exists(f): continue
        stem = re.sub(r'[\d.]+[a-z]?\.(pk3|zip)$', '', os.path.basename(f))
        cands = sorted(glob.glob(os.path.join(os.path.dirname(f), stem + '*')), key=os.path.getmtime)
        if cands: files[i] = cands[-1]
    missing = [f for f in files if not os.path.exists(f)]
    if missing:
        out.append('Load order files missing on this machine: ' + ', '.join(missing))
        return '\n'.join(out)
    # pack the probe
    probe = os.path.join(OUT_DIR, 'probe.pk3')
    z = zipfile.ZipFile(probe, 'w', zipfile.ZIP_DEFLATED)
    for f in ('zscript.txt', 'MAPINFO.txt'):
        z.write(os.path.join(OUT_DIR, 'probe', f), f)
    z.close()
    files.append(probe)
    runner = os.path.join(HUB, 'tools', 'qzd_hidden_run.ps1')
    args = ['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', runner, '-Files', ','.join(files),
            '-Map', 'MAP01', '-WaitTics', '140', '-TimeoutSec', '600', '-Commands', 'netevent rsm_state,wait 10', '-Tag', 'series_check']
    r = subprocess.run(args, capture_output=True, text=True)
    text = r.stdout + r.stderr
    # the runner prints `log: <path>` on a clean run and `... log <path>` when it counted error lines
    logm = re.search(r'\blog:? +([A-Za-z]:\\[^\r\n]+?\.log)', text)
    out.append(f'{len(files)} files loaded. Runner exit {r.returncode}.')
    if not logm:
        out.append('No log line from the runner:\n```\n' + text[-3000:] + '\n```')
        return '\n'.join(out)
    out.append(parse_log(logm.group(1).strip()))
    return '\n'.join(out)


def parse_log(path):
    out = []
    lines = read(path).splitlines()
    parse = re.search(r'script parsing took [\d.]+ ms', '\n'.join(lines))
    # an error or warning is two lines: the header, then the message; keep both
    def pairs(key):
        got = []
        for i, l in enumerate(lines):
            if key in l: got.append(l.strip() + ' ' + (lines[i + 1].strip() if i + 1 < len(lines) else ''))
        return got
    # ("Unknown class name" lines are the BODY of a Script warning, not an error)
    errors = pairs('Script error') + [l for l in lines if re.search(r'VM execution|Execution could not continue', l)]
    warns = pairs('Script warning')
    known = lambda l: 'VoxelPack' in l and 'No sprites specified for voxel' in l   # BD_VoxelPack's VOXELDEF (its own, known)
    kerr = [l for l in errors if known(l)]
    stood = [l for l in lines if re.search(r'STOOD DOWN|stood down|REFUSED|refused:|not learned', l)]
    chk = [l for l in lines if l.startswith('RSQCHK')]
    miss = [l for l in chk if 'MISSING' in l or 'no such class' in l]
    out.append(f'- parse: {"OK (" + parse.group(0) + ")" if parse else "NO PARSE LINE"}')
    out.append(f'- script errors: {len(errors)} ({len(kerr)} of them BD_VoxelPack\'s VOXELDEF "No sprites specified", its own, known)')
    for l in [e for e in errors if not known(e)][:20]: out.append(f'  - `{l}`')
    # warnings by the pk3 they come from: the series' own are the ones that matter here
    bypk = {}
    for l in warns:
        m = re.search(r'Script warning, "([^:"]+):', l)
        bypk.setdefault(m.group(1) if m else '?', []).append(l)
    ours = [l for k, v in bypk.items() if k.startswith('RSQ_') for l in v]
    out.append(f'- script warnings: {len(warns)} in all; THE SERIES\' OWN: {len(ours)}')
    for l in ours[:30]: out.append(f'  - `{l}`')
    out.append('  - by pk3: ' + ', '.join(f'{k} {len(v)}' for k, v in sorted(bypk.items(), key=lambda kv: -len(kv[1]))))
    out.append(f'- stood down / refused lines: {len(stood)}')
    for l in stood[:20]: out.append(f'  - `{l.strip()}`')
    out.append(f'- probe: {len(chk)} lines, {len(miss)} missing')
    for l in miss: out.append(f'  - `{l.strip()}`')
    done = [l for l in chk if l.startswith('RSQCHK done')]
    if not done: out.append('  - THE PROBE NEVER REPORTED (its handler did not run, or the level never reached tic 35)')
    state = [l for l in lines if l.startswith('slow motion:')]
    for l in state[:1]: out.append(f'- SlowMo: `{l.strip()}`')
    out.append(f'- log: `{path}`')
    verdict = 'PASS' if (parse and len(errors) == len(kerr) and not miss and done and not ours) else 'FAIL'
    out.insert(0, f'**{verdict}**\n')
    return '\n'.join(out)


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else 'both'
    os.makedirs(OUT_DIR, exist_ok=True)
    parts = [f'# Series check, {datetime.datetime.now():%Y-%m-%d %H:%M}\n']
    if what in ('static', 'both'): parts.append(static_check())
    if what in ('gate', 'both'): parts.append(gate())
    if what == 'parse': parts.append('## 5. The headless gate (an earlier log re-read)\n\n' + parse_log(sys.argv[2]))   # python tools/series_check.py parse <log>
    report = '\n'.join(parts)
    open(REPORT, 'w', encoding='utf-8', newline='\n').write(report)
    print(report)
    print(f'\nreport: {REPORT}')


if __name__ == '__main__':
    main()
