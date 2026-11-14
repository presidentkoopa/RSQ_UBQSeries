#!/usr/bin/env python3
"""Sprite lumps across a load order, resolved the way the engine resolves them: the LAST archive that has a lump of
that name in the sprite namespace wins (a WAD between S_START/S_END or SS_START/SS_END; a pk3 under sprites/).
Archives are read as data (zipfile / WAD directory), never extracted or executed."""
import os, re, struct, zipfile, io

class LoadOrder:
    def __init__(self, archives):
        self.index = {}          # LUMPNAME -> (archive, entry, size)
        self.palette = None
        self.brightmaps = {}     # sprite LUMPNAME -> the rest of its GLDEFS line ('map "..." disablefullbright'), last wins
        for a in archives:
            if a.lower().endswith('.wad'): self._wad(a)
            else: self._zip(a)

    def _wad(self, path):
        d = open(path, 'rb').read()
        n, off = struct.unpack('<ii', d[4:12])
        ins = False
        for i in range(n):
            p, s, nm = struct.unpack('<ii8s', d[off + 16 * i: off + 16 * i + 16])
            name = nm.rstrip(b'\0').decode('latin1').upper()
            if name in ('S_START', 'SS_START'): ins = True; continue
            if name in ('S_END', 'SS_END'): ins = False; continue
            if name == 'PLAYPAL' and self.palette is None: self.palette = d[p:p + 768]
            if ins and s > 0: self.index[name] = (path, (p, s), s)

    def _zip(self, path):
        try: z = zipfile.ZipFile(path)
        except Exception: return
        for info in z.infolist():
            fn = info.filename.replace('\\', '/')
            if info.is_dir() or not fn.lower().startswith('sprites/'): continue
            base = os.path.basename(fn)
            name = base.split('.')[0][:8].upper()
            if name: self.index[name] = (path, fn, info.file_size)
        # brightmaps: any text lump of the archive's root or a .bm / gldefs file (Brutal Doom's doommonsters.bm)
        for info in z.infolist():
            fn = info.filename.replace('\\', '/'); low = fn.lower()
            if info.is_dir() or info.file_size > 4_000_000: continue
            if not (low.endswith('.bm') or os.path.basename(low).startswith('gldefs')): continue
            t = z.read(info).decode('latin-1')
            for m in re.finditer(r'brightmap\s+sprite\s+"?(\w+)"?\s*\{([^}]*)\}', t, re.I):
                self.brightmaps[m.group(1).upper()] = ' '.join(m.group(2).split())

    def read(self, name):
        a, e, s = self.index[name.upper()]
        if isinstance(e, tuple):
            with open(a, 'rb') as f: f.seek(e[0]); return f.read(e[1])
        return zipfile.ZipFile(a).read(e)

    def where(self, name):
        return self.index.get(name.upper())
