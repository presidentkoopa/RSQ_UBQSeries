"""v3: #5 Snap, #6 Heavy, #7 Pillar = v2 (seqB.py, unchanged) + bouncing, settling debris tuned to each.
Debris (debris_v3.py, same module as set B): hard-pixel bits thrown out in mirrored pairs about the barrel line,
tumbling, bouncing, skidding, settling on the floor, stepping down a palette as they cool, then blinking out.
Debris is drawn behind the sprite layers (fx_v3.render back=): hidden while inside a fireball, seen once clear."""
import sys, random; sys.path.insert(0,'/tmp/fx_ctx1/a')
import fx, fx_v3, seqB
from fx import BX, FY, PX
from seqB import T0
from debris_v3 import Debris as _D
BC=BX+0.5                                  # barrel centre line (barrel bbox 140..180 -> 160.5)
class Debris(_D):
    """set-A canvas: floats 0..1, tics absolute (blast at T0)"""
    def __init__(s,start,**kw): super().__init__(start,BC,FY,PX,cscale=1/255,**kw)
    def end(s): return s.start+s.len
# hot bits: white-yellow -> orange -> red -> brown -> charcoal
FIRE=[(255,250,215),(255,222,110),(255,160,40),(225,92,16),(170,54,16),(118,44,24),(84,52,42),(70,60,54)]
FIRE_HOLD=[(255,236,150),(255,176,50),(236,108,20),(190,66,14),(140,48,18),(104,50,32),(80,62,52)]
# barrel shrapnel: hot rim first, then the barrel's dark olive metal
SHRAP=[(255,200,120),(196,132,70),(118,110,76),(90,94,68),(72,78,58),(60,64,50)]
def snap():
    L,S,lt=seqB.snap()
    # quick, light: a dozen small hot bits flicked out with the flash, short hops, cool fast to charcoal
    B=[Debris(T0+5,n=12,seed=51,z0=(14,28),x0=(16,24),speed=(3.4,5.4),spread=(25,62),grav=1.0,bounce=(.3,.4),friction=.5,
               palettes=[(1,FIRE)],cool=(2,3),shapes=('dot','bar','vbar','sq','sq','L'),hold=(6,10),depth=(0,10),spawn=.5,trail=1,exact=True,until=30)]
    return L,S,lt,B
def heavy():
    L,S,lt=seqB.heavy()
    # heavy: fat glowing chunks that thud down (low bounce) and smoulder, plus dark barrel shrapnel slabs
    B=[Debris(T0+4,n=14,seed=61,z0=(14,34),x0=(20,30),speed=(4.4,8),spread=(34,74),grav=1.0,bounce=(.22,.32),friction=.45,
               palettes=[(1,FIRE_HOLD)],cool=(3,5),shapes=('sq','L','chunk','shard','sq'),hold=(16,26),depth=(0,12),spawn=.6,exact=True,until=40),
        Debris(T0+5,n=8,seed=62,z0=(18,34),x0=(22,30),speed=(5.6,8),spread=(42,70),grav=1.05,bounce=(.2,.3),friction=.4,
               palettes=[(1,SHRAP)],cool=(2,3),shapes=('slab','shard','tri'),hold=(18,28),depth=(2,12),spawn=.5,exact=True,until=42)]
    return L,S,lt,B
def pillar():
    L,S,lt=seqB.pillar()
    # pillar: bits flung high up the column, hanging, then raining back down near the barrel; streak while fast
    B=[Debris(T0+5,n=14,seed=71,z0=(36,70),x0=(0,8),speed=(6,8.5),spread=(4,18),grav=.9,bounce=(.3,.4),friction=.5,
               palettes=[(1,FIRE)],cool=(4,6),shapes=('bar','sq','vbar','L','sq'),hold=(10,18),depth=(0,10),spawn=1.0,trail=2,exact=True,until=46)]
    return L,S,lt,B
SEQS=[('5_snap',snap),('6_heavy',heavy),('7_pillar',pillar)]
if __name__=='__main__':
    O='/tmp/fx_ctx1/look/out'; which=sys.argv[1:] or [n for n,_ in SEQS]
    for name,fn in SEQS:
        if name not in which: continue
        Ls,Ss,lt,Bk=fn(); fr=fx_v3.render(Ls,Ss,back=Bk,light=lt)
        fx.save(fr,f'{O}/A1_{name}_v3_full.gif'); fx.save(fr,f'{O}/A1_{name}_v3_half.gif',slow=2)
        [f.save(f'/tmp/fx_ctx1/look/look/{name}v3_{i:03d}.png') for i,f in enumerate(fr)]
        print(name,len(fr),'blast tics',max([l.end() for l in Ls]+[s.end() for s in Ss+Bk])-T0)
