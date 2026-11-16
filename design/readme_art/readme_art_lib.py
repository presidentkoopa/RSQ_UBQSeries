import struct,sys,os,numpy as np
from PIL import Image
ROOT=sys.argv[1]
def fon2(data):
    h=data[4]|(data[5]<<8); first,last,mono,active=data[6],data[7],data[8],data[10]+1
    p=14 if data[11]&1 else 12; count=last-first+1
    if mono: widths=[struct.unpack_from('<H',data,p)[0]]*count; p+=2
    else: widths=list(struct.unpack_from('<%dH'%count,data,p)); p+=2*count
    pal=[tuple(data[p+3*i:p+3*i+3]) for i in range(active)]; p+=3*active
    out={}
    for i in range(count):
        w=widths[i]
        if w==0: continue
        n=w*h; px=bytearray()
        while len(px)<n:
            c=data[p]; p+=1
            if c>=128: c-=256
            if c>=0: px+=data[p:p+c+1]; p+=c+1
            elif c!=-128: px+=bytes([data[p]])*(1-c); p+=1
        a=np.zeros((h,w,4),np.uint8)
        for y in range(h):
            for x in range(w):
                k=px[y*w+x]
                if k:
                    a[y,x,:3]=pal[k] if k<len(pal) else (255,0,255); a[y,x,3]=255
        out[first+i]=Image.fromarray(a,'RGBA')
    return out,h
F1,H1=fon2(open(ROOT+'/Score/RSSCFON.fon2','rb').read())
F2,H2=fon2(open(ROOT+'/Score/RSSCFN2.fon2','rb').read())
def mask(s,F=F1,gap=1):
    gl=[F.get(ord(c)) for c in s]; h=max(g.height for g in gl if g); sp=max(3,h//3)
    w=sum((g.width+gap) if g else sp for g in gl); m=Image.new('L',(max(1,w),h),0); x=0
    for g in gl:
        if g:
            a=np.array(g).astype(float); L=(a[:,:,:3].max(2)*(a[:,:,3]/255)); L=np.where(L>60,L,0).astype(np.uint8)
            cols=np.where(L.max(0)>0)[0]
            if len(cols): L=L[:,cols[0]:cols[-1]+1]
            m.paste(Image.fromarray(L),(x,h-g.height),Image.fromarray(L)); x+=L.shape[1]+gap
        else: x+=sp
    return m
def paint(m,top,bot):
    a=np.array(m).astype(float); h,w=a.shape; o=np.zeros((h,w,4),np.uint8)
    for y in range(h):
        c=top if y<h/2 else bot; k=0.55+0.45*a[y]/255.0
        for i in range(3): o[y,:,i]=np.clip(c[i]*k*1.15,0,255)
        o[y,:,3]=np.where(a[y]>0,255,0)
    return Image.fromarray(o,'RGBA')
def boxed(im,pad=1,col=(8,8,10)):
    w,h=im.size; out=Image.new('RGBA',(w+pad*2,h+pad*2),(0,0,0,0)); a=im.split()[3]
    for dx in range(-pad,pad+1):
        for dy in range(-pad,pad+1): out.paste(Image.new('RGBA',im.size,col+(255,)),(pad+dx,pad+dy),a)
    out.alpha_composite(im,(pad,pad)); return out
def smear(im,k):
    w,h=im.size; im2=im.resize((int(w*(1+0.3*k)),h),Image.NEAREST); sh=0.45*k
    return im2.transform((int(im2.width+h*sh),h),Image.AFFINE,(1,sh,-h*sh,0,1,0),Image.NEAREST)
def word(s,look,sc=3,F=F1):
    im=boxed(paint(mask(s,F),*look),1); return im.resize((im.width*sc,im.height*sc),Image.NEAREST)
WHITE=((255,220,120),(255,255,230))
COL={'gold':((240,150,20),(255,236,120)),'green':((40,170,60),(170,255,110)),'blue':((40,90,230),(130,190,255)),
 'purple':((130,50,210),(220,150,255)),'cyan':((20,160,190),(150,250,255)),'red':((190,20,20),(255,120,90)),
 'orange':((255,110,20),(255,210,90)),'steel':((96,100,112),(240,242,248)),'pink':((220,40,140),(255,170,220)),'lime':((120,200,20),(230,255,120))}
def save_gif(frames,durs,path,bg=None):
    # transparent GIF: palette with index 0 = transparent
    out=[]
    for fr in frames:
        a=np.array(fr); alpha=a[:,:,3]>127
        rgb=Image.fromarray(a[:,:,:3],'RGB').quantize(255,method=Image.MEDIANCUT,dither=Image.Dither.NONE)
        p=np.array(rgb)+1; p[~alpha]=0
        im=Image.fromarray(p.astype(np.uint8),'P'); pal=rgb.getpalette()[:765]; im.putpalette([0,0,0]+pal)
        out.append(im)
    out[0].save(path,save_all=True,append_images=out[1:],duration=durs,loop=0,transparency=0,disposal=2,optimize=False)
def header(text,colour,path,sc=3,width=None):
    a=COL[colour]; base=word(text,a,sc); hot=word(text,WHITE,sc)
    W=width or int(base.width*1.3+base.height*0.5); Hh=base.height+8
    frames=[];durs=[]
    def put(im,dur):
        c=Image.new('RGBA',(W,Hh),(0,0,0,0)); c.alpha_composite(im.crop((0,0,min(im.width,W),im.height)),(0,4)); frames.append(c); durs.append(dur)
    for k in (1.0,0.75,0.5,0.25): put(smear(hot if k>0.5 else base,k),55)
    for i in range(3): put(hot,110); put(base,110)
    put(base,4200)
    save_gif(frames,durs,path); base_c=Image.new('RGBA',(W,Hh),(0,0,0,0)); base_c.alpha_composite(base,(0,4)); return base_c
if __name__=='__main__':
    out=sys.argv[2]; os.makedirs(out,exist_ok=True)
    print('F1 h',H1,'chars',''.join(chr(c) for c in sorted(F1)));print('F2 h',H2,'chars',''.join(chr(c) for c in sorted(F2)))
