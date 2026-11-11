# TEST ONLY: the new Crosses() (segment through a thick disc) against the old closest-point test, on the rig's numbers
import math
def sub(a,b): return tuple(x-y for x,y in zip(a,b))
def add(a,b): return tuple(x+y for x,y in zip(a,b))
def mul(a,k): return tuple(x*k for x in a)
def dot(a,b): return sum(x*y for x,y in zip(a,b))
def ln(a): return math.sqrt(dot(a,a))
T=4/2.94  # placeholder; CM(4) below
def old(A,B,C,n,R,T):
    d=sub(B,A); dd=dot(d,d); f=dot(sub(C,A),d)/dd; f=min(1,max(0,f)); q=add(A,mul(d,f)); rel=sub(q,C); al=dot(rel,n); ip=sub(rel,mul(n,al))
    return ln(ip)<=R and abs(al)<=T, al
def new(A,B,C,n,R,T):
    d=sub(B,A); da=dot(sub(A,C),n); dn=dot(d,n)
    if abs(dn)<1e-9:
        if abs(da)>T: return False
        t0,t1=0.0,1.0
    else:
        ta=(-T-da)/dn; tb=(T-da)/dn; t0=max(0.0,min(ta,tb)); t1=min(1.0,max(ta,tb))
        if t0>t1: return False
    u=sub(sub(A,C),mul(n,da)); w=sub(d,mul(n,dn)); ww=dot(w,w)
    t=t0 if ww<=0 else min(t1,max(t0,-dot(u,w)/ww))
    return ln(add(u,mul(w,t)))<=R
T=4*32/94  # 4 cm at 32 units = 0.94 m? see CM
for name,A,B,C,n in [('P2D near',(-270,0,42),(-320,0,28),(-306,7,39),(1,0,0)),('P2E far',(88,0,162),(-320,0,28),(-306,7,39),(1,0,0)),
                     ('P2B side, no block expected',(-212,-100,42),(-220,-100,28),(-206,-93,39),(1,0,0)),
                     ('edge-on skim',(-200,0,39),(-400,0,39),(-306,7,39),(0,1,0))]:
    print(name,'old',old(A,B,C,n,29.8,1.36),'new',new(A,B,C,n,29.8,1.36))
