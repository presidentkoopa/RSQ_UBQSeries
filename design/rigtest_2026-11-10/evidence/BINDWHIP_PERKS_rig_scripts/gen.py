# TEST ONLY: bind-whip / rope-perk rig scripts. gen.py <name> -> <name>/script.txt
import sys, os
REST=(0.20,1.30,-0.30,20,0)
def lerp(a,b,u): return tuple(x+(y-x)*u for x,y in zip(a,b))
def keys(ks):
    # ks: list of (tic, pose); returns per-tic poses
    out=[]
    for t in range(ks[-1][0]+1):
        for (a,pa),(b,pb) in zip(ks,ks[1:]):
            if a<=t<=b: out.append(lerp(pa,pb,(t-a)/(b-a) if b>a else 0)); break
    return out
def P(p): return '"%.3f %.3f %.3f %.2f %.2f 0"'%p
class S:
    def __init__(s): s.c=[]
    def add(s,*x): s.c+=list(x)
    def hold(s,pose,n,hand='qz_rhand'):
        for _ in range(n): s.c+=['%s %s'%(hand,P(pose)),'wait 1']
    def path(s,ks,hand='qz_rhand',extra=None):
        for k,p in enumerate(keys(ks)):
            if extra and k in extra: s.c+=extra[k] if isinstance(extra[k],list) else [extra[k]]
            s.c+=['%s %s'%(hand,P(p)),'wait 1']
    def crack(s,start,extra=None):
        # the deliberate crack (whp probe's SwingKeys): rest -> wound up over the shoulder -> swing forward and down
        ks=[(0,start),(14,(0.24,1.78,0.08,150,0)),(20,(0.24,1.80,0.10,155,0)),(23,(0.22,1.60,-0.35,60,0)),(25,(0.20,1.40,-0.55,0,0)),(34,(0.20,1.35,-0.50,10,0)),(60,REST)]
        s.path(ks,extra=extra)
    def write(s,name,head):
        os.makedirs(name,exist_ok=True)
        open(name+'/script.txt','w').write('; '.join(head+s.c+['wait 10','quit']))
HEAD=['wait 20','vr_control_scheme 0','bd_tips 0','crosshair 0','screenblocks 10']
