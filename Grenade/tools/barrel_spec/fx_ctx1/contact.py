from PIL import Image, ImageDraw
L = '/tmp/fx_ctx1/look/'
ROWS = [
 ('C_wall_barrel', 'WALL / barrel (#5 Snap)', (40, 80, 320, 300), [-4, 0, 1, 3, 5, 8, 12, 16, 26, 40]),
 ('C_wall_grenade', 'WALL / grenade frag', (120, 140, 520, 420), [-1, 0, 1, 2, 3, 5, 8, 14, 30, 50]),
 ('C_ceiling_barrel', 'LOW CEILING / barrel (#6 Heavy)', (0, 130, 320, 300), [-4, 0, 3, 6, 10, 14, 20, 30, 40, 60]),
 ('C_sky_barrel', 'OPEN SKY / barrel (#7 Pillar)', (40, 0, 280, 300), [-4, 0, 6, 12, 18, 24, 30, 50, 80, 120]),
 ('C_water_barrel', 'WATER / barrel (#6 Heavy)', (20, 100, 300, 320), [-1, 0, 2, 4, 8, 12, 14, 18, 26, 40]),
 ('C_water_grenade', 'WATER / grenade frag', (100, 140, 540, 420), [-45, -1, 0, 2, 6, 10, 14, 18, 26, 40]),
]
tiles = []
for name, label, crop, tics in ROWS:
    w, h = crop[2] - crop[0], crop[3] - crop[1]
    row = Image.new('RGB', (210 + len(tics) * (w + 2), h + 16), (22, 22, 26)); d = ImageDraw.Draw(row)
    d.text((6, h // 2), label, fill=(255, 220, 120))
    for i, t in enumerate(tics):
        im = Image.open(f'{L}{name}_{t:+04d}.png').crop(crop)
        row.paste(im, (210 + i * (w + 2), 16)); d.text((212 + i * (w + 2), 3), f'tic {t:+d}', fill=(200, 200, 200))
    tiles.append(row)
W = max(r.width for r in tiles); H = sum(r.height + 4 for r in tiles)
S = Image.new('RGB', (W, H), (22, 22, 26)); y = 0
for r in tiles: S.paste(r, (0, y)); y += r.height + 4
S.save('/tmp/fx_ctx1/out/C1_contact.png'); print(S.size)
