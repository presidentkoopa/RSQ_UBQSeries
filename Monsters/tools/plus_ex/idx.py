# index DECORATE actors: name -> file, line, parent, text (comments kept)
import re,os,json,sys
def strip_comments(t):
    # replace comments with spaces, keep newlines and strings
    out=[];i=0;n=len(t)
    while i<n:
        c=t[i]
        if c=='"':
            j=i+1
            while j<n and t[j]!='"':
                if t[j]=='\\': j+=1
                j+=1
            out.append(t[i:j+1]); i=j+1
        elif t.startswith('//',i):
            j=t.find('\n',i); j=n if j<0 else j
            out.append(' '*(j-i)); i=j
        elif t.startswith('/*',i):
            j=t.find('*/',i+2); j=n if j<0 else j+2
            out.append(re.sub(r'[^\n]',' ',t[i:j])); i=j
        else: out.append(c); i+=1
    return ''.join(out)
hdr=re.compile(r'^[ \t]*actor[ \t]+"?([\w\.]+)"?[ \t]*(?::[ \t]*"?([\w\.]+)"?)?[ \t]*(?:replaces[ \t]+"?([\w\.]*)"?)?[ \t]*(\d+)?',re.I|re.M)
def index(files,root):
    acts={}
    for f in files:
        raw=open(f,encoding='latin-1').read()
        t=strip_comments(raw)
        for m in hdr.finditer(t):
            # find opening brace then matching
            b=t.find('{',m.end())
            d=0;j=b
            while j<len(t):
                if t[j]=='"':
                    j=t.find('"',j+1)
                elif t[j]=='{': d+=1
                elif t[j]=='}':
                    d-=1
                    if d==0: break
                j+=1
            line=t.count('\n',0,m.start())+1
            nm=m.group(1)
            if nm.lower() in acts: 
                acts[nm.lower()+'#dup'+str(line)]=None
            acts[nm.lower()]={'name':nm,'parent':m.group(2) or '','rep':m.group(3) or '','file':os.path.relpath(f,root),'line':line,'endline':t.count('\n',0,j)+1,'text':raw[m.start():j+1],'ctext':t[m.start():j+1]}
    return acts
if __name__=='__main__':
    which=sys.argv[1]
    if which=='plus':
        root='/tmp/chplus'
        top=open(root+'/DECORATE',encoding='latin-1').read()
        inc=re.findall(r'#include\s+"decorate/([^"]+)"',strip_comments(top),re.I)
        files=[root+'/DECORATE']+[os.path.join(root,'DECORATE_dir',i.replace('misc','MISC')) for i in inc]
    else:
        root='/tmp/ch104'
        top=open(root+'/DECORATE',encoding='latin-1').read()
        inc=re.findall(r'#include\s+"([^"]+)"',strip_comments(top),re.I)
        files=[root+'/DECORATE']+[os.path.join(root,i) for i in inc if os.path.exists(os.path.join(root,i))]
        print([i for i in inc if not os.path.exists(os.path.join(root,i))])
    a=index(files,root)
    json.dump({k:v for k,v in a.items() if v},open('/home/claude/scratch_plusex/%s_idx.json'%which,'w'))
    print(which,len(files),len(a))
