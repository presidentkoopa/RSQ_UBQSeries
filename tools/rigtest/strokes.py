import re,sys
ev=[]
for l in open(sys.argv[1]):
    m=re.match(r'T_GR t(\d+) h\d (take h\d|unhold|climb|hold|swing|latch).*? L([\d.]+).*free(\d\d)',l)
    if m: ev.append((int(m[1]),m[2],float(m[3]),m[4]))
last=None
for t,k,L,f in ev:
    if k.startswith('take'): last=(t,k,L)
    if k=='unhold' and last:
        print('%s t%d-%d  L %.1f -> %.1f (%+.1f)  free(main,off)=%s'%(last[1],last[0],t,last[2],L,L-last[2],f)); last=None
