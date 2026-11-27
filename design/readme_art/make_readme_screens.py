# make_readme_screens.py <uploads dir> <bd22 renders dir> <out dir>
# The front page's game pictures (design/readme_art/screens/): the owner's game screenshots of 2026-11-25 to 11-27
# and BD22 VR Reloaded's rig renders, cropped, framed and saved small. Nothing is drawn on them but a frame.
# Sources (owner's uploads, by file name): c3337010 / fdc1832e / 41139b16 (grenade kinds SMOKE, CHARM, INFIGHT),
# 0bfe512b (the mega blast, the same frames as Grenade/docs/readme/mega.gif), e536f32c (the Wheel's ring and sheet),
# 6b381cab (the holster assignment screen), 6a6ad1c8 (a watch card), f9602695 (a small card), 1edb8076 and e2184782
# (two sabers), 2c95b4a2 (pistol, laser, pickup message), 7c16d1d8 (two pistols with lasers).
import sys,os
from PIL import Image,ImageDraw
U,BD,OUT=sys.argv[1],sys.argv[2],sys.argv[3]; os.makedirs(OUT,exist_ok=True)
EDGE=(150,110,40); BG=(12,10,16)
def load(f): return Image.open(os.path.join(U,f)).convert('RGB')
def crop(im,box,w=None):
    W,H=im.size; c=im.crop((int(box[0]*W),int(box[1]*H),int(box[2]*W),int(box[3]*H)))
    return c.resize((w,round(c.height*w/c.width)),Image.LANCZOS) if w else c
def frame(im,pad=3):
    o=Image.new('RGB',(im.width+pad*2,im.height+pad*2),EDGE); o.paste(im,(pad,pad)); return o
def row(ims,gap=8,h=None):
    if h: ims=[i.resize((round(i.width*h/i.height),h),Image.LANCZOS) for i in ims]
    H=max(i.height for i in ims); W=sum(i.width for i in ims)+gap*(len(ims)+1)
    o=Image.new('RGB',(W,H+gap*2),BG); x=gap
    for i in ims: o.paste(i,(x,gap+(H-i.height)//2)); x+=i.width+gap
    return o
def save(im,name,q=86):
    p=os.path.join(OUT,name); im.save(p,quality=q,optimize=True); print(name,im.size,os.path.getsize(p))
# Grenade: the kinds, each with its word over the grenade in the hand
k=[crop(load('c3337010-image.webp'),(0.30,0.24,0.86,0.70)),crop(load('fdc1832e-image.webp'),(0.36,0.23,0.90,0.70)),
   crop(load('41139b16-image.webp'),(0.33,0.22,0.87,0.66))]
save(row([frame(i) for i in k],h=250),'grenade_kinds.jpg')
# Grenade: the mega blast, frame by frame
m=Image.open(os.path.join(U,'0bfe512b-image.webp')); fr=[]
for n in (6,10,16,26,40,62):
    m.seek(n); fr.append(frame(m.convert('RGB').crop((110,150,770,840)).resize((190,198),Image.LANCZOS),2))
save(row(fr,gap=6),'grenade_mega_frames.jpg')
# Wheel: the ring and its data sheet; the holster assignment screen
save(frame(crop(load('e536f32c-image.webp'),(0.05,0.30,1.0,0.95),880)),'wheel_ring.jpg')
save(frame(crop(load('6b381cab-image.webp'),(0.20,0.38,0.80,0.97),880)),'wheel_holster_screen.jpg')
# Gun Cards: the watch card on the wrist; the small card beside an off-hand pistol
save(frame(crop(load('6a6ad1c8-image.webp'),(0.0,0.36,0.84,0.82),880)),'guncards_watch_card.jpg')
save(frame(crop(load('f9602695-image.webp'),(0.15,0.48,1.0,1.0),640)),'guncards_small_card.jpg')
# Saber: two sabers; their clash
save(frame(crop(load('e2184782-image.webp'),(0.0,0.15,1.0,0.85),1000)),'saber_two_sabers.jpg')
save(frame(crop(load('1edb8076-image.webp'),(0.0,0.26,1.0,0.85),1000)),'saber_clash.jpg')
# Laser Sight: a pistol's beam (with a pickup message); two pistols' beams
save(frame(crop(load('2c95b4a2-image.webp'),(0.15,0.38,0.85,1.0),880)),'lasersight_pistol.jpg')
save(frame(crop(load('7c16d1d8-image.webp'),(0,0,1,1),1100)),'lasersight_two_pistols.jpg')
# BD22 VR Reloaded: three reloads by hand, mid-reload (its renders/2.0_reload_hands.png, panels m203, mag18, pump)
r=Image.open(os.path.join(BD,'2.0_reload_hands.png')).convert('RGB')
p=[frame(r.crop(c),2) for c in ((320,720,640,1038),(640,720,960,1038),(640,384,960,700))]
save(row(p,gap=6),'bd22_reload_by_hand.jpg')
# Gun Bonsai VR and Score: the top of the view, each hand's gauge (off hand left: Fist; main hand right: Rifle) with
# RSQ Score's line between them
save(frame(crop(load('e536f32c-image.webp'),(0.03,0.0,0.90,0.125),1400)),'top_of_view_gauges_score.jpg')
