#!/usr/bin/env python3
"""Fill a mod README's generated tables from its own lumps (design/README_FROM_CODE.md).

    python3 tools/readme/gen_readme_tables.py <ModFolder> [--check]

Rewrites what lies between
    <!-- GEN:keys -->    ... <!-- /GEN:keys -->      from KEYCONF  (addmenukey, defaultbind)
    <!-- GEN:options --> ... <!-- /GEN:options -->   from MENUDEF  (each row and its "// tip:" comment)
                                                     and CVARINFO  (the default)
in <ModFolder>/README.md. Nothing else in the README is touched. --check writes nothing and exits 1 if the
README's tables differ from what the lumps say now (so a stale table is caught).

The first OptionMenu of the mod is its front page and is written as an open table; every further page goes in a
folded <details> block. The series' shared parent menu (RSQ_RSOptions) is skipped.
"""
import os
import re
import sys

BUILTIN_VALUES = {
    "onoff": {"0": "Off", "1": "On", "false": "Off", "true": "On"},
    "yesno": {"0": "No", "1": "Yes", "false": "No", "true": "Yes"},
    "offon": {"0": "On", "1": "Off", "false": "On", "true": "Off"},
    "noyes": {"0": "Yes", "1": "No", "false": "Yes", "true": "No"},
}
SLIDERS = ("slider", "scaleslider")
SKIP_MENUS = {"rsq_rsoptions", "optionsmenu"}


def find_lump(folder, stem):
    """Every lump of that name in the folder (a pk3 reads MENUDEF.txt and MENUDEF.ddz both); the plain one first."""
    found = [n for n in os.listdir(folder)
             if os.path.isfile(os.path.join(folder, n)) and n.lower().split(".")[0] == stem]
    if not found:
        return None
    found.sort(key=lambda n: (n.lower().split(".", 1)[-1] not in (stem, "txt"), n.lower()))
    paths = [os.path.join(folder, n) for n in found]
    return paths[0] if len(paths) == 1 else paths


def read(path):
    if isinstance(path, list):
        out = []
        for p in path:
            out += read(p)
        return out
    with open(path, encoding="utf-8", errors="replace") as f:
        return f.read().splitlines()


def tokens(line):
    """Split a MENUDEF / KEYCONF line into tokens; quoted strings are one token."""
    out = []
    for m in re.finditer(r'"((?:[^"\\]|\\.)*)"|([^\s,"]+)', line):
        out.append(m.group(1) if m.group(1) is not None else m.group(2))
    return out


def strip_comment(line):
    out, quote = [], False
    i = 0
    while i < len(line):
        c = line[i]
        if c == '"':
            quote = not quote
        if not quote and line[i:i + 2] == "//":
            break
        out.append(c)
        i += 1
    return "".join(out)


def parse_cvarinfo(path):
    """name -> (type, default text)"""
    cvars = {}
    if not path:
        return cvars
    for raw in read(path):
        for stmt in strip_comment(raw).split(";"):
            m = re.match(r'\s*(?:(?:server|user|nosave|noarchive|cheat|latch|handlerclass\([^)]*\))\s+)+'
                         r'(bool|int|float|string|color)\s+(\w+)\s*(?:=\s*(.+?))?\s*$', stmt, re.I)
            if m:
                default = (m.group(3) or "").strip().strip('"')
                cvars[m.group(2).lower()] = (m.group(1).lower(), default)
    return cvars


def parse_language(folder):
    """$NAME -> text, from LANGUAGE lumps (English), for labels given as $NAME."""
    table = {}
    for name in sorted(os.listdir(folder)):
        if name.lower().split(".")[0] != "language":
            continue
        for raw in read(os.path.join(folder, name)):
            m = re.match(r'\s*(\w+)\s*=\s*"((?:[^"\\]|\\.)*)"', raw)
            if m:
                table.setdefault(m.group(1).upper(), m.group(2))
    return table


def parse_menudef(path):
    """-> (values {name: {value: label}}, menus [(name, title, [rows])])
    row = dict(kind, label, target, args, tip, heading)"""
    values, menus = {}, []
    if not path:
        return values, menus
    block, name, depth, tip, heading, cur = None, None, 0, "", "", None
    pending = None
    for raw in read(path):
        m = re.match(r"\s*//\s*tip:\s*(.*)$", raw, re.I)
        if m:
            tip = m.group(1).strip()
            continue
        line = strip_comment(raw).strip()
        if not line:
            continue
        tk = tokens(line)
        head = tk[0].lower() if tk else ""
        if depth == 0:
            if head in ("optionvalue", "optionstring") and len(tk) > 1:
                pending = ("values", tk[1])
            elif head in ("optionmenu", "addoptionmenu") and len(tk) > 1:
                pending = ("menu", tk[1])
            if "{" in line and pending:
                block, name = pending
                pending = None
                depth = 1
                if block == "values":
                    cur = values.setdefault(name.lower(), {})
                else:
                    found = [mm for mm in menus if mm[0].lower() == name.lower()]
                    if found:
                        cur = found[0]
                    else:
                        cur = [name, "", []]
                        menus.append(cur)
                    heading = ""
            continue
        if "{" in line and head != "{":
            depth += line.count("{")
        if head == "{":
            depth += 1
            continue
        if head == "}" or line == "}":
            depth -= 1
            if depth == 0:
                block, tip = None, ""
            continue
        if block == "values":
            if len(tk) >= 2:
                cur[tk[0]] = tk[1]
            continue
        if block != "menu":
            continue
        if head == "title" and len(tk) > 1:
            cur[1] = tk[1]
        elif head == "class":
            pass
        elif head == "statictext":
            text = tk[1].strip() if len(tk) > 1 else ""
            if text:
                heading = text
            tip = ""
        elif len(tk) >= 2 and re.match(r'\s*\w+\s+"', line):
            cur[2].append(dict(kind=tk[0], label=tk[1], target=tk[2] if len(tk) > 2 else "",
                               args=tk[3:], tip=tip, heading=heading))
            tip = ""
    return values, menus


def fmt_num(text):
    try:
        v = float(text)
    except ValueError:
        return text
    return ("%g" % v)


def default_text(row, cvars, values):
    kind = row["kind"].lower()
    cv = cvars.get(row["target"].lower())
    if kind in ("command", "safecommand", "submenu", "control") or cv is None:
        if kind in ("command", "safecommand") or kind.endswith("resetall") or kind.endswith("reset"):
            return "(button)"
        if kind == "submenu":
            return "(page)"
        if kind == "control":
            return "(key)"
        return ""
    ctype, d = cv
    if kind in SLIDERS or kind.endswith("slider"):
        rng = ""
        if len(row["args"]) >= 2:
            rng = " (%s to %s)" % (fmt_num(row["args"][0]), fmt_num(row["args"][1]))
        return fmt_num(d) + rng
    if row["args"]:
        vname = row["args"][0].lower()
        table = values.get(vname) or BUILTIN_VALUES.get(vname)
        if table:
            for key in (d, fmt_num(d), d.lower()):
                if key in table:
                    return table[key]
            try:
                for k, label in table.items():
                    if float(k) == float(d):
                        return label
            except ValueError:
                pass
    if ctype == "string":
        return '"%s"' % d if d else "(blank)"
    return fmt_num(d)


def cell(text):
    return text.replace("|", "\\|").strip()


def options_block(menus, values, cvars, lang):
    def label_of(text):
        if text.startswith("$"):
            return lang.get(text[1:].upper(), text)
        return text

    pages = [m for m in menus if m[0].lower() not in SKIP_MENUS and m[2]]
    if not pages:
        return ["This mod has no options page."]
    links = {}
    for m in menus:
        if m[0].lower() in SKIP_MENUS:
            for r in m[2]:
                if r["kind"].lower() == "submenu" and r["target"]:
                    links[r["target"].lower()] = label_of(r["label"])
    front_title, front_name = "", ""
    out = []
    for i, (name, title, rows) in enumerate(pages):
        table = ["| Option | Default | What it does |", "|---|---|---|"]
        last = None
        for r in rows:
            if r["heading"] != last and r["heading"]:
                table.append("| **%s** | | |" % cell(label_of(r["heading"])))
            last = r["heading"]
            table.append("| %s | %s | %s |" % (cell(label_of(r["label"])), cell(default_text(r, cvars, values)),
                                             cell(r["tip"])))
        shown = label_of(title) or name
        # the mod's own name, as its row in the series' Options menu spells it (a Title is all capitals)
        if i == 0:
            front_title = shown
            front_name = links.get(name.lower(), "")
        if front_name and shown.upper().startswith(front_title.upper()):
            rest = shown[len(front_title):]
            shown = front_name + (rest.title() if rest.isupper() else rest)
        elif shown.isupper():
            shown = " ".join(w if w in ("RSQ", "VR", "UBQ", "BD", "HUD") else w.capitalize() for w in shown.split())
        if i == 0:
            out += ["Options > Radiant Silvergun Options > %s" % shown, ""] + table
        else:
            out += ["", "<details><summary>%s (%d rows)</summary>" % (shown, len(rows)), ""] + table + \
                   ["", "</details>"]
    return out


def keys_block(path, lang):
    if not path:
        return ["This mod has no keys."]
    section, keys, binds = "", [], {}
    for raw in read(path):
        tk = tokens(strip_comment(raw))
        if not tk:
            continue
        head = tk[0].lower()
        if head == "addkeysection" and len(tk) > 1:
            section = tk[1]
        elif head == "addmenukey" and len(tk) > 2:
            keys.append((tk[1], tk[2]))
        elif head == "defaultbind" and len(tk) > 2:
            binds.setdefault(tk[2], []).append(tk[1])
    if not keys:
        return ["This mod has no keys."]
    out = ["Options > Customize Controls > %s" % section, "", "| Key | Default bind | Command |", "|---|---|---|"]
    for label, cmd in keys:
        if label.startswith("$"):
            label = lang.get(label[1:].upper(), label)
        out.append("| %s | %s | `%s` |" % (cell(label), ", ".join(binds.get(cmd, [])) or "none", cmd))
    return out


def replace_block(lines, tag, body):
    start, end = "<!-- GEN:%s -->" % tag, "<!-- /GEN:%s -->" % tag
    try:
        a = next(i for i, l in enumerate(lines) if l.strip() == start)
        b = next(i for i, l in enumerate(lines) if l.strip() == end and i > a)
    except StopIteration:
        sys.exit("README has no %s ... %s block" % (start, end))
    return lines[:a + 1] + body + lines[b:]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    check = "--check" in sys.argv
    if len(args) != 1:
        sys.exit(__doc__)
    folder = args[0].rstrip("/")
    readme = os.path.join(folder, "README.md")
    # a mod that ships from a subfolder (VisualRewards: <Mod>/pk3/) keeps its lumps there
    lumps = os.path.join(folder, "pk3") if os.path.isfile(os.path.join(folder, "pk3", "zscript.txt")) else folder
    cvars = parse_cvarinfo(find_lump(lumps, "cvarinfo"))
    values, menus = parse_menudef(find_lump(lumps, "menudef"))
    lang = parse_language(lumps)
    old = read(readme)
    new = replace_block(old, "keys", keys_block(find_lump(lumps, "keyconf"), lang))
    new = replace_block(new, "options", options_block(menus, values, cvars, lang))
    if check:
        if new != old:
            sys.exit("%s: generated tables are out of date" % readme)
        return
    with open(readme, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(new) + "\n")
    rows = sum(len(m[2]) for m in menus if m[0].lower() not in SKIP_MENUS)
    print("%s: %d option rows, %d pages" % (readme, rows, len([m for m in menus if m[0].lower() not in SKIP_MENUS and m[2]])))


if __name__ == "__main__":
    main()
