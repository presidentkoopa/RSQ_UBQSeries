#!/usr/bin/env python3
"""blendread.py -- a minimal reader for Blender 2.8x/2.9x .blend files (no Blender needed).

Reads the file blocks and the SDNA, so any struct can be decoded by name. Used by gen_flare.py to pull the flare's
mesh (vertices, polygons, UVs) and its object transform out of the owner's Flare.blend.

    python3 -I tools/blendread.py <file.blend>        # lists the objects, meshes, materials and images
"""
import struct, sys, zlib, gzip


class Blend:
    def __init__(self, path):
        data = open(path, 'rb').read()
        if data[:2] == b'\x1f\x8b': data = gzip.decompress(data)
        assert data[:7] == b'BLENDER', 'not a .blend'
        self.ptr = 8 if data[7:8] == b'-' else 4
        self.end = '<' if data[8:9] == b'v' else '>'
        self.ver = data[9:12].decode()
        self.data = data
        self.blocks = []
        o = 12
        hfmt = self.end + '4si' + ('Q' if self.ptr == 8 else 'I') + 'ii'
        hsz = struct.calcsize(hfmt)
        while o < len(data):
            code, size, old, sdna, count = struct.unpack_from(hfmt, data, o)
            code = code.rstrip(b'\0').decode('latin1')
            self.blocks.append(dict(code=code, size=size, old=old, sdna=sdna, count=count, off=o + hsz))
            o += hsz + size
            if code == 'ENDB': break
        self.byold = {b['old']: b for b in self.blocks}
        self._sdna()

    def _sdna(self):
        b = next(b for b in self.blocks if b['code'] == 'DNA1')
        d = self.data; o = b['off']
        def al(o): return (o + 3) & ~3
        assert d[o:o + 4] == b'SDNA'; o += 4
        assert d[o:o + 4] == b'NAME'; o += 4
        n = struct.unpack_from(self.end + 'i', d, o)[0]; o += 4
        names = []
        for _ in range(n):
            e = d.index(b'\0', o); names.append(d[o:e].decode()); o = e + 1
        o = al(o); assert d[o:o + 4] == b'TYPE'; o += 4
        n = struct.unpack_from(self.end + 'i', d, o)[0]; o += 4
        types = []
        for _ in range(n):
            e = d.index(b'\0', o); types.append(d[o:e].decode()); o = e + 1
        o = al(o); assert d[o:o + 4] == b'TLEN'; o += 4
        tlen = list(struct.unpack_from(self.end + '%dh' % len(types), d, o)); o += 2 * len(types)
        o = al(o); assert d[o:o + 4] == b'STRC'; o += 4
        n = struct.unpack_from(self.end + 'i', d, o)[0]; o += 4
        structs = []
        for _ in range(n):
            t, nf = struct.unpack_from(self.end + 'hh', d, o); o += 4
            fields = []
            for _ in range(nf):
                ft, fn = struct.unpack_from(self.end + 'hh', d, o); o += 4
                fields.append((types[ft], names[fn]))
            structs.append((types[t], fields))
        self.names, self.types, self.tlen, self.structs = names, types, tlen, structs
        self.layout = {}
        for si, (tn, fields) in enumerate(structs):
            off = 0; lay = {}
            for ft, fn in fields:
                cnt = 1
                base = fn
                for part in fn.split('[')[1:]: cnt *= int(part.rstrip(']'))
                base = fn.split('[')[0]
                if base.startswith('*') or base.startswith('(*'):
                    sz = self.ptr * cnt
                else:
                    sz = self.tlen[self.types.index(ft)] * cnt
                lay[base.lstrip('*').replace('(', '').replace(')', '')] = (off, ft, fn, sz)
                off += sz
            self.layout[tn] = lay

    def struct_name(self, block): return self.structs[block['sdna']][0]

    def field(self, tname, base_off, fname):
        off, ft, fn, sz = self.layout[tname][fname]
        o = base_off + off
        d = self.data
        if fn.startswith('*') or fn.startswith('(*'):
            return struct.unpack_from(self.end + ('Q' if self.ptr == 8 else 'I'), d, o)[0]
        cnt = sz // max(1, self.tlen[self.types.index(ft)])
        fmt = {'float': 'f', 'double': 'd', 'int': 'i', 'short': 'h', 'char': 'b', 'uchar': 'B', 'ushort': 'H',
               'int64_t': 'q', 'uint64_t': 'Q', 'uint': 'I'}.get(ft)
        if ft == 'char' and '[' in fn:
            raw = d[o:o + sz]; return raw.split(b'\0')[0].decode('latin1')
        if fmt is None: return o   # a nested struct: its offset
        v = struct.unpack_from(self.end + fmt * cnt, d, o)
        return v[0] if cnt == 1 else list(v)

    def deref(self, ptr):
        return self.byold.get(ptr)

    def items(self, ptr, tname):
        b = self.deref(ptr)
        if not b: return []
        sz = self.tlen[self.types.index(tname)]
        return [b['off'] + i * sz for i in range(b['size'] // sz)]


def summary(path):
    bl = Blend(path)
    print('blender', bl.ver, 'ptr', bl.ptr)
    for b in bl.blocks:
        if b['code'] in ('OB', 'ME', 'MA', 'IM'):
            tn = bl.struct_name(b)
            idoff = bl.field(tn, b['off'], 'id')
            print(b['code'], tn, bl.field('ID', idoff, 'name'))


if __name__ == '__main__':
    summary(sys.argv[1])
