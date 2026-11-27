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
| Wheel | done, tables generated, brought up to his changes | done | 19 + 7 small, plus N1 and N2 from him | F1 to F6 and F12 answered; F7 to F19, N1 (no beam), N2 (reach in, pull, throw back) and the small ones still open |
| ShieldSaw | done (44 rows), tables generated | done | 8 + 10 small | none yet |
| SlowMo | done (36 rows; it has an extra section "For other mods": the service), tables generated | done (186 rows) | 11 + 13 small | none yet |
| Tactical Rig | reader running again since 06:40 (the first one stopped with no report) | | | |
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

Second round (06:4x):
- Use and grenades: "when the wheel is open i don't want to be opening doors or throwing grenades." Done: the Wheel takes
  Use, Toss Grenade (+user1) and Quick Grenade while it is up.
- "i've never known what hold, point, release ever meant so remove it": done. The key is "Open Wheel": it opens and closes.
- "the whole stick lights a card thing is stupid, get that out": done.
- Next / prev and the gold light: new row Skip Holstered Guns (default Off; On: holstered guns are skipped and the
  cards next / prev reaches wear the light).
- The data sheet: he says it already shows the pointing hand's gun; the code now uses the pointing hand's copy too.
- HE REPORTED (N1): sabers, whip, hands, chainsaw, axe, maybe the ShieldSaw cast NO BEAM in the wheel. Not explained yet.
- HE DOUBTS (N2): reaching into a card and pulling it out (the ring is about 1 m away, the reach about 20 cm), and
  throwing a gun back at the ring. Both are in the code. Ask: remove or keep.

TOOLS: after any code change in a mod with a sources file, run
`python3 tools/readme/remap_sources.py <Mod> <ref> [ALIAS=path ...]` (Wheel: `Z=zscript/wheel/zscript.zs W=zscript/wheel/wr_web.zs S=zscript/wheel/wr_q_shim.zs`),
fix the rows it marks `(!)`, then `python3 tools/readme/gen_readme_tables.py <Mod>`.
READERS cannot write the findings file themselves (their Write is refused for it): they return it as text and it is saved for them.

## Not verified

- NOTHING HERE HAS BEEN COMPILED OR RUN. The Wheel code changes (wr_time and the settings move, Use and the grenade keys, the release and the stick, Skip Holstered Guns, the sheet's hand) need the rig
  (`tools/rig17`, `runall17.sh`: zero script errors) and a headset look before they ship. `pk3/RSQ_Wheel.pk3` is NOT rebuilt.
- The READMEs' claims are checked against code lines, not against behaviour in the headset.

## Controls map

`design/CONTROLS_MAP.md` (draft). Has: base Brutal Doom's 18 key commands (reference only), the RSQ keys, the five mods
that read raw grip key codes. MISSING: the owner's ini (which button sends which command; `vr_secondary_button_mappings`),
and the read of his BD22 VR weapons code (RSQ_BD_VR_Reloaded, 61,902 lines: every input each weapon takes). The optional
default control profile is drafted only after both.
