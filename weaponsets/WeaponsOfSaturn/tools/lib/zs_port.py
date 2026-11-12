"""Copy the BD22 VR scripts a standalone pack needs, with the few edits that free them from Brutal Doom's class names."""
import re, os
BD = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src'
FILES = ['rsvr/vrhand.zs', 'rsq/handler.zs', 'rsq/handtable.zs', 'rsq/gunmoves.zs', 'rsq/hands.zs', 'rsq/handtone.zs',
         'rsq/muzzle.zs', 'rsq/fistmoves.zs', 'rsq/casemodels.zs', 'rsq/casings.zs', 'rsr/rsr_assist.zs', 'rsr/vreload.zs', 'rsr/rsr_guns.bd.zs', 'rsr/rsb_guns.zs',
         'rsr/rsr_break.zs', 'rsr/rsr_pump.zs', 'rsr/rsr_pump_guns.zs', 'rsr/rsr_m203_geo.zs', 'rsr/rsr_m203.zs', 'rsq/flick.zs',
         'rsq/ballistics.zs', 'rsq/hit.zs', 'rsq/flash.zs', 'rsq/rounds.zs', 'rsq/bullet.zs', 'rsq/playerrounds.zs', 'rsq/shotfx.zs', 'rsq/dual.zs', 'rsq/dualhands.zs', 'rsq/scope.zs', 'rsq/scope_real.zs']
GUNS = ['AssaultShotgun', 'BFG10k', 'BIG_FUCKING_GUN', 'BrutalAxe', 'BrutalPistol', 'BrutalRevolver', 'BrutalSMG', 'Chain_saw',
        'DSweap', 'Devastator', 'FlameCannon', 'Flamethrower2', 'GrenadeLauncher', 'HellishMissileLauncher', 'IncendiaryLauncher',
        'MG42', 'MP40', 'Machinegun', 'Minigun', 'NukeLauncher', 'Plasma_Gun', 'RailGun', 'Revolver', 'Rifle', 'Rocket_Launcher',
        'SSG', 'Shot_Gun', 'Sniper', 'Unmaker', 'Melee_Attacks', 'RSQ_Off_Rifle']
G = '|'.join(GUNS)
def alias(t):
    n0 = t
    t = re.sub(r"\b([A-Za-z_]\w*(?:\.\w+)*) is '(%s)'" % G, r"RSQ_Alias.BD(\1) == '\2'", t)
    t = re.sub(r"\b([A-Za-z_]\w*(?:\.\w+)*)\.GetClassName\(\) == '(%s)'" % G, r"RSQ_Alias.Exact(\1) == '\2'", t)
    t = t.replace('Name n = w.GetClassName();', 'Name n = RSQ_Alias.Exact(w);')
    return t
def read(rel): return open(os.path.join(BD, 'zscript', rel), encoding='latin-1').read()
def port(outdir, patches):
    """patches: {rel: [(old, new, count_expected or None)]} applied after the alias pass. Every edit must hit."""
    for rel in FILES:
        t = alias(read(rel))
        for old, new, cnt in patches.get(rel, []):
            if isinstance(old, str):
                n = t.count(old)
                if n == 0 or (cnt and n != cnt): raise SystemExit('zs_port: %s: %r hits %d (want %s)' % (rel, old[:60], n, cnt))
                t = t.replace(old, new)
            else:
                t, n = old.subn(new, t)
                if n == 0 or (cnt and n != cnt): raise SystemExit('zs_port: %s: /%s/ hits %d (want %s)' % (rel, old.pattern[:60], n, cnt))
        p = os.path.join(outdir, 'zscript', rel)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, 'w', encoding='latin-1').write(t)
if __name__ == '__main__':
    import collections
    left = collections.Counter()
    for rel in FILES:
        t = re.sub(r'//[^\n]*', '', alias(read(rel)))
        for m in re.finditer(r"'(%s)'" % G, t): left[(rel, m.group(1))] += 1
        for m in re.finditer(r"\bis\s+'(\w+)'", t): print('is-left', rel, m.group(1))
    print(sum(left.values()), 'gun name literals after alias')
    for rel in FILES:
        t = alias(read(rel))
        for i, ln in enumerate(t.split('\n')):
            c = ln.split('//')[0]
            if re.search(r"'(%s)'" % G, c) and 'RSQ_Alias' not in c and "n == '" not in c: print(rel, i + 1, c.strip()[:150])
