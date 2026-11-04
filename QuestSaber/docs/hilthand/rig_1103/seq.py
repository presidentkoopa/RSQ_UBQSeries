import sys
# seq.py <scene> [lefty]  -> console script; the scene ends (quit) on the frame to look at
scene=sys.argv[1]; lefty=len(sys.argv)>2 and sys.argv[2]=='1'
M='qz_lhand' if lefty else 'qz_rhand'; O='qz_rhand' if lefty else 'qz_lhand'
TRIG='qz_ltrigger' if lefty else 'qz_rtrigger'
sx=-1 if lefty else 1
def P(x,y,z,p,yw,r=0): return '"%.3f %.3f %.3f %.1f %.1f %.1f"'%(x*sx,y,z,p,yw*sx,r*sx)
cam=sys.argv[3] if len(sys.argv)>3 else 'eye'
hmd={'eye':'"0 1.6 0 -25 0 0"','side':'"%.2f 1.45 -0.38 0 %d 0"'%(0.55*sx,90*sx)}[cam]
s=['qz_hmd %s'%hmd, '%s %s'%(M,P(0.13,1.42,-0.38,20,0)), '%s %s'%(O,P(-0.13,1.42,-0.38,20,0))]
if lefty: s.insert(0,'vr_control_scheme 10')
s+=['wait 40','give UBQS_Saber','wait 5','use UBQS_Saber','wait 60']
if scene=='idle': s+=['wait 20']
elif scene=='swing':
    # a forehand: wound back to the right, then swept across; quit mid-sweep
    for t,(x,y,z,p,yw) in enumerate([(0.30,1.55,-0.20,-10,70),(0.30,1.55,-0.22,-5,60),(0.26,1.52,-0.30,0,40),(0.18,1.48,-0.42,5,15)]):
        s+=['%s %s'%(M,P(x,y,z,p,yw)),'wait 1']
    s+=['wait 1']
elif scene in ('thrown','caught'):
    s+=['%s 1'%TRIG,'wait 8','%s %s'%(M,P(0.15,1.50,-0.15,0,0)),'wait 3']
    for z in (-0.30,-0.50,-0.68):
        s+=['%s %s'%(M,P(0.15,1.50,z,0,0)),'wait 1']
    s+=['%s 0'%TRIG,'wait 1','%s %s'%(M,P(0.13,1.42,-0.38,20,0))]
    s+=['wait 8'] if scene=='thrown' else ['wait 140']
s+=['quit']
print('; '.join(s))
