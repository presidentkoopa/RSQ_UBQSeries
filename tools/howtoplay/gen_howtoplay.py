#!/usr/bin/env python3
"""The in-game How To Play: write every series mod's tab data and its copy of the shared page.

    python3 tools/howtoplay/gen_howtoplay.py            write every file
    python3 tools/howtoplay/gen_howtoplay.py --check    write nothing; exit 1 if a file is stale or a mod is not wired
    python3 tools/howtoplay/gen_howtoplay.py --report   also print each mod's rows: label, places, Show Me, key

Reads each mod's README.md (the "How to play" table under <a name="how-to-play">: Do this | What happens | Needs, and
the Keys table GEN:keys) and its MENUDEF's Control rows. Writes, per mod (design/HOWTOPLAY_BUILD.md):
    <zsdir>/<file>howto.zs        the shared page, from tools/howtoplay/howto_template.zs, @P@ -> the mod's prefix
    <zsdir>/<file>howto_data.zs   its tab: name, rank, colour, rows (GENERATED: never edit by hand)
RSQ Score's tab is its Glossary: its data file builds the rows from Score's own glossary_data.zs at run time.

Text: upper case, ASCII 32 to 96 only (RSQ Score's fonts have nothing else); "|" and "~" separate fields.
"""
import os
import re
import sys

HUB = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
TEMPLATE = os.path.join(HUB, "tools", "howtoplay", "howto_template.zs")

# folder, prefix, zscript dir (files go here), file stem prefix, zscript root lump, MENUDEF, MAPINFO, rank, group
# rank: tools/rsmenu/rsmenu_template.zs Rank() (the Options order); group 0 Body, 1 Hands, 2 Reach, 3 Game
MODS = [
    ("TacticalRig", "RSQTR", "TacticalRig/zscript/rsqtr", "", "TacticalRig/zscript.txt", "TacticalRig/MENUDEF.txt", "TacticalRig/MAPINFO.txt", 0, 0),
    ("QuestSaber", "UBQS", "QuestSaber/zscript", "ubqs_", "QuestSaber/zscript.txt", "QuestSaber/MENUDEF", "QuestSaber/MAPINFO", 2, 1),
    ("ShieldSaw", "SSQ", "ShieldSaw/zscript/ssq", "", "ShieldSaw/zscript.txt", "ShieldSaw/MENUDEF.txt", "ShieldSaw/MAPINFO.txt", 3, 1),
    ("Melee", "RSQML", "Melee/zscript/rsqml", "", "Melee/zscript.txt", "Melee/MENUDEF.txt", "Melee/MAPINFO.txt", 4, 1),
    ("Whip", "RSQWP", "Whip/zscript/rsqwp", "", "Whip/zscript.txt", "Whip/MENUDEF.txt", "Whip/MAPINFO.txt", 5, 1),
    ("Grenade", "RSQGN", "Grenade/zscript/rsqgn", "", "Grenade/zscript.txt", "Grenade/MENUDEF.txt", "Grenade/MAPINFO.txt", 6, 1),
    ("FlashFlare", "RSQFF", "FlashFlare/zscript/rsqff", "", "FlashFlare/zscript.txt", "FlashFlare/MENUDEF.txt", "FlashFlare/MAPINFO.txt", 7, 1),
    ("Grapple", "RSQGR", "Grapple/zscript/rsqgr", "", "Grapple/zscript.txt", "Grapple/MENUDEF.txt", "Grapple/MAPINFO.txt", 8, 2),
    ("DistanceGrab", "RSQDG", "DistanceGrab/zscript/rsqdg", "", "DistanceGrab/zscript.txt", "DistanceGrab/MENUDEF.txt", "DistanceGrab/MAPINFO.txt", 9, 2),
    ("LaserSight", "RSQLS", "LaserSight/zscript/rsqls", "", "LaserSight/zscript.txt", "LaserSight/MENUDEF.txt", "LaserSight/MAPINFO.txt", 10, 2),
    ("SlowMo", "RSQSM", "SlowMo/zscript/rsqsm", "", "SlowMo/zscript.txt", "SlowMo/MENUDEF.txt", "SlowMo/MAPINFO.txt", 11, 3),
    ("Score", "RSQSC", "Score/zscript/rsscore", "", "Score/zscript.txt", "Score/MENUDEF.txt", "Score/MAPINFO.txt", 12, 3),
    ("Miniboss", "RSQMB", "Miniboss/zscript/rsqmb", "", "Miniboss/zscript.txt", "Miniboss/MENUDEF.txt", "Miniboss/MAPINFO.txt", 13, 3),
    ("VisualRewards", "RSQTHP", "VisualRewards/pk3/zscript/rsqthp", "", "VisualRewards/pk3/zscript.txt", "VisualRewards/pk3/MENUDEF.txt", "VisualRewards/pk3/MAPINFO.txt", 14, 3),
    ("GunCards", "RSQGC", "GunCards/zscript/rsqgc", "", "GunCards/zscript.txt", "GunCards/MENUDEF.txt", "GunCards/MAPINFO.txt", 15, 3),
    ("Wheel", "RSQWH", "Wheel/zscript/wheel", "", "Wheel/zscript.txt", "Wheel/MENUDEF.txt", "Wheel/MAPINFO.txt", 16, 3),
    ("GlowInTheDark", "RSQGD", "GlowInTheDark/zscript/rsqgd", "", "GlowInTheDark/zscript/rsqgd/rsqgd.zs", "GlowInTheDark/MENUDEF.txt", "GlowInTheDark/MAPINFO.txt", 17, 3),
    ("GunBonsaiOffhandVR", "RSQGBV", "GunBonsaiOffhandVR/rsq/zscript", "", "GunBonsaiOffhandVR/zscript.txt", "GunBonsaiOffhandVR/menudef.rsq", "GunBonsaiOffhandVR/mapinfo.rsq", 18, 3),
    ("Graveyard", "RSQGY", "Graveyard/zscript/rsqgy", "", "Graveyard/zscript.zs", "Graveyard/menudef.txt", "Graveyard/mapinfo.txt", 20, 3),
    ("PlayLog", "RSQPL", "PlayLog/zscript/rsqpl", "", "PlayLog/zscript.txt", "PlayLog/MENUDEF.txt", "PlayLog/MAPINFO.txt", 21, 3),
]
# the tab's colour: RSQ Score's text colours by Options group (the Glossary's family colours); the page falls back to the
# engine's own colours when Score is not loaded
GROUP_COLOUR = {0: "RSScore_Efficiency", 1: "RSScore_Daring", 2: "RSScore_Melee", 3: "RSScore_Style"}

# ---------------------------------------------------------------------------------------------------- SHOW ME
# A row of the Tactical Rig done at a place on the body gets a "Show Me" row: the Rig plays its ghost hand doing it
# (RSQTR_RigService "ghost.demo", ghost.zs). (mod, start of "Do this", demo name). --check fails if a key matches no row.
DEMOS = [
    ("TacticalRig", "Hold a gun in the main hand inside an empty holster", "holster"),
    ("TacticalRig", "Put the empty main hand in a full holster", "draw"),
    ("TacticalRig", "Squeeze the off hand's grip in a holster", "offdraw"),
    ("TacticalRig", "Squeeze either hand's grip, or press Use, at the belt buckle", "nade"),
    ("TacticalRig", "Squeeze the main hand's grip, or press Use, at the pocket", "cig"),
    ("TacticalRig", "Press Use with the cigarette at your lips", "mouth"),
    ("TacticalRig", "Hold both hands against your chest", "recenter"),
    ("TacticalRig", "Squeeze the main grip at the spot just below the main hand's hip", "saber"),
    ("TacticalRig", "Squeeze the off grip at the spot just below the off hand's hip", "offsaber"),
    ("TacticalRig", "Squeeze the grip of the whip's hand behind and outside", "whip"),
    ("TacticalRig", "Squeeze the off grip behind and outside the off hand's saber spot", "flare"),
    ("TacticalRig", "Squeeze the main grip at the keyring", "keyring"),
    ("TacticalRig", "Hold the watch check pose with a hand and press Use", "watch"),
    ("TacticalRig", "Squeeze the off grip at the off shoulder holster", "shield"),
    # the watch check and the pulse check as Gun Cards and Miniboss read them: the same ghost, asked by name
    ("GunCards", "Check your watch with either hand", "watch"),
    ("Miniboss", "Check your pulse", "pulse"),
]

# ---------------------------------------------------------------------------------------------------- THE BODY TAB
# Places (the flat figure): MOUTH, LSH / RSH (shoulders), CHEST, BELT, LHIP / RHIP, MAIN / OFF (each hand), BOTH.
# MSH / OSH / MHIP / OHIP are the main or off hand's side: the page turns them into L or R by handedness.
# A row's places come from words in its "Do this" (RULES, in order, every match counts); PLACE_FIX overrides a row
# (mod, start of "Do this") -> places ("" = none). --check fails if a PLACE_FIX key matches no row.
RULES = [
    (r"\b(mouth|lips|teeth)\b", "MOUTH"),
    (r"\boff shoulder\b|shoulder the shield is mounted|shield mounted on your shoulder", "OSH"),
    (r"\bshoulder holster\b|\bover a shoulder\b", "LSH RSH"),
    (r"\b(chest|breastbone)\b|\bthe pocket\b|\bflashlight clip\b|\bat the clip\b", "CHEST"),
    (r"\b(belt|buckle|grenade spot|keyring|ammo pouch)\b", "BELT"),
    (r"main hand's hip|main hand's saber spot", "MHIP"),
    (r"off hand's hip|off hand's saber spot", "OHIP"),
    (r"\byour hip\b|\ba hip\b", "LHIP RHIP"),
    (r"\bboth hands\b|\bhands together\b|\bcross your (hands|wrists)\b|\bboth palms\b|\bhands apart\b|\btwo lit blades\b|\bhands at your face\b|\bin both hands\b|\bwith both hands\b", "BOTH"),
    (r"\bcheck your watch\b|\bwatch check\b|\beither wrist\b", "MAIN OFF"),
    (r"\bcheck your pulse\b|\boff-hand wrist\b", "OFF"),
    (r"\boff hand\b|\boff arm\b|\boff palm\b|\boff grip\b|\boff primary fire\b|\boff hand's\b", "OFF"),
    (r"\bmain hand\b|\bmain primary fire\b|\bmain grip\b|\bmain hand's\b|\bmain saber's hand\b", "MAIN"),
]
PLACE_FIX = [
    # a holster at any place: every holster place
    ("TacticalRig", "Bring a hand near a holster", "LHIP RHIP CHEST LSH RSH"),
    ("TacticalRig", "Hold a gun in the main hand inside an empty holster", "LHIP RHIP CHEST LSH RSH MAIN"),
    ("TacticalRig", "Put the empty main hand in a full holster", "LHIP RHIP CHEST LSH RSH MAIN"),
    ("TacticalRig", "Squeeze the off hand's grip in a holster", "LHIP RHIP CHEST LSH RSH OFF"),
    ("TacticalRig", "Squeeze the main hand's grip, or press Use, at the pocket", "CHEST"),
    ("TacticalRig", "Squeeze the main grip at the pocket with the cigarette", "CHEST"),
    ("TacticalRig", "Look down at your belt", "BELT"),
    ("TacticalRig", "Press the off hand's fire with the Zippo away", "OFF"),
    ("TacticalRig", "Press the off hand's fire with the Zippo's flame", "MOUTH OFF"),
    ("TacticalRig", "Squeeze the grip of the whip's hand", "MHIP"),
    ("TacticalRig", "Squeeze the off grip behind and outside", "OHIP"),
    ("TacticalRig", "Squeeze the off grip at any place with a lit flare", "OFF"),
    ("TacticalRig", "Look at a holster with a gun in it", ""),
    ("TacticalRig", "Hold a gun in the main hand for 2 seconds", ""),
    ("TacticalRig", "Turn your head and both hands together", ""),
    ("TacticalRig", "Hold the watch check pose with a hand", "MAIN OFF"),
    ("TacticalRig", "Look down at yourself", ""),
    ("Wheel", "With the ring closed, bring a forearm up across your chest", "MAIN OFF"),
    ("Wheel", "Press the off hand's alt fire on a card", ""),
    ("Wheel", "Press the main hand's alt fire on a card", ""),
    ("FlashFlare", "Look down at your chest", "CHEST"),
    ("FlashFlare", "Press that grip while the engine is steadying", ""),
    ("FlashFlare", "Take another weapon into the off hand", ""),
    ("ShieldSaw", "Switch hands, or pick up something that goes to the off hand", ""),
    ("ShieldSaw", "Switch hands, or pick up a weapon that goes to the off hand", ""),
    ("ShieldSaw", "Press a key bound to Next or Previous Offhand Weapon", ""),
    ("ShieldSaw", "Squeeze the off hand's grip at the shoulder", "OSH OFF"),
    ("QuestSaber", "Leave the off hand empty", ""),
    ("QuestSaber", "Bring the saber into the main hand with the off hand empty", ""),
    ("QuestSaber", "Hold any weapon in the main hand with the off hand empty", ""),
    ("QuestSaber", "Look down at your hip", "LHIP RHIP"),
    ("GunCards", "Hold a gun in the main hand", ""),
    ("GunCards", "Hold a gun in the off hand", ""),
    ("GunCards", "Check your watch with an empty main hand", "MAIN"),
    ("GunCards", "Check your watch with an empty off hand", "OFF"),
    ("GunCards", "Check the off-hand watch while that hand steadies", "OFF"),
    ("GunCards", "Turn the back of either wrist", "MAIN OFF"),
    ("GunCards", "With a gun in the main hand, open Test and Debug", ""),
    ("GunCards", "Set Edit Spot For to Off Hand", ""),
    ("LaserSight", "Hold a gun in the main hand, or in the off hand", ""),
    ("LaserSight", "Steady the off hand's gun with both hands", "BOTH"),
    ("GunBonsaiOffhandVR", "Fire a bullet weapon from one hand", ""),
    ("Melee", "With a gun in the main hand, drive that hand", "MAIN"),
    ("Melee", "With the boxing gloves in the main hand", "BOTH"),
    ("Wheel", "Open the ring with Opens On set to Off Hand", ""),
    ("Grapple", "Press Fire Hook with Hook Hand set to Main Hand", ""),
    ("DistanceGrab", "Lay the other palm on a carried thing", "BOTH"),
    ("PlayLog", "Swing either hand faster than 1.0 m/s against your body", ""),
    ("PlayLog", "Bring the off hand within 0.8 m of your eyes", ""),
    ("Whip", "Get the whip into the hand Whip In does not name", ""),
    ("TacticalRig", "Squeeze the off grip at the off shoulder holster", "OSH OFF"),
    ("ShieldSaw", "In RSQ Wheel, press main secondary fire on the ShieldSaw's card, then primary fire on the off", ""),
    ("ShieldSaw", "Hold main primary fire with the shield in the off hand", "MAIN"),
    ("ShieldSaw", "With the shield in the off hand, flick the main hand's gun", "MAIN"),
    ("SlowMo", "Cross your hands in front of your face", "BOTH"),
    ("DistanceGrab", "Hold a gun in both hands", "BOTH"),
    ("FlashFlare", "Bring the off hand within 11 cm of the pocket", "CHEST OFF"),
    ("QuestSaber", "Hold jump with a saber in either hand", "MAIN OFF"),
    ("QuestSaber", "With the saber in the main hand and a fist in the off hand", "OFF"),
    ("QuestSaber", "With the second saber or the bare Force hand in the off hand", "MAIN"),
    # the watch check: Gun Cards' first row and the hand-specific ones; the rest stay on Gun Cards' tab only
    ("GunCards", "Check your watch with a hand that holds RSQ Saber's", ""),
    ("GunCards", "Check your watch with a hand that holds any other weapon", ""),
    ("GunCards", "Check your watch with a gun", ""),
    ("GunCards", "Hold a gun, or check your watch", ""),
]

# Rows left out of the tabs (their README rows stay): typed in the console (no console in a headset), a test hook, and
# rows that need RSQ Accessibility, which is being removed (owner 2026-11-27 08:10).
def excluded(do, needs):
    d = do.lower()
    if re.match(r"type\b", d) and "console" in d:
        return "typed in the console"
    if d.startswith("on the rig"):
        return "a test hook"
    if "rsq accessibility" in d:
        return "needs RSQ Accessibility (being removed)"
    n = needs.lower()
    if "rsq accessibility" in n and " or " not in n:
        return "needs RSQ Accessibility (being removed)"
    return ""


# ---------------------------------------------------------------------------------------------------- reading
def read(path):
    with open(os.path.join(HUB, path), encoding="utf-8", errors="replace") as f:
        return f.read()


def cells(line):
    line = line.strip()
    if line.startswith("|"):
        line = line[1:]
    if line.endswith("|"):
        line = line[:-1]
    out, cur, tick = [], "", False
    for ch in line:
        if ch == "`":
            tick = not tick
        if ch == "|" and not tick:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    out.append(cur.strip())
    return out


def how_rows(folder):
    t = read(folder + "/README.md")
    i = t.find('<a name="how-to-play">')
    if i < 0:
        return []
    s = t[i:]
    h = s.find("## How to play")
    e = s.find("\n## ", h + 5)
    s = s[:e] if e > 0 else s
    rows = []
    for l in s.splitlines():
        if not l.startswith("|") or l.startswith("|---") or l.startswith("| Do this"):
            continue
        c = cells(l)
        while len(c) < 3:
            c.append("")
        rows.append(c[:3])
    return rows


def keys_of(folder, menudef):
    """[(label, command)] from the README's Keys table and the MENUDEF's Control rows"""
    out = []
    t = read(folder + "/README.md")
    m = re.search(r"<!-- GEN:keys -->(.*?)<!-- /GEN:keys -->", t, re.S)
    if m:
        for l in m.group(1).splitlines():
            if l.startswith("| ") and not l.startswith("| Key") and not l.startswith("|---"):
                c = cells(l)
                if len(c) >= 3:
                    out.append((c[0], c[2].strip("`")))
    if menudef and os.path.exists(os.path.join(HUB, menudef)):
        for l in read(menudef).splitlines():
            m = re.match(r'\s*Control\s+"([^"]+)"\s*,\s*"([^"]+)"', l)
            if m:
                out.append((m.group(1), m.group(2)))
    return out


def menu_name(menudef):
    t = read(menudef)
    m = re.search(r'AddOptionMenu\s+"RSQ_RSOptions"\s*\{\s*Submenu\s+"([^"]+)"', t)
    if m:
        return m.group(1)
    m = re.search(r'AddOptionMenu\s+"OptionsMenu"\s*\{\s*Submenu\s+"([^"]+)"', t)
    return m.group(1) if m else ""


# ---------------------------------------------------------------------------------------------------- text
def clean(s):
    s = s.replace("**", "").replace("`", "")
    for a, b in (("–", "-"), ("—", "-"), ("’", "'"), ("‘", "'"), ("“", '"'), ("”", '"'),
                 ("×", "x"), ("°", " DEGREES"), ("≤", "<="), ("≥", ">=")):
        s = s.replace(a, b)
    s = s.upper()
    s = "".join(ch for ch in s if 32 <= ord(ch) <= 96)
    return re.sub(r"\s+", " ", s).strip()


def label_of(do):
    """The list's short name: the README's own "Do this", its brackets taken out; a "Name: how" row is cut to its
    name. The page narrows a long one to fit."""
    s = do
    prev = None
    while prev != s:
        prev = s
        s = re.sub(r"\s*\([^()]*\)", "", s)
    s = re.sub(r"\s+", " ", s).strip()
    if len(s) > 40:
        m = re.match(r"([^:]{8,40}):\s", s)
        if m and not re.match(r"(with|while|in|on)\b", m.group(1), re.I):
            s = m.group(1)
    return s


def needs_items(needs):
    out = []
    for part in re.split(r"[;,]", needs):
        part = re.sub(r"\s*\((default|both default|defaults)[^)]*\)", "", part).strip()
        if part:
            out.append(part)
    return out


def told_apart(pairs):
    """Rows of one tab with the same name: each gets " - " and the first setting from its Needs that the others do not
    share (the README's words), so the list does not show one name twice"""
    groups = {}
    for i, (lab, needs) in enumerate(pairs):
        groups.setdefault(lab.upper(), []).append(i)
    out = [lab for lab, needs in pairs]
    for key, idx in groups.items():
        if len(idx) < 2:
            continue
        items = [needs_items(pairs[i][1]) for i in idx]
        for i, its in zip(idx, items):
            others = [o for j, o in zip(idx, items) if j != i]
            pick = next((it for it in its if not all(it in o for o in others)), its[0] if its else "")
            if pick:
                out[i] = pairs[i][0] + " - " + pick
    return out


def zstr(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def places_of(mod, do):
    if mod == "GunCards" and do == "Check your watch":
        return []
    for m, start, pl in PLACE_FIX:
        if m == mod and do.startswith(start):
            return pl.split()
    d = do.lower()
    out = []
    for rx, pl in RULES:
        if re.search(rx, d):
            for p in pl.split():
                if p not in out:
                    out.append(p)
    # a place named for one hand's side: the hand that does it there is implied, not a separate place
    return out


def demo_of(mod, do):
    for m, start, name in DEMOS:
        if m == mod and do.startswith(start):
            return name
    return ""


def key_of(do, keys):
    d = do.lower()
    for label, cmd in keys:
        cands = {label, label.split(":")[0], re.sub(r"\s*\(.*\)", "", label), re.sub(r"\s+Key$", "", label)}
        for c in sorted(cands, key=len, reverse=True):
            c = c.strip().lower()
            if len(c) < 4:
                continue
            if re.search(r"\b(press|hold|bind|let go of)( the)? " + re.escape(c) + r"\b", d):
                return cmd
    return ""


# ---------------------------------------------------------------------------------------------------- building
def build(mod):
    folder, prefix, zsdir, stem, zroot, menudef, mapinfo, rank, group = mod
    name = menu_name(menudef)
    tab = re.sub(r"\s*\(.*\)", "", re.sub(r"^RSQ\s+", "", name)).strip()
    rows, report, left_out = [], [], []
    if folder != "Score":
        keys = keys_of(folder, menudef)
        kept = []
        for do, get, needs in how_rows(folder):
            why = excluded(do, needs)
            if why:
                left_out.append((do, why))
            else:
                kept.append((do, get, needs))
        labels = told_apart([(label_of(do), needs) for do, get, needs in kept])
        for (do, get, needs), lab in zip(kept, labels):
            pl = places_of(folder, do)
            dm = demo_of(folder, do)
            kc = key_of(do, keys)
            pairs = ["DO:", clean(do), "GET:", clean(get)]
            if needs.strip():
                pairs += ["NEEDS:", clean(needs)]
            fields = ["", "", clean(lab), ("KEY:" + kc) if kc else "", " ".join(pl), dm, "", "~".join(pairs)]
            rows.append("|".join(fields))
            report.append((lab, pl, dm, kc))
    return dict(mod=mod, name=name, tab=tab, rows=rows, report=report, left_out=left_out)


def data_file(b):
    folder, prefix, zsdir, stem, zroot, menudef, mapinfo, rank, group = b["mod"]
    colour = "RSScore_Gold" if folder == "Score" else GROUP_COLOUR[group]
    L = []
    L.append("// GENERATED by tools/howtoplay/gen_howtoplay.py from %s/README.md: do not edit, re-run it." % folder)
    L.append("// %s's tab in the series' How To Play (%showto.zs, design/HOWTOPLAY_BUILD.md)." % (b["name"], stem))
    if folder == "Score":
        L.append("// RSQ Score's tab IS its Glossary: its families are the tab's sections and its entries the rows, read at run")
        L.append("// time from glossary_data.zs (RSQSC_GlossaryMenu.Build, Score/tools/gen_glossary.py), so nothing is copied.")
    L.append("// A row: section|colour|label|value|places|demo|paragraph|label~text~label~text...")
    L.append("")
    L.append("class %s_HowToData ui" % prefix)
    L.append("{")
    L.append("\tconst NAME = %s;" % zstr(clean(b["name"])))
    L.append("\tconst TAB = %s;" % zstr(clean(b["tab"])))
    L.append("\tconst COLOUR = %s;" % zstr(colour))
    L.append("\tconst RANK = %d;" % rank)
    L.append("")
    L.append("\tstatic void Rows(out Array<String> r)")
    L.append("\t{")
    if folder == "Score":
        L.append("\t\tlet g = new(\"RSQSC_GlossaryMenu\");")
        L.append("\t\tg.Build();")
        L.append("\t\tfor (int i = 0; i < g.eFam.Size(); i++)")
        L.append("\t\t{")
        L.append("\t\t\tint f = clamp(g.eFam[i], 0, RSQSC_GlossaryMenu.NTABS - 1);")
        L.append("\t\t\tString pairs = \"BONUS:~\" .. Bare(g.eBonus[i]) .. \"~NEEDS:~\" .. Bare(g.eNeeds[i]);")
        L.append("\t\t\tr.Push(Bare(RSQSC_GlossaryMenu.FAMNAME[f]) .. \"|\" .. RSQSC_GlossaryMenu.FAMCOLOR[f] .. \"|\" .. Bare(g.eName[i]) .. \"|\""
                 " .. Bare(g.eShort[i]) .. \"|||\" .. Bare(g.eText[i]) .. \"|\" .. pairs);")
        L.append("\t\t}")
        L.append("\t}")
        L.append("")
        L.append("\t// the Glossary's own words, in the page's letters: no field separators, upper case")
        L.append("\tstatic String Bare(String s)")
        L.append("\t{")
        L.append("\t\ts.Replace(\"|\", \"/\");")
        L.append("\t\ts.Replace(\"~\", \"-\");")
        L.append("\t\treturn s.MakeUpper();")
        L.append("\t}")
    else:
        for r in b["rows"]:
            L.append("\t\tr.Push(%s);" % zstr(r))
        L.append("\t}")
    L.append("}")
    return "\n".join(L) + "\n"


def template_copy(prefix):
    with open(TEMPLATE, encoding="utf-8") as f:
        return f.read().replace("@P@", prefix)


def targets(b):
    folder, prefix, zsdir, stem, zroot, menudef, mapinfo, rank, group = b["mod"]
    return [(os.path.join(zsdir, stem + "howto.zs"), template_copy(prefix)),
            (os.path.join(zsdir, stem + "howto_data.zs"), data_file(b))]


def wiring_problems(b):
    """the hand-made lines every mod needs: the zscript includes, the menu rows, the start handler"""
    folder, prefix, zsdir, stem, zroot, menudef, mapinfo, rank, group = b["mod"]
    bad = []
    z = read(zroot)
    rel = os.path.relpath(os.path.join(zsdir, stem), os.path.dirname(zroot) if folder != "GlowInTheDark" else folder).replace(os.sep, "/")
    for f in ("howto.zs", "howto_data.zs"):
        if not re.search(r'#include\s+"[^"]*' + re.escape(stem + f) + '"', z):
            bad.append("%s: no #include of %s%s" % (zroot, stem, f))
    m = read(menudef)
    if not re.search(r'ListMenu\s+"ReadThisMenu"\s*\{\s*Class\s+"%s_HowToMenu"' % prefix, m):
        bad.append('%s: no ListMenu "ReadThisMenu" { Class "%s_HowToMenu" }' % (menudef, prefix))
    if not re.search(r'ListMenu\s+"%s_HowTo"\s*\{\s*Class\s+"%s_HowToMenu"' % (prefix, prefix), m):
        bad.append('%s: no ListMenu "%s_HowTo"' % (menudef, prefix))
    if not re.search(r'%sHowToLink\s+"How To Play"\s*,\s*"%s_HowTo"' % (prefix, prefix), m):
        bad.append('%s: no %sHowToLink "How To Play" row' % (menudef, prefix))
    mi = read(mapinfo)
    if '"%s_HowToStart"' % prefix not in mi:
        bad.append('%s: %s_HowToStart is not in AddEventHandlers' % (mapinfo, prefix))
    return bad


def main():
    check = "--check" in sys.argv
    report = "--report" in sys.argv
    if not os.path.exists(TEMPLATE):
        print("no template:", TEMPLATE)
        return 1
    stale, problems, total = [], [], 0
    builds = [build(m) for m in MODS]
    # every override still names a row
    for table, label in ((DEMOS, "DEMOS"), (PLACE_FIX, "PLACE_FIX")):
        for entry in table:
            mod, start = entry[0], entry[1]
            folder = [m for m in MODS if m[0] == mod]
            if not folder or not any(r[0].startswith(start) for r in how_rows(mod)):
                problems.append("%s: %s / %r matches no README row" % (label, mod, start))
    for b in builds:
        for path, text in targets(b):
            full = os.path.join(HUB, path)
            old = open(full, encoding="utf-8").read() if os.path.exists(full) else None
            if old != text:
                stale.append(path)
                if not check:
                    with open(full, "w", encoding="utf-8", newline="\n") as f:
                        f.write(text)
        problems += wiring_problems(b)
        total += len(b["rows"])
        if report:
            print("== %s (%s): tab %r, %d rows" % (b["mod"][0], b["mod"][1], b["tab"], len(b["rows"])))
            for lab, pl, dm, kc in b["report"]:
                print("   %-60s %-26s %-9s %s" % (lab[:60], " ".join(pl), dm, kc))
            for do, why in b["left_out"]:
                print("   LEFT OUT (%s): %s" % (why, do[:80]))
    for p in problems:
        print("WIRING:", p)
    if check:
        for s in stale:
            print("STALE:", s)
        print("%d mods, %d rows; %d stale file(s), %d wiring problem(s)" % (len(builds), total, len(stale), len(problems)))
        return 1 if stale or problems else 0
    print("%d mods, %d rows; wrote %d file(s); %d wiring problem(s)" % (len(builds), total, len(stale), len(problems)))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
