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
          'set rsqml_guard 0','set rsqml_heavyhands 0','set rsqml_hadouken 0','set rsqml_wallsplat 0','set rsqml_boxing 0','set rsqml_slappers 0',
          'set rsqml_hands_model 0','set rsqml_headlock 1','set rsqml_headlock_shield 0',
          'netevent p1_clear 700','qz_hmd "0 1.6 0 0 0 0"']: c(s)
put('r'); put('l'); w(40); c('netevent p1_inv 0'); c('netevent p1_hands 0')
# ---- the Headlock throw, a free imp (nothing of the probe holds it)
c('echo D1_HEADLOCK'); c('netevent p1_spawn:DoomImp 45 8 0'); w(5)
slow('l',[-0.12,1.45,-0.55]); c('netevent p1_mons 200 1'); c('netevent rsqml_hgrip 1'); w(15); c('netevent p1_mons 200 2')
c('netevent p1_watch 70 2'); c('echo D1_THROW'); move('l',[-0.12,1.45,-1.15],4); w(30); c('netevent p1_mons 900 3'); c('netevent rsqml_hgrip 0')
slow('l',[-0.15,1.45,-0.25]); w(40); c('netevent p1_mons 900 4'); c('netevent p1_clear 1200'); w(5)
# ---- Ground Pound and Clear Out by gesture, on free imps
c('echo D2_POUND'); c('netevent p1_spawn:DoomImp 64 0 0'); c('netevent p1_spawn:DoomImp 40 56 0'); c('netevent p1_spawn:DoomImp 40 -56 0'); w(10); c('netevent p1_mons 300 10')
both([0.15,0.85,-0.25],[-0.15,0.85,-0.25],6); w(1); c('netevent p1_mons 300 11'); w(4); c('netevent p1_mons 300 12'); w(8); c('netevent p1_mons 400 13')
both([0.15,1.45,-0.25],[-0.15,1.45,-0.25],30); w(10); c('netevent p1_clear 600'); w(3)
c('echo D2_CLEAROUT'); c('netevent p1_spawn:DoomImp 70 0 0'); c('netevent p1_spawn:DoomImp 60 30 0'); w(3)
pose['r'][3]=-60; pose['l'][3]=-60
both([0.20,1.45,-0.15],[-0.20,1.45,-0.15],15); w(6); c('netevent p1_mons 300 20')
both([0.20,1.45,-0.65],[-0.20,1.45,-0.65],5); w(1); c('netevent p1_mons 300 21'); w(4); c('netevent p1_mons 300 22'); w(8); c('netevent p1_mons 400 23')
pose['r'][3]=0; pose['l'][3]=0
both([0.15,1.45,-0.25],[-0.15,1.45,-0.25],25); w(10); c('netevent p1_clear 700'); w(3)
# ---- the uppercut barrel kick at full speed, the gun in the main hand, then the shot where it lands
c('echo D3_GUN'); c('give Shot_Gun'); c('give ammo'); c('use Shot_Gun'); w(45); c('netevent p1_inv 30'); c('netevent p1_hands 30')
c('netevent p1_spawn:ExplosiveBarrel 36 0 0'); w(10)
slow('l',[0.0,1.05,-0.60]); c('netevent p1_watch 90 1'); c('echo D3_KICK'); move('l',[0.0,1.80,-0.60],3); w(3)
slow('l',[-0.15,1.45,-0.25]); w(20)
c('echo D3_SHOOT'); pose['r'][3]=-50; put('r'); w(4); c('netevent p1_hands 31'); c('+attack'); w(2); c('-attack'); w(30); c('+attack'); w(2); c('-attack'); w(30)
pose['r'][3]=0; put('r'); w(5)
c('echo P1D_END'); c('quit')
open('/home/claude/scratch/rig1110/P1D/script.txt','w').write('; '.join(cmds)+'\n')
print(len(cmds))
