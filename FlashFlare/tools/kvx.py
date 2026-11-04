#!/usr/bin/env python3
"""kvx.py -- read and write Build-engine .kvx voxels (the format GZDoom's VOXELDEF loads), mip level 0 only.

Format (Ken Silverman's KVX, as GZDoom's r_data/voxels.cpp reads it): int32 numbytes, then xsiz ysiz zsiz, xpivot ypivot
zpivot (int32, 24.8 fixed: pivot * 256), xoffset[xsiz+1] (int32), xyoffset[xsiz][ysiz+1] (uint16), then the slabs of each
(x, y) column: ztop, zleng, backface-cull bits, zleng palette indices. Further mip levels may follow; the last 768 bytes of
the file are the palette (r g b, 0..63). GZDoom reads mip 0 only, so this writes mip 0 only.

Voxel: dict {(x, y, z): palette index}, z counted DOWN from the top (KVX's way).
"""
import struct


class Kvx:
    def __init__(self):
        self.size = (0, 0, 0)
        self.pivot = (0.0, 0.0, 0.0)
        self.vox = {}
        self.pal = [(0, 0, 0)] * 256   # 0..63 each

    @staticmethod
    def read(path):
        b = open(path, 'rb').read()
        k = Kvx()
        numbytes, xs, ys, zs, px, py, pz = struct.unpack_from('<7i', b, 0)
        k.size = (xs, ys, zs)
        k.pivot = (px / 256.0, py / 256.0, pz / 256.0)
        base = 28
        xoff = struct.unpack_from('<%di' % (xs + 1), b, base)
        o = base + 4 * (xs + 1)
        xyoff = []
        for x in range(xs):
            xyoff.append(struct.unpack_from('<%dH' % (ys + 1), b, o))
            o += 2 * (ys + 1)
        data0 = o
        # offsets in xoffset are from the start of xoffset's table end... per KVX: relative to the start of the xoffset array
        # plus (xsiz+1)*4 + xsiz*(ysiz+1)*2
        hdr = (xs + 1) * 4 + xs * (ys + 1) * 2
        for x in range(xs):
            for y in range(ys):
                s = data0 + xoff[x] - hdr + xyoff[x][y]
                e = data0 + xoff[x] - hdr + xyoff[x][y + 1]
                while s < e:
                    ztop, zleng, cull = b[s], b[s + 1], b[s + 2]
                    for i in range(zleng):
                        k.vox[(x, y, ztop + i)] = b[s + 3 + i]
                    s += 3 + zleng
        palb = b[-768:]
        k.pal = [(palb[i * 3], palb[i * 3 + 1], palb[i * 3 + 2]) for i in range(256)]
        return k

    def solid(self, x, y, z):
        return (x, y, z) in self.vox

    def write(self, path):
        xs, ys, zs = self.size
        cols = []
        for x in range(xs):
            row = []
            for y in range(ys):
                zsorted = sorted(z for (vx, vy, z) in self._colkeys(x, y))
                slabs = b''
                i = 0
                while i < len(zsorted):
                    j = i
                    while j + 1 < len(zsorted) and zsorted[j + 1] == zsorted[j] + 1 and j + 1 - i < 255:
                        j += 1
                    ztop = zsorted[i]
                    run = zsorted[i:j + 1]
                    cull = 0
                    # visible-face bits (KVX: 1 -x, 2 +x, 4 -y, 8 +y, 16 -z top, 32 +z bottom); GZDoom ignores them for
                    # drawing in the GL renderer but they are cheap to get right
                    for z in run:
                        for bit, (dx, dy, dz) in ((1, (-1, 0, 0)), (2, (1, 0, 0)), (4, (0, -1, 0)), (8, (0, 1, 0)),
                                                  (16, (0, 0, -1)), (32, (0, 0, 1))):
                            if not self.solid(x + dx, y + dy, z + dz):
                                cull |= bit
                    slabs += bytes([ztop, len(run), cull]) + bytes(self.vox[(x, y, z)] for z in run)
                    i = j + 1
                row.append(slabs)
            cols.append(row)
        xoff = []
        xyoff = []
        hdr = (xs + 1) * 4 + xs * (ys + 1) * 2
        pos = hdr
        data = b''
        for x in range(xs):
            xoff.append(pos)
            yo = [0]
            for y in range(ys):
                data += cols[x][y]
                yo.append(yo[-1] + len(cols[x][y]))
                pos += len(cols[x][y])
            xyoff.append(yo)
        xoff.append(pos)
        body = struct.pack('<6i', xs, ys, zs, int(round(self.pivot[0] * 256)), int(round(self.pivot[1] * 256)),
                           int(round(self.pivot[2] * 256)))
        body += struct.pack('<%di' % (xs + 1), *xoff)
        for yo in xyoff:
            body += struct.pack('<%dH' % (ys + 1), *yo)
        body += data
        out = struct.pack('<i', len(body)) + body
        out += bytes(c for rgb in self.pal for c in rgb)
        open(path, 'wb').write(out)

    def _colkeys(self, x, y):
        if not hasattr(self, '_cols') or self._colsn != len(self.vox):
            self._cols = {}
            for (vx, vy, vz) in self.vox:
                self._cols.setdefault((vx, vy), []).append((vx, vy, vz))
            self._colsn = len(self.vox)
        return self._cols.get((x, y), [])
