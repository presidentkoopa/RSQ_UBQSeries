import os, sys
sys.path.insert(0, '/home/claude/rsq_weapondepot/tools/rig')
import rig, mags, handrot as h
g = mags.tables()[1]
reload_ = ('give Clip2 400; +attack; wait 12; -attack; wait 25; +reload; wait 4; -reload; wait 30; qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 12; '
           'qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 15; qz_lhand "%s"; wait 25; qz_ltrigger 0; wait 40; '
           % (rig.lpose(0, 40, -30), mags.at(g, g['M'] + 3), mags.at(g, g['M'] * 0.5), mags.at(g, 0)))
L, U, TR, REAR = 0.520, -5.000, 11.0, 28.44
PALM = (-1.5, 2.0, -4.5); RND, RAX = (-1.930, 4.560, -4.500), (0, 0, 1)
palm_at = lambda x: h.place(PALM, (1, 0, 0), (x, L, U - 2.0), (1, 0, 0))[0]
round_at = lambda x: h.place(RND, RAX, (x, L, U), (1, 0, 0))[0]
FAR = '-0.25 1.3 -0.3 30 0 0'
m203 = ('give AmmoRocket 10; +altattack; wait 3; -altattack; wait 60; '
     'qz_lhand "%s"; wait 10; qz_lgrip 1; wait 10; qz_ltrigger 1; wait 6; '
     'qz_lhand "%s"; wait 8; qz_lhand "%s"; wait 8; qz_lhand "%s"; wait 10; qz_ltrigger 0; qz_lgrip 0; wait 6; '
     'qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 10; qz_lhand "%s"; wait 12; qz_lhand "%s"; wait 15; qz_ltrigger 0; wait 8; '
     'qz_lhand "%s"; wait 10; qz_ltrigger 1; wait 8; qz_lhand "%s"; wait 8; qz_lhand "%s"; wait 10; qz_ltrigger 0; wait 8; '
     'qz_lhand "%s"; wait 10; +altattack; wait 3; -altattack; wait 40; '
     % (palm_at(40), palm_at(40+TR*0.4), palm_at(40+TR*0.75), palm_at(40+TR+0.5), FAR, round_at(REAR+3.5), round_at(REAR+TR+0.4+4.3),
        palm_at(40+TR), palm_at(40+TR/2), palm_at(39.5), FAR))
head = 'god; ubqs_diag 4; rsr_reload 1; rsr_grab_with 0; rsr_debug 1; qz_rhand "0.25 1.3 -0.3 30 0 0"; qz_lhand "%s"; wait 40; ' % FAR
A = (head + 'echo FCPSTEP saber_in; netevent fcp_saber; wait 70; echo FCPSTEP rifle_by_key; use Rifle; wait 60; echo FCPSTEP reload; ' + reload_
     + 'echo FCPSTEP m203; ' + m203 + 'echo FCPSTEP saber_back; netevent fcp_saber; wait 70; echo FCPSTEP offgun; netevent fcp_offgun 3; wait 70; '
     'echo FCPSTEP rifle_offgun; use Rifle; wait 60; echo FCPSTEP saber_offgun; netevent fcp_saber; wait 70; quit')
B = (head + 'echo FCPSTEP saber_in; netevent fcp_saber; wait 70; echo FCPSTEP next_saber; netevent fcp_next; wait 60; echo FCPSTEP rifle; use Rifle; wait 60; '
     'echo FCPSTEP next_rifle; netevent fcp_next; wait 60; save fcs1; wait 20; echo FCPSTEP saber; netevent fcp_saber; wait 70; echo FCPSTEP load_rifle; load fcs1; wait 70; '
     'echo FCPSTEP saber2; netevent fcp_saber; wait 70; save fcs2; wait 20; echo FCPSTEP rifle2; use Rifle; wait 60; echo FCPSTEP load_saber; load fcs2; wait 70; '
     'echo FCPSTEP wheel_direct; netevent fcp_direct 0; wait 40; echo FCPSTEP saber3; netevent fcp_saber; wait 70; echo FCPSTEP death; god; kill; wait 40; quit')
open(sys.argv[1] + '/A.txt', 'w').write(A); open(sys.argv[1] + '/B.txt', 'w').write(B)
