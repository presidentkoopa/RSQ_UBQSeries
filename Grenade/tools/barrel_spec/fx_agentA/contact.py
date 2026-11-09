from PIL import Image, ImageDraw
T0=16; keys=[-4,-1,0,1,2,4,6,9,13,18,25,34]
names=['snap','heavy','pillar']; crop=(40,0,280,280); w,h=240,280
o=Image.new('RGB',(90+len(keys)*w,len(names)*(h+16)+4),(25,25,25)); d=ImageDraw.Draw(o)
for r,n in enumerate(names):
    y=r*(h+16)+16; d.text((6,y+h//2),'A1_'+n,fill=(255,220,120))
    for i,k in enumerate(keys):
        im=Image.open(f'/tmp/fx_agentA/look/{n}_{T0+k:03d}.png').crop(crop); o.paste(im,(90+i*w,y)); d.text((92+i*w,y-13),f'tic {k:+d}',fill=(200,200,200))
o.save('/tmp/fx_agentA/out/A_contact.png'); print(o.size)
