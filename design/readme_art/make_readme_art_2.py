import sys,os
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'readme_art_lib.py')).read().split("if __name__")[0])
OUT=sys.argv[2]
for fn,t,c in [('connected',"IT'S ALL CONNECTED",'pink')]:
    header(t,c,f'{OUT}/h_{fn}.gif',sc=3)
