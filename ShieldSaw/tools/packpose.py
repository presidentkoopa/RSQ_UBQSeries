# pack a fake hand pose for `netevent ssq-pose A B 0` (headless harness; see HANDOFF.md §4)
# usage: packpose.py x y z yaw pitch roll [grip]   (x y z in map units relative to the pawn)
import sys
def clampi(v,lo,hi): return max(lo,min(hi,v))
def packpos(x,y,z):
    X=clampi(round(x*4),-1024,1023)&0x7FF; Y=clampi(round(y*4),-1024,1023)&0x7FF; Z=clampi(round(z*4),-512,511)&0x3FF
    return X|(Y<<11)|(Z<<22)
def packang(yaw,pitch,roll,grip):
    iy=clampi(round((yaw%360)/360*1023),0,1023); ip=clampi(round((pitch+90)/180*1023),0,1023); ir=clampi(round(((roll+180)%360)/360*1023),0,1023)
    v=iy|(ip<<10)|(ir<<20)|((1 if grip else 0)<<30)
    return v-(1<<32) if v>=(1<<31) else v
a=[float(v) for v in sys.argv[1:7]]; g=len(sys.argv)>7 and sys.argv[7]!='0'
print(packpos(*a[:3]), packang(*a[3:6], g))
