# fmark.py <run> <pattern> [k]: the frame files rendered just after the first log line matching pattern (k files)
import re,sys,os
run,pat=sys.argv[1],sys.argv[2]; k=int(sys.argv[3]) if len(sys.argv)>3 else 4
lines=open(run+'/run.log','rb').read().decode('latin1').splitlines()
files=sorted(f for f in os.listdir(run+'/frames') if f.endswith('.jpg'))
R=[int(m.group(1)) for l in lines for m in [re.match(r'R10 R (\d+) maptime',l)] if m]
off=int(files[-1][1:6])-R[-1]
seen=False; out=[]
for l in lines:
    if not seen and re.search(pat,l): seen=True; continue
    if seen:
        m=re.match(r'R10 R (\d+) maptime (\d+)',l)
        if m:
            f='f%05d.jpg'%(int(m.group(1))+off)
            if os.path.exists(run+'/frames/'+f): out.append(f+' t'+m.group(2))
            if len(out)>=k: break
print(' '.join(out))
