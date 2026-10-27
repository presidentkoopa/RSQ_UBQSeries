import re,sys,statistics as st
rows=[]
for l in open(sys.argv[1]):
    m=re.search(r'T_GR t(\d+) h(\d) (\w+).*segs(\d+) ms([\d.]+)/([\d.]+)',l)
    if m: rows.append((int(m[1]),int(m[2]),m[3],int(m[4]),float(m[5]),float(m[6])))
d=[r[4] for r in rows]; t=[r[5] for r in rows]
print('samples',len(rows),'rope draw ms mean %.4f max %.4f'%(st.mean(d),max(d)),'| core tick ms mean %.4f max %.4f'%(st.mean(t),max(t)),'| pieces max',max(r[3] for r in rows))
