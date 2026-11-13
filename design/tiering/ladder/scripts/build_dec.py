import sys, os, pickle
sys.path.insert(0,'/tmp/econ3/ladder/scripts')
import parse
def collect(root, exts):
    out=[]
    for dp,dn,fns in os.walk(root):
        for f in sorted(fns):
            if f.lower().endswith(exts) or f.lower()=='decorate': out.append(os.path.join(dp,f))
    return out
bd = collect('/tmp/bd22src/actors', ('.dec','.txt')) + collect('/tmp/bd22src/zscript', ('.zs','.zc','.txt'))
parse.build_decorate(bd, '/tmp/econ3/ladder/scripts/bd22_classes.pkl', 'bd22')
xm = [p for p in collect('/tmp/xmve_04', ('.dec','.txt')) if 'changelog' not in p.lower()] + collect('/tmp/xmve_07', ('.dec','.txt'))
parse.build_decorate(xm, '/tmp/econ3/ladder/scripts/xmve_classes.pkl', 'xmve')
for p in ['bd22','xmve']:
    c=pickle.load(open(f'/tmp/econ3/ladder/scripts/{p}_classes.pkl','rb')); print(p,len(c))
    for k in ['imp','riflezombie','superimp','bulldemon','cyberbaron','teharchvile','draugr','thamuz']:
        if k in c: print('  ',k,c[k]['parent'],{kk:v for kk,v in c[k]['props'].items() if kk in('health','speed','painchance')},len(c[k]['frames']), c[k]['file'].split('/')[-1])
