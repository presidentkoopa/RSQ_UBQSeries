# TEST ONLY. The weapon-set laser check (2026-11-13): three launches of /home/claude/rig/work/full_lsset.sh (WoS Reloaded,
# GNRC Reloaded, BD22 VR Reloaded 2.0.4i in BD22 VR Reloaded's place), each under the rig lock, with this folder packed as
# setprobe.pk3 (LSPROBE) and the RSQ_LaserSight.pk3 under test (LSPK3). Then: python3 analyze.py lsset_wos lsset_gnrc lsset_bd
import subprocess, sys, os
RH = 'qz_rhand "0.25 1.3 -0.3 -8 0 0"'
LAWAY = 'qz_lhand "-0.45 0.9 0.0 0 0 0"'
LAIM = 'qz_lhand "-0.35 1.3 -0.3 -8 0 0"'
def gun(g, real):
    s = 'echo LSP_GUN_%s; give %s; wait 2; use %s; wait 90; give ammo; netevent lsp_kill; wait 40; netevent lsp_shot; wait 10; netevent lsp_shot; wait 10; ' % (g, g, g)
    if real: s += '+attack; wait 2; -attack; wait 20; ' * 4
    return s
def dual(g):
    s = 'echo LSP_DUAL_%s; give %s; wait 2; use %s; wait 90; give ammo; netevent rsq_dual; wait 70; %s; wait 40; netevent lsp_shotoff; wait 10; netevent lsp_shotoff; wait 10; ' % (g, g, g, LAIM)
    s += 'qz_ltrigger 1; wait 2; qz_ltrigger 0; wait 20; ' * 3
    s += '%s; netevent rsq_dual; wait 70; ' % LAWAY
    return s
def script(mains, duals):
    s = 'set rsqls_debug 1; set sv_rsq_true_bullets 0; god; notarget; %s; %s; wait 60; netevent lsp_kill; ' % (RH, LAWAY)
    for g, real in mains: s += gun(g, real)
    for g in duals: s += dual(g)
    return s + 'wait 10; quit'
RUNS = {
 'lsset_wos': ('/home/claude/rsq_ubqseries/weaponsets/WoS_Reloaded/RSQ_WeaponsOfSaturn_0.1.0.pk3',
   [('RSQWS_1911', 1), ('RSQWS_Beretta', 1), ('RSQWS_MachineRifle', 1), ('RSQWS_MP40', 1), ('RSQWS_Riotgun', 0), ('RSQWS_Coachgun', 0), ('RSQWS_NovaRifle', 0), ('RSQWS_Minigun', 0)],
   ['RSQWS_1911', 'RSQWS_Beretta']),
 'lsset_gnrc': ('/home/claude/rsq_ubqseries/weaponsets/GNRC_Reloaded/GNRC_Reloaded_0.1.0.pk3',
   [('RSQGW_Beretta', 1), ('RSQGW_ARifle', 1), ('RSQGW_Riotgun', 0), ('RSQGW_DoubleSG', 0), ('RSQGW_PlasRifle', 0), ('RSQGW_Minigun', 0)],
   ['RSQGW_Beretta', 'RSQGW_ARifle']),
 'lsset_bd': ('/home/claude/presidentkoopa/rsq_bd_vr_reloaded/BD22_VR-Reloaded_2.0.4i.pk3',
   [('BrutalPistol', 1), ('Rifle', 1), ('MP40', 1), ('Shot_Gun', 0), ('SSG', 0), ('Plasma_Gun', 0)],
   ['BrutalPistol']),
}
only = sys.argv[1:] or list(RUNS)
for name in only:
    pk, mains, duals = RUNS[name]
    env = dict(os.environ, BDVR=pk, **({'NOVOX': '1'} if 'weaponsets' in pk else {}), LSPK3=os.environ.get('LSPK3', '/tmp/lsw/out/RSQ_LaserSight.pk3'), EVERY='70', RES='480')
    sc = script(mains, duals)
    pass
    print('==', name, flush=True)
    r = subprocess.run(['flock', '/home/claude/rig.lock', '/home/claude/rig/work/full_lsset.sh', name, '1500', sc, os.environ.get('LSPROBE', '/tmp/lsw/out/setprobe.pk3')],
                       env=env, capture_output=True, text=True)
    print(r.stdout[-3000:], r.stderr[-2000:], flush=True)
    out = open('/home/claude/rig/work/runs/%s/run.out' % name, errors='replace').read()
    if 'Script error' in out or 'Execution could not continue' in out:
        print('FATAL at startup: stopping the batch'); print(out[-3000:]); break
