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
          'set rsqml_hands_model 0','qz_hmd "0 1.6 0 0 0 0"']: c(s)
put('r'); put('l'); w(40); c('netevent p1_inv 0'); c('netevent p1_hands 0')
c('echo E1_WHEEL_MAIN'); pose['r'][:3]=[0.05,1.55,-0.45]; put('r'); w(5); c('netevent wr_toggle_main'); w(15); pose['r'][:3]=[0.40,1.00,-0.05]; put('r'); w(40); c('echo E1_WHEEL_MAIN_CLOSE'); c('netevent wr_toggle_main'); w(30)
c('echo E1_WHEEL_OFF'); pose['l'][:3]=[-0.05,1.55,-0.45]; put('l'); w(5); c('netevent wr_toggle_off'); w(15); pose['l'][:3]=[-0.40,1.00,-0.05]; put('l'); w(40); c('echo E1_WHEEL_OFF_CLOSE'); c('netevent wr_toggle_off'); w(30)
pose['r'][:3]=[0.15,1.45,-0.25]; pose['l'][:3]=[-0.15,1.45,-0.25]; put('r'); put('l'); w(10)
c('echo E2_CLEAROUT'); c('netevent p1_spawn:DoomImp 70 0 0'); c('netevent p1_spawn:DoomImp 60 30 0'); w(15); c('netevent p1_mons 300 20')
c('netevent rsqg_pair 3 300'); w(1); c('netevent p1_mons 300 21'); w(3); c('netevent p1_mons 300 22'); w(6); c('netevent p1_mons 400 23'); w(25); c('netevent p1_clear 900'); w(5)
c('echo E3_GUN'); c('give Shot_Gun'); c('give ammo'); c('use Shot_Gun'); w(45); c('netevent p1_inv 30')
c('netevent p1_spawn:ExplosiveBarrel 36 0 0'); w(10)
for y in [1.40,1.30,1.20,1.10,1.00,0.90,0.80]:
    pose['l'][:3]=[0.0,y,-0.6] if y<1.4 else [-0.05,1.40,-0.45]; put('l'); w(8)
w(10); c('netevent p1_watch 120 1'); c('echo E3_KICK'); pose['l'][:3]=[0.0,1.40,-0.60]; put('l'); w(12)
pose['l'][:3]=[-0.15,1.45,-0.25]; w(1)
for k in range(8): pose['l'][1]=1.45; put('l'); w(3)
w(15); c('echo E3_SHOOT'); pose['r'][3]=-37; put('r'); w(6); c('netevent p1_hands 31')
for k in range(3): c('+attack'); w(3); c('-attack'); w(25)
pose['r'][3]=0; put('r'); w(20)
c('echo P1E_END'); c('quit')
open('/home/claude/scratch/rig1110/P1E/script.txt','w').write('; '.join(cmds)+'\n')
print(len(cmds))
