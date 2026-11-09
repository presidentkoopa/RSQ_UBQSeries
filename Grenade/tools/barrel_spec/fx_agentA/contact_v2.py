from PIL import Image, ImageDraw
T0=18; keys=[-6,-2,0,1,2,3,5,7,10,14,20,28]
names=['5_snap','6_heavy','7_pillar']; crop=(40,0,280,290); w,h=240,290
o=Image.new('RGB',(90+len(keys)*w,len(names)*(h+16)+4),(25,25,25)); d=ImageDraw.Draw(o)
for r,n in enumerate(names):
    y=r*(h+16)+16; d.text((6,y+h//2),'#'+n.replace('_',' '),fill=(255,220,120))
    for i,k in enumerate(keys):
        im=Image.open(f'/tmp/fx_agentA/look/{n}v2_{T0+k:03d}.png').crop(crop); o.paste(im,(90+i*w,y)); d.text((92+i*w,y-13),f'tic {k:+d}',fill=(200,200,200))
o.save('/tmp/fx_agentA/out/A_contact_v2.png'); print(o.size)
