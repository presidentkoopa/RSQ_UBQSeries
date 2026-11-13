import struct,sys,collections
d=open(sys.argv[1],'rb').read()
n=len(d)//12
tot=0;mx=0;rows=[]
for i in range(n):
    r=d[i*12:i*12+12]
    name=r[:4].decode('latin1')
    nf=r[8]; st=struct.unpack('<H',r[10:12])[0]
    tot+=nf; rows.append((name,nf,st))
print("sprites",n,"sum numframes",tot)
# detect wrap: starts should be increasing
wraps=sum(1 for a,b in zip(rows,rows[1:]) if b[2]<a[2])
print("start wraps",wraps,"last",rows[-1])
if len(sys.argv)>2:
    for nm in sys.argv[2:]:
        print([r for r in rows if r[0].startswith(nm)])
