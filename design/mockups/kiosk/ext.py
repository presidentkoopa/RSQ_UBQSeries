from PIL import Image
S=Image.open('/mnt/user-data/uploads/16c02e30-image.png').convert('RGBA')
bg=S.getpixel((1,1)); SP=S.load()
def ink(p): return abs(p[0]-bg[0])+abs(p[1]-bg[1])+abs(p[2]-bg[2])>=40
def key(im):
    im=im.copy(); px=im.load()
    for y in range(im.height):
        for x in range(im.width):
            p=px[x,y]
            if not ink(p): px[x,y]=(0,0,0,0)
    bb=im.getbbox(); return im.crop(bb) if bb else im
def bands(x0,x1,y0,y1,axis,gap=1):
    out=[];on=False;miss=0
    rng=range(y0,y1) if axis=='y' else range(x0,x1)
    for v in rng:
        hit=any(ink(SP[x,v]) for x in range(x0,x1)) if axis=='y' else any(ink(SP[v,y]) for y in range(y0,y1))
        if hit:
            if not on: s0=v; on=True
            miss=0; last=v
        elif on:
            miss+=1
            if miss>gap: out.append((s0,last+1)); on=False
    if on: out.append((s0,last+1))
    return out
cols=[(0,106),(106,212),(212,318)]
names=[['white','cyan','green'],['gold','violet','red'],['silver','orange','lime']]
WORDS={}; DIG={}
for ci,(x0,x1) in enumerate(cols):
    yb=bands(x0,x1,0,S.height,'y',0)
    for ri in range(3):
        nm=names[ri][ci]
        rows=yb[ri*7:ri*7+7]
        for k,(a,b) in enumerate(rows):
            segs=bands(x0,x1,a,b,'x',2)
            for j,(s0,s1) in enumerate(segs):
                WORDS[(nm,k,j)]=key(S.crop((s0,a,s1,b)))
        dy=rows[0]; ds=bands(x0,x1,dy[0],dy[1],'x',0)
        DIG[nm]=[key(S.crop((s0,dy[0],s1,dy[1]))) for s0,s1 in ds]
if __name__=='__main__':
    print(len(DIG['gold']), [ (k,WORDS[k].size) for k in WORDS if k[0]=='gold'])
    ws=[WORDS[k] for k in sorted(WORDS) if k[0]=='gold']
    W=max(w.width for w in ws); H=sum(w.height+2 for w in ws)
    o=Image.new('RGBA',(W,H),(20,20,30,255)); y=0
    for w in ws: o.alpha_composite(w,(0,y)); y+=w.height+2
    o.resize((W*5,H*5),Image.NEAREST).save('/tmp/sotn/gold_words.png')
