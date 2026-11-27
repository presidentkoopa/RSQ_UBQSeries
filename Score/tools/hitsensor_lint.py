"""hitsensor_lint.py -- checks the XMVE hit sensors (zscript/rsscore/hitsensor.zs + hitsensor_cards.zs) against the
DECORATE they copy. Read-only; exit 1 on any failure.

    python -I tools/hitsensor_lint.py [--bd <BD22 src folder>] [--xmve <XMVE pk3>]

  L1 hitsensor_cards.zs is what hitsensor_gen.py writes today (not stale, never hand-edited)
  L2 every helper class XMVE spawns by name has a card, and no card is a non-helper (MeatShield, the boss hitboxes ...)
  L3 every carded class keeps its root's damage factors and flags (the sensor carries the root's), and its own box,
     health and Spawn life match its card
  L4 the sensors' Default blocks carry their root's factors, health, box, PainChance, DamageType, GibHealth and flags
  L5 the leg ladder (LadderBelow / LadderBlast, Death, XDeath, Pain.SSG, the fall-through) is Leg.dec's, in order
  L6 the head blast is Head_Sys.dec's fall-through A_Explode, and its ladder really is dead at its health
  L7 no XMVE helper spawn drops the target pointer (the declaration finds its monster through it)
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hitsensor_dec as dec  # noqa: E402

ZS = os.path.join(HERE, "..", "zscript", "rsscore", "hitsensor.zs")
CARDS = os.path.join(HERE, "..", "zscript", "rsscore", "hitsensor_cards.zs")
OWN_OK = {"radius", "height", "bloodtype", "bloodcolor", "states"}   # what a helper subclass may set for itself
FLAG_OK = {"DONTRIP"}
IGNORED_FLAGS = {"SERVERSIDEONLY"}   # a dummy flag in this engine


def zs_class(text, name):
    m = re.search(r"(?im)^class\s+%s\b[^{]*\{" % re.escape(name), text)
    if not m:
        return ""
    depth, j = 1, m.end()
    while j < len(text) and depth:
        depth += {"{": 1, "}": -1}.get(text[j], 0)
        j += 1
    return text[m.end():j - 1]


def zs_default(body):
    m = re.search(r"(?s)\bDefault\s*\{(.*?)\}", body)
    d = re.sub(r"//[^\n]*", "", m.group(1)) if m else ""
    factors = {k.lower(): float(v) for k, v in re.findall(r'DamageFactor\s+"(\w+)"\s*,\s*([-\d.]+)', d)}
    flags = {f.upper(): s == "+" for s, f in re.findall(r"(?<![\w\"])([+-])([A-Za-z_]\w*)", d)}
    props = {k.lower(): v.strip() for k, v in re.findall(r"(?m)^\s*([A-Za-z]\w*)\s+([^;]+);", d) if k.lower() != "damagefactor"}
    return props, factors, flags


def ints(s):
    return [int(x) for x in re.findall(r"-?\d+", s)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bd", default=dec.BD_SRC)
    ap.add_argument("--xmve", default=dec.XMVE_PK3)
    a = ap.parse_args()
    fails = []

    def fail(code, msg):
        fails.append("%s %s" % (code, msg))

    actors = dec.read_sources(a.bd, a.xmve)
    head, leg, other = dec.helpers(actors)
    cards_text = open(CARDS, encoding="utf-8").read()
    zs = open(ZS, encoding="utf-8").read()

    # L1
    r = subprocess.run([sys.executable, "-I", os.path.join(HERE, "hitsensor_gen.py"), "--check", "--bd", a.bd, "--xmve", a.xmve],
                       capture_output=True, text=True)
    if r.returncode != 0:
        fail("L1", "hitsensor_cards.zs is stale or hand-edited: rerun tools/hitsensor_gen.py (%s)" % r.stdout.strip())

    # the cards as written
    def arr(fn):
        m = re.search(r"static \w+ %s\(int i\) \{ static const \w+ V\[\] = \{ (.*?) \};" % fn, cards_text)
        return [x.strip().strip('"') for x in m.group(1).split(",")] if m else []
    names = [n.lower() for n in arr("NameAt")]
    kinds, lives = [int(x) for x in arr("KindAt")], [int(x) for x in arr("LifeAt")]
    radii, heights = [float(x) for x in arr("RadiusAt")], [float(x) for x in arr("HeightAt")]
    healths = [int(x) for x in arr("HealthAt")]
    if not names or not (len(names) == len(kinds) == len(lives) == len(radii) == len(heights) == len(healths)):
        fail("L1", "the card arrays are missing or of different lengths")
    for i, n in enumerate(names):
        if not re.search(r"class RS_ScoreHitDecl_%s : RS_ScoreHitDecl \{ override int Card\(\) \{ return %d; \} \}" % (re.escape(arr("NameAt")[i]), i), cards_text):
            fail("L1", "no declaration class with row %d for %s" % (i, n))

    # L2
    spawned = dec.spawned_helper_names(a.xmve)
    for n in sorted(spawned):
        if n not in names:
            fail("L2", "XMVE spawns %s (%d calls) but it has no card: it stays a blockmap helper" % (n, spawned[n]))
    for n in names:
        if n in other or not dec.HELPER_NAME.match(n):
            fail("L2", "%s is carded but is not a per-frame helper" % n)
        if n not in actors:
            fail("L2", "%s is carded but no DECORATE defines it" % n)

    # L3
    roots = {1: dec.HEAD_ROOT, 2: dec.LEG_ROOT}
    for i, n in enumerate(names):
        if n not in actors:
            continue
        root = roots.get(kinds[i] if i < len(kinds) else 0)
        if not root or root not in dec.chain(actors, n):
            fail("L3", "%s: kind %s does not match its root" % (n, kinds[i] if i < len(kinds) else "?"))
            continue
        props, factors, flags, life, loops = dec.resolved(actors, n)
        rprops, rfactors, rflags, _, _ = dec.resolved(actors, root)
        if factors != rfactors:
            fail("L3", "%s changes its root's damage factors: %s" % (n, sorted(set(factors.items()) ^ set(rfactors.items()))))
        df = {k for k in set(flags) | set(rflags) if flags.get(k) != rflags.get(k)} - FLAG_OK
        if df:
            fail("L3", "%s changes its root's flags: %s" % (n, sorted(df)))
        for k in dec.chain(actors, n):
            if k == root:
                break
            extra = set(actors[k].props) - OWN_OK
            if extra:
                fail("L3", "%s sets %s itself (the sensor would not carry it)" % (actors[k].name, sorted(extra)))
        if life != lives[i] or loops:
            fail("L3", "%s: Spawn life %s, card %d" % (n, life, lives[i]))
        if float(props.get("radius", 0)) != radii[i] or float(props.get("height", 0)) != heights[i] or int(props.get("health", 0)) != healths[i]:
            fail("L3", "%s: box/health differ from its card" % n)

    # L4
    for cls, root in (("RS_ScoreHitSensorHead", dec.HEAD_ROOT), ("RS_ScoreHitSensorLeg", dec.LEG_ROOT)):
        body = zs_class(zs, cls)
        base = zs_class(zs, "RS_ScoreHitSensor")
        if not body:
            fail("L4", "no class %s in hitsensor.zs" % cls)
            continue
        p, f, fl = zs_default(body)
        bp, bf, bfl = zs_default(base)
        fl = dict(bfl, **fl)
        p = dict(bp, **p)
        rprops, rfactors, rflags, _, _ = dec.resolved(actors, root)
        if f != rfactors:
            fail("L4", "%s factors differ from %s: %s" % (cls, root, sorted(set(f.items()) ^ set(rfactors.items()))))
        for k in ("health", "radius", "height", "painchance", "mass", "gibhealth"):
            if k in rprops and float(re.sub(r"[^\d.\-]", "", rprops[k]) or 0) != float(re.sub(r"[^\d.\-]", "", p.get(k, "nan")) or "nan"):
                fail("L4", "%s %s %s, %s has %s" % (cls, k, p.get(k), root, rprops[k]))
        if p.get("damagetype", "").strip('"').lower() != rprops.get("damagetype", "").strip('"').lower():
            fail("L4", "%s DamageType %s, %s has %s" % (cls, p.get("damagetype"), root, rprops.get("damagetype")))
        for k, v in rflags.items():
            if k in IGNORED_FLAGS:
                continue
            if fl.get(k, None) != v and not (v is False and k not in fl):
                fail("L4", "%s flag %s%s missing" % (cls, "+" if v else "-", k))
        for k, v in fl.items():
            if k not in rflags and v:
                fail("L4", "%s sets +%s, which %s does not have" % (cls, k, root))

    # L5
    legdec = actors[dec.LEG_ROOT].states
    pain = re.search(r"(?is)^\s*Pain:\s*$(.*?)^\s*stop", legdec, re.M)
    jumps = re.findall(r'A_JumpIfHealthLower\((\d+),\s*"(\w+)"\)', pain.group(1)) if pain else []
    fall = re.findall(r"A_Explode\((\d+),\s*20", pain.group(1)) if pain else []

    def blast_of(label):
        m = re.search(r"(?is)^\s*%s:\s*$(.*?)\bstop\b" % re.escape(label), legdec, re.M)
        e = re.search(r"A_Explode\((\d+),\s*20", m.group(1)) if m else None
        return int(e.group(1)) if e else None
    want_below = [int(t) for t, _ in jumps]
    want_blast = [blast_of(lbl) for _, lbl in jumps]
    legbody = zs_class(zs, "RS_ScoreHitSensorLeg")
    mb = re.search(r"LadderBelow\(int i\) \{ static const int V\[\] = \{ ([^}]*) \}", legbody)
    ml = re.search(r"LadderBlast\(int i\) \{ static const int V\[\] = \{ ([^}]*) \}", legbody)
    have_below = ints(mb.group(1)) if mb else []
    have_blast = ints(ml.group(1)) if ml else []
    if not jumps or have_below != want_below or have_blast != want_blast:
        fail("L5", "leg ladder below %s blast %s; Leg.dec below %s blast %s" % (have_below, have_blast, want_below, want_blast))
    if re.search(r"LadderSize\(\) \{ return (\d+); \}", legbody) is None or int(re.search(r"LadderSize\(\) \{ return (\d+); \}", legbody).group(1)) != len(want_below):
        fail("L5", "LadderSize is not %d" % len(want_below))
    if not fall or "LegBlast(%s);\n\t\treturn Spend();" % fall[-1] not in legbody:
        fail("L5", "the fall-through blast is not Leg.dec's %s" % (fall[-1] if fall else "?"))
    for label, call in (("Death", "Death"), ("XDeath", "XDeath"), ("Pain350", "Pain.SSG")):
        v = blast_of(label)
        if v is None or not re.search(r"%s:[^\n]*\n\s*TNT1 A 0 \{ inPain = true; LegBlast\(%d\); \}" % (re.escape(call), v), legbody):
            fail("L5", "%s does not blast Leg.dec's %s" % (call, v))

    # L6
    headdec = actors[dec.HEAD_ROOT].states
    hp = re.search(r"(?is)^\s*Pain:\s*$(.*?)^\s*stop", headdec, re.M)
    hx = re.findall(r"A_Explode\(([^)]*)\)", hp.group(1)) if hp else []
    hj = [int(t) for t in re.findall(r"A_JumpIfHealthLower\((\d+)", hp.group(1))] if hp else []
    if not hx or [x.strip() for x in hx[-1].split(",")] != ["20", "15", "0", "0", "15"]:
        fail("L6", "Head_Sys.dec's fall-through blast changed: %s" % (hx[-1] if hx else "?"))
    if "A_Explode(20, 15, 0, false, 15);" not in zs_class(zs, "RS_ScoreHitSensorHead"):
        fail("L6", "the head sensor does not blast A_Explode(20, 15, 0, false, 15)")
    hhealth = int(dec.resolved(actors, dec.HEAD_ROOT)[0].get("health", "0"))
    if hj and hhealth - 9999 < max(hj):   # a blow under ~10,000 never reaches the ladder at this health
        fail("L6", "the head ladder is reachable at Health %d (thresholds up to %d): copy it" % (hhealth, max(hj)))

    # L7
    import zipfile
    with zipfile.ZipFile(a.xmve) as z:
        for n in z.namelist():
            if n.endswith("/"):
                continue
            t = dec.strip_comments(z.read(n).decode("latin-1"))
            for m in re.finditer(r'(?i)A_SpawnItemEx\s*\(\s*"((?:headshottarget|legtarget)\w*)"([^)]*)\)', t):
                if re.search(r"(?i)SXF_NOPOINTERS|SXF_TRANSFERPOINTERS", m.group(2)):
                    fail("L7", "%s: %s drops or swaps the target pointer" % (n, m.group(0)[:80]))

    if fails:
        print("hitsensor_lint: %d failure(s)" % len(fails))
        for f in fails:
            print("  " + f)
        return 1
    print("hitsensor_lint: ok (%d cards: %d head, %d leg; %d XMVE helper classes spawned, all carded; %d non-helpers left alone)"
          % (len(names), kinds.count(1), kinds.count(2), len(spawned), len(other)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
