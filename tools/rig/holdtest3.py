"""TEST ONLY: one gun per run. Hold the trigger 140 tics, count that gun's shots; QZD as is vs upstream attackdown."""
import rig, re, json
GUNS = ['BrutalPistol','Shot_Gun','SSG','Rifle','BrutalSMG','MP40','AssaultShotgun','RailGun','Plasma_Gun','Sniper',
        'Rocket_Launcher','GrenadeLauncher','Revolver','Revolver2','MG42','MiniGun','Machinegun','Flamethrower2','FlameCannon',
        'IncendiaryLauncher','Unmaker','Devastator','NukeLauncher','HellishMissileLauncher','BIG_FUCKING_GUN','BFG10k',
        'DualPistols','DualRifles','DualSMG','DualMP40','DualPlasmaRifles','DualFlameCannon']
out = {}
for g in GUNS:
    row = {}
    for tag, extra in (('qzd', ()), ('up', [__import__('rig').B + '/upstream.pk3'])):
        s = ('wait 120; god; rsq_extra_weapons 1; rsr_reload 0; give ammo; give %s; wait 2; use %s; wait 170; '
             'echo B22MARK; +attack; wait 140; -attack; wait 30; echo B22END; quit') % (g, g)
        rc, t = rig.run('h3_%s_%s' % (tag, g), s, 700, extra=extra)
        after = t.split('B22MARK', 1)[1] if 'B22MARK' in t else ''
        held = set(x.lower() for x in re.findall(r'B22 S \d+ main (\S+)', after.split('B22END')[0]))
        shots = sum(1 for m in re.finditer(r'B22 SHOT \d+ (\S+) (\d+)', after) if m.group(1).lower() == g.lower())
        row[tag] = dict(shots=shots, ok=('B22END' in t and held == {g.lower()}), held=sorted(held))
    out[g] = row
    print('%-24s qzd %3d%s  upstream %3d%s%s' % (g, row['qzd']['shots'], '' if row['qzd']['ok'] else '?', row['up']['shots'], '' if row['up']['ok'] else '?',
          '  <-- differs' if row['qzd']['shots'] != row['up']['shots'] else ''), flush=True)
json.dump(out, open(__import__('rig').OUT + '/holdtest3.json', 'w'), indent=1)
print('DONE')
