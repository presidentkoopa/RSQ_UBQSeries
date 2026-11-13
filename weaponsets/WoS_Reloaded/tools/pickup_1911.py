"""pickup_1911.py -> assets/pickup_1911/{pistG0.kvx, 1911pick.png}

The 1911's pickup (owner 2026-11-12: "get that voxel 1911 out of there and recolor the pistol one"): BD22's voxel pistol
(BD22 voxel pack Voxels/Weapons/pistG0.kvx, Voxeldef scale 0.8), drawn as BD22 VR draws its voxels (MODELDEF.rsqvox: the
kvx as a model, its 16x16 palette as the skin), with its palette recoloured to the 1911's own: the HUD mesh's skin (RS
ModelSwapper cards/brutalwolf/1911/1911.png). Measured, not picked: the voxel's 18 greys (0..124) are matched by rank
(voxel count) to the 1911 skin's colours by luminance rank (histogram matching), so the voxel's darkest is the skin's
darkest and its brightest the skin's brightest."""
import os, struct, zipfile, numpy as np
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(os.path.dirname(HERE), 'assets', 'pickup_1911')
BDVOX = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/pk3/02_BD22_VoxelPack.pk3'
SKIN = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src/rsqvox/pistg0.png'
CARD = '/home/claude/presidentkoopa/rs_modelswapper/cards/brutalwolf/1911/1911.png'
os.makedirs(OUT, exist_ok=True)
kvx = zipfile.ZipFile(BDVOX).read('Voxels/Weapons/pistG0.kvx')
open(os.path.join(OUT, 'pistG0.kvx'), 'wb').write(kvx)
# the palette indices the voxel uses, with how many voxels each
nb, x, y, z = struct.unpack_from('<4i', kvx, 0)
p = 28 + 4 * (x + 1) + 2 * x * (y + 1); end = 4 + nb; use = {}
while p < end:
    zl = kvx[p + 1]; p += 3
    for i in range(zl): use[kvx[p + i]] = use.get(kvx[p + i], 0) + 1
    p += zl
skin = Image.open(SKIN).convert('RGB'); pal = np.array(skin).reshape(-1, 3).astype(float)
# the 1911's colours (its painted texels: the black of unused texture space left out), sorted by luminance
card = np.array(Image.open(CARD).convert('RGB')).reshape(-1, 3).astype(float)
lum = card @ [0.299, 0.587, 0.114]
card, lum = card[lum > 6], lum[lum > 6]
order = np.argsort(lum); card = card[order]
# rank-match: the voxel's colours in luminance order, each at the quantile its voxels reach
idx = sorted(use, key=lambda i: pal[i] @ [0.299, 0.587, 0.114]); tot = sum(use.values()); acc = 0
new = pal.copy()
for i in idx:
    lo = acc / tot; acc += use[i]; hi = acc / tot
    a, b = int(lo * (len(card) - 1)), max(int(hi * (len(card) - 1)), int(lo * (len(card) - 1)) + 1)
    new[i] = card[a:b].mean(0)
Image.fromarray(new.reshape(16, 16, 3).clip(0, 255).astype(np.uint8)).save(os.path.join(OUT, '1911pick.png'))
print('recoloured', len(idx), 'palette entries:', [(i, tuple(pal[i].astype(int)), tuple(new[i].astype(int))) for i in idx])
