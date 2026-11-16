# the word-font lane's contact sheet and GIF (test only)
import os
from PIL import Image, ImageDraw, ImageFont
R = '/home/claude/rig/work/runs/'
OUT = '/home/claude/wt_wordfont/VisualRewards/test/evidence/'
F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 16)
f2 = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 14)
def fr(run, n): return Image.open(R + run + '/frames/f%05d.ppm' % n).convert('RGB')
PANELS = [('0  Score Small (RSSCFN2) -- the default', 28), ('1  SOTN (the owner\'s word sheet)', 48), ('2  JFO (the damage numbers\' font)', 64),
          ('3  Score Big (RSSCFON) -- what shipped until now', 80), ('4  Doom Small (the IWAD\'s STCFN)', 104)]
W = 720; PH = 210; LH = 26
head = 74
zoomH = 2 * 130 + 4 + LH + PH
S = Image.new('RGB', (W, head + len(PANELS) * (PH + LH) + LH + zoomH), (16, 16, 20))
d = ImageDraw.Draw(S)
d.text((10, 8), 'RSQ VisualRewards: Word Font (rsqvr_wordfont), the words over monsters', font=F, fill=(255, 220, 120))
d.text((10, 32), 'RIG ONLY, NOT HEADSET-CONFIRMED. QZD 17.3 rig, the owner\'s order (doom2, LegenDoom,', font=f2, fill=(230, 230, 230))
d.text((10, 50), 'brutal22test6, BD_VoxelPack, BD22 VR ... every RSQ pk3), MAP01, run wf_full3, one font a phase.', font=f2, fill=(230, 230, 230))
y = head
for lab, n in PANELS:
    d.text((10, y + 4), lab, font=F, fill=(255, 255, 255))
    S.paste(fr('wf_full3', n).crop((0, 240, 720, 240 + PH)), (0, y + LH))
    y += PH + LH
d.text((10, y + 4), 'x2 nearest: TARGET! (held) and THREAT! (two-tone): Score Small, then SOTN', font=f2, fill=(255, 255, 255))
y += LH
S.paste(fr('wf_full3', 28).crop((24, 356, 384, 421)).resize((720, 130), Image.NEAREST), (0, y))
S.paste(fr('wf_full3', 48).crop((60, 362, 420, 427)).resize((720, 130), Image.NEAREST), (0, y + 134))
y += 264
d.text((10, y + 4), 'VisualRewards alone (doom2 + it, no Score pk3), run wf_alone4', font=F, fill=(255, 255, 255))
S.paste(fr('wf_alone4', 50).crop((0, 230, 720, 230 + PH)), (0, y + LH))
S.save(OUT + 'wordfont_sheet.png', optimize=True)
print('sheet', S.size, os.path.getsize(OUT + 'wordfont_sheet.png'))

# GIF: run wf_full2 (480 px, every frame the rig drew): Score Small then SOTN
fs = sorted(int(f[1:6]) for f in os.listdir(R + 'wf_full2/frames'))
fs = [n for n in fs if n >= 13]
frames = []
for n in fs:
    im = fr('wf_full2', n).crop((0, 175, 480, 295))
    c = Image.new('RGB', (480, 120 + 22), (16, 16, 20)); c.paste(im, (0, 22))
    dd = ImageDraw.Draw(c)
    dd.text((6, 4), ('Score Small (default)' if n < 50 else 'SOTN') + '   rig only, not headset-confirmed', font=f2, fill=(255, 220, 120))
    frames.append(c.quantize(colors=64, method=Image.MEDIANCUT, dither=Image.NONE))
frames[0].save(OUT + 'wordfont_small_sotn.gif', save_all=True, append_images=frames[1:], duration=95, loop=0, optimize=True)
print('gif', len(frames), os.path.getsize(OUT + 'wordfont_small_sotn.gif'))
