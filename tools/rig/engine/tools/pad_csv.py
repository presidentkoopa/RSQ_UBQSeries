# Pad short rows in the engine's language CSVs (build.sh DATA FIX).
import csv, sys, io
for path in sys.argv[1:]:
    raw = open(path, encoding='utf-8', newline='').read()
    rows = list(csv.reader(io.StringIO(raw)))
    if not rows: continue
    n = len(rows[0]); fixed = 0
    for r in rows:
        if 0 < len(r) < n: r.extend([''] * (n - len(r))); fixed += 1
    if fixed:
        out = io.StringIO(); csv.writer(out, lineterminator='\n').writerows(rows)
        open(path, 'w', encoding='utf-8', newline='').write(out.getvalue())
        print('padded', fixed, 'rows in', path)
