# Sound engineering for the owner's explosion set (2026-11-10). In: his 17 WAVs. Out: mono OGGs, trimmed, cleaned,
# loudness-matched by role, soft-limited, faded.
import numpy as np, subprocess, json, sys
SRC='/mnt/user-data/uploads/explosions/'
def load(f):
    sr=int(subprocess.run(['ffprobe','-v','error','-show_entries','stream=sample_rate','-of','csv=p=0',SRC+f],capture_output=True,text=True).stdout.split()[0])
    raw=subprocess.run(['ffmpeg','-v','error','-i',SRC+f,'-ac','1','-af','highpass=f=28,dcshift=0','-f','f32le','-'],capture_output=True).stdout
    return np.frombuffer(raw,np.float32).astype(np.float64), sr
def env(a,sr,ms=10):
    w=max(1,int(sr*ms/1000)); return np.sqrt(np.convolve(a*a,np.ones(w)/w,'same'))
def db(x): return 20*np.log10(max(x,1e-9))
ROLE={ # role: (target impact RMS dBFS over its first 250 ms, max length s, tail floor dB below peak)
 'boom':(-14.0,1.15,-48),'pop':(-19.0,0.45,-44),'long':(-15.0,2.5,-52),'rocket':(-13.5,2.6,-50)}
SET=[('QGKB1','28.wav','boom'),('QGKB2','35.wav','boom'),('QGKB3','37.wav','boom'),('QGKB4','39.wav','boom'),
     ('QGKB5','40.wav','boom'),('QGKB6','42.wav','boom'),('QGKB7','58.wav','boom'),
     ('QGKP1','1.wav','pop'),('QGKP2','3.wav','pop'),('QGKP3','10.wav','pop'),('QGKP4','SFX00.wav','pop'),
     ('QGKP5','Merge Clip 1-174.wav','pop'),('QGKP6','Merge Clip 1-186.wav','pop'),('QGKP7','Merge Clip 1-189.wav','pop'),
     ('QGKR1','mapwpn005.acx_001.wav','rocket'),('QGKM2','27.wav','long'),('QGKMU','Merge Clip 1-175.wav','long')]
rep=[]
for lump,f,role in SET:
    a,sr=load(f); tgt,maxlen,floor=ROLE[role]
    e=env(a,sr); pk=e.max()
    # start: 3 ms before the envelope first reaches -30 dB of its peak
    s=max(0,int(np.argmax(e>pk*10**(-30/20)))-int(sr*0.003))
    a=a[s:]; e=e[s:]
    # end: where it last sits above the floor, capped by the role's length
    above=np.nonzero(e>pk*10**(floor/20))[0]; end=min(len(a), (above[-1] if len(above) else len(a))+int(sr*0.02), int(sr*maxlen))
    a=a[:end]
    # loudness: the impact's RMS (first 250 ms) to the role's target
    imp=np.sqrt((a[:int(sr*0.25)]**2).mean()); g=10**((tgt-db(imp))/20); a=a*g
    # soft limit to -1 dBFS: transparent below 0.6, tanh above
    ceil=0.891; knee=0.6
    over=np.abs(a)>knee
    a[over]=np.sign(a[over])*(knee+(ceil-knee)*np.tanh((np.abs(a[over])-knee)/(ceil-knee)))
    # fades: 2 ms in (no click on the trim), a cosine out over the last 25% (at most 600 ms)
    fi=int(sr*0.002); a[:fi]*=np.linspace(0,1,fi)
    fo=min(int(len(a)*0.45),int(sr*0.9)); a[-fo:]*=np.cos(np.linspace(0,np.pi/2,fo))**2
    pcm=(np.clip(a,-1,1)*32767).astype(np.int16).tobytes()
    subprocess.run(['ffmpeg','-v','error','-y','-f','s16le','-ar',str(sr),'-ac','1','-i','-','-c:a','libvorbis','-q:a','6','out/%s.ogg'%lump],input=pcm)
    subprocess.run(['ffmpeg','-v','error','-y','-f','s16le','-ar',str(sr),'-ac','1','-i','-','out/%s.wav'%lump],input=pcm)
    rep.append((lump,f,role,round(len(a)/sr,2),round(db(np.abs(a).max()),1),round(db(np.sqrt((a[:int(sr*0.25)]**2).mean())),1),round(db(g),1),round(s/sr*1000)))
for r in rep: print('%-6s %-24s %-6s %5.2fs peak %5.1f dB impact %5.1f dB gain %+5.1f dB trimmed %d ms'%r)
