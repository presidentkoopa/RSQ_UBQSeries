#!/usr/bin/env python3
"""TEST ONLY. Instrument a pk3's ZScript for per-handler timing.

Every `override void <Hook>(...)` for the hooks below is renamed to a private body function and a wrapper
override is put in its place that times the body with MSTimeF() and reports it to RSQProf (a static handler
added by the probe pk3, found by name so a pk3 without the probe still compiles is NOT supported: load the
probe). Usage: instrument.py in.pk3 out.pk3
"""
import re, sys, zipfile

HOOKS = ['WorldTick', 'WorldThingSpawned', 'WorldThingDied', 'WorldThingDamaged', 'NetworkProcess', 'PlayerEntered']
# also actor / thinker Tick overrides (an actor class's own per-tic cost)
TICK = 'Tick'

CLASS_RE = re.compile(r'\b(?:class|struct)\s+([A-Za-z_][A-Za-z0-9_]*)', re.I)


def is_code(name):
    n = name.lower()
    base = n.rsplit('/', 1)[-1]
    return n.endswith('.zs') or n.endswith('.zsc') or base.startswith('zscript')


def strip_for_scan(t):
    """Blank out comments and strings (same length) so regexes only see code."""
    out = list(t)
    i, n = 0, len(t)
    while i < n:
        c = t[i]
        if t.startswith('//', i):
            j = t.find('\n', i)
            j = n if j < 0 else j
            for k in range(i, j): out[k] = ' '
            i = j
        elif t.startswith('/*', i):
            j = t.find('*/', i + 2)
            j = n if j < 0 else j + 2
            for k in range(i, j):
                if out[k] != '\n': out[k] = ' '
            i = j
        elif c == '"':
            j = i + 1
            while j < n and t[j] != '"':
                j += 2 if t[j] == '\\' else 1
            for k in range(i + 1, min(j, n)): out[k] = ' '
            i = j + 1
        else:
            i += 1
    return ''.join(out)


def instrument(text, tag):
    scan = strip_for_scan(text)
    # class spans: a class's name applies from its declaration to the next declaration
    decls = [(m.start(), m.group(1)) for m in CLASS_RE.finditer(scan)]
    hooks = '|'.join(HOOKS + [TICK])
    pat = re.compile(r'override\s+void\s+(' + hooks + r')\s*\(([^)]*)\)', re.S)
    edits = []
    for m in pat.finditer(scan):
        cls = None
        for pos, name in decls:
            if pos < m.start(): cls = name
            else: break
        if not cls: continue
        hook = m.group(1)
        params = text[m.start(2):m.end(2)].strip()
        args = ', '.join(p.strip().split()[-1] for p in params.split(',') if p.strip()) if params else ''
        body = 'RSQPROF_%s_%s' % (hook, cls)
        key = '%s.%s' % (cls, hook)
        wrapper = ('override void %s(%s) { double rsqprof_t = MSTimeF(); %s(%s); RSQProf.Add("%s", MSTimeF() - rsqprof_t); } '
                   % (hook, params, body, args, key))
        edits.append((m.start(), m.end(), wrapper + 'void %s(%s)' % (body, params)))
    for s, e, r in reversed(edits):
        text = text[:s] + r + text[e:]
    return text, len(edits)


def main():
    src, dst = sys.argv[1], sys.argv[2]
    total = 0
    with zipfile.ZipFile(src) as zi, zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED) as zo:
        for info in zi.infolist():
            data = zi.read(info.filename)
            if not info.is_dir() and is_code(info.filename):
                try:
                    t = data.decode('latin-1')
                except Exception:
                    zo.writestr(info, data); continue
                t2, n = instrument(t, info.filename)
                total += n
                data = t2.encode('latin-1')
            zo.writestr(info, data, compress_type=zipfile.ZIP_DEFLATED)
    print('%s: %d hooks wrapped' % (src.rsplit('/', 1)[-1], total))


if __name__ == '__main__':
    main()
