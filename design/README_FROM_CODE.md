# READMEs from code (owner 2026-11-27)

Owner: "all readmes are stale. each mod needs a new readme made from reading the code. possible bugs need to be
presented to me as questions with selectable fixes."

This is the brief every reader follows, one reader per mod. The code is the only source.

## Rules

1. Read ALL of the mod's code first: every ZScript file whole (no skimming, no grep-only), MENUDEF, CVARINFO, KEYCONF,
   MAPINFO, and the other definition lumps. Tools and evidence folders are not the mod; skip them unless code points there.
2. Do NOT open the mod's README.md (or old handoffs / docs) until your new README is written. Comments in code are
   claims, not facts: where a comment and the code disagree, the code wins and the disagreement is a finding.
3. Then open the old README once, for two things only:
   - credits, licences and thanks (not derivable from code): carry them over unchanged;
   - anything it says the mod does that you did not find in code: each one is a finding ("README says X; code has no X").
4. Change NO code, settings, menus or assets. Do not commit. Do not build.
5. Follow `WHO_OWNS_WHAT.md`: a mechanic another mod owns is one line under "Works with", not described here.
6. Words: plain and short. No casino words. No marketing. Say what the player does and what happens.
   Do not expand the guiding statement in CLAUDE.md into anything.

## Files a reader writes (three, in the mod's folder)

### `README.md` (replaces the old one)

```
# RSQ <Name>

<Two or three sentences: what it is, in the player's terms.>

<a name="how-to-play"></a>
## How to play

| Do this | What happens | Needs |
|---|---|---|
| <the body move, grip, trigger or key> | <what the code does> | <the option that must be on, with its default; another mod if required; blank if nothing> |

(One row per thing a player can DO with default settings first, then rows that need a non-default option.
 A row for a move with a body gesture names the place on the body. Keep each cell one line.)

## Keys

<!-- GEN:keys -->
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| <other mod, found by name in code> | <what this mod does differently when it is loaded> |

## Limits

- <things the code plainly does not do or guards against, that a player would hit>

## Credits

<carried over from the old README / CREDITS.txt>

---
Written from the code at commit <hash>, <date>.
```

Leave the two GEN blocks empty: `tools/readme/gen_readme_tables.py` fills them from MENUDEF / CVARINFO / KEYCONF.

### `docs/README_SOURCES.md`

One line per claim in the README (every How to play row, every Works with row, every Limit):

```
| # | Claim (short) | File:line | Function |
```

Line numbers must be exact at the commit read. A claim you cannot cite does not go in the README.

### `docs/FINDINGS_2026-11-27.md`

Possible bugs and disagreements, for the owner to answer. Do not decide for him. Each one:

```
## F<n>: <one line, plain words>
- Kind: possible bug | comment disagrees with code | menu disagrees with code | README claimed, not in code | dead code | setting with no effect | other
- Where: <file:line> (and the second place if it is a disagreement)
- What the code does: <facts only>
- Why it looks wrong: <the reason, and what a player would notice, if anything>
- Sure?: certain | likely | unsure (say what would settle it: a rig test, an owner answer)
- Fix A: <smallest change> (size: lines / files)
- Fix B: <alternative, if there is a real one>
- Or intended: <what the README would then say>
```

Order them: what a player would notice first. Put pure wording / comment mismatches last under a heading
"Small ones (one answer for all)".

## Report back

A short list: files written, count of How to play rows, count of findings by kind, anything you could not read.
