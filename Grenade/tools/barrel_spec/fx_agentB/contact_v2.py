from seqs_v2 import *
ticks=[-8,-1,0,1,2,3,4,6,9,12,16,21,28]
rows=[(n,)+fn() for n,fn in SEQ.items()]
th=CW; lab=22; head=26
S=Image.new('RGB',(len(ticks)*th,len(rows)*(CH+lab+head)),(0,0,0)); d=ImageDraw.Draw(S); y=0
for name,fr,T0 in rows:
    d.text((6,y+8),f'{name}_v2   total {len(fr)} tics: barrel stands 16 + blinks 10 (lit/unlit 5x2), blast {len(fr)-T0} tics',fill=(255,255,255)); y+=head
    for i,t in enumerate(ticks):
        S.paste(fr[min(len(fr)-1,T0+t)],(i*th,y))     # 1:1, no resampling
        d.text((i*th+6,y+CH+4),('barrel' if t<-1 else 'blink (lit)' if t<0 else f'tic {t}'),fill=(255,220,80))
    y+=CH+lab
S.save('out/B_contact_v2.png'); print(S.size)
