import sys; sys.path.insert(0,'/tmp/fx_agentG')
import numpy as np
from PIL import Image,ImageDraw
import fxg, seqg
O='/tmp/fx_agentG/out'
def grid(fr,T0,tics,crop,cols,title):
    w=crop[2]-crop[0]; h=crop[3]-crop[1]; rows=(len(tics)+cols-1)//cols
    S=Image.new('RGB',(cols*w,rows*h+18),(18,18,24)); d=ImageDraw.Draw(S); d.text((4,4),title,fill=(255,255,255))
    for i,t in enumerate(tics):
        x=(i%cols)*w; y=18+(i//cols)*h
        S.paste(fr[t+T0].crop(crop),(x,y)); d.rectangle((x,y,x+w-1,y+h-1),outline=(40,40,50)); d.text((x+4,y+4),f'tic {t:+d}',fill=(255,220,0))
    return S
ff,fT=seqg.floor_shot(); af,aT=seqg.air_shot()
A=grid(ff,fT,[-40,-12,-1,0,1,2,3,5,6,9,14,26],(40,90,600,410),6,
       'FLOOR: grenade bounces in, blinks red faster, white flash, blast at its rest spot  (1.25 px/map unit; floor rings reach 200 and 255 units)')
B=grid(af,aT,[-24,-2,-1,0,1,2,4,6,8,11,16,30],(40,0,600,420),6,
       'AIR: thrown arc, tracer hits it at 120 units up (tic -1 star ting), blast + bonus (gold crosshair lock, gold cluster ring, gold rain)')
S=Image.new('RGB',(max(A.width,B.width),A.height+B.height)); S.paste(A,(0,0)); S.paste(B,(0,A.height))
S=S.resize((S.width*2,S.height*2),Image.NEAREST) if False else S
S.save(f'{O}/G_contact.png')
# kinds
tics=[0,1,2,4,6,9,14,22]; crop=(60,170,580,400); w=crop[2]-crop[0]; h=crop[3]-crop[1]
K=Image.new('RGB',(110+len(tics)*w,18+len(fxg.KINDS)*h),(18,18,24)); d=ImageDraw.Draw(K)
for j,t in enumerate(tics): d.text((110+j*w+4,4),f'tic {t:+d}',fill=(255,220,0))
for i,(name,col) in enumerate(fxg.KINDS):
    fxg.KIND_LUT=None if col is None else fxg.kind_ramp(col)
    fr,T0=seqg.floor_shot()
    for j,t in enumerate(tics): K.paste(fr[t+T0].crop(crop),(110+j*w,18+i*h))
    d.text((6,18+i*h+h//2-10),name,fill=(255,255,255)); d.text((6,18+i*h+h//2+4),'fire' if col is None else f'#{col:06X}',fill=(170,170,170))
    if col is not None: d.rectangle((6,18+i*h+h//2+20,40,18+i*h+h//2+32),fill='#%06X'%col)
fxg.KIND_LUT=None
K.save(f'{O}/G_kinds_contact.png'); print(S.size,K.size)
