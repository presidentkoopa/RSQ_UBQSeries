# TEST ONLY (scratch): writes P1B/script.txt, the swing launch for group P1 (Melee). Poses: x right, y up, z back (forward is -z), metres.
cmds=[]
pose={'r':[0.15,1.45,-0.25,0],'l':[-0.15,1.45,-0.25,0]}
def c(s): cmds.append(s)
def w(n): c('wait %d'%n)
def put(h):
    x,y,z,p=pose[h]; c('qz_%shand "%.3f %.3f %.3f %d 0 0"'%(h,x,y,z,p))
def move(h,to,steps,pitch=None):
    """move hand h to 'to' over 'steps' tics, one pose per tic"""
    a=pose[h][:3]
    if pitch is not None: pose[h][3]=pitch
    for i in range(1,steps+1):
        pose[h][:3]=[a[k]+(to[k]-a[k])*i/steps for k in range(3)]
        put(h); w(1)
def slow(h,to,still=4):
    a=pose[h][:3]; d=max(abs(to[k]-a[k]) for k in range(3)); steps=max(1,int(d/0.02+0.999))
    move(h,to,steps); w(still)
def both(to_r,to_l,steps):
    ar=pose['r'][:3]; al=pose['l'][:3]
    for i in range(1,steps+1):
        pose['r'][:3]=[ar[k]+(to_r[k]-ar[k])*i/steps for k in range(3)]
        pose['l'][:3]=[al[k]+(to_l[k]-al[k])*i/steps for k in range(3)]
        put('r'); put('l'); w(1)
def tap(h):
    c('+attack' if h=='r' else '+oh_attack'); w(3); c('-attack' if h=='r' else '-oh_attack'); w(12)
def sweep(h,n,events={}):
    # side to side across x -0.15..0.15, 0.05 m a tic (1.75 m/s), n tics; events: {tic: command}
    xs=[-0.15,-0.10,-0.05,0.0,0.05,0.10,0.15,0.10,0.05,0.0,-0.05,-0.10]
    for i in range(n):
        if i in events: c(events[i])
        pose[h][0]=xs[i%len(xs)]; put(h); w(1)

c('set rsqml_gloves 1'); w(5); c('map MAP01'); w(30)
for s in ['vr_control_scheme 0','bd_tips 0','crosshair 0','screenblocks 10','notarget','buddha','set rsqml_debug 1','set rsqa_debug 1',
          'set rsqa_rumble_backup 1','set vr_quake_haptic_level 0','set rsqml_uppercut_barrels 1','set rsqml_groundpound 1','set rsqml_clearout 1',
          'netevent p1_clear 700','qz_hmd "0 1.6 0 0 0 0"']: c(s)
put('r'); put('l'); w(40); c('netevent p1_inv 0')
# ---- S1 the three punches on a held imp (main jab, main hook), then free it and uppercut with the off hand
c('echo S1_PUNCHES'); c('netevent r10_spawn:DoomImp 40 0 0'); w(10)
slow('r',[0.05,1.45,-0.15]); c('echo S1_JAB'); move('r',[0.0,1.45,-0.75],6); w(4); slow('r',[0.15,1.45,-0.25]); w(10)
slow('r',[0.45,1.45,-0.50]); c('echo S1_HOOK'); move('r',[-0.15,1.45,-0.50],6); w(4); slow('r',[0.15,1.45,-0.25]); w(10)
c('netevent p1_mons 200 1'); c('netevent p1_unhold')
slow('l',[-0.05,1.05,-0.50]); c('echo S1_UPPERCUT'); move('l',[-0.05,1.65,-0.50],6); w(3); c('netevent p1_mons 300 2'); w(6); c('netevent p1_mons 300 3'); w(6); c('netevent p1_mons 300 4')
slow('l',[-0.15,1.45,-0.25]); w(20); c('netevent p1_clear 600'); w(5)
# ---- S2 the Headlock: grab, three main-hand punches, the throw
c('echo S2_HEADLOCK'); c('netevent r10_spawn:DoomImp 45 8 0'); w(5)
slow('l',[-0.12,1.45,-0.55]); c('netevent p1_mons 200 10'); c('netevent rsqml_hgrip 1'); w(10); c('netevent p1_mons 200 11')
for k in range(3):
    slow('r',[0.0,1.45,-0.15]); c('echo S2_PUNCH_%d'%k); move('r',[-0.08,1.45,-0.75],6); w(4); slow('r',[0.15,1.45,-0.25])
c('netevent p1_mons 200 12'); w(2)
c('echo S2_THROW'); move('l',[-0.12,1.45,-1.05],4); w(6); c('netevent p1_mons 400 13'); w(10); c('netevent p1_mons 600 14'); c('netevent rsqml_hgrip 0')
slow('l',[-0.15,1.45,-0.25]); w(20); c('netevent p1_mons 800 15'); c('netevent p1_clear 900'); w(5)
# ---- S3 the open palm swats an imp's fireball
c('echo S3_SWAT_FIREBALL'); tap('r'); c('netevent r10_spawn:DoomImp 220 0 0'); w(5)
slow('r',[-0.15,1.30,-0.35]); sweep('r',50,{4:'netevent p1_fire'}); w(20)
c('netevent p1_clear 400'); w(3)
# ---- S4 the open palm meets a zombieman's bullet
c('echo S4_SWAT_BULLET'); c('netevent r10_spawn:ZombieMan 220 0 0'); w(10)
sweep('r',30,{3:'netevent p1_zshot',15:'netevent p1_zshot'}); w(10)
slow('r',[0.15,1.45,-0.25]); tap('r'); c('netevent p1_clear 400'); w(5)
# ---- S5 Ground Pound and Clear Out by gesture
c('echo S5_POUND'); c('netevent r10_spawn:DoomImp 64 0 0'); c('netevent r10_spawn:DoomImp 40 56 0'); c('netevent r10_spawn:DoomImp 40 -56 0'); w(10)
both([0.15,1.45,-0.25],[-0.15,1.45,-0.25],1); w(6)
both([0.15,0.85,-0.25],[-0.15,0.85,-0.25],6); w(12); c('netevent p1_mons 300 20')
both([0.15,1.45,-0.25],[-0.15,1.45,-0.25],30); w(10); c('netevent p1_clear 400'); w(3)
c('echo S5_CLEAROUT'); c('netevent r10_spawn:DoomImp 70 0 0'); c('netevent r10_spawn:DoomImp 60 30 0'); c('netevent p1_unhold'); w(3)
pose['r'][3]=-60; pose['l'][3]=-60
both([0.20,1.45,-0.15],[-0.20,1.45,-0.15],15); w(6); c('netevent p1_mons 300 21')
both([0.20,1.45,-0.65],[-0.20,1.45,-0.65],5); w(3); c('netevent p1_mons 300 22'); w(6); c('netevent p1_mons 300 23')
pose['r'][3]=0; pose['l'][3]=0
both([0.15,1.45,-0.25],[-0.15,1.45,-0.25],25); w(10); c('netevent p1_clear 600'); w(3)
# ---- S6 the off-hand fist beside a gun; the uppercut barrel kick, then the shot
c('echo S6_GUN'); c('give Shot_Gun'); c('give ammo'); c('use Shot_Gun'); w(45); c('netevent p1_inv 30')
c('netevent r10_spawn:DoomImp 40 0 0'); w(5)
slow('l',[-0.05,1.45,-0.15]); c('echo S6_OFF_JAB'); move('l',[0.0,1.45,-0.75],6); w(4); slow('l',[-0.15,1.45,-0.25]); w(5)
c('netevent p1_clear 300'); c('netevent p1_spawn:ExplosiveBarrel 36 0 0'); w(10)
slow('l',[0.0,1.05,-0.60]); c('netevent p1_watch 80 1'); c('echo S6_KICK'); move('l',[0.0,1.65,-0.60],6); w(3)
slow('l',[-0.15,1.45,-0.25]); w(25)
c('echo S6_SHOOT'); pose['r'][3]=-38; put('r'); w(4); c('+attack'); w(2); c('-attack'); w(30); c('+attack'); w(2); c('-attack'); w(30)
pose['r'][3]=0; put('r'); w(5)
# ---- S7 Slappers Only with the Saber's Start With Saber: the inventory every tic
c('echo S7_SLAPPERS'); c('set rsqml_slappers 1'); w(20)
for k in range(16): c('netevent p1_inv %d'%(100+k)); w(1)
c('set rsqml_slappers 0'); w(60); c('netevent p1_inv 200')
c('echo P1B_END'); c('quit')
open('/home/claude/scratch/rig1110/P1B/script.txt','w').write('; '.join(cmds)+'\n')
print(len(cmds))
