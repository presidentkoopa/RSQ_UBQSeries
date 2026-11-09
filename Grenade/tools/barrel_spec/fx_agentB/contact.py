from seqs import *
from PIL import ImageFont
ticks=[-8,-1,0,1,2,4,6,9,12,16,21,28]
rows=[]
for name,fn in SEQ.items():
    fr,T0=fn(); rows.append((name,fr,T0))
th=240; lab=26; head=30
S=Image.new('RGB',(len(ticks)*th,len(rows)*(th+lab)+head*len(rows)),(0,0,0)); d=ImageDraw.Draw(S)
y=0
for name,fr,T0 in rows:
    d.text((6,y+8),f'{name}   ({len(fr)-T0} tics after the blast starts; barrel stands {T0} tics incl. blink)',fill=(255,255,255)); y+=head
    for i,t in enumerate(ticks):
        f=fr[min(len(fr)-1,T0+t)].resize((th,th),Image.LANCZOS)
        S.paste(f,(i*th,y)); d.text((i*th+6,y+th+6),('barrel' if t<-1 else 'blink' if t<0 else f'tic {t}'),fill=(255,220,80))
    y+=th+lab
S.save('out/B_contact.png'); print(S.size)
