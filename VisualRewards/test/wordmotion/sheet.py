# sheet.py (test only): the word-motion lane's evidence from decode.py's crops: the tic-by-tic sheet (the approved mockup's
# SOTN row over the rig's frames), the real-speed GIF (one rig frame a tic, 30 ms), and the fonts / Photosensitive panels.
import os
from PIL import Image, ImageDraw, ImageFont
C = '/home/claude/wm_scratch/crops/'
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'evidence') + '/'
MOCK = '/home/claude/wordmotion/word_motion_tic_by_tic.png'
F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 18)
f2 = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
BG = (20, 19, 26)
TICS = [0, 1, 2, 3, 4, 6, 8, 10]
BOX = {'THREAT!': (20, 85, 275, 132), 'UNCOMMON': (300, 85, 620, 132), 'KICK!': (205, 40, 365, 102)}
def cr(tag, tic, word): return Image.open(C + '%s/s%02d.png' % (tag, tic + 1)).crop(BOX[word])

LW, CWD = 300, 350
rows = [('MOCKUP (approved)', 'SOTN option row, x2', None, None, 120),
        ('RIG  THREAT!', 'held, SOTN two-tone (ldword.zs)', 'small', 'THREAT!', 47),
        ('RIG  UNCOMMON', 'a LegenDoom drop word\'s look', 'small', 'UNCOMMON', 47),
        ('RIG  KICK!', 'one-off; asked again at tic 10', 'small', 'KICK!', 62),
        ('RIG  THREAT!, photosafe', 'rsqa_photosafe 1: no flash', 'photo', 'THREAT!', 47),
        ('RIG  UNCOMMON, photosafe', '', 'photo', 'UNCOMMON', 47)]
H = 118 + sum(r[4] + 16 for r in rows) + 40
S = Image.new('RGB', (LW + CWD * len(TICS), H), BG); d = ImageDraw.Draw(S)
d.text((12, 8), 'RSQ VisualRewards: the words over monsters, SOTN entrance (rsqvr/words.zs). Score Small (default), tic by tic', font=F, fill=(255, 226, 120))
d.text((12, 34), 'RIG ONLY, NOT HEADSET-CONFIRMED. QZD 17.3 rig, the owner\'s full order (boss_full.sh: doom2, LegenDoom, brutal22test6, BD_VoxelPack, BD22 VR 2.0.4z, ... gate_rel3 + this VisualRewards),', font=f2, fill=(230, 230, 230))
d.text((12, 54), 'MAP01, run wm_small / wm_photo. The probe freezes the world and lets one tic run at a time: each column is the frame the rig drew for that tic (counted from the word\'s first drawn tic).', font=f2, fill=(230, 230, 230))
d.text((12, 74), 'Tics 0-3 the smear (wide, slanted: four slices a letter), tic 4 the snap upright, tics 4-7 the light look, 8-11 its own (the flash every 4 tics to 27). KICK! is asked again before tic 10: it pops in place, no smear.', font=f2, fill=(230, 230, 230))
y = 100
for i, tk in enumerate(TICS): d.text((LW + i * CWD + CWD // 2 - 22, y), 'tic %d' % tk, font=F, fill=(200, 200, 210))
y += 26
mock = Image.open(MOCK).convert('RGB')
for lab, sub, tag, word, rh in rows:
    d.text((10, y + rh // 2 - 18), lab, font=F, fill=(255, 255, 255) if tag else (255, 226, 120))
    d.text((10, y + rh // 2 + 4), sub, font=f2, fill=(170, 170, 185))
    for i, tk in enumerate(TICS):
        if tag is None:
            im = mock.crop((150 + i * 170, 175, 150 + i * 170 + 170, 235))
            im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
        else:
            im = cr(tag, tk, word)
        S.paste(im, (LW + i * CWD + (CWD - im.width) // 2, y + (rh - im.height) // 2))
    y += rh + 16
d.text((12, H - 30), 'Mockup: /home/claude/wordmotion/make.py (design/mockups/word_motion/). Rig: 720 px left eye, 1x pixels (no scaling).', font=f2, fill=(120, 120, 135))
S.save(OUT + 'wordmotion_tic_by_tic_sheet.png', optimize=True)
print('sheet', S.size, os.path.getsize(OUT + 'wordmotion_tic_by_tic_sheet.png'))

# the fonts: tic 0 (smear) and tic 4 (snap, light look) of THREAT! and UNCOMMON in every Word Font
FONTS = [('Score Small (0, default)', 'small'), ('SOTN (1)', 'sotn'), ('JFO (2)', 'jfo'), ('Score Big (3)', 'big'),
         ('Doom Small (4), Word Size 1.6', 'doom_ws')]
S = Image.new('RGB', (LW + 4 * CWD, 96 + len(FONTS) * 66 + 30), BG); d = ImageDraw.Draw(S)
d.text((12, 8), 'The SOTN entrance in every Word Font (rsqvr_wordfont): tic 0 (smear) and tic 4 (upright, light look)', font=F, fill=(255, 226, 120))
d.text((12, 34), 'RIG ONLY, NOT HEADSET-CONFIRMED. Same rig and order as the tic-by-tic sheet; runs wm_small, wm_sotn, wm_jfo, wm_big, wm_doom_ws.', font=f2, fill=(230, 230, 230))
for i, t in enumerate(['THREAT! tic 0', 'THREAT! tic 4', 'UNCOMMON tic 0', 'UNCOMMON tic 4']):
    d.text((LW + i * CWD + 90, 62), t, font=f2, fill=(200, 200, 210))
y = 90
for lab, tag in FONTS:
    d.text((10, y + 20), lab, font=f2, fill=(255, 255, 255))
    for i, (w, tk) in enumerate([('THREAT!', 0), ('THREAT!', 4), ('UNCOMMON', 0), ('UNCOMMON', 4)]):
        im = cr(tag, tk, w)
        S.paste(im, (LW + i * CWD + (CWD - im.width) // 2, y + (60 - im.height) // 2))
    y += 66
S.save(OUT + 'wordmotion_fonts.png', optimize=True)
print('fonts', S.size, os.path.getsize(OUT + 'wordmotion_fonts.png'))

# one whole frame: tic 0, Score Small, and tic 0 in the SOTN font
for tag, name in (('small', 'wordmotion_frame_tic0_small.png'), ('sotn', 'wordmotion_frame_tic0_sotn.png')):
    im = Image.open(C + tag + '/full_s01.png').convert('RGB')
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, 720, 26), fill=BG)
    d.text((8, 4), ('Score Small' if tag == 'small' else 'SOTN font') + ', tic 0 (smear). Rig only, not headset-confirmed', font=f2, fill=(255, 226, 120))
    im.save(OUT + name, optimize=True)
    print(name, os.path.getsize(OUT + name))

# real speed: one rig frame a tic (the held frames), 30 ms a frame (as the mockup's real-speed GIF), tics 0-47
frames = []
for tk in range(48):
    im = Image.open(C + 'small/s%02d.png' % (tk + 1)).crop((0, 10, 620, 140))
    c = Image.new('RGB', (620, 130 + 24), BG); c.paste(im, (0, 24))
    dd = ImageDraw.Draw(c)
    dd.text((6, 4), 'tic %2d   Score Small   rig only, not headset-confirmed' % tk, font=f2, fill=(255, 226, 120))
    frames.append(c.quantize(colors=64, method=Image.MEDIANCUT, dither=Image.NONE))
dur = [30] * (len(frames) - 1) + [900]
frames[0].save(OUT + 'wordmotion_real_speed.gif', save_all=True, append_images=frames[1:], duration=dur, loop=0, optimize=True)
print('gifs', len(frames), os.path.getsize(OUT + 'wordmotion_real_speed.gif'))
