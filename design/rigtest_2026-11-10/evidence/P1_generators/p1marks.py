import re,sys
# print each echo marker (uppercase line) with the maptime of the nearest R10 R line before it
last=None
for l in open(sys.argv[1]+'/run.log','rb').read().decode('latin1').splitlines():
    m=re.match(r'R10 R (\d+) maptime (\d+)',l)
    if m: last=int(m.group(2)); continue
    if re.match(r'^[A-Z][A-Z0-9_]+$',l.strip()): print(l.strip(), last)
