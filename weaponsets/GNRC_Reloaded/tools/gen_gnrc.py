"""Regenerate src/zscript/gnrc/gnrc_actors.gen.zs from GNRC's DECORATE (its non-weapon actors: projectiles, puffs,
casings, spent magazines, smoke, ammo). The weapons are hand-written (src/zscript/gnrc/).

GNRC reads every option through ACS (MD_OPTN). Led's options are not carried (owner), so each ACS read is replaced
by that option's default from GNRC's own CVARINFO before the conversion. GNRC's multi-line { } action blocks are
joined onto their frame line first (dec2zs reads one state per line).

usage: python3 tools/gen_gnrc.py [gnrc dir]"""
import os, re, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
SRC = sys.argv[1] if len(sys.argv) > 1 else '/home/claude/src/gnrc'
FILES = ['weapons/projectiles.txt', 'weapons/puffs.txt', 'weapons/casings.txt', 'weapons/smoke.txt', 'weapons/chainsaw.txt', 'items/ammo.txt']
# not carried: the punch (owner: RSQ Melee does melee), the death animation's thrown guns (Led's option), the
# iron-sight tokens
SKIP = ['FistAttack', 'BerserkFistAttack', 'DitchedPistol', 'DitchedShotgun', 'DitchedDBSG',
        'DitchedRifle', 'DitchedMG', 'EmptyDitchedMG', 'DitchedRL', 'DitchedPLRifle', 'DitchedBFG',
        'ModChainsaw', 'SawOn']	# chainsaw.txt: the saw is hand-written; its puffs are converted

# script -> the cvar it returns (acs/md_optn_src.acs, md_reld_src.acs)
SCRIPT = {'led_ReloadToggle': 'led_ReloadToggle', 'led_SmokeToggle': 'led_SmokeEffects', 'led_ShellSmoke': 'led_CasingSmoke',
          'led_CasingsToggle': 'led_ShellCasings', 'led_CasingLife': 'led_ShellLife', 'led_ArmorBonusToggle': 'led_ArmorBonus',
          'led_SpentMagsToggle': 'led_SpentMags', 'led_SpentMagLife': 'led_MagLife', 'led_BarrelToggle': 'led_Barrels',
          'led_FlinchToggle': 'led_AimPunch', 'led_ShellToggle': 'led_ShellSys', 'led_MedToggle': 'led_MedSys',
          'led_PumpToggle': 'led_ShotPump', 'led_SSGAltFireToggle': 'led_SSGAltFire', 'led_AnimToggle': 'led_DeathAnim',
          'led_ArmorToggle': 'led_ArmorSpark'}

def defaults():
    d = {}
    for m in re.finditer(r'(?im)^\s*(?:server|user)\s+(?:noarchive\s+)?(int|bool|float)\s+(\w+)\s*=\s*([^;]+);', open(os.path.join(SRC, 'cvarinfo.txt'), encoding='latin-1').read()):
        v = m.group(3).strip()
        d[m.group(2)] = {'true': '1', 'false': '0'}.get(v.lower(), v)
    return d

def prep(t, D):
    def acs(m):
        cv = SCRIPT.get(m.group(2))
        if not cv or cv not in D: raise SystemExit('no default for ACS script ' + m.group(2))
        return D[cv]
    t = re.sub(r'(ACS_NamedExecuteWithResult|CallACS)\(\s*"(\w+)"\s*\)', acs, t)
    t = re.sub(r'GetCvar\(\s*"(\w+)"\s*\)', lambda m: D[m.group(1)], t, flags=re.I)
    # a frame line followed by a { ... } block on the next lines: one line
    t = re.sub(r'(?m)^([ \t]*[A-Z0-9_#"]{4,6}\s+"?[A-Z\[\]#]+"?\s+-?\d+(?:\s+Bright)?)[ \t]*\n[ \t]*\{(.*?)\n[ \t]*\}',
               lambda m: m.group(1) + ' { ' + ' '.join(x.strip() for x in m.group(2).splitlines() if x.strip()) + ' }', t, flags=re.S)
    return t

def main():
    D = defaults()
    tmp = tempfile.mkdtemp()
    for f in FILES:
        p = os.path.join(tmp, f); os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, 'w', encoding='latin-1').write(prep(open(os.path.join(SRC, 'actors', f), encoding='latin-1').read(), D))
    out = os.path.join(ROOT, 'src/zscript/gnrc/gnrc_actors.gen.zs')
    r = subprocess.run([sys.executable, os.path.join(HERE, 'dec2zs.py'), out] + FILES + ['--skip', ','.join(SKIP), '--prefix', 'RSQGW_', '--rename', 'ARifle=RSQGW_ARifle'],
                       cwd=os.path.join(tmp), capture_output=True, text=True)
    print(r.stdout[-3000:], r.stderr[-2000:])
    # dec2zs leaves GNRC's unquoted, unterminated BounceType lines as they are
    z = open(out, encoding='latin-1').read()
    z, n = re.subn(r'(?m)^(\t+)BounceType\s+"?(\w+)"?\s*$', r'\1BounceType "\2";', z)
    open(out, 'w', encoding='latin-1').write(z)
    print('BounceType lines fixed:', n)

if __name__ == '__main__':
    main()
