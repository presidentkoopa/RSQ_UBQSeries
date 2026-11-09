"""Context 2: chain reaction. A row of barrels; each one set off by another barrel's blast goes off bigger than the one
that set it off, and blinks for less time (the chain speeds up), building to a finale.
Modifier by chain depth d (0 = the barrel the player shot):
  d0: #5 Snap x1.0   d1: #5 Snap x1.25   d2: #6 Heavy x1.0   d3: #6 Heavy x1.2   d4+: finale = Metal Slug mega blast
  blink before blowing: 10, 8, 6, 6, 4 tics; light pool grows with it; screen kick (1-3 px) from d2 up."""
import sys, numpy as np
sys.path.insert(0,'/tmp/fx_ctx2')
import ctx
W,H,FY=840,400,330
XS=[80,200,322,446,622]
LINKS=[('snap',1.0,10),('snap',1.25,8),('heavy',1.0,6),('heavy',1.2,6),('ms',1.0,4)]
KICK={2:[2,-1,1],3:[3,-2,1,-1],4:[4,-3,3,-2,2,-1,1]}
def schedule():
    tb=[18]                                      # first barrel shot at tic 8, blinks 10, blows at 18
    for d in range(1,len(LINKS)): tb.append(tb[-1]+2+LINKS[d][2])   # hit 2 tics after the previous blast, then blinks
    return tb
def build():
    S=ctx.Scene(W,H,FY); tb=schedule()
    plates=[]
    for d,(name,k,_) in enumerate(LINKS):
        if name=='ms':
            C,O,lt,lc,mT0,anc=ctx.ms_plate(); plates.append(('ms',C,O,lt,lc,mT0,anc,k))
        else:
            C,O,lt=ctx.plate(name); plates.append((name,C,O,lt,None,ctx.T0,(ctx.PBX,ctx.PFY),k))
    T=tb[-1]-plates[-1][5]+len(plates[-1][1])+8
    frames=[]
    for t in range(T):
        c=S.blank()
        for d,(name,C,O,lt,lc,pT0,anc,k) in enumerate(plates):
            st=tb[d]-pT0; i=t-st
            if name=='ms':
                L=lt[i] if 0<=i<len(lt) else 0
                if L>0: S.pool(c,XS[d]+0.5,L,col=tuple(lc[i]),k=1.8)
            else:
                S.pool(c,XS[d]+0.5,lt(i),k=k)
        for d in range(len(LINKS)):
            b=ctx.barrel_img(t,tb[d],LINKS[d][2])
            if b: S.sprite(c,b,XS[d],FY)
        for d,(name,C,O,lt,lc,pT0,anc,k) in enumerate(plates):
            st=tb[d]-pT0; i=t-st
            if i<0 or i>=len(C) or (name!='ms' and i<pT0-1): continue
            Ci=np.asarray(C[i],np.float32); Oi=np.asarray(O[i],np.float32)
            Ci,Oi,a=ctx.scale_plate(Ci,Oi,k) if k!=1 else (Ci,Oi,anc)
            if name=='ms': a=anc
            S.comp(c,Ci,Oi,a,XS[d],FY)
        # screen kick: whole frame shifted, edge filled with background
        for d,ks in KICK.items():
            j=t-tb[d]
            if 0<=j<len(ks):
                dy=ks[j]; c=np.roll(c,dy,axis=0)
                if dy>0: c[:dy]=ctx.BG
                else: c[dy:]=ctx.FLOORC
        frames.append(ctx.to_img(c))
    return frames,tb
if __name__=='__main__':
    fr,tb=build(); print(len(fr),tb)
    ctx.save(fr,'/tmp/fx_ctx2/out/C_chain_full.gif'); ctx.save(fr,'/tmp/fx_ctx2/out/C_chain_half.gif',slow=2)
    for i,f in enumerate(fr): f.save(f'/tmp/fx_ctx2/look/chain_{i:03d}.png')
