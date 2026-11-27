# READMEs from code, and what the in-game How To Play needs from them: STATUS

Started 2026-11-27 (owner). Come back to this file first. Branch: `readme-from-code`.

## Why this exists

1. Owner: "all readmes are stale. each mod needs a new readme made from reading the code. possible bugs need to be
   presented to me as questions with selectable fixes."
2. The in-game How To Play (handoff of 2026-11-27: one menu, a tab per loaded mod, Score's Glossary as Score's tab,
   Show Me with the Tactical Rig's ghost hand) is GENERATED from each README's How to play table. So the READMEs come
   first, and their shape is fixed so a generator can read them.
3. Owner: "we should ship an optional default control profile", and "my current ini needs to be dissected to establish
   controls for doom itself, brutal doom vr weapons, and RSQ mods loaded."

## How it is done

- `design/README_FROM_CODE.md`: the brief every reader follows. One reader per mod reads ALL the mod's code, then writes
  `<Mod>/README.md` (fixed template), `<Mod>/docs/README_SOURCES.md` (file:line for every claim) and
  `<Mod>/docs/FINDINGS_2026-11-27.md` (possible bugs as questions, each with candidate fixes).
- `tools/readme/gen_readme_tables.py <Mod>`: fills the README's Keys and Options tables from KEYCONF, MENUDEF ("// tip:"
  comments) and CVARINFO. `--check` fails when a README's tables are stale. Run it after any menu or setting change.
- The owner answers the findings as selectable questions, one mod at a time, most visible first. His answer is written
  into the findings file under the finding ("OWNER <date>: ..."). Fixes are separate commits from the READMEs.
- OWNER RULE (11-27): NOTHING IS PARKED. Every finding ends as a fix or as "intended". Do not offer "park it".
- OWNER RULE (11-27): CONTROLS means everything the player physically does that makes the game respond: every button,
  trigger, grip and stick on both controllers, and every hand or body move, with what it does in Doom itself, in his
  BD22 VR weapons (repo RSQ_BD_VR_Reloaded: his; base Brutal Doom is not his and is only a reference), and in each RSQ mod.

## What the How To Play generator will take from each README

- The table under `<a name="how-to-play">`: columns `Do this | What happens | Needs`. One row = one list entry in the
  mod's tab; "Needs" names the option (with its default) or the other mod. Rows that need a non-default option come last.
- A row whose "Do this" is a body move is a Show Me candidate (names the place on the body).
- The Keys table (GEN:keys): the command for each key, so a page can print the button it is bound to now
  (as `DistanceGrab/zscript/rsqdg/menurows.zs` and Gun Bonsai's menu already read binds), or NOT BOUND.
- Still to decide with the owner (from the handoff): which moves get Show Me first; a first-run "How To Play: F1" prompt.
- Score's font is capitals only, ASCII 32-96: the generator must upper-case and strip anything else.

## Per mod

| Mod | README from code | Sources | Findings | Owner's answers |
|---|---|---|---|---|
| Wheel | done, tables generated | done (312 cites) | 19 + 7 small | F1 to F4 answered (below); F5 to F19 and the small ones still to ask |
| Tactical Rig | NOT DONE: its reader was stopped at 06:1x with no report; a partial draft is left untracked at `TacticalRig/README.new.md` (not checked, do not trust) | no | no | - |
| ShieldSaw | reader running (started 06:33) | | | |
| SlowMo | reader running (started 06:33) | | | |
| all others | not started | | | |

Order after these: Distance Grab, Grapple, Grenade, Whip, Melee, Flashlight & Flare, Saber, Gun Cards, Gun Bonsai VR,
LaserSight, Score, Accessibility, Miniboss, Monsters, MonsterRecolour, Graveyard, Glow In The Dark, VisualRewards, PlayLog.

## The owner's answers so far

### Wheel (asked 2026-11-27 06:2x)

- The Wheel's controls, in his words: "it is primary fire on either hand to choose and close, offhand secondary fire to
  choose and keep open, and mainhand secondary fire to open rig assignment." Use takes no card. The Open Wheel key opens
  and closes; it is not how a gun is chosen ("why would anyone select a weapon by pressing 'open wheel'?").
- F1 (a gun inside a slot is not reachable by the key alone): intended.
- F2 (Slow Time dead while Freeze Time on): fixed. One row, Time While Open: Normal / Slow / Frozen (`wr_time`).
  He read "Mo" too many times: keep "SlowMo" out of labels; the mod's name appears once, in the tip.
- F3 (Use): Use with the hand in a card no longer takes it. Open: Use from a distance still reaches the game; Use still
  opens a fan on the When Crowded layout.
- F4 (a press on the data sheet does nothing): intended.

TO CHECK AGAINST HIS WORDS (not asked yet): the README still lists other ways a card is taken that are in the code:
letting go of a held Open Wheel on a card, pulling a hand back out of a card, pushing the stick. If the three inputs he
named are meant to be the ONLY ways, those are findings.

## Not verified

- NOTHING HERE HAS BEEN COMPILED OR RUN. The Wheel code changes (wr_time, the settings move, Use) need the rig
  (`tools/rig17`, `runall17.sh`: zero script errors) and a headset look before they ship. `pk3/RSQ_Wheel.pk3` is NOT rebuilt.
- The READMEs' claims are checked against code lines, not against behaviour in the headset.

## Controls map

`design/CONTROLS_MAP.md` (draft). Has: base Brutal Doom's 18 key commands (reference only), the RSQ keys, the five mods
that read raw grip key codes. MISSING: the owner's ini (which button sends which command; `vr_secondary_button_mappings`),
and the read of his BD22 VR weapons code (RSQ_BD_VR_Reloaded, 61,902 lines: every input each weapon takes). The optional
default control profile is drafted only after both.
