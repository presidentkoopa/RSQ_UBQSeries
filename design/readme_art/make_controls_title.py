# make_controls_title.py <repo> <out dir>: RSQ Controls' and RSQ PlayLog's README titles and dividers, in the same style as
# make_mod_art.py's, with the Doom marine walking (BD22 VR's PLAYA1-D1, copied to design/readme_art/marine/) instead
# of a monster: RSQ Controls is about the player.
import sys,os
HERE=os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(HERE,'readme_art_lib.py')).read().split("if __name__")[0])
OUT=sys.argv[2]; os.makedirs(OUT,exist_ok=True)
def walk(hmax):
    ims=[Image.open(os.path.join(HERE,'marine','PLAY%s1.png'%c)).convert('RGBA') for c in 'ABCD']
    k=min(2.0,hmax/max(i.height for i in ims))
    return [i.resize((max(1,int(i.width*k)),max(1,int(i.height*k))),Image.NEAREST) for i in ims]
for key,title,look in (('controls','RSQ CONTROLS',COL['orange']),('playlog','RSQ PLAYLOG',COL['green'])):
  base=word(title,look,4); hot=word(title,WHITE,4)
  w=walk(72)  ; mw=max(i.width for i in w); Hh=max(base.height,max(i.height for i in w))+8
  W=mw*2+base.width+int(base.height*0.5)+60; tx=mw+30
  frames=[]
  for f in range(36):
      c=Image.new('RGBA',(W,Hh),(0,0,0,0))
      if f<4: t=smear(hot if f<2 else base,1.0-f*0.25)
      else: t=hot if (f<10 and f%2==0) else base
      c.alpha_composite(t.crop((0,0,min(t.width,W-tx),t.height)),(tx,(Hh-base.height)//2))
      s=w[(f//3)%4]; c.alpha_composite(s,((mw-s.width)//2,Hh-s.height-2))
      s2=w[(f//3+2)%4].transpose(Image.FLIP_LEFT_RIGHT); c.alpha_composite(s2,(W-mw+(mw-s2.width)//2,Hh-s2.height-2))
      frames.append(c)
  save_gif(frames,[110]*36,f'{OUT}/'+key+'_title.gif')
  ws=[walk(44)[i%4] for i in range(12)]
  cw=max(i.width for i in ws)+14; d=Image.new('RGBA',(cw*12,48),(0,0,0,0))
  for i,s in enumerate(ws): d.alpha_composite(s,(i*cw+(cw-s.width)//2,48-s.height-2))
  d.save(f'{OUT}/'+key+'_divider.png',optimize=True)
  s=walk(56)[0]; c=Image.new('RGBA',(max(s.width,64),60),(0,0,0,0)); c.alpha_composite(s,((c.width-s.width)//2,60-s.height-2))
  c.save(f'{OUT}/'+key+'_icon.png',optimize=True)
print('ok')
