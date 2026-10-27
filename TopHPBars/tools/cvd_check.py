#!/usr/bin/env python3
"""cvd_check.py -- measure how far apart each scheme's colour bands stay under colour-vision
deficiency simulation (Machado, Oliveira & Fernandes 2009, severity 1.0, applied in linear RGB).
Prints CIE76 delta-E and relative luminance for every pair of bands, for the simulation that the
scheme is meant for and for normal vision.  Usage: cvd_check.py [palette.json]  (default: the
palette table inside gen_art.py)."""
import sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
M = {
 'normal': [[1,0,0],[0,1,0],[0,0,1]],
 'protan': [[0.152286,1.052583,-0.204868],[0.114503,0.786281,0.099216],[-0.003882,-0.048116,1.051998]],
 'deutan': [[0.367322,0.860646,-0.227968],[0.280085,0.672501,0.047413],[-0.011820,0.042940,0.968881]],
 'tritan': [[1.255528,-0.076749,-0.178779],[-0.078411,0.930809,0.147602],[0.004733,0.691367,0.303900]],
}
def lin(c): c/=255; return c/12.92 if c<=0.04045 else ((c+0.055)/1.055)**2.4
def simulate(rgb, kind):
    l=[lin(v) for v in rgb]; m=M[kind]
    return [min(1,max(0,sum(m[i][j]*l[j] for j in range(3)))) for i in range(3)]
def lab(l):
    X=0.4124*l[0]+0.3576*l[1]+0.1805*l[2]; Y=0.2126*l[0]+0.7152*l[1]+0.0722*l[2]; Z=0.0193*l[0]+0.1192*l[1]+0.9505*l[2]
    f=lambda t: t**(1/3) if t>0.008856 else 7.787*t+16/116
    fx,fy,fz=f(X/0.95047),f(Y),f(Z/1.08883)
    return (116*fy-16, 500*(fx-fy), 200*(fy-fz)), Y
def report(name, bands, kinds):
    worst=1e9
    for k in kinds:
        labs={b:lab(simulate(c,k)) for b,c in bands.items()}
        keys=list(bands)
        for i in range(len(keys)):
            for j in range(i+1,len(keys)):
                a,b=labs[keys[i]],labs[keys[j]]
                de=math.dist(a[0],b[0])
                lr=(max(a[1],b[1])+0.05)/(min(a[1],b[1])+0.05)
                worst=min(worst,de) if k!='normal' or len(kinds)==1 else worst
                print(f'  {name:10s} {k:7s} {keys[i]:5s}-{keys[j]:5s} dE {de:6.1f}  lum ratio {lr:4.2f}')
    return worst
if __name__=='__main__':
    from gen_art import SCHEMES
    for s in SCHEMES:
        bands={'high':s['high'],'mid':s['mid'],'low':s['low'],'over':s['over']}
        kinds=['normal']+s.get('check',[])
        w=report(s['name'],bands,kinds)
        print(f'{s["name"]}: worst dE under its own simulation {w:.1f}\n')
