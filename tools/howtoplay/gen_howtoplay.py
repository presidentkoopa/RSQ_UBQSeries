#!/usr/bin/env python3
"""The in-game How To Play and RSQoopaControls: write RSQ Controls' copy of the page, its tab data and its console script.

    python3 tools/howtoplay/gen_howtoplay.py            write every file
    python3 tools/howtoplay/gen_howtoplay.py --check    write nothing; exit 1 if a file is stale, Controls/ is not wired,
                                                        or a series mod still carries its own How To Play
    python3 tools/howtoplay/gen_howtoplay.py --report   also print each mod's rows: label, places, Show Me, key

The page lives in ONE mod, RSQ Controls (Controls/, RSQ_Controls.pk3; owner 2026-11-27 11:3x), since 2026-11-27.
It still reads every series mod's README.md (the "How to play" table under <a name="how-to-play">: Do this | What
happens | Needs, and the Keys table GEN:keys) and its MENUDEF's Control rows, and writes (design/HOWTOPLAY_BUILD.md):
    Controls/zscript/rsqct/howto.zs        the page, from tools/howtoplay/howto_template.zs, @P@ -> RSQCT
    Controls/zscript/rsqct/howto_data.zs   every mod's tab (name, colour, the class that is there when it is loaded,
                                           rows), RSQ Score's tab baked from Score's glossary_data.zs, and the
                                           CONTROLS tab's panels (GENERATED: never edit by hand)
    Controls/RSQoopaControls.cfg           the ini as console commands (controls_cfg)
The template's "// @STDCONTROLS@" line becomes the "Use RSQoopaControls" row's bind lists, its CVar list and the
layout's id (the first-launch screen asks again when it changes), from design/controls/rsq_standard_controls.ini.
The CONTROLS tab's plain words are the picture's: WORD, LEFT and RIGHT in design/readme_art/make_controls_table.py,
read (not run, not edited) from that file, so the picture and the game say the same thing.

Text: upper case, ASCII 32 to 96 only (RSQ Score's fonts have nothing else); "|" and "~" separate fields.
"""
import os
import re
import sys

HUB = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
TEMPLATE = os.path.join(HUB, "tools", "howtoplay", "howto_template.zs")
# RSQoopaControls, the series' controls (design/controls/CONTROLS.md): the "Use RSQoopaControls" row writes every line
# of it. Its three lists in the template (the line "// @STDCONTROLS@") are generated from this file, never typed.
CONTROLS_INI = os.path.join(HUB, "design", "controls", "rsq_standard_controls.ini")
# RSQ Controls: the one mod that carries the page, the Options rows and the first-launch screen
CTL_FOLDER, CTL_PREFIX, CTL_ZSDIR = "Controls", "RSQCT", "Controls/zscript/rsqct"
CTL_ZROOT, CTL_MENUDEF, CTL_MAPINFO = "Controls/zscript.txt", "Controls/MENUDEF.txt", "Controls/MAPINFO.txt"
# the same lines as a console script (controls_cfg). Not in the pk3: exec reads a file on disk only (gzdoom qzd17.3
# src/common/console/c_dispatch.cpp:1019-1029, FileReader::OpenFile on the path), so build.sh copies it beside the pk3.
CONTROLS_CFG = os.path.join("Controls", "RSQoopaControls.cfg")
# the picture's words: WORD (command -> plain words), LEFT / RIGHT (the rows, by key) in this file, read with ast
PICTURE = os.path.join(HUB, "design", "readme_art", "make_controls_table.py")
CONTROLS_SECTIONS = ("Doom.Bindings", "Doom.DoubleBindings", "CVars")
# [CVars]: name=value; a name as the engine's console takes one (letters, digits, "_"), a value that is not empty
CVAR_NAME = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")
STD_MARK = "\t// @STDCONTROLS@"

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
    # RSQ Monsters (added 2026-11-27, once its README was read from code; it was left out only because it had not been):
    # no event handler of its own prefix, so its probe is its first MAPINFO handler (RS_RetierHandler)
    ("Monsters", "RSQMN", "Monsters/zscript/monsters", "", "Monsters/zscript.txt", "Monsters/MENUDEF.txt", "Monsters/MAPINFO.txt", 19, 3),
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

# Rows left out of the tabs (their README rows stay): typed in the console (no console in a headset) and a test hook.
def excluded(do, needs):
    d = do.lower()
    if re.match(r"type\b", d) and "console" in d:
        return "typed in the console"
    if d.startswith("on the rig"):
        return "a test hook"
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
    else:
        rows = glossary_rows()
    return dict(mod=mod, name=name, tab=tab, rows=rows, report=report, left_out=left_out, probe=probe_of(mod))


# RSQ Score's tab is its Glossary: its six families are the tab's sections, its entries the rows. Baked here from
# Score's own glossary_data.zs (Score/tools/gen_glossary.py writes it), as RSQSC_GlossaryMenu.Build / Add / ShortOf read
# it (Score/zscript/rsscore/glossary.zs:58-75): RSQ Controls loads without Score, so it cannot call Score's code.
# --check fails when Score's Glossary changes and this copy is stale.
def glossary_rows():
    g = read("Score/zscript/rsscore/glossary.zs")
    fam = re.findall(r'"([^"]+)"', re.search(r"FAMNAME\[\]\s*=\s*\{([^}]*)\}", g).group(1))
    fcol = re.findall(r'"([^"]+)"', re.search(r"FAMCOLOR\[\]\s*=\s*\{([^}]*)\}", g).group(1))
    d = read("Score/zscript/rsscore/glossary_data.zs")
    q = r'"((?:[^"\\]|\\.)*)"'
    out, seen = [], 0
    for m in re.finditer(r"Add\((\d+), %s, %s, %s, %s\);" % (q, q, q, q), d):
        seen += 1
        f = min(max(int(m.group(1)), 0), len(fam) - 1)
        name, text, bonus, needs = [m.group(i).replace('\\"', '"').replace("\\\\", "\\") for i in range(2, 6)]
        mm = re.search(r"\+\d+", bonus)
        bare = lambda s: clean(s.replace("|", "/").replace("~", "-"))
        out.append("|".join([bare(fam[f]), fcol[f], bare(name), mm.group(0) if mm else "", "", "", bare(text),
                             "BONUS:~%s~NEEDS:~%s" % (bare(bonus), bare(needs))]))
    if seen != d.count("Add("):
        sys.exit("Score/zscript/rsscore/glossary_data.zs: %d Add( lines, %d read" % (d.count("Add("), seen))
    return out


# The class that is there when the mod is loaded, so the page can tell (a class name in a String is looked up when the
# page runs; null when no loaded pk3 declares it: gzdoom qzd17.3 src/common/scripting/backend/codegen.cpp:12329-12376
# FxClassTypeCast, NativeNameToClass :12378-12392). The mod's first MAPINFO event handler named with its own prefix,
# else its first one; --check fails when no file of the mod declares it.
def probe_of(mod):
    folder, prefix, zsdir, stem, zroot, menudef, mapinfo, rank, group = mod
    names = []
    for m in re.finditer(r"AddEventHandlers\s*=\s*([^\n}]*)", strip_cmt(read(mapinfo)), re.I):
        names += re.findall(r'"([^"]+)"', m.group(1))
    names = [n for n in names if not n.endswith("_HowToStart")]
    if not names:
        sys.exit("%s: no event handler to tell the mod is loaded" % mapinfo)
    own = [n for n in names if n.lower().startswith(prefix.lower() + "_")]
    return (own or names)[0]


def strip_cmt(t):
    return "\n".join(l.split("//")[0] for l in t.splitlines())


def declares(folder, cls):
    rx = re.compile(r"^\s*class\s+%s\b" % re.escape(cls), re.I | re.M)
    for root, dirs, files in os.walk(os.path.join(HUB, folder)):
        for fn in files:
            if fn.lower().endswith((".zs", ".zsc", ".txt")) and not fn.endswith("howto.zs") and not fn.endswith("howto_data.zs"):
                with open(os.path.join(root, fn), encoding="utf-8", errors="replace") as f:
                    if rx.search(f.read()):
                        return True
    return False


# ---------------------------------------------------------------------------------------------------- THE CONTROLS TAB
# RSQoopaControls drawn as design/readme_art/screens/keys_buttons.png draws it (owner 11:33): two panels, each row
# BUTTON | PRESS | DOUBLE PRESS | RIGHT GRIP + PRESS, in the picture's own words. WORD, LEFT and RIGHT are read from the
# picture's script with ast (literals only; the script is neither run nor edited), its cell() rule repeated: a key's
# command through WORD ('' -> '-'), None -> '-', '#TEXT' -> TEXT.
def picture_tables():
    import ast
    src = open(PICTURE, encoding="utf-8").read()
    got = {}
    for node in ast.parse(src).body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            if node.targets[0].id in ("WORD", "LEFT", "RIGHT"):
                got[node.targets[0].id] = ast.literal_eval(node.value)
    for k in ("WORD", "LEFT", "RIGHT"):
        if k not in got:
            sys.exit("%s: no %s = <literal>" % (os.path.relpath(PICTURE, HUB), k))
    return got["WORD"], got["LEFT"], got["RIGHT"]


def controls_panels():
    c = standard_controls()
    B, D = dict(c["Doom.Bindings"]), dict(c["Doom.DoubleBindings"])
    WORD, LEFT, RIGHT = picture_tables()
    def cell(k, d):
        if k is None:
            return "-"
        if k.startswith("#"):
            return k[1:]
        cmd = d.get(k, "")
        if cmd not in WORD:
            sys.exit("%s: no WORD for %r (%s); the picture and the page need its plain words"
                     % (os.path.relpath(PICTURE, HUB), cmd, k))
        return WORD[cmd]
    used = set()
    def panel(rows):
        out = []
        for b, p, dd, m in rows:
            used.update(x for x in (p, dd, m) if x and not x.startswith("#"))
            out.append("|".join(clean(v) for v in (b, cell(p, B), cell(dd, D), cell(m, B))))
        return out
    off, main = panel(LEFT), panel(RIGHT)
    # every line of the ini with a command is on a panel (the left stick's four walk keys are its "MOVE" row)
    walk = {"Axis1Plus", "Axis1Minus", "Axis2Plus", "Axis2Minus"}
    for sec in ("Doom.Bindings", "Doom.DoubleBindings"):
        for k, cmd in c[sec]:
            if cmd and k not in used and not (sec == "Doom.Bindings" and k in walk):
                sys.exit("%s: [%s] %s=%s is on neither panel of %s" % (os.path.relpath(CONTROLS_INI, HUB), sec, k, cmd,
                                                                   os.path.relpath(PICTURE, HUB)))
    if any("FREE" in r for r in off + main):
        sys.exit("the panels say FREE: the owner (11:33) wants a dash for an empty slot")
    return off, main


def data_file(builds):
    off, main = controls_panels()
    label = menu_label()
    L = []
    L.append("// GENERATED by tools/howtoplay/gen_howtoplay.py from every series mod's README.md, Score's glossary_data.zs,")
    L.append("// design/controls/rsq_standard_controls.ini and design/readme_art/make_controls_table.py: do not edit, re-run it.")
    L.append("// Every tab of the series' How To Play (howto.zs, design/HOWTOPLAY_BUILD.md), carried by RSQ Controls alone.")
    L.append("// A row: section|colour|label|value|places|demo|paragraph|label~text~label~text...")
    L.append("")
    L.append("class %s_HowToData ui" % CTL_PREFIX)
    L.append("{")
    L.append("\t// one tab per series mod, in the Options menu's order (tools/rsmenu Rank); a tab shows when its PROBE class exists")
    L.append("\tconst NMODS = %d;" % len(builds))
    for nm, key in (("PROBE", "probe"), ("TAB", "tab"), ("MODNAME", "name")):
        vals = [b[key] if key == "probe" else clean(b[key]) for b in builds]
        L.append("\tstatic const String %s[] = { %s };" % (nm, ", ".join(zstr(v) for v in vals)))
    cols = ["RSScore_Gold" if b["mod"][0] == "Score" else GROUP_COLOUR[b["mod"][8]] for b in builds]
    L.append("\tstatic const String COLOUR[] = { %s };" % ", ".join(zstr(v) for v in cols))
    L.append("")
    L.append("\t// THE CONTROLS TAB: RSQoopaControls, BUTTON|PRESS|DOUBLE PRESS|RIGHT GRIP + PRESS, the picture's words")
    L.append("\tconst CTL_NOFF = %d;" % len(off))
    L.append("\tconst CTL_NMAIN = %d;" % len(main))
    for nm, rows in (("CTL_OFF", off), ("CTL_MAIN", main)):
        L.append("\tstatic const String %s[] =" % nm)
        L.append("\t{")
        for i, r in enumerate(rows):
            L.append("\t\t%s%s" % (zstr(r), "," if i < len(rows) - 1 else ""))
        L.append("\t};")
    L.append("\tconst CTL_NOTE = %s;" % zstr(clean("Options > Radiant Silvergun Options > %s sets these. Switch back to your own there." % label)))
    L.append("\tconst CTL_NOTE2 = %s;" % zstr(clean(crouch_words())))
    L.append("")
    L.append("\tstatic void Rows(int m, out Array<String> r)")
    L.append("\t{")
    L.append("\t\tswitch (m)")
    L.append("\t\t{")
    for i, b in enumerate(builds):
        L.append("\t\tcase %d: Rows%s(r); break;" % (i, b["mod"][0]))
    L.append("\t\t}")
    L.append("\t}")
    for b in builds:
        L.append("")
        L.append("\t// %s (%s/README.md%s)" % (b["name"], b["mod"][0],
                 "; its Glossary, Score/zscript/rsscore/glossary_data.zs" if b["mod"][0] == "Score" else ""))
        L.append("\tstatic void Rows%s(out Array<String> r)" % b["mod"][0])
        L.append("\t{")
        for r in b["rows"]:
            L.append("\t\tr.Push(%s);" % zstr(r))
        L.append("\t}")
    L.append("}")
    return "\n".join(L) + "\n"


def standard_controls():
    """{section: [(key, command)]} from rsq_standard_controls.ini, in the file's order. '#' or ';' starts a comment line
    (as the engine's config reader). Stops on a line outside the three sections, a line without '=', a key twice in one
    section, or a '"' (the lists are ZScript strings); in [CVars] also on a name that is not a CVar name or an empty
    value."""
    out = {s: [] for s in CONTROLS_SECTIONS}
    sec = None
    with open(CONTROLS_INI, encoding="utf-8") as f:
        for n, raw in enumerate(f, 1):
            line = raw.strip()
            if not line or line[0] in "#;":
                continue
            where = "%s:%d" % (os.path.relpath(CONTROLS_INI, HUB), n)
            if line.startswith("[") and line.endswith("]"):
                sec = line[1:-1]
                if sec not in out:
                    sys.exit("%s: section [%s] is not one of %s" % (where, sec, ", ".join(CONTROLS_SECTIONS)))
                continue
            if sec is None:
                sys.exit("%s: a line before any section" % where)
            if "=" not in line or line.index("=") == 0:
                sys.exit("%s: not Key=command: %r" % (where, line))
            key, cmd = line.split("=", 1)
            key, cmd = key.strip(), cmd.strip()
            if '"' in key or '"' in cmd or "\\" in key or "\\" in cmd:
                sys.exit("%s: a quote or backslash: %r" % (where, line))
            if any(k.lower() == key.lower() for k, c in out[sec]):
                sys.exit("%s: %s twice in [%s]" % (where, key, sec))
            if sec == "CVars":
                if not CVAR_NAME.match(key):
                    sys.exit("%s: not a CVar name: %r" % (where, key))
                if not cmd:
                    sys.exit("%s: no value for %s" % (where, key))
            out[sec].append((key, cmd))
    if not out["Doom.Bindings"]:
        sys.exit("%s: no [Doom.Bindings] lines" % os.path.relpath(CONTROLS_INI, HUB))
    return out


def menu_label():
    """the Options row's name, as the template has it (const LABEL in OptionMenuItem@P@StdControls)"""
    with open(TEMPLATE, encoding="utf-8") as f:
        m = re.search(r'class OptionMenuItem@P@StdControls\b.*?const LABEL = "([^"]+)";', f.read(), re.S)
    if not m:
        sys.exit("%s: no const LABEL in OptionMenuItem@P@StdControls" % TEMPLATE)
    return m.group(1)


def crouch_words():
    """The CONTROLS tab's second line and the first-launch screen say "natural crouch on", so the ini's [CVars] must be
    that one line; anything else stops here until the words change with it."""
    c = standard_controls()
    if c["CVars"] != [("vr_crouch_use_button", "false")]:
        sys.exit("%s: [CVars] is not just vr_crouch_use_button=false; the page says only \"natural crouch on\": "
                 "change crouch_words with the ini" % os.path.relpath(CONTROLS_INI, HUB))
    return "It also turns natural crouch on: you crouch by crouching."


def layout_id(c):
    """the layout's id: a CRC-32 of its lines (not its comments), 1 to 2^31-1. The first-launch screen asks once per id,
    so any change to a bind, a double bind or a CVar line asks once more."""
    import zlib
    text = "\n".join("[%s]\n" % s + "\n".join("%s=%s" % kv for kv in c[s]) for s in CONTROLS_SECTIONS)
    return (zlib.crc32(text.encode("utf-8")) & 0x7FFFFFFF) or 1


def standard_controls_block():
    c = standard_controls()
    crouch_words()
    L = ["\t// GENERATED by tools/howtoplay/gen_howtoplay.py from design/controls/rsq_standard_controls.ini: do not edit,",
         "\t// change the ini and re-run it. Each line as the ini has it: Key=command (nothing after \"=\": that button emptied);",
         "\t// in CVARS name=value. LAYOUT_ID: these lines' id (layout_id); the first-launch screen asks once per id.",
         "\tconst LAYOUT_ID = %d;" % layout_id(c)]
    for name, sec in (("BINDS", "Doom.Bindings"), ("DOUBLEBINDS", "Doom.DoubleBindings"), ("CVARS", "CVars")):
        L.append("\tstatic const String %s[] =    // [%s]" % (name, sec))
        L.append("\t{")
        rows = c[sec]
        if not rows:
            # ZScript has no empty array constant: an empty section is a list with one empty line, which Write skips
            rows = [("", "")]
        for i, (k, cmd) in enumerate(rows):
            L.append("\t\t%s%s" % (zstr(k + "=" + cmd), "," if i < len(rows) - 1 else ""))
        L.append("\t};")
    return "\n".join(L)


def controls_cfg():
    """Controls/RSQoopaControls.cfg: every ini line as the console command that does the same, in the ini's order.
    The commands (gzdoom qzd17.3): bind / doublebind src/common/console/c_bind.cpp:610-618 (FKeyBindings::PerformBind
    :376, the key by the engine's names, GetKeyFromName :172-191), unbind / undoublebind :580-594 (UnbindKey
    :355-369), set src/common/console/c_cvars.cpp:1615-1630 (CmdSet :1596-1613; "true" / "false" for a Bool, ToBool
    :308-333), exec src/common/console/c_enginecmds.cpp:94-107. An exec'd file: "//" starts a comment, "#" does not
    (src/common/console/c_dispatch.cpp C_ParseExecFile :1019-1069)."""
    c = standard_controls()
    ini = os.path.relpath(CONTROLS_INI, HUB).replace(os.sep, "/")
    L = [
        "// RSQoopaControls: the RSQ UBQ Series controller layout for QuestZDoom 17.3 (the owner's, 2026-11-27).",
        "// GENERATED by tools/howtoplay/gen_howtoplay.py from %s: do not edit; change the ini" % ini,
        "// and re-run it. Every ini line in its order: [Doom.Bindings] as bind (a line with nothing after \"=\": unbind),",
        "// [Doom.DoubleBindings] as doublebind (nothing: undoublebind), [CVars] as set. No other key or setting is touched.",
        "// RSQ_Controls.pk3 offers the same lines from inside the game, no file needed: once on its first launch, and",
        "// any time at Options > Radiant Silvergun Options > %s." % menu_label(),
        "// Where each command comes from and what each button does: design/controls/CONTROLS.md.",
        "//",
        "// HOW TO USE IT. This file ships beside RSQ_Controls.pk3, not in it (exec reads a file on disk). Put it in the",
        "// folder QuestZDoom starts in: /sdcard/QuestZDoom on the Quest (questzdoom",
        "// QzDoom_OpenXR.cpp:249 chdir), the engine's folder on PC. Then, from the console:",
        "//     exec RSQoopaControls.cfg",
        "// Once is enough: the engine saves its binds and settings in its ini when it closes (gameconfigfile.cpp:968-978).",
        "// On a QuestZDoom command line (commandline.txt, or a profile's commandline_<name>.txt) add, exactly so:",
        "//     +wait 1;exec RSQoopaControls.cfg",
        "// -exec RSQoopaControls.cfg or +exec RSQoopaControls.cfg alone also run it, but too early: the engine runs the",
        "// command line's files and commands (d_main.cpp:3349-3354) and then reads its saved binds, clearing every bind first",
        "// (d_main.cpp:3356 DoKeySetup; gameconfigfile.cpp:806-836; c_bind.cpp:818-822), so the bind lines are lost.",
        "// \"wait 1;\" holds the exec back until the engine has read them (c_dispatch.cpp:355-385 wait, :70-85; run at",
        "// d_main.cpp:3594 and g_game.cpp:1430). Paths: gzdoom tag qzd17.3 src/ (src/common/console/ for c_*.cpp).",
        "// Not run in an engine yet.",
    ]
    for sec, cmd_on, cmd_off in (("Doom.Bindings", "bind", "unbind"), ("Doom.DoubleBindings", "doublebind", "undoublebind")):
        L.append("// [%s]" % sec)
        for k, cmd in c[sec]:
            L.append("%s %s \"%s\"" % (cmd_on, k, cmd) if cmd else "%s %s" % (cmd_off, k))
    L.append("// [CVars]")
    for k, v in c["CVars"]:
        L.append("set %s %s" % (k, v))
    return "\n".join(L) + "\n"


def template_copy(prefix):
    with open(TEMPLATE, encoding="utf-8") as f:
        t = f.read()
    if t.count(STD_MARK + "\n") != 1:
        sys.exit("%s: the line %r must be there once" % (TEMPLATE, STD_MARK.strip()))
    return t.replace(STD_MARK, standard_controls_block()).replace("@P@", prefix)


def targets(builds):
    return [(os.path.join(CTL_ZSDIR, "howto.zs"), template_copy(CTL_PREFIX)),
            (os.path.join(CTL_ZSDIR, "howto_data.zs"), data_file(builds)),
            (CONTROLS_CFG, controls_cfg())]


def controls_wiring():
    """the hand-made lines RSQ Controls needs: the includes, the menus, the handlers"""
    bad = []
    z = read(CTL_ZROOT)
    for f in ("howto.zs", "howto_data.zs"):
        if not re.search(r'#include\s+"zscript/rsqct/' + re.escape(f) + '"', z):
            bad.append("%s: no #include of zscript/rsqct/%s" % (CTL_ZROOT, f))
    m = read(CTL_MENUDEF)
    p = CTL_PREFIX
    for rx, what in ((r'ListMenu\s+"ReadThisMenu"\s*\{\s*Class\s+"%s_HowToMenu"' % p, 'ListMenu "ReadThisMenu"'),
                     (r'ListMenu\s+"%s_HowTo"\s*\{\s*Class\s+"%s_HowToMenu"' % (p, p), 'ListMenu "%s_HowTo"' % p),
                     (r'%sHowToLink\s+"How To Play"\s*,\s*"%s_HowTo"' % (p, p), '%sHowToLink "How To Play"' % p),
                     (r'OptionMenu\s+"%s_FirstRun"' % p, 'OptionMenu "%s_FirstRun"' % p),
                     (r'%sAnswer\s+"[^"]+"\s*,\s*1' % p, '%sAnswer ..., 1 (yes)' % p),
                     (r'%sAnswer\s+"[^"]+"\s*,\s*0' % p, '%sAnswer ..., 0 (no)' % p)):
        if not re.search(rx, m):
            bad.append("%s: no %s" % (CTL_MENUDEF, what))
    mi = read(CTL_MAPINFO)
    for h in ("%s_HowToStart" % p, "%s_FirstRun" % p):
        if '"%s"' % h not in mi:
            bad.append("%s: %s is not in AddEventHandlers" % (CTL_MAPINFO, h))
    cv = read("Controls/CVARINFO.txt")
    if not re.search(r"\brsqct_layout_asked\b", cv):
        bad.append("Controls/CVARINFO.txt: no rsqct_layout_asked")
    if not re.search(r"^\s*nosave\s+string\s+rsqct_own_controls\b", cv, re.M):
        bad.append("Controls/CVARINFO.txt: no nosave string rsqct_own_controls (the player's own controls)")
    return bad


def leftovers(b):
    """a series mod that still carries its own How To Play (the page is RSQ Controls' alone since 2026-11-27)"""
    folder, prefix, zsdir, stem, zroot, menudef, mapinfo, rank, group = b["mod"]
    bad = []
    for f in ("howto.zs", "howto_data.zs"):
        if os.path.exists(os.path.join(HUB, zsdir, stem + f)):
            bad.append("%s/%s%s still there" % (zsdir, stem, f))
        if re.search(r'#include\s+"[^"]*' + re.escape(stem + f) + '"', read(zroot)):
            bad.append("%s: still includes %s%s" % (zroot, stem, f))
    m = strip_cmt(read(menudef))
    if re.search(r'"ReadThisMenu"|%s_HowTo\b|%sHowToLink' % (prefix, prefix), m):
        bad.append("%s: still has a How To Play menu or row" % menudef)
    if "%s_HowToStart" % prefix in strip_cmt(read(mapinfo)):
        bad.append("%s: still adds %s_HowToStart" % (mapinfo, prefix))
    if not declares(folder, b["probe"]):
        bad.append("%s: no file declares %s (its tab's PROBE)" % (folder, b["probe"]))
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
    for path, text in targets(builds):
        full = os.path.join(HUB, path)
        old = open(full, encoding="utf-8").read() if os.path.exists(full) else None
        if old != text:
            stale.append(path)
            if not check:
                os.makedirs(os.path.dirname(full), exist_ok=True)
                with open(full, "w", encoding="utf-8", newline="\n") as f:
                    f.write(text)
    problems += controls_wiring()
    for b in builds:
        problems += leftovers(b)
        total += len(b["rows"])
        if report:
            print("== %s (%s): tab %r, %d rows, probe %s" % (b["mod"][0], b["mod"][1], b["tab"], len(b["rows"]), b["probe"]))
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
