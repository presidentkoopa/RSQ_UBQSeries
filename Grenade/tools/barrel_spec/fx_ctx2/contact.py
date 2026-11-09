"""C2_contact.png: key frames, one row per shot (frames from look/, 1x, no rescale). Label = blast-relative tic."""
from PIL import Image, ImageDraw
T0=18
def crowd_map():
    HOLD={T0+3:3,T0+4:3,T0+5:3,T0+6:3,T0+7:2,T0+8:2,T0+9:2,T0+10:2}; m=[]
    for t in range(200):
        for k in range(HOLD.get(t,1)): m.append((t,k))
    return m
CM=crowd_map()
TB=[18, 28, 36, 44, 50]
ROWS=[
 ('C_liquid_nukage  base #6 Heavy + nukage splash/stain','liq_nukage',[14,18,20,22,26,30,33,36,40,44,50,58,66,74,81],(0,110,320,300),lambda i:f'tic {i-T0:+d}'),
 ('C_liquid_lava  base #6 Heavy + lava splash/crust','liq_lava',[14,18,20,22,26,30,33,36,40,44,50,58,66,74,81],(0,110,320,300),lambda i:f'tic {i-T0:+d}'),
 ('C_liquid_blood  base #6 Heavy + blood splash/stain','liq_blood',[14,18,20,22,26,30,33,36,40,44,50,58,66,74,81],(0,110,320,300),lambda i:f'tic {i-T0:+d}'),
 ('C_chain  #5 x1, #5 x1.25, #6 x1, #6 x1.2, finale MS mega (blows at tics 18/28/36/44/50)','chain',[14,21,30,38,46,53,60,72],(0,40,840,380),lambda i:f'tic {i}'),
 ('C_crowd  base #6 Heavy, 4 imps; kill at +3 -> gib bursts + held/tinted beat','crowd',[10,17,18,19,20,21,22,24,27,30,33,36,44,58],(70,170,570,330),lambda i:f'tic {CM[i][0]-T0:+d}'+(f' hold {CM[i][1]+1}' if CM[i][0] in range(T0+3,T0+11) else '')),
 ('C_colour_room  base #6 Heavy, complement of room glow (green/orange/violet)','room',[16,18,20,21,23,27,31,40],(0,60,960,300),lambda i:f'tic {i-T0:+d}'),
 ('C_colour_kill  base #6 Heavy, tier colour of the kill (Red tier 6 / Blue tier 3), from kill tic +2','kill',[16,18,19,20,21,24,28,33,44],(0,80,720,300),lambda i:f'tic {i-T0:+d}'),
]
LH=16; rows=[]
for title,pre,idx,crop,lab in ROWS:
    ims=[Image.open(f'/tmp/fx_ctx2/look/{pre}_{i:03d}.png').crop(crop) for i in idx]
    w,h=ims[0].size
    R=Image.new('RGB',(w*len(ims),h+2*LH),(24,22,26)); d=ImageDraw.Draw(R)
    d.text((4,2),title,fill=(255,220,90))
    for k,(im,i) in enumerate(zip(ims,idx)):
        R.paste(im,(k*w,LH)); d.text((k*w+3,LH+h+2),lab(i),fill=(200,200,200))
        d.line([(k*w,LH),(k*w,LH+h)],fill=(50,48,54))
    rows.append(R)
W=max(r.width for r in rows); H=sum(r.height for r in rows)
S=Image.new('RGB',(W,H),(24,22,26)); y=0
for r in rows: S.paste(r,(0,y)); y+=r.height
S.save('/tmp/fx_ctx2/out/C2_contact.png'); print(S.size)
